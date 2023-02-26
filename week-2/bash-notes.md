# Noting all the commands used for the week 2 tasks

## $ ssh bandit0@bandit.labs.overthewire.org -p 2220 
connect to the Bandit game server via SSH using bandit0 as username and specifying 2220 as passwort

## ls
list all files in current directory

## cat readme
read the readme file

## logout
log out of SSH server

## cat < -
read the file named -

## cat "spaces in this filename"
open a file with blank spaces in filename

## ls -a
list all files and dirs (including hidden)

## find . -size 1033c
find all files with size equal to 1033 bytes in current directory and child directories

## cd /
change directory to root dir

## find . -size 33c -user bandit7 -group bandit6
find all files with size equal to 33 bytes that belongs to group bandit6 and user bandit7

## grep -w millionth data.txt
find row in data.txt file where word "millionth" shows up

## cat data.txt | sort | uniq -u
find a line inside data.txt that only appears once

## cat data.txt | grep --text -w ==
search for ocurrences of = sign and output it in grep text format

## cat data.txt | base64 --decode
open a file encoded in base64 and decode it