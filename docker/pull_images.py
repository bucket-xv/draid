import argparse
import threading
import time
import random
import os
import sys
from tools.image import pull_image, remove_image

project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def read(id, registry, file_num):
    # Wait for 0.1 seconds to avoid blocking the traffic
    time.sleep(0.1)

    obj_list = list(range(file_num))
    rng = random.Random(id)
    rng.shuffle(obj_list)
    start = time.time()
    for i in obj_list:
        image_idx = file_num * id + i
        image_name = f'{registry}:5000/draid-img{image_idx}'
        result = pull_image(image_name)
        print(result.stdout,file=sys.stderr)
    end = time.time()
    print(end-start)

def remove(id, registry, file_num):
    obj_list = list(range(file_num))
    for i in obj_list:
        image_idx = file_num * id + i
        image_name = f'{registry}:5000/draid-img{image_idx}'
        remove_image(image_name)

def main():
    parser = argparse.ArgumentParser(description='Read from a s3 bucket.')

    # Add the required positional argument
    parser.add_argument('num_files', type=int, help='the number of files to read for one thread')
    parser.add_argument('num_threads', type=int, help='the number of threads')
    parser.add_argument('id', type=int, help='the global thread id for the first thread')

    # Parse the arguments
    args = parser.parse_args()

    # Get registry
    with open(os.path.join(project_dir, 'configs', 'int_ip_addrs_server.txt'), 'r') as file:
        lines = file.readlines()
    registry = lines[-1].strip()

    # Pull images from registry and record the time
    threads = []
    for i in range(args.num_threads):
        t = threading.Thread(target=read, args=(args.id+i,registry,args.num_files))
        t.start()
        threads.append(t)
    
    for t in threads:
        t.join()

    # Remove images from registry in case of running out of space
    for i in range(args.num_threads):
        remove(args.id+i,registry,args.num_files)

if __name__ == '__main__':
    main()