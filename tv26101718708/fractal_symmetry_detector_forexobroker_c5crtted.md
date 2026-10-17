# Fractal Symmetry Detector [forexobroker]

- url: https://www.tradingview.com/script/c5CRTTeD-Fractal-Symmetry-Detector-forexobroker/
- type: indicator
- pine_id: PUB;980dd6f918ac4b5fb81a8426fd805026
- version: 1.0

## Description

Fractal Symmetry Detector identifies classical ABC retracement patterns on the chart and measures their Fibonacci symmetry in real time. It tracks the last three alternating swing pivots (A-B-C), computes the BC/AB retrace ratio, and validates it against the standard Fibonacci levels -- 38.2%, 50%, 61.8%, and 78.6%. When BC completes at one of those levels, the pattern is marked complete and a directional BUY or SELL signal fires with projected T1 and T2 targets at 1.272 and 1.618 extensions.

This indicator is designed for swing traders and harmonic traders who want to enter continuation moves at the deepest pullback rather than chase breakouts. The ABC pattern is drawn live with neon lines, the Fib level is labeled at point C, and target projections extend from C into the future.

🔶 CONCEPTS

Markets rarely move in straight lines. After an impulse move (leg AB), price typically pulls back (leg BC) before continuing. The depth of that pullback -- measured as BC divided by AB -- almost always respects one of four Fibonacci levels: 38.2% (shallow), 50% (halfway), 61.8% (golden), or 78.6% (deep). A retrace that completes at one of these levels with a confirming candle and volume often marks the end of the correction and the start of a continuation leg. This is the foundation of harmonic trading and explains why Fibonacci levels produce reversals so reliably.

🔶 HOW IT WORKS

- Detects ZigZag pivots using the configured pivot length, maintaining an alternating high/low sequence
- When a new pivot forms, checks the last three pivots (A-B-C); A and C must be the same type and B the opposite
- Computes BC/AB ratio and checks proximity to each enabled Fib level using the tolerance setting
- Assigns a symmetry score 0-100 based on how close the ratio is to the matched Fib level
- Fires BUY on valid bullish ABC (low-high-low) with a bullish candle and volume confirmation; SELL on mirror
- If the immediate bar at C does not confirm, the setup becomes PENDING for up to 5 bars awaiting confirmation

🔶 HOW TO USE

1. Add the indicator -- whenever a completed ABC pattern is detected, AB and BC lines are drawn in neon with a C-point Fib label
2. Watch the dashboard (top-right) for live pattern status, Fib level matched, BC/AB ratio, and projected targets
3. Green BUY triangle with "ABC ↑" label fires on bullish ABC completion; pink SELL triangle on bearish
4. When C completes but the immediate candle does not confirm, the pattern becomes PENDING -- the signal will fire on the next qualifying candle within 5 bars
5. Target lines draw from the signal bar to T1 (1.272x AB) and T2 (1.618x AB); use as profit-taking guides

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Pending-setup mechanism that catches delayed confirmations
- Projected T1 and T2 target lines drawn from every signal

🔶 SETTINGS GUIDE

- Pivot Length -- Lookback for ZigZag pivot detection
- ATR Length -- Period for leg-length measurement in ATR units
- Fib Level Tolerance -- Acceptable deviation from a Fib level (fraction)
- Accept 38.2% / 50.0% / 61.8% / 78.6% -- Toggle which Fib retrace levels qualify
- Target Ext 1 / 2 -- Projected CD extension multiples of AB (classical 1.272 and 1.618)
- Volume SMA Length -- Baseline for volume confirmation
- Volume Confirm Multiplier -- Signal bar volume vs SMA; 1.0 accepts average volume
- Signal Cooldown Bars -- Minimum bars between consecutive signals
- Require Reversal Candle at C -- Enforce direction-matching candle; disable to trigger on pattern completion alone

🔶 ALERTS

- FSD Buy ABC -- Bullish ABC pattern confirmed with buy signal
- FSD Sell ABC -- Bearish ABC pattern confirmed with sell signal
- FSD Any Signal -- Any directional ABC signal
- FSD Pattern Complete -- ABC pattern completed at a Fib level (before confirmation)
- FSD Golden Fib -- 50% or 61.8% retrace detected
- FSD Bull Setup Pending -- Bullish ABC waiting for confirmation candle
- FSD Bear Setup Pending -- Bearish ABC waiting for confirmation candle
- FSD Perfect Symmetry -- Symmetry score 90%+ reached
- FSD Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past ABC pattern completions do not guarantee future price movements.
- Pivot detection lags by the pivot length; patterns only print after the third pivot is confirmed.
- Fibonacci retracement levels are reference levels with no mechanical guarantee of producing a continuation leg; the indicator reports the pattern, not a probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Fractal Symmetry Detector [forexobroker]", shorttitle="FSD [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_sym    = "Symmetry Settings"
string g_fib    = "Fibonacci Levels"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_pivotLen    = input.int(5, "Pivot Length", minval=2, maxval=15, group=g_sym, tooltip="Lookback for swing high/low detection")
int    i_atrLen      = input.int(14, "ATR Length", minval=5, maxval=50, group=g_sym)
float  i_fibTol      = input.float(0.08, "Fib Level Tolerance", minval=0.02, maxval=0.2, step=0.01, group=g_fib, tooltip="Acceptable deviation from a Fib level (fraction)")
bool   i_use382      = input.bool(true, "Accept 38.2% Retrace",  group=g_fib)
bool   i_use500      = input.bool(true, "Accept 50.0% Retrace",  group=g_fib)
bool   i_use618      = input.bool(true, "Accept 61.8% Retrace",  group=g_fib)
bool   i_use786      = input.bool(true, "Accept 78.6% Retrace",  group=g_fib)
float  i_ext1        = input.float(1.272, "Target Ext 1", minval=1.0, maxval=2.0, step=0.05, group=g_fib, tooltip="First CD projection")
float  i_ext2        = input.float(1.618, "Target Ext 2", minval=1.0, maxval=3.0, step=0.05, group=g_fib, tooltip="Second CD projection")
int    i_volLen      = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_signal)
float  i_volMult     = input.float(1.0, "Volume Confirm Multiplier", minval=0.5, maxval=3.0, step=0.1, group=g_signal)
int    i_cooldown    = input.int(5, "Signal Cooldown Bars", minval=1, maxval=30, group=g_signal)
bool   i_reqCandle   = input.bool(true, "Require Reversal Candle at C", group=g_signal, tooltip="C bar must close in reversal direction")
bool   i_showTable   = input.bool(true, "Show Dashboard", group=g_visual)
bool   i_showABC     = input.bool(true, "Show ABC Pattern Lines", group=g_visual)
bool   i_showTargets = input.bool(true, "Show CD Target Projections", group=g_visual)
bool   i_showGlow    = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
color  i_buyColor    = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor   = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal = ta.atr(i_atrLen)
float volSma = ta.sma(volume, i_volLen)
float ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pl = ta.pivotlow(low,   i_pivotLen, i_pivotLen)

// ─── PIVOT BUFFER (last 3 alternating pivots = A, B, C) ───────────────────────
var array<float> pvPx   = array.new<float>()
var array<int>   pvBar  = array.new<int>()
var array<bool>  pvHigh = array.new<bool>()

bool newPivot = false
float pvNewPx = na
int   pvNewBar = na
bool  pvNewHigh = false

if not na(ph)
    pvNewPx := ph
    pvNewBar := bar_index - i_pivotLen
    pvNewHigh := true
    newPivot := true
if not na(pl)
    pvNewPx := pl
    pvNewBar := bar_index - i_pivotLen
    pvNewHigh := false
    newPivot := true

// Maintain alternating sequence; replace last if same direction but more extreme
if newPivot
    int n = array.size(pvPx)
    if n > 0
        bool lastH = array.get(pvHigh, n - 1)
        if lastH == pvNewHigh
            float lastPx = array.get(pvPx, n - 1)
            if (pvNewHigh and pvNewPx > lastPx) or (not pvNewHigh and pvNewPx < lastPx)
                array.pop(pvPx)
                array.pop(pvBar)
                array.pop(pvHigh)
                array.push(pvPx, pvNewPx)
                array.push(pvBar, pvNewBar)
                array.push(pvHigh, pvNewHigh)
        else
            array.push(pvPx, pvNewPx)
            array.push(pvBar, pvNewBar)
            array.push(pvHigh, pvNewHigh)
            if array.size(pvPx) > 5
                array.shift(pvPx)
                array.shift(pvBar)
                array.shift(pvHigh)
    else
        array.push(pvPx, pvNewPx)
        array.push(pvBar, pvNewBar)
        array.push(pvHigh, pvNewHigh)

// ─── ABC PATTERN ANALYSIS ──────────────────────────────────────────────────────
float A_px = na, int A_bar = na
float B_px = na, int B_bar = na
float C_px = na, int C_bar = na
bool  A_high = false, bool B_high = false, bool C_high = false
bool  abcValid = false
float abLen = 0.0
float bcLen = 0.0
float fibRatio = 0.0
int   fibMatch = 0  // 0=none, 1=38.2, 2=50, 3=61.8, 4=78.6
bool  isBullishABC = false  // A=high, B=low, C=high → bullish continuation entry at C pullback
bool  isBearishABC = false  // A=low, B=high, C=low → bearish continuation entry at C pullback

if array.size(pvPx) >= 3
    int m = array.size(pvPx)
    A_px := array.get(pvPx, m - 3)
    B_px := array.get(pvPx, m - 2)
    C_px := array.get(pvPx, m - 1)
    A_bar := array.get(pvBar, m - 3)
    B_bar := array.get(pvBar, m - 2)
    C_bar := array.get(pvBar, m - 1)
    A_high := array.get(pvHigh, m - 3)
    B_high := array.get(pvHigh, m - 2)
    C_high := array.get(pvHigh, m - 1)
    if A_high != B_high and B_high != C_high
        abLen := math.abs(B_px - A_px)
        bcLen := math.abs(C_px - B_px)
        if abLen > 0
            fibRatio := bcLen / abLen
            if i_use382 and math.abs(fibRatio - 0.382) <= i_fibTol
                fibMatch := 1
            if i_use500 and math.abs(fibRatio - 0.5) <= i_fibTol
                fibMatch := 2
            if i_use618 and math.abs(fibRatio - 0.618) <= i_fibTol
                fibMatch := 3
            if i_use786 and math.abs(fibRatio - 0.786) <= i_fibTol
                fibMatch := 4
            if fibMatch > 0
                abcValid := true
                // Bullish continuation: A-low → B-high → C-low pullback → expect continuation up
                isBullishABC := not A_high and B_high and not C_high
                // Bearish continuation: A-high → B-low → C-high pullback → expect continuation down
                isBearishABC := A_high and not B_high and C_high

string fibLabel = fibMatch == 1 ? "38.2%" : fibMatch == 2 ? "50.0%" : fibMatch == 3 ? "61.8%" : fibMatch == 4 ? "78.6%" : "—"
float symScore = fibMatch > 0 ? math.round(100.0 * (1.0 - math.abs(fibRatio - (fibMatch == 1 ? 0.382 : fibMatch == 2 ? 0.5 : fibMatch == 3 ? 0.618 : 0.786)) / i_fibTol)) : 0.0

// ─── DRAW ABC PATTERN LINES ────────────────────────────────────────────────────
var line abLine = na
var line bcLine = na
var label cLabel = na
if abcValid and newPivot and i_showABC
    if not na(abLine)
        line.delete(abLine)
    if not na(bcLine)
        line.delete(bcLine)
    if not na(cLabel)
        label.delete(cLabel)
    color patCol = isBullishABC ? c_green : isBearishABC ? c_pink : c_purple
    abLine := line.new(A_bar, A_px, B_bar, B_px, color=color.new(patCol, 20), width=2, style=line.style_solid)
    bcLine := line.new(B_bar, B_px, C_bar, C_px, color=color.new(patCol, 20), width=2, style=line.style_dashed)
    cLabel := label.new(C_bar, C_px, "C\n" + fibLabel, style=C_high ? label.style_label_down : label.style_label_up, color=color.new(patCol, 15), textcolor=color.white, size=size.small)

// ─── TARGET PROJECTIONS (CD extensions) ────────────────────────────────────────
float target1 = na
float target2 = na
if abcValid
    if isBullishABC
        target1 := C_px + abLen * i_ext1
        target2 := C_px + abLen * i_ext2
    if isBearishABC
        target1 := C_px - abLen * i_ext1
        target2 := C_px - abLen * i_ext2

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool volConfirm = volume >= volSma * i_volMult
bool freshPattern = abcValid and newPivot
bool bullCandle = close > open and close > (high + low) / 2.0
bool bearCandle = close < open and close < (high + low) / 2.0
bool candleOk = not i_reqCandle or (isBullishABC and bullCandle) or (isBearishABC and bearCandle)

bool rawBuy  = freshPattern and isBullishABC and candleOk and volConfirm and cooldownOk and confirmed
bool rawSell = freshPattern and isBearishABC and candleOk and volConfirm and cooldownOk and confirmed

// If first signal too strict, also allow "delayed confirmation" on next bar close if no new pivot yet
var bool pendingBull = false
var bool pendingBear = false
var float pendingTarget1 = na
var float pendingTarget2 = na
var int pendingBar = 0

if freshPattern and isBullishABC and not rawBuy
    pendingBull := true
    pendingBear := false
    pendingTarget1 := target1
    pendingTarget2 := target2
    pendingBar := bar_index
if freshPattern and isBearishABC and not rawSell
    pendingBear := true
    pendingBull := false
    pendingTarget1 := target1
    pendingTarget2 := target2
    pendingBar := bar_index
if (bar_index - pendingBar) > 5
    pendingBull := false
    pendingBear := false

bool pendingBuyTrig  = pendingBull and bullCandle and volConfirm and cooldownOk and confirmed
bool pendingSellTrig = pendingBear and bearCandle and volConfirm and cooldownOk and confirmed

bool buySignal  = rawBuy or pendingBuyTrig
bool sellSignal = rawSell or pendingSellTrig

if buySignal or sellSignal
    lastSignalBar := bar_index
    pendingBull := false
    pendingBear := false

// ─── STATS ─────────────────────────────────────────────────────────────────────
var int patternsDetected = 0
var int buysFired  = 0
var int sellsFired = 0
if freshPattern
    patternsDetected := patternsDetected + 1
if buySignal
    buysFired := buysFired + 1
if sellSignal
    sellsFired := sellsFired + 1

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ABC ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ABC ↓", textcolor=color.white)

// ─── VISUAL: Signal Context Label ──────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.3, "ABC COMPLETE ↑\nRetrace: " + fibLabel + "\nT1: " + (not na(pendingTarget1) ? str.tostring(math.round(pendingTarget1, 4)) : not na(target1) ? str.tostring(math.round(target1, 4)) : "—"), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.3, "ABC COMPLETE ↓\nRetrace: " + fibLabel + "\nT1: " + (not na(pendingTarget1) ? str.tostring(math.round(pendingTarget1, 4)) : not na(target1) ? str.tostring(math.round(target1, 4)) : "—"), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

// ─── VISUAL: Target Projection Lines ───────────────────────────────────────────
if i_showTargets and (buySignal or sellSignal)
    float tgt1 = not na(pendingTarget1) ? pendingTarget1 : target1
    float tgt2 = not na(pendingTarget2) ? pendingTarget2 : target2
    color tCol = buySignal ? i_buyColor : i_sellColor
    if not na(tgt1)
        line.new(bar_index, close, bar_index + 30, tgt1, color=color.new(tCol, 30), style=line.style_dotted, width=1)
        label.new(bar_index + 30, tgt1, "T1 " + str.tostring(i_ext1) + "x", style=label.style_label_left, color=color.new(tCol, 60), textcolor=color.white, size=size.tiny)
    if not na(tgt2)
        line.new(bar_index, close, bar_index + 30, tgt2, color=color.new(tCol, 50), style=line.style_dotted, width=1)
        label.new(bar_index + 30, tgt2, "T2 " + str.tostring(i_ext2) + "x", style=label.style_label_left, color=color.new(tCol, 60), textcolor=color.white, size=size.tiny)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(buySignal ? color.new(i_buyColor, 90) : sellSignal ? color.new(i_sellColor, 90) : na)

// ─── VISUAL: Symmetry Dashboard ────────────────────────────────────────────────
string patStatus = abcValid and isBullishABC ? "↑ BULL ABC" : abcValid and isBearishABC ? "↓ BEAR ABC" : abcValid ? "ABC" : "—"
color  patCol    = abcValid and isBullishABC ? c_green : abcValid and isBearishABC ? c_pink : color.gray
string pendingStr = pendingBull ? "↑ BULL WAIT" : pendingBear ? "↓ BEAR WAIT" : "—"
color  pendCol = pendingBull ? c_green : pendingBear ? c_pink : color.gray

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Fractal Symmetry Detector", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, patStatus, text_color=patCol, text_size=size.normal)
    table.cell(dash, 0, 1, "Fib Level", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, fibLabel, text_color=fibMatch > 0 ? c_gold : color.gray, text_size=size.small)
    table.cell(dash, 0, 2, "BC / AB Ratio", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(math.round(fibRatio, 3)), text_color=fibMatch > 0 ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 3, "Symmetry Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(symScore) + "%", text_color=symScore >= 80 ? c_gold : symScore >= 50 ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "AB Length (ATR)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, atrVal > 0 ? str.tostring(math.round(abLen / atrVal, 1)) + "x" : "—", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 5, "BC Length (ATR)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, atrVal > 0 ? str.tostring(math.round(bcLen / atrVal, 1)) + "x" : "—", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Pending Setup", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, pendingStr, text_color=pendCol, text_size=size.small)
    table.cell(dash, 0, 7, "Target 1", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, not na(target1) ? str.tostring(math.round(target1, 4)) : "—", text_color=c_gold, text_size=size.small)
    table.cell(dash, 0, 8, "Target 2", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, not na(target2) ? str.tostring(math.round(target2, 4)) : "—", text_color=c_gold, text_size=size.small)
    table.cell(dash, 0, 9, "Patterns Found", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(patternsDetected), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 10, "Signals (B / S)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(buysFired) + " / " + str.tostring(sellsFired), text_color=c_gold, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"FSD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"fib":"' + fibLabel + '"}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"FSD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"fib":"' + fibLabel + '"}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                     "FSD Buy ABC",           "Fractal Symmetry BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                    "FSD Sell ABC",          "Fractal Symmetry SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,       "FSD Any Signal",        "Any ABC signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(abcValid and newPivot,         "FSD Pattern Complete",  "ABC pattern completed on {{ticker}} {{interval}}")
alertcondition(fibMatch == 2 or fibMatch == 3, "FSD Golden Fib",       "50% or 61.8% retrace detected on {{ticker}} {{interval}}")
alertcondition(pendingBull,                   "FSD Bull Setup Pending","Bullish ABC waiting for confirmation on {{ticker}} {{interval}}")
alertcondition(pendingBear,                   "FSD Bear Setup Pending","Bearish ABC waiting for confirmation on {{ticker}} {{interval}}")
alertcondition(symScore >= 90,                "FSD Perfect Symmetry",  "Symmetry score 90%+ on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,       "FSD Webhook JSON",      "{\"action\":\"signal\",\"indicator\":\"FSD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
