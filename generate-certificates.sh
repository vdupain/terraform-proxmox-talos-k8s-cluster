#!/bin/sh
export PRIVATEKEY="my-tls.key"
export PUBLICKEY="my-tls.crt"

mkdir -p output
openssl req -x509 -days 365 -nodes -newkey rsa:4096 -keyout output/"$PRIVATEKEY" -out output/"$PUBLICKEY" -subj "/CN=sealed-secret/O=sealed-secret"