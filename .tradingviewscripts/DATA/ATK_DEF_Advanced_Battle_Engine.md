<!-- tradingview-pine-id: PUB;8a98c0b1c3e4480183c09a951f8d70c2 -->
<!-- tradingviewscripts-format: 1 -->
# ATK / DEF Advanced Battle Engine

Source: https://www.tradingview.com/script/Hq7sV54V/

## Description

## Overview

ATK / DEF Advanced Battle Engine is a market behavior analysis and visua tool that combines liqui conditions, price movement, volati behavior, and swing struc to provide a mu-dimenal reference around signcant price highs and lows.

Raher than trting price movement as a simple upward or downward ratio, this indicator examines how liquidity conditions and price movement inract with one anoer around swing points.

The ATK / DEF concept is used as a structural repsentation of changing market behavior. It is not inteed to repsent a conntional direcnal indicator or a simple adce/dine measement.

## Core Concept

The indicator combines several market observations into a unied analytical framework:

• Swing High and Swing Low structure
• Liquidity pressure
• Liquidity changes
• Price movement behavior
• ADL-based tracking
• ADL directional behavior
• ADL attraction characteristics
• Volatility conditions
• Combined behavior assessment

The purpose of combining these components is to provide additional context around hw price behaves when it rches or develops around important high and low areas.

Instead of evating a high or low from prie alone, the indicator considers the surrnding liqity and movement conditions at the se time.

## High & Low Behavior

Swing High and Swing Low points form the structural foution of the indicator.

When a high or low is idenied, the indicator displays additional contextal information associed with that location, including the current ADL tracking condition and liquidity pressure.

This creates a layered view of each structural point.

A high is therefore not trted simply as a numical pric leel, and a low is not treed simpl as an isolaed turing point.

The surroding conditions are displayd together to provide a broader represtation of the behavior occring around that area.

## Liquidity Analysis

Liquidity information is reprented through two primary observions:

### Liquidity Pressure

Liquidity Pressure compares the current volume condition with its corresnding average levl.

The result is normalized into a bounded rae and classied into dferent pressure levls.

This provides a reference for identiing whether the current market envirment is operating under relatily higher, normal, or lower liqdity conditions.

### Liquidity Change

Liquidity Change exanes the change in volume conditions across a dened period.

It provides a reference for whether liquidity conditions are incasing, decasing, or remning relavely balanc.

These measements are used as conttual information raer than as stalone directional measuments.

## ADL Tracking

The ADL Tracking component evaates the relaonship between price change and changs in volume conditions.

The resuing value is normalized into a  range and categized into several intensity levels.

This allows the indicator to reprent the current relatiohip between price movement and liquidity conditions without reducing the analysis to price direction alone.

The displayed levels provide a visua reference for changes in the inteity of this relationship.

## ADL Trend

ADL Trend measures the change in the ADL tracking condition over a dened period.

It classifies the observed behavior as:

• Up
• Down
• Sideways

The associated strgth value proides additional context rerding the magtude of the oerved change.

This component is intended to describe the changing state of the undeying measurement rather than simply deribing whether price is risg or faing.

## ADL Attraction

ADL Attraction examines the difference between the ADL-based movement component and the unrlying price-change component.

The resulting value is smoothed and normalized to provide a serate referce for directional pressure within the combed calculan.

The indicator presents this condition through:

• Direction
• Strength
• Intensity level

This helps distinguish the behavior of the combined liquidity/price relationship from the raw movement of price itelf.

## Volatility Behavior

Volatility Behavior compares the current candle range with ATR-based volatility conditions.

The result provides a normalized reprentation of the relative size of the current price range.

The indicator classifies volatility into several levels, allowing users to distiuish between relatively qut price behavior and periods with greater range expansion.

Volatility is presented as contextual information alongside liquidity and structural observations.

## Behavior Detection

The Behavior Detection component combines ADL Tracking and ADL Attraction into a single reference value.

This produces a brder repsentation of the conditions being obrved by the indicator.

The resulting classifation provides a simplified summary of the combined measurements while retaining the underlying components in the analysis table.

It should be viewed as a composite reference rather than a standalone directional measurement.

## ATK / DEF Framework

The ATK / DEF terminogy describes two sies of market behavior around structural price areas.

**ATK** reprsents the obsvation of upward-side interaction around relevant high-side structure.

**DEF** reprsents the obseration of downward-side interaction around relevant low-side structure.

These tems are usd as visal and structural laels for intpreting the relatiship between price, liqdity, and swing behavior.

They do not represent direct market instructions.

## Analysis Table

The intated analysis table prides a compact view of the current analytical state.

It includes:

• ADL Tracking
• ADL Trend
• ADL Attraction
• Liquidity Pressure
• Liquidity Change
• Volatility Behavior
• Behavior Detection

The table allows the different measurements to be vied togher rather than interpreting each component independently.

## Swing Labels

When ebled, Swing High and Swing Low labels display the strtural price level together with contextual liquidity and ADL information.

This allows histical swing locations to rein addtional analycal information instead of displaying only the price level.

The result is a more detaled visual reprentation of how liqdity and price behavior were charterized around the detected structural area.

## Design Philosophy

The design of ATK / DEF Advanced Battle Engine is based on combining multle forms of market information rather than relng on a single measurement.

Price strture provides the location.

Liquidity provides conttual participation information.

ADL calculaons provide a relaonship between price movement and volume conditions.

Volatity provides information about the sce of current price movement.

Together, these components create a multi-layer reference for stud market behavior around highs, lows, and chaing structural conditions.

## Important Note

This indicator is intended for market behavior analysis and visual reference.

It is not designed as a stalone desion-mag sysm. The displayed measuments should be evalted together with other anatical tools, market contet, and indendent intertation.

The values and classiations are callated from historal price and volume da and may chang as new mat dat devels.

Histor behavior does not guara future conditions.

ATK / DEF Advanced Battle Engine is designed to provide additional analytical

---

## Source Code

````pine
//@version=6
indicator("ATK / DEF Advanced Battle Engine", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================
// 1. Input Parameters
// ============================================
leftBars = input.int(5, "Left Bars", minval=1)
rightBars = input.int(5, "Right Bars", minval=1)
showLabels = input.bool(true, "Show Pivot Labels")
showADLTable = input.bool(true, "Show ADL Analysis Table", group="Display Settings")
tablePosition = input.string("Right", "Table Position", options=["Right", "Left"], group="Display Settings")
adlLength = input.int(14, "ADL Period", minval=5, maxval=50)

// ============================================
// 2. Detect Swing Highs and Swing Lows
// ============================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

// ============================================
// 3. Base Calculations
// ============================================
atr = ta.atr(14)
volumeMA = ta.sma(volume, adlLength)
priceMA = ta.sma(close, adlLength)

// Price change rate
priceChange = ta.change(close, 1) / (close[1] + 0.0001) * 100
volumeChange = ta.change(volume, 1) / (volume[1] + 0.0001) * 100

// ============================================
// 4. ADL Core Calculation (Rate of change method, no explosion)
// ============================================
adlCore = priceChange * (volumeChange / 100)
adlMA = ta.sma(adlCore, adlLength)

// ============================================
// 5. ADL Tracking (0-100%)
// ============================================
adlTrackingRaw = (adlCore - adlMA) / (adlMA + 0.0001) * 100
adlTrackingRaw := math.min(math.max(adlTrackingRaw, -100), 100)
adlTracking = (adlTrackingRaw + 100) / 2
adlTracking := math.min(math.max(adlTracking, 0), 100)

adlTrackingLevel = adlTracking > 80 ? "🔴 Extreme" :
                   adlTracking > 60 ? "🟡 Strong" :
                   adlTracking > 40 ? "🟢 Moderate" :
                   adlTracking > 20 ? "🟡 Weak" :
                   "🔵 Very Weak"

// ============================================
// 6. ADL Trend (Up/Down/Sideways)
// ============================================
adlTrendValue = ta.change(adlTrackingRaw, 5)
adlTrendValue := math.min(math.max(adlTrendValue, -100), 100)

adlTrend = adlTrendValue > 5 ? "⬆️ Up" :
           adlTrendValue < -5 ? "⬇️ Down" :
           "➡️ Sideways"

adlTrendStrength = math.abs(adlTrendValue)

// ============================================
// 7. ADL Attraction (Retains Direction)
// ============================================
adlAttraction = adlCore - priceChange
adlAttraction := ta.sma(adlAttraction, 5)
adlAttraction := math.min(math.max(adlAttraction, -100), 100)

adlAttractionStrength = math.abs(adlAttraction)

attractionDirection = adlAttraction > 5 ? "🟢 Upward" :
                      adlAttraction < -5 ? "🔴 Downward" :
                      "⚪ Balanced"

attractionLevel = adlAttractionStrength > 80 ? "🔴 Extreme" :
                  adlAttractionStrength > 60 ? "🟡 Strong" :
                  adlAttractionStrength > 40 ? "🟢 Moderate" :
                  adlAttractionStrength > 20 ? "🟡 Weak" :
                  "🔵 Very Weak"

// ============================================
// 8. Liquidity Indicators
// ============================================

// 8.1 Liquidity Pressure
liquidityPressure = (volume - volumeMA) / (volumeMA + 0.0001) * 100
liquidityPressure := math.min(math.max(liquidityPressure, -100), 100)

liquidityLevel = liquidityPressure > 50 ? "🔴 High Pressure" :
                 liquidityPressure > 20 ? "🟡 Mid Pressure" :
                 liquidityPressure > -20 ? "🟢 Normal" :
                 liquidityPressure > -50 ? "🟡 Low Pressure" :
                 "🔵 Very Low"

// 8.2 Liquidity Change
liquidityChange = ta.change(volume, 5) / (volume[5] + 0.0001) * 100
liquidityChange := math.min(math.max(liquidityChange, -100), 100)

liquidityTrend = liquidityChange > 20 ? "📈 Inflow" :
                 liquidityChange < -20 ? "📉 Outflow" :
                 "➡️ Balanced"

// ============================================
// 9. Swing Point Labels (Includes Liquidity)
// ============================================
if showLabels
    if not na(swingHigh)
        labelText = "🔴 HIGH\n" + str.tostring(swingHigh, "#.##") +   "\n📊 " + adlTrackingLevel + " " + str.tostring(adlTracking, "#.0") + "%" +   "\n💧 " + liquidityLevel + " " + str.tostring(liquidityPressure, "#.0") + "%"
        
        label.new(bar_index[rightBars], swingHigh,
                  text=labelText,
                  color=color.rgb(255,247,2), 
                  textcolor=color.white,
                  style=label.style_label_down, 
                  size=size.small)
    
    if not na(swingLow)
        labelText = "🟢 LOW\n" + str.tostring(swingLow, "#.##") +  "\n📊 " + adlTrackingLevel + " " + str.tostring(adlTracking, "#.0") + "%" +   "\n💧 " + liquidityLevel + " " + str.tostring(liquidityPressure, "#.0") + "%"
        
        label.new(bar_index[rightBars], swingLow,
                  text=labelText,
                  color=color.rgb(11,214,255), 
                  textcolor=color.white,
                  style=label.style_label_up, 
                  size=size.small)

// ============================================
// 10. Status Line Display
// ============================================
plot(liquidityPressure, "Liquidity Pressure", display=display.status_line, color=color.blue)
plot(adlTracking, "ADL Tracking", display=display.status_line, color=color.yellow)
plot(adlAttraction, "ADL Attraction", display=display.status_line, color=color.white)

// ============================================
// 11. ADL Analysis Table (Right Side)
// ============================================
if showADLTable
    tablePos = tablePosition == "Right" ? position.top_right : position.top_left
    
    var table adlTable = table.new(tablePos, 2, 8, 
                                   bgcolor=color.rgb(255, 255, 255),
                                   border_color=color.rgb(200, 200, 255, 80),
                                   border_width=1, frame_width=1)
    
    // Header
    table.cell(adlTable, 0, 0, "⚔️ ATK / DEF Battle Engine", 
               text_color=color.rgb(255, 255, 255),
               text_size=size.normal,
               bgcolor=color.rgb(255, 215, 0))
    table.merge_cells(adlTable, 0, 0, 1, 0)
    
    // Row 1: ADL Tracking
    table.cell(adlTable, 0, 1, "📊 ADL Tracking", text_color=color.rgb(50, 50, 50))
    table.cell(adlTable, 1, 1, adlTrackingLevel + "\n" + str.tostring(adlTracking, "#.0") + "%", 
               text_color=color.rgb(0, 200, 0), text_size=size.small)
    
    // Row 2: ADL Trend
    table.cell(adlTable, 0, 2, "📈 ADL Trend", text_color=color.rgb(50, 50, 50))
    table.cell(adlTable, 1, 2, adlTrend + "\n" + str.tostring(adlTrendStrength, "#.0") + "%", 
               text_color=adlTrendValue > 0 ? color.rgb(0, 200, 0) : color.rgb(255, 0, 0), text_size=size.small)
    
    // Row 3: ADL Attraction
    table.cell(adlTable, 0, 3, "🧲 ADL Attraction", text_color=color.rgb(50, 50, 50))
    table.cell(adlTable, 1, 3, attractionDirection + "\n" + attractionLevel + " " + str.tostring(adlAttractionStrength, "#.0") + "%", 
               text_color=adlAttraction > 0 ? color.rgb(0, 200, 0) : color.rgb(255, 0, 0), text_size=size.small)
    
    // Row 4: Liquidity Pressure
    table.cell(adlTable, 0, 4, "💧 Liquidity Pressure", text_color=color.rgb(50, 50, 50))
    table.cell(adlTable, 1, 4, liquidityLevel + "\n" + str.tostring(liquidityPressure, "#.0") + "%", 
               text_color=color.rgb(0, 200, 0), text_size=size.small)
    
    // Row 5: Liquidity Change
    table.cell(adlTable, 0, 5, "🌊 Liquidity Change", text_color=color.rgb(50, 50, 50))
    table.cell(adlTable, 1, 5, liquidityTrend + "\n" + str.tostring(liquidityChange, "#.0") + "%", 
               text_color=liquidityChange > 0 ? color.rgb(0, 200, 0) : color.rgb(255, 0, 0), text_size=size.small)
    
    // Row 6: Volatility Behavior
    volatilityBehavior = (high - low) / (atr + 0.0001) * 100
    volatilityBehavior := math.min(math.max(volatilityBehavior, 0), 100)
    volatilityLevel = volatilityBehavior > 70 ? "🔥 High" :
                      volatilityBehavior > 50 ? "⚡ Mid" :
                      volatilityBehavior > 30 ? "🌊 Low" :
                      "💤 Very Low"
    
    table.cell(adlTable, 0, 6, "🌊 Volatility", text_color=color.rgb(50, 50, 50))
    table.cell(adlTable, 1, 6, volatilityLevel + "\n" + str.tostring(volatilityBehavior, "#.0") + "%", 
               text_color=color.rgb(0, 200, 0), text_size=size.small)
    
    // Row 7: Behavior Detection
    behaviorScore = (adlTracking + adlAttractionStrength) / 2
    behaviorScore := math.min(behaviorScore, 100)
    behaviorLevel = behaviorScore > 70 ? "🔴 Strong" :  behaviorScore > 55 ? "🟡 Bullish" :   behaviorScore > 40 ? "🟢 Neutral" :    behaviorScore > 25 ? "🟡 Bearish" :     "🔵 Weak"
    
    table.cell(adlTable, 0, 7, "🎯 Behavior Detection", text_color=color.rgb(50, 50, 50))
    table.cell(adlTable, 1, 7, behaviorLevel + "\n" + str.tostring(behaviorScore, "#.0") + "%", 
               text_color=color.rgb(0, 200, 0), text_size=size.small)
````
