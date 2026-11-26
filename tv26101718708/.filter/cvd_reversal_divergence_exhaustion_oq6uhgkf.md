# CVD Reversal Divergence (Exhaustion)

- url: https://www.tradingview.com/script/oq6Uhgkf-CVD-Reversal-Divergence-Exhaustion/
- type: indicator
- pine_id: PUB;652f770d98f14cab932c3f2e25642726
- version: 2.0

## Description

[b]Overview[/b]
The CVD Reversal Divergence (Exhaustion) indicator is designed to identify potential market reversals by analyzing the divergence between price action and Cumulative Volume Delta (CVD).

[url=https://www.tradingview.com/x/9w8gF8fj/]https://www.tradingview.com/x/9w8gF8fj/[/url]

[b]Hypothesis[/b]
This indicator is built on the "Order Flow Exhaustion" hypothesis. In efficient markets, price trends should be supported by volume. When price hits a new high but CVD fails to follow (or vice versa), it indicates that the current momentum is exhausted, often signaling a pending reversal.

[b]Key Features[/b]
[list]
[*]Buying Exhaustion (Red Triangle): Signals a potential downward reversal when price structure diverges from buying pressure.
[*]
[*]Selling Exhaustion (Green Triangle): Signals a potential upward reversal when price structure diverges from selling pressure.
[*]
[*]Pivot-Based Detection: Uses structural pivot points to filter out intraday market noise, ensuring high-quality signals.
[/list]

[b]Understanding "Pivot Lookback (Bars)"[/b]
[list]
[*]The [i]Pivot Lookback[/i] parameter is the most critical setting for this indicator:
[*]
[*]What it does: It defines the number of bars required on each side of a pivot point to confirm it as a local high or low.
[*]
[*]How to tune it:
[*]Lower Values (e.g., 3-5): Increases sensitivity, allowing the indicator to detect smaller, localized reversals. Best for scalping.
[*]
[*]Higher Values (e.g., 10-20): Increases filtering, ignoring minor pullbacks and focusing on major structural shifts. Best for trend trading.
[/list]


[b]How to use[/b]
This indicator works best on liquid assets like Futures (ES, NQ, Gold) and high-volume stocks.

Use it as a confirmation tool rather than a standalone entry signal. Combine it with Support/Resistance levels or Volume Profile POCs for the best results.

## Source Code

````pine
//@version=6
// indicator("CVD Reversal Divergence (Exhaustion)", overlay=true, max_labels_count=500)

// // 1. Input parameters
// lookback = input.int(10, "Pivot Lookback (Bars)", minval=2)

// // 2. CVD calculation
// delta = volume * (close > open ? 1 : close < open ? -1 : 0)
// cvd = ta.cum(delta)

// // 3. Find price pivots
// ph = ta.pivothigh(high, lookback, lookback)
// pl = ta.pivotlow(low, lookback, lookback)

// // 4. Variables to track the previous pivot's values
// var float last_ph_price = na
// var float last_ph_cvd = na
// var float last_pl_price = na
// var float last_pl_cvd = na

// // 5. Buying Exhaustion logic (red downward triangle)
// if not na(ph)
//     // Check for Buying Exhaustion (divergence)
//     bool condition1 = (high[lookback] > last_ph_price) and (cvd[lookback] < last_ph_cvd)
//     bool condition2 = (high[lookback] < last_ph_price) and (cvd[lookback] > last_ph_cvd)
//
//     if condition1 or condition2
//         label.new(bar_index[lookback], high[lookback] + syminfo.mintick * 10, "▼", color=color.red, style=label.style_label_down, textcolor=color.white, size=size.small)
//
//     // Update the last pivot record
//     last_ph_price := high[lookback]
//     last_ph_cvd := cvd[lookback]

// // 6. Selling Exhaustion logic (green upward triangle)
// if not na(pl)
//     // Check for Selling Exhaustion (divergence)
//     bool condition3 = (low[lookback] < last_pl_price) and (cvd[lookback] > last_pl_cvd)
//     bool condition4 = (low[lookback] > last_pl_price) and (cvd[lookback] < last_pl_cvd)
//
//     if condition3 or condition4
//         label.new(bar_index[lookback], low[lookback] - syminfo.mintick * 10, "▲", color=color.green, style=label.style_label_up, textcolor=color.white, size=size.small)
//
//     // Update the last pivot record
//     last_pl_price := low[lookback]
//     last_pl_cvd := cvd[lookback]

//@version=6
indicator("CVD Reversal Divergence (Clean & Optimized)", overlay=true)

// ============================================================
// v0.0.2 — Upgraded to Pine Script v6
// Key migration notes:
//   * In v6, booleans can no longer hold `na`, and comparisons
//     involving `na` evaluate to `false` instead of `na`.
//     Explicit `not na(...)` guards were added so the divergence
//     logic is unambiguous and future-proof.
//   * `and` / `or` are lazily evaluated in v6, so the guard
//     pattern `not na(x) and (x > y)` is also slightly faster.
// ============================================================

// 1. Input parameters
lookback = input.int(10, "Pivot Confirmation Period (Lookback)", minval=2)

// --- Pre-alert optimization switches ---
grp_alerts = "Pre-Alert Noise Reduction Filters"
showPreAlert = input.bool(true, "Show Potential Reversal Pre-Alerts (faint X marks)", group=grp_alerts)
usePAFilter = input.bool(true, "Filter 1: Require candle reversal character (bearish close at highs / bullish close at lows)", group=grp_alerts, tooltip="When enabled, a strong bullish candle making a new high will NOT trigger an alert; only candles that meet resistance and close bearish will")
useEarlyDivFilter = input.bool(true, "Filter 2: Require 'early divergence' character", group=grp_alerts, tooltip="When enabled, a pre-alert only fires when the current CVD is weaker than the CVD at the previous historical high, greatly reducing false signals in one-sided trends")

// 2. CVD calculation
delta = volume * (close > open ? 1 : close < open ? -1 : 0)
cvd = ta.cum(delta)

// 3. Find confirmed pivots (the real pivots)
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

// 4. Variables to track the previous pivot's price and CVD data
var float last_ph_price = na
var float last_ph_cvd = na
var float last_pl_price = na
var float last_pl_cvd = na

// ==========================================
// 5. Pre-alert logic: detect high-quality potential pivots
// ==========================================
// Raw base logic: making a new local high / low
isPotentialPH_raw = high == ta.highest(high, lookback + 1)
isPotentialPL_raw = low == ta.lowest(low, lookback + 1)

// Filter 1: Candle reversal character (Price Action)
// A top pre-alert requires a bearish close (close < open); a bottom pre-alert requires a bullish close (close > open)
pa_PH_Condition = not usePAFilter or (close < open)
pa_PL_Condition = not usePAFilter or (close > open)

// Filter 2: Early divergence character
// Top pre-alert: price is making a new high AND the current CVD is below the CVD at the previous historical high (buying exhaustion)
earlyBearDiv = not useEarlyDivFilter or na(last_ph_cvd) or (cvd < last_ph_cvd)
// Bottom pre-alert: price is making a new low AND the current CVD is above the CVD at the previous historical low (selling exhaustion)
earlyBullDiv = not useEarlyDivFilter or na(last_pl_cvd) or (cvd > last_pl_cvd)

// Combined pre-alert conditions
isPotentialPH = isPotentialPH_raw and pa_PH_Condition and earlyBearDiv
isPotentialPL = isPotentialPL_raw and pa_PL_Condition and earlyBullDiv

// [Pre-alert plotting]
plotshape(showPreAlert and isPotentialPH, "Potential High", shape.xcross, location.abovebar, color.new(color.red, 70), size=size.tiny)
plotshape(showPreAlert and isPotentialPL, "Potential Low", shape.xcross, location.belowbar, color.new(color.green, 70), size=size.tiny)

// ==========================================
// 6. Confirmed divergence logic (final confirmation)
// ==========================================
bool isBearExhaustion = false
bool isBullExhaustion = false

if not na(ph)
    // Check for bearish divergence
    // v6 note: explicit na guards — on the very first pivot there is no
    // previous record to compare against, so no signal can fire.
    bool hasPrevPH = not na(last_ph_price) and not na(last_ph_cvd)
    bool condition1 = hasPrevPH and (high[lookback] > last_ph_price) and (cvd[lookback] < last_ph_cvd)
    bool condition2 = hasPrevPH and (high[lookback] < last_ph_price) and (cvd[lookback] > last_ph_cvd)

    if condition1 or condition2
        isBearExhaustion := true

    // Update the last pivot record
    last_ph_price := high[lookback]
    last_ph_cvd := cvd[lookback]

if not na(pl)
    // Check for bullish divergence
    bool hasPrevPL = not na(last_pl_price) and not na(last_pl_cvd)
    bool condition3 = hasPrevPL and (low[lookback] < last_pl_price) and (cvd[lookback] > last_pl_cvd)
    bool condition4 = hasPrevPL and (low[lookback] > last_pl_price) and (cvd[lookback] < last_pl_cvd)

    if condition3 or condition4
        isBullExhaustion := true

    // Update the last pivot record
    last_pl_price := low[lookback]
    last_pl_cvd := cvd[lookback]

// 7. [Core plotting]: clean confirmed signals (use offset to draw on the actual extreme bar)
plotshape(isBullExhaustion, "Bull Div", shape.triangleup, location.belowbar, color.green, size=size.small, offset=-lookback)
plotshape(isBearExhaustion, "Bear Div", shape.triangledown, location.abovebar, color.red, size=size.small, offset=-lookback)
````
