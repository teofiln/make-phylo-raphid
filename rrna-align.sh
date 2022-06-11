#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -lt 1 ]];
then
    echo ""
    echo -e "${GR}usage: rrna-align.sh <fasta file> ${NC}"
    echo -e "${GR}Refer to mafft's documentation${NC}"
    echo ""
    exit
fi

infa=$1
inname=$(basename ${infa})
drnm=$(dirname ${infa} | cut -d "/" -f 1)
outfa=${inname}.afa

mkdir -p ${drnm}/aligned

echo -e "${GR}Aligning ${infa} using mafft --auto.${NC}\n"
mafft --quiet --auto ${infa} > ${drnm}/aligned/temp.afa
sed -i s'/ /_/'g ${drnm}/aligned/temp.afa

echo -e "${GR}Trimming the alignment using trimal -automated1.${NC}\n"
./trimal -in ${drnm}/aligned/temp.afa -out ${drnm}/aligned/${outfa} -htmlout ${drnm}/aligned/${outfa}.html -automated1
rm  ${drnm}/aligned/temp.afa

echo -e "${GR}Done aligning an trimming ${infa}.${NC}\n"
