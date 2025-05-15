# utils/kitti_eval/nms.py

import numpy as np
from .nms_gpu import rotate_nms_gpu

def rboxes(boxes, scores, nms_threshold=0.1):
    """
    Custom rboxes NMS using rotate_nms_gpu.

    Args:
        boxes (list or np.ndarray): List of boxes, each box = [x, y, w, h, theta]
        scores (list or np.ndarray): Confidence scores for each box
        nms_threshold (float): IoU threshold for NMS

    Returns:
        list[int]: Indices of boxes kept after NMS
    """
    boxes = np.array(boxes, dtype=np.float32)
    scores = np.array(scores, dtype=np.float32).reshape(-1, 1)

    if boxes.ndim != 2 or boxes.shape[1] != 5:
        raise ValueError(f"[rboxes] Expected boxes shape (N, 5), got {boxes.shape}")
    if scores.shape[0] != boxes.shape[0]:
        raise ValueError(f"[rboxes] Number of scores ({scores.shape[0]}) does not match number of boxes ({boxes.shape[0]})")

    dets = np.hstack((boxes, scores))  # shape: (N, 6)
    keep_indices = rotate_nms_gpu(dets, nms_overlap_thresh=nms_threshold)
    return keep_indices
