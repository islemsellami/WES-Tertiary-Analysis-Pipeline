# =============================================================================
# Configuration template.
# Copy this file to config/config.sh and edit the paths. config.sh is ignored
# by git: never commit machine-specific paths or sample identifiers.
# =============================================================================

# ---- Working directory (one sub-folder per sample is created inside)
export WORKDIR="$HOME/wes_analysis"

# ---- Annotation and classification tools
export SNPEFF_JAR="/path/to/snpEff/snpEff.jar"
export SNPSIFT_JAR="/path/to/snpEff/SnpSift.jar"
export ANNOVAR_DIR="/path/to/annovar"
export HUMANDB="$ANNOVAR_DIR/humandb"
export INTERVAR="/path/to/InterVar/Intervar.py"
export INTERVAR_CONFIG="/path/to/InterVar/config.ini"

# ---- ROH, prioritization tools
export HOMSI_JAR="/path/to/HomSI/HomSI.jar"
export AIDIVA="/path/to/aiDIVA/aidiva/run_aidiva-rf.py"
export AIDIVA_CONFIG="/path/to/aiDIVA/config.yaml"
export EXOMISER_JAR="/path/to/exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar"
export EXOMISER_CONF="/path/to/exomiser/application.properties"

# ---- Databases (GRCh38)
export DBNSFP="/path/to/dbNSFP5.3.1a_grch38.gz"
export DBSNP="/path/to/dbSNP_hg38.vcf.gz"
export CLINVAR="/path/to/clinvar_YYYYMMDD.vcf.gz"
export HG38="/path/to/hg38.fa"

# ---- CNV analysis
export BED_EXONS="/path/to/capture_kit_exons.bed"            # same kit for all samples
export POPULATION_BED="/path/to/healthy_population_CNV_chr.bed"  # chr-prefixed
export CONTROL_BAMS_LIST="/path/to/control_bams.txt"         # one BAM path per line
export EXOMEDEPTH_RSCRIPT="Rscript"                          # Rscript of the ExomeDepth environment

# ---- Java memory settings
export JAVA_SMALL="-Xmx4g"
export JAVA_LARGE="-Xmx8g"
