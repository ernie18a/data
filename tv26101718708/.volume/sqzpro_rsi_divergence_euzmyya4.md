# SQZPRO + RSI Divergence

- url: https://www.tradingview.com/script/euzmyYa4-SQZPRO-RSI-Divergence/
- type: indicator
- pine_id: PUB;d1ef4152699541f4b2d619769bb70dfa
- version: 3.0

## Description

This indicator combines two tools in a single sub-pane below your chart:
RSI (top half of the logic) — a standard RSI plotted on its usual 0–100 scale, with horizontal lines at 70 (overbought), 50 (midline), and 30 (oversold). Length and source are configurable.
Squeeze PRO (volatility compression) — it compares Bollinger Bands (2 standard deviations) against three Keltner Channel widths (1x, 1.5x, and 2x average true range). Depending on how tightly the Bollinger Bands are nested inside those channels, it classifies the current bar into one of five states, each shown as a colored dot sitting on the RSI's 50-line:

Blue — transitional/no clear squeeze
Yellow — narrow squeeze (tightest compression, most "coiled")
Red — normal squeeze
Black — wide squeeze (loosest compression, but still squeezed)
Green — squeeze released (bands have expanded outward — volatility breakout in progress)

There's also an optional momentum histogram (off by default, toggle "Show MOM Histogram") that shows a linear-regression-based momentum oscillator, similar to the classic squeeze momentum indicator.
RSI Divergence — this scans for pivot highs/lows in the RSI and compares them to price pivots over the same span. When RSI and price disagree, it draws a short line connecting the two RSI pivot points plus a label, directly on the RSI plot:

"Bull" (regular bullish, green) — price made a lower low but RSI made a higher low; potential reversal up
"Bear" (regular bearish, red) — price made a higher high but RSI made a lower high; potential reversal down
"H Bull" / "H Bear" (hidden divergences, dimmer colors, off by default) — typically signal trend continuation rather than reversal

These signals are confirmed lbR bars (default 5) after the actual pivot, which is normal for any divergence tool — it trades a small delay for fewer false signals.
Confluence — the script tracks when a squeeze "fires" (transitions to the green/released state) and checks whether a divergence occurred on that same bar. If both line up, it triggers a separate "Bullish Confluence" or "Bearish Confluence" alert — the idea being that a volatility expansion plus a divergence in the same direction is a stronger combined signal than either alone.
Alerts are set up for every divergence type, for squeeze release on its own, and for the two confluence cases, so you can build alerts off whichever combination matters to you.

## Source Code

````pine
//@version=6
indicator(title="Makit0 Squeeze PRO + RSI Divergence", shorttitle="SQZPRO_RSI", overlay=false)

// =============================
// ============ RSI ============
// =============================

rsiLength = input.int(14, title="RSI Length", group="RSI")
rsiSource = input.source(close, title="RSI Source", group="RSI")
rsiValue = ta.rsi(rsiSource, rsiLength)

plot(rsiValue, title="RSI", color=#673ab7, linewidth=2)
hline(70, "RSI Overbought", color=#4a4a4a)
hline(30, "RSI Oversold", color=#4a4a4a)
hline(50, "RSI Midline", color=color.gray)

// =============================
// ===== ORIGINAL SQZ PRO ======
// =============================

source = close
length = 20

ma = ta.sma(source, length)
devBB = ta.stdev(source, length)
devKC = ta.sma(ta.tr(true), length)

// Bollinger 2x
upBB = ma + devBB * 2
lowBB = ma - devBB * 2

// Keltner 2x
upKCWide = ma + devKC * 2
lowKCWide = ma - devKC * 2

// Keltner 1.5x
upKCNormal = ma + devKC * 1.5
lowKCNormal = ma - devKC * 1.5

// Keltner 1x
upKCNarrow = ma + devKC
lowKCNarrow = ma - devKC

sqzOnWide   = (lowBB >= lowKCWide) and (upBB <= upKCWide)
sqzOnNormal = (lowBB >= lowKCNormal) and (upBB <= upKCNormal)
sqzOnNarrow = (lowBB >= lowKCNarrow) and (upBB <= upKCNarrow)
sqzOffWide  = (lowBB < lowKCWide) and (upBB > upKCWide)
noSqz       = not sqzOnWide and not sqzOffWide

// ===== Momentum Oscillator =====
midHL = (ta.highest(high, length) + ta.lowest(low, length)) / 2
midFinal = (midHL + ta.sma(close, length)) / 2
mom = ta.linreg(source - midFinal, length, 0)

mom_color = mom > 0 ?
     (mom > nz(mom[1]) ? color.aqua : color.blue) :
     (mom < nz(mom[1]) ? color.red : color.yellow)

// Toggle MOM visibility (default unticked)
showMom = input.bool(false, "Show MOM Histogram", group="Squeeze PRO")
plot(showMom ? mom : na, title='MOM', color=mom_color, style=plot.style_histogram, linewidth=5)

// =============================
// ===== SQZ Circles ============

// Custom SQZ colors
sq_color = noSqz ? #2962ff :        // color 0
           sqzOnNarrow ? #ffff00 : // color 1
           sqzOnNormal ? #ff0000 : // color 2
           sqzOnWide ? #000000 :   // color 3
           #00ff00                 // color 4 (sqzOffWide)

// Plot SQZ circles at RSI 50
plot(50, title='SQZ', color=sq_color, style=plot.style_circles, linewidth=3)

// =============================
// =========== VOLUME ==========
// =============================
// Volume is min-max normalized over a lookback and compressed into a small
// band at the bottom of the pane (0 to volHeight) so it sits alongside the
// RSI/SQZ scale without distorting it.

vol_group   = "Volume"
showVolume  = input.bool(true, "Show Volume", group=vol_group)
volMaLength = input.int(20, "Volume MA Length", group=vol_group)
volMaType   = input.string("SMA", "Volume MA Type", options=["SMA", "EMA"], group=vol_group)
volLookback = input.int(100, "Volume Normalization Lookback", group=vol_group)
volHeight   = input.int(20, "Volume Display Height", group=vol_group, minval=5, maxval=50)
volOffset   = input.int(50, "Volume Vertical Offset", group=vol_group, minval=0, maxval=100)

volMA = volMaType == "EMA" ? ta.ema(volume, volMaLength) : ta.sma(volume, volMaLength)

volHigh  = ta.highest(volume, volLookback)
volLow   = ta.lowest(volume, volLookback)
volRange = volHigh - volLow

volNorm   = volOffset + (volRange != 0 ? (volume - volLow) / volRange * volHeight : 0.0)
volMANorm = volOffset + (volRange != 0 ? (volMA - volLow) / volRange * volHeight : 0.0)

volBarColor = close >= open ? color.new(color.teal, 40) : color.new(color.maroon, 40)

plot(showVolume ? volNorm : na, title="Volume", style=plot.style_columns, color=volBarColor)
plot(showVolume ? volMANorm : na, title="Volume MA", color=color.orange, linewidth=2)

// =============================
// ===== RSI DIVERGENCE ========
// =============================
// Divergence is drawn directly on the RSI line (location.absolute), since
// it shares the 0-100 scale with the RSI plot above. A connecting line is
// always drawn between consecutive RSI pivots; it's only colored (visible)
// when a real divergence condition is met, otherwise it's fully transparent.

div_group  = "RSI Divergence"
lbL        = input.int(5, "Pivot Lookback Left", group=div_group)
lbR        = input.int(5, "Pivot Lookback Right", group=div_group)
rangeUpper = input.int(60, "Max Lookback Range", group=div_group)
rangeLower = input.int(5, "Min Lookback Range", group=div_group)

plotBull       = input.bool(true,  "Plot Regular Bullish",  group=div_group)
plotHiddenBull = input.bool(false, "Plot Hidden Bullish",   group=div_group)
plotBear       = input.bool(true,  "Plot Regular Bearish",  group=div_group)
plotHiddenBear = input.bool(false, "Plot Hidden Bearish",   group=div_group)

bullColor       = color.new(color.lime, 0)
bearColor       = color.new(color.red, 0)
hiddenBullColor = color.new(color.lime, 60)
hiddenBearColor = color.new(color.red, 60)
textColor       = color.white
noneColor       = color.new(color.white, 100)

plFound = not na(ta.pivotlow(rsiValue, lbL, lbR))
phFound = not na(ta.pivothigh(rsiValue, lbL, lbR))

_inRange(cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plRange = _inRange(plFound[1])
phRange = _inRange(phFound[1])

// --- Regular Bullish: RSI Higher Low, Price Lower Low ---
oscHL   = rsiValue[lbR] > ta.valuewhen(plFound, rsiValue[lbR], 1) and plRange
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCondAlert = priceLL and oscHL and plFound
bullCond = plotBull and bullCondAlert

plot(plFound ? rsiValue[lbR] : na, offset=-lbR, title="Regular Bullish Div", linewidth=2, color=(bullCond ? bullColor : noneColor))
plotshape(bullCond ? rsiValue[lbR] : na, offset=-lbR, title="Regular Bullish Label", text=" Bull ", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor, size=size.tiny)

// --- Hidden Bullish: RSI Lower Low, Price Higher Low ---
oscLL   = rsiValue[lbR] < ta.valuewhen(plFound, rsiValue[lbR], 1) and plRange
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCondAlert = priceHL and oscLL and plFound
hiddenBullCond = plotHiddenBull and hiddenBullCondAlert

plot(plFound ? rsiValue[lbR] : na, offset=-lbR, title="Hidden Bullish Div", linewidth=2, color=(hiddenBullCond ? hiddenBullColor : noneColor))
plotshape(hiddenBullCond ? rsiValue[lbR] : na, offset=-lbR, title="Hidden Bullish Label", text=" H Bull ", style=shape.labelup, location=location.absolute, color=hiddenBullColor, textcolor=textColor, size=size.tiny)

// --- Regular Bearish: RSI Lower High, Price Higher High ---
oscLH   = rsiValue[lbR] < ta.valuewhen(phFound, rsiValue[lbR], 1) and phRange
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCondAlert = priceHH and oscLH and phFound
bearCond = plotBear and bearCondAlert

plot(phFound ? rsiValue[lbR] : na, offset=-lbR, title="Regular Bearish Div", linewidth=2, color=(bearCond ? bearColor : noneColor))
plotshape(bearCond ? rsiValue[lbR] : na, offset=-lbR, title="Regular Bearish Label", text=" Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor, size=size.tiny)

// --- Hidden Bearish: RSI Higher High, Price Lower High ---
oscHH   = rsiValue[lbR] > ta.valuewhen(phFound, rsiValue[lbR], 1) and phRange
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCondAlert = priceLH and oscHH and phFound
hiddenBearCond = plotHiddenBear and hiddenBearCondAlert

plot(phFound ? rsiValue[lbR] : na, offset=-lbR, title="Hidden Bearish Div", linewidth=2, color=(hiddenBearCond ? hiddenBearColor : noneColor))
plotshape(hiddenBearCond ? rsiValue[lbR] : na, offset=-lbR, title="Hidden Bearish Label", text=" H Bear ", style=shape.labeldown, location=location.absolute, color=hiddenBearColor, textcolor=textColor, size=size.tiny)

// =============================
// ===== CONFLUENCE / ALERTS ===
// =============================
// squeezeReleased: the wide-band squeeze just turned off (volatility starting
// to expand) - combined with a same-bar divergence this is a strong setup.

squeezeReleased = (sqzOnWide[1] or noSqz[1]) and sqzOffWide

alertcondition(bullCondAlert, title="RSI Bullish Divergence", message="Regular bullish RSI divergence detected")
alertcondition(bearCondAlert, title="RSI Bearish Divergence", message="Regular bearish RSI divergence detected")
alertcondition(hiddenBullCondAlert, title="RSI Hidden Bullish Divergence", message="Hidden bullish RSI divergence detected")
alertcondition(hiddenBearCondAlert, title="RSI Hidden Bearish Divergence", message="Hidden bearish RSI divergence detected")
alertcondition(squeezeReleased, title="Squeeze Released", message="Squeeze has fired / volatility expanding")
alertcondition(squeezeReleased and bullCondAlert, title="Bullish Confluence", message="Squeeze release + bullish RSI divergence - potential long setup")
alertcondition(squeezeReleased and bearCondAlert, title="Bearish Confluence", message="Squeeze release + bearish RSI divergence - potential short setup")
````
