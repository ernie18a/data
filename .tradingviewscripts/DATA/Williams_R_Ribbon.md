<!-- tradingview-pine-id: PUB;3f69f8fdc452457ab0ec7b5024908179 -->
<!-- tradingviewscripts-format: 1 -->
# Williams %R Ribbon

Source: https://www.tradingview.com/script/XFTxyrvH-Williams-R-Ribbon/

## Description

[image]https://www.tradingview.com/x/9JAxOEau/[/image]

Williams %R Ribbon

Most traders know Williams %R as a classic overbought/oversold oscillator. Unfortunately, many stop there.

The Williams %R Ribbon reimagines this well-known indicator into a modern visualization designed to make momentum, trend transitions, and market extension easier to read at a glance. Instead of focusing solely on fixed overbought and oversold levels, this indicator emphasizes the relationship between Williams %R and its signal line, transforming that relationship into an intuitive gradient ribbon that helps reveal changes in market structure before they become obvious.

Features

Momentum Ribbon

The traditional Williams %R line is transformed into a dynamic ribbon that expands, contracts, and changes color based on the relationship between Williams %R and its signal line.

[*]Bullish momentum is displayed with a green ribbon.
[*]Bearish momentum is displayed with a red ribbon.
[*]Neutral conditions automatically fade to gray when momentum becomes indecisive.

The ribbon allows traders to recognize momentum shifts without constantly watching for line crossovers.

Multi-Timeframe Analysis

Analyze higher timeframe Williams %R values directly on lower timeframe charts.

Choose from:

[*]Chart Timeframe
[*]2× Chart Timeframe
[*]4× Chart Timeframe
[*]Manual Timeframe Selection
[*]

This makes it possible to monitor higher-timeframe momentum while executing trades on lower timeframes without adding multiple indicators to the chart.

Optional Display Smoothing

The ribbon includes display-only smoothing designed to reduce visual stair-stepping that naturally occurs when displaying higher timeframe calculations on lower timeframe charts.

Importantly:

[*]Indicator calculations remain unchanged.
[*]Signal generation remains unchanged.
[*]Alerts continue using the original data.
[*]

Only the visual appearance of the ribbon is smoothed.

Extension Grade

Instead of simply identifying whether Williams %R is overbought or oversold, the indicator continuously classifies the current level into extension categories such as:

[*]Moderately Extended
[*]Extended
[*]Very Extended
[*]Extremely Extended
[*]

This provides additional context regarding how far price has stretched relative to its recent trading range.

Flexible Display Modes

Choose the visualization that best fits your trading style.

Available display modes include:

[*]Ribbon
[*]Signal Line Only
[*]Solid Signal Line Only
[*]Ribbon + Signal Line

Whether you prefer a clean minimalist chart or a full ribbon visualization, the indicator adapts to your workflow.

Dynamic Coloring

The ribbon automatically adjusts its colors based on current market conditions.

Strong bullish momentum receives brighter bullish colors.

Strong bearish momentum receives brighter bearish colors.

Neutral conditions fade naturally, helping reduce visual noise during consolidation.

Built-In Alerts

Alerts are included for:

[*]Bullish ribbon crosses
[*]Bearish ribbon crosses
[*]Oversold exits
[*]Overbought exits
[*]All Extension Grade thresholds

Because alerts use the original unsmoothed Williams %R values, visual smoothing never delays signal generation.

Designed for Clarity

Many oscillators overwhelm traders with unnecessary visual clutter.

The goal of this indicator is the opposite.

Every design decision was made with one objective:

Help traders understand what the oscillator is communicating as quickly as possible.

The gradient ribbon allows momentum, trend direction, and market extension to be interpreted almost instantly while maintaining the familiar foundation of the classic Williams %R.

Best Used For

[*]Trend confirmation
[*]Multi-timeframe analysis
[*]Momentum analysis
[*]Mean reversion strategies
[*]Swing trading
[*]Identifying overextended markets
[*]Building rule-based trading systems

Disclaimer

This indicator is provided for educational and informational purposes only. It does not constitute financial, investment, legal, or tax advice and should not be considered a recommendation to buy or sell any financial instrument.

No indicator can predict future market movements or guarantee profitable results. Market conditions change continuously, and all trading involves risk, including the potential loss of all invested capital.

Past performance does not guarantee future results. Always perform your own analysis, practice sound risk management, and consult a qualified financial professional if you require investment advice.

---

## Source Code

````pine
//@version=6
indicator(
     title = "Williams %R Ribbon",
     shorttitle = "W%R Ribbon",
     overlay = false,
     format = format.price,
     precision = 2,
     explicit_plot_zorder = true
)

//──────────────────────────────────────────────────────────────────────
// TIMEFRAME SETTINGS
//──────────────────────────────────────────────────────────────────────

timeframeMode = input.string(
     "4× Chart",
     "Indicator Timeframe Mode",
     options = ["Chart", "2× Chart", "4× Chart", "Manual"],
     tooltip = "Automatically multiplies the chart timeframe. Examples: 5m × 4 = 20m and 1H × 4 = 4H.",
     group = "Timeframe Settings"
)

manualTimeframe = input.timeframe(
     "240",
     "Manual Timeframe",
     tooltip = "Used only when Indicator Timeframe Mode is set to Manual.",
     group = "Timeframe Settings",
     active = timeframeMode == "Manual"
)

//──────────────────────────────────────────────────────────────────────
// WILLIAMS %R SETTINGS
//──────────────────────────────────────────────────────────────────────

src = input.source(
     close,
     "Source",
     group = "Williams %R Settings"
)

williamsLength = input.int(
     14,
     "Williams %R Lookback",
     minval = 1,
     tooltip = "Number of indicator-timeframe bars used for the highest-high and lowest-low range.",
     group = "Williams %R Settings"
)

//──────────────────────────────────────────────────────────────────────
// SIGNAL SETTINGS
//──────────────────────────────────────────────────────────────────────

signalMaType = input.string(
     "RMA",
     "Signal Moving Average",
     options = ["EMA", "SMA", "WMA", "RMA", "HMA", "VWMA", "ALMA"],
     group = "Signal Settings"
)

signalLength = input.int(
     7,
     "Ribbon Signal Smoothing",
     minval = 1,
     tooltip = "Lower values react faster. Higher values create a smoother ribbon.",
     group = "Signal Settings"
)

almaOffset = input.float(
     0.85,
     "ALMA Offset",
     minval = 0.0,
     maxval = 1.0,
     step = 0.05,
     group = "Signal Settings"
)

almaSigma = input.float(
     6.0,
     "ALMA Sigma",
     minval = 0.1,
     step = 0.1,
     group = "Signal Settings"
)

neutralSpread = input.float(
     2.0,
     "Neutral Spread Threshold",
     minval = 0.0,
     step = 0.25,
     tooltip = "The ribbon turns neutral when Williams %R and its signal are this close together.",
     group = "Signal Settings"
)

//──────────────────────────────────────────────────────────────────────
// DISPLAY SMOOTHING
//──────────────────────────────────────────────────────────────────────

useVisualSmoothing = input.bool(
     true,
     "Smooth Ribbon Appearance",
     tooltip = "Softens higher-timeframe stair steps. Alerts continue to use the original unsmoothed values.",
     group = "Display Smoothing"
)

visualSmoothingType = input.string(
     "EMA",
     "Visual Smoothing Type",
     options = ["EMA", "SMA", "WMA", "RMA"],
     group = "Display Smoothing"
)

visualSmoothingLength = input.int(
     2,
     "Visual Smoothing Length",
     minval = 1,
     tooltip = "A value of 2 provides light visual smoothing.",
     group = "Display Smoothing"
)

//──────────────────────────────────────────────────────────────────────
// EXTREME LEVELS
//──────────────────────────────────────────────────────────────────────

overboughtLevel = input.float(
     -20.0,
     "Overbought Level",
     minval = -100.0,
     maxval = 0.0,
     step = 1.0,
     group = "Extreme Levels"
)

middleLevel = input.float(
     -50.0,
     "Middle Level",
     minval = -100.0,
     maxval = 0.0,
     step = 1.0,
     group = "Extreme Levels"
)

oversoldLevel = input.float(
     -80.0,
     "Oversold Level",
     minval = -100.0,
     maxval = 0.0,
     step = 1.0,
     group = "Extreme Levels"
)

//──────────────────────────────────────────────────────────────────────
// EXTENSION GRADE LEVELS
// Williams %R is bounded from -100 to 0. The closer it moves to either
// boundary, the more extended price is relative to its lookback range.
//──────────────────────────────────────────────────────────────────────

upperModerateLevel = input.float(
     -20.0,
     "Overbought Moderately Extended",
     minval = -50.0,
     maxval = 0.0,
     step = 1.0,
     tooltip = "At or above this level, Williams %R is moderately extended on the overbought side.",
     group = "Extension Grade Levels"
)

upperExtendedLevel = input.float(
     -15.0,
     "Overbought Extended",
     minval = -50.0,
     maxval = 0.0,
     step = 1.0,
     tooltip = "At or above this level, Williams %R is extended on the overbought side.",
     group = "Extension Grade Levels"
)

upperVeryExtendedLevel = input.float(
     -10.0,
     "Overbought Very Extended",
     minval = -50.0,
     maxval = 0.0,
     step = 1.0,
     tooltip = "At or above this level, Williams %R is very extended on the overbought side.",
     group = "Extension Grade Levels"
)

upperExtremelyExtendedLevel = input.float(
     -5.0,
     "Overbought Extremely Extended",
     minval = -50.0,
     maxval = 0.0,
     step = 1.0,
     tooltip = "At or above this level, Williams %R is extremely extended near its upper boundary.",
     group = "Extension Grade Levels"
)

lowerModerateLevel = input.float(
     -80.0,
     "Oversold Moderately Extended",
     minval = -100.0,
     maxval = -50.0,
     step = 1.0,
     tooltip = "At or below this level, Williams %R is moderately extended on the oversold side.",
     group = "Extension Grade Levels"
)

lowerExtendedLevel = input.float(
     -85.0,
     "Oversold Extended",
     minval = -100.0,
     maxval = -50.0,
     step = 1.0,
     tooltip = "At or below this level, Williams %R is extended on the oversold side.",
     group = "Extension Grade Levels"
)

lowerVeryExtendedLevel = input.float(
     -90.0,
     "Oversold Very Extended",
     minval = -100.0,
     maxval = -50.0,
     step = 1.0,
     tooltip = "At or below this level, Williams %R is very extended on the oversold side.",
     group = "Extension Grade Levels"
)

lowerExtremelyExtendedLevel = input.float(
     -95.0,
     "Oversold Extremely Extended",
     minval = -100.0,
     maxval = -50.0,
     step = 1.0,
     tooltip = "At or below this level, Williams %R is extremely extended near its lower boundary.",
     group = "Extension Grade Levels"
)

//──────────────────────────────────────────────────────────────────────
// EXTENSION GRADE DISPLAY
//──────────────────────────────────────────────────────────────────────

showExtensionGrade = input.bool(
     true,
     "Show Extension Grade",
     tooltip = "Displays the current Williams %R extension zone in the top-right corner.",
     group = "Extension Grade"
)

showGradeValue = input.bool(
     true,
     "Show Current Williams %R Value",
     group = "Extension Grade"
)

gradeTextSizeInput = input.string(
     "Normal",
     "Grade Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = "Extension Grade"
)

//──────────────────────────────────────────────────────────────────────
// APPEARANCE
//──────────────────────────────────────────────────────────────────────

bullColor = input.color(
     #26C6B8,
     "Bullish Color",
     group = "Appearance"
)

bearColor = input.color(
     #A83A68,
     "Bearish Color",
     group = "Appearance"
)

neutralColor = input.color(
     #667582,
     "Neutral Color",
     group = "Appearance"
)

bullExtremeColor = input.color(
     #67F5C4,
     "Bullish Extreme Color",
     group = "Appearance"
)

bearExtremeColor = input.color(
     #FF4F87,
     "Bearish Extreme Color",
     group = "Appearance"
)

gradientTransparency = input.int(
     35,
     "Gradient Transparency",
     minval = 0,
     maxval = 100,
     group = "Appearance"
)

displayMode = input.string(
     "Ribbon",
     "Display Mode",
     options = [
          "Ribbon",
          "Signal Line Only",
          "Solid Signal Line Only",
          "Ribbon + Signal Line"
     ],
     tooltip = "Choose whether the indicator displays the ribbon, a dynamically colored signal line, a solid-color signal line, or the ribbon and signal line together.",
     group = "Appearance"
)

signalLineWidth = input.int(
     2,
     "Signal Line Width",
     minval = 1,
     maxval = 5,
     group = "Appearance",
     active = displayMode != "Ribbon"
)

solidSignalColor = input.color(
     color.white,
     "Solid Signal Line Color",
     group = "Appearance",
     active = displayMode == "Solid Signal Line Only"
)

showZoneShading = input.bool(
     true,
     "Shade Extreme Zones",
     group = "Appearance"
)

showMiddleBackground = input.bool(
     false,
     "Shade Middle Range",
     group = "Appearance"
)

//──────────────────────────────────────────────────────────────────────
// SIGNAL DISPLAY
//──────────────────────────────────────────────────────────────────────

showCrossDots = input.bool(
     false,
     "Show Ribbon Cross Dots",
     group = "Signals"
)

showExtremeExitDots = input.bool(
     false,
     "Show Extreme Exit Dots",
     tooltip = "Shows a bullish dot when %R exits oversold and a bearish dot when %R exits overbought.",
     group = "Signals"
)

//──────────────────────────────────────────────────────────────────────
// MOVING-AVERAGE FUNCTIONS
//──────────────────────────────────────────────────────────────────────

f_hma(_source, _length) =>
    halfLength = math.max(1, int(math.round(_length / 2.0)))
    sqrtLength = math.max(1, int(math.round(math.sqrt(_length))))
    ta.wma(2.0 * ta.wma(_source, halfLength) - ta.wma(_source, _length), sqrtLength)

f_signalMa(_source, _length) =>
    switch signalMaType
        "EMA"  => ta.ema(_source, _length)
        "SMA"  => ta.sma(_source, _length)
        "WMA"  => ta.wma(_source, _length)
        "RMA"  => ta.rma(_source, _length)
        "HMA"  => f_hma(_source, _length)
        "VWMA" => ta.vwma(_source, _length)
        "ALMA" => ta.alma(_source, _length, almaOffset, almaSigma)
        => ta.rma(_source, _length)

f_visualMa(_source, _length) =>
    switch visualSmoothingType
        "EMA" => ta.ema(_source, _length)
        "SMA" => ta.sma(_source, _length)
        "WMA" => ta.wma(_source, _length)
        "RMA" => ta.rma(_source, _length)
        => ta.ema(_source, _length)

f_gradeTextSize() =>
    string result = size.normal

    if gradeTextSizeInput == "Tiny"
        result := size.tiny
    else if gradeTextSizeInput == "Small"
        result := size.small
    else if gradeTextSizeInput == "Large"
        result := size.large

    result

//──────────────────────────────────────────────────────────────────────
// AUTOMATIC TIMEFRAME SELECTION
//──────────────────────────────────────────────────────────────────────

chartSeconds = timeframe.in_seconds()

string selectedTimeframe = timeframe.period

if timeframeMode == "2× Chart"
    selectedTimeframe := timeframe.from_seconds(int(chartSeconds * 2.0))

if timeframeMode == "4× Chart"
    selectedTimeframe := timeframe.from_seconds(int(chartSeconds * 4.0))

if timeframeMode == "Manual"
    selectedTimeframe := manualTimeframe

//──────────────────────────────────────────────────────────────────────
// WILLIAMS %R CALCULATION
//──────────────────────────────────────────────────────────────────────

f_percentR() =>
    highestPrice = ta.highest(high, williamsLength)
    lowestPrice = ta.lowest(low, williamsLength)
    priceRange = highestPrice - lowestPrice

    if priceRange != 0.0
        100.0 * (src - highestPrice) / priceRange
    else
        -50.0

f_percentRSignal() =>
    value = f_percentR()
    f_signalMa(value, signalLength)

// Williams %R and its signal are both calculated inside the selected
// timeframe so the signal uses genuine higher-timeframe bars.

rawPercentR = request.security(
     syminfo.tickerid,
     selectedTimeframe,
     f_percentR(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

rawSignal = request.security(
     syminfo.tickerid,
     selectedTimeframe,
     f_percentRSignal(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//──────────────────────────────────────────────────────────────────────
// OPTIONAL DISPLAY-ONLY SMOOTHING
//──────────────────────────────────────────────────────────────────────

// Keep the actual indicator values nearly untouched.
percentR = useVisualSmoothing ? f_visualMa(rawPercentR, visualSmoothingLength) : rawPercentR
signal   = useVisualSmoothing ? f_visualMa(rawSignal, visualSmoothingLength) : rawSignal

//──────────────────────────────────────────────────────────────────────
// RIBBON STATE
//──────────────────────────────────────────────────────────────────────

spread = math.abs(percentR - signal)

isNeutral = spread < neutralSpread
isBull = percentR > signal and not isNeutral
isBear = percentR < signal and not isNeutral

inOversoldArea   = math.min(percentR, signal) <= oversoldLevel
inOverboughtArea = math.max(percentR, signal) >= overboughtLevel

color activeColor = neutralColor

if isBull
    activeColor := inOversoldArea ? bullExtremeColor : bullColor
else if isBear
    activeColor := inOverboughtArea ? bearExtremeColor : bearColor

//──────────────────────────────────────────────────────────────────────
// DISPLAY-ONLY RIBBON SMOOTHING
//──────────────────────────────────────────────────────────────────────

rawTop    = math.max(percentR, signal)
rawBottom = math.min(percentR, signal)

// The more reactive 2× mode receives a slightly stronger second pass.
// The already-smoother 4× mode keeps a lighter second pass.
secondarySmoothingLength =
     timeframeMode == "2× Chart" ? 3 :
     timeframeMode == "4× Chart" ? 2 :
     2

topValue = useVisualSmoothing
     ? f_visualMa(f_visualMa(rawTop, visualSmoothingLength), secondarySmoothingLength)
     : rawTop

bottomValue = useVisualSmoothing
     ? f_visualMa(f_visualMa(rawBottom, visualSmoothingLength), secondarySmoothingLength)
     : rawBottom

//──────────────────────────────────────────────────────────────────────
// REFERENCE LEVELS
//──────────────────────────────────────────────────────────────────────

upperBoundary = hline(
     0.0,
     "Upper Boundary",
     color = color.new(neutralColor, 85),
     linestyle = hline.style_solid
)

overboughtLine = hline(
     overboughtLevel,
     "Overbought",
     color = color.new(bearExtremeColor, 35),
     linestyle = hline.style_solid
)

middleLine = hline(
     middleLevel,
     "Middle Level",
     color = color.new(neutralColor, 65),
     linestyle = hline.style_dotted
)

oversoldLine = hline(
     oversoldLevel,
     "Oversold",
     color = color.new(bullExtremeColor, 35),
     linestyle = hline.style_solid
)

lowerBoundary = hline(
     -100.0,
     "Lower Boundary",
     color = color.new(neutralColor, 85),
     linestyle = hline.style_solid
)

//──────────────────────────────────────────────────────────────────────
// ZONE SHADING
//──────────────────────────────────────────────────────────────────────

fill(
     upperBoundary,
     overboughtLine,
     title = "Overbought Zone",
     color = showZoneShading ? color.new(bearColor, 93) : na
)

fill(
     oversoldLine,
     lowerBoundary,
     title = "Oversold Zone",
     color = showZoneShading ? color.new(bullColor, 93) : na
)

fill(
     overboughtLine,
     oversoldLine,
     title = "Middle Range Background",
     color = showMiddleBackground ? color.new(neutralColor, 96) : na
)

//──────────────────────────────────────────────────────────────────────
// GRADIENT RIBBON
//──────────────────────────────────────────────────────────────────────

topPlot = plot(
     topValue,
     title = "Ribbon Top",
     display = display.none
)

bottomPlot = plot(
     bottomValue,
     title = "Ribbon Bottom",
     display = display.none
)

showRibbon =
     displayMode == "Ribbon" or
     displayMode == "Ribbon + Signal Line"

showDynamicSignal =
     displayMode == "Signal Line Only" or
     displayMode == "Ribbon + Signal Line"

showSolidSignal =
     displayMode == "Solid Signal Line Only"

fill(
     topPlot,
     bottomPlot,
     topValue,
     bottomValue,
     showRibbon ? color.new(activeColor, 85) : na,
     showRibbon ? color.new(activeColor, gradientTransparency) : na,
     title = "Williams %R Gradient Ribbon"
)

//──────────────────────────────────────────────────────────────────────
// DISPLAY MODE LINES
//──────────────────────────────────────────────────────────────────────

plot(
     showDynamicSignal ? signal : na,
     title = "Dynamic Signal Line",
     color = activeColor,
     linewidth = signalLineWidth
)

plot(
     showSolidSignal ? signal : na,
     title = "Solid Signal Line",
     color = solidSignalColor,
     linewidth = signalLineWidth
)

//──────────────────────────────────────────────────────────────────────
// EXTENSION GRADE
// The displayed Williams %R value is graded by its proximity to 0 or -100.
// This measures location extension, not ribbon direction.
//──────────────────────────────────────────────────────────────────────

string gradeName = "Neutral Range"
string gradeSide = "Neutral"
color gradeColor = neutralColor

if percentR >= upperModerateLevel
    gradeName := "Moderately Extended"
    gradeSide := "Overbought"
    gradeColor := color.new(bearColor, 18)

if percentR >= upperExtendedLevel
    gradeName := "Extended"
    gradeSide := "Overbought"
    gradeColor := bearColor

if percentR >= upperVeryExtendedLevel
    gradeName := "Very Extended"
    gradeSide := "Overbought"
    gradeColor := color.from_gradient(
         percentR,
         upperVeryExtendedLevel,
         upperExtremelyExtendedLevel,
         bearColor,
         bearExtremeColor
    )

if percentR >= upperExtremelyExtendedLevel
    gradeName := "Extremely Extended"
    gradeSide := "Overbought"
    gradeColor := bearExtremeColor

if percentR <= lowerModerateLevel
    gradeName := "Moderately Extended"
    gradeSide := "Oversold"
    gradeColor := color.new(bullColor, 18)

if percentR <= lowerExtendedLevel
    gradeName := "Extended"
    gradeSide := "Oversold"
    gradeColor := bullColor

if percentR <= lowerVeryExtendedLevel
    gradeName := "Very Extended"
    gradeSide := "Oversold"
    gradeColor := color.from_gradient(
         percentR,
         lowerVeryExtendedLevel,
         lowerExtremelyExtendedLevel,
         bullColor,
         bullExtremeColor
    )

if percentR <= lowerExtremelyExtendedLevel
    gradeName := "Extremely Extended"
    gradeSide := "Oversold"
    gradeColor := bullExtremeColor

string gradeValueText = ""

if showGradeValue
    gradeValueText := "(" + str.tostring(percentR, "#.0") + ")"

gradeTextSize = f_gradeTextSize()

var table gradeTable = table.new(
     position.top_right,
     1,
     3,
     border_width = 0,
     frame_width = 0
)

if barstate.islast
    table.clear(gradeTable, 0, 0, 0, 2)

    if showExtensionGrade
        panelBackground = color.rgb(18, 20, 24)

        table.cell(
             gradeTable,
             0,
             0,
             "EXTENSION GRADE",
             text_color = color.new(color.white, 15),
             text_size = size.small,
             bgcolor = panelBackground,
             text_halign = text.align_center
        )

        string gradeDisplay = gradeName == "Neutral Range"
             ? "Neutral Range"
             : gradeSide + " • " + gradeName

        table.cell(
             gradeTable,
             0,
             1,
             gradeDisplay,
             text_color = gradeColor,
             text_size = gradeTextSize,
             bgcolor = panelBackground,
             text_halign = text.align_center
        )

        table.cell(
             gradeTable,
             0,
             2,
             gradeValueText,
             text_color = color.new(gradeColor, 15),
             text_size = size.small,
             bgcolor = panelBackground,
             text_halign = text.align_center
        )

//──────────────────────────────────────────────────────────────────────
// SIGNAL CONDITIONS
// Unsmoothed values are used so visual smoothing does not delay alerts.
//──────────────────────────────────────────────────────────────────────

bullCross = ta.crossover(rawPercentR, rawSignal)
bearCross = ta.crossunder(rawPercentR, rawSignal)

bullExtremeExit = ta.crossover(rawPercentR, oversoldLevel)
bearExtremeExit = ta.crossunder(rawPercentR, overboughtLevel)

//──────────────────────────────────────────────────────────────────────
// SIGNAL DOTS
//──────────────────────────────────────────────────────────────────────

plotshape(
     showCrossDots and bullCross ? rawSignal : na,
     title = "Bullish Ribbon Cross",
     style = shape.circle,
     location = location.absolute,
     size = size.tiny,
     color = bullExtremeColor
)

plotshape(
     showCrossDots and bearCross ? rawSignal : na,
     title = "Bearish Ribbon Cross",
     style = shape.circle,
     location = location.absolute,
     size = size.tiny,
     color = bearExtremeColor
)

plotshape(
     showExtremeExitDots and bullExtremeExit ? rawPercentR : na,
     title = "Bullish Oversold Exit",
     style = shape.circle,
     location = location.absolute,
     size = size.small,
     color = bullExtremeColor
)

plotshape(
     showExtremeExitDots and bearExtremeExit ? rawPercentR : na,
     title = "Bearish Overbought Exit",
     style = shape.circle,
     location = location.absolute,
     size = size.small,
     color = bearExtremeColor
)

//──────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────

alertcondition(
     bullCross,
     title = "Williams Ribbon Bullish Cross",
     message = "Williams %R crossed above its signal moving average."
)

alertcondition(
     bearCross,
     title = "Williams Ribbon Bearish Cross",
     message = "Williams %R crossed below its signal moving average."
)

alertcondition(
     bullExtremeExit,
     title = "Williams Ribbon Exited Oversold",
     message = "Williams %R crossed above the oversold level."
)

alertcondition(
     bearExtremeExit,
     title = "Williams Ribbon Exited Overbought",
     message = "Williams %R crossed below the overbought level."
)

// Extension-grade alerts use the original unsmoothed Williams %R values.
alertcondition(
     ta.crossover(rawPercentR, upperModerateLevel),
     title = "Williams Overbought Moderately Extended",
     message = "Williams %R entered the overbought Moderately Extended range."
)

alertcondition(
     ta.crossover(rawPercentR, upperExtendedLevel),
     title = "Williams Overbought Extended",
     message = "Williams %R entered the overbought Extended range."
)

alertcondition(
     ta.crossover(rawPercentR, upperVeryExtendedLevel),
     title = "Williams Overbought Very Extended",
     message = "Williams %R entered the overbought Very Extended range."
)

alertcondition(
     ta.crossover(rawPercentR, upperExtremelyExtendedLevel),
     title = "Williams Overbought Extremely Extended",
     message = "Williams %R entered the overbought Extremely Extended range."
)

alertcondition(
     ta.crossunder(rawPercentR, lowerModerateLevel),
     title = "Williams Oversold Moderately Extended",
     message = "Williams %R entered the oversold Moderately Extended range."
)

alertcondition(
     ta.crossunder(rawPercentR, lowerExtendedLevel),
     title = "Williams Oversold Extended",
     message = "Williams %R entered the oversold Extended range."
)

alertcondition(
     ta.crossunder(rawPercentR, lowerVeryExtendedLevel),
     title = "Williams Oversold Very Extended",
     message = "Williams %R entered the oversold Very Extended range."
)

alertcondition(
     ta.crossunder(rawPercentR, lowerExtremelyExtendedLevel),
     title = "Williams Oversold Extremely Extended",
     message = "Williams %R entered the oversold Extremely Extended range."
)
````
