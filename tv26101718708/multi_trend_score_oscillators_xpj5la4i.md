# Multi Trend Score Oscillators

- url: https://www.tradingview.com/script/XpJ5la4i-Multi-Trend-Score-Oscillators/
- type: indicator
- pine_id: PUB;05707fcc895c469bb8a79fd77c482889
- version: 1.0

## Description

Oscillators Multi Trend score


Part 1: How the Indicator Works Under the Hood
//The script evaluates the market using three independent concepts: Trend Direction, Momentum, and Market Regime (Volatility). It works on a strict point system that ranges between a maximum bullish score of +2.0 and a maximum bearish score of -2.0.


Trend Filter (Moving Averages): Max +/- 1.0 Point
It checks a fast 15 EMA and a slower 50 EMA.


Bullish (+1.0): If the 15 EMA is above the 50 EMA and the price is trading above the 15 EMA.
Bearish (-1.0): If the 15 EMA is below the 50 EMA and the price is trading below the 15 EMA.


Momentum Filter (MACD): Max +/- 1.0 Point
It analyzes the MACD line, Signal line, and Zero line.


Bullish Points: Gets +0.5 if the MACD line is above the Signal line, and another +0.5 if the MACD line is above the center zero line.


Bearish Points: Loses -0.5 if the MACD line is below the Signal line, and another -0.5 if the MACD line is below zero.


 The Gatekeeper (ADX Filter)
Before plotting, it checks the ADX (Average Directional Index). If the ADX is below 20, it means the market is ranging, chopping sideways, or dead.
The Penalty: If ADX < 20, it slashes the final score by 75% (trendScore * 0.25). This flattens the wave near zero, saving traders from getting chopped up in range-bound markets.
Indicator Overview: Multi-Indicator Trend Score (MITS)
MITS is a quantitative dashboard squeezed into a single, clean oscillator pane. It eliminates analysis paralysis by combining Moving Average trends, MACD momentum, and ADX market //regimes into a dynamic Trend Score between -2 and +2.


🔹 Key Features:
//Confluence Scoring: Rather than looking at EMAs and MACD separately, the script calculates their confluence in real time.


ADX Volatility Gatekeeper: When the market enters a low-volume, sideways chop zone (ADX < 20), the script automatically flattens the scoring engine by 75%. This prevents false //breakout signals.


Clean Visuals: Smooth area-gradient fill anchors to a zero-line baseline. Bright Green represents aggregate bullish confluence; Deep Red highlights aggregate bearish confluence.


How to Trade It:
Score > 1.0: Strong Bullish Confluence. Look for long entries or ride the trend.


Score < -1.0: Strong Bearish Confluence. Look for short entries or protect capital.


Flatline / Near Zero: The market is either flipping trends or trapped in a low-volatility chop zone filtered by the ADX. Sit on your hands.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © malqaizi

//@version=6
indicator(title = "Multi Trend Score ", shorttitle="MITS", overlay=false, max_bars_back=5000)

//Calculations
emaFast = ta.ema(close, 15)
emaSlow = ta.ema(close, 50)
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
[_, _, adxValue] = ta.dmi(12, 12)

// ==========================================
//input
// ==========================================
smoothLength = input.int(7, title="Score Smoothing Length", minval=1, tooltip="Higher = smoother line (looks like RSI). 1 = original blocky style.")

//  Variables
float trendScore = 0.0


// MA Direction
if (emaFast > emaSlow) and (close > emaFast)
    trendScore += 1.0
else if (emaFast < emaSlow) and (close < emaFast)
    trendScore -= 1.0

// MACD Momentum
if (macdLine > signalLine)
    trendScore += 0.5
if (macdLine > 0)
    trendScore += 0.5
if (macdLine < signalLine)
    trendScore -= 0.5
if (macdLine < 0)
    trendScore -= 0.5

// ADX Regime Gatekeeper 
if adxValue < 20
    trendScore := trendScore * 0.25 

// ==========================================
//  waves
// ==========================================
smoothedScore = ta.ema(trendScore, smoothLength)

// smoothedScore
lineColor = smoothedScore >= 0 ? color.rgb(0, 255, 187) : color.rgb(255, 0, 157)
fillColor = smoothedScore >= 0 ? color.new(color.rgb(0, 255, 187), 75) : color.new(color.rgb(255, 0, 157), 75)

//Plot
scorePlot = plot(smoothedScore, title="Smooth Trend Line", color=lineColor, linewidth=2)
zeroPlot  = plot(0, title="Zero Anchor", color=color.new(color.white, 60))
fill(scorePlot, zeroPlot, color=fillColor, title="Trend Background Fill")

// Dashboard Table 
var string marketRegime = "Neutral"
var color cellColor     = color.gray

if trendScore >= 2.0
    marketRegime := "Strong Bullish (+2)"
    cellColor    := color.rgb(0, 200, 50)
else if trendScore >= 1.0 and trendScore < 2.0
    marketRegime := "Bullish (+1)"
    cellColor    := color.rgb(50, 150, 50)
else if trendScore > 0.0 and trendScore < 1.0
    marketRegime := "Weak Bullish (+0.x)"
    cellColor    := color.rgb(70, 100, 70)
else if trendScore == 0.0
    marketRegime := "Flat / Neutral (0)"
    cellColor    := color.gray
else if trendScore < 0.0 and trendScore > -1.0
    marketRegime := "Weak Bearish (-0.x)"
    cellColor    := color.rgb(120, 70, 70)
else if trendScore <= -1.0 and trendScore > -2.0
    marketRegime := "Bearish (-1)"
    cellColor    := color.rgb(180, 50, 50)
else if trendScore <= -2.0
    marketRegime := "Strong Bearish (-2)"
    cellColor    := color.rgb(220, 20, 20)

if barstate.islast
    displayTable = table.new(position = position.top_right, columns = 2, rows = 2, border_width = 1, border_color = color.black)
    table.cell(displayTable, column = 0, row = 0, text = "Market Condition", bgcolor = color.black, text_color = color.white, text_size = size.small)
    table.cell(displayTable, column = 1, row = 0, text = "Score",            bgcolor = color.black, text_color = color.white, text_size = size.small)
    table.cell(displayTable, column = 0, row = 1, text = marketRegime, bgcolor = cellColor, text_color = color.white, text_size = size.normal)
    table.cell(displayTable, column = 1, row = 1, text = str.tostring(trendScore, "#.#"), bgcolor = cellColor, text_color = color.white, text_size = size.normal)






//oscillator 
//Part 1: How the Indicator Works Under the Hood
//The script evaluates the market using three independent concepts: Trend Direction, Momentum, and Market Regime (Volatility). It works on a strict point system that ranges between a maximum bullish score of +2.0 and a maximum bearish score of -2.0.

//1. Trend Filter (Moving Averages): Max +/- 1.0 Point
//It checks a fast 15 EMA and a slower 50 EMA.
//
//Bullish (+1.0): If the 15 EMA is above the 50 EMA and the price is trading above the 15 EMA.
//Bearish (-1.0): If the 15 EMA is below the 50 EMA and the price is trading below the 15 EMA.

//2. Momentum Filter (MACD): Max +/- 1.0 Point
//It analyzes the MACD line, Signal line, and Zero line.

//Bullish Points: Gets +0.5 if the MACD line is above the Signal line, and another +0.5 if the MACD line is above the center zero line.

//Bearish Points: Loses -0.5 if the MACD line is below the Signal line, and another -0.5 if the MACD line is below zero.

//3. The Gatekeeper (ADX Filter)
//Before plotting, it checks the ADX (Average Directional Index). If the ADX is below 20, it means the market is ranging, chopping sideways, or dead.

//The Penalty: If ADX < 20, it slashes the final score by 75% (trendScore * 0.25). This flattens the wave near zero, saving traders from getting chopped up in range-bound markets.
//ndicator Overview: Multi-Indicator Trend Score (MITS)
//MITS is a quantitative dashboard squeezed into a single, clean oscillator pane. It eliminates analysis paralysis by combining Moving Average trends, MACD momentum, and ADX market //regimes into a dynamic Trend Score between -2 and +2.

//🔹 Key Features:
//Confluence Scoring: Rather than looking at EMAs and MACD separately, the script calculates their confluence in real time.

//ADX Volatility Gatekeeper: When the market enters a low-volume, sideways chop zone (ADX < 20), the script automatically flattens the scoring engine by 75%. This prevents false //breakout signals.

//Clean Visuals: Smooth area-gradient fill anchors to a zero-line baseline. Bright Green represents aggregate bullish confluence; Deep Red highlights aggregate bearish confluence.

//💡 How to Trade It:
//Score > 1.0: Strong Bullish Confluence. Look for long entries or ride the trend.

//Score < -1.0: Strong Bearish Confluence. Look for short entries or protect capital.

//Flatline / Near Zero: The market is either flipping trends or trapped in a low-volatility chop zone filtered by the ADX. Sit on your hands.
````
