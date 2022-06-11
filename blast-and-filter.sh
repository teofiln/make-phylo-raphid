#!/bin/bash
set -eu
# set -x

GR='\033[0;32m'
NC='\033[0m'

if [[ $# -ne 5 ]];
then
    echo
    echo -e "${GR}Usage: blast-and-filter.sh <database> <query> <num_threads> <identity cutoff 0-100> <hsp coverage cutoff 0-100>${NC}"
    echo -e "${GR}Blast and filter out sequences without hits in provided database.${NC}"
    echo -e "${GR}Blast output is in directory 'blastout' and the filtered fasta file is in directory 'filtered'.${NC}"
    echo -e "${GR}Both of these are placed in the directory where the input fasta comes from.${NC}"
    echo
    exit
fi

dbs=$1
qry=$2
cpu=$3
idn=$4
cov=$5

dbsname=$(basename ${dbs})
qryname=$(basename ${qry} .fasta)
drname=$(dirname ${qry})

fasta_to_table () {
    cat $1 | awk '{if ($1 !~ ">") printf"%s", $0; else print "\n"$0}' | awk 'NF' | paste - -
}

if [[ ! -d "${drname}/blastout" ]]; then mkdir ${drname}/blastout; fi
if [[ ! -d "${drname}/filtered" ]]; then mkdir ${drname}/filtered; fi

# blast
blastn -db ${dbs} -query ${qry} -num_threads ${cpu} \
    -outfmt 6 -max_target_seqs 1 -max_hsps 1 \
    -perc_identity ${idn} -qcov_hsp_perc ${cov} > ${drname}/blastout/${dbsname}-${qryname}.blastout

# filter out sequences without a blast hit
# get the accessions of sequences with hits
cat ${drname}/blastout/${dbsname}-${qryname}.blastout | cut -f1 | sort | uniq > ${drname}/blastout/keepers-${dbsname}-${qryname}

# convert the fasta to a table
fasta_to_table ${qry} > ${drname}/filtered/${qryname}.table

# (rip)grep those lines in the table with match in the keepers file

rg --regex-size-limit 200M --dfa-size-limit 4G --threads 4 -Ff \
  ${drname}/blastout/keepers-${dbsname}-${qryname} \
  ${drname}/filtered/${qryname}.table \
  > ${drname}/filtered/blast.filtered.${qryname}.table

# for i in $(cat ${drname}/blastout/keepers-${dbsname}-${qryname}); do
#     ag --nonumbers $(echo ${i}) ${drname}/filtered/${qryname}.table
# done > ${drname}/filtered/blast.filtered.${qryname}.table

# rev comp the keepers if necessary
# find the sequences that are reverse complemented
cat ${drname}/blastout/${dbsname}-${qryname}.blastout |\
    awk '{if ($9 > $10) print $1}' > ${drname}/blastout/seqs-to-revcomp-${dbsname}-${qryname}

if [[ $( wc -l <${drname}/blastout/seqs-to-revcomp-${dbsname}-${qryname} ) -gt 0 ]]

  then
    
    # extract them from the file with all sequences
    rg --regex-size-limit 200M --dfa-size-limit 4G --threads 4 -Ff \
      ${drname}/blastout/seqs-to-revcomp-${dbsname}-${qryname} \
        ${drname}/filtered/blast.filtered.${qryname}.table |\
        tr "\t" "\n" | awk '{print tolower($0)}' > ${drname}/to-be-rev-comp-${qryname}.fasta

    # remove them from the file with all sequences
    rg --regex-size-limit 200M --dfa-size-limit 4G --threads 4 -vFf \
      ${drname}/blastout/seqs-to-revcomp-${dbsname}-${qryname} \
        ${drname}/filtered/blast.filtered.${qryname}.table |\
        tr "\t" "\n" | awk '{print tolower($0)}' \
        > ${drname}/ok-${qryname}.fasta

    # reverse complement
    # from: https://www.biostars.org/p/189325/
    cat ${drname}/to-be-rev-comp-${qryname}.fasta |\
        while read L; do
      echo $L; read L; echo "$L" | rev | tr "atgc" "tacg" ;
    done > ${drname}/rev-comp-${qryname}.fasta
    
    # combine
    cat ${drname}/ok-${qryname}.fasta ${drname}/rev-comp-${qryname}.fasta > ${drname}/filtered/blast.filtered.revcomp.${qryname}.fasta
  
  else

    cat ${drname}/filtered/blast.filtered.${qryname}.table |\
      tr "\t" "\n" | awk '{print tolower($0)}' > ${drname}/filtered/blast.filtered.revcomp.${qryname}.fasta

fi

# cp ${drname}/filtered/blast.filtered.revcomp.${qryname}.fasta ${drname}/filtered/blast.filtered.revcomp.${qryname}.fasta