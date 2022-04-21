import shutil
import os
import sys
from pathlib import Path


l1 = sys.argv[1]
l2 = sys.argv[2]

trans = f'{l1}_{l2}' # transformation
cwd = Path(os.getcwd()) / trans
cwd.mkdir(exist_ok=True)
# L Begin, End
print('Ligands', l1, l2)

# copy the 
if not os.path.exists(cwd / 'Parameters'):
	shutil.copytree('Parameters', cwd / 'Parameters')

# copy the scripts
shutil.copy('complex_run.sh', cwd)
shutil.copy('ligand_run.sh', cwd)


# prep the dir structure "Perturbations/lx-ly/unbound"
unbound = (cwd / 'Perturbations' / trans / 'unbound')
unbound.mkdir(exist_ok=True, parents=True)

# copy ligand fep
shutil.copy( Path('2.lig_fep')   / f'{l1}_{l2}.pert', 
			 			 unbound / f'{l1}_{l2}.pert')
shutil.copy( Path('3.lig_soleq') / f'{l1}_{l2}_sol.prm7', 
			 			 unbound / f'{l1}_{l2}.prm7')
shutil.copy( Path('3.lig_soleq') / f'{l1}_{l2}_soleq.rst7', 
			 			 unbound / f'{l1}_{l2}.rst7')

# prep the dir structure "Perturbations/lx-ly/bound"
bound = (cwd / 'Perturbations' / trans / 'bound')
bound.mkdir(exist_ok=True, parents=True)

# copy complex fep
shutil.copy( Path('2.com_fep') 	 / f'prot_{l1}_{l2}.pert', 
						   bound / f'{l1}_{l2}.pert')
shutil.copy( Path('3.com_soleq') / f'prot_{l1}_{l2}_sol.prm7', 
						   bound / f'{l1}_{l2}.prm7')
shutil.copy( Path('3.com_soleq') / f'prot_{l1}_{l2}_soleq.rst7', 
						   bound / f'{l1}_{l2}.rst7')