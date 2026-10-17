# AMD + FVG Sequential

- url: https://www.tradingview.com/script/bqrS1VYF-AMD-FVG-Sequential/
- type: indicator
- pine_id: PUB;551fd9e052724e70ab40bfbe046f43d3
- version: 2.0

## Description

Price Action and Smart Money Concepts (SMC) terminology:Accumulation — Blue Box: Detects when the range of the last N bars is less than \(\text{accMaxRange} \times \text{ATR}\). As long as the range remains tight, the box extends.Manipulation — M Mark: A wick that punctures the box (either above or below) and closes back inside. This sets the bias: an upward sweep leads to a bearish setup, while a downward sweep leads to a bullish setup.FVG (Fair Value Gap) — Green/Red Box: Includes a BUY/SELL arrow and a background flash. This is the main signal. It only triggers if it is in the direction coherent with the sweep (e.g., a bullish FVG is only valid after a sweep of lows, and vice versa).Distribution — D Mark: Triggered when the price moves away from the FVG by at least \(\text{distMinMov} \times \text{ATR}\).

## Source Code

````pine
//@version=5
indicator("AMD + FVG Sequential v3", overlay=true, max_boxes_count=200, max_labels_count=300, max_lines_count=100)

// === INPUTS ===
g1 = "1. Accumulation"
accBars     = input.int(5,    "Lookback bars",       3, 50, group=g1)
accMaxRange = input.float(2.0,"Max range x ATR",     0.1, step=0.1, group=g1, tooltip="Higher = looser. 2.0 catches most SPX micro-consolidations")

g2 = "2. Manipulation (sweep)"
manipWindow = input.int(10, "Bars after accum to find sweep", 1, 30, group=g2)
requireWick = input.bool(false, "Require close back inside range", group=g2)

g3 = "3. FVG (main signal)"
fvgWindow  = input.int(10,   "Bars after sweep to find FVG", 1, 30, group=g3)
fvgMinSize = input.float(0.05,"Min FVG size x ATR",         0.0, step=0.05, group=g3)

g4 = "4. Distribution"
distWindow = input.int(20, "Bars to confirm distribution", 1, 100, group=g4)
distMinMov = input.float(0.4,"Min move from FVG x ATR",    0.1, step=0.1, group=g4)

g5 = "ALWAYS-ON structure (the prediction tools)"
showAllFVGs   = input.bool(true,  "Show ALL FVGs (small boxes)", group=g5, tooltip="Every fair value gap on the chart - magnets for price retracement")
showAllSweeps = input.bool(true,  "Show ALL liquidity sweeps",   group=g5, tooltip="Every prior-high/low grab - reversal candidates")
sweepLookback = input.int(10,     "Sweep lookback bars",         3, 50, group=g5)
showRange     = input.bool(true,  "Show rolling range lines",    group=g5, tooltip="Current N-bar high/low - intraday S/R")
extendFVGs    = input.int(8,      "Extend FVG boxes (bars)",     2, 50, group=g5)

g6 = "Visuals & Debug"
showAccBox  = input.bool(true, "Accumulation box (sequence)", group=g6)
showManip   = input.bool(true, "Manipulation marker M", group=g6)
showFVG     = input.bool(true, "FVG box LARGE (sequence)", group=g6)
showDist    = input.bool(true, "Distribution marker D", group=g6)
bgFlash     = input.bool(true, "Background flash on signal", group=g6)
debugState  = input.bool(true, "Show state table", group=g6)
signalAtTop = input.bool(true, "Force BUY/SELL at top", group=g6)

atrVal = ta.atr(14)

// ===========================================
// LAYER 1: ALWAYS-ON STRUCTURE (always visible)
// ===========================================

// --- Rolling range lines (current N-bar S/R) ---
rngHi = ta.highest(high, accBars)
rngLo = ta.lowest(low, accBars)
plot(showRange ? rngHi : na, "Range high", color.new(color.gray, 50), 1)
plot(showRange ? rngLo : na, "Range low",  color.new(color.gray, 50), 1)

// --- ALL FVGs as small light boxes ---
bullFVG_all = low  > high[2] and (low - high[2]) >= fvgMinSize * atrVal
bearFVG_all = high < low[2]  and (low[2] - high) >= fvgMinSize * atrVal

if showAllFVGs and bullFVG_all
    box.new(bar_index - 2, low, bar_index + extendFVGs, high[2], border_color=color.new(color.aqua, 60), bgcolor=color.new(color.aqua, 88))

if showAllFVGs and bearFVG_all
    box.new(bar_index - 2, low[2], bar_index + extendFVGs, high, border_color=color.new(color.fuchsia, 60), bgcolor=color.new(color.fuchsia, 88))

// --- ALL liquidity sweeps (any prior high/low grabbed and rejected) ---
priorHi = ta.highest(high[1], sweepLookback)
priorLo = ta.lowest(low[1],  sweepLookback)
sweepHi_all = high > priorHi and close < priorHi
sweepLo_all = low  < priorLo and close > priorLo

plotshape(showAllSweeps and sweepHi_all, "Sweep high", shape.xcross, location.abovebar, color.new(color.orange, 0), size=size.tiny)
plotshape(showAllSweeps and sweepLo_all, "Sweep low",  shape.xcross, location.belowbar, color.new(color.yellow, 0), size=size.tiny)

// ===========================================
// LAYER 2: STATE MACHINE (AMD sequence - main signal)
// ===========================================

var int   st        = 0
var int   timer     = 0
var float accHi     = na
var float accLo     = na
var int   accLeft   = na
var int   accRight  = na
var bool  bullBias  = false
var float fvgHi     = na
var float fvgLo     = na
var box   accBoxId  = na
var box   fvgBoxId  = na

isAccum = (rngHi - rngLo) <= accMaxRange * atrVal

var bool fvgSignalNow = false
fvgSignalNow := false

// 0 -> 1
if st == 0 and isAccum and not na(atrVal) and bar_index >= accBars
    accHi := rngHi
    accLo := rngLo
    accLeft  := bar_index - accBars + 1
    accRight := bar_index
    st := 1
    timer := 0
    if showAccBox
        accBoxId := box.new(accLeft, accHi, accRight, accLo, border_color=color.new(color.blue, 20), bgcolor=color.new(color.blue, 80), border_width=2)

// 1 -> 2
if st == 1
    sweptHigh = high > accHi and (requireWick ? close < accHi : true)
    sweptLow  = low  < accLo and (requireWick ? close > accLo : true)
    if sweptHigh
        bullBias := false
        st := 2
        timer := 0
        if showManip
            label.new(bar_index, high, "M", color=color.new(color.red, 0), textcolor=color.white, style=label.style_label_down, size=size.normal)
    else if sweptLow
        bullBias := true
        st := 2
        timer := 0
        if showManip
            label.new(bar_index, low, "M", color=color.new(color.green, 0), textcolor=color.white, style=label.style_label_up, size=size.normal)
    else if isAccum
        accHi := math.max(accHi, high)
        accLo := math.min(accLo, low)
        accRight := bar_index
        timer := 0
        if showAccBox and not na(accBoxId)
            box.set_top(accBoxId, accHi)
            box.set_bottom(accBoxId, accLo)
            box.set_right(accBoxId, accRight)
    else
        timer += 1
        if timer > manipWindow
            st := 0
            timer := 0
            if not na(accBoxId)
                box.delete(accBoxId)
                accBoxId := na

// 2 -> 3
if st == 2
    timer += 1
    bullFVG = low  > high[2] and (low - high[2]) >= fvgMinSize * atrVal
    bearFVG = high < low[2]  and (low[2] - high) >= fvgMinSize * atrVal
    if bullBias and bullFVG
        fvgHi := low
        fvgLo := high[2]
        st := 3
        timer := 0
        fvgSignalNow := true
        if showFVG
            fvgBoxId := box.new(bar_index - 2, fvgHi, bar_index + 30, fvgLo, border_color=color.new(color.green, 0), bgcolor=color.new(color.green, 65), border_width=3)
    else if not bullBias and bearFVG
        fvgHi := low[2]
        fvgLo := high
        st := 3
        timer := 0
        fvgSignalNow := true
        if showFVG
            fvgBoxId := box.new(bar_index - 2, fvgHi, bar_index + 30, fvgLo, border_color=color.new(color.red, 0), bgcolor=color.new(color.red, 65), border_width=3)
    else if timer > fvgWindow
        st := 0
        timer := 0
        if not na(accBoxId)
            box.delete(accBoxId)
            accBoxId := na

// 3 -> 0
if st == 3
    timer += 1
    moveSize = bullBias ? (high - fvgHi) : (fvgLo - low)
    if moveSize >= distMinMov * atrVal
        if showDist
            label.new(bar_index, bullBias ? high : low, "D", color=color.new(color.purple, 0), textcolor=color.white, style=bullBias ? label.style_label_down : label.style_label_up, size=size.normal)
        st := 0
        timer := 0
    else if timer > distWindow
        st := 0
        timer := 0

// ===========================================
// MAIN SIGNAL OUTPUTS
// ===========================================
plotshape(fvgSignalNow and bullBias,     "BUY",  shape.triangleup,   signalAtTop ? location.abovebar : location.belowbar, color.new(color.lime, 0), size=size.huge, text="BUY",  textcolor=color.white)
plotshape(fvgSignalNow and not bullBias, "SELL", shape.triangledown, signalAtTop ? location.belowbar : location.abovebar, color.new(color.red,  0), size=size.huge, text="SELL", textcolor=color.white)

bgcolor(bgFlash and fvgSignalNow and bullBias     ? color.new(color.lime, 60) : na)
bgcolor(bgFlash and fvgSignalNow and not bullBias ? color.new(color.red,  60) : na)

alertcondition(fvgSignalNow and bullBias,     "AMD-FVG Bullish", "Bullish AMD-FVG signal")
alertcondition(fvgSignalNow and not bullBias, "AMD-FVG Bearish", "Bearish AMD-FVG signal")

// Also alert on any sweep + FVG combo (more frequent, less strict)
alertcondition(sweepLo_all and bullFVG_all, "Quick Bull setup", "Sweep low + bull FVG (no full AMD)")
alertcondition(sweepHi_all and bearFVG_all, "Quick Bear setup", "Sweep high + bear FVG (no full AMD)")

// ===========================================
// DEBUG TABLE
// ===========================================
var table dbg = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 70), border_width=1)
if debugState and barstate.islast
    stateName = st == 0 ? "Idle (waiting accum)" : st == 1 ? "Accumulation locked" : st == 2 ? "Manip done, waiting FVG" : "FVG fired, waiting dist"
    biasName  = bullBias ? "BULLISH" : "BEARISH"
    rngRatio  = (rngHi - rngLo) / atrVal
    nearAccum = rngRatio <= accMaxRange ? "YES - ready" : "no"
    table.cell(dbg, 0, 0, "State",       text_color=color.white, bgcolor=color.new(color.blue, 50))
    table.cell(dbg, 1, 0, stateName,     text_color=color.white)
    table.cell(dbg, 0, 1, "Bias",        text_color=color.white, bgcolor=color.new(color.blue, 50))
    table.cell(dbg, 1, 1, st >= 2 ? biasName : "—", text_color=color.white)
    table.cell(dbg, 0, 2, "Timer",       text_color=color.white, bgcolor=color.new(color.blue, 50))
    table.cell(dbg, 1, 2, str.tostring(timer), text_color=color.white)
    table.cell(dbg, 0, 3, "Range/ATR",   text_color=color.white, bgcolor=color.new(color.blue, 50))
    table.cell(dbg, 1, 3, str.tostring(rngRatio, "#.##") + " / " + str.tostring(accMaxRange), text_color=color.white)
    table.cell(dbg, 0, 4, "In accum?",   text_color=color.white, bgcolor=color.new(color.blue, 50))
    table.cell(dbg, 1, 4, nearAccum,     text_color=rngRatio <= accMaxRange ? color.lime : color.orange)
    table.cell(dbg, 0, 5, "ATR",         text_color=color.white, bgcolor=color.new(color.blue, 50))
    table.cell(dbg, 1, 5, str.tostring(atrVal, "#.##"), text_color=color.white)
````
