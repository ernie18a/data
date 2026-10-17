# Fibonacci Trend - Aynet

- url: https://www.tradingview.com/script/KAyB0PKo/
- type: strategy
- pine_id: PUB;60c14f0a20a64349be369f8576092899
- version: 1.0

## Description

[b]1. Inputs[/b]
lookbackPeriod: Defines the number of bars to consider for calculating swing highs and lows. Default is 20.
fibLevel1 to fibLevel5: Fibonacci retracement levels to calculate price levels (23.6%, 38.2%, 50%, 61.8%, 78.6%).
useTime: Enables or disables time-based Fibonacci projections.
riskPercent: Defines the percentage of risk for trading purposes (currently not used in calculations).
[b]2. Functions[/b]
isSwingHigh(index): Identifies a swing high at the given index, where the high of that candle is higher than both its previous and subsequent candles.
isSwingLow(index): Identifies a swing low at the given index, where the low of that candle is lower than both its previous and subsequent candles.
[b]3. Variables[/b]
swingHigh and swingLow: Store the most recent swing high and swing low prices.
swingHighTime and swingLowTime: Store the timestamps of the swing high and swing low.
fib1 to fib5: Fibonacci levels based on the difference between swingHigh and swingLow.
[b]4. Swing Point Detection[/b]
The script checks if the last bar is a swing high or swing low using the isSwingHigh() and isSwingLow() functions.
If a swing high is detected:
The high price is stored in swingHigh.
The timestamp of the swing high is stored in swingHighTime.
If a swing low is detected:
The low price is stored in swingLow.
The timestamp of the swing low is stored in swingLowTime.
[b]5. Fibonacci Levels Calculation[/b]
If both swingHigh and swingLow are defined, the script calculates the Fibonacci retracement levels (fib1 to fib5) based on the price difference (priceDiff = swingHigh - swingLow).
[b]6. Plotting Fibonacci Levels[/b]
Fibonacci levels (fib1 to fib5) are plotted as horizontal lines using the line.new() function.
Labels (e.g., "23.6%") are added near the lines to indicate the level.
Lines and labels are color-coded:
23.6% → Blue
38.2% → Green
50.0% → Yellow
61.8% → Orange
78.6% → Red
[b]7. Filling Between Fibonacci Levels[/b]
The plot() function creates lines for each Fibonacci level.
The fill() function is used to fill the space between two levels with semi-transparent colors:
Blue → Between fib1 and fib2
Green → Between fib2 and fib3
Yellow → Between fib3 and fib4
Orange → Between fib4 and fib5
[b]8. Time-Based Fibonacci Projections[/b]
If useTime is enabled:
The time difference (timeDiff) between the swing high and swing low is calculated.
Fibonacci time projections are added based on multiples of 23.6%.
If the current time reaches a projected time, a label (e.g., "T1", "T2") is displayed near the high price.
[b]9. Trading Logic[/b]
Two placeholder variables are defined for trading logic:
longCondition: Tracks whether a condition for a long trade is met (currently not implemented).
shortCondition: Tracks whether a condition for a short trade is met (currently not implemented).
These variables can be extended to define entry/exit signals based on Fibonacci levels.
[b]How It Works[/b]
Detect Swing Points: It identifies recent swing high and swing low points on the chart.
Calculate Fibonacci Levels: Based on the swing points, it computes retracement levels.
Visualize Levels: Plots the levels on the chart with labels and fills between them.
Time Projections: Optionally calculates time-based projections for future price movements.
Trading Opportunities: The framework provides tools for detecting potential reversal or breakout zones using Fibonacci levels.

## Source Code

````pine
//@version=5
strategy("Fibonacci Trend - Aynet", overlay=true)

// ===== Inputs =====
lookbackPeriod = input.int(20, "Lookback Period")
fibLevel1 = input.float(0.236, "Fib Level 1")
fibLevel2 = input.float(0.382, "Fib Level 2")
fibLevel3 = input.float(0.500, "Fib Level 3")
fibLevel4 = input.float(0.618, "Fib Level 4")
fibLevel5 = input.float(0.786, "Fib Level 5")
useTime = input.bool(true, "Use Time Projections")
riskPercent = input.float(1.0, "Risk Percentage", step=0.1)

// ===== Functions =====
isSwingHigh(index) =>
    high[index] > high[index + 1] and high[index] > high[index - 1]

isSwingLow(index) =>
    low[index] < low[index + 1] and low[index] < low[index - 1]

// ===== Variables =====
var float swingHigh = na
var float swingLow = na
var int swingHighTime = na
var int swingLowTime = na
var float fib1 = na
var float fib2 = na
var float fib3 = na
var float fib4 = na
var float fib5 = na

// ===== Swing Points Detection =====
if isSwingHigh(1)
    swingHigh := high[1]
    swingHighTime := time[1]

if isSwingLow(1)
    swingLow := low[1]
    swingLowTime := time[1]

// ===== Calculate Fibonacci Levels =====
if not na(swingHigh) and not na(swingLow)
    priceDiff = swingHigh - swingLow
    fib1 := swingLow + priceDiff * fibLevel1
    fib2 := swingLow + priceDiff * fibLevel2
    fib3 := swingLow + priceDiff * fibLevel3
    fib4 := swingLow + priceDiff * fibLevel4
    fib5 := swingLow + priceDiff * fibLevel5

// ===== Plot Fibonacci Levels with Labels =====
var line fib1_line = na
var line fib2_line = na
var line fib3_line = na
var line fib4_line = na
var line fib5_line = na
var label fib1_label = na
var label fib2_label = na
var label fib3_label = na
var label fib4_label = na
var label fib5_label = na

if not na(fib1)
    line.delete(fib1_line)
    label.delete(fib1_label)
    fib1_line := line.new(bar_index[lookbackPeriod], fib1, bar_index, fib1, color=color.blue, width=1)
    fib1_label := label.new(bar_index + 2, fib1, "23.6%", color=color.blue, style=label.style_label_left, textcolor=color.white)

if not na(fib2)
    line.delete(fib2_line)
    label.delete(fib2_label)
    fib2_line := line.new(bar_index[lookbackPeriod], fib2, bar_index, fib2, color=color.green, width=1)
    fib2_label := label.new(bar_index + 2, fib2, "38.2%", color=color.green, style=label.style_label_left, textcolor=color.white)

if not na(fib3)
    line.delete(fib3_line)
    label.delete(fib3_label)
    fib3_line := line.new(bar_index[lookbackPeriod], fib3, bar_index, fib3, color=color.yellow, width=1)
    fib3_label := label.new(bar_index + 2, fib3, "50.0%", color=color.yellow, style=label.style_label_left, textcolor=color.white)

if not na(fib4)
    line.delete(fib4_line)
    label.delete(fib4_label)
    fib4_line := line.new(bar_index[lookbackPeriod], fib4, bar_index, fib4, color=color.orange, width=1)
    fib4_label := label.new(bar_index + 2, fib4, "61.8%", color=color.orange, style=label.style_label_left, textcolor=color.white)

if not na(fib5)
    line.delete(fib5_line)
    label.delete(fib5_label)
    fib5_line := line.new(bar_index[lookbackPeriod], fib5, bar_index, fib5, color=color.red, width=1)
    fib5_label := label.new(bar_index + 2, fib5, "78.6%", color=color.red, style=label.style_label_left, textcolor=color.white)

// ===== Fill Between Levels =====
p1 = plot(fib1, "0.236", color=color.blue, linewidth=1)
p2 = plot(fib2, "0.382", color=color.green, linewidth=1)
p3 = plot(fib3, "0.500", color=color.yellow, linewidth=1)
p4 = plot(fib4, "0.618", color=color.orange, linewidth=1)
p5 = plot(fib5, "0.786", color=color.red, linewidth=1)

fill(p1, p2, color=color.new(color.blue, 90))
fill(p2, p3, color=color.new(color.green, 90))
fill(p3, p4, color=color.new(color.yellow, 90))
fill(p4, p5, color=color.new(color.orange, 90))

// ===== Time Labels =====
if useTime and not na(swingHighTime) and not na(swingLowTime)
    timeDiff = swingHighTime - swingLowTime
    for i = 1 to 5
        timeProj = swingHighTime + (timeDiff * (i * 0.236))
        if time >= timeProj and time[1] < timeProj
            label.new(bar_index, high, text="T" + str.tostring(i), 
                     style=label.style_label_down,
                     color=color.new(color.gray, 50),
                     textcolor=color.white)

// ===== Trading Logic =====
var bool longCondition = false
var bool shortCondition = false
````
