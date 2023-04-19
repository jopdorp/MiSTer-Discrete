from numpy import array, zeros, diag, diagflat, dot, reciprocal
from numpy.linalg import inv

# def jacobi(A,b,N=25,x=None):
#     """Solves the equation Ax=b via the Jacobi iterative method."""
#     # Create an initial guess if needed                                                                                                                                                            
#     if x is None:
#         x = zeros(len(A[0]))

#     # Create a vector of the diagonal elements of A                                                                                                                                                
#     # and subtract them from A                                                                                                                                                                     
#     D = diag(A)
#     print(D)
#     R = A - diagflat(D)

#     # Iterate for N times                                                                                                                                                                          
#     for _ in range(N):
#         x = (b - dot(R,x)) / D
#     return x

def jacobi_matrix(A,b,N=25,x=None):
    """Solves the equation Ax=b via the Jacobi iterative method."""
    # Create an initial guess if needed                                                                                                                                                            
    if x is None:
        x = zeros(len(A[0]))

    # Create a vector of the diagonal elements of A                                                                                                                                                
    # and subtract them from A                                                                                                                                                                     
    D = diagflat(diag(A))
    R = A - D
    D_inv = inv(D)

    # Iterate for N times                                                                                                                                                                          
    for _ in range(N):
        x = dot(D_inv, (b - dot(R,x)))
    return x

# This might actually be Gauss-Seidel, because x is immediately updated
def jacobi_element_wise(A,b,N=25,x=None):
    if x is None:
        x = [20,8,4]
    D_recip = reciprocal(diag(A))
    
    for k in range(N):
        for i in range(len(b)):
            s = 0
            for j in range(len(b)):
                if i != j:
                    s = s + A[i][j] * x[j]
            x[i] = (b[i] - s) * D_recip[i]
    return x

matrix = array([
    [3.,-1., 0.],
    [-1.,3.,-1.],
    [0.,-1., 2.],
])

b = array([52.,0.,0.])

print(jacobi_matrix(matrix,b,1))
print(jacobi_element_wise(matrix,b,4))