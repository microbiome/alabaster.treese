# Save `TreeSummarizedExperiment`s to file

The **alabaster.treese** package implements methods for saving and
loading `TreeSummarizedExperiment` objects under the **alabaster**
framework. It provides a language-agnostic method for serializing the
row/column trees, their links and the reference sequences, along with
everything handled by
[**alabaster.sce**](https://bioconductor.org/packages/alabaster.sce) for
the `SingleCellExperiment` parent class.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`alabaster.treese`](https://github.com/microbiome/alabaster.treese)`)`\
`tmp`` ``<-`` `[`tempfile`](https://rdrr.io/r/base/tempfile.html)`(``)`\
[`saveObject`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)`(``tse``, ``tmp``)`\
`roundtrip`` ``<-`` `[`readObject`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)`(``tmp``)`
