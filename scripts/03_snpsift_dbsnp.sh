#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 3 - add rsIDs from dbSNP (SnpSift annotate).
# Variants without rsID are counted as "novel".
# Usage: SAMPLE=sample1 ./scripts/03_snpsift_dbsnp.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"

java $JAVA_LARGE -jar "$SNPSIFT_JAR" annotate -id "$DBSNP" \
  "$OUT/step2.snpeff.vcf" > "$OUT/step3.dbsnp.vcf"

echo "Variants with rsID : $(grep -v '^#' "$OUT/step3.dbsnp.vcf" | awk '$3 != "."' | wc -l)"
echo "Novel (no rsID)    : $(grep -v '^#' "$OUT/step3.dbsnp.vcf" | awk '$3 == "."'  | wc -l)"
