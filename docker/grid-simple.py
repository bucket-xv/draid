import subprocess
import os
import json
import summary
import shutil
import numpy as np
from tools.convert import dict_to_str
from tools.osdmap import osd_node_mapping
import time
import argparse
import logging

project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def sub(tx_0, rx_0, tx_1, rx_1):
    if len(tx_0) == len(tx_1):
        for i in range(len(tx_0)):
            tx_1[i] -= tx_0[i]
            rx_1[i] -= rx_0[i]
        return {'tx': tx_1, 'rx': rx_1}
    else:
        return 'Error: The length of tx_0 and tx_1 are not equal!'

def parse_watch(output, osd_num):
    lines = output.strip().split('\n')
    cal_rx = []
    cal_tx = []
    for i in range(0, min(len(lines), osd_num * 2),2):
        try:
            cal_rx.append(float(lines[i]))
            cal_tx.append(float(lines[i+1]))
        except:
            logging.warning(f'Error parsing watch output: {lines}')
            cal_rx.append(float(lines[i].split(' ')[0]))
            cal_tx.append(float(lines[i+1].split(' ')[0]))
    return cal_tx, cal_rx

def multi(dict, num):
    for key, value in dict.items():
        dict[key] = [single_value * num for single_value in value]
    return dict

output_base_dir = os.path.join(project_dir, 'logs')

def setup(args, config):
    # Get the number of clients
    cli_path = os.path.join(project_dir, 'configs', 'int_ip_addrs_cli.txt')
    with open(cli_path, 'r') as f:
        cli_num = len(f.readlines())

    # Set the bandwidth list
    bandwidth_list = np.array(config['bandwidth']) * 1e6 # convert to Kbps
    commute_file = '/tmp/bandwidth.txt'
    with open(commute_file, 'w') as f:
        for band in bandwidth_list:
            f.write(str(int(band)) + '\n')
        f.flush()
        os.fsync(f.fileno())

    # Set the primary affinities
    primary_affinity = bandwidth_list/np.max(bandwidth_list)
    node_to_osd_mapping, osd_to_node_mapping = osd_node_mapping()
    assert len(primary_affinity) == len(node_to_osd_mapping)
    assert args.data_num + args.parity_num == len(primary_affinity)
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
    subprocess.run(push_command,capture_output=not args.verbose, text=True)

    # Set the bandwidth limit after all is done
    subprocess.run(['./limit_bandwidth.sh'], capture_output=not args.verbose, text=True)

def main():

    # Create the parser
    parser = argparse.ArgumentParser(description='Run the experiment according to the config file')

    parser.add_argument('-e', '--interface', type=str, required=True, help='the interface to monitor and limit')

    parser.add_argument('-c', '--config', type=str, required=True, help='the config name to use')

    parser.add_argument('-v', '--verbose', action='store_true', default=False, help='Verbose output')

    parser.add_argument('-d', '--data_num', type=int, default=4, help='the number of data chunks')

    parser.add_argument('-p', '--parity_num', type=int, default=1, help='the number of parity chunks')

    parser.add_argument('-m', '--mode', type=str, choices=['setup', 'run'], required=True, help='the mode to run')

    # Parse the arguments
    args = parser.parse_args()

    # Set the logging level
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.ERROR)

    start_time = time.time()
    
    config_file = os.path.join('settings', f'{args.config}.json')

    interface = args.interface

    with open(config_file, 'r') as f:
        config_list = json.load(f)

    try:
        shutil.rmtree(output_base_dir)
        logging.info(f"Directory '{output_base_dir}' has been removed successfully.")
    except OSError as error:
        logging.warning(f"{output_base_dir} : {error.strerror}")

    if args.mode == 'setup':
        setup(args, config_list[0])
        logging.info(f'Total setup time: {time.time() - start_time}')
        print('Setup done!')
        exit()

    logs={}
    # Loop through each set of arguments and execute the script
    for idx,config in enumerate(config_list):
        logging.info(f'Executing with config:    {config}')
        output_name = dict_to_str(config)
        output_dir = os.path.join(output_base_dir, output_name)
       
        # perform read balance if needed
        if config['read_balance'] == 1:
            balance_command = ['./tools/do_read_balance.sh']
            subprocess.run(balance_command, capture_output=not args.verbose)

        # Execute the experiment
        logging.info('Execution Starts!')
        exp_cmd = map(str, ['./sync_read.sh', config['num_files'], config['num_cores'], output_dir, interface])
        subprocess.run(exp_cmd, capture_output=not args.verbose, text=True, check=True)
        logging.info('Execution Ends!')

    # Cleanup
    cleanup_cmd = ['./cleanup.sh']
    subprocess.run(cleanup_cmd,capture_output=not args.verbose, text=True, check=True)
    
    with open('../logs/logs.json', 'w') as f:
        json.dump(logs, f)

    end_time = time.time()
    # print(f'Total experiment time: {end_time - start_time} seconds')
    summary.main()
    
if __name__ == "__main__":
    main()
