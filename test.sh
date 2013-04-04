#!/bin/bash

if [ $# -eq 0 ] ; then
	tasks='asma asmb scanner parser ag codea codeb gesamt'
else
	tasks=$*
fi

echo 'Invoking abgabe.sh ...'

./abgabe.sh $tasks

for item in $tasks ; do
	/usr/ftp/pub/ubvl/test13/$item/test
	sleep 1
done
