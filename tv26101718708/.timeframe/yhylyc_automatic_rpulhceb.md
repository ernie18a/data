# YH/YL/YC automatic 

- url: https://www.tradingview.com/script/RpULHceB-YH-YL-YC-automatic/
- type: indicator
- pine_id: PUB;1e42e8f6c4fc4dccae81f8f9898ecc17
- version: 1.0

## Description

This indicator will set the YH/YL/YC automatically for stocks and indexes.

## Source Code

````pine
//@version=5
indicator("YH / YL / YC (Live)", overlay=true, max_lines_count=10, max_labels_count=10)

// === INPUTS ===
colYH         = input.color(color.green,  "YH Color")
colYL         = input.color(color.green,   "YL Color")
colYC         = input.color(color.orange, "YC Color")
lineWidth     = input.int(1, "Line Width",          minval=1, maxval=5)
labelOffset   = input.int(15, "Label Offset (bars)", minval=1, maxval=50)
labelSize     = input.string("small", "Label Size", options=["tiny","small","normal","large"])
labelBgColor  = input.color(color.white, "Label Background Color")
labelTxtColor = input.color(color.black, "Label Text Color")
labelTransp   = input.int(0, "Label Background Transparency", minval=0, maxval=100)

// Map label size string naar size constante
lblSize = labelSize == "tiny"   ? size.tiny   :
          labelSize == "normal" ? size.normal :
          labelSize == "large"  ? size.large  : size.small

// Transparante versie van label achtergrond
lblBg = color.new(labelBgColor, labelTransp)

// === INSTRUMENT DETECTIE ===
// "stock" = gewone aandelen, "dr" = ADRs (zoals TSM, BABA), "fund" = ETFs
isStock    = syminfo.type == "stock" or syminfo.type == "dr" or syminfo.type == "fund"
isIntraday = timeframe.isintraday

// ═══════════════════════════════════════════════════════════
// INDICES/FUTURES
// ═══════════════════════════════════════════════════════════
dHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
dLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
dClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════
// STOCKS INTRADAY → manuele RTH tracking
// ═══════════════════════════════════════════════════════════
rthSession = "0930-1600"
nyTz       = "America/New_York"
inRTH      = isIntraday ? not na(time(timeframe.period, rthSession, nyTz)) : false

var float curRthHigh  = na
var float curRthLow   = na
var float curRthClose = na
var float prevRthHigh  = na
var float prevRthLow   = na
var float prevRthClose = na

if inRTH and not inRTH[1]
    prevRthHigh  := curRthHigh
    prevRthLow   := curRthLow
    prevRthClose := curRthClose
    curRthHigh  := high
    curRthLow   := low
    curRthClose := close

if inRTH
    curRthHigh  := na(curRthHigh) ? high : math.max(curRthHigh, high)
    curRthLow   := na(curRthLow)  ? low  : math.min(curRthLow, low)
    curRthClose := close

sHighI  = inRTH ? prevRthHigh  : curRthHigh
sLowI   = inRTH ? prevRthLow   : curRthLow
sCloseI = inRTH ? prevRthClose : curRthClose

// ═══════════════════════════════════════════════════════════
// STOCKS DAILY+ TF
// ═══════════════════════════════════════════════════════════
// Check of de laatste daily bar "vandaag" is:
// - Vandaag (live, forming) → [1] = gisteren
// - Niet vandaag (premarket/weekend) → [0] = gisteren
isCurrentBarToday = dayofmonth(time) == dayofmonth(timenow) and month(time) == month(timenow) and year(time) == year(timenow)

sHighD  = isCurrentBarToday ? high[1]  : high
sLowD   = isCurrentBarToday ? low[1]   : low
sCloseD = isCurrentBarToday ? close[1] : close

// ═══════════════════════════════════════════════════════════
// KIES JUISTE BRON
// ═══════════════════════════════════════════════════════════
yHigh  = isStock ? (isIntraday ? sHighI  : sHighD)  : dHigh
yLow   = isStock ? (isIntraday ? sLowI   : sLowD)   : dLow
yClose = isStock ? (isIntraday ? sCloseI : sCloseD) : dClose

// === DRAW ===
var line  lineYH  = na
var line  lineYL  = na
var line  lineYC  = na
var label labelYH = na
var label labelYL = na
var label labelYC = na

if barstate.islast and not na(yHigh) and not na(yLow) and not na(yClose)
    line.delete(lineYH)
    lineYH := line.new(bar_index, yHigh, bar_index + 1, yHigh,
         extend=extend.both, color=colYH, width=lineWidth)

    line.delete(lineYL)
    lineYL := line.new(bar_index, yLow, bar_index + 1, yLow,
         extend=extend.both, color=colYL, width=lineWidth)

    line.delete(lineYC)
    lineYC := line.new(bar_index, yClose, bar_index + 1, yClose,
         extend=extend.both, color=colYC, width=lineWidth)

    label.delete(labelYH)
    labelYH := label.new(bar_index + labelOffset, yHigh, "YH",
         color=lblBg, textcolor=labelTxtColor, style=label.style_label_center, size=lblSize)

    label.delete(labelYL)
    labelYL := label.new(bar_index + labelOffset, yLow, "YL",
         color=lblBg, textcolor=labelTxtColor, style=label.style_label_center, size=lblSize)

    label.delete(labelYC)
    labelYC := label.new(bar_index + labelOffset, yClose, "YC",
         color=lblBg, textcolor=labelTxtColor, style=label.style_label_center, size=lblSize)
````
