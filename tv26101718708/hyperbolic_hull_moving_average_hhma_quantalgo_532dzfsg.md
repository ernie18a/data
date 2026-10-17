# Hyperbolic Hull Moving Average (HHMA) [QuantAlgo]

- url: https://www.tradingview.com/script/532dzfsg-Hyperbolic-Hull-Moving-Average-HHMA-QuantAlgo/
- type: indicator
- pine_id: PUB;d3364045172a4c2fad9051faf0eed826
- version: 2.0

## Description

[b]🟢 Overview[/b]

[b]Hyperbolic Hull Moving Average[/b] is a trend-following indicator that replaces the linear weighting kernel inside a Hull Moving Average with a hyperbolic sine function, producing a moving average that concentrates weight on recent bars in a non-linear, exponentially accelerating curve rather than a straight ramp. Where a standard WMA assigns weight proportionally across the lookback, the sinh kernel creates a steep recency gradient that responds meaningfully to genuine momentum shifts while remaining more resistant to brief noise spikes, because distant bars lose influence at a compounding rate rather than a constant one. The result is a Hull-style construction with faster directional detection and smoother curvature than its conventional counterpart.
[image]https://www.tradingview.com/x/YAfkvpOw/[/image]
[b]🟢 How It Works[/b]

The indicator is built across three passes of the same sinh weighting function. The core kernel computes a weighted average where each bar's weight is determined by the hyperbolic sine of its normalized position within the lookback, scaled by a tension parameter:
[pine]float _x = (_len - i) / _len * _t
float _w = (math.exp(_x) - math.exp(-_x)) / 2[/pine]
Higher tension values push more of the total weight toward the most recent bars. At the default tension of 2.0 across a 24-period window, the most recent bar carries roughly 44 times the weight of the oldest bar. A standard WMA across the same window would assign the newest bar only 24 times the weight of the oldest, so the sinh kernel naturally produces a steeper bias toward recent price action at any equivalent length setting.

The Hull construction then runs two sinh-weighted averages at different periods, a fast pass at half the length and a slow pass at the full length, before combining them in the same denoising formula Alan Hull originally described:
[pine]fastSinh = f_sinh_weight(src, halfLen, tension)
slowSinh = f_sinh_weight(src, length, tension)
rawHull  = 2 * fastSinh - slowSinh
hhma     = f_sinh_weight(rawHull, sqrtLen, tension)[/pine]
The raw Hull output is then passed through a final sinh-weighted smoothing pass at the square root of the full length, which removes the lagging noise the doubling step introduces.

Trend direction is determined by a simple slope check on the final output. This keeps state detection clean and unambiguous, with direction changes triggering alerts and visual updates the bar they occur.
[image]https://www.tradingview.com/x/73GQOJAd/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Rising HHMA, Green):[/b] When the HHMA turns upward, all visual elements switch to the bullish colour, indicating a confirmed uptrend. Because the sinh kernel front-loads weight on recent bars, the line responds quickly to genuine upside momentum without needing price to sustain a move for many bars before registering a directional shift. Trend state remains bullish on each subsequent bar the HHMA continues to rise, allowing traders to hold positions through normal intra-trend oscillation without being shaken out by minor hesitations in the line.

[b]▶ Bearish Trend (Falling HHMA, Red):[/b] When the HHMA turns downward, all visual elements switch to the bearish colour, confirming a downtrend or a breakdown from a prior uptrend. The same recency weighting that accelerates bullish detection also means the line will respond relatively quickly to sustained selling pressure, reducing the lag that causes conventional Hull variants to stay bullish well into a reversal. The trend remains bearish on each bar the HHMA continues to fall.
[image]https://www.tradingview.com/x/Q9QE5fql/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three optimised parameter sets cover different trading approaches. "Default" is calibrated for swing trading on 4-hour and daily charts, balancing responsiveness with noise rejection. "Fast Response" shortens the lookback and increases recency bias for intraday and scalping use on 5-minute to 1-hour charts. "Smooth Trend" extends the period and flattens the weighting curve for position trading on daily and weekly charts where fewer, higher-conviction direction changes are preferred.
[image]https://www.tradingview.com/x/0mWBwYaN/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions support automated monitoring without requiring constant chart supervision. "Bullish Trend Signal" fires on the bar the HHMA slope turns upward. "Bearish Trend Signal" fires on the bar it turns downward. "Trend Direction Changed" covers both transitions with a single alert for traders who want a unified notification regardless of direction.
[image]https://www.tradingview.com/x/2bxp3qFB/[/image]
[b]▶ Visual Customization:[/b] Six colour presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) provide coordinated bullish and bearish colour pairs suited to different chart themes and backgrounds. Optional bar colouring tints price bars with the active trend colour at an adjustable transparency level, offering immediate visual confirmation of trend state across all open chart timeframes without requiring the indicator line itself to be in view.
[image]https://www.tradingview.com/x/O8U6FRDa/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Hyperbolic Hull Moving Average (HHMA) [QuantAlgo]', 'HHMA [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string calculation_settings = '════════ Calculation Parameters ════════'
var string visual_settings      = '════════ Visualization Settings ════════'

tooltip_src              = 'Price data used as input for the HHMA calculation. Close is standard and works well in most conditions. Using hl2 or hlc3 incorporates more of the bar range and produces a slightly smoother response. ohlc4 includes the open price and can reduce distortions caused by single wicks. Changing this input affects all three smoothing passes equally.'
tooltip_length           = 'Period for the Hyperbolic Hull Moving Average. Shorter periods (10-18) produce a highly reactive line that closely follows price action, capturing quick momentum shifts, ideal for intraday and scalping timeframes. Medium periods (20-30) balance responsiveness with noise filtering, suitable for swing trading on 4H and daily charts. Longer periods (36-55) establish a stable trend baseline with fewer but higher-conviction direction changes, best for position trading and primary trend identification. Standard value is 24 for balanced performance across most trading styles.'
tooltip_tension          = 'Controls the recency bias of the sinh weighting kernel. Lower values (0.5-1.0) distribute weight more evenly across the lookback, producing smoother output closer to a standard WMA. Higher values (2.5-4.0) concentrate weight heavily on the most recent bars, increasing responsiveness but also sensitivity to short-term noise. At the default tension of 2.0, the most recent bar carries roughly 44x the weight of the oldest bar across a 24-period window.'
tooltip_preset           = 'Select a predefined configuration optimised for different trading styles and timeframes.'
tooltip_preset_det       = 'Default (24, 2.0): Standard configuration suitable for swing trading on 4H and daily charts. Balanced length and tension capture meaningful trend changes while filtering minor fluctuations.\n\nFast Response (14, 2.8): Aggressive configuration for intraday and scalping on 5min-1H charts. Shorter length and higher tension react quickly to recent price shifts, best for active traders monitoring positions closely.\n\nSmooth Trend (48, 1.4): Conservative configuration for position trading on daily and weekly charts. Extended length and lower tension establish a stable trend baseline with minimal false signals, best for patient traders seeking primary trend direction.'
tooltip_enable_sideways  = 'Enable/disable the neutral sideways condition. When enabled, bars where the HHMA slope falls below the Sideways Threshold are classified as neither bullish nor bearish and rendered in the sideways colour. This is useful for avoiding false signals during low-momentum consolidation. When disabled, every bar is classified as either bullish or bearish based on HHMA direction alone, matching the classic two-state behaviour.'
tooltip_sideways_thresh  = 'Minimum slope (as % of HHMA value) required to confirm a directional trend. If the HHMA moves less than this between bars, the market is considered sideways and rendered in the sideways colour. Lower values (0.01-0.03) catch very shallow trends as directional. Higher values (0.08-0.15) require stronger momentum before confirming a trend, leaving more price action classified as sideways. Default 0.05% works well on 4H and daily charts. Only active when the Neutral Sideways Condition toggle is enabled.'
tooltip_color_preset     = 'Pre-configured colour schemes optimised for different chart themes and visual preferences. Classic uses traditional green/red. Aqua provides ocean-inspired blues and oranges. Cosmic offers futuristic cyan and purple. Cyber features warm orange and cool cyan contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Custom allows full colour customisation.'
tooltip_bullish          = 'Colour applied to the HHMA line and bars when the indicator is trending upward. Use vibrant colours to highlight uptrend zones and potential long opportunities.'
tooltip_bearish          = 'Colour applied to the HHMA line and bars when the indicator is trending downward. Use warning colours to signal downtrend zones and potential short opportunities or exit signals.'
tooltip_sideways         = 'Colour applied to the HHMA line and bars when the market is in a sideways or low-momentum state, meaning neither a bullish nor bearish condition is met. Gray is recommended as a neutral visual cue that clearly distinguishes consolidation from directional trend. Adjust alongside the Sideways Threshold to control how often this state activates. Only visible when the Neutral Sideways Condition toggle is enabled.'
tooltip_glow             = 'Enable/disable the neon glow effect around the HHMA line. When enabled, creates a layered visual effect with overlapping plots at increasing transparency, making the trend line more prominent and easier to track. Disable for a cleaner, minimalist appearance or when running many indicators where visual clarity is paramount.'
tooltip_barcolor         = 'Enable/disable bar colouring based on current HHMA direction. When enabled, price bars are tinted with the bullish, bearish, or sideways colour, providing instant visual confirmation of trend state without reading the indicator line directly. Disable if you prefer default bar colours or use another bar colouring indicator.'
tooltip_bartrans         = 'Transparency of the bar colouring overlay. Lower values (0-30) produce vivid, fully saturated bars that make trend direction immediately obvious. Higher values (70-90) apply a subtle tint that signals trend state without overwhelming price action visibility. Standard value is 60 for a balanced overlay that complements the HHMA glow without dominating the chart.'

src     = input.source(close,  'Price Source',          group = calculation_settings, tooltip = tooltip_src)
length  = input.int(24,        'Length',  minval = 2,   group = calculation_settings, tooltip = tooltip_length)
tension = input.float(2.0,     'Tension', minval = 0.1, step = 0.1, group = calculation_settings, tooltip = tooltip_tension)
preset  = input.string('Default', 'Preset Configuration', options = ['Default', 'Fast Response', 'Smooth Trend'], group = calculation_settings, tooltip = tooltip_preset + '\n\n' + tooltip_preset_det)
enable_sideways = input.bool(false, 'Neutral Sideways Condition', group = calculation_settings, tooltip = tooltip_enable_sideways)
sideways_thresh = input.float(0.05, 'Sideways Threshold (%)', minval = 0.01, step = 0.01, group = calculation_settings, tooltip = tooltip_sideways_thresh) / 100

color_preset    = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = visual_settings, tooltip = tooltip_color_preset)
bullish_input   = input.color(#00ffaa, 'Bullish Color',             group = visual_settings, tooltip = tooltip_bullish)
bearish_input   = input.color(#ff0000, 'Bearish Color',             group = visual_settings, tooltip = tooltip_bearish)
sideways_color  = input.color(color.gray, 'Sideways Color',         group = visual_settings, tooltip = tooltip_sideways)
enable_glow     = input.bool(true,  'Enable Neon Glow Effect',      group = visual_settings, tooltip = tooltip_glow)
enable_barcolor = input.bool(false, 'Enable Bar Coloring',          group = visual_settings, tooltip = tooltip_barcolor)
bar_trans       = input.int(60, 'Bar Color Transparency', minval = 0, maxval = 100, group = visual_settings, tooltip = tooltip_bartrans)

if preset == 'Fast Response'
    length  := 14
    tension := 2.8
else if preset == 'Smooth Trend'
    length  := 48
    tension := 1.4

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

f_sinh_weight(_src, _len, _t) =>
    float _weightSum   = 0.0
    float _weightedVal = 0.0
    for i = 0 to _len - 1
        float _x = (_len - i) / _len * _t
        float _w = (math.exp(_x) - math.exp(-_x)) / 2
        _weightedVal := _weightedVal + _src[i] * _w
        _weightSum   := _weightSum + _w
    _weightedVal / _weightSum

halfLen = math.max(1, math.floor(length / 2))
sqrtLen = math.max(1, math.floor(math.sqrt(length)))

fastSinh = f_sinh_weight(src, halfLen, tension)
slowSinh = f_sinh_weight(src, length, tension)
rawHull  = 2 * fastSinh - slowSinh
hhma     = f_sinh_weight(rawHull, sqrtLen, tension)

slopePct   = math.abs(hhma - hhma[1]) / hhma[1]
isSideways = enable_sideways and (slopePct < sideways_thresh)
isBullish  = not isSideways and (hhma > hhma[1])
isBearish  = not isSideways and (hhma < hhma[1])

turned_bullish = isBullish and not isBullish[1]
turned_bearish = isBearish and not isBearish[1]
trend_changed  = turned_bullish or turned_bearish

trend_color = isSideways ? sideways_color : (isBullish ? bullish_color : bearish_color)

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

plot(enable_glow ? hhma : na, 'HHMA Glow Outer', color.new(trend_color, 88), 20)
plot(enable_glow ? hhma : na, 'HHMA Glow Mid',   color.new(trend_color, 75), 10)
plot(enable_glow ? hhma : na, 'HHMA Glow Inner', color.new(trend_color, 50),  5)
plot(hhma, 'HHMA', color.new(trend_color, 0), 2)

barcolor(enable_barcolor ? color.new(trend_color, bar_trans) : na, title = 'Trend Bar Color')

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turned_bullish, title = 'Bullish Trend Signal',    message = 'Hyperbolic Hull MA: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(turned_bearish, title = 'Bearish Trend Signal',    message = 'Hyperbolic Hull MA: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(trend_changed,  title = 'Trend Direction Changed', message = 'Hyperbolic Hull MA: Trend direction changed on {{exchange}}:{{ticker}} - {{interval}}')

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
