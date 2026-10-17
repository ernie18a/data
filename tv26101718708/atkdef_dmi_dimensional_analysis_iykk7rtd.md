# ATK/DEF  DMI  Dimensional Analysis

- url: https://www.tradingview.com/script/IYKk7rTd/
- type: indicator
- pine_id: PUB;01e30354d2854858a04bb1ecc0a5e7ab
- version: 1.0

## Description

📊 ATK/DEF DMI Dimensional Analysis 

DMI Dimensional Analysis is a multi-dimensional market analysis tool built around the Directional Movement Index (DMI) framework.

Unlike traditional DMI displays that mainly show ADX, +DI, and -DI values separately, this indicator reorganizes directional movement data into several analytical dimensions to provide a clearer view of market structure, directional strength, momentum condition, and internal balance.

The goal of this indicator is to visualize how directional forces develop and interact within the market environment, helping users observe changes in market dynamics through a structured analytical framework.

⚙️ Momentum Engine

The Momentum Engine represents the current relationship between positive and negative directional movement.

By comparing +DI and -DI behavior, the indicator displays the current directional dominance state and helps visualize the balance between bullish and bearish pressure.

This component focuses on the internal direction of market movement rather than isolated indicator values.

⚡ Momentum Speed

Momentum Speed evaluates the intensity level of directional activity using ADX-based measurements.

The indicator categorizes directional strength into multiple levels, allowing users to observe whether market movement is developing with stronger momentum or remaining in a lower-energy condition.

This provides a simplified view of market activity intensity.

💪 Momentum Power

Momentum Power analyzes the relationship between +DI and -DI differences.

It measures the relative strength between opposing directional forces and displays whether the current movement environment has stronger positive or negative directional influence.

This dimension focuses on directional force comparison.

📈 Momentum Market Index

The Momentum Market Index combines ADX strength and directional separation into a normalized analytical value.

This index provides a broader perspective of the current market environment by evaluating:

• Trend strength
• Directional separation
• Movement participation

The purpose is to represent overall market condition through a single dimensional measurement.

📡 DMI Radar

The DMI Radar combines multiple internal DMI components into a unified analytical layer.

The radar structure considers:

• ADX trend strength
• Directional difference
• Momentum behavior
• Balance condition
• Directional transition state

Instead of focusing on one individual calculation, the radar provides a broader visualization of DMI characteristics.

⚖️ Balance Index

The Balance Index measures the relationship between positive and negative directional forces.

It helps visualize whether the market is experiencing:

• Balanced directional conditions
• Moderate directional imbalance
• Strong directional imbalance

This dimension is designed to display the internal equbrium of market movement.

🔴🟢 Swing Point Integration

The indicator integrates S High and S Low identification with DMI dimensional information.

Each detected swing point can display additional contextual information, including:

• Momentum Speed
• Momentum Power
• Market Index condition

This allows users to examine histor swing structures together with directional movement characteristics.

📊 Analytical Table

The integrated dashboard provides a compact overview of the current DMI environment:

• Momentum Engine
• Momentum Speed
• Momentum Power
• Momentum Market
• Balance Index
• DMI Radar
• ADX / +DI / -DI reference values

The table is designed to organize multiple DMI dimensions into a clear visual format.

Concept

Traditional DMI analysis usually focuses on individual lines such as ADX, +DI, and -DI.

This indicator takes a different approach by transforming DMI information into a dimensional analysis framework.

It does not attempt to replace the original DMI calculation. Instead, it provides a structured visualization method to stu directional behavior, market rhy, and internal force relationships.

The indicator is designed for users who want to explore market direction characteristics through a multi-layer DMI perspective.

Disclaimer

This indicator is created for market analysis and visualization purposes only.
It does not provide finan advice, tra recommendations, or guar market outcomes.

## Source Code

````pine
//@version=6
indicator(" DMI  Dimensional Analysis", overlay=true, max_lines_count=300, max_labels_count=300)

// ============================================
// 1. Input Parameters
// ============================================
leftBars = input.int(5, "Left Bars", minval=1, tooltip="Number of bars to the left of pivot point")
rightBars = input.int(5, "Right Bars", minval=1, tooltip="Number of bars to the right of pivot point")
showLabels = input.bool(true, "Show Pivot Labels")
showDMIInfo = input.bool(true, "Show DMI Analysis in Labels", tooltip="Display momentum speed, power and market index in swing labels")
showTable = input.bool(true, "Show Analysis Table", group="Display Settings")
tablePosition = input.string("Right", "Table Position", options=["Right", "Left"], group="Display Settings")
maxLabels = input.int(300, "Max Labels", minval=10, maxval=300, group="Management Settings")
maxLines = input.int(300, "Max Lines", minval=10, maxval=300, group="Management Settings")
maxBars = input.int(1000, "Max Bars", minval=100, maxval=1000, group="Management Settings")

// ============================================
// 2. DMI Calculation
// ============================================
adxLen = input.int(14, "ADX Period", minval=1, maxval=100)
[adx, plusDI, minusDI] = ta.dmi(adxLen, adxLen)

// ============================================
// 3. DMI Derived Indicators
// ============================================

// 3.1 Momentum Speed (Level 1-5)
dmiSpeed = adx > 40 ? 5 :
           adx > 30 ? 4 :
           adx > 20 ? 3 :
           adx > 15 ? 2 : 1

speedLabel = dmiSpeed == 5 ? "🔥🔥🔥 Extreme" :
             dmiSpeed == 4 ? "🔥🔥 Fast" :
             dmiSpeed == 3 ? "🔥 Moderate" :
             dmiSpeed == 2 ? "💨 Slow" : "💤 Stagnant"

// 3.2 Momentum Power (Bull/Bear)
dmiPower = plusDI > minusDI ? "🐂 Bull" : "🐻 Bear"

powerStrength = plusDI > minusDI ? (plusDI - minusDI > 20 ? "Strong" : plusDI - minusDI > 10 ? "Moderate" : "Weak") :(minusDI - plusDI > 20 ? "Strong" : minusDI - plusDI > 10 ? "Moderate" : "Weak")

// 3.3 Momentum Market (Index)
marketIndex = (adx / 50 * 40) + (math.abs(plusDI - minusDI) / 100 * 60)
marketIndex := math.min(math.max(marketIndex, 0), 100)

marketRating = marketIndex > 70 ? "📊 Strong Trend Market" :
               marketIndex > 50 ? "📊 Trend Market" :
               marketIndex > 30 ? "📊 Range Market" : "📊 Weak Market"

// ============================================
// 4. DMI Radar
// ============================================
diDiff = plusDI - minusDI
diDiffAbs = math.abs(diDiff)
flowBehaviorSmooth = ta.sma(plusDI - minusDI, 3)

// Crossover signals
plusCrossOverMinus = ta.crossover(plusDI, minusDI)
minusCrossOverPlus = ta.crossunder(plusDI, minusDI)

var int crossSignal = 0
if plusCrossOverMinus
    crossSignal := 1
if minusCrossOverPlus
    crossSignal := -1

// Balance Index
balanceRatio = plusDI / (plusDI + minusDI) * 100
balanceIndex = 50 - (balanceRatio - 50)
balanceIndex := math.abs(balanceIndex) * 2

// Radar components
radarTrend = (adx / 50) * 25
radarTrend := math.min(radarTrend, 25)

radarDirection = (diDiffAbs / 100) * 25
radarDirection := math.min(radarDirection, 25)

radarMomentum = (math.abs(flowBehaviorSmooth) / 5) * 20
radarMomentum := math.min(radarMomentum, 20)

radarBalance = (50 - math.abs(balanceIndex - 50)) / 50 * 15
radarBalance := math.max(radarBalance, 0)

radarCross = crossSignal == 1 ? 15 : crossSignal == -1 ? 5 : 10

radarScore = radarTrend + radarDirection + radarMomentum + radarBalance + radarCross
radarScore := math.min(math.max(radarScore, 0), 100)

radarSignal = radarScore > 70 ? "🚨 Strong Signal" :
              radarScore > 50 ? "📢 Moderate Signal" :
              "💤 Weak Signal"

// ============================================
// 5. Swing High/Low Detection
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 6. Label Management (Max 300, delete oldest if exceeded)
// ============================================
var label[] highLabels = array.new_label()
var label[] lowLabels = array.new_label()

manageLabels(labelArray) =>
    while array.size(labelArray) >= maxLabels
        oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// ============================================
// 7. Line Management (Max 300, delete oldest if exceeded)
// ============================================
var line[] trendLines = array.new_line()

manageLines(lineArray) =>
    while array.size(lineArray) >= maxLines
        oldLine = array.shift(lineArray)
        line.delete(oldLine)

// ============================================
// 8. Bar Management (Max 1000, clear if exceeded)
// ============================================
var int barCounter = 0

if barstate.isnew
    barCounter := barCounter + 1
    if barCounter > maxBars
        barCounter := 0
        if array.size(highLabels) > maxLabels * 0.7
            while array.size(highLabels) > maxLabels * 0.5
                oldLabel = array.shift(highLabels)
                label.delete(oldLabel)
        if array.size(lowLabels) > maxLabels * 0.7
            while array.size(lowLabels) > maxLabels * 0.5
                oldLabel = array.shift(lowLabels)
                label.delete(oldLabel)
        if array.size(trendLines) > maxLines * 0.7
            while array.size(trendLines) > maxLines * 0.5
                oldLine = array.shift(trendLines)
                line.delete(oldLine)

// ============================================
// 9. Swing Point Labels (With DMI Analysis)
// ============================================
if showLabels
    if not na(swingHigh)
        labelText = "🔴 High\n" + str.tostring(swingHigh, "#.##")
        if showDMIInfo
            labelText := labelText + "\n⚡Speed: " + speedLabel + " (" + str.tostring(dmiSpeed) + "/5)" + "\n💪Power: " + dmiPower + " " + powerStrength + "\n📈Market: " + marketRating + " (" + str.tostring(marketIndex, "#.0") + "%)"
        
        newLabel = label.new(bar_index[rightBars], swingHigh,
                  text=labelText,
                  color=color.rgb(208, 36, 202, 4), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
        array.push(highLabels, newLabel)
        manageLabels(highLabels)
    
    if not na(swingLow)
        labelText = "🟢 Low\n" + str.tostring(swingLow, "#.##")
        if showDMIInfo
            labelText := labelText + "\n⚡Speed: " + speedLabel + " (" + str.tostring(dmiSpeed) + "/5)" + "\n💪Power: " + dmiPower + " " + powerStrength + "\n📈Market: " + marketRating + " (" + str.tostring(marketIndex, "#.0") + "%)"
        
        newLabel = label.new(bar_index[rightBars], swingLow,
                  text=labelText,
                  color=color.rgb(37, 187, 37), textcolor=color.white,
                  style=label.style_label_up, size=size.small)
        array.push(lowLabels, newLabel)
        manageLabels(lowLabels)

// ============================================
// 10. Status Line Display
// ============================================
plot(adx, "ADX", display=display.status_line, color=color.yellow)
plot(plusDI, "+DI", display=display.status_line, color=color.green)
plot(minusDI, "-DI", display=display.status_line, color=color.red)

// ============================================
// 11. Right Side Table (Red & White Background)
// ============================================
if showTable
    tablePos = tablePosition == "Right" ? position.top_right : position.top_left
    
    var table dmiTable = table.new(tablePos, 2, 8, 
                                   bgcolor=color.rgb(250, 250, 250, 10),
                                   border_color=color.rgb(255, 200, 200, 80),
                                   border_width=1, frame_width=1)
    
    // Header - Red background, Gold text
    table.cell(dmiTable, 0, 0, "📊ATK/DEF DMI Dimensional Analysis", 
               text_color=color.rgb(245, 244, 243),
               text_size=size.normal,
               bgcolor=color.rgb(208, 52, 153))
    table.merge_cells(dmiTable, 0, 0, 1, 0)
    
    // Row 1: Momentum Engine - White background
    engineStatus = diDiff > 2 ? "🟢 Bull Engine" :
                   diDiff < -2 ? "🔴 Bear Engine" :
                   "🟡 Engine Idle"
    engineColor = diDiff > 2 ? color.rgb(0, 200, 0) :
                  diDiff < -2 ? color.rgb(200, 0, 0) :
                  color.rgb(200, 200, 0)
    table.cell(dmiTable, 0, 1, "⚙️ Momentum Engine", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(dmiTable, 1, 1, engineStatus, 
               text_color=engineColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 2: Momentum Speed - Light Red background
    speedColor = dmiSpeed >= 4 ? color.rgb(0, 200, 0) :
                 dmiSpeed >= 3 ? color.rgb(200, 200, 0) :
                 color.rgb(200, 0, 0)
    table.cell(dmiTable, 0, 2, "⚡ Momentum Speed", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(dmiTable, 1, 2, speedLabel + " (" + str.tostring(dmiSpeed) + "/5)", 
               text_color=speedColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 3: Momentum Power - White background
    powerColor = plusDI > minusDI ? color.rgb(0, 200, 0) : color.rgb(200, 0, 0)
    table.cell(dmiTable, 0, 3, "💪 Momentum Power", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(dmiTable, 1, 3, dmiPower + " " + powerStrength, 
               text_color=powerColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 4: Momentum Market - Light Red background
    marketColor = marketIndex > 70 ? color.rgb(0, 200, 0) :
                  marketIndex > 50 ? color.rgb(200, 200, 0) :
                  color.rgb(200, 0, 0)
    table.cell(dmiTable, 0, 4, "📈 Momentum Market", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(dmiTable, 1, 4, marketRating + "\n" + str.tostring(marketIndex, "#.0") + "%", 
               text_color=marketColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 5: Balance Index - White background
    balanceColor = balanceIndex < 20 ? color.rgb(0, 200, 0) :
                   balanceIndex < 40 ? color.rgb(200, 200, 0) :
                   color.rgb(200, 0, 0)
    balanceStatus = balanceIndex < 20 ? "⚖️ Highly Balanced" : balanceIndex < 40 ? "🔶 Mildly Imbalanced" : "🔴 Severely Imbalanced"
    table.cell(dmiTable, 0, 5, "⚖️ Balance Index", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(dmiTable, 1, 5, balanceStatus + "\n" + str.tostring(balanceIndex, "#.0") + "%", 
               text_color=balanceColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 6: DMI Radar - Light Red background
    radarColor = radarScore > 70 ? color.rgb(0, 200, 0) :
                 radarScore > 50 ? color.rgb(200, 200, 0) :
                 color.rgb(200, 0, 0)
    table.cell(dmiTable, 0, 6, "📡 DMI Radar", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(dmiTable, 1, 6, radarSignal + "\n" + str.tostring(radarScore, "#.0") + "%", 
               text_color=radarColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 7: ADX Reference - White background
    adxColor = adx > 25 ? color.rgb(0, 200, 0) :
               adx > 20 ? color.rgb(200, 200, 0) :
               color.rgb(200, 0, 0)
    table.cell(dmiTable, 0, 7, "📊 ADX Reference", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(dmiTable, 1, 7, "ADX: " + str.tostring(adx, "#.1") + 
               "\n+DI: " + str.tostring(plusDI, "#.1") + 
               "\n-DI: " + str.tostring(minusDI, "#.1"), 
               text_color=adxColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
````
