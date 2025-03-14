def dict_to_str(config):
    return str(config['num_cores']) + 'c_dev=' + str(config['std_deviation']) + '_seq=' + str(config['seq_num'])+'_'  + str(config['num_files']) + 'files_' + str(config['file_size']) + 'mB_'  + ('_balance' if config['read_balance'] else '')

def str_to_dict(str):
    config = {}
    str = str.split('_')
    config['num_cores'] = str[0].replace('c','')
    config['std_deviation'] = str[1].replace('dev=','')
    config['seq_num'] = str[2].replace('seq=','')
    config['num_files'] = str[3].replace('files','')
    config['file_size'] = str[4].replace('mB','')
    config['read_balance'] = 1 if 'balance' in str else 0
    return config