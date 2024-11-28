## Matrix1

+ Difficulty：Middle

## Solution

题目将flag分为前后两部分，分别做随机字节填充使得其长度为100，并转化为模p下的10阶方阵M1、M2。之后生成模p下的随机矩阵A，并计算：
$$
B = M_1AM_2^{-1}
$$
给出p、A、B，要求还原flag。

很明显的，M1、M2在模p下都是小值构成的矩阵，所以目标还是规约出他们。而M2的逆显然不是小值矩阵，为此先做个移项：
$$
BM_2 = M_1A
$$
为了方便之后阐述，不妨记：
$$
C = BM_2 = M_1A
$$
把所有矩阵写开：
$$
\left(\begin{matrix}
c_{0,0}&c_{0,1}&\cdots&c_{0,9}\\
c_{1,0}&c_{1,1}&\cdots&c_{1,9}\\
\vdots&\vdots&\ddots&\vdots\\
c_{9,0}&c_{9,1}&\cdots&c_{9,9}\\
\end{matrix}\right)
=
\left(\begin{matrix}
b_{0,0}&b_{0,1}&\cdots&b_{0,9}\\
b_{1,0}&b_{1,1}&\cdots&b_{1,9}\\
\vdots&\vdots&\ddots&\vdots\\
b_{9,0}&b_{9,1}&\cdots&b_{9,9}\\
\end{matrix}\right)
\left(\begin{matrix}
m_{1\;0,0}&m_{1\;0,1}&\cdots&m_{1\;0,9}\\
m_{1\;1,0}&m_{1\;1,1}&\cdots&m_{1\;1,9}\\
\vdots&\vdots&\ddots&\vdots\\
m_{1\;9,0}&m_{1\;9,1}&\cdots&m_{1\;9,9}\\
\end{matrix}\right)
=
\left(\begin{matrix}
m_{2\;0,0}&m_{2\;0,1}&\cdots&m_{2\;0,9}\\
m_{2\;1,0}&m_{2\;1,1}&\cdots&m_{2\;1,9}\\
\vdots&\vdots&\ddots&\vdots\\
m_{2\;9,0}&m_{2\;9,1}&\cdots&m_{2\;9,9}\\
\end{matrix}\right)
\left(\begin{matrix}
a_{0,0}&a_{0,1}&\cdots&a_{0,9}\\
a_{1,0}&a_{1,1}&\cdots&a_{1,9}\\
\vdots&\vdots&\ddots&\vdots\\
a_{9,0}&a_{9,1}&\cdots&a_{9,9}\\
\end{matrix}\right)
$$
可以看出对于任意一个C[i,j]，我们都可以理出对应的一条线性等式：
$$
c_{i,j} = \textbf{b}_{i,}\textbf{m}_{1\;,j} = \textbf{m}_{2\;i,}\textbf{a}_{,j}
$$
这个时候我们再消去c得到：
$$
\textbf{b}_{i,}\textbf{m}_{1\;,j} - \textbf{m}_{2\;i,}\textbf{a}_{,j} = 0
$$
这样的等式一共有n^2个，把所有等式搜集起来，并组合成一个矩阵方程就是：
$$
L_{n^2,2n^2}X = \textbf{0}
$$
其中展平的M1、M2拼接起来的M显然是矩阵方程的解：
$$
\textbf{M} = (m_{1\;0,0},\; m_{1\;0,1} ,\; ...,\; m_{1\;9,9},\;m_{2\;0,0},\; m_{2\;0,1} ,\; ...,\; m_{2\;9,9})
$$

$$
L\textbf{M} = \textbf{0}
$$

而由于L有n^2的右核，所以直接求矩阵方程会有无穷组解。然而M显然是这些解里比较小的，所以对右核的basis进行一次规约就可以找到M了。

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
A = 
B = 

############################################################################################### exp
########################################## part1 to mat
n = 10
A, B = Matrix(Zmod(p), n, n, A), Matrix(Zmod(p), n, n, B)


########################################## part2 get solution of M1A = BM2
L = Matrix(Zmod(p), n^2, 2*n^2)
for i in range(n):
    for j in range(n):
        for t in range(n):
            L[n*i+j, n^2+n*i+t] -= A[t,j]
            L[n*i+j, j+n*t] += B[i,t]
XY = Matrix(ZZ,L.right_kernel().basis())


########################################## part3 LLL
L = Matrix(ZZ,2*n^2,2*n^2)
for i in range(n^2):
    for j in range(2*n^2):
        L[i,j] = XY[i,j]
        L[n^2+i,n^2+i] = p
#print(L.dimensions())
res = flatter(L)[0]


########################################## part4 get flag
m1 = res[n^2:n^2+16]
m2 = res[:16]
flag = ""
for i in m1:
    flag += chr(i)
for i in m2:
    flag += chr(i)
print(flag)


#NSSCTF{LLL111lll_1n_th3_k3rn3L!}
```

这个题很重要的一个思想是：不管是矩阵还是向量运算，运算操作都是线性的，因此可以随时随地把矩阵与向量做等价转换（也就是展平）来得到更清楚的线性等式，这一点在后面的题目中会反复用到。
