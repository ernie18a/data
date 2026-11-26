# Range Filter Trend [QuantAlgo]

- url: https://www.tradingview.com/script/h9iJIm2v-Range-Filter-Trend-QuantAlgo/
- type: indicator
- pine_id: PUB;32a0b7b797e245139f59bf01f178ccb1
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Range Filter Trend[/b] indicator tracks the direction of price through a step filter that only moves when price travels beyond an adaptive noise range. For each bar it measures the absolute bar-to-bar movement of the source, smooths that movement in two passes with a selectable moving average, scales it by a multiplier, and holds the filter flat until the source pushes beyond that range from the filter's previous value. Every step of the filter confirms the trend direction, range bands frame the zone price must break, an optional neutral state grays out extended flat stretches, and trend change markers with state based coloring make direction readable at a glance across any timeframe and instrument.
[image]https://www.tradingview.com/x/RWAB4thW/[/image]
[b]🟢 How It Works[/b]

The indicator is built around a stepped range filter: the filter value carries forward unchanged until the source closes beyond one range width from it, then jumps to the source minus or plus the range. It has three stages: range construction from smoothed bar-to-bar movement, the step rule that produces the filter and its bands, and a state engine that reads trend direction from the filter's steps.

First, the range is built. The absolute change of the source from one bar to the next is averaged over the sampling period and then smoothed again over roughly twice that length, so a single wide bar cannot swing the range on its own. The smoothing type is selectable, and every average is computed on every bar before the chosen one is applied, keeping the internal history of each moving average consistent:
[pine]smoothRange(float src, simple int len, string maType) =>
    float ema1    = ta.ema(src, len)
    float ema2    = ta.ema(ema1, len)
    float ema3    = ta.ema(ema2, len)
    float smaVal  = ta.sma(src, len)
    float wmaVal  = ta.wma(src, len)
    float hmaVal  = ta.hma(src, len)
    float rmaVal  = ta.rma(src, len)
    float vwmaVal = ta.vwma(src, len)
    float lsmaVal = ta.linreg(src, len, 0)
    float almaVal = ta.alma(src, len, 0.85, 6.0)
    switch maType
        "SMA"  => smaVal
        "WMA"  => wmaVal
        "HMA"  => hmaVal
        "RMA"  => rmaVal
        "DEMA" => 2.0 * ema1 - ema2
        "TEMA" => 3.0 * (ema1 - ema2) + ema3
        "VWMA" => vwmaVal
        "LSMA" => lsmaVal
        "ALMA" => almaVal
        => ema1

float rawRange = math.abs(srcInput - srcInput[1])
float avgRange = smoothRange(rawRange, per, smoothingType)
float smRng    = smoothRange(avgRange, per * 2 - 1, smoothingType) * mult[/pine]
Next, the step rule produces the filter. When the source sits above the previous filter value, the filter rises only if the source minus the range clears that previous value, and it rises to exactly the source minus the range. The mirror rule applies below. Otherwise the filter holds flat. The range bands sit one range above and below the filter and mark the exact levels the next close must exceed for the filter to move:
[pine]var float filt = na
float prevFilt = nz(filt[1], srcInput)
filt := na(smRng) ? srcInput : srcInput > prevFilt ? (srcInput - smRng < prevFilt ? prevFilt : srcInput - smRng) : (srcInput + smRng > prevFilt ? prevFilt : srcInput + smRng)
float hBand = filt + smRng
float lBand = filt - smRng[/pine]
Finally, the state engine reads direction from the steps. An upward step confirms a bullish trend and a downward step confirms a bearish trend, each held until the filter steps the opposite way. With the neutral state enabled, a trend releases to neutral once the filter has stayed flat for the Range Bars count, and the next step of the filter confirms a fresh trend. States update on confirmed bars, so a confirmed trend change stays in place once the bar closes:
[pine]bool steppedUp   = filt > prevFilt
bool steppedDown = filt < prevFilt

var int flatBars = 0
flatBars := na(smRng) ? 0 : steppedUp or steppedDown ? 0 : flatBars + 1

var int signalState = 0

if barstate.isconfirmed and not na(smRng)
    if steppedUp and signalState != 1
        signalState := 1
    else if steppedDown and signalState != -1
        signalState := -1
    else if useNeutral and signalState != 0 and flatBars >= rangeBars
        signalState := 0[/pine]
[image]https://www.tradingview.com/x/5CdREbmx/[/image]
[b]🟢 Signal Interpretation[/b]

[b]▶ Bullish Trend (Upward Filter Step with Bullish Color):[/b] When the filter steps up, the line, bands, and fill switch to the bullish color, reading as buyers pushing price beyond the noise range. Treat this as a long bias: strongest on the marker bar itself, or on pullbacks that hold inside the band without dragging the filter down. Bias ends when price closes below the lower band, which steps the filter down and flips the state.

[b]▶ Bearish Trend (Downward Filter Step with Bearish Color):[/b] When the filter steps down, the line, bands, and fill switch to the bearish color, reading as sellers driving price through the noise range. Treat this as a short bias: strongest on the marker bar itself, or on bounces that fail inside the band without lifting the filter. Bias ends when price closes above the upper band, which steps the filter up and flips the state.

[b]▶ Neutral State (Optional, Flat Filter in Neutral Color):[/b] With Use Neutral State enabled, a trend that goes quiet releases to the neutral color once the filter has held flat for the Range Bars count. This separates ranging stretches from active trends: price is oscillating inside the band without the strength to move the filter. The next step in either direction confirms a fresh trend and prints a new marker.
[image]https://www.tradingview.com/x/kkIYIIPw/[/image]
[b]🟢 Features[/b]

[b]▶ Preconfigured Presets:[/b] Three parameter sets tuned for different trading styles and timeframes. "Default" delivers balanced trend tracking for swing trading on 1H to daily charts, with the sampling period, range multiplier, and range bars adjustable directly. "Fast Response" is built for intraday work on 5 minute to 1H charts, shortening the sampling period and narrowing the range so the filter follows price more closely and trend changes confirm sooner. "Smooth Trend" is aimed at position style reading on daily charts, lengthening the sampling period and widening the range so the filter rides through larger swings and changes state less often.
[image]https://www.tradingview.com/x/9JhRi9bG/[/image]
[b]▶ Built-in Alerts:[/b] Four alert conditions support hands off monitoring. "Bullish Trend Signal" fires on the bar an upward step confirms a bullish trend. "Bearish Trend Signal" fires on the bar a downward step confirms a bearish trend. "Neutral State" fires when an active trend releases to neutral. "Any Trend Change" fires on any state change. Alert messages include exchange, ticker, and timeframe for immediate context.
[image]https://www.tradingview.com/x/sOV8VvYr/[/image]
[b]▶ Visual Customization:[/b] Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, and Custom) apply coordinated bullish, bearish, and neutral colors to the filter line, range bands, band fill, markers, optional bar coloring, and optional background coloring. Custom unlocks independent bullish, bearish, and neutral color pickers. Line width, range bands, band fill, trend change markers, bar coloring, and background coloring can each be adjusted or toggled so the chart stays as clean or as expressive as the workflow requires.
[image]https://www.tradingview.com/x/p1wJ5exE/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator("Range Filter Trend [QuantAlgo]", overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string filter_settings = "════════ Range Filter Settings ════════"
var string visual_settings = "════════ Visualization Settings ════════"

tooltip_preset        = "Select a predefined configuration for different trading styles and timeframes. Fast Response and Smooth Trend set the Sampling Period, Range Multiplier, and Range Bars, overriding those inputs below. Price Source, Smoothing Type, Use Neutral State, and all visualization inputs keep their manual values."
tooltip_preset_det    = "Default: Uses the manual settings below, with the Sampling Period, Range Multiplier, and Range Bars adjustable directly. Suited to swing trading on 1H to daily charts.\n\nFast Response (Period 50, Multiplier 2.0, Range Bars 10): Shortens the sampling period, narrows the range, and releases to neutral after shorter pauses, so the filter follows price more closely and trend changes confirm sooner. Suited to intraday trading on 5min to 1H charts.\n\nSmooth Trend (Period 200, Multiplier 4.0, Range Bars 30): Lengthens the sampling period, widens the range, and holds trends through longer pauses, so the filter rides through larger swings and trend changes confirm less often. Suited to position trading on daily charts."
tooltip_src           = "Price series the filter follows and from which the bar-to-bar movement is measured. Close uses the final price of each bar, while hl2, hlc3, and ohlc4 average more of each bar's range, producing a smoother path with smaller bar-to-bar movement and a proportionally narrower range."
tooltip_smoothing     = "Moving average applied in two passes to the absolute bar-to-bar movement of the price source, producing the range the filter responds to. EMA weights recent movement more heavily and adapts at a moderate pace. SMA weights every bar in the window equally and produces the steadiest range. WMA applies linearly increasing weights toward the newest bars. HMA reduces lag substantially and reacts quickly to changes in movement. RMA applies lighter weighting to recent bars than EMA, producing a smoother and slower-adjusting range. DEMA and TEMA apply successive exponential passes to reduce lag, with TEMA the more responsive of the two. VWMA weights each bar's movement by its volume and depends on the symbol providing volume data. LSMA fits a linear regression across the window and follows changes in movement with little lag. ALMA applies a Gaussian weighting shifted toward recent bars, balancing smoothness and responsiveness. Faster types let the range expand and contract with volatility sooner, so the filter adjusts quickly after regime changes. Smoother types hold the range steadier, so the filter's behavior changes more gradually."
tooltip_period        = "Lookback for the average bar-to-bar movement that sets the filter's range. The movement is averaged over this many bars and smoothed again over roughly twice that length, so the range reflects a sustained level of movement rather than a single bar. Shorter periods (20-50) let the range track recent volatility closely, so the filter adjusts quickly when conditions shift. Longer periods (150-300) produce a steadier range that changes gradually, keeping the filter's behavior consistent across longer stretches."
tooltip_mult          = "Multiplier applied to the smoothed average movement to set the range on each side of the filter. The filter only moves when the price source travels beyond this range from the filter's previous value, so movement inside the range is ignored. Lower values (1.0-2.0) produce a narrow range that lets the filter follow price closely, with more frequent steps and more frequent trend changes. Higher values (4.0-6.0) produce a wide range that requires a larger move before the filter follows, giving fewer steps and longer-held trends."
tooltip_neutral_state = "Enable/disable the neutral state. When enabled, a bullish or bearish trend releases to neutral once the filter has stayed flat for the number of bars set by Range Bars, and the filter line switches to the neutral color. A flat filter means price has stayed inside the range without pushing it in either direction, so this separates ranging stretches from active trends. The next step of the filter confirms a fresh trend in that direction. When disabled, each trend holds until the filter steps the opposite way, so every bar after the first confirmed trend is classified as bullish or bearish."
tooltip_range_bars    = "Number of consecutive bars the filter must stay flat before an active trend releases to neutral. Pauses shorter than this stay in the current trend, so brief pullbacks that fail to move the filter do not interrupt it. Lower values (5-10) release to neutral quickly and mark even short consolidations as ranges. Higher values (30-50) hold the trend through longer pauses and reserve neutral for extended consolidations. Only active when Use Neutral State is enabled."
tooltip_color_preset  = "Pre-configured color schemes for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean-inspired blue and orange. Cosmic offers futuristic cyan and purple. Cyber features cool cyan and warm orange contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Custom uses the Bullish, Bearish, and Neutral colors set below, while all other presets use gray for the neutral state."
tooltip_bullish       = "Color applied to the filter line, range bands, band fill, trend change markers, price bars, and background while the trend is bullish, which is confirmed on the bar where the filter steps upward. Use a vibrant color to highlight uptrend phases and potential long opportunities. Only used when Color Preset is set to Custom."
tooltip_bearish       = "Color applied to the filter line, range bands, band fill, trend change markers, price bars, and background while the trend is bearish, which is confirmed on the bar where the filter steps downward. Use a warning color to highlight downtrend phases and potential short opportunities or exits. Only used when Color Preset is set to Custom."
tooltip_neutral_color = "Color applied to the filter line, range bands, band fill, price bars, and background while the state is neutral, which covers ranging stretches where the filter has stayed flat for the Range Bars count and the warm-up period before the first trend is confirmed. Gray is recommended as a neutral cue that clearly separates ranging phases from directional trends. Only used when Color Preset is set to Custom."
tooltip_line_width    = "Thickness of the filter line. The line steps only when the price source moves beyond the range, and its color reflects the current state. Lower values (1-2) keep the line clean alongside price action. Higher values (4-6) make each step and color change easier to follow on busy charts. The range bands use their own fixed width."
tooltip_bands         = "Enable/disable the range bands plotted one range above and below the filter. The bands mark the zone the price source must leave for the filter to move, so a bar closing outside them is the bar that steps the filter. Disable for a cleaner chart that shows the filter line alone."
tooltip_fill          = "Enable/disable the shading between the range bands. When enabled, the zone is filled with the current state color, strongest at the band edges and fading toward the filter line, so the boundaries price must break to move the filter stand out. Only applies when Show Range Bands is turned on."
tooltip_markers       = "Enable/disable the triangle markers printed on the bar where a bullish or bearish trend is confirmed, below the bar for bullish and above the bar for bearish. A trend confirmed after a neutral stretch prints a marker as well. Disable for an uncluttered chart where the filter color, bar coloring, or alerts track the trend instead."
tooltip_barcolor      = "Enable/disable bar coloring based on the current state. When enabled, price bars are tinted with the bullish, bearish, or neutral color, providing instant visual confirmation of the state without reading the filter line directly. Disable if you prefer default bar colors or use another bar coloring indicator."
tooltip_bartrans      = "Transparency of the bar coloring overlay. Lower values (0-30) produce vivid, fully saturated bars that make the state immediately obvious. Higher values (70-90) apply a subtle tint that shows the state without overwhelming price action. Only applies when Enable Bar Coloring is turned on."
tooltip_bgcolor       = "Enable/disable background coloring based on the current state. When enabled, the chart background is shaded with the bullish, bearish, or neutral color, highlighting each phase across the full height of the chart. Disable if you prefer a clean chart background or use another background coloring indicator."
tooltip_bgtrans       = "Transparency of the background coloring. Lower values (50-70) produce strong shading that makes each phase stand out immediately. Higher values (85-95) apply a subtle tint that keeps price action and other chart elements easy to read. Only applies when Enable Background Coloring is turned on."

presetMode    = input.string("Default", "Preset Configuration", group = filter_settings, options = ["Default", "Fast Response", "Smooth Trend"], tooltip = tooltip_preset + "\n\n" + tooltip_preset_det)
srcInput      = input.source(close, "Price Source", group = filter_settings, tooltip = tooltip_src)
smoothingType = input.string("EMA", "Smoothing Type", group = filter_settings, options = ["EMA", "SMA", "WMA", "HMA", "RMA", "DEMA", "TEMA", "VWMA", "LSMA", "ALMA"], tooltip = tooltip_smoothing)
periodIn      = input.int(100, "Sampling Period", group = filter_settings, minval = 2, maxval = 1000, tooltip = tooltip_period)
multIn        = input.float(3.0, "Range Multiplier", group = filter_settings, minval = 0.5, step = 0.25, tooltip = tooltip_mult)
useNeutral    = input.bool(false, "Use Neutral State", group = filter_settings, tooltip = tooltip_neutral_state)
rangeBarsIn   = input.int(20, "Range Bars", group = filter_settings, minval = 1, maxval = 500, tooltip = tooltip_range_bars)

colorPreset   = input.string("Custom", "Color Preset", group = visual_settings, options = ["Custom", "Classic", "Aqua", "Cosmic", "Cyber", "Neon"], tooltip = tooltip_color_preset)
bullCustom    = input.color(#00ffaa, "Bullish Color", group = visual_settings, tooltip = tooltip_bullish)
bearCustom    = input.color(#ff0000, "Bearish Color", group = visual_settings, tooltip = tooltip_bearish)
neutCustom    = input.color(#808080, "Neutral Color", group = visual_settings, tooltip = tooltip_neutral_color)
lineWidth     = input.int(3, "Line Width", group = visual_settings, minval = 1, maxval = 8, tooltip = tooltip_line_width)
showBands     = input.bool(true, "Show Range Bands", group = visual_settings, tooltip = tooltip_bands)
showFill      = input.bool(true, "Show Band Fill", group = visual_settings, tooltip = tooltip_fill)
showMarkers   = input.bool(true, "Show Trend Change Markers", group = visual_settings, tooltip = tooltip_markers)
colorBars     = input.bool(false, "Enable Bar Coloring", group = visual_settings, tooltip = tooltip_barcolor)
barTrans      = input.int(20, "Bar Color Transparency", group = visual_settings, minval = 0, maxval = 100, tooltip = tooltip_bartrans)
colorBg       = input.bool(false, "Enable Background Coloring", group = visual_settings, tooltip = tooltip_bgcolor)
bgTrans       = input.int(90, "Background Color Transparency", group = visual_settings, minval = 0, maxval = 100, tooltip = tooltip_bgtrans)

//              ╔════════════════════════════════╗              //
//              ║      PRESET CONFIGURATION      ║              //
//              ╚════════════════════════════════╝              //

int per = switch presetMode
    "Fast Response" => 50
    "Smooth Trend" => 200
    => periodIn

float mult = switch presetMode
    "Fast Response" => 2.0
    "Smooth Trend" => 4.0
    => multIn

int rangeBars = switch presetMode
    "Fast Response" => 10
    "Smooth Trend" => 30
    => rangeBarsIn

//              ╔════════════════════════════════╗              //
//              ║      RANGE FILTER ENGINE       ║              //
//              ╚════════════════════════════════╝              //

smoothRange(float src, simple int len, string maType) =>
    float ema1    = ta.ema(src, len)
    float ema2    = ta.ema(ema1, len)
    float ema3    = ta.ema(ema2, len)
    float smaVal  = ta.sma(src, len)
    float wmaVal  = ta.wma(src, len)
    float hmaVal  = ta.hma(src, len)
    float rmaVal  = ta.rma(src, len)
    float vwmaVal = ta.vwma(src, len)
    float lsmaVal = ta.linreg(src, len, 0)
    float almaVal = ta.alma(src, len, 0.85, 6.0)
    switch maType
        "SMA"  => smaVal
        "WMA"  => wmaVal
        "HMA"  => hmaVal
        "RMA"  => rmaVal
        "DEMA" => 2.0 * ema1 - ema2
        "TEMA" => 3.0 * (ema1 - ema2) + ema3
        "VWMA" => vwmaVal
        "LSMA" => lsmaVal
        "ALMA" => almaVal
        => ema1

float rawRange = math.abs(srcInput - srcInput[1])
float avgRange = smoothRange(rawRange, per, smoothingType)
float smRng    = smoothRange(avgRange, per * 2 - 1, smoothingType) * mult

var float filt = na
float prevFilt = nz(filt[1], srcInput)
filt := na(smRng) ? srcInput : srcInput > prevFilt ? (srcInput - smRng < prevFilt ? prevFilt : srcInput - smRng) : (srcInput + smRng > prevFilt ? prevFilt : srcInput + smRng)
float hBand = filt + smRng
float lBand = filt - smRng

//              ╔════════════════════════════════╗              //
//              ║          SIGNAL ENGINE         ║              //
//              ╚════════════════════════════════╝              //

bool steppedUp   = filt > prevFilt
bool steppedDown = filt < prevFilt

var int flatBars = 0
flatBars := na(smRng) ? 0 : steppedUp or steppedDown ? 0 : flatBars + 1

var int signalState = 0

if barstate.isconfirmed and not na(smRng)
    if steppedUp and signalState != 1
        signalState := 1
    else if steppedDown and signalState != -1
        signalState := -1
    else if useNeutral and signalState != 0 and flatBars >= rangeBars
        signalState := 0

int prevState      = nz(signalState[1])
bool turnedBull    = signalState == 1 and prevState != 1
bool turnedBear    = signalState == -1 and prevState != -1
bool turnedNeut    = signalState == 0 and prevState != 0
bool signalChanged = turnedBull or turnedBear or turnedNeut

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

[bullCol, bearCol, neutCol] = switch colorPreset
    "Classic" => [#00ff00, #ff0000, #808080]
    "Aqua" => [#00d4ff, #ff8c00, #808080]
    "Cosmic" => [#49ffce, #9932cc, #808080]
    "Cyber" => [#00cccc, #ff6600, #808080]
    "Neon" => [#ffff00, #ff00ff, #808080]
    => [bullCustom, bearCustom, neutCustom]

color signalColor = signalState == 1 ? bullCol : signalState == -1 ? bearCol : neutCol

color filtSideColor = color.new(signalColor, 100)
color bandSideColor = color.new(signalColor, showFill ? 80 : 100)

filtPlot  = plot(filt, "Range Filter", color.new(signalColor, 0), lineWidth)
upperPlot = plot(showBands ? hBand : na, "Upper Range Band", color.new(signalColor, 70), 1)
lowerPlot = plot(showBands ? lBand : na, "Lower Range Band", color.new(signalColor, 70), 1)
fill(filtPlot, upperPlot, top_value = hBand, bottom_value = filt, top_color = bandSideColor, bottom_color = filtSideColor, title = "Upper Band Fill")
fill(lowerPlot, filtPlot, top_value = filt, bottom_value = lBand, top_color = filtSideColor, bottom_color = bandSideColor, title = "Lower Band Fill")
plotshape(showMarkers and turnedBull, "Bullish Trend Change", shape.triangleup, location.belowbar, bullCol, size = size.small)
plotshape(showMarkers and turnedBear, "Bearish Trend Change", shape.triangledown, location.abovebar, bearCol, size = size.small)

barcolor(colorBars ? color.new(signalColor, barTrans) : na, title = "Trend Bar Color")
bgcolor(colorBg ? color.new(signalColor, bgTrans) : na, title = "Trend Background Color")

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

alertcondition(turnedBull, title = "Bullish Trend Signal", message = "Range Filter Trend: BULLISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(turnedBear, title = "Bearish Trend Signal", message = "Range Filter Trend: BEARISH trend confirmed on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(turnedNeut, title = "Neutral State", message = "Range Filter Trend: NEUTRAL state on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(signalChanged, title = "Any Trend Change", message = "Range Filter Trend: Trend signal changed on {{exchange}}:{{ticker}} - {{interval}}")

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
