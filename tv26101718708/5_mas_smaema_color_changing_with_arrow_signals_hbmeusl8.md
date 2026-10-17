# 5 MA's (SMA/EMA) Color Changing with Arrow Signals

- url: https://www.tradingview.com/script/HbmEUsl8/
- type: indicator
- pine_id: PUB;a19b76d9d04249608cfc30cb46b707ab
- version: 1.0

## Description

This indicator is a highly customizable multi-trend analysis tool designed to show market momentum across 5 different moving averages simultaneously. It helps traders identify alignment in market structure from short-term to long-term timeframes.

Key Features:

    5 Fully Customizable Lines: By default, it loads the classic 10, 20, 50, 100, and 200 periods. Each line can be independently toggled on/off.

    EMA/SMA Flexibility: You can easily switch each individual moving average between an SMA (Simple Moving Average) and an EMA (Exponential Moving Average) via a simple dropdown menu in the settings.

    Dynamic Color Coding: The lines automatically change color in real-time based on price action. They turn Green when the price closes above the line (Bullish Support) and Red when the price falls below (Bearish Resistance).

    Earliest Trend-Shift Signals (Arrows): The indicator features a built-in state engine. As soon as all 5 active moving averages align in the same direction, a signal is triggered. A green triangle appears below the bar at the exact earliest moment a full bullish trend establishes, and a red triangle appears above the bar when a full bearish trend establishes.

How to use it:
This script is excellent for trend-following strategies, breakout trading, and identifying institutional trend alignment. It eliminates chart clutter by combining 5 separate indicators into one efficient tool.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator(title = 'Flexible 5 EMA Indicator with Arrow Signals', shorttitle = '5xMA', overlay = true)

// --- FUNCTION FOR CALCULATION ---
getMA(type, src, len) =>
    type == 'SMA' ? ta.sma(src, len) : ta.ema(src, len)

// --- INPUTS FOR THE 5 LINES (Default: All SMA/EMA with Green/Red) ---

// EMA 1 (10)
showEma1 = input.bool(true, title = '▶ Show EMA 1?')
typeEma1 = input.string('EMA', title = 'Type EMA 1', options = ['SMA', 'EMA'])
lenEma1 = input.int(10, minval = 1, title = 'Length EMA 1')
colorUp1 = input.color(color.green, title = 'EMA 1: Color Above (Up)')
colorDown1 = input.color(color.red, title = 'EMA 1: Color Below (Down)')

// EMA 2 (20)
showEma2 = input.bool(true, title = '▶ Show EMA 2?')
typeEma2 = input.string('EMA', title = 'Type EMA 2', options = ['SMA', 'EMA'])
lenEma2 = input.int(20, minval = 1, title = 'Length EMA 2')
colorUp2 = input.color(color.green, title = 'EMA 2: Color Above (Up)')
colorDown2 = input.color(color.red, title = 'EMA 2: Color Below (Down)')

// EMA 3 (50)
showEma3 = input.bool(true, title = '▶ Show EMA 3?')
typeEma3 = input.string('EMA', title = 'Type EMA 3', options = ['SMA', 'EMA'])
lenEma3 = input.int(50, minval = 1, title = 'Length EMA 3')
colorUp3 = input.color(color.green, title = 'EMA 3: Color Above (Up)')
colorDown3 = input.color(color.red, title = 'EMA 3: Color Below (Down)')

// EMA 4 (100)
showEma4 = input.bool(true, title = '▶ Show EMA 4?')
typeEma4 = input.string('EMA', title = 'Type EMA 4', options = ['SMA', 'EMA'])
lenEma4 = input.int(100, minval = 1, title = 'Length EMA 4')
colorUp4 = input.color(color.green, title = 'EMA 4: Color Above (Up)')
colorDown4 = input.color(color.red, title = 'EMA 4: Color Below (Down)')

// EMA 5 (200)
showEma5 = input.bool(true, title = '▶ Show EMA 5?')
typeEma5 = input.string('EMA', title = 'Type EMA 5', options = ['SMA', 'EMA'])
lenEma5 = input.int(200, minval = 1, title = 'Length EMA 5')
colorUp5 = input.color(color.green, title = 'EMA 5: Color Above (Up)')
colorDown5 = input.color(color.red, title = 'EMA 5: Color Below (Down)')

src = input.source(close, title = 'General Source')

// --- CALCULATIONS ---
outEma1 = getMA(typeEma1, src, lenEma1)
outEma2 = getMA(typeEma2, src, lenEma2)
outEma3 = getMA(typeEma3, src, lenEma3)
outEma4 = getMA(typeEma4, src, lenEma4)
outEma5 = getMA(typeEma5, src, lenEma5)

// --- DYNAMIC COLOR LOGIC ---
dynColor1 = close >= outEma1 ? colorUp1 : colorDown1
dynColor2 = close >= outEma2 ? colorUp2 : colorDown2
dynColor3 = close >= outEma3 ? colorUp3 : colorDown3
dynColor4 = close >= outEma4 ? colorUp4 : colorDown4
dynColor5 = close >= outEma5 ? colorUp5 : colorDown5

// --- PLOTS FOR THE LINES ---
plot(showEma1 ? outEma1 : na, title = 'EMA 1', color = dynColor1, linewidth = 2)
plot(showEma2 ? outEma2 : na, title = 'EMA 2', color = dynColor2, linewidth = 2)
plot(showEma3 ? outEma3 : na, title = 'EMA 3', color = dynColor3, linewidth = 2)
plot(showEma4 ? outEma4 : na, title = 'EMA 4', color = dynColor4, linewidth = 2)
plot(showEma5 ? outEma5 : na, title = 'EMA 5', color = dynColor5, linewidth = 2)

// --- SIGNAL LOGIC FOR ARROWS ---
// Check if the price is currently above OR below ALL 5 activated lines
allGreen = (not showEma1 or close >= outEma1) and (not showEma2 or close >= outEma2) and (not showEma3 or close >= outEma3) and (not showEma4 or close >= outEma4) and (not showEma5 or close >= outEma5)

allRed = (not showEma1 or close < outEma1) and (not showEma2 or close < outEma2) and (not showEma3 or close < outEma3) and (not showEma4 or close < outEma4) and (not showEma5 or close < outEma5)

// The earliest moment: Signal only if it was NOT true on the PREVIOUS bar [1]
buySignal = allGreen and not allGreen[1]
sellSignal = allRed and not allRed[1]

// --- PLOTS FOR THE ARROWS ---
// Green arrow below the bar for buy signal
plotshape(buySignal, title = 'Buy Signal Arrow', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small)

// Red arrow above the bar for sell signal
plotshape(sellSignal, title = 'Sell Signal Arrow', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)
````
