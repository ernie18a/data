# SMC Toolkit 

- url: https://www.tradingview.com/script/qtgdPGnV-SMC-Toolkit/
- type: indicator
- pine_id: PUB;d38bef3804a84675906a291d4fd3ac0b
- version: 1.0

## Description

jhjujjjnjjjjjjjjjjjjjjnbuyhvgcyxctuvyiglhg.vhgckfxjdtzhfyrjcgtuhkvjblk

## Source Code

````pine
//@version=6
// =============================================================================
//  SMC TOOLKIT — SMT (MNQ/MES), FVG, IFVG, BSL, SSL, BOS
//  - Bullish elements are GREEN
//  - Bearish elements are RED
//  - Mitigated / invalidated levels automatically disappear
// =============================================================================
indicator("SMC Toolkit — SMT/FVG/IFVG/BSL/SSL/BOS", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// -------------------------- INPUTS -------------------------------------------
grpShow      = "Display"
showSMT      = input.bool(true,  "Show SMT Divergence (MNQ/MES)", group = grpShow)
showFVG      = input.bool(true,  "Show FVG",                      group = grpShow)
showIFVG     = input.bool(true,  "Show IFVG (Inverted FVG)",      group = grpShow)
showLiq      = input.bool(true,  "Show BSL / SSL",                group = grpShow)
showBOS      = input.bool(true,  "Show BOS",                      group = grpShow)

grpSMT       = "SMT Settings"
sym1         = input.symbol("CME_MINI:MNQ1!", "Symbol A (e.g. MNQ)", group = grpSMT)
sym2         = input.symbol("CME_MINI:MES1!", "Symbol B (e.g. MES)", group = grpSMT)
pivotLen     = input.int(5, "Pivot Length (SMT & BOS)", minval = 2, group = grpSMT)

grpFVG       = "FVG Settings"
fvgExtendBars= input.int(200, "Max Extend Bars (FVG)", minval = 10, group = grpFVG)

grpLiq       = "Liquidity Settings"
liqLookback  = input.int(15, "Pivot Length (Liquidity)", minval = 2, group = grpLiq)
liqExtend    = input.int(200, "Max Extend Bars (Liquidity)", minval = 10, group = grpLiq)

// -------------------------- COLORS -------------------------------------------
colBull      = color.new(color.green, 0)
colBear      = color.new(color.red,   0)
colBullFill  = color.new(color.green, 80)
colBearFill  = color.new(color.red,   80)
colBSL       = color.new(color.green, 0)
colSSL       = color.new(color.red,   0)

// =============================================================================
//  SMT DIVERGENCE — compares pivots of Symbol A (MNQ) vs Symbol B (MES)
// =============================================================================
a_high = request.security(sym1, timeframe.period, high, lookahead = barmerge.lookahead_off)
a_low  = request.security(sym1, timeframe.period, low,  lookahead = barmerge.lookahead_off)
b_high = request.security(sym2, timeframe.period, high, lookahead = barmerge.lookahead_off)
b_low  = request.security(sym2, timeframe.period, low,  lookahead = barmerge.lookahead_off)

phA = ta.pivothigh(a_high, pivotLen, pivotLen)
plA = ta.pivotlow (a_low,  pivotLen, pivotLen)
phB = ta.pivothigh(b_high, pivotLen, pivotLen)
plB = ta.pivotlow (b_low,  pivotLen, pivotLen)

var float lastPhA = na, var float lastPhB = na, var int lastPhBar = na
var float lastPlA = na, var float lastPlB = na, var int lastPlBar = na

if not na(phA) and not na(phB)
    if not na(lastPhA) and not na(lastPhB) and showSMT
        if (phA > lastPhA and phB < lastPhB) or (phA < lastPhA and phB > lastPhB)
            line.new(lastPhBar, lastPhA, bar_index - pivotLen, phA, color = colBear, width = 2, style = line.style_dashed)
            label.new(bar_index - pivotLen, phA, "SMT-", color = colBear, textcolor = color.white, style = label.style_label_down, size = size.tiny)
    lastPhA := phA
    lastPhB := phB
    lastPhBar := bar_index - pivotLen

if not na(plA) and not na(plB)
    if not na(lastPlA) and not na(lastPlB) and showSMT
        if (plA < lastPlA and plB > lastPlB) or (plA > lastPlA and plB < lastPlB)
            line.new(lastPlBar, lastPlA, bar_index - pivotLen, plA, color = colBull, width = 2, style = line.style_dashed)
            label.new(bar_index - pivotLen, plA, "SMT+", color = colBull, textcolor = color.white, style = label.style_label_up, size = size.tiny)
    lastPlA := plA
    lastPlB := plB
    lastPlBar := bar_index - pivotLen

// =============================================================================
//  FVG & IFVG — 3-bar imbalance; auto-remove on mitigation
// =============================================================================
type FVG
    box   bx
    float top
    float bot
    bool  bull
    bool  inverted

var array<FVG> fvgs = array.new<FVG>()

bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    topF = low
    botF = high[2]
    b = box.new(bar_index - 2, topF, bar_index, botF, border_color = colBull, bgcolor = colBullFill, extend = extend.right)
    array.push(fvgs, FVG.new(b, topF, botF, true, false))

if showFVG and bearFVG
    topF = low[2]
    botF = high
    b = box.new(bar_index - 2, topF, bar_index, botF, border_color = colBear, bgcolor = colBearFill, extend = extend.right)
    array.push(fvgs, FVG.new(b, topF, botF, false, false))

if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0
        f = array.get(fvgs, i)
        if bar_index - box.get_left(f.bx) > fvgExtendBars
            box.delete(f.bx)
            array.remove(fvgs, i)
            continue
        mitigated = f.bull ? (low <= f.bot) : (high >= f.top)
        if mitigated
            if not f.inverted and showIFVG
                f.inverted := true
                f.bull     := not f.bull
                box.set_border_color(f.bx, f.bull ? colBull : colBear)
                box.set_bgcolor(f.bx,     f.bull ? colBullFill : colBearFill)
            else
                box.delete(f.bx)
                array.remove(fvgs, i)
                continue
        if f.inverted
            invalidated = f.bull ? (close < f.bot) : (close > f.top)
            if invalidated
                box.delete(f.bx)
                array.remove(fvgs, i)

// =============================================================================
//  BSL / SSL — liquidity above/below; removed on sweep
// =============================================================================
type Liq
    line ln
    float px
    bool  buyside

var array<Liq> liqs = array.new<Liq>()

pvH = ta.pivothigh(high, liqLookback, liqLookback)
pvL = ta.pivotlow (low,  liqLookback, liqLookback)

if showLiq and not na(pvH)
    ln = line.new(bar_index - liqLookback, pvH, bar_index, pvH, color = colBSL, width = 1, style = line.style_dotted, extend = extend.right)
    array.push(liqs, Liq.new(ln, pvH, true))

if showLiq and not na(pvL)
    ln = line.new(bar_index - liqLookback, pvL, bar_index, pvL, color = colSSL, width = 1, style = line.style_dotted, extend = extend.right)
    array.push(liqs, Liq.new(ln, pvL, false))

if array.size(liqs) > 0
    for i = array.size(liqs) - 1 to 0
        l = array.get(liqs, i)
        if bar_index - line.get_x1(l.ln) > liqExtend
            line.delete(l.ln)
            array.remove(liqs, i)
            continue
        swept = l.buyside ? (high >= l.px) : (low <= l.px)
        if swept
            label.new(bar_index, l.px, l.buyside ? "BSL✔" : "SSL✔", color = l.buyside ? colBull : colBear, textcolor = color.white, style = l.buyside ? label.style_label_down : label.style_label_up, size = size.tiny)
            line.delete(l.ln)
            array.remove(liqs, i)

// =============================================================================
//  BOS — Break of Structure
// =============================================================================
var float lastSwingHigh   = na
var float lastSwingLow    = na
var int   lastSwingHighBar= na
var int   lastSwingLowBar = na
var int   marketBias      = 0

swingHigh = ta.pivothigh(high, pivotLen, pivotLen)
swingLow  = ta.pivotlow (low,  pivotLen, pivotLen)

if not na(swingHigh)
    lastSwingHigh    := swingHigh
    lastSwingHighBar := bar_index - pivotLen
if not na(swingLow)
    lastSwingLow     := swingLow
    lastSwingLowBar  := bar_index - pivotLen

if showBOS and not na(lastSwingHigh) and close > lastSwingHigh and marketBias != 1
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color = colBull, width = 2)
    label.new(bar_index, lastSwingHigh, "BOS", color = colBull, textcolor = color.white, style = label.style_label_down, size = size.small)
    marketBias := 1

if showBOS and not na(lastSwingLow) and close < lastSwingLow and marketBias != -1
    line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, color = colBear, width = 2)
    label.new(bar_index, lastSwingLow, "BOS", color = colBear, textcolor = color.white, style = label.style_label_up, size = size.small)
    marketBias := -1

// =============================================================================
//  ALERTS
// =============================================================================
alertcondition(bullFVG,  "Bullish FVG",  "Bullish FVG formed")
alertcondition(bearFVG,  "Bearish FVG",  "Bearish FVG formed")
````
