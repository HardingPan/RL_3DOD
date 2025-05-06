#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# 设置环境名称
ENV_NAME="fusion"

echo "Creating conda environment '$ENV_NAME' with Python 3.10..."
conda create -y -n $ENV_NAME python=3.10


# 激活环境
echo "Activating environment..."
eval "$(conda shell.bash hook)"
conda activate $ENV_NAME

# 安装 PyTorch 和 CUDA 工具包
echo "Installing PyTorch with CUDA 11.8..."
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 安装 spconv
echo "Installing spconv ..."
pip install spconv-cu118

# 安装其他依赖
echo "Installing other dependencies..."
pip install open3d
pip install opencv-python
pip install matplotlib
pip install numba
pip install nms

# 可选：安装常用的点云处理工具
echo "Installing additional useful packages..."
pip install scikit-learn
pip install tqdm
pip install pyyaml
pip install easydict
pip install tensorboard
pip install einops
pip install PyQt5
pip install scikit-image

echo "Environment setup complete! To activate this environment, use:"
echo "conda activate $ENV_NAME"

# 显示已安装的包和版本信息
echo "Installed packages:"
conda list

cd /home/panding/RL_3DOD/utils/Rotated_IoU/cuda_op
python setup.py install