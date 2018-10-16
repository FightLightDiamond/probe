#!/usr/bin/env bash
identity=`cat /etc/salt/minion | grep "id:"`
identity_path='/var/www/probe/configs/identity.json'

echo "GREP:"
echo $identity

identity=`echo $identity | awk '{print $2}'`

echo "AWK:"
echo $identity

probe_json=`jq ".[] |select(.identity==\"$identity\")" /var/www/probe/configs/identities.json`

echo "JQ:"
echo $probe_json

if [ "$probe_json" != "" ];
then
    echo $probe_json > $identity_path
else
 echo "Not found probe"
fi

exit