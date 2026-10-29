# Read a TreeSummarizedExperiment from disk

Read a
[TreeSummarizedExperiment](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-constructor.html)
object from its on-disk representation. This is usually not directly
called by users, but is instead called by dispatch in
[`readObject`](https://rdrr.io/pkg/alabaster.base/man/readObject.html).

## Usage

``` r
readTreeSummarizedExperiment(path, metadata, ...)
```

## Arguments

- path:

  String containing a path to a directory, itself created using the
  [`saveObject`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
  method for
  [TreeSummarizedExperiment](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-constructor.html)
  objects.

- metadata:

  Named list of metadata for this object, see
  [`readObjectFile`](https://rdrr.io/pkg/alabaster.base/man/readObjectFile.html)
  for details.

- ...:

  Further arguments passed to
  [`readSingleCellExperiment`](https://rdrr.io/pkg/alabaster.sce/man/readSingleCellExperiment.html)
  and internal
  [`altReadObject`](https://rdrr.io/pkg/alabaster.base/man/altReadObject.html)
  calls.

## Value

A
[TreeSummarizedExperiment](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-constructor.html)
object.

## See also

`"`[`saveObject,TreeSummarizedExperiment-method`](https://microbiome.github.io/alabaster.treese/reference/saveTreeSummarizedExperiment.md)`"`,
to save the TreeSummarizedExperiment to disk.

## Examples

``` r
# Mocking up a TreeSE:
data(tinyTree, package = "TreeSummarizedExperiment")
mat <- matrix(rpois(100, 10), ncol = 10)
rownames(mat) <- tinyTree[["tip.label"]]
colnames(mat) <- letters[1:10]

tse <- TreeSummarizedExperiment(list(counts = mat), rowTree = tinyTree)
tse[["stuff"]] <- LETTERS[1:10]
referenceSeq(tse) <- Biostrings::DNAStringSet(rep("ACGT", nrow(tse)))

# Staging it:
tmp <- tempfile()
saveObject(tse, tmp)
readObject(tmp)
#> class: TreeSummarizedExperiment 
#> dim: 10 10 
#> metadata(0):
#> assays(1): counts
#> rownames(10): t2 t7 ... t5 t3
#> rowData names(0):
#> colnames(10): a b ... i j
#> colData names(1): stuff
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
#> rowLinks: a LinkDataFrame (10 rows)
#> rowTree: 1 phylo tree(s) (10 leaves)
#> colLinks: NULL
#> colTree: NULL
#> referenceSeq: a DNAStringSet (10 sequences)
```
