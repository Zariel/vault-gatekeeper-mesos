#!/bin/bash

set -e

function vault () {
	docker run -it --rm -e VAULT_ADDR --entrypoint=/bin/sh sjourdan/vault -c "vault auth $VAULT_TOKEN &>/dev/null; vault $*"
}

function run_tests() {

	# Run Vault
	docker run -d -p 8200:8200 --hostname vault --name vault sjourdan/vault
	VAULT_HOST=`docker inspect -f '{{ .NetworkSettings.IPAddress }}' vault`
	export VAULT_ADDR="http://$VAULT_HOST:8200"
	export VAULT_TOKEN=`docker logs vault 2>/dev/null | grep 'Root Token' | awk '{ printf $3 }'`

	# Import minimesos env args
	eval `cd minimesos/ && minimesos info | tail -n+3`
	vault status
	echo $MINIMESOS_AGENT

	docker stop vault
	docker rm vaul
}

run_tests