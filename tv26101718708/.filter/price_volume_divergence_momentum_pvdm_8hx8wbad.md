# Price Volume Divergence Momentum (PVDM)

- url: https://www.tradingview.com/script/8Hx8wbAD/
- type: indicator
- pine_id: PUB;641883eecbfa4eb1a4e43c6119c4d6fa
- version: 1.0

## Description

Price Volume Divergence Momentum (PVDM)

Overview

PVDM is an open-source price-volume indicator designed to show two related aspects of the PVD process: current momentum and remaining pressure reserve.

The distinction is important. A market can be moving strongly while its underlying reserve is already weakening, or it can show modest movement while pressure is still being stored.

PVDM is the dynamics layer of the PVD Ecosystem. Its role is to describe how the price-volume process is moving and how much pressure remains behind that movement.

What it shows

PVDM is displayed in a separate pane.

It contains two main elements:

• Momentum histogram — shows the current movement in the PVD process.
• Pressure Reserve line — shows the direction and amount of stored pressure behind that movement.

A simple analogy is a balloon:

• the histogram describes whether air is currently flowing in or out;
• the reserve line describes how much pressure remains stored inside.

How to use it

PVDM can help distinguish between visible movement and underlying reserve.

Useful observations include:

• momentum and reserve strengthening together;
• momentum continuing while reserve fades;
• reserve building before momentum becomes more visible;
• momentum changing while reserve remains on the opposite side.

These relationships can provide context about the quality and durability of a move, but they are not automatic trade instructions.

Optional smoothing can be used to reduce visual noise in the histogram or reserve line.

Role in the PVD Ecosystem

PVDM answers the question:

How is the current price-volume process moving, and how much pressure remains behind it?

Its role is specifically momentum and reserve. It does not try to replace state classification or forward projection.

Originality

PVDM uses an original implementation built around changes in the normalized PVD process, adaptive memory, momentum quality, and a separately maintained pressure-reserve state.

The reserve is not simply another moving average of the histogram. It represents stored pressure derived from the evolving PVD process and is scaled so it can be interpreted alongside momentum.

The script is published open source so users can inspect and understand how the indicator is constructed.

Limitations

PVDM does not forecast certain future prices and does not provide guaranteed entry or exit signals.

Momentum can reverse quickly, and stored pressure does not guarantee that price will move in the same direction or within a specific time.

Results depend on the quality of price and volume data and can vary significantly across symbols, exchanges, and timeframes.

PVDM should be used together with market context, independent judgment, and appropriate risk management.

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
pressureNorm=na(pressureScale)?na:pressureScale==0.0?0.0:pressure/pressureScale

priceMove=priceDeltaType=="Close - Open"?close-open:close>open?high-low:close<open?-(high-low):0.0
priceScale=ta.sma(math.abs(priceMove),normLength)
priceNorm=na(priceScale)?na:priceScale==0.0?0.0:priceMove/priceScale
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

AFcandidate=not na(committedD)?math.abs(Dcandidate)-math.abs(committedD):0.0

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
pQuality=nz(Pdisplay,0.0)
momentumQuality=pQuality+pQuality*(1.0-pQuality)*math.max(forceQuality,0.0)+pQuality*math.min(forceQuality,0.0)
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
