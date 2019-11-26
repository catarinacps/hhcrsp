#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --chdir=.
#SBATCH --partition=cei
#SBATCH --nodes=1
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=hcpsilva@inf.ufrgs.br

set -euo pipefail

HOST=$(hostname)

# machine:
MACHINE=${HOST}_${SLURM_CPUS_ON_NODE}

# parameters:
# the experiment ID, defined in the lab-book
EXP_ID=math_otm_tf
# the code directory
CODE_DIR=$1
# the experiment directory
EXP_DIR=$CODE_DIR/labbook/experiments

# experiment name (which is the ID and the machine and its core count)
EXP_NAME=${EXP_ID}_${MACHINE}

# go to the scratch dir
cd $SCRATCH

# and clean everything
rm -rf *

# prepare our directory
mkdir $EXP_NAME
pushd $EXP_NAME

# get binaries
wget https://julialang-s3.julialang.org/bin/linux/x64/1.2/julia-1.2.0-linux-x86_64.tar.gz
tar xzf julia-1.2.0-linux-x86_64.tar.gz
mv julia-1.2.0 julia

# install from flipping source
wget https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew
chmod +x coinbrew
mkdir build
mkdir cbc
CBC_PATH=$(readlink -f cbc)
mv coinbrew build
pushd build
./coinbrew fetch Cbc --no-prompt
./coinbrew build Cbc --prefix=$CBC_PATH --no-prompt --test
./coinbrew install Cbc --prefix=$CBC_PATH --no-prompt
popd

# cause its missing this one lib
ln -s $(find ~/Installs -name 'libgfortran.so.3') cbc/lib/libgfortran.so.3

# update env vars
LD_LIBRARY_PATH+=:$(readlink -f cbc/lib)
LD_LIBRARY_PATH+=:$(readlink -f julia/lib)
LD_LIBRARY_PATH+=:$(readlink -f julia/lib/julia)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

PATH+=:$(readlink -f julia/bin)
PATH+=:$(readlink -f cbc/bin)
export PATH=$PATH

NUM_THREADS=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
NUM_NUMA_NODES=$(lscpu | grep '^NUMA node(s)' | awk '{print $3}')

USABLE_CPUS=$(($NUM_THREADS / $NUM_NUMA_NODES))

# download julia deps
julia $EXP_DIR/deps.jl

# copy the code folder
cp -r $CODE_DIR code
mkdir results
results_csv=$(readlink -f results/${EXP_NAME}.csv)
results_dir=$(readlink -f results)
pushd code

# build so we run faster
make

# init the csv results file
echo "id,instance,score,gap" > $results_csv

# math solver
while read -r id instance; do
    csv_line=${id},${instance}

    echo
    echo "--> Running with params: $id $instance"

    log_file=$results_dir/${id}_${instance}.log

    ./build/hhcrsp \
        -o model.lp \
        instances/Instanz${instance}.txt \
        math > $log_file

    numactl -C 0 -m 0 cbc \
        -timemo elapsed \
        -thread $USABLE_CPUS \
        -import model.lp \
        -sec 300 \
        -solve \
        -solu sol.lp >> $log_file

    obj_value=$(grep '^Objective' $log_file | awk '{print $3}')

    if grep -q '^Gap' $log_file; then
        gap=$(grep '^Gap' $log_file | awk '{print $2}')
    else
        gap=0.0
    fi

    echo ${csv_line},${obj_value},${gap} >> $results_csv
done < $EXP_DIR/math.plan

popd

# pack everything and send to the exp dir
tar czf $EXP_DIR/data/$EXP_NAME.tar.gz *

popd
rm -rf $SCRATCH/*
