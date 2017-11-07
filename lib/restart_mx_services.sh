#!/bin/bash

### "service" parameter is optional.

set -x

imail_user=$1
imail_host=$2
owm_common_root=$3
service="$4"

ssh -o BatchMode=yes ${imail_user}@${imail_host} "export JAVA_HOME=$CP_RUNTIME_JAVA_HOME ; ${owm_common_root}/bin/imservctrl killStart $service"

