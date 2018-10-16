#!/bin/bash

source common.sh
identity='configs/identity.json'
uri="probes"

echo "Register new Probe"

echo "What your probe's  name: "
read name
while [ -z "$name" ]; do
    echo -n "Name Number cannot be empty, please key again: "
    read name
done

echo "What your probe's serial number: "
read serial
while [ -z "$serial" ]; do
    echo -n "Serial Number cannot be empty, please key again: "
    read serial
done

echo "What your salt minion id: "
read minion_identity
while [ -z "$minion_identity" ]; do
    echo -n "Identity Number cannot be empty, please key again: "
    read minion_identity
done

echo "What your probe's location: "
read location
while [ -z "$location" ]; do
    echo -n "Location cannot be empty, please key again: "
    read location
done

echo "What your probe's description: "
read description

echo "Registering Probe: $serial with the server. Please wait ..."

params="name=$name&serial_number=$serial&location=$location&description=$description&identity=$minion_identity"
echo $params
echo $server
echo $uri
## Post request to register new indentity
data=`curl -X POST --data $params $server$uri`
echo $data
echo $data > $identity
echo "Done"