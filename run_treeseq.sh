#!/bin/bash

# Run all treeseq_models with a given exectuable
#
# bash ./run_with_slim.sh <slim-exectuable>

usage()
{
    echo "usage: bash ./$0 <slim-exectuable>"
    exit 1
}


# Validate user input

SLIM_EXECUTABLE=$1

if [ ! -x "${SLIM_EXECUTABLE}" ] ; then
    echo "ERROR: An executable must be provided."
    usage
fi

SEED=23

outdir="./${SLIM_EXECUTABLE}_results"
mkdir -p $outdir

for modelpath in treeseq_models/*.slim
do

    modelname=$(basename $modelpath)
    # Inform the user of what we will do
	echo "Running ${modelpath} with ${SLIM_EXECUTABLE}"
    outfile="${outdir}/${modelname}.txt"
    treefile="${outdir}/${modelname}.trees"
    echo "Results will be sent to ${outfile} and the tree sequence saved to ${treefile}"

    # Run
    cpuregex='CPU time used: ([0-9.]+)'
    wallregex='Wall time used: ([0-9.]+)'
    memregex='Peak memory usage: .* ([0-9.]+)MB'

    echo "cpu_secs, wall_secs, mem_MB" > ${outfile}

    output=$(${SLIM_EXECUTABLE} -time -mem -s ${SEED} -d "OUTFILE='${treefile}'" -l 0 ${modelpath} 2>&1)
    
    [[ ${output} =~ ${cpuregex} ]] && cpu=${BASH_REMATCH[1]}
    [[ ${output} =~ ${wallregex} ]] && wall=${BASH_REMATCH[1]}
    [[ ${output} =~ ${memregex} ]] && mem=${BASH_REMATCH[1]}

    echo "${cpu}, ${wall}, ${mem}" >> ${outfile}
done

echo
