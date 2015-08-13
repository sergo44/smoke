#!/bin/sh

read -p "Please, enter version of PHP 5.5 to build (etc 5.5):" VER

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
    wget "http://ru2.php.net/get/$TARGZ/from/this/mirror" --content-disposition

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

    ./configure --prefix="$PREFIX"\
	--enable-cgi \
	--enable-static \
	\
	--enable-mbstring \
	--enable-soap \
	--enable-zip \
	--enable-calendar \
	--enable-sockets \
	--enable-bcmath \
	\
	--with-zlib\
	--with-openssl=/opt/openssl \
	--with-curl=/opt/curl \
	--with-gettext=shared \
	\
	--with-gd=shared \
	--enable-gd-native-ttf \
	--with-freetype-dir=/usr \
	\
	--with-mcrypt \
	--with-mysql \
	--with-mysqli \
	--with-pdo-mysql \
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
    #echo "extension=openssl.so;" > $CFG/conf.d/openssl.ini
    #echo "extension=curl.so;" > $CFG/conf.d/curl.ini
    echo "extension=gd.so;" > $CFG/conf.d/gd.ini
    echo "extension=gettext.so;" > $CFG/conf.d/gettext.ini

    # opcache
    echo "zend_extension=opcache.so;" > $CFG/conf.d/opcache.ini
    echo "opcache.memory_consumption=128;" >> $CFG/conf.d/opcache.ini
    echo "opcache.interned_strings_buffer=8;" >> $CFG/conf.d/opcache.ini
    echo "opcache.max_accelerated_files=4000;" >> $CFG/conf.d/opcache.ini
    echo "opcache.revalidate_freq=60;" >> $CFG/conf.d/opcache.ini
    echo "opcache.fast_shutdown=1;" >> $CFG/conf.d/opcache.ini
    echo "opcache.enable_cli=1;" >> $CFG/conf.d/opcache.ini

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
# Set as default PHP-5.5 OPT CGI ?
#
read -p "Set as default version for php-5.5 opt?" REPLY
if [ $REPLY = "y" ]; then
    echo "#!/opt/php-$VER/bin/php-cgi" > /opt/php-cgi-5.5
    chmod 755 /opt/php-cgi-5.5
    
    rm /opt/php-5.5
    ln -s /opt/php-$VER /opt/php-5.5
fi;


#
# Restart service ?
#
read -p "Restart apache2?" REPLY
if [ $REPLY = "y" ]; then
    service apache2 restart
fi;

