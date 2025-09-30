from functools import reduce
from random import choice
from secret import flag

le4t = lambda x: "".join(choice(next((j for j in ['a@4A', 'b8B', 'cC', 'dD', 'e3E', 'fF', 'g9G', 'hH', 'iI', 'jJ', 'kK', 'l1L', 'mM', 'nN', 'o0O', 'pP', 'qQ', 'rR', 's$5S', 't7T', 'uU', 'vV', 'wW', 'xX', 'yY', 'z2Z'] if i in j), i)) for i in x.decode())
h4sH = lambda x: reduce(lambda acc, i: ((acc * (2**255+95)) % 2**256) + i, x, 0)

print(le4t(flag), h4sH(flag))
#nSsCtf{H@pPy_A7h_4nNiv3R$arY_ns$C7F_@nD_l3t$_d0_7h3_LllE3t$pEAk!} 9114319649335272435156391225321827082199770146054215376559826851511551461403