## Decision4

+ Difficulty：Middle
+ Solved：3

<br/>

## Description

Make your decision again and again and again and again! XD

<br/>

## Hint

+ 题目基于编码密码学，主要关注置换对误差的影响

<br/>

## Solution

本题背景为编码理论，采用的编码是模65537下的(40,12)-Generalized Reed Solomon Code，其decision为：

+ 如果flag当前bit是1，则生成一个GRS的码字M，并生成一个weight为k-1的误差e，然后按如下方式计算得到密文向量ci：
  $$
  \textbf{c}_i = P_1M + P_2e
  $$
  其中P1、P2是随机置换矩阵，共有40种可能性

+ 如果flag当前bit是0，其余部分与1完全一样，只是误差e的weight变成k，同样给出ci：
  $$
  \textbf{c}_i = P_1M + P_2e
  $$

可以看出我们需要判断的内容，是误差e的weight究竟是多少。

GRS码的纠错能力为$\frac{n-k}{2}$，对于这个题目来说就是14，因此不论当前bit为0还是1，其误差e的weight都在纠错范围内，也就是可以进行纠错。而由于随机置换矩阵仅仅有40种可能性，因此我们小范围爆破，其中就存在正确的P1，那么我们可以左乘逆矩阵得到：
$$
P_1^{-1}\textbf{c}_i = M + P_1^{-1}P_2e
$$
而由于e是一个可解码范围内的error，置换的复合$P_1^{-1}P_2$也仍然是个置换，不会改变e的weight，所以置换后的$P_1^{-1}P_2e$仍然是一个可解码范围内的error，所以我们对$P_1^{-1}\textbf{c}_i$做GRS码的decode，就可以得到正确码字M，自然也就可以得到e的weight从而进行decision。

需要注意不仅正确的$P_1^{-1}$能够解码，一些错误的${P'}_1^{-1}$依然能够成功解码，它们对应的是另外的正确码字和error，但当且仅当当前bit为1时才可能有error的weight为k-1。

exp：

```python
from Crypto.Util.number import *
from tqdm import *

p = 65537
F = GF(p)
n, k = 40, 12
C = codes.GeneralizedReedSolomonCode(F.list()[:n], k)
Co = C.encoder()
D = C.decoder()

output = 
output = output[7*8:-8]

flag = ""
for bit in trange(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue

    Found = 0
    for temp in range(n):
        P = Matrix(Zmod(p), matrix(Permutation([i for i in range(1,n+1)][temp:] + [i for i in range(1,n+1)][:temp])))
        codeword = P^(-1) * vector(F,output[bit])
        try:
            msg = D.decode_to_message(codeword).list()
            encodeword = Co.encode(vector(F,msg))
            err = codeword - encodeword
            if(err.list().count(0) == n-k+1):
                Found = 1
                break
        except:
            pass

    if(Found == 1):
        flag += "1"
    else:
        flag += "0"

    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#catctf{S1mplest_C0d1ng_SySt3M!}
```
