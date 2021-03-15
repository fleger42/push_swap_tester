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
	NBR=0
	NBR_ERROR=0
	let "NBR_TEST=$2 - $1"
	printf $BOLDYELLOW"Begin test of $BOLDRED$NBR_TEST$BOLDYELLOW random list from $BOLDRED$1$BOLDYELLOW to $BOLDRED$2$BOLDYELLOW!$RESET\n"
	for NBR in `seq $1 $2`;
	do
		LIST=$(perl -e "use List::Util 'shuffle'; my @out = (shuffle 0..$NBR)[0..$NBR]; print \"@out\"")
		set -v
		ARG=${LIST[@]}; ./push_swap $ARG | ./checker $ARG > /dev/null
		RET=$?
		if [[ $RET != 0 ]] 
		then
			printf $BOLDRED"Fail$RESET with size $TOTAL$NBR/$2$RESET\n"
			echo "LIST = "${LIST[@]}
			let "NBR_ERROR=NBR_ERROR+1"
		else
			printf $BOLDGREEN"Success$RESET with size $TOTAL$NBR/$2$RESET\n"
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
			TOTAL=$BLUE
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
}
if [[ $# -eq 0 ]]
then
	compil
	basetest 0 10
    printf $BOLDCYAN"You can use : $BOLDRED\"bash push_swap_tester.sh [start][end]\"$BOLDCYAN if you want to specify the range$RESET\n"
    exit 0
fi
if [[ $# -ne 2 ]] 
then
    printf $BOLDRED"Wrong number of elements !\nUsage = \"bash push_swap_tester.sh [start][end]\"$RESET\n"
    exit 0
fi
compil

basetest $1 $2