# ATR Display Box

- url: https://www.tradingview.com/script/9XQS7MOu-ATR-Display-Box/
- type: indicator
- pine_id: PUB;326fe5bda18f47929c7af69592f1f81b
- version: 1.0

## Description

A simple ATR box for you to see what kind of volatility the market is doing. Help with adjusting your stop losses. You can move it from top tight or left, and bottom left or right.

## Source Code

````pine
//@version=5
indicator("ATR Display Box", overlay=true)

// Inputs
atrLength = input.int(14, title="ATR Length")

boxPosition = input.string(
     "Bottom Right",
     title="Box Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"])

// ATR Calculation
atrValue = ta.atr(atrLength)

// Position Logic
tablePos =
     boxPosition == "Top Left" ? position.top_left :
     boxPosition == "Top Right" ? position.top_right :
     boxPosition == "Bottom Left" ? position.bottom_left :
     position.bottom_right

// Create Table
var table atrTable = table.new(tablePos, 1, 1)

// Update Table
table.cell(
     atrTable,
     0,
     0,
     "ATR(" + str.tostring(atrLength) + "): " +
     str.tostring(atrValue, format.mintick),
     bgcolor=color.new(color.black, 20),
     text_color=color.white,
     text_size=size.small)
````
