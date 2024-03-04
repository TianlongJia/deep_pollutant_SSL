#!/bin/bash
#SBATCH --job-name="SL_10%"
#SBATCH --partition=gpu
#SBATCH --time=120:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gpus-per-task=1
#SBATCH --mem-per-cpu=100G
#SBATCH --account=research-ceg-wm
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=T.Jia@tudelft.nl

# Load modules:
module load miniconda3
module load cuda/11.7


# Set conda env:
unset CONDA_SHLVL
source "$(conda info --base)/etc/profile.d/conda.sh"

# Activate conda, run job, deactivate conda
previous=$(/usr/bin/nvidia-smi --query-accounted-apps='gpu_utilization,mem_utilization,max_memory_usage,time' --format='csv' | /usr/bin/tail -n '+2')

conda activate vissl_env1
srun python tools/object_detection_benchmark_1.py \
    --config-file /scratch/tjian/PythonProject/deep_pollutant_SSL/configs/config/benchmark/object_detection/COCOInstance/Pollutant_MaskRCNN/Train_10%.yaml \
     --num-gpus 1 SOLVER.MAX_ITER 575 TEST.EVAL_PERIOD 5 SOLVER.IMS_PER_BATCH 4 MODEL.BACKBONE.FREEZE_AT 2 MODEL.WEIGHTS /scratch/tjian/PythonProject/deep_pollutant_SSL/checkpoints/pretrained_model/R-50.pkl OUTPUT_DIR /scratch/tjian/PythonProject/deep_pollutant_SSL/checkpoints/train_weights/SL_F2/Train_10%/


/usr/bin/nvidia-smi --query-accounted-apps='gpu_utilization,mem_utilization,max_memory_usage,time' --format='csv' | /usr/bin/grep -v -F "$previous"

conda deactivate