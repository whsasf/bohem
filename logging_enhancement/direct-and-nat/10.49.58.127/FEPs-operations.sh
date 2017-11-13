#!/bin/bash
#IMAP operations
. imap-operations.sh

#SMTP operations
. smtp-operations.sh

#POP operations
. pop-operations.sh

#judge behins

#imap
target_imap="10.37.2.214"
tar1="fromhost=${target_imap}:fromport="
cimap=`grep $tar1 imap-operations.log |wc -l`
echo -e "\n\n1- Counts for "fromhost=:fromport=" for IMAP is $cimap \n"
if (( $cimap == 180 ))
then
  echo -ne "\033[32m#####Logging enhancement in Direct mode for IMAP is ok!!##### \033[0m\n\n"
else
  echo -ne "\033[31m#####Logging enhancement in Direct mode for IMAP is not ok!!##### \033[0m\n\n"
fi
#smtp-1
target_mta="10.37.2.214"
tar3="fromhost=${target_mta}:fromport="
cmta1=`grep $tar3 smtp-operations.log|wc -l`
#echo $cmta1
#smtp-2
tar4="fromhost=\[${target_mta}\]:fromport="
cmta2=`grep $tar4 smtp-operations.log| wc -l`
#echo $cmta2
let cmta=cmta1+cmta2
echo -e "\n\n3- Counts for "fromhost=:fromport=" for SMTP is $cmta \n"
if (( $cmta == 100 ))
then
  echo -ne "\033[32m#####Logging enhancement in Direct mode for SMTP is ok!!##### \033[0m\n\n"
else
  echo -ne "\033[31m#####Logging enhancement in Direct mode for SMTP is not ok!!##### \033[0m\n\n"
fi
#pop
target_pop="10.37.2.214"
tar2="fromhost=${target_pop}:fromport="
cpop=`grep $tar2 pop-operations.log |wc -l`
echo -e "\n\n2- counts for "fromhost=:fromport=" for POP is $cpop \n"
if (( $cpop == 60 ))
then
  echo -ne "\033[32m#####Logging enhancement in Direct mode for POP is ok!!##### \033[0m\n\n"
else
  echo -ne "\033[31m#####Logging enhancement in Direct mode for POP is not ok!!##### \033[0m\n\n"
fi
