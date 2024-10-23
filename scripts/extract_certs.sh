#!/bin/bash

# Check if a PKCS12 file is added or not
if [[ -n "$1" ]]; then

	# Add PKCS12 file to a variable
	PFX=$1
	PFX_NO_EXT=$(basename -a -s .pfx -s .p12 "${PFX}")

	# Get import password for PKCS12 file; we'll also use this for the privkey passphrase
	echo "What is the import key?:"
	read -rs IMPORT

	# Generate certs in this order: private key, trust certificate, fullchain, private key without passphrase
	/usr/bin/openssl pkcs12 -in "${PFX}" -password pass:"${IMPORT}" -passout pass:"${IMPORT}" -nocerts -out privkey.pem
	/usr/bin/openssl pkcs12 -in "${PFX}" -password pass:"${IMPORT}" -clcerts -nokeys -chain -out trustcert.pem
	/usr/bin/openssl pkcs12 -in "${PFX}" -password pass:"${IMPORT}" -cacerts -nokeys -chain -out fullchain.pem
	/usr/bin/openssl rsa -in privkey.pem -passin pass:"$IMPORT" -out nopass-privkey.pem
	# RSA private key
	/usr/bin/openssl pkcs12 -in "${PFX}" -nocerts -nodes -passin pass:"${IMPORT}" | openssl rsa -out RSA_privkey.pem

	# Check if any of the files are empty, and if so remove them, as they'd be of no use as empty.
	if [[ ! -s fullchain.pem ]]; then
		/bin/rm fullchain.pem
	fi

	if [[ ! -s trustcert.pem ]]; then
		/bin/rm trustcert.pem
	fi

	if [[ ! -s privkey.pem ]]; then
		/bin/rm privkey.pem
	fi

	if [[ ! -s nopass-privkey.pem ]]; then
		/bin/rm nopass-privkey.pem
	fi

	if [[ ! -s RSA_privkey.pem ]]; then
		/bin/rm RSA_privkey.pem
	fi

else
	# Inform the user on how to use the script.
	echo "Usage: $0 certs.pfx"
fi
