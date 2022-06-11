#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -lt 1 ]];
then
    echo ""
    echo -e "${GR}usage: rrna-align.sh <fasta file> (<mask threshold>)${NC}"
    echo -e "${GR}[See usage of ssu-align for detailed options. This script allows ssu-align to determine the appropriate covariance model (archaea / bacteria / eukarya) and provides another filter of the downloaded sequences. The masking threshold (second argument) is optional with a default=0.95, i.e. if the posterior probability of positional homology of an alignment column is <0.95, that column will be removed from the final alignment. You can relax this setting, or chose not to mask at all by passing 'nomask' as the second parameter.]>${NC}"
    echo ""
    exit
fi

infa=$1
inname=$(basename ${infa} .fasta)
drnm=$(dirname ${infa} | cut -d "/" -f 1)
maskt=${2:-0.95}
outfa=ssualign.${inname}.${maskt}.afa

test -d "${drnm}/aligned" || mkdir ${drnm}/aligned

ssu-align $infa ${drnm}/aligned/${inname} 1>/dev/null

if [[ ${maskt} == "nomask" ]];
then
  ssu-esl-reformat afa ${drnm}/aligned/${inname}/${inname}.bacteria.stk > ${drnm}/aligned/${outfa}
else
  ssu-mask --pt ${maskt} ${drnm}/aligned/${inname} 1>/dev/null
  ssu-esl-reformat afa ${drnm}/aligned/${inname}/${inname}.bacteria.mask.stk > ${drnm}/aligned/${outfa}
fi

echo -e "${GR}Done aligning ${infa}.${NC}\n"
