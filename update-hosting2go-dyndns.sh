#!/bin/sh

BESTELCODE="$1"

WANIP=`dig +short myip.opendns.com @resolver1.opendns.com`
OLDWANIP=`cat wanip`

if [ $WANIP = "$OLDWANIP" ]
then
  echo "wan ip hasn't changed, exiting."
  exit 0
fi

echo "Old wan ip: $OLDWANIP"
echo "Current wan ip: $WANIP"

echo "Getting session with hosting2go"

GETSESSIONIDCMD="curl 'https://klant.hosting2go.nl/helpdesk/?action=check' -H 'Origin: https://klant.hosting2go.nl' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/53.0.2785.143 Chrome/53.0.2785.143 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://klant.hosting2go.nl/helpdesk/?' -H 'Connection: keep-alive' --data 'c=$BESTELCODE&S=Inloggen&js_support=J' --compressed -s -D - | awk '/Location: (.*)/ {print \$2}' | sed 's/.*dc=//'"

SESSIONID=`eval $GETSESSIONIDCMD | awk '{\$1=\$1};1'`
#SESSIONID="assaddsa"

echo "session id: $SESSIONID"

echo "Setting ip to $WANIP"

SETIPCMD="curl -v 'https://klant.hosting2go.nl/helpdesk/?action=editrecord&dc=$SESSIONID&record=a&id=959956' -H 'Origin: https://klant.hosting2go.nl' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/53.0.2785.143 Chrome/53.0.2785.143 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://klant.hosting2go.nl/helpdesk/?action=dns-a&dc=$SESSIONID&id=959956' -H 'Connection: keep-alive' --data 'host=thuis&destination=$WANIP' --compressed"

echo $SETIPCMD

#eval "$SETIPCMD"

# Save wan ip to file
echo $WANIP > wanip

exit 0
