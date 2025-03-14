import subprocess
import os
import json
from tools.info import parse_pg
import shutil
import numpy as np
from tools.convert import dict_to_str
from tools.osdmap import osd_node_mapping
from tools.image import push_image

def sub(tx_0, rx_0, tx_1, rx_1):
    if len(tx_0) == len(tx_1):
        for i in range(len(tx_0)):
            tx_1[i] -= tx_0[i]
            rx_1[i] -= rx_0[i]
        return {'tx': tx_1, 'rx': rx_1}
    else:
        return 'Error: The length of tx_0 and tx_1 are not equal!'

def parse_watch(output):
    lines = output.strip().split('\n')
    cal_rx = []
    cal_tx = []
    for i in range(0, len(lines),2):
        cal_rx.append(float(lines[i]))
        cal_tx.append(float(lines[i+1]))
    return cal_tx, cal_rx

def multi(dict, num):
    for key, value in dict.items():
        dict[key] = [single_value * num for single_value in value]
    return dict

output_base_dir = os.path.expanduser('~/draid/logs')

def main():
    import argparse

    # Create the parser
    parser = argparse.ArgumentParser(description='Run the experiment according to the config file')

    parser.add_argument('-e', '--interface', type=str, required=True, help='the interface to monitor and limit')

    parser.add_argument('-c', '--config', type=str, required=True, help='the config name to use')

    parser.add_argument('-v', '--verbose', action='store_true', default=False, help='Verbose output')

    parser.add_argument('-d', '--data_num', type=int, default=4, help='the number of data chunks')

    parser.add_argument('-p', '--parity_num', type=int, default=1, help='the number of parity chunks')
    
    # Parse the arguments
    args = parser.parse_args()
    
    config_file = os.path.join('settings', f'{args.config}.json')

    interface = args.interface

    with open(config_file, 'r') as f:
        config_list = json.load(f)
    
    cli_path = os.path.expanduser('~/draid/deploy/int_ip_addrs_cli.txt')
    with open(cli_path, 'r') as f:
        cli_num = len(f.readlines())

    try:
        shutil.rmtree(output_base_dir)
        print(f"Directory '{output_base_dir}' has been removed successfully.")
    except OSError as error:
        print(f"Warning: {output_base_dir} : {error.strerror}")

    logs={}
    # Loop through each set of arguments and execute the script
    for idx,config in enumerate(config_list):
        print('Executing with config: ', config)
        
        bandwidth_list = np.array(config['bandwidth']) * 1e6 # convert to Kbps
        commute_file = '/tmp/bandwidth.txt'
        with open(commute_file, 'w') as f:
            for band in bandwidth_list:
                f.write(str(int(band)) + '\n')
            f.flush()
            os.fsync(f.fileno())
        output_name = dict_to_str(config)
        output_dir = os.path.join(output_base_dir, output_name)
        

        watch_command = ['tools/watch_remote.sh',interface ]
        pg_command = ['sudo', 'ceph', 'pg', 'ls-by-pool', 'default.rgw.buckets.data']
        
        # Set the primary affinities
        primary_affinity = bandwidth_list/np.max(bandwidth_list)
        node_to_osd_mapping, osd_to_node_mapping = osd_node_mapping()
        assert len(primary_affinity) == len(node_to_osd_mapping)
        for osd, node in osd_to_node_mapping.items():
            primary_command = ['sudo', 'ceph', 'osd', 'primary-affinity', str(osd), format(primary_affinity[node],'.2f')]
            subprocess.run(primary_command,capture_output=not args.verbose, text=True, check=True)

        # Start Ceph rgw service and private registry
        start_cmd = map(str,['./setup.sh', args.data_num, args.parity_num])
        subprocess.run(start_cmd,capture_output=not args.verbose, text=True, check=True)

        # Push images to private registry
        num_files = config['num_files'] * config['num_cores'] * cli_num
        file_size= config['file_size'] * 1024 * 1024 # Convert to num of bytes
        push_command= map(str, ['tools/push_image.sh', num_files, file_size])
        subprocess.run(push_command,capture_output=not args.verbose, text=True, check=True)
        
        # perform read balance if needed
        if config['read_balance'] == 1:
            balance_command = ['./tools/do_read_balance.sh']
            subprocess.run(balance_command)
        
        # Record the base flow
        before = subprocess.run(watch_command,capture_output=True, text=True, check=True)
        tx_0, rx_0 = parse_watch(before.stdout)
        print('Setup completed!')

        # Execute the experiment
        exp_cmd = map(str, ['./sync_read.sh', config['num_files'], config['num_cores'], output_dir, interface])
        subprocess.run(exp_cmd, capture_output=not args.verbose, text=True, check=True)
        print('Execution Ends!')

        # Record the after flow
        after = subprocess.run(watch_command,capture_output=True, text=True, check=True)
        tx_1, rx_1 = parse_watch(after.stdout)
        
        # Record the PG logs
        pg_logs = subprocess.run(pg_command,capture_output=True, text=True, check=True)
        logs[output_name] = {
            'real': sub(tx_0,rx_0,tx_1,rx_1),
            'estimate': multi(parse_pg(pg_logs.stdout.strip().split('\n'), args.parity_num),int(config['num_cores'])),
        }

        # Cleanup
        cleanup_cmd = ['./cleanup.sh']
        subprocess.run(cleanup_cmd,capture_output=not args.verbose, text=True, check=True)
    
    with open('../logs/logs.json', 'w') as f:
        json.dump(logs, f)

if __name__ == "__main__":
    main()
