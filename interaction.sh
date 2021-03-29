#!/bin/sh
##
# @Description: This script is produce to make changing of client url easy as ABC
# Author: Odejinmi Samuel ~ Samji
##
##

echo I am about to help add all all_in_one_monitoring to your server
echo What is your domain name e.g bigbluebutton.com?
read server

echo What is the secret key e.g Key you get when you run bbb-conf --secret?
read secretkey


if [ "$server" == "" ]; then 
        echo "You must specify a valid domain name e.g bigbluebutton.com"
        echo "I will not be able to help you further"
        return
fi

if [ "$secretkey" == "" ]; then 
    err "You must specify a valid secret key (The key you get when you run bbb-conf --secret)."
    echo "I will not be able to help you further"
    return
fi


## Add grafana & Promotherus
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo curl -L "https://github.com/docker/compose/releases/download/1.28.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version


mkdir ~/bbb-monitoring
git clone https://github.com/greenstatic/bigbluebutton-exporter.git

cp -R ~/bigbluebutton-exporter/extras/all_in_one_monitoring/* ~/bbb-monitoring/

sudo sed -i "s/example.com/$server/" ~/bbb-monitoring/bbb_exporter_secrets.env
sudo sed -i "s/<SECRET>/$secretkey /" ~/bbb-monitoring/bbb_exporter_secrets.env

sudo sed -i "s/example.com/$server/" ~/bbb-monitoring/docker-compose.yaml

cd ~/bbb-monitoring
sudo docker-compose up -d

cat <<EOF >> /etc/bigbluebutton/nginx/monitoring.nginx
# BigBlueButton monitoring
location /monitoring/ {
  proxy_pass http://127.0.0.1:3001/;
  include proxy_params;
}
EOF
systemctl restart nginx

echo "Visit https://$SERVER/monitoring for metrics"

echo "*************Thanks for using me************"
echo "Give SamjiDiamond a star on github"
