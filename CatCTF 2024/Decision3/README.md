## Decision3

+ Difficulty：Middle
+ Solved：3

<br/>

## Description

Make your decision again and again and again!

<br/>

## Hint

+ 题目基于曲线同源，主要关注3-isogeny关联的曲线和2-isogeny关联的曲线满足的不同等式

<br/>

## Solution

本题背景为曲线同源，先在一个给定的素数p下，生成一个二次扩域$GF(p^2)$下的超奇异椭圆曲线E，然后基于这个E开始进行后续步骤。

> 有关isogeny的知识我也写过一篇文章记录，有兴趣的同学可以看这篇帮助入门：
>
> [Isogeny | 糖醋小鸡块的blog (tangcuxiaojikuai.xyz)](https://tangcuxiaojikuai.xyz/post/e06139e7.html)
>
> 当然，本题依然需要直接介绍其中一些概念，下方部分内容直接摘自上面这篇文章

本题的decision为：

+ 不论当前bit为1还是0，都会先基于刚才的曲线先进行十次2-isogeny或者3-isogeny，从而同源到一条新曲线上，这一步是为了通过起始曲线直接确定当前曲线

+ 如果flag当前bit是1，则进行一次3-isogeny，并且给出同源前后两条曲线Montgomery形式的a2，但是同源前的a2会有13bit误差，同源后的a2会有模p下的随机误差
+ 如果flag当前bit是0，则进行一次2-isogeny，并且给出同源前后两条曲线Montgomery形式的a2，但是同源前的a2会有13bit误差，同源后的a2会有模p下的随机误差

可以看出，我们主要是要判断出每一bit对应的同源究竟是2-isogeny还是3-isogeny，而其实不是2-isogeny就是3-isogeny，所以我们可以选择仅判断是否是2-isogeny，更为简单。

#### 一些基本概念

##### 超奇异椭圆曲线

若曲线E定义在有限域$F_{p^r} (r \in Z^*)$下，若E的阶order满足：
$$
order = 1 \quad(mod\;p)
$$
则E是一条超奇异椭圆曲线。

##### 扩域

扩张的概念其实很简单。扩张也称作扩域，对于两个域来说，如果K是F的子域，F就是K的扩域或扩张。那么这里不妨选一个素数p，其为一个模4余3的大素数，则对于有限域$F_p$来说，他的二次扩张就是$F_{p^2}$。

而本题的同源就是在有限域$F_{p^2}$下工作的，这个有限域的大小是p^2，也就是说其中有p^2个元素。而这样一个有限域的元素有个最方便的表示方法，就是写成复数形式：
$$
u + vi \quad (u,v \in F_p)
$$
这样表示显然满足域的定义，因为首先它含有单位元1和零元0，并且满足：

+ $(F_{p^2},+)$是阿贝尔群
+ $(F_{p^2}-\{0\},\times)$是阿贝尔群
+ 乘法对加法满足分配律

##### 曲线的Montgomery形式

对于蒙哥马利形的椭圆曲线来说，其曲线方程可以写成：
$$
E: \quad \quad y^2 = x^3 + ax^2 + x
$$
题目代码中的a2就是这个方程中的a，这是因为一条长Weierstrass形椭圆曲线的标准方程其实是：
$$
y^2 + a_1xy + a_3y = x^3 + a_2x^2 + a_4x + a_6
$$
而一般看到的是短Weierstrass形椭圆曲线，也就是：
$$
y^2 = x^3 + ax + b
$$
这是因为在域特征不为2或3时，所有长Weierstrass形曲线都可以转化成短Weierstrass形曲线。

##### j不变量

对于椭圆曲线来说，j不变量可以简单理解为一个判定两条椭圆曲线是否同构的值。也就是说，任何一个曲线都有自己独特的j不变量，而如果两条曲线的j不变量相等，则说明这两条曲线彼此同构。而由于同构的曲线本质上都可以看作同一条曲线，这也就说明，一个j不变量其实在同构意义上其实就唯一对应着一条曲线。

##### 曲线的Montgomery形式下，a与j不变量的关系

曲线在Montgomery形式下，a与他的j不变量满足如下方程：
$$
j(E) = \frac{256(a^2-3)^3}{a^2-4}
$$

##### modular polynomial

有一个比较有用的东西叫做modular polynomial，他的独特作用在于，能够用一个多项式关联d-isogeny中互为邻居的两个j不变量。也就是说，如果知道了一个j不变量，那么可以将其代入对应度的modular polynomial去求根，得到的所有根就是所有作为他的邻居的j不变量。其对应的度较低的多项式形式都可以在如下网站找到：

[Modular polynomials (mit.edu)](https://math.mit.edu/~drew/ClassicalModPolys.html)

#### 解题思路

##### 无误差情况下的求解

我们先假设我们得到的两条曲线的a2是无误差的。

我们从上面的预备知识知道，如果两条曲线是2-isogeny的邻居，那么他们的j不变量就会满足2-modular polynomial，也就是把两个j不变量代入下面的方程中，等式成立：

```python
f = (
	X^3
	+ Y^3
	- X^2 * Y^2
	+ 1488 * X^2 * Y
	+ 1488 * X * Y^2
	- 162000 * X^2
	- 162000 * Y^2
	+ 40773375 * X * Y
	+ 8748000000 * X
	+ 8748000000 * Y
	- 157464000000000
)
```

而我们现在虽然不能直接得到两条曲线的j不变量，但是我们有两条曲线Montgomery形式下的a，因此可以通过下面的等式计算出j不变量来：
$$
j(E) = \frac{256(a^2-3)^3}{a^2-4}
$$
然后检查方程是否满足上面的2-modular polynomial，就可以判断当前bit是0还是1了。

##### 有误差情况下的求解

然而，我们得到的曲线Montgomery形式下的a是有误差的，但是这误差有个特点就是：

+ 第一个误差仅有13bit，在可以枚举的范围
+ 两个误差都只涉及a的实部，虚部都是准确值

由于第一个误差很小，因此我们考虑在2^13范围内枚举第一个误差，那么我们可以看做我们拥有第一条曲线准确的a，也就可以计算出第一条曲线准确的j不变量。

而由于supersingular的同源曲线只能是supersingular的，所以对枚举到的超奇异曲线的j不变量，我们就可以代入到2-modular polynomial方程中，然后求根求出第二条曲线的j不变量，进而求出第二条曲线的a，然后我们只需要对比求出的这个a的虚部是否与给出a的虚部完全相同，就可以判断当前的两条曲线是不是2-isogeny的邻居，从而判断当前bit是0还是1。

#### 完整exp

```python
from Crypto.Util.number import *
from tqdm import *

p = 26734989077687468135677691953151
F.<i> = GF(p^2, modulus = x^2 + 1)

def check(j1,a2):
    PR.<Y> = PolynomialRing(F)
    X = j1
    f = (
            X^3
            + Y^3
            - X^2 * Y^2
            + 1488 * X^2 * Y
            + 1488 * X * Y^2
            - 162000 * X^2
            - 162000 * Y^2
            + 40773375 * X * Y
            + 8748000000 * X
            + 8748000000 * Y
            - 157464000000000
        )
    for i in f.roots():
        PR1.<a> = PolynomialRing(F)
        g = 256*(a^2-3)^3 - i[0]*(a^2-4)
        for j in g.roots():
            if((j[0] - a2)[1] == 0):
                return True
    return False


output = 
output = output[7*8:-8]
flag = ""
for bit in trange(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue

    Found = 0
    for i in range(2^13):
        a = output[bit][0] - i
        J = F(256*(a^2-3)^3) / F(a^2-4)
        if(EllipticCurve(F,j=J).is_supersingular(proof=False)):
            res = check(J, output[bit][1])
            if(res == True):
                Found = 1
                break

    if(Found == 1):
        flag += "0"
    else:
        flag += "1"
    
    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#catctf{D1ffeRenT_M0duL@r_P0lynom1Al!}
```

#### 多进程编程

赛中和做了本题的[@TRiv1al](https://www.zhihu.com/people/flatter-old)交流了一下，我的exp大概需要四五十分钟，他的思路没有多大差别，然而他的exp却要跑十小时左右才行。排除一些实现上的细节问题的话，这个时间差异就只能是算力差异了。

而一个有效减少耗时的方式就是使用multiprocessing进行多进程编程，他的使用方法很简单，因此直接放exp：

```python
from Crypto.Util.number import *
from multiprocessing import Pool
from tqdm import *

p = 26734989077687468135677691953151
F.<i> = GF(p^2, modulus = x^2 + 1)

def check(j1,a2):
    PR.<Y> = PolynomialRing(F)
    X = j1
    f = (
            X^3
            + Y^3
            - X^2 * Y^2
            + 1488 * X^2 * Y
            + 1488 * X * Y^2
            - 162000 * X^2
            - 162000 * Y^2
            + 40773375 * X * Y
            + 8748000000 * X
            + 8748000000 * Y
            - 157464000000000
        )
    for i in f.roots():
        PR1.<a> = PolynomialRing(F)
        g = 256*(a^2-3)^3 - i[0]*(a^2-4)
        for j in g.roots():
            if((j[0] - a2)[1] == 0):
                return True
    return False

def attack(tup):
    bit, i = tup
    a = output[bit][0] - i
    J = F(256*(a^2-3)^3) / F(a^2-4)
    if(EllipticCurve(F,j=J).is_supersingular(proof=False)):
        res = check(J, output[bit][1])
        if(res == True):
            return True
    return False

output = 
output = output[7*8:-8]
flag = ""
for bit in trange(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue

    Found = 0
    with Pool(8) as pool:
        r = list(pool.imap(attack, [(bit,i) for i in range(2^13)]))

    if(True in r):
        flag += "0"
    else:
        flag += "1"
    
    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#catctf{D1ffeRenT_M0duL@r_P0lynom1Al!}
```

这样子可以将时间缩短至十分钟左右。

注意这里Pool(8)并不代表着直接就可以将耗时缩短到单进程的1/8，因为这依然取决于你的CPU怎么样。但是一般来说使用多进程，对比起单进程肯定是有明显加速效果的。