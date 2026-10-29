.onLoad <- function(libname, pkgname) {
    # Register the reader so that readObject() dispatches to this package.
    registerReadObjectFunction(
        "tree_summarized_experiment", readTreeSummarizedExperiment)

    # The 'tree_summarized_experiment' type is not known to takane, so we need
    # to tell it how to validate it.
    registerValidateObjectFunction(
        "tree_summarized_experiment", .validate_tree_summarized_experiment)
    registerValidateObjectDimensionsFunction(
        "tree_summarized_experiment", .dimensions_tree_summarized_experiment)
    registerValidateObjectHeightFunction(
        "tree_summarized_experiment", .height_tree_summarized_experiment)
    registerValidateObjectSatisfiesInterface(
        "tree_summarized_experiment", "SUMMARIZED_EXPERIMENT")
    for (parent in .parent_types) {
        registerValidateObjectDerivedFrom("tree_summarized_experiment", parent)
    }
}

.onUnload <- function(libname, pkgname) {
    # Undo all registrations made in .onLoad().
    registerReadObjectFunction("tree_summarized_experiment", NULL)
    registerValidateObjectFunction("tree_summarized_experiment", NULL)
    registerValidateObjectDimensionsFunction("tree_summarized_experiment", NULL)
    registerValidateObjectHeightFunction("tree_summarized_experiment", NULL)
    registerValidateObjectSatisfiesInterface(
        "tree_summarized_experiment", "SUMMARIZED_EXPERIMENT",
        action = "remove")
    for (parent in .parent_types) {
        registerValidateObjectDerivedFrom(
            "tree_summarized_experiment", parent, action = "remove")
    }
}

# Types that a 'tree_summarized_experiment' is derived from.
.parent_types <- c(
    "summarized_experiment", "ranged_summarized_experiment",
    "single_cell_experiment")
