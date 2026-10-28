#  Labeled EMA Ribbon + VWAP

- url: https://www.tradingview.com/script/wdDvR4Zm-Labeled-EMA-Ribbon-VWAP/
- type: indicator
- pine_id: PUB;c92b549dfff6436f9ba045ffba7b9036
- version: 1.0

## Description

#Labeled EMA Ribbon + VWAP

## Overview

Custom Labeled EMA Ribbon + VWAP is a Pine Script v6 overlay indicator that combines five customizable exponential moving averages with a session VWAP and places clearly identified labels beside each line.

The indicator was created to solve a simple but persistent charting problem: when several moving averages are displayed at the same time, it can be difficult to remember which colored line represents which EMA.

This becomes especially challenging when traders use several averages with similar values, frequently change their EMA settings, or view charts where the lines are compressed closely together.

Rather than forcing the user to memorize a color scheme, open the indicator settings, or move the cursor over each line, this script places the name of each EMA directly beside its current value on the right side of the chart.

For example, when an EMA slot is set to a length of 21, its label displays “EMA 21.” If that same slot is changed to a length of 20, the label automatically updates to “EMA 20.”

The primary purpose of the indicator is to make a multi-EMA chart easier to read, customize, and interpret without changing the underlying meaning of the moving averages or VWAP.

## What the Indicator Displays

The default configuration includes:

* 8 EMA
* 21 EMA
* 34 EMA
* 50 EMA
* 200 EMA
* Daily VWAP

All five EMA lengths can be changed by the user.

Each line includes independent controls for:

* Visibility
* Length
* Color
* Line width
* Label visibility
* Label size

VWAP also has separate visibility, color, line-width, source, and label controls.

The indicator therefore functions as a customizable charting framework rather than a fixed moving-average template.

## Why the Labels Are Important

Most moving-average indicators identify their lines through color alone.

That approach can work when only one or two averages are displayed, but it becomes less practical when several EMAs are grouped together. During consolidation or strong directional movement, multiple averages may overlap or remain only a few ticks apart.

The right-side labels allow the user to immediately identify each line without relying exclusively on color.

This can be especially useful for traders who:

* Use several moving averages on one chart
* Frequently switch between different EMA combinations
* Analyze charts on different screens or devices
* Have difficulty remembering which color belongs to each average
* Share charts with traders who do not know their personal color system
* Want the chart itself to explain what each line represents

The labels are attached to the current EMA or VWAP value and update as the chart changes.

Users may also display the current numerical price beside each label. When this option is enabled, a label can show both the moving-average name and its present value.

## Custom EMA Slots

The indicator contains five EMA slots instead of permanently locking the user into one specific combination.

The default lengths are 8, 21, 34, 50, and 200, but each slot can be changed independently.

For example, a trader could change the default configuration to:

* 5 EMA
* 10 EMA
* 20 EMA
* 50 EMA
* 200 EMA

The labels automatically use the selected length. The user does not need to modify the script or manually rename anything after changing an input.

This dynamic labeling is one of the indicator’s main practical features. It allows the chart to remain accurate even when the user experiments with different moving-average combinations.

## Moving-Average Source

The EMA source is customizable.

The default source is the closing price, but users may select another available price source from the indicator settings.

All five EMA calculations use the selected source while retaining their individually selected lengths.

## VWAP

The script includes a daily anchored Volume Weighted Average Price calculation.

By default, VWAP resets at the beginning of each new trading day and uses HLC3 as its source.

The VWAP source can be changed by the user.

There is also an option to display VWAP only on intraday charts. This helps prevent a daily session VWAP from appearing on timeframes where the user may not find it relevant.

VWAP includes its own:

* Visibility control
* Source setting
* Color
* Line width
* Right-side label
* Label size

When current values are enabled, the VWAP label can also display its current price.

## Right-Side Labels

The indicator creates persistent labels for all five EMAs and VWAP.

The labels are positioned beyond the most recent candle so they do not cover the active price bar.

Users can control:

* Whether all labels are shown
* Which individual labels are visible
* How far labels appear from the current candle
* Whether labels are horizontally staggered
* The amount of spacing between staggered labels
* Label text color
* The size of each individual label
* Whether current price values appear inside the labels

The master label control allows all labels to be hidden without turning off the underlying EMA and VWAP lines.

Individual label controls allow a line to remain visible while its label is hidden.

## Staggered Label Placement

When multiple moving averages are close together, their labels may overlap.

The optional stagger feature moves each label progressively farther to the right. This creates horizontal separation between labels even when their underlying EMA values are nearly identical.

The stagger distance is adjustable.

This feature is especially useful during:

* Consolidation
* Moving-average compression
* Low-volatility periods
* EMA crossovers
* Strong trends where several averages remain tightly grouped

Staggering changes only the horizontal position of the labels. It does not alter the moving-average calculations or their actual price levels.

## Individual Label Sizes

Each EMA and the VWAP has its own label-size setting.

Available sizes include:

* Tiny
* Small
* Normal
* Large
* Huge

This allows the user to emphasize certain reference lines.

For example, a trader may use larger labels for the 200 EMA and VWAP while keeping faster moving-average labels smaller.

The sizing controls can also improve readability across different chart layouts and screen sizes.

## Optional EMA Ribbon

The indicator includes optional shading between the first four EMA slots.

The ribbon fills the areas between:

* EMA Slot 1 and EMA Slot 2
* EMA Slot 2 and EMA Slot 3
* EMA Slot 3 and EMA Slot 4

The shading changes according to the relative position of the two averages.

When the faster EMA is above the slower EMA, the selected bullish ribbon color is used.

When the faster EMA is below the slower EMA, the selected bearish ribbon color is used.

The bullish and bearish ribbon colors are customizable, and the user can adjust the ribbon transparency.

For the most intuitive ribbon display, faster EMA lengths should generally be placed in the lower-numbered slots and slower EMA lengths in the higher-numbered slots.

For example:

* Slot 1: 8 EMA
* Slot 2: 21 EMA
* Slot 3: 34 EMA
* Slot 4: 50 EMA

The ribbon is optional and is turned off by default so users can choose between a clean line-based chart and a shaded moving-average structure.

## Practical Uses

The indicator can support several types of chart analysis.

### Trend Context

Traders may use the position and slope of the EMAs to observe whether price is trading above, below, or between important moving averages.

A faster EMA remaining above a slower EMA may support a bullish trend interpretation, while the opposite arrangement may support a bearish interpretation.

### Dynamic Support and Resistance

Some traders use moving averages as areas where price may pause, react, reject, or continue.

The labels make it easier to identify which moving average price is approaching without having to remember its color.

### Pullback Analysis

A trader may observe whether price pulls back toward a faster EMA, a middle EMA, or a slower trend average.

For example, a shallow pullback may react near the 8 or 21 EMA, while a deeper pullback may reach the 34 or 50 EMA.

The script does not determine whether those reactions will succeed. It makes the relevant averages easier to identify.

### Long-Term Trend Reference

The 200 EMA is commonly used as a broader trend reference.

The default larger label and thicker line make it easier to distinguish the 200 EMA from the shorter averages, although both settings remain customizable.

### VWAP Context

Intraday traders may compare price with VWAP to evaluate whether price is trading above or below the session’s volume-weighted average.

VWAP can also be compared with the EMA structure.

For example, a trader may observe whether:

* Price is above both VWAP and the EMA group
* Price is below both VWAP and the EMA group
* VWAP is positioned inside the EMA ribbon
* Price is repeatedly crossing VWAP and the EMAs during consolidation

These observations provide context but are not automatic trade signals.

## Original Contribution

The formulas used for exponential moving averages and VWAP are standard technical-analysis calculations.

This script does not claim to create a new type of moving average or a new VWAP formula.

Its contribution is the combination of these familiar tools into a customizable chart-reading system that includes:

* Five independently adjustable EMA slots
* Labels that automatically display the selected EMA lengths
* Optional current-value labels
* Individually controlled line and label visibility
* Individual label sizes
* Adjustable right-side label placement
* Horizontal label staggering
* An optional multi-layer EMA ribbon
* A daily VWAP with its own label and settings
* A structured settings menu designed for easy customization

The main objective is usability and chart clarity.

## What the Indicator Does Not Do

This indicator is not a trading strategy.

It does not automatically determine:

* Trade entries
* Trade exits
* Stop-loss placement
* Profit targets
* Trend reversals
* Breakout validity
* Support or resistance strength
* Position size
* Risk-to-reward
* Market volatility
* Volume confirmation
* Whether price is overextended

An EMA or VWAP touch does not guarantee that price will reverse or continue.

Moving averages are calculated from historical price information and will react after price changes. Faster EMAs generally respond more quickly, while slower EMAs generally respond more gradually.

VWAP reflects the session’s volume-weighted average price, but trading above or below VWAP does not guarantee future direction.

## Recommended Use

The indicator is best used as a chart-organization and market-context tool.

Traders should combine it with their own methods for:

* Market structure
* Price action
* Support and resistance
* Volume
* Liquidity
* Entry confirmation
* Stop placement
* Position sizing
* Risk management

Its purpose is to help the trader clearly identify the moving averages and VWAP already being used in that analysis.

## Summary

Custom Labeled EMA Ribbon + VWAP was designed for traders who want the benefits of several moving averages without the confusion of trying to remember which line is which.

The indicator places dynamically updated labels beside five customizable EMAs and a daily VWAP. It also provides independent line controls, individual label sizes, optional price values, adjustable label spacing, horizontal staggering, and optional ribbon shading.

Its primary value is not generating signals. Its value is making a multi-average chart easier to read, modify, and use consistently.

## Source Code

````pine
//@version=6
indicator(
     title = "Custom Labeled EMA Ribbon + VWAP",
     shorttitle = "Custom EMA Ribbon + VWAP",
     overlay = true,
     max_labels_count = 20
)

//=====================================================================
// INPUT GROUPS
//=====================================================================

const string GROUP_GENERAL = "1. General Settings"
const string GROUP_LENGTHS = "2. EMA Lengths"
const string GROUP_LINES   = "3. Line Visibility"
const string GROUP_COLORS  = "4. Colors and Line Widths"
const string GROUP_LABELS  = "5. Right-Side Labels"
const string GROUP_SIZES   = "6. Individual Label Sizes"
const string GROUP_RIBBON  = "7. EMA Ribbon Fill"
const string GROUP_VWAP    = "8. VWAP Settings"

//=====================================================================
// GENERAL SETTINGS
//=====================================================================

float emaSource = input.source(
     close,
     "EMA Source",
     group = GROUP_GENERAL
)

bool showPriceInLabels = input.bool(
     false,
     "Show current values in labels",
     group = GROUP_GENERAL,
     tooltip = "Adds the current EMA or VWAP price to each label."
)

//=====================================================================
// CUSTOM EMA LENGTHS
//
// Change any of these values. The chart labels update automatically.
//
// Example:
// Change EMA 1 Length from 8 to 5.
// The label will automatically display EMA 5.
//=====================================================================

int ema1Length = input.int(
     8,
     "EMA 1 Length",
     minval = 1,
     maxval = 1000,
     group = GROUP_LENGTHS
)

int ema2Length = input.int(
     21,
     "EMA 2 Length",
     minval = 1,
     maxval = 1000,
     group = GROUP_LENGTHS
)

int ema3Length = input.int(
     34,
     "EMA 3 Length",
     minval = 1,
     maxval = 1000,
     group = GROUP_LENGTHS
)

int ema4Length = input.int(
     50,
     "EMA 4 Length",
     minval = 1,
     maxval = 1000,
     group = GROUP_LENGTHS
)

int ema5Length = input.int(
     200,
     "EMA 5 Length",
     minval = 1,
     maxval = 1000,
     group = GROUP_LENGTHS
)

//=====================================================================
// LINE VISIBILITY
//=====================================================================

bool showEMA1 = input.bool(
     true,
     "Show EMA 1",
     group = GROUP_LINES
)

bool showEMA2 = input.bool(
     true,
     "Show EMA 2",
     group = GROUP_LINES
)

bool showEMA3 = input.bool(
     true,
     "Show EMA 3",
     group = GROUP_LINES
)

bool showEMA4 = input.bool(
     true,
     "Show EMA 4",
     group = GROUP_LINES
)

bool showEMA5 = input.bool(
     true,
     "Show EMA 5",
     group = GROUP_LINES
)

bool showVWAP = input.bool(
     true,
     "Show VWAP",
     group = GROUP_LINES
)

//=====================================================================
// COLORS AND LINE WIDTHS
//=====================================================================

color ema1Color = input.color(
     color.rgb(0, 230, 255),
     "EMA 1 Color",
     group = GROUP_COLORS,
     inline = "ema1"
)

int ema1Width = input.int(
     3,
     "Width",
     minval = 1,
     maxval = 5,
     group = GROUP_COLORS,
     inline = "ema1"
)

color ema2Color = input.color(
     color.rgb(255, 235, 59),
     "EMA 2 Color",
     group = GROUP_COLORS,
     inline = "ema2"
)

int ema2Width = input.int(
     2,
     "Width",
     minval = 1,
     maxval = 5,
     group = GROUP_COLORS,
     inline = "ema2"
)

color ema3Color = input.color(
     color.rgb(255, 64, 255),
     "EMA 3 Color",
     group = GROUP_COLORS,
     inline = "ema3"
)

int ema3Width = input.int(
     2,
     "Width",
     minval = 1,
     maxval = 5,
     group = GROUP_COLORS,
     inline = "ema3"
)

color ema4Color = input.color(
     color.rgb(255, 145, 0),
     "EMA 4 Color",
     group = GROUP_COLORS,
     inline = "ema4"
)

int ema4Width = input.int(
     3,
     "Width",
     minval = 1,
     maxval = 5,
     group = GROUP_COLORS,
     inline = "ema4"
)

color ema5Color = input.color(
     color.rgb(255, 255, 255),
     "EMA 5 Color",
     group = GROUP_COLORS,
     inline = "ema5"
)

int ema5Width = input.int(
     4,
     "Width",
     minval = 1,
     maxval = 5,
     group = GROUP_COLORS,
     inline = "ema5"
)

color vwapColor = input.color(
     color.rgb(90, 255, 120),
     "VWAP Color",
     group = GROUP_COLORS,
     inline = "vwap"
)

int vwapWidth = input.int(
     3,
     "Width",
     minval = 1,
     maxval = 5,
     group = GROUP_COLORS,
     inline = "vwap"
)

//=====================================================================
// RIGHT-SIDE LABEL SETTINGS
//=====================================================================

bool showAllLabels = input.bool(
     true,
     "Show right-side labels",
     group = GROUP_LABELS,
     tooltip = "Master switch for all EMA and VWAP labels."
)

int labelOffset = input.int(
     3,
     "Distance from current candle",
     minval = 1,
     maxval = 100,
     group = GROUP_LABELS
)

bool staggerLabels = input.bool(
     true,
     "Stagger labels horizontally",
     group = GROUP_LABELS,
     tooltip = "Moves each label progressively farther right to reduce overlap during consolidation."
)

int staggerDistance = input.int(
     2,
     "Stagger distance",
     minval = 1,
     maxval = 20,
     group = GROUP_LABELS
)

color labelTextColor = input.color(
     color.black,
     "Label text color",
     group = GROUP_LABELS
)

// Individual label visibility

bool showEMA1Label = input.bool(
     true,
     "EMA 1 Label",
     group = GROUP_LABELS
)

bool showEMA2Label = input.bool(
     true,
     "EMA 2 Label",
     group = GROUP_LABELS
)

bool showEMA3Label = input.bool(
     true,
     "EMA 3 Label",
     group = GROUP_LABELS
)

bool showEMA4Label = input.bool(
     true,
     "EMA 4 Label",
     group = GROUP_LABELS
)

bool showEMA5Label = input.bool(
     true,
     "EMA 5 Label",
     group = GROUP_LABELS
)

bool showVWAPLabel = input.bool(
     true,
     "VWAP Label",
     group = GROUP_LABELS
)

//=====================================================================
// INDIVIDUAL LABEL SIZES
//=====================================================================

string ema1LabelSizeInput = input.string(
     "Small",
     "EMA 1 Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_SIZES
)

string ema2LabelSizeInput = input.string(
     "Small",
     "EMA 2 Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_SIZES
)

string ema3LabelSizeInput = input.string(
     "Small",
     "EMA 3 Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_SIZES
)

string ema4LabelSizeInput = input.string(
     "Small",
     "EMA 4 Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_SIZES
)

string ema5LabelSizeInput = input.string(
     "Normal",
     "EMA 5 Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_SIZES
)

string vwapLabelSizeInput = input.string(
     "Small",
     "VWAP Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_SIZES
)

//=====================================================================
// VWAP SETTINGS
//=====================================================================

float vwapSource = input.source(
     hlc3,
     "VWAP Source",
     group = GROUP_VWAP
)

bool showVWAPOnlyIntraday = input.bool(
     true,
     "Show VWAP only on intraday charts",
     group = GROUP_VWAP
)

//=====================================================================
// EMA RIBBON SETTINGS
//=====================================================================

bool showRibbonFill = input.bool(
     false,
     "Show EMA ribbon shading",
     group = GROUP_RIBBON
)

color bullishRibbonColor = input.color(
     color.rgb(0, 190, 130),
     "Bullish Ribbon",
     group = GROUP_RIBBON
)

color bearishRibbonColor = input.color(
     color.rgb(225, 70, 70),
     "Bearish Ribbon",
     group = GROUP_RIBBON
)

int ribbonTransparency = input.int(
     88,
     "Ribbon Transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_RIBBON
)

//=====================================================================
// CALCULATIONS
//=====================================================================

float ema1 = ta.ema(emaSource, ema1Length)
float ema2 = ta.ema(emaSource, ema2Length)
float ema3 = ta.ema(emaSource, ema3Length)
float ema4 = ta.ema(emaSource, ema4Length)
float ema5 = ta.ema(emaSource, ema5Length)

bool newTradingDay = timeframe.change("1D")

float dailyVWAP = ta.vwap(
     vwapSource,
     newTradingDay
)

bool vwapCanDisplay =
     showVWAP and
     (not showVWAPOnlyIntraday or timeframe.isintraday)

//=====================================================================
// EMA AND VWAP PLOTS
//=====================================================================

pEMA1 = plot(
     showEMA1 ? ema1 : na,
     title = "EMA Slot 1",
     color = ema1Color,
     linewidth = ema1Width
)

pEMA2 = plot(
     showEMA2 ? ema2 : na,
     title = "EMA Slot 2",
     color = ema2Color,
     linewidth = ema2Width
)

pEMA3 = plot(
     showEMA3 ? ema3 : na,
     title = "EMA Slot 3",
     color = ema3Color,
     linewidth = ema3Width
)

pEMA4 = plot(
     showEMA4 ? ema4 : na,
     title = "EMA Slot 4",
     color = ema4Color,
     linewidth = ema4Width
)

pEMA5 = plot(
     showEMA5 ? ema5 : na,
     title = "EMA Slot 5",
     color = ema5Color,
     linewidth = ema5Width
)

pVWAP = plot(
     vwapCanDisplay ? dailyVWAP : na,
     title = "VWAP",
     color = vwapColor,
     linewidth = vwapWidth
)

//=====================================================================
// OPTIONAL RIBBON FILLS
//
// The ribbon follows the order of the EMA slots:
//
// Slot 1 to Slot 2
// Slot 2 to Slot 3
// Slot 3 to Slot 4
//
// For the cleanest ribbon, keep the faster EMAs in the lower-numbered
// slots and slower EMAs in the higher-numbered slots.
//=====================================================================

color ribbon1To2 =
     ema1 >= ema2
     ? color.new(bullishRibbonColor, ribbonTransparency)
     : color.new(bearishRibbonColor, ribbonTransparency)

color ribbon2To3 =
     ema2 >= ema3
     ? color.new(bullishRibbonColor, ribbonTransparency)
     : color.new(bearishRibbonColor, ribbonTransparency)

color ribbon3To4 =
     ema3 >= ema4
     ? color.new(bullishRibbonColor, ribbonTransparency)
     : color.new(bearishRibbonColor, ribbonTransparency)

fill(
     pEMA1,
     pEMA2,
     color = showRibbonFill and showEMA1 and showEMA2
          ? ribbon1To2
          : na,
     title = "EMA Slot 1 to Slot 2 Ribbon"
)

fill(
     pEMA2,
     pEMA3,
     color = showRibbonFill and showEMA2 and showEMA3
          ? ribbon2To3
          : na,
     title = "EMA Slot 2 to Slot 3 Ribbon"
)

fill(
     pEMA3,
     pEMA4,
     color = showRibbonFill and showEMA3 and showEMA4
          ? ribbon3To4
          : na,
     title = "EMA Slot 3 to Slot 4 Ribbon"
)

//=====================================================================
// LABEL-SIZE CONVERSION FUNCTION
//=====================================================================

labelSizeFromInput(string selectedSize) =>
    selectedSize == "Tiny" ? size.tiny :
     selectedSize == "Small" ? size.small :
     selectedSize == "Normal" ? size.normal :
     selectedSize == "Large" ? size.large :
     size.huge

//=====================================================================
// EMA LABEL-TEXT FUNCTION
//
// This dynamically displays the selected length.
//
// Example:
// If EMA 1 Length is changed from 8 to 5,
// the label automatically becomes EMA 5.
//=====================================================================

makeEMALabelText(int emaLength, float emaValue) =>
    string emaName = "EMA " + str.tostring(emaLength)

    showPriceInLabels
         ? emaName + "  " + str.tostring(emaValue, format.mintick)
         : emaName

makeVWAPLabelText(float vwapValue) =>
    showPriceInLabels
         ? "VWAP  " + str.tostring(vwapValue, format.mintick)
         : "VWAP"

//=====================================================================
// LABEL-UPDATE FUNCTION
//=====================================================================

updateLabel(
     label labelID,
     bool shouldDisplay,
     int xPosition,
     float yPosition,
     string labelText,
     color backgroundColor,
     color textColor,
     string selectedSize
 ) =>
    label.set_xy(
         labelID,
         xPosition,
         shouldDisplay ? yPosition : na
    )

    label.set_text(
         labelID,
         shouldDisplay ? labelText : ""
    )

    label.set_color(
         labelID,
         shouldDisplay
              ? backgroundColor
              : color.new(backgroundColor, 100)
    )

    label.set_textcolor(
         labelID,
         textColor
    )

    label.set_size(
         labelID,
         labelSizeFromInput(selectedSize)
    )

//=====================================================================
// CREATE PERSISTENT LABELS
//=====================================================================

var label ema1Label = label.new(
     bar_index,
     close,
     "",
     xloc = xloc.bar_index,
     yloc = yloc.price,
     style = label.style_label_left
)

var label ema2Label = label.new(
     bar_index,
     close,
     "",
     xloc = xloc.bar_index,
     yloc = yloc.price,
     style = label.style_label_left
)

var label ema3Label = label.new(
     bar_index,
     close,
     "",
     xloc = xloc.bar_index,
     yloc = yloc.price,
     style = label.style_label_left
)

var label ema4Label = label.new(
     bar_index,
     close,
     "",
     xloc = xloc.bar_index,
     yloc = yloc.price,
     style = label.style_label_left
)

var label ema5Label = label.new(
     bar_index,
     close,
     "",
     xloc = xloc.bar_index,
     yloc = yloc.price,
     style = label.style_label_left
)

var label vwapLabel = label.new(
     bar_index,
     close,
     "",
     xloc = xloc.bar_index,
     yloc = yloc.price,
     style = label.style_label_left
)

//=====================================================================
// LABEL POSITIONS
//=====================================================================

int spacing = staggerLabels ? staggerDistance : 0

int ema1LabelX =
     bar_index + labelOffset

int ema2LabelX =
     bar_index + labelOffset + spacing

int ema3LabelX =
     bar_index + labelOffset + spacing * 2

int ema4LabelX =
     bar_index + labelOffset + spacing * 3

int ema5LabelX =
     bar_index + labelOffset + spacing * 4

int vwapLabelX =
     bar_index + labelOffset + spacing * 5

//=====================================================================
// UPDATE LABELS ON THE MOST RECENT BAR
//=====================================================================

if barstate.islast
    bool displayEMA1Label =
         showAllLabels and
         showEMA1 and
         showEMA1Label

    updateLabel(
         ema1Label,
         displayEMA1Label,
         ema1LabelX,
         ema1,
         makeEMALabelText(ema1Length, ema1),
         ema1Color,
         labelTextColor,
         ema1LabelSizeInput
    )

    bool displayEMA2Label =
         showAllLabels and
         showEMA2 and
         showEMA2Label

    updateLabel(
         ema2Label,
         displayEMA2Label,
         ema2LabelX,
         ema2,
         makeEMALabelText(ema2Length, ema2),
         ema2Color,
         labelTextColor,
         ema2LabelSizeInput
    )

    bool displayEMA3Label =
         showAllLabels and
         showEMA3 and
         showEMA3Label

    updateLabel(
         ema3Label,
         displayEMA3Label,
         ema3LabelX,
         ema3,
         makeEMALabelText(ema3Length, ema3),
         ema3Color,
         labelTextColor,
         ema3LabelSizeInput
    )

    bool displayEMA4Label =
         showAllLabels and
         showEMA4 and
         showEMA4Label

    updateLabel(
         ema4Label,
         displayEMA4Label,
         ema4LabelX,
         ema4,
         makeEMALabelText(ema4Length, ema4),
         ema4Color,
         labelTextColor,
         ema4LabelSizeInput
    )

    bool displayEMA5Label =
         showAllLabels and
         showEMA5 and
         showEMA5Label

    updateLabel(
         ema5Label,
         displayEMA5Label,
         ema5LabelX,
         ema5,
         makeEMALabelText(ema5Length, ema5),
         ema5Color,
         labelTextColor,
         ema5LabelSizeInput
    )

    bool displayVWAPLabel =
         showAllLabels and
         vwapCanDisplay and
         showVWAPLabel

    updateLabel(
         vwapLabel,
         displayVWAPLabel,
         vwapLabelX,
         dailyVWAP,
         makeVWAPLabelText(dailyVWAP),
         vwapColor,
         labelTextColor,
         vwapLabelSizeInput
    )
````
