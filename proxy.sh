#!/bin/bash
# Fixed L2TP/IPsec + SOCKS5 One-Click Installer
# Tested on Ubuntu 20.04/22.04 & Debian 10/11

# Config
IPSEC_PSK="$(openssl rand -base64 24)"
VPN_USER="vpnuser"
VPN_PASS="$(openssl rand -base64 12)"
SOCKS_PORT=1080
LOCAL_IP="10.8.0.1"
POOL_START="10.8.0.2"
POOL_END="10.8.0.10"
PUBLIC_IP=$(curl -4 ifconfig.me)

# Install Dependencies
apt-get update
apt-get install -y strongswan xl2tpd ppp net-tools socat iptables-persistent

# Stop services if running
systemctl stop strongswan ipsec xl2tpd 2>/dev/null

# IPsec Configuration
cat > /etc/ipsec.conf <<EOF
config setup
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16
    uniqueids=no

conn l2tp-psk
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=%any
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF

# Set PSK
echo "%any %any : PSK \"$IPSEC_PSK\"" > /etc/ipsec.secrets

# L2TP Configuration
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
ipsec saref = yes
listen-addr = 0.0.0.0

[lns default]
ip range = $POOL_START-$POOL_END
local ip = $LOCAL_IP
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

# PPP Options
cat > /etc/ppp/options.xl2tpd <<EOF
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
noauth
mtu 1280
mru 1280
nodefaultroute
EOF

# Create VPN User
echo "$VPN_USER l2tpd $VPN_PASS *" > /etc/ppp/chap-secrets

# Enable IP Forwarding
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# Configure Firewall
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i ppp+ -j ACCEPT
iptables -A FORWARD -o ppp+ -j ACCEPT
iptables -A INPUT -p udp --dport 1701 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p tcp --dport $SOCKS_PORT -j ACCEPT

# Save iptables rules
netfilter-persistent save

# Start Services - FIXED SERVICE NAME
systemctl start ipsec xl2tpd
systemctl enable ipsec xl2tpd

# SOCKS5 Forwarding
cat > /etc/systemd/system/socks5-proxy.service <<EOF
[Unit]
Description=SOCKS5 Proxy Server
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:$SOCKS_PORT,fork,reuseaddr TCP:$POOL_START:$SOCKS_PORT
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now socks5-proxy.service

# Enable UFW
ufw allow 1701/udp
ufw allow 4500/udp
ufw allow 500/udp
ufw allow $SOCKS_PORT/tcp
ufw --force enable

# Display Info
clear
echo "============================================"
echo " L2TP/IPsec + SOCKS5 Proxy Setup Complete"
echo "============================================"
echo "Public IP: $PUBLIC_IP"
echo "IPsec PSK: $IPSEC_PSK"
echo "VPN Credentials:"
echo "Username: $VPN_USER"
echo "Password: $VPN_PASS"
echo "SOCKS5 Proxy: $PUBLIC_IP:$SOCKS_PORT"
echo "============================================"
echo "Untuk MikroTik Client:"
echo "/interface l2tp-client add \\"
echo "  name=l2tp-vps \\"
echo "  user=$VPN_USER \\"
echo "  password=$VPN_PASS \\"
echo "  connect-to=$PUBLIC_IP \\"
echo "  ipsec-secret=\"$IPSEC_PSK\" \\"
echo "  disabled=no"
echo "============================================"
