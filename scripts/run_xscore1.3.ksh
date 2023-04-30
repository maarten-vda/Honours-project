#!/usr/people/douglas/programs/ksh.exe
#Uses HMScore as that's the best in both of Wang's papers
scriptname=$0
function errhan {
  print "Runs X-Score 1.3 on ALL the Autodock or Vina docked poses in the directory"
  print "USAGE: $0 protein_H.pdbqt"
  print "Polar hydrogens on receptor, all hydrogens on ligands are required (this script uses OpenBabel to do this)"
  print $error 
  exit 1
}


if (( $# < 1 )); then
  error="Not enough arguments"
  errhan $0  
fi

export XTOOL_HOME=/usr/people/douglas/programs/xscore_v1.3/
export XTOOL_PARAMETER=$XTOOL_HOME/parameter
export XSCORE_PARAMETER=$XTOOL_HOME/parameter
export XTOOL_BIN=$XTOOL_HOME/bin
#set path = ($path  $XTOOL_BIN)


function prepare_xscore {

protein=$1
ligand=$2

babel -ipdb $ligand -omol2 ${ligand%.pdb}.mol2 -p 7.4 2>/dev/null; wait
/usr/people/douglas/programs/xscore_v1.3/bin/xscore -fixmol2 ${ligand%.pdb}.mol2 ${ligand%.pdb}_fixed.mol2; wait
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



if [[ -n $(ls *_out.pdbqt 2> /dev/null) ]]; then
  print Vina output detected.
  search=_out.pdbqt
else
  print No Vina output detected, Autdock output assumed.
  search=_largestC.pdbqt
fi


for file in $(awk '{print $1}' rankedlist.txt ); do
  if [[ $search == _out.pdbqt ]]; then
    print ligand is ${file}$search
    awk '/MODEL 1/,/ENDMDL/' ${file}$search | grep "[AH][TE][OT][MA][ T][ M]" | cut -c1-55 > tmp.pdb; wait
    prepare_xscore $1 tmp.pdb; wait
    /usr/people/douglas/programs/xscore_v1.3/bin/xscore ./xscore.input; wait
    rm tmp_fixed.mol2; wait
    xscore_score=$(analyze_table  $file | awk '{print $2}')
    rm xscore.table; wait
  else
    print ligand is ${file}$search
    grep "[AH][TE][OT][MA][ T][ M]" ${file}$search | cut -c1-55 > tmp.pdb
    prepare_xscore $1 tmp.pdb
    /usr/people/douglas/programs/xscore_v1.3/bin/xscore ./xscore.input
    xscore_score=$(analyze_table  $file | awk '{print $2}')
    rm xscore.table
fi

  print -- ${file%$search} xscore: $xscore_score  
  if (( xscore_score > 20 )); then
    print "Xscore score far too high; setting it to 0.00"
    $xscore_score = 0
  fi
  sed -i "s/\(${file%$search} .*\)/\1 $xscore_score/" rankedlist.txt 

done





