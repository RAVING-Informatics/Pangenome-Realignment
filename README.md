# Pangenome-Realignment
This repository contains scripts and resources for pangenome-based re-analysis of srGS from rare disease patients.

## The Human Pangenome Reference Consortium (HPRC)
The HPRC has a [GitHub repository](https://github.com/human-pangenomics/hpp_pangenome_resources) dedicated to describing data available from the release of the draft human pangenome reference. This includes links to their pangenome graphs, and their associated indices, that they generated using three different strategies: Minigraph, Minigraph Cactus (MC), and Pangenome Graph Builder (PGGB).

In their release paper, the HPRC describe a workflow for aligning srGS to their MC pangenome graph, which leverages Giraffe [53]. Giraffe is part of the [vg toolkit](https://github.com/vgteam/vg), which provides graph data structures, interchange formats, alignment, genotyping and variant calling methods based on variation graphs. The HPRC compared the accuracy of calling small variants between their pangenome approach, using vf giraffe for alignment, to traditional approaches leveraging linear assemblies (i.e. bwa-mem alignment to GRCh38). Using either deepvariant or deeptrio for variant calling, they demonstrated that their pangenome approach outperformed the traditional linear approaches, especially in regions with errors in GRCh38 and medically relevant regions. Deeptrio outperformed deepvariant, and these improvements were additive to those of the pangenome. 

## Workflows
The HPRC has deposited WDL workflows on Zenodo for their [Giraffe-DeepVariant pipeline](https://doi.org/10.5281/zenodo.6655968) and [Giraffe-DeepTrio pipeline](https://zenodo.org/records/6655962). The suitability of these workflows for pangenome based short-read variant calling in unsolved rare disease samples will be explored as part of this project.

## Cohort Variant Calls
The HPRC has also provided combined VCFs and allele frequencies from 2,504 unrelated srGS samples of the 1KG, which they generate using their [Giraffe-DeepVariant pipeline](https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=publications/PANGENOME_2022/DeepVariant-1000GPcalls/). This will serve as a useful resource for variant frequency annotation and filtering.

## Relevent Publications
**HPRC Draft Pangenome paper**

Liao, W.-W., et al., A draft human pangenome reference. Nature, 2023. 617(7960): p. 312-324.

**vg-giraffe paper**

Sirén, J., et al., Pangenomics enables genotyping of known structural variants in 5202 diverse genomes. Science, 2021. 374(6574): p. abg8871.


