nextflow ../minbreeze-flash/main.nf -c proj_spec.conf -profile conda,pbspro -w work_temp -resume \
	-with-dag nflog/flowchart.png -with-timeline nflog/timeline.html -with-report nflog/report.html
