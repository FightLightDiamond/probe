#!/bin/bash

source common.sh

uri="html5-test-us-reports"
resultUrl="results"

message="Test is imported successfully"
msFailTest='"success"'

storeResultFile="backup/h_t_m_l5_speedtest_u_s/result.json"
storeReportFile="backup/h_t_m_l5_speedtest_u_s/report.json"

status=0
test_case_id=3

## Check file disconnection send sever

# Result
resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the 10G HTML5 speed test us test ..."

## Run HTML5 US command to get the result
data=`/var/www/probe/vendor/spd-cli -s speed-portal.singnet.com.sg -c US -j -dlStreams 40 -ulStreams 40`
#echo '----Data---'
echo $data

status=`echo $data | jq .status`
echo $status
echo $msFailTest
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
sendResult
