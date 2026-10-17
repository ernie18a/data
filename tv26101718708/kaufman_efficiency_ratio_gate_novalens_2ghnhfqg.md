# Kaufman Efficiency Ratio Gate [NovaLens]

- url: https://www.tradingview.com/script/2Ghnhfqg-Kaufman-Efficiency-Ratio-Gate-NovaLens/
- type: indicator
- pine_id: PUB;732e1b9f2d04496b974d5b6604d3118b
- version: 1.0

## Description

Kaufman Efficiency Ratio Gate is a regime classifier that separates trending markets from choppy ones. Instead of plotting a raw ratio and leaving you to interpret thresholds, it ranks the current Kaufman Efficiency Ratio within its own recent history and outputs a binary gate: trend-favorable or chop-dominant. Five timeframe-specific presets ship ready to use - pick the one matching your chart.


◉ [b]HOW IT WORKS[/b]

The Efficiency Ratio measures how much of price's total movement was directional over N bars:

ER = |Close - Close(N)| / Σ|Close(i) - Close(i-1)|

A value near 1.0 means price moved in a straight line - maximum efficiency. A value near 0 means price covered distance but went nowhere net - noise. Perry Kaufman introduced this in "Trading Systems and Methods" (1995) as the foundation for his Adaptive Moving Average.

Raw ER values are hard to threshold because what counts as "efficient" varies by asset and timeframe. This gate solves that with a three-stage pipeline:

 • [b]Light EMA smoothing[/b] - removes single-bar noise from the raw ER without adding meaningful lag (Smoothing = 2 for most presets).

 • [b]Percentile rank[/b] - ranks the smoothed ER within its own rolling window. A reading at the 70th percentile means the current efficiency is higher than 70% of recent history. This is what makes the gate self-normalizing. A "trending" efficiency ratio for Gold might sit at 0.45, while for a volatile altcoin it might be 0.25 - the gate adjusts automatically to each asset's own baseline, so you never need to guess at fixed thresholds.

 • [b]Symmetric hysteresis[/b] - the gate opens when rank crosses above the median + Stability/2, and closes when rank drops below the median - Stability/2. This prevents flicker at the boundary. A small buffer (Stability = 2) is enough because KER is already a clean ratio.

Other regime tools approach this differently. ADX measures trend strength through smoothed directional movement - it tells you how strong a trend is, but its fixed scale means a reading of 25 carries different weight on different instruments. The Choppiness Index compresses ATR relative to the window's price range into a 0-100 scale - useful, but sensitive to window length and not inherently normalized. The Efficiency Ratio takes a more direct route: what fraction of total movement was net directional? And the percentile-rank layer on top makes that reading self-normalizing across any asset or timeframe - no manual threshold tuning required.

The result is a binary state: trend-favorable (gate open) or chop-dominant (gate closed).


◈ [b]HOW TO READ IT[/b]

 • [b]Teal background / teal hero line[/b] - Gate open. The market's directional efficiency is above its recent median. Trend-following setups tend to perform better in this environment.

 • [b]Amber background / amber hero line[/b] - Gate closed. Efficiency is below the median - price is moving but not going anywhere. Trend-following setups historically tend to underperform in this environment.

 • [b]Bright teal (strong trend)[/b] - Smoothed KER is in the top 25% of its recent rank window. The trend is unusually clean - continuation setups tend to be cleaner in this state.

 • [b]Bright amber (strong chop)[/b] - Smoothed KER is in the bottom 25%. Noise is dominant - even range-bound strategies may find fewer clean entries. Generally a low-opportunity environment.

The info panel (top-right) shows the current gate state, smoothed KER value, percentile rank, and a momentum readout (strengthening / weakening / stable) based on how the rank has moved over the last few bars.


✦ [b]HOW WE USE IT - REGIME FILTER[/b]

In systematic trading, the Efficiency Ratio often serves as one of the regime filters applied before a trend-following signal gets capital allocation. The idea is to confirm that the market is actually trending efficiently, not just moving.

When the gate is open (teal), directional efficiency is elevated. Pullback entries, breakout continuations, trend-following MA crosses - these setups tend to perform better because price is converting movement into net progress. When the gate closes (amber), the same setups historically tend to underperform. Price is volatile but going nowhere. In choppy regimes, trend-following systems generally struggle, and while mean reversion may be more favorable, it remains a harder environment to trade overall. Many systematic traders use this kind of regime awareness to reduce exposure or adjust position sizing rather than forcing directional bets.

The gate works well as a context overlay alongside other entry signals. It doesn't indicate which direction to trade, but it helps characterize whether the current environment is rewarding directional movement at all.

What the gate is NOT: a forward predictor. It classifies the recent past. A gate-open reading means efficiency has been high - it doesn't guarantee the next bar will trend. It's a filter, not a crystal ball.


◆ [b]OTHER APPLICATIONS[/b]

 • [b]Entry filter[/b] - pair with any trend-following signal (MA cross, breakout, RSI) and add a gate-open condition. Filtering out chop regimes can help reduce whipsaw entries.

 • [b]Multi-timeframe confirmation[/b] - checking the gate on a higher timeframe before entering on a lower one can add confidence. For example, a Daily gate-open reading alongside a 4H trend entry.

 • [b]Regime-aware sizing[/b] - some traders scale position size with regime state, increasing exposure during gate-open periods and reducing it when the gate closes.

 • [b]Alert-driven workflow[/b] - set alerts on gate open/close transitions and check your trend setups only when the gate fires.


⚙ [b]SETTINGS[/b]

[b]Preset[/b] (default: Daily) - Timeframe-specific parameter bundles. Select the one matching your chart resolution:

 • [b]Weekly[/b] - KER 10, Smoothing 2, Rank Window 100, Stability 2. Long context window for position traders.

 • [b]Daily[/b] - KER 8, Smoothing 2, Rank Window 50, Stability 2. The default. Works well on most daily charts.

 • [b]8H[/b] - KER 8, Smoothing 2, Rank Window 50, Stability 2. Starting point same as Daily - validate on your own 8H charts.

 • [b]4H[/b] - KER 14, Smoothing 2, Rank Window 30, Stability 2. Wider KER period compensates for noisier intraday data.

 • [b]30m[/b] - KER 5, Smoothing 5, Rank Window 30, Stability 2. Short KER period with heavier smoothing for fast charts.

 • [b]Custom[/b] - Drive the gate from the four inputs below.

[b]KER Period[/b] - Lookback for the raw Efficiency Ratio. Shorter (5-8) reacts faster to regime changes. Longer (14-20) gives more stable readings but lags transitions.

[b]Smoothing[/b] - EMA applied to the raw KER. Set to 1 for no smoothing. KER is self-normalizing by construction, so low values (1-5) are usually enough.

[b]Rank Window[/b] - Rolling window for the percentile rank. Controls how much recent history defines "typical." Shorter windows adapt faster; longer windows give more stable context.

[b]Stability[/b] - Hysteresis half-width around the 50th percentile. At 0, the gate flips the instant rank crosses the median. At higher values, the gate requires a stronger signal to switch state. Low values (2-5) work well since KER is already a clean signal.

[b]Display toggles:[/b]

 • Show Raw KER - thin white line showing the unsmoothed ratio

 • Show Median - 50th-percentile reference line on the smoothed KER

 • Show Background - teal/amber background wash (turn off if your workspace already signals the regime elsewhere)

 • Show Info Panel - gate state, KER, rank, and momentum readout

 • Light Theme - flips panel colours for light chart backgrounds


△ [b]LIMITATIONS[/b]

 • [b]Backward-looking[/b] - the gate classifies recent efficiency, not future direction. Regimes can shift faster than the rank window catches, especially around news events.

 • [b]Directionless[/b] - both strong uptrends and strong downtrends produce gate-open readings. A separate directional indicator is needed to determine which side to trade.

 • [b]Noise on thin instruments[/b] - short KER periods on low-volume assets can produce noisy readings even with smoothing.

 • [b]History requirement[/b] - percentile rank needs sufficient data to be meaningful. The first ~50-100 bars on any chart (depending on preset) will have unstable rankings.


⌁ [b]NOTES[/b]

 • Based on Perry Kaufman's Efficiency Ratio from "Trading Systems and Methods" (1995)

 • Cross-validated against our PyneCore Python reference implementation.

 • Parameters were tuned on gold (XAUUSD) via the NovaLens research pipeline. The same presets generalize reasonably to other assets - though testing on your own instruments is always recommended.

 • Regime palette: teal = trend-favorable, amber = chop-dominant. Not green/red - this is a state classifier, not a directional signal.

If you find a Custom parameter set that works well on a different instrument, the comments are a good place to share it.

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// © NovaLens

//@version=6

// ──────────────────────────────────────────────────────────────────────────────
// Indicator:  NovaLens ER-01 — Kaufman Efficiency Ratio Gate
// Version:    3.1.0
// Release:    2026-04
// Author:     NovaLens Quantitative Research
// Profile:    https://www.tradingview.com/u/NovaLens/
// ──────────────────────────────────────────────────────────────────────────────
// A binary regime gate built on Kaufman's Efficiency Ratio. Each bar is
// classified as trend-favorable or chop-dominant by ranking the current
// KER reading within its own recent history, with symmetric hysteresis
// around the median to prevent flicker. Five timeframe-specific presets —
// Weekly / Daily / 8H / 4H / 30m — match the TradingView resolution
// dropdown one-to-one, so users pick the preset that matches their chart.
// Parameters were tuned on gold via the NovaLens research pipeline; the
// percentile-rank design is self-normalizing by construction so the same
// bundles generalize reasonably to other assets. The gate is a visual
// retrospective classifier — a filter, not a forward predictor.
// ──────────────────────────────────────────────────────────────────────────────

indicator("Kaufman Efficiency Ratio Gate [NovaLens]", shorttitle="KER Gate [NovaLens]", overlay=false, precision=3)

// ─── Brand constants ────────────────────────────────────────────────────────
string BRAND_NAME    = "NovaLens"
string BRAND_ENTITY  = "NovaLens Quantitative Research"
string BRAND_PROFILE = "https://www.tradingview.com/u/NovaLens/"
string productCode   = "ER-01"
string productTier   = "Free"

// ─── Preset ─────────────────────────────────────────────────────────────────
profile = input.string("Daily", "Preset", options=["Weekly", "Daily", "8H", "4H", "30m", "Custom"], group="Presets",
     tooltip="Timeframe-specific bundles. Select the one matching your chart resolution. Each bundle is (KER Period, Smoothing, Rank Window, Stability).\n\n• Weekly — 10, 2, 100, 2\n• Daily  — 10, 2,  50, 10\n• 8H     —  8, 2,  50, 2\n• 4H     — 14, 2,  30, 2\n• 30m    —  5, 5,  30, 2\n\n• Custom — drive the gate from the Custom inputs below.\n\nThe design uses minimal Smoothing and Stability (2–5) and lets KER Period + Rank Window do the real work, because the raw KER ratio is already self-normalizing by construction.\n\nNote: selecting a preset does not visually update the Custom inputs (Pine limitation). The gate still uses the preset values above whenever a named preset is active.")

// ─── Custom parameters (active when Preset = Custom) ───────────────────────
erLength    = input.int(8,  "KER Period",   minval=2,  group="Custom", tooltip="Active when Preset = Custom. Lookback (in bars) for the raw Kaufman Efficiency Ratio. Shorter = more responsive to recent moves.")
smoothLen   = input.int(2,  "Smoothing",    minval=1,  group="Custom", tooltip="Active when Preset = Custom. EMA length applied to the raw KER. Set to 1 for no smoothing (raw KER drives the gate directly). KER is self-normalizing, so low values (1–5) are usually enough. Heavier smoothing = slower, cleaner hero line at the cost of lag.")
pctLookback = input.int(50, "Rank Window",  minval=20, group="Custom", tooltip="Active when Preset = Custom. Rolling window (in bars) over which the percentile rank of the smoothed KER is computed. Controls how much recent history defines 'typical' for this market. Short windows adapt faster; long windows give more stable context.")
stability   = input.int(2,  "Stability",    minval=0, maxval=50, step=2, group="Custom", tooltip="Active when Preset = Custom. Hysteresis half-width around the 50th percentile. At Stability=0 the gate flips the instant rank crosses the median; at Stability=30 the gate only enters Trend-favorable at rank 65 and exits at rank 35. With clean KER signals, low values (2–5) are usually enough.")

showRaw        = input.bool(true,  "Show Raw KER",    group="Display")
showMedian     = input.bool(true,  "Show Median",     group="Display", tooltip="Thin 50th-percentile reference line on the smoothed KER series, so you can see where the current reading sits relative to its own typical value.")
showBackground = input.bool(true,  "Show Background", group="Display", tooltip="Toggle the teal/amber gate-state background wash. Turn off for a cleaner chart if your workspace already signals the regime elsewhere.")
showInfoPanel  = input.bool(true,  "Show Info Panel", group="Display")
lightTheme     = input.bool(false, "Light Theme",     group="Display", tooltip="Flip the info panel colours to dark-on-white for TradingView's light chart theme.")

// ─── Tier colour inputs ─────────────────────────────────────────────────────
colStrongTrend = input.color(color.rgb(0, 230, 180),   "Strong Trend", group="Colours", tooltip="Hero-line colour when gate is open AND smoothed KER is in the top 25% of its recent history.")
colTrend       = input.color(color.rgb(0, 180, 140),   "Trend",        group="Colours", tooltip="Hero-line colour when gate is open (Trend-favorable) in all other cases.")
colChop        = input.color(color.rgb(255, 160, 40),  "Chop",         group="Colours", tooltip="Hero-line colour when gate is closed (Chop-dominant) in all other cases.")
colStrongChop  = input.color(color.rgb(255, 200, 80),  "Strong Chop",  group="Colours", tooltip="Hero-line colour when gate is closed AND smoothed KER is in the bottom 25% of its recent history.")

// ─── Preset resolution ──────────────────────────────────────────────────────
// Single-line ternaries (Pine v6 is finicky with multi-line continuation).
int erLenEff     = profile == "Weekly" ? 10  : profile == "Daily" ? 10 : profile == "8H" ? 8  : profile == "4H" ? 14 : profile == "30m" ? 5  : erLength
int smoothEff    = profile == "Weekly" ? 2   : profile == "Daily" ? 2  : profile == "8H" ? 2  : profile == "4H" ? 2  : profile == "30m" ? 5  : smoothLen
int rankEff      = profile == "Weekly" ? 100 : profile == "Daily" ? 50 : profile == "8H" ? 50 : profile == "4H" ? 30 : profile == "30m" ? 30 : pctLookback
int stabilityEff = profile == "Weekly" ? 2   : profile == "Daily" ? 10 : profile == "8H" ? 2  : profile == "4H" ? 2  : profile == "30m" ? 2  : stability

float enterPct = 50.0 + stabilityEff / 2.0
float exitPct  = 50.0 - stabilityEff / 2.0

// ─── Calculation ────────────────────────────────────────────────────────────
direction  = math.abs(close - close[erLenEff])
volatility = math.sum(math.abs(close - close[1]), erLenEff)
ker = volatility != 0 ? direction / volatility : 0.0

// smoothEff <= 1 skips the EMA entirely, so Custom mode can express
// "raw KER drives the gate, no smoothing". Presets never hit this branch.
kerSmooth = smoothEff <= 1 ? ker : ta.ema(ker, smoothEff)

// Rank Window is preset-dependent via rankEff (simple int — all branches
// are const-int literals or the simple-int pctLookback input), so it can
// be passed directly to ta.percentrank / ta.percentile_linear_interpolation.
float pctRank = nz(ta.percentrank(kerSmooth, rankEff), 50.0)
float p50     = ta.percentile_linear_interpolation(kerSmooth, rankEff, 50)

// ─── Binary gate (percentile-rank with symmetric hysteresis) ───────────────
var bool gateTrade = false
if not gateTrade and pctRank >= enterPct
    gateTrade := true
else if gateTrade and pctRank <= exitPct
    gateTrade := false

// ─── Colours (non-tier) ─────────────────────────────────────────────────────
color neutral     = color.rgb(120, 123, 134)
color tealBright  = color.rgb(0, 230, 180)
color amberBright = color.rgb(255, 200, 80)
color rawLineCol  = color.new(color.white, 75)
color medLineCol  = color.new(color.rgb(200, 200, 200), 70)
color bgTrade     = color.new(color.rgb(0, 90, 68), 70)
color bgWait      = color.new(color.rgb(90, 55, 0), 78)

color kerTierColor = gateTrade ? (pctRank >= 75 ? colStrongTrend : colTrend)
                               : (pctRank <= 25 ? colStrongChop  : colChop)

// ─── Visuals ────────────────────────────────────────────────────────────────
plot(showMedian ? p50 : na, "Median", color=medLineCol, linewidth=1)
plot(showRaw    ? ker : na, "Raw KER", color=rawLineCol, linewidth=1)
plot(kerSmooth, "Smoothed KER", color=kerTierColor, linewidth=4)

bgcolor(showBackground ? (gateTrade ? bgTrade : bgWait) : na)

// ─── Regime change tracking (alerts only) ───────────────────────────────────
bool prevGate     = bar_index > 0 ? gateTrade[1] : false
bool enteredTrade = gateTrade and not prevGate
bool exitedTrade  = not gateTrade and prevGate

// ─── Info Panel ─────────────────────────────────────────────────────────────
if barstate.islast and showInfoPanel
    string stateStr = gateTrade ? "Trend-favorable" : "Chop-dominant"

    string smoothStr = str.tostring(kerSmooth, "#0.000")
    string rankStr   = str.tostring(pctRank, "#0") + "th pct"
    string rawKerStr = str.tostring(ker, "#0.000")

    float rankDelta = bar_index >= 4 ? pctRank - pctRank[4] : 0.0
    float momThresh = 5.0
    bool reinforces = gateTrade ? rankDelta >  momThresh : rankDelta < -momThresh
    bool undermines = gateTrade ? rankDelta < -momThresh : rankDelta >  momThresh
    string momentumStr = reinforces ? "Strengthening" : undermines ? "Weakening" : "Stable"

    color tblBg     = lightTheme ? color.new(color.rgb(250, 250, 252), 10) : color.new(color.black, 15)
    color tblFrame  = lightTheme ? color.new(color.rgb(170, 175, 190), 30) : color.new(neutral, 30)
    color tblBorder = lightTheme ? color.new(color.rgb(200, 205, 215), 40) : color.new(neutral, 50)
    color titleCol  = lightTheme ? color.rgb(15, 20, 35)  : color.white
    color labelCol  = lightTheme ? color.rgb(90, 95, 115) : neutral
    color valueCol  = lightTheme ? color.rgb(25, 30, 45)  : color.white

    color trendWordCol = lightTheme ? color.rgb(0, 120, 90)  : tealBright
    color chopWordCol  = lightTheme ? color.rgb(170, 95, 0)  : amberBright
    color stableCol    = lightTheme ? color.rgb(25, 30, 45)  : color.new(color.white, 20)

    color gateCol     = gateTrade ? trendWordCol : chopWordCol
    color momentumCol = reinforces ? trendWordCol : undermines ? chopWordCol : stableCol

    var table infoPanel = table.new(position.top_right, 2, 6, bgcolor=tblBg, border_width=1, border_color=tblBorder, frame_width=2, frame_color=tblFrame)
    table.cell(infoPanel, 0, 0, "KER Gate [NovaLens]", text_color=titleCol, text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 0, profile,               text_color=labelCol, text_size=size.normal, text_halign=text.align_right)
    table.cell(infoPanel, 0, 1, "State",               text_color=labelCol, text_size=size.small,  text_halign=text.align_left)
    table.cell(infoPanel, 1, 1, stateStr,              text_color=gateCol,  text_size=size.large,  text_halign=text.align_right)
    table.cell(infoPanel, 0, 2, "KER",                 text_color=labelCol, text_size=size.small,  text_halign=text.align_left)
    table.cell(infoPanel, 1, 2, smoothStr,             text_color=valueCol, text_size=size.small,  text_halign=text.align_right)
    table.cell(infoPanel, 0, 3, "Rank",                text_color=labelCol, text_size=size.small,  text_halign=text.align_left)
    table.cell(infoPanel, 1, 3, rankStr,               text_color=valueCol, text_size=size.small,  text_halign=text.align_right)
    table.cell(infoPanel, 0, 4, "Raw KER",             text_color=labelCol, text_size=size.small,  text_halign=text.align_left)
    table.cell(infoPanel, 1, 4, rawKerStr,             text_color=valueCol, text_size=size.small,  text_halign=text.align_right)
    table.cell(infoPanel, 0, 5, "Momentum",            text_color=labelCol, text_size=size.small,  text_halign=text.align_left)
    table.cell(infoPanel, 1, 5, momentumStr,           text_color=momentumCol, text_size=size.normal, text_halign=text.align_right)

// ─── Alerts ─────────────────────────────────────────────────────────────────
alertcondition(enteredTrade, "KER Gate Open",  "KER Gate opened — smoothed KER rank crossed above entry level (Trend-favorable)")
alertcondition(exitedTrade,  "KER Gate Close", "KER Gate closed — smoothed KER rank fell below exit level (Chop-dominant)")
````
