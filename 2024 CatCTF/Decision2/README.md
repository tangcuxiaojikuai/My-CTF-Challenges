## Decision2

+ Difficulty：Middle
+ Solved：3

<br/>

## Description

Make your decision again and again!

<br/>

## Hint

+ 题目基于配对密码学，主要关注weil pairing函数值的某种性质

<br/>

## Solution

本题背景为曲线配对，使用曲线为BLS12-638，其decision为：(以下运算均在模p下进行)

+ 如果flag当前bit是1，则返回的ci满足：
  $$
  c_i = a^{\frac{p-1}{\prod{primes}}}
  $$
  其中a是模p下的随机数

+ 如果flag当前bit是0，则返回的ci满足：
  $$
  c_i = e(P_1,P_2) \cdot e(Q_1,Q_2)
  $$
  其中，P1、P2为题目给定曲线上的两个不同r1阶点，Q1、Q2为题目给定曲线上的两个不同r2阶点，r1、r2为从primes随机选择的两个值，e为weil pairing函数

为了解决这个题目，首先需要简单了解一下双线性配对函数的一些性质。

#### 椭圆曲线上的双线性配对函数性质

简单来说，双线性配对可以理解成一个函数，其输入为椭圆曲线上的两个点，输出为椭圆曲线所在的域上的一个值。如果把这个函数记为e，那么这个概念可以写为：
$$
e : E_F \times E_F \rightarrow F
$$

$$
P \in E_F,Q \in E_F
$$

$$
e(P,Q) = a ,a\in F
$$

其中F是椭圆曲线所在域。

双线性配对函数的一些重要性质如下：

+ $e(aP,bQ) = e(P,Q)^{ab}$

+ $e(P,P) = 1$

+ 对r-torsion中的点的配对，配对到的值均为曲线所在域的r次单位根

  > 此外还需要介绍一下torsion的概念，曲线上的r-torsion结构定义为所有满足$rP = O$的P点形成的集合，其中O点为曲线的单位元

而题目所用的weil pairing函数正是满足上述性质的一个双线性配对函数。

#### 解题思路

flag当前bit为1的输出值能利用的点似乎并不多，因此我们还是主要关注flag当前bit为0的情况。由于P1、P2为曲线上的r1-torsion中的点，因此由上述性质可以知道，$e(P_1,P_2)$的结果是模p乘法群中的r1次单位根，也就是：
$$
e^{r_1}(P_1,P_2) = 1
$$
同理，对于r2-torsion中的Q1、Q2来说，就会有：
$$
e^{r_2}(Q_1,Q_2) = 1
$$
那么对于当前bit为0的输出来说，一定会有：
$$
c_i^{r_1r_2} = (e(P_1,P_2) \cdot e(Q_1,Q_2))^{r_1r_2} = e^{r_1r_2}(P_1,P_2) \cdot  e^{r_1r_2}(Q_1,Q_2)) = 1
$$
虽然我们并不知道r1、r2具体是primes中的哪两个值，但是我们可以遍历primes中所有两个因子的组合，那么对于当前bit为0的输出ci来说，一定存在一对r1、r2会满足上述等式。

> r1、r2可能相同，但是如此遍历依然可以满足上述等式，因为两个r1次单位根的乘积依然是r1次单位根

而对于当前bit为1的输出，我们知道他是：
$$
c_i = a^{\frac{p-1}{\prod{primes}}}
$$
那么他经过上述遍历，得到的结果是：
$$
c_i^{r_1r_2} = a^{\frac{p-1}{\prod{primes}}\cdot r_1r_2} = a^{\frac{p-1}{r_3r_4}}
$$
r3、r4就是每次遍历中，primes剩下来的两个值，可以看出当且仅当a的阶为${\frac{p-1}{r_3r_4}}$的因子时上式才等于1，而这概率很小，因此就可以逐比特做出正确decision，进而还原flag。

#### 完整exp

```python
from Crypto.Util.number import *
from itertools import *
from tqdm import *

output = 
output = output[7*8:-8]
p = 0x3cb868653d300b3fe80015554dd25db0fc01dcde95d4000000631bbd421715013955555555529c005c75d6c2ab00000000000ac79600d2abaaaaaaaaaaaaaa93eaf3ff000aaaaaaaaaaaaaaabeab000b
primes = [67, 5563, 2099837, 773517157085353949]

flag = ""
for bit in range(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue

    Found = 0
    for i in combinations(primes, r=2):
        if(pow(output[bit], prod(i), p) == 1):
            Found = 1
            break

    if(Found == 1):
        flag += "0"
    else:
        flag += "1"
    
    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#catctf{M4p_70_Sp3c1al_Gr0uP}
```

