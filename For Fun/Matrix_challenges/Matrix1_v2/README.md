## Matrix1_v2

+ Difficulty：Hard

## Solution

与Matrix1的区别在于，矩阵维数降低到了5，并且：
$$
B = M_1AM_2
$$
这一次M2没有求逆的操作，所以没有办法移项变成线性操作了。

而由于M1、M2都是flag编码矩阵，其中数值都在0-255，所以他们之中的数值相乘是个0-65536的量，依然是小量。所以我们的核心思路就是换元，把这个矩阵乘法中的二次项换元成0-65536的一次项去规约。

还是把矩阵乘法写开：
$$
\left(\begin{matrix}
b_{1,1}&\cdots&b_{1,n}\\
\vdots&\ddots&\vdots\\
b_{n,1}&\cdots&b_{n,n}\\
\end{matrix}\right)
=
\left(\begin{matrix}
m_{1\;1,1}&\cdots&m_{1\;1,n}\\
\vdots&\ddots&\vdots\\
m_{1\;n,1}&\cdots&m_{1\;n,n}\\
\end{matrix}\right)
\left(\begin{matrix}
a_{1,1}&\cdots&a_{1,n}\\
\vdots&\ddots&\vdots\\
a_{n,1}&\cdots&a_{n,n}\\
\end{matrix}\right)
\left(\begin{matrix}
m_{2\;1,1}&\cdots&m_{2\;1,n}\\
\vdots&\ddots&\vdots\\
m_{2\;n,1}&\cdots&m_{2\;n,n}\\
\end{matrix}\right)
$$
为了表示方便，用行向量表示M1矩阵，用列向量表示A矩阵，就有：
$$
\left(\begin{matrix}
b_{1,1}&\cdots&b_{1,n}\\
\vdots&\ddots&\vdots\\
b_{n,1}&\cdots&b_{n,n}\\
\end{matrix}\right)
=
\left(\begin{matrix}
\textbf{m}_{1\;1,}\\
\vdots\\
\textbf{m}_{1\;n,}\\
\end{matrix}\right)
(\textbf{a}_{,1} \; \cdots \textbf{a}_{,n})
\left(\begin{matrix}
m_{2\;1,1}&\cdots&m_{2\;1,n}\\
\vdots&\ddots&\vdots\\
m_{2\;n,1}&\cdots&m_{2\;n,n}\\
\end{matrix}\right)
$$
那么对于矩阵B任意位置(i,j)的量，有：
$$
b_{i,j} = \textbf{m}_{1\;i,}\sum_{k=1}^{n}(m_{2\;k,j}\textbf{a}_{,k})
$$
这就得到了我们需要的一组等式，接下来只需要把所有n^2个等式搜集起来，并把m1与m2对应乘积看成小量后做规约就可以得到所有二次项。

得到二次项之后，注意到B中同一行的所有数值其实是被相同的M1行向量和不同的M2的值加密的，所以作一下gcd就可以恢复M1的所有值，恢复M1后自然就恢复了M2。

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
n = 5
A = Matrix(Zmod(p), n, n, A)

########################################## part2 flatten
FA = []
for i in range(n):
    for j in range(n):
        FA.append(A[j,i])

FFA = []
for i in range(n^2):
    temp = [0]*n^2*i + FA + [0]*(n^4-n^2*i-n^2)
    FFA.append(temp)


########################################## part3 LLL
L = block_matrix(ZZ, [
    [1,Matrix(ZZ,FFA).T.stack(-vector(B))],
    [0,p]
]
)
L[:,-n^2:] *= p
#print(L.dimensions())
res = flatter(L)


########################################## part4 recover M1
for i in res:
    if(all(j == 0 for j in i[-n^2:]) and abs(i[-n^2-1]) == 1):
        ans = i[:-n^2-1]
        
        M1 = Matrix(Zmod(p), n, n)
        for j in range(n):
            temp = ans[:n^2]

            for k in range(n):
                mjk = gcd(ans[0+k], ans[n+k])
                for r in range(1,n-1):
                    mjk = gcd(mjk, gcd(ans[r*n+k], ans[(r+1)*n+k]))
                M1[j,k] = mjk
            
            ans = ans[n^3:]
        print(M1)
        break


########################################## part5 recover M2
B = Matrix(Zmod(p), n, n, B)
M2 = A^(-1)*M1^(-1)*B


########################################## part6 get flag
def flatten(M):
    M_flatten = []
    rows,cols = M.dimensions()
    for i in range(rows):
        for j in range(cols):
            M_flatten.append(M[i,j])
    return M_flatten

for i in flatten(M1):
    print(chr(i), end="")
print()
for i in flatten(M2):
    print(chr(i), end="")


#NSSCTF{M@k3_N0n_L1ne@r_L1ne@r!}
```

