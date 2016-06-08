[title]: - "Moving data to a worker machine with Stash-CVMFS"
[TOC]
 
## Overview

Stash-CVMFS is a data service for the OSG users. Stash-CVMFS allows you to replicate your data on 
multiple worker machines so that 
the data is readily available for data intensive jobs. Due to specific style of CVMFS update, the data 
replication is a not instantaneous.  Therefore, to use Stash-CVMFS service, you need to prepare the  data well 
ahead of job submission. 

When to use stash-cvmfs?

* Jobs require large input or reference data files (> 500 MB)
* The same data files are used repeatedly for many separate jobs

## How to use stash-cvmfs?

Stash-CVMFS service picks up data from the public directory and replicates the data on multiple remote 
machines. So you need to copy the input data files into the public directory: 

	/stash/user/<userid>/public 

where `<userid>` is your username.  The input files are replicated under   

      /cvmfs/stash.osgstorage.org/user/<userid>/public 

on multiple remote machines. You can check the replicated files on the OSG Connect submit node by

     ls /cvmfs/stash.osgstorage.org/user/<userid>/public 

It may take about 1-4 hours for the input data from public to show up on the replica location. 

To access input data on remote worker machine, include the following line in the job's submit script to indicate that CvmfsStash is required:

        +WantsCvmfsStash = true

In your job,  read or copy the input data from the replica 
directory `/cvmfs/stash.osgstorage.org/user/<userid>/public`.  Let us see an 
example in the following tutorial. 

## Stash-CVMFS tutorial files

It is easiest to start with the `tutorial` command. In the command prompt, type

    $ tutorial stash-cvmfs # Copies input and script files to the directory tutorial-stash-cvmfs
 
This will create a directory `tutorial-stash-cvmfs`. Inside the directory, you will see the following files

    word_frequency_count.bash        # Job execution script file
    word_frequency_count.submit      # Condor job submission file

Here, `word_frequency_count.submit` is the job submission file and `word_frequency_count.bash` is the job execution shell script. 

### Input data 

The input data for the tutorial were copied to the public directory a while ago. As a result, the Stash-CVMFS 
completed the replication of input data on multiple machines, including the submit node. The command

    $ ls -1 /stash/user/dbala/public/InputBooks/*.txt

shows the list of text files on the replica location as follows:

    /stash/user/dbala/public/InputBooks/Alices_Adventures_in_Wonderland_by_Lewis_Carroll.txt
    /stash/user/dbala/public/InputBooks/Dracula_by_Bram_Stoker.txt
    /stash/user/dbala/public/InputBooks/Pride_and_Prejudice_by_Jane_Austen.txt
    /stash/user/dbala/public/InputBooks/The_Adventures_of_Huckleberry_Finn_by_Mark_Twain.txt
    /stash/user/dbala/public/InputBooks/Ulysses_by_James_Joyce.txt


## Job execution file

Let us take a look at the  executable script `word_frequency_count.bash`

    #!/bin/bash  # sets up the shell environment (always include this line)

    echo " " > word_frequency_count.output  

    # Loop over the txt files, find the word frequency, and print top ten values in the output file. 
    for input_file in /cvmfs/stash.osgstorage.org/user/dbala/public/InputBooks/*.txt
    do
        echo "-------Word Count for $input_file --------" >> $output_file
        cat $input_file |tr [:space:] '\n' | grep -v "^\s*$" | sort | uniq -c | sort -bnr | head -n 10 >> word_frequency_count.output
        echo "-------------------------------------------------" >> $output_file
    done

The executable script reads each input file directly from the replica location. 

## HTCondor job submission file

Let us take a look at the job description file `word_frequency_count.submit`. 
    
   
    Universe = vanilla
    Executable = word_frequency_count.bash

    log           = job.log

    # Look for machines with stash-cvmfs replica is available 
    +WantsStashCvmfs = true

    Queue 1

In this  HTCondor job description file, the keyword `+WantsStashCvmfs = true`  makes HTCondor to look for a worker 
machine that has stash-cvmfs available. 


## Running the job 

We submit the job using `condor_submit` command as follows

	$ condor_submit word_frequency_count.submit //Submit the condor job 

This job should be finished quickly (less than an hour). You can check the status of the submitted job by using the `condor_q` command as follows

	$ condor_q username  # The status of the job is printed on the screen. Here, username is your login name.

After the job completed, you will see the output file `word_frequency_count.output` in your work directory.


## Getting Help
For assistance or questions, please email the OSG User Support team  at [user-support@opensciencegrid.org](mailto:user-support@opensciencegrid.org) or visit the [help desk and community forums](http://support.opensciencegrid.org).
