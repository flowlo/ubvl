#!/bin/bash

if [ $# -eq 0 ] ; then
        tasks='asma asmb scanner parser ag codea codeb gesamt'
else
        tasks=$*
fi

for item in $(git --git-dir=$(dirname $(realpath $0))/.git ls-tree -r --full-name --name-only master $tasks) ; do
	mkdir -p $(dirname $HOME/abgabe/$item)
	rsync -i $(dirname $(realpath $0))/$item $HOME/abgabe/$item
done
