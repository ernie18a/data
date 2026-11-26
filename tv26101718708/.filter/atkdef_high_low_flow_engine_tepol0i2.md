# ATK/DEF High Low Flow Engine 

- url: https://www.tradingview.com/script/TePoL0i2/
- type: indicator
- pine_id: PUB;35834dde0cf04e4e9901d3d6f8c1e660
- version: 1.0

## Description

ATK/DEF High Low Flow Engine is a market structure analysis tool designed to evaluate the effectives of swing highs and swing lows through the combination of price structure, volume activity, and flow behavior.

Unlike traditional swing high and swing low tools that only display historical turning points, this indicator focuses on analyzing the internal behavior behind each structural high and low area.

The objective is not simply to locate previous price extremes, but to evaluate the quality and characteristics of those points by examining how volume participation and flow conditions developed during the formation of each swing structure.

The engine combines swing point analysis with (CMF) based volume flow evaluation to provide a deeper view of historical price behavior.

Core Analysis Components
1. Swing High / Swing Low Structure Analysis

The indicator processes historical swing points based on pivot structure calculati.

Each detec high and low represents a previous area where price created a local structural extreme.

Instead of treating all swing points equally, the indicator attaches additional behavioral information to each structural point by evaluati the market activity that occurred during its formation.

This allows users to stu the difference between simple pri extremes and pri extremes supported by stronger market participation.

2. CMF Flow Behavior Analysis

The Chaikin Flow (CMF) component evaluates the relationship between clo position, pric range, and volume activity.

By combining price location within the candle range with traded volume, CMF provides a measurement of flow characteristics around the selected period.

This module analyzes whether volume activity around structural highs and lows was associa with stronger inflow conditions, weaker flow conditions, neutral behavior, or declinin participation.

The purpose is to evaluate the internal volume behavior surrounding price structures rather than relying only on the visible price level.

3. Volume Activity Evaluation

The volume analysis component measures current volume participation relative to its historical average.

It provides context regarding whether market activity around price structures is relatively elevated, normal, or reduced.

This evaluation helps distinguish between swing points formed under different lev of market participation.

The volume component is used as a structural measurement factor and does not represent a volume distribution model or market profile visualization.

Structural Effectiveness Evaluation

Traditional swing high and swing low concepts mainly answer:

"Where did price previously create an extreme?"

This indicator expands that concept by analyzing:

"How did volume and money flow behave when that extreme was formed?"

By combining swing structure with CMF-based flow analysis, the indicator provides additional information about the characteristics behind historical highs and lows.

The displayed measurements represent analytical observations of price structure, volume conditions, and money flow behavior.

Dashboard Information

The integrated dashboard provides multiple analytical measurements including:

• CMF flow condition
• CMF moving average relationship
• Volume activity lev
• flow strength classification
• Price location relative to calculated flow reference
• Structural zone activity measurement

These vals are designed to provide a compact overvi of market behavior surrounding the current chart environment.

Key Features

• Swing high and swing low structural analysis
• Volume-based behavior evaluation
• CMF money flow measurement
• Historical high and low quality assessment
• Price structure combined with volume characteristics
• Liquidity activity observation
• Structural behavior dashboard
• Multi-factor market activity analysis
• Historical price extreme evaluation
• Quantitative observation of volume participation

ATK/DEF High Low Flow Engine is designed as a technical analysis and market structure research tool.

The calculat focus on stu the relationship between pric extremes, volume participation, and  flow characteristics.

Rather than displaying simple historical highs and lows, this framework provides additional context regarding the behavioral conditions surrounding those structural points.

All displayed values are analytical measurements derived from historical market data and are intended for research and technical analysis purposes.

## Source Code

````pine
//@version=6
indicator("ATK/DEF High Low Flow Engine ", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================
// 1. INPUT PARAMETERS
// ============================================
leftBars = input.int(5, "Left Bars", minval=1, tooltip="Number of bars to the left of pivot point")
rightBars = input.int(5, "Right Bars", minval=1, tooltip="Number of bars to the right of pivot point")
showLabels = input.bool(true, "Show Pivot Labels")
showDashboard = input.bool(true, "Show CMF Dashboard")

// CMF Parameters
cmf_period = input.int(20, "CMF Period", minval=5, tooltip="CMF calculation period")
cmf_ma_period = input.int(10, "CMF MA Period", minval=3, tooltip="CMF moving average period")

// ============================================
// 2. CMF (Chaikin Money Flow) Calculation
// ============================================

price_range = high - low
mf_multiplier = price_range != 0 ? ((close - low) - (high - close)) / price_range : 0

mf_volume = mf_multiplier * volume

cmf = math.sum(mf_volume, cmf_period) / math.sum(volume, cmf_period)

cmf_ma = ta.sma(cmf, cmf_ma_period)

cmf_vs_ma = cmf - cmf_ma

// ============================================
// 3. CMF Behavior (with MA)
// ============================================

cmf_behavior_text = cmf > 0.1 and cmf > cmf_ma ? "📈 Strong Inflow" :cmf > 0 and cmf > cmf_ma ? "📈 Inflow" : cmf > -0.1 and cmf < cmf_ma ? "➖ Neutral" :cmf < -0.1 and cmf < cmf_ma ? "📉 Outflow" : cmf > cmf_ma ? "📈 Bullish" :"📉 Bearish"

cmf_behavior_color = cmf > 0.1 and cmf > cmf_ma ? color.rgb(0, 200, 0) :
                     cmf > 0 and cmf > cmf_ma ? color.rgb(0, 255, 100) :
                     cmf > -0.1 and cmf < cmf_ma ? color.rgb(255, 200, 50) :
                     cmf < -0.1 and cmf < cmf_ma ? color.rgb(255, 50, 50) :
                     cmf > cmf_ma ? color.rgb(0, 200, 100) :
                     color.rgb(200, 100, 50)

// ============================================
// 4. CMF Liquidity Volume
// ============================================

volume_ma = ta.sma(volume, 20)

liquidity_factor = volume / volume_ma

liquidity_text = liquidity_factor > 1.5 ? "🔥 High Liquidity" :
                 liquidity_factor > 0.8 ? "📊 Normal" :
                 "💧 Low Liquidity"

liquidity_color = liquidity_factor > 1.5 ? color.rgb(255, 200, 50) :
                  liquidity_factor > 0.8 ? color.rgb(150, 150, 160) :
                  color.rgb(255, 50, 50)

// ============================================
// 5. CMF Overbought/Oversold
// ============================================

cmf_obos_text = cmf > 0.5 ? "🔴 Overbought" :cmf > 0.2 ? "🟡 Bullish" : cmf > -0.2 ? "⚪ Neutral" : cmf > -0.5 ? "🟡 Bearish" :  "🟢 Oversold"

cmf_obos_color = cmf > 0.5 ? color.rgb(255, 50, 50) :
                 cmf > 0.2 ? color.rgb(255, 200, 50) :
                 cmf > -0.2 ? color.rgb(150, 150, 160) :
                 cmf > -0.5 ? color.rgb(255, 200, 50) :
                 color.rgb(50, 200, 50)

// ============================================
// 6. CMF POC (Point of Control)
// ============================================

vwap = ta.vwap(close)
poc = vwap * (1 + cmf * 0.1)

poc_position = close > poc ? "📈 Below POC" :
               close < poc ? "📉 Above POC" :
               "⚖️ At POC"

poc_position_color = close > poc ? color.rgb(0, 200, 0) :
                     close < poc ? color.rgb(255, 50, 50) :
                     color.rgb(255, 200, 50)

// ============================================
// 7. CMF Zone Activity
// ============================================

cmf_zone_text = cmf > 0.3 ? "☀️ Strong Zone" :cmf > 0.1 ? "🌤️ Bullish Zone" :cmf > -0.1 ? "🌥️ Neutral Zone" :  cmf > -0.3 ? "🌧️ Bearish Zone" : "❄️ Weak Zone"

cmf_zone_color = cmf > 0.3 ? color.rgb(0, 200, 0) :
                 cmf > 0.1 ? color.rgb(0, 255, 100) :
                 cmf > -0.1 ? color.rgb(180, 180, 180) :
                 cmf > -0.3 ? color.rgb(255, 200, 50) :
                 color.rgb(255, 50, 50)

zone_progress = (cmf + 1) / 2 * 100

progress_bar = zone_progress > 80 ? "████████" :
               zone_progress > 60 ? "██████  " :
               zone_progress > 40 ? "████    " :
               zone_progress > 20 ? "██      " :
               "        "

// ============================================
// 8. Detect Swing Highs & Lows
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 9. Get CMF Values at Swing Points
// ============================================
swingHighCMF = ta.valuewhen(not na(swingHigh), cmf, 0)
swingLowCMF = ta.valuewhen(not na(swingLow), cmf, 0)

// ============================================
// 10. Swing Point Labels (with CMF Behavior)
// ============================================
if showLabels
    if not na(swingHigh)
        var string highBehavior = ""
        if swingHighCMF > 0.1
            highBehavior := "📈 Strong Inflow"
        else if swingHighCMF > 0
            highBehavior := "📈 Inflow"
        else if swingHighCMF > -0.1
            highBehavior := "➖ Neutral"
        else
            highBehavior := "📉 Outflow"
        
        label.new(bar_index[rightBars], swingHigh,
                  text="🔴 High\n" + 
                       str.tostring(swingHigh, "#.##") + "\n" +
                       "CMF: " + str.tostring(swingHighCMF, "#.##") + "\n" +
                       highBehavior,
                  color=color.rgb(200,0,0, 85), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
    
    if not na(swingLow)
        var string lowBehavior = ""
        if swingLowCMF > 0.1
            lowBehavior := "📈 Strong Inflow"
        else if swingLowCMF > 0
            lowBehavior := "📈 Inflow"
        else if swingLowCMF > -0.1
            lowBehavior := "➖ Neutral"
        else
            lowBehavior := "📉 Outflow"
        
        label.new(bar_index[rightBars], swingLow,
                  text="🟢 Low\n" + 
                       str.tostring(swingLow, "#.##") + "\n" +
                       "CMF: " + str.tostring(swingLowCMF, "#.##") + "\n" +
                       lowBehavior,
                  color=color.rgb(0,150,0, 85), textcolor=color.white,
                  style=label.style_label_up, size=size.small)

// ============================================
// 11. CMF Dashboard (Top Right)
// ============================================
if barstate.islast and showDashboard
    var table cmfTable = table.new(
        position.top_right,
        2, 7,
        border_color = color.rgb(255, 183, 77, 30),
        border_width = 1
    )
    
    bg_header = color.rgb(255, 200, 100, 20)
    
    table.cell(cmfTable, 0, 0, "📊 CMF Dashboard", 
               text_color=color.black, bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)
    table.cell(cmfTable, 1, 0, str.tostring(cmf, "#.##"), 
               text_color=color.black, bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)
    
    // ---------- Row 1: CMF Behavior ----------
    bg_row1 = color.rgb(255, 255, 255, 4)
    table.cell(cmfTable, 0, 1, "Behavior", 
               text_color=color.black, bgcolor=bg_row1,
               text_size=size.small, text_halign=text.align_center)
    table.cell(cmfTable, 1, 1, cmf_behavior_text, 
               text_color=cmf_behavior_color, bgcolor=bg_row1,
               text_size=size.small, text_halign=text.align_center)
    
    // ---------- Row 2: CMF MA ----------
    bg_row2 = color.rgb(255, 215, 0, 10)
    table.cell(cmfTable, 0, 2, "CMF MA", 
               text_color=color.black, bgcolor=bg_row2,
               text_size=size.small, text_halign=text.align_center)
    table.cell(cmfTable, 1, 2, str.tostring(cmf_ma, "#.##") + "\n" + 
               "Δ: " + str.tostring(cmf_vs_ma, "#.##"), 
               text_color=cmf_vs_ma > 0 ? color.rgb(0, 200, 0) : color.rgb(255, 50, 50), 
               bgcolor=bg_row2,
               text_size=size.small, text_halign=text.align_center)
    
    // ---------- Row 3: Liquidity Volume ----------
    bg_row3 = color.rgb(255, 255, 255, 6)
    table.cell(cmfTable, 0, 3, "Liquidity", 
               text_color=color.black, bgcolor=bg_row3,
               text_size=size.small, text_halign=text.align_center)
    table.cell(cmfTable, 1, 3, liquidity_text + " " + str.tostring(liquidity_factor, "#.##") + "x", 
               text_color=liquidity_color, bgcolor=bg_row3,
               text_size=size.small, text_halign=text.align_center)
    
    // ---------- Row 4: Overbought/Oversold ----------
    bg_row4 = color.rgb(255, 255, 255, 4)
    table.cell(cmfTable, 0, 4, "OB/OS", 
               text_color=color.black, bgcolor=bg_row4,
               text_size=size.small, text_halign=text.align_center)
    table.cell(cmfTable, 1, 4, cmf_obos_text, 
               text_color=cmf_obos_color, bgcolor=bg_row4,
               text_size=size.small, text_halign=text.align_center)
    
    // ---------- Row 5: POC ----------
    bg_row5 = color.rgb(255, 255, 255, 6)
    table.cell(cmfTable, 0, 5, "POC", 
               text_color=color.black, bgcolor=bg_row5,
               text_size=size.small, text_halign=text.align_center)
    table.cell(cmfTable, 1, 5, poc_position + "\n" + str.tostring(poc, "#.##"), 
               text_color=poc_position_color, bgcolor=bg_row5,
               text_size=size.small, text_halign=text.align_center)
    
    // ---------- Row 6: Zone Activity ----------
    bg_row6 = color.rgb(255, 255, 255, 4)
    table.cell(cmfTable, 0, 6, "Zone", 
               text_color=color.black, bgcolor=bg_row6,
               text_size=size.small, text_halign=text.align_center)
    table.cell(cmfTable, 1, 6, cmf_zone_text + "\n" + progress_bar + " " + str.tostring(zone_progress, "#") + "%", 
               text_color=cmf_zone_color, bgcolor=bg_row6,
               text_size=size.small, text_halign=text.align_center)
````
