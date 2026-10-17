# Marubozu Tap Analysis

- url: https://www.tradingview.com/script/JWNK0Aw0-Marubozu-Tap-Analysis/
- type: indicator
- pine_id: PUB;bc9c5aa660b745108871e2e0dc706b66
- version: 1.0

## Description

Tracks Marubozu open candles where open = low of a bullish candle, and open = high of a bearish candle, and outputs a probability table for taps of that level. Price later returns to these "no-wick" candles at a high rate and can serve as a draw on liquidity. User settings allow you to specify the lookback window for a tap of the Marubozu open so you can see the probability of a return to the open within a window of time.

## Source Code

````pine
//@version=5
indicator("Marubozu Tap Analysis", overlay=true, max_lines_count=500, max_labels_count=500)
// Author: leifl

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
i_expireBars = input.int(500,   "Expire Level After N Bars", minval=1, maxval=5000, step=1,  group="Settings",
     tooltip="A level is marked as 'Untapped' (miss) if price hasn't revisited it within this many candles.")

i_showLines  = input.bool(true,  "Show Dashed Level Lines",  group="Display")
i_showLabels = input.bool(true,  "Show Candle Labels",       group="Display")

i_tablePos   = input.string("Top Right", "Table Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Display")

// Label Appearance
i_labelSize = input.string("Tiny", "Label Size",
     options = ["Tiny","Small","Normal","Large","Huge"],
     group="Label Appearance")

i_bullLabelColor = input.color(color.green, "Bull Label Color", group="Label Appearance")
i_bearLabelColor = input.color(color.red,  "Bear Label Color", group="Label Appearance")
i_labelTextColor = input.color(color.white,"Label Text Color", group="Label Appearance")

// convert label size
_labelSize = switch i_labelSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.huge

_tPos = switch i_tablePos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

// ═══════════════════════════════════════════════════════════════════════════════
//  CANDLE CLASSIFICATION
// ═══════════════════════════════════════════════════════════════════════════════
isBullNW = open == low
isBearNW = open == high

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════════════════
var float[] bLvl  = array.new_float(0)
var int[]   bBar  = array.new_int(0)
var line[]  bLine = array.new_line(0)

var float[] rLvl  = array.new_float(0)
var int[]   rBar  = array.new_int(0)
var line[]  rLine = array.new_line(0)

var int   bHits = 0
var int   bMiss = 0
var float bSum  = 0.0

var int   rHits = 0
var int   rMiss = 0
var float rSum  = 0.0

// ═══════════════════════════════════════════════════════════════════════════════
//  ADD NEW LEVELS
// ═══════════════════════════════════════════════════════════════════════════════
if isBullNW
    lc = i_showLines ? color.new(color.green, 0) : color.new(color.green, 100)
    ln = line.new(bar_index, open, bar_index + 1, open,
         extend = extend.right, color = lc, style = line.style_dashed, width = 1)

    array.push(bLvl,  open)
    array.push(bBar,  bar_index)
    array.push(bLine, ln)

    if i_showLabels
        label.new(bar_index, low,
             style     = label.style_label_up,
             size      = _labelSize,
             color     = color.new(i_bullLabelColor, 20),
             textcolor = i_labelTextColor)

if isBearNW
    lc = i_showLines ? color.new(color.red, 0) : color.new(color.red, 100)
    ln = line.new(bar_index, open, bar_index + 1, open,
         extend = extend.right, color = lc, style = line.style_dashed, width = 1)

    array.push(rLvl,  open)
    array.push(rBar,  bar_index)
    array.push(rLine, ln)

    if i_showLabels
        label.new(bar_index, high,
             style     = label.style_label_down,
             size      = _labelSize,
             color     = color.new(i_bearLabelColor, 20),
             textcolor = i_labelTextColor)

// ═══════════════════════════════════════════════════════════════════════════════
//  RESOLVE BULL LEVELS
// ═══════════════════════════════════════════════════════════════════════════════
if array.size(bLvl) > 0
    i = array.size(bLvl) - 1
    while i >= 0
        lvl     = array.get(bLvl, i)
        created = array.get(bBar, i)
        elapsed = bar_index - created

        if elapsed > 0
            tapped  = low <= lvl
            expired = elapsed >= i_expireBars

            if tapped or expired
                if tapped
                    bHits += 1
                    bSum  += elapsed
                else
                    bMiss += 1

                line.delete(array.get(bLine, i))
                array.remove(bLvl,  i)
                array.remove(bBar,  i)
                array.remove(bLine, i)
        i -= 1

// ═══════════════════════════════════════════════════════════════════════════════
//  RESOLVE BEAR LEVELS
// ═══════════════════════════════════════════════════════════════════════════════
if array.size(rLvl) > 0
    i = array.size(rLvl) - 1
    while i >= 0
        lvl     = array.get(rLvl, i)
        created = array.get(rBar, i)
        elapsed = bar_index - created

        if elapsed > 0
            tapped  = high >= lvl
            expired = elapsed >= i_expireBars

            if tapped or expired
                if tapped
                    rHits += 1
                    rSum  += elapsed
                else
                    rMiss += 1

                line.delete(array.get(rLine, i))
                array.remove(rLvl,  i)
                array.remove(rBar,  i)
                array.remove(rLine, i)
        i -= 1


// ═══════════════════════════════════════════════════════════════════════════════
//  STATS TABLE
// ═══════════════════════════════════════════════════════════════════════════════
f_pct(h, m) =>
    total = h + m
    total > 0 ? h / total * 100.0 : 0.0

f_avg(s, h) =>
    h > 0 ? s / h : 0.0

f_fmt_avg(s, h) =>
    h > 0 ? str.tostring(math.round(f_avg(s, h), 1)) : "–"

var table T = table.new(
     _tPos, 4, 8,
     bgcolor      = color.new(#0a0a18, 5),
     border_width = 1,
     border_color = color.new(#3a3a5c, 0),
     frame_width  = 1,
     frame_color  = color.new(#5555aa, 0))

if barstate.islast
    C_HDR  = #141428
    C_TXT  = #b0b0d0
    C_BULL = color.lime
    C_BEAR = #ff4444
    C_HIT  = #00e676
    C_MISS = #ff6d00
    C_PCT  = #ffe082
    C_NUM  = color.white
    C_DIM  = #55556a
    SZ     = size.small

    bTot = bHits + bMiss
    rTot = rHits + rMiss
    cHit = bHits + rHits
    cMis = bMiss + rMiss
    cTot = bTot  + rTot

    // Header row
    table.cell(T, 0, 0, "Metric",     text_color=C_TXT,  bgcolor=C_HDR, text_size=SZ)
    table.cell(T, 1, 0, "Bullish NW", text_color=C_BULL, bgcolor=C_HDR, text_size=SZ)
    table.cell(T, 2, 0, "Bearish NW", text_color=C_BEAR, bgcolor=C_HDR, text_size=SZ)
    table.cell(T, 3, 0, "Combined",   text_color=C_TXT,  bgcolor=C_HDR, text_size=SZ)

    // Description row
    table.cell(T, 0, 1, "Structure",   text_color=C_DIM, text_size=SZ, text_halign=text.align_left)
    table.cell(T, 1, 1, "Open = Low",  text_color=C_DIM, text_size=SZ)
    table.cell(T, 2, 1, "Open = High", text_color=C_DIM, text_size=SZ)
    table.cell(T, 3, 1, "Both",        text_color=C_DIM, text_size=SZ)

    // Identified
    table.cell(T, 0, 2, "Identified",       text_color=C_TXT, text_size=SZ, text_halign=text.align_left)
    table.cell(T, 1, 2, str.tostring(bTot), text_color=C_NUM, text_size=SZ)
    table.cell(T, 2, 2, str.tostring(rTot), text_color=C_NUM, text_size=SZ)
    table.cell(T, 3, 2, str.tostring(cTot), text_color=C_NUM, text_size=SZ)

    // Tapped
    table.cell(T, 0, 3, "Tapped ✓",          text_color=C_TXT, text_size=SZ, text_halign=text.align_left)
    table.cell(T, 1, 3, str.tostring(bHits),  text_color=C_HIT, text_size=SZ)
    table.cell(T, 2, 3, str.tostring(rHits),  text_color=C_HIT, text_size=SZ)
    table.cell(T, 3, 3, str.tostring(cHit),   text_color=C_HIT, text_size=SZ)

    // Untapped
    table.cell(T, 0, 4, "Untapped ✗",        text_color=C_TXT,  text_size=SZ, text_halign=text.align_left)
    table.cell(T, 1, 4, str.tostring(bMiss),  text_color=C_MISS, text_size=SZ)
    table.cell(T, 2, 4, str.tostring(rMiss),  text_color=C_MISS, text_size=SZ)
    table.cell(T, 3, 4, str.tostring(cMis),   text_color=C_MISS, text_size=SZ)

    // Hit Rate
    bPct = bTot > 0 ? math.round(bHits / bTot * 100, 1) : 0.0
    rPct = rTot > 0 ? math.round(rHits / rTot * 100, 1) : 0.0
    cPct = cTot > 0 ? math.round(cHit  / cTot * 100, 1) : 0.0
    table.cell(T, 0, 5, "Hit Rate",                            text_color=C_TXT, text_size=SZ, text_halign=text.align_left)
    table.cell(T, 1, 5, str.tostring(bPct) + "%",             text_color=C_PCT, text_size=SZ)
    table.cell(T, 2, 5, str.tostring(rPct) + "%",             text_color=C_PCT, text_size=SZ)
    table.cell(T, 3, 5, str.tostring(cPct) + "%",             text_color=C_PCT, text_size=SZ)

    // Avg bars to tap
    bAvg = bHits > 0 ? str.tostring(math.round(bSum / bHits, 1)) : "–"
    rAvg = rHits > 0 ? str.tostring(math.round(rSum / rHits, 1)) : "–"
    cAvg = cHit  > 0 ? str.tostring(math.round((bSum + rSum) / cHit, 1)) : "–"
    table.cell(T, 0, 6, "Avg Bars → Tap", text_color=C_TXT, text_size=SZ, text_halign=text.align_left)
    table.cell(T, 1, 6, bAvg,             text_color=C_NUM, text_size=SZ)
    table.cell(T, 2, 6, rAvg,             text_color=C_NUM, text_size=SZ)
    table.cell(T, 3, 6, cAvg,             text_color=C_NUM, text_size=SZ)

    // Pending
    pBull = array.size(bLvl)
    pBear = array.size(rLvl)
    table.cell(T, 0, 7, "Pending",                                          text_color=C_TXT, text_size=SZ, text_halign=text.align_left)
    table.cell(T, 1, 7, str.tostring(pBull),                               text_color=C_DIM, text_size=SZ)
    table.cell(T, 2, 7, str.tostring(pBear),                               text_color=C_DIM, text_size=SZ)
    table.cell(T, 3, 7, str.tostring(pBull + pBear),                       text_color=C_DIM, text_size=SZ)
````
