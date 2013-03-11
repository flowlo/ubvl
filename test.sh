#!/usr/bin/env bash
shopt -s nullglob

for i in test/*.0 ; do
	./ag/ag < $i &> $i.out
	if [ "$?" -eq "0" ] ; then
		tput setaf 2
		echo Grammar passed test \'$(basename $i)\'!
		tput sgr0
	else
		tput setaf 1
		echo Grammar failed test \'$(basename $i)\':
		tput sgr0
		cat $i.out
	fi
	./parser/parser < $i 2>1 > $i.out
	if [ "$?" -eq "0" ] ; then
		tput setaf 2
		echo Parser passed test \'$(basename $i)\'!
		tput sgr0
	else
		tput setaf 1
		echo Parser failed test \'$(basename $i)\':
		tput sgr0
		cat $i.out
	fi
	./scanner/scanner < $i 2>1 > $i.out
	if [ "$?" -eq "0" ] ; then
		tput setaf 2
		echo Scanner passed test \'$(basename $i)\'!
		tput sgr0
	else
		tput setaf 1
		echo Scanner failed test \'$(basename $i)\':
		tput sgr0
		cat $i.out
	fi
done
exit
for i in test/*.1 ; do
	./scanner/scanner < $i > $i.out
	if [ "$?" -eq "1" ] ; then
		tput setaf 2
		echo Passed test \'$i\'!
		tput sgr0
	else
		tput setaf 1
		echo Failed test \'$i\':
		tput sgr0
		cat $i.out
	fi
done

for i in test/*.1 ; do
	./scanner/scanner < $i > $i.out
	if [ "$?" -eq "1" ] ; then
		tput setaf 2
		echo Passed test \'$i\'!
		tput sgr0
	else
		tput setaf 1
		echo Failed test \'$i\':
		tput sgr0
		cat $i.out
	fi
done

for i in test/*.1 ; do
	./scanner/scanner < $i > $i.out
	if [ "$?" -eq "1" ] ; then
		tput setaf 2
		echo Passed test \'$i\'!
		tput sgr0
	else
		tput setaf 1
		echo Failed test \'$i\':
		tput sgr0
		cat $i.out
	fi
done
