## 3DES

+ Difficulty：Middle
+ Solved：1

<br/>

## Description

三个DES

<br/>

## Hint

+ 怎么爆破会好一点呢？
+ correlation attack
+ 打印Geffe生成器的真值表进行观察
+ DES的密钥似乎并不是每一位都有用


<br/>

## Solution

题目分别初始化三个DES，其密钥由8个数字组成。而每个DES执行的其实是流密钥的功能，也就是对于他的每一次输出，都是将种子进行一次DES加密得到新的种子，并且取其LSB作为该次流密钥的输出。

但是题目是将三个DES的流密钥进行combine之后输出的，共给出两百位输出序列，要求还原三个DES的密钥来解密得到flag。

注意到题目combine的方式是：
$$
x = x_1x_2 \oplus x_2x_3 \oplus x_3
$$
这其实是一个Geffe生成器，而他一个很脆弱的地方在于：他的输出与x1、x3都有相关性。打印真值表可以发现，对于Geffe生成器的每一位输出，都有75%的概率与x1相同或与x3相同，所以我们就可以分开爆破DES1和DES3的密钥，去观测其输出是否与200位给定的序列有接近75%的相似度，来判断密钥的正确性。

有了这个思路过后，剩下的问题就是如何爆破。由于题目的DES密钥均为8位数字组成，所以需要爆破的可能组合共有10^8种，复杂度依然比较高。但是需要注意到，DES的八字节密钥实际参与加密的只有56位，因为每个第8bit实际上本来是作为校验位的，在产生轮密钥之前就会被去掉，因此实际需要爆破的仅有5^8种可能。同时，由于正确密钥的输出应该和output有75%左右的相似度，因此200个比特基本上已经很难再有误判的可能性，并不需要把给出的2000bit全部用上，所以就只需要两分多钟就可以爆破出来DES1、DES3的密钥了。

有了正确的DES1、DES3的密钥，又有种子"!NSSCTF!"，就有了他们对应的两百位输出x1、x3，那么爆破x2就只需要看combine之后的结果是否与output完全相等即可。同时，由于密钥错误但依然连续50位均相等的概率已经非常低，所以只取前五十位参与爆破可以节省时间。

exp：

```python
from Crypto.Util.number import *
from Crypto.Cipher import DES
from itertools import product
from tqdm import *

output = "10110101110110001000111000110101000110111100110110011010000010001110010010101111000101101100101011110101111011000000001110011001011001110010010000001010111101011110011011000111011101010000111011011110010001101001110010111100101111110001000110000110111010100010111010000110000001011010111100100011011010001101001001100000000001100101111110110011000101101100110101010000010101100001010010000010010011001011110000010101111000001110010100110110111011001010111111100010100111000110110010101101000001011000101110101100000110110000101101010100101010000100110011011110100110111101101100011100011100101000000100000000101001100101001010101001000110011110110000111111001111101110110110100001010000100110010100010101000001010001111100000010100000101101111010010011010100011000100111001101100001011111001100111101100011001001000001000100011011010000001101110000001111011000111000011001010011100110110111111101010110101110110110000101110110000000101110000011110101001100010000101001010010000011110111100001101011001110100011101111011001010110111000010000111000010010111111111000111100110000100100100011111100101111011001000000011000001100110100011100110010100010001110011001011100101001101001100110001010000011001001101010010101001111110100010111000000101011000100100000010011111011001011010001101101101001100111010110101001001111000111000001000001010000001100101110110010111111001001011111111000100110011100011000111011010100001011010000011110101001110101010011111000100010011010000101011100110110101000100010010001011101010010100100001011010101000010000110001100100010000010111110011111000011000100011001110001100100111111101000001001101110000100101011010010011001100100100100010000101100111001100110000110010001001010011011011101011010100110001100001000111010000100100100010110111100000100111010101100000111010111011000100011010111110010010000110111111001101000011111000111100110111110011110101001100110111000111111011010011100011000010010011010100000100110010011111011110111011111011011110010110000110011110000"
cipher = b'\xe3\t\x13\xe2\x8b\xd1\xdeql\x94F\xb5}\xb8d\xfa~\x06&~\x8f\xcb-&\xf3q/j\xd3\xbe\x1f\xef\x18\x84hn\x1c[t\x03\x10\xb8\x8e?\x89\x8b\x00\xc5\xb9`5E\xeaC\xe9,'

def compare(str1,str2):
    assert len(str1) == len(str2)
    count1 = 0
    for i in range(len(str1)):
        if(str1[i] == str2[i]):
            count1 += 1
    if(count1 / len(str1) > 0.7):
        return True
    else:
        return False

#part1 remove redundant data of table
table = "0123456789"
prefix_set = []
for i in table:
    temp = bin(ord(i) // 2)[2:].zfill(7)
    if(temp not in prefix_set):
        prefix_set.append(temp)


#part2 bruteforce LFSR1.key and LFSR3.key
key13 = []
for i in tqdm(product(prefix_set,repeat = 8),total=5**8):
    temp = ''.join(c + '0' for c in list(i))
    key = long_to_bytes(int(temp,2))

    DES1 = DES.new(key,mode=DES.MODE_ECB)

    seed = b"!NSSCTF!"
    output1 = ""
    for j in range(200):
        seed = DES1.encrypt(seed)
        output1 += str(bytes_to_long(seed) & 1)
    if(compare(output[:200],output1)):
        key13.append(key)


#part3 bruteforce LFSR2.key and decrypt
def combine(x1,x2,x3):
    return (x1&x2)^(x2&x3)^x3


#DES1 = DES.new(key13[0],mode=DES.MODE_ECB)
#DES3 = DES.new(key13[1],mode=DES.MODE_ECB)
DES1 = DES.new(key13[1],mode=DES.MODE_ECB)
DES3 = DES.new(key13[0],mode=DES.MODE_ECB)
for i in tqdm(product(prefix_set,repeat = 8),total=5**8):
    temp = ''.join(c + '0' for c in list(i))
    key = long_to_bytes(int(temp,2))

    DES2 = DES.new(key,mode=DES.MODE_ECB)

    seed1 = b"!NSSCTF!"
    seed2 = b"!NSSCTF!"
    seed3 = b"!NSSCTF!"
    judge = True
    for j in range(50):
        seed1 = DES1.encrypt(seed1)
        seed2 = DES2.encrypt(seed2)
        seed3 = DES3.encrypt(seed3)
        temp = combine(bytes_to_long(seed1) & 1 , bytes_to_long(seed2) & 1 , bytes_to_long(seed3) & 1)
        if(str(temp) != output[j]):
            judge = False
            break

    if(judge):
        flag = DES3.decrypt(cipher)
        flag = DES2.decrypt(flag)
        flag = DES1.decrypt(flag)
        print(flag)
        break


#NSSCTF{Y0U_C411_Th15_3DES???_;D_J4st_U53_CorreL@tion!}
```

