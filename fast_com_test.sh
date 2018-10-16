#!/usr/bin/env bash

source common.sh

uri="fast-com-test-reports"
resultUrl="results"
json_file="fast.com.json"
payload="payload.json"
test_id_file="incl/fast.com.json"

message="Test is imported successfully"
msFailTest="Cannot retrieve fast com configuration"

storeResultFile="backup/fast_com/result.json"
storeReportFile="backup/fast_com/report.json"

status=0
test_case_id=3

fastTest='vendor/fast/my_fast_com.py'

## Check file disconnection send sever

## Result
resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the fast com test ..."

## Run my_fast_com.py command to get the result
data=$(python $fastTest)
echo $data

## --------------Test Fail
if [ "$data" == 0 ];
then
    status=0
    sendResult
    exit
fi

## --------------Test Pass

jsonData=$(echo $data | jq "{no_convert: 0, download: \"$data\",
    \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity,
    created_at: \"$timestamp\", updated_at: \"$timestamp\", status: 1, version: \"1.0\" }")
echo $jsonData
### Send payload to server
response=$(curl -H "Content-Type: application/json" -X POST -d "$jsonData" $server$uri)
echo $response;
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

