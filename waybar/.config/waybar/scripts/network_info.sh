#!/usr/bin/env bash

# Wi-Fi SSID
SSID=$(iwgetid -r || echo "N/A")

# Signal strength %
SIGNAL=$(grep "$SSID" /proc/net/wireless 2>/dev/null | awk '{print int($3*100/70)}')
SIGNAL=${SIGNAL:-N/A}

# Default interface
IFACE=$(ip route | awk '/default/ {print $5}')

# LAN IP
LAN=$(ip -4 addr show dev "$IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "N/A")

# WAN IP
WAN=$(curl -s ifconfig.me || echo "N/A")

# Download / Upload KB
RX=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null)
TX=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null)
RX=$((RX/1024))
TX=$((TX/1024))

# VPN status
if ip a | grep -q tun0; then VPN="active"; else VPN="inactive"; fi

# Output nicely
echo "Wi-Fi: $SSID"
echo "Signal: $SIGNAL%"
echo "LAN IP: $LAN"
echo "WAN IP: $WAN"
echo "Download: ${RX} KB"
echo "Upload: ${TX} KB"
echo "VPN: $VPN"