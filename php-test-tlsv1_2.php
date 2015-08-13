<?php

$ch = curl_init("https://engine.paymentgate.ru/payment/webservices/merchant-ws?wsdl");
curl_setopt($ch, CURLOPT_VERBOSE, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURL_SSLVERSION_TLSv1_2, 1);
var_dump( curl_exec( $ch ) );

