# Chandelier Exit Trend [QuantAlgo]

- url: https://www.tradingview.com/script/JMcKPHvH-Chandelier-Exit-Trend-QuantAlgo/
- type: indicator
- pine_id: PUB;68cae0fffb1e41488c42c37f80c84e9d
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Chandelier Exit Trend[/b] is a trend-following indicator built on a volatility-adjusted trailing stop that resets with every new trend, rather than one measured from a fixed window that can reach back into the previous move. It hangs the stop a multiple of the Average True Range from the trend's highest or lowest price, ratchets it only with the trend as new extremes form or volatility contracts, then confirms a trend change when a bar closes through it, so traders can ride trends against a clearly defined exit level across every timeframe and market.
[image]https://www.tradingview.com/x/zoLnw1c2/[/image]
[b]🟢 How It Works[/b]

The indicator is built around the chandelier exit, a trailing stop technique introduced by Chuck LeBeau that hangs the stop from the extreme of a move the way a chandelier hangs from a ceiling, at a distance that widens and narrows with volatility. It has three stages: stop placement from the trend's extreme and the Average True Range, a trailing rule that only lets the stop move in the direction of the trend, and a state engine that confirms trend changes when a bar closes beyond the stop.

First, the stop is placed. The extreme is the highest price seen since the current bullish trend began, or the lowest price seen since the current bearish trend began, looking back no further than the lookback period. Closing prices are used by default and highs and lows when Use Close for Extremes is disabled, while the bar that opens a trend always measures from its close. Because every trend measures from its own extreme, a new trend never hangs its stop from a high or low set before it began, so a fresh stop starts on the correct side of price. The stop then sits the ATR multiple away from that extreme:
[pine]float atrValue = ta.atr(per)

int span         = math.max(1, math.min(per, bar_index - trendStart + 1))
float hiSrc      = useClose or bar_index == trendStart ? close : high
float loSrc      = useClose or bar_index == trendStart ? close : low
max_bars_back(hiSrc, 500)
max_bars_back(loSrc, 500)
float longRaw    = ta.highest(hiSrc, span) - mult * atrValue
float shortRaw   = ta.lowest(loSrc, span) + mult * atrValue[/pine]
Next, the trailing rule moves the stop. While a bullish trend continues, the long stop takes the higher of its previous value and the newly measured level, so it steps up as new highs form or volatility contracts, and holds its ground through pullbacks and expanding volatility instead of giving back distance. The short stop mirrors this during a bearish trend, stepping only downward. On the first bar of a new trend, the stop starts from the freshly measured level:
[pine]longStop  := signalState == 1 and prevState == 1 ? math.max(longRaw, prevLongStop) : longRaw
shortStop := signalState == -1 and prevState == -1 ? math.min(shortRaw, prevShortStop) : shortRaw
float activeStop = signalState == 1 ? longStop : signalState == -1 ? shortStop : na[/pine]
Finally, the state engine confirms trend changes. A bullish trend turns bearish when a bar closes below the previous bar's long stop, and a bearish trend turns bullish when a bar closes above the previous bar's short stop. The confirming bar becomes the first bar of the new trend, which resets the window the next extreme is measured from. States update on confirmed bars, so a confirmed trend change stays in place once the bar closes:
[pine]var int signalState = 0
var int trendStart  = 0
var float longStop  = na
var float shortStop = na
float prevLongStop  = longStop
float prevShortStop = shortStop

if barstate.isconfirmed
    int newState = signalState
    if signalState == 1 and close < prevLongStop
        newState := -1
    else if signalState == -1 and close > prevShortStop
        newState := 1
    else if signalState == 0
        newState := close > prevShortStop ? 1 : close < prevLongStop ? -1 : 0
    if newState != signalState
        signalState := newState
        trendStart  := bar_index[/pine]
[image]https://www.tradingview.com/x/eg0UdNKE/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Rising Stop Below Price with Bullish Color):[/b] When a close clears the short stop, a trend change point marks the start of a stop line below price, and the stop line and risk zone take on the bullish color, reading as buyers lifting price through the trailing stop that capped the prior decline. Treat this as a long bias with the stop as its invalidation level: pullbacks that hold above it leave the trend intact, and the bias ends on the first close beneath the long stop, which turns the trend bearish.

[b]▶ Bearish Trend (Falling Stop Above Price with Bearish Color): [/b]When a close breaks below the long stop, the trend change point and the stop line appear above price in the bearish color, reading as sellers pressing price beneath the trailing stop that supported the prior advance. Treat this as a short bias with the stop as its invalidation level: bounces that stall below it leave the trend intact, and the bias ends on the first close above the short stop, which turns the trend bullish.
[image]https://www.tradingview.com/x/8U7rXR3V/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets for different trading styles and timeframes. "Default" delivers balanced trend tracking for swing trading on 1H to daily charts, with the lookback period and ATR multiplier adjustable directly. "Fast Response" is built for intraday work on 5 minute to 1H charts, shortening the lookback and hanging the stop closer to the extreme so it trails price more tightly and trend changes confirm sooner. "Smooth Trend" is aimed at position style reading on daily and weekly charts, lengthening the lookback and hanging the stop farther from the extreme so trends hold through deeper pullbacks and change direction less often.
[image]https://www.tradingview.com/x/E9ZLS74K/[/image]
[b]▶ Built-in Alerts:[/b] Three alert conditions support hands off monitoring. "Bullish Trend Signal" fires on the bar that confirms a bullish trend by closing above the short stop. "Bearish Trend Signal" fires on the bar that confirms a bearish trend by closing below the long stop. "Any Trend Change" fires on either change. Alert messages include exchange, ticker, and timeframe for immediate context.
[image]https://www.tradingview.com/x/82mpEkef/[/image]
[b]▶ Visual Customization: [/b]Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) apply coordinated bullish and bearish colors to the stop line, stop glow, risk zone, trend change points, optional bar coloring, and optional background coloring. The bullish and bearish color pickers apply when Custom is selected. The glow, zone, trend change points, and both coloring options can each be toggled, with adjustable transparency for the bar and background tints, so the chart stays as clean or as expressive as the workflow requires.
[image]https://www.tradingview.com/x/JtZQOSoG/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator("Chandelier Exit Trend [QuantAlgo]", overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string chandelier_settings = "════════ Chandelier Settings ════════"
var string visual_settings     = "════════ Visualization Settings ════════"

tooltip_preset       = "Select a predefined configuration for different trading styles and timeframes. Fast Response and Smooth Trend set the Lookback Period and ATR Multiplier, overriding those inputs below. Use Close for Extremes and all visualization inputs keep their manual values."
tooltip_preset_det   = "Default: Uses the manual settings below, with the Lookback Period and ATR Multiplier adjustable directly. Suited to swing trading on 1H to daily charts.\n\nFast Response (Period 14, Multiplier 2.0): Shortens the lookback and hangs the stop closer to the extreme, so the stop trails price more tightly and trend changes confirm sooner. Suited to intraday trading on 5min to 1H charts.\n\nSmooth Trend (Period 30, Multiplier 4.0): Lengthens the lookback and hangs the stop farther from the extreme, so trends hold through deeper pullbacks and trend changes confirm less often. Suited to position trading on daily and weekly charts."
tooltip_period       = "Number of bars used for the Average True Range and the longest window searched for the extreme the stop hangs from. In a bullish trend the long stop hangs below the highest price reached since the trend began, and in a bearish trend the short stop sits above the lowest price reached since the trend began, counting back no more than this many bars. Each new trend measures from its own extreme, so the stop is not hung from highs or lows set before the trend began. Shorter periods (10-14) track recent volatility and fresh extremes closely, so the stop adjusts quickly. Longer periods (30-50) produce a steadier ATR and a wider window, so the stop moves more gradually."
tooltip_mult         = "Multiplier applied to the Average True Range to set how far the stop hangs from the extreme. A bar that closes beyond the stop confirms a trend change, so this controls how much room a trend has before it changes. Lower values (1.5-2.5) keep the stop close to price, giving quicker exits and more frequent trend changes. Higher values (3.5-5.0) give trends more room through pullbacks, producing fewer trend changes and longer-held trends."
tooltip_close        = "Enable/disable measuring the extremes from closing prices. When enabled, the stop hangs from the highest and lowest closes, so single-bar wicks do not move the stop. When disabled, the stop hangs from the highest high and lowest low, so it reacts to intrabar spikes and sits closer to price. On the bar where a new trend is confirmed, the stop is always measured from the close."
tooltip_color_preset = "Pre-configured color schemes for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean-inspired blue and orange. Cosmic offers futuristic cyan and purple. Cyber features cool cyan and warm orange contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Custom uses the Bullish and Bearish colors set below."
tooltip_bullish      = "Color applied to the stop line, stop glow, risk zone, trend change points, price bars, and background while the trend is bullish, which is confirmed on the bar that closes above the short stop. Use a vibrant color to highlight uptrend phases and potential long opportunities. Only used when Color Preset is set to Custom."
tooltip_bearish      = "Color applied to the stop line, stop glow, risk zone, trend change points, price bars, and background while the trend is bearish, which is confirmed on the bar that closes below the long stop. Use a warning color to highlight downtrend phases and potential short opportunities or exits. Only used when Color Preset is set to Custom."
tooltip_glow         = "Enable/disable the soft glow around the stop line. The glow brightens as price closes in on the stop and dims as price extends toward the extreme, so a trend under pressure stands out before the stop is reached. Disable for a thinner line that keeps the focus on price action."
tooltip_zone         = "Enable/disable the shading between price and the active stop. When enabled, the zone is filled with the current trend color, strongest at the stop and fading toward price, so the room left before a trend change is visible at a glance. The zone narrows as price approaches the stop and widens as price extends away from it."
tooltip_points       = "Enable/disable the glowing point that opens each new stop line. Each point sits on the bar where a bullish or bearish trend is confirmed, at the level where the new stop begins, so every stop line starts from a visible anchor. A trend that reverses on the very next bar draws no line and no point. Disable for an uncluttered chart where the stop line color, bar coloring, or alerts track the trend instead."
tooltip_barcolor     = "Enable/disable bar coloring based on the current trend. When enabled, price bars are tinted with the bullish or bearish color, providing instant visual confirmation of the trend without reading the stop line directly. Disable if you prefer default bar colors or use another bar coloring indicator."
tooltip_bartrans     = "Transparency of the bar coloring overlay. Lower values (0-30) produce vivid, fully saturated bars that make the trend immediately obvious. Higher values (70-90) apply a subtle tint that shows the trend without overwhelming price action. Only applies when Enable Bar Coloring is turned on."
tooltip_bgcolor      = "Enable/disable background coloring based on the current trend. When enabled, the chart background is shaded with the bullish or bearish color, highlighting each trend across the full height of the chart. Disable if you prefer a clean chart background or use another background coloring indicator."
tooltip_bgtrans      = "Transparency of the background coloring. Lower values (50-70) produce strong shading that makes each trend stand out immediately. Higher values (85-95) apply a subtle tint that keeps price action and other chart elements easy to read. Only applies when Enable Background Coloring is turned on."

presetMode  = input.string("Default", "Preset Configuration", group = chandelier_settings, options = ["Default", "Fast Response", "Smooth Trend"], tooltip = tooltip_preset + "\n\n" + tooltip_preset_det)
periodIn    = input.int(22, "Lookback Period", group = chandelier_settings, minval = 2, maxval = 500, tooltip = tooltip_period)
multIn      = input.float(3.0, "ATR Multiplier", group = chandelier_settings, minval = 0.5, step = 0.25, tooltip = tooltip_mult)
useClose    = input.bool(true, "Use Close for Extremes", group = chandelier_settings, tooltip = tooltip_close)

colorPreset = input.string("Custom", "Color Preset", group = visual_settings, options = ["Custom", "Classic", "Aqua", "Cosmic", "Cyber", "Neon"], tooltip = tooltip_color_preset)
bullCustom  = input.color(#00ffaa, "Bullish Color", group = visual_settings, tooltip = tooltip_bullish)
bearCustom  = input.color(#ff0000, "Bearish Color", group = visual_settings, tooltip = tooltip_bearish)
showGlow    = input.bool(true, "Show Stop Glow", group = visual_settings, tooltip = tooltip_glow)
showZone    = input.bool(true, "Show Risk Zone", group = visual_settings, tooltip = tooltip_zone)
showPoints  = input.bool(true, "Show Trend Change Points", group = visual_settings, tooltip = tooltip_points)
colorBars   = input.bool(false, "Enable Bar Coloring", group = visual_settings, tooltip = tooltip_barcolor)
barTrans    = input.int(0, "Bar Color Transparency", group = visual_settings, minval = 0, maxval = 100, tooltip = tooltip_bartrans)
colorBg     = input.bool(false, "Enable Background Coloring", group = visual_settings, tooltip = tooltip_bgcolor)
bgTrans     = input.int(90, "Background Color Transparency", group = visual_settings, minval = 0, maxval = 100, tooltip = tooltip_bgtrans)

//              ╔════════════════════════════════╗              //
//              ║      PRESET CONFIGURATION      ║              //
//              ╚════════════════════════════════╝              //

int per = switch presetMode
    "Fast Response" => 14
    "Smooth Trend" => 30
    => periodIn

float mult = switch presetMode
    "Fast Response" => 2.0
    "Smooth Trend" => 4.0
    => multIn

//              ╔════════════════════════════════╗              //
//              ║        CHANDELIER ENGINE       ║              //
//              ╚════════════════════════════════╝              //

float atrValue = ta.atr(per)

var int signalState = 0
var int trendStart  = 0
var float longStop  = na
var float shortStop = na
float prevLongStop  = longStop
float prevShortStop = shortStop

if barstate.isconfirmed
    int newState = signalState
    if signalState == 1 and close < prevLongStop
        newState := -1
    else if signalState == -1 and close > prevShortStop
        newState := 1
    else if signalState == 0
        newState := close > prevShortStop ? 1 : close < prevLongStop ? -1 : 0
    if newState != signalState
        signalState := newState
        trendStart  := bar_index

int prevState    = nz(signalState[1])
int span         = math.max(1, math.min(per, bar_index - trendStart + 1))
float hiSrc      = useClose or bar_index == trendStart ? close : high
float loSrc      = useClose or bar_index == trendStart ? close : low
max_bars_back(hiSrc, 500)
max_bars_back(loSrc, 500)
float longRaw    = ta.highest(hiSrc, span) - mult * atrValue
float shortRaw   = ta.lowest(loSrc, span) + mult * atrValue
longStop  := signalState == 1 and prevState == 1 ? math.max(longRaw, prevLongStop) : longRaw
shortStop := signalState == -1 and prevState == -1 ? math.min(shortRaw, prevShortStop) : shortRaw
float activeStop = signalState == 1 ? longStop : signalState == -1 ? shortStop : na

//              ╔════════════════════════════════╗              //
//              ║          SIGNAL ENGINE         ║              //
//              ╚════════════════════════════════╝              //

bool turnedBull    = signalState == 1 and prevState != 1
bool turnedBear    = signalState == -1 and prevState != -1
bool signalChanged = turnedBull or turnedBear

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

[bullCol, bearCol] = switch colorPreset
    "Classic" => [#00ff00, #ff0000]
    "Aqua" => [#00d4ff, #ff8c00]
    "Cosmic" => [#49ffce, #9932cc]
    "Cyber" => [#00cccc, #ff6600]
    "Neon" => [#ffff00, #ff00ff]
    => [bullCustom, bearCustom]

color signalColor    = signalState == 1 ? bullCol : signalState == -1 ? bearCol : chart.fg_color
bool sameTrend       = signalState == prevState
bool lineStart       = sameTrend and prevState != nz(signalState[2])
float pressure       = math.max(0.0, math.min(1.0, nz(1.0 - signalState * (close - activeStop) / (mult * atrValue))))
bool stopAbove       = activeStop > ohlc4
color stopSideColor  = color.new(signalColor, showZone ? 72 : 100)
color priceSideColor = color.new(signalColor, 100)

plot(showGlow ? activeStop : na, "Stop Halo", sameTrend ? color.new(signalColor, 90 - 15 * pressure) : na, 10, editable = false, display = display.pane)
plot(showGlow ? activeStop : na, "Stop Glow", sameTrend ? color.new(signalColor, 78 - 28 * pressure) : na, 5, editable = false, display = display.pane)
plot(activeStop, "Chandelier Stop", sameTrend ? signalColor : na, 2, display = display.pane)
plot(activeStop, "Stop Level", signalColor, editable = false, display = display.all - display.pane)
pricePlot    = plot(ohlc4, "Price Reference", display = display.none, editable = false)
bullZonePlot = plot(signalState == 1 ? activeStop : na, "Bullish Zone Edge", display = display.none, editable = false)
bearZonePlot = plot(signalState == -1 ? activeStop : na, "Bearish Zone Edge", display = display.none, editable = false)
fill(pricePlot, bullZonePlot, top_value = math.max(ohlc4, activeStop), bottom_value = math.min(ohlc4, activeStop), top_color = stopAbove ? stopSideColor : priceSideColor, bottom_color = stopAbove ? priceSideColor : stopSideColor, title = "Bullish Risk Zone")
fill(pricePlot, bearZonePlot, top_value = math.max(ohlc4, activeStop), bottom_value = math.min(ohlc4, activeStop), top_color = stopAbove ? stopSideColor : priceSideColor, bottom_color = stopAbove ? priceSideColor : stopSideColor, title = "Bearish Risk Zone")
plot(showPoints and lineStart ? activeStop[1] : na, "Trend Change Halo", color.new(signalColor, 80), 12, plot.style_circles, offset = -1, editable = false, display = display.pane)
plot(showPoints and lineStart ? activeStop[1] : na, "Trend Change Point", signalColor, 6, plot.style_circles, offset = -1, display = display.pane)

barcolor(colorBars and signalState != 0 ? color.new(signalColor, barTrans) : na, title = "Trend Bar Color")
bgcolor(colorBg and signalState != 0 ? color.new(signalColor, bgTrans) : na, title = "Trend Background Color")

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turnedBull, title = "Bullish Trend Signal", message = "Chandelier Exit Trend: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(turnedBear, title = "Bearish Trend Signal", message = "Chandelier Exit Trend: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(signalChanged, title = "Any Trend Change", message = "Chandelier Exit Trend: Trend signal changed on {{exchange}}:{{ticker}} - {{interval}}")

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
