<!-- tradingview-pine-id: PUB;157e68c4b85c43749c3621c567b67911 -->
<!-- tradingviewscripts-format: 1 -->
# Price Volume Divergence Momentum

Source: https://www.tradingview.com/script/SwWO3s6P/

## Description

Price Volume Divergence Momentum (PVDM)

PVDM is the momentum component of the PVD Ecosystem. It focuses on a simple question: How is price-volume pressure moving right now, and how much of that movement has built up?

The indicator combines two closely related views:

PVD Momentum
The green and red histogram shows the current direction and strength of PVD pressure movement.

• Green = positive pressure movement
• Red = negative pressure movement
• Taller bars = stronger movement
• More solid bars = stronger momentum quality
• More transparent bars = weaker momentum quality

This makes it possible to see not only the direction of momentum, but also how convincing the current movement is.

PVD Pressure Reserve
The blue and orange line shows how much directional pressure movement has accumulated over time.

• Blue = positive pressure reserve
• Orange = negative pressure reserve
• Movement away from zero = pressure is building
• Movement toward zero = accumulated pressure is being released
• Values near the upper or lower range = strongly loaded pressure reserve

A simple way to picture this is a balloon: the histogram shows the pressure currently going in one direction or the other, while the Pressure Reserve shows how strongly the balloon has already been filled in that direction.

Reading both together

When Momentum and Pressure Reserve point in the same direction, the existing pressure is being reinforced.

When they point in opposite directions, the accumulated pressure reserve is being released. This can make changes in market dynamics easier to recognize than by looking at momentum alone.

A highly loaded Pressure Reserve is not automatically a reversal signal. Its value becomes especially interesting when the Momentum histogram begins to change direction or strength.

Calculation Mode

Non-Repainting is the default mode and uses confirmed candle information for a stable view.

Repainting allows the current open candle to update as price and volume develop.

PVDM can be used on different markets and timeframes as an additional view of the pressure behind price movement.

---

## Source Code

````pine
//@version=6
indicator("Price Volume Divergence Momentum", shorttitle="PVDM", overlay=false)

//=============================================================================
// MODULE 1 — INPUTS
//=============================================================================
calculationMode=input.string("Non-Repainting","Calculation Mode",options=["Non-Repainting","Repainting"])
priceDeltaType=input.string("Signed High - Low","Price Movement",options=["Close - Open","Signed High - Low"])
normLength=input.int(11,"Normalization Length",minval=1)
maType=input.string("EMA","PVDO MA Type",options=["SMA","EMA","HMA","LMA","RMA","WMA","VWMA","TEMA"])
pvdoMaLength=input.int(121,"PVDO MA Length",minval=1)
logisticBandwidth=input.float(121,"Logistic Bandwidth",minval=1)
dynamicMemory=input.int(11,"Momentum Memory",minval=1)
momentumMaType=input.string("EMA","Momentum MA Type",options=["SMA","EMA","HMA","LMA","RMA","WMA","VWMA","TEMA"])
momentumMaLength=input.int(0,"Momentum MA Length",minval=0)
reserveMaType=input.string("EMA","Pressure Reserve MA Type",options=["SMA","EMA","HMA","LMA","RMA","WMA","VWMA","TEMA"])
reserveMaLength=input.int(0,"Pressure Reserve MA Length",minval=0)

//=============================================================================
// MODULE 2 — COMMON FUNCTIONS
//=============================================================================
tema(src,len)=>
    ema1=ta.ema(src,len),ema2=ta.ema(ema1,len),ema3=ta.ema(ema2,len)
    3*ema1-3*ema2+ema3

ma(src,len,type)=>
    switch type
        "SMA"=>ta.sma(src,len)
        "EMA"=>ta.ema(src,len)
        "HMA"=>ta.hma(src,len)
        "LMA"=>ta.linreg(src,len,0)
        "RMA"=>ta.rma(src,len)
        "WMA"=>ta.wma(src,len)
        "VWMA"=>ta.vwma(src,len)
        "TEMA"=>tema(src,len)

mkr_logistic_weight(src,bandwidth)=>1.0/(1.0+math.exp(-math.abs(src)/bandwidth))
bound(x)=>x/(1.0+math.abs(x))
emaCandidate(committed,x,alpha)=>na(committed)?x:alpha*x+(1.0-alpha)*committed

//=============================================================================
// MODULE 3 — PVDO FOUNDATION
//=============================================================================
candleRange=math.max(high-low,syminfo.mintick)
pressure=volume*(close-open)/candleRange
pressureScale=ta.sma(math.abs(pressure),normLength)
pressureNorm=not na(pressureScale) and pressureScale>0?pressure/pressureScale:0.0

priceMove=priceDeltaType=="Close - Open"?close-open:close>open?high-low:close<open?-(high-low):0.0
priceScale=ta.sma(math.abs(priceMove),normLength)
priceNorm=not na(priceScale) and priceScale>0?priceMove/priceScale:0.0
pvdoRaw=-(priceNorm-pressureNorm)*math.abs(priceNorm)

pvdoMain=ma(pvdoRaw,pvdoMaLength,maType)

var float pvdoLogistic=na
pvdoChange=pvdoMain-nz(pvdoLogistic,pvdoMain)
pvdoWeight=mkr_logistic_weight(pvdoChange,logisticBandwidth)
pvdoLogistic:=na(pvdoLogistic[1])?pvdoMain:pvdoLogistic[1]+pvdoWeight*pvdoChange

//=============================================================================
// MODULE 4 — PVDM DYNAMIC STATE
//=============================================================================
alpha=2.0/(dynamicMemory+1.0)
reserveDecay=(dynamicMemory-1.0)/dynamicMemory

var float committedPvdo=na
var float committedMeanVp=na
var float committedMeanAbsVp=na
var float committedReserveRaw=na
var float committedD=na
var float committedAF=na
var float committedP=na
var float committedPressureReserve=na

hasReference=not na(committedPvdo)

Vp=hasReference?pvdoLogistic-committedPvdo:na

meanVpCandidate=not na(Vp)?emaCandidate(committedMeanVp,Vp,alpha):na
meanAbsVpCandidate=not na(Vp)?emaCandidate(committedMeanAbsVp,math.abs(Vp),alpha):na

reserveRawCandidate=not na(Vp)?(na(committedReserveRaw)?Vp:committedReserveRaw*reserveDecay+Vp):na
reserveScale=not na(meanAbsVpCandidate) and meanAbsVpCandidate>0?dynamicMemory*meanAbsVpCandidate:na
pressureReserveCandidate=not na(reserveScale)?math.max(-1.0,math.min(1.0,reserveRawCandidate/reserveScale)):0.0

//=============================================================================
// MODULE 5 — PVD MOMENTUM
//=============================================================================
Dcandidate=not na(meanAbsVpCandidate) and meanAbsVpCandidate>0?bound(Vp/meanAbsVpCandidate):0.0
Pcandidate=not na(meanAbsVpCandidate) and meanAbsVpCandidate>0?math.min(1.0,math.abs(meanVpCandidate)/meanAbsVpCandidate):0.0

Acandidate=not na(committedD)?Dcandidate-committedD:0.0
AFcandidate=math.sign(Dcandidate)*Acandidate

//=============================================================================
// MODULE 6 — COMMITMENT & CALCULATION MODE
//=============================================================================
firstObservation=na(committedPvdo)

float Ddisplay=na
float AFdisplay=na
float Pdisplay=na
float pressureReserveDisplay=na

if firstObservation
    if barstate.isconfirmed
        committedPvdo:=pvdoLogistic
else
    Ddisplay:=calculationMode=="Repainting"?Dcandidate:committedD
    AFdisplay:=calculationMode=="Repainting"?AFcandidate:committedAF
    Pdisplay:=calculationMode=="Repainting"?Pcandidate:committedP
    pressureReserveDisplay:=calculationMode=="Repainting"?pressureReserveCandidate:committedPressureReserve

    if barstate.isconfirmed
        committedPvdo:=pvdoLogistic
        committedMeanVp:=meanVpCandidate
        committedMeanAbsVp:=meanAbsVpCandidate
        committedReserveRaw:=reserveRawCandidate
        committedD:=Dcandidate
        committedAF:=AFcandidate
        committedP:=Pcandidate
        committedPressureReserve:=pressureReserveCandidate
        Ddisplay:=Dcandidate
        AFdisplay:=AFcandidate
        Pdisplay:=Pcandidate
        pressureReserveDisplay:=pressureReserveCandidate

//=============================================================================
// MODULE 7 — PVD MOMENTUM & MOMENTUM QUALITY
//=============================================================================
forceQuality=math.max(-1.0,math.min(1.0,nz(AFdisplay,0.0)))
momentumQuality=nz(Pdisplay,0.0)+(1.0-nz(Pdisplay,0.0))*math.max(forceQuality,0.0)+nz(Pdisplay,0.0)*math.min(forceQuality,0.0)
momentumQuality:=math.max(0.0,math.min(1.0,momentumQuality))

momentumOutput=momentumMaLength<=1?Ddisplay:ma(Ddisplay,momentumMaLength,momentumMaType)

momentumTransparency=int(math.round(60.0-50.0*momentumQuality))
momentumBaseColor=momentumOutput>=0?color.lime:color.red
momentumColor=color.new(momentumBaseColor,momentumTransparency)

hline(0.0,"Zero",color=color.new(color.gray,70))
plot(momentumOutput,"PVD Momentum",style=plot.style_columns,color=momentumColor,linewidth=2)

//=============================================================================
// MODULE 8 — PVD PRESSURE RESERVE
//=============================================================================
pressureReserveOutput=reserveMaLength<=1?pressureReserveDisplay:ma(pressureReserveDisplay,reserveMaLength,reserveMaType)
pressureReserveColor=pressureReserveOutput>=0?color.rgb(100,200,255):color.rgb(255,190,100)

plot(not na(Ddisplay)?pressureReserveOutput:na,"PVD Pressure Reserve",color=pressureReserveColor,linewidth=2)
````
