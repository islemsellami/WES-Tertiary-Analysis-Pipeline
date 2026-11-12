#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 11 - runs of homozygosity (ROH).
#   11a) PLINK 1.9 on each INDIVIDUAL VCF (never on the merged trio VCF)
#   11b) HomSI on the MERGED trio VCF, to compare the three homozygosity profiles
# NOTE: PLINK and HomSI must write to a local Linux filesystem, not to a mounted
# Windows drive (e.g. /mnt/<drive>). Outputs are therefore written to $TMPDIR_ROH first.
# Usage: SAMPLE=sample1 ./scripts/11_roh_plink_homsi.sh plink
#        FAMILY=fam1   ./scripts/11_roh_plink_homsi.sh homsi
MODE="${1:?Usage: $0 plink|homsi}"
TMPDIR_ROH="${TMPDIR_ROH:-$HOME/roh_tmp}"; mkdir -p "$TMPDIR_ROH"

if [ "$MODE" = "plink" ]; then
  : "${SAMPLE:?Set SAMPLE}"
  OUT="$WORKDIR/$SAMPLE"
  plink --vcf "$OUT/step2.snpeff.vcf" --make-bed --out "$TMPDIR_ROH/$SAMPLE-plink" \
        --allow-extra-chr --chr-set 95
  plink --bfile "$TMPDIR_ROH/$SAMPLE-plink" --homozyg \
        --homozyg-snp 50 --homozyg-kb 1500 --homozyg-density 50 --homozyg-gap 1000 \
        --homozyg-window-het 1 --homozyg-window-missing 5 \
        --allow-extra-chr --chr-set 95 --out "$TMPDIR_ROH/$SAMPLE-ROH"
  echo "ROH summary (NSEG = 0: no ROH detected):"; cat "$TMPDIR_ROH/$SAMPLE-ROH.hom.indiv"
  cp "$TMPDIR_ROH/$SAMPLE"-ROH* "$TMPDIR_ROH/$SAMPLE"-plink* "$OUT/"

elif [ "$MODE" = "homsi" ]; then
  : "${FAMILY:?Set FAMILY}"
  TRIO="$WORKDIR/${FAMILY}-trio"
  # headless mode is mandatory on servers / WSL (no display)
  java -Djava.awt.headless=true -jar "$HOMSI_JAR" \
       -vcf "$TRIO/trio.merged.vcf" -prefix "${FAMILY}-trio" -out "$TMPDIR_ROH/${FAMILY}-trio-HomSI"
  cp "$TMPDIR_ROH/${FAMILY}-trio-HomSI"* "$TRIO/"
  echo "Red curve = homozygosity, blue curve = heterozygosity."
  echo "A homozygous block present in the child but not in the parents suggests autosomal"
  echo "recessive inheritance by descent."
else
  echo "Unknown mode: $MODE"; exit 1
fi
