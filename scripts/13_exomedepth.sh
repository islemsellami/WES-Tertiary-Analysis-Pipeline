#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 13 wrapper - run ExomeDepth for one sample (background, with log).
# Usage: SAMPLE=sample1 PATIENT_BAM=/path/sample1.bam ./scripts/13_exomedepth.sh
: "${SAMPLE:?Set SAMPLE}"; : "${PATIENT_BAM:?Set PATIENT_BAM}"
OUT="$WORKDIR/$SAMPLE/cnv"; mkdir -p "$OUT"

nohup "$EXOMEDEPTH_RSCRIPT" "$HERE/13_exomedepth.R" "$SAMPLE" "$PATIENT_BAM" \
      "$CONTROL_BAMS_LIST" "$BED_EXONS" "$OUT" > "$OUT/log_exomedepth.txt" 2>&1 &
echo "PID: $!  (follow with: tail -f $OUT/log_exomedepth.txt)"
