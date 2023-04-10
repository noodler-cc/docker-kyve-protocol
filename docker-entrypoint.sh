#!/bin/bash

# Function to check if storage_priv.json exists
check_storage_priv() {
        if [ ! -f "/noodle/storage_priv.json" ]; then
                print_message "storage_priv.json does not exist" "ERROR"
                exit 1
        fi
}

# Function to print messages
print_message() {
        local message="$1"
        local type="$2"
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        case "$type" in
                "WARNING")
                echo -e "\e[33m${timestamp} - ${type} - ${message}\e[0m"
                ;;

                "ERROR")
                echo -e "\e[31m${timestamp} - ${type} - ${message}\e[0m"
                ;;

                *)
                echo "${timestamp} - INFO - ${message}"
                ;;
        esac
}

# Function to set network variables
set_network_variables() {
        case "$NETWORK" in
                "Mainnet")
                VAR_CHAIN_ID="kyve-1"
                VAR_RPC="https://rpc-eu-1.kyve.network"
                VAR_REST="https://api-eu-1.kyve.network"
                ;;

                "Kaon")
                VAR_CHAIN_ID="kaon-1"
                VAR_RPC="https://rpc-eu-1.kaon.kyve.network"
                VAR_REST="https://api-eu-1.kaon.kyve.network"
                ;;

                "Korellia")
                VAR_CHAIN_ID="korellia"
                VAR_RPC="https://rpc-eu-1.korellia.kyve.network"
                VAR_REST="https://api-eu-1.korellia.kyve.network"
                ;;

                *)
                print_message "Network is not defined" "ERROR"
                exit 1
                ;;
        esac
}

# Function to get pool information
get_pool_info() {
        status_code=$(wget --server-response -qO- ${VAR_REST}/kyve/query/v1beta1/pool/${POOL_ID} 2>&1 | grep "HTTP/" | awk '{print $2}')
        if [ "$status_code" -ne 200 ]; then
                print_message "The network or pool does not exist, check these variables" "ERROR"
                exit 1
        fi
        json_data=$(wget -qO- ${VAR_REST}/kyve/query/v1beta1/pool/${POOL_ID})
        VAR_VERSION=$(echo $json_data | jq -r '.pool.data.protocol.version')
        VAR_LINK_GITHUB=$(echo $json_data | jq -r '.pool.data.protocol.binaries | fromjson | .["kyve-linux-x64"]')
        VAR_RUNTIME=$(echo $json_data | jq -r '.pool.data.runtime')

        print_message "Pool ID: $POOL_ID"
        print_message "Runtime: $VAR_RUNTIME"
        print_message "-- Version: $VAR_VERSION"
        print_message "Network: $NETWORK"
        print_message "-- RPC: $VAR_RPC"
        print_message "-- API REST: $VAR_REST"
}

get_last_binary() {
        print_message "Get binary..."
        if [ ! -z "$BIN_VERSION" ]; then
                VAR_VERSION=$BIN_VERSION
                VAR_LINK_GITHUB="https://github.com/KYVENetwork/kyvejs/releases/download/${VAR_RUNTIME}@${BIN_VERSION}/kyve-linux-x64.zip"
        fi
        # Check if binary for requested version already exists
        if [ -f "/noodle/.kysor/upgrades/pool-$POOL_ID/$VAR_VERSION/bin/kyve-linux-x64" ]; then
                print_message "Using existing binary for version $VAR_VERSION"
        else
                # Download binary from API
                nohup mkdir -p /noodle/.kysor/upgrades/pool-$POOL_ID/$VAR_VERSION/bin > /dev/null 2>&1
                nohup wget -P /noodle/.kysor/upgrades/pool-$POOL_ID/$VAR_VERSION/bin $VAR_LINK_GITHUB > /dev/null 2>&1
                nohup unzip /noodle/.kysor/upgrades/pool-$POOL_ID/$VAR_VERSION/bin/kyve-linux-x64.zip -d /noodle/.kysor/upgrades/pool-$POOL_ID/$VAR_VERSION/bin > /dev/null 2>&1
                nohup rm /noodle/.kysor/upgrades/pool-$POOL_ID/$VAR_VERSION/bin/kyve-linux-x64.zip > /dev/null 2>&1
        fi
}

# Function to initialize kysor
init_kysor() {
        if [ ! -f "/noodle/.kysor/config.toml" ]; then
                print_message "Initializing kysor..."
                nohup /noodle/kysor init \
                --chain-id $VAR_CHAIN_ID \
                --rpc $VAR_RPC \
                --rest $VAR_REST > /dev/null 2>&1
        fi
}

# Function to create a validator account
create_validator_account() {
        if [ ! -f "/noodle/.kysor/valaccounts/node.toml" ]; then
                if [[ ! -z $MNEMONIC ]]; then
                        print_message "Creating validator account with mnemonic..."
                        nohup /noodle/kysor valaccounts create \
                                --name 'node' \
                                --pool $POOL_ID \
                                --storage-priv "$(cat /noodle/storage_priv.json)" \
                                --metrics \
                                --recover > /dev/null 2>&1 <<EOF
$MNEMONIC
EOF
                        else
                        print_message "Creating validator account without mnemonic..." "WARNING"
                        print_message "Please save your configuration file /noodle/.kysor/valaccounts/node.toml" "WARNING"
                        nohup /noodle/kysor valaccounts create \
                                --name 'node' \
                                --pool $POOL_ID \
                                --storage-priv "$(cat /noodle/storage_priv.json)" \
                                --metrics > /dev/null 2>&1
                        PUBLIC_ADDRESS=$(/noodle/kysor valaccounts show-address --name node)
                        print_message "Please save your configuration file /noodle/.kysor/valaccounts/node.toml"
                fi
        fi
}

# Function to start the validator
start_validator() {
        /noodle/kysor start --valaccount 'node'
}

# Call functions
check_storage_priv
set_network_variables
get_pool_info
get_last_binary
init_kysor
create_validator_account
start_validator
