import os
import sys

# Check if the correct number of arguments is provided
if len(sys.argv) != 3:
    print("Usage: python script.py <num_files> <file_size in Mbs>")
    sys.exit(1)

# Check if the arguments are integers
try:
    num_files = int(sys.argv[1])
    file_size = int(sys.argv[2])
except ValueError:
    print("Both arguments must be integers.")
    sys.exit(1)

# Define the number of random numbers you want to generate

num_bytes = file_size * 1024 * 1024 
output_dir = '../data'

os.makedirs(output_dir, exist_ok=True)

for i in range(num_files):
    filename = os.path.join(output_dir, f'{i}.txt')

    # Open the file in write mode
    with open(filename, 'wb') as file:
        # Generate and write random numbers to the file
        file.write(os.urandom(num_bytes))

print(f"Random bytes have been written to {num_files} files.")
