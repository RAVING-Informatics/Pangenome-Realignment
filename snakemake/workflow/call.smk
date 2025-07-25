def get_surjected_bam(wildcards):
    try:
        return config["surjected_bams"][wildcards.sample]
    except KeyError:
        return f"results/{wildcards.sample}/{wildcards.sample}.{wildcards.graph}.{wildcards.surj}.bam"

def get_surjected_bai(wildcards):
    try:
        return config["surjected_bams"][wildcards.sample] + ".bai"
    except KeyError:
        return f"results/{wildcards.sample}/{wildcards.sample}.{wildcards.graph}.{wildcards.surj}.bam.bai"

rule pack:
    input:
        gbz="results/{sample}/{graph}.sample_pg.{sample}.gbz",
        gaf="results/{sample}/{sample}.{graph}.gaf.gz"
    output: tempCond('results/{sample}/{sample}.{graph}.pack')
    threads: 8
    priority: 3
    benchmark: 'benchmark/{sample}.{graph}.pack.benchmark.tsv'
    log: 'logs/pack.{graph}.{sample}.log'
    container: docker_imgs['vg']
    shell: "vg pack -x {input.gbz} -a {input.gaf} -Q 5 -t {threads} -o {output} 2> {log}"

if 'gt_ref' in config and config['gt_ref']:
    rule vgcall:
        input: 
            gbz=getgbz(),
            paths_list=config['ref_paths_list'],
            pack='results/{sample}/{sample}.{graph}.pack'
        output: tempCond('results/{sample}/{sample}.{graph}.gt.minlen{minlen}.vcf.gz')
        threads: 8
        priority: 4
        benchmark: 'benchmark/{sample}.{graph}.vgcall.minlen{minlen}.benchmark.tsv'
        container: docker_imgs['vg']
        shell:
            """
            RPATHS=""
            for RP in `cat {input.paths_list}`
            do
            RPATHS=`echo "-p $RP $RPATHS"`
            done

            vg call -t {threads} -k {input.pack} -aAz $RPATHS -s {wildcards.sample} -c {wildcards.minlen} {input.gbz} | gzip > {output}
            """
else:
    rule vgcall:
        input: 
            gbz="results/{sample}/{graph}.sample_pg.{sample}.gbz",
            paths_list=config['ref_paths_list'],
            pack='results/{sample}/{sample}.{graph}.pack'
        output: tempCond('results/{sample}/{sample}.{graph}.gt.minlen{minlen}.vcf.gz')
        threads: 8
        priority: 4
        benchmark: 'benchmark/{sample}.{graph}.vgcall.minlen{minlen}.benchmark.tsv'
        container: docker_imgs['vg']
        shell:
            """
            RPATHS=""
            for RP in `cat {input.paths_list}`
            do
            RPATHS=`echo "-p $RP $RPATHS"`
            done

            vg call -t {threads} -k {input.pack} -Az $RPATHS -s {wildcards.sample} -c {wildcards.minlen} {input.gbz} | gzip > {output}
            """

rule dv_make_examples:
    input:
        ref=getref(),
        ref_idx=getrefidx(),
        bam=get_surjected_bam,
        bai=get_surjected_bai
    output: temp("results/{sample}/{sample}.{graph}.{surj}.make_examples.tfrecord.tar.gz")
    params:
        label="{sample}.{graph}.{surj}",
        dvdir="dv_{sample}_{graph}_{surj}"
    threads: 8
    priority: 6
    container: docker_imgs['deepvariant']
    benchmark: 'benchmark/{sample}.{graph}.{surj}.dv_make_examples.benchmark.tsv'
    log: 'logs/{sample}.{graph}.{surj}.dv_make_examples.log'
    shell:
        """
        mkdir -p {params.dvdir}

        seq 0 $(({threads}-1)) | \
        parallel -q --halt 2 --line-buffer /opt/deepvariant/bin/make_examples \
        --mode calling \
        --ref {input.ref} \
        --reads {input.bam} \
        --examples ./{params.dvdir}/make_examples.{params.label}.tfrecord@{threads}.gz \
        --sample_name {wildcards.sample} \
        --gvcf ./{params.dvdir}/gvcf.{params.label}.tfrecord@{threads}.gz \
        --channels insert_size \
        --min_mapping_quality 1 \
        --keep_legacy_allele_counter_behavior \
        --task {{}} 2> {log}
        
        tar -czf '{output}' {params.dvdir}
        rm -rf {params.dvdir}
        """

if config['use_gpu']:
    rule dv_call_variants_gpu:
        input:
            ref=getref(),
            ref_idx=getrefidx(),
            ex="results/{sample}/{sample}.{graph}.{surj}.make_examples.tfrecord.tar.gz",
            model_data=config["model"] + ".data-00000-of-00001",
            model_index=config["model"] + ".index",
            model_meta=config["model"] + ".meta"
        output:
            vcf=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.vcf.gz"),
            tbi=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.vcf.gz.tbi"),
            gvcf=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.g.vcf.gz"),
            gtbi=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.g.vcf.gz.tbi")
        params:
            call_tf="temp.call_variants_output.{sample}.{surj}.tfrecord.gz",
            label="{sample}.{graph}.{surj}",
            dvdir="dv_{sample}_{graph}_{surj}"
        container: docker_imgs['deepvariant_gpu']
        threads: 8
        priority: 7
        benchmark: 'benchmark/{sample}.{graph}.{surj}.dv_call_variants_gpu.benchmark.tsv'
        log: 'logs/{sample}.{graph}.{surj}.dv_call_variants_gpu.log'
        shell:
            """
            tar -xzf {input.ex}

            /opt/deepvariant/bin/call_variants \
            --outfile {params.call_tf} \
            --examples "{params.dvdir}/make_examples.{params.label}.tfrecord@{threads}.gz" \
            --checkpoint "{config[model]}" 2> {log}

            /opt/deepvariant/bin/postprocess_variants \
            --ref {input.ref} \
            --infile {params.call_tf} \
            --nonvariant_site_tfrecord_path "{params.dvdir}/gvcf.{params.label}.tfrecord@{threads}.gz" \
            --outfile "{output.vcf}" \
            --gvcf_outfile "{output.gvcf}" 2>> {log}

            rm -fr {params.call_tf} {params.dvdir}
            """
else:
    rule dv_call_variants:
        input:
            ref=getref(),
            ref_idx=getrefidx(),
            ex="results/{sample}/{sample}.{graph}.{surj}.make_examples.tfrecord.tar.gz",
            model_data=config["model"] + ".data-00000-of-00001",
            model_index=config["model"] + ".index",
            model_meta=config["model"] + ".meta"
        output:
            vcf=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.vcf.gz"),
            tbi=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.vcf.gz.tbi"),
            gvcf=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.g.vcf.gz"),
            gtbi=tempCond("results/{sample}/{sample}.{graph}.{surj}.snv_indels.g.vcf.gz.tbi")
        params:
            call_tf="temp.call_variants_output.{sample}.{surj}.tfrecord.gz",
            label="{sample}.{graph}.{surj}",
            dvdir="dv_{sample}_{graph}_{surj}"
        container: docker_imgs['deepvariant']
        threads: 8
        priority: 7
        benchmark: 'benchmark/{sample}.{graph}.{surj}.dv_call_variants.benchmark.tsv'
        log: 'logs/{sample}.{graph}.{surj}.dv_call_variants.log'
        shell:
            """
            tar -xzf {input.ex}

            /opt/deepvariant/bin/call_variants \
            --outfile {params.call_tf} \
            --examples "{params.dvdir}/make_examples.{params.label}.tfrecord@{threads}.gz" \
            --checkpoint "{config[model]}" 2> {log}

            /opt/deepvariant/bin/postprocess_variants \
            --ref {input.ref} \
            --infile {params.call_tf} \
            --nonvariant_site_tfrecord_path "{params.dvdir}/gvcf.{params.label}.tfrecord@{threads}.gz" \
            --outfile "{output.vcf}" \
            --gvcf_outfile "{output.gvcf}" 2>> {log}

            rm -fr {params.call_tf} {params.dvdir}
            """

rule sv_call_manta:
    input: 
        ref=getref(),
        ref_idx=getrefidx(),
        bam=get_surjected_bam,
        bai=get_surjected_bai
    output:
        calls=tempCond("results/{sample}/{sample}.{graph}.{surj}.sv_manta.vcf.gz"),
        cand=tempCond("results/{sample}/{sample}.{graph}.{surj}.sv_manta_candidates.vcf.gz")
    params:
        tmp_dir='temp.manta.{sample}.{graph}.{surj}'
    threads: 8
    container: docker_imgs['manta']
    priority: 6
    benchmark: 'benchmark/{sample}.{graph}.{surj}.manta.benchmark.tsv'
    log: 'logs/{sample}.{graph}.{surj}.manta.log'
    shell:
        """
        rm -rf {params.tmp_dir}
        configManta.py --bam {input.bam} --referenceFasta {input.ref} --runDir {params.tmp_dir}
        {params.tmp_dir}/runWorkflow.py -j {threads} 2> {log}
        mv {params.tmp_dir}/results/variants/diploidSV.vcf.gz {output.calls}
        mv {params.tmp_dir}/results/variants/candidateSV.vcf.gz {output.cand}
        rm -rf {params.tmp_dir}
        """

rule coverage_mosdepth:
    input:
        bam=get_surjected_bam,
        bai=get_surjected_bai
    output:
        qbed=tempCond("results/{sample}/{sample}.{graph}.{surj}.coverage.q.bed.gz"),
        bed=tempCond("results/{sample}/{sample}.{graph}.{surj}.coverage.bed.gz")
    params:
        tmp_dir="temp.mosdepth.{sample}.{graph}.{surj}"
    threads: 4
    container: docker_imgs['mosdepth']
    priority: 6
    benchmark: 'benchmark/{sample}.{graph}.{surj}.coverage_mosdepth.benchmark.tsv'
    shell:
        """
        mkdir -p {params.tmp_dir}
        mosdepth -q 0:1:4:100: -b 500 -t {threads} {params.tmp_dir}/cov {input.bam}
        mv {params.tmp_dir}/cov.quantized.bed.gz {output.qbed}
        mv {params.tmp_dir}/cov.regions.bed.gz {output.bed}
        rm -rf {params.tmp_dir}
        """
