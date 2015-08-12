#!/bin/sh
#Written by dave@thebarnums.com

#In addition to starting the couchbase process, we must start a script that will configure couchbase once it is up.
#That is done via 'myinit' by placing a link to the configuration script in /etc/my_init.d/

#Set a shutdown trap (run service_stop_couchbase.sh on container shutdown.)
trap "/root/bin/service_stop_couchbase.sh" SIGHUP SIGINT SIGTERM SIGSTOP SIGUSR1

## Start the couchbase process
exec /sbin/setuser couchbase /opt/couchbase/bin/couchbase-server >>/opt/couchbase/var/lib/couchbase/logs/start.log 2>&1

#Go to sleep (in order to capture focus) while the PID exists.
#SupervisorD requires the script to retain focus.
echo "sleeping while process runs"
sleep 10
while pgrep -u couchbase > /dev/null 2>&1; do
  sleep 10
done

