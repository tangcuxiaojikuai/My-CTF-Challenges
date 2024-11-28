## easy_mod3

+ Difficulty：Middle

## Solution

这题相比于前面的题目有两处改动：

+ table仅有N和s两种值
+ 长度增加到100

既然又增加了明文串的长度，那么不考虑调参/爆破的情况下，自然规约出的向量中的值要比前面两问更小才行。而由于只有两种值，所以也很容易将他与背包问题里的0、1联系起来。所以本题的核心思路在于：如何将N和s转化为0、1？

由于N的ASCII码值为78，而s为115，所以我们不妨新令一组变量为：
$$
t_i = s_i - 78
$$
那么再回看上面的式子：
$$
m_0 = \sum_{i=0}^{99}256^is_i \quad(mod\;p)
$$
就有：
$$
m_0 = \sum_{i=0}^{99}256^i(t_i+78) \quad(mod\;p)
$$
然后做类似的处理，把所有78移到等式左侧去得到m1，就有：
$$
m_1 = \sum_{i=0}^{99}256^it_i \quad(mod\;p)
$$
现在的问题是ti由0和37(115-78)组成，离我们预想的0、1还有点差距。但处理方法也很简单，只需要做个如下的变换即可：
$$
37^{-1}m_1 = \sum_{i=0}^{99}256^i(37^{-1}t_i) \quad(mod\;p)
$$
此时规约出来的就是0、1向量了，格的构造和前面并没有大的区别，依然仅需要修改m0那个位置的值。

exp：

```python
from Crypto.Util.number import *

p = 421384892562377694077340767015240048728671794320496268132504965422627021346504549648945043590200571
c = 273111533929258227142700975315635731051782710899867431150541189647916512765137757827512121549727178

a = inverse(ord("s")-ord("N"),p)

prefix = b"NSSCTF{"
suffix = b"}"
length = 108 - len(prefix) - len(suffix)

#part1 remove prefix and suffix
c -= 256^(len(suffix) + length) * bytes_to_long(prefix)
c -= bytes_to_long(suffix)
c = c * inverse(256,p) % p

L = Matrix(ZZ,length+2,length+2)
for i in range(length):
    L[i,i] = 1
    L[i,-1] = 256^i
    c -= 256^i*78
    c %= p
c = a*c % p

L[-2,-2] = 1
L[-2,-1] = -c
L[-1,-1] = p
L[:,-1:] *= p
res = L.BKZ()

flag1 = "NSSCTF{"
flag2 = "NSSCTF{"
for i in res[:-1]:
    if(all(abs(j) <= 1 for j in i[:-2])):
        for j in i[:-2][::-1]:
            if(abs(j) == 1):
                flag1 += "N"
                flag2 += "s"
            else:
                flag1 += "s"
                flag2 += "N"
flag1 += "}"
flag2 += "}"

if(bytes_to_long(flag1.encode()) % p == 273111533929258227142700975315635731051782710899867431150541189647916512765137757827512121549727178):
    print(flag1)
elif(bytes_to_long(flag2.encode()) % p == 273111533929258227142700975315635731051782710899867431150541189647916512765137757827512121549727178):
    print(flag2)


#NSSCTF{NNNssNsNNNNsNNNsNNNNNssNNNssNNNsNsNNsNsNNssNNNNNNsNNNssNsNNNNNssNssssNsNNsNsssNNNNssNNNssNsNNssNsNss}
```

