#!/bin/bash

source common.sh

uri="html5-test-sg-reports"
resultUrl="results"

message="Create success"
msFailTest='"success"'

storeResultFile="backup/h_t_m_l5_speedtest_s_g/result.json"
storeReportFile="backup/h_t_m_l5_speedtest_s_g/report.json"

status=0
test_case_id=3

## Check file disconnection send sever

# Result
resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the HTML5 speed test SG ..."

# Run HTML5 SG command to get the result
data=`/var/www/probe/vendor/spd-cli -s speed-portal.singnet.com.sg -c SG -j`
#data=`./vendor/spd-cli -s speed-portal.singnet.com.sg -c SG -j`
echo $data
echo $msFailTest
status=`echo $data | jq .status`
echo $status
## --------------Test Fail
if [ "$msFailTest" != "$status"  ]; then
    sendResult
    exit
fi

data=`echo $data | jq .result`

download=`echo $data | jq .download`
upload=`echo $data | jq .upload`
ping=`echo $data | jq .ping`
ping=${ping%.*}

dataReport="{\"ping\": \"$ping\", \"upload\": \"$upload\", \"download\": \"$download\",
    \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity}";

echo $dataReport;
## Send payload to server

response=$(curl -H "Content-Type: application/json" -X POST -d "$dataReport" $server$uri)

if [[ "$response" != *$message* ]]
then
    if [ ! -f $storeReportFile ]; then
        echo [] > $storeReportFile
    fi
    data=`jq ".[.| length] |= . + $dataReport" $storeReportFile`
    echo $data > $storeReportFile
fi

## Result test true
status=1
#sendResult
