## Matrix8

+ Difficulty：Middle

## Solution

和Matrix7一样，依然基于矩阵多项式，区别在于：

+ 并没有给出足够的数据进行插值，仅仅给了一组矩阵点对
+ 系数矩阵列表f全部为flag编码矩阵

系数矩阵在模p下很小，所以要用格，我们现在拥有的矩阵方程是：
$$
\left(
 \begin{matrix}
A&A^2&\cdots&A^{n}\\
  \end{matrix}
\right)
\left(
 \begin{matrix}
F_1\\
F_2\\
\vdots\\
F_{n}\\
  \end{matrix}
\right)
=
\left(
 \begin{matrix}
C_1\\

  \end{matrix}
\right)
$$
最简单的思路就是我们把这个矩阵方程展平，然后LLL即可。注意到F共有n个n阶方阵，代表着n^3个变量，因此选7已经要规约接近400维的方阵，因此才将n改为7便于展平规约。

exp：

```python
from Crypto.Util.number import *
from re import findall
from subprocess import check_output

def flatter(M):
    # compile https://github.com/keeganryan/flatter and put it in $PATH
    z = "[[" + "]\n[".join(" ".join(map(str, row)) for row in M) + "]]"
    ret = check_output(["flatter"], input=z.encode())
    return matrix(M.nrows(), M.ncols(), map(int, findall(b"-?\\d+", ret)))

def flatten(M):
    M_flatten = []
    rows,cols = M.dimensions()
    for i in range(rows):
        for j in range(cols):
            M_flatten.append(M[i,j])
    return M_flatten

############################################################################################### data
p = 
C = 


############################################################################################### exp
n = 7
t = 1
def matrix_lagrange_LLL(n, t, PT, p):   
    ##### part1 flatten Ci to R
    R = []
    for i in range(t):
        C = flatten(Matrix(Zmod(p), n, n, PT[i][1]))
        for j in C:
            R.append(j)
    R = vector(Zmod(p), R)
    
    
    ##### part2 get L
    L = Matrix(Zmod(p), t*n^2, n^3)
    for r in range(t):
        A = Matrix(Zmod(p), n, n, PT[r][0])
        for j in range(n):
            for k in range(n):

                for i in range(n):
                    Ai = A^(i+1)
                    for x in range(n):
                        L[n^2*r+n*j+k,n^2*i+n*k+x] = Ai[j,x]

    
    ##### part3 LLL
    M = block_matrix(ZZ,[
        [1,Matrix(ZZ,L).T.stack(Matrix(ZZ,R))],
        [0,p]
    ])
    M[:,-t*n^2:] *= p
    #print(M.dimensions())
    res = flatter(M)[0][:n^2]
    for i in range(n):
        for j in range(n):
            print(chr(res[n*j+i]), end="")


matrix_lagrange_LLL(n, t, C, p)


#NSSCTF{Y3t_4n0Th3r_L@graNge_InterP0lati0n_TasK}
```

> 但是这个方法显然并不好，因为我们人为的增大了格的维数，好一些的方法继续看v2

