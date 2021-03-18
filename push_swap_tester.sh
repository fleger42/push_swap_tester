#!/bin/bash
RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

BOLDBLACK="\033[1m\033[30m"
BOLDRED="\033[1m\033[31m"
BOLDGREEN="\033[1m\033[32m"
BOLDYELLOW="\033[1m\033[33m"
BOLDBLUE="\033[1m\033[34m"
BOLDMAGENTA="\033[1m\033[35m"
BOLDCYAN="\033[1m\033[36m"
BOLDWHITE="\033[1m\033[37m"

function compil()
{
	printf $BOLDYELLOW"Compiling your push_swap and checker...$RESET\n"
	rm -f push_swap checker
	make re -C ../ >/dev/null 2>&1
	cp ../push_swap ../checker . >/dev/null 2>&1
	chmod 755 push_swap >/dev/null 2>&1
	chmod 755 checker >/dev/null 2>&1
	if [[ ! -e push_swap ]] || [[ ! -e checker ]]
	then
		printf $BOLDRED"Compiling failed ! Dont forget you have to clone this folder in the root of your project$RESET\n"
		exit 0
	fi
	printf $BOLDYELLOW"Compiling succesfull !$RESET\n"
	sleep 1
}

function basetest()
{
	if [[ "$1" -ge "$2" ]] || [[ "$1" -lt 0 ]] || [[ "$2" -lt 0 ]]
	then
		printf $BOLDRED"Wrong range of elements !$RESET\n"
		exit 0
	fi
	TOTAL=$WHITE
	NBR_ERROR=0
	let "NBR_TEST=$2 - $1"
	printf $BOLDYELLOW"Begin basic test of $BOLDRED$NBR_TEST$BOLDYELLOW random list from size $BOLDRED$1$BOLDYELLOW to $BOLDRED$2$BOLDYELLOW!$RESET\n"
	sleep 3
	for NBR in `seq $1 $2`;
	do
		INSTRUCT=0
		LIST=$(perl -e "use List::Util 'shuffle'; my @out = (shuffle 0..$NBR)[0..$NBR]; print \"@out\"")
		set -v
		ARG=${LIST[@]}; ./push_swap $ARG > output.txt ; cat output.txt | ./checker $ARG > result_checker.txt ; cat output.txt | ./srcs/ref_checker $ARG > result_checker2.txt
		INSTRUCT=$(wc -l < "output.txt")
		value=$(<result_checker.txt)
		value_2=$(<result_checker2.txt)
		if [[ "$value" != "$value_2" ]]
		then
			printf $BOLDRED"Your checker output $value instead of $value_2 !\nFail$RESET"" in $BOLDRED$INSTRUCT$RESET instructions with size = $TOTAL$NBR/$2$RESET\n"
			echo "LIST = "${LIST[@]}
			let "NBR_ERROR=NBR_ERROR+1"
		elif [[ $value = "KO" ]]
		then
			printf $BOLDRED"Fail$RESET"" in $BOLDRED$INSTRUCT$RESET instructions with size = $TOTAL$NBR/$2$RESET\n"
			echo "LIST = "${LIST[@]}
			let "NBR_ERROR=NBR_ERROR+1"
		else
			printf $BOLDGREEN"Success$RESET"" in $BOLDRED$INSTRUCT$RESET instructions with size = $TOTAL$NBR/$2$RESET\n"
			echo "LIST = "${LIST[@]}
			echo 
		fi
		let "NBR=NBR+1"
		if [[ $NBR = 100 ]] 
		then
			TOTAL=$GREEN
		fi
		if [[ $NBR = 200 ]] 
		then
			TOTAL=$BOLDCYAN
		fi
		if [[ $NBR = 300 ]] 
		then
			TOTAL=$MAGENTA
		fi
		if [[ $NBR = 400 ]] 
		then
			TOTAL=$YELLOW
		fi
		if [[ $NBR = 500 ]] 
		then
			TOTAL=$RED
		fi
	done
	if [[ $NBR_ERROR != 0 ]]
	then
		printf $BOLDRED"Failed !$RESET You got $BOLDRED$NBR_ERROR$RESET error in $BOLDCYAN$NBR_TEST$RESET test\n"
	else
		printf $BOLDGREEN"Well done !$RESET\n"
	fi
	sleep 3
}

function optitest()
{
	BIGGEST=0
	for NBR in `seq 1 100`;
	do
		LIST=$(perl -e "use List::Util 'shuffle'; my @out = (shuffle 0..$1)[0..$1]; print \"@out\"")
		set -v
		ARG=${LIST[@]}; ./push_swap $ARG > output.txt ; cat output.txt | ./checker $ARG > result_checker.txt ; cat output.txt | ./srcs/ref_checker $ARG > result_checker2.txt
		RESULT=$(wc -l < "output.txt")
		value=$(<result_checker.txt)
		value_2=$(<result_checker2.txt)
		if [[ "$value" != "$value_2" ]] || [[ $value = "KO" ]]
		then
			printf $BOLDRED"Failed optitest with list = $RESET$ARG\n"
			exit 1
		fi
		if [[ $BIGGEST -lt RESULT ]]
		then
			BIGGEST=$RESULT
		fi
		let "O_RET+=RESULT"
	done
	let "O_RET=$O_RET/100"
	sleep 3
}

function exec()
{
	rm output.txt
	rm result_checker.txt
	rm result_checker2.txt
	RESULT=0
	value=0
	value_2=0
	./push_swap $1 > /dev/null 2> output.txt ; cat output.txt | ./checker $1 > /dev/null 2> result_checker.txt ; cat output.txt | ./srcs/ref_checker $1 > /dev/null 2> result_checker2.txt
	RESULT=$(<output.txt)
	value=$(<result_checker.txt)
	value_2=$(<result_checker2.txt)
	if [[ "$value" != "$value_2" ]]
	then
		printf $BOLDRED"\nYour checker output "$value" instead of "$value_2" ! Failed error test with list = $RESET"
		echo \["$1"\]
	elif [[ "$RESULT" != "$value_2" ]]
	then
		printf $BOLDRED"\nYour push_swap output "$RESULT" instead of "$value_2" ! Failed error test with list = $RESET"
		echo \["$1"\]
	else
		printf $BOLDGREEN"\nSuccess error test with list = $RESET"
		echo \["$1"\]
	fi
}

function errortest()
{
	ERROR=0
	printf $BOLDYELLOW"Begin error test$RESET\n"
	sleep 3
	printf $BOLDCYAN"\nNo args$RESET\n"
	exec
	printf $BOLDCYAN"\nWith alpha char$RESET\n"
	exec "1 2 3 6 4 a"
	exec "a 1 2 3 5 6"
	exec "1 2 3 4 A"
	exec "A"
	printf $BOLDCYAN"\nWith value > int$RESET\n"
	exec "1 2 3 4 2147483647"
	exec "1 2 3 4 2147483648"
	exec "1 2 3 4 -2147483647"
	exec "1 2 3 4 -2147483648"
	exec "1 2 3 4 -2147483649"
	printf $BOLDCYAN"\nWith dupe > int$RESET\n"
	exec "1 2 3 1"
	exec "1 2 1 3"
	exec "3 2 1 1"
	exec "1 1 2 3"
	exec "2 1 1 4"
	
}

if [[ $# -eq 0 ]]
then
	compil
	basetest 0 100
	printf $BOLDCYAN"You can use : $BOLDRED\"bash push_swap_tester.sh [start][end]\"$BOLDCYAN if you want to specify the range$RESET\n"
	printf $BOLDYELLOW"Begin optimisation test$RESET\n"
	if [[ $NBR_ERROR != 0 ]]
	then
		exit 1
	fi
	optitest 2
	printf $BOLDCYAN"\nFor size = 3 : Average = $O_RET and biggest = $BIGGEST !$RESET\n"
	if [[ $BIGGEST -gt 3 ]]
	then
		printf $BOLDRED"Fail optimisation test with size = 3. You must have 3 instruction max$RESET\n"
	else
		printf $BOLDGREEN"Good optimisation with size = 3.$RESET\n"
	fi
	optitest 4
	printf $BOLDCYAN"\nFor size = 5 : Average = $O_RET and biggest = $BIGGEST !$RESET\n"
	if [[ $BIGGEST -gt 12 ]]
	then
		printf $BOLDRED"Fail optimisation test with size = 5. You must have 12 instruction max$RESET\n"
	else
		printf $BOLDGREEN"Good optimisation with size = 5.$RESET\n"
	fi
	optitest 99
	printf $BOLDCYAN"\nFor size = 100 : Average = $O_RET and biggest = $BIGGEST !$RESET\n"
	if [[ $O_RET -lt 700 ]]
	then
		printf $BOLDGREEN"Considering the barem, you have 5/5 with size = 100\n$RESET"
	elif [[ $O_RET -lt 900 ]]
	then
		printf $BOLDGREEN"Considering the barem, you have 4/5 with size = 100\n$RESET"
	elif [[ $O_RET -lt 1100 ]]
	then	
		printf $BOLDYELLOW"Considering the barem, you have 3/5 with size = 100\n$RESET"
	elif [[ $O_RET -lt 1300 ]]
	then	
		printf $BOLDYELLOW"Considering the barem, you have 2/5 with size = 100\n$RESET"
	elif [[ $O_RET -lt 1500 ]]
	then	
		printf $BOLDRED"Considering the barem, you have 1/5 with size = 100\n$RESET"
	fi
	optitest 499
	printf $BOLDCYAN"\nFor size = 500 : Average = $O_RET and biggest = $BIGGEST !$RESET\n"
	if [[ $O_RET -lt 5500 ]]
	then
		printf $BOLDGREEN"Considering the barem, you have 5/5 with size = 500\n$RESET"
	elif [[ $O_RET -lt 7000 ]]
	then	
		printf $BOLDGREEN"Considering the barem, you have 4/5 with size = 500\n$RESET"
	elif [[ $O_RET -lt 8500 ]]
	then	
		printf $BOLDYELLOW"Considering the barem, you have 3/5 with size = 500\n$RESET"
	elif [[ $O_RET -lt 10000 ]]
	then	
		printf $BOLDYELLOW"Considering the barem, you have 2/5 with size = 500\n$RESET"
	elif [[ $O_RET -lt 11500 ]]
	then	
		printf $BOLDRED"Considering the barem, you have 1/5 with size = 500\n$RESET"
	fi
	errortest
    exit 0
fi

if [[ $# -ne 2 ]] 
then
    printf $BOLDRED"Wrong number of elements !\nUsage = \"bash push_swap_tester.sh\" for all test \nOr Usage = \"bash push_swap_tester.sh [start][end]\" if you want to specify a range$RESET\n"
    exit 0
fi
compil

basetest $1 $2