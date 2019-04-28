#!/bin/bash

get_cert() {
    keytool -v -list -keystore ${1} -storepass ${2} -alias 1|grep "Certificate fingerprints" -A3 > ${3}/${4}
}

get_fingerprint() {
    openssl x509 -noout -fingerprint -sha256 -inform pem -in /home/ec2-user/test.pem|awk -F'=' '{print $2}'
}

extract_cert() {
    openssl pkcs12 -in ${1} -out ${2} -password pass:${3} -passout pass:${4}
}

check_diff() {
    diff $cert_file $keystore > /dev/null
    return $?
}

while getopts "f:k:p:d:" opt
do
    case $opt in
        f)
         cert_file="$OPTARG"
         ;;
        k)
          keystore="$OPTARG"
          ;;
        p)
          password="$OPTARG"
          ;;
        d)
          directory="$OPTARG"
          ;;
    esac
done

extract_cert "${keystore}" "${directory}/cert.pem" "${password}"

get_cert $keystore $password $directory keystore.log
get_cert $cert_file $password $directory file.log
if [ "$(check_diff)" == "0" ]
then
    echo "OK"
else
    echo "KO"
fi