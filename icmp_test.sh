#!/bin/bash

source common.sh

uri="icmp-test-reports"
resultUrl="results"
icmp_payload="icmp_payload.json"
test_id_file="incl/icmp_test.json"
datafile="icmp_data.json"
url_file="configs/url/icmp_test.json"

message="Test is imported successfully"
msFailTest="unknown host"

storeResultFile="backup/icmp_test/result.json"
storeReportFile="backup/icmp_test/report.json"

status=3
test_case_id=3

## Result
resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the ICMP test ..."

## Clean out all old data if existed
rm_exist_file $datafile

## now loop through the above array
url_file="configs/url/icmp_test.json"
arr=( $(jq -r '.list[]' $url_file) )
for domain in "${arr[@]}"
do
    ping_result=$(ping -c 5 $domain)
    echo $ping_result

    ## --------------Test Fail
    if [ "$ping_result" == "" ];
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

    ## Run speedtest_cli command to get the result
    package_loss=$(echo "$ping_result" | awk -F ',' '/%/{print $3}' | awk -F '%' '//{print $1}')
    echo $package_loss;

    avg=$(echo "$ping_result" | awk -F '/' '/rtt/{print $5}')
    if [ -z "$avg" ]; then
        avg=0
    fi
    echo $avg;

    stddev=$(echo "$ping_result" | awk -F '/' '/rtt/{print $7}' | awk -F ' ms' '//{print $1}')
    if [ -z "$stddev" ]; then
        stddev=0
    fi

    echo $stddev

    dataReport="{\"target\": \"$domain\", \"package_loss\": \"$package_loss\",
        \"round_trip_time_avg\": \"$avg\", \"standard_deviation\": \"$stddev\",
        \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity}"
    echo $dataReport;

    response=$(curl -H "Content-Type: application/json" -X POST -d "$dataReport" $server$uri)
    echo $response;

    checkBackup

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

