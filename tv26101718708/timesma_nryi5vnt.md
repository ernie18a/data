# TimeSMA

- url: https://www.tradingview.com/script/NryI5VNT-TimeSMA/
- type: indicator
- pine_id: PUB;3922db28ebed42778572421891ea9c04
- version: 1.0

## Description

This is a GREAT SCRIPT.  You can now easily view a daily moving average on ANY timeframe, - daily, 2h, 30m, 45sec, etc.

[b]The Problem with a Standard SMA[/b]

A 20 SMA on a daily chart averages the last 20 trading days. Switch to a 30m chart and that same "20 SMA" now covers only 10 hours. It's no longer a 20-day SMA — it's just 20 candles of whatever timeframe you're on.

[b]The Fix[/b]

Enable Time-Based mode and set Length to 20. Now it's a true 20-day SMA on every timeframe — daily, 2h, 30m, or 5m. The script automatically calculates how many bars are needed to represent exactly 20 trading days.

[b]Features[/b]

[list=*]
[*]Time-Based mode toggle — works as a standard SMA when disabled
[*]Vertical line marking the oldest bar included in the calculation
[*]Bull/bear background shading
[*]Edge case warnings for monthly timeframes
[*]
[/list]

## Source Code

````pine
//@version=6
indicator("TimeSMA", overlay=true)

// Simple Moving Average - Any Timeframe
// 
// By default, an SMA's Length counts candles — so a "20 SMA" means 
// something different on a 5M chart vs 1D chart.
// 
// This script adds an optional Time-Based mode where Length represents
// trading days instead, so the MA always covers the same time span
// regardless of which timeframe you're viewing.



// SECTION: functions
// must be declared first so can be used in script
getTFLabel() => 
    string result = ""
    if timeframe.isseconds
        result := str.tostring(timeframe.multiplier) + "s"
    else if timeframe.isminutes and timeframe.multiplier >= 60
        result := str.tostring(timeframe.multiplier / 60) + "h"    
    else if timeframe.isminutes
        result := str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isdaily
        result := str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        result := str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        result := str.tostring(timeframe.multiplier) + "M"
    else
        result := timeframe.period
    result // returns timeframe label like 30m, 4hr, 1D, etc.



// SECTION: user inputs
// -> basic MA inputs, these are found in the default TV MA script
int length = input.int(5, title="Length", minval=1)
float src = input.source(close, title="Source")


// -> Use Time-Based Length inputs
bool useTimeLength = input.bool(false, "Use Time-Based Moving Average", 
    group="Time-Based Moving Average Settings",
    tooltip="A 20 SMA means something different on a 30m chart vs 1D chart. Enable this to use Length as time rather than candles, so the SMA always covers the same time span in every timeframe.\n\nCurrently only supports using length in days."
)
bool disableWatermark = input.bool(false, "Disable Watermark", 
    active=useTimeLength, group="Time-Based Moving Average Settings",
    tooltip="Hides the Time-Based Moving Average watermark."
)
bool disableMonthWarning = input.bool(false, "Disable Month Timeframe Warning", 
    active=useTimeLength, group="Time-Based Moving Average Settings",
    tooltip="Hides the monthly timeframe warning that MA values are approximate."
)


// -> Vertical line lookback inputs
bool showVertLine = input.bool(false, "Show Vertical Line at First MA Candle",
    group="Vertical Line Appearance",
    tooltip="Marks the oldest candle with a vertical line included in the moving average calculation."
)
color VLineColor = input.color(color.blue, title="Line Color & Opacity", 
    active=showVertLine, group="Vertical Line Appearance",
    tooltip="The MA line color is set in the Style tab.  If you change it there, update this color to keep both lines consistent."
)
string VLineStyle = input.string("Dotted", title="Line Style", 
    active=showVertLine, group="Vertical Line Appearance",
    options=["Solid", "Dashed", "Dotted"] 
)
int VLineWidth = input.int(2, title="Line Thickness (1-4)", 
    active=showVertLine, group="Vertical Line Appearance",
    minval=1, maxval=4
)

// -> Background Shadow inputs
bool showShading = input.bool(false, "Show Background Shading", group="Background Shading", tooltip="Highlights whether price is trading above (bullish) or below (bearish) the MA.")
color bullColor = input.color(color.new(color.green, 70), title="Bull Color", group="Background Shading", active=showShading)
color bearColor = input.color(color.new(color.red, 70), title="Bear Color", group="Background Shading", active=showShading)

// -> Debuging input
bool debug = input.bool(false, title="Show Debug Label")





// SECTION: main  
// Convert current timeframe to minutes per bar
float minsPerBar = timeframe.multiplier * (
    timeframe.isminutes ? 1.0 :
    timeframe.isdaily ? 390.0 :
    timeframe.isweekly ? 390.0 * 5 :
    timeframe.ismonthly ? 390.0 * 21.5 : // 21.5 is avg trading days per month.
    na
)
if na(minsPerBar)
    runtime.error("Unsupported timeframe: " + getTFLabel())


// 390 trading mins/day * length
int adjustedLength = useTimeLength ? math.round(390 * length / minsPerBar) : length
if useTimeLength and adjustedLength < 1 // occurs when length is short and use monthly TF
    int minLength = math.ceil(minsPerBar / 390 * 0.5)
    runtime.error("A length of " + str.tostring(length) + " days is too short for the " + getTFLabel() + " timeframe - it results in less than 1 bar. Need a least a length of " + str.tostring(minLength) + " days.")
if useTimeLength and adjustedLength > 5000 // occurs when length is long and on 1s - 1m TF
    runtime.error("A length of " + str.tostring(length) + " days on the " + getTFLabel() + " timeframe requires " + str.tostring(adjustedLength) + " bars, which exceeds Pine Script's 5000 bar limit. Try a shorter length or higher timeframe.")


float ma = ta.sma(src, adjustedLength)

maPlot = plot(
    ma,
    color=color.blue,
    title="Moving Average",
    linestyle=plot.linestyle_solid,
    linewidth=2
)

// background shading code
// first plot invisible price line (keep hidden, required by fill())
invisiblePricePlot = plot(
    close, 
    title="Invisible Price", 
    color=na, 
    display=display.none
)
fill(maPlot, invisiblePricePlot, 
    color=showShading ? (close > ma ? bullColor : bearColor) : na)


// show Vertical Lookback Line
var line vLine = na
string vStyle = na
if VLineStyle == "Solid"
    vStyle := line.style_solid
else if VLineStyle == "Dotted"
    vStyle := line.style_dotted
else
    vStyle := line.style_dashed

if barstate.islast and showVertLine
    if not na(vLine)
        line.delete(vLine)

    vLine := line.new(
        x1=bar_index - adjustedLength,
        y1=low,
        x2=bar_index - adjustedLength,
        y2=high,
        color=VLineColor,
        width=VLineWidth,
        style=vStyle,
        extend=extend.both
    )













// SECTION: labels and debug code
var label debugLabel = na
if barstate.islast and debug
    if not na(debugLabel) 
        label.delete(debugLabel)

    debugLabel := label.new(
        bar_index, 
        high, 
        "*** Debug Information *** " +
        "\n-> User Length Input = " + str.tostring(length) + 
        "\n-> Chart Interval = " + getTFLabel() + 
        "\n-> MA uses " + str.tostring(adjustedLength) + " bars",
        style=label.style_label_left,
        color=color.black, 
        textalign=text.align_left,
        textcolor=color.white
    )

var label warningLabel = na
if timeframe.ismonthly and barstate.islast and useTimeLength and not disableMonthWarning
    if not na(warningLabel)
        label.delete(warningLabel)

    warningLabel := label.new(
        bar_index, 
        high,
        "⚠️ Warning:\n\n" +
        "Monthly timeframe MA values are approximate.\n" + 
        "Month length varies (28-31), so the calculation\n" +
        "uses a fixed average of 21.5 trading days per month.\n\n" +
        "(can disable warning in settings)",
        style=label.style_label_left,
        color=color.yellow,
        textalign=text.align_left,
        textcolor=color.black
    )

var table watermark = table.new(position.top_center, 1, 2)
if barstate.islast and useTimeLength and not disableWatermark
    table.cell(
        watermark, 0, 0,
        "⚡ Time-Based Moving Average ⚡",
        text_color=color.new(color.orange, 30),
        text_size=size.large
    )
    table.cell(
        watermark, 0, 1,
        "(disable watermark in settings)",
        text_color=color.new(color.orange, 50),
        text_size=size.small
    )
````
