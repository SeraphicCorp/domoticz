#!/bin/sh
# This script starts / stops camera
# First argument is ON or OFF
# Second argument is a list of camera id, comma separated. Example : 1 or 1,2
HTTP_PROTOCOL=https
# Domain name or IP
SYNOLOGY_HOST=synology.example.org
SYNOLOGY_PORT=5000
USER=user
PASSWORD=password

#Domain name or IP
SARAH_CLIENT_HOST=sarah.example.org
SARAH_CLIENT_PORT=8888

# Do not modify below
SWITCH_COMMAND=$1
CAMERA_LIST=$2
BASE_URI="$HTTP_PROTOCOL://$SYNOLOGY_HOST:$SYNOLOGY_PORT"
COMMAND=Enable
SARAH_COMMAND=Activation
COOKIE=`mktemp`
OPTIONS=
if [ $SWITCH_COMMAND = "OFF" ]
then

	COMMAND=Disable
	SARAH_COMMAND=Désactivation
fi
if [ $HTTP_PROTOCOL = "https" ]
then
	OPTIONS="--no-check-certificate"
fi
START_TIME=`date +%s`


wget -q -O- "http://$SARAH_CLIENT_HOST:$SARAH_CLIENT_PORT//?tts=$SARAH_COMMAND des cameras $CAMERA_LIST"

echo "Starting $0 : $COMMAND cameras $CAMERA_LIST"
echo "Authenticating" 
wget $OPTIONS -q -O- --keep-session-cookies --save-cookies $COOKIE "$BASE_URI/webapi/auth.cgi?api=SYNO.API.Auth&method=Login&session=SurveillanceStation&version=1&account=$USER&passwd=$PASSWORD"
echo "Sending command"
wget $OPTIONS -q -O- --load-cookies $COOKIE "$BASE_URI/webapi/entry.cgi?api=SYNO.SurveillanceStation.Camera&method=$COMMAND&version=3&cameraIds=$CAMERA_LIST"
echo "Disconnecting"
wget $OPTIONS -q -O- --load-cookies $COOKIE "$BASE_URI/webapi/auth.cgi?api=SYNO.API.Auth&method=Logout&version=1"
rm $COOKIE
END_TIME=`date +%s`
DURATION=`expr $END_TIME - $START_TIME`
echo "Ending $0 after $DURATION seconds"

wget -q -O- "http://$SARAH_CLIENT_HOST:$SARAH_CLIENT_PORT//?tts=$SARAH_COMMAND terminée"
