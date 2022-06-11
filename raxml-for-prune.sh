#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -lt 1 ]];
then
    echo ""
    echo -e "${GR}usage: raxml-for-trim.sh <fasta file> ${NC}"
    echo -e "${GR}Refer to raxml's documentation${NC}"
    echo ""
    exit
fi

infa=$1
inname=$(basename ${infa} .fasta)
drnm=$(dirname ${infa})

sed -i 's/ /_/g' ${infa}

echo -e "${GR}Building a tree for pruning long branches from ${infa} using raxml.${NC}\n"
./raxml-ng --search1 --msa ${infa} --model GTR+G --prefix ${infa} --threads 8 --seed 2 

echo -e "${GR}Done building tree for pruning long branches ${infa}.${NC}\n"
echo -e "${GR}The files are in ${drnm}.${NC}\n"



