#!/usr/people/douglas/programs/ksh.exe
function errhan {
  print "Runs RFScore on ALL the Autodock or Vina docked poses in the directory"
  print "pdbqt files are used"
  print "USAGE: $0 protein.pdbqt"
  print $error 
  exit 1
}


if (( $# != 1 )); then
  error="Not enough arguments"
  errhan
elif 
  [[ ! -s rankedlist.txt ]]; then
  error="Cannot find rankedlist.txt"
  errhan
elif [[ ! -e $1 ]]; then
  error="Cannot find $1"
  errhan
fi


if [[ -n $(ls *_out.pdbqt 2> /dev/null) ]]; then
  print Vina output detected.
  search=_out.pdbqt
else
  print No Vina output detected, Autdock output assumed.
  search=_largestC.pdbqt
fi


for file in $(awk '{print $1}' rankedlist.txt ); do
    print ligand is ${file}$search
    awk '/MODEL 1/,/ENDMDL/' ${file}$search > topVinamodel.pdbqt
    rfscore=$(/usr/people/douglas/programs/rf-score-4/rf-score /usr/people/douglas/programs/rf-score-4/pdbbind-2014-refined.rf $1 topVinamodel.pdbqt)
    print -- ${file%$search} rfscore: $rfscore  
  sed -i "s/\(${file%$search} .*\)/\1 ${rfscore-0.00}/" rankedlist.txt 

done
