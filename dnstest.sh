#!/bin/bash

source common.sh

uri="dns-test-reports"
resultUrl="results"
payload="dnstest_payload.json"
test_id_file="incl/dnstest.json"
datafile="dnstest_data.json"
url_file="configs/url/dnstest.json"

message="Test is imported successfully"
msFailTest="connection timed out"
msPassTest="Got answer"

storeResultFile="backup/dnstest/result.json"
storeReportFile="backup/dnstest/report.json"

status=3
test_id=3

resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the Dns test ..."

arr=( $(jq -r '.list[]' $url_file) )
## now loop through the above array
for domain in "${arr[@]}"
do
   ## Run dig command to get the result
   response_time=$(dig $domain  | grep "Query time:" | awk -F ':' '//{print $2}' | awk -F ' msec' '//{print $1}')
    singnet83=$(dig @165.21.83.88 $domain | grep "Query time:" | awk -F ':' '//{print $2}' | awk -F ' msec' '//{print $1}')
    singnet100=$(dig @165.21.100.88 $domain | grep "Query time:" | awk -F ':' '//{print $2}' | awk -F ' msec' '//{print $1}')
    google=$(dig @8.8.8.8 $domain | grep "Query time:" | awk -F ':' '//{print $2}' | awk -F ' msec' '//{print $1}')

    echo $response_time;
    echo $singnet83;
    echo $singnet100;
    echo $google;
    #echo $ping_result
    if [ "$response_time" == "" ] && [ "$singnet83" == "" ] && [ "$singnet100" == "" ] && [ "$google" == "" ];
    then
        fail=0;
        if [ "$status" != 3 ] && [ "$status" != 2 ] && [ "$fail" != "$status" ];
        then
            status=2;
            sendResult
            continue
        fi
        if [ "$status" != 2 ];
        then
            status="$fail"
        fi
    fi
    #format data
    if [ "$response_time" == "" ];
    then
        response_time=0
    fi
    if [ "$singnet83" == "" ];
    then
        singnet83=0
    fi
    if [ "$singnet100" == "" ];
    then
        singnet100=0
    fi
    if [ "$google" == "" ];
    then
        google=0
    fi

    # Combine to json file
    echo "Data"
    jsonData="{\"target\": \"$domain\", \"response_time\": \"$response_time\",
    \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity,
    \"sing_net_83\": \"$singnet83\", \"sing_net_100\": \"$singnet100\", \"google\": \"$google\"}";

    echo $jsonData

    ## Send payload to server
    response=$(curl -H "Content-Type: application/json" -X POST -d "$jsonData" $server$uri)

    echo $response

    if [[ "$response" != *$message* ]]
    then
        if [ ! -f $storeReportFile ]; then
            echo [] > $storeReportFile
        fi
        data=`jq ".[.| length] |= . + $jsonData" $storeReportFile`
        echo $data > $storeReportFile
    fi
    ## Result test true

    pass=1;
    if [ "$status" != 3 ] && [ "$status" != 2 ] && [ "$pass" != "$status" ];
    then
        status=2
        sendResult
        continue
    fi
    if [ "$status" != 2 ];
    then
        status="$pass"
    fi
done

if [ "$status" == 3 ];
then
    status = 0
fi

sendResult