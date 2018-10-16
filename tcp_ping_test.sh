#!/bin/bash

source common.sh

uri="tcp-test-reports"
resultUrl="results"
url_file="configs/url/tcp_ping_test.json"

msFailTest="Unable to resolve"

storeResultFile="backup/tcp_ping/result.json"
storeReportFile="backup/tcp_ping/report.json"

status=3
test_case_id=3

## Result
resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the TCP test ..."

url_file="configs/url/tcp_ping_test.json"
arr=( $(jq -r '.list[]' $url_file) )
## now loop through the above array
for domain in "${arr[@]}"
do
    ping_result=$(hping3 -c 5 -S -p 80 $domain 2>&1)
    echo $ping_result
    ## --------------Test Fail
    if [[ "$ping_result" == *$msFailTest* ]];
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

    if [[ "$ping_result" == *not* ]];
    then
        break
    fi

    ## Run speedtest_cli command to get the result
    package_loss=$(echo "$ping_result" | awk -F ',' '/%/{print $3}' | awk -F '%' '//{print $1}')
    avg=$(echo "$ping_result" | awk -F '/' '/round-trip/{print $5}' | awk -F ' ' '//{print $1}')
    if [ -z "$avg" ]; then
    avg=0
    fi
    stddev=$(echo "$ping_result" | awk -F '/' '/round-trip/{print $7}' | awk -F ' ms' '//{print $1}')
    if [ -z "$stddev" ]; then
    stddev=0
    fi

    dataReport="{\"target\": \"$domain\", \"package_loss\": \"$package_loss\",
        \"round_trip_time_avg\": \"$avg\", \"standard_deviation\": \"$stddev\",
        \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity}"
    echo $dataReport;

    response=$(curl -H "Content-Type: application/json" -X POST -d "$dataReport" $server$uri)
    echo $response
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
    status=0
fi

sendResult
