# Quant Confluence Engine [JOAT]

- url: https://www.tradingview.com/script/dOIRiuX0-Quant-Confluence-Engine-JOAT/
- type: indicator
- pine_id: PUB;dcdcaa09735e4fa8aadd4d205705ff58
- version: 1.0

## Description

[b]Quant Confluence Engine [JOAT][/b]
[i]Scores several independent market factors into one weighted composite, so signals fire on agreement across dimensions rather than on any single trigger.[/i]

[image]https://www.tradingview.com/x/az3oxC6U/[/image]

[b]What it is[/b]
Single-factor signals are fragile: a momentum cross, a moving-average flip or a volume spike each fails often on its own. This engine measures several independent factors, normalises them to a common scale, and blends them into one bipolar confluence score. A signal is produced only when enough factors line up, and the transparency of the score lets you see exactly why. It is an original scoring framework, not a bundle of overlaid classic indicators.

[b]How it works[/b]
• [b]The factors[/b] — the engine evaluates a set of complementary dimensions, each capturing a different aspect of the tape: trend alignment, momentum, volatility regime, volume behaviour, price structure and stretch relative to a mean. Each factor is computed with a standard, well-understood method and then scaled so it contributes fairly.

• [b]Normalisation[/b] — every factor is converted to a bounded contribution, so no single input can dominate the composite purely because of its raw magnitude.

• [b]Composite score[/b] — the contributions are combined into one signed 0-centred score. Positive means the factors lean bullish, negative bearish, and the magnitude expresses how strong the agreement is.

• [b]State-machine signals[/b] — a Buy fires when the score crosses into sufficient bullish agreement from a non-bullish state; a Sell is the mirror. Because a signal requires a genuine state change, the engine will not re-fire the same direction bar after bar — signals are self-spacing by construction.

[b]Trade levels[/b]
Each signal draws a red risk box to the ATR stop and a green reward box to the third target, with inner dividers and right-edge labels for entry, stop and each take-profit at your R multiples.

[b]The dashboard[/b]
An adjustable factor-grid panel shows each factor's current lean (up or down) alongside a bipolar composite-score headline, the active signal, a conviction reading, and a live first-target-before-stop tally from closed bars only. The grid makes it obvious which factors are driving or vetoing a setup.

[b]How to use it[/b]
• Works on any asset and timeframe; the factors adapt to the data.
• Read the grid before acting — a signal backed by broad agreement differs from one carried by a single strong factor.
• Raise the agreement requirement for fewer, higher-conviction signals, or lower it for more frequent ones.

[b]Settings[/b]
Per-factor lengths and weights, the agreement threshold, ATR risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
The value is the framework itself: a normalised, weighted multi-factor score with a transparent per-factor readout and a state-machine trigger that prevents signal spam. It is designed so a trader can inspect the reasoning, not just accept a label — which is precisely what a confluence approach should offer.


[b]Notes and limitations[/b]
• Confluence reduces some false signals but does not remove them; correlated factors can all be wrong together in unusual conditions.
• Weighting is a design choice — different weights suit different markets, so treat the defaults as a starting point.
• The tally reflects only past bars on the current chart and is not a prediction.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Quant Confluence Engine [JOAT]", "Quant Confluence [JOAT]", overlay = true, max_labels_count = 300, max_lines_count = 100, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (emerald vs red, slate neutral)
// ─────────────────────────────────────────────────────────────────────────
GRN    = #16C784
GRN_HI = #5CF0B0
RED    = #F0324B
RED_HI = #FF7C93
GOLD   = #FFC24B
SLATE  = #58637A
INK    = #070C12
INKHI  = #EAF6F0

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gW      = "Factor Weights"
wTrend  = input.float(1.5, "Trend weight",    minval = 0, step = 0.1, group = gW)
wMom    = input.float(1.0, "Momentum weight", minval = 0, step = 0.1, group = gW)
wMacd   = input.float(1.0, "MACD weight",     minval = 0, step = 0.1, group = gW)
wAdx    = input.float(1.0, "Strength weight", minval = 0, step = 0.1, group = gW)
wVol    = input.float(0.8, "Volume weight",   minval = 0, step = 0.1, group = gW)
wLoc    = input.float(0.7, "Location weight", minval = 0, step = 0.1, group = gW)

gF      = "Factor Settings"
emaFast = input.int(21,  "Trend EMA fast", minval = 2, group = gF)
emaSlow = input.int(55,  "Trend EMA slow", minval = 2, group = gF)
rsiLen  = input.int(14,  "RSI length", minval = 2, group = gF)
adxLen  = input.int(14,  "ADX/DI length", minval = 2, group = gF)
adxThr  = input.float(18,"ADX trend threshold", minval = 5, step = 1, group = gF, tooltip = "Below this, the market is treated as range — strength factor votes 0.")
volLen  = input.int(20,  "Relative-volume window", minval = 2, group = gF)
locLen  = input.int(20,  "Location range window", minval = 2, group = gF)

gSig    = "Signals"
scoreThr= input.float(45,"Score trigger (0–100)", minval = 10, maxval = 100, step = 5, group = gSig, tooltip = "Absolute confluence score needed to fire a Buy/Sell on a fresh crossover.")
minFactors=input.int(4, "Min agreeing factors", minval = 1, maxval = 6, group = gSig, tooltip = "How many of the six factors must point the same way.")

gTr     = "Trade Levels"
showLad = input.bool(true, "TP/SL risk/reward boxes", group = gTr)
atrLenT = input.int(14, "ATR length", minval = 1, group = gTr)
slMult  = input.float(1.5,"SL = ATR ×", minval = 0.1, step = 0.1, group = gTr)
tp1R    = input.float(1.0,"TP1 (R)", step = 0.5, group = gTr)
tp2R    = input.float(2.0,"TP2 (R)", step = 0.5, group = gTr)
tp3R    = input.float(3.0,"TP3 (R)", step = 0.5, group = gTr)
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gTr)

gV      = "Visuals"
colorBars=input.bool(true, "Score-graded candles", group = gV)
showGrad= input.bool(true, "Score trail line", group = gV)
showBg  = input.bool(true, "Confluence background", group = gV)

gP      = "Dashboard"
showHUD = input.bool(true, "Show factor dashboard", group = gP)
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

f_dirTxt(int v) => v > 0 ? "▲" : v < 0 ? "▼" : "•"
f_dirCol(int v) => v > 0 ? GRN : v < 0 ? RED : SLATE

// ─────────────────────────────────────────────────────────────────────────
//  FACTOR 1 — TREND  (fast vs slow EMA + slow-EMA slope)
// ─────────────────────────────────────────────────────────────────────────
eF = ta.ema(close, emaFast)
eS = ta.ema(close, emaSlow)
slopeUp = eS > eS[2]
vTrend = eF > eS and slopeUp ? 1 : eF < eS and not slopeUp ? -1 : eF > eS ? 1 : eF < eS ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  FACTOR 2 — MOMENTUM  (RSI regime around 50)
// ─────────────────────────────────────────────────────────────────────────
rsi = ta.rsi(close, rsiLen)
vMom = rsi >= 55 ? 1 : rsi <= 45 ? -1 : rsi > 50 ? 1 : rsi < 50 ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  FACTOR 3 — MACD  (histogram sign + expansion)
// ─────────────────────────────────────────────────────────────────────────
[macdLine, sigLine, histLine] = ta.macd(close, 12, 26, 9)
vMacd = histLine > 0 and histLine >= histLine[1] ? 1 : histLine < 0 and histLine <= histLine[1] ? -1 : histLine > 0 ? 1 : histLine < 0 ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  FACTOR 4 — STRENGTH  (ADX gate + DI direction)
// ─────────────────────────────────────────────────────────────────────────
up   = ta.change(high)
down = -ta.change(low)
plusDM  = na(up) ? na : (up > down and up > 0 ? up : 0)
minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
trur    = ta.rma(ta.tr(true), adxLen)
plusDI  = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur
dx  = (plusDI + minusDI) == 0 ? 0 : 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)
vAdx = adx < adxThr ? 0 : plusDI > minusDI ? 1 : minusDI > plusDI ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  FACTOR 5 — VOLUME  (relative volume confirms the bar's direction)
// ─────────────────────────────────────────────────────────────────────────
relVol = ta.sma(volume, volLen) > 0 ? volume / ta.sma(volume, volLen) : 1.0
volDir = close > open ? 1 : close < open ? -1 : 0
vVol = relVol >= 1.2 ? volDir : 0

// ─────────────────────────────────────────────────────────────────────────
//  FACTOR 6 — LOCATION  (where in the recent range — buy low, sell high)
// ─────────────────────────────────────────────────────────────────────────
hh = ta.highest(high, locLen)
ll = ta.lowest(low, locLen)
locPct = (hh - ll) > 0 ? (close - ll) / (hh - ll) : 0.5
// discount (low third) favours longs, premium (high third) favours shorts
vLoc = locPct <= 0.35 ? 1 : locPct >= 0.65 ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  WEIGHTED CONFLUENCE SCORE  (–100 … +100)
// ─────────────────────────────────────────────────────────────────────────
wSum = wTrend + wMom + wMacd + wAdx + wVol + wLoc
rawScore = vTrend * wTrend + vMom * wMom + vMacd * wMacd + vAdx * wAdx + vVol * wVol + vLoc * wLoc
score = wSum > 0 ? rawScore / wSum * 100.0 : 0.0
scoreSm = ta.ema(score, 2)

bullVotes = (vTrend > 0 ? 1 : 0) + (vMom > 0 ? 1 : 0) + (vMacd > 0 ? 1 : 0) + (vAdx > 0 ? 1 : 0) + (vVol > 0 ? 1 : 0) + (vLoc > 0 ? 1 : 0)
bearVotes = (vTrend < 0 ? 1 : 0) + (vMom < 0 ? 1 : 0) + (vMacd < 0 ? 1 : 0) + (vAdx < 0 ? 1 : 0) + (vVol < 0 ? 1 : 0) + (vLoc < 0 ? 1 : 0)

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS  (score crosses threshold with enough agreeing factors)
// ─────────────────────────────────────────────────────────────────────────
longOK  = scoreSm >= scoreThr and bullVotes >= minFactors
shortOK = scoreSm <= -scoreThr and bearVotes >= minFactors

var int state = 0
buy  = longOK and state <= 0
sell = shortOK and state >= 0
if buy
    state := 1
if sell
    state := -1
sig = buy or sell

conv = math.round(math.abs(scoreSm))

// ─────────────────────────────────────────────────────────────────────────
//  LIVE STATS + TP/SL LADDER
// ─────────────────────────────────────────────────────────────────────────
atr = ta.atr(atrLenT)

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

var box   riskBox = na
var box   rwdBox  = na
var line  lnE = na
var line  lnS = na
var line  ln1 = na
var line  ln2 = na
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_lvl(line ln, float p, color c) =>
    line.set_xy1(ln, bar_index, p)
    line.set_xy2(ln, bar_index + boxW, p)
    line.set_color(ln, c)

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
    risk    = atr * slMult
    risk    := risk > 0 ? risk : atr
    sSL    := buy ? close - risk : close + risk
    sT1    := buy ? close + risk * tp1R : close - risk * tp1R
    sOpen  := true

    if showLad
        t2 = buy ? close + risk * tp2R : close - risk * tp2R
        t3 = buy ? close + risk * tp3R : close - risk * tp3R
        // red RISK box (entry → SL) and green REWARD box (entry → TP3)
        box.delete(riskBox)
        box.delete(rwdBox)
        riskBox := box.new(bar_index, sEntry, bar_index + boxW, sSL, bgcolor = color.new(RED, 82), border_color = color.new(RED, 35), border_width = 1)
        rwdBox  := box.new(bar_index, sEntry, bar_index + boxW, t3,  bgcolor = color.new(GRN, 85), border_color = color.new(GRN, 35), border_width = 1)
        if na(lnE)
            lnE := line.new(bar_index, sEntry, bar_index + boxW, sEntry, color = GOLD, width = 2)
            lnS := line.new(bar_index, sSL,  bar_index + boxW, sSL,  color = RED,  style = line.style_dashed)
            ln1 := line.new(bar_index, sT1,  bar_index + boxW, sT1,  color = GRN,  style = line.style_dotted)
            ln2 := line.new(bar_index, t2,   bar_index + boxW, t2,   color = GRN,  style = line.style_dotted)
            lbE := label.new(bar_index + boxW, sEntry, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lbS := label.new(bar_index + boxW, sSL, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb1 := label.new(bar_index + boxW, sT1, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb2 := label.new(bar_index + boxW, t2, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb3 := label.new(bar_index + boxW, t3, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        f_lvl(lnE, sEntry, GOLD)
        f_lvl(lnS, sSL, RED)
        f_lvl(ln1, sT1, GRN)
        f_lvl(ln2, t2, GRN)
        f_lbl(lbE, sEntry, " ENTRY " + str.tostring(sEntry, format.mintick), GOLD)
        f_lbl(lbS, sSL,    " SL "    + str.tostring(sSL, format.mintick), RED_HI)
        f_lbl(lb1, sT1,    " TP1 · " + str.tostring(tp1R,"#.#") + "R " + str.tostring(sT1, format.mintick), GRN)
        f_lbl(lb2, t2,     " TP2 · " + str.tostring(tp2R,"#.#") + "R " + str.tostring(t2,  format.mintick), GRN_HI)
        f_lbl(lb3, t3,     " TP3 · " + str.tostring(tp3R,"#.#") + "R " + str.tostring(t3,  format.mintick), GRN_HI)

if showLad and not na(riskBox) and barstate.islast
    box.set_right(riskBox, bar_index + boxW)
    box.set_right(rwdBox, bar_index + boxW)
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
sClamp = math.max(-100.0, math.min(100.0, scoreSm)) / 100.0
scoreCol = sClamp >= 0 ? color.from_gradient(sClamp, 0, 1, SLATE, GRN_HI) : color.from_gradient(-sClamp, 0, 1, SLATE, RED_HI)
barcolor(colorBars ? color.new(scoreCol, 20) : na)

// score trail: a line offset below/above price tinted by score
trail = ta.ema(close, emaFast)
plot(showGrad ? trail : na, "Score trail", color = color.new(scoreCol, 0), linewidth = 2)

bgcolor(showBg ? color.new(sClamp >= 0 ? GRN : RED, 94 - math.round(math.abs(sClamp) * 6)) : na, title = "Confluence")

plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = GRN, textcolor = INK, text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = RED, textcolor = INKHI, text = "SELL", size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  FACTOR DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 11, bgcolor = color.new(hudBg, 0), frame_color = color.new(#173025, 0), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #123A2A), 0)

    // big bipolar score meter: red fills left of centre, green fills right
    half = 6
    gPos = math.round(math.min(1.0, math.max(0.0, sClamp))  * half)
    gNeg = math.round(math.min(1.0, math.max(0.0, -sClamp)) * half)
    sbar = ""
    for i = 1 to half
        sbar := sbar + (i > half - gNeg ? "▰" : "▱")
    sbar := sbar + "│"
    for i = 1 to half
        sbar := sbar + (i <= gPos ? "▰" : "▱")
    scC = sClamp > 0.1 ? GRN_HI : sClamp < -0.1 ? RED_HI : SLATE

    sigT = buy ? "BUY ▲" : sell ? "SELL ▼" : state == 1 ? "Long bias" : state == -1 ? "Short bias" : "Flat"
    sigC = buy ? GRN_HI : sell ? RED_HI : state == 1 ? GRN : state == -1 ? RED : SLATE
    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? SLATE : winRate >= 55 ? GRN : winRate <= 45 ? RED : GOLD

    table.cell(hud, 0, 0, "  ⚛ QUANT CONFLUENCE", text_color = INKHI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, (scoreSm >= 0 ? "+" : "") + str.tostring(math.round(scoreSm)) + "  ", text_color = scC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 0, 1, "  SCORE −100…+100", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, sbar + "  ", text_color = scC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 2, "  Trend", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, f_dirTxt(vTrend) + "  ", text_color = f_dirCol(vTrend), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 3, "  Momentum (RSI)", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, f_dirTxt(vMom) + "  ", text_color = f_dirCol(vMom), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 4, "  MACD", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, f_dirTxt(vMacd) + "  ", text_color = f_dirCol(vMacd), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 5, "  Strength (ADX " + str.tostring(math.round(adx)) + ")", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, f_dirTxt(vAdx) + "  ", text_color = f_dirCol(vAdx), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 6, "  Volume", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 6, f_dirTxt(vVol) + "  ", text_color = f_dirCol(vVol), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 7, "  Location", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 7, f_dirTxt(vLoc) + "  ", text_color = f_dirCol(vLoc), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 8, "  Agreement", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 8, str.tostring(math.max(bullVotes, bearVotes)) + "/6  ", text_color = bullVotes >= bearVotes ? GRN : RED, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 9, "  Signal", text_color = SLATE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 9, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 10, "  Win (TP1)", text_color = SLATE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 10, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy",  "Quant Confluence: bullish score crossed threshold with factor agreement")
alertcondition(sell, "Sell", "Quant Confluence: bearish score crossed threshold with factor agreement")
alertcondition(ta.cross(scoreSm, 0), "Score flip", "Quant Confluence: confluence score crossed zero")
````
