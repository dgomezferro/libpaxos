#!/bin/bash

DIR=`pwd`
if [[ `basename $DIR` != "cluster" ]]; then
    echo "Please run from scripts/cluster/"
    exit;
fi
source ../common/auto_launch.sh;

#init_check

set_log_dir "$HOME/paxos_logs"
set_basedir "$HOME/libpaxos2/tests"

launch_background_acceptor 0 ybcn-svr13
launch_background_acceptor 1 ybcn-svr10
launch_background_acceptor 2 ybcn-svr11

launch_tp_monitor ybcn-svr13
sleep 4

launch_background_proposer 0 ybcn-svr13
sleep 5

CLIENT_ARGS="-m 20 -M 2000 -t 2 -d 60 -c 5 -p 500"
#launch_background_client "$CLIENT_ARGS" node08
#launch_background_client "$CLIENT_ARGS" node09
# launch_background_client "$CLIENT_ARGS" node10
#launch_background_client "$CLIENT_ARGS" node11
#launch_background_client "$CLIENT_ARGS" node12

CLIENT_ARGS="$CLIENT_ARGS -s 300"
launch_follow "./benchmark_client $CLIENT_ARGS" ybcn-svr9
sleep 2

remote_kill_all "example_acceptor example_proposer benchmark_client tp_monitor example_oracle"

show_proposer_log 0
show_tp_log
