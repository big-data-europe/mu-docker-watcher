#!/usr/bin/env bash
containers=()

#/ Usage:
#/ Description:
#/ Examples:
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() {
  echo "Cleanup logic here"
  exit 0
}


# Searches for a tuple in an array. There is a need to use then
# external containers array instead of passing it as a parameter because
# in bash arrays can't be passed as is, but the whole list of elements.
containsTuple() {
  local cont="$1"
  local iface="$2"

  # When array is empty.
  if [ ${#containers[@]} == 0 ]; then
    return 1
  fi
  for ((i=0; i<${#containers[@]}; i+=2)); do
    if [ $cont == "${containers[i]}" ] && [ $iface == "${containers[i+1]}" ]; then
      return 0
    fi
  done
  return 1
}

mkdir -p data/pcap


#####################
# Start of the script
#####################
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    # trap cleanup EXIT

    while :
    do
      info "Watch the wlp3s0 interface"
      containsTuple "testcontainer" "wlp3s0"

      if [ $? != 0 ]; then
        info "Watching for wlp3s0"
        tcpdump -i wlp3s0 -s 0 -w "data/pcap/webcat_default_br-1234_%Y-%m-%d_%H:%M:%S.pcap" &

        containers+=("testcontainer")
        containers+=("wlp3s0")
      fi


      info "Watch the br-34ccce3029a6 interface"
      containsTuple "testcontainer" "br-34ccce3029a6"

      if [ $? != 0 ]; then
        info "Watching for br-34ccce3029a6"
        tcpdump -i br-34ccce3029a6 -s 0 -w "data/pcap/webcat_default_br-5678_%Y-%m-%d_%H:%M:%S.pcap" &

        containers+=("testcontainer")
        containers+=("br-34ccce3029a6")
      fi


      sleep 3
    done
fi