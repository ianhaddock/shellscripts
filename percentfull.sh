#!/bin/sh 
# hacked by Ian haddock August 23, 2014
# pass 2 variables - percent and length - and output a ASCII meter bar

## Input Variables 

PERCENT=$1
LENGTH=$2
i=0;
z=1000; 

## Do some math to get around floating point 

FIXEDPERFULL=$(echo "scale = 1; (10*$PERCENT)" | bc );
PERBAR=$(echo "scale = 1; (100/$LENGTH)*10" | bc );
FIXEDPERBAR=${PERBAR%.*};

## Output the bar

printf "[";

while [ $i -le $z ]
do
	if [ $FIXEDPERFULL -ge $i ]; then
		printf "=";
		i=$(($i+$FIXEDPERBAR));
	else	
		printf "_";
		i=$(($i+$FIXEDPERBAR));
	fi;
done
printf "] ";

echo $PERCENT"% Full";

