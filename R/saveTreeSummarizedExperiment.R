#' Save a TreeSummarizedExperiment to disk
#'
#' Save a \link[TreeSummarizedExperiment]{TreeSummarizedExperiment} to its
#' on-disk representation.
#'
#' @param x A \link[TreeSummarizedExperiment]{TreeSummarizedExperiment} object
#' or one of its subclasses.
#'
#' @param path String containing the path to a directory in which to save
#' \code{x}.
#'
#' @param ... Further arguments to pass to
#' \code{"\link[alabaster.sce]{saveObject,SingleCellExperiment-method}"}.
#'
#' @details
#' Everything inherited from the
#' \link[SingleCellExperiment]{SingleCellExperiment} parent class is saved by
#' \pkg{alabaster.sce}. The TreeSummarizedExperiment-specific slots are saved as
#' follows:
#' \itemize{
#' \item Each tree in \code{\link[TreeSummarizedExperiment]{rowTree}} or
#' \code{\link[TreeSummarizedExperiment]{colTree}} is saved as a list
#' containing the fields of the \code{phylo} object, where the \code{edge}
#' matrix is split into \code{parent} and \code{child} vectors. This preserves
#' the node numbering and arbitrary tip/node labels, which would not survive a
#' round trip through Newick.
#' \item \code{\link[TreeSummarizedExperiment]{rowLinks}} and
#' \code{\link[TreeSummarizedExperiment]{colLinks}} are saved as data frames.
#' \item \code{\link[TreeSummarizedExperiment]{referenceSeq}} is saved as FASTA
#' via \pkg{alabaster.string}. A DNAStringSetList is saved as a list of such
#' sequence sets.
#' }
#'
#' @return \code{x} is saved into \code{path} and \code{NULL} is invisibly
#' returned.
#'
#' @seealso
#' \code{\link{readTreeSummarizedExperiment}}, to read the
#' TreeSummarizedExperiment back into the R session.
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
#' list.files(tmp, recursive = TRUE)
#'
#' @name saveTreeSummarizedExperiment
NULL

#' @export
#' @rdname saveTreeSummarizedExperiment
#' @import TreeSummarizedExperiment alabaster.base methods
#' @importMethodsFrom alabaster.string saveObject
setMethod("saveObject", "TreeSummarizedExperiment", function(x, path, ...) {
    # Everything from the SingleCellExperiment parent class is saved by
    # alabaster.sce.
    callNextMethod()

    # Save the row and column trees together with their links.
    .save_trees(
        x, rowTree(x, whichTree = NULL), rowLinks(x), path, "row", "rowTree",
        ...)
    .save_trees(
        x, colTree(x, whichTree = NULL), colLinks(x), path, "column",
        "colTree", ...)

    # Save the reference sequences, if any are present.
    ref <- referenceSeq(x)
    if (!is.null(ref)) {
        tryCatch({
            altSaveObject(ref, file.path(path, "reference_sequences"), ...)
        }, error = function(e) {
            stop(
                "failed to stage 'referenceSeq(<", class(x)[1], ">)'\n  - ",
                conditionMessage(e))
        })
    }

    # Overwrite the object type in the metadata written by the parent method.
    meta <- readObjectFile(path)
    meta[["tree_summarized_experiment"]] <- list(version = "1.0")
    saveObjectFile(path, "tree_summarized_experiment", meta)

    invisible(NULL)
})

# Save all trees and the corresponding links for one dimension. 'prefix' is
# either "row" or "column", and 'accessor' is only used in error messages.
# Nothing is saved if there are no trees.
.save_trees <- function(x, trees, links, path, prefix, accessor, ...) {
    tree_names <- names(trees)
    if (!length(tree_names)) {
        return(NULL)
    }

    # Each tree is saved in a numbered subdirectory, and the tree names are
    # saved separately in 'names.json' to preserve their order.
    tree_dir <- file.path(path, paste0(prefix, "_trees"))
    dir.create(tree_dir, showWarnings = FALSE)
    for (i in seq_along(tree_names)) {
        tryCatch({
            .save_phylo(trees[[i]], file.path(tree_dir, i - 1L), ...)
        }, error = function(e) {
            stop(
                "failed to stage '", accessor, "(<", class(x)[1], ">, \"",
                tree_names[i], "\")'\n  - ", conditionMessage(e))
        })
    }
    write(
        jsonlite::toJSON(tree_names), file = file.path(tree_dir, "names.json"))

    # The links are saved as a plain data frame.
    altSaveObject(
        as(links, "DFrame"), file.path(path, paste0(prefix, "_links")), ...)
}

# Save a single 'phylo' object. Any user-supplied 'list.format' is captured
# here so that it is not passed twice to altSaveObject().
.save_phylo <- function(tree, path, ..., list.format) {
    # Always using HDF5, as the JSON format loses precision in the branch
    # lengths.
    altSaveObject(.flatten_phylo(tree), path, list.format = "hdf5", ...)
}

# Convert a 'phylo' object into a basic list that alabaster.base can save.
.flatten_phylo <- function(tree) {
    # The edge matrix is split into vectors so that it can be saved as a basic
    # list; the 'order' attribute describes the ordering of edges, so we keep
    # it there.
    edge <- list(parent = tree[["edge"]][, 1], child = tree[["edge"]][, 2])
    edge[["order"]] <- attr(tree, "order")
    tree <- unclass(tree)
    attr(tree, "order") <- NULL
    tree[["edge"]] <- edge
    tree
}
