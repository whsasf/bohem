#!/bin/bash

if [ ! -f "/home/whsasf/workspace/bohem/etc/bohem.conf" ]
then
	# this could come up if the user has _bohem_self linked from somewhere
	printf "bohem $_bohem_version Fatal ERROR:\n"
	printf "\tCould not find ${_bohem_dir}/etc/bohem.conf. Check the installation.\n\n"

else
  echo $_bohem_version
fi

echo $$