# STRATEGY Fibonacci Levels with High/Low Criteria - AYNET

- url: https://www.tradingview.com/script/8FA8W4CB/
- type: strategy
- pine_id: PUB;b26b75d282224f0eb2c4330073caf0df
- version: 1.0

## Description

Here is an explanation of the Fibonacci Levels Strategy with High/Low Criteria script:

Overview
This strategy combines Fibonacci retracement levels with high/low criteria to generate buy and sell signals based on price crossing specific thresholds. It utilizes higher timeframe (HTF) candlesticks and user-defined lookback periods for high/low levels.

Key Features
Higher Timeframe Integration:

The script calculates the open, high, low, and close values of the higher timeframe (HTF) candlestick.
Users can choose to calculate levels based on the current or the last HTF candle.
Fibonacci Levels:

Fibonacci retracement levels are dynamically calculated based on the HTF candlestick's range (high - low).
Users can customize the levels (0.000, 0.236, 0.382, 0.500, 0.618, 0.786, 1.000).
High/Low Lookback Criteria:

The script evaluates the highest high and lowest low over user-defined lookback periods.
These levels are plotted on the chart for visual reference.
Trade Signals:

Long Signal: Triggered when the close price crosses above both:
The lowest price criteria (lookback period).
The Fibonacci level 3 (default: 0.5).
Short Signal: Triggered when the close price crosses below both:
The highest price criteria (lookback period).
The Fibonacci level 3 (default: 0.5).
Visualization:

Plots Fibonacci levels and high/low criteria on the chart for easy interpretation.
Inputs
Higher Timeframe:

Users can select the timeframe (default: Daily) for the HTF candlestick.
Option to calculate based on the current or last HTF candle.
Lookback Periods:

lowestLookback: Number of bars for the lowest low calculation (default: 20).
highestLookback: Number of bars for the highest high calculation (default: 10).
Fibonacci Levels:

Fully customizable Fibonacci levels ranging from 0.000 to 1.000.
Visualization
Fibonacci Levels:

Plots six customizable Fibonacci levels with distinct colors and transparency.
High/Low Criteria:

Plots the highest and lowest levels based on the lookback periods as reference lines.
Trading Logic
Long Condition:

Price must close above:
The lowest price criteria (lowcriteria).
The Fibonacci level 3 (50% retracement).
Short Condition:

Price must close below:
The highest price criteria (highcriteria).
The Fibonacci level 3 (50% retracement).
Use Case
Trend Reversal Strategy:
Combines Fibonacci retracement with recent high/low criteria to identify potential reversal or breakout points.
Custom Timeframe Analysis:
Incorporates higher timeframe data for multi-timeframe trading strategies.

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
