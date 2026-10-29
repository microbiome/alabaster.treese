# takane does not know about the 'tree_summarized_experiment' type, so these
# functions are registered in .onLoad to support validation by validateObject.

.validate_tree_summarized_experiment <- function(path, metadata) {
    # Everything from the parent class is validated by takane.
    metadata[["type"]] <- "single_cell_experiment"
    validateObject(path, metadata)

    # Validate the trees and links for both dimensions.
    for (prefix in c("row", "column")) {
        tree_dir <- file.path(path, paste0(prefix, "_trees"))
        link_dir <- file.path(path, paste0(prefix, "_links"))

        # Links are only meaningful if trees are present.
        if (!file.exists(tree_dir)) {
            if (file.exists(link_dir)) {
                stop(
                    "'", prefix, "_links' should not be present without '",
                    prefix, "_trees'")
            }
            next
        }

        # Tree names must be unique and non-missing.
        tree_names <- jsonlite::fromJSON(file.path(tree_dir, "names.json"))
        if (!length(tree_names) || anyNA(tree_names) ||
            anyDuplicated(tree_names)) {
            stop(
                "expected unique non-missing names in '", prefix,
                "_trees/names.json'")
        }

        # Each tree and the links are validated as regular alabaster objects.
        for (y in seq_along(tree_names)) {
            validateObject(file.path(tree_dir, y - 1L))
        }
        validateObject(link_dir)
    }

    # Validate the reference sequences, if any were saved.
    ref_path <- file.path(path, "reference_sequences")
    if (file.exists(ref_path)) {
        validateObject(ref_path)
    }

    invisible(NULL)
}

# Dimensions are taken from the 'summarized_experiment' metadata.
.dimensions_tree_summarized_experiment <- function(path, metadata) {
    se_meta <- metadata[["summarized_experiment"]]
    as.integer(unlist(se_meta[["dimensions"]]))
}

# The height is the number of rows.
.height_tree_summarized_experiment <- function(path, metadata) {
    .dimensions_tree_summarized_experiment(path, metadata)[1]
}
