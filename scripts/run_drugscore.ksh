#!/usr/people/douglas/programs/ksh.exe

function errhan {
  print "Runs DSXcsd on ALL the Autodock or Vina docked poses in the directory"
  print "Hydrogen atoms are ignored."
  print "USAGE: run_drugscore.ksh protein.pdb sites.mol2"
  print $error 
  exit 1
}

if (( $# < 2 )); then
  errhan
elif 
  [[ ! -s rankedlist.txt ]]; then
  error="Cannot find rankedlist.txt"
  errhan
elif [[ ! -e $1 ]] || [[ ! -e $2 ]]; then
  error="Cannot find either $1 or $2"
  errhan
fi


function generate_protein_poc {
cut -c1-55 $1 > tmp.pdb; print END >> tmp.pdb
babel -d -ipdb tmp.pdb -opdb ${1%.pdb?(qt)}_noH.pdb 2>/dev/null; rm tmp.pdb
#print ${1%.pdb?(qt)}_noH.pdb $2 > calc_pocket.in
#~douglas/programs/drugscore/SCRIPTS/calc_pocket calc_pocket.in 9 y
}

function run_drugscore {

grep ^ATOM $2 | cut -c1-55 | babel -ipdb -omol2 -d  2>/dev/null | sed "s/\(@<TRIPOS>MOLECULE\)/\n\1/"> docked.mol2; wait
~douglas/programs/drugscore/SCRIPTS/drugscore PAIRSURF ${1%.pdb?(qt)}_noH.pdb docked.mol2; wait
}

function run_DSX_PDB {
#~douglas/programs/openbabel-2.3.1/build/bin/babel 
babel -ipdb ${2} -omol2 -d  2>/dev/null | sed "s/\(@<TRIPOS>MOLECULE\)/\n\1/"> docked.mol2; wait
~douglas/programs/DSX_0.89/RHEL_linux32/dsx_rhel_linux_32.lnx -P ${1%.pdb?(qt)}_noH.pdb -L docked.mol2 -D ~douglas/programs/DSX_0.89/pdb_pot_0511; wait
rm docked.mol2; wait
}

function run_DSX_CSD {
#~douglas/programs/openbabel-2.3.1/build/bin/babel 
grep ^ATOM $2 | cut -c1-55 | babel -ipdb -omol2 -d  2>/dev/null | sed "s/\(@<TRIPOS>MOLECULE\)/\n\1/"> docked.mol2; wait
~douglas/programs/DSX_0.89/RHEL_linux32/dsx_rhel_linux_32.lnx -T1 1.0 -T2 1.0 -T3 1.0 -P ${1%.pdb?(qt)}_noH.pdb -L docked.mol2 -D ~douglas/programs/DSX_0.89/csd_pot_0511; wait
print "~douglas/programs/DSX_0.89/RHEL_linux32/dsx_rhel_linux_32.lnx -T1 1.0 -T2 1.0 -T3 1.0 -P ${1%.pdb?(qt)}_noH.pdb -L docked.mol2 -D ~douglas/programs/DSX_0.89/csd_pot_0511"
rm docked.mol2; wait
}

if [[ -n $(ls *_out.pdbqt 2> /dev/null) ]]; then
  print Vina output detected.
  search=_out.pdbqt
else
  print "No Vina output detected, Autdock output assumed."; sleep 3
  search=_largestC.pdbqt
fi
rm -f drugscore_vs_DSX.txt


if [[ ! -s calc_pocket.in ]] || [[ ! -s ${1%.pdb?(qt)}_noH.pdb ]]; then 
  print Generating receptor files ...
  generate_protein_poc $1 $2
fi


for file in $(awk '{print $1}' rankedlist.txt ); do
  print ligand is $file
  if [[ $search == _out.pdbqt ]]; then
    print "ligand is ${file}$search"
    awk '/MODEL 1/,/ENDMDL/' ${file}$search | egrep "^[AH][TE][OT][MA][ T][ M]|MODEL|ENDMDL" | cut -c1-55 > topVinamodel.pdb
#    run_drugscore $1 topVinamodel.pdb; wait
    run_DSX_CSD $1 topVinamodel.pdb; wait
    DSXscoreCSD=$(grep -A2 "number.*name.*rmsd" DSX_${1%.pdb?(qt)}_noH_docked.txt | tail -1 | awk '{print $7}')
    
  else
    print "ligand is ${file}$search"
#    run_drugscore $1 ${file}$search; wait
#    drugscore=$(tail -1 PAIR_SURF_SURF_10_10_docked.cor | awk '{print $5}')
#    run_DSX_PDB $1 ${file}$search; wait
#    DSXscorePDB=$(grep -A2 "number.*name.*rmsd" DSX_${1%.pdb?(qt)}_noH_docked.txt | tail -1 | awk '{print $7}')
    run_DSX_CSD $1 ${file}$search; wait
    DSXscoreCSD=$(grep -A2 "number.*name.*rmsd" DSX_${1%.pdb?(qt)}_noH_docked.txt | tail -1 | awk '{print $7}')
  print DSXscore is $DSXscoreCSD
  print also $(grep -A2 "number.*name.*rmsd" DSX_${1%.pdb?(qt)}_noH_docked.txt  | tail -1 | awk '{print $7}')
 

  fi
  
  DSXscoreCSD=$(printf "%.0f" $DSXscoreCSD)
  colwidth=4
  spaces=$(( colwidth - ${#DSXscoreCSD}  ))
  space=" "
  for ((c=0; c < $spaces; c++)); do
    space+=" "
  done
  print space is ."$space".
  print -- ${file%$search} DSX_scoreCSD: $DSXscoreCSD 
  print sed -i "s/\(${file%$search} .*\)/\1$space$DSXscoreCSD/" rankedlist.txt 
  sed -i "s/\(${file%$search} .*\)/\1$space$DSXscoreCSD/" rankedlist.txt 
done




