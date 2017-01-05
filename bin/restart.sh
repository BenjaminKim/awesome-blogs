#!/bin/bash
SCRIPT_DIR=`dirname $0`
APP_HOME=$SCRIPT_DIR/..
bundle exec pumactl -S "$APP_HOME/../../shared/tmp/pids/puma.state" phased-restart