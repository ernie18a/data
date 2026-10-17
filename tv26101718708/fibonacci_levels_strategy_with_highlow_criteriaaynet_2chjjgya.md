# Fibonacci Levels Strategy with High/Low Criteria-AYNET

- url: https://www.tradingview.com/script/2chJjgYA/
- type: strategy
- pine_id: PUB;e63abd1fac344a928656780b93a637bf
- version: 1.0

## Description

This code represents a TradingView strategy that uses Fibonacci levels in conjunction with high/low price criteria over specified lookback periods to determine buy (long) and sell (short) conditions. Below is an explanation of each main part of the code:

Explanation of Key Sections
User Inputs for Higher Time Frame and Candle Settings

Users can select a higher time frame (timeframe) for analysis and specify whether to use the "Current" or "Last" higher time frame (HTF) candle for calculating Fibonacci levels.
The currentlast setting allows flexibility between using real-time or the most recent closed higher time frame candle.
Lookback Periods for High/Low Criteria

Two lookback periods, lowestLookback and highestLookback, allow users to set the number of bars to consider when finding the lowest and highest prices, respectively.
This determines the criteria for entering trades based on how recent highs or lows compare to current prices.
Fibonacci Levels Configuration

Fibonacci levels (0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, and 100%) are configurable. These are used to calculate price levels between the high and low of the higher time frame candle.
Each level represents a retracement or extension relative to the high/low range of the HTF candle, providing important price levels for decision-making.
HTF Candle Calculation

HTF candle data is calculated based on the higher time frame selected by the user, using the newbar check to reset htfhigh, htflow, and htfopen values.
The values are updated with each new HTF bar or as prices move within the same HTF bar to track the highest high and lowest low accurately.
Set Fibonacci Levels Array

Using the calculated HTF candle's high, low, and open, the Fibonacci levels are computed by interpolating these values according to the user-defined Fibonacci levels.
A fibLevels array stores these computed values.
Plotting Fibonacci Levels

Each Fibonacci level is plotted on the chart with a different color, providing visual indicators for potential support/resistance levels.
High/Low Price Criteria Calculation

The lowest and highest prices over the specified lookback periods (lowestLookback and highestLookback) are calculated and plotted on the chart. These serve as dynamic levels to trigger long or short entries.
Trade Signal Conditions

longCondition: A long (buy) signal is generated when the price crosses above both the lowest price criteria and the 50% Fibonacci level.
shortCondition: A short (sell) signal is generated when the price crosses below both the highest price criteria and the 50% Fibonacci level.
Executing Trades

Based on the longCondition and shortCondition, trades are entered with the strategy.entry() function, using the labels "Long" and "Short" for tracking on the chart.
Strategy Use
This strategy allows traders to utilize Fibonacci retracement levels and recent highs/lows to identify trend continuation or reversal points, potentially providing entry points aligned with larger market structure. Adjusting the lowestLookback and highestLookback along with Fibonacci levels enables a customizable approach to suit different trading styles and market conditions.

## Source Code

````pine
//@version=5
strategy("Fibonacci Levels Strategy with High/Low Criteria", overlay = true)

// Kullanıcıdan yüksek zaman dilimini ve mum bilgilerini al
timeframe = input.timeframe(defval = "D", title = "Higher Time Frame")
currentlast = input.string(defval = "Last", title = "Current or Last HTF Candle", options = ["Current", "Last"])

// Kullanıcıdan en düşük ve en yüksek fiyat bakış sürelerini al
lowestLookback = input(20, "Lowest Price Lookback", tooltip="The strategy will BUY when the price crosses over the lowest it has been in the last X amount of bars")
highestLookback = input(10, "Highest Price Lookback", tooltip="If Take-Profit is not checked, the strategy will SELL when the price crosses under the highest it has been in the last X amount of bars")

// Fibonacci seviyeleri ayarları
level0 = input.float(defval = 0.000, title = "Level 0")
level1 = input.float(defval = 0.236, title = "Level 1")
level2 = input.float(defval = 0.382, title = "Level 2")
level3 = input.float(defval = 0.500, title = "Level 3")
level4 = input.float(defval = 0.618, title = "Level 4")
level5 = input.float(defval = 0.786, title = "Level 5")
level100 = input.float(defval = 1.000, title = "Level 100")

// HTF mumlarını hesapla
newbar = ta.change(time(timeframe)) != 0 
var float htfhigh = high
var float htflow = low
var float htfopen = open
float htfclose = close
var counter = 0

if newbar
    htfhigh := high
    htflow := low
    htfopen := open
    counter := 0
else
    htfhigh := math.max(htfhigh, high)
    htflow := math.min(htflow, low)
    counter += 1

var float open_ = na
var float high_ = na
var float low_ = na
var float close_ = na
if currentlast == "Last" and newbar
    open_ := htfopen[1]
    high_ := htfhigh[1]
    low_ := htflow[1]
    close_ := htfclose[1]
else if currentlast == "Current"
    open_ := htfopen
    high_ := htfhigh
    low_ := htflow
    close_ := htfclose

// Fibonacci seviyelerini hesapla
var float[] fibLevels = array.new_float(6)
array.set(fibLevels, 0, open_ + (high_ - low_) * level0)
array.set(fibLevels, 1, open_ + (high_ - low_) * level1)
array.set(fibLevels, 2, open_ + (high_ - low_) * level2)
array.set(fibLevels, 3, open_ + (high_ - low_) * level3)
array.set(fibLevels, 4, open_ + (high_ - low_) * level4)
array.set(fibLevels, 5, open_ + (high_ - low_) * level5)

// Fibonacci seviyelerini grafik üzerine çiz
plot(array.get(fibLevels, 0), color=color.new(color.blue, 75), title="Fibonacci Level 0")
plot(array.get(fibLevels, 1), color=color.new(color.green, 75), title="Fibonacci Level 1")
plot(array.get(fibLevels, 2), color=color.new(color.red, 75), title="Fibonacci Level 2")
plot(array.get(fibLevels, 3), color=color.new(color.orange, 75), title="Fibonacci Level 3")
plot(array.get(fibLevels, 4), color=color.new(color.teal, 75), title="Fibonacci Level 4")
plot(array.get(fibLevels, 5), color=color.new(color.navy, 75), title="Fibonacci Level 5")

// En düşük ve en yüksek fiyat kriterlerini hesapla
lowcriteria = ta.lowest(low, lowestLookback)[1]
highcriteria = ta.highest(high, highestLookback)[1]

plot(highcriteria, color=color.green, title="Highest Price Criteria")
plot(lowcriteria, color=color.red, title="Lowest Price Criteria")

// Fibonacci seviyeleri ile ticaret sinyalleri oluştur
longCondition = close > lowcriteria and close > array.get(fibLevels, 3) // En düşük kriterin ve Fibonacci seviyesinin üstüne çıkarsa alım
shortCondition = close < highcriteria and close < array.get(fibLevels, 3) // En yüksek kriterin ve Fibonacci seviyesinin altına düşerse satış

if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)
````
