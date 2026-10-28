# ATK / DEF Directional Movement State Engine

- url: https://www.tradingview.com/script/z4CmW4Wg/
- type: indicator
- pine_id: PUB;4f57d8fc93fb4733918adcc20d038814
- version: 1.0

## Description

Description

ATK / DEF Directional Movement State Engine is a market condition analysis framework built around the Directional Movement Index (DMI) system.

Unlike traditional DMI tools that mainly display +DI, -DI, and ADX values, this indicator focuses on interpre the effectiveness and current condition of directional movement through multiple analytical layers.

The engine combines directional strength, trend structure, volatility behavior, and price action characteristics to provide a structured view of market conditions.

The purpose of this framework is to evalu the qual of directional movement and understand the current state of market behavior.

Directional Movement Core

The foundation of this indicator is based on the DMI and ADX framework.

It analyzes:

+DI directional pressure
-DI directional pressure
ADX directional strength

The relationship between these components is used to class the current movement environment, including:

Strong directional conditions
Weak directional conditions
Balanced movement
Swinging conditions

Rather than focusing on a single numeri rea, the engine evalua how directional components interact with the broader market structure.

ATK / DEF Market State Concept

The ATK / DEF framework represents two different market behaviors.

ATK (Attack State)
Describes environments where directional movement demonstrates stronger activity and clearer momentum characteristics.

DEF (Defense State)
Describes environments where directional movement becomes weaker, balanced, or less defined.

The engine observes these states through directional strength, price structure, and movement behavior to describe the current market condition.

Directional Radar System

The Radar module analyzes current price behavior by combining candle structure and market movement characteristics.

It evaluates:

Candle body efficiency
Price range behavior
Directional pressure
Trend positioning
Short-term movement characterist

The radar provides a visual representation of the current behavioral condition, helping use understand whether the market is displaying expansion, decline, compression, or swing characteristics.

Trend Structure Analysis

The trend module evaluates market structure through multiple moving average relationships and price positioning.

It observes:

Short- trend direction
Medium-alignment
Long- structural condition

This provides additional context for understanding the relationship between directional movement and the overall price structure.

Velocity Measurement

The Velocity component measures current movement intensit through volatility conditions.

It evalua price movement range relative to recent market activity to describe different leve of movement speed.

This helps identify whether the current environment is experiencing:

Lower activity conditions
Normal movement conditions
Higher volatility conditions
Market Regime Observation

The Regime module evaluates changes in market activity using volatility structure.

It observes:

Expansion conditions
Contraction conditions
Range environments

This provides additional context around how the market is currently behaving.

ADX State Classification

The ADX state engine combines ADX strength with DI relationships to categorize directional conditions.

The classification includes:

Strong U
Strong D
Weak U
Weak D
Swing Condition

These states are designed to describe the current directional environment rather than forecast future market movement.

Integrated Dashboard

The built-in dashboard organizes multiple analytical components into a single view:

Engine status
Velocity level
Radar condition
Trend direction
Market regime
ADX state
Current price information

The dashboard provides a compact overview of market structure and directional behavior.

Design Philosophy

ATK / DEF Directional Movement State Engine is designed around the concept that market movement should be analyzed through multiple layers rather than a single indicator value.

By combining:

Directional movement analysis
ADX strength evaluation
Trend structure
Volatility behavior
Price action characteristics

the indicator provides a structured framework for observing market conditions and understanding directional movement effectiveness.

This tool is designed for analytical purposes, helping users stu market behavior, movement structure, and directional dynamics.

## Source Code

````pine
//@version=6
indicator("ATK / DEF Directional Movement State Engine", overlay=true, max_labels_count=500)

// ============================================
// 1. Core Data
// ============================================
float price = close

// Monthly timeframe data
float monthlyOpen = request.security(syminfo.tickerid, "M", open)
float monthlyLow = request.security(syminfo.tickerid, "M", low)

// ============================================
// 2. Directional Movement Indicators (ADX/DMI)
// ============================================
[dmiPlus, dmiMinus, adx] = ta.dmi(14, 14)

// ============================================
// 3. Plot Directional Indicators on Chart
// ============================================
plot(adx, color=color.rgb(255, 215, 0), linewidth=2, title="ADX", display=display.pane)
plot(dmiPlus, color=color.rgb(0, 230, 118), linewidth=1, title="+DI", display=display.pane)
plot(dmiMinus, color=color.rgb(255, 80, 80), linewidth=1, title="-DI", display=display.pane)

// Horizontal reference lines
hline(25, color=color.rgb(255, 215, 0, 60), linestyle=hline.style_dashed, title="Gold Zone 25")
hline(20, color=color.rgb(150, 150, 150, 50), linestyle=hline.style_dashed, title="Trigger Zone 20")

// ============================================
// 4. Engine Status (Active / Standby / Off)
// ============================================
string engineStatus = "Standby"
string engineIcon = "⏸️"
if price > monthlyOpen and price > ta.sma(close, 20)
    engineStatus := "Active"
    engineIcon := "▶️"
if price < monthlyLow and close < ta.sma(close, 20)
    engineStatus := "Off"
    engineIcon := "⏹️"

// ============================================
// 5. Velocity Level (1-5)
// ============================================
float atr = ta.atr(14)
float atrPercent = (atr / price) * 100
int speedLevel = 3
string speedIcon = "⚡"
if atrPercent >= 4.0
    speedLevel := 5
else if atrPercent >= 2.8
    speedLevel := 4
else if atrPercent >= 1.5
    speedLevel := 3
else if atrPercent >= 0.8
    speedLevel := 2
else
    speedLevel := 1

// ============================================
// 6. Flow Behavior Radar
// ============================================
string radarSignal = "Swing"
string radarIcon = "🌀"

float bullishPower = high - math.max(open, close)
float bearishPower = math.min(open, close) - low
float priceRange = high - low
float bodySize = math.abs(close - open)

if close > ta.sma(close, 20) and close > ta.sma(close, 50) and close > open and bodySize > priceRange * 0.5
    radarSignal := "Rally"
    radarIcon := "📈"
if close < ta.sma(close, 20) and close < ta.sma(close, 50) and close < open and bodySize > priceRange * 0.5
    radarSignal := "Decline"
    radarIcon := "📉"
if bodySize < priceRange * 0.3 and close > ta.sma(close, 20)
    radarSignal := "Shakeout"
    radarIcon := "🧹"
if bearishPower > bullishPower * 1.5 and close < open
    radarSignal := "Dump"
    radarIcon := "💥"
if bodySize < priceRange * 0.4 and math.abs(close - open) < atr * 0.3
    radarSignal := "Swing"
    radarIcon := "🌀"

// ============================================
// 7. Trend Direction
// ============================================
string trendDirection = "Side"
string trendIcon = "➡️"

bool ema20Up = ta.ema(close, 20) > ta.ema(close, 50)
bool ema50Up = ta.ema(close, 50) > ta.ema(close, 200)
bool priceAbove = close > ta.ema(close, 20) and close > ta.ema(close, 50)

if ema20Up and ema50Up and priceAbove
    trendDirection := "Up"
    trendIcon := "⬆️"
if not ema20Up and not ema50Up and close < ta.ema(close, 20) and close < ta.ema(close, 50)
    trendDirection := "Down"
    trendIcon := "⬇️"

// ============================================
// 8. Regime Prediction
// ============================================
string preventChange = "Range"
string preventIcon = "🔄"

[upper, middle, lower] = ta.bb(close, 20, 2)

float bbWidth = (upper - lower) / middle * 100
float bbWidthAvg = ta.sma(bbWidth, 10)

if not na(bbWidth) and not na(bbWidthAvg)
    if bbWidth > bbWidthAvg * 1.2
        preventChange := "Expansion"
        preventIcon := "↗️"
    if bbWidth < bbWidthAvg * 0.8
        preventChange := "Contraction"
        preventIcon := "↘️"

// ============================================
// 9. ADX State
// ============================================
string adxStatus = "Swing"
string adxIcon = "🌀"
color adxColor = color.rgb(255, 215, 0)

if adx > 25
    if dmiPlus > dmiMinus
        adxStatus := "Strong Up"
        adxIcon := "📈"
        adxColor := color.rgb(0, 255, 150)
    else
        adxStatus := "Strong Down"
        adxIcon := "📉"
        adxColor := color.rgb(255, 50, 50)
else if adx > 20
    if dmiPlus > dmiMinus
        adxStatus := "Weak Up"
        adxIcon := "↗️"
        adxColor := color.rgb(100, 255, 180)
    else
        adxStatus := "Weak Down"
        adxIcon := "↘️"
        adxColor := color.rgb(255, 150, 150)
else
    adxStatus := "Swing"
    adxIcon := "🌀"
    adxColor := color.rgb(255, 230, 100)

// ============================================
// 10. Right Side Dashboard
// ============================================
if barstate.islast
    color bgDolphin = color.rgb(20, 60, 140, 90)
    color bgBorder = color.rgb(80, 180, 255, 60)
    color textWhite = color.rgb(235, 245, 255)
    color textGold = color.rgb(255, 215, 0)
    color textGreen = color.rgb(0, 230, 118)
    color textRed = color.rgb(255, 80, 80)
    color textYellow = color.rgb(255, 215, 0)
    
    string priceStr = str.tostring(close, "#,##0.00")
    string pricePercent = str.tostring((close - monthlyOpen) / monthlyOpen * 100, "#.##") + "%"
    string adxStr = str.tostring(adx, "#.0")
    
    var table panelTable = table.new(
        position.top_right,
        1, 10,
        bgcolor = bgBorder,
        border_width = 1,
        border_color = bgBorder,
        frame_width = 1,
        frame_color = bgBorder
    )
    
    table.cell(panelTable, 0, 0, " 🐬 ATK / DEF Engine ", 
               text_color=textWhite, 
               bgcolor=color.rgb(30, 80, 180, 90),
               text_size=size.small, 
               text_halign=text.align_center)
    
    table.cell(panelTable, 0, 1, "▶️ Engine  " + engineIcon + " " + engineStatus, 
               text_color=engineStatus == "Active" ? textGreen : engineStatus == "Off" ? textRed : textYellow, 
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_left)
    
    table.cell(panelTable, 0, 2, "⚡ Velocity  " + speedIcon + " " + str.tostring(speedLevel) + " / 5", 
               text_color=textWhite, 
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_left)
    
    table.cell(panelTable, 0, 3, "📡 Radar  " + radarIcon + " " + radarSignal, 
               text_color=radarSignal == "Rally" ? textGreen : radarSignal == "Decline" ? textRed : textYellow,
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_left)
    
    table.cell(panelTable, 0, 4, "📊 Trend  " + trendIcon + " " + trendDirection, 
               text_color=trendDirection == "Up" ? textGreen : trendDirection == "Down" ? textRed : textYellow,
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_left)
    
    table.cell(panelTable, 0, 5, "🔮 Regime  " + preventIcon + " " + preventChange, 
               text_color=preventChange == "Expansion" ? textGreen : preventChange == "Contraction" ? textRed : textYellow,
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_left)
    
    table.cell(panelTable, 0, 6, "📈 ADX  " + adxIcon + " " + adxStatus + " " + adxStr, 
               text_color=adxColor,
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_left)
    
    table.cell(panelTable, 0, 7, "─────────────────────", 
               text_color=bgBorder, 
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_center)
    
    table.cell(panelTable, 0, 8, "💰 Price  " + priceStr + "  " + pricePercent, 
               text_color=textGold, 
               bgcolor=bgDolphin,
               text_size=size.small, 
               text_halign=text.align_left)
    
    table.cell(panelTable, 0, 9, "", 
               text_color=textWhite, 
               bgcolor=bgBorder,
               text_size=size.small, 
               text_halign=text.align_center)
````
