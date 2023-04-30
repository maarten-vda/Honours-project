#!/usr/people/douglas/programs/ksh.exe
USAGE=$'[-?\n@(#)$Id: run_xscore'
USAGE+=$' 070110 $\n]'
USAGE+="[-author?Douglas R. Houston <dhouston@staffmail.ed.ac.uk>]"
USAGE+="[-copyright?Copyright (c) D. R. Houston 2010.]"
USAGE+="[+NAME?run_xscore --- Rescores dockings using X-Score]" 
USAGE+="[+DESCRIPTION?Prepares input files for X-Score, runs it on all Vina or Autodockings, analyzes output, option for consensus scoring.]"
USAGE+="[+EXAMPLE?run_xscore.ksh -mc protein_H.pdb (protein must have polar hydrogens)]"
USAGE+="[p:prep?Prepare input files.]"
USAGE+="[r:run?Run X-Score.]"
USAGE+="[a:analyze?Get results from table.]"
USAGE+="[m:multi?Runs X-Score on all dockings in directory (rankAD must be run first if Autodock results as to be used as .pdbqt files are needed for their polar hydrogens).]"
USAGE+="[c:consensus?Generates consensus-ranked list (rankAD must be run first).]"
USAGE+=$'\n\n run_xscore.ksh -[p|r|a|m|c] <protein_h.pdb> [ligand.pdb]\n\n'

scriptname=$0
function errhan {
print
eval $scriptname --man
print "\n$error"
exit 1
}

if [[ ${1:0:1} != "-" ]]; then
  error="You must specify some options"
  errhan $0  
fi

while getopts "$USAGE" optchar ; do
  case $optchar in
     p) options+=(prepare_xscore) ;;
     r) options+=(run_xscore) ;;
     a) options+=(analyze_table) ;;
     m) options+=(score_multiple) ;;
     c) options+=(consensus) ;;
     *) error="Unable to recognize option ${1:-your arguments}." 
        errhan $0 ;;
  esac
done
shift $(($OPTIND - 1))

if (( $# < 1 )); then
  error="Not enough arguments"
  errhan $0  
fi

#export LD_LIBRARY_PATH=/usr/people/douglas/programs/lib/
export XTOOL_HOME=~/programs/xscore_v1.3/
export XTOOL_PARAMETER=$XTOOL_HOME/parameter
export XSCORE_PARAMETER=$XTOOL_HOME/parameter
export XTOOL_BIN=$XTOOL_HOME/bin
#set path = ($path  $XTOOL_BIN)

function prepare_xscore {

protein=$1
ligand=$2

print path is $LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=
/usr/people/douglas/programs/openbabel/bin/babel -ipdb $ligand -omol2 ${ligand%.pdb}.mol2 -p 7.4; wait
export LD_LIBRARY_PATH=~/programs/xscore_v1.3/lib/ 
/usr/people/douglas/programs/xscore_v1.3/bin/xscore -fixmol2 ${ligand%.pdb}.mol2 ${ligand%.pdb}_fixed.mol2; wait
exit
if [[ ! -s ${ligand%.pdb}_fixed.mol2 ]]; then
  print "WARNING: Fixmol2 has failed, running: \"cp ${ligand%.pdb}.mol2 ${ligand%.pdb}_fixed.mol2\""
  cp ${ligand%.pdb}.mol2 ${ligand%.pdb}_fixed.mol2
  sleep 10
fi

if [[ ! -e ${protein%.pdbqt}_fixed.pdb ]]; then
  print Preparing fixed receptor
  cut -c1-55 $protein > tmp.pdb
  /usr/people/douglas/programs/xscore_v1.3/bin/xscore -fixpdb tmp.pdb ${protein%.pdbqt}_fixed.pdb; wait
fi

print "######################################################################
#                            XTOOL/SCORE                             # 
######################################################################
###
FUNCTION	SCORE
###
### set up input and output files ------------------------------------
###
#
RECEPTOR_PDB_FILE    ./${protein%.pdbqt}_fixed.pdb
#REFERENCE_MOL2_FILE  none
#COFACTOR_MOL2_FILE  none 
LIGAND_MOL2_FILE     ./${ligand%.pdb}_fixed.mol2
#
OUTPUT_TABLE_FILE    ./xscore.table
OUTPUT_LOG_FILE      ./xscore.log
###
### how many top hits to extract from the LIGAND_MOL2_FILE?
###
NUMBER_OF_HITS       0 
HITS_DIRECTORY       ./hits.mdb 
###
### want to include atomic binding scores in the resulting Mol2 files?
###
SHOW_ATOM_BIND_SCORE	YES		[YES/NO]
###
### set up scoring functions -----------------------------------------
###
APPLY_HPSCORE         NO               [YES/NO]
        HPSCORE_CVDW  0.004 
        HPSCORE_CHB   0.054
        HPSCORE_CHP   0.009
        HPSCORE_CRT  -0.061
        HPSCORE_C0    3.441
APPLY_HMSCORE         YES               [YES/NO]
        HMSCORE_CVDW  0.004
        HMSCORE_CHB   0.101
        HMSCORE_CHM   0.387
        HMSCORE_CRT  -0.097
        HMSCORE_C0    3.567
APPLY_HSSCORE         NO               [YES/NO]
        HSSCORE_CVDW  0.004
        HSSCORE_CHB   0.073
        HSSCORE_CHS   0.004
        HSSCORE_CRT  -0.090
        HSSCORE_C0    3.328

###
" > xscore.input; wait
}


function analyze_table {
single_ligand=$1
print "$single_ligand $(awk '{print $7}' xscore.table | tail -1 | tr -d "[[:space:]]" )"
#rm xscore.table
}



function run_xscore {
/usr/people/douglas/programs/xscore_v1.3/bin/xscore  ./xscore.input; wait
}


function score_multiple {
wd=$(pwd)
rm -f ${2-${wd##*/}_xscores.txt}
if [[ -s vina.dpf ]]; then
  print "Vina dockings detected"
  for multi_ligand in $( find . -name "*_out.pdbqt" ); do
    print LIGAND IS $multi_ligand
    awk '/MODEL 1/,/ENDMDL/' $multi_ligand | grep "[AH][TE][OT][MA][ T][ M]" | cut -c1-55 > tmp.pdb; wait
    prepare_xscore $1 tmp.pdb; wait
    /usr/people/douglas/programs/xscore_v1.3/bin/xscore ./xscore.input; wait
    rm tmp_fixed.mol2; wait
    xscore_score=$(analyze_table  $multi_ligand | tee -a tmp.$$.txt | awk '{print $2}')
    sed -i "1,/REMARK VINA RESULT/ {/REMARK VINA RESULT:/a\
REMARK XSCORE RESULT:      $xscore_score
}" $multi_ligand; wait
    rm xscore.table; wait
  done
else
  print "Printing output to ${2-${wd##*/}_xscores.txt}"
  for multi_ligand in $( awk '{print $1}' rankedlist.txt ); do
    grep "[AH][TE][OT][MA][ T][ M]" ${multi_ligand}_largestC.pdbqt | cut -c1-55 > tmp.pdb
    prepare_xscore $1 tmp.pdb
    /usr/people/douglas/programs/xscore_v1.3/bin/xscore  ./xscore.input
    analyze_table  $multi_ligand | tee -a tmp.$$.txt
    rm xscore.table
  done
fi
sort -n --key=2 tmp.$$.txt > ${2-${wd##*/}_xscores.txt}; rm tmp.$$.txt
}

function consensus {
#This reads in rankedlist.txt and xscores.txt and uses a by-ranks voting scheme
#The number of elements and their names in each list must be identical - only the order counts
#The higher the X-score the better the affinity
wd=$(pwd)
print "Preparing consensus-ranked list of docked compounds ..."
xscore_ranked=($(cut -f1 -d" " ${2-${wd##*/}_xscores.txt} ))
autodock_ranked=($(cut -f1 -d" " rankedlist.txt))

typeset -A tallyx
scoreboard=
prizes=${#xscore_ranked[*]}; print "A total of $((prizes*2)) prizes to give away!!"
for xscore in ${xscore_ranked[*]}; do
  tallyx[${xscore%_l*.pdb}]=$prizes
  ((prizes--))
done

prizes=${#xscore_ranked[*]}
for ascore in ${autodock_ranked[*]}; do
  spacer=
  tallya[$ascore]=$prizes
#  print $ascore ${tallya[$ascore]} ${tallyx[$ascore]}
  ((prizes--))
  tallytotal[$ascore]=$((${tallyx[$ascore]}+${tallya[$ascore]}))
  spacer_length=$(( 8 - ${#ascore} ))
  for ((counter=0; counter < $spacer_length; counter++)); do
    spacer+=" "
  done 
  scoreboard+="${ascore}$spacer	${tallyx[$ascore]}		${tallya[$ascore]}		${tallytotal[$ascore]}\n"
done

print "Molecule	XScore_points	Autodock_points	Total_points"
print "$scoreboard" | sort -n -r --key=4 | tee consensus.txt
print printed consensus.txt
}


for arg in ${options[*]}; do
  case $arg in
    prepare_xscore) prepare_xscore $1 $2 ;;
    run_xscore) run_xscore ;;
    analyze_table) analyze_table $2 ;;
    score_multiple) score_multiple $1 ;;
    consensus) consensus $1 $2 ;;
  esac
done

