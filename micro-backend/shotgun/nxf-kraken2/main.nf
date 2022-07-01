// kraken2-bracken-krona pipeline

/*
NXF ver 19.08+ needed because of the use of tuple instead of set
*/
if( !nextflow.version.matches('>=20.04') ) {
    println "This workflow requires Nextflow version 20.04 or greater and you are running version $nextflow.version"
    exit 1
}

/*
* ANSI escape codes to color output messages
*/
ANSI_GREEN = "\033[1;32m"
ANSI_RED = "\033[1;31m"
ANSI_RESET = "\033[0m"

def defval(param, defaultval){
  param ? param : defaultval
}

/* 
 * pipeline input parameters 
 */
params.readsdir = "fastq"
params.outdir = "${workflow.launchDir}/results-kraken2" // output is where the reads are because it is easier to integrate with shiny later
params.fqpattern = "*_R{1,2}.fastq.gz"
params.readlen = 100
params.ontreads = false
params.kraken_db = false
// params.kraken_db = "https://genome-idx.s3.amazonaws.com/kraken/k2_standard_8gb_20200919.tar.gz"
//params.kraken_store = "$HOME/db/kraken" // here kraken db will be collected
// todo: stage dynamically, using the file name --> under $Home/db/kraken/filename
params.weakmem = false
params.taxlevel = "S" //level to estimate abundance at [options: D,P,C,O,F,G,S] (default: S)
params.skip_krona = true
params.help = ""
// Haven't put it in the argument yet.
params.adapter1 = ""
params.adapter2 = ""
// Right now make it work for pair-end
if (params.adapter1 && params.adapter2) {
  fastp_adapter = "--adapter_sequence ${params.adapter1} --adapter_sequence_r2 ${params.adapter2}"
} else
{ fastp_adapter = ""}


/* Instead of manually write this everytime, let's do it here
log.info "Test"
def allParams = params.keySet();
log.info "$allParams"
log.info "end Test"
exit(1)
*/

/* 
 * handling of parameters 
 */

//just in case trailing slash in readsdir not provided...
readsdir_repaired = "${params.readsdir}".replaceFirst(/$/, "/") 

// build search pattern for fastq files in input dir
reads = readsdir_repaired + params.fqpattern

// get counts of found fastq files
readcounts = file(reads)

if (params.help) {
    helpMessage()
    exit(0)
}

log.info """
        ===========================================
         K R A K E N 2 - B R A C K E N  P I P E L I N E

         Used parameters:
        -------------------------------------------
         --readsdir         : ${params.readsdir}
         --fqpattern        : ${params.fqpattern}
         --ontreads         : ${params.ontreads}
         --readlen          : ${params.readlen}
         --outdir           : ${params.outdir}
         --kraken_db        : ${params.kraken_db}
         --weakmem          : ${params.weakmem}
         --taxlevel         : ${params.taxlevel}
         --skip_krona       : ${params.skip_krona}
         --adapter1         : ${params.adapter1}
         --adapter2         : ${params.adapter2}

         Runtime data:
        -------------------------------------------
         Running with profile:   ${ANSI_GREEN}${workflow.profile}${ANSI_RESET}
         Container:              ${ANSI_GREEN}${workflow.container}${ANSI_RESET}
         Running as user:        ${ANSI_GREEN}${workflow.userName}${ANSI_RESET}
         Launch dir:             ${ANSI_GREEN}${workflow.launchDir}${ANSI_RESET}
         Base dir:               ${ANSI_GREEN}${baseDir}${ANSI_RESET}
         Fastq files:            ${ANSI_GREEN}${ readcounts.size() } files found${ANSI_RESET}
         """
         .stripIndent()
/* 
 * define help 
 */
def helpMessage() {
log.info """
        ===========================================
         K R A K E N 2 - B R A C K E N  P I P E L I N E

         Note: 
         single- or pair-end data is automatically detected

         Usage:
        -------------------------------------------
         --readsdir     : directory with fastq files, default is "fastq"
         --fqpattern    : regex pattern to match fastq files, default is "*_R{1,2}.fastq.gz"
         --ontreads     : logical, set to true in case of Nanopore reads, default is false. This parameter has influence on fastp -q and bracken -r
         --readlen      : read length used for bracken, default is 150 (250 if ontreads is true). A kmer distribution file for this length has to be present in your database, see bracken help.
         --outdir       : where results will be saved, default is "results-kraken2"
         --kraken_db    : either 'false' (default, do not execute kraken2), or a path to a kraken2 database folder. See https://benlangmead.github.io/aws-indexes/k2 for available ready to use indexes
         --weakmem      : logical, set to true to avoid loading the kraken2 database in RAM (on weak machines)
         --taxlevel     : taxonomical level to estimate bracken abundance at [options: D,P,C,O,F,G,S] (default: S)
         --skip_krona   : skip making krona plots
        ===========================================
         """
         .stripIndent()

}


// because all is from conda, get versions from there. Note double escape for OR
process SoftwareVersions {
    publishDir "${params.outdir}/software_versions", mode: 'copy'

    output:
        file("software_versions.txt")

    script:
    """
    echo "software\tversion\tbuild\tchannel" > tempfile
    
    conda list | \
    grep 'fastp\\|kraken2\\|bracken\\|krona\\|r-data.table\\|r-dplyr\\|r-tidyr\\|r-dt\\|r-d3heatmap\\|r-base' \
    >> tempfile

    echo 'nextflow\t${nextflow.version}\t${nextflow.build}' >> tempfile
    multiqc --version | sed 's/, version//' >> tempfile

    # replace blanks with tab for easier processing downstream
    tr -s '[:blank:]' '\t' < tempfile > software_versions.txt
    """
}


Channel
    .fromFilePairs( reads, checkIfExists: true, size: -1 ) // default is 2, so set to -1 to allow any number of files
    .ifEmpty { error "Can not find any reads matching ${reads}" }
    .set{ read_ch }

if(params.kraken_db){
    kraken_db_ch = Channel.value(params.kraken_db)
} else {
    kraken_db_ch = Channel.empty()
}


/* 
 * run fastp 
 */
process Fastp {

    tag "fastp on $sample_id"

    cpus "2"
    memory "4 GB"
    time "1:00:00"

    //echo true
    publishDir "${params.outdir}/trimmed_fastq", mode: 'copy', pattern: 'trim_*' // publish only trimmed fastq files

    input:
        tuple sample_id, file(x) from read_ch
    
    output:
        tuple sample_id, file('trim_*') into fastp_ch
        file("${sample_id}_fastp.json") into fastp4mqc_ch


    script:
    def single = x instanceof Path // this is from Paolo: https://groups.google.com/forum/#!topic/nextflow/_ygESaTlCXg
    def fastp_input = single ? "-i \"${ x }\"" : "-i \"${ x[0] }\" -I \"${ x[1] }\""
    def fastp_output = single ? "-o \"trim_${ x }\"" : "-o \"trim_${ x[0] }\" -O \"trim_${ x[1] }\""
    def qscore_cutoff = params.ontreads ? 7 : 15 //here ontreads matters

    """
    fastp \
    -q $qscore_cutoff \
    $fastp_input \
    $fastp_output \
    $fastp_adapter \
    -j ${sample_id}_fastp.json
    """
}
// make fastp channels for kraken2 and mqc
fastp_ch
    .into { fastp1 ; }


/*
 run kraken2 AND bracken 
 Kraken-Style Bracken Report --> to use in pavian
 Bracken output file --> just a table, to be formatted and saved as html DataTable using R
 kraken2 counts file, this is the kraken2.output --> to use in krona
 */
//fastp1.println()

process Kraken2 {
    tag "kraken2 on $sample_id"

    cpus "32"
    memory "64 GB"
    time "24:00:00"

    publishDir "${params.outdir}/samples", mode: 'copy', pattern: '*.{report,tsv}'
    publishDir "${params.outdir}/bracken_misc", mode: 'copy', pattern: 'bracken_misc/**'
    
    input:
        path db from kraken_db_ch
        tuple sample_id, file(x) from fastp1
    
    output:
        file("*report") into kraken2mqc_ch // both kraken2 and the bracken-corrected reports are published and later used in pavian?
        file("*kraken2.krona") into kraken2krona_ch
        tuple sample_id, file("*bracken.tsv") into bracken2dt_ch
        file("*bracken.tsv") into bracken2summary_ch
    
    script:
    def single = x instanceof Path
    def kraken_input = single ? "\"${ x }\"" : "--paired \"${ x[0] }\"  \"${ x[1] }\""
    def memory = params.weakmem ? "--memory-mapping" : ""  // use --memory-mapping to avoid loading db in ram on weak systems
    def rlength = params.ontreads ? 250 : params.readlen // and here ontreads matters. Default for -r is 100 in bracken, Dilthey used 1k in his paper
    
        """
        kraken2 \
            -db $db \
            $memory \
	        --threads ${task.cpus} \
            --report ${sample_id}_kraken2.report \
            $kraken_input \
            > kraken2.output
        cut -f 2,3 kraken2.output > ${sample_id}_kraken2.krona

        bracken \
            -d $db \
            -r $rlength \
            -i ${sample_id}_kraken2.report \
            -l ${params.taxlevel} \
            -o ${sample_id}_bracken.tsv

        for i in C O F G
        do
            mkdir -p bracken_misc/\${i}
            bracken \
                -d $db \
                -r $rlength \
                -i ${sample_id}_kraken2.report \
                -l \${i} \
                -o bracken_misc/\${i}/${sample_id}_bracken.tsv
        done
        """

}

    
process KronaDB {

    cpus "5"
    memory "32 GB"
    time "12:00:00"

    output:
        file("krona_db/taxonomy.tab") optional true into krona_db_ch // is this a value ch?

    when: 
        !params.skip_krona
        
    script:
    """
    ktUpdateTaxonomy.sh krona_db
    """
}

// prepare channel for krona, I want to have all samples in one krona plot
// e.g. ktImportTaxonomy file1 file2 ...

// run krona on the kraken2 result
process KronaFromKraken {

    memory "32GB"
    publishDir params.outdir, mode: 'copy'

    input:
        file(x) from kraken2krona_ch.collect()
        file("krona_db/taxonomy.tab") from krona_db_ch
    
    output:
        file("*_taxonomy_krona.html")

    when:
        !params.skip_krona
    
    script:
    """
    mkdir krona
    ktImportTaxonomy -o kraken2_taxonomy_krona.html -tax krona_db $x
    """
}


// format and save bracken table as DataTable, per sample

process DataTables1 {
    tag "DataTables1 on $sample_id"
    publishDir "${params.outdir}/samples", mode: 'copy', pattern: '*.html'

    input:
        tuple sample_id, file(x) from bracken2dt_ch
        
    output:
        file("*.html")

    script: 
    """
    bracken2dt.R $x ${sample_id}_bracken.html
    """
}

// use combine_bracken_outputs.py from bracken instead of bracken2summary.R
// should be the same though
// saves one summary table as html and csv for all samples
process DataTables2 {
    tag "DataTables2"
    publishDir params.outdir, mode: 'copy'

    input:
        file(x) from bracken2summary_ch.collect() //this gives all the bracken table files as params to the script
    output:
        file("*.html") optional true // for some sample numbers html is not generated
        file("*.csv")

// the bracken2summary.R decides what to output depending on number of samples
// for all sample counts - output a csv summary, for <= 12 - make html table and graph
    script:
    """
    bracken2summary.R $x
    """
}

// still no bracken module in mqc, opened an issue on github
process MultiQC {
    tag "MultiQC"
    publishDir params.outdir, mode: 'copy'

    input:
        file x from fastp4mqc_ch.collect()
        file y from kraken2mqc_ch.collect().ifEmpty([]) 
    output:
        file "multiqc_report.html"
    
    script:
    """
    multiqc --interactive .
    """
}

//=============================
workflow.onComplete {
    if (workflow.success) {
        log.info """
            ===========================================
            Output files are here:   ==> ${ANSI_GREEN}$params.outdir${ANSI_RESET}
            ===========================================
            """
            .stripIndent()
    }
    else {
        log.info """
            ===========================================
            ${ANSI_RED}Finished with errors!${ANSI_RESET}
            """
            .stripIndent()
    }
}

// vi: ft=groovy
