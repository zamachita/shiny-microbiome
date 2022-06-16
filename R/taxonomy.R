source("R/common.R")

library(pheatmap)
library(ANCOMBC)

hm_phy <- pheatmap(
  WideVar(ps.filt, phylum, 50),
  show_colnames = F,
  fontsize_col = 6
)

hm_phy

##
# Statistics
##

PS <- ps_filt
stats_ttest <- tibble(
    rank = c("phylum", "order", "family", "genus", "ASV")
  ) %>%
  rowwise() %>%
  mutate(
    df_melt = list(
      ps.filt %>%
        AggregateTaxa(rank) %>%
        microbiome::transform("hellinger") %>%
        FastMelt(c("GROUP_name", "DATE_hour"))  # TODO, use column from metadata instead of hard code
    ),
    stat_ttest_log = list(
      df_melt %>%
        group_by(TaxaID, c_age.group) %>%  # TODO let user choose which column to use instead of hardcode (c_age.group)
        quietly(t_test)(abn ~ GROUP_name)    # TODO let user choose which column to use instead of hardcode (GROUP_name)
    ),
    stat_ttest = list(
      stat_ttest_log %>%
        pluck("result") %>%
        dplyr::filter(! is.nan(df)) %>%
        group_by(c_age.group) %>%  # TODO let user choose which column to use instead of hardcode (c_age.group)
        adjust_pvalue(method = "holm") %>%
        add_significance("p.adj")
    )
  )

PS_OBJ <- ps.filt

stats_ancom <- tibble(
  ps = list(PS_OBJ)
) %>%
  expand_grid(rank = c("family", "genus", "ASV")) %>%
  rowwise() %>%
  mutate(
    stat_ancom_reduced = list(PS_OBJ %>%
      AggregateTaxa(rank) %>%
      ancombc(phyloseq = ., formula = "GROUP_name")
    ),
    stat_ancom_interact = list(PS_OBJ %>%
      AggregateTaxa(rank) %>%
      ancombc(phyloseq = ., formula = "DATE_hour * GROUP_name")
    )
  )

stats_ancom <- stats_ancom %>%
  ungroup() %>%
  mutate(
    across(
      starts_with("stat_ancom"),
      ~ map(., TidyAncomAll),
      .names = "tidy_{col}"
    )
  )


# TODO
# 1. Let user choose which rank to export (phylum, order, family)
# 2. Show table stats_ancom$tidy_stat_ancom_reduced[[1]]
