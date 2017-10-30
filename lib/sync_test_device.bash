#!/bin/bash
set -x

## This scripts expects env. variables as follows:
##
## for test_device.selenium script:
## ................................
## DEVICE_NAME         As it appears in the drop-down in the UI
## DEVICE_MANUFACTURER As it appears in the device added page
##
##
## for this script itself:
## .......................
## DEVICE_MODEL        As it appears in the device added page
## DEVICE_XML_MODEL    As it appears in the server xml mappings file
##
##############################################################


##
## change nothing below this line
## 
export domain=device.$$.dom

if [ "$SYNC1_HOST" = "nohost.invalid" ]; then
	log_skip "Sync server not installed"
	exit 0
fi

##test_device.selenium --- the UI is too unreliable to test.


## Looking for the mappings within the mappings file for a particular device
## manufacturer: DEVICE_MANUFACTURER
## model:        DEVICE_XML_MODEL

DEVICES_MAPPINGS_NAME=pab_vcard_map.xml
DEVICES_MAPPINGS_LOCAL=../${DEVICES_MAPPINGS_NAME}
DEVICES_MAPPINGS_REMOTE=${SYNC1_INSTALL}/syncml/bin/${DEVICES_MAPPINGS_NAME}

if [ ! -f ${DEVICES_MAPPINGS_LOCAL} ];then
  echo "Need to get a remote file ${DEVICES_MAPPINGS_REMOTE}"
  #scp -v -o BatchMode=yes root@${SYNC1_HOST} ${DEVICES_MAPPINGS_REMOTE} . 2>/dev/null
  scp -o BatchMode=yes root@${SYNC1_HOST}:${DEVICES_MAPPINGS_REMOTE} ${DEVICES_MAPPINGS_LOCAL}
  if [ ! -f ${DEVICES_MAPPINGS_LOCAL} ];then
    log_fail "Getting a file ${DEVICES_MAPPINGS_REMOTE} FAILED"
    exit 0
  fi
else
  echo "Found a local copy ${DEVICES_MAPPINGS_LOCAL} of a remote file ${DEVICES_MAPPINGS_REMOTE}"
fi

eval "awk 'BEGIN { inMapSection = sectionStart = sectionEnd = mfg = model = phoneBackup = counter = 0;"\
"  mfgString = _mfgString = modelString = _modelString = \"\";"\
"}"\
"{"\
"  if ( index( toupper(\$0), \"<MAP>\" ) ) {"\
"    sectionStart++;"\
"    inMapSection = 1;"\
"    mfg = model = phoneBackup = 0;"\
"    _mfgString = _modelString = \"\";"\
"  }"\
"  else if ( inMapSection && index( toupper(\$0), \"<MFG \" ) && match( \$0, \".*\\\""${DEVICE_MANUFACTURER}"\\\".*\" ) ) {"\
"    mfg = 1;"\
"    _mfgString = \"[\" NR \"]\" \$0;"\
"  }"\
"  else if ( inMapSection && index( toupper(\$0), \"<MODEL \" ) && match( \$0, \".*\\\""${DEVICE_XML_MODEL}"\\\".*\" ) ) {"\
"    if ( mfg ) {"\
"      model = 1;"\
"      _modelString = \"[\" NR \"]\" \$0;"\
"    } else mfg = 0"\
"  }"\
"  else if ( inMapSection && match( toupper(\$0), \"<TYPE *NAME *= *\\\"PHONEBACKUP\\\".*/>\" ) ) {"\
"    phoneBackup = 1;"\
"    mfg = model = phoneBackup = 0;"\
"    _mfgString = _modelString = \"\";"\
"  }"\
"  else if ( inMapSection && index( toupper(\$0), \"</MAP>\" ) ) {"\
"    sectionEnd++;"\
"    inMapSection--;"\
"    if ( mfg && model && phoneBackup ) {"\
"      mfg = model = phoneBackup = 0;"\
"      _mfgString = _modelString = \"\";"\
"    }"\
"    else if ( mfg && model ) {"\
"      if ( !counter ) {"\
"        mfgString = _mfgString;"\
"        modelString = _modelString;"\
"      } else {"\
"        mfgString = mfgString \", \" _mfgString;"\
"        modelString = modelString \", \" _modelString;"\
"      }"\
"      counter++;"\
"    }"\
"    else {"\
"      mfg = model = phoneBackup = 0;"\
"      _mfgString = _modelString = \"\";"\
"    } "\
"  }"\
"}"\
"END {"\
"  print \"mfgString = \" mfgString \"\\nmodelString = \" modelString \"\\ncounter = \" counter;"\
"  if ( counter != 1 ) exit 2;"\
"}' ${DEVICES_MAPPINGS_LOCAL}" \
&& log_pass "mfg:'${DEVICE_MANUFACTURER}' model:'${DEVICE_XML_MODEL}' Mappings exist" \
|| log_fail "mfg:'${DEVICE_MANUFACTURER}' model:'${DEVICE_XML_MODEL}' Mappings DON'T exist" 

exit 0
