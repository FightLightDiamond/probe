#!/bin/bash

source common.sh

uri="speedtest"
resultUrl="results"
payload="dropbox_test_payload.json"
test_id_file="incl/dropbox_test.json"
datafile="dropbox_test_data.json"
url_file="configs/url/dropbox_test.json"

message="Test is imported successfully"
msFailTest=""

storeResultFile="backup/dropbox_test/result.json"
storeReportFile="backup/dropbox_test/report.json"

status=0
test_case_id=3

resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the Dropbox test ..."

## Clean out all old data if existed
rm_exist_file $datafile

## Run curl command to get the result
url_file="configs/url/dnstest.json"
arr=( $(jq -r '.list[]' $url_file) )
for domain in "${arr[@]}"
do
   data=$(curl -L -O -H 'Cache-Control: no-cache' $domain 2>/dev/stdout | awk -F '100' '/100/{print $3}')
done

echo "Result test: $data";

## --------------Test Fail
if [ "$data" == "$msFailTest"  ] ;
then
    status=0
    sendResult
    exit
fi
## --------------Test Pass
current_speed=$(echo $data | awk '{print $11}')
avarage_download=$(echo $data | awk '{print $6}')

## Remove M at last digit

avarage_download=`echo "scale=2; $avarage_download / 1024". | bc`
current_speed=`echo "scale=2; $current_speed / 1024". | bc`

echo "avarage_download: $avarage_download"
echo "current_speed_final: $current_speed"

avarage_download_final=$(convert_to_num $avarage_download)
current_speed_final=$(convert_to_num $current_speed)

echo "avarage_download: $avarage_download_final"
echo "current_speed_final: $current_speed_final"

# Combine to json file
echo "{\"average download\":$avarage_download_final, \"current speed\":$current_speed_final}" >> $datafile

cat $datafile

## Combine identity to payload
jq -s '.[0] * .[1] * .[2]' $identity $datafile $test_id_file  > $payload
cat $payload

## Send payload to server
response=`curl -H "Content-Type: application/json" -X POST -d @$payload $server$uri`

dataReport=$(cat $payload)
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
