import xml.etree.ElementTree as ET
import os
import json
import sys


if __name__ == '__main__':
    tree = ET.parse(sys.argv[1])
    num_servers = int(sys.argv[2])
    all_file = open('ip_addrs_all.txt', "w")
    cli_file = open('int_ip_addrs_cli.txt', "w")
    server_file2 = open('int_ip_addrs_server.txt', "w")
    
    root = tree.getroot()
    ipv4_addrs = []
    int_addrs = []
    for child in root.iter():
        if child.tag.endswith('host'):
            ipv4_addrs.append(child.get('ipv4'))
        if child.tag.endswith('interface'):
            for ip in child.iter():
                if ip.get('type') == 'ipv4':
                    int_addrs.append(ip.get('address'))
            
    print(ipv4_addrs)
    for server in ipv4_addrs:
        all_file.write(server + '\n')
    
    print(int_addrs[:num_servers])
    # host_file2.write(int_addrs[0] + '\n')
    for server in int_addrs[:num_servers]:
        server_file2.write(server + '\n')
    for client in int_addrs[num_servers:]:
        cli_file.write(client + '\n')

    # exp_file = open('../exp/ip_addrs_cli.txt', "w")
    # for client in ipv4_addrs[num_servers:]:
    #     exp_file.write(client + '\n')
