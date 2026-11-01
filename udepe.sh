#!/bin/bash
BIWhite='\033[1;97m'
BIYellow='\033[1;93m'
NC='\033[0m'
clear
function loading() {
  clear
  local pid=$1
  local delay=0.1
  local spin='-\|/'

  while ps -p $pid > /dev/null; do
    local temp=${spin#?}
    printf "[%c] " "$spin"
    local spin=$temp${spin%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done

  printf "    \b\b\b\b"
}

systemctl stop udp-custom &>/dev/null
systemctl disable udp-custom &>/dev/null
rm -rf /etc/systemd/system/udp-custom.service &>/dev/null
systemctl daemon-reload
cd
rm -rf /root/udp &>/dev/null
echo -e "${BIWhite}change to time GMT+7${NC}"
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

sleep 1
echo -e "${BIWhite}downloading udp-custom${NC}"
sleep 1
echo -e "${BIWhite}downloading default config${NC}"
wget -q https://raw.githubusercontent.com/Ris-Project/scriptpgetunnel/main/udp.zip
unzip udp.zip
clear
echo -e "${BIWhite}Loading....${NC}"
sleep 2
chmod +x /root/udp/udp-custom
sleep 2
chmod 644 /root/udp/config.json

if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom By Lite

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom By Lite

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
fi

rm -rf /root/udp.zip &>/dev/null
sleep 1
echo -e "${BIWhite}Mereload Service...${NC}"
systemctl daemon-reload
sleep 1
echo -e "${BIWhite}Mengaktifkan Service...${NC}"
systemctl enable --now udp-custom &>/dev/null
sleep 1
echo -e "${BIWhite}Merestart Service...${NC}"
systemctl restart udp-custom &>/dev/null
sleep 3 & loading $!
echo -e "${BIWhite}Successfully Installed UDP Custom${NC}"