import os

root_dir = '/media/sdb2/K-Radar/minikradar'

# 遍历 root_dir 下所有文件夹
for folder_name in os.listdir(root_dir):
    folder_path = os.path.join(root_dir, folder_name)
    
    # 确保是数字命名的文件夹
    if os.path.isdir(folder_path) and folder_name.isdigit():
        sparse_cube_dir = os.path.join(folder_path, 'sparse_cube')
        
        if os.path.exists(sparse_cube_dir):
            for fname in os.listdir(sparse_cube_dir):
                if fname.startswith('spcube_') and fname.endswith('.npy'):
                    src = os.path.join(sparse_cube_dir, fname)
                    dst = os.path.join(sparse_cube_dir, fname.replace('spcube_', 'cube_'))
                    os.rename(src, dst)
                    print(f'Renamed: {src} -> {dst}')
