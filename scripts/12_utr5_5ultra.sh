#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 12 - 5'UTR variants: effect on translation (uORF creation/loss, Kozak context)
# with 5ULTRA. 5'UTR variants are classified MODIFIER by SnpEff, hence this module.
# 5ULTRA is NOT redistributed here (CC BY-NC-ND licence): install it from its own
# repository (https://github.com/mchaldebas/5ULTRA) in a dedicated environment.
# Usage: SAMPLE=sample1 ./scripts/12_utr5_5ultra.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"

grep '^#' "$OUT/step2.snpeff.vcf" > "$OUT/$SAMPLE.5utr.vcf"
grep -v '^#' "$OUT/step2.snpeff.vcf" | grep '5_prime_UTR_variant' >> "$OUT/$SAMPLE.5utr.vcf" || true
echo "5'UTR variants: $(grep -vc '^#' "$OUT/$SAMPLE.5utr.vcf")"

python3 -m fiveULTRA -I "$OUT/$SAMPLE.5utr.vcf" -O "$OUT/$SAMPLE.5ultra.tsv" --full --mane

echo "Rows: $(wc -l < "$OUT/$SAMPLE.5ultra.tsv")"
echo "Potentially pathogenic (score >= 0.7):"
awk -F'\t' 'NR>1 && $5 >= 0.7 {print $0}' "$OUT/$SAMPLE.5ultra.tsv" | head -10
# 5ULTRA can change the scikit-learn version: aiDIVA needs scikit-learn 1.3.2
# (use separate environments, see docs/troubleshooting.md).
