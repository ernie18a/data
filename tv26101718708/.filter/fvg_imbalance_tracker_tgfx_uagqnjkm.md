# FVG Imbalance Tracker TGFX

- url: https://www.tradingview.com/script/uAgQNJkM-FVG-Imbalance-Tracker-TGFX/
- type: indicator
- pine_id: PUB;3ec5e8b620fd4a6aa24688fb51d7dbbe
- version: 1.0

## Description

FVG Imbalance Tracker

OVERVIEW
FVG Imbalance Tracker automatically detects, draws and tracks Fair Value Gaps (FVG), also known as imbalances. It marks each gap as a zone, extends it until price returns, and tells you when the gap has been mitigated (filled). An optional 50% midline (Consequent Encroachment / CE) and a higher-timeframe table give you context at a glance.

WHAT IS A FAIR VALUE GAP
A Fair Value Gap is a three-candle pattern where the first and third candles do not overlap, leaving a price range that was crossed in a single, one-sided move:
- Bullish FVG: the low of candle 3 is above the high of candle 1.
- Bearish FVG: the high of candle 3 is below the low of candle 1.
That untraded range is an imbalance. Price frequently returns to it later to "rebalance" before continuing, which is why these zones are useful as potential reaction areas.

HOW IT WORKS
1. On the close of every third candle, the script checks for a gap between candle 1 and candle 3.
2. If a gap is found (and passes the optional ATR size filter), a zone is drawn from the pattern to the right.
3. Each zone keeps extending until it is mitigated. You choose what mitigation means:
   - Full fill: price fully closes the gap.
   - 50% (CE): price reaches the midpoint (Consequent Encroachment).
   - Touch: price reaches the near edge of the gap.
4. Once mitigated, the zone is dimmed and stops extending (or is removed, if you prefer).

HOW TO READ IT
- Green zones = bullish Fair Value Gaps (potential demand / support areas).
- Red zones = bearish Fair Value Gaps (potential supply / resistance areas).
- Solid, extending zone = still unmitigated.
- Dimmed zone = already mitigated.
- Dotted midline = the 50% (CE) level of the gap.
- Multi-timeframe table: shows the latest imbalance direction on three higher timeframes (Bull / Bear / –) for higher-timeframe context.

SETTINGS
- Detection: optional ATR filter to ignore small gaps, ATR length, minimum gap size (× ATR), and maximum gaps kept per side.
- Mitigation: choose Full fill, 50% (CE) or Touch, and whether mitigated gaps stay dimmed or are removed.
- Visual: colors for bullish/bearish gaps, box transparency, optional border, optional 50% midline, optional labels, label size.
- Multi-timeframe table: enable/disable, the three timeframes, and table position.

REPAINTING
Gaps are confirmed on the close of the third candle, so a zone does not appear and then disappear intrabar.

ALERTS
Three alerts are available: "New bullish FVG", "New bearish FVG" and "FVG mitigated". Add them from the alert dialog and set them to trigger once per bar close.

NOTES
This script is an original implementation of standard, public price-action concepts (Fair Value Gaps and Consequent Encroachment). It is a visualization and context tool — it does not generate buy/sell signals and makes no claim about future performance. Fair Value Gaps work best combined with your own analysis (market structure, liquidity, higher-timeframe context, risk management) rather than used in isolation.

## Source Code

````pine
//@version=6
// =============================================================
//  FVG / IMBALANCE TRACKER  (Fair Value Gaps)
//  Author: TradingconGaboFX (TGFX)
//
//  WHAT IT DOES
//  ------------
//  • Detects bullish and bearish Fair Value Gaps (FVG / imbalance):
//    the 3-candle pattern where candles 1 and 3 do not overlap, leaving
//    an unfilled gap that price often returns to.
//      - Bullish FVG: low of candle 3 is above the high of candle 1.
//      - Bearish FVG: high of candle 3 is below the low of candle 1.
//  • Draws each gap as a zone that extends right until it is mitigated.
//  • Tracks mitigation (fill): when price returns into the gap by your
//    chosen amount (full fill, 50% / CE, or first touch), the zone is
//    dimmed and stops extending.
//  • Optional 50% midline (Consequent Encroachment / CE).
//  • ATR filter to ignore tiny, insignificant gaps.
//  • Multi-timeframe table with the latest imbalance direction on up to
//    three higher timeframes.
//  • Alerts for new bullish FVG, new bearish FVG, and FVG mitigated.
//
//  NOTES
//  -----
//  • FVGs are confirmed on the close of the third candle, so a zone does
//    not appear and disappear intrabar.
//  • Fair Value Gaps and Consequent Encroachment are standard, public
//    price-action concepts; this is an original implementation.
// =============================================================

indicator("FVG Imbalance Tracker TGFX", shorttitle = "FVG Tracker TGFX", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ----------------------------- Inputs -----------------------------
gD = "── Detection ──"
useMin   = input.bool(true, "Filter small gaps by ATR", group = gD)
atrLen   = input.int(14, "ATR length", minval = 1, group = gD)
minMult  = input.float(0.25, "Min gap size × ATR", minval = 0.0, step = 0.05, group = gD, tooltip = "Ignore FVGs smaller than this × ATR.")
maxBoxes = input.int(15, "Max FVGs per side", minval = 1, maxval = 80, group = gD)

gM = "── Mitigation ──"
mitMode  = input.string("Full fill", "Mitigation", options = ["Full fill", "50% (CE)", "Touch"], group = gM, tooltip = "When an FVG is considered mitigated / filled.")
keepMit  = input.bool(true, "Keep mitigated (dimmed)", group = gM, tooltip = "If off, mitigated FVGs are removed.")

gV = "── Visual ──"
bullCol    = input.color(#089981, "Bullish FVG", group = gV)
bearCol    = input.color(#f23645, "Bearish FVG", group = gV)
boxTransp  = input.int(82, "Box transparency", minval = 0, maxval = 100, group = gV)
showBorder = input.bool(false, "Show box border", group = gV)
showCE     = input.bool(true, "Show 50% line (CE)", group = gV)
showLbl    = input.bool(false, "Show FVG labels", group = gV)
lblSizeStr = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = gV)

gT = "── Multi-timeframe table ──"
showTable = input.bool(true, "Show MTF table", group = gT)
tf1       = input.timeframe("60",  "Timeframe 1", group = gT)
tf2       = input.timeframe("240", "Timeframe 2", group = gT)
tf3       = input.timeframe("D",   "Timeframe 3", group = gT)
tblPosStr = input.string("top_right", "Table position", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"], group = gT)

// ----------------------------- Helpers -----------------------------
atr     = ta.atr(atrLen)
labSize = lblSizeStr == "tiny" ? size.tiny : lblSizeStr == "small" ? size.small : size.normal

biasTxt(int d) => d ==  1 ? "Bull" : d == -1 ? "Bear" : "–"
biasCol(int d) => d ==  1 ? bullCol : d == -1 ? bearCol : color.gray

// ----------------------------- State -----------------------------
var array<box>   bBox = array.new<box>()
var array<line>  bMid = array.new<line>()
var array<label> bLab = array.new<label>()
var array<float> bTop = array.new<float>()
var array<float> bBot = array.new<float>()
var array<bool>  bMit = array.new<bool>()

var array<box>   rBox = array.new<box>()
var array<line>  rMid = array.new<line>()
var array<label> rLab = array.new<label>()
var array<float> rTop = array.new<float>()
var array<float> rBot = array.new<float>()
var array<bool>  rMit = array.new<bool>()

// Add an FVG. isBull = true -> bullish gap, false -> bearish gap. top > bot always.
addFVG(bool isBull, float top, float bot, int leftBar) =>
    col = isBull ? bullCol : bearCol
    bx  = box.new(leftBar, top, bar_index, bot, xloc = xloc.bar_index, extend = extend.right, border_color = color.new(col, showBorder ? 30 : 100), border_width = 1, bgcolor = color.new(col, boxTransp))
    line ml = na
    if showCE
        mid = (top + bot) / 2
        ml := line.new(leftBar, mid, bar_index, mid, xloc = xloc.bar_index, extend = extend.right, color = color.new(col, 25), style = line.style_dotted, width = 1)
    label lb = showLbl ? label.new(leftBar, isBull ? bot : top, "FVG", xloc = xloc.bar_index, style = isBull ? label.style_label_up : label.style_label_down, color = color.new(col, 80), textcolor = col, size = labSize) : na
    if isBull
        array.push(bBox, bx)
        array.push(bMid, ml)
        array.push(bLab, lb)
        array.push(bTop, top)
        array.push(bBot, bot)
        array.push(bMit, false)
        if array.size(bBox) > maxBoxes
            box.delete(array.shift(bBox))
            mlOld = array.shift(bMid)
            if not na(mlOld)
                line.delete(mlOld)
            lbOld = array.shift(bLab)
            if not na(lbOld)
                label.delete(lbOld)
            array.shift(bTop)
            array.shift(bBot)
            array.shift(bMit)
    else
        array.push(rBox, bx)
        array.push(rMid, ml)
        array.push(rLab, lb)
        array.push(rTop, top)
        array.push(rBot, bot)
        array.push(rMit, false)
        if array.size(rBox) > maxBoxes
            box.delete(array.shift(rBox))
            mlOld = array.shift(rMid)
            if not na(mlOld)
                line.delete(mlOld)
            lbOld = array.shift(rLab)
            if not na(lbOld)
                label.delete(lbOld)
            array.shift(rTop)
            array.shift(rBot)
            array.shift(rMit)

// Dim / stop a mitigated FVG (or delete it)
closeFVG(box bx, line ml, label lb, color col, int atBar) =>
    if keepMit
        box.set_extend(bx, extend.none)
        box.set_right(bx, atBar)
        box.set_bgcolor(bx, color.new(col, math.min(boxTransp + 12, 100)))
        box.set_border_color(bx, color.new(col, 100))
        if not na(ml)
            line.set_extend(ml, extend.none)
            line.set_x2(ml, atBar)
            line.set_color(ml, color.new(col, 70))
    else
        box.delete(bx)
        if not na(ml)
            line.delete(ml)
        if not na(lb)
            label.delete(lb)

// ----------------------------- Detection & mitigation (bar close) -----------------------------
newBull = false
newBear = false
fvgMit  = false

if barstate.isconfirmed
    // bullish FVG: candle 3 low above candle 1 high
    if low > high[2]
        sz = low - high[2]
        if not useMin or sz >= minMult * atr
            addFVG(true, low, high[2], bar_index - 2)
            newBull := true
    // bearish FVG: candle 3 high below candle 1 low
    if high < low[2]
        sz = low[2] - high
        if not useMin or sz >= minMult * atr
            addFVG(false, low[2], high, bar_index - 2)
            newBear := true

    // mitigation — bullish gaps (price returns from above)
    if array.size(bBox) > 0
        for i = 0 to array.size(bBox) - 1
            if not array.get(bMit, i)
                tp  = array.get(bTop, i)
                bt  = array.get(bBot, i)
                lvl = mitMode == "Full fill" ? bt : mitMode == "50% (CE)" ? (tp + bt) / 2 : tp
                if low <= lvl
                    array.set(bMit, i, true)
                    fvgMit := true
                    closeFVG(array.get(bBox, i), array.get(bMid, i), array.get(bLab, i), bullCol, bar_index)
    // mitigation — bearish gaps (price returns from below)
    if array.size(rBox) > 0
        for i = 0 to array.size(rBox) - 1
            if not array.get(rMit, i)
                tp  = array.get(rTop, i)
                bt  = array.get(rBot, i)
                lvl = mitMode == "Full fill" ? tp : mitMode == "50% (CE)" ? (tp + bt) / 2 : bt
                if high >= lvl
                    array.set(rMit, i, true)
                    fvgMit := true
                    closeFVG(array.get(rBox, i), array.get(rMid, i), array.get(rLab, i), bearCol, bar_index)

// ----------------------------- Multi-timeframe imbalance -----------------------------
// Latest imbalance direction on a higher timeframe (1 bull / -1 bear / 0 none).
htfFvgDir(float multMin, bool filterOn, int alen) =>
    a = ta.atr(alen)
    var int dir = 0
    bull = low > high[2] and (not filterOn or (low - high[2]) >= multMin * a)
    bear = high < low[2] and (not filterOn or (low[2] - high) >= multMin * a)
    if bull
        dir := 1
    if bear
        dir := -1
    dir

d1 = request.security(syminfo.tickerid, tf1, htfFvgDir(minMult, useMin, atrLen), lookahead = barmerge.lookahead_off)
d2 = request.security(syminfo.tickerid, tf2, htfFvgDir(minMult, useMin, atrLen), lookahead = barmerge.lookahead_off)
d3 = request.security(syminfo.tickerid, tf3, htfFvgDir(minMult, useMin, atrLen), lookahead = barmerge.lookahead_off)

tblPos = tblPosStr == "top_right" ? position.top_right : tblPosStr == "top_left" ? position.top_left : tblPosStr == "bottom_right" ? position.bottom_right : tblPosStr == "bottom_left" ? position.bottom_left : position.middle_right
var table t = table.new(tblPos, 2, 4, border_width = 1)

if showTable and barstate.islast
    table.cell(t, 0, 0, "TF",        text_color = color.white, bgcolor = color.new(color.gray, 25), text_size = size.small)
    table.cell(t, 1, 0, "Imbalance", text_color = color.white, bgcolor = color.new(color.gray, 25), text_size = size.small)
    table.cell(t, 0, 1, tf1, text_color = color.white, text_size = size.small)
    table.cell(t, 1, 1, biasTxt(d1), text_color = biasCol(d1), text_size = size.small)
    table.cell(t, 0, 2, tf2, text_color = color.white, text_size = size.small)
    table.cell(t, 1, 2, biasTxt(d2), text_color = biasCol(d2), text_size = size.small)
    table.cell(t, 0, 3, tf3, text_color = color.white, text_size = size.small)
    table.cell(t, 1, 3, biasTxt(d3), text_color = biasCol(d3), text_size = size.small)

// ----------------------------- Alerts -----------------------------
alertcondition(newBull, "New bullish FVG", "New bullish Fair Value Gap formed")
alertcondition(newBear, "New bearish FVG", "New bearish Fair Value Gap formed")
alertcondition(fvgMit,  "FVG mitigated",   "A Fair Value Gap has been mitigated (filled)")
````
