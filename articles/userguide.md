# Saving \`TreeSummarizedExperiment\`s to artifacts and back again

## Overview

The
*[alabaster.treese](https://bioconductor.org/packages/3.24/alabaster.treese)*
package implements methods to save `TreeSummarizedExperiment` objects to
file artifacts and load them back into R. It extends
*[alabaster.sce](https://bioconductor.org/packages/3.24/alabaster.sce)*,
which handles everything from the `SingleCellExperiment` parent class.
Check out the
*[alabaster.base](https://bioconductor.org/packages/3.24/alabaster.base)*
for more details on the motivation and concepts of the **alabaster**
framework.

## Quick start

Given a `TreeSummarizedExperiment`, we can use
[`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
to save it inside a staging directory:

\
`# Mock up a TreeSE with a row tree and reference sequences.`\
[`library`](https://rdrr.io/r/base/library.html)`(``TreeSummarizedExperiment``)`\
[`data`](https://rdrr.io/r/utils/data.html)`(``tinyTree``)`\
`mat`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rpois`](https://rdrr.io/r/stats/Poisson.html)`(``100``, ``10``)``, ncol ``=`` ``10``)`\
[`rownames`](https://rdrr.io/r/base/colnames.html)`(``mat``)`` ``<-`` ``tinyTree``[[``"tip.label"``]``]`\
[`colnames`](https://rdrr.io/r/base/colnames.html)`(``mat``)`` ``<-`` ``letters``[``1``:``10``]`\
\
`tse`` ``<-`` `[`TreeSummarizedExperiment`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-constructor.html)`(`[`list`](https://rdrr.io/r/base/list.html)`(``counts ``=`` ``mat``)``, rowTree ``=`` ``tinyTree``)`\
`tse``[[``"stuff"``]``]`` ``<-`` ``LETTERS``[``1``:``10``]`\
[`referenceSeq`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)`(``tse``)`` ``<-`` ``Biostrings``::`[`DNAStringSet`](https://rdrr.io/pkg/Biostrings/man/XStringSet-class.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(``"ACGT"``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``tse``)``)``)`\
`tse`

    ## class: TreeSummarizedExperiment 
    ## dim: 10 10 
    ## metadata(0):
    ## assays(1): counts
    ## rownames(10): t2 t7 ... t5 t3
    ## rowData names(0):
    ## colnames(10): a b ... i j
    ## colData names(1): stuff
    ## reducedDimNames(0):
    ## mainExpName: NULL
    ## altExpNames(0):
    ## rowLinks: a LinkDataFrame (10 rows)
    ## rowTree: 1 phylo tree(s) (10 leaves)
    ## colLinks: NULL
    ## colTree: NULL
    ## referenceSeq: a DNAStringSet (10 sequences)

\
`# Save it into a staging directory.`\
[`library`](https://rdrr.io/r/base/library.html)`(`[`alabaster.treese`](https://github.com/microbiome/alabaster.treese)`)`\
`tmp`` ``<-`` `[`tempfile`](https://rdrr.io/r/base/tempfile.html)`(``)`\
[`saveObject`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)`(``tse``, ``tmp``)`\
\
[`list.files`](https://rdrr.io/r/base/list.files.html)`(``tmp``, recursive ``=`` ``TRUE``)`

    ##  [1] "_environment.json"                     
    ##  [2] "assays/0/array.h5"                     
    ##  [3] "assays/0/OBJECT"                       
    ##  [4] "assays/names.json"                     
    ##  [5] "column_data/basic_columns.h5"          
    ##  [6] "column_data/OBJECT"                    
    ##  [7] "OBJECT"                                
    ##  [8] "reference_sequences/names.txt.gz"      
    ##  [9] "reference_sequences/OBJECT"            
    ## [10] "reference_sequences/sequences.fasta.gz"
    ## [11] "row_data/basic_columns.h5"             
    ## [12] "row_data/OBJECT"                       
    ## [13] "row_links/basic_columns.h5"            
    ## [14] "row_links/OBJECT"                      
    ## [15] "row_trees/0/list_contents.h5"          
    ## [16] "row_trees/0/OBJECT"                    
    ## [17] "row_trees/names.json"

We can then load it back into the session with
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html).

\
`# Load the TreeSE back from disk.`\
`roundtrip`` ``<-`` `[`readObject`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)`(``tmp``)`\
[`class`](https://rdrr.io/r/base/class.html)`(``roundtrip``)`

    ## [1] "TreeSummarizedExperiment"
    ## attr(,"package")
    ## [1] "TreeSummarizedExperiment"

## On-disk representation

Each tree in
[`rowTree()`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
or
[`colTree()`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
is saved as a list containing the fields of its `phylo` object, with the
`edge` matrix split into `parent` and `child` vectors. We do not use
Newick as it does not preserve the node numbering (which is referenced
by
[`rowLinks()`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
and
[`colLinks()`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html))
or labels containing special characters. Users who need a Newick file
for other tools can always create one with
[`ape::write.tree()`](https://rdrr.io/pkg/ape/man/write.tree.html). The
links themselves are saved as data frames, while the
[`referenceSeq()`](https://rdrr.io/pkg/TreeSummarizedExperiment/man/TreeSummarizedExperiment-accessor.html)
is saved as FASTA via
*[alabaster.string](https://bioconductor.org/packages/3.24/alabaster.string)*.

## Session information

\
[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`

    ## R version 4.6.1 (2026-06-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.5 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] alabaster.treese_0.99.0         alabaster.base_1.13.4          
    ##  [3] TreeSummarizedExperiment_2.21.0 Biostrings_2.81.9              
    ##  [5] XVector_0.53.0                  SingleCellExperiment_1.35.2    
    ##  [7] SummarizedExperiment_1.43.0     Biobase_2.73.2                 
    ##  [9] GenomicRanges_1.65.4            Seqinfo_1.3.2                  
    ## [11] IRanges_2.47.5                  S4Vectors_0.51.10              
    ## [13] BiocGenerics_0.59.12            generics_0.1.4                 
    ## [15] MatrixGenerics_1.25.0           matrixStats_1.5.0              
    ## [17] BiocStyle_2.41.0               
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] xfun_0.62                bslib_0.12.0             alabaster.string_1.13.1 
    ##  [4] htmlwidgets_1.6.4        rhdf5_2.57.20            lattice_0.23-1          
    ##  [7] rhdf5filters_1.25.4      yulab.utils_0.2.5        vctrs_0.7.3             
    ## [10] tools_4.6.1              parallel_4.6.1           tibble_3.3.1            
    ## [13] pkgconfig_2.0.3          Matrix_1.7-6             desc_1.4.3              
    ## [16] lifecycle_1.0.5          compiler_4.6.1           treeio_1.37.1           
    ## [19] textshaping_1.0.5        alabaster.se_1.13.1      codetools_0.2-20        
    ## [22] htmltools_0.5.9          sass_0.4.10              alabaster.matrix_1.13.4 
    ## [25] yaml_2.3.12              lazyeval_0.2.3           pkgdown_2.2.1           
    ## [28] pillar_1.11.1            crayon_1.5.3             jquerylib_0.1.4         
    ## [31] tidyr_1.3.2              BiocParallel_1.47.0      DelayedArray_0.39.8     
    ## [34] cachem_1.1.0             abind_1.4-8              nlme_3.1-171            
    ## [37] tidyselect_1.2.1         digest_0.6.39            purrr_1.2.2             
    ## [40] dplyr_1.2.1              bookdown_0.48            fastmap_1.2.0           
    ## [43] grid_4.6.1               cli_3.6.6                SparseArray_1.13.4      
    ## [46] magrittr_2.0.5           S4Arrays_1.13.2          h5mread_1.5.3           
    ## [49] ape_5.8-1                rappdirs_0.3.4           rmarkdown_2.32          
    ## [52] otel_0.2.0               ragg_1.5.2               HDF5Array_1.41.3        
    ## [55] alabaster.sce_1.13.1     evaluate_1.0.5           knitr_1.52              
    ## [58] rlang_1.3.0              Rcpp_1.1.2               glue_1.8.1              
    ## [61] tidytree_0.4.8           BiocManager_1.30.27      alabaster.ranges_1.13.1 
    ## [64] alabaster.schemas_1.13.0 jsonlite_2.0.0           Rhdf5lib_2.1.0          
    ## [67] R6_2.6.1                 systemfonts_1.3.2        fs_2.1.0
