
. /lib/lsb/init-functions

#. /etc/init.d/functions

STATUS_RUNNING=0
STATUS_DEAD=1
STATUS_DEAD_AND_LOCK=2
STATUS_NOT_RUNNING=3

ERROR_PROGRAM_NOT_INSTALLED=5

KAFKA_LOG_DIR=/var/log/kafka
KAFKA_CONF_DIR=/etc/kafka/conf
KAFKA_RUN_DIR=/var/run/kafka
KAFKA_HOME=/usr/lib/kafka
KAFKA_USER=kafka

KAFKA_CONF_FILE=${KAFKA_CONF_DIR}/server.properties
KAFKA_BASE_DIR=/usr/lib/kafka
KAFKA_EXEC_PATH=/usr/lib/kafka/bin
KAFKA_PID_FILE=${KAFKA_RUN_DIR}/kafka.pid

#export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$KAFKA_CONF_DIR/log4j.properties"
#export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"

# if there is an env script it should be run
# otherwise, kafka will take the defaults out of kafka-run-class.sh

if [ -e "$KAFKA_HOME/bin/kafka-env.sh" ]; then
	source $KAFKA_HOME/bin/kafka-env.sh
fi


start() {
  [ -x $exec ] || exit $ERROR_PROGRAM_NOT_INSTALLED

  checkstatus
  status=$?
  if [ "$status" -eq "$STATUS_RUNNING" ]; then
    exit 0
  fi

  log_success_msg "Starting $desc (kafka): "
  
#  /bin/su -s /bin/bash -c "/bin/bash -c 'echo \$\$ >${KAFKA_PID_FILE} && cd ${KAFKA_BASE_DIR} && exec ${KAFKA_EXEC_PATH}/kafka-run-class.sh\
#		daemon kafkaServer kafka.Kafka $KAFKA_CONF_FILE >> ${KAFKA_LOG_DIR}/kafka.out 2>&1' &" $KAFKA_USER
 /bin/su -s /bin/bash -c "/bin/bash -c 'echo \$\$ >${KAFKA_PID_FILE} && cd ${KAFKA_BASE_DIR} && exec ${KAFKA_EXEC_PATH}/kafka-run-class.sh\
         kafka.Kafka $KAFKA_CONF_FILE >> ${KAFKA_LOG_DIR}/kafka.out 2>&1' &" $KAFKA_USER
  RETVAL=$?
  #[ $RETVAL -eq 0 ] && touch $LOCKFILE
  return $RETVAL
}


stop() {
  if [ ! -e $KAFKA_PID_FILE ]; then
    log_failure_msg "Kafka broker is not running"
    exit 0
  fi

  log_success_msg "Stopping $desc (kafka): "

  KAFKA_PID=`cat $KAFKA_PID_FILE`
  if [ -n $KAFKA_PID ]; then
    kill -TERM ${KAFKA_PID} &>/dev/null
    for i in `seq 1 ${KAFKA_SHUTDOWN_TIMEOUT}` ; do
      kill -0 ${KAFKA_PID} &>/dev/null || break
      sleep 1
    done
    kill -KILL ${KAFKA_PID} &>/dev/null
  fi
  rm -f $LOCKFILE $KAFKA_PID_FILE
  return 0
}

restart() {
  stop
  start
}

checkstatus(){
  pidofproc -p $KAFKA_PID_FILE java > /dev/null
  status=$?

  case "$status" in
    $STATUS_RUNNING)
      log_success_msg "Kafka broker is running"
      ;;
    $STATUS_DEAD)
      log_failure_msg "Kafka broker is dead and pid file exists"
      ;;
    $STATUS_DEAD_AND_LOCK)
      log_failure_msg "Kafka broker is dead and lock file exists"
      ;;
    $STATUS_NOT_RUNNING)
      log_failure_msg "Kafka broker is not running"
      ;;
    *)
      log_failure_msg "Kafka broker status is unknown"
      ;;
  esac
  return $status
}

condrestart(){
  [ -e ${LOCKFILE} ] && restart || :
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    checkstatus
    ;;
  restart)
    restart
    ;;
  condrestart|try-restart)
    condrestart
    ;;
  *)
    echo $"BROKER_IDUsage: $0 {start|stop|status|restart|try-restart|condrestart}"
    exit 1
esac

exit $RETVAL
