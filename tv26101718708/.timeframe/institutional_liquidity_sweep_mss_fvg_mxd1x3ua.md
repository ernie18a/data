# Institutional Liquidity Sweep + MSS + FVG

- url: https://www.tradingview.com/script/MXD1x3ua-Institutional-Liquidity-Sweep-MSS-FVG/
- type: indicator
- pine_id: PUB;d82a153eadf740db98ff26de04263be0
- version: 5.0

## Description

Session based liquidity sweep for Asia, London and NY levels that uses MSS + FVG to give signals for long or short

## Source Code

````pine
//@version=5
indicator("Advanced SMC Liquidity Sweep + MSS + FVG", overlay=true, max_labels_count=500, max_boxes_count=500)

// =====================================================
// INPUTS
// =====================================================
emaLen         = input.int(50, "EMA Length")
useEMA         = input.bool(true, "Use EMA Trend Filter")
showLiquidity  = input.bool(true, "Show Liquidity Levels")
showSessions   = input.bool(true, "Show Session Backgrounds")
showFVG        = input.bool(true, "Show FVG Boxes")
useVolume      = input.bool(true, "Use Volume Filter")

// =====================================================
// STYLE COLORS
// =====================================================

// Asia
asiaHighColor   = input.color(color.aqua, "Asia High")
asiaLowColor    = input.color(color.aqua, "Asia Low")

// London
londonHighColor = input.color(color.blue, "London High")
londonLowColor  = input.color(color.navy, "London Low")

// New York
nyHighColor     = input.color(color.purple, "New York High")
nyLowColor      = input.color(color.maroon, "New York Low")

// PDH / PDL
pdhColor        = input.color(color.orange, "PDH")
pdlColor        = input.color(color.orange, "PDL")

// 4H
fourHHighColor  = input.color(color.teal, "4H High")
fourHLowColor   = input.color(color.teal, "4H Low")

// =====================================================
// EMA FILTER
// =====================================================
ema = ta.ema(close, emaLen)

plot(useEMA ? ema : na,
     title="EMA",
     color=color.orange,
     linewidth=2)

bullTrend = close > ema
bearTrend = close < ema

// =====================================================
// SESSION DEFINITIONS
// =====================================================
asia     = not na(time(timeframe.period, "1900-0000"))
london   = not na(time(timeframe.period, "0300-0600"))
newyork  = not na(time(timeframe.period, "0830-1100"))

// =====================================================
// SESSION BACKGROUNDS
// =====================================================
bgcolor(showSessions and asia ? color.new(color.gray, 92) : na)
bgcolor(showSessions and london ? color.new(color.blue, 92) : na)
bgcolor(showSessions and newyork ? color.new(color.purple, 92) : na)

// =====================================================
// SESSION LIQUIDITY TRACKING
// =====================================================
var float asiaHigh = na
var float asiaLow = na

var float londonHigh = na
var float londonLow = na

var float nyHigh = na
var float nyLow = na

// Asia
if asia and not asia[1]
    asiaHigh := high
    asiaLow := low

if asia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

// London
if london and not london[1]
    londonHigh := high
    londonLow := low

if london
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

// New York
if newyork and not newyork[1]
    nyHigh := high
    nyLow := low

if newyork
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

// =====================================================
// PREVIOUS DAY + 4H LEVELS
// =====================================================
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])

fourHHigh = request.security(syminfo.tickerid, "240", high[1])
fourHLow = request.security(syminfo.tickerid, "240", low[1])

// =====================================================
// LIQUIDITY PLOTS
// =====================================================

// Asia
plot(showLiquidity ? asiaHigh : na,
     title="Asia High",
     color=asiaHighColor,
     linewidth=2)

plot(showLiquidity ? asiaLow : na,
     title="Asia Low",
     color=asiaLowColor,
     linewidth=2)

// London
plot(showLiquidity ? londonHigh : na,
     title="London High",
     color=londonHighColor,
     linewidth=2)

plot(showLiquidity ? londonLow : na,
     title="London Low",
     color=londonLowColor,
     linewidth=2)

// New York
plot(showLiquidity ? nyHigh : na,
     title="New York High",
     color=nyHighColor,
     linewidth=2)

plot(showLiquidity ? nyLow : na,
     title="New York Low",
     color=nyLowColor,
     linewidth=2)

// PDH / PDL
plot(showLiquidity ? pdh : na,
     title="PDH",
     color=pdhColor,
     linewidth=2)

plot(showLiquidity ? pdl : na,
     title="PDL",
     color=pdlColor,
     linewidth=2)

// 4H HIGH / LOW
plot(showLiquidity ? fourHHigh : na,
     title="4H High",
     color=fourHHighColor,
     linewidth=2)

plot(showLiquidity ? fourHLow : na,
     title="4H Low",
     color=fourHLowColor,
     linewidth=2)

// =====================================================
// VOLUME FILTER
// =====================================================
volMA = ta.sma(volume, 20)
volumeValid = volume > volMA

// =====================================================
// FAIR VALUE GAPS
// =====================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

// Bullish FVG
bullTop = low
bullBottom = high[2]

// Bearish FVG
bearTop = low[2]
bearBottom = high

// =====================================================
// FVG BOXES
// =====================================================
if showFVG and bullFVG
    box.new(
         left=bar_index-2,
         top=bullTop,
         right=bar_index+5,
         bottom=bullBottom,
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if showFVG and bearFVG
    box.new(
         left=bar_index-2,
         top=bearTop,
         right=bar_index+5,
         bottom=bearBottom,
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

// =====================================================
// LIQUIDITY SWEEPS
// =====================================================

// Asia
asiaBullSweep =
     low < asiaLow and
     close > asiaLow

asiaBearSweep =
     high > asiaHigh and
     close < asiaHigh

// London
londonBullSweep =
     low < londonLow and
     close > londonLow

londonBearSweep =
     high > londonHigh and
     close < londonHigh

// New York
nyBullSweep =
     low < nyLow and
     close > nyLow

nyBearSweep =
     high > nyHigh and
     close < nyHigh

// PDH / PDL
pdlSweep =
     low < pdl and
     close > pdl

pdhSweep =
     high > pdh and
     close < pdh

// 4H
fourHBullSweep =
     low < fourHLow and
     close > fourHLow

fourHBearSweep =
     high > fourHHigh and
     close < fourHHigh

// =====================================================
// COMBINED SWEEP CONDITIONS
// =====================================================
longSweep =
     asiaBullSweep or
     londonBullSweep or
     nyBullSweep or
     pdlSweep or
     fourHBullSweep

shortSweep =
     asiaBearSweep or
     londonBearSweep or
     nyBearSweep or
     pdhSweep or
     fourHBearSweep

// =====================================================
// MSS
// =====================================================
longMSS =
     longSweep[1] and
     close > high[1]

shortMSS =
     shortSweep[1] and
     close < low[1]

// =====================================================
// DISPLACEMENT
// =====================================================
atr = ta.atr(14)

bullDisplacement =
     close > open and
     (close - open) > atr * 0.5

bearDisplacement =
     close < open and
     (open - close) > atr * 0.5

// =====================================================
// FINAL SIGNALS
// =====================================================
longSignal =
     longSweep and
     longMSS and
     bullFVG and
     bullDisplacement and
     bullTrend and
     (not useVolume or volumeValid)

shortSignal =
     shortSweep and
     shortMSS and
     bearFVG and
     bearDisplacement and
     bearTrend and
     (not useVolume or volumeValid)

// =====================================================
// LONG LABEL
// =====================================================
if longSignal
    label.new(
         x=bar_index,
         y=low,
         text="Long",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.normal)

// =====================================================
// SHORT LABEL
// =====================================================
if shortSignal
    label.new(
         x=bar_index,
         y=high,
         text="Short",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal)

// =====================================================
// ALERTS
// =====================================================
alertcondition(
     longSignal,
     title="Long Signal",
     message="Bullish Liquidity Sweep + MSS + FVG")

alertcondition(
     shortSignal,
     title="Short Signal",
     message="Bearish Liquidity Sweep + MSS + FVG")
````
