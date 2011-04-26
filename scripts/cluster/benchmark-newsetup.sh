#!/bin/bash
thisrun=$9

#based on cluster/benchmark_simple.sh and common/auto_launch.sh


# Default logging dir
LOGDIR="$HOME/libpaxos2/paxos_logs"
BASEDIR="$HOME/libpaxos2/tests"

# Nodes
NSR="ybcn-svr13" # Server
NCL="ybcn-svr13" # Clients
NA0="ybcn-svr9"  # Acceptors
NA1="ybcn-svr10"
NA2="ybcn-svr11"
NP0="ybcn-svr9"  # Proposer


function init_check () {
        local DIR=`pwd`
        if [[ `basename $DIR` != "cluster" ]]; then
                echo "Please run from scripts/cluster/"
                exit;
        fi

        if [[ `hostname -s` != $NSR ]]; then
                echo "Please run from $NSR"
                exit;
        fi

}

# function launch_detach_acceptor () {
#   local a_id=$1
#   local host=$2
#   local logfile="$LOGDIR/acceptor_$a_id"
# 
#   echo "Starting acceptor $a_id on host $host"
#   echo "(logs to: $logfile)"
#   ssh -t $host "$BASEDIR/acceptor_main -i $a_id &> $logfile &" &  
# }

function launch_background_acceptor () {
        local a_id=$1
        local host=$2
        local logfile="$LOGDIR/acceptor_$1_host_$2_run_$thisrun"

        echo "Starting acceptor $a_id on host $host"
        #echo "(logs to: $logfile)"
        #ssh $host "$BASEDIR/example_acceptor $a_id &> $logfile" &
        ssh $host $BASEDIR/launch_background.sh $logfile "$BASEDIR/example_acceptor $a_id" &
}

function launch_tp_monitor () {
        local host=$1
        local logfile="$LOGDIR/monitor_host_$1_run_$thisrun"

        echo "Starting monitor on host $host"
        #echo "(logs to: $logfile)"
        #ssh $host "$BASEDIR/tp_monitor &> $logfile" &           
        ssh $host $BASEDIR/launch_background.sh $logfile "$BASEDIR/tp_monitor" &           
}

function show_tp_log () {
    echo "*** Tail of tp_monitor log"
    echo "*** From: $LOGDIR/monitor.txt"
    ssh $NCL tail -n 20 $LOGDIR/monitor.txt
    echo
}

function launch_background_oracle () {
        local host=$1
        local logfile="$LOGDIR/oracle.txt"

        echo "Starting oracle on host $host"
        #echo "(logs to: $logfile)"
        #ssh $host "$BASEDIR/example_oracle &> $logfile" &
        ssh $host $BASEDIR/launch_background.sh $logfile "$BASEDIR/example_oracle" &
}

function launch_background_proposer () {
        local p_id=$1
        local host=$2
        local logfile="$LOGDIR/proposer_$p_id_host_$2_run_$thisrun"

        echo "Starting proposer $p_id on host $host"
        #echo "(logs to: $logfile)"
        #ssh $host "$BASEDIR/example_proposer $p_id &> $logfile" &
        ssh $host $BASEDIR/launch_background.sh $logfile "$BASEDIR/example_proposer $p_id" &
}

function show_proposer_log () {
    echo "*** Tail of proposer $1 log"
    echo "*** From: $LOGDIR/proposer_$1"
    tail -n 20 $LOGDIR/proposer_$1
    echo
}


function launch_background_client () {
        local bench_args=$1
        local host=$2
        local clientcount=$3
        local logfile="$LOGDIR/client_$3_host_$2_run_$thisrun"

        echo "Starting client $clientcount on host $host"
        #echo "(logs to: $logfile)"
        #ssh mpc@$host "$BASEDIR/benchmark_client $bench_args &> $logfile" &
        #$BASEDIR/benchmark_client $bench_args &
        ssh $host $BASEDIR/launch_background.sh $logfile $BASEDIR/benchmark_client $bench_args &
}

function launch_follow () {
        local cmd=$1
        local host=$2
        local logfile="$LOGDIR/follow_host_$2_run_$thisrun"

        echo "Executing: \"$cmd\" on host $host"
        #ssh -t mpc@$host "cd $BASEDIR; $cmd &> $logfile"
        cd $BASEDIR; /usr/bin/time -p $cmd &> $logfile
}

# function launch_background () {
#   local cmd=$1
#   local host=$2
#   
#   echo "Executing: \"$cmd\" on host $host"
#   echo "from $BASEDIR"
#   ssh $host "cd $BASEDIR && $cmd" &
# }

function remote_kill () {
        local prog=$1
        local host=$2

        echo "Killing $prog on host $host"
        ssh $host "killall -9 $prog"
}

function remote_kill_all () {
    local procnames="$1"

        nodenum=$NCL
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGINT $procnames"
        nodenum=$NA0
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGINT $procnames"
        nodenum=$NA1
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGINT $procnames"
        nodenum=$NA2
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGINT $procnames"
        nodenum=$NP0
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGINT $procnames"
}

function remote_kill_all_with_fire () {
    local procnames="$1"

        nodenum=$NCL
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGKILL $procnames"
        nodenum=$NA0
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGKILL $procnames"
        nodenum=$NA1
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGKILL $procnames"
        nodenum=$NA2
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGKILL $procnames"
        nodenum=$NP0
        echo "Killing on $nodenum"
        ssh -o "ConnectTimeout=10" "$nodenum" "killall -SIGKILL $procnames"
}

#main 



#use the script to kill servers and clients:
if [[ $1 == "kill" ]]; then
  echo killing
  remote_kill_all_with_fire "example_acceptor example_proposer benchmark_client tp_monitor example_oracle"
  exit;
fi



#use the script to clean the logs
if [[ $1 == "rmlogs" ]]; then
  echo removing the logs
  rm $LOGDIR/*
  ssh mpc@s1 "rm $LOGDIR/*"
  ssh mpc@s3 "rm $LOGDIR/*"
  ssh mpc@s4 "rm $LOGDIR/*"
  ssh mpc@s5 "rm $LOGDIR/*"
  exit;
fi


#use the script to copy all libpaxos2 files to all servers:
if [[ $1 == "install" ]]; then
  echo copying libpaxos2 to s1, s3, s4, s5
  cd $HOME
  tar czf libpaxos2.tgz  libpaxos2
  scp libpaxos2.tgz mpc@s1:
  scp libpaxos2.tgz mpc@s3:
  scp libpaxos2.tgz mpc@s4:
  scp libpaxos2.tgz mpc@s5:
  ssh s1 "tar xzf libpaxos2.tgz; rm libpaxos2.tgz"
  ssh s3 "tar xzf libpaxos2.tgz; rm libpaxos2.tgz"
  ssh s4 "tar xzf libpaxos2.tgz; rm libpaxos2.tgz"
  ssh s5 "tar xzf libpaxos2.tgz; rm libpaxos2.tgz"
  rm libpaxos2.tgz
  cd $BASEDIR
  exit;
fi


EXPECTED_ARGS=9
if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: benchmark_simple_mpc.sh numberClients submitNvaluesConcurrently MinValueSize MaxValueSize Duration submitTimeout printEveryNvalues saveLatencyEveryNvalues runId"
  exit 1
fi

#1 first argument is the number of clients; the rest are benchmark_client options (except last):
#2 -c N : submit N values concurrently  (default is 30)
#3 -m N : min value size is N bytes     (values sent are random between min and max)
#4 -M N : max value size is N bytes
#5 -d N : duration is N seconds         (duration of experiment; default is 40)
#6 -t N : submit timeout is N seconds   (timeout to resend; default is 10)
#7 -p N : print submit count every N values  (default is 10)
#8 -s N : saves a latency sample every N values sent  (default is 0)
#9 identification of the run



init_check


launch_background_acceptor 0 $NA0
sleep 1
launch_background_acceptor 1 $NA1
sleep 1
launch_background_acceptor 2 $NA2
sleep 1

launch_background_proposer 0 $NP0 
sleep 15

#launch_tp_monitor $NP0
#sleep 1

#launch_tp_monitor s5 
#sleep 1

if [ $1 -ge 2 ]; then 
        for (( i = 1; i < $1; i++ )); do
                CLIENT_ARGS="-m $3 -M $4 -t $6 -d $5 -c $2 -p $7"
                launch_background_client "$CLIENT_ARGS" $NCL $i
        done
fi

#next client is mandatory, previous are optional 
CLIENT_ARGS="-m $3 -M $4 -t $6 -d $5 -c $2 -p $7"
CLIENT_ARGS="$CLIENT_ARGS -s $8"
launch_follow "./benchmark_client $CLIENT_ARGS" $NCL

sleep 1

remote_kill_all "example_acceptor example_proposer benchmark_client tp_monitor example_oracle"
sleep 5
remote_kill_all_with_fire "example_acceptor example_proposer benchmark_client tp_monitor example_oracle"
echo
echo
echo
