## Matrix_LCG2

+ Difficulty：Middle

## Solution

与上一题区别在于：

+ 60x60$\rightarrow$10x10
+ $p_{30bit} \rightarrow p_{256bit}$
+ 数据组数由3组增加到5组

此时p显然没有办法爆，但同样的，只要有p就很容易解出$A,B$来，因此核心还是在于求p。

和普通LCG一样，先考虑两两消元：
$$
X_3-X_2 = A(X_2-X_1) \quad(mod\;p)
$$

$$
X_4-X_3 = A(X_3-X_2) \quad(mod\;p)
$$

$$
X_5-X_4 = A(X_4-X_3) \quad(mod\;p)
$$

此时考虑消去$A$的影响，比如对于：
$$
(X_2-X_1)(X_4-X_3) = (X_2-X_1)\cdot A^2(X_2-X_1)
$$

$$
(X_3-X_2)^2 = A(X_2-X_1)\cdot A(X_2-X_1)
$$

虽然矩阵乘法不可交换，但是行列式可以，因此有：
$$
|(X_2-X_1)(X_4-X_3)| - |(X_3-X_2)^2| = 0 \quad(mod\;p)
$$
同理：
$$
|(X_3-X_2)(X_5-X_4)| - |(X_4-X_3)^2| = 0 \quad(mod\;p)
$$
作差求gcd即可得到p，之后按上题方法恢复$A,B$即可。

exp：

```python
from Crypto.Util.number import *
from tqdm import *

dim = 10
X1 = 
X2 = 
X3 = 
X4 = 
X5 = 

X1 = Matrix(ZZ,X1)
X2 = Matrix(ZZ,X2)
X3 = Matrix(ZZ,X3)
X4 = Matrix(ZZ,X4)
X5 = Matrix(ZZ,X5)

t1 = ((X4-X3)*(X2-X1)).det() - ((X3-X2)^2).det()
t2 = ((X5-X4)*(X3-X2)).det() - ((X4-X3)^2).det()
p = GCD(t1,t2)

flag = b""
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


#NSSCTF{No_idea_of_context_of_flag_XD}
```

