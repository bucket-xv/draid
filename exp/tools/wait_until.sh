#!/bin/bash

pattern1="pgs"
pattern2="active+clean"

# Wait until the final line of the output contains both patterns
while true; do
  # Run 'sudo ceph -s' and capture the last line of the output
  final_line=$(sudo ceph -s | tail -n 2)

  # Check if both patterns are in the final line
  if echo "$final_line" | grep -q "$pattern1" && echo "$final_line" | grep -q "$pattern2"; then
    echo "The final line contains both '$pattern1' and '$pattern2'."
    break
  else
    echo "Waiting for the final line to contain both '$pattern1' and '$pattern2'..."
    sleep 5  # Wait for 5 seconds before trying again
  fi
done