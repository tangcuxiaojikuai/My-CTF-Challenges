## 3rdRSA

+ Difficulty：Easy
+ Solved：4

<br/>

## Description

3rd’s Crypto checkin

<br/>

## Solution

把组成n的三个素数分别记作p、q、r，题目给出了以下信息：

+ p、q、r均为729bit左右的素数
+ r-1有一些光滑的小素因子，将他们的乘积记为t，t大约有100bit
+ m大约在1200bit左右
+ $m^3$和$3^m$的值
+ n和r的值

由于给出了r，所以可以先求出m模r的值，同时由$3^m$可以在模r下求光滑部分的dlp，也就得到了m模t的值，之后crt起来就可以拿到m模rt的值，记为ml，此时就可以把m写为：
$$
m = rtm_h + m_l
$$
代入$m^3$中就可以得到：
$$
c = m^3 = (rtm_h + m_l)^3 \quad(mod\;n)
$$
所以就有：
$$
f(x) = (rtx + m_l)^3 \quad(mod\;n)
$$

$$
f(m_h) = 0 \quad(mod\;n)
$$

所以接下来copper就可以了，而由于x的系数有r所以在模n下无法monic，所以转到模pq下去copper就行。

exp：

```python
from Crypto.Util.number import *

nss = 129063444400395931140552937306125851382394430986439278160593873744789936793795518045323178995007062628298309773582176239691459885773526624534690277511861861603281624682554253545227928169748182762012056234854538541309647111293806528166653033498149834445725530659660926127593831428768095049111056550293489376446453196283413940748453177975852069148305909986767912740830549027892132105563377310203897753966350743874679104628321785862987706430998848051299468409157327409929019736966482807332241638171032488791288702638854996896008055380420273360334533680833179185524820732104480666659321861366843400175400593725077960919448688150587388484016394469887799115548829
c1th = 34434392180151160913417544852616971692121904677314473399957347521083237373034994312975350004829141725822217771937654823384811574065863494723195053499396034949290411943322317170325058243501037304118017625559902628138026099775011556912632571666551501574674149399754491989755975771939193289559108779735832803131353873359793188227274679870124905519577462789862633176435874379040514994389592895575023493569300837110208625710266981571291166908408795186263690648761483931536077993683195891166866749702144363195471519064199405194909234060054947618318112220998235092847932193233297870660035092387998034397222343161862784190790234800655328367322488558923652724216788
c2nd = 2607182269911588640317443768516313475146031043011942375047416295563239497652683572392929453795834334601092180070778075446956225213228673291202712614851722328808263442169879046516657696381344172034458368689995793563352685120784745264814592735479698208625232292101406540095075755385738751964408524935105574210332493169531158694712409957008980603987021669723807161080311585592233184680564859608827956836072947637991546257832547921898039818720396103470292159465748053549459040177976994334908062142249458811885621719209965027537964222416346303361195322236614316663222188005352271974634346800843280024794327865267659775840158740927725776164466534809032826708671
p3rd = 34625024969762267128651307772809623649843622265032692142413571471210174269061639087466847081494470128344958794692961988682025560523709683489711068300641190919761862123159064271694245866486251838863170363349568878104217

r = p3rd
r_1 = r-1
t = int("333"*33) // 362853724342990469324766235474268869786311886053883 // 1344628210313298373
cofactor = r_1 // t

m_t = discrete_log(Mod(pow(c2nd,cofactor,p3rd),p3rd), Mod(pow(3,cofactor,p3rd),p3rd), ord = t)

PR.<x> = PolynomialRing(Zmod(r))
f = x^3 - c1th
m_rs = f.roots()
for i in m_rs:
    m_r = int(i[0])
    m_rt = crt([m_t,m_r], [t,r])
    ll = len(bin(m_rt)[2:])

    PR1.<m> = PolynomialRing(Zmod(nss // r))
    f1 = (m*r*t + m_rt)^3 - c1th
    f1 = f1.monic()
    res = f1.small_roots(X=2^((3*3*3*3 + 33 + 3*3*3 + 3*3 + 3) * 8 - ll), beta=1, epsilon=0.05)
    if(res != []):
        print(long_to_bytes(int(res[0])*r*t + m_rt))
        break


#NSSCTF{Rea1lY_EZ_Ch3ck1n_4nd_H4ve_FUN!}
```
