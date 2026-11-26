# Liquidity Sweeps EQH EQL TGFX

- url: https://www.tradingview.com/script/mlHahyQG-Liquidity-Sweeps-EQH-EQL-TGFX/
- type: indicator
- pine_id: PUB;834611c9ed9f418aa3329d601ba0e343
- version: 1.0

## Description

Liquidity Sweeps — EQH / EQL

OVERVIEW
Liquidity Sweeps — EQH / EQL is a price-action tool that highlights resting liquidity on the chart and shows when that liquidity is taken. It automatically detects clusters of equal swing highs (EQH) and equal swing lows (EQL), draws them as liquidity levels, and flags the moment price runs through a level and closes back on the other side — a liquidity sweep (also called a stop run or liquidity grab).

THE IDEA BEHIND IT
Stop orders tend to build up just beyond obvious swing highs and lows. When several swings form at roughly the same price, they create a visible pool of resting orders:
- Equal highs (EQH) sit above price and represent buy-side liquidity (buy stops / breakout buy orders).
- Equal lows (EQL) sit below price and represent sell-side liquidity (sell stops / breakout sell orders).
Price is often drawn toward these pools. A sweep occurs when price spikes through the level to trigger those orders and then closes back inside the range — frequently a sign that the move beyond the level lacked follow-through.

HOW IT WORKS
1. Swings are detected with confirmed Williams pivots (configurable left/right length).
2. When two consecutive pivot highs (or lows) form within an adaptive, ATR-based tolerance, they are treated as "equal" and a liquidity level is drawn at the extreme. The tolerance can also be set as a fixed tick distance.
3. Each level extends to the right until price reaches it.
4. A sweep is confirmed on bar close:
   - Bearish sweep: a bar's high trades above an EQH but the bar closes back below it (buy-side liquidity taken).
   - Bullish sweep: a bar's low trades below an EQL but the bar closes back above it (sell-side liquidity taken).
   The swept level is then dimmed and stops extending, and a "SWEEP" label is placed.

HOW TO READ IT
- Red levels / "EQH" labels = buy-side liquidity resting above price.
- Green levels / "EQL" labels = sell-side liquidity resting below price.
- Solid line = level still intact (liquidity untouched).
- Dotted/dimmed line = level already swept.
- Red "SWEEP" above a candle = buy-side liquidity taken and rejected.
- Green "SWEEP" below a candle = sell-side liquidity taken and reclaimed.
- Multi-timeframe table: shows the most recent sweep direction on three higher timeframes (Bull / Bear / –) for higher-timeframe context at a glance. On each higher timeframe a sweep is measured as breaking the N-bar high/low and closing back inside.

SETTINGS
- Swing detection: pivot left/right bars control how large a swing must be before it counts. Lower = more, smaller swings (more sensitive); higher = fewer, more significant ones.
- Equal levels: tolerance mode (ATR or ticks), ATR length and multiplier, and a tick tolerance. A larger tolerance treats more pivots as "equal".
- Sweeps: show/hide sweep labels, and whether swept levels stay on the chart (dimmed) or are removed.
- Visual: colors for buy-side/sell-side, line width, label size, show/hide level labels.
- Multi-timeframe table: enable/disable, the three timeframes, the higher-timeframe sweep lookback, and the table position.

REPAINTING
Levels are built only from pivots that are already confirmed, so a level never appears and then disappears once drawn (by definition, a pivot is confirmed a number of bars after it forms, equal to the "right bars" setting). Sweeps are evaluated on bar close, so sweep labels and alerts do not change intrabar.

ALERTS
Two alerts are available: "Bullish liquidity sweep" and "Bearish liquidity sweep". Add them from the alert dialog and set them to trigger once per bar close.

NOTES
This script is an original implementation of standard, public price-action concepts (Williams pivots, equal highs/lows, liquidity sweeps). It is a visualization and context tool — it does not generate buy/sell signals and makes no claim about future performance. Sweeps are best combined with your own analysis (market structure, higher-timeframe context, risk management) rather than used in isolation.

## Source Code

````pine
//@version=6
// =============================================================
//  LIQUIDITY SWEEPS — Equal Highs / Equal Lows (EQH / EQL)
//  Author: TradingconGaboFX (TGFX)
//
//  WHAT IT DOES
//  ------------
//  • Detects clusters of equal swing highs (EQH = buy-side liquidity)
//    and equal swing lows (EQL = sell-side liquidity) within an
//    adaptive, ATR-based tolerance.
//  • Draws each liquidity level and extends it to the right until
//    price reaches it.
//  • Flags a LIQUIDITY SWEEP when price wicks through a level and
//    closes back on the other side (a stop-run / liquidity grab):
//        - Bearish sweep:  high > EQH  and  close < EQH   (buy-side taken)
//        - Bullish sweep:  low  < EQL  and  close > EQL   (sell-side taken)
//    The swept level is then dimmed and stops extending.
//  • Multi-timeframe table summarising the latest sweep direction on
//    up to three higher timeframes.
//  • Alerts for bullish and bearish liquidity sweeps.
//
//  NOTES
//  -----
//  • Levels are built from confirmed Williams pivots, so a level only
//    appears after its pivot is confirmed and does not repaint once drawn.
//  • Sweeps are evaluated on bar close (no intrabar repaint).
//  • Pivots, equal highs/lows and liquidity sweeps are standard public
//    price-action concepts; this is an original implementation.
// =============================================================

indicator("Liquidity Sweeps — EQH / EQL [TGFX]", shorttitle="Liq Sweeps [TGFX]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ----------------------------- Inputs -----------------------------
gP = "── Swing detection ──"
leftBars  = input.int(8, "Pivot left bars",  minval = 1, group = gP)
rightBars = input.int(8, "Pivot right bars", minval = 1, group = gP)

gE = "── Equal levels (liquidity) ──"
tolMode   = input.string("ATR", "Tolerance mode", options = ["ATR", "Ticks"], group = gE)
atrLen    = input.int(14, "ATR length", minval = 1, group = gE)
atrMult   = input.float(0.10, "ATR tolerance ×", minval = 0.0, step = 0.05, group = gE, tooltip = "Two pivots are 'equal' if within this × ATR.")
tickTol   = input.int(20, "Tick tolerance", minval = 0, group = gE, tooltip = "Used when Tolerance mode = Ticks.")
maxLevels = input.int(8, "Max levels per side", minval = 1, maxval = 60, group = gE)

gS = "── Sweeps ──"
showSwLbl = input.bool(true, "Show sweep labels", group = gS)
swText    = input.string("SWEEP", "Sweep label text", group = gS)
keepSwept = input.bool(true, "Keep swept levels (dimmed)", group = gS, tooltip = "If off, swept levels are deleted.")

gV = "── Visual ──"
buyCol     = input.color(#f23645, "EQH / buy-side", group = gV)
sellCol    = input.color(#089981, "EQL / sell-side", group = gV)
lblSizeStr = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = gV)
lineWid    = input.int(1, "Line width", minval = 1, maxval = 4, group = gV)
showLvlLbl = input.bool(true, "Show EQH/EQL labels", group = gV)

gT = "── Multi-timeframe table ──"
showTable = input.bool(true, "Show MTF table", group = gT)
swpLen    = input.int(20, "HTF sweep lookback (bars)", minval = 2, group = gT, tooltip = "On each HTF, a sweep = breaking the N-bar high/low and closing back inside.")
tf1       = input.timeframe("60",  "Timeframe 1", group = gT)
tf2       = input.timeframe("240", "Timeframe 2", group = gT)
tf3       = input.timeframe("D",   "Timeframe 3", group = gT)
tblPosStr = input.string("top_right", "Table position", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"], group = gT)

// ----------------------------- Helpers -----------------------------
atr     = ta.atr(atrLen)
tol     = tolMode == "ATR" ? atrMult * atr : tickTol * syminfo.mintick
labSize = lblSizeStr == "tiny" ? size.tiny : lblSizeStr == "small" ? size.small : size.normal

biasTxt(int d) => d ==  1 ? "Bull" : d == -1 ? "Bear" : "–"
biasCol(int d) => d ==  1 ? sellCol : d == -1 ? buyCol : color.gray

// ----------------------------- State -----------------------------
var float prevPH    = na
var int   prevPHbar = na
var float prevPL    = na
var int   prevPLbar = na

var array<float> hLvl   = array.new<float>()
var array<line>  hLine  = array.new<line>()
var array<label> hLab   = array.new<label>()
var array<bool>  hSwept = array.new<bool>()

var array<float> lLvl   = array.new<float>()
var array<line>  lLine  = array.new<line>()
var array<label> lLab   = array.new<label>()
var array<bool>  lSwept = array.new<bool>()

// Add a new liquidity level. isHigh = true -> EQH (buy-side), false -> EQL (sell-side)
addLevel(bool isHigh, float price, int startBar) =>
    col = isHigh ? buyCol : sellCol
    ln  = line.new(startBar, price, bar_index, price, xloc = xloc.bar_index, extend = extend.right, color = col, width = lineWid)
    lb  = showLvlLbl ? label.new(startBar, price, isHigh ? "EQH" : "EQL", xloc = xloc.bar_index, style = isHigh ? label.style_label_down : label.style_label_up, color = color.new(col, 80), textcolor = col, size = labSize) : na
    if isHigh
        array.push(hLvl, price)
        array.push(hLine, ln)
        array.push(hLab, lb)
        array.push(hSwept, false)
        if array.size(hLvl) > maxLevels
            line.delete(array.shift(hLine))
            lbOld = array.shift(hLab)
            if not na(lbOld)
                label.delete(lbOld)
            array.shift(hLvl)
            array.shift(hSwept)
    else
        array.push(lLvl, price)
        array.push(lLine, ln)
        array.push(lLab, lb)
        array.push(lSwept, false)
        if array.size(lLvl) > maxLevels
            line.delete(array.shift(lLine))
            lbOld = array.shift(lLab)
            if not na(lbOld)
                label.delete(lbOld)
            array.shift(lLvl)
            array.shift(lSwept)

// ----------------------------- Pivots & equal levels -----------------------------
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low,  leftBars, rightBars)

if not na(ph)
    phBar = bar_index - rightBars
    if not na(prevPH) and math.abs(ph - prevPH) <= tol
        addLevel(true, math.max(ph, prevPH), prevPHbar)   // equal highs -> buy-side liquidity
    prevPH    := ph
    prevPHbar := phBar

if not na(pl)
    plBar = bar_index - rightBars
    if not na(prevPL) and math.abs(pl - prevPL) <= tol
        addLevel(false, math.min(pl, prevPL), prevPLbar)  // equal lows -> sell-side liquidity
    prevPL    := pl
    prevPLbar := plBar

// ----------------------------- Sweep detection (on bar close) -----------------------------
bearSweepSig = false
bullSweepSig = false

if barstate.isconfirmed
    // buy-side liquidity (EQH) taken -> bearish sweep
    if array.size(hLvl) > 0
        for i = 0 to array.size(hLvl) - 1
            if not array.get(hSwept, i)
                lv = array.get(hLvl, i)
                if high > lv and close < lv
                    array.set(hSwept, i, true)
                    bearSweepSig := true
                    ln = array.get(hLine, i)
                    if keepSwept
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        line.set_style(ln, line.style_dotted)
                        line.set_color(ln, color.new(buyCol, 55))
                    else
                        line.delete(ln)
                        lb = array.get(hLab, i)
                        if not na(lb)
                            label.delete(lb)
                    if showSwLbl
                        label.new(bar_index, high, swText, xloc = xloc.bar_index, style = label.style_label_down, color = buyCol, textcolor = color.white, size = labSize)
    // sell-side liquidity (EQL) taken -> bullish sweep
    if array.size(lLvl) > 0
        for i = 0 to array.size(lLvl) - 1
            if not array.get(lSwept, i)
                lv = array.get(lLvl, i)
                if low < lv and close > lv
                    array.set(lSwept, i, true)
                    bullSweepSig := true
                    ln = array.get(lLine, i)
                    if keepSwept
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        line.set_style(ln, line.style_dotted)
                        line.set_color(ln, color.new(sellCol, 55))
                    else
                        line.delete(ln)
                        lb = array.get(lLab, i)
                        if not na(lb)
                            label.delete(lb)
                    if showSwLbl
                        label.new(bar_index, low, swText, xloc = xloc.bar_index, style = label.style_label_up, color = sellCol, textcolor = color.white, size = labSize)

// ----------------------------- Multi-timeframe liquidity bias -----------------------------
// On each HTF: bull = breaks N-bar low and closes back above; bear = breaks N-bar high and closes back below.
htfBias(int len) =>
    hh = ta.highest(high, len)[1]
    ll = ta.lowest(low,  len)[1]
    var int dir = 0
    if low < ll and close > ll
        dir := 1
    if high > hh and close < hh
        dir := -1
    dir

b1 = request.security(syminfo.tickerid, tf1, htfBias(swpLen), lookahead = barmerge.lookahead_off)
b2 = request.security(syminfo.tickerid, tf2, htfBias(swpLen), lookahead = barmerge.lookahead_off)
b3 = request.security(syminfo.tickerid, tf3, htfBias(swpLen), lookahead = barmerge.lookahead_off)

tblPos = tblPosStr == "top_right" ? position.top_right : tblPosStr == "top_left" ? position.top_left : tblPosStr == "bottom_right" ? position.bottom_right : tblPosStr == "bottom_left" ? position.bottom_left : position.middle_right
var table t = table.new(tblPos, 2, 4, border_width = 1)

if showTable and barstate.islast
    table.cell(t, 0, 0, "TF",        text_color = color.white, bgcolor = color.new(color.gray, 25), text_size = size.small)
    table.cell(t, 1, 0, "Liquidity", text_color = color.white, bgcolor = color.new(color.gray, 25), text_size = size.small)
    table.cell(t, 0, 1, tf1, text_color = color.white, text_size = size.small)
    table.cell(t, 1, 1, biasTxt(b1), text_color = biasCol(b1), text_size = size.small)
    table.cell(t, 0, 2, tf2, text_color = color.white, text_size = size.small)
    table.cell(t, 1, 2, biasTxt(b2), text_color = biasCol(b2), text_size = size.small)
    table.cell(t, 0, 3, tf3, text_color = color.white, text_size = size.small)
    table.cell(t, 1, 3, biasTxt(b3), text_color = biasCol(b3), text_size = size.small)

// ----------------------------- Alerts -----------------------------
alertcondition(bullSweepSig, "Bullish liquidity sweep", "Bullish liquidity sweep — sell-side liquidity taken (EQL swept and reclaimed)")
alertcondition(bearSweepSig, "Bearish liquidity sweep", "Bearish liquidity sweep — buy-side liquidity taken (EQH swept and rejected)")
````
