#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

export NODE_HOME=`echo /opt/node-*`
echo using ${NODE_HOME}
export NODE_PATH=${NODE_HOME}/lib/node_modules
export PATH=${PATH}:${NODE_HOME}/bin
export LD_LIBRARY_PATH=${NODE_HOME}/lib
export C_INCLUDE_PATH=${NODE_HOME}/include
export CPLUS_INCLUDE_PATH=${NODE_HOME}/include

node -v

$SCRIPTPATH/shadowsocks-manager/bin/ssmgr -c $SCRIPTPATH/s_manager.yml
