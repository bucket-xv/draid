import json
import os
import warnings
import time

def main():
    ip_file_path = os.path.join(os.path.dirname(__file__), '..', '..', 'configs', 'int_ip_addrs_server.txt')
    with open(ip_file_path, 'r') as f:
        ip_addrs = f.readlines()
    ip_addrs = [ip.strip() for ip in ip_addrs]

    docker_config_path = '/etc/docker/daemon.json'
    if os.path.exists(docker_config_path):
        with open(docker_config_path, 'r') as f:
            docker_config = json.load(f)
    else:
        warnings.warn(f'{docker_config_path} does not exist')
        docker_config = {}

    docker_config['insecure-registries'] = [f'master:5000']
    for ip in ip_addrs:
        docker_config['insecure-registries'].append(f'{ip}:5000')
        docker_config['insecure-registries'].append(f'{ip}:5005')
    os.makedirs(os.path.dirname(docker_config_path), exist_ok=True)
    with open(docker_config_path, 'w') as f:
        json.dump(docker_config, f)

    print(f'{docker_config_path} updated AS:')
    print(docker_config)

    time.sleep(1)
    print('Restarting docker service')
    os.system('sudo systemctl restart docker')

if __name__ == '__main__':
    main()