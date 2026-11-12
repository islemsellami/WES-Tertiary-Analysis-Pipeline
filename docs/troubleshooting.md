# Troubleshooting

| Problem | Cause | Solution |
|---|---|---|
| **UTF-16 BOM** in SnpSift output (steps 4-5) | Output written from PowerShell | Scripts convert automatically with `iconv -f UTF-16 -t UTF-8`; check with `file <vcf>` |
| **PLINK / HomSI cannot write** to `/mnt/<drive>` | Windows-mounted drive | Write to a local Linux directory (`TMPDIR_ROH`) then copy (done by `11_roh_plink_homsi.sh`) |
| **HomSI fails without display** | GUI needed by default | Always use `-Djava.awt.headless=true` |
| **aiDIVA error after running 5ULTRA** | 5ULTRA changes scikit-learn | aiDIVA requires `scikit-learn==1.3.2`; use separate environments for 5ULTRA and aiDIVA |
| **dbNSFP column names** | `-` replaced by `_` in the VCF | Use `dbNSFP_fathmm_XF_coding_score`, `dbNSFP_Eigen_phred_coding` |
| **ExomeDepth: `include.chr`** | BED already has `chr` | Keep `include.chr = FALSE` |
| **ExomeDepth: name column** | Counts table calls the BED name column `exon` | Use `name = counts$exon` in `CallCNVs` |
| **bedtools: no overlap found** | Population BED without `chr` prefix | `awk '{print "chr"$0}' population.bed > population_chr.bed` |
| **Exomiser: `Assembly hg19 not supported`** | VCF has no `chr` prefix | Add the prefix (command below) |
| **Exomiser: `HPO IDs not defined`** | Exomiser 14: HPO must be under `analysis:` | Use `templates/exomiser_analysis_template.yml` |
| **Exomiser: `CADD snv is not configured`** | CADD data not installed | Remove CADD from `pathogenicitySources` (keep REVEL, MVP) |

Add the `chr` prefix to a VCF (header contigs and records):

```bash
awk '{
  if (/^##contig=<ID=/ && !/chr/) { gsub(/ID=/, "ID=chr") }
  else if (!/^#/ && $1 !~ /^chr/) { $1 = "chr"$1 }
  print
}' OFS='\t' input.vcf > input.chr.vcf
```
