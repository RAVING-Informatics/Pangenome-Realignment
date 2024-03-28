# Pangenome-Realignment
This repository contains scripts and resources for pangenome-based re-analysis of srGS from rare disease patients.

## The Human Pangenome Reference Consortium (HPRC)
The HPRC has a [GitHub repository](https://github.com/human-pangenomics/hpp_pangenome_resources) dedicated to describing data available from the release of the draft human pangenome reference. This includes links to their pangenome graphs, and their associated indices, that they generated using three different strategies: Minigraph, Minigraph Cactus (MC), and Pangenome Graph Builder (PGGB).

In their release paper, the HPRC describe a workflow for aligning srGS to their MC pangenome graph, which leverages Giraffe [53]. Giraffe is part of the [vg toolkit](https://github.com/vgteam/vg), which provides graph data structures, interchange formats, alignment, genotyping and variant calling methods based on variation graphs. The HPRC compared the accuracy of calling small variants between their pangenome approach, using vf giraffe for alignment, to traditional approaches leveraging linear assemblies (i.e. bwa-mem alignment to GRCh38). Using either deepvariant or deeptrio for variant calling, they demonstrated that their pangenome approach outperformed the traditional linear approaches, especially in regions with errors in GRCh38 and medically relevant regions. Deeptrio outperformed deepvariant, and these improvements were additive to those of the pangenome. 

## Pangenie
Pangenie is a short-read genotyper for various types of genetic variants, including SNPs, indels and SVs, represented in a pangenome graph [54]. In contrast to vg-giraffe, Pangenie is an alignment-free approach, and rather uses k-mer counts from SRS data to genotype variants in a process known as genome inference [54]. In the original release paper. Pangenie outperformed several genotypers (5 mapping-based, 1 k-mer based) across a range of variant types, particularly for indels and SVs and variants in repeat regions [54]. Additionally, 71% of the SV alleles genotypable by PanGenie were not contained in gnomAD SV callsets [54], which aligns with prior studies demonstrating that SRS-based SV detection relative to a linear reference genome fails to detect most SVs (see above). These findings were corroborated by Liao et al. who applied Pangenie to genotype SVs 3202 srGS samples from the 1KG based on a VCF derived from the MC pangenome graph; the Pangenie-based callsets had 104% more SVs per haplotype compared to an Illumina based 1KG SV callset [23]. 


## Workflows
The HPRC has deposited WDL workflows on Zenodo for their [Giraffe-DeepVariant pipeline](https://doi.org/10.5281/zenodo.6655968) and [Giraffe-DeepTrio pipeline](https://zenodo.org/records/6655962). The suitability of these workflows for pangenome based short-read variant calling in unsolved rare disease samples will be explored as part of this project.

Workflows for Pangenie-based genotyping using HPRC pangenome graphs are available on [GitHub](https://github.com/eblerjana/pangenie) and [BitBucket](https://bitbucket.org/jana_ebler/hprc-experiments/src/master/genotyping-experiments/).

## Cohort Variant Calls
The HPRC has also provided combined VCFs and allele frequencies from 2,504 unrelated srGS samples of the 1KG, which they generate using their [Giraffe-DeepVariant pipeline](https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=publications/PANGENOME_2022/DeepVariant-1000GPcalls/). This will serve as a useful resource for variant frequency annotation and filtering.

The 1KG Pangenie genotypes and MC-based VCF used as input in the HPRC experiments are available on [Zenodo](https://zenodo.org/records/6797328).

## Relevent Publications
**HPRC Draft Pangenome paper**

Liao, W.-W., et al., A draft human pangenome reference. Nature, 2023. 617(7960): p. 312-324.

**vg-giraffe paper**

Sirén, J., et al., Pangenomics enables genotyping of known structural variants in 5202 diverse genomes. Science, 2021. 374(6574): p. abg8871.


