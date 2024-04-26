# HIT-bulkISOseq_paper
The scripts for analysis of HIT-ISOseq paper.

# Dependencies
* SMRTlink 8.0 or later `you can install it in light way: smrtlink_*.run --rootdir smrtlink --smrttools-only`
* ncbi-blast-2.2.26+ or later
* R-3.4.1 or later with ggplot2| gridExtra | grid

# Usage
export`smrtlink` `blast` `R` to you path first.
```
export PATH=$PATH:/smrtlink/smrtcmds/bin
export PATH=$PATH:/ncbi-blast-2.2.28+/bin
export PATH=$PATH:/R-3.1.1/bin
```

## Step1 raw data statistics (optional)
```
samtools view *.subreads.bam | awk '{print $1"\t"length($10)}' > tmp.len
sed '1i Subreads\tLength' tmp.len > subreads.len
perl PolymeraseReads.stat.pl subreads.len ./
perl SubReads.stat.pl subreads.len ./
```
## Step2 run CCS
```
ccs *.subreads.bam ccs.bam --min-passes 0 --min-length 50 --max-length 21000 --min-rq 0.75 -j 4
```
Start from SMRTlink8.0, CCS4.0 significantly speeds up the analysis and can be easily parallelized by using `--chunk`.

## Step3 classify CCS by primer blast
### 3.1) cat ccs result in bam format from each chunk
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
classify_by_primer -blastm7 mapped.m7 -ccsfa ccs.fa -umilen 8 -min_primerlen 16 -min_isolen 200 -outdir ./
```
`classify_by_primer` wraps a tool to detect full-length transcript from CCS base on PacBio official IsoSeq library construction protocol and `BGI patented multi-transcripts in one ZMW library construction protocol`.
```
$ classify_by_primer -h

Despriprion: BGI version's full-length transcript detection algorithm for PacBio official IsoSeq library construction protocol and BGI patented multi-transcripts in one ZMW library construction protocol.
Usage: classify_by_primer -blastm7 mapped.m7 -ccsfa ccs.fa -umilen 8 -min_primerlen 15 -min_isolen 200 -outdir ./

Options:
        -blastm7*:              result of primer blast to ccs.fa in blast -outfmt 7 format
        -ccsfa*:                the ccs.fa you want to classify to get full-length transcript
        -umilen*:               the UMI length in your library, if set to 0 means nonUMI for library construction
        -min_primerlen*:        the minimum primer alignment length in ccs.fa
        -min_isolen*:           the minimum output's transcript length whithout polyA tail
        -outdir*:               output directory
```
Here is an example for classifying CCS generate from `BGI patented full-length polyA tail detection library construction protocol`, the parameters and usage are the same as in `classify_by_primer`.
```
classify_by_primer.fullpa -blastm7 mapped.m7 -ccsfa ccs.fa -umilen 8 -min_primerlen 16 -min_isolen 200 -outdir ./
