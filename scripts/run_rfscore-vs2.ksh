#!/usr/people/douglas/programs/ksh.exe


function errhan {
  print "Runs RFScore-VS2 on ALL the Autodock or Vina docked poses in the directory"
  print "pdbqt files are used, requires rankAD to be run first to create rankedlist.txt"
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
  if [[ $search == _out.pdbqt ]]; then
    print ligand is ${file}$search
    awk '/MODEL 1/,/ENDMDL/' ${file}$search > topVinamodel.pdbqt
    rfscore=$(~douglas/programs/rf-score-vs/rf-score-vs --receptor $1 topVinamodel.pdbqt -ocsv | tail -1 | cut -f3 -d"," | dos2unix)
  else
    print ligand is ${file}$search
    rfscore=$(~douglas/programs/rf-score-vs/rf-score-vs --receptor $1 -ocsv ${file}$search | tail -1 | cut -f3 -d"," | dos2unix)
  fi
  rfscore2=$(printf "%.2f\n" $rfscore)
  print -- "file: ${file%$search} rfscore: $rfscore2"  
  sed -i "s/\(${file%$search} .*\)/\1 ${rfscore2-0.00}/" rankedlist.txt 
done
