DAEMON=/usr/local/bin/thin
SCRIPT_NAME=/etc/puppet/config.ru
ROLE_NAME=puppetmasterd
DAEMON_OPTS="-D -l /var/log/puppet/thin.log -P /var/run/puppet/$ROLE_NAME.pid -e production --servers 3 --daemonize --socket /var/run/puppet/$ROLE_NAME.sock --chdir /etc/puppet/ --user puppet --group puppet -R $SCRIPT_NAME"
    
# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0
  
case "$1" in
  start)
        $DAEMON start $DAEMON_OPTS
        ;;
  stop)
        $DAEMON stop $DAEMON_OPTS
        ;;
  restart|force-reload|reload)
        $DAEMON restart $DAEMON_OPTS
        ;;
  *)
        echo "Usage: $0 {start|stop|restart}" >&2
        exit 3
        ;;
esac
    
: