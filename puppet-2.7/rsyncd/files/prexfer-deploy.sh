#!/bin/bash

# Pre transfer script for deployments
#

BASENAME=`basename  $0 `
LOCKFILE="/var/run/deploy/.deploy.lock"
LOG=" logger -p local0.info -t ${BASENAME}"
TO_DEPLOY_ARTIFACTS=`ls -d -1 ${RSYNC_MODULE_PATH}/*`

if [ -f ${LOCKFILE} ]; then
	echo "Error. Deploy in progress: ${LOCKFILE}" | ${LOG}
	exit 1
fi

for ARTIFACT in ${TO_DEPLOY_ARTIFACTS}; do
	if ! [ -f ${ARTIFACT} ]; then
		echo "Error: Artifact ${ARTIFACT} must not be deployed in this server" | ${LOG}
		exit 1
	fi
done	

echo "Prexfer-deploy succesfully" | ${LOG}
exit 0
