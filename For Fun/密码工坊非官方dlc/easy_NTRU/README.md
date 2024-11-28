## easy_NTRU

+ Difficulty：Middle

## Solution

题目基于NTRU，但是问题在于f的数量级过大，甚至超过了p，所以没有办法直接规约。

而处理手段和mod系列其实很类似，由于已知flag的前后缀以及中间一小段的内容，所以可以尝试把flag写成如下形式：
$$
f = 256^{58} + 256^rm_1 + 256^smid + 256m_2 + suf
$$
这个式子里，m1、m2是未知小量，r、s也是未知数，不过可以注意到的是，一旦中间已知部分!!NSSCTF!!的位置确定下来，r、s的具体值也就随即确定了，而中间部分的位置也仅有几十种，所以可以爆破所有可能的位置得到r、s。

那么就假设我们现在已知r、s，目的是规约出f来，就先回看一下NTRU的模等式：
$$
hf = g \quad(mod\;p)
$$
转化成等式，并且把f的展开形式代入进来，也就是：
$$
h(256^{58} + 256^rm_1 + 256^smid + 256m_2 + suf) + kp = g
$$
把常数整合一下，就得到：
$$
h256^rm_1 + h256m_2 + C + kp = g
$$
虽然g未知，但是他的数量级仅有128，在模p下也是个小量，所以就能造出如下格：
$$
\left(\begin{matrix}
1 &&&h256^r\\
&1& &h256\\
&&1 &-C\\
&& &p\\
\end{matrix}\right)
$$
这个格具有的线性关系是：
$$
(m_1,m_2,1,k)
\left(\begin{matrix}
1 &&&h256^r\\
&1& &h256\\
&&1 &-C\\
&& &p\\
\end{matrix}\right)
=
(m_1,m_2,1,g)
$$
比较关键的是配平数量级的问题，由于中间部分位置确定后，m1、m2各有多少个字节其实也就确定了，所以就能够进行配平。

exp：

```python
from Crypto.Util.number import *
from tqdm import *

h = 1756927950546402823211991210884487117388985427696056353000574684529449680817044069252055937789026298359737442776894512901268732373696001068086438971265520
p = 9154925474221530551204374718472364426110749279786123087256403092166680682021327157348820042798042742469289027059354748716972834115194900518063143041804941
flag_len = 65
prefix = bytes_to_long(b"NSSCTF{")*256^(flag_len-7)
suffix = bytes_to_long(b"}")
middle_len = 10

for location in range(1,flag_len-7-middle_len+1):
    middle = bytes_to_long(("!!NSSCTF!!").encode())*256^location
    constant = prefix + middle + suffix

    c2_len = location-1
    c1_len = flag_len - middle_len - 1 - 7 - c2_len
    c2_loc = 1
    c1_loc = 1 + c2_len + middle_len
    
    L = Matrix(ZZ,[[1,0,0,256^c1_loc*h],
                [0,1,0,256^c2_loc*h],
                [0,0,1,constant*h],
                [0,0,0,p]])
    
    T = max(256^c1_len,256^c2_len,2^128)
    Q = diagonal_matrix([T//(256^c1_len) , T//(256^c2_len) , T , T//2^128])
    L = L*Q
    L = L.LLL()
    res = L[0]
    L = L/Q
    res = L[0]
    if((res[2] == 1 or res[2] == -1) and isPrime(int(abs(res[3]))) and int(abs(res[3])).bit_length()==128):
        try:
            print(long_to_bytes(int(abs(res[0]))).decode(),end = "")
            print("!!NSSCTF!!",end = "")
            print(long_to_bytes(int(abs(res[1]))).decode(),end = "")
        except:
            pass


#NSSCTF{Task_1s_to_FinD_where_th3_!!NSSCTF!!_IS_in_thi5_FLAGHhah!}
```

