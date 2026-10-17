# Nadaraya-Watson Regression Liquidity Sweeps [AlgoAlpha]

- url: https://www.tradingview.com/script/IdfeKkUv-Nadaraya-Watson-Regression-Liquidity-Sweeps-AlgoAlpha/
- type: indicator
- pine_id: PUB;da8cbdd5e0134da8b1fbe8320dedc59f
- version: 1.0

## Description

🟠 OVERVIEW

This script combines Nadaraya-Watson regression, momentum analysis, and liquidity level tracking into a single workflow. It measures the slope of a smoothed price regression curve, converts that slope into a normalized oscillator, and uses momentum shifts to identify areas where liquidity may be resting.

The oscillator is built from the rate of change of the Nadaraya-Watson estimate rather than price itself. This allows momentum transitions to be measured relative to the underlying regression trend. When momentum weakens after an extended move, the script records swing-based liquidity levels that can later be swept by price.

A volatility-adjusted Nadaraya-Watson band is also displayed on the chart. This provides context for trend direction, momentum strength, and potential rebound conditions around the regression value.

🟠 CONCEPTS

[list]

[*] Nadaraya-Watson Regression — A kernel-based smoothing method that estimates an underlying price curve by weighting nearby historical data more heavily than distant data.

[*] Normalized Regression Slope — The change in the Nadaraya-Watson estimate divided by its recent standard deviation, allowing momentum strength to be compared across different market conditions.

[*] Liquidity Sweep Level — A horizontal level created from a swing high or swing low when momentum begins to weaken, representing an area that may later attract price.

[*] Oscillator Signal Line — An EMA of the normalized oscillator used to identify momentum crossovers and momentum phase changes.

[*] Rebound Condition — A signal generated when price moves back through the Nadaraya-Watson value while oscillator direction remains aligned with the prevailing momentum bias.

[/list]

🟠 FEATURES

[list]

[*] Normalized Nadaraya-Watson Oscillator — Measures momentum using the slope of a smoothed regression curve.
[image]https://www.tradingview.com/x/kFU4lftH/[/image]

[*] Liquidity Sweep Detection — Creates liquidity levels when bullish or bearish momentum begins to weaken.
[image]https://www.tradingview.com/x/aZ4K6uPi/[/image]

[*] Volatility-Adjusted Regression Band — Displays a dynamic overlay around the Nadaraya-Watson estimate using smoothed ATR values.
[image]https://www.tradingview.com/x/XXeaxz9A/[/image]

[*] Momentum Weakening Signals — Marks locations where oscillator momentum begins to lose strength against the current directional bias.
[image]https://www.tradingview.com/x/e55O66YZ/[/image]

[*] Rebound Signals — Highlights situations where price reclaims or loses the regression value while momentum remains aligned with trend direction.
[image]https://www.tradingview.com/x/xJp7JcEn/[/image]
[/list]

🟠 HOW TO USE

[list]

[*] Monitor the oscillator relative to its signal line to identify momentum shifts and changes in directional bias.

[*] Watch for newly created liquidity levels after momentum weakening events, as these levels may become future sweep targets.

[*] Use sweeps of upper or lower liquidity levels to identify areas where price has taken resting liquidity.

[*] Look for bullish rebound signals when price reclaims the regression value while bullish momentum remains active.

[*] Look for bearish rebound signals when price loses the regression value while bearish momentum remains active.

[*] Combine oscillator direction, liquidity levels, and regression band structure to build context around trend continuation or reversal scenarios.

[/list]

🟠 CONCLUSION

The Nadaraya-Watson Regression Liquidity Sweeps indicator combines regression-based momentum analysis, volatility-adjusted trend structure, and liquidity level tracking. By linking momentum transitions to swing-derived liquidity zones, it helps identify where liquidity may be forming and when it has been swept. This provides traders with additional context for trend analysis, pullbacks, and potential reversal areas.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlgoAlpha

//@version=6
indicator("Nadaraya-Watson Regression Liquidity Sweeps [AlgoAlpha]", "AlgoAlpha - Nadaraya-Watson Regression Liquidity", overlay = false, max_lines_count = 500)

group_regression = "Regression"
group_oscillator = "Oscillator"
group_volatility = "Volatility"
group_levels = "Liquidity Levels"
group_appearance = "Appearance"

norm_len = input.int(100, "Normalization Length", minval = 1, group = group_oscillator, tooltip = "Controls the standard deviation window used to normalize the Nadaraya-Watson slope. Increasing it makes oscillator scaling more stable and slower to adapt; decreasing it makes scaling adapt faster but can make the oscillator more reactive and noisy.")
nw_bandwidth = input.int(30, "Nadaraya-Watson Bandwidth", minval = 1, group = group_regression, tooltip = "Controls the width of the Nadaraya-Watson kernel. Increasing it makes the regression smoother and slower to turn; decreasing it makes the regression track price more closely but can add noise.")
nw_lookback = input.int(140, "Nadaraya-Watson Lookback", minval = 1, group = group_regression, tooltip = "Controls how many historical bars are included in the Nadaraya-Watson estimate. Increasing it uses more history for a more stable curve; decreasing it focuses more on recent price action and reacts faster.")
osc_smooth_len = input.int(21, "Oscillator Smoothing Length", minval = 1, group = group_oscillator, tooltip = "Controls the WMA smoothing applied to the normalized slope oscillator. Increasing it makes the oscillator smoother with fewer sharp turns; decreasing it makes the oscillator more responsive but choppier.")
signal_len = input.int(14, "Signal Length", minval = 1, group = group_oscillator, tooltip = "Controls the EMA length of the oscillator signal line. Increasing it makes signal crosses slower and less frequent; decreasing it makes crosses happen earlier and more often.")
atr_len = input.int(14, "ATR Length", minval = 1, group = group_volatility, tooltip = "Controls the ATR window used for the price overlay volatility offset. Increasing it makes volatility measurement smoother; decreasing it makes the overlay react faster to recent range expansion or contraction.")
vol_smooth_len = input.int(21, "Volatility Smoothing Length", minval = 1, group = group_volatility, tooltip = "Controls the smoothing applied to ATR before it is used in the overlay. Increasing it creates a steadier volatility offset; decreasing it makes the offset expand and contract more quickly.")

use_tip = input.bool(true, "Use Swing Points", group = group_levels, tooltip = "When enabled, liquidity levels are anchored to the highest high or lowest low reached during the active oscillator phase. When disabled, new levels are anchored to the current bar high or low when the signal event occurs.")

show_nw_band_candles = input.bool(true, "Show Nadaraya-Watson Band Candles", group = group_appearance, tooltip = "When enabled, plots the Nadaraya-Watson volatility band as overlay candles. Disabling it hides the band candles without changing calculations, levels, signals, or alerts.")
show_bar_color_candles = input.bool(true, "Show Bar Colour Candles", group = group_appearance, tooltip = "When enabled, redraws price candles with oscillator-based bullish or bearish colours using plotcandle. Disabling it leaves the chart's normal candles visually unchanged.")
show_signal_line = input.bool(true, "Show Oscillator Signal Line", group = group_appearance, tooltip = "When enabled, displays the EMA signal line of the oscillator. Disabling it hides the signal line but keeps signal-cross logic active.")
show_momentum_signals = input.bool(true, "Show Momentum Weakening Signals", group = group_appearance, tooltip = "When enabled, displays the small momentum weakening dots on the chart. Disabling it hides those visual markers without affecting alert conditions.")
show_rebound_signals = input.bool(true, "Show Rebound Signals", group = group_appearance, tooltip = "When enabled, displays bullish and bearish rebound markers around the Nadaraya-Watson value. Disabling it hides those visual markers without affecting calculations.")

green = input.color(#00ffbb, "Bullish Colour", group = group_appearance, tooltip = "Sets the bullish color used for positive oscillator fills, bullish price overlay coloring, lower liquidity levels, and bullish momentum events.")
red = input.color(#ff1100, "Bearish Colour", group = group_appearance, tooltip = "Sets the bearish color used for negative oscillator fills, bearish price overlay coloring, upper liquidity levels, and bearish momentum events.")

nw(series float src, simple int bandwidth, simple int lookback) =>
    float num = 0.0
    float den = 0.0
    float h2  = 2.0 * math.pow(bandwidth, 2)
    for i = 0 to lookback - 1
        float w = math.exp(-math.pow(i, 2) / h2)
        num += src[i] * w
        den += w
    num / den

pseudo_transp(color c, int transp) =>
    color.from_gradient(transp, 0, 100, c, chart.bg_color)

nw_val   = nw(close, nw_bandwidth, nw_lookback)
nw_slope = nw_val - nw_val[1]

slope_std = ta.stdev(nw_slope, norm_len)
osc_      = nw_slope / slope_std
osc       = ta.wma(osc_, osc_smooth_len)
signal    = ta.ema(osc, signal_len)

volatility = ta.sma(ta.atr(atr_len), vol_smooth_len)

overflow = math.max(math.abs(osc) - 2, 0)

con1 = ta.crossunder(osc, signal)
con2 = ta.crossover(osc, signal)

above_signal = osc > signal
below_signal = osc < signal

var float above_tip_price = na
var int above_tip_bar = na

var float below_tip_price = na
var int below_tip_bar = na

if above_signal
    if not above_signal[1]
        above_tip_price := high
        above_tip_bar := bar_index
    else if na(above_tip_price) or high > above_tip_price
        above_tip_price := high
        above_tip_bar := bar_index

if below_signal
    if not below_signal[1]
        below_tip_price := low
        below_tip_bar := bar_index
    else if na(below_tip_price) or low < below_tip_price
        below_tip_price := low
        below_tip_bar := bar_index

draw_upper_line = osc > 0 and con1
draw_lower_line = osc < 0 and con2
draw_new_line = draw_upper_line or draw_lower_line

var line active_line = na
var float active_line_price = na
var int active_line_type = 0

upper_level_swept = not na(active_line) and active_line_type == 1 and close > active_line_price
lower_level_swept = not na(active_line) and active_line_type == -1 and close < active_line_price

if not na(active_line) and active_line_type != 0
    line.set_x2(active_line, bar_index)

    line_crossed = active_line_type == 1 ? close > active_line_price : close < active_line_price

    if line_crossed or draw_new_line
        active_line_type := 0

if draw_upper_line
    float level_price = use_tip and not na(above_tip_price) ? above_tip_price : high
    int level_bar = use_tip and not na(above_tip_bar) ? above_tip_bar : bar_index

    active_line := line.new(
         x1 = level_bar,
         y1 = level_price,
         x2 = bar_index,
         y2 = level_price,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = red,
         style = line.style_solid,
         width = 2,
         force_overlay = true
     )

    active_line_price := level_price
    active_line_type := 1

if draw_lower_line
    float level_price = use_tip and not na(below_tip_price) ? below_tip_price : low
    int level_bar = use_tip and not na(below_tip_bar) ? below_tip_bar : bar_index

    active_line := line.new(
         x1 = level_bar,
         y1 = level_price,
         x2 = bar_index,
         y2 = level_price,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = green,
         style = line.style_solid,
         width = 2,
         force_overlay = true
     )

    active_line_price := level_price
    active_line_type := -1

weakening_bullish_momentum = osc > 0 and con1
weakening_bearish_momentum = osc < 0 and con2
bullish_zero_cross = ta.crossover(osc, 0)
bearish_zero_cross = ta.crossunder(osc, 0)
bullish_signal_cross = con2
bearish_signal_cross = con1
bullish_rebound = osc > 0 and close[1] < nw_val and close > nw_val
bearish_rebound = osc < 0 and close[1] > nw_val and close < nw_val

main = plot(osc, "Oscillator", color.blue, 2, plot.style_line, display = display.none)
plot(signal, "Signal Line", show_signal_line ? color.new(chart.fg_color, 50) : na)

ovf = plot(osc > 2 ? overflow : osc < -2 ? -overflow : 0, "Overflow", display = display.none)

zero = plot(0, "Zero Line", chart.fg_color)

col_ = osc > 0 ? color.from_gradient(osc, 0, 3, pseudo_transp(green, 80), pseudo_transp(green, 30)) : color.from_gradient(osc, -3, 0, pseudo_transp(red, 30), pseudo_transp(red, 80))

fill(main, ovf, col_, "Oscillator Fill")
fill(zero, ovf, osc > 0 ? green : red, "Oscillator Fill")

plotcandle(
     open = show_nw_band_candles ? nw_val + (osc > 0 ? -volatility : volatility) : na,
     high = show_nw_band_candles ? osc < 0 ? high : nw_val : na,
     low = show_nw_band_candles ? osc > 0 ? low : nw_val : na,
     close = show_nw_band_candles ? nw_val : na,
     title = "Nadaraya-Watson Band",
     bordercolor = na,
     force_overlay = true,
     color = col_,
     wickcolor = color.new(col_, 70)
 )

plotcandle(
     open = show_bar_color_candles ? open : na,
     high = show_bar_color_candles ? high : na,
     low = show_bar_color_candles ? low : na,
     close = show_bar_color_candles ? close : na,
     title = "Price",
     color = col_,
     wickcolor = col_,
     bordercolor = col_,
     force_overlay = true
 )

plotchar(show_momentum_signals and weakening_bullish_momentum, "Weakening Bullish Momentum", "●", location.abovebar, green, size = size.tiny, force_overlay = true)
plotchar(show_momentum_signals and weakening_bearish_momentum, "Weakening Bearish Momentum", "●", location.belowbar, red, size = size.tiny, force_overlay = true)

plotchar(show_rebound_signals and bullish_rebound ? nw_val - volatility * 1.5 : na, "Bullish Rebound", "▲", location.absolute, green, size = size.tiny, force_overlay = true)
plotchar(show_rebound_signals and bearish_rebound ? nw_val + volatility * 1.5 : na, "Bearish Rebound", "▼", location.absolute, red, size = size.tiny, force_overlay = true)

//ALERTS
alertcondition(weakening_bullish_momentum, title = "Weakening Bullish Momentum")
alertcondition(weakening_bearish_momentum, title = "Weakening Bearish Momentum")
alertcondition(bullish_signal_cross, title = "Bullish Signal Cross")
alertcondition(bearish_signal_cross, title = "Bearish Signal Cross")
alertcondition(bullish_zero_cross, title = "Bullish Zero Cross")
alertcondition(bearish_zero_cross, title = "Bearish Zero Cross")
alertcondition(draw_upper_line, title = "New Upper Liquidity Sweep Level")
alertcondition(draw_lower_line, title = "New Lower Liquidity Sweep Level")
alertcondition(upper_level_swept, title = "Upper Liquidity Sweep Level Swept")
alertcondition(lower_level_swept, title = "Lower Liquidity Sweep Level Swept")
````
