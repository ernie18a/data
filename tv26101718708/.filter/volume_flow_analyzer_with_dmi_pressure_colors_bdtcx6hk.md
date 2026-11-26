# Volume Flow Analyzer with DMI Pressure Colors

- url: https://www.tradingview.com/script/BdtCx6hk-Volume-Flow-Analyzer-with-DMI-Pressure-Colors/
- type: indicator
- pine_id: PUB;9b20027fbc514b78aaf556920884a3c5
- version: 1.0

## Description

Author: IndicatorEdge** | Pine Script™ v6

What It Does
Colors volume bars GREEN (bullish) or RED (bearish) based on DMI pressure. Shows real-time trading suggestions in dashboard.

How It Works
- **+DI > -DI + ADX ≥ 20** → 🟢 BULLISH (buyers in control)
- **-DI > +DI + ADX ≥ 20** → 🔴 BEARISH (sellers in control)  
- **+DI ≈ -DI or ADX < 20** → ⚪ NEUTRAL (wait)

Dashboard Info
| Field | Meaning |
|-------|---------|
| STATE | Bullish/Bearish/Neutral + ADX |
| DMI | +DI / -DI values (who's winning) |
| ADX | Trend strength (>20 = trending) |
| RATIO | Volume vs average (SPIKE = unusual) |
| STRENGTH | Visual bar █░░░ (0-100%) |
| ACTION | What to do (BUY/WAIT/SELL) |

Trading Actions
| When | Action |
|------|--------|
| +DI = -DI | ⏸️ WAIT - No direction |
| +DI > -DI + spike | 🟢🔥 STRONG BUY |
| +DI > -DI | 🟢 BUY |
| -DI > +DI + spike | 🔴🔥 STRONG SELL |
| -DI > +DI | 🔴 SELL |
| DMI crossover | 🟢⬆️ BULLISH ENTRY |
| DMI crossunder | 🔴⬇️ EXIT/SHORT |

How to Use
1. Check STATE (bullish/bearish)
2. Check ADX (>20 = strong trend)
3. Follow ACTION suggestion
4. Confirm with price action

Best Timeframes
15min, 30min, 1H, 4H

Alerts (6 types)
- Bullish crossover
- Bearish crossunder  
- DMI equal (WAIT signal)
- Volume spike + bullish
- Volume spike + bearish

Limitations
- Lagging indicator (14 periods)
- Does NOT predict future
- False signals in low ADX

Default Settings
- DMI Period: 14
- ADX Threshold: 20  
- ADX Filter: ON
- Bar Opacity: 80%

⚠️ Past performance does not guarantee future results. Confirmation with price action required.

## Source Code

````pine
//© IndicatorEdge
//@version=6

indicator(title="Volume Flow Analyzer with DMI Pressure Colors", 
          overlay=false, 
          shorttitle="VFA DMI Pressure", 
          format=format.volume)

//═══════════════════════════════════════════════════════════════════════════
// USER INPUTS
//═══════════════════════════════════════════════════════════════════════════

// ---- Moving Average Settings ----
maOn = input.bool(true, "Show Volume MA", group="Moving Average")
maLength = input.int(20, "MA Length", minval=1, group="Moving Average")
maType = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA"], group="Moving Average")
maColor = input.color(color.aqua, "MA Color", group="Moving Average")

// ---- DMI Pressure Detection ----
dmiLength = input.int(14, "DMI Period", minval=2, maxval=50, group="DMI Settings")
adxThreshold = input.int(20, "ADX Trend Threshold", minval=1, maxval=50, group="DMI Settings")
useADXFilter = input.bool(true, "Filter Ranging Markets", group="DMI Settings")

// ---- Volume Bar Colors ----
bullishColor = input.color(color.new(color.green, 0), "Bullish Bar Color", group="Volume Colors")
bearishColor = input.color(color.new(color.red, 0), "Bearish Bar Color", group="Volume Colors")
neutralColor = input.color(color.new(color.gray, 0), "Neutral Bar Color", group="Volume Colors")
barOpacity = input.int(80, "Bar Opacity %", minval=20, maxval=100, group="Volume Colors")

// ---- Visual Effects ----
bgEffect = input.string("Solid", "Background Effect", options=["Solid", "Wave", "Pulse"], group="Display")
bgOpacity = input.int(10, "Background Opacity %", minval=5, maxval=30, group="Display")
tableOn = input.bool(true, "Show Info Panel", group="Display")
showVolumeSpikes = input.bool(true, "Highlight Volume Spikes", group="Display")
spikeMultiplier = input.float(1.5, "Spike Threshold", minval=1.2, maxval=3.0, step=0.1, group="Display")
dashboardBgOpacity = input.int(90, "Dashboard Background %", minval=70, maxval=100, group="Display")
showActionText = input.bool(true, "Show Trading Action Suggestions", group="Display")

//═══════════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
//═══════════════════════════════════════════════════════════════════════════

barTransparency = 100 - barOpacity
bgTransparency = bgOpacity
dashboardBgTransparency = 100 - dashboardBgOpacity

getMA(src, len, type) =>
    switch type
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        => ta.ema(src, len)

movingAverage = maOn ? getMA(volume, maLength, maType) : na

[diPlus, diMinus, adx] = ta.dmi(dmiLength, dmiLength)
trendingMarket = adx >= adxThreshold

sma20Volume = ta.sma(volume, 20)
volumeSpike = volume > sma20Volume * spikeMultiplier

// Calculate volume strength
volumeStrengthPercent = math.min(100, (volume / sma20Volume) * 100)
volumeStrength = volume > sma20Volume ? volumeStrengthPercent : 0 - volumeStrengthPercent

// Calculate DMI difference and trend direction
dmiDifference = diPlus - diMinus
dmiEqual = math.abs(dmiDifference) <= 2  // Within 2 points = essentially equal

//═══════════════════════════════════════════════════════════════════════════
// TRADING ACTION SUGGESTIONS BASED ON DMI CONDITIONS
//═══════════════════════════════════════════════════════════════════════════

var string tradingAction = ""
var color actionColor = color.gray
var string actionIcon = ""

// Determine trading action based on DMI and ADX
if dmiEqual and (useADXFilter and not trendingMarket)
    tradingAction := "WAIT - No Clear Direction"
    actionColor := color.orange
    actionIcon := "⏸️"
else if dmiEqual and trendingMarket
    tradingAction := "CAUTION - Trend Pausing"
    actionColor := color.yellow
    actionIcon := "⚠️"
else if diPlus > diMinus and trendingMarket and volumeSpike
    tradingAction := "STRONG BUY - Volume Confirmed"
    actionColor := color.lime
    actionIcon := "🟢🔥"
else if diPlus > diMinus and trendingMarket
    tradingAction := "BUY - Bullish Pressure"
    actionColor := color.green
    actionIcon := "🟢"
else if diPlus > diMinus and not trendingMarket
    tradingAction := "WEAK BUY - Low Momentum"
    actionColor := color.new(color.green, 40)
    actionIcon := "🟢⚡"
else if diMinus > diPlus and trendingMarket and volumeSpike
    tradingAction := "STRONG SELL - Volume Confirmed"
    actionColor := color.red
    actionIcon := "🔴🔥"
else if diMinus > diPlus and trendingMarket
    tradingAction := "SELL - Bearish Pressure"
    actionColor := color.red
    actionIcon := "🔴"
else if diMinus > diPlus and not trendingMarket
    tradingAction := "WEAK SELL - Low Momentum"
    actionColor := color.new(color.red, 40)
    actionIcon := "🔴⚡"
else if ta.crossover(diPlus, diMinus)
    tradingAction := "BULLISH CROSSOVER - Entry"
    actionColor := color.lime
    actionIcon := "🟢⬆️"
else if ta.crossunder(diPlus, diMinus)
    tradingAction := "BEARISH CROSSUNDER - Exit/Short"
    actionColor := color.red
    actionIcon := "🔴⬇️"
else
    tradingAction := "No Action - Monitor"
    actionColor := color.gray
    actionIcon := "👁️"

//═══════════════════════════════════════════════════════════════════════════
// PRESSURE STATE DETERMINATION
//═══════════════════════════════════════════════════════════════════════════

var string pressureText = ""
var color bgPressureColor = color.new(color.gray, 90)
var color volumeBarColor = color.new(color.gray, 20)
var color tableAccent = color.gray
var color dashboardHighlight = color.white
var color volumeBarColorHex = color.gray
var float volumeIntensity = 0.0

if useADXFilter and not trendingMarket
    pressureText := "CONSOLIDATION"
    bgPressureColor := color.new(color.gray, bgTransparency)
    volumeBarColor := color.new(neutralColor, barTransparency)
    tableAccent := color.new(color.gray, 0)
    dashboardHighlight := color.new(color.gray, 0)
    volumeBarColorHex := color.gray
    volumeIntensity := 0.3
else if diPlus > diMinus
    pressureText := "BULLISH"
    bgPressureColor := color.new(bullishColor, bgTransparency)
    volumeBarColor := color.new(bullishColor, barTransparency)
    tableAccent := color.new(color.green, 0)
    dashboardHighlight := color.new(color.lime, 0)
    volumeBarColorHex := color.green
    volumeIntensity := math.min(1.0, volume / sma20Volume / 2)
else if diMinus > diPlus
    pressureText := "BEARISH"
    bgPressureColor := color.new(bearishColor, bgTransparency)
    volumeBarColor := color.new(bearishColor, barTransparency)
    tableAccent := color.new(color.red, 0)
    dashboardHighlight := color.new(color.red, 0)
    volumeBarColorHex := color.red
    volumeIntensity := math.min(1.0, volume / sma20Volume / 2)
else
    pressureText := "NEUTRAL - EQUAL"
    bgPressureColor := color.new(color.gray, bgTransparency)
    volumeBarColor := color.new(neutralColor, barTransparency)
    tableAccent := color.new(color.orange, 0)
    dashboardHighlight := color.new(color.orange, 0)
    volumeBarColorHex := color.orange
    volumeIntensity := 0.2

if useADXFilter and not trendingMarket
    pressureText := pressureText + " (ADX:" + str.tostring(math.round(adx)) + ")"
else if trendingMarket
    pressureText := pressureText + " (ADX:" + str.tostring(math.round(adx)) + ")"

spikeIndicator = volumeSpike and showVolumeSpikes ? "⚡" : ""

//═══════════════════════════════════════════════════════════════════════════
// PLOTS
//═══════════════════════════════════════════════════════════════════════════

finalBarColor = volumeSpike and showVolumeSpikes ? color.new(color.white, barTransparency / 2) : volumeBarColor
plot(volume, color=finalBarColor, title="Volume Bars", style=plot.style_columns, linewidth=2)
plot(movingAverage, color=maColor, title="Volume MA", style=plot.style_line, linewidth=2)

//═══════════════════════════════════════════════════════════════════════════
// BACKGROUND EFFECTS
//═══════════════════════════════════════════════════════════════════════════

wavePosition = (math.sin(bar_index * 0.1) + 1) / 2
pulsePosition = math.abs(math.sin(bar_index * 0.2))

var color displayBgColor = bgPressureColor

if bgEffect == "Wave"
    displayBgColor := color.from_gradient(wavePosition, 0, 1, bgPressureColor, color.new(bgPressureColor, bgTransparency + 20))
if bgEffect == "Pulse"
    displayBgColor := color.from_gradient(pulsePosition, 0, 1, color.new(bgPressureColor, bgTransparency + 20), bgPressureColor)

bgcolor(displayBgColor, title="Market Pressure Background")

//═══════════════════════════════════════════════════════════════════════════
// DASHBOARD WITH TRADING ACTION SUGGESTIONS
//═══════════════════════════════════════════════════════════════════════════

// Determine number of rows (8 with action, 7 without)
totalRows = showActionText ? 8 : 7

var infoTable = table.new(position.top_right, 2, totalRows, 
                           bgcolor=color.new(color.black, dashboardBgTransparency),
                           border_color=tableAccent,
                           border_width=2,
                           frame_width=1,
                           frame_color=color.new(color.white, 50))

if tableOn and barstate.islast
    // Header separator
    table.cell(infoTable, 0, 0, "━━━━━━━━━━━━━━━━━━━━━━", 
               text_color=tableAccent, 
               bgcolor=color.new(color.black, dashboardBgTransparency),
               text_size=size.small, 
               text_halign=text.align_center)
    table.cell(infoTable, 1, 0, "", bgcolor=color.new(color.black, dashboardBgTransparency))
    
    // Title Row
    table.cell(infoTable, 0, 1, "📊 VOLUME FLOW", 
               text_color=color.white, 
               bgcolor=color.new(tableAccent, 80),
               text_size=size.small, 
               text_halign=text.align_center)
    table.cell(infoTable, 1, 1, "ANALYZER", 
               text_color=color.white, 
               bgcolor=color.new(tableAccent, 80),
               text_size=size.small)
    
    // Row 2: Market State
    stateIcon = diPlus > diMinus ? "🟢" : diMinus > diPlus ? "🔴" : "⚖️"
    table.cell(infoTable, 0, 2, stateIcon + " STATE", 
               text_color=color.white, 
               bgcolor=color.new(color.black, 70),
               text_size=size.small)
    table.cell(infoTable, 1, 2, pressureText + " " + spikeIndicator, 
               text_color=dashboardHighlight, 
               bgcolor=color.new(color.black, 70),
               text_size=size.small,
               text_halign=text.align_left)
    
    // Row 3: DMI Values with EQUAL indicator
    dmiEqualText = dmiEqual ? " ⚖️ EQUAL" : ""
    table.cell(infoTable, 0, 3, "⚡ DMI", 
               text_color=color.white,
               bgcolor=color.new(color.black, 70),
               text_size=size.small)
    table.cell(infoTable, 1, 3, "+DI:" + str.tostring(math.round(diPlus)) + "  -DI:" + str.tostring(math.round(diMinus)) + dmiEqualText, 
               text_color=color.white,
               bgcolor=color.new(color.black, 70),
               text_size=size.small)
    
    // Row 4: ADX Value
    adxIcon = trendingMarket ? "📈" : "📉"
    table.cell(infoTable, 0, 4, adxIcon + " ADX", 
               text_color=color.white,
               bgcolor=color.new(color.black, 70),
               text_size=size.small)
    adxColor = trendingMarket ? color.lime : color.orange
    table.cell(infoTable, 1, 4, str.tostring(math.round(adx)) + (trendingMarket ? " TRENDING" : " RANGING"), 
               text_color=adxColor,
               bgcolor=color.new(color.black, 70),
               text_size=size.small)
    
    // Row 5: Volume Ratio
    volRatio = volume / sma20Volume
    volIcon = volumeSpike ? "⚡" : "📊"
    table.cell(infoTable, 0, 5, volIcon + " RATIO", 
               text_color=color.white,
               bgcolor=color.new(color.black, 70),
               text_size=size.small)
    
    volColor = volumeSpike ? color.yellow : color.white
    volText = volumeSpike ? "SPIKE! " + str.tostring(volRatio, "#.##") + "x" : str.tostring(volRatio, "#.##") + "x avg"
    table.cell(infoTable, 1, 5, volText, 
               text_color=volColor,
               bgcolor=color.new(color.black, 70),
               text_size=size.small,
               text_halign=text.align_left)
    
    // Row 6: Volume Strength Visual Bar
    strengthPercent = math.abs(math.round(volumeStrength))
    barLength = 10
    filledBars = math.round((strengthPercent / 100) * barLength)
    filledBars := math.min(filledBars, barLength)
    
    visualBarText = ""
    barDisplayColor = volumeStrength > 0 ? color.green : volumeStrength < 0 ? color.red : color.gray
    
    for i = 0 to barLength - 1
        if i < filledBars
            visualBarText := visualBarText + "█"
        else
            visualBarText := visualBarText + "░"
    
    visualBarText := visualBarText + "  " + str.tostring(strengthPercent) + "%"
    
    barIcon = volumeStrength > 0 ? "🟢" : volumeStrength < 0 ? "🔴" : "⚪"
    table.cell(infoTable, 0, 6, barIcon + " STRENGTH", 
               text_color=color.white,
               bgcolor=color.new(color.black, 70),
               text_size=size.small)
    table.cell(infoTable, 1, 6, visualBarText, 
               text_color=barDisplayColor,
               bgcolor=color.new(color.black, 70),
               text_size=size.small,
               text_halign=text.align_left)
    
    // Row 7: 🎯 TRADING ACTION SUGGESTION (New!)
    if showActionText
        table.cell(infoTable, 0, 7, actionIcon + " ACTION", 
                   text_color=color.white,
                   bgcolor=color.new(color.black, 70),
                   text_size=size.small)
        table.cell(infoTable, 1, 7, tradingAction, 
                   text_color=actionColor,
                   bgcolor=color.new(color.black, 70),
                   text_size=size.small,
                   text_halign=text.align_left)

//═══════════════════════════════════════════════════════════════════════════
// ALERTS
//═══════════════════════════════════════════════════════════════════════════

alertcondition(ta.crossover(diPlus, diMinus), title="🟢 Bullish Crossover", message="DMI bullish crossover - Consider Entry")
alertcondition(ta.crossunder(diPlus, diMinus), title="🔴 Bearish Crossunder", message="DMI bearish crossunder - Consider Exit/Short")
alertcondition(dmiEqual, title="⚠️ DMI Equal", message="DMI lines are equal - Market equilibrium, wait for direction")
alertcondition(volumeSpike and diPlus > diMinus, title="⚡ Bullish Volume Spike", message="High volume with bullish pressure - Strong Buy Signal")
alertcondition(volumeSpike and diMinus > diPlus, title="⚡ Bearish Volume Spike", message="High volume with bearish pressure - Strong Sell Signal")
````
