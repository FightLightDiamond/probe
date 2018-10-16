#!/usr/bin/env bash
#!/usr/bin/env bash

source ../common.sh

uri="speedtest"
resultUrl="results"

TESTS="dnstest dropbox_test fast_com h_t_m_l5_speedtest_s_g h_t_m_l5_speedtest_u_s http_web_page_load_test icmp_test speedtest speedtest_usa tcp_ping teng_speedtest youtube"
rm -rf backup
mkdir backup
for TEST in $TESTS
do
    mkdir "backup/$TEST"
    storeResultFile="/var/www/probe/backup/$TEST/result.json"
    storeReportFile="/var/www/probe/backup/$TEST/report.json"
    echo [] > $storeResultFile
    echo [] > $storeReportFile
done