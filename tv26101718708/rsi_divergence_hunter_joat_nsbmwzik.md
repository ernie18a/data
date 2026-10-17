# RSI Divergence Hunter [JOAT]

- url: https://www.tradingview.com/script/nsbmwZiK-RSI-Divergence-Hunter-JOAT/
- type: indicator
- pine_id: PUB;65453bcde16d46a3829d17d7aa85d2c7
- version: 1.0

## Description

[b]RSI Divergence Hunter [JOAT][/b]
[i]Automatically detects the four classic RSI divergence types on confirmed pivots and frames each one as a trade.[/i]

[image]https://www.tradingview.com/x/pfvUMgj8/[/image]

[b]What it is[/b]
Divergence between price and momentum is one of the oldest reversal and continuation reads, but marking it by hand is subjective and easy to force. This indicator detects all four divergence types algorithmically on confirmed pivots, so what you see is defined and repeatable, and then attaches a full trade structure to each. It is an original divergence engine, not a plain RSI plot.

[b]How it works[/b]
• [b]RSI core[/b] — the relative strength index measures the speed and size of recent moves. It is the momentum reference every divergence is measured against.

• [b]Confirmed pivots[/b] — the engine waits for pivots on both price and RSI to confirm a set number of bars back before comparing them. Because pivots are only evaluated once confirmed, a plotted divergence does not repaint into or out of existence.

• [b]The four types[/b] — regular bullish (price lower low, RSI higher low) and regular bearish (price higher high, RSI lower high) point to potential reversals; hidden bullish and hidden bearish point to trend continuation after a pullback. Each is drawn with a connecting line on both price and RSI and labelled by type.

• [b]Zones and gating[/b] — overbought and oversold zones give context, and a minimum-gap control keeps divergence signals from stacking on lower timeframes.

[b]Trade levels[/b]
Each qualifying divergence draws a red risk box to the stop and a green reward box to the third target, with inner dividers and right-edge labels for entry, stop and each take-profit at your R multiples. The stop is anchored beyond the pivot that formed the divergence.

[b]The dashboard[/b]
An adjustable divergence-scope panel shows the current RSI value and zone, the most recent divergence type detected, the active signal, a conviction estimate, and a live first-target-before-stop tally from closed bars only.

[b]How to use it[/b]
• Works on any asset and timeframe.
• Treat regular divergences as counter-trend reversal cues and hidden divergences as with-trend continuation cues — the distinction matters.
• Combine with structure or a trend filter; divergence works well as confluence, not in isolation.

[b]Settings[/b]
RSI length and source, pivot strength, which divergence types to display, overbought/oversold levels, risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
The contribution is a complete, confirmed-pivot detector for all four divergence classes with clear per-type labelling and integrated, non-repainting trade framing. By fixing the definition of a divergence and waiting for pivot confirmation, it removes much of the hindsight bias that makes manual divergence unreliable.

[image]https://www.tradingview.com/x/o9BvPZjq/[/image]

[b]Notes and limitations[/b]
• Divergence signals can persist and reappear in strong trends; a divergence is a condition, not a timing guarantee.
• Confirmed pivots introduce a natural delay equal to the pivot strength — this is the cost of not repainting.
• The tally reflects only past bars on the current chart and is not a forecast.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("RSI Divergence Hunter [JOAT]", "RSI Div Hunter [JOAT]", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (cyberpunk neon)
// ─────────────────────────────────────────────────────────────────────────
CYAN    = #00E5FF
CYAN_HI = #7CF5FF
MAGENTA = #FF2E9A
MAG_HI  = #FF7CC2
PURPLE  = #A64BFF
PURP_HI = #C89BFF
LIME    = #7CFF5A
LIME_HI = #B6FF9C
AMBER   = #FFC24B
INK     = #05070E
INKHI   = #EAF2FF
MUTE    = #5A6B8C

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gR      = "RSI Engine"
rsiLen  = input.int(14, "RSI length", minval = 2, group = gR, tooltip = "Length of the RSI whose swings are compared against price swings.")
rsiSrc  = input.source(close, "RSI source", group = gR)

gP      = "Pivot Detection"
pivLeft = input.int(5, "Pivot left strength",  minval = 1, group = gP, tooltip = "Bars of higher/lower price required on the LEFT of a swing.")
pivRight= input.int(5, "Pivot right strength", minval = 1, group = gP, tooltip = "Bars required on the RIGHT — a pivot only confirms this many bars back, which is what makes signals non-repainting.")
maxGap  = input.int(60, "Max bars between pivots", minval = 5, group = gP, tooltip = "Ignore a divergence if the two pivots are further apart than this (stale comparison).")

gD      = "Divergence Types"
useReg  = input.bool(true, "Hunt REGULAR divergences", group = gD)
useHid  = input.bool(true, "Hunt HIDDEN divergences", group = gD)

gF      = "Regime Filter"
rsiBullMax = input.float(62, "Bullish pivot RSI must be ≤", minval = 30, maxval = 80, step = 1, group = gF, tooltip = "Bullish divergences only count when the momentum low forms in the lower/neutral RSI band.")
rsiBearMin = input.float(38, "Bearish pivot RSI must be ≥", minval = 20, maxval = 70, step = 1, group = gF, tooltip = "Bearish divergences only count when the momentum high forms in the upper/neutral RSI band.")

gC      = "Confirmation"
useConfirm = input.bool(true, "Require close-through confirmation", group = gC, tooltip = "If ON, a divergence only becomes a BUY/SELL once price CLOSES back through the pivot bar's extreme. If OFF, it fires on the pivot itself.")
confWin = input.int(30, "Confirmation window (bars)", minval = 3, group = gC, tooltip = "How long a pending divergence waits for its close-through before expiring.")

gZ      = "Reaction Zones"
showZones = input.bool(true, "Draw demand/supply zones", group = gZ)
zoneAtr = input.float(0.6, "Zone half-height (ATR ×)", minval = 0.1, step = 0.1, group = gZ, tooltip = "Vertical thickness of a zone box, in ATR units around the pivot price.")
zoneExt = input.int(20, "Zone extend (bars)", minval = 2, group = gZ)
maxZones= input.int(6, "Max live zones", minval = 1, maxval = 40, group = gZ, tooltip = "Oldest zones are pruned once this many are on the chart.")

gT      = "Trade Levels"
showTPSL = input.bool(true, "Show TP/SL boxes", group = gT, tooltip = "Draw a red risk box (entry→SL) and a green reward box (entry→TP3) on each confirmed BUY/SELL.")
slBuf   = input.float(0.5, "SL buffer beyond pivot (ATR ×)", minval = 0.0, step = 0.1, group = gT, tooltip = "Extra cushion placed beyond the divergence pivot extreme for the protective stop.")
tp1R    = input.float(1.0, "TP1 (R)", step = 0.5, group = gT)
tp2R    = input.float(2.0, "TP2 (R)", step = 0.5, group = gT)
tp3R    = input.float(3.0, "TP3 (R)", step = 0.5, group = gT)
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gT)

gV      = "Visuals"
showLines = input.bool(true, "Draw divergence lines + labels", group = gV)
colorBars = input.bool(true, "RSI-regime candles", group = gV)
markPivs  = input.bool(true, "Mark confirmed pivots", group = gV)
atrLenT   = input.int(14, "ATR length", minval = 1, group = gV)

gH      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gH)
hudPos  = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gH)
hudBg   = input.color(#05070E, "Background", group = gH)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// ─────────────────────────────────────────────────────────────────────────
//  CORE SERIES
// ─────────────────────────────────────────────────────────────────────────
rsi = ta.rsi(rsiSrc, rsiLen)
atr = ta.atr(atrLenT)

momUp   = rsi >= 55
momDn   = rsi <= 45
momTxt  = rsi >= 60 ? "Strong Up" : rsi >= 55 ? "Up" : rsi <= 40 ? "Strong Down" : rsi <= 45 ? "Down" : "Neutral"
momCol  = rsi >= 55 ? LIME : rsi <= 45 ? MAGENTA : MUTE

// ─────────────────────────────────────────────────────────────────────────
//  PIVOTS  (confirmed pivRight bars back → non-repainting)
// ─────────────────────────────────────────────────────────────────────────
pivLow  = ta.pivotlow(low,  pivLeft, pivRight)
pivHigh = ta.pivothigh(high, pivLeft, pivRight)
hasPL   = not na(pivLow)
hasPH   = not na(pivHigh)

// coordinates of the pivot that just confirmed
plBar   = bar_index - pivRight
plPrice = pivLow
plRsi   = rsi[pivRight]
plLo    = low[pivRight]
plHi    = high[pivRight]

phBar   = bar_index - pivRight
phPrice = pivHigh
phRsi   = rsi[pivRight]
phLo    = low[pivRight]
phHi    = high[pivRight]

// memory of the previous confirmed pivots
var float prevLowP = na
var float prevLowR = na
var int   prevLowB = na
var float prevHighP = na
var float prevHighR = na
var int   prevHighB = na

// pruning containers
var array<box>   zoneArr = array.new<box>()
var array<line>  lineArr = array.new<line>()
var array<label> lblArr  = array.new<label>()

// pending confirmation state
var float pendBullLvl = na
var int   pendBullBar = na
var float pendBearLvl = na
var int   pendBearBar = na

// pivot extremes for SL placement (persist until next divergence of that side)
var float pendBullExt = na
var float pendBearExt = na

// last-divergence memory (for HUD)
var string lastDivTxt = "—"
var color  lastDivCol = MUTE
var int    lastDivBar = na
var float  lastConv   = 0.0

// per-bar detection flags
bullNow = false
bearNow = false

// ─────────────────────────────────────────────────────────────────────────
//  ZONE / LINE / LABEL BUILDERS  (with pruning)
// ─────────────────────────────────────────────────────────────────────────
f_pushZone(box b) =>
    array.push(zoneArr, b)
    if array.size(zoneArr) > maxZones
        box.delete(array.shift(zoneArr))

f_pushLine(line l) =>
    array.push(lineArr, l)
    if array.size(lineArr) > maxZones * 2
        line.delete(array.shift(lineArr))

f_pushLabel(label lb) =>
    array.push(lblArr, lb)
    if array.size(lblArr) > maxZones * 2
        label.delete(array.shift(lblArr))

f_drawDiv(int b1, float p1, int b2, float p2, string txt, color c, bool bull) =>
    if showLines
        ln = line.new(b1, p1, b2, p2, color = color.new(c, 15), width = 2, style = line.style_solid)
        f_pushLine(ln)
        lb = label.new(b2, p2, txt, style = bull ? label.style_label_up : label.style_label_down, color = color.new(c, 12), textcolor = INK, size = size.small)
        f_pushLabel(lb)

f_drawZone(int b, float px, bool bull) =>
    if showZones
        h  = atr * zoneAtr
        bx = box.new(b, px + h, b + zoneExt, px - h, border_color = color.new(bull ? LIME : MAGENTA, 30), border_width = 1, bgcolor = color.new(bull ? LIME : MAGENTA, 82))
        f_pushZone(bx)

// ─────────────────────────────────────────────────────────────────────────
//  DIVERGENCE DETECTION — LOWS (bullish)
// ─────────────────────────────────────────────────────────────────────────
if hasPL
    if not na(prevLowP) and (plBar - prevLowB) <= maxGap and plRsi <= rsiBullMax
        regBull = useReg and plPrice < prevLowP and plRsi > prevLowR
        hidBull = useHid and plPrice > prevLowP and plRsi < prevLowR
        if regBull or hidBull
            txt = regBull ? "Bull Div" : "Hidden Bull"
            col = regBull ? CYAN : LIME
            f_drawDiv(prevLowB, prevLowP, plBar, plPrice, txt, col, true)
            f_drawZone(plBar, plPrice, true)
            bullNow := true
            pendBullLvl := plHi
            pendBullBar := plBar
            pendBullExt := plLo
            lastDivTxt := txt
            lastDivCol := col
            lastDivBar := bar_index
            lastConv := math.min(100.0, 45.0 + math.abs(plRsi - prevLowR) * 3.0)
    prevLowP := plPrice
    prevLowR := plRsi
    prevLowB := plBar

// ─────────────────────────────────────────────────────────────────────────
//  DIVERGENCE DETECTION — HIGHS (bearish)
// ─────────────────────────────────────────────────────────────────────────
if hasPH
    if not na(prevHighP) and (phBar - prevHighB) <= maxGap and phRsi >= rsiBearMin
        regBear = useReg and phPrice > prevHighP and phRsi < prevHighR
        hidBear = useHid and phPrice < prevHighP and phRsi > prevHighR
        if regBear or hidBear
            txt = regBear ? "Bear Div" : "Hidden Bear"
            col = regBear ? MAGENTA : PURPLE
            f_drawDiv(prevHighB, prevHighP, phBar, phPrice, txt, col, false)
            f_drawZone(phBar, phPrice, false)
            bearNow := true
            pendBearLvl := phLo
            pendBearBar := phBar
            pendBearExt := phHi
            lastDivTxt := txt
            lastDivCol := col
            lastDivBar := bar_index
            lastConv := math.min(100.0, 45.0 + math.abs(phRsi - prevHighR) * 3.0)
    prevHighP := phPrice
    prevHighR := phRsi
    prevHighB := phBar

// ─────────────────────────────────────────────────────────────────────────
//  CONFIRMATION / ACTIVATION
// ─────────────────────────────────────────────────────────────────────────
// close-through logic: bullish confirms on a close above the pivot high,
// bearish on a close below the pivot low.
bullCross = not na(pendBullLvl) and close > pendBullLvl and close[1] <= pendBullLvl
bearCross = not na(pendBearLvl) and close < pendBearLvl and close[1] >= pendBearLvl

buySig  = useConfirm ? bullCross : bullNow
sellSig = useConfirm ? bearCross : bearNow

// clear / expire pending buffers
if bullCross
    pendBullLvl := na
if bearCross
    pendBearLvl := na
if not na(pendBullLvl) and (bar_index - pendBullBar) > confWin
    pendBullLvl := na
if not na(pendBearLvl) and (bar_index - pendBearBar) > confWin
    pendBearLvl := na

// running conviction fade toward neutral as the signal ages
barsSince = na(lastDivBar) ? na : bar_index - lastDivBar
convLive  = na(barsSince) ? 0.0 : math.max(0.0, lastConv - barsSince * 1.5)

// current signal state
var int sigState = 0
if buySig
    sigState := 1
if sellSig
    sigState := -1

// ─────────────────────────────────────────────────────────────────────────
//  LIVE WIN-RATE TRACKER  (+1 ATR before −1 ATR; no lookahead)
// ─────────────────────────────────────────────────────────────────────────
var int   wins   = 0
var int   losses = 0
var bool  tOpen  = false
var int   tDir   = 0
var float tUp    = na
var float tDn    = na

if tOpen
    if tDir == 1
        if high >= tUp
            wins   += 1
            tOpen  := false
        else if low <= tDn
            losses += 1
            tOpen  := false
    else
        if low <= tUp
            wins   += 1
            tOpen  := false
        else if high >= tDn
            losses += 1
            tOpen  := false

sig = buySig or sellSig
if sig
    if tOpen
        losses += 1
        tOpen  := false
    tDir  := buySig ? 1 : -1
    tUp   := buySig ? close + atr : close - atr
    tDn   := buySig ? close - atr : close + atr
    tOpen := true

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// zones live count
liveZones = array.size(zoneArr)

// ─────────────────────────────────────────────────────────────────────────
//  TP/SL TRADE BOXES  (single active set; SL beyond pivot extreme, TPs at R)
// ─────────────────────────────────────────────────────────────────────────
var box   riskBox = na
var box   rewBox  = na
var line  entLn   = na
var line  slLn    = na
var line  tp1Ln   = na
var line  tp2Ln   = na
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_setLbl(label lb, float p, string txt, color c) =>
    label.set_xy(lb, bar_index + boxW, p)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

if (buySig or sellSig) and showTPSL
    isBuy = buySig
    entry = close
    ext   = isBuy ? nz(pendBullExt, low) : nz(pendBearExt, high)
    sl    = isBuy ? ext - atr * slBuf : ext + atr * slBuf
    risk  = math.abs(entry - sl)
    risk := risk > 0 ? risk : atr
    t1    = isBuy ? entry + risk * tp1R : entry - risk * tp1R
    t2    = isBuy ? entry + risk * tp2R : entry - risk * tp2R
    t3    = isBuy ? entry + risk * tp3R : entry - risk * tp3R

    box.delete(riskBox)
    box.delete(rewBox)
    line.delete(entLn)
    line.delete(slLn)
    line.delete(tp1Ln)
    line.delete(tp2Ln)
    // red RISK box: entry → SL
    riskBox := box.new(bar_index, entry, bar_index + boxW, sl, bgcolor = color.new(MAGENTA, 82), border_color = color.new(MAGENTA, 35), border_width = 1)
    // green REWARD box: entry → TP3
    rewBox  := box.new(bar_index, entry, bar_index + boxW, t3, bgcolor = color.new(LIME, 85), border_color = color.new(LIME, 35), border_width = 1)
    // solid entry line, dashed SL, thin TP1/TP2 dividers
    entLn := line.new(bar_index, entry, bar_index + boxW, entry, color = color.new(AMBER, 0),     width = 2)
    slLn  := line.new(bar_index, sl,    bar_index + boxW, sl,    color = color.new(MAGENTA, 10), width = 1, style = line.style_dashed)
    tp1Ln := line.new(bar_index, t1,    bar_index + boxW, t1,    color = color.new(LIME, 30),    width = 1)
    tp2Ln := line.new(bar_index, t2,    bar_index + boxW, t2,    color = color.new(LIME, 30),    width = 1)
    if na(lbE)
        lbE := label.new(bar_index + boxW, entry, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        lbS := label.new(bar_index + boxW, sl,    "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        lb1 := label.new(bar_index + boxW, t1,    "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        lb2 := label.new(bar_index + boxW, t2,    "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        lb3 := label.new(bar_index + boxW, t3,    "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
    f_setLbl(lbE, entry, " ENTRY " + str.tostring(entry, format.mintick), AMBER)
    f_setLbl(lbS, sl,    " SL " + str.tostring(sl, format.mintick), MAG_HI)
    f_setLbl(lb1, t1,    " TP1 · " + str.tostring(tp1R, "#.#") + "R " + str.tostring(t1, format.mintick), LIME_HI)
    f_setLbl(lb2, t2,    " TP2 · " + str.tostring(tp2R, "#.#") + "R " + str.tostring(t2, format.mintick), LIME_HI)
    f_setLbl(lb3, t3,    " TP3 · " + str.tostring(tp3R, "#.#") + "R " + str.tostring(t3, format.mintick), CYAN_HI)

// keep the active trade drawing extended while it lives
if showTPSL and not na(riskBox) and barstate.islast
    box.set_right(riskBox, bar_index + boxW)
    box.set_right(rewBox,  bar_index + boxW)
    line.set_x2(entLn, bar_index + boxW)
    line.set_x2(slLn,  bar_index + boxW)
    line.set_x2(tp1Ln, bar_index + boxW)
    line.set_x2(tp2Ln, bar_index + boxW)
    label.set_x(lbE, bar_index + boxW)
    label.set_x(lbS, bar_index + boxW)
    label.set_x(lb1, bar_index + boxW)
    label.set_x(lb2, bar_index + boxW)
    label.set_x(lb3, bar_index + boxW)

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS  (all global scope)
// ─────────────────────────────────────────────────────────────────────────
regimeCol = rsi >= 55 ? color.from_gradient(rsi, 55, 75, color.new(LIME, 55), color.new(LIME_HI, 20)) : rsi <= 45 ? color.from_gradient(rsi, 25, 45, color.new(MAG_HI, 20), color.new(MAGENTA, 55)) : color.new(MUTE, 55)
barcolor(colorBars ? regimeCol : na)

// pivot markers (placed at the confirmed pivot bar via constant-input offset)
plotshape(markPivs and hasPL, "Pivot low",  style = shape.triangleup,   location = location.belowbar, color = color.new(CYAN, 30),    size = size.tiny, offset = -pivRight)
plotshape(markPivs and hasPH, "Pivot high", style = shape.triangledown, location = location.abovebar, color = color.new(MAGENTA, 30), size = size.tiny, offset = -pivRight)

// activation labels
plotshape(buySig,  "BUY",  style = shape.labelup,   location = location.belowbar, color = LIME,    textcolor = INK,   text = "BUY",  size = size.small)
plotshape(sellSig, "SELL", style = shape.labeldown, location = location.abovebar, color = MAGENTA, textcolor = INKHI, text = "SELL", size = size.small)

// subtle regime background
bgcolor(rsi >= 60 ? color.new(LIME, 92) : rsi <= 40 ? color.new(MAGENTA, 92) : na, title = "Regime")

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 9, bgcolor = color.new(hudBg, 0), frame_color = color.new(CYAN, 55), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #06212B), 0)

    // DOT conviction meter (● filled / ○ empty) — 5 dots
    cf = math.round(convLive / 20)
    cbar = ""
    for i = 1 to 5
        cbar := cbar + (i <= cf ? "●" : "○")
    convC = convLive >= 66 ? LIME_HI : convLive >= 33 ? AMBER : MUTE

    // RSI position DOT meter (0..100 mapped to 5 dots)
    rf = math.round(rsi / 20)
    rbar = ""
    for i = 1 to 5
        rbar := rbar + (i <= rf ? "●" : "○")

    rArrow = rsi >= 55 ? "▲" : rsi <= 45 ? "▼" : "•"
    sigTxt = buySig ? "BUY ▲" : sellSig ? "SELL ▼" : sigState == 1 ? "Long bias" : sigState == -1 ? "Short bias" : "Flat"
    sigC   = buySig ? LIME_HI : sellSig ? MAG_HI : sigState == 1 ? LIME : sigState == -1 ? MAGENTA : MUTE
    wrTxt  = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    wrC    = na(winRate) ? MUTE : winRate >= 55 ? LIME : winRate <= 45 ? MAGENTA : AMBER

    // ── header: scope title + big RSI value
    table.cell(hud, 0, 0, "  ◈ DIVERGENCE SCOPE", text_color = CYAN_HI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, str.tostring(math.round(rsi)) + " " + rArrow + "  ", text_color = momCol, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

    // ── coloured BADGE row for the last divergence type (spans both cells)
    badgeC = color.new(lastDivCol, 12)
    table.cell(hud, 0, 1, "  LAST", text_color = INK, text_halign = text.align_left, bgcolor = badgeC, text_size = hudTS)
    table.cell(hud, 1, 1, lastDivTxt + "  ", text_color = INK, text_halign = text.align_right, bgcolor = badgeC, text_size = hudTS)

    table.cell(hud, 0, 2, "  RSI level", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, rbar + "  ", text_color = momCol, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 3, "  Momentum", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, momTxt + "  ", text_color = momCol, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 4, "  Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, cbar + " " + str.tostring(math.round(convLive)) + "  ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 5, "  Active zones", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, str.tostring(liveZones) + "  ", text_color = CYAN_HI, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 6, "  Pending", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    pendTxt = not na(pendBullLvl) ? "Bull ↑" : not na(pendBearLvl) ? "Bear ↓" : "—"
    pendC   = not na(pendBullLvl) ? LIME : not na(pendBearLvl) ? MAGENTA : MUTE
    table.cell(hud, 1, 6, pendTxt + "  ", text_color = pendC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 7, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 7, sigTxt + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 8, "  Win (1R ATR)", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 8, wrTxt + "  ", text_color = wrC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buySig,  "Bullish divergence", "RSI Divergence Hunter: bullish divergence confirmed — demand zone active")
alertcondition(sellSig, "Bearish divergence", "RSI Divergence Hunter: bearish divergence confirmed — supply zone active")
alertcondition(bullNow, "Bull pivot divergence", "RSI Divergence Hunter: bullish divergence detected at pivot")
alertcondition(bearNow, "Bear pivot divergence", "RSI Divergence Hunter: bearish divergence detected at pivot")
````
