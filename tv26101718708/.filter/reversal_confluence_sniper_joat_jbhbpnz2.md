# Reversal Confluence Sniper [JOAT]

- url: https://www.tradingview.com/script/jbHBPnz2-Reversal-Confluence-Sniper-JOAT/
- type: indicator
- pine_id: PUB;076f541999c047259970d4079be3a5ac
- version: 1.0

## Description

[b]Reversal Confluence Sniper [JOAT][/b]
[i]Hunts exhaustion reversals by requiring several independent exhaustion signals to appear together, so it fades stretched moves with confirmation rather than hope.[/i]

[b]What it is[/b]
Fading a trend is dangerous when done on a single cue. This indicator only flags a potential reversal when multiple, independent signs of exhaustion coincide at the same moment — turning a risky counter-trend guess into a confluence-gated setup. It is an original reversal engine, not a lone oscillator flip.

[image]https://www.tradingview.com/x/jJBsBP1W/[/image]

[b]How it works[/b]
The engine looks for several exhaustion conditions and requires enough of them to align:

• [b]Momentum extreme[/b] — an oscillator reaching and rolling over from an overextended level, showing the push is losing force.

• [b]Volatility stretch[/b] — price extended a statistically large distance from a mean or band, marking an unsustainable move.

• [b]Rejection candle[/b] — a wick or close that rejects the extreme, showing the aggressive side failed to hold new ground.

• [b]Participation[/b] — a volume or effort read that flags climax or fade behaviour rather than steady continuation.

A Buy (bullish reversal) prints when enough downside-exhaustion factors align; a Sell when enough upside-exhaustion factors align. A minimum-gap control prevents repeated prints while a market chops around an extreme.

[b]Trade levels[/b]
Each signal draws a red risk box to a stop placed beyond the exhaustion extreme and a green reward box to the third target, with inner dividers and right-edge labels for entry, stop and each take-profit at your R multiples. Placing the stop beyond the extreme respects the idea that if price makes a new extreme, the reversal thesis is wrong.

[b]The dashboard[/b]
An adjustable sniper-scope panel shows which exhaustion factors are currently active, a combined conviction reading, the active signal, and a live first-target-before-stop tally from closed bars only, so you can see how much confluence backs each setup.

[b]How to use it[/b]
• Works on any asset and timeframe.
• Most effective for timing entries at the end of a stretched move, ideally into a higher-timeframe level or zone.
• Because it fades momentum, pair it with structure or a level tool and keep stops disciplined — reversals that do not confirm should be cut quickly.

[b]Settings[/b]
The exhaustion factor lengths and thresholds, the number of factors required to trigger, risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
The contribution is the confluence gate itself: several independent exhaustion measures that must agree before a counter-trend signal is allowed, with a transparent readout of which factors fired and integrated, non-repainting trade framing. It is designed to make fading safer by demanding evidence, not to promise reversals.

[b]Notes and limitations[/b]
• Counter-trend trading is inherently higher risk; strong trends can stay stretched far longer than expected and overrun any reversal signal.
• Requiring more factors reduces false signals but also reduces frequency — this trade-off is yours to set.
• The tally reflects only past bars on the current chart and is not a forecast.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Reversal Confluence Sniper [JOAT]", "Reversal Sniper [JOAT]", overlay = true, max_labels_count = 300, max_lines_count = 100, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (CYBERPUNK — neon on near-black)
// ─────────────────────────────────────────────────────────────────────────
CYAN    = #00E5FF
CYAN_HI = #7BF3FF
MAG     = #FF2E9A
MAG_HI  = #FF7AC2
PURPLE  = #A64BFF
PURP_HI = #C99BFF
LIME    = #7CFF5A
AMBER   = #FFC24B
INK     = #05070E
INKHI   = #EAF2FF
MUTE    = #5A6B8C

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gE      = "Exhaustion Core"
meanLen = input.int(20,  "Mean / z-score length", minval = 5, group = gE, tooltip = "Lookback for the EMA mean anchor and the standard-deviation used in the z-score distance gauge.")
runN    = input.int(5,   "Climax run bars (N)", minval = 2, maxval = 15, group = gE, tooltip = "A run of N consecutive same-direction closes counts as a full exhaustion on the run gauge.")
zThr    = input.float(2.0,"Z-score stretch threshold", minval = 0.5, step = 0.1, group = gE, tooltip = "Distance from the mean (in std-devs) that counts as a full stretch on the z gauge.")
rsiLen  = input.int(14,  "RSI length", minval = 2, group = gE)
obLevel = input.float(70,"RSI overbought", minval = 50, maxval = 95, step = 1, group = gE)
osLevel = input.float(30,"RSI oversold",   minval = 5,  maxval = 50, step = 1, group = gE)
spikeMul= input.float(1.8,"Volatility spike (range ≥ ATR ×)", minval = 1.0, step = 0.1, group = gE, tooltip = "A bar whose true range is this multiple of ATR is a climactic blow-off bar.")

gB      = "Bands"
bbLen   = input.int(20,  "BB / KC length", minval = 5, group = gB)
bbMult  = input.float(2.0,"BB multiplier", minval = 0.5, step = 0.1, group = gB)
kcMult  = input.float(1.5,"Keltner multiplier", minval = 0.5, step = 0.1, group = gB, tooltip = "Keltner extreme used as the second band-tag reference.")

gR      = "Reversal & Confluence"
wickFrac= input.float(0.5,"Pin wick fraction of range", minval = 0.2, maxval = 0.9, step = 0.05, group = gR, tooltip = "Rejection wick must be at least this fraction of the bar's range to qualify as a pin.")
volLen  = input.int(20,  "Volume climax window", minval = 2, group = gR)
volThr  = input.float(1.6,"Volume climax (rel-vol ≥)", minval = 1.0, step = 0.1, group = gR)
minConf = input.int(3,   "Min confluences (of 5)", minval = 1, maxval = 5, group = gR, tooltip = "How many of the five confluence checks must be met to fire a sniper shot.")
minExh  = input.int(55,  "Min exhaustion score", minval = 0, maxval = 100, step = 5, group = gR, tooltip = "Exhaustion meter must be at least this high for a signal to arm.")
cooldown= input.int(8,   "Cooldown bars", minval = 0, maxval = 100, group = gR, tooltip = "Minimum bars between shots so the desk does not spam re-entries.")

gT      = "Trade Levels"
showBox = input.bool(true, "TP/SL boxes", group = gT)
atrLenT = input.int(14, "ATR length", minval = 1, group = gT)
slPad   = input.float(0.5,"SL pad beyond wick (ATR ×)", minval = 0.0, step = 0.1, group = gT, tooltip = "Extra cushion placed beyond the reversal wick for the stop.")
tp1R    = input.float(1.0,"TP1 (R)", step = 0.5, group = gT)
tp2R    = input.float(2.0,"TP2 (R)", step = 0.5, group = gT)
tp3R    = input.float(3.0,"TP3 (R)", step = 0.5, group = gT)
boxLen  = input.int(24, "Box width (bars)", minval = 5, group = gT)

gV      = "Visuals"
showBands=input.bool(true, "Band plots + fill", group = gV)
showMk  = input.bool(true, "Glow reversal markers", group = gV)
colorBars=input.bool(true, "Exhaustion-tinted candles", group = gV)
showBg  = input.bool(true, "Exhaustion background flash", group = gV)

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
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

f_meter(float pct01) =>
    fill = math.round(math.max(0.0, math.min(1.0, pct01)) * 10)
    out = ""
    for i = 1 to 10
        out := out + (i <= fill ? "▰" : "▱")
    out

// sniper-scope block gauge  █▓▒░  (10 cells, shaded transition)
f_block(float pct01) =>
    v      = math.max(0.0, math.min(1.0, pct01))
    filled = math.floor(v * 10)
    frac   = v * 10 - filled
    out = ""
    for i = 0 to 9
        out := out + (i < filled ? "█" : i == filled ? (frac >= 0.66 ? "▓" : frac >= 0.33 ? "▒" : "░") : "░")
    out

// confluence dot pips  ●○
f_pips(int n, int total) =>
    out = ""
    for i = 1 to total
        out := out + (i <= n ? "●" : "○")
    out

// ─────────────────────────────────────────────────────────────────────────
//  MEAN ANCHOR, BANDS & CORE SERIES
// ─────────────────────────────────────────────────────────────────────────
mean   = ta.ema(close, meanLen)
sd     = ta.stdev(close, meanLen)
zRaw   = sd > 0 ? (close - mean) / sd : 0.0

atr    = ta.atr(atrLenT)
rng    = high - low

basis  = ta.sma(close, bbLen)
dev    = bbMult * ta.stdev(close, bbLen)
bbU    = basis + dev
bbL    = basis - dev
rngMa  = ta.sma(ta.tr(true), bbLen)
kcU    = basis + kcMult * rngMa
kcL    = basis - kcMult * rngMa

rsi    = ta.rsi(close, rsiLen)

// ─────────────────────────────────────────────────────────────────────────
//  CONSECUTIVE-CLOSE RUN  (guarded accumulators)
// ─────────────────────────────────────────────────────────────────────────
var int upRun = 0
var int dnRun = 0
upRun := close > close[1] ? nz(upRun) + 1 : 0
dnRun := close < close[1] ? nz(dnRun) + 1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  EXHAUSTION CORE  (four gauges → directional 0..100 scores)
// ─────────────────────────────────────────────────────────────────────────
volSpike = atr > 0 ? rng / atr : 0.0
spikeComp= math.min(1.0, volSpike / spikeMul)

// UP exhaustion (stretched high → prime for a SELL / bearish reversal)
runUpC   = math.min(1.0, upRun / runN)
zUpC     = math.min(1.0, math.max(0.0, zRaw) / zThr)
rsiUpC   = math.min(1.0, math.max(0.0, rsi - obLevel) / math.max(1.0, 100 - obLevel))
exhaustUp= math.round(100 * (0.30 * runUpC + 0.30 * zUpC + 0.25 * rsiUpC + 0.15 * spikeComp))

// DOWN exhaustion (stretched low → prime for a BUY / bullish reversal)
runDnC   = math.min(1.0, dnRun / runN)
zDnC     = math.min(1.0, math.max(0.0, -zRaw) / zThr)
rsiDnC   = math.min(1.0, math.max(0.0, osLevel - rsi) / math.max(1.0, osLevel))
exhaustDn= math.round(100 * (0.30 * runDnC + 0.30 * zDnC + 0.25 * rsiDnC + 0.15 * spikeComp))

exhaust  = math.max(exhaustUp, exhaustDn)
exhDir   = exhaustUp >= exhaustDn ? 1 : -1     // 1 = stretched up, -1 = stretched down

// ─────────────────────────────────────────────────────────────────────────
//  REVERSAL TRIGGER  (engulfing OR pin/rejection that closes back inside band)
// ─────────────────────────────────────────────────────────────────────────
body      = math.abs(close - open)
upWick    = high - math.max(close, open)
dnWick    = math.min(close, open) - low
safeRng   = rng > 0 ? rng : syminfo.mintick

bullEngulf= close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
bearEngulf= close < open and close[1] > open[1] and close <= open[1] and open >= close[1]

// bullish pin: pokes below a lower band, long lower wick, closes back inside
bullPin   = (low < bbL or low < kcL) and close > bbL and (dnWick / safeRng) >= wickFrac and close > open
bearPin   = (high > bbU or high > kcU) and close < bbU and (upWick / safeRng) >= wickFrac and close < open

bullRev   = bullEngulf or bullPin
bearRev   = bearEngulf or bearPin

// ─────────────────────────────────────────────────────────────────────────
//  CONFLUENCE STACK  (five checks each side)
// ─────────────────────────────────────────────────────────────────────────
// 1) band tag — price probed the relevant extreme this bar
tagLo    = low <= bbL or low <= kcL
tagHi    = high >= bbU or high >= kcU
// 2) RSI regime — oversold / overbought
rsiOS    = rsi <= osLevel
rsiOB    = rsi >= obLevel
// 3) RSI divergence-lite — price makes a lower low but RSI turns up (and mirror)
divBull  = close < close[1] and rsi > rsi[1] and rsi < 50
divBear  = close > close[1] and rsi < rsi[1] and rsi > 50
// 4) volume climax
relVol   = ta.sma(volume, volLen) > 0 ? volume / ta.sma(volume, volLen) : 1.0
volClimax= relVol >= volThr
// 5) mean-reversion distance — z-score beyond threshold
zLo      = zRaw <= -zThr
zHi      = zRaw >=  zThr

confBull = (tagLo ? 1 : 0) + (rsiOS ? 1 : 0) + (divBull ? 1 : 0) + (volClimax ? 1 : 0) + (zLo ? 1 : 0)
confBear = (tagHi ? 1 : 0) + (rsiOB ? 1 : 0) + (divBear ? 1 : 0) + (volClimax ? 1 : 0) + (zHi ? 1 : 0)

// ─────────────────────────────────────────────────────────────────────────
//  SNIPER SIGNALS  (exhaustion + reversal + confluences + cooldown)
// ─────────────────────────────────────────────────────────────────────────
var int lastSigBar = na
canFire  = na(lastSigBar) or (bar_index - lastSigBar) >= cooldown

buyRaw   = bullRev and exhaustDn >= minExh and confBull >= minConf and exhDir == -1
sellRaw  = bearRev and exhaustUp >= minExh and confBear >= minConf and exhDir == 1

buy      = buyRaw  and canFire
sell     = sellRaw and canFire and not buyRaw
sig      = buy or sell
if sig
    lastSigBar := bar_index

confMet  = buy ? confBull : sell ? confBear : math.max(confBull, confBear)

// ─────────────────────────────────────────────────────────────────────────
//  CONVICTION 0..100  (exhaustion depth + confluence density + snap strength)
// ─────────────────────────────────────────────────────────────────────────
exhComp  = (buy ? exhaustDn : sell ? exhaustUp : exhaust) / 100.0
confComp = math.max(confBull, confBear) / 5.0
snapComp = math.min(1.0, body / (atr > 0 ? atr : safeRng))
conv     = math.round(100 * (0.45 * exhComp + 0.35 * confComp + 0.20 * snapComp))

// ─────────────────────────────────────────────────────────────────────────
//  LIVE WIN-RATE  (TP1 before SL — no lookahead)
// ─────────────────────────────────────────────────────────────────────────
var float sEntry = na
var float sSL    = na
var float sT1    = na
var int   sDir   = 0
var bool  sOpen  = false
var int   wins   = 0
var int   losses = 0

if sOpen
    if sDir == 1
        if high >= sT1
            wins   += 1
            sOpen  := false
        else if low <= sSL
            losses += 1
            sOpen  := false
    else
        if low <= sT1
            wins   += 1
            sOpen  := false
        else if high >= sSL
            losses += 1
            sOpen  := false

// ─────────────────────────────────────────────────────────────────────────
//  TP/SL BOXES  (single active pair, redrawn on each signal)
// ─────────────────────────────────────────────────────────────────────────
var box   slBox = na
var box   tpBox = na
var line  lnE = na
var line  lnS = na
var line  lnT1 = na
var line  lnT2 = na
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_lbl(label lb, float p, string txt, color c) =>
    label.set_xy(lb, bar_index + boxLen, p)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

if sig
    if sOpen
        losses := losses + 1
        sOpen  := false
    sDir   := buy ? 1 : -1
    sEntry := close
    // stop sits beyond the reversal wick with an ATR pad
    wickSL  = buy ? math.min(low, low[1]) - atr * slPad : math.max(high, high[1]) + atr * slPad
    sSL    := wickSL
    risk    = math.abs(sEntry - sSL)
    risk    := risk > 0 ? risk : atr
    sT1    := buy ? sEntry + risk * tp1R : sEntry - risk * tp1R
    t2      = buy ? sEntry + risk * tp2R : sEntry - risk * tp2R
    t3      = buy ? sEntry + risk * tp3R : sEntry - risk * tp3R
    sOpen  := true

    if showBox
        box.delete(slBox)
        box.delete(tpBox)
        rCol = buy ? MAG : CYAN
        gCol = buy ? CYAN : MAG
        // red risk box: entry → SL
        slBox := box.new(bar_index, sEntry, bar_index + boxLen, sSL, bgcolor = color.new(MAG, 82), border_color = color.new(MAG, 30), border_width = 1)
        // reward box: entry → TP3
        tpBox := box.new(bar_index, sEntry, bar_index + boxLen, t3, bgcolor = color.new(LIME, 84), border_color = color.new(LIME, 30), border_width = 1)
        if na(lbE)
            lbE := label.new(bar_index + boxLen, sEntry, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lbS := label.new(bar_index + boxLen, sSL,   "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb1 := label.new(bar_index + boxLen, sT1,   "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb2 := label.new(bar_index + boxLen, t2,    "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb3 := label.new(bar_index + boxLen, t3,    "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            // solid ENTRY, dashed SL, dotted TP1/TP2 divider lines across the boxes
            lnE  := line.new(bar_index, sEntry, bar_index + boxLen, sEntry, color = AMBER,                 width = 2, style = line.style_solid)
            lnS  := line.new(bar_index, sSL,    bar_index + boxLen, sSL,    color = MAG_HI,                width = 1, style = line.style_dashed)
            lnT1 := line.new(bar_index, sT1,    bar_index + boxLen, sT1,    color = color.new(CYAN_HI, 20), width = 1, style = line.style_dotted)
            lnT2 := line.new(bar_index, t2,     bar_index + boxLen, t2,     color = color.new(LIME, 20),    width = 1, style = line.style_dotted)
        line.set_xy1(lnE, bar_index, sEntry)
        line.set_xy2(lnE, bar_index + boxLen, sEntry)
        line.set_xy1(lnS, bar_index, sSL)
        line.set_xy2(lnS, bar_index + boxLen, sSL)
        line.set_xy1(lnT1, bar_index, sT1)
        line.set_xy2(lnT1, bar_index + boxLen, sT1)
        line.set_xy1(lnT2, bar_index, t2)
        line.set_xy2(lnT2, bar_index + boxLen, t2)
        f_lbl(lbE, sEntry, " ENTRY " + str.tostring(sEntry, format.mintick), AMBER)
        f_lbl(lbS, sSL,    " SL " + str.tostring(sSL, format.mintick), MAG_HI)
        f_lbl(lb1, sT1,    " TP1 · " + str.tostring(tp1R, "#.#") + "R  " + str.tostring(sT1, format.mintick), CYAN_HI)
        f_lbl(lb2, t2,     " TP2 · " + str.tostring(tp2R, "#.#") + "R  " + str.tostring(t2, format.mintick), CYAN_HI)
        f_lbl(lb3, t3,     " TP3 · " + str.tostring(tp3R, "#.#") + "R  " + str.tostring(t3, format.mintick), LIME)

// keep the active trade drawing extended while it lives
if showBox and not na(slBox) and barstate.islast
    box.set_right(slBox, bar_index + boxLen)
    box.set_right(tpBox, bar_index + boxLen)
    line.set_x2(lnE,  bar_index + boxLen)
    line.set_x2(lnS,  bar_index + boxLen)
    line.set_x2(lnT1, bar_index + boxLen)
    line.set_x2(lnT2, bar_index + boxLen)
    label.set_x(lbE, bar_index + boxLen)
    label.set_x(lbS, bar_index + boxLen)
    label.set_x(lb1, bar_index + boxLen)
    label.set_x(lb2, bar_index + boxLen)
    label.set_x(lb3, bar_index + boxLen)

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  BAND PLOTS + FILL
// ─────────────────────────────────────────────────────────────────────────
uB = plot(showBands ? bbU : na, "BB Upper", color = color.new(CYAN, 55))
lB = plot(showBands ? bbL : na, "BB Lower", color = color.new(MAG, 55))
plot(showBands ? basis : na, "Basis", color = color.new(MUTE, 40))
plot(showBands ? kcU : na, "KC Upper", color = color.new(PURPLE, 70), style = plot.style_stepline)
plot(showBands ? kcL : na, "KC Lower", color = color.new(PURPLE, 70), style = plot.style_stepline)
fillCol = exhaust >= minExh ? color.new(exhDir == 1 ? MAG : CYAN, 88) : color.new(PURPLE, 94)
fill(uB, lB, color = fillCol, title = "Band fill")

// ─────────────────────────────────────────────────────────────────────────
//  EXHAUSTION-TINTED CANDLES + BACKGROUND FLASH
// ─────────────────────────────────────────────────────────────────────────
tintCol = exhDir == 1 ? color.from_gradient(exhaustUp, 0, 100, MUTE, MAG_HI) : color.from_gradient(exhaustDn, 0, 100, MUTE, CYAN_HI)
barcolor(colorBars ? color.new(tintCol, 25) : na, title = "Exhaustion tint")

primed  = exhaust >= minExh
bgCol   = primed ? color.new(exhDir == 1 ? MAG : CYAN, 90 - math.round(math.min(1.0, (exhaust - minExh) / 45.0) * 6)) : na
bgcolor(showBg ? bgCol : na, title = "Exhaustion flash")

// ─────────────────────────────────────────────────────────────────────────
//  GLOW REVERSAL MARKERS  (layered constant-size shapes = neon glow)
// ─────────────────────────────────────────────────────────────────────────
plotshape(showMk and buy  ? low  : na, "Buy glow 2",  style = shape.circle, location = location.belowbar, color = color.new(CYAN, 55), size = size.large)
plotshape(showMk and buy  ? low  : na, "Buy glow 1",  style = shape.circle, location = location.belowbar, color = color.new(CYAN, 20), size = size.normal)
plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = CYAN, textcolor = INK,   text = "SNIPE ▲", size = size.small)
plotshape(showMk and sell ? high : na, "Sell glow 2", style = shape.circle, location = location.abovebar, color = color.new(MAG, 55), size = size.large)
plotshape(showMk and sell ? high : na, "Sell glow 1", style = shape.circle, location = location.abovebar, color = color.new(MAG, 20), size = size.normal)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = MAG,  textcolor = INKHI, text = "SNIPE ▼", size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  SNIPER-SCOPE DASHBOARD  (crosshair header ⊕ · block gauge █▓▒░ · dot pips ●○)
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 9, bgcolor = color.new(hudBg, 0), frame_color = color.new(MAG, 45), frame_width = 1, border_color = color.new(#141C33, 40), border_width = 1)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(#1A1140, 0)

    // accent set: magenta (up-stretch / risk) · cyan (dn-stretch / reward) · amber (mid)
    exhAcc = exhDir == 1 ? MAG_HI : CYAN_HI
    exhC  = exhaust >= 66 ? exhAcc : exhaust >= 33 ? AMBER : MUTE
    exhT  = exhDir == 1 ? "▲ up-stretch" : "▼ dn-stretch"

    confShow = math.max(confBull, confBear)
    confC = confShow >= minConf ? CYAN_HI : confShow >= math.max(1, minConf - 1) ? AMBER : MUTE

    rsiC  = rsi >= obLevel ? MAG_HI : rsi <= osLevel ? CYAN_HI : MUTE
    zC    = math.abs(zRaw) >= zThr ? (zRaw > 0 ? MAG_HI : CYAN_HI) : MUTE
    convC = conv >= 66 ? CYAN_HI : conv >= 33 ? AMBER : MUTE

    sigT  = buy ? "LONG SNIPE ▲" : sell ? "SHORT SNIPE ▼" : primed ? (exhDir == 1 ? "⊕ lock top…" : "⊕ lock bottom…") : "· scanning ·"
    sigC  = buy ? CYAN_HI : sell ? MAG_HI : primed ? AMBER : MUTE

    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? CYAN_HI : winRate <= 45 ? MAG_HI : AMBER

    // crosshair title bar
    table.cell(hud, 0, 0, " ⊕ SNIPER SCOPE", text_color = INKHI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, "◎ JOAT ", text_color = MAG_HI, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

    // headline EXHAUSTION 0-100 gauge (big value + block meter)
    table.cell(hud, 0, 1, " EXHAUSTION", text_color = AMBER, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, str.tostring(exhaust) + " ┃" + f_block(exhaust / 100.0) + " ", text_color = exhC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)

    table.cell(hud, 0, 2, " Stretch", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, exhT + " ", text_color = exhC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 3, " Confluence", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, f_pips(confShow, 5) + " " + str.tostring(confShow) + "/5 ", text_color = confC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 4, " RSI", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, str.tostring(math.round(rsi)) + " ", text_color = rsiC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 5, " Dist (z)", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, str.tostring(zRaw, "#.##") + "σ ", text_color = zC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 6, " Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 6, str.tostring(conv) + " ▕" + f_block(conv / 100.0) + " ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 7, " Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 7, sigT + " ", text_color = sigC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 0, 8, " Win rate", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 8, statTxt + " ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy",  "Reversal Sniper: bullish snap-back after down exhaustion with confluence")
alertcondition(sell, "Sell", "Reversal Sniper: bearish snap-back after up exhaustion with confluence")
alertcondition(sig,  "Any signal", "Reversal Sniper: sniper reversal shot fired")
alertcondition(exhaustDn >= minExh and exhaustDn[1] < minExh, "Bottom priming", "Reversal Sniper: down-exhaustion primed — watching for a long snap-back")
alertcondition(exhaustUp >= minExh and exhaustUp[1] < minExh, "Top priming", "Reversal Sniper: up-exhaustion primed — watching for a short snap-back")
````
