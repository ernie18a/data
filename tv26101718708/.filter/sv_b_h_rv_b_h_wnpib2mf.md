# SV B (H) + RV B (H)

- url: https://www.tradingview.com/script/wNpIB2Mf-SV-B-H-RV-B-H/
- type: indicator
- pine_id: PUB;2b43a1e46daa487c9abd182ebecaf41c
- version: 1.0

## Description

How the Indicator Works
1. Statistical Strength Measurement (Z-Scores)

The script converts key variables into Z-scores over a lookback period (default 50 bars):

Price Z-score
Volume Z-score
Distance above Session VWAP Z-score
Distance above Rolling VWAP Z-score

A Z-score measures how unusual a value is compared to recent history.

Example:

Price Z-score = +2.0
Price is 2 standard deviations above its average
Volume Z-score = +2.0
Volume is much higher than normal
2. VWAP Analysis

The script evaluates two VWAP references:

Session VWAP

Standard intraday VWAP reset each trading day.

Used for:

SV B (H) signals

Rolling VWAP

Custom VWAP calculated over a rolling window (default 50 bars).

Used for:

RV B (H) signals

This allows detection of strength relative to both:

Intraday institutional positioning (Session VWAP)
Recent market positioning (Rolling VWAP)
3. Composite Momentum Score

The indicator creates a weighted composite score:

Components:

Price Z-score
Volume Z-score
VWAP Distance Z-score

Default weights:

Price = 1
Volume = 1
VWAP = 1

Formula:

Composite = Average of the three weighted Z-scores

The composite is then smoothed with a 5-period EMA.

This helps reduce noise and avoid signals from a single spike.

4. Alignment Requirement

Before a signal can occur, a minimum number of bullish components must be present.

Default:

At least 2 of 3 conditions must be bullish

Examples:

Price	Volume	VWAP	Signal Eligible?
Strong	Strong	Weak	Yes
Strong	Weak	Strong	Yes
Weak	Strong	Strong	Yes
Strong	Weak	Weak	No
5. Composite Trigger

The smoothed composite score must exceed:

1.5 (default)

By default the script requires a crossover above 1.5 rather than simply remaining above it.

This prevents repeated signals during the same trend.

6. Opening Range High Filter

The script tracks:

Opening Range (9:30–10:00 AM)

It records the highest price during that period.

A bullish signal is only allowed when:

Current close > Opening Range High

This ensures momentum is occurring after a meaningful intraday breakout.

7. Premarket High Filter

The script also tracks:

Premarket Session (4:00–9:29 AM)

It records the highest premarket price.

A bullish signal requires:

Current close > Premarket High

If no premarket data exists, this filter is ignored.

Signal Requirements
SV B (H) Signal

Generated when:

✅ At least 2 bullish components align

AND

✅ Session VWAP composite crosses above threshold

AND

✅ Price closes above Opening Range High

AND

✅ Price closes above Premarket High

RV B (H) Signal

Generated when:

✅ At least 2 bullish components align

AND

✅ Rolling VWAP composite crosses above threshold

AND

✅ Price closes above Opening Range High

AND

✅ Price closes above Premarket High

Visual Output
Purple Circle

SV B (H)

Session VWAP bullish breakout
Strong price + volume + session VWAP alignment
Aqua Circle

RV B (H)

Rolling VWAP bullish breakout
Strong price + volume + rolling VWAP alignment

Both are plotted below the bar where the signal occurs.

## Source Code

````pine
//@version=5
indicator("SV B (H) + RV B (H) 🟣", overlay=true)

groupCore="Core Settings"
src=input.source(close,"Source",group=groupCore)
zLen=input.int(50,"Z-Score Length",minval=5,group=groupCore)
rvwapLen=input.int(50,"Rolling VWAP Length",minval=5,group=groupCore)
smoothLen=input.int(5,"Composite Smoothing",minval=1,group=groupCore)

groupWeights="Composite Weights"
wPrice=input.float(1.0,"Price Z Weight",step=0.1,group=groupWeights)
wVol=input.float(1.0,"Volume Z Weight",step=0.1,group=groupWeights)
wVwap=input.float(1.0,"VWAP Distance Z Weight",step=0.1,group=groupWeights)

groupThresholds="Composite Thresholds"
strongLevel=input.float(1.0,"Strong Alignment Threshold",step=0.1,group=groupThresholds)
compositeTrigger=input.float(1.5,"Composite Trigger",step=0.1,group=groupThresholds)
minAlignedCount=input.int(2,"Minimum Components Aligned",minval=1,maxval=3,group=groupThresholds)
useCompositeCross=input.bool(true,"Require Composite Threshold Cross",group=groupThresholds)

groupSessions="Session Levels"
premarketSession=input.session("0400-0929","Premarket Session",group=groupSessions)
orSession=input.session("0930-1000","Opening Range Session",group=groupSessions)

groupDisplay="Display"
showSessionSignals=input.bool(true,"Show Session Bull",group=groupDisplay)
showRollingSignals=input.bool(true,"Show Rolling Bull",group=groupDisplay)

groupStyle="Style"
sessionBullColor=input.color(color.fuchsia,"Session Bull Color",group=groupStyle)
rollingBullColor=input.color(color.aqua,"Rolling Bull Color",group=groupStyle)

f_zscore(_x,_len)=>
    _mean=ta.sma(_x,_len)
    _std=ta.stdev(_x,_len)
    _std!=0?(_x-_mean)/_std:0.0

f_rolling_vwap(_price,_volume,_len)=>
    _pv=_price*_volume
    _sumPV=math.sum(_pv,_len)
    _sumV=math.sum(_volume,_len)
    _sumV!=0?_sumPV/_sumV:na

rvwap=f_rolling_vwap(src,volume,rvwapLen)
sessionVWAP=ta.vwap(hlc3)

priceZ=f_zscore(src,zLen)
volumeZ=f_zscore(volume,zLen)
sessionVwapDistZ=f_zscore(src-sessionVWAP,zLen)
rollingVwapDistZ=f_zscore(src-rvwap,zLen)

weightSumRaw=wPrice+wVol+wVwap
weightSum=weightSumRaw==0?1.0:weightSumRaw

sessionCompositeRaw=(priceZ*wPrice+volumeZ*wVol+sessionVwapDistZ*wVwap)/weightSum
rollingCompositeRaw=(priceZ*wPrice+volumeZ*wVol+rollingVwapDistZ*wVwap)/weightSum
sessionCompositeZ=ta.ema(sessionCompositeRaw,smoothLen)
rollingCompositeZ=ta.ema(rollingCompositeRaw,smoothLen)

sessionBullPrice=priceZ>strongLevel
sessionBullVol=volumeZ>strongLevel
sessionBullVwap=sessionVwapDistZ>strongLevel
rollingBullPrice=priceZ>strongLevel
rollingBullVol=volumeZ>strongLevel
rollingBullVwap=rollingVwapDistZ>strongLevel

sessionBullCount=(sessionBullPrice?1:0)+(sessionBullVol?1:0)+(sessionBullVwap?1:0)
rollingBullCount=(rollingBullPrice?1:0)+(rollingBullVol?1:0)+(rollingBullVwap?1:0)

sessionBullAligned=sessionBullCount>=minAlignedCount
rollingBullAligned=rollingBullCount>=minAlignedCount

sessionBullCompositePass=useCompositeCross?ta.crossover(sessionCompositeZ,compositeTrigger):sessionCompositeZ>compositeTrigger
rollingBullCompositePass=useCompositeCross?ta.crossover(rollingCompositeZ,compositeTrigger):rollingCompositeZ>compositeTrigger

inPremarket=not na(time(timeframe.period,premarketSession))
inOR=not na(time(timeframe.period,orSession))

var float premarketHigh=na
var float orHigh=na

newDay=ta.change(time("D"))!=0
if newDay
    premarketHigh:=na
    orHigh:=na

if inPremarket
    premarketHigh:=na(premarketHigh)?high:math.max(premarketHigh,high)

if inOR
    orHigh:=na(orHigh)?high:math.max(orHigh,high)

aboveOR=not na(orHigh) and close>orHigh
abovePM=na(premarketHigh)?true:close>premarketHigh
abovePMandOR=aboveOR and abovePM

sessionBullSignal=showSessionSignals and sessionBullAligned and sessionBullCompositePass and abovePMandOR
rollingBullSignal=showRollingSignals and rollingBullAligned and rollingBullCompositePass and abovePMandOR

plotshape(sessionBullSignal,title="Session Bull",style=shape.circle,location=location.belowbar,color=sessionBullColor,size=size.small,text="SV B (H)")
plotshape(rollingBullSignal,title="Rolling Bull",style=shape.circle,location=location.belowbar,color=rollingBullColor,size=size.small,text="RV B (H)")

alertcondition(sessionBullSignal,"SV B (H)","Session VWAP bull composite signal above OR high and premarket high if it exists")
alertcondition(rollingBullSignal,"RV B (H)","Rolling VWAP bull composite signal above OR high and premarket high if it exists")

if sessionBullSignal and barstate.isconfirmed
    alert("SV B (H) - Session VWAP bull composite above OR high and premarket high if it exists",alert.freq_once_per_bar_close)

if rollingBullSignal and barstate.isconfirmed
    alert("RV B (H) - Rolling VWAP bull composite above OR high and premarket high if it exists",alert.freq_once_per_bar_close)
````
