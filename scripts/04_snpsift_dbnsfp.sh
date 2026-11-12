#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 4 - add 16 pathogenicity and conservation scores from dbNSFP 5.3.1a.
# Scores: SIFT, PolyPhen-2, CADD, REVEL, AlphaMissense, fathmm-XF, Eigen-phred,
# MutationAssessor, BayesDel_noAF, phastCons (3 alignments), phyloP (3 alignments),
# 1000 Genomes AF.
# Usage: SAMPLE=sample1 ./scripts/04_snpsift_dbnsfp.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"
FIELDS="SIFT_score,Polyphen2_HDIV_score,CADD_phred,REVEL_score,AlphaMissense_score,fathmm-XF_coding_score,Eigen-phred_coding,MutationAssessor_score,phastCons100way_vertebrate,phastCons470way_mammalian,phastCons17way_primate,phyloP100way_vertebrate,phyloP470way_mammalian,phyloP17way_primate,1000Gp3_AF,BayesDel_noAF_score"

java $JAVA_LARGE -jar "$SNPSIFT_JAR" dbnsfp -db "$DBNSFP" -f "$FIELDS" \
  "$OUT/step3.dbsnp.vcf" > "$OUT/step4.dbnsfp.raw.vcf"

# Some Windows-side runs write UTF-16 with a BOM: normalise to UTF-8.
if file "$OUT/step4.dbnsfp.raw.vcf" | grep -qi 'UTF-16'; then
  iconv -f UTF-16 -t UTF-8 "$OUT/step4.dbnsfp.raw.vcf" > "$OUT/step4.dbnsfp.vcf"
else
  cp "$OUT/step4.dbnsfp.raw.vcf" "$OUT/step4.dbnsfp.vcf"
fi

echo "Variants: $(grep -vc '^#' "$OUT/step4.dbnsfp.vcf")"
echo "dbNSFP fields declared in the header (expected: 16):"
grep '##INFO=<ID=dbNSFP' "$OUT/step4.dbnsfp.vcf" | grep -o 'ID=[^,]*' | wc -l
# Field names use underscores in the VCF (e.g. dbNSFP_fathmm_XF_coding_score).
