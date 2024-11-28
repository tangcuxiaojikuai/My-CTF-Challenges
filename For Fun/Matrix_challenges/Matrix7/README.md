## Matrix7

+ Difficulty：Easy

## Solution

题目先生成了一个长度为10的矩阵列表f，其中第一个矩阵为flag编码的编码矩阵，后面9个是模p下的随机矩阵。这个列表f其实相当于一个度为10的多项式系数，也就是对于任意一个输入矩阵A，经过F会计算：
$$
F(A) = AF_1 + A^2F_2 + ... + A^{n}F_n
$$

> 注意两点：
>
> + 这个多项式度为n，没有0次项
> + 这个多项式对于系数F来说是右乘（换成左乘题目依然可以做，只是需要注意一下）

在此基础上，题目给了10组点对：
$$
(A_i,F(A_i))
$$
我们需要还原出矩阵列表f，从而找到作为一次项系数矩阵的flag编码矩阵。

这显然依然是要做插值来恢复系数，回顾一下前面的内容，我们已经做过了以下两种插值：

+ 点对为数值：$(x,y)$
+ 点对为函数：$(f(x), g(x))$

而现在我们的点对变成了矩阵。

不过方法还是没有变，依然写出插值需要的矩阵方程然后解就可以了：
$$
\left(
 \begin{matrix}
A_1&A_1^2&\cdots&A_1^{n}\\
A_2&A_2^2&\cdots&A_2^{n}\\
\vdots&\vdots&\ddots&\vdots\\
A_n&A_n^2&\cdots&A_n^{n}\\
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
C_2\\
\vdots\\
C_{n}\\
  \end{matrix}
\right)
$$
exp：

```python
from Crypto.Util.number import *

############################################################################################### data
p = 
C = 


############################################################################################### exp
n = 10
L = Matrix(Zmod(p), 0, n^2)
R = Matrix(Zmod(p), 0, n)
for i in range(n):
    Ai = Matrix(Zmod(p), n, n, C[i][0])
    Ci = Matrix(Zmod(p), n, n, C[i][1])
    temp = Ai
    R = R.stack(Ci)
    for j in range(1,n):
        temp = temp.augment(Ai^(j+1))
    L = L.stack(temp)

F = L.solve_right(R)
M = F[:n]
for i in range(n):
    for j in range(n):
        print(chr(M[i,j]), end="")


#NSSCTF{M@tRiX_L4granGe_InterP0lati0n_1Sn't_H4rD}
```



<br/>