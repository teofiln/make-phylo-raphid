#!/bin/bash
# set -x
set -eu

GR='\033[0;32m'
NC='\033[0m'

if [ $# -ne 7 ];
then
    echo ""
    echo -e "${GR}usage: ncbi-download-gene-for-clade.sh <Clade> <Gene> <Min seq length> <Max seq length> <Ribosomal: yes or no> <Outdir> <UserSeqs> ${NC}"
    echo ""
    exit
fi

CLADE=$1
GENE=$2
MIN=$3
MAX=$4
RIB=$5
ODR=$6
SEQ=$7

GENE2=$(echo ${GENE} | tr -d " ")

mkdir -p  ${ODR}
cd ${ODR}


if [[ ${RIB} == "yes" ]];
then
    QUERY=$( echo "${GENE} AND ${CLADE} [ORGN] AND ${MIN}:${MAX} [SLEN]" );
else
    QUERY=$( echo "${GENE} [GENE] AND ${CLADE} [ORGN] AND ${MIN}:${MAX} [SLEN]" );
fi

echo -e "${GR}Searching NCBI with query: '${QUERY}'.${NC}"
# search ncbi nucleotide database for gene in clade with length range
esearch -db Nucleotide -query "${QUERY}" |\
    # get document summary
    efetch -format docsum |\
    # extract taxon ids, sequence length, species name and genbank accession
    xtract -pattern DocumentSummary -element TaxId Slen Organism Caption |\
    # sort by taxon id, then by length
    # save this to a file to keep the original table
    sort -nrk2,2 -nk1,1 > ${CLADE}-${GENE2}.table

echo -e "${GR}Got the accession numbers. Now downloading sequences."

download_seqs () {
    cat $1 |\
    epost -db nucleotide |\
    efetch -db nucleotide -format gpc |\
    xtract -pattern INSDSeq -def "NA" \
      -element INSDSeq_accession-version INSDSeq_organism INSDSeq_taxonomy INSDSeq_sequence |\
    awk -F"\t" '{print ">"$1,$2,$3"\n"$4}'    
}



tmpdir=tmpdl.${CLADE}.${GENE2}
mkdir ${tmpdir}

# sort by taxon id, then by length, filter out the duplicate taxids keeping the entry with the longest sequence
cat ${CLADE}-${GENE2}.table |\
  sort -nrk2,2 -nk1,1 | sort -uk1,1 |\
  # take the genbank accession column
  cut -f4 > ${tmpdir}/accessions

split -l 200 ${tmpdir}/accessions ${tmpdir}/chunk

j=0
tot=$(wc -l ${tmpdir}/accessions | cut -d " " -f1)
outtx=${CLADE}-${GENE2}-uniq-taxid-full-names.fasta
test -e ${outtx} && rm ${outtx}
touch ${outtx}

for i in ${tmpdir}/chunk*; do
  if [[ $(wc -l ${i} | cut -d " " -f1 ) -eq 200 ]]; then
    j=$((${j} + 200))
  else
    j="last batch"
  fi
  echo -e "${GR}Downloaded ${j} of a total of ${tot} sequences.${NC}"
  download_seqs ${i} >> ${outtx}
  sleep 2s
done

rm -r ${tmpdir}

echo -e "${GR}Filtering out duplicates based on scientific name.${NC}"

# sort and get unique Genus+species ids
cat ${CLADE}-${GENE2}-uniq-taxid-full-names.fasta | \
# unfold the sequences
    awk '{if ($1 !~ ">") printf"%s", $0; else print "\n"$0}' | \
# delete empty first line, reformat to `tag \t sequence`, sort and get uniq, reformat back into fasta
    awk 'NF' | paste - - | sort -t" " -Vk2,3 | sort -t" " -uk2,3 | tr "\t" "\n" | tr ";" "_" | tr " " "_" > temp.fasta

echo -e "${GR}Adding user sequences to downloaded data.${NC}"
cat temp.fasta $(dirname $(pwd))/${SEQ} > temp2.fasta
# make simple file with numbers for sequence names
echo ${GENE}
cat temp2.fasta | paste - - | awk -v GN=${GENE} '{print ">" GN NR"_"substr($1,2)"\n"$2}' > ${CLADE}-${GENE2}-uniq-gen-sp-full-names.fasta
cat ${CLADE}-${GENE2}-uniq-gen-sp-full-names.fasta | awk -F"_" '{print $1}' > ${CLADE}-${GENE2}-uniq-gen-sp.fasta
rm temp.fasta temp2.fasta

# echo -e "${GR}Downloaded $(grep -c ">" ${CLADE}-${GENE2}-uniq-gen-sp.fasta) sequences (with unique Genus+species identifications).${NC}"
echo -e "${GR}Done with ${GENE} sequences for ${CLADE}.${NC}"

echo -e "${GR}+-+-+${NC}"