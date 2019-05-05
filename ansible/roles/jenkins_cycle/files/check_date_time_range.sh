#!/bin/bash

stop() {
    echo -n "$1"
    exit 0
}

#For simplicity
check_day_is_today() {
    day=$1
    today=$2
    [[ "$day" == "$today" ]] && echo "OK" || echo "KO"
}

check_last_day_is_today(){
    current_month=$(date +%m)
    next_week=$(date -d"now + 1 week" +%m)
    [[ "$current_month" != "$next_week" ]] && echo "OK" || echo "KO"
}

check_first_day_is_today(){
    current_month=$(date +%m)
    next_week=$(date -d"now - 1 week" +%m)
    [[ "$current_month" != "$next_week" ]] && echo "OK" || echo "KO"
}

check_now_is_time() {
    start_time_string=$1
    end_time_string=$2
    [[ $(date -d"$start_time_string" +%s) -le $(date +%s) ]] &&  [[ $(date -d"$end_time_string" +%s) -ge $(date +%s) ]] && echo "OK" || echo "KO"
}


while getopts "e:k:r:s:w:" opt
do
    case $opt in
        e)
         end_time="$OPTARG"
         ;;
        k)
          keyword="$OPTARG"
          ;;
        r)
          request_day="$OPTARG"
          ;;
        s)
          start_time="$OPTARG"
          ;;
        w)
          weekday_today="$OPTARG"
          ;;
    esac
done

[[ "$(check_day_is_today ${request_day} ${weekday_today} )" == "KO" ]] && stop "no"
if [ ! -z "$keyword" ]
then
    if [ "$keyword" == "last" ]
    then
        [[ "$(check_last_day_is_today)" == "KO" ]] && stop "no"
    fi
    if [ "$keyword" == "first" ]
    then
        [[ "$(check_first_day_is_today)" == "KO" ]] && stop "no"
    fi
fi
[[ "$(check_now_is_time ${start_time} ${end_time})" == "KO" ]] && stop "no"
stop "yes"