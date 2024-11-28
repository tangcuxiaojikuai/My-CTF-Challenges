## Matrix2

+ Difficulty：Easy

## Solution

题目仍然先随机生成一个256bit的素数p，之后生成一个长为flag长度的列表secret，其中每个元素都是模p下的随机值，记他为：
$$
secret = (s_1,s_2,...,s_n)
$$
传secret进入encrypt加密，加密步骤主要是：

+ 生成两个矩阵，满足：
  $$
  L = (\textbf{v}_1,\textbf{v}_2,...,\textbf{v}_n)
  $$

  $$
  R = (s_1\textbf{v}_1,s_2\textbf{v}_2,...,s_n\textbf{v}_n)
  $$

+ 当L和R都满秩时（其实也就是L的所有向量线性无关），返回下面矩阵作为密文：
  $$
  C = (RL^{-1})^e
  $$
  其中e是"Tequila"对应的整数值

+ 以列表secret的和的md5值作为AES的key加密flag，得到enc

给出p、C、enc，要求还原flag。

由于L和R的列向量之间的关系实在是太引人注意了，所以我们先不考虑这个加密指数e的话，可以假设一个A满足：
$$
A = RL^{-1}
$$
这也就是：
$$
AL = R
$$
随便取一条列向量来看就是：
$$
A\textbf{v}_1 = s_1\textbf{v}_1
$$
可以看出两个事实：

+ L中的所有列向量是A的特征向量
+ secret中的所有值是A的特征值

而我们现在有：
$$
C = A^e
$$
为了利用这一点，做以下推导：

若矩阵A满足：
$$
A \textbf{x} = \lambda \textbf{x}
$$
则$\lambda$是A的特征值，$\textbf{x}$是A的特征向量，而对于A^2则有：
$$
A^2 \textbf{x} = A(A\textbf{x}) = A(\lambda \textbf{x}) = \lambda(A\textbf{x}) = \lambda^2 \textbf{x}
$$
以此类推就得到：
$$
A^n \textbf{x} = \lambda^n \textbf{x}
$$
得到结论：

+ A和A^n的特征向量相同
+ A^n的特征值是A对应特征值的n倍

把结论作用在这个题目就有：

+ C的特征值是A的特征值的e倍，也就是si^e

而特征值是模p下的一个数字，所以有：
$$
s_i^{p-1} = 1 \quad(mod\;p)
$$
所以我们只需要求e关于p-1的逆d，然后将C的所有特征值做d次方之后求和就可以得到sum(secret)，之后就可以解AES得到flag。

exp：

```python
from Crypto.Util.number import *
from Crypto.Cipher import AES
from hashlib import md5

############################################################################################### data
p = 
C = 
enc = 

############################################################################################### exp
########################################## part1 to mat
n = int(pow(len(C),1/2))
C = Matrix(GF(p), n, n, C)


########################################## part2 find eigenvalues and flag
res = C.eigenvalues()
e = bytes_to_long(b"Tequila")
key = 0
for i in res:
    key += int(pow(i,inverse(e,p-1),p))

flag = AES.new(key=md5(str(key).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).decrypt(enc)
print(flag)


#NSSCTF{A_S1mPl3_e1g3nVa1ue5_tr1ck!}
```

