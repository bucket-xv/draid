import boto3
import yaml
import os

project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
registry_config_path = os.path.join(project_dir, 'configs', 'registry.yml')

def create_bucket():
    with open(registry_config_path, 'r') as file:
        config = yaml.safe_load(file)
        s3_config = config['storage']['s3']
    # Create a bucket
    bucket_name = s3_config['bucket']
    url = s3_config['regionendpoint']
    access_key = s3_config['accesskey']
    secret_key = s3_config['secretkey']
    s3 = boto3.client('s3', endpoint_url=url,
            aws_access_key_id = access_key,
            aws_secret_access_key = secret_key)
    response = s3.create_bucket(Bucket=bucket_name)
    print(response)

if __name__ == '__main__':
    create_bucket()