# Seller Exhaustion Detector

- url: https://www.tradingview.com/script/ByZSqHud-Seller-Exhaustion-Detector/
- type: indicator
- pine_id: PUB;7af9a4a948a34accacfde8bab3811315
- version: 1.0

## Description

Seller Exhaustion Detector (SED)

Overview

Seller Exhaustion Detector identifies the point where a downtrend's selling pressure is spent and buyers begin absorbing supply — the transition from distribution to accumulation. Instead of reacting to a single pattern, it scores seven independent exhaustion footprints and only confirms a signal when structural gates prove the low is actually holding.

How It Works

The detector scores confluence across a 16-point scale:


Liquidity Sweep + Reclaim (3 pts) — tracks untapped pivot-low liquidity pools; a wick below a pool followed by a close back above it marks a stop run absorbed by passive buyers.
CVD Bullish Divergence (3 pts) — price makes a lower low while session-reset cumulative volume delta makes a higher low: sell orders are no longer moving price.
RSI Bullish Divergence (2 pts) — momentum fails to confirm the new price low.
Sell-Volume Dry-Up (2 pts) — red-candle volume contracts near the lows; motivated sellers are done.
Absorption (2 pts) — elevated volume, compressed range, close in the upper half: supply being eaten without downside progress.
Higher Low (2 pts) — first structural higher pivot after the low.
Selling Climax Watch (1 pt) and Confirmed Wick Rejection (1 pt) — capitulation context and next-bar-confirmed hammer rejections.


A score alone never fires a signal. Three hard gates must also pass: the low must have held for a configurable number of bars (or a fresh sweep-reclaim substitutes as confirmation), price must be above a rising/flat EMA9, and fast volume delta must be positive. This eliminates premature signals printed while price is still making new lows.

Signals


Orange circle — selling climax (capitulation bar; watch window begins)
Gold diamond — liquidity pool swept and reclaimed
EXHAUSTION label — confirmed exhaustion (score + all gates)
ACCUMULATE label — post-exhaustion structure reclaim with positive delta
STOP-OUT label — the exhaustion low broke; the signal is invalid
Dashboard — live score breakdown and gate status, with selectable text size


Recommended Use

Built for 1-minute to 5-minute intraday charts on liquid symbols. Use EXHAUSTION as location, ACCUMULATE as trigger, and the invalidation print as a hard exit reference. Tune Climax Multiplier down (~1.7) and Pivot Left/Right to 3–4 for faster symbols.

Limitations

Volume delta is approximated from candle direction (up-volume minus down-volume), not exchange bid/ask data, so absorption and CVD reads are estimates. All components are derived from OHLCV and confirm after the fact by design — the detector locates high-probability reversal conditions; it does not predict bottoms. Not financial advice.

## Source Code

````pine
//@version=6
//  Seller Exhaustion & Accumulation Detector v3.2
// v3.2 changes vs v3.1:
//  - POOL EXPIRY: liquidity levels older than "Pool Max Age" are removed (fixes stale lines drifting over the volume pane)
//  - Swept-pool markers (dashed) also expire instead of persisting forever
//  - Professional signal labels via label.new with user-selectable size (Tiny/Small/Normal) and score tooltips
//  - Dashboard text size selectable in settings (Tiny/Small/Normal)
// Sweep logic is original — do NOT merge LuxAlgo CC BY-NC-SA code into commercial releases.

indicator("Seller Exhaustion Detector", "SED", overlay = true, scale = scale.right, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────── INPUTS ───────────────────────────
grpV = "Volume Climax / Dry-Up"
volLen      = input.int(20,   "Volume SMA Length",            group = grpV)
climaxMult  = input.float(2.0,"Climax Volume Multiplier",     step = 0.1,  group = grpV)
dryUpMult   = input.float(0.7,"Sell-Volume Dry-Up Threshold", step = 0.05, group = grpV)

grpW = "Wick Rejection / Absorption"
wickRatio   = input.float(1.5,"Lower Wick : Body Ratio",      step = 0.1,  group = grpW)
absVolMult  = input.float(1.5,"Absorption Volume Multiplier", step = 0.1,  group = grpW)
absRangeMax = input.float(0.7,"Absorption Max Range (x ATR)", step = 0.05, group = grpW)

grpD = "Divergence"
rsiLen      = input.int(14, "RSI Length",       group = grpD)
pivLen      = input.int(5,  "Pivot Left/Right", group = grpD)

grpL = "Liquidity Sweeps"
liqPivLen   = input.int(14,  "Liquidity Pivot Lookback",       group = grpL)
maxPools    = input.int(8,   "Max Tracked Pools", minval = 2, maxval = 20, group = grpL)
poolMaxAge  = input.int(150, "Pool Max Age (bars)", minval = 20, group = grpL, tooltip = "Untouched pools older than this are removed — prevents stale lines stretching across the chart")
reclaimBars = input.int(3,   "Reclaim Within (bars)", minval = 1, group = grpL)
showPools   = input.bool(true, "Show Liquidity Levels",        group = grpL)

grpS = "Structure, Gates & Scoring"
lookback      = input.int(30, "Swing-Low Lookback",              group = grpS)
nearLowATR    = input.float(1.0, "Near-Low Tolerance (x ATR)",   step = 0.1, group = grpS)
stabilizeBars = input.int(6,  "Low Must Hold (bars)", minval = 2, group = grpS)
watchBars     = input.int(15, "Climax Watch Window (bars)",      group = grpS)
scoreThresh   = input.int(9,  "Exhaustion Score Threshold (of 16)", minval = 1, maxval = 16, group = grpS)
showEarly     = input.bool(false, "Show Early Warning",          group = grpS)

grpUI = "Appearance"
sigSizeIn  = input.string("Small", "Signal Label Size",   options = ["Tiny", "Small", "Normal"], group = grpUI)
dashSizeIn = input.string("Tiny",  "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = grpUI)
showDash   = input.bool(true, "Show Dashboard", group = grpUI)

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal
sigSz  = f_size(sigSizeIn)
dashSz = f_size(dashSizeIn)

// Professional palette
colGold  = color.new(#D4AF37, 0)
colTeal  = color.new(#26A69A, 0)
colGray  = color.new(#787B86, 20)
colRed   = color.new(#EF5350, 0)
colAmber = color.new(#FF9800, 0)

// ─────────────────────────── CORE SERIES ───────────────────────────
atr     = ta.atr(14)
volSma  = ta.sma(volume, volLen)
rsi     = ta.rsi(close, rsiLen)
body    = math.abs(close - open)
lowWick = math.min(open, close) - low
isRed   = close < open
ema9    = ta.ema(close, 9)

delta   = isRed ? -volume : volume
var float cvd = 0.0
cvd := session.isfirstbar ? delta : cvd + delta
deltaFast = ta.sma(delta, 5)

downVol     = isRed ? volume : 0.0
downVolFast = ta.sma(downVol, 5)
downVolSlow = ta.sma(downVol, volLen)

// ─────────────────────────── LIQUIDITY POOLS ───────────────────────────
var array<float> poolLvl = array.new<float>()
var array<int>   poolBar = array.new<int>()
var array<line>  poolLn  = array.new<line>()
// Swept markers (dashed) with their own expiry
var array<line>  sweptLn    = array.new<line>()
var array<int>   sweptLnBar = array.new<int>()

liqPL = ta.pivotlow(low, liqPivLen, liqPivLen)
if not na(liqPL)
    array.unshift(poolLvl, liqPL)
    array.unshift(poolBar, bar_index - liqPivLen)
    array.unshift(poolLn, showPools ? line.new(bar_index - liqPivLen, liqPL, bar_index, liqPL, color = color.new(#26A69A, 40), width = 1) : line(na))
    if array.size(poolLvl) > maxPools
        line.delete(array.pop(poolLn))
        array.pop(poolLvl)
        array.pop(poolBar)

// AGE EXPIRY — newest at index 0, oldest at the end
while array.size(poolBar) > 0 and bar_index - array.get(poolBar, array.size(poolBar) - 1) > poolMaxAge
    line.delete(array.pop(poolLn))
    array.pop(poolLvl)
    array.pop(poolBar)
while array.size(sweptLnBar) > 0 and bar_index - array.get(sweptLnBar, array.size(sweptLnBar) - 1) > poolMaxAge
    line.delete(array.pop(sweptLn))
    array.pop(sweptLnBar)

var float sweptLvl = na
var int   sweptBar = na
sweepReclaim = false

if array.size(poolLvl) > 0
    for i = array.size(poolLvl) - 1 to 0
        lvl = array.get(poolLvl, i)
        ln  = array.get(poolLn, i)
        if not na(ln)
            line.set_x2(ln, bar_index)
        if close < lvl
            if not na(ln)
                line.delete(ln)
            array.remove(poolLn, i)
            array.remove(poolLvl, i)
            array.remove(poolBar, i)
        else if low < lvl
            sweptLvl := lvl
            sweptBar := bar_index
            if close > lvl
                sweepReclaim := true
                if not na(ln)
                    line.set_style(ln, line.style_dashed)
                    line.set_color(ln, color.new(#D4AF37, 20))
                    array.unshift(sweptLn, ln)          // hand line to expiring marker store
                    array.unshift(sweptLnBar, bar_index)
                array.remove(poolLn, i)
                array.remove(poolLvl, i)
                array.remove(poolBar, i)

delayedReclaim = not na(sweptLvl) and not na(sweptBar) and bar_index - sweptBar <= reclaimBars and close > sweptLvl and close[1] <= sweptLvl
sweepEvent  = sweepReclaim or delayedReclaim
sweepActive = ta.barssince(sweepEvent) <= watchBars

// ─────────────────────────── STABILIZED LOW ───────────────────────────
swingLow      = ta.lowest(low, lookback)
barsSinceLow  = ta.barssince(low <= swingLow)
lowStabilized = barsSinceLow >= stabilizeBars
nearLow       = low <= swingLow + nearLowATR * atr
emaFalling    = ema9 - ema9[5] < -0.5 * atr

// ─────────────────────────── COMPONENTS ───────────────────────────
sellingClimax   = isRed and volume > climaxMult * volSma and low <= ta.lowest(low, lookback)
barsSinceClimax = ta.barssince(sellingClimax)
inWatch         = not na(barsSinceClimax) and barsSinceClimax <= watchBars

wickBar     = nearLow and lowWick > wickRatio * math.max(body, syminfo.mintick) and close >= (high + low) / 2
wickConfirm = wickBar[1] and close > high[1]
wickActive  = ta.barssince(wickConfirm) <= watchBars

plPrice = ta.pivotlow(low, pivLen, pivLen)
var float lastPL  = na
var float prevPL  = na
var float lastPLr = na
var float prevPLr = na
var float lastPLc = na
var float prevPLc = na
if not na(plPrice)
    prevPL  := lastPL
    lastPL  := plPrice
    prevPLr := lastPLr
    lastPLr := rsi[pivLen]
    prevPLc := lastPLc
    lastPLc := cvd[pivLen]

rsiBullDiv   = not na(plPrice) and not na(prevPL) and lastPL < prevPL and lastPLr > prevPLr
cvdBullDiv   = not na(plPrice) and not na(prevPL) and lastPL < prevPL and lastPLc > prevPLc
rsiDivActive = ta.barssince(rsiBullDiv) <= watchBars
cvdDivActive = ta.barssince(cvdBullDiv) <= watchBars

dryUp      = nearLow and downVolFast < dryUpMult * downVolSlow and downVolSlow > 0
absorption = nearLow and volume > absVolMult * volSma and (high - low) < absRangeMax * atr and close >= (high + low) / 2
absActive  = ta.barssince(absorption) <= watchBars
higherLow  = not na(plPrice) and not na(prevPL) and lastPL > prevPL
hlActive   = ta.barssince(higherLow) <= watchBars

// ─────────────────────────── SCORE (0–16) ───────────────────────────
score = (sweepActive ? 3 : 0) + (cvdDivActive ? 3 : 0) + (rsiDivActive ? 2 : 0) + (dryUp ? 2 : 0) + (absActive ? 2 : 0) + (hlActive ? 2 : 0) + (inWatch ? 1 : 0) + (wickActive ? 1 : 0)

// ─────────────────────────── GATES ───────────────────────────
recentReclaim = ta.barssince(sweepEvent) <= reclaimBars
gateStable = lowStabilized or recentReclaim
gateEma    = close > ema9 and not emaFalling
gateDelta  = deltaFast > 0
gatesOk    = gateStable and gateEma and gateDelta

exhaustConfirmed = score >= scoreThresh and gatesOk and nearLow
var int lastSignalBar = na
var float exhLow = na
newExhaust = exhaustConfirmed and (na(lastSignalBar) or bar_index - lastSignalBar > watchBars)
if newExhaust
    lastSignalBar := bar_index
    exhLow := swingLow

var bool earlyWarn = false
earlyWarn := showEarly and score >= scoreThresh - 3 and nearLow and not gatesOk and not earlyWarn[1]

invalidated = not na(exhLow) and low < exhLow
if invalidated
    exhLow := na

sinceExhaust = ta.barssince(newExhaust)
accumConfirm = not na(sinceExhaust) and sinceExhaust > 0 and sinceExhaust <= watchBars * 2 and
               close > ta.highest(high, 5)[1] and close > ema9 and deltaFast > 0
newAccum = accumConfirm and not accumConfirm[1]

// ─────────────────────────── SIGNAL LABELS (professional, sized by input) ───────────────────────────
tipTxt = "Score " + str.tostring(score) + "/16" +
         "\nSweep+Reclaim: " + (sweepActive ? "yes" : "no") +
         "\nCVD Div: " + (cvdDivActive ? "yes" : "no") +
         "\nRSI Div: " + (rsiDivActive ? "yes" : "no") +
         "\nDry-Up: " + (dryUp ? "yes" : "no") +
         "\nAbsorption: " + (absActive ? "yes" : "no")

if newExhaust
    label.new(bar_index, low - 0.3 * atr, "EXHAUSTION", style = label.style_label_up, color = colGold, textcolor = color.black, size = sigSz, tooltip = tipTxt)
if newAccum
    label.new(bar_index, low - 0.3 * atr, "ACCUMULATE", style = label.style_label_up, color = colTeal, textcolor = color.white, size = sigSz, tooltip = tipTxt)
if earlyWarn
    label.new(bar_index, low - 0.3 * atr, "watch", style = label.style_label_up, color = color.new(#787B86, 60), textcolor = color.white, size = size.tiny, tooltip = tipTxt)
if invalidated
    label.new(bar_index, low - 0.3 * atr, "STOP-OUT", style = label.style_label_up, color = colRed, textcolor = color.white, size = sigSz, tooltip = "Exhaustion low broken — signal invalid")

// Minor marks stay as small fixed shapes
plotshape(sellingClimax, "Selling Climax",  shape.circle,  location.belowbar, colAmber, size = size.tiny, display = display.pane)
plotshape(sweepEvent,    "Liquidity Sweep", shape.diamond, location.belowbar, colGold,  size = size.tiny, display = display.pane)

bgcolor(inWatch ? color.new(color.orange, 94) : na, title = "Climax Watch Window")
plot(ema9, "EMA 9", color.new(#787B86, 50), display = display.pane)

// ─────────────────────────── DASHBOARD ───────────────────────────
var table dash = table.new(position.top_right, 2, 13, bgcolor = color.new(color.black, 20), border_width = 1)
f_cell(int r, string txt, bool on) =>
    table.cell(dash, 0, r, txt, text_color = color.white, text_size = dashSz)
    table.cell(dash, 1, r, on ? "✔" : "✖", text_color = on ? colTeal : colRed, text_size = dashSz)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "SELLER EXHAUSTION v3.2", text_color = colGold, text_size = dashSz)
    table.cell(dash, 1, 0, str.tostring(score) + "/16", text_color = score >= scoreThresh ? colTeal : colGray, text_size = dashSz)
    f_cell(1,  "GATE: Stable / Reclaim", gateStable)
    f_cell(2,  "GATE: Above EMA9",       gateEma)
    f_cell(3,  "GATE: Delta > 0",        gateDelta)
    f_cell(4,  "Liq Sweep+Reclaim (3)",  sweepActive)
    f_cell(5,  "CVD Bull Div (3)",       cvdDivActive)
    f_cell(6,  "RSI Bull Div (2)",       rsiDivActive)
    f_cell(7,  "Sell Dry-Up (2)",        dryUp)
    f_cell(8,  "Absorption (2)",         absActive)
    f_cell(9,  "Higher Low (2)",         hlActive)
    f_cell(10, "Climax Watch (1)",       inWatch)
    f_cell(11, "Wick Confirmed (1)",     wickActive)
    f_cell(12, "Near Swing Low",         nearLow)

// ─────────────────────────── ALERTS ───────────────────────────
alertcondition(sellingClimax, "Selling Climax",       "SED: Selling climax")
alertcondition(sweepEvent,    "Liquidity Sweep",      "SED: Liquidity pool swept and reclaimed")
alertcondition(newExhaust,    "Seller Exhaustion",    "SED: Confirmed exhaustion")
alertcondition(invalidated,   "EXH Invalidated",      "SED: Exhaustion low broken")
alertcondition(newAccum,      "Accumulation Confirm", "SED: Accumulation confirmed")
````
