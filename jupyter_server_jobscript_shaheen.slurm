#!/bin/bash -l

#SBATCH --nodes=4
#SBATCH --partition=workq
#SBATCH --time=0:30:00


module swap PrgEnv-cray PrgEnv-gnu
module load intelpython3
module load cray-hdf5-parallel


# get tunneling info
export XDG_RUNTIME_DIR=""
node=$(hostname -s)
user=$(whoami)
gateway=${EPROXY_LOGIN}
submit_host=${SLURM_SUBMIT_HOST}
port=8889
export IPYTHONDIR=$PWD

echo $node on $gateway pinned to port $port
# print tunneling instructions jupyter-log
echo -e "
To connect to the compute node ${node} on Shaheen running your jupyter notebook server,
you need to run following two commands in a terminal

1. Command to create ssh tunnel from you workstation/laptop to cdlX:
ssh -L ${port}:localhost:${port} ${user}@${submit_host}.hpc.kaust.edu.sa

2. Command to create ssh tunnel to run on cdlX:
ssh -L ${port}:${node}:${port} ${user}@${gateway}

Copy the link provided below by jupyter-server and replace the nid0XXXX with localhost before pasting it in your browser on your workstation/laptop
"
profile="mpi_tutorial"

echo "Creating profile ${profile}"
ipython profile create ${profile}

echo "Launching controller"
ipcontroller --ip="*" --profile=${profile} --log-to-file &
sleep 10

echo "Launching engines"
srun ipengine --profile=${profile} --location=$(hostname) --log-to-file &
sleep 45
echo "Use profile=ipyparallel.Client(profile='$profile') in your Jupyter notebook to initialize the MPI cluster." 
# Run Jupyter
jupyter notebook --no-browser --port=${port} --ip=${node}

