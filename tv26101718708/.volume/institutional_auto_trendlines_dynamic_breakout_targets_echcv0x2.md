# Institutional Auto Trendlines  Dynamic  Breakout Targets

- url: https://www.tradingview.com/script/Echcv0X2-Institutional-Auto-Trendlines-Dynamic-Breakout-Targets/
- type: indicator
- pine_id: PUB;25c15f270a2740dc85b2a5ff8cefa814
- version: 2.0

## Description

Description

Institutional Trendline Precision Engine v1 is designed to detect high-quality diagonal support and resistance trendlines automatically from confirmed swing pivots.

The goal of this indicator is not to draw every possible trendline. Its purpose is to filter the chart and show only the most relevant diagonal market structure based on quality, touch behavior, volatility, trendline respect, and proximity to current price.

This tool is built for traders who want cleaner structure, fewer manual drawings, and a more systematic way to evaluate diagonal support and resistance.

Main Features
Automatic confirmed trendline detection
Builds support lines from confirmed pivot lows.
Builds resistance lines from confirmed pivot highs.
Uses left/right pivot confirmation to avoid using unfinished swing points.
Quality-ranked trendlines
Scores each line using touch clusters, fit quality, violation rate, candle respect, wick rejection, recency, structural span, EMA/VWAP confluence, and optional higher-timeframe bias.
Clean chart filtering
Hides weak, duplicated, broken, old, overlapping, or distant trendlines.
Displays only the strongest support and resistance lines by default.
Nearest dynamic support and resistance
Shows the closest active dynamic support below price.
Shows the closest active dynamic resistance above price.
Breakout and retest logic
Detects long breakouts above resistance.
Detects short breakdowns below support.
Detects retests after confirmed breaks.
Detects rejection and failed-break events.
Optional TP/SL target projection
Projects visual target and invalidation levels after selected signals.
Target modes include ATR Band, Structure, and Hybrid.
These are visual guides only and are not strategy orders.
MTF bias filter
Uses higher-timeframe EMA structure as a soft quality and signal filter.
Helps avoid treating every local line as equally important.
Editable visual style panel
Custom support/resistance colors.
Adjustable line transparency.
Manual or automatic line styles.
Manual or automatic line width.
Editable target line colors, transparency, and style.
Adjustable signal marker transparency.
Dashboard
Displays trendline count, best quality, market condition, MTF bias, nearest support/resistance, geometry state, pressure, and active target status.
What This Indicator Is Good At

This indicator is useful for identifying cleaner diagonal market structure, reducing chart clutter, and locating respected trendlines that have shown repeated reaction behavior.

It can help traders observe:

where price is reacting to diagonal support or resistance
whether price is approaching an important dynamic level
when a breakout, retest, rejection, or failed break occurs
whether higher-timeframe structure supports or conflicts with the current setup
where a possible target and invalidation area may be located after a signal
What This Indicator Is Not

This indicator does not predict the future.

It is not a complete trading strategy.

It does not execute trades.

It does not know news events, liquidity sweeps, spread, slippage, exchange outages, or macro conditions.

Because it uses confirmed pivots, some signals and trendlines appear only after the pivot confirmation period has completed. This is intentional and helps avoid drawing structure from unfinished swings.

Recommended Use

Use this indicator as a structure and confirmation tool, not as a standalone buy/sell system.

Best use cases:

trendline breakout confirmation
retest observation
dynamic support/resistance mapping
structure cleanup on busy charts
higher-timeframe trendline context
educational chart analysis

Recommended default settings:
Precision Mode: Balanced
Chart Density: Publication
Signal Display: Markers Only
Confirmed Line Style: Auto By Quality
Confirmed Line Width: Auto By Quality
Target Signal Source: Breakouts Only
Target Mode: Hybrid
Show Developing Lines: Off
Show Confidence Channels: Off
Trend State Watermark: Off

Honest Note

No automatic trendline indicator can replace market context or risk management. Diagonal lines can be useful, but they are still interpretations of market structure. This script tries to reduce noise by ranking and filtering lines, but false breakouts, late pivots, and choppy-market signals can still happen.

Use it with higher-timeframe analysis, volume, liquidity levels, session context, and proper risk control.

https://www.tradingview.com/x/viedzmSM/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IlSeparatio369.

//@version=6
indicator('Institutional Trendline Precision Engine v1', 'Institutional Trendline v1', overlay = true, max_lines_count = 300, max_labels_count = 240, max_bars_back = 3000, precision = 4)

// ==============================================================================
// README
// ==============================================================================
// Institutional Trendline Precision Engine v1
//
// WHAT THIS INDICATOR DOES
// This indicator automatically detects diagonal support and resistance trendlines
// from confirmed swing pivots. It builds support from pivot lows and resistance
// from pivot highs, then ranks each trendline by structural quality.
//
// CORE LOGIC
// 1. Confirms pivot highs and pivot lows using left/right pivot bars.
// 2. Tests recent pivot pairs as possible trendline anchors.
// 3. Rejects invalid lines that are too flat, too steep, too old, too broken,
//    duplicated, overlapping, or too far from current price.
// 4. Scores each valid line by touch clusters, distance fit, violation rate,
//    candle respect, wick rejection, recency, span, EMA/VWAP confluence,
//    and optional higher-timeframe bias.
// 5. Displays only the strongest ranked lines to keep the chart clean.
// 6. Tracks nearest dynamic support and nearest dynamic resistance.
// 7. Classifies active geometry as Uptrend, Downtrend, Range, Converging Triangle,
//    Diverging Triangle, Ascending Base, Descending Cap, or Expansion structure.
// 8. Provides alert logic for breakout, breakdown, retest, rejection,
//    and failed-break events.
// 9. Projects optional TP/SL target lines from valid breakout/retest/rejection signals.
//
// WHAT THIS INDICATOR IS GOOD AT
// - Finding cleaner diagonal support and resistance.
// - Reducing chart clutter compared with manual trendline drawing.
// - Showing only the most relevant ranked trendlines.
// - Detecting breakout, retest, rejection, and failed-break events from respected lines.
// - Classifying channel and triangle geometry.
// - Displaying optional TP/SL projections after meaningful trendline events.
// - Keeping alerts active while visual labels can remain disabled.
// - Using confirmed pivots and lookahead_off higher-timeframe requests.
//
// WHAT THIS INDICATOR IS NOT GOOD AT
// - It does not predict the future.
// - It is not a complete trading strategy.
// - It does not execute orders.
// - It does not know news, slippage, spread, liquidity sweeps, or exchange outages.
// - It can miss fast V-shaped reversals because confirmed pivots require right-side bars.
// - It can still show weak lines in extremely choppy markets if filters are too loose.
// - TP/SL projections are educational visual guides, not guaranteed outcomes.
// - It should not be used alone without risk management and higher-timeframe context.
//
// PUBLICATION DEFAULTS
// - Precision Mode: Balanced
// - Chart Density: Publication
// - Line Extension Mode: Right
// - Signal Display: Markers Only
// - Target Signal Source: Breakouts Only
// - Target Mode: Hybrid
// - Pivot Anchor Markers: Off
// - Confidence Channels: Off
// - Trend State Watermark: Off
// ==============================================================================

// ==============================================================================
// GROUPS
// ==============================================================================
string G_GENERAL = 'General'
string G_ENGINE = 'Engine'
string G_SCORE = 'Scoring'
string G_MTF = 'MTF Bias'
string G_SIGNAL = 'Signals'
string G_TARGET = 'Targets'
string G_VISUAL = 'Visuals'
string G_STYLE = 'Editable Style Panel'
string G_PANEL = 'Dashboard'
string G_ALERTS = 'Alerts'

// ==============================================================================
// INPUTS
// ==============================================================================
confirmedOnly = input.bool(true, 'Confirmed-Bar Processing', group = G_GENERAL, tooltip = 'Updates trendline discovery and signal logic only after the bar closes. Recommended for cleaner non-repainting behavior.')
roundToTick = input.bool(true, 'Round Prices To Tick', group = G_GENERAL, tooltip = 'Rounds displayed line prices to the symbol minimum tick size.')
touchSource = input.string('Wicks', 'Touch Source', options = ['Wicks', 'Bodies'], group = G_GENERAL, tooltip = 'Wicks use full high/low reactions. Bodies require candle bodies to respect the trendline and are stricter.')
precisionMode = input.string('Balanced', 'Precision Mode', options = ['Aggressive', 'Balanced', 'Conservative'], group = G_GENERAL, tooltip = 'Aggressive shows more structure. Balanced is recommended. Conservative requires stronger quality and cleaner signals.')

pivotLeft = input.int(3, 'Pivot Left Bars', minval = 2, maxval = 15, group = G_ENGINE, tooltip = 'Number of bars required on the left side of a confirmed swing pivot.')
pivotRight = input.int(3, 'Pivot Right Bars', minval = 2, maxval = 15, group = G_ENGINE, tooltip = 'Number of bars required on the right side of a confirmed swing pivot. Higher values create stronger but slower pivots.')

lookback1 = input.int(70, 'Short Lookback', minval = 30, maxval = 500, group = G_ENGINE, tooltip = 'Short discovery window for recent trendlines.')
lookback2 = input.int(150, 'Medium Lookback', minval = 60, maxval = 800, group = G_ENGINE, tooltip = 'Medium discovery window for broader structure.')
lookback3 = input.int(300, 'Large Lookback', minval = 100, maxval = 1200, group = G_ENGINE, tooltip = 'Large discovery window for major diagonal structure.')

detectEveryBars = input.int(8, 'Detection Interval', minval = 1, maxval = 50, group = G_ENGINE, tooltip = 'Runs trendline discovery every N bars. Higher values improve performance. Lower values update faster.')
analysisBackBars = input.int(420, 'Recent Analysis Window', minval = 100, maxval = 1500, group = G_ENGINE, tooltip = 'Limits heavy discovery work to recent bars for performance.')
maxStoredPivots = input.int(130, 'Maximum Stored Pivots', minval = 40, maxval = 300, group = G_ENGINE, tooltip = 'Maximum confirmed swing pivots stored internally.')
candidatePivotDepth = input.int(8, 'Recent Candidate Pivots', minval = 4, maxval = 18, group = G_ENGINE, tooltip = 'Number of recent pivots tested as possible trendline anchors.')
scorePivotDepth = input.int(16, 'Score Pivot Depth', minval = 6, maxval = 36, group = G_ENGINE, tooltip = 'Number of recent pivots used to score each candidate trendline.')
sampledBars = input.int(16, 'Sampled Candle Checks', minval = 5, maxval = 60, group = G_ENGINE, tooltip = 'Number of sampled candles used to detect structural violations and candle respect.')
maxActiveLines = input.int(12, 'Maximum Stored Confirmed Lines', minval = 4, maxval = 40, group = G_ENGINE, tooltip = 'Maximum confirmed trendlines kept internally before pruning weaker ones.')
minAnchorSeparation = input.float(0.12, 'Minimum Anchor Separation', minval = 0.03, maxval = 0.60, step = 0.01, group = G_ENGINE, tooltip = 'Minimum distance between two anchor pivots as a fraction of the active lookback.')
minSlopeAtrPerBar = input.float(0.004, 'Minimum Slope ATR Per Bar', minval = 0.000, maxval = 0.200, step = 0.001, group = G_ENGINE, tooltip = 'Rejects nearly horizontal lines. Horizontal areas are better treated as static support/resistance.')
maxSlopeAtrPerBar = input.float(0.34, 'Maximum Slope ATR Per Bar', minval = 0.02, maxval = 2.00, step = 0.01, group = G_ENGINE, tooltip = 'Rejects unrealistically steep lines relative to volatility.')
maxSlopeAngleDeg = input.float(34.0, 'Maximum Normalized Slope Angle', minval = 5.0, maxval = 80.0, step = 1.0, group = G_ENGINE, tooltip = 'Rejects excessive slope angle after normalizing price movement by ATR.')
maxLineAgeBars = input.int(650, 'Maximum Line Age Bars', minval = 50, maxval = 2000, group = G_ENGINE, tooltip = 'Old trendlines are removed after this number of bars from their oldest anchor.')
duplicatePriceATR = input.float(0.65, 'Duplicate Price Distance ATR', minval = 0.10, maxval = 3.00, step = 0.05, group = G_ENGINE, tooltip = 'Trendlines closer than this ATR distance are treated as possible duplicates.')
duplicateSlopeATR = input.float(0.10, 'Duplicate Slope Distance ATR', minval = 0.01, maxval = 1.00, step = 0.01, group = G_ENGINE, tooltip = 'Slope similarity threshold used to merge or reject duplicated trendlines.')
useHistoricalATR = input.bool(true, 'Use Historical ATR For Scoring', group = G_ENGINE, tooltip = 'Scores older touches using volatility from that historical bar instead of only current ATR.')

minQuality = input.float(52.0, 'Minimum Raw Quality', minval = 20.0, maxval = 95.0, step = 1.0, group = G_SCORE, tooltip = 'Minimum raw quality required to create a confirmed trendline.')
minEffectiveQuality = input.float(46.0, 'Minimum Effective Quality', minval = 10.0, maxval = 95.0, step = 1.0, group = G_SCORE, tooltip = 'Minimum effective quality required for a line to stay visible.')
minTouchClusters = input.int(2, 'Minimum Touch Clusters', minval = 2, maxval = 8, group = G_SCORE, tooltip = 'Minimum separated touch groups required for a valid trendline.')
touchClusterGap = input.int(4, 'Touch Cluster Gap', minval = 1, maxval = 20, group = G_SCORE, tooltip = 'Minimum bars required between accepted touch clusters.')
touchATR = input.float(0.70, 'Touch Tolerance ATR', minval = 0.05, maxval = 3.00, step = 0.01, group = G_SCORE, tooltip = 'Distance from the trendline counted as a valid touch.')
violationATR = input.float(1.10, 'Violation Tolerance ATR', minval = 0.05, maxval = 4.00, step = 0.01, group = G_SCORE, tooltip = 'Close beyond the trendline by this ATR amount counts as structural violation.')
maxViolationRate = input.float(0.28, 'Maximum Violation Rate', minval = 0.00, maxval = 0.80, step = 0.01, group = G_SCORE, tooltip = 'Maximum sampled violation rate allowed for a valid trendline.')
minFitScore = input.float(0.20, 'Minimum Fit Score', minval = 0.00, maxval = 0.95, step = 0.01, group = G_SCORE, tooltip = 'Minimum distance-based fit score required.')
agePenaltyPer100 = input.float(0.35, 'Age Penalty Per 100 Bars', minval = 0.00, maxval = 5.00, step = 0.05, group = G_SCORE, tooltip = 'Reduces effective quality as a line becomes older.')
stalePenaltyPer100 = input.float(0.60, 'Stale Penalty Per 100 Bars', minval = 0.00, maxval = 5.00, step = 0.05, group = G_SCORE, tooltip = 'Reduces effective quality when price has not touched the line recently.')

enableMTF = input.bool(true, 'Enable MTF Bias', group = G_MTF, tooltip = 'Uses higher-timeframe EMA structure as a soft trendline quality modifier.')
htf1 = input.timeframe('240', 'Higher Timeframe 1', group = G_MTF, tooltip = 'First higher timeframe used for trend bias.')
htf2 = input.timeframe('D', 'Higher Timeframe 2', group = G_MTF, tooltip = 'Second higher timeframe used for trend bias.')

enableSignals = input.bool(true, 'Enable Alert Logic', group = G_SIGNAL, tooltip = 'Enables breakout, breakdown, retest, rejection, and failed-break alert logic.')
signalDisplay = input.string('Markers Only', 'Signal Display', options = ['Off', 'Markers Only', 'Latest Labels Only', 'Full Historical'], group = G_SIGNAL, tooltip = 'Controls signal visuals. Off hides signals. Markers Only is clean for publication. Latest Labels Only shows recent text labels. Full Historical keeps more labels but may clutter the chart.')
maxVisibleSignalEvents = input.int(10, 'Maximum Visible Signal Events', minval = 1, maxval = 50, group = G_SIGNAL, tooltip = 'Maximum recent signal markers or labels kept on chart when using clean display modes.')
enableRejectionSignals = input.bool(true, 'Enable Rejection Alerts', group = G_SIGNAL, tooltip = 'Detects candle rejection from respected support or resistance trendlines.')
signalFilterMode = input.string('Trend + Momentum', 'Signal Filter Mode', options = ['None', 'Trend', 'Momentum', 'Trend + Momentum'], group = G_SIGNAL, tooltip = 'Filters signals by trend, momentum, both, or none.')
requireBodyBreak = input.bool(true, 'Require Body Breakout', group = G_SIGNAL, tooltip = 'Requires candle body confirmation beyond the trendline for breakout and breakdown signals.')
requireMTFAgreement = input.bool(false, 'Require MTF Agreement', group = G_SIGNAL, tooltip = 'Requires higher-timeframe bias to agree with breakout direction.')
useVolumeFilter = input.bool(false, 'Require Volume Expansion', group = G_SIGNAL, tooltip = 'Requires current volume to be above its average by the selected ratio.')
volumeLength = input.int(30, 'Volume Average Length', minval = 5, maxval = 200, group = G_SIGNAL, tooltip = 'Volume average length used by the optional volume expansion filter.')
volumeRatioMin = input.float(1.15, 'Minimum Volume Ratio', minval = 0.50, maxval = 5.00, step = 0.05, group = G_SIGNAL, tooltip = 'Minimum volume divided by average volume required when volume filtering is enabled.')
signalQuality = input.float(60.0, 'Signal Raw Quality', minval = 20.0, maxval = 98.0, step = 1.0, group = G_SIGNAL, tooltip = 'Minimum raw quality required for signal logic.')
signalEffectiveQuality = input.float(54.0, 'Signal Effective Quality', minval = 10.0, maxval = 98.0, step = 1.0, group = G_SIGNAL, tooltip = 'Minimum effective quality required for signal logic.')
signalTopN = input.int(4, 'Signal Top Lines', minval = 1, maxval = 15, group = G_SIGNAL, tooltip = 'Only the top-ranked lines per side are checked for signals.')
breakoutATR = input.float(0.22, 'Breakout Buffer ATR', minval = 0.02, maxval = 2.00, step = 0.01, group = G_SIGNAL, tooltip = 'Close must exceed the trendline by this ATR buffer.')
retestATR = input.float(0.42, 'Retest Distance ATR', minval = 0.05, maxval = 2.50, step = 0.01, group = G_SIGNAL, tooltip = 'Maximum retest distance from the broken line.')
rejectionATR = input.float(0.18, 'Rejection Close Buffer ATR', minval = 0.02, maxval = 2.00, step = 0.01, group = G_SIGNAL, tooltip = 'Minimum close distance back away from the line to confirm rejection.')
retestWindow = input.int(30, 'Retest Window Bars', minval = 3, maxval = 250, group = G_SIGNAL, tooltip = 'Bars after breakout where retest can trigger.')
signalCooldown = input.int(35, 'Signal Cooldown Bars', minval = 0, maxval = 150, group = G_SIGNAL, tooltip = 'Minimum bars between repeated signals on the same line. Higher values reduce signal clutter.')
maxSignalLabels = input.int(30, 'Maximum Full Historical Labels', minval = 5, maxval = 100, group = G_SIGNAL, tooltip = 'Maximum labels kept when Signal Display is Full Historical.')

showTargets = input.bool(true, 'Show Breakout Targets', group = G_TARGET, tooltip = 'Shows optional TP/SL projection lines after selected trendline events. This is a visual guide only, not a trading strategy.')
targetSignalSource = input.string('Breakouts Only', 'Target Signal Source', options = ['Breakouts Only', 'Breakouts + Retests', 'All Directional'], group = G_TARGET, tooltip = 'Controls which signal types can start a TP/SL target projection.')
targetMode = input.string('Hybrid', 'Target Mode', options = ['ATR Band', 'Structure', 'Hybrid'], group = G_TARGET, tooltip = 'ATR Band uses volatility distance. Structure uses the trendline as invalidation. Hybrid uses the wider safer risk distance.')
targetRewardRisk = input.float(1.80, 'Target Reward/Risk', minval = 0.25, maxval = 10.0, step = 0.05, group = G_TARGET, tooltip = 'Target distance relative to risk distance. Example: 1.8 means target is 1.8 times the entry-to-stop distance.')
targetATRLength = input.int(30, 'Target ATR Length', minval = 5, maxval = 200, group = G_TARGET, tooltip = 'ATR length used by the target volatility band.')
targetATRMultiplier = input.float(0.30, 'Target ATR Band Multiplier', minval = 0.05, maxval = 3.00, step = 0.05, group = G_TARGET, tooltip = 'ATR multiplier used to create the base volatility band.')
targetMaxPercent = input.float(0.30, 'Target Max Band Percent', minval = 0.05, maxval = 5.00, step = 0.05, group = G_TARGET, tooltip = 'Caps the target volatility band as a percent of price.')
targetDistanceMult = input.float(10.0, 'ATR Target Distance Multiplier', minval = 1.0, maxval = 50.0, step = 0.5, group = G_TARGET, tooltip = 'Multiplies the capped volatility band to estimate ATR-band risk distance.')
targetStructureBuffer = input.float(2.0, 'Structure Stop Buffer', minval = 0.25, maxval = 10.0, step = 0.25, group = G_TARGET, tooltip = 'Extra volatility-band buffer beyond the trendline when using Structure or Hybrid mode.')
targetForwardBars = input.int(80, 'Target Line Forward Bars', minval = 10, maxval = 300, group = G_TARGET, tooltip = 'How far TP/SL lines project forward while the target setup is active.')
targetReplaceOnNewSignal = input.bool(true, 'Replace Target On New Signal', group = G_TARGET, tooltip = 'When enabled, a new valid target signal replaces the previous active target projection.')
targetStopByClose = input.bool(true, 'Stop Uses Close Confirmation', group = G_TARGET, tooltip = 'When enabled, stop is confirmed by close beyond SL. When disabled, wick touch can trigger stop.')

showConfirmedLines = input.bool(true, 'Show Confirmed Lines', group = G_VISUAL, tooltip = 'Shows confirmed ranked trendlines.')
showDevelopingLines = input.bool(false, 'Show Developing Lines', group = G_VISUAL, tooltip = 'Shows latest pivot-to-pivot developing support and resistance. Disabled by default for publication cleanliness.')
showChannels = input.bool(false, 'Show Confidence Channels', group = G_VISUAL, tooltip = 'Shows ATR confidence channels around visible confirmed lines.')
showLineLabels = input.bool(true, 'Show Right-Side Line Labels', group = G_VISUAL, tooltip = 'Shows compact quality labels at the right side of visible lines.')
showNearest = input.bool(true, 'Show Nearest Support And Resistance', group = G_VISUAL, tooltip = 'Plots nearest valid dynamic support and resistance.')
showNearestLabels = input.bool(true, 'Show Nearest Price Labels', group = G_VISUAL, tooltip = 'Shows compact right-side labels for nearest support and resistance.')
showPivotAnchors = input.bool(false, 'Show Pivot Anchor Markers', group = G_VISUAL, tooltip = 'Shows small confirmed pivot markers. Useful for educational screenshots, disabled by default.')
showRangeFill = input.bool(false, 'Fill Nearest Range', group = G_VISUAL, tooltip = 'Fills the area between nearest support and resistance.')
visualTheme = input.string('Institutional Dark', 'Visual Theme', options = ['Institutional Dark', 'Clean Light', 'Monochrome'], group = G_VISUAL, tooltip = 'Chart theme for trendlines and dashboard.')
chartDensity = input.string('Publication', 'Chart Density', options = ['Minimal', 'Publication', 'Full'], group = G_VISUAL, tooltip = 'Minimal hides most labels and extra context. Publication is clean and balanced. Full shows more detail.')
lineExtensionMode = input.string('Right', 'Line Extension Mode', options = ['Right', 'Both', 'None'], group = G_VISUAL, tooltip = 'Right projects lines forward. Both extends backward and forward. None keeps only the anchored segment.')
visibleSupports = input.int(2, 'Visible Support Lines', minval = 0, maxval = 10, group = G_VISUAL, tooltip = 'Maximum visible support trendlines before chart-density adjustment.')
visibleResistances = input.int(2, 'Visible Resistance Lines', minval = 0, maxval = 10, group = G_VISUAL, tooltip = 'Maximum visible resistance trendlines before chart-density adjustment.')
minVisibleLineSpacingATR = input.float(0.45, 'Minimum Visible Line Spacing ATR', minval = 0.00, maxval = 3.00, step = 0.05, group = G_VISUAL, tooltip = 'Hides weaker same-side lines that are too close to a stronger line. This reduces fan-line clutter.')
maxVisibleDistanceATR = input.float(6.0, 'Maximum Visible Distance ATR', minval = 1.0, maxval = 100.0, step = 0.5, group = G_VISUAL, tooltip = 'Trendlines farther than this ATR distance from current price are hidden.')
devVisibleDistanceATR = input.float(4.0, 'Developing Line Visible Distance ATR', minval = 0.5, maxval = 30.0, step = 0.5, group = G_VISUAL, tooltip = 'Developing lines are shown only when their current price is within this ATR distance from price.')
lineForwardBars = input.int(95, 'Confirmed Line Forward Bars', minval = 20, maxval = 300, group = G_VISUAL, tooltip = 'How far confirmed lines project into the future.')
devForwardBars = input.int(55, 'Developing Line Forward Bars', minval = 10, maxval = 200, group = G_VISUAL, tooltip = 'How far developing lines project into the future.')
hideBrokenSupport = input.bool(true, 'Hide Broken Support Lines', group = G_VISUAL, tooltip = 'Hides support lines when price is materially below them.')
hideBrokenResistance = input.bool(false, 'Hide Broken Resistance Lines', group = G_VISUAL, tooltip = 'Hides resistance lines when price is materially above them.')
showTrendStateWatermark = input.bool(false, 'Show Trend State Watermark', group = G_VISUAL, tooltip = 'Shows detected trend geometry in the middle of the chart.')
watermarkTransparency = input.int(88, 'Watermark Transparency', minval = 75, maxval = 100, step = 1, group = G_VISUAL, tooltip = 'Controls how transparent the trend-state watermark is.')
geometrySlopeThreshold = input.float(0.015, 'Geometry Flat Threshold ATR', minval = 0.000, maxval = 0.200, step = 0.001, group = G_VISUAL, tooltip = 'Slope below this ATR-per-bar value is treated as flat for channel and triangle classification.')

// ==============================================================================
// EDITABLE STYLE PANEL
// ==============================================================================
useCustomTrendlineColors = input.bool(false, 'Use Custom Trendline Colors', group = G_STYLE, tooltip = 'When enabled, confirmed support and resistance lines use the custom colors below instead of the selected theme.')
customSupportColor = input.color(color.rgb(12, 175, 105), 'Custom Support Color', group = G_STYLE, tooltip = 'Custom color for support trendlines, support labels, and bullish markers when custom colors are enabled.')
customResistanceColor = input.color(color.rgb(220, 70, 70), 'Custom Resistance Color', group = G_STYLE, tooltip = 'Custom color for resistance trendlines, resistance labels, and bearish markers when custom colors are enabled.')

confirmedLineTransparency = input.int(16, 'Confirmed Line Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for confirmed ranked trendlines. Lower is stronger, higher is lighter.')
confirmedLineStyleMode = input.string('Auto By Quality', 'Confirmed Line Style', options = ['Auto By Quality', 'Solid', 'Dashed', 'Dotted'], group = G_STYLE, tooltip = 'Auto uses solid/dashed/dotted based on quality. Manual options force one style for all confirmed trendlines.')
confirmedLineWidthMode = input.string('Auto By Quality', 'Confirmed Line Width', options = ['Auto By Quality', 'Manual'], group = G_STYLE, tooltip = 'Auto increases width for high-quality lines. Manual uses the selected fixed width.')
confirmedLineManualWidth = input.int(2, 'Manual Confirmed Line Width', minval = 1, maxval = 5, group = G_STYLE, tooltip = 'Fixed width used when Confirmed Line Width is set to Manual.')

channelWidthATR = input.float(0.22, 'Channel Width ATR', minval = 0.05, maxval = 1.50, step = 0.01, group = G_STYLE, tooltip = 'ATR channel width when confidence channels are enabled.')
channelTransparency = input.int(84, 'Channel Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for confidence channel lines.')

developingLineTransparency = input.int(30, 'Developing Line Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for developing pivot-to-pivot trendlines.')
developingLineWidth = input.int(1, 'Developing Line Width', minval = 1, maxval = 5, group = G_STYLE, tooltip = 'Width for developing support and resistance lines.')
developingLineStyleInput = input.string('Dashed', 'Developing Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = G_STYLE, tooltip = 'Style for developing support and resistance lines.')
developingLabelTransparency = input.int(30, 'Developing Label Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for developing line labels.')

nearestLineTransparency = input.int(20, 'Nearest S/R Line Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for nearest dynamic support and resistance plots.')
nearestLineWidth = input.int(2, 'Nearest S/R Line Width', minval = 1, maxval = 5, group = G_STYLE, tooltip = 'Width for nearest dynamic support and resistance plots.')
nearestLabelTransparency = input.int(12, 'Nearest Label Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for nearest support and resistance price labels.')

lineLabelTransparency = input.int(12, 'Line Label Background Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for right-side trendline quality labels.')
labelSizeInput = input.string('Tiny', 'Label Size', options = ['Tiny', 'Small', 'Normal'], group = G_STYLE, tooltip = 'Size of line and signal labels.')
labelStackATR = input.float(0.08, 'Label Stack Offset ATR', minval = 0.00, maxval = 1.00, step = 0.01, group = G_STYLE, tooltip = 'Offsets right-side labels vertically by rank to reduce overlap.')

signalMarkerTransparency = input.int(8, 'Signal Marker Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for breakout, retest, rejection, and failed-break markers.')

targetEntryColor = input.color(color.rgb(255, 255, 255), 'Target Entry Line Color', group = G_STYLE, tooltip = 'Color for the target entry reference line.')
targetTPColor = input.color(color.rgb(210, 170, 55), 'Target TP Line Color', group = G_STYLE, tooltip = 'Color for the target take-profit line.')
targetSLColor = input.color(color.rgb(220, 70, 70), 'Target SL Line Color', group = G_STYLE, tooltip = 'Color for the target stop-loss line.')
targetEntryTransparency = input.int(50, 'Target Entry Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for target entry line.')
targetTPTransparency = input.int(0, 'Target TP Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for target TP line.')
targetSLTransparency = input.int(20, 'Target SL Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for target SL line.')
targetLineWidth = input.int(2, 'Target TP Line Width', minval = 1, maxval = 5, group = G_STYLE, tooltip = 'Width for the TP line.')
targetRiskLineWidth = input.int(1, 'Target Entry/SL Line Width', minval = 1, maxval = 5, group = G_STYLE, tooltip = 'Width for entry and SL lines.')
targetLineStyleInput = input.string('Dashed', 'Target Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = G_STYLE, tooltip = 'Style for TP and SL target lines.')
targetLabelTransparency = input.int(10, 'Target Label Transparency', minval = 0, maxval = 100, group = G_STYLE, tooltip = 'Transparency for the target label background.')

showPanel = input.bool(true, 'Show Dashboard', group = G_PANEL, tooltip = 'Shows compact structure dashboard.')
panelPosition = input.string('Top Right', 'Dashboard Position', options = ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right'], group = G_PANEL, tooltip = 'Dashboard location.')

enableAlertConditions = input.bool(true, 'Enable Alert Conditions', group = G_ALERTS, tooltip = 'Enables TradingView alertcondition outputs.')
enableInlineAlerts = input.bool(false, 'Enable Inline JSON Alerts', group = G_ALERTS, tooltip = 'Allows compact JSON alert messages through alert() calls.')

// ==============================================================================
// COLORS
// ==============================================================================
f_theme() =>
    color sup = color.rgb(12, 175, 105)
    color res = color.rgb(220, 70, 70)
    color neu = color.rgb(45, 55, 70)
    color prem = color.rgb(210, 170, 55)
    if visualTheme == 'Clean Light'
        sup := color.rgb(20, 130, 85)
        res := color.rgb(185, 60, 60)
        neu := color.rgb(70, 80, 95)
        prem := color.rgb(190, 145, 35)
    if visualTheme == 'Monochrome'
        sup := color.rgb(215, 215, 215)
        res := color.rgb(150, 150, 150)
        neu := color.rgb(90, 90, 90)
        prem := color.rgb(235, 235, 235)
    [sup, res, neu, prem]

[themeSupportColor, themeResistanceColor, neutralColor, premiumColor] = f_theme()
supportColor = useCustomTrendlineColors ? customSupportColor : themeSupportColor
resistanceColor = useCustomTrendlineColors ? customResistanceColor : themeResistanceColor

// ==============================================================================
// BASIC HELPERS
// ==============================================================================
f_clamp(x, lo, hi) =>
    math.max(lo, math.min(x, hi))

f_tick(x) =>
    roundToTick and not na(x) ? math.round(x / syminfo.mintick) * syminfo.mintick : x

f_price(m, b, x) =>
    m * float(x) + b

f_label_size() =>
    labelSizeInput == 'Tiny' ? size.tiny : labelSizeInput == 'Normal' ? size.normal : size.small

f_style_from_input(styleText) =>
    styleText == 'Solid' ? line.style_solid : styleText == 'Dotted' ? line.style_dotted : line.style_dashed

f_quality_text(q) =>
    q >= 80 ? 'Elite' : q >= 65 ? 'Strong' : q >= 45 ? 'Valid' : 'Developing'

f_line_style(q) =>
    confirmedLineStyleMode == 'Auto By Quality' ? q >= 72 ? line.style_solid : q >= 52 ? line.style_dashed : line.style_dotted : f_style_from_input(confirmedLineStyleMode)

f_line_width(q, clusters) =>
    if confirmedLineWidthMode == 'Manual'
        confirmedLineManualWidth
    else
        base = q >= 82 ? 3 : q >= 65 ? 2 : 1
        clusters >= 5 ? math.min(base + 1, 3) : base

f_panel_pos(pos) =>
    pos == 'Top Left' ? position.top_left : pos == 'Top Right' ? position.top_right : pos == 'Bottom Left' ? position.bottom_left : position.bottom_right

f_extend_mode() =>
    lineExtensionMode == 'Both' ? extend.both : lineExtensionMode == 'None' ? extend.none : extend.right

f_dir_text(dir) =>
    dir == 1 ? 'UP' : dir == -1 ? 'DOWN' : 'FLAT'

f_geometry_name(kind, m) =>
    kind == -1 ? m >= 0 ? 'Up/High' : 'Down/High' : m >= 0 ? 'Up/Low' : 'Down/Low'

// ==============================================================================
// TECHNICALS
// ==============================================================================
atr14 = ta.atr(14)
atr50 = ta.atr(50)
pkRaw = low > 0 ? math.sqrt(math.pow(math.log(high / low), 2.0) / (4.0 * math.log(2.0))) * close : 0.0
pkVol = ta.ema(pkRaw, 14)
atrAdaptive = math.max((atr14 * 0.70 + atr50 * 0.30 + pkVol * 0.20) / 1.20, syminfo.mintick)

targetVolBandRaw = math.min(ta.atr(targetATRLength) * targetATRMultiplier, close * targetMaxPercent * 0.01)
targetVolBand = math.max(targetVolBandRaw, syminfo.mintick)

rsi = ta.sma(ta.rsi(close, 14), 3)
[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
vwapValue = ta.vwap(hlc3)

volAvg = ta.sma(volume, volumeLength)
volRatio = volAvg > 0 ? volume / volAvg : na

upMove = high - high[1]
downMove = low[1] - low
plusDM = upMove > downMove and upMove > 0 ? upMove : 0.0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0.0
trNow = math.max(math.max(high - low, math.abs(high - close[1])), math.abs(low - close[1]))
trRma = ta.rma(trNow, 14)
plusRma = ta.rma(plusDM, 14)
minusRma = ta.rma(minusDM, 14)
plusDI = trRma != 0 ? 100.0 * plusRma / trRma : 0.0
minusDI = trRma != 0 ? 100.0 * minusRma / trRma : 0.0
dx = plusDI + minusDI != 0 ? 100.0 * math.abs(plusDI - minusDI) / (plusDI + minusDI) : 0.0
adx = ta.rma(dx, 14)
isTrending = adx >= 20

precisionAdj = precisionMode == 'Conservative' ? 5.0 : precisionMode == 'Aggressive' ? -4.0 : 0.0
createQualityFloor = f_clamp(minQuality + precisionAdj, 10.0, 98.0)
visibleQualityFloor = f_clamp(minEffectiveQuality + precisionAdj, 10.0, 98.0)
signalRawFloor = f_clamp(signalQuality + precisionAdj, 10.0, 98.0)
signalEffectiveFloor = f_clamp(signalEffectiveQuality + precisionAdj, 10.0, 98.0)

effectiveSupports = chartDensity == 'Minimal' ? math.min(visibleSupports, 1) : chartDensity == 'Full' ? visibleSupports : math.min(visibleSupports, 2)
effectiveResistances = chartDensity == 'Minimal' ? math.min(visibleResistances, 1) : chartDensity == 'Full' ? visibleResistances : math.min(visibleResistances, 2)
effectiveShowLineLabels = chartDensity == 'Minimal' ? false : showLineLabels
effectiveShowChannels = chartDensity == 'Full' ? showChannels : chartDensity == 'Publication' ? showChannels : false

f_slope_dir(m, atrRef) =>
    slopeAtr = m / math.max(atrRef, syminfo.mintick)
    slopeAtr > geometrySlopeThreshold ? 1 : slopeAtr < -geometrySlopeThreshold ? -1 : 0

f_calc_targets(dir, linePrice) =>
    entry = close
    band = targetVolBand
    atrRisk = band * targetDistanceMult
    structLong = entry - (linePrice - band * targetStructureBuffer)
    structShort = linePrice + band * targetStructureBuffer - entry
    riskCandidate = dir == 1 ? targetMode == 'ATR Band' ? atrRisk : targetMode == 'Structure' ? structLong : math.max(atrRisk, structLong) : targetMode == 'ATR Band' ? atrRisk : targetMode == 'Structure' ? structShort : math.max(atrRisk, structShort)
    risk = math.max(riskCandidate, band)
    sl = dir == 1 ? entry - risk : entry + risk
    tp = dir == 1 ? entry + risk * targetRewardRisk : entry - risk * targetRewardRisk
    [f_tick(entry), f_tick(sl), f_tick(tp), risk]

// ==============================================================================
// MTF BIAS
// ==============================================================================
htf1Close = request.security(syminfo.tickerid, htf1, close, barmerge.gaps_off, barmerge.lookahead_off)
htf1Ema50 = request.security(syminfo.tickerid, htf1, ta.ema(close, 50), barmerge.gaps_off, barmerge.lookahead_off)
htf1Ema200 = request.security(syminfo.tickerid, htf1, ta.ema(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

htf2Close = request.security(syminfo.tickerid, htf2, close, barmerge.gaps_off, barmerge.lookahead_off)
htf2Ema50 = request.security(syminfo.tickerid, htf2, ta.ema(close, 50), barmerge.gaps_off, barmerge.lookahead_off)
htf2Ema200 = request.security(syminfo.tickerid, htf2, ta.ema(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

htf1Bull = not na(htf1Close) and htf1Close > htf1Ema50 and htf1Ema50 > htf1Ema200
htf1Bear = not na(htf1Close) and htf1Close < htf1Ema50 and htf1Ema50 < htf1Ema200
htf2Bull = not na(htf2Close) and htf2Close > htf2Ema50 and htf2Ema50 > htf2Ema200
htf2Bear = not na(htf2Close) and htf2Close < htf2Ema50 and htf2Ema50 < htf2Ema200

htfBullCount = (htf1Bull ? 1 : 0) + (htf2Bull ? 1 : 0)
htfBearCount = (htf1Bear ? 1 : 0) + (htf2Bear ? 1 : 0)

// ==============================================================================
// ADVANCED QUALITY HELPERS
// ==============================================================================
f_mtf_quality(kind) =>
    if not enableMTF
        1.0
    else
        agree = kind == 1 ? htfBullCount : htfBearCount
        conflict = kind == 1 ? htfBearCount : htfBullCount
        agree >= 2 ? 1.05 : agree == 1 ? 1.02 : conflict >= 2 ? 0.95 : 1.0

f_confluence_score(linePrice) =>
    d1 = math.abs(linePrice - ema20) / atrAdaptive
    d2 = math.abs(linePrice - ema50) / atrAdaptive
    d3 = math.abs(linePrice - ema200) / atrAdaptive
    d4 = na(vwapValue) ? 999.0 : math.abs(linePrice - vwapValue) / atrAdaptive
    dMin = math.min(math.min(d1, d2), math.min(d3, d4))
    f_clamp(1.0 - dMin / 1.50, 0.0, 1.0)

f_slope_ok(m) =>
    slopeAtrPerBar = math.abs(m) / math.max(atrAdaptive, syminfo.mintick)
    angleDeg = math.abs(math.atan(slopeAtrPerBar) * 180.0 / math.pi)
    slopeAtrPerBar >= minSlopeAtrPerBar and slopeAtrPerBar <= maxSlopeAtrPerBar and angleDeg <= maxSlopeAngleDeg

f_signal_filter(dir) =>
    trendOk = dir == 1 ? close > ema20 and ema20 >= ema50 : close < ema20 and ema20 <= ema50
    momentumOk = dir == 1 ? rsi >= 50 and macdHist >= 0 : rsi <= 50 and macdHist <= 0
    modeOk = signalFilterMode == 'None' ? true : signalFilterMode == 'Trend' ? trendOk : signalFilterMode == 'Momentum' ? momentumOk : trendOk and momentumOk
    mtfOk = not requireMTFAgreement or not enableMTF or (dir == 1 ? htfBullCount >= htfBearCount : htfBearCount >= htfBullCount)
    volumeOk = not useVolumeFilter or na(volRatio) or volRatio >= volumeRatioMin
    modeOk and mtfOk and volumeOk

f_body_break_ok(dir, linePrice, tol) =>
    if not requireBodyBreak
        true
    else
        dir == 1 ? math.min(open, close) > linePrice + tol * 0.20 : math.max(open, close) < linePrice - tol * 0.20

// ==============================================================================
// STORAGE
// ==============================================================================
var array<int> pivotHighBars = array.new_int()
var array<float> pivotHighPrices = array.new_float()
var array<int> pivotLowBars = array.new_int()
var array<float> pivotLowPrices = array.new_float()

var array<line> midLines = array.new_line()
var array<line> upperLines = array.new_line()
var array<line> lowerLines = array.new_line()
var array<label> tags = array.new_label()

var array<int> kindArr = array.new_int()
var array<float> mArr = array.new_float()
var array<float> bArr = array.new_float()
var array<float> qArr = array.new_float()
var array<int> clusterArr = array.new_int()
var array<int> touchArr = array.new_int()
var array<float> fitArr = array.new_float()
var array<float> respectArr = array.new_float()
var array<int> createdArr = array.new_int()
var array<int> lastTouchArr = array.new_int()
var array<int> lastSignalArr = array.new_int()
var array<int> lastBreakBarArr = array.new_int()
var array<int> lastBreakDirArr = array.new_int()
var array<string> srcArr = array.new_string()
var array<int> a1BarArr = array.new_int()
var array<float> a1PriceArr = array.new_float()
var array<int> a2BarArr = array.new_int()
var array<float> a2PriceArr = array.new_float()

var array<label> signalLabels = array.new_label()

var line devSupLine = na
var line devResLine = na
var label devSupLabel = na
var label devResLabel = na
var label nearestSupLabel = na
var label nearestResLabel = na

var bool targetActive = false
var int targetDir = 0
var float targetEntry = na
var float targetSL = na
var float targetTP = na
var float targetRisk = na
var string targetStatus = 'IDLE'
var line targetEntryLine = na
var line targetTPLine = na
var line targetSLLine = na
var label targetLab = na

// ==============================================================================
// PIVOT COLLECTION
// ==============================================================================
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

if not na(ph)
    array.push(pivotHighBars, bar_index - pivotRight)
    array.push(pivotHighPrices, ph)

if not na(pl)
    array.push(pivotLowBars, bar_index - pivotRight)
    array.push(pivotLowPrices, pl)

while array.size(pivotHighBars) > maxStoredPivots
    array.shift(pivotHighBars)
    array.shift(pivotHighPrices)

while array.size(pivotLowBars) > maxStoredPivots
    array.shift(pivotLowBars)
    array.shift(pivotLowPrices)

plotshape(showPivotAnchors and not na(ph), title = 'Confirmed Pivot High Anchor', style = shape.circle, location = location.abovebar, offset = -pivotRight, size = size.tiny, color = color.new(resistanceColor, 20))
plotshape(showPivotAnchors and not na(pl), title = 'Confirmed Pivot Low Anchor', style = shape.circle, location = location.belowbar, offset = -pivotRight, size = size.tiny, color = color.new(supportColor, 20))

// ==============================================================================
// LEVEL HELPERS
// ==============================================================================
f_level_count() =>
    array.size(mArr)

f_effective_q(i) =>
    q = array.get(qArr, i)
    created = array.get(createdArr, i)
    lastTouch = array.get(lastTouchArr, i)
    m = array.get(mArr, i)
    b = array.get(bArr, i)
    age = math.max(0, bar_index - created)
    stale = math.max(0, bar_index - lastTouch)
    lineNow = f_price(m, b, bar_index)
    confluenceBoost = f_confluence_score(lineNow) * 3.5
    agePenalty = math.min(10.0, float(age) / 100.0 * agePenaltyPer100)
    stalePenalty = math.min(14.0, float(stale) / 100.0 * stalePenaltyPer100)
    f_clamp(q + confluenceBoost - agePenalty - stalePenalty, 0.0, 100.0)

f_display_score(idx) =>
    eq = f_effective_q(idx)
    m = array.get(mArr, idx)
    b = array.get(bArr, idx)
    v = f_price(m, b, bar_index)
    distATR = math.abs(close - v) / atrAdaptive
    lastTouch = array.get(lastTouchArr, idx)
    stale = math.max(0, bar_index - lastTouch)
    recency = f_clamp(1.0 - float(stale) / math.max(float(maxLineAgeBars), 1.0), 0.0, 1.0)
    clusters = array.get(clusterArr, idx)
    respect = array.get(respectArr, idx)
    eq + recency * 7.0 + float(clusters) * 1.20 + respect * 4.0 - distATR * 3.50

f_side_rank(idx) =>
    myKind = array.get(kindArr, idx)
    myScore = f_display_score(idx)
    rank = 1
    n = f_level_count()
    if n > 0
        for i = 0 to n - 1 by 1
            if i != idx and array.get(kindArr, i) == myKind and f_display_score(i) > myScore
                rank += 1
    rank

f_spacing_ok(idx) =>
    ok = true
    myKind = array.get(kindArr, idx)
    myScore = f_display_score(idx)
    myPrice = f_price(array.get(mArr, idx), array.get(bArr, idx), bar_index)
    n = f_level_count()
    if n > 0 and minVisibleLineSpacingATR > 0
        for i = 0 to n - 1 by 1
            if i != idx and array.get(kindArr, i) == myKind
                otherScore = f_display_score(i)
                otherPrice = f_price(array.get(mArr, i), array.get(bArr, i), bar_index)
                if otherScore > myScore and math.abs(myPrice - otherPrice) <= atrAdaptive * minVisibleLineSpacingATR
                    ok := false
    ok

f_duplicate_index(m, b, kind) =>
    out = -1
    n = f_level_count()
    if n > 0
        nowVal = f_price(m, b, bar_index)
        futureVal = f_price(m, b, bar_index + lineForwardBars)
        for i = 0 to n - 1 by 1
            if array.get(kindArr, i) == kind
                oldM = array.get(mArr, i)
                oldB = array.get(bArr, i)
                oldNow = f_price(oldM, oldB, bar_index)
                oldFuture = f_price(oldM, oldB, bar_index + lineForwardBars)
                priceDiffNow = math.abs(nowVal - oldNow)
                priceDiffFuture = math.abs(futureVal - oldFuture)
                slopeDiffAtr = math.abs(m - oldM) / math.max(atrAdaptive, syminfo.mintick)
                if priceDiffNow <= atrAdaptive * duplicatePriceATR and priceDiffFuture <= atrAdaptive * duplicatePriceATR and slopeDiffAtr <= duplicateSlopeATR
                    out := i
                    break
    out

f_remove_level(idx) =>
    if idx >= 0 and idx < f_level_count()
        line.delete(array.get(midLines, idx))
        line.delete(array.get(upperLines, idx))
        line.delete(array.get(lowerLines, idx))
        label.delete(array.get(tags, idx))

        array.remove(midLines, idx)
        array.remove(upperLines, idx)
        array.remove(lowerLines, idx)
        array.remove(tags, idx)

        array.remove(kindArr, idx)
        array.remove(mArr, idx)
        array.remove(bArr, idx)
        array.remove(qArr, idx)
        array.remove(clusterArr, idx)
        array.remove(touchArr, idx)
        array.remove(fitArr, idx)
        array.remove(respectArr, idx)
        array.remove(createdArr, idx)
        array.remove(lastTouchArr, idx)
        array.remove(lastSignalArr, idx)
        array.remove(lastBreakBarArr, idx)
        array.remove(lastBreakDirArr, idx)
        array.remove(srcArr, idx)
        array.remove(a1BarArr, idx)
        array.remove(a1PriceArr, idx)
        array.remove(a2BarArr, idx)
        array.remove(a2PriceArr, idx)
    true

f_add_or_update(m, b, q, clusters, touches, fit, respect, kind, lb, lastTouch, a1Bar, a1Price, a2Bar, a2Price) =>
    if not na(m) and not na(b) and not na(a1Bar) and not na(a2Bar) and q >= createQualityFloor and f_slope_ok(m)
        dup = f_duplicate_index(m, b, kind)
        if dup >= 0
            if q > array.get(qArr, dup)
                array.set(mArr, dup, m)
                array.set(bArr, dup, b)
                array.set(qArr, dup, q)
                array.set(clusterArr, dup, clusters)
                array.set(touchArr, dup, touches)
                array.set(fitArr, dup, fit)
                array.set(respectArr, dup, respect)
                array.set(kindArr, dup, kind)
                array.set(lastTouchArr, dup, na(lastTouch) ? array.get(lastTouchArr, dup) : lastTouch)
                array.set(srcArr, dup, 'LB ' + str.tostring(lb))
                array.set(a1BarArr, dup, a1Bar)
                array.set(a1PriceArr, dup, a1Price)
                array.set(a2BarArr, dup, a2Bar)
                array.set(a2PriceArr, dup, a2Price)
        else
            x1 = a1Bar
            x2 = bar_index + lineForwardBars
            y1 = f_tick(f_price(m, b, x1))
            y2 = f_tick(f_price(m, b, x2))
            baseCol = kind == 1 ? supportColor : resistanceColor
            ch = atrAdaptive * channelWidthATR

            midLine = line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = f_extend_mode(), color = color.new(baseCol, 100), width = 2, style = line.style_solid)
            upperLine = line.new(x1, y1 + ch, x2, y2 + ch, xloc = xloc.bar_index, extend = f_extend_mode(), color = color.new(baseCol, 100), width = 1, style = line.style_dotted)
            lowerLine = line.new(x1, y1 - ch, x2, y2 - ch, xloc = xloc.bar_index, extend = f_extend_mode(), color = color.new(baseCol, 100), width = 1, style = line.style_dotted)
            tagObj = label.new(x2, y2, '', xloc = xloc.bar_index, style = kind == 1 ? label.style_label_up : label.style_label_down, color = color.new(baseCol, 100), textcolor = color.new(color.white, 100), size = f_label_size())

            array.push(midLines, midLine)
            array.push(upperLines, upperLine)
            array.push(lowerLines, lowerLine)
            array.push(tags, tagObj)

            array.push(kindArr, kind)
            array.push(mArr, m)
            array.push(bArr, b)
            array.push(qArr, q)
            array.push(clusterArr, clusters)
            array.push(touchArr, touches)
            array.push(fitArr, fit)
            array.push(respectArr, respect)
            array.push(createdArr, bar_index)
            array.push(lastTouchArr, na(lastTouch) ? bar_index : lastTouch)
            array.push(lastSignalArr, -10000)
            array.push(lastBreakBarArr, -1)
            array.push(lastBreakDirArr, 0)
            array.push(srcArr, 'LB ' + str.tostring(lb))
            array.push(a1BarArr, a1Bar)
            array.push(a1PriceArr, a1Price)
            array.push(a2BarArr, a2Bar)
            array.push(a2PriceArr, a2Price)
    true

f_prune() =>
    i = 0
    while i < f_level_count()
        eq = f_effective_q(i)
        createdAge = bar_index - array.get(createdArr, i)
        anchorAge = bar_index - array.get(a1BarArr, i)
        kind = array.get(kindArr, i)
        lineNow = f_price(array.get(mArr, i), array.get(bArr, i), bar_index)
        brokenSupport = kind == 1 and close < lineNow - atrAdaptive * 0.80
        brokenResistance = kind == -1 and close > lineNow + atrAdaptive * 0.80

        removeLine = anchorAge > maxLineAgeBars or createdAge > maxLineAgeBars * 2 or eq < visibleQualityFloor - 22
        removeLine := removeLine or hideBrokenSupport and brokenSupport and createdAge > 30
        removeLine := removeLine or hideBrokenResistance and brokenResistance and createdAge > 30

        if removeLine
            f_remove_level(i)
        else
            i += 1

    while f_level_count() > maxActiveLines
        weak = 0
        weakQ = 999.0
        for j = 0 to f_level_count() - 1 by 1
            qj = f_display_score(j)
            if qj < weakQ
                weakQ := qj
                weak := j
        f_remove_level(weak)
    true

// ==============================================================================
// DISCOVERY ENGINE
// ==============================================================================
processNow = confirmedOnly ? barstate.isconfirmed : true
inRecentWindow = last_bar_index - bar_index <= analysisBackBars
shouldDiscover = processNow and inRecentWindow and bar_index % detectEveryBars == 0

if shouldDiscover
    lbArr = array.from(lookback1, lookback2, lookback3)

    for lbIdx = 0 to array.size(lbArr) - 1 by 1
        lb = array.get(lbArr, lbIdx)
        minSep = int(math.round(float(lb) * minAnchorSeparation))

        for side = 0 to 1 by 1
            kind = side == 0 ? 1 : -1
            barsArr = kind == 1 ? pivotLowBars : pivotHighBars
            priceArr = kind == 1 ? pivotLowPrices : pivotHighPrices
            pCount = array.size(barsArr)

            float bestM = na
            float bestB = na
            float bestQ = 0.0
            int bestClusters = 0
            int bestTouches = 0
            float bestFit = 0.0
            float bestRespect = 0.0
            int bestLastTouch = na
            int bestA1Bar = na
            float bestA1Price = na
            int bestA2Bar = na
            float bestA2Price = na

            if pCount >= 2
                startCand = math.max(0, pCount - candidatePivotDepth)
                startScore = math.max(0, pCount - scorePivotDepth)

                if startCand <= pCount - 2
                    for a = startCand to pCount - 2 by 1
                        barA = array.get(barsArr, a)
                        priceA = array.get(priceArr, a)

                        for c = a + 1 to pCount - 1 by 1
                            barC = array.get(barsArr, c)
                            priceC = array.get(priceArr, c)
                            sep = math.abs(barC - barA)

                            if sep >= minSep and barA != barC and bar_index - barA <= lb and bar_index - barC <= lb
                                m = (priceC - priceA) / float(barC - barA)
                                b = priceA - m * float(barA)

                                if f_slope_ok(m)
                                    int touches = 0
                                    int clusters = 0
                                    int lastClusterBar = na
                                    int newestTouchBar = na
                                    int oldestTouchBar = na
                                    float distSum = 0.0
                                    float tolSum = 0.0
                                    float wickSum = 0.0
                                    int rejections = 0
                                    int respectHits = 0
                                    int respectFails = 0

                                    for p = startScore to pCount - 1 by 1
                                        pBar = array.get(barsArr, p)
                                        rawPivotPrice = array.get(priceArr, p)
                                        barsAgo = bar_index - pBar

                                        if barsAgo >= 0 and barsAgo < 3000 and bar_index - pBar <= lb
                                            pPrice = touchSource == 'Bodies' ? kind == 1 ? math.min(open[barsAgo], close[barsAgo]) : math.max(open[barsAgo], close[barsAgo]) : rawPivotPrice
                                            linePriceAtPivot = f_price(m, b, pBar)
                                            histATR = useHistoricalATR ? math.max(nz(atrAdaptive[barsAgo], atrAdaptive), syminfo.mintick) : atrAdaptive
                                            tolPivot = histATR * touchATR
                                            distPivot = math.abs(pPrice - linePriceAtPivot)

                                            if distPivot <= tolPivot
                                                touches += 1
                                                distSum += distPivot
                                                tolSum += tolPivot
                                                newestTouchBar := na(newestTouchBar) ? pBar : math.max(newestTouchBar, pBar)
                                                oldestTouchBar := na(oldestTouchBar) ? pBar : math.min(oldestTouchBar, pBar)

                                                if na(lastClusterBar) or math.abs(pBar - lastClusterBar) >= touchClusterGap
                                                    clusters += 1
                                                    lastClusterBar := pBar

                                                candleRange = math.max(high[barsAgo] - low[barsAgo], syminfo.mintick)
                                                lowerWick = math.max(math.min(open[barsAgo], close[barsAgo]) - low[barsAgo], 0.0) / candleRange
                                                upperWick = math.max(high[barsAgo] - math.max(open[barsAgo], close[barsAgo]), 0.0) / candleRange
                                                wickSum += kind == 1 ? lowerWick : upperWick

                                                rejected = kind == 1 ? close[barsAgo] > linePriceAtPivot : close[barsAgo] < linePriceAtPivot
                                                if rejected
                                                    rejections += 1

                                    violations = 0
                                    checked = 0
                                    step = math.max(1, int(math.round(float(lb) / float(sampledBars))))
                                    j = 0

                                    while j <= lb and j <= bar_index and j < 3000
                                        linePriceSample = f_price(m, b, bar_index - j)
                                        histATRSample = useHistoricalATR ? math.max(nz(atrAdaptive[j], atrAdaptive), syminfo.mintick) : atrAdaptive
                                        violationTol = histATRSample * violationATR

                                        sampleHigh = high[j]
                                        sampleLow = low[j]
                                        sampleOpen = open[j]
                                        sampleClose = close[j]
                                        bodyEdge = kind == 1 ? math.min(sampleOpen, sampleClose) : math.max(sampleOpen, sampleClose)
                                        candleCrossesLine = sampleHigh >= linePriceSample and sampleLow <= linePriceSample
                                        wickRespectsLine = candleCrossesLine and (kind == 1 ? bodyEdge >= linePriceSample : bodyEdge <= linePriceSample)

                                        if wickRespectsLine
                                            respectHits += 1

                                        violated = kind == 1 ? sampleClose < linePriceSample - violationTol : sampleClose > linePriceSample + violationTol
                                        if violated
                                            violations += 1
                                            respectFails += 1

                                        checked += 1
                                        j += step

                                    avgDist = touches > 0 ? distSum / float(touches) : 1e10
                                    avgTol = touches > 0 ? tolSum / float(touches) : atrAdaptive
                                    fitScore = touches > 0 ? f_clamp(1.0 - avgDist / math.max(avgTol, syminfo.mintick), 0.0, 1.0) : 0.0
                                    violationRate = checked > 0 ? float(violations) / float(checked) : 1.0
                                    violationScore = f_clamp(1.0 - violationRate / math.max(maxViolationRate, 0.01), 0.0, 1.0)
                                    respectScore = checked > 0 ? f_clamp((float(respectHits) * 2.0 - float(respectFails)) / float(checked), 0.0, 1.0) : 0.0
                                    touchScore = f_clamp(float(clusters) / float(minTouchClusters + 3), 0.0, 1.0)
                                    rejectionScore = touches > 0 ? f_clamp(float(rejections) / float(touches), 0.0, 1.0) : 0.0
                                    wickScore = touches > 0 ? f_clamp(wickSum / float(touches), 0.0, 1.0) : 0.0
                                    spanScore = not na(newestTouchBar) and not na(oldestTouchBar) ? f_clamp(float(newestTouchBar - oldestTouchBar) / float(lb), 0.0, 1.0) : 0.0
                                    recencyScore = not na(newestTouchBar) ? f_clamp(1.0 - float(bar_index - newestTouchBar) / float(lb), 0.0, 1.0) : 0.0
                                    confluenceScore = f_confluence_score(f_price(m, b, bar_index))

                                    valid = clusters >= minTouchClusters and fitScore >= minFitScore and violationRate <= maxViolationRate

                                    qualityRaw = touchScore * 0.22 + fitScore * 0.16 + violationScore * 0.16 + respectScore * 0.12 + rejectionScore * 0.10 + wickScore * 0.07 + spanScore * 0.07 + recencyScore * 0.06 + confluenceScore * 0.04
                                    q = valid ? qualityRaw * 100.0 * f_mtf_quality(kind) : 0.0
                                    q := f_clamp(q, 0.0, 100.0)

                                    if q > bestQ
                                        olderBar = math.min(barA, barC)
                                        olderPrice = barA <= barC ? priceA : priceC
                                        newerBar = math.max(barA, barC)
                                        newerPrice = barA > barC ? priceA : priceC
                                        bestM := m
                                        bestB := b
                                        bestQ := q
                                        bestClusters := clusters
                                        bestTouches := touches
                                        bestFit := fitScore
                                        bestRespect := respectScore
                                        bestLastTouch := newestTouchBar
                                        bestA1Bar := olderBar
                                        bestA1Price := olderPrice
                                        bestA2Bar := newerBar
                                        bestA2Price := newerPrice

            f_add_or_update(bestM, bestB, bestQ, bestClusters, bestTouches, bestFit, bestRespect, kind, lb, bestLastTouch, bestA1Bar, bestA1Price, bestA2Bar, bestA2Price)

if processNow and inRecentWindow and bar_index % detectEveryBars == 0
    f_prune()

// ==============================================================================
// DEVELOPING LINES
// ==============================================================================
f_hide_dev_line(ln, lb) =>
    if not na(ln)
        line.set_color(ln, color.new(color.gray, 100))
    if not na(lb)
        label.set_text(lb, '')
        label.set_color(lb, color.new(color.gray, 100))
        label.set_textcolor(lb, color.new(color.white, 100))
    true

if barstate.islast
    if showDevelopingLines and chartDensity != 'Minimal'
        nL = array.size(pivotLowBars)
        if nL >= 2
            b1 = array.get(pivotLowBars, nL - 2)
            p1 = array.get(pivotLowPrices, nL - 2)
            b2 = array.get(pivotLowBars, nL - 1)
            p2 = array.get(pivotLowPrices, nL - 1)
            sep = math.abs(b2 - b1)
            if b1 != b2
                m = (p2 - p1) / float(b2 - b1)
                b = p1 - m * float(b1)
                devLineNow = f_price(m, b, bar_index)
                devOk = sep >= 6 and f_slope_ok(m) and math.abs(close - devLineNow) / atrAdaptive <= devVisibleDistanceATR
                if devOk
                    x1 = math.min(b1, b2)
                    x2 = bar_index + devForwardBars
                    y1 = f_tick(f_price(m, b, x1))
                    y2 = f_tick(f_price(m, b, x2))
                    if na(devSupLine)
                        devSupLine := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = f_extend_mode(), color = color.new(supportColor, developingLineTransparency), width = developingLineWidth, style = f_style_from_input(developingLineStyleInput))
                    else
                        line.set_xy1(devSupLine, x1, y1)
                        line.set_xy2(devSupLine, x2, y2)
                        line.set_extend(devSupLine, f_extend_mode())
                        line.set_color(devSupLine, color.new(supportColor, developingLineTransparency))
                        line.set_width(devSupLine, developingLineWidth)
                        line.set_style(devSupLine, f_style_from_input(developingLineStyleInput))
                    if na(devSupLabel)
                        devSupLabel := label.new(x2, y2, 'DEV S', xloc = xloc.bar_index, style = label.style_label_up, color = color.new(supportColor, developingLabelTransparency), textcolor = color.white, size = f_label_size())
                    else
                        label.set_xy(devSupLabel, x2, y2)
                        label.set_text(devSupLabel, 'DEV S')
                        label.set_color(devSupLabel, color.new(supportColor, developingLabelTransparency))
                        label.set_textcolor(devSupLabel, color.white)
                else
                    f_hide_dev_line(devSupLine, devSupLabel)
        else
            f_hide_dev_line(devSupLine, devSupLabel)

        nH = array.size(pivotHighBars)
        if nH >= 2
            b1 = array.get(pivotHighBars, nH - 2)
            p1 = array.get(pivotHighPrices, nH - 2)
            b2 = array.get(pivotHighBars, nH - 1)
            p2 = array.get(pivotHighPrices, nH - 1)
            sep = math.abs(b2 - b1)
            if b1 != b2
                m = (p2 - p1) / float(b2 - b1)
                b = p1 - m * float(b1)
                devLineNow = f_price(m, b, bar_index)
                devOk = sep >= 6 and f_slope_ok(m) and math.abs(close - devLineNow) / atrAdaptive <= devVisibleDistanceATR
                if devOk
                    x1 = math.min(b1, b2)
                    x2 = bar_index + devForwardBars
                    y1 = f_tick(f_price(m, b, x1))
                    y2 = f_tick(f_price(m, b, x2))
                    if na(devResLine)
                        devResLine := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = f_extend_mode(), color = color.new(resistanceColor, developingLineTransparency), width = developingLineWidth, style = f_style_from_input(developingLineStyleInput))
                    else
                        line.set_xy1(devResLine, x1, y1)
                        line.set_xy2(devResLine, x2, y2)
                        line.set_extend(devResLine, f_extend_mode())
                        line.set_color(devResLine, color.new(resistanceColor, developingLineTransparency))
                        line.set_width(devResLine, developingLineWidth)
                        line.set_style(devResLine, f_style_from_input(developingLineStyleInput))
                    if na(devResLabel)
                        devResLabel := label.new(x2, y2, 'DEV R', xloc = xloc.bar_index, style = label.style_label_down, color = color.new(resistanceColor, developingLabelTransparency), textcolor = color.white, size = f_label_size())
                    else
                        label.set_xy(devResLabel, x2, y2)
                        label.set_text(devResLabel, 'DEV R')
                        label.set_color(devResLabel, color.new(resistanceColor, developingLabelTransparency))
                        label.set_textcolor(devResLabel, color.white)
                else
                    f_hide_dev_line(devResLine, devResLabel)
        else
            f_hide_dev_line(devResLine, devResLabel)
    else
        f_hide_dev_line(devSupLine, devSupLabel)
        f_hide_dev_line(devResLine, devResLabel)

// ==============================================================================
// VISUAL UPDATE
// ==============================================================================
supportPower = 0.0
resistancePower = 0.0

if f_level_count() > 0
    for i = 0 to f_level_count() - 1 by 1
        kind = array.get(kindArr, i)
        m = array.get(mArr, i)
        b = array.get(bArr, i)
        baseCol = kind == 1 ? supportColor : resistanceColor
        nowLine = f_price(m, b, bar_index)

        liveSrc = touchSource == 'Bodies' ? kind == 1 ? math.min(open, close) : math.max(open, close) : kind == 1 ? low : high
        liveTouch = math.abs(liveSrc - nowLine) <= atrAdaptive * touchATR
        if processNow and liveTouch
            array.set(lastTouchArr, i, bar_index)

        eq = f_effective_q(i)
        sideRank = f_side_rank(i)
        spacingOk = f_spacing_ok(i)
        distATR = math.abs(close - nowLine) / atrAdaptive

        brokenSup = kind == 1 and close < nowLine - atrAdaptive * 0.80
        brokenRes = kind == -1 and close > nowLine + atrAdaptive * 0.80

        allowSide = kind == 1 ? sideRank <= effectiveSupports : sideRank <= effectiveResistances
        visible = showConfirmedLines and allowSide and spacingOk and eq >= visibleQualityFloor and distATR <= maxVisibleDistanceATR
        visible := visible and not(hideBrokenSupport and brokenSup)
        visible := visible and not(hideBrokenResistance and brokenRes)

        x1Base = array.get(a1BarArr, i)
        x1 = math.max(0, x1Base)
        x2 = bar_index + lineForwardBars
        y1 = f_tick(f_price(m, b, x1))
        y2 = f_tick(f_price(m, b, x2))

        localPower = visible and distATR <= 3.0 ? eq / 100.0 * (1.0 - distATR / 3.0) : 0.0
        if kind == 1
            supportPower += localPower
        else
            resistancePower += localPower

        ch = atrAdaptive * channelWidthATR
        midColor = visible ? color.new(baseCol, confirmedLineTransparency) : color.new(baseCol, 100)
        chColor = visible and effectiveShowChannels ? color.new(baseCol, channelTransparency) : color.new(baseCol, 100)

        line.set_xy1(array.get(midLines, i), x1, y1)
        line.set_xy2(array.get(midLines, i), x2, y2)
        line.set_extend(array.get(midLines, i), f_extend_mode())
        line.set_color(array.get(midLines, i), midColor)
        line.set_width(array.get(midLines, i), f_line_width(eq, array.get(clusterArr, i)))
        line.set_style(array.get(midLines, i), f_line_style(eq))

        line.set_xy1(array.get(upperLines, i), x1, y1 + ch)
        line.set_xy2(array.get(upperLines, i), x2, y2 + ch)
        line.set_extend(array.get(upperLines, i), f_extend_mode())
        line.set_color(array.get(upperLines, i), chColor)

        line.set_xy1(array.get(lowerLines, i), x1, y1 - ch)
        line.set_xy2(array.get(lowerLines, i), x2, y2 - ch)
        line.set_extend(array.get(lowerLines, i), f_extend_mode())
        line.set_color(array.get(lowerLines, i), chColor)

        labelOffset = atrAdaptive * labelStackATR * float(math.min(sideRank - 1, 6)) * (kind == 1 ? 1.0 : -1.0)
        yLabel = y2 + labelOffset
        geomName = f_geometry_name(kind, m)
        txt = (kind == 1 ? 'S' : 'R') + str.tostring(sideRank) + ' ' + str.tostring(eq, '#.#') + '%'

        tip = 'Type: ' + (kind == 1 ? 'Support' : 'Resistance')
        tip += '\nGeometry: ' + geomName
        tip += '\nSlope Direction: ' + f_dir_text(f_slope_dir(m, atrAdaptive))
        tip += '\nEffective Quality: ' + str.tostring(eq, '#.#') + '% (' + f_quality_text(eq) + ')'
        tip += '\nRaw Quality: ' + str.tostring(array.get(qArr, i), '#.#') + '%'
        tip += '\nCandle Respect: ' + str.tostring(array.get(respectArr, i) * 100.0, '#.#') + '%'
        tip += '\nDisplay Rank: ' + str.tostring(sideRank)
        tip += '\nTouch Clusters: ' + str.tostring(array.get(clusterArr, i))
        tip += '\nTouches: ' + str.tostring(array.get(touchArr, i))
        tip += '\nFit Score: ' + str.tostring(array.get(fitArr, i) * 100.0, '#.#') + '%'
        tip += '\nLine Price: ' + str.tostring(f_tick(nowLine))
        tip += '\nDistance: ' + str.tostring(distATR, '#.##') + ' ATR'
        tip += '\nSource: ' + array.get(srcArr, i)

        label.set_xy(array.get(tags, i), x2, yLabel)
        label.set_text(array.get(tags, i), visible and effectiveShowLineLabels ? txt : '')
        label.set_color(array.get(tags, i), visible and effectiveShowLineLabels ? color.new(baseCol, lineLabelTransparency) : color.new(baseCol, 100))
        label.set_textcolor(array.get(tags, i), visible and effectiveShowLineLabels ? color.white : color.new(color.white, 100))
        label.set_style(array.get(tags, i), kind == 1 ? label.style_label_up : label.style_label_down)
        label.set_size(array.get(tags, i), f_label_size())
        label.set_tooltip(array.get(tags, i), tip)

// ==============================================================================
// SIGNAL ENGINE
// ==============================================================================
var bool condLongBreak = false
var bool condShortBreak = false
var bool condLongRetest = false
var bool condShortRetest = false
var bool condLongReject = false
var bool condShortReject = false
var bool condFailedBreak = false
var string jsonAgg = ''
var int targetFireDir = 0
var float targetFireLine = na
var string targetFireName = ''

condLongBreak := false
condShortBreak := false
condLongRetest := false
condShortRetest := false
condLongReject := false
condShortReject := false
condFailedBreak := false
jsonAgg := ''
targetFireDir := 0
targetFireLine := na
targetFireName := ''

f_add_signal(y, txt, dir, q, eq, code) =>
    if signalDisplay != 'Off'
        col = dir == 1 ? supportColor : resistanceColor
        st = dir == 1 ? label.style_label_up : label.style_label_down
        isMarker = signalDisplay == 'Markers Only'
        visualText = isMarker ? code : txt
        visualSize = isMarker ? size.tiny : f_label_size()
        lab = label.new(bar_index, y, visualText, xloc = xloc.bar_index, style = st, color = color.new(col, signalMarkerTransparency), textcolor = color.white, size = visualSize)
        label.set_tooltip(lab, txt + '\nRaw Quality: ' + str.tostring(q, '#.#') + '%\nEffective Quality: ' + str.tostring(eq, '#.#') + '%')
        array.push(signalLabels, lab)
        limit = signalDisplay == 'Full Historical' ? maxSignalLabels : maxVisibleSignalEvents
        while array.size(signalLabels) > limit
            old = array.shift(signalLabels)
            label.delete(old)
    true

f_json(eventName, q, eq, dirText, linePrice) =>
    '{"event":"' + eventName + '","q":' + str.tostring(q, '#.#') + ',"eq":' + str.tostring(eq, '#.#') + ',"dir":"' + dirText + '","line":' + str.tostring(f_tick(linePrice)) + ',"close":' + str.tostring(close) + '}'

if enableSignals and processNow and f_level_count() > 0
    for i = 0 to f_level_count() - 1 by 1
        kind = array.get(kindArr, i)
        eq = f_effective_q(i)
        sideRank = f_side_rank(i)
        q = array.get(qArr, i)

        canSignal = sideRank <= signalTopN and q >= signalRawFloor and eq >= signalEffectiveFloor and bar_index - array.get(lastSignalArr, i) > signalCooldown

        m = array.get(mArr, i)
        b = array.get(bArr, i)
        nowLine = f_price(m, b, bar_index)
        prevLine = f_price(m, b, bar_index - 1)

        breakTol = atrAdaptive * breakoutATR
        retestTol = atrAdaptive * retestATR
        rejectTol = atrAdaptive * rejectionATR

        longBreak = canSignal and kind == -1 and close > nowLine + breakTol and close[1] <= prevLine + breakTol and f_body_break_ok(1, nowLine, breakTol) and f_signal_filter(1)
        shortBreak = canSignal and kind == 1 and close < nowLine - breakTol and close[1] >= prevLine - breakTol and f_body_break_ok(-1, nowLine, breakTol) and f_signal_filter(-1)

        if longBreak
            condLongBreak := true
            array.set(lastBreakBarArr, i, bar_index)
            array.set(lastBreakDirArr, i, 1)
            array.set(lastSignalArr, i, bar_index)
            f_add_signal(low - atrAdaptive * 0.35, 'LONG BREAK', 1, q, eq, 'LB')
            jsonAgg += (jsonAgg == '' ? '' : ',') + f_json('long_break', q, eq, 'long', nowLine)
            targetFireDir := 1
            targetFireLine := nowLine
            targetFireName := 'LONG BREAK'

        if shortBreak
            condShortBreak := true
            array.set(lastBreakBarArr, i, bar_index)
            array.set(lastBreakDirArr, i, -1)
            array.set(lastSignalArr, i, bar_index)
            f_add_signal(high + atrAdaptive * 0.35, 'SHORT BREAK', -1, q, eq, 'SB')
            jsonAgg += (jsonAgg == '' ? '' : ',') + f_json('short_break', q, eq, 'short', nowLine)
            targetFireDir := -1
            targetFireLine := nowLine
            targetFireName := 'SHORT BREAK'

        dir = array.get(lastBreakDirArr, i)
        boBar = array.get(lastBreakBarArr, i)
        inRetestWindow = dir != 0 and boBar > 0 and bar_index > boBar and bar_index - boBar <= retestWindow
        canRetest = inRetestWindow and bar_index - array.get(lastSignalArr, i) > signalCooldown and eq >= signalEffectiveFloor

        longRetest = canRetest and dir == 1 and kind == -1 and low <= nowLine + retestTol and close > nowLine and f_signal_filter(1)
        shortRetest = canRetest and dir == -1 and kind == 1 and high >= nowLine - retestTol and close < nowLine and f_signal_filter(-1)

        if longRetest
            condLongRetest := true
            array.set(lastSignalArr, i, bar_index)
            array.set(lastBreakDirArr, i, 0)
            f_add_signal(low - atrAdaptive * 0.25, 'LONG RETEST', 1, q, eq, 'LR')
            jsonAgg += (jsonAgg == '' ? '' : ',') + f_json('long_retest', q, eq, 'long', nowLine)
            if targetSignalSource != 'Breakouts Only'
                targetFireDir := 1
                targetFireLine := nowLine
                targetFireName := 'LONG RETEST'

        if shortRetest
            condShortRetest := true
            array.set(lastSignalArr, i, bar_index)
            array.set(lastBreakDirArr, i, 0)
            f_add_signal(high + atrAdaptive * 0.25, 'SHORT RETEST', -1, q, eq, 'SR')
            jsonAgg += (jsonAgg == '' ? '' : ',') + f_json('short_retest', q, eq, 'short', nowLine)
            if targetSignalSource != 'Breakouts Only'
                targetFireDir := -1
                targetFireLine := nowLine
                targetFireName := 'SHORT RETEST'

        longReject = enableRejectionSignals and canSignal and kind == 1 and low <= nowLine + retestTol and close > nowLine + rejectTol and close > open and f_signal_filter(1)
        shortReject = enableRejectionSignals and canSignal and kind == -1 and high >= nowLine - retestTol and close < nowLine - rejectTol and close < open and f_signal_filter(-1)

        if longReject
            condLongReject := true
            array.set(lastSignalArr, i, bar_index)
            f_add_signal(low - atrAdaptive * 0.25, 'LONG REJECT', 1, q, eq, 'RJ')
            jsonAgg += (jsonAgg == '' ? '' : ',') + f_json('long_reject', q, eq, 'long', nowLine)
            if targetSignalSource == 'All Directional'
                targetFireDir := 1
                targetFireLine := nowLine
                targetFireName := 'LONG REJECT'

        if shortReject
            condShortReject := true
            array.set(lastSignalArr, i, bar_index)
            f_add_signal(high + atrAdaptive * 0.25, 'SHORT REJECT', -1, q, eq, 'RJ')
            jsonAgg += (jsonAgg == '' ? '' : ',') + f_json('short_reject', q, eq, 'short', nowLine)
            if targetSignalSource == 'All Directional'
                targetFireDir := -1
                targetFireLine := nowLine
                targetFireName := 'SHORT REJECT'

        failedLong = inRetestWindow and dir == 1 and close < nowLine - breakTol * 0.50
        failedShort = inRetestWindow and dir == -1 and close > nowLine + breakTol * 0.50

        if failedLong or failedShort
            condFailedBreak := true
            array.set(lastSignalArr, i, bar_index)
            array.set(lastBreakDirArr, i, 0)
            f_add_signal(failedLong ? high + atrAdaptive * 0.35 : low - atrAdaptive * 0.35, 'FAILED BREAK', failedLong ? -1 : 1, q, eq, 'FB')
            jsonAgg += (jsonAgg == '' ? '' : ',') + f_json('failed_break', q, eq, failedLong ? 'failed_long' : 'failed_short', nowLine)

if enableInlineAlerts and processNow and jsonAgg != ''
    alert('{"source":"Institutional Trendline v1","time":' + str.tostring(time) + ',"events":[' + jsonAgg + ']}', alert.freq_once_per_bar_close)

// ==============================================================================
// TARGET ENGINE
// ==============================================================================
if showTargets and processNow and targetFireDir != 0 and not na(targetFireLine) and (not targetActive or targetReplaceOnNewSignal)
    if not na(targetEntryLine)
        line.delete(targetEntryLine)
        targetEntryLine := na
    if not na(targetTPLine)
        line.delete(targetTPLine)
        targetTPLine := na
    if not na(targetSLLine)
        line.delete(targetSLLine)
        targetSLLine := na
    if not na(targetLab)
        label.delete(targetLab)
        targetLab := na

    [newEntry, newSL, newTP, newRisk] = f_calc_targets(targetFireDir, targetFireLine)

    targetActive := true
    targetDir := targetFireDir
    targetEntry := newEntry
    targetSL := newSL
    targetTP := newTP
    targetRisk := newRisk
    targetStatus := targetFireDir == 1 ? 'LONG ACTIVE' : 'SHORT ACTIVE'

    targetEntryLine := line.new(bar_index, targetEntry, bar_index + targetForwardBars, targetEntry, xloc = xloc.bar_index, extend = extend.none, color = color.new(targetEntryColor, targetEntryTransparency), width = targetRiskLineWidth, style = line.style_dotted)
    targetTPLine := line.new(bar_index, targetTP, bar_index + targetForwardBars, targetTP, xloc = xloc.bar_index, extend = extend.none, color = color.new(targetTPColor, targetTPTransparency), width = targetLineWidth, style = f_style_from_input(targetLineStyleInput))
    targetSLLine := line.new(bar_index, targetSL, bar_index + targetForwardBars, targetSL, xloc = xloc.bar_index, extend = extend.none, color = color.new(targetSLColor, targetSLTransparency), width = targetRiskLineWidth, style = f_style_from_input(targetLineStyleInput))

    targetText = targetFireName + '\nTP ' + str.tostring(targetTP) + '\nSL ' + str.tostring(targetSL) + '\nRR ' + str.tostring(targetRewardRisk, '#.##')
    targetLab := label.new(bar_index + targetForwardBars, targetTP, targetText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(targetTPColor, targetLabelTransparency), textcolor = color.white, size = f_label_size())

if showTargets and targetActive
    if not na(targetEntryLine)
        line.set_x2(targetEntryLine, bar_index + targetForwardBars)
    if not na(targetTPLine)
        line.set_x2(targetTPLine, bar_index + targetForwardBars)
    if not na(targetSLLine)
        line.set_x2(targetSLLine, bar_index + targetForwardBars)
    if not na(targetLab)
        label.set_x(targetLab, bar_index + targetForwardBars)
        label.set_y(targetLab, targetTP)

    tpHit = targetDir == 1 ? high >= targetTP : low <= targetTP
    slHit = targetStopByClose ? (targetDir == 1 ? close <= targetSL : close >= targetSL) : (targetDir == 1 ? low <= targetSL : high >= targetSL)

    if tpHit
        targetActive := false
        targetStatus := 'TP HIT'
        if not na(targetLab)
            label.set_color(targetLab, color.new(supportColor, targetLabelTransparency))
        if not na(targetTPLine)
            line.set_color(targetTPLine, color.new(supportColor, targetTPTransparency))
        if not na(targetSLLine)
            line.set_color(targetSLLine, color.new(neutralColor, 70))

    if slHit and not tpHit
        targetActive := false
        targetStatus := 'SL HIT'
        if not na(targetLab)
            label.set_color(targetLab, color.new(resistanceColor, targetLabelTransparency))
        if not na(targetSLLine)
            line.set_color(targetSLLine, color.new(resistanceColor, targetSLTransparency))
        if not na(targetTPLine)
            line.set_color(targetTPLine, color.new(neutralColor, 70))

if not showTargets
    if not na(targetEntryLine)
        line.delete(targetEntryLine)
        targetEntryLine := na
    if not na(targetTPLine)
        line.delete(targetTPLine)
        targetTPLine := na
    if not na(targetSLLine)
        line.delete(targetSLLine)
        targetSLLine := na
    if not na(targetLab)
        label.delete(targetLab)
        targetLab := na
    targetActive := false
    targetDir := 0
    targetEntry := na
    targetSL := na
    targetTP := na
    targetRisk := na
    targetStatus := 'OFF'

// ==============================================================================
// NEAREST SUPPORT / RESISTANCE + GEOMETRY CLASSIFICATION
// ==============================================================================
float nearestSupport = na
float nearestResistance = na
float nearestSupportQ = na
float nearestResistanceQ = na

float activeUpperPrice = na
float activeLowerPrice = na
float activeUpperSlope = na
float activeLowerSlope = na
float activeUpperScore = -1e10
float activeLowerScore = -1e10
string activeUpperName = '-'
string activeLowerName = '-'

if f_level_count() > 0
    for i = 0 to f_level_count() - 1 by 1
        eq = f_effective_q(i)
        kind = array.get(kindArr, i)
        m = array.get(mArr, i)
        b = array.get(bArr, i)
        v = f_price(m, b, bar_index)
        distATR = math.abs(close - v) / atrAdaptive
        score = f_display_score(i)
        geom = f_geometry_name(kind, m)

        if eq >= visibleQualityFloor and distATR <= maxVisibleDistanceATR
            if kind == 1 and v <= close
                if na(nearestSupport) or math.abs(close - v) < math.abs(close - nearestSupport)
                    nearestSupport := f_tick(v)
                    nearestSupportQ := eq

            if kind == -1 and v >= close
                if na(nearestResistance) or math.abs(close - v) < math.abs(close - nearestResistance)
                    nearestResistance := f_tick(v)
                    nearestResistanceQ := eq

            if kind == -1 and score > activeUpperScore
                activeUpperScore := score
                activeUpperPrice := f_tick(v)
                activeUpperSlope := m
                activeUpperName := geom

            if kind == 1 and score > activeLowerScore
                activeLowerScore := score
                activeLowerPrice := f_tick(v)
                activeLowerSlope := m
                activeLowerName := geom

upperDir = na(activeUpperSlope) ? 0 : f_slope_dir(activeUpperSlope, atrAdaptive)
lowerDir = na(activeLowerSlope) ? 0 : f_slope_dir(activeLowerSlope, atrAdaptive)

trendState = upperDir == 1 and lowerDir == 1 ? 'Uptrend' : upperDir == -1 and lowerDir == -1 ? 'Downtrend' : upperDir == 1 and lowerDir == -1 ? 'Diverging Triangle' : upperDir == -1 and lowerDir == 1 ? 'Converging Triangle' : upperDir == 0 and lowerDir == 0 ? 'Range' : upperDir == 1 and lowerDir == 0 ? 'Ascending Expansion' : upperDir == 0 and lowerDir == 1 ? 'Ascending Base' : upperDir == -1 and lowerDir == 0 ? 'Descending Cap' : upperDir == 0 and lowerDir == -1 ? 'Descending Expansion' : 'Neutral'

pSup = plot(showNearest ? nearestSupport : na, 'Nearest Dynamic Support', color = color.new(supportColor, nearestLineTransparency), linewidth = nearestLineWidth, style = plot.style_linebr)
pRes = plot(showNearest ? nearestResistance : na, 'Nearest Dynamic Resistance', color = color.new(resistanceColor, nearestLineTransparency), linewidth = nearestLineWidth, style = plot.style_linebr)
fill(pSup, pRes, color = showRangeFill ? color.new(premiumColor, 94) : na, title = 'Nearest Active Range')

if barstate.islast
    if showNearest and showNearestLabels and chartDensity != 'Minimal' and not na(nearestSupport)
        txtS = 'Nearest S ' + str.tostring(nearestSupport) + ' | ' + str.tostring(nearestSupportQ, '#') + '%'
        if na(nearestSupLabel)
            nearestSupLabel := label.new(bar_index + 3, nearestSupport, txtS, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(supportColor, nearestLabelTransparency), textcolor = color.white, size = f_label_size())
        else
            label.set_xy(nearestSupLabel, bar_index + 3, nearestSupport)
            label.set_text(nearestSupLabel, txtS)
            label.set_color(nearestSupLabel, color.new(supportColor, nearestLabelTransparency))
            label.set_textcolor(nearestSupLabel, color.white)
            label.set_style(nearestSupLabel, label.style_label_left)
            label.set_size(nearestSupLabel, f_label_size())
    else
        if not na(nearestSupLabel)
            label.set_text(nearestSupLabel, '')
            label.set_color(nearestSupLabel, color.new(supportColor, 100))
            label.set_textcolor(nearestSupLabel, color.new(color.white, 100))

    if showNearest and showNearestLabels and chartDensity != 'Minimal' and not na(nearestResistance)
        txtR = 'Nearest R ' + str.tostring(nearestResistance) + ' | ' + str.tostring(nearestResistanceQ, '#') + '%'
        if na(nearestResLabel)
            nearestResLabel := label.new(bar_index + 3, nearestResistance, txtR, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(resistanceColor, nearestLabelTransparency), textcolor = color.white, size = f_label_size())
        else
            label.set_xy(nearestResLabel, bar_index + 3, nearestResistance)
            label.set_text(nearestResLabel, txtR)
            label.set_color(nearestResLabel, color.new(resistanceColor, nearestLabelTransparency))
            label.set_textcolor(nearestResLabel, color.white)
            label.set_style(nearestResLabel, label.style_label_left)
            label.set_size(nearestResLabel, f_label_size())
    else
        if not na(nearestResLabel)
            label.set_text(nearestResLabel, '')
            label.set_color(nearestResLabel, color.new(resistanceColor, 100))
            label.set_textcolor(nearestResLabel, color.new(color.white, 100))

// ==============================================================================
// DASHBOARD + WATERMARK
// ==============================================================================
var table panel = table.new(f_panel_pos(panelPosition), 3, 14, bgcolor = color.new(color.black, 88), frame_color = color.new(color.gray, 78), frame_width = 1)
var table watermark = table.new(position.middle_center, 1, 1, border_width = 0)

f_best_q() =>
    best = 0.0
    n = f_level_count()
    if n > 0
        for i = 0 to n - 1 by 1
            best := math.max(best, f_effective_q(i))
    best

if barstate.islast
    if showTrendStateWatermark
        table.cell(watermark, 0, 0, trendState, text_color = color.new(premiumColor, watermarkTransparency), text_size = size.huge, bgcolor = color.new(color.black, 100))
    else
        table.clear(watermark, 0, 0, 0, 0)

    if showPanel
        active = f_level_count()
        bestQ = f_best_q()
        pressure = supportPower > resistancePower ? 'SUPPORT' : resistancePower > supportPower ? 'RESIST' : 'BALANCED'

        table.cell(panel, 0, 0, 'TRENDLINE', bgcolor = color.new(premiumColor, 58), text_color = color.white, text_size = size.small)
        table.cell(panel, 1, 0, 'V1', bgcolor = color.new(premiumColor, 58), text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 0, precisionMode, bgcolor = color.new(premiumColor, 58), text_color = color.white, text_size = size.small)

        table.cell(panel, 0, 1, 'Confirmed', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 1, str.tostring(active), text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 1, active > 0 ? 'ACTIVE' : 'WARMUP', text_color = active > 0 ? supportColor : premiumColor, text_size = size.small)

        table.cell(panel, 0, 2, 'Best Quality', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 2, str.tostring(bestQ, '#.#') + '%', text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 2, f_quality_text(bestQ), text_color = bestQ >= 65 ? supportColor : premiumColor, text_size = size.small)

        table.cell(panel, 0, 3, 'Market', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 3, isTrending ? 'TREND' : 'RANGE', text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 3, 'ADX ' + str.tostring(adx, '#'), text_color = isTrending ? supportColor : neutralColor, text_size = size.small)

        table.cell(panel, 0, 4, 'MTF', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 4, 'B ' + str.tostring(htfBullCount) + '/2 R ' + str.tostring(htfBearCount) + '/2', text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 4, htfBullCount > htfBearCount ? 'BULL' : htfBearCount > htfBullCount ? 'BEAR' : 'NEUTRAL', text_color = htfBullCount > htfBearCount ? supportColor : htfBearCount > htfBullCount ? resistanceColor : neutralColor, text_size = size.small)

        table.cell(panel, 0, 5, 'Support', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 5, na(nearestSupport) ? '-' : str.tostring(nearestSupport), text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 5, na(nearestSupportQ) ? '-' : str.tostring(nearestSupportQ, '#') + '%', text_color = supportColor, text_size = size.small)

        table.cell(panel, 0, 6, 'Resistance', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 6, na(nearestResistance) ? '-' : str.tostring(nearestResistance), text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 6, na(nearestResistanceQ) ? '-' : str.tostring(nearestResistanceQ, '#') + '%', text_color = resistanceColor, text_size = size.small)

        table.cell(panel, 0, 7, 'Geometry', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 7, trendState, text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 7, f_dir_text(upperDir) + '/' + f_dir_text(lowerDir), text_color = premiumColor, text_size = size.small)

        table.cell(panel, 0, 8, 'Upper Line', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 8, activeUpperName, text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 8, na(activeUpperPrice) ? '-' : str.tostring(activeUpperPrice), text_color = resistanceColor, text_size = size.small)

        table.cell(panel, 0, 9, 'Lower Line', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 9, activeLowerName, text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 9, na(activeLowerPrice) ? '-' : str.tostring(activeLowerPrice), text_color = supportColor, text_size = size.small)

        table.cell(panel, 0, 10, 'Pressure', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 10, pressure, text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 10, str.tostring(math.abs(supportPower - resistancePower), '#.##'), text_color = supportPower > resistancePower ? supportColor : resistancePower > supportPower ? resistanceColor : neutralColor, text_size = size.small)

        table.cell(panel, 0, 11, 'Target', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 11, targetActive ? targetDir == 1 ? 'LONG' : 'SHORT' : targetStatus, text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 11, showTargets ? targetMode : 'OFF', text_color = targetActive ? premiumColor : neutralColor, text_size = size.small)

        table.cell(panel, 0, 12, 'TP / SL', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 12, na(targetTP) ? '-' : str.tostring(targetTP), text_color = premiumColor, text_size = size.small)
        table.cell(panel, 2, 12, na(targetSL) ? '-' : str.tostring(targetSL), text_color = resistanceColor, text_size = size.small)

        table.cell(panel, 0, 13, 'Visuals', text_color = color.gray, text_size = size.small)
        table.cell(panel, 1, 13, chartDensity, text_color = color.white, text_size = size.small)
        table.cell(panel, 2, 13, signalDisplay, text_color = premiumColor, text_size = size.small)
    else
        table.clear(panel, 0, 0, 2, 13)

// ==============================================================================
// ALERT CONDITIONS
// ==============================================================================
alertcondition(enableAlertConditions and condLongBreak, title = 'Long Breakout', message = 'Institutional Trendline v1: Long breakout confirmed.')
alertcondition(enableAlertConditions and condShortBreak, title = 'Short Breakdown', message = 'Institutional Trendline v1: Short breakdown confirmed.')
alertcondition(enableAlertConditions and condLongRetest, title = 'Long Retest', message = 'Institutional Trendline v1: Long retest confirmed.')
alertcondition(enableAlertConditions and condShortRetest, title = 'Short Retest', message = 'Institutional Trendline v1: Short retest confirmed.')
alertcondition(enableAlertConditions and condLongReject, title = 'Long Rejection', message = 'Institutional Trendline v1: Support rejection confirmed.')
alertcondition(enableAlertConditions and condShortReject, title = 'Short Rejection', message = 'Institutional Trendline v1: Resistance rejection confirmed.')
alertcondition(enableAlertConditions and condFailedBreak, title = 'Failed Break', message = 'Institutional Trendline v1: Failed breakout detected.')
````
