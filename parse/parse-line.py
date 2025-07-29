import pandas as pd
import argparse
import gzip
import sys

def parse_vcf(input_vcf, output_file, output_format='tsv'):
    # ✅ Handle all input sources: stdin, gzipped, plain text
    if input_vcf == "/dev/stdin":
        handle = sys.stdin
    elif input_vcf.endswith(".gz"):
        handle = gzip.open(input_vcf, "rt")
    else:
        handle = open(input_vcf, "r")

    # ✅ Decide delimiter exactly like original script
    sep = '\t' if output_format == 'tsv' else ','

    # ✅ VEP headers & INFO fields — exactly as original
    vep_headers = [
        "Allele", "Consequence", "IMPACT", "SYMBOL", "Gene", "Feature_type", "Feature", "BIOTYPE",
        "EXON", "INTRON", "HGVSc", "HGVSp", "cDNA_position", "CDS_position", "Protein_position",
        "Amino_acids", "Codons", "Existing_variation", "DISTANCE", "STRAND", "FLAGS", "VARIANT_CLASS",
        "SYMBOL_SOURCE", "HGNC_ID", "CANONICAL", "MANE_SELECT", "MANE_PLUS_CLINICAL", "TSL", "APPRIS",
        "CCDS", "ENSP", "SWISSPROT", "TREMBL", "UNIPARC", "UNIPROT_ISOFORM", "SOURCE", "GENE_PHENO",
        "DOMAINS", "miRNA", "HGVS_OFFSET", "AF", "AFR_AF", "AMR_AF", "EAS_AF", "EUR_AF", "SAS_AF",
        "gnomADe_AF", "gnomADe_AFR_AF", "gnomADe_AMR_AF", "gnomADe_ASJ_AF", "gnomADe_EAS_AF",
        "gnomADe_FIN_AF", "gnomADe_NFE_AF", "gnomADe_OTH_AF", "gnomADe_SAS_AF", "gnomADg_AF",
        "gnomADg_AFR_AF", "gnomADg_AMI_AF", "gnomADg_AMR_AF", "gnomADg_ASJ_AF", "gnomADg_EAS_AF",
        "gnomADg_FIN_AF", "gnomADg_MID_AF", "gnomADg_NFE_AF", "gnomADg_OTH_AF", "gnomADg_SAS_AF",
        "MAX_AF", "MAX_AF_POPS", "FREQS", "CLIN_SIG", "SOMATIC", "PHENO", "PUBMED", "MOTIF_NAME",
        "MOTIF_POS", "HIGH_INF_POS", "MOTIF_SCORE_CHANGE", "TRANSCRIPTION_FACTORS", "clinvar",
        "clinvar_CLNSIG", "clinvar_CLNREVSTAT", "clinvar_CLNDN"
    ]

    info_fields = [
        "AF", "AQ", "AC", "AN", "AF_HPRC", "AF_1000G", "AF_gnomad", "AF_hgsvc3",
        "UniqueT2T", "SVTYPE", "END", "CHR2", "NGRP", "CT", "CIEND95", "CIPOS95",
        "SVLEN", "GC", "NEXP", "STRIDE", "RPOLY", "OL", "SU", "WR", "PE", "SR",
        "SC", "BND", "LPREC", "RT", "MeanPROB", "MaxPROB"
    ]

    fixed_columns = ['CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'FORMAT']

    sample_columns = None
    chunk = []
    chunk_size = 50000
    wrote_header = False

    for i, line in enumerate(handle):
        if line.startswith('##'):
            continue  # ignore metadata lines

        if line.startswith('#'):
            headers = line.strip().split('\t')
            sample_columns = headers[9:]
            continue

        fields = line.strip().split('\t')
        if len(fields) < 9:
            continue

        chrom, pos, v_id, ref, alt, qual, filt, info, fmt = fields[:9]
        sample_data = fields[9:]

        # Parse INFO
        info_dict = {kv.split('=')[0]: kv.split('=', 1)[1] for kv in info.split(';') if '=' in kv}
        info_present = {kv.split('=')[0]: True for kv in info.split(';') if '=' not in kv}

        extracted_info = {field: info_dict.get(field, None) for field in info_fields}
        extracted_info['UniqueT2T'] = 'Yes' if 'UniqueT2T' in info_present or 'UniqueT2T' in info_dict else None

        # Parse CSQ
        csq_data = info_dict.get('CSQ', '').split(',')
        genetic_models = info_dict.get('GeneticModels', '')

        for csq_entry in csq_data:
            csq_fields = csq_entry.split('|')
            csq_dict = dict(zip(vep_headers, csq_fields))

            csq_dict.update({
                'CHROM': chrom,
                'POS': pos,
                'ID': v_id,
                'REF': ref,
                'ALT': alt,
                'QUAL': qual,
                'FILTER': filt,
                'FORMAT': fmt,
                'GeneticModels': genetic_models,
                **extracted_info
            })

            for sample, data in zip(sample_columns, sample_data):
                csq_dict[sample] = data

            chunk.append(csq_dict)

        # ✅ flush every 50k rows
        if len(chunk) >= chunk_size:
            df = pd.DataFrame(chunk)
            all_columns = fixed_columns + sample_columns + info_fields + [
                col for col in df.columns if col not in fixed_columns + sample_columns + info_fields
            ]
            df = df.reindex(columns=all_columns)
            df.to_csv(output_file, sep=sep, index=False, mode='a', header=not wrote_header)
            wrote_header = True
            chunk = []

    # ✅ final flush for remaining rows
    if chunk:
        df = pd.DataFrame(chunk)
        all_columns = fixed_columns + sample_columns + info_fields + [
            col for col in df.columns if col not in fixed_columns + sample_columns + info_fields
        ]
        df = df.reindex(columns=all_columns)
        df.to_csv(output_file, sep=sep, index=False, mode='a', header=not wrote_header)

    handle.close()
    print(f"✅ Done parsing {input_vcf} → {output_file}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Parse a VCF file and extract INFO fields")
    parser.add_argument("input_vcf", help="Input VCF file")
    parser.add_argument("output_file", help="Output file (TSV or CSV)")
    parser.add_argument("--output_format", choices=['tsv','csv'], default='tsv', help="Output file format (default: TSV)")
    args = parser.parse_args()

    parse_vcf(args.input_vcf, args.output_file, output_format=args.output_format)
