# Aurora Trend Channels [Pineify]

- url: https://www.tradingview.com/script/SqDaLEuE-Aurora-Trend-Channels-Pineify/
- type: indicator
- pine_id: PUB;b9d5f901efa84756b1b2c535c606998e
- version: 1.0

## Description

[b]Aurora Trend Channels[/b]

A volatility-adjusted trend channel built around a [i]Volume-Weighted Moving Average[/i] (VWMA) center and [i]Average True Range[/i] (ATR) outer bands. Unlike standard Bollinger Bands — which expand with statistical price deviation — the outer bands here track true-range volatility, including gap moves, and the center responds to volume weight rather than giving every candle equal influence. The channel shifts color with trend direction, and breakout signals fire only when price exits the outer ATR envelope, filtering out the weak cross-center noise that produces most false signals in simpler systems.

[b]Key Features[/b]

[list]
[*]VWMA center line: high-volume candles steer the trend reference more than low-volume ones, aligning the basis with where real trading activity occurred

[*]ATR-scaled bands: channel width expands during volatile sessions and contracts during quiet ones — the envelope automatically adapts to current market conditions

[*]EMA post-smoothing: a second smoothing pass over the raw VWMA and ATR values removes single-bar spikes without adding significant lag, producing cleaner channel edges

[*]Dynamic color coding: the entire channel flips between bullish green and bearish red in real time, giving an instant visual read on the current trend state

[*]Split-zone fills: the upper half of the channel is shaded bullish, the lower half bearish, so you can immediately see where price sits within the structure

[*]Outer-band breakout signals: BUY and SELL labels appear only when price crosses outside the ATR bands — a higher bar than a simple basis crossover

[*]Alert conditions for both breakout directions, compatible with TradingView's built-in alert system
[/list]

[b]How It Works[/b]

The calculation runs in two stages: building the channel, then smoothing it.

[list=1]
[*][b]VWMA basis:[/b] Each bar's close is weighted by its volume over the [i]Channel Length[/i] lookback. High-volume candles pull the moving average toward the prices at which the most trading happened — a demand-weighted trend reference rather than a simple time average.

[*][b]ATR envelope:[/b] The [i]Average True Range[/i] over the same lookback is multiplied by the [i]Band Multiplier[/i] and added/subtracted from the VWMA. ATR accounts for gap moves that high-low range ignores, so the bands genuinely reflect the full volatility environment.

[*][b]EMA smoothing:[/b] Both the raw VWMA and the raw band values are passed through an EMA of length [i]Smoothing Factor[/i]. This second pass removes the jagged edges that appear when a single high-volatility bar distorts the ATR calculation, without requiring a longer primary lookback.

[*][b]Trend coloring:[/b] A simple price-versus-basis comparison determines channel color on each bar. The VWMA already embeds volume context, so a bare close comparison is sufficient — no additional filter is needed.

[*][b]Signal conditions:[/b] Buy signals trigger on [i]crossover[/i] (close crosses above the upper band), sell signals on [i]crossunder[/i] (close crosses below the lower band). Crossing the outer ATR band means price moved beyond the typical volatility range, not merely through the center — it takes more momentum to get there.
[/list]

[b]How the Components Work Together[/b]

The core design choice here is pairing a volume-sensitive center with a volatility-sensitive envelope. Either alone has a weakness: a VWMA reacts to where volume traded but does not adapt its width to current market conditions; ATR bands sized around a simple SMA treat every candle's price equally regardless of liquidity. Combining them gives a channel that is anchored to real trading activity on the vertical axis and calibrated to actual volatility on the horizontal axis.

The EMA smoothing layer serves a specific function that would be lost with a single longer lookback. A longer primary window reduces noise but also makes the channel slower to respond to trend changes. Post-smoothing via a short EMA removes the erratic single-bar edges while keeping the primary length aggressive enough to track trends in real time. The result is a channel that reacts quickly but does not telegraph every spike.

Because signals require a full close outside the outer band rather than a touch or intrabar breach, they are naturally scarce. On a daily chart using default settings, expect a few signals per month rather than a few per week — which means each one carries more weight but also that the indicator is not designed for high-frequency entries.

[b]Trading Ideas and Insights[/b]

[list]
[*]Use the buy signal as an initial breakout entry trigger, then use retests of the upper band as add-on levels on the assumption the band becomes dynamic support after a breakout. A failure to hold the band after retest may indicate the move is exhausting.

[*]The channel fill colors work well as a trend filter for a separate entry system. If the channel is red, consider suppressing buy signals from another indicator until the channel flips green — a simple but effective regime filter.

[*]On higher timeframes (daily, weekly), the VWMA center often acts as a mean-reversion target after extended moves. Price that runs far from the basis and then loses momentum may retrace toward it; this is not directly signaled, but visually obvious on the chart.

[*]In ranging markets, price will oscillate between the bands without triggering outer-band breakouts. This is by design — the indicator is quiet in ranges and active in trending environments. If you see frequent small candles touching but not closing outside the bands, that is the market telling you conditions are not favorable for breakout trades.
[/list]

Past patterns do not guarantee future results. All signals should be evaluated within the context of the broader market structure and combined with appropriate risk management.

[b]Unique Aspects[/b]

[list]
[*]VWMA as the trend center, not SMA or EMA — the volume weighting means the channel is anchored where liquidity was concentrated, not just where time passed

[*]ATR bands instead of standard-deviation bands: the outer envelope reflects the full range including gaps, making it more robust on instruments with frequent overnight moves or news-driven spikes

[*]Two-stage smoothing design: the primary length drives responsiveness, the post-smooth EMA removes erratic band edges — decoupling these two concerns rather than collapsing them into a single longer period

[*]Breakout signals on outer band crosses only — no signals on basis crossovers, which substantially reduces noise on trending instruments

[*]Split fill that shades upper and lower zones in separate colors, giving an intuitive sense of channel structure without relying solely on the band lines
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to any chart. It works on all timeframes and instruments, though it was designed primarily for trending markets on the daily and 4-hour charts.

[*]Observe the channel color. Green indicates price is above the VWMA (bullish); red indicates below (bearish). Use this as a broad market context filter.

[*]Watch for BUY labels (triangle below bar) when price closes above the upper band, and SELL labels (triangle above bar) when price closes below the lower band. These indicate breakouts beyond the typical ATR volatility range.

[*]After a breakout signal, watch whether price holds the outer band on any pullback. A clean retest and bounce can serve as a secondary entry point.

[*]To set alerts: right-click the indicator → Add Alert → select "Aurora Buy Alert" or "Aurora Sell Alert".
[/list]

[b]Customization[/b]

[list]
[*][b]Channel Length[/b] (default: 20) — Controls both the VWMA lookback and the ATR period. Lower values (10–14) produce a fast, reactive channel suitable for intraday charts. Higher values (30–50) create a more stable channel that filters out shorter swing noise, better suited to daily or weekly context.

[*][b]Band Multiplier[/b] (default: 2.0) — Scales the ATR to set band width. At 2.0 on most instruments, outer band crosses are relatively uncommon — perhaps a few per month on a daily chart. Reducing to 1.5 produces more frequent signals; increasing to 2.5 or 3.0 reserves signals for only the most decisive momentum moves.

[*][b]Smoothing Factor[/b] (default: 4) — The EMA period applied after the primary calculation. Values of 1–3 produce crisper but more jagged band edges; values of 5–8 create visually cleaner bands with slightly more lag at band turns. Most users will not need to change this.

[*][b]Bullish/Bearish/Basis colors[/b] — Adjust to match your chart theme or personal preference without affecting calculation.
[/list]

[b]Conclusion[/b]

Aurora Trend Channels targets the specific problem of defining when a price move is large enough to matter — not just trending, but trending beyond the normal noise range. The VWMA-plus-ATR construction ties the channel to both volume activity and realized volatility, giving it more market context than either component alone. It works best as part of a broader system: the channel for trend direction and breakout signals, combined with a secondary tool for entry timing and position sizing within the trend.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// © Custom Creation

//
// Aurora Trend Channels [Pineify]
// --------------------------------
// Uses a Volume-Weighted Moving Average (VWMA) as the trend center, combined with
// ATR-scaled outer bands to define a volatility-adjusted channel around price.
// The channel color flips with trend direction, and breakout signals fire when
// price crosses outside the ATR bands — the point where momentum is strong enough
// to push beyond typical volatility range.
//
// Channel states:
//   1. Bullish — price is above the VWMA basis; upper/lower bands colored green
//   2. Bearish — price is below the VWMA basis; bands colored red
//   3. Breakout — price crosses outside an outer band, triggering a signal label
//

//@version=6
indicator("Aurora Trend Channels [Pineify]", overlay=true, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
grp_main  = "Channel Settings"
grp_style = "Aesthetics & Colors"

length = input.int(20, "Channel Length", minval=1, group=grp_main,
     tooltip="Lookback period for the VWMA trend center and ATR volatility calculation. Higher values create a slower, more stable channel; lower values respond faster but can produce more noise.")
mult   = input.float(2.0, "Band Multiplier", minval=0.1, step=0.1, group=grp_main,
     tooltip="Scales the ATR to set outer band distance. 2.0 captures roughly one standard ATR cycle; increase for wider bands that only trigger on exceptional moves.")
smooth = input.int(4, "Smoothing Factor", minval=1, group=grp_main,
     tooltip="EMA period applied to the raw VWMA and ATR bands. Reduces jagged band edges caused by single-bar volatility spikes. Higher values produce smoother, slightly lagging bands.")

bullColor  = input.color(#089981, "Bullish Trend",  group=grp_style)
bearColor  = input.color(#F23645, "Bearish Trend",  group=grp_style)
basisColor = input.color(#2962FF, "Center Basis",   group=grp_style)

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{

// VWMA weights each price by its bar's volume, so high-volume candles steer the
// center more than low-volume ones — more representative of where actual trading occurred
basis_raw = ta.vwma(close, length)

// ATR captures true range volatility including overnight gaps; multiplied to set
// a proportional envelope around the VWMA that expands in volatile regimes
atr = ta.atr(length) * mult

upper_raw = basis_raw + atr
lower_raw = basis_raw - atr

// EMA post-smoothing removes single-bar spikes from the raw band values,
// producing cleaner channel edges without introducing significant lag at typical settings
basis = ta.ema(basis_raw, smooth)
upper = ta.ema(upper_raw, smooth)
lower = ta.ema(lower_raw, smooth)

// Trend direction drives the channel color; a simple price-vs-basis comparison
// is intentional here — the VWMA already embeds volume context
int   trend        = close > basis ? 1 : -1
color channelColor = trend == 1 ? bullColor : bearColor

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
p_upper = plot(upper, "Upper Aurora Band", color=color.new(channelColor, 30), linewidth=2)
p_lower = plot(lower, "Lower Aurora Band", color=color.new(channelColor, 30), linewidth=2)
p_basis = plot(basis, "Center Basis",      color=basisColor, linewidth=2)

// Split fills — upper half tinted bullish, lower half tinted bearish — give an
// immediate visual read on which zone price occupies within the channel
fill(p_upper, p_basis, color.new(bullColor, 85), title="Bullish Zone")
fill(p_basis, p_lower, color.new(bearColor, 85), title="Bearish Zone")

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{

// Crossover/under of the outer ATR bands means price broke beyond the typical
// volatility range, not just through the trend center — a higher-conviction move
buy_signal  = ta.crossover(close, upper)
sell_signal = ta.crossunder(close, lower)

plotshape(buy_signal,  title="Buy Signal",  style=shape.triangleup,   location=location.belowbar, color=bullColor, size=size.small, text="BUY",  textcolor=color.white)
plotshape(sell_signal, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, text="SELL", textcolor=color.white)

alertcondition(buy_signal,  title="Aurora Buy Alert",  message="Bullish breakout detected on Aurora Channels!")
alertcondition(sell_signal, title="Aurora Sell Alert", message="Bearish breakout detected on Aurora Channels!")
````
