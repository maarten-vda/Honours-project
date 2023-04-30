#!/usr/people/douglas/programs/ksh.exe
function errhan {
  print "Runs NNScore2 on ALL the Autodock or Vina docked poses in the directory"
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
    nnscore=$(python ~douglas/programs/NNScore2.0/NNScore2.01.py -receptor $1 -ligand topVinamodel.pdbqt -vina_executable ~douglas/programs/autodock_vina_1_1_2_linux_x86/bin/vina | awk '/AVERAGE SCORE OF ALL 20 NETWORKS/,/SUMMARY/' | head -4 | tail -1 | awk '{print $10" "$11}')

  else
    print ligand is ${file}$search
    grep -v "^TER" ${file}$search > topADmodel.pdbqt
    nnscore=$(python ~douglas/programs/NNScore2.0/NNScore2.01.py -receptor $1 -ligand topADmodel.pdbqt -vina_executable ~douglas/programs/autodock_vina_1_1_2_linux_x86/bin/vina | awk '/AVERAGE SCORE OF ALL 20 NETWORKS/,/SUMMARY/' | head -4 | tail -1 | awk '{print $10" "$11}')
  fi

  unit=${nnscore#* }
  case $unit in
    M)  typeset -i score=$(( ${nnscore% *} * 1000000 ));;
    mM) typeset -i score=$(( ${nnscore% *} * 1000 ));;
    uM) typeset -F1 score=${nnscore% *} ;;
    nM) typeset -F3 score=$(( ${nnscore% *} / 1000 ));;
    pM) typeset -F5 score=$(( ${nnscore% *} / 1000000 ));;
    fM) typeset -F8 score=$(( ${nnscore% *} / 1000000000 ));;
  esac

  colwidth=7
  spaces=$(( colwidth - ${#score}  ))
  space=" "
  for ((c=0; c < $spaces; c++)); do
    space+=" "
  done
  print space is ."$space".
  if [[ -z $nnscore ]]; then
    unset nnscore score
  fi
  print -- "${file%$search} nnscore2: ${nnscore-nan}  ${score-nan}"
  sed -i "s/\(${file%$search} .*\)/\1$space${score-nan}/" rankedlist.txt 

done


