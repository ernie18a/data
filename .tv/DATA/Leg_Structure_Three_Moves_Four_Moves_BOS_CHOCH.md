<!-- tradingview-pine-id: PUB;cdde0dc9c20344379f0e80ac71460dfe -->
<!-- tradingviewscripts-format: 1 -->
# Leg Structure + Three Moves + Four Moves + BOS + CHOCH

Source: https://www.tradingview.com/script/b37PkBUA-Leg-Structure-Three-Moves-Four-Moves-BOS-CHOCH/

## Description

I'm trying to see what works for me.  Following forming patterns for greater success...hopefully.

---

## Source Code

````pine
//@version=6
indicator(
     "Leg Structure + Three Moves + Four Moves + BOS + CHOCH",
     overlay=true,
     max_labels_count=500
)
 
//────────────────────────────────────────────
// GENERAL
//────────────────────────────────────────────
string tz = "America/New_York"
 
//────────────────────────────────────────────
// DISPLAY SETTINGS
//────────────────────────────────────────────
groupDisplay = "Display"
 
bool showFormingSignals = input.bool(
     true,
     "Show Three-Move Forming Circles",
     group=groupDisplay
)
 
bool showFourMoveSignals = input.bool(
     true,
     "Show Purple Four-Move Circles",
     group=groupDisplay
)
 
bool showEmergingSignals = input.bool(
     true,
     "Show Yellow Emerging Diamonds",
     group=groupDisplay
)
 
bool showBOSSignals = input.bool(
     true,
     "Show Confirmed BOS Arrows",
     group=groupDisplay
)
 
bool showCHOCHSignals = input.bool(
     true,
     "Show Orange CHOCH Triangles",
     group=groupDisplay
)
 
bool showEMA = input.bool(
     true,
     "Show EMA",
     group=groupDisplay
)
 
bool showStructureLevels = input.bool(
     false,
     "Show Active Structure Levels",
     group=groupDisplay
)
 
bool waitForClose = input.bool(
     true,
     "Wait for Candle Close",
     group=groupDisplay
)
 
//────────────────────────────────────────────
// DIRECTIONAL LEG SETTINGS
//────────────────────────────────────────────
groupLegs = "Directional Leg Settings"
 
bool useBodyDirection = input.bool(
     true,
     "Use Candle Body Direction for Legs",
     group=groupLegs
)
 
bool dojiExtendsCurrentLeg = input.bool(
     true,
     "Allow Doji to Extend Current Leg",
     group=groupLegs
)
 
float minimumLegATR = input.float(
     0.00,
     "Minimum Completed Leg Range as ATR",
     minval=0.00,
     maxval=3.00,
     step=0.05,
     group=groupLegs
)
 
//────────────────────────────────────────────
// LEG-STRENGTH SETTINGS
//────────────────────────────────────────────
groupStrength = "Leg Strength Settings"
 
bool requireLegStrength = input.bool(
     true,
     "Require Leg-Strength Qualification",
     group=groupStrength
)
 
float maximumPullbackRetracement = input.float(
     0.75,
     "Maximum Pullback as Portion of Impulse",
     minval=0.10,
     maxval=1.50,
     step=0.05,
     group=groupStrength
)
 
float minimumImpulsePullbackRatio = input.float(
     1.25,
     "Minimum Impulse-to-Pullback Ratio",
     minval=0.50,
     maxval=5.00,
     step=0.05,
     group=groupStrength
)
 
float minimumLegEfficiency = input.float(
     0.35,
     "Minimum Impulse Displacement Efficiency",
     minval=0.00,
     maxval=1.00,
     step=0.05,
     group=groupStrength
)
 
float minimumContinuationStrength = input.float(
     0.70,
     "Minimum New Impulse vs Previous Impulse",
     minval=0.10,
     maxval=2.00,
     step=0.05,
     group=groupStrength
)
 
int maximumPullbackBars = input.int(
     8,
     "Maximum Candles in Pullback Leg",
     minval=1,
     maxval=30,
     group=groupStrength
)
 
//────────────────────────────────────────────
// EMA AND ATR FILTERS
//────────────────────────────────────────────
groupFilters = "EMA and ATR Filters"
 
int emaLength = input.int(
     9,
     "EMA Length",
     minval=1,
     group=groupFilters
)
 
int atrLength = input.int(
     14,
     "ATR Length",
     minval=1,
     group=groupFilters
)
 
bool requireFormingEMA = input.bool(
     false,
     "Require EMA for Forming Structure",
     group=groupFilters
)
 
bool requireFourMoveEMA = input.bool(
     false,
     "Require EMA for Four-Move Structure",
     group=groupFilters
)
 
bool requireEmergingEMA = input.bool(
     false,
     "Require EMA for Emerging Structure",
     group=groupFilters
)
 
bool requireBOSEMA = input.bool(
     false,
     "Require EMA for BOS",
     group=groupFilters
)
 
//────────────────────────────────────────────
// EMERGING STRUCTURE SETTINGS
//────────────────────────────────────────────
groupEmerging = "Emerging Structure Settings"
 
float emergingDistanceATR = input.float(
     0.30,
     "Maximum Distance From BOS Level as ATR",
     minval=0.05,
     maxval=2.00,
     step=0.05,
     group=groupEmerging
)
 
bool requireEmergingDirectionalCandle = input.bool(
     true,
     "Require Directional Emerging Candle",
     group=groupEmerging
)
 
//────────────────────────────────────────────
// BOS SETTINGS
//────────────────────────────────────────────
groupBOS = "BOS Confirmation Settings"
 
int confirmationWindowBars = input.int(
     8,
     "Maximum Bars After Four-Move Signal",
     minval=1,
     maxval=50,
     group=groupBOS
)
 
float minimumBreakoutBodyATR = input.float(
     0.35,
     "Minimum Breakout Body as ATR",
     minval=0.05,
     maxval=2.00,
     step=0.05,
     group=groupBOS
)
 
float minimumClosePosition = input.float(
     0.65,
     "Strong Close Threshold",
     minval=0.50,
     maxval=0.95,
     step=0.05,
     group=groupBOS
)
 
bool requireMomentumExpansion = input.bool(
     true,
     "Require Breakout Momentum Expansion",
     group=groupBOS
)
 
//────────────────────────────────────────────
// CHOCH SETTINGS
//────────────────────────────────────────────
groupCHOCH = "Potential Reversal Settings"
 
bool requireCHOCHClose = input.bool(
     true,
     "Require Close Through Protected Level",
     group=groupCHOCH
)
 
float minimumCHOCHBodyATR = input.float(
     0.20,
     "Minimum CHOCH Body as ATR",
     minval=0.00,
     maxval=2.00,
     step=0.05,
     group=groupCHOCH
)
 
//────────────────────────────────────────────
// SIGNAL WINDOW
//────────────────────────────────────────────
bool inSignalWindow =
     not na(time(timeframe.period, "1000-1230", tz))
 
bool newSignalWindow =
     inSignalWindow and
     not inSignalWindow[1]
 
bool signalWindowEnded =
     not inSignalWindow and
     inSignalWindow[1]
 
bool confirmedBar =
     not waitForClose or
     barstate.isconfirmed
 
bool newDay =
     ta.change(time("D")) != 0
 
//────────────────────────────────────────────
// CANDLE AND INDICATOR VALUES
//────────────────────────────────────────────
float candleRange =
     math.max(high - low, syminfo.mintick)
 
float bodySize =
     math.abs(close - open)
 
float previousBodySize =
     math.abs(close[1] - open[1])
 
bool bullishBody =
     close > open
 
bool bearishBody =
     close < open
 
float bullishClosePosition =
     (close - low) / candleRange
 
float bearishClosePosition =
     (high - close) / candleRange
 
float emaValue =
     ta.ema(close, emaLength)
 
float atrValue =
     ta.atr(atrLength)
 
bool bullishEMA =
     close >= emaValue and
     emaValue >= emaValue[1]
 
bool bearishEMA =
     close <= emaValue and
     emaValue <= emaValue[1]
 
//────────────────────────────────────────────
// CANDLE DIRECTION
//────────────────────────────────────────────
int candleDirection =
     useBodyDirection ?
     (
         close > open ? 1 :
         close < open ? -1 :
         0
     ) :
     (
         close > close[1] ? 1 :
         close < close[1] ? -1 :
         0
     )
 
//────────────────────────────────────────────
// CURRENT ACTIVE LEG
//────────────────────────────────────────────
var int currentLegDirection = 0
var float currentLegHigh = na
var float currentLegLow = na
var float currentLegOpen = na
var float currentLegClose = na
var int currentLegStartBar = na
var int currentLegEndBar = na
 
//────────────────────────────────────────────
// COMPLETED LEG HISTORY
//────────────────────────────────────────────
var int legDirection1 = 0
var int legDirection2 = 0
var int legDirection3 = 0
var int legDirection4 = 0
 
var float legHigh1 = na
var float legHigh2 = na
var float legHigh3 = na
var float legHigh4 = na
 
var float legLow1 = na
var float legLow2 = na
var float legLow3 = na
var float legLow4 = na
 
var float legRange1 = na
var float legRange2 = na
var float legRange3 = na
var float legRange4 = na
 
var float legDisplacement1 = na
var float legDisplacement2 = na
var float legDisplacement3 = na
var float legDisplacement4 = na
 
var float legEfficiency1 = na
var float legEfficiency2 = na
var float legEfficiency3 = na
var float legEfficiency4 = na
 
var int legBars1 = na
var int legBars2 = na
var int legBars3 = na
var int legBars4 = na
 
//────────────────────────────────────────────
// STRUCTURE STATE
//────────────────────────────────────────────
var int structureBias = 0
var bool bullSetupActive = false
var bool bearSetupActive = false
var int bullSetupBar = na
var int bearSetupBar = na
var float bullBOSLevel = na
var float bearBOSLevel = na
var float protectedBullLow = na
var float protectedBearHigh = na
var bool bullEmergingTriggered = false
var bool bearEmergingTriggered = false

// Four-move patterns arm first. The purple marker prints only on
// the first candle moving in the direction of the confirming leg.
var bool bullishFourMoveArmed = false
var bool bearishFourMoveArmed = false
var float pendingBullBOSLevel = na
var float pendingBearBOSLevel = na
var float pendingProtectedBullLow = na
var float pendingProtectedBearHigh = na
 
//────────────────────────────────────────────
// ONE-BAR SIGNAL FLAGS
//────────────────────────────────────────────
bool bullishFormingSignal = false
bool bearishFormingSignal = false
bool bullishFourMoveSignal = false
bool bearishFourMoveSignal = false
bool bullishEmergingSignal = false
bool bearishEmergingSignal = false
bool bullishBOSSignal = false
bool bearishBOSSignal = false
bool bullishCHOCHSignal = false
bool bearishCHOCHSignal = false
 
safeRatio(float numerator, float denominator) =>
    not na(numerator) and
     not na(denominator) and
     denominator > 0 ?
     numerator / denominator :
     na
 
//────────────────────────────────────────────
// RESET
//────────────────────────────────────────────
if newDay or newSignalWindow
    currentLegDirection := 0
    currentLegHigh := na
    currentLegLow := na
    currentLegOpen := na
    currentLegClose := na
    currentLegStartBar := na
    currentLegEndBar := na
 
    legDirection1 := 0
    legDirection2 := 0
    legDirection3 := 0
    legDirection4 := 0
 
    legHigh1 := na
    legHigh2 := na
    legHigh3 := na
    legHigh4 := na
    legLow1 := na
    legLow2 := na
    legLow3 := na
    legLow4 := na
 
    legRange1 := na
    legRange2 := na
    legRange3 := na
    legRange4 := na
 
    legDisplacement1 := na
    legDisplacement2 := na
    legDisplacement3 := na
    legDisplacement4 := na
 
    legEfficiency1 := na
    legEfficiency2 := na
    legEfficiency3 := na
    legEfficiency4 := na
 
    legBars1 := na
    legBars2 := na
    legBars3 := na
    legBars4 := na
 
    structureBias := 0
    bullSetupActive := false
    bearSetupActive := false
    bullSetupBar := na
    bearSetupBar := na
    bullBOSLevel := na
    bearBOSLevel := na
    protectedBullLow := na
    protectedBearHigh := na
    bullEmergingTriggered := false
    bearEmergingTriggered := false
    bullishFourMoveArmed := false
    bearishFourMoveArmed := false
    pendingBullBOSLevel := na
    pendingBearBOSLevel := na
    pendingProtectedBullLow := na
    pendingProtectedBearHigh := na
 
//────────────────────────────────────────────
// LEG BUILDING AND LEG COMPLETION
//────────────────────────────────────────────
if confirmedBar and inSignalWindow
    if currentLegDirection == 0
        if candleDirection != 0
            currentLegDirection := candleDirection
            currentLegHigh := high
            currentLegLow := low
            currentLegOpen := open
            currentLegClose := close
            currentLegStartBar := bar_index
            currentLegEndBar := bar_index
 
    else if candleDirection == currentLegDirection
        currentLegHigh := math.max(currentLegHigh, high)
        currentLegLow := math.min(currentLegLow, low)
        currentLegClose := close
        currentLegEndBar := bar_index
 
    else if candleDirection == 0 and dojiExtendsCurrentLeg
        currentLegHigh := math.max(currentLegHigh, high)
        currentLegLow := math.min(currentLegLow, low)
        currentLegClose := close
        currentLegEndBar := bar_index
 
    else if candleDirection != 0 and candleDirection != currentLegDirection
        float completedRange = currentLegHigh - currentLegLow
        float rawDisplacement =
             currentLegDirection == 1 ?
             currentLegClose - currentLegOpen :
             currentLegOpen - currentLegClose
        float completedDisplacement = math.max(rawDisplacement, 0.0)
        float completedEfficiency =
             completedRange > 0 ?
             completedDisplacement / completedRange :
             0.0
        int completedBars = currentLegEndBar - currentLegStartBar + 1
        bool completedLegQualified =
             minimumLegATR <= 0 or
             completedRange >= atrValue * minimumLegATR
 
        if completedLegQualified
            legDirection4 := legDirection3
            legDirection3 := legDirection2
            legDirection2 := legDirection1
            legDirection1 := currentLegDirection
 
            legHigh4 := legHigh3
            legHigh3 := legHigh2
            legHigh2 := legHigh1
            legHigh1 := currentLegHigh
 
            legLow4 := legLow3
            legLow3 := legLow2
            legLow2 := legLow1
            legLow1 := currentLegLow
 
            legRange4 := legRange3
            legRange3 := legRange2
            legRange2 := legRange1
            legRange1 := completedRange
 
            legDisplacement4 := legDisplacement3
            legDisplacement3 := legDisplacement2
            legDisplacement2 := legDisplacement1
            legDisplacement1 := completedDisplacement
 
            legEfficiency4 := legEfficiency3
            legEfficiency3 := legEfficiency2
            legEfficiency2 := legEfficiency1
            legEfficiency1 := completedEfficiency
 
            legBars4 := legBars3
            legBars3 := legBars2
            legBars2 := legBars1
            legBars1 := completedBars
 
            // THREE-MOVE FORMING STRUCTURE
            // Bullish sequence: prior HH, held HL, then the first bullish
            // candle of the third structural advance exceeds the prior HH.
            // Bearish sequence: prior LL, held LH, then the first bearish
            // candle of the third structural decline breaks the prior LL.
            bool bullishThreeMoveBase =
                 legDirection4 == 1 and
                 legDirection3 == -1 and
                 legDirection2 == 1 and
                 legDirection1 == -1 and
                 not na(legHigh4) and
                 not na(legHigh2) and
                 not na(legLow3) and
                 not na(legLow1) and
                 legHigh2 > legHigh4 and
                 legLow1 > legLow3

            bool bearishThreeMoveBase =
                 legDirection4 == -1 and
                 legDirection3 == 1 and
                 legDirection2 == -1 and
                 legDirection1 == 1 and
                 not na(legLow4) and
                 not na(legLow2) and
                 not na(legHigh3) and
                 not na(legHigh1) and
                 legLow2 < legLow4 and
                 legHigh1 < legHigh3

            float bullishPullbackRetracement =
                 bullishThreeMoveBase ? safeRatio(legRange1, legRange2) : na
            float bearishPullbackRetracement =
                 bearishThreeMoveBase ? safeRatio(legRange1, legRange2) : na
            float bullishImpulsePullbackRatio =
                 bullishThreeMoveBase ? safeRatio(legRange2, legRange1) : na
            float bearishImpulsePullbackRatio =
                 bearishThreeMoveBase ? safeRatio(legRange2, legRange1) : na
            float bullishContinuationRatio =
                 bullishThreeMoveBase ? safeRatio(legRange2, legRange4) : na
            float bearishContinuationRatio =
                 bearishThreeMoveBase ? safeRatio(legRange2, legRange4) : na

            bool bullishFormingStrengthQualified =
                 not requireLegStrength or
                 (
                     not na(bullishPullbackRetracement) and
                     not na(bullishImpulsePullbackRatio) and
                     not na(bullishContinuationRatio) and
                     bullishPullbackRetracement <= maximumPullbackRetracement and
                     bullishImpulsePullbackRatio >= minimumImpulsePullbackRatio and
                     bullishContinuationRatio >= minimumContinuationStrength and
                     legEfficiency2 >= minimumLegEfficiency and
                     legBars1 <= maximumPullbackBars
                 )

            bool bearishFormingStrengthQualified =
                 not requireLegStrength or
                 (
                     not na(bearishPullbackRetracement) and
                     not na(bearishImpulsePullbackRatio) and
                     not na(bearishContinuationRatio) and
                     bearishPullbackRetracement <= maximumPullbackRetracement and
                     bearishImpulsePullbackRatio >= minimumImpulsePullbackRatio and
                     bearishContinuationRatio >= minimumContinuationStrength and
                     legEfficiency2 >= minimumLegEfficiency and
                     legBars1 <= maximumPullbackBars
                 )

            bool bullishFormingEMAQualified =
                 not requireFormingEMA or bullishEMA
            bool bearishFormingEMAQualified =
                 not requireFormingEMA or bearishEMA

            bool bullishThirdMoveAdvance =
                 candleDirection == 1 and
                 not na(legHigh2) and
                 high > legHigh2

            bool bearishThirdMoveAdvance =
                 candleDirection == -1 and
                 not na(legLow2) and
                 low < legLow2

            bullishFormingSignal :=
                 bullishThreeMoveBase and
                 bullishThirdMoveAdvance and
                 bullishFormingStrengthQualified and
                 bullishFormingEMAQualified

            bearishFormingSignal :=
                 bearishThreeMoveBase and
                 bearishThirdMoveAdvance and
                 bearishFormingStrengthQualified and
                 bearishFormingEMAQualified
            bool patternBullBearBullBear =
                 legDirection4 == 1 and
                 legDirection3 == -1 and
                 legDirection2 == 1 and
                 legDirection1 == -1
 
            bool patternBearBullBearBull =
                 legDirection4 == -1 and
                 legDirection3 == 1 and
                 legDirection2 == -1 and
                 legDirection1 == 1
 
            bool bullishPatternA =
                 patternBullBearBullBear and
                 legHigh2 > legHigh4 and
                 legLow1 > legLow3
 
            bool bullishPatternB =
                 patternBearBullBearBull and
                 legHigh1 > legHigh3 and
                 legLow2 > legLow4
 
            bool bearishPatternA =
                 patternBullBearBullBear and
                 legHigh2 < legHigh4 and
                 legLow1 < legLow3
 
            bool bearishPatternB =
                 patternBearBullBearBull and
                 legHigh1 < legHigh3 and
                 legLow2 < legLow4
 
            float bullOldPullbackRatioA = safeRatio(legRange3, legRange4)
            float bullNewPullbackRatioA = safeRatio(legRange1, legRange2)
            float bullNewImpulsePullbackRatioA = safeRatio(legRange2, legRange1)
            float bullContinuationRatioA = safeRatio(legRange2, legRange4)
 
            bool bullishStrengthA =
                 not requireLegStrength or
                 (
                     not na(bullOldPullbackRatioA) and
                     not na(bullNewPullbackRatioA) and
                     not na(bullNewImpulsePullbackRatioA) and
                     not na(bullContinuationRatioA) and
                     bullOldPullbackRatioA <= maximumPullbackRetracement and
                     bullNewPullbackRatioA <= maximumPullbackRetracement and
                     bullNewImpulsePullbackRatioA >= minimumImpulsePullbackRatio and
                     bullContinuationRatioA >= minimumContinuationStrength and
                     legEfficiency2 >= minimumLegEfficiency and
                     legBars1 <= maximumPullbackBars
                 )
 
            float bullPullbackRatioB = safeRatio(legRange2, legRange3)
            float bullContinuationRatioB = safeRatio(legRange1, legRange3)
 
            bool bullishStrengthB =
                 not requireLegStrength or
                 (
                     not na(bullPullbackRatioB) and
                     not na(bullContinuationRatioB) and
                     bullPullbackRatioB <= maximumPullbackRetracement and
                     bullContinuationRatioB >= minimumContinuationStrength and
                     legEfficiency1 >= minimumLegEfficiency and
                     legBars2 <= maximumPullbackBars
                 )
 
            float bearBounceRatioA = safeRatio(legRange2, legRange3)
            float bearContinuationRatioA = safeRatio(legRange1, legRange3)
 
            bool bearishStrengthA =
                 not requireLegStrength or
                 (
                     not na(bearBounceRatioA) and
                     not na(bearContinuationRatioA) and
                     bearBounceRatioA <= maximumPullbackRetracement and
                     bearContinuationRatioA >= minimumContinuationStrength and
                     legEfficiency1 >= minimumLegEfficiency and
                     legBars2 <= maximumPullbackBars
                 )
 
            float bearOldBounceRatioB = safeRatio(legRange3, legRange4)
            float bearNewBounceRatioB = safeRatio(legRange1, legRange2)
            float bearNewImpulseBounceRatioB = safeRatio(legRange2, legRange1)
            float bearContinuationRatioB = safeRatio(legRange2, legRange4)
 
            bool bearishStrengthB =
                 not requireLegStrength or
                 (
                     not na(bearOldBounceRatioB) and
                     not na(bearNewBounceRatioB) and
                     not na(bearNewImpulseBounceRatioB) and
                     not na(bearContinuationRatioB) and
                     bearOldBounceRatioB <= maximumPullbackRetracement and
                     bearNewBounceRatioB <= maximumPullbackRetracement and
                     bearNewImpulseBounceRatioB >= minimumImpulsePullbackRatio and
                     bearContinuationRatioB >= minimumContinuationStrength and
                     legEfficiency2 >= minimumLegEfficiency and
                     legBars1 <= maximumPullbackBars
                 )
 
            bool bullishFourMoveEMAQualified =
                 not requireFourMoveEMA or bullishEMA
            bool bearishFourMoveEMAQualified =
                 not requireFourMoveEMA or bearishEMA
 
            bool bullishFourMoveQualified =
                 (
                     (bullishPatternA and bullishStrengthA) or
                     (bullishPatternB and bullishStrengthB)
                 )

            bool bearishFourMoveQualified =
                 (
                     (bearishPatternA and bearishStrengthA) or
                     (bearishPatternB and bearishStrengthB)
                 )

            // Completing the fourth structural move arms the setup.
            // It does not print the purple marker on the completed leg.
            if bullishFourMoveQualified
                bullishFourMoveArmed := true
                bearishFourMoveArmed := false

                if bullishPatternA
                    pendingBullBOSLevel := legHigh2
                    pendingProtectedBullLow := legLow1
                else
                    pendingBullBOSLevel := legHigh1
                    pendingProtectedBullLow := legLow2

                pendingBearBOSLevel := na
                pendingProtectedBearHigh := na

            if bearishFourMoveQualified
                bearishFourMoveArmed := true
                bullishFourMoveArmed := false

                if bearishPatternA
                    pendingBearBOSLevel := legLow1
                    pendingProtectedBearHigh := legHigh2
                else
                    pendingBearBOSLevel := legLow2
                    pendingProtectedBearHigh := legHigh1

                pendingBullBOSLevel := na
                pendingProtectedBullLow := na

            // Purple confirmation is reserved for the first candle of
            // the confirming leg: bullish for HH/HL, bearish for LH/LL.
            bullishFourMoveSignal :=
                 bullishFourMoveArmed and
                 candleDirection == 1 and
                 bullishFourMoveEMAQualified

            bearishFourMoveSignal :=
                 bearishFourMoveArmed and
                 candleDirection == -1 and
                 bearishFourMoveEMAQualified

            if bullishFourMoveSignal
                structureBias := 1
                bullSetupActive := true
                bullSetupBar := bar_index
                bullBOSLevel := pendingBullBOSLevel
                protectedBullLow := pendingProtectedBullLow
                bullEmergingTriggered := false

                bearSetupActive := false
                bearSetupBar := na
                bearBOSLevel := na
                protectedBearHigh := na
                bearEmergingTriggered := false

                bullishFourMoveArmed := false
                bearishFourMoveArmed := false
                pendingBullBOSLevel := na
                pendingProtectedBullLow := na
                pendingBearBOSLevel := na
                pendingProtectedBearHigh := na

            if bearishFourMoveSignal
                structureBias := -1
                bearSetupActive := true
                bearSetupBar := bar_index
                bearBOSLevel := pendingBearBOSLevel
                protectedBearHigh := pendingProtectedBearHigh
                bearEmergingTriggered := false

                bullSetupActive := false
                bullSetupBar := na
                bullBOSLevel := na
                protectedBullLow := na
                bullEmergingTriggered := false

                bearishFourMoveArmed := false
                bullishFourMoveArmed := false
                pendingBearBOSLevel := na
                pendingProtectedBearHigh := na
                pendingBullBOSLevel := na
                pendingProtectedBullLow := na

        currentLegDirection := candleDirection
        currentLegHigh := high
        currentLegLow := low
        currentLegOpen := open
        currentLegClose := close
        currentLegStartBar := bar_index
        currentLegEndBar := bar_index
 
int barsAfterBullSetup =
     bullSetupActive and not na(bullSetupBar) ?
     bar_index - bullSetupBar : na
 
int barsAfterBearSetup =
     bearSetupActive and not na(bearSetupBar) ?
     bar_index - bearSetupBar : na
 
bool bullSetupExpired =
     bullSetupActive and
     not na(barsAfterBullSetup) and
     barsAfterBullSetup > confirmationWindowBars
 
bool bearSetupExpired =
     bearSetupActive and
     not na(barsAfterBearSetup) and
     barsAfterBearSetup > confirmationWindowBars
 
if bullSetupExpired
    bullSetupActive := false
    bullSetupBar := na
    bullBOSLevel := na
    bullEmergingTriggered := false
 
if bearSetupExpired
    bearSetupActive := false
    bearSetupBar := na
    bearBOSLevel := na
    bearEmergingTriggered := false
 
float bullishDistanceToBOS =
     not na(bullBOSLevel) ? bullBOSLevel - close : na
 
float bearishDistanceToBOS =
     not na(bearBOSLevel) ? close - bearBOSLevel : na
 
bool bullishNearBOS =
     not na(bullishDistanceToBOS) and
     close <= bullBOSLevel and
     bullishDistanceToBOS >= 0 and
     bullishDistanceToBOS <= atrValue * emergingDistanceATR
 
bool bearishNearBOS =
     not na(bearishDistanceToBOS) and
     close >= bearBOSLevel and
     bearishDistanceToBOS >= 0 and
     bearishDistanceToBOS <= atrValue * emergingDistanceATR
 
bool bullishEmergingEMAQualified =
     not requireEmergingEMA or bullishEMA
 
bool bearishEmergingEMAQualified =
     not requireEmergingEMA or bearishEMA
 
bool bullishEmergingCandleQualified =
     not requireEmergingDirectionalCandle or bullishBody
 
bool bearishEmergingCandleQualified =
     not requireEmergingDirectionalCandle or bearishBody
 
bullishEmergingSignal :=
     confirmedBar and
     inSignalWindow and
     bullSetupActive and
     not bullEmergingTriggered and
     bullishNearBOS and
     bullishEmergingEMAQualified and
     bullishEmergingCandleQualified
 
bearishEmergingSignal :=
     confirmedBar and
     inSignalWindow and
     bearSetupActive and
     not bearEmergingTriggered and
     bearishNearBOS and
     bearishEmergingEMAQualified and
     bearishEmergingCandleQualified
 
if bullishEmergingSignal
    bullEmergingTriggered := true
 
if bearishEmergingSignal
    bearEmergingTriggered := true
 
bool breakoutBodyQualified =
     bodySize >= atrValue * minimumBreakoutBodyATR
 
bool bullishMomentumQualified =
     not requireMomentumExpansion or
     (
         bullishBody and
         bodySize > previousBodySize and
         breakoutBodyQualified
     )
 
bool bearishMomentumQualified =
     not requireMomentumExpansion or
     (
         bearishBody and
         bodySize > previousBodySize and
         breakoutBodyQualified
     )
 
bool bullishBOSEMAQualified =
     not requireBOSEMA or bullishEMA
 
bool bearishBOSEMAQualified =
     not requireBOSEMA or bearishEMA
 
bullishBOSSignal :=
     confirmedBar and
     inSignalWindow and
     bullSetupActive and
     not na(bullBOSLevel) and
     bullishBody and
     close > bullBOSLevel and
     bullishClosePosition >= minimumClosePosition and
     bullishMomentumQualified and
     bullishBOSEMAQualified
 
bearishBOSSignal :=
     confirmedBar and
     inSignalWindow and
     bearSetupActive and
     not na(bearBOSLevel) and
     bearishBody and
     close < bearBOSLevel and
     bearishClosePosition >= minimumClosePosition and
     bearishMomentumQualified and
     bearishBOSEMAQualified
 
if bullishBOSSignal
    bullSetupActive := false
    bullSetupBar := na
    bullBOSLevel := na
    bullEmergingTriggered := false
 
if bearishBOSSignal
    bearSetupActive := false
    bearSetupBar := na
    bearBOSLevel := na
    bearEmergingTriggered := false
 
bool CHOCHBodyQualified =
     bodySize >= atrValue * minimumCHOCHBodyATR
 
bool bearishProtectedLevelBroken =
     structureBias == 1 and
     not na(protectedBullLow) and
     (
         requireCHOCHClose ?
         close < protectedBullLow :
         low < protectedBullLow
     )
 
bool bullishProtectedLevelBroken =
     structureBias == -1 and
     not na(protectedBearHigh) and
     (
         requireCHOCHClose ?
         close > protectedBearHigh :
         high > protectedBearHigh
     )
 
bearishCHOCHSignal :=
     confirmedBar and
     inSignalWindow and
     bearishProtectedLevelBroken and
     CHOCHBodyQualified
 
bullishCHOCHSignal :=
     confirmedBar and
     inSignalWindow and
     bullishProtectedLevelBroken and
     CHOCHBodyQualified
 
if bearishCHOCHSignal
    structureBias := 0
    bullSetupActive := false
    bullSetupBar := na
    bullBOSLevel := na
    protectedBullLow := na
    bullEmergingTriggered := false
 
if bullishCHOCHSignal
    structureBias := 0
    bearSetupActive := false
    bearSetupBar := na
    bearBOSLevel := na
    protectedBearHigh := na
    bearEmergingTriggered := false
 
if signalWindowEnded
    currentLegDirection := 0
    currentLegHigh := na
    currentLegLow := na
    currentLegOpen := na
    currentLegClose := na
    currentLegStartBar := na
    currentLegEndBar := na
    bullSetupActive := false
    bearSetupActive := false
    bullSetupBar := na
    bearSetupBar := na
    bullBOSLevel := na
    bearBOSLevel := na
    bullEmergingTriggered := false
    bearEmergingTriggered := false
    bullishFourMoveArmed := false
    bearishFourMoveArmed := false
    pendingBullBOSLevel := na
    pendingBearBOSLevel := na
    pendingProtectedBullLow := na
    pendingProtectedBearHigh := na
 
plot(
     showEMA ? emaValue : na,
     title="EMA",
     color=color.orange,
     linewidth=2
)
 
plot(
     showStructureLevels and structureBias == 1 ?
     protectedBullLow : na,
     title="Protected Bullish Low",
     color=color.new(color.red, 20),
     linewidth=1,
     style=plot.style_linebr
)
 
plot(
     showStructureLevels and structureBias == -1 ?
     protectedBearHigh : na,
     title="Protected Bearish High",
     color=color.new(color.green, 20),
     linewidth=1,
     style=plot.style_linebr
)
 
plot(
     showStructureLevels and bullSetupActive ?
     bullBOSLevel : na,
     title="Bullish BOS Level",
     color=color.new(color.lime, 20),
     linewidth=1,
     style=plot.style_linebr
)
 
plot(
     showStructureLevels and bearSetupActive ?
     bearBOSLevel : na,
     title="Bearish BOS Level",
     color=color.new(color.red, 20),
     linewidth=1,
     style=plot.style_linebr
)
 
plotshape(
     showFormingSignals and bullishFormingSignal,
     title="Bullish Three-Move Structure Forming",
     style=shape.circle,
     location=location.belowbar,
     size=size.small,
     color=color.blue,
     text="F",
     textcolor=color.white
)
 
plotshape(
     showFormingSignals and bearishFormingSignal,
     title="Bearish Three-Move Structure Forming",
     style=shape.circle,
     location=location.abovebar,
     size=size.small,
     color=color.blue,
     text="F",
     textcolor=color.white
)
 
plotshape(
     showFourMoveSignals and bullishFourMoveSignal,
     title="Bullish Four Structural Moves",
     style=shape.circle,
     location=location.belowbar,
     size=size.small,
     color=color.purple,
     text="4M",
     textcolor=color.white
)
 
plotshape(
     showFourMoveSignals and bearishFourMoveSignal,
     title="Bearish Four Structural Moves",
     style=shape.circle,
     location=location.abovebar,
     size=size.small,
     color=color.purple,
     text="4M",
     textcolor=color.white
)
 
plotshape(
     showEmergingSignals and bullishEmergingSignal,
     title="Bullish Emerging Structure",
     style=shape.diamond,
     location=location.belowbar,
     size=size.small,
     color=color.yellow,
     text="E",
     textcolor=color.black
)
 
plotshape(
     showEmergingSignals and bearishEmergingSignal,
     title="Bearish Emerging Structure",
     style=shape.diamond,
     location=location.abovebar,
     size=size.small,
     color=color.yellow,
     text="E",
     textcolor=color.black
)
 
plotshape(
     showBOSSignals and bullishBOSSignal,
     title="Bullish BOS Confirmed",
     style=shape.arrowup,
     location=location.belowbar,
     size=size.normal,
     color=color.lime,
     text="BOS",
     textcolor=color.black
)
 
plotshape(
     showBOSSignals and bearishBOSSignal,
     title="Bearish BOS Confirmed",
     style=shape.arrowdown,
     location=location.abovebar,
     size=size.normal,
     color=color.red,
     text="BOS",
     textcolor=color.white
)
 
plotshape(
     showCHOCHSignals and bullishCHOCHSignal,
     title="Potential Bullish Reversal CHOCH",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,
     color=color.orange,
     text="CHOCH",
     textcolor=color.black
)
 
plotshape(
     showCHOCHSignals and bearishCHOCHSignal,
     title="Potential Bearish Reversal CHOCH",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     color=color.orange,
     text="CHOCH",
     textcolor=color.black
)
 
alertcondition(
     bullishFormingSignal,
     title="Bullish Three-Move Forming Structure",
     message="Bullish three-move forming structure confirmed on {{ticker}} at {{close}} on {{interval}}."
)
 
alertcondition(
     bearishFormingSignal,
     title="Bearish Three-Move Forming Structure",
     message="Bearish three-move forming structure confirmed on {{ticker}} at {{close}} on {{interval}}."
)
 
alertcondition(
     bullishFourMoveSignal,
     title="Bullish Four Structural Moves",
     message="Bullish four-move structure confirmed on the first bullish candle of the confirming leg for {{ticker}}."
)
 
alertcondition(
     bearishFourMoveSignal,
     title="Bearish Four Structural Moves",
     message="Bearish four-move structure confirmed on the first bearish candle of the confirming leg for {{ticker}}."
)
 
alertcondition(
     bullishEmergingSignal,
     title="Bullish Emerging Structure",
     message="Bullish structure is approaching its BOS level on {{ticker}}."
)
 
alertcondition(
     bearishEmergingSignal,
     title="Bearish Emerging Structure",
     message="Bearish structure is approaching its BOS level on {{ticker}}."
)
 
alertcondition(
     bullishBOSSignal,
     title="Bullish BOS Confirmed",
     message="Bullish break of structure confirmed on {{ticker}} at {{close}}."
)
 
alertcondition(
     bearishBOSSignal,
     title="Bearish BOS Confirmed",
     message="Bearish break of structure confirmed on {{ticker}} at {{close}}."
)
 
alertcondition(
     bullishCHOCHSignal,
     title="Potential Bullish Reversal CHOCH",
     message="Potential bullish reversal or CHOCH confirmed on {{ticker}}."
)
 
alertcondition(
     bearishCHOCHSignal,
     title="Potential Bearish Reversal CHOCH",
     message="Potential bearish reversal or CHOCH confirmed on {{ticker}}."
)



alertcondition(
     bullishCHOCHSignal or bearishCHOCHSignal,
     title="Any Change of Character",
     message="Change of Character confirmed on {{ticker}} at {{close}} on {{interval}}."
)
````
