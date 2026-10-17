# IShakfa Long-Only Confluence

- url: https://www.tradingview.com/script/Gogucnau-IShakfa-Long-Only-Confluence/
- type: indicator
- pine_id: PUB;dbebf0aff52d42a2b0c023cabee3db76
- version: 1.0

## Description

OVERVIEW
IShakfa Long-Only Confluence is a buy-only signal tool that waits for several
independent technical conditions to align before marking a long entry, and then
attaches a fixed take-profit and stop-loss plan to that entry. It is built around
a single idea: the highest-conviction long entries tend to occur when you buy a
short-term pullback (a dip) inside a market that is already trending up, while
momentum and trend strength are confirming the move. Rather than acting on any one
signal, this indicator only fires when trend, market structure, momentum, and a
dip-reversal trigger agree at the same time.
It is intentionally selective. Long stretches with no signal are normal and expected
— the tool is designed to skip choppy, rangebound, and downtrending conditions
entirely.
WHAT IT DOES

Marks BUY entries only when a stack of confirming conditions is satisfied together.
Draws an Entry line, a Take-Profit line, and a Stop-Loss line for each trade.
Manages one position at a time: after a BUY, no new BUY appears until the open
trade reaches its target or stop.
Prints a "TP" or "SL" marker when a level is touched.
Shows a live status table so you can always see which conditions are met and which
are holding a signal back.
Provides alerts for the entry and for both exits.

HOW A BUY IS GENERATED
A BUY prints only when ALL of the following are true on the same bar:

TREND — Price is above the slow EMA, the fast EMA is above the slow EMA, and the
slow EMA is rising. This confirms an established uptrend rather than a flat market.
MARKET STRUCTURE — The most recent confirmed swing structure break is to the
upside (a bullish Break of Structure / Change of Character). Swing points are
based on confirmed pivots.
MOMENTUM — A Squeeze-Momentum style oscillator (linear regression of price versus
its recent mean) is positive and rising.
DIP REVERSAL (entry timing) — A combined Bollinger %b + RSI + Stochastic
"oversold package" has just turned back up out of its oversold zone within a short
lookback window. This is what times the entry to a pullback rather than chasing.
RSI CONFIRM (optional) — RSI has turned up above a confirmation level, showing the
bounce has follow-through.
TREND STRENGTH (optional) — ADX is above a minimum threshold and +DI is above -DI,
so entries only occur when a real trend is present (filters out chop).
VOLUME (optional) — Volume is above its moving average (off by default; useful for
stocks, less reliable for some ETFs/FX).

The status table converts this into a 0–100% "confidence" reading. A signal prints
only when every enabled condition passes.
TRADE MANAGEMENT (EXITS)
When a BUY fires, the indicator records the entry price and computes:
Take-Profit = entry x (1 + TP%)     default +20%
Stop-Loss   = entry x (1 - SL%)     default -10%
This is a 2:1 reward-to-risk framework by default. Both percentages are editable.

Only one position is tracked at a time. New entries are blocked until the current
one resolves.
On any single bar, the stop is evaluated before the target. If a bar's range spans
both levels, the result is recorded as a stop — the conservative assumption.
The Entry/TP/SL lines are drawn while the trade is open and stop drawing once it
closes.

IMPORTANT — TIMEFRAME NOTE: A +20% / -10% bracket is large for very low timeframes.
On a 15-minute chart each trade effectively becomes a multi-day swing and exits will
be infrequent. If you prefer faster turnover, either reduce the TP/SL percentages or
run the indicator on a higher timeframe (1H/4H/Daily), where a 20%/10% target fits
price movement more naturally. Tune the percentages to the instrument's volatility.
THE INFO TABLE
The table (top-right) lists each of the seven conditions with a check or cross, an
overall confidence percentage, the current position state, and the active TP/SL
levels when in a trade. If no signal is appearing, the table tells you exactly which
condition is the holdout, so the tool is never a black box.
SETTINGS OVERVIEW

General: entry trigger window (how recently the dip-reversal must have occurred).
Exit Strategy: Take-Profit %, Stop-Loss %, and a toggle to draw the level lines.
Trend: fast/slow EMA lengths and the rising-EMA lookback.
Smart Money Concepts: swing pivot length (larger = more significant structure).
Squeeze Momentum: squeeze length and true-range option.
BB %b + RSI + Stoch: lengths, thresholds, and how many of the three sub-conditions
must be oversold to mark a dip (1–3).
RSI Confirm / ADX / Volume: optional confirmation filters with their own thresholds.
Visuals: toggle arrows, EMAs, and the info table.

HOW TO USE

Add the indicator and let the chart load enough history for the EMAs and pivots.
Watch the table. When all enabled conditions line up, a BUY arrow prints and the
Entry/TP/SL lines appear.
Use the drawn levels as your trade plan, or as a starting point you adjust to your
own risk rules.
If signals are too rare, relax the optional filters (ADX/Volume), lower the
oversold sub-conditions needed, or widen the entry window. If they are too frequent,
do the opposite.

ALERTS
Create an alert and choose one of:

"Buy Signal"
"Take Profit Hit"
"Stop Loss Hit"
Set the alert to "Once Per Bar Close." A single "Any alert() function call" alert will
also capture all three events for the chart.

REPAINTING / CALCULATION BEHAVIOR
Historical signals are based on confirmed, closed-bar data and confirmed swing pivots,
and do not repaint. On the live (still-forming) bar, conditions are evaluated on each
tick and only become final when the bar closes — this is standard indicator behavior.
For confirmed signals, rely on bar close and set alerts to "Once Per Bar Close."
ORIGINALITY AND CREDITS
This script is a mashup that combines several well-known technical concepts and adds
an original confluence-gating layer plus an automated take-profit/stop-loss management
engine. The component concepts are credited as follows:

Smart Money Concepts (market-structure breaks / BOS / CHoCH): concept popularized by
LuxAlgo and the broader ICT methodology.
Squeeze Momentum: original concept by LazyBear.
Bollinger Bands: John Bollinger. RSI and ADX/DMI: J. Welles Wilder. Stochastic:
George Lane.

The logic here is an independent re-implementation of these public concepts (not a
copy of any author's source code). The original contribution is the way the components
are combined into a single, gated long-only signal with built-in trade management and
a transparency table.
DISCLAIMER
This indicator is provided for educational and informational purposes only. It is not
financial advice and does not guarantee any outcome. Technical confluence improves the
odds of a setup but never removes risk — losing trades will occur. Always do your own
research and manage risk according to your own plan. Past behavior of any signal does
not predict future results.

## Source Code

````pine
//@version=6
// =============================================================================
//  IShakfa Long-Only Confluence [v3]   (INDICATOR)
// -----------------------------------------------------------------------------
//  PURPOSE
//    Fire a BUY only on high-conviction long setups, then manage the trade with
//    a fixed-percentage take-profit (+20%) and stop-loss (-10%). Only one trade
//    is "open" at a time: after a BUY, no new BUY appears until TP or SL is hit.
//    No short / sell signals.
//
//  HIGH-CONFIDENCE STACK (a BUY requires ALL of these to be true together):
//    1. TREND      : price above the slow EMA, fast EMA above slow EMA, slow EMA rising
//    2. STRUCTURE  : Smart Money Concepts market structure is bullish (last break = up)
//    3. MOMENTUM   : Squeeze Momentum (LazyBear) is positive AND rising
//    4. ENTRY      : BB %b + RSI + Stochastic oversold package just reversed up (dip buy)
//    5. RSI CONFIRM: RSI has turned up above a confirmation level (optional)
//    6. ADX/DMI    : trend strength above threshold and +DI > -DI (optional)
//    7. VOLUME     : volume above its average (optional)
//
//  EXITS (per trade):
//    Take-Profit = entry x (1 + TP%)   default +20%
//    Stop-Loss   = entry x (1 - SL%)   default -10%
//    Levels drawn until touched; SL is checked before TP on the same bar (conservative).
//
//  NON-REPAINTING: closed-bar logic; SMC levels are confirmed pivots; exits use
//  the bar's own high/low against fixed levels. Use "Once Per Bar Close" alerts.
//  This is a clean re-implementation of the concepts, not a copy of any source.
// =============================================================================

indicator("IShakfa Long-Only Confluence", overlay=true, max_labels_count=500)

// =============================================================================
//  SECTION 0 — GENERAL
// =============================================================================
grpG       = "General"
confWin    = input.int(6, "Entry trigger window (bars)", minval=1, maxval=30, group=grpG,
                tooltip="How recently the dip-reversal (module 4) must have happened while trend, structure and momentum confirm. Smaller = stricter timing.")

// Helper: did `cond` fire within the last `w` bars? (never returns na). Defined
// before use because Pine requires top-down function declaration.
f_within(cond, w) =>
    bs = ta.barssince(cond)
    not na(bs) and bs <= w

// =============================================================================
//  SECTION 1 — EXIT STRATEGY (TP / SL as % of entry)
// =============================================================================
grpX       = "Exit Strategy"
tpPct      = input.float(20.0, "Take-Profit %", minval=0.1, step=0.5, group=grpX,
                tooltip="Target = entry price + this %.")
slPct      = input.float(10.0, "Stop-Loss %",   minval=0.1, step=0.5, group=grpX,
                tooltip="Stop = entry price - this %.")
showLevels = input.bool(true, "Draw Entry / TP / SL lines", group=grpX)

// =============================================================================
//  SECTION 2 — FILTER 1: TREND  (mandatory)
// =============================================================================
grpT       = "1) Trend"
emaFastLen = input.int(50,  "Fast EMA", minval=1, group=grpT)
emaSlowLen = input.int(200, "Slow EMA", minval=1, group=grpT)
emaRiseLk  = input.int(10,  "Slow EMA rising lookback", minval=1, group=grpT,
                tooltip="Slow EMA must be higher than it was this many bars ago (confirms an uptrend, not a flat market).")

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
trendUp = close > emaSlow and emaFast > emaSlow and emaSlow > emaSlow[emaRiseLk]

// =============================================================================
//  SECTION 3 — FILTER 2: SMART MONEY CONCEPTS (structure, mandatory)
// =============================================================================
grpS       = "2) Smart Money Concepts"
smcLen     = input.int(10, "Swing pivot length", minval=2, group=grpS,
                tooltip="Bars each side of a swing. Larger = more significant structure (fewer, stronger signals). Pivots confirm this many bars later = non-repainting.")

ph = ta.pivothigh(high, smcLen, smcLen)
pl = ta.pivotlow(low,  smcLen, smcLen)

var float swingH  = na
var float swingL  = na
var bool  hBroken = true
var bool  lBroken = true
var int   smcTrend = 0

if not na(ph)
    swingH  := ph
    hBroken := false
if not na(pl)
    swingL  := pl
    lBroken := false

rawBull = not na(swingH) and not hBroken and ta.crossover(close, swingH)
rawBear = not na(swingL) and not lBroken and ta.crossunder(close, swingL)
if rawBull
    hBroken := true
    smcTrend := 1
if rawBear
    lBroken := true
    smcTrend := -1

bullStruct = smcTrend == 1

// =============================================================================
//  SECTION 4 — FILTER 3: SQUEEZE MOMENTUM (LazyBear, mandatory)
//  Require momentum positive AND rising for conviction.
// =============================================================================
grpM       = "3) Squeeze Momentum"
sqLen      = input.int(20, "Squeeze length", minval=1, group=grpM)
sqUseTR    = input.bool(true, "KC uses True Range", group=grpM)

hh   = ta.highest(high, sqLen)
ll   = ta.lowest(low,  sqLen)
mid1 = (hh + ll) / 2
mid2 = (mid1 + ta.sma(close, sqLen)) / 2
sqMom = ta.linreg(close - mid2, sqLen, 0)
momUp = sqMom > 0 and sqMom > sqMom[1]

// =============================================================================
//  SECTION 5 — FILTER 4: BB %b + RSI + STOCH  (dip-reversal entry trigger, mandatory)
// =============================================================================
grpA       = "4) BB %b + RSI + Stoch"
bbLen      = input.int(20, "BB length", minval=1, group=grpA)
bbMult     = input.float(2.0, "BB std-dev mult", minval=0.1, step=0.1, group=grpA)
bbLowerB   = input.float(0.20, "%b oversold (<=)", step=0.05, group=grpA)
b_rsiLen   = input.int(14, "RSI length", minval=1, group=grpA)
b_os       = input.int(35, "RSI oversold", minval=1, maxval=99, group=grpA)
stLen      = input.int(14, "Stochastic length", minval=1, group=grpA)
stK        = input.int(3,  "Stoch smooth K",    minval=1, group=grpA)
stOS       = input.int(20, "Stoch oversold",    minval=1, maxval=99, group=grpA)
aNeed      = input.int(2,  "Oversold sub-conditions needed (of 3)", minval=1, maxval=3, group=grpA,
                tooltip="How many of {BB%b, RSI, Stoch} must be oversold to mark a dip. 2 = robust, 3 = strictest.")

bbBasis  = ta.sma(close, bbLen)
bbDev    = bbMult * ta.stdev(close, bbLen)
bbUpper  = bbBasis + bbDev
bbLower  = bbBasis - bbDev
bbRange  = bbUpper - bbLower
percentB = bbRange == 0 ? 0.5 : (close - bbLower) / bbRange
rsiA     = ta.rsi(close, b_rsiLen)
stochK   = ta.sma(ta.stoch(close, high, low, stLen), stK)

osScore = (percentB <= bbLowerB ? 1 : 0) + (rsiA <= b_os ? 1 : 0) + (stochK <= stOS ? 1 : 0)
osZone  = osScore >= aNeed
dipReversal = osZone[1] and not osZone          // package recovering out of oversold
recentDip   = f_within(dipReversal, confWin)

// =============================================================================
//  SECTION 6 — FILTER 5: RSI CONFIRM  (optional)
// =============================================================================
grpR       = "5) RSI Confirm"
useRsiConf = input.bool(true, "Require RSI turning up", group=grpR)
rsiConfLvl = input.int(45, "RSI confirm level (>)", minval=1, maxval=99, group=grpR,
                tooltip="RSI must be above this AND rising, confirming the bounce has momentum.")
rsiConfOk  = not useRsiConf or (rsiA > rsiConfLvl and rsiA > rsiA[1])

// =============================================================================
//  SECTION 7 — FILTER 6: ADX / DMI  (optional)
// =============================================================================
grpD       = "6) ADX / DMI"
useAdx     = input.bool(true, "Require trend strength (ADX)", group=grpD)
diLen      = input.int(14, "DI length", minval=1, group=grpD)
adxSmooth  = input.int(14, "ADX smoothing", minval=1, group=grpD)
adxMin     = input.float(20.0, "ADX minimum", minval=0, step=1, group=grpD,
                tooltip="Only trade when ADX exceeds this (a trending, not choppy, market).")
[diPlus, diMinus, adxVal] = ta.dmi(diLen, adxSmooth)
adxOk      = not useAdx or (adxVal > adxMin and diPlus > diMinus)

// =============================================================================
//  SECTION 8 — FILTER 7: VOLUME  (optional)
// =============================================================================
grpVol     = "7) Volume"
useVol     = input.bool(false, "Require above-average volume", group=grpVol,
                tooltip="Off by default — many ETFs/FX have unreliable volume. Turn on for stocks.")
volLen     = input.int(20, "Volume avg length", minval=1, group=grpVol)
volMult    = input.float(1.0, "Volume x average (>)", minval=0.1, step=0.1, group=grpVol)
volOk      = not useVol or na(volume) or volume > ta.sma(volume, volLen) * volMult

// =============================================================================
//  SECTION 9 — CONFIDENCE SCORE + BUY CONDITION
// =============================================================================
// Count how many checks pass (disabled optional filters count as passed).
c1 = trendUp
c2 = bullStruct
c3 = momUp
c4 = recentDip
c5 = rsiConfOk
c6 = adxOk
c7 = volOk
passCount  = (c1?1:0)+(c2?1:0)+(c3?1:0)+(c4?1:0)+(c5?1:0)+(c6?1:0)+(c7?1:0)
confidence = int(math.round(passCount / 7.0 * 100))

buyCond = c1 and c2 and c3 and c4 and c5 and c6 and c7

// =============================================================================
//  SECTION 10 — TRADE MANAGEMENT (one position; TP/SL exits)
//  Exits are processed BEFORE new entries so a trade can't enter & exit same bar.
// =============================================================================
var bool  inTrade    = false
var float entryPrice = na
var float tpPrice    = na
var float slPrice    = na
var int   entryBar   = na

// ---- 10a. Manage an open trade ----
exitTP = false
exitSL = false
if inTrade
    if low <= slPrice              // stop checked first (conservative)
        exitSL  := true
        inTrade := false
    else if high >= tpPrice
        exitTP  := true
        inTrade := false

// ---- 10b. New entry only when flat ----
buySignal = buyCond and not inTrade
if buySignal
    inTrade    := true
    entryPrice := close
    tpPrice    := close * (1 + tpPct / 100.0)
    slPrice    := close * (1 - slPct / 100.0)
    entryBar   := bar_index

// =============================================================================
//  SECTION 11 — VISUALS
// =============================================================================
grpV       = "Visuals"
showShapes = input.bool(true, "Show Buy / TP / SL markers", group=grpV)
showEMA    = input.bool(true, "Show EMAs", group=grpV)
showTable  = input.bool(true, "Show info table", group=grpV)

plot(showEMA ? emaSlow : na, "Slow EMA", color=color.new(color.orange, 30), linewidth=1)
plot(showEMA ? emaFast : na, "Fast EMA", color=color.new(color.blue,   40), linewidth=1)

// TP/SL/Entry lines only while a trade is open (style_linebr breaks across gaps)
plot(showLevels and inTrade ? entryPrice : na, "Entry", color=color.new(color.gray,  0), style=plot.style_linebr, linewidth=1)
plot(showLevels and inTrade ? tpPrice    : na, "TP",    color=color.new(color.green, 0), style=plot.style_linebr, linewidth=1)
plot(showLevels and inTrade ? slPrice    : na, "SL",    color=color.new(color.red,   0), style=plot.style_linebr, linewidth=1)

plotshape(showShapes and buySignal, title="Buy", style=shape.triangleup,
     location=location.belowbar, color=color.new(#26a69a, 0), size=size.small, text="BUY")
plotshape(showShapes and exitTP, title="TP hit", style=shape.labeldown,
     location=location.abovebar, color=color.new(color.green, 0), textcolor=color.white, size=size.small, text="TP")
plotshape(showShapes and exitSL, title="SL hit", style=shape.labelup,
     location=location.belowbar, color=color.new(color.red, 0), textcolor=color.white, size=size.small, text="SL")

// Entry label with the full plan
if showLevels and buySignal
    label.new(bar_index, low,
         "BUY " + str.tostring(close, format.mintick) +
         "\nTP " + str.tostring(tpPrice, format.mintick) + "  (+" + str.tostring(tpPct, "#.#") + "%)" +
         "\nSL " + str.tostring(slPrice, format.mintick) + "  (-" + str.tostring(slPct, "#.#") + "%)",
         yloc=yloc.belowbar, style=label.style_label_up,
         color=color.new(#26a69a, 15), textcolor=color.white, size=size.small)

// =============================================================================
//  SECTION 12 — INFO TABLE
// =============================================================================
f_yn(b) => b ? "✓" : "✗"
f_c(b)  => b ? color.new(color.green, 0) : color.new(color.red, 0)

var table tb = table.new(position.top_right, 2, 11, frame_color=color.new(color.gray, 50),
     frame_width=1, border_color=color.new(color.gray, 70), border_width=1)

if showTable and barstate.islast
    table.cell(tb, 0, 0, "Long-Only Confluence", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(tb, 1, 0, "v3",                   text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)

    table.cell(tb, 0, 1, "1 Trend up",    text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 1, f_yn(c1), text_color=f_c(c1), text_size=size.small)
    table.cell(tb, 0, 2, "2 Structure",   text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 2, f_yn(c2), text_color=f_c(c2), text_size=size.small)
    table.cell(tb, 0, 3, "3 Momentum",    text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 3, f_yn(c3), text_color=f_c(c3), text_size=size.small)
    table.cell(tb, 0, 4, "4 Dip reversal",text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 4, f_yn(c4), text_color=f_c(c4), text_size=size.small)
    table.cell(tb, 0, 5, "5 RSI confirm", text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 5, f_yn(c5), text_color=f_c(c5), text_size=size.small)
    table.cell(tb, 0, 6, "6 ADX strength",text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 6, f_yn(c6), text_color=f_c(c6), text_size=size.small)
    table.cell(tb, 0, 7, "7 Volume",      text_color=color.silver, text_size=size.small)
    table.cell(tb, 1, 7, f_yn(c7), text_color=f_c(c7), text_size=size.small)

    table.cell(tb, 0, 8, "Confidence", text_color=color.white, text_size=size.small)
    table.cell(tb, 1, 8, str.tostring(confidence) + "%",
         text_color=confidence >= 100 ? color.new(color.green,0) : color.new(color.silver,0), text_size=size.small)

    posTxt = inTrade ? "IN TRADE @ " + str.tostring(entryPrice, format.mintick) : "FLAT"
    table.cell(tb, 0, 9, "Position", text_color=color.white, text_size=size.small)
    table.cell(tb, 1, 9, posTxt, text_color=inTrade ? color.green : color.gray, text_size=size.small)

    lvlTxt = inTrade ? ("TP " + str.tostring(tpPrice, format.mintick) + " / SL " + str.tostring(slPrice, format.mintick)) : "—"
    table.cell(tb, 0, 10, "Targets", text_color=color.white, text_size=size.small)
    table.cell(tb, 1, 10, lvlTxt, text_color=color.silver, text_size=size.small)

// =============================================================================
//  SECTION 13 — ALERTS
// =============================================================================
alertcondition(buySignal, title="Buy Signal",
     message="IShakfa Long-Only: BUY {{ticker}} {{interval}} @ {{close}} | TP +20% / SL -10%")
alertcondition(exitTP, title="Take Profit Hit",
     message="IShakfa Long-Only: TAKE PROFIT hit on {{ticker}} {{interval}}")
alertcondition(exitSL, title="Stop Loss Hit",
     message="IShakfa Long-Only: STOP LOSS hit on {{ticker}} {{interval}}")

if buySignal
    alert("IShakfa Long-Only: BUY " + syminfo.ticker + " | TP +" + str.tostring(tpPct, "#.#") + "% / SL -" + str.tostring(slPct, "#.#") + "%", alert.freq_once_per_bar_close)
if exitTP
    alert("IShakfa Long-Only: TAKE PROFIT hit on " + syminfo.ticker, alert.freq_once_per_bar_close)
if exitSL
    alert("IShakfa Long-Only: STOP LOSS hit on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
