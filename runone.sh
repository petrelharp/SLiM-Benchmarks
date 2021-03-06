#!/bin/bash

# Run one model for a given number of replicates with a given number of threads
#
# bash ./runone.sh <model-name> <replicates> [<thread-count>]
#
# Benjamin C. Haller, 13 July 2020
#
# see _README.txt for documentation
#

usage()
{
    echo "usage: bash ./runone.sh <model-name> <replicates> [<thread-count>]"
    exit 1
}

intregex='^[1-9][0-9]*$'


# Validate user input

modelname=$1
replicates=$2
threadcount=$3

if [ -z "${modelname}" ] ; then
    echo "ERROR: A model name must be supplied."
    usage
fi
if [ -z "${replicates}" ] ; then
    echo "ERROR: A replicate count must be supplied."
    usage
fi
if ! [[ "${replicates}" =~ ${intregex} ]] ; then
    echo "ERROR: The replicate count must be a positive integer."
    usage
fi
if [ -n "${threadcount}" ] ; then
    if ! [[ "${threadcount}" =~ ${intregex} ]] ; then
        echo "ERROR: The thread count must be a positive integer."
        usage
    fi
fi

modelfile="${modelname}.slim"
modelpath="./models/${modelfile}"

if ! [ -f "${modelpath}" ] ; then
	echo "No model at ${modelpath}"
	exit 1
fi

if ! [ -x "./slim_single" ] ; then
	echo "No executable found at ./slim_single"
	exit 1
fi
if ! [ -x "./slim_multi" ] ; then
	echo "No executable found at ./slim_multi"
	exit 1
fi


# Inform the user of what we will do

if [ -z "${threadcount}" ] ; then
	echo -n "Running ${replicates} replicates of ${modelfile} with slim_single"
	outdir="./times_single/"
else
	echo -n "Running ${replicates} replicates of ${modelfile} with slim_multi (${threadcount} threads)"
	outdir="./times_parallel_${threadcount}/"
fi

outfile="${outdir}${modelname}.txt"

#echo "Results will be sent to ${outfile}"

if ! [ -d ${outdir} ] ; then
    mkdir ${outdir}
fi


# Run the replicates
cpuregex='CPU time used: ([0-9.]+)'
wallregex='Wall time used: ([0-9.]+)'
memregex='Peak memory usage: .* ([0-9.]+)MB'

echo "cpu_secs, wall_secs, mem_MB" > ${outfile}

for ((i=1;i<=replicates;i++)) ; do
    echo -n "."
    
    if [ -z "${threadcount}" ] ; then
        output=$(./slim_single -time -mem -s ${i} -l 0 ${modelpath} 2>&1)
    else
        output=$(./slim_multi -time -mem -s ${i} -l 0 -maxthreads ${threadcount} ${modelpath} 2>&1)
    fi
    
    [[ ${output} =~ ${cpuregex} ]] && cpu=${BASH_REMATCH[1]}
    [[ ${output} =~ ${wallregex} ]] && wall=${BASH_REMATCH[1]}
    [[ ${output} =~ ${memregex} ]] && mem=${BASH_REMATCH[1]}

    #echo "${cpu} seconds, ${wall} seconds, ${mem} MB"
    echo "${cpu}, ${wall}, ${mem}" >> ${outfile}
done

echo













