# Retracement Points [STRAT+EMA]

- url: https://www.tradingview.com/script/gMnjtFJp-Retracement-Points-STRAT-EMA/
- type: indicator
- pine_id: PUB;6e2b0b5f6d1746f2a1165f8e0edb3ed5
- version: 1.0

## Description

It helps with dealing with retracement which helps in entry and exit for scalp.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Custom Retracement Points Indicator for STRAT+EMA Strategy
//@version=5
indicator("Retracement Points [STRAT+EMA]", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
lookback         = input.int(5,   title="Swing Lookback (bars each side)", minval=1, maxval=20)
showUpLabels     = input.bool(true,  title="Show Up Move Labels")
showDnLabels     = input.bool(true,  title="Show Down Move Labels")
showLines        = input.bool(true,  title="Show Retracement Lines")
labelSize        = input.string("small", title="Label Size", options=["tiny","small","normal","large"])
pointsOrPct      = input.string("Points", title="Display Mode", options=["Points","Percent","Both"])
lineStyle        = input.string("Dashed", title="Line Style", options=["Solid","Dashed","Dotted"])

// ─────────────────────────────────────────────────────────────────────────────
// SWING HIGH / LOW DETECTION
// ─────────────────────────────────────────────────────────────────────────────
isSwingHigh = ta.pivothigh(high, lookback, lookback)
isSwingLow  = ta.pivotlow(low,  lookback, lookback)

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
labelSz = labelSize == "tiny"   ? size.tiny   :
          labelSize == "small"  ? size.small  :
          labelSize == "large"  ? size.large  : size.normal

lineStl = lineStyle == "Solid"  ? line.style_solid  :
          lineStyle == "Dotted" ? line.style_dotted : line.style_dashed

formatLabel(pts, pct) =>
    ptsStr = str.tostring(math.round(pts * 100) / 100)
    pctStr = str.tostring(math.round(pct * 10)  / 10) + "%"
    pointsOrPct == "Points"  ? ptsStr :
     pointsOrPct == "Percent" ? pctStr : ptsStr + "\n" + pctStr

// ─────────────────────────────────────────────────────────────────────────────
// TRACK PREVIOUS PIVOT
// ─────────────────────────────────────────────────────────────────────────────
var float lastHighPrice = na
var int   lastHighBar   = na
var float lastLowPrice  = na
var int   lastLowBar    = na

// ─────────────────────────────────────────────────────────────────────────────
// PROCESS SWING HIGHS
// ─────────────────────────────────────────────────────────────────────────────
if not na(isSwingHigh)
    pivotBar   = bar_index - lookback
    pivotPrice = isSwingHigh

    if not na(lastLowPrice) and showUpLabels
        pts = pivotPrice - lastLowPrice
        pct = (pts / lastLowPrice) * 100

        label.new(
             x        = pivotBar,
             y        = pivotPrice,
             text     = "▲ " + formatLabel(pts, pct),
             color    = color.new(color.teal, 10),
             textcolor = color.white,
             style    = label.style_label_down,
             size     = labelSz)

        if showLines
            line.new(
                 x1    = lastLowBar,
                 y1    = lastLowPrice,
                 x2    = pivotBar,
                 y2    = pivotPrice,
                 color = color.new(color.teal, 40),
                 width = 1,
                 style = lineStl)

    lastHighPrice := pivotPrice
    lastHighBar   := pivotBar

// ─────────────────────────────────────────────────────────────────────────────
// PROCESS SWING LOWS
// ─────────────────────────────────────────────────────────────────────────────
if not na(isSwingLow)
    pivotBar   = bar_index - lookback
    pivotPrice = isSwingLow

    if not na(lastHighPrice) and showDnLabels
        pts = lastHighPrice - pivotPrice
        pct = (pts / lastHighPrice) * 100

        label.new(
             x         = pivotBar,
             y         = pivotPrice,
             text      = "▼ " + formatLabel(pts, pct),
             color     = color.new(color.red, 10),
             textcolor = color.white,
             style     = label.style_label_up,
             size      = labelSz)

        if showLines
            line.new(
                 x1    = lastHighBar,
                 y1    = lastHighPrice,
                 x2    = pivotBar,
                 y2    = pivotPrice,
                 color = color.new(color.red, 40),
                 width = 1,
                 style = lineStl)

    lastLowPrice := pivotPrice
    lastLowBar   := pivotBar

// ─────────────────────────────────────────────────────────────────────────────
// LIVE RETRACEMENT FROM LAST CONFIRMED PIVOT
// ─────────────────────────────────────────────────────────────────────────────
var label liveLabel = na
var line  liveLine  = na

label.delete(liveLabel)
line.delete(liveLine)

if not na(lastHighPrice) and not na(lastLowPrice)
    if lastHighBar > lastLowBar
        pts = lastHighPrice - close
        pct = (pts / lastHighPrice) * 100
        dir = pts >= 0 ? "▼ Pullback: " : "▲ Extension: "
        col = pts >= 0 ? color.new(color.red, 5) : color.new(color.teal, 5)

        liveLabel := label.new(
             x         = bar_index,
             y         = close,
             text      = dir + formatLabel(math.abs(pts), math.abs(pct)),
             color     = col,
             textcolor = color.white,
             style     = label.style_label_left,
             size      = labelSz)

        liveLine := line.new(
             x1    = lastHighBar,
             y1    = lastHighPrice,
             x2    = bar_index,
             y2    = close,
             color = color.new(col, 50),
             width = 1,
             style = line.style_dotted)
    else
        pts = close - lastLowPrice
        pct = (pts / lastLowPrice) * 100
        dir = pts >= 0 ? "▲ Extension: " : "▼ Retrace: "
        col = pts >= 0 ? color.new(color.teal, 5) : color.new(color.red, 5)

        liveLabel := label.new(
             x         = bar_index,
             y         = close,
             text      = dir + formatLabel(math.abs(pts), math.abs(pct)),
             color     = col,
             textcolor = color.white,
             style     = label.style_label_left,
             size      = labelSz)

        liveLine := line.new(
             x1    = lastLowBar,
             y1    = lastLowPrice,
             x2    = bar_index,
             y2    = close,
             color = color.new(col, 50),
             width = 1,
             style = line.style_dotted)
````
