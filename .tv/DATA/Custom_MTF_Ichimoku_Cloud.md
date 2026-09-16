<!-- tradingview-pine-id: PUB;526e56b534d340daa6ff8756a5e0338c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Custom MTF Ichimoku Cloud

Source: https://www.tradingview.com/script/HmAXxPyk-Custom-Multi-Timeframe-MTF-Ichimoku-Cloud-Clean-Minimalist/

## Description

Welcome to the Custom MTF Ichimoku Cloud, an optimized and decluttered version of the traditional Ichimoku Kinko Hyo indicator.

Designed for traders who love the comprehensive trend analysis of the Ichimoku system but want to avoid the typical visual noise, this script strips away the unnecessary elements while adding powerful Multi-Timeframe (MTF) capabilities.

Key Features
Multi-Timeframe (MTF) Power: Want to see the 5-minute trend while timing your entries on a 1-minute chart? Now you can. The built-in MTF functionality allows you to set the indicator to a higher timeframe than your current chart, giving you a macro perspective without switching views.

Decluttered & Minimalist View:

No Lagging Span: The Chikou Span has been removed to keep your price action front and center.

Seamless Cloud: The harsh upper and lower boundary lines (Senkou Span A & B) have been hidden. You only see a clean, smooth cloud fill, reducing visual fatigue.

Fully Customizable Aesthetics: Every visual aspect is in your control. Easily tweak the colors, line thicknesses, and timeframes directly from the settings menu.

Default Styling
Right out of the box, this indicator is tuned for a sleek, modern look that works great on both light and dark themes:

Base Line (Kijun-sen): Dark Navy, distinct and thick (Thickness: 3) to clearly define the medium-term trend.

Conversion Line (Tenkan-sen): Orange, slightly thinner (Thickness: 2) to easily track short-term momentum.

The Cloud (Kumo): A subtle, dark gray fill with 70% transparency. It provides clear support/resistance zones without overpowering your candlesticks.

How to Use It
Trend Identification: If price is above the MTF cloud, the macro trend is bullish. If below, it is bearish.

Dynamic Support/Resistance: Use the clean cloud as a zone of interest for pullbacks.

Crossovers: Watch for the Orange Conversion Line to cross the Navy Base Line for potential entry signals in the direction of the macro trend.

Whether you are a scalper looking for higher timeframe confluence, or a swing trader wanting a cleaner chart, this custom MTF Ichimoku provides the perfect balance of data and aesthetics.

(Note: Go to the indicator settings (gear icon) to change the timeframe, colors, or line thicknesses to fit your exact trading style!)

---

## Source Code

````pine
//@version=6
indicator(title="Custom MTF Ichimoku Cloud", shorttitle="MTF Ichimoku", overlay=true)

// ==============================================================================
// 1. INPUTS
// ==============================================================================

// -- Timeframe --
// Default empty string ("") means it will use the current chart's timeframe.
tf = input.timeframe("", title="Indicator Timeframe")

// -- Ichimoku Periods --
conversionPeriods   = input.int(9, minval=1, title="Conversion Line Periods")
basePeriods         = input.int(26, minval=1, title="Base Line Periods")
laggingSpan2Periods = input.int(52, minval=1, title="Lagging Span 2 Periods")
displacement        = input.int(26, minval=1, title="Displacement (Offset)")

// -- Colors & Thickness Defaults --
grp_style = "Colors & Line Thickness"

col_conv   = input.color(color.orange, title="Conversion Line Color", group=grp_style)
thick_conv = input.int(2, title="Conversion Line Thickness", minval=1, maxval=4, group=grp_style)

col_base   = input.color(color.navy, title="Base Line Color", group=grp_style)
thick_base = input.int(3, title="Base Line Thickness", minval=1, maxval=4, group=grp_style) 

// Darker shade with 70% transparency (70 in Pine represents 70% transparent)
col_cloud_fill  = input.color(color.new(#555555, 70), title="Cloud Fill Color", group=grp_style) 

// ==============================================================================
// 2. LOGIC & CALCULATIONS
// ==============================================================================

// Donchian channel calculation (Average of Highest High and Lowest Low)
donchian(len) => math.avg(ta.lowest(len), ta.highest(len))

// Base Ichimoku calculations
conversionLine = donchian(conversionPeriods)
baseLine       = donchian(basePeriods)
leadLine1      = math.avg(conversionLine, baseLine)
leadLine2      = donchian(laggingSpan2Periods)

// Fetching Multi-Timeframe Data
[mtf_conversion, mtf_base, mtf_lead1, mtf_lead2] = request.security(syminfo.tickerid, tf, [conversionLine, baseLine, leadLine1, leadLine2])

// ==============================================================================
// 3. PLOTTING
// ==============================================================================

// Plotting Conversion and Base Lines
plot(mtf_conversion, color=col_conv, linewidth=thick_conv, title="Conversion Line")
plot(mtf_base, color=col_base, linewidth=thick_base, title="Base Line")

// Plotting Cloud Lines (Senkou Span A and B) with displacement
// display=display.none completely hides the upper/lower lines while allowing the fill() to still work
p1 = plot(mtf_lead1, offset=displacement - 1, display=display.none, title="Senkou Span A")
p2 = plot(mtf_lead2, offset=displacement - 1, display=display.none, title="Senkou Span B")

// Filling the Cloud
fill(p1, p2, color=col_cloud_fill, title="Cloud Background")
````
