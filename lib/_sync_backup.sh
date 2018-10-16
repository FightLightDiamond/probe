#!/usr/bin/env bash

source ../common.sh

uri="speedtest"
resultUrl="results"

TESTS="dnstest dropbox_test fast_com h_t_m_l5_speedtest_s_g h_t_m_l5_speedtest_u_s http_web_page_load_test icmp_test speedtest speedtest_usa tcp_ping teng_speedtest youtube"

for TEST in $TESTS
do
    storeResultFile="/var/www/probe/backup/$TEST/result.json"
    echo $storeResultFile;
    # Result
    isResut=`cat $storeResultFile`
    if [ "$isResut" != "[]" ]; then
        result=$(curl -H "Content-Type: application/json" -d  "$isResut"  $server$resultUrl)
        if [[ "$result" != "" ]]
        then
          $storeResultFile
        fi
    fi
    ## Report
    storeReportFile="/var/www/probe/backup/$TEST/report.json"
    echo $storeReportFile
    isReport=`cat $storeReportFile`
    if [ "$isReport" != "[]" ]; then
        result=$(curl -H "Content-Type: application/json" -d  "$isReport"  $server$uri)
        #echo $result
        if [[ "$result" != "" ]]
        then
           $storeReportFile
        fi
    fi
done