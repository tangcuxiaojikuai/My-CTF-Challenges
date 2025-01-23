from Crypto.Util.number import *
from secret import flag
from sympy import *

p = 0
for a in range(2**20):
            for b in range(2**20):
                        for c in range(2**20):
                                    for d in range(2**20):
                                                for e in range(2**20):
                                                            for f in range(2**20):
                                                                        for g in range(2**20):
                                                                                    for h in range(2**20):
                                                                                                for i in range(2**20):
                                                                                                            for j in range(2**20):
                                                                                                                        for k in range(2**20):
                                                                                                                                    for l in range(2**20):
                                                                                                                                                for m in range(2**20):
                                                                                                                                                            for n in range(2**20):
                                                                                                                                                                        for o in range(2**20):
                                                                                                                                                                                    for q in range(2**20):
                                                                                                                                                                                                for r in range(2**20):
                                                                                                                                                                                                            for s in range(2**20):
                                                                                                                                                                                                                        for t in range(2**20):
                                                                                                                                                                                                                                    if(a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+q+r+s+t == 2**20
                                                                                                                                                                                                                                                and 2**1 <= a <= 2**11
                                                                                                                                                                                                                                                and 2**2 <= b <= 2**12
                                                                                                                                                                                                                                                and 2**3 <= c <= 2**13
                                                                                                                                                                                                                                                and 2**4 <= d <= 2**14
                                                                                                                                                                                                                                                and 2**5 <= e <= 2**15
                                                                                                                                                                                                                                                and 2**6 <= f <= 2**16
                                                                                                                                                                                                                                                and 2**7 <= g <= 2**17
                                                                                                                                                                                                                                                and 2**8 <= h <= 2**18
                                                                                                                                                                                                                                                and 2**9 <= i <= 2**19
                                                                                                                                                                                                                                                and j == ord("🚩")
                                                                                                                                                                                                                                                and 2**9 <= k <= 2**19
                                                                                                                                                                                                                                                and 2**8 <= l <= 2**18
                                                                                                                                                                                                                                                and 2**7 <= m <= 2**17
                                                                                                                                                                                                                                                and 2**6 <= n <= 2**16
                                                                                                                                                                                                                                                and 2**5 <= o <= 2**15
                                                                                                                                                                                                                                                and 2**4 <= q <= 2**14
                                                                                                                                                                                                                                                and 2**3 <= r <= 2**13
                                                                                                                                                                                                                                                and 2**2 <= s <= 2**12
                                                                                                                                                                                                                                                and 2**1 <= t <= 2**11):
                                                                                                                                                                                                                                                p += 1

m = bytes_to_long(flag)
n = nextprime(p)*getPrime(256)
c = pow(m,65537,n)

print("n =",n)
print("c =",c)


'''
n = 162917824250624428770847214526766153715994730770828294223045145782361053118639752515448191168318791581379714281400019977395626358004912238500194006293059
c = 122406161670580331591403173748658855680897827252661396790491763445171793944030771193413106560964524799938825689332487037104687390956044492567123541927155
'''