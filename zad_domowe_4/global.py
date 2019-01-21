from pathlib import Path

from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import MinMaxScaler
import numpy as np
import mahotas
import cv2
import os
import h5py

# Three Global feature descriptors
# 1. Color Histogram quantifies color of the art
# 2. Hu Moments quantifies shape of the art
# 3. Haralick Texture that quantifies texture of tha art

fixed_size = tuple((200, 200))
train_path = Path("dataset", "training_set")
bins = 8



def fd_hu_moments(image):
    """Feature descriptor: Shape"""
    image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)  # convert to greyscale
    feature = cv2.HuMoments(cv2.moments(image)).flatten()
    return feature


def fd_haralick(image):
    """Feature descriptor: Texture"""
    # convert the image to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    # compute the haralick texture feature vector
    haralick = mahotas.features.haralick(gray).mean(axis=0)
    # return the result
    return haralick


def fd_histogram(image):
    """Feature descriptor: Color"""
    # convert the image to HSV color-space
    image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    # compute the color histogram
    hist  = cv2.calcHist([image], [0, 1, 2], None, [bins, bins, bins], [0, 256, 0, 256, 0, 256])
    # normalize the histogram
    cv2.normalize(hist, hist)
    # return the histogram
    return hist.flatten()


def image_global_features(path_to_image, label):
    image = cv2.imread(str(path_to_image))
    try:
        image = cv2.resize(image, fixed_size)
    except Exception:
        print("Error: ", path_to_image)
        return
    # Global feature extraction
    ft_histogram = fd_histogram(image)
    ft_shape = fd_hu_moments(image)
    ft_texture = fd_haralick(image)

    # Concatenate global features
    global_feature = np.hstack([ft_histogram, ft_texture, ft_shape])

    # update list of labels and features vectors
    labels.append(label)
    global_features.append(global_feature)


def extract_global(labels_list):
    for category in labels_list:

        cat_dir = train_path / category
        current_label = category
        images_paths = [i for i in cat_dir.iterdir() if i.is_file()]

        # loop over images in category
        for image_path in images_paths:
            image_global_features(image_path, current_label)
        print("[STATUS] processed folder: {}".format(current_label))
    print("[STATUS] completed Global Feature Extraction...")


def validate_and_saving_features():
    # get the overall feature vector size
    print("[STATUS] feature vector size {}".format(np.array(global_features).shape))

    # get the overall training label size
    print("[STATUS] training Labels {}".format(np.array(labels).shape))

    # encode the target labels
    targetNames = np.unique(labels)
    le = LabelEncoder()
    target = le.fit_transform(labels)
    print("[STATUS] training labels encoded...")

    # normalize the feature vector in the range (0-1)
    scaler = MinMaxScaler(feature_range=(0, 1))
    rescaled_features = scaler.fit_transform(global_features)
    print("[STATUS] feature vector normalized...")

    print("[STATUS] target labels: {}".format(target))
    print("[STATUS] target labels shape: {}".format(target.shape))

    # save the feature vector using HDF5
    h5f_data = h5py.File('output/data.h5', 'w')
    h5f_data.create_dataset('dataset_1', data=np.array(rescaled_features))

    h5f_label = h5py.File('output/labels.h5', 'w')
    h5f_label.create_dataset('dataset_1', data=np.array(targetNames))

    h5f_data.close()
    h5f_label.close()

    print("[STATUS] end of training..")


if __name__ == "__main__":
    # get categories from folder structure
    train_labels = os.listdir(train_path)
    train_labels.sort()

    global_features = []
    labels = []

    extract_global(train_labels)
    validate_and_saving_features()











