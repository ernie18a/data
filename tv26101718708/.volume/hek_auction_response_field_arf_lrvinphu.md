# HEK Auction Response Field [ARF]

- url: https://www.tradingview.com/script/LRViNPHu-HEK-Auction-Response-Field-ARF/
- type: indicator
- pine_id: PUB;ccd333946b3f47ae89041b96196fab7b
- version: 1.0

## Description

HEK Auction Response Field [ARF]

Auction Response Field (ARF) is a stateful market-structure indicator designed to describe how price is responding to market effort, rather than predict the next candle.

ARF combines three ideas into one coherent framework:

Response Field — a continuous directional measure of realized price response relative to normalized market effort.

Persistent auction regimes — a confirmed-bar state engine classifying the market as Balance, Bull Drive, Bear Drive, Bull Absorption, Bear Absorption, Churn or Transition.

Orthogonal modifiers — contextual labels such as Vacuum-like displacement, Effort-Supported behavior and Low Efficiency. Modifiers add context without replacing the primary regime.

What makes ARF different?

Many indicators classify price using a single threshold or a collection of independent signals. ARF instead treats market behavior as a state-ownership problem.

A new active regime must earn ownership through evidence and separation. Existing regimes use asymmetric persistence rules to avoid one-bar state flicker. Balance has its own entry, hold and escape behavior. Bull and Bear Drive states also use a two-confirmed-bar Semantic Field Guard: if realized Response Field becomes directionally incompatible with the current Drive state for two confirmed bars, Drive ownership is released.

This architecture is intended to separate:

direction from effort,

state from modifier,

live response from confirmed regime ownership,

visual presentation from the validated state engine.

Primary regimes

Bull Drive
Directional upside response is efficiently controlling the auction.

Bear Drive
Directional downside response is efficiently controlling the auction.

Bull Absorption
Selling pressure is present, but the auction is responding with relative bullish resilience.

Bear Absorption
Buying effort is present, but upside response is being absorbed.

Balance
No active directional regime has sufficient evidence to own the auction and balanced behavior is persistent.

Churn
Effort is elevated relative to realized directional progress, indicating contested or inefficient auction behavior.

Transition
No primary state currently has enough ownership evidence. Transition is intentionally valid information, not a missing signal.

Response Field

The center panel is the continuous Response Field.

Positive values indicate bullish realized response.

Negative values indicate bearish realized response.

Values near equilibrium indicate limited directional response.

The displayed Field is visually compressed for readability across different instruments. Display smoothing and compression are presentation-only controls and do not alter the regime engine.

Regime timeline

The lower ribbon provides a compact visual history of confirmed auction regimes. Its debounce is presentation-only. It does not delay state transitions or alerts.

Semantic dashboard

The dashboard translates internal evidence into a compact interpretation:

Response Field — Bullish / Neutral / Bearish

Market Effort — High / Normal / Low

Price Response — High / Normal / Low

Path Quality — Orderly / Mixed / Low

Modifier — current orthogonal context, when present

Raw diagnostic values can be enabled from Advanced display.

Signal detail

ARF offers three visual signal levels:

Essential — Drive regime entries only. Recommended default.

Selective — Drive entries plus high-significance Absorption and Vacuum-like events.

Research — broader event visibility for analysis.

These settings change presentation only. They do not alter primary regime ownership.

Confirmed-bar behavior and repainting

The continuous Response Field can move on the live bar because current OHLCV values are still changing.

Primary regime transitions, regime counters and state alerts are committed only when the bar is confirmed. ARF does not use future-looking data or lookahead logic.

A live-bar Field movement should therefore not be confused with a confirmed regime transition.

How to use ARF

ARF is best used as a market-context layer rather than as an isolated entry system.

Examples:

distinguish directional Drive from Balance before evaluating a setup,

identify when directional effort is being absorbed,

recognize contested Churn conditions,

use Vacuum-like or Low-Efficiency modifiers to qualify the primary regime,

track whether a directional regime persists or loses semantic ownership.

ARF does not provide profit guarantees, price targets or certainty about future price movement. A regime describes the current auction structure; it is not a forecast that price must continue in the same direction.

Suggested chart setup

For the cleanest view:

use standard candles,

keep Signal detail = Essential initially,

keep the semantic dashboard and regime timeline enabled,

leave research evidence plots disabled unless inspecting the model,

evaluate multiple instruments and timeframes rather than optimizing visual settings for one chart.

## Source Code

````pine
//@version=6
indicator(
     "Auction Response Field [ARF]",
     shorttitle = "ARF",
     overlay = false,
     precision = 2,
     max_labels_count = 200)

//=============================================================================
// ARF v1.7 — PRODUCTIZATION & EDITOR'S PICK RELEASE CANDIDATE
//
// Frozen research core:
//   ARF v1.3B — Asymmetric Hysteresis & Balance Escape Closure
//
// Architecture:
//   1) Structural feature layer
//   2) Comparable state-evidence layer
//   3) Stateful primary auction regime
//   4) Orthogonal modifiers
//   5) Realized Response Field
//
// IMPORTANT:
//   Primary-state transitions are COMMITTED ONLY on confirmed bars.
//   The live Field may update intrabar, but state ownership/counters do not.
//
// PRODUCT PRINCIPLE:
//   ARF is a market-state interpretation tool, not a buy/sell prediction model.
//   It describes auction behavior through Response Field, persistent primary
//   regimes and orthogonal modifiers. No future-looking data is used.
//=============================================================================

//=============================================================================
// FROZEN CANONICAL CALIBRATION
//
// These values are the empirically validated ARF v1.6 production core.
// They are intentionally not exposed as user inputs in the release candidate.
// Changing them would create a different research model and invalidate the
// documented validation chain.
//=============================================================================

contextLength = 34
effortReference = 1.00
responseReference = 0.60
levelCurve = 2.20
fieldSmooth = 5

efficiencyReference = 0.25
directionReference = 0.50
evidenceCurve = 2.00
directionDeadZone = 0.10

activeEntryThreshold = 55.0
activeHoldThreshold = 42.0
activeEntrySeparation = 8.0
activeSwitchMargin = 10.0
activeSwitchConfirmBars = 2
activeExitConfirmBars = 2

balanceEntryThreshold = 60.0
balanceHoldThreshold = 48.0
balanceEscapeConfirmBars = 2
activeToBalanceThreshold = 62.0
activeToBalanceConfirmBars = 2

vacuumLeverageRatioReference = 1.35
vacuumLeverageCurve = 2.00
vacuumEpsilonLevel = 5.0
vacuumModifierThreshold = 55.0
effortSupportedThreshold = 55.0
lowEfficiencyThreshold = 35.0

//=============================================================================
// USER INTERFACE — PRESENTATION ONLY
//=============================================================================

groupDisplay =
     "Display"

displayFieldSmooth =
     input.int(
         5,
         "Field display smoothing",
         minval = 1,
         maxval = 20,
         group = groupDisplay,
         tooltip = "Visual-only smoothing of the displayed Response Field. It does not change ARF evidence, state ownership or alerts.")

displayCompression =
     input.float(
         20.0,
         "Field display compression",
         minval = 1.0,
         maxval = 100.0,
         step = 1.0,
         group = groupDisplay,
         tooltip = "Visual-only monotonic compression used to keep the Response Field readable across instruments. It does not change the underlying Field.")

showRegimeTimeline =
     input.bool(
         true,
         "Show regime timeline",
         group = groupDisplay,
         tooltip = "Shows the debounced visual history of primary auction regimes at the bottom of the pane.")

showDashboard =
     input.bool(
         true,
         "Show semantic dashboard",
         group = groupDisplay,
         tooltip = "Shows the current confirmed regime plus plain-language Field, effort, response, path-quality and modifier context.")

showBarColors =
     input.bool(
         false,
         "Color price bars by primary state",
         group = groupDisplay,
         tooltip = "Optional chart bar coloring. Disabled by default to keep the publication chart clean.")

groupSignals =
     "Signals"

signalMode =
     input.string(
         "Essential",
         "Signal detail",
         options = [
             "Essential",
             "Selective",
             "Research"
         ],
         group = groupSignals,
         tooltip = "Essential: Drive regime entries only. Selective: adds high-significance Absorption and Vacuum-like events. Research: shows all enabled event classes.")

highSignificanceEvidence =
     input.float(
         70.0,
         "Selective-mode significance",
         minval = 50,
         maxval = 95,
         step = 1,
         group = groupSignals,
         tooltip = "Presentation-only evidence threshold used by Selective mode. It never changes the primary state engine.")

markerCooldownBars =
     input.int(
         4,
         "Marker cooldown",
         minval = 0,
         maxval = 20,
         group = groupSignals,
         tooltip = "Presentation-only suppression of repeated markers from the same category.")

groupAdvanced =
     "Advanced display"

timelineConfirmBars =
     input.int(
         2,
         "Timeline visual confirmation",
         minval = 1,
         maxval = 6,
         group = groupAdvanced,
         tooltip = "Visual-only debounce for the timeline. Primary state, counters and alerts remain on their confirmed-bar timing.")

debugDashboard =
     input.bool(
         false,
         "Show dashboard diagnostics",
         group = groupAdvanced,
         tooltip = "Adds raw Field, candidate evidence, Balance evidence and transition reason for research/debug use.")

showEvidencePlots =
     input.bool(
         false,
         "Show evidence plots",
         group = groupAdvanced,
         tooltip = "Displays internal evidence series for research. Keep disabled for normal use and publication screenshots.")

//=============================================================================
// CONSTANTS
//=============================================================================

STATE_TRANSITION      = 0
STATE_BALANCE         = 1
STATE_BULL_DRIVE      = 2
STATE_BEAR_DRIVE      = 3
STATE_BULL_ABSORPTION = 4
STATE_BEAR_ABSORPTION = 5
STATE_CHURN           = 6

eps =
     math.max(
         syminfo.mintick,
         0.0000001)

//=============================================================================
// HELPERS
//=============================================================================

f_clamp(float value, float minimum, float maximum) =>
    math.max(
         minimum,
         math.min(
             maximum,
             value))

f_level(float value, float reference, float curve) =>
    safeValue =
         math.max(
             value,
             0.0)

    safeReference =
         math.max(
             reference,
             eps)

    ratio =
         safeValue /
         safeReference

    powered =
         math.pow(
             ratio,
             curve)

    powered > 0
         ? 100.0 *
           powered /
           (1.0 + powered)
         : 0.0

f_positive_evidence(float value, float reference, float curve) =>
    positiveValue =
         math.max(
             value,
             0.0)

    f_level(
         positiveValue,
         math.max(reference, eps),
         curve)

f_wgmean4(
     float a,
     float b,
     float c,
     float d,
     float wa,
     float wb,
     float wc,
     float wd) =>

    safeA = math.max(a, 0.000001)
    safeB = math.max(b, 0.000001)
    safeC = math.max(c, 0.000001)
    safeD = math.max(d, 0.000001)

    exponent =
         wa * math.log(safeA) +
         wb * math.log(safeB) +
         wc * math.log(safeC) +
         wd * math.log(safeD)

    100.0 * math.exp(exponent)

f_wgmean3(
     float a,
     float b,
     float c,
     float wa,
     float wb,
     float wc) =>

    safeA = math.max(a, 0.000001)
    safeB = math.max(b, 0.000001)
    safeC = math.max(c, 0.000001)

    exponent =
         wa * math.log(safeA) +
         wb * math.log(safeB) +
         wc * math.log(safeC)

    100.0 * math.exp(exponent)

f_state_name(int state) =>
    state == STATE_BALANCE ? "BALANCE" :
      state == STATE_BULL_DRIVE ? "BULL DRIVE" :
      state == STATE_BEAR_DRIVE ? "BEAR DRIVE" :
      state == STATE_BULL_ABSORPTION ? "BULL ABSORPTION" :
      state == STATE_BEAR_ABSORPTION ? "BEAR ABSORPTION" :
      state == STATE_CHURN ? "CHURN" :
      "TRANSITION"


f_level_semantic(float value) =>
    value >= 70.0 ? "HIGH" :
      value >= 45.0 ? "NORMAL" :
      "LOW"

f_efficiency_semantic(float value) =>
    value >= 70.0 ? "ORDERLY" :
      value >= 45.0 ? "MIXED" :
      "LOW"

f_field_semantic(float value) =>
    value >= 8.0 ? "BULLISH" :
      value <= -8.0 ? "BEARISH" :
      "NEUTRAL"


//=============================================================================
// BAR GEOMETRY
//=============================================================================

previousClose =
     nz(
         close[1],
         close)

trueRange =
     math.max(
         high - low,
         math.max(
             math.abs(
                 high -
                 previousClose),
             math.abs(
                 low -
                 previousClose)))

atr =
     ta.rma(
         trueRange,
         contextLength)

safeTR =
     math.max(
         trueRange,
         eps)

safeATR =
     math.max(
         atr,
         eps)

body =
     math.abs(
         close -
         open)

upperWick =
     math.max(
         high -
         math.max(
             open,
             close),
         0.0)

lowerWick =
     math.max(
         math.min(
             open,
             close) -
         low,
         0.0)

upperWickRatio =
     f_clamp(
         upperWick /
         safeTR,
         0.0,
         1.0)

lowerWickRatio =
     f_clamp(
         lowerWick /
         safeTR,
         0.0,
         1.0)

closeLocation =
     f_clamp(
         (
             (close - low) -
             (high - close)
         ) /
         safeTR,
         -1.0,
         1.0)

//=============================================================================
// PARTICIPATION
//=============================================================================

volumeAverage =
     ta.sma(
         volume,
         contextLength)

hasUsableVolume =
     not na(volume) and
     not na(volumeAverage) and
     volumeAverage > 0

relativeParticipation =
     hasUsableVolume
         ? volume /
           volumeAverage
         : 1.0

//=============================================================================
// EFFORT
//=============================================================================

rangeExpansion =
     trueRange /
     safeATR

effortRaw =
     math.sqrt(
         math.max(
             rangeExpansion,
             0.0) *
         math.max(
             relativeParticipation,
             0.0))

effortLevel =
     f_level(
         effortRaw,
         effortReference,
         levelCurve)

//=============================================================================
// RESPONSE
//=============================================================================

bodyResponse =
     body /
     safeATR

stepResponse =
     math.abs(
         close -
         previousClose) /
     safeATR

responseRaw =
     bodyResponse * 0.55 +
     stepResponse * 0.45

responseLevel =
     f_level(
         responseRaw,
         responseReference,
         levelCurve)

//=============================================================================
// PATH EFFICIENCY
//=============================================================================

stepDistance =
     math.abs(
         close -
         previousClose)

pathDistance =
     ta.sma(
         stepDistance,
         contextLength) *
     contextLength

netDistance =
     math.abs(
         close -
         nz(
             close[contextLength],
             close))

pathEfficiency =
     pathDistance > eps
         ? f_clamp(
             netDistance /
             pathDistance,
             0.0,
             1.0)
         : 0.0

efficiencyEvidence =
     f_level(
         pathEfficiency,
         efficiencyReference,
         evidenceCurve)

//=============================================================================
// DIRECTION
//=============================================================================

bodyDirection =
     close > open
         ? 1.0
         : close < open
             ? -1.0
             : 0.0

bodyFraction =
     f_clamp(
         body /
         safeTR,
         0.0,
         1.0)

directionRaw =
     f_clamp(
         closeLocation * 0.60 +
         bodyDirection *
         bodyFraction *
         0.40,
         -1.0,
         1.0)

direction =
     math.abs(
         directionRaw) >= directionDeadZone
         ? directionRaw
         : 0.0

directionConviction =
     f_level(
         math.abs(direction),
         directionReference,
         evidenceCurve)

//=============================================================================
// NORMALIZED EVIDENCE COMPONENTS
//=============================================================================

effortHigh =
     effortLevel /
     100.0

effortLow =
     1.0 -
     effortHigh

responseHigh =
     responseLevel /
     100.0

responseLow =
     1.0 -
     responseHigh

efficiencyHigh =
     efficiencyEvidence /
     100.0

efficiencyLow =
     1.0 -
     efficiencyHigh

bullDirectionEvidence =
     direction > 0
         ? directionConviction /
           100.0
         : 0.0

bearDirectionEvidence =
     direction < 0
         ? directionConviction /
           100.0
         : 0.0

directionNeutrality =
     1.0 -
     directionConviction /
     100.0

//=============================================================================
// REJECTION GEOMETRY
//=============================================================================

lowerRejection =
     f_clamp(
         lowerWickRatio *
         2.0,
         0.0,
         1.0) *
     f_clamp(
         (
             closeLocation +
             1.0
         ) /
         2.0,
         0.0,
         1.0)

upperRejection =
     f_clamp(
         upperWickRatio *
         2.0,
         0.0,
         1.0) *
     f_clamp(
         (
             1.0 -
             closeLocation
         ) /
         2.0,
         0.0,
         1.0)

bullOneSidedRejection =
     lowerRejection *
     (
         1.0 -
         upperRejection
     )

bearOneSidedRejection =
     upperRejection *
     (
         1.0 -
         lowerRejection
     )

twoSidedRejection =
     math.sqrt(
         math.max(
             lowerRejection *
             upperRejection,
             0.0))

//=============================================================================
// PRIMARY STATE EVIDENCE — FROZEN v1.2 GEOMETRY
//=============================================================================

bullDriveEvidence =
     f_wgmean4(
         effortHigh,
         responseHigh,
         efficiencyHigh,
         bullDirectionEvidence,
         0.15,
         0.35,
         0.25,
         0.25)

bearDriveEvidence =
     f_wgmean4(
         effortHigh,
         responseHigh,
         efficiencyHigh,
         bearDirectionEvidence,
         0.15,
         0.35,
         0.25,
         0.25)

bullAbsorptionEvidence =
     f_wgmean4(
         effortHigh,
         responseLow,
         bullOneSidedRejection,
         efficiencyLow,
         0.30,
         0.30,
         0.30,
         0.10)

bearAbsorptionEvidence =
     f_wgmean4(
         effortHigh,
         responseLow,
         bearOneSidedRejection,
         efficiencyLow,
         0.30,
         0.30,
         0.30,
         0.10)

churnEvidence =
     f_wgmean4(
         effortHigh,
         responseLow,
         twoSidedRejection,
         directionNeutrality,
         0.25,
         0.25,
         0.30,
         0.20)

balanceEvidence =
     f_wgmean3(
         effortLow,
         responseLow,
         efficiencyLow,
         0.35,
         0.35,
         0.30)

//=============================================================================
// VACUUM-LIKE MODIFIER — FROZEN v1.3B ARCHITECTURE
//=============================================================================

responseEffortRatio =
     (
         responseLevel +
         vacuumEpsilonLevel
     ) /
     (
         effortLevel +
         vacuumEpsilonLevel
     )

displacementLeverageRaw =
     math.log(
         math.max(
             responseEffortRatio,
             0.000001))

vacuumLeverageReference =
     math.log(
         math.max(
             vacuumLeverageRatioReference,
             1.000001))

displacementLeverageEvidence =
     f_positive_evidence(
         math.max(
             displacementLeverageRaw,
             0.0),
         vacuumLeverageReference,
         vacuumLeverageCurve)

leverageHigh =
     displacementLeverageEvidence /
     100.0

bullVacuumEvidence =
     f_wgmean4(
         leverageHigh,
         responseHigh,
         efficiencyHigh,
         bullDirectionEvidence,
         0.25,
         0.30,
         0.25,
         0.20)

bearVacuumEvidence =
     f_wgmean4(
         leverageHigh,
         responseHigh,
         efficiencyHigh,
         bearDirectionEvidence,
         0.25,
         0.30,
         0.25,
         0.20)

//=============================================================================
// REALIZED RESPONSE FIELD — FROZEN
//=============================================================================

fieldRaw =
     responseLevel *
     direction *
     (
         0.35 +
         0.65 *
         pathEfficiency
     )

field =
     ta.ema(
         fieldRaw,
         fieldSmooth)

//=============================================================================
// ACTIVE CANDIDATE HELPERS
//=============================================================================

f_active_score(int state) =>
    state == STATE_BULL_DRIVE ? bullDriveEvidence :
      state == STATE_BEAR_DRIVE ? bearDriveEvidence :
      state == STATE_BULL_ABSORPTION ? bullAbsorptionEvidence :
      state == STATE_BEAR_ABSORPTION ? bearAbsorptionEvidence :
      state == STATE_CHURN ? churnEvidence :
      0.0

f_top_active() =>
    int bestState =
         STATE_BULL_DRIVE

    float bestScore =
         bullDriveEvidence

    float secondScore =
         -1.0

    if bearDriveEvidence > bestScore
        secondScore := bestScore
        bestScore := bearDriveEvidence
        bestState := STATE_BEAR_DRIVE
    else
        secondScore := math.max(
             secondScore,
             bearDriveEvidence)

    if bullAbsorptionEvidence > bestScore
        secondScore := bestScore
        bestScore := bullAbsorptionEvidence
        bestState := STATE_BULL_ABSORPTION
    else
        secondScore := math.max(
             secondScore,
             bullAbsorptionEvidence)

    if bearAbsorptionEvidence > bestScore
        secondScore := bestScore
        bestScore := bearAbsorptionEvidence
        bestState := STATE_BEAR_ABSORPTION
    else
        secondScore := math.max(
             secondScore,
             bearAbsorptionEvidence)

    if churnEvidence > bestScore
        secondScore := bestScore
        bestScore := churnEvidence
        bestState := STATE_CHURN
    else
        secondScore := math.max(
             secondScore,
             churnEvidence)

    [bestState, bestScore, secondScore]

[activeCandidate, activeCandidateScore, activeSecondScore] = f_top_active()

activeCandidateSeparation =
     activeCandidateScore -
     activeSecondScore

qualifyingActive = (
     activeCandidateScore >= activeEntryThreshold and
     activeCandidateSeparation >= activeEntrySeparation
)

//=============================================================================
// STATEFUL PRIMARY REGIME — v1.6 CANONICAL
//
// Canonical policy:
//   B_SEMANTIC_FIELD_GUARD
//
// COMMIT RULE:
//   State/counters update only on confirmed bars.
//
// GUARD RULE:
//   BULL DRIVE: Field <= 0 for 2 consecutive confirmed bars.
//   BEAR DRIVE: Field >= 0 for 2 consecutive confirmed bars.
//
// Active-to-active switching keeps first priority.
//=============================================================================

semanticFieldGuardBars =
     2

var int primaryState =
     STATE_TRANSITION

var string transitionReason =
     "INIT"

var int activeExitCounter =
     0

var int pendingActiveSwitch =
     STATE_TRANSITION

var int pendingActiveSwitchCount =
     0

var int pendingBalanceEscape =
     STATE_TRANSITION

var int pendingBalanceEscapeCount =
     0

var int pendingBalanceEntryCount =
     0

var int semanticFieldGuardCounter =
     0

if barstate.isconfirmed

    //-------------------------------------------------------------------------
    // TRANSITION
    //-------------------------------------------------------------------------

    if primaryState == STATE_TRANSITION

        activeExitCounter := 0
        pendingActiveSwitch := STATE_TRANSITION
        pendingActiveSwitchCount := 0
        pendingBalanceEscape := STATE_TRANSITION
        pendingBalanceEscapeCount := 0
        pendingBalanceEntryCount := 0
        semanticFieldGuardCounter := 0

        if qualifyingActive

            primaryState :=
                 activeCandidate

            transitionReason :=
                 "ENTER_ACTIVE"

        else if
             balanceEvidence >= balanceEntryThreshold and
             activeCandidateScore < activeEntryThreshold

            primaryState :=
                 STATE_BALANCE

            transitionReason :=
                 "ENTER_BALANCE"

        else

            transitionReason :=
                 "WAIT"

    //-------------------------------------------------------------------------
    // BALANCE
    //-------------------------------------------------------------------------

    else if primaryState == STATE_BALANCE

        pendingActiveSwitch :=
             STATE_TRANSITION

        pendingActiveSwitchCount :=
             0

        activeExitCounter :=
             0

        semanticFieldGuardCounter :=
             0

        if qualifyingActive

            if pendingBalanceEscape == activeCandidate

                pendingBalanceEscapeCount +=
                     1

            else

                pendingBalanceEscape :=
                     activeCandidate

                pendingBalanceEscapeCount :=
                     1

            if pendingBalanceEscapeCount >= balanceEscapeConfirmBars

                primaryState :=
                     activeCandidate

                transitionReason :=
                     "BALANCE_ESCAPE_TO_ACTIVE"

                pendingBalanceEscape :=
                     STATE_TRANSITION

                pendingBalanceEscapeCount :=
                     0

            else

                transitionReason :=
                     "BALANCE_ESCAPE_PENDING"

        else

            pendingBalanceEscape :=
                 STATE_TRANSITION

            pendingBalanceEscapeCount :=
                 0

            if balanceEvidence >= balanceHoldThreshold

                transitionReason :=
                     "HOLD_BALANCE"

            else

                primaryState :=
                     STATE_TRANSITION

                transitionReason :=
                     "EXIT_BALANCE_WEAK"

    //-------------------------------------------------------------------------
    // ACTIVE STATES
    //-------------------------------------------------------------------------

    else

        currentActiveScore =
             f_active_score(
                 primaryState)

        switchPending =
             false

        switchCommitted =
             false

        // Frozen Active -> different Active switch gets first priority.
        if activeCandidate != primaryState

            switchEligible =
                 activeCandidateScore >= activeEntryThreshold and
                 activeCandidateSeparation >= activeEntrySeparation and
                 (
                     activeCandidateScore -
                     currentActiveScore
                 ) >= activeSwitchMargin

            if switchEligible

                activeExitCounter :=
                     0

                pendingBalanceEntryCount :=
                     0

                if pendingActiveSwitch == activeCandidate

                    pendingActiveSwitchCount +=
                         1

                else

                    pendingActiveSwitch :=
                         activeCandidate

                    pendingActiveSwitchCount :=
                         1

                if pendingActiveSwitchCount >= activeSwitchConfirmBars

                    primaryState :=
                         activeCandidate

                    pendingActiveSwitch :=
                         STATE_TRANSITION

                    pendingActiveSwitchCount :=
                         0

                    semanticFieldGuardCounter :=
                         0

                    transitionReason :=
                         "SWITCH_ACTIVE"

                    switchCommitted :=
                         true

                else

                    transitionReason :=
                         "HOLD_ACTIVE_SWITCH_PENDING"

                    switchPending :=
                         true

            else

                pendingActiveSwitch :=
                     STATE_TRANSITION

                pendingActiveSwitchCount :=
                     0

        else

            pendingActiveSwitch :=
                 STATE_TRANSITION

            pendingActiveSwitchCount :=
                 0

        // Only continue ownership checks if no Active switch committed.
        if not switchCommitted

            driveFieldIncompatible =
                 (
                     primaryState == STATE_BULL_DRIVE and
                     field <= 0
                 ) or
                 (
                     primaryState == STATE_BEAR_DRIVE and
                     field >= 0
                 )

            isDriveStateCanonical =
                 primaryState == STATE_BULL_DRIVE or
                 primaryState == STATE_BEAR_DRIVE

            if isDriveStateCanonical and driveFieldIncompatible

                semanticFieldGuardCounter +=
                     1

            else

                semanticFieldGuardCounter :=
                     0

            semanticGuardExit =
                 isDriveStateCanonical and
                 semanticFieldGuardCounter >= semanticFieldGuardBars

            if semanticGuardExit

                if
                     balanceEvidence >= activeToBalanceThreshold and
                     activeCandidateScore < activeEntryThreshold

                    primaryState :=
                         STATE_BALANCE

                    transitionReason :=
                         "SEMANTIC_FIELD_GUARD_EXIT_TO_BALANCE"

                else

                    primaryState :=
                         STATE_TRANSITION

                    transitionReason :=
                         "SEMANTIC_FIELD_GUARD_EXIT_TO_TRANSITION"

                activeExitCounter :=
                     0

                pendingBalanceEntryCount :=
                     0

                semanticFieldGuardCounter :=
                     0

            else

                // Frozen v1.3B hold / weak-exit semantics.
                if currentActiveScore >= activeHoldThreshold

                    activeExitCounter :=
                         0

                    pendingBalanceEntryCount :=
                         0

                    if switchPending

                        transitionReason :=
                             "HOLD_ACTIVE_SWITCH_PENDING"

                    else if activeCandidate == primaryState

                        transitionReason :=
                             "HOLD_ACTIVE"

                    else

                        transitionReason :=
                             "HOLD_ACTIVE_HYSTERESIS"

                else

                    activeExitCounter +=
                         1

                    if
                         balanceEvidence >= activeToBalanceThreshold and
                         activeCandidateScore < activeEntryThreshold

                        pendingBalanceEntryCount +=
                             1

                    else

                        pendingBalanceEntryCount :=
                             0

                    if activeExitCounter >= activeExitConfirmBars

                        if pendingBalanceEntryCount >= activeToBalanceConfirmBars

                            primaryState :=
                                 STATE_BALANCE

                            transitionReason :=
                                 "ACTIVE_EXIT_TO_BALANCE"

                        else

                            primaryState :=
                                 STATE_TRANSITION

                            transitionReason :=
                                 "ACTIVE_EXIT_TO_TRANSITION"

                        activeExitCounter :=
                             0

                        pendingBalanceEntryCount :=
                             0

                        semanticFieldGuardCounter :=
                             0

                    else

                        transitionReason :=
                             "HOLD_ACTIVE_EXIT_PENDING"

//=============================================================================
// MODIFIERS
//=============================================================================

bullVacuumLike = (
     bullVacuumEvidence >= vacuumModifierThreshold and
     direction > 0
)

bearVacuumLike = (
     bearVacuumEvidence >= vacuumModifierThreshold and
     direction < 0
)

vacuumLike = (
     bullVacuumLike or
     bearVacuumLike
)

isDriveState = (
     primaryState == STATE_BULL_DRIVE or
     primaryState == STATE_BEAR_DRIVE
)

effortSupported = (
     isDriveState and
     effortLevel >= effortSupportedThreshold
)

lowEfficiency = (
     primaryState != STATE_TRANSITION and
     efficiencyEvidence <= lowEfficiencyThreshold
)

modifierName = (
     bullVacuumLike ? "BULL VACUUM-LIKE" :
     bearVacuumLike ? "BEAR VACUUM-LIKE" :
     effortSupported ? "EFFORT-SUPPORTED" :
     lowEfficiency ? "LOW EFFICIENCY" :
     "NONE"
)

//=============================================================================
// STATE EVENTS — CONFIRMED ONLY
//=============================================================================

stateChanged = (
     barstate.isconfirmed and
     primaryState != nz(primaryState[1], STATE_TRANSITION)
)

enteredBullDrive =
     stateChanged and
     primaryState == STATE_BULL_DRIVE

enteredBearDrive =
     stateChanged and
     primaryState == STATE_BEAR_DRIVE

enteredBullAbsorption =
     stateChanged and
     primaryState == STATE_BULL_ABSORPTION

enteredBearAbsorption =
     stateChanged and
     primaryState == STATE_BEAR_ABSORPTION

enteredChurn =
     stateChanged and
     primaryState == STATE_CHURN

enteredBalance =
     stateChanged and
     primaryState == STATE_BALANCE

enteredTransition =
     stateChanged and
     primaryState == STATE_TRANSITION

newBullVacuumLike =
     barstate.isconfirmed and
     bullVacuumLike and
     not bullVacuumLike[1]

newBearVacuumLike =
     barstate.isconfirmed and
     bearVacuumLike and
     not bearVacuumLike[1]

//=============================================================================
// COLORS
//=============================================================================

bullDriveColor =
     color.rgb(
         0,
         196,
         145)

bearDriveColor =
     color.rgb(
         232,
         76,
         92)

bullAbsorptionColor =
     color.rgb(
         58,
         181,
         131)

bearAbsorptionColor =
     color.rgb(
         216,
         112,
         116)

churnColor =
     color.rgb(
         226,
         174,
         65)

balanceColor =
     color.rgb(
         138,
         144,
         154)

transitionColor =
     color.rgb(
         95,
         103,
         116)

bullVacuumColor =
     color.rgb(
         69,
         147,
         245)

bearVacuumColor =
     color.rgb(
         178,
         101,
         232)

primaryStateColor = (
     primaryState == STATE_BULL_DRIVE ? bullDriveColor :
     primaryState == STATE_BEAR_DRIVE ? bearDriveColor :
     primaryState == STATE_BULL_ABSORPTION ? bullAbsorptionColor :
     primaryState == STATE_BEAR_ABSORPTION ? bearAbsorptionColor :
     primaryState == STATE_CHURN ? churnColor :
     primaryState == STATE_BALANCE ? balanceColor :
     transitionColor
)

// Visual-only Field transform.
// Research Field and all state evidence remain untouched.
displayFieldBase =
     ta.ema(
         field,
         displayFieldSmooth)

displayField =
     50.0 *
     displayFieldBase /
     (
         math.abs(displayFieldBase) +
         displayCompression
     )

fieldColor = (
     displayField > 0 ? bullDriveColor :
     displayField < 0 ? bearDriveColor :
     balanceColor
)

//=============================================================================
// PANEL — VISUALLY COMPRESSED REALIZED RESPONSE FIELD
//=============================================================================

zeroPlot =
     plot(
         0,
         "Equilibrium",
         color =
             color.new(
                 color.gray,
                 100),
         display = display.pane)

fieldPlot =
     plot(
         displayField,
         "Display Response Field",
         color = fieldColor,
         linewidth = 2,
         display = display.pane)

fill(
     fieldPlot,
     zeroPlot,
     color =
         displayField >= 0
             ? color.new(
                 bullDriveColor,
                 91)
             : color.new(
                 bearDriveColor,
                 91))

plot(
     0,
     "Auction Equilibrium",
     color = color.new(color.gray, 72),
     linewidth = 1,
     display = display.pane)

plot(
     25,
     "Positive Response Zone",
     color = color.new(bullDriveColor, 86),
     linewidth = 1,
     display = display.pane)

plot(
     -25,
     "Negative Response Zone",
     color = color.new(bearDriveColor, 86),
     linewidth = 1,
     display = display.pane)

//=============================================================================
// REGIME TIMELINE — VISUAL PERSISTENCE LAYER
//
// timelineState is presentation-only.
// primaryState, alerts and state-machine counters remain untouched.
//
// A new primary state must persist for N confirmed bars before the timeline
// changes color. This removes micro-segmentation without changing research
// semantics or event timing.
//=============================================================================

var int timelineState =
     STATE_TRANSITION

var int timelinePendingState =
     STATE_TRANSITION

var int timelinePendingCount =
     0

if barstate.isconfirmed

    if primaryState == timelineState

        timelinePendingState :=
             STATE_TRANSITION

        timelinePendingCount :=
             0

    else

        if timelinePendingState == primaryState

            timelinePendingCount +=
                 1

        else

            timelinePendingState :=
                 primaryState

            timelinePendingCount :=
                 1

        if timelinePendingCount >= timelineConfirmBars

            timelineState :=
                 primaryState

            timelinePendingState :=
                 STATE_TRANSITION

            timelinePendingCount :=
                 0

timelineStateColor = (
     timelineState == STATE_BULL_DRIVE ? bullDriveColor :
     timelineState == STATE_BEAR_DRIVE ? bearDriveColor :
     timelineState == STATE_BULL_ABSORPTION ? bullAbsorptionColor :
     timelineState == STATE_BEAR_ABSORPTION ? bearAbsorptionColor :
     timelineState == STATE_CHURN ? churnColor :
     timelineState == STATE_BALANCE ? balanceColor :
     transitionColor
)

timelineTopLevel =
     -38.0

timelineBottomLevel =
     -46.0

timelineTop =
     plot(
         showRegimeTimeline
             ? timelineTopLevel
             : na,
         "Regime Timeline Top",
         color = color.new(timelineStateColor, 100),
         linewidth = 1,
         display = display.pane)

timelineBottom =
     plot(
         showRegimeTimeline
             ? timelineBottomLevel
             : na,
         "Regime Timeline Bottom",
         color = color.new(timelineStateColor, 100),
         linewidth = 1,
         display = display.pane)

fill(
     timelineTop,
     timelineBottom,
     color =
         showRegimeTimeline
             ? color.new(timelineStateColor, 8)
             : na,
     title = "Visual Regime Timeline")

//=============================================================================
// OPTIONAL RESEARCH EVIDENCE PLOTS
//=============================================================================

plot(
     showEvidencePlots
         ? effortLevel
         : na,
     "Effort Level",
     color =
         color.new(
             color.orange,
             45),
     display = display.pane)

plot(
     showEvidencePlots
         ? responseLevel
         : na,
     "Response Level",
     color =
         color.new(
             color.blue,
             45))

plot(
     showEvidencePlots
         ? efficiencyEvidence
         : na,
     "Efficiency Evidence",
     color =
         color.new(
             color.purple,
             55))

//=============================================================================
// VISUAL-ONLY MARKER COMPRESSION
//
// Alerts and state transitions remain unsuppressed.
// Cooldown affects presentation only.
//=============================================================================

var int lastDriveMarkerBar =
     na

var int lastAbsorptionMarkerBar =
     na

var int lastVacuumMarkerBar =
     na

var int lastChurnMarkerBar =
     na

driveEvent =
     enteredBullDrive or
     enteredBearDrive

absorptionEvent =
     enteredBullAbsorption or
     enteredBearAbsorption

vacuumEvent =
     newBullVacuumLike or
     newBearVacuumLike

//=============================================================================
// SIGNAL HIERARCHY
//
// Essential  : Drive entry events only.
// Selective  : Drive + high-significance Absorption/Vacuum.
// Research   : all event classes.
//
// This layer is presentation-only. Alerts and state ownership are unchanged.
//=============================================================================

essentialMode =
     signalMode == "Essential"

selectiveMode =
     signalMode == "Selective"

researchMode =
     signalMode == "Research"

bullAbsorptionSignificant =
     enteredBullAbsorption and
     bullAbsorptionEvidence >= highSignificanceEvidence

bearAbsorptionSignificant =
     enteredBearAbsorption and
     bearAbsorptionEvidence >= highSignificanceEvidence

bullVacuumSignificant =
     newBullVacuumLike and
     bullVacuumEvidence >= highSignificanceEvidence

bearVacuumSignificant =
     newBearVacuumLike and
     bearVacuumEvidence >= highSignificanceEvidence

showDriveEvent =
     driveEvent

showBullAbsorptionEvent =
     researchMode
         ? enteredBullAbsorption
         : selectiveMode
             ? bullAbsorptionSignificant
             : false

showBearAbsorptionEvent =
     researchMode
         ? enteredBearAbsorption
         : selectiveMode
             ? bearAbsorptionSignificant
             : false

showBullVacuumEvent =
     researchMode
         ? newBullVacuumLike
         : selectiveMode
             ? bullVacuumSignificant
             : false

showBearVacuumEvent =
     researchMode
         ? newBearVacuumLike
         : selectiveMode
             ? bearVacuumSignificant
             : false

showChurnEvent =
     researchMode and
     enteredChurn


driveMarkerAllowed =
     driveEvent and
     (
         na(lastDriveMarkerBar) or
         bar_index - lastDriveMarkerBar > markerCooldownBars
     )

absorptionDisplayEvent =
     showBullAbsorptionEvent or
     showBearAbsorptionEvent

vacuumDisplayEvent =
     showBullVacuumEvent or
     showBearVacuumEvent

absorptionMarkerAllowed =
     absorptionDisplayEvent and
     (
         na(lastAbsorptionMarkerBar) or
         bar_index - lastAbsorptionMarkerBar > markerCooldownBars
     )

vacuumMarkerAllowed =
     vacuumDisplayEvent and
     (
         na(lastVacuumMarkerBar) or
         bar_index - lastVacuumMarkerBar > markerCooldownBars
     )

churnMarkerAllowed =
     showChurnEvent and
     (
         na(lastChurnMarkerBar) or
         bar_index - lastChurnMarkerBar > markerCooldownBars
     )

if barstate.isconfirmed

    if driveMarkerAllowed
        lastDriveMarkerBar :=
             bar_index

    if absorptionMarkerAllowed
        lastAbsorptionMarkerBar :=
             bar_index

    if vacuumMarkerAllowed
        lastVacuumMarkerBar :=
             bar_index

    if churnMarkerAllowed
        lastChurnMarkerBar :=
             bar_index

//=============================================================================
// MAIN-CHART SPARSE STATE MARKERS
//=============================================================================

plotshape(
     showDriveEvent and
     driveMarkerAllowed and
     enteredBullDrive,
     title = "Bull Drive Entered",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullDriveColor,
     size = size.tiny,
     text = "D",
     textcolor = color.white,
     force_overlay = true)

plotshape(
     showDriveEvent and
     driveMarkerAllowed and
     enteredBearDrive,
     title = "Bear Drive Entered",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearDriveColor,
     size = size.tiny,
     text = "D",
     textcolor = color.white,
     force_overlay = true)

plotshape(
     absorptionMarkerAllowed and
     showBullAbsorptionEvent,
     title = "Bull Absorption Entered",
     style = shape.diamond,
     location = location.belowbar,
     color = bullAbsorptionColor,
     size = size.tiny,
     text = "A",
     textcolor = color.white,
     force_overlay = true)

plotshape(
     absorptionMarkerAllowed and
     showBearAbsorptionEvent,
     title = "Bear Absorption Entered",
     style = shape.diamond,
     location = location.abovebar,
     color = bearAbsorptionColor,
     size = size.tiny,
     text = "A",
     textcolor = color.white,
     force_overlay = true)

plotshape(
     churnMarkerAllowed and
     showChurnEvent,
     title = "Churn Entered",
     style = shape.circle,
     location = location.abovebar,
     color = churnColor,
     size = size.tiny,
     text = "C",
     textcolor = color.black,
     force_overlay = true)

//=============================================================================
// MAIN-CHART VACUUM-LIKE MODIFIER MARKERS
//=============================================================================

plotshape(
     vacuumMarkerAllowed and
     showBullVacuumEvent,
     title = "Bull Vacuum-Like",
     style = shape.square,
     location = location.belowbar,
     color = bullVacuumColor,
     size = size.tiny,
     text = "V",
     textcolor = color.white,
     force_overlay = true)

plotshape(
     vacuumMarkerAllowed and
     showBearVacuumEvent,
     title = "Bear Vacuum-Like",
     style = shape.square,
     location = location.abovebar,
     color = bearVacuumColor,
     size = size.tiny,
     text = "V",
     textcolor = color.white,
     force_overlay = true)

//=============================================================================
// OPTIONAL PRICE-BAR COLORING
//=============================================================================

priceBarColor =
     primaryState == STATE_BULL_DRIVE
         ? color.new(
             bullDriveColor,
             25)
         : primaryState == STATE_BEAR_DRIVE
             ? color.new(
                 bearDriveColor,
                 25)
             : primaryState == STATE_BULL_ABSORPTION
                 ? color.new(
                     bullAbsorptionColor,
                     45)
                 : primaryState == STATE_BEAR_ABSORPTION
                     ? color.new(
                         bearAbsorptionColor,
                         45)
                     : primaryState == STATE_CHURN
                         ? color.new(
                             churnColor,
                             45)
                         : na

barcolor(
     showBarColors
         ? priceBarColor
         : na)

//=============================================================================
// SEMANTIC DASHBOARD
//
// Default view communicates meaning rather than internal research variables.
// Debug mode exposes raw values and transition internals.
//=============================================================================

fieldSemantic =
     f_field_semantic(field)

effortSemantic =
     f_level_semantic(effortLevel)

responseSemantic =
     f_level_semantic(responseLevel)

efficiencySemantic =
     f_efficiency_semantic(efficiencyEvidence)

fieldSemanticColor = (
     field >= 8.0 ? bullDriveColor :
     field <= -8.0 ? bearDriveColor :
     balanceColor
)

effortSemanticColor = (
     effortLevel >= 70.0 ? churnColor :
     effortLevel >= 45.0 ? transitionColor :
     balanceColor
)

responseSemanticColor = (
     responseLevel >= 70.0 ? churnColor :
     responseLevel >= 45.0 ? transitionColor :
     balanceColor
)

efficiencySemanticColor = (
     efficiencyEvidence >= 70.0 ? bullDriveColor :
     efficiencyEvidence >= 45.0 ? transitionColor :
     bearAbsorptionColor
)

dashboardNeutralTextColor =
     transitionColor

modifierSemantic =
     modifierName == "NONE"
         ? "—"
         : modifierName

var table dashboard =
     table.new(
         position.top_right,
         2,
         10,
         border_width = 1)

if barstate.islast and showDashboard

    table.cell(
         dashboard,
         0,
         0,
         "ARF",
         text_color = color.white,
         bgcolor = primaryStateColor)

    table.cell(
         dashboard,
         1,
         0,
         f_state_name(primaryState),
         text_color = color.white,
         bgcolor = primaryStateColor)

    table.cell(
         dashboard,
         0,
         1,
         "Response Field",
         text_color = color.silver)

    table.cell(
         dashboard,
         1,
         1,
         fieldSemantic,
         text_color = fieldSemanticColor)

    table.cell(
         dashboard,
         0,
         2,
         "Market Effort",
         text_color = color.silver)

    table.cell(
         dashboard,
         1,
         2,
         effortSemantic,
         text_color = effortSemanticColor)

    table.cell(
         dashboard,
         0,
         3,
         "Price Response",
         text_color = color.silver)

    table.cell(
         dashboard,
         1,
         3,
         responseSemantic,
         text_color = responseSemanticColor)

    table.cell(
         dashboard,
         0,
         4,
         "Path Quality",
         text_color = color.silver)

    table.cell(
         dashboard,
         1,
         4,
         efficiencySemantic,
         text_color = efficiencySemanticColor)

    table.cell(
         dashboard,
         0,
         5,
         "Modifier",
         text_color = color.silver)

    table.cell(
         dashboard,
         1,
         5,
         modifierSemantic,
         text_color =
             bullVacuumLike
                 ? bullVacuumColor
                 : bearVacuumLike
                     ? bearVacuumColor
                     : dashboardNeutralTextColor)

    if debugDashboard

        table.cell(
             dashboard,
             0,
             6,
             "Raw Field",
             text_color = color.silver)

        table.cell(
             dashboard,
             1,
             6,
             str.tostring(field, "#.0"),
             text_color = fieldColor)

        table.cell(
             dashboard,
             0,
             7,
             "Candidate",
             text_color = color.silver)

        table.cell(
             dashboard,
             1,
             7,
             f_state_name(activeCandidate) +
             " " +
             str.tostring(activeCandidateScore, "#.0"),
             text_color = dashboardNeutralTextColor)

        table.cell(
             dashboard,
             0,
             8,
             "Balance",
             text_color = color.silver)

        table.cell(
             dashboard,
             1,
             8,
             str.tostring(balanceEvidence, "#.0"),
             text_color = balanceColor)

        table.cell(
             dashboard,
             0,
             9,
             "Action",
             text_color = color.silver)

        table.cell(
             dashboard,
             1,
             9,
             barstate.isconfirmed
                 ? transitionReason
                 : "LIVE / UNCONFIRMED",
             text_color =
                 barstate.isconfirmed
                     ? dashboardNeutralTextColor
                     : churnColor)

    else

        table.cell(dashboard, 0, 6, "")
        table.cell(dashboard, 1, 6, "")
        table.cell(dashboard, 0, 7, "")
        table.cell(dashboard, 1, 7, "")
        table.cell(dashboard, 0, 8, "")
        table.cell(dashboard, 1, 8, "")
        table.cell(dashboard, 0, 9, "")
        table.cell(dashboard, 1, 9, "")

//=============================================================================
// CANONICAL SEMANTIC FIELD GUARD EVENTS
//=============================================================================

semanticGuardExitEvent =
     barstate.isconfirmed and
     (
         transitionReason == "SEMANTIC_FIELD_GUARD_EXIT_TO_BALANCE" or
         transitionReason == "SEMANTIC_FIELD_GUARD_EXIT_TO_TRANSITION"
     )

alertcondition(
     semanticGuardExitEvent,
     "ARF Semantic Field Guard Exit",
     "ARF Semantic Field Guard released Drive ownership.")

//=============================================================================
// ALERTS — CONFIRMED PRIMARY-STATE EVENTS

//=============================================================================

alertcondition(
     enteredBullDrive,
     "ARF Bull Drive Entered",
     "ARF confirmed a Bull Drive auction regime.")

alertcondition(
     enteredBearDrive,
     "ARF Bear Drive Entered",
     "ARF confirmed a Bear Drive auction regime.")

alertcondition(
     enteredBullAbsorption,
     "ARF Bull Absorption Entered",
     "ARF confirmed a Bull Absorption auction regime.")

alertcondition(
     enteredBearAbsorption,
     "ARF Bear Absorption Entered",
     "ARF confirmed a Bear Absorption auction regime.")

alertcondition(
     enteredChurn,
     "ARF Churn Entered",
     "ARF confirmed a Churn auction regime.")

alertcondition(
     enteredBalance,
     "ARF Balance Entered",
     "ARF confirmed a Balance auction regime.")

alertcondition(
     enteredTransition,
     "ARF Transition Entered",
     "ARF returned to Transition because no primary auction regime currently owns the state.")

alertcondition(
     newBullVacuumLike,
     "ARF Bull Vacuum-Like Modifier",
     "ARF detected a confirmed Bull Vacuum-like modifier.")

alertcondition(
     newBearVacuumLike,
     "ARF Bear Vacuum-Like Modifier",
     "ARF detected a confirmed Bear Vacuum-like modifier.")
````
