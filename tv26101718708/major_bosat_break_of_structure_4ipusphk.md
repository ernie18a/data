# Major BOS[AT] - Break of Structure

- url: https://www.tradingview.com/script/4iPusphk-Major-BOS-AT-Break-of-Structure/
- type: indicator
- pine_id: PUB;fafac13fa41440b793c5a245e25a116c
- version: 1.0

## Description

looks at the makor breka of stucture to determine if the market is moving in cretain direction

## Source Code

````pine
//@version=5
indicator("Major BOS[AT] - Break of Structure", shorttitle="Major BOS", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ─────────────────────────────────────
leftLen     = input.int(12, "Left Bars (Higher = Major Only)", minval=5)
rightLen    = input.int(12, "Right Bars (Higher = Major Only)", minval=5)
minSwingPct = input.float(0.5, "Minimum Swing Size % (Filter Noise)", minval=0.1, step=0.1)

// ── Major Swing Detection ─────────────────────
ph = ta.pivothigh(high, leftLen, rightLen)
pl = ta.pivotlow(low,  leftLen, rightLen)

// Filter small swings using ATR percentage
atr = ta.atr(14)
swingHighValid = not na(ph) and (ph - ta.lowest(low, leftLen*2)) / atr >= minSwingPct
swingLowValid  = not na(pl) and (ta.highest(high, leftLen*2) - pl) / atr >= minSwingPct

var float lastMajorSH = na
var float lastMajorSL = na
var int   trend = 0

// Update last major swings
if swingHighValid
    lastMajorSH := ph

if swingLowValid
    lastMajorSL := pl

// ── Major BOS & CHoCH Logic ───────────────────
bosBullish = not na(ph) and swingHighValid and close > lastMajorSH[1] and trend <= 0
bosBearish = not na(pl) and swingLowValid  and close < lastMajorSL[1] and trend >= 0

chochBullish = not na(ph) and swingHighValid and close > lastMajorSH[1] and trend == -1
chochBearish = not na(pl) and swingLowValid  and close < lastMajorSL[1] and trend ==  1

// Update trend
if bosBullish or chochBullish
    trend := 1
if bosBearish or chochBearish
    trend := -1

// ── Plotting ───────────────────────────────────
plotshape(bosBullish,  title="Major Bullish BOS",  location=location.belowbar, color=#00ff88, style=shape.labelup,   text="BOS↑", textcolor=color.black,   size=size.large)
plotshape(bosBearish,  title="Major Bearish BOS",  location=location.abovebar, color=#ff4488, style=shape.labeldown, text="BOS↓", textcolor=color.white,   size=size.large)

plotshape(chochBullish, title="CHoCH Bullish", location=location.belowbar, color=#00ffff, style=shape.triangleup,   text="CHoCH", size=size.normal)
plotshape(chochBearish, title="CHoCH Bearish", location=location.abovebar, color=#ff00ff, style=shape.triangledown, text="CHoCH", size=size.normal)

// Structure Lines (Major Only)
if swingHighValid
    line.new(bar_index[rightLen], ph, bar_index + 50, ph, color=#ff4488, width=2, style=line.style_solid)

if swingLowValid
    line.new(bar_index[rightLen], pl, bar_index + 50, pl, color=#00ff88, width=2, style=line.style_solid)
````
