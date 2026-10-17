# ATK/DEF MOM Momentum Motor Analysis

- url: https://www.tradingview.com/script/XwVPaZWJ/
- type: indicator
- pine_id: PUB;0e81084c9cd04446ab601ad6a07f95b0
- version: 1.0

## Description

ATK/DEF MOM Momentum Motor Analysis

ATK/DEF MOM Momentum Motor Analysis is a swing structure evaluation framework that combines momentum measurement with a multi-layer motor analysis model to examine the internal strength, speed, and condition of price movement around swing h and swing l.

Unlike traditional swing point indicators that only mark histo high and low locations, this indicator focuses on evaluating the momentum characteristics behind each detec swing structure.

The purpose of this framework is to analyze how momentum behaves around important price points by using momentum acceleration, velocity, strength, balance, and radar-based measurements to provide a deeper view of swing point conditions.

The system combines Swing H / Swing L detec with a Momentum Motor framework, creating a multi-dimel evaluation environment for stu histori price behavior.

Momentum Motor Framework

The Momentum Motor system is built around multiple momentum-based calcu designed to measure different characteristics of price movement.

The framework evaluates:

• Momentum direction
• Momentum strength
• Momentum acceleration
• Momentum speed
• Momentum stage condition
• Momentum balance
• Momentum activity intensity

These measurements are combined into a structured analysis model to describe the current state of momentum behavior.

The Motor concept represents the continuous evaluation process of momentum conditions, similar to monitoring the operating condition of a system by observing speed, power, and performance characteristics.

1. Momentum Engine Analysis

The Momentum Engine evaluates the relationship between basic momentum and momentum acceleration.

This module analyzes whether momentum activity is increasing, decreasing, or maintaining its current condition by examining:

• Momentum value changes
• Acceleration characteristics
• Momentum smoothing behavior
• Engine state variation

The purpose of this component is to describe the internal momentum condition beh price movement rather than simply measuring price direction.

2. Momentum Speed Rating Motor

The Speed Rating Motor evaluates the velocity of momentum changes.

This module measures how quickly momentum conditions are changing compared with recent momentum activity.

The evaluation includes:

• Momentum velocity
• Speed intensity
• Relative momentum acceleration
• Current activity level comparison

The rating framework categorizes momentum speed conditions into different grades to represent changes in market activity intensity.

This allo uss to stu whether a swing point developed during a high-activity momentum environment or a slower momentum condition.

3. Momentum Power Motor

The Power Motor evaluates the strength characteristics of positive and negative momentum.

This component analyzes:

• Momentum expansion
• Momentum weakening conditions
• Acceleration support
• Momentum pressure difference

The purpose is to provide additional context regarding the strength behind a swing h or swing l.

It does not classify future outcomes. Instead, it displays calculated momentum characteristics based on histori price da.

4. Momentum Market Stage Analysis

The Market Stage module evaluates momentum development conditions through the relationship between momentum values, smoothing measurements, and momentum changes.

The framework identifies different momentum states such as:

• Early momentum development
• Middle momentum expansion
• Late momentum condition
• Neutral / range condition

This provides a structural view of where momentum activity is currently positioned within the analyzed period.

5. Momentum Radar Evaluation

The Momentum Radar combines multiple momentum measurements into a unif analytical score.

The radar calculation considers:

• Momentum magnitude
• Momentum acceleration
• Momentum relationship with average momentum
• Momentum speed

The radar value represents the combined strength of measured momentum characteristics.

It is designed as a reference measurement for stu momentum conditions ac different swing structures.

6. Momentum Balance Analysis

The Balance Ind evaluates the relative relationship between positive and negative momentum forces.

This module studies:

• Bull momentum contribution
• Bear momentum contribution
• Momentum imbalance level
• Dominant momentum condition

The objective is to visualize the balan state of momentum activity rather than provide directional instru.

Swing High / Low Momentum Evaluation

Each detected Swing H and Swing L point is analyzed through the Momentum Motor framework.

Instead of treating all swing points equa, the indicator attaches momentum information to each structural point, including:

• Momentum speed rating
• Momentum power condition
• Momentum stage
• Motor operating status

This creates a momentum profile for histor swing structures.

A swing h or swing l is therefore viewed not only as a pric location, but also as a point containing momentum behavior information.

Key Features

• Swing High / Swing Low structural identification
• Momentum-based swing point evaluation
• Multi-layer Momentum Motor framework
• Momentum acceleration analysis
• Momentum speed rating system
• Momentum power evaluation
• Market stage analysis
• Momentum radar calculation
• Momentum balance measurement
• Analytical dashboard display
• Historical momentum condition labeling

Methodology

ATK/DEF MOM Momentum Motor Analysis combines swing structure analysis with quantitative momentum measurements to stu the relationship between pric movement and momentum behavior.

The framework focuses on analyzing the characteristics of momentum around histor price structures rather than relying on simple high/low marking.

All calcula are derived from histor price data and momentum measurements.

The displayed information is intended for technical analysis, market resear, and stu momentum behavior.

This indicator does not provide tra instruct, entry recommen, or guaran market outcs.

## Source Code

````pine
//@version=6
indicator("ATK/DEF MOM Momentum Motor Analysis", overlay=true, max_lines_count=300, max_labels_count=300)

// ============================================
// 1. Input Parameters
// ============================================
leftBars = input.int(5, "Left Bars", minval=1, tooltip="Number of bars to the left of pivot point")
rightBars = input.int(5, "Right Bars", minval=1, tooltip="Number of bars to the right of pivot point")
showLabels = input.bool(true, "Show Pivot Labels")
showMOMTable = input.bool(true, "Show MOM Analysis Table", group="Display Settings")
showMotorInfo = input.bool(true, "Show Motor Info in Labels", group="Display Settings", tooltip="Show motor analysis in swing labels")
tablePosition = input.string("Right", "Table Position", options=["Right", "Left"], group="Display Settings")
momLength = input.int(10, "MOM Length", minval=1, maxval=100, tooltip="Momentum period")
maLength = input.int(20, "MA Length", minval=1, maxval=100, tooltip="MA period for trend")
maxBars = input.int(1000, "Max Bars", minval=100, maxval=1000, group="Management Settings")

// ============================================
// 2. MOM Momentum Calculation
// ============================================

// 2.1 Base Momentum (MOM)
mom = close - close[momLength]
momSmooth = ta.sma(mom, 5)

// 2.2 MOM Momentum Engine
momAcceleration = ta.change(mom, 3)
momEngine = mom + momAcceleration * 2
momEngineSmooth = ta.sma(momEngine, 5)

engineStatus = momEngineSmooth > 0 ? "🟢 Bull Engine" :
               momEngineSmooth < 0 ? "🔴 Bear Engine" :
               "🟡 Engine Idle"

// 2.3 MOM Momentum Speed
momVelocity = ta.change(mom, 2)
momSpeed = math.abs(momVelocity)

speedLevel = momSpeed > 50 ? 5 :
             momSpeed > 30 ? 4 :
             momSpeed > 15 ? 3 :
             momSpeed > 5 ? 2 : 1

speedLabel = speedLevel == 5 ? "🔥🔥🔥 Extreme" :
             speedLevel == 4 ? "🔥🔥 Fast" :
             speedLevel == 3 ? "🔥 Moderate" :
             speedLevel == 2 ? "💨 Slow" : "💤 Stagnant"

speedDirection = momVelocity > 0 ? "Accelerating" : "Decelerating"

// ============================================
// 3. Motor System
// ============================================

// 3.1 Momentum Speed Rating Motor Environment (Grade A, B, C, D)
absMomVelocity = math.abs(momVelocity)
maxVelocity = ta.highest(absMomVelocity, 50) + 0.0001
velocityRatio = absMomVelocity / maxVelocity * 100

motorSpeedGrade = velocityRatio > 70 ? "A" :
                  velocityRatio > 45 ? "B" :
                  velocityRatio > 20 ? "C" : "D"

motorSpeedLabel = motorSpeedGrade == "A" ? "🔥🔥🔥 Grade A Extreme" :
                  motorSpeedGrade == "B" ? "🔥🔥 Grade B Fast" :
                  motorSpeedGrade == "C" ? "🔥 Grade C Moderate" :
                  "💨 Grade D Slow"

// Speed grade color
motorSpeedColor = motorSpeedGrade == "A" ? color.rgb(255, 0, 0) :
                  motorSpeedGrade == "B" ? color.rgb(255, 165, 0) :
                  motorSpeedGrade == "C" ? color.rgb(255, 255, 0) :
                  color.rgb(100, 100, 255)

// 3.2 Momentum Power Motor (Bull, Bear)
motorPower = mom > 0 and momAcceleration > 0 ? "🐂 Bull Strong" :
             mom > 0 and momAcceleration <= 0 ? "🐂 Bull Weakening" :
             mom < 0 and momAcceleration < 0 ? "🐻 Bear Strong" :
             mom < 0 and momAcceleration >= 0 ? "🐻 Bear Weakening" :
             "⚪ Neutral"

motorDirection = mom > 0 ? "🐂 Bull" : mom < 0 ? "🐻 Bear" : "⚪ Neutral"
powerStrength = mom > 0 and momAcceleration > 0 ? "Strong" : mom > 0 and momAcceleration <= 0 ? "Weakening" : mom < 0 and momAcceleration < 0 ? "Strong" : mom < 0 and momAcceleration >= 0 ? "Weakening" : "Neutral"

// 3.3 Momentum Market Motor (Early, Mid, Late)
momTrendMA = ta.sma(mom, 20)
momTrendSlope = ta.change(momTrendMA, 5)

// Bull market stages
isEarlyStage = mom > 0 and momSmooth > 0 and momVelocity > 0 and momAcceleration > 0 and mom < momTrendMA * 1.2
isMidStage = mom > 0 and momSmooth > 0 and momVelocity > 0 and momAcceleration > 0 and mom >= momTrendMA * 1.2
isLateStage = mom > 0 and momVelocity < 0 and momAcceleration < 0

// Bear market stages
isBearEarly = mom < 0 and momSmooth < 0 and momVelocity < 0 and momAcceleration < 0 and mom > momTrendMA * 1.2
isBearMid = mom < 0 and momSmooth < 0 and momVelocity < 0 and momAcceleration < 0 and mom <= momTrendMA * 1.2
isBearLate = mom < 0 and momVelocity > 0 and momAcceleration > 0

marketStage = mom > 0 and isEarlyStage ? "Early 📈" :
              mom > 0 and isMidStage ? "Mid 📈" :
              mom > 0 and isLateStage ? "Late 📉" :
              mom < 0 and isBearEarly ? "Early 📉" :
              mom < 0 and isBearMid ? "Mid 📉" :
              mom < 0 and isBearLate ? "Late 📈" :
              "Range ⚪"

// Market stage color
stageColor = marketStage == "Early 📈" or marketStage == "Early 📉" ? color.rgb(0, 200, 255) :
             marketStage == "Mid 📈" or marketStage == "Mid 📉" ? color.rgb(0, 200, 0) :
             marketStage == "Late 📈" or marketStage == "Late 📉" ? color.rgb(255, 165, 0) :
             color.rgb(150, 150, 150)

// ============================================
// 4. MOM Momentum Trend
// ============================================
momMA = ta.sma(mom, maLength)
momTrend = mom > momMA ? "📈 Bullish" : "📉 Bearish"
momTrendStrength = math.abs(mom - momMA) / (momMA + 0.0001) * 100

trendLevel = momTrendStrength > 20 ? "Strong" :
             momTrendStrength > 10 ? "Moderate" :
             "Weak"

// ============================================
// 5. MOM Momentum Radar
// ============================================
score1 = math.min(math.abs(mom) / 50 * 30, 30)
score2 = math.min(math.abs(momAcceleration) / 20 * 25, 25)
score3 = (mom > 0 and mom > momMA) or (mom < 0 and mom < momMA) ? 25 : 10
score4 = math.min(momSpeed / 100 * 20, 20)

radarScore = score1 + score2 + score3 + score4
radarScore := math.min(math.max(radarScore, 0), 100)

radarSignal = radarScore > 70 ? "🚨 Strong" :
              radarScore > 50 ? "📢 Moderate" :
              "💤 Weak"

// ============================================
// 6. MOM Momentum Balance Index
// ============================================
bullMomentum = mom > 0 ? mom : 0
bearMomentum = mom < 0 ? math.abs(mom) : 0
totalMomentum = bullMomentum + bearMomentum

balanceIndex = totalMomentum > 0 ? (math.abs(bullMomentum - bearMomentum) / totalMomentum * 100) : 0
balanceIndex := math.min(balanceIndex, 100)

balanceStatus = balanceIndex < 20 ? "⚖️ Balanced" : balanceIndex < 40 ? "🔶 Mild Imbalance" : "🔴 Severe Imbalance"
powerComparison = bullMomentum > bearMomentum ? "Bull Dominant" : "Bear Dominant"

// ============================================
// 7. MOM Reference
// ============================================
momReference = mom > 0 ? "🟢 Positive" :
               mom < 0 ? "🔴 Negative" :
               "⚪ Neutral"

referenceStrength = math.abs(mom) > 30 ? "Strong" : math.abs(mom) > 15 ? "Moderate" : "Weak"

// ============================================
// 8. Detect Swing Highs & Lows
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 9. Label Management (Max 300)
// ============================================
var label[] highLabels = array.new_label()
var label[] lowLabels = array.new_label()

manageLabels(labelArray) =>
    while array.size(labelArray) >= 300
        oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// ============================================
// 10. Bar Management (Max 1000)
// ============================================
var int barCounter = 0

if barstate.isnew
    barCounter := barCounter + 1
    if barCounter > maxBars
        barCounter := 0
        if array.size(highLabels) > 210
            while array.size(highLabels) > 150
                oldLabel = array.shift(highLabels)
                label.delete(oldLabel)
        if array.size(lowLabels) > 210
            while array.size(lowLabels) > 150
                oldLabel = array.shift(lowLabels)
                label.delete(oldLabel)

// ============================================
// 11. Swing Point Labels (Motor Info Only, No Separator)
// ============================================
if showLabels
    if not na(swingHigh)
        labelText = "🔴 High\n" + str.tostring(swingHigh, "#.##")
        if showMotorInfo
            labelText := labelText + "\n🏎️ Rating: " + motorSpeedLabel + "\n💪 Power: " + motorPower + "\n📈 Stage: " + marketStage
        
        newLabel = label.new(bar_index[rightBars], swingHigh,
                  text=labelText,
                  color=color.rgb(237, 35, 163), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
        array.push(highLabels, newLabel)
        manageLabels(highLabels)
    
    if not na(swingLow)
        labelText = "🟢 Low\n" + str.tostring(swingLow, "#.##")
        if showMotorInfo
            labelText := labelText + "\n🏎️ Rating: " + motorSpeedLabel + "\n💪 Power: " + motorPower + "\n📈 Stage: " + marketStage
        
        newLabel = label.new(bar_index[rightBars], swingLow,
                  text=labelText,
                  color=color.rgb(25, 189, 25), textcolor=color.white,
                  style=label.style_label_up, size=size.small)
        array.push(lowLabels, newLabel)
        manageLabels(lowLabels)

// ============================================
// 12. Status Line Display
// ============================================
plot(mom, "MOM", display=display.status_line, color=color.purple)
plot(momSmooth, "MOM SMA", display=display.status_line, color=color.orange)
plot(momEngineSmooth, "MOM Engine", display=display.status_line, color=color.blue)

// ============================================
// 13. Right Side Table (MOM + Motor)
// ============================================
if showMOMTable
    tablePos = tablePosition == "Right" ? position.top_right : position.top_left
    
    var table momTable = table.new(tablePos, 2, 10, 
                                   bgcolor=color.rgb(250, 250, 250, 10),
                                   border_color=color.rgb(200, 200, 255, 80),
                                   border_width=1, frame_width=1)
    
    // Header - Pink background, Gold text (Row 0)
    table.cell(momTable, 0, 0, "ATK / DEF Momentum Motor Analysis", 
               text_color=color.rgb(255, 215, 0),
               text_size=size.normal,
               bgcolor=color.rgb(218, 40, 212))
    table.merge_cells(momTable, 0, 0, 1, 0)
    
    // Row 1: Speed Rating Motor - White background
    table.cell(momTable, 0, 1, "🏎️ Speed Rating", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(momTable, 1, 1, motorSpeedLabel, 
               text_color=motorSpeedColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 2: Power Motor - Light Red background
    powerColor = mom > 0 ? color.rgb(0, 200, 0) : color.rgb(200, 0, 0)
    table.cell(momTable, 0, 2, "💪 Power Motor", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(momTable, 1, 2, motorDirection + " " + powerStrength, 
               text_color=powerColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 3: Market Stage - White background
    table.cell(momTable, 0, 3, "📈 Market Stage", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(momTable, 1, 3, marketStage, 
               text_color=stageColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 4: Momentum Engine - Light Red background
    engineColor = momEngineSmooth > 0 ? color.rgb(0, 200, 0) :
                  momEngineSmooth < 0 ? color.rgb(200, 0, 0) :
                  color.rgb(200, 200, 0)
    table.cell(momTable, 0, 4, "⚙️ Momentum Engine", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(momTable, 1, 4, engineStatus, 
               text_color=engineColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 5: Momentum Speed - White background
    speedColor = speedLevel >= 4 ? color.rgb(0, 200, 0) :
                 speedLevel >= 3 ? color.rgb(200, 200, 0) :
                 color.rgb(200, 0, 0)
    table.cell(momTable, 0, 5, "🏎️ Momentum Speed", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(momTable, 1, 5, speedLabel + " (" + str.tostring(speedLevel) + "/5)", 
               text_color=speedColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 6: Momentum Trend - Light Red background
    trendColor = mom > momMA ? color.rgb(0, 200, 0) : color.rgb(200, 0, 0)
    table.cell(momTable, 0, 6, "📈 Momentum Trend", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(momTable, 1, 6, momTrend + " (" + trendLevel + ")", 
               text_color=trendColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 7: Momentum Radar - White background
    radarColor = radarScore > 70 ? color.rgb(0, 200, 0) :
                 radarScore > 50 ? color.rgb(200, 200, 0) :
                 color.rgb(200, 0, 0)
    table.cell(momTable, 0, 7, "📡 Momentum Radar", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(momTable, 1, 7, radarSignal + " (" + str.tostring(radarScore, "#.0") + "%)", 
               text_color=radarColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 8: Balance Index - Light Red background
    balanceColor = balanceIndex < 20 ? color.rgb(0, 200, 0) :
                   balanceIndex < 40 ? color.rgb(200, 200, 0) :
                   color.rgb(200, 0, 0)
    table.cell(momTable, 0, 8, "⚖️ Balance Index", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 220, 220, 90))
    table.cell(momTable, 1, 8, powerComparison + "\n" + str.tostring(balanceIndex, "#.0") + "%", 
               text_color=balanceColor, text_size=size.small,
               bgcolor=color.rgb(255, 220, 220, 90))
    
    // Row 9: MOM Reference - White background
    refColor = mom > 0 ? color.rgb(0, 200, 0) :
               mom < 0 ? color.rgb(200, 0, 0) :
               color.rgb(200, 200, 0)
    table.cell(momTable, 0, 9, "📊 MOM Reference", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(momTable, 1, 9, momReference + " (" + referenceStrength + ")" + 
               "\nMOM: " + str.tostring(mom, "#.2"), 
               text_color=refColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
````
