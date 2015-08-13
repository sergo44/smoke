#!/bin/sh


VER="5.3.29"
CFG="/opt/php-$VER/etc"
PREFIX="/opt/php-$VER"

cd "/opt/src/php-$VER";

#
# Configuring
#

read -p "Make clean ? (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    make clean
fi;


read -p "Configure (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    apt-get build-dep php5

    ./configure\
	--prefix="$PREFIX"\
	--enable-cgi \
	--enable-static \
	\
	--enable-mbstring \
	--enable-soap \
	--enable-zip \
	--enable-calendar\
	--enable-exif\
	\
	--with-bz2\
	--with-zlib\
	--with-openssl=shared\
	--with-curl=shared \
	\
	--with-gd=shared \
	--enable-gd-native-ttf \
	--with-freetype-dir=/usr \
	\
	--with-mcrypt \
	--with-mysql \
	--with-mysqli \
	--with-pgsql \
	\
	--with-jpeg-dir=/usr \
	--with-png-dir=/usr \
	--with-config-file-path="$CFG" \
	--with-config-file-scan-dir="$CFG/conf.d"

fi

read -p "Make ? (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    make -j 12
fi;


read -p "Make test ? (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    make test -j 12
fi;


#
# Install ?
#
read -p "Install ? (y/n)?" REPLY
    if [ $REPLY = "y" ]; then

    make install

fi;

#
# Set config ini files?
#
read -p "Save ini files? (y/n)?" REPLY
if [ $REPLY = "y" ]; then

    if [ ! -d "$CFG" ];
    then
	mkdir -p "$CFG";
    fi

    if [ ! -d "$CFG/conf.d" ];
    then 
	mkdir -p "$CFG/conf.d";
    fi;

    # extension
    echo "extension=openssl.so;" > $CFG/conf.d/openssl.ini
    echo "extension=curl.so;" > $CFG/conf.d/curl.ini
    echo "extension=gd.so;" > $CFG/conf.d/gd.ini
    
    # defaults
    echo "date.timezone=\"Europe/Moscow\";" > $CFG/conf.d/defaults.ini

    # limits
    echo "post_max_size=512m;" > $CFG/conf.d/limits.ini
    echo "memory_limit=128m;" >> $CFG/conf.d/limits.ini
    echo "upload_max_filesize=512m;" >> $CFG/conf.d/limits.ini
fi;

#
# Pecl imagemagic
#
read -p "Pecl install imagick (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    apt-get build-dep php5-imagick --install-recommends
    cd $PREFIX/bin/
    ./pecl install imagick
    echo "extension=imagick.so;" > $CFG/conf.d/imagick.ini
fi;

#
# Set as default PHP-5.3 OPT CGI ?
#
read -p "Set as default version for php-5.3 opt?" REPLY
if [ $REPLY = "y" ]; then
    echo "#!/opt/php-$VER/bin/php-cgi" > /opt/php-cgi-5.3
    chmod 755 /opt/php-cgi-5.3
fi;


#
# Restart service ?
#
read -p "Restart apache2?" REPLY
if [ $REPLY = "y" ]; then
    service apache2 restart
fi;

