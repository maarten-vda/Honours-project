#!/usr/people/douglas/programs/ksh.exe
function errhan {
  print "Runs NNScore1 on ALL the Autodock or Vina docked poses in the directory"
  print "\"If n > 0, the network output was interpreted to predict Kd < 25 μM; otherwise, it predicted Kd > 25 μM\""
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
  if [[ $search == _out.pdbqt ]]; then
    print ligand is ${file}$search
    awk '/MODEL 1/,/ENDMDL/' ${file}$search > topVinamodel.pdbqt
    nnscore1=$(python ~douglas/programs/NNScore1.0/NNScore.py -receptor $1 -ligand topVinamodel.pdbqt -networks_dir ~douglas/programs/NNScore1.0/networks/top_24_networks/ | grep Average | awk '{print $3}')

  else
    print ligand is ${file}$search
    grep -v "^TER" ${file}$search > topADmodel.pdbqt
    nnscore1=$(python ~douglas/programs/NNScore1.0/NNScore.py -receptor $1 -ligand topADmodel.pdbqt -networks_dir ~douglas/programs/NNScore1.0/networks/top_24_networks/ | grep Average | awk '{print $3}')
  fi

print -- unmodified score is $nnscore1
if (( nnscore1 > -9.999 )); then
  typeset -F4 nnscore1
else
  typeset -i nnscore1
  nnscore1=00000
fi

  print score is $nnscore1
  colwidth=7
  spaces=$(( colwidth - ${#nnscore1}  ))
  space=" "
  for ((c=0; c < $spaces; c++)); do
    space+=" "
  done
  print space is ."$space".

  if [[ -z $nnscore1 ]]; then
    unset nnscore1
  fi
  print -- ${file%$search} nnscore1: $nnscore1   
  print sed -i "s/\(${file%$search} .*\)/\1$space$nnscore1/" rankedlist.txt 
  sed -i "s/\(${file%$search} .*\)/\1$space$nnscore1/" rankedlist.txt 
  typeset -E4 nnscore1

done


