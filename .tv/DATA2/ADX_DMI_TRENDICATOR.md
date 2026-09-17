<!-- tradingview-pine-id: PUB;783f1b523c1d4e3e946376d1ea246249 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ADX / DMI(+)(-) TRENDICATOR

Source: https://www.tradingview.com/script/e0cYPlWZ-ADX-DMI-TRENDICATOR/

## Description

## Draft Description

**ADX / DMI(+)(-) TRENDICATOR** is a responsive trend-strength and directional-momentum indicator designed to complement an **8 EMA / 20 EMA trading system**.

It combines:

- **ADX** to measure trend strength
- **DI+** to measure bullish directional pressure
- **DI−** to measure bearish directional pressure
- **20 and 40 ADX levels** to identify developing and strong trends
- **Angel Crosses** when DI+ crosses above DI−
- **Death Crosses** when DI− crosses above DI+
- Confirmed-candle alerts designed to avoid intrabar repainting

The default calculation settings use an **8-period DI length** and **8-period ADX smoothing** for a faster response to recent price candles. All calculation settings remain adjustable for different markets and timeframes.

The indicator includes customizable:

- ADX, DI+, and DI− visibility
- ADX and DI line widths
- Line, stepline, and circle plot styles
- Indicator colors
- Horizontal level visibility and styles
- ADX alert threshold
- Directional DI fill

Use ADX to determine whether a market is trending, then use DI+ and DI− to identify the dominant directional pressure. For example, a bullish EMA alignment combined with DI+ above DI− and ADX above 20 may indicate strengthening bullish momentum.

## How It Differs From Typical ADX/DMI Indicators

### 1. Confirmed-candle behavior

Many indicators react to changing intrabar values, causing temporary crosses or signals that can disappear before the candle closes. This indicator commits ADX, DI+, and DI− values only after candle confirmation, helping prevent intrabar signal repainting.

### 2. Designed for faster EMA-based systems

The default **8/8 settings** are intended as a responsive starting point for an **8 EMA / 20 EMA trend system**, rather than relying exclusively on the traditional slower 14/14 settings.

### 3. Clearer trend-strength framework

The fixed **20 and 40 levels** provide a simple visual framework:

- Below 20: weak or ranging conditions
- Above 20: trend development or moderate strength
- Above 40: strong trend conditions

### 4. More complete customization

Instead of only changing colors, users can control visibility, line widths, plot styles, level styles, and directional fills directly from the settings panel.

### 5. Expanded alert system

The indicator includes confirmed alerts for:

- Angel Crosses
- Death Crosses
- ADX crossing above or below 20
- ADX crossing above or below 40
- ADX crossing the custom alert threshold

### 6. Direction and strength are separated

Unlike systems that treat ADX as a buy or sell signal, this indicator keeps the concepts separate:

- **ADX = strength**
- **DI+ / DI− = direction**
- **8 EMA / 20 EMA = trend structure**

This helps reduce the common mistake of interpreting a rising ADX alone as a bullish signal.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("ADX / DMI(+)(-) TRENDICATOR", "ADX / DMI(+)(-) TRENDICATOR", precision = 2)

// --- Constants ---
string GROUP_CALCULATION = "Calculation"
string GROUP_VISIBILITY = "Visibility"
string GROUP_STYLE = "Style"
float ADX_WEAK_LEVEL = 20.0
float ADX_STRONG_LEVEL = 40.0

// --- Inputs ---
int diLengthInput = input.int(8, "DI length", minval = 1, tooltip = "Number of bars used to calculate DI+ and DI-. Lower values react faster.", group = GROUP_CALCULATION)
int adxSmoothingInput = input.int(8, "ADX smoothing", minval = 1, tooltip = "Number of bars used to smooth ADX. Lower values react faster.", group = GROUP_CALCULATION)
float thresholdInput = input.float(20.0, "Alert threshold", minval = 0.0, step = 0.5, tooltip = "ADX level used by the threshold alert. The plotted reference levels remain fixed at 20 and 40.", group = GROUP_CALCULATION)

bool showAdxInput = input.bool(true, "Show ADX", tooltip = "Show or hide the ADX line.", group = GROUP_VISIBILITY)
bool showDiPlusInput = input.bool(true, "Show DI+", tooltip = "Show or hide the positive Directional Indicator line.", group = GROUP_VISIBILITY)
bool showDiMinusInput = input.bool(true, "Show DI-", tooltip = "Show or hide the negative Directional Indicator line.", group = GROUP_VISIBILITY)
bool showLevelsInput = input.bool(true, "Show 20 / 40 levels", tooltip = "Show or hide the horizontal ADX reference levels.", group = GROUP_VISIBILITY)
bool showFillInput = input.bool(true, "Show DI fill", tooltip = "Show or hide the directional fill between DI+ and DI-.", group = GROUP_VISIBILITY)

color adxColorInput = input.color(#5b9cf6, "ADX color", tooltip = "Color of the ADX line.", group = GROUP_STYLE)
color bullishColorInput = input.color(#089981, "DI+ color", tooltip = "Color of the DI+ line and bullish fill.", group = GROUP_STYLE)
color bearishColorInput = input.color(#f23645, "DI- color", tooltip = "Color of the DI- line and bearish fill.", group = GROUP_STYLE)
color levelsColorInput = input.color(#808080, "Levels color", tooltip = "Color of the 20 and 40 reference levels.", group = GROUP_STYLE)
int adxWidthInput = input.int(2, "ADX width", minval = 1, maxval = 5, tooltip = "Width of the ADX line.", group = GROUP_STYLE)
int diWidthInput = input.int(2, "DI width", minval = 1, maxval = 5, tooltip = "Width of the DI+ and DI- lines.", group = GROUP_STYLE)
string plotStyleInput = input.string("Line", "ADX / DI style", options = ["Line", "Stepline", "Circles"], tooltip = "Visual style used by the ADX, DI+, and DI- plots.", group = GROUP_STYLE)
string levelStyleInput = input.string("Dashed", "Level style", options = ["Solid", "Dashed", "Dotted"], tooltip = "Line style used by the 20 and 40 reference levels.", group = GROUP_STYLE)

// --- Core logic ---
[diPlusRaw, diMinusRaw, adxRaw] = ta.dmi(diLengthInput, adxSmoothingInput)

// Commit values only after the candle closes to prevent intrabar repainting.
var float diPlusConfirmed = na
var float diMinusConfirmed = na
var float adxConfirmed = na
if barstate.isconfirmed
    diPlusConfirmed := diPlusRaw
    diMinusConfirmed := diMinusRaw
    adxConfirmed := adxRaw

plotStyle = switch plotStyleInput
    "Stepline" => plot.style_stepline
    "Circles" => plot.style_circles
    => plot.style_line

levelStyle = switch levelStyleInput
    "Solid" => hline.style_solid
    "Dotted" => hline.style_dotted
    => hline.style_dashed

// --- Visual elements ---
diPlusPlot = plot(diPlusConfirmed, "DI+", color = showDiPlusInput ? bullishColorInput : na, linewidth = diWidthInput, style = plotStyle)
diMinusPlot = plot(diMinusConfirmed, "DI-", color = showDiMinusInput ? bearishColorInput : na, linewidth = diWidthInput, style = plotStyle)
plot(adxConfirmed, "ADX", color = showAdxInput ? adxColorInput : na, linewidth = adxWidthInput, style = plotStyle)
hline(ADX_STRONG_LEVEL, "40", color = levelsColorInput, linestyle = levelStyle, display = showLevelsInput ? display.all : display.none)
hline(ADX_WEAK_LEVEL, "20", color = levelsColorInput, linestyle = levelStyle, display = showLevelsInput ? display.all : display.none)

bool showDirectionalFill = showFillInput and showDiPlusInput and showDiMinusInput
color directionalFillColor = showDirectionalFill and not na(diPlusConfirmed) ? (diPlusConfirmed >= diMinusConfirmed ? color.new(bullishColorInput, 90) : color.new(bearishColorInput, 90)) : na
fill(diPlusPlot, diMinusPlot, color = directionalFillColor, title = "DI direction")

// --- Alerts ---
angelCross = ta.crossover(diPlusRaw, diMinusRaw)
deathCross = ta.crossover(diMinusRaw, diPlusRaw)
adxThresholdCross = ta.crossover(adxRaw, thresholdInput)
adxAbove20 = ta.crossover(adxRaw, ADX_WEAK_LEVEL)
adxBelow20 = ta.crossunder(adxRaw, ADX_WEAK_LEVEL)
adxAbove40 = ta.crossover(adxRaw, ADX_STRONG_LEVEL)
adxBelow40 = ta.crossunder(adxRaw, ADX_STRONG_LEVEL)

// All alerts require a confirmed candle, so they work on any chart timeframe without intrabar repainting.
alertcondition(barstate.isconfirmed and angelCross, "Angel Cross: DI+ > DI-", "Angel Cross: DI+ crossed above DI- on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and deathCross, "Death Cross: DI- > DI+", "Death Cross: DI- crossed above DI+ on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and adxThresholdCross, "ADX crossed above alert threshold", "ADX crossed above the alert threshold on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and adxAbove20, "ADX crossed above 20", "ADX crossed above 20 on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and adxBelow20, "ADX crossed below 20", "ADX crossed below 20 on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and adxAbove40, "ADX crossed above 40", "ADX crossed above 40 on {{ticker}} {{interval}}")
alertcondition(barstate.isconfirmed and adxBelow40, "ADX crossed below 40", "ADX crossed below 40 on {{ticker}} {{interval}}")
````
