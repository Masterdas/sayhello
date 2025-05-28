#!/data/data/com.termux/files/usr/bin/bash

# === Colors ===
green="\e[32m"
yellow="\e[33m"
red="\e[31m"
cyan="\e[36m"
end="\e[0m"

clear

# === Display Banner ===
echo -e "${yellow}====================================="
echo -e "${green}  ZeroDark Nexus - Sey hello Setup  "
echo -e "${yellow}====================================="
echo -e "${cyan}Welcome to ZeroDark Nexus Setup!${end}"

# === Install dependencies ===
echo -e "${green}Installing required dependencies...${end}"
pkg install php curl -y
chmod +x sayhello
mv sayhello $PREFIX/bin/

echo -e "\e[92m Installed Successfully[\e[34m✓\e[92m]\e[34m"
echo -e "\e[92m~\e[0m $ .....\e[92mSUBSCRIBE My YOUTUBE Channel\e[0m.....\e[94m[\e[92m✓\e[94m]\e[0m"
termux-open-url https://youtube.com/@zerodarknexus