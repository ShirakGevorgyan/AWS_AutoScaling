#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y apache2 stress

sudo systemctl start apache2
sudo systemctl enable apache2

# Configure the default webpage with the instance's private IP
echo "Web Server Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)" > /var/www/html/index.html

sleep 60

stress --cpu 2 --timeout 600
