#!/bin/bash

model_name=$2
start_batch_size=$1

if [ -z "$model_name" ] || [ -z "$start_batch_size" ]
then
  echo 'model name and batch size can not be null'
  exit 2
fi

run_simple_batch=false
if [ -n "$3" ]
then
  echo 'run simple batch only'
  run_simple_batch=true
fi


# we aim to get a full pass
run_vertically() {
  model_name=$1
  batch_size=$2
  other_params="$3"
  line_cnt=5
  lower_pass=0
  upper_failure=0
  while [ $upper_failure = 0 ] || [  $(( $upper_failure-$lower_pass )) -gt 10 ]
  do
    echo "start another group test with batch size - $batch_size"
    out_filename="${model_name}-${batch_size}-stdout${other_params// /_}"
    rm "$out_filename"
    bash run_core.sh $batch_size $model_name "$other_params" >> $out_filename  2>&1
    bash process.sh $out_filename
    line_cnt=`wc -l < $out_filename'_analysis.txt'`
    echo "found $line_cnt results that are not OOM"
 
    if [ "$run_simple_batch" = true ] 
    then
      echo 'run simple batch only, auto upper finder is disabled'
      break
    fi
  
    if [ $line_cnt = 5 ]
    then
      lower_pass=$batch_size
     
      if [ $upper_failure = 0 ]
      then
        batch_size=$(( $lower_pass*2 ))
        echo "double lower_pass to get first upper_failure"
      else
        batch_size=$(( ($lower_pass + $upper_failure)/2  ))
        echo "get the middle value between lower_pass and upper_failure: $batch_size"
      fi
    else
      if [ $batch_size = $2 ] 
      then
        echo "cannot get a full pass even with the start batch size, stop furthur try"
        exit 3
      else 
        upper_failure=$batch_size
        batch_size=$(( ($lower_pass + $upper_failure)/2  ))
        echo "OOM happens, so mark current batch size of upper"
      fi
    fi
    

  done
}

# off memory explicitly
#other_params='--mem_opt off'
#echo 'running first set experiments - memopt=off'
#run_vertically $model_name $start_batch_size "$other_params"


# default intelligent memory explicitly
#other_params='--mem_opt intelligent'
#echo 'running second set experiments - memopt=intelligent'
#run_vertically $model_name $start_batch_size "$other_params"


echo 'running third set experiments - memopt=intelligent with elastic_percentage'
declare -a elastic_ps=("80")
#declare -a to_reserve=("0" "1" "2" "8" "3" "9" "10" "11")
declare -a to_reserve=("2" "8" "3" "9" "10" "11")
for p in "${elastic_ps[@]}"
do
  for s in "${to_reserve[@]}"
  do
    echo "elastic_percentage is $p, to_reserve=$s"
    other_params="--mem_opt=intelligent --to_reserve=$s --elastic_percentage=$p"
    run_vertically $model_name $start_batch_size "$other_params"
  done
done
