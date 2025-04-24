sudo nmcli connection add type macvlan \
  con-name macvlan0 \
  ifname macvlan0 \
  dev eth1 \
  mode bridge \
  ipv4.method auto 
