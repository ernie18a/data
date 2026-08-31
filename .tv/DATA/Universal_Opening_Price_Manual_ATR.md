<!-- tradingview-pine-id: PUB;2740f181786247fda9fb076ed1762210 -->
<!-- tradingviewscripts-format: 1 -->
# Universal Opening Price ± Manual ATR

Source: https://www.tradingview.com/script/1Zb1Gn4c-Universal-Opening-Price-Manual-ATR/

## Description

A indicator helping you identify strike based on manually entering the dialy ATR

---

## Source Code

````pine
//@version=6
indicator("Universal Opening Price ± Manual ATR", overlay = true)

// =====================================================
// SETTINGS
// =====================================================

// Manually enter the ATR-based distance you want
manualDistance = input.float(
     7.0,
     "Manual ATR Distance",
     minval = 0.01,
     step = 0.25
)

// Opening time in New York time
openHour = input.int(
     9,
     "Opening Hour — New York Time",
     minval = 0,
     maxval = 23
)

openMinute = input.int(
     30,
     "Opening Minute — New York Time",
     minval = 0,
     maxval = 59
)

// Display settings
showLabels = input.bool(true, "Show Current-Day Labels")
showOpenMarker = input.bool(false, "Mark Opening Candle")

string marketTimeZone = "America/New_York"

// =====================================================
// CAPTURE THE SELECTED OPENING PRICE
// =====================================================

bool isOpeningBar =
     hour(time, marketTimeZone) == openHour and
     minute(time, marketTimeZone) == openMinute

var float openingPrice = na

if isOpeningBar
    openingPrice := open

// =====================================================
// CALCULATE LEVELS
// =====================================================

float upperLevel =
     not na(openingPrice) ?
     openingPrice + manualDistance :
     na

float lowerLevel =
     not na(openingPrice) ?
     openingPrice - manualDistance :
     na

// =====================================================
// HISTORICAL STEPPED LINES
// =====================================================

plot(
     upperLevel,
     title = "Upper Manual ATR Level",
     color = color.green,
     linewidth = 2,
     style = plot.style_stepline
)

plot(
     openingPrice,
     title = "Opening Price",
     color = color.yellow,
     linewidth = 2,
     style = plot.style_stepline
)

plot(
     lowerLevel,
     title = "Lower Manual ATR Level",
     color = color.red,
     linewidth = 2,
     style = plot.style_stepline
)

// =====================================================
// OPTIONAL OPENING-CANDLE MARKER
// =====================================================

plotshape(
     showOpenMarker and isOpeningBar,
     title = "Opening Candle",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.yellow,
     size = size.tiny,
     text = "OPEN"
)

// =====================================================
// CURRENT-DAY LABELS
// =====================================================

var label upperLabel = na
var label openLabel = na
var label lowerLabel = na

if barstate.islast
    label.delete(upperLabel)
    label.delete(openLabel)
    label.delete(lowerLabel)

    if showLabels and not na(openingPrice)
        upperLabel := label.new(
             x = bar_index,
             y = upperLevel,
             text =
                 "+" + str.tostring(manualDistance) +
                 ": " +
                 str.tostring(upperLevel, format.mintick),
             style = label.style_label_left,
             color = color.green,
             textcolor = color.white
        )

        openLabel := label.new(
             x = bar_index,
             y = openingPrice,
             text =
                 "OPEN: " +
                 str.tostring(openingPrice, format.mintick),
             style = label.style_label_left,
             color = color.yellow,
             textcolor = color.black
        )

        lowerLabel := label.new(
             x = bar_index,
             y = lowerLevel,
             text =
                 "-" + str.tostring(manualDistance) +
                 ": " +
                 str.tostring(lowerLevel, format.mintick),
             style = label.style_label_left,
             color = color.red,
             textcolor = color.white
        )
````
