#!/usr/bin/env python3
"""Prepare the aiDIVA input table from the annotated VCF (step 17a).

Columns not available in the pipeline are set to fixed defaults: CONDEL, oe_lof, homAF,
CAPICE and SpliceAI. Document this choice when reporting results.
"""
import argparse
import pandas as pd

HEADER = ['#CHROM', 'POS', 'REF', 'ALT', 'FILTER', 'SYMBOL', 'IMPACT', 'SIFT', 'PolyPhen',
          'CADD_PHRED', 'REVEL', 'MAX_AF', 'EIGEN_PHRED', 'CONDEL', 'FATHMM_XF',
          'MutationAssessor', 'phastCons_mammal', 'phastCons_primate', 'phastCons_vertebrate',
          'phyloP_mammal', 'phyloP_primate', 'phyloP_vertebrate', 'oe_lof', 'homAF', 'CAPICE',
          'ALPHA_MISSENSE_SCORE', 'HIGH_IMPACT', 'IS_INDEL', 'SpliceAI', 'Consequence',
          'MOST_SEVERE_CONSEQUENCE', 'GT_PATIENT']
STRING_COLS = ['SYMBOL', 'IMPACT', 'Consequence', 'MOST_SEVERE_CONSEQUENCE', 'GT_PATIENT', 'FILTER']


def get_info(info, key):
    for field in info.split(';'):
        if field.startswith(key + '='):
            return field.split('=', 1)[1]
    return '.'


def get_ann(ann):
    """Return gene, effect, impact, HGVS.c, HGVS.p of the first SnpEff annotation."""
    if ann == '.':
        return '.', '.', '.', '.', '.'
    p = ann.split(',')[0].split('|')
    g = lambda i: p[i] if len(p) > i else '.'
    return g(3), g(1), g(2), g(9), g(10)


def clean(val):
    try:
        v = str(val).split(',')[0]
        return float(v) if v not in ['.', 'nan', ''] else 0.0
    except ValueError:
        return 0.0


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--vcf', required=True, help='annotated VCF (step 5)')
    ap.add_argument('--out', required=True, help='aiDIVA input TSV')
    a = ap.parse_args()

    n = 0
    with open(a.vcf, encoding='utf-8', errors='replace') as fin, open(a.out, 'w', encoding='utf-8') as fout:
        fout.write('\t'.join(HEADER) + '\n')
        for line in fin:
            if line.startswith('#'):
                continue
            parts = line.rstrip('\n').split('\t')
            if len(parts) < 8:
                continue
            chrom, pos, _id, ref, alt = parts[:5]
            info = parts[7]
            fmt = parts[8] if len(parts) > 8 else '.'
            smp = parts[9] if len(parts) > 9 else '.'
            gt = '.'
            if fmt != '.' and smp != '.':
                ff, sf = fmt.split(':'), smp.split(':')
                if 'GT' in ff:
                    gt = sf[ff.index('GT')]
            gene, effect, impact, _hc, _hp = get_ann(get_info(info, 'ANN'))
            gi = lambda k: clean(get_info(info, 'dbNSFP_' + k))
            row = [chrom, pos, ref, alt, 'PASS', gene, impact,
                   gi('SIFT_score'), gi('Polyphen2_HDIV_score'), gi('CADD_phred'), gi('REVEL_score'),
                   gi('1000Gp3_AF'), gi('Eigen_phred_coding'), 0.0, gi('fathmm_XF_coding_score'),
                   gi('MutationAssessor_score'), gi('phastCons470way_mammalian'),
                   gi('phastCons17way_primate'), gi('phastCons100way_vertebrate'),
                   gi('phyloP470way_mammalian'), gi('phyloP17way_primate'), gi('phyloP100way_vertebrate'),
                   0.55, 0.0, 0.0, gi('AlphaMissense_score'),
                   1 if impact == 'HIGH' else 0, 1 if (len(ref) > 1 or len(alt) > 1) else 0,
                   0.0, effect, effect, gt]
            fout.write('\t'.join(str(x) for x in row) + '\n')
            n += 1
            if n % 50000 == 0:
                print(f'{n} variants...')
    print(f'aiDIVA input written: {n} variants')

    df = pd.read_csv(a.out, sep='\t', low_memory=False)
    for col in STRING_COLS:
        if col in df.columns:
            df[col] = df[col].fillna('.').astype(str)
    df.to_csv(a.out, sep='\t', index=False)
    print(f'String columns normalised: {len(df)} variants')


if __name__ == '__main__':
    main()
