# Luminous Mean Reversion Channels [Pineify]

- url: https://www.tradingview.com/script/37ufcFK9-Luminous-Mean-Reversion-Channels-Pineify/
- type: indicator
- pine_id: PUB;dd0132a2a9fc4578b05e2dadc28c1e63
- version: 1.0

## Description

[b]Luminous Mean Reversion Channels [Pineify][/b]

Luminous Mean Reversion Channels is a volatility-adaptive mean reversion overlay built around an ATR-stepped central level. Rather than following every candle like a moving average, the center line only recalibrates after price moves far enough to clear a volatility threshold. The upper and lower bands then mark stretched areas where price may begin rotating back toward the mean.

[b]Key Features[/b]

[list]
[*]ATR-based range logic that adapts to changing volatility

[*]Stepped mean reversion level that filters small price noise

[*]Upper overbought band and lower oversold band with soft visual fills

[*]BUY and SELL labels when price crosses back through an outer band

[*]Alert conditions for bullish and bearish mean reversion events
[/list]

[b]How It Works[/b]

The script measures [i]Average True Range[/i] over the selected Volatility Length, then multiplies it by the Channel Width Factor. This creates the displacement threshold.

If the source price rises more than that threshold above the current center line, the center line steps upward by one threshold. If price falls more than that threshold below the current center line, it steps downward. If price stays inside the threshold, the center line does not move.

When the center line changes, the script stores half of the active threshold as the channel width. The overbought band is plotted above the center line, and the oversold band is plotted below it. A BUY label appears when price crosses upward through the lower band. A SELL label appears when price crosses downward through the upper band.

[b]How the Components Work Together[/b]

ATR defines how large a move must be before the range is considered meaningful. The stepped center line defines the current mean reversion reference. The band-crossing logic then looks for price moving back inside a stretched area. This combination helps separate ordinary candle noise from larger volatility-adjusted displacement.

[b]Trading Ideas and Insights[/b]

[list]
[*]A BUY label near the lower band may indicate that downside extension is starting to mean revert

[*]A SELL label near the upper band may indicate that upside extension is starting to cool

[*]Repeated center-line steps in one direction suggest trend pressure; countertrend signals may need stronger confirmation

[*]Sideways rotation between the two bands can be useful context for range-trading analysis
[/list]

Signals are context markers, not guaranteed entries. Trend, structure, liquidity, and higher-timeframe conditions should still guide risk decisions.

[b]Unique Aspects[/b]

[list]
[*]This is not a standard Bollinger Band, Keltner Channel, or fixed moving average envelope. The central value moves in discrete ATR-based steps instead of updating on every bar

[*]The active band width is captured when the mean level recalibrates, tying the channel to the volatility regime that caused the shift

[*]The visual output focuses on two practical reversal zones rather than a dense stack of intermediate levels
[/list]

[b]How to Use[/b]

[list=1]
[*]Apply the indicator to a clean chart and choose the source price

[*]Use the gray center line as the current mean reversion reference

[*]Watch the red upper band for stretched upside conditions and the green lower band for stretched downside conditions

[*]Use BUY and SELL labels as prompts for further confirmation, not as standalone trade instructions

[*]Create alerts from the bullish or bearish mean reversion conditions if you want notifications
[/list]

[b]Customization[/b]

[list]
[*][b]Volatility Length[/b] (default: 200) - ATR lookback. Higher values smooth the channel; lower values react faster

[*][b]Channel Width Factor[/b] (default: 6.0) - ATR multiplier. Higher values create wider bands and fewer signals

[*][b]Source[/b] - Price series used for the channel and signal crosses
[/list]

[b]Open-Source Reference and Limitations[/b]

This script uses the public volatility-stepped range concept associated with Predictive Ranges as a foundation, then presents it as a simplified two-band mean reversion channel with Pineify styling, focused labels, and alerts. Mean reversion labels can appear early during strong trends, and past chart examples do not guarantee future results. Avoid using BUY/SELL signals on non-standard chart types when evaluating realistic trading behavior.

[b]Conclusion[/b]

Luminous Mean Reversion Channels is designed for traders who want a clean, volatility-aware view of price extension. Its main value is showing when price is stretched relative to an ATR-stepped mean and when it begins crossing back toward the active range.

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
// Luminous Mean Reversion Channels
// ---------------------------------
// A volatility-stepped mean reversion overlay inspired by Predictive
// Ranges. The center line only moves when price has displaced by a full
// ATR-based threshold, so small fluctuations are ignored while larger
// range shifts recalibrate the channel.
//
// Three practical states are highlighted:
//   1. Upper stretch  — price is near or crossing back from the overbought band
//   2. Mean zone      — price is rotating around the stepped central level
//   3. Lower stretch  — price is near or crossing back from the oversold band

//@version=6
indicator("Luminous Mean Reversion Channels [Pineify]", shorttitle="Luminous MRC [Pineify]", overlay=true)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{

grp_channel = "Channel Settings"
length = input.int(200, "Volatility Length", minval=2, group=grp_channel, tooltip="ATR lookback used to size the displacement threshold. Higher values smooth the channel response; lower values react faster.")
mult = input.float(6.0, "Channel Width Factor", minval=0, step=0.5, group=grp_channel, tooltip="ATR multiplier that controls how far price must move before the mean level recalibrates. Higher values create wider channels and fewer signals.")
src = input.source(close, "Source", group=grp_channel, tooltip="Price series used for the stepped mean calculation and band-crossing signals.")

//---------------------------------------------------------------------------------------------------------------------}
// CORE LOGIC: VOLATILITY-STEPPED MEAN REVERSION CHANNEL
//---------------------------------------------------------------------------------------------------------------------{

var float avg_line = src
var float hold_atr = 0.0

// The ATR threshold defines what counts as a meaningful displacement.
// Small moves inside this threshold leave the central level unchanged.
atr_val = nz(ta.atr(length)) * mult

// [Source: Predictive Ranges concept]
// The central level advances in fixed volatility steps instead of tracking
// every candle. This makes the range less reactive to ordinary market noise.
avg_line := src - avg_line > atr_val ? avg_line + atr_val : avg_line - src > atr_val ? avg_line - atr_val : avg_line

// Capture the active width only when the center line changes. This keeps the
// displayed channel tied to the volatility regime that caused the recalibration.
hold_atr := avg_line != avg_line[1] ? atr_val / 2 : hold_atr

upper_band = avg_line + hold_atr * 2
lower_band = avg_line - hold_atr * 2

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{

up_plot = plot(upper_band, color=color.new(#f23645, 0), title="Overbought Band", linewidth=2)
mid_plot = plot(avg_line, color=color.new(#787b86, 50), title="Mean Reversion Level", style=plot.style_line, linewidth=1)
dn_plot = plot(lower_band, color=color.new(#089981, 0), title="Oversold Band", linewidth=2)

// Fills emphasize where price is stretched relative to the stepped mean:
// red above the center for upside extension, green below for downside extension.
fill(up_plot, mid_plot, top_color=color.new(#f23645, 85), bottom_color=color.new(#f23645, 100), title="Bearish Reversal Aura")
fill(dn_plot, mid_plot, top_color=color.new(#089981, 100), bottom_color=color.new(#089981, 85), title="Bullish Reversal Aura")

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{

// Reversal labels fire when price crosses back through an outer band. The
// condition looks for re-entry from an extended area, not a trend-following break.
buy_signal = ta.crossover(src, lower_band)
sell_signal = ta.crossunder(src, upper_band)

plotshape(buy_signal, title="Buy Signal", style=shape.labelup, location=location.belowbar, color=color.new(#089981, 0), text="BUY", textcolor=color.white, size=size.small)
plotshape(sell_signal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.new(#f23645, 0), text="SELL", textcolor=color.white, size=size.small)

alertcondition(buy_signal, title="Bullish Mean Reversion", message="Price crossed back above the lower mean reversion band.")
alertcondition(sell_signal, title="Bearish Mean Reversion", message="Price crossed back below the upper mean reversion band.")
````
