# Round Number Grid

- url: https://www.tradingview.com/script/mGHRuHwm-Round-Number-Grid/
- type: indicator
- pine_id: PUB;e8906656513b4224a3ccf9706f4d69ef
- version: 1.0

## Description

Round Number Grid is a visual price reference tool that draws psychological round-number levels around the current market price.

The purpose of this script is to help traders quickly see nearby round-number levels such as 50, 100, 150, 200, 250, 300, 500, or other clean price steps depending on the symbol and its volatility.

This is a visual tool only. It does not generate buy or sell signals, does not predict future price movement, and does not claim that round numbers will act as support or resistance.

How it works

The script can calculate the grid step in two ways:

- Auto from ATR: the script uses recent volatility to estimate a suitable distance between levels, then converts that distance into a clean round-number step.
- Manual: the user can manually choose the distance between grid levels.

In Auto mode, the script converts the ATR-based distance into a clean step such as:

- 1
- 2.5
- 5
- 10
- 25
- 50
- 100

This helps the grid adapt to different symbols and price ranges.

What the script shows

- Round-number levels above and below current price
- The nearest round-number level above price
- The nearest round-number level below price
- Optional major levels every selected number of steps
- Optional labels for visible levels
- A compact state label showing:
  - Current grid step
  - Nearest round level above
  - Nearest round level below
  - Percentage distance to the nearest levels

Visual features

The nearest level above price can be highlighted with a separate color and width.

The nearest level below price can also be highlighted separately.

Users can control:

- Number of levels shown above and below price
- Step mode: Auto or Manual
- Auto step multiplier from ATR
- Manual step size
- Major level frequency
- Line colors
- Line width
- Line style
- Label size
- Label visibility
- State label visibility
- Right-side line extension

Right extension

The script includes a right-extension setting so users can extend the grid lines farther to the right.

Users can choose between:

- Manual bars: extend levels by a selected number of bars
- Infinite right: extend the grid lines continuously to the right side of the chart

This makes the grid easier to read when the user wants more space between price, labels, and the right edge of the chart.

Alerts

The script includes alert conditions for:

- Round level crossed
- Nearest upper round level crossed
- Nearest lower round level crossed

These alerts are descriptive price-reference events only. They are not buy or sell signals.

Important note

Round numbers are psychological reference levels. They may be watched by market participants, but they are not guaranteed support or resistance levels.

A reaction near a round number does not guarantee a reversal, continuation, breakout, or rejection.

This indicator is intended for visual analysis, education, and chart context. It should be used together with broader market structure, trend, volume, support and resistance, and risk management.

Repainting / behavior note

This script does not use pivot confirmation, future-looking calculations, or predictive signals.

However, the visible grid is centered around the current price area. When price moves significantly, the displayed grid can recenter around the new price area. This is normal behavior for a visual round-number grid and should not be interpreted as a signal change.

The script is not a strategy, not financial advice, and not a standalone trading system.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Round Number Grid
// ============================================================================
// Draws psychological round-number levels around the current price.
//
// The grid step can be selected manually or calculated automatically from
// recent volatility. In Auto mode, the script converts an ATR-based distance
// into a clean nice step: 1 / 2.5 / 5 x a power of ten.
//
// PURPOSE
// This is a visual reference grid for psychological price levels. It highlights
// the nearest round number above and below current price, and optionally shades
// the active price interval between them.
//
// IMPORTANT MECHANICS
// - Grid levels are fixed round-number references.
// - The visible grid recenters around current price as price moves.
// - Round numbers are a market convention, not guaranteed support/resistance.
// - This script does not generate buy/sell signals or price forecasts.
// ============================================================================

indicator(
     title            = "Round Number Grid",
     shorttitle       = "RoundGrid",
     overlay          = true,
     max_lines_count  = 120,
     max_labels_count = 120,
     max_boxes_count  = 10
)

// ============================================================================
// Inputs
// ============================================================================

string stepMode = input.string(
     defval  = "Auto (from ATR)",
     title   = "Step mode",
     options = ["Auto (from ATR)", "Manual"],
     group   = "1) Grid",
     tooltip = "Auto mode derives the grid step from ATR. Manual mode uses a fixed price distance."
)

float stepAtr = input.float(
     defval  = 4.0,
     title   = "Auto step x ATR",
     minval  = 1.0,
     maxval  = 30.0,
     step    = 0.5,
     group   = "1) Grid",
     active  = stepMode == "Auto (from ATR)",
     tooltip = "The grid step is the nearest nice number to this many ATR(14) units."
)

float manualStep = input.float(
     defval  = 1.0,
     title   = "Manual step",
     minval  = 0.000001,
     group   = "1) Grid",
     active  = stepMode == "Manual",
     tooltip = "Fixed price distance between grid lines, e.g. 5.0 for a stock or 1000 for BTC."
)

int levelsEachSide = input.int(
     defval  = 5,
     title   = "Levels each side",
     minval  = 2,
     maxval  = 15,
     group   = "1) Grid",
     tooltip = "Number of round-number levels displayed above and below the nearest round level."
)

int majorEvery = input.int(
     defval  = 5,
     title   = "Major line every N levels",
     minval  = 2,
     maxval  = 10,
     group   = "1) Grid",
     tooltip = "Levels that are a multiple of N grid steps are drawn as major lines."
)

bool showLabels = input.bool(
     defval = true,
     title  = "Show level labels",
     group  = "2) Display"
)

bool showOnlyNearestLabels = input.bool(
     defval = false,
     title  = "Show only nearest labels",
     group  = "2) Display",
     active = showLabels,
     tooltip = "Keeps labels only on the nearest round level above and below price, plus major levels."
)

bool highlightNearest = input.bool(
     defval = true,
     title  = "Highlight nearest above / below",
     group  = "2) Display",
     tooltip = "Highlights the nearest round number above and below current price."
)

bool shadeActiveInterval = input.bool(
     defval = false,
     title  = "Shade active interval",
     group  = "2) Display",
     tooltip = "Optionally shades the price area between the nearest round number below and above current price."
)

bool showStateLabel = input.bool(
     defval = true,
     title  = "Show state label",
     group  = "2) Display",
     tooltip = "Compact label with the grid step and the nearest round level above and below."
)

int stateLabelOffsetBars = input.int(
     defval  = 18,
     title   = "State label offset bars",
     minval  = 0,
     maxval  = 200,
     group   = "2) Display",
     active  = showStateLabel,
     tooltip = "Moves the state label to the right so it does not overlap level labels."
)

int leftBars = input.int(
     defval  = 35,
     title   = "Line length left (bars)",
     minval  = 5,
     maxval  = 500,
     group   = "2) Display"
)

string rightExtensionMode = input.string(
     defval  = "Manual bars",
     title   = "Right extension mode",
     options = ["Manual bars", "Infinite right"],
     group   = "2) Display",
     tooltip = "Manual bars extends levels by the selected number of bars. Infinite right uses TradingView line extension to project the grid across the chart."
)

int rightExtensionBars = input.int(
     defval  = 40,
     title   = "Extend levels right",
     minval  = 0,
     maxval  = 500,
     group   = "2) Display",
     active  = rightExtensionMode == "Manual bars",
     tooltip = "How many bars the grid lines extend to the right. Increase this value if the labels or lines need more space."
)

string labelSizeInput = input.string(
     defval  = "Tiny",
     title   = "Label size",
     options = ["Tiny", "Small", "Normal"],
     group   = "2) Display"
)

int minorWidth = input.int(
     defval = 2,
     title  = "Minor line width",
     minval = 1,
     maxval = 4,
     group  = "3) Lines"
)

int majorWidth = input.int(
     defval = 2,
     title  = "Major line width",
     minval = 1,
     maxval = 5,
     group  = "3) Lines"
)

int nearestWidth = input.int(
     defval = 3,
     title  = "Nearest line width",
     minval = 1,
     maxval = 5,
     group  = "3) Lines",
     active = highlightNearest
)

string minorStyleInput = input.string(
     defval  = "Dashed",
     title   = "Minor line style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "3) Lines"
)

string majorStyleInput = input.string(
     defval  = "Dashed",
     title   = "Major line style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "3) Lines"
)

string nearestStyleInput = input.string(
     defval  = "Solid",
     title   = "Nearest line style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "3) Lines",
     active  = highlightNearest
)

color minorColor = input.color(
     defval = color.rgb(135, 145, 160),
     title  = "Minor line color",
     group  = "4) Colors"
)

color majorColor = input.color(
     defval = color.rgb(212, 180, 131),
     title  = "Major line color",
     group  = "4) Colors"
)

color nearestAboveColor = input.color(
     defval = color.rgb(201, 91, 101),
     title  = "Nearest above color",
     group  = "4) Colors"
)

color nearestBelowColor = input.color(
     defval = color.rgb(72, 166, 126),
     title  = "Nearest below color",
     group  = "4) Colors"
)

color activeIntervalColor = input.color(
     defval = color.rgb(212, 180, 131),
     title  = "Active interval color",
     group  = "4) Colors",
     active = shadeActiveInterval
)

int minorTransparency = input.int(
     defval = 12,
     title  = "Minor line transparency",
     minval = 0,
     maxval = 100,
     group  = "4) Colors"
)

int majorTransparency = input.int(
     defval = 6,
     title  = "Major line transparency",
     minval = 0,
     maxval = 100,
     group  = "4) Colors"
)

int nearestTransparency = input.int(
     defval = 0,
     title  = "Nearest line transparency",
     minval = 0,
     maxval = 100,
     group  = "4) Colors",
     active = highlightNearest
)

int intervalTransparency = input.int(
     defval = 90,
     title  = "Active interval transparency",
     minval = 0,
     maxval = 100,
     group  = "4) Colors",
     active = shadeActiveInterval
)

color stateTextColor = input.color(
     defval = color.white,
     title  = "State label text color",
     group  = "4) Colors"
)

int hiddenTransparency = 100

// ============================================================================
// Helpers
// ============================================================================

float atr = ta.atr(14)

labelSize =
     labelSizeInput == "Small" ? size.small :
     labelSizeInput == "Normal" ? size.normal :
     size.tiny

f_line_style(string styleInput) =>
    styleInput == "Dotted" ? line.style_dotted :
     styleInput == "Dashed" ? line.style_dashed :
     line.style_solid

f_nice_step(float rawValue) =>
    float result = na
    if not na(rawValue) and rawValue > 0.0
        float mag = math.pow(10.0, math.floor(math.log10(rawValue)))
        float m = rawValue / mag
        result := m < 1.5 ? mag :
             m < 3.5 ? 2.5 * mag :
             m < 7.5 ? 5.0 * mag :
             10.0 * mag
    result

f_pct_text(float priceLevel) =>
    str.tostring((priceLevel / close - 1.0) * 100.0, "0.0") + "%"

// ============================================================================
// Grid step
// ============================================================================

float rawStep = stepMode == "Manual" ? manualStep : atr * stepAtr
float gridStep = stepMode == "Manual" ? manualStep : f_nice_step(rawStep)

bool ready = not na(gridStep) and gridStep > 0.0 and close > 0.0

float levelBelow =
     ready ?
     math.floor(close / gridStep) * gridStep :
     na

float levelAbove =
     ready ?
     levelBelow + gridStep :
     na

float nearestRound =
     ready ?
     math.round(close / gridStep) * gridStep :
     na

bool crossedRound =
     not na(nearestRound[1]) and
     ((close > nearestRound[1] and close[1] <= nearestRound[1]) or
      (close < nearestRound[1] and close[1] >= nearestRound[1]))

bool crossedAboveLevel =
     not na(levelAbove[1]) and close > levelAbove[1] and close[1] <= levelAbove[1]

bool crossedBelowLevel =
     not na(levelBelow[1]) and close < levelBelow[1] and close[1] >= levelBelow[1]

// ============================================================================
// Drawing objects
// ============================================================================

var array<line>  gridLines  = array.new<line>()
var array<label> gridLabels = array.new<label>()
var label stateLabel = na
var box activeBox = na

// ============================================================================
// Drawing
// ============================================================================

if barstate.islast and ready

    int slots = 2 * levelsEachSide + 1

    while array.size(gridLines) < slots
        array.push(gridLines, line.new(bar_index, close, bar_index, close, color = color.new(color.white, 100)))
        array.push(gridLabels, label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.new(color.white, 100), size = labelSize))

    int xStart = bar_index - leftBars
    int xEnd = bar_index + rightExtensionBars
    bool extendInfiniteRight = rightExtensionMode == "Infinite right"

    float baseLevel = math.round(close / gridStep) * gridStep

    // Optional active interval shading.
    if shadeActiveInterval
        if na(activeBox)
            activeBox := box.new(xStart, levelAbove, xEnd, levelBelow, border_color = color.new(activeIntervalColor, hiddenTransparency), bgcolor = color.new(activeIntervalColor, intervalTransparency))
        box.set_lefttop(activeBox, xStart, levelAbove)
        box.set_rightbottom(activeBox, xEnd, levelBelow)
        box.set_bgcolor(activeBox, color.new(activeIntervalColor, intervalTransparency))
        box.set_border_color(activeBox, color.new(activeIntervalColor, hiddenTransparency))
    else
        if not na(activeBox)
            box.delete(activeBox)
            activeBox := na

    for i = 0 to array.size(gridLines) - 1
        line ln = array.get(gridLines, i)
        label lb = array.get(gridLabels, i)

        bool slotVisible = i < slots

        if slotVisible
            int k = i - levelsEachSide
            float lvl = baseLevel + k * gridStep
            int levelIndex = int(math.round(lvl / gridStep))

            bool major = math.abs(levelIndex) % majorEvery == 0
            bool isAbove = math.abs(lvl - levelAbove) <= syminfo.mintick * 0.5
            bool isBelow = math.abs(lvl - levelBelow) <= syminfo.mintick * 0.5
            bool nearest = highlightNearest and (isAbove or isBelow)

            color rawColor =
                 nearest and isAbove ? nearestAboveColor :
                 nearest and isBelow ? nearestBelowColor :
                 major ? majorColor :
                 minorColor

            int useTransparency =
                 nearest ? nearestTransparency :
                 major ? majorTransparency :
                 minorTransparency

            int drawWidth =
                 nearest ? nearestWidth :
                 major ? majorWidth :
                 minorWidth

            string useStyle =
                 nearest ? nearestStyleInput :
                 major ? majorStyleInput :
                 minorStyleInput

            color drawColor = color.new(rawColor, useTransparency)

            line.set_xy1(ln, xStart, lvl)
            line.set_xy2(ln, xEnd, lvl)
            line.set_extend(ln, extendInfiniteRight ? extend.right : extend.none)
            line.set_color(ln, drawColor)
            line.set_width(ln, drawWidth)
            line.set_style(ln, f_line_style(useStyle))

            string prefix =
                 nearest and isAbove ? "Above " :
                 nearest and isBelow ? "Below " :
                 ""

            bool labelAllowed =
                 showLabels and
                 (not showOnlyNearestLabels or nearest or major)

            label.set_xy(lb, xEnd + 1, lvl)
            label.set_text(lb, labelAllowed ? prefix + str.tostring(lvl, format.mintick) : "")
            label.set_textcolor(lb, labelAllowed ? drawColor : color.new(rawColor, hiddenTransparency))
            label.set_size(lb, labelSize)
        else
            line.set_extend(ln, extend.none)
            line.set_color(ln, color.new(color.white, hiddenTransparency))
            label.set_text(lb, "")
            label.set_textcolor(lb, color.new(color.white, hiddenTransparency))

    // State label.
    string stateText =
         "Step: " + str.tostring(gridStep, format.mintick) + "\n" +
         "Above " + str.tostring(levelAbove, format.mintick) + " (+" + f_pct_text(levelAbove) + ")\n" +
         "Below " + str.tostring(levelBelow, format.mintick) + " (" + f_pct_text(levelBelow) + ")"

    color stateColor =
         close - levelBelow <= levelAbove - close ?
         nearestBelowColor :
         nearestAboveColor

    if showStateLabel
        if na(stateLabel)
            stateLabel := label.new(
                 x         = xEnd + 1 + stateLabelOffsetBars,
                 y         = close,
                 text      = stateText,
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = color.new(stateColor, 12),
                 textcolor = stateTextColor,
                 size      = labelSize
            )
        else
            label.set_x(stateLabel, xEnd + 1 + stateLabelOffsetBars)
            label.set_y(stateLabel, close)
            label.set_text(stateLabel, stateText)
            label.set_color(stateLabel, color.new(stateColor, 12))
            label.set_textcolor(stateLabel, stateTextColor)
            label.set_size(stateLabel, labelSize)
    else
        if not na(stateLabel)
            label.delete(stateLabel)
            stateLabel := na

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     crossedRound,
     title   = "Round level crossed",
     message = "Round Number Grid: close crossed the nearest round-number level."
)

alertcondition(
     crossedAboveLevel,
     title   = "Nearest upper round level crossed",
     message = "Round Number Grid: close crossed above the nearest upper round-number level."
)

alertcondition(
     crossedBelowLevel,
     title   = "Nearest lower round level crossed",
     message = "Round Number Grid: close crossed below the nearest lower round-number level."
)

// ============================================================================
// End of file
// ============================================================================
````
