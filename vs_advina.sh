#!/bin/bash

database=***          #database name, format: mol2 
database_num=***      #molecule number in database
recptor=***           #receptor file,format: pdbqt
#read?

mkdir dock_dir
cp ./$database dock_dir/
cd dock_dir/
obabel -i mol2 $database -o mol2 -O molecule.mol2 -m 

mkdir {1..$database_num}

for i in {1..$database_num}; do 
	mv ./molecule$i.mol2 ./$i;
done

for i in {1..$database_num}; do 
	cd ./$i;
	mv molecule*.mol2 ./molecule.mol2;
	cd ../;
done 

for i in {1..$database_num}; do 
	cd ./$i;
	cp ../../$recptor .;
	cd ../;
done

for i in {1..$database_num}; do 
	cd ./$i;
	/home/user/program/mgltools_x86_64Linux2_1.5.7/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py -l molecule.mol2 -o molecule.pdbqt;
	echo $i;
	cd ../;
done


screen -R name

for i in {1..$database_num}; do 
	cd ./$i;
	/home/user/program/autodock_vina_1_1_2_linux_x86/bin/vina --config ../../config.arg --ligand molecule.pdbqt --log dock.log;
	echo $i;
	cd ../;
done

cd ../
mkdir log_file
cd dock_dir/

for i in {1..$database_num}; do 
	cd ./$i;
	mv dock.log dock_$i.log;
	cp dock_$i.log ../../log_file;
	cd ../../;
done
	
cp affinity.py log_file/
cd log_file

python affinity.py

sort -k 2 -n affinity.out >> affinity_sort.out 
	



