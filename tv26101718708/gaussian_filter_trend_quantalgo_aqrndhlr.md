# Gaussian Filter Trend [QuantAlgo]

- url: https://www.tradingview.com/script/AqRNdhlR-Gaussian-Filter-Trend-QuantAlgo/
- type: indicator
- pine_id: PUB;a98154dd8ce244868b008e6ac629a08d
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Gaussian Filter Trend[/b] passes price through a multi-pole Gaussian filter and holds the result inside an adaptive volatility deadband, producing a stepped trend path that advances only once a move has cleared the band. That band is sized by an Efficiency Ratio, tightening when price travels directionally and widening through chop, so the line tracks sustained moves and sits still through noise. Around that path, a star field orbits at two volatility-scaled radii that fade with distance, echoing the decay of the filter's own weighting and making the current trend distinctly recognizable at a glance on any instrument or timeframe.
[image]https://www.tradingview.com/x/Kkptzlsu/[/image]
[b]🟢 How It Works[/b]

The indicator's core methodology combines two mechanisms: a cascaded Gaussian filter that smooths the source series, and an efficiency-driven deadband that governs when that smoothed value is permitted to move the trend line.

First, the selected source is passed through one to four cascaded single-pole stages. A beta term derived from the filter length and the pole count sets the smoothing coefficient. Because pole count enters that calculation directly, adding poles rescales the filter response rather than layering more averaging onto the same curve:
[pine]beta  = (1 - math.cos(2 * math.pi / length)) / (math.pow(1.414, 2.0 / poleCount) - 1)
alpha = -beta + math.sqrt(beta * beta + 2 * beta)[/pine]
Next, efficiency is measured by comparing net directional movement against the total distance traveled over the efficiency window. The ratio moves toward one when travel is more directional and toward zero when price covers ground without net progress. It is then smoothed, so the deadband width is less likely to shift sharply from one bar to the next:
[pine]efficiency_ratio    = path_length == 0 ? 0.0 : net_move / path_length
smoothed_efficiency = ta.ema(efficiency_ratio, efficiency_smooth)[/pine]
The smoothed reading blends between a wider chop multiplier and a tighter trend multiplier, and that result scales Average True Range into the deadband width. Higher readings pull the envelope in, so the line can follow a move more closely. Lower readings push it out, which is intended to reduce flips in conditions where they are more likely. Disabling Adaptive Width bypasses the blend and applies a single fixed multiplier:
[pine]width_multiplier = adaptive_width ? chop_multiplier + (trend_multiplier - chop_multiplier) * smoothed_efficiency : fixed_multiplier
trend_width      = ta.atr(atr_length) * width_multiplier[/pine]
Finally, the trend line carries its previous value forward and steps only when the envelope has moved past it. It drops when the upper band falls below the current level and rises when the lower band climbs above it, producing a stepped path rather than a continuous curve:
[pine]if upper_band < trend_line
    trend_line := upper_band
if lower_band > trend_line
    trend_line := lower_band[/pine]
A persistent direction state records the last step and carries it through flat segments, so the line color, star field, bar coloring and alerts all read from the same value rather than diverging while the line is stationary. The star field orbits that path at a distance scaled to recent average bar range, spreading as ranges expand and drawing in as they compress, so the trend and the volatility it is being measured against are visible in one read.
[image]https://www.tradingview.com/x/u8CvxN5G/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Long/Buy):[/b] When the lower band climbs above the trend line, the line steps higher and the indicator enters bullish state. The trend line and star field switch to the bullish color. This condition identifies potential long or buy opportunities and remains active until the upper band falls below the line and confirms a bearish step.

[b]▶ Bearish Trend (Short/Sell):[/b] When the upper band falls below the trend line, the line steps lower and the indicator enters bearish state. The visual elements switch to the bearish color. This condition identifies potential short or sell opportunities and holds until the lower band climbs above the line and confirms a bullish step.

[b]▶ Flat Path (Hold):[/b] When price stays inside the deadband, neither band displaces the line and it holds level. Color does not change, so the prior state is carried rather than reconfirmed. Extended flat runs indicate the efficiency reading has widened the band against choppier conditions, and the state resolves only when one side of the envelope clears the line.
[image]https://www.tradingview.com/x/oASCyvFv/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets cover a range of trading styles and timeframes. "Default" uses four poles over a fourteen bar window for a balanced configuration aimed at swing trading on 1-hour and daily charts. "Fast Response" shortens the filter length and drops to two poles for a tighter path on 5-minute to 1-hour charts, which may suit intraday work at the cost of more frequent steps in choppier conditions. "Smooth Trend" lengthens the filter and widens the chop multiplier for a steadier baseline on daily and weekly charts, aimed at position trading. Selecting any preset other than Default overrides every Gaussian Filter and Trend Width input beneath it.
[image]https://www.tradingview.com/x/sZjvB1vi/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions support automated monitoring of trend transitions. "Bullish Trend Signal" fires on the bar the direction state flips to bullish. "Bearish Trend Signal" fires on the bar it flips to bearish. "Any Trend Change" triggers on either transition for traders who want a single unified alert regardless of direction. All alerts include the exchange, ticker, and timeframe in the message for immediate context.
[image]https://www.tradingview.com/x/sOVZQfto/[/image]
[b]▶ Visual Customization:[/b] Six color presets, Custom, Classic, Aqua, Cosmic, Cyber, and Neon, provide coordinated bullish and bearish color pairings suited to different chart themes and personal preferences. Selecting Custom exposes independent color pickers for both states, alongside an adjustable neutral color used during the initial warmup before the first directional step. Line width is configurable from one for a minimal look up to eight for a heavier path, and the star field toggles separately from the line so either element can be displayed on its own. Optional bar coloring and background shading tint the candles and chart field with the active trend color at configurable transparency levels, reflecting the current state without reading the line directly.
[image]https://www.tradingview.com/x/gkh6zrBi/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Gaussian Filter Trend [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗
//              ║      USER-DEFINED SETTINGS     ║
//              ╚════════════════════════════════╝

var string filter_settings = '════════ Gaussian Filter ════════'
var string width_settings  = '════════ Trend Width ════════'
var string visual_settings = '════════ Visual Settings ════════'

tooltip_preset     = 'Select a predefined configuration optimized for different trading styles and timeframes.\n\nImportant: selecting any preset other than Default overrides every Gaussian Filter and Trend Width setting below it. Manual changes to those inputs will have no effect until the preset is returned to Default.'
tooltip_preset_det = 'Default (Length 14, Poles 4, ATR 1.5, Eff 10): Balanced configuration for swing trading on 1H to daily charts. Moderate Gaussian smoothing with adaptive width that tightens in trend and widens in chop.\n\nFast Response (Length 8, Poles 2, ATR 1.2, Eff 7): Aggressive configuration for intraday trading on 5min to 1H charts. Fewer poles and a shorter length react quickly to shorter-duration moves.\n\nSmooth Trend (Length 21, Poles 4, ATR 2.0, Eff 18): Conservative configuration for position trading on daily and weekly charts. Longer smoothing and a wider chop multiplier establish a stable directional baseline with fewer false flips.'
tooltip_src        = 'Price data passed through the Gaussian filter. Close is standard and works well in most conditions. hl2 incorporates the bar range and can reduce wick-driven noise. hlc3 adds further stability by averaging high, low, and close equally.'
tooltip_length     = 'Sampling length of the Gaussian filter in bars. This is the primary smoothness control. Shorter lengths track price more tightly and flip sooner. Longer lengths suppress noise and delay state changes.'
tooltip_poles      = 'Number of cascaded one-pole stages in the Gaussian filter, from 1 to 4. Each additional pole increases smoothness and lag. Two poles suit faster markets. Four poles suit higher-timeframe trend following.'
tooltip_atr_len    = 'Lookback for Average True Range, which sets the unit of the trend deadband. The trend line only moves when the Gaussian output walks beyond this volatility envelope.'
tooltip_atr_mult   = 'Fixed width of the trend deadband in ATR units. Only applies when Adaptive Width is disabled. Higher values require a larger Gaussian displacement before the trend line steps.'
tooltip_adapt      = 'Enable/disable Efficiency Ratio scaling of the ATR deadband. When enabled, the Adaptive Trend and Adaptive Chop multipliers replace the Fixed Width Multiplier. High efficiency (clean directional progress) tightens the band so the line follows trend. Low efficiency (choppy two-way travel) widens the band so the line holds through noise.'
tooltip_eff_len    = 'Lookback window for the Efficiency Ratio. Measures net displacement against total path length. Shorter windows react quickly to regime shifts. Longer windows give a more stable read on whether directional movement is genuine.'
tooltip_trend_mult = 'ATR width applied when Efficiency Ratio is high. Only applies when Adaptive Width is enabled. Lower values keep the trend line tight during established directional moves.'
tooltip_chop_mult  = 'ATR width applied when Efficiency Ratio is low. Only applies when Adaptive Width is enabled. Higher values keep the trend line still during ranges and reduce flip noise.'
tooltip_eff_smooth = 'EMA length applied to the raw Efficiency Ratio so the deadband width does not jump bar to bar. Higher values make width changes more gradual.'
tooltip_preset_col = 'Pre-configured color schemes optimized for different chart themes and visual preferences. Custom allows full color control using the two color inputs below. Classic uses traditional green/red. Aqua provides ocean-inspired tones. Cosmic offers futuristic cyan and purple. Cyber features warm orange and cool cyan contrast. Neon delivers high-contrast yellow and magenta for maximum visibility.'
tooltip_bullish    = 'Color applied to the trend line and star field while the trend is bullish. Only applies when Color Preset is set to Custom.'
tooltip_bearish    = 'Color applied to the trend line and star field while the trend is bearish. Only applies when Color Preset is set to Custom.'
tooltip_neutral    = 'Color applied before the trend line has made its first directional step. Used only during the initial warmup period.'
tooltip_line_width = 'Thickness of the Gaussian trend line. The star field is drawn independently and is not affected by this setting.'
tooltip_show_trend = 'Enable/disable the Gaussian trend line on the chart. This control is independent of the star field.'
tooltip_show_stars = 'Enable/disable the orbiting star field around the trend path. This control is independent of the trend line.'
tooltip_candles    = 'Enable/disable bar coloring based on current trend direction, providing instant visual confirmation without reading the trend line directly.'
tooltip_bar_trans  = 'Transparency of the bar coloring overlay. Lower values produce vivid bars. Higher values apply a subtle tint that preserves price action visibility.'
tooltip_bg         = 'Enable/disable background shading based on current trend direction, tinting the chart field without altering the trend line or star field.'
tooltip_bg_trans   = 'Transparency of the background shading. Lower values produce a stronger wash. Higher values keep the tint subtle so price action remains readable.'

preset           = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = filter_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
gaussian_source  = input.source(close, 'Price Source', group = filter_settings, tooltip = tooltip_src)
gaussian_length  = input.int(14, 'Length', minval = 2, group = filter_settings, tooltip = tooltip_length)
gaussian_poles   = input.int(4, 'Poles', minval = 1, maxval = 4, group = filter_settings, tooltip = tooltip_poles)

atr_length         = input.int(14, 'ATR Length', minval = 1, group = width_settings, tooltip = tooltip_atr_len)
fixed_multiplier   = input.float(1.5, 'Fixed Width Multiplier', step = 0.1, minval = 0.1, group = width_settings, tooltip = tooltip_atr_mult)
adaptive_width     = input.bool(true, 'Adaptive Width', group = width_settings, tooltip = tooltip_adapt)
efficiency_length  = input.int(10, 'Efficiency Length', minval = 2, group = width_settings, tooltip = tooltip_eff_len)
trend_multiplier   = input.float(0.8, 'Adaptive Trend Multiplier', step = 0.1, minval = 0.1, group = width_settings, tooltip = tooltip_trend_mult)
chop_multiplier    = input.float(2.5, 'Adaptive Chop Multiplier', step = 0.1, minval = 0.1, group = width_settings, tooltip = tooltip_chop_mult)
efficiency_smooth  = input.int(5, 'Efficiency Smoothing', minval = 1, group = width_settings, tooltip = tooltip_eff_smooth)

color_preset  = input.string('Custom', 'Color Preset', options = ['Custom', 'Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon'], group = visual_settings, tooltip = tooltip_preset_col)
bullish_input = input.color(#00ffaa, 'Bullish Color', group = visual_settings, tooltip = tooltip_bullish)
bearish_input = input.color(#ff0000, 'Bearish Color', group = visual_settings, tooltip = tooltip_bearish)
neutral_input = input.color(color.gray, 'Neutral Color', group = visual_settings, tooltip = tooltip_neutral)
line_width    = input.int(4, 'Line Width', minval = 1, maxval = 8, group = visual_settings, tooltip = tooltip_line_width)
show_trend    = input.bool(true, 'Show Trend Line', group = visual_settings, tooltip = tooltip_show_trend)
show_stars    = input.bool(true, 'Show Stars', group = visual_settings, tooltip = tooltip_show_stars)
show_candles  = input.bool(false, 'Enable Bar Coloring', group = visual_settings, tooltip = tooltip_candles)
bar_trans     = input.int(0, 'Bar Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bar_trans)
show_bg       = input.bool(false, 'Enable Background Coloring', group = visual_settings, tooltip = tooltip_bg)
bg_trans      = input.int(90, 'Background Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bg_trans)

if preset == 'Fast Response'
    gaussian_length    := 8
    gaussian_poles     := 2
    atr_length         := 10
    fixed_multiplier   := 1.2
    efficiency_length  := 7
    trend_multiplier   := 0.6
    chop_multiplier    := 1.8
    efficiency_smooth  := 3
else if preset == 'Smooth Trend'
    gaussian_length    := 21
    gaussian_poles     := 4
    atr_length         := 21
    fixed_multiplier   := 2.0
    efficiency_length  := 18
    trend_multiplier   := 1.0
    chop_multiplier    := 3.2
    efficiency_smooth  := 8

[bullish_color, bearish_color] = switch color_preset
    'Classic' => [#00ff00, #ff0000]
    'Aqua'    => [#00d4ff, #ff8c00]
    'Cosmic'  => [#49ffce, #9932cc]
    'Cyber'   => [#00cccc, #ff6600]
    'Neon'    => [#ffff00, #ff00ff]
    => [bullish_input, bearish_input]

//              ╔════════════════════════════════╗
//              ║        CORE CALCULATION        ║
//              ╚════════════════════════════════╝

gaussianFilter(src, length, poleCount) =>
    beta  = (1 - math.cos(2 * math.pi / length)) / (math.pow(1.414, 2.0 / poleCount) - 1)
    alpha = -beta + math.sqrt(beta * beta + 2 * beta)
    var float stage1 = na
    var float stage2 = na
    var float stage3 = na
    var float stage4 = na
    stage1 := alpha * src + (1 - alpha) * nz(stage1, src)
    stage2 := alpha * stage1 + (1 - alpha) * nz(stage2, src)
    stage3 := alpha * stage2 + (1 - alpha) * nz(stage3, src)
    stage4 := alpha * stage3 + (1 - alpha) * nz(stage4, src)
    poleCount <= 1 ? stage1 : poleCount == 2 ? stage2 : poleCount == 3 ? stage3 : stage4

filtered_price = gaussianFilter(gaussian_source, gaussian_length, gaussian_poles)

net_move             = math.abs(gaussian_source - gaussian_source[efficiency_length])
path_length          = math.sum(math.abs(ta.change(gaussian_source)), efficiency_length)
efficiency_ratio     = path_length == 0 ? 0.0 : net_move / path_length
smoothed_efficiency  = ta.ema(efficiency_ratio, efficiency_smooth)

width_multiplier = adaptive_width ? chop_multiplier + (trend_multiplier - chop_multiplier) * smoothed_efficiency : fixed_multiplier
trend_width      = ta.atr(atr_length) * width_multiplier
upper_band       = filtered_price + trend_width
lower_band       = filtered_price - trend_width

var float trend_line = filtered_price
trend_line := nz(trend_line[1], filtered_price)
if upper_band < trend_line
    trend_line := upper_band
if lower_band > trend_line
    trend_line := lower_band

stepped_up   = trend_line > trend_line[1]
stepped_down = trend_line < trend_line[1]

var int trend_dir = 0
if stepped_up
    trend_dir := 1
else if stepped_down
    trend_dir := -1

trend_color = trend_dir == 1 ? bullish_color : trend_dir == -1 ? bearish_color : neutral_input

turned_bull  = trend_dir == 1 and trend_dir[1] != 1
turned_bear  = trend_dir == -1 and trend_dir[1] != -1
state_change = turned_bull or turned_bear

//              ╔════════════════════════════════╗
//              ║         VISUALIZATION          ║
//              ╚════════════════════════════════╝

visual_span = ta.sma(high - low, 14)
theta       = bar_index * 0.52
inner_orbit = visual_span * 0.85
outer_orbit = visual_span * 1.75

inner_star_a = trend_line + math.sin(theta) * inner_orbit
inner_star_b = trend_line + math.sin(theta + math.pi) * inner_orbit
outer_star_a = trend_line + math.cos(theta * 0.71 + 1.1) * outer_orbit
outer_star_b = trend_line + math.cos(theta * 0.71 + 1.1 + math.pi) * outer_orbit

plot(show_trend ? trend_line : na, title = 'Gaussian Filter Trend', color = trend_color, linewidth = line_width)
plot(show_stars ? inner_star_a : na, title = 'Inner Star A', color = color.new(trend_color, 30), style = plot.style_circles, linewidth = 2, editable = false, display = display.pane)
plot(show_stars ? inner_star_b : na, title = 'Inner Star B', color = color.new(trend_color, 30), style = plot.style_circles, linewidth = 2, editable = false, display = display.pane)
plot(show_stars ? outer_star_a : na, title = 'Outer Star A', color = color.new(trend_color, 70), style = plot.style_circles, linewidth = 1, editable = false, display = display.pane)
plot(show_stars ? outer_star_b : na, title = 'Outer Star B', color = color.new(trend_color, 70), style = plot.style_circles, linewidth = 1, editable = false, display = display.pane)

barcolor(show_candles and trend_dir != 0 ? color.new(trend_color, bar_trans) : na, title = 'Trend Bar Color')
bgcolor(show_bg and trend_dir != 0 ? color.new(trend_color, bg_trans) : na, title = 'Trend Background')

//              ╔════════════════════════════════╗
//              ║             ALERTS             ║
//              ╚════════════════════════════════╝

alertcondition(turned_bull,  title = 'Bullish Trend Signal', message = 'Gaussian Filter Trend: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bear,  title = 'Bearish Trend Signal', message = 'Gaussian Filter Trend: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(state_change, title = 'Any Trend Change',     message = 'Gaussian Filter Trend: Trend state changed on {{exchange}}:{{ticker}} - {{interval}}')

//              ╔════════════════════════════════╗
//              ║           CREATED BY           ║
//              ╚════════════════════════════════╝

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗ 
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````
