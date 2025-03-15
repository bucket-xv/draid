import yaml
import os
import json

# bucket name
bucket = 'registry'

if __name__ == '__main__':

    # Path to files
    project_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    configs_dir = os.path.join(project_dir, 'configs')
    ip_path = os.path.join(configs_dir, 'int_ip_addrs_server.txt')
    rgw_path = os.path.join(configs_dir, 'rgw.txt')
    user_path = os.path.join(configs_dir, 'user.json')
    template_path = os.path.join(project_dir, 'deploy', 'tools', 'template.yml')
    output_path = os.path.join(configs_dir, 'registry.yml')

    # First, get the urls of the rgw daemons
    with open(ip_path, 'r') as f:
        ips = f.readlines()
    with open(rgw_path, 'r') as f:
        daemons = f.read()
    lines = daemons.split('\n')
    lines = lines[1:]
    urls = []
    for line in lines:
        if line == "":
            break
        words = line.split()
        host = words[1]
        ip = ips[-1]
        port = words[2].split(':')[1]
        url = 'http://' + ip + ':' + port
        urls.append(url)
    
    # Then get the access key and secret key
    with open(user_path, 'r') as f:
        user_info = json.load(f)

    keys = user_info['keys']
    for key in keys:
        if key['user'] == 'chenhao':
            access_key = key['access_key']
            secret_key = key['secret_key']
            break

    # Read the template config
    with open(template_path, 'r') as file:
        config = yaml.safe_load(file)

    # Modify the 's3' setting
    config['storage']['s3'] = {
        'regionendpoint': urls[0],
        'accesskey': access_key,
        'secretkey': secret_key,
        'region': 'someregion',
        'bucket': bucket
    }

    # Write the updated config back to the file
    with open(output_path, 'w') as file:
        yaml.dump(config, file, default_flow_style=False)
