# Stop Loss & Position Size Calculator 

- url: https://www.tradingview.com/script/u71mmTje-Stop-Loss-Position-Size-Calculator/
- type: indicator
- pine_id: PUB;72070e7a110f4f2e82ff0e82f1ff4888
- version: 1.0

## Description

# Stop Loss & Position Size Calculator

This indicator is designed to help futures traders manage risk by visualizing stop loss levels based on their maximum risk amount, contract type, and position size.

The indicator calculates where your stop loss would be placed depending on how many contracts you want to trade. This allows you to quickly see the relationship between your entry price, stop loss distance, and dollar risk.

## Features

* Supports multiple futures contracts:

  * MNQ (Micro Nasdaq)
  * NQ (Nasdaq)
  * MES (Micro S&P 500)
  * ES (S&P 500)
  * MYM (Micro Dow Jones)
  * YM (Dow Jones)
  * Custom contracts

* Automatic point value calculation

* Custom point value option

* Long and Short trading direction

* Adjustable maximum risk amount

* Adjustable number of contracts displayed

* Custom colors for lines and labels

* Adjustable line extension settings

## Settings Explained

### Contract

Select the futures contract you are trading. The indicator automatically uses the correct dollar value per point.

If you are using another instrument, select **Custom** and enter the correct point value manually.

### Maximum Risk ($)

Enter the maximum amount of money you are willing to risk on the trade.

Example:

* Risk: $350
* MNQ point value: $2 per point

The indicator calculates the stop distance for each contract size.

### Trade Direction

Select:

* Long: Stop loss levels are calculated below the entry price.
* Short: Stop loss levels are calculated above the entry price.

### Entry Price

Enter your planned entry price.

If left at 0, the indicator automatically uses the current market price.

### Maximum Contracts Shown

Choose how many contract scenarios you want to display.

Example:

* 1 contract
* 2 contracts
* 3 contracts

This allows you to compare different position sizes quickly.

## Line Extension Settings

You can adjust how far the stop loss levels are displayed on the chart.

Options:

* Right Only: Shows levels only forward from the current price.
* Left + Right: Extends levels in both directions.
* Left Only: Extends levels backwards for historical analysis.
* Fixed Candles: Choose your own number of candles.

## How To Use

1. Select your futures contract.
2. Enter your maximum risk amount.
3. Choose Long or Short.
4. Enter your planned entry price.
5. Review the calculated stop loss levels for different contract sizes.

The indicator is intended as a risk management tool and should be combined with your own trading strategy, market analysis, and trade setup.

Always verify contract specifications and point values before trading live.

## Source Code

````pine
//@version=6
indicator("Stop Loss & Position Size Calculator v1.0", overlay=true, max_labels_count=50, max_lines_count=50)

//==================================================
// CONTRACT SETTINGS
//==================================================

contract = input.string(
     "MNQ",
     "Contract",
     options=["MNQ", "NQ", "MES", "ES", "MYM", "YM", "Custom"])

customPointValue = input.float(
     2.0,
     "Custom Point Value ($ per point)",
     step=0.25)

pointValue = switch contract
    "MNQ" => 2.0
    "NQ"  => 20.0
    "MES" => 5.0
    "ES"  => 50.0
    "MYM" => 0.5
    "YM"  => 5.0
    => customPointValue


//==================================================
// TRADE SETTINGS
//==================================================

risk = input.float(
     350,
     "Maximum Risk ($)",
     step=50)

direction = input.string(
     "Long",
     "Trade Direction",
     options=["Long", "Short"])

entryInput = input.float(
     0,
     "Entry Price (0 = Current Price)",
     step=0.25)

entryPrice = entryInput == 0 ? close : entryInput

maxContracts = input.int(
     3,
     "Maximum Contracts Shown",
     minval=1,
     maxval=10)


//==================================================
// DISPLAY SETTINGS
//==================================================

showLabels = input.bool(true, "Show Labels")

entryColor = input.color(color.yellow, "Entry Line Color")

stop1Color = input.color(color.red, "1 Contract Line Color")
stop2Color = input.color(color.orange, "2 Contract Line Color")
stop3Color = input.color(color.lime, "3 Contract Line Color")

entryLabelColor = input.color(color.yellow, "Entry Label Color")

stop1LabelColor = input.color(color.red, "1 Contract Label Color")
stop2LabelColor = input.color(color.orange, "2 Contract Label Color")
stop3LabelColor = input.color(color.lime, "3 Contract Label Color")

labelTextColor = input.color(color.white, "Label Text Color")

lineWidth = input.int(
     2,
     "Line Width",
     minval=1,
     maxval=5)


//==================================================
// LINE EXTENSION SETTINGS
//==================================================

extensionMode = input.string(
     "Left + Right",
     "Line Extension",
     options=[
          "Right Only",
          "Left + Right",
          "Left Only",
          "Fixed Candles"
     ])

extensionCandles = input.int(
     100,
     "Extension Candles",
     minval=1)


//==================================================
// CALCULATION
//==================================================

stopDistance(contractAmount) =>
    risk / (contractAmount * pointValue)

stopPrice(distance) =>
    direction == "Long" ? entryPrice - distance : entryPrice + distance


//==================================================
// LINE POSITIONS
//==================================================

lineStart = extensionMode == "Right Only" ? bar_index : bar_index - extensionCandles

lineEnd = extensionMode == "Left Only" ? bar_index : bar_index + extensionCandles


//==================================================
// OBJECT STORAGE
//==================================================

var line entryLine = na
var line[] stopLines = array.new_line()
var label[] labels = array.new_label()


//==================================================
// DRAW LINES
//==================================================

if barstate.islast

    if not na(entryLine)
        line.delete(entryLine)

    if array.size(stopLines) > 0
        for i = 0 to array.size(stopLines) - 1
            line.delete(array.get(stopLines, i))
        array.clear(stopLines)


    entryLine := line.new(
         lineStart,
         entryPrice,
         lineEnd,
         entryPrice,
         color=entryColor,
         width=lineWidth,
         style=line.style_dashed)


    for c = 1 to maxContracts

        distance = stopDistance(c)
        level = stopPrice(distance)

        currentColor = c == 1 ? stop1Color : c == 2 ? stop2Color : stop3Color

        newLine = line.new(
             lineStart,
             level,
             lineEnd,
             level,
             color=currentColor,
             width=lineWidth)

        array.push(stopLines, newLine)


//==================================================
// DRAW LABELS
//==================================================

if barstate.islast

    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)


    if showLabels

        entryLabel = label.new(
             bar_index + 5,
             entryPrice,
             "ENTRY\n" + str.tostring(entryPrice),
             style=label.style_label_left,
             color=entryLabelColor,
             textcolor=labelTextColor)

        array.push(labels, entryLabel)


        for c = 1 to maxContracts

            distance = stopDistance(c)
            level = stopPrice(distance)

            labelColor = c == 1 ? stop1LabelColor : c == 2 ? stop2LabelColor : stop3LabelColor

            labelText = str.tostring(c) + " " + contract +
                 "\nSL: " + str.tostring(level, "#.##") +
                 "\n" + str.tostring(distance, "#.##") + " pts" +
                 "\nRisk: $" + str.tostring(risk, "#")

            stopLabel = label.new(
                 bar_index + 5,
                 level,
                 labelText,
                 style=label.style_label_left,
                 color=labelColor,
                 textcolor=labelTextColor)

            array.push(labels, stopLabel)
````
