# BB %B + BandWidth

- url: https://www.tradingview.com/script/6Jj7tYeg-BB-B-BandWidth/
- type: indicator
- pine_id: PUB;62146ff6d6cc486e937f3542dbfe0d5d
- version: 1.0

## Description

**1. First Look At The Cyan Line: %B**

`%B` shows where price is located within the Bollinger Bands:

- `100`: Price is near the upper Bollinger Band
- Above `80`: Strong zone, but may also be short-term overheated
- `50`: Price is near the middle band
- Below `20`: Weak zone, but may also be short-term oversold
- `0`: Price is near the lower Bollinger Band
- Above `100`: Price has broken above the upper band
- Below `0`: Price has broken below the lower band

In your chart, the current `%B` is around `99.59`, which means price is very close to the upper Bollinger Band. Short-term momentum is strong, but it is also close to an overheated zone.

**2. Then Look At The Orange/Red Line: BandWidth PercentRank**

`BandWidth` measures the width of the Bollinger Bands, which represents volatility.

The default mode is `PercentRank`:

- Below `20`: Low volatility, likely in a squeeze
- Crossing above `20`: Possible squeeze release, volatility may start expanding
- Around `50`: Normal volatility
- Above `80`: Volatility is already high, chasing entries becomes riskier

The red background means the market is in a squeeze zone, where the Bollinger Bands are narrow and price may be building energy.

**3. How To Read The Markers**

- Green upward triangle: `%B` breaks above the upper band, a strong bullish breakout signal
- Red downward triangle: `%B` breaks below the lower band, a strong bearish breakout signal
- Red dot near the top: `%B` crosses above `80`, entering a strong/overheated zone
- Green dot near the bottom: `%B` crosses below `20`, entering a weak/oversold zone
- Yellow diamond: BandWidth exits the squeeze, volatility starts expanding

**4. Practical Usage Sequence**

A more reliable way to use it:

1. First look for the red background, which means a squeeze.
2. Wait for the yellow diamond, which means volatility is starting to release.
3. Check the direction of `%B`:
   - `%B` crossing above `80` means the bullish side is stronger
   - `%B` crossing below `20` means the bearish side is stronger
4. If `%B` breaks above `100` or below `0`, it means price has broken outside the Bollinger Bands and momentum is stronger.

## Source Code

````pine
//@version=6
indicator("BB %B + BandWidth", shorttitle="BB%B+BW", overlay=false, precision=2)

// Inputs
src = input.source(close, "Source")
length = input.int(20, "BB Length", minval=1)
mult = input.float(2.0, "StdDev Multiplier", minval=0.1, step=0.1)

show_percent_b = input.bool(true, "Show %B", group="Display")
show_bandwidth = input.bool(true, "Show BandWidth", group="Display")
show_signals = input.bool(true, "Show Signals", group="Display")

upper_breakout_level = input.float(1.0, "Upper Breakout Level", minval=0.5, maxval=2.0, step=0.01, group="Signals")
lower_breakout_level = input.float(0.0, "Lower Breakout Level", minval=-1.0, maxval=0.5, step=0.01, group="Signals")

bw_mode = input.string("PercentRank", "BandWidth Mode", options=["PercentRank", "Raw %"], group="BandWidth")
bw_rank_length = input.int(100, "BandWidth PercentRank Length", minval=10, group="BandWidth")
squeeze_rank_level = input.float(20.0, "Squeeze Threshold (%Rank)", minval=0.0, maxval=100.0, step=1.0, group="BandWidth")

percent_b_color = input.color(color.aqua, "%B Color", group="Colors")
bandwidth_color = input.color(color.orange, "BandWidth Color", group="Colors")
squeeze_bw_color = input.color(color.red, "Squeeze BandWidth Color", group="Colors")
squeeze_bg_color = input.color(color.new(color.red, 88), "Squeeze Background", group="Colors")

// Bollinger Bands
basis = ta.sma(src, length)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev
bb_range = upper - lower

// %B, plotted as 0-100 for axis alignment
percent_b = bb_range != 0 ? (src - lower) / bb_range : na
percent_b_plot = percent_b * 100.0

// BandWidth
bandwidth_raw = basis != 0 ? (bb_range / math.abs(basis)) * 100.0 : na
bandwidth_rank = ta.percentrank(bandwidth_raw, bw_rank_length)
bandwidth_plot = bw_mode == "PercentRank" ? bandwidth_rank : bandwidth_raw

// Squeeze always uses BandWidth PercentRank
is_squeeze = not na(bandwidth_rank) and bandwidth_rank <= squeeze_rank_level
squeeze_start = ta.crossunder(bandwidth_rank, squeeze_rank_level)
squeeze_release = ta.crossover(bandwidth_rank, squeeze_rank_level)

// Signals
percent_b_breakout_up = ta.crossover(percent_b, upper_breakout_level)
percent_b_breakout_down = ta.crossunder(percent_b, lower_breakout_level)
percent_b_overbought = ta.crossover(percent_b, 0.8)
percent_b_oversold = ta.crossunder(percent_b, 0.2)

// Plots
plot(show_percent_b ? percent_b_plot : na, "%B", color=percent_b_color, linewidth=2)
plot(show_bandwidth ? bandwidth_plot : na, "BandWidth", color=is_squeeze ? squeeze_bw_color : bandwidth_color, linewidth=2)

plot(bw_mode == "PercentRank" and show_bandwidth ? squeeze_rank_level : na, "Squeeze Threshold", color=color.new(color.red, 45), linewidth=1, style=plot.style_linebr)

hline(100.0, "%B 1.0", color=color.new(color.gray, 55), linestyle=hline.style_dashed)
hline(80.0, "%B 0.8 Overbought", color=color.new(color.red, 55), linestyle=hline.style_dotted)
hline(50.0, "%B 0.5 Midline", color=color.new(color.gray, 75), linestyle=hline.style_dotted)
hline(20.0, "%B 0.2 Oversold", color=color.new(color.lime, 55), linestyle=hline.style_dotted)
hline(0.0, "%B 0.0", color=color.new(color.gray, 55), linestyle=hline.style_dashed)

bgcolor(is_squeeze and show_bandwidth ? squeeze_bg_color : na, title="Squeeze Background")

// Shape markers
plotshape(show_signals and show_percent_b and percent_b_breakout_up ? 105.0 : na, "Bullish %B Breakout", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(show_signals and show_percent_b and percent_b_breakout_down ? -5.0 : na, "Bearish %B Breakout", style=shape.triangledown, location=location.absolute, color=color.red, size=size.tiny)

plotshape(show_signals and show_percent_b and percent_b_overbought ? 95.0 : na, "%B Overbought Cross", style=shape.circle, location=location.absolute, color=color.red, size=size.tiny)
plotshape(show_signals and show_percent_b and percent_b_oversold ? 5.0 : na, "%B Oversold Cross", style=shape.circle, location=location.absolute, color=color.lime, size=size.tiny)

plotshape(show_signals and show_bandwidth and squeeze_start ? 45.0 : na, "Squeeze Start", style=shape.circle, location=location.absolute, color=color.red, size=size.tiny)
plotshape(show_signals and show_bandwidth and squeeze_release ? 55.0 : na, "Squeeze Release", style=shape.diamond, location=location.absolute, color=color.yellow, size=size.tiny)

// Alerts
alertcondition(percent_b_breakout_up, "Bullish %B Breakout", "%B crossed above the upper breakout threshold")
alertcondition(percent_b_breakout_down, "Bearish %B Breakout", "%B crossed below the lower breakout threshold")
alertcondition(percent_b_overbought, "%B Above 0.8", "%B crossed above 0.8")
alertcondition(percent_b_oversold, "%B Below 0.2", "%B crossed below 0.2")
alertcondition(squeeze_start, "BandWidth Squeeze Start", "BandWidth entered squeeze")
alertcondition(squeeze_release, "BandWidth Squeeze Release", "BandWidth squeeze has been released")
````
