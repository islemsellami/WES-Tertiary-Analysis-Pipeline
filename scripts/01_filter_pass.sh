#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 1 - keep only variants flagged PASS (VCFtools).
# Usage: SAMPLE=sample1 RAW_VCF=/path/to/sample1.vcf.gz ./scripts/01_filter_pass.sh
: "${SAMPLE:?Set SAMPLE}"; : "${RAW_VCF:?Set RAW_VCF}"
OUT="$WORKDIR/$SAMPLE"; mkdir -p "$OUT"

vcftools --gzvcf "$RAW_VCF" --keep-filtered PASS --recode --out "$OUT/step1"

echo "PASS variants retained: $(grep -vc '^#' "$OUT/step1.recode.vcf")"
