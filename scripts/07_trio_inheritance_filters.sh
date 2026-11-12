#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 7 - transmission-based filtering of the merged trio (autosomal recessive).
#   a) MAF <= 1 % (1000 Genomes AF from dbNSFP; missing AF kept)
#   b) complete AR   : proband 1/1, mother 0/1, father 0/1
#   c) partial AR    : proband 1/1 and at least one heterozygous parent
#   d) HIGH/MODERATE impact, then removal of ClinVar Benign / Likely benign
# Usage: FAMILY=fam1 ./scripts/07_trio_inheritance_filters.sh
: "${FAMILY:?}"
TRIO="$WORKDIR/${FAMILY}-trio"
S="java $JAVA_SMALL -jar $SNPSIFT_JAR filter"
count() { grep -vc '^#' "$1"; }

$S "(dbNSFP_1000Gp3_AF <= 0.01) | (dbNSFP_1000Gp3_AF = '.')" \
   "$TRIO/trio.merged.vcf" > "$TRIO/trio.MAF01.vcf"
echo "After MAF < 1 %          : $(count "$TRIO/trio.MAF01.vcf")"

$S "((GEN[0].GT = '1/1') | (GEN[0].GT = '1|1')) & \
    ((GEN[1].GT = '0/1') | (GEN[1].GT = '0|1')) & \
    ((GEN[2].GT = '0/1') | (GEN[2].GT = '0|1'))" \
   "$TRIO/trio.MAF01.vcf" > "$TRIO/trio.AR.complete.vcf"
echo "AR homozygous (complete) : $(count "$TRIO/trio.AR.complete.vcf")"

$S "((GEN[0].GT = '1/1') | (GEN[0].GT = '1|1')) & \
    ( ((GEN[1].GT = '0/1') | (GEN[1].GT = '0|1')) | ((GEN[2].GT = '0/1') | (GEN[2].GT = '0|1')) )" \
   "$TRIO/trio.MAF01.vcf" > "$TRIO/trio.AR.partial.vcf"
echo "AR homozygous (partial)  : $(count "$TRIO/trio.AR.partial.vcf")"

$S "(ANN[*].IMPACT = 'HIGH') | (ANN[*].IMPACT = 'MODERATE')" \
   "$TRIO/trio.AR.complete.vcf" > "$TRIO/trio.AR.HIGH_MODERATE.vcf"
{ grep '^#' "$TRIO/trio.AR.HIGH_MODERATE.vcf"
  grep -v '^#' "$TRIO/trio.AR.HIGH_MODERATE.vcf" | grep -v 'CLNSIG=Benign\|CLNSIG=Likely_benign'
} > "$TRIO/trio.AR.final.vcf"
echo "AR final (non-benign)    : $(count "$TRIO/trio.AR.final.vcf")"
