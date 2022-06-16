source("R/common.R")

library(microbiome)
library(vegan)

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
#' @importFrom phyloseq
#'
rarefaction_curve <- function(physeq, iter = 10, from = 3000, to = 9000) {
  crossing(depth = seq(from, to, 1000), iter = seq(iter)) %>%
    mutate(final = map2(depth, iter, ~ ps_obj.filt %>%
      rarefy_even_depth(.x) %>%
      microbiome::alpha(index = c("Chao1", "diversity_gini_simpson", "diversity_shannon")) %>%
      as_tibble(rownames = "ID_sample"))) %>%
    unnest(final)
}

aindex_labeler <- labeller(
  aindex = c(
    Chao1 = "Chao1",
    Shannon = "Shannon's index",
    Simpson = "Simpson's index"
  )
)

my_comparisons <- list(c("AD", "Control"))

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
        as_tibble(rownames = "ID_sample") %>%
        mutate(Simpson = -(diversity_gini_simpson - 1)) %>%
        dplyr::select(ID_sample, Chao1 = chao1, Simpson, Shannon = diversity_shannon) %>%
        pivot_longer(-ID_sample, names_to = "aindex", values_to = "value") %>%
        left_join(emetadata, by = "ID_sample")
    )
  )

# Plot
# x = date_time or group_name
# plot_a <- adiv_ps$alpha_div[[3]] %>%
#   ggplot(aes(x = GROUP_name, y = value)) +
#   geom_point() +
#   geom_boxplot() +
#   facet_wrap(~aindex, scales = "free_y")

# plot_b <- adiv_ps$alpha_div[[3]] %>%
#   ggplot(aes(x = DATE_hour, y = value)) +
#   geom_point() +
#   geom_boxplot() +
#   facet_wrap(~aindex, scales = "free_y")

# plot_c <- adiv_ps$alpha_div[[3]] %>%
#   ggplot(aes(x = DATE_hour, y = value)) +
#   geom_point() +
#   geom_smooth(method = "lm", se = FALSE) +
#   facet_wrap(~aindex, scales = "free_y")


# Example function for plotting
#' Args
#'  choose_x str
plot_alpha <- function(adiv, choose_rank, choose_x) {
  adiv_dat <- adiv %>%
    dplyr::filter(rank == choose_rank) %>%
    pull("alpha_div") %>%
    `[[`(1)

  x_sym <- ensym(choose_x) # create symbol
  adiv_dat %>%
    ggplot(aes(x = {{x_sym}}, y = value)) +  # Use symbol in programatic way
    geom_point() +
    geom_boxplot() +
    facet_wrap(~aindex, scales = "free_y")
}

# Usage
plot_alpha(adiv_ps, "phylum", "GROUP_name")
plot_alpha(adiv_ps, "phylum", "DATE_hour")


##
# Beta diversity
##
bdiv_ps <- tibble(
  ps = list(ps.filt)
) %>%
  expand_grid(rank=c("family", "ASV")) %>%
  expand_grid(a_distance=c("bray", "jaccard", "unifrac")) %>%  # Get sort metadata
  dplyr::filter(rank == "ASV" | a_distance != "unifrac") %>%
  rowwise() %>%
  mutate(
    dstmtx = list(ps %>% 
      AggregateTaxa(rank) %>%
      microbiome::transform("hellinger") %>%
      phyloseq::distance(method = a_distance, parallel = TRUE)),
    PCoA = list(cmdscale(dstmtx)
    ),
    NMDS_log = list(
      quietly(vegan::metaMDS)(dstmtx)
    ),
    NMDS = list(
      NMDS_log$result
    )
  )

# TODO: make this into function PLOT_NMDS
DAT <- bdiv_ps$NMDS[[3]]
METADATA <- ps.filt %>% meta() %>% as_tibble(rownames = "ID_samples")
COLOR <- "GROUP_name"

# TODO: make this into function PLOT_NMDS(nmds_dat, metadata, color)
COLOR_q <- ensym(COLOR)
DAT %>%
  vegan::scores(display = "sites") %>%
  as_tibble(rownames = "ID_samples") %>%
  left_join(METADATA) %>%
  ggplot(aes(x = NMDS1, y = NMDS2, color = {{COLOR_q}})) +
    geom_point() +
    stat_ellipse()

  

# TODO: make this into function REPORT_EXCEL
# DAT %>%
#   vegan::scores(display = "sites")
  


# TODO: Plot


# Export data
# TODO: Create function to export all data in excel.


# Save plot
# ggsave("alphadiv.pdf")
