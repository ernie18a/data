<!-- tradingview-pine-id: PUB;bbecf8bbdbcf4dcf8a75fb233317aedf -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# In-Play Reversal Scanner [V4.1]

Source: https://www.tradingview.com/script/DNvYDrhJ-Reversal-Scanner-V4-Multi-Timeframe-Exhaustion-Context/

## Description

Reversal Scanner V4 is a multi-timeframe market-state scanner designed to identify directional moves that are becoming increasingly favorable for a potential reversal.

The core idea behind the scanner is simple:

Distance alone does not make a market overextended. How the market traveled that distance matters.

A market that moves 2 ATR over several days through slow, overlapping price action is fundamentally different from one that moves the same distance through rapid expansion, high velocity, and strong directional participation.

Rather than treating every large move as a reversal opportunity, this scanner attempts to answer three separate questions:

1. Is there actually a meaningful directional move in progress?
2. Has that move become statistically or structurally extended?
3. Is the impulse that created the move beginning to deteriorate?

The scanner uses Daily + 1H + 4H analysis to separate these functions.

The Daily timeframe provides the broader move and extension context. The 1H timeframe measures the behavior and velocity of the active impulse. The 4H timeframe evaluates the structure of the move and whether lower-timeframe price action supports the broader reversal thesis.

Understanding the Dashboard

ACTIVE MOVE

This section establishes the directional move currently being evaluated.

Move Age measures how long the active directional move has been developing.

Move / Daily ATR normalizes the total displacement of the move against the instrument's Daily ATR. This makes the scanner more comparable across markets with very different nominal prices and volatility.

A 100-point move in one market may be insignificant while the same nominal move in another could be extreme. ATR normalization helps solve that problem.

IN-PLAY SCORE

The In-Play Score measures whether the current move is sufficiently active to deserve attention.

It incorporates characteristics such as:

Current Velocity — how quickly price is currently moving relative to its normal behavior.

Move RVOL — relative volume associated with the move.

Range Regime — whether current price ranges are compressed, normal, or expanded.

High In-Play readings indicate that the scanner is evaluating a meaningful active move rather than ordinary market noise.

Importantly:

IN PLAY does not mean ENTER.

It means the move has enough activity to warrant further evaluation.

EXTENSION SCORE

Extension measures how far the market has traveled relative to its normal behavior.

The scanner evaluates factors including:

Daily Z-Score — statistical displacement relative to the instrument's recent distribution.

Directional Days — persistence of movement in the current direction.

Hard Extension — identifies particularly extreme displacement conditions.

This section answers:

"Has price traveled far enough for a reversal thesis to become reasonable?"

A market can have extremely high velocity without being sufficiently extended. Likewise, a market can be statistically extended while still possessing enough momentum to continue moving.

For that reason, extension is only one component of the scanner.

IMPULSE HISTORY

This section evaluates the strongest part of the directional move rather than looking only at current conditions.

It tracks characteristics such as:

Peak Velocity — the strongest velocity reached during the move.

Peak Acceleration — the strongest acceleration event observed during the move.

Current Acceleration — how much acceleration remains now.

Deceleration — how substantially the current impulse has deteriorated from its peak.

This is one of the most important concepts behind the scanner.

A market may currently appear slow precisely because it has already exhausted an extremely aggressive impulse.

For example:

High peak velocity → acceleration spike → substantial deceleration

is fundamentally different from:

Low velocity → low acceleration → continued slow movement.

The first represents a potentially exhausted impulse. The second may simply represent a market that was never particularly impulsive.

The scanner therefore preserves information about the history of the move, rather than allowing current conditions to erase evidence of the original expansion.

4H STRUCTURE

The 4-hour layer provides intermediate structural context between the Daily move and 1H impulse measurements.

It evaluates:

4H Legs — the number of meaningful structural legs within the move.

4H Efficiency — how efficiently price has traveled in the dominant direction.

4H Direction — whether intermediate structure remains aligned with the larger move.

Structure Quality provides an overall assessment of whether the move has developed through relatively clean directional structure or increasingly messy/choppy price action.

This is important because mature trends frequently transition from efficient directional movement into overlapping, inefficient structure before a larger reversal develops.

Final Status

The scanner combines these independent components into a final market-state classification.

Rather than producing a binary BUY or SELL signal, it progresses through different stages as the reversal thesis develops.

For example:

WAIT / DEVELOPING
A move exists, but the conditions required for a high-quality reversal thesis have not sufficiently developed.

REVERSAL WATCH
Extension, impulse history, and/or structural deterioration are becoming meaningful enough to begin monitoring the opposite direction.

PRIORITY REVERSAL
Multiple components of the model have aligned sufficiently for the market to become a higher-priority reversal candidate.

The dashboard also displays Potential LONG or Potential SHORT based on the direction opposite the active move.

A bullish active move therefore creates a potential short reversal thesis, while a bearish active move creates a potential long thesis.

How I Use It

This scanner is intended to answer where to look, not when to enter.

My workflow is:

Scan multiple futures markets for high-quality active moves.
Identify instruments progressing into Reversal Watch or Priority Reversal.
Determine whether the move shows a combination of meaningful extension, historically strong impulse, substantial deceleration, and deteriorating/appropriate 4H structure.
Move to a lower timeframe and wait for an actual reversal setup.
Use independent price-action confirmation for execution and risk management.

For example, a market showing:

Strong directional move
High historical velocity
Large acceleration spike
Significant extension
95%+ deceleration from peak impulse
Mature 4H structure

would receive substantially more attention than a market that is merely far away from its starting price.

The scanner itself is not the entry trigger.

Why Multiple Timeframes?

The scanner deliberately separates the analysis across three time horizons:

Daily = Context & Extension
Where is the market within the larger move?

1H = Impulse & Velocity
How aggressively did the move occur, and is that aggression still present?

4H = Structure
How clean or mature is the intermediate structure connecting those two perspectives?

This prevents a common problem with reversal systems: attempting to make a single timeframe simultaneously determine trend, extension, exhaustion, and execution.

What the Scanner Is Designed to Find

The ideal candidate is not simply an "overbought" or "oversold" market.

It is a market that experienced a meaningful directional impulse, traveled far enough to become relevant, and is now showing evidence that the characteristics responsible for that move are deteriorating.

Conceptually:

Impulse → Expansion → Extension → Deceleration → Structural deterioration → Reversal opportunity

The scanner attempts to quantify the first five stages.

Price action determines the sixth.

Important

This indicator is a context and market-state tool, not a standalone trading system.

IN PLAY, REVERSAL WATCH, PRIORITY REVERSAL, Potential LONG, and Potential SHORT should not be interpreted as automatic trade entries.

They identify conditions that may warrant additional analysis.

Users should independently determine entries, stops, targets, position sizing, and risk management.

Past market behavior does not guarantee future results.

---

## Source Code

````pine
//@version=6

indicator("In-Play Reversal Scanner [V4.1]", overlay=true)

//=====================================================================

// INPUTS

//=====================================================================

//---------------------------------------------------------------------

// DISPLAY / PANEL STYLE
//---------------------------------------------------------------------

groupDisplay = "Display / Panel Style"

showPanel = input.bool(
     true,
     "Show Dashboard",
     group=groupDisplay)

panelPosition = input.string(
     "Top Right",
     "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=groupDisplay)

panelMode = input.string(
     "Compact",
     "Panel Mode",
     options=["Compact", "Full"],
     tooltip="Compact is optimized for mobile. Full shows all diagnostic metrics.",
     group=groupDisplay)

panelTextSizeInput = input.string(
     "Small",
     "Panel Text Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupDisplay)

panelBackgroundColor = input.color(
     color.black,
     "Panel Background",
     group=groupDisplay)

panelBackgroundTransparency = input.int(
     10,
     "Panel Background Transparency",
     minval=0,
     maxval=100,
     group=groupDisplay)

panelTextColor = input.color(
     color.white,
     "Primary Text Color",
     group=groupDisplay)

panelMutedTextColor = input.color(
     color.gray,
     "Muted Text Color",
     group=groupDisplay)

panelHeaderColor = input.color(
     color.rgb(15, 42, 95),
     "Header Color",
     group=groupDisplay)

panelHeaderTextColor = input.color(
     color.white,
     "Header / Final Text Color",
     group=groupDisplay)

panelSectionColor = input.color(
     color.rgb(45, 45, 45),
     "Section Header Color",
     group=groupDisplay)

panelSectionTransparency = input.int(
     20,
     "Section Header Transparency",
     minval=0,
     maxval=100,
     group=groupDisplay)

panelPositiveColor = input.color(
     color.rgb(0, 125, 65),
     "Positive / Qualified Color",
     group=groupDisplay)

panelWarningColor = input.color(
     color.rgb(170, 115, 0),
     "Warning / Developing Color",
     group=groupDisplay)

panelExtremeColor = input.color(
     color.rgb(160, 35, 40),
     "Extreme / Reversal Color",
     group=groupDisplay)

panelBullishColor = input.color(
     color.lime,
     "Bullish Direction Color",
     group=groupDisplay)

panelBearishColor = input.color(
     color.red,
     "Bearish Direction Color",
     group=groupDisplay)

panelStatusTransparency = input.int(
     75,
     "Score / Status Cell Transparency",
     minval=0,
     maxval=100,
     group=groupDisplay)

panelFinalTransparency = input.int(
     65,
     "Final Status Transparency",
     minval=0,
     maxval=100,
     group=groupDisplay)

panelBorderColor = input.color(
     color.gray,
     "Border Color",
     group=groupDisplay)

panelBorderTransparency = input.int(
     75,
     "Border Transparency",
     minval=0,
     maxval=100,
     group=groupDisplay)

showPanelFooter = input.bool(
     true,
     "Show Full-Mode Footer",
     group=groupDisplay)

//---------------------------------------------------------------------

// DAILY CONTEXT

//---------------------------------------------------------------------

groupDaily = "Daily Context"

dailyATRLength = input.int(

     14,

     "Daily ATR Length",

     minval=5,

     group=groupDaily)

zLength = input.int(

     20,

     "Daily Z-Score Length",

     minval=10,

     group=groupDaily)

dailyRangeShort = input.int(

     3,

     "Short Range Regime Length",

     minval=2,

     group=groupDaily)

dailyRangeLong = input.int(

     20,

     "Long Range Regime Length",

     minval=5,

     group=groupDaily)

dailyVolumeLength = input.int(

     20,

     "Daily Volume Baseline",

     minval=5,

     group=groupDaily)

//---------------------------------------------------------------------

// 1H IMPULSE ENGINE

//---------------------------------------------------------------------

groupHourly = "1H Impulse Engine"

directionLookback = input.int(

     24,

     "Direction Lookback (Hours)",

     minval=6,

     maxval=96,

     group=groupHourly)

impulseSearchHours = input.int(

     120,

     "Move Origin Search (Hours)",

     minval=24,

     maxval=300,

     group=groupHourly)

hourlyATRLength = input.int(

     14,

     "Hourly ATR Length",

     minval=5,

     group=groupHourly)

velocityBaseline = input.int(

     100,

     "Velocity Baseline",

     minval=30,

     group=groupHourly)

volumeBaseline = input.int(

     100,

     "Hourly Volume Baseline",

     minval=30,

     group=groupHourly)

//---------------------------------------------------------------------

// 4H STRUCTURE

//---------------------------------------------------------------------

groupStructure = "4H Structure"

structureLookback = input.int(

     30,

     "Structure Search (4H Bars)",

     minval=10,

     maxval=75,

     group=groupStructure)

structureDirectionLookback = input.int(

     6,

     "4H Direction Lookback",

     minval=2,

     maxval=24,

     group=groupStructure)

fourHourATRLength = input.int(

     14,

     "4H ATR Length",

     minval=5,

     group=groupStructure)

structureRetraceATR = input.float(

     0.75,

     "Minimum 4H Pullback (ATR)",

     minval=0.20,

     step=0.05,

     group=groupStructure)

idealLegMin = input.int(

     2,

     "Ideal Minimum Legs",

     minval=1,

     maxval=10,

     group=groupStructure)

idealLegMax = input.int(

     5,

     "Ideal Maximum Legs",

     minval=2,

     maxval=12,

     group=groupStructure)

structureEfficiencyThreshold = input.float(

     0.45,

     "Clean Structure Efficiency",

     minval=0.10,

     maxval=1.0,

     step=0.05,

     group=groupStructure)

//---------------------------------------------------------------------

// IN-PLAY

//---------------------------------------------------------------------

groupInPlay = "In-Play"

moveATRThreshold = input.float(

     2.0,

     "Move / Daily ATR",

     minval=0.50,

     step=0.25,

     group=groupInPlay)

relativeVelocityThreshold = input.float(

     1.50,

     "Relative Velocity",

     minval=0.50,

     step=0.10,

     group=groupInPlay)

moveRVOLThreshold = input.float(

     1.25,

     "Move RVOL",

     minval=0.50,

     step=0.05,

     group=groupInPlay)

rangeRegimeThreshold = input.float(

     1.15,

     "Range Regime",

     minval=0.50,

     step=0.05,

     group=groupInPlay)

inPlayMinimum = input.float(

     70.0,

     "Minimum In-Play Score",

     minval=0,

     maxval=100,

     group=groupInPlay)

//---------------------------------------------------------------------

// EXTENSION

//---------------------------------------------------------------------

groupExtension = "Extension"

zThreshold = input.float(

     2.0,

     "Hard Z-Score Threshold",

     minval=0.50,

     step=0.10,

     group=groupExtension)

hardMoveATRThreshold = input.float(

     2.0,

     "Hard Move / ATR Threshold",

     minval=0.50,

     step=0.25,

     group=groupExtension)

directionalDaysThreshold = input.int(

     3,

     "Directional Days",

     minval=1,

     maxval=10,

     group=groupExtension)

moveAgeThreshold = input.float(

     3.0,

     "Move Age (Days)",

     minval=0.5,

     step=0.5,

     group=groupExtension)

extensionMinimum = input.float(

     65.0,

     "Reversal Extension Minimum",

     minval=0,

     maxval=100,

     group=groupExtension)

priorityExtensionMinimum = input.float(

     80.0,

     "Priority Extension Minimum",

     minval=0,

     maxval=100,

     group=groupExtension)

//---------------------------------------------------------------------

// IMPULSE HISTORY

//---------------------------------------------------------------------

groupImpulse = "Impulse History"

peakVelocityThreshold = input.float(

     1.75,

     "Peak Relative Velocity",

     minval=0.50,

     step=0.10,

     group=groupImpulse)

velocityExpansionThreshold = input.float(

     1.00,

     "Peak Velocity Expansion",

     minval=0.10,

     step=0.10,

     tooltip="Increase in relative velocity versus the preceding velocity window.",

     group=groupImpulse)

velocityDecayThreshold = input.float(

     0.25,

     "Priority Velocity Decay",

     minval=0.0,

     maxval=1.0,

     step=0.05,

     tooltip="0.25 means current relative velocity has fallen 25% from peak.",

     group=groupImpulse)

impulseMinimum = input.float(

     50.0,

     "Impulse History Minimum",

     minval=0,

     maxval=100,

     group=groupImpulse)

priorityImpulseMinimum = input.float(

     60.0,

     "Priority Impulse Minimum",

     minval=0,

     maxval=100,

     group=groupImpulse)

//---------------------------------------------------------------------

// MANUAL CONTEXT

//---------------------------------------------------------------------

groupContext = "Manual Context"

freshCatalyst = input.bool(

     false,

     "Fresh News / Catalyst Present?",

     tooltip="Fresh fundamental news reduces confidence in fading the move.",

     group=groupContext)

//=====================================================================

// HELPERS

//=====================================================================

f_clamp(value, minimum, maximum) =>

    math.max(minimum, math.min(maximum, value))

f_score(value, threshold, weight) =>

    float result = 0.0

    if not na(value) and threshold > 0

        result := f_clamp(value / threshold, 0.0, 1.0) * weight

    result

f_position(pos) =>
    switch pos
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_signedText(float value) =>
    string result = ""
    if na(value)
        result := "n/a"
    else if value > 0
        result := "+" + str.tostring(value, "#.00")
    else
        result := str.tostring(value, "#.00")
    result

//=====================================================================
// PANEL STYLE VALUES
//=====================================================================

panelTextSize = switch panelTextSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    => size.small

color panelBg = color.new(
     panelBackgroundColor,
     panelBackgroundTransparency)

color panelBorder = color.new(
     panelBorderColor,
     panelBorderTransparency)

color panelHeaderBg = color.new(
     panelHeaderColor,
     0)

color panelSectionBg = color.new(
     panelSectionColor,
     panelSectionTransparency)

//=====================================================================

// DAILY STREAK

//=====================================================================

f_dailyStreak() =>

    int upCount = 0

    int downCount = 0

    for i = 0 to 9

        if close[i] > close[i + 1]

            upCount += 1

        else

            break

    for i = 0 to 9

        if close[i] < close[i + 1]

            downCount += 1

        else

            break

    int result = 0

    if upCount > 0

        result := upCount

    else if downCount > 0

        result := -downCount

    result

//=====================================================================

// 1H IMPULSE ENGINE

//=====================================================================

f_hourlyMetrics() =>

    float hATR = ta.atr(hourlyATRLength)

    //-------------------------------------------------------------

    // ACTIVE DIRECTION

    //-------------------------------------------------------------

    int dir = 0

    if close > close[directionLookback]

        dir := 1

    else if close < close[directionLookback]

        dir := -1

    //-------------------------------------------------------------

    // MOVE ORIGIN

    //-------------------------------------------------------------

    float bullOrigin = ta.lowest(low, impulseSearchHours + 1)

    float bearOrigin = ta.highest(high, impulseSearchHours + 1)

    int bullBars = math.abs(

         ta.lowestbars(

             low,

             impulseSearchHours + 1))

    int bearBars = math.abs(

         ta.highestbars(

             high,

             impulseSearchHours + 1))

    float origin = close

    int originBars = 0

    if dir == 1

        origin := bullOrigin

        originBars := bullBars

    else if dir == -1

        origin := bearOrigin

        originBars := bearBars

    //-------------------------------------------------------------

    // MOVE DISTANCE

    //-------------------------------------------------------------

    float distance = math.abs(close - origin)

    //-------------------------------------------------------------

    // MOVE RVOL

    //-------------------------------------------------------------

    float moveVolumeSum = 0.0

    int moveVolumeBars = 0

    if originBars > 0

        for step = 0 to impulseSearchHours - 1

            int idx = impulseSearchHours - 1 - step

            if idx < originBars

                moveVolumeSum += volume[idx]

                moveVolumeBars += 1

    float moveAverageVolume = volume

    if moveVolumeBars > 0

        moveAverageVolume :=

             moveVolumeSum /

             moveVolumeBars

    float normalVolume =

         ta.sma(

             volume,

             volumeBaseline)

    float moveRVOL = na

    if normalVolume > 0

        moveRVOL :=

             moveAverageVolume /

             normalVolume

    //-------------------------------------------------------------

    // NORMALIZED VELOCITY

    //-------------------------------------------------------------

    float normalizedVelocity = na

    if hATR > 0

        normalizedVelocity :=

             math.abs(

                 close -

                 close[directionLookback]) /

             hATR /

             directionLookback

    float averageVelocity =

         ta.sma(

             normalizedVelocity,

             velocityBaseline)

    float relativeVelocity = na

    if averageVelocity > 0

        relativeVelocity :=

             normalizedVelocity /

             averageVelocity

    //-------------------------------------------------------------

    // VELOCITY EXPANSION

    //-------------------------------------------------------------

    // Compare current relative velocity with the previous

    // non-overlapping velocity window.

    float previousRelativeVelocity =

         relativeVelocity[directionLookback]

    float currentVelocityExpansion = 0.0

    if not na(relativeVelocity) and

       not na(previousRelativeVelocity)

        currentVelocityExpansion :=

             relativeVelocity -

             previousRelativeVelocity

    //-------------------------------------------------------------

    // PEAK VELOCITY / PEAK VELOCITY EXPANSION

    //-------------------------------------------------------------

    float peakRelativeVelocity = 0.0

    float peakVelocityExpansion = 0.0

    if originBars > 0

        for step = 0 to impulseSearchHours - 1

            int idx = impulseSearchHours - 1 - step

            if idx < originBars

                //---------------------------------------------

                // PEAK VELOCITY

                //---------------------------------------------

                float histVelocity =

                     relativeVelocity[idx]

                if not na(histVelocity)

                    if histVelocity >

                         peakRelativeVelocity

                        peakRelativeVelocity :=

                             histVelocity

                //---------------------------------------------

                // PEAK VELOCITY EXPANSION

                //---------------------------------------------

                float histPreviousVelocity =

                     relativeVelocity[

                         idx +

                         directionLookback]

                if not na(histVelocity) and

                   not na(histPreviousVelocity)

                    float expansion =

                         histVelocity -

                         histPreviousVelocity

                    if expansion >

                         peakVelocityExpansion

                        peakVelocityExpansion :=

                             expansion

    //-------------------------------------------------------------

    // VELOCITY DECAY FROM PEAK

    //-------------------------------------------------------------

    float velocityDecay = 0.0

    if peakRelativeVelocity > 0 and

       not na(relativeVelocity)

        velocityDecay :=

             1.0 -

             relativeVelocity /

             peakRelativeVelocity

    velocityDecay :=

         f_clamp(

             velocityDecay,

             0.0,

             1.0)

    //-------------------------------------------------------------

    // RETURN

    //-------------------------------------------------------------

    [dir, origin, originBars, distance, moveRVOL, relativeVelocity, normalizedVelocity, currentVelocityExpansion, peakRelativeVelocity, peakVelocityExpansion, velocityDecay]

//=====================================================================

// 4H STRUCTURE ENGINE

//=====================================================================

f_fourHourStructure() =>

    float h4ATR =

         ta.atr(

             fourHourATRLength)

    //-------------------------------------------------------------

    // DIRECTION

    //-------------------------------------------------------------

    int dir = 0

    if close >

         close[structureDirectionLookback]

        dir := 1

    else if close <

         close[structureDirectionLookback]

        dir := -1

    //-------------------------------------------------------------

    // ORIGIN

    //-------------------------------------------------------------

    float bullOrigin =

         ta.lowest(

             low,

             structureLookback + 1)

    float bearOrigin =

         ta.highest(

             high,

             structureLookback + 1)

    int bullBars =

         math.abs(

             ta.lowestbars(

                 low,

                 structureLookback + 1))

    int bearBars =

         math.abs(

             ta.highestbars(

                 high,

                 structureLookback + 1))

    float origin = close

    int originBars = 0

    if dir == 1

        origin := bullOrigin

        originBars := bullBars

    else if dir == -1

        origin := bearOrigin

        originBars := bearBars

    //-------------------------------------------------------------

    // EFFICIENCY

    //-------------------------------------------------------------

    float distance =

         math.abs(

             close -

             origin)

    float travel = 0.0

    if originBars > 0

        for step = 0 to structureLookback - 1

            int idx =

                 structureLookback - 1 - step

            if idx < originBars

                travel +=

                     math.abs(

                         close[idx] -

                         close[idx + 1])

    float efficiency = 0.0

    if travel > 0

        efficiency :=

             distance /

             travel

    efficiency :=

         f_clamp(

             efficiency,

             0.0,

             1.0)

    //-------------------------------------------------------------

    // LEG COUNT

    //-------------------------------------------------------------

    int legs = 0

    if dir != 0

        legs := 1

    float extreme = origin

    bool inPullback = false

    if dir != 0 and originBars > 0

        for step = 0 to structureLookback - 1

            int idx =

                 structureLookback - 1 - step

            if idx < originBars

                float localATR =

                     h4ATR[idx]

                //-------------------------------------------------

                // BULLISH

                //-------------------------------------------------

                if dir == 1

                    if not inPullback

                        if high[idx] > extreme

                            extreme := high[idx]

                        float retracement = 0.0

                        if localATR > 0

                            retracement :=

                                 (extreme -

                                  low[idx]) /

                                 localATR

                        if retracement >=

                             structureRetraceATR

                            inPullback := true

                    else

                        if high[idx] >= extreme

                            legs += 1

                            inPullback := false

                            extreme := high[idx]

                //-------------------------------------------------

                // BEARISH

                //-------------------------------------------------

                else if dir == -1

                    if not inPullback

                        if low[idx] < extreme

                            extreme := low[idx]

                        float retracement = 0.0

                        if localATR > 0

                            retracement :=

                                 (high[idx] -

                                  extreme) /

                                 localATR

                        if retracement >=

                             structureRetraceATR

                            inPullback := true

                    else

                        if low[idx] <= extreme

                            legs += 1

                            inPullback := false

                            extreme := low[idx]

    //-------------------------------------------------------------

    // LEG QUALITY

    //-------------------------------------------------------------

    float legQuality = 0.0

    if legs < idealLegMin

        legQuality :=

             f_clamp(

                 legs /

                 idealLegMin,

                 0.0,

                 1.0)

    else if legs <= idealLegMax

        legQuality := 1.0

    else

        float excessLegs =

             legs -

             idealLegMax

        legQuality :=

             1.0 -

             excessLegs *

             0.15

        legQuality :=

             f_clamp(

                 legQuality,

                 0.0,

                 1.0)

    //-------------------------------------------------------------

    // EFFICIENCY QUALITY

    //-------------------------------------------------------------

    float efficiencyQuality = 0.0

    if structureEfficiencyThreshold > 0

        efficiencyQuality :=

             f_clamp(

                 efficiency /

                 structureEfficiencyThreshold,

                 0.0,

                 1.0)

    //-------------------------------------------------------------

    // STRUCTURE QUALITY

    //-------------------------------------------------------------

    float structureQuality =

         legQuality *

         0.40 +

         efficiencyQuality *

         0.60

    structureQuality *= 100.0

    [dir, legs, efficiency, structureQuality]

//=====================================================================

// DAILY DATA

//=====================================================================

float dailyATR =

     request.security(

         syminfo.tickerid,

         "D",

         ta.atr(dailyATRLength),

         lookahead=barmerge.lookahead_off)

float dailyMean =

     request.security(

         syminfo.tickerid,

         "D",

         ta.sma(close, zLength),

         lookahead=barmerge.lookahead_off)

float dailySTD =

     request.security(

         syminfo.tickerid,

         "D",

         ta.stdev(close, zLength),

         lookahead=barmerge.lookahead_off)

float dailyClose =

     request.security(

         syminfo.tickerid,

         "D",

         close,

         lookahead=barmerge.lookahead_off)

float dailyZ = na

if dailySTD > 0

    dailyZ :=

         (dailyClose -

          dailyMean) /

         dailySTD

float absDailyZ =

     math.abs(

         dailyZ)

//---------------------------------------------------------------------

// RANGE REGIME

//---------------------------------------------------------------------

float shortRange =

     request.security(

         syminfo.tickerid,

         "D",

         ta.sma(

             ta.tr(true),

             dailyRangeShort),

         lookahead=barmerge.lookahead_off)

float longRange =

     request.security(

         syminfo.tickerid,

         "D",

         ta.sma(

             ta.tr(true),

             dailyRangeLong),

         lookahead=barmerge.lookahead_off)

float rangeRegime = na

if longRange > 0

    rangeRegime :=

         shortRange /

         longRange

//---------------------------------------------------------------------

// PREVIOUS DAY RVOL

//---------------------------------------------------------------------

float previousDayRVOL =

     request.security(

         syminfo.tickerid,

         "D",

         volume[1] /

         ta.sma(

             volume,

             dailyVolumeLength)[1],

         lookahead=barmerge.lookahead_off)

//---------------------------------------------------------------------

// DAILY DIRECTIONAL STREAK

//---------------------------------------------------------------------

int dailyStreak =

     request.security(

         syminfo.tickerid,

         "D",

         f_dailyStreak(),

         lookahead=barmerge.lookahead_off)

//=====================================================================

// 1H DATA

//=====================================================================

[moveDirection, moveOrigin, moveHours, moveDistance, moveRVOL, relativeVelocity, normalizedVelocity, currentVelocityExpansion, peakRelativeVelocity, peakVelocityExpansion, velocityDecay] = request.security(

     syminfo.tickerid,

     "60",

     f_hourlyMetrics(),

     lookahead=barmerge.lookahead_off)

//=====================================================================

// 4H DATA

//=====================================================================

[ structureDirection, structureLegs, structureEfficiency, structureQuality] = request.security(

     syminfo.tickerid,

     "240",

     f_fourHourStructure(),

     lookahead=barmerge.lookahead_off)

//=====================================================================

// MOVE NORMALIZATION

//=====================================================================

float moveATR = na

if dailyATR > 0

    moveATR :=

         moveDistance /

         dailyATR

float moveDays =

     moveHours /

     24.0

//=====================================================================

// DIRECTION ALIGNMENT

//=====================================================================

int dailyDirection = 0

if dailyStreak > 0

    dailyDirection := 1

else if dailyStreak < 0

    dailyDirection := -1

bool dailyAligned =

     dailyDirection ==

     moveDirection and

     moveDirection != 0

int alignedDays = 0

if dailyAligned

    alignedDays :=

         math.abs(

             dailyStreak)

bool structureAligned =

     structureDirection ==

     moveDirection and

     moveDirection != 0

float alignedStructureQuality =

     structureQuality

if not structureAligned

    alignedStructureQuality :=

         structureQuality *

         0.50

//=====================================================================

// SCORE 1: IN-PLAY

//=====================================================================

float inPlayVelocity =

     f_score(

         relativeVelocity,

         relativeVelocityThreshold,

         35.0)

float inPlayMove =

     f_score(

         moveATR,

         moveATRThreshold,

         30.0)

float inPlayVolume =

     f_score(

         moveRVOL,

         moveRVOLThreshold,

         20.0)

float inPlayRange =

     f_score(

         rangeRegime,

         rangeRegimeThreshold,

         15.0)

float inPlayScore =

     inPlayVelocity +

     inPlayMove +

     inPlayVolume +

     inPlayRange

bool isInPlay =

     inPlayScore >=

     inPlayMinimum

//=====================================================================

// SCORE 2: EXTENSION

//=====================================================================

// Primary extension = 80%

float extensionZ =

     f_score(

         absDailyZ,

         zThreshold,

         40.0)

float extensionATR =

     f_score(

         moveATR,

         hardMoveATRThreshold,

         40.0)

// Secondary maturity = 20%

float extensionPersistence =

     f_score(

         alignedDays,

         directionalDaysThreshold,

         10.0)

float extensionAge =

     f_score(

         moveDays,

         moveAgeThreshold,

         10.0)

float rawExtensionScore =

     extensionZ +

     extensionATR +

     extensionPersistence +

     extensionAge

bool hardExtension =

     absDailyZ >= zThreshold or

     moveATR >= hardMoveATRThreshold

float extensionScore =

     rawExtensionScore

if not hardExtension

    extensionScore :=

         math.min(

             extensionScore,

             49.0)

if freshCatalyst

    extensionScore :=

         math.max(

             0.0,

             extensionScore -

             15.0)

bool isExtended =

     hardExtension and

     extensionScore >=

     extensionMinimum

//=====================================================================

// SCORE 3: IMPULSE HISTORY

//=====================================================================

// Peak velocity = 35%

float impulsePeakVelocity =

     f_score(

         peakRelativeVelocity,

         peakVelocityThreshold,

         35.0)

// Peak velocity expansion = 25%

float impulseExpansion =

     f_score(

         peakVelocityExpansion,

         velocityExpansionThreshold,

         25.0)

// Structure = 25%

float impulseStructure =

     alignedStructureQuality /

     100.0 *

     25.0

// Velocity decay = 15%

float impulseDecay =

     f_score(

         velocityDecay,

         velocityDecayThreshold,

         15.0)

float impulseHistoryScore =

     impulsePeakVelocity +

     impulseExpansion +

     impulseStructure +

     impulseDecay

bool validImpulseHistory =

     impulseHistoryScore >=

     impulseMinimum

//=====================================================================

// FINAL QUALIFICATION

//=====================================================================

bool priorityReversal =

     isInPlay and

     hardExtension and

     extensionScore >= priorityExtensionMinimum and

     impulseHistoryScore >= priorityImpulseMinimum and

     velocityDecay >= velocityDecayThreshold and

     not freshCatalyst

bool reversalWatch =

     not priorityReversal and

     isInPlay and

     hardExtension and

     extensionScore >= extensionMinimum and

     validImpulseHistory and

     not freshCatalyst

bool developing =

     not priorityReversal and

     not reversalWatch and

     isInPlay and

     (

         relativeVelocity >= relativeVelocityThreshold or

         extensionScore >= 45.0

     )

//=====================================================================

// STATUS TEXT

//=====================================================================

string moveDirectionText = switch

    moveDirection == 1 => "BULLISH"

    moveDirection == -1 => "BEARISH"

    => "NEUTRAL"

string reversalDirectionText = switch

    moveDirection == 1 => "Potential SHORT"

    moveDirection == -1 => "Potential LONG"

    => "NONE"

string inPlayStatus = switch

    inPlayScore >= 85 => "VERY ACTIVE"

    isInPlay => "IN PLAY"

    inPlayScore >= 50 => "WATCH"

    => "QUIET"

string extensionStatus = switch

    not hardExtension => "NOT EXTENDED"

    extensionScore >= 85 => "EXTREME"

    extensionScore >= extensionMinimum => "EXTENDED"

    => "DEVELOPING"

string impulseStatus = switch

    impulseHistoryScore >= 75 => "STRONG HISTORY"

    impulseHistoryScore >= impulseMinimum => "VALID HISTORY"

    impulseHistoryScore >= 35 => "WEAK HISTORY"

    => "POOR HISTORY"

string structureStatus = switch

    alignedStructureQuality >= 75 => "CLEAN"

    alignedStructureQuality >= 50 => "MODERATE"

    alignedStructureQuality >= 30 => "MESSY"

    => "CHOPPY"

string finalStatus = switch

    priorityReversal => "PRIORITY REVERSAL"

    reversalWatch => "REVERSAL WATCH"

    developing => "DEVELOPING"

    isInPlay => "IN PLAY"

    => "IGNORE"

//=====================================================================

// COLORS
//=====================================================================

color inPlayColor = switch
    inPlayScore >= 85 => panelPositiveColor
    isInPlay => panelPositiveColor
    inPlayScore >= 50 => panelWarningColor
    => panelMutedTextColor

color extensionColor = switch
    not hardExtension => panelMutedTextColor
    extensionScore >= 85 => panelExtremeColor
    extensionScore >= extensionMinimum => panelWarningColor
    => panelWarningColor

color impulseColor = switch
    impulseHistoryScore >= 75 => panelPositiveColor
    impulseHistoryScore >= impulseMinimum => panelPositiveColor
    impulseHistoryScore >= 35 => panelWarningColor
    => panelMutedTextColor

color finalColor = switch
    priorityReversal => panelExtremeColor
    reversalWatch => panelWarningColor
    developing => panelWarningColor
    isInPlay => panelPositiveColor
    => panelMutedTextColor

color directionColor = switch
    moveDirection == 1 => panelBullishColor
    moveDirection == -1 => panelBearishColor
    => panelMutedTextColor

//=====================================================================

// DISPLAY STRINGS

//=====================================================================

string moveAgeText =

     str.tostring(

         moveDays,

         "#.0") +

     " days"

string moveATRText =

     str.tostring(

         moveATR,

         "#.00") +

     " ATR"

string velocityText =

     str.tostring(

         relativeVelocity,

         "#.00") +

     "x"

string peakVelocityText =

     str.tostring(

         peakRelativeVelocity,

         "#.00") +

     "x"

string currentExpansionText =
     f_signedText(currentVelocityExpansion) +
     "x"

string peakExpansionText =
     f_signedText(peakVelocityExpansion) +
     "x"

string velocityDecayText =

     str.tostring(

         velocityDecay *

         100.0,

         "#.0") +

     "%"

string zText =

     str.tostring(

         dailyZ,

         "#.00") +

     " sigma"

string moveRVOLText =

     str.tostring(

         moveRVOL,

         "#.00") +

     "x"

string rangeText =

     str.tostring(

         rangeRegime,

         "#.00") +

     "x"

string structureEfficiencyText =

     str.tostring(

         structureEfficiency *

         100.0,

         "#.0") +

     "%"

string structureQualityText =

     str.tostring(

         alignedStructureQuality,

         "#.0")

string previousRVOLText =

     str.tostring(

         previousDayRVOL,

         "#.00") +

     "x"

//=====================================================================

// DASHBOARD
//=====================================================================

var table dashboard = table.new(
     f_position(panelPosition),
     3,
     25,
     bgcolor=panelBg,
     frame_color=panelBorder,
     frame_width=1,
     border_color=panelBorder,
     border_width=1)

if barstate.islast
    table.clear(dashboard, 0, 0, 2, 24)

    if showPanel
        //=================================================================
        // COMPACT / MOBILE MODE
        //=================================================================
        if panelMode == "Compact"
            table.cell(dashboard, 0, 0, "REVERSAL", bgcolor=panelHeaderBg, text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 0, syminfo.ticker, bgcolor=panelHeaderBg, text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 0, finalStatus, bgcolor=color.new(finalColor, panelFinalTransparency), text_color=panelHeaderTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 1, "Move", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 1, moveDirectionText, text_color=directionColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 1, reversalDirectionText, text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 2, "In-Play", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 2, str.tostring(inPlayScore, "#.0"), bgcolor=color.new(inPlayColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 2, inPlayStatus, bgcolor=color.new(inPlayColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 3, "Extension", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 3, str.tostring(extensionScore, "#.0"), bgcolor=color.new(extensionColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 3, hardExtension ? zText : "Not Ext.", text_color=hardExtension ? extensionColor : panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 4, "Impulse", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 4, str.tostring(impulseHistoryScore, "#.0"), bgcolor=color.new(impulseColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 4, peakVelocityText, text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 5, "Cooling", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 5, currentExpansionText, text_color=currentVelocityExpansion <= 0 ? panelPositiveColor : panelWarningColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 5, velocityDecayText, text_color=velocityDecay >= velocityDecayThreshold ? panelPositiveColor : panelWarningColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 6, "4H Struct", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 6, structureQualityText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 6, str.tostring(structureLegs) + " legs", text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 7, "FINAL", bgcolor=color.new(finalColor, panelFinalTransparency), text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 7, finalStatus, bgcolor=color.new(finalColor, panelFinalTransparency), text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 7, priorityReversal or reversalWatch ? reversalDirectionText : "WAIT", bgcolor=color.new(finalColor, panelFinalTransparency), text_color=panelHeaderTextColor, text_size=panelTextSize)

        //=================================================================
        // FULL DESKTOP MODE
        //=================================================================
        else
            table.cell(dashboard, 0, 0, "REVERSAL SCANNER V4.1", bgcolor=panelHeaderBg, text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 0, syminfo.ticker, bgcolor=panelHeaderBg, text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 0, "D + 1H + 4H", bgcolor=panelHeaderBg, text_color=panelHeaderTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 1, "ACTIVE MOVE", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 1, moveDirectionText, text_color=directionColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 1, reversalDirectionText, text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 2, "Move Age", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 2, moveAgeText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 2, str.tostring(moveHours) + " hrs", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 3, "Move / Daily ATR", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 3, moveATRText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 3, moveATR >= hardMoveATRThreshold ? "EXTENDED" : "NORMAL", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 4, "IN-PLAY SCORE", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 4, str.tostring(inPlayScore, "#.0"), bgcolor=color.new(inPlayColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 4, inPlayStatus, bgcolor=color.new(inPlayColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 5, "Current Velocity", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 5, velocityText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 5, relativeVelocity >= relativeVelocityThreshold ? "HIGH" : "NORMAL", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 6, "Move RVOL", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 6, moveRVOLText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 6, moveRVOL >= moveRVOLThreshold ? "HIGH" : "NORMAL", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 7, "Range Regime", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 7, rangeText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 7, rangeRegime >= rangeRegimeThreshold ? "EXPANDED" : "NORMAL", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 8, "EXTENSION SCORE", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 8, str.tostring(extensionScore, "#.0"), bgcolor=color.new(extensionColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 8, extensionStatus, bgcolor=color.new(extensionColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 9, "Daily Z-Score", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 9, zText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 9, absDailyZ >= zThreshold ? "HARD EXTENSION" : "NORMAL", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 10, "Directional Days", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 10, str.tostring(math.abs(dailyStreak)), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 10, dailyAligned ? "ALIGNED" : "NOT ALIGNED", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 11, "Hard Extension", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 11, hardExtension ? "YES" : "NO", text_color=hardExtension ? panelPositiveColor : panelMutedTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 11, hardExtension ? "QUALIFIED" : "MAX SCORE 49", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 12, "IMPULSE HISTORY", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 12, str.tostring(impulseHistoryScore, "#.0"), bgcolor=color.new(impulseColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 12, impulseStatus, bgcolor=color.new(impulseColor, panelStatusTransparency), text_color=panelTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 13, "Peak Velocity", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 13, peakVelocityText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 13, peakRelativeVelocity >= peakVelocityThreshold ? "HIGH" : "NORMAL", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 14, "Peak Vel Expansion", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 14, peakExpansionText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 14, peakVelocityExpansion >= velocityExpansionThreshold ? "SURGE" : "NORMAL", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 15, "Current Vel Expansion", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 15, currentExpansionText, text_color=currentVelocityExpansion <= 0 ? panelPositiveColor : panelWarningColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 15, currentVelocityExpansion > 0 ? "EXPANDING" : "COOLING", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 16, "Velocity Decay", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 16, velocityDecayText, text_color=velocityDecay >= velocityDecayThreshold ? panelPositiveColor : panelWarningColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 16, velocityDecay >= velocityDecayThreshold ? "COOLED FROM PEAK" : "STILL HOT", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 17, "4H STRUCTURE", bgcolor=panelSectionBg, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 17, structureQualityText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 17, structureStatus, text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 18, "4H Legs", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 18, str.tostring(structureLegs), text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 18, structureLegs >= idealLegMin and structureLegs <= idealLegMax ? "IDEAL" : structureLegs > idealLegMax ? "TOO MANY" : "EARLY", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 19, "4H Efficiency", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 19, structureEfficiencyText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 19, structureEfficiency >= structureEfficiencyThreshold ? "LOW ACCEPTANCE" : "CHOPPY", text_color=panelMutedTextColor, text_size=panelTextSize)

            string structureDirectionText = switch
                structureDirection == 1 => "BULLISH"
                structureDirection == -1 => "BEARISH"
                => "NEUTRAL"

            table.cell(dashboard, 0, 20, "4H Direction", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 20, structureDirectionText, text_color=structureDirection == 1 ? panelBullishColor : structureDirection == -1 ? panelBearishColor : panelMutedTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 20, structureAligned ? "ALIGNED" : "MISMATCH", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 21, "Fresh Catalyst", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 21, freshCatalyst ? "YES" : "NO", text_color=freshCatalyst ? panelExtremeColor : panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 21, freshCatalyst ? "DO NOT FADE" : "CLEAR", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 22, "Previous Day RVOL", text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 22, previousRVOLText, text_color=panelTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 22, "INFO", text_color=panelMutedTextColor, text_size=panelTextSize)

            table.cell(dashboard, 0, 23, "FINAL STATUS", bgcolor=color.new(finalColor, panelFinalTransparency), text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 1, 23, finalStatus, bgcolor=color.new(finalColor, panelFinalTransparency), text_color=panelHeaderTextColor, text_size=panelTextSize)
            table.cell(dashboard, 2, 23, priorityReversal or reversalWatch ? reversalDirectionText : "WAIT", bgcolor=color.new(finalColor, panelFinalTransparency), text_color=panelHeaderTextColor, text_size=panelTextSize)

            if showPanelFooter
                table.cell(dashboard, 0, 24, "V4.1", text_color=panelMutedTextColor, text_size=panelTextSize)
                table.cell(dashboard, 1, 24, "Scanner != Entry", text_color=panelMutedTextColor, text_size=panelTextSize)
                table.cell(dashboard, 2, 24, "D + 1H + 4H", text_color=panelMutedTextColor, text_size=panelTextSize)

//=====================================================================

// ALERTS

//=====================================================================

bool newInPlay =

     isInPlay and

     not isInPlay[1]

bool newDeveloping =

     developing and

     not developing[1]

bool newReversalWatch =

     reversalWatch and

     not reversalWatch[1]

bool newPriorityReversal =

     priorityReversal and

     not priorityReversal[1]

alertcondition(

     newInPlay,

     "Entered In-Play",

     "Instrument entered In-Play status.")

alertcondition(

     newDeveloping,

     "Developing Reversal",

     "Instrument is developing toward reversal conditions.")

alertcondition(

     newReversalWatch,

     "Reversal Watch",

     "Instrument qualifies for Reversal Watch.")

alertcondition(

     newPriorityReversal,

     "Priority Reversal Watch",

     "Instrument qualifies for PRIORITY Reversal Watch.")
````
