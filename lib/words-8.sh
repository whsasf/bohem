#!/bin/bash

###
### This script prints out a random word, or if an integer parameter is specified, that number of words
###
### All words in this file have at least one 8-bit character, but nothing wider.
###

tmpfile=.words$$.txt
cat > $tmpfile <<- _EOF
			año
			combustão
			cómo
			cuándo
			cuántos
			cumpleaños
			démarrer
			diás
			dónde
			espontânea
			felíz
			frío
			glück
			grüne
			horrível
			irmã
			kalschnäuziger
			lástima
			mañana
			não
			nasenlöcher
			natürlich
			número
			otoño
			père
			plaît
			qué
			quién
			ratón
			relámpago
			schön
			selbstenzündung
			solitária
			täglich
			tão
			téléphonique
			tschüß
			última
			weiß
			_EOF

words=`cat $tmpfile`
count=`echo $words | wc -w`
rm $tmpfile

if [ "$1" != "" ]; then
	num=$1
else
	num=1
fi

while [ $num -gt 0 ]
do
	id=$((RANDOM % count + 1))
	word=`echo $words | cut -f $id -d ' '`
	result="$result $word"
	num=$((num - 1))
done
echo $result

