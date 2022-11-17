#!/bin/bash
#====================================================
# This is just a reminder file with usefull git commands
# Author Artyom Ivanov
# Created 10.2022
# Ver 1.0
# Main workflow git+github
# create online repo->pull to local->make changes->push back
#====================================================

# Note some* derivatives in commands and change the, with proper values
# after sudo apt install git
# run global config commands
git config --global user.name "someusername"
git config --global user.email "somemail@somedomain.com"
# create a directory to make it repository
sudo mkdir -p gitroot
cd gitroot
sudo mkdir -p $1
# init
cd $1
git init .
# create alias to get readable git log
alias graph="git log --all --decorate --oneline --graph"

# work with files
# create ignore file
touch .gitignore
echo "*.log" > .gitignore
# create you first file
touch README.md
echo "This is readmefile, make it usefull" < README.md

# git status - show current progress
sudo git status
# git add README.md, you can use "sudo git add *" to add all files
sudo git add README.md

# git commit - next we have to make first so called "snapshot" - commit, always write some message
sudo git commit -m "try to commit new text file..."

# work with logs
# we can watch all the commits
git log
# we can look only last one
git log -1
# we can look what exactly changed
git log -1 -p

# next, to work with github we have to generate pat key
# go to github-settings-developers-pat
# generate key

# also we can create an ssh key by run
#ssh-keygen #choose defaults
# copy from "cat .ssh/id_rsa.pub"
# next we go to github-profile-settings-ssh keys and paste from above pub

# next we can create online repository
# then we clone this repository to local mashine with ssh key
git clone git@github.com:someusername/somerepository.git

# then we can add or change some files
echo this is new file > ffffile.txt
echo this is new string >> README.md 

# and next we push to github with
git push origin

# work with branches
# create new branch
git branch fix_error
# switch to new branch
git checkout fix_error
# delete a branch
git branch -d fix_error
# create a branch and move to it
git checkout -b fix_error_2
# to push to github a new branch we will use (fix_error_in_file_fffff -name of new branch)
git push --set-upstream origin fix_error_in_file_fffff
# next we merge new branch to master
git merge fix_error_in_file_fffff
git branch -d fix_error_in_file_fffff
git push origin
# delete branch from online
git push origin --delete new_fixes

# work with commits
# go back to old commit
git log
git checkout 5507fcfcc802f16000e71ee84369f62b50e51238
# go back to main
git checkout main
# add changes to commit
echo 123123 >> ffff.txt
git commit --amend
# reset changes 3 commits back
git reset --hard HEAD~3
# list commits in one line
git log --pretty=oneline

# work with tags
# create tag and push it to github
git tag v.1.0.0
git push origin v.1.0.0 
# delete tag from local and from github
git tag -d v1.1.0
git push origin --delete v1.1.0
# go to commit by tag
git checkout v.1.0.0
# set tag on some commit
git tag -a v.1.1.1 9da84ce6b36a63de2215282eab68a4908cd699c3

# work with shates
# postpone commit
git stash
# aplly stashed commits and delete stash
git stash pop
# apply stashed and save them in stash
git stash apply
