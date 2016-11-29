SRC="/usr/src/curl/7_51_0"

if [ ! -d $SRC ];
then
    mkdir -p $SRC
    git clone https://github.com/bagder/curl $SRC

    cd $SRC
    git checkout tags/curl-7_51_0
else
    cd $SRC
    make clean
    git pull
fi;

./buildconf
./configure --prefix=/opt/curl --with-ssl=/opt/openssl --disable-file --without-pic --disable-shared --without-ca-bundle --with-ca-path=/opt/openssl/ssl/certs

read -p "Press enter to make or ^C to stop?" REPLY
make -j10

read -p "Press enter to make install or ^C to break?" REPLY
make install
