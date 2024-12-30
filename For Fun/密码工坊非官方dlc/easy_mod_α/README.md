## easy_mod_α

+ Difficulty：Middle

## Solution

题目基于$(m,n)=(220,137)$的LWE：
$$
b = sA + e
$$
给出$A,b$，需要我们解出私钥$s$，从而解AES拿到flag。

本题error虽然只有两种选择，但是error是完全随机且未知的，这为我们实施预处理的线性变换带来了相当大的困难。

然而，二元的error有一个性质，那就是一定存在线性变换$\textbf{y} = a\textbf{x} + b\cdot(1,1)$，使得：
$$
(0,1) = a\textbf{e} + b\cdot(1,1) \quad(mod\;p)
$$

> 道理很简单，因为两个不重合的点一定能唯一确定一条直线

但是这个题目中我们并不知道$e$具体是多少，因此我们看上去没有办法确定出这样的$a,b$。然而由于找$a,b$的过程本身也是规约的过程，所以我们完全可以将两步合并在一起。

具体来说，本来使用的优化后的primal attack的格会满足：
$$
(s'_1,s'_2,...,s'_n,k_{m-n+1},k_{m-n+2},...k_m,1)
\left(\begin{matrix}
1&&&a'_{1,1}&a'_{2,1}&&a'_{m-n,1}&\\
&\cdots&&\vdots&\vdots&\ddots&&\\
&&1&a'_{1,n}&a'_{2,n}&&a'_{m-n,n}&\\

&&&p\\
&&&&p\\
&&&&&\ddots\\
&&&&&&p\\
-b_{1}&-b_{2}&-b_{3}&\cdots&\cdots&\cdots&-b_{m}&1\\
\end{matrix}\right)
=
(e_1,e_2,...,e_m,1)
$$
只需要在最下方加入一行全1向量，并在最右方附加一个单位阵，那么就会有：
$$
(as'_1,as'_2,...,as'_n,ak_{m-n+1},ak_{m-n+2},...ak_m, a, b)
\left(\begin{matrix}
1&&&a'_{1,1}&a'_{2,1}&&a'_{m-n,1}&\\
&\cdots&&\vdots&\vdots&\ddots&&\\
&&1&a'_{1,n}&a'_{2,n}&&a'_{m-n,n}&\\

&&&p\\
&&&&p\\
&&&&&\ddots\\
&&&&&&p\\
b_{1}&b_{2}&b_{3}&\cdots&\cdots&\cdots&b_{m}&1\\
1&1&1&\cdots&\cdots&\cdots&1&&1\\
\end{matrix}\right)
=
(ae_1+b,ae_2+b,...,ae_m+b,a, b)
$$
于是就可以在一次规约内找到所有的变换后的error，以及线性变换的$a,b$。而由于$a,b$可以认为是模p下的随机值，所以不要忘了配平。

最后基本等同于规约01向量，所以本题数据组数要求也很低，取150组做BKZ即可。

> 如果对primal attack的优化不太了解可以先看：[LWE | 糖醋小鸡块的blog (tangcuxiaojikuai.xyz)](https://tangcuxiaojikuai.xyz/post/758dd33a.html)

exp：

```python
from Crypto.Util.number import *
from Crypto.Cipher import AES
from hashlib import md5

A = 
b = 
p = 

m, n = 220, 137
A = Matrix(Zmod(p), m, n, A)
b = vector(Zmod(p), b)

def primal_attack2(A,b,m,n,p):
    L = block_matrix(
        [
            [(matrix(Zmod(p), A).T).echelon_form().change_ring(ZZ), 0],
            [matrix.zero(m - n, n).augment(matrix.identity(m - n) * p), 0],
            [matrix(ZZ, b).stack(vector(ZZ, [1]*nums)), 1],
        ]
    )
    Q = diagonal_matrix(ZZ, [p]*m + [1]*2)
    L = L*Q
    L = L.BKZ()
    L = L/Q
    L = Matrix(ZZ, L)
    res = vector(Zmod(p), L[2])
    e, k, t = res[:-2], res[-2], res[-1]
    return (e-vector(ZZ, [t]*nums))*inverse(k,p)

nums = 150
e2 = primal_attack2(A[:nums], b[:nums], nums, n, p)

s = A[:nums].solve_right(b[:nums]-e2[:nums])
print(AES.new(key=md5(str(s).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).decrypt(bytes.fromhex("b6f1c4afa09e0a0fef73d86755e7babb24671cf9ac204f761d37286c5c66111f4c99a56bdd1e167c89f1a849edc0")))
```

> 而实际上换个角度理解primal attack的话，题目的格还可以省去两维，变成真正的只规约出01向量，并且还能找到线性变换的$a,b$，之后有机会再说吧