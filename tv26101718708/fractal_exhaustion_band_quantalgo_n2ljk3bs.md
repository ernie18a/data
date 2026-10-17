# Fractal Exhaustion Band [QuantAlgo]

- url: https://www.tradingview.com/script/N2LJK3bs-Fractal-Exhaustion-Band-QuantAlgo/
- type: indicator
- pine_id: PUB;b63599d7fa2148d89fcb6292f31d2366
- version: 2.0

## Description

[b]🟢 Overview[/b]

The [b]Fractal Exhaustion Band[/b] is a trend-following indicator that replaces the fixed ATR multiplier common to most adaptive bands with the Fractal Dimension Index, scaling the buffer width in real time based on how efficiently price is consuming its recent range. Additionally, an extremum tracker accumulates swing highs and lows since the last confirmed flip to form an outer Band Edge, giving traders a structured range to position within the trend, identify exhaustion near its boundaries, and treat extensions beyond the edge as potential deviation signals ahead of a directional flip across any instrument or timeframe.
[image]https://www.tradingview.com/x/6m2AyQrY/[/image]
[b]🟢 How It Works[/b]

The core methodology is built around three sequential stages: a fractal dimension calculation that quantifies the structural quality of recent price movement, a dynamic buffer derived from that measurement, and a ratcheting trend line that advances only when market conditions justify it.

First, the Fractal Dimension Index (FDI) is calculated by comparing the total path length price has travelled over the lookback window against the straight-line distance between its highest and lowest point. A value near 1 indicates clean, efficient trending. A value near 2 indicates erratic, space-filling movement. The ratio is log-normalised by the window size to keep it comparable across different FDI Period settings:
[pine]fdi = high_ - low_ > 0 ? (math.log(len) - math.log(high_ - low_)) / math.log(power) : 0[/pine]
Next, the FDI is fed directly into the buffer calculation as a scaling factor on top of the Band Width Multiplier and a 10-period ATR. This means the buffer is never fixed; it inflates when price behaviour is erratic and compresses when price is trending with conviction:
[pine]dynamic_mult = sensitivity * (1 + fdi)
buffer       = atr * dynamic_mult[/pine]
The trend line then ratchets in the direction of the current trend, but only on bars where the FDI is below 1.5. This gate prevents the line from being dragged by price during high-fractal-dimension conditions, even if price has not yet breached the buffer threshold. A trend flip is only registered when price closes beyond the buffer on the opposite side:
[pine]if fdi < 1.5
    trend_line := math.max(trend_line, close - buffer)[/pine]
Finally, an extremum tracker accumulates the running high or low since the last confirmed flip, forming the outer Band Edge. A midline is derived as the average between this extremum and the trend line, creating a three-layer structure that encodes both the structural anchor of recent price extremes and the adaptive trend line beneath it:
[pine]ex  := trend_dir != trend_dir[1] ? (trend_dir == 1 ? high : low)
     : trend_dir == 1 ? math.max(nz(ex[1], high), high)
     :                  math.min(nz(ex[1], low),  low)
mid  = math.avg(ex, trend_line)[/pine]
[image]https://www.tradingview.com/x/azGrcHOg/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Band Rising with Bullish Colour):[/b] When price moves upward with sufficient efficiency to produce a low FDI reading and close above the trend line's buffer threshold, the trend direction flips to bullish and the entire band shifts to the bullish colour. From that point, the Fractal Line ratchets upward on each bar where the FDI remains below 1.5, while the extremum tracker accumulates successive highs to form the outer Band Edge above. The flat segments visible in the band reflect bars where the FDI gate suppressed movement, while upward steps reflect bars where trending conditions were confirmed.
[image]https://www.tradingview.com/x/Ac0bqBhR/[/image]
Within the bullish band, the Fractal Line and Band Edge define a structured trading range. Price oscillating between the two represents normal trend continuation behaviour, and pullbacks toward the Fractal Line can be treated as higher-probability long entries with the trend, using the Fractal Line itself as the logical invalidation level. The Band Mid serves as a directional gauge within that range; price holding above it reflects stronger momentum, while price drifting below it signals weakening conviction worth monitoring. When price pushes into the Band Edge zone and begins interacting with the accumulated swing highs, treat that as an exhaustion area rather than a continuation signal. Longs initiated near the Band Edge carry elevated risk of a short-term mean reversion back toward the Fractal Line. If price then extends meaningfully beyond the Band Edge, treat the extension as a deviation from the established structure. A deviation of this kind, particularly when accompanied by a rising FDI indicating deteriorating trend quality, is a preparatory signal to begin tightening long exposure and watching for the Fractal Line to be breached on the downside, which would confirm the bias flip to bearish.

[b]▶ Bearish Trend (Band Declining with Bearish Colour):[/b] When price moves downward with sufficient efficiency to produce a low FDI reading and close below the trend line's buffer threshold, the trend direction flips to bearish and the band shifts to the bearish colour. The Fractal Line ratchets lower on each bar where the FDI gate permits, while the extremum tracker accumulates successive lows to form the outer Band Edge below. As with the bullish state, the filter holds its last value on bars where fractal dimension is elevated, and the direction state remains unchanged on those bars.
[image]https://www.tradingview.com/x/dzwxtZMr/[/image]
Within the bearish band, the same structural logic applies in reverse. Price oscillating between the Fractal Line above and the Band Edge below represents normal bearish continuation, and bounces toward the Fractal Line can be treated as higher-probability short entries with the trend, using the Fractal Line as the invalidation level. The Band Mid again acts as a momentum gauge; price holding below it indicates sustained selling pressure, while recovery above it suggests the downtrend is losing conviction. When price pushes into the Band Edge zone and interacts with the accumulated swing lows, treat that region as exhaustion rather than confirmation of further downside. Shorts initiated near the Band Edge carry elevated mean-reversion risk back toward the Fractal Line. If price extends beyond the Band Edge to the downside, treat that extension as a structural deviation. A deviation paired with a rising FDI is a signal to begin reducing short exposure and watching for an upward breach of the Fractal Line, which would confirm the directional flip back to bullish.

[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets cover a range of trading styles and timeframes. "Default" delivers balanced noise filtering suited to swing trading on 4-hour and daily charts. "Fast Response" tightens the buffer and shortens the fractal measurement window for intraday and scalping use on 1-minute to 1-hour charts, producing earlier trend flips in response to smaller directional moves. "Smooth Trend" widens the buffer and extends the measurement window for position trading on daily and weekly charts, requiring a more sustained and efficient directional move before a trend flip is registered.
[image]https://www.tradingview.com/x/i00mKDCg/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions support automated monitoring of trend transitions. Bullish Trend fires on the first bar where trend direction flips from bearish to bullish. Bearish Trend fires on the first bar where trend direction flips from bullish to bearish. Any Signal Change triggers on either transition for traders who want a single unified alert regardless of direction. All alerts include the exchange, ticker, and timeframe in the message for immediate context.
[image]https://www.tradingview.com/x/uvmKqy9P/[/image]
[b]▶ Visual Customisation:[/b] Six colour presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) provide coordinated bullish and bearish colour pairings suited to different chart themes and personal preferences. Selecting Custom exposes independent colour pickers for full manual control over both states. The three-layer band fill uses graduated transparency across the outer edge, midline, and trend line zones to clearly distinguish structural from adaptive components at a glance. Optional bar colouring tints price candles with the active trend colour using a configurable transparency level, and optional background colouring extends the trend state tint across the full chart pane at a separately configurable transparency.
[image]https://www.tradingview.com/x/hQcVyqBV/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Fractal Exhaustion Band [QuantAlgo]', overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string fractal_band_settings = "══════ Fractal Band Settings ══════"
var string visual_settings       = "════════ Visualisation Settings ════════"

tooltip_src          = 'The price series the fractal band tracks. Close is the standard choice and represents the confirmed bar price. HL2 uses the bar midpoint to reduce close-to-close noise. HLC3 adds close weighting for a balanced estimate. OHLC4 averages all four prices for maximum smoothing.'
tooltip_preset       = 'Select a predefined configuration optimised for different trading styles and timeframes.\n\nDefault (20, 1.2): Balanced configuration suited to swing trading on 4H and daily charts.\n\nFast Response (10, 0.7): Aggressive configuration for scalping and intraday use on 1min to 1H charts. Reacts quickly to fractal shifts at the cost of more frequent state changes.\n\nSmooth Trend (40, 2.0): Conservative configuration for position trading on daily and weekly charts. Filters out noise and delivers only high-conviction trend flips.'
tooltip_sensitivity  = 'Scales the width of the fractal band as a multiple of the ATR-FDI product. Lower values produce a tighter band that flips on smaller price displacements. Higher values widen the band and require a more significant move before a trend flip, filtering out noise. Standard value is 1.2.'
tooltip_power        = 'The lookback window used to calculate the Fractal Dimension Index. Controls the range and path length measurement period. Shorter values react quickly to expanding ranges. Longer values smooth out transient fluctuations. Standard value is 20.'
tooltip_preset_color = 'Pre-configured colour schemes optimised for different chart themes. Classic uses traditional green and red. Aqua provides ocean-inspired tones. Cosmic offers futuristic cyan and purple. Cyber features warm orange and cool cyan contrast. Neon delivers high-contrast yellow and magenta. Custom activates the colour pickers below.'
tooltip_bull         = 'Colour applied to the band and fill during a confirmed uptrend.'
tooltip_bear         = 'Colour applied to the band and fill during a confirmed downtrend.'
tooltip_bars         = 'When enabled, candles are tinted with the active trend colour for instant visual confirmation of fractal state.'
tooltip_bar_t        = 'Transparency of the candle tint when Colour Candles is enabled. 0 is fully opaque, 100 is fully transparent.'
tooltip_bg           = 'When enabled, the chart background is tinted with the active trend colour at low opacity.'
tooltip_bg_t         = 'Transparency of the background tint when Colour Background is enabled. 85 to 95 is recommended.'
tooltip_fill         = "When enabled, the area between the band edge, midline, and fractal line is filled with the active trend colour. Disable to show only the band lines without any fill."

presetInput      = input.string("Default", "Preset Configuration",  group = fractal_band_settings, options = ["Default", "Fast Response", "Smooth Trend"], tooltip = tooltip_preset)
src              = input.source(close,     "Source",                group = fractal_band_settings, tooltip = tooltip_src)
power            = input.int(20,           "FDI Period",            group = fractal_band_settings, tooltip = tooltip_power)
sensitivity      = input.float(1.2,        "Band Width Multiplier", group = fractal_band_settings, step = 0.1, tooltip = tooltip_sensitivity)

if presetInput == "Fast Response"
    power       := 10
    sensitivity := 0.7
else if presetInput == "Smooth Trend"
    power       := 40
    sensitivity := 2.0

colorPresetInput = input.string("Custom", "Colour Preset",           group = visual_settings, options = ["Classic", "Aqua", "Cosmic", "Cyber", "Neon", "Custom"], tooltip = tooltip_preset_color)
bullColorInput   = input.color(#00ffaa,   "Uptrend",  inline = "c",  group = visual_settings, tooltip = tooltip_bull)
bearColorInput   = input.color(#ff0000,   "Downtrend", inline = "c", group = visual_settings, tooltip = tooltip_bear)
paintBarsInput   = input.bool(false,      "Colour Candles",           group = visual_settings, tooltip = tooltip_bars)
barTranspInput   = input.int(30,          "Candle Transparency",      group = visual_settings, minval = 0, maxval = 100, tooltip = tooltip_bar_t)
paintBgInput     = input.bool(false,      "Colour Background",        group = visual_settings, tooltip = tooltip_bg)
bgTranspInput    = input.int(90,          "Background Transparency",  group = visual_settings, minval = 0, maxval = 100, tooltip = tooltip_bg_t)

[bullColor, bearColor] = switch colorPresetInput
    "Classic" => [color(#00ff00), color(#ff0000)]
    "Aqua"    => [color(#00d4ff), color(#ff8c00)]
    "Cosmic"  => [color(#49ffce), color(#9932cc)]
    "Cyber"   => [color(#00cccc), color(#ff6600)]
    "Neon"    => [color(#ffff00), color(#ff00ff)]
    "Custom"  => [bullColorInput, bearColorInput]

showFillInput = input.bool(true, "Show Band Fill", group = visual_settings, tooltip = tooltip_fill)

//              ╔════════════════════════════════╗              //
//              ║           CORE LOGIC           ║              //
//              ╚════════════════════════════════╝              //

high_ = ta.highest(high, power)
low_  = ta.lowest(low, power)

len = 0.0
for i = 0 to power - 2 by 1
    len := len + math.abs(src[i] - src[i + 1])

fdi          = high_ - low_ > 0 ? (math.log(len) - math.log(high_ - low_)) / math.log(power) : 0
dynamic_mult = sensitivity * (1 + fdi)
atr          = ta.atr(10)
buffer       = atr * dynamic_mult

var float trend_line = na
var int   trend_dir  = 1
var float ex         = na

if na(trend_line)
    trend_line := src

if trend_dir >= 0
    if close < trend_line - buffer
        trend_dir  := -1
        trend_line := close + buffer * 0.5
    else
        if fdi < 1.5
            trend_line := math.max(trend_line, close - buffer)
else
    if close > trend_line + buffer
        trend_dir  := 1
        trend_line := close - buffer * 0.5
    else
        if fdi < 1.5
            trend_line := math.min(trend_line, close + buffer)

bullFlip = trend_dir ==  1 and trend_dir[1] == -1
bearFlip = trend_dir == -1 and trend_dir[1] ==  1

ex := trend_dir != trend_dir[1] ? (trend_dir == 1 ? high : low) : trend_dir == 1 ? math.max(nz(ex[1], high), high) : math.min(nz(ex[1], low), low)

mid = math.avg(ex, trend_line)

//              ╔════════════════════════════════╗              //
//              ║             PLOTS              ║              //
//              ╚════════════════════════════════╝              //

color currentColor = trend_dir == 1 ? bullColor : bearColor
noColor            = trend_dir != trend_dir[1]

cEx    = noColor ? na : color.new(currentColor, 40)
cMid   = noColor ? na : color.new(currentColor, 55)
cTrail = noColor ? na : currentColor

pEx    = plot(ex,         'Band Edge',    color = cEx,    linewidth = 1, style = plot.style_linebr)
pMid   = plot(mid,        'Band Mid',     color = cMid,   linewidth = 1, style = plot.style_linebr)
pTrail = plot(trend_line, 'Fractal Line', color = cTrail, linewidth = 3, style = plot.style_linebr)

fill(pEx,  pMid,   color = noColor or not showFillInput ? na : color.new(currentColor, 85))
fill(pMid, pTrail, color = noColor or not showFillInput ? na : color.new(currentColor, 70))

plotshape(bullFlip ? trend_line : na, title = 'Bull Flip',      location = location.absolute, style = shape.circle, color = bullColor,                size = size.tiny)
plotshape(bullFlip ? trend_line : na, title = 'Bull Flip Glow', location = location.absolute, style = shape.circle, color = color.new(bullColor, 50), size = size.small)
plotshape(bearFlip ? trend_line : na, title = 'Bear Flip',      location = location.absolute, style = shape.circle, color = bearColor,                size = size.tiny)
plotshape(bearFlip ? trend_line : na, title = 'Bear Flip Glow', location = location.absolute, style = shape.circle, color = color.new(bearColor, 50), size = size.small)

barcolor(paintBarsInput ? color.new(currentColor, barTranspInput) : na)
bgcolor(paintBgInput    ? color.new(currentColor, bgTranspInput)  : na)

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(bullFlip,             title = "Bullish Trend",     message = "Fractal Exhaustion Band [QuantAlgo]: Bullish trend confirmed on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(bearFlip,             title = "Bearish Trend",     message = "Fractal Exhaustion Band [QuantAlgo]: Bearish trend confirmed on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(bullFlip or bearFlip, title = "Any Signal Change", message = "Fractal Exhaustion Band [QuantAlgo]: Trend direction flipped on {{exchange}}:{{ticker}} - {{interval}}")

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
