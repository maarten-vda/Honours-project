#!/usr/people/douglas/programs/ksh.exe
source /usr/people/douglas/programs/mgltools_x86_64Linux2_1.5.6/bin/mglenv.sh > /dev/null 2>&1 
#Tell GWOVina where the Boost libraries are
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/people/douglas/programs/boost_1_59_0/lib/


USAGE=$'[-?\n@(#)$Id: autoAD'
USAGE+=$' 1.2.0 $\n]'
USAGE+="[-author?Douglas R. Houston <dhouston@staffmail.ed.ac.uk>]"
USAGE+="[-copyright?Copyright (c) D. R. Houston 2009.]"
USAGE+="[+NAME?autoAD --- Autodock automator]" 
USAGE+="[+DESCRIPTION?Prepares an SD file of compounds and "
USAGE+="a protein receptor for a Vina or Autodock run, can run either "
USAGE+="if option is specified.]"
USAGE+="[+EXAMPLE?autoAD.ksh -cqpgmds sdffile.sdf receptor.pdb sitepoints.mol2]"
USAGE+="[c:convert?Uses Babel to convert specified sdf file to individual mol2s.]"
USAGE+="[q:pdbqt?Uses AutodockTools to convert specified mol2 file to pdbqt.]"
USAGE+="[a:autodock?Run Autodock using specified dpf file.]"
USAGE+="[l:listdock?Run Autodock using specified docking list file.]"
USAGE+="[y:dyndock?Run Autodock using dynamically generated list (Dynamic mode).]"
USAGE+="[d:makedpfs?Make Autodock docking parameter files for every compound.]"
USAGE+="[j:vinadpf?Make Vina docking parameter file.]"
USAGE+="[l:prepose?Do not randomise starting pose.]"
USAGE+="[p:preprecep?Hydrogenate receptor using pdb2pqr, add charges and merge nonpolar hydrogens.]"
USAGE+="[g:makegpf?Make Autodock grid parameter file for receptor.]"
USAGE+="[m:makemaps?Calculate Autodock grids.]"
USAGE+="[x:maxparams?Set parameters to maximum (default is HTS settings).]"
USAGE+="[s:autodist?Run autodist in dynamic mode with Autodock.]"
USAGE+="[v:vinadist?Run GWOVina using dynamically generated list (Dynamic mode).]"
USAGE+="[h:listvina?Run GWOVina using specified docking list file.]"
USAGE+="[z:dynvina?Run autodist in dynamic mode with GWOVina.]"
USAGE+="[n:vina?Run GWOVina as a one-off using specified ligand, receptor and binding site definition.]"
USAGE+="[e:evryting?Activate all preparatory options, run Autodock in Dynamic mode.]"
USAGE+="[b:vevryting?Activate all preparatory options, run Vina in Dynamic mode.]"
USAGE+="[h:prepDOCK6?Set up all DOCK input files, calculate energy grids.]"
USAGE+="[k:distDOCK6?Distribute DOCK jobs to node files.]"
USAGE+="[f:dynDOCK6?Run autodist in dynamic mode with DOCK 6.3.]"
USAGE+="[t:verbose?Activate verbose mode (for bug fixing).]"
USAGE+=$'\n\n <compoundlist.sdf> <receptor.pdb> <gridcentre.pdb>\n\n'

scriptname=$0
function errhan {
print
eval $scriptname --man
print "\n$error"
exit 1
}


if (( $# < 1 )) || [[ ${1:0:1} != "-" ]]; then 
  error="You must specify some arguments and option flags."
  errhan $0  
fi

while getopts "$USAGE" optchar ; do
  case $optchar in
     h) listvina=listvina ;;
     l) pose=1 ;;
     c) sdf2pdbs=sdf2pdbs ;;
     q) pdbs2pdbqts=pdbs2pdbqts ;;
     d) makedpfs=makedpfs ;;
     p) preprecep=preprecep ;;
     g) makegpf=makegpf ;;
     m) makemaps=makemaps ;;
     x) max_params="--exhaustiveness=32" ;;
     a) autodock=autodock ;;
     l) autodock=listdock ;;
     y) autodock=dyndock ;;
     f) autodock=dynDOCK6 ;;
     s) autodock=distdock ;;
     v) vina=vina ;;
     z) dynvina=dynvina ;;
     n) vina_oneoff=vina_oneoff ;;
     j) vinadpf=vinadpf ;;
     e) sdf2pdbs=sdf2pdbs 
        pdbs2pdbqts=pdbs2pdbqts
        makedpfs=makedpfs
        preprecep=preprecep 
        makegpf=makegpf
        makemaps=makemaps 
        autodock=distdock ;;
     b) if (( $# < 3 )); then
          error="Not enough arguments"
          errhan
        fi
        sdf2pdbs=sdf2pdbs 
        pdbs2pdbqts=pdbs2pdbqts
        preprecep=preprecep 
        makegpf=makegpf
        makemaps=makemaps
        vinadpf=vinadpf
        vina=vina ;;
     k) if (( $# < 2 )); then
          error="Not enough arguments"
          errhan
        fi
        mode_selection=f
        autodist=autodist ;;
     h) if (( $# < 2 )); then
          error="Not enough arguments"
          errhan
        fi
        prepDOCK6=prepDOCK6 ;;
     f) if (( $# < 2 )); then
          error="Not enough arguments"
          errhan
        fi
        mode_selection=f
        autodock=dynDOCK6 ;;
     t) verbose=1 
        print "Verbose mode activated" ;;
     *) error="Unable to recognize option ${1:-your arguments}." 
        errhan $0 ;;
  esac
done

shift $(($OPTIND - 1))

for arg in $*; do
  if [[ ! -e $arg || ! -f $arg ]]; then
    error="Cannot find file $arg"
    errhan
  fi
  ((c++))
  arglist+=($arg)
done

spacing=0.2

ligid=${arglist[0]%.*}
sortkey=$(print ${ligid} | wc -c )

if [[ $(uname -s) != Linux ]]; then
  error="Only works on Linux, sorry."
  errhan $0 
fi



function sdf2pdbs {
#Use babel to convert sdf into multiple pdbs, strips H out first (to remove mispositioned H) then re-adds it
if [[ ${arglist[0]##*.} != sdf && ${arglist[0]##*.} != pdb ]] && [[ ${arglist[0]##*.} != mol2 ]]; then
  error="Please specify a list of compounds in SD file format. "
  errhan
fi
print Checking ${arglist[0]##*.} file for errors ...
dot=$(head -1 ${arglist[0]} | cut -f1 -d" ")
sed -i "s/^$dot/${dot#.}/" ${arglist[0]} 
sed -i "s/0999 V2000/0   1 V2000/" ${arglist[0]} 
if [[ -z $(head -10000 ${arglist[0]} | grep "M  END") ]]; then
  print "Adding \"M  END\" to SD file ..."
  sed -i '/>  <PARTIALQ_INFO>/i\
M  END' ${arglist[0]}
fi
print ${arglist[0]%.sdf} > ligid.txt
print Removing any hydrogen atoms from ${arglist[0]##*.} file ...
print "obabel -i${arglist[0]##*.} ${arglist[0]} -o${arglist[0]##*.} -O${ligid}_noH_tmp.${arglist[0]##*.}.$$ -d"; sleep 3
obabel -i${arglist[0]##*.} ${arglist[0]} -o${arglist[0]##*.} -O${ligid}_noH_tmp.${arglist[0]##*.}.$$ -d
print Adding hydrogen atoms to compounds, and converting SDF to separate mol2 files ...
print "obabel -i${arglist[0]##*.} ${ligid}_noH_tmp.${arglist[0]##*.}.$$ -omol2 -O${ligid}.mol2 -p 7.4 -m"; sleep 3
obabel -i${arglist[0]##*.} ${ligid}_noH_tmp.${arglist[0]##*.}.$$ -omol2 -O${ligid}.mol2 -p 7.4 -m
#print Converting ${ligid}_OBH.sdf to individual mol2 files ...
#/usr/people/douglas/programs/openbabel/bin/babel -isdf ${ligid}_OBH.sdf -omol2 ${ligid}.mol2 -m
#print Adding hydrogens to mol2 files
#/usr/people/douglas/programs/openbabel/bin/babel -h -imol2 tmp$$*.mol2 -omol2 -m ${ligid}.mol2
#for file in $(ls ${ligid}tmp$$*.mol2); do
#  mv $file ${file/tmp$$}
#done
#rm *tmp*$$*
}


function pdbs2pdbqts {
#Use Autodock script to convert mol2s into pdbqts
for file in $( ls -1 ${ligid}[[:digit:]]*.mol2 | sort -n --key=1.$sortkey); do
  print "Converting $file to pdbqt format ..."
  print "Running /usr/people/douglas/programs/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py -F -l $file  "
  /usr/people/douglas/programs/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py -F -l $file  > /dev/null 2>&1; wait
  if [[ ! -e ${file%.mol2}.pdbqt ]]; then
    print prepare_ligand4.py failed on $file, attempting to use PDB format instead ...
    babel -imol2 $file -opdb ${file%.mol2}.pdb > /dev/null 2>&1 
    /usr/people/douglas/programs/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py -F -l ${file%.mol2}.pdb > /dev/null
  fi
done
print "Atom types in ligand files:"
cut -c78-79 ${ligid}*.pdbqt | sort -u
#for atomtype in $(cut -c78-79 ${ligid}*.pdbqt | sort -u); do
#  print "map ${arglist[1]%.*}_H.${atomtype}.map #atom-specific affinity map"
#done 
#print
}


function preprecep {
if [[ ${#arglist[*]} > 1 ]] && [[ ${arglist[1]##*.} == pdb ]]; then
  argno=1
elif [[ ${arglist[0]##*.} == pdb ]]; then
  argno=0
else
  error="Are you sure your arguments are in the right order?"
  errhan
fi
print "Preparing receptor ... "
/usr/people/douglas/programs/mgltools_x86_64Linux2_1.5.6/bin/pythonsh /usr/people/douglas/programs/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py -U nphs_lps -r ${arglist[${argno}]%.*}.pdb
grep -v '^ATOM.*  H   .*0.000 HD$'  ${arglist[${argno}]%.*}.pdbqt  > tmp.pdbqt.$$; mv tmp.pdbqt.$$ ${arglist[${argno}]%.*}_H.pdbqt
}


function boxsize {
if [[ ${1##*.} == mol2 ]]; then
  xcoords=($(awk '/^@<TRIPOS>ATOM/,/@<TRIPOS>BOND/' $1 | cut -c17-26 | sort -g))
  ycoords=($(awk '/^@<TRIPOS>ATOM/,/@<TRIPOS>BOND/' $1 | cut -c27-36 | sort -g))
  zcoords=($(awk '/^@<TRIPOS>ATOM/,/@<TRIPOS>BOND/' $1 | cut -c37-46 | sort -g))
# print number of variables is ${#xcoords[*]} and last variable is ${xcoords[$((${#xcoords[*]}-1))]}
  pad=8
else
  xcoords=($(grep  "^[AH][TE][OT][MA][ T][ M]" $1 | cut -c31-38 | sort -g))
  ycoords=($(grep  "^[AH][TE][OT][MA][ T][ M]" $1 | cut -c39-46 | sort -g))
  zcoords=($(grep  "^[AH][TE][OT][MA][ T][ M]" $1 | cut -c47-54 | sort -g))
# print number of variables is ${#xcoords[*]} and last variable is ${xcoords[$((${#xcoords[*]}-1))]}
  pad=12
fi

((centrex=(${xcoords[0]}+${xcoords[$((${#xcoords[*]}-1))]})/2))
((maxx=${xcoords[$((${#xcoords[*]}-1))]}-(${xcoords[0]})))

((centrey=(${ycoords[0]}+${ycoords[$((${#ycoords[*]}-1))]})/2))
((maxy=${ycoords[$((${#ycoords[*]}-1))]}-(${ycoords[0]})))

((centrez=(${zcoords[0]}+${zcoords[$((${#zcoords[*]}-1))]})/2))
((maxz=${zcoords[$((${#zcoords[*]}-1))]}-(${zcoords[0]})))

#print Centre of the molecule is $centrex $centrey $centrez

typeset -i halfnpntsx
((halfnpntsx=((maxx+pad)/$2)/2))
((npntsx=halfnpntsx*2))

typeset -i halfnpntsy
((halfnpntsy=((maxy+pad)/$2)/2))
((npntsy=halfnpntsy*2))

typeset -i halfnpntsz
((halfnpntsz=((maxz+pad)/$2)/2))
((npntsz=halfnpntsz*2))

((space=($npntsx*$2)*($npntsy*$2)*($npntsz*$2) ))
if (( space > 47000 )); then
  print "WARNING: The search space volume is $space; > 47,000 Angstrom^3!" 1>&2
  sleep 5
else
  print "All is well; the search space volume is $space; <= 47,000 Angstrom^3" 1>&2
fi


print "npts $npntsx $npntsy $npntsz"
printf "gridcenter %3.3f %3.3f %3.3f\n" $centrex $centrey $centrez

print "HEADER    CORNERS OF BOX
REMARK    CENTER (X Y Z)  $centrex $centrey $centrez
REMARK    DIMENSIONS (X Y Z)   $(($npntsx*$2)) $(($npntsy*$2)) $(($npntsz*$2)) " > ${1%.*}_box.pdb

corners+=( $(($centrex-($halfnpntsx*$2))) $(($centrey-($halfnpntsy*$2))) $(($centrez-($halfnpntsz*$2))) )
corners+=( $(($centrex+($halfnpntsx*$2))) $(($centrey-($halfnpntsy*$2))) $(($centrez-($halfnpntsz*$2))) )
corners+=( $(($centrex+($halfnpntsx*$2))) $(($centrey-($halfnpntsy*$2))) $(($centrez+($halfnpntsz*$2))) )
corners+=( $(($centrex-($halfnpntsx*$2))) $(($centrey-($halfnpntsy*$2))) $(($centrez+($halfnpntsz*$2))) )
corners+=( $(($centrex-($halfnpntsx*$2))) $(($centrey+($halfnpntsy*$2))) $(($centrez-($halfnpntsz*$2))) )
corners+=( $(($centrex+($halfnpntsx*$2))) $(($centrey+($halfnpntsy*$2))) $(($centrez-($halfnpntsz*$2))) )
corners+=( $(($centrex+($halfnpntsx*$2))) $(($centrey+($halfnpntsy*$2))) $(($centrez+($halfnpntsz*$2))) )
corners+=( $(($centrex-($halfnpntsx*$2))) $(($centrey+($halfnpntsy*$2))) $(($centrez+($halfnpntsz*$2))) )

p=0
for ((n=0; n < $((${#corners[*]}/3)); n++)); do
  printf "ATOM      $((n+1))  CO$n BOX   1      " >> ${1%.*}_box.pdb
  for ((c=0; c < 3; c++)); do
    print -f  "%8.3f" -- "${corners[$p]}" >> ${1%.*}_box.pdb
    ((p++))
  done
  print >> ${1%.*}_box.pdb
done
print "CONECT    1    2    4    5
CONECT    2    1    3    6
CONECT    3    2    4    7
CONECT    4    1    3    8
CONECT    5    1    6    8
CONECT    6    2    5    7
CONECT    7    3    6    8
CONECT    8    4    5    7" >> ${1%.*}_box.pdb
}



function makegpf {

if [[ ${#arglist[*]} > 2 ]] && [[ ${arglist[1]##*.} == pdb ]]; then
  print "More than 2 args detected, second is protein"
  argno=1
  if [[ -e ${arglist[0]%.*}1.pdbqt ]]; then
    ligand=${arglist[0]%.*}1.pdbqt
  else
    ligand=${arglist[0]%.*}.pdbqt
  fi
  input_receptor=${arglist[${argno}]%.*}_H.pdbqt

elif [[ ${#arglist[*]} > 2 ]] && [[ ${arglist[1]##*.} == pdbqt ]] &&  [[ ${arglist[0]##*.} == pdbqt ]]; then
  ligand=${arglist[0]%.*}.pdbqt
  input_receptor=${arglist[1]%.*}.pdbqt
  argno=1
  print "More than 2 args detected, second is protein"
elif [[ ${arglist[0]##*.} == pdb ]]; then
  print "2 args detected, first is protein.pdb"
  if [[ ${arglist[1]##*.} != pdb ]]; then
    print "and second is ligand; running OpenBabel to convert ligand to pdb"
     babel -i${arglist[1]##*.} ${arglist[1]} -opdb ${arglist[1]%.*}.pdb
  fi
  argno=0
  ligand=${arglist[1]%.*}.pdb
  input_receptor=${arglist[${argno}]%.*}_H.pdbqt
elif [[ ${arglist[0]##*.} == pdbqt ]]; then
  print "2 args detected, first is protein.pdbqt"
  argno=0
  input_receptor=${arglist[${argno}]}
elif [[ ${arglist[1]##*.} == pdbqt ]]; then
  print "2 args detected, second is protein.pdbqt"
  argno=1
  input_receptor=${arglist[1]}
  if [[ -e ${arglist[0]%.*}1.pdbqt ]]; then
    ligand=${arglist[0]%.*}1.pdbqt
    print "and first is $ligand"
  else
    ligand=${arglist[0]%.*}.pdbqt
    print "and first is $ligand"
  fi
else
  error="Are you sure your arguments are in the right order? USAGE: autoAD.ksh -g ligand.pdbqt protein_H.pdbqt pocket.[mol2/pdb]"
  errhan
fi
rm -f *~
print "Making grid parameter file for ${arglist[${argno}]%.*}"
print "parameter_file /usr/people/douglas/programs/autodock/AD4.1_bound.dat
$(boxsize ${arglist[$((argno+1))]} $spacing)
spacing $spacing" > gpftemplate_tmp 
print "Box written to ${arglist[$((argno+1))]%.*}_box.pdb"
print "prepare_gpf4.py -l $ligand -r $input_receptor -i gpftemplate_tmp -d ./ "
/usr/people/douglas/programs/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_gpf4.py -l $ligand -r $input_receptor -i gpftemplate_tmp -d ./ 
sed -i "s/npts.*/$(grep npts gpftemplate_tmp)                        # num.grid points in xyz/" ${arglist[${argno}]%%?(_H).*}_H.gpf
atomtypes=$(grep "^map .*\.map" ${arglist[${argno}]%%?(_H).*}_H.gpf | wc | awk '{print $1}')
if (( atomtypes > 14 )); then
  print "Too many atom types, splitting gpf files ..."
  cp ${arglist[${argno}]%%?(_H).*}_H.gpf ${arglist[${argno}]%%?(_H).*}_H2.gpf
  maps=($(grep "^map .*\.map" ${arglist[${argno}]%%?(_H).*}_H.gpf | awk '{print $2}'))
  for ((n=0; n < $((atomtypes-14)); n++)); do
    sed -i "/.*${maps[$n]}.*/d" ${arglist[${argno}]%%?(_H).*}_H.gpf
    deltype=${maps[$n]%.map}; deltype=${deltype#*.}
    deltypes+="$deltype "
  done
  for deltype in $deltypes; do
    sed -i "s/\(^ligand_types \)$deltype \(.*\)/\1\2/" ${arglist[${argno}]%%?(_H).*}_H.gpf 
  done
  for ((n=$n; n < $atomtypes; n++)); do
    sed -i "/${maps[$n]}/d" ${arglist[${argno}]%%?(_H).*}_H2.gpf
  done
  sed -i  "s/^ligand_types.*/ligand_types $deltypes # ligand atom types/" ${arglist[${argno}]%%?(_H).*}_H2.gpf
fi
#rm -f gpftemplate_tmp
}


function makemaps {
if [[ ${#arglist[*]} > 1 ]] && [[ ${arglist[1]##*.} == pdb?(qt) ]]; then
  argno=1
elif [[ ${arglist[0]##*.} == pdb ]]; then
  argno=0
else
  error="Are you sure your arguments are in the right order?"
  errhan
fi
print "Calculating grids, logfile: ${arglist[${argno}]%.*}_H.glg"
if [[ -e ${arglist[${argno}]%%?(_H).*}_H2.gpf ]]; then
  print "Split grid parameter files detected, running Autogrid twice ..."
  /usr/people/douglas/programs/autodock/autogrid4 -p ${arglist[${argno}]%%?(_H).*}_H2.gpf | tee ${arglist[${argno}]%%?(_H).*}_H2.glg
fi
/usr/people/douglas/programs/autodock/autogrid4 -p ${arglist[${argno}]%%?(_H).*}_H.gpf | tee ${arglist[${argno}]%%?(_H).*}_H.glg
}


function vinadpf {
print "Making Vina parameter file vina.dpf"
if (( ${#arglist[*]} < 2 )); then
  error="Requires 2 arguments: receptor_withHs.pdbqt, binding_site_definition.[mol2|pdb]."
  errhan $0
else
  boxsize ${arglist[${#arglist[*]}-1]} $spacing > vina.dpf
  print "Box written to ${arglist[${#arglist[*]}-1]%.*}_box.pdb"
  print ${arglist[${#arglist[*]}-2]/%.pdb/_H.pdbqt} >> vina.dpf
fi
print $ligid >> vina.dpf
print ${arglist[${#arglist[*]}-1]} >> vina.dpf
print -- "$max_params" >> vina.dpf
}

function vina {
if [[ ! -e vina.dpf ]]; then
  error="Vina.dpf not found; please run autoAD.ksh -j to generate it."
  errhan $0
fi
centers=($(grep gridcenter vina.dpf))
npts=($(grep npts vina.dpf))
receptor=$(grep .pdbqt vina.dpf)
max_params=$(grep exhaustiveness vina.dpf)
print $receptor
for file in $(< ${arglist[0]}); do
  print $file
  if ! grep -q -s "Writing output ... done." ${file%.dpf}_out.dlg; then
    print Running GWOVina ...

    /usr/people/douglas/programs/gwovina-1.0/build/linux/release/gwovina --receptor $receptor --ligand $file --center_x ${centers[1]} --center_y ${centers[2]} --center_z ${centers[3]} --size_x $(((${npts[1]}+1)*$spacing)) --size_y $(((${npts[2]}+1)*$spacing)) --size_z $(((${npts[3]}+1)*$spacing)) $max_params | tee -a ${arglist[0]%.pdbqt}_out.dlg
#    print run_xscore ${receptor} ${arglist[0]%.pdbqt}_out.pdbqt
#    run_xscore ${receptor} ${arglist[0]%.pdbqt}_out.pdbqt
  else
    print "${file%.dpf}.dlg already complete!"
  fi
done
}

$sdf2pdbs 
$pdbs2pdbqts 
$preprecep
$makegpf
$makemaps
$vinadpf
$vina
