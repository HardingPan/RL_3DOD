import os
import cv2

def check_image_validity(image_path):
    """
    检查图像是否有效。尝试读取图像，若返回 None，则认为图像损坏。
    """
    image = cv2.imread(image_path)
    if image is None:
        return False
    return True

def traverse_and_check_images(directory):
    """
    遍历目录中的所有文件，检查是否存在损坏的图像文件。
    """
    damaged_images = []  # 用来记录损坏的图片路径
    for root, dirs, files in os.walk(directory):
        for file in files:
            # 仅检查图片文件，可以根据你的实际需求调整文件类型
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.tiff')):
                file_path = os.path.join(root, file)
                if not check_image_validity(file_path):
                    print(f"损坏的图像: {file_path}")
                    damaged_images.append(file_path)
    
    if damaged_images:
        print(f"\n共发现 {len(damaged_images)} 张损坏的图像。")
    else:
        print("所有图像均有效。")

# 使用示例，替换为你的图像文件夹路径
image_directory = "/media/sdb2/K-Radar/kradar/1"
traverse_and_check_images(image_directory)
