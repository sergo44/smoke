<?php

$ch = curl_init("https://zakupki.gov.ru");
curl_setopt($ch, CURLOPT_VERBOSE, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_SSLENGINE, "gost");
curl_setopt($ch, CURLOPT_SSLENGINE_DEFAULT, "gost");
curl_setopt($ch, CURLOPT_SSL_CIPHER_LIST, "GOST2001-GOST89-GOST89");
var_dump( curl_exec( $ch ) );

