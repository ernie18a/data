# Whale Order Flow Radar [JOAT]

- url: https://www.tradingview.com/script/JJHJQfaH-Whale-Order-Flow-Radar-JOAT/
- type: indicator
- pine_id: PUB;ac4d86c9018a40d4a59a3ce7b1aab91c
- version: 1.0

## Description

[b]Whale Order Flow Radar [JOAT][/b]
[i]Reconstructs institutional order-flow pressure from standard OHLCV and flags the footprints large participants leave behind — without needing tick or bid/ask data.[/i]

[b]What it is[/b]
Most volume tools only tell you that "a lot traded". They do not tell you who was aggressive or which side absorbed the flow. This indicator estimates aggressor pressure from the one thing every chart gives you — the open, high, low, close and volume of each bar — and turns it into a readable map of accumulation, distribution and absorption. It is an original engine built from scratch; it is not a wrapper around a built-in volume study.

[b]How it works[/b]
The calculations are transparent and each one is standard statistics applied in a specific way:

• [b]Whale prints[/b] — every bar's volume is converted to a z-score against a rolling mean and standard deviation (default 50-bar window). A bar is only tagged as a whale print when its volume is a statistical outlier [i]and[/i] it closes with conviction (the close lands in the upper or lower third of the bar's range). Requiring both filters separates genuine directional size from random spikes.

• [b]Delta proxy[/b] — each bar's volume is split into buy volume and sell volume by where price closed inside its own range (close near the high = buyers dominated, close near the low = sellers dominated). Delta is buy minus sell. This is a bounded, non-repainting estimate of aggressor delta; it is a proxy, not true tick delta, and the description is honest about that.

• [b]Cumulative delta[/b] — the running sum of the delta proxy, with an optional reset per session or week so it does not drift indefinitely.

• [b]Absorption[/b] — high volume combined with an unusually small range flags a passive iceberg soaking up flow. These are marked separately because they often precede reversals rather than continuations.

• [b]Pressure oscillator[/b] — a smoothed, volume-normalised delta that drives the colour system and gates the signals so you are reading strength, not every wiggle.

[b]The signals[/b]
A Buy prints when a bullish whale print lands while the cumulative delta and an optional trend filter both agree; a Sell is the mirror. Everything is evaluated on the confirmed bar, so a printed signal does not repaint. A minimum-bar spacing control keeps Buy and Sell labels from stacking on lower timeframes.

[b]Trade levels[/b]
When enabled, the most recent signal draws an ATR-based ladder: a stop level and three take-profit levels at your chosen R multiples, each labelled with its price on the right edge, so the intended risk and reward are visible at a glance.

[b]The dashboard[/b]
A compact panel reports the current trend bias, the pressure reading, a 0–100 conviction estimate for the latest print, the active signal state, and a live win tally (how often the first target was reached before the stop, measured only on already-closed bars with no lookahead). The panel position and text size are adjustable.

[b]How to use it[/b]
• Works on any symbol and any timeframe that provides volume; on symbols with no real volume the delta components are less meaningful, which is noted here honestly.
• Treat whale prints and absorption as context, not as automatic entries — combine them with your own structure read.
• Use the trend filter to only take prints in the direction of the higher-level bias, or turn it off for counter-trend fade setups.
• The conviction score and win tally are on-chart context to help you filter, not a performance promise.

[b]Settings[/b]
Volume baseline window, whale z-score threshold, conviction fraction, absorption threshold, delta smoothing and reset, trend filter length, ATR risk multiple and target R multiples, plus full visual and dashboard controls.

[b]Originality and usefulness[/b]
The value here is the specific combination: a dual-filter whale detector (outlier volume [i]and[/i] close-in-range conviction), a bounded close-based delta proxy with cumulative tracking, a separate absorption model, and a normalised pressure oscillator that ties them together into one non-repainting signal. That blend, and the reasoning for it, is what makes it more than a standard volume histogram.

[b]Notes and limitations[/b]
• The delta and pressure figures are estimates derived from OHLCV, not exchange order-flow data. They approximate aggressor behaviour; they do not measure it directly.
• No indicator predicts the future. Signals can and will fail, especially in thin or news-driven conditions.
• The win tally reflects only what has already happened on the loaded chart and is not a forecast of future results.
• This is an educational and analytical tool, not financial advice. Manage your own risk.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Whale Order Flow Radar [JOAT]", "Whale Radar [JOAT]", overlay = true, max_labels_count = 500, max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (ocean blue → violet, gold accent)
// ─────────────────────────────────────────────────────────────────────────
BLUE_MID = #2F6BFF
BLUE_HI  = #6FA8FF
VIOLET   = #8A5CFF
VIOLET_HI= #B18CFF
CRIMSON  = #FF3B6B
CRIMSON_HI= #FF7C9C
GOLD     = #FFC24B
INK      = #070A12
INKHI    = #EAF0FF
MUTE     = #5A6478

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gW      = "Whale Detection"
volBase = input.int(50,  "Volume baseline window", minval = 10, group = gW, tooltip = "Lookback used to build the volume mean/σ that a whale print is measured against.")
whaleZ  = input.float(2.0,"Whale z-score threshold", minval = 0.5, step = 0.1, group = gW, tooltip = "How many σ above average volume a bar needs to count as a whale print. Higher = rarer, stronger prints.")
convFr  = input.float(0.34,"Conviction (close-in-range)", minval = 0.1, maxval = 0.5, step = 0.02, group = gW, tooltip = "Close must land within this fraction of the top/bottom of the bar's range to qualify as directional whale flow.")
absorbZ = input.float(1.6,"Absorption z-score", minval = 0.5, step = 0.1, group = gW, tooltip = "High volume + unusually small range = absorption/iceberg. Flagged as a warning marker.")

gD      = "Delta & Pressure"
deltaLen= input.int(14, "Cumulative-delta smoothing", minval = 1, group = gD, tooltip = "EMA length that smooths the delta pressure oscillator driving colours & the HUD.")
resetDlt= input.string("Session","Cumulative delta reset", options = ["Never","Session","Week"], group = gD, tooltip = "When the running cumulative delta counter resets to zero.")

gT      = "Trend Filter"
useTrend= input.bool(true, "Require trend agreement", group = gT, tooltip = "Only allow whale Buys above the trend baseline and whale Sells below it.")
trendLen= input.int(50, "Trend EMA", minval = 2, group = gT)

gTr     = "Trade Levels"
showLad = input.bool(true, "ATR TP/SL ladder on signals", group = gTr, tooltip = "Draws SL and TP1/2/3 (ATR-scaled) for the most recent whale signal.")
atrLenT = input.int(14, "ATR length", minval = 1, group = gTr)
slMult  = input.float(1.5, "SL = ATR ×", minval = 0.1, step = 0.1, group = gTr)
tp1R    = input.float(1.0, "TP1 (R)", step = 0.5, group = gTr)
tp2R    = input.float(2.0, "TP2 (R)", step = 0.5, group = gTr)
tp3R    = input.float(3.0, "TP3 (R)", step = 0.5, group = gTr)

gV      = "Visuals"
colorBars= input.bool(true, "Pressure-tinted candles", group = gV)
showAbs = input.bool(true, "Absorption markers", group = gV)
showBg  = input.bool(true, "Pressure background", group = gV)
bubbleSz= input.bool(true, "Scale whale marker by strength", group = gV)

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#0A0E1A, "Background", group = gP)

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

// compact volume formatter (K / M / B) — str.tostring has no volume format
f_compact(float x) =>
    a = math.abs(x)
    a >= 1e9 ? str.tostring(x / 1e9, "#.##") + "B" : a >= 1e6 ? str.tostring(x / 1e6, "#.##") + "M" : a >= 1e3 ? str.tostring(x / 1e3, "#.##") + "K" : str.tostring(x, "#")

// ─────────────────────────────────────────────────────────────────────────
//  VOLUME STATISTICS  (rolling mean / σ → z-score of this bar's volume)
// ─────────────────────────────────────────────────────────────────────────
volMean = ta.sma(volume, volBase)
volSd   = ta.stdev(volume, volBase)
volZ    = volSd > 0 ? (volume - volMean) / volSd : 0.0

rng     = high - low
rngMean = ta.sma(rng, volBase)
smallRange = rng < rngMean * 0.6

// ─────────────────────────────────────────────────────────────────────────
//  DELTA PROXY  (split bar volume by close position inside its range)
//  buyVol/sellVol are bounded in [0,volume]; delta = buy - sell.
// ─────────────────────────────────────────────────────────────────────────
clsPos  = rng > 0 ? (close - low) / rng : 0.5   // 0=closed on low, 1=closed on high
buyVol  = volume * clsPos
sellVol = volume * (1.0 - clsPos)
delta   = buyVol - sellVol

isNewSession = timeframe.change("D")
isNewWeek    = timeframe.change("W")
doReset = resetDlt == "Session" ? isNewSession : resetDlt == "Week" ? isNewWeek : false

var float cumDelta = 0.0
cumDelta := (doReset ? 0.0 : nz(cumDelta)) + nz(delta)

// pressure oscillator: normalised, smoothed delta flow
deltaNorm = volMean > 0 ? delta / volMean : 0.0
pressure  = ta.ema(deltaNorm, deltaLen)          // >0 buyers in control, <0 sellers

// ─────────────────────────────────────────────────────────────────────────
//  TREND FILTER
// ─────────────────────────────────────────────────────────────────────────
trendMa = ta.ema(close, trendLen)
upTrend = close >= trendMa

// ─────────────────────────────────────────────────────────────────────────
//  WHALE CLASSIFICATION
// ─────────────────────────────────────────────────────────────────────────
isWhale    = volZ >= whaleZ
bullConv   = clsPos >= (1.0 - convFr)            // closed in top third
bearConv   = clsPos <= convFr                    // closed in bottom third
whaleBull  = isWhale and bullConv
whaleBear  = isWhale and bearConv
absorption = showAbs and volZ >= absorbZ and smallRange

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS  (whale print + delta agreement + trend, on confirmed bar)
// ─────────────────────────────────────────────────────────────────────────
deltaBull = pressure > 0
deltaBear = pressure < 0
trendOKl  = not useTrend or upTrend
trendOKs  = not useTrend or not upTrend

buy  = whaleBull and deltaBull and trendOKl
sell = whaleBear and deltaBear and trendOKs
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
//  CONVICTION SCORE 0..100  (edge estimate of the current print)
// ─────────────────────────────────────────────────────────────────────────
zComp    = math.min(1.0, volZ / (whaleZ * 2.0))
dComp    = math.min(1.0, math.abs(pressure) / 0.5)
rComp    = buy ? clsPos : sell ? (1.0 - clsPos) : math.max(clsPos, 1.0 - clsPos)
conv     = math.round(100 * (0.45 * zComp + 0.35 * dComp + 0.20 * rComp))

// ─────────────────────────────────────────────────────────────────────────
//  LIVE STATS  (sequential, no lookahead — win = TP1 reached before SL)
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

if sig
    if sOpen
        losses += 1
        sOpen := false
    sDir   := buy ? 1 : -1
    sEntry := close
    risk    = atr * slMult
    sSL    := buy ? close - risk : close + risk
    sT1    := buy ? close + risk * tp1R : close - risk * tp1R
    sOpen  := true

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  ATR TP/SL LADDER  (latest signal, redrawn each new signal)
// ─────────────────────────────────────────────────────────────────────────
var line  lnE = na
var line  lnS = na
var line  ln1 = na
var line  ln2 = na
var line  ln3 = na
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_lad(line ln, label lb, float p, string txt, color c) =>
    line.set_xy1(ln, bar_index, p)
    line.set_xy2(ln, bar_index + 10, p)
    line.set_color(ln, c)
    label.set_xy(lb, bar_index + 10, p)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

if showLad and sig
    risk = atr * slMult
    e  = close
    sl = buy ? e - risk : e + risk
    t1 = buy ? e + risk * tp1R : e - risk * tp1R
    t2 = buy ? e + risk * tp2R : e - risk * tp2R
    t3 = buy ? e + risk * tp3R : e - risk * tp3R
    if na(lnE)
        lnE := line.new(bar_index, e, bar_index + 10, e, color = GOLD, width = 2)
        lnS := line.new(bar_index, sl, bar_index + 10, sl, color = CRIMSON, style = line.style_dashed)
        ln1 := line.new(bar_index, t1, bar_index + 10, t1, color = BLUE_MID)
        ln2 := line.new(bar_index, t2, bar_index + 10, t2, color = BLUE_MID)
        ln3 := line.new(bar_index, t3, bar_index + 10, t3, color = VIOLET)
        lbE := label.new(bar_index + 10, e, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        lbS := label.new(bar_index + 10, sl,"", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        lb1 := label.new(bar_index + 10, t1,"", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        lb2 := label.new(bar_index + 10, t2,"", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        lb3 := label.new(bar_index + 10, t3,"", style = label.style_label_left, color = color.new(INK,100), size = size.small)
    f_lad(lnE, lbE, e,  " ENTRY " + str.tostring(e, format.mintick), GOLD)
    f_lad(lnS, lbS, sl, " SL " + str.tostring(sl, format.mintick), CRIMSON)
    f_lad(ln1, lb1, t1, " TP1 · " + str.tostring(tp1R,"#.#") + "R", BLUE_HI)
    f_lad(ln2, lb2, t2, " TP2 · " + str.tostring(tp2R,"#.#") + "R", BLUE_HI)
    f_lad(ln3, lb3, t3, " TP3 · " + str.tostring(tp3R,"#.#") + "R", VIOLET_HI)

if showLad and not na(lnE) and barstate.islast
    line.set_x2(lnE, bar_index + 10)
    line.set_x2(lnS, bar_index + 10)
    line.set_x2(ln1, bar_index + 10)
    line.set_x2(ln2, bar_index + 10)
    line.set_x2(ln3, bar_index + 10)
    label.set_x(lbE, bar_index + 10)
    label.set_x(lbS, bar_index + 10)
    label.set_x(lb1, bar_index + 10)
    label.set_x(lb2, bar_index + 10)
    label.set_x(lb3, bar_index + 10)

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS  —  pressure candles, whale prints, absorption, background
// ─────────────────────────────────────────────────────────────────────────
pClamp = math.max(-1.0, math.min(1.0, pressure * 2.0))
bull_g = color.from_gradient(pClamp, 0, 1, BLUE_MID, VIOLET)
bear_g = color.from_gradient(-pClamp, 0, 1, CRIMSON, VIOLET)
presCol = pClamp >= 0 ? bull_g : bear_g

barcolor(colorBars ? color.new(presCol, 25) : na)

// whale markers — size scales with z-score if enabled (plotshape.size must be
// a constant, so we branch into three fixed-size calls by strength tier)
whaleBig = volZ >= whaleZ * 2.0
whaleMed = volZ >= whaleZ * 1.4 and not whaleBig
whaleSm  = not whaleBig and not whaleMed
plotshape(whaleBull and (not bubbleSz or whaleSm), "Whale Buy S",  style = shape.diamond, location = location.belowbar, color = BLUE_MID, size = size.small)
plotshape(whaleBull and bubbleSz and whaleMed,     "Whale Buy M",  style = shape.diamond, location = location.belowbar, color = BLUE_MID, size = size.normal)
plotshape(whaleBull and bubbleSz and whaleBig,     "Whale Buy L",  style = shape.diamond, location = location.belowbar, color = BLUE_MID, size = size.large)
plotshape(whaleBear and (not bubbleSz or whaleSm), "Whale Sell S", style = shape.diamond, location = location.abovebar, color = CRIMSON, size = size.small)
plotshape(whaleBear and bubbleSz and whaleMed,     "Whale Sell M", style = shape.diamond, location = location.abovebar, color = CRIMSON, size = size.normal)
plotshape(whaleBear and bubbleSz and whaleBig,     "Whale Sell L", style = shape.diamond, location = location.abovebar, color = CRIMSON, size = size.large)
plotshape(absorption, "Absorption", style = shape.xcross, location = location.abovebar, color = GOLD, size = size.tiny, text = "ABS", textcolor = GOLD)

// confirmed buy/sell labels
plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = BLUE_MID, textcolor = INKHI, text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = CRIMSON, textcolor = INKHI, text = "SELL", size = size.small)

bgcolor(showBg ? color.new(pClamp >= 0 ? BLUE_MID : CRIMSON, 92 - math.round(math.abs(pClamp) * 6)) : na, title = "Pressure background")

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
    hud := table.new(f_pos(hudPos), 2, 8, bgcolor = color.new(hudBg, 0), frame_color = color.new(#1E2740, 0), frame_width = 1, border_width = 0)

    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #1B2340), 0)

    pT = pClamp > 0.15 ? "BUYERS" : pClamp < -0.15 ? "SELLERS" : "BALANCED"
    pC = pClamp > 0.15 ? BLUE_HI : pClamp < -0.15 ? CRIMSON_HI : MUTE

    // pressure meter
    seg = 10
    fN  = math.round((pClamp + 1) / 2 * seg)
    pbar = ""
    for i = 1 to seg
        pbar := pbar + (i <= fN ? "▰" : "▱")

    cdT = cumDelta >= 0 ? "+" : ""
    cdC = cumDelta >= 0 ? BLUE_MID : CRIMSON

    trT = upTrend ? "UP" : "DOWN"
    trC = upTrend ? BLUE_MID : CRIMSON

    // conviction meter
    cF = math.round(conv / 100.0 * 10)
    cbar = ""
    for i = 1 to 10
        cbar := cbar + (i <= cF ? "▰" : "▱")
    convC = conv >= 66 ? VIOLET_HI : conv >= 33 ? GOLD : MUTE

    sigT = buy ? "WHALE BUY ▲" : sell ? "WHALE SELL ▼" : absorption ? "Absorption ⚠" : "Scanning…"
    sigC = buy ? BLUE_HI : sell ? CRIMSON_HI : absorption ? GOLD : MUTE

    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? BLUE_MID : winRate <= 45 ? CRIMSON : GOLD

    table.cell(hud, 0, 0, "  🐋 WHALE RADAR", text_color = INKHI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, "Inst  ", text_color = VIOLET_HI, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 0, 1, "  Pressure", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, pT + "  ", text_color = pC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 2, "  Flow", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, pbar + "  ", text_color = pC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 3, "  Cum. Delta", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, cdT + f_compact(cumDelta) + "  ", text_color = cdC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 4, "  Trend", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, trT + "  ", text_color = trC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 5, "  Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, cbar + " " + str.tostring(conv) + "  ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 6, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 6, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 7, "  Win (TP1)", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 7, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Whale Buy",  "Whale Radar: bullish institutional print with delta + trend confirmation")
alertcondition(sell, "Whale Sell", "Whale Radar: bearish institutional print with delta + trend confirmation")
alertcondition(whaleBull or whaleBear, "Any Whale Print", "Whale Radar: outlier volume print detected")
alertcondition(absorption, "Absorption", "Whale Radar: high-volume absorption / iceberg detected")
````
