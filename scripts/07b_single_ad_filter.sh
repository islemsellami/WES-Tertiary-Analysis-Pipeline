#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 7b - autosomal dominant filtering for a single patient (no parental VCF needed):
# strictly heterozygous (0/1) HIGH/MODERATE variants in the proband. Identifies de novo
# variants or variants inherited in a dominant mode.
# Usage: SAMPLE=sample1 ./scripts/07b_single_ad_filter.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"

java $JAVA_SMALL -jar "$SNPSIFT_JAR" filter \
  "( (ANN[*].IMPACT = 'HIGH') | (ANN[*].IMPACT = 'MODERATE') ) & ( (GEN[0].GT = '0/1') | (GEN[0].GT = '0|1') )" \
  "$OUT/step5.clinvar.vcf" > "$OUT/$SAMPLE.AD.het.vcf"

echo "Heterozygous HIGH/MODERATE variants: $(grep -vc '^#' "$OUT/$SAMPLE.AD.het.vcf")"
