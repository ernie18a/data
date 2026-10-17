# Simple Note Display

- url: https://www.tradingview.com/script/sNJChsye-Simple-Note-Display/
- type: indicator
- pine_id: PUB;9f9ad026c9d942679f20bddfbedca795
- version: 1.0

## Description

Displays a simple on-screen note directly on the TradingView chart for reminders, trade plans, or important market information..

You can edit your own information in the script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © VikiSoh

//@version=6
//@version=5
indicator("Simple Note Display", overlay=true)

// Create a table (top-right corner)
var table noteTable = table.new(position.bottom_right, 100, 100)
var table noteTable2 = table.new(position.middle_right, 100, 100)
var table noteTable3 = table.new(position.bottom_right, 100, 100)

// Your note text
//noteText = "Monthly Chart:-MACD 金叉，等MA金叉-在Weekly Chart, 等MACD金叉或零轴之上--进场时机，永远是在Daily Chart, MACD 和MA金叉- 放SL - Weekly 提款"
//noteText2 = "MACD 金叉，Price>MA8, Price 没有低过前低，八爪之涨，进场"
noteText3 = "跟日图趋势进场"

// Update table every bar
//table.cell(noteTable, 0, 0, noteText3, text_color=color.white, bgcolor=color.blue)
//table.cell(noteTable2, 0, 0,noteText2, text_color=color.white, bgcolor=color.blue)
table.cell(noteTable3, 0, 0, noteText3, text_color=color.white, bgcolor=color.blue)
````
