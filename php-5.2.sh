#!/bin/sh
CFG="/opt/php-5.2/etc"
PREFIX="/opt/php-5.2/"

umask 0022 && cd php-5.2.17

read -p "Recompile (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    apt-get build-dep php5-cgi --install-recommends

    ./configure --prefix="$PREFIX"\
	--enable-fastcgi \
	--enable-force-cgi-redirect \
	--enable-cgi \
	\
	--enable-mbstring \
	--enable-soap \
	--enable-zip \
	--enable-calendar\
	\
	--with-zlib=shared\
	--with-openssl=shared\
	--with-curl=shared \
	\
	--with-gd=shared \
	--enable-gd-native-ttf \
	--with-ttf \
	--with-freetype-dir=/usr \
	\
	--with-mcrypt=shared \
	--with-mysql=shared \
	--with-mysqli=shared \
	--with-pgsql=shared \
	\
	--with-jpeg-dir=/usr \
	--with-png-dir=/usr \
	--with-config-file-path="$CFG" \
	--with-config-file-scan-dir="$CFG/conf.d" \
	--with-libdir=lib/x86_64-linux-gnu
	
	
    sleep 10
    make clean
    make -j 12
    make install

    if [ ! -d "$CFG" ];
    then
	mkdir -p "$CFG";
    fi

    if [ ! -d "$CFG/conf.d" ];
    then 
	mkdir -p "$CFG/conf.d";
    fi;

    echo "extension=zlib.so;" > $CFG/conf.d/zlib.ini
    echo "extension=openssl.so;" > $CFG/conf.d/openssl.ini
    echo "extension=curl.so;" > $CFG/conf.d/curl.ini
    echo "extension=gd.so;" > $CFG/conf.d/gd.ini
    echo "extension=mcrypt.so;" > $CFG/conf.d/mcrypt.ini
    echo "extension=mysql.so;" > $CFG/conf.d/mysql.ini
    echo "extension=mysqli.so;" > $CFG/conf.d/mysqli.ini
    echo "extension=pgsql.so;" > $CFG/conf.d/pgsql.ini

    if [ ! -f "$CFG/php.ini" ];
    then
	echo "post_max_size=512m;" > $CFG/php.ini
        echo "memory_limit=64m;" >> $CFG/php.ini
	echo "upload_max_filesize=512m;" >> $CFG/php.ini
    fi
fi
#	--with-apxs2=/usr/bin/apxs2\

read -p "Pecl install imagick (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    apt-get build-dep php5-imagick --install-recommends
    cd $PREFIX/bin/
    ./pecl install -f imagick-3.1.2
    echo "extension=imagick.so;" > $CFG/conf.d/imagick.ini
fi;

read -p "Restart apache2?" REPLY
if [ $REPLY = "y" ]; then
service apache2 restart
fi;
