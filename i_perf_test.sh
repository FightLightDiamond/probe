#!/bin/bash

source common.sh

uri="i-perf-test-reports"
resultUrl="results"
url_file="configs/url/i_perf.json"

message="Test is imported successfully"
msFailTest="error -"

storeResultFile="backup/i_perf/result.json"
storeReportFile="backup/i_perf/report.json"

status=0
test_case_id=3

### Result
#resultRestore
#reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the 10G speed test ..."

## Run iperf3 command to get the result

arr=( $(jq -r '.list[]' $url_file) )
for domain in "${arr[@]}"
do
    up=`iperf3 -c $domain -P 16 -w 1M -J | jq '.end.sum_sent.bits_per_second'`
    down=`iperf3 -c $domain -P 16 -w 1M -R -J | jq '.end.sum_received.bits_per_second'`

    echo $up
    echo $down

    up=`echo "scale=2; $up/$coefficient" | bc`
    down=`echo "scale=2; $down/$coefficient" | bc`

    echo $up
    echo $down

    dataReport="{\"target\": \"$domain\", \"download\": \"$down\", \"upload\": \"$up\",
        \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity}"
    echo $dataReport;

    response=$(curl -H "Content-Type: application/json" -X POST -d "$dataReport" $server$uri)
    echo $response;

    checkBackup
done

## Result test true
status=1
sendResult