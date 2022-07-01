nextflow run main.nf -profile test -resume \
	-with-report results-kraken2/nextflow.html \
	-with-timeline results-kraken2/timeline.html \
	-with-trace results-kraken2/trace.txt \
	-with-dag results-kraken2/dag.png
