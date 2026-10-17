# Asymmetric Volatility Trend Line [QuantAlgo]

- url: https://www.tradingview.com/script/IZMG4B5Y-Asymmetric-Volatility-Trend-Line-QuantAlgo/
- type: indicator
- pine_id: PUB;fe659869c1004ad6b7d165e36a2ee0fa
- version: 1.0

## Description

[b]🟢 Overview[/b]

[b]Asymmetric Volatility Trend Line[/b] is a trend-following indicator built on adaptive standard deviation thresholds rather than fixed bands or moving average crossovers. It quantifies the statistical volatility of recent price movement to determine asymmetric conditions for trend continuation versus trend reversal, then uses those conditions to anchor a dynamic trend line that adjusts position in response to confirmed directional moves, helping traders distinguish between genuine breakouts and noise-driven fluctuations across every timeframe and market.
[image]https://www.tradingview.com/x/PGItlV2V/[/image]
[b]🟢 How It Works[/b]

The foundation of the indicator is a rolling standard deviation applied to the selected price source over a configurable lookback window, scaled by a threshold multiplier to produce the volatility boundary used in all trend logic:
[pine]vol_threshold = ta.stdev(src, lookback) * threshold_mult[/pine]
This threshold is intentionally asymmetric in application. When the trend line is in a bullish state, a smaller fraction of the threshold (0.5x) is required for price to confirm continuation, while a full threshold breach in the opposite direction is needed to trigger a reversal. The same asymmetry applies in reverse during bearish states:
[pine]if trend_dir >= 0
    if src > trend_line + vol_threshold * 0.5
        trend_line := math.max(trend_line, src - vol_threshold * 0.25)
        trend_dir  := 1
    else if src < trend_line - vol_threshold
        trend_line := src + vol_threshold * 0.25
        trend_dir  := -1[/pine]
This design means continuation requires less evidence than reversal. A directional move only needs to exceed half the volatility threshold to sustain the current trend, but must overcome the full threshold to flip it. The 0.25x offset applied when repositioning the trend line keeps it anchored within the volatility envelope rather than jumping directly to price, producing a smoother line that does not overreact to a single bar.

When a reversal is confirmed, the trend line is placed on the opposite side of price at a quarter-threshold distance, giving it room to develop without immediately triggering another flip:
[pine]trend_line := src + vol_threshold * 0.25  // repositioned on bearish flip
trend_dir  := -1[/pine]
Direction state is tracked through two integer variables, with reversal conditions derived from comparing the current and prior bar states:
[pine]turned_bullish = trend_dir == 1  and trend_dir[1] == -1
turned_bearish = trend_dir == -1 and trend_dir[1] == 1
is_reversal    = trend_dir != prev_dir and bar_index > 0[/pine]
[image]https://www.tradingview.com/x/QkUoFaWM/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Green):[/b] When price closes above the trend line by more than half the volatility threshold, the indicator enters bullish mode with green colouring applied across the trend line, gradient fill, and reversal marker (⦿). This state persists until price closes below the trend line by the full volatility threshold, allowing normal pullbacks to occur without triggering a direction change.

[b]▶ Bearish Trend (Red):[/b] When price closes below the trend line by more than half the volatility threshold, the indicator enters bearish mode with red colouring across all visual elements. A full threshold breach to the upside is required to exit this bearish state.
[image]https://www.tradingview.com/x/wRRXM0BU/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets cover different trading approaches. "Default" targets swing trading on 4-hour and daily charts with moderate threshold sensitivity. "Fast Response" reduces the volatility barrier and shortens the lookback for intraday charts where the indicator needs to adapt to shorter-duration moves. "Smooth Trend" raises the reversal threshold substantially for position trading on daily and weekly timeframes, where the cost of a false flip is higher than the cost of a delayed one. Selecting a preset overrides the individual multiplier and lookback inputs.
[image]https://www.tradingview.com/x/ROkAItSf/[/image]
[b]▶ Built-in Alerts: [/b]Three alert conditions cover all directional states. "Bullish Trend Signal" fires on the bar where the trend direction flips from bearish to bullish. "Bearish Trend Signal" fires on the bar where it flips from bullish to bearish. "Any Trend Change" combines both into a single condition for traders who want a unified notification regardless of direction.
[image]https://www.tradingview.com/x/IWXRh9ZD/[/image]
[b]▶ Visual Customisation: [/b]Six colour presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) apply coordinated bullish and bearish colour schemes across the trend line, gradient fill, reversal markers, and optional bar and background colouring. Bar colouring tints price candles with the active trend colour at a configurable transparency level, and background colouring extends the directional tint across the full chart pane. Both are disabled by default and controlled independently.
[image]https://www.tradingview.com/x/VBKRZ0bX/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Asymmetric Volatility Trend Line [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string filter_settings = '════════ Core Settings ════════'
var string visual_settings = '════════ Visual Settings ════════'

tooltip_src          = 'Price data used as input for the calculation. Close is standard and works well in most conditions. hl2 incorporates the bar range and can reduce wick-driven noise. hlc3 adds further stability by averaging high, low, and close equally.'
tooltip_lookback     = 'Lookback window for computing the rolling standard deviation used as the volatility base. Longer windows produce a more stable threshold that reacts slowly to volatility regime changes. Shorter windows make the threshold adapt faster to recent market conditions.'
tooltip_mult         = 'Scales the raw volatility threshold derived from standard deviation. Higher values raise the barrier price must overcome to shift the trend line direction, producing fewer but higher-conviction signals. Lower values make the line more reactive to smaller moves and increase signal frequency.'
tooltip_preset       = 'Select a predefined configuration optimised for different trading styles and timeframes.'
tooltip_preset_det   = 'Default (1.5×, 20): Balanced configuration for swing trading on 4H and daily charts. Filters moderate noise while remaining responsive to genuine trend shifts.\n\nFast Response (1.0×, 12): Aggressive configuration for intraday trading on 5min–1H charts. Lower threshold reacts quickly to smaller moves, best for active traders.\n\nSmooth Trend (2.5×, 35): Conservative configuration for position trading on daily and weekly charts. High threshold establishes a stable directional baseline with minimal false signals.'
tooltip_color_preset = 'Pre-configured colour schemes optimised for different chart themes and visual preferences. Classic uses traditional green/red. Aqua provides ocean-inspired tones. Cosmic offers futuristic cyan and purple. Cyber features warm orange and cool cyan contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Custom allows full colour control.'
tooltip_bullish      = 'Colour applied to the trend line, gradient fill, and reversal markers when the filter is trending upward.'
tooltip_bearish      = 'Colour applied to the trend line, gradient fill, and reversal markers when the filter is trending downward.'
tooltip_candles      = 'Enable/disable bar colouring based on current trend direction. When enabled, price bars are tinted with the bullish or bearish colour, providing instant visual confirmation of trend state without reading the trend line directly.'
tooltip_bar_trans    = 'Transparency of the bar colouring overlay. Lower values produce vivid bars that make trend direction immediately obvious. Higher values apply a subtle tint that signals trend state without overwhelming price action visibility.'
tooltip_bgcolor      = 'Enable/disable background colouring based on current trend direction. Tints the chart background with the bullish or bearish colour to reinforce trend state across the full pane.'
tooltip_bg_trans     = 'Transparency of the background colouring overlay. Lower values produce a vivid tint. Higher values apply a subtle wash that signals trend state without obscuring price action.'

preset         = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = filter_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
src            = input.source(close, 'Price Source', group = filter_settings, tooltip = tooltip_src)
threshold_mult = input.float(1.5, 'Threshold Multiplier', minval = 0.1, step = 0.05, group = filter_settings, tooltip = tooltip_mult)
lookback       = input.int(20, 'Volatility Lookback', minval = 1, group = filter_settings, tooltip = tooltip_lookback)

color_preset   = input.string('Custom', 'Colour Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = visual_settings, tooltip = tooltip_color_preset)
bullish_input  = input.color(#00ffaa, 'Bullish Colour', group = visual_settings, tooltip = tooltip_bullish)
bearish_input  = input.color(#ff0000, 'Bearish Colour', group = visual_settings, tooltip = tooltip_bearish)
show_candles   = input.bool(false, 'Enable Bar Colouring', group = visual_settings, tooltip = tooltip_candles)
bar_trans      = input.int(0, 'Bar Colour Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bar_trans)
show_bgcolor   = input.bool(false, 'Enable Background Colouring', group = visual_settings, tooltip = tooltip_bgcolor)
bg_trans       = input.int(90, 'Background Colour Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bg_trans)

if preset == 'Fast Response'
    threshold_mult := 1.0
    lookback       := 12
else if preset == 'Smooth Trend'
    threshold_mult := 2.5
    lookback       := 35

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

vol_threshold = ta.stdev(src, lookback) * threshold_mult

var float trend_line = na
var int   trend_dir  = 0
var int   prev_dir   = 0

if na(trend_line)
    trend_line := src
else
    prev_dir := trend_dir
    if trend_dir >= 0
        if src > trend_line + vol_threshold * 0.5
            trend_line := math.max(trend_line, src - vol_threshold * 0.25)
            trend_dir  := 1
        else if src < trend_line - vol_threshold
            trend_line := src + vol_threshold * 0.25
            trend_dir  := -1
    else
        if src < trend_line - vol_threshold * 0.5
            trend_line := math.min(trend_line, src + vol_threshold * 0.25)
            trend_dir  := -1
        else if src > trend_line + vol_threshold
            trend_line := src - vol_threshold * 0.25
            trend_dir  := 1

turned_bullish = trend_dir == 1  and trend_dir[1] == -1
turned_bearish = trend_dir == -1 and trend_dir[1] == 1
trend_changed  = turned_bullish or turned_bearish
is_reversal    = trend_dir != prev_dir and bar_index > 0

//              ╔════════════════════════════════╗              //
//              ║         VISUALISATION          ║              //
//              ╚════════════════════════════════╝              //

line_color = trend_dir == 1 ? bullish_color : bearish_color

plot(trend_line, 'Trend Line', color = line_color, linewidth = 4, style = plot.style_linebr)

mid1 = trend_line + (src - trend_line) * 0.25
mid2 = trend_line + (src - trend_line) * 0.50
mid3 = trend_line + (src - trend_line) * 0.75

p_base = plot(trend_line, display = display.none)
p_mid1 = plot(mid1,       display = display.none)
p_mid2 = plot(mid2,       display = display.none)
p_mid3 = plot(mid3,       display = display.none)
p_src  = plot(src,        display = display.none)

fill(p_base, p_mid1, color = color.new(line_color, 55))
fill(p_mid1, p_mid2, color = color.new(line_color, 70))
fill(p_mid2, p_mid3, color = color.new(line_color, 82))
fill(p_mid3, p_src,  color = color.new(line_color, 92))

plotchar(is_reversal ? trend_line[1] : na, 'Reversal', '⦿', location = location.absolute, color = line_color, size = size.small, offset = -1)

barcolor(show_candles  ? color.new(line_color, bar_trans) : na, title = 'Trend Bar Colour')
bgcolor(show_bgcolor   ? color.new(line_color, bg_trans)  : na, title = 'Trend Background Colour')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turned_bullish, title = 'Bullish Trend Signal', message = 'Asymmetric Volatility Trend Line: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bearish, title = 'Bearish Trend Signal', message = 'Asymmetric Volatility Trend Line: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(trend_changed,  title = 'Any Trend Change',     message = 'Asymmetric Volatility Trend Line: Trend direction changed on {{exchange}}:{{ticker}} - {{interval}}')

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
