import os
import warnings
import csv
import numpy as np

project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
output_base_dir = os.path.join(project_dir, 'logs')

def main():
    print('Experiment Summary:')
    # Iterate over the output_dir and print the results
    for output_dir in os.listdir(output_base_dir):
        latencies = []
        traffic = []
        if not os.path.isdir(os.path.join(output_base_dir, output_dir)):
            continue

        for file in os.listdir(os.path.join(output_base_dir, output_dir)):
            if file.endswith('out.log'):
                with open(os.path.join(output_base_dir, output_dir, file), 'r') as f:
                    for line in f:
                        if line.strip() == '':
                            continue
                        try:
                            latencies.append(float(line.strip()))
                        except:
                            warnings.warn(f'Error parsing line: {line}')
            elif file.endswith('.csv'):
                with open(os.path.join(output_base_dir, output_dir, file), 'r') as f:
                    # Read a csv table from file
                    reader = csv.reader(f)
                    ip = file.split('_')[0]
                    last_row = None
                    for row in reader:
                        last_row = row
                    try:
                        traffic.append((ip, float(last_row[2])))
                    except:
                        warnings.warn(f'Error parsing line: {last_row}')
        traffic = sorted(traffic, key=lambda x: x[0])
        # Print all output traffic except the last one, as the last one don't have output traffic
        print(f'Average image pulling latency of {"draid" if "balance" in output_dir else "baseline"}: {np.mean(latencies)}')
        print("Traffic (MB):")
        print("| " + " | ".join(f"{str(item[0]):<20}" for item in traffic[:-1]) + " |")
        print("| " + " | ".join(f"{str(item[1]/1e6):<20}" for item in traffic[:-1]) + " |")

if __name__ == "__main__":
    main()
