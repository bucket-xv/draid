import os
import numpy as np
import matplotlib.pyplot as plt
# import pandas as pd
import csv
import argparse
from tools.convert import str_to_dict

# Replace 'parent_directory' with the path to your log directory
project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
base_directory = os.path.join(project_dir, 'save_logs')

parser = argparse.ArgumentParser(description='Plot the average latency of the logs')
parser.add_argument('-m', '--mode', type=str, default='bottleneck', choices=['bottleneck', 'gaussian'], help='the mode to plot') 
parser.add_argument('-f', '--from-index', type=int, default=None, help='the start index to plot')
parser.add_argument('-t', '--to-index', type=int, default=None, help='the end index to plot')
parser.add_argument('-i', '--input-dir', type=str, default='logs', help='the input directory')

args = parser.parse_args()

parent_directory  = os.path.join(base_directory, args.input_dir)

# Get a list of folders in the parent directory
folders = [f for f in os.listdir(parent_directory) if os.path.isdir(os.path.join(parent_directory, f))]
folders = sorted(folders)

# Initialize a list to store the average values of latency
average_latency = []


# Loop through each folder
for folder in folders:
    
    folder_path = os.path.join(parent_directory, folder)
    total_sum = 0
    total_count = 0
    
    # Loop through each file in the folder
    for file_name in os.listdir(folder_path):
        traffic = []
        file_path = os.path.join(folder_path, file_name)
        
        # Check if it's a file and not a directory
        if os.path.isfile(file_path) and file_name.endswith('.log'):
            with open(file_path, 'r') as file:
                # Read all numbers from the file
                numbers = [float(line.strip()) for line in file if line.strip().replace('.', '', 1).isdigit()]
                total_sum += sum(numbers)
                total_count += len(numbers)
        
    #     elif os.path.isfile(file_path) and file_name.endswith('traffic.csv'):
    #         with open(file_path, newline='') as csvfile:
    #             csv_reader = csv.reader(csvfile)
    #             headers = next(csv_reader)  # Skip the header row
    #             for row in csv_reader:
    #                 # Assuming the data is in a format that can be converted to float
    #                 traffic.append(float(row[1]))
    #     if traffic != []:
    #         for i in range(len(traffic)-1, 0, -1):
    #             traffic[i] -= traffic[i-1]
    #         plt.plot(traffic, label=file_name)

    # plt.title(folder)
    # # plt.show()
    # plt.xlabel('Time')
    # plt.ylabel('Bytes')
    # plt.legend()
    # plt.savefig(f'images/{folder}.png')
    # plt.close()
    
    # Calculate the average for the folder
    if total_count > 0:
        average = total_sum / total_count
    else:
        average = 0
    average_latency.append(average)

# Group the folders based on their arguments
config = [str_to_dict(folder) for folder in folders]
# config,average_latency = zip(*sorted(zip(config,average_latency), key=lambda x: (int(x[0]['num_cores']), int(x[0]['num_files']),  float(x[0]['bandwidth']),float(x[0]['file_size']))))

# # Group the config based on num_cores value
# num_cores_seq=[]
# subplots_keys = []
# subplots_values = []
# for i in range(len(config)):
#     num_cores = config[i]['num_cores']
#     if num_cores not in num_cores_seq:
#         num_cores_seq.append(num_cores)
#         subplots_keys.append([])
#         subplots_values.append([])
#     index = num_cores_seq.index(num_cores)
#     subplots_keys[index].append(config[i]['bandwidth'] + 'gbps_' + config[i]['num_files'] + 'files' + ('_balance' if config[i]['read_balance'] else ''))
#     subplots_values[index].append(average_latency[i])


# # Plotting the bar graph for each num_cores value
# fig, axs = plt.subplots(len(num_cores_seq),1, figsize=(20, 5+3*len(num_cores_seq)))
# if len(num_cores_seq)==1:
#     axs = [axs]
# for i in range(len(num_cores_seq)):
#     num_cores = num_cores_seq[i]
#     bars = axs[i].bar(subplots_keys[i][:8], subplots_values[i][:8])

#     # Add the data labels on top of each bar
#     for bar in bars:
#         yval = bar.get_height()
#         axs[i].text(bar.get_x() + bar.get_width()/2, yval, round(yval, 2), va='bottom')  # va: vertical alignment
#     axs[i].set_xlabel('Settings')
#     axs[i].set_ylabel('Average Latency (s)')
#     axs[i].set_title(f'Average Latency in different Settings for {num_cores} Cores')
# plt.tight_layout()

# Show the plot
# plt.savefig('images/average_latency.png')
# plt.close()

# if args.inbalance:
inbalance_plot_dict = {}
balance_plot_dict = {}
merged_config = {}  
for i in range(len(config)):
    conf = config[i]
    dup_conf = conf.copy()
    dup_conf.pop('seq_num')
    if tuple(dup_conf.items()) not in merged_config:
        merged_config[tuple(sorted(dup_conf.items()))] = []
    merged_config[tuple(sorted(dup_conf.items()))].append(i)
for key in merged_config:
    latency_list = []
    for i in merged_config[key]:
        latency_list.append(average_latency[i])       
        num_cores = config[i]['num_cores']
        num_files = config[i]['num_files']
        std_deviation = config[i]['std_deviation']  
        read_balance = config[i]['read_balance']
    avg = np.median(np.array(latency_list))

    if read_balance:
        if (num_cores, num_files) not in balance_plot_dict:
            balance_plot_dict[(num_cores, num_files)] = {} # ([bandwidth], [average_latency])
        # balance_plot_dict[(num_cores, num_files)][0].append(config[i]['std_deviation'])
        # balance_plot_dict[(num_cores, num_files)][1].append(average_latency[i])
        balance_plot_dict[(num_cores, num_files)][std_deviation] = avg
        print
    else:
        if (num_cores, num_files) not in inbalance_plot_dict:
            inbalance_plot_dict[(num_cores, num_files)] = {} # ([bandwidth], [average_latency])
        # inbalance_plot_dict[(num_cores, num_files)][0].append(config[i]['std_deviation'])
        # inbalance_plot_dict[(num_cores, num_files)][1].append(average_latency[i])
        inbalance_plot_dict[(num_cores, num_files)][std_deviation] = avg

# Plotting the bar graph for each num_cores, num_files pair
fig, axs = plt.subplots(len(inbalance_plot_dict),1, figsize=(20, 5+3*len(balance_plot_dict)))
if len(inbalance_plot_dict)==1:
    axs = [axs]
for i in range(len(inbalance_plot_dict)):
    num_cores, num_files = list(inbalance_plot_dict.keys())[i]

    data = list(inbalance_plot_dict.values())[i]
    data = sorted(data.items())[args.from_index:args.to_index]
    data_x, data_y = zip(*data)
    axs[i].scatter(data_x, data_y, label='Inbalance')

    data = list(balance_plot_dict.values())[i]
    data = sorted(data.items())[args.from_index:args.to_index]
    data_x, data_y = zip(*data)
    axs[i].scatter(data_x, data_y, label='Balance')

    if args.mode == 'bottleneck':
        axs[i].set_xlabel('Bottleneck Bandwidth (Gbps)')
        axs[i].invert_xaxis()
    elif args.mode == 'gaussian':
        axs[i].set_xlabel('Standard Deviation')
    else:
        raise NotImplementedError
    axs[i].set_ylabel('Average Latency (s)')
    axs[i].set_title(f'Average Latency in different Settings for {num_cores} cores, {num_files} files')
    axs[i].legend()
plt.tight_layout()

# Show the plot
plt.savefig('images/inbalance-latency.png')
plt.close()