#!/usr/bin/env nextflow

process SPLITLETTERS {

} 

process CONVERTTOUPPER {
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}

    // split the input string into chunks

    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory



}