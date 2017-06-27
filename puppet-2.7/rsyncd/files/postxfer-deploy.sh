#!/bin/bash

BASENAME=`basename  $0 `
LOCKFILE="/var/run/deploy/.deploy.lock"
LOG=" logger -p local0.info -t ${BASENAME}"
TO_DEPLOY_ARTIFACTS=`find ${RSYNC_MODULE_PATH} -type f`

touch ${LOCKFILE}

for ARTIFACT in ${TO_DEPLOY_ARTIFACTS}; do 
	/root/deploy.sh ${ARTIFACT} | ${LOG}
	if [ $? -ne 0 ]; then
		echo "Postxfer-deploy ${ARTIFACT} fails. Exiting..." | ${LOG}
		rm ${LOCKFILE}
		exit 1
	fi
done


echo "Postxfer-deploy ${ARTIFACT} succesfully" | ${LOG}
rm ${RSYNC_MODULE_PATH}/*
rm ${LOCKFILE}
exit 0 
