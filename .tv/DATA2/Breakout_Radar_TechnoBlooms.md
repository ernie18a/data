<!-- tradingview-pine-id: PUB;449bf0688ebe4490b53ca9b26fa7fd99 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Breakout Radar (TechnoBlooms)

Source: https://www.tradingview.com/script/p40tl5M6-Breakout-Radar-TechnoBlooms/

## Description

Breakout Radar (TechnoBlooms)
Compression • Pressure • Bias • Breakout Confirmation
A structure-first breakout analysis tool designed to identify when quiet price action is building toward a directional move.
Overview
Breakout Radar is a price-compression and breakout-pressure indicator developed by TechnoBlooms. Instead of simply marking every new high or low as a breakout, it first looks for a compressed market structure, measures the pressure developing inside that structure, identifies directional bias, and then waits for price to confirm a break beyond the locked range.
The objective is simple: help traders distinguish between ordinary sideways movement and a consolidation that may be preparing for expansion. The indicator is designed as a decision-support tool, not as an automatic buy/sell system.
What Makes Breakout Radar Different?
Compression first: The system searches for contraction in volatility and price structure before considering a breakout.
Locked structure boxes: Once a qualifying compression is detected, its boundaries are locked instead of continuously following price like a conventional range filter.
Bull vs Bear Pressure: The indicator evaluates how price is behaving near the upper and lower boundaries and converts that behaviour into separate Bull Pressure and Bear Pressure readings.
Pressure Delta and Bias: The difference between bullish and bearish pressure helps identify whether the structure is leaning BULLISH, BEARISH or remains NEUTRAL.
Progressive radar states: The setup develops through SCANNING, BUILDING, WATCH and ARMED states rather than jumping immediately to a signal.
Confirmed breakout: A breakout requires price to close beyond the locked structure with an ATR-based confirmation buffer.
Signal validity buffer: After confirmation, the latest breakout signal can remain valid through a normal retest and is removed only when its stored invalidation level is breached or a newer breakout replaces it.
Clean historical context: Completed compression structures remain faintly visible so traders can study how earlier consolidations resolved, while overlap filtering reduces unnecessary nested boxes.
How to Read the Dashboard
Dashboard Item	Interpretation
Compression	Measures how strongly the current market is contracting. Higher values indicate tighter compression relative to recent conditions.
Bull Pressure	Measures bullish pressure developing inside the active structure.
Bear Pressure	Measures bearish pressure developing inside the active structure.
Pressure Delta	Bull Pressure minus Bear Pressure. A positive value favours bulls; a negative value favours bears.
Bias	Summarises the current directional pressure as BULLISH, BEARISH or NEUTRAL.
Radar State	SCANNING = no active setup; BUILDING = compression found; WATCH = pressure is becoming meaningful; ARMED = pressure and compression have reached stronger conditions.
Understanding the Radar States
SCANNING — The indicator is monitoring the market, but no qualifying compression structure is currently active.
BUILDING — A compression structure has been identified. Pressure is developing, but the setup is not yet strong enough to demand close attention.
WATCH — Pressure has strengthened. Traders may begin watching the box boundaries and directional bias more closely.
ARMED — Compression and directional pressure have reached stronger conditions. This does not mean a breakout has already happened; it means the structure deserves heightened attention.
How the Breakout Signal Works
A bullish breakout is considered confirmed when price closes above the locked upper boundary plus the configured ATR confirmation buffer and bullish pressure is stronger than bearish pressure. A bearish breakout uses the opposite logic below the lower boundary.
Only the latest relevant breakout arrow is retained. The arrow is intentionally small so the chart remains focused on structure rather than becoming filled with historical signal markers.
The signal is not automatically removed after a fixed number of candles. At the moment of confirmation, Breakout Radar stores an ATR-based invalidation level. This allows price to perform a normal retest without immediately cancelling the breakout. The signal disappears when the breakout is invalidated or when a newer confirmed breakout replaces it.
Example 1 — Bullish Compression Breakout
Assume a stock trades sideways between ₹980 and ₹1,000 while volatility contracts. Breakout Radar identifies the compression and locks a box around the structure. As price repeatedly tests the upper portion of the box, Bull Pressure rises from 48 to 64 and then to 78, while Bear Pressure remains near 42.
The dashboard may progress from BUILDING → WATCH → ARMED with a BULLISH bias. If price subsequently closes above the upper boundary plus the breakout confirmation buffer, a small bullish arrow appears. A minor pullback toward the breakout area does not automatically remove the signal; it remains valid until the stored bullish invalidation level is breached.
Example 2 — Bearish Compression Breakout
Imagine an index consolidating between 24,800 and 25,000. During the consolidation, repeated pressure develops near the lower boundary. Bear Pressure increases to 81 while Bull Pressure falls to 51, producing a negative Pressure Delta and a BEARISH bias.
Once price closes below the locked lower boundary with the required ATR buffer, the bearish breakout is confirmed and a small downward arrow appears. The completed compression box remains on the chart as historical context while the Radar is free to scan independently for the next compression structure.
Example 3 — Why ARMED Is Not the Same as BUY or SELL
Suppose Compression is 76, Bull Pressure is 80 and Bear Pressure is 49. The Radar can show ARMED with a BULLISH bias even though price is still inside the box. This is an early-warning condition, not a trade confirmation. If price fails to break the upper boundary and pressure weakens, the setup can remain inside the structure or change bias. The breakout arrow appears only after the actual confirmation condition is met.
Reading the Boxes
The rectangles represent detected compression structures. The active structure is used for live pressure and breakout analysis. After a breakout, the completed box can remain lightly visible to show where the expansion originated. An overlap filter is used to reduce repeated boxes representing substantially the same price structure.
How Breakout Radar Compares with Other Popular Tools
Breakout Radar shares some visual ideas with range filters, order blocks, and support/resistance tools because all of them study how price behaves around important areas. The similarity, however, is mainly in the chart structure. Breakout Radar is built for a different question: is the market compressing, which side is applying more pressure, and has that compression actually expanded into a confirmed breakout?
Tool	Main Purpose	Similarity	Key Difference
Range Filter	Smooth price noise and identify directional movement or a filtered trading range.	Both may show boundaries around price and can help traders recognise a transition from sideways movement to expansion.	A range filter usually moves or recalculates with price. Breakout Radar first detects compression, locks the structure, measures Bull/Bear Pressure inside it, and waits for a buffered close outside the box.
Order Block	Mark price areas associated with prior institutional-style supply/demand concepts or displacement.	Both can leave historical zones on the chart and both may become areas traders watch during later price interaction.	Breakout Radar does not claim to identify institutional orders or actual order flow. Its boxes represent measured compression structures, not order blocks. Direction is assessed from price behaviour and pressure within the compression.
Support & Resistance	Identify levels or zones where price has previously reacted, stalled, reversed, or broken.	The top and bottom of a Breakout Radar box naturally act as temporary resistance and support while the compression remains active.	Traditional S&R starts with reaction levels. Breakout Radar starts with volatility/structure compression and then adds pressure, bias, state progression and breakout confirmation.
Breakout Radar	Identify compressed structures, measure directional pressure, and confirm expansion beyond a locked range.	Uses price boundaries just as many classical technical tools do.	Combines compression scoring, locked boxes, Bull/Bear Pressure, Pressure Delta, Bias, BUILDING/WATCH/ARMED states, ATR breakout confirmation and signal invalidation in one workflow.
1. Breakout Radar vs Range Filter
The closest visual comparison is a range filter because both can make consolidation and directional movement easy to see. But Breakout Radar is not designed to continuously filter price. Once a qualifying compression is found, the box is locked. The indicator then studies what is happening inside that fixed structure. A trader can therefore see whether pressure is building toward the upper boundary, the lower boundary, or neither.
Example: price may remain inside a ₹500-₹510 box while Bull Pressure rises from 52 to 79. A conventional range filter may simply continue tracking the range or trend. Breakout Radar can move from BUILDING to WATCH to ARMED while the price is still inside the box, and only confirms the bullish breakout after a close above the upper boundary plus the ATR confirmation buffer.
2. Breakout Radar vs Order Blocks
An order-block indicator normally attempts to identify a zone associated with an earlier impulsive move and treats that area as a possible future supply or demand zone. Breakout Radar does something different: the rectangle is created because the current market has compressed, not because the script is labelling an institutional order area.
The historical boxes may therefore look superficially similar to order-block zones, but their meaning is different. A green completed Breakout Radar box means a compression structure eventually resolved upward; a red completed box means it resolved downward. It should not be interpreted as proof that institutional buying or selling occurred inside that box.
3. Breakout Radar vs Support & Resistance
Support and resistance are still relevant to Breakout Radar. In fact, the lower and upper boundaries of an active compression naturally behave like short-term support and resistance. The difference is that those boundaries are only one layer of the analysis.
Breakout Radar also asks whether volatility is compressed, how frequently price is pressuring each boundary, where price is persisting inside the structure, whether the internal structure is squeezing in one direction, and whether the final candle behaviour supports that direction. These components feed the Bull Pressure, Bear Pressure, Pressure Delta and Bias readings.
Where They Can Be Used Together
These tools do not have to compete with one another. A trader may use higher-timeframe support/resistance or a separately identified order-block area for context, then use Breakout Radar on the execution timeframe to see whether price is compressing near that area and whether directional pressure is developing. Likewise, a range or trend tool can provide broader directional context while Breakout Radar focuses specifically on the compression-to-expansion phase.
A Simple Way to Remember the Difference
•	Range Filter asks: Where is filtered price/trend moving?
•	Order Block asks: Where is a previously significant supply/demand-style zone?
•	Support & Resistance asks: Where has price reacted or may react again?
•	Breakout Radar asks: Is price compressing now, which side is building pressure, and has expansion been confirmed?
This distinction is central to the TechnoBlooms concept: the box itself is not the signal. The information comes from the evolution of compression, pressure, bias and eventual breakout confirmation.
Suggested Workflow
1.	Look for an active compression box rather than chasing price after an extended move.
2.	Check whether the Radar is BUILDING, WATCH or ARMED.
3.	Compare Bull Pressure and Bear Pressure, then confirm the Pressure Delta and Bias.
4.	Treat ARMED as preparation, not confirmation.
5.	Wait for a confirmed close beyond the relevant box boundary and confirmation buffer.
6.	Use the breakout invalidation level together with your own risk-management process.
7.	Confirm higher-timeframe structure, liquidity, market context and event risk before acting.
Important Notes
Breakout Radar does not predict that every compression will produce a successful breakout. Markets can generate false breaks, gaps, news-driven moves and rapid reversals. Pressure readings are analytical measurements derived from price behaviour; they are not exchange order-flow data.
The indicator does not provide profit targets or broker execution. This is intentional: Breakout Radar focuses on identifying compression, directional pressure, breakout confirmation and subsequent validity.
Recommended Markets & Timeframes
The concept can be applied to liquid equities, indices, futures, forex, commodities and crypto. Because volatility characteristics differ by instrument and timeframe, users should validate the default settings on the market they trade. Lower timeframes generally produce more setups and more noise; higher timeframes generally produce fewer but broader structures.
Alerts
Breakout Radar supports alert conditions for bullish ARMED, bearish ARMED, bullish breakout confirmation and bearish breakout confirmation. For live use, traders should configure TradingView alerts according to their preferred symbol, timeframe and confirmation workflow.
TradingView-Ready Short Description
Breakout Radar (TechnoBlooms) is a structure-first compression and breakout-pressure indicator designed to identify when a quiet market may be preparing for expansion. It combines volatility compression, locked price structures, Bull/Bear Pressure, Pressure Delta and directional Bias with progressive SCANNING → BUILDING → WATCH → ARMED states. Breakouts are confirmed only after price closes beyond the locked structure with an ATR-based buffer. The latest breakout signal remains visible while structurally valid, while completed compression boxes provide clean historical context. Breakout Radar is designed as a decision-support and market-structure tool rather than a standalone buy/sell system.
Disclaimer
For educational and analytical purposes only. This indicator does not constitute investment advice, a recommendation, or a guarantee of future performance. Trading and investing involve risk. Users should perform their own analysis and apply appropriate risk management before making trading decisions.

---

## Source Code

````pine
// This indicator is created under TechnoBlooms - Innovating Trading Indicators and Strategies.
// All rights reserved. Unauthorized copying or distribution is prohibited.
// © TechnoBlooms

//@version=6
indicator("Breakout Radar (TechnoBlooms)", overlay=true, max_boxes_count=100, max_labels_count=50)

//------------------------------------------------------------
// Inputs
//------------------------------------------------------------

compressionLength     = input.int(12, minval=6, title="Compression Structure Length")
atrLength             = input.int(14, minval=5, title="ATR Length")
atrBaseLength         = input.int(50, minval=20, title="ATR Base Length")

bbLength              = input.int(20, minval=10, title="BB Length")
bbMult                = input.float(2.0, minval=0.5, step=0.1, title="BB Multiplier")

pressureLength        = input.int(10, minval=5, title="Pressure Length")
boundaryTolerance     = input.float(0.20, minval=0.05, step=0.05, title="Boundary Tolerance %")

compressionTrigger    = input.float(60.0, minval=20, maxval=100, title="Compression Trigger")
buildingLevel         = input.float(45.0, minval=0, maxval=100, title="Building Pressure")
watchLevel            = input.float(60.0, minval=0, maxval=100, title="Watch Pressure")
armedLevel            = input.float(75.0, minval=0, maxval=100, title="Armed Pressure")

breakoutBufferATR     = input.float(0.10, minval=0.0, step=0.05, title="Breakout Confirmation Buffer ATR")
invalidationBufferATR = input.float(0.35, minval=0.10, step=0.05, title="Breakout Invalidation Buffer ATR")

overlapLimit          = input.float(65.0, minval=10, maxval=100, step=5, title="Maximum Box Overlap %")
minBoxGapATR          = input.float(0.25, minval=0.0, step=0.05, title="Minimum New Box Separation ATR")

showDashboard         = input.bool(true, title="Show Dashboard")
showStatusLabel       = input.bool(true, title="Show Current Status")

//------------------------------------------------------------
// Helper Function
//------------------------------------------------------------

clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

//------------------------------------------------------------
// Basic Market Calculations
//------------------------------------------------------------

atrNow  = ta.atr(atrLength)
atrBase = ta.sma(atrNow, atrBaseLength)

candleRange = high - low

//------------------------------------------------------------
// ATR Compression
//------------------------------------------------------------

atrRatio =
     atrBase != 0 ?
     atrNow / atrBase :
     1.0

atrCompression =
     clamp(
         (1.40 - atrRatio) / 0.90,
         0.0,
         1.0
     ) * 100.0

//------------------------------------------------------------
// Price Range Compression
//------------------------------------------------------------

structureHigh =
     ta.highest(
         high,
         compressionLength
     )

structureLow =
     ta.lowest(
         low,
         compressionLength
     )

currentStructureRange =
     structureHigh - structureLow

normalBarRange =
     ta.sma(
         high - low,
         atrBaseLength
     )

expectedStructureRange =
     normalBarRange *
     compressionLength

structureRatio =
     expectedStructureRange != 0 ?
     currentStructureRange / expectedStructureRange :
     1.0

rangeCompression =
     clamp(
         (1.10 - structureRatio) / 0.90,
         0.0,
         1.0
     ) * 100.0

//------------------------------------------------------------
// Bollinger Band Compression
//------------------------------------------------------------

bbBasis =
     ta.sma(
         close,
         bbLength
     )

bbDev =
     ta.stdev(
         close,
         bbLength
     ) * bbMult

bbUpper =
     bbBasis + bbDev

bbLower =
     bbBasis - bbDev

bbWidth =
     bbBasis != 0 ?
     (bbUpper - bbLower) / bbBasis :
     0.0

bbWidthAverage =
     ta.sma(
         bbWidth,
         atrBaseLength
     )

bbRatio =
     bbWidthAverage != 0 ?
     bbWidth / bbWidthAverage :
     1.0

bbCompression =
     clamp(
         (1.40 - bbRatio) / 0.90,
         0.0,
         1.0
     ) * 100.0

//------------------------------------------------------------
// Final Compression Score
//------------------------------------------------------------

compressionScore =
     atrCompression * 0.40 +
     rangeCompression * 0.35 +
     bbCompression * 0.25

compressionScore :=
     clamp(
         compressionScore,
         0.0,
         100.0
     )

//------------------------------------------------------------
// Compression Setup Variables
//------------------------------------------------------------

var bool setupActive = false

var float boxTop    = na
var float boxBottom = na

var int setupStartBar = na

var box activeBox = na

//------------------------------------------------------------
// Previous Completed Box
//------------------------------------------------------------

var float lastBoxTop    = na
var float lastBoxBottom = na
var int lastBoxEndBar   = na

//------------------------------------------------------------
// Last Breakout Signal
//------------------------------------------------------------

var bool signalActive = false

var string signalSide = ""

var float signalBreakoutLevel = na
var float signalInvalidation  = na

var label signalLabel = na

//------------------------------------------------------------
// Current Status Label
//------------------------------------------------------------

var label statusLabel = na

//------------------------------------------------------------
// Proposed New Compression Box
//------------------------------------------------------------

proposedTop =
     structureHigh

proposedBottom =
     structureLow

proposedHeight =
     proposedTop - proposedBottom

//------------------------------------------------------------
// Box Overlap Calculation
//------------------------------------------------------------

float overlapAmount  = 0.0
float overlapPercent = 0.0

if not na(lastBoxTop) and
   not na(lastBoxBottom) and
   proposedHeight > 0

    overlapTop =
         math.min(
             proposedTop,
             lastBoxTop
         )

    overlapBottom =
         math.max(
             proposedBottom,
             lastBoxBottom
         )

    overlapAmount :=
         math.max(
             overlapTop - overlapBottom,
             0.0
         )

    overlapPercent :=
         overlapAmount /
         proposedHeight *
         100.0

//------------------------------------------------------------
// Minimum Separation Check
//------------------------------------------------------------

newBoxSeparated = true

if not na(lastBoxTop) and
   not na(lastBoxBottom)

    aboveOldBox =
         proposedBottom >
         lastBoxTop +
         atrNow * minBoxGapATR

    belowOldBox =
         proposedTop <
         lastBoxBottom -
         atrNow * minBoxGapATR

    lowOverlap =
         overlapPercent <
         overlapLimit

    newBoxSeparated :=
         aboveOldBox or
         belowOldBox or
         lowOverlap

//------------------------------------------------------------
// Enough Data
//------------------------------------------------------------

enoughData =
     not na(compressionScore) and
     not na(structureHigh) and
     not na(structureLow)

//------------------------------------------------------------
// Detect New Compression
//------------------------------------------------------------

newCompression =
     enoughData and
     compressionScore >= compressionTrigger and
     not setupActive and
     newBoxSeparated

//------------------------------------------------------------
// Create Locked Compression Box
//------------------------------------------------------------

if newCompression

    setupActive := true

    setupStartBar :=
         bar_index

    boxTop :=
         proposedTop

    boxBottom :=
         proposedBottom

    //--------------------------------------------------------
    // Create fresh active box
    //--------------------------------------------------------

    activeBox :=
         box.new(
             left=bar_index - compressionLength + 1,
             top=boxTop,
             right=bar_index,
             bottom=boxBottom,
             bgcolor=color.new(color.orange, 96),
             border_color=color.new(color.orange, 35),
             border_width=1
         )

//------------------------------------------------------------
// Extend Active Compression Box
//------------------------------------------------------------

if setupActive and
   not na(activeBox)

    box.set_right(
         activeBox,
         bar_index
    )

//------------------------------------------------------------
// Box Measurements
//------------------------------------------------------------

boxHeight =
     setupActive ?
     boxTop - boxBottom :
     na

upperTolerance =
     setupActive ?
     math.max(
         boxTop * boundaryTolerance / 100.0,
         atrNow * 0.10
     ) :
     na

lowerTolerance =
     setupActive ?
     math.max(
         boxBottom * boundaryTolerance / 100.0,
         atrNow * 0.10
     ) :
     na

//------------------------------------------------------------
// Boundary Attacks
//------------------------------------------------------------

float bullTouches = 0.0
float bearTouches = 0.0

if setupActive

    for i = 0 to pressureLength - 1

        if high[i] >= boxTop - upperTolerance and
           high[i] <= boxTop + upperTolerance

            bullTouches += 1

        if low[i] <= boxBottom + lowerTolerance and
           low[i] >= boxBottom - lowerTolerance

            bearTouches += 1

bullAttackScore =
     setupActive ?
     clamp(
         bullTouches / 4.0,
         0.0,
         1.0
     ) * 25.0 :
     0.0

bearAttackScore =
     setupActive ?
     clamp(
         bearTouches / 4.0,
         0.0,
         1.0
     ) * 25.0 :
     0.0

//------------------------------------------------------------
// Price Persistence
//------------------------------------------------------------

float bullPersistence = 0.0
float bearPersistence = 0.0

if setupActive

    for i = 0 to pressureLength - 1

        if close[i] >=
           boxTop - upperTolerance * 2.0

            bullPersistence += 1

        if close[i] <=
           boxBottom + lowerTolerance * 2.0

            bearPersistence += 1

bullPersistenceScore =
     setupActive ?
     clamp(
         bullPersistence /
         pressureLength,
         0.0,
         1.0
     ) * 20.0 :
     0.0

bearPersistenceScore =
     setupActive ?
     clamp(
         bearPersistence /
         pressureLength,
         0.0,
         1.0
     ) * 20.0 :
     0.0

//------------------------------------------------------------
// Structural Squeeze
//------------------------------------------------------------

halfPressure =
     math.max(
         2,
         int(
             math.floor(
                 pressureLength / 2
             )
         )
     )

recentLow =
     ta.lowest(
         low,
         halfPressure
     )

olderLow =
     ta.lowest(
         low[halfPressure],
         halfPressure
     )

recentHigh =
     ta.highest(
         high,
         halfPressure
     )

olderHigh =
     ta.highest(
         high[halfPressure],
         halfPressure
     )

bullStructureStrength =
     setupActive and
     atrNow > 0 ?
     clamp(
         (recentLow - olderLow) /
         atrNow,
         0.0,
         1.0
     ) :
     0.0

bearStructureStrength =
     setupActive and
     atrNow > 0 ?
     clamp(
         (olderHigh - recentHigh) /
         atrNow,
         0.0,
         1.0
     ) :
     0.0

bullStructureScore =
     bullStructureStrength *
     20.0

bearStructureScore =
     bearStructureStrength *
     20.0

//------------------------------------------------------------
// Position Inside Compression Box
//------------------------------------------------------------

boxPosition =
     setupActive and
     boxHeight > 0 ?
     clamp(
         (close - boxBottom) /
         boxHeight,
         0.0,
         1.0
     ) :
     0.5

bullDistanceScore =
     boxPosition *
     20.0

bearDistanceScore =
     (1.0 - boxPosition) *
     20.0

//------------------------------------------------------------
// Candle Pressure
//------------------------------------------------------------

closeLocation =
     candleRange > 0 ?
     (close - low) /
     candleRange :
     0.5

bullBodyStrength =
     candleRange > 0 ?
     math.max(
         close - open,
         0
     ) /
     candleRange :
     0.0

bearBodyStrength =
     candleRange > 0 ?
     math.max(
         open - close,
         0
     ) /
     candleRange :
     0.0

bullCandleStrength =
     closeLocation * 0.60 +
     bullBodyStrength * 0.40

bearCandleStrength =
     (1.0 - closeLocation) * 0.60 +
     bearBodyStrength * 0.40

bullCandleScore =
     setupActive ?
     clamp(
         bullCandleStrength,
         0.0,
         1.0
     ) * 15.0 :
     0.0

bearCandleScore =
     setupActive ?
     clamp(
         bearCandleStrength,
         0.0,
         1.0
     ) * 15.0 :
     0.0

//------------------------------------------------------------
// Bull Pressure
//------------------------------------------------------------

bullPressure =
     bullAttackScore +
     bullPersistenceScore +
     bullStructureScore +
     bullDistanceScore +
     bullCandleScore

bullPressure :=
     clamp(
         bullPressure,
         0.0,
         100.0
     )

//------------------------------------------------------------
// Bear Pressure
//------------------------------------------------------------

bearPressure =
     bearAttackScore +
     bearPersistenceScore +
     bearStructureScore +
     bearDistanceScore +
     bearCandleScore

bearPressure :=
     clamp(
         bearPressure,
         0.0,
         100.0
     )

//------------------------------------------------------------
// Pressure Delta
//------------------------------------------------------------

pressureDelta =
     bullPressure -
     bearPressure

//------------------------------------------------------------
// Direction Bias
//------------------------------------------------------------

bullBias =
     setupActive and
     pressureDelta > 10

bearBias =
     setupActive and
     pressureDelta < -10

string biasText = "NEUTRAL"

if bullBias

    biasText := "BULLISH"

else if bearBias

    biasText := "BEARISH"

//------------------------------------------------------------
// Strongest Pressure
//------------------------------------------------------------

strongPressure =
     math.max(
         bullPressure,
         bearPressure
     )

//------------------------------------------------------------
// Radar State
//------------------------------------------------------------

string radarState = "SCANNING"

if setupActive

    if strongPressure >= armedLevel and
       compressionScore >= compressionTrigger

        radarState := "ARMED"

    else if strongPressure >= watchLevel

        radarState := "WATCH"

    else

        radarState := "BUILDING"

//------------------------------------------------------------
// Breakout Confirmation Buffer
//------------------------------------------------------------

breakoutBuffer =
     atrNow *
     breakoutBufferATR

//------------------------------------------------------------
// Breakout Conditions
//------------------------------------------------------------

bullBreakout =
     setupActive and
     close >
     boxTop + breakoutBuffer and
     bullPressure >
     bearPressure

bearBreakout =
     setupActive and
     close <
     boxBottom - breakoutBuffer and
     bearPressure >
     bullPressure

//------------------------------------------------------------
// Bullish Breakout
//------------------------------------------------------------

if bullBreakout

    //--------------------------------------------------------
    // Remove old signal
    //--------------------------------------------------------

    if not na(signalLabel)

        label.delete(signalLabel)
        signalLabel := na

    //--------------------------------------------------------
    // Store current breakout
    //--------------------------------------------------------

    signalActive := true

    signalSide :=
         "BULLISH"

    signalBreakoutLevel :=
         boxTop

    signalInvalidation :=
         boxTop -
         atrNow *
         invalidationBufferATR

    //--------------------------------------------------------
    // Tiny current arrow
    //--------------------------------------------------------

    signalLabel :=
         label.new(
             bar_index,
             low - atrNow * 0.15,
             "▲",
             style=label.style_none,
             textcolor= color.new(#06f093, 0),
             size=size.tiny
         )

    //--------------------------------------------------------
    // Complete box
    //--------------------------------------------------------

    if not na(activeBox)

        box.set_right(
             activeBox,
             bar_index
        )

        box.set_bgcolor(
             activeBox,
             color.new(color.lime, 96)
        )

        box.set_border_color(
             activeBox,
             color.new(#06f093, 0)
        )

        box.set_border_width(
             activeBox,
             1
        )

    //--------------------------------------------------------
    // Remember completed box
    //--------------------------------------------------------

    lastBoxTop :=
         boxTop

    lastBoxBottom :=
         boxBottom

    lastBoxEndBar :=
         bar_index

    //--------------------------------------------------------
    // Reset current setup only
    //--------------------------------------------------------

    setupActive := false

    boxTop    := na
    boxBottom := na

    setupStartBar := na

    activeBox := na

//------------------------------------------------------------
// Bearish Breakout
//------------------------------------------------------------

if bearBreakout

    //--------------------------------------------------------
    // Remove old signal
    //--------------------------------------------------------

    if not na(signalLabel)

        label.delete(signalLabel)
        signalLabel := na

    //--------------------------------------------------------
    // Store current breakout
    //--------------------------------------------------------

    signalActive := true

    signalSide :=
         "BEARISH"

    signalBreakoutLevel :=
         boxBottom

    signalInvalidation :=
         boxBottom +
         atrNow *
         invalidationBufferATR

    //--------------------------------------------------------
    // Tiny current arrow
    //--------------------------------------------------------

    signalLabel :=
         label.new(
             bar_index,
             high + atrNow * 0.15,
             "▼",
             style=label.style_none,
             textcolor=color.new(#ff03ea, 0),
             size=size.tiny
         )

    //--------------------------------------------------------
    // Complete box
    //--------------------------------------------------------

    if not na(activeBox)

        box.set_right(
             activeBox,
             bar_index
        )

        box.set_bgcolor(
             activeBox,
            color.new(#f70ee4, 95)
        )

        box.set_border_color(
             activeBox,
            color.new(#ff03ea, 0)
        )

        box.set_border_width(
             activeBox,
             1
        )

    //--------------------------------------------------------
    // Remember completed box
    //--------------------------------------------------------

    lastBoxTop :=
         boxTop

    lastBoxBottom :=
         boxBottom

    lastBoxEndBar :=
         bar_index

    //--------------------------------------------------------
    // Reset current setup only
    //--------------------------------------------------------

    setupActive := false

    boxTop    := na
    boxBottom := na

    setupStartBar := na

    activeBox := na

//------------------------------------------------------------
// Breakout Invalidation
//------------------------------------------------------------

bullSignalInvalid =
     signalActive and
     signalSide == "BULLISH" and
     not na(signalInvalidation) and
     close <
     signalInvalidation

bearSignalInvalid =
     signalActive and
     signalSide == "BEARISH" and
     not na(signalInvalidation) and
     close >
     signalInvalidation

//------------------------------------------------------------
// Remove Signal Only When Invalid
//------------------------------------------------------------

if bullSignalInvalid or
   bearSignalInvalid

    if not na(signalLabel)

        label.delete(signalLabel)
        signalLabel := na

    signalActive := false

    signalSide := ""

    signalBreakoutLevel := na
    signalInvalidation  := na

//------------------------------------------------------------
// Active Box Appearance
//------------------------------------------------------------

if setupActive and
   not na(activeBox)

    //--------------------------------------------------------
    // ARMED
    //--------------------------------------------------------

    if radarState == "ARMED"

        if bullBias

            box.set_border_color(
                 activeBox,
                 color.new(#06f093, 0)
            )

        else if bearBias

            box.set_border_color(
                 activeBox,
                color.new(#ff03ea, 0)
            )

        else

            box.set_border_color(
                 activeBox,
                 color.new(color.orange, 10)
            )

        box.set_border_width(
             activeBox,
             2
        )

        box.set_bgcolor(
             activeBox,
             color.new(color.orange, 93)
        )

    //--------------------------------------------------------
    // WATCH
    //--------------------------------------------------------

    else if radarState == "WATCH"

        box.set_border_color(
             activeBox,
             color.new(color.orange, 15)
        )

        box.set_border_width(
             activeBox,
             1
        )

        box.set_bgcolor(
             activeBox,
             color.new(color.orange, 95)
        )

    //--------------------------------------------------------
    // BUILDING
    //--------------------------------------------------------

    else

        box.set_border_color(
             activeBox,
             color.new(#5b5c60, 55)
        )

        box.set_border_width(
             activeBox,
             1
        )

        box.set_bgcolor(
             activeBox,
             color.new(color.gray, 97)
        )

//------------------------------------------------------------
// Current Status Label
//------------------------------------------------------------

if barstate.islast

    //--------------------------------------------------------
    // Delete old status label
    //--------------------------------------------------------

    if not na(statusLabel)

        label.delete(statusLabel)
        statusLabel := na

    //--------------------------------------------------------
    // Show only during active setup
    //--------------------------------------------------------

    if showStatusLabel and
       setupActive

        string statusText = ""

        if radarState == "ARMED"

            statusText :=
                 "ARMED | " +
                 biasText

        else if radarState == "WATCH"

            statusText :=
                 "WATCH | " +
                 biasText

        else

            statusText :=
                 "BUILDING | " +
                 biasText

        //----------------------------------------------------
        // Label position
        //----------------------------------------------------

        float statusPrice =
             bullBias ?
             boxTop :
             bearBias ?
             boxBottom :
             boxTop

        //----------------------------------------------------
        // Label colour
        //----------------------------------------------------

        color statusColor =
             radarState == "ARMED" and bullBias ?
             color.new(#06f093, 0) :
             radarState == "ARMED" and bearBias ?
             color.new(#ff03ea, 0) :
             radarState == "WATCH" ?
             color.new(color.orange, 5) :
             color.new(color.gray, 20)

        //----------------------------------------------------
        // Create label
        //----------------------------------------------------

        statusLabel :=
             label.new(
                 bar_index,
                 statusPrice,
                 statusText,
                 style=label.style_label_left,
                 color=statusColor,
                 textcolor=color.white,
                 size=size.small
             )

//------------------------------------------------------------
// Dashboard
//------------------------------------------------------------

var table radarTable =
     table.new(
         position.top_right,
         2,
         6,
         border_width=1
     )

if barstate.islast and
   showDashboard

    //--------------------------------------------------------
    // Header
    //--------------------------------------------------------

    table.cell(
         radarTable,
         0,
         0,
         "BREAKOUT RADAR",
         text_color=color.white,
         bgcolor=color.rgb(45, 45, 45)
     )

    table.cell(
         radarTable,
         1,
         0,
         radarState,
         text_color=color.white,
         bgcolor=
             radarState == "ARMED" ?
             color.new(color.orange, 5) :
             radarState == "WATCH" ?
             color.new(color.orange, 20) :
             radarState == "BUILDING" ?
             color.new(color.gray, 25) :
             color.new(color.gray, 50)
     )

    //--------------------------------------------------------
    // Compression
    //--------------------------------------------------------

    table.cell(
         radarTable,
         0,
         1,
         "Compression",
         text_color=color.white,
         bgcolor=color.rgb(45, 45, 45)
     )

    table.cell(
         radarTable,
         1,
         1,
         str.tostring(
             compressionScore,
             "#.0"
         ),
         text_color=color.white,
         bgcolor=color.rgb(30, 30, 30)
     )

    //--------------------------------------------------------
    // Bull Pressure
    //--------------------------------------------------------

    table.cell(
         radarTable,
         0,
         2,
         "Bull Pressure",
         text_color=color.white,
         bgcolor=color.rgb(45, 45, 45)
     )

    table.cell(
         radarTable,
         1,
         2,
         str.tostring(
             bullPressure,
             "#.0"
         ),
         text_color= color.new(#06f093, 0),
         bgcolor=color.rgb(30, 30, 30)
     )

    //--------------------------------------------------------
    // Bear Pressure
    //--------------------------------------------------------

    table.cell(
         radarTable,
         0,
         3,
         "Bear Pressure",
         text_color=color.white,
         bgcolor=color.rgb(45, 45, 45)
     )

    table.cell(
         radarTable,
         1,
         3,
         str.tostring(
             bearPressure,
             "#.0"
         ),
         text_color=color.new(#ff03ea, 0),
         bgcolor=color.rgb(30, 30, 30)
     )

    //--------------------------------------------------------
    // Pressure Delta
    //--------------------------------------------------------

    table.cell(
         radarTable,
         0,
         4,
         "Pressure Delta",
         text_color=color.white,
         bgcolor=color.rgb(45, 45, 45)
     )

    table.cell(
         radarTable,
         1,
         4,
         str.tostring(
             pressureDelta,
             "#.0"
         ),
         text_color=
             pressureDelta > 0 ?
             color.new(#06f093, 0) :
             pressureDelta < 0 ?
            color.new(#ff03ea, 0) :
             color.white,
         bgcolor=color.rgb(30, 30, 30)
     )

    //--------------------------------------------------------
    // Bias
    //--------------------------------------------------------

    table.cell(
         radarTable,
         0,
         5,
         "Bias",
         text_color=color.white,
         bgcolor=color.rgb(45, 45, 45)
     )

    table.cell(
         radarTable,
         1,
         5,
         setupActive ?
         biasText :
         signalActive ?
         signalSide :
         "NEUTRAL",
         text_color=
             setupActive and bullBias ?
              color.new(#06f093, 0) :
             setupActive and bearBias ?
            color.new(#ff03ea, 0) :
             signalActive and signalSide == "BULLISH" ?
             color.new(#06f093, 0) :
             signalActive and signalSide == "BEARISH" ?
            color.new(#ff03ea, 0) :
             color.white,
         bgcolor=color.rgb(30, 30, 30)
     )

//------------------------------------------------------------
// Alerts
//------------------------------------------------------------

bullArmed =
     setupActive and
     radarState == "ARMED" and
     bullBias

bearArmed =
     setupActive and
     radarState == "ARMED" and
     bearBias

alertcondition(
     bullArmed,
     title="Bullish Breakout Armed",
     message="TechnoBlooms Breakout Radar: Bullish breakout pressure is ARMED."
)

alertcondition(
     bearArmed,
     title="Bearish Breakout Armed",
     message="TechnoBlooms Breakout Radar: Bearish breakout pressure is ARMED."
)

alertcondition(
     bullBreakout,
     title="Bullish Breakout Confirmed",
     message="TechnoBlooms Breakout Radar: Bullish breakout confirmed."
)

alertcondition(
     bearBreakout,
     title="Bearish Breakout Confirmed",
     message="TechnoBlooms Breakout Radar: Bearish breakout confirmed."
)
````
