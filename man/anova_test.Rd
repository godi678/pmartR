% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/anova_test.R
\name{anova_test}
\alias{anova_test}
\title{Tests for a quantiative difference between groups (aka factors, aka main effects)}
\usage{
anova_test(omicsData, comparisons = NULL, pval_adjust = "none",
  pval_thresh = 0.05, covariates = NULL, paired = FALSE,
  equal_var = TRUE)
}
\arguments{
\item{omicsData}{A pmartR data object of any class}

\item{comparisons}{data.frame with columns for "Control" and "Test" containing the different comparisons of interest. Comparisons will be made between the Test and the corresponding Control  If left NULL, then all pairwise comparisons are executed.}

\item{pval_adjust}{character vector specifying the type of multiple comparisons adjustment to implement. An unspecified value corresponds to no adjustment. Valid options include: holm, bonferroni, Tukey, Dunnett, none.}

\item{pval_thresh}{numeric p-value threshold, below or equal to which peptides are considered differentially expressed. Defaults to 0.05}

\item{covariates}{data.frame similar to \code{groupData} consisting of two columsn: the sample ID variable (with names matching column names in \code{omicsData$e_data}) and a column containing the numeric or group data for each sample}

\item{paired}{logical; should the data be paired or not? if TRUE then the `f_data` element of `omicsData` is checked for a "Pair" column, an error is returned if none is found}

\item{equal_var}{logical; should the variance across groups be assumed equal?}
}
\value{
a list of `data.frame`s
\tabular{ll}{
Results  \tab Edata cname, Variance Estimate, ANOVA F-Statistic, ANOVA p-value, Group means\cr
 \tab \cr
Fold_changes  \tab Estimated fold-changes for each comparison \cr
 \tab \cr
Fold_changes_pvalues  \tab P-values corresponding to the fold-changes for each comparison \cr
 \tab \cr
Fold_change_flags  \tab Indicator of statistical significance (0/+-2 to if adjusted p-value>=pval_thresh or p-value<pval_thresh) \cr
 }
}
\description{
This is the ANOVA part of the IMD-ANOVA test proposed in Webb-Robertson et al. (2010).
}
\details{
The order in which different scenarios are handeled:
\enumerate{
 \item If the data are paired, then the pairing is accounted for first then each of the next steps is carried out on the new variable that is 
 the difference in the paired individuals.<br>
 \item If covariates are provided, their effect is removed before testing for group differences though mathematically covariates and grouping 
 effects are accounted for simultaneously
 \item ANOVA is executed to assess the effect of each main effects, results in a vector of group means for each biomolecule and variance estimate
 \item Group comparisons defined by `comaprison` argument are implemented use parameter vector and variance estimates in ANOVA step
}
}
\examples{
dontrun{
library(pmartRdata)
library(pmartR)
mypepData <- edata_transform(omicsData = pep_object, data_scale = "log2")
mypepData <- group_designation(omicsData = mypepData, main_effects = c("Condition"))

#Try running anova_test without filtering, should get warning because the data haven't been filtered yet
anova_res <- anova_test(omicsData = mypepData) 

#Now filter and run again
imdanova_Filt <- imdanova_filter(omicsData = mypepData)
mypepData <- applyFilt(filter_object = imdanova_Filt, omicsData = mypepData, min_nonmiss_anova=2)
anova_res <- anova_test(omicsData = mypepData)
anova_res_tukey <- anova_test(omicsData = mypepData, pval_adjust = 'tukey') 
#Should be equivalent to above since only making one comparison
all(anova_res$Comparison==anova_res_tukey$Comparisons)

#If group IDs are treated as a covariate, all of the fold changes should be zero
covars <- attr(mypepData, "group_DF")
colnames(covars)[2] <- "Gp"
anova_res <- anova_test(omicsData = mypepData, covariates = covars)
summary(anova_res$Fold_changes)

#Test with really big dataset, one factor
library(OvarianPepdataBPsubset)
tcga_ovarian_pepdata_bp <- as.pepData(e_data = tcga_ovarian_pepdata_bp_subset$e_data, f_data = tcga_ovarian_pepdata_bp_subset$f_data, e_meta = tcga_ovarian_pepdata_bp_subset$e_meta, edata_cname = "Peptide", fdata_cname = "sampleID", emeta_cname = "Protein", check.names = FALSE)
tcga_ovarian_pepdata_bp <- group_designation(omicsData = tcga_ovarian_pepdata_bp, main_effects = c("vital_status"))
tcga_ovarian_pepdata_bp <- edata_transform(tcga_ovarian_pepdata_bp, "log2")
imdanova_Filt <- imdanova_filter(omicsData = tcga_ovarian_pepdata_bp)
tcga_ovarian_pepdata_bp <- applyFilt(filter_object = imdanova_Filt, omicsData = tcga_ovarian_pepdata_bp, min_nonmiss_anova=2)
ovarian_res <- anova_test(omicsData = tcga_ovarian_pepdata_bp) 
#Tukey adjustment is super slow right now because "ptukey" is super slow, not sure how to fix that
ovarian_res_tukey <- anova_test(omicsData = tcga_ovarian_pepdata_bp, pval_adjust = 'tukey') 
#Dunnett adjustment, super slow because mvtnorm::pmvt is super slow
ovarian_res_dunnett <- anova_test(omicsData = tcga_ovarian_pepdata_bp, pval_adjust = 'dunnett') 

#Test really big dataset, two factors, all pairwise comparisons
tcga_ovarian_pepdata_bp <- group_designation(omicsData = tcga_ovarian_pepdata_bp, main_effects = c("vital_status","neoplasm_histologic_grade"))
ovarian_res_twofac <- anova_test(omicsData = tcga_ovarian_pepdata_bp)

#Same but only test main effects (Dead vs Alive, G2 vs G3)
comp_df <- data.frame(Control=c("Alive","G2"), Test=c("Dead","G3"))
ovarian_res_twofac_main_effects <- anova_test(omicsData = tcga_ovarian_pepdata_bp, comparisons = comp_df)

#Same but only test arbitrary diagonal effects (Dead_G2 vs Alive_G3, Alive_G2 vs Alive_G3)
comp_df <- data.frame(Control=c("Dead_G2","Alive_G2"), Test=c("Alive_G3","Alive_G3"))
ovarian_res_twofac_arb_effects <- anova_test(omicsData = tcga_ovarian_pepdata_bp, comparisons = comp_df)
}
}
\references{
Webb-Robertson, Bobbie-Jo M., et al. "Combined statistical analyses of peptide intensities and peptide occurrences improves identification of significant peptides from MS-based proteomics data." Journal of proteome research 9.11 (2010): 5748-5756.
}
\author{
Bryan Stanfill
}
