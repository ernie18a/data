# Smart Wick Risk Engine

- url: https://www.tradingview.com/script/uTKkYvOe-Smart-Wick-Risk-Engine/
- type: indicator
- pine_id: PUB;2d132ac094144d5cb86db01392c81b3c
- version: 1.0

## Description

Smart Wick Risk Engine is a precision trading tool designed for fast execution traders, especially on lower timeframes like M1.

This indicator measures the exact distance from candle wicks (high and low) to the closing price of each candle, helping traders quickly identify stop-loss distances based on real market structure.

Based on this wick-to-close distance, the tool automatically calculates the optimal lot size according to a user-defined risk per trade. This allows traders to maintain consistent risk management without manual calculations during fast market conditions.

Key Features:

* Automatic wick-to-close distance measurement (both upper and lower wicks)
* Real-time lot size calculation for Buy and Sell scenarios
* Adjustable risk per trade ($) for flexible account scaling
* Automatic pip calculation for Forex and Gold (XAUUSD)
* Clean label display directly on chart for instant decision making
* Designed for fast execution (ideal for scalping and intraday trading)

How to Use:

1. Wait for candle close
2. Read the wick distance (pip value)
3. Use the displayed lot size based on your risk
4. Execute trade immediately

This tool eliminates the need for manual lot size calculation, helping traders stay focused and consistent under pressure.

Note:

* Pip value is automatically calculated but can be adjusted depending on broker specifications.
* Best used with a solid trading strategy and proper discipline.

## Source Code

````pine
//@version=5
indicator("Wick to Close Distance + Buy/Sell Lot Size", overlay=true, max_labels_count=500)

// Inputs
candlesToShow = input.int(100, "Show Labels For Last X Candles", minval=1)
minDistance   = input.float(0.0, "Minimum Pip Filter", minval=0.0, step=0.1)
showLotLabels = input.bool(true, "Show Lot Size Labels")

// Pip setup
pip = syminfo.mintick * 10

// Distances
upperPips = (high - close) / pip
lowerPips = (close - low) / pip

// Rounded pip labels
upperValue = math.round(upperPips * 10) / 10
lowerValue = math.round(lowerPips * 10) / 10

// Risk
riskUsd  = input.float(3.0, "Risk Per Trade ($)", minval=0.1, step=0.5)
pipValue = input.float(10.0, "Pip Value (per lot)", step=1)

// Lot calc
sellLotRaw = upperPips > 0 ? riskUsd / (upperPips * pipValue) : na
buyLotRaw  = lowerPips > 0 ? riskUsd / (lowerPips * pipValue) : na

// MT5 adjust
lotStep = 0.01

sellLot = not na(sellLotRaw) ? math.floor(sellLotRaw / lotStep) * lotStep : na
buyLot  = not na(buyLotRaw)  ? math.floor(buyLotRaw / lotStep) * lotStep : na

sellLot := not na(sellLot) ? math.max(sellLot, 0.01) : na
buyLot  := not na(buyLot)  ? math.max(buyLot, 0.01) : na

// Limit displayed candles
showBar = bar_index >= math.max(last_bar_index - candlesToShow + 1, 0)

// Offset so lot labels don't overlap pip labels
offset = pip * 3

// Pip labels
if showBar and upperValue >= minDistance
    label.new(
         bar_index, high,
         text=str.tostring(upperValue, "#.0"),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.tiny)

if showBar and lowerValue >= minDistance
    label.new(
         bar_index, low,
         text=str.tostring(lowerValue, "#.0"),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.tiny)

// Lot labels
if showLotLabels and showBar and upperValue >= minDistance and not na(sellLot)
    label.new(
         bar_index, high + offset,
         text="Sell: " + str.tostring(sellLot, "#.##"),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

if showLotLabels and showBar and lowerValue >= minDistance and not na(buyLot)
    label.new(
         bar_index, low - offset,
         text="Buy: " + str.tostring(buyLot, "#.##"),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)
````
