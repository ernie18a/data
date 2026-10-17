# Adaptive Momentum Ribbon [JOAT]

- url: https://www.tradingview.com/script/qRM3S3AY-Adaptive-Momentum-Ribbon-JOAT/
- type: indicator
- pine_id: PUB;b5fcb06242924d18b8b338fa7586ed81
- version: 1.0

## Description

[b]Adaptive Momentum Ribbon [JOAT][/b]
[i]An eight-layer moving-average ribbon whose colour is driven by live momentum and whose compression flags the coil before the move.[/i]

[image]https://www.tradingview.com/x/6Q5miP0D/[/image]

[b]What it is[/b]
A single moving average tells you very little. A ribbon of them, fanned by speed, tells you three things at once: direction (the colour), strength (how wide it fans) and turning points (where it squeezes and flips). This indicator builds that ribbon and adds a momentum core and a compression detector so the ribbon is not just decorative — it gates the signals.

[b]How it works[/b]
• [b]The ribbon[/b] — eight exponential moving averages from fast to slow, with an optional light second smoothing pass for cleaner turns. When the fast layers sit above the slow layers the stack is bullish, and vice versa.

• [b]Momentum core[/b] — a rate-of-change normalised by ATR and then smoothed. This value is mapped onto a colour gradient, so a strong trend glows saturated while a fading one drifts toward neutral. The same value gates entries, so you buy strength rather than every flip.

• [b]Compression detector[/b] — the width between the fastest and slowest ribbon lines is ranked as a percentile over a lookback window. A low percentile means the market is coiled; a move out of that coil is the tradable expansion. Coils are highlighted so you can see energy building.

• [b]Flip signals[/b] — a Buy prints when the ribbon flips up out of (or just after) a compression with positive momentum; a Sell is the mirror. Because a flip requires the stack to actually reverse, signals are naturally spaced, and a minimum-gap control adds a further safeguard against clustering.

[b]Trade levels[/b]
Each signal draws a red risk box to the ATR-based stop and a green reward box to the third target, with inner target lines and right-edge price labels for entry, stop and every take-profit at your chosen R multiples.

[b]The dashboard[/b]
An adjustable panel shows trend direction, a block-gradient momentum meter with a signed headline value, the compression state (coiled or expanded), a 0–100 conviction estimate, the current signal, and a live first-target-before-stop tally from closed bars only.

[b]How to use it[/b]
• Works on all assets and timeframes; the ribbon adapts to whatever data it is given.
• Use the coil highlight to prepare for a move and the flip-with-momentum signal to time it.
• Require the coil filter for cleaner, fewer signals in choppy markets, or relax it for more responsive trend entries.

[b]Settings[/b]
Base length and layer step, source, optional smoothing, momentum length and smoothing, signal momentum gate, compression window and percentile threshold, risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
The combination is the point: a speed-fanned ribbon, an ATR-normalised momentum gradient that both colours the ribbon and filters signals, and a percentile-ranked compression model that isolates coils. Together they turn a familiar visual into a structured, non-repainting trend-and-expansion tool.

[b]Notes and limitations[/b]
• Moving averages lag by nature; the ribbon confirms trend, it does not call exact tops or bottoms.
• In strong one-way trends the compression filter may keep you out of some continuation entries — that is the intended trade-off for fewer false flips.
• The tally reflects only past bars on the current chart and is not a forecast.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Adaptive Momentum Ribbon [JOAT]", "Momentum Ribbon [JOAT]", overlay = true, max_labels_count = 300, max_lines_count = 100, max_boxes_count = 100)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (aurora green vs rose, gradient-friendly)
// ─────────────────────────────────────────────────────────────────────────
GRN_LO = #0E5A46
GRN_MID= #12B36A
GRN_HI = #5CF0A0
ROSE_LO= #6E1230
ROSE_MID=#F0324B
ROSE_HI= #FF7C9C
AMBER  = #FFC24B
INK    = #060B10
INKHI  = #EAFBF2
MUTE   = #55627A

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gR      = "Ribbon"
baseLen = input.int(10, "Base EMA length", minval = 2, group = gR, tooltip = "Length of the fastest ribbon line. Each subsequent layer is progressively slower.")
stepLen = input.int(6,  "Layer step", minval = 1, group = gR, tooltip = "How much slower each ribbon layer is than the previous one.")
ribbonSrc= input.source(close, "Source", group = gR)
smooth  = input.bool(true, "Smooth ribbon (HMA feel)", group = gR, tooltip = "Adds a light second-pass smoothing for cleaner turns.")

gM      = "Momentum Core"
momLen  = input.int(14, "Momentum length", minval = 2, group = gM, tooltip = "ROC lookback that drives the gradient colour and gates signals.")
momSmooth=input.int(5,  "Momentum smoothing", minval = 1, group = gM)
momGate = input.float(0.0,"Signal momentum gate", step = 0.05, group = gM, tooltip = "Momentum must exceed this (normalised) for a signal to fire. 0 = only sign matters.")

gC      = "Compression"
useCoil = input.bool(true, "Require coil release for signals", group = gC, tooltip = "Only take flips that emerge from a compression/coil, filtering chop.")
coilLen = input.int(60, "Coil ranking window", minval = 10, group = gC, tooltip = "Window used to rank current ribbon width — low percentile = coiled.")
coilThr = input.float(0.30,"Coil percentile", minval = 0.05, maxval = 0.9, step = 0.05, group = gC)

gV      = "Visuals"
showRib = input.bool(true, "Show ribbon", group = gV)
fillRib = input.bool(true, "Fill ribbon", group = gV)
colorBars=input.bool(true, "Gradient candles", group = gV)
showCoil= input.bool(true, "Highlight coils", group = gV)

gTr     = "Trade Levels"
showTPSL= input.bool(true, "TP/SL boxes", group = gTr, tooltip = "Draws red-risk + green-reward boxes with ENTRY/SL/TP1·2·3 labels for the most recent ribbon signal.")
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gTr)
slMult  = input.float(1.5, "SL = ATR ×", minval = 0.1, step = 0.1, group = gTr)
tp1R    = input.float(1.0, "TP1 (R)", step = 0.5, group = gTr)
tp2R    = input.float(2.0, "TP2 (R)", step = 0.5, group = gTr)
tp3R    = input.float(3.0, "TP3 (R)", step = 0.5, group = gTr)

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#08110C, "Background", group = gP)

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

f_ema(float src, int len) =>
    e = ta.ema(src, len)
    s = ta.ema(e, math.max(2, int(len / 3)))   // light second pass
    smooth ? s : e

// aurora block-gradient meter — solid █ then a ▓▒ fade into empty ░
f_meter(float pct01) =>
    v = math.max(0.0, math.min(1.0, pct01))
    fill = math.round(v * 10)
    out = ""
    for i = 1 to 10
        out := out + (i <= fill ? "█" : i == fill + 1 ? "▓" : i == fill + 2 ? "▒" : "░")
    out

// ─────────────────────────────────────────────────────────────────────────
//  RIBBON  (8 layers, fastest → slowest)
// ─────────────────────────────────────────────────────────────────────────
r1 = f_ema(ribbonSrc, baseLen)
r2 = f_ema(ribbonSrc, baseLen + stepLen)
r3 = f_ema(ribbonSrc, baseLen + stepLen * 2)
r4 = f_ema(ribbonSrc, baseLen + stepLen * 3)
r5 = f_ema(ribbonSrc, baseLen + stepLen * 4)
r6 = f_ema(ribbonSrc, baseLen + stepLen * 5)
r7 = f_ema(ribbonSrc, baseLen + stepLen * 6)
r8 = f_ema(ribbonSrc, baseLen + stepLen * 7)

ribUp   = r1 > r8                       // fast above slow = bullish stack
ribWidth= math.abs(r1 - r8)

// ─────────────────────────────────────────────────────────────────────────
//  MOMENTUM CORE  (normalised, smoothed ROC → gradient position 0..1)
// ─────────────────────────────────────────────────────────────────────────
atr14 = ta.atr(14)
roc   = ribbonSrc - ribbonSrc[momLen]
momRaw= atr14 > 0 ? roc / (atr14 * momLen) : 0.0
mom   = ta.ema(momRaw, momSmooth)
momClamp = math.max(-1.0, math.min(1.0, mom * 3.0))
gpos  = (momClamp + 1) / 2               // 0..1 for gradient

// ribbon colour: gradient by momentum, hue by direction
ribCol = ribUp ? color.from_gradient(gpos, 0.5, 1.0, GRN_MID, GRN_HI) : color.from_gradient(gpos, 0.0, 0.5, ROSE_HI, ROSE_MID)

// ─────────────────────────────────────────────────────────────────────────
//  COMPRESSION  (percentile rank of ribbon width — low = coiled)
// ─────────────────────────────────────────────────────────────────────────
widthPct = ta.percentrank(ribWidth, coilLen) / 100.0
coiled   = widthPct <= coilThr
coilRelease = coiled[1] and not coiled   // width just expanded out of a coil

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS  (ribbon flip + momentum gate + optional coil release)
// ─────────────────────────────────────────────────────────────────────────
flipUp = ribUp and not ribUp[1]
flipDn = not ribUp and ribUp[1]
momOKl = mom >= momGate
momOKs = mom <= -momGate
coilOK = not useCoil or coilRelease or coiled[1]

buy  = flipUp and momOKl and coilOK
sell = flipDn and momOKs and coilOK
sig  = buy or sell

// ─────────────────────────────────────────────────────────────────────────
//  CONVICTION 0..100
// ─────────────────────────────────────────────────────────────────────────
momComp  = math.min(1.0, math.abs(momClamp))
coilComp = 1.0 - widthPct                 // tighter prior coil = better
slopeComp= atr14 > 0 ? math.min(1.0, math.abs(r1 - r1[3]) / atr14) : 0.0
conv = math.round(100 * (0.45 * momComp + 0.30 * coilComp + 0.25 * slopeComp))

// ─────────────────────────────────────────────────────────────────────────
//  LIVE STATS  (win = +1 ATR before -1 ATR after the signal)
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

// TP/SL trade graphic — red risk box (entry→SL) + green reward box (entry→TP3),
// solid ENTRY line, dashed SL line, dotted TP1/TP2 dividers, right-edge labels.
var box   riskBox = na
var box   rewBox  = na
var line  lnEntry = na
var line  lnSL    = na
var line  lnT1    = na
var line  lnT2    = na
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_lbl(label lb, float p, string txt, color c) =>
    label.set_xy(lb, bar_index + boxW, p)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

f_seg(line ln, float p) =>
    line.set_xy1(ln, bar_index, p)
    line.set_xy2(ln, bar_index + boxW, p)

if sig
    if sOpen
        losses += 1
        sOpen := false
    sDir   := buy ? 1 : -1
    sEntry := close
    risk    = atr14 * slMult
    risk   := risk > 0 ? risk : atr14
    sSL    := buy ? close - risk : close + risk
    sT1    := buy ? close + risk * tp1R : close - risk * tp1R
    sOpen  := true

    if showTPSL
        t2 = buy ? close + risk * tp2R : close - risk * tp2R
        t3 = buy ? close + risk * tp3R : close - risk * tp3R
        box.delete(riskBox)
        box.delete(rewBox)
        // red RISK box: entry → SL   |   green REWARD box: entry → TP3
        riskBox := box.new(bar_index, sEntry, bar_index + boxW, sSL, bgcolor = color.new(ROSE_MID, 82), border_color = color.new(ROSE_MID, 35), border_width = 1)
        rewBox  := box.new(bar_index, sEntry, bar_index + boxW, t3,  bgcolor = color.new(GRN_MID, 85), border_color = color.new(GRN_MID, 35), border_width = 1)
        if na(lnEntry)
            lnEntry := line.new(bar_index, sEntry, bar_index + boxW, sEntry, color = AMBER,    width = 2)
            lnSL    := line.new(bar_index, sSL,    bar_index + boxW, sSL,    color = ROSE_MID, style = line.style_dashed)
            lnT1    := line.new(bar_index, sT1,    bar_index + boxW, sT1,    color = color.new(GRN_MID, 30), style = line.style_dotted)
            lnT2    := line.new(bar_index, t2,     bar_index + boxW, t2,     color = color.new(GRN_MID, 30), style = line.style_dotted)
            lbE := label.new(bar_index + boxW, sEntry, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lbS := label.new(bar_index + boxW, sSL,    "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb1 := label.new(bar_index + boxW, sT1,    "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb2 := label.new(bar_index + boxW, t2,     "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb3 := label.new(bar_index + boxW, t3,     "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        f_seg(lnEntry, sEntry)
        f_seg(lnSL, sSL)
        f_seg(lnT1, sT1)
        f_seg(lnT2, t2)
        f_lbl(lbE, sEntry, " ENTRY " + str.tostring(sEntry, format.mintick), AMBER)
        f_lbl(lbS, sSL,    " SL " + str.tostring(sSL, format.mintick), ROSE_HI)
        f_lbl(lb1, sT1,    " TP1 · " + str.tostring(tp1R,"#.#") + "R " + str.tostring(sT1, format.mintick), GRN_MID)
        f_lbl(lb2, t2,     " TP2 · " + str.tostring(tp2R,"#.#") + "R " + str.tostring(t2, format.mintick), GRN_MID)
        f_lbl(lb3, t3,     " TP3 · " + str.tostring(tp3R,"#.#") + "R " + str.tostring(t3, format.mintick), GRN_HI)

if showTPSL and not na(riskBox) and barstate.islast
    box.set_right(riskBox, bar_index + boxW)
    box.set_right(rewBox, bar_index + boxW)
    line.set_x2(lnEntry, bar_index + boxW)
    line.set_x2(lnSL, bar_index + boxW)
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
//  PLOTS  —  ribbon, fill, coil highlight, candles, signals
// ─────────────────────────────────────────────────────────────────────────
p1 = plot(showRib ? r1 : na, "R1", color = color.new(ribCol, 0),  linewidth = 2)
plot(showRib ? r2 : na, "R2", color = color.new(ribCol, 15))
plot(showRib ? r3 : na, "R3", color = color.new(ribCol, 30))
plot(showRib ? r4 : na, "R4", color = color.new(ribCol, 45))
plot(showRib ? r5 : na, "R5", color = color.new(ribCol, 55))
plot(showRib ? r6 : na, "R6", color = color.new(ribCol, 65))
plot(showRib ? r7 : na, "R7", color = color.new(ribCol, 75))
p8 = plot(showRib ? r8 : na, "R8", color = color.new(ribCol, 85), linewidth = 2)
fill(p1, p8, color = fillRib ? color.new(ribCol, 82) : na, title = "Ribbon fill")

barcolor(colorBars ? color.new(ribCol, 15) : na)

bgcolor(showCoil and coiled ? color.new(AMBER, 90) : na, title = "Coil zone")
plotshape(showCoil and coilRelease, "Coil release", style = shape.circle, location = location.bottom, color = AMBER, size = size.tiny)

plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = GRN_MID, textcolor = INK, text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = ROSE_MID, textcolor = INKHI, text = "SELL", size = size.small)

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
    hud := table.new(f_pos(hudPos), 2, 7, bgcolor = color.new(hudBg, 0), frame_color = color.new(#173025, 0), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #123A2A), 0)

    // aurora accent — green rising, rose falling
    auroraC = momClamp >= 0 ? GRN_HI : ROSE_HI

    dirT = ribUp ? "UP" : "DOWN"
    dirC = ribUp ? GRN_MID : ROSE_MID

    // block-gradient momentum meter + big signed headline value
    mbar = f_meter(gpos)
    mC = momClamp > 0.1 ? GRN_HI : momClamp < -0.1 ? ROSE_HI : MUTE
    momHead = (momClamp >= 0 ? "▲ +" : "▼ ") + str.tostring(math.round(momClamp * 100))

    coilT = coiled ? "COILED" : "EXPANDED"
    coilC = coiled ? AMBER : ribUp ? GRN_MID : ROSE_MID

    cbar = f_meter(conv / 100.0)
    convC = conv >= 66 ? GRN_HI : conv >= 33 ? AMBER : MUTE

    sigT = buy ? "BUY ▲" : sell ? "SELL ▼" : coilRelease ? "Coil released" : ribUp ? "Hold long" : "Hold short"
    sigC = buy ? GRN_HI : sell ? ROSE_HI : coilRelease ? AMBER : ribUp ? GRN_MID : ROSE_MID
    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? GRN_MID : winRate <= 45 ? ROSE_MID : AMBER

    table.cell(hud, 0, 0, "  ░▒▓█ MOMENTUM RIBBON", text_color = INKHI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, momHead + "  ", text_color = auroraC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 0, 1, "  Trend", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, dirT + "  ", text_color = dirC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 2, "  Momentum", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, mbar + "  ", text_color = mC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 3, "  State", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, coilT + "  ", text_color = coilC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 4, "  Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, cbar + " " + str.tostring(conv) + "  ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 5, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 6, "  Win (TP1)", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 6, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy",  "Momentum Ribbon: bullish flip out of coil with positive momentum")
alertcondition(sell, "Sell", "Momentum Ribbon: bearish flip out of coil with negative momentum")
alertcondition(coilRelease, "Coil release", "Momentum Ribbon: compression released — expansion move starting")
````
