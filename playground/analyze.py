import os
import glob
import sys

def calculate_average(directory):
    total_sum = 0
    total_count = 0

    # Get all files in the directory
    files = glob.glob(os.path.join(directory, '*'))

    for file_path in files:
        with open(file_path, 'r') as file:
            for line in file:
                try:
                    # Convert the line to a float and add it to the total sum
                    number = float(line.strip())
                    total_sum += number
                    total_count += 1
                except ValueError:
                    pass
                    # If the line is not a number, ignore it
                    # print(f"Warning: Line '{line.strip()}' is not a valid number and will be ignored.")
    
    # Calculate the average
    if total_count > 0:
        print(f'Numbers total counted: {total_count}')
        average = total_sum / total_count
        return average
    else:
        return None

# Replace 'your_directory_path' with the path to the directory containing your files
if len(sys.argv) != 2:
    print("Usage: python script.py <argument>")
    sys.exit(1)

directory_path = str(sys.argv[1])
average = calculate_average(directory_path)

if average is not None:
    print(f"The average of all numbers in the files is: {average}")
else:
    print("No valid numbers found in the files.")
