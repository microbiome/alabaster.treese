# Save `TreeSummarizedExperiment`s to file

The **alabaster.treese** package implements methods for saving and loading
`TreeSummarizedExperiment` objects under the **alabaster** framework.
It provides a language-agnostic method for serializing the row/column trees,
their links and the reference sequences,
along with everything handled by
[**alabaster.sce**](https://bioconductor.org/packages/alabaster.sce) for the
`SingleCellExperiment` parent class.

```r
library(alabaster.treese)
tmp <- tempfile()
saveObject(tse, tmp)
roundtrip <- readObject(tmp)
```
