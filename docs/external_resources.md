# External resources used for manual prioritisation and interpretation

| Resource | URL | Use |
|---|---|---|
| AnnotSV (web) | https://www.lbgi.fr/AnnotSV/ | CNV annotation: genes, OMIM, ACMG/ClinGen 2019 score, DGV, gnomAD-SV |
| ClinVar | https://www.ncbi.nlm.nih.gov/clinvar | Clinical significance |
| HGMD | https://hgmd.cf.ac.uk | Published pathogenic variants |
| gnomAD | https://gnomad.broadinstitute.org | Population frequencies |
| VarSome | https://varsome.com | ACMG classification |
| PubMind | https://pubmind.wglab.org | Literature mining |
| ClinPred | https://genome.ucsc.edu | UCSC track |
| DeepRare | https://deeprare.ai | Differential diagnosis |
| PanelApp | https://panelapp.genomicsengland.co.uk | Gene panels |
| UniProt | https://www.uniprot.org | Protein sequences and domains |
| OMIM | https://omim.org | Gene-disease relationships |

## AnnotSV (CNV annotation, web server)

1. Open https://www.lbgi.fr/AnnotSV/ and select genome **GRCh38**.
2. Upload `CNV_<sample>_not_in_population.bed` (columns: chr, start, end, type, BF).
3. Download the annotated TSV and look at the OMIM gene, the ACMG/ClinGen class and the
   haploinsufficiency (HI) / pLI columns.
