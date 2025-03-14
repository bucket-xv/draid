import json
import boto3

def get_urls(config_path):
    with open(config_path, 'r') as f:
        daemons = f.read()
    lines = daemons.split('\n')
    lines = lines[1:]
    urls = []
    for line in lines:
        if line == "":
            break
        words = line.split()
        host = words[1]
        id = int(host.split('.')[0][4:]) + 1
        ip = '10.10.1.' + str(id)
        port = words[2].split(':')[1]
        url = 'http://' + ip + ':' + port
        urls.append(url)
    return urls

def get_id_and_key(json_path):
    with open(json_path, 'r') as f:
        user_info = json.load(f)

    # "keys": [
    #     {
    #         "user": "chenhao",
    #         "access_key": "7CBQQPIAV7ZL8K2JBUPU",
    #         "secret_key": "ASsfkeJkBW9hbRGLsJstiakZsg1DVu9bAYjd5yte",
    #         "active": true,
    #         "create_date": "2024-12-31T03:05:34.197796Z"
    #     }
    # ]
    keys = user_info['keys']
    for key in keys:
        if key['user'] == 'chenhao':
            access_key = key['access_key']
            secret_key = key['secret_key']
            break
    return access_key, secret_key

def get_client(url_path,json_path):
    url = get_urls(url_path)[0]
    access_key, secret_key = get_id_and_key(json_path)
    print(access_key)
    s3 = boto3.client('s3', endpoint_url=url,
            aws_access_key_id = access_key,
            aws_secret_access_key = secret_key)
    return s3

def main():
    url_path = '../configs/rgw.txt'
    json_path = '../configs/user.json'
    # print(get_urls(url_path))
    # print(get_id_and_key(json_path))

if __name__ == '__main__':
    main()