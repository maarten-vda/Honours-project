# Importing necessary libraries
import os
import sys

# Get the file path argument from the command line
file_path = sys.argv[1]

# Open the PDB file and read its content
with open(file_path, "r") as pdb_file:
    pdb_content = pdb_file.readlines()

# Initialize the protein and ligand content
protein_content = ""
ligand_content = ""

# Initialize the residue identifier and chain ID of the ligand
ligand_residue = ""
ligand_chain = ""

# Iterate through each line in the PDB file
for line in pdb_content:
    # Check if the line starts with "ATOM"
    if line.startswith("ATOM"):
        # Get the chain identifier and residue number of the current line
        chain_id = line[21]
        residue_num = line[22:26].strip()

        # If the residue identifier is different from the previous line,
        # it belongs to a different molecule
        if residue_num != ligand_residue or chain_id != ligand_chain:
            # If the residue identifier matches the HET record for the ligand,
            # it belongs to the ligand
            if "HET    " in line:
                ligand_residue = line.split()[2]
                ligand_chain = line.split()[3]
            elif ligand_residue and ligand_chain:
                ligand_content += line
            # Otherwise, it belongs to the protein
            else:
                protein_content += line
        else:
            # If the residue identifier is the same as the previous line,
            # append the line to the corresponding molecule
            ligand_content += line

# Write the protein and ligand content to separate PDB files
protein_file_path = os.path.splitext(file_path)[0] + "_protein.pdb"
with open(protein_file_path, "w") as protein_file:
    protein_file.write(protein_content)

ligand_file_path = os.path.splitext(file_path)[0] + "_ligand.pdb"
with open(ligand_file_path, "w") as ligand_file:
    ligand_file.write(ligand_content)
