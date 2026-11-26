#  ATK/DEF High Low & MA Engine

- url: https://www.tradingview.com/script/hMzHjFEo/
- type: indicator
- pine_id: PUB;2f8cfeab1f4e415382e98fd6e289456f
- version: 1.0

## Description

ATK/DEF High Low & MA Engine is a market structure analysis framework designed to evalu histor high and low price behavior together with moving average structure, momentum conditio, and volume environment.

Unlike traditional high and low markers that only display previous turning points, this indicator focuses on analyzing the quality and context of price extr by combining swing point identification with broade market conditions.

The purpose of this engine is to provide a structured view of how histo highs and lows develo, how pric interacts with different market phases, and how trend structure changes around important pric areas.

High & Low Structure Analysis

The indicator identifies swing highs and swing lows using pivot-based market structure detection.

Rather than treati eve high or low as equally signific, the framework is designed to highlight the relationship between:

Historical price turning points
Market direction
Trend organization
Pric momentum conditions
Trad activity environment

Swing points represent areas where pric previously experienced a structural reaction. These points can be used as references for stud market behavior and price development.

ATK / DEF Market Structure Concept

The indicator uses the concept of:

ATK (Attack Structure)
and
DEF (Defense Structure)

to describe different pric behaviors around market movement.

ATK focuses on directional strength and pric expansion characteristics.

DEF focuses on pric holding behavior, reaction areas, and structural balance.

This framework does not classify market movement as a guaran future outcome. Instead, it provides a visual representation of current market structure conditions based on histor price information.

Moving Average Structure Engine

The indicator integrates three moving averages to evalu market organization across different periods.

The MA framework analyzes:

Short-term price movement
Medium-term structure
Longer-term market direction

The relationship between multiple moving averages helps display:

Trend alignment
Directional consistency
Transition phases
Mixed market conditions

Instead of relying on a single moving average, the engine observes the interaction between different periods to provide a broader view of market structure.

Momentum & Market Condition Evaluati

The engine includes momentum observation by comparing recent pric movement with previous pric levels.

This component evaluates:

Pric expansion strength
Directional momentum
Neutral conditions
Weakenin movement

Momentum information is displayed as part of the overall market condition analysis and is intended to provide additional context around pric structure.

Volume Environment Analysis

Volume conditions are included to measure the activity level behind price movement.

The volume module compares current activity against histor volume behavior to classify market participation conditions.

This helps analyze whether pric movement is occurring in:

Higher activ environments
Normal participation conditions
Lower activity environments

Volume information is used as a contextu factor and is not designed to predic future pric movement.

Multi-Factor Market Rating Framework

The data panel combines mul market observations into a summa structural view.

The evaluation considers factors including:

Moving average alig
Moving average direction
Momentum condition
Volume environment
Pric position relative to moving averages

The displayed condition represents the current relationship between these factors and should be interpre as a market context reference rather than a standal tra decision.

Difference From Traditional High/Low Indicators

Traditional high and low indicators generally focus only on locat previous turning points.

ATK/DEF High Low & MA Engine expands this concept by combining:

Swing structure
Trend organization
Momentum context
Volume environment
Market condition overview

The objective is not simply to mark where pric changed direction, but to stu why those histo highs and lows devel within different market environments.

Design Philosophy

Markets are dyna systems where price extremes are created through the interaction of movement, participation, and structure.

This indicator is designed around the idea that a high or low point should be viewe together with its surrou conditions rather than as an isolat pric lev.

By combining structural highs/lows with moving average behavior and market context, the engine provides a more complete visualization of pric behavior.

Features

• Pivot-based swing high and swing low detection
• Three-period moving average structure analysis
• Trend arrangement observation
• Momentum condition display
• Volume environment monitoring
• Market condition dashboard
• Structural high/low visualization
• Multi-factor context evalua

Important Note

ATK/DEF High Low & MA Engine is an analytical tool designed to visualize market structure and histori pric behavior.

It does not provide finan advice, guaran outcomes, or direct tra instructions.

Users should combine this tool with their own analysis, risk manageme, and tra methodology when making decisions.

## Source Code

````pine
//@version=6
indicator("☀️ ATK/DEF High Low & MA Engine", overlay=true, max_lines_count=200, max_labels_count=200)

// ============================================
// 1. INPUT PARAMETERS
// ============================================
leftBars = input.int(5, "Left Bars", minval=1)
rightBars = input.int(5, "Right Bars", minval=1)
showLabels = input.bool(true, "Show Pivot Labels")

// MA Parameters
showMA = input.bool(true, "Show MAs", group="MA Settings")
ma1_length = input.int(7, "MA1 Period", minval=1, group="MA Settings")
ma1_color = input.color(color.new(#4FC3F7, 0), "MA1 Color", group="MA Settings")
ma2_length = input.int(20, "MA2 Period", minval=1, group="MA Settings")
ma2_color = input.color(color.new(#FFB74D, 0), "MA2 Color", group="MA Settings")
ma3_length = input.int(60, "MA3 Period", minval=1, group="MA Settings")
ma3_color = input.color(color.new(#EF5350, 0), "MA3 Color", group="MA Settings")

// Motor Switch
showMotor = input.bool(true, "Show Motor", group="MA Settings")
showTable = input.bool(true, "Show Data Panel ☀️", group="MA Settings")

// ============================================
// 2. CALCULATE THREE MAs
// ============================================
ma1 = ta.sma(close, ma1_length)
ma2 = ta.sma(close, ma2_length)
ma3 = ta.sma(close, ma3_length)

// Arrangement Detection
bullishArrange = ma1 > ma2 and ma2 > ma3
bearishArrange = ma1 < ma2 and ma2 < ma3

// Arrangement Changes
bullishCross = ta.crossover(ma1, ma2) and ma2 > ma3
bearishCross = ta.crossunder(ma1, ma2) and ma2 < ma3

// ============================================
// 3. PLOT THREE MAs
// ============================================
plot(showMA ? ma1 : na, color=ma1_color, linewidth=2, title="MA1")
plot(showMA ? ma2 : na, color=ma2_color, linewidth=2, title="MA2")
plot(showMA ? ma3 : na, color=ma3_color, linewidth=2, title="MA3")

// ============================================
// 4. MOTOR (Enlarged Labels)
// ============================================
if showMotor
    if bullishCross
        label.new(bar_index, low - (high - low) * 0.8,
                  text="   ☀️ BULLISH  \n" +
                       " MA1 > MA2 > MA3 \n" +
                       "  Trend Up  ", 
                  color=color.new(#66BB6A, 85), 
                  textcolor=color.white,
                  style=label.style_label_up, 
                  size=size.large)
    
    if bearishCross
        label.new(bar_index, high + (high - low) * 0.8,
                  text="   🌧️ BEARISH  \n" +
                       " MA1 < MA2 < MA3 \n" +
                       "  Trend Down  ", 
                  color=color.new(#EF5350, 85), 
                  textcolor=color.white,
                  style=label.style_label_down, 
                  size=size.large)

// ============================================
// 5. ☀️ SUNSHINE DATA PANEL
// ============================================
if barstate.islast and showTable
    var table infoTable = table.new(
        position.top_right, 
        5, 6,
        border_color = color.new(#FFB74D, 30),
        border_width = 1
    )
    
    // ---------- Row 0: Header ----------
    bg_header = color.rgb(255, 215, 120, 20)
    
    table.cell(infoTable, 0, 0, "☀️ ATK/DEF", 
               text_color=color.black, 
               bgcolor=color.rgb(255, 200, 100, 25),
               text_size=size.small, text_halign=text.align_center)
    
    table.cell(infoTable, 1, 0, "MA7", 
               text_color=color.black, 
               bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)
    
    table.cell(infoTable, 2, 0, "MA20", 
               text_color=color.black, 
               bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)
    
    table.cell(infoTable, 3, 0, "MA60", 
               text_color=color.black, 
               bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)
    
    table.cell(infoTable, 4, 0, "Status", 
               text_color=color.black, 
               bgcolor=bg_header,
               text_size=size.small, text_halign=text.align_center)

    // ---------- Row 1: MA Direction ----------
    bg_row = color.rgb(255, 255, 255, 6)
    
    table.cell(infoTable, 0, 1, "Direction", 
               text_color=color.black, 
               bgcolor=bg_row,
               text_size=size.small, text_halign=text.align_center)
    
    ma1_dir = ma1 > ma1[1] ? "↗" : "↘"
    ma1_dir_color = ma1 > ma1[1] ? color.rgb(0, 120, 0) : color.rgb(180, 0, 0)
    table.cell(infoTable, 1, 1, ma1_dir, 
               text_color=ma1_dir_color, bgcolor=bg_row,
               text_size=size.small, text_halign=text.align_center)
    
    ma2_dir = ma2 > ma2[1] ? "↗" : "↘"
    ma2_dir_color = ma2 > ma2[1] ? color.rgb(0, 120, 0) : color.rgb(180, 0, 0)
    table.cell(infoTable, 2, 1, ma2_dir, 
               text_color=ma2_dir_color, bgcolor=bg_row,
               text_size=size.small, text_halign=text.align_center)
    
    ma3_dir = ma3 > ma3[1] ? "↗" : "↘"
    ma3_dir_color = ma3 > ma3[1] ? color.rgb(0, 120, 0) : color.rgb(180, 0, 0)
    table.cell(infoTable, 3, 1, ma3_dir, 
               text_color=ma3_dir_color, bgcolor=bg_row,
               text_size=size.small, text_halign=text.align_center)
    
    if bullishArrange
        table.cell(infoTable, 4, 1, "☀️ Bull", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row,
                   text_size=size.small, text_halign=text.align_center)
    else if bearishArrange
        table.cell(infoTable, 4, 1, "🌧️ Bear", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 4, 1, "🌥️ Mixed", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row,
                   text_size=size.small, text_halign=text.align_center)

    // ---------- Row 2: Momentum ----------
    bg_row2 = color.rgb(255, 255, 255, 4)
    
    table.cell(infoTable, 0, 2, "Momentum", 
               text_color=color.black, 
               bgcolor=bg_row2,
               text_size=size.small, text_halign=text.align_center)
    
    momentum_pct = (close - close[10]) / close[10] * 100
    
    if momentum_pct > 2
        table.cell(infoTable, 1, 2, "Strong", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 2, "📈", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 2, "Up", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
    else if momentum_pct > -2
        table.cell(infoTable, 1, 2, "Neutral", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 2, "➖", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 2, "Flat", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 1, 2, "Weak", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 2, "📉", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 2, "Down", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
    
    if bullishCross
        table.cell(infoTable, 4, 2, "⭐ Golden", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
    else if bearishCross
        table.cell(infoTable, 4, 2, "⚠️ Death", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 4, 2, "💤 Wait", 
                   text_color=color.rgb(100, 100, 100), bgcolor=bg_row2,
                   text_size=size.small, text_halign=text.align_center)

    // ---------- Row 3: Signal ----------
    bg_row3 = color.rgb(255, 200, 100, 10)
    
    table.cell(infoTable, 0, 3, "🎯 Signal", 
               text_color=color.black, 
               bgcolor=bg_row3,
               text_size=size.small, text_halign=text.align_center)
    
    buy_signals = 0
    sell_signals = 0
    
    if ma1 > ma1[1]
        buy_signals := buy_signals + 1
    else
        sell_signals := sell_signals + 1
    if ma2 > ma2[1]
        buy_signals := buy_signals + 1
    else
        sell_signals := sell_signals + 1
    if ma3 > ma3[1]
        buy_signals := buy_signals + 1
    else
        sell_signals := sell_signals + 1
    if momentum_pct > 0
        buy_signals := buy_signals + 1
    else
        sell_signals := sell_signals + 1
    
    if buy_signals >= 3
        table.cell(infoTable, 1, 3, "🟢 BUY", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 3, "⚡", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 3, str.tostring(buy_signals) + "/4", 
                   text_color=color.black, bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
    else if sell_signals >= 3
        table.cell(infoTable, 1, 3, "🔴 SELL", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 3, "⚡", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 3, str.tostring(sell_signals) + "/4", 
                   text_color=color.black, bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 1, 3, "⏸️ WAIT", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 3, "🌀", 
                   text_color=color.rgb(100, 100, 100), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 3, str.tostring(buy_signals) + "/" + str.tostring(sell_signals), 
                   text_color=color.black, bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
    
    if bullishArrange
        table.cell(infoTable, 4, 3, "📈 LONG", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
    else if bearishArrange
        table.cell(infoTable, 4, 3, "📉 SHORT", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 4, 3, "🧘 WAIT", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row3,
                   text_size=size.small, text_halign=text.align_center)

    // ---------- Row 4: Volume ----------
    bg_row4 = color.rgb(255, 255, 255, 4)
    
    table.cell(infoTable, 0, 4, "📊 Volume", 
               text_color=color.black, 
               bgcolor=bg_row4,
               text_size=size.small, text_halign=text.align_center)
    
    volume_ma = ta.sma(volume, 20)
    volume_ratio = volume / volume_ma
    
    if volume_ratio > 1.5
        table.cell(infoTable, 1, 4, "🔥 High", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 4, str.tostring(volume_ratio, "#.##") + "x", 
                   text_color=color.black, bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 4, "🚀 Active", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
    else if volume_ratio > 0.8
        table.cell(infoTable, 1, 4, "🌊 Normal", 
                   text_color=color.rgb(100, 100, 100), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 4, str.tostring(volume_ratio, "#.##") + "x", 
                   text_color=color.black, bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 4, "🌿 Stable", 
                   text_color=color.rgb(100, 100, 100), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 1, 4, "💧 Low", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 4, str.tostring(volume_ratio, "#.##") + "x", 
                   text_color=color.black, bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 4, "😴 Quiet", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
    
    if volume > volume_ma
        table.cell(infoTable, 4, 4, "📈 Up", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 4, 4, "📉 Down", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row4,
                   text_size=size.small, text_halign=text.align_center)

    // ---------- Row 5: Overall Rating ----------
    bg_row5 = color.rgb(255, 200, 100, 15)
    
    table.cell(infoTable, 0, 5, "☀️ Overall", 
               text_color=color.black, 
               bgcolor=bg_row5,
               text_size=size.small, text_halign=text.align_center)
    
    score = 0
    if bullishArrange
        score := score + 3
    if ma1 > ma1[1] and ma2 > ma2[1]
        score := score + 2
    if momentum_pct > 0
        score := score + 2
    if volume > volume_ma
        score := score + 1
    if close > ma1
        score := score + 2
    
    if score >= 7
        table.cell(infoTable, 1, 5, "🌟 Strong", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 5, str.tostring(score) + "/10", 
                   text_color=color.black, bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 5, "☀️ Sunny", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 4, 5, "✅ BULL", 
                   text_color=color.rgb(0, 130, 0), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
    else if score >= 4
        table.cell(infoTable, 1, 5, "🌤️ Neutral", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 5, str.tostring(score) + "/10", 
                   text_color=color.black, bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 5, "⛅ Cloudy", 
                   text_color=color.rgb(100, 100, 100), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 4, 5, "⏸️ WAIT", 
                   text_color=color.rgb(180, 120, 0), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
    else
        table.cell(infoTable, 1, 5, "❄️ Weak", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 2, 5, str.tostring(score) + "/10", 
                   text_color=color.black, bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 3, 5, "🌧️ Rainy", 
                   text_color=color.rgb(80, 80, 120), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)
        table.cell(infoTable, 4, 5, "📉 BEAR", 
                   text_color=color.rgb(180, 0, 0), bgcolor=bg_row5,
                   text_size=size.small, text_halign=text.align_center)

// ============================================
// 6. DETECT SWING HIGHS & LOWS
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 7. SWING POINT LABELS
// ============================================
if showLabels
    if not na(swingHigh)
        label.new(bar_index[rightBars], swingHigh,
                  text="🔴 High\n" + str.tostring(swingHigh, "#.##"),
                  color=color.new(#EF5350, 75), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
    
    if not na(swingLow)
        label.new(bar_index[rightBars], swingLow,
                  text="🟢 Low\n" + str.tostring(swingLow, "#.##"),
                  color=color.new(#66BB6A, 75), textcolor=color.white,
                  style=label.style_label_up, size=size.small)
````
