# WizTrader Reaction Map

- url: https://www.tradingview.com/script/JL6gbzWO-WizTrader-Reaction-Map/
- type: indicator
- pine_id: PUB;8c5c3650efa7421ca6779f8f90dc4591
- version: 1.0

## Description

[b]WizTrader Reaction Map[/b] is an open-source support and resistance indicator that keeps a compact map of confirmed price-reaction zones around the current market.

[b]What it does[/b]

Confirmed swing pivots create support or resistance zones. Each zone is permanently anchored to the pivot that created it:

[list]
[*]Support starts at a confirmed pivot low and extends upward into the prior price area.
[*]Resistance starts at a confirmed pivot high and extends downward into the prior price area.
[/list]

The zone does not move or resize after creation. This keeps its visual origin tied to the candle that created it.

[b]Reaction counting[/b]

The label count has a strict meaning:

[list]
[*]1x = the original confirmed pivot.
[*]2x = the original pivot plus one later qualified revisit.
[*]3x = the original pivot plus two later qualified revisits.
[/list]

A later pivot inside an existing same-side zone does not add another reaction. It only prevents creation of a duplicate overlapping zone.

For a later entry to count as a new revisit, price must spend the full profile revisit interval in confirmed bars outside the zone. The revisit clock starts from the most recent confirmed bar that touched the zone, including bars between the original pivot and its later confirmation. A brief move outside and immediate return therefore remains part of the same interaction.

Each qualified revisit can contribute at most one rejection measurement. Rejection distance is measured from the near edge of the zone so the zone's own thickness is not counted as rejection strength.

[b]Zone classes[/b]

[list]
[*][b]Fresh[/b] - one confirmed reaction.
[*][b]Established[/b] - repeated interaction.
[*][b]Strong[/b] - multiple reactions and/or stronger rejection behavior.
[/list]

These classes describe recorded interaction with the zone. They are not predictions that a future reaction will occur.

[b]Current relevance[/b]

The script keeps a bounded internal pool of zones and ranks display candidates using:

[list]
[*]distance from current price, with proximity carrying the most weight
[*]reaction count, with its contribution capped
[*]average rejection quality
[*]recency of the latest interaction
[/list]

By default, two support zones and two resistance zones are shown. The display limit can be changed from one to five zones per side.

A zone removed by internal pool pruning is discarded and is not reconstructed later.

[b]Profiles[/b]

[list]
[*][b]Responsive[/b] - focuses on more local swing reactions.
[*][b]Balanced[/b] - the default middle ground.
[*][b]Major[/b] - focuses on broader swing structures.
[/list]

Profiles change pivot span, zone depth, revisit spacing, recency horizon, and break tolerance. They use the same reaction-zone model.

[b]Breaks and Role Flip[/b]

A zone is considered broken only after a confirmed close moves beyond its outer pivot edge by the profile-dependent break buffer.

[b]Role Flip is disabled by default[/b] to keep the map focused on currently intact zones. With Role Flip disabled, a confirmed broken zone is removed.

When Role Flip is enabled:

[list]
[*]confirmed broken resistance becomes support
[*]confirmed broken support becomes resistance
[/list]

A flipped zone keeps its original pivot anchor and price area. The script represents the current role of the zone, so a flipped zone is recolored/reclassified across its existing box rather than stored as a separate historical snapshot.

[b]Fresh Pivot Zones[/b]

Fresh Pivot Zones controls ordinary one-touch pivot zones. When disabled, those zones remain hidden until they receive a qualified revisit.

A confirmed Role Flip is treated separately from an ordinary fresh pivot zone and can remain display-eligible even when Fresh Pivot Zones is disabled. In Detailed label mode, a newly converted 1x zone is labeled Role Flip.

[b]Duplicate and opposite-side zones[/b]

A new same-side pivot zone is suppressed when its price area overlaps an existing same-side zone.

For an opposite-side candidate, overlap alone is not enough to suppress it. The new pivot wick itself must lie inside the existing opposite zone. This allows a new swing extreme just beyond an older zone to create its own reaction area, although partial support/resistance overlap can therefore occur.

[b]Display controls[/b]

Reaction Zones hides or shows the zone fills without disabling alerts.

Extend Zones Right controls whether visible zones project into the future chart area. When disabled, each zone ends at the current last bar and advances only as new bars appear. This setting is visual only and does not change reaction counting, ranking, breaks, Role Flip, or alerts.

Zone Borders can be disabled independently.

Zone Transparency changes fill transparency while preserving the small visual distinction between Fresh, Established, and Strong zones.

Labels can be Off, Minimal, or Detailed.

[b]Alerts[/b]

Available alert conditions:

[list]
[*]Reaction Zone Touch
[*]Reaction Zone Rejection
[*]Reaction Zone Break
[*]Reaction Zone Role Flip (requires Role Flip)
[/list]

Structural events use confirmed bars. Touch and rejection alerts follow zones selected by the current relevance map. Break and Role Flip alerts use the zone's visibility on the previous confirmed bar so the break itself does not remove the alert condition through a ranking change.

[b]What is original about this script[/b]

Reaction Map uses a purpose-built zone-management model rather than combining several named indicators. Its behavior is centered on fixed pivot-anchored geometry, qualified revisit counting, one-rejection-per-revisit scoring, current-price relevance ranking, a bounded candidate pool, duplicate-zone suppression, and optional role conversion after confirmed breaks.

[b]Limitations[/b]

This is a current-state reaction map, not a historical snapshot renderer. Deleted or pruned zones disappear from earlier chart areas, and a Role Flip updates the current role of an existing box.

Support and resistance are descriptive market structures. Historical reactions do not guarantee future reactions, and price can move through any zone.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// WizTrader Reaction Map
// Open-source support and resistance reaction-zone indicator.
//
// MODEL
//   Confirmed pivots create fixed zones anchored to the originating pivot wick.
//   Duplicate same-side pivot zones are suppressed.
//   Later reactions count only after price spends the full profile revisit
//   interval outside the zone and then enters it again.
//   Visible zones are ranked by proximity, reaction history, rejection quality,
//   and recency.
//   Confirmed breaks remove zones by default. Optional Role Flip can convert
//   broken resistance to support and broken support to resistance.
//
// Reaction zones describe historical price interaction. They are not predictions
// and do not guarantee that price will react again.

//@version=6
indicator(
     "WizTrader Reaction Map",
     shorttitle="WizReact",
     overlay=true,
     max_boxes_count=50,
     max_labels_count=50,
     explicit_plot_zorder=true)

// ─────────────────────────────────────────────────────────────────────────────
// WIZTRADER PALETTE
// ─────────────────────────────────────────────────────────────────────────────

color WIZ_BULL    = color.rgb(85, 134, 219)
color WIZ_BEAR    = color.rgb(172, 68, 203)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

groupDisplay = "Display"

showZones = input.bool(
     true,
     "Reaction Zones",
     tooltip="Shows the active support and resistance reaction zones. This setting controls chart display only; alerts remain active.",
     group=groupDisplay)

extendZonesRight = input.bool(
     true,
     "Extend Zones Right",
     tooltip="Extends visible zones into the future chart area. When disabled, zones end at the current last bar and continue forward only as new bars appear. This is visual only.",
     group=groupDisplay)

showZoneBorders = input.bool(
     true,
     "Zone Borders",
     tooltip="Shows the outer border lines of visible reaction zones. Turn this off for a cleaner filled-zone view.",
     group=groupDisplay)

zoneFillTransparency = input.int(
     85,
     "Zone Transparency",
     minval=0,
     maxval=100,
     step=1,
     tooltip="Controls zone fill transparency. 0 is fully opaque and 100 is fully transparent. Zone strength still creates a small visual difference around this base value.",
     group=groupDisplay)

labelMode = input.string(
     "Minimal",
     "Zone Labels",
     options=["Off", "Minimal", "Detailed"],
     tooltip="Controls the amount of information shown beside active zones.",
     group=groupDisplay)

maxZonesPerSide = input.int(
     2,
     "Zones per Side",
     minval=1,
     maxval=5,
     tooltip="Maximum number of currently relevant support zones and resistance zones shown on the chart.",
     group=groupDisplay)

groupBehavior = "Reaction Model"

profile = input.string(
     "Balanced",
     "Profile",
     options=["Responsive", "Balanced", "Major"],
     tooltip="Responsive finds more local reactions, Balanced is the default, and Major focuses on broader swing zones.",
     group=groupBehavior)

roleFlip = input.bool(
     false,
     "Role Flip",
     tooltip="Optional. When enabled, confirmed broken resistance becomes support and confirmed broken support becomes resistance. The zone keeps its original pivot anchor and price area. Disabled by default for a cleaner current-zone map.",
     group=groupBehavior)

showFreshPivotZones = input.bool(
     true,
     "Fresh Pivot Zones",
     tooltip="Shows ordinary one-touch zones created from confirmed pivots. Turn this off to show only revisited zones plus confirmed Role Flips. Role Flips are not treated as ordinary fresh pivot zones.",
     group=groupBehavior)

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE CALIBRATION
// ─────────────────────────────────────────────────────────────────────────────

int pivotSpan =
     profile == "Responsive" ? 3 :
     profile == "Major" ? 8 :
     5

float zoneWidthATR =
     profile == "Responsive" ? 0.22 :
     profile == "Major" ? 0.40 :
     0.30

int revisitGap =
     profile == "Responsive" ? 3 :
     profile == "Major" ? 6 :
     4

int freshnessBars =
     profile == "Responsive" ? 80 :
     profile == "Major" ? 240 :
     140

// With wick-edge anchoring the old break buffers became too shallow.
// These values restore more meaningful confirmation beyond the pivot extreme.
float breakBufferATR =
     profile == "Responsive" ? 0.15 :
     profile == "Major" ? 0.30 :
     0.20

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

zoneClass(int touches, float rejectionAvg) =>
    string cls = "Fresh"
    if touches >= 4 or (touches >= 3 and rejectionAvg >= 0.45)
        cls := "Strong"
    else if touches >= 2
        cls := "Established"
    cls

zoneTransparency(int touches, float rejectionAvg) =>
    string cls = zoneClass(touches, rejectionAvg)

    // 85 reproduces the original visual balance:
    // Fresh 91 / Established 85 / Strong 78.
    // Moving the slider shifts all classes together while preserving hierarchy.
    int transparency = math.min(zoneFillTransparency + 6, 100)

    if cls == "Strong"
        transparency := math.max(zoneFillTransparency - 7, 0)
    else if cls == "Established"
        transparency := zoneFillTransparency

    transparency

zoneBorderTransparency(int touches, float rejectionAvg) =>
    string cls = zoneClass(touches, rejectionAvg)
    int transparency = 68
    if cls == "Strong"
        transparency := 28
    else if cls == "Established"
        transparency := 48
    transparency

// ─────────────────────────────────────────────────────────────────────────────
// ZONE STORAGE
// ─────────────────────────────────────────────────────────────────────────────
//
// Side:
//   +1 = Support
//   -1 = Resistance

var array<float> zoneCenter      = array.new_float()
var array<float> zoneHalfWidth   = array.new_float()
var array<int>   zoneSide        = array.new_int()
var array<int>   zoneTouches     = array.new_int()
var array<float> zoneRejectSum   = array.new_float()
var array<int>   zoneLastTouch        = array.new_int()
var array<bool>  zoneWasInside        = array.new_bool()
var array<bool>  zoneRejectionCounted   = array.new_bool()
var array<bool>  zoneRoleFlipped        = array.new_bool()
var array<bool>  zoneVisibleConfirmed   = array.new_bool()
var array<box>   zoneBoxes              = array.new_box()
var array<label> zoneLabels           = array.new_label()

countSide(int wantedSide) =>
    int count = 0
    int n = array.size(zoneSide)
    if n > 0
        for i = 0 to n - 1
            if array.get(zoneSide, i) == wantedSide
                count += 1
    count

zoneDisplayEligible(int i) =>
    int touches = array.get(zoneTouches, i)
    bool flipped = array.get(zoneRoleFlipped, i)

    // "Fresh" in the zone class means one confirmed reaction.
    // The display setting applies only to ordinary pivot-created Fresh zones.
    // A confirmed Role Flip is a separate structural event and stays eligible.
    showFreshPivotZones or touches >= 2 or flipped

zonePriority(int i, float currentAtr) =>
    int touches = array.get(zoneTouches, i)
    float rejectAvg = array.get(zoneRejectSum, i) / math.max(touches, 1)
    int age = bar_index - array.get(zoneLastTouch, i)

    float center = array.get(zoneCenter, i)
    float half = array.get(zoneHalfWidth, i)
    float top = center + half
    float bottom = center - half
    int side = array.get(zoneSide, i)

    float distanceToZone =
         close > top
         ? close - top
         : close < bottom
         ? bottom - close
         : 0.0

    float distanceAtr =
         distanceToZone / math.max(currentAtr, syminfo.mintick)

    float proximityScore =
         16.0 / (1.0 + distanceAtr)

    float reactionScore =
         math.min(touches, 5) * 0.30

    float rejectionScore =
         clamp(rejectAvg / 0.75, 0.0, 1.0)

    float freshness =
         clamp(
              1.0 - age / math.max(freshnessBars * 1.0, 1.0),
              0.0,
              1.0)

    float freshnessScore =
         freshness * 1.20

    // Do not penalize a zone merely because price closes slightly beyond its
    // outer edge. Until the confirmed break threshold is crossed, it remains
    // fully eligible for ranking, display and subsequent break/flip alerts.
    proximityScore +
     reactionScore +
     rejectionScore +
     freshnessScore

deleteZone(int index) =>
    box b = array.get(zoneBoxes, index)
    label l = array.get(zoneLabels, index)

    box.delete(b)
    if not na(l)
        label.delete(l)

    array.remove(zoneCenter, index)
    array.remove(zoneHalfWidth, index)
    array.remove(zoneSide, index)
    array.remove(zoneTouches, index)
    array.remove(zoneRejectSum, index)
    array.remove(zoneLastTouch, index)
    array.remove(zoneWasInside, index)
    array.remove(zoneRejectionCounted, index)
    array.remove(zoneRoleFlipped, index)
    array.remove(zoneVisibleConfirmed, index)
    array.remove(zoneBoxes, index)
    array.remove(zoneLabels, index)

    true

poolLimitPerSide() =>
    math.max(8, maxZonesPerSide * 3)

pruneSide(int side, float currentAtr) =>
    int poolLimit = poolLimitPerSide()

    while countSide(side) > poolLimit
        int weakestIndex = -1
        float weakestPriority = 1e20

        int n = array.size(zoneCenter)
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
    bool eligible = zoneDisplayEligible(index)
    int side = array.get(zoneSide, index)
    float thisPriority = zonePriority(index, currentAtr)
    int betterCount = 0

    if eligible
        int n = array.size(zoneCenter)
        if n > 0
            for j = 0 to n - 1
                if j != index and array.get(zoneSide, j) == side and zoneDisplayEligible(j)
                    float otherPriority = zonePriority(j, currentAtr)

                    if otherPriority > thisPriority or (otherPriority == thisPriority and j < index)
                        betterCount += 1

    eligible and betterCount < maxZonesPerSide

// ─────────────────────────────────────────────────────────────────────────────
// BASE MEASURES
// ─────────────────────────────────────────────────────────────────────────────

float atr14 = ta.atr(14)
float atrSafe = na(atr14) or atr14 <= 0.0 ? math.max(high - low, syminfo.mintick) : atr14

float pivotHigh = ta.pivothigh(high, pivotSpan, pivotSpan)
float pivotLow  = ta.pivotlow(low, pivotSpan, pivotSpan)

bool engineReady =
     bar_index >= math.max(34, pivotSpan * 3) and
     not na(atr14)

// ─────────────────────────────────────────────────────────────────────────────
// CREATE NEW REACTION ZONE
// ─────────────────────────────────────────────────────────────────────────────

addZoneIfNew(float price, int side, float pivotAtr, float rejectionQuality, int pivotBar) =>
    // candidateHalf is half of the total zone depth. The pivot wick itself is
    // the OUTER edge of the zone:
    //   Support    -> pivot low is the lower edge; zone extends upward
    //   Resistance -> pivot high is the upper edge; zone extends downward
    float candidateHalf = math.max(pivotAtr * zoneWidthATR, syminfo.mintick * 2.0)
    float candidateCenter =
         side == 1
         ? price + candidateHalf
         : price - candidateHalf

    float candidateTop = candidateCenter + candidateHalf
    float candidateBottom = candidateCenter - candidateHalf

    bool sameSideOverlapFound = false
    bool oppositeOverlapFound = false

    int n = array.size(zoneCenter)
    if n > 0
        for i = 0 to n - 1
            float existingCenter = array.get(zoneCenter, i)
            float existingHalf = array.get(zoneHalfWidth, i)
            int existingSide = array.get(zoneSide, i)

            float existingTop = existingCenter + existingHalf
            float existingBottom = existingCenter - existingHalf

            bool overlaps =
                 candidateTop >= existingBottom and
                 candidateBottom <= existingTop

            bool sameSideOverlap =
                 existingSide == side and
                 overlaps

            bool oppositeOverlap =
                 existingSide != side and
                 price >= existingBottom and
                 price <= existingTop

            // A later confirmed pivot inside an existing same-side zone does
            // not add a reaction. It only prevents a duplicate overlapping zone.
            if sameSideOverlap
                sameSideOverlapFound := true

            // An opposite-side candidate is suppressed only when the pivot
            // wick tip itself lies inside the existing opposite zone. Partial
            // overlap alone is allowed so a new extreme can create its own zone.
            if oppositeOverlap
                oppositeOverlapFound := true

    if not sameSideOverlapFound and not oppositeOverlapFound
        color sideColor = side == 1 ? WIZ_BULL : WIZ_BEAR

        box b = box.new(
             left=pivotBar,
             top=candidateTop,
             right=bar_index,
             bottom=candidateBottom,
             xloc=xloc.bar_index,
             extend=extendZonesRight ? extend.right : extend.none,
             bgcolor=color.new(sideColor, 91),
             border_color=showZoneBorders ? color.new(sideColor, 68) : na,
             border_width=1)

        bool confirmationBarInside =
             high >= candidateBottom and
             low <= candidateTop

        // A pivot is confirmed pivotSpan bars after it occurred. Initialize the
        // revisit clock from the MOST RECENT bar between pivot and confirmation
        // that still intersected this new zone, not blindly from the pivot bar.
        int lastCreationTouchBar = pivotBar
        for offset = 0 to pivotSpan
            bool touchedDuringConfirmation =
                 high[offset] >= candidateBottom and
                 low[offset] <= candidateTop

            if touchedDuringConfirmation
                lastCreationTouchBar := bar_index - offset
                break

        array.push(zoneCenter, candidateCenter)
        array.push(zoneHalfWidth, candidateHalf)
        array.push(zoneSide, side)
        array.push(zoneTouches, 1)
        array.push(zoneRejectSum, rejectionQuality)
        array.push(zoneLastTouch, lastCreationTouchBar)
        array.push(zoneWasInside, confirmationBarInside)
        array.push(zoneRejectionCounted, true)
        array.push(zoneRoleFlipped, false)
        array.push(zoneVisibleConfirmed, false)
        array.push(zoneBoxes, b)
        array.push(zoneLabels, na)

        pruneSide(side, atrSafe)

    true

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMED PIVOTS -> ZONES
// ─────────────────────────────────────────────────────────────────────────────

if engineReady and barstate.isconfirmed
    if not na(pivotHigh)
        float pivotAtr = math.max(nz(atr14[pivotSpan], atrSafe), syminfo.mintick)
        float rejection =
             clamp((pivotHigh - close[pivotSpan]) / pivotAtr, 0.0, 2.0)

        addZoneIfNew(
             pivotHigh,
             -1,
             pivotAtr,
             rejection,
             bar_index - pivotSpan)

    if not na(pivotLow)
        float pivotAtr = math.max(nz(atr14[pivotSpan], atrSafe), syminfo.mintick)
        float rejection =
             clamp((close[pivotSpan] - pivotLow) / pivotAtr, 0.0, 2.0)

        addZoneIfNew(
             pivotLow,
             1,
             pivotAtr,
             rejection,
             bar_index - pivotSpan)

// ─────────────────────────────────────────────────────────────────────────────
// LIVE ZONE EVENTS
// ─────────────────────────────────────────────────────────────────────────────

bool touchEvent = false
bool rejectionEvent = false
bool breakEvent = false
bool roleFlipEvent = false

if engineReady and barstate.isconfirmed
    int i = array.size(zoneCenter) - 1

    while i >= 0
        float center = array.get(zoneCenter, i)
        float half = array.get(zoneHalfWidth, i)
        float top = center + half
        float bottom = center - half
        int side = array.get(zoneSide, i)
        int lastTouch = array.get(zoneLastTouch, i)
        bool wasInside = array.get(zoneWasInside, i)
        bool rejectionCounted = array.get(zoneRejectionCounted, i)
        bool wasVisiblePrevious = array.get(zoneVisibleConfirmed, i)

        bool intersects =
             high >= bottom and
             low <= top

        bool enteredZone =
             intersects and
             not wasInside and
             bar_index - lastTouch > revisitGap

        if enteredZone
            // This is the ONLY place where an existing zone gains a later touch.
            array.set(zoneTouches, i, array.get(zoneTouches, i) + 1)
            array.set(zoneLastTouch, i, bar_index)
            array.set(zoneRejectionCounted, i, false)
            rejectionCounted := false

            if zoneIsVisibleCandidate(i, atrSafe)
                touchEvent := true

        // Once a revisit has opened a rejection opportunity, the confirming
        // close may occur on a later bar that no longer physically overlaps
        // the zone. Count exactly one rejection for that revisit.
        bool supportReject =
             side == 1 and
             close > top

        bool resistanceReject =
             side == -1 and
             close < bottom

        bool canCountRejection =
             not rejectionCounted and
             (supportReject or resistanceReject)

        if canCountRejection
            float rejectionMove =
                 side == 1
                 ? clamp((close - top) / atrSafe, 0.0, 2.0)
                 : clamp((bottom - close) / atrSafe, 0.0, 2.0)

            array.set(zoneRejectSum, i, array.get(zoneRejectSum, i) + rejectionMove)
            array.set(zoneRejectionCounted, i, true)

            if wasVisiblePrevious or zoneIsVisibleCandidate(i, atrSafe)
                rejectionEvent := true

        float breakBuffer = math.max(atrSafe * breakBufferATR, syminfo.mintick * 2.0)

        bool brokenSupport =
             side == 1 and
             close < bottom - breakBuffer

        bool brokenResistance =
             side == -1 and
             close > top + breakBuffer

        bool broken = brokenSupport or brokenResistance

        if broken
            // Break relevance is based on whether the zone was part of the
            // visible map on the PREVIOUS confirmed bar. This avoids losing the
            // alert when the break itself changes current relevance ranking.
            if wasVisiblePrevious
                breakEvent := true

            if roleFlip
                int newSide = -side

                array.set(zoneSide, i, newSide)
                array.set(zoneTouches, i, 1)
                array.set(zoneRejectSum, i, 0.0)
                array.set(zoneLastTouch, i, bar_index)
                array.set(zoneWasInside, i, false)
                array.set(zoneRejectionCounted, i, true)
                array.set(zoneRoleFlipped, i, true)

                // Keep the original pivot anchor and price area. Role Flip
                // changes only the zone role/color, not its historical origin.
                if wasVisiblePrevious
                    roleFlipEvent := true
            else
                deleteZone(i)

                i -= 1
                continue

        bool insideNow =
             high >= bottom and
             low <= top

        array.set(zoneWasInside, i, insideNow)

        // Revisit spacing is measured from the LAST confirmed bar that was
        // inside the zone. Price must therefore spend the FULL revisitGap
        // confirmed bars outside before a new entry can increase the count.
        if insideNow
            array.set(zoneLastTouch, i, bar_index)

        i -= 1

// Candidate-pool safety pass. The visible ranking uses only eligible zones.
// Zones pruned from the bounded internal pool are permanently discarded.
if engineReady and barstate.isconfirmed
    pruneSide(1, atrSafe)
    pruneSide(-1, atrSafe)

    int visibleSnapshotCount = array.size(zoneCenter)
    if visibleSnapshotCount > 0
        for i = 0 to visibleSnapshotCount - 1
            array.set(
                 zoneVisibleConfirmed,
                 i,
                 zoneIsVisibleCandidate(i, atrSafe))

// ─────────────────────────────────────────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────────────────────────────────────────
//
// Zone price geometry and the original pivot anchor are fixed at creation.
// The visual pass may update right-side extension, visibility, styling and labels.

int zoneCount = array.size(zoneCenter)

if barstate.islast and zoneCount > 0
    for i = 0 to zoneCount - 1
        float center = array.get(zoneCenter, i)
        int side = array.get(zoneSide, i)
        int touches = array.get(zoneTouches, i)
        float rejectAvg = array.get(zoneRejectSum, i) / math.max(touches, 1)

        string cls = zoneClass(touches, rejectAvg)
        color sideColor = side == 1 ? WIZ_BULL : WIZ_BEAR

        bool visibleZone =
             showZones and
             zoneIsVisibleCandidate(i, atrSafe)

        box b = array.get(zoneBoxes, i)
        bool flipped = array.get(zoneRoleFlipped, i)

        box.set_extend(
             b,
             extendZonesRight
             ? extend.right
             : extend.none)

        if not extendZonesRight
            box.set_right(b, bar_index)

        box.set_bgcolor(
             b,
             visibleZone
             ? color.new(sideColor, zoneTransparency(touches, rejectAvg))
             : na)

        box.set_border_color(
             b,
             visibleZone and showZoneBorders
             ? color.new(sideColor, zoneBorderTransparency(touches, rejectAvg))
             : na)

        label oldLabel = array.get(zoneLabels, i)

        bool wantLabel =
             visibleZone and
             labelMode != "Off"

        if wantLabel
            string sideText = side == 1 ? "SUP" : "RES"

            string detailClass =
                 flipped and touches == 1
                 ? "Role Flip"
                 : cls

            string labelText =
                 labelMode == "Detailed"
                 ? sideText + " · " + detailClass + " · " + str.tostring(touches) + "×"
                 : sideText + " · " + str.tostring(touches) + "×"

            if na(oldLabel)
                label newLabel = label.new(
                     x=bar_index + 1,
                     y=center,
                     text=labelText,
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     style=label.style_label_left,
                     color=color.new(sideColor, 18),
                     textcolor=color.white,
                     size=size.tiny)

                array.set(zoneLabels, i, newLabel)
            else
                label.set_x(oldLabel, bar_index + 1)
                label.set_y(oldLabel, center)
                label.set_text(oldLabel, labelText)
                label.set_color(oldLabel, color.new(sideColor, 18))
                label.set_textcolor(oldLabel, color.white)
        else
            if not na(oldLabel)
                label.delete(oldLabel)
                array.set(zoneLabels, i, na)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(
     touchEvent,
     "Reaction Zone Touch",
     "WizTrader Reaction Map: price entered an active reaction zone.")

alertcondition(
     rejectionEvent,
     "Reaction Zone Rejection",
     "WizTrader Reaction Map: price rejected an active reaction zone.")

alertcondition(
     breakEvent,
     "Reaction Zone Break",
     "WizTrader Reaction Map: a confirmed close broke an active reaction zone.")

alertcondition(
     roleFlipEvent,
     "Reaction Zone Role Flip (requires Role Flip)",
     "WizTrader Reaction Map: a broken zone changed role between support and resistance. Requires Role Flip to be enabled.")
````
