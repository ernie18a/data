# Adaptive Change of Character (CHoCH)

- url: https://www.tradingview.com/script/RUye8LIU-Adaptive-Change-of-Character-CHoCH/
- type: indicator
- pine_id: PUB;727dec8ad6394b7d9f3eed83a9b3213c
- version: 2.0

## Description

[b]Indicator Description: Adaptive Change of Character (CHoCH)[/b]

Overview
The Adaptive Change of Character (CHoCH) indicator is a technical analysis tool designed for Smart Money Concepts (SMC) and Price Action traders. Unlike standard trend-following indicators, this script specifically identifies the early transition phase of a market reversal. It monitors swing points (Pivot Highs and Lows) and signals a "Change of Character" the moment price action breaks the previous counter-structure, providing an early warning of a potential trend shift.

Key Features
Multi-Timeframe Compatibility: The script is fully dynamic. Whether you are scalping on a 5-minute chart or swing trading on the Daily, the logic automatically recalibrates to the current chart interval.

Smart Pivot Detection: Uses a configurable "Swing Depth" to filter out market noise, ensuring that only significant structural points are used to trigger signals.

Visual Market Sentiment: The background color shifts between green (bullish state) and red (bearish state), allowing you to see the current market character at a glance.

Integrated Alerts: Includes built-in alert conditions for both Bullish and Bearish CHoCH events, making it compatible with TradingView’s alert system for mobile or desktop notifications.

How it Works
Market Structure Mapping: The indicator identifies "valid" highs and lows based on the user-defined Swing Depth.

Bullish CHoCH: Occurs when the market is in a bearish state and the price closes above the most recent valid Swing High. This suggests a shift from supply-dominance to demand-dominance.

Bearish CHoCH: Occurs when the market is in a bullish state and the price closes below the most recent valid Swing Low. This suggests a shift from demand-dominance to supply-dominance.

Settings & Inputs
Swing Depth: Adjusts the sensitivity of the pivot detection.

Lower values (2–5): Highly sensitive, best for fast-moving scalping.

Higher values (10+): More conservative, used to identify major structural shifts on higher timeframes.

Trading Utility
This indicator is best used as a confirmation tool. Traders typically look for a CHoCH when price enters a higher-timeframe Point of Interest (POI), such as an Order Block or Fair Value Gap (FVG), to confirm that the lower-timeframe trend is reversing in alignment with the higher-timeframe bias.

Note: This indicator requires a candle close beyond the structural level to confirm a CHoCH, reducing the risk of "fakeouts" caused by simple wick touches (liquidity grabs).

## Source Code

````pine
//@version=5
indicator("Static CHoCH Entry Labels", overlay=true, max_labels_count=500)

// --- Inputs ---
depth = input.int(5, "Swing Depth", minval=2)

// --- Variables ---
var float lastHigh   = na
var float lastLow    = na
var bool  isBullish  = true 
var float entryPrice = na

// --- Pivot Detection ---
ph = ta.pivothigh(high, depth, depth)
pl = ta.pivotlow(low, depth, depth)

if not na(ph)
    lastHigh := ph
if not na(pl)
    lastLow := pl

// --- CHoCH Logic ---
bearishCHoCH = isBullish and close < lastLow
bullishCHoCH = not isBullish and close > lastHigh

// --- Logic & Visualization ---
if bearishCHoCH
    isBullish  := false
    entryPrice := close
    
    // Position the label in the open space above this specific candle
    // We use ATR to make sure it doesn't touch the candle wicks
    float labelY = high + (ta.atr(10) * 2)
    
    label.new(bar_index, labelY, "SELL ENTRY\n" + str.tostring(entryPrice, format.mintick), 
         color=color.red, 
         textcolor=color.white, 
         style=label.style_label_down, 
         size=size.small)
    
    // Visual Marker on the candle itself
    label.new(bar_index, high, "▼", color=color.new(color.red, 100), textcolor=color.red, style=label.style_label_down)

if bullishCHoCH
    isBullish  := true
    entryPrice := close
    
    // Position the label in the open space above this specific candle
    float labelY = high + (ta.atr(10) * 2)
    
    label.new(bar_index, labelY, "BUY ENTRY\n" + str.tostring(entryPrice, format.mintick), 
         color=color.green, 
         textcolor=color.white, 
         style=label.style_label_down, 
         size=size.small)
    
    // Visual Marker on the candle itself
    label.new(bar_index, low, "▲", color=color.new(color.green, 100), textcolor=color.green, style=label.style_label_up)

// --- Background and Structure Reference ---
plot(lastHigh, "Upper Boundary", color=isBullish ? color.gray : color.red, style=plot.style_linebr)
plot(lastLow, "Lower Boundary", color=isBullish ? color.green : color.gray, style=plot.style_linebr)
````
