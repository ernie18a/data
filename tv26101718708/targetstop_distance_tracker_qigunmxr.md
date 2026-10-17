# Target/Stop Distance Tracker

- url: https://www.tradingview.com/script/QIgUNmxr-Target-Stop-Distance-Tracker/
- type: indicator
- pine_id: PUB;9316b4a7ed4c4b72bdcd64224f7c7df4
- version: 1.0

## Description

This is a custom, dynamic utility indicator designed specifically for futures traders who trade 5-contract position sizes on the Micro Nasdaq-100 (MNQ) and Micro S&P 500 (MES). Instead of manually calculating point distances for your trades, this script automatically calculates and visualizes exactly how many points the market needs to move to hit your specific dollar-based profit targets and stop losses.

Key Features

Auto-Symbol Detection: The script automatically knows whether you are looking at an MNQ or MES chart and adjusts the point value math ($2/pt for MNQ, $5/pt for MES) in the background.

Fixed Dollar Goals: It is hardcoded to your specific trading plan for a 5-contract size:

MNQ: Calculates the distance for a $500 Profit Target (50 points) and a $250 Stop Loss (25 points).

MES: Calculates the distance for a $300 Profit Target (12 points) and a $250 Stop Loss (10 points).

Live Price Tracking: The target and stop levels update dynamically with the current price.

Minimalist Visuals: Uses clean, floating text labels that stay anchored strictly to the current, active candle. It will not clutter your chart with trailing labels from previous candles or bulky background boxes.

Directional Toggle: Includes a simple input in the settings to switch between "Long" and "Short" positions, automatically flipping the target above or below the current price.

How to Use It
Simply add it to your MNQ or MES chart. Open the indicator settings to check or uncheck the "Long Position?" box depending on your trade direction. The indicator will instantly project your required exit points perfectly scaled to your 5-contract position limits.

## Source Code

````pine
//@version=6
indicator("Target/Stop Distance Tracker", overlay=true)

// --- Inputs ---
isLong = input.bool(true, title="Long Position?")
contracts = input.int(5, title="Contracts")

// --- Asset Detection ---
var float pointValue = na
var float targetDollar = na
var float stopDollar = 250.0

if syminfo.root == "MNQ"
    pointValue := 2.0
    targetDollar := 500.0
else if syminfo.root == "MES"
    pointValue := 5.0
    targetDollar := 300.0

// --- Calculations ---
dollarsPerPoint = contracts * pointValue
targetPoints = targetDollar / dollarsPerPoint
stopPoints = stopDollar / dollarsPerPoint

targetLevel = isLong ? close + targetPoints : close - targetPoints
stopLevel = isLong ? close - stopPoints : close + stopPoints

// --- Plotting ---
// (Remove or comment out these plot lines if you literally only want the text labels and no lines)
plot(targetLevel, color=color.new(color.green, 50), title="Target", style=plot.style_stepline)
plot(stopLevel, color=color.new(color.red, 50), title="Stop", style=plot.style_stepline)

// --- Minimal Label Logic ---
// 1. Create the labels ONLY ONCE using "var"
var label targetLabel = label.new(x=na, y=na, text="", style=label.style_none, textcolor=color.green, size=size.normal)
var label stopLabel = label.new(x=na, y=na, text="", style=label.style_none, textcolor=color.red, size=size.normal)

// 2. Simply update their position and text on the live bar
if barstate.islast
    label.set_xy(targetLabel, bar_index + 2, targetLevel)
    label.set_text(targetLabel, "Target: " + str.tostring(targetPoints) + " pts")
    
    label.set_xy(stopLabel, bar_index + 2, stopLevel)
    label.set_text(stopLabel, "Stop: " + str.tostring(stopPoints) + " pts")
````
