#!/bin/bash

# Display available network interfaces
echo "Available network interfaces:"
interfaces=$(ifconfig -a | sed 's/[ \t].*//;/^$/d')
echo "$interfaces"

# Ask the user for the network interface
while true; do
    read -p "Enter the network interface you want to modify (e.g., eth0, wlan0): " interface
    # Validate the selected interface
    if echo "$interfaces" | grep -qw "$interface"; then
        break
    else
        echo "Invalid interface. Please try again."
    fi
done

# Disable the selected network interface
ifconfig "$interface" down

# Ask the user whether they want to assign a specific MAC address
while true; do
    read -p "Do you want to assign a specific MAC address? (yes/y or no/n): " response
    if [[ "$response" =~ ^(yes|y)$ ]]; then
        # Ask for the new MAC address
        while true; do
            read -p "Enter the new MAC address (e.g., 00:11:22:33:44:55): " mac_address
            # Validate the MAC address format
            if [[ "$mac_address" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
                macchanger -m "$mac_address" "$interface"
                break
            else
                echo "Invalid MAC address format. Please try again."
            fi
        done
        break
    elif [[ "$response" =~ ^(no|n)$ ]]; then
        # Change MAC address to a random one
        macchanger -a "$interface"
        break
    else
        echo "Invalid response. Please answer with yes/y or no/n."
    fi
done

# Enable the network interface
ifconfig "$interface" up

# Restart the network manager service
if command -v service &> /dev/null; then
    systemctl restart NetworkManager
else
    service network-manager restart
fi

echo "MAC address changed successfully for $interface!"