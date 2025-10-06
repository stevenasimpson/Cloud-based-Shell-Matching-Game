#!/bin/bash

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql

#Change VM's webserver's cofiguration to use shared folder.
# (Look inside shell-website.conf for specifics.)
cp /vagrant/shell-website.conf /etc/apache2/sites-available
# activate our website configuration ...
a2ensite shell-website.conf
# ... and disable the default website provided with Apache
a2dissite 000-default
service apache2 reload 