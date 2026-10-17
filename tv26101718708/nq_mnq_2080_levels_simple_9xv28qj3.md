# NQ / MNQ 20-80 Levels SIMPLE

- url: https://www.tradingview.com/script/9Xv28qJ3-NQ-MNQ-20-80-Levels-SIMPLE/
- type: indicator
- pine_id: PUB;2f8934dad40943d5b6136f538af4f664
- version: 1.0

## Description

## NQ / MNQ 20-80 Levels SIMPLE — How to Use

This indicator automatically plots the important **20 and 80 levels** between every 100-point range on NQ / MNQ.
These levels often act as **reaction zones** where price can:

* Bounce
* Reject
* Reverse
* Continue trending after pullbacks

It helps traders quickly visualize clean intraday structure without cluttering the chart.

### What the Levels Mean

* **20 Levels (Green)** → Often act as support during bullish trends
* **80 Levels (Red)** → Often act as resistance during bearish trends

These areas are commonly respected by price action, especially during:

* Pullbacks
* Breakouts
* Liquidity sweeps
* Trend continuation moves

### Simple Trading Ideas

#### In Uptrend

* Wait for price to pull back near a **20 level**
* Look for rejection candles or strong buying reaction
* Enter with tight stop below the level

#### In Downtrend

* Wait for price to reject near an **80 level**
* Look for weakness or bearish candles
* Enter with stop above the level

### Best Used With

* Trendlines
* EMA support/resistance
* VWAP
* Volume Profile
* Bookmap
* SpotGamma levels
* Candlestick confirmations

### Pro Tip

Do not blindly buy or sell the levels.
Wait for:

* Rejection
* Confirmation candle
* Momentum shift
* Trend alignment

The strongest trades happen when multiple confirmations align together.

### Features

✔ Simple clean levels
✔ Line or box display mode
✔ Custom colors and styles
✔ Adjustable levels above and below price
✔ Great for scalping and intraday structure trading

If this indicator helps your trading journey, please consider:
👍 Leaving a Like
⭐ Adding to Favorites
📢 Sharing it with fellow traders and friends

Your support and feedback are truly appreciated and help improve future tools for the trading community.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sunilnahata

//@version=5
indicator("NQ / MNQ 20-80 Levels SIMPLE", overlay=true, max_lines_count=500, max_boxes_count=500)

// === INPUTS ===
levelsAbove = input.int(10, "Levels Above Price")
levelsBelow = input.int(10, "Levels Below Price")

mode = input.string("Lines", "Display Mode", options=["Lines", "Boxes"])

// === LINE SETTINGS ===
color20 = input.color(color.green, "20 Level Color")
color80 = input.color(color.red, "80 Level Color")

width20 = input.int(2, "20 Line Width")
width80 = input.int(2, "80 Line Width")

styleInput = input.string("Solid", "Line Style", options=["Solid", "Dotted", "Dashed"])

// === BOX SETTINGS ===
boxColor20 = input.color(color.new(color.green, 80), "20 Box Color")
boxColor80 = input.color(color.new(color.red, 80), "80 Box Color")

boxHeight = input.float(5.0, "Box Height (Points)")

// === STYLE FIX ===
lineStyle = line.style_solid
if styleInput == "Dotted"
    lineStyle := line.style_dotted
else if styleInput == "Dashed"
    lineStyle := line.style_dashed

// === BASE ROUND NUMBER ===
base100 = math.floor(close / 100) * 100

// === DRAW ONLY ON LAST BAR (NO LAG) ===
if barstate.islast
    for i = -levelsBelow to levelsAbove
        base = base100 + (i * 100)

        level20 = base + 20
        level80 = base + 80

        if mode == "Lines"
            line.new(bar_index - 300, level20, bar_index + 300, level20, extend=extend.right, color=color20, width=width20, style=lineStyle)
            line.new(bar_index - 300, level80, bar_index + 300, level80, extend=extend.right, color=color80, width=width80, style=lineStyle)
        else
            box.new(bar_index - 300, level20 + boxHeight, bar_index + 300, level20 - boxHeight, bgcolor=boxColor20, border_width=0)
            box.new(bar_index - 300, level80 + boxHeight, bar_index + 300, level80 - boxHeight, bgcolor=boxColor80, border_width=0)
````
