L1=10 && 
L2=11 &&
solvate.py --input ../2.lig_fep/l"$L1"_l"$L2".prm7 ../2.lig_fep/l"$L1"_l"$L2".rst7 \
		   --output l"$L1"_l"$L2"_sol \
		   --water tip3p --box_dim 35