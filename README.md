# HIT-bulkISOseq_paper
The scripts for analysis of HIT-ISOseq paper.

## Dependencies
* ncbi-blast-2.2.26+ or later

## Deconcatenation of HIT-ISOseq CCS by primer blast
### 3.1) cat ccs result in bam format
```
samtools view ccs.bam > ccs.sam
samtools view ccs.bam | awk '{print ">"$1"\n"$10}' > ccs.fa
```
### 3.2) make primer blast to CCS
```
makeblastdb -in primer.fa -dbtype nucl
blastn -query ccs.fa -db primer.fa -outfmt 7 -word_size 5 > mapped.m7
```
The following primer sequence is commonly used by PacBio official IsoSeq library construction protocol and `BGI patented multi-transcripts in one ZMW library construction protocol`.
```
$ cat primer.fa
>primer_F
AAGCAGTGGTATCAACGCAGAGTACATGGGGGGGG
>primer_S
GTACTCTGCGTTGATACCACTGCTTACTAGT
```
The following primer sequence is used by `BGI patented full-length polyA tail detection library construction protocol`.
```
$ cat primer.fa
>primer_F
AAGCAGTGGTATCAACGCAGAGTAC
>primer_S
AAGCAGTGGTATCAACGCAGAGTACATCGATCCCCCCCCCCCCTTT
```
### 3.3) classify CCS by primer
Here is an example for classifying CCS generate from PacBio official IsoSeq library construction protocol and `BGI patented multi-transcripts in one ZMW library construction protocol`.
```
perl classify_by_primer.pl -blastm7 mapped.m7 -ccsfa ccs.fa -umilen 8 -min_primerlen 16 -min_isolen 50 -outdir ./ -sample sampleName
```
`classify_by_primer.pl` wraps a tool to detect full-length transcript from CCS base on PacBio official IsoSeq library construction protocol and `BGI patented multi-transcripts in one ZMW library construction protocol`.
```
$ classify_by_primer.pl -h

Despriprion: BGI version's full-length transcript detection algorithm for PacBio official IsoSeq library construction protocol and BGI patented multi-transcripts in one ZMW library construction protocol.
Usage: classify_by_primer -blastm7 mapped.m7 -ccsfa ccs.fa -umilen 8 -min_primerlen 15 -min_isolen 200 -outdir ./

Options:
	-blastm7*:		result of primer blast to ccs.fa in blast -outfmt 7 format
	-ccsfa*:		the ccs.fa you want to classify to get full-length transcript
	-umilen*:		the UMI length in your library, if set to 0 means nonUMI for library construction
	-min_primerlen*:	the minimum primer alignment length in ccs.fa
	-min_isolen*:		the minimum output's transcript length whithout polyA tail
	-outdir*:		output directory
	-sample*:		sample name
	-help:			print this help
```
