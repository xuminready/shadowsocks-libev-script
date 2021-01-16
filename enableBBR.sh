#!/bin/bash

echo 'orginal source: https://www.flyzy2005.com/fan-qiang/shadowsocks/ubuntu-bbr-shadowsocks/'

echo "use /usr/lib/sysctl.d/*.conf if /etc/sysctl.conf doesn't exist"
echo 'https://wiki.archlinux.org/index.php/sysctl'

sudo bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
sudo bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'

sudo sysctl -p

sysctl net.ipv4.tcp_available_congestion_control

lsmod | grep bbr
