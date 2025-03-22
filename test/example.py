import boto3
import os
import json
import argparse

key_file = os.path.expanduser('~/draid/configs/user.json')
ip_file = os.path.expanduser('~/draid/configs/int_ip_addrs_cli.txt')

def conn():
    with open(key_file, 'r') as f:
        key = json.load(f)
    with open(ip_file, 'r') as f:
        ip = f.read().strip()
    s3 = boto3.client('s3', endpoint_url=f'http://{ip}:8000',
            aws_access_key_id = key['access_key'],
            aws_secret_access_key = key['secret_key'])
    return s3

def create_bucket(bucket_name):
    s3 = conn()
    s3.create_bucket(Bucket=bucket_name)

def put_object(bucket_name, object_name, object_body):
    s3 = conn()
    s3.put_object(Bucket=bucket_name, Key=object_name, Body=object_body)

def get_object(bucket_name, object_name):
    s3 = conn()
    s3.get_object(Bucket=bucket_name, Key=object_name)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action', type=str, help='action to perform', choices=['create', 'put', 'get'], required=True)
    parser.add_argument('--bucketname', type=str, help='bucket name', default='test-bucket')
    parser.add_argument('--objectname', type=str, help='object name', default='test-object')
    parser.add_argument('--objectbody', type=str, help='object body', default='test-object-content')
    args = parser.parse_args()

    if args.action == 'create':
        create_bucket(args.bucketname)
    elif args.action == 'put':
        put_object(args.bucketname, args.objectname, args.objectbody)
    elif args.action == 'get':
        get_object(args.bucketname, args.objectname)

if __name__ == '__main__':
    main()