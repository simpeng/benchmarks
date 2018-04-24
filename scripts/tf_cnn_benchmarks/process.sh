#!/bin/bash 

input_name=$1

name_after_grep=$input_name'_after_grep'
grep "FilterFlag" $input_name > $name_after_grep
bash analyzie_result.sh $name_after_grep | sort > $input_name'_analysis.txt'

