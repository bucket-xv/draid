import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file into a pandas DataFrame
df = pd.read_csv('traffic_log.csv')

# Convert the Timestamp column to datetime
df['Timestamp'] = pd.to_datetime(df['Timestamp'], unit='s')

# Set the Timestamp column as the index
df.set_index('Timestamp', inplace=True)

# Plot the data
plt.figure(figsize=(14, 7))
plt.plot(df.index, df['RX_Bytes'], label='Received Bytes')
plt.plot(df.index, df['TX_Bytes'], label='Transmitted Bytes')
plt.xlabel('Time')
plt.ylabel('Bytes')
plt.title('Network Traffic Over Time')
plt.legend()
plt.grid(True)
plt.show()
