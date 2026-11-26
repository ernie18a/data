# Recovery Raid Index

- url: https://www.tradingview.com/script/UqfrSfCc-Recovery-Raid-Index/
- type: indicator
- pine_id: PUB;0cb75fdac3814be9b6237e1ebfd7cdd2
- version: 1.0

## Description

Recovery Raid Index is a price-action overlay designed to help traders separate real breakouts from liquidity raids that quickly reverse.

Breakouts are not all the same. Some represent genuine expansion, while others are stop-runs through obvious liquidity before price reclaims the level. Recovery RAID Index detects sweeps of important liquidity levels, tracks whether price recovers or accepts beyond them, and scores the quality of that outcome using structure, rejection, flow, relative volume, fair value gap context, session behavior, and optional lower-timeframe confirmation.

The goal is simple: show traders what happened after liquidity was taken.

Overview

Retail traders are often trapped by breakouts that sweep a prior high or low, trigger stops, and then reverse sharply. Recovery RAID Index was built to study that exact sequence.

The script identifies liquidity raids above or below key levels, waits for either a reclaim or an accepted continuation, and classifies the outcome directly on the chart. Instead of only marking that a sweep happened, it evaluates the quality of the recovery and gives traders a structured way to understand whether the move looks like a trap reversal, a real breakout, or an abandoned setup.

This is part of the broader Structure Flow research approach: structure first, confirmation second, visual clarity always.

What it does

Recovery RAID Index is designed to track the full life cycle of a liquidity sweep.

It can:

Detect sweeps of swing highs/lows, equal highs/lows, previous day highs/lows, previous week highs/lows, and developing session highs/lows.
Track pending reclaim levels after a sweep occurs.
Confirm when price reclaims the swept level within a configurable time window.
Classify failed reversals as accepted breakouts or accepted breakdowns.
Score recoveries using level importance, sweep depth, reclaim speed, wick rejection, RVOL, directional flow, close-back strength, FVG confluence, and volatility regime.
Display R and R+ recovery signals.
Show ACCEPT UP / ACCEPT DOWN labels when price accepts beyond the swept level instead of reversing.
Draw recovery boxes around the sweep zone.
Plot optional stop and target planning lines based on the sweep extreme and next liquidity level.
Maintain outcome statistics by liquidity source.
Optionally validate reclaim quality using lower-timeframe closes.
Why it is different

Most liquidity sweep tools focus on the moment price takes a high or low. Recovery RAID Index focuses on the decision that follows.

A sweep by itself is not enough. Price can sweep liquidity and reverse, sweep liquidity and continue, or sweep liquidity and do nothing meaningful. This script is built around that distinction.

Recovery RAID Index separates:

Trap recoveries — price sweeps liquidity, then reclaims the level.
Strong recoveries — recoveries with stronger confluence and higher score.
Accepted breakouts/breakdowns — price sweeps a level and continues beyond it.
Expired sweeps — price fails to confirm either outcome within the reclaim window.

The script also includes outcome memory, so traders can see how different liquidity sources are resolving recently. For example, previous day sweeps may be recovering well while session-level sweeps are failing. That makes the tool more than a marker; it becomes a live read on sweep behavior.

Core logic
Liquidity sources

The script can monitor multiple sources of obvious liquidity:

Swing highs and swing lows
Equal highs and equal lows
Previous day high and low
Previous week high and low
Developing session high and low

Each source has a different importance value. Previous week and previous day levels generally carry more weight than ordinary swing levels, while equal highs/lows add context where liquidity is visibly clustered.

Recovery model

A sweep occurs when price trades beyond a tracked liquidity level by a configurable ATR buffer.

For a bullish recovery setup, price sweeps below a liquidity level and then must close back above the swept level within the reclaim window.

For a bearish recovery setup, price sweeps above a liquidity level and then must close back below the swept level within the reclaim window.

If price does not reclaim and instead remains beyond the swept level after the acceptance window, the script can classify the event as accepted continuation rather than reversal.

This creates a complete sweep framework:

Liquidity is taken.
The script tracks the reclaim level.
Price either recovers, accepts, or expires.
The event is labeled and recorded.
Score model

Each recovery receives a score from 0 to 100.

The score is based on several components:

Level importance
Higher-value liquidity sources receive more weight. A previous week high or low is treated as more important than a simple local swing.

Sweep depth
Measures how far price moved beyond the swept level in ATR terms. A meaningful sweep should take liquidity clearly, but not become so extended that the reclaim loses quality.

Reclaim speed
Fast recoveries are generally stronger than delayed recoveries. The script rewards price that reclaims the level quickly.

Wick rejection
Large rejection wicks can show that price rejected the sweep area. The script measures the wick relative to the candle range.

Relative volume
RVOL compares current volume to average volume. Higher participation can increase confidence that the sweep was meaningful.

Flow proxy
The script estimates directional pressure using candle position and volume. This is not true bid/ask delta, but it helps approximate whether buying or selling pressure supported the reclaim.

Close-back strength
Measures how far price closes back through the swept level after reclaiming.

Fair value gap confluence
If a recovery aligns with an active FVG near the sweep zone, the score can receive an additional boost.

Volatility regime
The script adapts scoring behavior based on volatility. In higher-volatility regimes, sweep depth is weighted differently than in normal or low-volatility conditions.

Fair value gap confluence

Recovery RAID Index can detect recent fair value gaps and check whether they overlap the sweep/reclaim area.

This matters because a sweep that reclaims into an imbalance or displacement zone may carry more context than a simple wick through a level.

The FVG engine considers:

bullish and bearish FVG formation
impulse requirement
FVG age
distance from the swept level
whether the gap is still active

FVG confluence is optional and can be turned off.

Optional lower-timeframe confirmation

The script includes optional lower-timeframe reclaim confirmation.

When enabled, the reclaim candle is checked using lower-timeframe closes. For example, on a 15-minute chart, the script can inspect lower-timeframe candles to see how many closed back through the swept level.

This helps distinguish a clean structural reclaim from a single end-of-candle close. Because lower-timeframe confirmation is more computationally demanding, it is optional and off by default.

Session intelligence

The script identifies broad session context using UTC time:

London
New York
Other

The reclaim window can adjust based on session behavior. This is useful because sweeps can behave differently during active sessions compared with quieter market periods.

Session information is also included in tooltips.

Outcome memory

Recovery RAID Index records recent sweep outcomes by source category:

Swing
Equal high/low
Previous day
Previous week
Session

The outcome table shows how many recent sweeps recovered, accepted, or failed by source. This helps traders understand which liquidity pools are currently producing cleaner reactions.

This is intended as a transparency feature, not a performance claim.

Signal types
R LONG

A bullish recovery signal. Price swept below a liquidity level, then reclaimed back above the swept level within the configured reclaim window.

R+ LONG

A stronger bullish recovery. This is an R LONG signal with a higher recovery score.

R SHORT

A bearish recovery signal. Price swept above a liquidity level, then reclaimed back below the swept level within the configured reclaim window.

R+ SHORT

A stronger bearish recovery. This is an R SHORT signal with a higher recovery score.

ACCEPT UP

Price swept above a liquidity level and then accepted beyond it instead of rejecting. This suggests continuation rather than reversal.

ACCEPT DOWN

Price swept below a liquidity level and then accepted beyond it instead of reclaiming. This suggests continuation rather than reversal.

Pending reclaim level

A sweep has occurred and the script is waiting to see whether price recovers, accepts, or expires.

How to use it
Basic workflow
Identify a meaningful liquidity level.
Wait for price to sweep that level.
Watch the pending reclaim level.
Let the script classify the outcome as recovery, strong recovery, acceptance, or expiry.
Use the recovery score and tooltip context to evaluate the setup.
Use recovery boxes and optional stop/target lines as planning references.
Example use cases

Previous day low raid
Price trades below the previous day low, forms a rejection wick, then closes back above the level with strong RVOL. The script may print R LONG or R+ LONG depending on score.

Previous day high acceptance
Price sweeps above the previous day high and holds above it beyond the acceptance window. The script may print ACCEPT UP, showing that the sweep behaved more like continuation than reversal.

Equal high trap
Price takes a visible equal high, fails to hold above it, and quickly reclaims below the level. The script may classify the event as R SHORT.

Filtering weak sweeps
Users can require stronger wick rejection, higher RVOL, FVG confluence, or lower-timeframe confirmation to reduce weaker signals.

Inputs
Liquidity Levels

This section controls which levels the script monitors.

Use Swing High / Low
Tracks confirmed pivot highs and lows.

Use Equal High / Low
Tracks equal highs/lows within an ATR-based tolerance.

Use Previous Day High / Low
Adds prior daily extremes as liquidity levels.

Use Previous Week High / Low
Adds prior weekly extremes.

Use Developing Session High / Low
Tracks current session extremes using the previous bar value to avoid same-bar self-reference.

Swing Pivot Length
Controls how sensitive swing detection is.

Equal High/Low Tolerance ATR
Controls how close two swing levels must be to count as equal highs or equal lows.

Hide Far Liquidity Levels
Keeps the chart cleaner by hiding levels far from current price.

Raid Detection

This section controls sweep and reclaim behavior.

Sweep Buffer ATR
Minimum distance beyond a level required to count as a sweep.

Reclaim Buffer ATR
Minimum close-back buffer required to confirm a reclaim.

Accepted Breakout Buffer ATR
Distance beyond the swept level used to classify acceptance.

Max Sweep Depth ATR
Prevents extremely distant breaks from being treated as clean liquidity sweeps.

Base Max Bars To Reclaim
Maximum number of bars allowed for price to reclaim the swept level.

Bars Before Acceptance Check
Minimum number of bars before the script checks whether the sweep has become accepted continuation.

Minimum Recovery Score
Minimum score required to print an R signal.

Strong Recovery Score
Minimum score required to print an R+ signal.

Flow / Volume Scoring

This section controls participation and rejection scoring.

RVOL Length
Lookback used to calculate relative volume.

RVOL Target
Target relative-volume value used in scoring.

Flow Smoothing
Smoothing length for the directional flow proxy.

Flow Target
Target directional-flow value used in scoring.

Ideal Rejection Wick Ratio
Wick-to-range ratio used to score rejection quality.

FVG Confluence

This section controls fair value gap context.

Use FVG Confluence Boost
Enables or disables FVG scoring.

Max Active FVG Age
Controls how long an FVG can remain active for confluence.

FVG Near Sweep Tolerance ATR
Controls how close the FVG must be to the sweep level.

Minimum FVG Impulse ATR
Requires enough displacement before counting an FVG.

Show Active FVG Zones
Displays active FVG areas on the chart.

Optional LTF Confirmation

This section controls lower-timeframe reclaim validation.

Use Lower-TF Reclaim Confirmation
Requires a configurable portion of lower-timeframe closes to confirm the reclaim.

Lower Timeframe
The lower timeframe used for confirmation.

Minimum LTF Reclaim Ratio
Minimum portion of lower-timeframe closes required beyond the reclaim level.

This feature can improve confirmation quality but may increase computation. It is off by default.

Targets / Trade Plan

This section controls planning references.

Show Auto Stop / Target
Draws optional stop and target reference lines after recovery signals.

Plan Line Forward Bars
Controls how far stop/target lines extend.

Max Plan Sets Kept
Limits how many historical planning lines remain on the chart.

Stops are based on the sweep extreme. Targets are based on the next available liquidity level.

Display and Object Management

This section controls visual layers.

Users can toggle:

liquidity levels
sweep markers
recovery boxes
accepted breakout labels
dashboard
outcome statistics table
EMA 50
yearly VWAP
FVG zones
stop/target planning lines

Object limits are included to keep the chart clean and responsive.

Best markets and timeframes

Recovery RAID Index is designed for liquid markets where stop-runs and liquidity sweeps are common.

It is most useful on:

indices
futures
forex
crypto
liquid large-cap stocks

It can be used across many timeframes, but the strongest general range is usually 5-minute to 4-hour charts.

Lower timeframes may produce more signals and require more filtering. Higher timeframes may produce fewer but cleaner events.

Lower-timeframe confirmation works best when the chart timeframe is meaningfully higher than the selected confirmation timeframe.

Limitations

Recovery RAID Index does not predict every reversal.

Important limitations:

Strong trends can sweep liquidity and continue.
Not every reclaim leads to follow-through.
The flow model is an approximation based on candle position and volume, not true bid/ask order flow.
Pivot-based levels require confirmation and are delayed by design.
Lower-timeframe confirmation depends on available intrabar data.
FVG confluence is contextual, not a guarantee.
Outcome statistics are recent script memory, not a backtest or performance claim.

This script should be used with market context, session awareness, and risk management.

Originality statement

Recovery RAID Index is not a generic liquidity-line overlay.

Its core idea is the post-sweep decision model: it detects when liquidity has been raided, then evaluates whether the market recovered the level, accepted beyond it, or abandoned the setup. The script scores that process using level importance, sweep depth, reclaim speed, rejection quality, relative volume, directional flow, FVG confluence, volatility regime, session context, and optional lower-timeframe reclaim validation.

The result is a workflow tool for studying liquidity sweeps, not just a marker for highs and lows.

Usage notes
Use R and R+ signals to study potential reversal setups after liquidity sweeps.
Use ACCEPT UP and ACCEPT DOWN labels to study continuation after sweeps.
Use R+ signals for stricter filtering.
Use R signals for broader monitoring.
Use the outcome table to see which liquidity sources are resolving best recently.
Use FVG confluence when you want more structure-based filtering.
Use lower-timeframe confirmation only when you need stricter reclaim validation.
If the chart becomes too busy, disable some liquidity sources, hide far levels, or turn off recovery boxes.
Disclaimer

This indicator is for educational and analytical purposes only. It does not provide financial advice and does not guarantee future performance.

## Source Code

````pine
//@version=6
indicator("Recovery Raid Index", shorttitle="RRI", overlay=true,
     dynamic_requests=true, max_bars_back=900, max_labels_count=250, max_lines_count=140, max_boxes_count=80)

// ══════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════
g1 = "Liquidity Levels"
useSwingLevels      = input.bool(true, "Use Swing High / Low", group=g1)
useEqualLevels      = input.bool(true, "Use Equal High / Low", group=g1)
usePrevDayLevels    = input.bool(true, "Use Previous Day High / Low", group=g1)
usePrevWeekLvls     = input.bool(true, "Use Previous Week High / Low", group=g1)
useSessionLevels    = input.bool(true, "Use Developing Session High / Low", group=g1)
pivotLen            = input.int(5, "Swing Pivot Length", minval=2, maxval=30, group=g1)
equalTolAtr         = input.float(0.15, "Equal High/Low Tolerance ATR", minval=0.02, maxval=1.0, step=0.01, group=g1)
hideFarLevels       = input.bool(true, "Hide Far Liquidity Levels", group=g1)
levelMaxDistanceAtr = input.float(16.0, "Max Visible Level Distance ATR", minval=2.0, maxval=100.0, step=1.0, group=g1)

g2 = "Raid Detection"
atrLen             = input.int(14, "ATR Length", minval=5, maxval=100, group=g2)
sweepBufferAtr     = input.float(0.03, "Sweep Buffer ATR", minval=0.0, maxval=1.0, step=0.01, group=g2)
reclaimBufferAtr   = input.float(0.02, "Reclaim Buffer ATR", minval=0.0, maxval=1.0, step=0.01, group=g2)
acceptBufferAtr    = input.float(0.12, "Accepted Breakout Buffer ATR", minval=0.01, maxval=2.0, step=0.01, group=g2)
maxSweepDepthAtr   = input.float(2.50, "Max Sweep Depth ATR", minval=0.25, maxval=10.0, step=0.25, group=g2)
maxReclaimBars     = input.int(8, "Base Max Bars To Reclaim", minval=1, maxval=100, group=g2)
acceptBars         = input.int(3, "Bars Before Acceptance Check", minval=1, maxval=50, group=g2)
minRecoveryScore   = input.float(58, "Minimum Recovery Score", minval=0, maxval=100, step=1, group=g2)
strongScore        = input.float(78, "Strong Recovery Score", minval=50, maxval=100, step=1, group=g2)

g3 = "Flow / Volume Scoring"
rvolLen        = input.int(20, "RVOL Length", minval=5, maxval=200, group=g3)
rvolTarget     = input.float(1.30, "RVOL Target", minval=0.20, maxval=5.0, step=0.05, group=g3)
deltaLen       = input.int(7, "Flow Smoothing", minval=2, maxval=50, group=g3)
deltaTarget    = input.float(0.06, "Flow Target", minval=0.005, maxval=0.50, step=0.005, group=g3)
minWickRatio   = input.float(0.35, "Ideal Rejection Wick Ratio", minval=0.05, maxval=0.95, step=0.05, group=g3)

g4 = "FVG Confluence"
useFvgConfluence = input.bool(true, "Use FVG Confluence Boost", group=g4)
fvgMaxAge        = input.int(20, "Max Active FVG Age", minval=1, maxval=200, group=g4)
fvgNearAtr       = input.float(0.60, "FVG Near Sweep Tolerance ATR", minval=0.05, maxval=5.0, step=0.05, group=g4)
fvgImpulseAtr    = input.float(0.40, "Minimum FVG Impulse ATR", minval=0.0, maxval=5.0, step=0.05, group=g4)
showFvgZones     = input.bool(true, "Show Active FVG Zones", group=g4)

g5 = "Optional LTF Confirmation"
useLtfConfirm = input.bool(false, "Use Lower-TF Reclaim Confirmation", group=g5, tooltip="Advanced. When enabled, the reclaim candle must show enough lower-timeframe closes back through the swept level. Default is OFF for performance.")
ltfTf         = input.timeframe("1", "Lower Timeframe", group=g5)
ltfMinRatio   = input.float(0.60, "Minimum LTF Reclaim Ratio", minval=0.10, maxval=1.0, step=0.05, group=g5)

g6 = "Targets / Trade Plan"
showStopTargets = input.bool(true, "Show Auto Stop / Target", group=g6)
targetForwardBars = input.int(30, "Plan Line Forward Bars", minval=5, maxval=200, group=g6)
maxPlanSets = input.int(8, "Max Plan Sets Kept", minval=1, maxval=25, group=g6)

g7 = "Display"
showLiquidityLevels = input.bool(true, "Show Liquidity Levels", group=g7)
showSweepMarkers    = input.bool(true, "Show Sweep Markers", group=g7)
showRecoveryBoxes   = input.bool(true, "Show Recovery Boxes", group=g7)
showAcceptedBreaks  = input.bool(true, "Show Accepted Breakouts", group=g7)
showDashboard       = input.bool(true, "Show Dashboard", group=g7)
showStatsTable      = input.bool(true, "Show Outcome Statistics", group=g7)
showEMA             = input.bool(false, "Show EMA 50", group=g7)
showYVWAP           = input.bool(false, "Show Yearly VWAP", group=g7)

g8 = "Object Management"
maxRecoveryBoxes = input.int(20, "Max Recovery Boxes Kept", minval=1, maxval=50, group=g8)
boxForwardBars   = input.int(0, "Extend Recovery Box Right Bars", minval=0, maxval=200, group=g8)
statsLookback    = input.int(30, "Outcome Memory Size", minval=10, maxval=100, group=g8)

g9 = "Alerts"
enableDynamicAlerts = input.bool(true, "Enable Dynamic alert() Messages", group=g9)

// ══════════════════════════════════════════════════════════════════════
// PALETTE
// ══════════════════════════════════════════════════════════════════════
C_BULL = #00d4a8
C_BEAR = #ff4d6d
C_WARN = #fbbf24
C_INFO = #4f7cff
C_DIM  = #4a5568
C_TEXT = #e2e8f0
C_BG   = #0d1117
C_BG2  = #161b22

// ══════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════
clamp01(x) =>
    math.max(0.0, math.min(1.0, x))

scoreClamp(x) =>
    math.max(0.0, math.min(100.0, x))

candidateBear(level, importance, sweepBuf, atrValue, maxDepthAtr) =>
    depth = not na(level) ? high - level : na
    ok = not na(depth) and depth > sweepBuf and depth <= atrValue * maxDepthAtr
    ok ? importance * 100.0 - (depth / math.max(atrValue, syminfo.mintick)) * 10.0 : na

candidateBull(level, importance, sweepBuf, atrValue, maxDepthAtr) =>
    depth = not na(level) ? level - low : na
    ok = not na(depth) and depth > sweepBuf and depth <= atrValue * maxDepthAtr
    ok ? importance * 100.0 - (depth / math.max(atrValue, syminfo.mintick)) * 10.0 : na

levelVisible(level, atrValue) =>
    not na(level) and (not hideFarLevels or math.abs(level - close) <= atrValue * levelMaxDistanceAtr)

overlapsZone(top, bottom, level, tol) =>
    not na(top) and not na(bottom) and not na(level) and level <= top + tol and level >= bottom - tol

sourceBucket(src) =>
    str.contains(src, "SWING") ? "SWING" :
     str.contains(src, "EQUAL") ? "EQUAL" :
     str.contains(src, "PD") ? "PD" :
     str.contains(src, "PW") ? "PW" :
     str.contains(src, "SESSION") ? "SESSION" : "OTHER"

// ══════════════════════════════════════════════════════════════════════
// CORE SERIES
// ══════════════════════════════════════════════════════════════════════
atr = ta.atr(atrLen)
ema50 = ta.ema(close, 50)

sweepBuf   = atr * sweepBufferAtr
reclaimBuf = atr * reclaimBufferAtr
acceptBuf  = atr * acceptBufferAtr

// Yearly VWAP
var float cumPV = 0.0
var float cumV  = 0.0

if timeframe.change("12M")
    cumPV := 0.0
    cumV  := 0.0

cumPV += hlc3 * nz(volume, 1.0)
cumV  += nz(volume, 1.0)
yVwap = cumV > 0 ? cumPV / cumV : hlc3

bullStack = ema50 > yVwap and close > ema50 and close > yVwap
bearStack = ema50 < yVwap and close < ema50 and close < yVwap

// Session intelligence
utcHour = hour(time, "UTC")
isLondon = utcHour >= 8 and utcHour < 12
isNY = utcHour >= 13 and utcHour < 17
sessionName = isNY ? "NY" : isLondon ? "LONDON" : "OTHER"
sessionMult = isNY ? 1.0 : isLondon ? 1.2 : 0.8
effectiveMaxReclaimBars = math.max(1, int(math.round(maxReclaimBars * sessionMult)))

// Regime intelligence
atrRegimeBase = ta.sma(atr, 50)
highVolRegime = not na(atrRegimeBase) and atr > atrRegimeBase * 1.30
lowVolRegime = not na(atrRegimeBase) and atr < atrRegimeBase * 0.70
volRegime = highVolRegime ? "HIGH VOL" : lowVolRegime ? "LOW VOL" : "NORMAL"

// Dynamic scoring weights
importanceWeight = 18.0
depthWeight = highVolRegime ? 12.0 : 18.0
speedWeight = lowVolRegime ? 12.0 : 18.0
wickWeight = 13.0
rvolWeight = 11.0
flowWeight = 10.0
closeBackWeight = 8.0
fvgWeight = 8.0

// ══════════════════════════════════════════════════════════════════════
// FLOW / VOLUME MODEL
// ══════════════════════════════════════════════════════════════════════
volSafe = nz(volume, 0.0)
volMA   = ta.sma(volSafe, rvolLen)
rvol    = volMA > 0 ? volSafe / volMA : 1.0

barRange = math.max(high - low, syminfo.mintick)
buyPress = ((close - low) / barRange) * volSafe
sellPress = ((high - close) / barRange) * volSafe
nDelta = ta.ema(buyPress - sellPress, deltaLen) / math.max(ta.ema(volSafe, deltaLen), 1.0)

// ══════════════════════════════════════════════════════════════════════
// LIQUIDITY LEVELS
// ══════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float swingHigh1 = na
var float swingHigh2 = na
var int   swingHighBar = na

var float swingLow1 = na
var float swingLow2 = na
var int   swingLowBar = na

if not na(ph)
    swingHigh2 := swingHigh1
    swingHigh1 := ph
    swingHighBar := bar_index - pivotLen

if not na(pl)
    swingLow2 := swingLow1
    swingLow1 := pl
    swingLowBar := bar_index - pivotLen

eqTol = atr * equalTolAtr

equalHigh = useEqualLevels and not na(swingHigh1) and not na(swingHigh2) and math.abs(swingHigh1 - swingHigh2) <= eqTol ? (swingHigh1 + swingHigh2) * 0.5 : na
equalLow  = useEqualLevels and not na(swingLow1) and not na(swingLow2) and math.abs(swingLow1 - swingLow2) <= eqTol ? (swingLow1 + swingLow2) * 0.5 : na

prevDayHigh  = usePrevDayLevels ? request.security(syminfo.tickerid, "D", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on) : na
prevDayLow   = usePrevDayLevels ? request.security(syminfo.tickerid, "D", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on) : na
prevWeekHigh = usePrevWeekLvls ? request.security(syminfo.tickerid, "W", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on) : na
prevWeekLow  = usePrevWeekLvls ? request.security(syminfo.tickerid, "W", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on) : na

// Developing session high / low, previous bar value to avoid same-bar self-reference.
var float sessionHigh = na
var float sessionLow  = na

if timeframe.change("D")
    sessionHigh := high
    sessionLow  := low
else
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow  := math.min(nz(sessionLow, low), low)

devSessionHigh = useSessionLevels ? sessionHigh[1] : na
devSessionLow  = useSessionLevels ? sessionLow[1] : na

// ══════════════════════════════════════════════════════════════════════
// FVG ENGINE
// ══════════════════════════════════════════════════════════════════════
bullFvgRaw = useFvgConfluence and low > high[2] and math.abs(close[1] - open[1]) >= atr * fvgImpulseAtr
bearFvgRaw = useFvgConfluence and high < low[2] and math.abs(close[1] - open[1]) >= atr * fvgImpulseAtr

var float bullFvgTop = na
var float bullFvgBot = na
var int bullFvgBar = na
var box bullFvgBox = na

var float bearFvgTop = na
var float bearFvgBot = na
var int bearFvgBar = na
var box bearFvgBox = na

if bullFvgRaw and barstate.isconfirmed
    bullFvgTop := low
    bullFvgBot := high[2]
    bullFvgBar := bar_index
    if not na(bullFvgBox)
        box.delete(bullFvgBox)
    if showFvgZones
        bullFvgBox := box.new(bar_index - 2, bullFvgTop, bar_index + 40, bullFvgBot,
             border_color=color.new(C_BULL, 82), bgcolor=color.new(C_BULL, 95), border_width=1)

if bearFvgRaw and barstate.isconfirmed
    bearFvgTop := low[2]
    bearFvgBot := high
    bearFvgBar := bar_index
    if not na(bearFvgBox)
        box.delete(bearFvgBox)
    if showFvgZones
        bearFvgBox := box.new(bar_index - 2, bearFvgTop, bar_index + 40, bearFvgBot,
             border_color=color.new(C_BEAR, 82), bgcolor=color.new(C_BEAR, 95), border_width=1)

bullFvgActive = useFvgConfluence and not na(bullFvgTop) and not na(bullFvgBot) and not na(bullFvgBar) and bar_index - bullFvgBar <= fvgMaxAge and low > bullFvgBot
bearFvgActive = useFvgConfluence and not na(bearFvgTop) and not na(bearFvgBot) and not na(bearFvgBar) and bar_index - bearFvgBar <= fvgMaxAge and high < bearFvgTop

if not bullFvgActive and not na(bullFvgBox)
    box.delete(bullFvgBox)
    bullFvgBox := na

if not bearFvgActive and not na(bearFvgBox)
    box.delete(bearFvgBox)
    bearFvgBox := na

// ══════════════════════════════════════════════════════════════════════
// HISTORY ARRAYS
// outcome: 0=recovered, 1=accepted, 2=expired/abandoned
// ══════════════════════════════════════════════════════════════════════
var array<string> histSource = array.new<string>()
var array<int> histOutcome = array.new<int>()

recordOutcome(src, outcome) =>
    if str.length(src) > 0
        array.push(histSource, sourceBucket(src))
        array.push(histOutcome, outcome)
        if array.size(histSource) > statsLookback
            array.shift(histSource)
            array.shift(histOutcome)

// ══════════════════════════════════════════════════════════════════════
// PENDING RAID STATE
// ══════════════════════════════════════════════════════════════════════
var bool  pendLong = false
var float pendLongLevel = na
var float pendLongExtreme = na
var int   pendLongBar = na
var string pendLongSource = ""
var string pendLongSession = ""
var float pendLongImp = na
var float pendLongWick = na
var float pendLongRvol = na

var bool  pendShort = false
var float pendShortLevel = na
var float pendShortExtreme = na
var int   pendShortBar = na
var string pendShortSource = ""
var string pendShortSession = ""
var float pendShortImp = na
var float pendShortWick = na
var float pendShortRvol = na

// Enforce expiry before accepting new sweep.
if pendLong and not na(pendLongBar) and bar_index - pendLongBar > effectiveMaxReclaimBars
    recordOutcome(pendLongSource, 2)
    pendLong := false
    pendLongLevel := na
    pendLongExtreme := na
    pendLongBar := na
    pendLongSource := ""
    pendLongSession := ""
    pendLongImp := na
    pendLongWick := na
    pendLongRvol := na

if pendShort and not na(pendShortBar) and bar_index - pendShortBar > effectiveMaxReclaimBars
    recordOutcome(pendShortSource, 2)
    pendShort := false
    pendShortLevel := na
    pendShortExtreme := na
    pendShortBar := na
    pendShortSource := ""
    pendShortSession := ""
    pendShortImp := na
    pendShortWick := na
    pendShortRvol := na

// ══════════════════════════════════════════════════════════════════════
// SELECT SWEPT LEVELS
// ══════════════════════════════════════════════════════════════════════
float bearSweepLevel = na
float bearSweepRank  = na
float bearSweepImp   = na
string bearSweepSrc  = ""

float bullSweepLevel = na
float bullSweepRank  = na
float bullSweepImp   = na
string bullSweepSrc  = ""

float cand = na

// Bearish raid candidates: price sweeps ABOVE liquidity.
cand := useSwingLevels ? candidateBear(swingHigh1, 1.00, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bearSweepRank) or cand > bearSweepRank)
    bearSweepRank := cand
    bearSweepLevel := swingHigh1
    bearSweepImp := 1.00
    bearSweepSrc := "SWING HIGH"

cand := useEqualLevels ? candidateBear(equalHigh, 1.20, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bearSweepRank) or cand > bearSweepRank)
    bearSweepRank := cand
    bearSweepLevel := equalHigh
    bearSweepImp := 1.20
    bearSweepSrc := "EQUAL HIGH"

cand := usePrevDayLevels ? candidateBear(prevDayHigh, 1.35, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bearSweepRank) or cand > bearSweepRank)
    bearSweepRank := cand
    bearSweepLevel := prevDayHigh
    bearSweepImp := 1.35
    bearSweepSrc := "PDH"

cand := usePrevWeekLvls ? candidateBear(prevWeekHigh, 1.50, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bearSweepRank) or cand > bearSweepRank)
    bearSweepRank := cand
    bearSweepLevel := prevWeekHigh
    bearSweepImp := 1.50
    bearSweepSrc := "PWH"

cand := useSessionLevels ? candidateBear(devSessionHigh, 1.10, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bearSweepRank) or cand > bearSweepRank)
    bearSweepRank := cand
    bearSweepLevel := devSessionHigh
    bearSweepImp := 1.10
    bearSweepSrc := "SESSION HIGH"

// Bullish raid candidates: price sweeps BELOW liquidity.
cand := useSwingLevels ? candidateBull(swingLow1, 1.00, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bullSweepRank) or cand > bullSweepRank)
    bullSweepRank := cand
    bullSweepLevel := swingLow1
    bullSweepImp := 1.00
    bullSweepSrc := "SWING LOW"

cand := useEqualLevels ? candidateBull(equalLow, 1.20, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bullSweepRank) or cand > bullSweepRank)
    bullSweepRank := cand
    bullSweepLevel := equalLow
    bullSweepImp := 1.20
    bullSweepSrc := "EQUAL LOW"

cand := usePrevDayLevels ? candidateBull(prevDayLow, 1.35, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bullSweepRank) or cand > bullSweepRank)
    bullSweepRank := cand
    bullSweepLevel := prevDayLow
    bullSweepImp := 1.35
    bullSweepSrc := "PDL"

cand := usePrevWeekLvls ? candidateBull(prevWeekLow, 1.50, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bullSweepRank) or cand > bullSweepRank)
    bullSweepRank := cand
    bullSweepLevel := prevWeekLow
    bullSweepImp := 1.50
    bullSweepSrc := "PWL"

cand := useSessionLevels ? candidateBull(devSessionLow, 1.10, sweepBuf, atr, maxSweepDepthAtr) : na
if not na(cand) and (na(bullSweepRank) or cand > bullSweepRank)
    bullSweepRank := cand
    bullSweepLevel := devSessionLow
    bullSweepImp := 1.10
    bullSweepSrc := "SESSION LOW"

bearSweepFound = barstate.isconfirmed and not na(bearSweepLevel)
bullSweepFound = barstate.isconfirmed and not na(bullSweepLevel)

// Allow more important sweeps to preempt stale pending states.
bullSweepBetter = bullSweepFound and (not pendLong or bullSweepImp > nz(pendLongImp, 0.0))
bearSweepBetter = bearSweepFound and (not pendShort or bearSweepImp > nz(pendShortImp, 0.0))

lowerWick = math.max(math.min(open, close) - low, 0.0)
upperWick = math.max(high - math.max(open, close), 0.0)
lowerWickRatio = lowerWick / barRange
upperWickRatio = upperWick / barRange

if bullSweepBetter
    if pendLong
        recordOutcome(pendLongSource, 2)

    pendLong := true
    pendLongLevel := bullSweepLevel
    pendLongExtreme := low
    pendLongBar := bar_index
    pendLongSource := bullSweepSrc
    pendLongSession := sessionName
    pendLongImp := bullSweepImp
    pendLongWick := lowerWickRatio
    pendLongRvol := rvol

    if showSweepMarkers
        label.new(bar_index, low, "sweep\n" + bullSweepSrc,
             style=label.style_label_up,
             color=color.new(C_BULL, 78),
             textcolor=C_TEXT,
             size=size.tiny,
             tooltip="Bullish liquidity sweep below " + bullSweepSrc + "\nSession: " + sessionName)

if bearSweepBetter
    if pendShort
        recordOutcome(pendShortSource, 2)

    pendShort := true
    pendShortLevel := bearSweepLevel
    pendShortExtreme := high
    pendShortBar := bar_index
    pendShortSource := bearSweepSrc
    pendShortSession := sessionName
    pendShortImp := bearSweepImp
    pendShortWick := upperWickRatio
    pendShortRvol := rvol

    if showSweepMarkers
        label.new(bar_index, high, "sweep\n" + bearSweepSrc,
             style=label.style_label_down,
             color=color.new(C_BEAR, 78),
             textcolor=C_TEXT,
             size=size.tiny,
             tooltip="Bearish liquidity sweep above " + bearSweepSrc + "\nSession: " + sessionName)

// Confirmed-bar-only pending updates.
if pendLong and barstate.isconfirmed
    pendLongExtreme := math.min(pendLongExtreme, low)
    pendLongWick := math.max(pendLongWick, lowerWickRatio)
    pendLongRvol := math.max(pendLongRvol, rvol)

if pendShort and barstate.isconfirmed
    pendShortExtreme := math.max(pendShortExtreme, high)
    pendShortWick := math.max(pendShortWick, upperWickRatio)
    pendShortRvol := math.max(pendShortRvol, rvol)

// ══════════════════════════════════════════════════════════════════════
// OPTIONAL LOWER-TF CONFIRMATION
// ══════════════════════════════════════════════════════════════════════
chartSec = timeframe.in_seconds(timeframe.period)
ltfSec = timeframe.in_seconds(ltfTf)
ltfValid = useLtfConfirm and not na(chartSec) and not na(ltfSec) and ltfSec < chartSec

float ltfLongRatio = na
float ltfShortRatio = na

if useLtfConfirm and ltfValid and barstate.isconfirmed
    ltfCloses = request.security_lower_tf(syminfo.tickerid, ltfTf, close)
    ltfBars = array.size(ltfCloses)

    if ltfBars > 0
        if pendLong and not na(pendLongLevel)
            longAbove = 0
            for i = 0 to ltfBars - 1
                if array.get(ltfCloses, i) > pendLongLevel
                    longAbove += 1
            ltfLongRatio := longAbove / ltfBars

        if pendShort and not na(pendShortLevel)
            shortBelow = 0
            for i = 0 to ltfBars - 1
                if array.get(ltfCloses, i) < pendShortLevel
                    shortBelow += 1
            ltfShortRatio := shortBelow / ltfBars

ltfLongOk = not useLtfConfirm or not ltfValid or (not na(ltfLongRatio) and ltfLongRatio >= ltfMinRatio)
ltfShortOk = not useLtfConfirm or not ltfValid or (not na(ltfShortRatio) and ltfShortRatio >= ltfMinRatio)

// ══════════════════════════════════════════════════════════════════════
// RECOVERY / ACCEPTANCE LOGIC
// ══════════════════════════════════════════════════════════════════════
longBarsSince  = pendLong ? bar_index - pendLongBar : na
shortBarsSince = pendShort ? bar_index - pendShortBar : na

longRecoveredRaw  = pendLong and longBarsSince <= effectiveMaxReclaimBars and close > pendLongLevel + reclaimBuf and barstate.isconfirmed
shortRecoveredRaw = pendShort and shortBarsSince <= effectiveMaxReclaimBars and close < pendShortLevel - reclaimBuf and barstate.isconfirmed

longRecovered = longRecoveredRaw and ltfLongOk
shortRecovered = shortRecoveredRaw and ltfShortOk

longAcceptedBreakdown = pendLong and longBarsSince >= acceptBars and close < pendLongLevel - acceptBuf and barstate.isconfirmed
shortAcceptedBreakout = pendShort and shortBarsSince >= acceptBars and close > pendShortLevel + acceptBuf and barstate.isconfirmed

longExpired  = pendLong and longBarsSince > effectiveMaxReclaimBars
shortExpired = pendShort and shortBarsSince > effectiveMaxReclaimBars

longDepthAtr = pendLong and atr > 0 ? (pendLongLevel - pendLongExtreme) / atr : 0.0
shortDepthAtr = pendShort and atr > 0 ? (pendShortExtreme - pendShortLevel) / atr : 0.0

longSpeed = pendLong ? 1.0 - math.min(longBarsSince, effectiveMaxReclaimBars) / effectiveMaxReclaimBars : 0.0
shortSpeed = pendShort ? 1.0 - math.min(shortBarsSince, effectiveMaxReclaimBars) / effectiveMaxReclaimBars : 0.0

longCloseBack = pendLong and atr > 0 ? math.max(close - pendLongLevel, 0.0) / atr : 0.0
shortCloseBack = pendShort and atr > 0 ? math.max(pendShortLevel - close, 0.0) / atr : 0.0

longFlowScore = nDelta > 0 ? clamp01(nDelta / deltaTarget) : 0.0
shortFlowScore = nDelta < 0 ? clamp01(math.abs(nDelta) / deltaTarget) : 0.0

longFvgConfluence = pendLong and bullFvgActive and overlapsZone(bullFvgTop, bullFvgBot, pendLongLevel, atr * fvgNearAtr)
shortFvgConfluence = pendShort and bearFvgActive and overlapsZone(bearFvgTop, bearFvgBot, pendShortLevel, atr * fvgNearAtr)

longScore = pendLong ? scoreClamp(
     importanceWeight * clamp01(pendLongImp / 1.50) +
     depthWeight * clamp01(longDepthAtr / 0.80) +
     speedWeight * clamp01(longSpeed) +
     wickWeight * clamp01(pendLongWick / minWickRatio) +
     rvolWeight * clamp01(pendLongRvol / rvolTarget) +
     flowWeight * longFlowScore +
     closeBackWeight * clamp01(longCloseBack / 0.50) +
     (longFvgConfluence ? fvgWeight : 0.0)) : 0.0

shortScore = pendShort ? scoreClamp(
     importanceWeight * clamp01(pendShortImp / 1.50) +
     depthWeight * clamp01(shortDepthAtr / 0.80) +
     speedWeight * clamp01(shortSpeed) +
     wickWeight * clamp01(pendShortWick / minWickRatio) +
     rvolWeight * clamp01(pendShortRvol / rvolTarget) +
     flowWeight * shortFlowScore +
     closeBackWeight * clamp01(shortCloseBack / 0.50) +
     (shortFvgConfluence ? fvgWeight : 0.0)) : 0.0

longSignal = longRecovered and longScore >= minRecoveryScore
shortSignal = shortRecovered and shortScore >= minRecoveryScore

longStrong = longSignal and longScore >= strongScore
shortStrong = shortSignal and shortScore >= strongScore

// Snapshot values before state clears.
longSignalSource = pendLongSource
shortSignalSource = pendShortSource
longSignalSession = pendLongSession
shortSignalSession = pendShortSession
longSignalRvol = pendLongRvol
shortSignalRvol = pendShortRvol
longSignalDepth = longDepthAtr
shortSignalDepth = shortDepthAtr
longSignalBars = longBarsSince
shortSignalBars = shortBarsSince
longSignalFvg = longFvgConfluence
shortSignalFvg = shortFvgConfluence

// ══════════════════════════════════════════════════════════════════════
// TARGET SELECTION
// ══════════════════════════════════════════════════════════════════════
float longTarget = na
if not na(swingHigh1) and swingHigh1 > close
    longTarget := swingHigh1
if not na(equalHigh) and equalHigh > close and (na(longTarget) or equalHigh < longTarget)
    longTarget := equalHigh
if not na(prevDayHigh) and prevDayHigh > close and (na(longTarget) or prevDayHigh < longTarget)
    longTarget := prevDayHigh
if not na(prevWeekHigh) and prevWeekHigh > close and (na(longTarget) or prevWeekHigh < longTarget)
    longTarget := prevWeekHigh
if not na(devSessionHigh) and devSessionHigh > close and (na(longTarget) or devSessionHigh < longTarget)
    longTarget := devSessionHigh

float shortTarget = na
if not na(swingLow1) and swingLow1 < close
    shortTarget := swingLow1
if not na(equalLow) and equalLow < close and (na(shortTarget) or equalLow > shortTarget)
    shortTarget := equalLow
if not na(prevDayLow) and prevDayLow < close and (na(shortTarget) or prevDayLow > shortTarget)
    shortTarget := prevDayLow
if not na(prevWeekLow) and prevWeekLow < close and (na(shortTarget) or prevWeekLow > shortTarget)
    shortTarget := prevWeekLow
if not na(devSessionLow) and devSessionLow < close and (na(shortTarget) or devSessionLow > shortTarget)
    shortTarget := devSessionLow

// ══════════════════════════════════════════════════════════════════════
// VISUAL OBJECTS
// ══════════════════════════════════════════════════════════════════════
var array<box> recoveryBoxes = array.new<box>()
var array<line> planLines = array.new<line>()

if longSignal
    labelText = longStrong ? "R+" : "R"
    label.new(bar_index, low - atr * 0.35, labelText,
         style=label.style_label_up,
         color=longStrong ? C_BULL : color.new(C_BULL, 20),
         textcolor=C_BG,
         size=longStrong ? size.normal : size.small,
         tooltip="Bullish Raid Recovery\nScore: " + str.tostring(longScore, "#") +
                 "\nSource: " + longSignalSource +
                 "\nSession: " + longSignalSession +
                 "\nFVG: " + (longSignalFvg ? "Yes" : "No") +
                 "\nSweep depth: " + str.tostring(longSignalDepth, "#.##") + " ATR" +
                 "\nReclaim bars: " + str.tostring(longSignalBars) +
                 "\nRVOL: " + str.tostring(longSignalRvol, "#.##") + "x" +
                 "\nFlow: " + str.tostring(nDelta, "#.###") +
                 "\nRegime: " + volRegime)

    if showRecoveryBoxes
        b = box.new(left=pendLongBar, top=pendLongLevel, right=bar_index + boxForwardBars, bottom=pendLongExtreme,
             border_color=color.new(C_BULL, 58),
             bgcolor=color.new(C_BULL, longStrong ? 88 : 92),
             border_width=1)
        array.push(recoveryBoxes, b)
        if array.size(recoveryBoxes) > maxRecoveryBoxes
            old = array.shift(recoveryBoxes)
            if not na(old)
                box.delete(old)

    if showStopTargets
        stopLine = line.new(bar_index, pendLongExtreme, bar_index + targetForwardBars, pendLongExtreme,
             color=color.new(C_BEAR, 45), style=line.style_dashed, width=1)
        array.push(planLines, stopLine)

        if not na(longTarget)
            targetLine = line.new(bar_index, longTarget, bar_index + targetForwardBars, longTarget,
                 color=color.new(C_BULL, 45), style=line.style_dashed, width=1)
            array.push(planLines, targetLine)

        while array.size(planLines) > maxPlanSets * 2
            oldLine = array.shift(planLines)
            if not na(oldLine)
                line.delete(oldLine)

if shortSignal
    labelText = shortStrong ? "R+" : "R"
    label.new(bar_index, high + atr * 0.35, labelText,
         style=label.style_label_down,
         color=shortStrong ? C_BEAR : color.new(C_BEAR, 20),
         textcolor=C_TEXT,
         size=shortStrong ? size.normal : size.small,
         tooltip="Bearish Raid Recovery\nScore: " + str.tostring(shortScore, "#") +
                 "\nSource: " + shortSignalSource +
                 "\nSession: " + shortSignalSession +
                 "\nFVG: " + (shortSignalFvg ? "Yes" : "No") +
                 "\nSweep depth: " + str.tostring(shortSignalDepth, "#.##") + " ATR" +
                 "\nReclaim bars: " + str.tostring(shortSignalBars) +
                 "\nRVOL: " + str.tostring(shortSignalRvol, "#.##") + "x" +
                 "\nFlow: " + str.tostring(nDelta, "#.###") +
                 "\nRegime: " + volRegime)

    if showRecoveryBoxes
        b = box.new(left=pendShortBar, top=pendShortExtreme, right=bar_index + boxForwardBars, bottom=pendShortLevel,
             border_color=color.new(C_BEAR, 58),
             bgcolor=color.new(C_BEAR, shortStrong ? 88 : 92),
             border_width=1)
        array.push(recoveryBoxes, b)
        if array.size(recoveryBoxes) > maxRecoveryBoxes
            old = array.shift(recoveryBoxes)
            if not na(old)
                box.delete(old)

    if showStopTargets
        stopLine = line.new(bar_index, pendShortExtreme, bar_index + targetForwardBars, pendShortExtreme,
             color=color.new(C_BULL, 45), style=line.style_dashed, width=1)
        array.push(planLines, stopLine)

        if not na(shortTarget)
            targetLine = line.new(bar_index, shortTarget, bar_index + targetForwardBars, shortTarget,
                 color=color.new(C_BEAR, 45), style=line.style_dashed, width=1)
            array.push(planLines, targetLine)

        while array.size(planLines) > maxPlanSets * 2
            oldLine = array.shift(planLines)
            if not na(oldLine)
                line.delete(oldLine)

if showAcceptedBreaks and longAcceptedBreakdown
    label.new(bar_index, low, "ACCEPT ↓",
         style=label.style_label_down,
         color=color.new(C_BEAR, 55),
         textcolor=C_TEXT,
         size=size.tiny,
         tooltip="Accepted breakdown after liquidity sweep.\nSource: " + longSignalSource)

if showAcceptedBreaks and shortAcceptedBreakout
    label.new(bar_index, high, "ACCEPT ↑",
         style=label.style_label_up,
         color=color.new(C_BULL, 55),
         textcolor=C_BG,
         size=size.tiny,
         tooltip="Accepted breakout after liquidity sweep.\nSource: " + shortSignalSource)

// Track last signal before clearing state.
var string lastSignal = "NONE"
var float lastScore = na
var string lastSource = ""

if longSignal
    lastSignal := longStrong ? "R+ LONG" : "R LONG"
    lastScore := longScore
    lastSource := longSignalSource

if shortSignal
    lastSignal := shortStrong ? "R+ SHORT" : "R SHORT"
    lastScore := shortScore
    lastSource := shortSignalSource

// Record outcomes before clearing state.
if longRecovered
    recordOutcome(longSignalSource, 0)

if shortRecovered
    recordOutcome(shortSignalSource, 0)

if longAcceptedBreakdown
    recordOutcome(longSignalSource, 1)

if shortAcceptedBreakout
    recordOutcome(shortSignalSource, 1)

if longExpired
    recordOutcome(longSignalSource, 2)

if shortExpired
    recordOutcome(shortSignalSource, 2)

// Clear pending states after resolution.
if longRecovered or longAcceptedBreakdown or longExpired
    pendLong := false
    pendLongLevel := na
    pendLongExtreme := na
    pendLongBar := na
    pendLongSource := ""
    pendLongSession := ""
    pendLongImp := na
    pendLongWick := na
    pendLongRvol := na

if shortRecovered or shortAcceptedBreakout or shortExpired
    pendShort := false
    pendShortLevel := na
    pendShortExtreme := na
    pendShortBar := na
    pendShortSource := ""
    pendShortSession := ""
    pendShortImp := na
    pendShortWick := na
    pendShortRvol := na

// ══════════════════════════════════════════════════════════════════════
// LEVEL PLOTS
// ══════════════════════════════════════════════════════════════════════
plot(showLiquidityLevels and useSwingLevels and levelVisible(swingHigh1, atr) ? swingHigh1 : na, "Swing High Liquidity", color=color.new(C_BEAR, 78), linewidth=1, style=plot.style_linebr)
plot(showLiquidityLevels and useSwingLevels and levelVisible(swingLow1, atr) ? swingLow1 : na, "Swing Low Liquidity", color=color.new(C_BULL, 78), linewidth=1, style=plot.style_linebr)

plot(showLiquidityLevels and useEqualLevels and levelVisible(equalHigh, atr) ? equalHigh : na, "Equal High Liquidity", color=color.new(C_BEAR, 62), linewidth=1, style=plot.style_linebr)
plot(showLiquidityLevels and useEqualLevels and levelVisible(equalLow, atr) ? equalLow : na, "Equal Low Liquidity", color=color.new(C_BULL, 62), linewidth=1, style=plot.style_linebr)

plot(showLiquidityLevels and usePrevDayLevels and levelVisible(prevDayHigh, atr) ? prevDayHigh : na, "Previous Day High", color=color.new(C_BEAR, 72), linewidth=1, style=plot.style_linebr)
plot(showLiquidityLevels and usePrevDayLevels and levelVisible(prevDayLow, atr) ? prevDayLow : na, "Previous Day Low", color=color.new(C_BULL, 72), linewidth=1, style=plot.style_linebr)

plot(showLiquidityLevels and usePrevWeekLvls and levelVisible(prevWeekHigh, atr) ? prevWeekHigh : na, "Previous Week High", color=color.new(C_BEAR, 84), linewidth=1, style=plot.style_linebr)
plot(showLiquidityLevels and usePrevWeekLvls and levelVisible(prevWeekLow, atr) ? prevWeekLow : na, "Previous Week Low", color=color.new(C_BULL, 84), linewidth=1, style=plot.style_linebr)

plot(showLiquidityLevels and useSessionLevels and levelVisible(devSessionHigh, atr) ? devSessionHigh : na, "Developing Session High", color=color.new(C_BEAR, 88), linewidth=1, style=plot.style_linebr)
plot(showLiquidityLevels and useSessionLevels and levelVisible(devSessionLow, atr) ? devSessionLow : na, "Developing Session Low", color=color.new(C_BULL, 88), linewidth=1, style=plot.style_linebr)

plot(pendLong ? pendLongLevel : na, "Pending Bullish Reclaim Level", color=color.new(C_BULL, 25), linewidth=2, style=plot.style_linebr)
plot(pendShort ? pendShortLevel : na, "Pending Bearish Reclaim Level", color=color.new(C_BEAR, 25), linewidth=2, style=plot.style_linebr)

plot(showEMA ? ema50 : na, "EMA 50", color=color.new(C_INFO, 30), linewidth=1)
plot(showYVWAP ? yVwap : na, "Yearly VWAP", color=color.new(C_WARN, 30), linewidth=1)

// ══════════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════════
var table dash = na

if barstate.isfirst
    dash := table.new(position.top_right, 6, 2,
         bgcolor=color.new(C_BG2, 5),
         border_color=color.new(C_DIM, 50),
         border_width=1,
         frame_color=color.new(C_DIM, 25),
         frame_width=1)

if barstate.islast and not na(dash)
    if showDashboard
        stateTxt =
             pendLong and pendShort ? "DUAL RAID" :
             pendLong ? "PENDING LONG" :
             pendShort ? "PENDING SHORT" :
             "WATCHING"

        stateCol =
             pendLong ? C_BULL :
             pendShort ? C_BEAR :
             C_DIM

        pendingTxt =
             pendLong ? pendLongSource :
             pendShort ? pendShortSource :
             "NONE"

        scoreTxt = na(lastScore) ? "—" : str.tostring(lastScore, "#")

        flowTxt = str.tostring(nDelta * 100, "#") + "% | " + str.tostring(rvol, "#.1") + "x"
        flowCol = nDelta > 0 ? C_BULL : nDelta < 0 ? C_BEAR : C_DIM

        biasTxt = bullStack ? "BULL STACK" : bearStack ? "BEAR STACK" : "NEUTRAL"
        biasCol = bullStack ? C_BULL : bearStack ? C_BEAR : C_DIM

        ltfTxt = not useLtfConfirm ? "OFF" : ltfValid ? "ON" : "INVALID"

        table.cell(dash, 0, 0, "STATE", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 1, 0, "PENDING", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 2, 0, "LAST", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 3, 0, "FLOW", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 4, 0, "BIAS", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(dash, 5, 0, "REGIME", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)

        table.cell(dash, 0, 1, stateTxt, text_color=stateCol, text_size=size.small, text_halign=text.align_center)
        table.cell(dash, 1, 1, pendingTxt, text_color=stateCol, text_size=size.small, text_halign=text.align_center)
        table.cell(dash, 2, 1, lastSignal + " | " + scoreTxt, text_color=lastSignal == "NONE" ? C_DIM : str.contains(lastSignal, "LONG") ? C_BULL : C_BEAR, text_size=size.small, text_halign=text.align_center)
        table.cell(dash, 3, 1, flowTxt, text_color=flowCol, text_size=size.small, text_halign=text.align_center)
        table.cell(dash, 4, 1, biasTxt, text_color=biasCol, text_size=size.small, text_halign=text.align_center)
        table.cell(dash, 5, 1, volRegime + " | LTF " + ltfTxt, text_color=C_INFO, text_size=size.small, text_halign=text.align_center)
    else
        for c = 0 to 5
            table.cell(dash, c, 0, "")
            table.cell(dash, c, 1, "")

// ══════════════════════════════════════════════════════════════════════
// OUTCOME STATISTICS TABLE
// ══════════════════════════════════════════════════════════════════════
var table statTbl = na

if barstate.isfirst
    statTbl := table.new(position.bottom_right, 5, 6,
         bgcolor=color.new(C_BG2, 8),
         border_color=color.new(C_DIM, 55),
         border_width=1,
         frame_color=color.new(C_DIM, 35),
         frame_width=1)

if barstate.islast and not na(statTbl)
    if showStatsTable
        table.cell(statTbl, 0, 0, "SOURCE", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(statTbl, 1, 0, "TOTAL", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(statTbl, 2, 0, "REC", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(statTbl, 3, 0, "ACC", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)
        table.cell(statTbl, 4, 0, "RATE", text_color=C_DIM, text_size=size.tiny, text_halign=text.align_center)

        for row = 1 to 5
            bucket = row == 1 ? "SWING" : row == 2 ? "EQUAL" : row == 3 ? "PD" : row == 4 ? "PW" : "SESSION"
            total = 0
            recovered = 0
            accepted = 0

            for i = 0 to array.size(histSource) - 1
                if array.get(histSource, i) == bucket
                    total += 1
                    out = array.get(histOutcome, i)
                    if out == 0
                        recovered += 1
                    if out == 1
                        accepted += 1

            rate = total > 0 ? recovered / total * 100.0 : na
            rateTxt = na(rate) ? "—" : str.tostring(rate, "#") + "%"
            rateCol = na(rate) ? C_DIM : rate >= 60 ? C_BULL : rate >= 40 ? C_WARN : C_BEAR

            table.cell(statTbl, 0, row, bucket, text_color=C_TEXT, text_size=size.tiny, text_halign=text.align_center)
            table.cell(statTbl, 1, row, str.tostring(total), text_color=C_TEXT, text_size=size.tiny, text_halign=text.align_center)
            table.cell(statTbl, 2, row, str.tostring(recovered), text_color=C_BULL, text_size=size.tiny, text_halign=text.align_center)
            table.cell(statTbl, 3, row, str.tostring(accepted), text_color=C_BEAR, text_size=size.tiny, text_halign=text.align_center)
            table.cell(statTbl, 4, row, rateTxt, text_color=rateCol, text_size=size.tiny, text_halign=text.align_center)
    else
        for r = 0 to 5
            for c = 0 to 4
                table.cell(statTbl, c, r, "")

// ══════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════
alertcondition(longSignal, "Bullish Raid Recovery", "Structure Flow Raid Recovery - Bullish Recovery")
alertcondition(shortSignal, "Bearish Raid Recovery", "Structure Flow Raid Recovery - Bearish Recovery")
alertcondition(longStrong, "Strong Bullish Raid Recovery", "Structure Flow Raid Recovery - Strong Bullish Recovery")
alertcondition(shortStrong, "Strong Bearish Raid Recovery", "Structure Flow Raid Recovery - Strong Bearish Recovery")
alertcondition(longAcceptedBreakdown, "Accepted Breakdown After Sweep", "Structure Flow Raid Recovery - Accepted Breakdown")
alertcondition(shortAcceptedBreakout, "Accepted Breakout After Sweep", "Structure Flow Raid Recovery - Accepted Breakout")

if enableDynamicAlerts and longSignal
    alert("Structure Flow Raid Recovery | " + (longStrong ? "R+ LONG" : "R LONG") +
          " | Score: " + str.tostring(longScore, "#") +
          " | Source: " + longSignalSource +
          " | Session: " + longSignalSession +
          " | FVG: " + (longSignalFvg ? "Yes" : "No") +
          " | Depth: " + str.tostring(longSignalDepth, "#.##") + " ATR" +
          " | RVOL: " + str.tostring(longSignalRvol, "#.##") + "x" +
          " | Flow: " + str.tostring(nDelta, "#.###"),
          alert.freq_once_per_bar_close)

if enableDynamicAlerts and shortSignal
    alert("Structure Flow Raid Recovery | " + (shortStrong ? "R+ SHORT" : "R SHORT") +
          " | Score: " + str.tostring(shortScore, "#") +
          " | Source: " + shortSignalSource +
          " | Session: " + shortSignalSession +
          " | FVG: " + (shortSignalFvg ? "Yes" : "No") +
          " | Depth: " + str.tostring(shortSignalDepth, "#.##") + " ATR" +
          " | RVOL: " + str.tostring(shortSignalRvol, "#.##") + "x" +
          " | Flow: " + str.tostring(nDelta, "#.###"),
          alert.freq_once_per_bar_close)
````
