# library(testthat); library(alabaster.treese)
# source("test-TreeSummarizedExperiment.R")

# Making a TreeSE and annotating it.
set.seed(100)
row_tree <- ape::rtree(20)
row_tree[["node.label"]] <- sprintf("NODE_%i", seq_len(row_tree[["Nnode"]]))
col_tree <- ape::rtree(10)

mat <- matrix(rpois(200, 10), ncol = 10)
rownames(mat) <- row_tree[["tip.label"]]
colnames(mat) <- col_tree[["tip.label"]]

tse <- TreeSummarizedExperiment(
    list(counts = mat), rowTree = row_tree, colTree = col_tree)
tse[["column_group"]] <- LETTERS[1:10]
rowData(tse)[["bacteria_group"]] <- runif(nrow(tse))

# Random reference sequences, one per row.
random_seqs <- vapply(seq_len(nrow(tse)), function(i) {
    paste(sample(c("A", "C", "G", "T"), 20, replace = TRUE), collapse = "")
}, "")
referenceSeq(tse) <- Biostrings::DNAStringSet(random_seqs)

# Compare all TreeSE-specific components of two objects.
expect_tse_identical <- function(out, ref) {
    expect_s4_class(out, "TreeSummarizedExperiment")
    expect_identical(rowData(out), rowData(ref))
    expect_identical(colData(out), colData(ref))
    expect_identical(
        rowTree(out, whichTree = NULL), rowTree(ref, whichTree = NULL))
    expect_identical(
        colTree(out, whichTree = NULL), colTree(ref, whichTree = NULL))
    expect_identical(
        strip_links(rowLinks(out)), strip_links(rowLinks(ref)))
    expect_identical(
        strip_links(colLinks(out)), strip_links(colLinks(ref)))
    expect_identical(
        class(referenceSeq(out)), class(referenceSeq(ref)))
    expect_identical(
        lapply(as.list(referenceSeq(out)), as.character),
        lapply(as.list(referenceSeq(ref)), as.character))
}

# Names on the columns of a DataFrame are not preserved by alabaster.
strip_links <- function(links) {
    if (!is.null(links)) {
        links <- as(links, "DFrame")
        links[["nodeNum"]] <- unname(links[["nodeNum"]])
    }
    links
}

test_that("saveObject works as expected for TreeSE objects", {
    tmp <- tempfile()
    saveObject(tse, tmp)
    expect_identical(
        readObjectFile(tmp)[["type"]], "tree_summarized_experiment")

    out <- readObject(tmp)
    expect_tse_identical(out, tse)
    expect_identical(as.matrix(assay(out)), assay(tse))
})

test_that("saveObject works with a DNAStringSetList as the referenceSeq", {
    referenceSeq(tse) <- Biostrings::DNAStringSetList(
        first = referenceSeq(tse), second = rev(referenceSeq(tse)))

    tmp <- tempfile()
    saveObject(tse, tmp)
    out <- readObject(tmp)
    expect_s4_class(referenceSeq(out), "DNAStringSetList")
    expect_tse_identical(out, tse)
})

test_that("saveObject works without any of the TreeSE-specific slots", {
    copy <- TreeSummarizedExperiment(list(counts = mat))

    tmp <- tempfile()
    saveObject(copy, tmp)
    out <- readObject(tmp)
    expect_tse_identical(out, copy)
    expect_null(rowTree(out))
    expect_null(referenceSeq(out))
})

test_that("saveObject preserves awkward labels and node numbering", {
    # Newick would mangle these labels and renumber the nodes of a postorder
    # tree.
    tree <- ape::reorder.phylo(row_tree, "postorder")
    tree[["tip.label"]][1:2] <- c(
        "k__Bacteria; p__Firmicutes", "it's (weird), isn't it")
    tree[["root.edge"]] <- 0.5
    copy <- tse
    rownames(copy) <- tree[["tip.label"]][
        match(rownames(tse), row_tree[["tip.label"]])]
    copy <- changeTree(copy, rowTree = tree)

    tmp <- tempfile()
    saveObject(copy, tmp)
    out <- readObject(tmp)
    expect_tse_identical(out, copy)
})

test_that("saveObject works with multiple trees", {
    # Create a second TreeSE with a renamed copy of the tree and combine.
    other <- tse
    rownames(other) <- paste0("OTHER_", rownames(other))
    other_tree <- row_tree
    other_tree[["tip.label"]] <- paste0("OTHER_", other_tree[["tip.label"]])
    other <- changeTree(other, rowTree = other_tree)
    combined <- rbind(tse, other)
    expect_identical(length(rowTreeNames(combined)), 2L)

    tmp <- tempfile()
    saveObject(combined, tmp)
    out <- readObject(tmp)
    expect_tse_identical(out, combined)
})

test_that("saveObject works with TreeSEs as alternative experiments", {
    copy <- tse
    altExp(copy, "subset") <- tse[1:5, ]

    tmp <- tempfile()
    saveObject(copy, tmp)
    out <- readObject(tmp)
    expect_s4_class(altExp(out, "subset"), "TreeSummarizedExperiment")
    expect_tse_identical(altExp(out, "subset"), altExp(copy, "subset"))
})

test_that("validateObject catches missing TreeSE components", {
    tmp <- tempfile()
    saveObject(tse, tmp)
    expect_error(validateObject(tmp), NA)

    # Links without trees should fail validation.
    unlink(file.path(tmp, "row_trees"), recursive = TRUE)
    expect_error(validateObject(tmp), "row_links")
})

test_that("dimensions and height are reported from the metadata", {
    tmp <- tempfile()
    saveObject(tse, tmp)
    meta <- readObjectFile(tmp)

    # Both functions read the dimensions recorded in the OBJECT file.
    expect_identical(
        .dimensions_tree_summarized_experiment(tmp, meta), dim(tse))
    expect_identical(
        .height_tree_summarized_experiment(tmp, meta), nrow(tse))
})

test_that("validateObject checks the dimensions of a nested TreeSE", {
    # A TreeSE as an alternative experiment must have as many columns as the
    # main experiment; takane uses the registered dimensions function for this.
    sce <- SingleCellExperiment(list(counts = mat))
    altExp(sce, "tree") <- tse

    tmp <- tempfile()
    saveObject(sce, tmp)
    expect_no_error(validateObject(tmp))

    # Replace the alternative experiment with a TreeSE that has fewer columns.
    # Both objects are valid on their own, but their column counts disagree.
    alt_path <- file.path(tmp, "alternative_experiments", "0")
    unlink(alt_path, recursive = TRUE)
    saveObject(tse[, 1:5], alt_path)
    expect_error(validateObject(tmp), "same number of columns")
})
