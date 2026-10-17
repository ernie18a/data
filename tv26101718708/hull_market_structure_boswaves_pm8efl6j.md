# Hull Market Structure [BOSWaves]

- url: https://www.tradingview.com/script/Pm8Efl6j-Hull-Market-Structure-BOSWaves/
- type: indicator
- pine_id: PUB;605c56761f534d85a926cf271c9a6efe
- version: 1.0

## Description

BRAYAN SUPPORT & RESISTANCE

Automatic Support and Resistance indicator designed to identify key market levels where price is likely to:
- Bounce
- Reject
- Reverse
- Break with strength

FEATURES:
✅ Automatic support levels
✅ Automatic resistance levels
✅ Dynamic market structure
✅ Clean and simple design
✅ Optimized for XAUUSD
✅ Works on M1 and M5

COLORS:
🟢 Green = Support
🔴 Red = Resistance

BEST USE:
- M5 for main structure
- M1 for precise entries
- Best during New York session

Perfect for:
- Scalping
- Smart Money Concepts
- Rejections
- Breakouts
- Trend confirmations

This indicator helps traders identify high probability reaction zones in the market.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Hull Market Structure [BOSWaves]", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string g1 = "Hull"
const string g2 = "Structure"
const string g3 = "Position Tool"
const string g4 = "Display"

int   hullLen    = input.int(50, "Hull Length", minval = 5, maxval = 200, group = g1, tooltip = "Period for the Hull Moving Average. Lower = faster, higher = smoother.")

int   swingLen   = input.int(5, "Swing Length", minval = 2, maxval = 20, group = g2, tooltip = "Bars left/right to confirm swing highs and lows.")
int   cooloff    = input.int(10, "Signal Cooloff", minval = 3, maxval = 50, group = g2, tooltip = "Minimum bars between consecutive BOS/CHoCH signals.")
 
float slBuffer   = input.float(0.1, "SL Buffer %", minval = 0, maxval = 2, step = 0.05, group = g3, tooltip = "Extra percentage added to the SL level for breathing room.")
bool  showPos    = input.bool(true, "Show Position Tool", group = g3, tooltip = "Plots entry, SL and TP levels on the bar after a CHoCH signal.")
int   maxPos     = input.int(2, "Max Positions Visible", minval = 1, maxval = 10, group = g3, tooltip = "Limits how many position tools are shown on the chart. Oldest are removed first.")
float tp1R       = input.float(1.0, "TP1 (R)", minval = 0.5, maxval = 5.0, step = 0.5, group = g3, tooltip = "First take profit as a multiple of risk.")
float tp2R       = input.float(2.0, "TP2 (R)", minval = 1.0, maxval = 10.0, step = 0.5, group = g3, tooltip = "Second take profit as a multiple of risk.")
float tp3R       = input.float(3.0, "TP3 (R)", minval = 1.5, maxval = 15.0, step = 0.5, group = g3, tooltip = "Third take profit as a multiple of risk.")
int   posExtend  = input.int(30, "Position Extend", minval = 10, maxval = 100, group = g3, tooltip = "How far the position tool levels extend to the right.")

bool  paintBar   = input.bool(true, "Color Candles", group = g4)
color bullCol    = input.color(#00ff88, "Bullish", inline = "c", group = g4)
color bearCol    = input.color(#ff3366, "Bearish", inline = "c", group = g4)

// ┌────────────────────────────── BOSWaves ─ Hull MA ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float hull      = ta.hma(close, hullLen)
int   hullTrend = hull > hull[2] ? 1 : hull < hull[2] ? -1 : 0
float atr       = ta.atr(14)
color hullCol   = hullTrend == 1 ? bullCol : bearCol

pHull1 = plot(hull, "Hull", color.new(hullCol,60), 1)
pHull2 = plot(hull[2], "Hull Trail", color.new(hullCol,60), 1)
fill(pHull1, pHull2, color.new(hullCol, 60))

// ┌────────────────────────────── BOSWaves ─ Swing Detection ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var int structTrend = 0
var float currSwHi     = na
var int   currSwHiBar  = na
var float currSwLo     = na
var int   currSwLoBar  = na
var float prevSwHi     = na
var float prevSwLo     = na
var int   prevSwHiBar  = na
var int   prevSwLoBar  = na

if not na(ph)
    prevSwHi    := currSwHi
    prevSwHiBar := currSwHiBar
    currSwHi    := high[swingLen]
    currSwHiBar := bar_index - swingLen

if not na(pl)
    prevSwLo    := currSwLo
    prevSwLoBar := currSwLoBar
    currSwLo    := low[swingLen]
    currSwLoBar := bar_index - swingLen

 
  
// ┌────────────────────────────── BOSWaves ─ Position Tool Storage ──────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var posLines  = array.new<line>()
var posBoxes  = array.new<box>()
var posLabels = array.new<label>()
var int posCount = 0

// ┌────────────────────────────── BOSWaves ─ BOS / CHoCH ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var int lastBullSignal = na
var int lastBearSignal = na

bool canBull = na(lastBullSignal) or (bar_index - lastBullSignal) >= cooloff
bool canBear = na(lastBearSignal) or (bar_index - lastBearSignal) >= cooloff

bool bullBreak = canBull and hullTrend == 1 and not na(prevSwHi) and close > prevSwHi and close[1] <= prevSwHi
bool bearBreak = canBear and hullTrend == -1 and not na(prevSwLo) and close < prevSwLo and close[1] >= prevSwLo

var bool  pendingBullPos = false
var bool  pendingBearPos = false
var float pendingSL      = na

if bullBreak
    lastBullSignal := bar_index

    bool isCHoCH = structTrend <= 0
    string txt   = isCHoCH ? "CHoCH" : "BOS"
    structTrend  := 1

    int originBar = nz(prevSwHiBar, bar_index - 10)
    float level   = prevSwHi

    line.new(originBar, level, bar_index, level,
         color = color.new(bullCol, 40), width = 1, style = line.style_dashed)

    int midBar = originBar + int((bar_index - originBar) / 2)
    label.new(midBar, level, txt,
         style = label.style_none,
         textcolor = bullCol,
         size = isCHoCH ? size.normal : size.small)

    float slLevel = low * (1 - slBuffer / 100)
 

    if isCHoCH and showPos
        pendingBullPos := true
        pendingSL      := slLevel

if bearBreak
    lastBearSignal := bar_index

    bool isCHoCH = structTrend >= 0
    string txt   = isCHoCH ? "CHoCH" : "BOS"
    structTrend  := -1

    int originBar = nz(prevSwLoBar, bar_index - 10)
    float level   = prevSwLo

    line.new(originBar, level, bar_index, level,
         color = color.new(bearCol, 40), width = 1, style = line.style_dashed)

    int midBar = originBar + int((bar_index - originBar) / 2)
    label.new(midBar, level, txt,
         style = label.style_none,
         textcolor = bearCol,
         size = isCHoCH ? size.normal : size.small)

    float slLevel = high * (1 + slBuffer / 100)
 

    if isCHoCH and showPos
        pendingBearPos := true
        pendingSL      := slLevel

// ┌────────────────────────────── BOSWaves ─ Position Tool ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if pendingBullPos
    pendingBullPos := false

    float entry = open
    float sl    = pendingSL
    float risk  = entry - sl
    float tp1   = entry + risk * tp1R
    float tp2   = entry + risk * tp2R
    float tp3   = entry + risk * tp3R
    int   ext   = bar_index + posExtend

    posLines.push(line.new(bar_index, entry, ext, entry,
         color = color.new(bullCol, 20), width = 1, style = line.style_solid))
    posLines.push(line.new(bar_index, tp1, ext, tp1,
         color = color.new(bullCol, 40), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp2, ext, tp2,
         color = color.new(bullCol, 50), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp3, ext, tp3,
         color = color.new(bullCol, 60), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, sl, ext, sl,
         color = color.new(bearCol, 30), width = 1, style = line.style_dotted))

    posBoxes.push(box.new(bar_index, tp1, ext, entry,
         border_color = color.new(bullCol, 80), bgcolor = color.new(bullCol, 92), border_width = 0))
    posBoxes.push(box.new(bar_index, tp2, ext, tp1,
         border_color = color.new(bullCol, 85), bgcolor = color.new(bullCol, 94), border_width = 0))
    posBoxes.push(box.new(bar_index, tp3, ext, tp2,
         border_color = color.new(bullCol, 88), bgcolor = color.new(bullCol, 95), border_width = 0))
    posBoxes.push(box.new(bar_index, entry, ext, sl,
         border_color = color.new(bearCol, 85), bgcolor = color.new(bearCol, 95), border_width = 0))

    posLabels.push(label.new(ext, entry, "Entry " + str.tostring(entry, format.mintick),
         style = label.style_none, textcolor = color.new(bullCol, 10), size = size.normal))
    posLabels.push(label.new(ext, tp1, "TP1 " + str.tostring(tp1R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bullCol, 20), size = size.normal))
    posLabels.push(label.new(ext, tp2, "TP2 " + str.tostring(tp2R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bullCol, 30), size = size.normal))
    posLabels.push(label.new(ext, tp3, "TP3 " + str.tostring(tp3R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bullCol, 40), size = size.normal))
    posLabels.push(label.new(ext, sl, "SL " + str.tostring(sl, format.mintick),
         style = label.style_none, textcolor = color.new(bearCol, 20), size = size.normal))

    posCount += 1
    while posCount > maxPos
        for _j = 0 to 4
            if posLines.size() > 0
                posLines.shift().delete()
        for _j = 0 to 3
            if posBoxes.size() > 0
                posBoxes.shift().delete()
        for _j = 0 to 4
            if posLabels.size() > 0
                posLabels.shift().delete()
        posCount -= 1

if pendingBearPos
    pendingBearPos := false

    float entry = open
    float sl    = pendingSL
    float risk  = sl - entry
    float tp1   = entry - risk * tp1R
    float tp2   = entry - risk * tp2R
    float tp3   = entry - risk * tp3R
    int   ext   = bar_index + posExtend

    posLines.push(line.new(bar_index, entry, ext, entry,
         color = color.new(bearCol, 20), width = 1, style = line.style_solid))
    posLines.push(line.new(bar_index, tp1, ext, tp1,
         color = color.new(bearCol, 40), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp2, ext, tp2,
         color = color.new(bearCol, 50), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, tp3, ext, tp3,
         color = color.new(bearCol, 60), width = 1, style = line.style_dotted))
    posLines.push(line.new(bar_index, sl, ext, sl,
         color = color.new(bullCol, 30), width = 1, style = line.style_dotted))

    posBoxes.push(box.new(bar_index, entry, ext, tp1,
         border_color = color.new(bearCol, 80), bgcolor = color.new(bearCol, 92), border_width = 0))
    posBoxes.push(box.new(bar_index, tp1, ext, tp2,
         border_color = color.new(bearCol, 85), bgcolor = color.new(bearCol, 94), border_width = 0))
    posBoxes.push(box.new(bar_index, tp2, ext, tp3,
         border_color = color.new(bearCol, 88), bgcolor = color.new(bearCol, 95), border_width = 0))
    posBoxes.push(box.new(bar_index, sl, ext, entry,
         border_color = color.new(bullCol, 85), bgcolor = color.new(bullCol, 95), border_width = 0))

    posLabels.push(label.new(ext, entry, "Entry " + str.tostring(entry, format.mintick),
         style = label.style_none, textcolor = color.new(bearCol, 10), size = size.normal))
    posLabels.push(label.new(ext, tp1, "TP1 " + str.tostring(tp1R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bearCol, 20), size = size.normal))
    posLabels.push(label.new(ext, tp2, "TP2 " + str.tostring(tp2R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bearCol, 30), size = size.normal))
    posLabels.push(label.new(ext, tp3, "TP3 " + str.tostring(tp3R, "#.#") + "R",
         style = label.style_none, textcolor = color.new(bearCol, 40), size = size.normal))
    posLabels.push(label.new(ext, sl, "SL " + str.tostring(sl, format.mintick),
         style = label.style_none, textcolor = color.new(bullCol, 20), size = size.normal))

    posCount += 1
    while posCount > maxPos
        for _j = 0 to 4
            if posLines.size() > 0
                posLines.shift().delete()
        for _j = 0 to 3
            if posBoxes.size() > 0
                posBoxes.shift().delete()
        for _j = 0 to 4
            if posLabels.size() > 0
                posLabels.shift().delete()
        posCount -= 1

// ┌────────────────────────────── BOSWaves ─ Candles + BG ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
color trendCol = structTrend == 1 ? bullCol : structTrend == -1 ? bearCol : color.gray

barcolor(paintBar ? color.new(trendCol, 30) : na)
 
// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(bullBreak, "Bullish BOS", "Bullish break of structure on {{ticker}}")
alertcondition(bearBreak, "Bearish BOS", "Bearish break of structure on {{ticker}}")
alertcondition(bullBreak and structTrend <= 0, "Bullish CHoCH", "Change of character bullish on {{ticker}}")
alertcondition(bearBreak and structTrend >= 0, "Bearish CHoCH", "Change of character bearish on {{ticker}}")
````
