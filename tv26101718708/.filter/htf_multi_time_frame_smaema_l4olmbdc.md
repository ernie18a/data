# HTF Multi Time Frame SMA/EMA

- url: https://www.tradingview.com/script/L4OlmBdc-HTF-Multi-Time-Frame-SMA-EMA/
- type: indicator
- pine_id: PUB;58436ceb6ac74a43bde38774840dddf1
- version: 1.0

## Description

This open-source indicator tracks Higher Timeframe (HTF) Moving Averages (supporting both SMA and EMA calculations) directly from your lower timeframe chart, using optimized, non-repainting real-time requests. It features a customizable Visual Smoothing Engine that allows traders to choose between a classic "Standard Step" line or a fluid, gaps-aligned "Smoothed Linear" bridge across higher timeframe data gaps. The script tracks trend direction through dynamic color shifts based on the HTF line's real-time slope and includes togglable Bullish and Bearish Breakout signals (hidden by default) that trigger when the current price crosses the HTF boundary. Designed for clean risk assessment, this utility provides multi-timeframe structural clarity without cluttering your layout.

## Source Code

````pine
// © Mozilla Public License 2.0
// © fxtraderanthony

//@version=6
indicator("HTF Multi Time Frame SMA/EMA", overlay=true, precision=4)

// ==========================================
// 1. INPUTS
// ==========================================
var string G_MA    = "Base Moving Average Settings"
var string G_SMOOTH = "Visual Smoothing Settings"
var string G_HTF   = "Timeframe Settings"

// Base MA Settings (Defaulted to SMA 50)
maType   = input.string("SMA", title="Base MA Type", options=["SMA", "EMA"], group=G_MA)
maLength = input.int(50, title="Base MA Length", minval=1, group=G_MA)
maSource = input.source(close, title="Source", group=G_MA)

// Smoothing Selection
useSmoothing = input.string("Smoothed (Linear)", title="Line Style", options=["Standard (Step)", "Smoothed (Linear)"], group=G_SMOOTH)

// Timeframe Settings
htfString = input.timeframe("60", title="Higher Timeframe", 
     options=["5", "15", "30", "60", "240", "D"], group=G_HTF)

// ==========================================
// 2. LOGIC CALCULATIONS
// ==========================================

// Reusable function to calculate MA types
get_ma(src, len, type) =>
    type == "SMA" ? ta.sma(src, len) : ta.ema(src, len)

// Calculate the base MA on the current timeframe
localMaValue = get_ma(maSource, maLength, maType)

// --- THE SMOOTHING ENGINE ---
// Standard Mode: gaps_off creates a stair-step line
// Smoothed Mode: gaps_on returns 'na' between HTF updates, forcing a smooth linear connection
gapSetting = useSmoothing == "Smoothed (Linear)" ? barmerge.gaps_on : barmerge.gaps_off

// Fetch HTF data safely (Set to equal current real-time bar by default)
finalMaValue = request.security(syminfo.tickerid, htfString, localMaValue, gapSetting, barmerge.lookahead_off)

// ==========================================
// 3. COLOR & SIGNAL LOGIC
// ==========================================

// Track the last non-na value for processing backend calculations and colors.
stableMaValue = ta.valuewhen(not na(finalMaValue), finalMaValue, 0)

// Determine trend color based on the slope of the stable MA line
lineColor = color.silver
if stableMaValue > stableMaValue[1]
    lineColor := color.green
else if stableMaValue < stableMaValue[1]
    lineColor := color.red

// Signal triggers when the current close crosses the stable HTF MA
buySignal  = ta.crossover(close, stableMaValue)
sellSignal = ta.crossunder(close, stableMaValue)

// ==========================================
// 4. PLOTTING & VISUALS
// ==========================================

// Plot the HTF Moving Average line (MODIFIED: linewidth changed to 1)
plot(finalMaValue, title="HTF MA Line", color=lineColor, linewidth=1, style=plot.style_line)

// Plot Shapes for Entry Signals (Hidden by default via display.none per user preference)
plotshape(buySignal,  title="Bullish Breakout", style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.tiny, display=display.none)
plotshape(sellSignal, title="Bearish Breakout", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.tiny, display=display.none)

// ==========================================
// 5. ALERTS
// ==========================================

if buySignal
    alert("MTF Ultra-Smooth " + maType + " Bullish Cross!", alert.freq_once_per_bar_close)

if sellSignal
    alert("MTF Ultra-Smooth " + maType + " Bearish Cross!", alert.freq_once_per_bar_close)
````
