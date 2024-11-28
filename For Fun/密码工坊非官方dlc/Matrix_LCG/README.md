## Matrix_LCG

+ Difficulty：Easy

## Solution

题目基于60x60方阵的LCG递推：
$$
X_{i+1} = AX_i + B \quad(mod\;p)
$$
在未知$A,B,p$的情况下，给出了三组连续的输出$X$，要求还原初始seed方阵从而得到flag，其中p为30bit。

预期解法很朴素简单，假如我们有p，那么对于连续的三组输出来说有：
$$
X_{2} = AX_1 + B \quad(mod\;p)
$$

$$
X_{3} = AX_2 + B \quad(mod\;p)
$$

和普通LCG一样作差得到：
$$
X_3-X_2 = A(X_2-X_1) \quad(mod\;p)
$$
求逆就得到$A$，再任意带入一组就有$B$了。此时问题在于我们并没有p，但是p仅有30bit，所以看上去可以爆破一下。

但是实际上手会发现由于最底层运算是60x60的矩阵的，爆破30bit会很慢，此时一个trick在于矩阵内部所有值都是模p下的，因此可以找出其中的最大值，在此基础上向后爆破素数，一般来说就可以仅仅爆破20bit以内。

exp：

```python
from Crypto.Util.number import *
from tqdm import *

dim = 60


X1 = Matrix(ZZ,X1)
X2 = Matrix(ZZ,X2)
X3 = Matrix(ZZ,X3)

max1 = 0
for i in range(dim):
    for j in range(dim):
        if(X1[i,j] > max1):
            max1 = X1[i,j]
        if(X2[i,j] > max1):
            max1 = X2[i,j]
        if(X3[i,j] > max1):
            max1 = X3[i,j]


p = max1
flag = b""
for i in trange(2^20):
    p += 1
    if(isPrime(p)):
        X1_ = X1.change_ring(Zmod(p))
        X2_ = X2.change_ring(Zmod(p))
        X3_ = X3.change_ring(Zmod(p))
        A = (X3_-X2_)*(X2_-X1_)^(-1)
        B = X2_ - A*X1_
        M = A^(-1)*(X1_ - B)
        if(M[0,0] <= 128):
            for i in M:
                for j in i:
                    flag += long_to_bytes(int(j))
            print(flag)
            break


#NSSCTF{Ju57_Ano7h3R_LCG_ch4ll3nGe}
```

