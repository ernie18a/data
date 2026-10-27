# Erfy CVD

- url: https://www.tradingview.com/script/iYCOIeq3-Erfy-CVD/
- type: indicator
- pine_id: PUB;60ececbf2b4942bfbd947dc738c5fd8e
- version: 1.0

## Description

Erfy CVD is a divergence indicator designed to identify potential reversals by comparing price movement with estimated cumulative volume delta.

A bullish divergence appears when price forms a lower low while CVD forms a higher low, suggesting that selling pressure may be weakening.

A bearish divergence appears when price forms a higher high while CVD forms a lower high, suggesting that buying pressure may be weakening.

The indicator confirms signals one candle after the pivot and automatically removes a divergence when its price level is swept. The CVD is estimated using candle volume and closing position because Pine Script does not provide true bid-and-ask order-flow data.

This indicator should be used as confirmation alongside market structure, liquidity, volume profile and other forms of analysis. It should not be treated as a standalone buy or sell signal.

## Source Code

````pine
//@version=6
indicator(
     title = "Clean CVD Divergence",
     shorttitle = "Erfy CVD",
     overlay = true,
     max_lines_count = 200,
     max_labels_count = 200
)

//=====================================================================
// SETTINGS
//=====================================================================

int pivotLength = input.int(
     1,
     "Pivot strength",
     minval = 1,
     maxval = 20,
     group = "Detection"
)

string cvdResetMode = input.string(
     "Session",
     "CVD reset",
     options = ["Session", "Continuous"],
     group = "CVD"
)

string sessionTime = input.session(
     "1800-1700",
     "Trading session",
     group = "CVD"
)

string timezone = input.string(
     "America/New_York",
     "Session timezone",
     group = "CVD"
)

bool resetPivots = input.bool(
     true,
     "Reset pivots each session",
     group = "CVD"
)

//=====================================================================
// APPEARANCE
//=====================================================================

color bullColor = input.color(
     color.rgb(20, 210, 150),
     "Bullish colour",
     group = "Appearance"
)

color bearColor = input.color(
     color.rgb(245, 80, 100),
     "Bearish colour",
     group = "Appearance"
)

string markerStyle = input.string(
     "Arrow",
     "Signal marker",
     options = ["Arrow", "Label", "None"],
     group = "Appearance"
)

string markerSizeInput = input.string(
     "Tiny",
     "Marker size",
     options = ["Tiny", "Small", "Normal"],
     group = "Appearance"
)

string lineStyleInput = input.string(
     "Dotted",
     "Line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = "Appearance"
)

int lineWidth = input.int(
     2,
     "Line width",
     minval = 1,
     maxval = 4,
     group = "Appearance"
)

int lineTransparency = input.int(
     15,
     "Line transparency",
     minval = 0,
     maxval = 90,
     group = "Appearance"
)

int markerTransparency = input.int(
     5,
     "Marker transparency",
     minval = 0,
     maxval = 90,
     group = "Appearance"
)

//=====================================================================
// STYLE CONVERSION
//=====================================================================

string selectedLineStyle = switch lineStyleInput
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

string selectedMarkerSize = switch markerSizeInput
    "Small" => size.small
    "Normal" => size.normal
    => size.tiny

//=====================================================================
// ESTIMATED CVD
//=====================================================================

bool inSession = not na(
     time(timeframe.period, sessionTime, timezone)
)

bool previousBarInSession = (
     bar_index > 0 and
     inSession[1]
)

bool newSession = (
     cvdResetMode == "Session" and
     inSession and
     (not previousBarInSession or barstate.isfirst)
)

float candleRange = math.max(
     high - low,
     syminfo.mintick
)

float estimatedBuyVolume = (
     volume * (close - low) / candleRange
)

float estimatedSellVolume = (
     volume * (high - close) / candleRange
)

float estimatedDelta = (
     estimatedBuyVolume - estimatedSellVolume
)

var float estimatedCVD = 0.0

if newSession
    estimatedCVD := estimatedDelta
else
    estimatedCVD += estimatedDelta

//=====================================================================
// PRICE PIVOTS
//=====================================================================

float pivotLow = ta.pivotlow(
     low,
     pivotLength,
     pivotLength
)

float pivotHigh = ta.pivothigh(
     high,
     pivotLength,
     pivotLength
)

int currentPivotBar = (
     bar_index - pivotLength
)

float cvdAtLow = (
     not na(pivotLow) ?
     estimatedCVD[pivotLength] :
     na
)

float cvdAtHigh = (
     not na(pivotHigh) ?
     estimatedCVD[pivotLength] :
     na
)

//=====================================================================
// STORED PIVOTS
//=====================================================================

var int previousLowBar = na
var float previousLowPrice = na
var float previousLowCVD = na

var int previousHighBar = na
var float previousHighPrice = na
var float previousHighCVD = na

if resetPivots and newSession
    previousLowBar := na
    previousLowPrice := na
    previousLowCVD := na

    previousHighBar := na
    previousHighPrice := na
    previousHighCVD := na

// Alert events are reset on every bar.
bool bullishSignal = false
bool bearishSignal = false

//=====================================================================
// BULLISH CVD DIVERGENCE
// Price makes a lower low while CVD makes a higher low.
//=====================================================================

if not na(pivotLow)
    bullishSignal := (
         not na(previousLowPrice) and
         not na(previousLowCVD) and
         pivotLow < previousLowPrice and
         cvdAtLow > previousLowCVD
    )

    if bullishSignal
        line.new(
             x1 = previousLowBar,
             y1 = previousLowPrice,
             x2 = currentPivotBar,
             y2 = pivotLow,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(
                  bullColor,
                  lineTransparency
             ),
             style = selectedLineStyle,
             width = lineWidth
        )

        if markerStyle == "Arrow"
            label.new(
                 x = currentPivotBar,
                 y = pivotLow,
                 text = "▲",
                 xloc = xloc.bar_index,
                 yloc = yloc.belowbar,
                 style = label.style_none,
                 color = color.new(color.black, 100),
                 textcolor = color.new(
                      bullColor,
                      markerTransparency
                 ),
                 size = selectedMarkerSize
            )

        if markerStyle == "Label"
            label.new(
                 x = currentPivotBar,
                 y = pivotLow,
                 text = "CVD +",
                 xloc = xloc.bar_index,
                 yloc = yloc.belowbar,
                 style = label.style_label_up,
                 color = color.new(
                      bullColor,
                      markerTransparency
                 ),
                 textcolor = color.black,
                 size = selectedMarkerSize
            )

    previousLowBar := currentPivotBar
    previousLowPrice := pivotLow
    previousLowCVD := cvdAtLow

//=====================================================================
// BEARISH CVD DIVERGENCE
// Price makes a higher high while CVD makes a lower high.
//=====================================================================

if not na(pivotHigh)
    bearishSignal := (
         not na(previousHighPrice) and
         not na(previousHighCVD) and
         pivotHigh > previousHighPrice and
         cvdAtHigh < previousHighCVD
    )

    if bearishSignal
        line.new(
             x1 = previousHighBar,
             y1 = previousHighPrice,
             x2 = currentPivotBar,
             y2 = pivotHigh,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(
                  bearColor,
                  lineTransparency
             ),
             style = selectedLineStyle,
             width = lineWidth
        )

        if markerStyle == "Arrow"
            label.new(
                 x = currentPivotBar,
                 y = pivotHigh,
                 text = "▼",
                 xloc = xloc.bar_index,
                 yloc = yloc.abovebar,
                 style = label.style_none,
                 color = color.new(color.black, 100),
                 textcolor = color.new(
                      bearColor,
                      markerTransparency
                 ),
                 size = selectedMarkerSize
            )

        if markerStyle == "Label"
            label.new(
                 x = currentPivotBar,
                 y = pivotHigh,
                 text = "CVD −",
                 xloc = xloc.bar_index,
                 yloc = yloc.abovebar,
                 style = label.style_label_down,
                 color = color.new(
                      bearColor,
                      markerTransparency
                 ),
                 textcolor = color.white,
                 size = selectedMarkerSize
            )

    previousHighBar := currentPivotBar
    previousHighPrice := pivotHigh
    previousHighCVD := cvdAtHigh

//=====================================================================
// ALERTS
//=====================================================================

alertcondition(
     bullishSignal,
     title = "Bullish CVD Divergence",
     message = "Bullish CVD divergence confirmed."
)

alertcondition(
     bearishSignal,
     title = "Bearish CVD Divergence",
     message = "Bearish CVD divergence confirmed."
)
````
