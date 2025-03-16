import subprocess
import argparse
import os

def push_image(image_name: str, file_size: int):
    project_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    # Create a temporary directory for the Dockerfile and large file
    temp_dir = f"/tmp/tmp_file"
    os.makedirs(temp_dir, exist_ok=True)

    # Create a large file of `file_size`
    large_file_path = os.path.join(temp_dir, 'large_file')
    with open(large_file_path, 'wb') as f:
        f.write(os.urandom(file_size))

    # Get the registry ip address
    with open(os.path.join(project_dir, 'configs', 'int_ip_addrs_server.txt'), 'r') as f:
        registry_ip = f.readlines()[0].strip()

    # Create a Dockerfile in the temporary directory
    dockerfile_path = os.path.join(temp_dir, 'Dockerfile')
    with open(dockerfile_path, 'w') as f:
        f.write(f"FROM {registry_ip}:5000/alpine\nCOPY large_file /\n")

    # Build the Docker image, push it to the registry and remove the image
    command=f"sudo docker build {temp_dir} -t {image_name} && sudo docker push {image_name}; sudo docker rmi {image_name}"
    return subprocess.run(command, shell=True, text=True)

def pull_image(image_name: str):
    command=f"sudo docker pull {image_name}"
    result = subprocess.run(command, capture_output=True, shell=True, text=True)
    return result

def remove_image(image_name: str): 
    command=f"sudo docker rmi {image_name}"
    result = subprocess.run(command, capture_output=True, shell=True, text=True)
    return result

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n','--num',default=5, type=int, help='the number of images to create and push to private registry')
    parser.add_argument('-s','--size',default=1024 * 1024 * 1024, type=int, help='size of each image')
    parser.add_argument('action', type=str, choices=['push','pull'], help='the action to perform')
    parser.add_argument('addr',type=str, help='the docker registry to push to')

    args = parser.parse_args()
    if args.action == 'push':
        for i in range(args.num):
            push_image(f"{args.addr}/img{i}", file_size=args.size)
    else:
        pull_image(args.addr)
    
if __name__ == '__main__':
    main()