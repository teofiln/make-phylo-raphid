!#/bin/bash

#(change the path to raxml-ng as appropriate)

# testing if all works with raxml-ng

/home/teo/src/raxml-ng/raxml-ng --check --msa final-alignment.afa --model by-comp --prefix BY-COMP
/home/teo/src/raxml-ng/raxml-ng --check --msa final-alignment.afa --model by-comp-by-codon --prefix BY-COMP-BY-CODON
/home/teo/src/raxml-ng/raxml-ng --check --msa final-alignment.afa --model by-gene-by-codon --prefix BY-GENE-BY-CODON


# then, run an optimization with desired partition and 100 random + 100 parsimony starting trees
#/home/teo/src/raxml-ng/raxml-ng --msa final-alignment.afa --model ADD-PARTITION-FILE-NAME --prefix ADD-PREFIX \
#    --threads 4 --seed 2 --brlen scaled --tree pars{100},rand{100} 