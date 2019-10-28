#!/bin/sh
# This file is part of the jetson_stats package (https://github.com/rbonghi/jetson_stats or http://rnext.it).
# Copyright (c) 2019 Raffaello Bonghi.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Author: Raffaello Bonghi <raffaello@rnext.it>

# Path folders
JETSON_STATS_FOLDER=/opt/jetson_stats
JETSON_FAN_CONFIG="$JETSON_STATS_FOLDER/fan_config"

set_fan_speed()
{
    local FAN_PATH=$1
    local FAN_TYPE=$(sed '1q;d' $JETSON_FAN_CONFIG)
    if [ ! -z "$FAN_TYPE" ] ; then
        echo "Set fan: $FAN_TYPE"
        if [ "$FAN_TYPE" = "AUTO" ] ; then
            echo "1" > "$FAN_PATH/temp_control"
        elif [ "$FAN_TYPE" = "MANUAL" ] ; then
            echo "0" > "$FAN_PATH/temp_control"
        fi
        # Set speed only if FAN_TYPE is not JC    
        if [ $FAN_TYPE != "JC" ] ; then
            # Load speed fan
            local FAN_SPEED=$(sed '2q;d' $JETSON_FAN_CONFIG)
            # Setup fan speed
            if [ ! -z "$FAN_SPEED" ] ; then
                echo "Set fan speed: $FAN_SPEED"
                # Set fan speed
                if [ -f "$FAN_PATH/target_pwm" ] ; then
                    echo "$FAN_SPEED" > "$FAN_PATH/target_pwm"
                fi
            fi
        fi
    fi
}

status()
{
    # Read fan type
    local FAN_TYPE=$(sed '1q;d' $JETSON_FAN_CONFIG)
    if [ ! -z "$FAN_TYPE" ] ; then
        echo "Fan type: $FAN_TYPE"
    fi
    # Read fan speed
    local FAN_SPEED=$(sed '2q;d' $JETSON_FAN_CONFIG)
    if [ ! -z "$FAN_SPEED" ] ; then
        echo "Fan speed: $FAN_SPEED"
    fi
    exit 0
}

main()
{
    if [ $# -eq 0 ] ; then
        # Setup fan speed and type control
        if [ -d "/sys/kernel/debug/tegra_fan" ] ; then
            set_fan_speed "/sys/kernel/debug/tegra_fan"
        fi
        if [ -d "/sys/devices/pwm-fan" ] ; then
            set_fan_speed "/sys/devices/pwm-fan"
        fi
        exit 0
    fi

    case "$1" in 
        status)
            status
            ;;
        *)
            echo "Usage: $0 [options]"
            echo "  options,"
            echo "  status     | Show the status of the system"
    esac
}

main $@
exit 0

#EOF