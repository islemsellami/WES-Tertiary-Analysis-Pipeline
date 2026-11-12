#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 5 - add ClinVar clinical annotations (CLNSIG, CLNDN, CLNREVSTAT, CLNHGVS).
# Usage: SAMPLE=sample1 ./scripts/05_snpsift_clinvar.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"

java $JAVA_SMALL -jar "$SNPSIFT_JAR" annotate "$CLINVAR" \
  "$OUT/step4.dbnsfp.vcf" > "$OUT/step5.clinvar.raw.vcf"

if file "$OUT/step5.clinvar.raw.vcf" | grep -qi 'UTF-16'; then
  iconv -f UTF-16 -t UTF-8 "$OUT/step5.clinvar.raw.vcf" > "$OUT/step5.clinvar.vcf"
else
  cp "$OUT/step5.clinvar.raw.vcf" "$OUT/step5.clinvar.vcf"
fi

echo "Variants: $(grep -vc '^#' "$OUT/step5.clinvar.vcf")"
echo "ClinVar Pathogenic: $(grep -v '^#' "$OUT/step5.clinvar.vcf" | grep -c 'CLNSIG=Pathogenic' || true)"
