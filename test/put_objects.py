import argparse
import os
from utils import get_client, get_urls, get_id_and_key
import boto3
import threading

def write(url_path, json_path,bucket_name, file_folder,obj_list, thread_id):
    urls = get_urls(url_path)
    url = urls[thread_id % len(urls)]
    print('write to url:', url)
    access_key, secret_key = get_id_and_key(json_path)
    # print(access_key)
    s3 = boto3.client('s3', endpoint_url=url,
            aws_access_key_id = access_key,
            aws_secret_access_key = secret_key)
    for idx in obj_list:
        object_name = 'object' + str(idx)
        file_name = '0.txt'
        file_path = os.path.join(file_folder,file_name)
        with open(file_path, 'rb') as f:
            data = f.read()
        # print(data[:10])
        s3.put_object(Bucket=bucket_name,
                      Key=object_name,
                      Body=data)

def main():
    parser = argparse.ArgumentParser(description='Create a s3 bucket and put some objects in it.')

    # Add the required positional argument
    parser.add_argument('num_files', type=int, help='the number of files to put in the bucket')
    parser.add_argument('-n','--name', type=str,default='bucket', help='the name of the bucket')

    # Parse the arguments
    args = parser.parse_args()

    # Create a bucket
    bucket_name = args.name
    print(bucket_name)
    config_dir = '../configs'
    url_path = os.path.join(config_dir, 'rgw.txt')
    json_path = os.path.join(config_dir, 'user.json')
    s3 = get_client(url_path, json_path)
    # response = s3.list_buckets()
    # print(response)
    response = s3.create_bucket(Bucket=bucket_name)
    print(response)
    # response = s3.get_bucket_acl(Bucket=bucket_name )
    # print(response)

    # Put some objects in it 
    data_dir = '../data'
    num_threads = 10 
    obj_list = list(range(args.num_files))
    # Split the obj_list into num_threads parts
    obj_list = [obj_list[i::num_threads] for i in range(num_threads)]

    threads = []
    for i in range(num_threads):
        t = threading.Thread(target=write, args=(url_path, json_path,bucket_name, data_dir,obj_list[i],i))
        t.start()
        threads.append(t)
    
    for t in threads:
        t.join()

if __name__ == '__main__':
    main()