#!/bin/bash
echo "Daftar interface jaringan aktif dan IP-nya:"
for iface in /sys/class/net/*; do
    name=$(basename "$iface")
    if [[ "$name" != "lo" ]]; then
        state=$(cat "$iface/operstate")
        if [[ "$state" == "up" ]]; then
            ip4=$(ip -4 addr show "$name" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "No IPv4")
            echo "$name - Status: $state - IP: $ip4"
        fi
    fi
done
