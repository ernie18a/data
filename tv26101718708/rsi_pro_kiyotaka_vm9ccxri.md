# RSI Pro - Kiyotaka

- url: https://www.tradingview.com/script/VM9ccXri-RSI-Pro-Kiyotaka/
- type: indicator
- pine_id: PUB;24f01db945714d35937354ec288b3a16
- version: 1.0

## Description

The RSI Pro is a D/7R-inspired advanced momentum oscillator that upgrades the standard Relative Strength Index (RSI). Instead of a single, jagged line that often gives false signals, this indicator smooths the data and uses multiple moving averages to create a visual
"Ribbon." It is designed to help traders identify trend strength and reversals without the noise associated with a standard RSI. 

How It Works: 
Dual RSIs: It calculates two RSIs: 
Fast RSI (14): Reacts quickly to price changes. 
Slow RSI (20): Reacts slower, filtering out noise. 
Smoothing: Both RSls are smoothed using an EMA (Exponential Moving Average) to remove the jagged "jitters" of raw price action. 
The Signal Line: A baseline (SMA) is plotted. The "Ribbon" is the shaded area between the RSIs and this Signal Line. 
Green Ribbon: The RSI is above the Signal Line (Bullish Momentum). 
Red Ribbon: The RSI is below the Signal Line (Bearish Momentum).

## Source Code

````pine
//@version=6
indicator("RSI Pro - Kiyotaka", shorttitle = "RSI Pro", overlay = false, behind_chart = false, max_labels_count = 500)

// =========================
// Inputs (matched to RSI Pro panel as closely as possible)
// =========================
plottingMode   = input.string("Bars", "Plotting Mode", options=["RSI Ribbon", "Bars", "Line", "Ribbon Line"])
highlightMode  = input.string("Momentum", "Highlight Mode", options=["None", "Mean Reversion", "Momentum"])
showCandles    = input.string("Trend Strength", "Candle Coloring", options=["Off", "Trend", "Mean-Reversion", "Trend Strength"])
sourceOpt      = input.string("OHLC4", "Source", options=["Close", "Open", "High", "Low", "HL2", "HLC3", "OHLC4"])
rawRsiType     = input.string("Wilder / RMA", "RSI Type", options=["Wilder / RMA", "EMA", "SMA / Cutler"])
fastRsiLen     = input.int(14, "Fast RSI Period", minval=1)
slowRsiLen     = input.int(20, "Slow RSI Period", minval=1)
emaSmoothLen   = input.int(3, "EMA Smooth", minval=1)
signalLen      = input.int(14, "Signal Line Length", minval=1)
signalBase     = input.string("Fast RSI", "Signal Source", options=["Fast RSI", "Slow RSI", "Average of Both"])
showLevels     = input.bool(true, "Show O/B O/S Levels")
obthres        = input.float(75.0, "Overbought Threshold", minval=0, maxval=100)
osthres        = input.float(25.0, "Oversold Threshold", minval=0, maxval=100)
showRawRsi     = input.bool(false, "Show Raw RSI")
showValues     = input.bool(true, "Show Latest Values Table")
showDivergence = input.bool(true, "Show Divergence Signals")
divMode        = input.string("Both", "Divergence Mode", options=["Confirmed", "Early", "Both"])
divSource      = input.string("Fast RSI", "Confirmed Divergence Source", options=["Fast RSI", "Slow RSI", "Signal"])
divLeft        = input.int(5, "Divergence Pivot Left", minval=1)
divRight       = input.int(5, "Divergence Pivot Right", minval=1)
earlyDivSource = input.string("Fast RSI", "Early Divergence Source", options=["Fast RSI", "Slow RSI"])
earlyLookback  = input.int(10, "Early Divergence Lookback", minval=2)
earlyBullMax   = input.float(35.0, "Early Bullish Zone Max", minval=0, maxval=100)
earlyBearMin   = input.float(65.0, "Early Bearish Zone Min", minval=0, maxval=100)
earlyUseTurn   = input.bool(true, "Early Divergence Use RSI Turn")
earlyUseCross  = input.bool(true, "Early Divergence Use Signal Cross")

bullColor      = input.color(color.rgb(96, 244, 220), "Bullish / O S Color")
bearColor      = input.color(color.rgb(255, 82, 82), "Bearish / O B Color")
sigColor       = input.color(color.white, "Signal Line Color")

// =========================
// Source selection
// =========================
src = switch sourceOpt
    "Close" => close
    "Open"  => open
    "High"  => high
    "Low"   => low
    "HL2"   => hl2
    "HLC3"  => hlc3
    => ohlc4

// =========================
// RSI functions
// =========================
rsi_rma(_src, _len) =>
    up = math.max(_src - _src[1], 0)
    dn = math.max(_src[1] - _src, 0)
    avgUp = ta.rma(up, _len)
    avgDn = ta.rma(dn, _len)
    avgDn == 0 ? 100 : avgUp == 0 ? 0 : 100 - (100 / (1 + avgUp / avgDn))

rsi_ema(_src, _len) =>
    up = math.max(_src - _src[1], 0)
    dn = math.max(_src[1] - _src, 0)
    avgUp = ta.ema(up, _len)
    avgDn = ta.ema(dn, _len)
    avgDn == 0 ? 100 : avgUp == 0 ? 0 : 100 - (100 / (1 + avgUp / avgDn))

rsi_sma(_src, _len) =>
    up = math.max(_src - _src[1], 0)
    dn = math.max(_src[1] - _src, 0)
    avgUp = ta.sma(up, _len)
    avgDn = ta.sma(dn, _len)
    avgDn == 0 ? 100 : avgUp == 0 ? 0 : 100 - (100 / (1 + avgUp / avgDn))

calcRsi(_src, _len) =>
    switch rawRsiType
        "Wilder / RMA" => rsi_rma(_src, _len)
        "EMA"          => rsi_ema(_src, _len)
        => rsi_sma(_src, _len)

// =========================
// Core logic inferred from the source labels + input names
// Fast RSI Period / Slow RSI Period appear to be RSI lengths,
// then both are EMA-smoothed by the shared EMA Smooth input.
// =========================
rawFast = calcRsi(src, fastRsiLen)
rawSlow = calcRsi(src, slowRsiLen)

smooth1 = ta.ema(rawFast, emaSmoothLen)
smooth2 = ta.ema(rawSlow, emaSmoothLen)

sigBase = switch signalBase
    "Fast RSI"         => smooth1
    "Slow RSI"         => smooth2
    => (smooth1 + smooth2) / 2.0
sig = ta.sma(sigBase, signalLen)

// =========================
// Colors
// =========================
posCol = bullColor
negCol = bearColor
posOne = color.new(bullColor, 0)
negOne = color.new(bearColor, 0)
posTwo = color.new(color.lime, 0)
negTwo = color.new(color.maroon, 0)
sigCol = sigColor
rawFastCol = color.new(color.aqua, 25)
rawSlowCol = color.new(color.orange, 25)

colFast = smooth1 >= sig ? posOne : negOne
colSlow = smooth2 >= sig ? posTwo : negTwo
colLine = smooth1 >= 50 ? posCol : negCol

// =========================
// Background highlight
// =========================
isSmooth1OB = smooth1 > obthres
isSmooth2OB = smooth2 > obthres
isSmooth1OS = smooth1 < osthres
isSmooth2OS = smooth2 < osthres

color bgCol = na
if highlightMode == "Mean Reversion"
    bgCol := isSmooth2OB ? color.new(negTwo, 88) : isSmooth1OB ? color.new(negOne, 88) : isSmooth2OS ? color.new(posTwo, 88) : isSmooth1OS ? color.new(posOne, 88) : na
else if highlightMode == "Momentum"
    bgCol := isSmooth2OB ? color.new(posTwo, 88) : isSmooth1OB ? color.new(posOne, 88) : isSmooth2OS ? color.new(negTwo, 88) : isSmooth1OS ? color.new(negOne, 88) : na
bgcolor(bgCol)

// =========================
// Levels
// =========================
plot(showLevels ? obthres : na, "OB", color=color.new(bearColor, 65), linewidth=1)
plot(showLevels ? 50 : na, "Mid", color=color.new(color.gray, 70), linewidth=1)
plot(showLevels ? osthres : na, "OS", color=color.new(bullColor, 65), linewidth=1)

// =========================
// Plotting
// =========================
pFast = plot(plottingMode == "Bars" ? na : smooth1, "Fast RSI", color=plottingMode == "Line" ? colLine : colFast, linewidth=2)
pSlow = plot(plottingMode == "RSI Ribbon" ? smooth2 : na, "Slow RSI", color=colSlow, linewidth=2)
pSig  = plot(plottingMode == "Bars" ? sig : plottingMode == "Line" or plottingMode == "Ribbon Line" or plottingMode == "RSI Ribbon" ? sig : na, "Signal", color=sigCol, linewidth=1)

plot(showRawRsi ? rawFast : na, "Raw Fast RSI", color=rawFastCol, linewidth=1)
plot(showRawRsi ? rawSlow : na, "Raw Slow RSI", color=rawSlowCol, linewidth=1)

fill(pFast, pSig, color=plottingMode == "RSI Ribbon" ? color.new(colFast, 84) : na, title="Fast Fill")
fill(pSlow, pSig, color=plottingMode == "RSI Ribbon" ? color.new(colSlow, 84) : na, title="Slow Fill")
fill(pFast, pSig, color=plottingMode == "Ribbon Line" ? color.new(colFast, 84) : na, title="Ribbon Fill")

plot(plottingMode == "Bars" ? smooth1 : na, "Fast RSI Bars", style=plot.style_columns, color=color.new(colFast, 10), histbase=50, linewidth=2)
plot(plottingMode == "Bars" ? smooth2 : na, "Slow RSI Bars", style=plot.style_columns, color=color.new(colSlow, 50), histbase=50, linewidth=2)
plot(plottingMode == "Bars" ? sig : na, "Signal Bars Mode", color=sigCol, linewidth=1)

// =========================
// Divergence
// Confirmed = pivot-based regular divergence.
// Early = rolling-window divergence with RSI turn and/or signal cross filter.
// =========================
showConfirmedDiv = showDivergence and (divMode == "Confirmed" or divMode == "Both")
showEarlyDiv = showDivergence and (divMode == "Early" or divMode == "Both")

confirmedSeries = switch divSource
    "Fast RSI" => smooth1
    "Slow RSI" => smooth2
    => sig

earlySeries = switch earlyDivSource
    "Fast RSI" => smooth1
    => smooth2

// Confirmed divergence (regular bullish / bearish)
oscPivotLow = ta.pivotlow(confirmedSeries, divLeft, divRight)
oscPivotHigh = ta.pivothigh(confirmedSeries, divLeft, divRight)

prevPriceLow = ta.valuewhen(not na(oscPivotLow), low[divRight], 1)
prevOscLow = ta.valuewhen(not na(oscPivotLow), oscPivotLow, 1)
prevPriceHigh = ta.valuewhen(not na(oscPivotHigh), high[divRight], 1)
prevOscHigh = ta.valuewhen(not na(oscPivotHigh), oscPivotHigh, 1)

bullDiv = showConfirmedDiv and not na(oscPivotLow) and not na(prevPriceLow) and not na(prevOscLow) and low[divRight] < prevPriceLow and oscPivotLow > prevOscLow
bearDiv = showConfirmedDiv and not na(oscPivotHigh) and not na(prevPriceHigh) and not na(prevOscHigh) and high[divRight] > prevPriceHigh and oscPivotHigh < prevOscHigh

// Early divergence
priorPriceLow = ta.lowest(low[1], earlyLookback)
priorPriceHigh = ta.highest(high[1], earlyLookback)
priorOscLow = ta.lowest(earlySeries[1], earlyLookback)
priorOscHigh = ta.highest(earlySeries[1], earlyLookback)

priceBreakLow = low < priorPriceLow
priceBreakHigh = high > priorPriceHigh
oscHoldLow = earlySeries > priorOscLow
oscHoldHigh = earlySeries < priorOscHigh

bullTurn = earlySeries > earlySeries[1]
bearTurn = earlySeries < earlySeries[1]
bullCross = ta.crossover(earlySeries, sig)
bearCross = ta.crossunder(earlySeries, sig)

earlyBullTrigger = (earlyUseTurn and bullTurn) or (earlyUseCross and bullCross)
earlyBearTrigger = (earlyUseTurn and bearTurn) or (earlyUseCross and bearCross)

earlyBullRaw = priceBreakLow and oscHoldLow and earlySeries < earlyBullMax and earlyBullTrigger
earlyBearRaw = priceBreakHigh and oscHoldHigh and earlySeries > earlyBearMin and earlyBearTrigger

earlyBullDiv = showEarlyDiv and earlyBullRaw and not earlyBullRaw[1]
earlyBearDiv = showEarlyDiv and earlyBearRaw and not earlyBearRaw[1]

plotshape(bullDiv ? confirmedSeries[divRight] : na, title="Confirmed Bull Div", style=shape.triangleup, location=location.absolute, color=color.new(bullColor, 0), text="C", textcolor=color.black, size=size.tiny, offset=-divRight)
plotshape(bearDiv ? confirmedSeries[divRight] : na, title="Confirmed Bear Div", style=shape.triangledown, location=location.absolute, color=color.new(bearColor, 0), text="C", textcolor=color.white, size=size.tiny, offset=-divRight)
plotshape(earlyBullDiv ? earlySeries : na, title="Early Bull Div", style=shape.circle, location=location.absolute, color=color.new(bullColor, 45), text="E", textcolor=color.black, size=size.tiny)
plotshape(earlyBearDiv ? earlySeries : na, title="Early Bear Div", style=shape.circle, location=location.absolute, color=color.new(bearColor, 45), text="E", textcolor=color.white, size=size.tiny)

alertcondition(bullDiv, title="Confirmed Bullish Divergence", message="Confirmed bullish divergence detected on Kiyotaka RSI Ribbon Clone")
alertcondition(bearDiv, title="Confirmed Bearish Divergence", message="Confirmed bearish divergence detected on Kiyotaka RSI Ribbon Clone")
alertcondition(earlyBullDiv, title="Early Bullish Divergence", message="Early bullish divergence detected on Kiyotaka RSI Ribbon Clone")
alertcondition(earlyBearDiv, title="Early Bearish Divergence", message="Early bearish divergence detected on Kiyotaka RSI Ribbon Clone")

// =========================
// Candle coloring on the main chart
// =========================
// Seven-stop gradient matching the earlier Kiyotaka-style conversion.
// Values below 20 remain at the first palette color; values above 80 remain
// at the final palette color.
f_candleGradient7(
     float value,
     color c20,
     color c30,
     color c40,
     color c50,
     color c60,
     color c70,
     color c80) =>
    float v = math.max(20.0, math.min(80.0, value))
    v <= 30.0 ? color.from_gradient(v, 20.0, 30.0, c20, c30) :
     v <= 40.0 ? color.from_gradient(v, 30.0, 40.0, c30, c40) :
     v <= 50.0 ? color.from_gradient(v, 40.0, 50.0, c40, c50) :
     v <= 60.0 ? color.from_gradient(v, 50.0, 60.0, c50, c60) :
     v <= 70.0 ? color.from_gradient(v, 60.0, 70.0, c60, c70) :
                 color.from_gradient(v, 70.0, 80.0, c70, c80)

// Mean Reversion: extreme oversold = green; extreme overbought = orange/red.
meanRevColor = f_candleGradient7(
     smooth1,
     #51F703,
     #308D9F,
     #235767,
     color.gray,
     #9C2E2E,
     #DF3738,
     #FA971F)

// Trend Strength: bullish RSI strength = green/teal; bearish RSI strength = orange/red.
trendStrengthColor = f_candleGradient7(
     smooth1,
     #FA971F,
     #DF3738,
     #9C2E2E,
     color.gray,
     #235767,
     #308D9F,
     #51F703)

// Trend mode keeps the selectable bullish/bearish input colors.
trendColor = smooth1 >= 50 ? posCol : negCol

color barCol = switch showCandles
    "Trend"          => trendColor
    "Mean-Reversion" => meanRevColor
    "Trend Strength" => trendStrengthColor
    => na

bool showColoredCandles = showCandles != "Off"

// Retain native bar coloring where the chart allows it.
barcolor(barCol, title = "Native Candle Coloring", editable = false)

// Overlay candles on the main chart so colors display consistently.
plotcandle(
     showColoredCandles ? open : na,
     showColoredCandles ? high : na,
     showColoredCandles ? low : na,
     showColoredCandles ? close : na,
     title = "RSI Colored Candle Overlay",
     color = barCol,
     wickcolor = barCol,
     bordercolor = barCol,
     editable = false,
     force_overlay = true)

// =========================
// Value display
// =========================
var table t = table.new(position.top_right, 2, 5, border_width=1)
if barstate.islast and showValues
    table.cell(t, 0, 0, "Fast", text_color=color.white, bgcolor=color.new(colFast, 70))
    table.cell(t, 1, 0, str.tostring(smooth1, format.mintick), text_color=color.white, bgcolor=color.new(colFast, 85))
    table.cell(t, 0, 1, "Slow", text_color=color.white, bgcolor=color.new(colSlow, 70))
    table.cell(t, 1, 1, str.tostring(smooth2, format.mintick), text_color=color.white, bgcolor=color.new(colSlow, 85))
    table.cell(t, 0, 2, "Signal", text_color=color.white, bgcolor=color.new(sigCol, 70))
    table.cell(t, 1, 2, str.tostring(sig, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 0, 3, "Raw Fast", text_color=color.white, bgcolor=color.new(rawFastCol, 70))
    table.cell(t, 1, 3, str.tostring(rawFast, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(t, 0, 4, "Raw Slow", text_color=color.white, bgcolor=color.new(rawSlowCol, 70))
    table.cell(t, 1, 4, str.tostring(rawSlow, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0))
else if barstate.islast and not showValues
    table.clear(t, 0, 0, 1, 4)
````
