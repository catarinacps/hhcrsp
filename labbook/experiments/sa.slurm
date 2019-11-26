#!/bin/bash

set -euxo pipefail

HOST=$(hostname)

# machine:
MACHINE=${HOST}_$(lscpu | grep '^CPU(s):' | awk '{print $2}')

# parameters:
# the experiment ID, defined in the lab-book
EXP_ID=sa_otm_tf
# the code directory
CODE_DIR=$1
# the experiment directory
EXP_DIR=$CODE_DIR/labbook/experiments

# experiment name (which is the ID and the machine and its core count)
EXP_NAME=${EXP_ID}_${MACHINE}

# go to the scratch dir
cd $2

# and clean everything
rm -rf *

# prepare our directory
mkdir $EXP_NAME
pushd $EXP_NAME

# copy the code folder
cp -r $CODE_DIR code
mkdir results
results_csv=$(readlink -f results/${EXP_NAME}.csv)
results_dir=$(readlink -f results)
pushd code

# build so we run faster
make

# init the csv results file
echo "instance,temperature,strategy,factor,iterations_outer,iterations_inner,score" > $results_csv

# math solver
while read -r instance temperature strategy factor iterations; do
    iterations=${iterations//\"}
    csv_line=${instance},${temperature},${strategy},${factor},${iterations// /,}

    echo
    echo "--> Running with params: $instance $temperature $strategy $factor $iterations"

    log_file=$results_dir/${instance}_${temperature}_${strategy}_${factor}_${iterations// /_}.log

    ./build/hhcrsp \
        -t $temperature \
        -g $strategy \
        -f $factor \
        -i $iterations \
        instances/Instanz${instance}.txt \
        sa > $log_file

    obj_value=$(grep '^Score' $log_file | awk '{print $2}')

    echo ${csv_line},${obj_value} >> $results_csv
done < $EXP_DIR/sa.plan

popd

# pack everything and send to the exp dir
tar czf $EXP_DIR/data/$EXP_NAME.tar.gz *

popd
rm -rf $SCRATCH/*
