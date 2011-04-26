#!/bin/bash

# Edit this accordingly
PROJ_DIR="/Users/danielgf/dev/libpaxos2-trunk/tests" 


if [[ ! -e $PROJ_DIR ]]; then
    echo "You must edit the PROJ_DIR variable in this script!"
    exit 1;
fi

KEEP_XTERM_OPEN="echo \"press enter to close\"; read";

rm -rf /tmp/acceptor_*;
echo "Starting the acceptors"
xterm -geometry 80x24+60+10 -e bash -c "$PROJ_DIR/example_acceptor 0; $KEEP_XTERM_OPEN" &
xterm -geometry 80x24+450+10 -e bash -c "$PROJ_DIR/example_acceptor 1; $KEEP_XTERM_OPEN" &
xterm -geometry 80x24+850+10 -e bash -c "$PROJ_DIR/example_acceptor 2; $KEEP_XTERM_OPEN" &

xterm -geometry 80x24+650+300 -e bash -c "$PROJ_DIR/example_learner; $KEEP_XTERM_OPEN" &
xterm -geometry 80x24+850+300 -e bash -c "$PROJ_DIR/tp_monitor; $KEEP_XTERM_OPEN" &
sleep 3;

xterm -geometry 80x24+60+300 -e bash -c "$PROJ_DIR/example_proposer 0; $KEEP_XTERM_OPEN" &
sleep 2;

xterm -geometry 80x8+60+600 -e bash -c "$PROJ_DIR/benchmark_client -m 8 -M 8 -c 100 -s 10; $KEEP_XTERM_OPEN" &

echo "Press enter to send the kill signal"
read
killall -INT example_acceptor example_proposer example_learner benchmark_client tp_monitor
