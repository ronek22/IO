import os
import warnings
from pathlib import Path

import h5py
import matplotlib.pyplot as plt
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC

warnings.filterwarnings('ignore')


def import_features():
    h5f_data = h5py.File('output/data.h5', 'r')
    h5f_label = h5py.File('output/labels.h5', 'r')

    global_features_string = h5f_data['dataset_1']
    global_labels_string = h5f_label['dataset_1']

    gf = np.array(global_features_string)
    gl = np.array(global_labels_string)

    h5f_data.close()
    h5f_label.close()
    return gf, gl


def draw_confusion(matrix, name, classes):
    plt.figure()
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(matrix)
    ax.set_title(name)

    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45)
    plt.yticks(tick_marks, classes)

    for i in range(len(matrix)):
        for j in range(len(matrix)):
            ax.text(j, i, matrix[i, j], ha="center", va="center", color="w")
    plt.savefig('output/charts/' + name + ".png")


# number of trees for random forest classificatory
num_trees = 100
test_size = 0.10
seed = 9

models = [
    ('KNN', KNeighborsClassifier()),
    ('NB', GaussianNB()),
    ('LR', LogisticRegression()),
    ('RF', RandomForestClassifier(n_estimators=num_trees, random_state=seed)),
    ('SVM', SVC(random_state=seed))
]


# variables to hold results and names
results = {}
names = []
scoring = "accuracy"
confusion_matrices = {}

if __name__ == "__main__":
    train_path = Path("dataset", "training_set")
    train_labels = os.listdir(train_path)
    train_labels.sort()
    global_features, global_labels = import_features()

    # verify the shape of the feature vector and labels
    print("[STATUS] features shape: {}".format(global_features.shape))
    print("[STATUS] labels shape: {}".format(global_labels.shape))

    print("[STATUS] training started...")

    (trainDataGlobal, testDataGlobal, trainLabelsGlobal, testLabelsGlobal) = train_test_split(np.array(global_features),
                                                                                              np.array(global_labels),
                                                                                              test_size=test_size,
                                                                                              random_state=seed)

    print("[STATUS] splitted train and test data...")
    print("Train data  : {}".format(trainDataGlobal.shape))
    print("Test data   : {}".format(testDataGlobal.shape))
    print("Train labels: {}".format(trainLabelsGlobal.shape))
    print("Test labels : {}".format(testLabelsGlobal.shape))

    for name, model in models:
        classifier = model.fit(trainDataGlobal, trainLabelsGlobal)
        y_pred = classifier.predict(testDataGlobal)
        confusion_matrices[name] = confusion_matrix(testLabelsGlobal, y_pred)
        results[name] = classifier.score(testDataGlobal, testLabelsGlobal)
        print(name, ": ", results[name])
        draw_confusion(confusion_matrices[name], name, train_labels)

    plt.figure()
    plt.bar(*zip(*results.items()))
    plt.savefig("output/charts/summary.png")

