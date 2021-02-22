#!/bin/bash

# copy hermes config
mkdir -p $HOME/.hermes
cp ibc/config.toml ~/.hermes/config.toml

# build 
cd ibc-rs

echo "Building the Rust relayer..."
cargo build &> /dev/null

# cleanup the client entries from config
echo "Removing light client peers from configuration..."
cargo run --bin hermes -- -c ~/.hermes/config.toml light rm -c stargate --all -y &> /dev/null || true
cargo run --bin hermes -- -c ~/.hermes/config.toml light rm -c heliax --all -y &> /dev/null || true

# set the primary peers for clients on each chain
echo "Adding primary peers to light client configuration..."
cargo run --bin hermes -- -c ~/.hermes/config.toml light add "localhost:26657" -c "stargate" -f -p -s "/home/ec2-user/node-stargate/data" -y
cargo run --bin hermes -- -c ~/.hermes/config.toml light add "localhost:26357" -c "heliax" -f -p -s "/home/ec2-user/node-heliax/data" -y 

# set the secondary peers for clients on each chain
echo "Adding secondary peers to light client configuration..."
cargo run --bin hermes -- -c ~/.hermes/config.toml light add "localhost:26657" -c "stargate" -s "/home/ec2-user/node-stargate/data" -y --peer-id 2427F8D914A6862279B3326FA64F76E3BC06DB2E 
cargo run --bin hermes -- -c ~/.hermes/config.toml light add "localhost:26357" -c "heliax" -s "/home/ec2-user/node-heliax/data" -y --peer-id A885BB3D3DFF6101188B462466AE926E7A6CD51E

# add the key seeds to the keyring of each chain
echo "Importing keys..."
cargo run --bin hermes -- -c ~/.hermes/config.toml keys add "stargate" "/home/ec2-user/node-stargate/key_seed.json" 
cargo run --bin hermes -- -c ~/.hermes/config.toml keys add "heliax" "/home/ec2-user/node-heliax/key_seed.json"

echo "Done!"
