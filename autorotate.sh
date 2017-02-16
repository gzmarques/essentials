#!/bin/sh
# Auto rotate screen based on device orientation
timestamp() {
  # get unix time
    DATE=$(date +%s)
    # convert unix time to human readable format
    DATE_HREAD=$(date -d @$DATE +%Y/%m/%d_%H:%M:%S)
    return $DATE_HREAD
}
rtcwake -u -s 1 -m mem
# Receives input from monitor-sensor (part of iio-sensor-proxy package)
# Screen orientation and launcher location is set based upon accelerometer position
# Launcher will be on the left in a landscape orientation and on the bottom in a portrait orientation
# This script should be added to startup applications for the user

# Clear sensor.log so it doesn't get too long over time
#echo "$(timestamp) ** Message: Accelerometer orientation changed: normal"
> sensor.log
printf("initializated") > launcher.log
# Launch monitor-sensor and store the output in a variable that can be parsed by the rest of the script
echo "$(timestamp)" && monitor-sensor >> sensor.log 2>&1 &

# Parse output or monitor sensor to get the new orientation whenever the log file is updated
# Possibles are: normal, bottom-up, right-up, left-up
# Light data will be ignored
while inotifywait -e modify sensor.log; do
# Read the last line that was added to the file and get the orientation
ORIENTATION=$(tail -n 1000 sensor.log | grep 'Accelerometer orientation changed' | tail -n 1 | grep -oE '[^ ]+$')

# Set the actions to be taken for each possible orientation
case "$ORIENTATION" in
normal)
xrandr --output eDP1 --rotate normal && gsettings set com.canonical.Unity.Launcher launcher-position Left ;;
bottom-up)
xrandr --output eDP1 --rotate inverted && gsettings set com.canonical.Unity.Launcher launcher-position Left ;;
right-up)
xrandr --output eDP1 --rotate right && gsettings set com.canonical.Unity.Launcher launcher-position Bottom ;;
left-up)
xrandr --output eDP1 --rotate left && gsettings set com.canonical.Unity.Launcher launcher-position Bottom ;;
undefined)
xrandr --output eDP1 --rotate left && gsettings set com.canonical.Unity.Launcher launcher-position Left ;;
esac

case "$ORIENTATION" in
normal)
gsettings set com.canonical.Unity.Launcher launcher-position Left && echo 'launcher left' >> launcher.log ;;
bottom-up)
gsettings set com.canonical.Unity.Launcher launcher-position Left && echo 'launcher left' >> launcher.log ;;
right-up)
gsettings set com.canonical.Unity.Launcher launcher-position Bottom && echo 'launcher bottom' >> launcher.log ;;
left-up)
gsettings set com.canonical.Unity.Launcher launcher-position Bottom && echo 'launcher bottom' >> launcher.log ;;
undefined)
gsettings set com.canonical.Unity.Launcher launcher-position Left && echo 'launcher left' >> launcher.log ;;
esac
done
