#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 9 - export the annotated VCF as a 31-column TSV (Excel / R / Python friendly):
# position, SnpEff annotation, 16 dbNSFP scores, ClinVar fields and genotypes.
# Usage (single sample): SAMPLE=sample1 ./scripts/09_extract_fields.sh
#        (trio, AR final): FAMILY=fam1 MODE=trio ./scripts/09_extract_fields.sh
MODE="${MODE:-single}"
FIELDS=(CHROM POS REF ALT ID "ANN[0].GENE" "ANN[0].EFFECT" "ANN[0].IMPACT" "ANN[0].HGVS_C" "ANN[0].HGVS_P" "dbNSFP_SIFT_score" "dbNSFP_Polyphen2_HDIV_score" "dbNSFP_CADD_phred" "dbNSFP_REVEL_score" "dbNSFP_AlphaMissense_score" "dbNSFP_fathmm_XF_coding_score" "dbNSFP_Eigen_phred_coding" "dbNSFP_MutationAssessor_score" "dbNSFP_BayesDel_noAF_score" "dbNSFP_phastCons100way_vertebrate" "dbNSFP_phastCons470way_mammalian" "dbNSFP_phastCons17way_primate" "dbNSFP_phyloP100way_vertebrate" "dbNSFP_phyloP470way_mammalian" "dbNSFP_phyloP17way_primate" "dbNSFP_1000Gp3_AF" "CLNDN" "CLNHGVS" "CLNREVSTAT" "CLNSIG")
if [ "$MODE" = "trio" ]; then
  : "${FAMILY:?Set FAMILY}"
  TRIO="$WORKDIR/${FAMILY}-trio"
  IN="$TRIO/trio.AR.final.vcf"; OUTTSV="$TRIO/extract_${FAMILY}_trio_AR.tsv"
  GT=("GEN[0].GT" "GEN[1].GT" "GEN[2].GT")      # proband, mother, father
else
  : "${SAMPLE:?Set SAMPLE}"
  IN="$WORKDIR/$SAMPLE/step5.clinvar.vcf"; OUTTSV="$WORKDIR/$SAMPLE/extract_${SAMPLE}.tsv"
  GT=("GEN[*].GT")
fi

java $JAVA_SMALL -jar "$SNPSIFT_JAR" extractFields -s "," -e "." "$IN" "${FIELDS[@]}" "${GT[@]}" > "$OUTTSV"

echo "Rows: $(wc -l < "$OUTTSV")"
echo "Columns:"; head -1 "$OUTTSV" | tr '\t' '\n' | nl
