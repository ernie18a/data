# Aurora Expanded Trend Cloud [Pineify]

- url: https://www.tradingview.com/script/yQIY659c-Aurora-Expanded-Trend-Cloud-Pineify/
- type: indicator
- pine_id: PUB;b548d2441a8b4450b15cae421c6e4514
- version: 1.0

## Description

[b]Aurora Expanded Trend Cloud[/b]

This indicator uses a [i]Donchian Channel[/i] breakout to define trend direction and then projects an asymmetric "cloud" zone above or below price — a visual region where the market is expected to find support (in uptrends) or resistance (in downtrends). What makes it different from a plain Donchian system is the one-directional trailing cloud boundary: once the floor starts rising (or the ceiling falling), it never reverses, creating a ratcheting effect that tightens as a trend matures without whipping back on normal pullbacks.

[b]Key Features[/b]

[list]
[*]Trend direction determined by Donchian Channel breakouts — clean, objective, no oscillator subjectivity

[*]Cloud width scales with the current channel width, so the zone automatically widens during high-volatility periods and compresses when price is ranging

[*]One-way trailing boundary: the cloud floor only moves up in bull trends; the cloud ceiling only moves down in bear trends — reducing false exits during healthy retracements

[*]Trend-start circles mark the exact bar where each breakout first confirmed, providing a clear visual reference for entry timing

[*]Trend state exposed in the Data Window for use in external scripts or Pine Strategy bridges
[/list]

[b]How It Works[/b]

The calculation pipeline has three stages:

[list=1]
[*][b]Channel Construction[/b] — Each bar, the indicator computes the N-bar [i]highest high[/i] (upper band) and [i]lowest low[/i] (lower band). The difference is the channel width, which serves as a volatility proxy.

[*][b]Expansion Offset[/b] — An expansion percentage (default 50 %) is applied to the channel width to derive an offset. For example, on a bar where the channel spans 10 points, a 50 % setting produces a 5-point offset. This offset is added to the lower band (bullish cloud floor) or subtracted from the upper band (bearish cloud ceiling).

[*][b]One-Directional Trail[/b] — Rather than placing the cloud boundary exactly at the shifted band each bar, the indicator uses [i]math.max[/i] (bullish) or [i]math.min[/i] (bearish) against the prior trail value. Once the floor is at level X, it will not drop below X even if the Donchian lower band temporarily dips — the level "locks in" and can only continue advancing. On a trend flip, the trail resets from the new band anchor.
[/list]

[b]How the Components Work Together[/b]

The Donchian breakout sets the trend but is inherently reactive — it waits for price to close beyond the N-bar extreme, so the first signal can be a bar or two late on fast moves. The cloud's one-way trail compensates for this by providing a persistent, non-retreating reference level throughout the trend. Because the floor never pulls back, it acts as a natural trailing stop zone: if price closes below the green cloud boundary, the bullish structure has likely deteriorated beyond normal noise. The two mechanisms are complementary — breakout for entry, one-directional trail for management.

The expansion percentage links cloud width to current volatility. On a stock moving 1 % a day in a tight channel, the cloud stays narrow. During a high-momentum phase where the channel widens, the cloud expands proportionally, giving the trade more room to breathe. This avoids one of the common frustrations with fixed-offset trailing stops: premature exits during volatile but sustained trends.

[b]Trading Ideas and Insights[/b]

[list]
[*]When a green circle appears and the cloud floor begins to form below price, it may signal an early-stage uptrend. Consider entries on the first close above the upper band with the cloud floor as an initial stop reference.

[*]As a trend matures, the cloud floor rises and tightens. A close back into the cloud zone — especially with a wick that tags the floor — may indicate a pause rather than a reversal. A close below the cloud often warrants reassessment.

[*]Compression of the Donchian Channel ahead of a circle signal (upper and lower bands converging) can suggest accumulated energy before a breakout. These setups may produce cleaner follow-through than breakouts from already-wide channels.

[*]On higher timeframes the cloud acts as a broad trend filter. If price is above the green cloud on the daily, consider filtering intraday long setups only from that direction.
[/list]

Past behavior does not guarantee future results. The indicator has no predictive capability — it identifies conditions based on historical price structure. Always combine with independent confirmation and proper risk management.

[b]Limitations to Be Aware Of[/b]

[list]
[*]The Donchian breakout condition requires a close beyond the N-bar extreme. On fast-moving bars, the entry signal appears one bar after the actual breakout, which can result in a worse fill price.

[*]The one-way trail means the cloud boundary never retreats during a trend, but it also means it can diverge significantly from current price during extended moves. In those situations, the cloud is no longer a tight stop reference — it reflects the starting anchor of the trend, not current structure.

[*]In choppy, range-bound conditions, the indicator will produce frequent trend flips (circles in rapid alternation). No trend-following tool performs well in this regime; watch the channel width as a rough proxy for regime type.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to any chart and timeframe. It works on overlay mode, drawing directly on price.

[*]A green cloud below price confirms a bullish trend. A red cloud above price confirms a bearish trend. The solid-colored boundary line is the active trailing level.

[*]Colored circles mark trend start bars. Green below price = trend flipped bullish. Red above price = trend flipped bearish.

[*]Use the Trend Length input to adjust sensitivity. Shorter values (10–15) react faster and suit shorter timeframes or momentum styles. Longer values (30–50) filter more noise and suit swing or position trading.

[*]Adjust the Expansion % to control how far the cloud boundary sits from the Donchian band. Higher values give more room and widen the cloud; lower values keep the trail tight to price.
[/list]

[b]Customization[/b]

[list]
[*][b]Trend Length[/b] (default: 20) — Lookback window for the Donchian Channel. Larger values require a more sustained breakout to flip the trend and produce fewer, higher-conviction signals. Smaller values increase responsiveness at the cost of more noise.

[*][b]Expansion %[/b] (default: 50) — How wide the cloud is expressed as a fraction of the channel width. At 100 %, the cloud spans the full channel. At 0 %, the cloud collapses to a line at the channel boundary. Values between 30 %–70 % work well for most setups.
[/list]

[b]Conclusion[/b]

Aurora Expanded Trend Cloud combines a Donchian breakout system with a volatility-adaptive, one-directional trailing zone to give both a clear trend signal and a persistent visual reference level throughout the move. It is best suited for traders who want an objective, rule-based trend overlay without manual line-drawing — particularly on trending assets and timeframes where Donchian systems historically perform best.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AuroraIndicators

//@version=6
indicator("Aurora Expanded Trend Cloud [Pineify]", overlay = true, max_lines_count = 500)

//---------------------------------------------------------------------------------------------------------------------
// CONSTANTS & INPUTS
//---------------------------------------------------------------------------------------------------------------------

// Color constants for bullish and bearish trends
GREEN = #089981
RED   = #F23645

// User inputs for customization
lengthInput    = input.int(20, "Trend Length", minval = 5, tooltip = "Length for trend detection")
expansionInput = input.float(50, "Expansion %", minval = 0, maxval = 100, tooltip = "Percentage of price expansion for cloud formation")

//---------------------------------------------------------------------------------------------------------------------
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------

// Calculate Donchian Channel upper and lower bounds
upper = ta.highest(high, lengthInput)
lower = ta.lowest(low, lengthInput)

// Calculate the expansion offset based on channel width
float channelWidth = upper - lower
float expansionOffset = channelWidth * (expansionInput / 100)

// Persistent variables to track trend direction and trailing cloud levels
var int trend = 1  // Initialize as bullish
var float trailUp = na
var float trailDn = na

// Detect trend direction based on price action
// Bullish: close breaks above the upper band
// Bearish: close breaks below the lower band
bool newBull = close > upper
bool newBear = close < lower

// Trend state changes
bool wasBullish = trend[1] == 1
bool wasBearish = trend[1] == -1
bool switchedToBull = trend == 1 and not wasBullish
bool switchedToBear = trend == -1 and not wasBearish

// Update trend after detection
if newBull
    trend := 1
else if newBear
    trend := -1

// Cloud Expansion Logic: Calculate trailing cloud boundaries
// When trend is bullish, trailUp follows expanded lower band (only moves up)
if trend == 1
    if switchedToBull or trend[1] != 1
        // First bar of bullish trend - initialize trailUp at expanded lower band
        trailUp := lower + expansionOffset
        trailDn := na
    else
        // Continuing bullish - trailUp follows expanded lower band, only moves up
        trailUp := math.max(nz(trailUp, lower + expansionOffset), lower + expansionOffset)

// When trend is bearish, trailDn follows expanded upper band (only moves down)
if trend == -1
    if switchedToBear or trend[1] != -1
        // First bar of bearish trend - initialize trailDn at expanded upper band
        trailDn := upper - expansionOffset
        trailUp := na
    else
        // Continuing bearish - trailDn follows expanded upper band, only moves down
        trailDn := math.min(nz(trailDn, upper - expansionOffset), upper - expansionOffset)

//---------------------------------------------------------------------------------------------------------------------
// VISUALS & PLOTS
//---------------------------------------------------------------------------------------------------------------------

// Plot upper and lower channel lines for bullish trend
plot_upper   = plot(trend == 1 ? upper : na, "Bullish Upper", color = color.new(GREEN, 100))
plot_trailUp = plot(trend == 1 and not na(trailUp) ? trailUp : na, "Bullish Lower", color = color.new(GREEN, 0), linewidth = 2)

// Plot upper and lower channel lines for bearish trend
plot_lower   = plot(trend == -1 ? lower : na, "Bearish Lower", color = color.new(RED, 100))
plot_trailDn = plot(trend == -1 and not na(trailDn) ? trailDn : na, "Bearish Upper", color = color.new(RED, 0), linewidth = 2)

// Trend Change Detection: Identify when a new trend begins
startBull = trend == 1 and trend[1] != 1
startBear = trend == -1 and trend[1] != -1

// Plot trend start dots for visual entry signals
plotshape(startBull, "Bullish Start", shape.circle, location.belowbar, GREEN, size = size.large)
plotshape(startBear, "Bearish Start", shape.circle, location.abovebar, RED, size = size.large)

// Fill cloud areas with translucent colors for visual distinction
fill(plot_upper, plot_trailUp, color.new(GREEN, 85), title = "Bullish Cloud")
fill(plot_lower, plot_trailDn, color.new(RED, 85), title = "Bearish Cloud")

// Plot trend value for debugging (use Data Window to view)
plot(trend, "Trend", color = color.white, display = display.data_window)
````
