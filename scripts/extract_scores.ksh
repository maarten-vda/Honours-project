#!/usr/people/douglas/programs/ksh.exe

# Get the name of the directory where this script is located
dir=$(basename "$(pwd)")

# Define the protein-ligand complex name pattern
complex_pattern="${dir}_ligand1"

# Extract unmodified nnscore
nnscore=$(grep "${complex_pattern}" nnscore1.log | grep "nnscore1:" | awk '{print $NF}')

# Extract DSX score
DSXscore=$(tail -c 59 DSX_*_protein_H_noH_docked.txt | cut -c 1-8)

# Extract nnscore2
nnscore2=$(grep "${complex_pattern}" nnscore2.log | grep "nnscore2:" | awk '{print $NF}')

# Extract rfscore4
rfscore4=$(grep "${complex_pattern}" rfscore4.log | grep "rfscore:" | awk '{print $NF}')

# Extract rfscore-vs2
rfscore_vs2=$(grep "rfscore:" rfscore-vs2.log | awk '{print $NF}')

# Extract xscore1.3
xscore=$(grep "${complex_pattern}" xscore1.3.log | grep "xscore:" | awk '{print $NF}')

# Output scores to a file
echo "nnscore: ${nnscore}" > scores.txt
echo "DSX score: ${DSXscore}" >> scores.txt
echo "nnscore2: ${nnscore2}" >> scores.txt
echo "rfscore4: ${rfscore4}" >> scores.txt
echo "rfscore-vs2: ${rfscore_vs2}" >> scores.txt
echo "xscore1.3: ${xscore}" >> scores.txt

