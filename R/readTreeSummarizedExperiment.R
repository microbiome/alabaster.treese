#' Read a TreeSummarizedExperiment from disk
#'
#' Read a \link[TreeSummarizedExperiment]{TreeSummarizedExperiment} object from
#' its on-disk representation. This is usually not directly called by users,
#' but is instead called by dispatch in
#' \code{\link[alabaster.base]{readObject}}.
#'
#' @param path String containing a path to a directory, itself created using
#' the \code{\link[alabaster.base]{saveObject}} method for
#' \link[TreeSummarizedExperiment]{TreeSummarizedExperiment} objects.
#'
#' @param metadata Named list of metadata for this object, see
#' \code{\link[alabaster.base]{readObjectFile}} for details.
#'
#' @param ... Further arguments passed to
#' \code{\link[alabaster.sce]{readSingleCellExperiment}} and internal
#' \code{\link[alabaster.base]{altReadObject}} calls.
#'
#' @return A \link[TreeSummarizedExperiment]{TreeSummarizedExperiment} object.
#'
#' @seealso
#' \code{"\link{saveObject,TreeSummarizedExperiment-method}"}, to save the
#' TreeSummarizedExperiment to disk.
#'
#' @examples
#' # Mocking up a TreeSE:
#' data(tinyTree, package = "TreeSummarizedExperiment")
#' mat <- matrix(rpois(100, 10), ncol = 10)
#' rownames(mat) <- tinyTree[["tip.label"]]
#' colnames(mat) <- letters[1:10]
#'
#' tse <- TreeSummarizedExperiment(list(counts = mat), rowTree = tinyTree)
#' tse[["stuff"]] <- LETTERS[1:10]
#' referenceSeq(tse) <- Biostrings::DNAStringSet(rep("ACGT", nrow(tse)))
#'
#' # Staging it:
#' tmp <- tempfile()
#' saveObject(tse, tmp)
#' readObject(tmp)
#'
#' @export
#' @importFrom alabaster.sce readSingleCellExperiment
#' @importFrom Biostrings DNAStringSetList
#' @import TreeSummarizedExperiment alabaster.base methods
readTreeSummarizedExperiment <- function(path, metadata, ...) {
    # Check that the data folder looks correct.
    validateObject(path, metadata)

    # Everything from the SingleCellExperiment parent class is read by
    # alabaster.sce.
    se <- readSingleCellExperiment(path, metadata, ...)

    # Read the row and column trees together with their links.
    row <- .read_trees(path, "row", ...)
    col <- .read_trees(path, "column", ...)

    # Read the reference sequences, if any were saved. A DNAStringSetList is
    # saved as a list of DNAStringSets, so it is coerced back here.
    ref <- NULL
    ref_path <- file.path(path, "reference_sequences")
    if (file.exists(ref_path)) {
        ref <- altReadObject(ref_path, ...)
        if (!is(ref, "DNAStringSet")) {
            ref <- DNAStringSetList(ref)
        }
    }

    # Filling the slots directly, as the setters would recompute the links.
    new("TreeSummarizedExperiment", se,
        rowTree = row[["trees"]], rowLinks = row[["links"]],
        colTree = col[["trees"]], colLinks = col[["links"]],
        referenceSeq = ref)
}

# Read all trees and the corresponding links for one dimension. 'prefix' is
# either "row" or "column". Returns a list with 'trees' and 'links', both of
# which are NULL if no trees were saved.
.read_trees <- function(path, prefix, ...) {
    tree_dir <- file.path(path, paste0(prefix, "_trees"))
    if (!file.exists(tree_dir)) {
        return(list(trees = NULL, links = NULL))
    }

    # Trees are stored in numbered subdirectories, in the order of their
    # names in 'names.json'.
    tree_names <- jsonlite::fromJSON(file.path(tree_dir, "names.json"))
    all_trees <- vector("list", length(tree_names))
    for (y in seq_along(tree_names)) {
        tree <- altReadObject(file.path(tree_dir, y - 1L), ...)
        all_trees[[y]] <- .unflatten_phylo(tree)
    }
    names(all_trees) <- tree_names

    # The links are stored as a data frame and converted back to a
    # LinkDataFrame.
    links <- altReadObject(file.path(path, paste0(prefix, "_links")), ...)
    list(trees = all_trees, links = new("LinkDataFrame", links))
}

# Reverse of .flatten_phylo(): rebuild the edge matrix from the parent and
# child vectors and restore the 'phylo' class and 'order' attribute.
.unflatten_phylo <- function(tree) {
    edge <- tree[["edge"]]
    tree[["edge"]] <- cbind(edge[["parent"]], edge[["child"]])
    class(tree) <- "phylo"
    attr(tree, "order") <- edge[["order"]]
    tree
}
