#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

source lib/rm_exist_file.sh

coefficient=1048575

server=`cat configs/server.txt`
probeData="configs/identity.json"

storeResultFile=""
storeReportFile=""
resultUrl=""

response=""
message="Test is imported successfully"
dataReport=""

status=0
timestamp=`date "+%Y-%m-%d %T"`
test_id=1
probe_id=`jq '.id' $probeData`
identity=`jq '.identity' $probeData`

echo "Probe id"
echo $probe_id
echo "Identity"
echo $identity

function resultRestore {
    echo 'begin result restore'
    isResult=`cat $storeResultFile`
    echo $isResult
    if [ "$isResult" != "[]" ]; then
        result=$(curl -H "Content-Type: application/json" -d  "$isResult"  $server$resultUrl)
        if [[ "$result" != "" ]]
        then
          echo [] > $storeResultFile
        fi
    fi
    echo 'end result restore'
}

function reportRestore {
    echo 'begin report restore'
    isReport=`cat $storeReportFile`
    if [ "$isReport" != "[]" ]; then
        result=$(curl -H "Content-Type: application/json" -d  "$isReport"  $server$uri)
        #echo $result
        if [[ "$result" != "" ]]
        then
           echo [] > $storeReportFile
        fi
    fi
    echo 'end result restore'
}

function checkRegister {
    #data=`cat $probeData`
    echo 'begin check register'
    while [ ! -f $probeData ]; do
        echo "You have not register your probe yet."
        sh `register.sh`
    done
    echo 'end check register'
}

function checkBackup()
{
    if [[ "$response" != *$message* ]]
    then
        if [ ! -f $storeReportFile ]; then
            echo [] > $storeReportFile
        fi
        data=`jq ".[.| length] |= . + $dataReport" $storeReportFile`
        echo $data > $storeReportFile
    fi
}

function sendResult()
{
    dataResult="{\"test_case_id\": \"$test_id\", \"probe_id\": \"$probe_id\", \"identity\": $identity,
         \"status\": 0, \"version\": \"1\", \"created_at\": \"$timestamp\", \"updated_at\": \"$timestamp\"}"
    response=$(curl -H "Content-Type: application/json" -d  "$dataResult"  $server$resultUrl)
    echo $response;
    checkBackup
}
