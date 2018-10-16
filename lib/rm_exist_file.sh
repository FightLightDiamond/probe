#!/bin/bash

function rm_exist_file {
    if [ -f "$1" ]; then
        rm -rf "$1"
    fi
}

function convert_to_num {
    str=$1
    i=$((${#str}-1))
    lastdigit="${str:$i:1}"
    re='^[0-9]+$'
    if ! [[ $lastdigit =~ $re ]] ; then
        echo ${str::-1}
    else
        echo $str
    fi
}