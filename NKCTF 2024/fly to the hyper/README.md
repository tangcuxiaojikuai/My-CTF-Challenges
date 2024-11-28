## fly to the hyper

+ Difficulty：Hard
+ Solved：1

<br/>

## Description

find the password

<br/>

## Hint

+ something seems so smooth


<br/>

## Solution

题目基于域$GF(2^{180})$下的亏格为2的超椭圆曲线，其满足方程：
$$
y^2 + h(x)y = f(x)
$$

$$
h(x) = x^2 + 1
$$

$$
f(x) = x^5 + x^2 + 1
$$

题目初始化了一个长度为10字节的password，其中每个字符都是不可见字符。然后用这个password的md5值作为AES的密钥去加密了flag，因此主要任务就是通过泄露的信息去还原password，进而解密AES得到明文。

而题目泄露的信息如下：

+ 将password转为长度为80的01串，并转为列表，记为bag
+ 随机生成80个该超椭圆曲线上Jacobian群上的元素，并且均乘5，该列表记为points
+ 令元素s为Jacobian群的单位元，然后遍历bag，若当前bit为1，则加上points的对应项
+ 给出最终的s以及列表points

可以看出这其实就类似一个背包加密，只是把情境放在了一条超椭圆曲线上而已。所以其实要做的就是两件事：

+ 转为数域上的背包问题
+ 求解背包问题

那么先解决第一个问题，要转到数域上，就要对Jacobian群的元素求解DLP，这就又需要先求出Jacobian群的阶。一般来说超椭圆曲线的Jacobian群的阶并不容易求解，但是由于本题选择的是$GF(2^{180})$这个有限域，其基域是$GF(2)$，因此可以参考论文求解他的阶：

[main.dvi (uwaterloo.ca)](https://www.math.uwaterloo.ca/~ajmeneze/publications/hyperelliptic.pdf)

```python
#calc order(only genus = 2 and characterictiv = 2)
def Hyper_Jacobian_order(n,q=2):
    F = GF(q)
    PP.<u> = PolynomialRing(F)
    h = u^2 + u
    f = u^5 + u^3 + 1
    H = HyperellipticCurve(f, h)

    #calc M1,M2
    M1,M2 = H.count_points_exhaustive(2)

    #calc a1,a2
    a1 = M1 - 1 - q
    a2 = (M2 - 1 - q^2 + a1^2) // 2
    
    #calc y1,y2
    X = var('X')
    y1,y2 = solve([X^2 + a1*X + (a2 - 2 * 2) == 0], X)
    y1,y2 = y1.rhs(),y2.rhs()
    
    #calc alpha1,alpha2
    alpha1 = solve([X^2 - y1*X + q == 0], X)[0].rhs()
    alpha2 = solve([X^2 - y2*X + q == 0], X)[0].rhs()

    #calc Nn
    Nn = int(abs(1-alpha1^n)^2*abs(1-alpha2^n)^2)
    
    return Nn

n = 180
order = Hyper_Jacobian_order(n)
```

但是更简洁的方式可以参考0CTF的simple curve一题hxp的wp，可以先求出超椭圆曲线在基域上的Frobenius多项式的分解，然后再利用下方链接里的定理去计算其k=180的扩域上Jacobian群的阶：

[hxp | 0CTF 2020 writeups](https://hxp.io/blog/74/0CTF-2020-writeups/)

```python
extend = 180
F = GF(2^extend, 'z', modulus = x^180+x^3+1)
z = F.gens()[0]
PRx = PolynomialRing(F,"x")
x = PRx.gens()[0]
h = x^2 + 1
f = x^5 + x^2 + 1
H = HyperellipticCurve(f, h)
J = H.jacobian()

C = H.change_ring(GF(2))
p = C.frobenius_polynomial()
alpha = p.roots(ring=QQbar)
N = ZZ(prod(1-a[0]^extend for a in alpha))
```

求出Jacobian群的阶过后，对阶进行分解，可以发现本题选的Jacobian群的阶相当的光滑：

```python
2^5 * 3^12 * 13^2 * 19^2 * 101 * 157 * 271 * 461 * 523 * 701 * 829 * 1531 * 1747 * 20341 * 57901 * 71161 * 623881 * 93383701 * 1563346261 * 118050254940601 * 1559805923143337117401
```

然而sage似乎并没有实现对超椭圆曲线的Jacobian群的DLP(我没有找到)，因此要自己实现一个Pohlig-Hellman，实现原理也很简单，就是选择一些小的子群去爆破，并且结合上多进程和bsgs去进行加速。这里最多也就选择到623881这个因子，因为如果再选择更大的比如93383701的因子就会使整个过程显著变慢。

> 同时这里还有一个问题，就是我是用的随机算法选择作为DLP的基点的G，发现很难找到一个阶就正好为Jacobian群阶的生成元。而对Jacobian群是否一定存在生成元这个问题我也没研究过，所以保险起见没有取前面有幂次的小因子参与DLP

所以最终选择以下因子去进行Pohlig-Hellman：

```python
101 * 157 * 271 * 461 * 523 * 701 * 829 * 1531 * 1747 * 20341 * 57901 * 71161 * 623881
```

那么进行DLP，可以将points里面的每个点都表示成选择的基点G的倍数形式，也就是每个点都写成$r_iG$的形式，那么整个背包加密的过程就变成：
$$
x_1r_1G + x_2r_2G + ... x_{80}r_{80}G = sG
$$
那么其实也就转成了数域上的背包问题：
$$
x_1r_1 + x_2r_2 + ... + x_{80}r_{80} = s \quad(mod\;n)
$$
其中xi是0或1，n是刚才选择的小因子的乘积，约为146bit。

可以由于模数并不是很大，用最常见的背包造格难以规约出理想的目标向量，因此考虑两个优化：

+ 用一个线性变换y=2x-1，将目标向量由1、0组成的向量变到由1、-1组成的向量
+ 由于已知password均为不可见字符，所以每个字符的MSB都是1，就可以有效降维

做了这些处理后就可以用BKZ规约出目标向量了，然后再逆变换回去就得到原始bag，加上降维消去的MSB就组成了password，进行AES解密就得到flag了。

这里其实也可以采取一点爆破降维的思想，因为格本身维数并不大，所以规约时间很快，因此爆破一些比特位的时间可能会比选择上623881去做Pohlig-Hellman的时间花销要小。

exp：

```python
from Crypto.Util.number import *
from random import *
from tqdm import *
from gmpy2 import iroot
from math import prod
from sympy.ntheory.modular import crt
from multiprocessing import Pool
from Crypto.Cipher import AES
from hashlib import md5


#part1 get Jacobian's order
extend = 180
F = GF(2^extend, 'z', modulus = x^180+x^3+1)
z = F.gens()[0]
PRx = PolynomialRing(F,"x")
x = PRx.gens()[0]
h = x^2 + 1
f = x^5 + x^2 + 1
H = HyperellipticCurve(f, h)
J = H.jacobian()

C = H.change_ring(GF(2))
p = C.frobenius_polynomial()
alpha = p.roots(ring=QQbar)
N = ZZ(prod(1-a[0]^extend for a in alpha))


#part2 choose a random point G
def gen_point():
    while(1):
        try:
            a = F.from_integer(randint(1,2^extend-1))
            PRy.<y> = PolynomialRing(F,"y")
            y = PRy.gens()[0]
            curve = y^2 + h(a)*y - f(a)
            y , k = curve.roots()[0]
            if(k == 1):
                return J(H(a , y))
        except:
            pass
G = gen_point()


#part3 dlp(remove big primes to use Pohlig-Hellman)
def bsgs(operation):
    P,Q,ord = operation

    #subgroup
    O = J(0)
    P = (N // ord) * P
    Q = (N // ord) * Q

    #Q = kP -> Q = (ax+b)P -> Q-bP = x(aP)
    a = iroot(ord,2)[0]+1
    x = O

    dic = {}
    for i in range(a):
        dic[str(Q-x)] = i
        x += P
    
    x = O
    aP = a*P
    for i in range(a):
        if str(x) in dic.keys():
            d = int(i*a+dic[str(x)])
            return (d,ord)
        x += aP

#Q = kP
def Pohlig_Hellman(P , Q , modlist):
    operation_list = [(P,Q,i) for i in modlist]

    with Pool(16) as pool:
        r = list(pool.imap(bsgs, operation_list))
    
    c = [i[0] for i in r]
    mod = [i[1] for i in r]

    return int(crt(mod,c)[0])

modlist = [101 , 157 , 271 , 461 , 523 , 701 , 829 , 1531 , 1747 , 20341 , 57901 , 71161 , 623881]
big_factors = N // prod(modlist)
G = big_factors * G

#data
s = 
points = 
c = 


s = J(s)
s = big_factors * s
B = Pohlig_Hellman(G,s,modlist)
assert B * G == s

A = []
if(1):
    for i in trange(len(points)):
        point = big_factors * J(points[i])
        d = Pohlig_Hellman(G,point,modlist)
        A.append(d)
        assert d * G == point


#part4 remove redundancy
temp = []
for i in range(len(A)):
    if(i % 8 == 0):
        B -= A[i]
        B %= prod(modlist)
        continue
    temp.append(A[i])
A = temp


#part5 knapsack(use BKZ)
L = Matrix(ZZ,len(A)+2,len(A)+2)
for i in range(len(A)):
    L[i,i] = 2
    L[-2,i] = -1
    L[i,-1] = A[i]
L[-2,-2] = 1
L[-2,-1] = -B
L[-1,-1] = prod(modlist)

L[:,-1:] *= prod(modlist)

bag = []
res = L.BKZ()[0]
vec = vector(ZZ,res[:-2])
if(res[-2] == -1):
    vec = - vec
for i in vec:
    bag.append((i + 1) // 2)


#part6 recover password
password = ""
for i in range(len(bag)):
    if(len(password) % 8 == 0):
        password += "1"
    password += str(bag[i])
password = long_to_bytes(int(password,2))


#part7 decrypt AES
key = md5(password).digest()
enc = AES.new(key,mode = AES.MODE_ECB)
flag = enc.decrypt(c)
print(flag)


#NKCTF{Kn@ps4ck_0F_HyperElliptiCCurve!}
```

