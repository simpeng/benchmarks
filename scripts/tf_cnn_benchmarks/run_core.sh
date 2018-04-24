#!/bin/bash

model_name=$2
batch_size=$1

if [ -z "$model_name" ] || [ -z "$batch_size" ]
then
  echo 'model name and batch size can not be null'
  exit 2
fi

run_benchmark() {
  COUNTER=0
  batch_size=$1
  model_name=$2
  while [ $COUNTER -lt 5 ]
  do 
    echo 'FilterFlag - The counter is '$COUNTER
    echo "FilterFlag - python tf_cnn_benchmarks.py --num_gpus=1 --batch_size=${batch_size} --model=${model_name} --variable_update=parameter_server $3"
    python tf_cnn_benchmarks.py --num_gpus=1 --batch_size=$batch_size --model=$model_name --variable_update=parameter_server $3
    COUNTER=$(( $COUNTER+1 ))
    sleep 1
  done
}

other_params=$3
run_benchmark $batch_size $model_name "$other_params"



