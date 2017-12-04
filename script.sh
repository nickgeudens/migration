#!/bin/bash

#First, populate the repos array with all repository's that you would like to copy
#Make sure there are empty repository's on the destination server with the same name

originServer='http://nick@localhost:7990/scm/test/'
destinationServer='git@github.com:nickgeudens/'

declare -a repos=(
	'testerke.git'
	)
mkdir temp
cd temp
for gitRepo in ${repos[@]}
do
	#short name for repo
  	localRepoDir=$(echo ${localCodeDir}${gitRepo}|cut -d'.' -f1)
	echo -e "\n"
	echo "Cloning '${localRepoDir}'..."
	git clone $originServer$gitRepo $localRepoDir &> /dev/null;
	cd ./$localRepoDir 
	git branch -r | grep -v '\->' | while read remote;
	do git checkout -b ${remote#origin/} ${remote} &> /dev/null;
	echo "$(tput setaf 2)${remote#origin/}$(tput sgr 0)"; done
	newOriginCmd="git remote add new-origin ${destinationServer}${gitRepo}"
	$($newOriginCmd)
	echo "Pushing '${localRepoDir}' to destination..."
	git push --all new-origin
	echo "Pushing tags to destination..."
	git push --tags new-origin &> /dev/null
	git remote rm origin
	git remote rename new-origin origin
	cd ..
	
done
cd ..
rm -rf temp
