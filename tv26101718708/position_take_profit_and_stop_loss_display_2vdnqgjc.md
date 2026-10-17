# Position Take Profit and Stop Loss Display

- url: https://www.tradingview.com/script/2vDNQGjc-Position-Take-Profit-and-Stop-Loss-Display/
- type: indicator
- pine_id: PUB;6a8d451c993c4a4a81d9a73ed4616cf4
- version: 1.0

## Description

Position Take Profit and Stop Loss Display is a simple visual tool designed to make stop-loss and take-profit distances easier to judge directly on the chart.

The idea is straightforward: chart zoom and candle size can sometimes make a 20, 30 or 50-point move look very different. This indicator keeps a consistent visual reference around the current market price, helping you see exactly what your chosen risk distance looks like in real time.

Features:

• Configurable stop-loss distance
• Optional take-profit levels
• Long, Short or Both directions
• Supports both Points and Ticks
• Levels update dynamically with the current market price
• Customisable line colours, width and style
• Optional labels
• Optional live-price anchor
• Adjustable line length

Example:
If Stop Distance is set to 30 points, the indicator can show a level 30 points above and 30 points below the current price. This provides a quick visual reference for the actual size of that move regardless of chart zoom.

The indicator does not generate trade signals or determine where a stop loss should be placed. It is simply a visual measurement and risk-planning tool.

Originally built for my own intraday trading on NASDAQ and S&P 500 markets, but it can be used on other instruments as well.

Use the Points setting when you want to measure actual price/index points. Use Ticks when you want the distance calculated using the instrument's minimum tick size.

## Source Code

````pine
//@version=6
indicator(
     "Position Take Profit and Stop Loss Display",
     shorttitle = "TP and SL Display",
     overlay = true,
     max_lines_count = 10,
     max_labels_count = 10
 )

// RV Risk Ruler
// Version: 1.0.1
// Purpose: Live visual distance ruler for stop-loss and optional take-profit levels.

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

string GROUP_LEVELS = "Risk Levels"
string GROUP_STYLE  = "Appearance"

direction = input.string(
     "Both",
     "Direction",
     options = ["Both", "Long", "Short"],
     group = GROUP_LEVELS,
     tooltip = "Both shows the selected distance above and below live price."
 )

unit = input.string(
     "Points",
     "Distance unit",
     options = ["Points", "Ticks"],
     group = GROUP_LEVELS,
     tooltip = "Points = actual chart price points. Ticks = multiples of the symbol's minimum tick size."
 )

stopDistance = input.float(
     30.0,
     "Stop distance",
     minval = 0.0,
     step = 0.25,
     group = GROUP_LEVELS
 )

showTP = input.bool(
     false,
     "Show Take Profit",
     group = GROUP_LEVELS
 )

tpDistance = input.float(
     100.0,
     "Take Profit distance",
     minval = 0.0,
     step = 0.25,
     group = GROUP_LEVELS
 )

showAnchor = input.bool(
     false,
     "Show live-price anchor",
     group = GROUP_STYLE
 )

showLabels = input.bool(
     true,
     "Show labels",
     group = GROUP_STYLE
 )

lineLength = input.int(
     35,
     "Line length",
     minval = 5,
     maxval = 250,
     group = GROUP_STYLE,
     tooltip = "Number of bars the levels extend to the left."
 )

labelOffset = input.int(
     3,
     "Label offset",
     minval = 1,
     maxval = 20,
     group = GROUP_STYLE
 )

lineWidth = input.int(
     2,
     "Line width",
     minval = 1,
     maxval = 4,
     group = GROUP_STYLE
 )

lineStyleInput = input.string(
     "Solid",
     "Line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_STYLE
 )

stopColor = input.color(
     color.red,
     "Stop color",
     group = GROUP_STYLE
 )

tpColor = input.color(
     color.green,
     "Take Profit color",
     group = GROUP_STYLE
 )

anchorColor = input.color(
     color.new(color.gray, 55),
     "Anchor color",
     group = GROUP_STYLE
 )

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

// On the real-time bar, close is the latest available chart price.
float anchor = close

// Convert entered distance into chart price units.
float multiplier = unit == "Ticks" ? syminfo.mintick : 1.0

float stopOffset = stopDistance * multiplier
float tpOffset   = tpDistance * multiplier

bool showLong  = direction == "Long" or direction == "Both"
bool showShort = direction == "Short" or direction == "Both"

// Long levels.
float longStop = anchor - stopOffset
float longTP   = anchor + tpOffset

// Short levels.
float shortStop = anchor + stopOffset
float shortTP   = anchor - tpOffset

string unitText = unit == "Ticks" ? " ticks" : " pts"

string stopText = str.tostring(stopDistance, "#.##") + unitText
string tpText   = str.tostring(tpDistance, "#.##") + unitText

lineStyleValue = switch lineStyleInput
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

// ─────────────────────────────────────────────────────────────────────────────
// DRAWING OBJECTS
// ─────────────────────────────────────────────────────────────────────────────

var line longStopLine  = line.new(na, na, na, na)
var line shortStopLine = line.new(na, na, na, na)

var line longTPLine  = line.new(na, na, na, na)
var line shortTPLine = line.new(na, na, na, na)

var line anchorLine = line.new(na, na, na, na)

var label longStopLabel  = label.new(na, na, "")
var label shortStopLabel = label.new(na, na, "")

var label longTPLabel  = label.new(na, na, "")
var label shortTPLabel = label.new(na, na, "")

// ─────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────

updateLine(line id, bool visible, float price, color lineColor) =>
    int leftX  = bar_index - math.min(lineLength, bar_index)
    int rightX = bar_index + labelOffset

    line.set_xy1(id, leftX, price)
    line.set_xy2(id, rightX, price)
    line.set_width(id, lineWidth)
    line.set_style(id, lineStyleValue)
    line.set_color(id, visible ? lineColor : color.new(lineColor, 100))

updateLabel(
     label id,
     bool visible,
     float price,
     string labelText,
     color labelColor
 ) =>
    bool actuallyVisible = visible and showLabels

    label.set_xy(
         id,
         bar_index + labelOffset,
         price
     )

    label.set_text(
         id,
         actuallyVisible ? labelText : ""
     )

    label.set_style(
         id,
         label.style_label_left
     )

    label.set_color(
         id,
         actuallyVisible
             ? color.new(labelColor, 10)
             : color.new(labelColor, 100)
     )

    label.set_textcolor(
         id,
         actuallyVisible
             ? color.white
             : color.new(color.white, 100)
     )

    label.set_size(
         id,
         size.small
     )

// ─────────────────────────────────────────────────────────────────────────────
// LIVE UPDATE
// ─────────────────────────────────────────────────────────────────────────────

if barstate.islast

    // Stops
    updateLine(
         longStopLine,
         showLong,
         longStop,
         stopColor
     )

    updateLine(
         shortStopLine,
         showShort,
         shortStop,
         stopColor
     )

    updateLabel(
         longStopLabel,
         showLong,
         longStop,
         "LONG SL  -" + stopText,
         stopColor
     )

    updateLabel(
         shortStopLabel,
         showShort,
         shortStop,
         "SHORT SL  +" + stopText,
         stopColor
     )

    // Take profits
    updateLine(
         longTPLine,
         showTP and showLong,
         longTP,
         tpColor
     )

    updateLine(
         shortTPLine,
         showTP and showShort,
         shortTP,
         tpColor
     )

    updateLabel(
         longTPLabel,
         showTP and showLong,
         longTP,
         "LONG TP  +" + tpText,
         tpColor
     )

    updateLabel(
         shortTPLabel,
         showTP and showShort,
         shortTP,
         "SHORT TP  -" + tpText,
         tpColor
     )

    // Optional live-price anchor.
    updateLine(
         anchorLine,
         showAnchor,
         anchor,
         anchorColor
     )
````
