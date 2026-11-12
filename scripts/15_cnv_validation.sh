#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 15 - orthogonal validation of a candidate CNV (excludes false positives):
#   15a) CNVkit  : independent detection + zoomed scatter plot
#   15b) samtools depth : coverage ratio CNV / flanking region (~0.5 = heterozygous deletion)
#   15c) Samplot : read-level visualisation
# Requires the environments in environment/ (cnvkit.yml; samplot is in core.yml).
# Usage: SAMPLE=s1 BAM=/path/s1.bam CHR=chr17 START=31327521 END=31335090 \
#        FLANK_START=31100000 FLANK_END=31327520 TYPE=DEL ./scripts/15_cnv_validation.sh
: "${SAMPLE:?}"; : "${BAM:?}"; : "${CHR:?}"; : "${START:?}"; : "${END:?}"
: "${FLANK_START:?}"; : "${FLANK_END:?}"; TYPE="${TYPE:-DEL}"
OUT="$WORKDIR/$SAMPLE/cnv_validation"; mkdir -p "$OUT"

# 15a - CNVkit (target BED deduplicated beforehand; control .cov.cnn files in $OUT)
#   cnvkit.py coverage "$BAM" "$OUT/targets_dedup.bed" -o "$OUT/$SAMPLE.cov.cnn"
#   (repeat for each control, then:)
#   cnvkit.py reference "$OUT"/*.cov.cnn --no-gc -o "$OUT/reference.cnn"
#   cnvkit.py fix "$OUT/$SAMPLE.cov.cnn" "$OUT/antitarget_empty.cnn" "$OUT/reference.cnn" --no-gc -o "$OUT/$SAMPLE.cnr"
#   cnvkit.py segment "$OUT/$SAMPLE.cnr" -o "$OUT/$SAMPLE.cns"
#   cnvkit.py call "$OUT/$SAMPLE.cns" -o "$OUT/$SAMPLE.called.cns"
if [ -f "$OUT/$SAMPLE.cnr" ] && [ -f "$OUT/$SAMPLE.called.cns" ]; then
  MPLBACKEND=Agg cnvkit.py scatter "$OUT/$SAMPLE.cnr" -s "$OUT/$SAMPLE.called.cns" \
    -c "$CHR:$START-$END" -o "$OUT/CNV_scatter_zoom.png"
fi

# 15b - samtools depth ratio
COV_CNV=$(samtools depth -r "$CHR:$START-$END" "$BAM" | awk '{s+=$3; n++} END {print s/n}')
COV_FLANK=$(samtools depth -r "$CHR:$FLANK_START-$FLANK_END" "$BAM" | awk '{s+=$3; n++} END {print s/n}')
echo "Mean coverage CNV: $COV_CNV | flanking: $COV_FLANK"
echo "Ratio CNV / flanking: $(echo "$COV_CNV/$COV_FLANK" | bc -l)   (~0.5 = heterozygous deletion)"

# 15c - Samplot
samplot plot -n "$SAMPLE" -b "$BAM" -o "$OUT/${SAMPLE}_CNV_samplot.png" \
  -c "$CHR" -s "$START" -e "$END" -t "$TYPE"

# 15d - healthy-population check (empty result = absent from healthy population)
if [ -n "${POPULATION_BED:-}" ]; then
  echo "Overlap with healthy-population map:"
  grep "$CHR" "$POPULATION_BED" | awk -v s="$START" -v e="$END" '$2 <= e && $3 >= s'
fi
