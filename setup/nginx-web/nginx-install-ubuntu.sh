#!/bin/bash
sudo apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
            | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
        http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
            | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt -y update
sudo apt install -y nginx

sudo mkdir /upload

sudo cp ./web-server.conf /etc/nginx/conf.d/
sudo systemctl restart nginx
