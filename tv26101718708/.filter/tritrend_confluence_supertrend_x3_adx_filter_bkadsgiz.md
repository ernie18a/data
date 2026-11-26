# Tri-Trend Confluence | SuperTrend x3 + ADX Filter

- url: https://www.tradingview.com/script/bKaDsgIz-Tri-Trend-Confluence-SuperTrend-x3-ADX-Filter/
- type: strategy
- pine_id: PUB;25bb93cf85864da8b927146a3780e64e
- version: 4.0

## Description

A trend-following system that only fires when three independently-tuned SuperTrend lines (fast/medium/slow) agree on direction — filtered by ADX trend strength.
[b]How it works[/b]
Three SuperTrends (fast, medium, slow) vote on trend direction. Choose your consensus mode: require all three to agree, a 2-of-3 majority, or a fast-trigger + slow-confirm setup. Entries also require ADX above a configurable strength threshold (with an optional "ADX must be rising" filter), keeping you out of range-bound grinds where SuperTrend alone tends to whipsaw.
[b]Features[/b]
[list]
[*]3 independently configurable SuperTrend lines
[*]ADX strength + rising filter
[*]Volume confirmation filter
[*]Higher-timeframe trend filter (via request.security)
[*]ATR-based position sizing — risks a fixed % of equity per trade, sized off the actual stop distance
[*]Enforced intrabar stop at the slow SuperTrend line
[*]Visual trend cloud + ADX strength gradient background for at-a-glance read
[*]Backtested with realistic costs
[*]Default settings include 0.05% commission and 2-tick slippage baked in. Adjust the commission/slippage inputs to match your specific broker/exchange before trusting results for your own execution venue.
[/list]
[b]Tips for use[/b]
[list]
[*]Test each filter independently before stacking them
[*]The "All Agree" entry mode is the most conservative (fewer, higher-conviction trades); "Majority (2/3)" trades more often at the cost of some precision.
[*]This is a trend-following system — expect it to underperform in sideways/choppy markets even with filters on, and to shine during sustained directional moves. 
[*]Not financial advice — backtest on your own instruments/timeframes before risking capital.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blitz_locked

//@version=6
strategy("Triple Supertrend Strategy", overlay=true, fill_orders_on_standard_ohlc=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     commission_type=strategy.commission.percent, commission_value=0.05,
     slippage=2)
import TradingView/ta/13

//Input section
STgrp = "SuperTrend Settings"
st1Period = input.int(10, "Fast ST - ATR Period", group = STgrp)
st1Mult = input.float(1.5, "Fast ST - Multiplier", group = STgrp)

st2Period = input.int(14, "Medium ST - ATR Period", group = STgrp)
st2Mult = input.float(2.5, "Medium ST - Multiplier", group = STgrp)

st3Period = input.int(20, "Slow ST - ATR Period", group = STgrp)
st3Mult = input.float(3, "Slow ST - Multiplier", group = STgrp)

ADXgrp = "ADX Settngs"
adxDILength = input.int(14, "DI Length", group = ADXgrp)
adxSmooth = input.int(14, "ADX Smoothing",group = ADXgrp)
adxThreshold = input.float(25, "ADX Threshold (floor)",group = ADXgrp)
useAdxRising = input.bool(false, "Require rising ADX?", group = ADXgrp)
adxRisingLookback = input.int(3, "ADX Rising Lookback (Bars)",group = ADXgrp)

volGrp = "Volume Filter Settings"
useVolFilter = input.bool(false, "Use volume filter?", group = volGrp)
volMaLen = input.int(20, "Volume MA Length",group = volGrp)
volMult = input.float(1.2, "Volume Exceed MA Mult", group = volGrp)

HTFgrp = "Higher Timeframe Settings"
useHTFFiler = input.bool(false, "Use HTF filter?", group = HTFgrp)
htfTimeframe = input.timeframe("240","HTF Timeframe",group = HTFgrp)
htfStPeriod = input.int(14, "HTF ST - ATR Period", group = HTFgrp)
htfStMult = input.float(3.0, "HTF ST - ATR Multiplier", group = HTFgrp)

entryGrp = "Entry Settings"
entryType = input.string("All Agree", "Entry Mode", options=["All Agree","Majority (2/3)", "Fast Trigger, Slope Confirm"], group = entryGrp)

visGrp = "Visual Settings"
showCloud = input.bool(true, "Show Cloud Fill", group = visGrp)
showAdxGrad = input.bool(true, "Show ADX Gradient", group = visGrp)

grpRisk = "Risk / Position Sizing"
riskPercent  = input.float(1.0, "Risk % of Equity per Trade", minval=0.1, step=0.1, group=grpRisk)
useAtrSizing = input.bool(true, "Use ATR-Based Position Sizing", group=grpRisk)
atrFloorLen  = input.int(14, "ATR Floor Length", group=grpRisk)
atrFloorMult = input.float(0.5, "Min Stop Distance (x ATR)", step=0.1, group=grpRisk)

//Supertrend Calculations
[st1,dir1] = ta.supertrend(st1Mult,st1Period)
[st2,dir2] = ta.supertrend(st2Mult,st2Period)
[st3,dir3] = ta.supertrend(st3Mult,st3Period)

//close vs supertrend line, derive trend
trend1 = close>st1 ? 1 : -1 //fast
trend2 = close>st2 ? 1 : -1 //medium
trend3 = close>st3 ? 1 : -1 //slow

trendStrength = trend1 + trend2 + trend3 

//ADX Calc and Filter
[diPlus, diMinus, adx] = ta.dmi(adxDILength, adxSmooth)

adxStrong = adx>adxThreshold
adxRising = adx>adx[adxRisingLookback]
adxOk = adxStrong and (not useAdxRising or adxRising)

//Volume Filter
volAvg = ta.sma(volume,volMaLen)
volOk = not useVolFilter or (volume>volAvg*volMult)

//HTF Filter
//Function for trend, simplifying process, seeing close vs supertrend line
f_htfTrend(period,mult) => 
    [stLine,_d]=ta.supertrend(mult,period)
    close>stLine ? 1 : -1

htfTrend = request.security(syminfo.tickerid, htfTimeframe, f_htfTrend(htfStPeriod,htfStMult), lookahead = barmerge.lookahead_off)

htfOkayLong = not useHTFFiler or htfTrend == 1
htfOkayShort = not useHTFFiler or htfTrend == -1

// ATR Position Sizing
atrFloor = ta.atr(atrFloorLen) * atrFloorMult

stopDistLong  = math.max(close - st3, atrFloor)
stopDistShort = math.max(st3 - close, atrFloor)

riskAmount = strategy.equity * (riskPercent / 100)

qtyLong  = useAtrSizing ? riskAmount / stopDistLong  : (strategy.equity * 0.1) / close
qtyShort = useAtrSizing ? riskAmount / stopDistShort : (strategy.equity * 0.1) / close

//Entry Logic
bullConsensus = switch entryType 
    "All Agree" => trendStrength ==3
    "Majority (2/3)" => trendStrength >=1
    "Fast Trigger, Slope Confirm" => trend1 ==1 and trend3 ==1
    => false

bearConsensus = switch entryType 
    "All Agree" => trendStrength ==-3
    "Majority (2/3)" => trendStrength >=-1
    "Fast Trigger, Slope Confirm" => trend1 ==-1 and trend3 ==-1
    => false

diBull = diPlus>diMinus
diBear = diMinus>diPlus

longCondition = bullConsensus and adxOk and volOk and htfOkayLong and diBull
shortCondition = bearConsensus and adxOk and volOk and htfOkayShort and diBear

longExit = trend1==-1
shortExit = trend1==1

//Execution
if (longCondition)
    strategy.entry("long", strategy.long, qty=qtyLong)

if (shortCondition)
    strategy.entry("short", strategy.short, qty=qtyShort)

if (longExit)
    strategy.close("long")

if (shortExit)
    strategy.close("short")

// Enforced trailing stop at the slow SuperTrend line
if strategy.position_size > 0
    strategy.exit("Long Stop", "long", stop=st3)
if strategy.position_size < 0
    strategy.exit("Short Stop", "short", stop=st3)

//Visuals
// Cloud fill between Fast and Slow SuperTrend
p1 = plot(showCloud ? st1 : na, "Fast ST Line", color=trend1 == 1 ? color.new(color.green, 40) : color.new(color.red, 40))
p3 = plot(showCloud ? st3 : na, "Slow ST Line", color=trend3 == 1 ? color.new(color.green, 40) : color.new(color.red, 40))
cloudColor = trendStrength > 0 ? color.new(color.green, 88) : trendStrength < 0 ? color.new(color.red, 88) : color.new(color.gray, 92)
fill(p1, p3, color = showCloud ? cloudColor : na, title="Trend Cloud")

// ADX strength gradient background
// Maps ADX (0-100) to background transparency: stronger trend = more visible tint.
adxTransparency = math.max(60, 100 - adx)
adxBgColor = adx > adxThreshold ? (diBull ? color.new(color.teal, adxTransparency) : color.new(color.maroon, adxTransparency)) : na
bgcolor(showAdxGrad ? adxBgColor : na, title="ADX Strength Gradient")
````
