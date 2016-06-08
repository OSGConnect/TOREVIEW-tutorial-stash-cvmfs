#!/bin/bash

output_file=word_frequency_count.output
echo " " > word_frequency_count.output
for input_file in /cvmfs/stash.osgstorage.org/user/dbala/public/InputBooks/*.txt
do
    echo "-------Word Count for $input_file --------" >> $output_file
    cat $input_file |tr [:space:] '\n' | grep -v "^\s*$" | sort | uniq -c | sort -bnr | head -n 10 >> $output_file
    echo "-------------------------------------------------" >> $output_file
done
