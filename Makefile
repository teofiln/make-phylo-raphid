# load config 
local_config=$(wildcard config.mk)
CONFIG_FILES=$(local_config)
include $(CONFIG_FILES)

# output file(s)
PRUNED := $(foreach word,$(CLADES),$(OUTDIR)/pruned/pruned.blast.filtered.revcomp.$(word)-$(GENE)-uniq-gen-sp.fasta.afa.raxml.bestTree)
PRUNETREES := $(foreach word,$(CLADES),$(OUTDIR)/aligned/blast.filtered.revcomp.$(word)-$(GENE)-uniq-gen-sp.fasta.afa.raxml.bestTree)
AFAS := $(foreach word,$(CLADES),$(OUTDIR)/aligned/blast.filtered.revcomp.$(word)-$(GENE)-uniq-gen-sp.fasta.afa)
BLASTS := $(foreach word,$(CLADES),$(OUTDIR)/filtered/blast.filtered.revcomp.$(word)-$(GENE)-uniq-gen-sp.fasta)
DOWNLOADS := $(foreach word,$(CLADES),$(OUTDIR)/$(word)-$(GENE)-uniq-gen-sp.fasta)

all: $(PRUNED)

prune: $(PRUNED)
prunetree: $(PRUNETREES)
align: $(AFAS)
filter: $(BLASTS)
download: $(DOWNLOADS)

# for testing
test: ; $(info $$AFAS is [${AFAS}]) $(info $$DOWNLOADS is [${DOWNLOADS}]) $(info $$BLASTS is [${BLASTS}])

# what align script to use
ifeq ($(RIBOSOMAL), yes)
  ALIGNER=./rrna-align.sh
else
  ALIGNER=./coding-transd-align.sh
endif

$(OUTDIR)/pruned/pruned.blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta.afa.raxml.bestTree: $(OUTDIR)/aligned/blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta.afa $(OUTDIR)/aligned/blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta.afa.raxml.bestTree
	./tree-shrink.sh $^

$(OUTDIR)/aligned/blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta.afa.raxml.bestTree: $(OUTDIR)/aligned/blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta.afa
	./raxml-for-prune.sh $^

$(OUTDIR)/aligned/blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta.afa: $(OUTDIR)/filtered/blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta
	$(ALIGNER) $^

$(OUTDIR)/filtered/blast.filtered.revcomp.%-$(GENE)-uniq-gen-sp.fasta: $(OUTDIR)/%-$(GENE)-uniq-gen-sp.fasta
	./blast-and-filter.sh baits/all-$(GENE)-baits.fa $^ 1 $(IDENTITY) $(COVERAGE)

$(OUTDIR)/%-$(GENE)-uniq-gen-sp.fasta: 
	./dl-seqs-tax.sh $* $(GENE) $(MIN_LEN) $(MAX_LEN) $(RIBOSOMAL) $(OUTDIR) $(USER_SEQ)

blastclean:
	\rm -r $(OUTDIR)/filtered $(OUTDIR)/blastout

alignclean:
	\rm -r $(OUTDIR)/aligned

allclean:
	\rm -r $(OUTDIR)

installdeps:
	./install-deps.sh

rmdeps:
	\rm -r rg pal2nal.pl TransDecoder.* run_treeshrink.py trimal
	\rm -r deps/pal2nal.v14/ deps/ripgrep-0.7.1-x86_64-unknown-linux-musl/ deps/TransDecoder-TransDecoder-v5.0.2/ deps/TreeShrink-master deps/trimAl
