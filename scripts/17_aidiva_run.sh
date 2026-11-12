#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 17 - variant prioritisation with aiDIVA (random forest on 21 dbNSFP features +
# HPO phenotype similarity). Scores: AIDIVA_SCORE (pathogenicity, 0-1), HPO_RELATEDNESS (0-1)
# and FINAL_AIDIVA_SCORE (combined).
# aiDIVA requires scikit-learn 1.3.2: use a dedicated environment.
# Usage: SAMPLE=sample1 HPO_LIST=/path/hpo_terms.txt ./scripts/17_aidiva_run.sh
: "${SAMPLE:?Set SAMPLE}"; : "${HPO_LIST:?Set HPO_LIST (one HPO term per line)}"
OUT="$WORKDIR/$SAMPLE"; mkdir -p "$OUT/aiDIVA_results"

python3 "$HERE/17_aidiva_prepare_input.py" --vcf "$OUT/step5.clinvar.vcf" --out "$OUT/$SAMPLE.aidiva_input.tsv"

nohup python3 "$AIDIVA" --config "$AIDIVA_CONFIG" \
  --in_data "$OUT/$SAMPLE.aidiva_input.tsv" \
  --out_prefix "$OUT/aiDIVA_results/${SAMPLE}_aidiva" \
  --hpo_list "$HPO_LIST" --family_type SINGLE --rare_disease --threads 4 \
  > "$OUT/log_aidiva.txt" 2>&1 &
echo "PID: $!  (follow with: tail -f $OUT/log_aidiva.txt)"
