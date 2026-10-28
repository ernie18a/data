# Sovereign A+ Setup Indicator BB Breach 30 min

- url: https://www.tradingview.com/script/JjKtYxN1-Sovereign-A-Setup-Indicator-BB-Breach-30-min/
- type: indicator
- pine_id: PUB;46aed565ff474546a3888e4c078ce102
- version: 1.0

## Description

Indicator and alerts for the 30 min BB Breach Strategy

## Source Code

````pine
//@version=6
indicator("Sovereign A+ Setup Indicator", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════════
// SOVEREIGN A+ SETUP INDICATOR v1.1
// ───────────────────────────────────────────────────────────────────
// Identifies high-probability A+ setups based on:
//   1. Multi-timeframe trend alignment (30m, 1H, 4H, 1D)
//   2. EMA stack on 30m (13 > 62 > 200 for longs, inverse for shorts)
//   3. Bollinger Band breach (wick beyond the band)
//   4. Bullish/bearish impulse with Break of Structure (BOS)
//   5. Auto-drawn Fib retracement with 0.5 prep alert and 0.71 entry zone
//
// Fires a SINGLE prep alert when price taps the 0.5 retracement.
// User decides on entry, target and stop based on their own judgement.
// ═══════════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────────
// INPUTS
// ───────────────────────────────────────────────────────────────────
grpEma  = "EMA Settings"
fastLen = input.int(13,  "Fast EMA",   group=grpEma)
medLen  = input.int(62,  "Medium EMA", group=grpEma)
slowLen = input.int(200, "Slow EMA",   group=grpEma)

grpBB    = "Bollinger Band Settings"
bbLen    = input.int(20,    "BB Length",   group=grpBB)
bbStdDev = input.float(2.0, "BB Std Dev",  step=0.1, group=grpBB)

grpStruct = "Structure Settings"
pivotN    = input.int(2, "Swing Pivot Sensitivity (bars either side)", minval=1, maxval=5, group=grpStruct, tooltip="Lower = more swings detected (more setups). Higher = stricter swings (fewer, cleaner setups). N=2 is recommended for 30m.")

grpFib       = "Fib & Entry Zone"
prepLevel    = input.float(0.5,  "Prep Alert Level (Fib)", step=0.01, group=grpFib)
entryLevel   = input.float(0.71, "Entry Zone Level (Fib)", step=0.01, group=grpFib)
bufferPips   = input.float(3.0,  "Entry Zone Buffer (pips, majors)", step=0.5, group=grpFib, tooltip="Buffer applied either side of the 0.71 level. JPY pairs and crosses auto-adjust to 5 pips by default.")
jpyBuffer    = input.float(5.0,  "Entry Zone Buffer (pips, JPY/Cross)", step=0.5, group=grpFib)

grpVis     = "Visuals"
showFib    = input.bool(true,  "Show Fib levels", group=grpVis)
showZone   = input.bool(true,  "Show 0.71 entry zone box", group=grpVis)
showEmas   = input.bool(true,  "Show EMAs", group=grpVis)
showBB     = input.bool(true,  "Show Bollinger Bands", group=grpVis)
showLabels = input.bool(true,  "Show setup status labels", group=grpVis)
showBOS    = input.bool(true,  "Show BOS markers", group=grpVis, tooltip="Marks Break of Structure with a label and horizontal line at the broken swing level. Useful for learning what BOS looks like.")
bosLifespan = input.int(50, "BOS marker lifespan (bars)", minval=10, maxval=500, group=grpVis, tooltip="How many bars the BOS label/line stays on chart before being removed.")

// ───────────────────────────────────────────────────────────────────
// PIP DETECTION (auto-adjust buffer for JPY pairs)
// ───────────────────────────────────────────────────────────────────
isJpy   = str.contains(syminfo.ticker, "JPY")
pipSize = isJpy ? 0.01 : syminfo.mintick * 10
buffer  = (isJpy ? jpyBuffer : bufferPips) * pipSize

// ───────────────────────────────────────────────────────────────────
// EMAs (30m)
// ───────────────────────────────────────────────────────────────────
emaFast = ta.ema(close, fastLen)
emaMed  = ta.ema(close, medLen)
emaSlow = ta.ema(close, slowLen)

plot(showEmas ? emaFast : na, "Fast EMA",   color=color.red,   linewidth=2)
plot(showEmas ? emaMed  : na, "Medium EMA", color=color.blue,  linewidth=2)
plot(showEmas ? emaSlow : na, "Slow EMA",   color=color.black, linewidth=2)

emaStackBull = emaFast > emaMed and emaMed > emaSlow
emaStackBear = emaFast < emaMed and emaMed < emaSlow

// ───────────────────────────────────────────────────────────────────
// BOLLINGER BANDS
// ───────────────────────────────────────────────────────────────────
bbBasis = ta.sma(close, bbLen)
bbDev   = bbStdDev * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

pUp  = plot(showBB ? bbUpper : na, "BB Upper", color=color.gray)
pMid = plot(showBB ? bbBasis : na, "BB Basis", color=color.new(color.gray, 50))
pLow = plot(showBB ? bbLower : na, "BB Lower", color=color.gray)
fill(pUp, pLow, color=showBB ? color.new(color.gray, 92) : na)

// ───────────────────────────────────────────────────────────────────
// MULTI-TIMEFRAME TREND ALIGNMENT
// 50/200 SMA cross on each TF as the trend definition.
// ───────────────────────────────────────────────────────────────────
trendOnTf(tf) =>
    s = request.security(syminfo.tickerid, tf, ta.sma(close, 50),  lookahead=barmerge.lookahead_off)
    l = request.security(syminfo.tickerid, tf, ta.sma(close, 200), lookahead=barmerge.lookahead_off)
    s > l ? 1 : s < l ? -1 : 0

t30  = trendOnTf("30")
t60  = trendOnTf("60")
t240 = trendOnTf("240")
t1D  = trendOnTf("1D")

allBull = t30 == 1  and t60 == 1  and t240 == 1  and t1D == 1
allBear = t30 == -1 and t60 == -1 and t240 == -1 and t1D == -1

// ───────────────────────────────────────────────────────────────────
// CONTEXT FILTER
// ───────────────────────────────────────────────────────────────────
contextBull = allBull and emaStackBull and close > emaFast
contextBear = allBear and emaStackBear and close < emaFast

// ───────────────────────────────────────────────────────────────────
// SWING HIGH/LOW DETECTION (fractal-based)
// ───────────────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotN, pivotN)
pl = ta.pivotlow(low,  pivotN, pivotN)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(ph)
    lastSwingHigh := ph

if not na(pl)
    lastSwingLow := pl

// ───────────────────────────────────────────────────────────────────
// SETUP STATE MACHINE
// State 0 = idle, State 1 = BB breach detected, State 2 = BOS confirmed (armed)
// ───────────────────────────────────────────────────────────────────
var int   bullState       = 0
var float bullBreachLow   = na
var float bullBosTarget   = na
var float bullImpulseHigh = na
var int   bullSetupBar    = na
var int   bullBreachBar   = na
var bool  bullPrepFired   = false

var int   bearState       = 0
var float bearBreachHigh  = na
var float bearBosTarget   = na
var float bearImpulseLow  = na
var int   bearSetupBar    = na
var int   bearBreachBar   = na
var bool  bearPrepFired   = false

// BOS marker tracking arrays
var array<line>  bosLines       = array.new<line>()
var array<label> bosLabels      = array.new<label>()
var array<int>   bosCreatedBars = array.new<int>()

// Active setup drawings
var line   bullFib0Line   = na
var line   bullFib05Line  = na
var line   bullFib071Line = na
var line   bullFib1Line   = na
var box    bullEntryBox   = na
var label  bullStatusLbl  = na

var line   bearFib0Line   = na
var line   bearFib05Line  = na
var line   bearFib071Line = na
var line   bearFib1Line   = na
var box    bearEntryBox   = na
var label  bearStatusLbl  = na

clearBullDrawings() =>
    if not na(bullFib0Line)
        line.delete(bullFib0Line)
    if not na(bullFib05Line)
        line.delete(bullFib05Line)
    if not na(bullFib071Line)
        line.delete(bullFib071Line)
    if not na(bullFib1Line)
        line.delete(bullFib1Line)
    if not na(bullEntryBox)
        box.delete(bullEntryBox)
    if not na(bullStatusLbl)
        label.delete(bullStatusLbl)

clearBearDrawings() =>
    if not na(bearFib0Line)
        line.delete(bearFib0Line)
    if not na(bearFib05Line)
        line.delete(bearFib05Line)
    if not na(bearFib071Line)
        line.delete(bearFib071Line)
    if not na(bearFib1Line)
        line.delete(bearFib1Line)
    if not na(bearEntryBox)
        box.delete(bearEntryBox)
    if not na(bearStatusLbl)
        label.delete(bearStatusLbl)

// ───────────────────────────────────────────────────────────────────
// BULL SETUP LOGIC
// ───────────────────────────────────────────────────────────────────
bullBreach = contextBull and low < bbLower

if bullState == 0 and bullBreach
    bullState     := 1
    bullBreachLow := low
    bullBosTarget := lastSwingHigh
    bullBreachBar := bar_index
    bullPrepFired := false

if bullState == 1
    if low < bullBreachLow
        bullBreachLow := low
        bullBreachBar := bar_index
    if not na(bullBosTarget) and close > bullBosTarget
        bullState       := 2
        bullImpulseHigh := high
        bullSetupBar    := bar_index
        // Draw BOS marker (label + dotted line at broken level)
        if showBOS
            bosLine = line.new(bar_index - 20, bullBosTarget, bar_index, bullBosTarget, color=color.new(color.green, 0), width=1, style=line.style_dotted)
            bosLbl  = label.new(bar_index, bullBosTarget, "BOS", style=label.style_label_left, color=color.new(color.green, 20), textcolor=color.white, size=size.small)
            array.push(bosLines, bosLine)
            array.push(bosLabels, bosLbl)
            array.push(bosCreatedBars, bar_index)

bullPrepHit = false
if bullState == 2
    if high > bullImpulseHigh
        bullImpulseHigh := high
    fibLow  = bullBreachLow
    fibHigh = bullImpulseHigh
    fibRange = fibHigh - fibLow
    lvl0   = fibHigh
    lvl05  = fibHigh - fibRange * prepLevel
    lvl071 = fibHigh - fibRange * entryLevel
    lvl1   = fibLow
    // Redraw with PROMINENT styling
    clearBullDrawings()
    if showFib
        bullFib0Line   := line.new(bullBreachBar, lvl0,   bar_index + 50, lvl0,   color=color.new(color.gray,    0), width=2, extend=extend.right, style=line.style_dotted)
        bullFib05Line  := line.new(bullBreachBar, lvl05,  bar_index + 50, lvl05,  color=color.new(color.orange,  0), width=2, extend=extend.right, style=line.style_dashed)
        bullFib071Line := line.new(bullBreachBar, lvl071, bar_index + 50, lvl071, color=color.new(color.green,   0), width=3, extend=extend.right)
        bullFib1Line   := line.new(bullBreachBar, lvl1,   bar_index + 50, lvl1,   color=color.new(color.gray,    0), width=2, extend=extend.right, style=line.style_dotted)
    if showZone
        bullEntryBox := box.new(bullBreachBar, lvl071 + buffer, bar_index + 50, lvl071 - buffer, border_color=color.new(color.green, 0), bgcolor=color.new(color.green, 70), extend=extend.right)
    if showLabels
        bullStatusLbl := label.new(bar_index, lvl05, "BULL A+ ARMED", style=label.style_label_down, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
    if not bullPrepFired and low <= lvl05
        bullPrepFired := true
        bullPrepHit   := true
    if low <= lvl071 + buffer
        bullState := 0
        clearBullDrawings()
    if not emaStackBull
        bullState := 0
        clearBullDrawings()
    if not allBull
        bullState := 0
        clearBullDrawings()
    if close < fibLow
        bullState := 0
        clearBullDrawings()

// ───────────────────────────────────────────────────────────────────
// BEAR SETUP LOGIC
// ───────────────────────────────────────────────────────────────────
bearBreach = contextBear and high > bbUpper

if bearState == 0 and bearBreach
    bearState      := 1
    bearBreachHigh := high
    bearBosTarget  := lastSwingLow
    bearBreachBar  := bar_index
    bearPrepFired  := false

if bearState == 1
    if high > bearBreachHigh
        bearBreachHigh := high
        bearBreachBar  := bar_index
    if not na(bearBosTarget) and close < bearBosTarget
        bearState      := 2
        bearImpulseLow := low
        bearSetupBar   := bar_index
        if showBOS
            bosLine = line.new(bar_index - 20, bearBosTarget, bar_index, bearBosTarget, color=color.new(color.red, 0), width=1, style=line.style_dotted)
            bosLbl  = label.new(bar_index, bearBosTarget, "BOS", style=label.style_label_left, color=color.new(color.red, 20), textcolor=color.white, size=size.small)
            array.push(bosLines, bosLine)
            array.push(bosLabels, bosLbl)
            array.push(bosCreatedBars, bar_index)

bearPrepHit = false
if bearState == 2
    if low < bearImpulseLow
        bearImpulseLow := low
    fibHigh = bearBreachHigh
    fibLow  = bearImpulseLow
    fibRange = fibHigh - fibLow
    lvl0   = fibLow
    lvl05  = fibLow + fibRange * prepLevel
    lvl071 = fibLow + fibRange * entryLevel
    lvl1   = fibHigh
    clearBearDrawings()
    if showFib
        bearFib0Line   := line.new(bearBreachBar, lvl0,   bar_index + 50, lvl0,   color=color.new(color.gray,   0), width=2, extend=extend.right, style=line.style_dotted)
        bearFib05Line  := line.new(bearBreachBar, lvl05,  bar_index + 50, lvl05,  color=color.new(color.orange, 0), width=2, extend=extend.right, style=line.style_dashed)
        bearFib071Line := line.new(bearBreachBar, lvl071, bar_index + 50, lvl071, color=color.new(color.red,    0), width=3, extend=extend.right)
        bearFib1Line   := line.new(bearBreachBar, lvl1,   bar_index + 50, lvl1,   color=color.new(color.gray,   0), width=2, extend=extend.right, style=line.style_dotted)
    if showZone
        bearEntryBox := box.new(bearBreachBar, lvl071 + buffer, bar_index + 50, lvl071 - buffer, border_color=color.new(color.red, 0), bgcolor=color.new(color.red, 70), extend=extend.right)
    if showLabels
        bearStatusLbl := label.new(bar_index, lvl05, "BEAR A+ ARMED", style=label.style_label_up, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
    if not bearPrepFired and high >= lvl05
        bearPrepFired := true
        bearPrepHit   := true
    if high >= lvl071 - buffer
        bearState := 0
        clearBearDrawings()
    if not emaStackBear
        bearState := 0
        clearBearDrawings()
    if not allBear
        bearState := 0
        clearBearDrawings()
    if close > fibHigh
        bearState := 0
        clearBearDrawings()

// ───────────────────────────────────────────────────────────────────
// VISUAL MARKERS — breach dot at actual breach candle
// ───────────────────────────────────────────────────────────────────
var label bullBreachLabel = na
var label bearBreachLabel = na

if bullState == 2 and bullSetupBar == bar_index
    if not na(bullBreachLabel)
        label.delete(bullBreachLabel)
    bullBreachLabel := label.new(bullBreachBar, low[bar_index - bullBreachBar], "•", yloc=yloc.belowbar, style=label.style_circle, color=color.new(color.green, 30), size=size.tiny)

if bearState == 2 and bearSetupBar == bar_index
    if not na(bearBreachLabel)
        label.delete(bearBreachLabel)
    bearBreachLabel := label.new(bearBreachBar, high[bar_index - bearBreachBar], "•", yloc=yloc.abovebar, style=label.style_circle, color=color.new(color.red, 30), size=size.tiny)

if bullState == 0 and not na(bullBreachLabel)
    label.delete(bullBreachLabel)
    bullBreachLabel := na

if bearState == 0 and not na(bearBreachLabel)
    label.delete(bearBreachLabel)
    bearBreachLabel := na

plotshape(bullPrepHit, title="Bull Prep Alert", location=location.belowbar, style=shape.labelup,   color=color.new(color.green, 0), text="A+", textcolor=color.white, size=size.normal)
plotshape(bearPrepHit, title="Bear Prep Alert", location=location.abovebar, style=shape.labeldown, color=color.new(color.red,   0), text="A+", textcolor=color.white, size=size.normal)

// ───────────────────────────────────────────────────────────────────
// BOS MARKER CLEANUP — remove markers older than bosLifespan bars
// ───────────────────────────────────────────────────────────────────
if array.size(bosCreatedBars) > 0
    i = array.size(bosCreatedBars) - 1
    while i >= 0
        createdBar = array.get(bosCreatedBars, i)
        if bar_index - createdBar > bosLifespan
            line.delete(array.get(bosLines, i))
            label.delete(array.get(bosLabels, i))
            array.remove(bosLines, i)
            array.remove(bosLabels, i)
            array.remove(bosCreatedBars, i)
        i := i - 1

// ───────────────────────────────────────────────────────────────────
// ALERTS
// ───────────────────────────────────────────────────────────────────
alertcondition(bullPrepHit, title="Bull A+ Setup — Prep Alert", message="Sovereign A+ BULL setup approaching on {{ticker}} {{interval}}. Price tapping 0.5 retrace. Get to your chart and prepare.")
alertcondition(bearPrepHit, title="Bear A+ Setup — Prep Alert", message="Sovereign A+ BEAR setup approaching on {{ticker}} {{interval}}. Price tapping 0.5 retrace. Get to your chart and prepare.")

// ───────────────────────────────────────────────────────────────────
// STATUS TABLE (top right)
// ───────────────────────────────────────────────────────────────────
var table statusTable = table.new(position.top_right, 2, 6, frame_color=color.white, frame_width=1, bgcolor=color.new(color.black, 20))

if barstate.islast
    table.cell(statusTable, 0, 0, "Filter", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(statusTable, 1, 0, "Status", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(statusTable, 0, 1, "TFs Aligned", text_color=color.white)
    tfStatus = allBull ? "BULL" : allBear ? "BEAR" : "MIXED"
    tfCol    = allBull ? color.green : allBear ? color.red : color.gray
    table.cell(statusTable, 1, 1, tfStatus, text_color=color.white, bgcolor=color.new(tfCol, 30))

    table.cell(statusTable, 0, 2, "EMA Stack", text_color=color.white)
    emaStatus = emaStackBull ? "BULL" : emaStackBear ? "BEAR" : "NONE"
    emaCol    = emaStackBull ? color.green : emaStackBear ? color.red : color.gray
    table.cell(statusTable, 1, 2, emaStatus, text_color=color.white, bgcolor=color.new(emaCol, 30))

    table.cell(statusTable, 0, 3, "Bull Setup", text_color=color.white)
    bullStateStr = bullState == 0 ? "Idle" : bullState == 1 ? "BB Breach" : "Armed (await 0.5)"
    table.cell(statusTable, 1, 3, bullStateStr, text_color=color.white, bgcolor=color.new(bullState > 0 ? color.green : color.gray, 30))

    table.cell(statusTable, 0, 4, "Bear Setup", text_color=color.white)
    bearStateStr = bearState == 0 ? "Idle" : bearState == 1 ? "BB Breach" : "Armed (await 0.5)"
    table.cell(statusTable, 1, 4, bearStateStr, text_color=color.white, bgcolor=color.new(bearState > 0 ? color.red : color.gray, 30))

    table.cell(statusTable, 0, 5, "Buffer (pips)", text_color=color.white)
    table.cell(statusTable, 1, 5, str.tostring(isJpy ? jpyBuffer : bufferPips, "#.#"), text_color=color.white)
````
