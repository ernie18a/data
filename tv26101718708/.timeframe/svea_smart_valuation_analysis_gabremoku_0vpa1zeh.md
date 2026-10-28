# SVEA - Smart Valuation & Analysis [Gabremoku]

- url: https://www.tradingview.com/script/0Vpa1zeh-SVEA-Smart-Valuation-Analysis-Gabremoku/
- type: indicator
- pine_id: PUB;c82301eb96744f4797e3ea5d1fa7f39d
- version: 1.0

## Description

SVEA - Smart Valuation & Analysis [Gabremoku] is a multi-layer technical analysis framework designed to combine adaptive RSI overbought/oversold logic, multi-timeframe confluence, ADX volatility zones, and smart signal visualization into one single chart overlay.

At its core, SVEA uses RSI as the primary valuation engine for detecting overbought and oversold conditions, then expands that logic with adaptive thresholds, asset-specific presets, multi-timeframe confirmation, and ADX-based dynamic price zones. RSI is widely used to spot momentum extremes, but it is often more effective when combined with broader context such as trend strength, volatility, and higher-timeframe confirmation.

The result is a flexible decision-support tool built for traders who want more than a plain oscillator — a full environment for reading exhaustion, confluence, volatility expansion, and reversal potential directly on the chart.

What it shows
📊 Adaptive OB/OS Engine — SVEA uses RSI as the core oscillator and can switch between:

Adaptive thresholds

Auto-detected presets

Equity / Crypto / Forex / 15m presets

Custom levels

Because RSI thresholds often behave differently across instruments and timeframes, adaptive or asset-specific levels can provide more context than rigid 70/30 defaults.

🎯 OB/OS Price Zones — instead of showing only RSI values, the script projects overbought and oversold conditions into visual price bands and event boxes on the chart.

🧠 Multi-Timeframe Confluence — RSI values from the current timeframe plus two higher timeframes are compared in a confluence table, making it easier to identify when conditions align across chart scales. Multi-timeframe RSI is commonly used to improve timing and filter noise.

⚡ ADX Volatility Zones — SVEA combines ADX with Bollinger Band expansion logic to create dynamic top and bottom zones, then generates ADX-based zone-entry signals. ADX is a trend-strength tool, while Bollinger Bands help frame volatility expansion and statistical stretch.

🔺 Adaptive Buy/Sell Signals — buy/sell markers are triggered when RSI exits oversold or overbought conditions, optionally filtered by ADX strength and multi-timeframe confirmation.

🎨 Theme System — choose between a classic look or the Gabremoku visual identity.

Core logic
SVEA is built around four layers:

📉 RSI exhaustion logic — overbought and oversold detection

🧠 adaptive thresholds — levels that adjust with RSI behavior over time

🕒 multi-timeframe confluence — confirmation from higher timeframes

📈 ADX + BB zones — volatility-adjusted structural areas for signal visualization

This is important because RSI alone can remain overbought or oversold for a long time during strong trends, so combining it with ADX and higher-timeframe context helps reduce low-quality reversal signals. RSI is often strongest in ranging environments, while ADX helps identify whether trend conditions are too strong for mean-reversion logic to work cleanly.

Features
✅ RSI-based overbought/oversold framework

✅ Adaptive OB/OS thresholds based on RSI mean and standard deviation

✅ Auto preset detection by asset class and timeframe

✅ Presets for Equity, Crypto, Forex, and 15m charts

✅ Custom OB/OS levels

✅ Continuous or event-based OB/OS price zones

✅ Multi-timeframe RSI confluence table

✅ ADX + Bollinger Band dynamic top/bottom zones

✅ ADX-Buy and ADX-Sell zone-entry signals

✅ Adaptive Buy/Sell signals from RSI exit conditions

✅ Optional ADX confirmation filter

✅ Optional multi-timeframe confirmation filter

✅ Divergence framework inputs and styling foundation

✅ Theme switch between Classic and Gabremoku

✅ Integrated alerts for OB/OS, MTF confluence, and ADX zone signals

How to use
A practical workflow with SVEA is:

🔎 Start with the OB/OS state — determine whether RSI is entering an extreme zone.

🕒 Check the MTF confluence table — if current and higher timeframes align, the setup has stronger context. Multi-timeframe alignment is commonly used to reduce false single-timeframe signals.

📈 Look at ADX conditions — if ADX is high, the market may still be trending strongly, meaning raw RSI reversals can be less reliable. ADX above 25 is often used as a sign of strong trend conditions.

🎯 Use the adaptive buy/sell markers as transition signals when price exits an extreme area rather than blindly reacting to the first OB/OS touch.

Operational suggestion
💡 Suggested trading logic

🔵 Bullish mean-reversion setup: stronger when RSI is oversold, higher timeframes are also oversold or supportive, and price enters the bottom ADX zone. This creates a layered reversal context rather than a single-indicator trigger.

🟨 Bearish mean-reversion setup: stronger when RSI is overbought, higher timeframes confirm the stretch, and price enters the top ADX zone.

⚠️ Strong-trend caution: when ADX is elevated, do not assume every RSI extreme will reverse immediately. A strong ADX often means the current directional move still has strength behind it.

🧠 Best use case: use SVEA as a confluence engine, not as a stand-alone auto-entry tool.

A practical rule:

RSI gives you exhaustion

MTF gives you context

ADX gives you trend strength

Zones give you location

That combination is exactly what makes this script more robust than a standard RSI overlay.

Notes
This script is best described as a technical confluence framework rather than a single-indicator oscillator. It is especially useful for traders who want to visualize when price is statistically stretched, whether that stretch is confirmed across timeframes, and whether trend strength supports or weakens the case for reversal. Confluence-based tools are commonly used to improve selectivity by requiring several conditions to align before acting.

Author: Gabremoku

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("SVEA - Smart Valuation & Analysis [Gabremoku]",  shorttitle='SVEA [Gabremoku]', overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)
//Indicator version 1.4 

// ============================================================================
// INPUTS
// ============================================================================

// About
aboutText = "Smart Valuation & Analysis"
var table aboutTbl = na
if na(aboutTbl)
    aboutTbl := table.new(position.top_right, 1, 2, border_width = 0)

// OB/OS Settings
theme = input.string("Classic", "Theme", options=["Classic", "Gabremoku"], group="Display")
showOBOS = input.bool(true, "Show OB/OS Zones", group="OB/OS")
presetOBOS = input.string("Adaptive", "OB/OS Preset", 
     options=["Adaptive", "Auto", "15m Time-frame", "Equity", "Crypto", "Forex", "Custom"], 
     group="OB/OS")
obLevel = input.float(80, "Overbought Level", minval=50, maxval=100, group="OB/OS")
osLevel = input.float(25, "Oversold Level", minval=0, maxval=50, group="OB/OS")

// Preset constants
presetEquityOB = 80.0
presetEquityOS = 25.0
presetCryptoOB = 72.0
presetCryptoOS = 26.0
presetForexOB = 74.0
presetForexOS = 20.0
preset15mOB = 71.0
preset15mOS = 21.0

obosLength = input.int(14, "OB/OS Length (RSI)", minval=5, group="OB/OS")
ob_event_width = input.int(8, "OB/OS box width (bars)", minval=1, group="OB/OS")

// Display
ob_color = input.color(color.red, "Overbought Color", group="OB/OS")
os_color = input.color(color.green, "Oversold Color", group="OB/OS")
ob_zone_alpha = input.int(85, "OB zone opacity (0-100)", minval=0, maxval=100, group="OB/OS")
os_zone_alpha = input.int(85, "OS zone opacity (0-100)", minval=0, maxval=100, group="OB/OS")



// Continuous zone settings
hideContinuousOBOS = input.bool(false, "Hide Continuous OB/OS Zones", group="OB/OS")
ob_zone_lookback = input.int(20, "OB/OS zone lookback (bars)", minval=1, group="OB/OS")
ob_price_pad = input.float(1.0, "OB/OS price pad (%)", minval=0.0, step=0.1, group="OB/OS")
ob_zone_k = input.float(1.0, "Volatility Multiplier (ATR%)", minval=0.0, step=0.1, group="OB/OS")
atrLength = input.int(14, "ATR Length", minval=1, group="OB/OS")
alwaysShowBands = input.bool(true, "Always show OB/OS bands", group="OB/OS")

// Adaptive Thresholds Settings
adaptiveLookback = input.int(100, "Adaptive Lookback Period", minval=20, maxval=500, group="Adaptive Thresholds")
adaptivePercentile = input.float(75, "Adaptive OB Percentile", minval=60, maxval=95, group="Adaptive Thresholds")
adaptiveSmooth = input.int(12, "Adaptive Smoothing Length", minval=1, maxval=60, group="Adaptive Thresholds")

// Divergences
showDivergences = input.bool(true, "Show Divergences", group="Divergences")
divLookback = input.int(5, "Divergence Lookback", minval=3, maxval=20, group="Divergences")
showBullDiv = input.bool(true, "Show Bullish Divergences", group="Divergences")
showBearDiv = input.bool(true, "Show Bearish Divergences", group="Divergences")
showHiddenDiv = input.bool(true, "Show Hidden Divergences", group="Divergences")
divBullColor = input.color(color.new(color.lime, 0), "Bullish Div Color", group="Divergences")
divBearColor = input.color(color.new(color.red, 0), "Bearish Div Color", group="Divergences")
divHiddenBullColor = input.color(color.new(color.aqua, 0), "Hidden Bull Div Color", group="Divergences")
divHiddenBearColor = input.color(color.new(color.orange, 0), "Hidden Bear Div Color", group="Divergences")

isGabremoku = theme == "Gabremoku"
themeBullColor = isGabremoku ? color.blue : divBullColor
themeBearColor = isGabremoku ? color.yellow : divBearColor
themeHiddenBullColor = isGabremoku ? color.blue : divHiddenBullColor
themeHiddenBearColor = isGabremoku ? color.yellow : divHiddenBearColor
themeOBColor = isGabremoku ? color.yellow : ob_color
themeOSColor = isGabremoku ? color.blue : os_color

// Multi-Timeframe
enableMTF = input.bool(true, "Enable Multi-Timeframe Analysis", group="Multi-Timeframe")
htf1 = input.timeframe("60", "Higher Timeframe 1", group="Multi-Timeframe")
htf2 = input.timeframe("240", "Higher Timeframe 2", group="Multi-Timeframe")
showMTFTable = input.bool(true, "Show MTF Confluence Table", group="Multi-Timeframe")

// Alerts
enableAlerts = input.bool(true, "Enable Alerts", group="Alerts")
alertOnOB = input.bool(true, "Alert on Overbought", group="Alerts")
alertOnOS = input.bool(true, "Alert on Oversold", group="Alerts")
alertOnBullDiv = input.bool(true, "Alert on Bullish Divergence", group="Alerts")
alertOnBearDiv = input.bool(true, "Alert on Bearish Divergence", group="Alerts")
alertOnMTFConfluence = input.bool(true, "Alert on MTF Confluence", group="Alerts")

// ADX Settings
showADXSignals = input.bool(true, "Show ADX Signals", group="ADX Signals")
showBuySellSignals = input.bool(true, "Show Adaptive Buy/Sell Signals", group="ADX Signals")
signalConfirmWithADX = input.bool(false, "Require ADX Strength for Buy/Sell", group="ADX Signals")
signalRequireMTF = input.bool(false, "Require MTF Confluence for Buy/Sell", group="ADX Signals")
bbLength = input.int(20, "BB Length", minval=1, group="ADX Signals")
bbMult = input.float(1.5, "BB StdDev", minval=0.1, step=0.1, group="ADX Signals")
adxLength = input.int(14, "ADX Length", minval=1, group="ADX Signals")
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group="ADX Signals")
adxStrong = input.int(25, "Strong Trend Threshold", minval=1, group="ADX Signals")
adxWeak = input.int(20, "Weak Trend Threshold", minval=1, group="ADX Signals")
adxInfluence = input.float(0.8, "ADX Band Multiplier", minval=0.5, maxval=3.0, step=0.1, group="ADX Signals")
zoneOffset = input.float(1, "Zone Offset from Price", minval=0.0, maxval=3.0, step=0.1, group="ADX Signals")
zoneExpansion = input.float(1, "Zone Width", minval=0.5, maxval=5.0, step=0.1, group="ADX Signals")
smoothLength = input.int(50, "Zone Smoothing Length", minval=10, maxval=200, group="ADX Signals")
signalCooldown = input.int(20, "Signal Cooldown (bars)", minval=5, maxval=100, group="ADX Signals")
adxBuyColor = input.color(color.new(#00ff88, 0), "ADX-Buy Color", group="ADX Signals")
adxSellColor = input.color(color.new(#ff3366, 0), "ADX-Sell Color", group="ADX Signals")

// ============================================================================
// ADX CALCULATIONS AND SIGNALS
// ============================================================================

// ADX Calculation
[diPlus, diMinus, adx] = ta.dmi(adxLength, adxSmooth)
adxNormalized = adx / 100

// ADX-Adjusted Bollinger Bands Calculation
bbBasis = ta.sma(close, bbLength)
bbDev = ta.stdev(close, bbLength)

// Apply ADX multiplier to standard deviation
adxMultiplier = 1 + (adxNormalized * adxInfluence)
bbDevAdjusted = bbMult * bbDev * adxMultiplier

bbUpper = bbBasis + bbDevAdjusted
bbLower = bbBasis - bbDevAdjusted
bbWidth = (bbUpper - bbLower) / bbBasis * 100

// Zone Creation Based on Bollinger Bands
// Smooth the BB values for zone positioning
bbUpperSmooth = ta.sma(bbUpper, smoothLength)
bbLowerSmooth = ta.sma(bbLower, smoothLength)
bbRangeSmooth = bbUpperSmooth - bbLowerSmooth

// Calculate offset distance
offsetDistance = bbRangeSmooth * zoneOffset

// Top zone - starts offset distance above upper BB, then expands outward
topZoneBottom = bbUpperSmooth + offsetDistance
topZoneTop = topZoneBottom + (bbRangeSmooth * zoneExpansion)

// Bottom zone - starts offset distance below lower BB, then expands outward
bottomZoneTop = bbLowerSmooth - offsetDistance
bottomZoneBottom = bottomZoneTop - (bbRangeSmooth * zoneExpansion)

// Signal Logic - Zone Detection and State Tracking
// Define zones more clearly
priceInTopZone = close > topZoneBottom
priceInBottomZone = close < bottomZoneTop
priceInNeutralZone = close <= topZoneBottom and close >= bottomZoneTop

// State tracking
var int lastADXBuySignalBar = -999
var int lastADXSellSignalBar = -999

// ADX-Buy signal when entering bottom zone (oversold)
adxBuySignal = priceInBottomZone and not priceInBottomZone[1] and (bar_index - lastADXBuySignalBar >= signalCooldown)

// ADX-Sell signal when entering top zone (overbought)
adxSellSignal = priceInTopZone and not priceInTopZone[1] and (bar_index - lastADXSellSignalBar >= signalCooldown)

// Update last signal bars
if adxBuySignal
    lastADXBuySignalBar := bar_index
    
if adxSellSignal
    lastADXSellSignalBar := bar_index

// ============================================================================
// ADAPTIVE THRESHOLDS CALCULATION
// ============================================================================

// Calcolo adaptive thresholds basato su deviazione standard RSI
rsiForAdaptive = ta.rsi(close, obosLength)

// Calcola media e deviazione standard RSI
rsiMean = ta.sma(rsiForAdaptive, adaptiveLookback)
rsiStdDev = ta.stdev(rsiForAdaptive, adaptiveLookback)

// Calcola livelli basati su deviazioni standard dalla media
// Più volatilità = livelli più larghi, meno volatilità = livelli più stretti
stdMultiplier = (adaptivePercentile - 50) / 25  // converte 75 in ~1.0

rawAdaptiveOB = rsiMean + (rsiStdDev * stdMultiplier)
rawAdaptiveOS = rsiMean - (rsiStdDev * stdMultiplier)

// Applica limiti ragionevoli (min 68-max 85 per OB, min 15-max 32 per OS)
boundedAdaptiveOB = math.max(68, math.min(85, rawAdaptiveOB))
boundedAdaptiveOS = math.max(15, math.min(32, rawAdaptiveOS))

// Smoothing per evitare cambiamenti troppo bruschi
var float smoothedAdaptiveOB = 75.0
var float smoothedAdaptiveOS = 25.0

smoothedAdaptiveOB := ta.ema(boundedAdaptiveOB, adaptiveSmooth)
smoothedAdaptiveOS := ta.ema(boundedAdaptiveOS, adaptiveSmooth)

// ============================================================================
// OSCILLATOR AND PRESET DETECTION
// ============================================================================

obosOsc = ta.rsi(close, obosLength)

// Auto detection
isDetectedCrypto = (syminfo.type == "crypto")
isDetectedForex = (syminfo.type == "forex")
isDetected15m = timeframe.isintraday and (timeframe.multiplier == 15)
detectedPreset = isDetected15m ? "15m Time-frame" : (isDetectedCrypto ? "Crypto" : (isDetectedForex ? "Forex" : "Equity"))
effectivePreset = presetOBOS == "Auto" ? detectedPreset : presetOBOS

// Choose runtime levels based on effective preset
obLevelUsed = effectivePreset == "Adaptive" ? smoothedAdaptiveOB : 
     (effectivePreset == "Custom" ? obLevel : 
     (effectivePreset == "Crypto" ? presetCryptoOB : 
     (effectivePreset == "Forex" ? presetForexOB : 
     (effectivePreset == "15m Time-frame" ? preset15mOB : presetEquityOB))))

osLevelUsed = effectivePreset == "Adaptive" ? smoothedAdaptiveOS : 
     (effectivePreset == "Custom" ? osLevel : 
     (effectivePreset == "Crypto" ? presetCryptoOS : 
     (effectivePreset == "Forex" ? presetForexOS : 
     (effectivePreset == "15m Time-frame" ? preset15mOS : presetEquityOS))))

isOverbought = obosOsc > obLevelUsed
isOversold = obosOsc < osLevelUsed

// Display preset info
displayPreset = presetOBOS == "Auto" ? "Auto -> " + detectedPreset : presetOBOS
presetText = "Preset: " + displayPreset + "  (OB=" + str.tostring(obLevelUsed, "#.#") + " OS=" + str.tostring(osLevelUsed, "#.#") + ")"

table.cell(aboutTbl, 0, 0, text = aboutText, text_color = color.white, bgcolor = color.new(color.black, 85))
table.cell(aboutTbl, 0, 1, text = presetText, text_color = color.white, bgcolor = color.new(color.gray, 80))

// ============================================================================
// MULTI-TIMEFRAME ANALYSIS
// ============================================================================

htf1_rsi = request.security(syminfo.tickerid, htf1, ta.rsi(close, obosLength), lookahead=barmerge.lookahead_off)
htf2_rsi = request.security(syminfo.tickerid, htf2, ta.rsi(close, obosLength), lookahead=barmerge.lookahead_off)

htf1_ob = htf1_rsi > obLevelUsed
htf1_os = htf1_rsi < osLevelUsed
htf2_ob = htf2_rsi > obLevelUsed
htf2_os = htf2_rsi < osLevelUsed

// Confluence detection
mtfBullishConfluence = isOversold and htf1_os and htf2_os
mtfBearishConfluence = isOverbought and htf1_ob and htf2_ob
mtfBullishConfirm = htf1_os and htf2_os
mtfBearishConfirm = htf1_ob and htf2_ob

// Buy/Sell signal conditions
exitOversold = ta.crossover(obosOsc, osLevelUsed)
exitOverbought = ta.crossunder(obosOsc, obLevelUsed)
wasInBottomZone = priceInBottomZone[1] or isOversold[1]
wasInTopZone = priceInTopZone[1] or isOverbought[1]
validADXSignal = not signalConfirmWithADX or adx > adxStrong
validMTFBuy = not signalRequireMTF or mtfBullishConfirm
validMTFSell = not signalRequireMTF or mtfBearishConfirm
buySignal = showBuySellSignals and exitOversold and wasInBottomZone and validADXSignal and validMTFBuy
sellSignal = showBuySellSignals and exitOverbought and wasInTopZone and validADXSignal and validMTFSell

// MTF Table
var table mtfTbl = na
if enableMTF and showMTFTable and na(mtfTbl)
    mtfTbl := table.new(position.bottom_right, 3, 4, border_width=1)
    // Headers
    table.cell(mtfTbl, 0, 0, "Timeframe", bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(mtfTbl, 1, 0, "RSI", bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(mtfTbl, 2, 0, "Status", bgcolor=color.new(color.gray, 70), text_color=color.white)

if enableMTF and showMTFTable and not na(mtfTbl)
    // Current TF
    ctfStatus = isOverbought ? "OB" : (isOversold ? "OS" : "Neutral")
    ctfColor = isOverbought ? color.new(themeBearColor, 70) : (isOversold ? color.new(themeBullColor, 70) : color.new(color.gray, 85))
    table.cell(mtfTbl, 0, 1, timeframe.period, text_color=color.white)
    table.cell(mtfTbl, 1, 1, str.tostring(obosOsc, "#.#"), text_color=color.white)
    table.cell(mtfTbl, 2, 1, ctfStatus, bgcolor=ctfColor, text_color=color.white)
    
    // HTF1
    htf1Status = htf1_ob ? "OB" : (htf1_os ? "OS" : "Neutral")
    htf1Color = htf1_ob ? color.new(themeBearColor, 70) : (htf1_os ? color.new(themeBullColor, 70) : color.new(color.gray, 85))
    table.cell(mtfTbl, 0, 2, htf1, text_color=color.white)
    table.cell(mtfTbl, 1, 2, str.tostring(htf1_rsi, "#.#"), text_color=color.white)
    table.cell(mtfTbl, 2, 2, htf1Status, bgcolor=htf1Color, text_color=color.white)
    
    // HTF2
    htf2Status = htf2_ob ? "OB" : (htf2_os ? "OS" : "Neutral")
    htf2Color = htf2_ob ? color.new(themeBearColor, 70) : (htf2_os ? color.new(themeBullColor, 70) : color.new(color.gray, 85))
    table.cell(mtfTbl, 0, 3, htf2, text_color=color.white)
    table.cell(mtfTbl, 1, 3, str.tostring(htf2_rsi, "#.#"), text_color=color.white)
    table.cell(mtfTbl, 2, 3, htf2Status, bgcolor=htf2Color, text_color=color.white)

// ============================================================================
// DIVERGENCES DETECTION
// ============================================================================

// Find pivots
ph = ta.pivothigh(obosOsc, divLookback, divLookback)
pl = ta.pivotlow(obosOsc, divLookback, divLookback)
phPrice = ta.pivothigh(high, divLookback, divLookback)
plPrice = ta.pivotlow(low, divLookback, divLookback)

// Store pivot data
var float lastPivotHighRSI = na
var float lastPivotHighPrice = na
var int lastPivotHighBar = na

var float lastPivotLowRSI = na
var float lastPivotLowPrice = na
var int lastPivotLowBar = na


// Detect Regular Bearish Divergence (price higher high, RSI lower high)
//regularBearishDiv = false
//if showDivergences and showBearDiv and not na(ph) and not na(lastPivotHighRSI)
//    if phPrice > lastPivotHighPrice and ph < lastPivotHighRSI
//        regularBearishDiv := true
//        line.new(lastPivotHighBar, lastPivotHighPrice, bar_index - divLookback, phPrice, 
//                color=themeBearColor, width=1, style=line.style_dashed)
//            label.new(bar_index - divLookback, phPrice, "Bear Div", 
//                style=label.style_label_down, color=themeBearColor, textcolor=color.white, size=size.small)
//    if plPrice < lastPivotLowPrice and pl > lastPivotLowRSI
//        regularBullishDiv := true
//        line.new(lastPivotLowBar, lastPivotLowPrice, bar_index - divLookback, plPrice, 
//                color=themeBullColor, width=1, style=line.style_dashed)
//            label.new(bar_index - divLookback, plPrice, "Bull Div", 
//                style=label.style_label_up, color=themeBullColor, textcolor=color.white, size=size.small)
//    if phPrice < lastPivotHighPrice and ph > lastPivotHighRSI
//        hiddenBearishDiv := true
//        line.new(lastPivotHighBar, lastPivotHighPrice, bar_index - divLookback, phPrice, 
//                color=themeHiddenBearColor, width=1, style=line.style_dotted)
//            label.new(bar_index - divLookback, phPrice, "Hidden Bear", 
//                style=label.style_label_down, color=themeHiddenBearColor, textcolor=color.white, size=size.tiny)
//    if plPrice > lastPivotLowPrice and pl < lastPivotLowRSI
//        hiddenBullishDiv := true
//        line.new(lastPivotLowBar, lastPivotLowPrice, bar_index - divLookback, plPrice, 
//               color=themeHiddenBullColor, width=1, style=line.style_dotted)
//            label.new(bar_index - divLookback, plPrice, "Hidden Bull", 
//                style=label.style_label_up, color=themeHiddenBullColor, textcolor=color.white, size=size.tiny)
//    lastPivotHighPrice := phPrice
//    lastPivotHighBar := bar_index - divLookback

if not na(pl)
    lastPivotLowRSI := pl
    lastPivotLowPrice := plPrice
    lastPivotLowBar := bar_index - divLookback

// ============================================================================
// OB/OS ZONES VISUALIZATION
// ============================================================================

atr = ta.atr(atrLength)
volPct = atr / close * 100.0
padPct = ob_price_pad + ob_zone_k * volPct

var box obBox = na
var box osBox = na

if showOBOS
    if hideContinuousOBOS
        left = math.max(1, bar_index - ob_zone_lookback + 1)
        right = bar_index + 1
        obTop = ta.highest(high, ob_zone_lookback) * (1 + padPct / 100.0)
        obBottom = ta.highest(high, 1) * (1 - padPct / 100.0)
        osTop = ta.lowest(low, 1) * (1 + padPct / 100.0)
        osBottom = ta.lowest(low, ob_zone_lookback) * (1 - padPct / 100.0)

        if isOverbought or alwaysShowBands
            if na(obBox)
                obBox := box.new(left, obTop, right, obBottom, 
                     bgcolor=color.new(themeOBColor, ob_zone_alpha), 
                     border_color=color.new(themeOBColor, math.max(ob_zone_alpha - 10, 0)))
            else
                box.set_left(obBox, left)
                box.set_right(obBox, right)
                box.set_top(obBox, obTop)
                box.set_bottom(obBox, obBottom)
        else
            if not na(obBox)
                box.delete(obBox)
                obBox := na

        if isOversold or alwaysShowBands
            if na(osBox)
                osBox := box.new(left, osTop, right, osBottom, 
                     bgcolor=color.new(themeOSColor, os_zone_alpha), 
                     border_color=color.new(themeOSColor, math.max(os_zone_alpha - 10, 0)))
            else
                box.set_left(osBox, left)
                box.set_right(osBox, right)
                box.set_top(osBox, osTop)
                box.set_bottom(osBox, osBottom)
        else
            if not na(osBox)
                box.delete(osBox)
                osBox := na
    else
        if isOverbought and not isOverbought[1]
            l = bar_index
            r = bar_index + ob_event_width
            top = high * (1 + ob_price_pad / 100.0)
            bottom = low * (1 - ob_price_pad / 100.0)
            box.new(l, top, r, bottom, 
                 bgcolor=color.new(themeOBColor, ob_zone_alpha), 
                 border_color=color.new(themeOBColor, math.max(ob_zone_alpha - 10, 0)))
        if isOversold and not isOversold[1]
            l = bar_index
            r = bar_index + ob_event_width
            top = high * (1 + ob_price_pad / 100.0)
            bottom = low * (1 - ob_price_pad / 100.0)
            box.new(l, top, r, bottom, 
                 bgcolor=color.new(themeOSColor, os_zone_alpha), 
                 border_color=color.new(themeOSColor, math.max(os_zone_alpha - 10, 0)))

// ============================================================================
// ALERTS SYSTEM
// ============================================================================

// Track state changes to trigger alerts only once
var bool wasOverbought = false
var bool wasOversold = false

obEntry = isOverbought and not wasOverbought
osEntry = isOversold and not wasOversold

wasOverbought := isOverbought
wasOversold := isOversold

// Create alert conditions
if enableAlerts
    if alertOnOB and obEntry
        alert("SVEA: Overbought zone entered - RSI: " + str.tostring(obosOsc, "#.##"), alert.freq_once_per_bar)
    
    if alertOnOS and osEntry
        alert("SVEA: Oversold zone entered - RSI: " + str.tostring(obosOsc, "#.##"), alert.freq_once_per_bar)
    
//    if alertOnBullDiv and regularBullishDiv
//        alert("SVEA: Bullish Divergence detected!", alert.freq_once_per_bar)
    
//    if alertOnBearDiv and regularBearishDiv
//        alert("SVEA: Bearish Divergence detected!", alert.freq_once_per_bar)
    
    if alertOnMTFConfluence and mtfBullishConfluence
        alert("SVEA: Multi-Timeframe BULLISH Confluence - All TFs Oversold!", alert.freq_once_per_bar)
    
    if alertOnMTFConfluence and mtfBearishConfluence
        alert("SVEA: Multi-Timeframe BEARISH Confluence - All TFs Overbought!", alert.freq_once_per_bar)

// Plot shapes for visual confirmation of signals (solo divergenze)
//plotshape(regularBullishDiv, "Bull Div", shape.triangleup, location.belowbar, themeBullColor, size=size.small)
//plotshape(regularBearishDiv, "Bear Div", shape.triangledown, location.abovebar, themeBearColor, size=size.small)

// ============================================================================
// ADX SIGNAL VISUALIZATION
// ============================================================================

// ADX Alerts
if enableAlerts and showADXSignals
    if adxBuySignal
        alert("SVEA: ADX-Buy Signal - Price Entered Bottom Zone (Oversold)", alert.freq_once_per_bar)
    
    if adxSellSignal
        alert("SVEA: ADX-Sell Signal - Price Entered Top Zone (Overbought)", alert.freq_once_per_bar)

// Modern Aesthetic Visualization (Tech Crystal Design)
// Complex geometric markers: Layered Diamonds for a "Jewel/Tech" look

// Colors
signalBullColor = isGabremoku ? color.blue : #00E5FF
signalBearColor = isGabremoku ? color.yellow : #FF0055

// Calculate dynamic positions for overlapping effect
atrViz = ta.atr(14)
crystalOffset = atrViz * 0.1  // Gap from candle
crystalOverlap = atrViz * 0.15 // Offset between the two diamonds

// Buy Signal Prices
buyOuterY = low - crystalOffset
buyInnerY = buyOuterY - crystalOverlap // Inner shifted slightly down/outward

// Sell Signal Prices
sellOuterY = high + crystalOffset
sellInnerY = sellOuterY + crystalOverlap // Inner shifted slightly up/outward

// Buy Signal Visuals
plotshape(showADXSignals and adxBuySignal ? buyOuterY : na, "Buy Crystal Outer", shape.diamond, location.absolute, color.new(signalBullColor, 50), size=size.small)
plotshape(showADXSignals and adxBuySignal ? buyInnerY : na, "Buy Crystal Inner", shape.diamond, location.absolute, signalBullColor, size=size.tiny)

// Sell Signal Visuals
plotshape(showADXSignals and adxSellSignal ? sellOuterY : na, "Sell Crystal Outer", shape.diamond, location.absolute, color.new(signalBearColor, 50), size=size.small)
plotshape(showADXSignals and adxSellSignal ? sellInnerY : na, "Sell Crystal Inner", shape.diamond, location.absolute, signalBearColor, size=size.tiny)

// Buy/Sell Signal Visuals
plotshape(buySignal, "Adaptive Buy", shape.triangleup, location.belowbar, color.new(signalBullColor, 0), size=size.tiny)
plotshape(sellSignal, "Adaptive Sell", shape.triangledown, location.abovebar, color.new(signalBearColor, 0), size=size.tiny)

// Bar Coloring - Azure for Buy, Black for Sell (Void Candle effect)
signalSellBarColor = isGabremoku ? signalBearColor : color.black
barcolor(showADXSignals and (adxBuySignal or adxSellSignal) ? (adxBuySignal ? signalBullColor : signalSellBarColor) : na)
````
