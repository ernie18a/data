# Ask Dr. Alex AI

- url: https://www.tradingview.com/script/HuWtsbpr-Ask-Dr-Alex-AI/
- type: indicator
- pine_id: PUB;4b37bf76490a474cb9048f29c623c971
- version: 11.0

## Description

Ask Dr. Alex AI — Interactive Chart Intelligence for TradingView
Ask Dr. Alex AI is an interactive chart intelligence indicator built to help traders understand what the chart is saying before making a decision. Instead of only printing a simple buy or sell label, Ask Dr. Alex AI lets the user select a question from a built-in menu and then reveals the specific chart evidence behind the answer.

This indicator is designed as a guided market assistant for traders who want clearer context around support, resistance, patterns, momentum, trend pressure, forecast bias, and trade planning.

What Makes Ask Dr. Alex AI Different
Most indicators only show signals.

Ask Dr. Alex AI answers questions.

Users can select from guided questions such as:

Is this safe to trade right now?
Am I buying from support, selling from resistance, or chasing price?
What pattern is active?
What does the next candle / 10C forecast suggest?
What is the entry, stop loss, and take-profit plan?
ALL — Show Everything
Deep Scan Mode
When a question is selected, the indicator highlights the relevant chart areas and summarizes what it sees using the Dr. Alex AI answer panel.

Core Features
Interactive Question Menu
Choose a question and the indicator reveals only the relevant chart evidence.

Dr. Alex AI Answer Panel
Provides a plain-English summary of the current market condition.

Deep Scan Mode
Unlocks deeper diagnostic checks such as:

Trend Strength
MTF Agreement
Support Bounce Check
Resistance Rejection
Pattern Quality
Forecast Conflict
Ribbon Conflict
Entry Quality
Risk / Reward
Invalidation Point
Fakeout Risk
Wilson Tangent
Full Diagnostic
Support / Resistance Intelligence
Displays major support and resistance zones, higher-timeframe levels, and whether price is reacting from a meaningful area.

Pattern Awareness
Detects and explains major active patterns such as doji at support, hammer at support, double bottom, engulfing candles, marubozu candles, breakout retests, traps, and continuation patterns.

Respect Support Bounce Mode
When price touches major support and a bullish rejection pattern appears, the system can shift from hard bearish continuation into Support Bounce Watch / Bull Watch instead of blindly forecasting into support.

Next-Candle Bias Ribbon
A five-state visual ribbon helps summarize the projected next-candle condition:

Green = Bullish
Blue = Bull Watch
Gray = Neutral
Orange = Bear Watch
Red = Bearish
10-Candle Forecast View
Shows a forward projection path based on confidence, pattern context, support/resistance, trend pressure, and active sentiment.

Trade Plan Panel
When a setup is active, the indicator can display:

Entry range
Stop loss
TP1
TP2
Risk/reward model
Setup status
Confidence and Rank Engine
Uses a multi-factor scoring system to compare bullish and bearish pressure across trend, momentum, structure, volatility, MTF alignment, candle behavior, and ribbon state.

Machine-Learning-Inspired Scoring Logic
Ask Dr. Alex AI uses adaptive, weighted, machine-learning-inspired decision logic to evaluate chart conditions and adjust the way it interprets support bounces, forecast conflicts, momentum shifts, and pattern quality. It is designed to behave like an intelligent diagnostic layer, not just a static signal generator.

How to Use
Add the indicator to your chart.
Choose a question from the Ask Dr. Alex AI menu.
Review the highlighted chart evidence.
Read the Dr. Alex AI answer panel.
Use Deep Scan Mode when you want a more detailed diagnostic breakdown.
Use ALL — Show Everything when you want the full visual system displayed at once.
Best Use Case
Ask Dr. Alex AI is best used as a decision-support and educational chart assistant. It is built to help traders slow down, identify context, avoid chasing price, respect support/resistance, and understand why a setup is active, weak, conflicted, or invalidated.

It is especially useful for traders who want the chart to answer questions such as:

“Is this actually a trade, or am I forcing it?”

“Is price bouncing from support or breaking down?”

“Why is the forecast bullish if the trend is bearish?”

“Why is the signal waiting?”

“What must happen before this setup becomes valid?”

Important Disclaimer
Ask Dr. Alex AI is for educational and informational purposes only. It does not guarantee profits, predict the future with certainty, or replace personal judgment, risk management, or professional financial advice. Trading involves risk, and users are responsible for their own trading decisions.

## Source Code

````pine
//@version=6
indicator("Ask Dr. Alex AI", shorttitle="Ask Dr. Alex AI", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

//====================================================
// ASK DR. ALEX AI v6.6D DOT STATE LOCK + DOT FOCUS ALERTS
// Fixes:
// - Removed visible "35" text from star labels, panel wording, and status text so it cannot be mistaken for pips. Stars now mark scout confirmation only.
// - Reduced unique request.security calls so TradingView can load/update chart
// - Dashboard no longer offers Bottom Left, avoiding conflict with trade-plan panel
// - Removed confusing "exit" wording from status/sentiment guidance
// - Reversal detection checks pattern names correctly
// - Pane Labels / candle score clutter now defaults OFF
// - Bottom ribbon now shows projected next-candle color after support, resistance, patterns, MTF, confidence, and ribbon logic
// - Indicator status/name area cleaned so it does not show extra ribbon plot numbers
// - Added Respect Support Bounce Mode so doji/hammer/double-bottom/rejection at major support neutralizes bearish ribbon/forecast unless support breaks
// - Restored global closed-candle evaluation for execution data, MACD, DMI, fractal RSI/pivots, zones, and forecast base
// - Rebuilt Ask Dr. Alex AI as checkbox-style compact answers, not a dropdown and not giant panels
// - Show All is now compact and excludes label panels/full dashboard by design
// - Rebuilt panels across the bottom: Active Signal left, Ask Dr. Alex center, Ask Dr. Alex engine compact right
// - Ribbon no longer scrolls under the signal panel; it is summarized inside the bottom center block
// - Locked signal arrows to confirmed bars only and plots them back on the closed candle that generated the signal
// - Added closed 5M sentiment compliance so BUY/SELL arrows cannot fire against the 5M closed direction
// - Built for clean operation on the 30M chart with execTf defaulting to 30
// - Added scout confirmation: normal Ask Dr. Alex 30M logic plus closed 5M scout confirmation
// - Split candle confidence numbers from high-confidence pane labels
// - High-confidence pane labels print only on elite candles, default every 10 bars
// - Added scout confirmation stars/dots without using label objects
// - Restored public TradingView indicator name to Ask Dr. Alex AI
// - Forecast candle-box body drawing section removed so empty squares cannot appear near the price scale
// - All visible plot markers and input arguments are hidden from the TradingView status line
// - Bottom ribbon now floats above the lower panel instead of anchoring behind it
// - Restored the 5-color projected ribbon scheme: STRONG BEAR red, BEAR orange, NEUTRAL gray, BULL blue, STRONG BULL green
// - v6.5K: Right classic dashboard panel defaults HIDDEN again; bottom panel left untouched
// - v6.5K: High-confidence label frequency preserved at every 10 bars
// - v6.5K: Star labels restored as star-only markers, no 35 text
// - Historical label/pattern panels now default ON again while the full MTF dashboard remains separately controlled
// - Ask Dr. Alex AI no longer displays legacy brand labels in its UI/alerts
// - v6.5M: Split pattern labels away from the classic MTF dashboard control; dashboard remains OFF by default.
// - v6.5M: Added clean 4-level marker hierarchy: dot = strong move, star = scout confirmation, arrow = full setup, diamond = elite/all-E setup.
// - v6.5M: Strong-move dots are high-threshold and cooldown-controlled so weak markers do not clutter the chart.
// - v6.5M: Scout watch dots remain OFF by default; only confirmed scout stars print by default.
// - v6.6: Added dedicated BUY DOT / SELL DOT alertconditions so dot signals appear in TradingView alerts.
// - v6.6: Added Dot Focus Mode to show dot signals without arrow/star/diamond clutter.
// - v6.6: Added top-center projected ribbon anchor.
// - v6.6: Added dot-candle Buy Stop / Sell Stop and SL lines using the dot candle wick extremes.
// - v6.6: Dot stop plan expires visually after 2 bars by default and uses a pip SL buffer by default.
// - v6.6A: Dot SL buffer now defaults to 10 pips and remains adjustable in settings.
// - v6.6B: Dot plan entry/SL now anchor to the visible dot candle on the chart, and the dot controls are visible in Inputs.
// - v6.6A: Dot SL labels no longer reveal the buffer amount on the public chart; labels show SL only.
// - v6.6A: Dot plan labels are pushed to the right edge of the plan line so candles do not hide them.
// - v6.6D: Dot logic only update. Confirmed BUY/SELL dots are green/red, caution dots are yellow, invalid dots are gray.
// - v6.6D: Alerts now fire only on confirmed green/red dot appearances through Dot Focus Alert / BUY DOT / SELL DOT.
// - v6.6D: Removed dot stop-hit alertconditions so alerts do not wait for entry/SL activity after the dot appears.
// - v6.6D: Dot signals are no longer hidden just because a star/arrow/diamond also exists; dot remains the primary high-value signal.
// - v6.6D: Dot Focus Mode hides the 10-candle forecast so active dot Entry/SL/TP stays clean.
// - v6.6D: Confirmed dot plans now include TP and default to active-only, not historical clutter.
//====================================================

//==============================
// CORE SETTINGS
//==============================
execTf              = input.timeframe("30", "Execution / scanner timeframe", display=display.none)
fastLen             = input.int(9, "Fast EMA period", minval=1, display=display.none)
slowLen             = input.int(21, "Slow EMA period", minval=2, display=display.none)
midLen              = input.int(50, "Middle EMA period", minval=5, display=display.none)
longLen             = input.int(200, "Long EMA period", minval=20, display=display.none)
hullLen             = input.int(34, "Hull MA period", minval=2, display=display.none)
atrLen              = input.int(14, "ATR period", minval=1, display=display.none)

mtfRequired         = input.int(3, "MTF timeframes required to agree", minval=2, maxval=4, display=display.none)
minConfidence       = input.int(45, "Minimum confidence score", minval=0, maxval=100, display=display.none)
minRank             = input.int(4, "Minimum rank", minval=0, maxval=10, display=display.none)
strongConfidence    = input.int(80, "STRONG signal confidence", minval=50, maxval=100, display=display.none)
strongRank          = input.int(8, "STRONG signal rank", minval=4, maxval=10, display=display.none)
earlyConfidence     = input.int(65, "EARLY signal confidence", minval=35, maxval=100, display=display.none)

structureLookback   = input.int(20, "Structure lookback bars", minval=5, display=display.none)
minRetraceDepth     = input.float(0.10, "Minimum retrace/depth ATR", minval=0.0, step=0.05, display=display.none)
structureAtr        = input.float(0.50, "Structure clearance ATR", minval=0.0, step=0.05, display=display.none)

//==============================
// FRACTAL RIBBON SETTINGS
//==============================
useFractalRibbonGate = input.bool(true, "Use built-in Fractal Ribbon verification", display=display.none)
frFastLen            = input.int(10, "Fractal Ribbon fast length", minval=1, display=display.none)
frSlowLen            = input.int(21, "Fractal Ribbon slow length", minval=2, display=display.none)
frUpper              = input.float(75.0, "Fractal Ribbon upper guide", minval=1, maxval=100, display=display.none)
frLower              = input.float(25.0, "Fractal Ribbon lower guide", minval=0, maxval=99, display=display.none)
frPivotLeft          = input.int(1, "Fractal pivot left bars", minval=1, maxval=10, display=display.none)
frPivotRight         = input.int(1, "Fractal pivot right bars", minval=1, maxval=10, display=display.none)

//==============================
// ZONE SETTINGS
//==============================
showZones            = input.bool(true, "Show Buy/Sell support-resistance zones", display=display.none)
zoneTf               = input.timeframe("60", "Zone timeframe", display=display.none)
zoneLookback         = input.int(60, "Zone lookback", minval=10, maxval=300, display=display.none)
zoneAtrMult          = input.float(0.45, "Zone thickness ATR", minval=0.05, step=0.05, display=display.none)
zonePastBars         = input.int(80, "Zone starts bars back", minval=10, maxval=500, display=display.none)
zoneFutureBars       = input.int(40, "Zone projects bars forward", minval=5, maxval=500, display=display.none)
zoneTransparency     = input.int(82, "Zone transparency", minval=0, maxval=100, display=display.none)
requireZoneExit      = input.bool(true, "Signals only after clean zone move", display=display.none)
zoneExitBars         = input.int(5, "Bars after zone touch allowed", minval=1, maxval=50, display=display.none)
postRetestBars       = input.int(20, "Post-retest lookback bars", minval=2, maxval=100, display=display.none)
retestToleranceAtr   = input.float(0.25, "Retest tolerance ATR", minval=0.0, step=0.05, display=display.none)
strongRequiresRetest = input.bool(true, "STRONG signals require post-retest", display=display.none)

//==============================
// HTF SUPPORT / RESISTANCE SHORT LINES
//==============================
showHTFSRShortLines  = input.bool(true, "Show 4H/D/W/M support-resistance short lines", display=display.none)
htfShortLineLen      = input.int(12, "HTF short line length (bars)", minval=2, maxval=100, display=display.none)
htfShortLineWidth    = input.int(2, "HTF short line width", minval=1, maxval=4, display=display.none)

//==============================
// UNIQUE SWING TRENDLINES
//==============================
showUniqueTrendlines = input.bool(true, "Show unique swing trendlines", display=display.none)
swingTrendLeft       = input.int(3, "Swing trendline left bars", minval=1, maxval=20, display=display.none)
swingTrendRight      = input.int(3, "Swing trendline right bars", minval=1, maxval=20, display=display.none)
swingTrendWidth      = input.int(2, "Swing trendline width", minval=1, maxval=4, display=display.none)

//==============================
// FAKEOUT / REPEAT CONTROL
//==============================
useClosedTf          = true  // LOCKED: all execution logic uses the last closed execution candle only
enable35Logic        = input.bool(true, "Enable 30M + closed 5M scout confirmation", group="SIGNAL SAFETY", display=display.none)
apply35OnlyOn30m     = input.bool(true, "Apply scout confirmation only on 30M chart", group="SIGNAL SAFETY", display=display.none)
requireConfirmBody   = input.bool(true, "Require candle body confirmation", display=display.none)
oneSignalPerTrend    = input.bool(true, "Block repeat arrows until trend changes/upgrades", display=display.none)
cooldownBars         = input.int(6, "Minimum bars between repeat signals", minval=0, maxval=100, display=display.none)

showEarlySignals     = input.bool(true, "Show EARLY BUY / EARLY SELL", display=display.none)
showStrongSignals    = input.bool(true, "Show STRONG BUY / STRONG SELL", display=display.none)
showNormalSignals    = input.bool(true, "Show normal BUY / SELL", display=display.none)
showHistorical       = input.bool(true, "Show historical signal labels", display=display.none)

//==============================
// CANDLE CONFIDENCE / HIGH-CONFIDENCE LABEL SETTINGS
// Confidence numbers and pane labels are intentionally separate layers:
// - confidence numbers = small teaching numbers
// - pane labels = only elite/high-confidence candles
//==============================
showCandleConfidenceNumbers = input.bool(true, "Show candle confidence numbers", group="CANDLE TEACHING", display=display.none)
candleScoreMode             = input.string("Confidence", "Candle number type", options=["Confidence", "Rank", "Both"], group="CANDLE TEACHING", display=display.none)
confidenceNumberEveryBars   = input.int(1, "Confidence number spacing", minval=1, maxval=20, group="CANDLE TEACHING", display=display.none)
confidenceNumberBarsBack    = input.int(300, "Confidence numbers bars back", minval=25, maxval=500, group="CANDLE TEACHING", display=display.none)
scoreSide                   = input.string("Winning Side", "Candle score side", options=["Winning Side", "Buy Only", "Sell Only"], group="CANDLE TEACHING", display=display.none)
scoreLabelSizeOpt           = input.string("Tiny", "Candle score size", options=["Tiny", "Small", "Normal"], group="CANDLE TEACHING", display=display.none)
scoreOffsetAtr              = input.float(0.10, "Candle score distance ATR", minval=0.0, step=0.05, group="CANDLE TEACHING", display=display.none)
scoreLocationOpt            = input.string("Auto", "Candle score location", options=["Auto", "Above Candle", "Below Candle"], group="CANDLE TEACHING", display=display.none)

showHighConfidencePaneLabels = input.bool(true, "Show high-confidence pane labels", group="HIGH-CONFIDENCE LABELS", display=display.none)
highConfidenceThreshold      = input.int(80, "High-confidence label threshold", minval=50, maxval=100, group="HIGH-CONFIDENCE LABELS", display=display.none)
highConfidenceMinRank        = input.int(8, "High-confidence minimum rank", minval=1, maxval=10, group="HIGH-CONFIDENCE LABELS", display=display.none)
highConfidenceLabelEveryBars = input.int(10, "High-confidence pane label frequency (bars)", minval=1, maxval=50, group="HIGH-CONFIDENCE LABELS", display=display.none)
require35ForPaneLabels       = input.bool(true, "Pane labels require scout confirmation when active", group="HIGH-CONFIDENCE LABELS", display=display.none)
show35LogicStars             = input.bool(true, "Show scout confirmed stars", group="SCOUT MARKERS", display=display.none)
show35WatchDots              = input.bool(false, "Show scout watch dots", group="SCOUT MARKERS", display=display.none)

//==============================
// CLEAN MARKER HIERARCHY
// Dot = strong move only. Star = scout confirmed. Arrow = full setup. Diamond = elite/all-E setup.
// Weak markers stay filtered by default to avoid chart clutter.
//==============================
showStrongMoveDots          = input.bool(true, "Show strong-move dots", group="MARKER HIERARCHY")
focusDotSignalsOnly         = input.bool(false, "DOT FOCUS MODE: show only dot signals", group="MARKER HIERARCHY")
showDotCautionStates        = input.bool(true, "Show yellow/gray dot caution states", group="MARKER HIERARCHY")
blockRepeatSignalsWhileActive = input.bool(true, "Block repeat signals while same signal is active", group="MARKER HIERARCHY")
showDotPendingLines         = input.bool(true, "Show dot candle Buy Stop / Sell Stop lines", group="MARKER HIERARCHY")
dotPlanActiveOnly           = input.bool(true, "Dot plan active only (hide old plans)", group="MARKER HIERARCHY")
dotEntryMaxBars             = input.int(2, "Dot stop entry expires after bars", minval=1, maxval=10, group="MARKER HIERARCHY")
dotStopLossBufferPips       = input.float(10.0, "Dot SL buffer beyond opposite wick tip (pips)", minval=0.0, step=0.5, group="MARKER HIERARCHY")
dotTakeProfitRR             = input.float(1.00, "Dot TP risk/reward", minval=0.10, step=0.10, group="MARKER HIERARCHY")
maxDotPlansKept             = input.int(60, "Maximum dot stop plans kept", minval=10, maxval=120, group="MARKER HIERARCHY")
strongMoveMinConfidence     = input.int(75, "Strong-move dot minimum confidence", minval=50, maxval=100, group="MARKER HIERARCHY", display=display.none)
strongMoveMinRank           = input.int(7, "Strong-move dot minimum rank", minval=1, maxval=10, group="MARKER HIERARCHY", display=display.none)
strongMoveBodyAtr           = input.float(0.70, "Strong-move dot body ATR", minval=0.10, step=0.05, group="MARKER HIERARCHY", display=display.none)
strongMoveMinPatternScore   = input.int(6, "Strong-move dot pattern score", minval=0, maxval=10, group="MARKER HIERARCHY", display=display.none)
strongMoveDotCooldownBars   = input.int(8, "Strong-move dot cooldown bars", minval=1, maxval=100, group="MARKER HIERARCHY", display=display.none)
showEliteDiamonds           = input.bool(true, "Show elite/all-E diamonds", group="MARKER HIERARCHY", display=display.none)
eliteMinConfidence          = input.int(85, "Elite diamond minimum confidence", minval=70, maxval=100, group="MARKER HIERARCHY", display=display.none)
eliteMinRank                = input.int(8, "Elite diamond minimum rank", minval=1, maxval=10, group="MARKER HIERARCHY", display=display.none)
eliteMinPatternScore        = input.int(8, "Elite diamond minimum pattern score", minval=0, maxval=10, group="MARKER HIERARCHY", display=display.none)

//==============================
// ASK DR. ALEX AI / PANEL CONTROL
//==============================
showAskAI            = input.bool(true, "Show Ask Dr. Alex AI compact panel", group="ASK DR. ALEX AI", display=display.none)
showAllCompact       = input.bool(false, "Show All (Excluding Label Panels)", group="ASK DR. ALEX AI", display=display.none)
askSafeTrade         = input.bool(true, "Ask: Is this safe to trade?", group="ASK DR. ALEX AI", display=display.none)
askSupportResistance = input.bool(true, "Ask: Support / Resistance / Chasing?", group="ASK DR. ALEX AI", display=display.none)
askPattern           = input.bool(false, "Ask: Active pattern?", group="ASK DR. ALEX AI", display=display.none)
askForecast          = input.bool(true, "Ask: Next candle / 10C forecast?", group="ASK DR. ALEX AI", display=display.none)
askTradePlan         = input.bool(true, "Ask: Entry / SL / TP plan?", group="ASK DR. ALEX AI", display=display.none)

// Label panels/full dashboard are separate and are never forced by Show All.
showPatternLabels    = input.bool(true, "Show historical pattern labels", group="PATTERN LABELS", display=display.none)
showDashboard        = input.bool(false, "Show classic MTF dashboard / right panel", group="PANELS / CLUTTER CONTROL", display=display.none)
showAlexEngineBlock    = input.bool(true, "Show Ask Dr. Alex engine bottom block", group="PANELS / CLUTTER CONTROL", display=display.none)
dashPositionOpt      = input.string("Top Right", "Dashboard position", options=["Top Right", "Top Left", "Bottom Right", "Middle Right"], group="PANELS / CLUTTER CONTROL", display=display.none)
dashTextSizeOpt      = input.string("Tiny", "Dashboard text size", options=["Tiny", "Small", "Normal"], group="PANELS / CLUTTER CONTROL", display=display.none)

signalSizeOpt        = input.string("Tiny", "Signal label size", options=["Tiny", "Small", "Normal", "Large"], display=display.none)
signalDetailOpt      = input.string("Compact", "Signal label detail", options=["Arrow Only", "Compact", "Full"], display=display.none)
signalOffsetAtr      = input.float(0.25, "Signal distance from candle ATR", minval=0.0, step=0.05, display=display.none)
signalAnchorOpt      = input.string("Auto", "Signal label anchor", options=["Auto", "Candle", "Support/Resistance Zone"], display=display.none)

enableTalkingAlerts  = input.bool(true, "Enable talk-style active sentiment alerts", display=display.none)

showTradePlanPanel   = input.bool(true, "Show lower-left active signal trade plan", display=display.none)
entryBandAtr         = input.float(0.15, "Entry range thickness ATR", minval=0.01, step=0.01, display=display.none)
slBufferAtr          = input.float(0.10, "SL buffer beyond zone ATR", minval=0.0, step=0.05, display=display.none)
tp1RR                = input.float(1.00, "TP1 risk/reward", minval=0.10, step=0.05, display=display.none)
tp2RR                = input.float(1.50, "TP2 risk/reward", minval=0.10, step=0.05, display=display.none)

showFutureForecast   = input.bool(true, "Show 10-candle future forecast", display=display.none)
forecastStyleOpt     = input.string("Line", "Forecast display style", tooltip="Line-only forecast. Candle-box forecast bodies were removed to prevent hollow/empty square boxes near the price scale.", display=display.none)
forecastBars         = input.int(10, "Forecast candles forward", minval=1, maxval=50, display=display.none)
forecastLookback     = input.int(20, "Forecast slope lookback", minval=5, maxval=100, display=display.none)
forecastAtrMult      = input.float(1.00, "Forecast ATR strength", minval=0.10, step=0.05, display=display.none)
forecastOnlyActive   = input.bool(true, "Forecast only when active signal/sentiment exists", display=display.none)
forecastCandleWickAtr= input.float(0.35, "Forecast candle wick ATR", minval=0.01, step=0.01, display=display.none)
forecastCandleBodyMin= input.float(0.18, "Forecast minimum candle body ATR", minval=0.01, step=0.01, display=display.none)
forecastRespectMTFSR = input.bool(true, "Forecast respects MTF support/resistance", display=display.none)
forecastVisualMinAtr = input.float(1.00, "Minimum visible forecast distance ATR", minval=0.0, step=0.10, display=display.none)
forecastDrawRail     = input.bool(true, "Draw forecast visibility rail", display=display.none)
forecastSRLookback   = input.int(50, "MTF S/R forecast lookback", minval=10, maxval=300, display=display.none)
forecastSRBufferAtr  = input.float(0.15, "Forecast S/R buffer ATR", minval=0.0, step=0.05, display=display.none)

//==============================
// RESPECT SUPPORT BOUNCE MODE
//==============================
respectSupportBounceMode = input.bool(true, "Respect support-bounce override", display=display.none)
supportBounceLookback    = input.int(5, "Support bounce lookback bars", minval=1, maxval=25, display=display.none)
supportBounceBufferAtr   = input.float(0.20, "Support bounce buffer ATR", minval=0.0, step=0.05, display=display.none)
supportWatchMinScore     = input.int(5, "Minimum support-bounce pattern score", minval=1, maxval=10, display=display.none)

showActivePatternLabel = input.bool(true, "Show active major pattern label", display=display.none)
showHistoricalPatternLabels = input.bool(true, "Show historical pattern labels", display=display.none)
showCurrentPatternBadge = input.bool(true, "Show current active pattern badge", display=display.none)
patternLabelSizeOpt    = input.string("Tiny", "Pattern label size", options=["Tiny", "Small", "Normal", "Large"], display=display.none)
patternAnchorOpt       = input.string("Candle", "Pattern label anchor", options=["Auto", "Candle", "Support/Resistance Zone"], display=display.none)
minPatternLabelScore   = input.int(8, "Minimum pattern score to label", minval=0, maxval=10, display=display.none)
useCompactPatternLabels = input.bool(true, "Use compact historical pattern labels", display=display.none)
patternLabelCooldownBars = input.int(6, "Historical pattern label frequency / spacing", minval=1, maxval=50, display=display.none)
patternTrapBars        = input.int(5, "Failed breakout trap bars", minval=1, maxval=20, display=display.none)
doublePatternToleranceAtr = input.float(0.35, "Double top/bottom ATR tolerance", minval=0.05, step=0.05, display=display.none)
flagLookback           = input.int(8, "Flag pattern pullback lookback", minval=3, maxval=30, display=display.none)
usePatternCompatibilityGate = input.bool(true, "Block signals against strong opposite pattern", display=display.none)

showRibbonMarks      = input.bool(true, "Show projected ribbon", group="RIBBON", display=display.none)
ribbonAnchorOpt      = input.string("Top Center", "Projected ribbon anchor", options=["Top Center", "Floating Above Lower Panel"], group="RIBBON", display=display.none)
ribbonBarsBack       = input.int(30, "Ribbon bars back", minval=5, maxval=60, group="RIBBON", display=display.none)
ribbonFloatLookback  = input.int(120, "Ribbon float lookback", minval=20, maxval=500, group="RIBBON", display=display.none)
ribbonFloatLiftAtr   = input.float(1.60, "Ribbon lift above lower panel ATR", minval=0.10, step=0.05, group="RIBBON", display=display.none)
showBarColor         = input.bool(false, "Color candles by Ask Dr. Alex ribbon", display=display.none)
showBackground       = input.bool(false, "Show soft Ask Dr. Alex background color", display=display.none)

//==============================
// VISUAL SIZE MAPPING
//==============================
sigSize = signalSizeOpt == "Tiny" ? size.tiny : signalSizeOpt == "Small" ? size.small : signalSizeOpt == "Normal" ? size.normal : size.large
dashSize = dashTextSizeOpt == "Tiny" ? size.tiny : dashTextSizeOpt == "Small" ? size.small : size.normal
scoreSize = scoreLabelSizeOpt == "Tiny" ? size.tiny : scoreLabelSizeOpt == "Small" ? size.small : size.normal
patternSize = patternLabelSizeOpt == "Tiny" ? size.tiny : patternLabelSizeOpt == "Small" ? size.small : patternLabelSizeOpt == "Normal" ? size.normal : size.large

dashPos = dashPositionOpt == "Top Left" ? position.top_left : dashPositionOpt == "Bottom Right" ? position.bottom_right : dashPositionOpt == "Middle Right" ? position.middle_right : position.top_right

//==============================
// MTF DIRECTION FUNCTION
// 1 = bullish, -1 = bearish, 0 = neutral
// FIXED: one request.security call per timeframe instead of four.
//==============================
f_mtfDir(tf) =>
    [c, f, s, sp] = request.security(syminfo.tickerid, tf, [useClosedTf ? close[1] : close, useClosedTf ? ta.ema(close, fastLen)[1] : ta.ema(close, fastLen), useClosedTf ? ta.ema(close, slowLen)[1] : ta.ema(close, slowLen), useClosedTf ? ta.ema(close, slowLen)[2] : ta.ema(close, slowLen)[1]], barmerge.gaps_off, barmerge.lookahead_off)
    bull = f > s and c > s and s > sp
    bear = f < s and c < s and s < sp
    bull ? 1 : bear ? -1 : 0

//==============================
// CLOSED-CANDLE SAFE EXECUTION TIMEFRAME DATA
//==============================
f_execData() =>
    _o = useClosedTf ? open[1] : open
    _h = useClosedTf ? high[1] : high
    _l = useClosedTf ? low[1] : low
    _c = useClosedTf ? close[1] : close
    _v = useClosedTf ? volume[1] : volume
    _fast = ta.ema(close, fastLen)
    _slow = ta.ema(close, slowLen)
    _mid = ta.ema(close, midLen)
    _long = ta.ema(close, longLen)
    _hma = ta.hma(close, hullLen)
    _atr = ta.atr(atrLen)
    _rsi = ta.rsi(close, 14)
    _stoch = ta.stoch(close, high, low, 14)
    _stochD = ta.sma(_stoch, 3)
    _will = (ta.highest(high, 14) - close) / math.max(ta.highest(high, 14) - ta.lowest(low, 14), syminfo.mintick) * -100.0
    _vwma = ta.vwma(close, 20)
    _bbBasis = ta.sma(close, 20)
    _bbUpper = _bbBasis + ta.stdev(close, 20) * 2.0
    _bbLower = _bbBasis - ta.stdev(close, 20) * 2.0
    _obv = ta.cum(math.sign(ta.change(close)) * volume)
    [_o, _h, _l, _c, _v, useClosedTf ? _fast[1] : _fast, useClosedTf ? _slow[1] : _slow, useClosedTf ? _mid[1] : _mid, useClosedTf ? _long[1] : _long, useClosedTf ? _slow[2] : _slow[1], useClosedTf ? _mid[2] : _mid[1], useClosedTf ? _long[2] : _long[1], useClosedTf ? _hma[1] : _hma, useClosedTf ? _hma[2] : _hma[1], useClosedTf ? _atr[1] : _atr, useClosedTf ? _rsi[1] : _rsi, useClosedTf ? _rsi[2] : _rsi[1], useClosedTf ? ta.cci(hlc3, 20)[1] : ta.cci(hlc3, 20), useClosedTf ? ta.mfi(hlc3, 14)[1] : ta.mfi(hlc3, 14), useClosedTf ? _stoch[1] : _stoch, useClosedTf ? _stochD[1] : _stochD, useClosedTf ? _will[1] : _will, useClosedTf ? _vwma[1] : _vwma, useClosedTf ? _vwma[2] : _vwma[1], useClosedTf ? _bbBasis[1] : _bbBasis, useClosedTf ? _bbUpper[1] : _bbUpper, useClosedTf ? _bbLower[1] : _bbLower, useClosedTf ? ta.highest(high, 20)[2] : ta.highest(high, 20)[1], useClosedTf ? ta.lowest(low, 20)[2] : ta.lowest(low, 20)[1], useClosedTf ? ta.sar(0.02, 0.02, 0.2)[1] : ta.sar(0.02, 0.02, 0.2), useClosedTf ? _obv[1] : _obv, useClosedTf ? _obv[2] : _obv[1], useClosedTf ? ta.highest(high, structureLookback)[2] : ta.highest(high, structureLookback)[1], useClosedTf ? ta.lowest(low, structureLookback)[2] : ta.lowest(low, structureLookback)[1], useClosedTf ? ta.highest(high, 10)[1] : ta.highest(high, 10), useClosedTf ? ta.lowest(low, 10)[1] : ta.lowest(low, 10)]

f_macdData() =>
    [m, sig, hist] = ta.macd(close, 12, 26, 9)
    [useClosedTf ? m[1] : m, useClosedTf ? sig[1] : sig, useClosedTf ? hist[1] : hist]

f_dmiData() =>
    [pdi, mdi, adx] = ta.dmi(14, 14)
    [useClosedTf ? pdi[1] : pdi, useClosedTf ? mdi[1] : mdi, useClosedTf ? adx[1] : adx]

[oX, hX, lX, cX, vX, fastX, slowX, midX, longX, slowPrevX, midPrevX, longPrevX, hmaX, hmaPrevX, atrX, rsiX, rsiPrevX, cciX, mfiX, stochKX, stochDX, willrX, vwmaX, vwmaPrevX, bbBasisX, bbUpperX, bbLowerX, donHiX, donLoX, sarX, obvX, obvPrevX, highPrevX, lowPrevX, high10X, low10X] = request.security(syminfo.tickerid, execTf, f_execData(), barmerge.gaps_off, barmerge.lookahead_off)

[macdLineX, macdSignalX, macdHistX] = request.security(syminfo.tickerid, execTf, f_macdData(), barmerge.gaps_off, barmerge.lookahead_off)
[pdiX, mdiX, adxX] = request.security(syminfo.tickerid, execTf, f_dmiData(), barmerge.gaps_off, barmerge.lookahead_off)

//==============================
// BUILT-IN FRACTAL RIBBON
//==============================
frOscRaw = request.security(syminfo.tickerid, execTf, useClosedTf ? ta.rsi(close, 14)[1] : ta.rsi(close, 14), barmerge.gaps_off, barmerge.lookahead_off)
frFast = ta.ema(frOscRaw, frFastLen)
frSlow = ta.ema(frOscRaw, frSlowLen)
frPivotHigh = request.security(syminfo.tickerid, execTf, useClosedTf ? ta.pivothigh(high, frPivotLeft, frPivotRight)[1] : ta.pivothigh(high, frPivotLeft, frPivotRight), barmerge.gaps_off, barmerge.lookahead_off)
frPivotLow  = request.security(syminfo.tickerid, execTf, useClosedTf ? ta.pivotlow(low, frPivotLeft, frPivotRight)[1] : ta.pivotlow(low, frPivotLeft, frPivotRight), barmerge.gaps_off, barmerge.lookahead_off)

var float lastFractalHigh = na
var float lastFractalLow = na
if not na(frPivotHigh)
    lastFractalHigh := frPivotHigh
if not na(frPivotLow)
    lastFractalLow := frPivotLow

frBreakBull = not na(lastFractalHigh) and cX > lastFractalHigh
frBreakBear = not na(lastFractalLow) and cX < lastFractalLow
frRibbonBull = frFast > frSlow and frFast > 50 and (frBreakBull or cX > slowX)
frRibbonBear = frFast < frSlow and frFast < 50 and (frBreakBear or cX < slowX)
frRibbonNeutral = not frRibbonBull and not frRibbonBear

//==============================
// SWING TRENDLINE DETECTION
//==============================
swingPivotHigh = ta.pivothigh(high, swingTrendLeft, swingTrendRight)
swingPivotLow = ta.pivotlow(low, swingTrendLeft, swingTrendRight)

var float lastSwingHigh1 = na
var float lastSwingHigh2 = na
var int lastSwingHighBar1 = na
var int lastSwingHighBar2 = na
var float lastSwingLow1 = na
var float lastSwingLow2 = na
var int lastSwingLowBar1 = na
var int lastSwingLowBar2 = na

if not na(swingPivotHigh)
    lastSwingHigh2 := lastSwingHigh1
    lastSwingHighBar2 := lastSwingHighBar1
    lastSwingHigh1 := swingPivotHigh
    lastSwingHighBar1 := bar_index - swingTrendRight

if not na(swingPivotLow)
    lastSwingLow2 := lastSwingLow1
    lastSwingLowBar2 := lastSwingLowBar1
    lastSwingLow1 := swingPivotLow
    lastSwingLowBar1 := bar_index - swingTrendRight

//==============================
// MTF STACK
//==============================
// M5 is a closed lower-timeframe compliance check for 30M chart signals.
// It is not counted in the main MTF total; it is a safety veto so signals do not fight short-term sentiment.
dirM5  = f_mtfDir("5")
dirM15 = f_mtfDir("15")
dirH1  = f_mtfDir("60")
dirH4  = f_mtfDir("240")
dirD1  = f_mtfDir("D")
dirW1  = f_mtfDir("W")
dirMN1 = f_mtfDir("M")

[h4ResClosed, h4SupClosed] = request.security(syminfo.tickerid, "240", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)
[d1ResClosed, d1SupClosed] = request.security(syminfo.tickerid, "D", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)
[w1ResClosed, w1SupClosed] = request.security(syminfo.tickerid, "W", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)
[mn1ResClosed, mn1SupClosed] = request.security(syminfo.tickerid, "M", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)

bullCount = (dirM15 == 1 ? 1 : 0) + (dirH1 == 1 ? 1 : 0) + (dirH4 == 1 ? 1 : 0) + (dirD1 == 1 ? 1 : 0)
bearCount = (dirM15 == -1 ? 1 : 0) + (dirH1 == -1 ? 1 : 0) + (dirH4 == -1 ? 1 : 0) + (dirD1 == -1 ? 1 : 0)

mtfBullOK = bullCount >= mtfRequired and bullCount > bearCount
mtfBearOK = bearCount >= mtfRequired and bearCount > bullCount

// Scout confirmation = regular Ask Dr. Alex 30M setup logic + closed 5M scout confirmation.
// It is an added confirmation gate for the 30M model, not a replacement for the normal Ask Dr. Alex engine.
is30mChart = timeframe.period == "30"
logic35Active = enable35Logic and (not apply35OnlyOn30m or is30mChart)
m5BullOK = not logic35Active or dirM5 == 1
m5BearOK = not logic35Active or dirM5 == -1
m5ComplianceText = not logic35Active ? "SCOUT OFF" : dirM5 == 1 ? "SCOUT OK: M5 BULL" : dirM5 == -1 ? "SCOUT OK: M5 BEAR" : "SCOUT WAIT: M5 NEUTRAL"

//==============================
// 36-FACTOR CONFIDENCE ENGINE
//==============================
body = math.abs(cX - oX)
candleRange = math.max(hX - lX, syminfo.mintick)
upperWick = hX - math.max(oX, cX)
lowerWick = math.min(oX, cX) - lX
bodyBullOK = cX > oX and body >= atrX * 0.12
bodyBearOK = cX < oX and body >= atrX * 0.12
confirmBullOK = not requireConfirmBody or bodyBullOK
confirmBearOK = not requireConfirmBody or bodyBearOK
range10 = high10X - low10X
depthOK = range10 >= atrX * minRetraceDepth
structureBullOK = cX > highPrevX or (highPrevX - cX) >= atrX * structureAtr
structureBearOK = cX < lowPrevX or (cX - lowPrevX) >= atrX * structureAtr
donMidX = (donHiX + donLoX) / 2.0
bbMidUpper = (bbBasisX + bbUpperX) / 2.0
bbMidLower = (bbBasisX + bbLowerX) / 2.0

f_sum36(bull) =>
    int s = 0
    if bull
        s += mtfBullOK ? 1 : 0
        s += bullCount > bearCount ? 1 : 0
        s += dirM15 == 1 ? 1 : 0
        s += dirH1 == 1 ? 1 : 0
        s += (dirH4 == 1 or dirD1 == 1) ? 1 : 0
        s += cX > fastX ? 1 : 0
        s += fastX > slowX ? 1 : 0
        s += cX > slowX ? 1 : 0
        s += slowX > slowPrevX ? 1 : 0
        s += midX > longX ? 1 : 0
        s += cX > midX ? 1 : 0
        s += hmaX > hmaPrevX ? 1 : 0
        s += cX > hmaX ? 1 : 0
        s += rsiX > 50 ? 1 : 0
        s += rsiX > rsiPrevX ? 1 : 0
        s += macdLineX > macdSignalX ? 1 : 0
        s += macdHistX > 0 ? 1 : 0
        s += cciX > 0 ? 1 : 0
        s += stochKX > stochDX ? 1 : 0
        s += stochKX > 50 ? 1 : 0
        s += mfiX > 50 ? 1 : 0
        s += willrX > -50 ? 1 : 0
        s += adxX > 15 and pdiX > mdiX ? 1 : 0
        s += sarX < cX ? 1 : 0
        s += obvX > obvPrevX ? 1 : 0
        s += vwmaX > vwmaPrevX ? 1 : 0
        s += cX > vwmaX ? 1 : 0
        s += cX > bbBasisX ? 1 : 0
        s += cX > bbMidUpper ? 1 : 0
        s += cX > donMidX ? 1 : 0
        s += cX > highPrevX ? 1 : 0
        s += bodyBullOK ? 1 : 0
        s += body >= atrX * 0.12 ? 1 : 0
        s += lowerWick > upperWick ? 1 : 0
        s += frRibbonBull ? 1 : 0
        s += structureBullOK ? 1 : 0
    else
        s += mtfBearOK ? 1 : 0
        s += bearCount > bullCount ? 1 : 0
        s += dirM15 == -1 ? 1 : 0
        s += dirH1 == -1 ? 1 : 0
        s += (dirH4 == -1 or dirD1 == -1) ? 1 : 0
        s += cX < fastX ? 1 : 0
        s += fastX < slowX ? 1 : 0
        s += cX < slowX ? 1 : 0
        s += slowX < slowPrevX ? 1 : 0
        s += midX < longX ? 1 : 0
        s += cX < midX ? 1 : 0
        s += hmaX < hmaPrevX ? 1 : 0
        s += cX < hmaX ? 1 : 0
        s += rsiX < 50 ? 1 : 0
        s += rsiX < rsiPrevX ? 1 : 0
        s += macdLineX < macdSignalX ? 1 : 0
        s += macdHistX < 0 ? 1 : 0
        s += cciX < 0 ? 1 : 0
        s += stochKX < stochDX ? 1 : 0
        s += stochKX < 50 ? 1 : 0
        s += mfiX < 50 ? 1 : 0
        s += willrX < -50 ? 1 : 0
        s += adxX > 15 and mdiX > pdiX ? 1 : 0
        s += sarX > cX ? 1 : 0
        s += obvX < obvPrevX ? 1 : 0
        s += vwmaX < vwmaPrevX ? 1 : 0
        s += cX < vwmaX ? 1 : 0
        s += cX < bbBasisX ? 1 : 0
        s += cX < bbMidLower ? 1 : 0
        s += cX < donMidX ? 1 : 0
        s += cX < lowPrevX ? 1 : 0
        s += bodyBearOK ? 1 : 0
        s += body >= atrX * 0.12 ? 1 : 0
        s += upperWick > lowerWick ? 1 : 0
        s += frRibbonBear ? 1 : 0
        s += structureBearOK ? 1 : 0
    s

bullRaw = f_sum36(true)
bearRaw = f_sum36(false)
bullConf = int(math.round(bullRaw / 36.0 * 100.0))
bearConf = int(math.round(bearRaw / 36.0 * 100.0))
bullRank = int(math.round(bullRaw / 3.6))
bearRank = int(math.round(bearRaw / 3.6))

winningBuy = bullConf >= bearConf
candleConf = scoreSide == "Buy Only" ? bullConf : scoreSide == "Sell Only" ? bearConf : winningBuy ? bullConf : bearConf
candleRank = scoreSide == "Buy Only" ? bullRank : scoreSide == "Sell Only" ? bearRank : winningBuy ? bullRank : bearRank
candleDir = scoreSide == "Buy Only" ? 1 : scoreSide == "Sell Only" ? -1 : winningBuy ? 1 : -1
candleScoreText = candleScoreMode == "Rank" ? str.tostring(candleRank) : candleScoreMode == "Both" ? str.tostring(candleConf) + "/" + str.tostring(candleRank) : str.tostring(candleConf)

//==============================
// ASK DR. ALEX RIBBON ENGINE
// Base ribbon is trend/pressure driven. Respect Support Bounce Mode below can
// neutralize a bearish base ribbon into SUPPORT WATCH after the pattern engine
// confirms support rejection. It does not force a BUY signal.
//==============================
rawPressure = bullConf - bearConf
ribbonFast = ta.ema(rawPressure, 5)
ribbonSlow = ta.ema(rawPressure, 13)
ribbonBullBase = ribbonFast > ribbonSlow and ribbonFast > 5 and frRibbonBull
ribbonBearBase = ribbonFast < ribbonSlow and ribbonFast < -5 and frRibbonBear
ribbonBull = ribbonBullBase
ribbonBear = ribbonBearBase
ribbonNeutral = not ribbonBull and not ribbonBear
ribbonText = ribbonBull ? "BULL" : ribbonBear ? "BEAR" : "NEUTRAL"
ribbonColor = ribbonBull ? color.new(color.green, 0) : ribbonBear ? color.new(color.red, 0) : color.new(color.gray, 0)

//==============================
// BUY / SELL ZONES
//==============================
[zoneHigh, zoneLow, zoneAtr] = request.security(syminfo.tickerid, zoneTf, [useClosedTf ? ta.highest(high, zoneLookback)[1] : ta.highest(high, zoneLookback), useClosedTf ? ta.lowest(low, zoneLookback)[1] : ta.lowest(low, zoneLookback), useClosedTf ? ta.atr(atrLen)[1] : ta.atr(atrLen)], barmerge.gaps_off, barmerge.lookahead_off)
buyZoneLow = zoneLow
buyZoneHigh = zoneLow + zoneAtr * zoneAtrMult
sellZoneHigh = zoneHigh
sellZoneLow = zoneHigh - zoneAtr * zoneAtrMult

var box buyZoneBox = na
var box sellZoneBox = na
if showZones and barstate.islast
    if na(buyZoneBox)
        buyZoneBox := box.new(bar_index - zonePastBars, buyZoneHigh, bar_index + zoneFutureBars, buyZoneLow, bgcolor=color.new(color.green, zoneTransparency), border_color=color.new(color.green, 35))
    else
        box.set_left(buyZoneBox, bar_index - zonePastBars)
        box.set_right(buyZoneBox, bar_index + zoneFutureBars)
        box.set_top(buyZoneBox, buyZoneHigh)
        box.set_bottom(buyZoneBox, buyZoneLow)
    if na(sellZoneBox)
        sellZoneBox := box.new(bar_index - zonePastBars, sellZoneHigh, bar_index + zoneFutureBars, sellZoneLow, bgcolor=color.new(color.red, zoneTransparency), border_color=color.new(color.red, 35))
    else
        box.set_left(sellZoneBox, bar_index - zonePastBars)
        box.set_right(sellZoneBox, bar_index + zoneFutureBars)
        box.set_top(sellZoneBox, sellZoneHigh)
        box.set_bottom(sellZoneBox, sellZoneLow)

if not showZones and barstate.islast
    if not na(buyZoneBox)
        box.delete(buyZoneBox)
        buyZoneBox := na
    if not na(sellZoneBox)
        box.delete(sellZoneBox)
        sellZoneBox := na

//==============================
// ZONE CONTEXT + POST-RETEST VERIFICATION
//==============================
inBuyZone = lX <= buyZoneHigh and hX >= buyZoneLow
inSellZone = hX >= sellZoneLow and lX <= sellZoneHigh
barsSinceBuyZone = ta.barssince(inBuyZone)
barsSinceSellZone = ta.barssince(inSellZone)
recentBuyZoneTouch = not na(barsSinceBuyZone) and barsSinceBuyZone <= zoneExitBars
recentSellZoneTouch = not na(barsSinceSellZone) and barsSinceSellZone <= zoneExitBars
recentBuyZoneTouchPrev = not na(barsSinceBuyZone[1]) and barsSinceBuyZone[1] <= zoneExitBars
recentSellZoneTouchPrev = not na(barsSinceSellZone[1]) and barsSinceSellZone[1] <= zoneExitBars

buyZoneExit = recentBuyZoneTouchPrev and cX > buyZoneHigh and cX > oX
sellZoneExit = recentSellZoneTouchPrev and cX < sellZoneLow and cX < oX
buyBreakoutNow = cX > buyZoneHigh and cX[1] <= buyZoneHigh[1]
sellBreakoutNow = cX < sellZoneLow and cX[1] >= sellZoneLow[1]
barsSinceBuyBreakout = ta.barssince(buyBreakoutNow)
barsSinceSellBreakout = ta.barssince(sellBreakoutNow)
buyPostRetest = not na(barsSinceBuyBreakout) and barsSinceBuyBreakout > 0 and barsSinceBuyBreakout <= postRetestBars and lX <= buyZoneHigh + atrX * retestToleranceAtr and cX > buyZoneHigh and cX > oX
sellPostRetest = not na(barsSinceSellBreakout) and barsSinceSellBreakout > 0 and barsSinceSellBreakout <= postRetestBars and hX >= sellZoneLow - atrX * retestToleranceAtr and cX < sellZoneLow and cX < oX

buyZoneOK = not requireZoneExit or buyZoneExit or buyPostRetest
sellZoneOK = not requireZoneExit or sellZoneExit or sellPostRetest
zoneBullEvent = buyPostRetest or buyZoneExit
zoneBearEvent = sellPostRetest or sellZoneExit

activeSentimentDir = 0
activeSentimentText = requireZoneExit ? "WAITING FOR ALIGNED SENTIMENT" : "SENTIMENT FILTER OFF"
activeSentimentColor = color.new(color.gray, 35)
activeBuySentimentStart = false
activeSellSentimentStart = false

//==============================
// MAJOR PATTERN ENGINE
//==============================
prevBodyHigh = math.max(oX[1], cX[1])
prevBodyLow = math.min(oX[1], cX[1])
currBodyHigh = math.max(oX, cX)
currBodyLow = math.min(oX, cX)
bodyPct = body / candleRange
upperWickPct = upperWick / candleRange
lowerWickPct = lowerWick / candleRange

bullEngulf = cX > oX and cX[1] < oX[1] and currBodyHigh >= prevBodyHigh and currBodyLow <= prevBodyLow
bearEngulf = cX < oX and cX[1] > oX[1] and currBodyHigh >= prevBodyHigh and currBodyLow <= prevBodyLow
doji = bodyPct <= 0.15
bullMarubozu = cX > oX and bodyPct >= 0.75 and upperWickPct <= 0.12 and lowerWickPct <= 0.12
bearMarubozu = cX < oX and bodyPct >= 0.75 and upperWickPct <= 0.12 and lowerWickPct <= 0.12
hammer = lowerWick >= body * 2.0 and upperWick <= body * 0.75 and cX > lX + candleRange * 0.55
shootingStar = upperWick >= body * 2.0 and lowerWick <= body * 0.75 and cX < lX + candleRange * 0.45

bullResistanceBreak = cX > sellZoneHigh and cX[1] <= sellZoneHigh[1] and bodyBullOK
bearSupportBreak = cX < buyZoneLow and cX[1] >= buyZoneLow[1] and bodyBearOK
barsSinceBullResistanceBreak = ta.barssince(bullResistanceBreak)
barsSinceBearSupportBreak = ta.barssince(bearSupportBreak)
bullTrap = not na(barsSinceBullResistanceBreak) and barsSinceBullResistanceBreak > 0 and barsSinceBullResistanceBreak <= patternTrapBars and cX < sellZoneLow and cX < oX
bearTrap = not na(barsSinceBearSupportBreak) and barsSinceBearSupportBreak > 0 and barsSinceBearSupportBreak <= patternTrapBars and cX > buyZoneHigh and cX > oX

bullImpulse = cX[flagLookback] < cX and (cX - cX[flagLookback]) > atrX * 1.5
bearImpulse = cX[flagLookback] > cX and (cX[flagLookback] - cX) > atrX * 1.5
pullbackHigh = ta.highest(hX, flagLookback)[1]
pullbackLow = ta.lowest(lX, flagLookback)[1]
bullFlag = bullImpulse and cX > pullbackHigh and cX > fastX and fastX > slowX and bodyBullOK
bearFlag = bearImpulse and cX < pullbackLow and cX < fastX and fastX < slowX and bodyBearOK

doubleTop = math.abs(hX - highPrevX) <= atrX * doublePatternToleranceAtr and cX < oX and cX < fastX and recentSellZoneTouch
doubleBottom = math.abs(lX - lowPrevX) <= atrX * doublePatternToleranceAtr and cX > oX and cX > fastX and recentBuyZoneTouch
normalBullStructureBreak = cX > highPrevX and bodyBullOK
normalBearStructureBreak = cX < lowPrevX and bodyBearOK

patternName = "No Active Pattern"
patternDir = 0
patternScore = 0
patternBias = "Neutral"
forecastBias = "Neutral"
patternForecastBoost = 0.0

if normalBullStructureBreak
    patternName := "Bull Structure Break"
    patternDir := 1
    patternScore := 6
    patternBias := "BUY"
    forecastBias := "Bull"
    patternForecastBoost := 0.10
if normalBearStructureBreak
    patternName := "Bear Structure Break"
    patternDir := -1
    patternScore := 6
    patternBias := "SELL"
    forecastBias := "Bear"
    patternForecastBoost := -0.10
if doji and recentBuyZoneTouch
    patternName := "Doji at Support"
    patternDir := 1
    patternScore := 5
    patternBias := "BUY WATCH"
    forecastBias := "Bull Watch"
    patternForecastBoost := 0.05
else if doji and recentSellZoneTouch
    patternName := "Doji at Resistance"
    patternDir := -1
    patternScore := 5
    patternBias := "SELL WATCH"
    forecastBias := "Bear Watch"
    patternForecastBoost := -0.05
else if doji and (bullConf >= 70 or bearConf >= 70)
    patternName := "Doji Exhaustion Warning"
    patternDir := 0
    patternScore := 4
    patternBias := "REVERSAL WATCH"
    forecastBias := "Flatten"
    patternForecastBoost := 0.0
if hammer and recentBuyZoneTouch
    patternName := "Hammer at Support"
    patternDir := 1
    patternScore := 8
    patternBias := "BUY"
    forecastBias := "Bull Reversal"
    patternForecastBoost := 0.18
if shootingStar and recentSellZoneTouch
    patternName := "Shooting Star at Resistance"
    patternDir := -1
    patternScore := 8
    patternBias := "SELL"
    forecastBias := "Bear Reversal"
    patternForecastBoost := -0.18
if doubleBottom
    patternName := "Double Bottom"
    patternDir := 1
    patternScore := cX > highPrevX ? 9 : 7
    patternBias := "BUY"
    forecastBias := "Bull Reversal"
    patternForecastBoost := 0.22
if doubleTop
    patternName := "Double Top"
    patternDir := -1
    patternScore := cX < lowPrevX ? 9 : 7
    patternBias := "SELL"
    forecastBias := "Bear Reversal"
    patternForecastBoost := -0.22
if bullFlag
    patternName := "Bull Flag Breakout"
    patternDir := 1
    patternScore := buyPostRetest ? 9 : 8
    patternBias := "BUY"
    forecastBias := "Bull Continuation"
    patternForecastBoost := 0.25
if bearFlag
    patternName := "Bear Flag Breakdown"
    patternDir := -1
    patternScore := sellPostRetest ? 9 : 8
    patternBias := "SELL"
    forecastBias := "Bear Continuation"
    patternForecastBoost := -0.25
if bullEngulf
    patternName := recentBuyZoneTouch ? "Bullish Engulfing at Support" : "Bullish Engulfing"
    patternDir := 1
    patternScore := buyPostRetest ? 9 : recentBuyZoneTouch ? 8 : 6
    patternBias := "BUY"
    forecastBias := recentBuyZoneTouch ? "Bull Reversal" : "Bull"
    patternForecastBoost := recentBuyZoneTouch ? 0.25 : 0.15
if bearEngulf
    patternName := recentSellZoneTouch ? "Bearish Engulfing at Resistance" : "Bearish Engulfing"
    patternDir := -1
    patternScore := sellPostRetest ? 9 : recentSellZoneTouch ? 8 : 6
    patternBias := "SELL"
    forecastBias := recentSellZoneTouch ? "Bear Reversal" : "Bear"
    patternForecastBoost := recentSellZoneTouch ? -0.25 : -0.15
if bullMarubozu
    patternName := buyPostRetest ? "Bull Marubozu Post-Retest" : recentBuyZoneTouch ? "Bull Marubozu at Support" : "Bull Marubozu"
    patternDir := 1
    patternScore := mtfBullOK and frRibbonBull ? 10 : buyPostRetest ? 9 : 7
    patternBias := patternScore >= 9 ? "STRONG BUY" : "BUY"
    forecastBias := patternScore >= 9 ? "Strong Bull" : "Bull"
    patternForecastBoost := patternScore >= 9 ? 0.35 : 0.22
if bearMarubozu
    patternName := sellPostRetest ? "Bear Marubozu Post-Retest" : recentSellZoneTouch ? "Bear Marubozu at Resistance" : "Bear Marubozu"
    patternDir := -1
    patternScore := mtfBearOK and frRibbonBear ? 10 : sellPostRetest ? 9 : 7
    patternBias := patternScore >= 9 ? "STRONG SELL" : "SELL"
    forecastBias := patternScore >= 9 ? "Strong Bear" : "Bear"
    patternForecastBoost := patternScore >= 9 ? -0.35 : -0.22
if bearTrap
    patternName := "Bear Trap Reversal"
    patternDir := 1
    patternScore := 9
    patternBias := "BUY"
    forecastBias := "Bull Reversal"
    patternForecastBoost := 0.32
if bullTrap
    patternName := "Bull Trap Reversal"
    patternDir := -1
    patternScore := 9
    patternBias := "SELL"
    forecastBias := "Bear Reversal"
    patternForecastBoost := -0.32
if buyPostRetest
    patternName := "Breakout Retest BUY"
    patternDir := 1
    patternScore := 10
    patternBias := "STRONG BUY"
    forecastBias := "Strong Bull"
    patternForecastBoost := 0.40
if sellPostRetest
    patternName := "Breakout Retest SELL"
    patternDir := -1
    patternScore := 10
    patternBias := "STRONG SELL"
    forecastBias := "Strong Bear"
    patternForecastBoost := -0.40

patternBuyCompatible = not usePatternCompatibilityGate or patternDir >= 0 or patternScore < 7
patternSellCompatible = not usePatternCompatibilityGate or patternDir <= 0 or patternScore < 7

// CLEAN HISTORICAL PATTERN / FAKEOUT LABELS
// The old labels were too large, too wordy, and too frequent.  Default now shows only major/elite patterns,
// uses short one-line labels, spaces labels apart, and places them off the candle body.
patternShortName = str.contains(patternName, "Trap") ? (patternDir == 1 ? "FAKEOUT BUY" : "FAKEOUT SELL") :
     str.contains(patternName, "Retest") ? (patternDir == 1 ? "RETEST BUY" : "RETEST SELL") :
     str.contains(patternName, "Marubozu") ? (patternDir == 1 ? "MARUBOZU BUY" : "MARUBOZU SELL") :
     str.contains(patternName, "Engulfing") ? (patternDir == 1 ? "ENGULF BUY" : "ENGULF SELL") :
     str.contains(patternName, "Flag") ? (patternDir == 1 ? "FLAG BUY" : "FLAG SELL") :
     str.contains(patternName, "Double") ? (patternDir == 1 ? "DBL BOTTOM BUY" : "DBL TOP SELL") :
     str.contains(patternName, "Doji") ? (patternDir == 1 ? "DOJI SUPPORT" : patternDir == -1 ? "DOJI RESIST" : "DOJI WATCH") :
     str.contains(patternName, "Hammer") ? "HAMMER BUY" :
     str.contains(patternName, "Shooting") ? "STAR SELL" :
     patternDir == 1 ? "BUY PATTERN" : patternDir == -1 ? "SELL PATTERN" : "PATTERN WATCH"

patternLabelTextFull = patternName + "\n" + patternBias + " " + str.tostring(patternScore) + "/10"
patternLabelTextCompact = patternShortName + " " + str.tostring(patternScore) + "/10"
patternLabelText = useCompactPatternLabels ? patternLabelTextCompact : patternLabelTextFull
patternLabelColor = patternDir == 1 ? color.new(color.green, 0) : patternDir == -1 ? color.new(color.red, 0) : color.new(color.orange, 0)
patternLabelStyle = patternDir == -1 ? label.style_label_down : label.style_label_up
patternWantsZoneAnchor = patternAnchorOpt == "Support/Resistance Zone" or (patternAnchorOpt == "Auto" and patternScore >= 8 and patternDir != 0)
patternZonePrice = patternDir == 1 ? buyZoneHigh : patternDir == -1 ? sellZoneLow : na
patternCanUseZoneAnchor = patternWantsZoneAnchor and not na(patternZonePrice)
patternOffsetAtr = math.max(atrX * 0.35, syminfo.mintick * 10)
patternAnchorY = patternCanUseZoneAnchor ? patternZonePrice : patternDir == -1 ? hX + patternOffsetAtr : patternDir == 1 ? lX - patternOffsetAtr : cX
patternYLoc = yloc.price
patternReady = showPatternLabels and not focusDotSignalsOnly and showActivePatternLabel and patternScore >= minPatternLabelScore and patternName != "No Active Pattern"
patternChanged = patternReady and (patternName != patternName[1] or patternDir != patternDir[1] or patternScore != patternScore[1])
var int lastHistoricalPatternLabelBar = na
historicalPatternSpacingOK = na(lastHistoricalPatternLabelBar) or bar_index - lastHistoricalPatternLabelBar >= patternLabelCooldownBars
patternHistoricalPrint = showPatternLabels and not focusDotSignalsOnly and showHistoricalPatternLabels and patternChanged and historicalPatternSpacingOK

if patternHistoricalPrint
    label.new(bar_index, patternAnchorY, text=patternLabelText, xloc=xloc.bar_index, yloc=patternYLoc, style=patternLabelStyle, color=patternLabelColor, textcolor=color.white, size=patternSize)
    lastHistoricalPatternLabelBar := bar_index

var label currentPatternBadge = na
if showPatternLabels and not focusDotSignalsOnly and showCurrentPatternBadge and barstate.islast
    if not na(currentPatternBadge)
        label.delete(currentPatternBadge)
    if patternReady
        currentPatternBadge := label.new(bar_index, patternAnchorY, text="ACTIVE PATTERN\n" + patternLabelText, xloc=xloc.bar_index, yloc=patternYLoc, style=patternLabelStyle, color=patternLabelColor, textcolor=color.white, size=patternSize)

//==============================
// RESPECT SUPPORT BOUNCE OVERRIDE
// Keeps the ribbon/forecast from pressing sell directly into major support
// when the pattern engine confirms a support rejection. This is a WATCH layer,
// not a BUY signal layer. A candle close below support cancels the override.
//==============================
supportBounceBuffer = atrX * supportBounceBufferAtr
majorSupport = buyZoneLow
majorSupport := not na(h4SupClosed) and h4SupClosed <= cX + supportBounceBuffer and (na(majorSupport) or h4SupClosed > majorSupport) ? h4SupClosed : majorSupport
majorSupport := not na(d1SupClosed) and d1SupClosed <= cX + supportBounceBuffer and (na(majorSupport) or d1SupClosed > majorSupport) ? d1SupClosed : majorSupport
majorSupport := not na(w1SupClosed) and w1SupClosed <= cX + supportBounceBuffer and (na(majorSupport) or w1SupClosed > majorSupport) ? w1SupClosed : majorSupport
majorSupport := not na(mn1SupClosed) and mn1SupClosed <= cX + supportBounceBuffer and (na(majorSupport) or mn1SupClosed > majorSupport) ? mn1SupClosed : majorSupport

supportTouchedNow = not na(majorSupport) and lX <= majorSupport + supportBounceBuffer and hX >= majorSupport - supportBounceBuffer
barsSinceMajorSupportTouch = ta.barssince(supportTouchedNow)
recentMajorSupportTouch = not na(barsSinceMajorSupportTouch) and barsSinceMajorSupportTouch <= supportBounceLookback
majorSupportBroken = not na(majorSupport) and cX < majorSupport - supportBounceBuffer * 0.35
bullishSupportRejection = supportTouchedNow and not majorSupportBroken and (cX >= oX or lowerWick > upperWick or cX >= lX + candleRange * 0.55)
supportBouncePattern = (str.contains(patternName, "Doji at Support") or str.contains(patternName, "Hammer at Support") or str.contains(patternName, "Double Bottom") or str.contains(patternName, "Bullish Engulfing at Support") or str.contains(patternName, "Bull Marubozu at Support") or str.contains(patternName, "Bear Trap Reversal")) and patternScore >= supportWatchMinScore
supportBounceOverride = respectSupportBounceMode and recentMajorSupportTouch and not majorSupportBroken and (supportBouncePattern or (patternDir == 1 and patternScore >= supportWatchMinScore and bullishSupportRejection))
supportWatchText = supportBounceOverride ? "SUPPORT WATCH" : ""

if supportBounceOverride and ribbonBear
    ribbonBear := false

ribbonNeutral := not ribbonBull and not ribbonBear
ribbonText := supportBounceOverride and ribbonNeutral ? "SUPPORT WATCH" : ribbonBull ? "BULL" : ribbonBear ? "BEAR" : "NEUTRAL"
ribbonColor := supportBounceOverride and ribbonNeutral ? color.new(color.blue, 0) : ribbonBull ? color.new(color.green, 0) : ribbonBear ? color.new(color.red, 0) : color.new(color.gray, 0)

bgcolor(showBackground ? ribbonBull ? color.new(color.green, 90) : ribbonBear ? color.new(color.red, 90) : supportBounceOverride ? color.new(color.blue, 92) : na : na)
barcolor(showBarColor ? ribbonBull ? color.new(color.green, 0) : ribbonBear ? color.new(color.red, 0) : supportBounceOverride ? color.new(color.blue, 0) : na : na)

//==============================
// FINAL SIGNALS
//==============================
// Regular Ask Dr. Alex logic WITHOUT the 5M scout. This preserves the original engine.
buyBaseRegular = mtfBullOK and bullConf >= minConfidence and bullRank >= minRank and depthOK and structureBullOK and confirmBullOK and buyZoneOK and patternBuyCompatible
sellBaseRegular = mtfBearOK and bearConf >= minConfidence and bearRank >= minRank and depthOK and structureBearOK and confirmBearOK and sellZoneOK and patternSellCompatible
buyCoreRegular = buyBaseRegular and (not useFractalRibbonGate or frRibbonBull)
sellCoreRegular = sellBaseRegular and (not useFractalRibbonGate or frRibbonBear)
earlyBuyRegular = showEarlySignals and not buyCoreRegular and bullCount >= 2 and dirM15 == 1 and dirH1 == 1 and bearCount <= 1 and bullConf >= earlyConfidence and bullRank >= minRank and frRibbonBull and confirmBullOK and buyZoneOK and patternBuyCompatible
earlySellRegular = showEarlySignals and not sellCoreRegular and bearCount >= 2 and dirM15 == -1 and dirH1 == -1 and bullCount <= 1 and bearConf >= earlyConfidence and bearRank >= minRank and frRibbonBear and confirmBearOK and sellZoneOK and patternSellCompatible

// Final tradable signal logic. When scout confirmation is active, the closed 5M scout must agree.
buyBase = buyBaseRegular and m5BullOK
sellBase = sellBaseRegular and m5BearOK
buyCore = buyCoreRegular and m5BullOK
sellCore = sellCoreRegular and m5BearOK
earlyBuy = earlyBuyRegular and m5BullOK
earlySell = earlySellRegular and m5BearOK
strongBuy = showStrongSignals and buyCore and bullConf >= strongConfidence and bullRank >= strongRank and bullCount >= mtfRequired and frRibbonBull and (not strongRequiresRetest or buyPostRetest)
strongSell = showStrongSignals and sellCore and bearConf >= strongConfidence and bearRank >= strongRank and bearCount >= mtfRequired and frRibbonBear and (not strongRequiresRetest or sellPostRetest)
normalBuy = showNormalSignals and buyCore and not strongBuy
normalSell = showNormalSignals and sellCore and not strongSell

regularBuyCandidate = buyCoreRegular or earlyBuyRegular
regularSellCandidate = sellCoreRegular or earlySellRegular
logic35BuyConfirmed = logic35Active and regularBuyCandidate and dirM5 == 1
logic35SellConfirmed = logic35Active and regularSellCandidate and dirM5 == -1
logic35BuyWatch = logic35Active and regularBuyCandidate and dirM5 != 1
logic35SellWatch = logic35Active and regularSellCandidate and dirM5 != -1

//==============================
// REPEAT CONTROL
//==============================
var int lastSignalDir = 0
var int lastSignalStrength = -1
var int lastBuyBar = na
var int lastSellBar = na
var label lastSignalLabel = na

buyCooldownOK = na(lastBuyBar) or bar_index - lastBuyBar >= cooldownBars
sellCooldownOK = na(lastSellBar) or bar_index - lastSellBar >= cooldownBars
allowEarlyBuy = (not oneSignalPerTrend or lastSignalDir != 1 or lastSignalStrength < 0) and buyCooldownOK
allowNormalBuy = (not oneSignalPerTrend or lastSignalDir != 1 or lastSignalStrength < 1) and (buyCooldownOK or lastSignalStrength < 1)
allowStrongBuy = (not oneSignalPerTrend or lastSignalDir != 1 or lastSignalStrength < 2) and (buyCooldownOK or lastSignalStrength < 2)
allowEarlySell = (not oneSignalPerTrend or lastSignalDir != -1 or lastSignalStrength < 0) and sellCooldownOK
allowNormalSell = (not oneSignalPerTrend or lastSignalDir != -1 or lastSignalStrength < 1) and (sellCooldownOK or lastSignalStrength < 1)
allowStrongSell = (not oneSignalPerTrend or lastSignalDir != -1 or lastSignalStrength < 2) and (sellCooldownOK or lastSignalStrength < 2)

// NO-REPAINT SIGNAL LOCK:
// All arrows wait for the chart bar to be confirmed. Because execution data is locked to the last closed exec candle,
// arrows are plotted back one chart bar so the visual marker sits on the closed candle that generated the setup.
// Since all signal inputs are locked to closed execution data, the signal can be drawn as soon as the next chart bar opens.
// It is plotted back to the closed candle that generated it, so it does not repaint or flicker intrabar.
noRepaintSignalOK = not na(cX) and not na(atrX)
signalPlotBar = bar_index > 0 ? bar_index - 1 : bar_index

earlyBuySignal = noRepaintSignalOK and earlyBuy and not earlyBuy[1] and allowEarlyBuy
buySignal = noRepaintSignalOK and normalBuy and not normalBuy[1] and allowNormalBuy
strongBuySignal = noRepaintSignalOK and strongBuy and not strongBuy[1] and allowStrongBuy
earlySellSignal = noRepaintSignalOK and earlySell and not earlySell[1] and allowEarlySell
sellSignal = noRepaintSignalOK and normalSell and not normalSell[1] and allowNormalSell
strongSellSignal = noRepaintSignalOK and strongSell and not strongSell[1] and allowStrongSell

//==============================
// CANDLE SCORE LABELS
//==============================
scoreColor = candleDir == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
scoreAbove = scoreLocationOpt == "Above Candle" or (scoreLocationOpt == "Auto" and candleDir == -1)

buyText = signalDetailOpt == "Arrow Only" ? "▲" : signalDetailOpt == "Compact" ? "Buy " + str.tostring(bullConf) : "BUY\nConf " + str.tostring(bullConf) + "\nRank " + str.tostring(bullRank)
sellText = signalDetailOpt == "Arrow Only" ? "▼" : signalDetailOpt == "Compact" ? "Sell " + str.tostring(bearConf) : "SELL\nConf " + str.tostring(bearConf) + "\nRank " + str.tostring(bearRank)
earlyBuyText = signalDetailOpt == "Arrow Only" ? "△" : signalDetailOpt == "Compact" ? "Early Buy " + str.tostring(bullConf) : "EARLY BUY\nConf " + str.tostring(bullConf) + "\nRank " + str.tostring(bullRank)
earlySellText = signalDetailOpt == "Arrow Only" ? "▽" : signalDetailOpt == "Compact" ? "Early Sell " + str.tostring(bearConf) : "EARLY SELL\nConf " + str.tostring(bearConf) + "\nRank " + str.tostring(bearRank)
strongBuyText = signalDetailOpt == "Arrow Only" ? "▲" : signalDetailOpt == "Compact" ? "Strong Buy " + str.tostring(bullConf) : "STRONG BUY\nConf " + str.tostring(bullConf) + "\nRank " + str.tostring(bullRank)
strongSellText = signalDetailOpt == "Arrow Only" ? "▼" : signalDetailOpt == "Compact" ? "Strong Sell " + str.tostring(bearConf) : "STRONG SELL\nConf " + str.tostring(bearConf) + "\nRank " + str.tostring(bearRank)

bullSignalStrength = strongBuySignal ? 2 : buySignal ? 1 : earlyBuySignal ? 0 : -1
bearSignalStrength = strongSellSignal ? 2 : sellSignal ? 1 : earlySellSignal ? 0 : -1
hasBullSignal = bullSignalStrength >= 0
hasBearSignal = bearSignalStrength >= 0
printBullSignal = false
printBearSignal = false

if hasBullSignal and not hasBearSignal
    printBullSignal := true
else if hasBearSignal and not hasBullSignal
    printBearSignal := true
else if hasBullSignal and hasBearSignal
    if bullSignalStrength > bearSignalStrength
        printBullSignal := true
    else if bearSignalStrength > bullSignalStrength
        printBearSignal := true
    else
        printBullSignal := bullConf >= bearConf
        printBearSignal := bearConf > bullConf

if focusDotSignalsOnly
    printBullSignal := false
    printBearSignal := false

hasAnySignalThisBar = printBullSignal or printBearSignal
showConfidenceNumberThisBar = showCandleConfidenceNumbers and not focusDotSignalsOnly and bar_index >= last_bar_index - confidenceNumberBarsBack + 1 and bar_index % confidenceNumberEveryBars == 0
if showConfidenceNumberThisBar and not hasAnySignalThisBar
    label.new(bar_index, na, text=candleScoreText, xloc=xloc.bar_index, yloc=scoreAbove ? yloc.abovebar : yloc.belowbar, style=label.style_none, textcolor=scoreColor, size=scoreSize)

eliteBuyCandle = bullConf >= highConfidenceThreshold and bullRank >= highConfidenceMinRank and candleDir == 1
eliteSellCandle = bearConf >= highConfidenceThreshold and bearRank >= highConfidenceMinRank and candleDir == -1
paneLabel35OK = not require35ForPaneLabels or not logic35Active or logic35BuyConfirmed or logic35SellConfirmed
highConfidencePaneThisBar = showHighConfidencePaneLabels and not focusDotSignalsOnly and paneLabel35OK and bar_index % highConfidenceLabelEveryBars == 0 and (eliteBuyCandle or eliteSellCandle)
if highConfidencePaneThisBar
    paneTxt = eliteBuyCandle ? "★\nConf " + str.tostring(bullConf) + " | Rank " + str.tostring(bullRank) : "★\nConf " + str.tostring(bearConf) + " | Rank " + str.tostring(bearRank)
    paneCol = eliteBuyCandle ? color.new(color.green, 0) : color.new(color.red, 0)
    paneStyle = eliteBuyCandle ? label.style_label_up : label.style_label_down
    label.new(bar_index, na, text=paneTxt, xloc=xloc.bar_index, yloc=eliteBuyCandle ? yloc.belowbar : yloc.abovebar, style=paneStyle, color=paneCol, textcolor=color.white, size=scoreSize)

useBuyZoneAnchor = signalAnchorOpt == "Support/Resistance Zone" or (signalAnchorOpt == "Auto" and (buyZoneExit or buyPostRetest))
useSellZoneAnchor = signalAnchorOpt == "Support/Resistance Zone" or (signalAnchorOpt == "Auto" and (sellZoneExit or sellPostRetest))
buyAnchorY = useBuyZoneAnchor ? buyZoneHigh : na
sellAnchorY = useSellZoneAnchor ? sellZoneLow : na
buyAnchorLoc = useBuyZoneAnchor ? yloc.price : yloc.belowbar
sellAnchorLoc = useSellZoneAnchor ? yloc.price : yloc.abovebar

if printBullSignal
    if not showHistorical and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    txt = bullSignalStrength == 2 ? strongBuyText : bullSignalStrength == 1 ? buyText : earlyBuyText
    col = bullSignalStrength == 2 ? color.new(color.green, 0) : bullSignalStrength == 1 ? color.new(color.green, 15) : color.new(color.teal, 20)
    lastSignalLabel := label.new(signalPlotBar, buyAnchorY, text=txt, xloc=xloc.bar_index, yloc=buyAnchorLoc, style=label.style_label_up, color=col, textcolor=color.white, size=sigSize)
    lastSignalDir := 1
    lastSignalStrength := bullSignalStrength
    lastBuyBar := bar_index

if printBearSignal
    if not showHistorical and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    txt = bearSignalStrength == 2 ? strongSellText : bearSignalStrength == 1 ? sellText : earlySellText
    col = bearSignalStrength == 2 ? color.new(color.red, 0) : bearSignalStrength == 1 ? color.new(color.red, 15) : color.new(color.orange, 20)
    lastSignalLabel := label.new(signalPlotBar, sellAnchorY, text=txt, xloc=xloc.bar_index, yloc=sellAnchorLoc, style=label.style_label_down, color=col, textcolor=color.white, size=sigSize)
    lastSignalDir := -1
    lastSignalStrength := bearSignalStrength
    lastSellBar := bar_index

if ribbonNeutral
    lastSignalStrength := -1

//==============================
// ALIGNED ACTIVE SENTIMENT
//==============================
patternBullReversal = patternDir == 1 and (str.contains(patternName, "Reversal") or str.contains(patternName, "Doji") or str.contains(patternName, "Hammer") or str.contains(patternName, "Double Bottom") or str.contains(patternName, "Trap"))
patternBearReversal = patternDir == -1 and (str.contains(patternName, "Reversal") or str.contains(patternName, "Doji") or str.contains(patternName, "Shooting Star") or str.contains(patternName, "Double Top") or str.contains(patternName, "Trap"))
patternBullContinuation = patternDir == 1 and not patternBullReversal
patternBearContinuation = patternDir == -1 and not patternBearReversal
bullBreakoutEvent = bullResistanceBreak or str.contains(patternName, "Bull Flag Breakout") or patternName == "Breakout Retest BUY"
bearBreakdownEvent = bearSupportBreak or str.contains(patternName, "Bear Flag Breakdown") or patternName == "Breakout Retest SELL"
bullBreakoutRetest = patternName == "Breakout Retest BUY" or (buyPostRetest and bullBreakoutEvent)
bearBreakdownRetest = patternName == "Breakout Retest SELL" or (sellPostRetest and bearBreakdownEvent)

bullSentimentScore = 0
bullSentimentScore += zoneBullEvent ? 2 : 0
bullSentimentScore += bullBreakoutEvent ? 2 : 0
bullSentimentScore += buyPostRetest or bullBreakoutRetest ? 1 : 0
bullSentimentScore += patternDir == 1 and patternScore >= minPatternLabelScore ? 2 : 0
bullSentimentScore += patternBullReversal ? 1 : 0
bullSentimentScore += patternBullContinuation ? 1 : 0
bullSentimentScore += bullConf > bearConf ? 1 : 0
bullSentimentScore += bullCount > bearCount ? 1 : 0
bullSentimentScore += ribbonBull ? 1 : 0
bullSentimentScore += frRibbonBull ? 1 : 0
bullSentimentScore += strongBuy or buyCore or earlyBuy ? 2 : 0

bearSentimentScore = 0
bearSentimentScore += zoneBearEvent ? 2 : 0
bearSentimentScore += bearBreakdownEvent ? 2 : 0
bearSentimentScore += sellPostRetest or bearBreakdownRetest ? 1 : 0
bearSentimentScore += patternDir == -1 and patternScore >= minPatternLabelScore ? 2 : 0
bearSentimentScore += patternBearReversal ? 1 : 0
bearSentimentScore += patternBearContinuation ? 1 : 0
bearSentimentScore += bearConf > bullConf ? 1 : 0
bearSentimentScore += bearCount > bullCount ? 1 : 0
bearSentimentScore += ribbonBear ? 1 : 0
bearSentimentScore += frRibbonBear ? 1 : 0
bearSentimentScore += strongSell or sellCore or earlySell ? 2 : 0

bullSentimentQualified = m5BullOK and bullSentimentScore >= 4 and bullSentimentScore > bearSentimentScore + 1
bearSentimentQualified = m5BearOK and bearSentimentScore >= 4 and bearSentimentScore > bullSentimentScore + 1
activeSentimentDir := bullSentimentQualified ? 1 : bearSentimentQualified ? -1 : 0

activeSentimentText := activeSentimentDir == 1 ? bullBreakoutRetest ? "BUY BREAKOUT RETEST" : bullResistanceBreak ? "BUY BREAKOUT ABOVE RESISTANCE" : buyPostRetest and patternBullReversal ? "BUY REVERSAL POST-RETEST" : buyPostRetest ? "BUY POST-RETEST" : buyZoneExit and patternBullReversal ? "BUY REVERSAL FROM SUPPORT" : buyZoneExit ? "BUY FROM SUPPORT" : patternBullReversal ? "BULL REVERSAL WATCH" : patternBullContinuation ? "BULL CONTINUATION" : strongBuy ? "STRONG BUY SENTIMENT" : buyCore ? "BUY SENTIMENT ACTIVE" : earlyBuy ? "EARLY BUY SENTIMENT" : "BULL SENTIMENT ACTIVE" : activeSentimentDir == -1 ? bearBreakdownRetest ? "SELL BREAKDOWN RETEST" : bearSupportBreak ? "SELL BREAKDOWN BELOW SUPPORT" : sellPostRetest and patternBearReversal ? "SELL REVERSAL POST-RETEST" : sellPostRetest ? "SELL POST-RETEST" : sellZoneExit and patternBearReversal ? "SELL REVERSAL FROM RESISTANCE" : sellZoneExit ? "SELL FROM RESISTANCE" : patternBearReversal ? "BEAR REVERSAL WATCH" : patternBearContinuation ? "BEAR CONTINUATION" : strongSell ? "STRONG SELL SENTIMENT" : sellCore ? "SELL SENTIMENT ACTIVE" : earlySell ? "EARLY SELL SENTIMENT" : "BEAR SENTIMENT ACTIVE" : requireZoneExit ? "WAITING FOR ALIGNED SENTIMENT" : "SENTIMENT FILTER OFF"
activeSentimentColor := activeSentimentDir == 1 ? color.new(color.green, 0) : activeSentimentDir == -1 ? color.new(color.red, 0) : color.new(color.gray, 35)
activeBuySentimentStart := activeSentimentDir == 1 and activeSentimentDir[1] != 1
activeSellSentimentStart := activeSentimentDir == -1 and activeSentimentDir[1] != -1

//==============================
// PROJECTED NEXT-CANDLE RIBBON
// This replaces the old raw ribbon dots.
// The bottom ribbon now grades the NEXT candle bias after the full engine has
// considered support/resistance zones, breakout/retest behavior, major chart
// patterns, MTF alignment, confidence, fractal ribbon, and active sentiment.
// Color key with no text on the chart:
//   Green  = strong projected bullish candle
//   Blue   = bullish projected candle / buy watch
//   Gray   = neutral or mixed projection
//   Orange = bearish projected candle / sell watch
//   Red    = strong projected bearish candle
//==============================
nextBullProjectionScore = 0
nextBullProjectionScore += activeSentimentDir == 1 ? 5 : 0
nextBullProjectionScore += supportBounceOverride ? 6 : 0
nextBullProjectionScore += zoneBullEvent ? 2 : 0
nextBullProjectionScore += buyZoneExit ? 1 : 0
nextBullProjectionScore += buyPostRetest ? 2 : 0
nextBullProjectionScore += bullBreakoutEvent ? 2 : 0
nextBullProjectionScore += bullBreakoutRetest ? 2 : 0
nextBullProjectionScore += patternDir == 1 ? patternScore >= 8 ? 3 : 2 : 0
nextBullProjectionScore += patternBullReversal ? 2 : 0
nextBullProjectionScore += patternBullContinuation ? 1 : 0
nextBullProjectionScore += mtfBullOK ? 2 : 0
nextBullProjectionScore += bullCount > bearCount ? 1 : 0
nextBullProjectionScore += bullConf > bearConf ? 1 : 0
nextBullProjectionScore += frRibbonBull ? 1 : 0
nextBullProjectionScore += ribbonBull ? 1 : 0
nextBullProjectionScore += strongBuy ? 3 : buyCore ? 2 : earlyBuy ? 1 : 0

nextBearProjectionScore = 0
nextBearProjectionScore += activeSentimentDir == -1 ? 5 : 0
nextBearProjectionScore += zoneBearEvent ? 2 : 0
nextBearProjectionScore += sellZoneExit ? 1 : 0
nextBearProjectionScore += sellPostRetest ? 2 : 0
nextBearProjectionScore += bearBreakdownEvent ? 2 : 0
nextBearProjectionScore += bearBreakdownRetest ? 2 : 0
nextBearProjectionScore += patternDir == -1 ? patternScore >= 8 ? 3 : 2 : 0
nextBearProjectionScore += patternBearReversal ? 2 : 0
nextBearProjectionScore += patternBearContinuation ? 1 : 0
nextBearProjectionScore += mtfBearOK ? 2 : 0
nextBearProjectionScore += bearCount > bullCount ? 1 : 0
nextBearProjectionScore += bearConf > bullConf ? 1 : 0
nextBearProjectionScore += frRibbonBear ? 1 : 0
nextBearProjectionScore += ribbonBear ? 1 : 0
nextBearProjectionScore += strongSell ? 3 : sellCore ? 2 : earlySell ? 1 : 0
nextBearProjectionScore := supportBounceOverride ? math.max(0, nextBearProjectionScore - 4) : nextBearProjectionScore

projectionGap = nextBullProjectionScore - nextBearProjectionScore
projectedNextCodeRaw = projectionGap >= 6 ? 2 : projectionGap >= 2 ? 1 : projectionGap <= -6 ? -2 : projectionGap <= -2 ? -1 : 0
projectedNextCode = supportBounceOverride and projectedNextCodeRaw < 1 ? 1 : projectedNextCodeRaw
projectedNextText = supportBounceOverride and projectedNextCode == 1 ? "SUPPORT WATCH NEXT" : projectedNextCode == 2 ? "STRONG BULL NEXT" : projectedNextCode == 1 ? "BULL NEXT" : projectedNextCode == -1 ? "BEAR NEXT" : projectedNextCode == -2 ? "STRONG BEAR NEXT" : "NEUTRAL NEXT"
// RESTORED 5-COLOR RIBBON SCHEME
// Strong Bear = red, Bear = orange, Neutral = gray, Bull = blue, Strong Bull = green.
projectedRibbonColor = projectedNextCode == -2 ? color.new(color.red, 0) : projectedNextCode == -1 ? color.new(color.orange, 0) : projectedNextCode == 0 ? color.new(color.gray, 0) : projectedNextCode == 1 ? color.new(color.blue, 0) : color.new(color.green, 0)

// Projected ribbon anchor:
// - Top Center is fixed to the chart window so it does not drift under lower panels.
// - Floating mode preserves the prior price-anchored ribbon above the lower panel.
var int[] projectedRibbonHistory = array.new_int()
if barstate.isnew
    array.unshift(projectedRibbonHistory, projectedNextCode)
    if array.size(projectedRibbonHistory) > ribbonBarsBack
        array.pop(projectedRibbonHistory)

f_ribbonColor(code) =>
    code == -2 ? color.new(color.red, 0) : code == -1 ? color.new(color.orange, 0) : code == 0 ? color.new(color.gray, 0) : code == 1 ? color.new(color.blue, 0) : color.new(color.green, 0)

var table ribbonTopTable = na
if barstate.islast
    if showRibbonMarks and ribbonAnchorOpt == "Top Center"
        if na(ribbonTopTable)
            ribbonTopTable := table.new(position.top_center, ribbonBarsBack, 1, bgcolor=color.new(color.black, 100), frame_color=color.new(color.black, 100), frame_width=0, border_color=color.new(color.black, 100), border_width=0)
        for i = 0 to ribbonBarsBack - 1
            histIdx = ribbonBarsBack - 1 - i
            code = array.size(projectedRibbonHistory) > histIdx ? array.get(projectedRibbonHistory, histIdx) : 0
            table.cell(ribbonTopTable, i, 0, "", bgcolor=f_ribbonColor(code), width=1, height=1)
    else
        if not na(ribbonTopTable)
            table.delete(ribbonTopTable)
            ribbonTopTable := na

showRibbonThisBar = showRibbonMarks and ribbonAnchorOpt == "Floating Above Lower Panel" and bar_index >= last_bar_index - ribbonBarsBack + 1
ribbonFloatBase = ta.lowest(low, ribbonFloatLookback)
ribbonFloatY = ribbonFloatBase + ta.atr(14) * ribbonFloatLiftAtr
plotshape(showRibbonThisBar ? ribbonFloatY : na, title="Ask Dr. Alex AI 5-Color Projected Ribbon", style=shape.square, location=location.absolute, color=projectedRibbonColor, size=size.small, display=display.all - display.status_line - display.price_scale)

//==============================
// CLEAN MARKER HIERARCHY
// Dot = strong displacement move. Star = closed 5M scout confirmation.
// Arrow labels above/below candles = existing full setup labels. Diamond = elite/all-E setup.
// All marker logic uses closed execution data and hides values from the status line.
//==============================
strongMoveBodyOK = body >= atrX * strongMoveBodyAtr
strongMoveBullCandle = cX > oX and cX >= lX + candleRange * 0.65
strongMoveBearCandle = cX < oX and cX <= hX - candleRange * 0.65
strongMoveBuyPatternOK = (patternDir == 1 and patternScore >= strongMoveMinPatternScore) or normalBullStructureBreak or bullMarubozu or bullEngulf or bullFlag or buyPostRetest or bullResistanceBreak
strongMoveSellPatternOK = (patternDir == -1 and patternScore >= strongMoveMinPatternScore) or normalBearStructureBreak or bearMarubozu or bearEngulf or bearFlag or sellPostRetest or bearSupportBreak
strongMoveBuyCandidate = noRepaintSignalOK and bullConf >= strongMoveMinConfidence and bullRank >= strongMoveMinRank and bullConf > bearConf and strongMoveBodyOK and strongMoveBullCandle and strongMoveBuyPatternOK and (ribbonBull or frRibbonBull or mtfBullOK)
strongMoveSellCandidate = noRepaintSignalOK and bearConf >= strongMoveMinConfidence and bearRank >= strongMoveMinRank and bearConf > bullConf and strongMoveBodyOK and strongMoveBearCandle and strongMoveSellPatternOK and (ribbonBear or frRibbonBear or mtfBearOK)

eliteBuyDiamond = not focusDotSignalsOnly and showEliteDiamonds and noRepaintSignalOK and (strongBuySignal or buySignal) and logic35BuyConfirmed and bullConf >= eliteMinConfidence and bullRank >= eliteMinRank and patternDir == 1 and patternScore >= eliteMinPatternScore and (ribbonBull or frRibbonBull) and projectedNextCode >= 1
eliteSellDiamond = not focusDotSignalsOnly and showEliteDiamonds and noRepaintSignalOK and (strongSellSignal or sellSignal) and logic35SellConfirmed and bearConf >= eliteMinConfidence and bearRank >= eliteMinRank and patternDir == -1 and patternScore >= eliteMinPatternScore and (ribbonBear or frRibbonBear) and projectedNextCode <= -1

scoutBuyStar = not focusDotSignalsOnly and show35LogicStars and logic35BuyConfirmed and not eliteBuyDiamond
scoutSellStar = not focusDotSignalsOnly and show35LogicStars and logic35SellConfirmed and not eliteSellDiamond
scoutBuyWatchDot = not focusDotSignalsOnly and show35WatchDots and logic35BuyWatch and not eliteBuyDiamond and not scoutBuyStar
scoutSellWatchDot = not focusDotSignalsOnly and show35WatchDots and logic35SellWatch and not eliteSellDiamond and not scoutSellStar

var int lastStrongMoveBuyDotBar = na
var int lastStrongMoveSellDotBar = na
var int lastStrongMoveDotDir = 0
sameBuyDotStillActive = blockRepeatSignalsWhileActive and lastStrongMoveDotDir == 1 and strongMoveBuyCandidate
sameSellDotStillActive = blockRepeatSignalsWhileActive and lastStrongMoveDotDir == -1 and strongMoveSellCandidate

// v6.6D DOT STATE LOCK
// Green/red are the only confirmed entry dots and the only dot states allowed to fire alerts.
// Yellow is caution/watch only. Gray is invalid/blocked only. No alert fires on yellow or gray.
// The dot confirmation happens BEFORE the dot is printed; there is no second alert gate after the dot appears.
dotBuyConfirmOK = (not logic35Active or dirM5 == 1) and projectedNextCode >= 1 and bullConf > bearConf
dotSellConfirmOK = (not logic35Active or dirM5 == -1) and projectedNextCode <= -1 and bearConf > bullConf
dotBuyInvalidNow = (logic35Active and dirM5 == -1) or projectedNextCode <= -1 or activeSentimentDir == -1
dotSellInvalidNow = (logic35Active and dirM5 == 1) or projectedNextCode >= 1 or activeSentimentDir == 1 or supportBounceOverride
rawStrongMoveBuyDot = showStrongMoveDots and strongMoveBuyCandidate and not strongMoveBuyCandidate[1] and not sameBuyDotStillActive and (na(lastStrongMoveBuyDotBar) or bar_index - lastStrongMoveBuyDotBar >= strongMoveDotCooldownBars)
rawStrongMoveSellDot = showStrongMoveDots and strongMoveSellCandidate and not strongMoveSellCandidate[1] and not sameSellDotStillActive and (na(lastStrongMoveSellDotBar) or bar_index - lastStrongMoveSellDotBar >= strongMoveDotCooldownBars)
strongMoveBuyDot = rawStrongMoveBuyDot and dotBuyConfirmOK
strongMoveSellDot = rawStrongMoveSellDot and dotSellConfirmOK
buyDotCaution = showDotCautionStates and rawStrongMoveBuyDot and not strongMoveBuyDot and not dotBuyInvalidNow
sellDotCaution = showDotCautionStates and rawStrongMoveSellDot and not strongMoveSellDot and not dotSellInvalidNow
buyDotInvalid = showDotCautionStates and rawStrongMoveBuyDot and not strongMoveBuyDot and dotBuyInvalidNow
sellDotInvalid = showDotCautionStates and rawStrongMoveSellDot and not strongMoveSellDot and dotSellInvalidNow
dotFocusAlert = strongMoveBuyDot or strongMoveSellDot
if strongMoveBuyDot or buyDotCaution or buyDotInvalid
    lastStrongMoveBuyDotBar := bar_index
    lastStrongMoveDotDir := strongMoveBuyDot ? 1 : lastStrongMoveDotDir
if strongMoveSellDot or sellDotCaution or sellDotInvalid
    lastStrongMoveSellDotBar := bar_index
    lastStrongMoveDotDir := strongMoveSellDot ? -1 : lastStrongMoveDotDir
if blockRepeatSignalsWhileActive and not strongMoveBuyCandidate and not strongMoveSellCandidate
    lastStrongMoveDotDir := 0

pipSize = syminfo.type == "forex" ? syminfo.mintick * 10.0 : syminfo.mintick
dotSLBuffer = dotStopLossBufferPips * pipSize
// Dot entry/SL plans must anchor to the actual visible dot candle on the chart.
// This keeps the stop exactly at the opposite wick tip of the dot candle, plus/minus the adjustable pip buffer.
dotCandleHigh = high
dotCandleLow = low
buyDotStopEntry = dotCandleHigh
buyDotStopLoss = dotCandleLow - dotSLBuffer
buyDotRisk = math.max(buyDotStopEntry - buyDotStopLoss, syminfo.mintick)
buyDotTakeProfit = buyDotStopEntry + buyDotRisk * dotTakeProfitRR
sellDotStopEntry = dotCandleLow
sellDotStopLoss = dotCandleHigh + dotSLBuffer
sellDotRisk = math.max(sellDotStopLoss - sellDotStopEntry, syminfo.mintick)
sellDotTakeProfit = sellDotStopEntry - sellDotRisk * dotTakeProfitRR

var float activeBuyDotEntry = na
var float activeSellDotEntry = na
var int activeBuyDotBar = na
var int activeSellDotBar = na
if strongMoveBuyDot
    activeBuyDotEntry := buyDotStopEntry
    activeBuyDotBar := bar_index
if strongMoveSellDot
    activeSellDotEntry := sellDotStopEntry
    activeSellDotBar := bar_index

buyDotEntryHit = not na(activeBuyDotEntry) and not na(activeBuyDotBar) and bar_index > activeBuyDotBar and bar_index - activeBuyDotBar <= dotEntryMaxBars and high >= activeBuyDotEntry
sellDotEntryHit = not na(activeSellDotEntry) and not na(activeSellDotBar) and bar_index > activeSellDotBar and bar_index - activeSellDotBar <= dotEntryMaxBars and low <= activeSellDotEntry
buyDotExpired = not na(activeBuyDotBar) and bar_index - activeBuyDotBar > dotEntryMaxBars
sellDotExpired = not na(activeSellDotBar) and bar_index - activeSellDotBar > dotEntryMaxBars
if buyDotEntryHit or buyDotExpired
    activeBuyDotEntry := na
    activeBuyDotBar := na
if sellDotEntryHit or sellDotExpired
    activeSellDotEntry := na
    activeSellDotBar := na

var line[] dotEntryLines = array.new_line()
var line[] dotStopLines = array.new_line()
var line[] dotTpLines = array.new_line()
var label[] dotEntryLabels = array.new_label()
var label[] dotStopLabels = array.new_label()
var label[] dotTpLabels = array.new_label()
f_clearDotPlans() =>
    while array.size(dotEntryLines) > 0
        line.delete(array.shift(dotEntryLines))
    while array.size(dotStopLines) > 0
        line.delete(array.shift(dotStopLines))
    while array.size(dotTpLines) > 0
        line.delete(array.shift(dotTpLines))
    while array.size(dotEntryLabels) > 0
        label.delete(array.shift(dotEntryLabels))
    while array.size(dotStopLabels) > 0
        label.delete(array.shift(dotStopLabels))
    while array.size(dotTpLabels) > 0
        label.delete(array.shift(dotTpLabels))

f_pruneDotPlans() =>
    while array.size(dotEntryLines) > maxDotPlansKept
        line.delete(array.shift(dotEntryLines))
    while array.size(dotStopLines) > maxDotPlansKept
        line.delete(array.shift(dotStopLines))
    while array.size(dotTpLines) > maxDotPlansKept
        line.delete(array.shift(dotTpLines))
    while array.size(dotEntryLabels) > maxDotPlansKept
        label.delete(array.shift(dotEntryLabels))
    while array.size(dotStopLabels) > maxDotPlansKept
        label.delete(array.shift(dotStopLabels))
    while array.size(dotTpLabels) > maxDotPlansKept
        label.delete(array.shift(dotTpLabels))

dotPlanLabelX = bar_index + dotEntryMaxBars

if dotPlanActiveOnly and (buyDotEntryHit or buyDotExpired or sellDotEntryHit or sellDotExpired)
    f_clearDotPlans()

if showDotPendingLines and strongMoveBuyDot
    if dotPlanActiveOnly
        f_clearDotPlans()
    buyEntryLine = line.new(bar_index, buyDotStopEntry, bar_index + dotEntryMaxBars, buyDotStopEntry, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.lime, 0), style=line.style_solid, width=2)
    buySLLine = line.new(bar_index, buyDotStopLoss, bar_index + dotEntryMaxBars, buyDotStopLoss, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_dotted, width=1)
    buyTPLine = line.new(bar_index, buyDotTakeProfit, bar_index + dotEntryMaxBars, buyDotTakeProfit, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=1)
    buyEntryLabel = label.new(dotPlanLabelX, buyDotStopEntry, "BUY STOP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny)
    buySLLabel = label.new(dotPlanLabelX, buyDotStopLoss, "SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    buyTPLabel = label.new(dotPlanLabelX, buyDotTakeProfit, "TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.blue, 0), textcolor=color.white, size=size.tiny)
    array.push(dotEntryLines, buyEntryLine)
    array.push(dotStopLines, buySLLine)
    array.push(dotTpLines, buyTPLine)
    array.push(dotEntryLabels, buyEntryLabel)
    array.push(dotStopLabels, buySLLabel)
    array.push(dotTpLabels, buyTPLabel)
    if not dotPlanActiveOnly
        f_pruneDotPlans()

if showDotPendingLines and strongMoveSellDot
    if dotPlanActiveOnly
        f_clearDotPlans()
    sellEntryLine = line.new(bar_index, sellDotStopEntry, bar_index + dotEntryMaxBars, sellDotStopEntry, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=2)
    sellSLLine = line.new(bar_index, sellDotStopLoss, bar_index + dotEntryMaxBars, sellDotStopLoss, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_dotted, width=1)
    sellTPLine = line.new(bar_index, sellDotTakeProfit, bar_index + dotEntryMaxBars, sellDotTakeProfit, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=1)
    sellEntryLabel = label.new(dotPlanLabelX, sellDotStopEntry, "SELL STOP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    sellSLLabel = label.new(dotPlanLabelX, sellDotStopLoss, "SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    sellTPLabel = label.new(dotPlanLabelX, sellDotTakeProfit, "TP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.blue, 0), textcolor=color.white, size=size.tiny)
    array.push(dotEntryLines, sellEntryLine)
    array.push(dotStopLines, sellSLLine)
    array.push(dotTpLines, sellTPLine)
    array.push(dotEntryLabels, sellEntryLabel)
    array.push(dotStopLabels, sellSLLabel)
    array.push(dotTpLabels, sellTPLabel)
    if not dotPlanActiveOnly
        f_pruneDotPlans()

plotchar(strongMoveBuyDot, title="Ask Dr. Alex AI CONFIRMED BUY DOT", char="●", location=location.belowbar, color=color.new(color.green, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(strongMoveSellDot, title="Ask Dr. Alex AI CONFIRMED SELL DOT", char="●", location=location.abovebar, color=color.new(color.red, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(buyDotCaution, title="Ask Dr. Alex AI BUY DOT CAUTION", char="●", location=location.belowbar, color=color.new(color.yellow, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(sellDotCaution, title="Ask Dr. Alex AI SELL DOT CAUTION", char="●", location=location.abovebar, color=color.new(color.yellow, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(buyDotInvalid, title="Ask Dr. Alex AI BUY DOT INVALID", char="●", location=location.belowbar, color=color.new(color.gray, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(sellDotInvalid, title="Ask Dr. Alex AI SELL DOT INVALID", char="●", location=location.abovebar, color=color.new(color.gray, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(scoutBuyStar, title="Scout BUY confirmed", char="★", location=location.belowbar, color=color.new(color.green, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(scoutSellStar, title="Scout SELL confirmed", char="★", location=location.abovebar, color=color.new(color.red, 0), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(scoutBuyWatchDot, title="Scout BUY watch", char="●", location=location.belowbar, color=color.new(color.green, 65), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(scoutSellWatchDot, title="Scout SELL watch", char="●", location=location.abovebar, color=color.new(color.red, 65), size=size.tiny, display=display.all - display.status_line - display.price_scale)
plotchar(eliteBuyDiamond, title="Elite/all-E BUY diamond", char="◆", location=location.belowbar, color=color.new(color.lime, 0), size=size.small, display=display.all - display.status_line - display.price_scale)
plotchar(eliteSellDiamond, title="Elite/all-E SELL diamond", char="◆", location=location.abovebar, color=color.new(color.red, 0), size=size.small, display=display.all - display.status_line - display.price_scale)

//==============================
// DASHBOARD TEXT
//==============================
m5Text  = dirM5 == 1 ? "BULL" : dirM5 == -1 ? "BEAR" : "NEUTRAL"
m15Text = dirM15 == 1 ? "BULL" : dirM15 == -1 ? "BEAR" : "NEUTRAL"
h1Text  = dirH1 == 1 ? "BULL" : dirH1 == -1 ? "BEAR" : "NEUTRAL"
h4Text  = dirH4 == 1 ? "BULL" : dirH4 == -1 ? "BEAR" : "NEUTRAL"
d1Text  = dirD1 == 1 ? "BULL" : dirD1 == -1 ? "BEAR" : "NEUTRAL"
w1Text  = dirW1 == 1 ? "BULL" : dirW1 == -1 ? "BEAR" : "NEUTRAL"
mn1Text = dirMN1 == 1 ? "BULL" : dirMN1 == -1 ? "BEAR" : "NEUTRAL"
m5Color  = dirM5 == 1 ? color.new(color.green, 0) : dirM5 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
m15Color = dirM15 == 1 ? color.new(color.green, 0) : dirM15 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
h1Color  = dirH1 == 1 ? color.new(color.green, 0) : dirH1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
h4Color  = dirH4 == 1 ? color.new(color.green, 0) : dirH4 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
d1Color  = dirD1 == 1 ? color.new(color.green, 0) : dirD1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
w1Color  = dirW1 == 1 ? color.new(color.green, 0) : dirW1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
mn1Color = dirMN1 == 1 ? color.new(color.green, 0) : dirMN1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)

statusText = "WAIT"
if strongBuy
    statusText := "STRONG BUY"
else if strongSell
    statusText := "STRONG SELL"
else if buyCore
    statusText := "BUY PASSED"
else if sellCore
    statusText := "SELL PASSED"
else if earlyBuy
    statusText := "EARLY BUY"
else if earlySell
    statusText := "EARLY SELL"
else if supportBounceOverride
    statusText := "WATCH: Support bounce respected"
else if logic35Active and mtfBullOK and not m5BullOK
    statusText := "WAIT: Scout needs M5 bullish"
else if logic35Active and mtfBearOK and not m5BearOK
    statusText := "WAIT: Scout needs M5 bearish"
else if not (mtfBullOK or mtfBearOK)
    statusText := "WAIT: MTF failed need " + str.tostring(mtfRequired) + " | B=" + str.tostring(bullCount) + " S=" + str.tostring(bearCount)
else if requireZoneExit and mtfBullOK and not buyZoneOK
    statusText := "WAIT: Buy needs clean move from support zone"
else if requireZoneExit and mtfBearOK and not sellZoneOK
    statusText := "WAIT: Sell needs clean move from resistance zone"
else if mtfBullOK and not patternBuyCompatible
    statusText := "WAIT: Opposite pattern - " + patternName
else if mtfBearOK and not patternSellCompatible
    statusText := "WAIT: Opposite pattern - " + patternName
else if strongRequiresRetest and buyCore and bullConf >= strongConfidence and bullRank >= strongRank and not buyPostRetest
    statusText := "BUY PASSED: waiting post-retest for STRONG"
else if strongRequiresRetest and sellCore and bearConf >= strongConfidence and bearRank >= strongRank and not sellPostRetest
    statusText := "SELL PASSED: waiting post-retest for STRONG"
else if useFractalRibbonGate and mtfBullOK and not frRibbonBull
    statusText := "WAIT: Bull fractal ribbon not confirmed"
else if useFractalRibbonGate and mtfBearOK and not frRibbonBear
    statusText := "WAIT: Bear fractal ribbon not confirmed"
else if mtfBullOK and bullConf < minConfidence
    statusText := "WAIT: Bull confidence " + str.tostring(bullConf)
else if mtfBearOK and bearConf < minConfidence
    statusText := "WAIT: Bear confidence " + str.tostring(bearConf)
else if mtfBullOK and bullRank < minRank
    statusText := "WAIT: Bull rank " + str.tostring(bullRank)
else if mtfBearOK and bearRank < minRank
    statusText := "WAIT: Bear rank " + str.tostring(bearRank)
else if not depthOK
    statusText := "WAIT: Retrace/depth failed"
else if mtfBullOK and not structureBullOK
    statusText := "WAIT: Bull structure failed"
else if mtfBearOK and not structureBearOK
    statusText := "WAIT: Bear structure failed"
else if requireConfirmBody and mtfBullOK and not confirmBullOK
    statusText := "WAIT: Bull candle not confirmed"
else if requireConfirmBody and mtfBearOK and not confirmBearOK
    statusText := "WAIT: Bear candle not confirmed"

//==============================
// TRADE PLAN
//==============================
activePlanDir = strongBuy or buyCore or earlyBuy ? 1 : strongSell or sellCore or earlySell ? -1 : activeSentimentDir
activePlanName = strongBuy ? "STRONG BUY" : buyCore ? "BUY" : earlyBuy ? "EARLY BUY" : strongSell ? "STRONG SELL" : sellCore ? "SELL" : earlySell ? "EARLY SELL" : activeSentimentDir == 1 ? "BUY SETUP" : activeSentimentDir == -1 ? "SELL SETUP" : "WAIT"
planIsBuy = activePlanDir == 1
planIsSell = activePlanDir == -1

buyEntryLow = buyZoneHigh
buyEntryHigh = buyZoneHigh + atrX * entryBandAtr
buyEntryMid = (buyEntryLow + buyEntryHigh) / 2.0
buySL = buyZoneLow - atrX * slBufferAtr
buyRisk = math.max(buyEntryMid - buySL, syminfo.mintick)
buyTP1 = buyEntryMid + buyRisk * tp1RR
buyTP2 = buyEntryMid + buyRisk * tp2RR
sellEntryHigh = sellZoneLow
sellEntryLow = sellZoneLow - atrX * entryBandAtr
sellEntryMid = (sellEntryLow + sellEntryHigh) / 2.0
sellSL = sellZoneHigh + atrX * slBufferAtr
sellRisk = math.max(sellSL - sellEntryMid, syminfo.mintick)
sellTP1 = sellEntryMid - sellRisk * tp1RR
sellTP2 = sellEntryMid - sellRisk * tp2RR

planEntryLow = planIsBuy ? buyEntryLow : planIsSell ? sellEntryLow : na
planEntryHigh = planIsBuy ? buyEntryHigh : planIsSell ? sellEntryHigh : na
planSL = planIsBuy ? buySL : planIsSell ? sellSL : na
planTP1 = planIsBuy ? buyTP1 : planIsSell ? sellTP1 : na
planTP2 = planIsBuy ? buyTP2 : planIsSell ? sellTP2 : na

//==============================
// FORECAST
//==============================
baseForecastPressure = (bullConf - bearConf) / 100.0
forecastPressureRaw = math.max(-1.0, math.min(1.0, baseForecastPressure + patternForecastBoost))
forecastPressure = supportBounceOverride and forecastPressureRaw < 0 ? math.max(0.05, patternForecastBoost + 0.05) : forecastPressureRaw
forecastDirRaw = activePlanDir != 0 ? activePlanDir : activeSentimentDir != 0 ? activeSentimentDir : supportBounceOverride ? 1 : patternDir != 0 and patternScore >= 7 ? patternDir : bullConf > bearConf ? 1 : bearConf > bullConf ? -1 : 0
forecastDir = supportBounceOverride and forecastDirRaw == -1 ? 1 : forecastDirRaw
forecastWatchMode = supportBounceOverride and activePlanDir == 0 and activeSentimentDir == 0
forecastAllowed = showFutureForecast and not focusDotSignalsOnly and (not forecastOnlyActive or activePlanDir != 0 or activeSentimentDir != 0 or supportBounceOverride)
forecastBasePrice = useClosedTf ? close[1] : close
forecastAtr = useClosedTf ? ta.atr(atrLen)[1] : ta.atr(atrLen)
lrNow = useClosedTf ? ta.linreg(close, forecastLookback, 0)[1] : ta.linreg(close, forecastLookback, 0)
lrPrev = useClosedTf ? ta.linreg(close, forecastLookback, 1)[1] : ta.linreg(close, forecastLookback, 1)
slopeMove = (lrNow - lrPrev) * forecastBars
forecastBaseMove = slopeMove + forecastAtr * forecastAtrMult * forecastPressure
forecastEndRaw = forecastBasePrice + forecastBaseMove
forecastEndUncapped = forecastDir == 1 ? math.max(forecastEndRaw, forecastBasePrice + forecastAtr * (forecastWatchMode ? 0.05 : 0.10)) : forecastDir == -1 ? math.min(forecastEndRaw, forecastBasePrice - forecastAtr * 0.10) : na

[h1Res, h1Sup] = request.security(syminfo.tickerid, "60", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[h4Res, h4Sup] = request.security(syminfo.tickerid, "240", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[d1Res, d1Sup] = request.security(syminfo.tickerid, "D", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[w1Res, w1Sup] = request.security(syminfo.tickerid, "W", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[mnRes, mnSup] = request.security(syminfo.tickerid, "M", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)

nearestRes = na(h1Res) or h1Res <= forecastBasePrice ? na : h1Res
nearestRes := not na(h4Res) and h4Res > forecastBasePrice and (na(nearestRes) or h4Res < nearestRes) ? h4Res : nearestRes
nearestRes := not na(d1Res) and d1Res > forecastBasePrice and (na(nearestRes) or d1Res < nearestRes) ? d1Res : nearestRes
nearestRes := not na(w1Res) and w1Res > forecastBasePrice and (na(nearestRes) or w1Res < nearestRes) ? w1Res : nearestRes
nearestRes := not na(mnRes) and mnRes > forecastBasePrice and (na(nearestRes) or mnRes < nearestRes) ? mnRes : nearestRes
nearestSup = na(h1Sup) or h1Sup >= forecastBasePrice ? na : h1Sup
nearestSup := not na(h4Sup) and h4Sup < forecastBasePrice and (na(nearestSup) or h4Sup > nearestSup) ? h4Sup : nearestSup
nearestSup := not na(d1Sup) and d1Sup < forecastBasePrice and (na(nearestSup) or d1Sup > nearestSup) ? d1Sup : nearestSup
nearestSup := not na(w1Sup) and w1Sup < forecastBasePrice and (na(nearestSup) or w1Sup > nearestSup) ? w1Sup : nearestSup
nearestSup := not na(mnSup) and mnSup < forecastBasePrice and (na(nearestSup) or mnSup > nearestSup) ? mnSup : nearestSup

srBuffer = forecastAtr * forecastSRBufferAtr
buyCap = not na(nearestRes) ? math.max(forecastBasePrice + syminfo.mintick, nearestRes - srBuffer) : na
sellCap = not na(nearestSup) ? math.min(forecastBasePrice - syminfo.mintick, nearestSup + srBuffer) : na
forecastEndCapped = forecastRespectMTFSR and forecastDir == 1 and not na(buyCap) ? math.min(forecastEndUncapped, buyCap) : forecastRespectMTFSR and forecastDir == -1 and not na(sellCap) ? math.max(forecastEndUncapped, sellCap) : forecastEndUncapped
minVisibleMove = forecastAtr * (forecastWatchMode ? 0.20 : forecastVisualMinAtr)
forecastEndVisible = forecastDir == 1 and math.abs(forecastEndCapped - forecastBasePrice) < minVisibleMove ? forecastBasePrice + minVisibleMove : forecastDir == -1 and math.abs(forecastEndCapped - forecastBasePrice) < minVisibleMove ? forecastBasePrice - minVisibleMove : forecastEndCapped
forecastEnd = forecastEndVisible
forecastCapText = forecastWatchMode and not na(majorSupport) ? "Respect support bounce " + str.tostring(majorSupport, format.mintick) : forecastRespectMTFSR and forecastDir == 1 and not na(nearestRes) ? "MTF resistance cap " + str.tostring(nearestRes, format.mintick) : forecastRespectMTFSR and forecastDir == -1 and not na(nearestSup) ? "MTF support cap " + str.tostring(nearestSup, format.mintick) : "No MTF cap"
forecastText = forecastWatchMode ? "10C BULL WATCH" : forecastDir == 1 ? "10C BUY Forecast" : forecastDir == -1 ? "10C SELL Forecast" : "10C WAIT Forecast"
forecastColor = forecastWatchMode ? color.new(color.blue, 0) : forecastDir == 1 ? color.new(color.green, 0) : forecastDir == -1 ? color.new(color.red, 0) : color.new(color.gray, 35)
showForecastLine = forecastStyleOpt == "Line" or forecastStyleOpt == "Both"
showForecastCandleBodies = false

var line forecastLine = na
var line forecastRailTop = na
var line forecastRailBottom = na
var label forecastStartLabel = na
var label forecastLabel = na
var box[] forecastBodyBoxes = array.new_box()
var line[] forecastWickLines = array.new_line()

f_clearForecastCandles() =>
    bodyCount = array.size(forecastBodyBoxes)
    if bodyCount > 0
        for i = 0 to bodyCount - 1
            box.delete(array.get(forecastBodyBoxes, i))
        array.clear(forecastBodyBoxes)
    wickCount = array.size(forecastWickLines)
    if wickCount > 0
        for i = 0 to wickCount - 1
            line.delete(array.get(forecastWickLines, i))
        array.clear(forecastWickLines)

if barstate.islast
    if not na(forecastLine)
        line.delete(forecastLine)
    if not na(forecastRailTop)
        line.delete(forecastRailTop)
    if not na(forecastRailBottom)
        line.delete(forecastRailBottom)
    if not na(forecastStartLabel)
        label.delete(forecastStartLabel)
    if not na(forecastLabel)
        label.delete(forecastLabel)
    f_clearForecastCandles()
    if forecastAllowed and forecastDir != 0 and not na(forecastEnd)
        if forecastDrawRail
            railPad = forecastAtr * math.max(forecastCandleWickAtr, 0.15)
            railTop = math.max(forecastBasePrice, forecastEnd) + railPad
            railBottom = math.min(forecastBasePrice, forecastEnd) - railPad
            forecastRailTop := line.new(bar_index, railTop, bar_index + forecastBars, railTop, xloc=xloc.bar_index, extend=extend.none, color=color.new(forecastColor, 20), style=line.style_dotted, width=1)
            forecastRailBottom := line.new(bar_index, railBottom, bar_index + forecastBars, railBottom, xloc=xloc.bar_index, extend=extend.none, color=color.new(forecastColor, 20), style=line.style_dotted, width=1)
        forecastStartLabel := label.new(bar_index, forecastBasePrice, text="FORECAST START", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(forecastColor, 0), textcolor=color.white, size=size.tiny)
        if showForecastLine
            forecastLine := line.new(bar_index, forecastBasePrice, bar_index + forecastBars, forecastEnd, xloc=xloc.bar_index, extend=extend.none, color=forecastColor, style=line.style_dashed, width=2)
        // Forecast candle-body boxes intentionally removed.
        // This keeps the 10-candle forecast as line/label logic only and prevents hollow empty square boxes.
        forecastLabel := label.new(bar_index + forecastBars, forecastEnd, text=forecastText + "\n" + str.tostring(forecastEnd, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=forecastDir == 1 ? label.style_label_up : label.style_label_down, color=forecastColor, textcolor=color.white, size=size.tiny)

//==============================
// HTF S/R SHORT LINES + UNIQUE SWING TRENDLINES
//==============================
var line h4ResLine = na
var line h4SupLine = na
var line d1ResLine = na
var line d1SupLine = na
var line w1ResLine = na
var line w1SupLine = na
var line mn1ResLine = na
var line mn1SupLine = na
var line swingHighTrendLine = na
var line swingLowTrendLine = na

if barstate.islast
    srLineX1 = bar_index - 1
    srLineX2 = bar_index - 1 + htfShortLineLen
    if showHTFSRShortLines
        if na(h4ResLine)
            h4ResLine := line.new(srLineX1, h4ResClosed, srLineX2, h4ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(h4ResLine, srLineX1, h4ResClosed)
            line.set_xy2(h4ResLine, srLineX2, h4ResClosed)
            line.set_color(h4ResLine, color.new(color.red, 0))
            line.set_style(h4ResLine, line.style_solid)
            line.set_width(h4ResLine, htfShortLineWidth)
        if na(h4SupLine)
            h4SupLine := line.new(srLineX1, h4SupClosed, srLineX2, h4SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(h4SupLine, srLineX1, h4SupClosed)
            line.set_xy2(h4SupLine, srLineX2, h4SupClosed)
            line.set_color(h4SupLine, color.new(color.blue, 0))
            line.set_style(h4SupLine, line.style_solid)
            line.set_width(h4SupLine, htfShortLineWidth)
        if na(d1ResLine)
            d1ResLine := line.new(srLineX1, d1ResClosed, srLineX2, d1ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(d1ResLine, srLineX1, d1ResClosed)
            line.set_xy2(d1ResLine, srLineX2, d1ResClosed)
            line.set_color(d1ResLine, color.new(color.red, 0))
            line.set_style(d1ResLine, line.style_solid)
            line.set_width(d1ResLine, htfShortLineWidth)
        if na(d1SupLine)
            d1SupLine := line.new(srLineX1, d1SupClosed, srLineX2, d1SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(d1SupLine, srLineX1, d1SupClosed)
            line.set_xy2(d1SupLine, srLineX2, d1SupClosed)
            line.set_color(d1SupLine, color.new(color.blue, 0))
            line.set_style(d1SupLine, line.style_solid)
            line.set_width(d1SupLine, htfShortLineWidth)
        if na(w1ResLine)
            w1ResLine := line.new(srLineX1, w1ResClosed, srLineX2, w1ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(w1ResLine, srLineX1, w1ResClosed)
            line.set_xy2(w1ResLine, srLineX2, w1ResClosed)
            line.set_color(w1ResLine, color.new(color.red, 0))
            line.set_style(w1ResLine, line.style_solid)
            line.set_width(w1ResLine, htfShortLineWidth)
        if na(w1SupLine)
            w1SupLine := line.new(srLineX1, w1SupClosed, srLineX2, w1SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(w1SupLine, srLineX1, w1SupClosed)
            line.set_xy2(w1SupLine, srLineX2, w1SupClosed)
            line.set_color(w1SupLine, color.new(color.blue, 0))
            line.set_style(w1SupLine, line.style_solid)
            line.set_width(w1SupLine, htfShortLineWidth)
        if na(mn1ResLine)
            mn1ResLine := line.new(srLineX1, mn1ResClosed, srLineX2, mn1ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(mn1ResLine, srLineX1, mn1ResClosed)
            line.set_xy2(mn1ResLine, srLineX2, mn1ResClosed)
            line.set_color(mn1ResLine, color.new(color.red, 0))
            line.set_style(mn1ResLine, line.style_solid)
            line.set_width(mn1ResLine, htfShortLineWidth)
        if na(mn1SupLine)
            mn1SupLine := line.new(srLineX1, mn1SupClosed, srLineX2, mn1SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(mn1SupLine, srLineX1, mn1SupClosed)
            line.set_xy2(mn1SupLine, srLineX2, mn1SupClosed)
            line.set_color(mn1SupLine, color.new(color.blue, 0))
            line.set_style(mn1SupLine, line.style_solid)
            line.set_width(mn1SupLine, htfShortLineWidth)
    else
        if not na(h4ResLine)
            line.delete(h4ResLine)
            h4ResLine := na
        if not na(h4SupLine)
            line.delete(h4SupLine)
            h4SupLine := na
        if not na(d1ResLine)
            line.delete(d1ResLine)
            d1ResLine := na
        if not na(d1SupLine)
            line.delete(d1SupLine)
            d1SupLine := na
        if not na(w1ResLine)
            line.delete(w1ResLine)
            w1ResLine := na
        if not na(w1SupLine)
            line.delete(w1SupLine)
            w1SupLine := na
        if not na(mn1ResLine)
            line.delete(mn1ResLine)
            mn1ResLine := na
        if not na(mn1SupLine)
            line.delete(mn1SupLine)
            mn1SupLine := na

    if showUniqueTrendlines
        if not na(lastSwingHigh2) and not na(lastSwingHigh1) and not na(lastSwingHighBar2) and not na(lastSwingHighBar1)
            if na(swingHighTrendLine)
                swingHighTrendLine := line.new(lastSwingHighBar2, lastSwingHigh2, lastSwingHighBar1, lastSwingHigh1, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.red, 0), style=line.style_solid, width=swingTrendWidth)
            else
                line.set_xy1(swingHighTrendLine, lastSwingHighBar2, lastSwingHigh2)
                line.set_xy2(swingHighTrendLine, lastSwingHighBar1, lastSwingHigh1)
                line.set_extend(swingHighTrendLine, extend.right)
                line.set_color(swingHighTrendLine, color.new(color.red, 0))
                line.set_style(swingHighTrendLine, line.style_solid)
                line.set_width(swingHighTrendLine, swingTrendWidth)
        if not na(lastSwingLow2) and not na(lastSwingLow1) and not na(lastSwingLowBar2) and not na(lastSwingLowBar1)
            if na(swingLowTrendLine)
                swingLowTrendLine := line.new(lastSwingLowBar2, lastSwingLow2, lastSwingLowBar1, lastSwingLow1, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.blue, 0), style=line.style_solid, width=swingTrendWidth)
            else
                line.set_xy1(swingLowTrendLine, lastSwingLowBar2, lastSwingLow2)
                line.set_xy2(swingLowTrendLine, lastSwingLowBar1, lastSwingLow1)
                line.set_extend(swingLowTrendLine, extend.right)
                line.set_color(swingLowTrendLine, color.new(color.blue, 0))
                line.set_style(swingLowTrendLine, line.style_solid)
                line.set_width(swingLowTrendLine, swingTrendWidth)
    else
        if not na(swingHighTrendLine)
            line.delete(swingHighTrendLine)
            swingHighTrendLine := na
        if not na(swingLowTrendLine)
            line.delete(swingLowTrendLine)
            swingLowTrendLine := na

//==============================
// UNIFIED BOTTOM MASTER PANEL LAYOUT
// One fixed bottom-center table: left = Active Signal, middle = Ask Dr. Alex,
// right = Ask Dr. Alex engine. Same 9-row height, thin black border.
// This avoids giant floating panels and keeps Show All compact.
//==============================
planColor = planIsBuy ? color.new(color.green, 0) : planIsSell ? color.new(color.red, 0) : color.new(color.gray, 40)
planTextColor = color.white
statusColor = strongBuy or buyCore or earlyBuy ? color.new(color.green, 0) : strongSell or sellCore or earlySell ? color.new(color.red, 0) : supportBounceOverride ? color.new(color.blue, 0) : color.new(color.gray, 35)
f_priceText(v) => na(v) ? "-" : str.tostring(v, format.mintick)

safeAnswer = activePlanName != "WAIT" ? activePlanName : supportBounceOverride ? "WAIT / support watch" : activeSentimentDir == 1 ? "BUY watch" : activeSentimentDir == -1 ? "SELL watch" : "WAIT"
srAnswer = supportBounceOverride ? "Testing major support" : inBuyZone ? "Inside support" : inSellZone ? "Inside resistance" : cX > buyZoneHigh and cX < sellZoneLow ? "Middle / no chase" : "Near zone"
patternAnswer = patternName == "No Active Pattern" ? "None" : patternBias + " " + str.tostring(patternScore) + "/10"
forecastAnswer = forecastDir == 0 or na(forecastEnd) ? "WAIT" : forecastWatchMode ? "Bull Watch" : forecastDir == 1 ? "BUY -> " + f_priceText(forecastEnd) : "SELL -> " + f_priceText(forecastEnd)
planAnswer = activePlanName == "WAIT" ? "No active plan" : activePlanName + " E " + f_priceText(planEntryLow) + "-" + f_priceText(planEntryHigh)
invalidAnswer = planIsBuy ? "Invalid < " + f_priceText(planSL) : planIsSell ? "Invalid > " + f_priceText(planSL) : supportBounceOverride and not na(majorSupport) ? "Invalid < support" : "Wait for trigger"
ribbonCompactText = "Last " + str.tostring(ribbonBarsBack) + " | " + projectedNextText

var table masterPanel = table.new(position.bottom_center, 6, 9, border_width=1, border_color=color.black, frame_width=1, frame_color=color.black)

if barstate.islast
    // Clear the whole master panel first.
    for r = 0 to 8
        for c = 0 to 5
            table.cell(masterPanel, c, r, "", text_color=color.white, bgcolor=color.new(color.black, 100), text_size=size.tiny)

    // LEFT BLOCK: Active signal / trade plan.
    if showTradePlanPanel
        table.cell(masterPanel, 0, 0, "ASK DR. ALEX ACTIVE SIGNAL", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(masterPanel, 1, 0, activePlanName, text_color=planTextColor, bgcolor=planColor, text_size=size.tiny)
        table.cell(masterPanel, 0, 1, "Entry Range", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 1, f_priceText(planEntryLow) + " - " + f_priceText(planEntryHigh), text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 0, 2, "SL", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 2, f_priceText(planSL), text_color=color.white, bgcolor=color.new(color.red, 15), text_size=size.tiny)
        table.cell(masterPanel, 0, 3, "TP1", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 3, f_priceText(planTP1) + " (" + str.tostring(tp1RR) + "R)", text_color=color.white, bgcolor=color.new(color.green, 15), text_size=size.tiny)
        table.cell(masterPanel, 0, 4, "TP2", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 4, f_priceText(planTP2) + " (" + str.tostring(tp2RR) + "R)", text_color=color.white, bgcolor=color.new(color.green, 5), text_size=size.tiny)
        table.cell(masterPanel, 0, 5, "Scout", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 5, m5ComplianceText, text_color=color.white, bgcolor=m5Color, text_size=size.tiny)
        table.cell(masterPanel, 0, 6, "Sentiment", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 6, activeSentimentText, text_color=color.white, bgcolor=activeSentimentColor, text_size=size.tiny)
        table.cell(masterPanel, 0, 7, "10C Forecast", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 7, forecastDir == 0 or na(forecastEnd) ? "WAIT" : forecastWatchMode ? "WATCH -> " + f_priceText(forecastEnd) : (forecastDir == 1 ? "BUY -> " : "SELL -> ") + f_priceText(forecastEnd), text_color=color.white, bgcolor=forecastColor, text_size=size.tiny)
        table.cell(masterPanel, 0, 8, "Forecast Cap", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 1, 8, forecastCapText, text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)

    // MIDDLE BLOCK: Ask Dr. Alex AI. Checkbox answers only; Show All excludes label panels.
    if showAskAI
        table.cell(masterPanel, 2, 0, "ASK DR. ALEX AI", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(masterPanel, 3, 0, syminfo.ticker + " | Chart " + timeframe.period + " / Exec " + execTf, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(masterPanel, 2, 1, showAllCompact or askSafeTrade ? "Safe?" : "", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 1, showAllCompact or askSafeTrade ? safeAnswer : "", text_color=color.white, bgcolor=statusColor, text_size=size.tiny)
        table.cell(masterPanel, 2, 2, showAllCompact or askSupportResistance ? "S/R" : "", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 2, showAllCompact or askSupportResistance ? srAnswer : "", text_color=color.white, bgcolor=supportBounceOverride or inBuyZone ? color.new(color.blue, 0) : inSellZone ? color.new(color.red, 0) : color.new(color.gray, 35), text_size=size.tiny)
        table.cell(masterPanel, 2, 3, showAllCompact or askPattern ? "Pattern" : "", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 3, showAllCompact or askPattern ? patternAnswer : "", text_color=color.white, bgcolor=patternLabelColor, text_size=size.tiny)
        table.cell(masterPanel, 2, 4, showAllCompact or askForecast ? "Forecast" : "", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 4, showAllCompact or askForecast ? forecastAnswer : "", text_color=color.white, bgcolor=forecastColor, text_size=size.tiny)
        table.cell(masterPanel, 2, 5, showAllCompact or askTradePlan ? "Plan" : "", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 5, showAllCompact or askTradePlan ? planAnswer : "", text_color=color.white, bgcolor=planColor, text_size=size.tiny)
        table.cell(masterPanel, 2, 6, "Invalid", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 6, invalidAnswer, text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
        table.cell(masterPanel, 2, 7, "Ribbon", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 7, showRibbonMarks ? ribbonCompactText : "OFF", text_color=color.white, bgcolor=showRibbonMarks ? projectedRibbonColor : color.new(color.black, 80), text_size=size.tiny)
        table.cell(masterPanel, 2, 8, "Status", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 3, 8, statusText, text_color=color.white, bgcolor=statusColor, text_size=size.tiny)

    // RIGHT BLOCK: Ask Dr. Alex compact engine.
    if showAlexEngineBlock
        table.cell(masterPanel, 4, 0, "ASK DR. ALEX AI", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(masterPanel, 5, 0, "ENGINE", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=size.tiny)
        table.cell(masterPanel, 4, 1, "M5", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 1, m5Text, text_color=color.white, bgcolor=m5Color, text_size=size.tiny)
        table.cell(masterPanel, 4, 2, "M15", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 2, m15Text, text_color=color.white, bgcolor=m15Color, text_size=size.tiny)
        table.cell(masterPanel, 4, 3, "H1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 3, h1Text, text_color=color.white, bgcolor=h1Color, text_size=size.tiny)
        table.cell(masterPanel, 4, 4, "H4 / D1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 4, h4Text + " / " + d1Text, text_color=color.white, bgcolor=h4Color, text_size=size.tiny)
        table.cell(masterPanel, 4, 5, "W1 / MN1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 5, w1Text + " / " + mn1Text, text_color=color.white, bgcolor=mn1Color, text_size=size.tiny)
        table.cell(masterPanel, 4, 6, "Core", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 6, "B=" + str.tostring(bullCount) + " S=" + str.tostring(bearCount), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 4, 7, "Conf / Rank", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 7, "B" + str.tostring(bullConf) + "/" + str.tostring(bullRank) + " S" + str.tostring(bearConf) + "/" + str.tostring(bearRank), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 4, 8, "Pattern", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.tiny)
        table.cell(masterPanel, 5, 8, patternBias + " " + str.tostring(patternScore) + "/10", text_color=color.white, bgcolor=patternLabelColor, text_size=size.tiny)

// Optional classic dashboard / hidden right panel.
// DEFAULT = OFF so the right side stays clean.
// IMPORTANT: Do NOT create an empty table shell when this panel is off.
// The prior build cleared cells but left the grid/frame visible, creating blank boxes.
// This keeps the panel code intact and deletes the table only when hidden.
var table dash = na
if showDashboard and barstate.islast
    if na(dash)
        dash := table.new(dashPos, 2, 17, border_width=1, border_color=color.black, frame_width=1, frame_color=color.black)
    table.cell(dash, 0, 0, "ASK DR. ALEX AI", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=dashSize)
    table.cell(dash, 1, 0, syminfo.ticker + " | Exec " + execTf, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=dashSize)
    table.cell(dash, 0, 1, "M15", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 1, m15Text, text_color=color.white, bgcolor=m15Color, text_size=dashSize)
    table.cell(dash, 0, 2, "H1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 2, h1Text, text_color=color.white, bgcolor=h1Color, text_size=dashSize)
    table.cell(dash, 0, 3, "H4", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 3, h4Text, text_color=color.white, bgcolor=h4Color, text_size=dashSize)
    table.cell(dash, 0, 4, "D1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 4, d1Text, text_color=color.white, bgcolor=d1Color, text_size=dashSize)
    table.cell(dash, 0, 5, "W1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 5, w1Text, text_color=color.white, bgcolor=w1Color, text_size=dashSize)
    table.cell(dash, 0, 6, "MN1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 6, mn1Text, text_color=color.white, bgcolor=mn1Color, text_size=dashSize)
    table.cell(dash, 0, 7, "Core Counts", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 7, "B=" + str.tostring(bullCount) + " S=" + str.tostring(bearCount) + " Need=" + str.tostring(mtfRequired), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 8, "Confidence", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 8, "Buy " + str.tostring(bullConf) + " | Sell " + str.tostring(bearConf), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 9, "Rank", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 9, "Buy " + str.tostring(bullRank) + " | Sell " + str.tostring(bearRank), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 10, "Ask Dr. Alex Ribbon", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 10, ribbonText, text_color=color.white, bgcolor=ribbonColor, text_size=dashSize)
    table.cell(dash, 0, 11, "Active Sentiment", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 11, activeSentimentText, text_color=color.white, bgcolor=activeSentimentColor, text_size=dashSize)
    table.cell(dash, 0, 12, "36 Indicator MTF Status", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 12, statusText, text_color=color.white, bgcolor=statusColor, text_size=dashSize)
    table.cell(dash, 0, 13, "W/M Context", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 13, "W1 " + w1Text + " | MN1 " + mn1Text, text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 14, "Active Pattern", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 14, patternName, text_color=color.white, bgcolor=patternLabelColor, text_size=dashSize)
    table.cell(dash, 0, 15, "Pattern Direction", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 15, patternBias + " | " + str.tostring(patternScore) + "/10", text_color=color.white, bgcolor=patternLabelColor, text_size=dashSize)
    table.cell(dash, 0, 16, "Forecast Bias", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 16, forecastBias, text_color=color.white, bgcolor=patternLabelColor, text_size=dashSize)
else if barstate.islast
    if not na(dash)
        table.delete(dash)
        dash := na

//==============================
// ALERTS
//==============================
if enableTalkingAlerts and barstate.isconfirmed and activeBuySentimentStart
    alert("Ask Dr. Alex AI says: Active BUY sentiment on " + syminfo.ticker + ". Confidence " + str.tostring(bullConf) + ". Rank " + str.tostring(bullRank) + ". Entry range " + f_priceText(buyEntryLow) + " to " + f_priceText(buyEntryHigh) + ". Stop loss " + f_priceText(buySL) + ". TP1 " + f_priceText(buyTP1) + ". TP2 " + f_priceText(buyTP2) + ". Pattern " + patternName + " " + patternBias + " score " + str.tostring(patternScore) + " out of 10. Ten candle forecast " + str.tostring(forecastEnd, format.mintick) + ". " + forecastCapText + ". " + activeSentimentText, alert.freq_once_per_bar_close)

if enableTalkingAlerts and barstate.isconfirmed and activeSellSentimentStart
    alert("Ask Dr. Alex AI says: Active SELL sentiment on " + syminfo.ticker + ". Confidence " + str.tostring(bearConf) + ". Rank " + str.tostring(bearRank) + ". Entry range " + f_priceText(sellEntryLow) + " to " + f_priceText(sellEntryHigh) + ". Stop loss " + f_priceText(sellSL) + ". TP1 " + f_priceText(sellTP1) + ". TP2 " + f_priceText(sellTP2) + ". Pattern " + patternName + " " + patternBias + " score " + str.tostring(patternScore) + " out of 10. Ten candle forecast " + str.tostring(forecastEnd, format.mintick) + ". " + forecastCapText + ". " + activeSentimentText, alert.freq_once_per_bar_close)

alertcondition(activeBuySentimentStart, title="Ask Dr. Alex AI ACTIVE BUY SENTIMENT", message="ASK DR. ALEX AI ACTIVE BUY SENTIMENT on {{ticker}}")
alertcondition(activeSellSentimentStart, title="Ask Dr. Alex AI ACTIVE SELL SENTIMENT", message="ASK DR. ALEX AI ACTIVE SELL SENTIMENT on {{ticker}}")
alertcondition(patternScore >= minPatternLabelScore and patternDir == 1, title="Ask Dr. Alex AI BULLISH PATTERN", message="Ask Dr. Alex AI bullish active pattern on {{ticker}}")
alertcondition(patternScore >= minPatternLabelScore and patternDir == -1, title="Ask Dr. Alex AI BEARISH PATTERN", message="Ask Dr. Alex AI bearish active pattern on {{ticker}}")
alertcondition(supportBounceOverride, title="Ask Dr. Alex AI SUPPORT WATCH", message="Ask Dr. Alex AI support-bounce watch on {{ticker}}")
alertcondition(dotFocusAlert, title="Ask Dr. Alex AI DOT FOCUS ALERT", message="Ask Dr. Alex AI confirmed DOT FOCUS signal on {{ticker}}. Green dot = confirmed buy. Red dot = confirmed sell. Yellow/gray dots do not alert.")
alertcondition(strongMoveBuyDot, title="Ask Dr. Alex AI CONFIRMED BUY DOT", message="Ask Dr. Alex AI CONFIRMED BUY DOT on {{ticker}}. The green dot is the alert. Buy Stop is the dot candle high. Stop loss is the opposite wick tip plus the adjustable pip buffer. TP uses the Dot TP risk/reward setting.")
alertcondition(strongMoveSellDot, title="Ask Dr. Alex AI CONFIRMED SELL DOT", message="Ask Dr. Alex AI CONFIRMED SELL DOT on {{ticker}}. The red dot is the alert. Sell Stop is the dot candle low. Stop loss is the opposite wick tip plus the adjustable pip buffer. TP uses the Dot TP risk/reward setting.")
alertcondition(earlyBuySignal, title="Ask Dr. Alex AI EARLY BUY", message="Ask Dr. Alex AI EARLY BUY on {{ticker}}")
alertcondition(earlySellSignal, title="Ask Dr. Alex AI EARLY SELL", message="Ask Dr. Alex AI EARLY SELL on {{ticker}}")
alertcondition(buySignal, title="Ask Dr. Alex AI BUY", message="Ask Dr. Alex AI BUY on {{ticker}}")
alertcondition(sellSignal, title="Ask Dr. Alex AI SELL", message="Ask Dr. Alex AI SELL on {{ticker}}")
alertcondition(strongBuySignal, title="Ask Dr. Alex AI STRONG BUY", message="Ask Dr. Alex AI STRONG BUY on {{ticker}}")
alertcondition(strongSellSignal, title="Ask Dr. Alex AI STRONG SELL", message="Ask Dr. Alex AI STRONG SELL on {{ticker}}")
````
