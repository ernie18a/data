<!-- tradingview-pine-id: PUB;421de405ef9a4f488ae15cf1220ccf9e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Zeiierman Bands (Zeiierman)

Source: https://www.tradingview.com/script/YtNcfY4g-Zeiierman-Bands-Zeiierman/

## Description

█ Overview
Zeiierman Bands (Zeiierman) is an adaptive liquidity-band indicator designed to visualize price equilibrium, liquidity stress, directional pressure, and mean-reversion opportunities directly around price.

Instead of using a standard moving average with symmetrical volatility bands, the indicator builds a custom Liquidity Mean using price, volume participation, candle range, wick behavior, and liquidity interaction. The upper and lower bands then adapt independently depending on the stress developing on each side of the market.
[image]https://www.tradingview.com/x/HK2DNVCz/[/image]
A higher-timeframe Liquidity Tension model colors the bands:

• Bull Color = positive directional pressure
• Bear Color = negative directional pressure
• Neutral Color = insufficient directional pressure

Reclaim triangles identify situations where price reaches a liquidity extreme and then begins moving back toward equilibrium.
[image]https://www.tradingview.com/x/0pgjEFSL/[/image]
█ How It Works
⚪ Liquidity Mean
Volume participation is compared with candle movement to estimate liquidity acceptance. Wick behavior is then used to adjust the price being weighted into the mean.
[pine]acceptance = relativeVolume / relativeRange[/pine]
The result is a liquidity-weighted equilibrium instead of a conventional moving average.

⚪ Asymmetric Liquidity Bands
Upside and downside deviation are calculated separately using normal price dispersion, wick activity, and liquidity stress.
[pine]upper = mean + deviation * upperStress
lower = mean - deviation * lowerStress[/pine]
This allows one side of the bands to expand more than the other when liquidity pressure becomes uneven.

⚪ Liquidity Color
The color engine compares price with the previous completed candle from the selected higher timeframe and combines that position with Path Efficiency.
[pine]normalizedPosition = 2 * (close - htfMid) / htfRange
rawTension = normalizedPosition * pathEfficiency[/pine]
Persistent positive tension creates the Bull regime, persistent negative tension creates the Bear regime, and weaker conditions remain Neutral.

⚪ Reclaim Signals
A reclaim setup becomes armed after price reaches an outer liquidity extreme. The signal appears when price then reclaims the inner band toward the Liquidity Mean.
[pine]longReclaim  = armedLong  and crossover(z, -reclaimLevel)
shortReclaim = armedShort and crossunder(z, reclaimLevel)[/pine]
The optional OU Filter removes reclaims when the current environment does not behave sufficiently like a mean-reverting process.

When Align Reclaims With Trend is enabled, Long Reclaims are allowed only during the Bull regime and Short Reclaims only during the Bear regime.
█ How to Use
Bull-colored bands indicate positive higher-timeframe Liquidity Pressure, while Bear-colored bands indicate negative Liquidity Pressure. Neutral bands indicate that directional pressure is not strong enough to establish either regime.
[image]https://www.tradingview.com/x/NZlgvd6J/[/image]
⚪ Bullish Setup
If the bands are blue, look for rejection from the lower bands. These areas can act as potential bounce zones because the setup is aligned with higher-timeframe liquidity pressure.
[image]https://www.tradingview.com/x/5tRzWyjN/[/image]
⚪ Bearish Setup
If the bands are yellow, look for rejection from the upper bands. These areas can act as potential rejection zones because the setup is aligned with higher-timeframe liquidity pressure.
[image]https://www.tradingview.com/x/Q0kKRCYo/[/image]
⚪ Volatility Contraction & Expansion
When the bands begin to contract, volatility is decreasing, and price is becoming more compressed. This can signal that the market is building toward a larger move.

A breakout followed by band expansion shows that volatility is increasing and price is moving out of the compressed range.

⚪ Bearish Setup
In this example, the bands contract before price breaks lower. The bands then expand as bearish momentum accelerates, confirming the volatility expansion and continuation of the move.
[image]https://www.tradingview.com/x/EGLNUfjc/[/image]
⚪ Bullish Setup
In this example, the bands contract as price consolidates and volatility decreases. Price then breaks higher and the bands expand as bullish momentum increases. A second contraction develops before another breakout, followed by a stronger volatility expansion and continuation of the bullish move.
[image]https://www.tradingview.com/x/xceblaAb/[/image]
█ Settings

[*]Length: Controls the primary calculation window.
[*]Deviation: Controls the distance of the outer bands.
[*]Reclaim Ratio: Controls the position of the inner reclaim bands.
[*]Use OU Filter: Enables the mean-reversion filter for reclaim signals.
[*]OU Strictness: Controls how selective the OU filter is.
[*]Color Timeframe: Selects the timeframe used by the Liquidity Color Engine.
[*]Auto Color Timeframe: Automatically moves the color engine higher according to the timeframe mapping.
[*]Path Efficiency Length: Controls how price travel efficiency is measured.
[*]Tension Build Length: Controls how quickly directional tension strengthens.
[*]Tension Release Length: Controls how quickly tension fades or reverses.
[*]Maximum Tension: Caps the Liquidity Tension value.
[*]Trend Tension Threshold: Determines when Bull or Bear coloring becomes active.
[*]Reclaim Signals: Shows or hides reclaim signals and their reclaim alerts.
[*]Align Reclaims With Trend: Allows Long Reclaims only in the Bull regime and Short Reclaims only in the Bear regime.
[*]Fill Bands: Shows or hides the area between the outer bands.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
//@version=6
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
indicator("Zeiierman Bands (Zeiierman)", overlay=true, behind_chart=false, dynamic_requests=true)
//}

// ~~ Tooltips {
var string t1="Rolling window used by the custom liquidity mean, stress deviation, sweep horizon and OU model."
var string t2="Outer band distance. Higher values place the outer bands farther from the custom mean."
var string t3="Places the inner reclaim bands as a fraction of the outer deviation."
var string t4="Enables the OU mean-reversion regime filter for reclaim triangles."
var string t5="Controls how selective the OU filter is. Higher values require faster reversion and lower equilibrium drift."
var string t6="Base timeframe used by the Liquidity Warp color engine. When Auto color timeframe is on and the chart timeframe equals this base timeframe, coloring steps up using the fixed auto map."
var string t7="Measures how directly price travelled. Exact Liquidity Warp path-efficiency input."
var string t8="Controls how quickly persistent liquidity separation builds into the color state."
var string t9="Controls how quickly the color tension releases or reverses."
var string t10="Caps the Liquidity Warp tension state."
var string t11="Tension required before the bands switch from neutral to bull or bear coloring."
var string t12="Colors used by the Liquidity Warp neutral, bull and bear states."
var string t13="Color of confirmed reclaim triangles."
var string t14="Enables or disables reclaim triangles and reclaim alerts."
var string t15="When enabled, long reclaims require the bullish liquidity color regime and short reclaims require the bearish liquidity color regime."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Groups {
gB="1. Band Behavior"
gO="2. OU Filter"
gC="3. Liquidity Color Engine"
gS="4. Colors & Style"
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
n=input.int(20,"Length",minval=10,group=gB,tooltip=t1)
m=input.float(2.0,"Deviation",minval=0.5,step=0.1,group=gB,tooltip=t2)
r=input.float(0.75,"Reclaim Ratio",minval=0.25,maxval=0.95,step=0.05,group=gB,tooltip=t3)
ou=input.bool(true,"Use OU Filter",group=gO,tooltip=t4)
os=input.float(0.5,"OU Strictness",minval=0.1,maxval=2.0,step=0.1,group=gO,tooltip=t5)
ct=input.timeframe("60","Color timeframe",group=gC,tooltip=t6)
at=input.bool(true,"Auto color timeframe",group=gC)
el=input.int(3,"Path efficiency length",minval=2,maxval=200,group=gC,tooltip=t7)
bl=input.int(6,"Tension build length",minval=1,maxval=100,group=gC,tooltip=t8)
rl=input.int(20,"Tension release length",minval=1,maxval=100,group=gC,tooltip=t9)
mt=input.float(8.25,"Maximum tension",minval=0.25,maxval=10.0,step=0.25,group=gC,tooltip=t10)
rt=input.float(0.20,"Trend tension threshold",minval=0.05,maxval=2.0,step=0.05,group=gC,tooltip=t11)
nc=input.color(color.silver,"Neutral color",group=gS,tooltip=t12)
bc=input.color(color.aqua,"Bull color",group=gS,tooltip=t12)
sc=input.color(color.orange,"Bear color",group=gS,tooltip=t12)
sf=input.bool(true,"Fill bands",group=gS)
rs=input.bool(true,"Reclaim signals",group=gS,tooltip=t14)
trn=input.bool(false,"Align reclaims with trend",group=gS,tooltip=t15)
lc=input.color(color.lime,"Long reclaim",inline="rec",group=gS,tooltip=t13)
rc=input.color(color.red,"Short reclaim",inline="rec",group=gS,tooltip=t13)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
// ~~ State {
L=0
S=1
var fm=array.from(timeframe.in_seconds("1"),timeframe.in_seconds("5"),timeframe.in_seconds("15"),
 timeframe.in_seconds("30"),timeframe.in_seconds("60"),timeframe.in_seconds("240"),
 timeframe.in_seconds("1D"),timeframe.in_seconds("1W"))
var tm=array.from("60","60","240","240","1D","1D","1W","1M")
var arm=array.new_bool(2,false)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helpers {
clp(v,lo,hi)=>math.max(lo,math.min(hi,v))

avg(src,k)=>
    s=0.0
    c=0.0
    for i=0 to k-1
        v=src[i]
        if not na(v)
            s+=v
            c+=1.0
    c>0?s/c:na

wavg(src,wg,k)=>
    s=0.0
    w=0.0
    for i=0 to k-1
        v=src[i]
        q=nz(wg[i],0.0)
        if not na(v) and q>0
            s+=v*q
            w+=q
    w>0?s/w:na

rdev(src,md,k)=>
    s=0.0
    c=0.0
    for i=0 to k-1
        v=src[i]
        if not na(v) and not na(md)
            d=v-md
            s+=d*d
            c+=1.0
    c>0?math.sqrt(s/c):na

rms(src,k)=>
    s=0.0
    c=0.0
    for i=0 to k-1
        v=src[i]
        if not na(v)
            s+=v*v
            c+=1.0
    c>0?math.sqrt(s/c):na

ar1(src,k)=>
    sx=0.0
    sy=0.0
    sxy=0.0
    sxx=0.0
    c=0.0
    for i=0 to k-1
        x=src[i+1]
        y=src[i]
        if not na(x) and not na(y)
            sx+=x
            sy+=y
            sxy+=x*y
            sxx+=x*x
            c+=1.0
    mx=c>0?sx/c:na
    my=c>0?sy/c:na
    cv=c>1?sxy/c-mx*my:na
    vx=c>1?sxx/c-mx*mx:na
    not na(vx) and vx>1e-12?cv/vx:na

atf(tf)=>
    out=tf
    s=timeframe.in_seconds(tf)
    for i=0 to fm.size()-1
        if s==fm.get(i)
            out:=tm.get(i)
            break
    out

etf(tf,use,cs)=>
    ts=timeframe.in_seconds(tf)
    use and not na(cs) and not na(ts) and cs==ts?atf(tf):tf

pe(src,k)=>
    st=math.abs(ta.change(src))
    av=ta.sma(st,k)
    tt=av*k
    nt=math.abs(src-src[k])
    not na(tt) and not na(nt) and tt>syminfo.mintick?math.min(nt/tt,1.0):0.0

ten(pr,tg,b,r,c)=>
    sd=pr==0 or tg==0 or math.sign(pr)==math.sign(tg)
    bd=sd and math.abs(tg)>math.abs(pr)
    a=bd?2.0/(b+1.0):2.0/(r+1.0)
    clp(pr+a*(tg-pr),-c,c)

armU(ok,z,lrq,srq)=>
    if barstate.isconfirmed
        if not ok or lrq or srq
            arm.set(L,false)
            arm.set(S,false)
        else
            if z<=-m
                arm.set(L,true)
                arm.set(S,false)
            if z>=m
                arm.set(S,true)
                arm.set(L,false)
            if z>=0
                arm.set(L,false)
            if z<=0
                arm.set(S,false)
    0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Core Params {
im=m*r
sw=math.max(3,int(math.round(n*0.5)))
al=math.max(30,n*6)
cs=timeframe.in_seconds(timeframe.period)
tf=etf(ct,at,cs)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Liquidity Acceptance {
c=math.max(close,syminfo.mintick)
pc=math.max(nz(close[1],close),syminfo.mintick)
tr=math.max(high-low,math.max(math.abs(high-pc),math.abs(low-pc)))
va=avg(volume,n)
ra=avg(tr,n)
hv=not na(volume) and volume>0 and not na(va) and va>0
vr=hv?volume/va:1.0
rr=not na(ra) and ra>syminfo.mintick?tr/ra:1.0
ab=clp(hv?vr/math.max(rr,0.20):1.0,0.15,6.0)
wt=math.pow(ab,1.1)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Rejection Price {
uw=math.max(0.0,high-math.max(open,close))
dw=math.max(0.0,math.min(open,close)-low)
ap=close+0.105*(dw-uw)
pm=avg(close,n)
lm=wavg(ap,wt,n)
md=not na(pm) and not na(lm)?pm+0.1*(lm-pm):pm
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Liquidity Stress {
ph=ta.highest(high[1],sw)
pl=ta.lowest(low[1],sw)
us=not na(ph) and high>ph and close<ph
ls=not na(pl) and low<pl and close>pl
bf=not na(ra)?ra*0.35:tr*0.35
un=not na(ph) and high>=ph-bf
ln=not na(pl) and low<=pl+bf
ue=un?uw+(us?2.0*(high-ph)+0.5*(high-close):0.0):0.0
le=ln?dw+(ls?2.0*(pl-low)+0.5*(close-low):0.0):0.0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Asymmetric Deviation {
bs=rdev(close,md,n)
ur=rms(uw,n)
lr=rms(dw,n)
uer=rms(ue,n)
ler=rms(le,n)
ug=not na(bs)?math.sqrt(bs*bs+math.pow(0.3*ur,2)+math.pow(0.3*uer,2)):na
lg=not na(bs)?math.sqrt(bs*bs+math.pow(0.3*lr,2)+math.pow(0.3*ler,2)):na
up=md+m*ug
dn=md-m*lg
ui=md+im*ug
li=md-im*lg
z=close>=md?(not na(ug) and ug>1e-10?(close-md)/ug:na):(not na(lg) and lg>1e-10?(close-md)/lg:na)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ OU Regime {
x=not na(md) and md>0?math.log(c/md):na
p=ar1(x,al)
hl=not na(p) and p>0 and p<1?math.log(0.5)/math.log(p):na
sg=not na(ug) and not na(lg)?(ug+lg)*0.5:na
dz=not na(sg) and sg>1e-10 and not na(md[n])?math.abs(md-md[n])/sg:na
mh=n*2.0/os
mz=1.0/os
rd=bar_index>al+n and not na(z) and not na(hl) and not na(dz)
oo=rd and hl>=2 and hl<=mh and dz<=mz
ok=ou?oo:not na(z)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Liquidity Color {
[hh,ll]=request.security(syminfo.tickerid,tf,[high[1],low[1]],lookahead=barmerge.lookahead_on)
hr=hh-ll
sr=math.max(hr,syminfo.mintick)
hm=(hh+ll)*0.5
ar=not na(hh) and not na(ll) and hr>0
np=ar?2.0*(close-hm)/sr:na
ef=pe(close,el)
rw=not na(np)?np*ef:0.0
tg=clp(rw,-mt,mt)
var t=0.0
pt=nz(t[1],0.0)
t:=ten(pt,tg,bl,rl,mt)
rg=t>=rt?1:t<=-rt?-1:0
ac=rg==1?bc:rg==-1?sc:nc
bu=rg==1 and nz(rg[1])!=1
be=rg==-1 and nz(rg[1])!=-1
ne=rg==0 and nz(rg[1])!=0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Reclaim State {
lx=ta.crossover(z,-im)
sx=ta.crossunder(z,im)
lrq=ok and arm.get(L) and lx and z<0 and (not trn or rg==1)
srq=ok and arm.get(S) and sx and z>0 and (not trn or rg==-1)
armU(ok,z,lrq,srq)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plots & Alerts {
mp=plot(md,"Liquidity Mean",color=color.new(ac,10),linewidth=2)
upP=plot(up,"Upper Band",color=ac,linewidth=1)
dnP=plot(dn,"Lower Band",color=ac,linewidth=1)
uiP=plot(ui,"Upper Reclaim",color=color.new(ac,70),linewidth=1)
liP=plot(li,"Lower Reclaim",color=color.new(ac,70),linewidth=1)
fill(upP,dnP,color=sf?color.new(ac,90):na,title="Liquidity Warp Fill")
pa = ta.ema(ta.atr(14),200)
plotshape(rs and barstate.isconfirmed and lrq?low-pa:na,title="Long Reclaim",style=shape.triangleup,location=location.absolute,size=size.tiny,color=lc)
plotshape(rs and barstate.isconfirmed and srq?high+pa:na,title="Short Reclaim",style=shape.triangledown,location=location.absolute,size=size.tiny,color=rc)
plotshape(rs and barstate.isconfirmed and lrq?low-pa:na,title="UI Long Reclaim",style=shape.triangleup,location=location.absolute,size=size.small,color=color.new(lc,80))
plotshape(rs and barstate.isconfirmed and srq?high+pa:na,title="UI Short Reclaim",style=shape.triangledown,location=location.absolute,size=size.small,color=color.new(rc,80))
alertcondition(rs and barstate.isconfirmed and lrq,"OU Liquidity Long Reclaim","Lower liquidity stress extreme reclaimed while OU regime is valid.")
alertcondition(rs and barstate.isconfirmed and srq,"OU Liquidity Short Reclaim","Upper liquidity stress extreme reclaimed while OU regime is valid.")
alertcondition(bu,"Bullish Liquidity Regime","Liquidity color engine entered the bullish tension regime.")
alertcondition(be,"Bearish Liquidity Regime","Liquidity color engine entered the bearish tension regime.")
alertcondition(ne,"Neutral Liquidity Regime","Liquidity color engine returned to the neutral tension regime.")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
