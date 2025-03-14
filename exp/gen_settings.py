import json
import numpy as np
import random

random.seed(233)

# Sampling 7 points from a standard Gaussian distribution
mean = 10
min_bandwidth = 1
max_bandwidth = 19

def count_file_lines(file_path):
    line_count = 0
    try:
        with open(file_path, 'r') as file:
            for line in file:
                line_count += 1
    except FileNotFoundError:
        print(f"The file at {file_path} was not found.")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
    return line_count

# num_servers = count_file_lines('../deploy/int_ip_addrs_server.txt') + 1

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-g', '--gaussian', action='store_true', default=False, help='if use a gaussian distribution to generate bandwidth')
    parser.add_argument('-n', '--num_servers', type=int, required=True, help='number of servers')
    parser.add_argument('-r', '--repetition', type=int, default=3, help='repetition times')
    parser.add_argument('-o', '--output', type=str, default='default', help='output file')
    parser.add_argument('-c', '--cores', type=int, default=1, help='number of cores')
    parser.add_argument('-f', '--files', type=int, default=10, help='number of files')
    parser.add_argument('-s', '--file_size', type=int, default=10, help='file size')
    args = parser.parse_args()
    
    repetition = args.repetition
    num_servers = args.num_servers
    np.random.seed(233)
    target_file = f'settings/{args.output}.json'
    output=[]
    for num_cores in [args.cores]:
        for num_files in [args.files]:
            if args.gaussian:
                for std_dev in np.arange(0, 5, 0.5):
                    for seq_num in range(0,repetition): 
                        bandwidth = np.random.normal(mean, std_dev, num_servers)
                        print(bandwidth)
                        bandwidth = np.clip(bandwidth, min_bandwidth, max_bandwidth)
                        for read_balance in [0, 1]:
                            config={
                                "num_cores": num_cores,
                                "num_files": num_files,
                                "file_size": args.file_size,
                                "bandwidth": list(bandwidth),
                                "read_balance": read_balance,
                                "std_deviation": std_dev,
                                "seq_num": seq_num
                            }
                            output.append(config)
            else:
                for std_dev in range(1,10,1):
                    bandwidth = [10 for _ in range(num_servers)]
                    bandwidth[0] = std_dev
                    for seq_num in range(0,repetition):
                        random.shuffle(bandwidth)
                        for read_balance in [0, 1]:
                            config={
                                "num_cores": num_cores,
                                "num_files": num_files,
                                "file_size": args.file_size,
                                "bandwidth": list(bandwidth),
                                "read_balance": read_balance,
                                "std_deviation": std_dev,
                                "seq_num": seq_num
                            }
                            output.append(config)

    with open(target_file, 'w') as f:
        json.dump(output, f, indent=4)

if __name__ == "__main__":
    main()