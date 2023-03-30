#!/bin/bash

##############
# edit below #
##############

# Location of whole scipion installation
SCIPION_HOME=/opt/bioxray/programs/scipion3

# number cpu cores for installation of plugins
NPROC=10

CUDA=True  # True or False
CUDA_PATH=/usr/local/cuda-11.7 # PATH to CUDA installation
MPI_PATH=opt/bioxray/programs/openmpi_4.0.3 # PATH to MPI installation
OPENCV=False # True or FALSE

#############
# stop edit #
#############

# download and install conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash Miniconda3-latest-Linux-x86_64.sh -b -p ${SCIPION_HOME}

source ${SCIPION_HOME}/etc/profile.d/conda.sh

# 
conda activate

pip3 install --user scipion-installer

python3 -m scipioninstaller -conda -noXmipp -noAsk ${SCIPION_HOME}

${SCIPION_HOME}/scipion3 config --overwrite


mkdir ${SCIPION_HOME}/plugins
cd ${SCIPION_HOME}/plugins

# EM plugins to install

EM_PLUGINS="xmipp appion aretomo ccp4 chimera cistem cryodrgn cryosparc2 eman2 fsc3d gautomatch gctf localrec motioncorr relion resmap sphire susantomo tomowin topaz"

# upgrade or install EM plugins

for PACK in ${EM_PLUGINS}; do
    echo $PACK
    scipion3 uninstallp -p scipion-em-${PACK}
    scipion3 installp -p scipion-em-${PACK} -j $NPROC
done


# TOMO DEVEL PLUGINS to install 

TOMO_PLUGINS="tomo imod tomoviz dynamo novactf xmipptomo pyseg emantomo reliontomo tomosegmemtv tomo3d aretomo deepfinder cryocare tomotwin susantomo"

# upgrade or install TOMO plugins

for TOMOPACK in ${TOMO_PLUGINS}; do
    echo $TOMOPACK
    # uninstall 
    scipion3 uninstallp -p scipion-em-${TOMOPACK}
    if [ -d scipion-em-${TOMOPACK}/.git ]; then
	cd scipion-em-$TOMOPACK
	git pull
	cd ..
    else
	# only needed on first run
	git clone  https://github.com/scipion-em/scipion-em-${TOMOPACK}.git
    fi
    scipion3 installp -p scipion-em-${TOMOPACK} -j $NPROC --devel
done

cat<<EOF >> ${SCIPION_HOME}/config/scipion.conf
CUDA = ${CUDA}
CUDA_BIN = ${CUDA_PATH}/bin
CUDA_LIB = ${CUDA_PATH}/lib64
MPI_BINDIR = ${MPI_PATH}/bin
MPI_LIBDIR = ${MPI_PATH}/lib
MPI_INCLUDE = ${MPI_PATH}/include
OPENCV = ${OPENCV}
EOF



# create executeble in PATH
echo -e '#!/bin/bash\n'${SCIPION_HOME}'/scipion3 $@' > /usr/local/bin/scipion3
chmod 755 /usr/local/bin/scipion3



echo -e '############\nALL DONE!\n############'

