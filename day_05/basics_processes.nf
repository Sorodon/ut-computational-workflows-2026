params {
    step: Integer = 0
    zip: String = 'zip'
}


process SAYHELLO {
    debug true
    output:
        stdout
    script:
        """
        echo Hello World!
        """
}

process SAYHELLO_PYTHON {
    debug true
    output:
        stdout
    script:
        """
        #!/bin/python
        print('Hello World!')
        """
}

process SAYHELLO_PARAM {
    debug true
    input:
        val helloworld
    output:
        stdout
    script:
        """
        echo '${helloworld}'
        """
}

process SAYHELLO_FILE {
    publishDir 'results', mode: 'move'
    input:
        val helloworld
    output:
        path('helloworld')
    script:
        """
        touch 'helloworld'
        echo '${helloworld}' > helloworld
        """
}

process UPPERCASE {
    publishDir 'results', mode: 'copy'
    input:
        val instr
    output:
        path('uppercase')
    script:
        """
        touch 'uppercase'
        echo ${instr} | tr '[:lower:]' '[:upper:]' > uppercase
        """
}

process PRINTUPPER {
    debug true
    input:
        path uppercase
    output:
        stdout
    script:
        """
        cat ${uppercase}
        """
}

process ZIP_FILE {
    debug true
    publishDir 'results', mode: 'copy'
    input:
        path infile
        val zip
    output:
        stdout
        path('*')
    script:
        """
        OUTFILE=\$(basename $infile)
        GZIP_OUTFILE=\$OUTFILE.gz
        BZIP_OUTFILE=\$OUTFILE.bz2
        if [[ ${zip} == 'zip' ]]; then
            zip \$OUTFILE $infile >/dev/null && \
            echo \$(pwd)/\$OUTFILE.zip
        elif [[ $zip == 'gzip' ]]; then
            gzip -c $infile > \$GZIP_OUTFILE && \
            echo \$(pwd)/\$GZIP_OUTFILE
        elif [[ $zip == 'bzip2' ]]; then
            bzip2 -c $infile > \$BZIP_OUTFILe && \
            echo \$(pwd)/\$BZIP_OUTFILE
        fi
        """
}

process COMPRESS_FILES {
    debug true
    publishDir 'results', mode: 'copy'
    input:
        path infile
    output:
        stdout
        path('*')
    script:
        """
        OUTFILE=\$(basename $infile)
        GZIP_OUTFILE=\$OUTFILE.gz
        BZIP_OUTFILE=\$OUTFILE.bz2
        zip \$OUTFILE $infile && \
            echo \$(pwd)/\$OUTFILE.zip
        gzip -c $infile > \$GZIP_OUTFILE && \
            echo \$(pwd)/\$GZIP_OUTFILE
        bzip2 -c $infile > \$BZIP_OUTFILE && \
            echo \$(pwd)/\$BZIP_OUTFILE
        """

}

process WRITETOFILE {
    debug true
    publishDir 'results', mode: 'copy'
    input:
        val terfs
    output:
        path "names.tsv"
    script:
        """
        echo "name\ttitle" > names.tsv
        echo "${terfs.collect{v->"${v.name}\t${v.title}"}.join('\n')}" >> names.tsv
        """
}



workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        ZIP_FILE(out_ch, params.zip)
        
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        COMPRESS_FILES(out_ch)
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        in_ch.collect()
            | WRITETOFILE
            // continue here // this is super misleading, as we need to use collect before here or resort to unsafe overwriting of files created on other threads.
    }

}
