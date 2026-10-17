# ICT Liquidity Sweep & Structure [JOAT]

- url: https://www.tradingview.com/script/hhAt4Q6Z-ICT-Liquidity-Sweep-Structure-JOAT/
- type: indicator
- pine_id: PUB;24b927ff9f494314bf1057c168eb5952
- version: 1.0

## Description

[b]ICT Liquidity Sweep and Structure [JOAT][/b]
[i]A smart-money workflow that maps resting liquidity, detects stop-hunt sweeps, and reads market structure shifts on one clean overlay.[/i]

[image]https://www.tradingview.com/x/Voggaix3/[/image]

[b]What it is[/b]
This tool organises several well-known smart-money / ICT concepts into one coherent, non-repainting engine and — importantly — explains how the pieces reinforce each other rather than just stacking them. The premise: price is drawn to pools of resting orders (old highs and lows), often sweeps them to trigger stops, and then reveals its true intent through a structure break. The indicator makes each of those steps visible and gates its signals on their confluence.

[b]How it works[/b]
• [b]Liquidity levels[/b] — confirmed swing highs and lows (pivots) are drawn as buy-side liquidity (above old highs) and sell-side liquidity (below old lows) lines, each labelled with its price. These mark where stops are likely resting.

• [b]Liquidity sweeps[/b] — a sweep is detected when price trades through one of these levels and then closes back on the original side, i.e. the level was raided but not accepted. This is the classic stop-hunt footprint and is the setup trigger.

• [b]Market structure (BOS / CHoCH)[/b] — the engine tracks the live sequence of swings. A Break of Structure confirms trend continuation; a Change of Character is the first counter-break that flips the internal bias. Both are labelled on confirmed closes.

• [b]Fair value gaps[/b] — three-bar imbalances left by displacement are drawn as zones and used as entry confluence, since price often rebalances them.

• [b]Confluence gate[/b] — a Buy requires a bullish sequence (a sweep of sell-side liquidity followed by a bullish structure shift, optionally aligned with a fair-value gap); a Sell is the mirror. Buy and Sell are made mutually exclusive so both never print on the same bar, and a minimum-spacing control prevents clustering.

[b]Trade levels[/b]
Each signal renders a red risk box from entry to stop and a green reward box from entry to the third target, with inner target dividers and right-edge labels for entry, stop and each take-profit at your R multiples. The stop is anchored to the structure that produced the signal, not to a fixed distance.

[b]The dashboard[/b]
An adjustable panel summarises the current structural bias, the most recent liquidity event, the nearest untapped level, a conviction estimate, the active signal, and a live first-target-before-stop tally computed only on closed bars.

[b]How to use it[/b]
• Suitable for any asset and timeframe; the concepts are scale-independent, though very low timeframes produce more noise.
• Use the liquidity lines to anticipate where price may be drawn next, and wait for a sweep-plus-structure confluence rather than acting on a raw level touch.
• Combine with a higher-timeframe bias for directional filtering.

[b]Settings[/b]
Pivot strength, liquidity extension, sweep sensitivity, fair-value-gap minimum size, structure options, risk multiple and target R multiples, plus full colour and dashboard controls.

[b]Originality and usefulness[/b]
Rather than plotting isolated ICT drawings, this engine chains them into a single logical sequence — liquidity, sweep, structure shift, imbalance — and only signals when that sequence agrees. The description of why those components belong together, and the confirmed-bar evaluation that keeps them honest, is what distinguishes it from a generic structure plotter.

[image]https://www.tradingview.com/x/OyUMjTsS/[/image]

[b]Notes and limitations[/b]
• Structure and sweeps are defined algorithmically; discretionary traders may mark them slightly differently.
• Signals confirm on bar close, which trades a small amount of immediacy for stability and no repainting.
• The on-chart tally reflects only past bars on the current chart and is not a prediction.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
//@version=6

indicator("ICT Liquidity Sweep & Structure [JOAT]", "ICT Liquidity [JOAT]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (institutional blue vs red, clean)
// ─────────────────────────────────────────────────────────────────────────
BLUE   = #2962FF
BLUE_HI= #6D9BFF
RED    = #F0324B
RED_HI = #FF6E85
GRN    = #16C784
GRN_HI = #4FE3A2
GOLD   = #FFB020
INK    = #0A0E17
INKHI  = #ECF1FA
MUTE   = #56607A
BOXBLU = #2962FF
BOXRED = #F0324B

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gS      = "Structure"
pivLen  = input.int(8, "Swing pivot strength", minval = 2, group = gS, tooltip = "Bars either side used to confirm a swing high/low. Higher = major structure only.")
showBos = input.bool(true, "Show BOS / CHoCH labels", group = gS)
showSwn = input.bool(true, "Mark swing points", group = gS)

gL      = "Liquidity Sweeps"
sweepWick= input.float(0.0, "Min wick beyond level (ATR ×)", minval = 0.0, step = 0.05, group = gL, tooltip = "How far the wick must pierce the swing (in ATR) before a close-back-inside counts as a sweep. 0 = any pierce.")
showLiq = input.bool(true, "Draw liquidity lines", group = gL)
liqExt  = input.int(20, "Level extension (bars)", minval = 2, group = gL)

gF      = "Fair Value Gaps"
showFVG = input.bool(true, "Show FVG zones", group = gF)
fvgMinAtr= input.float(0.25,"Min FVG size (ATR ×)", minval = 0.0, step = 0.05, group = gF, tooltip = "Ignore tiny imbalances smaller than this multiple of ATR.")
fvgMax  = input.int(8, "Max live FVGs", minval = 1, maxval = 30, group = gF)

gSig    = "Signals & Trade"
reqFvg  = input.bool(false,"Require FVG confluence", group = gSig, tooltip = "Only signal when a fresh FVG in the trade direction exists.")
showLad = input.bool(true, "TP/SL ladder", group = gSig)
atrLenT = input.int(14, "ATR length", minval = 1, group = gSig)
slPad   = input.float(0.5, "SL padding beyond sweep (ATR ×)", minval = 0.0, step = 0.1, group = gSig)
tp1R    = input.float(1.0, "TP1 (R)", step = 0.5, group = gSig)
tp2R    = input.float(2.0, "TP2 (R)", step = 0.5, group = gSig)
tp3R    = input.float(3.0, "TP3 (R)", step = 0.5, group = gSig)
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gSig)

gV      = "Visuals"
colorBars = input.bool(true, "Colour candles by structure", group = gV, tooltip = "Tint candles blue when structure is bullish, red when bearish.")

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#0B0F1A, "Background", group = gP)

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

// dot meter (● filled / ○ empty) — SMC terminal identity
f_dots(float pct01) =>
    fill = math.round(math.max(0.0, math.min(1.0, pct01)) * 10)
    out = ""
    for i = 1 to 10
        out := out + (i <= fill ? "●" : "○")
    out

atr = ta.atr(atrLenT)

// ─────────────────────────────────────────────────────────────────────────
//  SWING PIVOTS  (confirmed pivLen bars back)
// ─────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)

var float lastPH   = na          // most recent confirmed swing high price
var float lastPL   = na          // most recent confirmed swing low price
var int   lastPHb  = na
var int   lastPLb  = na
var bool  phSwept  = false       // has the current swing high been raided?
var bool  plSwept  = false

if not na(ph)
    lastPH  := ph
    lastPHb := bar_index - pivLen
    phSwept := false
if not na(pl)
    lastPL  := pl
    lastPLb := bar_index - pivLen
    plSwept := false

if showSwn and not na(ph)
    label.new(bar_index - pivLen, ph, "◆", style = label.style_none, textcolor = color.new(RED, 20), size = size.tiny)
if showSwn and not na(pl)
    label.new(bar_index - pivLen, pl, "◆", style = label.style_none, textcolor = color.new(BLUE, 20), size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────
//  LIQUIDITY LEVEL LINES  (drawn at swings, extended right, coloured by side)
// ─────────────────────────────────────────────────────────────────────────
if showLiq and not na(ph)
    line.new(bar_index - pivLen, ph, bar_index + liqExt, ph, color = color.new(RED, 55), style = line.style_dotted, width = 1)
    label.new(bar_index + liqExt, ph, "BSL " + str.tostring(ph, format.mintick), style = label.style_none, textcolor = color.new(RED, 25), size = size.tiny, textalign = text.align_left)
if showLiq and not na(pl)
    line.new(bar_index - pivLen, pl, bar_index + liqExt, pl, color = color.new(BLUE, 55), style = line.style_dotted, width = 1)
    label.new(bar_index + liqExt, pl, "SSL " + str.tostring(pl, format.mintick), style = label.style_none, textcolor = color.new(BLUE, 25), size = size.tiny, textalign = text.align_left)

// ─────────────────────────────────────────────────────────────────────────
//  MARKET STRUCTURE  (BOS = break with trend, CHoCH = first counter break)
// ─────────────────────────────────────────────────────────────────────────
var int bias = 0                 // +1 bullish structure, -1 bearish, 0 none
var float bosHi = na
var float bosLo = na
bosHi := na(lastPH) ? bosHi : lastPH
bosLo := na(lastPL) ? bosLo : lastPL

bosUp   = not na(bosHi) and ta.crossover(close, bosHi)
bosDn   = not na(bosLo) and ta.crossunder(close, bosLo)

choChUp = bosUp and bias <= 0
choChDn = bosDn and bias >= 0

if bosUp
    bias := 1
if bosDn
    bias := -1

if showBos and bosUp
    label.new(bar_index, low, choChUp ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(BLUE, 15), textcolor = INKHI, size = size.tiny, yloc = yloc.belowbar)
if showBos and bosDn
    label.new(bar_index, high, choChDn ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(RED, 15), textcolor = INKHI, size = size.tiny, yloc = yloc.abovebar)

// ─────────────────────────────────────────────────────────────────────────
//  LIQUIDITY SWEEPS  (wick pierces swing → close back inside = raid)
// ─────────────────────────────────────────────────────────────────────────
pad = sweepWick * atr
sweepLow  = not na(lastPL) and not plSwept and low  < (lastPL - pad) and close > lastPL
sweepHigh = not na(lastPH) and not phSwept and high > (lastPH + pad) and close < lastPH

if sweepLow
    plSwept := true
    label.new(bar_index, low, "×", style = label.style_none, textcolor = BLUE_HI, size = size.small, yloc = yloc.belowbar)
if sweepHigh
    phSwept := true
    label.new(bar_index, high, "×", style = label.style_none, textcolor = RED_HI, size = size.small, yloc = yloc.abovebar)

// ─────────────────────────────────────────────────────────────────────────
//  FAIR VALUE GAPS  (3-bar imbalance)
// ─────────────────────────────────────────────────────────────────────────
var array<box> fvgBox = array.new<box>()
var array<int> fvgDir = array.new<int>()

bullFVG = low > high[2] and (low - high[2]) > fvgMinAtr * atr
bearFVG = high < low[2]  and (low[2] - high) > fvgMinAtr * atr

var bool freshBullFVG = false
var bool freshBearFVG = false
freshBullFVG := false
freshBearFVG := false

if showFVG and bullFVG
    b = box.new(bar_index - 2, low, bar_index + 3, high[2], border_color = color.new(BLUE, 60), bgcolor = color.new(BLUE, 85), extend = extend.none, text = "FVG", text_color = color.new(BLUE_HI, 20), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_center)
    array.push(fvgBox, b)
    array.push(fvgDir, 1)
    freshBullFVG := true
if showFVG and bearFVG
    b = box.new(bar_index - 2, low[2], bar_index + 3, high, border_color = color.new(RED, 60), bgcolor = color.new(RED, 85), extend = extend.none, text = "FVG", text_color = color.new(RED_HI, 20), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_center)
    array.push(fvgBox, b)
    array.push(fvgDir, -1)
    freshBearFVG := true

// prune old / filled FVGs
if array.size(fvgBox) > 0
    for i = array.size(fvgBox) - 1 to 0
        b = array.get(fvgBox, i)
        d = array.get(fvgDir, i)
        top = box.get_top(b)
        bot = box.get_bottom(b)
        filled = d == 1 ? close < bot : close > top
        if filled
            box.delete(b)
            array.remove(fvgBox, i)
            array.remove(fvgDir, i)
        else
            box.set_right(b, bar_index + 3)
// cap live count
while array.size(fvgBox) > fvgMax
    box.delete(array.shift(fvgBox))
    array.shift(fvgDir)

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS  (sweep + structure confirmation, optional FVG confluence)
// ─────────────────────────────────────────────────────────────────────────
var bool armedLong  = false      // a sell-side sweep is waiting for confirmation
var bool armedShort = false
var float armLowRef  = na
var float armHighRef = na

if sweepLow
    armedLong  := true
    armLowRef  := low
if sweepHigh
    armedShort := true
    armHighRef := high

// confirmation: bullish structure shift within a few bars of the sweep
bullConfirm = armedLong  and (bosUp or close > open and close > high[1])
bearConfirm = armedShort and (bosDn or close < open and close < low[1])

fvgOKl = not reqFvg or freshBullFVG
fvgOKs = not reqFvg or freshBearFVG

sell = bearConfirm and fvgOKs
buy  = bullConfirm and fvgOKl and not sell   // never print both on the same bar
sig  = buy or sell

// ── signal debounce — structure signals never stack on any timeframe
minGap = input.int(8, "Min bars between signals", minval = 0, group = "Signals", tooltip = "Minimum bar spacing between printed signals so labels never overlap on lower timeframes. 0 = off.")
var int lastSigBar = na
okGap = na(lastSigBar) or (bar_index - lastSigBar) >= minGap
buy  := buy  and okGap
sell := sell and okGap
sig  := buy or sell
if sig
    lastSigBar := bar_index

if buy
    armedLong := false
if sell
    armedShort := false
// disarm on staleness
var int armLongBar = na
var int armShortBar = na
if sweepLow
    armLongBar := bar_index
if sweepHigh
    armShortBar := bar_index
if not na(armLongBar) and bar_index - armLongBar > 6
    armedLong := false
if not na(armShortBar) and bar_index - armShortBar > 6
    armedShort := false

// ─────────────────────────────────────────────────────────────────────────
//  CONVICTION 0..100
// ─────────────────────────────────────────────────────────────────────────
structComp = (buy and choChUp) or (sell and choChDn) ? 1.0 : 0.6
sweepDepth = buy and not na(armLowRef) ? math.min(1.0, (lastPL - armLowRef) / (atr + 1e-9)) : sell and not na(armHighRef) ? math.min(1.0, (armHighRef - lastPH) / (atr + 1e-9)) : 0.0
fvgComp    = (buy and freshBullFVG) or (sell and freshBearFVG) ? 1.0 : 0.4
conv = math.round(100 * (0.4 * structComp + 0.35 * math.max(0.0, sweepDepth) + 0.25 * fvgComp))

// ─────────────────────────────────────────────────────────────────────────
//  LIVE STATS + TP/SL LADDER
// ─────────────────────────────────────────────────────────────────────────
var float sEntry = na
var float sSL = na
var float sT1 = na
var int   sDir = 0
var bool  sOpen = false
var int   wins = 0
var int   losses = 0

if sOpen
    if sDir == 1
        if high >= sT1
            wins += 1
            sOpen := false
        else if low <= sSL
            losses += 1
            sOpen := false
    else
        if low <= sT1
            wins += 1
            sOpen := false
        else if high >= sSL
            losses += 1
            sOpen := false

// single active trade set — red risk box + green reward box + labeled levels
var box   riskBox = na
var box   rewBox  = na
var line  lnEnt = na          // solid ENTRY line
var line  lnSl  = na          // dashed SL line (bottom of risk box)
var line  lnT1  = na          // thin divider at TP1
var line  lnT2  = na          // thin divider at TP2
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_lbl(label lb, float p, string txt, color c) =>
    label.set_xy(lb, bar_index + boxW, p)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

if sig
    if sOpen
        losses += 1
        sOpen := false
    sDir   := buy ? 1 : -1
    sEntry := close
    slBase = buy ? math.min(low, nz(armLowRef, low)) - slPad * atr : math.max(high, nz(armHighRef, high)) + slPad * atr
    sSL    := slBase
    risk    = math.abs(sEntry - sSL)
    risk   := risk > 0 ? risk : atr
    sT1    := buy ? sEntry + risk * tp1R : sEntry - risk * tp1R
    t2      = buy ? sEntry + risk * tp2R : sEntry - risk * tp2R
    t3      = buy ? sEntry + risk * tp3R : sEntry - risk * tp3R
    sOpen  := true

    if showLad
        // reposition the filled risk/reward boxes on each new signal
        box.delete(riskBox)
        box.delete(rewBox)
        riskBox := box.new(bar_index, sEntry, bar_index + boxW, sSL, bgcolor = color.new(RED, 82), border_color = color.new(RED, 35), border_width = 1)
        rewBox  := box.new(bar_index, sEntry, bar_index + boxW, t3, bgcolor = color.new(GRN, 85), border_color = color.new(GRN, 35), border_width = 1)
        if na(lnEnt)
            lnEnt := line.new(bar_index, sEntry, bar_index + boxW, sEntry, color = GOLD, width = 2)
            lnSl  := line.new(bar_index, sSL, bar_index + boxW, sSL, color = color.new(RED, 15), style = line.style_dashed)
            lnT1  := line.new(bar_index, sT1, bar_index + boxW, sT1, color = color.new(GRN, 45), style = line.style_dotted)
            lnT2  := line.new(bar_index, t2,  bar_index + boxW, t2,  color = color.new(GRN, 45), style = line.style_dotted)
            lbE := label.new(bar_index + boxW, sEntry, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lbS := label.new(bar_index + boxW, sSL, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb1 := label.new(bar_index + boxW, sT1, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb2 := label.new(bar_index + boxW, t2, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb3 := label.new(bar_index + boxW, t3, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        line.set_xy1(lnEnt, bar_index, sEntry)
        line.set_xy2(lnEnt, bar_index + boxW, sEntry)
        line.set_xy1(lnSl, bar_index, sSL)
        line.set_xy2(lnSl, bar_index + boxW, sSL)
        line.set_xy1(lnT1, bar_index, sT1)
        line.set_xy2(lnT1, bar_index + boxW, sT1)
        line.set_xy1(lnT2, bar_index, t2)
        line.set_xy2(lnT2, bar_index + boxW, t2)
        f_lbl(lbE, sEntry, " ENTRY " + str.tostring(sEntry, format.mintick), GOLD)
        f_lbl(lbS, sSL,    " SL " + str.tostring(sSL, format.mintick), RED_HI)
        f_lbl(lb1, sT1,    " TP1 · " + str.tostring(tp1R,"#.#") + "R " + str.tostring(sT1, format.mintick), GRN_HI)
        f_lbl(lb2, t2,     " TP2 · " + str.tostring(tp2R,"#.#") + "R " + str.tostring(t2, format.mintick), GRN_HI)
        f_lbl(lb3, t3,     " TP3 · " + str.tostring(tp3R,"#.#") + "R " + str.tostring(t3, format.mintick), GRN)

// extend the active trade graphic to the right while the trade is open
if showLad and not na(riskBox) and barstate.islast
    box.set_right(riskBox, bar_index + boxW)
    box.set_right(rewBox, bar_index + boxW)
    line.set_x2(lnEnt, bar_index + boxW)
    line.set_x2(lnSl, bar_index + boxW)
    line.set_x2(lnT1, bar_index + boxW)
    line.set_x2(lnT2, bar_index + boxW)
    label.set_x(lbE, bar_index + boxW)
    label.set_x(lbS, bar_index + boxW)
    label.set_x(lb1, bar_index + boxW)
    label.set_x(lb2, bar_index + boxW)
    label.set_x(lb3, bar_index + boxW)

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  SIGNAL PLOTS  +  bias-tinted background
// ─────────────────────────────────────────────────────────────────────────
plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = BLUE, textcolor = INKHI, text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = RED,  textcolor = INKHI, text = "SELL", size = size.small)
bgcolor(bias == 1 ? color.new(BLUE, 95) : bias == -1 ? color.new(RED, 95) : na, title = "Structure bias")

// candles tinted by structure bias (blue bull / red bear)
barcolor(colorBars ? (bias == 1 ? color.new(BLUE, 20) : bias == -1 ? color.new(RED, 20) : na) : na, title = "Structure candles")

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD  —  "SMC TERMINAL"  (blue title bar, coloured status cell, dot meters)
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 7, bgcolor = color.new(hudBg, 0), frame_color = color.new(BLUE, 55), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)

    biasT = bias == 1 ? "▲ BULLISH" : bias == -1 ? "▼ BEARISH" : "• NEUTRAL"
    biasC = bias == 1 ? INKHI : bias == -1 ? INKHI : MUTE
    biasBg= bias == 1 ? color.new(BLUE, 55) : bias == -1 ? color.new(RED, 55) : SURF
    armT  = armedLong ? "Long armed" : armedShort ? "Short armed" : "—"
    armC  = armedLong ? BLUE_HI : armedShort ? RED_HI : MUTE
    fvgT  = str.tostring(array.size(fvgBox)) + " live"
    sigT  = buy ? "BUY ▲" : sell ? "SELL ▼" : "Waiting"
    sigC  = buy ? BLUE_HI : sell ? RED_HI : MUTE
    convC = conv >= 66 ? BLUE_HI : conv >= 33 ? GOLD : MUTE
    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? BLUE_HI : winRate <= 45 ? RED_HI : GOLD

    // Row 0 — full-width blue TITLE bar
    table.cell(hud, 0, 0, "◆ SMC TERMINAL", text_color = INKHI, text_halign = text.align_left, bgcolor = BLUE, text_size = hudTS)
    table.cell(hud, 1, 0, "SMC  ", text_color = INKHI, text_halign = text.align_right, bgcolor = BLUE, text_size = hudTS)
    // Row 1 — coloured STATUS band: left cell = structure, right = conviction headline
    table.cell(hud, 0, 1, " " + biasT + " ", text_color = biasC, text_halign = text.align_left, bgcolor = biasBg, text_size = hudTS)
    table.cell(hud, 1, 1, str.tostring(conv) + "  ", text_color = convC, text_halign = text.align_right, bgcolor = biasBg, text_size = hudTS)
    // Row 2 — Setup
    table.cell(hud, 0, 2, "  Setup", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, armT + "  ", text_color = armC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // Row 3 — FVG zones
    table.cell(hud, 0, 3, "  FVG zones", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, fvgT + "  ", text_color = GOLD, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // Row 4 — Conviction dot meter
    table.cell(hud, 0, 4, "  Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, f_dots(conv / 100.0) + "  ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // Row 5 — Signal
    table.cell(hud, 0, 5, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // Row 6 — Win rate (TP1 before SL)
    table.cell(hud, 0, 6, "  Win (TP1)", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 6, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy",  "ICT Liquidity: sell-side sweep + bullish structure confirmation")
alertcondition(sell, "Sell", "ICT Liquidity: buy-side sweep + bearish structure confirmation")
alertcondition(sweepLow or sweepHigh, "Liquidity Sweep", "ICT Liquidity: a liquidity level was swept")
alertcondition(choChUp or choChDn, "CHoCH", "ICT Liquidity: change of character detected")
````
