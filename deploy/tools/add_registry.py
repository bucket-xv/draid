import json
import os
import warnings

# #!/bin/bash

# registry=$(tail -n 1 ~/draid/deploy/int_ip_addrs_server.txt)

# content="{
#   \"insecure-registries\" : [\"$registry:5000\"]
# }"

# sudo mkdir -p /etc/docker
# # sudo touch /etc/docker/daemon.json
# echo "$content" | sudo tee /etc/docker/daemon.json > /dev/null

# sleep 1
# sudo systemctl restart docker

def main():
    ip_file_path = os.path.join(os.path.dirname(__file__), '..', '..', 'configs', 'ip_addrs_all.txt')
    with open(ip_file_path, 'r') as f:
        ip_addrs = f.readlines()
    ip_addrs = [ip.strip() for ip in ip_addrs]
    print(ip_addrs)

    docker_config_path = '/etc/docker/daemon.json'
    if os.path.exists(docker_config_path):
        with open(docker_config_path, 'r') as f:
            docker_config = json.load(f)
    else:
        warnings.warn(f'{docker_config_path} does not exist')
        docker_config = {}

    docker_config['insecure-registries'] = []
    for ip in ip_addrs:
        docker_config['insecure-registries'].append(f'{ip}:5000')
    os.makedirs(os.path.dirname(docker_config_path), exist_ok=True)
    with open(docker_config_path, 'w') as f:
        json.dump(docker_config, f)

    print(f'{docker_config_path} updated')
    print(docker_config)

if __name__ == '__main__':
    main()