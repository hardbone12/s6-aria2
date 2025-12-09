#!/usr/bin/env bash
#
# Thanks for these projects sharing tracker lists.
# https://github.com/ngosang/trackerslist
# https://github.com/XIU2/TrackersListCollection
#

GREEN_FONT_PREFIX="\033[32m"
RED_FONT_PREFIX="\033[31m"
YELLOW_FONT_PREFIX="\033[1;33m"
FONT_COLOR_SUFFIX="\033[0m"
INFO="[${GREEN_FONT_PREFIX}INFO${FONT_COLOR_SUFFIX}]"
ERROR="[${RED_FONT_PREFIX}ERROR${FONT_COLOR_SUFFIX}]"
WARN="[${YELLOW_FONT_PREFIX}WARN${FONT_COLOR_SUFFIX}]"

ARIA2_CONF=${1:-/config/aria2.conf}
DOWNLOADER="curl -fsSL --connect-timeout 5 --max-time 10 --retry 2"

DEFAULT_TRACKER_URLS="
https://cf.trackerslist.com/all_aria2.txt,
https://cdn.jsdelivr.net/gh/ngosang/trackerslist@master/trackers_all.txt
"

DATE_TIME() {
    date +"%m/%d %H:%M:%S"
}

FETCH_FROM_URL() {
    local url="$1"
    local content
    content=$(${DOWNLOADER} "${url}" 2>/dev/null)
    if [[ $? -eq 0 && -n "${content}" ]]; then
        echo -e "$(DATE_TIME) ${INFO} Fetched: ${url}" >&2
        echo "${content}"
    else
        echo -e "$(DATE_TIME) ${WARN} Failed: ${url}" >&2
    fi
}

NORMALIZE_TRACKERS() {
    echo "$1" | tr ',' '\n' | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
        grep -E '^(udp|http|https|wss)://' | \
        sort -u
}

GET_TRACKERS() {
    local urls all_trackers=""
    
    urls="${DEFAULT_TRACKER_URLS}"
    [[ -n "${CUSTOM_TRACKER_URL}" ]] && urls="${urls},${CUSTOM_TRACKER_URL}"
    urls=$(echo "${urls}" | tr '\n' ',' | sed 's/,,*/,/g; s/^,//; s/,$//')
    
    echo -e "$(DATE_TIME) ${INFO} Fetching trackers..."
    
    IFS=',' read -ra URL_ARRAY <<< "${urls}"
    for url in "${URL_ARRAY[@]}"; do
        url=$(echo "${url}" | xargs)
        [[ -z "${url}" ]] && continue
        all_trackers+="$(FETCH_FROM_URL "${url}")"$'\n'
    done
    
    TRACKER_LIST=$(NORMALIZE_TRACKERS "${all_trackers}")
    
    if [[ -z "${TRACKER_LIST}" ]]; then
        echo -e "$(DATE_TIME) ${ERROR} No trackers fetched!"
        exit 1
    fi
    
    local count=$(echo "${TRACKER_LIST}" | wc -l)
    echo -e "$(DATE_TIME) ${INFO} Total unique trackers: ${count}"
    
    TRACKER=$(echo "${TRACKER_LIST}" | tr '\n' ',' | sed 's/,$//')
}

UPDATE_CONFIG() {
    echo -e "$(DATE_TIME) ${INFO} Updating config: ${ARIA2_CONF}"
    
    if [[ ! -f "${ARIA2_CONF}" ]]; then
        echo -e "$(DATE_TIME) ${ERROR} Config file not found!"
        exit 1
    fi
    
    grep -q "^bt-tracker=" "${ARIA2_CONF}" || echo "bt-tracker=" >> "${ARIA2_CONF}"
    sed -i "s@^\(bt-tracker=\).*@\1${TRACKER}@" "${ARIA2_CONF}"
    
    echo -e "$(DATE_TIME) ${INFO} Config file updated."
}

UPDATE_RPC() {
    local rpc_port rpc_secret rpc_address rpc_payload result
    
    rpc_port=$(grep "^rpc-listen-port=" "${ARIA2_CONF}" | cut -d= -f2-)
    rpc_secret=$(grep "^rpc-secret=" "${ARIA2_CONF}" | cut -d= -f2-)
    rpc_address="localhost:${rpc_port:-6800}/jsonrpc"
    
    if [[ -n "${rpc_secret}" ]]; then
        rpc_payload='{"jsonrpc":"2.0","method":"aria2.changeGlobalOption","id":"1","params":["token:'${rpc_secret}'",{"bt-tracker":"'${TRACKER}'"}]}'
    else
        rpc_payload='{"jsonrpc":"2.0","method":"aria2.changeGlobalOption","id":"1","params":[{"bt-tracker":"'${TRACKER}'"}]}'
    fi
    
    echo -e "$(DATE_TIME) ${INFO} Updating via RPC: ${rpc_address}"
    
    result=$(curl "${rpc_address}" -fsSd "${rpc_payload}" 2>/dev/null)
    
    if echo "${result}" | grep -q "OK"; then
        echo -e "$(DATE_TIME) ${INFO} RPC update successful."
    else
        echo -e "$(DATE_TIME) ${WARN} RPC update failed (Aria2 may not be running)."
    fi
}

command -v curl >/dev/null || {
    echo -e "$(DATE_TIME) ${ERROR} curl not installed."
    exit 1
}

GET_TRACKERS
UPDATE_CONFIG
UPDATE_RPC

exit 0
