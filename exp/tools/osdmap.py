import subprocess

def osd_node_mapping():
    command = ['sudo', 'ceph', 'osd', 'tree']
    # Execute the command
    result = subprocess.run(command, capture_output=True, text=True, check=True)

    input_data = result.stdout.split('\n')  
    # Dictionary to hold the mapping of host to OSDs
    node_to_osd_mapping = {}
    osd_to_node_mapping = {}

    # Variable to keep track of the current host
    current_host = None

    # Parse the input data
    for line in input_data:
        # Split the line into columns
        columns = line.split()
        
        # Check if the line contains a host entry
        if len(columns) > 3 and columns[2] == 'host':
            current_host = int(columns[3][4:])
            node_to_osd_mapping[current_host] = []
        
        # Check if the line contains an OSD entry
        if len(columns) > 3 and columns[3].startswith('osd'):
            osd_name = int(columns[3].split('.')[1])
            # Append the OSD to the current host's list
            if current_host is not None:
                node_to_osd_mapping[current_host].append(osd_name)
                osd_to_node_mapping[osd_name] = current_host

    return node_to_osd_mapping, osd_to_node_mapping

def main():
    print(osd_node_mapping())

if __name__ == "__main__":
    main()