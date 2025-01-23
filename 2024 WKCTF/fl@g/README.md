## fl@g

+ Difficulty：Easy
+ Solved：25

<br/>

## Solution

题目内容很简单，对下面的字符表做全排列：

```python
table = string.ascii_letters + string.digits + "@?!*"
```

然后将num置为0，对于每个排列对应的字符串，如果其中含有下面几个字符串的任意一个，num就加1：

```python
"flag" , "FLAG" , "f14G" , "7!@9" , "🚩"
```

取最终的num值得的nextprime作为素数p，和另一个300bit的随机素数q组成模数n进行RSA加密，要求还原flag。

注意到题目甚至给了tqdm，直接运行一下看看：

```python
  0%| | 4924893/544344939077443064003729240247842752644293064388798874532860126869671081148416000000000000000 [00:02<8575920132509507371641612729862070066331081369915450517599590325456
```

好像并不是很能接受哈哈哈，所以是要想办法用其它的办法计算出来。

这其实是一个经典的容斥定理的运用，首先可以看出来，🚩这个完全是放出来整活的，不会对num的值产生任何影响。所以关键就在于前四个字符串对应的事件。不妨记以下四个集合：

```python
A1 : 排列的字符串中含有"flag"
A2 : 排列的字符串中含有"FLAG"
A3 : 排列的字符串中含有"f14G"
A4 : 排列的字符串中含有"7!@9"
```

而由题目，我们要计算的值就是：
$$
num = |A_1 \cup A_2 \cup A_3 \cup A_4 |
$$
由容斥原理，这个值就等于：
$$
|A_1 \cup A_2 \cup A_3 \cup A_4 | = |A_1| + |A_2| + |A_3| + |A_4| \\
- |A_1 \cap A_2| - |A_1 \cap A_3| - |A_1 \cap A_4| - |A_2 \cap A_3| - |A_2 \cap A_4| - |A_3 \cap A_4| \\
+ |A_1 \cap A_2 \cap A_3| + |A_1 \cap A_2 \cap A_4| + |A_1 \cap A_3 \cap A_4| + |A_2 \cap A_3 \cap A_4| \\
- |A_1 \cap A_2 \cap A_3 \cap A_4|
$$
所以分别计算每个集合的大小就可以得到num，之后取nextprime分解掉n，最后解RSA就好了。

exp：

```python
from Crypto.Util.number import *
from math import *
import string
import gmpy2

table = string.ascii_letters + string.digits + "@?!*"

LENGTH = len(table)

#"flag" in temp or "FLAG" in temp or "f14G" in temp or "7!@9" in temp or "🚩" in temp
A = factorial(LENGTH-4+1)
B = factorial(LENGTH-4+1)
C = factorial(LENGTH-4+1)
D = factorial(LENGTH-4+1)

AB = factorial(LENGTH-4*2+2)
AC = 0
AD = factorial(LENGTH-4*2+2)
BC = 0
BD = factorial(LENGTH-4*2+2)
CD = factorial(LENGTH-4*2+2)

ABC = 0
ABD = factorial(LENGTH-4*3+3)
ACD = 0
BCD = 0

ABCD = 0

p = gmpy2.next_prime(A+B+C+D-AB-AC-AD-BC-BD-CD+ABC+ABD+ACD+BCD-ABCD)
#7930399977709836210408886944838540258627004066353629452237535203485317857280000000000083


n = 10179374723747373757354331803486491859701644330006662145185130847839571647703918266478112837755004588085165750997749893646933873398734236153637724985137304539453062753420396973717
c = 1388132475577742501308652898326761622837921103707698682051295277382930035244575886211234081534946870195081797116999020335515058810721612290772127889245497723680133813796299680596

q = n // p

print(long_to_bytes(gmpy2.powmod(c,inverse(65537,(p-1)*(q-1)),n)))


#WKCTF{How_long_does_it_take_to_run_directly?}
```

