# Lumina Trend Channels & Bands [Pineify]

- url: https://www.tradingview.com/script/sw5a20Fo-Lumina-Trend-Channels-Bands-Pineify/
- type: indicator
- pine_id: PUB;46f526f479434817bc3317f55065ee36
- version: 1.0

## Description

[b]Pineify - Lumina Trend Channels & Bands[/b]

Lumina Trend Channels & Bands is an overlay indicator that builds a volatility-adjusted trend channel around a [i]Volume-Weighted Moving Average[/i] (VWMA). VWMA forms the baseline, while ATR bands define how far price must move before trend state changes.

[b]Key Features[/b]

[list]
[*]VWMA midpoint weighted toward higher-volume closes.

[*]ATR-based upper and lower bands that adapt to current range.

[*]Persistent trend state while price remains inside the channel.

[*]Triangle markers on the first cross above the upper band or below the lower band.
[/list]

[b]How It Works[/b]

The script calculates a VWMA of close, then adds and subtracts ATR multiplied by the Band Multiplier. A close above the upper band sets bullish state; a close below the lower band sets bearish state. Between the bands, the prior state is preserved.

[list=1]
[*]Compute the VWMA baseline.

[*]Measure ATR and scale it by the Band Multiplier.

[*]Plot upper and lower channel bands around the VWMA, then mark the first crossover or crossunder.
[/list]

[b]How the Components Work Together[/b]

VWMA supplies the directional anchor, while ATR decides how much evidence price needs before a breakout is treated as meaningful. In high volatility the bands widen and demand a stronger close; in quiet conditions the channel tightens and reacts sooner. The cloud fill emphasizes the active side of the trend.

[b]Trading Ideas and Insights[/b]

[list]
[*]A bullish triangle may indicate continuation after price clears the upper boundary.

[*]A bearish triangle may flag downside momentum when price loses the lower band.

[*]Inside-channel movement is a drift zone. Wait for bar close on live bars; fast reversals can lag, and ranges can whipsaw.
[/list]

[b]Unique Aspects[/b]

[list]
[*]Trend state is retained inside the ATR channel, reducing flip-flopping around the VWMA.

[*]The asymmetric cloud emphasizes the active trend side while keeping the opposite band visible.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to a clean price chart.

[*]Use the midline and channel to judge bullish, bearish, or undecided territory.

[*]Treat triangles as potential breakout starts, then look for confirmation.

[*]No built-in alert conditions are included in this version.
[/list]

[b]Customization[/b]

[list]
[*][b]Trend Baseline Length[/b] (default: 50) - VWMA lookback. Higher values smooth the channel but add lag.

[*][b]Volatility (ATR) Length[/b] (default: 14) - ATR lookback for band width.

[*][b]Band Multiplier[/b] (default: 2.0) - Channel distance. Higher values reduce breakouts; lower values are more sensitive.

[*][b]Bullish/Bearish Trend Colors[/b] - Adjust line, cloud, and marker colors.
[/list]

[b]Conclusion[/b]

Lumina Trend Channels & Bands is for traders who want a clean VWMA trend channel with volatility-aware breakout markers. Use it as context alongside structure, volume, and risk management rather than as a standalone system.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//

//
// Lumina Trend Channels & Bands
// -----------------------------
// This overlay builds a VWMA-centered trend channel and expands it with ATR so the bands adapt
// to current volatility. Trend state flips only after price closes beyond the outer channel,
// which helps separate meaningful breakouts from ordinary movement around the baseline.
//
// Market states or key concepts:
//   1. Bullish channel break - price clears the upper volatility boundary.
//   2. Bearish channel break - price loses the lower volatility boundary.
//   3. Channel drift - price remains inside the bands and the prior trend state is preserved.
//
//@version=6
indicator("Lumina Trend Channels & Bands [Pineify]", overlay=true, max_lines_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
grp_channel = "Channel Settings"
grp_style   = "Aesthetics & Colors"

ma_len  = input.int(50, title="Trend Baseline Length", minval=1, group=grp_channel, tooltip="VWMA lookback used for the channel midpoint. Higher values create a slower trend baseline; lower values make the channel react faster.")
atr_len = input.int(14, title="Volatility (ATR) Length", minval=1, group=grp_channel, tooltip="ATR lookback used to size the upper and lower bands. Higher values smooth volatility changes; lower values respond faster to sudden range expansion.")
mult    = input.float(2.0, title="Band Multiplier", minval=0.1, step=0.1, group=grp_channel, tooltip="Distance between the VWMA baseline and each ATR band. Higher values require larger breakouts; lower values increase signal frequency and whipsaw risk.")

bull_col = input.color(#089981, title="Bullish Trend Color", group=grp_style, tooltip="Color used for bullish trend emphasis, including the midline, lower cloud, and bullish breakout marker.")
bear_col = input.color(#f23645, title="Bearish Trend Color", group=grp_style, tooltip="Color used for bearish trend emphasis, including the midline, upper cloud, and bearish breakout marker.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{
// VWMA gives heavier influence to higher-volume closes, so the channel midpoint follows price areas
// where participation was stronger instead of treating every bar equally.
base_ma = ta.vwma(close, ma_len)

// ATR converts recent range into a price-distance buffer. Multiplying it around the VWMA creates a
// volatility-adjusted channel that widens during expansion and tightens when conditions quiet down.
atr = ta.atr(atr_len)
upper_band = base_ma + (atr * mult)
lower_band = base_ma - (atr * mult)

// The trend state is intentionally persistent: inside the channel, the previous state remains active.
// Only a close beyond an outer band is strong enough to flip the visual bias.
var int trend = 1
trend := close > upper_band ? 1 : close < lower_band ? -1 : trend

// Cross events isolate the first bar that escapes the channel, avoiding repeated markers while price
// remains extended beyond the same boundary.
bull_break = ta.crossover(close, upper_band)
bear_break = ta.crossunder(close, lower_band)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
u_plot = plot(upper_band, color=trend == 1 ? color.new(bull_col, 50) : bear_col, title="Upper Band", linewidth=1)
l_plot = plot(lower_band, color=trend == 1 ? bull_col : color.new(bear_col, 50), title="Lower Band", linewidth=1)
m_plot = plot(base_ma, color=trend == 1 ? bull_col : bear_col, title="Midline", style=plot.style_line, linewidth=2)

// The dominant cloud appears on the side of the active trend. This keeps the chart focused on whether
// pullbacks are occurring above a bullish lower boundary or below a bearish upper boundary.
fill(u_plot, m_plot, color=trend == -1 ? color.new(bear_col, 80) : color.new(bull_col, 95), title="Upper Cloud")
fill(l_plot, m_plot, color=trend == 1 ? color.new(bull_col, 80) : color.new(bear_col, 95), title="Lower Cloud")

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
plotshape(bull_break, style=shape.triangleup, location=location.belowbar, color=bull_col, size=size.small, title="Bullish Breakout")
plotshape(bear_break, style=shape.triangledown, location=location.abovebar, color=bear_col, size=size.small, title="Bearish Breakout")
````
