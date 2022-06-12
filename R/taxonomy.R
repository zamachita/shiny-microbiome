source("R/common.R")

library(pheatmap)

hm_phy <- pheatmap(
  WideVar(ps.filt, phylum, 50),
  show_colnames = F,
  fontsize_col = 6
)

hm_phy
