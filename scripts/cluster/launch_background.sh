host=$1
cmd=$2
logfile=$3

ssh $host "$cmd" &> $logfile
