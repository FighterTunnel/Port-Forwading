:local socksPort 1080
:local vpnNet "10.8.0.0/24"
:local ispInterface "STARLINK"

# Reset SOCKS5
/ip socks set enabled=no
/ip socks set enabled=yes port=$socksPort

# Fix NAT
/ip firewall nat add chain=srcnat protocol=tcp dst-port=$socksPort action=masquerade
/ip firewall nat add chain=srcnat src-address=$vpnNet action=masquerade

# Fix DNS
/ip dns set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1

# Fix Firewall
/ip firewall filter add chain=forward src-address=$vpnNet action=accept place-before=0
/ip firewall filter add chain=forward out-interface=$ispInterface action=accept

# Restart
/interface l2tp-client disable [find]
delay 3
/interface l2tp-client enable [find]
