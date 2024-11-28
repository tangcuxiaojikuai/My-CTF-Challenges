## easy_mod2

+ Difficulty：Middle

## Solution

和mod1唯一的区别就是，m0的长度变成了80。而不调blocksize等参数/不爆破一些字节的话，可以测试出70就是上一个题目的极限了，因此本题的预期是想展示一种更优的构造。

而更优的构造思路也很简单，注意到上题是新令了如下一组变量，使得48-53的目标向量变到了0-7：
$$
t_i = s_i - 48
$$
而其实仅仅改动这个48，改成52，就可以使得目标向量变到-4到3这个更小的数量级了，格的构造和上一题没有任何区别。

需要注意的一小点是，这一题倒数第二列不再需要配3或4，因为目标向量的值已经在-4到3这个范围里了，所以平均差不多在-1，所以就配1就很合理。

exp：

```python
from Crypto.Util.number import *


p = 324556397741108806830285502585098109678766437252172614832253074632331911859471735318636292671562523
c = 141624663734155235543198856069652171779130720945875442624943917912062658275440028763836569215230250

prefix = b"NSSCTF{"
suffix = b"}"
length = 88 - len(prefix) - len(suffix)

#part1 remove prefix and suffix
c -= 256^(len(suffix) + length) * bytes_to_long(prefix)
c -= bytes_to_long(suffix)
c = c * inverse(256,p) % p

L = Matrix(ZZ,length+2,length+2)
for i in range(length):
    L[i,i] = 1
    L[i,-1] = 256^i
    c -= 256^i*48
    c -= 256^i*3

L[-2,-2] = 1
L[-2,-1] = -c
L[-1,-1] = p
L[:,-1:] *= p
res = L.BKZ()

flag = ""
for i in res[:-1]:
    if(all(abs(j) <= 4 for j in i[:-2])):
        if(i[-2] == 1):
            for j in i[:-2][::-1]:
                flag += chr(48 + 3 + j)
        else:
            for j in i[:-2][::-1]:
                flag += chr(48 + 3 - j)
if(flag != ""):
    print(flag)

#NSSCTF{25350625451533421162474265547571536103420331260232652121722452361537257541460235}
```

