# DMI Same Direction Movement + RSI + 6 TF

- url: https://www.tradingview.com/script/j2DNgxjv-DMI-Same-Direction-Movement-RSI-6-TF/
- type: indicator
- pine_id: PUB;37b847d2fc92449091fc926da96f8ef8
- version: 1.0

## Description

# DMI Same Direction Movement + RSI + 6TF

## Overview

DMI Same Direction Movement + RSI + 6TF is a multi-timeframe technical indicator that combines the Directional Movement Index (DMI), ADX, RSI, and a Same Direction Movement visualization into a single oscillator-style tool.

The indicator is designed to help traders observe directional conditions and momentum relationships across multiple user-defined timeframes without changing the chart timeframe.

## DMI

The indicator uses:

* +DI (Positive Directional Indicator)
* -DI (Negative Directional Indicator)
* ADX (Average Directional Index)

The default DI Length is 73, while the default ADX Smoothing is 14. Both values can be adjusted from the settings.

The relationship between +DI and -DI is used as one component of the directional assessment.

## RSI

The indicator includes RSI with a default length of 73.

Three reference levels are displayed:

* 70 — upper RSI level
* 50 — central reference level
* 30 — lower RSI level

The RSI 50 level is also used together with the DMI relationship in the multi-timeframe status table.

## Same Direction Movement

Same Direction Movement identifies bars where +DI and -DI are moving in the same direction compared with their previous values.

Two conditions are detected:

* Both +DI and -DI are increasing.
* Both +DI and -DI are decreasing.

When enabled, these conditions are represented by small markers at the top of the indicator pane.

The marker color can be customized from the settings.

## Multi-Timeframe Analysis

The indicator supports six independently configurable timeframes.

Each timeframe can be:

* Enabled or disabled.
* Entered manually in minutes.
* Used independently from the chart timeframe.

The default timeframes are:

* TF 1: 5 minutes
* TF 2: 9 minutes
* TF 3: 15 minutes
* TF 4: 30 minutes
* TF 5: 73 minutes
* TF 6: 240 minutes

Custom minute values can also be entered, allowing timeframes such as 36, 73, or other minute-based intervals.

## MTF Status Table

The table in the upper-right corner displays the current directional condition for each enabled timeframe.

### BUYERS

BUYERS is displayed when:

+DI > -DI

and

RSI > 50

### SELLERS

SELLERS is displayed when:

-DI > +DI

and

RSI < 50

### NEUTRAL

NEUTRAL is displayed when the DMI and RSI conditions do not simultaneously meet either of the above conditions.

### OFF

OFF indicates that the corresponding timeframe has been disabled in the settings.

## Important Notes

This indicator is a technical analysis tool intended to help visualize DMI, ADX, RSI, and multi-timeframe relationships.

The displayed conditions are descriptive calculations based on the selected settings and do not represent guaranteed trading signals or predictions of future price movement.

Users should evaluate the indicator together with their own analysis, risk management, and trading methodology.

## Recommended Use

The indicator can be used for:

* Multi-timeframe directional analysis
* DMI and RSI relationship analysis
* Momentum observation
* Comparing directional conditions across different timeframes
* Identifying periods where +DI and -DI move in the same direction
* Monitoring changes in market conditions across multiple custom minute-based timeframes

## Source Code

````pine
//@version=6

indicator("DMI Same Direction Movement + RSI + 6 TF", shorttitle="DMI RSI 6TF", format=format.price, precision=4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

lensig = input.int(14, "ADX Smoothing", minval=1)

len = input.int(73, "DI Length", minval=1)

showSameDirection = input.bool(true, "Show Same Direction Movement")

sameDirectionColor = input.color(color.yellow, "Same Direction Color")

rsiLength = input.int(73, "RSI Length", minval=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME 1
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTF1 = input.bool(true, "Enable TF 1", group="Timeframe 1")

tf1Minutes = input.int(5, "TF 1 Minutes", minval=1, group="Timeframe 1")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME 2
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTF2 = input.bool(true, "Enable TF 2", group="Timeframe 2")

tf2Minutes = input.int(9, "TF 2 Minutes", minval=1, group="Timeframe 2")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME 3
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTF3 = input.bool(true, "Enable TF 3", group="Timeframe 3")

tf3Minutes = input.int(15, "TF 3 Minutes", minval=1, group="Timeframe 3")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME 4
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTF4 = input.bool(true, "Enable TF 4", group="Timeframe 4")

tf4Minutes = input.int(30, "TF 4 Minutes", minval=1, group="Timeframe 4")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME 5
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTF5 = input.bool(true, "Enable TF 5", group="Timeframe 5")

tf5Minutes = input.int(73, "TF 5 Minutes", minval=1, group="Timeframe 5")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME 6
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTF6 = input.bool(true, "Enable TF 6", group="Timeframe 6")

tf6Minutes = input.int(240, "TF 6 Minutes", minval=1, group="Timeframe 6")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME STRINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tf1 = str.tostring(tf1Minutes)

tf2 = str.tostring(tf2Minutes)

tf3 = str.tostring(tf3Minutes)

tf4 = str.tostring(tf4Minutes)

tf5 = str.tostring(tf5Minutes)

tf6 = str.tostring(tf6Minutes)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN DMI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[plusDI, minusDI, adxValue] = ta.dmi(len, lensig)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAME DIRECTION MOVEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plusChange = ta.change(plusDI)

minusChange = ta.change(minusDI)

sameDirectionUp = plusChange > 0 and minusChange > 0

sameDirectionDown = plusChange < 0 and minusChange < 0

sameDirection = sameDirectionUp or sameDirectionDown

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rsiValue = ta.rsi(close, rsiLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(adxValue, color=#F50057, title="ADX")

plot(plusDI, color=#2962FF, title="+DI")

plot(minusDI, color=#FF6D00, title="-DI")

plot(rsiValue, color=color.green, title="RSI", linewidth=1)

hline(70, "RSI 70", color=color.gray, linestyle=hline.style_dashed)

hline(50, "RSI 50", color=color.gray, linestyle=hline.style_dotted)

hline(30, "RSI 30", color=color.gray, linestyle=hline.style_dashed)

plotshape(showSameDirection and sameDirection, title="Same Direction Movement", style=shape.circle, location=location.top, color=sameDirectionColor, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF 1 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[tf1Plus, tf1Minus, tf1Adx] = request.security(syminfo.tickerid, tf1, ta.dmi(len, lensig))

tf1Rsi = request.security(syminfo.tickerid, tf1, ta.rsi(close, rsiLength))

tf1Buy = tf1Plus > tf1Minus and tf1Rsi > 50

tf1Sell = tf1Minus > tf1Plus and tf1Rsi < 50

tf1Status = tf1Buy ? "BUYERS" : tf1Sell ? "SELLERS" : "NEUTRAL"

tf1Bg = not showTF1 ? color.new(color.gray, 80) : tf1Buy ? color.green : tf1Sell ? color.red : color.white

tf1Text = not showTF1 ? color.gray : tf1Buy ? color.white : tf1Sell ? color.white : color.black

tf1Name = showTF1 ? str.tostring(tf1Minutes) + "m" : "OFF"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF 2 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[tf2Plus, tf2Minus, tf2Adx] = request.security(syminfo.tickerid, tf2, ta.dmi(len, lensig))

tf2Rsi = request.security(syminfo.tickerid, tf2, ta.rsi(close, rsiLength))

tf2Buy = tf2Plus > tf2Minus and tf2Rsi > 50

tf2Sell = tf2Minus > tf2Plus and tf2Rsi < 50

tf2Status = tf2Buy ? "BUYERS" : tf2Sell ? "SELLERS" : "NEUTRAL"

tf2Bg = not showTF2 ? color.new(color.gray, 80) : tf2Buy ? color.green : tf2Sell ? color.red : color.white

tf2Text = not showTF2 ? color.gray : tf2Buy ? color.white : tf2Sell ? color.white : color.black

tf2Name = showTF2 ? str.tostring(tf2Minutes) + "m" : "OFF"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF 3 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[tf3Plus, tf3Minus, tf3Adx] = request.security(syminfo.tickerid, tf3, ta.dmi(len, lensig))

tf3Rsi = request.security(syminfo.tickerid, tf3, ta.rsi(close, rsiLength))

tf3Buy = tf3Plus > tf3Minus and tf3Rsi > 50

tf3Sell = tf3Minus > tf3Plus and tf3Rsi < 50

tf3Status = tf3Buy ? "BUYERS" : tf3Sell ? "SELLERS" : "NEUTRAL"

tf3Bg = not showTF3 ? color.new(color.gray, 80) : tf3Buy ? color.green : tf3Sell ? color.red : color.white

tf3Text = not showTF3 ? color.gray : tf3Buy ? color.white : tf3Sell ? color.white : color.black

tf3Name = showTF3 ? str.tostring(tf3Minutes) + "m" : "OFF"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF 4 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[tf4Plus, tf4Minus, tf4Adx] = request.security(syminfo.tickerid, tf4, ta.dmi(len, lensig))

tf4Rsi = request.security(syminfo.tickerid, tf4, ta.rsi(close, rsiLength))

tf4Buy = tf4Plus > tf4Minus and tf4Rsi > 50

tf4Sell = tf4Minus > tf4Plus and tf4Rsi < 50

tf4Status = tf4Buy ? "BUYERS" : tf4Sell ? "SELLERS" : "NEUTRAL"

tf4Bg = not showTF4 ? color.new(color.gray, 80) : tf4Buy ? color.green : tf4Sell ? color.red : color.white

tf4Text = not showTF4 ? color.gray : tf4Buy ? color.white : tf4Sell ? color.white : color.black

tf4Name = showTF4 ? str.tostring(tf4Minutes) + "m" : "OFF"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF 5 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[tf5Plus, tf5Minus, tf5Adx] = request.security(syminfo.tickerid, tf5, ta.dmi(len, lensig))

tf5Rsi = request.security(syminfo.tickerid, tf5, ta.rsi(close, rsiLength))

tf5Buy = tf5Plus > tf5Minus and tf5Rsi > 50

tf5Sell = tf5Minus > tf5Plus and tf5Rsi < 50

tf5Status = tf5Buy ? "BUYERS" : tf5Sell ? "SELLERS" : "NEUTRAL"

tf5Bg = not showTF5 ? color.new(color.gray, 80) : tf5Buy ? color.green : tf5Sell ? color.red : color.white

tf5Text = not showTF5 ? color.gray : tf5Buy ? color.white : tf5Sell ? color.white : color.black

tf5Name = showTF5 ? str.tostring(tf5Minutes) + "m" : "OFF"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TF 6 DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[tf6Plus, tf6Minus, tf6Adx] = request.security(syminfo.tickerid, tf6, ta.dmi(len, lensig))

tf6Rsi = request.security(syminfo.tickerid, tf6, ta.rsi(close, rsiLength))

tf6Buy = tf6Plus > tf6Minus and tf6Rsi > 50

tf6Sell = tf6Minus > tf6Plus and tf6Rsi < 50

tf6Status = tf6Buy ? "BUYERS" : tf6Sell ? "SELLERS" : "NEUTRAL"

tf6Bg = not showTF6 ? color.new(color.gray, 80) : tf6Buy ? color.green : tf6Sell ? color.red : color.white

tf6Text = not showTF6 ? color.gray : tf6Buy ? color.white : tf6Sell ? color.white : color.black

tf6Name = showTF6 ? str.tostring(tf6Minutes) + "m" : "OFF"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table mtfTable = table.new(position.top_right, 2, 7, border_width=1)

table.cell(mtfTable, 0, 0, "TF", text_color=color.white, bgcolor=color.gray)

table.cell(mtfTable, 1, 0, "STATUS", text_color=color.white, bgcolor=color.gray)

table.cell(mtfTable, 0, 1, tf1Name, text_color=tf1Text, bgcolor=tf1Bg)

table.cell(mtfTable, 1, 1, showTF1 ? tf1Status : "OFF", text_color=tf1Text, bgcolor=tf1Bg)

table.cell(mtfTable, 0, 2, tf2Name, text_color=tf2Text, bgcolor=tf2Bg)

table.cell(mtfTable, 1, 2, showTF2 ? tf2Status : "OFF", text_color=tf2Text, bgcolor=tf2Bg)

table.cell(mtfTable, 0, 3, tf3Name, text_color=tf3Text, bgcolor=tf3Bg)

table.cell(mtfTable, 1, 3, showTF3 ? tf3Status : "OFF", text_color=tf3Text, bgcolor=tf3Bg)

table.cell(mtfTable, 0, 4, tf4Name, text_color=tf4Text, bgcolor=tf4Bg)

table.cell(mtfTable, 1, 4, showTF4 ? tf4Status : "OFF", text_color=tf4Text, bgcolor=tf4Bg)

table.cell(mtfTable, 0, 5, tf5Name, text_color=tf5Text, bgcolor=tf5Bg)

table.cell(mtfTable, 1, 5, showTF5 ? tf5Status : "OFF", text_color=tf5Text, bgcolor=tf5Bg)

table.cell(mtfTable, 0, 6, tf6Name, text_color=tf6Text, bgcolor=tf6Bg)

table.cell(mtfTable, 1, 6, showTF6 ? tf6Status : "OFF", text_color=tf6Text, bgcolor=tf6Bg)
````
