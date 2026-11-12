#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 2 - functional annotation with SnpEff (GRCh38.99, canonical transcripts).
# Impact classes: HIGH, MODERATE, LOW, MODIFIER.
# Usage: SAMPLE=sample1 ./scripts/02_snpeff_annotation.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"

java $JAVA_SMALL -jar "$SNPEFF_JAR" -v GRCh38.99 \
  -canon -strict -no-upstream -no-downstream -no-intergenic \
  "$OUT/step1.recode.vcf" > "$OUT/step2.snpeff.vcf"

echo "Annotated variants: $(grep -vc '^#' "$OUT/step2.snpeff.vcf")"
echo "Impact distribution:"
grep -v '^#' "$OUT/step2.snpeff.vcf" | grep -o 'IMPACT=[^;]*' | sort | uniq -c | sort -rn || true
