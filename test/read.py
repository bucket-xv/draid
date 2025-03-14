import argparse
import os
from utils import get_urls,get_id_and_key
import time
import threading
import boto3
import random

def read(seed,bucket_name, file_num):
    rng = random.Random(seed)
    config_dir = '../configs'
    url_path = os.path.join(config_dir, 'rgw.txt')
    urls = get_urls(url_path)
    url = urls[seed % len(urls)]
    json_path = os.path.join(config_dir, 'user.json')
    access_key, secret_key = get_id_and_key(json_path)
    s3 = boto3.client('s3', endpoint_url=url,
            aws_access_key_id = access_key,
            aws_secret_access_key = secret_key)

    sleep_time = 0.1
    time.sleep(sleep_time)

    obj_list = list(range(file_num))
    rng.shuffle(obj_list)
    start = time.time()
    for i in obj_list:
        idx = file_num * seed + i
        object_name = 'object' + str(i)
        response = s3.get_object(Bucket=bucket_name,Key=object_name)
    end = time.time()
    print(end-start)

def main():
    parser = argparse.ArgumentParser(description='Read from a s3 bucket.')

    # Add the required positional argument
    parser.add_argument('num_files', type=int, help='the number of files to read from the bucket')
    parser.add_argument('file_size', type=int, help='the size of the file to read from the bucket')
    parser.add_argument('num_threads', type=int, help='the number of threads')
    parser.add_argument('seed', type=int, help='the seed for the random number generator')

    # Parse the arguments
    args = parser.parse_args()

    # Get s3 client object
    bucket_name = 'bucket'

    # Put some objects in it and record the time
    threads = []
    for i in range(args.num_threads):
        t = threading.Thread(target=read, args=(args.seed+i,bucket_name,args.num_files))
        t.start()
        threads.append(t)
    
    for t in threads:
        t.join()


if __name__ == '__main__':
    main()