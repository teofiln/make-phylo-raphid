box::use(
    dplyr[`%>%`],
    readr,
    purrr,
    rlang,
    tidyr
)

gene_list <- c(
    "16s", "18s", "28s", "atpb", "cob",
    "cox1", "psaa", "psab", "psba", "psbc", "rbcl"
)

# a list of fasta files with complete names in table format tab `\t` sequence
nams_list <- list.files(
    path = "to-concatenate-2022-06-09/",
    pattern = "^Bacillariophyceae",
    full.names = TRUE
) |> purrr::keep(function(x) endsWith(x, "table"))

nams <- purrr::map(nams_list, readr::read_tsv, col_names = c("tag", "seq")) |>
    rlang::set_names(gene_list)

# a list of fasta files with numeric ids in table format tab `\t` sequence
seqs_list <- list.files(
    path = "to-concatenate-2022-06-09/",
    pattern = "^pruned",
    full.names = TRUE
) |> purrr::keep(function(x) endsWith(x, "table"))

seqs <- lapply(seqs_list, readr::read_tsv, col_names = c("tag", "seq")) |>
    rlang::set_names(gene_list)

# datasets with fewer than 50 taxa are not considered?
purrr::map(seqs, nrow)

# steps:
# 1. make a global list of names with global unique identifier
# 2. assign the global identifier to the cleaned, aligned, trimmed, pruned fasta
# 3. concatenate based on the global unique id
# 4. add species info

# 1. global list of names and ids
all_names <- purrr::map(nams, dplyr::pull, "tag") |> purrr::flatten_chr()
tot <- length(all_names)

# helper, expect
get_field <- function(all_names, index) {
    purrr::map_chr(
        all_names,
        function(x) {
            strsplit(x, split = "_")[[1]][index] |> paste(collapse = "_")
        }
    )
}

global_table <- data.frame(
    global_id = 1:tot,
    gene_id = get_field(all_names, 1) |> gsub(pattern = ">", replacement = ""),
    ncbi_id = get_field(all_names, 2),
    genus = get_field(all_names, 3),
    species = get_field(all_names, -c(1:3)) |>
        strsplit(split = "__") |>
        purrr::map(purrr::pluck, 1) |>
        purrr::flatten_chr() |>
        gsub(pattern = "_Eukaryota", replacement = ""),
    id_name_taxonomy = get_field(all_names, -1)
) |>
    # add gen/sp id
    dplyr::group_by(genus, species) |>
    dplyr::mutate(species_id = dplyr::cur_group_id()) |>
    dplyr::arrange(species_id) |>
    # groups might interfere with joins downstream
    dplyr::ungroup()

head(global_table)

# species table is like global table, but each species occurs only once
# and redundant columns are removed
species_table <- dplyr::distinct(global_table, species_id, genus, species)


# 2. assign the global identifier to the cleaned, aligned, trimmed, pruned fasta

# parse the tag to isolate the gene_id
# then join by gene_id to the global table to add the species_id

parse_gene_id <- function(seqs_data) {
    seqs_data |>
        dplyr::mutate(gene_id = get_field(tag, 1) |>
            gsub(pattern = ">", replacement = "") |>
            gsub(pattern = ".p1", replacement = ""))
}

join_species_id <- function(seqs_data, global_data) {
    dplyr::left_join(global_data, seqs_data, by = "gene_id") |>
        dplyr::arrange(dplyr::desc(seq)) |>
        dplyr::distinct(species_id, .keep_all = TRUE) |>
        dplyr::select(species_id, seq) |>
        dplyr::arrange(species_id)
}

species_id_seqs <- purrr::map(seqs, function(x) {
    aln_len <- nchar(x[["seq"]][[1]])
    parse_gene_id(x) |>
        join_species_id(global_data = global_table) |>
        dplyr::mutate(
            seq = ifelse(is.na(seq),
                paste0(rep("-", aln_len), collapse = ""), seq
            )
        )
})

species_id_seqs <- purrr::imap(species_id_seqs, function(.x, .y) {
    rlang::set_names(.x, c("species_id", .y))
})

purrr::map_dbl(species_id_seqs, nrow)

# 3. concatenate

# step 1 is many joins
concat_full <-
    purrr::reduce(species_id_seqs, dplyr::left_join, by = "species_id") |>
    # step 2 is pasting together
    tidyr::unite(col = "concat", -species_id, sep = "", remove = FALSE) |>
    # step 3 adds human readable species info
    dplyr::left_join(species_table, by = "species_id") |>
    dplyr::select(species_id, genus, species, concat, dplyr::everything())

# 4. final alignment
final_alignment_table <- concat_full |>
    tidyr::unite(
        col = "tag", sep = "_", remove = FALSE,
        species_id, genus, species
    ) |>
    dplyr::select(tag, concat)

# save
readr::write_tsv(
    x = final_alignment_table,
    file = "to-concatenate-2022-06-09/final-alignment.table"
)
