#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 10 - automated ACMG/AMP 2015 classification with InterVar, then merge the
# classification with the annotated TSV.
# Usage: SAMPLE=sample1 ./scripts/10_intervar_acmg.sh
: "${SAMPLE:?Set SAMPLE}"
OUT="$WORKDIR/$SAMPLE"

# 10a - VCF -> ANNOVAR input
perl "$ANNOVAR_DIR/convert2annovar.pl" -format vcf4 "$OUT/step3.dbsnp.vcf" \
  > "$OUT/$SAMPLE.intervar.avinput"
echo "Converted variants: $(wc -l < "$OUT/$SAMPLE.intervar.avinput")"

# 10b - InterVar (long run: launch in background and follow the log)
nohup python3 "$INTERVAR" -b hg38 \
  -i "$OUT/$SAMPLE.intervar.avinput" --input_type=AVinput \
  -o "$OUT/$SAMPLE.intervar" -c "$INTERVAR_CONFIG" -d "$HUMANDB/" \
  > "$OUT/log_intervar.txt" 2>&1 &
echo "InterVar PID: $!  (follow with: tail -f $OUT/log_intervar.txt)"
echo "When finished, merge with the TSV:"
echo "  python3 scripts/merge_intervar.py --tsv $OUT/extract_${SAMPLE}.tsv \\"
echo "          --intervar $OUT/$SAMPLE.intervar.hg38_multianno.txt.intervar \\"
echo "          --out $OUT/extract_${SAMPLE}_intervar.tsv"
