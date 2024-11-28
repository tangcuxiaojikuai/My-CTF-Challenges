from sage.all import *
from sage.stats.distributions.discrete_gaussian_integer import DiscreteGaussianDistributionIntegerSampler
from secret import flag

std_limit = 0.01


def get_accurate_Discrete_Gaussian(sigma, limit=std_limit):
    factor = 1
    while True:
        Df = DiscreteGaussianDistributionIntegerSampler(sigma * factor)
        if abs(RR(std([Df() for _ in range(2 ** 15)])) - sigma) / sigma < limit:
            return Df
        factor += 0.01


def ZZ_to_Fq(_vector, _q, _n):
    return [int(i % _q) if abs(_q - int(i % _q)) > int(i % _q) else (int(i % _q) - _q) for i in _vector] + [0] * (
            _n - len(_vector))


def My_generator(Sampler, _n, limit=std_limit):
    while True:
        tmp = [Sampler() for _ in range(_n)]
        if abs(RR(std(tmp)) - Sampler.sigma) < limit:
            return tmp


def generate_key():
    while True:
        F = Matrix([[PRz(My_generator(Df, d)) for _ in range(n)] for _ in range(n)])
        G = Matrix([[PRz(My_generator(Df, d)) for _ in range(k)] for _ in range(n)])
        try:
            H = F.change_ring(PRqm).inverse() * G.change_ring(PRqm)
            H = Matrix([[PRz(Hij.lift()) for Hij in Hi] for Hi in H.transpose()]).transpose()
            return F, G, H
        except ArithmeticError:
            continue


d = 64
q = 12289
p = 17
n = 2
k = 1
sigma_f, sigma_s, sigma_e = 0.4, 0.6, 0.6

PRq = PolynomialRing(Zmod(q), 'xq')
PRp = PolynomialRing(Zmod(p), 'xp')
PRz = PolynomialRing(ZZ, 'xz')
mod_polynomial = PRz.cyclotomic_polynomial(d * 2)
PRqm = PRq.quotient(mod_polynomial)
PRpm = PRp.quotient(mod_polynomial)
Df = get_accurate_Discrete_Gaussian(sigma_f)
Ds = get_accurate_Discrete_Gaussian(sigma_s)
De = get_accurate_Discrete_Gaussian(sigma_e)
m = []
base = int.from_bytes(flag, byteorder='big')
while base > 0:
    m.append(int(base % p))
    base = base // p
m = PRz(m)

s = vector([PRz(My_generator(Ds, d)) for _ in range(n)])
e = PRz(My_generator(Ds, d))

############################################################ Fixed
F, G, H = generate_key()
m = PRqm(m.list())
e = PRqm(e.list())
s = s.change_ring(PRqm)
HH = H.change_ring(PRqm)
c = (p*(HH.T)*s)[0] + p*e + m
c = PRz(c.list())
############################################################ Fixed End

open('data.txt', 'w').write('H = ' + str([list(vi) for vi in H]) + '\n' + 'c = ' + str(c) + '\n')