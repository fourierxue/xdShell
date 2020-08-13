#!/bin/bash
#echo "please enter directory:"
#read path
#for dir in $(ls $path)
#do
#    mkdir $dir
#done

function copyDirStructure() {
    for dir in `ls $1`
    do
        if [ -d $1"/"$dir ]; #判断是否是目录，是目录则递归
        then
            mkdir $2"/"$dir
            echo "make directory:"$2"/"$dir
            copyDirStructure $1"/"$dir $2"/"$dir
        fi
    done
}
copyDirStructure $1 $2
