# Tri-Vector Flow Predictor 

- url: https://www.tradingview.com/script/jdSbQ0r6-Tri-Vector-Flow-Predictor/
- type: indicator
- pine_id: PUB;ed7c1820a3a24270a9f31f8a551611a9
- version: 2.0

## Description

Tri-Vector Flow Predictor v3.2 is an adaptive directional trading indicator designed to help traders read the next probable price movement with clean visuals and structured signal logic.

This tool combines trend, volatility, market structure, liquidity sweeps, Fair Value Gap impulses, compression breakouts, volume pressure, regression quality, and multi-timeframe confirmation into one visual decision-support engine.

The goal is not to predict the future with certainty. The goal is to organize multiple important market conditions into one clean framework so traders can better understand when price may continue, reverse, expand, or lose momentum.

What the indicator includes:

* Adaptive fused trend core
* Value cloud around fair price
* Pulse rail for trend and invalidation structure
* Long and short entry signals
* Long and short exit signals
* One-entry / one-exit trade state logic
* Liquidity sweep detection
* Structure break and retest logic
* Fair Value Gap impulse detection
* Multi-timeframe trend agreement
* Regression-based forecast quality
* Next-move prediction cone
* Risk / reward projection with entry, invalidation, TP1, and TP2
* Clean dashboard showing bias, trigger, prediction, regime, scores, MTF stack, and regression quality

How to use it:

Use the LONG and SHORT labels as the main directional signal markers. The signal is not based on one condition only. It requires trigger logic, score confirmation, filtering, and directional dominance.

The EXIT L and EXIT S labels show the internal exit logic for the active virtual trade state. Exits can occur from an opposite signal, invalidation hit, TP2, or confidence loss.

The prediction cone is a probabilistic visual guide. It shows where price may move next based on the current flow vector, volatility, score dominance, trend pressure, MTF context, and regression quality. It should not be treated as a guaranteed target.

The Pulse Rail can be used as an adaptive structure line. When price holds above it, bullish structure is stronger. When price holds below it, bearish structure is stronger.

The Value Cloud helps identify whether price is near fair value or extended. Signals near value are usually cleaner. Signals very far from value can be late unless strong impulse conditions are present.

Recommended settings:

For scalping:
Use Fast mode with Clean or Minimal visuals.

For day trading:
Use Balanced mode with MTF Stack enabled.

For swing trading:
Use Precision mode with MTF Stack enabled.

For screenshots and deeper analysis:
Use Full visual density.

Honest limitations:

This indicator does not know the future. It cannot guarantee the next price movement. It can produce losing signals during chop, news events, low liquidity, fakeouts, abnormal spreads, and sudden volatility shocks.

The prediction cone is an estimation, not a promise.

This tool is best used as a confluence engine together with market structure, higher-timeframe direction, liquidity zones, and proper risk management.

For safer behavior, keep Confirm Signals On Candle Close enabled.



  
Honest Opinion / Carefully Read 

Tri-Vector Flow Predictor v3.2 is designed as a clean decision-support engine, not a perfect signal system.

Its strongest feature is the one-entry / one-exit trade state. Instead of spamming repeated labels, it shows a clearer flow: LONG entry, LONG exit, SHORT entry, and SHORT exit.

The indicator combines trend, volatility, structure, liquidity sweeps, FVG impulses, retests, volume pressure, regression quality, and MTF agreement to estimate the probable next move.

The prediction cone is only a probabilistic guide. It is not a guaranteed future price path. Price can still move against the forecast during chop, news, fakeouts, low liquidity, or sudden volatility.

This tool is best used as confluence with market structure, higher-timeframe direction, liquidity zones, and proper risk management.

Use it as a trading assistant, not as financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IlSeparatio369

//@version=6
indicator("Tri-Vector Flow Predictor v3.3", "Tri-Vector Predictor v3.3", overlay = true, max_lines_count = 500, max_labels_count = 400, max_boxes_count = 220, max_bars_back = 5000, dynamic_requests = true, precision = 4)

//------------------------------------------------------------------------------
// README / PUBLICATION NOTES
//------------------------------------------------------------------------------
// TRI-VECTOR FLOW PREDICTOR v3.3
//
// WHAT THIS INDICATOR DOES
// This indicator is a discretionary decision-support tool designed to estimate
// the probable next directional price movement. It combines multiple market
// conditions into one clean visual engine:
//
// 1. Adaptive trend direction from a fused core.
// 2. Volatility-adjusted pulse rail.
// 3. Momentum and directional pressure.
// 4. Liquidity sweep detection.
// 5. Breakout and compression ignition logic.
// 6. Confirmed structure breaks.
// 7. Structure retest entries.
// 8. Fair Value Gap impulse detection.
// 9. Multi-timeframe trend agreement.
// 10. Regression-based forecast quality.
// 11. Volume pressure and candle quality.
// 12. One-entry / one-exit trade state logic.
//
// v3.3 VISUAL REFINEMENT
// - Hybrid smaller signal labels.
// - Smaller professional dashboard table text.
// - Hybrid locked prediction cone.
// - Forecast display no longer chases every tick.
// - Prediction refreshes only on important events or timed confirmed refresh.
//
// IMPORTANT HONEST LIMITATIONS
// This indicator does not know the future.
// The prediction cone is probabilistic, not guaranteed.
// Use this as a confluence and decision-support tool, not as financial advice.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Groups
//------------------------------------------------------------------------------
groupPreset  = "Preset / Adaptation"
groupCore    = "Core Engine"
groupSignal  = "Signal Logic"
groupFilter  = "Accuracy Filters"
groupMTF     = "Multi-Timeframe Filter"
groupStruct  = "Structure / Liquidity"
groupPredict = "Next Price Prediction"
groupTrade   = "One Entry / One Exit Engine"
groupVisual  = "Clean Visuals"
groupDash    = "Dashboard"
groupAlert   = "Alerts"

//------------------------------------------------------------------------------
// Preset / Adaptation
//------------------------------------------------------------------------------
mode = input.string("Balanced", "Signal Mode", options = ["Fast", "Balanced", "Precision", "Manual"], group = groupPreset, tooltip = "Fast reacts earlier. Balanced is the recommended default. Precision gives fewer but stricter signals. Manual uses custom values.")
marketPreset = input.string("Auto", "Market Profile", options = ["Auto", "Crypto", "Forex", "Indices", "Metals", "Stocks", "Universal"], group = groupPreset, tooltip = "Auto detects the symbol type when possible. The profile adjusts volatility, score strictness, and signal tolerance.")
useAutoTFAdapt = input.bool(true, "Use Auto Timeframe Adaptation", group = groupPreset, tooltip = "When ON, the engine becomes faster on small intraday charts and stricter on higher timeframes.")

manualCoreLen  = input.int(24, "Manual Core Length", minval = 2, maxval = 200, group = groupPreset, tooltip = "Used only in Manual mode. Controls the main fused core length.")
manualVolLen   = input.int(14, "Manual Volatility Length", minval = 1, maxval = 100, group = groupPreset, tooltip = "Used only in Manual mode. Controls volatility normalization.")
manualAdxLen   = input.int(14, "Manual ADX Length", minval = 2, maxval = 100, group = groupPreset, tooltip = "Used only in Manual mode. Controls directional movement scoring.")
manualErLen    = input.int(14, "Manual Efficiency Length", minval = 2, maxval = 100, group = groupPreset, tooltip = "Used only in Manual mode. Controls efficiency and anti-chop scoring.")
manualMinScore = input.float(80.0, "Manual Minimum Signal Score", minval = 0.0, maxval = 100.0, step = 1.0, group = groupPreset, tooltip = "Used only in Manual mode. Higher values reduce signal frequency.")

baseCore = mode == "Fast" ? 16 : mode == "Balanced" ? 24 : mode == "Precision" ? 34 : manualCoreLen
baseVol  = mode == "Fast" ? 9 : mode == "Balanced" ? 14 : mode == "Precision" ? 18 : manualVolLen
baseAdx  = mode == "Fast" ? 10 : mode == "Balanced" ? 14 : mode == "Precision" ? 18 : manualAdxLen
baseEr   = mode == "Fast" ? 10 : mode == "Balanced" ? 14 : mode == "Precision" ? 18 : manualErLen
baseMin  = mode == "Fast" ? 72.0 : mode == "Balanced" ? 80.0 : mode == "Precision" ? 88.0 : manualMinScore

tfFast = timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5)
tfMid = timeframe.isminutes and timeframe.multiplier > 5 and timeframe.multiplier <= 60
tfHigh = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly

tfLenK = not useAutoTFAdapt ? 1.00 : tfFast ? 0.82 : tfMid ? 0.92 : tfHigh ? 1.16 : 1.00
tfScoreAdj = not useAutoTFAdapt ? 0.0 : tfFast ? -2.0 : tfMid ? -1.0 : tfHigh ? 3.0 : 0.0

tickerUpper = str.upper(syminfo.ticker)
autoProfile = syminfo.type == "crypto" or str.contains(tickerUpper, "BTC") or str.contains(tickerUpper, "ETH") ? "Crypto" :
     syminfo.type == "forex" ? "Forex" :
     str.contains(tickerUpper, "XAU") or str.contains(tickerUpper, "GOLD") or str.contains(tickerUpper, "SILVER") ? "Metals" :
     syminfo.type == "index" or str.contains(tickerUpper, "US100") or str.contains(tickerUpper, "NAS") or str.contains(tickerUpper, "SPX") or str.contains(tickerUpper, "US500") ? "Indices" :
     syminfo.type == "stock" ? "Stocks" : "Universal"

profile = marketPreset == "Auto" ? autoProfile : marketPreset

profileVolK = profile == "Crypto" ? 1.12 : profile == "Forex" ? 0.88 : profile == "Indices" ? 1.00 : profile == "Metals" ? 1.08 : profile == "Stocks" ? 1.02 : 1.00
profileScoreAdj = profile == "Crypto" ? 1.0 : profile == "Forex" ? 2.0 : profile == "Indices" ? 0.0 : profile == "Metals" ? 1.0 : profile == "Stocks" ? 1.0 : 0.0

coreLen = math.max(2, int(math.round(baseCore * tfLenK)))
volLen = math.max(1, int(math.round(baseVol * tfLenK)))
adxLen = math.max(2, int(math.round(baseAdx * tfLenK)))
erLen = math.max(2, int(math.round(baseEr * tfLenK)))
minScore = baseMin + profileScoreAdj + tfScoreAdj

//------------------------------------------------------------------------------
// Core Inputs
//------------------------------------------------------------------------------
src = input.source(hlc3, "Source", group = groupCore, tooltip = "Main calculation source. HLC3 is smoother. Close is stricter.")
confirmOnClose = input.bool(true, "Confirm Signals On Candle Close", group = groupCore, tooltip = "When ON, signals print only after candle close. This reduces intrabar flipping.")
valueWidth = input.float(0.70, "Value Cloud Width", minval = 0.10, maxval = 5.0, step = 0.05, group = groupCore, tooltip = "Width of the inner value cloud around the fused core.")
outerWidth = input.float(1.25, "Outer Cloud Width", minval = 0.20, maxval = 8.0, step = 0.05, group = groupCore, tooltip = "Width of the outer value cloud. This shows extension risk.")
railDistance = input.float(1.45, "Pulse Rail Distance", minval = 0.20, maxval = 10.0, step = 0.05, group = groupCore, tooltip = "Distance of the adaptive pulse rail from the fused core.")
minEfficiency = input.float(0.22, "Minimum Efficiency Ratio", minval = 0.0, maxval = 1.0, step = 0.01, group = groupCore, tooltip = "Higher values block chop. Lower values allow faster but noisier signals.")

//------------------------------------------------------------------------------
// Signal Logic
//------------------------------------------------------------------------------
setupBars = input.int(20, "Pulse Setup Memory", minval = 3, maxval = 200, group = groupSignal, tooltip = "Bars used to remember a valid pullback before a reclaim signal.")
pullbackPhase = input.float(0.55, "Required Pullback Phase", minval = 0.10, maxval = 5.0, step = 0.05, group = groupSignal, tooltip = "How deep price must pull back into value before a PULSE signal.")
rangeLen = input.int(34, "Ignition Range Length", minval = 8, maxval = 300, group = groupSignal, tooltip = "Lookback range used for compression breakout signals.")
compressionMax = input.float(4.20, "Maximum Compression Width", minval = 1.0, maxval = 20.0, step = 0.10, group = groupSignal, tooltip = "Range width divided by volatility. Lower values are stricter.")
breakBuffer = input.float(0.10, "Breakout Buffer", minval = 0.0, maxval = 3.0, step = 0.01, group = groupSignal, tooltip = "Extra volatility buffer required beyond compression range or structure levels.")
sweepLen = input.int(22, "Sweep Lookback", minval = 5, maxval = 300, group = groupSignal, tooltip = "Lookback used for liquidity sweep reversal signals.")
sweepBuffer = input.float(0.05, "Sweep Buffer", minval = 0.0, maxval = 3.0, step = 0.01, group = groupSignal, tooltip = "Extra volatility buffer beyond recent high or low for sweep detection.")
minDisplacement = input.float(0.42, "Minimum Displacement", minval = 0.05, maxval = 3.0, step = 0.01, group = groupSignal, tooltip = "Minimum candle body size in volatility units for impulse signals.")
scoreEdge = input.float(9.0, "Minimum Score Dominance", minval = 0.0, maxval = 40.0, step = 1.0, group = groupSignal, tooltip = "Long score must beat short score by this amount, and short score must beat long score by this amount.")
majorCooldown = input.int(8, "Major Signal Cooldown Bars", minval = 0, maxval = 300, group = groupSignal, tooltip = "Minimum bars between major signal events.")
minMoveSinceSignal = input.float(0.70, "Minimum Move Since Last Signal", minval = 0.0, maxval = 10.0, step = 0.10, group = groupSignal, tooltip = "Prevents signals from printing too close together in price.")
allowSameDirectionSignals = input.bool(false, "Allow Same Direction Major Signals", group = groupSignal, tooltip = "When OFF, a new LONG normally requires the previous major signal to be SHORT, and vice versa.")
useRailFlipSignal = input.bool(true, "Use Pulse Rail Flip Signal", group = groupSignal, tooltip = "Adds a fast structural flip signal when the adaptive pulse rail changes direction.")
useFvgSignal = input.bool(true, "Use FVG Impulse Signal", group = groupSignal, tooltip = "Adds Fair Value Gap impulse detection for fast displacement entries.")
useStructureSignal = input.bool(true, "Use Structure Break Signal", group = groupSignal, tooltip = "Adds confirmed pivot-based break of structure signals.")
useRetestSignal = input.bool(true, "Use Structure Retest Signal", group = groupSignal, tooltip = "Adds a cleaner pullback retest entry after a confirmed break of structure.")
useLateFilter = input.bool(true, "Block Late Entries", group = groupSignal, tooltip = "Blocks entries when price is already too far from the fused core.")
maxPulseExtension = input.float(1.25, "Max PULSE Extension", minval = 0.40, maxval = 10.0, step = 0.05, group = groupSignal)
maxIgnitionExtension = input.float(2.20, "Max IGNITION Extension", minval = 0.40, maxval = 10.0, step = 0.05, group = groupSignal)
maxSweepExtension = input.float(1.80, "Max SWEEP Extension", minval = 0.40, maxval = 10.0, step = 0.05, group = groupSignal)
maxStructureExtension = input.float(1.90, "Max STRUCTURE Extension", minval = 0.40, maxval = 10.0, step = 0.05, group = groupSignal)
maxFvgExtension = input.float(2.10, "Max FVG Extension", minval = 0.40, maxval = 10.0, step = 0.05, group = groupSignal)

//------------------------------------------------------------------------------
// Accuracy Filters
//------------------------------------------------------------------------------
useHardEMAFilter = input.bool(false, "Use Hard EMA Filter", group = groupFilter, tooltip = "When ON, LONG requires price above EMA and SHORT requires price below EMA.")
emaLen = input.int(200, "EMA Bias Length", minval = 1, group = groupFilter)
useVWAPFilter = input.bool(false, "Use VWAP Filter", group = groupFilter, tooltip = "When ON, LONG requires price above VWAP and SHORT requires price below VWAP.")
useVolumeFilter = input.bool(false, "Use Volume Filter", group = groupFilter, tooltip = "When ON, signals require volume above the selected average ratio.")
volumeLen = input.int(20, "Volume Average Length", minval = 1, maxval = 200, group = groupFilter)
minVolumeRatio = input.float(1.0, "Minimum Volume Ratio", minval = 0.1, maxval = 5.0, step = 0.1, group = groupFilter)
useCandleFilter = input.bool(true, "Use Candle Quality Filter", group = groupFilter, tooltip = "When ON, signals need acceptable body and close quality unless they are strong impulse signals.")
minBodyRatio = input.float(0.22, "Minimum Body Ratio", minval = 0.0, maxval = 1.0, step = 0.01, group = groupFilter)
minClosePos = input.float(0.58, "Minimum Close Position", minval = 0.0, maxval = 1.0, step = 0.01, group = groupFilter)
usePredictionFilter = input.bool(true, "Use Prediction Alignment Filter", group = groupFilter, tooltip = "When ON, entries must agree with the next-move prediction unless the trigger is a strong reversal sweep.")
minPredictionConfidence = input.float(42.0, "Minimum Prediction Confidence", minval = 0.0, maxval = 100.0, step = 1.0, group = groupFilter)
useNoiseFloor = input.bool(true, "Use Noise Floor Filter", group = groupFilter, tooltip = "Blocks weak signals when expected move is too small compared with recent candle noise.")

//------------------------------------------------------------------------------
// Multi-Timeframe Filter
//------------------------------------------------------------------------------
useMTFStack = input.bool(true, "Use MTF Consensus Stack", group = groupMTF, tooltip = "When ON, signals receive confirmation from two higher-timeframe EMA states.")
mtfTF1 = input.timeframe("60", "MTF 1", group = groupMTF)
mtfTF2 = input.timeframe("240", "MTF 2", group = groupMTF)
mtfEmaLen = input.int(100, "MTF EMA Length", minval = 1, group = groupMTF)
mtfMinAgree = input.int(1, "Minimum MTF Agreement", minval = 0, maxval = 2, group = groupMTF, tooltip = "1 is balanced. 2 is stricter. 0 disables hard agreement while still scoring MTF context.")

//------------------------------------------------------------------------------
// Structure / Liquidity
//------------------------------------------------------------------------------
structurePivot = input.int(5, "Confirmed Structure Pivot", minval = 2, maxval = 30, group = groupStruct, tooltip = "Confirmed pivot size used for structure break signals.")
retestBars = input.int(18, "Structure Retest Memory", minval = 3, maxval = 120, group = groupStruct, tooltip = "Bars allowed for price to retest a broken structure level.")
retestTolerance = input.float(0.45, "Retest Tolerance", minval = 0.05, maxval = 3.0, step = 0.05, group = groupStruct, tooltip = "Volatility tolerance around a broken structure level.")
showStructureLevels = input.bool(false, "Show Latest Structure Levels", group = groupStruct)
showLiquiditySweeps = input.bool(true, "Show Small Sweep Marks", group = groupStruct)

//------------------------------------------------------------------------------
// Next Price Prediction
//------------------------------------------------------------------------------
showPrediction = input.bool(true, "Show Next Price Prediction", group = groupPredict, tooltip = "Shows a forward probabilistic price movement guide.")
forecastBars = input.int(34, "Prediction Bars Forward", minval = 5, maxval = 150, group = groupPredict, tooltip = "How many bars forward the projection extends.")
predictionStrength = input.float(1.00, "Prediction Strength", minval = 0.10, maxval = 3.00, step = 0.05, group = groupPredict, tooltip = "Higher values project further. Keep near 1.0 for realistic movement.")
predictionConeMult = input.float(1.15, "Prediction Cone Width", minval = 0.20, maxval = 5.00, step = 0.05, group = groupPredict, tooltip = "Controls the uncertainty cone around the prediction.")
regressionLen = input.int(55, "Regression Forecast Length", minval = 10, maxval = 300, group = groupPredict, tooltip = "Length used for the regression forecast component.")
showPredictionCone = input.bool(true, "Show Prediction Cone", group = groupPredict)
showPredictionLabel = input.bool(true, "Show Prediction Label", group = groupPredict)
useLockedPrediction = input.bool(true, "Use Hybrid Locked Prediction", group = groupPredict, tooltip = "When ON, the prediction cone locks and refreshes only on important events instead of moving on every live price update.")
predictionRefreshBars = input.int(5, "Locked Prediction Refresh Bars", minval = 1, maxval = 100, group = groupPredict, tooltip = "Refreshes the locked prediction after this many confirmed bars.")
predictionConfidenceRefresh = input.float(10.0, "Confidence Refresh Change", minval = 1.0, maxval = 50.0, step = 1.0, group = groupPredict, tooltip = "Refreshes the locked prediction when forecast confidence changes by this amount.")
predictionFlipConfidence = input.float(55.0, "Direction Flip Confidence", minval = 1.0, maxval = 100.0, step = 1.0, group = groupPredict, tooltip = "Refreshes the locked prediction when direction flips with at least this confidence.")

//------------------------------------------------------------------------------
// One Entry / One Exit Engine
//------------------------------------------------------------------------------
showTradeEngine = input.bool(true, "Show One Entry / One Exit Signals", group = groupTrade, tooltip = "Shows LONG entry, LONG exit, SHORT entry, SHORT exit from the internal state engine.")
showTradeProjection = input.bool(true, "Show Active Trade Projection", group = groupTrade, tooltip = "Shows active entry, invalidation, TP1, and TP2 lines.")
projectionBars = input.int(70, "Projection Bars", minval = 5, maxval = 300, group = groupTrade)
stopMult = input.float(0.90, "Minimum Stop Volatility", minval = 0.1, maxval = 10.0, step = 0.05, group = groupTrade)
rr1 = input.float(1.5, "TP1 Risk Reward", minval = 0.1, maxval = 20.0, step = 0.1, group = groupTrade)
rr2 = input.float(2.5, "TP2 Risk Reward", minval = 0.1, maxval = 20.0, step = 0.1, group = groupTrade)
useTrailingInvalidation = input.bool(true, "Use Adaptive Trailing Invalidation", group = groupTrade, tooltip = "When ON, invalidation trails using the adaptive pulse rail.")
moveStopToBEAfterTP1 = input.bool(true, "Move Invalidation To Entry After TP1", group = groupTrade, tooltip = "When ON, invalidation moves to entry after TP1 is touched.")
exitOnTP2 = input.bool(true, "Exit On TP2", group = groupTrade)
exitOnConfidenceLoss = input.bool(true, "Exit On Confidence Loss", group = groupTrade)
confidenceExitScore = input.float(48.0, "Confidence Exit Score", minval = 0.0, maxval = 100.0, step = 1.0, group = groupTrade)

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
showRecentOnly = input.bool(true, "Show Recent Chart Only", group = groupVisual, tooltip = "Hides old indicator history and keeps the chart clean.")
visibleBars = input.int(300, "Recent Bars To Show", minval = 50, maxval = 1500, group = groupVisual)

visualDensity = input.string("Clean", "Visual Density", options = ["Minimal", "Clean", "Full"], group = groupVisual, tooltip = "Minimal shows only essential lines and signals. Clean is recommended. Full shows all advanced object visuals.")
visualTheme = input.string("Pro", "Visual Theme", options = ["Pro", "Neon", "Monochrome", "Print"], group = groupVisual, tooltip = "Controls the main visual color style.")
useThemeColors = input.bool(true, "Use Theme Colors", group = groupVisual, tooltip = "When ON, the selected theme controls colors. When OFF, manual colors below are used.")

showCloud = input.bool(true, "Show Value Cloud", group = groupVisual)
showRail = input.bool(true, "Show Pulse Rail", group = groupVisual)
showEMA = input.bool(true, "Show EMA Bias", group = groupVisual)
showCore = input.bool(false, "Show Fused Core", group = groupVisual)
showVWAP = input.bool(false, "Show VWAP", group = groupVisual)
showCompass = input.bool(true, "Show Direction Compass", group = groupVisual)
showExhaustion = input.bool(true, "Show Exhaustion Diamond", group = groupVisual)
showBarColor = input.bool(false, "Color Candles By Bias", group = groupVisual)

showBiasBackdrop = input.bool(true, "Show Soft Bias Backdrop", group = groupVisual)
showForecastLadder = input.bool(true, "Show Forecast Ladder", group = groupVisual)
showForecastHorizon = input.bool(true, "Show Forecast Horizon Marker", group = groupVisual)
showCurrentPriceTag = input.bool(true, "Show Current Price Tag", group = groupVisual)
showLastSignalTag = input.bool(true, "Show Last Signal Detail Tag", group = groupVisual)
showRiskRewardBoxes = input.bool(true, "Show Risk / Reward Boxes", group = groupVisual)
showTradePath = input.bool(true, "Show Active Trade Path", group = groupVisual)
showTradeStatusBadge = input.bool(true, "Show Trade Status Badge", group = groupVisual)
showRegimeBadge = input.bool(true, "Show Regime Badge", group = groupVisual)
showDashboardMeters = input.bool(true, "Show Dashboard Meters", group = groupVisual)

signalLabelMode = input.string("Hybrid", "Signal Label Mode", options = ["Hybrid", "Full", "Compact"], group = groupVisual, tooltip = "Hybrid uses full labels in Clean/Full mode and compact labels in Minimal mode. Full shows LONG/SHORT. Compact shows L/S/XL/XS.")
signalLabelSizeInput = input.string("Tiny", "Signal Label Size", options = ["Tiny", "Small"], group = groupVisual, tooltip = "Controls the size of object-based signal labels.")
maxSignalLabels = input.int(160, "Maximum Historical Signal Labels", minval = 20, maxval = 350, group = groupVisual, tooltip = "Limits historical signal labels to protect TradingView label limits.")

manualBullColor = input.color(color.rgb(0, 190, 255), "Manual Bullish Color", group = groupVisual)
manualBearColor = input.color(color.rgb(255, 150, 0), "Manual Bearish Color", group = groupVisual)
manualNeutralColor = input.color(color.rgb(135, 140, 150), "Manual Neutral Color", group = groupVisual)
manualEmaColor = input.color(color.rgb(255, 190, 40), "Manual EMA Color", group = groupVisual)
manualVwapColor = input.color(color.rgb(170, 100, 255), "Manual VWAP Color", group = groupVisual)
textColor = input.color(color.white, "Text Color", group = groupVisual)

cloudTransp = input.int(94, "Cloud Transparency", minval = 0, maxval = 100, group = groupVisual)
railTransp = input.int(0, "Rail Transparency", minval = 0, maxval = 100, group = groupVisual)
glowTransp = input.int(92, "Rail Glow Transparency", minval = 0, maxval = 100, group = groupVisual)
barTransp = input.int(84, "Candle Transparency", minval = 0, maxval = 100, group = groupVisual)
railLineWidth = input.int(2, "Pulse Rail Width", minval = 1, maxval = 5, group = groupVisual)
signalDistance = input.float(0.45, "Signal Distance From Candle", minval = 0.0, maxval = 5.0, step = 0.05, group = groupVisual)

//------------------------------------------------------------------------------
// Dashboard / Alerts
//------------------------------------------------------------------------------
showDashboard = input.bool(true, "Show Dashboard", group = groupDash)
dashPosInput = input.string("Bottom Right", "Dashboard Position", options = ["Top Right", "Middle Right", "Bottom Right", "Bottom Left"], group = groupDash)
useJsonAlerts = input.bool(false, "Enable Dynamic JSON Alerts", group = groupAlert, tooltip = "When ON, alert() sends dynamic JSON messages. Create alert using Any alert() function call.")

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(_x, _lo, _hi) =>
    math.max(_lo, math.min(_x, _hi))

f_tick(_x) =>
    math.round(_x / syminfo.mintick) * syminfo.mintick

f_price(_x) =>
    str.tostring(_x, format.mintick)

f_pos(_p) =>
    _p == "Top Right" ? position.top_right : _p == "Middle Right" ? position.middle_right : _p == "Bottom Left" ? position.bottom_left : position.bottom_right

f_meter(_x) =>
    v = int(math.round(f_clamp(_x, 0.0, 100.0) / 10.0))
    v >= 10 ? "##########" : v == 9 ? "#########-" : v == 8 ? "########--" : v == 7 ? "#######---" : v == 6 ? "######----" : v == 5 ? "#####-----" : v == 4 ? "####------" : v == 3 ? "###-------" : v == 2 ? "##--------" : v == 1 ? "#---------" : "----------"

f_label_size(_s) =>
    _s == "Small" ? size.small : size.tiny

//------------------------------------------------------------------------------
// Visual Density Flags
//------------------------------------------------------------------------------
densityMinimal = visualDensity == "Minimal"
densityClean = visualDensity == "Clean"
densityFull = visualDensity == "Full"
allowClean = not densityMinimal
allowFull = densityFull

//------------------------------------------------------------------------------
// Theme Colors
//------------------------------------------------------------------------------
themeBull = visualTheme == "Neon" ? color.rgb(0, 255, 180) : visualTheme == "Monochrome" ? color.rgb(220, 220, 220) : visualTheme == "Print" ? color.rgb(60, 60, 60) : color.rgb(0, 190, 255)
themeBear = visualTheme == "Neon" ? color.rgb(255, 80, 210) : visualTheme == "Monochrome" ? color.rgb(120, 120, 120) : visualTheme == "Print" ? color.rgb(20, 20, 20) : color.rgb(255, 150, 0)
themeNeutral = visualTheme == "Neon" ? color.rgb(150, 160, 180) : visualTheme == "Monochrome" ? color.rgb(160, 160, 160) : visualTheme == "Print" ? color.rgb(100, 100, 100) : color.rgb(135, 140, 150)
themeEma = visualTheme == "Neon" ? color.rgb(255, 230, 80) : visualTheme == "Monochrome" ? color.rgb(190, 190, 190) : visualTheme == "Print" ? color.rgb(80, 80, 80) : color.rgb(255, 190, 40)
themeVwap = visualTheme == "Neon" ? color.rgb(160, 110, 255) : visualTheme == "Monochrome" ? color.rgb(140, 140, 140) : visualTheme == "Print" ? color.rgb(120, 120, 120) : color.rgb(170, 100, 255)

bullColor = useThemeColors ? themeBull : manualBullColor
bearColor = useThemeColors ? themeBear : manualBearColor
neutralColor = useThemeColors ? themeNeutral : manualNeutralColor
emaColor = useThemeColors ? themeEma : manualEmaColor
vwapColor = useThemeColors ? themeVwap : manualVwapColor

//------------------------------------------------------------------------------
// Fused Core
//------------------------------------------------------------------------------
lag = int(math.floor((coreLen - 1) * 0.5))
zInput = src + (src - nz(src[lag], src))
zlema = ta.ema(zInput, coreLen)

emaA = ta.ema(src, coreLen)
emaB = ta.ema(emaA, coreLen)
dema = 2.0 * emaA - emaB

hma = ta.hma(src, math.max(2, coreLen))

srcAbsChange = math.abs(ta.change(src))
erChange = math.abs(src - nz(src[erLen], src))
erVol = nz(ta.sma(srcAbsChange, erLen) * erLen, 0.0)
efficiency = erVol > 0.0 ? f_clamp(erChange / erVol, 0.0, 1.0) : 0.0
fractalEnergy = 1.0 - efficiency

fastSC = 2.0 / 3.0
slowSC = 2.0 / 31.0
kamaSC = math.pow(efficiency * (fastSC - slowSC) + slowSC, 2.0)

var float kama = na
kama := na(kama[1]) ? src : kama[1] + kamaSC * (src - kama[1])

omega = 2.0 * math.pi / math.max(coreLen, 2)
alpha = (math.cos(omega) + math.sin(omega) - 1.0) / math.cos(omega)

var float twoPole = na
twoPole := na(twoPole[1]) ? src : twoPole[1] + alpha * (src - twoPole[1])

coreRaw = zlema * 0.30 + dema * 0.22 + hma * 0.20 + kama * 0.18 + twoPole * 0.10
core = ta.ema(coreRaw, 2)
slowCore = ta.ema(core, coreLen * 2)

//------------------------------------------------------------------------------
// Volatility Fusion
//------------------------------------------------------------------------------
tr = math.max(high - low, math.max(math.abs(high - nz(close[1], close)), math.abs(low - nz(close[1], close))))
atr = nz(ta.atr(volLen), tr)

logHL = low > 0.0 and high > 0.0 ? math.log(high / low) : 0.0
parkRaw = math.sqrt(math.pow(logHL, 2.0) / (4.0 * math.log(2.0))) * close
parkVol = nz(ta.sma(parkRaw, volLen), atr)

logCO = open > 0.0 and close > 0.0 ? math.log(close / open) : 0.0
gkRaw = 0.5 * math.pow(logHL, 2.0) - (2.0 * math.log(2.0) - 1.0) * math.pow(logCO, 2.0)
gkBar = math.sqrt(math.max(gkRaw, 0.0)) * close
gkVol = nz(ta.sma(gkBar, volLen), atr)

volUnit = math.max(atr, math.max(parkVol * 0.70, gkVol * 0.70)) * profileVolK
volBase = nz(ta.sma(volUnit, 80), volUnit)
volRatio = volBase > 0.0 ? f_clamp(volUnit / volBase, 0.30, 3.00) : 1.00

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxRising = ta.rising(adx, 2)

//------------------------------------------------------------------------------
// Phase / Bias Engine
//------------------------------------------------------------------------------
phaseRaw = volUnit > 0.0 ? (close - core) / volUnit : 0.0
phase = ta.ema(phaseRaw, 3)
phaseVelocity = phase - nz(phase[1], phase)

lowestPhase = ta.lowest(phase, setupBars)
highestPhase = ta.highest(phase, setupBars)

pressure = ta.ema(volUnit > 0.0 ? (core - nz(core[1], core)) / volUnit : 0.0, 3)
extension = math.abs(phase)

emaValue = ta.ema(close, emaLen)
emaFast = ta.ema(close, 50)

vwapRaw = ta.vwap(hlc3)
vwapValue = nz(vwapRaw, emaValue)

coreBull = core > slowCore and pressure > 0.0
coreBear = core < slowCore and pressure < 0.0

//------------------------------------------------------------------------------
// MTF Stack
//------------------------------------------------------------------------------
mtfClose1 = request.security(syminfo.tickerid, mtfTF1, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
mtfEMA1 = request.security(syminfo.tickerid, mtfTF1, ta.ema(close, mtfEmaLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
mtfClose2 = request.security(syminfo.tickerid, mtfTF2, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
mtfEMA2 = request.security(syminfo.tickerid, mtfTF2, ta.ema(close, mtfEmaLen), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

mtfBull1 = mtfClose1 > mtfEMA1
mtfBear1 = mtfClose1 < mtfEMA1
mtfBull2 = mtfClose2 > mtfEMA2
mtfBear2 = mtfClose2 < mtfEMA2

mtfBullAgree = (mtfBull1 ? 1 : 0) + (mtfBull2 ? 1 : 0)
mtfBearAgree = (mtfBear1 ? 1 : 0) + (mtfBear2 ? 1 : 0)

//------------------------------------------------------------------------------
// Pulse Rail
//------------------------------------------------------------------------------
railAdaptive = railDistance * (adx > 28.0 ? 0.94 : adx < 15.0 ? 1.08 : 1.0) * (efficiency > 0.55 ? 0.95 : efficiency < 0.25 ? 1.08 : 1.0)

bullRail = core - volUnit * railAdaptive
bearRail = core + volUnit * railAdaptive

var float rail = na
var int pulse = 1

prevPulse = nz(pulse[1], 1)
prevRail = nz(rail[1], bullRail)

if prevPulse == 1
    if close < prevRail
        pulse := -1
        rail := bearRail
    else
        pulse := 1
        rail := math.max(bullRail, prevRail)
else
    if close > prevRail
        pulse := 1
        rail := bullRail
    else
        pulse := -1
        rail := math.min(bearRail, prevRail)

railFlipUp = pulse == 1 and prevPulse == -1
railFlipDown = pulse == -1 and prevPulse == 1

//------------------------------------------------------------------------------
// Candle / Volume / Delta Pressure
//------------------------------------------------------------------------------
volSeries = nz(volume, 0.0)
volAvg = ta.sma(volSeries, volumeLen)
volumeRatio = volAvg > 0.0 ? volSeries / volAvg : 1.0

barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyRatio = body / barRange
bodyVol = volUnit > 0.0 ? body / volUnit : 0.0

closePosBull = (close - low) / barRange
closePosBear = (high - close) / barRange

bullCandle = close > open and closePosBull >= minClosePos and bodyRatio >= minBodyRatio
bearCandle = close < open and closePosBear >= minClosePos and bodyRatio >= minBodyRatio

deltaRaw = volSeries * (close - open) / barRange
deltaPressure = ta.ema(deltaRaw, volumeLen)
deltaNorm = volAvg > 0.0 ? f_clamp(deltaPressure / volAvg, -2.0, 2.0) : 0.0

noiseRange = ta.sma(barRange, 20)
noiseOk = not useNoiseFloor or volUnit >= noiseRange * 0.35 or bodyVol >= minDisplacement * 0.60

confirmedOk = not confirmOnClose or barstate.isconfirmed

//------------------------------------------------------------------------------
// Structure / Liquidity / FVG
//------------------------------------------------------------------------------
ph = ta.pivothigh(high, structurePivot, structurePivot)
pl = ta.pivotlow(low, structurePivot, structurePivot)

var float lastSwingHigh = na
var float lastSwingLow = na
var float brokenHighLevel = na
var float brokenLowLevel = na
var int brokenHighBar = na
var int brokenLowBar = na

priorSwingHigh = lastSwingHigh
priorSwingLow = lastSwingLow

if not na(ph)
    lastSwingHigh := ph

if not na(pl)
    lastSwingLow := pl

rangeHighNow = ta.highest(high, rangeLen)
rangeLowNow = ta.lowest(low, rangeLen)
rangeHigh = nz(rangeHighNow[1], high)
rangeLow = nz(rangeLowNow[1], low)

rangeWidth = rangeHigh - rangeLow
compressionRatio = volUnit > 0.0 ? rangeWidth / volUnit : 99.0
compressed = compressionRatio <= compressionMax or efficiency < 0.32
compressedPrev = not na(compressionRatio[1]) and (compressionRatio[1] <= compressionMax or efficiency[1] < 0.32)

sweepHighNow = ta.highest(high, sweepLen)
sweepLowNow = ta.lowest(low, sweepLen)
sweepHigh = nz(sweepHighNow[1], high)
sweepLow = nz(sweepLowNow[1], low)

phaseCrossUp = ta.crossover(phase, 0.0)
phaseCrossDown = ta.crossunder(phase, 0.0)

bullDisplacement = close > open and bodyVol >= minDisplacement and closePosBull >= 0.64
bearDisplacement = close < open and bodyVol >= minDisplacement and closePosBear >= 0.64

bullFVG = useFvgSignal and bar_index > 2 and low > high[2] and bodyVol >= minDisplacement * 0.70 and close > open
bearFVG = useFvgSignal and bar_index > 2 and high < low[2] and bodyVol >= minDisplacement * 0.70 and close < open

structureBuyBreak = useStructureSignal and not na(priorSwingHigh) and close > priorSwingHigh + volUnit * breakBuffer and close[1] <= priorSwingHigh
structureSellBreak = useStructureSignal and not na(priorSwingLow) and close < priorSwingLow - volUnit * breakBuffer and close[1] >= priorSwingLow

if structureBuyBreak
    brokenHighLevel := priorSwingHigh
    brokenHighBar := bar_index

if structureSellBreak
    brokenLowLevel := priorSwingLow
    brokenLowBar := bar_index

retestBuy = useRetestSignal and not na(brokenHighLevel) and not na(brokenHighBar) and bar_index - brokenHighBar <= retestBars and low <= brokenHighLevel + volUnit * retestTolerance and close > brokenHighLevel and close > open
retestSell = useRetestSignal and not na(brokenLowLevel) and not na(brokenLowBar) and bar_index - brokenLowBar <= retestBars and high >= brokenLowLevel - volUnit * retestTolerance and close < brokenLowLevel and close < open

//------------------------------------------------------------------------------
// Event Detection
//------------------------------------------------------------------------------
pulseBuyEventRaw = lowestPhase < -pullbackPhase and phaseCrossUp and close > core and phaseVelocity > 0.0
pulseSellEventRaw = highestPhase > pullbackPhase and phaseCrossDown and close < core and phaseVelocity < 0.0

ignitionBuyEventRaw = close > rangeHigh + volUnit * breakBuffer and close[1] <= rangeHigh and compressedPrev and bullDisplacement and phaseVelocity > 0.0
ignitionSellEventRaw = close < rangeLow - volUnit * breakBuffer and close[1] >= rangeLow and compressedPrev and bearDisplacement and phaseVelocity < 0.0

sweepBuyEventRaw = low < sweepLow - volUnit * sweepBuffer and close > sweepLow and bullCandle and phaseVelocity > 0.0
sweepSellEventRaw = high > sweepHigh + volUnit * sweepBuffer and close < sweepHigh and bearCandle and phaseVelocity < 0.0

flipBuyEventRaw = useRailFlipSignal and railFlipUp and close > core and phaseVelocity > 0.0 and closePosBull >= 0.55
flipSellEventRaw = useRailFlipSignal and railFlipDown and close < core and phaseVelocity < 0.0 and closePosBear >= 0.55

structureBuyEventRaw = structureBuyBreak and close > core and phaseVelocity > 0.0
structureSellEventRaw = structureSellBreak and close < core and phaseVelocity < 0.0

fvgBuyEventRaw = bullFVG and close > core and phaseVelocity > 0.0
fvgSellEventRaw = bearFVG and close < core and phaseVelocity < 0.0

retestBuyEventRaw = retestBuy and close > core and phaseVelocity >= 0.0
retestSellEventRaw = retestSell and close < core and phaseVelocity <= 0.0

pulseBuyEvent = pulseBuyEventRaw and (not useLateFilter or extension <= maxPulseExtension)
pulseSellEvent = pulseSellEventRaw and (not useLateFilter or extension <= maxPulseExtension)

ignitionBuyEvent = ignitionBuyEventRaw and (not useLateFilter or extension <= maxIgnitionExtension)
ignitionSellEvent = ignitionSellEventRaw and (not useLateFilter or extension <= maxIgnitionExtension)

sweepBuyEvent = sweepBuyEventRaw and (not useLateFilter or extension <= maxSweepExtension)
sweepSellEvent = sweepSellEventRaw and (not useLateFilter or extension <= maxSweepExtension)

flipBuyEvent = flipBuyEventRaw and (not useLateFilter or extension <= 1.65)
flipSellEvent = flipSellEventRaw and (not useLateFilter or extension <= 1.65)

structureBuyEvent = structureBuyEventRaw and (not useLateFilter or extension <= maxStructureExtension)
structureSellEvent = structureSellEventRaw and (not useLateFilter or extension <= maxStructureExtension)

fvgBuyEvent = fvgBuyEventRaw and (not useLateFilter or extension <= maxFvgExtension)
fvgSellEvent = fvgSellEventRaw and (not useLateFilter or extension <= maxFvgExtension)

retestBuyEvent = retestBuyEventRaw and (not useLateFilter or extension <= maxPulseExtension)
retestSellEvent = retestSellEventRaw and (not useLateFilter or extension <= maxPulseExtension)

rawBuyEvent = pulseBuyEvent or ignitionBuyEvent or sweepBuyEvent or flipBuyEvent or structureBuyEvent or fvgBuyEvent or retestBuyEvent
rawSellEvent = pulseSellEvent or ignitionSellEvent or sweepSellEvent or flipSellEvent or structureSellEvent or fvgSellEvent or retestSellEvent

longTriggerText = ignitionBuyEvent ? "Ignition" : structureBuyEvent ? "Structure" : fvgBuyEvent ? "FVG" : retestBuyEvent ? "Retest" : pulseBuyEvent ? "Pulse" : sweepBuyEvent ? "Sweep" : flipBuyEvent ? "Rail Flip" : "None"
shortTriggerText = ignitionSellEvent ? "Ignition" : structureSellEvent ? "Structure" : fvgSellEvent ? "FVG" : retestSellEvent ? "Retest" : pulseSellEvent ? "Pulse" : sweepSellEvent ? "Sweep" : flipSellEvent ? "Rail Flip" : "None"

//------------------------------------------------------------------------------
// Regime
//------------------------------------------------------------------------------
chopState = efficiency < minEfficiency or (adx < 16.0 and fractalEnergy > 0.70)
impulseState = adx >= 25.0 and efficiency >= 0.38 and not compressed
reversalRisk = extension > 2.20 and fractalEnergy > 0.55
expansionState = volRatio > 1.20 and adxRising
compressionState = compressed and volRatio < 1.05

//------------------------------------------------------------------------------
// Filters
//------------------------------------------------------------------------------
emaLongOk = not useHardEMAFilter or close > emaValue
emaShortOk = not useHardEMAFilter or close < emaValue

vwapLongOk = not useVWAPFilter or close > vwapValue
vwapShortOk = not useVWAPFilter or close < vwapValue

mtfLongOk = not useMTFStack or mtfBullAgree >= mtfMinAgree
mtfShortOk = not useMTFStack or mtfBearAgree >= mtfMinAgree

volumeOk = not useVolumeFilter or volumeRatio >= minVolumeRatio

candleLongOk = not useCandleFilter or bullCandle or ignitionBuyEvent or flipBuyEvent or structureBuyEvent or fvgBuyEvent or retestBuyEvent
candleShortOk = not useCandleFilter or bearCandle or ignitionSellEvent or flipSellEvent or structureSellEvent or fvgSellEvent or retestSellEvent

efficiencyOk = efficiency >= minEfficiency or rawBuyEvent or rawSellEvent

//------------------------------------------------------------------------------
// Score Engine
//------------------------------------------------------------------------------
emaScoreLong = close > emaValue ? 13.0 : close > emaFast ? 8.0 : 0.0
emaScoreShort = close < emaValue ? 13.0 : close < emaFast ? 8.0 : 0.0

coreScoreLong = coreBull ? 12.0 : pressure > 0.0 ? 7.0 : 0.0
coreScoreShort = coreBear ? 12.0 : pressure < 0.0 ? 7.0 : 0.0

railScoreLong = pulse == 1 ? 8.0 : 0.0
railScoreShort = pulse == -1 ? 8.0 : 0.0

diScoreLong = diPlus > diMinus ? 10.0 : 0.0
diScoreShort = diMinus > diPlus ? 10.0 : 0.0

mtfScoreLong = useMTFStack ? mtfBullAgree * 4.0 : 8.0
mtfScoreShort = useMTFStack ? mtfBearAgree * 4.0 : 8.0

eventScoreLong = ignitionBuyEvent ? 23.0 : structureBuyEvent ? 21.0 : fvgBuyEvent ? 20.0 : retestBuyEvent ? 20.0 : pulseBuyEvent ? 19.0 : sweepBuyEvent ? 18.0 : flipBuyEvent ? 16.0 : 0.0
eventScoreShort = ignitionSellEvent ? 23.0 : structureSellEvent ? 21.0 : fvgSellEvent ? 20.0 : retestSellEvent ? 20.0 : pulseSellEvent ? 19.0 : sweepSellEvent ? 18.0 : flipSellEvent ? 16.0 : 0.0

phaseScoreLong = phase > 0.0 and phaseVelocity > 0.0 ? 10.0 : phaseVelocity > 0.0 ? 5.0 : 0.0
phaseScoreShort = phase < 0.0 and phaseVelocity < 0.0 ? 10.0 : phaseVelocity < 0.0 ? 5.0 : 0.0

candleScoreLong = closePosBull >= 0.72 ? 9.0 : closePosBull >= 0.60 ? 5.0 : 0.0
candleScoreShort = closePosBear >= 0.72 ? 9.0 : closePosBear >= 0.60 ? 5.0 : 0.0

dispScoreLong = bullDisplacement ? 8.0 : bodyVol >= minDisplacement * 0.70 and close > open ? 4.0 : 0.0
dispScoreShort = bearDisplacement ? 8.0 : bodyVol >= minDisplacement * 0.70 and close < open ? 4.0 : 0.0

deltaScoreLong = deltaNorm > 0.35 ? 6.0 : deltaNorm > 0.05 ? 3.0 : 0.0
deltaScoreShort = deltaNorm < -0.35 ? 6.0 : deltaNorm < -0.05 ? 3.0 : 0.0

adxScore = f_clamp((adx - 12.0) / 24.0 * 8.0, 0.0, 8.0)
adxRisingScore = adxRising ? 3.0 : 0.0
erScore = f_clamp(efficiency * 9.0, 0.0, 9.0)
fractalScore = f_clamp((1.0 - fractalEnergy) * 8.0, 0.0, 8.0)
volumeScore = useVolumeFilter ? volumeRatio >= minVolumeRatio ? 4.0 : 0.0 : 4.0
extensionScore = extension <= 0.90 ? 9.0 : extension <= 1.60 ? 5.0 : extension <= 2.20 ? 2.0 : 0.0
expansionScore = expansionState ? 3.0 : 0.0

regimePenalty = chopState ? 7.0 : fractalEnergy > 0.80 ? 4.0 : 0.0
dynamicMinScore = f_clamp(minScore + (chopState ? 4.0 : 0.0) - (impulseState ? 3.0 : 0.0) + (compressionState ? 1.0 : 0.0), 50.0, 96.0)

scoreLong = f_clamp(emaScoreLong + coreScoreLong + railScoreLong + diScoreLong + mtfScoreLong + eventScoreLong + phaseScoreLong + candleScoreLong + dispScoreLong + deltaScoreLong + adxScore + adxRisingScore + erScore + fractalScore + volumeScore + extensionScore + expansionScore - regimePenalty, 0.0, 100.0)
scoreShort = f_clamp(emaScoreShort + coreScoreShort + railScoreShort + diScoreShort + mtfScoreShort + eventScoreShort + phaseScoreShort + candleScoreShort + dispScoreShort + deltaScoreShort + adxScore + adxRisingScore + erScore + fractalScore + volumeScore + extensionScore + expansionScore - regimePenalty, 0.0, 100.0)

baseLongScore = f_clamp(emaScoreLong + coreScoreLong + railScoreLong + diScoreLong + mtfScoreLong + phaseScoreLong + candleScoreLong + deltaScoreLong + adxScore + erScore + fractalScore + volumeScore + extensionScore - regimePenalty, 0.0, 100.0)
baseShortScore = f_clamp(emaScoreShort + coreScoreShort + railScoreShort + diScoreShort + mtfScoreShort + phaseScoreShort + candleScoreShort + deltaScoreShort + adxScore + erScore + fractalScore + volumeScore + extensionScore - regimePenalty, 0.0, 100.0)

var int bias = 0
bias := baseLongScore >= baseShortScore + scoreEdge ? 1 : baseShortScore >= baseLongScore + scoreEdge ? -1 : nz(bias[1], 0)

activeScore = bias == 1 ? baseLongScore : bias == -1 ? baseShortScore : math.max(baseLongScore, baseShortScore)

//------------------------------------------------------------------------------
// Regression Forecast Component
//------------------------------------------------------------------------------
regNow = ta.linreg(src, regressionLen, 0)
regPrev = ta.linreg(src, regressionLen, 1)
regSlope = regNow - regPrev
regResidual = src - regNow
regNoise = ta.stdev(regResidual, regressionLen)
regTotal = ta.stdev(src, regressionLen)
regQuality = regTotal > 0.0 ? f_clamp(1.0 - regNoise / regTotal, 0.0, 1.0) : 0.0
regVector = volUnit > 0.0 ? f_clamp(regSlope / volUnit * 3.0, -1.0, 1.0) : 0.0

//------------------------------------------------------------------------------
// Next Price Prediction Engine
//------------------------------------------------------------------------------
scoreDominance = f_clamp((scoreLong - scoreShort) / 100.0, -1.0, 1.0)
phaseVector = f_clamp(phaseVelocity * 0.75 + phase * 0.18, -1.0, 1.0)
pressureVector = f_clamp(pressure * 1.25, -1.0, 1.0)
diVector = f_clamp((diPlus - diMinus) / 50.0, -1.0, 1.0)
railVector = pulse == 1 ? 0.25 : pulse == -1 ? -0.25 : 0.0
mtfVector = useMTFStack ? f_clamp((mtfBullAgree - mtfBearAgree) / 2.0 * 0.30, -0.30, 0.30) : 0.0
deltaVector = f_clamp(deltaNorm * 0.18, -0.25, 0.25)
regQualityVector = regVector * (0.35 + regQuality * 0.65)

rawFlowVector = scoreDominance * 0.34 + phaseVector * 0.19 + pressureVector * 0.15 + diVector * 0.10 + regQualityVector * 0.12 + railVector + mtfVector + deltaVector
flowVector = f_clamp(rawFlowVector, -1.0, 1.0)

regimeMultiplier = impulseState ? 1.22 : compressionState ? 0.78 : chopState ? 0.55 : 1.00
reversalMultiplier = reversalRisk ? 0.72 : 1.00
qualityMultiplier = 0.80 + regQuality * 0.30
horizonScale = math.sqrt(forecastBars / 14.0)

predictionMove = volUnit * flowVector * horizonScale * predictionStrength * regimeMultiplier * reversalMultiplier * qualityMultiplier
predictedPrice = f_tick(close + predictionMove)

coneWidth = volUnit * predictionConeMult * horizonScale * (chopState ? 1.25 : impulseState ? 0.90 : 1.00) * (1.15 - regQuality * 0.25)
coneUpper = f_tick(predictedPrice + coneWidth)
coneLower = f_tick(predictedPrice - coneWidth)
coneMidUpper = f_tick(predictedPrice + coneWidth * 0.66)
coneMidLower = f_tick(predictedPrice - coneWidth * 0.66)
coneInnerUpper = f_tick(predictedPrice + coneWidth * 0.33)
coneInnerLower = f_tick(predictedPrice - coneWidth * 0.33)

predictionSide = predictedPrice > close ? 1 : predictedPrice < close ? -1 : 0
predictionColor = predictionSide == 1 ? bullColor : predictionSide == -1 ? bearColor : neutralColor
predictionConfidence = f_clamp(math.abs(flowVector) * 100.0 + regQuality * 12.0 + (impulseState ? 8.0 : 0.0) - (chopState ? 12.0 : 0.0), 0.0, 100.0)

predictionLongOk = not usePredictionFilter or ((predictionConfidence >= minPredictionConfidence and predictionSide >= 0) or sweepBuyEvent)
predictionShortOk = not usePredictionFilter or ((predictionConfidence >= minPredictionConfidence and predictionSide <= 0) or sweepSellEvent)

//------------------------------------------------------------------------------
// Final Signal Logic
//------------------------------------------------------------------------------
baseLongOk = confirmedOk and emaLongOk and vwapLongOk and mtfLongOk and volumeOk and candleLongOk and efficiencyOk and predictionLongOk and noiseOk
baseShortOk = confirmedOk and emaShortOk and vwapShortOk and mtfShortOk and volumeOk and candleShortOk and efficiencyOk and predictionShortOk and noiseOk

var int lastMajorBar = na
var float lastMajorPrice = na
var int lastMajorSide = 0

cooldownOk = na(lastMajorBar) or bar_index - lastMajorBar >= majorCooldown
moveOk = na(lastMajorPrice) or math.abs(close - lastMajorPrice) >= volUnit * minMoveSinceSignal

sideLongOk = allowSameDirectionSignals or lastMajorSide != 1
sideShortOk = allowSameDirectionSignals or lastMajorSide != -1

buyCandidate = cooldownOk and moveOk and sideLongOk and baseLongOk and rawBuyEvent and scoreLong >= dynamicMinScore and scoreLong >= scoreShort + scoreEdge
sellCandidate = cooldownOk and moveOk and sideShortOk and baseShortOk and rawSellEvent and scoreShort >= dynamicMinScore and scoreShort >= scoreLong + scoreEdge

buySignal = buyCandidate and (not sellCandidate or scoreLong > scoreShort)
sellSignal = sellCandidate and (not buyCandidate or scoreShort > scoreLong)

if buySignal
    lastMajorBar := bar_index
    lastMajorPrice := close
    lastMajorSide := 1

if sellSignal
    lastMajorBar := bar_index
    lastMajorPrice := close
    lastMajorSide := -1

activeTrigger = buySignal ? longTriggerText : sellSignal ? shortTriggerText : bias == 1 ? longTriggerText : bias == -1 ? shortTriggerText : "None"

//------------------------------------------------------------------------------
// One Entry / One Exit Trade State Engine
//------------------------------------------------------------------------------
var int tradeSide = 0
var float tradeEntry = na
var float tradeStop = na
var float tradeTp1 = na
var float tradeTp2 = na
var int tradeEntryBar = na
var bool tp1Touched = false

if tradeSide == 1 and not na(tradeTp1)
    tp1Touched := tp1Touched or high >= tradeTp1

if tradeSide == -1 and not na(tradeTp1)
    tp1Touched := tp1Touched or low <= tradeTp1

if useTrailingInvalidation and tradeSide == 1 and not na(tradeStop)
    tradeStop := math.max(tradeStop, f_tick(math.min(rail, close - volUnit * 0.35)))

if useTrailingInvalidation and tradeSide == -1 and not na(tradeStop)
    tradeStop := math.min(tradeStop, f_tick(math.max(rail, close + volUnit * 0.35)))

if moveStopToBEAfterTP1 and tp1Touched and tradeSide == 1 and not na(tradeEntry)
    tradeStop := math.max(tradeStop, tradeEntry)

if moveStopToBEAfterTP1 and tp1Touched and tradeSide == -1 and not na(tradeEntry)
    tradeStop := math.min(tradeStop, tradeEntry)

longConfidenceLoss = tradeSide == 1 and exitOnConfidenceLoss and scoreLong < confidenceExitScore and scoreShort > scoreLong
shortConfidenceLoss = tradeSide == -1 and exitOnConfidenceLoss and scoreShort < confidenceExitScore and scoreLong > scoreShort

longStopHit = tradeSide == 1 and not na(tradeStop) and close <= tradeStop
shortStopHit = tradeSide == -1 and not na(tradeStop) and close >= tradeStop
longTP2Hit = tradeSide == 1 and not na(tradeTp2) and close >= tradeTp2
shortTP2Hit = tradeSide == -1 and not na(tradeTp2) and close <= tradeTp2

longExitSignal = showTradeEngine and tradeSide == 1 and confirmedOk and (sellSignal or longStopHit or longConfidenceLoss or (exitOnTP2 and longTP2Hit))
shortExitSignal = showTradeEngine and tradeSide == -1 and confirmedOk and (buySignal or shortStopHit or shortConfidenceLoss or (exitOnTP2 and shortTP2Hit))

if longExitSignal or shortExitSignal
    tradeSide := 0
    tp1Touched := false

longEntrySignal = showTradeEngine and buySignal and tradeSide <= 0
shortEntrySignal = showTradeEngine and sellSignal and tradeSide >= 0

if longEntrySignal
    tradeSide := 1
    tradeEntry := f_tick(close)
    tradeStop := f_tick(math.min(rail, tradeEntry - volUnit * stopMult))
    riskLong = math.max(math.abs(tradeEntry - tradeStop), volUnit * stopMult)
    tradeTp1 := f_tick(tradeEntry + riskLong * rr1)
    tradeTp2 := f_tick(tradeEntry + riskLong * rr2)
    tradeEntryBar := bar_index
    tp1Touched := false

if shortEntrySignal
    tradeSide := -1
    tradeEntry := f_tick(close)
    tradeStop := f_tick(math.max(rail, tradeEntry + volUnit * stopMult))
    riskShort = math.max(math.abs(tradeEntry - tradeStop), volUnit * stopMult)
    tradeTp1 := f_tick(tradeEntry - riskShort * rr1)
    tradeTp2 := f_tick(tradeEntry - riskShort * rr2)
    tradeEntryBar := bar_index
    tp1Touched := false

//------------------------------------------------------------------------------
// Hybrid Locked Prediction Display State
//------------------------------------------------------------------------------
var float lockedPredictedPrice = na
var float lockedConeUpper = na
var float lockedConeLower = na
var float lockedConeMidUpper = na
var float lockedConeMidLower = na
var float lockedConeInnerUpper = na
var float lockedConeInnerLower = na
var float lockedPredictionConfidence = na
var float lockedPredictionStartPrice = na
var int lockedPredictionSide = 0
var int lockedPredictionBar = na

predictionNewEvent = longEntrySignal or shortEntrySignal or longExitSignal or shortExitSignal
predictionDirectionFlip = not na(lockedPredictedPrice) and predictionSide != lockedPredictionSide and predictionSide != 0 and predictionConfidence >= predictionFlipConfidence
predictionConfidenceShift = not na(lockedPredictionConfidence) and math.abs(predictionConfidence - lockedPredictionConfidence) >= predictionConfidenceRefresh
predictionTimedRefresh = na(lockedPredictionBar) or bar_index - lockedPredictionBar >= predictionRefreshBars
predictionExpired = not na(lockedPredictionBar) and bar_index >= lockedPredictionBar + forecastBars

predictionShouldRefresh = not useLockedPrediction or na(lockedPredictedPrice) or predictionNewEvent or predictionDirectionFlip or predictionConfidenceShift or ((predictionTimedRefresh or predictionExpired) and confirmedOk)

if predictionShouldRefresh
    lockedPredictedPrice := predictedPrice
    lockedConeUpper := coneUpper
    lockedConeLower := coneLower
    lockedConeMidUpper := coneMidUpper
    lockedConeMidLower := coneMidLower
    lockedConeInnerUpper := coneInnerUpper
    lockedConeInnerLower := coneInnerLower
    lockedPredictionConfidence := predictionConfidence
    lockedPredictionStartPrice := close
    lockedPredictionSide := predictionSide
    lockedPredictionBar := bar_index

displayPredictedPrice = useLockedPrediction ? nz(lockedPredictedPrice, predictedPrice) : predictedPrice
displayConeUpper = useLockedPrediction ? nz(lockedConeUpper, coneUpper) : coneUpper
displayConeLower = useLockedPrediction ? nz(lockedConeLower, coneLower) : coneLower
displayConeMidUpper = useLockedPrediction ? nz(lockedConeMidUpper, coneMidUpper) : coneMidUpper
displayConeMidLower = useLockedPrediction ? nz(lockedConeMidLower, coneMidLower) : coneMidLower
displayConeInnerUpper = useLockedPrediction ? nz(lockedConeInnerUpper, coneInnerUpper) : coneInnerUpper
displayConeInnerLower = useLockedPrediction ? nz(lockedConeInnerLower, coneInnerLower) : coneInnerLower
displayPredictionConfidence = useLockedPrediction ? nz(lockedPredictionConfidence, predictionConfidence) : predictionConfidence
displayPredictionSide = useLockedPrediction ? lockedPredictionSide : predictionSide
displayPredictionStartPrice = useLockedPrediction ? nz(lockedPredictionStartPrice, close) : close
displayForecastX1 = useLockedPrediction ? nz(lockedPredictionBar, bar_index) : bar_index
displayForecastX2 = displayForecastX1 + forecastBars
displayPredictionColor = displayPredictionSide == 1 ? bullColor : displayPredictionSide == -1 ? bearColor : neutralColor

//------------------------------------------------------------------------------
// Last Signal Detail Label
//------------------------------------------------------------------------------
var label lastSignalLabel = na

if allowClean and showLastSignalTag and (longEntrySignal or shortEntrySignal or longExitSignal or shortExitSignal)
    if not na(lastSignalLabel)
        label.delete(lastSignalLabel)

    sigColor = longEntrySignal ? bullColor : shortEntrySignal ? bearColor : neutralColor
    sigY = longEntrySignal or shortExitSignal ? low - volUnit * 1.15 : high + volUnit * 1.15
    sigStyle = longEntrySignal or shortExitSignal ? label.style_label_up : label.style_label_down
    sigName = longEntrySignal ? "LONG ENTRY" : shortEntrySignal ? "SHORT ENTRY" : longExitSignal ? "LONG EXIT" : "SHORT EXIT"
    sigScore = longEntrySignal ? scoreLong : shortEntrySignal ? scoreShort : activeScore
    sigTrigger = longEntrySignal ? longTriggerText : shortEntrySignal ? shortTriggerText : "Exit"
    sigText = sigName + "\nTrigger: " + sigTrigger + "\nScore: " + str.tostring(math.round(sigScore)) + "/100\nForecast: " + f_price(displayPredictedPrice)
    lastSignalLabel := label.new(bar_index, sigY, sigText, style = sigStyle, textcolor = textColor, color = color.new(sigColor, 0), size = size.tiny)

//------------------------------------------------------------------------------
// Exhaustion
//------------------------------------------------------------------------------
rsi = ta.rsi(src, 14)
bullExhaustion = showExhaustion and bias == 1 and extension > 2.60 and rsi > 70 and closePosBull < 0.48
bearExhaustion = showExhaustion and bias == -1 and extension > 2.60 and rsi < 30 and closePosBear < 0.48

//------------------------------------------------------------------------------
// Clean Plot Visuals
//------------------------------------------------------------------------------
showBarNow = not showRecentOnly or bar_index >= last_bar_index - visibleBars

biasColor = bias == 1 ? bullColor : bias == -1 ? bearColor : neutralColor
cloudColor = color.new(biasColor, cloudTransp)
outerCloudColor = color.new(biasColor, math.min(100, cloudTransp + 3))
railColor = color.new(biasColor, railTransp)
glowColor = color.new(biasColor, glowTransp)

valueUpper = core + volUnit * valueWidth
valueLower = core - volUnit * valueWidth
outerUpper = core + volUnit * outerWidth
outerLower = core - volUnit * outerWidth

pVU = plot(showCloud and showBarNow ? valueUpper : na, "Value Cloud Upper", color = color.new(biasColor, 100))
pVL = plot(showCloud and showBarNow ? valueLower : na, "Value Cloud Lower", color = color.new(biasColor, 100))
pOU = plot(showCloud and showBarNow ? outerUpper : na, "Outer Cloud Upper", color = color.new(biasColor, 100))
pOL = plot(showCloud and showBarNow ? outerLower : na, "Outer Cloud Lower", color = color.new(biasColor, 100))

fill(pVU, pVL, color = showCloud ? cloudColor : na, title = "Value Cloud")
fill(pOU, pOL, color = showCloud ? outerCloudColor : na, title = "Outer Cloud")

plot(showRail and showBarNow ? rail : na, "Pulse Rail Glow", color = glowColor, linewidth = 5)
plot(showRail and showBarNow ? rail : na, "Pulse Rail", color = railColor, linewidth = railLineWidth)

plot(showCore and showBarNow ? core : na, "Fused Core", color = color.new(neutralColor, 0), linewidth = 1)
plot(showEMA and showBarNow ? emaValue : na, "EMA Bias", color = color.new(emaColor, 0), linewidth = 2)
plot(showVWAP and showBarNow ? vwapValue : na, "VWAP", color = color.new(vwapColor, 0), linewidth = 1)

plot(showStructureLevels and showBarNow ? lastSwingHigh : na, "Latest Structure High", color = color.new(bearColor, 25), linewidth = 1, style = plot.style_linebr)
plot(showStructureLevels and showBarNow ? lastSwingLow : na, "Latest Structure Low", color = color.new(bullColor, 25), linewidth = 1, style = plot.style_linebr)

buyY = low - volUnit * signalDistance
sellY = high + volUnit * signalDistance
exitLongY = high + volUnit * signalDistance
exitShortY = low - volUnit * signalDistance

// Object-based hybrid signal labels.
var array<label> signalLabels = array.new<label>()

signalLblSize = f_label_size(signalLabelSizeInput)

longEntryText = signalLabelMode == "Compact" or (signalLabelMode == "Hybrid" and densityMinimal) ? "L" : "LONG"
shortEntryText = signalLabelMode == "Compact" or (signalLabelMode == "Hybrid" and densityMinimal) ? "S" : "SHORT"
longExitText = signalLabelMode == "Compact" or (signalLabelMode == "Hybrid" and densityMinimal) ? "XL" : "EXIT L"
shortExitText = signalLabelMode == "Compact" or (signalLabelMode == "Hybrid" and densityMinimal) ? "XS" : "EXIT S"

if longEntrySignal and showBarNow
    lb = label.new(bar_index, buyY, longEntryText, style = label.style_label_up, textcolor = textColor, color = color.new(bullColor, 0), size = signalLblSize)
    array.push(signalLabels, lb)

if shortEntrySignal and showBarNow
    lb = label.new(bar_index, sellY, shortEntryText, style = label.style_label_down, textcolor = textColor, color = color.new(bearColor, 0), size = signalLblSize)
    array.push(signalLabels, lb)

if longExitSignal and showBarNow
    lb = label.new(bar_index, exitLongY, longExitText, style = label.style_label_down, textcolor = textColor, color = color.new(neutralColor, 0), size = signalLblSize)
    array.push(signalLabels, lb)

if shortExitSignal and showBarNow
    lb = label.new(bar_index, exitShortY, shortExitText, style = label.style_label_up, textcolor = textColor, color = color.new(neutralColor, 0), size = signalLblSize)
    array.push(signalLabels, lb)

while array.size(signalLabels) > maxSignalLabels
    oldLabel = array.shift(signalLabels)
    label.delete(oldLabel)

plotshape(allowFull and showLiquiditySweeps and sweepBuyEvent and showBarNow ? low - volUnit * 0.20 : na, "Bullish Sweep Mark", style = shape.circle, location = location.absolute, color = color.new(bullColor, 0), size = size.tiny)
plotshape(allowFull and showLiquiditySweeps and sweepSellEvent and showBarNow ? high + volUnit * 0.20 : na, "Bearish Sweep Mark", style = shape.circle, location = location.absolute, color = color.new(bearColor, 0), size = size.tiny)

plotshape(allowClean and bullExhaustion and showBarNow ? high + volUnit * 0.45 : na, "Bull Exhaustion", style = shape.diamond, location = location.absolute, color = color.new(bearColor, 0), size = size.tiny)
plotshape(allowClean and bearExhaustion and showBarNow ? low - volUnit * 0.45 : na, "Bear Exhaustion", style = shape.diamond, location = location.absolute, color = color.new(bullColor, 0), size = size.tiny)

barcolor(showBarColor and showBarNow ? color.new(biasColor, barTransp) : na)

//------------------------------------------------------------------------------
// Object-Based Visual Layer
//------------------------------------------------------------------------------
var box biasBackdropBox = na
var box predictionConeOuter = na
var box predictionConeMid = na
var box predictionConeInner = na
var line predictionLine = na
var line forecastUpperLine = na
var line forecastTargetLine = na
var line forecastLowerLine = na
var line horizonLine = na
var label predictionLabel = na
var label compassLabel = na
var label currentPriceLabel = na
var label regimeBadgeLabel = na
var label mtfBadgeLabel = na

visibleHighNow = ta.highest(high, visibleBars)
visibleLowNow = ta.lowest(low, visibleBars)

if barstate.islast
    if not na(biasBackdropBox)
        box.delete(biasBackdropBox)
    if not na(predictionConeOuter)
        box.delete(predictionConeOuter)
    if not na(predictionConeMid)
        box.delete(predictionConeMid)
    if not na(predictionConeInner)
        box.delete(predictionConeInner)
    if not na(predictionLine)
        line.delete(predictionLine)
    if not na(forecastUpperLine)
        line.delete(forecastUpperLine)
    if not na(forecastTargetLine)
        line.delete(forecastTargetLine)
    if not na(forecastLowerLine)
        line.delete(forecastLowerLine)
    if not na(horizonLine)
        line.delete(horizonLine)
    if not na(predictionLabel)
        label.delete(predictionLabel)
    if not na(compassLabel)
        label.delete(compassLabel)
    if not na(currentPriceLabel)
        label.delete(currentPriceLabel)
    if not na(regimeBadgeLabel)
        label.delete(regimeBadgeLabel)
    if not na(mtfBadgeLabel)
        label.delete(mtfBadgeLabel)

    if allowClean and showBiasBackdrop
        biasBackdropBox := box.new(bar_index - 2, visibleHighNow, displayForecastX2, visibleLowNow, bgcolor = color.new(biasColor, 97), border_color = color.new(biasColor, 100))

    if showPrediction
        if allowClean and showPredictionCone
            predictionConeOuter := box.new(displayForecastX1, displayConeUpper, displayForecastX2, displayConeLower, bgcolor = color.new(displayPredictionColor, 94), border_color = color.new(displayPredictionColor, 80))
            predictionConeMid := box.new(displayForecastX1, displayConeMidUpper, displayForecastX2, displayConeMidLower, bgcolor = color.new(displayPredictionColor, 91), border_color = color.new(displayPredictionColor, 88))
            predictionConeInner := box.new(displayForecastX1, displayConeInnerUpper, displayForecastX2, displayConeInnerLower, bgcolor = color.new(displayPredictionColor, 88), border_color = color.new(displayPredictionColor, 100))

        predictionLine := line.new(displayForecastX1, displayPredictionStartPrice, displayForecastX2, displayPredictedPrice, color = color.new(displayPredictionColor, 0), width = 2, style = line.style_dotted)

        if allowClean and showForecastLadder
            forecastUpperLine := line.new(displayForecastX1, displayConeUpper, displayForecastX2, displayConeUpper, color = color.new(displayPredictionColor, 35), width = 1, style = line.style_dashed)
            forecastTargetLine := line.new(displayForecastX1, displayPredictedPrice, displayForecastX2, displayPredictedPrice, color = color.new(displayPredictionColor, 0), width = 2)
            forecastLowerLine := line.new(displayForecastX1, displayConeLower, displayForecastX2, displayConeLower, color = color.new(displayPredictionColor, 35), width = 1, style = line.style_dashed)

        if allowFull and showForecastHorizon
            horizonLine := line.new(displayForecastX2, visibleHighNow, displayForecastX2, visibleLowNow, color = color.new(displayPredictionColor, 70), width = 1, style = line.style_dashed)

        if showPredictionLabel
            predText = displayPredictionSide == 1 ? "NEXT MOVE UP" : displayPredictionSide == -1 ? "NEXT MOVE DOWN" : "NEXT MOVE FLAT"
            predictionLabel := label.new(displayForecastX2, displayPredictedPrice, predText + "\nTarget " + f_price(displayPredictedPrice) + "\nConfidence " + str.tostring(math.round(displayPredictionConfidence)) + "/100", style = label.style_label_left, textcolor = textColor, color = color.new(displayPredictionColor, 0), size = size.tiny)

    if allowClean and showCompass
        dirText = bias == 1 ? "LONG BIAS" : bias == -1 ? "SHORT BIAS" : "NEUTRAL"
        tradeText = tradeSide == 1 ? "Active LONG" : tradeSide == -1 ? "Active SHORT" : "No Active Trade"
        compassLabel := label.new(bar_index + 2, close, dirText + "\n" + tradeText + "\nScore " + str.tostring(math.round(activeScore)) + "/100\nPrediction " + f_price(displayPredictedPrice), style = label.style_label_left, textcolor = textColor, color = color.new(biasColor, 10), size = size.tiny)

    if allowClean and showCurrentPriceTag
        currentPriceLabel := label.new(bar_index, close, "Now " + f_price(close), style = label.style_label_left, textcolor = textColor, color = color.new(neutralColor, 20), size = size.tiny)

    if allowFull and showRegimeBadge
        regimeBadgeText = impulseState ? "REGIME: IMPULSE" : compressionState ? "REGIME: COMPRESSION" : chopState ? "REGIME: CHOP" : expansionState ? "REGIME: EXPANSION" : "REGIME: DRIFT"
        regimeBadgeLabel := label.new(displayForecastX2, visibleHighNow, regimeBadgeText, style = label.style_label_left, textcolor = textColor, color = color.new(biasColor, 15), size = size.tiny)

        mtfBadgeText = "MTF " + str.tostring(mtfBullAgree) + "B / " + str.tostring(mtfBearAgree) + "S"
        mtfBadgeLabel := label.new(displayForecastX2, visibleLowNow, mtfBadgeText, style = label.style_label_left, textcolor = textColor, color = color.new(neutralColor, 25), size = size.tiny)

//------------------------------------------------------------------------------
// Active Trade Projection
//------------------------------------------------------------------------------
var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tradePathLine = na
var label entryLabel = na
var label stopLabel = na
var label tp1Label = na
var label tp2Label = na
var label tradeStatusLabel = na
var box rewardBox = na
var box riskBox = na

if barstate.islast and showTradeProjection
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tradePathLine)
        line.delete(tradePathLine)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(stopLabel)
        label.delete(stopLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tradeStatusLabel)
        label.delete(tradeStatusLabel)
    if not na(rewardBox)
        box.delete(rewardBox)
    if not na(riskBox)
        box.delete(riskBox)

    if tradeSide != 0 and not na(tradeEntry) and not na(tradeStop) and not na(tradeTp1) and not na(tradeTp2)
        tradeColor = tradeSide == 1 ? bullColor : bearColor
        x1 = bar_index
        x2 = bar_index + projectionBars

        rewardTop = tradeSide == 1 ? tradeTp2 : tradeEntry
        rewardBottom = tradeSide == 1 ? tradeEntry : tradeTp2
        riskTop = tradeSide == 1 ? tradeEntry : tradeStop
        riskBottom = tradeSide == 1 ? tradeStop : tradeEntry

        if allowClean and showRiskRewardBoxes
            rewardBox := box.new(x1, rewardTop, x2, rewardBottom, bgcolor = color.new(tradeColor, 92), border_color = color.new(tradeColor, 85))
            riskBox := box.new(x1, riskTop, x2, riskBottom, bgcolor = color.new(bearColor, 93), border_color = color.new(bearColor, 85))

        if allowFull and showTradePath
            tradePathLine := line.new(x1, tradeEntry, x2, tradeTp2, color = color.new(tradeColor, 20), width = 2, style = line.style_dotted)

        entryLine := line.new(x1, tradeEntry, x2, tradeEntry, color = color.new(neutralColor, 0), width = 1)
        stopLine := line.new(x1, tradeStop, x2, tradeStop, color = color.new(bearColor, 0), width = 1, style = line.style_dashed)
        tp1Line := line.new(x1, tradeTp1, x2, tradeTp1, color = color.new(tradeColor, 0), width = 1, style = line.style_dotted)
        tp2Line := line.new(x1, tradeTp2, x2, tradeTp2, color = color.new(tradeColor, 0), width = 1, style = line.style_dotted)

        stopText = tp1Touched ? "BE / Invalid " + f_price(tradeStop) : "Invalid " + f_price(tradeStop)
        tp1Text = tp1Touched ? "TP1 Hit " + f_price(tradeTp1) : "TP1 " + f_price(tradeTp1)

        entryLabel := label.new(x2, tradeEntry, "Entry " + f_price(tradeEntry), style = label.style_label_left, textcolor = textColor, color = color.new(neutralColor, 10), size = size.tiny)
        stopLabel := label.new(x2, tradeStop, stopText, style = label.style_label_left, textcolor = textColor, color = color.new(bearColor, 10), size = size.tiny)
        tp1Label := label.new(x2, tradeTp1, tp1Text, style = label.style_label_left, textcolor = textColor, color = color.new(tradeColor, 10), size = size.tiny)
        tp2Label := label.new(x2, tradeTp2, "TP2 " + f_price(tradeTp2), style = label.style_label_left, textcolor = textColor, color = color.new(tradeColor, 10), size = size.tiny)

        if allowClean and showTradeStatusBadge
            activeRisk = math.max(math.abs(tradeEntry - tradeStop), syminfo.mintick)
            activeR = tradeSide == 1 ? (close - tradeEntry) / activeRisk : (tradeEntry - close) / activeRisk
            statusY = tradeSide == 1 ? math.max(close, tradeTp1) + volUnit * 0.60 : math.min(close, tradeTp1) - volUnit * 0.60
            statusText = (tradeSide == 1 ? "LONG STATUS" : "SHORT STATUS") + "\nR: " + str.tostring(activeR, "#.00") + "\nTP1: " + (tp1Touched ? "Touched" : "Waiting")
            tradeStatusLabel := label.new(bar_index + 2, statusY, statusText, style = label.style_label_left, textcolor = textColor, color = color.new(tradeColor, 10), size = size.tiny)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
dashPosition = f_pos(dashPosInput)
var table dash = table.new(dashPosition, 2, 16, border_width = 1)

regimeText = impulseState ? "Impulse" : compressionState ? "Compression" : chopState ? "Chop" : expansionState ? "Expansion" : "Drift"
biasText = bias == 1 ? "Long" : bias == -1 ? "Short" : "Neutral"
tradeTextDash = tradeSide == 1 ? "LONG" : tradeSide == -1 ? "SHORT" : "Flat"
predictText = displayPredictionSide == 1 ? "Up" : displayPredictionSide == -1 ? "Down" : "Flat"
mtfText = str.tostring(mtfBullAgree) + "B / " + str.tostring(mtfBearAgree) + "S"
visualText = visualDensity + " / " + visualTheme

if barstate.islast and showDashboard
    bg = color.new(color.black, 74)
    hb = color.new(biasColor, 8)
    vb = color.new(biasColor, 84)
    dashHeaderSize = size.small
    dashBodySize = size.tiny

    table.cell(dash, 0, 0, "Tri-Vector v3.3", text_color = color.white, bgcolor = hb, text_size = dashHeaderSize)
    table.cell(dash, 1, 0, mode + " / " + profile, text_color = color.white, bgcolor = hb, text_size = dashHeaderSize)

    table.cell(dash, 0, 1, "Visuals", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 1, visualText, text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 2, "Bias", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 2, biasText, text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 3, "Trade", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 3, tradeTextDash, text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 4, "Trigger", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 4, activeTrigger, text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 5, "Prediction", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 5, predictText + " " + str.tostring(math.round(displayPredictionConfidence)) + "%", text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 6, "Next Price", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 6, f_price(displayPredictedPrice), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 7, "Long / Short", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 7, str.tostring(math.round(scoreLong)) + " / " + str.tostring(math.round(scoreShort)), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 8, "Min Score", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 8, str.tostring(math.round(dynamicMinScore)), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 9, "Signal Meter", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 9, showDashboardMeters ? f_meter(activeScore) : str.tostring(math.round(activeScore)), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 10, "Forecast Meter", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 10, showDashboardMeters ? f_meter(displayPredictionConfidence) : str.tostring(math.round(displayPredictionConfidence)), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 11, "Regime", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 11, regimeText, text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 12, "Efficiency", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 12, str.tostring(efficiency, "#.00"), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 13, "ADX / Delta", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 13, str.tostring(adx, "#.0") + " / " + str.tostring(deltaNorm, "#.00"), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 14, "MTF Stack", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 14, useMTFStack ? mtfText : "Off", text_color = color.white, bgcolor = vb, text_size = dashBodySize)

    table.cell(dash, 0, 15, "Reg Quality", text_color = color.white, bgcolor = bg, text_size = dashBodySize)
    table.cell(dash, 1, 15, str.tostring(regQuality, "#.00"), text_color = color.white, bgcolor = vb, text_size = dashBodySize)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(longEntrySignal, "Tri-Vector v3.3 LONG Entry", "Tri-Vector v3.3 LONG entry on {{ticker}} {{interval}} close={{close}}")
alertcondition(longExitSignal, "Tri-Vector v3.3 LONG Exit", "Tri-Vector v3.3 LONG exit on {{ticker}} {{interval}} close={{close}}")
alertcondition(shortEntrySignal, "Tri-Vector v3.3 SHORT Entry", "Tri-Vector v3.3 SHORT entry on {{ticker}} {{interval}} close={{close}}")
alertcondition(shortExitSignal, "Tri-Vector v3.3 SHORT Exit", "Tri-Vector v3.3 SHORT exit on {{ticker}} {{interval}} close={{close}}")

longEntryJson = '{"script":"Tri-Vector Flow Predictor v3.3","ticker":"' + syminfo.ticker + '","tickerid":"' + syminfo.tickerid + '","timeframe":"' + timeframe.period + '","event":"LONG_ENTRY","price":' + f_price(close) + ',"score":' + str.tostring(math.round(scoreLong)) + ',"trigger":"' + longTriggerText + '","prediction":' + f_price(displayPredictedPrice) + ',"confidence":' + str.tostring(math.round(displayPredictionConfidence)) + ',"entry":' + f_price(tradeEntry) + ',"stop":' + f_price(tradeStop) + ',"tp1":' + f_price(tradeTp1) + ',"tp2":' + f_price(tradeTp2) + '}'
longExitJson = '{"script":"Tri-Vector Flow Predictor v3.3","ticker":"' + syminfo.ticker + '","tickerid":"' + syminfo.tickerid + '","timeframe":"' + timeframe.period + '","event":"LONG_EXIT","price":' + f_price(close) + ',"prediction":' + f_price(displayPredictedPrice) + ',"confidence":' + str.tostring(math.round(displayPredictionConfidence)) + '}'
shortEntryJson = '{"script":"Tri-Vector Flow Predictor v3.3","ticker":"' + syminfo.ticker + '","tickerid":"' + syminfo.tickerid + '","timeframe":"' + timeframe.period + '","event":"SHORT_ENTRY","price":' + f_price(close) + ',"score":' + str.tostring(math.round(scoreShort)) + ',"trigger":"' + shortTriggerText + '","prediction":' + f_price(displayPredictedPrice) + ',"confidence":' + str.tostring(math.round(displayPredictionConfidence)) + ',"entry":' + f_price(tradeEntry) + ',"stop":' + f_price(tradeStop) + ',"tp1":' + f_price(tradeTp1) + ',"tp2":' + f_price(tradeTp2) + '}'
shortExitJson = '{"script":"Tri-Vector Flow Predictor v3.3","ticker":"' + syminfo.ticker + '","tickerid":"' + syminfo.tickerid + '","timeframe":"' + timeframe.period + '","event":"SHORT_EXIT","price":' + f_price(close) + ',"prediction":' + f_price(displayPredictedPrice) + ',"confidence":' + str.tostring(math.round(displayPredictionConfidence)) + '}'

alertFreq = confirmOnClose ? alert.freq_once_per_bar_close : alert.freq_once_per_bar

if useJsonAlerts and longEntrySignal
    alert(longEntryJson, alertFreq)

if useJsonAlerts and longExitSignal
    alert(longExitJson, alertFreq)

if useJsonAlerts and shortEntrySignal
    alert(shortEntryJson, alertFreq)

if useJsonAlerts and shortExitSignal
    alert(shortExitJson, alertFreq)
````
