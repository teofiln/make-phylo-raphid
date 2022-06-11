#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -lt 2 ]];
then
    echo ""
    echo -e "${GR}usage: tree-shrink.sh <alignment> <tree> ${NC}"
    echo -e "${GR}Refer to TreeShrink's documentation${NC}"
    echo ""
    exit
fi

infa=$1
intr=$2
drnm=$(dirname ${infa})
drnm2=$(dirname ${drnm})
bsnm=$(basename ${intr})

mkdir -p ${drnm}/mm_indir
mkdir -p ${drnm}/mm_indir/gene
cp ${infa} ${drnm}/mm_indir/gene/input.fasta
cp ${intr} ${drnm}/mm_indir/gene/input.treefile

echo -e "${GR}Pruning long branches from ${infa} using TreeShrink and default settings.${NC}\n"
/usr/bin/python3 run_treeshrink.py -i ${drnm}/mm_indir -a input.fasta -t input.treefile -O pruned.${bsnm} #> /dev/null
mkdir -p ${drnm2}/pruned
cp ${drnm}/mm_indir/gene/* ${drnm2}/pruned

echo -e "${GR}Done pruning long branches for ${infa}.${NC}\n"
echo -e "${GR}The files are in ${drnm2}/pruned.${NC}\n"



