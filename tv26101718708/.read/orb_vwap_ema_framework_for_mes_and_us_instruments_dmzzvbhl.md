# ORB VWAP EMA Framework for MES and U.S. Instruments

- url: https://www.tradingview.com/script/dmzZvbHl-ORB-VWAP-EMA-Framework-for-MES-and-U-S-Instruments/
- type: indicator
- pine_id: PUB;27ee07b8a82047c888929ba891554451
- version: 1.0

## Description

The ORB VWAP EMA Framework for MES and U.S. Instruments is an intraday chart-analysis indicator designed to support a structured Opening Range Breakout workflow across Micro E-mini S&P 500 futures and other U.S. market instruments that respond to the New York regular session open. It plots VWAP, 4 EMA, 9 EMA, Previous Day High/Low, Overnight High/Low, and the 15-minute Regular Trading Hours Opening Range, with optional range shading for added visual context. The script also identifies breakout, retest, and confirmation events to help standardize market review and rule-based intraday analysis. Individual label groups can be enabled or disabled in settings to suit different chart preferences and levels of visual detail. Although optimized for MES, the framework can also be applied to other U.S. index futures, stocks, and ETFs where the New York session open and opening range behavior are relevant. This indicator is intended as a decision-support and market-structure visualization tool for disciplined analysis and testing, and does not represent any claim of profitability or predictive performance.

How to use
Apply the indicator to an intraday chart, commonly a 5-minute chart, and use the plotted Opening Range, VWAP, EMA structure, and key session reference levels to evaluate price behavior during Regular Trading Hours. The framework is optimized for MES but can also be used on other U.S. index futures, stocks, and ETFs where the New York session open is a meaningful source of intraday price discovery. Breakout, retest, and confirmation labels can be used to organize chart review and assess whether price is interacting with the Opening Range in alignment with broader directional structure. Label visibility controls in settings allow the display to be adjusted for different workflows and levels of chart detail.

## Source Code

````pine
//@version=6
indicator("MES ORB VWAP EMA", overlay=true, max_labels_count=500)

//====================================================
// INPUTS
//====================================================
emaFastLength         = input.int(4, "Fast EMA Length", minval=1)
emaSlowLength         = input.int(9, "Slow EMA Length", minval=1)

showPDLevels          = input.bool(true, "Show Previous Day High/Low")
showONLevels          = input.bool(true, "Show Overnight High/Low")
showORBLevels         = input.bool(true, "Show 15-Minute ORB High/Low")
showORBShade          = input.bool(true, "Shade ORB Area")

showEMABuySellLabels  = input.bool(true, "Show EMA BUY/SELL Labels")
showBreakoutLabels    = input.bool(true, "Show ORB Breakout Labels")
showRetestLabels      = input.bool(true, "Show ORB Retest Labels")
showConfirmLabels     = input.bool(true, "Show Confirmation Labels")

highlightBreakouts    = input.bool(true, "Highlight Breakout Bars")

overnightSession = input.session("1800-0929", "Overnight Session")
orbSession       = input.session("0930-0945", "ORB Session (New York Time)")
rthSession       = input.session("0930-1600", "RTH Session (New York Time)")

//====================================================
// CORE CALCULATIONS
//====================================================
emaFast = ta.ema(close, emaFastLength)
emaSlow = ta.ema(close, emaSlowLength)
vwapVal = ta.vwap(hlc3)

pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

//====================================================
// DAY RESET
//====================================================
newDay = ta.change(time("D")) != 0

//====================================================
// SESSION STATE
//====================================================
inOvernight = not na(time(timeframe.period, overnightSession, "America/New_York"))
inORB       = not na(time(timeframe.period, orbSession, "America/New_York"))
inRTH       = not na(time(timeframe.period, rthSession, "America/New_York"))

//====================================================
// OVERNIGHT HIGH / LOW
//====================================================
var float onh = na
var float onl = na

if newDay
    onh := na
    onl := na

if inOvernight
    onh := na(onh) ? high : math.max(onh, high)
    onl := na(onl) ? low  : math.min(onl, low)

//====================================================
// EMA CROSS CONDITIONS
//====================================================
bullCross = ta.crossover(emaFast, emaSlow)
bearCross = ta.crossunder(emaFast, emaSlow)

//====================================================
// TREND FILTERS
//====================================================
longTrendOk  = close > vwapVal and emaFast > emaSlow
shortTrendOk = close < vwapVal and emaFast < emaSlow

//====================================================
// 15-MINUTE ORB HIGH / LOW
//====================================================
var float orbHigh = na
var float orbLow  = na

if newDay
    orbHigh := na
    orbLow  := na

if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow, low)

orbReady = not na(orbHigh) and not na(orbLow) and not inORB

//====================================================
// STATE VARIABLES
//====================================================
var bool bullBreakoutSeen   = false
var bool bearBreakoutSeen   = false
var bool bullRetestSeen     = false
var bool bearRetestSeen     = false
var bool waitBullConfirm    = false
var bool waitBearConfirm    = false
var bool bullConfirmSeen    = false
var bool bearConfirmSeen    = false

if newDay
    bullBreakoutSeen := false
    bearBreakoutSeen := false
    bullRetestSeen   := false
    bearRetestSeen   := false
    waitBullConfirm  := false
    waitBearConfirm  := false
    bullConfirmSeen  := false
    bearConfirmSeen  := false

//====================================================
// BREAKOUT DETECTION
//====================================================
bullBreakout = inRTH and orbReady and close > orbHigh and not bullBreakoutSeen
bearBreakout = inRTH and orbReady and close < orbLow and not bearBreakoutSeen

if bullBreakout
    bullBreakoutSeen := true

if bearBreakout
    bearBreakoutSeen := true

//====================================================
// RETEST DETECTION
//====================================================
rawBullRetest = inRTH and orbReady and bullBreakoutSeen and not bullRetestSeen and low <= orbHigh and close > orbHigh and not bullBreakout
rawBearRetest = inRTH and orbReady and bearBreakoutSeen and not bearRetestSeen and high >= orbLow and close < orbLow and not bearBreakout

bullRetest = rawBullRetest and longTrendOk
bearRetest = rawBearRetest and shortTrendOk

if bullRetest
    bullRetestSeen  := true
    waitBullConfirm := true

if bearRetest
    bearRetestSeen  := true
    waitBearConfirm := true

//====================================================
// CONFIRMATION CANDLE LOGIC
//====================================================
bullConfirm = inRTH and waitBullConfirm and not bullConfirmSeen and close > open and close > high[1]
bearConfirm = inRTH and waitBearConfirm and not bearConfirmSeen and close < open and close < low[1]

if bullConfirm
    bullConfirmSeen := true
    waitBullConfirm := false

if bearConfirm
    bearConfirmSeen := true
    waitBearConfirm := false

//====================================================
// VISUAL COLORING
//====================================================
breakoutBarColor = highlightBreakouts ? (bullBreakout ? color.lime : bearBreakout ? color.red : na) : na
breakoutBgColor  = highlightBreakouts ? (bullBreakout ? color.new(color.lime, 85) : bearBreakout ? color.new(color.red, 85) : na) : na

barcolor(breakoutBarColor)
bgcolor(breakoutBgColor)

//====================================================
// PLOTS
//====================================================
plot(emaFast, "4 EMA", color=color.green, linewidth=2)
plot(emaSlow, "9 EMA", color=color.orange, linewidth=2)
plot(vwapVal, "VWAP", color=color.blue, linewidth=2)

plot(showPDLevels ? pdh : na, "PDH", color=color.fuchsia, linewidth=2, style=plot.style_linebr)
plot(showPDLevels ? pdl : na, "PDL", color=color.fuchsia, linewidth=2, style=plot.style_linebr)

plot(showONLevels ? onh : na, "ONH", color=color.aqua, linewidth=2, style=plot.style_linebr)
plot(showONLevels ? onl : na, "ONL", color=color.aqua, linewidth=2, style=plot.style_linebr)

orbHighPlot = plot(showORBLevels ? orbHigh : na, "ORB High", color=color.yellow, linewidth=2, style=plot.style_linebr)
orbLowPlot  = plot(showORBLevels ? orbLow  : na, "ORB Low",  color=color.yellow, linewidth=2, style=plot.style_linebr)

fill(orbHighPlot, orbLowPlot, color=showORBShade ? color.new(color.yellow, 85) : na, title="ORB Area")

//====================================================
// EMA BUY/SELL LABELS
//====================================================
plotshape(showEMABuySellLabels and bullCross, title="Bull Cross", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small, text="BUY")
plotshape(showEMABuySellLabels and bearCross, title="Bear Cross", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small, text="SELL")

//====================================================
// LABEL OFFSETS
//====================================================
labelOffset = syminfo.mintick * 20

//====================================================
// BREAKOUT LABELS
//====================================================
if showBreakoutLabels and bullBreakout
    label.new(bar_index, low - labelOffset, "ORB LONG", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.normal)

if showBreakoutLabels and bearBreakout
    label.new(bar_index, high + labelOffset, "ORB SHORT", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)

//====================================================
// RETEST LABELS
//====================================================
if showRetestLabels and bullRetest
    label.new(bar_index, low - labelOffset, "RETEST LONG", style=label.style_label_up, color=color.teal, textcolor=color.white, size=size.normal)

if showRetestLabels and bearRetest
    label.new(bar_index, high + labelOffset, "RETEST SHORT", style=label.style_label_down, color=color.maroon, textcolor=color.white, size=size.normal)

//====================================================
// CONFIRMATION LABELS
//====================================================
if showConfirmLabels and bullConfirm
    label.new(bar_index, low - labelOffset, "CONFIRM LONG", style=label.style_label_up, color=color.blue, textcolor=color.white, size=size.normal)

if showConfirmLabels and bearConfirm
    label.new(bar_index, high + labelOffset, "CONFIRM SHORT", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.normal)
````
