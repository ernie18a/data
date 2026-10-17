# Live Price Pro  Candle Timer & SL/TP Distance

- url: https://www.tradingview.com/script/cydxB1Iy-Live-Price-Pro-Candle-Timer-SL-TP-Distance/
- type: indicator
- pine_id: PUB;e2f36a13c63341e2b19ccaf86bc9f1cd
- version: 1.0

## Description

This indicator provides a clean, customizable information panel directly on your TradingView chart. It displays the current market price, the remaining time before the active candle closes, and the live distance from the current market price to your Entry, Take Profit, and Stop Loss levels.

It is especially useful for traders who want to monitor their trade levels without repeatedly calculating price distance manually.

Main features
Live market price display
Real-time countdown to candle close
Manual Entry, Take Profit, and Stop Loss inputs
Automatic distance calculation from the current market price
Distance display in:
Price
Points
Percentage
Price and points
Price and percentage
Bullish and bearish price colors
Dark or Bull/Bear background mode
Adjustable panel size
Full panel positioning across the chart
How to use the indicator

After adding the indicator to your chart, open the indicator settings.

Under Trade Levels, enter your planned:

Entry Price
Take Profit Price
Stop Loss Price

The panel will automatically calculate the distance between the current market price and each level.

For example:

Current Price: 4069.17
Entry: 4065.00
Distance: -4.17

Take Profit: 4080.00
Distance: +10.83

Stop Loss: 4060.00
Distance: -9.17

A positive value means the level is above the current market price. A negative value means the level is below the current market price.

Candle countdown

The candle timer shows the remaining time before the current candle closes.

The timer automatically adapts to the selected chart timeframe. For example:

On a 5-minute chart, it counts down to the next 5-minute candle.
On a 1-hour chart, it counts down to the next hourly candle.
On higher timeframes, it can display hours or days when required.

The timer uses the actual candle closing time provided by TradingView.

Distance modes

You can choose how the distance is displayed.

Price

Shows the direct price difference.

+10.83

Points

Shows the distance in minimum tick increments based on the symbol.

+1083 pts

Percentage

Shows the percentage difference from the current market price.

+0.27%

Price + Points

Shows both the price difference and point distance.

+10.83 | +1083 pts

Price + Percentage

Shows both the price difference and percentage distance.

+10.83 | +0.27%
Panel positioning

The panel can be placed in any of the following chart positions:

Top Left
Top Center
Top Right
Middle Left
Middle Center
Middle Right
Bottom Left
Bottom Center
Bottom Right

This allows the panel to be positioned away from candles, indicators, or other chart elements.

Customization

Users can customize:

Panel position
Panel size
Background mode
Background transparency
Bullish price color
Bearish price color
Entry color
Take Profit color
Stop Loss color
Timer and text color
Which panel rows are visible
Important notes

The Entry, Take Profit, and Stop Loss levels are entered manually. The indicator does not place, manage, or execute trades.

A value of 0 means that the selected trade level has not been configured.

Point values depend on the symbol’s minimum tick size. Therefore, the meaning of “points” may differ between gold, forex, indices, cryptocurrencies, and other markets.

The live price is based on the current chart price and may differ slightly from the executable bid or ask price shown by a broker.

Suitable for

This indicator can be used for:

Gold trading
Forex trading
Indices
Cryptocurrencies
Intraday trading
Scalping
Swing trading
Manual trade planning
Risk and target monitoring
Disclaimer

This indicator is intended for informational and educational purposes only. It does not provide financial advice, trade signals, or guaranteed results. Traders remain fully responsible for their own entries, exits, position sizing, and risk management.

## Source Code

````pine
//@version=6
indicator("LIVE PRICE + TIMER + TARGET DISTANCE", overlay=true)

//====================================================
// PANEL SETTINGS
//====================================================

panelPos = input.string(
     "Bottom Center",
     "Panel Position",
     options=[
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     group="Panel"
)

mode = input.string(
     "Dark",
     "Background Mode",
     options=["Dark", "Bull/Bear"],
     group="Panel"
)

sizeInput = input.string(
     "Medium",
     "Panel Size",
     options=["Small", "Medium", "Large"],
     group="Panel"
)

transp = input.int(
     80,
     "Background Transparency",
     minval=0,
     maxval=100,
     group="Panel"
)

//====================================================
// DISPLAY SETTINGS
//====================================================

showPrice = input.bool(true, "Show Live Price", group="Display")
showTimer = input.bool(true, "Show Candle Timer", group="Display")

showEntry = input.bool(true, "Show Entry", group="Display")
showTP = input.bool(true, "Show Take Profit", group="Display")
showSL = input.bool(true, "Show Stop Loss", group="Display")

distanceMode = input.string(
     "Price + Points",
     "Distance Display",
     options=[
         "Price",
         "Points",
         "Percentage",
         "Price + Points",
         "Price + Percentage"
     ],
     group="Display"
)

//====================================================
// TRADE LEVEL SETTINGS
//====================================================

entryPrice = input.float(
     0.0,
     "Entry Price",
     step=0.01,
     group="Trade Levels"
)

takeProfitPrice = input.float(
     0.0,
     "Take Profit Price",
     step=0.01,
     group="Trade Levels"
)

stopLossPrice = input.float(
     0.0,
     "Stop Loss Price",
     step=0.01,
     group="Trade Levels"
)

//====================================================
// COLOR SETTINGS
//====================================================

priceUp = input.color(color.lime, "Bullish Price", group="Colors")
priceDown = input.color(color.red, "Bearish Price", group="Colors")

entryColor = input.color(color.aqua, "Entry Color", group="Colors")
tpColor = input.color(color.lime, "Take Profit Color", group="Colors")
slColor = input.color(color.red, "Stop Loss Color", group="Colors")

textColor = input.color(color.white, "Timer/Text Color", group="Colors")

//====================================================
// PANEL POSITION
//====================================================

pos = switch panelPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

//====================================================
// TEXT SIZE
//====================================================

textSize = switch sizeInput
    "Small"  => size.small
    "Large"  => size.huge
    => size.large

//====================================================
// LIVE MARKET PRICE
//====================================================

marketPrice = close
isBull = close >= open

priceColor = isBull ? priceUp : priceDown

bgColor = mode == "Dark" ?
     color.new(color.black, transp) :
     isBull ?
         color.new(priceUp, transp) :
         color.new(priceDown, transp)

//====================================================
// CANDLE COUNTDOWN TIMER
// Uses the actual closing time of the current candle.
//====================================================

remainingMilliseconds = time_close - timenow
remainingMilliseconds := math.max(remainingMilliseconds, 0)

totalSeconds = int(math.floor(remainingMilliseconds / 1000))

daysLeft = int(math.floor(totalSeconds / 86400))
hoursLeft = int(math.floor((totalSeconds % 86400) / 3600))
minutesLeft = int(math.floor((totalSeconds % 3600) / 60))
secondsLeft = int(totalSeconds % 60)

hoursStr = hoursLeft < 10 ?
     "0" + str.tostring(hoursLeft) :
     str.tostring(hoursLeft)

minutesStr = minutesLeft < 10 ?
     "0" + str.tostring(minutesLeft) :
     str.tostring(minutesLeft)

secondsStr = secondsLeft < 10 ?
     "0" + str.tostring(secondsLeft) :
     str.tostring(secondsLeft)

timeText = daysLeft > 0 ?
     str.tostring(daysLeft) + "D " +
     hoursStr + ":" +
     minutesStr + ":" +
     secondsStr :
     hoursLeft > 0 ?
         hoursStr + ":" +
         minutesStr + ":" +
         secondsStr :
         minutesStr + ":" +
         secondsStr

//====================================================
// DISTANCE CALCULATION FUNCTIONS
//====================================================

// Signed number: positive values receive a "+" symbol.
formatSigned(float value) =>
    value > 0 ?
         "+" + str.tostring(value, format.mintick) :
         str.tostring(value, format.mintick)

// Number of minimum tick increments between market and level.
calculatePoints(float level) =>
    syminfo.mintick > 0 ?
         (level - marketPrice) / syminfo.mintick :
         0.0

// Percentage distance from current market price.
calculatePercentage(float level) =>
    marketPrice != 0 ?
         ((level - marketPrice) / marketPrice) * 100 :
         0.0

// Build the distance text according to selected mode.
distanceText(float level) =>
    priceDistance = level - marketPrice
    pointsDistance = calculatePoints(level)
    percentageDistance = calculatePercentage(level)

    priceText = formatSigned(priceDistance)
    pointsText = pointsDistance > 0 ?
         "+" + str.tostring(pointsDistance, "#") :
         str.tostring(pointsDistance, "#")
    percentText = percentageDistance > 0 ?
         "+" + str.tostring(percentageDistance, "#.##") + "%" :
         str.tostring(percentageDistance, "#.##") + "%"

    switch distanceMode
        "Price" =>
            priceText

        "Points" =>
            pointsText + " pts"

        "Percentage" =>
            percentText

        "Price + Percentage" =>
            priceText + " | " + percentText

        =>
            priceText + " | " + pointsText + " pts"

//====================================================
// LEVEL VALIDATION
// A value of 0.0 means that the level is not configured.
//====================================================

entryConfigured = entryPrice > 0
tpConfigured = takeProfitPrice > 0
slConfigured = stopLossPrice > 0

entryText = entryConfigured ?
     "ENTRY: " +
     str.tostring(entryPrice, format.mintick) +
     "   DIST: " +
     distanceText(entryPrice) :
     "ENTRY: NOT SET"

tpText = tpConfigured ?
     "TP: " +
     str.tostring(takeProfitPrice, format.mintick) +
     "   DIST: " +
     distanceText(takeProfitPrice) :
     "TP: NOT SET"

slText = slConfigured ?
     "SL: " +
     str.tostring(stopLossPrice, format.mintick) +
     "   DIST: " +
     distanceText(stopLossPrice) :
     "SL: NOT SET"

//====================================================
// TABLE
// Five rows:
// 1. Market price
// 2. Candle timer
// 3. Entry
// 4. Take Profit
// 5. Stop Loss
//====================================================

var table panel = table.new(
     pos,
     columns=1,
     rows=5,
     border_width=0
)

//====================================================
// RENDER PANEL
//====================================================

if barstate.islast
    table.cell(
         panel,
         0,
         0,
         showPrice ?
             "$: " + str.tostring(marketPrice, format.mintick) :
             "",
         text_size=textSize,
         text_color=priceColor,
         bgcolor=bgColor
    )

    table.cell(
         panel,
         0,
         1,
         showTimer ?
             "CANDLE CLOSE: " + timeText :
             "",
         text_size=textSize,
         text_color=textColor,
         bgcolor=bgColor
    )

    table.cell(
         panel,
         0,
         2,
         showEntry ? entryText : "",
         text_size=textSize,
         text_color=entryColor,
         bgcolor=bgColor
    )

    table.cell(
         panel,
         0,
         3,
         showTP ? tpText : "",
         text_size=textSize,
         text_color=tpColor,
         bgcolor=bgColor
    )

    table.cell(
         panel,
         0,
         4,
         showSL ? slText : "",
         text_size=textSize,
         text_color=slColor,
         bgcolor=bgColor
    )
````
