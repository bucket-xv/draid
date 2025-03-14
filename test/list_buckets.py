import os
from utils import get_client

def main():
    config_dir = '../configs'
    url_path = os.path.join(config_dir, 'rgw.txt')
    json_path = os.path.join(config_dir, 'user.json')
    s3 = get_client(url_path, json_path)
    response = s3.list_buckets()
    print(response)


if __name__ == '__main__':
    main()