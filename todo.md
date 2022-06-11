To do:

- a global table with genus, species, gene_name, gene_numeric_id
- add a global_id to the global table, this will repeat on genus+species case and will allow concatenation

- filter things not identified to some level.. i.e., remove `sp.` 
- but when? on download? or before concatenating 
- also allow this to be genus specific, so we want to keep all Diploneis regardless of species-level id


- can we get vouchers from ncbi? And use that to concat?


- a script to make a blast database from bait sequences
- a script to concatenate alignments
- a script to compress everything except the final output