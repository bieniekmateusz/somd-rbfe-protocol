## Relative binding free energy - tutorial
RBFE input files were taken from the sarscov2-3toR study case in the `fegrow` package. 

## BioSimSpace protocols and scripts used to generate the input files for free energy MBAR calculations. 

The following details the procedure for protein-ligand binding free energy calculations. 

## File Setup for Free Energy Calculations

Install BioSimSpace (https://github.com/michellab/BioSimSpace/)

### Step 1a) Parameterise the protein with **AMBER** forcefield:
  - Given the protein in pdb format, use the [parameterise.py](https://github.com/michellab/BioSimSpace/blob/devel/nodes/playground/parameterise.py) script from BioSimSpace to parameterise it with the ff14SB amber forcefield, and generating .rst7 and .prm7 files: ```parameterise.py --input PROT.pdb --forcefield ff14SB --output PROT```
  - save the generated .rst7 and .prm files in the `1.prot_param` directory

### Step 1b) Generate AMBER format forcefield for the ligands (GAFF):
  - Given a molecule in a pdb format in `0.lig_input` directory, use ```parameterise.py --input MOL.pdb --forcefield GAFF2 --output MOL```
  - Save each molecule's topology .prm and coordinates .rst7 in `1.lig_param`

### Step 1c) Combine each ligand and protein:
  - for each ligand, combine it with the protein: ```combine.py --system1 MOLX.prm7 MOLX.rst7 --system2 PROTEIN.prm7 PROTEIN.rst7 --output PROT_MOLX``` in the `1.com_param` directory
  - this will create unsolvated .prm7 and .rst7 files

### Step 2) Generate the files for the free energy calculations:
  - create the perturbation files for the free energy calculations. E.g. define the transition of Mol1 to Mol2 which creates .mapping, .mergeat0.pdb. .pert, .prm7 and .rst7 files. For the unbound alchemical leg run ```prepareFEP.py --input1 MOL1.prm7 MOL1.rst7 --input2 MOL2.prm7 MOL2.rst7 --output MOL1_MOL2``` to generate files in the `forward/2.lig_fep` directory. For the bound alchemical leg: ```prepareFEP.py --input1 PROT_MOL1.prm7 PROT_MOL1.rst7 --input2 PROT_MOL2.prm7 PROT_MOL2.rst7 --output PROT_MOL1_MOL2``` and output the files in the `2.com_fep` directory.

### Step 3a) Solvate both unbound and bound legs:
  - solvate each ligand transformation with: ```solvate.py --input MOL1_MOL2.prm7 MOL1_MOL2.rst7 --output MOL1_MOL2_sol --water tip3p --box_dim 35``` in the `3.lig_soleq`
  - solvate each complex transformation with: ```solvate.py --input PROT_MOL1_MOL2.prm7 PROT_MOL1_MOL2.rst7 --output PROT_MOL1_MOL2_sol --water tip3p --box_dim 90``` in the `3.com_soleq` directory
  - `--box_dim` is the box size used for our system in Angstroms.

### 3b) Equilibrate the solvated systems:
  - equilibrate the bound leg (prot_mol_sol.rst7): ```amberequilibration.py --input MOL1_MOL2_sol.prm7 MOL1_MOL2_sol.rst7 --output MOL1_MOL2_soleq``` in `3.lig_soleq` directory. 
  - equilibrate the unbound leg (mol_sol.rst7): ```amberequilibration.py --input MOL1_MOL2_sol.prm7 MOL1_MOL2_sol.rst7 --output MOL1_MOL2_soleq``` in `3.com_soleq` directory. 

### 4) Free Energy Calculations
Copy the directory `Parameters` and the scripts `complex_lambdarun-comb.sh` and `ligand_lambdarun-comb.sh` into the directory `forward`. The `Parameters` folder should contain the main configuration file `lambda.cfg` which the user should verify and modify accordingly.

For each transformation:
1) Create a directory named `MOL1-MOL2`. In the directory run `python ../init.py` to initialise the directory. 
2) The `lambda.cfg` file contains various parameters, namely the number of moves and cycles, the timestep, the type of constraints, the lambda windows used and the platform on which to run the calculation. 
3) Run the ```ligand_lambdarun-comb.sh``` and ```complex_lambdarun-comb.sh``` scripts. Note that the lambda lists in these scripts should correspond to the `lambda.cfg`. (Fixme)
- Script ```ligand_lambdarun-comb.sh``` runs the command for the unbound perturbations, whilst ```complex_lambdarun-comb.sh``` runs the bound perturbations. 
4) Gather the results by runing ```analyse_freenrg mbar -i lambda-*/simfile.dat -o out.dat -p 90``` in all discharge and vanish directories. Further calculate the corrections:

#### Corrections:

 - FUNC.py: Evaluates the electrostatic correction for the free energy change: FUNC_corr. This is run for lambda= 0 at the discharge leg.
 - ```lj-tailcorrection -C sim.cfg -l <lambda> -b 1.00 -r traj000000001.dcd -s 20``` Evaluates the end-point correction for the truncated vdW potentials. This is run for lambda= 0 and lambda= 1 of the vanish leg.

## Results

In addition to the above instructions for generating the input files for this paper, the `results` directory also contains the raw data (free energy calculations) which can be analysed with ```python run_networkanalysis.py sars/sarscov2-3toR.csv --target_compound 14 -o sars.dat -e sars/sarscov2_ic50_exp.csv --stats --generate_notebook```.

This protocol might require more repetition for good sampling. Repeat the steps 3-6 with MOL2_MOL1 instead of MOL1_MOL2 in order to obtain the `backward` directories.


