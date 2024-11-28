## Matrix3

+ Difficulty：Middle

## Solution

题目将flag编码为模p下的n阶方阵M，并随机生成一个同样由0-255以内数值组成的n阶矩阵e，之后生成模p下的随机矩阵W、X、Y、Z，并计算：
$$
C = WXMYZ + e
$$
给出p、W、X、Y、Z、C，要求还原明文。

由于W、X、Y、Z全都知道，所以简化一下也就有：
$$
C = AMB + e
$$

$$
A = WX
$$

$$
B = YZ
$$

M和e在模p下都很小，所以看上去是个LWE。然而常见的LWE一般是这种形式：
$$
C = Ax + e
$$
相比于上面的等式来说主要有两个区别：

+ M、e都是矩阵而非向量
+ M还右乘了一个随机矩阵B

而正如Matrix1的wp中最后一点所讲，矩阵的操作都是线性的，我们完全可以将他转化成向量的操作，所以这题的主要问题就在于怎么将矩阵展平成向量。

> 做一下下述处理的话，可以转化成Matrix1的类似问题：
> $$
> A^{-1}C = MB + A^{-1}e
> $$
> 这题我们换个思路，直接硬来

我们仍然把矩阵写开，便于观察：
$$
\left(\begin{matrix}
c_{1,1}&\cdots&c_{1,n}\\
\vdots&\ddots&\vdots\\
c_{n,1}&\cdots&c_{n,n}\\
\end{matrix}\right)
=
\left(\begin{matrix}
a_{1,1}&\cdots&a_{1,n}\\
\vdots&\ddots&\vdots\\
a_{n,1}&\cdots&a_{n,n}\\
\end{matrix}\right)
\left(\begin{matrix}
m_{1,1}&\cdots&m_{1,n}\\
\vdots&\ddots&\vdots\\
m_{n,1}&\cdots&m_{n,n}\\
\end{matrix}\right)
\left(\begin{matrix}
b_{1,1}&\cdots&b_{1,n}\\
\vdots&\ddots&\vdots\\
b_{n,1}&\cdots&b_{n,n}\\
\end{matrix}\right)
+
\left(\begin{matrix}
e_{1,1}&\cdots&e_{1,n}\\
\vdots&\ddots&\vdots\\
e_{n,1}&\cdots&e_{n,n}\\
\end{matrix}\right)
$$
可以发现把C、e两部分展平成向量很容易：
$$
flatten(C) = (c_{1,1},c_{1,2},...,c_{n,n})
$$

$$
flatten(e) = (e_{1,1},e_{1,2},...,e_{n,n})
$$

因此我们主要关注的是下面这部分如何展平：
$$
\left(\begin{matrix}
a_{1,1}&\cdots&a_{1,n}\\
\vdots&\ddots&\vdots\\
a_{n,1}&\cdots&a_{n,n}\\
\end{matrix}\right)
\left(\begin{matrix}
m_{1,1}&\cdots&m_{1,n}\\
\vdots&\ddots&\vdots\\
m_{n,1}&\cdots&m_{n,n}\\
\end{matrix}\right)
\left(\begin{matrix}
b_{1,1}&\cdots&b_{1,n}\\
\vdots&\ddots&\vdots\\
b_{n,1}&\cdots&b_{n,n}\\
\end{matrix}\right)
$$
仍然是任取一个位置(i,j)来构建对应的线性等式：
$$
c_{i,j} - e_{i,j} = (AMB)_{i,j}
$$
也就是：
$$
(AMB)_{i,j} = A_{i,}M_{,1}b_{1,j} + A_{i,}M_{,2}b_{2,j} + ... + A_{i,}M_{,n}b_{n,j}
$$
如此一来我们就将M也展平成向量放进线性等式中了。可以发现这样一条线性等式其实已经包含了M的所有值，所以如果M中值够小的话（比如0、1），那么其实给C的其中一个值或许都可以规约出来。

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

############################################################################################### data
p = 
W = 
X = 
Y = 
Z = 
C = 


############################################################################################### exp
########################################## part1 to mat
n = 10
W, X, Y, Z, C = Matrix(Zmod(p),n,n,W), Matrix(Zmod(p),n,n,X), Matrix(Zmod(p),n,n,Y), Matrix(Zmod(p),n,n,Z), Matrix(Zmod(p),n,n,C)


########################################## part2 flatten
def flatten(M):
    M_flatten = []
    rows,cols = M.dimensions()
    for i in range(rows):
        for j in range(cols):
            M_flatten.append(M[i,j])
    return M_flatten

E = W*X
F = Y*Z
EF = []
for i in range(n):
    for j in range(n):
        temp = []
        for k in range(n):
            for m in range(n):
                temp.append(F[m,j]*E[i,k])
        EF.append(temp)

EF = Matrix(Zmod(p), EF)
CC = Matrix(Zmod(p), flatten(C)).T


########################################## part3 LWE
L = block_matrix(
    [
        [matrix.identity(n^2)*p, matrix.zero(n^2, n^2+1)],
        [(matrix(EF).T).stack(-vector(CC)).change_ring(ZZ), matrix.identity(n^2+1)],
    ]
)
#print(L.dimensions())
res = flatter(L)[0]
flag = ""
for i in res:
    flag += chr(abs(i))
print(flag)


#NSSCTF{fl@tt3n_4nd_LWE!}
```

