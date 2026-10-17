# Macro Structural Run [XP Tactical HUD]

- url: https://www.tradingview.com/script/ofQGmRzq-Macro-Structural-Run-XP-Tactical-HUD/
- type: indicator
- pine_id: PUB;e3f80e0b4704455aab4d2976a390940a
- version: 1.0

## Description

[Publication Description] Macro Structural Run [XP Tactical HUD]
Overview
The Macro Structural Run (MSR) is a high-precision trend-following system designed to identify the exact onset of long-term market trends while protecting the user from late entries and sudden "blow-off" exhaustion phases. Unlike standard moving averages that suffer from fixed lag, the MSR uses a Structural Decay Filter that dynamically weights price data based on its "Efficiency Score."

1. The Core Logic: Structural Decay
Standard indicators treat every bar with equal importance or use a fixed exponential decay. The MSR is different. It calculates a Weighted Moving Average where the weight of each historical bar is determined by two factors:

Efficiency Ratio (ER): This measures how "clean" the price movement was. If price moved from point A to point B in a straight line, it is 100% efficient. If it zig-zagged wildly to get there, efficiency is low. The MSR prioritizes "efficient" historical structure.
Temporal Decay: Influence decreases as bars move further into the past, allowing the filter to hold onto strong structural foundations while remaining reactive to new data.

2. High-Precision On-Set Detection
To solve the problem of entering a move too late, the XP Execution engine requires three points of confirmation before an INITIATE_RUN signal is triggered:

Structural Surge: The Efficiency Ratio must be high (default > 60%) and actively rising.
Tactical Proximity: The price must be close to the structural filter (measured in ATR). If the price has already exploded away from its base, the signal is suppressed.
Momentum Flip: The filter must confirm a foundational change in the macro trend direction.

3. Reactive Exhaustion Analysis
A major feature of this system is its ability to detect when a run is about to fail. It monitors for three types of "danger zones":

Volatility Spikes: Identifies sudden, violent bars that are significantly larger than the recent average (True Range vs. ATR).
Parabolic Acceleration: Tracks the rate at which the price is warping away from its structural base.
Efficiency Decay: Flags when the "cleanliness" of the move drops below the Exhaustion Floor.

4. How to Use the Diagnostic HUD
The Diagnostic HUD provides real-time telemetry on the state of the market:

RUN_PRECISION: Shows the current efficiency of the trend. Above 60% is ideal for runs.
BASE_ANCHOR: Tells you how far price is from the structural base. "OPTIMAL" means a safe entry zone.
VOL_RATIO: Monitors for spikes. A ratio above 2.0x indicates high-risk volatility.
LATEST_SIGNAL: A centralized readout of the current trade lifecycle (BULL_INITIATE, EXHAUST_EXIT, or SYNC_LOST).

Instructions for Use
Entry: Look for the INITIATE_RUN labels on the chart or the BULL/BEAR_INITIATE status on the HUD. Ensure the SYNC_STATUS is "OPTIMAL."
Holding: Maintain the position as long as the HUD shows "MACRO_STABLE" and the line color remains Cyan or Pink.
Exit: When the line turns Neon Gold or the HUD displays EXHAUST_EXIT, the structural health of the move has collapsed. This is the tactical signal to take profits or tighten stops.
Settings Breakdown
Macro Lookback: Controls the sensitivity of the long-term path. (50+ for macro runs).
Structural Power: Higher values prioritize "clean" price action and ignore noise.
Spike Sensitivity: Adjusts how reactive the system is to sudden volatility. Lower values are more sensitive.

Disclaimer
This indicator is for educational and informational purposes only. It is not financial advice. Trading involves significant risk, and past performance is not indicative of future results. Always use proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Macro Structural Run [XP Tactical HUD]", shorttitle="MSR [XP]", overlay=true)

// --- Constants ---
const string G_CALC  = "Macro Engine"
const string G_RUN   = "On-Set Detection Logic"
const string G_EXH   = "Exhaustion & Spike Analysis"
const string G_STYLE = "Tactical Visuals"
const string G_HUD   = "HUD Configuration"

// --- Inputs ---
srcInput    = input.source(close, "Detection Source", group=G_CALC)
macroLen    = input.int(50, "Macro Lookback Resolution", minval=10, group=G_CALC)
erLenInput  = input.int(14, "Structural Resolution", minval=5, group=G_CALC)
decayInput  = input.float(0.08, "Temporal Decay", minval=0.0, maxval=0.5, step=0.01, group=G_CALC)
powerInput  = input.float(3.0, "Structural Power", minval=0.1, group=G_CALC)

// On-Set Precision Settings
minEfficiency  = input.float(0.60, "Min Run Efficiency", minval=0.1, maxval=1.0, group=G_RUN)
proximityLimit = input.float(1.5, "Max Run Start Gap (ATR)", minval=0.1, group=G_RUN)

// Exhaustion & Spike Parameters
exhThreshold   = input.float(0.40, "Exhaustion Floor", minval=0.1, maxval=1.0, group=G_EXH)
extremeDist    = input.float(3.0, "Extreme Extension (ATR)", minval=1.0, group=G_EXH)
spikeSens      = input.float(2.5, "Spike Sensitivity", minval=1.0, maxval=5.0, step=0.1, group=G_EXH)

// Style Customization
upColor     = input.color(#00f2ff, "Bullish Path Color", group=G_STYLE)
dnColor     = input.color(#ff0055, "Bearish Path Color", group=G_STYLE)
exhColor    = input.color(#ffd700, "Exhaustion/Gold Color", group=G_STYLE)
neuColor    = input.color(#bc13fe, "Metric/Purple Color", group=G_STYLE)

// HUD Configuration
hudPosition = input.string("Top Right", "HUD Location", 
     options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], 
     group=G_HUD)
showHud     = input.bool(true, "Show Diagnostic HUD", group=G_HUD)

// Helper function for HUD position
get_hud_pos(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        => position.top_right

// --- Calculations ---
// Efficiency Ratio (ER)
change      = math.abs(srcInput - srcInput[erLenInput])
volatility  = math.sum(math.abs(srcInput - srcInput[1]), erLenInput)
erSeries    = volatility > 0 ? change / volatility : 0.0
erMA        = ta.sma(erSeries, 14)

// Structural Decay Filter (SDF) 
calculate_sdf(src, er, length, decay, power) =>
    float sumWeights = 0.0
    float sumValues  = 0.0
    for i = 0 to length - 1
        float weight = math.pow(er[i], power) * math.pow(1.0 - decay, i)
        sumValues  += src[i] * weight
        sumWeights += weight
    sumWeights > 0 ? sumValues / sumWeights : src

macroFilter = calculate_sdf(srcInput, erSeries, macroLen, decayInput, powerInput)

// --- Analysis Engine ---
atr = ta.atr(14)
distFromMacro = math.abs(srcInput - macroFilter)

// Core Trend
isUp = macroFilter > macroFilter[1]
trendFlip = ta.change(isUp)

// On-Set Logic
highEfficiency = erSeries >= minEfficiency
efficiencyAccel = erSeries > erSeries[1] 
atBase         = distFromMacro <= (atr * proximityLimit)
priceCross     = ta.crossover(srcInput, macroFilter) or ta.crossunder(srcInput, macroFilter)

runOnSet = (trendFlip or priceCross) and highEfficiency and efficiencyAccel and atBase

// Reactive Spike & Exhaustion Logic
volSurge = ta.tr(true) > (ta.atr(20) * spikeSens)
distGrowth = distFromMacro - distFromMacro[1]
isParabolicSpike = distGrowth > (atr * 0.75) and distFromMacro > (atr * 1.5)

isExhausted = (erSeries < exhThreshold and erSeries < erMA) or 
              (distFromMacro > atr * extremeDist) or 
              (volSurge and distFromMacro > atr * 1.2) or 
              (isParabolicSpike)

exhaustionAlert = isExhausted and not isExhausted[1]

// --- Tactical Visuals ---

// 1. Macro Structural Path
macroColor = isExhausted ? exhColor : (isUp ? upColor : dnColor)
macroPlot = plot(macroFilter, "Macro Structural Path", color=macroColor, linewidth=2)

// 2. Structural Tension Fill
srcPlot = plot(srcInput, "Source", color=color.new(chart.fg_color, 100), display=display.none)
fill(macroPlot, srcPlot, 
     top_value    = math.max(srcInput, macroFilter), 
     bottom_value = math.min(srcInput, macroFilter), 
     top_color    = isUp ? color.new(upColor, 80) : color.new(dnColor, 95), 
     bottom_color = isUp ? color.new(upColor, 95) : color.new(dnColor, 80),
     title        = "Run Tension")

// 3. Action HUD Labels (Chart Screen)
if runOnSet
    label.new(bar_index, isUp ? low : high, 
         text      = isUp ? "◢ INITIATE_RUN_BULL" : "◥ INITIATE_RUN_BEAR", 
         style     = isUp ? label.style_label_up : label.style_label_down,
         color     = #00000000, 
         textcolor = isUp ? upColor : dnColor, 
         size      = size.small)

if exhaustionAlert and volSurge
    label.new(bar_index, isUp ? high : low, 
         text      = "![VOLATILITY_SPIKE]", 
         style     = label.style_label_center,
         color     = #00000000, 
         textcolor = exhColor, 
         size      = size.small)

// 4. Diagnostic HUD (Dashboard)
var table hudTable = table.new(get_hud_pos(hudPosition), 2, 8, bgcolor=color.new(#000000, 40), border_color=color.new(chart.fg_color, 80), border_width=1)

// Track the signal status for the dashboard
var string dashboardSignal = "MONITORING"
var color signalColor = chart.fg_color

if runOnSet
    dashboardSignal := isUp ? "BULL_INITIATE" : "BEAR_INITIATE"
    signalColor := isUp ? upColor : dnColor
else if isExhausted
    dashboardSignal := "EXHAUST_EXIT"
    signalColor := exhColor
else if ta.change(isUp) // Change in direction but no clean entry
    dashboardSignal := "SYNC_LOST"
    signalColor := neuColor

if showHud and barstate.islast
    table.cell(hudTable, 0, 0, "SYSTEM_SYNC", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(hudTable, 1, 0, isExhausted ? "EXHAUSTED" : "MACRO_STABLE", text_color=isExhausted ? exhColor : upColor, text_size=size.tiny)
    
    table.cell(hudTable, 0, 1, "RUN_PRECISION", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(hudTable, 1, 1, str.tostring(math.round(erSeries * 100, 0)) + "%", text_color=erSeries >= minEfficiency ? upColor : exhColor, text_size=size.tiny)
    
    table.cell(hudTable, 0, 2, "BASE_ANCHOR", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(hudTable, 1, 2, str.tostring(math.round(distFromMacro / atr, 2)) + " ATR", text_color=distFromMacro < proximityLimit * atr ? upColor : exhColor, text_size=size.tiny)
    
    table.cell(hudTable, 0, 3, "VOL_RATIO", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(hudTable, 1, 3, str.tostring(math.round(ta.tr(true) / ta.atr(20), 1)) + "x", text_color=volSurge ? exhColor : upColor, text_size=size.tiny)

    table.cell(hudTable, 0, 4, "PARABOLIC_EXH", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(hudTable, 1, 4, isParabolicSpike ? "DANGER_HIGH" : "STABLE", text_color=isParabolicSpike ? exhColor : upColor, text_size=size.tiny)

    // Initiate Run Signal - NEW TO DASHBOARD
    table.cell(hudTable, 0, 5, "LATEST_SIGNAL", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(hudTable, 1, 5, dashboardSignal, text_color=signalColor, text_size=size.tiny)

// --- Alerts ---
if runOnSet
    alert("MACRO_RUN_INITIATED: " + (isUp ? "BULL" : "BEAR") + " on " + syminfo.ticker, alert.freq_once_per_bar_close)

if exhaustionAlert
    alert("CRITICAL_EXHAUSTION detected on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
