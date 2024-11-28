from Crypto.Util.number import *
from random import *
from secret import flag
from os import urandom
from random import *

def pad(c,l):
    return c + urandom(l-len(c))

def getPrime3(bits):
    while(1):
        p = int("333"*33)*getrandbits(bits-333) + 1
        if(isPrime(p)):
            return p

p1th = getPrime(3*3*3*3*3*3)
p2nd = getPrime(3*3*3*3*3*3)
p3rd = getPrime3(3*3*3*3*3*3)
nss = p1th*p2nd*p3rd
m = bytes_to_long(pad(flag,3*3*3*3 + 33 + 3*3*3 + 3*3))

print("nss =", nss)
print("c1th =", pow(m,3,nss))
print("c2nd =", pow(3,m,nss))
print("p3rd =", p3rd)


'''
nss = 129063444400395931140552937306125851382394430986439278160593873744789936793795518045323178995007062628298309773582176239691459885773526624534690277511861861603281624682554253545227928169748182762012056234854538541309647111293806528166653033498149834445725530659660926127593831428768095049111056550293489376446453196283413940748453177975852069148305909986767912740830549027892132105563377310203897753966350743874679104628321785862987706430998848051299468409157327409929019736966482807332241638171032488791288702638854996896008055380420273360334533680833179185524820732104480666659321861366843400175400593725077960919448688150587388484016394469887799115548829
c1th = 34434392180151160913417544852616971692121904677314473399957347521083237373034994312975350004829141725822217771937654823384811574065863494723195053499396034949290411943322317170325058243501037304118017625559902628138026099775011556912632571666551501574674149399754491989755975771939193289559108779735832803131353873359793188227274679870124905519577462789862633176435874379040514994389592895575023493569300837110208625710266981571291166908408795186263690648761483931536077993683195891166866749702144363195471519064199405194909234060054947618318112220998235092847932193233297870660035092387998034397222343161862784190790234800655328367322488558923652724216788
c2nd = 2607182269911588640317443768516313475146031043011942375047416295563239497652683572392929453795834334601092180070778075446956225213228673291202712614851722328808263442169879046516657696381344172034458368689995793563352685120784745264814592735479698208625232292101406540095075755385738751964408524935105574210332493169531158694712409957008980603987021669723807161080311585592233184680564859608827956836072947637991546257832547921898039818720396103470292159465748053549459040177976994334908062142249458811885621719209965027537964222416346303361195322236614316663222188005352271974634346800843280024794327865267659775840158740927725776164466534809032826708671
p3rd = 34625024969762267128651307772809623649843622265032692142413571471210174269061639087466847081494470128344958794692961988682025560523709683489711068300641190919761862123159064271694245866486251838863170363349568878104217
'''