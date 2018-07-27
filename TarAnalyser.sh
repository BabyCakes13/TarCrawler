#!/bin/bash

totalFiles=0

checkUser(){

	if [[ "$EUID" > 0 ]]; then

		initialiseParse "$@"
		echo -e "\n Total number of searched files is $totalFiles"

	else

		echo "You are root, baby, get out of here!"
		exit 1

	fi

}

isTar(){

	if [[ "$arg" == *.tar.gz || "$arg" == *.tgz ]]; then

		echo "T"

	else

		echo "F"

	fi

}
checkCommandArguments(){

	local tarArgument="F"
	local dirArgument="F"
	local cFlag="F"
	local nFlag="F"
	local tarname="F"

	for arg in "$@" 
	do
		
		if [[ "$arg" == "-c" ]]; then

			cFlag="T"

		elif [[ "$arg" == "-n" ]]; then

			nFlag="T"

		elif [[ "$arg" == *.tar.gz || "$arg" == *.tgz ]]; then
			
			tarArgument=$(isTar $arg)
			tarName="$arg"

		elif [[ -d "$arg" ]]; then

			dirArgument="T"

		fi

	done

	echo "$nFlag$cFlag$tarArgument$dirArgument$tarName"

}

initialiseParse(){

	local checkResult=$(checkCommandArguments "$@")
	local isTar=${checkResult:2:1}
	local isDir=${checkResult:3:1}
	local isN=${checkResult:0:1}
	local isC=${checkResult:1:1}

	if [[ "$isTar" == "T" ]]; then

		tarName=${checkResult:4}
		parseTar "${checkResult:4}" "$isC" "$isN"

	elif [[ "$isDir" == "T" ]]; then

		parseDirectory "$@"

	else

		echo "There is no tar or directory. Focus"

	fi
	
}

parseDirectory(){

	local isTarResult=$(isTar $arg)

	cd "$1"

	for arg in *
	do

		if [[ -d "$arg" ]]; then

			parseDirectory "$arg" "$2" "$3"

		elif [[ $isTarResult != "F" ]]; then

			parseTar "$arg" "$2" "$3"

		fi

	done

	cd ".."

}

parseTar(){

	echo -e "\n"
	
	local folderName=$1"_temporary"
	local tarName=$1

	mkdir $folderName
	tar xf $tarName -C $folderName
	cd $folderName

	if [[ "$2" == "T" ]]; then

		foundFiles=$(ls | wc -l)
		echo "Number of files in archive $1 is $foundFiles"
		totalFiles="$((totalFiles + foundFiles))"
	fi

	if [[ "$3" == "T" ]]; then

		grep -rnw -e "Such open, much Stack"

	fi

	#recusrively parse directories or tar files found in the current tar
	for arg in *
	do

		isTarResult=$(isTar $arg)

		if [[ "$isTarResult" == "T" ]]; then

			parseTar "$arg" "$2" "$3"

		elif [[ -d "$arg" ]]; then

			parseDirectory "$arg" "$2" "$3"

		fi

	done

	cd ".."
	rm -r $folderName

}


checkUser "$@"