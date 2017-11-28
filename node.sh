#!/bin/bash

# runs app.js file from the same directory
# Usage:
# - ./node-docker-spinup.sh i ${PACKAGE} : install package
# - ./node-docker-spinup.sh r            : run script app.js; supports command line arguments

IMAGE="9.2.0-alpine"
PORTS="-p 8080:8080/tcp -p 8080:8080/udp"
CFG="package.json"
APP="app.js"
APP_DEMO="0"
if [ ! -f ${APP} ]; then
	echo "console.log('Hello there from node. Args:'); console.log(process.argv);" > ${APP}
	APP_DEMO="1"
fi

# save mode and gather args
mode=$1
shift
args=""
for var in "$@"
do
	args="${args} ${var}"
done

# set npm command
cmd="-v"
if [ -z "${mode}" ]; then
	echo "Mode not set"
	exit 1
else
	case ${mode} in
		"i") # install package
			cmd="install --silent ${args}"
			;;
		"r") # run
			# save args and pass to node script
			cmd="start --silent ${args}"
			;;
	esac
fi

echo "{ \"scripts\": { \"start\": \"node app.js\" } }" > ${CFG}
docker run --rm -w /app -v $(pwd):/app ${PORTS} "node:${IMAGE}" npm ${cmd}
rm ${CFG}

if [ "${mode}" == "r" ] && [ "${APP_DEMO}" == "1" ]; then
	rm ${APP}
fi

