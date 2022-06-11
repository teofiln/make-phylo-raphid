#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -lt 1 ]];
then
    echo ""
    echo -e "${GR}usage: coding-align.sh <fasta file> ${NC}"
    echo -e "${GR}[See usage of MACSE for details]${NC}"
    echo ""
    exit
fi

inname=$1
basenm=$(basename $1)
drnm=$(dirname $1)
drnm2=$(dirname $1 | cut -d "/" -f 1)

mkdir -p ${drnm2}/aligned

echo -e "${GR}Aligning ${inname} using MACSE alignSequences.${NC}\n"
java -jar macse_v2.05.jar -prog alignSequences -seq ${inname} -out_NT temp.afa

echo -e "${GR}Exporting ${inname} using MACSE exportAlignment.${NC}\n"
java -jar macse_v2.05.jar -prog exportAlignment -align temp.afa -codonForExternalFS --- -codonForInternalStop NNN -codonForInternalFS --- -charForRemainingFS - -out_NT ${inname}.afa -out_AA ${inname}.protein.afa 

cp ${inname}.afa ${inname}.protein.afa ${drnm2}/aligned

echo -e "${GR}Done aligning ${inname}.${NC}\n"