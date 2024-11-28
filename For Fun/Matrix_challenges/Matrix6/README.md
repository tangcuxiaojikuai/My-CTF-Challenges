## Matrix6

+ Difficulty：Hard

## Solution

题目改编自：

[2024-江西省第三届天使杯网络安全技能大赛线上预选赛-wp-crypto | 糖醋小鸡块的blog (tangcuxiaojikuai.xyz)](https://tangcuxiaojikuai.xyz/post/6d3f5803.html#more)

本题相比于这个题目也就加了个小trick，前面的部分可以参考上篇文章，这里直接从插值的部分开始，我们有：
$$
\left(
 \begin{matrix}
1&f_1(x)&f_1(x)^2&\cdots&f_1(x)^{n}\\
1&f_2(x)&f_2(x)^2&\cdots&f_2(x)^{n}\\
\vdots&\vdots&\vdots&\ddots&\vdots\\
1&f_{n+1}(x)&f_{n+1}(x)^2&\cdots&f_{n+1}(x)^{n}\\
  \end{matrix}
\right)
\left(
 \begin{matrix}
g_1\\
g_2\\
\vdots\\
g_{n}\\
  \end{matrix}
\right)
=
\left(
 \begin{matrix}
c_1\\
c_2\\
\vdots\\
c_{n+1}\\
  \end{matrix}
\right)
$$
这是一个非齐次方程，由于我们知道这个矩阵方程存在解，为m和g和多项式g(x)的系数，所以其系数矩阵的秩等于增广矩阵的秩，因此有增广矩阵不满秩，所以有：
$$
L = \left(
 \begin{matrix}
1&f_1(x)&f_1(x)^2&\cdots&f_1(x)^{n}&c_1\\
1&f_2(x)&f_2(x)^2&\cdots&f_2(x)^{n}&c_2\\
\vdots&\vdots&\vdots&\ddots&\vdots&\vdots\\
1&f_{n+1}(x)&f_{n+1}(x)^2&\cdots&f_{n+1}(x)^{n}&c_{n+1}\\
  \end{matrix}
\right)
$$

$$
det(L) = 0 \quad(mod\;n)
$$

所以我们获得了一个在模n下以m为根的多项式。

而我们同时还有一个以m为根的多项式h：
$$
h(x) = x^{1337} - c \quad(mod\;n)
$$
所以两个多项式求一求gcd就好了。

问题在于L中每个f的度都很大，所以直接求L的行列式并不现实(度太大了，多项式都建不出来)。但处理方法也很熟悉，只需要在模h(x)的商环下去做就行。

exp：

```python
from Crypto.Util.number import *
from tqdm import *

def gcd(g1, g2):
    while g2:
        g1, g2 = g2, g1 % g2
    return g1.monic()

############################################################################################### data
n = 
c = 
F = 
C = 


############################################################################################### exp
nums = 10
e = 1337
PR.<x> = PolynomialRing(Zmod(n))
PRq.<a> = PR.quo(x^e-c)
L = Matrix(PRq,nums+1,nums+1)
for i in trange(nums+1):
    f = F[i]
    ci = C[i]
    temp = 0
    for j in range(nums):
        temp += f[j][0] * a^f[j][1]
    for j in range(nums):
        L[i,j] = temp^j
    L[i,-1] = ci

m = -gcd(L.det().lift(), x^e-c)[0]
print(long_to_bytes(int(m)))


#NSSCTF{L@graNge_InterP0lati0n_w1Th_QUoT1enT}
```

