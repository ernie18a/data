<!-- tradingview-pine-id: PUB;60f77b5e3cb04c879c1ea28d85f90583 -->
<!-- tradingviewscripts-format: 1 -->
# Session Levels Pro

Source: https://www.tradingview.com/script/6jjYZ2mP-Session-Levels-Pro/

## Description

**Session Levels Pro: PDH/PDL, Asia H/L, Premarket H/L, OR, FVG, POC**

A multi-session context tool that plots the key reference levels intraday traders use to read price action, all in one indicator.

**What it plots:**

- **Previous Day High / Low** — prior session's high and low, drawn as dotted lines
- **Asia Session High / Low** — high/low of the Asia trading window (default 18:00–03:00 exchange time), useful for spotting liquidity sweeps into the London/NY session
- **Premarket High / Low** — high/low of the pre-market session (default 04:00–09:30), plus **0.5 and 0.618 Fibonacci retracements** of that range — common reaction/reversal zones
- **Opening Range (OR)** — a box marking the high/low of the first few minutes after the regular session opens (default 09:30–09:45)
- **Fair Value Gaps (FVG)** — 3-candle imbalance zones, auto-drawn as boxes and automatically removed once price trades back through (mitigates) them
- **Session POC** — an approximate volume Point of Control for the current day, calculated from a volume-by-price histogram, plotted as a dotted line at the highest-volume price

**Why it's useful:**
These are the levels many day traders watch for liquidity grabs, mean-reversion, and breakout confirmation — previous day/Asia/premarket extremes often act as support/resistance, the OR defines the day's initial balance, FVGs mark imbalance the market may return to "fill," and POC shows where the heaviest trading activity occurred.

**Customization:**
Every element (sessions, colors, fib levels, FVG mitigation, POC bin count) is togglable and adjustable in the indicator settings, grouped by feature.

**Notes:**
- Best on intraday timeframes (1m–15m).
- Default session times assume US market hours in exchange timezone — adjust Asia/Premarket/OR session strings in settings if your instrument or broker uses different hours.
- POC is an approximation (histogram built from `hlc3` and bar volume), not a true tick-level volume profile.

---

## Source Code

````pine
//@version=6
indicator("Session Levels Pro", shorttitle="Session Levels Pro", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================
grp1 = "Previous Day High / Low"
showPDHL  = input.bool(true, "Show Previous Day High/Low", group=grp1)
pdhlColor = input.color(color.new(color.red, 0), "PDH/PDL Color", group=grp1)

grp2a = "Asia Session High / Low"
showAsia   = input.bool(true, "Show Asia High/Low", group=grp2a)
asiaSession = input.session("1800-0300", "Asia Session (Exchange Time)", group=grp2a)
asiaColor   = input.color(color.new(color.orange, 0), "Asia High/Low Color", group=grp2a)

grp2 = "Premarket High / Low"
showPM   = input.bool(true, "Show Premarket High/Low", group=grp2)
pmSession = input.session("0400-0930", "Premarket Session (Exchange Time)", group=grp2)
pmColor   = input.color(color.new(color.lime, 0), "PM High/Low Color", group=grp2)
showFib   = input.bool(true, "Show Fib Retracements (0.5 / 0.618)", group=grp2)
fibColor  = input.color(color.new(color.green, 30), "Fib Color", group=grp2)

grp3 = "Opening Range (OR)"
showOR   = input.bool(true, "Show Opening Range Box", group=grp3)
orSession = input.session("0930-0945", "Opening Range Session (Exchange Time)", group=grp3)
orColor   = input.color(color.new(color.blue, 85), "OR Box Fill", group=grp3)
orBorder  = input.color(color.new(color.blue, 30), "OR Box Border", group=grp3)

grp4 = "Fair Value Gap (FVG)"
showFVG     = input.bool(true, "Show FVG Boxes", group=grp4)
fvgBullColor = input.color(color.new(color.teal, 75), "Bullish FVG Color", group=grp4)
fvgBearColor = input.color(color.new(color.red, 75), "Bearish FVG Color", group=grp4)
fvgMitigate  = input.bool(true, "Remove FVG box once price fills it", group=grp4)

grp5 = "Session POC (Point of Control)"
showPOC = input.bool(true, "Show Session POC Line", group=grp5)
pocColor = input.color(color.new(color.blue, 0), "POC Color", group=grp5)
pocRows  = input.int(24, "POC Price Bins", minval=10, maxval=100, group=grp5)

// ============================================================
// PREVIOUS DAY HIGH / LOW
// ============================================================
[pdHigh, pdLow] = request.security(syminfo.tickerid, "1D", [high[1], low[1]], lookahead=barmerge.lookahead_off)

var line  pdhLine  = na
var line  pdlLine  = na
var label pdhLabel = na
var label pdlLabel = na

if showPDHL and barstate.islast
    line.delete(pdhLine)
    line.delete(pdlLine)
    label.delete(pdhLabel)
    label.delete(pdlLabel)
    pdhLine  := line.new(bar_index - 200, pdHigh, bar_index + 25, pdHigh, color=pdhlColor, style=line.style_dotted, width=1)
    pdlLine  := line.new(bar_index - 200, pdLow,  bar_index + 25, pdLow,  color=pdhlColor, style=line.style_dotted, width=1)
    pdhLabel := label.new(bar_index + 25, pdHigh, "Previous Day High (" + str.tostring(pdHigh, format.mintick) + ")", style=label.style_label_left, color=color.new(color.black, 100), textcolor=pdhlColor, size=size.small)
    pdlLabel := label.new(bar_index + 25, pdLow,  "Previous Day Low (" + str.tostring(pdLow, format.mintick) + ")",  style=label.style_label_left, color=color.new(color.black, 100), textcolor=pdhlColor, size=size.small)

// ============================================================
// ASIA SESSION HIGH / LOW
// Note: default 1800-0300 spans midnight (exchange time), which
// TradingView's session string handles natively.
// ============================================================
inAsia = not na(time(timeframe.period, asiaSession))

var float asiaHigh = na
var float asiaLow  = na

newAsia = inAsia and not inAsia[1]
if newAsia
    asiaHigh := high
    asiaLow  := low
if inAsia
    asiaHigh := math.max(nz(asiaHigh), high)
    asiaLow  := math.min(nz(asiaLow), low)

var line  asiaHighLine  = na
var line  asiaLowLine   = na
var label asiaHighLabel = na
var label asiaLowLabel  = na

if showAsia and barstate.islast and not na(asiaHigh)
    line.delete(asiaHighLine)
    line.delete(asiaLowLine)
    label.delete(asiaHighLabel)
    label.delete(asiaLowLabel)
    asiaHighLine  := line.new(bar_index - 175, asiaHigh, bar_index + 25, asiaHigh, color=asiaColor, width=1)
    asiaLowLine   := line.new(bar_index - 175, asiaLow,  bar_index + 25, asiaLow,  color=asiaColor, width=1)
    asiaHighLabel := label.new(bar_index + 25, asiaHigh, "Asia High (" + str.tostring(asiaHigh, format.mintick) + ")", style=label.style_label_left, color=color.new(color.black, 100), textcolor=asiaColor, size=size.small)
    asiaLowLabel  := label.new(bar_index + 25, asiaLow,  "Asia Low (" + str.tostring(asiaLow, format.mintick) + ")",  style=label.style_label_left, color=color.new(color.black, 100), textcolor=asiaColor, size=size.small)

// ============================================================
// PREMARKET HIGH / LOW  (+ fib retracements)
// ============================================================
inPM = not na(time(timeframe.period, pmSession))

var float pmHigh = na
var float pmLow  = na

newPM = inPM and not inPM[1]
if newPM
    pmHigh := high
    pmLow  := low
if inPM
    pmHigh := math.max(nz(pmHigh), high)
    pmLow  := math.min(nz(pmLow), low)

var line  pmhLine    = na
var line  pmlLine    = na
var line  fib50Line  = na
var line  fib618Line = na
var label pmhLabel   = na
var label pmlLabel   = na
var label fib50Label = na
var label fib618Label = na

if showPM and barstate.islast and not na(pmHigh)
    line.delete(pmhLine)
    line.delete(pmlLine)
    label.delete(pmhLabel)
    label.delete(pmlLabel)
    pmhLine  := line.new(bar_index - 150, pmHigh, bar_index + 25, pmHigh, color=pmColor, width=1)
    pmlLine  := line.new(bar_index - 150, pmLow,  bar_index + 25, pmLow,  color=pmColor, width=1)
    pmhLabel := label.new(bar_index + 25, pmHigh, "Pre Market High (" + str.tostring(pmHigh, format.mintick) + ")", style=label.style_label_left, color=color.new(color.black, 100), textcolor=pmColor, size=size.small)
    pmlLabel := label.new(bar_index + 25, pmLow,  "Pre Market Low (" + str.tostring(pmLow, format.mintick) + ")",  style=label.style_label_left, color=color.new(color.black, 100), textcolor=pmColor, size=size.small)

    if showFib
        pmRange = pmHigh - pmLow
        fib50   = pmHigh - pmRange * 0.5
        fib618  = pmHigh - pmRange * 0.618
        line.delete(fib50Line)
        line.delete(fib618Line)
        label.delete(fib50Label)
        label.delete(fib618Label)
        fib50Line   := line.new(bar_index - 100, fib50,  bar_index + 25, fib50,  color=fibColor, width=1)
        fib618Line  := line.new(bar_index - 100, fib618, bar_index + 25, fib618, color=fibColor, width=1)
        fib50Label  := label.new(bar_index + 25, fib50,  "0.5 (" + str.tostring(fib50, format.mintick) + ")",   style=label.style_label_left, color=color.new(color.black, 100), textcolor=fibColor, size=size.small)
        fib618Label := label.new(bar_index + 25, fib618, "0.618 (" + str.tostring(fib618, format.mintick) + ")", style=label.style_label_left, color=color.new(color.black, 100), textcolor=fibColor, size=size.small)

// ============================================================
// OPENING RANGE (OR) BOX
// ============================================================
inOR = not na(time(timeframe.period, orSession))

var float orHigh     = na
var float orLow      = na
var int   orStartBar = na
var box   orBox       = na

newOR = inOR and not inOR[1]
if newOR
    orHigh     := high
    orLow      := low
    orStartBar := bar_index

if inOR
    orHigh := math.max(nz(orHigh), high)
    orLow  := math.min(nz(orLow), low)

if showOR and inOR
    box.delete(orBox)
    orBox := box.new(orStartBar, orHigh, bar_index, orLow, border_color=orBorder, bgcolor=orColor, text="OR", text_color=orBorder, text_size=size.small)

// freeze / extend the box once the OR session ends
if showOR and inOR[1] and not inOR
    box.delete(orBox)
    orBox := box.new(orStartBar, orHigh, bar_index, orLow, border_color=orBorder, bgcolor=orColor, text="OR", text_color=orBorder, text_size=size.small)

// ============================================================
// FAIR VALUE GAP (FVG) - 3 candle imbalance
// ============================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

var box[] fvgBoxes = array.new_box(0)

if showFVG and bullFVG
    newBox = box.new(bar_index[2], high[2], bar_index + 15, low, bgcolor=fvgBullColor, border_color=color.new(color.teal, 0), text="FVG", text_color=color.teal, text_size=size.tiny)
    array.push(fvgBoxes, newBox)

if showFVG and bearFVG
    newBox = box.new(bar_index[2], low[2], bar_index + 15, high, bgcolor=fvgBearColor, border_color=color.new(color.red, 0), text="FVG", text_color=color.red, text_size=size.tiny)
    array.push(fvgBoxes, newBox)

// mitigate (delete) FVG boxes once price trades back through them
if showFVG and fvgMitigate and array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0 by 1
        b = array.get(fvgBoxes, i)
        top = box.get_top(b)
        bot = box.get_bottom(b)
        if (close <= bot) or (close >= top)
            box.delete(b)
            array.remove(fvgBoxes, i)
        else
            box.set_right(b, bar_index + 15)

// ============================================================
// SESSION POC (approximate volume point of control)
// Rebuilds a volume-by-price histogram for the current day
// and plots a line at the price bin with the highest volume.
// ============================================================
var float[] sessHigh = array.new_float(0)
var float[] sessLow  = array.new_float(0)
var float[] sessVol  = array.new_float(0)
var float[] sessTyp  = array.new_float(0)

newDay = ta.change(time("D")) != 0
if newDay
    array.clear(sessHigh)
    array.clear(sessLow)
    array.clear(sessVol)
    array.clear(sessTyp)

array.push(sessHigh, high)
array.push(sessLow, low)
array.push(sessVol, volume)
array.push(sessTyp, hlc3)

var line  pocLine  = na
var label pocLabel = na

if showPOC and barstate.islast and array.size(sessTyp) > 0
    dHigh = array.max(sessHigh)
    dLow  = array.min(sessLow)
    binSize = (dHigh - dLow) / pocRows
    if binSize > 0
        volBins = array.new_float(pocRows, 0.0)
        for i = 0 to array.size(sessTyp) - 1
            typ = array.get(sessTyp, i)
            vol = array.get(sessVol, i)
            binIdx = int(math.min(math.max((typ - dLow) / binSize, 0), pocRows - 1))
            array.set(volBins, binIdx, array.get(volBins, binIdx) + vol)

        maxVol = array.max(volBins)
        maxIdx = array.indexof(volBins, maxVol)
        pocPrice = dLow + (maxIdx + 0.5) * binSize

        line.delete(pocLine)
        label.delete(pocLabel)
        pocLine  := line.new(bar_index - 150, pocPrice, bar_index + 25, pocPrice, color=pocColor, style=line.style_dotted, width=1)
        pocLabel := label.new(bar_index + 25, pocPrice, "POC (" + str.tostring(pocPrice, format.mintick) + ")", style=label.style_label_left, color=color.new(color.black, 100), textcolor=pocColor, size=size.small)
````
