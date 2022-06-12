source("R/common.R")

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
# x = date_time or group_name
plot_a <- adiv_ps$alpha_div[[3]] %>%
  ggplot(aes(x = GROUP_name, y = value)) +
    geom_point() +
    geom_boxplot() +
    facet_wrap(~ aindex, scales = "free_y")

plot_b <- adiv_ps$alpha_div[[3]] %>%
  ggplot(aes(x = DATE_hour, y = value)) +
  geom_point() +
  geom_boxplot() +
  facet_wrap(~ aindex, scales = "free_y")

plot_c <- adiv_ps$alpha_div[[3]] %>%
  ggplot(aes(x = DATE_hour, y = value)) +
  geom_point() +
  geom_smooth(method = "lm", se=FALSE) +
  facet_wrap(~ aindex, scales = "free_y")

plot_c

# Save plot
#ggsave("alphadiv.pdf")