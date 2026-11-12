#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 14 - remove CNVs that are present in a healthy-population CNV map: a CNV seen in
# healthy individuals is considered benign; only absent CNVs remain pathogenic candidates.
# The population BED must use the "chr" prefix (convert with:
#   awk '{print "chr"$0}' population.bed > population_chr.bed ).
# Usage: SAMPLE=sample1 ./scripts/14_cnv_population_filter.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE/cnv"
CSV="$OUT/CNV_raw_${SAMPLE}.csv"

# ExomeDepth CSV columns: $3=type, $5=start, $6=end, $7=chromosome, $9=BF
awk -F',' 'NR>1 && $9+0 > 10 {
  gsub(/"/, "", $7); gsub(/"/, "", $3)
  type = ($3 ~ /deletion/) ? "DEL" : "DUP"
  printf "%s\t%s\t%s\t%s\t%s\n", $7, $5, $6, type, $9
}' "$CSV" > "$OUT/CNV_${SAMPLE}_BF10.bed"
echo "CNV with BF > 10: $(wc -l < "$OUT/CNV_${SAMPLE}_BF10.bed")"

bedtools intersect -a "$OUT/CNV_${SAMPLE}_BF10.bed" -b "$POPULATION_BED" -v \
  > "$OUT/CNV_${SAMPLE}_not_in_population.bed"
echo "Present in healthy population (removed): $(bedtools intersect -a "$OUT/CNV_${SAMPLE}_BF10.bed" -b "$POPULATION_BED" | wc -l)"
echo "Candidate pathogenic CNVs:"; cat "$OUT/CNV_${SAMPLE}_not_in_population.bed"
echo "Annotate them with AnnotSV (web server, see README): upload CNV_${SAMPLE}_not_in_population.bed"
