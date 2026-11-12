#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 6 - merge the three annotated VCFs of a trio (autosomal recessive analysis).
# Genotype column order in the merged VCF: GEN[0]=proband, GEN[1]=mother, GEN[2]=father.
# Usage: FAMILY=fam1 PROBAND=fam1-P MOTHER=fam1-M FATHER=fam1-F ./scripts/06_trio_merge.sh
: "${FAMILY:?}"; : "${PROBAND:?}"; : "${MOTHER:?}"; : "${FATHER:?}"
TRIO="$WORKDIR/${FAMILY}-trio"; mkdir -p "$TRIO"

for M in "$PROBAND" "$MOTHER" "$FATHER"; do
  D="$WORKDIR/$M"
  # drop a multi-valued dbNSFP field that breaks bcftools merge
  bcftools annotate -x INFO/dbNSFP_Interpro_domain "$D/step5.clinvar.vcf" \
    -Oz -o "$D/step5.bgz.vcf.gz"
  tabix -p vcf "$D/step5.bgz.vcf.gz"
done

bcftools merge \
  "$WORKDIR/$PROBAND/step5.bgz.vcf.gz" \
  "$WORKDIR/$MOTHER/step5.bgz.vcf.gz" \
  "$WORKDIR/$FATHER/step5.bgz.vcf.gz" \
  -m all -o "$TRIO/trio.merged.vcf"

echo "Genotype columns (expected: proband, mother, father):"
grep '^#CHROM' "$TRIO/trio.merged.vcf" | tr '\t' '\n' | tail -3
echo "Variants in merged trio VCF: $(grep -vc '^#' "$TRIO/trio.merged.vcf")"
