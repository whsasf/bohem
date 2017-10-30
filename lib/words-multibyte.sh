#!/bin/bash

###
### This script prints out a random word, or if an integer parameter is specified, that number of words
###
### All words in this file have at least one character wider than 8-bits.
### None of these words are more than 3-bytes (16 bits).
###

tmpfile=.words$$.txt
cat > $tmpfile <<- _EOF
			햇빛
			규율
			고마워요
			한국어
			울란바따르
			Вдруг
			Ви́хри
			дитя́
			заво́ет
			запла́чет
			запозда́лый
			застучи́
			зашуми́т
			зверь
			как
			кро́вле
			крутя́
			нам
			обветша́лой
			око́шко
			она́
			пу́тник
			сне́жные
			соло́мой
			廣武將軍碑
			龍藏寺碑
			蘇孝慈墓誌
			董美人墓誌
			九成宮醴泉銘
			教科書体
			仿宋體
			颜真卿
			اليونانيه
			الجيريجى
			الإغريقى
			لغه
			هيندو
			اوروبيه
			اتطور
			اليونانى
			الحديث
			النموذجى
			المناطق
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

