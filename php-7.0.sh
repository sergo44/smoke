#!/bin/sh

read -p "Please, enter version of PHP 7.0 to build (etc 7.0.14):" VER

SRC_PREFIX="/usr/src/php";

if [ ! -d  $SRC_PREFIX ]; then
    mkdir -p $SRC_PREFIX
fi;

CFG="/opt/php-$VER/etc"
PREFIX="/opt/php-$VER"
SRC="/usr/src/php/php-$VER"
TARGZ="php-$VER.tar.gz"

cd $SRC_PREFIX

# DOENLOADING
read -p "Download source for version $VER ? (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    wget "http://php.net/get/$TARGZ/from/this/mirror" --content-disposition

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

RELEASE=`lsb_release -sc`;

read -p "Configure (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    apt-get build-dep php5

    if [ $RELEASE = "squeeze" ] || [ $RELEASE = "wheezy" ]
    then
	CFG_OPT="--with-openssl=/opt/openssl --with-curl=/opt/curl ";
    else
        CFG_OPT="--with-openssl --with-curl";
    fi

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
	--enable-pcntl \
	--enable-intl \
	\
	--with-zlib\
	$CFG_OPT \
	--with-gettext=shared \
	\
	--with-gd=shared \
	--enable-gd-native-ttf \
	--with-freetype-dir=/usr \
	\
	--with-mcrypt \
	--with-mysqli \
	--with-pdo-mysql \
	\
	--without-fpm-systemd \
	--disable-phpdbg \
	--disable-debug \
	--disable-rpath \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-sysvmsg \
	\
	--with-jpeg-dir=/usr \
	--with-png-dir=/usr \
	--with-config-file-path="$CFG" \
	--with-config-file-scan-dir="$CFG/conf.d" \
#	--enable-fpm 
	#--enable-debug
	#--with-pgsql
	#--with-pic \
fi

read -p "Make ? (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    make -j 6
fi;


read -p "Make test ? (y/n)?" REPLY
if [ $REPLY = "y" ]; then

    MYSQL_TEST_USER=php \
    MYSQL_TEST_DB=php \
    PDO_MYSQL_TEST_USER=php \
    PDO_MYSQL_TEST_DB=php \
    make test -j 6
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
    echo "max_input_vars=10000;" >> $CFG/conf.d/limits.ini
    
    # mysql socket
    echo "mysqli.default_socket=\"/var/run/mysqld/mysqld.sock\";" > $CFG/conf.d/mysqli.ini

    # pdo mysql socket
    echo "pdo_mysql.default_socket=\"/var/run/mysqld/mysqld.sock\";" > $CFG/conf.d/pdo.ini
    
fi;
#
# Pecl imagemagic
#
read -p "Pecl install imagick (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    apt-get build-dep php5-imagick --install-recommends
    cd $PREFIX/bin/
    ./pecl install -f imagick
    echo "extension=imagick.so;" > $CFG/conf.d/imagick.ini
fi;

#
# Pecl memcahed
#
read -p "Pecl install memcached (y/n)?" REPLY
if [ $REPLY = "y" ]; then
    apt-get build-dep php5-memcached --install-recommends
    cd /usr/src/smoke
    rm ./php-memcached -rf
    git clone https://github.com/php-memcached-dev/php-memcached.git -b php7
    cd php-memcached
    $PREFIX/bin/phpize .
    ./configure --with-php-config=$PREFIX/bin/php-config --disable-memcached-sasl
    make
    make install
    cd ..
    rm ./php-memcached -rf
    echo "extension=memcached.so;" > $CFG/conf.d/memcached.ini
fi;


#
# Set as default PHP-7.0 OPT CGI ?
#
read -p "Set as default version for php-7.0 opt?" REPLY
if [ $REPLY = "y" ]; then
    echo "#!/opt/php-$VER/bin/php-cgi" > /opt/php-cgi-7.0
    chmod 755 /opt/php-cgi-7.0

    rm /opt/php-7.0
    ln -s /opt/php-$VER /opt/php-7.0
fi;


#
# Restart service ?
#
read -p "Restart apache2?" REPLY
if [ $REPLY = "y" ]; then
    service apache2 restart
fi;

