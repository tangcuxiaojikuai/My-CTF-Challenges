## Matrix8_v2

+ Difficulty：Middle

## Solution

直接规约了。

我们依然从矩阵方程出发：
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
我们把F和C的矩阵用列向量形式来表示：
$$
\left(
 \begin{matrix}
F_1\\
F_2\\
\vdots\\
F_{n}\\
  \end{matrix}
\right)
=
(\textbf{f}_1, \textbf{f}_2, ..., \textbf{f}_n)
$$

$$
C_1 = (\textbf{c}_1, \textbf{c}_2, ..., \textbf{c}_n)
$$

那么矩阵方程变成：
$$
\left(
 \begin{matrix}
A&A^2&\cdots&A^{n}\\
  \end{matrix}
\right)
(\textbf{f}_1, \textbf{f}_2, ..., \textbf{f}_n)
=
(\textbf{c}_1, \textbf{c}_2, ..., \textbf{c}_n)
$$
可以看出各个列向量之间其实是独立的，所以我们完全可以按如下方式逐个恢复列向量：
$$
\left(
 \begin{matrix}
A&A^2&\cdots&A^{n}\\
  \end{matrix}
\right)
\textbf{f}_i
=
\textbf{c}_1
$$
这样相比于全部展平的矩阵，维数从n^3降低到了n^2，规约n次即可。

exp：

```python
from Crypto.Util.number import *
from tqdm import *
from re import findall
from subprocess import check_output

def flatter(M):
    # compile https://github.com/keeganryan/flatter and put it in $PATH
    z = "[[" + "]\n[".join(" ".join(map(str, row)) for row in M) + "]]"
    ret = check_output(["flatter"], input=z.encode())
    return matrix(M.nrows(), M.ncols(), map(int, findall(b"-?\\d+", ret)))


############################################################################################### data
p = 
C = 


############################################################################################### exp
############################################## part1 construct matrix equation
n = 15
L = Matrix(Zmod(p), 0, n^2)
R = Matrix(Zmod(p), 0, n)
for i in range(1):
    Ai = Matrix(Zmod(p), n, n, C[i][0])
    Ci = Matrix(Zmod(p), n, n, C[i][1])
    temp = Ai
    R = R.stack(Ci)
    for j in range(1,n):
        temp = temp.augment(Ai^(j+1))
    L = L.stack(temp)

############################################## part2 LLL
F1 = []
for i in trange(n):
    L1 = Matrix(ZZ,L)
    R1 = R[:,i:i+1]
    M = block_matrix(ZZ,[
        [1,L1.T.stack(Matrix(R1).T)],
        [0,p]
    ])
    M[:,-n:] *= p
    res = flatter(M)[0][:n]
    F1.append(list(map(abs,res)))


############################################## part3 recover F1
for i in range(n):
    for j in range(n):
        print(chr(F1[j][i]), end="")
    

#NSSCTF{d1m3nSi0n_1s_n0T_A_pr0B13m_FOr_th1S_T@sK}
```

