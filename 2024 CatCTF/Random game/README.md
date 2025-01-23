## Random game

+ Difficulty：Hard
+ Solved：3

<br/>

## Description

Play a random game with bear!

<br/>

## Hint

+ python的random库函数均基于MT19937伪随机数生成器，搜索一下它的基本原理及攻击思路

+ 费马小定理似乎对某些i有用

+ MT19937的初始state可以看作是长19968的01向量，后续产生的所有随机数对应的01向量在模2下都是初始向量的特定线性组合

<br/>

## Solution

题目明显的分为了两个部分，一部分是getrandbits，一部分是shuffle。比较显然的解题步骤应该是：

+ 用gift实现伪随机数预测，从而确定shuffle如何进行
+ 逆向shuffle还原flag

本题wp也就分这两个部分展开。

#### getrandbits部分

##### MT19937的重要性质以及破解原理

python的random库中，几乎所有的函数都依赖于MT19937伪随机数生成，其具体原理及其他攻击方式可以参考：

[MT19937 分析 | Xenny 的博客](https://xenny.wiki/posts/crypto/PRNG/MT19937.html)

[浅析MT19937伪随机数生成算法-安全客 - 安全资讯平台 (anquanke.com)](https://www.anquanke.com/post/id/205861)

我们这里不详细展开讲MT19937的详细算法内容，只需要了解该算法的几个性质，以及getrandbits实现的几个细节：

+ MT19937生成随机数前，会初始化一个state，state由624个32bit的数字组成，**有了这个state，就可以往后任意预测随机数，不仅仅是getrandbits，random库里的几乎所有函数都可以预测其行为**

+ 往后所有getrandbits产生的数字，都是**关于这个初始state模2下线性的**，这是破解MT19937的核心。用数学化一点的表述就是：

  + 把初始state二进制展开成一个长19968(624x32)的向量，记为$\textbf{s}$，该向量由0、1组成

  + 把getrandbits产生的任意位置的一个比特记为b

  + 那么一定存在一个向量$\textbf{t}$，使得：
    $$
    \textbf{t}\cdot \textbf{s} = b
    $$
    这就是线性关系的含义。

+ getrandbits是按照32bit为单位产生的，举几个例子就是：

  + 如果getrandbit(0)，会直接返回0，不会调用随机数生成
  + 如果getrandbit(32k)，那么会连续产生k个32bit的数并拼接起来
  + 如果getrandbits(t)，0<t<32，那么会先产生一个32bit的数字，然后截取其高t位作为本次随机数

以上就是做题需要了解的核心部分。

所以我们如果能拿到初始的state，就可以预测getrandbits的输出，乃至预测shuffle的行为。也就是说我们的目标是要求解那个长19968的01向量s，而求解依据就是刚才的线性关系式：
$$
\textbf{s}\cdot \textbf{t} = b
$$
其中b是getrandbits产生的某个位置的比特，如果我们能搜集到19968个这样的等式，那么我们就可以把他们拼接起来，构建出一个矩阵方程：
$$
\textbf{s}_{1,19968}T_{19968,19968} = \textbf{b}_{1,19968}
$$
如果T是满秩的，那么我们求解这个矩阵方程就可以得到s的唯一解，再把向量转回624个32bit的数字，也就得到了初始状态state。即使T不是满秩的，在模2下也可以简单遍历一下矩阵方程的解空间，其中就存在正确的s，所以依然可以获得state。

而为了解这个矩阵方程，我们需要有矩阵T和向量b，下面就开始针对题目讲解T和b的获取方式。

##### 获取b

正如刚才所说，b是getrandbits的输出比特组成的向量，这些比特位置可以任意分布，但是我们需要知道他的位置来确定其线性关系。

而我们能获得的getrandbits的输出结果都在gift中，他是：

```python
gift = b"".join(long_to_bytes((pow(getrandbits(4), 2*i, 17) & 0xf) ^ getrandbits(8), 1) for i in range(4567))
```

首先最直接可以获得的一些输出在于getrandbits(8)，我们可以发现每一轮给出的输出其实是getrandbits(8)异或一个4bit的数字，因此密文的高四位就是本次getrandbits(8)的高四位，如此一来我们就可以获得：
$$
4567 \cdot 4 = 18268
$$
这么多个输出比特。

这并不够，正如上一节所讲的，我们需要19968个比特才行，还差一千多个。而我们可以发现与getrandbits(8)异或的部分是：

```python
(pow(getrandbits(4), 2*i, 17) & 0xf) for i in range(4567)
```

17是个素数，由费马小定理我们可以知道：
$$
a^{16} = 1 \quad(mod\;17) \quad ,\quad a \in \{1,2,...,16\}
$$
实际上，由二次剩余的欧拉准则我们能进一步知道：
$$
a^{8} = 1 \quad(mod\;17) \quad ,\quad a \in QR_{17}
$$

$$
a^{8} = -1 = 16 \quad(mod\;17) \quad ,\quad a \in NR_{17}
$$

此时前者结果是1，后者结果是0。而如果a=0，那么结果是0。也就是说，当i为4的整数倍时，本次的：

```python
(pow(getrandbits(4), 2*i, 17) & 0xf)
```

这个计算结果只能是0或1，这也代表着本次getrandbits(8)的高七位就是密文的高七位，所以我们总共能获得的比特数是：
$$
4567 \cdot 4 + \lfloor \frac{4567}{4} \rfloor \cdot 3 = 21691
$$
这远远超过了19968，因此我们就获得了足够的输出比特，只需要选择其中19968个来解线性方程即可。把他们组合起来就得到了向量b：
$$
\textbf{b}_{1,19968}
$$

> 事实上把已知的全取上为好，这样可以让约束更多，从而压缩s的解空间

##### 获取T

我们回顾一下我们需要解的矩阵方程：
$$
\textbf{s} \cdot T = \textbf{b}
$$
我们现在已经获取了b，只要能获取T，就可以解这个矩阵方程得到s了。

而T虽然我们暂时不知道，但是有一点可以确定：它是**由MT19937本身算法得到的确定的线性关系**，也就是说，我们如果拥有所有b的对应比特在MT19937产生的随机数流中的位置，那么其对应的T矩阵也是固定的。

我们的任务就是找到这个固定的T，而找的方式类似于黑盒调用。具体来说，如果我们取最开始的s为：
$$
(1,0,0,...,0)
$$
那么我们按照这个s设置初始state，然后调用getrandbits去生成我们已知位置对应的比特，得到b'，此时得到的b'其实就是T的第一行。同理，我们接下来继续令s为：
$$
(0,1,0,...,0)
$$
用这个s设置state，得到的b‘就是T的第二行。如法炮制我们就可以得到T的全部行。

有了T、b之后我们就可以解出初始state，有初始state之后我们可以将random的state设置为初始state，然后运行一遍gift，就来到了题目中shuffle前同样的状态。

#### shuffle部分

简单阅读一下random库的shuffle，源码如下：

```python
def shuffle(self, x, random=None):
    """Shuffle list x in place, and return None.

    Optional argument random is a 0-argument function returning a
    random float in [0.0, 1.0); if it is the default None, the
    standard random.random will be used.

    """

    if random is None:
        randbelow = self._randbelow
        for i in reversed(range(1, len(x))):
            # pick an element in x[:i+1] with which to exchange x[i]
            j = randbelow(i + 1)
            x[i], x[j] = x[j], x[i]
    else:
        _warn('The *random* parameter to shuffle() has been deprecated\n'
                'since Python 3.9 and will be removed in a subsequent '
                'version.',
                DeprecationWarning, 2)
        floor = _floor
        for i in reversed(range(1, len(x))):
            # pick an element in x[:i+1] with which to exchange x[i]
            j = floor(random() * (i + 1))
            x[i], x[j] = x[j], x[i]
```

可以看出，shuffle的实现原理是调用random库的randbelow函数来多次交换列表内的元素顺序，而我们现在拥有同样的初始状态，所以可以生成一个同样长度的列表，列表中的元素是索引。之后我们将这个列表shuffle2024次，就能看出flag对应的列表中的每个元素在经历2024次shuffle之后，究竟被交换到了什么样的位置，然后按对应索引将flag重新排序即可。

#### 完整exp

```python
from Crypto.Util.number import *
from random import *
from tqdm import *

gift = 
c = 'fUDs_|hUafdiE_eS)ecfna_rh|tu_ps(_1c}_efs___nfdHyilsseUfgt_Fho3is{3Lo_n_n1_u_uH||fFm_X'


######################################################### part1 recover MT and get seed
gift = long_to_bytes(gift)
RNG = Random()

def construct_a_row(RNG):
    row = []
    for i in range(len(gift)):
        RNG.getrandbits(4)
        if(i % 4 == 0):
            row += list(map(int, (bin(RNG.getrandbits(8) >> 1)[2:].zfill(7))))
        else:
            row += list(map(int, (bin(RNG.getrandbits(8) >> 4)[2:].zfill(4))))
    return row

L = []
for i in trange(19968):
    state = [0]*624
    temp = "0"*i + "1"*1 + "0"*(19968-1-i)
    for j in range(624):
        state[j] = int(temp[32*j:32*j+32],2)
    RNG.setstate((3,tuple(state+[624]),None))
    L.append(construct_a_row(RNG))

L = Matrix(GF(2),L)
R = []
for i in range(len(gift)):
    if(i % 4 == 0):
        R += list(map(int, (bin(gift[i] >> 1)[2:].zfill(7))))
    else:
        R += list(map(int, (bin(gift[i] >> 4)[2:].zfill(4))))

R = vector(GF(2),R)

s = L.solve_left(R)
init = "".join(list(map(str,s)))
state = []
for i in range(624):
    state.append(int(init[32*i:32*i+32],2))

RNG1 = Random()
RNG1.setstate((3,tuple(state+[624]),None))


######################################################### part2 set seed and recover shuffle
for i in range(4567):
    RNG1.getrandbits(4)
    RNG1.getrandbits(8)
x = [i for i in range(len(c))]

for i in range(2024):
    RNG1.shuffle(x)

flag = ""
for i in range(len(c)):
    flag += c[x.index(i)]
print(flag)


#catctf{_Shuf|fl3_s|hUFf1e_UnsHUff|L3_unsH|ufF1E_}
```
