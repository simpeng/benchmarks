#/bin/bash

for entry in ./exp1/*_analysis.txt
do
  python offline_perf_collector.py --filename="$entry"
done
