#!/bin/bash
##
# @Description: This script is produce to make bbb metrics simple
# Author: Odejinmi Samuel ~ Samji
##

function show_usage (){
    printf "Usage: montoring.sh -s bigbluebutton.com -k tyuijk389iokdikjdeded\n"
    printf "\n"
    printf "Options:\n"
    printf " -s|--server, The server domain e.g bigbluebutton.com url\n"
    printf " -k|--key , The secret key you get when you run bbb-conf --secret\n"
    printf " -h|--help, Print help\n"

return 0
}

while [ ! -z "$1" ]; do
  case "$1" in
     --server|-s)
         shift
         SERVER=$1
         echo "You entered SERVER as: $1"
         ;;
     --key|-k)
         shift
         SECRETKEY=$1
         echo "You entered SECRETKEY as: $1"
         ;;
     --help|-h)
        shift
        echo "You requested for help"
        show_usage
         ;;
     *)
        show_usage
        ;;
  esac
shift
done


if [ "$SERVER" == "" ]; then 
        echo "You must specify a valid domain name e.g bigbluebutton.com"
        show_usage
        return
fi

if [ "$SECRETKEY" == "" ]; then 
    err "You must specify a valid SECRETKEY (The key you get when you run bbb-conf --secret)."
    show_usage
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

sudo sed -i "s/example.com/$SERVER/" ~/bbb-monitoring/bbb_exporter_secrets.env
sudo sed -i "s/<SECRET>/$SECRETKEY /" ~/bbb-monitoring/bbb_exporter_secrets.env

sudo sed -i "s/example.com/$SERVER/" ~/bbb-monitoring/docker-compose.yaml

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
