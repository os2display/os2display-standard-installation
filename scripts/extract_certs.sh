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
	/usr/bin/openssl pkcs12 -in "${PFX}" -password pass:"${IMPORT}" -passout pass:"${IMPORT}" -nocerts -out "${PFX_NO_EXT}"_privkey.pem
	/usr/bin/openssl pkcs12 -in "${PFX}" -password pass:"${IMPORT}" -clcerts -nokeys -chain -out "${PFX_NO_EXT}"_trustcert.pem
	/usr/bin/openssl pkcs12 -in "${PFX}" -password pass:"${IMPORT}" -cacerts -nokeys -chain -out "${PFX_NO_EXT}"_fullchain.pem
	/usr/bin/openssl rsa -in "${PFX_NO_EXT}"_privkey.pem -passin pass:"$IMPORT" -out "${PFX_NO_EXT}"_nopass-privkey.pem
	# RSA private key
	/usr/bin/openssl pkcs12 -in "${PFX}" -nocerts -nodes -passin pass:"${IMPORT}" | openssl rsa -out "${PFX_NO_EXT}"_RSA_privkey.pem

	# Check if any of the files are empty, and if so remove them, as they'd be of no use as empty.
	if [[ ! -s ${PFX_NO_EXT}_fullchain.pem ]]; then
		/bin/rm "${PFX_NO_EXT}"_fullchain.pem
	fi

	if [[ ! -s ${PFX_NO_EXT}_trustcert.pem ]]; then
		/bin/rm "${PFX_NO_EXT}"_trustcert.pem
	fi

	if [[ ! -s ${PFX_NO_EXT}_privkey.pem ]]; then
		/bin/rm "${PFX_NO_EXT}"_privkey.pem
	fi

	if [[ ! -s ${PFX_NO_EXT}_nopass-privkey.pem ]]; then
		/bin/rm "${PFX_NO_EXT}"_nopass-privkey.pem
	fi

	if [[ ! -s ${PFX_NO_EXT}_RSA_privkey.pem ]]; then
		/bin/rm "${PFX_NO_EXT}"_RSA_privkey.pem
	fi

else
	# Inform the user on how to use the script.
	echo "Usage: $0 certs.pfx"
fi
