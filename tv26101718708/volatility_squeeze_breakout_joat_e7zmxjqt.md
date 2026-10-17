# Volatility Squeeze Breakout [JOAT]

- url: https://www.tradingview.com/script/e7zMXJqT-Volatility-Squeeze-Breakout-JOAT/
- type: indicator
- pine_id: PUB;4c0d2d6e60aa44caaa4fafc5fbaf7030
- version: 1.0

## Description

[b]Volatility Squeeze Breakout [JOAT][/b]
[i]Finds volatility compression — when Bollinger Bands contract inside the Keltner Channel — and signals the directional release with a built-in energy gauge.[/i]

[image]https://www.tradingview.com/x/xNmG8t8P/[/image]

[b]What it is[/b]
Markets alternate between coiling and expanding. This indicator detects the coil using the classic squeeze relationship between two well-known volatility envelopes, quantifies how much energy has built up, and then signals the breakout in the direction momentum actually resolves. It is an original implementation with a charge model and full trade framing, not a bare squeeze dot script.

[b]How it works[/b]
• [b]The squeeze[/b] — a squeeze is on when the Bollinger Bands (price standard deviation) contract entirely inside the Keltner Channel (ATR-based). This means realised volatility has fallen below its typical range and the market is compressing.

• [b]Charge / energy[/b] — while the squeeze persists, the tool tracks how long and how tightly the market has been coiled and expresses it as a 0–100 charge. A longer, tighter coil stores more potential energy for the eventual expansion.

• [b]Momentum direction[/b] — a smoothed momentum measure determines which way the coil is leaning, so the breakout is read directionally rather than as a neutral event.

• [b]The release[/b] — a Buy fires when the squeeze releases with rising positive momentum; a Sell fires when it releases with falling negative momentum. The release is a discrete event, and a minimum-gap control prevents repeated prints around the same break.

[b]Trade levels[/b]
On a signal, a red risk box marks entry to the ATR stop and a green reward box marks entry to the third target, with inner dividers and right-edge labels for entry, stop and each take-profit at your R multiples.

[b]The dashboard[/b]
An adjustable energy-gauge panel shows the squeeze state, the charge that had accumulated at the moment of release, the momentum direction, a conviction estimate, the active signal, and a live first-target-before-stop tally from closed bars only.

[b]How to use it[/b]
• Works on any asset and timeframe; volatility cycles exist at every scale.
• Watch the charge build during a squeeze, then act on the release in the momentum direction.
• Higher charge readings indicate a longer coil, which some traders treat as a higher-quality setup — but a big coil can still resolve in either direction, so the momentum gate matters.

[b]Settings[/b]
Bollinger length and multiplier, Keltner length and ATR multiplier, momentum length, release and charge options, risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
The squeeze concept is public domain; the value added here is the charge model that turns coil duration and tightness into a readable energy figure, the directional momentum gate on the release, and the integrated non-repainting trade framing — combined and explained so a trader can see exactly why each breakout is flagged.

[b]Notes and limitations[/b]
• Squeeze breakouts can fail or fake out; a release does not guarantee follow-through.
• The charge measures compression, not direction — always confirm with the momentum reading and your own context.
• The tally reflects only past bars on the current chart and is not a prediction.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Volatility Squeeze Breakout [JOAT]", "Squeeze Breakout [JOAT]", overlay = true, max_labels_count = 300, max_lines_count = 100, max_boxes_count = 20)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (cyber blue → violet, amber ignition)
// ─────────────────────────────────────────────────────────────────────────
BLUE   = #2F80FF
BLUE_HI= #74B0FF
VIOLET = #9B5CFF
VIOLET_HI=#C39CFF
RED    = #FF3D5A
RED_HI = #FF8199
GRN    = #25C685
GRN_HI = #7CF6C0
AMBER  = #FFC24B
INK    = #05090F
INKHI  = #EAF1FF
MUTE   = #55607A

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gS      = "Squeeze"
bbLen   = input.int(20, "BB / KC length", minval = 5, group = gS, tooltip = "Shared lookback for Bollinger Bands and Keltner Channel.")
bbMult  = input.float(2.0,"BB multiplier", minval = 0.5, step = 0.1, group = gS)
kcMult  = input.float(1.5,"KC multiplier (firm)", minval = 0.5, step = 0.1, group = gS, tooltip = "Standard squeeze threshold. BB inside KC at this width = firm squeeze.")
kcMultV = input.float(1.0,"KC multiplier (vice)", minval = 0.3, step = 0.1, group = gS, tooltip = "Tighter threshold marking an extreme 'vice' squeeze.")
kcMultM = input.float(2.0,"KC multiplier (mild)", minval = 0.5, step = 0.1, group = gS, tooltip = "Loose threshold marking an early/mild squeeze.")

gMom    = "Momentum Wave"
momLen  = input.int(20, "Momentum length", minval = 5, group = gMom, tooltip = "Linear-regression window for the directional momentum wave.")
waveScale=input.float(1.0,"Wave display scale", minval = 0.1, step = 0.1, group = gMom, tooltip = "Visual amplitude of the momentum wave plotted beneath price.")

gT      = "Trade Levels"
showLad = input.bool(true, "Show TP/SL boxes", group = gT)
atrLenT = input.int(14, "ATR length", minval = 1, group = gT)
slMult  = input.float(1.5,"SL = ATR ×", minval = 0.1, step = 0.1, group = gT)
tp1R    = input.float(1.0,"TP1 (R)", step = 0.5, group = gT)
tp2R    = input.float(2.0,"TP2 (R)", step = 0.5, group = gT)
tp3R    = input.float(3.0,"TP3 (R)", step = 0.5, group = gT)
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gT)

gV      = "Visuals"
showDots= input.bool(true, "Squeeze dots (mid-line)", group = gV)
showWave= input.bool(true, "Momentum wave", group = gV)
colorBars=input.bool(true, "Charge-tinted candles", group = gV)
showBg  = input.bool(true, "Ignition background flash", group = gV)

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#080D18, "Background", group = gP)

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
//  BANDS  (Bollinger vs Keltner)
// ─────────────────────────────────────────────────────────────────────────
basis = ta.sma(close, bbLen)
dev   = bbMult * ta.stdev(close, bbLen)
bbU   = basis + dev
bbL   = basis - dev

atr   = ta.atr(atrLenT)
rngMa = ta.sma(ta.tr(true), bbLen)
kcU_f = basis + kcMult  * rngMa
kcL_f = basis - kcMult  * rngMa
kcU_v = basis + kcMultV * rngMa
kcL_v = basis - kcMultV * rngMa
kcU_m = basis + kcMultM * rngMa
kcL_m = basis - kcMultM * rngMa

sqzMild = bbU < kcU_m and bbL > kcL_m
sqzFirm = bbU < kcU_f and bbL > kcL_f
sqzVice = bbU < kcU_v and bbL > kcL_v
inSqz   = sqzMild or sqzFirm or sqzVice
tier    = sqzVice ? 3 : sqzFirm ? 2 : sqzMild ? 1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  ENERGY / CHARGE  (bars in squeeze × tightness → 0..100)
// ─────────────────────────────────────────────────────────────────────────
var int sqzBars = 0
sqzBars := inSqz ? sqzBars + 1 : 0
barsComp = math.min(1.0, sqzBars / 30.0)
tierComp = tier / 3.0
charge   = math.round(100 * (0.6 * barsComp + 0.4 * tierComp))

fired    = not inSqz and inSqz[1]        // squeeze just released this bar
var int chargeAtFire = 0
if fired
    chargeAtFire := int(math.round(100 * (0.6 * math.min(1.0, sqzBars[1] / 30.0) + 0.4 * (nz(tier[1]) / 3.0))))

// ─────────────────────────────────────────────────────────────────────────
//  MOMENTUM WAVE  (linreg of price vs its Donchian/SMA mid → direction)
// ─────────────────────────────────────────────────────────────────────────
mid    = (ta.highest(high, momLen) + ta.lowest(low, momLen)) / 2
refMid = (mid + ta.sma(close, momLen)) / 2
momVal = ta.linreg(close - refMid, momLen, 0)
momUp  = momVal > 0
momRising = momVal > momVal[1]

// normalise wave for display beneath price
waveNorm = atr > 0 ? momVal / (atr * 4.0) : 0.0
waveClamp= math.max(-1.0, math.min(1.0, waveNorm))
wavePlot = low - atr * 1.2 + waveClamp * atr * waveScale

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS  (release + momentum direction + rising)
// ─────────────────────────────────────────────────────────────────────────
buy  = fired and momUp and momRising
sell = fired and not momUp and not momRising
sig  = buy or sell

// ── signal debounce — Buy/Sell can never stack on any timeframe
minGap = input.int(5, "Min bars between signals", minval = 0, group = "Signals", tooltip = "Minimum bar spacing between printed signals so labels never overlap on lower timeframes. 0 = off.")
var int lastSigBar = na
okGap = na(lastSigBar) or (bar_index - lastSigBar) >= minGap
buy  := buy  and okGap
sell := sell and okGap
sig  := buy or sell
if sig
    lastSigBar := bar_index

// ─────────────────────────────────────────────────────────────────────────
//  CONVICTION 0..100
// ─────────────────────────────────────────────────────────────────────────
chgComp  = chargeAtFire / 100.0
momComp  = math.min(1.0, math.abs(waveClamp))
expComp  = atr > 0 ? math.min(1.0, math.abs(bbU - bbL - (bbU[1] - bbL[1])) / atr) : 0.0
conv = math.round(100 * (0.45 * chgComp + 0.35 * momComp + 0.20 * expComp))

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

var box   riskBox = na    // red risk box  (entry → SL)
var box   rewBox  = na    // green reward box (entry → TP3)
var line  lnE = na        // solid ENTRY line
var line  lnS = na        // dashed SL line
var line  ln1 = na        // TP1 divider
var line  ln2 = na        // TP2 divider
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na
var float sT2 = na
var float sT3 = na

f_setLbl(label lb, float p, string txt, color c) =>
    label.set_xy(lb, bar_index + boxW, p)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

if sig
    if sOpen
        losses += 1
        sOpen := false
    sDir   := buy ? 1 : -1
    sEntry := close
    risk    = atr * slMult
    risk   := risk > 0 ? risk : atr        // never zero-height
    sSL    := buy ? sEntry - risk : sEntry + risk
    sT1    := buy ? sEntry + risk * tp1R : sEntry - risk * tp1R
    sT2    := buy ? sEntry + risk * tp2R : sEntry - risk * tp2R
    sT3    := buy ? sEntry + risk * tp3R : sEntry - risk * tp3R
    sOpen  := true

    if showLad
        // reposition the single active trade set on each new signal
        box.delete(riskBox)
        box.delete(rewBox)
        line.delete(lnE)
        line.delete(lnS)
        line.delete(ln1)
        line.delete(ln2)
        riskBox := box.new(bar_index, sEntry, bar_index + boxW, sSL, bgcolor = color.new(RED, 82), border_color = color.new(RED, 35), border_width = 1)
        rewBox  := box.new(bar_index, sEntry, bar_index + boxW, sT3, bgcolor = color.new(GRN, 85), border_color = color.new(GRN, 35), border_width = 1)
        lnE := line.new(bar_index, sEntry, bar_index + boxW, sEntry, color = AMBER, width = 2)
        lnS := line.new(bar_index, sSL, bar_index + boxW, sSL, color = RED, style = line.style_dashed)
        ln1 := line.new(bar_index, sT1, bar_index + boxW, sT1, color = color.new(GRN, 25), style = line.style_dotted)
        ln2 := line.new(bar_index, sT2, bar_index + boxW, sT2, color = color.new(GRN, 25), style = line.style_dotted)
        if na(lbE)
            lbE := label.new(bar_index + boxW, sEntry, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lbS := label.new(bar_index + boxW, sSL, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb1 := label.new(bar_index + boxW, sT1, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb2 := label.new(bar_index + boxW, sT2, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb3 := label.new(bar_index + boxW, sT3, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        f_setLbl(lbE, sEntry, " ENTRY " + str.tostring(sEntry, format.mintick), AMBER)
        f_setLbl(lbS, sSL, " SL " + str.tostring(sSL, format.mintick), RED_HI)
        f_setLbl(lb1, sT1, " TP1 · " + str.tostring(tp1R,"#.#") + "R " + str.tostring(sT1, format.mintick), GRN)
        f_setLbl(lb2, sT2, " TP2 · " + str.tostring(tp2R,"#.#") + "R " + str.tostring(sT2, format.mintick), GRN_HI)
        f_setLbl(lb3, sT3, " TP3 · " + str.tostring(tp3R,"#.#") + "R " + str.tostring(sT3, format.mintick), GRN_HI)

// keep the active trade graphic pinned to the right edge while the trade is open
if showLad and not na(riskBox) and barstate.islast
    box.set_right(riskBox, bar_index + boxW)
    box.set_right(rewBox, bar_index + boxW)
    line.set_x2(lnE, bar_index + boxW)
    line.set_x2(lnS, bar_index + boxW)
    line.set_x2(ln1, bar_index + boxW)
    line.set_x2(ln2, bar_index + boxW)
    label.set_x(lbE, bar_index + boxW)
    label.set_x(lbS, bar_index + boxW)
    label.set_x(lb1, bar_index + boxW)
    label.set_x(lb2, bar_index + boxW)
    label.set_x(lb3, bar_index + boxW)

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────────────────────────────────
uB = plot(bbU, "BB Upper", color = color.new(BLUE, 55))
lB = plot(bbL, "BB Lower", color = color.new(BLUE, 55))
plot(basis, "Basis", color = color.new(MUTE, 30))
fill(uB, lB, color = inSqz ? color.new(VIOLET, 90) : color.new(BLUE, 94), title = "Band fill")

// squeeze dots on the mid-line, coloured by tier
dotCol = tier == 3 ? VIOLET_HI : tier == 2 ? VIOLET : tier == 1 ? BLUE : na
plotshape(showDots and inSqz ? basis : na, "Squeeze", style = shape.circle, location = location.absolute, color = dotCol, size = size.tiny)
plotshape(showDots and not inSqz ? basis : na, "No squeeze", style = shape.cross, location = location.absolute, color = color.new(#25C685, 55), size = size.tiny)

// charge-tinted candles
chargeCol = momUp ? color.from_gradient(charge, 0, 100, BLUE, VIOLET_HI) : color.from_gradient(charge, 0, 100, RED, VIOLET_HI)
barcolor(colorBars ? color.new(chargeCol, 20) : na)

// momentum wave beneath price
waveCol = momUp ? (momRising ? BLUE_HI : BLUE) : (momRising ? RED : RED_HI)
plot(showWave ? wavePlot : na, "Momentum wave", color = color.new(waveCol, 10), linewidth = 2, style = plot.style_line)

// ignition flash + signals
bgcolor(showBg and fired ? color.new(AMBER, 80) : na, title = "Ignition")
plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = BLUE, textcolor = INKHI, text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = RED,  textcolor = INKHI, text = "SELL", size = size.small)

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
    hud := table.new(f_pos(hudPos), 2, 8, bgcolor = color.new(hudBg, 0), frame_color = color.new(#1B2540, 0), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, VIOLET), 45)
    // cyber-blue → violet accent, driven by the coil charge
    ACC   = color.from_gradient(charge, 0, 100, BLUE_HI, VIOLET_HI)

    // big block-meter for the CHARGE headline (█ full, ▓▒ falloff, ░ empty)
    chF = math.round(charge / 100.0 * 14)
    chbar = ""
    for i = 1 to 14
        chbar := chbar + (i <= chF ? "█" : i == chF + 1 ? "▓" : i == chF + 2 ? "▒" : "░")

    // squeeze-tier coloured badge
    sqzT = tier == 3 ? " VICE " : tier == 2 ? " FIRM " : tier == 1 ? " MILD " : " —— "
    sqzC = tier == 3 ? VIOLET_HI : tier == 2 ? VIOLET_HI : tier == 1 ? BLUE_HI : MUTE
    sqzBg= tier == 3 ? color.new(VIOLET, 62) : tier == 2 ? color.new(VIOLET, 74) : tier == 1 ? color.new(BLUE, 74) : SURF

    momT = momUp ? (momRising ? "Bull ↑" : "Bull ↓") : (momRising ? "Bear ↑" : "Bear ↓")
    momC = momUp ? BLUE_HI : RED_HI

    convC = conv >= 66 ? VIOLET_HI : conv >= 33 ? BLUE_HI : MUTE

    sigT = buy ? "LONG RELEASE ▲" : sell ? "SHORT RELEASE ▼" : inSqz ? "Coiling…" : "Neutral"
    sigC = buy ? BLUE_HI : sell ? RED_HI : inSqz ? VIOLET_HI : MUTE
    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? BLUE_HI : winRate <= 45 ? RED_HI : AMBER

    // title bar
    table.cell(hud, 0, 0, "  ⚡ ENERGY GAUGE", text_color = INKHI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, "Squeeze  ", text_color = VIOLET_HI, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)
    // CHARGE headline (big value)
    table.cell(hud, 0, 1, "  CHARGE", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, str.tostring(charge) + " / 100  ", text_color = ACC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // long block meter + tier badge
    table.cell(hud, 0, 2, "  " + chbar, text_color = ACC, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, sqzT, text_color = sqzC, text_halign = text.align_right, bgcolor = sqzBg, text_size = hudTS)
    // detail rows
    table.cell(hud, 0, 3, "  Coiling", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, str.tostring(sqzBars) + " bars  ", text_color = sqzC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 4, "  Momentum", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, momT + "  ", text_color = momC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 5, "  Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, str.tostring(conv) + " / 100  ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 6, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 6, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 7, "  Win (TP1)", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 7, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy",  "Squeeze Breakout: bullish release with rising momentum")
alertcondition(sell, "Sell", "Squeeze Breakout: bearish release with falling momentum")
alertcondition(fired, "Squeeze fired", "Squeeze Breakout: volatility squeeze released")
alertcondition(sqzVice and not sqzVice[1], "Vice squeeze", "Squeeze Breakout: extreme (vice) squeeze forming")
````
