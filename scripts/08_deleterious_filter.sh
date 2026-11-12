#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 8 - keep variants predicted deleterious by combined dbNSFP scores.
# A variant is retained if it satisfies at least ONE of the combinations below.
# Thresholds from the literature:
#   CADD_phred > 20            (Kircher et al., Nat Genet 2014)
#   REVEL > 0.5                (Ioannidis et al., AJHG 2016)
#   AlphaMissense > 0.564      (Cheng et al., Science 2023)
#   BayesDel_noAF > 0.069      (Kong et al., npj Genom Med 2025)
# Usage: SAMPLE=sample1 ./scripts/08_deleterious_filter.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"

java -Xmx2g -jar "$SNPSIFT_JAR" filter \
"( (dbNSFP_CADD_phred > 20) & (dbNSFP_REVEL_score > 0.5) ) |
 ( (dbNSFP_CADD_phred > 20) & (dbNSFP_AlphaMissense_score > 0.564) ) |
 ( (dbNSFP_REVEL_score > 0.5) & (dbNSFP_BayesDel_noAF_score > 0.069) )" \
  "$OUT/step5.clinvar.vcf" > "$OUT/step8.deleterious.vcf"

echo "Deleterious variants: $(grep -vc '^#' "$OUT/step8.deleterious.vcf")"
echo "Top genes:"
grep -v '^#' "$OUT/step8.deleterious.vcf" | grep -o 'ANN=[^;]*' | cut -d'|' -f4 | sort | uniq -c | sort -rn | head -20
