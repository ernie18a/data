<!-- tradingview-pine-id: PUB;eae5feaffb29455087d2ca0e05a85ded -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# OBV Structure Oscillator [OBVSO]

Source: https://www.tradingview.com/script/52l4Xtsu-OBV-Structure-Oscillator-OBVSO/

## Description

# OBV Structure Oscillator [OBVSO]

## Description

**OBV Structure Oscillator [OBVSO]** is an extension of the classic On-Balance Volume Oscillator concept, designed to make **volume-pressure structure and directional changes** easier to read on a consistent scale.

Instead of displaying the raw OBV Oscillator, whose numerical scale can vary significantly depending on an instrument's volume characteristics, OBVSO transforms the oscillator into a bounded **0–100 range**, with **50 representing the neutral midpoint**.

### Calculation

OBVSO begins by calculating On-Balance Volume (OBV) and then creates an oscillator by comparing OBV with its EMA:

**OBV Oscillator = OBV − EMA(OBV)**

The resulting oscillator is then symmetrically normalized using its highest absolute amplitude over the selected *Normalization Lookback*.

The final result is bounded between:

* **50** = neutral oscillator level
* **Above 50** = relatively positive OBV pressure
* **Below 50** = relatively negative OBV pressure
* **70 and 30** = upper and lower structural reference zones

The 70/30 zones are not intended to represent conventional overbought/oversold signals or automatic reversal levels. They are primarily visual reference zones for evaluating the strength and structure of OBV movement.

### Display Smoothing

**Display Smoothing** applies an optional EMA to the OBVSO line displayed on the chart.

Its purpose is purely to improve visual readability when the normalized oscillator becomes excessively sharp or fragmented.

A value of **1** preserves the normalized OBV Oscillator without additional display smoothing.

### OBV Signal

OBVSO also includes an independent **OBV Signal** calculated directly from the normalized oscillator **before Display Smoothing is applied**.

This separates the two functions:

* **Display Smoothing** → improves visual readability of the oscillator structure.
* **OBV Signal** → provides a reference for the underlying directional trend of the oscillator.

Available OBV Signal smoothing methods:

* SMA
* EMA
* SMMA (RMA)
* WMA
* VWMA

The default setting is **SMA 13**.

Because the OBV Signal is calculated from the oscillator before Display Smoothing, increasing Display Smoothing does not create a double-smoothed signal.

### Visual Structure

OBVSO includes:

* Customizable positive and negative oscillator colors.
* Positive upper gradient.
* Negative lower gradient.
* Neutral midpoint at 50.
* 70/30 structural reference zones.
* Independent OBV Signal.

The indicator is primarily intended for **OBV structure analysis**, including changes in volume momentum, strengthening or weakening pressure, and oscillator structures such as higher lows, higher highs, lower highs, and lower lows.

OBVSO does not generate automatic buy or sell signals. Its readings are best interpreted together with price structure, trend, support/resistance, volume, or other confirmation tools.

## Credits

The core OBV Oscillator concept used in this indicator was inspired by **LazyBear's On Balance Volume Oscillator**, which evaluates OBV relative to a moving average of OBV.

Special thanks to **LazyBear** for sharing the original OBV Oscillator implementation as open-source code with the TradingView community.

OBVSO extends that concept with symmetric 0–100 normalization, a neutral midpoint at 50, bounded structural zones, independent display smoothing, configurable gradient visualization, and a separately calculated OBV trend signal.

---

# Release Notes — v1.0

**Initial Public Open-Source Release — OBV Structure Oscillator [OBVSO]**

* Built with Pine Script® v6.
* Uses the core OBV Oscillator concept inspired by LazyBear.
* Added symmetric normalization to a 0–100 scale.
* Added a neutral midpoint at 50.
* Added configurable Normalization Lookback.
* Added 70/30 structural reference zones.
* Added positive and negative gradient visualization.
* Added customizable positive and negative oscillator colors.
* Added EMA-based Display Smoothing for improved structural readability.
* Display Smoothing affects only the displayed oscillator line.
* Added an independent OBV Signal.
* OBV Signal is calculated from the normalized/bounded OBV Oscillator before Display Smoothing.
* Added SMA, EMA, SMMA (RMA), WMA, and VWMA signal options.
* Default OBV Signal is SMA 13.
* Added a separately configurable OBV Signal color.
* Reorganized the code into clearer settings, calculation, visualization, and smoothing-signal sections.

The primary goal of this release is to make OBV Oscillator structure easier to compare across periods while preserving the underlying behavior of the original OBV-based oscillator.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nixforge
//
// OBV Structure Oscillator [OBVSO]
// Core OBV Oscillator concept inspired by LazyBear's
// On Balance Volume Oscillator.
//
// Extended with:
// - Symmetric 0–100 normalization
// - Neutral midpoint at 50
// - Independent display smoothing
// - Independent OBV trend signal
// - Structural gradient visualization
//
// Version 1.0.1

//@version=6
indicator(
     title      = "OBV Structure Oscillator [OBVSO]",
     shorttitle = "OBVSO",
     overlay    = false,
     format     = format.price,
     precision  = 2,
     scale      = scale.right
)


//=============================================================================
// OBV OSCILLATOR SETTINGS
//=============================================================================
showObvOsc = input.bool(
     true,
     title = "Show OBV Oscillator",
     group = "OBV Oscillator Settings"
)

obvLength = input.int(
     20,
     title = "EMA Length",
     minval = 1,
     group = "OBV Oscillator Settings"
)

obvSource = input.source(
     close,
     title = "Source",
     group = "OBV Oscillator Settings"
)

normalizationLength = input.int(
     85,
     title = "Normalization Lookback",
     minval = 10,
     maxval = 150,
     group = "OBV Oscillator Settings",
    tooltip = "Determines the number of bars used to identify the absolute peak of the OBVOS. Smaller values are more sensitive, while larger values provide greater stability."
)

displaySmoothing = input.int(
     1,
     title = "Display Smoothing",
     minval = 1,
     maxval = 20,
     group = "OBV Oscillator Settings",
     tooltip = "Use 1 to preserve the normalized OBVSO structure. Increase the value for a smoother visual appearance (max 20)."
)

showObvArea = input.bool(
     true,
     title = "Show OBV Gradient",
     group = "OBV Oscillator Settings"
)


//-----------------------------------------------------------------------------
// OBV Colors
//-----------------------------------------------------------------------------
obvPositiveColor = input.color(
     color.rgb(0, 188, 212, 12),
     title = "Positive Color",
     group = "OBV Oscillator Settings",
     inline = "OBV Color"
)

obvNegativeColor = input.color(
     color.new(color.fuchsia, 30),
     title = "Negative Color",
     group = "OBV Oscillator Settings",
     inline = "OBV Color"
)


//=============================================================================
// OBV CALCULATION
//=============================================================================
priceChange = ta.change(obvSource)

obvValue = ta.cum(
     priceChange > 0 ? nz(volume, 0.0) :
     priceChange < 0 ? -nz(volume, 0.0) :
     0.0
)


//-----------------------------------------------------------------------------
// Original OBV Oscillator
//-----------------------------------------------------------------------------
rawObvOsc = obvValue - ta.ema(
     obvValue,
     obvLength
)


//-----------------------------------------------------------------------------
// Normalization
//-----------------------------------------------------------------------------
highestAbsoluteOsc = ta.highest(
     math.abs(rawObvOsc),
     normalizationLength
)


// OBVSO zero     = 50
// Positive peak   = near 100
// Negative peak   = near 0

normalizedObvOsc = highestAbsoluteOsc > 0
     ? 50.0 + 50.0 * rawObvOsc / highestAbsoluteOsc
     : 50.0


//-----------------------------------------------------------------------------
// Bound to 0–100
//-----------------------------------------------------------------------------
boundedObvOsc = math.max(
     0.0,
     math.min(
          100.0,
          normalizedObvOsc
     )
)

//=============================================================================
// DISPLAY SMOOTHING
//=============================================================================
obvOsc = displaySmoothing > 1
     ? ta.ema(boundedObvOsc, displaySmoothing)
     : boundedObvOsc

//-----------------------------------------------------------------------------
// OBV Oscillator Color
//-----------------------------------------------------------------------------
obvColor = obvOsc >= 50.0
     ? obvPositiveColor
     : obvNegativeColor


//=============================================================================
// OBV PLOT
//=============================================================================
plot(
     showObvOsc ? obvOsc : na,
     title = "OBV Oscillator",
     color = obvColor,
     linewidth = 1
)


//=============================================================================
// LEVELS AND FILLS
//=============================================================================
midlinePlot = plot(
     50.0,
     title = "Midline Plot",
     color = na,
     display = display.none,
     editable = false
)

//-----------------------------------------------------------------------------
// Visible Midline
//-----------------------------------------------------------------------------
hline(
     50.0,
     title = "Midline / Zero Line",
     color = color.new(#787B86, 65),
     linestyle = hline.style_solid
)

//=============================================================================
// OBV GRADIENT FILLS
//=============================================================================
obvUpperPlot = plot(
     showObvOsc and obvOsc >= 50.0
          ? obvOsc
          : na,
     title = "OBV Upper Fill Plot",
     color = na,
     display = display.none
)

obvLowerPlot = plot(
     showObvOsc and obvOsc < 50.0
          ? obvOsc
          : na,
     title = "OBV Lower Fill Plot",
     color = na,
     display = display.none
)


//-----------------------------------------------------------------------------
// Gradient Colors
//-----------------------------------------------------------------------------
obvUpperColor = color.new(
     obvPositiveColor,
     60
)

obvLowerColor = color.new(
     obvNegativeColor,
     65
)

obvTransColor = color.new(
     chart.bg_color,
     90
)


//-----------------------------------------------------------------------------
// Positive Gradient
//-----------------------------------------------------------------------------
fill(
     obvUpperPlot,
     midlinePlot,
     100.0,
     70.0,
     obvUpperColor,
     obvTransColor,
     title = "OBV Upper Gradient",
     display = (showObvOsc and showObvArea)
          ? display.all
          : display.none
)

//-----------------------------------------------------------------------------
// Negative Gradient
//-----------------------------------------------------------------------------

fill(
     midlinePlot,
     obvLowerPlot,
     30.0,
     0.0,
     obvTransColor,
     obvLowerColor,
     title = "OBV Lower Gradient",
     display = (showObvOsc and showObvArea)
          ? display.all
          : display.none
)

//-----------------------------------------------------------------------------
// Upper / Lower Band
//-----------------------------------------------------------------------------

upperBand = hline(
     70.0,
     title = "Upper Structure Level",
     color = color.new(color.gray, 85),
     linestyle = hline.style_dashed
)

lowerBand = hline(
     30.0,
     title = "Lower Structure Level",
     color = color.new(color.gray, 85),
     linestyle = hline.style_dashed
)

fill(
     upperBand,
     lowerBand,
     color.new(color.blue, 95),
     title = "Range Background"
)


//=============================================================================
// OBV-BASED MA / SMOOTHING SIGNAL
//=============================================================================
GRP = "OBV Signal Settings"


//-----------------------------------------------------------------------------
// Inputs
//-----------------------------------------------------------------------------

maTypeInput = input.string(
     "SMA",
     title = "Type",
     options = [
          "None",
          "SMA",
          "EMA",
          "SMMA (RMA)",
          "WMA",
          "VWMA"
     ],
     group = GRP,
     display = display.none
)

maLengthInput = input.int(
     13,
     title = "Length",
     minval = 9,
     maxval = 27,
     tooltip = "Minval 9, Maxval 27.",
     group = GRP,
     display = display.none,
     active = maTypeInput != "None"
)

maColorInput = input.color(
     color.rgb(251, 194, 45, 40),
     title = "Signal Color",
     group = GRP,
     display = display.none,
     active = maTypeInput != "None"
)

bool enableMA = maTypeInput != "None"


//=============================================================================
// OBV SIGNAL CALCULATION
//=============================================================================
// Signal is calculated from OBVSO before Display Smoothing.
smaObv  = ta.sma(boundedObvOsc, maLengthInput)
emaObv  = ta.ema(boundedObvOsc, maLengthInput)
rmaObv  = ta.rma(boundedObvOsc, maLengthInput)
wmaObv  = ta.wma(boundedObvOsc, maLengthInput)
vwmaObv = ta.vwma(boundedObvOsc, maLengthInput)

smoothingMA =
     maTypeInput == "SMA"        ? smaObv  :
     maTypeInput == "EMA"        ? emaObv  :
     maTypeInput == "SMMA (RMA)" ? rmaObv  :
     maTypeInput == "WMA"        ? wmaObv  :
     maTypeInput == "VWMA"       ? vwmaObv :
     na

//=============================================================================
// OBV SIGNAL PLOT
//=============================================================================
plot(
     smoothingMA,
     title = "OBV Signal",
     color = maColorInput,
     linewidth = 1,
     display = enableMA ? display.all : display.none
)

// OBV SIGNAL - END
````
