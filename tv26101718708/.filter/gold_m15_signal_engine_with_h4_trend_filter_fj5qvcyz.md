# Gold M15 Signal Engine with H4 Trend Filter

- url: https://www.tradingview.com/script/Fj5qVcYZ-Gold-M15-Signal-Engine-with-H4-Trend-Filter/
- type: indicator
- pine_id: PUB;2acf97c9402e4fb8a0d475319118d497
- version: 2.0

## Description

WHAT THIS SCRIPT DOES

This indicator detects intraday entry setups on the 15-minute chart and attaches a complete, pre-calculated trade frame to each one: an entry, a stop-loss, and three targets. It then tracks that setup bar by bar and reports what actually happened to it — which target was reached, whether the stop was hit, and when the setup has gone stale.

It was built and tuned for gold (XAU/USD) on the 15-minute timeframe. The script deliberately refuses to run on any other timeframe.


WHY IT IS DIFFERENT FROM A STANDARD SIGNAL SCRIPT

Most published signal scripts stop at the arrow. They mark an entry and leave the trader to guess the rest. Three design choices separate this one:

1. Every signal ships with its own risk frame.
The stop-loss is derived from the structural level that produced the signal, not from a fixed pip distance, and it is then capped by a percentage-of-price ceiling so a single wide candle cannot create an unreasonable stop. The first target is ATR-based. The second target prefers a real support or resistance level detected on the chart, and only falls back to an ATR multiple when no suitable level exists. This means targets sit where price is actually likely to react, not at arbitrary distances.

2. The higher timeframe has a veto.
A 4-hour EMA200 trend filter gates every signal. A long is only permitted when the 4-hour close is above its own EMA200, and a short only when it is below. This removes the most common failure mode of intraday signal scripts — firing counter-trend entries during a strong higher-timeframe move. The filter can be switched off in the settings.

3. Signals report their own outcome.
Once a signal is active the script follows it: it marks the bar where each target was reached, automatically moves the displayed stop to breakeven after the first target and to the first target after the second, and hides the setup once the stop is hit. Setups that neither complete nor fail within a configurable number of bars are marked as expired rather than being left on the chart indefinitely.


HOW THE SIGNAL ENGINE WORKS

Three independent detection paths can produce a signal. All of them must additionally pass the RSI gate, the higher-timeframe filter, and a cooldown period.

EMA pullback. In an aligned trend (EMA20 above EMA50 and price above EMA200 for longs, inverted for shorts), price wicks into the EMA20 and closes back on the trend side of it. The candle must close in the outer 55% of its own range, which filters out indecisive bars.

Support and resistance reaction. Price tests a detected level within a 0.15% tolerance and closes back on the correct side of it with the same candle-strength requirement.

N-bar breakout. Price closes beyond the highest high or lowest low of the previous N bars with a directional close.

Support and resistance levels are built from confirmed pivot highs and lows. A minimum-gap rule prevents clustered levels from stacking on top of each other, and the number of active levels on each side is capped.

RSI gate. The pullback path requires RSI between 35 and 65 — it avoids entries that are already stretched. The reaction and breakout paths use wider one-sided bounds appropriate to their context.

Cooldown. A minimum number of bars must pass between signals, and a new signal in the same direction is blocked while an earlier one is still running.


READING THE PANEL

The panel in the top-right corner shows the direction of the active signal, its entry, the current stop, all three targets, the bar the signal was created on, its live status, and the current 4-hour trend state.

The status line progresses through: active, then first target reached with the stop moved to entry, then second target reached with the stop moved to the first target, then complete. If the stop is hit the panel is removed and the bar is marked on the chart.


SETTINGS

Moving averages — lengths for the three EMAs.
Support / resistance — pivot lookback, how many levels to keep on each side, and the minimum percentage gap between them.
Signal engine — RSI length, cooldown bars, breakout lookback, and how many bars before a setup is marked expired.
Targets and stop — ATR length, the three ATR multipliers, and the maximum stop size as a percentage of price.
Higher-timeframe filter — enable or disable the 4-hour trend veto.


LIMITATIONS - PLEASE READ

It runs on the 15-minute timeframe only. On any other timeframe the script draws a warning and produces nothing. The thresholds were tuned for 15-minute gold behaviour and do not transfer.

It was tuned on gold. The tolerance values, ATR multipliers and RSI bounds reflect how XAU/USD moves. On other instruments the defaults will need adjustment and the results may differ substantially.

Signals are evaluated on confirmed bars only. Nothing is drawn or evaluated from an unclosed bar, so the script does not repaint — but this also means a signal appears at the close of its bar, not during it.

The 4-hour filter uses the last closed 4-hour bar. The higher-timeframe request uses lookahead_off, so no future data is used. The consequence is that within a forming 4-hour bar the filter reflects the previous one.

Target and stop levels are calculated at the moment the signal fires and are not recalculated afterwards. If volatility changes materially after entry, the levels do not adapt.

The stop and target tracking uses bar high and low values. When both the stop and a target fall inside the same bar's range, the script resolves the stop first. Real intrabar sequence may have differed.

It does not know about scheduled news. Economic releases routinely produce moves that invalidate technical setups. The script has no awareness of the economic calendar.

This is an analysis tool, not a trading system. It does not account for spread, commission, slippage or position sizing, and no historical behaviour implies future results.


ON PERFORMANCE CLAIMS

This publication makes no claim about win rate, accuracy or profitability, because no such claim can be substantiated for future market conditions. What the script does is make each setup's assumptions explicit and visible so you can evaluate them yourself.


ORIGINALITY

The three detection paths use well-known building blocks — EMAs, RSI, ATR, pivot-based levels. The original work is in how they are combined: a structural stop bounded by a percentage ceiling, a second target that prefers real chart levels over a fixed multiple, a higher-timeframe veto applied uniformly across all three detection paths, and a per-signal outcome tracker with automatic stop progression and expiry. The code is entirely original and is published open-source so every one of these mechanics can be inspected and modified.

## Source Code

````pine
//@version=6
// Consultya Signal Indicator — v3.1 (Pine Script v6)
// v3.1 also adds an average and total in R to the tally (a third booked at
// each target), the same measure used on consultya.co.
// v3.1: signals are skipped from 60 minutes before to 60 minutes after
// scheduled US releases (official dates, same calendar as Gold News
// Reaction Map). Measured on the private research build, entries in those
// windows averaged a loss while all other entries averaged a gain.

indicator("Gold M15 Signal Engine with H4 Trend Filter", overlay=true, max_labels_count=500, max_lines_count=100)

// ══════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════
i_e20    = input.int(20,    "EMA 20",              group="Moving averages")
i_e50    = input.int(50,    "EMA 50",              group="Moving averages")
i_e200   = input.int(200,   "EMA 200",             group="Moving averages")
i_swing  = input.int(7,     "Swing Length",        group="Support / resistance")
i_maxS   = input.int(2,     "Max Supports",        group="Support / resistance")
i_maxR   = input.int(2,     "Max Resistances",     group="Support / resistance")
i_minD   = input.float(0.4, "Min Gap %",           group="Support / resistance")
i_rsiP   = input.int(14,    "RSI Period",          group="Signal engine")
i_cool   = input.int(5,     "Cooldown Bars",       group="Signal engine")
i_brk    = input.int(10,    "Breakout Bars",       group="Signal engine")
i_exp    = input.int(40,    "Expire Bars (0=off)", group="Signal engine")
i_atrP   = input.int(14,    "ATR Period",          group="Targets and stop")
i_tp1x   = input.float(0.8, "TP1 × ATR",          group="Targets and stop")
i_tp2x   = input.float(1.8, "TP2 × ATR fallback", group="Targets and stop")
i_tp3x   = input.float(3.0, "TP3 × ATR",          group="Targets and stop")
i_slPct  = input.float(0.35,"Max SL %",            group="Targets and stop")
i_stats  = input.bool(true, "Show signal tally",   group="Targets and stop", tooltip="Counts the outcomes the indicator drew across the bars this chart has loaded. It is a record of drawn outcomes, not a backtest - no spread, no slippage, no position sizing.")
i_h4     = input.bool(true, "H4 trend filter",      group="Higher-timeframe filter", tooltip="Only allow 15-minute signals that agree with the 4-hour trend. Blocks counter-trend entries.")
i_news    = input.bool(true, "Skip signals around US releases", group="News filter", tooltip="No new signal from the minutes before to the minutes after a scheduled US release. Release dates are stored from the official calendars (Fed, BLS, BEA, Census, ISM, Labor Department) and run to the end of 2027 for the main releases.")
i_nBefore = input.int(60, "Minutes before the release", minval=0, maxval=240, group="News filter")
i_nAfter  = input.int(60, "Minutes after the release",  minval=0, maxval=240, group="News filter")
i_nSet    = input.string("All ten", "Releases", options=["All ten", "Major"], group="News filter", tooltip="All ten: FOMC decision and minutes, CPI, NFP, PCE, PPI, retail sales, ISM Manufacturing and Services, weekly jobless claims. Major: FOMC decision, CPI, NFP, PCE, PPI and retail sales.")
i_nShade  = input.bool(true, "Shade the release windows", group="News filter")

// ══════════════════════════════════════════════════════════════
// CORE INDICATORS
// ══════════════════════════════════════════════════════════════
ema20  = ta.ema(close, i_e20)
ema50  = ta.ema(close, i_e50)
ema200 = ta.ema(close, i_e200)
rsiVal = ta.rsi(close, i_rsiP)
atrVal = ta.atr(i_atrP)

plot(ema20,  "EMA 20",  color=color.yellow, linewidth=1)
plot(ema50,  "EMA 50",  color=#1E90FF,      linewidth=2)
plot(ema200, "EMA 200", color=color.red,    linewidth=2)

// ══════════════════════════════════════════════════════════════
// H4 TREND FILTER
// ══════════════════════════════════════════════════════════════
h4_ema200    = request.security(syminfo.tickerid, "240", ta.ema(close, 200), lookahead=barmerge.lookahead_off)
h4_close     = request.security(syminfo.tickerid, "240", close,              lookahead=barmerge.lookahead_off)
h4_uptrend   = h4_close > h4_ema200
h4_downtrend = h4_close < h4_ema200
h4_buy_ok    = not i_h4 or h4_uptrend
h4_sell_ok   = not i_h4 or h4_downtrend
plot(h4_ema200, "H4 EMA 200", color=color.new(color.purple, 50), linewidth=1, style=plot.style_stepline)

// ══════════════════════════════════════════════════════════════
// NEWS FILTER - official US release calendar (New York time)
// k: 0 FOMC, 1 CPI, 2 NFP, 3 PPI, 4 PCE, 5 Retail, 6 ISM Mfg, 7 ISM Srv,
//    8 Claims, 9 FOMC minutes. "Major" keeps k 0-5.
// ══════════════════════════════════════════════════════════════
var array<int> relT = array.new<int>()
nAll = i_nSet == "All ten"
addT(array<int> days, int h, int mi, int k) =>
    if nAll or k <= 5
        for d in days
            array.push(relT, timestamp("America/New_York", math.floor(d / 10000), math.floor(d / 100) % 100, d % 100, h, mi))
if barstate.isfirst
    addT(array.from(20240131, 20240320, 20240501, 20240612, 20240731, 20240918), 14, 0, 0)
    addT(array.from(20241107, 20241218), 14, 0, 0)
    addT(array.from(20250129, 20250319, 20250507, 20250618, 20250730, 20250917), 14, 0, 0)
    addT(array.from(20251029, 20251210), 14, 0, 0)
    addT(array.from(20260128, 20260318, 20260429, 20260617, 20260729, 20260916), 14, 0, 0)
    addT(array.from(20261028, 20261209), 14, 0, 0)
    addT(array.from(20270127, 20270317, 20270428, 20270609, 20270728, 20270915), 14, 0, 0)
    addT(array.from(20271027, 20271208), 14, 0, 0)
    addT(array.from(20240103, 20240221, 20240410, 20240522, 20240703, 20240821), 14, 0, 9)
    addT(array.from(20241009, 20241126), 14, 0, 9)
    addT(array.from(20250108, 20250219, 20250409, 20250528, 20250709, 20250820), 14, 0, 9)
    addT(array.from(20251008, 20251119, 20251230), 14, 0, 9)
    addT(array.from(20260218, 20260408, 20260520, 20260708, 20260819, 20261007), 14, 0, 9)
    addT(array.from(20261118), 14, 0, 9)
    addT(array.from(20261230), 14, 0, 9)
    addT(array.from(20270217, 20270407, 20270519, 20270630, 20270818, 20271006), 14, 0, 9)
    addT(array.from(20271117, 20271229), 14, 0, 9)
    addT(array.from(20240111, 20240213, 20240312, 20240410, 20240515, 20240612), 8, 30, 1)
    addT(array.from(20240711, 20240814, 20240911, 20241010, 20241113, 20241211), 8, 30, 1)
    addT(array.from(20250115, 20250212, 20250312, 20250410, 20250513, 20250611), 8, 30, 1)
    addT(array.from(20250715, 20250812, 20250911, 20251024, 20251218), 8, 30, 1)
    addT(array.from(20260113, 20260213, 20260311, 20260410, 20260512, 20260610), 8, 30, 1)
    addT(array.from(20260714, 20260812, 20260911, 20261014, 20261110, 20261210), 8, 30, 1)
    addT(array.from(20270113, 20270211, 20270310, 20270413, 20270512, 20270610), 8, 30, 1)
    addT(array.from(20270714, 20270811, 20270914, 20271014, 20271110, 20271210), 8, 30, 1)
    addT(array.from(20240126, 20240229, 20240329, 20240426, 20240531, 20240628), 8, 30, 4)
    addT(array.from(20240726, 20240830, 20240927, 20241031, 20241127, 20241220), 8, 30, 4)
    addT(array.from(20250131, 20250228, 20250328, 20250430, 20250530, 20250627), 8, 30, 4)
    addT(array.from(20250731, 20250829, 20250926), 8, 30, 4)
    addT(array.from(20260220, 20260313, 20260409, 20260430, 20260528, 20260625), 8, 30, 4)
    addT(array.from(20260730, 20260826, 20260930, 20261029, 20261125, 20261223), 8, 30, 4)
    addT(array.from(20270331, 20270429, 20270527, 20270625, 20270729, 20270825), 8, 30, 4)
    addT(array.from(20270930, 20271028, 20271124), 8, 30, 4)
    addT(array.from(20251205), 10, 0, 4)
    addT(array.from(20260122), 10, 0, 4)
    addT(array.from(20240112, 20240216, 20240314, 20240411, 20240514, 20240613), 8, 30, 3)
    addT(array.from(20240712, 20240813, 20240912, 20241011, 20241114, 20241212), 8, 30, 3)
    addT(array.from(20250114, 20250213, 20250313, 20250411, 20250515, 20250612), 8, 30, 3)
    addT(array.from(20250716, 20250814, 20250910, 20251125), 8, 30, 3)
    addT(array.from(20260114, 20260130, 20260227, 20260318, 20260414, 20260513), 8, 30, 3)
    addT(array.from(20260611, 20260715, 20260813, 20260910, 20261015, 20261113), 8, 30, 3)
    addT(array.from(20261215), 8, 30, 3)
    addT(array.from(20270114, 20270212, 20270312, 20270414, 20270513, 20270611), 8, 30, 3)
    addT(array.from(20270715, 20270810, 20270910, 20271015, 20271112, 20271215), 8, 30, 3)
    addT(array.from(20240105, 20240202, 20240308, 20240405, 20240503, 20240607), 8, 30, 2)
    addT(array.from(20240705, 20240802, 20240906, 20241004, 20241101, 20241206), 8, 30, 2)
    addT(array.from(20250110, 20250207, 20250307, 20250404, 20250502, 20250606), 8, 30, 2)
    addT(array.from(20250703, 20250801, 20250905, 20251120, 20251216), 8, 30, 2)
    addT(array.from(20260109, 20260211, 20260306, 20260403, 20260508, 20260605), 8, 30, 2)
    addT(array.from(20260702, 20260807, 20260904, 20261002, 20261106, 20261204), 8, 30, 2)
    addT(array.from(20270108, 20270205, 20270305, 20270402, 20270507, 20270604), 8, 30, 2)
    addT(array.from(20270702, 20270806, 20270903, 20271008, 20271105, 20271203), 8, 30, 2)
    addT(array.from(20240117, 20240215, 20240314, 20240415, 20240515, 20240618), 8, 30, 5)
    addT(array.from(20240716, 20240815, 20240917, 20241017, 20241115, 20241217), 8, 30, 5)
    addT(array.from(20250116, 20250214, 20250317, 20250416, 20250515, 20250617), 8, 30, 5)
    addT(array.from(20250717, 20250815, 20250916, 20251125, 20251216), 8, 30, 5)
    addT(array.from(20260114, 20260210, 20260306, 20260401, 20260421, 20260514), 8, 30, 5)
    addT(array.from(20260617, 20260716, 20260814, 20260916, 20261015, 20261117), 8, 30, 5)
    addT(array.from(20261216), 8, 30, 5)
    addT(array.from(20240103, 20240201, 20240301, 20240401, 20240501, 20240603), 10, 0, 6)
    addT(array.from(20240701, 20240801, 20240903, 20241001, 20241101, 20241202), 10, 0, 6)
    addT(array.from(20250103, 20250203, 20250303, 20250401, 20250501, 20250602), 10, 0, 6)
    addT(array.from(20250701, 20250801, 20250902, 20251001, 20251103, 20251201), 10, 0, 6)
    addT(array.from(20260105, 20260202, 20260302, 20260401, 20260501, 20260601), 10, 0, 6)
    addT(array.from(20260701, 20260803, 20260901, 20261001, 20261102, 20261201), 10, 0, 6)
    addT(array.from(20270104, 20270201, 20270301, 20270401, 20270503, 20270601), 10, 0, 6)
    addT(array.from(20270701, 20270802, 20270901, 20271001, 20271101, 20271201), 10, 0, 6)
    addT(array.from(20240105, 20240205, 20240305, 20240403, 20240503, 20240605), 10, 0, 7)
    addT(array.from(20240703, 20240805, 20240905, 20241003, 20241105, 20241204), 10, 0, 7)
    addT(array.from(20250107, 20250205, 20250305, 20250403, 20250505, 20250604), 10, 0, 7)
    addT(array.from(20250703, 20250805, 20250904, 20251003, 20251105, 20251203), 10, 0, 7)
    addT(array.from(20260107, 20260204, 20260304, 20260406, 20260505, 20260603), 10, 0, 7)
    addT(array.from(20260706, 20260805, 20260903, 20261005, 20261104, 20261203), 10, 0, 7)
    addT(array.from(20270106, 20270203, 20270303, 20270405, 20270505, 20270603), 10, 0, 7)
    addT(array.from(20270706, 20270804, 20270903, 20271005, 20271103, 20271203), 10, 0, 7)
    addT(array.from(20240104, 20240111, 20240118, 20240125, 20240201, 20240208), 8, 30, 8)
    addT(array.from(20240215, 20240222, 20240229, 20240307, 20240314, 20240321), 8, 30, 8)
    addT(array.from(20240328, 20240404, 20240411, 20240418, 20240425, 20240502), 8, 30, 8)
    addT(array.from(20240509, 20240516, 20240523, 20240530, 20240606, 20240613), 8, 30, 8)
    addT(array.from(20240620, 20240627, 20240703, 20240711, 20240718, 20240725), 8, 30, 8)
    addT(array.from(20240801, 20240808, 20240815, 20240822, 20240829, 20240905), 8, 30, 8)
    addT(array.from(20240912, 20240919, 20240926, 20241003, 20241010, 20241017), 8, 30, 8)
    addT(array.from(20241024, 20241031, 20241107, 20241114, 20241121, 20241127), 8, 30, 8)
    addT(array.from(20241205, 20241212, 20241219, 20241226), 8, 30, 8)
    addT(array.from(20250102, 20250108, 20250116, 20250123, 20250130, 20250206), 8, 30, 8)
    addT(array.from(20250213, 20250220, 20250227, 20250306, 20250313, 20250320), 8, 30, 8)
    addT(array.from(20250327, 20250403, 20250410, 20250417, 20250424, 20250501), 8, 30, 8)
    addT(array.from(20250508, 20250515, 20250522, 20250529, 20250605, 20250612), 8, 30, 8)
    addT(array.from(20250618, 20250626, 20250703, 20250710, 20250717, 20250724), 8, 30, 8)
    addT(array.from(20250731, 20250807, 20250814, 20250821, 20250828, 20250904), 8, 30, 8)
    addT(array.from(20250911, 20250918, 20250925, 20251120, 20251126, 20251204), 8, 30, 8)
    addT(array.from(20251211, 20251218, 20251224, 20251231), 8, 30, 8)
    addT(array.from(20260108, 20260115, 20260122, 20260129, 20260205, 20260212), 8, 30, 8)
    addT(array.from(20260219, 20260226, 20260305, 20260312, 20260319, 20260326), 8, 30, 8)
    addT(array.from(20260402, 20260409, 20260416, 20260423, 20260430, 20260507), 8, 30, 8)
    addT(array.from(20260514, 20260521, 20260528, 20260604, 20260611, 20260618), 8, 30, 8)
    addT(array.from(20260625, 20260702, 20260709, 20260716, 20260723, 20260730), 8, 30, 8)
    addT(array.from(20260806, 20260813, 20260820, 20260827, 20260903, 20260910), 8, 30, 8)
    addT(array.from(20260917, 20260924, 20261001, 20261008, 20261015, 20261022), 8, 30, 8)
    addT(array.from(20261029, 20261105, 20261112, 20261119, 20261125, 20261203), 8, 30, 8)
    addT(array.from(20261210, 20261217), 8, 30, 8)
    addT(array.from(20261224, 20261231, 20270107, 20270114, 20270121, 20270128), 8, 30, 8)
    addT(array.from(20270204, 20270211, 20270218, 20270225, 20270304, 20270311), 8, 30, 8)
    addT(array.from(20270318, 20270325, 20270401, 20270408, 20270415, 20270422), 8, 30, 8)
    addT(array.from(20270429, 20270506, 20270513, 20270520, 20270527, 20270603), 8, 30, 8)
    addT(array.from(20270610, 20270617, 20270624, 20270701, 20270708, 20270715), 8, 30, 8)
    addT(array.from(20270722, 20270729, 20270805, 20270812, 20270819, 20270826), 8, 30, 8)
    addT(array.from(20270902, 20270909, 20270916, 20270923, 20270930, 20271007), 8, 30, 8)
    addT(array.from(20271014, 20271021, 20271028, 20271104, 20271111, 20271118), 8, 30, 8)
    addT(array.from(20271124, 20271202, 20271209, 20271216, 20271223, 20271230), 8, 30, 8)
    array.sort(relT, order.ascending)

// A bar is inside a window when its close falls between a release time
// minus the minutes before and the release time plus the minutes after.
var int pN = 0
nRel = array.size(relT)
while pN < nRel and array.get(relT, pN) + i_nAfter * 60000 < time_close
    pN += 1
nearRel = pN < nRel and array.get(relT, pN) - i_nBefore * 60000 <= time_close
bgcolor(i_news and i_nShade and nearRel ? color.new(color.orange, 88) : na, title="US release window")

// ══════════════════════════════════════════════════════════════
// M15 GUARD
// ══════════════════════════════════════════════════════════════
is_m15 = timeframe.period == "15"
if not is_m15 and barstate.islast
    label.new(bar_index, high, "Consultya: this script runs on the 15-minute timeframe only", color=color.yellow,
              textcolor=color.black, style=label.style_label_down, size=size.normal)

// ══════════════════════════════════════════════════════════════
// SUPPORT / RESISTANCE DETECTION
// ══════════════════════════════════════════════════════════════
var array<float> supArr  = array.new_float(0)
var array<float> resArr  = array.new_float(0)
var array<line>  supLns  = array.new_line(0)
var array<line>  resLns  = array.new_line(0)

f_near(arr, lvl, gap) =>
    found = false
    n = array.size(arr)
    if n > 0
        for j = 0 to n - 1
            if math.abs(array.get(arr, j) - lvl) < gap
                found := true
                break
    found

ph = ta.pivothigh(high, i_swing, i_swing)
pl = ta.pivotlow(low,   i_swing, i_swing)

if not na(ph) and is_m15
    gap = close * i_minD / 100.0
    if ph > close and not f_near(resArr, ph, gap)
        if array.size(resArr) >= i_maxR
            line.delete(array.shift(resLns))
            array.shift(resArr)
        array.push(resArr, ph)
        ln = line.new(bar_index - i_swing, ph, bar_index, ph,
             extend=extend.right, color=color.new(#FF4500, 20), style=line.style_dashed, width=1)
        array.push(resLns, ln)

if not na(pl) and is_m15
    gap = close * i_minD / 100.0
    if pl < close and not f_near(supArr, pl, gap)
        if array.size(supArr) >= i_maxS
            line.delete(array.shift(supLns))
            array.shift(supArr)
        array.push(supArr, pl)
        ln = line.new(bar_index - i_swing, pl, bar_index, pl,
             extend=extend.right, color=color.new(color.lime, 20), style=line.style_solid, width=1)
        array.push(supLns, ln)

// ══════════════════════════════════════════════════════════════
// SIGNAL STATE
// ══════════════════════════════════════════════════════════════
var int   lastSig  = -999   // g_lastSigBar
var bool  sigOn    = false   // g_sigTime != 0
var bool  sigBuy   = true    // g_sigIsBuy
var float sigEntry = na      // g_sigPrice
var float sigSL    = na      // g_sigSL
var float sigTP1   = na      // g_sigTP1
var float sigTP2   = na      // g_sigTP2
var float sigTP3   = na      // g_sigTP3
var int   sigBar   = -1      // g_sigBar
var bool  sigDone  = false   // g_sigDone
var bool  t1Hit    = false   // g_tp1Hit
var bool  t2Hit    = false   // g_tp2Hit
// R bookkeeping: a third is booked at TP1, a third at TP2, the rest at TP3,
// the stop or expiry. 1R is the distance from entry to the ORIGINAL stop.
var float sigSL0   = na
var float bookedR  = 0.0
var float openFr   = 1.0

// ══════════════════════════════════════════════════════════════
// OUTCOME COUNTERS
// A tally of what the indicator drew on the loaded history. This is
// a record of the drawn outcomes, not a backtest: no spread, no
// slippage, no sizing, and when one bar touches both the stop and a
// target the stop is assumed to come first.
// ══════════════════════════════════════════════════════════════
var int cTotal = 0   // signals fired
var int   cNews   = 0   // signals skipped by the news filter
var int cTP3   = 0   // reached TP3
var int cTP2   = 0   // reached TP2, then stopped out at TP1 (still a win)
var int cBE    = 0   // reached TP1, then stopped out at entry
var int cLoss  = 0   // stopped out before any target
var int cExp   = 0   // closed by the expiry rule with no target reached
var int   cR     = 0     // closed signals measured in R
var float sumR   = 0.0   // their total result in R (thirds model, before costs)
var int   cPos   = 0     // closed signals that ended above 0R

f_R(float px) =>
    risk = math.abs(sigEntry - sigSL0)
    risk > 0 and not na(px) ? (sigBuy ? (px - sigEntry) / risk : (sigEntry - px) / risk) : na

// ══════════════════════════════════════════════════════════════
// INFO PANEL
// ══════════════════════════════════════════════════════════════
var table pnl = table.new(position.top_right, 2, 10, bgcolor=#0D1117, border_width=1, border_color=#2A2D4A, frame_width=2, frame_color=#2A2D4A)

// ══════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════

// Nearest level helpers
f_nearestAbove(tp) =>       // nearest resistance above tp
    float best = na
    n = array.size(resArr)
    if n > 0
        for j = 0 to n - 1
            v = array.get(resArr, j)
            if v > tp and (na(best) or v < best)
                best := v
    best

f_nearestBelow(tp) =>       // nearest support below tp
    float best = na
    n = array.size(supArr)
    if n > 0
        for j = 0 to n - 1
            v = array.get(supArr, j)
            if v < tp and (na(best) or v > best)
                best := v
    best

// Build stop-loss and the three targets
f_tps(isBuy, price, base, rng, atr) =>
    maxSL = price * (i_slPct / 100.0)
    sl_   = isBuy ? base - math.min(rng * 0.5, maxSL)
                  : base + math.min(rng * 0.5, maxSL)
    tp1_  = isBuy ? price + atr * i_tp1x
                  : price - atr * i_tp1x
    nr    = f_nearestAbove(tp1_)
    ns    = f_nearestBelow(tp1_)
    tp2_  = isBuy ? (not na(nr) and nr > tp1_ ? nr : price + atr * i_tp2x)
                  : (not na(ns) and ns < tp1_ ? ns : price - atr * i_tp2x)
    tp3r  = isBuy ? price + atr * i_tp3x : price - atr * i_tp3x
    tp3_  = isBuy ? (tp3r <= tp2_ ? tp2_ + (tp2_ - price) * 0.5 : tp3r)
                  : (tp3r >= tp2_ ? tp2_ - (price - tp2_) * 0.5 : tp3r)
    [sl_, tp1_, tp2_, tp3_]

// ══════════════════════════════════════════════════════════════
// MAIN LOGIC — evaluated on confirmed bars only (no repainting)
// ══════════════════════════════════════════════════════════════
if is_m15 and barstate.isconfirmed

    rng = high - low

    // State before this bar, used to book thirds and the exit in R
    pOn   = sigOn and not sigDone
    pT1   = t1Hit
    pT2   = t2Hit
    pDone = sigDone
    pTP3  = cTP3
    expNow = false

    // ── Track the outcome of the active signal ───────────────────────────
    if sigOn and not sigDone and sigBar >= 0 and bar_index > sigBar

        if sigBuy
            // Stop-loss takes priority
            if low <= sigSL
                label.new(bar_index, sigSL, "✕ SL",
                          color=#C83C3C, textcolor=color.white,
                          style=label.style_label_up, size=size.tiny)
                sigOn   := false
                sigDone := true
                if t2Hit
                    cTP2 += 1
                else if t1Hit
                    cBE += 1
                else
                    cLoss += 1

            // TP3
            else if high >= sigTP3
                if not t1Hit
                    label.new(bar_index, sigTP1, ">> TP1",
                              color=#00C8A0, textcolor=color.black,
                              style=label.style_label_down, size=size.tiny)
                    t1Hit := true
                if not t2Hit
                    label.new(bar_index, sigTP2, ">> TP2",
                              color=#00D0A8, textcolor=color.black,
                              style=label.style_label_down, size=size.tiny)
                    t2Hit := true
                label.new(bar_index, sigTP3, ">> TP3",
                          color=#00EB78, textcolor=color.black,
                          style=label.style_label_down, size=size.tiny)
                sigDone := true
                cTP3 += 1

            // TP2
            else if not t2Hit and high >= sigTP2
                if not t1Hit
                    label.new(bar_index, sigTP1, ">> TP1",
                              color=#00C8A0, textcolor=color.black,
                              style=label.style_label_down, size=size.tiny)
                    t1Hit := true
                    sigSL := sigEntry      // SL → breakeven
                label.new(bar_index, sigTP2, ">> TP2",
                          color=#00D0A8, textcolor=color.black,
                          style=label.style_label_down, size=size.tiny)
                t2Hit := true
                sigSL := sigTP1           // SL → TP1

            // TP1
            else if not t1Hit and high >= sigTP1
                label.new(bar_index, sigTP1, ">> TP1",
                          color=#00C8A0, textcolor=color.black,
                          style=label.style_label_down, size=size.tiny)
                t1Hit := true
                sigSL := sigEntry         // SL → breakeven

        else  // SELL
            if high >= sigSL
                label.new(bar_index, sigSL, "✕ SL",
                          color=#C83C3C, textcolor=color.white,
                          style=label.style_label_down, size=size.tiny)
                sigOn   := false
                sigDone := true
                if t2Hit
                    cTP2 += 1
                else if t1Hit
                    cBE += 1
                else
                    cLoss += 1

            else if low <= sigTP3
                if not t1Hit
                    label.new(bar_index, sigTP1, ">> TP1",
                              color=#00C8A0, textcolor=color.black,
                              style=label.style_label_up, size=size.tiny)
                    t1Hit := true
                if not t2Hit
                    label.new(bar_index, sigTP2, ">> TP2",
                              color=#00D0A8, textcolor=color.black,
                              style=label.style_label_up, size=size.tiny)
                    t2Hit := true
                label.new(bar_index, sigTP3, ">> TP3",
                          color=#00EB78, textcolor=color.black,
                          style=label.style_label_up, size=size.tiny)
                sigDone := true
                cTP3 += 1

            else if not t2Hit and low <= sigTP2
                if not t1Hit
                    label.new(bar_index, sigTP1, ">> TP1",
                              color=#00C8A0, textcolor=color.black,
                              style=label.style_label_up, size=size.tiny)
                    t1Hit := true
                    sigSL := sigEntry
                label.new(bar_index, sigTP2, ">> TP2",
                          color=#00D0A8, textcolor=color.black,
                          style=label.style_label_up, size=size.tiny)
                t2Hit := true
                sigSL := sigTP1

            else if not t1Hit and low <= sigTP1
                label.new(bar_index, sigTP1, ">> TP1",
                          color=#00C8A0, textcolor=color.black,
                          style=label.style_label_up, size=size.tiny)
                t1Hit := true
                sigSL := sigEntry

    // ── Close the signal once it has run out of time ─────────────────────
    // Without this the expiry rule was display-only: the panel said
    // "Expired" while the signal kept tracking targets in the background.
    if sigOn and not sigDone and i_exp > 0 and bar_index - sigBar >= i_exp
        label.new(bar_index, sigBuy ? low : high, "⏳",
                  color=#808080, textcolor=color.white,
                  style=sigBuy ? label.style_label_up : label.style_label_down, size=size.tiny)
        sigOn   := false
        sigDone := true
        expNow  := true
        if t2Hit
            cTP2 += 1
        else if t1Hit
            cBE += 1
        else
            cExp += 1

    // ── Result in R for the signal tracked on this bar ───────────────────
    if pOn
        third = 1.0 / 3.0
        if t1Hit and not pT1
            bookedR += third * f_R(sigTP1)
            openFr  -= third
        if t2Hit and not pT2
            bookedR += third * f_R(sigTP2)
            openFr  -= third
        if sigDone and not pDone
            exitPx = cTP3 > pTP3 ? sigTP3 : expNow ? close : sigSL
            r = bookedR + openFr * f_R(exitPx)
            if not na(r)
                cR   += 1
                sumR += r
                if r > 0
                    cPos += 1

    // ── Signal detection ─────────────────────────────────────────────────
    canSig   = bar_index - lastSig >= i_cool
    actBuy   = sigOn and not sigDone and     sigBuy   // a long signal is currently running
    actSell  = sigOn and not sigDone and not sigBuy   // a short signal is currently running

    fire_buy  = false
    fire_sell = false
    buy_base  = low
    sell_base = high
    buy_clr   = color.lime
    sell_clr  = color.orange

    if canSig
        upTrd   = ema20 > ema50
        dnTrd   = ema20 < ema50
        abv200  = close > ema200
        blw200  = close < ema200
        strongU = rng > 0 and (close - low)  >= rng * 0.55
        strongD = rng > 0 and (high - close) >= rng * 0.55
        rsiOk   = rsiVal >= 35.0 and rsiVal <= 65.0

        // ── Signal 1: EMA Bounce ─────────────────────────────────────────
        // Long: uptrend, above EMA200, wick touches EMA20, closes above it, strong candle, RSI 35-65
        if upTrd and abv200 and low <= ema20 and close > ema20 and strongU and rsiOk and h4_buy_ok and not actBuy
            fire_buy := true
            buy_base := low
            buy_clr  := color.lime

        // Short: downtrend, below EMA200, wick touches EMA20, closes below it, strong candle, RSI 35-65
        else if dnTrd and blw200 and high >= ema20 and close < ema20 and strongD and rsiOk and h4_sell_ok and not actSell
            fire_sell := true
            sell_base := high
            sell_clr  := color.orange

        // ── Signal 2: SR Bounce ──────────────────────────────────────────
        if not fire_buy and not fire_sell
            tol = close * 0.0015  // 0.15% tolerance around the level

            // Long at support
            n_s = array.size(supArr)
            if n_s > 0
                for j = 0 to n_s - 1
                    lvl = array.get(supArr, j)
                    if lvl < close and low <= lvl + tol and low >= lvl - tol * 2.0 and
                         (close - low) >= rng * 0.55 and rsiVal < 60.0 and h4_buy_ok and not actBuy
                        fire_buy := true
                        buy_base := lvl
                        buy_clr  := color.aqua
                        break

            // Short at resistance
            if not fire_buy
                n_r = array.size(resArr)
                if n_r > 0
                    for j = 0 to n_r - 1
                        lvl = array.get(resArr, j)
                        if lvl > close and high >= lvl - tol and high <= lvl + tol * 2.0 and
                             (high - close) >= rng * 0.55 and rsiVal > 40.0 and h4_sell_ok and not actSell
                            fire_sell := true
                            sell_base := lvl
                            sell_clr  := color.yellow
                            break

        // ── Signal 3: N-Bar Breakout ─────────────────────────────────────
        if not fire_buy and not fire_sell and bar_index >= i_brk + 1
            hh = ta.highest(high, i_brk)[1]  // highest high of the previous N bars
            ll = ta.lowest(low,   i_brk)[1]  // lowest low of the previous N bars

            if close > hh and rng > 0 and (close - low) >= rng * 0.5 and rsiVal < 70.0 and h4_buy_ok and not actBuy
                fire_buy  := true
                buy_base  := low
                buy_clr   := color.white
            else if close < ll and rng > 0 and (high - close) >= rng * 0.5 and rsiVal > 30.0 and h4_sell_ok and not actSell
                fire_sell := true
                sell_base := high
                sell_clr  := color.fuchsia

    // ── News filter: no new signal inside a US release window ───────────
    if (fire_buy or fire_sell) and i_news and nearRel
        cNews += 1
        label.new(bar_index, fire_buy ? low - close * 0.002 : high + close * 0.002, "news",
                  color=color.new(color.gray, 55), textcolor=color.white,
                  style=fire_buy ? label.style_label_up : label.style_label_down, size=size.tiny,
                  tooltip="Signal skipped: inside a US release window")
        fire_buy  := false
        fire_sell := false

    // ── Emit the signal and store its levels ─────────────────────────────
    if fire_buy
        [sl_, tp1_, tp2_, tp3_] = f_tps(true, close, buy_base, rng, atrVal)
        off = close * 0.002
        tip = "Entry: " + str.tostring(close, format.mintick) +
              "  SL: "  + str.tostring(sl_,   format.mintick) +
              "  TP1: " + str.tostring(tp1_,  format.mintick)
        label.new(bar_index, buy_base - off, "",
                  color=buy_clr, style=label.style_arrowup, size=size.small, tooltip=tip)
        sigOn    := true
        sigBuy   := true
        sigEntry := close
        sigSL    := sl_
        sigSL0   := sl_
        bookedR  := 0.0
        openFr   := 1.0
        sigTP1   := tp1_
        sigTP2   := tp2_
        sigTP3   := tp3_
        sigBar   := bar_index
        sigDone  := false
        t1Hit    := false
        t2Hit    := false
        lastSig  := bar_index
        cTotal   += 1

    if fire_sell and not fire_buy
        [sl_, tp1_, tp2_, tp3_] = f_tps(false, close, sell_base, rng, atrVal)
        off = close * 0.002
        tip = "Entry: " + str.tostring(close,  format.mintick) +
              "  SL: "  + str.tostring(sl_,    format.mintick) +
              "  TP1: " + str.tostring(tp1_,   format.mintick)
        label.new(bar_index, sell_base + off, "",
                  color=sell_clr, style=label.style_arrowdown, size=size.small, tooltip=tip)
        sigOn    := true
        sigBuy   := false
        sigEntry := close
        sigSL    := sl_
        sigSL0   := sl_
        bookedR  := 0.0
        openFr   := 1.0
        sigTP1   := tp1_
        sigTP2   := tp2_
        sigTP3   := tp3_
        sigBar   := bar_index
        sigDone  := false
        t1Hit    := false
        t2Hit    := false
        lastSig  := bar_index
        cTotal   += 1

// ══════════════════════════════════════════════════════════════
// PANEL UPDATE — refreshes on the last bar
// ══════════════════════════════════════════════════════════════
if is_m15 and barstate.islast and sigOn
    barsEl   = bar_index - sigBar
    expired  = i_exp > 0 and barsEl >= i_exp

    // Status
    stat_txt = expired   ? "-- Expired"             :
               sigDone   ? ">> TP3 hit — signal complete"  :
               t2Hit     ? ">> TP2 hit — SL moved to TP1" :
               t1Hit     ? ">> TP1 hit — SL moved to entry" :
                           "● Active"
    stat_clr = expired   ? #808080 :
               sigDone   ? #00EB78 :
               t2Hit     ? #00D0A0 :
               t1Hit     ? #00C0B0 :
                           #50B450

    dir_txt = sigBuy ? "BUY  +" : "SELL  -"
    dir_clr = sigBuy ? #00D25A  : #DC3C3C

    sl_lbl  = str.tostring(sigSL, format.mintick) +
              (t2Hit ? " [TP1]" : t1Hit ? " [BE]" : "")

    hdr_bg  = #1A1E3A
    row_bg  = #0D1117
    dir_bg  = sigBuy ? #003A18 : #3A0010

    // Row 0 — Header
    table.cell(pnl, 0, 0, "▣ CONSULTYA", text_color=#8AB4FF, text_size=size.normal, bgcolor=hdr_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 0, "",            text_color=#8AB4FF, text_size=size.normal, bgcolor=hdr_bg)
    // Row 1 — Direction
    table.cell(pnl, 0, 1, dir_txt,       text_color=dir_clr, text_size=size.large, bgcolor=dir_bg, text_halign=text.align_center)
    table.cell(pnl, 1, 1, "",            text_color=dir_clr, text_size=size.large, bgcolor=dir_bg)
    // Row 2 — Entry
    table.cell(pnl, 0, 2, "Entry",       text_color=#BBBBBB, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 2, str.tostring(sigEntry, format.mintick), text_color=color.white, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_right)
    // Row 3 — SL
    table.cell(pnl, 0, 3, "SL",          text_color=#FF6060, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 3, sl_lbl,        text_color=#FF8080, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_right)
    // Row 4 — TP1
    table.cell(pnl, 0, 4, "TP1",         text_color=#BBBBBB, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 4, str.tostring(sigTP1, format.mintick), text_color=#64C8FF, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_right)
    // Row 5 — TP2
    table.cell(pnl, 0, 5, "TP2",         text_color=#BBBBBB, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 5, str.tostring(sigTP2, format.mintick), text_color=#00E5CC, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_right)
    // Row 6 — TP3
    table.cell(pnl, 0, 6, "TP3",         text_color=#BBBBBB, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 6, str.tostring(sigTP3, format.mintick), text_color=#00FF88, text_size=size.normal, bgcolor=row_bg, text_halign=text.align_right)
    // Row 7 — Bar
    table.cell(pnl, 0, 7, "Bar",         text_color=#555577, text_size=size.small,  bgcolor=row_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 7, str.tostring(sigBar), text_color=#555577, text_size=size.small, bgcolor=row_bg, text_halign=text.align_right)
    // Row 8 — Status
    table.cell(pnl, 0, 8, stat_txt,      text_color=stat_clr, text_size=size.normal, bgcolor=hdr_bg, text_halign=text.align_left)
    table.cell(pnl, 1, 8, "",            text_color=stat_clr, text_size=size.normal, bgcolor=hdr_bg)
    // Row 9 — H4 Filter
    h4_lbl = not i_h4 ? "H4 OFF" : h4_uptrend ? "H4 uptrend" : "H4 downtrend"
    h4_clr = not i_h4 ? #555555 : h4_uptrend  ? #00C853     : #FF1744
    table.cell(pnl, 0, 9, h4_lbl,        text_color=h4_clr,   text_size=size.small,  bgcolor=#0A0D15, text_halign=text.align_left)
    table.cell(pnl, 1, 9, "",            text_color=h4_clr,   text_size=size.small,  bgcolor=#0A0D15)

// ══════════════════════════════════════════════════════════════
// OUTCOME TALLY
// Counts what the indicator drew across the bars this chart has
// loaded. Not a backtest - see the note at the counter declarations.
// ══════════════════════════════════════════════════════════════
var table stats = table.new(position.bottom_right, 2, 12, bgcolor=#0D1117, border_width=1, border_color=#2A2D4A, frame_width=2, frame_color=#2A2D4A)

if is_m15 and barstate.islast and i_stats
    wins   = cTP3 + cTP2
    closed = wins + cBE + cLoss + cExp
    decided = wins + cLoss
    wrTxt  = decided > 0 ? str.tostring(wins * 100.0 / decided, "#.#") + "%" : "-"
    pPct   = cR > 0 ? cPos * 100.0 / cR : 0.0
    ipTxt  = cR > 0 ? str.tostring(pPct, "#.#") + "%" : "-"
    ipClr  = cR == 0 ? #9AAABB : pPct >= 50 ? #00E58A : #FF6060

    sHdr = #1A1E3A
    sRow = #0D1117

    table.cell(stats, 0, 0, "SIGNAL TALLY", text_color=#8AB4FF, text_size=size.normal, bgcolor=sHdr, text_halign=text.align_left)
    table.cell(stats, 1, 0, str.tostring(cTotal), text_color=color.white, text_size=size.normal, bgcolor=sHdr, text_halign=text.align_right)

    table.cell(stats, 0, 1, "In profit", text_color=#BBBBBB, text_size=size.large, bgcolor=sRow, text_halign=text.align_left, tooltip="Share of closed signals that ended above 0R with a third booked at TP1, a third at TP2 and the rest at TP3, the stop or expiry. A signal that reached TP1 and then closed at entry counts as in profit. Before costs.")
    table.cell(stats, 1, 1, ipTxt, text_color=ipClr, text_size=size.large, bgcolor=sRow, text_halign=text.align_right)

    table.cell(stats, 0, 2, "TP3 reached", text_color=#BBBBBB, text_size=size.normal, bgcolor=sRow, text_halign=text.align_left)
    table.cell(stats, 1, 2, str.tostring(cTP3), text_color=#00FF88, text_size=size.normal, bgcolor=sRow, text_halign=text.align_right)

    table.cell(stats, 0, 3, "TP2, closed at TP1", text_color=#BBBBBB, text_size=size.normal, bgcolor=sRow, text_halign=text.align_left)
    table.cell(stats, 1, 3, str.tostring(cTP2), text_color=#00E5CC, text_size=size.normal, bgcolor=sRow, text_halign=text.align_right)

    table.cell(stats, 0, 4, "TP1, closed at entry", text_color=#BBBBBB, text_size=size.normal, bgcolor=sRow, text_halign=text.align_left)
    table.cell(stats, 1, 4, str.tostring(cBE), text_color=#64C8FF, text_size=size.normal, bgcolor=sRow, text_halign=text.align_right)

    table.cell(stats, 0, 5, "Stopped out", text_color=#BBBBBB, text_size=size.normal, bgcolor=sRow, text_halign=text.align_left)
    table.cell(stats, 1, 5, str.tostring(cLoss), text_color=#FF6060, text_size=size.normal, bgcolor=sRow, text_halign=text.align_right)

    table.cell(stats, 0, 6, "Expired flat", text_color=#BBBBBB, text_size=size.normal, bgcolor=sRow, text_halign=text.align_left)
    table.cell(stats, 1, 6, str.tostring(cExp), text_color=#9AAABB, text_size=size.normal, bgcolor=sRow, text_halign=text.align_right)

    table.cell(stats, 0, 7, "Closed / still open", text_color=#8899AA, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_left)
    table.cell(stats, 1, 7, str.tostring(closed) + " / " + str.tostring(cTotal - closed), text_color=#8899AA, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_right)

    avgR = cR > 0 ? sumR / cR : 0.0
    rClr = sumR > 0 ? #00E58A : sumR < 0 ? #FF6060 : #9AAABB
    table.cell(stats, 0, 9, "Avg R per trade", text_color=#BBBBBB, text_size=size.normal, bgcolor=sRow, text_halign=text.align_left, tooltip="Each closed signal in units of its original risk (1R = entry to the first stop), booking a third at TP1, a third at TP2 and the rest at TP3, the stop or expiry. Before spread, slippage and commission.")
    table.cell(stats, 1, 9, cR > 0 ? (avgR >= 0 ? "+" : "") + str.tostring(avgR, "0.000") + "R" : "-", text_color=rClr, text_size=size.normal, bgcolor=sRow, text_halign=text.align_right)
    table.cell(stats, 0, 10, "Total R  ·  thirds, before costs", text_color=#8899AA, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_left)
    table.cell(stats, 1, 10, cR > 0 ? (sumR >= 0 ? "+" : "") + str.tostring(sumR, "0.0") + "R" : "-", text_color=rClr, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_right)

    table.cell(stats, 0, 8, i_news ? "Skipped near US releases" : "News filter off", text_color=#8899AA, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_left)
    table.cell(stats, 1, 8, i_news ? str.tostring(cNews) : "-", text_color=#8899AA, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_right)

    table.cell(stats, 0, 11, "Reached TP2 vs stopped", text_color=#8899AA, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_left, tooltip="TP2 or TP3 reached, divided by TP2 or TP3 reached plus stopped out. Signals that closed at entry after TP1 are left out. This was the Win rate row before v3.1.")
    table.cell(stats, 1, 11, wrTxt, text_color=#8899AA, text_size=size.small, bgcolor=#0A0D15, text_halign=text.align_right)
````
