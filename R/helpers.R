library(tidyverse)
library(ggplot2)
library(microbiome)
library(forcats)
library(cowplot)

source("R/lib/lhs.R")
source("R/lib/lib.R")
source("R/lib/plot.R")


ps <- ReadQiime2(
  "data/asv.tab", "data/taxonomy.tsv",
  "data/repsep.fasta", "data/rooted-tree.nwk",
  "data/metadata.tsv")


# Calculate fecal and oral separately

SimpleFilter <- function(.ps) {
  prev_phylum <- .ps %>% CalcPrev %>% SumPrev(phylum) %>% arrange(maxprev)
  rmv_phylum <- prev_phylum %>% dplyr::filter(maxprev < 3 & sumabn < 100) %>% pull(phylum)
  
  .ps.filt <- .ps %>% with_taxa(kingdom == "Bacteria" & phylum != "") %>%
    with_taxa(! phylum %in% rmv_phylum) %>%
    prune_taxa(taxa_sums(.) > 10, .)
  
  return(.ps.filt)
}

ps.filt <- SimpleFilter(ps)

dtheme <- theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        strip.background = element_rect(fill="grey"))

theme_set(dtheme)

a1_pallete <- c(
  "#F0A0FF","#0075DC","#993F00","#4C005C","#191919","#005C31",
  "#2BCE48","#FFCC99","#808080","#94FFB5","#8F7C00","#9DCC00",
  "#C20088","#003380","#FFA405","#FFA8BB","#426600","#FF0010",
  "#5EF1F2","#00998F","#E0FF66","#740AFF","#990000","#FFFF80",
  "#FFE100","#FF5005")

emetadata <- read_tsv("data/metadata.tsv",
                      na=c("", "#N/A", "NA"),
                      show_col_types = FALSE) %>%
  mutate(
    across(starts_with("GROUP"), ~ factor(.))
  )

sample_data(ps.filt) <- sample_data(emetadata %>% column_to_rownames("ID_sample"))

#OUTPUT_TAXA_EXCEL <- "output/taxa_xcel"
#dir.create(OUTPUT_TAXA_EXCEL, recursive=TRUE)

###
### ALPHA DIVERSITY
###


#' Calculate the rarify curve
#' 
#' 
#' @param pseqobj Phyloseq object
#' @param rarefaction
#' 
#' @seealso \code{\link[Microbiome]{alpha}}
#' 
#' @examples
#' 
#' @importFrom phyloseq
#' 
rarefaction_curve <- function(physeq, iter=10, from=3000, to=9000){
  crossing(depth = seq(from, to, 1000), iter = seq(iter)) %>%
    mutate(final = map2(depth, iter, ~ ps_obj.filt %>%
                          rarefy_even_depth(.x) %>%
                          microbiome::alpha(index = c("Chao1", "diversity_gini_simpson", "diversity_shannon")) %>%
                          as_tibble(rownames="ID_sample"))) %>%
    unnest(final)
}

# Calculate all at once.
# div.alpha <- microbiome::alpha(ps_obj.filt, index = "all") %>%
#   as_tibble(rownames="ID_SAMPLE") %>%
#   mutate(Simpson = -(diversity_gini_simpson-1)) %>%
#   dplyr::select(ID_SAMPLE, Chao1 = chao1, Simpson, Shannon = diversity_shannon) %>%
#   pivot_longer(-ID_SAMPLE, names_to= "aindex", values_to = "value") %>%
#   left_join(emetadata, by="ID_SAMPLE")


# Plot the first one
# tibble(
#   ps=list(ps_obj01.filt, ps_obj02.filt, ps_obj03.filt)
# )

# Boxplot
aindex_labeler <- labeller(
  aindex = c(
    Chao1 = "Chao1",
    Shannon = "Shannon's index",
    Simpson = "Simpson's index"))

my_comparisons <- list( c("AD", "Control") )

adiv_ps <- tibble(
  ps = list(ps.filt)
) %>%
  expand_grid(
    rank = c("phylum", "family", "ASV")
  ) %>%
  rowwise() %>%
  mutate(
    alpha_div = list(
      ps %>%
        AggregateTaxa(rank) %>%
        microbiome::alpha(index = "all") %>%
        as_tibble(rownames="ID_sample") %>%
        mutate(Simpson = -( diversity_gini_simpson - 1 )) %>%
        dplyr::select(ID_sample, Chao1 = chao1, Simpson, Shannon = diversity_shannon) %>%
        pivot_longer(-ID_sample, names_to= "aindex", values_to = "value") %>%
        left_join(emetadata, by="ID_sample")
    )
  )

# Plot
# x = group_name or date_time
plot_a <- adiv_ps$alpha_div[[3]] %>%
  ggplot(aes(x = GROUP_name, y = value)) +
  geom_point() +
  geom_boxplot() +
  facet_wrap(~ aindex, scales = "free_y")

hm_phy <- pheatmap(
  WideVar(ps.filt, phylum, 50),
  show_colnames = F,
  fontsize_col = 6
)

# Save plot
#ggsave("alphadiv.pdf")