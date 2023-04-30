import argparse
import pymol
from pymol import cmd


def split_protein_ligand(pdb_file):
    # load the PDB file
    cmd.load(pdb_file)

    # select the ligand atoms
    cmd.select("ligand", "not polymer and not resn HOH and not elem H")

    # create a new PDB file for the ligand atoms
    cmd.save("ligand.pdb", "ligand")

    # select the protein atoms
    cmd.select("protein", "polymer")

    # create a new PDB file for the protein atoms
    cmd.save("protein.pdb", "protein")

    # delete the loaded PDB file
    cmd.delete("all")


if __name__ == '__main__':
    # parse command line arguments
    parser = argparse.ArgumentParser(description='Split protein-ligand complex into separate PDB files')
    parser.add_argument('pdb_file', metavar='pdb_file', type=str, help='path to PDB file')
    args = parser.parse_args()

    # call split_protein_ligand function with input PDB file
    split_protein_ligand(args.pdb_file)
