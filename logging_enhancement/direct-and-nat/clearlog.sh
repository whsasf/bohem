#!/bin/bash
function clearlog()
	{
		for i in `find . -name "*.[A-Za-z]*"`
		do cat /dev/null >$i
		done
  }
ssh root@172.26.202.87 "su - imail2 -c \"clearlog\""
