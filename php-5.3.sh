#!/bin/sh

read -p "Please, enter version of PHP 5.3 to build (etc 5.3.29):" VER

SRC_PREFIX="/usr/src/php";

CFG="/opt/php-$VER/etc"
PREFIX="/opt/php-$VER"
SRC="/usr/src/php/php-$VER"
TARGZ="php-$VER.tar.gz"

if [ ! -d  $SRC_PREFIX ]; then
    mkdir -p $SRC_PREFIX
fi;

cd $SRC_PREFIX

# DOWNLOADING
read -p "Download source for version $VER ? (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    wget "http://us1.php.net/distributions/$TARGZ" --content-disposition

    if [ ! -f $TARGZ ]; then
	echo "File $TARGZ not found (not downloaded)";
	exit 1;
    fi;
    
    tar -xzf $TARGZ
    rm $TARGZ
fi;

if [ ! -d $SRC ]; then
    echo "Src directory $SRC not exists";
    exit 1;
fi;

cd $SRC;

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

    if [ ! -d /usr/include/freetype2/freetype ]; then
	mkdir /usr/include/freetype2/freetype
	ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h
    fi;

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
fi;

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
    echo "extension=gettext.so;" > $CFG/conf.d/gettext.ini

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
    ./pecl install imagick-3.1.2
    echo "extension=imagick.so;" > $CFG/conf.d/imagick.ini
fi;

#
# Set as default PHP-5.3 OPT CGI ?
#
read -p "Set as default version for php-5.3 opt?" REPLY
if [ $REPLY = "y" ]; then
    echo "#!/opt/php-$VER/bin/php-cgi" > /opt/php-cgi-5.3
    chmod 755 /opt/php-cgi-5.3

    rm /opt/php-5.3
    ln -s /opt/php-$VER /opt/php-5.3
fi;


#
# Restart service ?
#
read -p "Restart apache2?" REPLY
if [ $REPLY = "y" ]; then
    service apache2 restart
fi;

