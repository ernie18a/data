# Dynamic Volatility Filter [QuantAlgo]

- url: https://www.tradingview.com/script/X3xqqnI4-Dynamic-Volatility-Filter-QuantAlgo/
- type: indicator
- pine_id: PUB;2b3e3ffbdbda459aa6d8257999ab1323
- version: 1.0

## Description

[b]🟢 Overview[/b]

[b]Dynamic Volatility Filter[/b] is a trend-following indicator built on an adaptive volatility threshold rather than fixed bands or moving average crossovers. It quantifies the realized volatility of recent price movement to establish a dynamic noise floor that price must overcome before the line responds, anchoring a filtered trend line that only shifts when a directional move exceeds the prevailing volatility regime, helping traders separate statistically significant trend change from noise-driven fluctuation across every timeframe and market.
[image]https://www.tradingview.com/x/VIgw0PYU/[/image]
[b]🟢 How It Works[/b]

The foundation of the indicator is a rolling volatility estimate derived from the Average True Range over a configurable lookback window, scaled by a noise multiplier to produce the threshold used in all line logic:
[pine]threshold = ta.atr(lookback) * noise_mult[/pine]
This threshold functions as a deviation barrier the line will not cross until price movement breaches it. On each bar the filter measures the displacement between price and the current line position, and only when that displacement exceeds the volatility threshold does the line update:
[pine]float diff = src - dvf_line
if math.abs(diff) > threshold
    dvf_line := dvf_line + diff * snap_speed[/pine]
The line remains stationary through movement that falls within the volatility envelope and only commits once displacement clears the threshold. Rather than converging directly onto price, the line advances by a fraction of the residual distance governed by the catch-up coefficient, producing a damped response instead of an instantaneous one. Lower catch-up values introduce deliberate lag that requires a move to persist before the line follows, while higher values tighten the track to price.

Direction state is derived from the line's own first difference, comparing its current position against the prior bar:
[pine]if dvf_line > dvf_line[1]
    trend_dir := 1
else if dvf_line < dvf_line[1]
    trend_dir := -1[/pine]
Because the line holds flat whenever displacement stays inside the threshold, those periods register no direction change. With Show Neutral enabled the state resets to neutral during these pauses, and with it disabled the line retains its last directional reading until the next threshold breach.
[image]https://www.tradingview.com/x/oqwebFNZ/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Green):[/b] When the filter line registers positive displacement against its prior position, the indicator enters bullish mode with green coloring applied across the line, gradient fill, and volatility bands. This state persists through pullbacks contained within the threshold, since direction only updates when the line moves. The transition into green marks a potential long/buy opportunity, with pullbacks toward the line during an established bullish reading offering potential continuation entries.

[b]▶ Bearish Trend (Red):[/b] When the filter line registers negative displacement against its prior position, the indicator enters bearish mode with red coloring across all visual elements. The reading holds bearish until price clears the volatility threshold in the opposite direction. The transition into red marks a potential short/sell opportunity, with rallies back toward the line during an established bearish reading offering potential continuation entries on the downside.

[b]▶ Neutral (Gray):[/b] When Show Neutral is enabled, the line and fills turn gray during flat stretches where price stays inside the threshold and the line holds still. This state signals an absence of confirmed direction and is best treated as a stand-aside condition, where waiting for the line to commit back to green or red avoids entering during indecisive, range-bound conditions.
[image]https://www.tradingview.com/x/T2nrBin7/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets cover different trading approaches. "Default" targets swing trading on 4-hour and daily charts with a balanced threshold that filters moderate noise while staying responsive to genuine regime shifts. "Fast Response" lowers the volatility barrier and shortens the lookback for intraday charts where the line needs to adapt to shorter-duration moves. "Smooth Trend" raises the threshold and slows the catch-up for position trading on daily and weekly timeframes, where the cost of a false flip exceeds the cost of a delayed one. Selecting a preset overrides the individual noise, period, and catch-up inputs.
[image]https://www.tradingview.com/x/NmjVNHWB/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions cover all directional states. "Bullish Trend Signal" fires on the bar where the trend confirms bullish. "Bearish Trend Signal" fires on the bar where it confirms bearish. "Any Trend Change" combines both into a single condition for traders who want a unified notification regardless of direction.
[image]https://www.tradingview.com/x/iEH5Y9tS/[/image]
[b]▶ Visual Customization:[/b] Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) apply coordinated bullish and bearish color schemes across the line, gradient fill, volatility bands, and optional bar and background coloring. The volatility bands plot one threshold above and below the line to frame the deviation envelope price must breach, and can be hidden for a clean line-only view. Bar coloring tints price candles with the active trend color at a configurable transparency level, and background coloring extends the directional tint across the full chart pane. Both are disabled by default and controlled independently.
[image]https://www.tradingview.com/x/Tpu8Bimp/[/image]
[b]*Recommendation:[/b] Layer the Dynamic Volatility Filter with complementary analysis rather than treating it as a standalone decision tool. Combine direction changes with volume context, since expanding volume on a flip bar suggests the move has broader participation behind it, and read transitions against key structural levels, as a flip occurring near major support or resistance carries more weight than one in open space. Pairing this script with volume, open interest, CVD, market structure, and mean reversion indicators from our QuantAlgo toolkit can further validate directional bias before entry.

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Dynamic Volatility Filter [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string filter_settings = '════════ Core Settings ════════'
var string visual_settings = '════════ Visual Settings ════════'

tooltip_preset       = 'Select a predefined configuration optimized for different trading styles and timeframes.'
tooltip_preset_det   = 'Default (Noise 2.0×, Period 20, Speed 0.3): Balanced configuration for swing trading on 4H and daily charts. Filters moderate noise while staying responsive to genuine trend shifts.\n\nFast Response (Noise 1.2×, Period 12, Speed 0.5): Aggressive configuration for intraday trading on 5min to 1H charts. Lower threshold and quicker catch-up react fast to smaller moves.\n\nSmooth Trend (Noise 2.8×, Period 35, Speed 0.2): Conservative configuration for position trading on daily and weekly charts. Higher threshold and slower catch-up establish a stable directional baseline with minimal whipsaw.'
tooltip_src          = 'Price data used as input for the filter. Close is standard and works well in most conditions. hl2 incorporates the bar range and can reduce wick-driven noise. hlc3 adds further stability by averaging high, low, and close equally.'
tooltip_noise        = 'Scales the ATR-based noise filter. The line only moves when price breaks beyond this threshold, so higher values raise the barrier price must overcome before the line shifts, producing fewer but higher-conviction direction changes. Lower values make the line more reactive to smaller moves and increase signal frequency.'
tooltip_lookback     = 'Lookback window for the Average True Range that sets the noise threshold. Longer windows produce a steadier threshold that reacts slowly to volatility regime changes. Shorter windows make the threshold adapt faster to recent market conditions.'
tooltip_snap         = 'How aggressively the line catches up to price once the noise threshold is breached. Higher values snap the line toward price quickly for a tighter track. Lower values let the line ease in gradually, adding lag that can help confirm a move before the line commits.'
tooltip_show_bands   = 'Show or hide the volatility envelope drawn one threshold above and below the filter line. Disable for a clean line-only view. The line color and all alerts continue to work either way.'
tooltip_neutral      = 'When enabled, the line and fills turn neutral color during flat stretches where price stays inside the noise threshold and the line holds still. When disabled, the line keeps its last bullish or bearish color through those flat periods.'
tooltip_color_preset = 'Pre-configured color schemes optimized for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean inspired blue and orange. Cosmic offers cyan and purple. Cyber features warm orange against cool cyan. Neon delivers high contrast yellow and magenta. Custom lets you set the bull and bear colors yourself.'
tooltip_bullish      = 'Color applied to the line, gradient fill, and bands when the filter is trending upward.'
tooltip_bearish      = 'Color applied to the line, gradient fill, and bands when the filter is trending downward.'
tooltip_neutral_col  = 'Color shown when the filter is flat and Show Neutral is enabled. Gray is recommended as a clear cue that separates a paused, sideways line from an active directional move.'
tooltip_candles      = 'Enable/disable bar coloring based on current trend direction. When enabled, price bars are tinted with the bullish, bearish, or neutral color, giving instant visual confirmation of trend state without reading the line directly.'
tooltip_bar_trans    = 'Transparency of the bar coloring overlay. Lower values produce vivid bars that make trend direction immediately obvious. Higher values apply a subtle tint that signals state without overwhelming price action.'
tooltip_bgcolor      = 'Enable/disable background coloring based on current trend direction. Tints the chart background with the bullish, bearish, or neutral color to reinforce trend state across the full pane.'
tooltip_bg_trans     = 'Transparency of the background coloring overlay. Lower values produce a vivid tint. Higher values apply a subtle wash that signals state without obscuring price action.'

preset        = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = filter_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
src           = input.source(close, 'Price Source', group = filter_settings, tooltip = tooltip_src)
noise_mult    = input.float(2.0, 'Noise Filter', minval = 0.5, step = 0.1, group = filter_settings, tooltip = tooltip_noise)
lookback      = input.int(20, 'Volatility Period', minval = 1, group = filter_settings, tooltip = tooltip_lookback)
snap_speed    = input.float(0.3, 'Catch-up Speed', minval = 0.05, maxval = 1.0, step = 0.05, group = filter_settings, tooltip = tooltip_snap)

show_bands    = input.bool(true, 'Show Volatility Bands', group = visual_settings, tooltip = tooltip_show_bands)
show_neutral  = input.bool(false, 'Show Neutral', group = visual_settings, tooltip = tooltip_neutral)
color_preset  = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = visual_settings, tooltip = tooltip_color_preset)
bullish_input = input.color(#00ffaa, 'Bullish Color', group = visual_settings, tooltip = tooltip_bullish)
bearish_input = input.color(#ff0000, 'Bearish Color', group = visual_settings, tooltip = tooltip_bearish)
neutral_input = input.color(#808080, 'Neutral Color', group = visual_settings, tooltip = tooltip_neutral_col)
show_candles  = input.bool(false, 'Enable Bar Coloring', group = visual_settings, tooltip = tooltip_candles)
bar_trans     = input.int(0, 'Bar Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bar_trans)
show_bgcolor  = input.bool(false, 'Enable Background Coloring', group = visual_settings, tooltip = tooltip_bgcolor)
bg_trans      = input.int(90, 'Background Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bg_trans)

if preset == 'Fast Response'
    noise_mult := 1.2
    lookback   := 12
    snap_speed := 0.5
else if preset == 'Smooth Trend'
    noise_mult := 2.8
    lookback   := 35
    snap_speed := 0.2

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

atr = ta.atr(lookback)
threshold = atr * noise_mult
var float dvf_line = na
var int trend_dir = 0
if na(dvf_line)
    dvf_line := src
    dvf_line
else
    float diff = src - dvf_line
    if math.abs(diff) > threshold
        dvf_line := dvf_line + diff * snap_speed
        dvf_line
    else
        dvf_line := dvf_line
        dvf_line

if dvf_line > dvf_line[1]
    trend_dir := 1
    trend_dir
else if dvf_line < dvf_line[1]
    trend_dir := -1
    trend_dir
else
    trend_dir := show_neutral ? 0 : trend_dir
    trend_dir

turned_bullish = trend_dir == 1  and trend_dir[1] != 1
turned_bearish = trend_dir == -1 and trend_dir[1] != -1
trend_changed  = turned_bullish or turned_bearish

//              ╔════════════════════════════════╗              //
//              ║         VISUALIZATION          ║              //
//              ╚════════════════════════════════╝              //

line_color = trend_dir == 1 ? bullish_color : trend_dir == -1 ? bearish_color : neutral_input

plot(dvf_line, 'Dynamic Volatility Filter Line', color = line_color, linewidth = 4, style = plot.style_linebr)

mid1 = dvf_line + (src - dvf_line) * 0.25
mid2 = dvf_line + (src - dvf_line) * 0.50
mid3 = dvf_line + (src - dvf_line) * 0.75

p_base = plot(dvf_line, display = display.none)
p_mid1 = plot(mid1,     display = display.none)
p_mid2 = plot(mid2,     display = display.none)
p_mid3 = plot(mid3,     display = display.none)
p_src  = plot(src,      display = display.none)

fill(p_base, p_mid1, color = color.new(line_color, 55))
fill(p_mid1, p_mid2, color = color.new(line_color, 70))
fill(p_mid2, p_mid3, color = color.new(line_color, 82))
fill(p_mid3, p_src,  color = color.new(line_color, 92))

p1 = plot(show_bands ? dvf_line + threshold : na, 'Upper Band', color = color.new(line_color, 60), linewidth = 2, linestyle = plot.linestyle_dotted)
p2 = plot(show_bands ? dvf_line - threshold : na, 'Lower Band', color = color.new(line_color, 60), linewidth = 2, linestyle = plot.linestyle_dotted)
fill(p1, p2, color = color.new(line_color, show_bands ? 92 : 100))

barcolor(show_candles ? color.new(line_color, bar_trans) : na, title = 'Trend Bar Color')
bgcolor(show_bgcolor  ? color.new(line_color, bg_trans)  : na, title = 'Trend Background Color')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turned_bullish, title = 'Bullish Trend Signal', message = 'Dynamic Volatility Filter: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bearish, title = 'Bearish Trend Signal', message = 'Dynamic Volatility Filter: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(trend_changed,  title = 'Any Trend Change',     message = 'Dynamic Volatility Filter: Trend direction changed on {{exchange}}:{{ticker}} - {{interval}}')

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
