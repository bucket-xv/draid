import json
import os
import matplotlib.pyplot as plt

json_path = '/home/xvchenhao/draid/save_logs/logs.json'
output_base_dir = 'images/'
def main():
    with open(json_path, 'r') as f:
        data = json.load(f)
    data_x = {}
    data_tx = {}
    data_rx = {}
    for setting,x_data in data.items():
        for file_num,value in x_data.items():
            if setting not in data_tx:
                data_x[setting] = []
                data_tx[setting] = []
                data_rx[setting] = []
            data_x[setting].append(int(file_num))
            txs = value['real']['tx']
            rxs = value['real']['rx']
            data_tx[setting].append(max(txs)/min(txs))
            data_rx[setting].append(max(rxs)/min(rxs))

    for key,value in data_tx.items():
        plt.plot(data_x[key], value, label=key)
    plt.legend()
    plt.xlabel('Number of Files')
    plt.ylabel('Inbalance')
    plt.title('Inbalance in different Settings')
    plt.savefig(os.path.join(output_base_dir,'inbalance_tx.png'))
    plt.close()

    for key,value in data_rx.items():
        plt.plot(data_x[key], value, label=key)
    plt.legend()
    plt.xlabel('Number of Files')
    plt.ylabel('Inbalance')
    plt.title('Inbalance in different Settings')
    plt.savefig(os.path.join(output_base_dir,'inbalance_rx.png'))
    plt.close()

if __name__ == '__main__':
    main()