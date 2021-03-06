#!/bin/sh

#ssh welcome message
/bin/uname --kernel-name --nodename --kernel-release --kernel-version --machine > /etc/motd

echo 'LANG="en_US.UTF-8"' >> /etc/sysconfig/i18n
echo 'SYSFONT="latarcyrheb-sun16"' >> /etc/sysconfig/i18n

yum -y groupinstall "Development Tools"
yum -y install iftop htop libtool-ltdl-devel openssl-devel openssl mod_ssl pcre-devel gcc make gcc-c++ rpm-build rpm-devel autoconf automake lynx ncurses
yum -y install mysql-devel mysql-server php-mysqli httpd-devel php-devel php-common php-gd php-mcrypt php-xml php-xmlrpc php-domxml php-mbstring php-pear  php-soap

yum -y install git npm
npm install -g bower
npm install -g preen

yum update -y


#---------apc begin-------------
printf "\n" | pecl install apc
printf "extension = apc.so\napc.enabled=1" > /etc/php.d/apc.ini
systemctl restart httpd
#-----------apc end-------------

#----------- memcache begin----------
yum -y install memcached
systemctl start memcached
systemctl enable memcached

printf "yes\n" | pecl install  memcache
printf "extension=memcache.so" > /etc/php.d/memcache.ini
systemctl restart httpd
#----------- memcache end ----------

#----------sphinx begin--------------
cd /usr/src

wget http://sphinxsearch.com/files/sphinx-2.2.10-release.tar.gz
tar xzf sphinx-2.2.10-release.tar.gz 
cd sphinx-2.2.10-release

./configure --prefix=/usr/local/sphinx
make && make install

#/usr/local/sphinx/etc
# add config

#---- add sphinx cronjobs

printf "\n@reboot /usr/local/sphinx/bin/searchd --config /usr/local/sphinx/etc/sphinx.conf" >> /var/spool/cron/root

printf "\n1 */12 * * *  /usr/bin/pgrep indexer || time /usr/local/sphinx/bin/indexer --all --rotate --config /usr/local/sphinx/etc/sphinx.conf" >> /var/spool/cron/root

#--------------sphinx end------------------



#------unoconv begin---------------------
#http://debianworld.ru/articles/unoconv-konvertaciya-word-pdf-swf-html-ppt-dokumentov-v-debian-ubuntu/
#aptitude install openoffice.org-headless openoffice.org-writer openoffice.org-impress
#aptitude install unoconv
#unoconv --listener &
#todo make it be in /etc/init.d
#------unoconv end-----------------------

#---Imagick---
yum install libwebp libwebp-tools

yum -y install ImageMagick ImageMagick-devel ImageMagick-perl
printf "\n" | pecl install imagick
echo "extension=imagick.so" >> /etc/php.d/imagick.ini
#----------------------

#-----datetime sync-----
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
yum -y install ntp
/usr/sbin/ntpdate pool.ntp.org
systemctl start ntpd
systemctl enable ntpd
ln -s '/usr/lib/systemd/system/ntpd.service' '/etc/systemd/system/multi-user.target.wants/ntpd.service'



#---xpdf----
yum -y install libpng-devel
cd /usr/src
wget ftp://ftp.foolabs.com/pub/xpdf/xpdfbin-linux-3.04.tar.gz
tar xzf xpdfbin-linux-3.04.tar.gz
cp -u xpdfbin-linux-3.04/bin64/* /usr/local/bin/
wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-cyrillic.tar.gz
tar xzf xpdf-cyrillic.tar.gz
mkdir -p /usr/local/share/xpdf/cyrillic
cp -u xpdf-cyrillic/* /usr/local/share/xpdf/cyrillic/
cp -u xpdf-cyrillic/add-to-xpdfrc /usr/local/etc/xpdfrc

#Antiword
cd /usr/src
wget http://www.winfield.demon.nl/linux/antiword-0.37.tar.gz
tar xzf antiword-0.37.tar.gz
cd antiword-0.37
make all && make global_install

cd ~
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer


#yum install -y monit

