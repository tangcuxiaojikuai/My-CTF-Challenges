## Decision1

+ Difficulty: Middle
+ Solved：4

<br/>

## Description

Make your decision again!

<br/>

## Hint

+ 对比一下本题和revenge，可以知道非预期大概出现在什么地方

<br/>

## Solution

本题背景为格密码，其decision为：

+ 如果flag当前bit是1，则生成一个长度为40的模n下随机数组成的列表

+ 如果flag当前bit是0，则：

  + 生成一个长度为20的模n下随机数列表poly，poly代表着一个模n下的多项式f：
    $$
    f(x) = poly_0 + poly_1x^1 + poly_2x^2 + ... + poly_{19}x^{19}
    $$

  + 用多项式f，生成一个长度为40的列表，列表中的元素为：
    $$
    c_i = f(i) + e_i \quad , \quad i \in [0,39]
    $$

  其中ei取值为getrandbits(1)，也就是0或1。

我们需要判断出output中的每个列表究竟是用哪种方式生成的，从而决定当前bit是0还是1。

#### 无误差情况下的求解——拉格朗日插值

由于当前bit为1的样本是随机值组成的列表，因此我们的思路显然是通过某种方法，来判断当前bit的样本是不是F0产生的样本。而注意到F0产生的列表中的每个元素，其实是多项式f上带误差的点值，也就是带误差的因变量y，而我们同时又知道每个y对应的自变量x就是0-39，所以其实我们拥有的是带误差的多项式点对，如下：
$$
(0,f(0)+e_0)
$$

$$
(1,f(1)+e_1)
$$

$$
...
$$

$$
(39,f(39)+e_{39})
$$

而有多组多项式点对，恢复多项式的其中一个办法就是拉格朗日插值法。具体来说，如果没有误差，那么我们可以建立如下矩阵方程：
$$
\left(\begin{matrix}
0&0^1&\cdots&0^{19}\\
1^0&1^1&\cdots&1^{19}\\
\vdots&\vdots&\ddots&\vdots\\
39^0&39^1&\cdots&39^{19}\\
\end{matrix}\right)_{40,20}
\left(\begin{matrix}
poly_0\\
poly_1\\
\vdots\\
poly_{19}\\
\end{matrix}\right)_{20,1}
=
\left(\begin{matrix}
f(0)\\
f(1)\\
\vdots\\
f(39)\\
\end{matrix}\right)_{40,1}
$$
我们的未知数只有poly对应的向量，并且左边的方程数有40个，变量仅有20个。那么我们根据ci构建出这个矩阵方程，如果有解就说明存在这样的poly，当前bit就一定是0了。而由于方程是超定的，所以对于当前bit为1产生的随机列表来说，其几乎不可能有解，因此就可以做出判断。

#### 有误差情况下的求解——LWE样本判定

然而这样做的障碍在于本题的点值有1bit的随机误差ei，那么矩阵方程会变成：
$$
\left(\begin{matrix}
0&0^1&\cdots&0^{19}\\
1^0&1^1&\cdots&1^{19}\\
\vdots&\vdots&\ddots&\vdots\\
39^0&39^1&\cdots&39^{19}\\
\end{matrix}\right)_{40,20}
\left(\begin{matrix}
poly_0\\
poly_1\\
\vdots\\
poly_{19}\\
\end{matrix}\right)_{20,1}
+
\left(\begin{matrix}
e_0\\
e_1\\
\vdots\\
e_{39}\\
\end{matrix}\right)_{40,1}
=
\left(\begin{matrix}
c_0\\
c_1\\
\vdots\\
c_{39}\\
\end{matrix}\right)_{40,1}
$$
此时由于误差e向量的存在，我们解不了矩阵方程了，就需要考虑其他办法。此时如果我们把矩阵方程抽象出来就是：
$$
Ax + e = b
$$
其中我们知道的信息有：

+ A、b的全部值
+ e是0、1组成的向量，在模n下是相当小的量

这其实就是一个典型的LWE样本，有关LWE的详细介绍我之前有写过：

[LWE | 糖醋小鸡块的blog (tangcuxiaojikuai.xyz)](https://tangcuxiaojikuai.xyz/post/758dd33a.html)

而判断一个样本是不是LWE样本，需要用到格密码的相关知识，而这一部分最常用到的有一个LLL函数。

##### LLL

和coppersmith一样，LLL的原理在这里不展开，入门时主要先掌握把它当作一个工具调用即可。他能做到的功能是：

+ 输入一组线性基向量

+ 输出这些基向量经线性组合后，得到的一些更短的基向量

  > 这里“更短”的含义可以理解为向量的长度更小，一定程度上也代表着向量中每个值都相对小

所以要用到LLL的题目的一般思路是：

+ 构造出题目对应的矩阵方程
+ 找到方程中由小的未知量构成的向量，这就是需要的短向量
+ 从矩阵方程中提取出经线性组合后，能够获得需要的短向量的基
+ 对这组基向量调用LLL，得到需要的短向量

我们接下来就照着这个步骤来完成一次解题。

##### 利用LLL解决LWE样本判定

按照步骤，我们第一步需要构造出矩阵方程，这其实也就是带误差的拉格朗日插值方程：
$$
\left(\begin{matrix}
0&0^1&\cdots&0^{19}\\
1^0&1^1&\cdots&1^{19}\\
\vdots&\vdots&\ddots&\vdots\\
39^0&39^1&\cdots&39^{19}\\
\end{matrix}\right)_{40,20}
\left(\begin{matrix}
poly_0\\
poly_1\\
\vdots\\
poly_{19}\\
\end{matrix}\right)_{20,1}
+
\left(\begin{matrix}
e_0\\
e_1\\
\vdots\\
e_{39}\\
\end{matrix}\right)_{40,1}
=
\left(\begin{matrix}
c_0\\
c_1\\
\vdots\\
c_{39}\\
\end{matrix}\right)_{40,1}
$$
接下来我们需要找到小的未知量构成的向量，很显然就是0、1组成的向量e。

第三步尤为关键，我们需要提取出一组经线性组合后能获得短向量的格基，这一步看上去并不容易。而实际上，线性组合的方式就蕴藏在第一步的矩阵方程中，我们不妨将矩阵方程进行转置：
$$
(poly_0,poly_1,...,poly_{19})
\left(\begin{matrix}
0&0^1&\cdots&0^{19}\\
1^0&1^1&\cdots&1^{19}\\
\vdots&\vdots&\ddots&\vdots\\
39^0&39^1&\cdots&39^{19}\\
\end{matrix}\right)^T
+
(e_0,e_1,...,e_{39})
=
(c_0,c_1,...,c_{19})
$$
可以发现，其实poly列表的左乘，就是对该矩阵行向量进行线性组合，而整个运算是模n下的，所以我们可以构造出如下的一矩阵，其行向量就是我们要找的一组线性基：
$$
L = 
\left(\begin{matrix}
1&&&&&0^0&1^0&\cdots&39^0\\
&1&&&&0^1&1^1&\cdots&39^1\\
&&\ddots&&&\vdots&\vdots&\ddots&\vdots\\
&&&1&&0^{19}&1^{19}&\cdots&39^{19}\\
&&&&1&-c_0&-c_1&\cdots&-c_{19}\\
&&&&&n&&&\\
&&&&&&n&&\\
&&&&&&&\ddots&\\
&&&&&&&&n\\
\end{matrix}\right)
$$
而对这个矩阵做如下的线性组合的话，就可以得到短向量：
$$
(poly_0,poly_1,...,poly_{19},1,k_0,k_1,...,k_{19})
L
=
(poly_0,poly_1,...,poly_{19},1,e_0,e_1,...,e_{19})
$$
由于e较小，所以这样得到的目标向量就较短，因此我们对将矩阵L作为LLL的输入进行调用，就可以在LLL的输出向量中找到我们需要的这个向量了。

> 事实上格基规约还需要进行一步操作叫配平（有时是为了规约出0而配大系数）。之所以要进行这个步骤，主要是因为LLL算法输出的基，会更倾向于向量中每个值数量级都相近的短向量

> 有更好的一种方式可以只规约出e，具体可以参考上面那篇LWE文章的primal attack2

而如果当前bit是1，其密文是随机值组成的列表，当然就很难有这么凑巧的线性组合，可以使得LLL之后输出这样的短向量，因此就可以通过LLL的输出结果对当前bit做出判断了。

#### 完整exp

```python
from Crypto.Util.number import *
from tqdm import *

#primal_attack2
def primal_attack2(A,b,m,n,p,esz):
    L = block_matrix(
        [
            [matrix(Zmod(p), A).T.echelon_form().change_ring(ZZ), 0],
            [matrix.zero(m - n, n).augment(matrix.identity(m - n) * p), 0],
            [matrix(ZZ, b), 1],
        ]
    )
    #print(L.dimensions())
    Q = diagonal_matrix([1]*m + [esz])
    L *= Q
    L = L.LLL()
    L /= Q
    res = L[0]
    if(all(i in [0,1,-1] for i in res) and abs(res[-1]) == 1):
        return True
    else:
        return False


output = 
output = output[7*8:-8]
n = 65537
nums = 40

flag = ""
for bit in trange(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue

    A = Matrix(Zmod(n), 0, 20)
    b = []
    for i in range(nums):
        A = A.stack(vector(Zmod(n), [pow(i,j,n) for j in range(20)]))
        b.append(output[bit][i])
    A = Matrix(ZZ, A)
    b = vector(ZZ, b)
    check = primal_attack2(A,b,nums,20,n,1)

    if(check == True):
        flag += "0"
    else:
        flag += "1"
    
    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#catctf{l4gRanG3_@nD_LWE_s@mple!}
```

#### 非预期解

事实上，由于多项式的度仅为19，因此在没有误差影响的情况下，利用拉格朗日插值方程，我们只需要20组数据就可以恢复多项式系数：
$$
\left(\begin{matrix}
0&0^1&\cdots&0^{19}\\
1^0&1^1&\cdots&1^{19}\\
\vdots&\vdots&\ddots&\vdots\\
19^0&19^1&\cdots&19^{19}\\
\end{matrix}\right)
\left(\begin{matrix}
poly_0\\
poly_1\\
\vdots\\
poly_{19}\\
\end{matrix}\right)
=
\left(\begin{matrix}
c_0\\
c_1\\
\vdots\\
c_{19}\\
\end{matrix}\right)
$$
然而实际上题目是有误差的，但是我们可以爆破这20比特的误差，从而恢复多项式系数：
$$
\left(\begin{matrix}
0&0^1&\cdots&0^{19}\\
1^0&1^1&\cdots&1^{19}\\
\vdots&\vdots&\ddots&\vdots\\
19^0&19^1&\cdots&19^{19}\\
\end{matrix}\right)
\left(\begin{matrix}
poly_0\\
poly_1\\
\vdots\\
poly_{19}\\
\end{matrix}\right)
=
\left(\begin{matrix}
c_0\\
c_1\\
\vdots\\
c_{19}\\
\end{matrix}\right)
-
\left(\begin{matrix}
e_0\\
e_1\\
\vdots\\
e_{19}\\
\end{matrix}\right)
$$
然后拿这多项式去计算后续值的函数值，检查误差是否仅有1比特即可。

exp：

```python
from Crypto.Util.number import *
from itertools import *
from tqdm import *


output = 
output = output[7*8:-8]
n = 65537
nums = 20

flag = ""
f = lambda x: sum((poly[i])*pow(x,i,n) for i in range(len(poly))) % n
for bit in trange(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue
        
    A = Matrix(Zmod(n), 0, 20)
    b = []
    for i in range(nums):
        A = A.stack(vector(Zmod(n), [pow(i,j,n) for j in range(20)]))
        b.append(output[bit][i])
    A = Matrix(Zmod(n), A)
    b = vector(Zmod(n), b)
    invA = A^(-1)

    Found = 0
    for e in product([0,1],repeat=nums):
        e = vector(Zmod(n),e)
        poly = (invA*(b-e)).list()

        #check
        if(abs(int(f(20))-int(output[bit][20])) <= 1 and abs(int(f(21))-int(output[bit][21])) <= 1):
            Found = 1
            break

    if(Found == 1):
        flag += "0"
    else:
        flag += "1"
    
    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#catctf{l4gRanG3_@nD_LWE_s@mple!}
```

Decision1_revenge就是提高了维数的非预期修复版本，所以不单独写exp了。