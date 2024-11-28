from Crypto.Util.number import *
from itertools import *
from tqdm import *


PR.<x> = PolynomialRing(GF(2))
G = x^256 + x^255 + x^254 + x^251 + x^250 + x^246 + x^245 + x^243 + x^242 + x^240 + x^239 + x^238 + x^236 + x^235 + x^234 + x^233 + x^232 + x^230 + x^229 + x^221 + x^220 + x^218 + x^213 + x^210 + x^208 + x^207 + x^203 + x^200 + x^198 + x^197 + x^194 + x^192 + x^191 + x^190 + x^189 + x^185 + x^184 + x^180 + x^179 + x^178 + x^177 + x^175 + x^174 + x^173 + x^172 + x^171 + x^170 + x^169 + x^167 + x^165 + x^164 + x^161 + x^160 + x^159 + x^157 + x^154 + x^151 + x^149 + x^148 + x^144 + x^142 + x^139 + x^138 + x^137 + x^133 + x^132 + x^130 + x^129 + x^126 + x^125 + x^123 + x^122 + x^120 + x^119 + x^118 + x^117 + x^115 + x^114 + x^113 + x^112 + x^109 + x^108 + x^107 + x^106 + x^105 + x^103 + x^101 + x^99 + x^98 + x^97 + x^94 + x^91 + x^90 + x^89 + x^88 + x^83 + x^82 + x^80 + x^79 + x^73 + x^71 + x^68 + x^67 + x^65 + x^61 + x^59 + x^58 + x^56 + x^55 + x^54 + x^51 + x^49 + x^48 + x^46 + x^44 + x^42 + x^41 + x^40 + x^39 + x^38 + x^37 + x^34 + x^33 + x^32 + x^30 + x^29 + x^28 + x^27 + x^26 + x^25 + x^23 + x^22 + x^15 + x^14 + x^13 + x^12 + x^10 + x^8 + x^7 + x^4 + x^3 + x + 1
c = x^249 + x^248 + x^246 + x^244 + x^243 + x^242 + x^239 + x^238 + x^237 + x^232 + x^230 + x^229 + x^228 + x^226 + x^225 + x^223 + x^222 + x^221 + x^220 + x^218 + x^217 + x^215 + x^214 + x^207 + x^206 + x^204 + x^202 + x^201 + x^200 + x^198 + x^197 + x^196 + x^193 + x^191 + x^188 + x^186 + x^185 + x^184 + x^183 + x^177 + x^172 + x^171 + x^170 + x^169 + x^167 + x^166 + x^165 + x^164 + x^162 + x^161 + x^160 + x^158 + x^156 + x^155 + x^154 + x^151 + x^148 + x^146 + x^145 + x^144 + x^143 + x^142 + x^140 + x^139 + x^135 + x^134 + x^132 + x^131 + x^126 + x^122 + x^121 + x^120 + x^119 + x^115 + x^113 + x^110 + x^109 + x^107 + x^106 + x^105 + x^104 + x^103 + x^102 + x^101 + x^100 + x^98 + x^94 + x^93 + x^92 + x^90 + x^89 + x^87 + x^84 + x^81 + x^80 + x^79 + x^77 + x^75 + x^74 + x^71 + x^70 + x^68 + x^67 + x^66 + x^65 + x^64 + x^62 + x^60 + x^59 + x^57 + x^55 + x^54 + x^53 + x^52 + x^51 + x^50 + x^49 + x^46 + x^45 + x^44 + x^43 + x^42 + x^41 + x^40 + x^39 + x^38 + x^35 + x^34 + x^30 + x^28 + x^27 + x^24 + x^23 + x^20 + x^18 + x^17 + x^16 + x^13 + x^12 + x^11 + x^10 + x^7 + x^5 + x^4 + x^3 + 1
v = G.list()
vec_c = c.list() + [0]*(256-len(c.list()))

#part1 construct a matrix of mod G
n = 256
m = 45*8
mat = Matrix(GF(2),m,n)
for i in range(n):
    mat[i,i] = 1
for i in range(n,m):
    for j in range(i-n,n):
        mat[i,j] = -v[j-(i-n)]
    
    init_row = vector(ZZ,n*[0])
    for j in range(i-n):
        temp = -v[n-1-j]*vector(ZZ,mat[i-j-1])
        init_row += temp
    for j in range(n):
        mat[i,j] += init_row[j]   


#part2 fix some bits(prefix suffix and every byte's MSB 0)
#prefix
prefix = b"flag{"
prefix_bin = bin(bytes_to_long(prefix))[2:].zfill(len(prefix)*8)
for i in range(len(prefix_bin)):
    extend = vector(GF(2),[0]*(m-1-i) + [1] + [0]*i)
    mat = mat.augment(extend)
    vec_c.append(int(prefix_bin[i]))
#suffix
suffix = b"}"
suffix_bin = bin(bytes_to_long(suffix))[2:].zfill(len(suffix)*8)[::-1]
for i in range(len(suffix_bin)):
    extend = vector(GF(2),[0]*i + [1] + [0]*(m-1-i))
    mat = mat.augment(extend)
    vec_c.append(int(suffix_bin[i]))
#every byte's MSB 0
length = 45 - len(prefix) - len(suffix)
for i in range(length):
    extend = vector(GF(2),[0]*(16+8*i-1) + [1] + [0]*(m-16-8*i))
    mat = mat.augment(extend)
    vec_c.append(0)


#part3 find solution in solution space
sol = mat.solve_left(vector(GF(2),vec_c))
ker = mat.left_kernel().basis()
for i in product([0,1],repeat=(mat.dimensions()[0]-mat.dimensions()[1])):
    temp = 0
    for j in range(len(i)):
        temp += i[j]*ker[j]
    final = sol + temp
    flag = ""
    for i in final:
        flag += str(i)
    flag = str(long_to_bytes(int(flag[::-1],2)))[2:-1]
    if(len(flag) == 45):
        print(flag)
        break


#flag{W0W!!_U_r3c0v3r_fl4g_fr0m_qu0ti3nt_Ring}