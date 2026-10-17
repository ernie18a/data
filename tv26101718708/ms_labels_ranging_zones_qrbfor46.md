# MS Labels & Ranging Zones

- url: https://www.tradingview.com/script/qrbFOR46-MS-Labels-Ranging-Zones/
- type: indicator
- pine_id: PUB;6343068260c64270aa4e0a5feef75e9c
- version: 1.0

## Description

Label	Meaning	Color
eHH	External Higher High	Cyan (above bar)
eLH	External Lower High	Cyan (above bar)
eLL	External Lower Low	Orange (below bar)
eHL	External Higher Low	Orange (below bar)
iHH	Internal Higher High	Blue (above bar)
iLH	Internal Lower High	Blue (above bar)
iLL	Internal Lower Low	Purple (below bar)
iHL	Internal Higher Low	Purple (below bar)
Key Differences
External (e): Major swing points that define the overall market structure — these are the significant highs and lows that create the "bigger picture" trend
Internal (i): Minor swing points within the external structure — useful for fine-tuning entries and exits
Default Settings (optimized for 15m)
Setting	Default	Purpose
External Lookback	20 bars	Detects major swings
Internal Lookback	5 bars	Detects minor swings
Show External	✓ ON	Major structure always visible
Show Internal	✓ ON	Minor structure visible

## Source Code

````pine
//@version=6
indicator("MS Labels & Ranging Zones", overlay=true, max_labels_count=500, max_boxes_count=500)

// --- Inputs ---
extLen     = input.int(20, "External Swing Lookback", minval=2)
intLen     = input.int(5,  "Internal Swing Lookback", minval=2)
atrLen     = input.int(14, "ATR Length for Noise Filter")
atrMult    = input.float(0.3, "ATR Multiplier Filter", step=0.1)

showExt    = input.bool(true, "Show External Structure")
showInt    = input.bool(true, "Show Internal Structure")

extColorHi = input.color(color.aqua,   "External High Color (eHH/eLH)")
extColorLo = input.color(color.orange, "External Low Color (eLL/eHL)")
intColorHi = input.color(color.blue,   "Internal High Color (iHH/iLH)")
intColorLo = input.color(color.purple, "Internal Low Color (iLL/iHL)")

labelSize  = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal, size.large])

// --- Calculations ---
atr = ta.atr(atrLen)
minMove = atr * atrMult

// External Swings with Noise Filter
extPH = ta.pivothigh(high, extLen, extLen)
extPL = ta.pivotlow(low, extLen, extLen)

// Internal Swings with Noise Filter
intPH = ta.pivothigh(high, intLen, intLen)
intPL = ta.pivotlow(low, intLen, intLen)

// Persistent state
var float lastExtHi = na
var float lastExtLo = na
var float lastIntHi = na
var float lastIntLo = na

// --- Label Positioning Function ---
addLabel(x, y, txt, col, yloc) =>
    label.new(x=x, y=y, text=txt, xloc=xloc.bar_index, yloc=yloc, color=color.new(col, 100), textcolor=col, style=label.style_none, size=labelSize)

// --- Process External Structure ---
if showExt
    if not na(extPH)
        float price = high[extLen]
        bool validMove = na(lastExtHi) or math.abs(price - lastExtHi) > minMove
        if validMove
            int idx = bar_index[extLen]
            string txt = na(lastExtHi) or price > lastExtHi ? "eHH" : "eLH"
            addLabel(idx, price, txt, extColorHi, yloc.abovebar)
            lastExtHi := price

    if not na(extPL)
        float price = low[extLen]
        bool validMove = na(lastExtLo) or math.abs(price - lastExtLo) > minMove
        if validMove
            int idx = bar_index[extLen]
            string txt = na(lastExtLo) or price < lastExtLo ? "eLL" : "eHL"
            addLabel(idx, price, txt, extColorLo, yloc.belowbar)
            lastExtLo := price

// --- Process Internal Structure ---
if showInt
    if not na(intPH)
        float price = high[intLen]
        bool validMove = (na(lastIntHi) or math.abs(price - lastIntHi) > minMove) and na(extPH)
        if validMove
            int idx = bar_index[intLen]
            string txt = na(lastIntHi) or price > lastIntHi ? "iHH" : "iLH"
            addLabel(idx, price, txt, intColorHi, yloc.abovebar)
            lastIntHi := price

    if not na(intPL)
        float price = low[intLen]
        bool validMove = (na(lastIntLo) or math.abs(price - lastIntLo) > minMove) and na(extPL)
        if validMove
            int idx = bar_index[intLen]
            string txt = na(lastIntLo) or price < lastIntLo ? "iLL" : "iHL"
            addLabel(idx, price, txt, intColorLo, yloc.belowbar)
            lastIntLo := price
````
