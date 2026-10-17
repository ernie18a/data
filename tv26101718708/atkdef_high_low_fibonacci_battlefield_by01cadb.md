#  ATK/DEF HIGH LOW Fibonacci Battlefield 

- url: https://www.tradingview.com/script/by01CaDB/
- type: indicator
- pine_id: PUB;c501bc4d83ab46caa29584689a8402f6
- version: 1.0

## Description

ATK/DEF HIGH LOW Fibonacci Battlefield is a multi-factor market structure analysis framework designed to evalua the quality and behavior characte of swing highs and swing lows through the combination of Fibonacci positio, pric behavior, liquidity activity, and market pressure analysis.

Unlike traditional swing high and swing low identification tools that only mark histori tur poin based on pric locatn, this indicator focuses on stu the internal characts behind each detec high and low area.

The purpose of this framework is to provide additional structural context by evalua ho price interact with important swing locatio and how market activity changes around those areas.

The indicator combines three major analytical components into a unified battlefield evalua model:

1. Fibonacci Battlefield Structure

The Fibonacci Battlefield module evalua the position of pric within the current histori rang and analyzes the relationship between swing points and Fibonacci-based pric areas.

This component studies:

• Current pric location within the measured range
• Fibonacci retracement positionin  Distance between pric and important Fibonacci lev
• Structural reaction areas around previous highs and lows

Instead of treati Fibonacci leve as isolated horizontal lines, this module uses Fibonacci positioning as a framework to analyze the relative location and condition of pric  within a market structure.

The module provides a structural perspecti of whether historical swing areas are located near important Fibonacci zo and how these areas relae to current pric behavior.

2. Whirlpool Pressure Index

The Whirlpool Pressure Index evalua candle behavior and internal pric pressure by analyzing the relationship between bu pressure and se pressure.

This component examines:

• Candle rang distribution
• Closing position within the candle range
• Bu and se pressure balance
• Current pressure intensity around pric areas

The purpose of this calcula is to measure the behavioral characteristics of pric movement and understand the strength of interacti occurring near detec swing highs and swing lows.

It does not attempt to predfuture movement. Instead, it provides a quantimeasurement of current pric behavior based on historical candle information.

3. Liquidity Accelerator / Decelerator

The Liquidity Accelerator / Decelerator module evaluat changes in activity by analyzing volume behavior relative to its historic average.

This component focuses on:

• Relative volume activity
• Changes in market participation
• Liquidity expansion and contrac conditions
• Volume activity intensity around pric movement

The volume calcula is used as a market activity measurement and control reference, helping evalua whether a swing area is formed during stronger or weaker participation conditions.

This module represents volume activity analysis and is not a volume distribution profile or volume profile visualization.

High / Low Behavior Evaluation

The indicator identif swing highs and swing lows and attach multiple analytical measurements to each structural point.

Each detected high and low area can be evaluated through:

• Fibonacci structural position
• Price reaction characteristics
• Pressure condition
• Liquidity activity
• Market behavior context

This allows historical swing locatio to be stubeyond simple pric levels.

The framework focuses on the quality and characteristics of swing points rather than only identifyi where previous highs and lows occurred.

Integrated Battlefield Dashboard

The dashboard combines multiple analytical measurements into a compact information panel.

Displayed information includes:

• Fibonacci structural condition
• Pressure balance measurement
• Liquidity activity condition
• Flow balance characteristics
• Current market environment status

The dashboard is designed to provide a structured overview of market behavior and pric conditions from multiple perspectives.

Market Condition Analysis

The market condition module evaluat  the current relationship between pric exten, momentum characteristics, and recent pric range behavior.

It analyzes:

• RSI positioning
• Recent pric extremes
• Momentum condition
• Pric and oscillator relationship

This component is designed to describe the current market environment and highlight changes in pric behavior characteristics.

It is a condition measurement tool based on historical market data rather than a prediction system.

Core Features

• Swing High and Swing Low structural analysis
• Fibonacci-based battlefield framework
• Pric behavior evaluati
• Candle pressure measurement
• Volume activity analysis
• Liquidity condition tracking
• Multi-factor market structure dashboard
• Historical swing point contextual analysis
• Quantitative evaluat of pric areas
• Integrat structural and behavioral analysis framework

Concept

ATK/DEF HIGH LOW Fibonacci Battlefield is designed to stu the relationship between pric structure, market participation, and behavioral characteristics.

Traditional swing tools mainy focus on identifying previous highs and lows. This framework expas the analysis by combining structural position, candle behavior, and volume activity to evalua the characteris behind each swing location.

All calculat are derived from historical market data and are intended for market research, technical analysis, and structural observation purposes.

The displayed values represent analytical measurements of pric behavior, liquidity conditions, and market structure characteristics.

## Source Code

````pine
//@version=6
indicator(" ATK/DEF HIGH LOW Fibonacci Battlefield ", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================
// 1. INPUT PARAMETERS
// ============================================
leftBars = input.int(5, "Left Bars", minval=1, tooltip="Number of bars to the left of pivot point")
rightBars = input.int(5, "Right Bars", minval=1, tooltip="Number of bars to the right of pivot point")
showLabels = input.bool(true, "Show Pivot Labels")
showDashboard = input.bool(true, "Show Dashboard", group="Dashboard Settings")

// Fibo Parameters
fibo_lookback = input.int(50, "Fibo Lookback", minval=20, maxval=200, tooltip="Fibonacci calculation period")

// ============================================
// 2. DETECT SWING HIGHS & LOWS
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 3. ATK/DEF FIBO CALCULATION
// ============================================

// -------- 3.1 Calculate Fibonacci Levels --------
highest_high = ta.highest(high, fibo_lookback)
lowest_low = ta.lowest(low, fibo_lookback)
fibo_range = highest_high - lowest_low

fibo_0 = lowest_low
fibo_236 = lowest_low + fibo_range * 0.236
fibo_382 = lowest_low + fibo_range * 0.382
fibo_500 = lowest_low + fibo_range * 0.500
fibo_618 = lowest_low + fibo_range * 0.618
fibo_786 = lowest_low + fibo_range * 0.786
fibo_100 = highest_high

// -------- 3.2 Calculate Price Position in Fibonacci --------
price_position = (close - lowest_low) / fibo_range * 100

// -------- 3.3 Fibonacci Reaction Strength --------
fibo_reaction = (close - fibo_382) / (fibo_618 - fibo_382) * 50 + 50
fibo_reaction := math.min(100, math.max(0, fibo_reaction))

// -------- 3.4 Nearest Fibonacci Support/Resistance --------
var float nearest_resistance_price = fibo_100
var string nearest_resistance_fibo = "1.0"
var float nearest_support_price = fibo_0
var string nearest_support_fibo = "0.0"

// Resistance
if close < fibo_236
    nearest_resistance_price := fibo_236
    nearest_resistance_fibo := "0.236"
else if close < fibo_382
    nearest_resistance_price := fibo_382
    nearest_resistance_fibo := "0.382"
else if close < fibo_500
    nearest_resistance_price := fibo_500
    nearest_resistance_fibo := "0.500"
else if close < fibo_618
    nearest_resistance_price := fibo_618
    nearest_resistance_fibo := "0.618"
else if close < fibo_786
    nearest_resistance_price := fibo_786
    nearest_resistance_fibo := "0.786"
else if close < fibo_100
    nearest_resistance_price := fibo_100
    nearest_resistance_fibo := "1.0"
else
    nearest_resistance_price := fibo_100
    nearest_resistance_fibo := "1.0"

// Support
if close > fibo_100
    nearest_support_price := fibo_786
    nearest_support_fibo := "0.786"
else if close > fibo_786
    nearest_support_price := fibo_618
    nearest_support_fibo := "0.618"
else if close > fibo_618
    nearest_support_price := fibo_500
    nearest_support_fibo := "0.500"
else if close > fibo_500
    nearest_support_price := fibo_382
    nearest_support_fibo := "0.382"
else if close > fibo_382
    nearest_support_price := fibo_236
    nearest_support_fibo := "0.236"
else if close > fibo_236
    nearest_support_price := fibo_0
    nearest_support_fibo := "0.0"
else
    nearest_support_price := fibo_0
    nearest_support_fibo := "0.0"

// -------- 3.5 Fibo Behavior --------
var string fibo_behavior = ""
if price_position > 78.6
    fibo_behavior := "⚔️ ATK Zone"
else if price_position > 61.8
    fibo_behavior := "📉 Deep Pullback"
else if price_position > 38.2
    fibo_behavior := "📊 Standard Pullback"
else if price_position > 23.6
    fibo_behavior := "📈 Shallow Pullback"
else
    fibo_behavior := "🔄 Deep Retracement"

// ============================================
// 4. WHIRLPOOL PRESSURE INDEX
// ============================================

range_hl = high - low

// Selling Pressure = (High - Close) / (High - Low) * 100
selling_pressure = range_hl != 0 ? (high - close) / range_hl * 100 : 50

// Buying Pressure = (Close - Low) / (High - Low) * 100
buying_pressure = range_hl != 0 ? (close - low) / range_hl * 100 : 50

// Whirlpool Pressure = Selling / Buying * 50
whirlpool_pressure = buying_pressure > 0 ? selling_pressure / buying_pressure * 50 : 50
whirlpool_pressure := math.min(100, math.max(0, whirlpool_pressure))

whirlpool_text = whirlpool_pressure > 70 ? "🔥 High Pressure" :
                 whirlpool_pressure > 50 ? "📊 Balanced" :
                 "🟢 Low Pressure"

whirlpool_color = whirlpool_pressure > 70 ? color.rgb(255, 50, 50) :
                  whirlpool_pressure > 50 ? color.rgb(255, 200, 50) :
                  color.rgb(0, 200, 0)

// ============================================
// 5. LIQUIDITY ACCELERATOR/DECELERATOR
// ============================================

volume_ma = ta.sma(volume, 20)
volume_ratio = volume / volume_ma

// Liquidity Change Rate
liquidity_change = (volume_ratio - volume_ratio[1]) / volume_ratio[1] * 100
liquidity_change := not na(liquidity_change) ? liquidity_change : 0

// Accelerator/Decelerator
liquidity_accel = liquidity_change > 5 ? "🚀 Accelerate" :
                  liquidity_change > -5 ? "➖ Stable" :
                  "🛑 Decelerate"

liquidity_accel_color = liquidity_change > 5 ? color.rgb(0, 200, 0) :liquidity_change > -5 ? color.rgb(255, 200, 50) :color.rgb(255, 50, 50)

// ============================================
// 6. BALANCE FLOW MAINTENANCE INDEX
// ============================================

// Flow Balance = Buying / Selling
flow_balance = selling_pressure > 0 ? buying_pressure / selling_pressure : 50

// Balance Flow Index (0-100)
balance_flow = flow_balance * 50
balance_flow := math.min(100, math.max(0, balance_flow))

balance_text = balance_flow > 60 ? "🟢 Bullish Maintain" :
               balance_flow > 40 ? "📊 Balanced" :
               "🔴 Bearish Maintain"

balance_color = balance_flow > 60 ? color.rgb(0, 200, 0) :balance_flow > 40 ? color.rgb(255, 200, 50) : color.rgb(255, 50, 50)

// ============================================
// 7. DIRECTION REVERSAL TIMER 💣
// ============================================

rsi = ta.rsi(close, 14)

price_high_20 = ta.highest(high, 20)
price_low_20 = ta.lowest(low, 20)
rsi_high_20 = ta.highest(rsi, 20)
rsi_low_20 = ta.lowest(rsi, 20)

reversal_signal = (rsi > 70 and close == price_high_20) or
                  (rsi < 30 and close == price_low_20) or
                  (close == price_high_20 and rsi < rsi_high_20) or
                  (close == price_low_20 and rsi > rsi_low_20)

reversal_timer = reversal_signal ? "💣 Reversal!" :
                 rsi > 70 ? "⚠️ Overbought" :
                 rsi < 30 ? "⚠️ Oversold" :
                 "✅ Normal"

reversal_color = reversal_signal ? color.rgb(255, 0, 0) :
                 rsi > 70 ? color.rgb(255, 200, 50) :
                 rsi < 30 ? color.rgb(0, 200, 255) :
                 color.rgb(0, 200, 0)

// ============================================
// 8. GET SWING POINT FIBO VALUES
// ============================================

swingHighPricePos = ta.valuewhen(not na(swingHigh), price_position, 0)
swingLowPricePos = ta.valuewhen(not na(swingLow), price_position, 0)

swingHighFiboReaction = ta.valuewhen(not na(swingHigh), fibo_reaction, 0)
swingLowFiboReaction = ta.valuewhen(not na(swingLow), fibo_reaction, 0)

currentPricePos = price_position
currentReaction = fibo_reaction

// ============================================
// 9. SWING POINT LABELS
// ============================================
if showLabels
    if not na(swingHigh)
        highPricePos = not na(swingHighPricePos) ? swingHighPricePos : currentPricePos
        highReaction = not na(swingHighFiboReaction) ? swingHighFiboReaction : currentReaction
        
        var string highZone = ""
        if highPricePos > 61.8
            highZone := "⚔️ ATK Zone"
        else if highPricePos > 50
            highZone := "📈 Bullish Zone"
        else if highPricePos > 38.2
            highZone := "📊 Neutral Zone"
        else
            highZone := "🛡️ DEF Zone"
        
        var string highReact = ""
        if highReaction > 70
            highReact := "🔥 Strong"
        else if highReaction > 50
            highReact := "📊 Moderate"
        else
            highReact := "💤 Weak"
        
        var string highPullback = ""
        if highPricePos > 78.6
            highPullback := "⚔️ ATK Zone"
        else if highPricePos > 61.8
            highPullback := "📉 Deep Pullback"
        else if highPricePos > 38.2
            highPullback := "📊 Standard"
        else if highPricePos > 23.6
            highPullback := "📈 Shallow"
        else
            highPullback := "🔄 Deep Retrace"
        
        label.new(bar_index[rightBars], swingHigh,
                  text="🔴 High " + str.tostring(swingHigh, "#.##") + "\n" +
                       "Pullback " + highPullback + "\n" +
                       "Zone " + highZone + "\n" +
                       "Reaction " + highReact + " (" + str.tostring(highReaction, "#") + "%)\n" +
                       "Support " + str.tostring(nearest_support_price, "#.##") + " (" + nearest_support_fibo + ")\n" +
                       "Resistance " + str.tostring(nearest_resistance_price, "#.##") + " (" + nearest_resistance_fibo + ")",
                  color=color.rgb(200,0,0, 85), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
    
    if not na(swingLow)
        lowPricePos = not na(swingLowPricePos) ? swingLowPricePos : currentPricePos
        lowReaction = not na(swingLowFiboReaction) ? swingLowFiboReaction : currentReaction
        
        var string lowZone = ""
        if lowPricePos > 61.8
            lowZone := "⚔️ ATK Zone"
        else if lowPricePos > 50
            lowZone := "📈 Bullish Zone"
        else if lowPricePos > 38.2
            lowZone := "📊 Neutral Zone"
        else
            lowZone := "🛡️ DEF Zone"
        
        var string lowReact = ""
        if lowReaction > 70
            lowReact := "🔥 Strong"
        else if lowReaction > 50
            lowReact := "📊 Moderate"
        else
            lowReact := "💤 Weak"
        
        var string lowPullback = ""
        if lowPricePos > 78.6
            lowPullback := "⚔️ ATK Zone"
        else if lowPricePos > 61.8
            lowPullback := "📉 Deep Pullback"
        else if lowPricePos > 38.2
            lowPullback := "📊 Standard"
        else if lowPricePos > 23.6
            lowPullback := "📈 Shallow"
        else
            lowPullback := "🔄 Deep Retrace"
        
        label.new(bar_index[rightBars], swingLow,
                  text="🟢 Low " + str.tostring(swingLow, "#.##") + "\n" +
                       "Pullback " + lowPullback + "\n" +
                       "Zone " + lowZone + "\n" +
                       "Reaction " + lowReact + " (" + str.tostring(lowReaction, "#") + "%)\n" +
                       "Support " + str.tostring(nearest_support_price, "#.##") + " (" + nearest_support_fibo + ")\n" +
                       "Resistance " + str.tostring(nearest_resistance_price, "#.##") + " (" + nearest_resistance_fibo + ")",
                  color=color.rgb(0,150,0, 85), textcolor=color.white,
                  style=label.style_label_up, size=size.small)

// ============================================
// 10. DASHBOARD (Top Right)
// ============================================
if barstate.islast and showDashboard
    var table dashTable = table.new(
        position.top_right,
        2, 6,
        border_color = color.rgb(255, 215, 0, 30),
        border_width = 1
    )
    
    bg_header = color.rgb(255, 215, 0, 20)
    
    table.cell(dashTable, 0, 0, "📊 Fibo Dashboard", 
               text_color=color.black, bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dashTable, 1, 0, str.tostring(price_position, "#") + "%", 
               text_color=color.black, bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)
    
    // Row 1: Fibo Behavior
    bg_row1 = color.rgb(255, 255, 255, 4)
    table.cell(dashTable, 0, 1, "📊 Fibo Behavior", 
               text_color=color.black, bgcolor=bg_row1,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dashTable, 1, 1, fibo_behavior + "\n" + str.tostring(fibo_reaction, "#") + "%", 
               text_color=color.rgb(255, 215, 0), bgcolor=bg_row1,
               text_size=size.small, text_halign=text.align_center)
    
    // Row 2: Whirlpool Pressure
    bg_row2 = color.rgb(255, 255, 255, 6)
    table.cell(dashTable, 0, 2, "🌀 Pressure", 
               text_color=color.black, bgcolor=bg_row2,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dashTable, 1, 2, whirlpool_text + "\n" + str.tostring(whirlpool_pressure, "#") + "%", 
               text_color=whirlpool_color, bgcolor=bg_row2,
               text_size=size.small, text_halign=text.align_center)
    
    // Row 3: Liquidity
    bg_row3 = color.rgb(255, 255, 255, 4)
    table.cell(dashTable, 0, 3, "⚡ Liquidity", 
               text_color=color.black, bgcolor=bg_row3,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dashTable, 1, 3, liquidity_accel + "\n" + str.tostring(liquidity_change, "#.##") + "%", 
               text_color=liquidity_accel_color, bgcolor=bg_row3,
               text_size=size.small, text_halign=text.align_center)
    
    // Row 4: Balance Flow
    bg_row4 = color.rgb(255, 255, 255, 6)
    table.cell(dashTable, 0, 4, "⚖️ Balance", 
               text_color=color.black, bgcolor=bg_row4,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dashTable, 1, 4, balance_text + "\n" + str.tostring(balance_flow, "#") + "%", 
               text_color=balance_color, bgcolor=bg_row4,
               text_size=size.small, text_halign=text.align_center)
    
    // Row 5: Reversal Timer 💣
    bg_row5 = color.rgb(255, 200, 100, 10)
    table.cell(dashTable, 0, 5, "💣 Reversal", 
               text_color=color.black, bgcolor=bg_row5,
               text_size=size.small, text_halign=text.align_center)
    table.cell(dashTable, 1, 5, reversal_timer + "\nRSI: " + str.tostring(rsi, "#"), 
               text_color=reversal_color, bgcolor=bg_row5,
               text_size=size.small, text_halign=text.align_center)
````
