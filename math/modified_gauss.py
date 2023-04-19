import numpy as np


def modified_gauss(A, b):
    A_inv = np.linalg.inv(A)
    print(A_inv)
    return np.dot(A_inv, b);

matrix = [
    [3., -1., 0.],
    [-1.,3.,-1.],
    [0.,-1.,2.],
]

b = [52., 0., 0.]

print(modified_gauss(matrix, b))