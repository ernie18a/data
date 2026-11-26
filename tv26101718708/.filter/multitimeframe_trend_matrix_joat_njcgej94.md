# Multi-Timeframe Trend Matrix [JOAT]

- url: https://www.tradingview.com/script/NjcGEJ94-Multi-Timeframe-Trend-Matrix-JOAT/
- type: indicator
- pine_id: PUB;4e8356b868564d6a8314a9eff9e56ef0
- version: 1.0

## Description

[b]Multi-Timeframe Trend Matrix [JOAT][/b]
[i]Reads several timeframes with several methods at once and scores their agreement into a single alignment signal — without lookahead.[/i]

[image]https://www.tradingview.com/x/60Imwe1k/[/image]

[b]What it is[/b]
Trading a single timeframe blinds you to the larger context; watching many by eye is slow and inconsistent. This indicator evaluates a grid of timeframes and trend methods, turns the whole grid into one alignment score, and signals when top-down agreement forms. It is an original multi-timeframe aggregation tool built to avoid the common pitfalls of higher-timeframe requests.

[b]How it works[/b]
• [b]The matrix[/b] — a set of higher and lower timeframes is each assessed by several independent trend methods (such as a moving-average relationship, a directional trend measure and a momentum read). Each cell of the grid returns simply bullish or bearish, so the picture is easy to interpret.

• [b]No lookahead[/b] — every higher-timeframe value is pulled with lookahead disabled, so the indicator never borrows future data from an unclosed higher-timeframe bar. This is a deliberate, disclosed design choice that keeps the signals honest and non-repainting on historical bars.

• [b]Alignment score[/b] — the grid is condensed into one signed score representing how strongly all timeframes and methods agree. Full agreement produces a strong reading; a split grid produces a weak, near-neutral one.

• [b]State-machine signals[/b] — a Buy fires when alignment turns sufficiently bullish from a non-bullish state; a Sell is the mirror. Requiring a state change means the matrix will not re-signal the same direction repeatedly — the signals are self-spacing.

[b]Trade levels[/b]
Each signal draws a red risk box to the ATR stop and a green reward box to the third target, with inner dividers and right-edge labels for entry, stop and each take-profit at your R multiples.

[b]The dashboard[/b]
An adjustable alignment-matrix panel displays every timeframe-by-method cell as bullish or bearish, a bipolar alignment-score headline, the active signal, a conviction estimate, and a live first-target-before-stop tally from closed bars only. The grid shows exactly which timeframes agree and which disagree.

[b]How to use it[/b]
• Works on any asset; pick a base timeframe and let the grid supply the higher-timeframe context.
• Favour entries when the grid is broadly aligned; be cautious when it is mixed.
• Use it as a top-down filter alongside your own entry method, or take its aligned signals directly.

[b]Settings[/b]
The set of timeframes, the methods and their lengths, the alignment threshold, ATR risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
The contribution is the aggregation framework: a disciplined, lookahead-free multi-timeframe, multi-method grid condensed into one transparent alignment score with a state-machine trigger. Seeing the full grid — not just a final arrow — is what lets a trader trust or override the signal for themselves.

[b]Notes and limitations[/b]
• Higher-timeframe values update only as those bars close, so alignment can shift when a higher-timeframe bar completes — this is expected and prevents lookahead bias.
• Strong alignment can still precede a reversal; agreement is context, not certainty.
• The tally reflects only past bars on the current chart and is not a forecast.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Multi-Timeframe Trend Matrix [JOAT]", "MTF Matrix [JOAT]", overlay = true, max_labels_count = 300, max_lines_count = 100, max_boxes_count = 20)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (CYBERPUNK — near-black + neon)
// ─────────────────────────────────────────────────────────────────────────
CYAN   = #00E5FF
MAG    = #FF2E9A
PURP   = #A64BFF
LIME   = #7CFF5A
AMBER  = #FFC24B
INK    = #05070E
INKHI  = #EAF2FF
MUTE   = #5A6B8C

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS — TIMEFRAMES
// ─────────────────────────────────────────────────────────────────────────
gTF   = "Higher Timeframes"
tf1   = input.timeframe("5",   "TF 1", group = gTF)
tf2   = input.timeframe("15",  "TF 2", group = gTF)
tf3   = input.timeframe("60",  "TF 3", group = gTF)
tf4   = input.timeframe("240", "TF 4", group = gTF)
tf5   = input.timeframe("D",   "TF 5", group = gTF)
tf6   = input.timeframe("W",   "TF 6", group = gTF)

gMTF  = "MTF Trend Read"
htfFast = input.int(21, "HTF EMA fast", minval = 2, group = gMTF)
htfSlow = input.int(55, "HTF EMA slow", minval = 2, group = gMTF)

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS — CHART METHODS
// ─────────────────────────────────────────────────────────────────────────
gM    = "Chart-TF Methods"
emaF  = input.int(9,  "EMA stack fast", minval = 2, group = gM)
emaM  = input.int(21, "EMA stack mid",  minval = 2, group = gM)
emaS  = input.int(55, "EMA stack slow", minval = 2, group = gM)
stAtr = input.int(10, "Supertrend ATR", minval = 1, group = gM)
stMul = input.float(3.0, "Supertrend mult", minval = 0.5, step = 0.5, group = gM)
rsiLen= input.int(14, "RSI length", minval = 2, group = gM)

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS — SIGNALS
// ─────────────────────────────────────────────────────────────────────────
gS    = "Signals"
alnThr= input.float(55, "Alignment trigger (0–100)", minval = 10, maxval = 100, step = 5, group = gS, tooltip = "Absolute alignment score needed to arm a Buy/Sell.")
needMom = input.bool(true, "Require chart momentum confirm", group = gS, tooltip = "Buy also needs MACD histogram > 0 and RSI > 50 (mirror for Sell).")

gTr   = "Trade Levels"
showLad = input.bool(true, "Show TP/SL boxes", group = gTr)
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gTr)
atrLenT = input.int(14, "ATR length", minval = 1, group = gTr)
slMult  = input.float(1.5, "SL = ATR ×", minval = 0.1, step = 0.1, group = gTr)
tp1R    = input.float(1.0, "TP1 (R)", step = 0.5, group = gTr)
tp2R    = input.float(2.0, "TP2 (R)", step = 0.5, group = gTr)
tp3R    = input.float(3.0, "TP3 (R)", step = 0.5, group = gTr)

gV    = "Visuals"
colorBars = input.bool(true, "Score-graded candles", group = gV)
showBg    = input.bool(true, "Alignment background", group = gV)

gP    = "Dashboard"
showHUD = input.bool(true, "Show trend matrix", group = gP)
hudPos  = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#05070E, "Background", group = gP)

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
f_dirCol(int v) => v > 0 ? LIME : v < 0 ? MAG : MUTE

// HTF composite trend: EMA stack + price-vs-fast-EMA, collapsed to –1/0/+1.
// Declared before use; called INSIDE request.security so it runs on the HTF.
f_htfTrend() =>
    ef = ta.ema(close, htfFast)
    es = ta.ema(close, htfSlow)
    a  = ef > es ? 1 : ef < es ? -1 : 0
    b  = close > ef ? 1 : close < ef ? -1 : 0
    a + b > 0 ? 1 : a + b < 0 ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  MTF TREND READS  (NON-REPAINTING ON HISTORY)
// ----------------------------------------------------------------------------
//  lookahead_off guarantees no future HTF data ever leaks into the past, so
//  every historical bar reads a CLOSED higher-timeframe value and never
//  repaints. The forming HTF bar naturally updates intra-bar in real time
//  (standard MTF behaviour); signals are read on chart-bar close.
// ─────────────────────────────────────────────────────────────────────────
// lookahead_off = no future leak. The forming HTF bar updates intrabar (normal);
// signals are read on chart-bar close, so history is stable / non-repainting.
mt1 = request.security(syminfo.tickerid, tf1, f_htfTrend(), lookahead = barmerge.lookahead_off)
mt2 = request.security(syminfo.tickerid, tf2, f_htfTrend(), lookahead = barmerge.lookahead_off)
mt3 = request.security(syminfo.tickerid, tf3, f_htfTrend(), lookahead = barmerge.lookahead_off)
mt4 = request.security(syminfo.tickerid, tf4, f_htfTrend(), lookahead = barmerge.lookahead_off)
mt5 = request.security(syminfo.tickerid, tf5, f_htfTrend(), lookahead = barmerge.lookahead_off)
mt6 = request.security(syminfo.tickerid, tf6, f_htfTrend(), lookahead = barmerge.lookahead_off)

v1 = int(nz(mt1))
v2 = int(nz(mt2))
v3 = int(nz(mt3))
v4 = int(nz(mt4))
v5 = int(nz(mt5))
v6 = int(nz(mt6))

// ─────────────────────────────────────────────────────────────────────────
//  CHART-TIMEFRAME METHODS  (each votes –1 / +1)
// ─────────────────────────────────────────────────────────────────────────
// METHOD 1 — EMA stack
cF = ta.ema(close, emaF)
cM = ta.ema(close, emaM)
cS = ta.ema(close, emaS)
mStack = cF > cM and cM > cS ? 1 : cF < cM and cM < cS ? -1 : cF > cS ? 1 : -1

// METHOD 2 — Supertrend direction
[stLine, stDir] = ta.supertrend(stMul, stAtr)
mSt = stDir < 0 ? 1 : -1   // ta.supertrend: dir = -1 uptrend, +1 downtrend

// METHOD 3 — RSI regime
rsi = ta.rsi(close, rsiLen)
mRsi = rsi >= 50 ? 1 : -1

// METHOD 4 — MACD histogram sign
[macdLine, sigLine, histLine] = ta.macd(close, 12, 26, 9)
mMacd = histLine >= 0 ? 1 : -1

// ─────────────────────────────────────────────────────────────────────────
//  AGGREGATE ALIGNMENT SCORE  (–100 … +100)
// ─────────────────────────────────────────────────────────────────────────
mtfSum = v1 + v2 + v3 + v4 + v5 + v6
mthSum = mStack + mSt + mRsi + mMacd
rawSum = mtfSum + mthSum
// max magnitude = 6 (HTF) + 4 (methods) = 10
score  = rawSum / 10.0 * 100.0
scoreSm= ta.ema(score, 2)

bullVotes = (v1 > 0 ? 1 : 0) + (v2 > 0 ? 1 : 0) + (v3 > 0 ? 1 : 0) + (v4 > 0 ? 1 : 0) + (v5 > 0 ? 1 : 0) + (v6 > 0 ? 1 : 0) + (mStack > 0 ? 1 : 0) + (mSt > 0 ? 1 : 0) + (mRsi > 0 ? 1 : 0) + (mMacd > 0 ? 1 : 0)
bearVotes = (v1 < 0 ? 1 : 0) + (v2 < 0 ? 1 : 0) + (v3 < 0 ? 1 : 0) + (v4 < 0 ? 1 : 0) + (v5 < 0 ? 1 : 0) + (v6 < 0 ? 1 : 0) + (mStack < 0 ? 1 : 0) + (mSt < 0 ? 1 : 0) + (mRsi < 0 ? 1 : 0) + (mMacd < 0 ? 1 : 0)

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS  (alignment crosses threshold + chart-TF momentum confirms)
// ─────────────────────────────────────────────────────────────────────────
momUp   = histLine > 0 and rsi > 50
momDn   = histLine < 0 and rsi < 50
longOK  = scoreSm >=  alnThr and (not needMom or momUp)
shortOK = scoreSm <= -alnThr and (not needMom or momDn)

var int state = 0
buy  = longOK and state <= 0
sell = shortOK and state >= 0
if buy
    state := 1
if sell
    state := -1
sig = buy or sell

// ─────────────────────────────────────────────────────────────────────────
//  LIVE STATS + TP/SL LADDER
// ─────────────────────────────────────────────────────────────────────────
atr = ta.atr(atrLenT)

var float sSL   = na
var float sT1   = na
var float sEntry= na
var int   sDir  = 0
var bool  sOpen = false
var int   wins  = 0
var int   losses= 0

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

// ── TP/SL BOXES  (red risk entry→SL, green reward entry→TP3) ──
var box   riskBox = na
var box   rewBox  = na
var line  lnEntry = na
var line  lnSL    = na
var line  lnTP1   = na
var line  lnTP2   = na
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_setLine(line ln, float p, color c) =>
    line.set_xy1(ln, bar_index, p)
    line.set_xy2(ln, bar_index + boxW, p)
    line.set_color(ln, c)

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
    risk   := risk > 0 ? risk : atr          // never a zero-height box
    sSL    := buy ? close - risk : close + risk
    sT1    := buy ? close + risk * tp1R : close - risk * tp1R
    sOpen  := true

    if showLad
        t2  = buy ? close + risk * tp2R : close - risk * tp2R
        t3  = buy ? close + risk * tp3R : close - risk * tp3R
        // red RISK box (entry→SL) + green REWARD box (entry→TP3)
        box.delete(riskBox)
        box.delete(rewBox)
        riskBox := box.new(bar_index, sEntry, bar_index + boxW, sSL, bgcolor = color.new(MAG, 82), border_color = color.new(MAG, 35), border_width = 1)
        rewBox  := box.new(bar_index, sEntry, bar_index + boxW, t3,  bgcolor = color.new(LIME, 85), border_color = color.new(LIME, 35), border_width = 1)
        if na(lnEntry)
            lnEntry := line.new(bar_index, sEntry, bar_index + boxW, sEntry, color = AMBER, width = 2)
            lnSL    := line.new(bar_index, sSL, bar_index + boxW, sSL, color = MAG, style = line.style_dashed)
            lnTP1   := line.new(bar_index, sT1, bar_index + boxW, sT1, color = color.new(LIME, 30), style = line.style_dotted)
            lnTP2   := line.new(bar_index, t2,  bar_index + boxW, t2,  color = color.new(LIME, 30), style = line.style_dotted)
            lbE := label.new(bar_index + boxW, sEntry, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lbS := label.new(bar_index + boxW, sSL, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb1 := label.new(bar_index + boxW, sT1, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb2 := label.new(bar_index + boxW, t2, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb3 := label.new(bar_index + boxW, t3, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        f_setLine(lnEntry, sEntry, AMBER)
        f_setLine(lnSL, sSL, MAG)
        f_setLine(lnTP1, sT1, color.new(LIME, 30))
        f_setLine(lnTP2, t2,  color.new(LIME, 30))
        f_setLbl(lbE, sEntry, " ENTRY " + str.tostring(sEntry, format.mintick), AMBER)
        f_setLbl(lbS, sSL, " SL " + str.tostring(sSL, format.mintick), MAG)
        f_setLbl(lb1, sT1, " TP1 · " + str.tostring(tp1R, "#.#") + "R " + str.tostring(sT1, format.mintick), LIME)
        f_setLbl(lb2, t2,  " TP2 · " + str.tostring(tp2R, "#.#") + "R " + str.tostring(t2, format.mintick), LIME)
        f_setLbl(lb3, t3,  " TP3 · " + str.tostring(tp3R, "#.#") + "R " + str.tostring(t3, format.mintick), LIME)

// keep the active trade graphic pinned to the right edge
if showLad and not na(riskBox) and barstate.islast
    box.set_right(riskBox, bar_index + boxW)
    box.set_right(rewBox, bar_index + boxW)
    line.set_x2(lnEntry, bar_index + boxW)
    line.set_x2(lnSL, bar_index + boxW)
    line.set_x2(lnTP1, bar_index + boxW)
    line.set_x2(lnTP2, bar_index + boxW)
    label.set_x(lbE, bar_index + boxW)
    label.set_x(lbS, bar_index + boxW)
    label.set_x(lb1, bar_index + boxW)
    label.set_x(lb2, bar_index + boxW)
    label.set_x(lb3, bar_index + boxW)

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS  (global scope, constant styles)
// ─────────────────────────────────────────────────────────────────────────
sClamp   = math.max(-100.0, math.min(100.0, scoreSm)) / 100.0
scoreCol = sClamp >= 0 ? color.from_gradient(sClamp, 0, 1, MUTE, LIME) : color.from_gradient(-sClamp, 0, 1, MUTE, MAG)
barcolor(colorBars ? color.new(scoreCol, 15) : na, title = "Score candles")

bgcolor(showBg ? color.new(sClamp >= 0 ? LIME : MAG, 94 - math.round(math.abs(sClamp) * 6)) : na, title = "Alignment")

plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = LIME, textcolor = INK,   text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = MAG,  textcolor = INKHI, text = "SELL", size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  CYBERPUNK TREND MATRIX DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 17, bgcolor = color.new(hudBg, 0), frame_color = color.new(PURP, 40), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, PURP), 15)
    DIVR  = color.new(PURP, 68)

    scoreV = math.round(scoreSm)
    scC = sClamp > 0.1 ? LIME : sClamp < -0.1 ? MAG : MUTE

    // ── big bipolar ALIGNMENT SCORE meter: magenta left half, lime right half,
    //    meeting at centre (col0 right-aligned bear side, col1 left-aligned bull) ──
    nNeg = math.round(math.max(0.0, -sClamp) * 8)
    nPos = math.round(math.max(0.0,  sClamp) * 8)
    negBar = ""
    for i = 1 to 8
        negBar := negBar + (i <= 8 - nNeg ? "▱" : "▰")
    posBar = ""
    for i = 1 to 8
        posBar := posBar + (i <= nPos ? "▰" : "▱")

    sigT = buy ? "BUY ▲" : sell ? "SELL ▼" : state == 1 ? "Long bias" : state == -1 ? "Short bias" : "Flat"
    sigC = buy ? LIME : sell ? MAG : state == 1 ? CYAN : state == -1 ? MAG : MUTE
    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? LIME : winRate <= 45 ? MAG : AMBER

    // ── HEADLINE: alignment score + two-tone meter + vote tally ──
    table.cell(hud, 0, 0, "  ◈ ALIGNMENT MATRIX", text_color = INKHI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, (scoreV > 0 ? "+" : "") + str.tostring(scoreV) + "  ", text_color = scC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 0, 1, negBar, text_color = MAG, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, posBar, text_color = LIME, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 2, "  Bull / Bear vote", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, str.tostring(bullVotes) + " ▲ / " + str.tostring(bearVotes) + " ▼  ", text_color = bullVotes >= bearVotes ? LIME : MAG, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    // ── HTF matrix ──
    table.cell(hud, 0, 3, "  HIGHER TIMEFRAMES", text_color = PURP, text_halign = text.align_left, bgcolor = DIVR, text_size = hudTS)
    table.cell(hud, 1, 3, "  ", text_color = PURP, text_halign = text.align_right, bgcolor = DIVR, text_size = hudTS)
    table.cell(hud, 0, 4, "  " + tf1, text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, f_dirTxt(v1) + "  ", text_color = f_dirCol(v1), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 5, "  " + tf2, text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, f_dirTxt(v2) + "  ", text_color = f_dirCol(v2), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 6, "  " + tf3, text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 6, f_dirTxt(v3) + "  ", text_color = f_dirCol(v3), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 7, "  " + tf4, text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 7, f_dirTxt(v4) + "  ", text_color = f_dirCol(v4), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 8, "  " + tf5, text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 8, f_dirTxt(v5) + "  ", text_color = f_dirCol(v5), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 9, "  " + tf6, text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 9, f_dirTxt(v6) + "  ", text_color = f_dirCol(v6), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    // ── chart-method matrix ──
    table.cell(hud, 0, 10, "  CHART METHODS", text_color = PURP, text_halign = text.align_left, bgcolor = DIVR, text_size = hudTS)
    table.cell(hud, 1, 10, "  ", text_color = PURP, text_halign = text.align_right, bgcolor = DIVR, text_size = hudTS)
    table.cell(hud, 0, 11, "  EMA stack", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 11, f_dirTxt(mStack) + "  ", text_color = f_dirCol(mStack), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 12, "  Supertrend", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 12, f_dirTxt(mSt) + "  ", text_color = f_dirCol(mSt), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 13, "  RSI " + str.tostring(math.round(rsi)), text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 13, f_dirTxt(mRsi) + "  ", text_color = f_dirCol(mRsi), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 14, "  MACD hist", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 14, f_dirTxt(mMacd) + "  ", text_color = f_dirCol(mMacd), text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    // ── signal + live win-rate ──
    table.cell(hud, 0, 15, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 15, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 16, "  Win (TP1)", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 16, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy",  "MTF Matrix: alignment crossed bullish threshold with momentum confirm")
alertcondition(sell, "Sell", "MTF Matrix: alignment crossed bearish threshold with momentum confirm")
alertcondition(ta.cross(scoreSm, 0), "Alignment flip", "MTF Matrix: aggregate alignment score crossed zero")
````
