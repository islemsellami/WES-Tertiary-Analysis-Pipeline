#!/usr/bin/env Rscript
# Step 13 - CNV detection from WES coverage with ExomeDepth (beta-binomial model).
#   Bayes factor (BF): < 3 no CNV | > 10 probable | > 30 very probable.
#   The correlation between patient and selected controls should exceed 0.97.
#
# Usage:
#   Rscript scripts/13_exomedepth.R <sample> <patient.bam> <controls_list.txt> <exons.bed> <outdir>
#   controls_list.txt: one control BAM path per line (same capture kit; patient excluded automatically)
suppressMessages({ library(ExomeDepth); library(GenomicRanges) })

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 5) stop("Usage: 13_exomedepth.R <sample> <patient.bam> <controls_list.txt> <exons.bed> <outdir>")
sample_id <- args[1]; patient_bam <- args[2]; controls_file <- args[3]
bed_path  <- args[4]; outdir <- args[5]
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# --- exons (BED with chr prefix) -------------------------------------------
bed <- read.table(bed_path, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
bed <- bed[, 1:4]; colnames(bed) <- c("chromosome", "start", "end", "name")
cat("Exons in BED:", nrow(bed), "\n")

# --- BAM files -------------------------------------------------------------
controls <- readLines(controls_file); controls <- controls[nzchar(controls)]
controls <- controls[normalizePath(controls) != normalizePath(patient_bam)]
stopifnot(length(controls) >= 2)
all_bams <- c(patient_bam, controls)

# --- read counting (long step: 1-2 h). The matrix is cached for reuse ----------
counts_file <- file.path(outdir, paste0("count_matrix_", sample_id, ".RData"))
if (file.exists(counts_file)) {
  load(counts_file)
} else {
  counts <- getBamCounts(bed.frame = bed, bam.files = all_bams, min.mapq = 20,
                         include.chr = FALSE)   # FALSE because the BED already has "chr"
  save(counts, file = counts_file)
}

bam_cols <- grep("\\.bam$", colnames(counts), value = TRUE)
patient_col <- bam_cols[1]                       # first BAM = patient
mat <- as.matrix(counts[, bam_cols]); storage.mode(mat) <- "numeric"
patient_counts   <- mat[, patient_col]
reference_counts <- mat[, colnames(mat) != patient_col, drop = FALSE]
cat("Patient total reads:", sum(patient_counts), "\n")
print(colSums(reference_counts))

# --- reference selection and model -------------------------------------------
choice <- select.reference.set(test.counts = patient_counts,
                               reference.counts = reference_counts,
                               bin.length = counts$end - counts$start)
cat("Selected controls:", choice$reference.choice, "\n")
reference_sel <- apply(reference_counts[, choice$reference.choice, drop = FALSE], 1, sum)

model <- new("ExomeDepth", test = patient_counts, reference = reference_sel,
             formula = "cbind(test, reference) ~ 1")

calls <- CallCNVs(x = model, transition.probability = 10^-4,
                  chromosome = as.character(counts$chromosome),
                  start = counts$start, end = counts$end,
                  name = counts$exon)            # the BED name column is called "exon" in the counts

res <- calls@CNV.calls
write.csv(res, file.path(outdir, paste0("CNV_raw_", sample_id, ".csv")), row.names = FALSE)
cat("Total CNV:", nrow(res), "\n")
cat("BF > 10  :", sum(res$BF > 10), "\n")
cat("BF > 30  :", sum(res$BF > 30), "\n")
