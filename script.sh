#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
touch teste.txt
sudo bash -c 'echo "your very own public web server!" > /var/www/html/index.html'
