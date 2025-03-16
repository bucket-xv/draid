import sys

# Initialize a dictionary to hold the sum of bytes for each bucket
# Read each line from standard input (stdin)

def parse_pg(input, parity_chunk_num = 1):
    bucket_sums = {}
    bucket_second_sums = {}
    for line in input:
        # Remove leading and trailing whitespace
        words = line.split()
        
        try:
            sixth_number = float(words[5])
        except:
            # print('Bytes is not a number')
            continue
        
        state = words[10]
        if state != 'active+clean':
            print('Ahah, PG failure state:'+state)
        # Find all bracketed lists in the line
        osd_map = words[14]

        pair = osd_map.split('p')

        bracketed_list, primary = pair[0][1:-1], pair[1]
        
        # Split the list into individual bucket numbers
        buckets = list(map(int, bracketed_list.split(',')))

        primary = int(primary)

        data_chunk_num = len(buckets) - parity_chunk_num
        
        # Calculate the bytes for each bucket and add them to the respective sum
        for bucket in buckets[:data_chunk_num]:
            # Determine the multiplier based on the bucket's position
            first_multiplier = 1.0 if bucket == primary else 1.0/data_chunk_num
            second_multiplier = 1.0 if bucket == primary else 0
            
            # Add the calculated bytes to the bucket's sum
            bucket_sums[bucket] = bucket_sums.get(bucket, 0.0) + (sixth_number * first_multiplier)
            bucket_second_sums[bucket] = bucket_second_sums.get(bucket, 0.0) + (sixth_number * second_multiplier)

    # Print the sum of bytes for each bucket
    bucket_values = []
    bucket_second_values = []
    bucket_sums = sorted(bucket_sums.items())
    bucket_second_sums = sorted(bucket_second_sums.items())
    for _, sum_bytes in bucket_sums:
        bucket_values.append(sum_bytes)
    for _, sum_bytes in bucket_second_sums:
        bucket_second_values.append(sum_bytes)
    return {"tx":bucket_values,"rx":bucket_second_values}

if __name__ == "__main__":
    # Read each line from standard input (stdin)
    m = parse_pg(sys.stdin)

    # Print the sum of bytes for each bucket
    sci_tx =[format(num, 'e') for num in m["tx"]]
    sci_rx =[format(num, 'e') for num in m["rx"]]
    print("tx:",sci_tx,"\nrx:",sci_rx)