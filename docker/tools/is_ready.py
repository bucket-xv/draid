import subprocess
import time

def is_ready():
    result = subprocess.run(["sudo", "ceph", "-s"], check=True, capture_output=True)
    lines = result.stdout.decode().split('\n')
    # print(lines)
    for i in range(len(lines)):
        if 'active+clean' in lines[i]:
            return lines[i+1] == ' '
    return False

if __name__ == '__main__':
    while(not is_ready()):
        print("Waiting for Ceph to be ready...")
        time.sleep(3)
    print("Ceph is ready!")