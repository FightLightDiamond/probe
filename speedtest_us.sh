#!/bin/bash

source common.sh

uri="speed-test-us-reports"
resultUrl="results"

message="Test is imported successfully"
msFailTest="Cannot retrieve speedtest configuration"

storeResultFile="backup/speedtest_us/result.json"
storeReportFile="backup/speedtest_us/report.json"

status=0
test_case_id=2

resultRestore
reportRestore

# Người tham công tiếc việc, thường cho rằng mình đang sống rất tốt nhưng thật ra là đang đánh mất chính mình vì cách
# làm việc như thế. Qúa bận rộn, còn đâu thời gian và tâm trí để nghĩ đến bản  thân, nói chi đến người khác, rồi chỉ
# thích làm và làm. Vấn đề lẫn lỗn giữa làm và kết quả. Không phải cứ làm nhiều là thu được kết quả tốt. Họ muốn sử dụng
# sự bận rộn của mình để chứng minh với người khác là mình đang thành công, nhưng nhìn cho thấu đáo liệu thời gian họ bỏ ra đó
# đa phần là những việc không cần thiết

checkRegister

function testing {
    echo "Let start the speed test ..."
    #data=$(speedtest-cli --server 2761 --json )
    data=$(speedtest-cli --json )
    echo $data
    byteSent=$(echo $data | jq ".bytes_sent")
    echo "End start the speed test ..."
}
testing

function checkTestFail {
    echo "Begin check test fail"
    if [ "$data" == "$msFailTest"  ] || [ "$byteSent" == 0 ];
    then
        sendResult
        exit
    fi
    echo "End check test fail"
}
checkTestFail

function sendReportDetailTestPass
{
    echo "Start report detail test pass"
    ping=`echo $data | jq ".ping"`
    ping=${ping%.*}
    download=`echo $data | jq ".download"`
    download=`echo "scale=2; $download/$coefficient" | bc`
    upload=`echo $data | jq ".upload"`
    upload=`echo "scale=2; $upload/$coefficient" | bc`
    #download, upload need /1048576
    jsonData=$(echo $data | jq "{bytes_sent: .bytes_sent, download: \"$download\", upload: \"$upload\",
    test_id: \"$test_case_id\", probe_id: \"$probe_id\", identity: $identity,
    ping: $ping, created_at: \"$timestamp\", updated_at: \"$timestamp\",
    status: 1, version: \"1.0\"
    }")

    echo $jsonData
    echo $server$uri

    response=$(curl -H "Content-Type: application/json" -X POST -d "$jsonData" $server$uri)

    if [[ "$response" != *$message* ]]
    then
        if [ ! -f $storeReportFile ]; then
            echo [] > $storeReportFile
        fi
        data=`jq ".[.| length] |= . + $jsonData" $storeReportFile`
        echo $data > $storeReportFile
    fi
    echo "End report detail test pass"
}
sendReportDetailTestPass

status=1
sendResult
