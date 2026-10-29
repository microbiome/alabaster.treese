# Save a TreeSummarizedExperiment to disk

Save a
[TreeSummarizedExperiment](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-constructor.html)
to its on-disk representation.

## Usage

``` r
# S4 method for class 'TreeSummarizedExperiment'
saveObject(x, path, ...)
```

## Arguments

- x:

  A
  [TreeSummarizedExperiment](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-constructor.html)
  object or one of its subclasses.

- path:

  String containing the path to a directory in which to save `x`.

- ...:

  Further arguments to pass to
  `"`[`saveObject,SingleCellExperiment-method`](https://rdrr.io/pkg/alabaster.sce/man/saveSingleCellExperiment.html)`"`.

## Value

`x` is saved into `path` and `NULL` is invisibly returned.

## Details

Everything inherited from the
[SingleCellExperiment](https://rdrr.io/pkg/SingleCellExperiment/man/SingleCellExperiment.html)
parent class is saved by alabaster.sce. The
TreeSummarizedExperiment-specific slots are saved as follows:

- Each tree in
  [`rowTree`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
  or
  [`colTree`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
  is saved as a list containing the fields of the `phylo` object, where
  the `edge` matrix is split into `parent` and `child` vectors. This
  preserves the node numbering and arbitrary tip/node labels, which
  would not survive a round trip through Newick.

- [`rowLinks`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
  and
  [`colLinks`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
  are saved as data frames.

- [`referenceSeq`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
  is saved as FASTA via alabaster.string. A DNAStringSetList is saved as
  a list of such sequence sets.

## See also

[`readTreeSummarizedExperiment`](https://microbiome.github.io/alabaster.treese/reference/readTreeSummarizedExperiment.md),
to read the TreeSummarizedExperiment back into the R session.

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
list.files(tmp, recursive = TRUE)
#>  [1] "OBJECT"                                
#>  [2] "_environment.json"                     
#>  [3] "assays/0/OBJECT"                       
#>  [4] "assays/0/array.h5"                     
#>  [5] "assays/names.json"                     
#>  [6] "column_data/OBJECT"                    
#>  [7] "column_data/basic_columns.h5"          
#>  [8] "reference_sequences/OBJECT"            
#>  [9] "reference_sequences/names.txt.gz"      
#> [10] "reference_sequences/sequences.fasta.gz"
#> [11] "row_data/OBJECT"                       
#> [12] "row_data/basic_columns.h5"             
#> [13] "row_links/OBJECT"                      
#> [14] "row_links/basic_columns.h5"            
#> [15] "row_trees/0/OBJECT"                    
#> [16] "row_trees/0/list_contents.h5"          
#> [17] "row_trees/names.json"                  
```
