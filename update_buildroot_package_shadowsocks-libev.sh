curl -s https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest \
  | grep browser_download_url \
  | grep tar.gz \
  | cut -d '"' -f 4 \
  | wget -qi -
