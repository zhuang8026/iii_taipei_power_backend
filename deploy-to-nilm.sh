#!/usr/bin/env bash

export TARGET_SERVERS=("125.227.38.81" "125.227.38.81" "211.23.79.239" "211.23.68.180")
export TARGET_SERVERS_NAMES=("ntpc0" "ntpc1" "ntpc2" "ntpc3")
export SSH_USERNAME="localadmin"
export SSH_PORT="22"
export DEPLOY_PATH="/srv/NILM-Frontend/"

for((i=0; i<${#TARGET_SERVERS[@]}; i++))
do
    SERVER=${TARGET_SERVERS[i]}
    SERVER_NAMES=${TARGET_SERVERS_NAMES[i]}
    cd ./deployData/$SERVER_NAMES
    ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${SSH_USERNAME}@$SERVER "mkdir -p ${DEPLOY_PATH}/$SERVER_NAMES-backend/"
    rsync -av --delete -e "ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" ./dist/* ${SSH_USERNAME}@${SERVER}:${DEPLOY_PATH}/$SERVER_NAMES-backend/;
    cd ../../
done
