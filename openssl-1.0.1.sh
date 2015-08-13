
SRC="/usr/src/openssl/1.0.1-stable"

if [ ! -d $SRC ];
then
    git clone https://github.com/openssl/openssl.git -b OpenSSL_1_0_1-stable $SRC
else
    cd $SRC
    git pull
fi;

cd $SRC

read -p "Press enter to continue or ^C to break?" REPLY
./config --prefix=/opt/openssl no-idea no-mdc2 no-rc5 no-zlib enable-tlsext no-ssl2 no-ssl3
#./config --prefix=/opt/openssl no-idea enable-tlsext no-ssl2 no-ssl3 enable-rfc3779 enable-rfc3779

read -p "Press enter to make depend or ^C to stop?" REPLY
make depend

read -p "Press enter to make or ^C to break?" REPLY
make

read -p "Press enter to make install or ^C to break?" REPLY
make install

read -p "Press enter to copy certs or ^C to break?" REPLY
cp -RPL /etc/ssl/certs/* /opt/openssl/ssl/certs
/opt/openssl/bin/c_rehash /opt/openssl/ssl/certs
cat /opt/openssl/ssl/certs/*.pem > /opt/openssl/ssl/certs/ca-certificates.crt
