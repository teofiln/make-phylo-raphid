Dependencies.
- mafft
- blast
- iqtree

These were installed with `apt install` from Ubuntu repositories.

Other dependencies are shipped with the pipeline and can be installed with the `install-deps.sh` script.

Steps.

1. Place `bait` sequences in `baits/` folder as fasta files. One per gene.
2. Create `blast` databases for each gene. In the `baits/` folder, run:

    ```for i in *.fa; do makeblastdb -in ${i} -dbtype nucl; done```

3. Update the make config file with parameters

    ```
    # clade
    CLADES=Bacillariophyceae

    # download settings
    GENE=mygene # set gene name here
    MIN_LEN=300 # sequences `shorter' than this will not be downloaded from NCBI
    MAX_LEN=3000 # sequences `longer' than this will not be downloaded from NCBI
    RIBOSOMAL=no # is it 16s/18s/28s/ITS/5.2s or similar?
    OUTDIR=mygene # typically same as GENE

    # blast settings
    IDENTITY=20 # depending on baits and target clade
    COVERAGE=40 # depending on baits and target clade
    ```

4. Run `make' to build the dataset for a gene and clade, as specified in the `config.mk' file

    ```
    make
    ```

5. Alternatively, you can perform step by step:

    ```
    make download
    make filter
    make align
    ```

6. To clean up run one of the following:

    ```
    make alignclean
    make blastclean
    make allclean
    ```