#!/bin/bash
LAST_SET_SPEED="-1"

while true; do
    CURRENT_TEMP=$(nvidia-settings -q=[gpu:0]/GPUCoreTemp | sed "s/.*: \(.*\)\..*/\1/;2q;d")
    echo "Current temp is: $CURRENT_TEMP"

    MAPPING_ARR=()
    while read line; do
        MAPPING_ARR+=("$line")
    done < /usr/bin/nvidia-fan-daemon-mapping.cfg

    FINAL_SPEED="-1"
    LAST_TEMP="0"
    LAST_SPEED="-1"
    LAST_DIFF="9999"
    for mapping in "${MAPPING_ARR[@]}"
    do
        IFS=':' read -ra VALS <<< "$mapping"
        MAP_TEMP=${VALS[0]}
        MAP_SPEED=${VALS[1]}

        DIFF=$(( $MAP_TEMP - $CURRENT_TEMP ))

        if [ ${MAP_TEMP} -eq ${CURRENT_TEMP} ]; then
            FINAL_SPEED=$MAP_SPEED
            break
        elif [ ${DIFF} -gt "0" -a ${DIFF} -gt ${LAST_DIFF} ]; then
            FINAL_SPEED=$(bc <<< "scale=2; ((($MAP_SPEED - $LAST_SPEED) / ($MAP_TEMP - $LAST_TEMP)) * ($CURRENT_TEMP - $LAST_TEMP)) + $LAST_SPEED")
            FINAL_SPEED=$(printf "%.0f" $FINAL_SPEED)
            break
        fi

        LAST_TEMP=$MAP_TEMP
        LAST_SPEED=$MAP_SPEED
        LAST_DIFF=$DIFF
    done

    if [ ${FINAL_SPEED} -eq "-1" ]; then
        if [ ${LAST_SPEED} -eq "-1" ]; then
            FINAL_SPEED="30"
        else
            FINAL_SPEED="100"
        fi
    fi

    if [ ${FINAL_SPEED} -ne ${LAST_SET_SPEED} ]; then
        echo "Setting GPU FAN speed to: $FINAL_SPEED"
        nvidia-settings -a GPUFanControlState=1 -a GPUTargetFanSpeed=$FINAL_SPEED
        LAST_SET_SPEED=$FINAL_SPEED
    fi
    sleep 4s
done
