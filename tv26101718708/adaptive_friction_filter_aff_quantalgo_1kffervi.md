# Adaptive Friction Filter (AFF) [QuantAlgo]

- url: https://www.tradingview.com/script/1kfFeRvI-Adaptive-Friction-Filter-AFF-QuantAlgo/
- type: indicator
- pine_id: PUB;a95577336f2641c1ae6addd1f6894e77
- version: 2.0

## Description

[b]🟢 Overview[/b]

The [b]Adaptive Friction Filter (AFF)[/b] identifies trending market conditions by applying a physics-inspired friction model to price movement. Rather than smoothing price through fixed averaging, it introduces a dynamic noise threshold derived from recent market volatility, which means price must generate enough force to overcome this threshold before the filter moves at all. Once breached, the filter closes the gap at a configurable rate, producing a step-like trend line that holds steady through noise and responds decisively to genuine directional moves. This allows traders to distinguish between meaningful trend continuation and low-conviction chop across any instrument or timeframe.
[image]https://www.tradingview.com/x/RLB4Y8jP/[/image]
[b]🟢 How It Works[/b]

The AFF's core methodology is built around a two-stage mechanism: a volatility-derived friction threshold that gates filter movement, and a catch-up scalar that governs how much of the gap the filter closes on each bar once that threshold is exceeded.

First, the friction threshold is computed as the simple moving average of absolute bar-to-bar price changes over the configured lookback window, scaled by the friction coefficient. This makes the threshold inherently self-adjusting; it widens during volatile conditions and contracts during quiet ones, without requiring any manual recalibration:
[pine]friction = ta.sma(math.abs(src - src[1]), lookback) * friction_mult[/pine]
Next, the raw displacement between current price and the filter's last position is evaluated as force. The filter only advances if this force exceeds the friction threshold. When it does, the filter moves toward price by a fraction of the gap governed by the catch-up scalar, rather than closing the full distance immediately, producing a controlled and progressive response:
[pine]force    = src - aff_line
aff_line := math.abs(force) > friction ? aff_line + force * catchup_scalar : aff_line[/pine]
Trend direction is then resolved by comparing the current filter value to its prior bar value. The direction state persists when the filter is flat, so no transition is registered on bars where the filter does not move:
[pine]trend_dir := aff_line > aff_line[1] ? 1 : aff_line < aff_line[1] ? -1 : trend_dir[/pine]
Finally, the filter is rendered as two overlapping plots at the same value: a step-line that traces the filter's path and a circle overlay positioned at each bar's filter value. The circles serve a visual purpose, reinforcing the current filter level at each step and making it easier to read the filter's position at a glance, particularly during flat periods where the step-line alone can be harder to track. Together they produce a dotted step appearance that improves legibility across different chart zoom levels and timeframes.
[image]https://www.tradingview.com/x/22H0Q16g/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (AFF Line Rising with Bullish Colour):[/b] When price generates enough upward force to exceed the friction threshold, the filter begins stepping higher and the line shifts to the bullish colour. The step-line rendering makes the transition visually clear; flat segments indicate bars where force was insufficient to move the filter, while upward steps reflect bars where it was. The bullish trend state persists until force in the downward direction is large enough to push the filter lower, at which point trend direction flips and the line shifts to the bearish colour.

[b]▶ Bearish Trend (AFF Line Declining with Bearish Colour):[/b] When price generates enough downward force to exceed the friction threshold, the filter begins stepping lower and shifts to the bearish colour. As with the bullish state, the filter holds its last value on bars where force is insufficient to breach the threshold, and the direction state remains unchanged on those bars. A full reversal back to bullish requires upward force to exceed the friction threshold and push the filter higher, at which point trend direction flips and the colour transitions accordingly.
[image]https://www.tradingview.com/x/LaQOpgIp/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets cover a range of trading styles and timeframes. "Default" delivers balanced noise filtering for swing trading on 4-hour and daily charts. "Fast Response" lowers the friction threshold and accelerates the catch-up rate for intraday and scalping use on 5-minute to 1-hour charts, producing earlier filter movement in response to smaller price displacements. "Smooth Trend" raises the threshold and slows the catch-up rate for position trading on daily and weekly charts, requiring larger price displacements relative to the average noise level before the filter advances.
[image]https://www.tradingview.com/x/nRA0AqZJ/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions support automated monitoring of trend transitions. "Bullish Trend Signal" fires on the first bar trend direction flips from bearish to bullish. "Bearish Trend Signal" fires on the first bar trend direction flips from bullish to bearish. "Any Trend Change" triggers on either transition for traders who want a single unified alert regardless of direction. All alerts include the exchange, ticker, and timeframe in the message for immediate context.
[image]https://www.tradingview.com/x/zXxUbxbT/[/image]
[b]▶ Visual Customisation:[/b] Six colour presets, Classic, Aqua, Cosmic, Cyber, Neon, and Custom, provide coordinated bullish and bearish colour pairings suited to different chart themes and personal preferences. Selecting Custom exposes independent colour pickers for full manual control over both states. Optional bar colouring tints price candles with the active trend colour using a configurable transparency level, and optional background colouring extends the trend state tint across the full chart pane at a separately configurable transparency.
[image]https://www.tradingview.com/x/8ctb9yom/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Adaptive Friction Filter (AFF) [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string filter_settings = '════════ AFF Settings ════════'
var string visual_settings = '════════ Visual Settings ════════'

tooltip_src            = 'Price data used as input for the AFF calculation. Close is standard and works well in most conditions. hl2 incorporates the bar range and can reduce wick-driven noise. hlc3 adds further stability by averaging high, low, and close equally.'
tooltip_friction       = 'Scales the dynamic noise threshold. The threshold is derived from the average absolute bar-to-bar price change, making it inherently volatility-adjusted. Higher values raise the barrier price must overcome to move the filter, producing fewer but higher-conviction directional shifts. Lower values lower the barrier, making the filter more reactive to smaller moves.'
tooltip_catchup        = 'Controls how aggressively the filter closes the gap once the friction threshold is overcome. At 1.0 the filter jumps directly to price in one bar. At 0.1 it closes the gap gradually over several bars. Lower values produce a smoother visual and reduce whipsaw on volatile breakouts.'
tooltip_lookback       = 'Lookback window for computing the average noise threshold. Longer windows produce a more stable friction level that reacts slowly to volatility regime changes. Shorter windows make the threshold adapt faster to recent market conditions.'
tooltip_preset         = 'Select a predefined configuration optimised for different trading styles and timeframes.'
tooltip_preset_det     = 'Default (1.5, 0.5, 20): Balanced configuration for swing trading on 4H and daily charts. Filters moderate noise while remaining responsive to genuine trend shifts.\n\nFast Response (1.0, 0.7, 14): Aggressive configuration for intraday and scalping on 5min–1H charts. Lower friction and faster catch-up react quickly to smaller moves, best for active traders.\n\nSmooth Trend (2.2, 0.35, 30): Conservative configuration for position trading on daily and weekly charts. High friction and slow catch-up establish a stable directional baseline with minimal false signals.'
tooltip_color_preset   = 'Pre-configured colour schemes optimised for different chart themes and visual preferences. Classic uses traditional green/red. Aqua provides ocean-inspired tones. Cosmic offers futuristic cyan and purple. Cyber features warm orange and cool cyan contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Custom allows full colour control.'
tooltip_bullish        = 'Colour applied to the AFF line and bars when the filter is trending upward.'
tooltip_bearish        = 'Colour applied to the AFF line and bars when the filter is trending downward.'
tooltip_enable_neutral = 'When enabled, bars where the AFF line is flat (price contained within the friction band, so no directional shift occurred) are classified as neutral and coloured with the Neutral Color instead of holding the previous trend colour. Useful for visually isolating ranging or low-conviction conditions. Trend direction and alert logic are unaffected.'
tooltip_neutral        = 'Colour applied to the AFF line and bars during the neutral state — when the filter is flat, neither rising nor falling. Represents a no-conviction condition where price has not overcome the friction threshold in either direction.'
tooltip_candles        = 'Enable/disable bar colouring based on current AFF direction. When enabled, price bars are tinted with the bullish or bearish colour, providing instant visual confirmation of trend state without reading the filter line directly.'
tooltip_bar_trans      = 'Transparency of the bar colouring overlay. Lower values produce vivid bars that make trend direction immediately obvious. Higher values apply a subtle tint that signals trend state without overwhelming price action visibility.'
tooltip_bgcolor        = 'Enable/disable background colouring based on current AFF direction. Tints the chart background with the bullish or bearish colour to reinforce trend state across the full pane.'
tooltip_bg_trans       = 'Transparency of the background colouring overlay. Lower values produce a vivid tint that makes trend direction immediately obvious. Higher values apply a subtle wash that signals trend state without overwhelming price action visibility.'

preset         = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = filter_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
src            = input.source(close, 'Price Source', group = filter_settings, tooltip = tooltip_src)
friction_mult  = input.float(1.5, 'Friction Coefficient', minval = 0.1, step = 0.05, group = filter_settings, tooltip = tooltip_friction)
catchup_scalar = input.float(0.5, 'Catch-Up Sensitivity', minval = 0.1, maxval = 1.0, step = 0.05, group = filter_settings, tooltip = tooltip_catchup)
lookback       = input.int(20, 'Friction Window', minval = 1, group = filter_settings, tooltip = tooltip_lookback)

color_preset   = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = visual_settings, tooltip = tooltip_color_preset)
bullish_input  = input.color(#00ffaa, 'Bullish Color', group = visual_settings, tooltip = tooltip_bullish)
bearish_input  = input.color(#ff0000, 'Bearish Color', group = visual_settings, tooltip = tooltip_bearish)
enable_neutral = input.bool(false, 'Enable Neutral State', group = visual_settings, tooltip = tooltip_enable_neutral)
neutral_input  = input.color(#787b86, 'Neutral Color', group = visual_settings, tooltip = tooltip_neutral)
show_candles   = input.bool(true, 'Enable Bar Colouring', group = visual_settings, tooltip = tooltip_candles)
bar_trans      = input.int(50, 'Bar Colour Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bar_trans)
show_bgcolor   = input.bool(false, 'Enable Background Colouring', group = visual_settings, tooltip = tooltip_bgcolor)
bg_trans       = input.int(90, 'Background Colour Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bg_trans)

if preset == 'Fast Response'
    friction_mult := 1.0
    catchup_scalar := 0.7
    lookback := 14
    lookback
else if preset == 'Smooth Trend'
    friction_mult := 2.2
    catchup_scalar := 0.35
    lookback := 30
    lookback

[bullish_color, bearish_color, neutral_color] = switch color_preset
    'Classic' => [#00ff00, #ff0000, #808080]
    'Aqua' => [#00d4ff, #ff8c00, #78909c]
    'Cosmic' => [#49ffce, #9932cc, #8e8e9e]
    'Cyber' => [#00cccc, #ff6600, #8a8a8a]
    'Neon' => [#ffff00, #ff00ff, #aaaaaa]
    'Custom' => [bullish_input, bearish_input, neutral_input]

//              ╔════════════════════════════════╗              //
//              ║        CORE CALCULATION        ║              //
//              ╚════════════════════════════════╝              //

friction = ta.sma(math.abs(src - src[1]), lookback) * friction_mult

var float aff_line = na
var int trend_dir = 0

if na(aff_line)
    aff_line := src
    aff_line
else
    force = src - aff_line
    aff_line := math.abs(force) > friction ? aff_line + force * catchup_scalar : aff_line
    aff_line

trend_dir := aff_line > aff_line[1] ? 1 : aff_line < aff_line[1] ? -1 : trend_dir

turned_bullish = trend_dir == 1 and trend_dir[1] == -1
turned_bearish = trend_dir == -1 and trend_dir[1] == 1
trend_changed  = turned_bullish or turned_bearish
is_neutral     = enable_neutral and aff_line == aff_line[1]

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

slope      = math.abs(aff_line - aff_line[1])
slope_norm = ta.highest(slope, 100)
intensity  = math.min(slope / math.max(slope_norm, 0.0001), 1.0)

bull_col = color.from_gradient(intensity, 0, 1, color.new(bullish_color, 50), bullish_color)
bear_col = color.from_gradient(intensity, 0, 1, color.new(bearish_color, 50), bearish_color)
line_col = is_neutral ? neutral_color : trend_dir == 1 ? bull_col : bear_col

plot(aff_line, 'AFF Step', color = color.new(line_col, 20), linewidth = 4, style = plot.style_stepline)
plot(aff_line, 'AFF Dots', color = line_col, linewidth = 4, style = plot.style_circles)

barcolor(show_candles ? color.new(line_col, bar_trans) : na, title = 'Trend Bar Colour')
bgcolor(show_bgcolor ? color.new(line_col, bg_trans) : na, title = 'Trend Background Colour')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turned_bullish, title = 'Bullish Trend Signal', message = 'Adaptive Friction Filter: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bearish, title = 'Bearish Trend Signal', message = 'Adaptive Friction Filter: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(trend_changed, title = 'Any Trend Change', message = 'Adaptive Friction Filter: Trend direction changed on {{exchange}}:{{ticker}} - {{interval}}')

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
