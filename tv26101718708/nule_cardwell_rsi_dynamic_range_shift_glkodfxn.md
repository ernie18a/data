# Nule Cardwell RSI - Dynamic Range Shift

- url: https://www.tradingview.com/script/GLkodfXN-Nule-Cardwell-RSI-Dynamic-Range-Shift/
- type: indicator
- pine_id: PUB;f712214a90de4445b23208fb748795ec
- version: 1.0

## Description

Cardwell RSI — Quick Use Guide

For your daily swing trading, use the indicator mainly to identify the market's momentum regime and then confirm your price setup.

1. Check the State

* 🔵 RSI > 60 → BULLISH → favour long setups.
* ⚪ RSI 40–60 → LATERAL → wait for clearer direction.
* 🔴 RSI < 40 → BEARISH → avoid fresh longs / be cautious.

2. Watch 40 & 60

* In a bullish phase, 40 acts as support.
* In a bearish phase, 60 acts as resistance.
* A move back through these levels can signal a change in momentum.

3. Use the RSI MA

* Recommended: EMA 9.
* RSI above a rising EMA 9 → improving momentum.
* RSI below a falling EMA 9 → weakening momentum.
* Frequent crossings → likely consolidation.

4. Use Divergences

* Regular divergence → possible trend/momentum reversal.
* Hidden divergence → possible trend continuation.
* Particularly useful for managing an existing swing trade.

* 🔴 Red circle = Regular Bearish Divergence
* 🔵 Blue diamond = Hidden Bullish Divergence

5. Combine it with your price setup

Your workflow should be:

Price trend → Setup → Volume → Cardwell RSI → Entry

For example:

> Stock above 21/50 EMA + bullish price setup + RSI >60 + RSI above rising EMA 9
> = good bullish confirmation

### One-line rule

Above 60 = ride bullish momentum | 40–60 = wait | Below 40 = respect bearish momentum.

The indicator should therefore be treated as a confirmation/filter, not as a standalone buy/sell signal.

## Source Code

````pine
//@version=6
indicator("Nule Cardwell RSI - Dynamic Range Shift", shorttitle="Cardwell RSI", overlay=false, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupRSI = "RSI Settings"

rsiLength = input.int(14, "RSI Length", minval=2, group=groupRSI)
smoothLen = input.int(1, "RSI Smoothing", minval=1, group=groupRSI)
confirmBars = input.int(2, "Range Shift Confirmation", minval=1, maxval=10, group=groupRSI)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI MOVING AVERAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMA = "RSI Moving Average"

showMA = input.bool(false, "Show MA", group=groupMA)
maLength = input.int(14, "MA Length", minval=1, group=groupMA)
maType = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA", "RMA", "HMA"], group=groupMA)
maWidth = input.int(1, "MA Width", minval=1, maxval=3, group=groupMA)
maColorInput = input.color(color.orange, "MA Color", group=groupMA)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupVisual = "Visual Settings"

showShading = input.bool(true, "Range Shading", group=groupVisual)
showLevels = input.bool(true, "Show RSI Levels", group=groupVisual)
darkMode = input.bool(false, "Dark Mode", group=groupVisual)
showDashboard = input.bool(true, "Dashboard", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIVERGENCE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDiv = "Divergence"

showDiv = input.bool(true, "Show Divergences", group=groupDiv)
pivotLeft = input.int(5, "Pivot Left", minval=1, group=groupDiv)
pivotRight = input.int(5, "Pivot Right", minval=1, group=groupDiv)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullLight = color.rgb(35, 105, 235)
bearLight = color.rgb(220, 60, 60)

bullDark = color.rgb(70, 155, 255)
bearDark = color.rgb(255, 85, 85)

bullColor = darkMode ? bullDark : bullLight
bearColor = darkMode ? bearDark : bearLight

neutralColor = darkMode ? color.rgb(185, 185, 185) : color.rgb(70, 70, 70)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiRaw = ta.rsi(close, rsiLength)

rsi = smoothLen > 1 ? ta.sma(rsiRaw, smoothLen) : rsiRaw

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CROSS CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
crossedAbove60 = ta.crossover(rsi, 60)
crossedBelow60 = ta.crossunder(rsi, 60)

crossedAbove40 = ta.crossover(rsi, 40)
crossedBelow40 = ta.crossunder(rsi, 40)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CARDWELL RANGE-SHIFT STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int state = 0
var int bullBars = 0
var int bearBars = 0

bullCondition = rsi > 60
bearCondition = rsi < 40

bullBars := bullCondition ? bullBars + 1 : 0
bearBars := bearCondition ? bearBars + 1 : 0

bullShift = bullBars >= confirmBars and state != 1
bearShift = bearBars >= confirmBars and state != -1

if bullShift
    state := 1

if bearShift
    state := -1

// Immediate visual state
displayState = rsi > 60 ? 1 : rsi < 40 ? -1 : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiColor = rsi > 60 ? bullColor : rsi < 40 ? bearColor : neutralColor

plot(
     rsi,
     title="Cardwell RSI",
     color=rsiColor,
     linewidth=2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI MOVING AVERAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiMA =
     maType == "SMA" ? ta.sma(rsi, maLength) :
     maType == "EMA" ? ta.ema(rsi, maLength) :
     maType == "WMA" ? ta.wma(rsi, maLength) :
     maType == "RMA" ? ta.rma(rsi, maLength) :
     ta.hma(rsi, maLength)

plot(
     showMA ? rsiMA : na,
     title="RSI Moving Average",
     color=maColorInput,
     linewidth=maWidth
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI LEVEL COLORS
// 20 / 60 = RED
// 40 / 80 = BLUE
// 50 = GREY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
level20 = darkMode ? color.new(color.red, 25) : color.new(color.red, 35)
level40 = darkMode ? color.new(color.blue, 20) : color.new(color.blue, 30)
level50 = darkMode ? color.new(color.gray, 60) : color.new(color.gray, 75)
level60 = darkMode ? color.new(color.red, 20) : color.new(color.red, 30)
level80 = darkMode ? color.new(color.blue, 20) : color.new(color.blue, 30)

h20 = hline(
     20,
     "20",
     color=level20,
     linestyle=hline.style_dotted,
     display=showLevels ? display.all : display.none
)

h40 = hline(
     40,
     "40",
     color=level40,
     linewidth=1,
     display=showLevels ? display.all : display.none
)

h50 = hline(
     50,
     "50",
     color=level50,
     linestyle=hline.style_dotted,
     display=showLevels ? display.all : display.none
)

h60 = hline(
     60,
     "60",
     color=level60,
     linewidth=1,
     display=showLevels ? display.all : display.none
)

h80 = hline(
     80,
     "80",
     color=level80,
     linestyle=hline.style_dotted,
     display=showLevels ? display.all : display.none
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC RANGE SHADING
//
// RSI > 60
// 80-60 = BLUE
// 60-40 = BLUE
// 40-20 = WHITE
//
// RSI 40-60
// 80-60 = BLUE
// 60-40 = GREY
// 40-20 = RED
//
// RSI < 40
// 80-60 = WHITE
// 60-40 = RED
// 40-20 = RED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
blueRangeColor =
     darkMode
     ? color.new(color.rgb(70, 155, 255), 89)
     : color.new(color.rgb(35, 105, 235), 94)

greyRangeColor =
     darkMode
     ? color.new(color.rgb(145, 145, 145), 87)
     : color.new(color.rgb(135, 135, 135), 91)

redRangeColor =
     darkMode
     ? color.new(color.rgb(255, 85, 85), 89)
     : color.new(color.rgb(220, 60, 60), 94)

whiteRangeColor =
     darkMode
     ? color.new(color.white, 88)
     : color.new(color.rgb(210, 210, 210), 92)

// 60-80
upperShade =
     showShading
     ? rsi < 40
         ? whiteRangeColor
         : blueRangeColor
     : na

fill(
     h60,
     h80,
     color=upperShade,
     title="Dynamic 60-80"
)

// 40-60
middleShade =
     showShading
     ? rsi > 60
         ? blueRangeColor
         : rsi >= 40
             ? greyRangeColor
             : redRangeColor
     : na

fill(
     h40,
     h60,
     color=middleShade,
     title="Dynamic 40-60"
)

// 20-40
lowerShade =
     showShading
     ? rsi > 60
         ? whiteRangeColor
         : redRangeColor
     : na

fill(
     h20,
     h40,
     color=lowerShade,
     title="Dynamic 20-40"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RANGE SHIFT MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     bullShift ? rsi : na,
     title="Bullish Range Shift",
     style=shape.circle,
     location=location.absolute,
     color=bullColor,
     size=size.tiny
)

plotshape(
     bearShift ? rsi : na,
     title="Bearish Range Shift",
     style=shape.circle,
     location=location.absolute,
     color=bearColor,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiLowPivot = ta.pivotlow(rsi, pivotLeft, pivotRight)
rsiHighPivot = ta.pivothigh(rsi, pivotLeft, pivotRight)

var float previousRsiLow = na
var float previousPriceLow = na

var float previousRsiHigh = na
var float previousPriceHigh = na

bool regularBull = false
bool hiddenBull = false
bool regularBear = false
bool hiddenBear = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BULLISH DIVERGENCES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not na(rsiLowPivot)

    currentRsiLow = rsi[pivotRight]
    currentPriceLow = low[pivotRight]

    if not na(previousRsiLow)

        // Regular Bullish:
        // Price = Lower Low
        // RSI   = Higher Low
        regularBull :=
             currentPriceLow < previousPriceLow and
             currentRsiLow > previousRsiLow

        // Hidden Bullish:
        // Price = Higher Low
        // RSI   = Lower Low
        hiddenBull :=
             currentPriceLow > previousPriceLow and
             currentRsiLow < previousRsiLow

    previousRsiLow := currentRsiLow
    previousPriceLow := currentPriceLow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BEARISH DIVERGENCES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not na(rsiHighPivot)

    currentRsiHigh = rsi[pivotRight]
    currentPriceHigh = high[pivotRight]

    if not na(previousRsiHigh)

        // Regular Bearish:
        // Price = Higher High
        // RSI   = Lower High
        regularBear :=
             currentPriceHigh > previousPriceHigh and
             currentRsiHigh < previousRsiHigh

        // Hidden Bearish:
        // Price = Lower High
        // RSI   = Higher High
        hiddenBear :=
             currentPriceHigh < previousPriceHigh and
             currentRsiHigh > previousRsiHigh

    previousRsiHigh := currentRsiHigh
    previousPriceHigh := currentPriceHigh

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIVERGENCE MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     showDiv and regularBull ? rsi[pivotRight] : na,
     title="Regular Bullish Divergence",
     style=shape.circle,
     location=location.absolute,
     color=color.red,
     size=size.tiny,
     offset=-pivotRight
)

plotshape(
     showDiv and hiddenBull ? rsi[pivotRight] : na,
     title="Hidden Bullish Divergence",
     style=shape.diamond,
     location=location.absolute,
     color=bullColor,
     size=size.tiny,
     offset=-pivotRight
)

plotshape(
     showDiv and regularBear ? rsi[pivotRight] : na,
     title="Regular Bearish Divergence",
     style=shape.circle,
     location=location.absolute,
     color=bearColor,
     size=size.tiny,
     offset=-pivotRight
)

plotshape(
     showDiv and hiddenBear ? rsi[pivotRight] : na,
     title="Hidden Bearish Divergence",
     style=shape.diamond,
     location=location.absolute,
     color=bearColor,
     size=size.tiny,
     offset=-pivotRight
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dashboard = table.new(
     position.top_right,
     2,
     5,
     border_width=0
)

// State
phaseText =
     displayState == 1
         ? "BULLISH"
         : displayState == -1
             ? "BEARISH"
             : "LATERAL"

// Correct Cardwell zones
zoneText =
     displayState == 1
         ? "40 - 80"
         : displayState == -1
             ? "20 - 60"
             : "40 - 60"

// RSI directional bias
directionText =
     rsi > rsi[1]
         ? "RISING  ↗"
         : rsi < rsi[1]
             ? "FALLING  ↘"
             : "FLAT  →"

// Key level
keyText =
     displayState == 1
         ? "40 SUPPORT"
         : displayState == -1
             ? "60 RESISTANCE"
             : "40 - 60 RANGE"

// Dashboard state color
phaseColor =
     displayState == 1
         ? bullColor
         : displayState == -1
             ? bearColor
             : neutralColor

// Dashboard backgrounds
panelBG =
     darkMode
         ? color.new(color.black, 10)
         : color.new(color.white, 10)

panelText =
     darkMode
         ? color.white
         : color.black

// Slightly muted label background
labelBG =
     darkMode
         ? color.new(color.black, 25)
         : color.new(color.white, 15)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast

    if showDashboard

        // RSI
        table.cell(
             dashboard,
             0,
             0,
             "RSI",
             text_color=panelText,
             bgcolor=labelBG,
             text_size=size.tiny
        )

        table.cell(
             dashboard,
             1,
             0,
             str.tostring(rsi, "#.0"),
             text_color=color.white,
             bgcolor=phaseColor,
             text_size=size.tiny
        )

        // STATE
        table.cell(
             dashboard,
             0,
             1,
             "STATE",
             text_color=panelText,
             bgcolor=labelBG,
             text_size=size.tiny
        )

        table.cell(
             dashboard,
             1,
             1,
             phaseText,
             text_color=color.white,
             bgcolor=phaseColor,
             text_size=size.tiny
        )

        // ZONE
        table.cell(
             dashboard,
             0,
             2,
             "ZONE",
             text_color=panelText,
             bgcolor=labelBG,
             text_size=size.tiny
        )

        table.cell(
             dashboard,
             1,
             2,
             zoneText,
             text_color=color.white,
             bgcolor=phaseColor,
             text_size=size.tiny
        )

        // BIAS
        table.cell(
             dashboard,
             0,
             3,
             "BIAS",
             text_color=panelText,
             bgcolor=labelBG,
             text_size=size.tiny
        )

        table.cell(
             dashboard,
             1,
             3,
             directionText,
             text_color=color.white,
             bgcolor=phaseColor,
             text_size=size.tiny
        )

        // KEY
        table.cell(
             dashboard,
             0,
             4,
             "KEY",
             text_color=panelText,
             bgcolor=labelBG,
             text_size=size.tiny
        )

        table.cell(
             dashboard,
             1,
             4,
             keyText,
             text_color=color.white,
             bgcolor=phaseColor,
             text_size=size.tiny
        )

    else

        table.clear(
             dashboard,
             0,
             0,
             1,
             4
        )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     bullShift,
     title="Cardwell Bullish Range Shift",
     message="Cardwell RSI shifted into Bullish range."
)

alertcondition(
     bearShift,
     title="Cardwell Bearish Range Shift",
     message="Cardwell RSI shifted into Bearish range."
)

alertcondition(
     crossedBelow60,
     title="Cardwell RSI Lost 60",
     message="Cardwell RSI crossed below 60."
)

alertcondition(
     crossedAbove60,
     title="Cardwell RSI Reclaimed 60",
     message="Cardwell RSI crossed above 60."
)

alertcondition(
     crossedBelow40,
     title="Cardwell RSI Lost 40",
     message="Cardwell RSI crossed below 40."
)

alertcondition(
     crossedAbove40,
     title="Cardwell RSI Reclaimed 40",
     message="Cardwell RSI crossed above 40."
)

alertcondition(
     regularBull,
     title="Regular Bullish RSI Divergence",
     message="Regular Bullish RSI divergence detected."
)

alertcondition(
     regularBear,
     title="Regular Bearish RSI Divergence",
     message="Regular Bearish RSI divergence detected."
)

alertcondition(
     hiddenBull,
     title="Hidden Bullish RSI Divergence",
     message="Hidden Bullish RSI divergence detected."
)

alertcondition(
     hiddenBear,
     title="Hidden Bearish RSI Divergence",
     message="Hidden Bearish RSI divergence detected."
)
````
