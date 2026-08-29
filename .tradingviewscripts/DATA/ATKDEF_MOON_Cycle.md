<!-- tradingview-pine-id: PUB;8c39882a6938475792022271dcce0e0a -->
<!-- tradingviewscripts-format: 1 -->
#  ATK/DEF MOON Cycle

Source: https://www.tradingview.com/script/pFeMRTk8/

## Description

# ATK/DEF MOON Cycle

ATK/DEF MOON Cycle is a market observation framework designed to examine price behavior through a different analytical structure from conventional technical analysis.

Instead of reducing market behavior to a single trend, indicator, or directional classification, this framework observes several measuble properties of the market simuaneously, including **price position, range depth, movement velocity, volatility, activity, structural distance, price expansion and contraction, and session conditions**.

The framework uses a physics-inspired conceual vocabary to organize these observations. Terms such as **Moon Phase, Water Depth, Resonance, Rotation, Black Hole, Satellite, Velocity and Burst** are names for calculated market conditions within the indicator. They are conceptual analytical labels and do not repreent literal astromical forces, gravitional effects, or claims that physical objects control fin markets.

The objective is to provide another way of ohow market conditions develop and intect.

## 🌙 MO Moon Phase — Cyclical Price Position

The Moon Phase module divies the current price position within a confurable obsertion range into eight stages:

* 🌑 New Moon
* 🌒 Waxing Crescent
* 🌓 First Quarter
* 🌔 Waxing Gibbous
* 🌕 Full Moon
* 🌖 Waning Gibbous
* 🌗 Last Quarter
* 🌘 Waning Crescent

The calcation uses the highest and lowest prices within the selected cy length.

The current closing price is noalized between these two bdaries and expreed as a percentage 

This creates a visual reprention of where price is currently posioned inside its measured range.

The eight phas theefore describe **progressive positnal changes inside the market range**, rather than reprenting an actual astrmical moon cycle.

The default observation length is 28 bars and can be adjued through the indicator settings.

## 🌊 MO Test Depth — Range Depth

Test Depth measures how deeply the current price is positioned within the observed price range.

The calcation compares the current close with the cycle high and cycle low and converts the result into a normalied percentage.

The indicator divides this position into several zones:

* 🔵 Shallows
* 🟢 Shallow Water
* 🟡 Mid Water
* 🔴 Deep Water

This proides a diffent perective from siply describg price as bullish or bearish.

The same directional movement can have very different structural meanings depeding on wther price is located near the lower portion, middle portion, or upper portion of its observed range.

Test Depth is therefore primarily a **positional measurement**.

## 🔄 MO Resonance Rotation — Movement Velocity

Resonance Rotation measures the magtude of recent pric displacement relative to ATR.

The indicator calcates price change over several bas and compares that movement with the current ATR environment.

The result is normalized into a scale and classified into:

* Lo Speed
* M Speed
* Hg Speed

This allows the framework to distinguish between relatively small price movement and movement that is large comred with the current volatity environment.

The rm “Rotation” is a coptual descrtion of changing market movement. It does not iply literal physical rotation.

## 🌀 MO Black Hole Trap — Compression and Expansion

Black Hole Trap examines the relationship between **candle range and relative volume**.

The cunt candle range is comred with the brder cycle range, while current volume is comped with its moving average.

Several conditions can therefre be observed:

* relatiely compresed price rane with reced actity
* comessed range with very low relive activity
* expaded range with eleted activity
* more orary range and activity conditions

These conditions are converted into a normaled Black Hole Score

The resulting classifications are:

* No Tra
* Weak Tra
* Mid Tr
* Strong Tr

The purpose of this module is to describe unul combitions of **range compression, range expansion and market activity**.

“Black Hole” is a conceptual name for this calculd condition. It does not reprent an acal phcal black hole, gravitanal fild, or phycal force acng on price.

## ⚡ MO Price Action Resonance — Condition Alignment

Price Action Resonance examines several market characstics together.

The calculation considers:

* current price relative to the cycle high
* current price relative to the cycle low
* price relationship with the per
* relative volume

Each condition contrutes to a combined resonance score.

The score is classified into:

* No Reonace
* Weak Resnance
* Mid Resonace
* Strong Renance

This component is desned to show when seral difrent market obseations are ocuing together.

Raer than trting one measurent as the comlete descption of market behavior, the module presves several dimions and combes them into a single descrtive state.

## ⚡ MO Smooth Velocity — Smoothed Directional Movement

Smooth Velocity measures the rate of change of an EMA-smoothed price series.

The price is first smoothed with an EMA, after which the change in the smoothed series is measured over several bars and normazed relative to the smoothed price.

The resulting state is classified as:

* 🚀 Fast Up
* ⬆️ Slow Up
* ➡️ Sideways
* ⬇️ Slow Down
* 📉 Fast Down

This provides information about both **direction and movement rate**.

The purpose is not simply to ideify whether price is above or below a moving average, but to obrve how the smoothed price itelf is changing.

## 💥 MO Price Burst — Candle Displacement and Activity

Price Burst examines the relationship between candle body movement, total candle range and relative volume.

The open-to-close movement is normaled agaist the candle's high-to-low range.

The resulting directional movement is then combined with the current volume ratio.

This produces a Burst Strength measurement that is classified into:

* 💤 No Burst
* 💥 Weak Burst
* 💥 Mid Burst
* 💥 Strong Burst

This module descibes periods where candle displacement becomes more pronnced relative to the candle's total range and surrnding activity.

It provides another way of observing changes in the intesity of price movement.

## 🌍 MO Session Disruption Radar — Session Volatility

Session Radar divides the d into three broad observation periods:

* 🌏 Asia
* 🌍 Europe
* 🌎 America

The current ATR is compared with a session-specific volatility reference.

This produces a normalized session activity value and corsponding state.

The module therefore examines whether current volatility is relatively subdd or eleted within the defied session environment.

It is designed as a **session cont measurement**, allowing volatity conditions to be observed alonside the other componts of the framework.

## 🛰️ MO Moon Satellite — Secondary Price Position

The Satellite module introdes a secondary observation range derived from the main cycle length.

The current price is measured between the sateite high and salite low and normaled 

The resulting states are:

* Very Low Sateite
* Low Sateite
* Balance Sateite
* Mid Sateite
* High Sateite

This creates a second positnal layer.

The main Moon Phase describes the broer range posion, while the Satelte measument provides another view of where price is locatd inside a smller obseation range.

“Satellite” is a conceptual naming system for this secondary range relationship.

## ⛰️ MO Structure Distance — Structural Location

Structure Distance evaates the current price against an expded structural range.

The indicator idtifies the highest and lowest prices over a larger obsvation window and calates the distance from the current close to both boundies.

The resulting conditions include:

* ⛰️ Near Re
* 🏔️ Near Sort
* 📈 Near Hh
* 📉 Near Lw
* 〰️ Mid Zo

This allows the current market locaon to be descbed in relation to its brder obseed exemes.

The measurement is based on distance rather than a manally drn level.

# 📍 Swing Point Context

The indicator also uses confirmed pivot-based swing highs and swing lows.

When a swing point is confirmed, its label can disay several pieces of conte information simaneously:

* swing price
* current MO Phase
* Satellite position
* structural location
* structural distance

This connects individual swing points with the broader market state being observed by the framework.

The pivot parameters can be adjusted through the Left Bars and Right Bars settings.

# 🧭 A Different Way to Observe Market Direction

The central concept of ATK/DEF MOON Cycle is that market direction does not have to be repreted by one conveional trend calcuion.

The framework separates several different questions:

**Where is price?**
MO Moon Phase, Test Depth and Satellite Position describe price location within different observation ranges.

**How fast is price moving?**
Resonance Rotation and Smooth Velocity describe the rate of price movement.

**How large is the current movement?**
ATR, candle range and Price Burst provide volatility and displacement information.

**How active is the market?**
Relative volume contributes information about the current activity environment.

**Where is price within the broader structure?**
Structure Distance describes the relationship between current price and observed structural extremes.

**Are several conditions occurring together?**
Price Action Resonance combines multiple observations into a common descriptive score.

This separation is important because market position and market movement are not necearily the same thing.

Price can be positioned near an extreme while movement remains weak.

Price can also move rapidly while remaining inside the middle portion of a larger structure.

A compressed range can occur with low activity, while an expanded range can occur with elevated activity.

ATK/DEF MOON Cycle keeps these characteristics visible instead of forcing them into a single conventional trend definition.

# 🧠 Conceptual Architecture

The indicator uses a phycs-inspired voculary as an alrnative organizational language for market obervation.

The terology can be understood as follows:

**Moon Phase**
→ progressive position inside a measured price cycle.

**Water Depth**
→ depth of current price inside the observed range.

**Rotation**
→ normalized magnitude of recent price movement.

**Resonance**
→ simultaneous presence of several measurable market conditions.

**Black Hole**
→ unusual range and activity conditions.

**Velocity**
→ rate of change of price movement.

**Burst**
→ concentrated candle displacement combined with activity.

**Satellite**
→ position inside a secondary observation range.

**Structure Distance**
→ distance between current price and observed structural extremes.

These terms form one consistent analytical language while the underlng calculations remain based on chart data.

The indicator transrms these values into normazed measurements and desiptive states.

The percentages displayed by the indicator repsent **normazed analytical values**. They are not probality estates and should not be intereted as guateed forecasts.

# 📊 Dashboard Design

The MOON Cycle dashboard presents several indepdent obseations in one compact structure.

The dashboard includes:

* Test Depth
* Resonance Rotation
* Black Hole Trap
* Price Action Resonance
* Smooth Velocity
* Price Burst
* Session Radar

Each row reprents a different charactertic of the current market environment.

The purpose of the dashboard is to make the relationship between different market properties eaier to observe without reding the ente chart to a single numeral value.

# 🔬 Analytical Philosophy

ATK/DEF MOON Cycle is based on a simple principle:

**Observe the market from multiple dimensns instead of descring it through only one contional concept.**

Price is treated not only as a seqnce of candles, but as a changing system of:

* position
* movement
* velocity
* range
* activity
* expansion
* contraction
* structural distance
* cyclical progression
* session environment

The physics-inspired terminology provides a separate conceptual language for organizing these observations.

It is not preseed as a claim that finl markets are goverd by lital astroal or phycal mechanms.

The undeying measements remain derived from market data available on the chart.

# ⚠️ Important Information

ATK/DEF MOON Cycle is an analytical and visualization framework for stu market behavior.

The ter used by the indicator is concal. References to Moon, Satellite, Black Hole, Resonance, Rotation, Water Depth and similar terms describe calcul market conditions and are not claims about leral physical forces affting fin mars.

The indicator does not provide fin advice Its purpose is to provide an altetive framework for obsing and analyzing the changing chararistics of market da.

---

## Source Code

````pine
//@version=6
indicator(" ATK/DEF MOON Cycle", overlay=true, max_lines_count=300, max_labels_count=300)

// ============================================
// 1. Input Parameters
// ============================================
leftBars = input.int(5, "Left Bars", minval=1, tooltip="Number of bars to the left of pivot point")
rightBars = input.int(5, "Right Bars", minval=1, tooltip="Number of bars to the right of pivot point")
showLabels = input.bool(true, "Show Pivot Labels")
showMOTable = input.bool(true, "Show MO Moon Phase Table", group="Display Settings")
tablePosition = input.string("Right", "Table Position", options=["Right", "Left"], group="Display Settings")
moCycleLength = input.int(28, "MO Cycle Length", minval=14, maxval=56, tooltip="Moon phase cycle length (default 28 days/cycle)")

// ============================================
// 2. Detect Swing Highs and Swing Lows
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 3. MO Moon Phase Analysis Calculations
// ============================================

// 3.1 Base Cycle Calculation
lookback = moCycleLength
cycleHigh = ta.highest(high, lookback)
cycleLow = ta.lowest(low, lookback)
cycleRange = cycleHigh - cycleLow
cycleRange := cycleRange == 0 ? 0.0001 : cycleRange

pricePosition = (close - cycleLow) / cycleRange * 100
pricePosition := math.min(math.max(pricePosition, 0), 100)

// 3.2 ATR Calculation
atr = ta.atr(14)

// ============================================
// 4. MO Moon Phase Stage
// ============================================
moStage = ""
moStageIcon = ""
moStageColor = color.white

if pricePosition < 12.5
    moStage := "🌑 New Moon"
    moStageIcon := "🌑"
    moStageColor := color.rgb(50, 50, 50)
else if pricePosition < 25
    moStage := "🌒 Waxing Crescent"
    moStageIcon := "🌒"
    moStageColor := color.rgb(100, 100, 200)
else if pricePosition < 37.5
    moStage := "🌓 First Quarter"
    moStageIcon := "🌓"
    moStageColor := color.rgb(150, 150, 255)
else if pricePosition < 50
    moStage := "🌔 Waxing Gibbous"
    moStageIcon := "🌔"
    moStageColor := color.rgb(200, 200, 255)
else if pricePosition < 62.5
    moStage := "🌕 Full Moon"
    moStageIcon := "🌕"
    moStageColor := color.rgb(255, 215, 0)
else if pricePosition < 75
    moStage := "🌖 Waning Gibbous"
    moStageIcon := "🌖"
    moStageColor := color.rgb(200, 150, 100)
else if pricePosition < 87.5
    moStage := "🌗 Last Quarter"
    moStageIcon := "🌗"
    moStageColor := color.rgb(150, 100, 50)
else
    moStage := "🌘 Waning Crescent"
    moStageIcon := "🌘"
    moStageColor := color.rgb(50, 50, 50)

// ============================================
// 5. MO Test Depth
// ============================================
testDepth = (close - cycleLow) / (cycleHigh - cycleLow + 0.0001) * 100
testDepth := math.min(math.max(testDepth, 0), 100)

testDepthLevel = testDepth > 70 ? "🔴 Deep Water" :
                 testDepth > 50 ? "🟡 Mid Water" :
                 testDepth > 30 ? "🟢 Shallow Water" :
                 "🔵 Shallows"

testDepthColor = testDepth > 70 ? color.rgb(255, 0, 0) :
                 testDepth > 50 ? color.rgb(255, 165, 0) :
                 testDepth > 30 ? color.rgb(0, 200, 0) :
                 color.rgb(0, 150, 255)

// ============================================
// 6. MO Resonance Rotation Cycle
// ============================================
priceVelocity = ta.change(close, 3)
rotationSpeed = math.abs(priceVelocity) / (atr + 0.0001) * 100
rotationSpeed := math.min(rotationSpeed, 100)

rotationLevel = rotationSpeed > 60 ? "🔄 High Speed" : rotationSpeed > 35 ? "🔄 Mid Speed" : "🔄 Low Speed"

rotationColor = rotationSpeed > 60 ? color.rgb(255, 0, 0) : rotationSpeed > 35 ? color.rgb(255, 165, 0) : color.rgb(0, 200, 255)

// ============================================
// 7. MO Black Hole Trap
// ============================================
rangeWidth = (high - low) / (cycleRange + 0.0001) * 100
volumeAvg = ta.sma(volume, 14)
volumeRatio = volume / (volumeAvg + 0.0001)

blackHoleScore = 0.0
if rangeWidth < 10 and volumeRatio < 0.8
    blackHoleScore := 50 + (10 - rangeWidth) * 3
else if rangeWidth < 20 and volumeRatio < 0.6
    blackHoleScore := 30 + (20 - rangeWidth) * 2
else if rangeWidth > 40 and volumeRatio > 1.5
    blackHoleScore := 70 + (rangeWidth - 40) * 1.5
else
    blackHoleScore := 30

blackHoleScore := math.min(math.max(blackHoleScore, 0), 100)

blackHoleLevel = blackHoleScore > 70 ? "🌀 Strong Trap" :
                 blackHoleScore > 50 ? "🌀 Mid Trap" :
                 blackHoleScore > 30 ? "🌀 Weak Trap" :
                 "🌀 No Trap"

blackHoleColor = blackHoleScore > 70 ? color.rgb(255, 0, 0) :
                 blackHoleScore > 50 ? color.rgb(255, 165, 0) :
                 blackHoleScore > 30 ? color.rgb(0, 200, 0) :
                 color.rgb(0, 150, 255)

// ============================================
// 8. MO Price Action Resonance
// ============================================
resonanceScore = 0.0

if close > cycleHigh * 0.98
    resonanceScore := resonanceScore + 30
if close < cycleLow * 1.02
    resonanceScore := resonanceScore + 30
if close > ta.sma(close, 20)
    resonanceScore := resonanceScore + 20
else
    resonanceScore := resonanceScore + 10

if volumeRatio > 1.5
    resonanceScore := resonanceScore + 20
else if volumeRatio > 1.2
    resonanceScore := resonanceScore + 10

resonanceScore := math.min(math.max(resonanceScore, 0), 100)

resonanceLevel = resonanceScore > 70 ? "⚡ Strong Resonance" :
                 resonanceScore > 50 ? "⚡ Mid Resonance" :
                 resonanceScore > 30 ? "⚡ Weak Resonance" :
                 "⚡ No Resonance"

resonanceColor = resonanceScore > 70 ? color.rgb(255, 0, 0) :
                 resonanceScore > 50 ? color.rgb(255, 165, 0) :
                 resonanceScore > 30 ? color.rgb(0, 200, 0) :
                 color.rgb(0, 150, 255)

// ============================================
// 9. MO Smooth Moving Velocity
// ============================================
smoothPrice = ta.ema(close, 5)
smoothVelocity = ta.change(smoothPrice, 5) / (smoothPrice + 0.0001) * 100
smoothVelocity := math.min(math.max(smoothVelocity, -100), 100)

smoothVelocityLevel = smoothVelocity > 2 ? "🚀 Fast Up" :
                      smoothVelocity > 0.5 ? "⬆️ Slow Up" :
                      smoothVelocity > -0.5 ? "➡️ Sideways" :
                      smoothVelocity > -2 ? "⬇️ Slow Down" :
                      "📉 Fast Down"

smoothVelocityColor = smoothVelocity > 2 ? color.rgb(255, 0, 0) :
                      smoothVelocity > 0.5 ? color.rgb(255, 165, 0) :
                      smoothVelocity > -0.5 ? color.rgb(0, 200, 0) :
                      smoothVelocity > -2 ? color.rgb(255, 165, 0) :
                      color.rgb(255, 0, 0)

// ============================================
// 10. MO Price Burst
// ============================================
burstMomentum = (close - open) / (high - low + 0.0001) * 100
burstMomentum := math.min(math.max(burstMomentum, -100), 100)

burstStrength = math.abs(burstMomentum) * (volumeRatio / (1 + volumeRatio))

burstLevel = burstStrength > 30 ? "💥 Strong Burst" :
             burstStrength > 15 ? "💥 Mid Burst" :
             burstStrength > 5 ? "💥 Weak Burst" :
             "💤 No Burst"

burstColor = burstStrength > 30 ? color.rgb(255, 0, 0) :
             burstStrength > 15 ? color.rgb(255, 165, 0) :
             burstStrength > 5 ? color.rgb(0, 200, 0) :
             color.rgb(150, 150, 150)

// ============================================
// 11. MO Session Disruption Radar
// ============================================
currentHour = hour

isAsianSession = currentHour >= 0 and currentHour < 8
isEuropeanSession = currentHour >= 8 and currentHour < 16
isAmericanSession = currentHour >= 16 and currentHour < 24

asianVolatility = ta.atr(14) * 0.3
europeanVolatility = ta.atr(14) * 0.5
americanVolatility = ta.atr(14) * 0.7

sessionRadar = 0.0
sessionLevel = ""
sessionIcon = ""

if isAsianSession
    sessionRadar := (atr / (asianVolatility + 0.0001)) * 50
    sessionRadar := math.min(sessionRadar, 100)
    sessionLevel := sessionRadar > 70 ? "🌏 Asia Strong" : sessionRadar > 50 ? "🌏 Asia Mid" : "🌏 Asia Weak"
    sessionIcon := "🌏"
else if isEuropeanSession
    sessionRadar := (atr / (europeanVolatility + 0.0001)) * 50
    sessionRadar := math.min(sessionRadar, 100)
    sessionLevel := sessionRadar > 70 ? "🌍 Europe Strong" : sessionRadar > 50 ? "🌍 Europe Mid" : "🌍 Europe Weak"
    sessionIcon := "🌍"
else if isAmericanSession
    sessionRadar := (atr / (americanVolatility + 0.0001)) * 50
    sessionRadar := math.min(sessionRadar, 100)
    sessionLevel := sessionRadar > 70 ? "🌎 America Strong" : sessionRadar > 50 ? "🌎 America Mid" : "🌎 America Weak"
    sessionIcon := "🌎"
else
    sessionRadar := 0
    sessionLevel := "⏰ Consolidation"
    sessionIcon := "⏰"

sessionColor = sessionRadar > 70 ? color.rgb(255, 0, 0) :
               sessionRadar > 50 ? color.rgb(255, 165, 0) :
               sessionRadar > 30 ? color.rgb(0, 200, 0) :
               color.rgb(0, 150, 255)

// ============================================
// 12. MO Moon Satellite
// ============================================
satelliteLookback = math.max(5, moCycleLength / 6)
satelliteHigh = ta.highest(high, satelliteLookback)
satelliteLow = ta.lowest(low, satelliteLookback)
satelliteRange = satelliteHigh - satelliteLow
satelliteRange := satelliteRange == 0 ? 0.0001 : satelliteRange
satellitePosition = (close - satelliteLow) / satelliteRange * 100

satelliteLevel = satellitePosition > 80 ? "🛰️ High Satellite" :
                 satellitePosition > 60 ? "🛰️ Mid Satellite" :
                 satellitePosition > 40 ? "🛰️ Balance Satellite" :
                 satellitePosition > 20 ? "🛰️ Low Satellite" :
                 "🛰️ Very Low Satellite"

// ============================================
// 13. MO Structure Distance
// ============================================
structureHigh = ta.highest(high, moCycleLength * 2)
structureLow = ta.lowest(low, moCycleLength * 2)
structureRange = structureHigh - structureLow
structureRange := structureRange == 0 ? 0.0001 : structureRange

distanceToHigh = (structureHigh - close) / structureRange * 100
distanceToHigh := math.min(math.max(distanceToHigh, 0), 100)
distanceToLow = (close - structureLow) / structureRange * 100
distanceToLow := math.min(math.max(distanceToLow, 0), 100)

structureLevel = distanceToHigh < 10 ? "⛰️ Near Resistance" :
                 distanceToLow < 10 ? "🏔️ Near Support" :
                 distanceToHigh < 30 ? "📈 Near High" :
                 distanceToLow < 30 ? "📉 Near Low" :
                 "〰️ Mid Zone"

distancePercent = math.min(distanceToHigh, distanceToLow)
distancePercent := math.min(distancePercent, 100)

// ============================================
// 14. Swing Point Labels (with MO Moon Phase Analysis)
// ============================================
if showLabels
    if not na(swingHigh)
        labelText = "🔴 High\n" + str.tostring(swingHigh, "#.##") + "\n" + moStageIcon + " " + moStage + "\n" + satelliteLevel + "\n" + structureLevel + " (" + str.tostring(distancePercent, "#.0") + "%)"
        
        label.new(bar_index[rightBars], swingHigh,
                  text=labelText,
                  color=color.rgb(255,247,2), 
                  textcolor=color.white,
                  style=label.style_label_down, 
                  size=size.small)
    
    if not na(swingLow)
        labelText = "🟢 Low\n" + str.tostring(swingLow, "#.##") + "\n" + moStageIcon + " " + moStage + "\n" + satelliteLevel + "\n" + structureLevel + " (" + str.tostring(distancePercent, "#.0") + "%)"
        
        label.new(bar_index[rightBars], swingLow,
                  text=labelText,
                  color=color.rgb(11,214,255), 
                  textcolor=color.white,
                  style=label.style_label_up, 
                  size=size.small)

// ============================================
// 15. Status Line Display
// ============================================
plot(testDepth, "MO Test Depth", display=display.status_line, color=color.white)
plot(rotationSpeed, "MO Rotation Speed", display=display.status_line, color=color.white)
plot(blackHoleScore, "MO Black Hole", display=display.status_line, color=color.orange)
plot(resonanceScore, "MO Resonance", display=display.status_line, color=color.yellow)

// ============================================
// 16. MO Moon Phase Analysis Table
// ============================================
if showMOTable
    tablePos = tablePosition == "Right" ? position.top_right : position.top_left
    
    var table moTable = table.new(tablePos, 2, 8, 
                                   bgcolor=color.rgb(255, 255, 255),
                                   border_color=color.rgb(255, 255, 255),
                                   border_width=1, frame_width=1)
    
    // Header
    table.cell(moTable, 0, 0, "🌙 ATK/DEF MOON Cycle", 
               text_color=color.rgb(255, 255, 255),
               text_size=size.normal,
               bgcolor=color.rgb(255, 230, 2))
    table.merge_cells(moTable, 0, 0, 1, 0)
    
    // Row 1: MO Test Depth
    table.cell(moTable, 0, 1, "🌊 Test Depth", text_color=color.rgb(40, 40, 39),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(moTable, 1, 1, testDepthLevel + "\n" + str.tostring(testDepth, "#.0") + "%", 
               text_color=testDepthColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 2: MO Resonance Rotation
    table.cell(moTable, 0, 2, "🔄 Resonance Rotation", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(240, 220, 255, 90))
    table.cell(moTable, 1, 2, rotationLevel + "\n" + str.tostring(rotationSpeed, "#.0") + "%", 
               text_color=rotationColor, text_size=size.small,
               bgcolor=color.rgb(240, 220, 255, 90))
    
    // Row 3: MO Black Hole Trap
    table.cell(moTable, 0, 3, "🌀 Black Hole Trap", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(moTable, 1, 3, blackHoleLevel + "\n" + str.tostring(blackHoleScore, "#.0") + "%", 
               text_color=blackHoleColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 4: MO Price Action Resonance
    table.cell(moTable, 0, 4, "⚡ Price Resonance", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(240, 220, 255, 90))
    table.cell(moTable, 1, 4, resonanceLevel + "\n" + str.tostring(resonanceScore, "#.0") + "%", 
               text_color=resonanceColor, text_size=size.small,
               bgcolor=color.rgb(240, 220, 255, 90))
    
    // Row 5: MO Smooth Velocity
    table.cell(moTable, 0, 5, "⚡ Smooth Velocity", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(moTable, 1, 5, smoothVelocityLevel + "\n" + str.tostring(smoothVelocity, "#.00") + "%", 
               text_color=smoothVelocityColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
    
    // Row 6: MO Price Burst
    table.cell(moTable, 0, 6, "💥 Price Burst", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(240, 220, 255, 90))
    table.cell(moTable, 1, 6, burstLevel + "\n" + str.tostring(burstStrength, "#.0") + "%", 
               text_color=burstColor, text_size=size.small,
               bgcolor=color.rgb(240, 220, 255, 90))
    
    // Row 7: MO Session Disruption
    table.cell(moTable, 0, 7, sessionIcon + " Session Radar", text_color=color.rgb(50, 50, 50),
               bgcolor=color.rgb(255, 255, 255, 90))
    table.cell(moTable, 1, 7, sessionLevel + "\n" + str.tostring(sessionRadar, "#.0") + "%", 
               text_color=sessionColor, text_size=size.small,
               bgcolor=color.rgb(255, 255, 255, 90))
````
