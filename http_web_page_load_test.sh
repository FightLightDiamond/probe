#!/bin/bash

source common.sh

uri="http-web-page-load-test-reports"
resultUrl="results"
url_file="configs/url/http_web_page_load_test.json"

message="Test is imported successfully"
msFailTest="0,000:0,000"

storeResultFile="backup/http_web_page_load_test/result.json"
storeReportFile="backup/http_web_page_load_test/report.json"

status=3
test_case_id=3
## Result

resultRestore
reportRestore

## Check identity, if not exist, need to register new one
checkRegister

echo "Let start the HTTP Web Page Load test ..."

arr=( $(jq -r '.list[]' $url_file) )
## now loop through the above array
for domain in "${arr[@]}"
do
    ping_result=$(curl -o /dev/null -s -w %{time_namelookup}:%{time_total} $domain)
    echo 'Ping result';
    echo $ping_result;

    ## --------------Test Fail
    if [ "$ping_result" == "$msFailTest" ];
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
    dns_resolution_time=$(echo "$ping_result" | awk -F ':' '//{print $1}')
    load_time=$(echo "$ping_result" | awk -F ':' '//{print $2}')

    echo $dns_resolution_time
    echo $load_time
    # Combine to json file
    dns_resolution_time=`echo "$dns_resolution_time * 1000" | bc`
    load_time=`echo "$load_time * 1000" | bc`

    echo $dns_resolution_time
    echo $load_time

    dns_resolution_time=${dns_resolution_time%.*}
    load_time=${load_time%.*}

    echo $dns_resolution_time
    echo $load_time

    dataReport="{\"target\":\"$domain\", \"dns_resolution_time\":\"$dns_resolution_time\", \"load_time\":\"$load_time\",
    \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity}"
    echo $dataReport;

    response=$(curl -H "Content-Type: application/json" -X POST -d "$dataReport" $server$uri)
    checkBackup

    ## Result test true
    pass=1;    if [ "$status" != 3 ] && [ "$status" != 2 ] && [ "$pass" != "$status" ];
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