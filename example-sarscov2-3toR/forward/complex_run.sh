export SIRE_DONT_PHONEHOME=1

# read the lambdas from the config file
# sed1: remove "lambda array = "
# sed2: remove commas
# sed3: remove new line character
lambdas=`cat Parameters/lambda.cfg \
	| egrep lambda \
	| sed 's/[[:space:]]*lambda[[:space:]]*array[[:space:]]*=//' \
	| sed 's/,/ /g' \
	| sed 's/\r/ /'
	` 

for hdir in `find Perturbations/* -type d -name "l*_l*"`
do
	echo "Complex hybird dir $hdir"
	# remove the Perturbations/ prefix
	hyb=${hdir#Perturbations/}

	cd Perturbations/$hyb/bound
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