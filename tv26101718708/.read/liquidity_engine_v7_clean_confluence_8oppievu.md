# Liquidity Engine v7 | Clean Confluence

- url: https://www.tradingview.com/script/8OpPiEVU-Liquidity-Engine-v7-Clean-Confluence/
- type: indicator
- pine_id: PUB;0e4ec3b9ff594baba04868382e0f9419
- version: 1.0

## Description

Liquidity Engine v7 | Clean Confluence

Liquidity Engine v7 is a price-action and liquidity-based confluence indicator designed to bring several market-structure concepts into one organized system without overcrowding the chart.
Rather than treating every signal as an isolated event, the indicator uses persistent confluence memory. This allows confirmations that develop across multiple candles—such as a liquidity sweep followed by displacement, a structure break, FVG formation, and VWAP confirmation—to remain part of the active setup for a configurable period.

Core Features:
- Liquidity Sweeps — Tracks sweeps of previous-day highs/lows and opening-range liquidity.
- 30-Minute Opening Range — Automatically identifies ORH/ORL and monitors breakout/retest behavior.
- PDH / PDL — Displays previous-day high and low as important liquidity references.
- Market Structure — Identifies bullish and bearish BOS and CHoCH using confirmed swing structure.
- Automatic Trendlines — Builds short swing-to-swing trendlines and marks confirmed breaks.
- FVG / IFVG Detection — Highlights qualifying fair value gaps and tracks inversion when price breaks through an imbalance.
- Order Blocks — Locates opposing candles associated with displacement and structure breaks.
- VWAP + Deviation Bands — Provides intraday price-location and expansion context.
- Flow Strength Bubbles — Uses relative volume, candle displacement, body efficiency, and VWAP deviation to classify directional activity into progressively stronger visual tiers.
- Persistent Confluence Engine — Remembers recent structural events instead of requiring every confirmation to occur on the same candle.
- Confluence Dashboard — Displays active bullish and bearish confirmations, flow conditions, and the resulting directional bias in one compact panel.
- Custom Alerts — Supports alerts for bullish/bearish confluence, liquidity sweeps, trendline breaks, and structure breaks.

How the Confluence System Works
The indicator evaluates multiple independent pieces of evidence rather than relying on a single entry signal.

A potential bullish sequence might develop as:
Sell-Side Liquidity Sweep → Trendline Break → BOS/CHoCH → FVG/OB → Retest → VWAP Confirmation → Buying Pressure

The bearish process works in reverse.
Because these events naturally occur across several candles, the Confluence Memory setting allows recent confirmations to remain active while a setup develops.

The dashboard compares active bullish and bearish conditions and displays WAIT, BULL, or BEAR when the configured confirmation threshold is reached.

Flow Bubbles:
Bubble size represents the strength of the indicator's flow proxy:
Small/Faded: Moderate activity
Medium: Strong activity
Large: Institutional-strength activity

Flow strength is calculated from relative volume, displacement, candle-body efficiency, and VWAP deviation.

NOTE** The bubbles do not represent direct institutional order-book data. They are a price-and-volume-based proxy designed to highlight unusually strong participation.
Customization

Users can adjust opening-range settings, liquidity memory, FVG size and lifespan, order-block sensitivity, pivot strength, trendline length/history, structure memory, flow thresholds, confluence memory, minimum directional confirmations, dashboard position, and dashboard size.

Important Note:
The percentage displayed by Liquidity Engine represents the percentage of the indicator's configured confluence conditions currently aligned in a direction. It is not a predicted probability of price moving higher or lower and should not be interpreted as a historical win rate.

Liquidity Engine is intended as an analytical and educational tool for organizing market context. It does not provide financial advice or guarantee trade outcomes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © norman_qetuwrah

//@version=6
indicator("Liquidity Engine v7 | Clean Confluence", overlay=true,
     max_boxes_count=150, max_lines_count=300, max_labels_count=150)

//=====================================================================
// 1. SETTINGS
//=====================================================================

//-------------------------
// OPENING RANGE
//-------------------------
groupORB = "1. Opening Range"

showORB = input.bool(true, "Show ORH / ORL", group=groupORB)
orbSession = input.session("0930-1000", "Opening Range", group=groupORB)
orbRetestTicks = input.int(5, "Retest Tolerance (Ticks)", minval=1, group=groupORB)

//-------------------------
// PDH / PDL + LIQUIDITY
//-------------------------
groupLiquidity = "2. Liquidity"

showPD = input.bool(true, "Show PDH / PDL", group=groupLiquidity)
showSweeps = input.bool(true, "Detect Liquidity Sweeps", group=groupLiquidity)
sweepMemory = input.int(20, "Sweep Memory (Bars)", minval=1, maxval=100, group=groupLiquidity)

//-------------------------
// VWAP
//-------------------------
groupVWAP = "3. VWAP"

showVWAP = input.bool(true, "Show VWAP", group=groupVWAP)
show1SD = input.bool(true, "Show ±1 SD", group=groupVWAP)
show2SD = input.bool(false, "Show ±2 SD", group=groupVWAP)

//-------------------------
// FVG / IFVG
//-------------------------
groupFVG = "4. FVG / IFVG"

showFVG = input.bool(true, "Show FVG", group=groupFVG)
showIFVG = input.bool(true, "Show IFVG", group=groupFVG)

fvgATR = input.float(
     0.15,
     "Minimum FVG Size (ATR)",
     minval=0.05,
     step=0.05,
     group=groupFVG)

fvgLife = input.int(
     25,
     "FVG Maximum Length",
     minval=5,
     maxval=100,
     group=groupFVG)

maxFVG = input.int(
     3,
     "Maximum Active FVGs",
     minval=1,
     maxval=6,
     group=groupFVG)

//-------------------------
// ORDER BLOCKS
//-------------------------
groupOB = "5. Order Blocks"

showOB = input.bool(true, "Show Order Blocks", group=groupOB)

obLookback = input.int(
     8,
     "Opposite Candle Search",
     minval=2,
     maxval=20,
     group=groupOB)

obLife = input.int(
     25,
     "Order Block Length",
     minval=5,
     maxval=100,
     group=groupOB)

obDisplacementATR = input.float(
     0.80,
     "Minimum Displacement (ATR)",
     minval=0.20,
     step=0.10,
     group=groupOB)

//-------------------------
// TRENDLINES
//-------------------------
groupTrend = "6. Trendlines"

showTrend = input.bool(true, "Show Trendlines", group=groupTrend)

pivotLength = input.int(
     4,
     "Pivot Strength",
     minval=2,
     maxval=15,
     group=groupTrend)

trendProjection = input.int(
     12,
     "Trendline Length",
     minval=3,
     maxval=50,
     group=groupTrend)

trendHistory = input.int(
     8,
     "Historical Trendlines",
     minval=2,
     maxval=20,
     group=groupTrend)

showTLBreak = input.bool(true, "Show Trendline Break X", group=groupTrend)

//-------------------------
// MARKET STRUCTURE
//-------------------------
groupStructure = "7. Market Structure"

showStructure = input.bool(true, "Show BOS / CHoCH", group=groupStructure)

structureMemory = input.int(
     20,
     "Structure Memory (Bars)",
     minval=3,
     maxval=100,
     group=groupStructure)

//-------------------------
// FLOW
//-------------------------
groupFlow = "8. Institutional Flow"

showFlow = input.bool(true, "Show Flow Bubbles", group=groupFlow)

bubbleCooldown = input.int(
     3,
     "Bubble Cooldown",
     minval=0,
     maxval=20,
     group=groupFlow)

strongThreshold = input.int(
     5,
     "Strong Threshold",
     minval=3,
     maxval=8,
     group=groupFlow)

institutionalThreshold = input.int(
     7,
     "Institutional Threshold",
     minval=5,
     maxval=9,
     group=groupFlow)

//-------------------------
// CONFLUENCE ENGINE
//-------------------------
groupConfluence = "9. Confluence Engine"

confirmationMemory = input.int(
     20,
     "Confirmation Memory (Bars)",
     minval=3,
     maxval=100,
     group=groupConfluence)

minimumSignalScore = input.int(
     4,
     "Minimum Confirmations for Direction Box",
     minval=2,
     maxval=7,
     group=groupConfluence)

//-------------------------
// DASHBOARD
//-------------------------
groupDash = "10. Dashboard"

showDashboard = input.bool(true, "Show Dashboard", group=groupDash)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     group=groupDash)

dashboardSize = input.string(
     "Small",
     "Dashboard Size",
     options=["Tiny", "Small", "Normal"],
     group=groupDash)

//=====================================================================
// 2. CORE VALUES
//=====================================================================

atr = ta.atr(14)
tick = syminfo.mintick
newDay = ta.change(time("D")) != 0

//=====================================================================
// 3. VWAP
//=====================================================================

vwapValue = ta.vwap(hlc3)

var float sessionVolume = 0.0
var float sessionPV = 0.0
var float sessionPV2 = 0.0

if newDay
    sessionVolume := 0.0
    sessionPV := 0.0
    sessionPV2 := 0.0

sessionVolume += volume
sessionPV += volume * hlc3
sessionPV2 += volume * hlc3 * hlc3

weightedMean =
     sessionVolume > 0 ?
     sessionPV / sessionVolume :
     hlc3

weightedVariance =
     sessionVolume > 0 ?
     math.max(
         sessionPV2 / sessionVolume -
         weightedMean * weightedMean,
         0.0) :
     0.0

vwapSD = math.sqrt(weightedVariance)

upper1 = vwapValue + vwapSD
lower1 = vwapValue - vwapSD

upper2 = vwapValue + (2.0 * vwapSD)
lower2 = vwapValue - (2.0 * vwapSD)

plot(
     showVWAP ? vwapValue : na,
     "VWAP",
     color=color.purple,
     linewidth=2)

plot(
     showVWAP and show1SD ? upper1 : na,
     "+1 SD",
     color=color.new(color.purple, 60))

plot(
     showVWAP and show1SD ? lower1 : na,
     "-1 SD",
     color=color.new(color.purple, 60))

plot(
     showVWAP and show2SD ? upper2 : na,
     "+2 SD",
     color=color.new(color.purple, 80))

plot(
     showVWAP and show2SD ? lower2 : na,
     "-2 SD",
     color=color.new(color.purple, 80))

//=====================================================================
// 4. OPENING RANGE
//=====================================================================

inORB =
     not na(
         time(
             timeframe.period,
             orbSession,
             "America/New_York"))

orbStart = inORB and not inORB[1]

var float orbHigh = na
var float orbLow = na

if newDay
    orbHigh := na
    orbLow := na

if orbStart
    orbHigh := high
    orbLow := low
else if inORB
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow := math.min(nz(orbLow, low), low)

orbReady =
     not inORB and
     not na(orbHigh) and
     not na(orbLow)

plot(
     showORB and orbReady ? orbHigh : na,
     "ORH",
     color=color.new(color.green, 20),
     linewidth=1,
     style=plot.style_linebr)

plot(
     showORB and orbReady ? orbLow : na,
     "ORL",
     color=color.new(color.red, 20),
     linewidth=1,
     style=plot.style_linebr)

//=====================================================================
// 5. ORB RETEST
//=====================================================================

bullORBreak =
     orbReady and
     close > orbHigh and
     close[1] <= orbHigh

bearORBreak =
     orbReady and
     close < orbLow and
     close[1] >= orbLow

var int bullORBreakBar = na
var int bearORBreakBar = na

if bullORBreak
    bullORBreakBar := bar_index

if bearORBreak
    bearORBreakBar := bar_index

orbTolerance = tick * orbRetestTicks

bullORBRetest =
     not na(bullORBreakBar) and
     bar_index > bullORBreakBar and
     bar_index - bullORBreakBar <= confirmationMemory and
     low <= orbHigh + orbTolerance and
     close > orbHigh

bearORBRetest =
     not na(bearORBreakBar) and
     bar_index > bearORBreakBar and
     bar_index - bearORBreakBar <= confirmationMemory and
     high >= orbLow - orbTolerance and
     close < orbLow

if bullORBRetest
    bullORBreakBar := na

if bearORBRetest
    bearORBreakBar := na

//=====================================================================
// 6. PDH / PDL
//=====================================================================

pdh =
     request.security(
         syminfo.tickerid,
         "D",
         high[1],
         lookahead=barmerge.lookahead_on)

pdl =
     request.security(
         syminfo.tickerid,
         "D",
         low[1],
         lookahead=barmerge.lookahead_on)

// Only display after first 30 minutes completes.

plot(
     showPD and orbReady ? pdh : na,
     "PDH",
     color=color.new(color.orange, 10),
     linewidth=1,
     style=plot.style_linebr)

plot(
     showPD and orbReady ? pdl : na,
     "PDL",
     color=color.new(color.orange, 10),
     linewidth=1,
     style=plot.style_linebr)

//=====================================================================
// 7. LIQUIDITY SWEEPS
//=====================================================================

pdhSweep =
     orbReady and
     high > pdh and
     close < pdh

pdlSweep =
     orbReady and
     low < pdl and
     close > pdl

orhSweep =
     orbReady and
     high > orbHigh and
     close < orbHigh

orlSweep =
     orbReady and
     low < orbLow and
     close > orbLow

bearSweep = pdhSweep or orhSweep
bullSweep = pdlSweep or orlSweep

var int lastBullSweep = na
var int lastBearSweep = na

if bullSweep
    lastBullSweep := bar_index

if bearSweep
    lastBearSweep := bar_index

bullSweepActive =
     not na(lastBullSweep) and
     bar_index - lastBullSweep <= sweepMemory

bearSweepActive =
     not na(lastBearSweep) and
     bar_index - lastBearSweep <= sweepMemory

//=====================================================================
// 8. FLOW STRENGTH
//=====================================================================

volumeAverage = ta.sma(volume, 20)

relativeVolume =
     volumeAverage > 0 ?
     volume / volumeAverage :
     0.0

barRange = high - low
bodySize = math.abs(close - open)

bodyEfficiency =
     barRange > 0 ?
     bodySize / barRange :
     0.0

displacement =
     atr > 0 ?
     barRange / atr :
     0.0

vwapDeviation =
     vwapSD > 0 ?
     math.abs(close - vwapValue) / vwapSD :
     0.0

int volumePoints =
     relativeVolume >= 2.0 ? 3 :
     relativeVolume >= 1.5 ? 2 :
     relativeVolume >= 1.0 ? 1 :
     0

int displacementPoints =
     displacement >= 1.5 ? 2 :
     displacement >= 1.0 ? 1 :
     0

int efficiencyPoints =
     bodyEfficiency >= 0.70 ? 2 :
     bodyEfficiency >= 0.50 ? 1 :
     0

int deviationPoints =
     vwapDeviation >= 2.0 ? 2 :
     vwapDeviation >= 1.0 ? 1 :
     0

flowScore =
     volumePoints +
     displacementPoints +
     efficiencyPoints +
     deviationPoints

flowPercent =
     math.min(
         100.0,
         (flowScore / 9.0) * 100.0)

bullFlow = close > open
bearFlow = close < open

moderateFlow =
     flowScore >= 3 and
     flowScore < strongThreshold

strongFlow =
     flowScore >= strongThreshold and
     flowScore < institutionalThreshold

institutionalFlow =
     flowScore >= institutionalThreshold

//=====================================================================
// 9. FLOW BUBBLES - ACTUAL DIFFERENT SIZES
//=====================================================================

var int lastBullBubble = na
var int lastBearBubble = na

bullBubbleOK =
     na(lastBullBubble) or
     bar_index - lastBullBubble >= bubbleCooldown

bearBubbleOK =
     na(lastBearBubble) or
     bar_index - lastBearBubble >= bubbleCooldown

bullBubble =
     showFlow and
     bullFlow and
     flowScore >= 3 and
     bullBubbleOK

bearBubble =
     showFlow and
     bearFlow and
     flowScore >= 3 and
     bearBubbleOK

if bullBubble
    lastBullBubble := bar_index

if bearBubble
    lastBearBubble := bar_index

plotshape(
     bullBubble and moderateFlow,
     title="Moderate Buying",
     style=shape.circle,
     location=location.belowbar,
     color=color.new(color.green, 50),
     size=size.tiny)

plotshape(
     bearBubble and moderateFlow,
     title="Moderate Selling",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(color.red, 50),
     size=size.tiny)

plotshape(
     bullBubble and strongFlow,
     title="Strong Buying",
     style=shape.circle,
     location=location.belowbar,
     color=color.new(color.green, 15),
     size=size.small)

plotshape(
     bearBubble and strongFlow,
     title="Strong Selling",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(color.red, 15),
     size=size.small)

plotshape(
     bullBubble and institutionalFlow,
     title="Institutional Buying",
     style=shape.circle,
     location=location.belowbar,
     color=color.lime,
     size=size.large)

plotshape(
     bearBubble and institutionalFlow,
     title="Institutional Selling",
     style=shape.circle,
     location=location.abovebar,
     color=color.red,
     size=size.large)

//=====================================================================
// 10. PIVOTS
//=====================================================================

pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

var float lastHigh = na
var float previousHigh = na
var int lastHighBar = na
var int previousHighBar = na

var float lastLow = na
var float previousLow = na
var int lastLowBar = na
var int previousLowBar = na

if not na(pivotHigh)
    previousHigh := lastHigh
    previousHighBar := lastHighBar

    lastHigh := pivotHigh
    lastHighBar := bar_index - pivotLength

if not na(pivotLow)
    previousLow := lastLow
    previousLowBar := lastLowBar

    lastLow := pivotLow
    lastLowBar := bar_index - pivotLength

//=====================================================================
// 11. CLEAN HISTORICAL TRENDLINES
//=====================================================================

var array<line> resistanceLines = array.new_line()
var array<line> supportLines = array.new_line()

var line activeResistance = na
var line activeSupport = na

if showTrend and
   not na(previousHigh) and
   not na(lastHigh) and
   not na(previousHighBar) and
   not na(lastHighBar) and
   not na(pivotHigh)

    highSlope =
         (lastHigh - previousHigh) /
         math.max(lastHighBar - previousHighBar, 1)

    highEnd =
         lastHigh +
         highSlope * trendProjection

    activeResistance := line.new(
         x1=previousHighBar,
         y1=previousHigh,
         x2=lastHighBar + trendProjection,
         y2=highEnd,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(color.red, 20),
         width=2)

    array.push(resistanceLines, activeResistance)

    if array.size(resistanceLines) > trendHistory
        oldLine = array.shift(resistanceLines)
        line.delete(oldLine)

if showTrend and
   not na(previousLow) and
   not na(lastLow) and
   not na(previousLowBar) and
   not na(lastLowBar) and
   not na(pivotLow)

    lowSlope =
         (lastLow - previousLow) /
         math.max(lastLowBar - previousLowBar, 1)

    lowEnd =
         lastLow +
         lowSlope * trendProjection

    activeSupport := line.new(
         x1=previousLowBar,
         y1=previousLow,
         x2=lastLowBar + trendProjection,
         y2=lowEnd,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(color.green, 20),
         width=2)

    array.push(supportLines, activeSupport)

    if array.size(supportLines) > trendHistory
        oldLine = array.shift(supportLines)
        line.delete(oldLine)

//=====================================================================
// 12. TRENDLINE BREAKS
//=====================================================================

float resistancePrice = na
float resistancePrevious = na

float supportPrice = na
float supportPrevious = na

if not na(activeResistance)
    resistancePrice :=
         line.get_price(activeResistance, bar_index)

    resistancePrevious :=
         line.get_price(activeResistance, bar_index - 1)

if not na(activeSupport)
    supportPrice :=
         line.get_price(activeSupport, bar_index)

    supportPrevious :=
         line.get_price(activeSupport, bar_index - 1)

bullTLBreak =
     not na(resistancePrice) and
     not na(resistancePrevious) and
     close > resistancePrice and
     close[1] <= resistancePrevious

bearTLBreak =
     not na(supportPrice) and
     not na(supportPrevious) and
     close < supportPrice and
     close[1] >= supportPrevious

plotshape(
     showTLBreak and bullTLBreak,
     title="Bull Trend Break",
     text="×",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.green, 100),
     textcolor=color.green,
     size=size.small)

plotshape(
     showTLBreak and bearTLBreak,
     title="Bear Trend Break",
     text="×",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.red, 100),
     textcolor=color.red,
     size=size.small)

var int lastBullTLBreak = na
var int lastBearTLBreak = na

if bullTLBreak
    lastBullTLBreak := bar_index

if bearTLBreak
    lastBearTLBreak := bar_index

bullTLActive =
     not na(lastBullTLBreak) and
     bar_index - lastBullTLBreak <= confirmationMemory

bearTLActive =
     not na(lastBearTLBreak) and
     bar_index - lastBearTLBreak <= confirmationMemory

//=====================================================================
// 13. BOS / CHOCH
//=====================================================================

var int structureBias = 0

bullStructureBreak =
     not na(lastHigh) and
     close > lastHigh and
     close[1] <= lastHigh

bearStructureBreak =
     not na(lastLow) and
     close < lastLow and
     close[1] >= lastLow

bullCHOCH =
     bullStructureBreak and
     structureBias == -1

bullBOS =
     bullStructureBreak and
     structureBias != -1

bearCHOCH =
     bearStructureBreak and
     structureBias == 1

bearBOS =
     bearStructureBreak and
     structureBias != 1

if bullStructureBreak
    structureBias := 1

if bearStructureBreak
    structureBias := -1

//=====================================================================
// 14. CLEAN BOS / CHOCH LINES
//=====================================================================

if showStructure and bullStructureBreak

    structureColor =
         bullCHOCH ?
         color.lime :
         color.green

    structureText =
         bullCHOCH ?
         "CHoCH" :
         "BOS"

    line.new(
         x1=lastHighBar,
         y1=lastHigh,
         x2=bar_index,
         y2=lastHigh,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=structureColor,
         style=line.style_dashed,
         width=1)

    label.new(
         x=int(math.round((lastHighBar + bar_index) / 2)),
         y=lastHigh,
         text=structureText,
         xloc=xloc.bar_index,
         style=label.style_none,
         textcolor=structureColor,
         size=size.tiny)

if showStructure and bearStructureBreak

    structureColor =
         bearCHOCH ?
         color.orange :
         color.red

    structureText =
         bearCHOCH ?
         "CHoCH" :
         "BOS"

    line.new(
         x1=lastLowBar,
         y1=lastLow,
         x2=bar_index,
         y2=lastLow,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=structureColor,
         style=line.style_dashed,
         width=1)

    label.new(
         x=int(math.round((lastLowBar + bar_index) / 2)),
         y=lastLow,
         text=structureText,
         xloc=xloc.bar_index,
         style=label.style_none,
         textcolor=structureColor,
         size=size.tiny)

//=====================================================================
// 15. STRUCTURE MEMORY
//=====================================================================

var int lastBullStructure = na
var int lastBearStructure = na

if bullStructureBreak
    lastBullStructure := bar_index

if bearStructureBreak
    lastBearStructure := bar_index

bullStructureActive =
     not na(lastBullStructure) and
     bar_index - lastBullStructure <= structureMemory

bearStructureActive =
     not na(lastBearStructure) and
     bar_index - lastBearStructure <= structureMemory

//=====================================================================
// 16. FVG STORAGE
//=====================================================================

var array<box> bullFVGBoxes = array.new_box()
var array<float> bullFVGBottoms = array.new_float()
var array<int> bullFVGCreated = array.new_int()

var array<box> bearFVGBoxes = array.new_box()
var array<float> bearFVGTop = array.new_float()
var array<int> bearFVGCreated = array.new_int()

bullFVG =
     bar_index >= 2 and
     low > high[2] and
     low - high[2] >= atr * fvgATR

bearFVG =
     bar_index >= 2 and
     high < low[2] and
     low[2] - high >= atr * fvgATR

//=====================================================================
// 17. CREATE FVG
//=====================================================================

if showFVG and bullFVG

    bullBox = box.new(
         left=bar_index - 2,
         top=low,
         right=bar_index + fvgLife,
         bottom=high[2],
         xloc=xloc.bar_index,
         bgcolor=color.new(color.green, 88),
         border_color=color.new(color.green, 45),
         text="FVG",
         text_color=color.new(color.green, 15),
         text_size=size.tiny)

    array.push(bullFVGBoxes, bullBox)
    array.push(bullFVGBottoms, high[2])
    array.push(bullFVGCreated, bar_index)

    if array.size(bullFVGBoxes) > maxFVG
        oldBox = array.shift(bullFVGBoxes)
        box.delete(oldBox)
        array.shift(bullFVGBottoms)
        array.shift(bullFVGCreated)

if showFVG and bearFVG

    bearBox = box.new(
         left=bar_index - 2,
         top=low[2],
         right=bar_index + fvgLife,
         bottom=high,
         xloc=xloc.bar_index,
         bgcolor=color.new(color.red, 88),
         border_color=color.new(color.red, 45),
         text="FVG",
         text_color=color.new(color.red, 15),
         text_size=size.tiny)

    array.push(bearFVGBoxes, bearBox)
    array.push(bearFVGTop, low[2])
    array.push(bearFVGCreated, bar_index)

    if array.size(bearFVGBoxes) > maxFVG
        oldBox = array.shift(bearFVGBoxes)
        box.delete(oldBox)
        array.shift(bearFVGTop)
        array.shift(bearFVGCreated)

//=====================================================================
// 18. FVG → IFVG / CLEANUP
//=====================================================================

bool bullIFVGEvent = false
bool bearIFVGEvent = false

if array.size(bullFVGBoxes) > 0

    int i = array.size(bullFVGBoxes) - 1

    while i >= 0

        currentBox = array.get(bullFVGBoxes, i)
        bottom = array.get(bullFVGBottoms, i)
        created = array.get(bullFVGCreated, i)

        broken =
             close < bottom

        expired =
             bar_index - created > fvgLife

        if broken

            if showIFVG
                box.set_bgcolor(
                     currentBox,
                     color.new(color.red, 87))

                box.set_border_color(
                     currentBox,
                     color.new(color.red, 40))

                box.set_text(
                     currentBox,
                     "IFVG")

                box.set_right(
                     currentBox,
                     bar_index + 8)

                bearIFVGEvent := true
            else
                box.delete(currentBox)

            array.remove(bullFVGBoxes, i)
            array.remove(bullFVGBottoms, i)
            array.remove(bullFVGCreated, i)

        else if expired

            box.delete(currentBox)

            array.remove(bullFVGBoxes, i)
            array.remove(bullFVGBottoms, i)
            array.remove(bullFVGCreated, i)

        i -= 1

if array.size(bearFVGBoxes) > 0

    int i = array.size(bearFVGBoxes) - 1

    while i >= 0

        currentBox = array.get(bearFVGBoxes, i)
        top = array.get(bearFVGTop, i)
        created = array.get(bearFVGCreated, i)

        broken =
             close > top

        expired =
             bar_index - created > fvgLife

        if broken

            if showIFVG
                box.set_bgcolor(
                     currentBox,
                     color.new(color.green, 87))

                box.set_border_color(
                     currentBox,
                     color.new(color.green, 40))

                box.set_text(
                     currentBox,
                     "IFVG")

                box.set_right(
                     currentBox,
                     bar_index + 8)

                bullIFVGEvent := true
            else
                box.delete(currentBox)

            array.remove(bearFVGBoxes, i)
            array.remove(bearFVGTop, i)
            array.remove(bearFVGCreated, i)

        else if expired

            box.delete(currentBox)

            array.remove(bearFVGBoxes, i)
            array.remove(bearFVGTop, i)
            array.remove(bearFVGCreated, i)

        i -= 1

//=====================================================================
// 19. ORDER BLOCKS
//=====================================================================

bullDisplacement =
     close > open and
     barRange >= atr * obDisplacementATR

bearDisplacement =
     close < open and
     barRange >= atr * obDisplacementATR

bullOBTrigger =
     showOB and
     bullStructureBreak and
     bullDisplacement

bearOBTrigger =
     showOB and
     bearStructureBreak and
     bearDisplacement

var box bullOBBox = na
var box bearOBBox = na

var float bullOBBottom = na
var float bearOBTop = na

if bullOBTrigger

    int foundOffset = na

    for j = 1 to obLookback
        if na(foundOffset) and close[j] < open[j]
            foundOffset := j

    if not na(foundOffset)

        if not na(bullOBBox)
            box.delete(bullOBBox)

        bullOBBottom := low[foundOffset]

        bullOBBox := box.new(
             left=bar_index - foundOffset,
             top=high[foundOffset],
             right=bar_index + obLife,
             bottom=low[foundOffset],
             xloc=xloc.bar_index,
             bgcolor=color.new(color.teal, 87),
             border_color=color.new(color.teal, 35),
             text="OB",
             text_color=color.teal,
             text_size=size.tiny)

if bearOBTrigger

    int foundOffset = na

    for j = 1 to obLookback
        if na(foundOffset) and close[j] > open[j]
            foundOffset := j

    if not na(foundOffset)

        if not na(bearOBBox)
            box.delete(bearOBBox)

        bearOBTop := high[foundOffset]

        bearOBBox := box.new(
             left=bar_index - foundOffset,
             top=high[foundOffset],
             right=bar_index + obLife,
             bottom=low[foundOffset],
             xloc=xloc.bar_index,
             bgcolor=color.new(color.orange, 87),
             border_color=color.new(color.orange, 35),
             text="OB",
             text_color=color.orange,
             text_size=size.tiny)

// Remove invalid OBs.

if not na(bullOBBox) and
   not na(bullOBBottom) and
   close < bullOBBottom

    box.delete(bullOBBox)
    bullOBBox := na
    bullOBBottom := na

if not na(bearOBBox) and
   not na(bearOBTop) and
   close > bearOBTop

    box.delete(bearOBBox)
    bearOBBox := na
    bearOBTop := na

//=====================================================================
// 20. EVENT MEMORY
//=====================================================================

var int lastBullFVG = na
var int lastBearFVG = na

var int lastBullIFVG = na
var int lastBearIFVG = na

var int lastBullOB = na
var int lastBearOB = na

var int lastBullORBRetest = na
var int lastBearORBRetest = na

if bullFVG
    lastBullFVG := bar_index

if bearFVG
    lastBearFVG := bar_index

if bullIFVGEvent
    lastBullIFVG := bar_index

if bearIFVGEvent
    lastBearIFVG := bar_index

if bullOBTrigger
    lastBullOB := bar_index

if bearOBTrigger
    lastBearOB := bar_index

if bullORBRetest
    lastBullORBRetest := bar_index

if bearORBRetest
    lastBearORBRetest := bar_index

bullFVGActive =
     not na(lastBullFVG) and
     bar_index - lastBullFVG <= confirmationMemory

bearFVGActive =
     not na(lastBearFVG) and
     bar_index - lastBearFVG <= confirmationMemory

bullIFVGActive =
     not na(lastBullIFVG) and
     bar_index - lastBullIFVG <= confirmationMemory

bearIFVGActive =
     not na(lastBearIFVG) and
     bar_index - lastBearIFVG <= confirmationMemory

bullOBActive =
     not na(lastBullOB) and
     bar_index - lastBullOB <= confirmationMemory

bearOBActive =
     not na(lastBearOB) and
     bar_index - lastBearOB <= confirmationMemory

bullORBActive =
     not na(lastBullORBRetest) and
     bar_index - lastBullORBRetest <= confirmationMemory

bearORBActive =
     not na(lastBearORBRetest) and
     bar_index - lastBearORBRetest <= confirmationMemory

//=====================================================================
// 21. CONFLUENCE ENGINE
//=====================================================================

// VWAP is directional rather than simply counting "touches".

bullVWAP = close > vwapValue
bearVWAP = close < vwapValue

// Location relative to opening range.

bullORBPosition =
     orbReady and
     close > orbHigh

bearORBPosition =
     orbReady and
     close < orbLow

// Flow confirmation requires actual candle direction.

bullFlowConfirmed =
     bullFlow and
     flowScore >= strongThreshold

bearFlowConfirmed =
     bearFlow and
     flowScore >= strongThreshold

// Seven major confluences.

int bullScore = 0
int bearScore = 0

bullScore += bullSweepActive ? 1 : 0
bullScore += bullTLActive ? 1 : 0
bullScore += bullStructureActive ? 1 : 0
bullScore += bullVWAP ? 1 : 0
bullScore += bullFlowConfirmed ? 1 : 0
bullScore += (bullFVGActive or bullIFVGActive or bullOBActive) ? 1 : 0
bullScore += (bullORBActive or bullORBPosition) ? 1 : 0

bearScore += bearSweepActive ? 1 : 0
bearScore += bearTLActive ? 1 : 0
bearScore += bearStructureActive ? 1 : 0
bearScore += bearVWAP ? 1 : 0
bearScore += bearFlowConfirmed ? 1 : 0
bearScore += (bearFVGActive or bearIFVGActive or bearOBActive) ? 1 : 0
bearScore += (bearORBActive or bearORBPosition) ? 1 : 0

bullPercent =
     math.round(
         bullScore / 7.0 * 100)

bearPercent =
     math.round(
         bearScore / 7.0 * 100)

// Direction only wins if it actually has more confirmations.

bullDirection =
     bullScore >= minimumSignalScore and
     bullScore > bearScore

bearDirection =
     bearScore >= minimumSignalScore and
     bearScore > bullScore

//=====================================================================
// 22. DIRECTION BOX ON CHART
//=====================================================================

var box directionBox = na
var label directionLabel = na
var int lastDirection = 0

currentDirection =
     bullDirection ? 1 :
     bearDirection ? -1 :
     0

newDirection =
     currentDirection != 0 and
     currentDirection != lastDirection

if newDirection

    if not na(directionBox)
        box.delete(directionBox)

    if not na(directionLabel)
        label.delete(directionLabel)

    if bullDirection

        directionBox := box.new(
             left=bar_index,
             top=high + atr * 0.55,
             right=bar_index + 5,
             bottom=high + atr * 0.15,
             xloc=xloc.bar_index,
             bgcolor=color.new(color.green, 78),
             border_color=color.green,
             border_width=2)

        directionLabel := label.new(
             x=bar_index + 2,
             y=high + atr * 0.35,
             text="BULLISH " + str.tostring(bullPercent) + "%",
             xloc=xloc.bar_index,
             style=label.style_none,
             textcolor=color.white,
             size=size.small)

    if bearDirection

        directionBox := box.new(
             left=bar_index,
             top=low - atr * 0.15,
             right=bar_index + 5,
             bottom=low - atr * 0.55,
             xloc=xloc.bar_index,
             bgcolor=color.new(color.red, 78),
             border_color=color.red,
             border_width=2)

        directionLabel := label.new(
             x=bar_index + 2,
             y=low - atr * 0.35,
             text="BEARISH " + str.tostring(bearPercent) + "%",
             xloc=xloc.bar_index,
             style=label.style_none,
             textcolor=color.white,
             size=size.small)

lastDirection := currentDirection

//=====================================================================
// 23. FLOW DESCRIPTION
//=====================================================================

flowDescription =
     institutionalFlow ?
         (bullFlow ?
             "Institutional Buying" :
             "Institutional Selling") :
     strongFlow ?
         (bullFlow ?
             "Strong Buying" :
             "Strong Selling") :
     moderateFlow ?
         (bullFlow ?
             "Moderate Buying" :
             "Moderate Selling") :
     "Low / Neutral"

flowDisplay =
     flowDescription +
     " " +
     str.tostring(math.round(flowPercent)) +
     "%"

//=====================================================================
// 24. DASHBOARD POSITION + SIZE
//=====================================================================

dashPosition =
     dashboardPosition == "Top Left" ?
         position.top_left :
     dashboardPosition == "Top Center" ?
         position.top_center :
     dashboardPosition == "Top Right" ?
         position.top_right :
     dashboardPosition == "Middle Left" ?
         position.middle_left :
     dashboardPosition == "Middle Center" ?
         position.middle_center :
     dashboardPosition == "Middle Right" ?
         position.middle_right :
     dashboardPosition == "Bottom Left" ?
         position.bottom_left :
     dashboardPosition == "Bottom Center" ?
         position.bottom_center :
         position.bottom_right

dashTextSize =
     dashboardSize == "Tiny" ?
         size.tiny :
     dashboardSize == "Normal" ?
         size.normal :
         size.small

//=====================================================================
// 25. DASHBOARD
//=====================================================================

var table dashboard =
     table.new(
         dashPosition,
         3,
         10,
         bgcolor=color.new(color.black, 15),
         border_width=1)

confirmedText(condition) =>
    condition ? "✓" : "—"

confirmedColor(condition, bullish) =>
    condition ?
         (bullish ? color.lime : color.red) :
         color.gray

if barstate.islast and showDashboard

    table.cell(
         dashboard,
         0,
         0,
         "CONFLUENCE",
         text_color=color.white,
         text_size=dashTextSize,
         bgcolor=color.new(color.gray, 70))

    table.cell(
         dashboard,
         1,
         0,
         "BULL",
         text_color=color.lime,
         text_size=dashTextSize,
         bgcolor=color.new(color.gray, 70))

    table.cell(
         dashboard,
         2,
         0,
         "BEAR",
         text_color=color.red,
         text_size=dashTextSize,
         bgcolor=color.new(color.gray, 70))

    // Liquidity

    table.cell(
         dashboard,
         0,
         1,
         "Liquidity Sweep",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         1,
         confirmedText(bullSweepActive),
         text_color=confirmedColor(bullSweepActive, true),
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         1,
         confirmedText(bearSweepActive),
         text_color=confirmedColor(bearSweepActive, false),
         text_size=dashTextSize)

    // Trendline

    table.cell(
         dashboard,
         0,
         2,
         "Trend Break",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         2,
         confirmedText(bullTLActive),
         text_color=confirmedColor(bullTLActive, true),
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         2,
         confirmedText(bearTLActive),
         text_color=confirmedColor(bearTLActive, false),
         text_size=dashTextSize)

    // Structure

    table.cell(
         dashboard,
         0,
         3,
         "BOS / CHoCH",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         3,
         confirmedText(bullStructureActive),
         text_color=confirmedColor(bullStructureActive, true),
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         3,
         confirmedText(bearStructureActive),
         text_color=confirmedColor(bearStructureActive, false),
         text_size=dashTextSize)

    // VWAP

    table.cell(
         dashboard,
         0,
         4,
         "VWAP",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         4,
         confirmedText(bullVWAP),
         text_color=confirmedColor(bullVWAP, true),
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         4,
         confirmedText(bearVWAP),
         text_color=confirmedColor(bearVWAP, false),
         text_size=dashTextSize)

    // Flow

    table.cell(
         dashboard,
         0,
         5,
         "Order Flow",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         5,
         confirmedText(bullFlowConfirmed),
         text_color=confirmedColor(bullFlowConfirmed, true),
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         5,
         confirmedText(bearFlowConfirmed),
         text_color=confirmedColor(bearFlowConfirmed, false),
         text_size=dashTextSize)

    // FVG / OB

    bullZone =
         bullFVGActive or
         bullIFVGActive or
         bullOBActive

    bearZone =
         bearFVGActive or
         bearIFVGActive or
         bearOBActive

    table.cell(
         dashboard,
         0,
         6,
         "FVG / IFVG / OB",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         6,
         confirmedText(bullZone),
         text_color=confirmedColor(bullZone, true),
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         6,
         confirmedText(bearZone),
         text_color=confirmedColor(bearZone, false),
         text_size=dashTextSize)

    // ORB

    bullORBConfirmation =
         bullORBActive or
         bullORBPosition

    bearORBConfirmation =
         bearORBActive or
         bearORBPosition

    table.cell(
         dashboard,
         0,
         7,
         "30m ORB",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         7,
         confirmedText(bullORBConfirmation),
         text_color=confirmedColor(bullORBConfirmation, true),
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         7,
         confirmedText(bearORBConfirmation),
         text_color=confirmedColor(bearORBConfirmation, false),
         text_size=dashTextSize)

    // Flow strength

    table.cell(
         dashboard,
         0,
         8,
         "Flow Strength",
         text_color=color.white,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         1,
         8,
         bullFlow ? flowDisplay : "—",
         text_color=bullFlow ? color.lime : color.gray,
         text_size=dashTextSize)

    table.cell(
         dashboard,
         2,
         8,
         bearFlow ? flowDisplay : "—",
         text_color=bearFlow ? color.red : color.gray,
         text_size=dashTextSize)

    // Final bias

    finalText =
         bullDirection ?
             "BULL " + str.tostring(bullPercent) + "%" :
         bearDirection ?
             "BEAR " + str.tostring(bearPercent) + "%" :
             "WAIT"

    finalColor =
         bullDirection ?
             color.green :
         bearDirection ?
             color.red :
             color.orange

    table.cell(
         dashboard,
         0,
         9,
         "OUTCOME",
         text_color=color.white,
         text_size=dashTextSize,
         bgcolor=color.new(finalColor, 55))

    table.cell(
         dashboard,
         1,
         9,
         finalText,
         text_color=color.white,
         text_size=dashTextSize,
         bgcolor=color.new(finalColor, 55))

    table.cell(
         dashboard,
         2,
         9,
         str.tostring(math.max(bullScore, bearScore)) + "/7",
         text_color=color.white,
         text_size=dashTextSize,
         bgcolor=color.new(finalColor, 55))

//=====================================================================
// 26. ALERTS
//=====================================================================

alertcondition(
     bullDirection and not bullDirection[1],
     "Bullish Confluence",
     "Liquidity Engine: Bullish confluence confirmed.")

alertcondition(
     bearDirection and not bearDirection[1],
     "Bearish Confluence",
     "Liquidity Engine: Bearish confluence confirmed.")

alertcondition(
     bullSweep,
     "Bullish Liquidity Sweep",
     "Bullish liquidity sweep detected.")

alertcondition(
     bearSweep,
     "Bearish Liquidity Sweep",
     "Bearish liquidity sweep detected.")

alertcondition(
     bullTLBreak,
     "Bullish Trendline Break",
     "Bullish trendline break detected.")

alertcondition(
     bearTLBreak,
     "Bearish Trendline Break",
     "Bearish trendline break detected.")

alertcondition(
     bullStructureBreak,
     "Bullish Structure Break",
     "Bullish BOS / CHoCH detected.")

alertcondition(
     bearStructureBreak,
     "Bearish Structure Break",
     "Bearish BOS / CHoCH detected.")
````
