from Crypto.Util.number import *
from random import *
from secret import flag

assert flag.startswith(b"NSSCTF{") and flag.endswith(b"}")
assert len(flag) == 37

def gen_data(p,length):
    coeff = [randint(-2**32,2**32) for i in range(length-1)] + [randint(1,2**32)]
    return sum([coeff[i]*p**i for i in range(length)])

b = getPrime(1400)
a = gen_data(b,6)
p = getPrime(256*5)
q = getPrime(256)
n = p*q
m = bytes_to_long(flag[7:-1])

print("a =",a)
print("b =",b)
print("n =",n)
print("c =",a % (b-m) % p)


'''
a = 5549997533567190765451060003378594328208085965171057613046272782399320385801262427125465925310587069826816190505343998268891453664853919954972318043604177749860432778530185933735996050024160286370510179686746394158379258246587487978911503057556662561587215910791569507689015766531668277131113986057590781396398336299292315557904756600303993655014781202374308079885517355500419820878630803963625154724593589268277135757575099029314373537333985928427361897778453968429622806601778705482232467565493789524705788745221275426482603133790789320192127238641529684801868328091692081269798378555677980295282241736002111769899269365161305274768242912746034221266737507823710607682307448305506469386320122162063129111963956813928790055972563594890074229166442357508298255754150913934863439503751818506701092029312330070104636530223422238884679342877228773018649571938389437053258838947075103547766682006907290041060099030401078504154580918834901230411520541473984503892569919351799880236285333890681120340758177935223362561618860440679402085624994947954310720781671847323988290985994849577007330168617301104973145130975458942852068773890456852008660678772797081769299221752824132395057925957966236190693386264986627705062247274388532481890731361579962994281795847973719352965725024336536011747744286094626784548450945808977185031072003163884715639335582500821735372264778337277968982744615544014751382104123657815885683865159874330848264901320900587726777026680111663529893241507534145907710815328515080873983547987954554660585289621642017226020909406358582195295944513518489513783744170261194300084082634297086645338918551616443632828664857206551814971287007726341429714596407033649324399745531577851802389713905682407743356548494218886990858323750912334486066574949941863337284447418868362349705104596997062541665923824132293441261853623963153677146052741893849156220411360012198280306111549261407941431691085949136294791896025980996617245031309439043593114299292206028201810212469726512376109348231607843056259556121448353511032010729667364764526544162088652166231118576736952880650975321889920727908566750809108688218503956
b = 19088700216864219992000481909154962955010217153589993304722719340884054355376558326105036947257582728860147557431276912919643940358478125733042829478349114754313750607492935206321298801011776939307313478546331523512938761672813983870399597182080005906066953602228332948790458576153448761425614070248334986663583719133564252378947422392557755444674008030141846366476287826338519233008704965899055639264609925259823048079319
n = 1698281899194715114165111012319277103359733674717346894156321734086384210027912893592223341535254583183189375047805019470712423207121454213625786296403115965465797639874678119529865412063714723513964182015925137173277042639307327631371055326412204990172328114832185024332076266014268385262996787504249248741895102659976146333218908476195041388126877183421158327681480273218635257896126985050902620483850502219753728842322424353423665711001628722961510508066740039
c = 53146904354859601599585110457067111012858829248246133531123405294986679458995718625053726629192021849150034273282207940006128865030953003797480171720673649060942787124637476440400908506795533118278613492356804275358218541297790334587524059713360959881377651255593428483947657195937373058321156413003347566693680573881827047037751088091600420762361729539354
'''