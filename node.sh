#!/bin/bash

# runs app.js file from the same directory
# Usage:
# - ./node-docker-spinup.sh i ${PACKAGE} : install package
# - ./node-docker-spinup.sh r            : run script app.js; supports command line arguments

IMAGE="9.2.0-alpine"
PORTS="8080:8080"
CFG="package.json"
APP="app.js"
APP_DEMO="0"
if [ ! -f ${APP} ]; then
	echo "console.log('Hello there from node. Args:'); console.log(process.argv);" > ${APP}
	APP_DEMO="1"
fi

mode=$1
cmd="-v"

if [ -z "${mode}" ]; then
	echo "Mode not set"
	exit 1
else
	case ${mode} in
		"i") # install package
			cmd="install $2 --save --silent"
			;;
		"r") # run
			# save args and pass to node script
			shift
			args=""
			for var in "$@"
			do
				args="${args} ${var}"
			done

			cmd="start --silent ${args}"
			;;
	esac
fi

echo "{ \"scripts\": { \"start\": \"node app.js\" } }" > ${CFG}
docker run --rm -w /app -v $(pwd):/app -p "${PORTS}" "node:${IMAGE}" npm ${cmd}
rm ${CFG}

if [ "${mode}" == "r" ] && [ "${APP_DEMO}" == "1" ]; then
	rm ${APP}
fi

