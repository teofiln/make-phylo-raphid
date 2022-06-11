#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -lt 1 ]];
then
    echo ""
    echo -e "${GR}usage: coding-align.sh <fasta file> <genetic code number> ${NC}"
    echo -e "${GR}[See usage of TransDecoder for list of available genetic codes. By default this script will use the universal genetic code (number 1)]${NC}"
    echo ""
    exit
fi

inname=$1
basenm=$(basename $1)
drnm=$(dirname $1)
drnm2=$(dirname $1 | cut -d "/" -f 1)

test -d "${drnm2}/aligned" || mkdir ${drnm2}/aligned

./TransDecoder.LongOrfs -t ${inname} -G universal 
./TransDecoder.Predict -t ${inname} --single_best_only
mv ${basenm}.transdecoder* ${drnm}
mafft --auto ${inname}.transdecoder.pep > ${inname}.transdecoder.pep.afa
./pal2nal.pl ${inname}.transdecoder.pep.afa ${inname}.transdecoder.cds \
  -output fasta > ${inname}.transdecoder.cds.afa
  
awk '{if ($1 ~ ">") print $1; else print $0}' ${inname}.transdecoder.cds.afa > ${inname}.afa

cp ${inname}.afa ${drnm2}/aligned

echo -e "${GR}Done aligning ${inname}.${NC}\n"
