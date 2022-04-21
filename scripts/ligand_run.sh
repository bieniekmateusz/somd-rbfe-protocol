export SIRE_DONT_PHONEHOME=1

# read the lambdas from the config file
lambdas=`cat Parameters/lambda.cfg \
	| egrep lambda \
	| sed 's/[[:space:]]*lambda[[:space:]]*array[[:space:]]*=//' \
	| sed 's/,/\\ /g' `

for hdir in `find Perturbations/* -type d -name "l*_l*"`
do
	echo "Complex hybird dir $hdir"
	# remove the Perturbations/ prefix
	hyb=${hdir#Perturbations/}

	cd Perturbations/$hyb/unbound
	for lam in $lambdas;
	do 
		mkdir lambda-${lam}
		cd lambda-${lam}
			somd-freenrg -t ../$hyb.prm7 \
						 -c ../$hyb.rst7 \
						 -m ../$hyb.pert \
						 -C ../../../../Parameters/lambda.cfg \
						 -l $lam ;
			echo "		=======================\ndone $hyb  lambda $lam 	\n======================="
		cd ../ ;
	done
done