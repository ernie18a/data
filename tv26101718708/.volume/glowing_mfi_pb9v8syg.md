# Glowing MFI

- url: https://www.tradingview.com/script/Pb9v8syg-Glowing-MFI/
- type: indicator
- pine_id: PUB;e9f0b5e68a6844e5a1519781be7260d1
- version: 3.0

## Description

Hi all,
Glowing MFI with two additional middle bands added to help you gauge pullbacks. Enjoy it in dark mode!

## Source Code

````pine
//@version=6
indicator(title="Glowing MFI", shorttitle="MFI", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
length    = input.int(title="Length", defval=21, minval=1, maxval=2000)
mfiColor  = input.color(#ffb74d, "MFI Line Color")
obLevel   = input.float(80, "Overbought Level")
osLevel   = input.float(20, "Oversold Level")
midLevel  = input.float(50, "Middle Band Level")
mid2Level = input.float(40, "Middle Band 2 Level")
mid3Level = input.float(60, "Middle Band 3 Level")

// ─── Glow Settings ────────────────────────────────────────────────────────────
glow_on      = input.bool(true, "Enable Glow",     group = "Glow Settings", inline = "glow")
glow_intense = input.int(80,    "Intensity (0-98)", group = "Glow Settings", inline = "glow", minval = 0, maxval = 98)

// ─── Divergence Settings ──────────────────────────────────────────────────────
lbR            = input.int(5,     "Pivot Lookback Right",  group = "Divergence Settings")
lbL            = input.int(5,     "Pivot Lookback Left",   group = "Divergence Settings")
rangeUpper     = input.int(60,    "Max Lookback Range",    group = "Divergence Settings")
rangeLower     = input.int(5,     "Min Lookback Range",    group = "Divergence Settings")
plotBull       = input.bool(true,  "Plot Regular Bullish",  group = "Divergence Settings")
plotHiddenBull = input.bool(false, "Plot Hidden Bullish",   group = "Divergence Settings")
plotBear       = input.bool(true,  "Plot Regular Bearish",  group = "Divergence Settings")
plotHiddenBear = input.bool(false, "Plot Hidden Bearish",   group = "Divergence Settings")

// ─── Divergence Colors ────────────────────────────────────────────────────────
bullColor       = input.color(color.new(color.green, 0),  "Bullish Color",        group = "Divergence Colors")
hiddenBullColor = input.color(color.new(color.green, 80), "Hidden Bullish Color", group = "Divergence Colors")
bearColor       = input.color(color.new(color.red, 0),    "Bearish Color",        group = "Divergence Colors")
hiddenBearColor = input.color(color.new(color.red, 80),   "Hidden Bearish Color", group = "Divergence Colors")
textColor       = input.color(color.white,                "Label Text Color",     group = "Divergence Colors")
noneColor       = color.new(color.white, 100)

// ─── MFI Calculation ──────────────────────────────────────────────────────────
src = hlc3
mf  = ta.mfi(src, length)
osc = mf

// ─── Glow Layers ──────────────────────────────────────────────────────────────
i  = glow_intense
i2 = math.min(i + 20, 98)
i3 = math.min(i + 40, 98)

plot(glow_on ? mf : na, "MFI Glow1", color.new(mfiColor, i),  linewidth = 10, editable = false)
plot(glow_on ? mf : na, "MFI Glow2", color.new(mfiColor, i2), linewidth = 20, editable = false)
plot(glow_on ? mf : na, "MFI Glow3", color.new(mfiColor, i3), linewidth = 30, editable = false)

// MFI core line drawn on top
plot(mf, "MF", color = mfiColor, linewidth = 1)

// ─── Levels ───────────────────────────────────────────────────────────────────
hline(obLevel,   "Overbought",   color=#787B86)
hline(mid2Level, "Middle Band 2",color=color.new(#787B86, 30))
hline(midLevel,  "Middle Band",  color=color.new(#787B86, 50))
hline(mid3Level, "Middle Band 3",color=color.new(#787B86, 30))
hline(osLevel,   "Oversold",     color=#787B86)

// ─── Divergence Engine (ported from v4 source, rewritten for v6) ──────────────
plFound = na(ta.pivotlow(osc, lbL, lbR))  ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    bool result = rangeLower <= bars and bars <= rangeUpper
    result

// ─── Regular Bullish ─────────────────────────────────────────────────────────
bool inRangePl  = _inRange(plFound[1])
bool oscHL      = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
bool priceLL    = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bool bullCond   = plotBull and priceLL and oscHL and plFound

plot(plFound ? osc[lbR] : na, offset = -lbR, title = "Regular Bullish",
     linewidth = 2, color = bullCond ? bullColor : noneColor)
plotshape(bullCond ? osc[lbR] : na, offset = -lbR,
     title = "Regular Bullish Label", text = " Bull ",
     style = shape.labelup, location = location.absolute,
     color = bullColor, textcolor = textColor)

// ─── Hidden Bullish ───────────────────────────────────────────────────────────
bool oscLL          = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
bool priceHL        = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
bool hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound

plot(plFound ? osc[lbR] : na, offset = -lbR, title = "Hidden Bullish",
     linewidth = 2, color = hiddenBullCond ? hiddenBullColor : noneColor)
plotshape(hiddenBullCond ? osc[lbR] : na, offset = -lbR,
     title = "Hidden Bullish Label", text = " H Bull ",
     style = shape.labelup, location = location.absolute,
     color = bullColor, textcolor = textColor)

// ─── Regular Bearish ─────────────────────────────────────────────────────────
bool inRangePh  = _inRange(phFound[1])
bool oscLH      = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
bool priceHH    = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bool bearCond   = plotBear and priceHH and oscLH and phFound

plot(phFound ? osc[lbR] : na, offset = -lbR, title = "Regular Bearish",
     linewidth = 2, color = bearCond ? bearColor : noneColor)
plotshape(bearCond ? osc[lbR] : na, offset = -lbR,
     title = "Regular Bearish Label", text = " Bear ",
     style = shape.labeldown, location = location.absolute,
     color = bearColor, textcolor = textColor)

// ─── Hidden Bearish ───────────────────────────────────────────────────────────
bool oscHH          = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
bool priceLH        = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
bool hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound

plot(phFound ? osc[lbR] : na, offset = -lbR, title = "Hidden Bearish",
     linewidth = 2, color = hiddenBearCond ? hiddenBearColor : noneColor)
plotshape(hiddenBearCond ? osc[lbR] : na, offset = -lbR,
     title = "Hidden Bearish Label", text = " H Bear ",
     style = shape.labeldown, location = location.absolute,
     color = bearColor, textcolor = textColor)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(bullCond,       title = "Regular Bullish Divergence in MFI",  message = "Regular bullish divergence found in MFI")
alertcondition(hiddenBullCond, title = "Hidden Bullish Divergence in MFI",   message = "Hidden bullish divergence found in MFI")
alertcondition(bearCond,       title = "Regular Bearish Divergence in MFI",  message = "Regular bearish divergence found in MFI")
alertcondition(hiddenBearCond, title = "Hidden Bearish Divergence in MFI",   message = "Hidden bearish divergence found in MFI")
````
