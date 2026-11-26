# Price Action Breakout Trend [QuantAlgo]

- url: https://www.tradingview.com/script/kFsR2mbj-Price-Action-Breakout-Trend-QuantAlgo/
- type: indicator
- pine_id: PUB;38805a5fab7d4c13a8c72252e584c5ce
- version: 1.0

## Description

[b]🟢 Overview[/b]

[b]Price Action Breakout Trend[/b] is a trend-following indicator built on structural range breakouts rather than moving average crossovers or oscillator thresholds. It tracks the highest high and lowest low of a defined lookback window to establish the levels price must decisively clear to confirm a directional shift, anchoring a trailing stop that ratchets in the trend's direction and reverses only when price breaks through it, helping traders distinguish genuine trend continuation from the shallow pullbacks that punctuate every sustained move across all timeframes and markets.
[image]https://www.tradingview.com/x/r9id9KhA/[/image]
[b]🟢 How It Works[/b]

The foundation of the indicator is the range defined by recent price extremes. On each bar it references the highest high and lowest low of the prior lookback window, excluding the current bar so the reference range is locked in before price interacts with it:
[pine]prior_high = ta.highest(high, lookback)[1]
prior_low  = ta.lowest(low, lookback)[1][/pine]
These two levels frame the breakout boundaries. Rather than reacting to every marginal touch, the indicator lets you define what qualifies as a genuine break through the confirmation setting, which determines whether the closing price or the full bar extreme is tested against the trailing stop:
[pine]test_down = confirmation == 'Close' ? close : low
test_up   = confirmation == 'Close' ? close : high[/pine]
From these, a single trailing stop is maintained on the active side of the trend. While the trend holds bullish the stop ratchets upward, advancing to track the rising lookback low and never loosening, and the trend reverses the moment the tested price breaks below it:
[pine]if trend == 1
    trail := math.max(trail, prior_low)
    if test_down < trail
        trend := -1
        trail := prior_high[/pine]
On that reversal the stop immediately re-anchors to the opposite extreme, flipping above price to begin trailing the new downtrend, where the mirror of this same logic ratchets the stop lower and flips the trend back to bullish once price breaks above it. Because the reversal is triggered by the same stop price has been trailing, the line is not a passive overlay but the actual decision boundary, with no separate signal calculation sitting behind it. This makes the indicator a continuous stop-and-reverse system that always holds a committed direction, retaining its bullish or bearish reading through every pullback contained within the range until price clears the trailing level.
[image]https://www.tradingview.com/x/ctkElAWU/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Green):[/b] When price breaks above the trailing stop and the trend flips up, the indicator enters bullish mode with green coloring applied across the stop, gradient fill, and breakout levels. The stop sits below price and ratchets higher as the trend develops, and the reading holds through pullbacks that stay above it. The flip into green, marked by an up triangle beneath the bar, identifies a potential long/buy opportunity, with subsequent pullbacks toward the rising stop offering potential continuation entries while the trend remains intact.

[b]▶ Bearish Trend (Red):[/b] When price breaks below the trailing stop and the trend flips down, the indicator enters bearish mode with red coloring across all visual elements. The stop sits above price and ratchets lower as the decline extends, holding bearish through rallies that fail to reclaim it. The flip into red, marked by a down triangle above the bar, identifies a potential short/sell opportunity, with rallies back toward the falling stop offering potential continuation entries on the downside.
[image]https://www.tradingview.com/x/U7hitcEv/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets cover different trading approaches. "Default" targets swing trading on 4-hour and daily charts with a 10-bar lookback and close-based confirmation, filtering marginal breaks while staying responsive to genuine shifts. "Fast Response" shortens the lookback to 5 bars and switches to wick-based confirmation for intraday charts, where the trend needs to flip as soon as price trades beyond a recent extreme. "Smooth Trend" extends the lookback to 25 bars with close confirmation for position trading on daily and weekly timeframes, where the cost of a false flip exceeds the cost of a delayed one. Selecting a preset overrides the individual lookback and confirmation inputs.
[image]https://www.tradingview.com/x/gcjwT6DO/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions cover all directional states. "Bullish Breakout Signal" fires on the bar where the trend confirms bullish. "Bearish Breakout Signal" fires on the bar where it confirms bearish. "Any Breakout Signal" combines both into a single condition for traders who want a unified notification regardless of direction.
[image]https://www.tradingview.com/x/i4CwR5fi/[/image]
[b]▶ Visual Customization: [/b]Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) apply coordinated bullish and bearish schemes across the trailing stop, gradient fill, breakout levels, markers, and optional bar and background coloring. Independent toggles control each visual layer, so the trailing stop line, the gradient fill that ramps from the stop toward price, the triangle markers printed on each flip, and the underlying breakout levels that frame the active range can each be shown or hidden without affecting the others. Bar coloring tints price candles with the active trend color at a configurable transparency, and background coloring extends the directional tint across the full chart pane. Both are disabled by default and controlled independently.
[image]https://www.tradingview.com/x/HxrNJHbD/[/image]
[b]*Tips:[/b] Layer the [b]Price Action Breakout Trend[/b] with complementary analysis rather than treating it as a standalone trading tool. Breakouts hold most reliably when backed by participation, so combine each flip with volume context, since a break on expanding volume is far more likely to sustain than one on thin flow, and read the level being cleared against market structure, as a breakout through a well-established swing high or low carries more significance than one in open space. Pairing this script with volume, open interest, CVD, market structure, and mean reversion indicators from our QuantAlgo toolkit can further validate a breakout before entry.

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Price Action Breakout Trend [QuantAlgo]', overlay = true, max_bars_back = 500)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

g_breakout = '════════ Breakout Settings ════════'
g_visual   = '════════ Visual Settings ════════'

tooltip_preset       = 'Select a predefined configuration optimized for different trading styles and timeframes.'
tooltip_preset_det   = 'Default (Lookback 10, Close confirmation): Balanced configuration for swing trading on 4H and daily charts. Waits for a bar to close beyond the prior 10-bar extreme, filtering marginal breaks while staying responsive to genuine trend shifts.\n\nFast Response (Lookback 5, Wick confirmation): Aggressive configuration for intraday trading on 5min to 1H charts. A shorter lookback and wick-based trigger flip the trend as soon as price trades beyond a recent 5-bar extreme, catching smaller moves early at the cost of more frequent signals.\n\nSmooth Trend (Lookback 25, Close confirmation): Conservative configuration for position trading on daily and weekly charts. A longer lookback and close-based trigger establish a stable directional baseline with minimal whipsaw, flipping only on decisive breaks.'
tooltip_lookback     = 'Number of bars used to define the breakout range. The trend flips when price breaks beyond the highest high or lowest low of this many prior bars. Longer lookbacks require price to clear a wider range and produce fewer but more significant breakouts. Shorter lookbacks react to smaller swings and increase signal frequency.'
tooltip_confirm      = 'Determines what price interaction triggers a trend flip. Close waits for a bar to close beyond the trailing stop, filtering intrabar noise and false breaks. Wick flips as soon as any part of the bar trades beyond the stop, reacting faster but responding to intrabar spikes that may not hold into the close.'
tooltip_trail        = 'Show or hide the trailing stop line that tracks the near side of the breakout range. The stop ratchets in the direction of the trend and resets to the opposite extreme when the trend flips. Disable to keep only the gradient fill, markers, and any other enabled overlays.'
tooltip_fill         = 'Show or hide the gradient fill between the trailing stop and price. The fill is most opaque at the stop and fades toward price, giving a quick visual read on how far price has extended from the stop. Disable for a cleaner view that shows the stop line on its own.'
tooltip_markers      = 'Show or hide the triangle markers that mark each breakout. An up triangle appears below the bar on a bullish flip and a down triangle above the bar on a bearish flip. Disable to keep the chart clean while still relying on the trailing stop, fills, or alerts.'
tooltip_levels       = 'Show or hide the prior high and low that form the current breakout range, drawn as lines. The trailing stop tracks the near side of this range and resets to the far side on each flip. Disable for a clean view showing only the stop and its fill.'
tooltip_color_preset = 'Pre-configured color schemes optimized for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean inspired blue and orange. Cosmic offers cyan and purple. Cyber features warm orange against cool cyan. Neon delivers high contrast yellow and magenta. Custom lets you set the bull and bear colors yourself.'
tooltip_bullish      = 'Color applied to the trailing stop, gradient fill, and breakout levels when the trend is up.'
tooltip_bearish      = 'Color applied to the trailing stop, gradient fill, and breakout levels when the trend is down.'
tooltip_candles      = 'Enable or disable bar coloring based on current trend direction. When enabled, price bars are tinted with the bullish or bearish color, giving instant visual confirmation of trend state without reading the stop directly.'
tooltip_bar_trans    = 'Transparency of the bar coloring overlay. Lower values produce vivid bars that make trend direction immediately obvious. Higher values apply a subtle tint that signals state without overwhelming price action.'
tooltip_bgcolor      = 'Enable or disable background coloring based on current trend direction. Tints the chart background with the bullish or bearish color to reinforce trend state across the full pane.'
tooltip_bg_trans     = 'Transparency of the background coloring overlay. Lower values produce a vivid tint. Higher values apply a subtle wash that signals state without obscuring price action.'

preset             = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = g_breakout, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
lookback_input     = input.int(10, 'Breakout Lookback', minval = 1, group = g_breakout, tooltip = tooltip_lookback)
confirmation_input = input.string('Close', 'Breakout Confirmation', options = ['Close', 'Wick'], group = g_breakout, tooltip = tooltip_confirm)

show_trail    = input.bool(true, 'Show Trailing Stop', group = g_visual, tooltip = tooltip_trail)
show_fill     = input.bool(true, 'Show Gradient Fill', group = g_visual, tooltip = tooltip_fill)
show_markers  = input.bool(true, 'Show Markers', group = g_visual, tooltip = tooltip_markers)
show_levels   = input.bool(false, 'Show Breakout Levels', group = g_visual, tooltip = tooltip_levels)
color_preset  = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = g_visual, tooltip = tooltip_color_preset)
bullish_input = input.color(#00ffaa, 'Bullish Color', group = g_visual, tooltip = tooltip_bullish)
bearish_input = input.color(#ff0000, 'Bearish Color', group = g_visual, tooltip = tooltip_bearish)
show_candles  = input.bool(false, 'Enable Bar Coloring', group = g_visual, tooltip = tooltip_candles)
bar_trans     = input.int(0, 'Bar Color Transparency', minval = 0, maxval = 100, group = g_visual, tooltip = tooltip_bar_trans)
show_bgcolor  = input.bool(false, 'Enable Background Coloring', group = g_visual, tooltip = tooltip_bgcolor)
bg_trans      = input.int(90, 'Background Color Transparency', minval = 0, maxval = 100, group = g_visual, tooltip = tooltip_bg_trans)

lookback     = preset == 'Fast Response' ? 5      : preset == 'Smooth Trend' ? 25      : lookback_input
confirmation = preset == 'Fast Response' ? 'Wick' : preset == 'Smooth Trend' ? 'Close' : confirmation_input

[bullish_color, bearish_color] = switch color_preset
    'Classic' => [#00ff00, #ff0000]
    'Aqua'    => [#00d4ff, #ff8c00]
    'Cosmic'  => [#49ffce, #9932cc]
    'Cyber'   => [#00cccc, #ff6600]
    'Neon'    => [#ffff00, #ff00ff]
    'Custom'  => [bullish_input, bearish_input]

//              ╔════════════════════════════════╗              //
//              ║        CORE CALCULATION        ║              //
//              ╚════════════════════════════════╝              //

prior_high = ta.highest(high, lookback)[1]
prior_low  = ta.lowest(low, lookback)[1]

var float trail = na
var int   trend = 0

if na(trail) and not na(prior_low)
    trail := prior_low
    trend := 1

test_down = confirmation == 'Close' ? close : low
test_up   = confirmation == 'Close' ? close : high

if trend == 1
    trail := math.max(trail, prior_low)
    if test_down < trail
        trend := -1
        trail := prior_high
else if trend == -1
    trail := math.min(trail, prior_high)
    if test_up > trail
        trend := 1
        trail := prior_low

turned_bullish = trend == 1  and trend[1] == -1
turned_bearish = trend == -1 and trend[1] == 1
trend_changed  = turned_bullish or turned_bearish

//              ╔════════════════════════════════╗              //
//              ║         VISUALIZATION          ║              //
//              ╚════════════════════════════════╝              //

trend_color = trend == 1 ? bullish_color : bearish_color

p_trail = plot(trend == 0 ? na : trail, 'Trailing Stop', color = show_trail ? color.new(trend_color, 0) : na, linewidth = 2, style = plot.style_stepline)
p_price = plot(close, 'Price Anchor', color = na, display = display.none, editable = false)

step  = (close - trail) / 6
grad1 = trail + step * 1
grad2 = trail + step * 2
grad3 = trail + step * 3
grad4 = trail + step * 4
grad5 = trail + step * 5

p_grad1 = plot(grad1, display = display.none, editable = false)
p_grad2 = plot(grad2, display = display.none, editable = false)
p_grad3 = plot(grad3, display = display.none, editable = false)
p_grad4 = plot(grad4, display = display.none, editable = false)
p_grad5 = plot(grad5, display = display.none, editable = false)

fill(p_trail, p_grad1, color = show_fill ? color.new(trend_color, 60) : na)
fill(p_grad1, p_grad2, color = show_fill ? color.new(trend_color, 68) : na)
fill(p_grad2, p_grad3, color = show_fill ? color.new(trend_color, 76) : na)
fill(p_grad3, p_grad4, color = show_fill ? color.new(trend_color, 84) : na)
fill(p_grad4, p_grad5, color = show_fill ? color.new(trend_color, 92) : na)
fill(p_grad5, p_price, color = show_fill ? color.new(trend_color, 96) : na)

plot(show_levels ? prior_high : na, 'Breakout High', color = color.new(trend_color, 50), linewidth = 3, style = plot.style_linebr)
plot(show_levels ? prior_low : na,  'Breakout Low',  color = color.new(trend_color, 50), linewidth = 3, style = plot.style_linebr)

buy_signal  = turned_bullish
sell_signal = turned_bearish

plotshape(show_markers and buy_signal,  'Buy Signal',  shape.triangleup,   location.belowbar, color.new(bullish_color, 0), size = size.small)
plotshape(show_markers and sell_signal, 'Sell Signal', shape.triangledown, location.abovebar, color.new(bearish_color, 0), size = size.small)

barcolor(show_candles and trend != 0 ? color.new(trend_color, bar_trans) : na, title = 'Trend Bar Color')
bgcolor(show_bgcolor and trend != 0  ? color.new(trend_color, bg_trans)  : na, title = 'Trend Background Color')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turned_bullish, title = 'Bullish Breakout Signal', message = 'Price Action Breakout Trend: BULLISH breakout confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bearish, title = 'Bearish Breakout Signal', message = 'Price Action Breakout Trend: BEARISH breakout confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(trend_changed,  title = 'Any Breakout Signal',     message = 'Price Action Breakout Trend: Trend direction changed on {{exchange}}:{{ticker}} - {{interval}}')

//              ╔════════════════════════════════╗              //
//              ║           CREATED BY           ║              //
//              ╚════════════════════════════════╝              //

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗ 
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````
