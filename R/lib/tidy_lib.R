#
# Library for tidying dataset
#
FastMelt.Q <- function(physeq, ...) {
  includeSampleVarsS <- ensyms(...)
  includeSampleVars <- purrr::map(includeSampleVarsS, rlang::as_string)

  return(FastMelt(physeq, includeSampleVars))
}

#' Melt phyloseq object into long table
FastMelt <- function(physeq, includeSampleVars = character()) {
  require("phyloseq")
  require("data.table")
  # Fixed output name
  name.sam <- "ID_sample"
  name.abn <- "abn"
  name.tax <- "TaxaID"

  # Check if data.table has these name.

  # supports "naked" otu_table as `physeq` input.
  otutab <- as(otu_table(physeq), "matrix")
  if (!taxa_are_rows(physeq)) {
    otutab <- t(otutab)
  }
  otudt <- data.table(otutab, keep.rownames = name.tax)
  # Enforce character TaxaID key
  otudt[, (name.tax) := as.character(get(name.tax))]
  # Melt count table
  mdt <- melt.data.table(otudt,
    id.vars = name.tax,
    variable.name = name.sam,
    value.name = name.abn
  )
  # If NA, put warning
  # mdt <- mdt[!is.na(abn)]
  if (!is.null(tax_table(physeq, errorIfNULL = FALSE))) {
    # If there is a tax_table, join with it. Otherwise, skip this join.
    taxdt <- data.table(as(tax_table(physeq, errorIfNULL = TRUE), "matrix"), keep.rownames = name.tax)
    taxdt[, (name.tax) := as.character(get(name.tax))]
    # Join with tax table
    setkeyv(taxdt, name.tax)
    setkeyv(mdt, name.tax)
    mdt <- taxdt[mdt]
  }

  # Save taxonomy columns

  wh.svars <- which(sample_variables(physeq) %in% includeSampleVars)
  if (length(wh.svars) > 0) {
    # Only attempt to include sample variables if there is at least one present in object
    sdf <- as(sample_data(physeq), "data.frame")[, wh.svars, drop = FALSE]
    sdt <- data.table(sdf, keep.rownames = name.sam)
    # Join with long table
    setkeyv(sdt, name.sam)
    setkeyv(mdt, name.sam)
    mdt <- sdt[mdt]
  }
  setkeyv(mdt, name.tax)
  return(mdt)
}

#' Get information
TidyAncom <- function(ancomobj, obj) {
  ancomobj %>%
    pluck("res", obj) %>%
    as_tibble(rownames = "clade_name") %>%
    pivot_longer(-clade_name, names_to = "features", values_to = obj)
}

TidyAncomAll <- function(ancomobj) {
  TidyAncom(ancomobj, "p_val") %>%
    left_join(TidyAncom(ancomobj, "q_val"), by = c("clade_name", "features")) %>%
    left_join(TidyAncom(ancomobj, "beta"), by = c("clade_name", "features")) %>%
    left_join(TidyAncom(ancomobj, "se"), by = c("clade_name", "features"))
}