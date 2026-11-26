# Adaptive HL Flow Gate Stop Hunt Protection v2

- url: https://www.tradingview.com/script/lcrNw4Ve-Adaptive-HL-Flow-Gate-Stop-Hunt-Protection-v2/
- type: indicator
- pine_id: PUB;67d7884b524b4724ab9e5e3ed799270c
- version: 1.0

## Description

Adaptive H/L Flow Gate + Stop-Hunt Protection v2

This indicator is a discretionary market-flow tool designed to help traders read trend direction, high/low structure, liquidity sweeps, fake wicks, trap zones, and weak-entry conditions.

The script combines an adaptive trend trail, H/L flow gates, stop-hunt proxy zones, candle-body quality, volatility expansion, momentum confirmation, HTF bias, intraday VWAP context, and an entry-quality dashboard.

The main purpose is not to predict every market move. The purpose is to help traders understand when market flow is clean, when price is dangerous, and when a BUY or SELL signal may be lower quality because of chop, trap risk, stretched price, weak candle structure, or higher-timeframe conflict.

What this script does

The indicator reads the market in several layers.

First, it builds an adaptive trend trail using volatility and market efficiency. This trail helps define whether price is behaving bullish, bearish, or unstable.

Second, it builds High/Low Flow Gates. These gates act like a structure filter. When price is above the upper gate, bullish flow is stronger. When price is below the lower gate, bearish flow is stronger. When price is between the gates, the market may be neutral or choppy.

Third, it detects possible buy-side and sell-side sweeps. A buy-side sweep happens when price pushes above a previous high, attracts breakout buyers or triggers short stops, then closes back below the swept level. A sell-side sweep happens when price pushes below a previous low, triggers stops or breakout shorts, then closes back above the swept level.

Fourth, it creates stop-hunt zones. These zones show areas where price may have trapped late traders. The zones are not guaranteed reversal zones. They are warning areas where traders should be more careful.

Fifth, it uses a dashboard to show the current market state, score, quality grade, manipulation risk, HTF direction, filter status, and the main reason why a trade may be blocked.

How beginners should use it

For beginners, the most important part is the dashboard.

Use the Coach row first:

LONG OK means bullish flow is active and conditions are acceptable.
SHORT OK means bearish flow is active and conditions are acceptable.
WAIT CHOP means the market is messy and direction is weak.
TRAP RISK means recent sweep behavior makes entries dangerous.
WAIT STRETCHED means price is too far from the trail and the entry may be late.
WAIT GAP means a large gap created extra risk.

A beginner should not take every BUY or SELL label blindly. The better approach is:

Check the dashboard coach.
Check if the quality grade is A+, A, or B.
Avoid trades when the dashboard says CHOP, TRAP RISK, or LOW quality.
Use the stop-hunt zones as caution areas.
Wait for a retest mark if you want a more conservative entry.
How intermediate traders should use it

Intermediate traders can use the script as a confirmation tool.

A BUY signal is stronger when:

Price is above the H/L Flow Gate.
The adaptive trail is bullish.
HTF direction is bullish or neutral.
Quality grade is B or higher.
Price is not stretched too far from the trail.
There is no active buy-side trap risk blocking longs.

A SELL signal is stronger when:

Price is below the H/L Flow Gate.
The adaptive trail is bearish.
HTF direction is bearish or neutral.
Quality grade is B or higher.
Price is not stretched too far from the trail.
There is no active sell-side trap risk blocking shorts.

Intermediate traders should use the indicator together with support/resistance, session highs/lows, volume, market structure, and personal risk management.

How advanced traders should use it

Advanced traders can use this as a liquidity and flow filter.

The script is useful for identifying:

Failed breakouts
Sweep-and-reclaim behavior
Stop-hunt risk zones
Weak candles after liquidity grabs
Trend continuation after retests
Chop conditions before avoiding false signals
HTF conflict before entering lower-timeframe trades
Overextended price far away from the adaptive trail

The best use case is not “BUY means buy immediately.”
The better use case is:

“Is this signal happening in clean flow, or is it happening inside a trap/chop/stretched environment?”

That is where this script has real value.

How realistic are the signals?

The signals are realistic if used as filters, not as automatic guaranteed entries.

A BUY or SELL signal means the script detected a directional flow change after several conditions were checked. It does not mean the next candle must continue in that direction.

The signals are stronger when:

The quality grade is high.
HTF and middle timeframe agree.
The market is not choppy.
Price is not too stretched.
The candle body is strong.
There is no recent opposite stop-hunt risk.

The signals are weaker when:

The dashboard says WAIT CHOP.
The quality grade is LOW or C.
Price is far away from the trail.
The signal appears after a large wick.
HTF direction disagrees.
A stop-hunt zone is active nearby.

So the honest answer is:

The signals are useful, but they are not meant to be followed blindly.
They are best used as a decision-support system.

Why use this script?

Use this script if you want a cleaner way to answer these questions:

Is the market bullish, bearish, or neutral?
Is this breakout possibly fake?
Did price just sweep liquidity?
Am I entering too late?
Is the current candle strong or weak?
Is the higher timeframe helping or fighting the trade?
Should I wait instead of forcing an entry?
Is price inside a possible trap area?

The biggest advantage is that the script does not only show direction. It also explains risk conditions.

That makes it more useful than a simple moving average, supertrend, or basic BUY/SELL indicator.

Best used for:
• Identifying cleaner trend-flow conditions
• Avoiding weak entries after fake breakouts
• Spotting possible buy-side and sell-side liquidity sweeps
• Filtering trades during chop, trap risk, or stretched price
• Confirming entries with HTF direction, VWAP context, and structure gates
• Helping discretionary traders wait for better-quality setups

Not designed for:
• Guaranteed buy/sell signals
• Fully automated trading without additional confirmation
• Predicting exact tops or bottoms
• Reading real exchange liquidation orders
• Replacing risk management or trader judgment

“Recommended Settings”
Recommended starting settings:
• Visual Preset: Clean
• Trading Style Preset: Auto
• Signal Confirmation: Bar Close
• Use HTF Bias: On
• Stop-Hunt Protection: On
• Show Recent Window Only: On
• Mini Screener: Off unless needed

“How to read labels”
Label guide:
• BUY = bullish flow shift confirmed by the engine
• SELL = bearish flow shift confirmed by the engine
• R = retest opportunity after a confirmed flow shift
• BS = possible buy-side sweep above previous highs
• SS = possible sell-side sweep below previous lows
• TRAP = price is retesting a previous sweep area
• REC = sweep area has been reclaimed
• EXT = price may be overextended from the adaptive trail
• ! = pressure warning against the active flow

Important limitations:

This indicator does not read real liquidation data.

It estimates stop-hunt and liquidation-risk behavior using price-action logic such as failed highs/lows, wick size, range expansion, reclaim behavior, volume pulse when available, and candle quality.

No indicator can guarantee profitable trades. This tool should be used with risk management, stop-loss planning, higher-timeframe analysis, and personal trade confirmation.  
This script is best used as a market-flow and risk-filtering tool, not as a blind signal system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IlSeparatio369

//@version=5
indicator("Adaptive H/L Flow Gate + Stop-Hunt Protection v2 [Open Source]", "H/L Flow Gate Hunt-Pro v2", overlay = true, format = format.price, precision = 4, max_bars_back = 5000, max_lines_count = 420, max_labels_count = 420, max_boxes_count = 220, dynamic_requests = true)

//──────────────────────────────────────────────────────────────────────────────
// PUBLICATION README
//──────────────────────────────────────────────────────────────────────────────
// ADAPTIVE H/L FLOW GATE + STOP-HUNT PROTECTION v2
//
// WHAT THIS INDICATOR DOES
// This indicator is a discretionary market-flow and liquidity-protection tool.
// It combines adaptive trend trailing, high/low flow gates, wick/sweep analysis,
// stop-hunt proxy zones, HTF context, volatility compression, entry-quality
// scoring, and professional visual filtering.
//
// IMPORTANT LIQUIDATION NOTE
// TradingView Pine Script does not provide direct exchange liquidation orders.
// This script does not claim to read real liquidation data. It estimates
// liquidation-risk areas using price-action proxies: failed high/low sweeps,
// abnormal wick expansion, trap reclaim/failure, candle body quality, range
// expansion, volume pulse when available, and structure retests.
//
// NON-REPAINT NOTE
// Default signals confirm on bar close. Higher-timeframe requests use
// barmerge.lookahead_off. Realtime mode is available but less conservative.
//
// REALISTIC USE
// This is not a prediction machine. It is designed to help traders avoid weak
// entries, identify suspicious stop-hunt behavior, and read cleaner directional
// flow with less chart clutter.

//──────────────────────────────────────────────────────────────────────────────
// GROUPS
//──────────────────────────────────────────────────────────────────────────────
groupProfile = "01. Profile / Auto Settings"
groupEngine  = "02. Core Engine"
groupFilter  = "03. Accuracy Filters"
groupHunt    = "04. Stop-Hunt / Fake Wick Protection"
groupHTF     = "05. Multi-Timeframe Context"
groupRisk    = "06. Risk / Entry Firewall"
groupVisual  = "07. Visuals / Clean Chart"
groupSignals = "08. Signals"
groupDash    = "09. Dashboard"
groupScreen  = "10. Mini Screener"
groupAlerts  = "11. Alerts"

//──────────────────────────────────────────────────────────────────────────────
// PROFILE / AUTO SETTINGS
//──────────────────────────────────────────────────────────────────────────────
preset = input.string("Auto", "Trading Style Preset", options = ["Auto", "Scalper", "Day Trader", "Swing", "Position"], group = groupProfile, tooltip = "Auto selects a practical profile from the active chart timeframe.")
visualPreset = input.string("Clean", "Visual Preset", options = ["Minimal", "Clean", "Research"], group = groupProfile, tooltip = "Minimal shows essentials only. Clean is recommended for publishing. Research shows more diagnostics.")
usePresetValues = input.bool(true, "Use Preset Engine Values", group = groupProfile, tooltip = "When enabled, core lengths and multiplier are selected automatically from the trading style.")
roundToTick = input.bool(true, "Round Key Levels To Tick", group = groupProfile, tooltip = "Rounds plotted levels to the symbol tick size for cleaner levels and more realistic alerts.")
smartDensity = input.bool(true, "Auto Visual Density", group = groupProfile, tooltip = "Automatically reduces historical drawings and labels on higher timeframes to keep the chart clean.")

// Auto profile.
autoProfile = preset == "Auto" ? timeframe.isseconds ? "Scalper" : timeframe.isintraday and timeframe.multiplier <= 15 ? "Scalper" : timeframe.isintraday and timeframe.multiplier <= 120 ? "Day Trader" : timeframe.isdaily ? "Swing" : "Position" : preset

autoAtrLen = switch autoProfile
    "Scalper"    => 10
    "Day Trader" => 14
    "Swing"      => 21
    => 34

autoHiloLen = switch autoProfile
    "Scalper"    => 21
    "Day Trader" => 34
    "Swing"      => 55
    => 89

autoSmoothLen = switch autoProfile
    "Scalper"    => 8
    "Day Trader" => 13
    "Swing"      => 21
    => 34

autoMult = switch autoProfile
    "Scalper"    => 2.10
    "Day Trader" => 2.65
    "Swing"      => 3.15
    => 3.75

//──────────────────────────────────────────────────────────────────────────────
// CORE ENGINE INPUTS
//──────────────────────────────────────────────────────────────────────────────
src = input.source(hl2, "Source", group = groupEngine, tooltip = "Main source used by the adaptive trailing engine.")
atrLenManual = input.int(14, "Manual ATR Length", minval = 1, group = groupEngine, tooltip = "Manual ATR length used only when preset values are disabled.")
hiloLenManual = input.int(34, "Manual H/L Structure Length", minval = 2, group = groupEngine, tooltip = "Manual highest/lowest structure length used only when preset values are disabled.")
smoothLenManual = input.int(13, "Manual Smoothing Length", minval = 1, group = groupEngine, tooltip = "Manual smoothing length used only when preset values are disabled.")
multManual = input.float(2.65, "Manual Base Multiplier", minval = 0.10, step = 0.05, group = groupEngine, tooltip = "Manual base volatility multiplier used only when preset values are disabled.")
maType = input.string("EMA", "Gate Smoothing Type", options = ["EMA", "RMA", "SMA", "WMA", "HMA"], group = groupEngine, tooltip = "Smoothing type used for the High/Low Flow Gates.")
parkWeight = input.float(0.35, "Parkinson Volatility Weight", minval = 0.0, maxval = 0.80, step = 0.05, group = groupEngine, tooltip = "Blends ATR with high-low volatility. Higher values react more to range expansion.")
gateTightness = input.float(0.20, "Flow Gate Tightness", minval = 0.05, maxval = 0.45, step = 0.01, group = groupEngine, tooltip = "Controls the neutral gate width. Lower values react faster. Higher values require stronger movement.")
pressureLen = input.int(12, "Pressure Memory Length", minval = 2, maxval = 100, group = groupEngine, tooltip = "Smooths candle-position pressure used as a lightweight order-flow proxy.")

atrLen = usePresetValues ? autoAtrLen : atrLenManual
hiloLen = usePresetValues ? autoHiloLen : hiloLenManual
smoothLen = usePresetValues ? autoSmoothLen : smoothLenManual
baseMult = usePresetValues ? autoMult : multManual

//──────────────────────────────────────────────────────────────────────────────
// ACCURACY FILTER INPUTS
//──────────────────────────────────────────────────────────────────────────────
signalMode = input.string("Bar Close", "Signal Confirmation", options = ["Bar Close", "Realtime"], group = groupFilter, tooltip = "Bar Close is safer for publication. Realtime reacts faster but can change before candle close.")
scoreThreshold = input.int(58, "Flow Score Threshold", minval = 20, maxval = 95, group = groupFilter, tooltip = "Minimum confidence score needed to lock bullish or bearish flow.")
useNeutralState = input.bool(true, "Allow Neutral State", group = groupFilter, tooltip = "When enabled, weak conditions can return the engine to neutral instead of forcing a direction.")
neutralThreshold = input.int(28, "Neutral Reset Threshold", minval = 5, maxval = 60, group = groupFilter, tooltip = "If absolute score falls below this value, the engine can reset to neutral.")
useChopFilter = input.bool(true, "Use Chop Filter", group = groupFilter, tooltip = "Blocks fresh direction changes when efficiency and trend strength are poor.")
erLen = input.int(20, "Efficiency Ratio Length", minval = 2, group = groupFilter, tooltip = "Measures directional efficiency. Low values usually mean sideways noise.")
minER = input.float(0.18, "Minimum Efficiency Ratio", minval = 0.01, maxval = 0.80, step = 0.01, group = groupFilter, tooltip = "Fresh flips are blocked when efficiency is below this value.")
adxLen = input.int(14, "ADX Length", minval = 2, group = groupFilter, tooltip = "Length used to measure trend strength.")
adxSmooth = input.int(14, "ADX Smoothing", minval = 2, group = groupFilter, tooltip = "Smoothing used by ADX calculation.")
minADX = input.float(14.0, "Minimum ADX For Fresh Flips", minval = 1.0, maxval = 50.0, step = 0.5, group = groupFilter, tooltip = "Fresh flips are blocked when ADX is below this value.")
momLen = input.int(14, "Momentum Length", minval = 2, group = groupFilter, tooltip = "Length for MFI or RSI momentum confirmation.")
momDeadband = input.float(3.0, "Momentum Deadband Around 50", minval = 0.0, maxval = 20.0, step = 0.5, group = groupFilter, tooltip = "Momentum must move away from 50 by this amount to count as directional.")
minBarsBetweenFlips = input.int(3, "Minimum Bars Between Direction Flips", minval = 0, maxval = 100, group = groupFilter, tooltip = "Reduces whipsaw by preventing instant repeated bull/bear flips.")
useVolumePulse = input.bool(true, "Use Volume Pulse", group = groupFilter, tooltip = "Adds small score confirmation when volume expands in the candle direction.")
volLen = input.int(20, "Volume Average Length", minval = 1, group = groupFilter, tooltip = "Average volume length for pulse detection.")
volPulseMult = input.float(1.35, "Volume Pulse Multiplier", minval = 0.50, step = 0.05, group = groupFilter, tooltip = "Volume must be above average multiplied by this value to count as a pulse.")
useExpansionGate = input.bool(true, "Use Compression-To-Expansion Gate", group = groupFilter, tooltip = "Detects when volatility compresses and then expands. This helps identify stronger breakout conditions.")
compressionLen = input.int(40, "Compression Lookback", minval = 10, maxval = 300, group = groupFilter, tooltip = "Lookback used to compare current volatility against recent volatility.")
compressionPct = input.float(0.78, "Compression Threshold", minval = 0.30, maxval = 1.20, step = 0.01, group = groupFilter, tooltip = "Values below this threshold mean current volatility is compressed versus recent volatility.")

//──────────────────────────────────────────────────────────────────────────────
// STOP-HUNT / FAKE WICK INPUTS
//──────────────────────────────────────────────────────────────────────────────
useHuntProtection = input.bool(true, "Use Stop-Hunt Protection", group = groupHunt, tooltip = "Uses fake-wick and failed-sweep behavior to block weak entries after likely stop-hunt events.")
huntBlockBars = input.int(8, "Bars To Block After Opposite Sweep", minval = 1, maxval = 100, group = groupHunt, tooltip = "Number of bars a weak opposite entry can be blocked after a fake wick or sweep.")
liqRiskBlockScore = input.int(58, "Liquidation Proxy Risk Block Score", minval = 10, maxval = 100, group = groupHunt, tooltip = "Higher values block fewer trades. Lower values make stop-hunt protection stricter.")
sweepLookback = input.int(20, "Sweep Lookback", minval = 3, maxval = 300, group = groupHunt, tooltip = "Looks back this many bars to detect failed breaks above highs or below lows.")
wickMinPct = input.float(0.45, "Minimum Wick % Of Candle", minval = 0.10, maxval = 0.90, step = 0.05, group = groupHunt, tooltip = "Minimum wick share of the candle range required to classify a fake wick.")
rangeSpikeMult = input.float(1.35, "Range Expansion Multiplier", minval = 0.50, step = 0.05, group = groupHunt, tooltip = "Candle range must exceed average range by this multiplier to qualify as an aggressive sweep.")
requireVolumeForSweep = input.bool(false, "Require Volume Pulse For Sweep", group = groupHunt, tooltip = "When enabled, sweep detection requires volume expansion. Leave disabled for forex or unreliable volume.")
sweepVolMult = input.float(1.50, "Sweep Volume Multiplier", minval = 0.50, step = 0.05, group = groupHunt, tooltip = "Volume must be above average multiplied by this value when volume confirmation is required.")
useBodyQuality = input.bool(true, "Use Candle Body Quality Filter", group = groupHunt, tooltip = "Blocks weak fresh entries when candle body is too small compared with wick size.")
minBodyPct = input.float(0.22, "Minimum Body % For Fresh Flip", minval = 0.01, maxval = 0.80, step = 0.01, group = groupHunt, tooltip = "Fresh direction flips are weaker when the candle body is below this share of total range.")
useSweepClusterFilter = input.bool(true, "Require Stronger Sweeps In Clusters", group = groupHunt, tooltip = "When many sweeps happen close together, only stronger sweeps create new zones.")
clusterBars = input.int(12, "Sweep Cluster Bars", minval = 2, maxval = 100, group = groupHunt, tooltip = "Bars used to decide whether sweeps are clustered.")
clusterExtraStrength = input.int(12, "Cluster Strength Add-On", minval = 0, maxval = 50, group = groupHunt, tooltip = "Extra strength required for a new zone when sweeps are clustered.")
showSweepMarks = input.bool(true, "Show Fake Wick Marks", group = groupHunt, tooltip = "Shows small labels on failed high/low sweeps.")
showSweepZones = input.bool(true, "Draw Stop-Hunt Zones", group = groupHunt, tooltip = "Draws stop-hunt zones using boxes, trap lines, and small labels.")
extendActiveZones = input.bool(true, "Extend Active Zones", group = groupHunt, tooltip = "Active stop-hunt zones extend forward until invalidated or visually pruned.")
activeZoneForwardBars = input.int(24, "Active Zone Forward Bars", minval = 2, maxval = 300, group = groupHunt, tooltip = "How far active stop-hunt zones extend beyond the current bar.")
showTrapLines = input.bool(true, "Show Trap Lines Inside Zones", group = groupHunt, tooltip = "Draws the swept structure level inside each stop-hunt zone.")
showZoneLabels = input.bool(true, "Show Zone Labels", group = groupHunt, tooltip = "Shows compact labels such as Buy-Side Sweep and Sell-Side Sweep.")
showReclaimMarks = input.bool(true, "Show Trap Reclaim Marks", group = groupHunt, tooltip = "Shows when price reclaims beyond a previous sweep and weakens the trap idea.")
showTrapRetest = input.bool(true, "Show Trap Retest Marks", group = groupHunt, tooltip = "Shows when price revisits the most recent trap level after a sweep.")
sweepZoneBars = input.int(40, "Initial Stop-Hunt Zone Extension Bars", minval = 2, maxval = 300, group = groupHunt, tooltip = "Initial right extension of each newly detected fake-wick zone.")
maxSweepZones = input.int(8, "Maximum Stop-Hunt Zones", minval = 1, maxval = 40, group = groupHunt, tooltip = "Limits visible sweep zones to keep the chart clean.")
zoneTransp = input.int(90, "Stop-Hunt Zone Transparency", minval = 0, maxval = 100, group = groupHunt, tooltip = "Higher values make stop-hunt zones more subtle.")
invalidZoneTransp = input.int(96, "Invalidated Zone Transparency", minval = 0, maxval = 100, group = groupHunt, tooltip = "Transparency used after a zone is invalidated by price reclaim.")

//──────────────────────────────────────────────────────────────────────────────
// MULTI-TIMEFRAME CONTEXT
//──────────────────────────────────────────────────────────────────────────────
useHTF = input.bool(true, "Use HTF Bias In Score", group = groupHTF, tooltip = "Adds higher-timeframe EMA slope into the confidence score.")
blockHTFConflict = input.bool(true, "Block Weak Signals Against HTF", group = groupHTF, tooltip = "Blocks fresh low-quality signals when the higher timeframe points the opposite way.")
htfMode = input.string("Auto", "HTF Timeframe", options = ["Auto", "5", "15", "60", "240", "D", "W", "M", "3M"], group = groupHTF, tooltip = "Auto selects a higher timeframe based on the chart. Manual values give more control.")
htfLen = input.int(55, "HTF EMA Length", minval = 1, group = groupHTF, tooltip = "EMA length used to measure higher-timeframe slope.")
useMidTF = input.bool(true, "Use Middle-Timeframe Guard", group = groupHTF, tooltip = "Adds a second timeframe between the chart and HTF to reduce weak counterflow flips.")
midTfMode = input.string("Auto", "Middle Timeframe", options = ["Auto", "5", "15", "60", "240", "D", "W", "M"], group = groupHTF, tooltip = "Auto selects a middle timeframe for additional confirmation.")
useVWAPBias = input.bool(true, "Use Session VWAP Bias On Intraday", group = groupHTF, tooltip = "Adds small intraday bias when price is above or below session VWAP. Ignored when unavailable.")

// Auto timeframes.
autoHtf = timeframe.isseconds ? "5" : timeframe.isintraday and timeframe.multiplier <= 5 ? "60" : timeframe.isintraday and timeframe.multiplier <= 30 ? "240" : timeframe.isintraday ? "D" : timeframe.isdaily ? "W" : timeframe.isweekly ? "M" : "3M"
autoMidTf = timeframe.isseconds ? "5" : timeframe.isintraday and timeframe.multiplier <= 15 ? "60" : timeframe.isintraday and timeframe.multiplier <= 120 ? "240" : timeframe.isdaily ? "W" : timeframe.isweekly ? "M" : "M"
effectiveHtf = htfMode == "Auto" ? autoHtf : htfMode
effectiveMidTf = midTfMode == "Auto" ? autoMidTf : midTfMode

//──────────────────────────────────────────────────────────────────────────────
// RISK / ENTRY FIREWALL
//──────────────────────────────────────────────────────────────────────────────
showRiskBands = input.bool(false, "Show Risk Planning Bands", group = groupRisk, tooltip = "Shows dynamic 1R and 2R planning levels from price to adaptive trail. These are planning guides, not guaranteed targets.")
rr1 = input.float(1.0, "Target 1R", minval = 0.25, step = 0.25, group = groupRisk, tooltip = "First planning target multiple based on distance from price to adaptive trail.")
rr2 = input.float(2.0, "Target 2R", minval = 0.50, step = 0.25, group = groupRisk, tooltip = "Second planning target multiple based on distance from price to adaptive trail.")
riskLineTransp = input.int(84, "Risk Band Transparency", minval = 0, maxval = 100, group = groupRisk, tooltip = "Higher values make risk planning bands lighter.")
useStretchFirewall = input.bool(true, "Use Stretch Risk Firewall", group = groupRisk, tooltip = "Blocks fresh signals when price is already too far from the adaptive trail.")
maxEntryStretchATR = input.float(3.20, "Maximum Entry Stretch ATR", minval = 0.50, step = 0.10, group = groupRisk, tooltip = "Fresh entries are blocked when price is more than this many volatility units from the adaptive trail.")
useGapRiskFilter = input.bool(true, "Use Gap Risk Filter", group = groupRisk, tooltip = "Blocks fresh flips after unusually large opening gaps versus the previous close.")
gapRiskATR = input.float(1.20, "Gap Risk ATR Multiple", minval = 0.10, maxval = 10.0, step = 0.10, group = groupRisk, tooltip = "Opening gap is risky when open minus previous close exceeds this many volatility units.")
showLiquidityMagnet = input.bool(true, "Show Last-Bar Liquidity Magnet", group = groupRisk, tooltip = "Draws one clean last-bar target line toward the nearest relevant high or low liquidity pool.")
magnetLookback = input.int(80, "Liquidity Magnet Lookback", minval = 10, maxval = 500, group = groupRisk, tooltip = "Lookback used to find the most relevant high or low liquidity magnet.")
showRoundMagnet = input.bool(false, "Show Round-Number Magnet", group = groupRisk, tooltip = "Shows the nearest rounded price magnet as a subtle last-bar guide.")
manualRoundStep = input.float(0.0, "Manual Round Step, 0 = Auto", minval = 0.0, step = 0.01, group = groupRisk, tooltip = "Set a custom round-number step. Zero automatically estimates a practical step from price.")

//──────────────────────────────────────────────────────────────────────────────
// VISUALS / CLEAN CHART
//──────────────────────────────────────────────────────────────────────────────
showRecentOnly = input.bool(true, "Show Recent Window Only", group = groupVisual, tooltip = "Keeps old history clean by showing main visuals only on recent bars.")
recentBars = input.int(450, "Recent Window Bars", minval = 50, maxval = 5000, group = groupVisual, tooltip = "Number of bars where cloud, rails, signals, warnings, and marks remain visible.")
showTrail = input.bool(true, "Show Adaptive Trail", group = groupVisual, tooltip = "Shows the active adaptive trailing level.")
showPulseRail = input.bool(true, "Show Pulse Rail Glow", group = groupVisual, tooltip = "Adds a soft glow behind the active trail to make current flow easier to read.")
showGates = input.bool(true, "Show H/L Flow Gates", group = groupVisual, tooltip = "Shows upper and lower market-structure flow gates.")
showCloud = input.bool(true, "Show Flow Cloud", group = groupVisual, tooltip = "Fills the gate area. Green is bullish, red is bearish, gray is neutral.")
cloudTransp = input.int(90, "Cloud Transparency", minval = 0, maxval = 100, group = groupVisual, tooltip = "Higher values create a cleaner lighter cloud.")
lineTransp = input.int(12, "Main Line Transparency", minval = 0, maxval = 100, group = groupVisual, tooltip = "Transparency for main trail and gate lines.")
showRegimeHalo = input.bool(false, "Show Subtle Regime Background", group = groupVisual, tooltip = "Adds a very light background tint when trend quality is strong. Disabled by default for cleaner candles.")
colorCandles = input.bool(false, "Color Candles", group = groupVisual, tooltip = "Optional candle coloring by flow direction. Disabled by default to keep original candles clean.")
candleTransp = input.int(76, "Candle Color Transparency", minval = 0, maxval = 100, group = groupVisual, tooltip = "Higher values keep candles more visible.")
showHeroLabel = input.bool(true, "Show Last-Bar Status Label", group = groupVisual, tooltip = "Shows one compact label on the latest bar with state, score, quality, and risk.")
heroOffsetATR = input.float(0.70, "Last-Bar Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = groupVisual, tooltip = "Vertical offset for the last-bar status label.")
bullColor = input.color(color.rgb(0, 188, 125), "Bull Color", group = groupVisual)
bearColor = input.color(color.rgb(236, 64, 122), "Bear Color", group = groupVisual)
neutralColor = input.color(color.rgb(145, 145, 145), "Neutral Color", group = groupVisual)
buySideColor = input.color(color.rgb(255, 152, 0), "Buy-Side Sweep Color", group = groupVisual)
sellSideColor = input.color(color.rgb(41, 121, 255), "Sell-Side Sweep Color", group = groupVisual)
magnetColor = input.color(color.rgb(255, 202, 40), "Liquidity Magnet Color", group = groupVisual)

//──────────────────────────────────────────────────────────────────────────────
// SIGNALS
//──────────────────────────────────────────────────────────────────────────────
showSignalLabels = input.bool(true, "Show BUY / SELL Labels", group = groupSignals, tooltip = "Shows main flow direction labels. Old labels are automatically deleted.")
maxSignalLabels = input.int(6, "Maximum Signal Labels", minval = 1, maxval = 30, group = groupSignals, tooltip = "Limits visible signal labels to keep chart professional.")
showRetests = input.bool(true, "Show Retest Entries", group = groupSignals, tooltip = "Shows small retest marks after a trend flip when price returns to the gate and confirms again.")
retestDelayBars = input.int(3, "Minimum Bars After Flip For Retest", minval = 1, maxval = 50, group = groupSignals, tooltip = "Prevents immediate retest marks directly after a fresh flip.")
showContinuationDots = input.bool(true, "Show Continuation Dots", group = groupSignals, tooltip = "Small dots show trend continuation without large repeated labels.")
dotSpacing = input.int(7, "Continuation Dot Spacing", minval = 1, maxval = 50, group = groupSignals, tooltip = "Higher values show fewer continuation dots.")
showWarnings = input.bool(true, "Show Countertrend / Exhaustion Warnings", group = groupSignals, tooltip = "Shows warning marks when the active trend becomes stretched or pressure appears against it.")
exhaustionATR = input.float(2.80, "Exhaustion Distance From Trail ATR", minval = 0.50, step = 0.10, group = groupSignals, tooltip = "Trend is considered stretched when price is this many volatility units away from the adaptive trail.")
showOnlyHighQualityFlips = input.bool(false, "Only Label A/B Quality Flips", group = groupSignals, tooltip = "When enabled, weak C/LOW flow flips update the engine but do not print BUY/SELL labels.")

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
showDashboard = input.bool(true, "Show Dashboard", group = groupDash, tooltip = "Shows profile, state, score, HTF, chop, stop-hunt risk, and quality.")
dashPosition = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupDash)
dashText = input.string("Tiny", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = groupDash)
showFirewallRow = input.bool(true, "Show Firewall Detail", group = groupDash, tooltip = "Shows the main reason a fresh entry is blocked.")

//──────────────────────────────────────────────────────────────────────────────
// MINI SCREENER
//──────────────────────────────────────────────────────────────────────────────
showScreener = input.bool(false, "Show 5-Symbol Mini Screener", group = groupScreen, tooltip = "Optional lightweight screener using the same general flow logic. Disable for maximum performance.")
screenPosition = input.string("Bottom Right", "Screener Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupScreen)
sym1 = input.symbol("BINANCE:BTCUSDT", "Symbol 1", group = groupScreen)
tf1 = input.timeframe("", "TF 1", group = groupScreen)
sym2 = input.symbol("BINANCE:ETHUSDT", "Symbol 2", group = groupScreen)
tf2 = input.timeframe("", "TF 2", group = groupScreen)
sym3 = input.symbol("NASDAQ:AAPL", "Symbol 3", group = groupScreen)
tf3 = input.timeframe("", "TF 3", group = groupScreen)
sym4 = input.symbol("NASDAQ:TSLA", "Symbol 4", group = groupScreen)
tf4 = input.timeframe("", "TF 4", group = groupScreen)
sym5 = input.symbol("TVC:DXY", "Symbol 5", group = groupScreen)
tf5 = input.timeframe("", "TF 5", group = groupScreen)

//──────────────────────────────────────────────────────────────────────────────
// ALERT INPUTS
//──────────────────────────────────────────────────────────────────────────────
alertOnlyConfirmed = input.bool(true, "Alerts Only On Confirmed Bars", group = groupAlerts, tooltip = "Keeps alerts aligned with confirmed non-repaint signal mode.")

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
f_clamp(_x, _lo, _hi) =>
    math.min(math.max(_x, _lo), _hi)

f_ma(_x, _len, _type) =>
    float _out = na
    if _type == "EMA"
        _out := ta.ema(_x, _len)
    else if _type == "RMA"
        _out := ta.rma(_x, _len)
    else if _type == "SMA"
        _out := ta.sma(_x, _len)
    else if _type == "WMA"
        _out := ta.wma(_x, _len)
    else
        _half = math.max(1, int(math.round(_len * 0.5)))
        _sqrt = math.max(1, int(math.round(math.sqrt(_len))))
        _out := ta.wma(2.0 * ta.wma(_x, _half) - ta.wma(_x, _len), _sqrt)
    _out

f_tick(_x) =>
    roundToTick and syminfo.mintick > 0 ? math.round(_x / syminfo.mintick) * syminfo.mintick : _x

f_pos(_p) =>
    _p == "Top Right" ? position.top_right : _p == "Top Left" ? position.top_left : _p == "Bottom Right" ? position.bottom_right : position.bottom_left

f_size(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : size.normal

f_dirText(_d) =>
    _d == 1 ? "BULL" : _d == -1 ? "BEAR" : "NEUTRAL"

f_dirColor(_d) =>
    _d == 1 ? bullColor : _d == -1 ? bearColor : neutralColor

f_tf(_tf) =>
    _tf == "" ? timeframe.period : _tf

f_htfSlope() =>
    _ema = ta.ema(close, htfLen)
    _ema > _ema[1] ? 1 : _ema < _ema[1] ? -1 : 0

f_grade(_q) =>
    _q >= 85 ? "A+" : _q >= 75 ? "A" : _q >= 65 ? "B" : _q >= 50 ? "C" : "LOW"

f_boolText(_x) =>
    _x ? "YES" : "NO"

f_roundStep(_price) =>
    manualRoundStep > 0.0 ? manualRoundStep : _price >= 100000.0 ? 5000.0 : _price >= 10000.0 ? 1000.0 : _price >= 1000.0 ? 100.0 : _price >= 100.0 ? 10.0 : _price >= 10.0 ? 1.0 : math.max(syminfo.mintick * 100.0, syminfo.mintick)

//──────────────────────────────────────────────────────────────────────────────
// EFFECTIVE VISUAL SETTINGS
//──────────────────────────────────────────────────────────────────────────────
isMinimal = visualPreset == "Minimal"
isResearch = visualPreset == "Research"
autoRecentBars = timeframe.isintraday ? 450 : timeframe.isdaily ? 280 : 180
recentBarsEff = smartDensity ? math.min(recentBars, autoRecentBars) : recentBars
maxSignalLabelsEff = smartDensity and timeframe.isdaily ? math.min(maxSignalLabels, 5) : maxSignalLabels
maxSweepZonesEff = smartDensity ? visualPreset == "Research" ? maxSweepZones : math.min(maxSweepZones, 6) : maxSweepZones

showCloudEff = showCloud and not isMinimal
showPulseRailEff = showPulseRail and not isMinimal
showWarningsEff = showWarnings and not isMinimal
showRetestsEff = showRetests and not isMinimal
showDotsEff = showContinuationDots and not isMinimal
showSweepMarksEff = showSweepMarks and not isMinimal
showSweepZonesEff = showSweepZones and not isMinimal
inRecent = not showRecentOnly or bar_index >= last_bar_index - recentBarsEff

//──────────────────────────────────────────────────────────────────────────────
// VOLATILITY ENGINE
//──────────────────────────────────────────────────────────────────────────────
atrClassic = ta.atr(atrLen)
logHL = low > 0.0 ? math.log(high / low) : 0.0
parkVol = math.sqrt((1.0 / (4.0 * math.log(2.0))) * ta.sma(logHL * logHL, atrLen)) * close
hybridATR = atrClassic * (1.0 - parkWeight) + parkVol * parkWeight

atrBase = ta.sma(hybridATR, atrLen * 3)
volRatio = atrBase != 0.0 ? hybridATR / atrBase : 1.0
volFactor = f_clamp(nz(volRatio, 1.0), 0.80, 1.45)

erMove = math.abs(close - nz(close[erLen], close))
erNoise = math.sum(math.abs(close - nz(close[1], close)), erLen)
effRatio = erNoise != 0.0 ? erMove / erNoise : 0.0
erFactor = f_clamp(1.20 - effRatio * 0.45, 0.75, 1.35)

[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxSmooth)
adxFactor = adxValue < minADX ? 1.12 : adxValue > 35.0 ? 0.92 : 1.00
adaptiveMult = baseMult * volFactor * erFactor * adxFactor

avgHybrid = ta.sma(hybridATR, compressionLen)
compressionRatio = avgHybrid != 0.0 ? hybridATR / avgHybrid : 1.0
wasCompressed = compressionRatio[1] < compressionPct

//──────────────────────────────────────────────────────────────────────────────
// ADAPTIVE TRAIL ENGINE
//──────────────────────────────────────────────────────────────────────────────
basicUp = src - adaptiveMult * hybridATR
basicDn = src + adaptiveMult * hybridATR

var float trailUp = na
var float trailDn = na

prevTrailUp = nz(trailUp[1], basicUp)
prevTrailDn = nz(trailDn[1], basicDn)

trailUp := close[1] > prevTrailUp ? math.max(basicUp, prevTrailUp) : basicUp
trailDn := close[1] < prevTrailDn ? math.min(basicDn, prevTrailDn) : basicDn

var int stDir = 1
stDir := nz(stDir[1], 1)
stDir := stDir == -1 and close > prevTrailDn ? 1 : stDir == 1 and close < prevTrailUp ? -1 : stDir

trailRaw = stDir == 1 ? trailUp : trailDn
trail = f_tick(trailRaw)

//──────────────────────────────────────────────────────────────────────────────
// H/L FLOW GATES
//──────────────────────────────────────────────────────────────────────────────
hiBasis = f_ma(ta.highest(high, hiloLen), smoothLen, maType)
loBasis = f_ma(ta.lowest(low, hiloLen), smoothLen, maType)

gateMidRaw = (hiBasis + loBasis) * 0.5
gateRange = math.max(hiBasis - loBasis, hybridATR * 2.0)

upperGateRaw = gateMidRaw + gateRange * gateTightness
lowerGateRaw = gateMidRaw - gateRange * gateTightness

upperGate = f_tick(upperGateRaw)
lowerGate = f_tick(lowerGateRaw)
gateMid = f_tick(gateMidRaw)

gateDir = close > upperGate ? 1 : close < lowerGate ? -1 : 0
premiumDiscount = close >= gateMid ? "PREMIUM" : "DISCOUNT"

//──────────────────────────────────────────────────────────────────────────────
// CANDLE / STOP-HUNT DATA
//──────────────────────────────────────────────────────────────────────────────
candleRange = high - low
bodySize = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bodyPct = candleRange > 0.0 ? bodySize / candleRange : 1.0
upperWickPct = candleRange > 0.0 ? upperWick / candleRange : 0.0
lowerWickPct = candleRange > 0.0 ? lowerWick / candleRange : 0.0
closePosition = candleRange > 0.0 ? (close - low) / candleRange : 0.5
signedClosePosition = (closePosition - 0.5) * 2.0

avgRange = ta.sma(candleRange, sweepLookback)
rangeExpansion = avgRange > 0.0 and candleRange > avgRange * rangeSpikeMult
expansionNow = useExpansionGate and wasCompressed and compressionRatio > 1.05 and candleRange > nz(avgRange, candleRange)

volAvg = ta.sma(volume, volLen)
hasVolume = not na(volume) and volume > 0 and volAvg > 0
volumePulseRaw = hasVolume and volume > volAvg * volPulseMult
volWeight = hasVolume ? f_clamp(volume / volAvg, 0.50, 2.25) : 1.0
pressureRaw = signedClosePosition * volWeight
pressure = ta.ema(pressureRaw, pressureLen)
pressureDir = pressure > 0.18 ? 1 : pressure < -0.18 ? -1 : 0

sweepVolOk = not requireVolumeForSweep or not hasVolume or volume > volAvg * sweepVolMult
priorHigh = ta.highest(high[1], sweepLookback)
priorLow = ta.lowest(low[1], sweepLookback)

buySideSweepCore = useHuntProtection and sweepVolOk and rangeExpansion and high > priorHigh and close < priorHigh and upperWickPct >= wickMinPct
sellSideSweepCore = useHuntProtection and sweepVolOk and rangeExpansion and low < priorLow and close > priorLow and lowerWickPct >= wickMinPct

fakeBuySideWick = useHuntProtection and sweepVolOk and high > priorHigh and upperWickPct >= wickMinPct and close < open
fakeSellSideWick = useHuntProtection and sweepVolOk and low < priorLow and lowerWickPct >= wickMinPct and close > open

buySideStrengthNow = f_clamp(upperWickPct * 55.0 + (rangeExpansion ? 20.0 : 0.0) + (sweepVolOk ? 15.0 : 0.0) + (volumePulseRaw ? 10.0 : 0.0), 0.0, 100.0)
sellSideStrengthNow = f_clamp(lowerWickPct * 55.0 + (rangeExpansion ? 20.0 : 0.0) + (sweepVolOk ? 15.0 : 0.0) + (volumePulseRaw ? 10.0 : 0.0), 0.0, 100.0)

sweepClusteredBuy = ta.barssince(buySideSweepCore or fakeBuySideWick) <= clusterBars
sweepClusteredSell = ta.barssince(sellSideSweepCore or fakeSellSideWick) <= clusterBars
buySideStrengthGate = liqRiskBlockScore + (useSweepClusterFilter and sweepClusteredBuy ? clusterExtraStrength : 0)
sellSideStrengthGate = liqRiskBlockScore + (useSweepClusterFilter and sweepClusteredSell ? clusterExtraStrength : 0)

buySideSweep = (buySideSweepCore or fakeBuySideWick) and buySideStrengthNow >= math.min(buySideStrengthGate, 95)
sellSideSweep = (sellSideSweepCore or fakeSellSideWick) and sellSideStrengthNow >= math.min(sellSideStrengthGate, 95)

manipulationIndex = f_clamp(math.max(upperWickPct, lowerWickPct) * 42.0 + (rangeExpansion ? 24.0 : 0.0) + (volumePulseRaw ? 14.0 : 0.0) + ((buySideSweep or sellSideSweep) ? 20.0 : 0.0), 0.0, 100.0)

var float lastBuySideSweepHigh = na
var float lastBuySideSweepLevel = na
var float lastBuySideStrength = na
var int lastBuySideSweepBar = na

var float lastSellSideSweepLow = na
var float lastSellSideSweepLevel = na
var float lastSellSideStrength = na
var int lastSellSideSweepBar = na

if buySideSweep
    lastBuySideSweepHigh := high
    lastBuySideSweepLevel := priorHigh
    lastBuySideStrength := buySideStrengthNow
    lastBuySideSweepBar := bar_index

if sellSideSweep
    lastSellSideSweepLow := low
    lastSellSideSweepLevel := priorLow
    lastSellSideStrength := sellSideStrengthNow
    lastSellSideSweepBar := bar_index

barsSinceBuySideSweep = na(lastBuySideSweepBar) ? 100000 : bar_index - lastBuySideSweepBar
barsSinceSellSideSweep = na(lastSellSideSweepBar) ? 100000 : bar_index - lastSellSideSweepBar

buySideSweepActive = barsSinceBuySideSweep <= huntBlockBars
sellSideSweepActive = barsSinceSellSideSweep <= huntBlockBars

buySideDecay = buySideSweepActive ? f_clamp(1.0 - barsSinceBuySideSweep / huntBlockBars, 0.0, 1.0) : 0.0
sellSideDecay = sellSideSweepActive ? f_clamp(1.0 - barsSinceSellSideSweep / huntBlockBars, 0.0, 1.0) : 0.0

activeBuySideRisk = nz(lastBuySideStrength, 0.0) * buySideDecay
activeSellSideRisk = nz(lastSellSideStrength, 0.0) * sellSideDecay
activeLiqRisk = math.max(activeBuySideRisk, activeSellSideRisk)

buySideReclaimed = not na(lastBuySideSweepHigh) and close > lastBuySideSweepHigh
sellSideReclaimed = not na(lastSellSideSweepLow) and close < lastSellSideSweepLow

buySideReclaimNow = showReclaimMarks and buySideSweepActive and buySideReclaimed and not nz(buySideReclaimed[1], false)
sellSideReclaimNow = showReclaimMarks and sellSideSweepActive and sellSideReclaimed and not nz(sellSideReclaimed[1], false)

trapRetestBuySide = showTrapRetest and buySideSweepActive and not buySideReclaimed and not na(lastBuySideSweepLevel) and high >= lastBuySideSweepLevel and close < lastBuySideSweepLevel
trapRetestSellSide = showTrapRetest and sellSideSweepActive and not sellSideReclaimed and not na(lastSellSideSweepLevel) and low <= lastSellSideSweepLevel and close > lastSellSideSweepLevel

blockLongAfterBuySideSweep = useHuntProtection and buySideSweepActive and activeBuySideRisk >= liqRiskBlockScore and not buySideReclaimed
blockShortAfterSellSideSweep = useHuntProtection and sellSideSweepActive and activeSellSideRisk >= liqRiskBlockScore and not sellSideReclaimed

weakBodyFlip = useBodyQuality and bodyPct < minBodyPct and (upperWickPct >= wickMinPct or lowerWickPct >= wickMinPct)

//──────────────────────────────────────────────────────────────────────────────
// STOP-HUNT ZONE DRAWING / LIFECYCLE MANAGER
//──────────────────────────────────────────────────────────────────────────────
var box[] huntBoxes = array.new_box()
var line[] huntLines = array.new_line()
var label[] huntLabels = array.new_label()
var int[] huntTypes = array.new_int()
var bool[] huntActive = array.new_bool()

f_addHuntZone(_type, _top, _bottom, _trapLevel, _strength) =>
    _isBuySide = _type == 1
    _col = _isBuySide ? buySideColor : sellSideColor
    _txt = _isBuySide ? "Buy-side sweep\nNo weak longs" : "Sell-side sweep\nNo weak shorts"
    _labelStyle = _isBuySide ? label.style_label_down : label.style_label_up
    _labelY = _isBuySide ? _top : _bottom
    _right = bar_index + sweepZoneBars
    _b = box.new(left = bar_index, top = _top, right = _right, bottom = _bottom, xloc = xloc.bar_index, bgcolor = color.new(_col, zoneTransp), border_color = color.new(_col, 42), border_width = 1)
    _l = line.new(bar_index, _trapLevel, _right, _trapLevel, xloc = xloc.bar_index, extend = extend.none, color = showTrapLines ? color.new(_col, 12) : color.new(_col, 100), style = line.style_dotted, width = 1)
    _lb = label.new(bar_index, _labelY, showZoneLabels ? _txt + "\nStrength " + str.tostring(math.round(_strength)) : "", xloc = xloc.bar_index, style = _labelStyle, color = showZoneLabels ? color.new(_col, 0) : color.new(_col, 100), textcolor = color.white, size = size.tiny)
    array.push(huntBoxes, _b)
    array.push(huntLines, _l)
    array.push(huntLabels, _lb)
    array.push(huntTypes, _type)
    array.push(huntActive, true)
    if array.size(huntBoxes) > maxSweepZonesEff
        _oldB = array.shift(huntBoxes)
        _oldL = array.shift(huntLines)
        _oldLb = array.shift(huntLabels)
        array.shift(huntTypes)
        array.shift(huntActive)
        box.delete(_oldB)
        line.delete(_oldL)
        label.delete(_oldLb)

f_manageHuntZones() =>
    if array.size(huntBoxes) > 0
        for i = 0 to array.size(huntBoxes) - 1
            _b = array.get(huntBoxes, i)
            _l = array.get(huntLines, i)
            _lb = array.get(huntLabels, i)
            _type = array.get(huntTypes, i)
            _active = array.get(huntActive, i)
            _top = box.get_top(_b)
            _bottom = box.get_bottom(_b)
            _invalid = _type == 1 ? close > _top : close < _bottom
            if _active and _invalid
                array.set(huntActive, i, false)
                _col = _type == 1 ? buySideColor : sellSideColor
                box.set_bgcolor(_b, color.new(_col, invalidZoneTransp))
                box.set_border_color(_b, color.new(_col, 82))
                line.set_color(_l, color.new(_col, 78))
                label.set_color(_lb, color.new(_col, 85))
                label.set_text(_lb, "Invalidated")
            else if _active and extendActiveZones
                _right = bar_index + activeZoneForwardBars
                box.set_right(_b, _right)
                line.set_x2(_l, _right)

if showSweepZonesEff and inRecent and buySideSweep
    f_addHuntZone(1, high, priorHigh, priorHigh, buySideStrengthNow)

if showSweepZonesEff and inRecent and sellSideSweep
    f_addHuntZone(-1, priorLow, low, priorLow, sellSideStrengthNow)

f_manageHuntZones()

//──────────────────────────────────────────────────────────────────────────────
// MOMENTUM / VOLUME / MTF / SCORE
//──────────────────────────────────────────────────────────────────────────────
mfiValue = ta.mfi(hlc3, momLen)
rsiValue = ta.rsi(close, momLen)
osc = hasVolume ? mfiValue : rsiValue
oscDir = osc > 50.0 + momDeadband ? 1 : osc < 50.0 - momDeadband ? -1 : 0
volPulse = useVolumePulse and volumePulseRaw ? close >= open ? 1 : -1 : 0

htfDir = request.security(syminfo.tickerid, effectiveHtf, f_htfSlope(), barmerge.gaps_off, barmerge.lookahead_off)
midTfDir = request.security(syminfo.tickerid, effectiveMidTf, f_htfSlope(), barmerge.gaps_off, barmerge.lookahead_off)

sessionVWAP = ta.vwap(hlc3)
vwapDir = useVWAPBias and timeframe.isintraday and not na(sessionVWAP) ? close > sessionVWAP ? 1 : close < sessionVWAP ? -1 : 0 : 0

dmiDir = diPlus > diMinus ? 1 : diMinus > diPlus ? -1 : 0
adxDir = adxValue >= minADX ? dmiDir : 0
isChop = useChopFilter and (effRatio < minER or adxValue < minADX)

huntBias = sellSideSweep ? 1 : buySideSweep ? -1 : 0
liquidityMemoryBias = activeSellSideRisk > activeBuySideRisk ? 1 : activeBuySideRisk > activeSellSideRisk ? -1 : 0
expansionBias = expansionNow ? close >= open ? 1 : -1 : 0

scoreRaw = stDir * 18.0 + gateDir * 18.0 + oscDir * 13.0 + adxDir * 11.0 + pressureDir * 8.0 + volPulse * 5.0 + huntBias * 10.0 + liquidityMemoryBias * 7.0 + expansionBias * 5.0 + (useHTF ? htfDir * 11.0 : 0.0) + (useMidTF ? midTfDir * 7.0 : 0.0) + vwapDir * 4.0
score = f_clamp(nz(scoreRaw, 0.0), -100.0, 100.0)
signalReady = signalMode == "Realtime" or barstate.isconfirmed
alertReady = not alertOnlyConfirmed or barstate.isconfirmed

//──────────────────────────────────────────────────────────────────────────────
// RISK FIREWALL / SIGNAL ENGINE
//──────────────────────────────────────────────────────────────────────────────
distanceFromTrail = hybridATR != 0.0 ? math.abs(close - trail) / hybridATR : 0.0
stretchBlocked = useStretchFirewall and distanceFromTrail > maxEntryStretchATR
largeGap = useGapRiskFilter and hybridATR > 0.0 and math.abs(open - nz(close[1], open)) > hybridATR * gapRiskATR
htfConflictLong = blockHTFConflict and useHTF and htfDir == -1
htfConflictShort = blockHTFConflict and useHTF and htfDir == 1
midConflictLong = blockHTFConflict and useMidTF and midTfDir == -1
midConflictShort = blockHTFConflict and useMidTF and midTfDir == 1

longFirewall = isChop or blockLongAfterBuySideSweep or weakBodyFlip or stretchBlocked or htfConflictLong or midConflictLong or largeGap
shortFirewall = isChop or blockShortAfterSellSideSweep or weakBodyFlip or stretchBlocked or htfConflictShort or midConflictShort or largeGap

firewallReasonLong = isChop ? "CHOP" : blockLongAfterBuySideSweep ? "NO LONG AFTER BUY-SIDE SWEEP" : weakBodyFlip ? "WEAK BODY" : stretchBlocked ? "STRETCHED" : htfConflictLong ? "HTF CONFLICT" : midConflictLong ? "MID-TF CONFLICT" : largeGap ? "GAP RISK" : "CLEAR"
firewallReasonShort = isChop ? "CHOP" : blockShortAfterSellSideSweep ? "NO SHORT AFTER SELL-SIDE SWEEP" : weakBodyFlip ? "WEAK BODY" : stretchBlocked ? "STRETCHED" : htfConflictShort ? "HTF CONFLICT" : midConflictShort ? "MID-TF CONFLICT" : largeGap ? "GAP RISK" : "CLEAR"

var int flowDir = 0
var int lastFlipBar = na

prevFlow = nz(flowDir[1], 0)
canFlip = na(lastFlipBar) or bar_index - lastFlipBar >= minBarsBetweenFlips
candidateDir = prevFlow

if score >= scoreThreshold and not longFirewall
    candidateDir := 1
else if score <= -scoreThreshold and not shortFirewall
    candidateDir := -1
else if useNeutralState and math.abs(score) <= neutralThreshold
    candidateDir := 0

if signalReady
    if candidateDir != prevFlow and (candidateDir == 0 or canFlip)
        flowDir := candidateDir
        lastFlipBar := bar_index
    else
        flowDir := prevFlow
else
    flowDir := prevFlow

flowBuyRaw = signalReady and flowDir == 1 and prevFlow != 1
flowSellRaw = signalReady and flowDir == -1 and prevFlow != -1
flowChange = signalReady and flowDir != prevFlow

htfAligned = not useHTF or htfDir == 0 or htfDir == flowDir
midAligned = not useMidTF or midTfDir == 0 or midTfDir == flowDir
qualityPenalty = (isChop ? 24.0 : 0.0) + (weakBodyFlip ? 14.0 : 0.0) + (activeLiqRisk * 0.22) + (htfAligned ? 0.0 : 12.0) + (midAligned ? 0.0 : 7.0) + (stretchBlocked ? 18.0 : 0.0) + (manipulationIndex >= 70 ? 10.0 : 0.0) + (largeGap ? 10.0 : 0.0)
qualityBoost = math.abs(score) * 0.78 + (htfAligned ? 7.0 : 0.0) + (midAligned ? 4.0 : 0.0) + (flowDir != 0 ? 4.0 : 0.0) + (expansionNow ? 5.0 : 0.0) + (math.abs(pressure) > 0.35 ? 4.0 : 0.0)
entryQuality = f_clamp(qualityBoost - qualityPenalty, 0.0, 100.0)
qualityGrade = f_grade(entryQuality)
qualityOkForLabel = not showOnlyHighQualityFlips or entryQuality >= 65
flowBuy = flowBuyRaw and qualityOkForLabel
flowSell = flowSellRaw and qualityOkForLabel

coachText = flowDir == 1 and entryQuality >= 65 and not blockLongAfterBuySideSweep ? "LONG OK" : flowDir == -1 and entryQuality >= 65 and not blockShortAfterSellSideSweep ? "SHORT OK" : isChop ? "WAIT CHOP" : stretchBlocked ? "WAIT STRETCHED" : largeGap ? "WAIT GAP" : activeLiqRisk >= liqRiskBlockScore ? "TRAP RISK" : "WAIT"
firewallReason = flowDir == 1 ? firewallReasonLong : flowDir == -1 ? firewallReasonShort : score >= 0 ? firewallReasonLong : firewallReasonShort

//──────────────────────────────────────────────────────────────────────────────
// RETEST / CONTINUATION / WARNING LOGIC
//──────────────────────────────────────────────────────────────────────────────
barsFromFlip = na(lastFlipBar) ? 100000 : bar_index - lastFlipBar

bullRetest = signalReady and showRetestsEff and inRecent and flowDir == 1 and barsFromFlip >= retestDelayBars and low <= upperGate and close > upperGate and close > trail and oscDir >= 0 and not blockLongAfterBuySideSweep
bearRetest = signalReady and showRetestsEff and inRecent and flowDir == -1 and barsFromFlip >= retestDelayBars and high >= lowerGate and close < lowerGate and close < trail and oscDir <= 0 and not blockShortAfterSellSideSweep

longDot = showDotsEff and inRecent and flowDir == 1 and close > trail and close > upperGate and bar_index % dotSpacing == 0 and not blockLongAfterBuySideSweep
shortDot = showDotsEff and inRecent and flowDir == -1 and close < trail and close < lowerGate and bar_index % dotSpacing == 0 and not blockShortAfterSellSideSweep

bullExhaust = showWarningsEff and inRecent and flowDir == 1 and distanceFromTrail >= exhaustionATR and osc >= 70.0
bearExhaust = showWarningsEff and inRecent and flowDir == -1 and distanceFromTrail >= exhaustionATR and osc <= 30.0

bullPressureWarning = showWarningsEff and inRecent and flowDir == 1 and (gateDir == -1 or blockLongAfterBuySideSweep or not htfAligned or stretchBlocked or pressureDir == -1) and oscDir <= 0
bearPressureWarning = showWarningsEff and inRecent and flowDir == -1 and (gateDir == 1 or blockShortAfterSellSideSweep or not htfAligned or stretchBlocked or pressureDir == 1) and oscDir >= 0

//──────────────────────────────────────────────────────────────────────────────
// MAIN VISUALS
//──────────────────────────────────────────────────────────────────────────────
mainColor = flowDir == 1 ? color.new(bullColor, lineTransp) : flowDir == -1 ? color.new(bearColor, lineTransp) : color.new(neutralColor, lineTransp)
gateColor = color.new(neutralColor, math.min(lineTransp + 42, 100))
cloudColor = flowDir == 1 ? color.new(bullColor, cloudTransp) : flowDir == -1 ? color.new(bearColor, cloudTransp) : color.new(neutralColor, math.min(cloudTransp + 4, 100))
pulseColor = flowDir == 1 ? color.new(bullColor, 84) : flowDir == -1 ? color.new(bearColor, 84) : color.new(neutralColor, 94)
regimeBg = showRegimeHalo and inRecent and entryQuality >= 75 ? flowDir == 1 ? color.new(bullColor, 94) : flowDir == -1 ? color.new(bearColor, 94) : na : na

bgcolor(regimeBg)

pPulse = plot(showPulseRailEff and showTrail and inRecent ? trail : na, "Pulse Rail Glow", color = pulseColor, linewidth = 6, style = plot.style_linebr)
pTrail = plot(showTrail and inRecent ? trail : na, "Adaptive Trail", color = mainColor, linewidth = 2, style = plot.style_linebr)
pUpper = plot(showGates and inRecent ? upperGate : na, "Upper H/L Flow Gate", color = gateColor, linewidth = 1)
pLower = plot(showGates and inRecent ? lowerGate : na, "Lower H/L Flow Gate", color = gateColor, linewidth = 1)
pMid = plot(showGates and inRecent and isResearch ? gateMid : na, "Gate Midline", color = color.new(neutralColor, 84), linewidth = 1)

fill(pUpper, pLower, color = showCloudEff and inRecent ? cloudColor : na, title = "Flow Cloud")
barcolor(colorCandles ? flowDir == 1 ? color.new(bullColor, candleTransp) : flowDir == -1 ? color.new(bearColor, candleTransp) : na : na)

plotshape(longDot, "Bull Continuation Dot", style = shape.circle, location = location.belowbar, size = size.tiny, color = color.new(bullColor, 24))
plotshape(shortDot, "Bear Continuation Dot", style = shape.circle, location = location.abovebar, size = size.tiny, color = color.new(bearColor, 24))

plotshape(bullRetest, "Bull Retest", text = "R", style = shape.labelup, location = location.belowbar, size = size.tiny, color = color.new(bullColor, 0), textcolor = color.white)
plotshape(bearRetest, "Bear Retest", text = "R", style = shape.labeldown, location = location.abovebar, size = size.tiny, color = color.new(bearColor, 0), textcolor = color.white)

plotshape(bullExhaust, "Bull Exhaustion", text = "EXT", style = shape.triangledown, location = location.abovebar, size = size.tiny, color = color.new(color.orange, 0), textcolor = color.white)
plotshape(bearExhaust, "Bear Exhaustion", text = "EXT", style = shape.triangleup, location = location.belowbar, size = size.tiny, color = color.new(color.orange, 0), textcolor = color.white)

plotshape(bullPressureWarning, "Bull Pressure Warning", text = "!", style = shape.triangledown, location = location.abovebar, size = size.tiny, color = color.new(color.yellow, 0), textcolor = color.black)
plotshape(bearPressureWarning, "Bear Pressure Warning", text = "!", style = shape.triangleup, location = location.belowbar, size = size.tiny, color = color.new(color.yellow, 0), textcolor = color.black)

plotshape(showSweepMarksEff and inRecent and buySideSweep, "Buy-Side Fake Wick", text = "BS", style = shape.labeldown, location = location.abovebar, size = size.tiny, color = color.new(buySideColor, 0), textcolor = color.white)
plotshape(showSweepMarksEff and inRecent and sellSideSweep, "Sell-Side Fake Wick", text = "SS", style = shape.labelup, location = location.belowbar, size = size.tiny, color = color.new(sellSideColor, 0), textcolor = color.white)

plotshape(showReclaimMarks and inRecent and buySideReclaimNow, "Buy-Side Sweep Reclaimed", text = "REC", style = shape.labelup, location = location.belowbar, size = size.tiny, color = color.new(bullColor, 0), textcolor = color.white)
plotshape(showReclaimMarks and inRecent and sellSideReclaimNow, "Sell-Side Sweep Reclaimed", text = "REC", style = shape.labeldown, location = location.abovebar, size = size.tiny, color = color.new(bearColor, 0), textcolor = color.white)

plotshape(showTrapRetest and inRecent and trapRetestBuySide, "Buy-Side Trap Retest", text = "TRAP", style = shape.triangledown, location = location.abovebar, size = size.tiny, color = color.new(buySideColor, 0), textcolor = color.white)
plotshape(showTrapRetest and inRecent and trapRetestSellSide, "Sell-Side Trap Retest", text = "TRAP", style = shape.triangleup, location = location.belowbar, size = size.tiny, color = color.new(sellSideColor, 0), textcolor = color.white)

plotshape(isResearch and inRecent and expansionNow, "Compression Expansion", text = "EXP", style = shape.diamond, location = location.bottom, size = size.tiny, color = color.new(color.aqua, 0), textcolor = color.white)
plotshape(isResearch and inRecent and largeGap, "Gap Risk", text = "GAP", style = shape.diamond, location = location.top, size = size.tiny, color = color.new(color.orange, 0), textcolor = color.white)

//──────────────────────────────────────────────────────────────────────────────
// RISK PLANNING BANDS
//──────────────────────────────────────────────────────────────────────────────
stopDistance = math.abs(close - trail)
target1 = flowDir == 1 ? close + stopDistance * rr1 : flowDir == -1 ? close - stopDistance * rr1 : na
target2 = flowDir == 1 ? close + stopDistance * rr2 : flowDir == -1 ? close - stopDistance * rr2 : na
riskColor = flowDir == 1 ? color.new(bullColor, riskLineTransp) : flowDir == -1 ? color.new(bearColor, riskLineTransp) : color.new(neutralColor, 100)

plot(showRiskBands and inRecent and flowDir != 0 ? target1 : na, "Dynamic 1R Planning Band", color = riskColor, linewidth = 1, style = plot.style_linebr)
plot(showRiskBands and inRecent and flowDir != 0 ? target2 : na, "Dynamic 2R Planning Band", color = riskColor, linewidth = 1, style = plot.style_linebr)

//──────────────────────────────────────────────────────────────────────────────
// AUTO-DELETING MAIN SIGNAL LABELS
//──────────────────────────────────────────────────────────────────────────────
var label[] signalLabels = array.new_label()

f_addSignalLabel(_y, _txt, _col, _style) =>
    _lb = label.new(bar_index, _y, _txt, xloc = xloc.bar_index, style = _style, color = _col, textcolor = color.white, size = size.tiny)
    array.push(signalLabels, _lb)
    if array.size(signalLabels) > maxSignalLabelsEff
        _old = array.shift(signalLabels)
        label.delete(_old)

if showSignalLabels and inRecent and flowBuy
    f_addSignalLabel(math.min(low, nz(trail, low)) - hybridATR * 0.15, "BUY\n" + str.tostring(close, format.mintick) + "\nQ " + qualityGrade, bullColor, label.style_label_up)

if showSignalLabels and inRecent and flowSell
    f_addSignalLabel(math.max(high, nz(trail, high)) + hybridATR * 0.15, "SELL\n" + str.tostring(close, format.mintick) + "\nQ " + qualityGrade, bearColor, label.style_label_down)

//──────────────────────────────────────────────────────────────────────────────
// LAST-BAR LIQUIDITY MAGNETS
//──────────────────────────────────────────────────────────────────────────────
liqHigh = ta.highest(high, magnetLookback)
liqLow = ta.lowest(low, magnetLookback)
magnetLevelRaw = flowDir == 1 ? liqHigh : flowDir == -1 ? liqLow : close >= gateMid ? liqHigh : liqLow
magnetLevel = f_tick(magnetLevelRaw)
roundStep = f_roundStep(close)
roundMagnet = f_tick(math.round(close / roundStep) * roundStep)

var line magnetLine = na
var label magnetLabel = na
var line roundLine = na
var label roundLabel = na

if barstate.islast
    line.delete(magnetLine)
    label.delete(magnetLabel)
    line.delete(roundLine)
    label.delete(roundLabel)
    if showLiquidityMagnet and inRecent
        magnetLine := line.new(bar_index - 8, magnetLevel, bar_index + 26, magnetLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(magnetColor, 25), style = line.style_dashed, width = 1)
        magnetLabel := label.new(bar_index + 26, magnetLevel, "Liquidity magnet\n" + str.tostring(magnetLevel, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(magnetColor, 15), textcolor = color.black, size = size.tiny)
    if showRoundMagnet and inRecent
        roundLine := line.new(bar_index - 8, roundMagnet, bar_index + 20, roundMagnet, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 55), style = line.style_dotted, width = 1)
        roundLabel := label.new(bar_index + 20, roundMagnet, "Round magnet\n" + str.tostring(roundMagnet, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(neutralColor, 70), textcolor = color.white, size = size.tiny)

//──────────────────────────────────────────────────────────────────────────────
// LAST-BAR HERO LABEL
//──────────────────────────────────────────────────────────────────────────────
var label heroLabel = na

if barstate.islast and showHeroLabel
    label.delete(heroLabel)
    heroText = f_dirText(flowDir) + " | " + coachText + "\nScore " + str.tostring(math.round(score)) + " | Q " + qualityGrade + " | Trap " + str.tostring(math.round(activeLiqRisk)) + "\nManip " + str.tostring(math.round(manipulationIndex)) + " | " + premiumDiscount
    heroY = flowDir == -1 ? high + hybridATR * heroOffsetATR : low - hybridATR * heroOffsetATR
    heroStyle = flowDir == -1 ? label.style_label_down : label.style_label_up
    heroLabel := label.new(bar_index, heroY, heroText, xloc = xloc.bar_index, style = heroStyle, color = color.new(f_dirColor(flowDir), 7), textcolor = color.white, size = size.tiny)

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(f_pos(dashPosition), 2, 14, border_width = 1)

if barstate.islast and showDashboard
    txtSize = f_size(dashText)
    dirBg = color.new(f_dirColor(flowDir), 72)
    chopText = isChop ? "CHOP" : "OK"
    chopBg = isChop ? color.new(color.orange, 55) : color.new(bullColor, 78)
    huntText = blockLongAfterBuySideSweep ? "NO LONG" : blockShortAfterSellSideSweep ? "NO SHORT" : buySideSweep ? "BUY-SIDE SWEEP" : sellSideSweep ? "SELL-SIDE SWEEP" : "CLEAR"
    huntBg = blockLongAfterBuySideSweep or blockShortAfterSellSideSweep ? color.new(color.red, 55) : buySideSweep or sellSideSweep ? color.new(color.orange, 55) : color.new(bullColor, 82)
    qBg = entryQuality >= 75 ? color.new(bullColor, 70) : entryQuality >= 50 ? color.new(color.orange, 65) : color.new(color.red, 60)
    manipBg = manipulationIndex >= 70 ? color.new(color.red, 55) : manipulationIndex >= 45 ? color.new(color.orange, 60) : color.new(bullColor, 82)
    coachBg = coachText == "LONG OK" or coachText == "SHORT OK" ? color.new(bullColor, 72) : color.new(color.orange, 60)
    firewallBg = firewallReason == "CLEAR" ? color.new(bullColor, 82) : color.new(color.orange, 60)

    table.cell(dash, 0, 0, "H/L FLOW HUNT-PRO v2", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = txtSize)
    table.cell(dash, 1, 0, autoProfile, text_color = color.white, bgcolor = color.new(color.black, 0), text_size = txtSize)
    table.cell(dash, 0, 1, "Coach", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 1, coachText, text_color = color.white, bgcolor = coachBg, text_size = txtSize)
    table.cell(dash, 0, 2, "State", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 2, f_dirText(flowDir), text_color = color.white, bgcolor = dirBg, text_size = txtSize)
    table.cell(dash, 0, 3, "Score", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 3, str.tostring(math.round(score)), text_color = color.white, bgcolor = dirBg, text_size = txtSize)
    table.cell(dash, 0, 4, "Quality", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 4, qualityGrade + " / " + str.tostring(math.round(entryQuality)), text_color = color.white, bgcolor = qBg, text_size = txtSize)
    table.cell(dash, 0, 5, "Manipulation", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 5, str.tostring(math.round(manipulationIndex)), text_color = color.white, bgcolor = manipBg, text_size = txtSize)
    table.cell(dash, 0, 6, "Pressure", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 6, str.tostring(pressure, "#.00") + " " + f_dirText(pressureDir), text_color = color.white, bgcolor = color.new(f_dirColor(pressureDir), 78), text_size = txtSize)
    table.cell(dash, 0, 7, "Gate", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 7, f_dirText(gateDir), text_color = color.white, bgcolor = color.new(f_dirColor(gateDir), 78), text_size = txtSize)
    table.cell(dash, 0, 8, hasVolume ? "MFI" : "RSI", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 8, str.tostring(osc, "#.0"), text_color = color.white, bgcolor = color.new(f_dirColor(oscDir), 78), text_size = txtSize)
    table.cell(dash, 0, 9, "HTF " + effectiveHtf, text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 9, useHTF ? f_dirText(htfDir) : "OFF", text_color = color.white, bgcolor = color.new(f_dirColor(htfDir), 78), text_size = txtSize)
    table.cell(dash, 0, 10, "Mid " + effectiveMidTf, text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 10, useMidTF ? f_dirText(midTfDir) : "OFF", text_color = color.white, bgcolor = color.new(f_dirColor(midTfDir), 78), text_size = txtSize)
    table.cell(dash, 0, 11, "Filter", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 11, chopText, text_color = color.white, bgcolor = chopBg, text_size = txtSize)
    table.cell(dash, 0, 12, "Hunt Risk", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 12, huntText + " " + str.tostring(math.round(activeLiqRisk)), text_color = color.white, bgcolor = huntBg, text_size = txtSize)
    table.cell(dash, 0, 13, showFirewallRow ? "Firewall" : "Expansion", text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    table.cell(dash, 1, 13, showFirewallRow ? firewallReason : f_boolText(expansionNow), text_color = color.white, bgcolor = showFirewallRow ? firewallBg : expansionNow ? color.new(color.aqua, 65) : color.new(color.black, 75), text_size = txtSize)

//──────────────────────────────────────────────────────────────────────────────
// MINI SCREENER
//──────────────────────────────────────────────────────────────────────────────
f_screenState() =>
    _atr = ta.atr(atrLen)
    _logHL = low > 0.0 ? math.log(high / low) : 0.0
    _park = math.sqrt((1.0 / (4.0 * math.log(2.0))) * ta.sma(_logHL * _logHL, atrLen)) * close
    _hyb = _atr * (1.0 - parkWeight) + _park * parkWeight
    _hi = f_ma(ta.highest(high, hiloLen), smoothLen, maType)
    _lo = f_ma(ta.lowest(low, hiloLen), smoothLen, maType)
    _mid = (_hi + _lo) * 0.5
    _range = math.max(_hi - _lo, _hyb * 2.0)
    _upGate = _mid + _range * gateTightness
    _dnGate = _mid - _range * gateTightness
    _gateDir = close > _upGate ? 1 : close < _dnGate ? -1 : 0
    _ma = f_ma(close, smoothLen, maType)
    _maDir = close > _ma ? 1 : close < _ma ? -1 : 0
    _rsi = ta.rsi(close, momLen)
    _oscDir = _rsi > 50.0 + momDeadband ? 1 : _rsi < 50.0 - momDeadband ? -1 : 0
    _score = f_clamp(_maDir * 42.0 + _gateDir * 38.0 + _oscDir * 20.0, -100.0, 100.0)
    _dir = _score >= scoreThreshold ? 1 : _score <= -scoreThreshold ? -1 : 0
    _bars = ta.barssince(_dir != nz(_dir[1], 0))
    [_dir, _score, nz(_bars, 0)]

tf1Eff = f_tf(tf1)
tf2Eff = f_tf(tf2)
tf3Eff = f_tf(tf3)
tf4Eff = f_tf(tf4)
tf5Eff = f_tf(tf5)

[sd1, ss1, sb1] = request.security(sym1, tf1Eff, f_screenState(), barmerge.gaps_off, barmerge.lookahead_off)
[sd2, ss2, sb2] = request.security(sym2, tf2Eff, f_screenState(), barmerge.gaps_off, barmerge.lookahead_off)
[sd3, ss3, sb3] = request.security(sym3, tf3Eff, f_screenState(), barmerge.gaps_off, barmerge.lookahead_off)
[sd4, ss4, sb4] = request.security(sym4, tf4Eff, f_screenState(), barmerge.gaps_off, barmerge.lookahead_off)
[sd5, ss5, sb5] = request.security(sym5, tf5Eff, f_screenState(), barmerge.gaps_off, barmerge.lookahead_off)

var table screen = table.new(f_pos(screenPosition), 4, 6, border_width = 1)

f_screenRow(_row, _sym, _tf, _dir, _score, _bars) =>
    _bg = color.new(f_dirColor(_dir), 74)
    table.cell(screen, 0, _row, _sym, text_color = color.white, bgcolor = _bg, text_size = size.tiny)
    table.cell(screen, 1, _row, _tf, text_color = color.white, bgcolor = color.new(color.black, 72), text_size = size.tiny)
    table.cell(screen, 2, _row, f_dirText(_dir), text_color = color.white, bgcolor = _bg, text_size = size.tiny)
    table.cell(screen, 3, _row, str.tostring(math.round(_score)) + " / " + str.tostring(_bars), text_color = color.white, bgcolor = color.new(color.black, 72), text_size = size.tiny)

if barstate.islast and showScreener
    table.cell(screen, 0, 0, "Symbol", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    table.cell(screen, 1, 0, "TF", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    table.cell(screen, 2, 0, "Flow", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    table.cell(screen, 3, 0, "Score / Bars", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.tiny)
    f_screenRow(1, sym1, tf1Eff, sd1, ss1, sb1)
    f_screenRow(2, sym2, tf2Eff, sd2, ss2, sb2)
    f_screenRow(3, sym3, tf3Eff, sd3, ss3, sb3)
    f_screenRow(4, sym4, tf4Eff, sd4, ss4, sb4)
    f_screenRow(5, sym5, tf5Eff, sd5, ss5, sb5)

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
alertFlowBuy = alertReady and flowBuyRaw
alertFlowSell = alertReady and flowSellRaw
alertFlowChange = alertReady and flowChange
alertBullRetest = alertReady and bullRetest
alertBearRetest = alertReady and bearRetest
alertBuySweep = alertReady and buySideSweep
alertSellSweep = alertReady and sellSideSweep
alertNoLong = alertReady and blockLongAfterBuySideSweep
alertNoShort = alertReady and blockShortAfterSellSideSweep
alertBullExhaust = alertReady and bullExhaust
alertBearExhaust = alertReady and bearExhaust
alertBuyReclaim = alertReady and buySideReclaimNow
alertSellReclaim = alertReady and sellSideReclaimNow
alertTrapRetestBuy = alertReady and trapRetestBuySide
alertTrapRetestSell = alertReady and trapRetestSellSide
alertExpansion = alertReady and expansionNow

alertcondition(alertFlowBuy, "H/L Flow Gate BUY", "{\"event\":\"flow_buy\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertFlowSell, "H/L Flow Gate SELL", "{\"event\":\"flow_sell\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertFlowChange, "H/L Flow Gate Direction Change", "{\"event\":\"flow_change\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertBullRetest, "Bull Retest Entry", "{\"event\":\"bull_retest\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertBearRetest, "Bear Retest Entry", "{\"event\":\"bear_retest\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertBuySweep, "Buy-Side Sweep / Fake Wick", "{\"event\":\"buy_side_sweep_fake_wick\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertSellSweep, "Sell-Side Sweep / Fake Wick", "{\"event\":\"sell_side_sweep_fake_wick\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertNoLong, "Stop-Hunt Protection Blocks Long", "{\"event\":\"stop_hunt_no_long\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertNoShort, "Stop-Hunt Protection Blocks Short", "{\"event\":\"stop_hunt_no_short\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertBullExhaust, "Bull Exhaustion Warning", "{\"event\":\"bull_exhaustion\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertBearExhaust, "Bear Exhaustion Warning", "{\"event\":\"bear_exhaustion\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertBuyReclaim, "Buy-Side Sweep Reclaimed", "{\"event\":\"buy_side_sweep_reclaimed\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertSellReclaim, "Sell-Side Sweep Reclaimed", "{\"event\":\"sell_side_sweep_reclaimed\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertTrapRetestBuy, "Buy-Side Trap Retest", "{\"event\":\"buy_side_trap_retest\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertTrapRetestSell, "Sell-Side Trap Retest", "{\"event\":\"sell_side_trap_retest\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
alertcondition(alertExpansion, "Compression Expansion Detected", "{\"event\":\"compression_expansion\",\"ticker\":\"{{ticker}}\",\"tf\":\"{{interval}}\",\"price\":{{close}}}")
````
