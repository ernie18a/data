# ATK/DEF Imbalance Power Liquidity Analysis Engine

- url: https://www.tradingview.com/script/p6tHcBFD/
- type: indicator
- pine_id: PUB;528d68c279af4a369188de72d1ef1038
- version: 1.0

## Description

ATK/DEF Imbalance Power Liq Analysis Engine is a market behavior analysis framework designed to evaluate swing high and swing low through the relationship between balance fl and imbalance powr. 

Unlike traditional high and low point identification methods that mainly focus on pric location or histor turning areas, this indicator focuses on analyzing the internal strength characteristics behind pric movements by measuring the interaction between balanced conditions and directional imbalance.

The core concept of this framework is based on evaluating how pric behavior develops when bu and se pressure become balanced or imbalanced. By stu the intensity, deviation, and persistenc of these conditions, the indicator provides additional analytical information about the quality and behavioral characteristics of detec swing structures.

The engine combines several analytical components to evaluate high and low point behavior:

1. Balance and Imbalance Flo Analysis

The Balance Flo modu evaluates the relationship between positive and negative pric pressure using candle structure and pric movement characteristics.

This component measures the degree of directional imbalance and identifies whether market activity is showing stronger one-sided pressure or a more balanced condition.

The objecti is not to classify market direction, but to evaluate the internal strength distribution around pric struc.

2. Imbalance Power Measurement

The Imbalance Power modu measures the intensity of pressure differences between opposing forc.

By analyzing the magnitu of imbalance, the framework evaluates whether a swing high or swing low develod under strong pressure conditions or weaker participation conditions.

This provides a quantitative reference for comparing different structur points based on their internal behavioral characteristics.

3. Flo Strength Behavior Analysis

The Flo Behavior component studie changes in balance strength over time.

It evaluates whether flo conditions are increasing, decreasing, stabilizing, or shifting between different states.

This allows users to observe how pressure behavior changes around histor swing areas without relying only on pric leve.

4. Market Weight Capacity Evaluation

The Market Weight modu compares current imbalance strength against recent histor conditions.

This measurement provides context regarding the relative intensity of current flo behavior and helps distingu stronger and weaker activity environments.

5. Multi-Timeframe Imbalance Relationship

The framework evaluates short, medium, and longer fl conditions to display the relationship between different imbalance states.

This component provides additional context regarding whether different calculation periods show similar or conflicting pressure characteristics.

6. Swing High and Swing Low Behavioral Analysis

The indicator integrates imbalance and balance measurements directly with detected swing high and swing low structures.

Each structural point can display related flo information, including:
• Balance flo condition
• Imbalance strength level
• Flo behavior status
• Pressure change characteristics
• Structural activity reference

This approach focuses on stud the effectiveness and behavioral quality of high and low points rather than simply marking histor pric extremes.

Key Features:

• Balance and imbalance flo evaluation
• Swing high and swing low behavior analysis
• Candle-based pressure measurement
• Imbalance strength classification
• Flo behavior monitoring
• Market weight comparison
• Multi-period imbalance relationship analysis
• Structural point information display
• Analytical dashboard with calcu measurements
• Quantitative evaluation of pric behavior characteristics

ATK/DEF Imbalance Power Liq Analysis Engine is designed as a technical analysis rese tool for stu the relationship between pric structures, internal pressure distribution, and changing market behavior.

The displayed values represent calcu analytical measurements derived from histor price data. The framework is intended to provide additional context for stud market structure and liquidity behavior rather than providing tra instructions or directional decisions.

## Source Code

````pine
//@version=6
indicator("ATK/DEF Imbalance Power Liquidity Analysis Engine", overlay=true, max_lines_count=300, max_labels_count=300)

// ============================================
// 1. Input Parameters
// ============================================
leftBars = input.int(5, "Left Bars", minval=1, tooltip="Number of bars to the left of pivot point")
rightBars = input.int(5, "Right Bars", minval=1, tooltip="Number of bars to the right of pivot point")
showLabels = input.bool(true, "Show Pivot Labels")
showBOPInfo = input.bool(true, "Show BOP Analysis in Labels", tooltip="Display BOP balance flow, strength behavior, and turning trend in swing labels")
showBOPTable = input.bool(true, "Show BOP Analysis Table", group="Display Settings")
tablePosition = input.string("Right", "Table Position", options=["Right", "Left"], group="Display Settings")
bopLength = input.int(5, "BOP Smoothing Period", minval=1, maxval=20)

// ============================================
// 2. BOP Core Calculation
// ============================================
priceRange = high - low
priceRange := priceRange == 0 ? 0.0001 : priceRange
bopRaw = (close - open) / priceRange
bop = ta.sma(bopRaw, bopLength)
bopAbs = math.abs(bop)

// ============================================
// 3. BOP Balance Flow Value
// ============================================
bopFlowValue = bopAbs * 100
bopFlowValue := math.min(bopFlowValue, 100)

bopFlowDirection = bop > 0.01 ? 1 : bop < -0.01 ? -1 : 0
bopFlowSigned = bopFlowValue * bopFlowDirection

flowLevel = bopFlowValue > 70 ? "🔥🔥🔥 Bull Strong Flow" : bopFlowValue > 50 ? "🔥🔥 Bull Mid Flow" : bopFlowValue > 30 ? "🔥 Bull Weak Flow" : bopFlowValue > 15 ? "🌊 Micro Flow" : "💤 No Flow"

if bopFlowDirection < 0
    flowLevel := bopFlowValue > 70 ? "💨💨💨 Bear Strong Flow" :
                 bopFlowValue > 50 ? "💨💨 Bear Mid Flow" :
                 bopFlowValue > 30 ? "💨 Bear Weak Flow" :
                 bopFlowValue > 15 ? "🌊 Micro Flow" :
                 "💤 No Flow"
if bopFlowDirection == 0
    flowLevel := "⚖️ Balanced"

// ============================================
// 4. BOP Balance Strength Behavior
// ============================================
bopSMA = ta.sma(bop, 10)
bopStrength = (bop - bopSMA) / (bopSMA + 0.0001) * 100
bopStrength := math.min(math.max(bopStrength, -100), 100)

strengthBehavior = bopStrength > 30 ? "🔥 Strong Increasing" :
                   bopStrength > 15 ? "📈 Slow Increasing" :
                   bopStrength > -15 ? "⚖️ Sideways Consolidation" :
                   bopStrength > -30 ? "📉 Slow Decreasing" :
                   "💧 Strong Decreasing"

// ============================================
// 5. BOP Balance Turning Trend
// ============================================
bopSlope = ta.change(bop, 5)
bopMomentum = ta.change(bop, 3)
bopAcceleration = ta.change(bopMomentum, 3)

bopSlopeThreshold = 0.005
bopMomentumThreshold = 0.005

turningScore = 0.0

if (bop > 0.01 and bopMomentum < -bopMomentumThreshold)
    turningScore := turningScore + 30
if (bop > 0.01 and bopAcceleration < -0.005)
    turningScore := turningScore + 20

if (bop < -0.01 and bopMomentum > bopMomentumThreshold)
    turningScore := turningScore + 30
if (bop < -0.01 and bopAcceleration > 0.005)
    turningScore := turningScore + 20

if (bop > 0.01 and bopSlope < -bopSlopeThreshold)
    turningScore := turningScore + 25
if (bop < -0.01 and bopSlope > bopSlopeThreshold)
    turningScore := turningScore + 25

if (bopAbs > 0.5)
    turningScore := turningScore + 15

if (bopAbs > 0.2 and bopMomentum < 0.005 and bopMomentum > -0.005)
    turningScore := turningScore + 10

if (bop > 0 and bop[1] < 0) or (bop < 0 and bop[1] > 0)
    turningScore := turningScore + 15

turningScore := math.min(turningScore, 100)

turningTrend = turningScore > 70 ? "🔴 Strong Reversal" :
               turningScore > 45 ? "🟡 Potential Reversal" :
               turningScore > 20 ? "🟢 Watch Reversal" :
               "⚪ Trend Continuation"

turningColor = turningScore > 70 ? color.rgb(255, 0, 0) :
               turningScore > 45 ? color.rgb(255, 165, 0) :
               turningScore > 20 ? color.rgb(255, 200, 0) :
               color.rgb(150, 150, 150)

// ============================================
// 6. Right Side Table - BOP Balance Analysis
// ============================================

// 6.1 BOP Balance Level Value
balanceLevelValue = bop

// 6.2 BOP Balance Property Grade
balanceGrade = bopAbs > 0.6 ? "Grade A Extreme Imbalance" :
               bopAbs > 0.4 ? "Grade B Moderate Imbalance" :
               bopAbs > 0.2 ? "Grade C Mild Imbalance" :
               "Grade D Balanced State"

gradeColor = bopAbs > 0.6 ? color.rgb(255, 0, 0) :
             bopAbs > 0.4 ? color.rgb(255, 165, 0) :
             bopAbs > 0.2 ? color.rgb(255, 255, 0) :
             color.rgb(0, 200, 255)

// 6.3 BOP Balance Slippage Gap
bopMA20 = ta.sma(bop, 20)
slippageGap = (bop - bopMA20) / (bopMA20 + 0.0001) * 100
slippageGap := math.min(math.max(slippageGap, -100), 100)

gapLevel = slippageGap > 30 ? "🔥 Large Deviation" :
           slippageGap > 15 ? "📈 Moderate Deviation" :
           slippageGap > -15 ? "⚖️ Normal Range" :
           slippageGap > -30 ? "📉 Moderate Deviation" :
           "💧 Large Deviation"

gapColor = slippageGap > 30 ? color.rgb(255, 0, 0) :
           slippageGap > 15 ? color.rgb(255, 165, 0) :
           slippageGap > -15 ? color.rgb(150, 150, 150) :
           slippageGap > -30 ? color.rgb(0, 200, 255) :
           color.rgb(0, 0, 255)

// 6.4 BOP Balance Market Weight Capacity
bopMaxWeight = ta.highest(bopAbs, 50) + 0.0001
marketWeight = bopAbs / bopMaxWeight * 100
marketWeight := math.min(marketWeight, 100)

weightLevel = marketWeight > 80 ? "🔥🔥🔥 Extremely High Weight" :
              marketWeight > 60 ? "🔥🔥 High Weight" :
              marketWeight > 40 ? "🔥 Medium Weight" :
              marketWeight > 20 ? "💨 Low Weight" :
              "💤 Extremely Low Weight"

weightColor = marketWeight > 80 ? color.rgb(255, 0, 0) :
              marketWeight > 60 ? color.rgb(255, 165, 0) :
              marketWeight > 40 ? color.rgb(255, 200, 0) :
              marketWeight > 20 ? color.rgb(0, 200, 255) :
              color.rgb(150, 150, 150)

// 6.5 BOP Balance Level Ratio
bopMin = ta.lowest(bop, 100)
bopMax = ta.highest(bop, 100)
bopRange = bopMax - bopMin
bopRange := bopRange == 0 ? 0.0001 : bopRange
levelRatio = (bop - bopMin) / bopRange * 100
levelRatio := math.min(math.max(levelRatio, 0), 100)

ratioLevel = levelRatio > 80 ? "🔴 High Zone" :
             levelRatio > 60 ? "🟠 Mid-High Zone" :
             levelRatio > 40 ? "🟡 Mid Zone" :
             levelRatio > 20 ? "🟢 Mid-Low Zone" :
             "🔵 Low Zone"

ratioColor = levelRatio > 80 ? color.rgb(255, 0, 0) :
             levelRatio > 60 ? color.rgb(255, 165, 0) :
             levelRatio > 40 ? color.rgb(255, 200, 0) :
             levelRatio > 20 ? color.rgb(0, 200, 0) :
             color.rgb(0, 150, 255)

// 6.6 Timeframe Imbalance Trend
bopShort = ta.sma(bopRaw, 3)
bopMedium = ta.sma(bopRaw, 10)
bopLong = ta.sma(bopRaw, 20)

shortDir = bopShort > 0 ? 1 : -1
mediumDir = bopMedium > 0 ? 1 : -1
longDir = bopLong > 0 ? 1 : -1
consistency = shortDir + mediumDir + longDir

imbalanceTrend = consistency == 3 ? "🔥 Bull Resonance" :
                 consistency == 2 ? "📈 Bull Dominant" :
                 consistency == 1 ? "🟡 Bull Emerging" :
                 consistency == -1 ? "🟡 Bear Emerging" :
                 consistency == -2 ? "📉 Bear Dominant" :
                 consistency == -3 ? "💧 Bear Resonance" :
                 "⚖️ Bull/Bear Divergence"

trendColor = consistency == 3 ? color.rgb(255, 0, 0) :
             consistency == 2 ? color.rgb(255, 165, 0) :
             consistency == 1 ? color.rgb(255, 200, 0) :
             consistency == -1 ? color.rgb(0, 200, 255) :
             consistency == -2 ? color.rgb(0, 100, 255) :
             consistency == -3 ? color.rgb(0, 0, 255) :
             color.rgb(150, 150, 150)

// 6.7 BOP Value
bopValue = bop

// ============================================
// 7. Label Management (Max 300)
// ============================================
var label[] highLabels = array.new_label()
var label[] lowLabels = array.new_label()

manageLabels(labelArray) =>
    while array.size(labelArray) >= 300
        oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// ============================================
// 8. Detect Swing Highs & Lows
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 9. Swing Point Labels (Includes BOP Analysis, No Separator)
// ============================================
if showLabels
    if not na(swingHigh)
        labelText = "🔴 High\n" + str.tostring(swingHigh, "#.##")
        if showBOPInfo
            labelText := labelText +  "\n🌊 Flow: " + flowLevel + " (" + str.tostring(bopFlowValue, "#.0") + "%)" +  "\n⚡ Behavior: " + strengthBehavior + "\n🔄 Turning: " + turningTrend + " (" + str.tostring(turningScore, "#.0") + "pts)"
        
        newLabel = label.new(bar_index[rightBars], swingHigh,
                  text=labelText,
                  color=color.rgb(227,44,158, 0), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
        array.push(highLabels, newLabel)
        manageLabels(highLabels)
    
    if not na(swingLow)
        labelText = "🟢 Low\n" + str.tostring(swingLow, "#.##")
        if showBOPInfo
            labelText := labelText +  "\n🌊 Flow: " + flowLevel + " (" + str.tostring(bopFlowValue, "#.0") + "%)" +  "\n⚡ Behavior: " + strengthBehavior +  "\n🔄 Turning: " + turningTrend + " (" + str.tostring(turningScore, "#.0") + "pts)"
        
        newLabel = label.new(bar_index[rightBars], swingLow,
                  text=labelText,
                  color=color.rgb(44,187,44, 0), textcolor=color.white,
                  style=label.style_label_up, size=size.small)
        array.push(lowLabels, newLabel)
        manageLabels(lowLabels)

// ============================================
// 10. Status Line Display
// ============================================
plot(bop, "BOP", display=display.status_line, color=color.orange)

// ============================================
// 11. Right Side Table (BOP Balance Analysis)
// ============================================
if showBOPTable
    tablePos = tablePosition == "Right" ? position.top_right : position.top_left
    
    var table bopTable = table.new(tablePos, 2, 8, 
                                   bgcolor=color.rgb(255, 255, 255),
                                   border_color=color.rgb(200, 200, 255, 80),
                                   border_width=1, frame_width=1)
    
    // Header - Row 0 (Pink Header)
    table.cell(bopTable, 0, 0, "⚖️ ATK/DEF Imbalance Power Liquidity Analysis Engine", 
               text_color=color.rgb(255, 255, 255),
               text_size=size.normal,
               bgcolor=color.rgb(218, 52, 199))
    table.merge_cells(bopTable, 0, 0, 1, 0)
    
    // Row 1: BOP Balance Level Value - White Background
    bopColor = bop > 0 ? color.rgb(0, 200, 0) :
               bop < 0 ? color.rgb(200, 0, 0) :
               color.rgb(150, 150, 150)
    table.cell(bopTable, 0, 1, "📊 Balance Level", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(bopTable, 1, 1, str.tostring(bop, "#.000"), 
               text_color=bopColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 2: BOP Balance Property Grade - Light Red Background
    table.cell(bopTable, 0, 2, "🏷️ Balance Grade", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(bopTable, 1, 2, balanceGrade, 
               text_color=gradeColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 3: BOP Balance Slippage Gap - White Background
    table.cell(bopTable, 0, 3, "🎯 Slippage Gap", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(bopTable, 1, 3, gapLevel + "\n" + str.tostring(slippageGap, "#.0") + "%", 
               text_color=gapColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 4: BOP Balance Market Weight Capacity - Light Red Background
    table.cell(bopTable, 0, 4, "⚡ Market Weight", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(bopTable, 1, 4, weightLevel + "\n" + str.tostring(marketWeight, "#.0") + "%", 
               text_color=weightColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 5: BOP Balance Level Ratio - White Background
    table.cell(bopTable, 0, 5, "📈 Level Ratio", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(bopTable, 1, 5, ratioLevel + "\n" + str.tostring(levelRatio, "#.0") + "%", 
               text_color=ratioColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 6: Timeframe Imbalance Trend - Light Red Background
    table.cell(bopTable, 0, 6, "🔄 Imbalance Trend", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(bopTable, 1, 6, imbalanceTrend, 
               text_color=trendColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 7: BOP Value - White Background
    table.cell(bopTable, 0, 7, "📊 BOP Value", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(bopTable, 1, 7, str.tostring(bop, "#.000") + "\n" + str.tostring(bopAbs * 100, "#.0") + "% Strength", 
               text_color=bopColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
````
