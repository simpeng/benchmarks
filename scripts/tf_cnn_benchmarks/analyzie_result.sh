#!/bin/bash

filter='FilterFlag - python tf_cnn_benchmarks.py --num_gpus=1 --batch_size'
filter2='FilterFlag - perf - training step pengwa:0, session run time is '
temp=''

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line == $filter* ]]
  then 
    temp=$line
    #echo "match Text read from file: $line"
  elif [[ $line == $filter2* ]]
  then 
    if [[ $temp != '' ]]
    then 
      # echo "found time: $line"
      echo $temp$line
      temp=''
    else
      exit 128 
    fi
  fi

done < "$1"
