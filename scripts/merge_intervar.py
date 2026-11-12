#!/usr/bin/env python3
"""Merge InterVar ACMG classifications into the annotated TSV (step 10c)."""
import argparse
import pandas as pd


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--tsv", required=True, help="TSV from 09_extract_fields.sh")
    ap.add_argument("--intervar", required=True, help="*.hg38_multianno.txt.intervar")
    ap.add_argument("--out", required=True, help="merged TSV to write")
    a = ap.parse_args()

    tsv = pd.read_csv(a.tsv, sep="\t", low_memory=False)
    iv = pd.read_csv(a.intervar, sep="\t", low_memory=False, header=0)
    print(f"TSV: {len(tsv)} variants | InterVar: {len(iv)} variants")

    cls_cols = [c for c in iv.columns if "InterVar" in str(c)]
    if not cls_cols:
        raise SystemExit("No InterVar classification column found.")
    iv = iv[["#Chr", "Start", "Ref", "Alt"] + cls_cols].copy()
    iv.columns = ["CHROM_IV", "POS_IV", "REF_IV", "ALT_IV", "InterVar_Classification"]

    iv["CHROM_IV"] = iv["CHROM_IV"].astype(str)
    if not iv["CHROM_IV"].str.startswith("chr").all():
        iv["CHROM_IV"] = "chr" + iv["CHROM_IV"]
    tsv["POS"] = tsv["POS"].astype(str)
    iv["POS_IV"] = iv["POS_IV"].astype(str)

    merged = tsv.merge(iv, left_on=["CHROM", "POS", "REF", "ALT"],
                       right_on=["CHROM_IV", "POS_IV", "REF_IV", "ALT_IV"], how="left")
    merged = merged.drop(columns=["CHROM_IV", "POS_IV", "REF_IV", "ALT_IV"], errors="ignore")
    merged = merged.drop_duplicates(subset=["CHROM", "POS", "REF", "ALT"], keep="first")
    merged.to_csv(a.out, sep="\t", index=False)

    print(f"Merged: {len(merged)} variants")
    print(f"With InterVar classification: {merged['InterVar_Classification'].notna().sum()}")
    print(merged["InterVar_Classification"].value_counts().head(10))


if __name__ == "__main__":
    main()
