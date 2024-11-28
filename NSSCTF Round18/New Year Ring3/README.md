## New Year Ring3

+ Difficulty：Hard
+ Solved：1

<br/>

## Description

新年用个新新新新环！

<br/>

## Hint

+ 利用商环下的多项式同余关系，尝试找出一般意义下商环中多项式乘法的矩阵表示


<br/>

## Solution

本题仍然基于RLWE，只是又将商环变换成：
$$
\frac{Z_p[x]}{x^{64}+2x^{63}+2x^{61}+4x^{60}+...++2x^3+2x+4}
$$
似乎还是可以用刚才构造矩阵的思路去解，但是想一想就会发现，这里由于模多项式又多了非常多项，所以会变得极其麻烦。

因此，这一个题是想将商环下多项式乘法的矩阵表示推广到一个更一般的形式，也就是说，如果能找到一个方法，使得对任何商环中的多项式乘法都可以用一个统一的算法来表示矩阵的话，那么其实三个题目都能一步到位。

所以接下来就是阐述怎么构造出这样的矩阵。

首先，仍然接续前文的思路。对于一个商环的模多项式，设其最高次项次数为n，那么商环中的所有多项式就都可以用一个长度为n的向量表示，向量中的每一个值分别表示多项式0到n-1次项的系数。由于我们想得到的是一般形式的商环下的多项式乘法矩阵，因此我们下面将都用一个抽象出的例子来说明。我们就假设，我们要计算的是多项式a和多项式b在模多项式v下的乘积c，其中v是n次，那么就可以把这四个多项式记为：
$$
a = (a_0,a_1,a_2,a_3,...a_{n-1})
$$

$$
b = (b_0,b_1,b_2,b_3,...b_{n-1})
$$

$$
v = (v_0,v_1,v_2,v_3,...v_{n-1},1) \quad (默认模多项式为首一多项式)
$$

$$
c = (c_0,c_1,c_2,c_3,...c_{n-1})
$$

而接下来的核心思路是，将商环下的多项式乘法拆分成两步，并分别用矩阵乘法表示：

+ a和b相乘，得到多项式d
+ d模v，得到c

然后将两步矩阵相乘，就得到我们需要的最终矩阵——商环下多项式乘法的表示矩阵。其中d是一个最高次项可以达到2n-2次的一个多项式，因此可以用向量写作：
$$
d = (d_0,d_1,d_2,d_3,...d_{n-1},d_n,...,d_{2n-2})
$$
那么接下来就分步阐述怎么构造矩阵。

#### a和b相乘，得到多项式d

由于不需要进行模多项式运算，所以这一步其实非常简单，对于目标向量d中每个值对应的次数，我们只需要将所有能得到这个次数的系数乘积求和即可。也就是说矩阵乘法可以表示成：
$$
(a_0,a_1,a_2,...a_{n-1})
\left(
 \begin{matrix}
   b_0    &b_1    &b_2   &\cdots &b_{n-1}&&\\
   &b_0    &b_1   &\cdots &b_{n-2}&b_{n-1}&\\
   &&b_0   &\cdots &b_{n-3}&b_{n-2}&b_{n-1}\\
   &&&\ddots &\vdots&\vdots&\vdots&\ddots\\
   &&&&b_0&b_1&b_2&\cdots&b_{n-1}\\
  \end{matrix}
  \right)
  =
  (d_0,d_1,d_2,d_3,...d_{n-1},d_n,...,d_{2n-2})
$$
为了更方便说明，把向量和矩阵的大小都标识出来会更好：
$$
(a_0,a_1,a_2,...a_{n-1})_{1\times n}
\left(
 \begin{matrix}
   b_0    &b_1    &b_2   &\cdots &b_{n-1}&&\\
   &b_0    &b_1   &\cdots &b_{n-2}&b_{n-1}&\\
   &&b_0   &\cdots &b_{n-3}&b_{n-2}&b_{n-1}\\
   &&&\ddots &\vdots&\vdots&\vdots&\ddots\\
   &&&&b_0&b_1&b_2&\cdots&b_{n-1}\\
  \end{matrix}
  \right)
  _{n\times (2n-1)}
  =
  (d_0,d_1,d_2,d_3,...d_{n-1},d_n,...,d_{2n-2})_{1\times (2n-1)}
$$
那么接下来我们的目标是，将得到的d向量：
$$
(d_0,d_1,d_2,d_3,...d_{n-1},d_n,...,d_{2n-2})_{1\times (2n-1)}
$$
进行模v，从而得到最终的多项式c，将这个过程也表示成矩阵乘法。

#### d模v，得到c

首先对于d中前n项来说(也就是0到n-1次项)，表示到最终的向量c是很轻松的，由于次数低，不需要模多项式，所以只需要将对应数值加到c中对应项中就可以，也就是造一个单位矩阵即可。

而较难处理的是d中超过了n-1次的项，因为他们要进行模v的操作。而对于这里我们处理的手段仍然是构造模多项式中的同余方程：
$$
x^{n} = -(v_{n-1}x^{n-1}+v_{n-2}x^{n-2}+...+v_{2}x^{2}+v_{1}x^{1}+v_0) \quad(mod\;v)
$$
也就有：
$$
x^{n+i} = -(v_{n-1}x^{n-1+i}+v_{n-2}x^{n-2+i}+...+v_{2}x^{2+i}+v_{1}x^{1+i}+v_0x^i) \quad(mod\;v)
$$
而又因为d中最高也就只有2n-2次项，所以其中i的范围是：
$$
0,1,2,...,n-3,n-2
$$
可以预见的是，由于高次项会存在多次使用同余方程降次，因此我们需要从i=0开始，逐步将x^(n+i)均转化成一个次数在0到n-1的多项式并求出系数，加到最终多项式c的对应项的系数中。

i=0时，显然直接利用刚才的同余方程就可以得到每个次数的项前需要加的系数：
$$
x^{n} = -(v_{n-1}x^{n-1}+v_{n-2}x^{n-2}+...+v_{2}x^{2}+v_{1}x^{1}+v_0) \quad(mod\;v)
$$
而i=1时，右侧的同余方程又会出现需要降次的x^n次方项，如下：
$$
x^{n+1} = -(v_{n-1}{\color{red}x^{n}}+v_{n-2}x^{n-1}+...+v_{2}x^{3}+v_{1}x^{2}+v_0x) \quad(mod\;v)
$$
好像不太好处理，但其实想一想，不就是把刚才求过的n次项降次后得到的系数代入这里不就好了吗？也就是：
$$
x^{n+1} = -(v_{n-1}{\color{red}(-(v_{n-1}x^{n-1}+v_{n-2}x^{n-2}+...+v_{2}x^{2}+v_{1}x^{1}+v_0)}+v_{n-2}x^{n-1}+...+v_{2}x^{3}+v_{1}x^{2}+v_0x) \quad(mod\;v)
$$
然后展开运算出各项系数即可。

而继续看i=2的形式，右侧会得到：
$$
x^{n+2} = -(v_{n-1}{\color{red}x^{n+1}}+v_{n-2}{\color{red}x^{n}}+...+v_{2}x^{4}+v_{1}x^{3}+v_0x^2) \quad(mod\;v)
$$
可以发现红色项我们均计算过了，我们只需要继续刚才的过程：代入已经算出的式子并展开计算。这也就是一个迭代的过程，一直到：
$$
x^{n+n-2} = -(v_{n-1}{\color{red}x^{n+n-3}}+v_{n-2}{\color{red}x^{n+n-4}}+...+v_{2}{\color{red}x^{n}}+v_{1}x^{n-1}+v_0x^{n-2}) \quad(mod\;v)
$$
计算就彻底结束了。

而要构造矩阵，只需要将d中的大于等于n次方的每一项系数乘以刚才对应展开形式中的对应项系数，就可以得到矩阵中对应的行，然后接在刚才的单位矩阵下即可。也就是说这一步的矩阵应该长下面这个样子：
$$
\left(
 \begin{matrix}
   1\\
   &1\\
   &&1\\
   &&&\ddots\\
   &&&&1\\
   r_0&r_1&r_2&\cdots&r_{n-1}\\
   s_0&s_1&s_2&\cdots&s_{n-1}\\
  \vdots&\vdots&\vdots&\vdots&\vdots\\
   t_0&t_1&t_2&\cdots&t_{n-1}\\
  \end{matrix}
  \right)
  _{(2n-1)\times n}
$$
其中r、s、t几行是我们计算出的值，这里只是随便用个符号记录，没有特别的意义。

这一步的矩阵也表示完了，然后对这一步的矩阵有：
$$
(d_0,d_1,d_2,d_3,...d_{n-1},d_n,...,d_{2n-2})_{1\times (2n-1)}
\left(
 \begin{matrix}
   1\\
   &1\\
   &&1\\
   &&&\ddots\\
   &&&&1\\
   r_0&r_1&r_2&\cdots&r_{n-1}\\
   s_0&s_1&s_2&\cdots&s_{n-1}\\
  \vdots&\vdots&\vdots&\vdots&\vdots\\
   t_0&t_1&t_2&\cdots&t_{n-1}\\
  \end{matrix}
  \right)
  _{(2n-1)\times n}
  =
(c_0,c_1,c_2,c_3,...c_{n-1})_{1\times n}
$$

#### 综合表示

我们只需要将两个矩阵乘起来就得到我们需要的一般意义下的多项式乘法卷积矩阵了：
$$
L
=
\left(
 \begin{matrix}
   b_0    &b_1    &b_2   &\cdots &b_{n-1}&&\\
   &b_0    &b_1   &\cdots &b_{n-2}&b_{n-1}&\\
   &&b_0   &\cdots &b_{n-3}&b_{n-2}&b_{n-1}\\
   &&&\ddots &\vdots&\vdots&\vdots&\ddots\\
   &&&&b_0&b_1&b_2&\cdots&b_{n-1}\\
  \end{matrix}
  \right)
  _{n\times (2n-1)}
  
  \left(
 \begin{matrix}
   1\\
   &1\\
   &&1\\
   &&&\ddots\\
   &&&&1\\
   r_0&r_1&r_2&\cdots&r_{n-1}\\
   s_0&s_1&s_2&\cdots&s_{n-1}\\
  \vdots&\vdots&\vdots&\vdots&\vdots\\
   t_0&t_1&t_2&\cdots&t_{n-1}\\
  \end{matrix}
  \right)
  _{(2n-1)\times n}
$$
此时就有：
$$
(a_0,a_1,a_2,...a_{n-1})L= (c_0,c_1,c_2,c_3,...c_{n-1})
$$
对于这个题目来说，之后就只需要将矩阵代入到RLWE的攻击格中，就可以规约得到需要的向量了。

exp：

```python
from Crypto.Util.number import *

A = [143895536039223361852265879930678271849, 49941095619845369403633015749131244252, 192366807276439803341529420280624695341, 41863179329950350668896955448215016801, 161730900763954941459384930538350726304, 69486722690005239063204459423772119076, 150044605995739190031133614780160002164, 53617544566841857383903597080623109339, 74625820568619243297350181792710531670, 16380616502578067837931320551193635969, 161905270710745874415457791187229895491, 60615195134615631027916010677640865675, 160490605829184543601552626825699212302, 67566984475203250552779752218068594160, 213285653211278131505736720165333128065, 64852378214458505102852766762259296220, 127863063181868054387649888847647635563, 173388212610482051840613449798996257379, 107853129453974811439304180468226801619, 47026991726695830686352132714620786077, 54537407094343620242102574881749270054, 213117990243770129927508589374671252215, 188551573436848023902527678127834115095, 184904756222053551643771035280489901913, 130154717708566694574065576508622379407, 169935928816833755787895658897579592244, 25127997681478110567876718932464424139, 66241086523494222064942298262635441275, 128384348198631966247204855175670185827, 186534789734452323940160584274797242101, 44113757786219743282268996106377142498, 161464089943212437590741012855856579087, 152978274982120638112396394811148002893, 127858672640521604574047701048286112335, 24811959746896810879635351294335540800, 139884017165706571446169150175115903276, 162069295856137595644855638161429085830, 103852979898094376585707063387003994190, 209853862047034349714977775246731397993, 83875540721706520814802129116239183141, 229717680288888669127660062951596981300, 142905448436402318840598200380283379791, 97701946983539136207969604175005004177, 132882918810599573425074347748636321411, 30946979906897798248175975370883897061, 227445609344085479411697428271056340360, 226861499760726945354933277553812121082, 34610454530275079356327169999644151033, 86543487884993671802260662621113434518, 193748181739943346975874601639150010426, 34955296746796322689176100212054938608, 78982586205793555689802056285642735691, 3417188406740628320649576312400181913, 165141388407797054166867506278447838336, 12695265941766745754277957144871301850, 89458008041873757788350494973818918496, 17544328835809254417440184162473311528, 17809092337865928270441021151091911120, 190539046594231331045902135957952644092, 54013202950149354717829653296038417693, 182140149560821210676566057705914354798, 182590162902622112992977612842205026523, 226186981126958513892204825722664037031, 96763448317215723992226901770790799160]
B = [146131953632371057251386640770029761962, 155126848145561802955686124994407020596, 215548579819339372855889610814620506576, 215378077144333849353671692326217769974, 211651696346814349480371028078398365850, 56211588439881618182356345926007014351, 35792916285189253601060073066755768657, 193834084101163540069238791365615525212, 64185605303590514314207911465024315433, 74011476974910970618385371699236712496, 144080173424901828501825948809304329878, 50478515840382641218068722055014699097, 61424373096897526822902957616641049161, 228135094283701120116040034916450645966, 173676278129085855942014338366292660640, 4958486587405211188374567586180119556, 107653280004443417845206647750419894242, 227948848364624440330554299487592496262, 103344313582462128597769184556262118266, 179090340541635393147453223953633783366, 91157025540035569434535505051126504071, 218301646561306199078249711983197566905, 207984369886452772406666980534904709935, 84848453635637121750244379243550315275, 70455676155616420940430093468129934421, 112082679346753821742720835769195197209, 100096437088582331947465760446007491622, 23148318752965414660522976895342715316, 175024877143863308838121164427112023613, 65455761812920253083377790817920776573, 80719540338474829645398437070034720831, 30265965699771257065456865006701716765, 65059939935789446486144438246062876092, 73412866905686210879034022846184532326, 15496701729614207294798217895713334887, 187927627267834618400725936475600101114, 51596647781094949272750319452641626273, 34936140628305933632043160171328035222, 227636764157434931002269545814362460674, 40310006070105509297521946935690917605, 158199753843142436703851148792841271128, 62042757128547429572711130709028563495, 4994577444829057554913018889328955170, 212120189443587994433256482180523602261, 217895194863190305322702282626368171628, 14347476896110839167629995111874858945, 92969919157086783529099464146480743366, 98421412347381684974090776331896675353, 7670925013164447091797082877392123056, 92948133844692458289793766569490521009, 37843417064278243200690200946062028300, 73246898716604229152337274167003969610, 48576361100747286180365305580004800549, 226777738621945748117749363525255463543, 202653365491161565340111352416610858743, 81343653066789166205981715378171248137, 43128791749740623981661146675626160300, 51978531727836859802588862475571492852, 158673579466427370117557321982403789903, 154526278040551924441198621574328917110, 23520842615720508371775640194790884675, 76597771060168857457987619277375824543, 229138699410621489832761240581614631878, 62849396773221525801893336014307910648]
p = 229934842599910967421870245339955481121
n = 64

#part1 construct matrix of poly_mul

#n:The highest degree of a modular polynomial
#v:vector of modular polynomial
#a:vector of a polynomial multiplier

#aim to construct a matrix of c=a*b%v
def construct_poly_mul_mat(n,v,b):
    assert v[-1] == 1 #use this after monic

    #step1 construct a matrix of d=a*b
    mat1 = Matrix(ZZ,n,2*n-1)
    for i in range(n):
        for j in range(n):
            mat1[i,j+i] = b[j] 

    #step2 construct a matrix of c=d%v
    mat2 = Matrix(ZZ,2*n-1,n)
    for i in range(n):
        mat2[i,i] = 1
    for i in range(n,2*n-1):
        for j in range(i-n,n):
            mat2[i,j] = -v[j-(i-n)]
        
        init_row = vector(ZZ,n*[0])
        for j in range(i-n):
            temp = -v[n-1-j]*vector(ZZ,mat2[i-j-1])
            init_row += temp
        for j in range(n):
            mat2[i,j] += init_row[j]   
             
    #step3 multiply them and return
    return(mat1*mat2)

PRp.<x> = PolynomialRing(Zmod(p))
newyear = [2,0,2,4]
f = x^n
for i in range(n):
    f += newyear[i%4]*x^(n-1-i)
v = f.list()
poly_mul_mat = construct_poly_mul_mat(n,v,A)


#part2 construct Lattice of RLWE
I = identity_matrix(n)
B_mat = Matrix(ZZ,B)
O = diagonal_matrix([0]*n)
O_vec = Matrix(ZZ,1,n)
O_vec_T = Matrix(ZZ,n,1)
L = block_matrix(ZZ,[[p*I,O,0],[poly_mul_mat,I,O_vec_T],[B_mat,O_vec,1]])


#part3 LLL to get s and get flag
res = L.LLL()[0]
s = res[n:2*n]
for i in s:
    print(chr(abs(i)),end = "")


#NSSCTF{!!!Hah4H@,H0p3_Y0U_h@ve_fang_In_y0ur_po1Ynomial_5tudY!!}
```

而这样的通解自然对前面的两题也适用。