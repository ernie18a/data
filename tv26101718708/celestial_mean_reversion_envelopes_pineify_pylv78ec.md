# Celestial Mean Reversion Envelopes [Pineify]

- url: https://www.tradingview.com/script/PylV78eC-Celestial-Mean-Reversion-Envelopes-Pineify/
- type: indicator
- pine_id: PUB;9e130e3e684a45a6b88770d4794bc50d
- version: 1.0

## Description

[b]Celestial Mean Reversion Envelopes[/b]

This indicator identifies mean reversion opportunities by wrapping an adaptive moving average in standard deviation envelopes and signaling when price snaps back inside after piercing a band. Rather than using a fixed-period moving average as the baseline, the central line adapts its speed based on how frequently price is setting new highest highs or lowest lows — it tracks price quickly in trending conditions and almost freezes in ranges, so the bands shift organically with market character.

[b]Key Features[/b]

[list]
[*]Adaptive mean that responds to trend intensity rather than time alone — sluggish during consolidation, responsive during strong moves

[*]Standard deviation envelopes calibrated to actual recent volatility, not fixed ATR multiples

[*]Buy and sell signals generated on band crossunders/crossovers, confirming the reversal rather than anticipating it

[*]Translucent overbought/oversold shading between the mean and each band for quick visual context

[*]Built-in alerts for both reversion directions
[/list]

[b]How It Works[/b]

The calculation runs in two stages: first building the adaptive mean, then constructing the envelopes around it.

[list=1]
[*][i]Extreme tracking[/i] — On each bar, the indicator checks whether a new highest high or lowest low has formed over the lookback window. Bars where a fresh extreme appears are marked with a value of 1; all other bars get 0. The SMA of these binary values over the same window gives the fraction of recent bars that produced a new extreme.

[*][i]Squaring the fraction[/i] — Raising that fraction to the power of 2 produces a nonlinear smoothing coefficient. When trends are strong and new extremes appear on most bars, the coefficient approaches 1 and the adaptive mean tracks price closely. In a choppy range where few new extremes form, the coefficient collapses near zero and the mean barely moves. This technique is inspired by TRAMA (Trend Regularity Adaptive Moving Average) by e2e4mfck.

[*][i]Adaptive mean update[/i] — Each bar the mean nudges toward the source price by the amount determined by the coefficient. The result is an average that effectively switches between "responsive" and "parked" behavior depending on what the market is doing.

[*][i]Standard deviation envelopes[/i] — The upper and lower bands are placed at ±(StdDev × multiplier) from the adaptive mean, where StdDev is computed over the same lookback period. This makes the band width proportional to recent volatility: wider when price has been swinging, tighter during quiet periods.

[*][i]Signal generation[/i] — A buy signal fires when source [i]crossesunder[/i] the lower band (price dipped below, then closed back above it). A sell signal fires on a [i]crossover[/i] of the upper band. The crossunder/crossover logic requires price to actually breach and then retrace — a bar that merely touches the band without closing through it does not trigger.
[/list]

[b]How the Components Work Together[/b]

The adaptive mean solves a problem that conventional envelope indicators ignore: when a market trends hard, a static EMA or SMA falls behind, making the upper band a poor reference for "too far, too fast." Because the adaptive mean accelerates during trends, the envelopes stay anchored to current price levels rather than lagging. This means the bands are more likely to represent genuine statistical extremes rather than just momentum riding.

The standard deviation layer adds a second dimension. Instead of a fixed pip or percentage offset, the band width expands when the market is volatile and contracts when it is calm — naturally suppressing signals during low-volatility compression and allowing wider moves during active sessions before flagging exhaustion.

Together these two layers create a filter that roughly says: "price reached a statistically unusual distance from where the trend currently sits, then pulled back." That combination reduces fakeout signals compared to using static bands on a lagging baseline.

[b]Trading Ideas and Insights[/b]

[list]
[*]On higher timeframes (daily, 4H), buy signals at the lower band that coincide with a key support level or volume spike may offer higher-confidence entries. Look for the adaptive mean to be flattening — it suggests the trend is pausing rather than reversing.

[*]In intraday trading, signals that appear after a sharp impulsive leg tend to perform better than signals generated inside a choppy range. The adaptive mean will often be steeply sloped after an impulse, indicating the signal is against the micro-trend — exercise more caution and use tighter risk.

[*]When price oscillates between the bands repeatedly without triggering signals, the market is likely in a low-volatility squeeze. A breakout attempt that immediately pulls back (triggering a sell or buy signal) at the edge of that range can mark the failed breakout early.

[*]The gradient fill zones serve as a running reference for where price stands relative to the mean. Price persistently in the upper (red) fill with a rising adaptive mean suggests a strong trend; consider fading only when price crosses back into the neutral zone.

Past performance of any signal pattern does not guarantee future results. Always combine signals with broader context — structure, volume, and higher-timeframe bias. These signals indicate potential exhaustion; they do not predict reversal magnitude.
[/list]

[b]Unique Aspects[/b]

[list]
[*]The squaring of the trend-regularity fraction is the core differentiator. Most adaptive averages use linear coefficients; squaring creates a much sharper distinction between trending and ranging states, so the mean spends more time "frozen" during ranges and snaps to price quickly when momentum genuinely kicks in.

[*]Signals require price to close back inside the band, not just touch it — this one-bar confirmation step reduces noise from wicks that briefly pierce a band and immediately reverse without a real close-to-close move.

[*]Band width is purely standard-deviation based rather than ATR-derived, which means the scaling responds to the actual statistical dispersion of the source series rather than the high-low range. On instruments with many gaps this can produce meaningfully different widths than ATR bands.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to any chart. It overlays directly on the price pane.

[*]The blue line is the adaptive mean. When it is rising steeply the market is in an upward trending mode; when flat or slightly sloped, it is ranging.

[*]The red-shaded zone above the mean is the overbought area; the green-shaded zone below is the oversold area. Price spending extended time in one zone suggests momentum, not necessarily exhaustion.

[*]A green [b]BUY[/b] label below a bar means price closed back above the lower band after briefly breaking it — potential reversion entry. A red [b]SELL[/b] label above a bar means the opposite.

[*]To set alerts, use the "Buy Alert" or "Sell Alert" conditions from the indicator's alert panel (Once Per Bar Close recommended to avoid premature triggers on intrabar wicks).
[/list]

[b]Customization[/b]

[list]
[*][b]Adaptive Mean Length[/b] (default: 99) — Controls both the highest/lowest lookback and the SMA averaging window for the smoothing coefficient. Higher values slow the mean considerably and widen bands; lower values increase reactivity but also produce more frequent and less reliable signals.

[*][b]Envelope Multiplier[/b] (default: 2.5) — Scales the standard deviation distance. 2.0 suits instruments with tighter typical ranges; raise to 3.0+ on highly volatile assets to avoid constant band touches that don't represent genuine extremes.

[*][b]Source[/b] (default: close) — Change to hl2 or hlc3 to incorporate high and low into the baseline; close is typically sufficient for most reversion setups.

[*][b]Color inputs[/b] — Adjust bullish/bearish/mean colors and toggle the gradient fill on or off depending on visual preference.
[/list]

[b]Conclusion[/b]

Celestial Mean Reversion Envelopes pairs an adaptive mean that adjusts its responsiveness to trend regularity with volatility-scaled deviation bands, targeting the specific moment when a stretched move closes back inside its statistical boundary. The approach is best suited to traders who wait for confirmation — the crossunder/crossover trigger ensures you're acting on a completed reversal bar, not an open wick. As with any mean-reversion tool, it works best when context confirms the extension is exhaustion rather than breakout continuation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//
// Celestial Mean Reversion Envelopes
// ------------------------------------
// Uses an adaptive moving average (inspired by TRAMA) as the central baseline,
// then wraps it in standard deviation envelopes to mark statistically stretched
// price zones. Signals fire when price crosses back inside the outer band —
// the crossunder/crossover acts as the "snap back" confirmation trigger.
//
// Adaptive mean states:
//   1. Trending — new highest highs or lowest lows appear; the AMA tracks price closely
//   2. Ranging  — no new extremes; smoothing factor drops near zero, AMA freezes
//   3. Signal   — price pierces the band and immediately reverses back inside
//

//@version=6
indicator("Celestial Mean Reversion Envelopes [Pineify]", overlay=true, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
grp_core  = "Core Settings"
grp_style = "Aesthetics & Colors"

length = input.int(99, "Adaptive Mean Length", minval=2, group=grp_core,
     tooltip="Lookback window for highest/lowest tracking and the SMA smoothing factor. Higher values make the mean slower and the envelopes wider; lower values increase sensitivity but introduce more whipsaw signals.")
mult = input.float(2.5, "Envelope Multiplier", minval=0.5, step=0.5, group=grp_core,
     tooltip="Scales the standard deviation band width. 2.0–2.5 captures most normal price swings; raise it on volatile instruments to reduce noise.")
src = input.source(close, "Source", group=grp_core,
     tooltip="Price field fed into the adaptive mean and standard deviation calculations.")

bullCss   = input.color(#089981, "Bullish Reversion (Buy)",  inline="css1", group=grp_style)
bearCss   = input.color(#f23645, "Bearish Reversion (Sell)", inline="css1", group=grp_style)
meanCss   = input.color(#2962ff, "Mean Baseline",            inline="css2", group=grp_style)
showFills = input.bool(true, "Show Gradient Fills",          inline="css2", group=grp_style,
     tooltip="Toggles the translucent overbought/oversold shading between the mean and each outer band.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{
// Track when a new highest high or lowest low is set.
// sign() + max() collapses each bar to 1 (new extreme) or 0 (no new extreme).
hh = math.max(math.sign(ta.change(ta.highest(length))), 0)
ll = math.max(math.sign(ta.change(ta.lowest(length)) * -1), 0)

// trendSignal is 1 on bars where price reaches a new extreme in either direction.
// SMA over `length` bars gives the fraction of recent bars with new extremes.
// Squaring creates a nonlinear response: the coefficient drops sharply in ranges
// and rises steeply during sustained trends — adapting mean responsiveness automatically.
// [Source: TRAMA by e2e4mfck]
trendSignal = math.max(hh, ll)
tc = math.pow(ta.sma(trendSignal, length), 2)

// Adaptive moving average: only moves when tc is high (trending market).
// In flat markets tc ≈ 0, so ama barely updates; it drifts toward price only
// when new price extremes are consistently being made.
var float ama = na
ama := nz(ama + tc * (src - nz(ama, src)), src)

// Standard deviation of source gives a statistically grounded band width.
// Multiplying by `mult` lets traders calibrate how far price must stretch
// before a reversion signal is considered meaningful.
dev   = ta.stdev(src, length) * mult
upper = ama + dev
lower = ama - dev

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
// Crossunder below the lower band: price broke through support but the close
// snapped back inside, suggesting the extension was rejected.
buySignal  = ta.crossunder(src, lower)

// Crossover above the upper band: price broke through resistance but
// pulled back inside, suggesting the breakout failed and sellers absorbed supply.
sellSignal = ta.crossover(src, upper)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
p_upper = plot(upper, "Upper Band",      color.new(bearCss, 30), 2)
p_mean  = plot(ama,   "Celestial Mean",  color.new(meanCss, 0),  2)
p_lower = plot(lower, "Lower Band",      color.new(bullCss, 30), 2)

fill(p_upper, p_mean, showFills ? color.new(bearCss, 85) : na, title="Overbought Area")
fill(p_mean, p_lower, showFills ? color.new(bullCss, 85) : na, title="Oversold Area")

plotshape(buySignal  ? low  : na, "Reversion Buy",  shape.labelup,   location.belowbar, color.new(bullCss, 0), 0, text="▲\nBUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal ? high : na, "Reversion Sell", shape.labeldown, location.abovebar, color.new(bearCss, 0), 0, text="SELL\n▼", textcolor=color.white, size=size.small)

alertcondition(buySignal,  "Buy Alert",  "Price stretched below the lower envelope. Potential Mean Reversion UP.")
alertcondition(sellSignal, "Sell Alert", "Price stretched above the upper envelope. Potential Mean Reversion DOWN.")
````
