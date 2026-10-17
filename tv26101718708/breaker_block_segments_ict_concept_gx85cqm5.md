# Breaker Block Segments (ICT Concept)

- url: https://www.tradingview.com/script/Gx85cqm5-Breaker-Block-Segments-ICT-Concept/
- type: indicator
- pine_id: PUB;a9f418bd60744f1ab33eae5ef18ca50d
- version: 4.0

## Description

[b]Breaker Block Segments (ICT Concept)[/b]

While studying ICT (Inner Circle Trader) concepts around breaker blocks, I wanted to see if I could automatically identify them on the chart — so I built this script.

[b]What is an ICT Breaker Block?[/b]
An ICT Breaker Block is a failed order block that gets "flipped" — it acts as a strong support or resistance zone following a liquidity sweep and a market structure shift. A bearish breaker forms when an uptrend (series of Higher Lows and Higher Highs) is broken to the downside. A bullish breaker forms when a downtrend (series of Lower Highs and Lower Lows) is broken to the upside.

[b]What this script does[/b]
This script does not mark the exact breaker block candle. Instead, it identifies and draws [b]the segment that contains the breaker block[/b] — the two-leg pivot structure (the last Higher Low → Higher High → structural break, or the last Lower High → Lower Low → structural break) within which the breaker block lives. Think of it as narrowing down the zone for you to then look inside for the specific order block that flipped.

[b]How it works[/b]
The script identifies swing highs and swing lows using a configurable lookback/lookahead window (default: 2 bars each side). Equal-high and equal-low pairs are also recognised as valid swing points.

Swing points are tracked in an alternating sequence — consecutive same-type pivots are merged (the higher of two highs is kept; the lower of two lows is kept), ensuring a clean HH-HL-HH-HL or LH-LL-LH-LL chain.

A [b]Bearish Breaker Segment[/b] is identified when a configurable number of ascending Higher Low / Higher High pairs (minimum 3 pairs, i.e. 7 swing points) is followed by a Lower Low that breaks below the last Higher Low. The segment drawn is: last Higher Low → last Higher High → the breaking Lower Low.

A [b]Bullish Breaker Segment[/b] is identified when a configurable number of descending Lower High / Lower Low pairs (minimum 3 pairs) is followed by a Higher High that breaks above the last Lower High. The segment drawn is: last Lower High → last Lower Low → the breaking Higher High.

[b]Invalidation[/b]
A bearish segment is automatically removed if price trades above its Higher High. A bullish segment is removed if price trades below its Lower Low. Only live, valid segments remain on the chart.

[b]Settings[/b]

[list]
[*][i]Swing Bars[/i] — lookback and lookahead bars for swing detection
[*][i]Pivot Pairs Required[/i] — how many ascending/descending pairs must form before calling a breaker segment (minimum 3)
[*][i]Max Breakers to Display[/i] — keeps the chart clean; oldest segments are removed first
[*][i]Show Breakers[/i] — filter to show bullish only, bearish only, or both
[*][i]Show Breaker Labels[/i] — toggle the segment labels on/off
[*][i]Show Swing Dots[/i] — optionally display dots at every detected swing high and swing low, useful for understanding which pivot points the script is working with
[/list]

## Source Code

````pine
//@version=6
indicator("Breaker Block Segments (ICT Concept)", overlay=true, max_lines_count=500, max_labels_count=200)

// === Inputs ===
swingBars   = input.int(2,       "Swing Bars (Lookback & Lookahead)", minval=1, maxval=10, group="Swing Detection")
numPairs    = input.int(3,       "Pivot Pairs Required",              minval=2, maxval=6,  group="Swing Detection", tooltip="How many consecutive Higher Low / Higher High pairs (for bearish) or Lower High / Lower Low pairs (for bullish) must form before a structural break is called a Breaker Block. 2 pairs = 5 swing points total; higher = stricter.")
maxBreakers = input.int(3,       "Max Breakers to Display",           minval=1, maxval=10, group="Display")
showMode    = input.string("Both", "Show Breakers",                    options=["Both", "Bullish Only", "Bearish Only"], group="Display")
bullColor   = input.color(color.green, "Bullish Breaker Color", group="Appearance")
bearColor   = input.color(color.red,   "Bearish Breaker Color", group="Appearance")
lineWidth   = input.int(2,       "Line Width",  minval=1, maxval=4,   group="Appearance")
styleOpt    = input.string("solid", "Line Style", options=["solid", "dashed", "dotted"], group="Appearance")
showLabels       = input.bool(true,  "Show Breaker Labels",       group="Appearance")
showBrokenLevels = input.bool(true,  "Show Broken Level Lines",   group="Appearance")
showDots    = input.bool(false,  "Show Swing Dots",  group="Swing Dots")
dotSize     = input.string("small", "Dot Size",      group="Swing Dots", options=["tiny", "small", "normal", "large", "huge"])

lstyle = switch styleOpt
    "solid"  => line.style_solid
    "dashed" => line.style_dashed
    => line.style_dotted

// === Swing Detection (loop-based, identical to hunted_swings) ===
isSwingHigh = true
for j = 1 to swingBars
    if high[swingBars + j] >= high[swingBars]
        isSwingHigh := false
        break
for j = 0 to swingBars - 1
    if high[j] >= high[swingBars]
        isSwingHigh := false
        break

isSwingLow = true
for j = 1 to swingBars
    if low[swingBars + j] <= low[swingBars]
        isSwingLow := false
        break
for j = 0 to swingBars - 1
    if low[j] <= low[swingBars]
        isSwingLow := false
        break

isEqualHighPair = high[swingBars + 1] == high[swingBars]
for j = 0 to swingBars - 1
    if high[j] >= high[swingBars]
        isEqualHighPair := false
        break
for j = 2 to swingBars + 1
    if high[swingBars + j] >= high[swingBars]
        isEqualHighPair := false
        break

isEqualLowPair = low[swingBars + 1] == low[swingBars]
for j = 0 to swingBars - 1
    if low[j] <= low[swingBars]
        isEqualLowPair := false
        break
for j = 2 to swingBars + 1
    if low[swingBars + j] <= low[swingBars]
        isEqualLowPair := false
        break

isMarkHigh = isSwingHigh or isEqualHighPair
isMarkLow  = isSwingLow  or isEqualLowPair

// === Alternating Pivot Sequence ===
// Consecutive same-type pivots are merged: higher of two highs, lower of two lows.
var array<float> pvtPrice = array.new_float()
var array<int>   pvtBar   = array.new_int()
var array<int>   pvtType  = array.new_int()   // 1 = swing high, -1 = swing low

MAX_PIVOTS = 30

// === Breaker Line Storage ===
// Each breaker is two connected lines forming a V (bullish) or ^ (bearish).
var array<line>  bullL1          = array.new<line>()
var array<line>  bullL2          = array.new<line>()
var array<label> bullLabels      = array.new<label>()
var array<float> bullInvalLevel  = array.new_float()   // LL of segment — invalid if low crosses below
var array<line>  bullBrknHighLines = array.new<line>()
var array<line>  bullBrknLowLines  = array.new<line>()
var array<label> bullBrknHighLbls  = array.new<label>()
var array<label> bullBrknLowLbls   = array.new<label>()

var array<line>  bearL1          = array.new<line>()
var array<line>  bearL2          = array.new<line>()
var array<label> bearLabels      = array.new<label>()
var array<float> bearInvalLevel  = array.new_float()   // HH of segment — invalid if high crosses above
var array<line>  bearBrknHighLines = array.new<line>()
var array<line>  bearBrknLowLines  = array.new<line>()
var array<label> bearBrknHighLbls  = array.new<label>()
var array<label> bearBrknLowLbls   = array.new<label>()

bullBrk = false
bearBrk = false

// ─── Process new swing high ────────────────────────────────────────────────
if isMarkHigh
    shPrice = high[swingBars]
    shBar   = bar_index - swingBars
    sz = array.size(pvtType)
    if sz > 0 and array.get(pvtType, sz - 1) == 1
        // Consecutive high — keep the higher one (merge)
        if shPrice > array.get(pvtPrice, sz - 1)
            array.set(pvtPrice, sz - 1, shPrice)
            array.set(pvtBar,   sz - 1, shBar)
    else
        // New alternating high — append
        array.push(pvtPrice, shPrice)
        array.push(pvtBar,   shBar)
        array.push(pvtType,  1)
        while array.size(pvtPrice) > MAX_PIVOTS
            array.shift(pvtPrice)
            array.shift(pvtBar)
            array.shift(pvtType)

        // ── Check for Bullish Breaker ────────────────────────────────────
        // numPairs descending LH-LL pairs, then HH breaks above the last LH
        // Breaker segment drawn: last LH → last LL → HH
        sz2 = array.size(pvtType)
        totalPvts = 2 * numPairs + 1
        if sz2 >= totalPvts
            startIdx = sz2 - totalPvts
            typOk = true
            for k = 0 to totalPvts - 1
                expType = k % 2 == 0 ? 1 : -1
                if array.get(pvtType, startIdx + k) != expType
                    typOk := false
                    break
            if typOk
                priceOk = true
                for p = 1 to numPairs - 1
                    if array.get(pvtPrice, startIdx + p*2) >= array.get(pvtPrice, startIdx + (p-1)*2)
                        priceOk := false
                        break
                    if array.get(pvtPrice, startIdx + p*2+1) >= array.get(pvtPrice, startIdx + (p-1)*2+1)
                        priceOk := false
                        break
                lastLHIdx = startIdx + (numPairs - 1) * 2
                lastLLIdx = lastLHIdx + 1
                hhIdx     = sz2 - 1
                if array.get(pvtPrice, hhIdx) <= array.get(pvtPrice, lastLHIdx)
                    priceOk := false
                if priceOk and showMode != "Bearish Only"
                    b2  = array.get(pvtBar,   lastLHIdx)
                    b3  = array.get(pvtBar,   lastLLIdx)
                    b4  = array.get(pvtBar,   hhIdx)
                    pr2 = array.get(pvtPrice, lastLHIdx)
                    pr3 = array.get(pvtPrice, lastLLIdx)
                    pr4 = array.get(pvtPrice, hhIdx)
                    bullBrk := true
                    l1 = line.new(b2, pr2, b3, pr3, color=bullColor, width=lineWidth, style=lstyle)
                    l2 = line.new(b3, pr3, b4, pr4, color=bullColor, width=lineWidth, style=lstyle)
                    lbl = showLabels ? label.new(b4, pr4, "▲ Bullish Breaker Segment", style=label.style_label_upper_left, color=color.new(bullColor, 80), textcolor=bullColor, size=size.small) : na
                    array.push(bullL1, l1)
                    array.push(bullL2, l2)
                    array.push(bullLabels, lbl)
                    array.push(bullInvalLevel, pr3)
                    // Broken level lines:
                    //   Broken Previous High = lastLH (b2,pr2) — the lower high that HH broke above
                    //   Broken Previous Low  = prevLL (lastLLIdx-2) — the LL that was swept by lastLL
                    prevLLIdx   = lastLLIdx - 2
                    prevLLBar   = array.get(pvtBar,   prevLLIdx)
                    prevLLPrice = array.get(pvtPrice, prevLLIdx)
                    bhLine = showBrokenLevels ? line.new(b2,       pr2,       b4, pr2,       color=color.new(bullColor, 50), width=1, style=line.style_dotted) : na
                    blLine = showBrokenLevels ? line.new(prevLLBar, prevLLPrice, b4, prevLLPrice, color=color.new(bullColor, 50), width=1, style=line.style_dotted) : na
                    bhLbl  = showBrokenLevels and showLabels ? label.new(b2,       pr2,       "Broken Previous High", style=label.style_label_left, color=color.new(bullColor, 85), textcolor=bullColor, size=size.tiny) : na
                    blLbl  = showBrokenLevels and showLabels ? label.new(prevLLBar, prevLLPrice, "Broken Previous Low",  style=label.style_label_left, color=color.new(bullColor, 85), textcolor=bullColor, size=size.tiny) : na
                    array.push(bullBrknHighLines, bhLine)
                    array.push(bullBrknLowLines,  blLine)
                    array.push(bullBrknHighLbls,  bhLbl)
                    array.push(bullBrknLowLbls,   blLbl)
                    while array.size(bullL1) > maxBreakers
                        line.delete(array.shift(bullL1))
                        line.delete(array.shift(bullL2))
                        label.delete(array.shift(bullLabels))
                        array.shift(bullInvalLevel)
                        line.delete(array.shift(bullBrknHighLines))
                        line.delete(array.shift(bullBrknLowLines))
                        label.delete(array.shift(bullBrknHighLbls))
                        label.delete(array.shift(bullBrknLowLbls))

// ─── Process new swing low ─────────────────────────────────────────────────
if isMarkLow
    slPrice = low[swingBars]
    slBar   = bar_index - swingBars
    sz = array.size(pvtType)
    if sz > 0 and array.get(pvtType, sz - 1) == -1
        // Consecutive low — keep the lower one (merge)
        if slPrice < array.get(pvtPrice, sz - 1)
            array.set(pvtPrice, sz - 1, slPrice)
            array.set(pvtBar,   sz - 1, slBar)
    else
        // New alternating low — append
        array.push(pvtPrice, slPrice)
        array.push(pvtBar,   slBar)
        array.push(pvtType,  -1)
        while array.size(pvtPrice) > MAX_PIVOTS
            array.shift(pvtPrice)
            array.shift(pvtBar)
            array.shift(pvtType)

        // ── Check for Bearish Breaker ────────────────────────────────────
        // numPairs ascending HL-HH pairs, then LL breaks below the last HL
        // Breaker segment drawn: last HL → last HH → LL
        sz2 = array.size(pvtType)
        totalPvts = 2 * numPairs + 1
        if sz2 >= totalPvts
            startIdx = sz2 - totalPvts
            typOk = true
            for k = 0 to totalPvts - 1
                expType = k % 2 == 0 ? -1 : 1
                if array.get(pvtType, startIdx + k) != expType
                    typOk := false
                    break
            if typOk
                priceOk = true
                for p = 1 to numPairs - 1
                    if array.get(pvtPrice, startIdx + p*2) <= array.get(pvtPrice, startIdx + (p-1)*2)
                        priceOk := false
                        break
                    if array.get(pvtPrice, startIdx + p*2+1) <= array.get(pvtPrice, startIdx + (p-1)*2+1)
                        priceOk := false
                        break
                lastHLIdx = startIdx + (numPairs - 1) * 2
                lastHHIdx = lastHLIdx + 1
                llIdx     = sz2 - 1
                if array.get(pvtPrice, llIdx) >= array.get(pvtPrice, lastHLIdx)
                    priceOk := false
                if priceOk and showMode != "Bullish Only"
                    b2  = array.get(pvtBar,   lastHLIdx)
                    b3  = array.get(pvtBar,   lastHHIdx)
                    b4  = array.get(pvtBar,   llIdx)
                    pr2 = array.get(pvtPrice, lastHLIdx)
                    pr3 = array.get(pvtPrice, lastHHIdx)
                    pr4 = array.get(pvtPrice, llIdx)
                    bearBrk := true
                    l1 = line.new(b2, pr2, b3, pr3, color=bearColor, width=lineWidth, style=lstyle)
                    l2 = line.new(b3, pr3, b4, pr4, color=bearColor, width=lineWidth, style=lstyle)
                    lbl = showLabels ? label.new(b4, pr4, "▼ Bearish Breaker Segment", style=label.style_label_lower_left, color=color.new(bearColor, 80), textcolor=bearColor, size=size.small) : na
                    array.push(bearL1, l1)
                    array.push(bearL2, l2)
                    array.push(bearLabels, lbl)
                    array.push(bearInvalLevel, pr3)
                    // Broken level lines:
                    //   Broken Previous High = prevHH (lastHHIdx-2) — the HH that was exceeded by lastHH
                    //   Broken Previous Low  = lastHL (b2,pr2) — the HL that the LL broke below
                    prevHHIdx   = lastHHIdx - 2
                    prevHHBar   = array.get(pvtBar,   prevHHIdx)
                    prevHHPrice = array.get(pvtPrice, prevHHIdx)
                    bhLine = showBrokenLevels ? line.new(prevHHBar, prevHHPrice, b4, prevHHPrice, color=color.new(bearColor, 50), width=1, style=line.style_dotted) : na
                    blLine = showBrokenLevels ? line.new(b2,        pr2,         b4, pr2,         color=color.new(bearColor, 50), width=1, style=line.style_dotted) : na
                    bhLbl  = showBrokenLevels and showLabels ? label.new(prevHHBar, prevHHPrice, "Broken Previous High", style=label.style_label_left, color=color.new(bearColor, 85), textcolor=bearColor, size=size.tiny) : na
                    blLbl  = showBrokenLevels and showLabels ? label.new(b2,        pr2,         "Broken Previous Low",  style=label.style_label_left, color=color.new(bearColor, 85), textcolor=bearColor, size=size.tiny) : na
                    array.push(bearBrknHighLines, bhLine)
                    array.push(bearBrknLowLines,  blLine)
                    array.push(bearBrknHighLbls,  bhLbl)
                    array.push(bearBrknLowLbls,   blLbl)
                    while array.size(bearL1) > maxBreakers
                        line.delete(array.shift(bearL1))
                        line.delete(array.shift(bearL2))
                        label.delete(array.shift(bearLabels))
                        array.shift(bearInvalLevel)
                        line.delete(array.shift(bearBrknHighLines))
                        line.delete(array.shift(bearBrknLowLines))
                        label.delete(array.shift(bearBrknHighLbls))
                        label.delete(array.shift(bearBrknLowLbls))

// === Invalidation: remove breakers price has traded through ===
if array.size(bullL1) > 0
    for i = array.size(bullL1) - 1 to 0
        if low <= array.get(bullInvalLevel, i)
            line.delete(array.get(bullL1, i))
            line.delete(array.get(bullL2, i))
            label.delete(array.get(bullLabels, i))
            array.remove(bullL1, i)
            array.remove(bullL2, i)
            array.remove(bullLabels, i)
            array.remove(bullInvalLevel, i)
            line.delete(array.remove(bullBrknHighLines, i))
            line.delete(array.remove(bullBrknLowLines, i))
            label.delete(array.remove(bullBrknHighLbls, i))
            label.delete(array.remove(bullBrknLowLbls, i))

if array.size(bearL1) > 0
    for i = array.size(bearL1) - 1 to 0
        if high >= array.get(bearInvalLevel, i)
            line.delete(array.get(bearL1, i))
            line.delete(array.get(bearL2, i))
            label.delete(array.get(bearLabels, i))
            array.remove(bearL1, i)
            array.remove(bearL2, i)
            array.remove(bearLabels, i)
            array.remove(bearInvalLevel, i)
            line.delete(array.remove(bearBrknHighLines, i))
            line.delete(array.remove(bearBrknLowLines, i))
            label.delete(array.remove(bearBrknHighLbls, i))
            label.delete(array.remove(bearBrknLowLbls, i))

// === Swing Dots ===
plotshape(showDots and isMarkLow  and dotSize == "tiny",   style=shape.circle, location=location.belowbar, color=bullColor, size=size.tiny,   offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "small",  style=shape.circle, location=location.belowbar, color=bullColor, size=size.small,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "normal", style=shape.circle, location=location.belowbar, color=bullColor, size=size.normal, offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "large",  style=shape.circle, location=location.belowbar, color=bullColor, size=size.large,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkLow  and dotSize == "huge",   style=shape.circle, location=location.belowbar, color=bullColor, size=size.huge,   offset=-swingBars, editable=false, display=display.pane)

plotshape(showDots and isMarkHigh and dotSize == "tiny",   style=shape.circle, location=location.abovebar, color=bearColor, size=size.tiny,   offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "small",  style=shape.circle, location=location.abovebar, color=bearColor, size=size.small,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "normal", style=shape.circle, location=location.abovebar, color=bearColor, size=size.normal, offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "large",  style=shape.circle, location=location.abovebar, color=bearColor, size=size.large,  offset=-swingBars, editable=false, display=display.pane)
plotshape(showDots and isMarkHigh and dotSize == "huge",   style=shape.circle, location=location.abovebar, color=bearColor, size=size.huge,   offset=-swingBars, editable=false, display=display.pane)

// === Alerts ===
alertcondition(bullBrk,
     title="Bullish Breaker Block",
     message="Bullish Breaker Block detected — downtrend structure broken to the upside")
alertcondition(bearBrk,
     title="Bearish Breaker Block",
     message="Bearish Breaker Block detected — uptrend structure broken to the downside")
alertcondition(bullBrk or bearBrk,
     title="Any Breaker Block",
     message="Breaker Block segment detected")
````
