#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../config/config.sh
source "$HERE/../config/config.sh"

# Step 18 - HPO-driven prioritisation with Exomiser 14 (PhenoDigm: mouse / zebrafish
# orthologue phenotypes). Fill templates/exomiser_analysis_template.yml first.
# If the VCF has no "chr" prefix, add it (see docs/troubleshooting.md).
# Usage: SAMPLE=sample1 ANALYSIS_YML=/path/analysis.yml ./scripts/18_exomiser_run.sh
: "${SAMPLE:?Set SAMPLE}"; : "${ANALYSIS_YML:?Set ANALYSIS_YML}"
OUT="$WORKDIR/$SAMPLE/Exomiser"; mkdir -p "$OUT"

java -Xmx4g -jar "$EXOMISER_JAR" --analysis "$ANALYSIS_YML" \
     --spring.config.location="$EXOMISER_CONF"

echo "Top genes:";    head -20 "$OUT/${SAMPLE}-exomiser.genes.tsv"    | cut -f1-6
echo "Top variants:"; head -20 "$OUT/${SAMPLE}-exomiser.variants.tsv" | cut -f1-8
