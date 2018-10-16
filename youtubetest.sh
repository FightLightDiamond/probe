#!/bin/bash

source common.sh

uri="youtube-test-reports"
resultUrl="results"
url_file="configs/url/youtubetest.json"

msFailTest=""

storeResultFile="backup/youtube/result.json"
storeReportFile="backup/youtube/report.json"

status=0
test_case_id=3

## Result

#resultRestore
#reportRestore

start=`date +%s`

url_file="configs/url/youtubetest.json"
arr=( $(jq -r '.list[]' $url_file) )
for domain in "${arr[@]}"
do
    data=$(youtube-dl --no-check-certificate -f best -j $domain)
done

echo $data

## --------------Test Fail
if [ "$data" == "$msFailTest"  ];
then
    sendResult
    exit
fi

url_youtube=`echo $data | jq '.url'`
filename=`echo $data | jq '._filename'`

echo "URL"
echo $url_youtube

echo "FILE NAME"
echo $filename

end=`date +%s`
time_download=$((end-start))
filesize=($(stat --printf="%s" "$filename"))

echo "FILE SIZE"
echo $filesize

rate=$(($filesize/$time_download))

# Get Ip, Latency
domain=${url_youtube##*//}
domain=${domain%%/*}

ip=$(ping -c 1 $domain | awk -F '[()]' '/PING/{print $2}')
latency=$(ping -c 1 $domain | awk -F'time=' '/64 bytes/{print $2}')
echo $latency;

latency=${latency% *}

dataReport="{\"download rate\": $rate, \"ip\": \"$ip\", \"latency\": $latency, \"target\": \"$domain\"
        \"test_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity}"
echo $dataReport;


# Send payload to server
####
response=$(curl -H "Content-Type: application/json" -X POST -d "$dataReport" $server$uri)

## Result test true
status=1
sendResult