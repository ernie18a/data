# Reversal Signals & Trailing Stop [AlgoAlpha]

- url: https://www.tradingview.com/script/iyp96UKb-Reversal-Signals-Trailing-Stop-AlgoAlpha/
- type: indicator
- pine_id: PUB;bd34e7ae5927410a950dad922a936048
- version: 1.0

## Description

🟠 OVERVIEW

Reversal Signals & Trailing Stop identifies reversal attempts after price stretches away from a dynamic equilibrium. Instead of using fixed percentage bands or standard volatility envelopes, it measures the size of previous directional price moves and uses that information to position adaptive reversal bands around a moving basis.

When price rejects one of these bands with a wick and closes back inside the range, the script generates a reversal signal. Each signal starts a trailing stop that follows the move until price invalidates it. This allows the indicator to combine reversal detection with trade management in a single workflow.

🟠 CONCEPTS

[list]
[*] Dynamic Basis — A Hull Moving Average that acts as the center of the reversal bands and adapts to changing market direction.
[*] Directional Move Bands — Upper and lower bands built from the historical size of bullish and bearish candle sequences, using percentile analysis instead of fixed volatility.
[*] Wick Rejection — A reversal condition where price extends beyond a band but closes back inside it, showing rejection of the extreme move.
[*] Trailing Stop — A one-directional stop that follows price after a reversal signal and remains active until price breaks it for the required number of bars.
[*] Bounce Zone — A shaded region around the trailing stop that highlights the area where price interacts with the active trail.
[/list]

🟠 FEATURES

[list]
[*] Bullish and Bearish Signal Markers — Marks confirmed wick rejection reversals directly on the chart.
[image]https://www.tradingview.com/x/tK6BjmOk/[/image]

[*] Dynamic Trailing Stop — Draws an active trailing stop after each reversal signal and updates it as price moves.
[image]https://www.tradingview.com/x/r4kMf27o/[/image]

[*] Trail Shading and Bounce Zone — Highlights the space between price and the trailing stop, including a dedicated bounce region around the trail.
[image]https://www.tradingview.com/x/wvuSfQJA/[/image]
[/list]

🟠 HOW TO USE

[list]
[*] Watch for a bullish or bearish signal after price rejects one of the reversal bands and closes back inside the range.
[*] Use the active trailing stop as a dynamic exit level while the trade remains valid.
[*] Monitor the bounce zone to see where price is interacting with the trail during an active move.
[*] Wait for the trailing stop to invalidate before treating the current reversal as complete.
[*] Adjust the band coverage, band width, and trail distance to match the volatility of the market you are trading.
[/list]

🟠 CONCLUSION

Reversal Signals & Trailing Stop [AlgoAlpha] combines adaptive reversal bands, wick rejection signals, and a dynamic trailing stop into a single indicator. It is designed to identify potential reversal points while providing a structured way to manage the move after entry. This gives traders both reversal context and an objective trailing reference on the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlgoAlpha

//@version=6
indicator("Reversal Signals & Trailing Stop [AlgoAlpha]", "AlgoAlpha - Signals & Trailing Stop", overlay = true)

// Inputs

GROUP_BANDS = "Reversal Bands"
GROUP_TRAIL = "Trailing Stop"
GROUP_APPEARANCE = "Appearance"

midband_length = input.int(50, "Basis Length", minval = 2, group = GROUP_BANDS, tooltip = "Controls how quickly the center of the bands follows price. Lower values react faster; higher values are smoother.")
sample_memory = input.int(50, "Band Lookback", minval = 5, group = GROUP_BANDS, tooltip = "Sets how many past price moves are used to place the reversal bands. A longer lookback adjusts more slowly.")
move_percentile = input.int(90, "Band Width Coverage", minval = 1, maxval = 100, group = GROUP_BANDS, tooltip = "Controls how much past price movement the bands allow. Higher values create wider bands and fewer reversals.")
band_multiplier = input.float(2.0, "Band Width", minval = 0.1, step = 0.1, group = GROUP_BANDS, tooltip = "Widens or narrows both reversal bands. Higher values place them farther from the basis.")
 
allow_trail_interruptions = input.bool(false, "Opposite Signal Can Replace Trail", group = GROUP_TRAIL, tooltip = "Allows an opposite signal to end the active trail and start a new one. When off, the trail continues until price breaks it.")
atr_length = input.int(14, "Volatility Length", minval = 1, group = GROUP_TRAIL, tooltip = "Controls how quickly trail spacing adjusts when the market becomes calmer or more volatile.")
trail_distance_multiplier = input.float(2.1, "Trail Starting Distance", minval = 0.1, step = 0.1, group = GROUP_TRAIL, tooltip = "Sets how far the trail starts from price after a reversal. Higher values give price more room.")
bounce_width_multiplier = input.float(1.0, "Trail Bounce Zone Width", minval = 0.1, step = 0.1, group = GROUP_TRAIL, tooltip = "Sets the width of the stronger shaded area beside the trail. Higher values make it wider.")
invalidation_bars = input.int(2, "Trail Break Bars", minval = 1, group = GROUP_TRAIL, tooltip = "Sets how many bars in a row must trade beyond the trail before the trail ends.")
marker_offset_multiplier = input.float(0.15, "Signal Marker Distance", minval = 0.0, step = 0.05, group = GROUP_TRAIL, tooltip = "Sets the space between each signal marker and its reversal band. This only changes marker placement.")

show_trails = input.bool(true, "Show Trail", group = GROUP_APPEARANCE, tooltip = "Shows the active trailing stop and inner band lines.")
show_zones = input.bool(true, "Show Trail Shading", group = GROUP_APPEARANCE, tooltip = "Shows the light shading between price and the trail, including the stronger bounce zone.")
show_signals = input.bool(true, "Show Signals", group = GROUP_APPEARANCE, tooltip = "Shows bullish and bearish reversal markers.")
trail_line_width = input.int(2, "Trail Thickness", minval = 1, maxval = 5, group = GROUP_APPEARANCE, tooltip = "Thickness of the bullish and bearish trailing-stop lines.")
wide_zone_transparency = input.int(94, "Trail Shading Transparency", minval = 80, maxval = 100, group = GROUP_APPEARANCE, tooltip = "Controls the light shading between price and the trail. Higher values make it more transparent.")
bounce_zone_transparency = input.int(55, "Bounce Zone Transparency", minval = 0, maxval = 100, group = GROUP_APPEARANCE, tooltip = "Controls the stronger shaded area beside the trail. Lower values make it more visible.")
bearish_color = input.color(#ff1100, "Bearish Color", inline = "colors", group = GROUP_APPEARANCE, tooltip = "Color of bearish signals, trails, and bands above price.")
bullish_color = input.color(#00ffbb, "Bullish Color", inline = "colors", group = GROUP_APPEARANCE, tooltip = "Color of bullish signals, trails, and bands below price.")

// Directional move bands

candle_direction = close > open ? 1 : -1
candle_body = math.abs(close - open)
midband = ta.hma(close, midband_length)

var bullish_move_build = 0.0
var bearish_move_build = 0.0
var bullish_moves = array.new_float()
var bearish_moves = array.new_float()

while bullish_moves.size() > sample_memory
    bullish_moves.pop()
while bearish_moves.size() > sample_memory
    bearish_moves.pop()

if candle_direction < 0
    if bullish_move_build > 0
        bullish_moves.unshift(bullish_move_build)
    bullish_move_build := 0
else
    bullish_move_build += candle_body

if candle_direction > 0
    if bearish_move_build > 0
        bearish_moves.unshift(bearish_move_build)
    bearish_move_build := 0
else
    bearish_move_build += candle_body

upper_band = bullish_moves.percentile_nearest_rank(move_percentile) * band_multiplier + midband
lower_band = midband - bearish_moves.percentile_nearest_rank(move_percentile) * band_multiplier

// Reversal signals and trail state

atr = ta.atr(atr_length)
marker_offset = atr * marker_offset_multiplier
close_inside_bands = close >= lower_band and close <= upper_band
bullish_wick_rejection = barstate.isconfirmed and close_inside_bands and low < lower_band
bearish_wick_rejection = barstate.isconfirmed and close_inside_bands and high > upper_band

upper_trail_source = midband + (upper_band - midband) * trail_distance_multiplier
lower_trail_source = midband - (midband - lower_band) * trail_distance_multiplier

var trail_direction = 0
var last_signal_direction = 0
var float trail_value = na
var outside_count = 0

signal_can_start = trail_direction == 0 or allow_trail_interruptions
bullish_signal = signal_can_start and bullish_wick_rejection and last_signal_direction != 1 and (not bearish_wick_rejection or close >= open)
bearish_signal = signal_can_start and bearish_wick_rejection and last_signal_direction != -1 and (not bullish_wick_rejection or close < open)

if bullish_signal
    trail_direction := 1
    last_signal_direction := 1
    outside_count := 0
    bullish_start_distance = math.max(midband - lower_trail_source, atr * trail_distance_multiplier)
    trail_value := math.min(midband - bullish_start_distance, low - syminfo.mintick)
else if bearish_signal
    trail_direction := -1
    last_signal_direction := -1
    outside_count := 0
    bearish_start_distance = math.max(upper_trail_source - midband, atr * trail_distance_multiplier)
    trail_value := math.max(midband + bearish_start_distance, high + syminfo.mintick)
else if trail_direction == 1
    trail_value := math.max(trail_value, lower_trail_source)
    outside_count := low < trail_value ? outside_count + 1 : 0
    if outside_count >= invalidation_bars
        trail_direction := 0
        trail_value := na
        outside_count := 0
else if trail_direction == -1
    trail_value := math.min(trail_value, upper_trail_source)
    outside_count := high > trail_value ? outside_count + 1 : 0
    if outside_count >= invalidation_bars
        trail_direction := 0
        trail_value := na
        outside_count := 0
else
    trail_value := na

// Trail bands and visuals

price_midpoint = (open + close) * 0.5
bounce_band_width = ta.sma(ta.tr(true), atr_length) * bounce_width_multiplier
bullish_trail = trail_direction == 1 ? trail_value : na
bearish_trail = trail_direction == -1 ? trail_value : na
bullish_bounce_band = trail_direction == 1 and not na(bounce_band_width) ? math.max(trail_value, math.min(trail_value + bounce_band_width, price_midpoint)) : na
bearish_bounce_band = trail_direction == -1 and not na(bounce_band_width) ? math.min(trail_value, math.max(trail_value - bounce_band_width, price_midpoint)) : na

bullish_line_color = show_trails ? bullish_color : na
bearish_line_color = show_trails ? bearish_color : na
bullish_bounce_color = show_trails ? color.new(bullish_color, 25) : na
bearish_bounce_color = show_trails ? color.new(bearish_color, 25) : na
price_side_transparency = math.min(wide_zone_transparency + 4, 100)

price_midpoint_plot = plot(barstate.isfirst ? na : price_midpoint, "Price Midpoint", display = display.none)
bullish_trail_plot = plot(bullish_trail, "Bullish Reversal Trail", color = bullish_line_color, linewidth = trail_line_width, style = plot.style_linebr)
bearish_trail_plot = plot(bearish_trail, "Bearish Reversal Trail", color = bearish_line_color, linewidth = trail_line_width, style = plot.style_linebr)
bullish_bounce_plot = plot(bullish_bounce_band, "Bullish Bounce Band", color = bullish_bounce_color, linewidth = 1, style = plot.style_linebr)
bearish_bounce_plot = plot(bearish_bounce_band, "Bearish Bounce Band", color = bearish_bounce_color, linewidth = 1, style = plot.style_linebr)

fill(price_midpoint_plot, bullish_trail_plot, price_midpoint, bullish_trail, show_zones ? color.new(bullish_color, price_side_transparency) : na, show_zones ? color.new(bullish_color, wide_zone_transparency) : na, title = "Bullish Wide Zone", fillgaps = false)
fill(price_midpoint_plot, bearish_trail_plot, bearish_trail, price_midpoint, show_zones ? color.new(bearish_color, wide_zone_transparency) : na, show_zones ? color.new(bearish_color, price_side_transparency) : na, title = "Bearish Wide Zone", fillgaps = false)
fill(bullish_bounce_plot, bullish_trail_plot, bullish_bounce_band, bullish_trail, show_zones ? color.new(bullish_color, bounce_zone_transparency) : na, show_zones ? color.new(bullish_color, bounce_zone_transparency) : na, title = "Bullish Bounce Zone", fillgaps = false)
fill(bearish_trail_plot, bearish_bounce_plot, bearish_trail, bearish_bounce_band, show_zones ? color.new(bearish_color, bounce_zone_transparency) : na, show_zones ? color.new(bearish_color, bounce_zone_transparency) : na, title = "Bearish Bounce Zone", fillgaps = false)

plotshape(show_signals and bullish_signal ? bullish_trail - marker_offset : na, title = "Bullish Wick Reversal", style = shape.labelup, location = location.absolute, color = bullish_color, text = "▲", textcolor = color.white, size = size.small)
plotshape(show_signals and bearish_signal ? bearish_trail + marker_offset : na, title = "Bearish Wick Reversal", style = shape.labeldown, location = location.absolute, color = bearish_color, text = "▼", textcolor = color.white, size = size.small)

// Alerts

alertcondition(bullish_signal, title = "Bullish Reversal Signal")
alertcondition(bearish_signal, title = "Bearish Reversal Signal")
````
