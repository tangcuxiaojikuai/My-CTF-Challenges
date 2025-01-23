## C0pper

+ Difficulty：Middle
+ Solved：4

<br/>

## Description

What's the meaning of copper?

<br/>

## Hint

+ 搜索一下coppersmith方法的功能

+ 用coppersmith求出几个128bit的小根，然后多项式gcd

+ 多项式的度对copper的小根上界有影响，所以要想办法降低他

+ 对于m2来说多项式的度相当高，一个可能的处理方式是换元

<br/>

## Solution

题目把flag分成前后两段，并随机padding后转为整数值m1、m2，之后生成RSA的私钥p、q及其乘积公钥n，然后给出五个密文(以下运算均在模n下进行)：
$$
c_1 = m_1^3
$$

$$
c_2 = m_1^7 + e_1
$$

$$
c_3 = m_2^{333}
$$

$$
c_4 = m_2^{667} + e_2
$$

$$
c_5 = m_2^{997} + e_3
$$

并给出n，要求还原m1、m2。其中e1、e2、e3都是128bit的素数，e是error的意思，也就是误差。

#### 无误差情况下的求解思路

给我们制造麻烦的主要在于未知的e1、e2、e3，我们可以先想一想如果没有这几个误差我们能怎样恢复flag。比如对于c1、c2来说，我们就有两个在模n下以m1为根的多项式：
$$
f(x) = x^3 - c_1
$$

$$
g(x) = x^7 - c_1
$$

虽然n的分解未知的话，模下方程是难解的，但是既然有两个以m1为公共根的多项式，我们就可以求两个多项式的gcd，就会有一个公因式为：
$$
(x - m_1)
$$
就可以还原出m1，m2也同理可以还原。

#### 有误差情况下的求解思路——coppersmith方法

而e1、e2、e3这些误差使得我们无法建立出这样的多项式组，但是我们可以注意到三个误差都仅有128bit，在模n下是比较小的，而正如题目名字一样，coppersmith提出了一种方法，这种方法可以求解分解未知的n下，多项式的小根。因此我们现在的任务变成了构建出以这些error为小根的多项式。

> coppersmith方法的详细原理涉及格密码学，需要一定基础，有兴趣的可以自行搜索资料了解

入门的时候把这种方法当作黑盒调用即可，一般步骤为：

+ 由已知数据，在模n下建立出以小量为根的多项式

+ 调用coppersmith方法求解小根，单元小根多项式的求解在sagemath中有内置函数，为：

  ```python
  small_roots(X,beta,epsilon)
  ```

  > 参数意义可以查阅sage文档了解

  而如果是多元小根多项式，也有一些通用构造，常用的几个可以在以下网址找到：

  [defund/coppersmith: Coppersmith's method for multivariate polynomials (github.com)](https://github.com/defund/coppersmith)

  [kionactf/coppersmith: Coppersmith method (solving polynomial equation over composite modulus on small bounds) (github.com)](https://github.com/kionactf/coppersmith)

  其中第二个对于一般构造来说求解效果更好，但是环境配置会比较麻烦。实际上第一个更为通用，并且对于绝大部分题目的小根上界来说都已经足够。

+ 将小根代入原方程中，求解剩余未知量

#### 求解m1

那么对于m1，我们有：
$$
c_1 = m_1^3
$$

$$
c_2 - e_1 = m_1^7
$$

所以我们有：
$$
c_1^7 = (c_2 - e_1)^3
$$
由此，按上面的步骤，我们可以建立出一个以e1为小根的多项式：
$$
f(x) = (c_2 - x)^3 - c_1^7
$$
调用small_roots方法，就可以求出e1了。

得到e1之后，两个式子未知量就只剩下了m1，我们就又得到了两个以m1为公共根的多项式，因此求解多项式gcd即可得到m1。

#### 求解m2

对于m2我们有三个式子：
$$
c_3 = m_2^{333}
$$

$$
c_4 = m_2^{667} + e_2
$$

$$
c_5 = m_2^{997} + e_3
$$

按照求解m1的思路，似乎可以如法炮制出以e2为根的多项式：
$$
f(x) = (c_4 - x)^{333} - c_3^{667}
$$
但是实际操作下会发现求解不出来e2了，这是什么原因呢？

看一下m1和m2两部分，最显著的区别在于两部分的指数差异很大，m1指数较小，其对应多项式的度就小，仅为3；而m2指数较大，如果照同样的方法构造多项式的话，其指数为333，就大很多了。

而coppersmith方法求解小根的能力与多项式的度有强相关性，指数越小越利于coppersmith的求解，而333这种数量级已经远远超过了其求解能力，因此用同样的构造求解不了了。

> 多项式的度对于coppersmith小根上界为什么会有影响、究竟有什么影响，有兴趣的也可以自行翻阅资料

所以我们需要想别的构造，而突破点在于m2与m1的另一个区别——m2给了三组数据，所以我们要把三组结合起来一起用。而观察一下又可以发现，三组数据的指数是有很直接的关系的：
$$
667 = 2 \cdot 333 + 1
$$

$$
997 = 3 \cdot 333 - 2
$$

因此我们不妨做一个简单的换元处理：
$$
a = m_2^{333}
$$
那么就有：
$$
c_3 = a
$$

$$
c_4 = a^2m_2 + e_2
$$

$$
c_5 = a^3m_2^{-2} + e_3
$$

而我们知道两个式子结合起来可以消掉一个未知量，而当前三个式子有：
$$
a,m_2,e_2,e_3
$$
共计四个未知量，那么用三个式子两两消元，就可以消去a、m2这两个未知量，从而得到一个含e2、e3且度较低的多项式。

> 此处使用的方法为结式(resultant)消元法，有兴趣的可以自行查阅相关资料

而这样的多项式就可以调刚才提过的多元coppersmith来求解e1、e2了，求出e1、e2之后仍然使用多项式gcd就可以得到m2。

#### 完整exp

```python
from Crypto.Util.number import *
import itertools

def small_roots(f, bounds, m=1, d=None):
	if not d:
		d = f.degree()

	R = f.base_ring()
	N = R.cardinality()
	
	f /= f.coefficients().pop(0)
	f = f.change_ring(ZZ)

	G = Sequence([], f.parent())
	for i in range(m+1):
		base = N^(m-i) * f^i
		for shifts in itertools.product(range(d), repeat=f.nvariables()):
			g = base * prod(map(power, f.variables(), shifts))
			G.append(g)

	B, monomials = G.coefficients_monomials()
	monomials = vector(monomials)

	factors = [monomial(*bounds) for monomial in monomials]
	for i, factor in enumerate(factors):
		B.rescale_col(i, factor)

	B = B.dense_matrix().LLL()

	B = B.change_ring(QQ)
	for i, factor in enumerate(factors):
		B.rescale_col(i, 1/factor)

	H = Sequence([], f.parent().change_ring(QQ))
	for h in filter(None, B*monomials):
		H.append(h)
		I = H.ideal()
		if I.dimension() == -1:
			H.pop()
		elif I.dimension() == 0:
			roots = []
			for root in I.variety(ring=ZZ):
				root = tuple(R(root[var]) for var in f.variables())
				roots.append(root)
			return roots

	return []


########################################################### data


########################################################### part1 univariate coppersmith
PR.<x> = PolynomialRing(Zmod(n))
f = (c2 - x)^3 - c1^7
f = f.monic()
res = f.small_roots(X=2^128,beta=1,epsilon=0.05)
a = int(res[0])


def gcd(g1, g2):
    while g2:
        g1, g2 = g2, g1 % g2
    return g1.monic()

PR.<x> = PolynomialRing(Zmod(n))
f1 = x^3 - c1
f2 = x^7 + a - c2
print(long_to_bytes(int(-gcd(f1,f2)[0])))


########################################################### part2 bivariate coppersmith
PR.<t,m,a,b> = PolynomialRing(Zmod(n))
f1 = t - c3
f2 = t^2*m + a - c4
f3 = t^3 + b*m^2 - c5*m^2

g1 = f1.sylvester_matrix(f2,t).det()
g2 = f1.sylvester_matrix(f3,t).det()
h = g1.sylvester_matrix(g2,m).det()
print(h)
PR.<a,b> = PolynomialRing(Zmod(n))
F = 
res = small_roots(F, (2^128,2^128), m=4,d=4)
a, b = int(res[0][0]), int(res[0][1])



def gcd(g1, g2):
    while g2:
        g1, g2 = g2, g1 % g2
    return g1.monic()

PR.<x> = PolynomialRing(Zmod(n))
f1 = x^333 - c3
f2 = x^667 + a - c4
print(long_to_bytes(int(-gcd(f1,f2)[0])))


#catctf{Un1vaRiate_c0pp3rSm1th_@nd_Biv4r1aTe_C0Pp3rSm1th_4ND_Fin@lLy_P0lyn0m1Als_GCD!}
```

还有一个比较简单的思路是找如下方程的小正整数解：
$$
333x = 667y + 997z
$$
简单遍历一下小整数会得到一组解：
$$
(x,y,z) = (7,2,1)
$$
所以就有多项式：
$$
f(x,y) = (c_4 - x)^2(c_5 - y) - c_3^7
$$
多元copper即可。