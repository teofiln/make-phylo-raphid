#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -lt 1 ]];
then
    echo ""
    echo -e "${GR}usage: iqtree-for-trim.sh <fasta file> ${NC}"
    echo -e "${GR}Refer to iqtree's documentation${NC}"
    echo ""
    exit
fi

infa=$1
inname=$(basename ${infa} .fasta)
drnm=$(dirname ${infa})

echo -e "${GR}Building a tree for pruning long branches from ${infa} using iqtree.${NC}\n"
iqtree -s ${infa} -nt 8 -pre ${infa} > /dev/null

echo -e "${GR}Done building tree for pruning long branches ${infa}.${NC}\n"
echo -e "${GR}The files are in ${drnm}.${NC}\n"



