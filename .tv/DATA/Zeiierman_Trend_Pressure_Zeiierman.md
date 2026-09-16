<!-- tradingview-pine-id: PUB;3a1104c3742c4586baeb8b47edc93cdb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Zeiierman Trend Pressure (Zeiierman)

Source: https://www.tradingview.com/script/SEdUWOIJ-Zeiierman-Trend-Pressure-Zeiierman/

## Description

█ Overview
Zeiierman Trend Pressure (Zeiierman) is a multi-layer trend pressure and exhaustion oscillator designed to visualize short-term momentum, persistent trend structure, directional pressure, and exhaustion states within a normalized 0 to -100 range.
[image]https://www.tradingview.com/x/9Mr8xsCd/[/image]
Instead of relying on a single oscillator calculation, the indicator separates market behavior into three distinct components:

• Z-Pulse = fast reactive pressure
• Z-Trend = slower macro-weighted trend pressure
• Pressure Core = broader directional pressure and regime structure

Z-Pulse reacts quickly to changes in local range position, while Z-Trend blends fast, structural, and macro range measurements with a strong weighting toward the longer-term trend. The Pressure Core then evaluates candle position, candle body, wick behavior, and recent impulse to provide an additional view of directional pressure.

The indicator also contains a persistent Pressure Exhaustion model. When both Z-Pulse and Z-Trend reach an extreme region, an exhaustion state can become active. Instead of disappearing immediately when either line moves slightly away from the extreme, the state uses confirmation and release logic to remain active until pressure has meaningfully weakened.
[image]https://www.tradingview.com/x/2cHSSEPU/[/image]
Pressure Core coloring identifies the broader directional environment:

• Core Bull = positive directional pressure
• Core Bear = negative directional pressure
• Core Neutral = mixed or insufficient directional pressure

Dots show active pressure states, while triangles identify the beginning of an upper or lower pressure event. Price boxes can also be projected directly onto the chart while an exhaustion state remains active.
[image]https://www.tradingview.com/x/8Rbn0oNn/[/image]
█ How It Works
⚪ Z-Pulse
Z-Pulse is the indicator's fast component. It first measures where the current close sits inside the recent price range using a Williams-style normalized range calculation.
[pine]rangePosition = 100 * (close - highest) / (highest - lowest)[/pine]
A stochastic transformation of this fast range reading is then blended back into the original value.
[pine]Z-Pulse Raw =
    rangePosition * 0.72
  + stochasticPulse * 0.28[/pine]
The result is smoothed with an EMA to create Z-Pulse. This gives the indicator a responsive line that can quickly detect changes in local market pressure while staying within the 0 to -100 oscillator range.

⚪ Z-Trend
Z-Trend is designed to represent the more persistent side of market pressure.

Three normalized range measurements are calculated using the Pulse Range, Trend Range, and Macro Trend lengths. These readings are combined using fixed internal weights, with the macro component receiving the largest influence.
[pine]Z-Trend Target =
    Fast Range   * 0.10
  + Trend Range  * 0.18
  + Macro Range  * 0.72[/pine]
The engine then measures agreement between the three range layers and the efficiency of recent price movement.

When the market is moving efficiently and the range layers agree, Z-Trend becomes more resistant to short counter-trend movements. Persistent occupation of the upper or lower oscillator region also increases the Trend Persistence effect.

This makes Z-Trend slower and more stable than Z-Pulse, allowing it to represent the underlying directional structure instead of reacting to every short-term fluctuation.

⚪ Pressure Core
Pressure Core measures each candle's internal structure relative to a larger price range.

It combines five components:

• closing location inside the range
• average candle location
• candle-body direction
• upper versus lower wick pressure
• recent five-bar price impulse
[pine]pressure =
    closeLocation * 0.42
  + meanLocation  * 0.23
  + bodyBias      * 0.13
  + wickBias      * 0.12
  + impulse       * 0.10[/pine]
A reactive pressure model and a slower regime model are then combined using the Regime Weight setting.
[pine]Pressure Core =
    Regime Pressure  * Regime Weight
  + Reactive Pressure * (1 - Regime Weight)[/pine]
This creates a third view of market pressure that is independent of the Z-Pulse / Z-Trend relationship.

⚪ Pressure Exhaustion
Pressure Exhaustion begins when both Z-Pulse and Z-Trend occupy the same extreme region.
[pine]upperPressure = Z-Pulse >= upperLevel
                and Z-Trend >= upperLevel

lowerPressure = Z-Pulse <= lowerLevel
                and Z-Trend <= lowerLevel[/pine]
The state does not use a simple one-bar threshold cross. It includes entry confirmation and a separate release distance so temporary fluctuations do not immediately terminate a persistent pressure state.

This creates a hysteresis effect, where entry and release conditions are intentionally different.

At normal and higher sensitivity settings, both Z-Pulse and Z-Trend must move away from the extreme before the state is released. At the lowest sensitivity settings, the state is deliberately allowed to become much less stable.
█ How to Use
Zeiierman Trend Pressure can be used in three main ways: Trend Trading, Continuation Trading, and Reversal Trading.

Z-Pulse reacts faster to short-term changes in pressure, while Z-Trend shows the slower and more persistent trend direction. Pressure Core can then be used as an additional confirmation of the broader market bias.

⚪ Trend Trading
Use Z-Trend and Pressure Core to identify the main directional environment.

When Z-Trend is holding in the upper half of the oscillator and Pressure Core is Bull-colored, bullish pressure is dominant. This favors looking for long setups.

When Z-Trend is holding in the lower half, and Pressure Core is Bear-colored, bearish pressure is dominant. This favors looking for short setups.
[image]https://www.tradingview.com/x/eRP2S6Ho/[/image]

⚪ Continuation Trading
For continuation setups, look for temporary pullbacks within an already established trend.

• Bullish Continuation Setup
During a bullish trend, Z-Trend and Pressure Core should remain bullish while Z-Pulse temporarily moves lower. This shows that short-term pressure has weakened, but the broader trend structure is still intact.

• Z-Trend remains bullish
• Pressure Core remains Bull-colored
• Z-Pulse drops lower during the price pullback
• Z-Pulse then turns higher again
• Price begins continuing in the direction of the broader bullish trend
[image]https://www.tradingview.com/x/PBCEwlNH/[/image]
• Bearish Continuation Setup
During a bearish trend, Z-Trend and Pressure Core should remain bearish while Z-Pulse temporarily moves higher. This shows that short-term pressure has strengthened against the trend, but the broader bearish structure is still intact.

• Z-Trend remains bearish
• Pressure Core remains Bear-colored
• Z-Pulse temporarily pushes higher during a price bounce
• Z-Pulse then turns lower again
• Price begins continuing in the direction of the broader bearish trend
[image]https://www.tradingview.com/x/hKKLX3nG/[/image]
The important distinction is that Z-Pulse is allowed to move against the trend temporarily. That is the pullback. As long as Z-Trend and Pressure Core remain aligned with the broader direction, the move can be treated as a potential continuation setup rather than a full trend reversal.

⚪ Reversal Trading
The pressure boxes highlight areas where the market has remained under extreme directional pressure for a period of time.

The box itself shows the price range formed while the pressure state is active. The triangle at the end of the box marks the Pressure Release, which is the important confirmation for a potential reversal.

• Bullish Reversal
A blue box forms when Z-Pulse and Z-Trend remain under strong downside pressure.

While the box is active, bearish pressure is still present, so the box alone is not a buy signal.

When the blue triangle appears, the Lower Pressure state has been released. This shows that downside pressure is weakening and can mark a potential bullish reversal area.

• Blue Box = downside pressure is active
• Blue Triangle = downside pressure has released
[image]https://www.tradingview.com/x/brWuIHRh/[/image]
• Bearish Reversal
A red box forms when Z-Pulse and Z-Trend remain under strong upside pressure.

While the box is active, bullish pressure is still present, so the box alone is not a sell signal.

When the red triangle appears, the Upper Pressure state has been released. This shows that upside pressure is weakening and can mark a potential bearish reversal area.

• Red Box = upside pressure is active
• Red Triangle = upside pressure has released
[image]https://www.tradingview.com/x/EPNu9ita/[/image]
The key idea is to wait for the pressure release rather than trying to predict the reversal while the box is still developing.

█ Settings

[*]Pulse Range: Controls the primary range window used by Z-Pulse.
[*]Pulse Stochastic: Controls the stochastic transformation applied to the fast range reading.
[*]Pulse Smoothing: Controls EMA smoothing of Z-Pulse. Higher values create a smoother and slower response.
[*]Trend Range: Controls the medium-term structural range used by Z-Trend.
[*]Macro Trend: Controls the longest range component used by Z-Trend. This component has the largest internal weighting.
[*]Trend Smoothing: Controls the final smoothing of Z-Trend.
[*]Trend Persistence: Controls how strongly persistent occupation of an extreme region influences Z-Trend.
[*]Exhaustion Zone: Controls the base location of the upper and lower pressure regions.
[*]Sensitivity: Controls exhaustion selectivity, confirmation, release distance, and state persistence. Lower values are looser and more inconsistent, while higher values are stricter and more persistent.
[*]Reactive Smoothing: Controls smoothing of the reactive component inside Pressure Core.
[*]Regime Weight: Controls how much influence the slower Pressure Core regime receives relative to reactive pressure.

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
indicator("Zeiierman Trend Pressure (Zeiierman)", precision=2, explicit_plot_zorder=true, max_boxes_count=500)
//}

// ~~ Tooltips {
var string t1="Primary range horizon for Z-Pulse. Lower values react faster to local range position."
var string t2="Stochastic pulse applied to the primary range reading. Lower values make Z-Pulse more reactive."
var string t3="EMA smoothing applied to Z-Pulse. A value of 1 keeps the pulse raw."
var string t4="Medium horizon used by Z-Trend to measure structural range position."
var string t5="Macro horizon that dominates Z-Trend and gives it its long trend-following character."
var string t6="EMA smoothing applied to the Z-Trend target. Higher values make the line steadier."
var string t7="Strengthens persistence when Z-Trend repeatedly occupies an outer range zone."
var string t8="Base exhaustion zone. Sensitivity expands or contracts this zone around the default value."
var string t9="Strong global exhaustion sensitivity. 1 is intentionally loose, fast and inconsistent. 5 is balanced. 10 is strict, selective and persistent."
var string t10="Main smoothing control for Pressure Core. Higher values calm its reactive pressure component."
var string t11="Controls the balance between the fixed macro regime and reactive pressure in Pressure Core."
var string t12="Color of the reactive Z-Pulse line."
var string t13="Color of the macro-weighted Z-Trend line."
var string t14="Bull, bear and neutral colors used by Pressure Core."
var string t15="Thickness of the Pressure Core line."
var string t16="Fills the space between Z-Pulse and Z-Trend with fading hot and cold extreme gradients."
var string t17="Draws persistent price boxes while Z-Pulse and Z-Trend remain in a pressure exhaustion state."
var string t18="Colors of the upper and lower pressure levels shown in the oscillator pane."
var string t19="Transparency of the upper and lower pressure levels. 0 is fully visible and 100 is invisible."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Groups {
gP="1. Z-Pulse"
gT="2. Z-Trend"
gE="3. Pressure Exhaustion"
gC="4. Pressure Core"
gS="5. Colors & Style"
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
fl=input.int(21,"Pulse Range",minval=3,group=gP,tooltip=t1)
pl=input.int(9,"Pulse Stochastic",minval=3,group=gP,tooltip=t2)
ps=input.int(7,"Pulse Smoothing",minval=1,maxval=50,group=gP,tooltip=t3)

sl=input.int(55,"Trend Range",minval=5,group=gT,tooltip=t4)
ml=input.int(120,"Macro Trend",minval=10,group=gT,tooltip=t5)
ts=input.int(5,"Trend Smoothing",minval=1,maxval=30,group=gT,tooltip=t6)
db=input.float(9.0,"Trend Persistence",minval=0.0,maxval=20.0,step=0.5,group=gT,tooltip=t7)

zn=input.int(20,"Exhaustion Zone",minval=5,maxval=40,group=gE,tooltip=t8)
sn=input.int(7,"Sensitivity",minval=1,maxval=10,group=gE,tooltip=t9)
xc=input.bool(false,"Pulse / Trend Crosses",group=gE)

rm=input.int(16,"Reactive Smoothing",minval=1,maxval=30,group=gC,tooltip=t10)
gw=input.float(0.65,"Regime Weight",minval=0.0,maxval=1.0,step=0.05,group=gC,tooltip=t11)

cc=input.color(#2962ff,"Cold",inline="z",group=gS)
hc=input.color(#e6283e,"Hot",inline="z",group=gS)

ulc=input.color(#e6283e,"Upper Level",inline="lv",group=gS,tooltip=t18)
llc=input.color(#2962ff,"Lower Level",inline="lv",group=gS,tooltip=t18)
lvt=input.int(20,"Level Transparency",minval=0,maxval=100,group=gS,tooltip=t19)

pc=input.color(#E5E7EB,"Z-Pulse",inline="l",group=gS,tooltip=t12)
zc=input.color(color.rgb(139,174,255),"Z-Trend",inline="l",group=gS,tooltip=t13)

cbc=input.color(#40e3c3,"Core Bull",inline="tc",group=gS,tooltip=t14)
csc=input.color(#df5141,"Core Bear",inline="tc",group=gS,tooltip=t14)
cnc=input.color(color.silver,"Core Neutral",inline="tc",group=gS,tooltip=t14)
cw=input.int(2,"Core Width",minval=1,maxval=4,group=gS,tooltip=t15)

sf=input.bool(true,"Gradient Fill",group=gS,tooltip=t16)
bx=input.bool(true,"Price Boxes",inline="b",group=gS,tooltip=t17)
mb=input.int(60,"#",minval=1,maxval=300,inline="b",group=gS,active=bx)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Core Params {
const float sw=0.18
const float mw=0.72
const float th=0.92

const int rl=21
const int gl=112
const int gm=3
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ State {
F=0
S=1
M=2

var array<box> bh=array.new_box()

var float ud=0.0
var float dd=0.0
var float tz=na

var int est=0
var int ucn=0
var int lcn=0

var box ubx=na
var box lbx=na

var float ut=na
var float ub=na
var float lt=na
var float lb=na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helpers {
clp(float v,float lo,float hi)=>math.max(lo,math.min(hi,v))
sm(float v,int k)=>k>1?ta.ema(v,k):v

wr(int k)=>
    hh=ta.highest(high,k)
    ll=ta.lowest(low,k)
    100.0*(close-hh)/math.max(hh-ll,syminfo.mintick)

eff(int k)=>
    p=ta.sma(math.abs(close-close[1]),k)*k
    n=na(close[k])?na:math.abs(close-close[k])
    na(p) or na(n)?na:clp(n/math.max(p,syminfo.mintick),0.0,1.0)

stk(float x,int k)=>
    hi=ta.highest(x,k)
    lo=ta.lowest(x,k)
    -100.0+100.0*(x-lo)/math.max(hi-lo,1e-10)

con(array<float> a,array<float> w)=>
    ws0=w.get(F)+w.get(S)+w.get(M)
    clp((a.get(F)*w.get(F)+a.get(S)*w.get(S)+a.get(M)*w.get(M))/math.max(ws0,1e-10),-100.0,0.0)

agr(array<float> a)=>
    d=math.abs(a.get(F)-a.get(S))+math.abs(a.get(S)-a.get(M))+math.abs(a.get(F)-a.get(M))
    1.0-clp(d/300.0,0.0,1.0)

prs(int k)=>
    hh=ta.highest(high,k)
    ll=ta.lowest(low,k)
    rg=math.max(hh-ll,syminfo.mintick)
    cr=math.max(high-low,syminfo.mintick)
    bh0=math.max(open,close)
    bl0=math.min(open,close)
    uw=high-bh0
    lw=bl0-low
    cl=(close-ll)/rg
    mn=(hlc3-ll)/rg
    bd=((close-open)/cr+1.0)*0.5
    wk=((lw-uw)/cr+1.0)*0.5
    p5=nz(close[5],close)
    im=((close-p5)/rg+1.0)*0.5
    clp((cl*0.42+mn*0.23+bd*0.13+wk*0.12+im*0.10)*100.0,0.0,100.0)

alpha(float prev,float trg,float mac,float ag,float ef,float base,float hold)=>
    side=mac>-50.0?1:mac<-50.0?-1:0
    pull=(side==1 and trg<prev) or (side==-1 and trg>prev)
    lk=clp(0.15+ag*ef*hold,0.0,0.97)
    pull?math.max(0.015,base*(1.0-lk)):math.max(base*0.75,0.03)

ccore(float v,float rg)=>
    v>50.0 and rg>50.0?color.new(cbc,15):
     v<50.0 and rg<50.0?color.new(csc,15):
     color.new(cnc,35)

keep(array<box> a,box b,int lim)=>
    a.push(b)
    if a.size()>lim
        box.delete(a.shift())
    0

mkbox(float t,float b,color c,color br)=>
    box.new(bar_index-1,t,bar_index,b,bgcolor=color.new(c,80),border_color=br,border_width=1,force_overlay=true)

grow(box b,float t,float d)=>
    nt=math.max(t,high)
    nd=math.min(d,low)
    b.set_right(bar_index)
    b.set_top(nt)
    b.set_bottom(nd)
    [nt,nd]
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Z-Pulse Engine {
array<float> rz=array.from(wr(fl),wr(sl),wr(ml))

rf=rz.get(F)
rp=stk(rf,pl)

pr=clp(rf*0.72+rp*0.28,-100.0,0.0)
pz=sm(pr,ps)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Z-Trend Engine {
fw=math.max(0.0,1.0-sw-mw)
array<float> twt=array.from(fw,sw,mw)

cn=con(rz,twt)
ag=agr(rz)
ef=nz(eff(sl),0.0)

ud:=cn>-30.0?math.min(1.0,nz(ud[1])*0.93+0.07):nz(ud[1])*0.94
dd:=cn<-70.0?math.min(1.0,nz(dd[1])*0.93+0.07):nz(dd[1])*0.94

tg0=clp(cn+db*(ud-dd),-100.0,0.0)
tg=sm(tg0,2)

ba=2.0/(ts+1.0)
pa=na(tz[1])?ba:alpha(tz[1],tg,rz.get(M),ag,ef,ba,th)

tz:=na(tz[1])?tg:clp(tz[1]+pa*(tg-tz[1]),-100.0,0.0)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Pressure Core {
cp=ta.ema(prs(rl),rm)
cg=ta.ema(prs(gl),gm)

c0=cg*gw+cp*(1.0-gw)
cz=c0-100.0
ccl=ccore(c0,cg)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Strong Sensitivity Engine {
d=float(sn-5)

ez=clp(float(zn)-d*4.0,8.0,42.0)
rb=clp(8.0+d*1.75,1.0,18.0)
cf=sn<=5?1:sn<=7?2:sn<=9?3:4
fastExit=sn<=2

up=-ez
dn=-100.0+ez
ur=up-rb
lr=dn+rb

uc=pz>=up and tz>=up
lc=pz<=dn and tz<=dn

ucn:=uc?ucn+1:0
lcn:=lc?lcn+1:0

ux=fastExit?(pz<ur or tz<ur):(pz<ur and tz<ur)
lx=fastExit?(pz>lr or tz>lr):(pz>lr and tz>lr)

if est==0
    if ucn>=cf
        est:=1
    else if lcn>=cf
        est:=-1
else if est==1 and ux
    est:=0
else if est==-1 and lx
    est:=0

ue=est==1
le=est==-1

us=ue and nz(est[1],0)!=1
ls=le and nz(est[1],0)!=-1

ubk=est==0 and nz(est[1],0)==1
lbk=est==0 and nz(est[1],0)==-1

xup=ta.crossover(pz,tz)
xdn=ta.crossunder(pz,tz)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Visuals {
hm=color.new(hc,60)
cm=color.new(cc,60)

ul=color.new(ulc,lvt)
ll=color.new(llc,lvt)

inv=color.new(color.black,100)

hline(0,"Upper Bound",ul)
pU=plot(up,"Upper Pressure Level",color=ul,linewidth=1)

hline(-50,"Equilibrium",color.new(chart.fg_color,80))

pD=plot(dn,"Lower Pressure Level",color=ll,linewidth=1)
hline(-100,"Lower Bound",ll)

pP=plot(pz,"Z-Pulse",color=pc,linewidth=1)
pT=plot(tz,"Z-Trend",color=zc,linewidth=2)
pC=plot(cz,"Pressure Core",color=ccl,linewidth=cw)

gh=sf?color.new(hc,100):inv
gc=sf?color.new(cc,100):inv

fill(pP,pT,0,-30,top_color=color.new(gh,0),bottom_color=gh,title="Upper Pressure Gradient")
fill(pP,pT,-70,-100,top_color=gc,bottom_color=color.new(gc,0),title="Lower Pressure Gradient")

plotshape(ue?5:na,title="Upper Pressure Active",style=shape.circle,location=location.absolute,color=hm,size=size.tiny)
plotshape(le?-107:na,title="Lower Pressure Active",style=shape.circle,location=location.absolute,color=cm,size=size.tiny)

plotshape(us?5:na,title="Upper Pressure Start",style=shape.triangledown,location=location.absolute,color=hc,size=size.tiny)
plotshape(ls?-107:na,title="Lower Pressure Start",style=shape.triangleup,location=location.absolute,color=cc,size=size.tiny)

plotshape(ubk?5:na,title="Upper Pressure Release",style=shape.circle,location=location.absolute,color=hc,size=size.tiny)
plotshape(lbk?-107:na,title="Lower Pressure Release",style=shape.circle,location=location.absolute,color=cc,size=size.tiny)

plot(xc and (xup or xdn)?tz:na,"Z-Pulse / Z-Trend Cross",style=plot.style_circles,color=xup?cc:hc,linewidth=5)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Price Boxes {
if bx
    if us
        if not na(ubx)
            box.delete(ubx)

        ut:=high
        ub:=low
        ubx:=mkbox(ut,ub,hc,hm)
        keep(bh,ubx,mb)

    else if ue and not na(ubx)
        [nut,nub]=grow(ubx,ut,ub)
        ut:=nut
        ub:=nub

    else if ubk and not na(ubx)
        ubx.set_right(bar_index-1)
        ubx:=na

    if ls
        if not na(lbx)
            box.delete(lbx)

        lt:=high
        lb:=low
        lbx:=mkbox(lt,lb,cc,cm)
        keep(bh,lbx,mb)

    else if le and not na(lbx)
        [nlt,nlb]=grow(lbx,lt,lb)
        lt:=nlt
        lb:=nlb

    else if lbk and not na(lbx)
        lbx.set_right(bar_index-1)
        lbx:=na

plotshape(bx and ubk and not na(ut)?ut:na,title="Upper Pressure Release Price",style=shape.triangledown,location=location.absolute,color=hc,size=size.tiny,force_overlay=true)
plotshape(bx and lbk and not na(lb)?lb:na,title="Lower Pressure Release Price",style=shape.triangleup,location=location.absolute,color=cc,size=size.tiny,force_overlay=true)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alertcondition(ubk,"Upper Pressure Release","Zeiierman Trend Pressure upper pressure released on {{ticker}} {{interval}}.")
alertcondition(lbk,"Lower Pressure Release","Zeiierman Trend Pressure lower pressure released on {{ticker}} {{interval}}.")

alertcondition(xup,"Bullish Z-Pulse / Z-Trend Cross","Z-Pulse crossed above Z-Trend on {{ticker}} {{interval}}.")
alertcondition(xdn,"Bearish Z-Pulse / Z-Trend Cross","Z-Pulse crossed below Z-Trend on {{ticker}} {{interval}}.")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
