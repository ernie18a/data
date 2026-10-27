# Meridian Regime Overlay [JOAT]

- url: https://www.tradingview.com/script/Y1UNMVbS-Meridian-Regime-Overlay-JOAT/
- type: indicator
- pine_id: PUB;bfc5ebd49a634dd9af141d04771afe42
- version: 1.0

## Description

[b]JOAT Meridian Regime Overlay [JOAT][/b]

[b]Introduction[/b]

JOAT Meridian Regime Overlay is an open-source market context overlay built to classify whether price is operating in directional expansion, balanced auction, or compression.

It is designed as a chart-first regime engine rather than a standalone trigger study.

The script combines local baseline alignment, confirmed higher-timeframe bias, pivot structure, opening-range acceptance, realized volatility state, and session VWAP location into one integrated regime map.

The problem it solves is context.

Many indicators can say whether price is above or below an average.

Far fewer explain whether the move is supported by volatility expansion, structural acceptance, value migration, and higher-timeframe alignment.

Meridian Regime Overlay focuses on that exact problem.

It grades the live auction bar by bar.

It also shows what is supporting the grade.

That makes it useful as a decision filter before interpreting any lower-level signal source.

This script is not trying to predict the future.

Its job is to organize the present market condition.

It helps answer practical questions:

Is the market trending with real conviction?

Is price only drifting above a baseline without expansion?

Is the market compressing near a likely release point?

Is higher-timeframe structure aligned with the current move?

Is price accepting away from value or simply rotating around it?

[image]https://www.tradingview.com/x/0I2BM6Vv/[/image]

[b]Core Concepts[/b]

[b]1. Baseline Stack Alignment[/b]

Fast, slow, and anchor baselines define the local directional stack.

Directional strength improves when those baselines align in sequence and their slopes support the move.

[pine]
fastBase   = ta.ema(close, fastLen)
slowBase   = ta.ema(close, slowLen)
anchorBase = ta.ema(close, anchorLen)
[/pine]

[b]2. Confirmed Higher-Timeframe Bias[/b]

Higher-timeframe context is pulled using confirmed values only.

This avoids depending on unfinished HTF candles.

[pine]
htfFast   = request.security(syminfo.tickerid, biasTf, ta.ema(close[1], fastLen), lookahead = barmerge.lookahead_on)
htfSlow   = request.security(syminfo.tickerid, biasTf, ta.ema(close[1], slowLen), lookahead = barmerge.lookahead_on)
htfAnchor = request.security(syminfo.tickerid, biasTf, ta.ema(close[1], anchorLen), lookahead = barmerge.lookahead_on)
[/pine]

[b]3. Compression and Expansion State[/b]

The script compares Bollinger width and Keltner position to identify squeeze behavior and release behavior.

ADX and realized variance refine the classification.

[b]4. Pivot Structure State[/b]

Confirmed pivots define recent structural reference points.

Breaks through those pivots update the structural state.

[b]5. Session VWAP Context[/b]

Distance from session VWAP is normalized in ATR units.

This helps reveal whether price is auctioning away from value with intent or just rotating around it.

[b]6. Opening-Range Acceptance[/b]

The opening range is tracked and plotted.

Acceptance above or below that range adds useful early-session context.

[b]7. Composite Regime Score[/b]

Multiple directional variables are folded into a single regime score.

The score is a context summary, not a standalone trade signal.

[b]8. Confirmed Event Labels[/b]

The overlay prints confirmed auction-up, auction-down, and squeeze-release labels directly on the chart.

[image]https://www.tradingview.com/x/Iwj3Gn1N/[/image]

[b]Features[/b]

[list]
[*][b]Directional regime classification:[/b] bullish expansion, bearish expansion, balance, and compression states
[*][b]Baseline cloud system:[/b] fast and slow cloud for local trend stack
[*][b]Confirmed HTF alignment:[/b] higher-timeframe bias uses confirmed values only
[*][b]Opening-range plotting:[/b] high, low, and midpoint are tracked
[*][b]Session VWAP context:[/b] value migration is integrated into the read
[*][b]Pivot structure state:[/b] recent structural breaks are tracked
[*][b]Compression and release logic:[/b] squeeze and expansion state are visualized
[*][b]Bar-state coloring:[/b] candles transition with regime intensity
[*][b]Confirmed event labels:[/b] auction and expansion markers print on the chart
[*][b]Dashboard:[/b] summarizes regime, score, HTF, structure, volatility, and VWAP context
[/list]

[b]Input Parameters[/b]

[b]Trend Engine:[/b]

[list]
[*]Fast Baseline
[*]Slow Baseline
[*]Anchor Baseline
[*]Adaptive Mean Length
[*]Bias Timeframe
[*]Slope Lookback
[*]Slope Threshold ATR
[*]RVOL Impulse Threshold
[/list]

[b]Volatility Engine:[/b]

[list]
[*]ATR Length
[*]Compression Length
[*]Band Deviation
[*]Keltner Length
[*]Keltner Multiplier
[*]ADX Length
[*]ADX Floor
[*]Expansion Threshold
[*]Realized Variance Length
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read the regime color, cloud, and dashboard state.

[b]Step 2:[/b] Check higher-timeframe alignment before trusting directional continuation.

[b]Step 3:[/b] Compare structure and VWAP position to see whether price is accepting away from value.

[b]Step 4:[/b] Watch squeeze-release transitions closely because those often precede cleaner directional movement.

[b]Step 5:[/b] Use the script as a context filter for other tools rather than as a complete trading system.

[b]Indicator Limitations[/b]

[list]
[*]Pivot structure confirms after the pivot fully forms, which is intentional non-repainting behavior
[*]Higher-timeframe values are confirmed and therefore intentionally delayed
[*]Compression can persist longer than expected in slow auction environments
[*]Directional classification does not guarantee continuation
[/list]

[b]Originality Statement[/b]

This publication is original in the way it integrates baseline structure, confirmed higher-timeframe bias, compression state, realized variance, session VWAP, opening-range acceptance, and pivot structure into one unified regime overlay.

The components are not combined arbitrarily.

They all answer the same core question:

what is the current quality of the auction?

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not financial advice.

Market regimes can shift quickly.

All readings are based on historical and current bar data and do not guarantee future performance.

Always use independent analysis and risk management.

[b]Best Use Cases[/b]

[list]
[*]Directional trend filtering before using a separate trigger model
[*]Session context analysis during London and New York activity
[*]Volatility transition analysis when compression begins to release
[*]Structure-aware regime filtering for discretionary execution
[/list]

[b]Interpretation Notes[/b]

The strongest readings usually occur when the local stack, confirmed higher-timeframe stack, VWAP position, and volatility expansion agree.

If only one or two of those are aligned, the chart can still move, but the regime read is weaker.

Compression should not be treated as a bearish or bullish state by itself.

It is a warning that the market is withholding directional commitment.

Opening-range acceptance adds value because many directional sessions reveal their intent early.

When price cannot hold outside the opening range, the regime should usually be treated more cautiously.

[b]Publication Notes[/b]

This script is intended to be published with a clean chart where the cloud, baselines, opening range, and event labels are clearly visible.

The chart should not be cluttered with unrelated overlays.

If showing an example image, the regime state and at least one structural transition should be identifiable at a glance.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Meridian Regime Overlay [JOAT]", shorttitle = "MRO [JOAT]", overlay = true, max_lines_count = 160, max_labels_count = 120, max_boxes_count = 40)

string groupTrend = "Trend Engine"
string groupVolatility = "Volatility Engine"
string groupStructure = "Structure Engine"
string groupSessions = "Session Context"
string groupDisplay = "Display"
string groupDashboard = "Dashboard"

int fastLen = input.int(21, "Fast Baseline", minval = 2, group = groupTrend)
int slowLen = input.int(55, "Slow Baseline", minval = 5, group = groupTrend)
int anchorLen = input.int(144, "Anchor Baseline", minval = 20, group = groupTrend)
int hullLen = input.int(34, "Adaptive Mean", minval = 5, group = groupTrend)
string biasTf = input.timeframe("240", "Bias Timeframe", group = groupTrend)
int slopeLookback = input.int(8, "Slope Lookback", minval = 1, group = groupTrend)
float slopeThreshold = input.float(0.08, "Slope Threshold ATR", minval = 0.01, step = 0.01, group = groupTrend)
float rvolTrendBoost = input.float(1.15, "RVOL Impulse Threshold", minval = 0.5, step = 0.05, group = groupTrend)

int atrLen = input.int(14, "ATR Length", minval = 1, group = groupVolatility)
int bbLen = input.int(20, "Compression Length", minval = 5, group = groupVolatility)
float bbDev = input.float(2.0, "Band Deviation", minval = 0.5, step = 0.1, group = groupVolatility)
int kcLen = input.int(20, "Keltner Length", minval = 5, group = groupVolatility)
float kcMult = input.float(1.5, "Keltner Multiplier", minval = 0.1, step = 0.1, group = groupVolatility)
int adxLen = input.int(14, "ADX Length", minval = 2, group = groupVolatility)
float adxFloor = input.float(18.0, "ADX Floor", minval = 5.0, step = 0.5, group = groupVolatility)
float expansionFactor = input.float(1.12, "Expansion Threshold", minval = 0.5, step = 0.01, group = groupVolatility)
int realizedLen = input.int(30, "Realized Variance Length", minval = 10, group = groupVolatility)

int swingLen = input.int(5, "Swing Length", minval = 2, group = groupStructure)
int structureMemory = input.int(80, "Structure Memory Bars", minval = 10, group = groupStructure)
bool useOpeningRange = input.bool(true, "Track Opening Range", group = groupStructure)
string openingRangeSession = input.session("0930-1030", "Opening Range Window", group = groupStructure)

string londonSession = input.session("0300-0600", "London Window", group = groupSessions)
string newYorkSession = input.session("0930-1130", "New York Window", group = groupSessions)
string closingSession = input.session("1500-1600", "Closing Window", group = groupSessions)

bool showCloud = input.bool(true, "Show Bias Cloud", group = groupDisplay)
bool showBands = input.bool(true, "Show Deviation Bands", group = groupDisplay)
bool showOpeningRangePlot = input.bool(true, "Show Opening Range", group = groupDisplay)
bool showBackdrop = input.bool(true, "Show Session Backdrop", group = groupDisplay)
bool showStateLabel = input.bool(true, "Show State Label", group = groupDisplay)
bool showSignals = input.bool(true, "Show Signals", group = groupDisplay)
bool tintBars = input.bool(true, "Tint Bars", group = groupDisplay)

bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)

color bullStrong = input.color(color.rgb(16, 190, 141), "Bull Expansion", group = groupDisplay)
color bullSoft = input.color(color.rgb(82, 201, 171), "Bull Drift", group = groupDisplay)
color bearStrong = input.color(color.rgb(214, 88, 114), "Bear Expansion", group = groupDisplay)
color bearSoft = input.color(color.rgb(178, 106, 124), "Bear Drift", group = groupDisplay)
color neutralTone = input.color(color.rgb(125, 138, 162), "Neutral", group = groupDisplay)
color compressionTone = input.color(color.rgb(88, 104, 140), "Compression", group = groupDisplay)
color vwapColor = input.color(color.rgb(236, 186, 84), "Session VWAP", group = groupDisplay)
color openingRangeColor = input.color(color.rgb(110, 143, 222), "Opening Range", group = groupDisplay)
color dashboardBg = input.color(color.rgb(13, 18, 28), "Dashboard Background", group = groupDashboard)
color dashboardBorder = input.color(color.rgb(36, 50, 71), "Dashboard Border", group = groupDashboard)

f_in_session(string sessionSpec) =>
    not na(time(timeframe.period, sessionSpec))

f_non_repaint_ema(string tf, int len) =>
    request.security(syminfo.tickerid, tf, ta.ema(close, len)[1], lookahead = barmerge.lookahead_on)

f_non_repaint_close(string tf) =>
    request.security(syminfo.tickerid, tf, close[1], lookahead = barmerge.lookahead_on)

f_bias_text(int score) =>
    score >= 6 ? "Institutional Uptrend" :
     score >= 3 ? "Accumulation Uptrend" :
     score <= -6 ? "Institutional Downtrend" :
     score <= -3 ? "Distribution Downtrend" :
     "Balanced Rotation"

f_regime_text(int regimeCode) =>
    regimeCode == 3 ? "Auction Up" :
     regimeCode == 2 ? "Trend Up" :
     regimeCode == 1 ? "Rotation Up" :
     regimeCode == -1 ? "Rotation Down" :
     regimeCode == -2 ? "Trend Down" :
     regimeCode == -3 ? "Auction Down" :
     "Compression"

f_score_color(int score) =>
    score >= 6 ? bullStrong :
     score >= 3 ? bullSoft :
     score <= -6 ? bearStrong :
     score <= -3 ? bearSoft :
     compressionTone

f_volatility_text(float rv, float meanValue, float devValue) =>
    rv > meanValue + devValue ? "Elevated" :
     rv < meanValue - devValue * 0.5 ? "Quiet" :
     "Balanced"

float fastBase = ta.ema(close, fastLen)
float slowBase = ta.ema(close, slowLen)
float anchorBase = ta.ema(close, anchorLen)
float adaptiveMean = ta.hma(close, hullLen)
float atrValue = ta.atr(atrLen)

float fastSlopeRaw = fastBase - fastBase[slopeLookback]
float slowSlopeRaw = slowBase - slowBase[slopeLookback]
float fastSlopeAtr = atrValue > 0 ? fastSlopeRaw / atrValue : 0.0
float slowSlopeAtr = atrValue > 0 ? slowSlopeRaw / atrValue : 0.0

float htfFast = f_non_repaint_ema(biasTf, fastLen)
float htfSlow = f_non_repaint_ema(biasTf, slowLen)
float htfAnchor = f_non_repaint_ema(biasTf, anchorLen)
float htfClose = f_non_repaint_close(biasTf)

float dayTypical = hlc3
bool newDay = ta.change(time("D")) != 0
var float dayCumPv = na
var float dayCumVol = na
if newDay or na(dayCumPv)
    dayCumPv := dayTypical * volume
    dayCumVol := volume
else
    dayCumPv += dayTypical * volume
    dayCumVol += volume
float sessionVwap = dayCumVol > 0 ? dayCumPv / dayCumVol : close

float volumeMean = ta.sma(volume, 20)
float relativeVolume = volumeMean > 0 ? volume / volumeMean : 1.0
float bodySize = math.abs(close - open)
float averageBody = ta.sma(bodySize, 20)
bool bullishImpulseBar = close > open and bodySize > averageBody * 1.1 and relativeVolume >= rvolTrendBoost
bool bearishImpulseBar = close < open and bodySize > averageBody * 1.1 and relativeVolume >= rvolTrendBoost

float bbBasis = ta.ema(close, bbLen)
float bbDeviation = ta.stdev(close, bbLen)
float bbUpper = bbBasis + bbDeviation * bbDev
float bbLower = bbBasis - bbDeviation * bbDev
float bbWidth = bbBasis != 0 ? (bbUpper - bbLower) / bbBasis : 0.0
float bbWidthMean = ta.sma(bbWidth, bbLen)
float bbWidthDev = ta.stdev(bbWidth, bbLen)

float kcBasis = ta.ema(close, kcLen)
float kcRange = ta.ema(ta.tr(true), kcLen)
float kcUpper = kcBasis + kcRange * kcMult
float kcLower = kcBasis - kcRange * kcMult

bool squeezeOn = bbUpper < kcUpper and bbLower > kcLower
bool expansion = bbWidthMean > 0 and bbWidth > bbWidthMean * expansionFactor and bbWidth > nz(bbWidth[1])

[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxLen)
bool positiveDirectionalControl = diPlus > diMinus and adxValue >= adxFloor
bool negativeDirectionalControl = diMinus > diPlus and adxValue >= adxFloor

float logReturn = na(close[1]) or close[1] <= 0 ? 0.0 : math.log(close / close[1])
float realizedVariance = ta.ema(logReturn * logReturn, realizedLen)
float realizedMean = ta.sma(realizedVariance, realizedLen)
float realizedDev = ta.stdev(realizedVariance, realizedLen)
string volatilityState = f_volatility_text(realizedVariance, realizedMean, realizedDev)

float pivotHigh = ta.pivothigh(high, swingLen, swingLen)
float pivotLow = ta.pivotlow(low, swingLen, swingLen)
var float lastPivotHigh = na
var float lastPivotLow = na
var int lastPivotHighBar = na
var int lastPivotLowBar = na
if not na(pivotHigh)
    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index - swingLen
if not na(pivotLow)
    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index - swingLen

bool structureBreakUp = not na(lastPivotHigh) and not na(lastPivotHighBar) and bar_index - lastPivotHighBar <= structureMemory and close > lastPivotHigh and close[1] <= lastPivotHigh
bool structureBreakDown = not na(lastPivotLow) and not na(lastPivotLowBar) and bar_index - lastPivotLowBar <= structureMemory and close < lastPivotLow and close[1] >= lastPivotLow

var int structureState = 0
if structureBreakUp and barstate.isconfirmed
    structureState := 1
if structureBreakDown and barstate.isconfirmed
    structureState := -1

bool inOpeningRange = f_in_session(openingRangeSession)
var float openingRangeHigh = na
var float openingRangeLow = na
if newDay
    openingRangeHigh := na
    openingRangeLow := na
if useOpeningRange and inOpeningRange
    openingRangeHigh := na(openingRangeHigh) ? high : math.max(openingRangeHigh, high)
    openingRangeLow := na(openingRangeLow) ? low : math.min(openingRangeLow, low)
float openingRangeMid = na(openingRangeHigh) or na(openingRangeLow) ? na : (openingRangeHigh + openingRangeLow) * 0.5
bool openingRangeAcceptedUp = useOpeningRange and not na(openingRangeHigh) and close > openingRangeHigh
bool openingRangeAcceptedDown = useOpeningRange and not na(openingRangeLow) and close < openingRangeLow

bool localBullStack = fastBase > slowBase and slowBase > anchorBase
bool localBearStack = fastBase < slowBase and slowBase < anchorBase
bool htfBullStack = htfFast > htfSlow and htfSlow > htfAnchor
bool htfBearStack = htfFast < htfSlow and htfSlow < htfAnchor
bool aboveVwap = close > sessionVwap
bool belowVwap = close < sessionVwap

int compositeScore = 0
compositeScore += fastBase > slowBase ? 1 : fastBase < slowBase ? -1 : 0
compositeScore += slowBase > anchorBase ? 1 : slowBase < anchorBase ? -1 : 0
compositeScore += htfFast > htfSlow ? 1 : htfFast < htfSlow ? -1 : 0
compositeScore += htfSlow > htfAnchor ? 1 : htfSlow < htfAnchor ? -1 : 0
compositeScore += aboveVwap ? 1 : belowVwap ? -1 : 0
compositeScore += fastSlopeAtr > slopeThreshold ? 1 : fastSlopeAtr < -slopeThreshold ? -1 : 0
compositeScore += structureState
compositeScore += positiveDirectionalControl ? 1 : negativeDirectionalControl ? -1 : 0
compositeScore += bullishImpulseBar ? 1 : bearishImpulseBar ? -1 : 0
compositeScore += openingRangeAcceptedUp ? 1 : openingRangeAcceptedDown ? -1 : 0

int clampedScore = math.max(-8, math.min(8, compositeScore))
int regimeCode = squeezeOn ? 0 : clampedScore >= 6 and expansion ? 3 : clampedScore >= 3 ? 2 : clampedScore > 0 ? 1 : clampedScore <= -6 and expansion ? -3 : clampedScore <= -3 ? -2 : clampedScore < 0 ? -1 : 0
string biasText = f_bias_text(clampedScore)
string regimeText = f_regime_text(regimeCode)
color regimeColor = f_score_color(clampedScore)

bool inLondon = f_in_session(londonSession)
bool inNewYork = f_in_session(newYorkSession)
bool inClosing = f_in_session(closingSession)
string sessionState = inLondon ? "London" : inNewYork ? "New York" : inClosing ? "Close" : "Off Session"
color sessionBackdrop = not showBackdrop ? na : inLondon ? color.new(color.rgb(25, 66, 108), 90) : inNewYork ? color.new(color.rgb(73, 39, 104), 90) : inClosing ? color.new(color.rgb(84, 56, 34), 90) : na

float fastBandWidth = atrValue * 0.35
float slowBandWidth = atrValue * 0.70
float anchorBandWidth = atrValue * 1.10

float fastUpper = fastBase + fastBandWidth
float fastLower = fastBase - fastBandWidth
float slowUpper = slowBase + slowBandWidth
float slowLower = slowBase - slowBandWidth
float anchorUpper = anchorBase + anchorBandWidth
float anchorLower = anchorBase - anchorBandWidth

float vwapDistanceAtr = atrValue > 0 ? (close - sessionVwap) / atrValue : 0.0
float anchorDistanceAtr = atrValue > 0 ? (close - anchorBase) / atrValue : 0.0

color cloudColor = localBullStack and htfBullStack ? color.new(bullStrong, 82) : localBearStack and htfBearStack ? color.new(bearStrong, 82) : color.new(neutralTone, 86)
color slowCloudColor = close > anchorBase ? color.new(bullSoft, 92) : close < anchorBase ? color.new(bearSoft, 92) : color.new(neutralTone, 94)
color candleTone = regimeCode == 3 ? bullStrong : regimeCode == 2 ? bullSoft : regimeCode == 1 ? color.new(bullSoft, 15) : regimeCode == -1 ? color.new(bearSoft, 15) : regimeCode == -2 ? bearSoft : regimeCode == -3 ? bearStrong : compressionTone

plotFast = plot(showCloud ? fastBase : na, "Fast Baseline", color = color.new(color.white, 100))
plotSlow = plot(showCloud ? slowBase : na, "Slow Baseline", color = color.new(color.white, 100))
fill(plotFast, plotSlow, cloudColor, title = "Bias Cloud")

plotSlowUpper = plot(showCloud ? slowUpper : na, "Slow Upper Envelope", color = color.new(regimeColor, 65), linewidth = 1)
plotSlowLower = plot(showCloud ? slowLower : na, "Slow Lower Envelope", color = color.new(regimeColor, 65), linewidth = 1)
fill(plotSlowUpper, plotSlowLower, slowCloudColor, title = "Slow Envelope")

plotFastUpper = plot(showBands ? fastUpper : na, "Fast Upper Rail", color = color.new(regimeColor, 30), linewidth = 1)
plotFastLower = plot(showBands ? fastLower : na, "Fast Lower Rail", color = color.new(regimeColor, 30), linewidth = 1)
fill(plotFastUpper, plotFastLower, color.new(regimeColor, 90), title = "Fast Rail Fill")

plotAnchorUpper = plot(showBands ? anchorUpper : na, "Anchor Upper Rail", color = color.new(neutralTone, 65), linewidth = 1)
plotAnchorLower = plot(showBands ? anchorLower : na, "Anchor Lower Rail", color = color.new(neutralTone, 65), linewidth = 1)
fill(plotAnchorUpper, plotAnchorLower, color.new(neutralTone, 94), title = "Anchor Rail Fill")

plot(anchorBase, "Anchor Baseline", color = color.new(neutralTone, 0), linewidth = 2)
plot(adaptiveMean, "Adaptive Mean", color = color.new(regimeColor, 0), linewidth = 2)
plot(sessionVwap, "Session VWAP", color = color.new(vwapColor, 0), linewidth = 2)

plotOpeningHigh = plot(showOpeningRangePlot and useOpeningRange ? openingRangeHigh : na, "Opening Range High", color = color.new(openingRangeColor, 8), linewidth = 1, style = plot.style_linebr)
plotOpeningLow = plot(showOpeningRangePlot and useOpeningRange ? openingRangeLow : na, "Opening Range Low", color = color.new(openingRangeColor, 8), linewidth = 1, style = plot.style_linebr)
plotOpeningMid = plot(showOpeningRangePlot and useOpeningRange ? openingRangeMid : na, "Opening Range Mid", color = color.new(openingRangeColor, 50), linewidth = 1, style = plot.style_linebr)
fill(plotOpeningHigh, plotOpeningLow, color.new(openingRangeColor, 92), title = "Opening Range Fill")

barcolor(tintBars ? candleTone : na)
bgcolor(sessionBackdrop)

var label stateLabel = na
if showStateLabel and barstate.islast
    if na(stateLabel)
        stateLabel := label.new(bar_index, high, "", style = label.style_label_left, textcolor = color.white, color = color.new(dashboardBg, 10))
    float labelY = high + atrValue * 0.9
    string labelText = regimeText + " | " + sessionState + " | Score " + str.tostring(clampedScore)
    label.set_xy(stateLabel, bar_index, labelY)
    label.set_text(stateLabel, labelText)
    label.set_color(stateLabel, color.new(regimeColor, 72))
    label.set_textcolor(stateLabel, color.white)

var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(dashboardBg, 8), frame_color = dashboardBorder, frame_width = 1, border_color = dashboardBorder, border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Meridian", text_color = color.rgb(160, 172, 191), bgcolor = color.new(dashboardBg, 0), text_size = size.normal)
    table.cell(dash, 1, 0, "State", text_color = color.rgb(160, 172, 191), bgcolor = color.new(dashboardBg, 0), text_size = size.normal)

    table.cell(dash, 0, 1, "Regime", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 1, regimeText, text_color = regimeColor, text_size = size.normal)

    table.cell(dash, 0, 2, "Composite", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 2, str.tostring(clampedScore), text_color = regimeColor, text_size = size.normal)

    table.cell(dash, 0, 3, "Bias", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 3, biasText, text_color = regimeColor, text_size = size.normal)

    table.cell(dash, 0, 4, "HTF", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 4, htfBullStack ? "Aligned Up" : htfBearStack ? "Aligned Down" : "Balanced", text_color = htfBullStack ? bullSoft : htfBearStack ? bearSoft : neutralTone, text_size = size.normal)

    table.cell(dash, 0, 5, "Structure", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 5, structureState > 0 ? "Break Up" : structureState < 0 ? "Break Down" : "Contained", text_color = structureState > 0 ? bullSoft : structureState < 0 ? bearSoft : neutralTone, text_size = size.normal)

    table.cell(dash, 0, 6, "Volatility", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 6, volatilityState, text_color = volatilityState == "Elevated" ? color.rgb(237, 191, 91) : volatilityState == "Quiet" ? neutralTone : color.rgb(124, 182, 214), text_size = size.normal)

    table.cell(dash, 0, 7, "RVOL / ADX", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 7, str.tostring(relativeVolume, "#.00") + " / " + str.tostring(adxValue, "#.0"), text_color = relativeVolume >= rvolTrendBoost ? color.rgb(237, 191, 91) : neutralTone, text_size = size.normal)

    table.cell(dash, 0, 8, "VWAP / Session", text_color = color.white, text_size = size.normal)
    table.cell(dash, 1, 8, str.tostring(vwapDistanceAtr, "#.00") + " ATR | " + sessionState, text_color = aboveVwap ? bullSoft : belowVwap ? bearSoft : neutralTone, text_size = size.normal)

bool bullAuctionConfirmed = barstate.isconfirmed and regimeCode >= 2 and htfBullStack and aboveVwap and not squeezeOn
bool bearAuctionConfirmed = barstate.isconfirmed and regimeCode <= -2 and htfBearStack and belowVwap and not squeezeOn
bool squeezeReleaseUp = barstate.isconfirmed and expansion and positiveDirectionalControl and clampedScore >= 4
bool squeezeReleaseDown = barstate.isconfirmed and expansion and negativeDirectionalControl and clampedScore <= -4

plotshape(showSignals and bullAuctionConfirmed ? low - atrValue * 0.20 : na, "Bull Auction Label", shape.labelup, location.absolute, color.new(bullStrong, 0), text = "AU", textcolor = color.white, size = size.tiny)
plotshape(showSignals and bearAuctionConfirmed ? high + atrValue * 0.20 : na, "Bear Auction Label", shape.labeldown, location.absolute, color.new(bearStrong, 0), text = "AD", textcolor = color.white, size = size.tiny)
plotshape(showSignals and squeezeReleaseUp ? low - atrValue * 0.45 : na, "Expansion Up Label", shape.circle, location.absolute, color.new(color.rgb(237, 191, 91), 0), text = "EX", textcolor = color.white, size = size.tiny)
plotshape(showSignals and squeezeReleaseDown ? high + atrValue * 0.45 : na, "Expansion Down Label", shape.circle, location.absolute, color.new(color.rgb(237, 191, 91), 0), text = "EX", textcolor = color.white, size = size.tiny)

alertcondition(bullAuctionConfirmed, "Meridian Auction Up", "JOAT Meridian Regime Overlay auction-up regime confirmed on {{ticker}}")
alertcondition(bearAuctionConfirmed, "Meridian Auction Down", "JOAT Meridian Regime Overlay auction-down regime confirmed on {{ticker}}")
alertcondition(squeezeReleaseUp, "Meridian Expansion Up", "JOAT Meridian Regime Overlay expansion-up sequence confirmed on {{ticker}}")
alertcondition(squeezeReleaseDown, "Meridian Expansion Down", "JOAT Meridian Regime Overlay expansion-down sequence confirmed on {{ticker}}")

plot(clampedScore, "Composite Score", color = color.new(color.white, 100), display = display.data_window)
plot(adxValue, "ADX", color = color.new(color.white, 100), display = display.data_window)
plot(relativeVolume, "Relative Volume", color = color.new(color.white, 100), display = display.data_window)
plot(vwapDistanceAtr, "VWAP Distance ATR", color = color.new(color.white, 100), display = display.data_window)
plot(anchorDistanceAtr, "Anchor Distance ATR", color = color.new(color.white, 100), display = display.data_window)
plot(htfClose, "HTF Close", color = color.new(color.white, 100), display = display.data_window)
````
