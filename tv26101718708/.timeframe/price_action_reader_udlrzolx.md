# Price Action Reader

- url: https://www.tradingview.com/script/UDLrzOLX-Price-Action-Reader/
- type: indicator
- pine_id: PUB;830dba9e96494629a647645bb29067b7
- version: 16.0

## Description

Price Action Reader V2.6 is a real-time market structure and price action indicator designed to help traders identify trend shifts, momentum changes, and high-probability entry opportunities without relying on lagging indicators. The indicator automatically maps Higher Highs (HH), Higher Lows (HL), Lower Highs (LH), Lower Lows (LL), Breaks of Structure (BOS), Changes of Character (CHoCH), and Market Structure Shifts (MSS) to provide a clear view of evolving market conditions. It combines early MSS reversal signals with confirmation-based A+ retest entries that require structure breaks, retests, rejection candles, and confirmation before signaling a trade. Built-in trend, volatility, premium/discount, higher-timeframe, and overextension filters work together to reduce noise and eliminate low-quality setups commonly found in ranging markets. Designed for active traders and scalable across multiple timeframes, the indicator focuses on identifying trend continuations, reversals, and shifts in order flow while maintaining a clean chart and delivering actionable real-time analysis.

## Source Code

````pine
//@version=6
indicator("Price Action Reader", overlay=true, max_labels_count=500, max_lines_count=400, max_boxes_count=250, max_bars_back=4000)
// BUILD: DUAL_DESKTOP_MOBILE_DASHBOARD_2026_08_05

// ============================================================================
// PRICE ACTION READER
// COMPLETE MARKET STRUCTURE + SUPPLY/DEMAND INDICATOR
//
// Modules:
// 1. Candle / price-action engine
// 2. Internal swing engine
// 3. External swing engine
// 4. BOS / CHoCH engine
// 5. Supply / demand engine
// 6. Broken-zone role reversal
// 7. Market-state dashboard
//
// No LONG, SHORT, BUY, or SELL execution signals exist in this build.
// ============================================================================

// ============================================================================
// INPUTS
// ============================================================================

groupGeneral = "General"
groupPriceAction = "Price Action"
groupStructure = "Market Structure"
groupTrend = "Trend and HTF"
groupSD = "Supply and Demand"
groupEnvironment = "Environment"
groupVisuals = "Visuals"
groupDashboard = "Dashboard"
groupAlerts = "Analysis Alerts"

primaryTimeframe = input.timeframe("5", "Primary Chart Timeframe", group=groupGeneral)
confirmOnClose = input.bool(true, "Confirm Events On Candle Close", group=groupGeneral)
atrLength = input.int(14, "ATR Length", minval=1, group=groupGeneral)
bodyAverageLength = input.int(20, "Average Body Length", minval=5, group=groupGeneral)

minimumDisplacementBodyATR = input.float(0.60, "Minimum Displacement Body ATR", minval=0.10, maxval=2.00, step=0.05, group=groupPriceAction)
minimumDisplacementBodyPercent = input.float(0.55, "Minimum Displacement Body Percent", minval=0.30, maxval=0.90, step=0.05, group=groupPriceAction)
minimumDisplacementCloseStrength = input.float(0.70, "Minimum Displacement Close Strength", minval=0.50, maxval=0.95, step=0.01, group=groupPriceAction)
minimumRejectionWickBody = input.float(0.80, "Minimum Rejection Wick / Body", minval=0.10, maxval=4.00, step=0.05, group=groupPriceAction)
followThroughWindow = input.int(3, "Follow-Through Lookback", minval=1, maxval=8, group=groupPriceAction)

internalSwingLeft = input.int(2, "Internal Swing Left", minval=1, maxval=6, group=groupStructure)
internalSwingRight = input.int(2, "Internal Swing Right", minval=1, maxval=6, group=groupStructure)
externalSwingLeft = input.int(6, "External Swing Left", minval=3, maxval=20, group=groupStructure)
externalSwingRight = input.int(6, "External Swing Right", minval=3, maxval=20, group=groupStructure)
minimumExternalSwingRangeATR = input.float(1.00, "Minimum External Swing Range ATR", minval=0.25, maxval=5.00, step=0.05, group=groupStructure)
minimumBarsBetweenExternalPivots = input.int(4, "Minimum Bars Between External Pivots", minval=1, maxval=30, group=groupStructure)
structureBreakBufferATR = input.float(0.10, "External Break Buffer ATR", minval=0.00, maxval=1.00, step=0.01, group=groupStructure)
minimumBodyBeyondStructure = input.float(0.30, "Minimum Body Beyond Structure", minval=0.05, maxval=0.90, step=0.05, group=groupStructure)
minimumExternalBreakBodyATR = input.float(0.55, "Minimum External Break Body ATR", minval=0.10, maxval=2.00, step=0.05, group=groupStructure)
minimumExternalBreakBodyPercent = input.float(0.55, "Minimum External Break Body Percent", minval=0.30, maxval=0.90, step=0.05, group=groupStructure)
minimumExternalBreakCloseStrength = input.float(0.68, "Minimum External Break Close Strength", minval=0.50, maxval=0.95, step=0.01, group=groupStructure)
minimumExternalPivotAge = input.int(3, "Minimum External Pivot Age", minval=1, maxval=15, group=groupStructure)
requireProtectedSwingBreakForCHoCH = input.bool(true, "Require Protected Swing Break For CHoCH", group=groupStructure)
blockExternalBreaksInCongestion = input.bool(true, "Block External Breaks In Congestion", group=groupStructure)

emaLength = input.int(21, "EMA Length", minval=1, group=groupTrend)
useHTFContext = input.bool(true, "Use HTF Context", group=groupTrend)
htfOne = input.timeframe("15", "HTF One", group=groupTrend)
htfTwo = input.timeframe("30", "HTF Two", group=groupTrend)

showSDZones = input.bool(true, "Show Supply / Demand Zones", group=groupSD)
showFlipZones = input.bool(true, "Show Flip Zones", group=groupSD)
sdSwingLength = input.int(8, "Zone Swing Length", minval=2, maxval=30, group=groupSD)
sdATRLength = input.int(50, "Zone ATR Length", minval=5, maxval=200, group=groupSD)
sdMaximumZoneWidthATR = input.float(1.00, "Maximum Zone Width ATR", minval=0.10, maxval=4.00, step=0.10, group=groupSD)
sdMinimumPivotRangeATR = input.float(0.60, "Minimum Zone Pivot Range ATR", minval=0.10, maxval=3.00, step=0.05, group=groupSD)
sdMinimumDepartureATR = input.float(0.75, "Minimum Zone Departure ATR", minval=0.25, maxval=4.00, step=0.05, group=groupSD)
sdRequireStructureCreation = input.bool(false, "Require Recent BOS / CHoCH", group=groupSD)
sdStructureWindowBars = input.int(20, "Structure Creation Window", minval=3, maxval=60, group=groupSD)
sdMaximumRetests = input.int(2, "Maximum Zone Retests", minval=0, maxval=5, group=groupSD)
zoneBreakBufferATR = input.float(0.10, "Zone Break Buffer ATR", minval=0.00, maxval=0.50, step=0.01, group=groupSD)
sdFlipZonesEnabled = input.bool(true, "Enable Broken-Zone Role Reversal", group=groupSD)
sdFlipZoneLifeBars = input.int(100, "Flip Zone Life Bars", minval=10, maxval=300, group=groupSD)
sdMaximumZones = input.int(10, "Maximum Zones Per Side", minval=2, maxval=25, group=groupSD)

showCongestionState = input.bool(true, "Detect Congestion", group=groupEnvironment)
congestionLookback = input.int(12, "Congestion Lookback", minval=5, maxval=50, group=groupEnvironment)
congestionRangeATR = input.float(1.50, "Maximum Congestion Range ATR", minval=0.50, maxval=5.00, step=0.10, group=groupEnvironment)
congestionOverlapRequired = input.int(8, "Required Candle Overlaps", minval=3, maxval=20, group=groupEnvironment)

showEMA = input.bool(true, "Show EMA", group=groupVisuals)
showExternalSwings = input.bool(true, "Show External HH / HL / LH / LL", group=groupVisuals)
showInternalSwings = input.bool(false, "Show Internal Structure", group=groupVisuals)
externalSwingLabelOffsetATR = input.float(0.30, "External Swing Label Distance ATR", minval=0.05, maxval=2.00, step=0.05, group=groupVisuals)
internalSwingLabelOffsetATR = input.float(0.12, "Internal Swing Label Distance ATR", minval=0.05, maxval=1.00, step=0.05, group=groupVisuals)
maximumSwingLabels = input.int(30, "Maximum Swing Labels", minval=6, maxval=100, group=groupVisuals)
showStructureLines = input.bool(true, "Show BOS / CHoCH Lines", group=groupVisuals)
showStructureLabels = input.bool(true, "Show BOS / CHoCH Labels", group=groupVisuals)
showStructureBreakMarker = input.bool(true, "Show Structure Break Marker", group=groupVisuals)
structureLineWidth = input.int(2, "Structure Line Width", minval=1, maxval=4, group=groupVisuals)
structureLabelOffsetATR = input.float(0.18, "Structure Label Distance ATR", minval=0.05, maxval=1.00, step=0.05, group=groupVisuals)
maximumStructureMarks = input.int(24, "Maximum Structure Marks", minval=6, maxval=80, group=groupVisuals)
highlightDisplacementCandles = input.bool(true, "Highlight Displacement Candles", group=groupVisuals)

showDashboard = input.bool(true, "Show Dashboard", group=groupDashboard)
dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDashboard)
dashboardLayout = input.string("Desktop", "Dashboard Layout", options=["Desktop", "Mobile"], group=groupDashboard)

enableStructureAlerts = input.bool(true, "Enable Structure Alerts", group=groupAlerts)
enableZoneAlerts = input.bool(true, "Enable Zone Alerts", group=groupAlerts)

// ============================================================================
// COLORS AND HELPERS
// ============================================================================

bullColor = color.rgb(0, 230, 118)
bearColor = color.rgb(255, 61, 87)
warningColor = color.rgb(255, 193, 7)
neutralColor = color.rgb(145, 145, 145)
panelColor = color.rgb(22, 22, 22)
flipDemandColor = color.rgb(0, 170, 255)
flipSupplyColor = color.rgb(255, 145, 0)

f_delete_old_label(label[] labels, int maximum) =>
    if array.size(labels) > maximum
        label.delete(array.shift(labels))

f_delete_old_line(line[] lines, int maximum) =>
    if array.size(lines) > maximum
        line.delete(array.shift(lines))

// ============================================================================
// 1. CANDLE / PRICE-ACTION ENGINE
// ============================================================================

atr = ta.atr(atrLength)
sdATR = ta.atr(sdATRLength)
ema = ta.ema(close, emaLength)
body = math.abs(close - open)
averageBody = ta.sma(body, bodyAverageLength)
candleRange = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
bodyPercent = body / candleRange
bullCloseStrength = (close - low) / candleRange
bearCloseStrength = (high - close) / candleRange

bullCandle = close > open
bearCandle = close < open
closeConfirmed = not confirmOnClose or barstate.isconfirmed
currentChartIsPrimary = timeframe.period == primaryTimeframe

followThroughPriorHigh = ta.highest(high[1], followThroughWindow)
followThroughPriorLow = ta.lowest(low[1], followThroughWindow)

bullDisplacement =
     bullCandle and
     body >= atr * minimumDisplacementBodyATR and
     body >= averageBody and
     bodyPercent >= minimumDisplacementBodyPercent and
     bullCloseStrength >= minimumDisplacementCloseStrength

bearDisplacement =
     bearCandle and
     body >= atr * minimumDisplacementBodyATR and
     body >= averageBody and
     bodyPercent >= minimumDisplacementBodyPercent and
     bearCloseStrength >= minimumDisplacementCloseStrength

bullRejection =
     bullCandle and
     lowerWick >= math.max(body, syminfo.mintick) * minimumRejectionWickBody and
     bullCloseStrength >= 0.65

bearRejection =
     bearCandle and
     upperWick >= math.max(body, syminfo.mintick) * minimumRejectionWickBody and
     bearCloseStrength >= 0.65

bullFollowThrough =
     bullDisplacement and
     close > followThroughPriorHigh

bearFollowThrough =
     bearDisplacement and
     close < followThroughPriorLow

candleQualityScore =
     (bodyPercent >= 0.60 ? 25 : bodyPercent >= 0.45 ? 15 : 5) +
     (math.max(bullCloseStrength, bearCloseStrength) >= 0.75 ? 25 : 15) +
     (body >= averageBody ? 20 : 5) +
     (body >= atr * minimumDisplacementBodyATR ? 20 : 5) +
     ((bullRejection or bearRejection) ? 10 : 0)

emaRising = ema > ema[1]
emaFalling = ema < ema[1]
longTrendAligned = close > ema and emaRising
shortTrendAligned = close < ema and emaFalling

htfOneClose = request.security(syminfo.tickerid, htfOne, close, barmerge.gaps_off, barmerge.lookahead_off)
htfOneEMA = request.security(syminfo.tickerid, htfOne, ta.ema(close, emaLength), barmerge.gaps_off, barmerge.lookahead_off)
htfOnePriorEMA = request.security(syminfo.tickerid, htfOne, ta.ema(close, emaLength)[1], barmerge.gaps_off, barmerge.lookahead_off)
htfTwoClose = request.security(syminfo.tickerid, htfTwo, close, barmerge.gaps_off, barmerge.lookahead_off)
htfTwoEMA = request.security(syminfo.tickerid, htfTwo, ta.ema(close, emaLength), barmerge.gaps_off, barmerge.lookahead_off)
htfTwoPriorEMA = request.security(syminfo.tickerid, htfTwo, ta.ema(close, emaLength)[1], barmerge.gaps_off, barmerge.lookahead_off)

htfOneBull = htfOneClose > htfOneEMA and htfOneEMA >= htfOnePriorEMA
htfOneBear = htfOneClose < htfOneEMA and htfOneEMA <= htfOnePriorEMA
htfTwoBull = htfTwoClose > htfTwoEMA and htfTwoEMA >= htfTwoPriorEMA
htfTwoBear = htfTwoClose < htfTwoEMA and htfTwoEMA <= htfTwoPriorEMA

htfBullCount = (htfOneBull ? 1 : 0) + (htfTwoBull ? 1 : 0)
htfBearCount = (htfOneBear ? 1 : 0) + (htfTwoBear ? 1 : 0)

congestionHigh = ta.highest(high, congestionLookback)
congestionLow = ta.lowest(low, congestionLookback)
congestionRange = congestionHigh - congestionLow

int overlapCount = 0
for i = 1 to congestionLookback - 1
    if high[i] >= low[i + 1] and low[i] <= high[i + 1]
        overlapCount += 1

inCongestion =
     showCongestionState and
     congestionRange <= atr * congestionRangeATR and
     overlapCount >= congestionOverlapRequired

plot(showEMA ? ema : na, title="Trend EMA", color=color.new(neutralColor, 45), linewidth=1)

barcolor(
     highlightDisplacementCandles ?
     bullDisplacement ? color.new(bullColor, 45) :
     bearDisplacement ? color.new(bearColor, 45) :
     na :
     na
)

// ============================================================================
// 2. INTERNAL SWING ENGINE
// ============================================================================

internalPivotHigh = ta.pivothigh(high, internalSwingLeft, internalSwingRight)
internalPivotLow = ta.pivotlow(low, internalSwingLeft, internalSwingRight)

newInternalHigh = not na(internalPivotHigh)
newInternalLow = not na(internalPivotLow)

var float priorInternalHigh = na
var float priorInternalLow = na
var float activeInternalHigh = na
var float activeInternalLow = na

internalHH = newInternalHigh and not na(activeInternalHigh) and internalPivotHigh > activeInternalHigh
internalLH = newInternalHigh and not na(activeInternalHigh) and internalPivotHigh <= activeInternalHigh
internalHL = newInternalLow and not na(activeInternalLow) and internalPivotLow >= activeInternalLow
internalLL = newInternalLow and not na(activeInternalLow) and internalPivotLow < activeInternalLow

var label[] internalSwingLabels = array.new_label()

if showInternalSwings and newInternalHigh
    string textValue = na(activeInternalHigh) ? "iH" : internalHH ? "iHH" : "iLH"
    color textColor = na(activeInternalHigh) ? neutralColor : internalHH ? bullColor : bearColor
    label lb = label.new(
         bar_index - internalSwingRight,
         internalPivotHigh + nz(atr[internalSwingRight], atr) * internalSwingLabelOffsetATR,
         textValue,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         color=color.new(color.black, 100),
         textcolor=color.new(textColor, 35),
         size=size.tiny
     )
    array.push(internalSwingLabels, lb)
    f_delete_old_label(internalSwingLabels, maximumSwingLabels)

if showInternalSwings and newInternalLow
    string textValue = na(activeInternalLow) ? "iL" : internalHL ? "iHL" : "iLL"
    color textColor = na(activeInternalLow) ? neutralColor : internalHL ? bullColor : bearColor
    label lb = label.new(
         bar_index - internalSwingRight,
         internalPivotLow - nz(atr[internalSwingRight], atr) * internalSwingLabelOffsetATR,
         textValue,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         color=color.new(color.black, 100),
         textcolor=color.new(textColor, 35),
         size=size.tiny
     )
    array.push(internalSwingLabels, lb)
    f_delete_old_label(internalSwingLabels, maximumSwingLabels)

if newInternalHigh
    priorInternalHigh := activeInternalHigh
    activeInternalHigh := internalPivotHigh

if newInternalLow
    priorInternalLow := activeInternalLow
    activeInternalLow := internalPivotLow

internalBullSequence =
     not na(activeInternalHigh) and
     not na(priorInternalHigh) and
     not na(activeInternalLow) and
     not na(priorInternalLow) and
     activeInternalHigh > priorInternalHigh and
     activeInternalLow >= priorInternalLow

internalBearSequence =
     not na(activeInternalHigh) and
     not na(priorInternalHigh) and
     not na(activeInternalLow) and
     not na(priorInternalLow) and
     activeInternalHigh <= priorInternalHigh and
     activeInternalLow < priorInternalLow

internalStructureTrend =
     internalBullSequence ? 1 :
     internalBearSequence ? -1 :
     0

// ============================================================================
// 3. EXTERNAL SWING ENGINE
// ============================================================================

externalPivotHigh = ta.pivothigh(high, externalSwingLeft, externalSwingRight)
externalPivotLow = ta.pivotlow(low, externalSwingLeft, externalSwingRight)

newExternalHigh = not na(externalPivotHigh)
newExternalLow = not na(externalPivotLow)

externalPivotHighBar = bar_index - externalSwingRight
externalPivotLowBar = bar_index - externalSwingRight

var float priorSwingHigh = na
var float priorSwingLow = na
var float activeSwingHigh = na
var float activeSwingLow = na
var int activeSwingHighBar = na
var int activeSwingLowBar = na
var int lastAcceptedHighBar = na
var int lastAcceptedLowBar = na
var bool activeHighBroken = false
var bool activeLowBroken = false

externalHighRangeOK =
     newExternalHigh and
     (
         na(activeSwingLow) or
         externalPivotHigh - activeSwingLow >= nz(atr[externalSwingRight], atr) * minimumExternalSwingRangeATR
     )

externalLowRangeOK =
     newExternalLow and
     (
         na(activeSwingHigh) or
         activeSwingHigh - externalPivotLow >= nz(atr[externalSwingRight], atr) * minimumExternalSwingRangeATR
     )

externalHighSpacingOK =
     newExternalHigh and
     (
         na(lastAcceptedHighBar) or
         externalPivotHighBar - lastAcceptedHighBar >= minimumBarsBetweenExternalPivots
     )

externalLowSpacingOK =
     newExternalLow and
     (
         na(lastAcceptedLowBar) or
         externalPivotLowBar - lastAcceptedLowBar >= minimumBarsBetweenExternalPivots
     )

acceptExternalHigh =
     newExternalHigh and
     externalHighRangeOK and
     externalHighSpacingOK

acceptExternalLow =
     newExternalLow and
     externalLowRangeOK and
     externalLowSpacingOK

externalHH =
     acceptExternalHigh and
     not na(activeSwingHigh) and
     externalPivotHigh > activeSwingHigh

externalLH =
     acceptExternalHigh and
     not na(activeSwingHigh) and
     externalPivotHigh <= activeSwingHigh

externalHL =
     acceptExternalLow and
     not na(activeSwingLow) and
     externalPivotLow >= activeSwingLow

externalLL =
     acceptExternalLow and
     not na(activeSwingLow) and
     externalPivotLow < activeSwingLow

var label[] externalSwingLabels = array.new_label()

if showExternalSwings and acceptExternalHigh
    string textValue = na(activeSwingHigh) ? "H" : externalHH ? "HH" : "LH"
    color textColor = na(activeSwingHigh) ? neutralColor : externalHH ? bullColor : bearColor
    label lb = label.new(
         externalPivotHighBar,
         externalPivotHigh + nz(atr[externalSwingRight], atr) * externalSwingLabelOffsetATR,
         textValue,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         color=color.new(color.black, 100),
         textcolor=color.new(textColor, 10),
         size=size.tiny
     )
    array.push(externalSwingLabels, lb)
    f_delete_old_label(externalSwingLabels, maximumSwingLabels)

if showExternalSwings and acceptExternalLow
    string textValue = na(activeSwingLow) ? "L" : externalHL ? "HL" : "LL"
    color textColor = na(activeSwingLow) ? neutralColor : externalHL ? bullColor : bearColor
    label lb = label.new(
         externalPivotLowBar,
         externalPivotLow - nz(atr[externalSwingRight], atr) * externalSwingLabelOffsetATR,
         textValue,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         color=color.new(color.black, 100),
         textcolor=color.new(textColor, 10),
         size=size.tiny
     )
    array.push(externalSwingLabels, lb)
    f_delete_old_label(externalSwingLabels, maximumSwingLabels)

if acceptExternalHigh
    priorSwingHigh := activeSwingHigh
    activeSwingHigh := externalPivotHigh
    activeSwingHighBar := externalPivotHighBar
    lastAcceptedHighBar := externalPivotHighBar
    activeHighBroken := false

if acceptExternalLow
    priorSwingLow := activeSwingLow
    activeSwingLow := externalPivotLow
    activeSwingLowBar := externalPivotLowBar
    lastAcceptedLowBar := externalPivotLowBar
    activeLowBroken := false

externalBullSequence =
     not na(activeSwingHigh) and
     not na(priorSwingHigh) and
     not na(activeSwingLow) and
     not na(priorSwingLow) and
     activeSwingHigh > priorSwingHigh and
     activeSwingLow >= priorSwingLow

externalBearSequence =
     not na(activeSwingHigh) and
     not na(priorSwingHigh) and
     not na(activeSwingLow) and
     not na(priorSwingLow) and
     activeSwingHigh <= priorSwingHigh and
     activeSwingLow < priorSwingLow

// ============================================================================
// 4. MARKET-STRUCTURE ENGINE
// ============================================================================

var int structureTrend = 0
var float protectedSwingHigh = na
var float protectedSwingLow = na

if structureTrend == 0
    if externalBullSequence
        structureTrend := 1
        protectedSwingLow := activeSwingLow
    else if externalBearSequence
        structureTrend := -1
        protectedSwingHigh := activeSwingHigh

breakBuffer = atr * structureBreakBufferATR
bullPenetration = not na(activeSwingHigh) ? close - activeSwingHigh : 0.0
bearPenetration = not na(activeSwingLow) ? activeSwingLow - close : 0.0
bullBodyBeyond = body > 0.0 ? bullPenetration / body : 0.0
bearBodyBeyond = body > 0.0 ? bearPenetration / body : 0.0

bullBreakQuality =
     bullCandle and
     body >= atr * minimumExternalBreakBodyATR and
     bodyPercent >= minimumExternalBreakBodyPercent and
     bullCloseStrength >= minimumExternalBreakCloseStrength

bearBreakQuality =
     bearCandle and
     body >= atr * minimumExternalBreakBodyATR and
     bodyPercent >= minimumExternalBreakBodyPercent and
     bearCloseStrength >= minimumExternalBreakCloseStrength

structureEnvironmentAllowed =
     not blockExternalBreaksInCongestion or
     not inCongestion

bullPrimaryBreak =
     not na(activeSwingHigh) and
     not activeHighBroken and
     not na(activeSwingHighBar) and
     bar_index - activeSwingHighBar >= minimumExternalPivotAge and
     close > activeSwingHigh + breakBuffer and
     close[1] <= activeSwingHigh + breakBuffer and
     bullBodyBeyond >= minimumBodyBeyondStructure and
     bullBreakQuality and
     structureEnvironmentAllowed and
     closeConfirmed

bearPrimaryBreak =
     not na(activeSwingLow) and
     not activeLowBroken and
     not na(activeSwingLowBar) and
     bar_index - activeSwingLowBar >= minimumExternalPivotAge and
     close < activeSwingLow - breakBuffer and
     close[1] >= activeSwingLow - breakBuffer and
     bearBodyBeyond >= minimumBodyBeyondStructure and
     bearBreakQuality and
     structureEnvironmentAllowed and
     closeConfirmed

bullProtectedBreak =
     not requireProtectedSwingBreakForCHoCH or
     na(protectedSwingHigh) or
     close > protectedSwingHigh + breakBuffer

bearProtectedBreak =
     not requireProtectedSwingBreakForCHoCH or
     na(protectedSwingLow) or
     close < protectedSwingLow - breakBuffer

bullCHoCH =
     bullPrimaryBreak and
     structureTrend == -1 and
     bullProtectedBreak

bearCHoCH =
     bearPrimaryBreak and
     structureTrend == 1 and
     bearProtectedBreak

bullBOS =
     bullPrimaryBreak and
     structureTrend != -1 and
     not bullCHoCH

bearBOS =
     bearPrimaryBreak and
     structureTrend != 1 and
     not bearCHoCH

freshBullExternalEvent = bullBOS or bullCHoCH
freshBearExternalEvent = bearBOS or bearCHoCH

if bullPrimaryBreak
    activeHighBroken := true
    structureTrend := 1
    protectedSwingLow := activeSwingLow

if bearPrimaryBreak
    activeLowBroken := true
    structureTrend := -1
    protectedSwingHigh := activeSwingHigh

var line[] structureLines = array.new_line()
var label[] structureLabels = array.new_label()
var label[] structureMarkers = array.new_label()

if freshBullExternalEvent
    string eventText = bullCHoCH ? "CHoCH UP" : "BOS UP"
    color eventColor = bullCHoCH ? warningColor : bullColor
    int eventStart = math.max(0, nz(activeSwingHighBar, bar_index))
    int eventMid = int(math.floor((eventStart + bar_index) * 0.5))
    float labelPrice = activeSwingHigh + atr * structureLabelOffsetATR

    if showStructureLines
        line ln = line.new(eventStart, activeSwingHigh, bar_index, activeSwingHigh, xloc=xloc.bar_index, extend=extend.none, color=color.new(eventColor, bullCHoCH ? 0 : 12), width=structureLineWidth, style=bullCHoCH ? line.style_dashed : line.style_solid)
        array.push(structureLines, ln)
        f_delete_old_line(structureLines, maximumStructureMarks)

    if showStructureLabels
        label lb = label.new(eventMid, labelPrice, eventText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(eventColor, 100), textcolor=eventColor, size=bullCHoCH ? size.small : size.tiny)
        array.push(structureLabels, lb)
        f_delete_old_label(structureLabels, maximumStructureMarks)

    if showStructureBreakMarker
        label marker = label.new(bar_index, activeSwingHigh, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_circle, color=color.new(eventColor, bullCHoCH ? 0 : 25), textcolor=eventColor, size=bullCHoCH ? size.small : size.tiny)
        array.push(structureMarkers, marker)
        f_delete_old_label(structureMarkers, maximumStructureMarks)

if freshBearExternalEvent
    string eventText = bearCHoCH ? "CHoCH DOWN" : "BOS DOWN"
    color eventColor = bearCHoCH ? warningColor : bearColor
    int eventStart = math.max(0, nz(activeSwingLowBar, bar_index))
    int eventMid = int(math.floor((eventStart + bar_index) * 0.5))
    float labelPrice = activeSwingLow - atr * structureLabelOffsetATR

    if showStructureLines
        line ln = line.new(eventStart, activeSwingLow, bar_index, activeSwingLow, xloc=xloc.bar_index, extend=extend.none, color=color.new(eventColor, bearCHoCH ? 0 : 12), width=structureLineWidth, style=bearCHoCH ? line.style_dashed : line.style_solid)
        array.push(structureLines, ln)
        f_delete_old_line(structureLines, maximumStructureMarks)

    if showStructureLabels
        label lb = label.new(eventMid, labelPrice, eventText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, color=color.new(eventColor, 100), textcolor=eventColor, size=bearCHoCH ? size.small : size.tiny)
        array.push(structureLabels, lb)
        f_delete_old_label(structureLabels, maximumStructureMarks)

    if showStructureBreakMarker
        label marker = label.new(bar_index, activeSwingLow, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_circle, color=color.new(eventColor, bearCHoCH ? 0 : 25), textcolor=eventColor, size=bearCHoCH ? size.small : size.tiny)
        array.push(structureMarkers, marker)
        f_delete_old_label(structureMarkers, maximumStructureMarks)

// ============================================================================
// 5. SUPPLY / DEMAND ENGINE
// ============================================================================

sdPivotHigh = ta.pivothigh(high, sdSwingLength, sdSwingLength)
sdPivotLow = ta.pivotlow(low, sdSwingLength, sdSwingLength)
sdDepartureLow = ta.lowest(low, sdSwingLength + 1)
sdDepartureHigh = ta.highest(high, sdSwingLength + 1)

barsSinceBullStructure = ta.barssince(freshBullExternalEvent)
barsSinceBearStructure = ta.barssince(freshBearExternalEvent)

var box[] supplyBoxes = array.new_box()
var int[] supplyRetests = array.new_int()
var int[] supplyCreatedBars = array.new_int()

var box[] demandBoxes = array.new_box()
var int[] demandRetests = array.new_int()
var int[] demandCreatedBars = array.new_int()

var box[] flippedDemandBoxes = array.new_box()
var int[] flippedDemandCreatedBars = array.new_int()

var box[] flippedSupplyBoxes = array.new_box()
var int[] flippedSupplyCreatedBars = array.new_int()

f_remove_supply(int index) =>
    box bx = array.get(supplyBoxes, index)
    box.delete(bx)
    array.remove(supplyBoxes, index)
    array.remove(supplyRetests, index)
    array.remove(supplyCreatedBars, index)

f_remove_demand(int index) =>
    box bx = array.get(demandBoxes, index)
    box.delete(bx)
    array.remove(demandBoxes, index)
    array.remove(demandRetests, index)
    array.remove(demandCreatedBars, index)

f_remove_flipped_demand(int index) =>
    box bx = array.get(flippedDemandBoxes, index)
    box.delete(bx)
    array.remove(flippedDemandBoxes, index)
    array.remove(flippedDemandCreatedBars, index)

f_remove_flipped_supply(int index) =>
    box bx = array.get(flippedSupplyBoxes, index)
    box.delete(bx)
    array.remove(flippedSupplyBoxes, index)
    array.remove(flippedSupplyCreatedBars, index)

f_zone_overlaps(float top, float bottom, box[] zones) =>
    bool overlaps = false
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            box bx = array.get(zones, i)
            if top >= box.get_bottom(bx) and bottom <= box.get_top(bx)
                overlaps := true
                break
    overlaps

if not na(sdPivotHigh)
    float pivotATR = nz(sdATR[sdSwingLength], sdATR)
    float pivotRange = high[sdSwingLength] - low[sdSwingLength]
    float zoneTop = high[sdSwingLength]
    float rawBottom = math.min(open[sdSwingLength], close[sdSwingLength])
    float zoneBottom = math.max(rawBottom, zoneTop - pivotATR * sdMaximumZoneWidthATR)

    bool pivotRangeOK = pivotRange >= pivotATR * sdMinimumPivotRangeATR
    bool departureOK = sdDepartureLow <= zoneBottom - pivotATR * sdMinimumDepartureATR
    bool recentBearStructure = not na(barsSinceBearStructure) and barsSinceBearStructure <= sdStructureWindowBars
    bool structureOK = not sdRequireStructureCreation or recentBearStructure

    if pivotRangeOK and departureOK and structureOK and not f_zone_overlaps(zoneTop, zoneBottom, supplyBoxes)
        box bx = box.new(
             bar_index - sdSwingLength,
             zoneTop,
             bar_index + 1,
             zoneBottom,
             xloc=xloc.bar_index,
             extend=extend.right,
             bgcolor=showSDZones ? color.new(bearColor, 86) : color.new(bearColor, 100),
             border_color=showSDZones ? color.new(bearColor, 18) : color.new(bearColor, 100),
             text=showSDZones ? "SUPPLY" : "",
             text_color=color.white,
             text_size=size.tiny
         )
        array.unshift(supplyBoxes, bx)
        array.unshift(supplyRetests, 0)
        array.unshift(supplyCreatedBars, bar_index)

        if array.size(supplyBoxes) > sdMaximumZones
            f_remove_supply(array.size(supplyBoxes) - 1)

if not na(sdPivotLow)
    float pivotATR = nz(sdATR[sdSwingLength], sdATR)
    float pivotRange = high[sdSwingLength] - low[sdSwingLength]
    float zoneBottom = low[sdSwingLength]
    float rawTop = math.max(open[sdSwingLength], close[sdSwingLength])
    float zoneTop = math.min(rawTop, zoneBottom + pivotATR * sdMaximumZoneWidthATR)

    bool pivotRangeOK = pivotRange >= pivotATR * sdMinimumPivotRangeATR
    bool departureOK = sdDepartureHigh >= zoneTop + pivotATR * sdMinimumDepartureATR
    bool recentBullStructure = not na(barsSinceBullStructure) and barsSinceBullStructure <= sdStructureWindowBars
    bool structureOK = not sdRequireStructureCreation or recentBullStructure

    if pivotRangeOK and departureOK and structureOK and not f_zone_overlaps(zoneTop, zoneBottom, demandBoxes)
        box bx = box.new(
             bar_index - sdSwingLength,
             zoneTop,
             bar_index + 1,
             zoneBottom,
             xloc=xloc.bar_index,
             extend=extend.right,
             bgcolor=showSDZones ? color.new(bullColor, 86) : color.new(bullColor, 100),
             border_color=showSDZones ? color.new(bullColor, 18) : color.new(bullColor, 100),
             text=showSDZones ? "DEMAND" : "",
             text_color=color.white,
             text_size=size.tiny
         )
        array.unshift(demandBoxes, bx)
        array.unshift(demandRetests, 0)
        array.unshift(demandCreatedBars, bar_index)

        if array.size(demandBoxes) > sdMaximumZones
            f_remove_demand(array.size(demandBoxes) - 1)

bool liveSupplyBreak = false
bool liveDemandBreak = false
bool newFlipDemand = false
bool newFlipSupply = false

if array.size(supplyBoxes) > 0
    for reverseIndex = 0 to array.size(supplyBoxes) - 1
        int i = array.size(supplyBoxes) - 1 - reverseIndex
        box bx = array.get(supplyBoxes, i)
        float top = box.get_top(bx)
        float bottom = box.get_bottom(bx)

        bool broken =
             close > top + atr * zoneBreakBufferATR and
             bullDisplacement and
             closeConfirmed

        bool touched =
             high >= bottom and
             low <= top and
             bar_index > array.get(supplyCreatedBars, i)

        if broken
            liveSupplyBreak := true

            if sdFlipZonesEnabled
                box flip = box.new(
                     bar_index,
                     top,
                     bar_index + sdFlipZoneLifeBars,
                     bottom,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     bgcolor=showFlipZones ? color.new(flipDemandColor, 86) : color.new(flipDemandColor, 100),
                     border_color=showFlipZones ? color.new(flipDemandColor, 18) : color.new(flipDemandColor, 100),
                     text=showFlipZones ? "FLIP DEMAND" : "",
                     text_color=color.white,
                     text_size=size.tiny
                 )
                array.unshift(flippedDemandBoxes, flip)
                array.unshift(flippedDemandCreatedBars, bar_index)
                newFlipDemand := true

            f_remove_supply(i)
        else if touched
            int retests = array.get(supplyRetests, i) + 1
            array.set(supplyRetests, i, retests)

            if retests > 0
                box.set_bgcolor(bx, showSDZones ? color.new(bearColor, 91) : color.new(bearColor, 100))
                box.set_border_color(bx, showSDZones ? color.new(bearColor, 45) : color.new(bearColor, 100))
                box.set_text(bx, showSDZones ? "SUPPLY • TESTED" : "")

            if retests > sdMaximumRetests
                f_remove_supply(i)

if array.size(demandBoxes) > 0
    for reverseIndex = 0 to array.size(demandBoxes) - 1
        int i = array.size(demandBoxes) - 1 - reverseIndex
        box bx = array.get(demandBoxes, i)
        float top = box.get_top(bx)
        float bottom = box.get_bottom(bx)

        bool broken =
             close < bottom - atr * zoneBreakBufferATR and
             bearDisplacement and
             closeConfirmed

        bool touched =
             high >= bottom and
             low <= top and
             bar_index > array.get(demandCreatedBars, i)

        if broken
            liveDemandBreak := true

            if sdFlipZonesEnabled
                box flip = box.new(
                     bar_index,
                     top,
                     bar_index + sdFlipZoneLifeBars,
                     bottom,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     bgcolor=showFlipZones ? color.new(flipSupplyColor, 86) : color.new(flipSupplyColor, 100),
                     border_color=showFlipZones ? color.new(flipSupplyColor, 18) : color.new(flipSupplyColor, 100),
                     text=showFlipZones ? "FLIP SUPPLY" : "",
                     text_color=color.white,
                     text_size=size.tiny
                 )
                array.unshift(flippedSupplyBoxes, flip)
                array.unshift(flippedSupplyCreatedBars, bar_index)
                newFlipSupply := true

            f_remove_demand(i)
        else if touched
            int retests = array.get(demandRetests, i) + 1
            array.set(demandRetests, i, retests)

            if retests > 0
                box.set_bgcolor(bx, showSDZones ? color.new(bullColor, 91) : color.new(bullColor, 100))
                box.set_border_color(bx, showSDZones ? color.new(bullColor, 45) : color.new(bullColor, 100))
                box.set_text(bx, showSDZones ? "DEMAND • TESTED" : "")

            if retests > sdMaximumRetests
                f_remove_demand(i)

if array.size(flippedDemandBoxes) > 0
    for reverseIndex = 0 to array.size(flippedDemandBoxes) - 1
        int i = array.size(flippedDemandBoxes) - 1 - reverseIndex
        box bx = array.get(flippedDemandBoxes, i)
        bool expired = bar_index - array.get(flippedDemandCreatedBars, i) > sdFlipZoneLifeBars
        bool invalidated = close < box.get_bottom(bx) - atr * zoneBreakBufferATR

        if expired or invalidated
            f_remove_flipped_demand(i)

if array.size(flippedSupplyBoxes) > 0
    for reverseIndex = 0 to array.size(flippedSupplyBoxes) - 1
        int i = array.size(flippedSupplyBoxes) - 1 - reverseIndex
        box bx = array.get(flippedSupplyBoxes, i)
        bool expired = bar_index - array.get(flippedSupplyCreatedBars, i) > sdFlipZoneLifeBars
        bool invalidated = close > box.get_top(bx) + atr * zoneBreakBufferATR

        if expired or invalidated
            f_remove_flipped_supply(i)

float nearestSupplyTop = na
float nearestSupplyBottom = na
float nearestSupplyDistance = na
int nearestSupplyRetests = na

if array.size(supplyBoxes) > 0
    for i = 0 to array.size(supplyBoxes) - 1
        box bx = array.get(supplyBoxes, i)
        float top = box.get_top(bx)
        float bottom = box.get_bottom(bx)
        float distance = close < bottom ? bottom - close : close > top ? close - top : 0.0

        if na(nearestSupplyDistance) or distance < nearestSupplyDistance
            nearestSupplyTop := top
            nearestSupplyBottom := bottom
            nearestSupplyDistance := distance
            nearestSupplyRetests := array.get(supplyRetests, i)

float nearestDemandTop = na
float nearestDemandBottom = na
float nearestDemandDistance = na
int nearestDemandRetests = na

if array.size(demandBoxes) > 0
    for i = 0 to array.size(demandBoxes) - 1
        box bx = array.get(demandBoxes, i)
        float top = box.get_top(bx)
        float bottom = box.get_bottom(bx)
        float distance = close < bottom ? bottom - close : close > top ? close - top : 0.0

        if na(nearestDemandDistance) or distance < nearestDemandDistance
            nearestDemandTop := top
            nearestDemandBottom := bottom
            nearestDemandDistance := distance
            nearestDemandRetests := array.get(demandRetests, i)

insideSupply =
     not na(nearestSupplyTop) and
     high >= nearestSupplyBottom and
     low <= nearestSupplyTop

insideDemand =
     not na(nearestDemandTop) and
     high >= nearestDemandBottom and
     low <= nearestDemandTop

// ============================================================================
// 6. MARKET STATE + DASHBOARD
// ============================================================================

emaDistanceATR = atr > 0.0 ? math.abs(close - ema) / atr : 0.0
supplyDistanceATR = not na(nearestSupplyDistance) and atr > 0.0 ? nearestSupplyDistance / atr : na
demandDistanceATR = not na(nearestDemandDistance) and atr > 0.0 ? nearestDemandDistance / atr : na

string structureStateText =
     freshBullExternalEvent ? (bullCHoCH ? "EXT CHoCH UP" : "EXT BOS UP") :
     freshBearExternalEvent ? (bearCHoCH ? "EXT CHoCH DOWN" : "EXT BOS DOWN") :
     structureTrend == 1 ? "EXT HH / HL" :
     structureTrend == -1 ? "EXT LH / LL" :
     "EXT UNCONFIRMED"

string internalStateText =
     internalStructureTrend == 1 ? "INT BULL" :
     internalStructureTrend == -1 ? "INT BEAR" :
     "INT MIXED"

string marketStateText =
     inCongestion ? "CONGESTION" :
     liveSupplyBreak ? "SUPPLY BREAK" :
     liveDemandBreak ? "DEMAND BREAK" :
     bullFollowThrough ? "BULL FOLLOW-THROUGH" :
     bearFollowThrough ? "BEAR FOLLOW-THROUGH" :
     bullDisplacement ? "BULL EXPANSION" :
     bearDisplacement ? "BEAR EXPANSION" :
     bullRejection ? "BULL REJECTION" :
     bearRejection ? "BEAR REJECTION" :
     structureTrend == 1 ? "BULL TREND" :
     structureTrend == -1 ? "BEAR TREND" :
     "TRANSITION"

string htfStateText =
     not useHTFContext ? "DISABLED" :
     htfBullCount == 2 ? "BULLISH" :
     htfBearCount == 2 ? "BEARISH" :
     htfBullCount > htfBearCount ? "LEAN BULL" :
     htfBearCount > htfBullCount ? "LEAN BEAR" :
     "MIXED"

string zoneStateText =
     liveSupplyBreak ? "SUPPLY BROKEN" :
     liveDemandBreak ? "DEMAND BROKEN" :
     insideDemand ? "IN DEMAND" :
     insideSupply ? "IN SUPPLY" :
     not na(nearestDemandDistance) and nearestDemandDistance <= atr * 0.35 ? "NEAR DEMAND" :
     not na(nearestSupplyDistance) and nearestSupplyDistance <= atr * 0.35 ? "NEAR SUPPLY" :
     "BETWEEN ZONES"

string orderFlowText =
     bullFollowThrough ? "BULL FOLLOW-THROUGH" :
     bearFollowThrough ? "BEAR FOLLOW-THROUGH" :
     bullDisplacement ? "BULL DISPLACEMENT" :
     bearDisplacement ? "BEAR DISPLACEMENT" :
     bullRejection ? "BUYERS DEFENDING" :
     bearRejection ? "SELLERS DEFENDING" :
     "BALANCED"

string zoneCountText =
     "D " + str.tostring(array.size(demandBoxes)) +
     " / S " + str.tostring(array.size(supplyBoxes))

string nearestZoneText =
     insideDemand ? "DEMAND" :
     insideSupply ? "SUPPLY" :
     na(demandDistanceATR) and na(supplyDistanceATR) ? "NONE" :
     na(supplyDistanceATR) ? "DEMAND " + str.tostring(demandDistanceATR, "#.##") + " ATR" :
     na(demandDistanceATR) ? "SUPPLY " + str.tostring(supplyDistanceATR, "#.##") + " ATR" :
     demandDistanceATR <= supplyDistanceATR ? "DEMAND " + str.tostring(demandDistanceATR, "#.##") + " ATR" :
     "SUPPLY " + str.tostring(supplyDistanceATR, "#.##") + " ATR"

mobileDashboard = dashboardLayout == "Mobile"
desktopDashboard = dashboardLayout == "Desktop"


desktopLabelWidth = 12
desktopValueWidth = 20
desktopRowHeight = 4

string mobileStructureText =
     freshBullExternalEvent ? (bullCHoCH ? "CH UP" : "BOS UP") :
     freshBearExternalEvent ? (bearCHoCH ? "CH DN" : "BOS DN") :
     structureTrend == 1 ? "HH/HL" :
     structureTrend == -1 ? "LH/LL" :
     "UNCONF"

string mobileMarketText =
     inCongestion ? "RANGE" :
     liveSupplyBreak ? "SUP BRK" :
     liveDemandBreak ? "DEM BRK" :
     bullFollowThrough ? "BULL FT" :
     bearFollowThrough ? "BEAR FT" :
     bullDisplacement ? "BULL EXP" :
     bearDisplacement ? "BEAR EXP" :
     bullRejection ? "BULL REJ" :
     bearRejection ? "BEAR REJ" :
     structureTrend == 1 ? "BULL" :
     structureTrend == -1 ? "BEAR" :
     "TRANS"

string mobileHTFText =
     not useHTFContext ? "OFF" :
     htfBullCount == 2 ? "BULL" :
     htfBearCount == 2 ? "BEAR" :
     htfBullCount > htfBearCount ? "LEAN B" :
     htfBearCount > htfBullCount ? "LEAN S" :
     "MIXED"

string mobileZoneText =
     liveSupplyBreak ? "SUP BRK" :
     liveDemandBreak ? "DEM BRK" :
     insideDemand ? "DEMAND" :
     insideSupply ? "SUPPLY" :
     not na(nearestDemandDistance) and nearestDemandDistance <= atr * 0.35 ? "NEAR DEM" :
     not na(nearestSupplyDistance) and nearestSupplyDistance <= atr * 0.35 ? "NEAR SUP" :
     "BETWEEN"

string mobileFlowText =
     bullFollowThrough ? "BULL FT" :
     bearFollowThrough ? "BEAR FT" :
     bullDisplacement ? "BULL DISP" :
     bearDisplacement ? "BEAR DISP" :
     bullRejection ? "BUYERS" :
     bearRejection ? "SELLERS" :
     "BALANCED"

string dashboardStructureText = mobileDashboard ? mobileStructureText : structureStateText
string dashboardMarketText = mobileDashboard ? mobileMarketText : marketStateText
string dashboardHTFText = mobileDashboard ? mobileHTFText : htfStateText
string dashboardZoneText = mobileDashboard ? mobileZoneText : zoneStateText
string dashboardFlowText = mobileDashboard ? mobileFlowText : orderFlowText

dashboardLocation =
     dashboardPosition == "Top Left" ? position.top_left :
     dashboardPosition == "Bottom Right" ? position.bottom_right :
     dashboardPosition == "Bottom Left" ? position.bottom_left :
     position.top_right


var table dashboard = table.new(
     dashboardLocation,
     2,
     7,
     border_width=1,
     border_color=color.new(color.white, 75),
     frame_width=1,
     frame_color=color.new(color.white, 65)
 )

if showDashboard and barstate.islast
    color structureColor = structureTrend == 1 ? bullColor : structureTrend == -1 ? bearColor : neutralColor
    color marketColor = str.contains(marketStateText, "BULL") or str.contains(marketStateText, "SUPPLY BREAK") ? bullColor : str.contains(marketStateText, "BEAR") or str.contains(marketStateText, "DEMAND BREAK") ? bearColor : marketStateText == "CONGESTION" ? warningColor : neutralColor
    color htfColor = htfBullCount > htfBearCount ? bullColor : htfBearCount > htfBullCount ? bearColor : neutralColor
    color zoneColor = str.contains(zoneStateText, "DEMAND") ? bullColor : str.contains(zoneStateText, "SUPPLY") ? bearColor : neutralColor
    color flowColor = str.contains(orderFlowText, "BULL") or str.contains(orderFlowText, "BUYERS") ? bullColor : str.contains(orderFlowText, "BEAR") or str.contains(orderFlowText, "SELLERS") ? bearColor : neutralColor
    color qualityColor = candleQualityScore >= 75 ? bullColor : candleQualityScore >= 55 ? warningColor : neutralColor

    if mobileDashboard
        table.cell(dashboard, 0, 0, "PA", bgcolor=panelColor, text_color=color.white, text_size=size.small)
        table.cell(dashboard, 1, 0, currentChartIsPrimary ? "PRI" : "CONF", bgcolor=panelColor, text_color=currentChartIsPrimary ? bullColor : warningColor, text_size=size.small)

        table.cell(dashboard, 0, 1, "STR", bgcolor=panelColor, text_color=color.white, text_size=size.tiny)
        table.cell(dashboard, 1, 1, dashboardStructureText, bgcolor=color.new(structureColor, 82), text_color=structureColor, text_size=size.tiny)

        table.cell(dashboard, 0, 2, "MKT", bgcolor=panelColor, text_color=color.white, text_size=size.tiny)
        table.cell(dashboard, 1, 2, dashboardMarketText, bgcolor=color.new(marketColor, 82), text_color=marketColor, text_size=size.tiny)

        table.cell(dashboard, 0, 3, "HTF", bgcolor=panelColor, text_color=color.white, text_size=size.tiny)
        table.cell(dashboard, 1, 3, dashboardHTFText, bgcolor=color.new(htfColor, 82), text_color=htfColor, text_size=size.tiny)

        table.cell(dashboard, 0, 4, "ZONE", bgcolor=panelColor, text_color=color.white, text_size=size.tiny)
        table.cell(dashboard, 1, 4, dashboardZoneText, bgcolor=color.new(zoneColor, 82), text_color=zoneColor, text_size=size.tiny)

        table.cell(dashboard, 0, 5, "FLOW", bgcolor=panelColor, text_color=color.white, text_size=size.tiny)
        table.cell(dashboard, 1, 5, dashboardFlowText, bgcolor=color.new(flowColor, 82), text_color=flowColor, text_size=size.tiny)

        table.cell(dashboard, 0, 6, "PAQ", bgcolor=panelColor, text_color=color.white, text_size=size.tiny)
        table.cell(dashboard, 1, 6, str.tostring(candleQualityScore) + "/100", bgcolor=panelColor, text_color=qualityColor, text_size=size.tiny)

    if desktopDashboard
        table.cell(dashboard, 0, 0, "PRICE ACTION", width=desktopLabelWidth, height=desktopRowHeight + 1, bgcolor=panelColor, text_color=color.white, text_size=size.normal)
        table.cell(dashboard, 1, 0, currentChartIsPrimary ? "PRIMARY" : "CONFLUENCE", width=desktopValueWidth, height=desktopRowHeight + 1, bgcolor=panelColor, text_color=currentChartIsPrimary ? bullColor : warningColor, text_size=size.normal)

        table.cell(dashboard, 0, 1, "STRUCTURE", width=desktopLabelWidth, height=desktopRowHeight, bgcolor=panelColor, text_color=color.white, text_size=size.small)
        table.cell(dashboard, 1, 1, structureStateText, width=desktopValueWidth, height=desktopRowHeight, bgcolor=color.new(structureColor, 82), text_color=structureColor, text_size=size.small)

        table.cell(dashboard, 0, 2, "MARKET", width=desktopLabelWidth, height=desktopRowHeight, bgcolor=panelColor, text_color=color.white, text_size=size.small)
        table.cell(dashboard, 1, 2, marketStateText, width=desktopValueWidth, height=desktopRowHeight, bgcolor=color.new(marketColor, 82), text_color=marketColor, text_size=size.small)

        table.cell(dashboard, 0, 3, "HTF", width=desktopLabelWidth, height=desktopRowHeight, bgcolor=panelColor, text_color=color.white, text_size=size.small)
        table.cell(dashboard, 1, 3, htfStateText, width=desktopValueWidth, height=desktopRowHeight, bgcolor=color.new(htfColor, 82), text_color=htfColor, text_size=size.small)

        table.cell(dashboard, 0, 4, "ZONE", width=desktopLabelWidth, height=desktopRowHeight, bgcolor=panelColor, text_color=color.white, text_size=size.small)
        table.cell(dashboard, 1, 4, zoneStateText, width=desktopValueWidth, height=desktopRowHeight, bgcolor=color.new(zoneColor, 82), text_color=zoneColor, text_size=size.small)

        table.cell(dashboard, 0, 5, "ORDER FLOW", width=desktopLabelWidth, height=desktopRowHeight, bgcolor=panelColor, text_color=color.white, text_size=size.small)
        table.cell(dashboard, 1, 5, orderFlowText, width=desktopValueWidth, height=desktopRowHeight, bgcolor=color.new(flowColor, 82), text_color=flowColor, text_size=size.small)

        table.cell(dashboard, 0, 6, "PA QUALITY", width=desktopLabelWidth, height=desktopRowHeight, bgcolor=panelColor, text_color=color.white, text_size=size.small)
        table.cell(dashboard, 1, 6, str.tostring(candleQualityScore) + " / 100", width=desktopValueWidth, height=desktopRowHeight, bgcolor=panelColor, text_color=qualityColor, text_size=size.small)
else if barstate.islast
    table.clear(dashboard, 0, 0, 1, 6)

// ============================================================================
// ANALYSIS ALERTS ONLY
// ============================================================================

alertcondition(enableStructureAlerts and freshBullExternalEvent, title="Bullish Structure Event", message="Price Action Reader {{ticker}} {{interval}}: External bullish BOS or CHoCH confirmed.")
alertcondition(enableStructureAlerts and freshBearExternalEvent, title="Bearish Structure Event", message="Price Action Reader {{ticker}} {{interval}}: External bearish BOS or CHoCH confirmed.")
alertcondition(enableZoneAlerts and liveSupplyBreak, title="Supply Zone Broken", message="Price Action Reader {{ticker}} {{interval}}: Supply zone broken by bullish displacement.")
alertcondition(enableZoneAlerts and liveDemandBreak, title="Demand Zone Broken", message="Price Action Reader {{ticker}} {{interval}}: Demand zone broken by bearish displacement.")
alertcondition(enableZoneAlerts and newFlipDemand, title="Flip Demand Created", message="Price Action Reader {{ticker}} {{interval}}: Broken supply converted into flip demand.")
alertcondition(enableZoneAlerts and newFlipSupply, title="Flip Supply Created", message="Price Action Reader {{ticker}} {{interval}}: Broken demand converted into flip supply.")
````
