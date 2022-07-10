library(cli)
library(tidyverse)
library(ggplot2)
library(microbiome)
library(forcats)
library(cowplot)

source("R/lib/lhs.R")
source("R/lib/lib.R")
source("R/lib/plot.R")
source("R/lib/tidy_lib.R")

ps <- LoadFolder("data")
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