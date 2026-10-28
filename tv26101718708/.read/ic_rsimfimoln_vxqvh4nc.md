# IC RSI+MFI+MOLN

- url: https://www.tradingview.com/script/VxqVh4Nc-IC-RSI-MFI-MOLN/
- type: indicator
- pine_id: PUB;eaa68fd9092d41a1aae24e040a66e0a1
- version: 1.0

## Description

Indicator that helps with both RSI & MACD, Clouds to see breaks, 
buy and sell signals based on volumes, 
simple indicator for overview! 

works in all TF 
you also see HTF trend etc.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Westfelt

//@version=6
indicator("IC RSI+MFI", overlay=false, shorttitle="IC RSI+MFI", precision=2, max_labels_count=500)

// ========== INPUT SETTINGS ==========
rsiLength         = input(14,    title="RSI Length",               group="RSI Settings")
oversold          = input(30,    title="Oversold Level",           group="RSI Settings")
overbought        = input(70,    title="Overbought Level",         group="RSI Settings")
extremeOversold   = input(20,    title="Extreme Oversold Level",   group="RSI Settings")
extremeOverbought = input(80,    title="Extreme Overbought Level", group="RSI Settings")
src               = input(close, title="Source",                   group="RSI Settings")

mfiLength    = input(20, title="MFI Length",   group="MFI Cloud Settings")
fastMfiEma   = input(5,  title="Fast MFI EMA", group="MFI Cloud Settings")
slowMfiEma   = input(13, title="Slow MFI EMA", group="MFI Cloud Settings")
cloudOpacity = input.int(40, title="Cloud Opacity", minval=10, maxval=90, group="MFI Cloud Settings")

requireVolume   = input(false, title="Require Volume Confirmation", group="Signal Settings")
trendConfirm    = input(false, title="Require Trend Confirmation",  group="Signal Settings")
minPeakStrength = input.int(2, title="Minimum Peak Strength", minval=1, maxval=5, group="Signal Settings")
signalCooldown  = input.int(5, title="Signal Cooldown (bars)", minval=1, maxval=20, group="Signal Settings")

showMTF      = input(false,         title="Show Higher TF RSI", group="Multi-Timeframe")
mtfTimeframe = input.timeframe("D", title="Higher Timeframe",   group="Multi-Timeframe")

showDivergence = input(true,   title="Show Divergence Signals",    group="Divergence Settings")
divLookback    = input.int(15, title="Divergence Lookback (bars)", minval=5, maxval=50, group="Divergence Settings")

showFailureSwings = input(true, title="Show Failure Swings", group="Failure Swing Settings")

showHistogram  = input(true, title="Show RSI Histogram", group="Visual Settings")
showSignals    = input(true, title="Show Signals",        group="Visual Settings")
showZones      = input(true, title="Show OB/OS Zones",   group="Visual Settings")
showMiddleLine = input(true, title="Show Middle Line",   group="Visual Settings")
showMfiCloud   = input(true, title="Show MFI Cloud",     group="Visual Settings")
showSmoothed   = input(true, title="Show Smoothed RSI",  group="Visual Settings")

// ========== CALCULATIONS (all global) ==========
rsi         = ta.rsi(src, rsiLength)
smoothedRSI = ta.ema(rsi, 3)
rsiChange1  = ta.change(rsi, 1)
rsiChange2  = ta.change(rsi, 2)

mfi     = ta.mfi(close, mfiLength)
fastMfi = ta.ema(mfi, fastMfiEma)
slowMfi = ta.ema(mfi, slowMfiEma)

volSma     = ta.sma(volume, 20)
ema20close = ta.ema(close, 20)

bullishCloud = fastMfi > slowMfi
bearishCloud = fastMfi < slowMfi

htfRsi = request.security(syminfo.tickerid, mtfTimeframe, ta.rsi(src, rsiLength), lookahead=barmerge.lookahead_off)

isPeak = ta.falling(rsi, minPeakStrength) and rsi >= overbought
isDip  = ta.rising(rsi, minPeakStrength)  and rsi <= oversold

volumeOk    = not requireVolume or volume > volSma
trendOkBuy  = not trendConfirm  or close > ema20close
trendOkSell = not trendConfirm  or close < ema20close

htfTrendOkBuy  = not showMTF or htfRsi > 50
htfTrendOkSell = not showMTF or htfRsi < 50

var int barsSinceLastSignal = 0
barsSinceLastSignal := barsSinceLastSignal + 1
cooldownOk = barsSinceLastSignal >= signalCooldown

crossOverSold    = ta.crossover(rsi, oversold)
crossUnderBought = ta.crossunder(rsi, overbought)

rsiColor = rsi >= extremeOverbought ? color.new(#FF1744, 0) : rsi >= overbought ? color.new(#FF5252, 0) : rsi <= extremeOversold ? color.new(#00E676, 0) : rsi <= oversold ? color.new(#69F0AE, 0) : rsi > 50 ? color.new(#2979FF, 20) : color.new(#448AFF, 40)

// ========== DIVERGENCE ==========
rsiPivotHigh = ta.pivothigh(rsi, divLookback, divLookback)
rsiPivotLow  = ta.pivotlow(rsi,  divLookback, divLookback)

var float prevRsiHigh   = na
var float prevPriceHigh = na
bearishDiv = false
if not na(rsiPivotHigh)
    if not na(prevRsiHigh) and not na(prevPriceHigh)
        if high[divLookback] > prevPriceHigh and rsiPivotHigh < prevRsiHigh and rsiPivotHigh > 60
            bearishDiv := true
    prevRsiHigh   := rsiPivotHigh
    prevPriceHigh := high[divLookback]

var float prevRsiLow   = na
var float prevPriceLow = na
bullishDiv = false
if not na(rsiPivotLow)
    if not na(prevRsiLow) and not na(prevPriceLow)
        if low[divLookback] < prevPriceLow and rsiPivotLow > prevRsiLow and rsiPivotLow < 40
            bullishDiv := true
    prevRsiLow   := rsiPivotLow
    prevPriceLow := low[divLookback]

plotshape(showDivergence and bearishDiv ? rsiPivotHigh : na, title="Bearish Div", location=location.absolute, color=color.new(#FF6D00, 0), style=shape.triangledown, size=size.small, offset=-divLookback)
plotshape(showDivergence and bullishDiv ? rsiPivotLow  : na, title="Bullish Div", location=location.absolute, color=color.new(#00BFA5, 0), style=shape.triangleup,   size=size.small, offset=-divLookback)

// ========== FAILURE SWINGS ==========
var float fsLow   = na
var float fsPeak  = na
var bool  fsArmed = false

if rsi <= oversold
    fsLow   := rsi
    fsPeak  := na
    fsArmed := false

if not na(fsLow) and rsi > fsLow and na(fsPeak)
    fsPeak := rsi

var bool bullishFS = false
bullishFS := false
if not na(fsPeak) and not fsArmed and rsi > fsPeak
    bullishFS := true
    fsArmed   := true

var float fsPeakB  = na
var float fsLowB   = na
var bool  fsArmedB = false

if rsi >= overbought
    fsPeakB  := rsi
    fsLowB   := na
    fsArmedB := false

if not na(fsPeakB) and rsi < fsPeakB and na(fsLowB)
    fsLowB := rsi

var bool bearishFS = false
bearishFS := false
if not na(fsLowB) and not fsArmedB and rsi < fsLowB
    bearishFS := true
    fsArmedB  := true

plotshape(showFailureSwings and bullishFS ? oversold - 8    : na, title="Bull FS", location=location.absolute, color=color.new(#00E5FF, 0), style=shape.circle, size=size.tiny)
plotshape(showFailureSwings and bearishFS ? overbought + 8  : na, title="Bear FS", location=location.absolute, color=color.new(#FF9100, 0), style=shape.circle, size=size.tiny)

// ========== SIGNAL GENERATION ==========
var string lastSignal      = "None"
var color  lastSignalColor = color.gray

baseBuy  = isDip and volumeOk and trendOkBuy and rsiChange1 > 0 and rsiChange2 > 0
baseSell = isPeak and volumeOk and trendOkSell and rsiChange1 < 0 and rsiChange2 < 0

simpleBuy  = not requireVolume and not trendConfirm and crossOverSold
simpleSell = not requireVolume and not trendConfirm and crossUnderBought

buySignal  = showSignals and cooldownOk and htfTrendOkBuy  and (baseBuy  or simpleBuy  or (showDivergence and bullishDiv) or (showFailureSwings and bullishFS))
sellSignal = showSignals and cooldownOk and htfTrendOkSell and (baseSell or simpleSell or (showDivergence and bearishDiv) or (showFailureSwings and bearishFS))

if buySignal
    lastSignal          := "BUY"
    lastSignalColor     := color.green
    barsSinceLastSignal := 0
else if sellSignal
    lastSignal          := "SELL"
    lastSignalColor     := color.red
    barsSinceLastSignal := 0

// ========== PLOTS ==========
plot(rsi, title="RSI", color=rsiColor, linewidth=2)
plot(showSmoothed ? smoothedRSI : na, title="Smoothed RSI", color=color.new(#FFEB3B, 60), linewidth=1)
plot(showMTF ? htfRsi : na, title="HTF RSI", color=color.new(#CE93D8, 0), linewidth=2, style=plot.style_stepline)

histVal   = rsi - 50
histColor = histVal > 20 ? color.new(#FF5252, 10) : histVal > 0 ? color.new(#2979FF, 30) : histVal < -20 ? color.new(#69F0AE, 10) : color.new(#448AFF, 50)
plot(showHistogram ? histVal : na, title="RSI Histogram", style=plot.style_histogram, color=histColor, linewidth=1)
plot(showHistogram ? 0 : na, title="Histogram Zero", color=color.new(color.gray, 60), linewidth=1)

fastPlot  = plot(showMfiCloud ? fastMfi : na, title="Fast MFI EMA", color=color.new(color.blue,   0), linewidth=1, display=display.none)
slowPlot  = plot(showMfiCloud ? slowMfi : na, title="Slow MFI EMA", color=color.new(color.orange, 0), linewidth=1, display=display.none)
fillColor = bullishCloud ? color.new(color.green, 100 - cloudOpacity) : bearishCloud ? color.new(color.red, 100 - cloudOpacity) : na
fill(fastPlot, slowPlot, color=showMfiCloud ? fillColor : na, title="MFI Cloud")

hline(overbought,        "Overbought", color=showZones      ? color.new(#FF5252, 0) : na, linestyle=hline.style_dashed)
hline(oversold,          "Oversold",   color=showZones      ? color.new(#00C853, 0) : na, linestyle=hline.style_dashed)
hline(extremeOverbought, "Extreme OB", color=showZones      ? color.new(#B71C1C, 0) : na, linestyle=hline.style_dotted)
hline(extremeOversold,   "Extreme OS", color=showZones      ? color.new(#1B5E20, 0) : na, linestyle=hline.style_dotted)
hline(50,                "Mid Line",   color=showMiddleLine ? color.new(#616161, 0) : na, linestyle=hline.style_dashed)

plotshape(buySignal  ? oversold  - 5 : na, title="Buy Signal",  location=location.absolute, color=color.new(#00FF00, 0), style=shape.labelup,   size=size.tiny)
plotshape(sellSignal ? overbought + 5 : na, title="Sell Signal", location=location.absolute, color=color.new(#FF0000, 0), style=shape.labeldown, size=size.tiny)

bgcolor(showZones and rsi >= extremeOverbought ? color.new(#FF1744, 94) : na, title="Extreme OB Zone")
bgcolor(showZones and rsi >= overbought and rsi < extremeOverbought ? color.new(#FF5252, 92) : na, title="OB Zone")
bgcolor(showZones and rsi <= extremeOversold ? color.new(#00E676, 94) : na, title="Extreme OS Zone")
bgcolor(showZones and rsi <= oversold and rsi > extremeOversold ? color.new(#00C853, 92) : na, title="OS Zone")

// ========== ALERTS ==========
alertcondition(buySignal,  title="Buy Signal",         message="RSI Buy Signal at {{close}}")
alertcondition(sellSignal, title="Sell Signal",        message="RSI Sell Signal at {{close}}")
alertcondition(bullishDiv, title="Bullish Divergence", message="Bullish RSI Divergence at {{close}}")
alertcondition(bearishDiv, title="Bearish Divergence", message="Bearish RSI Divergence at {{close}}")
alertcondition(bullishFS,  title="Bull Failure Swing", message="Bullish Failure Swing at {{close}}")
alertcondition(bearishFS,  title="Bear Failure Swing", message="Bearish Failure Swing at {{close}}")

// ========== INFO TABLE ==========
var table infoTable = table.new(position.top_right, 2, 8, border_width=1, bgcolor=color.new(#1A1A2E, 88))

if barstate.islast
    table.cell(infoTable, 0, 0, "RSI Value",   text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 0, str.tostring(rsi, "#.00"), text_color=rsi >= overbought ? color.red : rsi <= oversold ? color.green : color.white, text_size=size.small)

    table.cell(infoTable, 0, 1, "Smooth RSI",  text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(smoothedRSI, "#.00"), text_color=color.new(#FFEB3B, 0), text_size=size.small)

    table.cell(infoTable, 0, 2, "HTF RSI",     text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 2, showMTF ? str.tostring(htfRsi, "#.00") : "Off", text_color=showMTF ? (htfRsi > 50 ? color.green : color.red) : color.gray, text_size=size.small)

    table.cell(infoTable, 0, 3, "MFI Trend",   text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 3, bullishCloud ? "Bullish" : bearishCloud ? "Bearish" : "Neutral", text_color=bullishCloud ? color.green : bearishCloud ? color.red : color.gray, text_size=size.small)

    table.cell(infoTable, 0, 4, "Status",      text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 4, rsi >= extremeOverbought ? "EXTREME OB" : rsi >= overbought ? "Overbought" : rsi <= extremeOversold ? "EXTREME OS" : rsi <= oversold ? "Oversold" : "Neutral", text_color=rsi >= overbought ? color.red : rsi <= oversold ? color.green : color.white, text_size=size.small)

    table.cell(infoTable, 0, 5, "Last Signal", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 5, lastSignal, text_color=lastSignalColor, text_size=size.small)

    table.cell(infoTable, 0, 6, "Momentum",    text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 6, rsiChange1 > 0 ? "Rising" : "Falling", text_color=rsiChange1 > 0 ? color.green : color.red, text_size=size.small)

    table.cell(infoTable, 0, 7, "Cooldown",    text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 7, cooldownOk ? "Ready" : str.tostring(signalCooldown - barsSinceLastSignal) + " bars", text_color=cooldownOk ? color.green : color.orange, text_size=size.small)
````
