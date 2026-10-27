# EZ$ AMD

- url: https://www.tradingview.com/script/EvA7acwT-EZ-AMD/
- type: indicator
- pine_id: PUB;fc36b04c30c944f29bac188e65c2b53d
- version: 4.0

## Description

Brief update description

EZ$ AMD Extreme Distribution v2.2 refines the indicator around higher-timeframe AMD narrative and precise lower-timeframe execution. Its primary purpose is to identify one high-quality AMD BUY near the lowest qualified manipulation area or one AMD SELL near the highest qualified manipulation area.

AMD signals require a completed accumulation period, manipulation beyond the accumulation range, a meaningful external-liquidity sweep, a confirmed reclaim, microstructure shift, displacement, and majority multi-timeframe bias agreement. The default model uses 4-hour AMD with 1-minute or 5-minute execution, making it suitable for Asia, London, and New York trading.

The live higher-timeframe candle synchronizes with the selected AMD model and changes color in real time:

Yellow: accumulation or waiting
Aqua: low-side manipulation
Purple: high-side manipulation
Green: bullish distribution
Red: bearish distribution

Standard BUY/SELL signals are optional and disabled by default. Support/resistance and higher-timeframe supply/demand origin zones remain available as visual context without independently creating AMD entries.

Settings guide
1. Recommended: AMD extreme signals only

This is the cleanest setup and the one I recommend.

Simple Signal Engine
Setting	Value
Standard BUY / SELL Display	Off
Confirm Signals on Candle Close	On
Signal Gap	8
Microstructure Length	2
Displacement Range × ATR	0.80
Displacement Body ÷ Range	0.60

This removes ordinary reaction signals and leaves AMD as the main entry engine.

Optimal Higher-Timeframe Signals
Setting	Value
Show Confirmed HTF BUY / SELL	Off

This prevents additional HTF labels from appearing.

Bias Dashboard
Setting	Value
Show Bias-Only Dashboard	On
Use Confirmed HTF Candles	On
Count 5m, 15m, 1H, 2H, 4H, Daily	All On
Minimum Matching Biases	4

An AMD BUY requires at least four bullish timeframes, while an AMD SELL requires at least four bearish timeframes. The aligned side must also outnumber the opposing side.

AMD settings
Setting	Value
Show 4-Hour AMD	On
All other AMD timeframes	Off
Show AMD Extreme-Level Signals	On
Hide Standard Signals When AMD Signals Are On	On
AMD Signals Only on 1m / 5m Charts	On
AMD Signal Timeframe	4H
Require External Level Liquidity Sweep	On
Require Close Back Through Swept Level	On
Require Microstructure Shift + Displacement	On
One AMD Signal Per Candle	On
Use Accumulation High / Low	On
Use Selected AMD Candle Open	Off
AMD Zone Trigger Mode	Deepest Zone Reaction
Use HTF Origin Zones for AMD Location	On
Use HTF Zone Edges + Midpoint	On
Require Level Cluster Inside HTF Zone	On
Minimum Levels in Cluster	2
Show Manipulation Extreme Diamond	Off

This is the strict A+ configuration.

2. Structural-zone visuals

For your 4-hour AMD and 1-minute execution workflow:

Setting	Value
Zone Model	Adaptive
Chart Timeframe Zone	Off
5-Minute Zone	Off
15-Minute Zone	Off
1-Hour Zone	Off
2-Hour Zone	Off
4-Hour Zone	On
Daily Zone	Off
Show Interaction Volume	Off
Show Timeframe + Zone Type	On
Use Visible Zones for Standard Signals	Off
Require FVG / Imbalance for S/D	On
Maximum S/D Retests	1

The 4-hour supply/demand origin zone remains visible and can improve AMD location, but it does not create an entry by itself.

3. Key levels

Keep these on:

Camarilla H4/L4
Previous day high/low
Previous week high/low
Previous 4-hour high/low
Asia high/low
London high/low
New York high/low
Overnight high/low

Keep these off for less noise:

Central Pivot
H3/L3
Daily, weekly, and monthly opens
Previous mids
Monday levels
Quarter levels
Yearly levels
Timed opens

The highs become possible SELL-side liquidity, and the lows become possible BUY-side liquidity.

4. Live AMD candle
Setting	Value
Show Live HTF Candle	On
Sync Live Candle to AMD Signal Timeframe	On
Color Live Candle by Real-Time AMD Phase	On
Show Timeframe Label	On
Show Candle Timer	On

The candle color is developing visual context. An actual AMD signal still requires a confirmed execution candle.

To show regular BUY/SELL signals too

Use:

Setting	Value
Standard BUY / SELL Display	Bias-Aligned Only
Hide Standard Signals When AMD Signals Are On	Off
Show AMD Extreme-Level Signals	On

This displays both:

Ordinary bias-aligned BUY/SELL
Strict AMD BUY/AMD SELL

For even stricter ordinary signals, turn Use AMD to Filter Standard Signals on. Ordinary BUY/SELL signals will then require matching AMD distribution.

I would leave this off initially because your primary focus is the AMD extreme signal.

To show only regular signals
Setting	Value
Standard BUY / SELL Display	Bias-Aligned Only
Show AMD Extreme-Level Signals	Off
Show Confirmed HTF BUY / SELL	Off

This returns the indicator to ordinary level reactions filtered by majority bias.

To show no signals at all

Use this visual-only mode:

Setting	Value
Standard BUY / SELL Display	Off
Show AMD Extreme-Level Signals	Off
Show Confirmed HTF BUY / SELL	Off
Show Manipulation Extreme Diamond	Off

You may still keep these visible:

4-hour AMD boxes
Live AMD candle
Bias dashboard
Key levels
4-hour supply/demand zone

This provides AMD market context without any entry symbols.

When no AMD signal appears

That does not necessarily mean the indicator is malfunctioning. Under the recommended settings, all of these must qualify:

You are using a 1-minute or 5-minute chart.
The 4-hour accumulation period completed.
Price manipulated beyond the correct accumulation boundary.
An external high or low was swept.
Price closed back through the swept level.
Price reclaimed into the accumulation range.
Microstructure shifted.
Displacement confirmed.
At least four of six biases agreed.
The required level cluster or HTF origin-zone condition qualified.
No earlier AMD signal was already issued for that 4-hour model.

## Source Code

````pine
//@version=6
indicator("EZ$ HTF Layered Reaction v5.0", shorttitle="EZ$ React", overlay=true, max_boxes_count=120, max_labels_count=300, max_lines_count=120)

//──────────────────────────────────────────────────────────────────────────────
// EZ$ HTF LAYERED REACTION INDICATOR v5.0
//
// Cleaned architecture:
//   • Support / resistance is the only structural-zone model and the only entry source.
//   • EZ$L / EZ$S is one live-validity engine from the active 1-minute
//     chart support/resistance box. No 5-minute entry signals are generated.
//   • A signal appears after the first confirmed box defense and is deleted when
//     that exact box closes invalid, is replaced, or an opposite 1-minute setup appears.
//   • This live-validity behavior intentionally removes invalidated historical
//     labels; it is a live decision aid, not a non-repainting backtest record.
//   • RL / RS labels and alerts have been removed completely.
//   • Multi-Asset Health inputs and the Liquidity Lean dashboard have been removed.
//     Health analysis belongs in the separate Multi-Asset Engine indicator.
//   • Pivots, higher-timeframe boxes, bias, Structure AMD and the live HTF candle
//     remain visual context only and never affect EZ$L / EZ$S.
//   • Visual OTE is optional post-signal refinement sourced only from EZ$L / EZ$S.
//     It never creates, blocks or modifies the signal.
//   • Bullish defenses must close above support; bearish defenses must close
//     below resistance. Signals and invalidations are confirmed on candle close.
//
// Removed from entry logic and display:
//   • RL / RS reaction labels and alerts.
//   • Multi-Asset Health source links and Liquidity Lean dashboard.
//   • Pivot-reaction, higher-timeframe overlap, objective-room and chase gates.
//   • Delayed follow-through engine, 5-minute entries and mandatory sweeps.
//   • Permanent plotshape signal history.
//──────────────────────────────────────────────────────────────────────────────

// ───── 1. Clean 1M S/R Signals
// One live entry engine only. The active chart must be 1 minute, and the current
// chart support/resistance box must confirm its first defense.
groupSignal = "1. Clean 1M S/R Signals"
optimalSignalDisplay = input.string("Live EZ$L / EZ$S", "Signal Display",
     options=["Off", "Live EZ$L / EZ$S"], group=groupSignal,
     tooltip="Live-validity markers from the active 1-minute chart S/R box only. A marker is deleted after a confirmed box invalidation or replacement.")
confirmOnClose = input.bool(true, "Confirm Signal + Invalidation on Candle Close", group=groupSignal,
     tooltip="Recommended. Prevents intrabar flicker. The signal can still disappear later after a confirmed box failure.")
atrLength = input.int(14, "ATR Length", minval=1, group=groupSignal)
useSessionATRForSignals = input.bool(false, "Use Session-Adaptive ATR", group=groupSignal,
     tooltip="OFF preserves rolling ATR for reaction measurements and optional OTE.")
microLength = input.int(2, "Microstructure Length", minval=1, maxval=10, group=groupSignal)
rejectionWickBody = input.float(1.20, "Rejection Wick ÷ Body", minval=0.25, maxval=5.00, step=0.05, group=groupSignal)
strongCloseLocation = input.float(0.65, "Strong Close Location", minval=0.50, maxval=0.95, step=0.01, group=groupSignal)
displacementATR = input.float(0.80, "Displacement Range × ATR", minval=0.25, maxval=3.00, step=0.05, group=groupSignal)
displacementBodyPct = input.float(0.60, "Displacement Body ÷ Range", minval=0.30, maxval=0.95, step=0.01, group=groupSignal)
useRelativeVolumeConcept = input.bool(false, "Allow Relative-Volume Reaction Concept", group=groupSignal,
     tooltip="OFF is recommended. Wick rejection, displacement and microstructure remain the reaction confirmations.")
relativeVolumeLength = input.int(20, "Relative-Volume Average Length", minval=2, group=groupSignal)
relativeVolumeMultiple = input.float(1.20, "High Volume Multiple", minval=1.00, maxval=5.00, step=0.05, group=groupSignal)

// ───── 2. Camarilla and objective levels
groupLevels = "2. Pivots & Key Levels"
showCentralPivot = input.bool(false, "Central Pivot (CP)", group=groupLevels)
showCamarillaH3L3 = input.bool(false, "Camarilla H3 / L3", group=groupLevels)
showCamarillaH4L4 = input.bool(true, "Camarilla H4 / L4", group=groupLevels)
showPreviousDay = input.bool(true, "Previous Day High / Low", group=groupLevels)
showPreviousWeek = input.bool(true, "Previous Week High / Low", group=groupLevels)
showPreviousMonth = input.bool(false, "Previous Month High / Low", group=groupLevels,
     tooltip="Major higher-timeframe context. Disabled by default to preserve a clean chart.")
showDailyOpen = input.bool(false, "Daily Open", inline="op1", group=groupLevels)
showPreviousDayMid = input.bool(false, "Previous Day Mid", inline="op1", group=groupLevels)
showWeeklyOpen = input.bool(false, "Weekly Open", inline="op2", group=groupLevels)
showPreviousWeekMid = input.bool(false, "Previous Week Mid", inline="op2", group=groupLevels)
showMonthlyOpen = input.bool(false, "Monthly Open", inline="op3", group=groupLevels)
showPreviousMonthMid = input.bool(false, "Previous Month Mid", inline="op3", group=groupLevels)
showPrevious4HLevels = input.bool(true, "Previous 4H High / Low", inline="h4", group=groupLevels)
showCurrent4HOpen = input.bool(false, "4H Open", inline="h4", group=groupLevels)
showPrevious4HMid = input.bool(false, "Previous 4H Mid", group=groupLevels)
showMondayLevels = input.bool(false, "Monday High / Low / Mid", group=groupLevels)
showQuarterLevels = input.bool(false, "Previous Quarter High / Low", inline="q", group=groupLevels)
showQuarterOpenMid = input.bool(false, "Quarter Open / Mid", inline="q", group=groupLevels)
showYearLevels = input.bool(false, "Current Year High / Low", inline="y", group=groupLevels)
showYearOpenMid = input.bool(false, "Year Open / Mid", inline="y", group=groupLevels)
showAsia = input.bool(true, "Completed Asia High / Low", group=groupLevels)
showLondon = input.bool(true, "Completed London High / Low", group=groupLevels)
showNewYork = input.bool(true, "Completed New York High / Low", group=groupLevels)
showSessionOpens = input.bool(false, "Asia / London / New York Opens", group=groupLevels)
show1800ETOpen = input.bool(false, "18:00 ET Open", inline="eto", group=groupLevels)
showMidnightETOpen = input.bool(false, "Midnight ET", inline="eto", group=groupLevels)
show1000ETOpen = input.bool(false, "10:00 ET", inline="eto", group=groupLevels,
     tooltip="Latest New York-time opens. Before today's 10:00 ET print, the 10:00 level remains the previous trading day's open.")
showOvernight = input.bool(true, "Completed Overnight High / Low", group=groupLevels,
     tooltip="Combined 6:00 PM–8:30 AM Chicago range. With automatic session blocking enabled, it is displayed during New York only.")

// ───── 3. Sessions
groupSessions = "3. Sessions"
sessionTimeZone = input.string("America/Chicago", "Session Time Zone", group=groupSessions)
asiaSession = input.session("1800-0000", "Asia Session", group=groupSessions)
londonSession = input.session("0200-0500", "London Session", group=groupSessions)
newYorkSession = input.session("0830-1500", "New York Session", group=groupSessions)
overnightSession = input.session("1800-0830", "Overnight Range", group=groupSessions)
autoBlockSessionLevels = input.bool(true, "Auto-Block Irrelevant Session Levels", group=groupSessions,
     tooltip="New York hides Asia levels, London hides prior New York levels, and Asia hides London levels. Session levels are visual context only.")
useSessionLevelFreshness = input.bool(true, "Retire Repeatedly Crossed Session Levels", group=groupSessions,
     tooltip="Removes visual session levels after repeated close-crosses.")
maximumSessionLevelCrosses = input.int(2, "Maximum Session-Level Close Crosses", minval=1, maxval=6, group=groupSessions)

// ───── 4. Structural zones
groupSR = "4. Structural Zones"
srPivotStrength = input.int(3, "Confirmed Pivot Strength", minval=1, maxval=10, group=groupSR)
srATRLength = input.int(14, "Zone ATR Length", minval=1, group=groupSR)
srMinimumPaddingATR = input.float(0.10, "Minimum Zone Width × ATR", minval=0.01, maxval=1.00, step=0.01, group=groupSR)
showZoneVolume = input.bool(false, "Show Interaction Volume in Boxes", group=groupSR)
showZoneLabels = input.bool(true, "Show Timeframe + Zone Type", group=groupSR)
zoneLabelSize = input.string("Normal", "Zone Label Size", options=["Small", "Normal", "Large"], group=groupSR,
     tooltip="Controls the text size inside support/resistance boxes. Normal is recommended for visibility.")
zoneLabelTextColor = input.color(color.black, "Zone Label Text Color", group=groupSR,
     tooltip="Black is recommended for light charts. Change this to white when using a dark chart.")
zoneLabelTwoLines = input.bool(true, "Stack Timeframe Above Zone Type", group=groupSR,
     tooltip="Shows the source timeframe above SUPPORT or RESISTANCE so the label is easier to read.")
zoneBorderWidth = input.int(2, "Zone Border Width", minval=1, maxval=4, group=groupSR)
showOnlyChartAndHigherTFBoxes = input.bool(true, "Show Chart + Higher-Timeframe Boxes Only", group=groupSR,
     tooltip="Recommended. Lower-timeframe boxes are hidden on higher-timeframe charts, while every enabled higher-timeframe box remains visible on 1M and 5M execution charts.")

showChartSR = input.bool(true, "Chart Timeframe Zone", group=groupSR)
show5mSR = input.bool(true, "5-Minute Zone", inline="sr1", group=groupSR)
show15mSR = input.bool(true, "15-Minute", inline="sr1", group=groupSR)
show1hSR = input.bool(true, "1-Hour", inline="sr2", group=groupSR)
show2hSR = input.bool(true, "2-Hour", inline="sr2", group=groupSR)
show4hSR = input.bool(true, "4-Hour", inline="sr3", group=groupSR)
show8hSR = input.bool(true, "8-Hour", inline="sr3", group=groupSR,
     tooltip="Adds an intermediate higher-timeframe reaction box between 4H and Daily.")
showDailySR = input.bool(true, "Daily", inline="sr4", group=groupSR)
showWeeklySR = input.bool(true, "Weekly", inline="sr4", group=groupSR,
     tooltip="Broad location context. On Daily charts, the Weekly box remains visible while lower-timeframe boxes are hidden.")

// ───── 5. Bias-only dashboard
groupBias = "5. Bias Dashboard"
showBiasDashboard = input.bool(true, "Show Bias-Only Dashboard", group=groupBias)
dashboardSize = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal"], group=groupBias,
     tooltip="Changes the text and cell footprint of the combined Bias + ATR dashboard. Small is recommended.")
compactDashboardLabels = input.bool(true, "Compact Dashboard Labels", group=groupBias,
     tooltip="Uses shorter labels such as MAJ, SIG, SES and ENG to reduce dashboard width.")
show1mBias = input.bool(true, "Show 1-Minute Bias", group=groupBias,
     tooltip="Adds immediate 1-minute pressure to the dashboard. Visual context only.")
showDynamicChartBias = input.bool(true, "Show Dynamic Chart Bias", group=groupBias,
     tooltip="Adds the active chart timeframe to the dashboard only when it is not already represented by 1M, 5M, 15M, 1H, 2H, 4H, or Daily. Visual context only.")
useConfirmedBias = input.bool(true, "Use Confirmed HTF Candles", group=groupBias)
biasEMALength = input.int(50, "Bias EMA Length", minval=2, group=groupBias)
countBias5m = input.bool(true, "Count 5m", inline="maj1", group=groupBias)
countBias15m = input.bool(true, "15m", inline="maj1", group=groupBias)
countBias1h = input.bool(true, "1H", inline="maj2", group=groupBias)
countBias2h = input.bool(true, "2H", inline="maj2", group=groupBias)
countBias4h = input.bool(true, "4H", inline="maj3", group=groupBias)
countBiasDaily = input.bool(true, "Daily", inline="maj3", group=groupBias)
minimumMajorityBiases = input.int(4, "Minimum Matching Biases", minval=1, maxval=6, group=groupBias,
     tooltip="Recommended: 4 of 6. The matching side must also outnumber the opposite side.")

// ───── 6. Visual higher-timeframe candle
groupPO3 = "6. Visual Higher-Timeframe Candle"
showPO3Candle = input.bool(true, "Show Live HTF Candle", group=groupPO3)
po3Timeframe = input.timeframe("240", "Live HTF Candle Timeframe", group=groupPO3,
     tooltip="This selects the displayed candle only. It does not determine the Structure AMD phase.")
po3Offset = input.int(6, "Offset to Right (bars)", minval=2, maxval=50, group=groupPO3)
po3BodyWidth = input.int(3, "Body Width (bars)", minval=1, maxval=8, group=groupPO3)
showPO3Label = input.bool(true, "Show Candle + Structure AMD Label", group=groupPO3)
showPO3Timer = input.bool(true, "Show HTF Candle Timer", group=groupPO3)
colorPO3ByAMD = input.bool(true, "Color Live Candle by Structure AMD", group=groupPO3,
     tooltip="Yellow = accumulation/range. Aqua = low-side manipulation. Purple = high-side manipulation. Green/red = bullish/bearish structural distribution.")

// ───── 7. Pure Structure AMD
groupAMD = "7. Pure Structure AMD"
structureAMDBoxScope = input.string("Chart + 5M + 15M", "Structure AMD Box Sources",
     options=["Chart Only", "Chart + 5M + 15M", "Chart + Visible HTF"], group=groupAMD,
     tooltip="Recommended on the 1-minute chart: Chart + 5M + 15M. Higher boxes remain broad location context unless Chart + Visible HTF is selected.")
structureAMDRequireExpansion = input.bool(true, "Require Expansion for Distribution", group=groupAMD,
     tooltip="ON requires displacement or a directional microstructure break after support/resistance is defended before distribution confirms.")
structureAMDMaximumAgeBars = input.int(250, "Maximum Structure Context Age (bars)", minval=25, maxval=2000, group=groupAMD,
     tooltip="Resets stale manipulation/distribution context to accumulation/wait when no new structural event occurs for this many chart bars.")
showStructureAMDDashboard = input.bool(true, "Show Structure AMD in Dashboard", group=groupAMD,
     tooltip="Structure AMD is visual context only. It never creates, blocks, filters, or modifies EZ$L / EZ$S / OTE.")

// ───── 8. Optional trend EMA
groupTrendEMA = "8. Optional Trend EMA"
showTrendEMA = input.bool(false, "Show Trend EMA", group=groupTrendEMA)
trendEMALength = input.int(20, "Trend EMA Length", minval=2, group=groupTrendEMA,
     tooltip="Visual reference only. It does not create, block, or modify live 1-minute S/R signals.")

// ───── 9. Session-adaptive ATR
groupSessionATR = "9. Session-Adaptive ATR"
showATRPanel = input.bool(true, "Show Compact ATR Status", group=groupSessionATR)

// ───── 10. Optional EZ$ Signal OTE
groupOTE = "10. Optional EZ$ Signal OTE"
showVisualOTE = input.bool(false, "Show EZ$ Signal OTE", group=groupOTE,
     tooltip="Optional post-signal entry refinement sourced only from a new 1-minute EZ$L / EZ$S marker. OFF is the clean default.")
oteRequireDisplacement = input.bool(true, "Require Displacement to Confirm Impulse", group=groupOTE)
oteMinimumImpulseATR = input.float(0.60, "Minimum Impulse Range × ATR", minval=0.25, maxval=5.00, step=0.05, group=groupOTE,
     tooltip="Reduced from 0.80 ATR so valid 1-minute impulses can qualify more naturally.")
oteRetracementLockPercent = input.float(15.0, "Lock Swing After Retracement (%)", minval=10.0, maxval=50.0, step=0.5, group=groupOTE,
     tooltip="The OTE freezes after a 15% confirmed retracement, allowing it to appear earlier than the prior 23.6% requirement.")
showOTEEquilibrium = input.bool(true, "Show 50% Equilibrium", group=groupOTE)
showOTEBoundaryLines = input.bool(true, "Show 62% / 79% Boundaries", group=groupOTE)
showOTEPreferredLine = input.bool(true, "Show 70.5% Preferred Entry", group=groupOTE)
showOTELabel = input.bool(true, "Show OTE Label", group=groupOTE)
removeOTEAfterFirstVisit = input.bool(true, "Remove After First Completed Zone Visit", group=groupOTE)
oteMaximumAgeBars = input.int(100, "Maximum OTE Age (bars)", minval=10, maxval=1000, group=groupOTE)

// ───── Core measurements
inAsiaSession = not na(time(timeframe.period, asiaSession, sessionTimeZone))
inLondonSession = not na(time(timeframe.period, londonSession, sessionTimeZone))
inNewYorkSession = not na(time(timeframe.period, newYorkSession, sessionTimeZone))

rollingATR = ta.atr(atrLength)
trueRangeValue = ta.tr(true)

f_update_session_atr(float previousValue, float currentTR, int length) =>
    na(previousValue) ? currentTR : previousValue + (currentTR - previousValue) / length

var float asiaSessionATR = na
var float londonSessionATR = na
var float newYorkSessionATR = na

bool sessionATRNeeded = showATRPanel or useSessionATRForSignals
if sessionATRNeeded and inAsiaSession
    asiaSessionATR := f_update_session_atr(asiaSessionATR, trueRangeValue, atrLength)
if sessionATRNeeded and inLondonSession
    londonSessionATR := f_update_session_atr(londonSessionATR, trueRangeValue, atrLength)
if sessionATRNeeded and inNewYorkSession
    newYorkSessionATR := f_update_session_atr(newYorkSessionATR, trueRangeValue, atrLength)

activeSessionName = inNewYorkSession ? "NEW YORK" : inLondonSession ? "LONDON" : inAsiaSession ? "ASIA" : "OFF SESSION"
sessionProfileATR = inNewYorkSession ? nz(newYorkSessionATR, rollingATR) :
     inLondonSession ? nz(londonSessionATR, rollingATR) :
     inAsiaSession ? nz(asiaSessionATR, rollingATR) : rollingATR

atr = useSessionATRForSignals ? sessionProfileATR : rollingATR
candleRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyPct = bodySize / candleRange
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closeLocation = (close - low) / candleRange

bullRejectCandle = close > open and lowerWick >= bodySize * rejectionWickBody and closeLocation >= strongCloseLocation
bearRejectCandle = close < open and upperWick >= bodySize * rejectionWickBody and closeLocation <= 1.0 - strongCloseLocation
bullDisplacement = close > open and candleRange >= atr * displacementATR and bodyPct >= displacementBodyPct
bearDisplacement = close < open and candleRange >= atr * displacementATR and bodyPct >= displacementBodyPct
bullMicroShift = close > ta.highest(high[1], microLength)
bearMicroShift = close < ta.lowest(low[1], microLength)

volumeAverage = ta.sma(volume, relativeVolumeLength)
highRelativeVolume = useRelativeVolumeConcept and not na(volumeAverage) and volume >= volumeAverage * relativeVolumeMultiple
bullVolumeReaction = highRelativeVolume and close > open and closeLocation >= strongCloseLocation
bearVolumeReaction = highRelativeVolume and close < open and closeLocation <= 1.0 - strongCloseLocation

bullReactionCandle = bullRejectCandle or bullDisplacement or bullMicroShift or bullVolumeReaction
bearReactionCandle = bearRejectCandle or bearDisplacement or bearMicroShift or bearVolumeReaction

trendEMA = ta.ema(close, trendEMALength)
plot(showTrendEMA ? trendEMA : na, "Trend EMA", color=color.new(color.white, 15), linewidth=2)

// ───── Previous-day Camarilla and central pivot
[pdHigh, pdLow, pdClose] = request.security(syminfo.tickerid, "1D",
     [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

previousDayRange = pdHigh - pdLow
centralPivot = (pdHigh + pdLow + pdClose) / 3.0
camarillaH3 = pdClose + previousDayRange * 1.1 / 4.0
camarillaL3 = pdClose - previousDayRange * 1.1 / 4.0
camarillaH4 = pdClose + previousDayRange * 1.1 / 2.0
camarillaL4 = pdClose - previousDayRange * 1.1 / 2.0

[pwHigh, pwLow, weeklyOpen] = request.security(syminfo.tickerid, "1W",
     [high[1], low[1], open], lookahead=barmerge.lookahead_on)
[pmHigh, pmLow, monthlyOpen] = request.security(syminfo.tickerid, "1M",
     [high[1], low[1], open], lookahead=barmerge.lookahead_on)

dailyOpen = request.security(syminfo.tickerid, "1D", open, lookahead=barmerge.lookahead_on)
previousDayMid = (pdHigh + pdLow) / 2.0
previousWeekMid = (pwHigh + pwLow) / 2.0
previousMonthMid = (pmHigh + pmLow) / 2.0

[pqHigh, pqLow, quarterOpen] = request.security(syminfo.tickerid, "3M",
     [high[1], low[1], open], lookahead=barmerge.lookahead_on)
previousQuarterMid = (pqHigh + pqLow) / 2.0

[currentYearHigh, currentYearLow, yearlyOpen] = request.security(syminfo.tickerid, "12M",
     [high, low, open], lookahead=barmerge.lookahead_off)
currentYearMid = (currentYearHigh + currentYearLow) / 2.0

[previous4HHigh, previous4HLow, current4HOpen] = request.security(syminfo.tickerid, "240",
     [high[1], low[1], open], lookahead=barmerge.lookahead_on)
previous4HMid = (previous4HHigh + previous4HLow) / 2.0

[dailyDayOfWeek, currentDailyHigh, currentDailyLow] = request.security(syminfo.tickerid, "1D",
     [dayofweek, high, low], lookahead=barmerge.lookahead_off)
var float mondayHigh = na
var float mondayLow = na
bool newTradingWeek = ta.change(time("1W")) != 0
if newTradingWeek
    mondayHigh := na
    mondayLow := na
if dailyDayOfWeek == dayofweek.monday
    mondayHigh := currentDailyHigh
    mondayLow := currentDailyLow
mondayMid = not na(mondayHigh) and not na(mondayLow) ? (mondayHigh + mondayLow) / 2.0 : na

// ───── Completed session helpers
f_previous_session(string sessionInput) =>
    bool inSession = not na(time(timeframe.period, sessionInput, sessionTimeZone))
    var float activeHigh = na
    var float activeLow = na
    var float completedHigh = na
    var float completedLow = na

    if inSession and not inSession[1]
        activeHigh := high
        activeLow := low
    else if inSession
        activeHigh := math.max(nz(activeHigh, high), high)
        activeLow := math.min(nz(activeLow, low), low)

    if not inSession and inSession[1]
        completedHigh := activeHigh
        completedLow := activeLow

    [completedHigh, completedLow]

f_latest_session_open(string sessionInput) =>
    bool inSession = not na(time(timeframe.period, sessionInput, sessionTimeZone))
    var float latestOpen = na
    if inSession and not inSession[1]
        latestOpen := open
    latestOpen

[asiaHigh, asiaLow] = f_previous_session(asiaSession)
[londonHigh, londonLow] = f_previous_session(londonSession)
[newYorkHigh, newYorkLow] = f_previous_session(newYorkSession)
[overnightHigh, overnightLow] = f_previous_session(overnightSession)
asiaOpen = f_latest_session_open(asiaSession)
londonOpen = f_latest_session_open(londonSession)
newYorkOpen = f_latest_session_open(newYorkSession)

f_latest_clock_open(int targetHour, int targetMinute, string targetTimeZone) =>
    bool isTargetBar = hour(time, targetTimeZone) == targetHour and minute(time, targetTimeZone) == targetMinute
    var float latestOpen = na
    var int latestTime = na
    if isTargetBar
        latestOpen := open
        latestTime := time
    [latestOpen, latestTime]

[open1800ET, open1800ETTime] = f_latest_clock_open(18, 0, "America/New_York")
[midnightOpenET, midnightOpenETTime] = f_latest_clock_open(0, 0, "America/New_York")
[open1000ET, open1000ETTime] = f_latest_clock_open(10, 0, "America/New_York")

allowAsiaSessionLevels = not autoBlockSessionLevels or not inNewYorkSession
allowLondonSessionLevels = not autoBlockSessionLevels or not inAsiaSession
allowNewYorkSessionLevels = not autoBlockSessionLevels or not inLondonSession
allowOvernightLevels = not autoBlockSessionLevels or inNewYorkSession

var int asiaHighCrosses = 0
var int asiaLowCrosses = 0
var int londonHighCrosses = 0
var int londonLowCrosses = 0
var int newYorkHighCrosses = 0
var int newYorkLowCrosses = 0
var int overnightHighCrosses = 0
var int overnightLowCrosses = 0

if not na(asiaHigh) and (na(asiaHigh[1]) or asiaHigh != asiaHigh[1])
    asiaHighCrosses := 0
    asiaLowCrosses := 0
if not na(londonHigh) and (na(londonHigh[1]) or londonHigh != londonHigh[1])
    londonHighCrosses := 0
    londonLowCrosses := 0
if not na(newYorkHigh) and (na(newYorkHigh[1]) or newYorkHigh != newYorkHigh[1])
    newYorkHighCrosses := 0
    newYorkLowCrosses := 0
if not na(overnightHigh) and (na(overnightHigh[1]) or overnightHigh != overnightHigh[1])
    overnightHighCrosses := 0
    overnightLowCrosses := 0

asiaHighEnabled = showAsia and allowAsiaSessionLevels and (not useSessionLevelFreshness or asiaHighCrosses < maximumSessionLevelCrosses)
asiaLowEnabled = showAsia and allowAsiaSessionLevels and (not useSessionLevelFreshness or asiaLowCrosses < maximumSessionLevelCrosses)
londonHighEnabled = showLondon and allowLondonSessionLevels and (not useSessionLevelFreshness or londonHighCrosses < maximumSessionLevelCrosses)
londonLowEnabled = showLondon and allowLondonSessionLevels and (not useSessionLevelFreshness or londonLowCrosses < maximumSessionLevelCrosses)
newYorkHighEnabled = showNewYork and allowNewYorkSessionLevels and (not useSessionLevelFreshness or newYorkHighCrosses < maximumSessionLevelCrosses)
newYorkLowEnabled = showNewYork and allowNewYorkSessionLevels and (not useSessionLevelFreshness or newYorkLowCrosses < maximumSessionLevelCrosses)
overnightHighEnabled = showOvernight and allowOvernightLevels and (not useSessionLevelFreshness or overnightHighCrosses < maximumSessionLevelCrosses)
overnightLowEnabled = showOvernight and allowOvernightLevels and (not useSessionLevelFreshness or overnightLowCrosses < maximumSessionLevelCrosses)
asiaOpenEnabled = showSessionOpens and allowAsiaSessionLevels
londonOpenEnabled = showSessionOpens and allowLondonSessionLevels
newYorkOpenEnabled = showSessionOpens and allowNewYorkSessionLevels

// ───── Plot clean key levels
plot(showCentralPivot ? centralPivot : na, "CP", color=color.new(color.yellow, 0), linewidth=2, style=plot.style_stepline)
plot(showCamarillaH3L3 ? camarillaH3 : na, "H3", color=color.new(color.orange, 10), linewidth=1, style=plot.style_stepline)
plot(showCamarillaH3L3 ? camarillaL3 : na, "L3", color=color.new(color.orange, 10), linewidth=1, style=plot.style_stepline)
plot(showCamarillaH4L4 ? camarillaH4 : na, "H4", color=color.new(color.red, 10), linewidth=1, style=plot.style_stepline)
plot(showCamarillaH4L4 ? camarillaL4 : na, "L4", color=color.new(color.lime, 10), linewidth=1, style=plot.style_stepline)
plot(showPreviousDay ? pdHigh : na, "PDH", color=color.new(color.gray, 20), linewidth=1, style=plot.style_stepline)
plot(showPreviousDay ? pdLow : na, "PDL", color=color.new(color.gray, 20), linewidth=1, style=plot.style_stepline)
plot(showPreviousWeek ? pwHigh : na, "PWH", color=color.new(color.silver, 35), linewidth=1, style=plot.style_stepline)
plot(showPreviousWeek ? pwLow : na, "PWL", color=color.new(color.silver, 35), linewidth=1, style=plot.style_stepline)
plot(showPreviousMonth ? pmHigh : na, "PMH", color=color.new(color.fuchsia, 45), linewidth=1, style=plot.style_stepline)
plot(showPreviousMonth ? pmLow : na, "PML", color=color.new(color.fuchsia, 45), linewidth=1, style=plot.style_stepline)
plot(showDailyOpen ? dailyOpen : na, "Daily Open", color=color.new(color.white, 35), linewidth=1, style=plot.style_stepline)
plot(showPreviousDayMid ? previousDayMid : na, "Previous Day Mid", color=color.new(color.gray, 55), linewidth=1, style=plot.style_stepline)
plot(showWeeklyOpen ? weeklyOpen : na, "Weekly Open", color=color.new(color.silver, 30), linewidth=1, style=plot.style_stepline)
plot(showPreviousWeekMid ? previousWeekMid : na, "Previous Week Mid", color=color.new(color.silver, 55), linewidth=1, style=plot.style_stepline)
plot(showMonthlyOpen ? monthlyOpen : na, "Monthly Open", color=color.new(color.fuchsia, 35), linewidth=1, style=plot.style_stepline)
plot(showPreviousMonthMid ? previousMonthMid : na, "Previous Month Mid", color=color.new(color.fuchsia, 60), linewidth=1, style=plot.style_stepline)
plot(showPrevious4HLevels ? previous4HHigh : na, "Previous 4H High", color=color.new(color.orange, 20), linewidth=1, style=plot.style_stepline)
plot(showPrevious4HLevels ? previous4HLow : na, "Previous 4H Low", color=color.new(color.orange, 20), linewidth=1, style=plot.style_stepline)
plot(showCurrent4HOpen ? current4HOpen : na, "4H Open", color=color.new(color.orange, 40), linewidth=1, style=plot.style_stepline)
plot(showPrevious4HMid ? previous4HMid : na, "Previous 4H Mid", color=color.new(color.orange, 60), linewidth=1, style=plot.style_stepline)
plot(showMondayLevels ? mondayHigh : na, "Monday High", color=color.new(color.yellow, 40), linewidth=1, style=plot.style_stepline)
plot(showMondayLevels ? mondayLow : na, "Monday Low", color=color.new(color.yellow, 40), linewidth=1, style=plot.style_stepline)
plot(showMondayLevels ? mondayMid : na, "Monday Mid", color=color.new(color.yellow, 65), linewidth=1, style=plot.style_stepline)
plot(showQuarterLevels ? pqHigh : na, "Previous Quarter High", color=color.new(color.maroon, 35), linewidth=1, style=plot.style_stepline)
plot(showQuarterLevels ? pqLow : na, "Previous Quarter Low", color=color.new(color.maroon, 35), linewidth=1, style=plot.style_stepline)
plot(showQuarterOpenMid ? quarterOpen : na, "Quarterly Open", color=color.new(color.maroon, 50), linewidth=1, style=plot.style_stepline)
plot(showQuarterOpenMid ? previousQuarterMid : na, "Previous Quarter Mid", color=color.new(color.maroon, 65), linewidth=1, style=plot.style_stepline)
plot(showYearLevels ? currentYearHigh : na, "Current Year High", color=color.new(color.navy, 35), linewidth=1, style=plot.style_stepline)
plot(showYearLevels ? currentYearLow : na, "Current Year Low", color=color.new(color.navy, 35), linewidth=1, style=plot.style_stepline)
plot(showYearOpenMid ? yearlyOpen : na, "Yearly Open", color=color.new(color.navy, 50), linewidth=1, style=plot.style_stepline)
plot(showYearOpenMid ? currentYearMid : na, "Current Year Mid", color=color.new(color.navy, 65), linewidth=1, style=plot.style_stepline)
plot(asiaHighEnabled ? asiaHigh : na, "Asia High", color=color.new(color.blue, 45), linewidth=1, style=plot.style_stepline)
plot(asiaLowEnabled ? asiaLow : na, "Asia Low", color=color.new(color.blue, 45), linewidth=1, style=plot.style_stepline)
plot(londonHighEnabled ? londonHigh : na, "London High", color=color.new(color.purple, 45), linewidth=1, style=plot.style_stepline)
plot(londonLowEnabled ? londonLow : na, "London Low", color=color.new(color.purple, 45), linewidth=1, style=plot.style_stepline)
plot(newYorkHighEnabled ? newYorkHigh : na, "New York High", color=color.new(color.aqua, 45), linewidth=1, style=plot.style_stepline)
plot(newYorkLowEnabled ? newYorkLow : na, "New York Low", color=color.new(color.aqua, 45), linewidth=1, style=plot.style_stepline)
plot(overnightHighEnabled ? overnightHigh : na, "Overnight High", color=color.new(color.teal, 35), linewidth=1, style=plot.style_stepline)
plot(overnightLowEnabled ? overnightLow : na, "Overnight Low", color=color.new(color.teal, 35), linewidth=1, style=plot.style_stepline)
plot(asiaOpenEnabled ? asiaOpen : na, "Asia Open", color=color.new(color.blue, 60), linewidth=1, style=plot.style_stepline)
plot(londonOpenEnabled ? londonOpen : na, "London Open", color=color.new(color.purple, 55), linewidth=1, style=plot.style_stepline)
plot(newYorkOpenEnabled ? newYorkOpen : na, "New York Open", color=color.new(color.aqua, 55), linewidth=1, style=plot.style_stepline)

f_manage_open_line(line existingLine, bool enabled, int startTime, float levelPrice, color lineColor) =>
    line outputLine = existingLine
    bool validLine = enabled and not na(startTime) and not na(levelPrice)
    if validLine
        if na(outputLine)
            outputLine := line.new(startTime, levelPrice, time, levelPrice,
                 xloc=xloc.bar_time, extend=extend.right, color=lineColor, width=1, style=line.style_dashed)
        else
            line.set_xy1(outputLine, startTime, levelPrice)
            line.set_xy2(outputLine, time, levelPrice)
            line.set_color(outputLine, lineColor)
    else if not na(outputLine)
        line.delete(outputLine)
        outputLine := na
    outputLine

var line open1800ETLine = na
var line midnightETLine = na
var line open1000ETLine = na
open1800ETLine := f_manage_open_line(open1800ETLine, show1800ETOpen, open1800ETTime, open1800ET, color.new(color.teal, 30))
midnightETLine := f_manage_open_line(midnightETLine, showMidnightETOpen, midnightOpenETTime, midnightOpenET, color.new(color.blue, 30))
open1000ETLine := f_manage_open_line(open1000ETLine, show1000ETOpen, open1000ETTime, open1000ET, color.new(color.orange, 30))

// ───── Structural support / resistance zone engine
f_zone_state(int pivotStrength, int localATRLength, float minimumPaddingATR) =>
    localATR = ta.atr(localATRLength)
    pivotLow = ta.pivotlow(low, pivotStrength, pivotStrength)
    pivotHigh = ta.pivothigh(high, pivotStrength, pivotStrength)

    var float supportTop = na
    var float supportBottom = na
    var float supportVolume = na
    var int supportTime = na

    var float resistanceTop = na
    var float resistanceBottom = na
    var float resistanceVolume = na
    var int resistanceTime = na

    if not na(pivotLow)
        pivotBodyLow = math.min(open[pivotStrength], close[pivotStrength])
        supportBottom := low[pivotStrength]
        supportTop := math.max(pivotBodyLow, supportBottom + localATR[pivotStrength] * minimumPaddingATR)
        supportVolume := showZoneVolume ? volume[pivotStrength] : na
        supportTime := time[pivotStrength]
    else if not na(supportTop)
        bool supportTouching = high >= supportBottom and low <= supportTop
        if close < supportBottom
            supportTop := na
            supportBottom := na
            supportVolume := na
            supportTime := na
        else if showZoneVolume and supportTouching
            supportVolume := nz(supportVolume) + volume

    if not na(pivotHigh)
        pivotBodyHigh = math.max(open[pivotStrength], close[pivotStrength])
        resistanceTop := high[pivotStrength]
        resistanceBottom := math.min(pivotBodyHigh, resistanceTop - localATR[pivotStrength] * minimumPaddingATR)
        resistanceVolume := showZoneVolume ? volume[pivotStrength] : na
        resistanceTime := time[pivotStrength]
    else if not na(resistanceTop)
        bool resistanceTouching = high >= resistanceBottom and low <= resistanceTop
        if close > resistanceTop
            resistanceTop := na
            resistanceBottom := na
            resistanceVolume := na
            resistanceTime := na
        else if showZoneVolume and resistanceTouching
            resistanceVolume := nz(resistanceVolume) + volume

    [supportTop, supportBottom, supportVolume, supportTime,
     resistanceTop, resistanceBottom, resistanceVolume, resistanceTime]

// Chart timeframe
[chartSupTop, chartSupBottom, chartSupVolume, chartSupTime,
 chartResTop, chartResBottom, chartResVolume, chartResTime] =
     f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR)

// Fixed timeframes
[s5Top, s5Bottom, s5Volume, s5Time, r5Top, r5Bottom, r5Volume, r5Time] =
     request.security(syminfo.tickerid, "5",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

[s15Top, s15Bottom, s15Volume, s15Time, r15Top, r15Bottom, r15Volume, r15Time] =
     request.security(syminfo.tickerid, "15",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

[s1hTop, s1hBottom, s1hVolume, s1hTime, r1hTop, r1hBottom, r1hVolume, r1hTime] =
     request.security(syminfo.tickerid, "60",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

[s2hTop, s2hBottom, s2hVolume, s2hTime, r2hTop, r2hBottom, r2hVolume, r2hTime] =
     request.security(syminfo.tickerid, "120",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

[s4hTop, s4hBottom, s4hVolume, s4hTime, r4hTop, r4hBottom, r4hVolume, r4hTime] =
     request.security(syminfo.tickerid, "240",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

[s8hTop, s8hBottom, s8hVolume, s8hTime, r8hTop, r8hBottom, r8hVolume, r8hTime] =
     request.security(syminfo.tickerid, "480",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

[sDTop, sDBottom, sDVolume, sDTime, rDTop, rDBottom, rDVolume, rDTime] =
     request.security(syminfo.tickerid, "1D",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

[sWTop, sWBottom, sWVolume, sWTime, rWTop, rWBottom, rWVolume, rWTime] =
     request.security(syminfo.tickerid, "1W",
         f_zone_state(srPivotStrength, srATRLength, srMinimumPaddingATR),
         lookahead=barmerge.lookahead_off)

// ───── Box helpers
f_zone_label_size() =>
    zoneLabelSize == "Large" ? size.large :
         zoneLabelSize == "Normal" ? size.normal : size.small

zoneTextSize = f_zone_label_size()

f_zone_text(string tfLabel, bool bullishZone, float zoneVolume) =>
    string separator = zoneLabelTwoLines ? "\n" : " "
    string result = showZoneLabels ? tfLabel + separator + (bullishZone ? "SUPPORT" : "RESISTANCE") : ""
    if showZoneVolume and not na(zoneVolume)
        result += (str.length(result) > 0 ? "\n" : "") + "V " + str.tostring(zoneVolume, format.volume)
    result

f_manage_box(box existingBox, bool enabled, int startTime, float topPrice, float bottomPrice,
     color backgroundColor, color borderColor, string boxText) =>
    box outputBox = existingBox
    bool validZone = enabled and not na(startTime) and not na(topPrice) and not na(bottomPrice)

    if validZone
        if na(outputBox)
            outputBox := box.new(left=startTime, top=topPrice, right=time, bottom=bottomPrice,
                 xloc=xloc.bar_time, extend=extend.right,
                 bgcolor=backgroundColor, border_color=borderColor, border_width=zoneBorderWidth,
                 text=boxText, text_color=zoneLabelTextColor, text_size=zoneTextSize,
                 text_halign=text.align_right, text_valign=text.align_center)
        else
            box.set_left(outputBox, startTime)
            box.set_top(outputBox, topPrice)
            box.set_bottom(outputBox, bottomPrice)
            box.set_bgcolor(outputBox, backgroundColor)
            box.set_border_color(outputBox, borderColor)
            box.set_border_width(outputBox, zoneBorderWidth)
            box.set_text(outputBox, boxText)
            box.set_text_color(outputBox, zoneLabelTextColor)
            box.set_text_size(outputBox, zoneTextSize)
    else if not na(outputBox)
        box.delete(outputBox)
        outputBox := na

    outputBox

supportBackground = color.new(color.green, 84)
supportBorder = color.new(color.lime, 35)
resistanceBackground = color.new(color.red, 84)
resistanceBorder = color.new(color.red, 30)

float boxChartSeconds = timeframe.in_seconds()
f_fixed_box_visible(bool enabled, string sourceTimeframe) =>
    float sourceSeconds = timeframe.in_seconds(sourceTimeframe)
    enabled and (not showOnlyChartAndHigherTFBoxes or
         (not na(boxChartSeconds) and not na(sourceSeconds) and sourceSeconds > boxChartSeconds))

bool visible5mSR = f_fixed_box_visible(show5mSR, "5")
bool visible15mSR = f_fixed_box_visible(show15mSR, "15")
bool visible1hSR = f_fixed_box_visible(show1hSR, "60")
bool visible2hSR = f_fixed_box_visible(show2hSR, "120")
bool visible4hSR = f_fixed_box_visible(show4hSR, "240")
bool visible8hSR = f_fixed_box_visible(show8hSR, "480")
bool visibleDailySR = f_fixed_box_visible(showDailySR, "1D")
bool visibleWeeklySR = f_fixed_box_visible(showWeeklySR, "1W")

var box chartSupportBox = na
var box chartResistanceBox = na
var box support5mBox = na
var box resistance5mBox = na
var box support15mBox = na
var box resistance15mBox = na
var box support1hBox = na
var box resistance1hBox = na
var box support2hBox = na
var box resistance2hBox = na
var box support4hBox = na
var box resistance4hBox = na
var box support8hBox = na
var box resistance8hBox = na
var box supportDailyBox = na
var box resistanceDailyBox = na
var box supportWeeklyBox = na
var box resistanceWeeklyBox = na

chartSupportBox := f_manage_box(chartSupportBox, showChartSR, chartSupTime, chartSupTop, chartSupBottom,
     supportBackground, supportBorder, f_zone_text(timeframe.period, true, chartSupVolume))
chartResistanceBox := f_manage_box(chartResistanceBox, showChartSR, chartResTime, chartResTop, chartResBottom,
     resistanceBackground, resistanceBorder, f_zone_text(timeframe.period, false, chartResVolume))

support5mBox := f_manage_box(support5mBox, visible5mSR, s5Time, s5Top, s5Bottom,
     supportBackground, supportBorder, f_zone_text("5m", true, s5Volume))
resistance5mBox := f_manage_box(resistance5mBox, visible5mSR, r5Time, r5Top, r5Bottom,
     resistanceBackground, resistanceBorder, f_zone_text("5m", false, r5Volume))

support15mBox := f_manage_box(support15mBox, visible15mSR, s15Time, s15Top, s15Bottom,
     supportBackground, supportBorder, f_zone_text("15m", true, s15Volume))
resistance15mBox := f_manage_box(resistance15mBox, visible15mSR, r15Time, r15Top, r15Bottom,
     resistanceBackground, resistanceBorder, f_zone_text("15m", false, r15Volume))

support1hBox := f_manage_box(support1hBox, visible1hSR, s1hTime, s1hTop, s1hBottom,
     supportBackground, supportBorder, f_zone_text("1H", true, s1hVolume))
resistance1hBox := f_manage_box(resistance1hBox, visible1hSR, r1hTime, r1hTop, r1hBottom,
     resistanceBackground, resistanceBorder, f_zone_text("1H", false, r1hVolume))

support2hBox := f_manage_box(support2hBox, visible2hSR, s2hTime, s2hTop, s2hBottom,
     supportBackground, supportBorder, f_zone_text("2H", true, s2hVolume))
resistance2hBox := f_manage_box(resistance2hBox, visible2hSR, r2hTime, r2hTop, r2hBottom,
     resistanceBackground, resistanceBorder, f_zone_text("2H", false, r2hVolume))

support4hBox := f_manage_box(support4hBox, visible4hSR, s4hTime, s4hTop, s4hBottom,
     supportBackground, supportBorder, f_zone_text("4H", true, s4hVolume))
resistance4hBox := f_manage_box(resistance4hBox, visible4hSR, r4hTime, r4hTop, r4hBottom,
     resistanceBackground, resistanceBorder, f_zone_text("4H", false, r4hVolume))

support8hBox := f_manage_box(support8hBox, visible8hSR, s8hTime, s8hTop, s8hBottom,
     supportBackground, supportBorder, f_zone_text("8H", true, s8hVolume))
resistance8hBox := f_manage_box(resistance8hBox, visible8hSR, r8hTime, r8hTop, r8hBottom,
     resistanceBackground, resistanceBorder, f_zone_text("8H", false, r8hVolume))

supportDailyBox := f_manage_box(supportDailyBox, visibleDailySR, sDTime, sDTop, sDBottom,
     supportBackground, supportBorder, f_zone_text("D", true, sDVolume))
resistanceDailyBox := f_manage_box(resistanceDailyBox, visibleDailySR, rDTime, rDTop, rDBottom,
     resistanceBackground, resistanceBorder, f_zone_text("D", false, rDVolume))

supportWeeklyBox := f_manage_box(supportWeeklyBox, visibleWeeklySR, sWTime, sWTop, sWBottom,
     supportBackground, supportBorder, f_zone_text("W", true, sWVolume))
resistanceWeeklyBox := f_manage_box(resistanceWeeklyBox, visibleWeeklySR, rWTime, rWTop, rWBottom,
     resistanceBackground, resistanceBorder, f_zone_text("W", false, rWVolume))

// ───── Reaction logic at a zone
// Clean behavior: bullish reactions must close above support; bearish reactions
// must close below resistance. A candle touching or remaining inside a box is
// not enough to confirm a defense.
f_bull_at_zone(float zoneTop, float zoneBottom) =>
    valid = not na(zoneTop) and not na(zoneBottom)
    touched = valid and high >= zoneBottom and low <= zoneTop
    sweepReclaim = valid and low < zoneBottom and close > zoneTop and bullReactionCandle
    bullishHold = touched and close > zoneTop and close[1] > zoneTop and close > open
    bullishReclaim = valid and close > zoneTop and close[1] <= zoneTop and bullReactionCandle
    bullishReject = touched and close > zoneTop and bullRejectCandle
    bullishImpulse = touched and close > zoneTop and (bullDisplacement or bullMicroShift or bullVolumeReaction)
    sweepReclaim or bullishHold or bullishReclaim or bullishReject or bullishImpulse

f_bear_at_zone(float zoneTop, float zoneBottom) =>
    valid = not na(zoneTop) and not na(zoneBottom)
    touched = valid and high >= zoneBottom and low <= zoneTop
    sweepReclaim = valid and high > zoneTop and close < zoneBottom and bearReactionCandle
    bearishHold = touched and close < zoneBottom and close[1] < zoneBottom and close < open
    bearishReclaim = valid and close < zoneBottom and close[1] >= zoneBottom and bearReactionCandle
    bearishReject = touched and close < zoneBottom and bearRejectCandle
    bearishImpulse = touched and close < zoneBottom and (bearDisplacement or bearMicroShift or bearVolumeReaction)
    sweepReclaim or bearishHold or bearishReclaim or bearishReject or bearishImpulse

// ───── Layered box reaction engine
f_pretty_timeframe(string sourceTimeframe) =>
    switch sourceTimeframe
        "1" => "1M"
        "2" => "2M"
        "3" => "3M"
        "5" => "5M"
        "10" => "10M"
        "15" => "15M"
        "30" => "30M"
        "45" => "45M"
        "60" => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "480" => "8H"
        "1D" => "D"
        "1W" => "W"
        => sourceTimeframe

var array<int> reactionZoneIds = array.new_int(18, na)
var array<bool> reactionInitialSeen = array.new_bool(18, false)

f_process_box_reaction(int slot, bool enabled, int zoneId, float zoneTop, float zoneBottom,
     bool bullishSide, bool reactionConfirmed) =>
    bool initialSignal = false
    bool validZone = enabled and not na(zoneId) and not na(zoneTop) and not na(zoneBottom)
    int storedZoneId = array.get(reactionZoneIds, slot)

    if not validZone
        array.set(reactionZoneIds, slot, na)
        array.set(reactionInitialSeen, slot, false)
    else
        bool zoneChanged = na(storedZoneId) or zoneId != storedZoneId
        if zoneChanged
            array.set(reactionZoneIds, slot, zoneId)
            array.set(reactionInitialSeen, slot, false)

        bool initialSeen = array.get(reactionInitialSeen, slot)
        bool invalidated = bullishSide ? close < zoneBottom : close > zoneTop

        if invalidated
            initialSeen := false
        else if reactionConfirmed and not initialSeen
            initialSignal := true
            initialSeen := true

        array.set(reactionInitialSeen, slot, initialSeen)

    initialSignal

bool reactionBarConfirmed = not confirmOnClose or barstate.isconfirmed

bool chartSupportReactionRaw = reactionBarConfirmed and showChartSR and f_bull_at_zone(chartSupTop, chartSupBottom)
bool chartResistanceReactionRaw = reactionBarConfirmed and showChartSR and f_bear_at_zone(chartResTop, chartResBottom)
bool support5mReactionRaw = reactionBarConfirmed and visible5mSR and f_bull_at_zone(s5Top, s5Bottom)
bool resistance5mReactionRaw = reactionBarConfirmed and visible5mSR and f_bear_at_zone(r5Top, r5Bottom)
bool support15mReactionRaw = reactionBarConfirmed and visible15mSR and f_bull_at_zone(s15Top, s15Bottom)
bool resistance15mReactionRaw = reactionBarConfirmed and visible15mSR and f_bear_at_zone(r15Top, r15Bottom)
bool support1hReactionRaw = reactionBarConfirmed and visible1hSR and f_bull_at_zone(s1hTop, s1hBottom)
bool resistance1hReactionRaw = reactionBarConfirmed and visible1hSR and f_bear_at_zone(r1hTop, r1hBottom)
bool support2hReactionRaw = reactionBarConfirmed and visible2hSR and f_bull_at_zone(s2hTop, s2hBottom)
bool resistance2hReactionRaw = reactionBarConfirmed and visible2hSR and f_bear_at_zone(r2hTop, r2hBottom)
bool support4hReactionRaw = reactionBarConfirmed and visible4hSR and f_bull_at_zone(s4hTop, s4hBottom)
bool resistance4hReactionRaw = reactionBarConfirmed and visible4hSR and f_bear_at_zone(r4hTop, r4hBottom)
bool support8hReactionRaw = reactionBarConfirmed and visible8hSR and f_bull_at_zone(s8hTop, s8hBottom)
bool resistance8hReactionRaw = reactionBarConfirmed and visible8hSR and f_bear_at_zone(r8hTop, r8hBottom)
bool supportDReactionRaw = reactionBarConfirmed and visibleDailySR and f_bull_at_zone(sDTop, sDBottom)
bool resistanceDReactionRaw = reactionBarConfirmed and visibleDailySR and f_bear_at_zone(rDTop, rDBottom)
bool supportWReactionRaw = reactionBarConfirmed and visibleWeeklySR and f_bull_at_zone(sWTop, sWBottom)
bool resistanceWReactionRaw = reactionBarConfirmed and visibleWeeklySR and f_bear_at_zone(rWTop, rWBottom)

chartSupportInitial = f_process_box_reaction(0, showChartSR, chartSupTime, chartSupTop, chartSupBottom, true, chartSupportReactionRaw)
chartResistanceInitial = f_process_box_reaction(1, showChartSR, chartResTime, chartResTop, chartResBottom, false, chartResistanceReactionRaw)
support5mInitial = f_process_box_reaction(2, visible5mSR, s5Time, s5Top, s5Bottom, true, support5mReactionRaw)
resistance5mInitial = f_process_box_reaction(3, visible5mSR, r5Time, r5Top, r5Bottom, false, resistance5mReactionRaw)
support15mInitial = f_process_box_reaction(4, visible15mSR, s15Time, s15Top, s15Bottom, true, support15mReactionRaw)
resistance15mInitial = f_process_box_reaction(5, visible15mSR, r15Time, r15Top, r15Bottom, false, resistance15mReactionRaw)
support1hInitial = f_process_box_reaction(6, visible1hSR, s1hTime, s1hTop, s1hBottom, true, support1hReactionRaw)
resistance1hInitial = f_process_box_reaction(7, visible1hSR, r1hTime, r1hTop, r1hBottom, false, resistance1hReactionRaw)
support2hInitial = f_process_box_reaction(8, visible2hSR, s2hTime, s2hTop, s2hBottom, true, support2hReactionRaw)
resistance2hInitial = f_process_box_reaction(9, visible2hSR, r2hTime, r2hTop, r2hBottom, false, resistance2hReactionRaw)
support4hInitial = f_process_box_reaction(10, visible4hSR, s4hTime, s4hTop, s4hBottom, true, support4hReactionRaw)
resistance4hInitial = f_process_box_reaction(11, visible4hSR, r4hTime, r4hTop, r4hBottom, false, resistance4hReactionRaw)
support8hInitial = f_process_box_reaction(12, visible8hSR, s8hTime, s8hTop, s8hBottom, true, support8hReactionRaw)
resistance8hInitial = f_process_box_reaction(13, visible8hSR, r8hTime, r8hTop, r8hBottom, false, resistance8hReactionRaw)
supportDInitial = f_process_box_reaction(14, visibleDailySR, sDTime, sDTop, sDBottom, true, supportDReactionRaw)
resistanceDInitial = f_process_box_reaction(15, visibleDailySR, rDTime, rDTop, rDBottom, false, resistanceDReactionRaw)
supportWInitial = f_process_box_reaction(16, visibleWeeklySR, sWTime, sWTop, sWBottom, true, supportWReactionRaw)
resistanceWInitial = f_process_box_reaction(17, visibleWeeklySR, rWTime, rWTop, rWBottom, false, resistanceWReactionRaw)

float reactionChartSeconds = timeframe.in_seconds()
bool chartIsOneMinute = reactionChartSeconds == 60
bool executionChartAllowed = chartIsOneMinute

// ───── Bias-only dashboard data
f_bias_pair() =>
    float localEMA = ta.ema(close, biasEMALength)
    [useConfirmedBias ? close[1] : close, useConfirmedBias ? localEMA[1] : localEMA]

[biasClose1m, biasEMA1m] = request.security(syminfo.tickerid, "1",
     f_bias_pair(), lookahead=barmerge.lookahead_off)
[biasClose5m, biasEMA5m] = request.security(syminfo.tickerid, "5",
     f_bias_pair(), lookahead=barmerge.lookahead_off)
[biasClose15m, biasEMA15m] = request.security(syminfo.tickerid, "15",
     f_bias_pair(), lookahead=barmerge.lookahead_off)
[biasClose1h, biasEMA1h] = request.security(syminfo.tickerid, "60",
     f_bias_pair(), lookahead=barmerge.lookahead_off)
[biasClose2h, biasEMA2h] = request.security(syminfo.tickerid, "120",
     f_bias_pair(), lookahead=barmerge.lookahead_off)
[biasClose4h, biasEMA4h] = request.security(syminfo.tickerid, "240",
     f_bias_pair(), lookahead=barmerge.lookahead_off)
[biasCloseDaily, biasEMADaily] = request.security(syminfo.tickerid, "1D",
     f_bias_pair(), lookahead=barmerge.lookahead_off)

bias1mBull = biasClose1m >= biasEMA1m
bias5Bull = biasClose5m >= biasEMA5m
bias15Bull = biasClose15m >= biasEMA15m
bias1hBull = biasClose1h >= biasEMA1h
bias2hBull = biasClose2h >= biasEMA2h
bias4hBull = biasClose4h >= biasEMA4h
biasDailyBull = biasCloseDaily >= biasEMADaily

chartBiasEMA = ta.ema(close, biasEMALength)
chartBiasClose = useConfirmedBias ? close[1] : close
chartBiasEMAValue = useConfirmedBias ? chartBiasEMA[1] : chartBiasEMA
chartBiasBull = chartBiasClose >= chartBiasEMAValue
chartBiasSeconds = timeframe.in_seconds()
chartBiasAlreadyListed = not na(chartBiasSeconds) and
     (chartBiasSeconds == 60 or chartBiasSeconds == 300 or chartBiasSeconds == 900 or
      chartBiasSeconds == 3600 or chartBiasSeconds == 7200 or chartBiasSeconds == 14400 or
      chartBiasSeconds == 86400)
showDynamicChartBiasRow = showDynamicChartBias and not chartBiasAlreadyListed

f_chart_bias_label() =>
    string chartLabel = timeframe.period
    if timeframe.isseconds
        chartLabel := str.tostring(timeframe.multiplier) + "s"
    else if timeframe.isminutes
        chartLabel := timeframe.multiplier % 60 == 0 ?
             str.tostring(int(timeframe.multiplier / 60)) + "H" :
             str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isdaily
        chartLabel := timeframe.multiplier == 1 ? "D" : str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        chartLabel := timeframe.multiplier == 1 ? "W" : str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        chartLabel := timeframe.multiplier == 1 ? "M" : str.tostring(timeframe.multiplier) + "M"
    chartLabel

chartBiasLabel = f_chart_bias_label()

f_bias_text(bool bullish) =>
    bullish ? "BULLISH" : "BEARISH"

f_bias_color(bool bullish) =>
    bullish ? color.new(color.green, 10) : color.new(color.red, 10)

selectedMajorityBiasCount =
     (countBias5m ? 1 : 0) +
     (countBias15m ? 1 : 0) +
     (countBias1h ? 1 : 0) +
     (countBias2h ? 1 : 0) +
     (countBias4h ? 1 : 0) +
     (countBiasDaily ? 1 : 0)

bullMajorityBiasCount =
     (countBias5m and bias5Bull ? 1 : 0) +
     (countBias15m and bias15Bull ? 1 : 0) +
     (countBias1h and bias1hBull ? 1 : 0) +
     (countBias2h and bias2hBull ? 1 : 0) +
     (countBias4h and bias4hBull ? 1 : 0) +
     (countBiasDaily and biasDailyBull ? 1 : 0)

bearMajorityBiasCount =
     (countBias5m and not bias5Bull ? 1 : 0) +
     (countBias15m and not bias15Bull ? 1 : 0) +
     (countBias1h and not bias1hBull ? 1 : 0) +
     (countBias2h and not bias2hBull ? 1 : 0) +
     (countBias4h and not bias4hBull ? 1 : 0) +
     (countBiasDaily and not biasDailyBull ? 1 : 0)

requiredMajorityBiasCount = math.min(minimumMajorityBiases, math.max(selectedMajorityBiasCount, 1))
majorityLongBias = selectedMajorityBiasCount > 0 and bullMajorityBiasCount >= requiredMajorityBiasCount and
     bullMajorityBiasCount > bearMajorityBiasCount
majorityShortBias = selectedMajorityBiasCount > 0 and bearMajorityBiasCount >= requiredMajorityBiasCount and
     bearMajorityBiasCount > bullMajorityBiasCount

// ───── Structure AMD engine
// This engine does not create new structure. It reads only the existing active
// support/resistance boxes and their already-confirmed reactions.
//
// A / RANGE  = active support and resistance contain price without delivery.
// M LOW      = a selected support box is swept and reclaimed.
// M HIGH     = a selected resistance box is swept and rejected.
// D BULL     = support was defended, then selected resistance breaks with expansion.
// D BEAR     = resistance was defended, then selected support breaks with expansion.
//
// Nothing in this section is referenced by EZ$L / EZ$S / OTE or alerts.
bool structureUseInternalBoxes = structureAMDBoxScope != "Chart Only"
bool structureUseAllVisibleHTF = structureAMDBoxScope == "Chart + Visible HTF"

bool structureChartEnabled = showChartSR
bool structure5mEnabled = structureUseInternalBoxes and visible5mSR
bool structure15mEnabled = structureUseInternalBoxes and visible15mSR
bool structure1hEnabled = structureUseAllVisibleHTF and visible1hSR
bool structure2hEnabled = structureUseAllVisibleHTF and visible2hSR
bool structure4hEnabled = structureUseAllVisibleHTF and visible4hSR
bool structure8hEnabled = structureUseAllVisibleHTF and visible8hSR
bool structureDailyEnabled = structureUseAllVisibleHTF and visibleDailySR
bool structureWeeklyEnabled = structureUseAllVisibleHTF and visibleWeeklySR

f_structure_zone_exists(bool enabled, float zoneTop, float zoneBottom) =>
    enabled and not na(zoneTop) and not na(zoneBottom)

f_structure_bull_sweep(bool enabled, float zoneTop, float zoneBottom) =>
    f_structure_zone_exists(enabled, zoneTop, zoneBottom) and
         low < zoneBottom and close > zoneTop and bullReactionCandle

f_structure_bear_sweep(bool enabled, float zoneTop, float zoneBottom) =>
    f_structure_zone_exists(enabled, zoneTop, zoneBottom) and
         high > zoneTop and close < zoneBottom and bearReactionCandle

f_structure_bull_break(bool enabled, float priorZoneTop) =>
    enabled and not na(priorZoneTop) and close > priorZoneTop and close[1] <= priorZoneTop

f_structure_bear_break(bool enabled, float priorZoneBottom) =>
    enabled and not na(priorZoneBottom) and close < priorZoneBottom and close[1] >= priorZoneBottom

bool structureSupportExists =
     f_structure_zone_exists(structureChartEnabled, chartSupTop, chartSupBottom) or
     f_structure_zone_exists(structure5mEnabled, s5Top, s5Bottom) or
     f_structure_zone_exists(structure15mEnabled, s15Top, s15Bottom) or
     f_structure_zone_exists(structure1hEnabled, s1hTop, s1hBottom) or
     f_structure_zone_exists(structure2hEnabled, s2hTop, s2hBottom) or
     f_structure_zone_exists(structure4hEnabled, s4hTop, s4hBottom) or
     f_structure_zone_exists(structure8hEnabled, s8hTop, s8hBottom) or
     f_structure_zone_exists(structureDailyEnabled, sDTop, sDBottom) or
     f_structure_zone_exists(structureWeeklyEnabled, sWTop, sWBottom)

bool structureResistanceExists =
     f_structure_zone_exists(structureChartEnabled, chartResTop, chartResBottom) or
     f_structure_zone_exists(structure5mEnabled, r5Top, r5Bottom) or
     f_structure_zone_exists(structure15mEnabled, r15Top, r15Bottom) or
     f_structure_zone_exists(structure1hEnabled, r1hTop, r1hBottom) or
     f_structure_zone_exists(structure2hEnabled, r2hTop, r2hBottom) or
     f_structure_zone_exists(structure4hEnabled, r4hTop, r4hBottom) or
     f_structure_zone_exists(structure8hEnabled, r8hTop, r8hBottom) or
     f_structure_zone_exists(structureDailyEnabled, rDTop, rDBottom) or
     f_structure_zone_exists(structureWeeklyEnabled, rWTop, rWBottom)

bool structureSupportContext =
     (f_structure_zone_exists(structureChartEnabled, chartSupTop, chartSupBottom) and close >= chartSupBottom) or
     (f_structure_zone_exists(structure5mEnabled, s5Top, s5Bottom) and close >= s5Bottom) or
     (f_structure_zone_exists(structure15mEnabled, s15Top, s15Bottom) and close >= s15Bottom) or
     (f_structure_zone_exists(structure1hEnabled, s1hTop, s1hBottom) and close >= s1hBottom) or
     (f_structure_zone_exists(structure2hEnabled, s2hTop, s2hBottom) and close >= s2hBottom) or
     (f_structure_zone_exists(structure4hEnabled, s4hTop, s4hBottom) and close >= s4hBottom) or
     (f_structure_zone_exists(structure8hEnabled, s8hTop, s8hBottom) and close >= s8hBottom) or
     (f_structure_zone_exists(structureDailyEnabled, sDTop, sDBottom) and close >= sDBottom) or
     (f_structure_zone_exists(structureWeeklyEnabled, sWTop, sWBottom) and close >= sWBottom)

bool structureResistanceContext =
     (f_structure_zone_exists(structureChartEnabled, chartResTop, chartResBottom) and close <= chartResTop) or
     (f_structure_zone_exists(structure5mEnabled, r5Top, r5Bottom) and close <= r5Top) or
     (f_structure_zone_exists(structure15mEnabled, r15Top, r15Bottom) and close <= r15Top) or
     (f_structure_zone_exists(structure1hEnabled, r1hTop, r1hBottom) and close <= r1hTop) or
     (f_structure_zone_exists(structure2hEnabled, r2hTop, r2hBottom) and close <= r2hTop) or
     (f_structure_zone_exists(structure4hEnabled, r4hTop, r4hBottom) and close <= r4hTop) or
     (f_structure_zone_exists(structure8hEnabled, r8hTop, r8hBottom) and close <= r8hTop) or
     (f_structure_zone_exists(structureDailyEnabled, rDTop, rDBottom) and close <= rDTop) or
     (f_structure_zone_exists(structureWeeklyEnabled, rWTop, rWBottom) and close <= rWTop)

bool structureBalancedRange = structureSupportContext and structureResistanceContext

bool structureSupportDefense =
     (structureChartEnabled and chartSupportInitial) or
     (structure5mEnabled and support5mInitial) or
     (structure15mEnabled and support15mInitial) or
     (structure1hEnabled and support1hInitial) or
     (structure2hEnabled and support2hInitial) or
     (structure4hEnabled and support4hInitial) or
     (structure8hEnabled and support8hInitial) or
     (structureDailyEnabled and supportDInitial) or
     (structureWeeklyEnabled and supportWInitial)

bool structureResistanceDefense =
     (structureChartEnabled and chartResistanceInitial) or
     (structure5mEnabled and resistance5mInitial) or
     (structure15mEnabled and resistance15mInitial) or
     (structure1hEnabled and resistance1hInitial) or
     (structure2hEnabled and resistance2hInitial) or
     (structure4hEnabled and resistance4hInitial) or
     (structure8hEnabled and resistance8hInitial) or
     (structureDailyEnabled and resistanceDInitial) or
     (structureWeeklyEnabled and resistanceWInitial)

bool structureBullManipulation =
     f_structure_bull_sweep(structureChartEnabled, chartSupTop, chartSupBottom) or
     f_structure_bull_sweep(structure5mEnabled, s5Top, s5Bottom) or
     f_structure_bull_sweep(structure15mEnabled, s15Top, s15Bottom) or
     f_structure_bull_sweep(structure1hEnabled, s1hTop, s1hBottom) or
     f_structure_bull_sweep(structure2hEnabled, s2hTop, s2hBottom) or
     f_structure_bull_sweep(structure4hEnabled, s4hTop, s4hBottom) or
     f_structure_bull_sweep(structure8hEnabled, s8hTop, s8hBottom) or
     f_structure_bull_sweep(structureDailyEnabled, sDTop, sDBottom) or
     f_structure_bull_sweep(structureWeeklyEnabled, sWTop, sWBottom)

bool structureBearManipulation =
     f_structure_bear_sweep(structureChartEnabled, chartResTop, chartResBottom) or
     f_structure_bear_sweep(structure5mEnabled, r5Top, r5Bottom) or
     f_structure_bear_sweep(structure15mEnabled, r15Top, r15Bottom) or
     f_structure_bear_sweep(structure1hEnabled, r1hTop, r1hBottom) or
     f_structure_bear_sweep(structure2hEnabled, r2hTop, r2hBottom) or
     f_structure_bear_sweep(structure4hEnabled, r4hTop, r4hBottom) or
     f_structure_bear_sweep(structure8hEnabled, r8hTop, r8hBottom) or
     f_structure_bear_sweep(structureDailyEnabled, rDTop, rDBottom) or
     f_structure_bear_sweep(structureWeeklyEnabled, rWTop, rWBottom)

bool structureResistanceBreak =
     f_structure_bull_break(structureChartEnabled, chartResTop[1]) or
     f_structure_bull_break(structure5mEnabled, r5Top[1]) or
     f_structure_bull_break(structure15mEnabled, r15Top[1]) or
     f_structure_bull_break(structure1hEnabled, r1hTop[1]) or
     f_structure_bull_break(structure2hEnabled, r2hTop[1]) or
     f_structure_bull_break(structure4hEnabled, r4hTop[1]) or
     f_structure_bull_break(structure8hEnabled, r8hTop[1]) or
     f_structure_bull_break(structureDailyEnabled, rDTop[1]) or
     f_structure_bull_break(structureWeeklyEnabled, rWTop[1])

bool structureSupportBreak =
     f_structure_bear_break(structureChartEnabled, chartSupBottom[1]) or
     f_structure_bear_break(structure5mEnabled, s5Bottom[1]) or
     f_structure_bear_break(structure15mEnabled, s15Bottom[1]) or
     f_structure_bear_break(structure1hEnabled, s1hBottom[1]) or
     f_structure_bear_break(structure2hEnabled, s2hBottom[1]) or
     f_structure_bear_break(structure4hEnabled, s4hBottom[1]) or
     f_structure_bear_break(structure8hEnabled, s8hBottom[1]) or
     f_structure_bear_break(structureDailyEnabled, sDBottom[1]) or
     f_structure_bear_break(structureWeeklyEnabled, sWBottom[1])

bool structureBullExpansion = bullDisplacement or (close > open and bullMicroShift)
bool structureBearExpansion = bearDisplacement or (close < open and bearMicroShift)

var int structureAMDPhase = 0
var int structureAMDContextBar = na
var bool structureBullArmed = false
var bool structureBearArmed = false

if reactionBarConfirmed
    bool structureContextExpired = not na(structureAMDContextBar) and
         bar_index - structureAMDContextBar > structureAMDMaximumAgeBars

    if structureContextExpired
        structureAMDPhase := 0
        structureAMDContextBar := na
        structureBullArmed := false
        structureBearArmed := false

    if structureSupportDefense and structureResistanceDefense
        // Both sides defended on the same confirmed bar: price is still balancing.
        structureAMDPhase := 0
        structureBullArmed := false
        structureBearArmed := false
        structureAMDContextBar := bar_index
    else if structureSupportDefense
        // A fresh support defense interrupts an active bearish delivery.
        if structureAMDPhase < 0
            structureAMDPhase := 0
        structureBullArmed := true
        structureBearArmed := false
        structureAMDContextBar := bar_index
    else if structureResistanceDefense
        // A fresh resistance defense interrupts an active bullish delivery.
        if structureAMDPhase > 0
            structureAMDPhase := 0
        structureBearArmed := true
        structureBullArmed := false
        structureAMDContextBar := bar_index

    if structureBullManipulation and not structureBearManipulation
        structureAMDPhase := 1
        structureBullArmed := true
        structureBearArmed := false
        structureAMDContextBar := bar_index
    else if structureBearManipulation and not structureBullManipulation
        structureAMDPhase := -1
        structureBearArmed := true
        structureBullArmed := false
        structureAMDContextBar := bar_index
    else if structureBullManipulation and structureBearManipulation
        structureAMDPhase := close >= open ? 1 : -1
        structureBullArmed := close >= open
        structureBearArmed := close < open
        structureAMDContextBar := bar_index

    bool structureBullDistribution = structureResistanceBreak and structureBullArmed and
         (not structureAMDRequireExpansion or structureBullExpansion)
    bool structureBearDistribution = structureSupportBreak and structureBearArmed and
         (not structureAMDRequireExpansion or structureBearExpansion)

    if structureBullDistribution and not structureBearDistribution
        structureAMDPhase := 2
        structureBullArmed := true
        structureBearArmed := false
        structureAMDContextBar := bar_index
    else if structureBearDistribution and not structureBullDistribution
        structureAMDPhase := -2
        structureBearArmed := true
        structureBullArmed := false
        structureAMDContextBar := bar_index
    else if structureBullDistribution and structureBearDistribution
        structureAMDPhase := close >= open ? 2 : -2
        structureBullArmed := close >= open
        structureBearArmed := close < open
        structureAMDContextBar := bar_index
    else
        bool bullishContextFailed = structureAMDPhase > 0 and structureSupportBreak and structureBearExpansion
        bool bearishContextFailed = structureAMDPhase < 0 and structureResistanceBreak and structureBullExpansion
        if bullishContextFailed or bearishContextFailed
            structureAMDPhase := 0
            structureAMDContextBar := bar_index
            structureBullArmed := false
            structureBearArmed := false

bool structureAMDValid = structureSupportExists or structureResistanceExists or structureAMDPhase != 0

f_structure_amd_phase_text(int phase, bool validPhase, bool balancedRange) =>
    not validPhase ? "N/A" :
         phase == 2 ? "D BULL" :
         phase == -2 ? "D BEAR" :
         phase == 1 ? "M LOW" :
         phase == -1 ? "M HIGH" :
         balancedRange ? "A / RANGE" : "A / WAIT"

f_structure_amd_phase_color(int phase, bool validPhase) =>
    not validPhase ? color.new(color.gray, 55) :
         phase == 2 ? color.new(color.green, 12) :
         phase == -2 ? color.new(color.red, 12) :
         phase == 1 ? color.new(color.aqua, 35) :
         phase == -1 ? color.new(color.purple, 30) : color.new(color.yellow, 45)

// ───── Single live-validity EZ$L / EZ$S engine
// The current 1-minute chart S/R box is the only entry source. A first confirmed
// defense creates the marker. The marker remains while that exact box remains
// current and valid, and is deleted after a confirmed close through the far edge,
// a box replacement, the indicator being disabled, or an opposite setup.
bool barReady = reactionBarConfirmed
bool optimalSignalsEnabled = optimalSignalDisplay != "Off"

bool entryLongSignal = barReady and optimalSignalsEnabled and executionChartAllowed and
     showChartSR and chartSupportInitial and not chartResistanceInitial
bool entryShortSignal = barReady and optimalSignalsEnabled and executionChartAllowed and
     showChartSR and chartResistanceInitial and not chartSupportInitial

var label activeEZLongLabel = na
var label activeEZShortLabel = na
var int activeEZLongZoneId = na
var int activeEZShortZoneId = na
var float activeEZLongZoneBottom = na
var float activeEZShortZoneTop = na

bool activeLongZoneChanged = not na(activeEZLongLabel) and
     (na(chartSupTime) or chartSupTime != activeEZLongZoneId)
bool activeShortZoneChanged = not na(activeEZShortLabel) and
     (na(chartResTime) or chartResTime != activeEZShortZoneId)
bool activeLongBoxFailed = not na(activeEZLongLabel) and barReady and
     (na(activeEZLongZoneBottom) or close < activeEZLongZoneBottom)
bool activeShortBoxFailed = not na(activeEZShortLabel) and barReady and
     (na(activeEZShortZoneTop) or close > activeEZShortZoneTop)

bool activeLongInvalidated = not na(activeEZLongLabel) and
     (not optimalSignalsEnabled or not executionChartAllowed or activeLongZoneChanged or activeLongBoxFailed)
bool activeShortInvalidated = not na(activeEZShortLabel) and
     (not optimalSignalsEnabled or not executionChartAllowed or activeShortZoneChanged or activeShortBoxFailed)

if activeLongInvalidated
    label.delete(activeEZLongLabel)
    activeEZLongLabel := na
    activeEZLongZoneId := na
    activeEZLongZoneBottom := na

if activeShortInvalidated
    label.delete(activeEZShortLabel)
    activeEZShortLabel := na
    activeEZShortZoneId := na
    activeEZShortZoneTop := na

if entryLongSignal
    if not na(activeEZLongLabel)
        label.delete(activeEZLongLabel)
    if not na(activeEZShortLabel)
        label.delete(activeEZShortLabel)
    activeEZShortLabel := na
    activeEZShortZoneId := na
    activeEZShortZoneTop := na
    activeEZLongLabel := label.new(bar_index, low, "EZ$L",
         style=label.style_label_up, color=color.new(color.green, 0),
         textcolor=color.white, size=size.small)
    activeEZLongZoneId := chartSupTime
    activeEZLongZoneBottom := chartSupBottom

if entryShortSignal
    if not na(activeEZShortLabel)
        label.delete(activeEZShortLabel)
    if not na(activeEZLongLabel)
        label.delete(activeEZLongLabel)
    activeEZLongLabel := na
    activeEZLongZoneId := na
    activeEZLongZoneBottom := na
    activeEZShortLabel := label.new(bar_index, high, "EZ$S",
         style=label.style_label_down, color=color.new(color.red, 0),
         textcolor=color.white, size=size.small)
    activeEZShortZoneId := chartResTime
    activeEZShortZoneTop := chartResTop

alertcondition(entryLongSignal, "EZ$ Live Long",
     "EZ$L: the active 1-minute support box confirmed its first defense on {{ticker}} {{interval}}.")
alertcondition(entryShortSignal, "EZ$ Live Short",
     "EZ$S: the active 1-minute resistance box confirmed its first defense on {{ticker}} {{interval}}.")
alertcondition(activeLongInvalidated, "EZ$ Long Invalidated",
     "The active EZ$L support-box setup was invalidated or replaced on {{ticker}} {{interval}}.")
alertcondition(activeShortInvalidated, "EZ$ Short Invalidated",
     "The active EZ$S resistance-box setup was invalidated or replaced on {{ticker}} {{interval}}.")

// ───── Visual OTE entry refinement
// A new live EZ$L / EZ$S marker arms the optional OTE. The signal itself remains
// independent; OTE waits for an impulse and then freezes after the first meaningful
// retracement. It is limited to the 1-minute chart.
bool oteChartAllowed = chartIsOneMinute
bool newOTELong = showVisualOTE and oteChartAllowed and entryLongSignal and not entryShortSignal
bool newOTEShort = showVisualOTE and oteChartAllowed and entryShortSignal and not entryLongSignal

var int oteDirection = 0
var int oteSetupBar = na
var int oteExtremeBar = na
var float oteAnchorPrice = na
var float oteExtremePrice = na
var bool oteImpulseConfirmed = false
var bool oteLocked = false
var bool oteZoneVisited = false
var int oteVisitBar = na

var box oteZoneBox = na
var line oteEquilibriumLine = na
var line ote62Line = na
var line ote705Line = na
var line ote79Line = na
var label oteEntryLabel = na

bool resetOTE = not showVisualOTE or not oteChartAllowed or newOTELong or newOTEShort

if resetOTE
    if not na(oteZoneBox)
        box.delete(oteZoneBox)
        oteZoneBox := na
    if not na(oteEquilibriumLine)
        line.delete(oteEquilibriumLine)
        oteEquilibriumLine := na
    if not na(ote62Line)
        line.delete(ote62Line)
        ote62Line := na
    if not na(ote705Line)
        line.delete(ote705Line)
        ote705Line := na
    if not na(ote79Line)
        line.delete(ote79Line)
        ote79Line := na
    if not na(oteEntryLabel)
        label.delete(oteEntryLabel)
        oteEntryLabel := na

    oteDirection := 0
    oteSetupBar := na
    oteExtremeBar := na
    oteAnchorPrice := na
    oteExtremePrice := na
    oteImpulseConfirmed := false
    oteLocked := false
    oteZoneVisited := false
    oteVisitBar := na

if newOTELong or newOTEShort
    oteDirection := newOTELong ? 1 : -1
    oteSetupBar := bar_index
    oteExtremeBar := bar_index
    oteAnchorPrice := newOTELong ? low : high
    oteExtremePrice := newOTELong ? high : low
    oteImpulseConfirmed := false
    oteLocked := false
    oteZoneVisited := false
    oteVisitBar := na

if showVisualOTE and oteChartAllowed and oteDirection != 0
    bool oteBullish = oteDirection == 1
    bool oteAgeExpired = not na(oteSetupBar) and bar_index - oteSetupBar > oteMaximumAgeBars
    bool oteLiveSignalInvalidated = oteBullish ? activeLongInvalidated : activeShortInvalidated
    bool oteInvalidated = barReady and (oteLiveSignalInvalidated or
         (oteImpulseConfirmed and (oteBullish ? close < oteAnchorPrice : close > oteAnchorPrice)))

    if oteAgeExpired or oteInvalidated
        resetOTE := true
    else if not oteLocked
        if not oteImpulseConfirmed
            if oteBullish
                if low < oteAnchorPrice
                    oteAnchorPrice := low
                    oteExtremePrice := high
                    oteExtremeBar := bar_index
                else if high > oteExtremePrice
                    oteExtremePrice := high
                    oteExtremeBar := bar_index
            else
                if high > oteAnchorPrice
                    oteAnchorPrice := high
                    oteExtremePrice := low
                    oteExtremeBar := bar_index
                else if low < oteExtremePrice
                    oteExtremePrice := low
                    oteExtremeBar := bar_index

            float developingRange = math.abs(oteExtremePrice - oteAnchorPrice)
            bool directionImpulse = oteBullish ?
                 (oteRequireDisplacement ? bullDisplacement : (bullDisplacement or bullMicroShift)) :
                 (oteRequireDisplacement ? bearDisplacement : (bearDisplacement or bearMicroShift))
            bool minimumImpulseMet = developingRange >= atr * oteMinimumImpulseATR
            if barReady and directionImpulse and minimumImpulseMet
                oteImpulseConfirmed := true
        else
            if oteBullish and high > oteExtremePrice
                oteExtremePrice := high
                oteExtremeBar := bar_index
            if not oteBullish and low < oteExtremePrice
                oteExtremePrice := low
                oteExtremeBar := bar_index

            float impulseRange = math.abs(oteExtremePrice - oteAnchorPrice)
            float lockDistance = impulseRange * oteRetracementLockPercent / 100.0
            bool meaningfulRetracement = barReady and bar_index > oteSetupBar and
                 impulseRange >= atr * oteMinimumImpulseATR and
                 (oteBullish ? close <= oteExtremePrice - lockDistance : close >= oteExtremePrice + lockDistance)
            if meaningfulRetracement
                oteLocked := true

    if oteLocked and not resetOTE
        float lockedRange = math.max(math.abs(oteExtremePrice - oteAnchorPrice), syminfo.mintick)
        float ote50 = oteDirection == 1 ? oteExtremePrice - lockedRange * 0.500 : oteExtremePrice + lockedRange * 0.500
        float ote62 = oteDirection == 1 ? oteExtremePrice - lockedRange * 0.620 : oteExtremePrice + lockedRange * 0.620
        float ote705 = oteDirection == 1 ? oteExtremePrice - lockedRange * 0.705 : oteExtremePrice + lockedRange * 0.705
        float ote79 = oteDirection == 1 ? oteExtremePrice - lockedRange * 0.790 : oteExtremePrice + lockedRange * 0.790
        float oteZoneTop = math.max(ote62, ote79)
        float oteZoneBottom = math.min(ote62, ote79)
        int oteLeftX = nz(oteExtremeBar, bar_index)
        int oteRightX = bar_index + 1
        color oteFill = oteDirection == 1 ? color.new(color.teal, 84) : color.new(color.orange, 84)
        color oteBorder = oteDirection == 1 ? color.new(color.aqua, 20) : color.new(color.orange, 20)
        color otePreferredColor = oteDirection == 1 ? color.aqua : color.orange

        if na(oteZoneBox)
            oteZoneBox := box.new(oteLeftX, oteZoneTop, oteRightX, oteZoneBottom,
                 xloc=xloc.bar_index, bgcolor=oteFill, border_color=oteBorder, border_width=1)
        else
            box.set_left(oteZoneBox, oteLeftX)
            box.set_right(oteZoneBox, oteRightX)
            box.set_top(oteZoneBox, oteZoneTop)
            box.set_bottom(oteZoneBox, oteZoneBottom)
            box.set_bgcolor(oteZoneBox, oteFill)
            box.set_border_color(oteZoneBox, oteBorder)

        if showOTEEquilibrium
            if na(oteEquilibriumLine)
                oteEquilibriumLine := line.new(oteLeftX, ote50, oteRightX, ote50,
                     xloc=xloc.bar_index, color=color.new(color.gray, 25), width=1, style=line.style_dashed)
            else
                line.set_xy1(oteEquilibriumLine, oteLeftX, ote50)
                line.set_xy2(oteEquilibriumLine, oteRightX, ote50)
        else if not na(oteEquilibriumLine)
            line.delete(oteEquilibriumLine)
            oteEquilibriumLine := na

        if showOTEBoundaryLines
            if na(ote62Line)
                ote62Line := line.new(oteLeftX, ote62, oteRightX, ote62,
                     xloc=xloc.bar_index, color=oteBorder, width=1)
            else
                line.set_xy1(ote62Line, oteLeftX, ote62)
                line.set_xy2(ote62Line, oteRightX, ote62)
            if na(ote79Line)
                ote79Line := line.new(oteLeftX, ote79, oteRightX, ote79,
                     xloc=xloc.bar_index, color=oteBorder, width=1)
            else
                line.set_xy1(ote79Line, oteLeftX, ote79)
                line.set_xy2(ote79Line, oteRightX, ote79)
        else
            if not na(ote62Line)
                line.delete(ote62Line)
                ote62Line := na
            if not na(ote79Line)
                line.delete(ote79Line)
                ote79Line := na

        if showOTEPreferredLine
            if na(ote705Line)
                ote705Line := line.new(oteLeftX, ote705, oteRightX, ote705,
                     xloc=xloc.bar_index, color=otePreferredColor, width=2)
            else
                line.set_xy1(ote705Line, oteLeftX, ote705)
                line.set_xy2(ote705Line, oteRightX, ote705)
                line.set_color(ote705Line, otePreferredColor)
        else if not na(ote705Line)
            line.delete(ote705Line)
            ote705Line := na

        if showOTELabel
            string oteLabelText = oteDirection == 1 ? "BULL OTE\nDISCOUNT • 70.5%" : "BEAR OTE\nPREMIUM • 70.5%"
            if na(oteEntryLabel)
                oteEntryLabel := label.new(oteRightX, ote705, oteLabelText,
                     xloc=xloc.bar_index, style=label.style_label_left,
                     color=color.new(otePreferredColor, 20), textcolor=color.white, size=size.tiny)
            else
                label.set_xy(oteEntryLabel, oteRightX, ote705)
                label.set_text(oteEntryLabel, oteLabelText)
                label.set_color(oteEntryLabel, color.new(otePreferredColor, 20))
        else if not na(oteEntryLabel)
            label.delete(oteEntryLabel)
            oteEntryLabel := na

        bool oteTouching = high >= oteZoneBottom and low <= oteZoneTop
        if barReady and not oteZoneVisited and bar_index > oteExtremeBar and oteTouching
            oteZoneVisited := true
            oteVisitBar := bar_index

        if removeOTEAfterFirstVisit and oteZoneVisited and bar_index > nz(oteVisitBar, bar_index) and not oteTouching
            resetOTE := true

// A reset can be requested after the state and drawing calculations above.
if resetOTE and oteDirection != 0 and not (newOTELong or newOTEShort)
    if not na(oteZoneBox)
        box.delete(oteZoneBox)
        oteZoneBox := na
    if not na(oteEquilibriumLine)
        line.delete(oteEquilibriumLine)
        oteEquilibriumLine := na
    if not na(ote62Line)
        line.delete(ote62Line)
        ote62Line := na
    if not na(ote705Line)
        line.delete(ote705Line)
        ote705Line := na
    if not na(ote79Line)
        line.delete(ote79Line)
        ote79Line := na
    if not na(oteEntryLabel)
        label.delete(oteEntryLabel)
        oteEntryLabel := na

    oteDirection := 0
    oteSetupBar := na
    oteExtremeBar := na
    oteAnchorPrice := na
    oteExtremePrice := na
    oteImpulseConfirmed := false
    oteLocked := false
    oteZoneVisited := false
    oteVisitBar := na

// ───── Reaction status
string reactionStatus = optimalSignalDisplay == "Off" ? "1M LIVE SIGNALS OFF" :
     executionChartAllowed ? "EZ$L / EZ$S • LIVE" : "1M SIGNALS ONLY"
color reactionStatusColor = color.new(color.blue, 35)

// ───── Session-level freshness updates
bool crossedAsiaHigh = ta.cross(close, asiaHigh)
bool crossedAsiaLow = ta.cross(close, asiaLow)
bool crossedLondonHigh = ta.cross(close, londonHigh)
bool crossedLondonLow = ta.cross(close, londonLow)
bool crossedNewYorkHigh = ta.cross(close, newYorkHigh)
bool crossedNewYorkLow = ta.cross(close, newYorkLow)
bool crossedOvernightHigh = ta.cross(close, overnightHigh)
bool crossedOvernightLow = ta.cross(close, overnightLow)

if not na(asiaHigh) and crossedAsiaHigh
    asiaHighCrosses += 1
if not na(asiaLow) and crossedAsiaLow
    asiaLowCrosses += 1
if not na(londonHigh) and crossedLondonHigh
    londonHighCrosses += 1
if not na(londonLow) and crossedLondonLow
    londonLowCrosses += 1
if not na(newYorkHigh) and crossedNewYorkHigh
    newYorkHighCrosses += 1
if not na(newYorkLow) and crossedNewYorkLow
    newYorkLowCrosses += 1
if not na(overnightHigh) and crossedOvernightHigh
    overnightHighCrosses += 1
if not na(overnightLow) and crossedOvernightLow
    overnightLowCrosses += 1

// ───── Compact Bias + ATR dashboard
dashboardTextSize = dashboardSize == "Tiny" ? size.tiny : dashboardSize == "Normal" ? size.normal : size.small

var table contextTable = table.new(position.bottom_left, 4, 12,
     bgcolor=color.new(color.black, 70), border_width=1, border_color=color.new(color.gray, 65))

if barstate.islast
    table.clear(contextTable, 0, 0, 3, 11)

    if showBiasDashboard
        table.cell(contextTable, 0, 0, "1m", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, 0, show1mBias ? f_bias_text(bias1mBull) : "OFF", text_color=color.white,
             bgcolor=show1mBias ? f_bias_color(bias1mBull) : color.new(color.gray, 55), text_size=dashboardTextSize)

        table.cell(contextTable, 0, 1, "5m", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, 1, f_bias_text(bias5Bull), text_color=color.white, bgcolor=f_bias_color(bias5Bull), text_size=dashboardTextSize)

        table.cell(contextTable, 0, 2, "15m", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, 2, f_bias_text(bias15Bull), text_color=color.white, bgcolor=f_bias_color(bias15Bull), text_size=dashboardTextSize)

        table.cell(contextTable, 0, 3, "1H", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, 3, f_bias_text(bias1hBull), text_color=color.white, bgcolor=f_bias_color(bias1hBull), text_size=dashboardTextSize)

        table.cell(contextTable, 0, 4, "2H", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, 4, f_bias_text(bias2hBull), text_color=color.white, bgcolor=f_bias_color(bias2hBull), text_size=dashboardTextSize)

        table.cell(contextTable, 0, 5, "4H", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, 5, f_bias_text(bias4hBull), text_color=color.white, bgcolor=f_bias_color(bias4hBull), text_size=dashboardTextSize)

        table.cell(contextTable, 0, 6, "D", text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, 6, f_bias_text(biasDailyBull), text_color=color.white, bgcolor=f_bias_color(biasDailyBull), text_size=dashboardTextSize)

        int nextContextRow = 7
        if showDynamicChartBiasRow
            table.cell(contextTable, 0, nextContextRow, chartBiasLabel, text_color=color.white,
                 bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
            table.cell(contextTable, 1, nextContextRow, f_bias_text(chartBiasBull), text_color=color.white,
                 bgcolor=f_bias_color(chartBiasBull), text_size=dashboardTextSize)
            nextContextRow += 1

        if showStructureAMDDashboard
            string structureAMDText = f_structure_amd_phase_text(
                 structureAMDPhase, structureAMDValid, structureBalancedRange)
            color structureAMDColor = f_structure_amd_phase_color(structureAMDPhase, structureAMDValid)

            table.cell(contextTable, 0, nextContextRow, "S-AMD", text_color=color.white,
                 bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
            table.cell(contextTable, 1, nextContextRow, structureAMDText, text_color=color.white,
                 bgcolor=structureAMDColor, text_size=dashboardTextSize)
            nextContextRow += 1

        int summaryStartRow = nextContextRow
        string majorityText = majorityLongBias ? "BULL " + str.tostring(bullMajorityBiasCount) + "/" + str.tostring(selectedMajorityBiasCount) :
             majorityShortBias ? "BEAR " + str.tostring(bearMajorityBiasCount) + "/" + str.tostring(selectedMajorityBiasCount) :
             "MIXED"
        color majorityColor = majorityLongBias ? color.new(color.green, 10) :
             majorityShortBias ? color.new(color.red, 10) : color.new(color.gray, 45)

        table.cell(contextTable, 0, summaryStartRow, compactDashboardLabels ? "MAJ" : "MAJORITY", text_color=color.white,
             bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, summaryStartRow, majorityText, text_color=color.white,
             bgcolor=majorityColor, text_size=dashboardTextSize)

        table.cell(contextTable, 0, summaryStartRow + 1, compactDashboardLabels ? "SIG" : "SIGNALS", text_color=color.white,
             bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, 1, summaryStartRow + 1, reactionStatus, text_color=color.white,
             bgcolor=reactionStatusColor, text_size=dashboardTextSize)

    if showATRPanel
        int atrColumn = showBiasDashboard ? 2 : 0
        table.cell(contextTable, atrColumn, 0, compactDashboardLabels ? "SES" : "SESSION", text_color=color.white,
             bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, atrColumn + 1, 0, activeSessionName, text_color=color.white,
             bgcolor=inNewYorkSession ? color.new(color.aqua, 55) : inLondonSession ? color.new(color.purple, 45) :
             inAsiaSession ? color.new(color.blue, 45) : color.new(color.gray, 55), text_size=dashboardTextSize)

        table.cell(contextTable, atrColumn, 1, compactDashboardLabels ? "ATR" : "ATR " + str.tostring(atrLength),
             text_color=color.white, bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, atrColumn + 1, 1, str.tostring(sessionProfileATR, format.mintick), text_color=color.white,
             bgcolor=color.new(color.black, 45), text_size=dashboardTextSize)

        table.cell(contextTable, atrColumn, 2, compactDashboardLabels ? "ENG" : "ENGINE", text_color=color.white,
             bgcolor=color.new(color.black, 35), text_size=dashboardTextSize)
        table.cell(contextTable, atrColumn + 1, 2, useSessionATRForSignals ? "SESSION" : "ROLLING", text_color=color.white,
             bgcolor=useSessionATRForSignals ? color.new(color.green, 25) : color.new(color.gray, 45), text_size=dashboardTextSize)


// ───── Live higher-timeframe candle visualization
// The displayed candle can be any selected HTF, but its phase color is derived
// entirely from support/resistance structure on the chart and selected box sources.
string visualHTF = po3Timeframe

[po3Open, po3High, po3Low, po3Close] = request.security(syminfo.tickerid, visualHTF,
     [open, high, low, close], lookahead=barmerge.lookahead_off)
po3CloseTime = time_close(visualHTF)

f_two_digits(int value) =>
    value < 10 ? "0" + str.tostring(value) : str.tostring(value)

f_po3_countdown(int candleCloseTime) =>
    int remainingSeconds = na(candleCloseTime) ? 0 :
         math.max(int(math.floor((candleCloseTime - timenow) / 1000.0)), 0)
    int hoursRemaining = int(math.floor(remainingSeconds / 3600.0))
    int minutesRemaining = int(math.floor((remainingSeconds % 3600) / 60.0))
    int secondsRemaining = remainingSeconds % 60
    hoursRemaining > 0 ? str.tostring(hoursRemaining) + ":" +
         f_two_digits(minutesRemaining) + ":" + f_two_digits(secondsRemaining) :
         f_two_digits(minutesRemaining) + ":" + f_two_digits(secondsRemaining)

int visualAMDPhase = structureAMDPhase
bool visualAMDValid = structureAMDValid
string visualAMDPhaseText = f_structure_amd_phase_text(
     structureAMDPhase, structureAMDValid, structureBalancedRange)

color phaseBodyColor = visualAMDPhase == 2 ? color.new(color.green, 12) :
     visualAMDPhase == -2 ? color.new(color.red, 12) :
     visualAMDPhase == 1 ? color.new(color.aqua, 18) :
     visualAMDPhase == -1 ? color.new(color.purple, 18) :
     visualAMDValid ? color.new(color.yellow, 22) : color.new(color.gray, 45)

color phaseBorderColor = visualAMDPhase == 2 ? color.lime :
     visualAMDPhase == -2 ? color.red :
     visualAMDPhase == 1 ? color.aqua :
     visualAMDPhase == -1 ? color.purple :
     visualAMDValid ? color.yellow : color.gray

color rawCandleBodyColor = po3Close >= po3Open ? color.new(color.green, 15) : color.new(color.red, 15)
color rawCandleBorderColor = po3Close >= po3Open ? color.lime : color.red
color candleColor = colorPO3ByAMD ? phaseBodyColor : rawCandleBodyColor
color candleBorder = colorPO3ByAMD ? phaseBorderColor : rawCandleBorderColor

var box po3BodyBox = na
var line po3WickLine = na
var label po3TfLabel = na

if barstate.islast
    if showPO3Candle and not na(po3Open)
        int leftX = bar_index + po3Offset
        int rightX = leftX + po3BodyWidth
        int centerX = int(math.round((leftX + rightX) / 2.0))
        float bodyTop = math.max(po3Open, po3Close)
        float bodyBottom = math.min(po3Open, po3Close)
        bodyTop := bodyTop == bodyBottom ? bodyTop + syminfo.mintick : bodyTop

        if na(po3BodyBox)
            po3BodyBox := box.new(leftX, bodyTop, rightX, bodyBottom,
                 xloc=xloc.bar_index, bgcolor=candleColor,
                 border_color=candleBorder, border_width=2)
        else
            box.set_left(po3BodyBox, leftX)
            box.set_right(po3BodyBox, rightX)
            box.set_top(po3BodyBox, bodyTop)
            box.set_bottom(po3BodyBox, bodyBottom)
            box.set_bgcolor(po3BodyBox, candleColor)
            box.set_border_color(po3BodyBox, candleBorder)
            box.set_border_width(po3BodyBox, 2)

        if na(po3WickLine)
            po3WickLine := line.new(centerX, po3Low, centerX, po3High,
                 xloc=xloc.bar_index, color=candleBorder, width=2)
        else
            line.set_xy1(po3WickLine, centerX, po3Low)
            line.set_xy2(po3WickLine, centerX, po3High)
            line.set_color(po3WickLine, candleBorder)
            line.set_width(po3WickLine, 2)

        if showPO3Label or showPO3Timer
            string po3LabelText = ""
            if showPO3Label
                po3LabelText += f_pretty_timeframe(visualHTF) + " LIVE\nSTRUCT AMD • " + visualAMDPhaseText
            if showPO3Timer
                po3LabelText += (str.length(po3LabelText) > 0 ? "\n" : "") +
                     f_po3_countdown(po3CloseTime)

            float labelY = po3High + atr * 0.20
            if na(po3TfLabel)
                po3TfLabel := label.new(centerX, labelY, po3LabelText,
                     xloc=xloc.bar_index, style=label.style_label_down,
                     color=color.new(candleBorder, 35),
                     textcolor=color.white, size=size.tiny)
            else
                label.set_xy(po3TfLabel, centerX, labelY)
                label.set_text(po3TfLabel, po3LabelText)
                label.set_color(po3TfLabel, color.new(candleBorder, 35))
                label.set_textcolor(po3TfLabel, color.white)
        else if not na(po3TfLabel)
            label.delete(po3TfLabel)
            po3TfLabel := na
    else
        if not na(po3BodyBox)
            box.delete(po3BodyBox)
            po3BodyBox := na
        if not na(po3WickLine)
            line.delete(po3WickLine)
            po3WickLine := na
        if not na(po3TfLabel)
            label.delete(po3TfLabel)
            po3TfLabel := na
````
