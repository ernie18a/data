# WizTrader Imbalance Map (FVG)

- url: https://www.tradingview.com/script/h2B0UDc0-WizTrader-Imbalance-Map-FVG/
- type: indicator
- pine_id: PUB;30998da9c1194bfbb8efe32c60d65fa7
- version: 1.0

## Description

[b]WizTrader Imbalance Map (FVG)[/b] is an open-source current-timeframe Fair Value Gap indicator designed to keep the chart focused on a small set of meaningful open FVGs instead of displaying every detected gap.

It identifies confirmed three-bar Fair Value Gaps, tracks their remaining unfilled area, evaluates how price reacts when they are retested, and ranks active zones using proximity, formation quality, reaction history, remaining area, and recency.

This version specifically covers classic three-bar FVGs on the chart timeframe. It does not model session-opening gaps, volume imbalances, or higher-timeframe FVGs.

[b]Three-bar FVG model[/b]

A bullish FVG is confirmed when the low of the current confirmed bar is above the high from two bars earlier.

A bearish FVG is confirmed when the high of the current confirmed bar is below the low from two bars earlier.

The zone begins on the middle displacement bar and represents the price area between the first and third bars.

[b]Formation Quality[/b]

Not every raw three-bar gap enters the map.

Each candidate must pass the selected profile's minimum FVG-height and displacement requirements.

Formation Quality is normalized from 0 to 1 and combines:

[list]
[*][b]40% FVG height strength[/b] - gap height is measured on one fixed scale across all profiles; 0.60 ATR or more receives full gap-strength credit
[*][b]30% displacement body strength[/b] - middle-candle body size relative to ATR
[*][b]30% displacement efficiency[/b] - the proportion of the displacement candle occupied by its body
[/list]

Using one fixed gap-strength scale means the same physical FVG receives the same gap-quality score regardless of the selected profile.

[b]Partial fill tracking[/b]

The displayed box represents only the remaining unfilled portion of an FVG.

For bullish FVGs, the upper part of the zone is removed as price reaches downward through the gap.

For bearish FVGs, the lower part is removed as price reaches upward through the gap.

A move beyond the far edge, including a session gap completely across the zone, fully fills the FVG and removes it.

[b]Reaction Quality[/b]

Formation Quality describes how an FVG was created. Reaction Quality evaluates what happens when price later returns.

After a retest ends, the script observes the subsequent response over a bounded window.

Reaction Quality combines:

[list]
[*][b]55% response distance[/b] - favorable movement away from the remaining FVG
[*][b]20% response speed[/b] - faster favorable reactions receive more credit, scaled by the amount of movement actually achieved
[*][b]25% retained area[/b] - zones that survive a retest with more unfilled area receive more credit
[/list]

With no favorable movement, no speed credit is awarded.

The favorable-move target and observation window scale with the selected profile:

[list]
[*][b]Responsive[/b] - 1.0 ATR over 4 bars
[*][b]Balanced[/b] - 1.5 ATR over 6 bars
[*][b]Major[/b] - 2.5 ATR over 10 bars
[/list]

If another retest begins before the observation window expires, the previous reaction is finalized before the new interaction starts.

[b]Lifecycle[/b]

Each FVG can move through four active states:

[list]
[*][b]Fresh[/b] - no retest has occurred
[*][b]Tested[/b] - the zone has been retested but does not yet qualify as Responsive
[*][b]Responsive[/b] - completed reaction history shows a sufficiently strong response while meaningful zone area remains
[*][b]Weakening[/b] - the zone has been heavily consumed, repeated reactions are weak, or its latest reaction has deteriorated materially
[/list]

[b]Filled[/b] is the terminal event. A fully filled FVG is removed.

A Weakening zone can become Responsive again if later reaction evidence improves and enough of the zone remains.

[b]Current zone ranking[/b]

The script maintains a bounded pool of open FVGs and ranks them using:

[list]
[*]distance from current price
[*]Formation Quality
[*]completed Reaction Quality
[*]remaining unfilled area
[*]recency of the latest interaction
[*]lifecycle state
[/list]

By default, two bullish and two bearish FVGs are shown. The user can select between one and five zones per side.

Ranking behavior also changes with the selected profile. Responsive favors nearby and recent FVGs more strongly, while Major gives more influence to Formation Quality and allows stronger zones to remain relevant at greater distances.

[b]Display relevance[/b]

Each profile has a maximum display distance:

[list]
[*][b]Responsive[/b] - 6 ATR
[*][b]Balanced[/b] - 10 ATR
[*][b]Major[/b] - 14 ATR
[/list]

Thin zones remain protected within 2 ATR of current price so an FVG that is actively being tested does not disappear merely because only a small portion remains.

Beyond 2 ATR, the remaining zone height must still satisfy the selected profile's minimum FVG-size requirement relative to current ATR. This helps remove old line-like zones that are no longer visually significant.

Hidden zones are not automatically deleted from the internal pool and may become visible again if price approaches them.

[b]Profiles[/b]

[list]
[*][b]Responsive[/b] - designed for smaller and more local FVGs, with stronger emphasis on proximity and recency
[*][b]Balanced[/b] - the default middle ground
[*][b]Major[/b] - requires broader and stronger formations and gives Formation Quality more influence than proximity
[/list]

The profiles use the same underlying model but differ in admission thresholds, display range, reaction horizon, and ranking preferences.

[b]50% Level[/b]

The optional 50% Level displays the midpoint of the original FVG until price reaches it for the first time.

[b]Detailed labels[/b]

Detailed labels show:

[list]
[*]Bullish or Bearish direction
[*]current lifecycle state
[*]percentage of the original FVG still open
[*]RQ - Reaction Quality from 0 to 100 after at least one completed response
[/list]

[b]Display controls[/b]

Users can control:

[list]
[*]Imbalance Zones
[*]Extend Zones Right
[*]Zone Borders
[*]Zone Transparency
[*]50% Level
[*]Zone Labels
[*]Zones per Side
[*]Fresh Imbalances
[/list]

Display settings do not change the underlying FVG calculations.

[b]Alerts[/b]

Available alert conditions:

[list]
[*]New Bullish Imbalance
[*]New Bearish Imbalance
[*]Any New Imbalance
[*]Imbalance Touch
[*]Imbalance 50% Reached
[*]Imbalance Filled
[*]Imbalance Responsive
[*]Imbalance Weakening
[/list]

Relevant-zone alerts follow the same current-map eligibility used for displayed zones.

[b]Model design[/b]

The FVG definition itself uses the standard confirmed three-bar gap structure.

The differentiation is in how open FVGs are managed after detection:

[list]
[*]formation-quality filtering
[*]progressive remaining-area tracking
[*]post-retest Reaction Quality
[*]Fresh / Tested / Responsive / Weakening lifecycle
[*]profile-specific ranking
[*]distance-aware display management
[*]small top-N visualization instead of plotting every qualifying FVG
[/list]

The goal is not to introduce a new definition of Fair Value Gap. The goal is to provide a compact map of selected open FVGs whose condition and ranking can change as price interacts with them.

[b]Limitations[/b]

This version evaluates classic three-bar FVGs on the current chart timeframe only.

It is a current-state map, not a historical snapshot renderer. Filled or internally pruned zones disappear from earlier chart areas.

Reaction Quality is a normalized model score, not a probability, expected return, or prediction.

FVGs and their historical reactions do not guarantee future support, resistance, continuation, reversal, or profitable trades.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// WizTrader Imbalance Map (FVG)
// Open-source current-timeframe Fair Value Gap map.
//
// MODEL
//   Confirmed three-bar price gaps create bullish or bearish FVG zones.
//   The selected profile changes minimum FVG height, displacement-body and
//   candle-efficiency requirements, formation-quality threshold, display
//   distance, recency, reaction window, and ranking.
//   Zones shrink as price trades back through their unfilled area.
//   Thin zones remain eligible near current price. Farther away, their current
//   remaining height must still meet the profile minimum relative to current ATR.
//   A move beyond the far edge, including a gap across it, fully fills the zone.
//   Retests build a Reaction Quality score from response distance, response
//   speed, and retained zone area. The favorable-move cap scales by profile.
//   Lifecycle state can be Fresh, Tested, Responsive, or Weakening.
//   Visible zones are ranked by proximity, formation quality, reaction evidence,
//   remaining area, and recency.
//   This model specifically covers confirmed three-bar Fair Value Gaps (FVGs).
//   It does not model session-opening gaps, volume imbalances, or
//   higher-timeframe FVGs.
//
// FVG zones describe historical price behavior. They are not predictions and
// do not guarantee that price will react.
//
//@version=6
indicator(
     "WizTrader Imbalance Map (FVG)",
     shorttitle="WizFVGMap",
     overlay=true,
     max_boxes_count=100,
     max_lines_count=100,
     max_labels_count=100,
     explicit_plot_zorder=true)

// ─────────────────────────────────────────────────────────────────────────────
// WIZTRADER PALETTE
// ─────────────────────────────────────────────────────────────────────────────

color WIZ_BULL = color.rgb(85, 134, 219)
color WIZ_BEAR = color.rgb(172, 68, 203)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

groupDisplay = "Display"

showZones = input.bool(
     true,
     "Imbalance Zones",
     tooltip="Shows the currently selected bullish and bearish imbalance zones. This setting is visual only; alerts remain active.",
     group=groupDisplay)

extendZonesRight = input.bool(
     true,
     "Extend Zones Right",
     tooltip="Extends visible zones into the future chart area. When disabled, zones end at the current last bar and continue forward only as new bars appear.",
     group=groupDisplay)

showZoneBorders = input.bool(
     true,
     "Zone Borders",
     tooltip="Shows the outer border lines of visible imbalance zones.",
     group=groupDisplay)

zoneFillTransparency = input.int(
     86,
     "Zone Transparency",
     minval=0,
     maxval=100,
     step=1,
     tooltip="Controls zone fill transparency. 0 is fully opaque and 100 is fully transparent.",
     group=groupDisplay)

showMidpoint = input.bool(
     false,
     "50% Level",
     tooltip="Shows the original 50% level until price reaches it for the first time.",
     group=groupDisplay)

labelMode = input.string(
     "Minimal",
     "Zone Labels",
     options=["Off", "Minimal", "Detailed"],
     tooltip="Minimal shows direction only. Detailed shows lifecycle state, remaining percentage, and RQ after a completed response. RQ = Reaction Quality from 0 to 100.",
     group=groupDisplay)

maxZonesPerSide = input.int(
     2,
     "Zones per Side",
     minval=1,
     maxval=5,
     tooltip="Maximum number of currently relevant bullish zones and bearish zones shown on the chart.",
     group=groupDisplay)

groupModel = "Imbalance Model"

profile = input.string(
     "Balanced",
     "Profile",
     options=["Responsive", "Balanced", "Major"],
     tooltip="Responsive accepts smaller/local FVGs and limits display to 6 ATR. Balanced is the default with a 10 ATR display range. Major requires broader/stronger FVGs and allows display out to 14 ATR. Within 2 ATR of current price, thin zones stay visible and alertable. Reaction Quality also scales its move target with the profile: 1.0 / 1.5 / 2.5 ATR.",
     group=groupModel)

showFresh = input.bool(
     true,
     "Fresh Imbalances",
     tooltip="When disabled, untouched newly created FVGs remain hidden until price later trades into them.",
     group=groupModel)

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE CALIBRATION
// ─────────────────────────────────────────────────────────────────────────────

float minGapATR =
     profile == "Responsive" ? 0.05 :
     profile == "Major" ? 0.22 :
     0.12

float minBodyATR =
     profile == "Responsive" ? 0.30 :
     profile == "Major" ? 0.85 :
     0.55

float minBodyEfficiency =
     profile == "Responsive" ? 0.45 :
     profile == "Major" ? 0.70 :
     0.55

float minFormationQuality =
     profile == "Responsive" ? 0.16 :
     profile == "Major" ? 0.58 :
     0.34

float maxDisplayDistanceATR =
     profile == "Responsive" ? 6.0 :
     profile == "Major" ? 14.0 :
     10.0

float nearPriceProtectionATR = 2.0

int freshnessBars =
     profile == "Responsive" ? 70 :
     profile == "Major" ? 260 :
     140

int reactionWindow =
     profile == "Responsive" ? 4 :
     profile == "Major" ? 10 :
     6

// Longer observation windows use a larger favorable-move cap so Reaction
// Quality does not saturate too easily on slower / broader profiles.
float reactionMoveCapATR =
     profile == "Responsive" ? 1.00 :
     profile == "Major" ? 2.50 :
     1.50

// Relevance ranking calibration.
// Formation quality combines FVG height on a fixed 0.60 ATR scale,
// displacement-body strength, and candle efficiency. Ranking then balances
// proximity, formation quality, reaction evidence, remaining area, and recency.
float rankProximityWeight =
     profile == "Responsive" ? 8.00 :
     profile == "Major" ? 4.00 :
     6.00

float rankFormationWeight =
     profile == "Responsive" ? 1.00 :
     profile == "Major" ? 2.00 :
     1.50

float rankRemainingWeight = 1.30
float rankReactionWeight = 2.20
float rankResponsiveBonus = 0.80
float rankWeakeningPenalty = 0.60

float rankRecencyWeight =
     profile == "Responsive" ? 1.20 :
     profile == "Major" ? 0.50 :
     0.80

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

// ─────────────────────────────────────────────────────────────────────────────
// ZONE STORAGE
// ─────────────────────────────────────────────────────────────────────────────
//
// Side:
//   +1 = Bullish imbalance
//   -1 = Bearish imbalance

var array<float> zoneOriginalTop       = array.new_float()
var array<float> zoneOriginalBottom    = array.new_float()
var array<float> zoneRemainingTop      = array.new_float()
var array<float> zoneRemainingBottom   = array.new_float()
var array<int>   zoneSide              = array.new_int()
var array<float> zoneQuality           = array.new_float()
var array<int>   zoneLastInteraction   = array.new_int()
var array<bool>  zoneWasInside         = array.new_bool()
var array<int>   zoneRetestCount       = array.new_int()
var array<float> zoneReactionSum       = array.new_float()
var array<int>   zoneReactionCount     = array.new_int()
var array<float> zoneLastReaction      = array.new_float()
var array<float> zonePreviousReaction  = array.new_float()
var array<float> zoneTestStartRatio    = array.new_float()
var array<bool>  zoneReactionWatching  = array.new_bool()
var array<int>   zoneReactionStartBar  = array.new_int()
var array<float> zoneReactionBestMove  = array.new_float()
var array<int>   zoneReactionBestBar   = array.new_int()
var array<float> zoneReactionPostRatio = array.new_float()
var array<bool>  zoneMidpointHit       = array.new_bool()
var array<bool>  zoneVisibleConfirmed  = array.new_bool()
var array<box>   zoneBoxes             = array.new_box()
var array<line>  zoneMidLines          = array.new_line()
var array<label> zoneLabels            = array.new_label()

zoneRemainingRatio(int i) =>
    float originalTop = array.get(zoneOriginalTop, i)
    float originalBottom = array.get(zoneOriginalBottom, i)
    float remainingTop = array.get(zoneRemainingTop, i)
    float remainingBottom = array.get(zoneRemainingBottom, i)

    float originalHeight =
         math.max(originalTop - originalBottom, syminfo.mintick)

    clamp(
         (remainingTop - remainingBottom) / originalHeight,
         0.0,
         1.0)

zoneReactionAverage(int i) =>
    int reactions = array.get(zoneReactionCount, i)
    reactions > 0
     ? array.get(zoneReactionSum, i) / reactions
     : 0.0

zoneLifecycleCode(int i) =>
    int retests = array.get(zoneRetestCount, i)
    int reactions = array.get(zoneReactionCount, i)
    float remainingRatio = zoneRemainingRatio(i)
    float averageReaction = zoneReactionAverage(i)
    float lastReaction = array.get(zoneLastReaction, i)
    float previousReaction = array.get(zonePreviousReaction, i)

    bool reactionDecay =
         reactions >= 2 and
         previousReaction > 0.0 and
         lastReaction < previousReaction * 0.70

    bool persistentlyWeak =
         reactions >= 2 and
         averageReaction < 0.38

    bool structurallyConsumed =
         remainingRatio < 0.35

    bool responsive =
         reactions >= 1 and
         averageReaction >= 0.55 and
         lastReaction >= 0.50 and
         not reactionDecay and
         not structurallyConsumed

    int code = 0

    if retests == 0
        code := 0
    else if structurallyConsumed or reactionDecay or persistentlyWeak
        code := 3
    else if responsive
        code := 2
    else
        code := 1

    code

zoneLifecycleName(int code) =>
    code == 0 ? "Fresh" :
     code == 1 ? "Tested" :
     code == 2 ? "Responsive" :
     "Weakening"

finalizeReaction(int i) =>
    float bestMoveATR = array.get(zoneReactionBestMove, i)
    int startBar = array.get(zoneReactionStartBar, i)
    int bestBar = array.get(zoneReactionBestBar, i)
    float startRatio = math.max(array.get(zoneTestStartRatio, i), 0.001)
    float postRatio = array.get(zoneReactionPostRatio, i)

    int bestDelay =
         math.max(bestBar - startBar, 0)

    float moveComponent =
         clamp(bestMoveATR / reactionMoveCapATR, 0.0, 1.0)

    float speedComponent =
         1.0 -
         clamp(
              bestDelay / math.max(reactionWindow * 1.0, 1.0),
              0.0,
              1.0)

    float retentionComponent =
         clamp(
              postRatio / startRatio,
              0.0,
              1.0)

    // Speed only earns weight to the extent that favorable movement actually
    // occurred. A flat reaction therefore cannot receive free speed points.
    float reactionScore =
         moveComponent * 0.55 +
         speedComponent * moveComponent * 0.20 +
         retentionComponent * 0.25

    float oldLast =
         array.get(zoneLastReaction, i)

    array.set(zonePreviousReaction, i, oldLast)
    array.set(zoneLastReaction, i, reactionScore)
    array.set(
         zoneReactionSum,
         i,
         array.get(zoneReactionSum, i) + reactionScore)
    array.set(
         zoneReactionCount,
         i,
         array.get(zoneReactionCount, i) + 1)
    array.set(zoneReactionWatching, i, false)

    reactionScore

zoneDisplayEligible(int i, float currentAtr) =>
    float top = array.get(zoneRemainingTop, i)
    float bottom = array.get(zoneRemainingBottom, i)

    float atrDenominator =
         math.max(currentAtr, syminfo.mintick)

    float distanceToZone =
         close > top
         ? close - top
         : close < bottom
         ? bottom - close
         : 0.0

    float distanceATR =
         distanceToZone / atrDenominator

    bool distanceEligible =
         distanceATR <= maxDisplayDistanceATR

    // Thin zones remain relevant near current price, where they may be actively
    // tested and should stay visible/alertable. Farther away, the current
    // remaining height must still meet the selected profile's minimum FVG size.
    bool heightEligible =
         distanceATR <= nearPriceProtectionATR or
         (top - bottom) / atrDenominator >= minGapATR

    distanceEligible and
     heightEligible and
     (showFresh or array.get(zoneRetestCount, i) > 0)

zonePriority(int i, float currentAtr) =>
    float top = array.get(zoneRemainingTop, i)
    float bottom = array.get(zoneRemainingBottom, i)

    float distanceToZone =
         close > top
         ? close - top
         : close < bottom
         ? bottom - close
         : 0.0

    float distanceATR =
         distanceToZone / math.max(currentAtr, syminfo.mintick)

    float proximityScore =
         rankProximityWeight / (1.0 + distanceATR)

    float qualityScore =
         clamp(array.get(zoneQuality, i), 0.0, 1.0) * rankFormationWeight

    float remainingRatio =
         zoneRemainingRatio(i)

    float remainingScore =
         remainingRatio * rankRemainingWeight

    int reactionCount =
         array.get(zoneReactionCount, i)

    float averageReaction =
         zoneReactionAverage(i)

    float latestReaction =
         array.get(zoneLastReaction, i)

    float reactionEvidence =
         reactionCount > 0
         ? averageReaction * 0.40 + latestReaction * 0.60
         : 0.0

    int lifecycle =
         zoneLifecycleCode(i)

    float reactionScore =
         reactionEvidence * rankReactionWeight +
         (lifecycle == 2 ? rankResponsiveBonus : 0.0) -
         (lifecycle == 3 ? rankWeakeningPenalty : 0.0)

    int age =
         bar_index - array.get(zoneLastInteraction, i)

    float recency =
         clamp(
              1.0 - age / math.max(freshnessBars * 1.0, 1.0),
              0.0,
              1.0)

    float recencyScore =
         recency * rankRecencyWeight

    proximityScore +
     qualityScore +
     remainingScore +
     reactionScore +
     recencyScore

countSide(int wantedSide) =>
    int count = 0
    int n = array.size(zoneSide)

    if n > 0
        for i = 0 to n - 1
            if array.get(zoneSide, i) == wantedSide
                count += 1

    count

deleteZone(int index) =>
    box b = array.get(zoneBoxes, index)
    line mid = array.get(zoneMidLines, index)
    label l = array.get(zoneLabels, index)

    box.delete(b)

    if not na(mid)
        line.delete(mid)

    if not na(l)
        label.delete(l)

    array.remove(zoneOriginalTop, index)
    array.remove(zoneOriginalBottom, index)
    array.remove(zoneRemainingTop, index)
    array.remove(zoneRemainingBottom, index)
    array.remove(zoneSide, index)
    array.remove(zoneQuality, index)
    array.remove(zoneLastInteraction, index)
    array.remove(zoneWasInside, index)
    array.remove(zoneRetestCount, index)
    array.remove(zoneReactionSum, index)
    array.remove(zoneReactionCount, index)
    array.remove(zoneLastReaction, index)
    array.remove(zonePreviousReaction, index)
    array.remove(zoneTestStartRatio, index)
    array.remove(zoneReactionWatching, index)
    array.remove(zoneReactionStartBar, index)
    array.remove(zoneReactionBestMove, index)
    array.remove(zoneReactionBestBar, index)
    array.remove(zoneReactionPostRatio, index)
    array.remove(zoneMidpointHit, index)
    array.remove(zoneVisibleConfirmed, index)
    array.remove(zoneBoxes, index)
    array.remove(zoneMidLines, index)
    array.remove(zoneLabels, index)

    true

poolLimitPerSide() =>
    math.max(10, maxZonesPerSide * 4)

pruneSide(int side, float currentAtr) =>
    int poolLimit = poolLimitPerSide()

    while countSide(side) > poolLimit
        int weakestIndex = -1
        float weakestPriority = 1e20

        int n = array.size(zoneSide)
        if n > 0
            for i = 0 to n - 1
                if array.get(zoneSide, i) == side
                    float p = zonePriority(i, currentAtr)

                    if p < weakestPriority
                        weakestPriority := p
                        weakestIndex := i

        if weakestIndex >= 0
            deleteZone(weakestIndex)
        else
            break

    true

zoneIsVisibleCandidate(int index, float currentAtr) =>
    bool eligible = zoneDisplayEligible(index, currentAtr)
    int side = array.get(zoneSide, index)
    float thisPriority = zonePriority(index, currentAtr)
    int betterCount = 0

    if eligible
        int n = array.size(zoneSide)

        if n > 0
            for j = 0 to n - 1
                if j != index and array.get(zoneSide, j) == side and zoneDisplayEligible(j, currentAtr)
                    float otherPriority = zonePriority(j, currentAtr)

                    if otherPriority > thisPriority or (otherPriority == thisPriority and j < index)
                        betterCount += 1

    eligible and betterCount < maxZonesPerSide

// ─────────────────────────────────────────────────────────────────────────────
// BASE MEASURES
// ─────────────────────────────────────────────────────────────────────────────

float atr14 = ta.atr(14)
float atrSafe =
     na(atr14) or atr14 <= 0.0
     ? math.max(high - low, syminfo.mintick)
     : atr14

bool engineReady =
     bar_index >= 34 and
     not na(atr14)

// ─────────────────────────────────────────────────────────────────────────────
// CREATE NEW IMBALANCE
// ─────────────────────────────────────────────────────────────────────────────

addImbalance(float top, float bottom, int side, float quality, int leftBar) =>
    bool duplicateFound = false

    int n = array.size(zoneSide)

    if n > 0
        for i = 0 to n - 1
            if array.get(zoneSide, i) == side
                float existingTop = array.get(zoneRemainingTop, i)
                float existingBottom = array.get(zoneRemainingBottom, i)

                float overlapDepth =
                     math.min(top, existingTop) -
                     math.max(bottom, existingBottom)

                float candidateHeight =
                     math.max(top - bottom, syminfo.mintick)

                float overlapRatio =
                     math.max(overlapDepth, 0.0) / candidateHeight

                if overlapRatio >= 0.50
                    duplicateFound := true

    bool created = false

    if not duplicateFound
        color sideColor =
             side == 1
             ? WIZ_BULL
             : WIZ_BEAR

        box b = box.new(
             left=leftBar,
             top=top,
             right=bar_index,
             bottom=bottom,
             xloc=xloc.bar_index,
             extend=extendZonesRight ? extend.right : extend.none,
             bgcolor=color.new(sideColor, zoneFillTransparency),
             border_color=showZoneBorders ? color.new(sideColor, 55) : na,
             border_width=1)

        float midpoint =
             (top + bottom) * 0.50

        line mid = line.new(
             x1=leftBar,
             y1=midpoint,
             x2=bar_index,
             y2=midpoint,
             xloc=xloc.bar_index,
             extend=extendZonesRight ? extend.right : extend.none,
             color=na,
             style=line.style_dotted,
             width=1)

        array.push(zoneOriginalTop, top)
        array.push(zoneOriginalBottom, bottom)
        array.push(zoneRemainingTop, top)
        array.push(zoneRemainingBottom, bottom)
        array.push(zoneSide, side)
        array.push(zoneQuality, quality)
        array.push(zoneLastInteraction, bar_index)
        array.push(zoneWasInside, false)
        array.push(zoneRetestCount, 0)
        array.push(zoneReactionSum, 0.0)
        array.push(zoneReactionCount, 0)
        array.push(zoneLastReaction, 0.0)
        array.push(zonePreviousReaction, 0.0)
        array.push(zoneTestStartRatio, 1.0)
        array.push(zoneReactionWatching, false)
        array.push(zoneReactionStartBar, -1)
        array.push(zoneReactionBestMove, 0.0)
        array.push(zoneReactionBestBar, -1)
        array.push(zoneReactionPostRatio, 1.0)
        array.push(zoneMidpointHit, false)
        array.push(zoneVisibleConfirmed, false)
        array.push(zoneBoxes, b)
        array.push(zoneMidLines, mid)
        array.push(zoneLabels, na)

        pruneSide(side, atrSafe)

        created := true

    created

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMED THREE-BAR IMBALANCES
// ─────────────────────────────────────────────────────────────────────────────

bool newBullishEvent = false
bool newBearishEvent = false

if engineReady and barstate.isconfirmed
    float middleRange =
         math.max(high[1] - low[1], syminfo.mintick)

    float middleBody =
         math.abs(close[1] - open[1])

    float middleBodyATR =
         middleBody / atrSafe

    float middleEfficiency =
         middleBody / middleRange

    float bodyStrength =
         clamp(
              middleBodyATR / 1.25,
              0.0,
              1.0)

    float efficiencyStrength =
         clamp(
              (middleEfficiency - 0.40) / 0.45,
              0.0,
              1.0)

    bool bullishGap =
         low > high[2]

    bool bearishGap =
         high < low[2]

    if bullishGap
        float gapSize =
             low - high[2]

        float gapATR =
             gapSize / atrSafe

        // Gap strength uses one fixed ATR scale for every profile, so the same
        // physical FVG receives the same gap-quality score regardless of the
        // selected profile. 0.60 ATR or more saturates at 1.00.
        float gapStrength =
             clamp(
                  gapATR / 0.60,
                  0.0,
                  1.0)

        float formationQuality =
             gapStrength * 0.40 +
             bodyStrength * 0.30 +
             efficiencyStrength * 0.30

        bool qualified =
             gapATR >= minGapATR and
             middleBodyATR >= minBodyATR and
             middleEfficiency >= minBodyEfficiency and
             formationQuality >= minFormationQuality

        if qualified
            bool created =
                 addImbalance(
                      low,
                      high[2],
                      1,
                      formationQuality,
                      bar_index - 1)

            if created
                newBullishEvent := true

    if bearishGap
        float gapSize =
             low[2] - high

        float gapATR =
             gapSize / atrSafe

        float gapStrength =
             clamp(
                  gapATR / 0.60,
                  0.0,
                  1.0)

        float formationQuality =
             gapStrength * 0.40 +
             bodyStrength * 0.30 +
             efficiencyStrength * 0.30

        bool qualified =
             gapATR >= minGapATR and
             middleBodyATR >= minBodyATR and
             middleEfficiency >= minBodyEfficiency and
             formationQuality >= minFormationQuality

        if qualified
            bool created =
                 addImbalance(
                      low[2],
                      high,
                      -1,
                      formationQuality,
                      bar_index - 1)

            if created
                newBearishEvent := true

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE ZONE EVENTS + PARTIAL FILL
// ─────────────────────────────────────────────────────────────────────────────

bool touchEvent = false
bool midpointEvent = false
bool filledEvent = false
bool responsiveEvent = false
bool weakeningEvent = false

if engineReady and barstate.isconfirmed
    int i = array.size(zoneSide) - 1

    while i >= 0
        float originalTop = array.get(zoneOriginalTop, i)
        float originalBottom = array.get(zoneOriginalBottom, i)
        float remainingTop = array.get(zoneRemainingTop, i)
        float remainingBottom = array.get(zoneRemainingBottom, i)
        int side = array.get(zoneSide, i)

        bool wasInside = array.get(zoneWasInside, i)
        bool midpointHit = array.get(zoneMidpointHit, i)
        bool wasVisiblePrevious = array.get(zoneVisibleConfirmed, i)
        bool reactionWatching = array.get(zoneReactionWatching, i)

        int lifecycleBefore =
             zoneLifecycleCode(i)

        // Directional reach logic also handles session gaps that jump completely
        // across the remaining zone. Strict comparisons avoid treating the
        // creation bar's exact boundary as an immediate retest.
        bool intersects =
             side == 1
             ? low < remainingTop
             : high > remainingBottom

        bool enteredZone =
             intersects and
             not wasInside

        // A new retest closes the prior observation window first, so one market
        // interaction cannot contaminate the reaction score of the next one.
        if enteredZone and reactionWatching
            finalizeReaction(i)
            reactionWatching := false

        float ratioBeforeMitigation =
             zoneRemainingRatio(i)

        if enteredZone
            array.set(
                 zoneRetestCount,
                 i,
                 array.get(zoneRetestCount, i) + 1)

            array.set(
                 zoneTestStartRatio,
                 i,
                 ratioBeforeMitigation)

        if intersects
            array.set(zoneLastInteraction, i, bar_index)

            if side == 1
                float newRemainingTop =
                     math.max(
                          originalBottom,
                          math.min(remainingTop, low))

                array.set(
                     zoneRemainingTop,
                     i,
                     newRemainingTop)

                remainingTop := newRemainingTop

            else
                float newRemainingBottom =
                     math.min(
                          originalTop,
                          math.max(remainingBottom, high))

                array.set(
                     zoneRemainingBottom,
                     i,
                     newRemainingBottom)

                remainingBottom := newRemainingBottom

        float originalHeight =
             math.max(
                  originalTop - originalBottom,
                  syminfo.mintick)

        float remainingHeight =
             math.max(
                  remainingTop - remainingBottom,
                  0.0)

        float remainingRatio =
             clamp(
                  remainingHeight / originalHeight,
                  0.0,
                  1.0)

        // Evaluate touch visibility AFTER mitigation / retest registration.
        // This allows a hidden Fresh zone to become eligible on its first retest.
        if enteredZone
            if wasVisiblePrevious or zoneIsVisibleCandidate(i, atrSafe)
                touchEvent := true

        bool reachedMidpoint =
             remainingRatio <= 0.50

        if reachedMidpoint and not midpointHit
            array.set(zoneMidpointHit, i, true)

            if wasVisiblePrevious or zoneIsVisibleCandidate(i, atrSafe)
                midpointEvent := true

        bool fullyFilled =
             remainingHeight <= syminfo.mintick

        if fullyFilled
            if wasVisiblePrevious or zoneIsVisibleCandidate(i, atrSafe)
                filledEvent := true

            deleteZone(i)

            i -= 1
            continue

        // When price stops reaching into the remaining zone, begin a bounded
        // observation window. The resulting Reaction Quality combines:
        //   55% favorable move away from the zone,
        //   20% speed, scaled by how much favorable movement occurred,
        //   25% retained zone area after the interaction.
        bool interactionEnded =
             wasInside and
             not intersects

        if interactionEnded
            float initialMoveATR =
                 side == 1
                 ? math.max(close - remainingTop, 0.0) / atrSafe
                 : math.max(remainingBottom - close, 0.0) / atrSafe

            array.set(zoneReactionWatching, i, true)
            array.set(zoneReactionStartBar, i, bar_index)
            array.set(zoneReactionBestMove, i, initialMoveATR)
            array.set(zoneReactionBestBar, i, bar_index)
            array.set(zoneReactionPostRatio, i, remainingRatio)

            reactionWatching := true

        // Continue observing reaction quality only while price remains away
        // from the zone. Re-entry finalizes the old observation above.
        if reactionWatching and not intersects
            float reactionMoveATR =
                 side == 1
                 ? math.max(close - remainingTop, 0.0) / atrSafe
                 : math.max(remainingBottom - close, 0.0) / atrSafe

            float bestMoveATR =
                 array.get(zoneReactionBestMove, i)

            if reactionMoveATR > bestMoveATR
                array.set(zoneReactionBestMove, i, reactionMoveATR)

                // Speed measures how quickly the response reaches its useful
                // displacement target. Once the move cap has been reached,
                // later continuation must not make the reaction look slower.
                if bestMoveATR < reactionMoveCapATR
                    array.set(zoneReactionBestBar, i, bar_index)

            int reactionStart =
                 array.get(zoneReactionStartBar, i)

            if bar_index - reactionStart >= reactionWindow
                finalizeReaction(i)
                reactionWatching := false

        // Keep one continuous interaction active while price continues through
        // the zone. A later Touch requires price to stop reaching into the
        // remaining zone first.
        array.set(zoneWasInside, i, intersects)

        int lifecycleAfter =
             zoneLifecycleCode(i)

        if lifecycleAfter != lifecycleBefore
            bool lifecycleVisible =
                 wasVisiblePrevious or
                 zoneIsVisibleCandidate(i, atrSafe)

            if lifecycleVisible
                if lifecycleAfter == 2
                    responsiveEvent := true
                else if lifecycleAfter == 3
                    weakeningEvent := true

        i -= 1

// ─────────────────────────────────────────────────────────────────────────────
// CANDIDATE-POOL SAFETY + VISIBILITY SNAPSHOT
// ─────────────────────────────────────────────────────────────────────────────

if engineReady and barstate.isconfirmed
    pruneSide(1, atrSafe)
    pruneSide(-1, atrSafe)

    int snapshotCount =
         array.size(zoneSide)

    if snapshotCount > 0
        for i = 0 to snapshotCount - 1
            array.set(
                 zoneVisibleConfirmed,
                 i,
                 zoneIsVisibleCandidate(i, atrSafe))

// ─────────────────────────────────────────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────────────────────────────────────────

int zoneCount =
     array.size(zoneSide)

if barstate.islast and zoneCount > 0
    for i = 0 to zoneCount - 1
        float originalTop = array.get(zoneOriginalTop, i)
        float originalBottom = array.get(zoneOriginalBottom, i)
        float remainingTop = array.get(zoneRemainingTop, i)
        float remainingBottom = array.get(zoneRemainingBottom, i)
        int side = array.get(zoneSide, i)

        float remainingRatio =
             zoneRemainingRatio(i)

        int lifecycle =
             zoneLifecycleCode(i)

        string state =
             zoneLifecycleName(lifecycle)

        float averageReaction =
             zoneReactionAverage(i)

        float latestReaction =
             array.get(zoneLastReaction, i)

        int reactionCount =
             array.get(zoneReactionCount, i)

        float displayedReaction =
             reactionCount > 0
             ? averageReaction * 0.40 + latestReaction * 0.60
             : 0.0

        color sideColor =
             side == 1
             ? WIZ_BULL
             : WIZ_BEAR

        bool visibleZone =
             showZones and
             zoneIsVisibleCandidate(i, atrSafe)

        box b =
             array.get(zoneBoxes, i)

        box.set_top(
             b,
             remainingTop)

        box.set_bottom(
             b,
             remainingBottom)

        box.set_extend(
             b,
             extendZonesRight
             ? extend.right
             : extend.none)

        if not extendZonesRight
            box.set_right(
                 b,
                 bar_index)

        int adjustedTransparency =
             lifecycle == 3
             ? math.min(zoneFillTransparency + 5, 100)
             : lifecycle == 2
             ? math.max(zoneFillTransparency - 4, 0)
             : zoneFillTransparency

        box.set_bgcolor(
             b,
             visibleZone
             ? color.new(sideColor, adjustedTransparency)
             : na)

        box.set_border_color(
             b,
             visibleZone and showZoneBorders
             ? color.new(sideColor, 55)
             : na)

        line mid =
             array.get(zoneMidLines, i)

        bool midpointHit =
             array.get(zoneMidpointHit, i)

        float midpoint =
             (originalTop + originalBottom) * 0.50

        line.set_y1(
             mid,
             midpoint)

        line.set_y2(
             mid,
             midpoint)

        line.set_extend(
             mid,
             extendZonesRight
             ? extend.right
             : extend.none)

        if not extendZonesRight
            line.set_x2(
                 mid,
                 bar_index)

        line.set_color(
             mid,
             visibleZone and showMidpoint and not midpointHit
             ? color.new(sideColor, 35)
             : na)

        label oldLabel =
             array.get(zoneLabels, i)

        bool wantLabel =
             visibleZone and
             labelMode != "Off"

        if wantLabel
            string sideText =
                 side == 1
                 ? "BULL"
                 : "BEAR"

            int openPct =
                 int(math.round(remainingRatio * 100.0))

            int reactionPct =
                 int(
                      math.round(
                           clamp(displayedReaction, 0.0, 1.0) * 100.0))

            string reactionText =
                 reactionCount > 0
                 ? " · RQ " + str.tostring(reactionPct)
                 : ""

            string labelText =
                 labelMode == "Detailed"
                 ? sideText + " · " + state + " · " + str.tostring(openPct) + "% open" + reactionText
                 : sideText

            float labelY =
                 (remainingTop + remainingBottom) * 0.50

            if na(oldLabel)
                label newLabel = label.new(
                     x=bar_index + 1,
                     y=labelY,
                     text=labelText,
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     style=label.style_label_left,
                     color=color.new(sideColor, 18),
                     textcolor=color.white,
                     size=size.tiny)

                array.set(
                     zoneLabels,
                     i,
                     newLabel)

            else
                label.set_x(
                     oldLabel,
                     bar_index + 1)

                label.set_y(
                     oldLabel,
                     labelY)

                label.set_text(
                     oldLabel,
                     labelText)

                label.set_color(
                     oldLabel,
                     color.new(sideColor, 18))

                label.set_textcolor(
                     oldLabel,
                     color.white)

        else
            if not na(oldLabel)
                label.delete(oldLabel)

                array.set(
                     zoneLabels,
                     i,
                     na)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(
     newBullishEvent,
     "New Bullish Imbalance",
     "WizTrader Imbalance Map: a new qualified bullish imbalance was confirmed.")

alertcondition(
     newBearishEvent,
     "New Bearish Imbalance",
     "WizTrader Imbalance Map: a new qualified bearish imbalance was confirmed.")

alertcondition(
     newBullishEvent or newBearishEvent,
     "Any New Imbalance",
     "WizTrader Imbalance Map: a new qualified imbalance was confirmed.")

alertcondition(
     touchEvent,
     "Imbalance Touch",
     "WizTrader Imbalance Map: price entered a currently relevant imbalance zone.")

alertcondition(
     midpointEvent,
     "Imbalance 50% Reached",
     "WizTrader Imbalance Map: price reached the 50% level of a currently relevant imbalance zone.")

alertcondition(
     filledEvent,
     "Imbalance Filled",
     "WizTrader Imbalance Map: a currently relevant imbalance zone was fully filled.")

alertcondition(
     responsiveEvent,
     "Imbalance Responsive",
     "WizTrader Imbalance Map: a currently relevant imbalance developed a responsive reaction profile.")

alertcondition(
     weakeningEvent,
     "Imbalance Weakening",
     "WizTrader Imbalance Map: a currently relevant imbalance moved into a weakening state.")
````
