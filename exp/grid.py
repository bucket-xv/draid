import subprocess
import os
import json
from tools.info import parse_pg
import shutil
import numpy as np
from tools.convert import dict_to_str
from tools.osdmap import osd_node_mapping

def sub(tx_0, rx_0, tx_1, rx_1):
    for i in range(len(tx_0)):
        tx_1[i] -= tx_0[i]
        rx_1[i] -= rx_0[i]
    return {'tx': tx_1, 'rx': rx_1}

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

username = 'BucketXv'
output_base_dir = os.path.expanduser('~/draid/logs')

def main():
    import argparse

    # Create the parser
    parser = argparse.ArgumentParser(description='Run the experiment according to the config file')

    parser.add_argument('-e','--interface', type=str, required=True, help='the interface to monitor and limit')

    parser.add_argument('-c', '--config', type=str, required=True, help='the config name to use')

    parser.add_argument('-v', '--verbose', action='store_true', default=False, help='Verbose output')

    parser.add_argument('-m', '--mode', type=str, default='rgw', choices=['rgw', 'rados'], help='the mode to run the experiment')

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
            for i in range(1,len(bandwidth_list)):
                f.write(str(int(bandwidth_list[i])) + '\n')
            f.flush()
            os.fsync(f.fileno())
        output_name = dict_to_str(config)
        output_dir = os.path.join(output_base_dir, output_name)
        command1 = ['./setup.sh',  config['num_files'] * config['num_cores'] * cli_num, config['file_size'], int(bandwidth_list[0]), args.mode, args.data_num, args.parity_num]
        command1 = map(str, command1)
        command2 = ['./sync_read.sh', username, config['num_files'], config['file_size'], config['num_cores'], output_dir, interface, args.mode]
        command2 = map(str, command2)
        command3 = ['./cleanup.sh']
        command3 = map(str, command3)
        watch_command = ['./watch_remote.sh',interface ]
        # sudo ceph pg ls-by-pool default.rgw.buckets.data
        pg_command = ['sudo', 'ceph', 'pg', 'ls-by-pool', 'default.rgw.buckets.data']
        
        primary_affinity = bandwidth_list/np.max(bandwidth_list)
        node_to_osd_mapping, osd_to_node_mapping = osd_node_mapping()
        assert len(primary_affinity) == len(node_to_osd_mapping)
        for osd, node in osd_to_node_mapping.items():
            primary_command = ['sudo', 'ceph', 'osd', 'primary-affinity', str(osd), format(primary_affinity[node],'.2f')]
            subprocess.run(primary_command,capture_output=not args.verbose, text=True, check=True)

        # Execute the command
        subprocess.run(command1,capture_output=not args.verbose, text=True, check=True)
        
        if config['read_balance'] == 1:
            balance_command = ['./do_read_balance.sh']
            subprocess.run(balance_command)
        
        before = subprocess.run(watch_command,capture_output=True, text=True, check=True)
        tx_0, rx_0 = parse_watch(before.stdout)

        print('Executing!')
        result = subprocess.run(command2, capture_output=not args.verbose, text=True, check=True)
        print('Execution Ends!')

        after = subprocess.run(watch_command,capture_output=True, text=True, check=True)
        tx_1, rx_1 = parse_watch(after.stdout)

        pg_logs = subprocess.run(pg_command,capture_output=True, text=True, check=True)

        logs[output_name] = {
            'real': sub(tx_0,rx_0,tx_1,rx_1),
            'estimate': multi(parse_pg(pg_logs.stdout.strip().split('\n'), args.parity_num),int(config['num_cores'])),
        }

        subprocess.run(command3,capture_output=not args.verbose, text=True, check=True)
    
    with open('../logs/logs.json', 'w') as f:
        json.dump(logs, f)

if __name__ == "__main__":
    main()
