<!-- tradingview-pine-id: PUB;404440cd105b4ca3a35e38996490866d -->
<!-- tradingviewscripts-format: 1 -->
# RSI Divergence Indicator Mitsos4

Source: https://www.tradingview.com/script/duXjI6e6-RSI-Divergence-Indicator/

## Description

RSI Divergence Indicator — Enhanced

An enhanced RSI indicator combining traditional RSI divergence detection with flexible smoothing and a dynamic trend-color system.

This indicator is designed to give traders a cleaner view of momentum, trend direction, and divergence in one RSI pane.

Key Features
Dynamic RSI Trend Coloring

The RSI can automatically change color based on the relationship between a fast and slow RSI:

🟢 Green — Fast RSI is above Slow RSI, indicating bullish momentum.
🔴 Red — Fast RSI is below Slow RSI, indicating bearish momentum.
The feature can be turned on or off from the Divergence settings.

The Fast RSI and Slow RSI lengths are fully adjustable, with defaults of 5 and 14.

RSI Smoothing

Choose from several smoothing methods for the RSI:

None
SMA
SMA + Bollinger Bands
EMA
SMMA (RMA)
WMA
VWMA

The smoothing length is fully adjustable.

RSI Bollinger Bands

When SMA + Bollinger Bands is selected, Bollinger Bands are automatically displayed around the smoothed RSI.

The BB Standard Deviation is adjustable, allowing traders to customize the band width.

Multiple RSI Levels

The indicator includes five important RSI reference levels:

70 — Overbought
60 — Bullish momentum zone
50 — Midline / neutral
40 — Bearish momentum zone
30 — Oversold

The 40 and 60 levels provide additional context for identifying momentum shifts before RSI reaches traditional overbought or oversold levels.

Regular Divergence

Detects traditional divergence between price and RSI:

Bullish Divergence

Price makes a Lower Low
RSI makes a Higher Low

Bearish Divergence

Price makes a Higher High
RSI makes a Lower High
Hidden Divergence

Also identifies hidden divergence:

Hidden Bullish

Price makes a Higher Low
RSI makes a Lower Low

Hidden Bearish

Price makes a Lower High
RSI makes a Higher High
Customizable Divergence Detection

The pivot lookback and divergence range settings allow traders to adjust how sensitive the divergence detection is.

Alerts

Alert conditions are included for:

Regular Bullish Divergence
Hidden Bullish Divergence
Regular Bearish Divergence
Hidden Bearish Divergence
Why Use This Indicator?

The goal of this indicator is to combine several useful RSI tools into one clean and customizable package.

Instead of relying on RSI alone, traders can use:

RSI + Dynamic Momentum Color + Smoothing + Bollinger Bands + 40/60 Momentum Levels + Regular Divergence + Hidden Divergence

This provides multiple ways to assess momentum and potential trend changes without requiring several separate indicators.

Suggested Starting Settings

For a balanced starting point:

RSI Period: 14
Smoothing: None
Fast RSI: 5
Slow RSI: 14
Overbought: 70
Bullish momentum: 60
Midline: 50
Bearish momentum: 40
Oversold: 30

These are simply starting points and can be adjusted depending on the market, timeframe, and trading style.

Important

This indicator is intended as a technical analysis tool and should not be considered financial advice. Divergences and momentum signals can fail, particularly during strong trends or volatile market conditions. Always combine indicator signals with your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator("RSI Divergence Indicator Mitsos4", format=format.price, timeframe="", timeframe_gaps=true)

len = input.int(14, "RSI Period", minval=1)
src = input.source(close, "RSI Source")

maType = input.string("None", "Smoothing Type", options=["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="RSI Smoothing")
maLength = input.int(14, "Length", minval=1, group="RSI Smoothing")
bbMult = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.1, group="RSI Smoothing")

useDivergenceColor = input.bool(true, "Color RSI By Divergence", group="Divergence")
fastRsiLength = input.int(5, "Fast RSI Length", minval=1, group="Divergence")
slowRsiLength = input.int(14, "Slow RSI Length", minval=1, group="Divergence")

lbR = input.int(5, "Pivot Lookback Right", minval=1, display=display.none)
lbL = input.int(5, "Pivot Lookback Left", minval=1, display=display.none)
rangeUpper = input.int(60, "Max of Lookback Range", minval=1, display=display.none)
rangeLower = input.int(5, "Min of Lookback Range", minval=1, display=display.none)

plotBull = input.bool(true, "Plot Bullish", display=display.none)
plotHiddenBull = input.bool(false, "Plot Hidden Bullish", display=display.none)
plotBear = input.bool(true, "Plot Bearish", display=display.none)
plotHiddenBear = input.bool(false, "Plot Hidden Bearish", display=display.none)

bearColor = color.red
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

osc = ta.rsi(src, len)

fastRsi = ta.rsi(src, fastRsiLength)
slowRsi = ta.rsi(src, slowRsiLength)

rsiColor = useDivergenceColor ? fastRsi >= slowRsi ? color.green : color.red : #2962FF

rsiMA = maType == "SMA" or maType == "SMA + Bollinger Bands" ? ta.sma(osc, maLength) :
     maType == "EMA" ? ta.ema(osc, maLength) :
     maType == "SMMA (RMA)" ? ta.rma(osc, maLength) :
     maType == "WMA" ? ta.wma(osc, maLength) :
     maType == "VWMA" ? ta.vwma(osc, maLength) :
     na

bbBasis = ta.sma(osc, maLength)
bbDev = bbMult * ta.stdev(osc, maLength)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

showMA = maType != "None"
showBB = maType == "SMA + Bollinger Bands"

plot(osc, title="RSI", linewidth=2, color=rsiColor)

plot(showMA ? rsiMA : na, title="RSI Moving Average", linewidth=2, color=color.orange)

upperPlot = plot(showBB ? bbUpper : na, title="RSI BB Upper", linewidth=1, color=color.green)
lowerPlot = plot(showBB ? bbLower : na, title="RSI BB Lower", linewidth=1, color=color.green)

fill(upperPlot, lowerPlot, color=color.new(color.green, 90), title="RSI Bollinger Bands")

hline(70, title="Overbought", color=#787B86, linestyle=hline.style_dotted)
hline(60, title="60 Level", color=#787B86, linestyle=hline.style_dotted)
hline(50, title="Middle Line", color=#787B86, linestyle=hline.style_dotted)
hline(40, title="40 Level", color=#787B86, linestyle=hline.style_dotted)
hline(30, title="Oversold", color=#787B86, linestyle=hline.style_dotted)

obLevel = hline(70, title="Overbought Fill", color=color.new(#787B86, 100))
osLevel = hline(30, title="Oversold Fill", color=color.new(#787B86, 100))

fill(obLevel, osLevel, color=color.rgb(33, 150, 243, 90), title="Background")

plFound = not na(ta.pivotlow(osc, lbL, lbR))
phFound = not na(ta.pivothigh(osc, lbL, lbR))

_inRange(cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

inRangePl = _inRange(plFound[1])

oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)

bullCondAlert = priceLL and oscHL and plFound
bullCond = plotBull and bullCondAlert

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Regular Bullish", linewidth=2, color=bullCond ? bullColor : noneColor, display=display.pane, editable=plotBull)

plotshape(bullCond ? osc[lbR] : na, offset=-lbR, title="Regular Bullish Label", text="Bull", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor, editable=plotBull)

oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)

hiddenBullCondAlert = priceHL and oscLL and plFound
hiddenBullCond = plotHiddenBull and hiddenBullCondAlert

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish", linewidth=2, color=hiddenBullCond ? hiddenBullColor : noneColor, display=display.pane, editable=plotHiddenBull)

plotshape(hiddenBullCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish Label", text="H Bull", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor, editable=plotHiddenBull)

inRangePh = _inRange(phFound[1])

oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)

bearCondAlert = priceHH and oscLH and phFound
bearCond = plotBear and bearCondAlert

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Regular Bearish", linewidth=2, color=bearCond ? bearColor : noneColor, display=display.pane, editable=plotBear)

plotshape(bearCond ? osc[lbR] : na, offset=-lbR, title="Regular Bearish Label", text="Bear", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor, editable=plotBear)

oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)

hiddenBearCondAlert = priceLH and oscHH and phFound
hiddenBearCond = plotHiddenBear and hiddenBearCondAlert

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish", linewidth=2, color=hiddenBearCond ? hiddenBearColor : noneColor, display=display.pane, editable=plotHiddenBear)

plotshape(hiddenBearCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish Label", text="H Bear", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor, editable=plotHiddenBear)

alertcondition(bullCondAlert, title="Regular Bullish Divergence", message="Found a new Regular Bullish Divergence")
alertcondition(hiddenBullCondAlert, title="Hidden Bullish Divergence", message="Found a new Hidden Bullish Divergence")
alertcondition(bearCondAlert, title="Regular Bearish Divergence", message="Found a new Regular Bearish Divergence")
alertcondition(hiddenBearCondAlert, title="Hidden Bearish Divergence", message="Found a new Hidden Bearish Divergence")
````
