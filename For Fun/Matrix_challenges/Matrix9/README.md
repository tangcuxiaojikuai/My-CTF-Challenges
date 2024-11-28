## Matrix9

+ Difficulty：Middle

## Solution

本题基于GF(2)下的矩阵运算，加密流程为：

+ 生成一个n维随机矩阵A

+ 生成一个度为10的随机多项式f

+ 计算：
  $$
  B = f(A)
  $$

+ 仅给出B，要求还原A，从而解AES密文得到flag

本题一个很重要的trick在于可交换矩阵，对于任意的多项式f，我们有：
$$
f(A) \cdot A = A \cdot f(A)
$$
所以我们有：
$$
BA = AB
$$
因此我们解下面的矩阵方程：
$$
BX = XB
$$
得到的kernel是n维的，因此小爆一下kernel其中就存在A，就可以解密得到flag了。

exp：

```python
from Crypto.Util.number import *
from itertools import *
from Crypto.Cipher import AES
from hashlib import md5

############################################################################################### data
B =
enc = 


############################################################################################### exp
########################################## part1 to mat
n = 10
B = Matrix(GF(2), n, n, B)


########################################## part2 get solution of BA = AB
L = Matrix(GF(2), n^2, n^2)
for i in range(n):
    for j in range(n):
        for t in range(n):
            L[n*i+j, n*i+t] += B[t,j]
            L[n*i+j, j+n*t] -= B[i,t]
Ker = L.right_kernel().basis()


########################################## part3 bruteforce for A
def recover(A_flatten, n, p):
    A = Matrix(Zmod(p), n, n)
    for i in range(n):
        for j in range(n):
            A[i,j] = A_flatten[n*i+j]
    return A

for i in product([0,1], repeat=len(Ker)):
    A = Matrix(GF(2), n, n)
    for j in range(len(Ker)):
        A += recover(i[j]*Ker[j], n, 2)
    flag = AES.new(key=md5(str(A).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).decrypt(enc)
    if(b"NSSCTF" in flag):
        print(flag)
        break


#NSSCTF{U31nG_C0mmut@t1vE_and_Bru7eF0rCe!}
```

