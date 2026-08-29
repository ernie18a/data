<!-- tradingview-pine-id: PUB;ba5a9f3a149c4226a1b1a8fc92b30302 -->
<!-- tradingviewscripts-format: 1 -->
# QQQ Gamma Pro A+ System

Source: https://www.tradingview.com/script/GQA9wDPo-QQQ-Gamma-Pro-A-System/

## Description

QQQ Gamma Pro A+ System is a high‑precision market‑timing indicator designed for traders who want clean, rules‑based signals on QQQ using institutional‑style data. It combines trend structure, volatility confirmation, and a proprietary gamma‑based market bias to identify only the highest‑quality A+ setups.

The system begins with a Trend Engine built on EMA alignment and VWAP positioning. This ensures signals only appear when the market is trending cleanly — either strongly bullish or strongly bearish. Momentum filters such as RSI and ATR expansion add an additional layer of confirmation, helping traders avoid low‑probability conditions.

A unique Gamma Proxy Engine analyzes SPY, QQQ, and IWM to determine underlying market pressure. When gamma is negative, the system becomes more selective, filtering out weak setups and highlighting only the most favorable opportunities. Gamma bias is displayed visually through chart background coloring and a mobile‑friendly dashboard.

The indicator plots A+ BUY and A+ SELL signals directly on the chart when trend, gamma, and momentum align. These signals are designed for intraday and swing traders who want structured, disciplined entries without noise.

To support opening‑range strategies, the system automatically tracks the Opening Range High and Low, giving traders a real‑time structure reference for breakouts, reversals, and liquidity sweeps.

A built‑in Mobile Dashboard displays gamma values, directional bias, and real‑time market regime information, making the indicator easy to monitor from any device. Alerts are included for both BUY and SELL signals.

🔥 Key Features
EMA + VWAP trend engine

RSI and ATR momentum filters

Gamma‑based market bias using SPY, QQQ, and IWM

A+ long and short signal detection

Opening Range High/Low tracking

Mobile‑optimized dashboard

Market regime background coloring

Built‑in BUY/SELL alerts

---

## Source Code

````pine
//@version=6
indicator("QQQ Gamma Pro A+ System", shorttitle="QQQ Gamma PRO", overlay=true, max_labels_count=500)


//====================================================
// INPUTS
//====================================================

trendGroup = "Trend Settings"

emaFastLen = input.int(9, "EMA Fast", group=trendGroup)
emaSlowLen = input.int(21, "EMA Slow", group=trendGroup)
emaTrendLen = input.int(200, "EMA Trend", group=trendGroup)


filterGroup = "Filters"

useRSI = input.bool(true, "Use RSI Filter", group=filterGroup)
rsiLength = input.int(14, "RSI Length", group=filterGroup)

useATR = input.bool(true, "Use ATR Filter", group=filterGroup)
atrLength = input.int(14, "ATR Length", group=filterGroup)



gammaGroup = "Gamma Engine"

gammaLength = input.int(20, "Gamma Lookback", group=gammaGroup)

gammaExtreme = input.float(
     2.0,
     "Extreme Gamma Level",
     step=0.1,
     group=gammaGroup)


symbol1 = input.symbol("SPY","Symbol 1",group=gammaGroup)
symbol2 = input.symbol("QQQ","Symbol 2",group=gammaGroup)
symbol3 = input.symbol("IWM","Symbol 3",group=gammaGroup)



//====================================================
// TREND
//====================================================

ema9 = ta.ema(close,emaFastLen)
ema21 = ta.ema(close,emaSlowLen)
ema200 = ta.ema(close,emaTrendLen)

vwapValue = ta.vwap(close)


bullTrend =
 close > ema200 and
 close > vwapValue and
 ema9 > ema21


bearTrend =
 close < ema200 and
 close < vwapValue and
 ema9 < ema21



//====================================================
// FILTERS
//====================================================

rsiValue = ta.rsi(close,rsiLength)

rsiBull = rsiValue > 50
rsiBear = rsiValue < 50


atrValue = ta.atr(atrLength)

atrOK = atrValue > ta.sma(atrValue,20)



//====================================================
// GAMMA PROXY FUNCTION
//====================================================

gammaCalc() =>

    basis = ta.sma(close,gammaLength)

    deviation = ta.stdev(close,gammaLength)

    deviation != 0 ?
     (close - basis) / deviation :
     0



//====================================================
// GAMMA DATA
//====================================================

spyGamma =
 request.security(symbol1,timeframe.period,gammaCalc())


qqqGamma =
 request.security(symbol2,timeframe.period,gammaCalc())


iwmGamma =
 request.security(symbol3,timeframe.period,gammaCalc())



//====================================================
// A+ SETUPS
//====================================================

longSignal =

 bullTrend and
 qqqGamma < 0 and
 low <= ema9 and
 close > ema9 and
 (not useRSI or rsiBull) and
 (not useATR or atrOK)



shortSignal =

 bearTrend and
 qqqGamma < 0 and
 high >= ema9 and
 close < ema9 and
 (not useRSI or rsiBear) and
 (not useATR or atrOK)



//====================================================
// OPENING RANGE
//====================================================

var float openingHigh = na
var float openingLow = na


newDay = ta.change(time("D"))


if bool(newDay)
    openingHigh := high
    openingLow := low
else
    openingHigh := math.max(openingHigh,high)
    openingLow := math.min(openingLow,low)



//====================================================
// PLOTS
//====================================================

plot(ema9,"EMA 9",color=color.yellow,linewidth=2)

plot(ema21,"EMA 21",color=color.blue,linewidth=2)

plot(ema200,"EMA 200",color=color.purple,linewidth=3)

plot(vwapValue,"VWAP",color=color.white,linewidth=2)

plot(openingHigh,"Opening High",color=color.green)

plot(openingLow,"Opening Low",color=color.red)



plotshape(
 longSignal,
 title="BUY",
 text="A+",
 style=shape.labelup,
 color=color.lime,
 textcolor=color.black,
 location=location.belowbar)



plotshape(
 shortSignal,
 title="SELL",
 text="A+",
 style=shape.labeldown,
 color=color.red,
 textcolor=color.white,
 location=location.abovebar)



//====================================================
// ALERTS
//====================================================

alertcondition(
 longSignal,
 title="QQQ A+ BUY",
 message="QQQ Gamma Pro A+ BUY")


alertcondition(
 shortSignal,
 title="QQQ A+ SELL",
 message="QQQ Gamma Pro A+ SELL")



//====================================================
// MOBILE DASHBOARD
//====================================================

dashGroup="Mobile Dashboard"

showDashboard =
 input.bool(true,"Show Dashboard",group=dashGroup)


dashboardSizeInput =
 input.string(
 "Small",
 "Dashboard Size",
 options=[
 "Tiny",
 "Small",
 "Normal",
 "Large"],
 group=dashGroup)



dashboardPositionInput =
 input.string(
 "Top Right",
 "Dashboard Position",
 options=[
 "Top Right",
 "Top Left",
 "Bottom Right",
 "Bottom Left"],
 group=dashGroup)



dashSize =
 dashboardSizeInput=="Tiny" ? size.tiny :
 dashboardSizeInput=="Small" ? size.small :
 dashboardSizeInput=="Normal" ? size.normal :
 size.large



dashPosition =
 dashboardPositionInput=="Top Right" ?
 position.top_right :
 dashboardPositionInput=="Top Left" ?
 position.top_left :
 dashboardPositionInput=="Bottom Right" ?
 position.bottom_right :
 position.bottom_left



var table dashboard =
 table.new(
 dashPosition,
 4,
 4,
 bgcolor=color.new(color.black,85),
 border_width=1)



// Dashboard row function

fillRow(sym,value,row)=>

    gammaColor =
     value >= 0 ?
     color.green :
     color.red


    table.cell(
     dashboard,
     0,
     row,
     sym,
     text_size=dashSize)


    table.cell(
     dashboard,
     1,
     row,
     value >= 0 ? "POS":"NEG",
     text_color=gammaColor,
     text_size=dashSize)


    table.cell(
     dashboard,
     2,
     row,
     str.tostring(value,"#.##"),
     text_size=dashSize)


    table.cell(
     dashboard,
     3,
     row,
     value > gammaExtreme ?
     "BULL" :
     value < -gammaExtreme ?
     "BEAR" :
     "WAIT",
     text_size=dashSize)



if barstate.islast and showDashboard

    table.cell(dashboard,0,0,"SYM",text_size=dashSize,text_color=color.white)
    table.cell(dashboard,1,0,"GAM",text_size=dashSize,text_color=color.white)
    table.cell(dashboard,2,0,"VAL",text_size=dashSize,text_color=color.white)
    table.cell(dashboard,3,0,"BIAS",text_size=dashSize,text_color=color.white)


    fillRow(symbol1,spyGamma,1)

    fillRow(symbol2,qqqGamma,2)

    fillRow(symbol3,iwmGamma,3)



//====================================================
// MARKET REGIME BACKGROUND
//====================================================

bgcolor(
 qqqGamma < 0 ?
 color.new(color.red,90) :
 color.new(color.green,90))
````
