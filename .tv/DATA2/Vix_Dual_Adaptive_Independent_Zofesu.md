<!-- tradingview-pine-id: PUB;9df1128b55e94c3cb97beebee731be2d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Vix Dual Adaptive (Independent) [Zofesu]

Source: https://www.tradingview.com/script/DyDBRNV0-Vix-Dual-Adaptive-Independent-Zofesu/

## Description

CREDITS
Based on the Williams VIX Fix concept originally published on TradingView by ChrisMoody (CM_Williams_Vix_Fix, 2014, open-source). Original script: tradingview.com/v/og7JPrRA/
The underlying VIX Fix formula was created by Larry Williams and is public domain.

─────────────────────────────────────

Vix Dual Adaptive (Independent) [Zofesu] is a sentiment oscillator that runs two fully independent Williams VIX Fix engines simultaneously — one calibrated to detect capitulation, one calibrated to detect euphoria. Each engine has its own lookback window, its own percentile threshold, and its own dual-layer statistical filter.

The standard VIX Fix measures fear only: one engine, one direction, shared parameters. This implementation adds an inverse engine that mirrors the calculation to detect overextension at the top of a move, and separates the calibration of both engines so each can be tuned to the specific behavior of the asset and timeframe being traded.

─────────────────────────────────────
01 — What is Vix Dual Adaptive?
─────────────────────────────────────
The indicator plots two histograms from a common zero line — Fear above, Greed below. A histogram bar lights up only when its engine registers a statistically extreme reading. When no extreme is present, bars render in black and serve purely as visual anchors for candle alignment.

Fear Engine (Lime)
Measures how far the current low sits below the highest recent close. Large values mean price has dropped sharply from a recent peak — capitulation conditions.
Formula: (highest(close, lb) − low) / highest(close, lb) × 100

Greed Engine (Purple) — original extension
Measures how far the current high sits above the lowest recent low. Large negative values mean price has extended sharply from a recent trough — euphoric conditions.
Formula: −((high − lowest(low, lb)) / lowest(low, lb) × 100)

─────────────────────────────────────
02 — Why Two Independent Engines
─────────────────────────────────────
Market tops and bottoms do not behave symmetrically. Bottoms form through fast, violent capitulation — often a single bar of panic selling. Tops form through slow distribution — extended drift with decreasing momentum.

A single-engine VIX Fix with shared parameters cannot capture both. A lookback tuned to catch sharp capitulation will miss slow euphoric extension, and a lookback tuned for drift will smooth away panic spikes entirely.

Running two engines with independent lookback windows and independent percentile thresholds solves this. The Fear engine can be set short and sensitive; the Greed engine can be set longer and more selective — or the reverse, depending on the asset's character.

─────────────────────────────────────
03 — Dual Threshold Filtering
─────────────────────────────────────
Each engine filters its raw value through two independent statistical thresholds. A signal bar appears when either threshold is crossed.

Threshold 1 — Bollinger Band boundary
SMA of the VIX Fix value plus or minus 2 standard deviations, calculated over the engine's lookback period. This boundary adapts dynamically to current volatility — it tightens in calm markets and widens during turbulence.

Threshold 2 — Percentile rank line
The highest (or lowest) VIX Fix value recorded over twice the lookback period, multiplied by the percentile setting. At 0.99 this means only readings in the top 1% of the historical range qualify. This threshold is absolute rather than adaptive — it anchors the signal to the asset's own extreme history.

Signal logic:
Fear bar — wvf ≥ BB upper OR wvf ≥ percentile threshold
Greed bar — wvf ≤ BB lower OR wvf ≤ percentile threshold

Using OR rather than AND is intentional. Either condition alone represents a statistically meaningful extreme; requiring both would suppress the majority of valid signals.

─────────────────────────────────────
04 — Settings
─────────────────────────────────────
Fear Lookback — default 145
Bars used for the Fear engine's VIX Fix and Bollinger Band calculation. Higher = smoother, fewer signals.

Fear Percentile — default 0.99
Statistical rank required for a Fear signal. 0.99 = only the top 1% of extremes qualify. Lower values produce more signals.

Greed Lookback — default 148
Independent from the Fear lookback. Tune separately.

Greed Percentile — default 0.99
Independent from the Fear percentile. Tune separately.

Show Bollinger Bands — default off
Show Percentile Lines — default off
Both boundary lines are hidden by default. Enable them during calibration to see where the thresholds sit relative to the histogram, then hide them once the settings are finalized.

─────────────────────────────────────
05 — Calibration
─────────────────────────────────────
Each asset and timeframe requires its own settings. There is no universal configuration — the defaults are calibrated for D1 on major instruments and should be treated as a starting point.

Step 1 — Enable both boundary lines so the thresholds are visible against the histogram.

Step 2 — Set the percentile to 0.99 and adjust the lookback across a range of 50 to 500. Watch how the signal density changes.

Step 3 — Reduce the percentile gradually until the number of signals matches your trading frequency. Fewer, higher-conviction signals for swing trading; more signals for active trading.

Step 4 — Repeat independently for the second engine. The two engines do not need matching values.

Step 5 — Hide the boundary lines once calibration is complete.

Save the finished configuration as an indicator template so it can be reapplied per instrument or TimeFrame.

─────────────────────────────────────
06 — Signal Interpretation
─────────────────────────────────────
Fear bar appears — the market has reached a statistically extreme oversold condition. Potential bullish reversal zone.

Greed bar appears — the market has reached a statistically extreme overextended condition. Potential bearish reversal zone.

The entry trigger is not the appearance of the bar. It is the moment the bar disappears on a closed candle — this confirms the extreme condition has ended rather than continuing. Entry on the following candle.

A bar that stays lit across multiple candles indicates a sustained trend or ongoing accumulation, not a reversal. Waiting for the bar to close and disappear is what separates a reversal signal from a continuation warning.

If both Fear and Greed register simultaneously, the two engines are reading conflicting pressure. This typically occurs during high-volatility expansion. Check the higher timeframe and wait for support or resistance confirmation before entering.

─────────────────────────────────────
07 — How To Use
─────────────────────────────────────
Step 1 — Calibrate the indicator to your instrument and timeframe using the process in section 05.

Step 2 — Wait for a colored histogram bar. Black bars carry no signal.

Step 3 — Do not enter while the bar is lit. Wait for it to disappear on a closed candle.

Step 4 — Enter on the next candle open. Stop loss beyond the extreme of the signal range.

Step 5 — Confirm with structure. A Fear signal landing on a known support level is significantly stronger than one occurring in open space. The indicator identifies when sentiment is extreme; it does not identify where price will turn.

Works on all asset classes: Indices, Stocks, Forex, Gold, Oil, Crypto.
Best timeframes: D1, W1.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu
//
// CREDITS:
// Based on the Williams VIX Fix concept originally published by ChrisMoody
// on TradingView (CM_Williams_Vix_Fix, 2014, open-source).
// Original script: https://www.tradingview.com/v/og7JPrRA/
// The underlying VIX Fix formula was created by Larry Williams and is public domain.
//
// ORIGINAL ADDITIONS by Zofesu:
// — Dual independent engine architecture (Fear + Greed calculated separately)
// — Inverse VIX engine for greed/euphoria detection (original concept)
// — Independent lookback windows for each engine
// — Independent percentile thresholds for each engine
// — Dual threshold filtering (BB + Percentile) per engine
// — Black histogram anchors for candle alignment

//@version=6
indicator("Vix Dual Adaptive (Independent) [Zofesu]", overlay=false, shorttitle="[Zofesu] Vix Dual Adaptive")

// --- FEAR SETTINGS (Top) ---
grp_fear = "FEAR SETTINGS (Lime)"
lb_f = input.int(145, "Fear Lookback", minval=10, group=grp_fear, tooltip="Number of bars used for the Fear engine's VIX Fix and Bollinger Band calculation. Higher = smoother, fewer signals. Independent from the Greed lookback. Default 145.")
ph_f = input.float(0.99, "Fear Percentile", step=0.01, group=grp_fear, tooltip="Statistical rank required for a Fear signal, applied to the highest VIX Fix value over twice the lookback period. 0.99 = only the top 1% of extremes qualify. Lower values produce more signals. Default 0.99.")

// --- GREED SETTINGS (Below) ---
grp_greed = "GREED SETTINGS (Purple)"
lb_g = input.int(148, "Greed Lookback", minval=10, group=grp_greed, tooltip="Number of bars used for the Greed engine's inverse VIX Fix and Bollinger Band calculation. Independent from the Fear lookback — tune separately. Default 148.")
ph_g = input.float(0.99, "Greed Percentile", step=0.01, group=grp_greed, tooltip="Statistical rank required for a Greed signal, applied to the lowest inverse VIX Fix value over twice the lookback period. Independent from the Fear percentile. Default 0.99.")

// Visibility toggles
show_bb = input.bool(false, "Show Bollinger Bands", tooltip="Displays the adaptive Bollinger Band boundary for both engines. Enable during calibration to see where the threshold sits relative to the histogram, then hide once settings are finalized.")
show_ph = input.bool(false, "Show Percentile Lines", tooltip="Displays the percentile rank threshold line for both engines. Enable during calibration to judge signal density, then hide once settings are finalized.")

// --- 1. FEAR CALCULATION (Vix Fix - Upward) ---
wvf_fear = ((ta.highest(close, lb_f) - low) / ta.highest(close, lb_f)) * 100

upper_f   = ta.sma(wvf_fear, lb_f) + (2.0 * ta.stdev(wvf_fear, lb_f))
percent_f = ta.highest(wvf_fear, lb_f * 2) * ph_f

is_panic = wvf_fear >= upper_f or wvf_fear >= percent_f
col_fear = is_panic ? color.lime : color.rgb(0, 0, 0)

// --- 2. GREED CALCULATION (Inverse Vix - Downward) ---
// Original Zofesu extension: mirrors the VIX Fix logic inverted to detect euphoria
wvf_greed = ((high - ta.lowest(low, lb_g)) / ta.lowest(low, lb_g)) * -100

upper_g   = ta.sma(wvf_greed, lb_g) - (2.0 * ta.stdev(wvf_greed, lb_g))
percent_g = ta.lowest(wvf_greed, lb_g * 2) * ph_g

is_greed = wvf_greed <= upper_g or wvf_greed <= percent_g
col_greed = is_greed ? color.rgb(184, 33, 243) : color.rgb(2, 2, 2)

// --- VISUALIZATION ---
hline(0, "Neutral", color=color.new(color.gray, 50))

// Histograms
plot(wvf_fear, title="Fear Histogram", style=plot.style_histogram, linewidth=4, color=col_fear)
plot(wvf_greed, title="Greed Histogram", style=plot.style_histogram, linewidth=4, color=col_greed)

// Borders Fear (Positive)
plot(show_bb ? upper_f : na, title="Fear BB", color=color.aqua, linewidth=1)
plot(show_ph ? percent_f : na, title="Fear Percentile", color=color.orange, linewidth=1)

// Borders Greed (Negative)
plot(show_bb ? upper_g : na, title="Greed BB", color=color.aqua, linewidth=1)
plot(show_ph ? percent_g : na, title="Greed Percentile", color=color.orange, linewidth=1)

// Background signals
bgcolor(is_panic ? color.new(color.lime, 90) : is_greed ? color.new(#c200e4, 90) : na)
````
