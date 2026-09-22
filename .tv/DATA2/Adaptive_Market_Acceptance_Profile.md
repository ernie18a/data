<!-- tradingview-pine-id: PUB;35b4cf3b74124f449c9787123e056467 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Market Acceptance Profile

Source: https://www.tradingview.com/script/Wxdvf9wW-Adaptive-Market-Acceptance-Profile/

## Description

Adaptive Market Acceptance Profile

The Adaptive Market Acceptance Profile is a price-behavior framework designed to visualize where the market has demonstrated sustained acceptance across a configurable historical window.

Rather than measuring activity only through raw volume concentration, the profile studies how consistently price occupies, revisits, and retains individual price regions. The result is a spatial map separating stronger acceptance areas from transitional and lower-retention regions.

At the center of the framework is the Acceptance Core — the price region carrying the strongest combined acceptance evidence within the active profile.

The engine also tracks whether this core structure is migrating higher, migrating lower, or remaining relatively stable.

🔶 MARKET ACCEPTANCE

Markets do not interact with every price equally.

Some regions are visited briefly before price moves away. Other regions repeatedly attract price, retain closes, and remain involved in market activity across the observation window.

The indicator organizes these differences into an adaptive horizontal profile.

Instead of asking only:

“Where did activity occur?”

the framework asks:

“Where has price demonstrated sustained acceptance?”

This distinction allows the profile to describe the structure of price acceptance rather than functioning as a conventional volume-at-price display.

🔹 Acceptance Profile

The visible horizontal profile divides the observed price range into adaptive price regions.

Each region is evaluated using multiple components of price behavior, including:

Occupancy — how consistently price interacts with the region.

Retention — the degree to which price remains associated with the region rather than immediately moving away.

Revisits — repeated interaction with previously occupied price areas.

These components are combined into a relative acceptance measurement.

Longer and more prominent profile rows represent areas carrying stronger acceptance evidence within the current observation window.

The profile is therefore comparative: it describes how acceptance is distributed across the analyzed range rather than assigning a probability to an individual level.

🔹 Acceptance Core

The Acceptance Core identifies the strongest acceptance concentration detected by the engine.

It acts as the principal structural reference of the profile and is highlighted separately from surrounding regions.

The Acceptance Core should not automatically be interpreted as support, resistance, a price target, or an expected reversal point.

Instead, it answers a different question:

Where has the strongest sustained price acceptance developed within the observed structure?

Current price can move significantly away from the Acceptance Core while the historical acceptance structure remains valid.

🔹 Acceptance Migration

Acceptance is not necessarily stationary.

As new market information enters the observation window, the dominant acceptance structure can gradually relocate.

The engine therefore monitors the evolution of the Acceptance Core and classifies its migration as:

MIGRATING HIGHER — acceptance structure is progressively developing at higher prices.

MIGRATING LOWER — acceptance structure is progressively developing at lower prices.

STABLE — displacement of the dominant acceptance structure is limited.

Migration describes the movement of observed acceptance. It is not a directional forecast.

🔹 Retention Context

The indicator evaluates how effectively price remains associated with its accepted regions.

Retention is summarized into contextual states such as:

HIGH
MODERATE
LOW

Higher retention indicates that price has demonstrated stronger persistence around the active acceptance structure.

Lower retention indicates weaker persistence or a more transitional environment.

These classifications describe observed market behavior and should not be interpreted as trade signals.

🔹 Revisit Evidence

Repeated interaction can provide additional information about whether a price region remains structurally relevant.

The Revisits measurement summarizes this behavior relative to the current profile environment.

A region repeatedly involved in price interaction can accumulate different acceptance characteristics from a region visited only briefly.

Revisit evidence is evaluated together with occupancy and retention rather than being treated as an independent signal.

🔶 ADAPTIVE VISUAL FRAMEWORK

The profile uses a controlled visual hierarchy designed to keep the underlying chart readable.

Stronger acceptance regions receive greater visual emphasis, while weaker or low-relevance regions are progressively reduced.

A relevance gate also suppresses distant regions when their evidence is insufficient to justify prominent display.

Strong historical acceptance can remain visible when its evidence remains meaningful.

This prevents the profile from simply following current price while also limiting unnecessary historical clutter.

The Acceptance Core remains the primary visual reference.

🔶 MARKET STATE DASHBOARD

The compact dashboard summarizes the active profile through five components:

STATE — current acceptance condition.

RETENTION — persistence of price within the active structure.

REVISITS — relative repeated interaction.

MIGRATION — movement of the dominant acceptance structure.

ACCEPTANCE CORE — price of the strongest detected acceptance concentration.

The dashboard is intended to summarize the profile—not replace interpretation of the underlying chart.

🔶 METHODOLOGY

The engine follows the analytical sequence:

Price Distribution → Occupancy → Retention → Revisit Evidence → Relative Acceptance → Acceptance Core → Core Migration

The observed price range is divided into multiple regions.

Historical price interaction is then evaluated within those regions and converted into relative acceptance evidence.

The strongest qualifying concentration becomes the active Acceptance Core.

As the observation window evolves, changes in that dominant region are used to evaluate Acceptance Migration.

Because the framework is adaptive, its profile can change as older observations leave the calculation window and new market behavior enters it.

🔶 HOW TO INTERPRET THE PROFILE

The indicator is designed for contextual analysis rather than mechanical entries.

For example, traders can study whether:

price is operating inside or outside its strongest accepted region;

acceptance is becoming concentrated or fragmented;

the dominant acceptance structure is migrating;

current price has separated significantly from the established Acceptance Core;

or a previously important acceptance region continues to retain structural relevance.

These observations can then be combined with independent market-structure, volatility, trend, execution, and risk-management analysis.

🔶 SETTINGS

Lookback / Observation Window

Controls how much historical price behavior contributes to the active acceptance structure.

Profile Rows

Controls the vertical resolution used to divide the analyzed price range.

More rows provide greater spatial granularity, while fewer rows create a broader structural representation.

Profile Width

Controls the maximum horizontal footprint of the acceptance profile.

Relevance Filtering

Controls how aggressively weaker or distant acceptance regions are visually suppressed.

Visual settings allow the profile, Acceptance Core, text, and dashboard to remain readable across different chart themes.

🔶 CONFIRMATION & LIMITATIONS

Adaptive Market Acceptance Profile is derived from historical chart information.

It does not display exchange order-book liquidity and should not be interpreted as a Level II/order-flow representation.

Acceptance is an internally calculated behavioral measurement rather than a probability of future price movement.

The Acceptance Core does not guarantee support, resistance, reversal, continuation, or future return to that price.

Migration describes changes in historical acceptance structure; it does not predict market direction.

Results can vary with instrument, timeframe, observation length, volatility regime, and available market data.

The indicator does not provide automated buy or sell recommendations.

🔶 ORIGINALITY

Adaptive Market Acceptance Profile was independently developed as a behavioral price-acceptance framework.

Its central objective is to measure and visualize persistent acceptance across price regions, rather than reproduce a conventional volume profile or represent exchange-level order flow.

The combination of occupancy, retention, revisit evidence, adaptive relevance filtering, Acceptance Core identification, and Acceptance Migration creates the indicator's analytical framework.

The visual profile is used as a spatial representation of that framework rather than as a conventional volume-at-price histogram.

Release Notes — v1.2

Initial public release

Adaptive acceptance distribution across price regions.

Occupancy, retention, and revisit-based acceptance framework.

Acceptance Core identification.

Higher / Lower / Stable Acceptance Migration.

Adaptive relevance filtering for distant low-information regions.

Controlled profile hierarchy for reduced chart clutter.

Compact market-state dashboard.

Cross-market visual validation performed across equities, metals, cryptocurrency, and FX.

---

## Source Code

````pine
//@version=6
indicator("Adaptive Market Acceptance Profile", shorttitle="ACCEPTANCE PROFILE", overlay=true, max_boxes_count=350, max_lines_count=120, max_labels_count=80)

// Adaptive Market Acceptance Profile v1.2 — relevance gate QA
// Independent market-behavior framework.
// Core question: where has price demonstrated sustained acceptance versus poor retention?
// This is a chart-derived analytical proxy, not exchange volume-at-price, order-book liquidity,
// probability, a trading signal, or a forecast.

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
G1 = "Acceptance Engine"
lookback     = input.int(140, "Calculation Lookback", minval=50, maxval=350, group=G1)
rows         = input.int(24, "Adaptive Price Rows", minval=12, maxval=34, group=G1)
atrLen       = input.int(14, "ATR Length", minval=5, maxval=60, group=G1)
revisitGap   = input.int(4, "Independent Revisit Gap", minval=2, maxval=15, group=G1)
closeWeight  = input.float(0.36, "Close Retention Weight", minval=0.10, maxval=0.60, step=0.02, group=G1)
dwellWeight  = input.float(0.34, "Dwell Weight", minval=0.10, maxval=0.60, step=0.02, group=G1)
revisitWeight= input.float(0.30, "Revisit Weight", minval=0.10, maxval=0.60, step=0.02, group=G1)

G2 = "Migration"
migrationLen = input.int(35, "Core Migration Comparison", minval=15, maxval=100, group=G2)
migrateATR   = input.float(0.30, "Migration Threshold (ATR)", minval=0.10, maxval=1.50, step=0.05, group=G2)

G3 = "Profile Geometry"
widthBars    = input.int(22, "Profile Width", minval=12, maxval=45, group=G3)
rightOffset  = input.int(5, "Right Offset", minval=3, maxval=20, group=G3)
smoothRad    = input.int(1, "Row Smoothing Radius", minval=0, maxval=3, group=G3)
minDisplay    = input.float(0.30, "Minimum Relative Acceptance", minval=0.10, maxval=0.65, step=0.05, group=G3)
heroThreshold= input.float(0.70, "Strong Acceptance Threshold", minval=0.50, maxval=0.90, step=0.05, group=G3)
relevanceATR = input.float(3.25, "Active Relevance Radius (ATR)", minval=1.50, maxval=8.00, step=0.25, group=G3)
farKeep      = input.float(0.72, "Far-Row Keep Threshold", minval=0.55, maxval=0.95, step=0.05, group=G3)

G4 = "Visuals"
showProfile  = input.bool(true, "Acceptance Profile", group=G4)
showCore     = input.bool(true, "Acceptance Core", group=G4)
showRejected = input.bool(true, "Low-Retention Rows", group=G4)
showCard     = input.bool(true, "Dashboard", group=G4)
showCoreLine = input.bool(true, "Acceptance Core Reference", group=G4)

//------------------------------------------------------------------------------
// Theme — tuned for deep navy / violet TradingView charts
//------------------------------------------------------------------------------
NAVY       = color.rgb(14, 8, 54)
NAVY_2     = color.rgb(22, 14, 72)
NAVY_3     = color.rgb(30, 21, 88)
PURPLE     = color.rgb(125, 88, 220)
PURPLE_SOFT= color.rgb(157, 126, 236)
TEAL       = color.rgb(55, 188, 166)
TEAL_SOFT  = color.rgb(93, 211, 189)
AMBER      = color.rgb(229, 169, 69)
RED_SOFT   = color.rgb(214, 100, 100)
WHITE      = color.rgb(245, 244, 250)
MUTED      = color.rgb(187, 181, 211)
NEUTRAL    = color.rgb(119, 111, 151)

clamp01(float x) => math.max(0.0, math.min(1.0, x))

atr = ta.atr(atrLen)
atrSafe = math.max(atr, syminfo.mintick)

//------------------------------------------------------------------------------
// Rolling behavioral observations
//------------------------------------------------------------------------------
// Retention: closes that remain near representative price rather than rejecting away.
// Dwell: repeated bar occupancy around a price region.
// Revisits: separated returns to a region, reducing the effect of one continuous cluster.
// Adaptive quantile rows keep the profile focused on actually occupied prices.

var box[] profileBoxes = array.new_box()
var line[] profileLines = array.new_line()
var label[] profileLabels = array.new_label()
var box coreBox = na
var line coreLine = na

clearVisuals() =>
    if array.size(profileBoxes) > 0
        for i = 0 to array.size(profileBoxes) - 1
            box.delete(array.get(profileBoxes, i))
    array.clear(profileBoxes)
    if array.size(profileLines) > 0
        for i = 0 to array.size(profileLines) - 1
            line.delete(array.get(profileLines, i))
    array.clear(profileLines)
    if array.size(profileLabels) > 0
        for i = 0 to array.size(profileLabels) - 1
            label.delete(array.get(profileLabels, i))
    array.clear(profileLabels)

var float acceptanceCore = na
var float acceptanceScore = na
var float retentionScore = na
var float revisitScore = na
var string acceptanceState = "WAITING"
var string migrationState = "WAITING"

if barstate.islast
    clearVisuals()
    if not na(coreBox)
        box.delete(coreBox)
        coreBox := na
    if not na(coreLine)
        line.delete(coreLine)
        coreLine := na

    float[] obsPx = array.new_float()
    float[] obsClose = array.new_float()
    float[] obsRange = array.new_float()
    int[] obsBar = array.new_int()

    for j = 0 to lookback - 1
        if not na(hlc3[j]) and not na(atr[j])
            array.push(obsPx, hlc3[j])
            array.push(obsClose, close[j])
            array.push(obsRange, math.max(high[j] - low[j], syminfo.mintick))
            array.push(obsBar, bar_index - j)

    nObs = array.size(obsPx)
    float[] sortedPx = array.copy(obsPx)
    array.sort(sortedPx, order.ascending)
    float[] qLo = array.new_float(rows, na)
    float[] qHi = array.new_float(rows, na)

    if nObs > 0
        for i = 0 to rows - 1
            loIdx = math.max(0, math.min(nObs - 1, int(math.floor(float(i) / rows * (nObs - 1)))))
            hiIdx = math.max(0, math.min(nObs - 1, int(math.ceil(float(i + 1) / rows * (nObs - 1)))))
            loPx = array.get(sortedPx, loIdx)
            hiPx = array.get(sortedPx, hiIdx)
            minH = atrSafe * 0.11
            if hiPx - loPx < minH
                mid = (hiPx + loPx) * 0.5
                loPx := mid - minH * 0.5
                hiPx := mid + minH * 0.5
            array.set(qLo, i, loPx)
            array.set(qHi, i, hiPx)

    float[] dwell = array.new_float(rows, 0.0)
    float[] retain = array.new_float(rows, 0.0)
    float[] rejects = array.new_float(rows, 0.0)
    int[] counts = array.new_int(rows, 0)
    int[] revisits = array.new_int(rows, 0)
    int[] lastVisit = array.new_int(rows, na)

    if nObs > 0
        // Iterate oldest -> newest for clean revisit counting.
        for jj = nObs - 1 to 0
            px = array.get(obsPx, jj)
            cl = array.get(obsClose, jj)
            rg = array.get(obsRange, jj)
            b = array.get(obsBar, jj)
            int idx = rows - 1
            for i = 0 to rows - 1
                if px >= array.get(qLo, i) and px <= array.get(qHi, i)
                    idx := i
                    break

            rowMid = (array.get(qLo, idx) + array.get(qHi, idx)) * 0.5
            rowHalf = math.max((array.get(qHi, idx) - array.get(qLo, idx)) * 0.5, syminfo.mintick)
            closeDist = math.abs(cl - rowMid) / math.max(rowHalf + rg * 0.35, syminfo.mintick)
            ret = clamp01(1.0 - closeDist)
            rej = clamp01(closeDist - 0.35)

            array.set(dwell, idx, array.get(dwell, idx) + 1.0)
            array.set(retain, idx, array.get(retain, idx) + ret)
            array.set(rejects, idx, array.get(rejects, idx) + rej)
            array.set(counts, idx, array.get(counts, idx) + 1)

            prev = array.get(lastVisit, idx)
            if na(prev) or b - prev >= revisitGap
                array.set(revisits, idx, array.get(revisits, idx) + 1)
            array.set(lastVisit, idx, b)

    maxDwell = 0.0
    maxRevisit = 0.0
    for i = 0 to rows - 1
        maxDwell := math.max(maxDwell, array.get(dwell, i))
        maxRevisit := math.max(maxRevisit, float(array.get(revisits, i)))

    float[] rawAcceptance = array.new_float(rows, 0.0)
    float[] smoothAcceptance = array.new_float(rows, 0.0)
    float[] rowRetention = array.new_float(rows, 0.0)
    float[] rowRevisit = array.new_float(rows, 0.0)

    wSum = math.max(closeWeight + dwellWeight + revisitWeight, 0.01)
    for i = 0 to rows - 1
        cnt = array.get(counts, i)
        d = maxDwell > 0 ? array.get(dwell, i) / maxDwell : 0.0
        r = cnt > 0 ? array.get(retain, i) / cnt : 0.0
        rv = maxRevisit > 0 ? float(array.get(revisits, i)) / maxRevisit : 0.0
        // Penalize rows characterized by repeated close-away behavior.
        rejectPenalty = cnt > 0 ? clamp01(array.get(rejects, i) / cnt) : 0.0
        score = clamp01((dwellWeight * d + closeWeight * r + revisitWeight * rv) / wSum - rejectPenalty * 0.18)
        array.set(rawAcceptance, i, score)
        array.set(rowRetention, i, r)
        array.set(rowRevisit, i, rv)

    maxAcc = 0.0
    domIdx = 0
    for i = 0 to rows - 1
        sm = 0.0
        wt = 0.0
        for k = -smoothRad to smoothRad
            ni = i + k
            if ni >= 0 and ni < rows and array.get(counts, ni) > 0
                w = float(smoothRad + 1 - math.abs(k))
                sm += array.get(rawAcceptance, ni) * w
                wt += w
        sm := wt > 0 ? sm / wt : array.get(rawAcceptance, i)
        array.set(smoothAcceptance, i, sm)
        if sm > maxAcc
            maxAcc := sm
            domIdx := i

    domLo = nObs > 0 ? array.get(qLo, domIdx) : close
    domHi = nObs > 0 ? array.get(qHi, domIdx) : close
    acceptanceCore := (domLo + domHi) * 0.5
    acceptanceScore := maxAcc
    retentionScore := array.get(rowRetention, domIdx)
    revisitScore := array.get(rowRevisit, domIdx)

    // State is contextual: high acceptance = sustained occupancy/retention/revisits.
    acceptanceState := maxAcc >= 0.68 ? "ACCEPTED" : maxAcc >= 0.46 ? "TRANSITION" : "LOW ACCEPTANCE"

    // Compare current core with an older occupied-price center as a stable migration proxy.
    olderCount = math.min(migrationLen, math.max(0, nObs - migrationLen))
    olderSum = 0.0
    if olderCount > 0
        for j = migrationLen to migrationLen + olderCount - 1
            if j < nObs
                olderSum += array.get(obsPx, j)
    olderCenter = olderCount > 0 ? olderSum / olderCount : acceptanceCore
    migrationDelta = acceptanceCore - olderCenter
    migrationState := migrationDelta > atrSafe * migrateATR ? "MIGRATING HIGHER" : migrationDelta < -atrSafe * migrateATR ? "MIGRATING LOWER" : "STABLE"

    profileRight = bar_index + rightOffset

    if showProfile and nObs > 0
        for i = 0 to rows - 1
            cnt = array.get(counts, i)
            if cnt > 0
                a = array.get(smoothAcceptance, i)
                norm = maxAcc > 0 ? a / maxAcc : 0.0
                ret = array.get(rowRetention, i)
                isDom = i == domIdx
                isLow = norm < 0.48 or ret < 0.35
                isHigh = norm >= heroThreshold and ret >= 0.50
                rowCenter = (array.get(qLo, i) + array.get(qHi, i)) * 0.5
                // Relevance gate: keep the active structural neighborhood compact.
                // Distant rows survive only when their acceptance evidence is genuinely strong.
                distCurrentATR = math.abs(rowCenter - close) / atrSafe
                distCoreATR = math.abs(rowCenter - acceptanceCore) / atrSafe
                locallyRelevant = math.min(distCurrentATR, distCoreATR) <= relevanceATR
                strongHistorical = norm >= farKeep and ret >= 0.50
                baseInformative = norm >= minDisplay or (showRejected and isLow and norm >= minDisplay * 0.82)
                displayRow = isDom or (baseInformative and locallyRelevant) or strongHistorical
                if displayRow
                    rowCol = isHigh ? TEAL : isLow ? RED_SOFT : PURPLE
                    wBars = math.max(3, int(math.round((0.10 + math.pow(norm, 1.35) * 0.90) * widthBars)))
                    rawBot = array.get(qLo, i)
                    rawTop = array.get(qHi, i)
                    rowMid = (rawBot + rawTop) * 0.5
                    rawHalf = math.abs(rawTop - rawBot) * 0.5
                    stripHalf = math.min(rawHalf * 0.30, atrSafe * 0.060)
                    stripHalf := math.max(stripHalf, syminfo.mintick * 2.0)
                    // Strong rows read clearly; transitional/weak rows recede into the navy chart.
                    borderFade = isDom ? 4 : isHigh ? 42 : isLow ? 74 : 68
                    fillFade = isDom ? 24 : isHigh ? 55 : isLow ? 82 : 76
                    bx = box.new(profileRight - wBars, rowMid + stripHalf, profileRight, rowMid - stripHalf,
                         xloc=xloc.bar_index,
                         border_color=color.new(rowCol, borderFade),
                         bgcolor=color.new(rowCol, fillFade),
                         border_width=isDom ? 2 : 1)
                    array.push(profileBoxes, bx)

    if showCore and nObs > 0
        half = math.max(math.min((domHi - domLo) * 0.28, atrSafe * 0.085), syminfo.mintick * 3.0)
        coreBox := box.new(profileRight - widthBars - 1, acceptanceCore + half, profileRight + 1, acceptanceCore - half,
             xloc=xloc.bar_index, border_color=color.new(AMBER, 5), border_width=1, bgcolor=color.new(AMBER, 88))
        coreLb = label.new(profileRight + 1, acceptanceCore,
             "ACCEPTANCE CORE  " + str.tostring(acceptanceCore, format.mintick),
             xloc=xloc.bar_index, style=label.style_label_left,
             color=color.new(NAVY_2, 8), textcolor=AMBER, size=size.tiny)
        array.push(profileLabels, coreLb)

    if showCoreLine and nObs > 0
        coreLine := line.new(math.max(0, bar_index - lookback + 1), acceptanceCore, profileRight, acceptanceCore,
             xloc=xloc.bar_index, color=color.new(AMBER, 34), width=1, style=line.style_dashed)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table card = table.new(position.top_right, 2, 6, bgcolor=NAVY, frame_color=color.new(PURPLE_SOFT, 48), frame_width=1, border_color=color.new(PURPLE, 72), border_width=1)

if barstate.islast
    if showCard
        stateCol = acceptanceState == "ACCEPTED" ? TEAL_SOFT : acceptanceState == "LOW ACCEPTANCE" ? RED_SOFT : PURPLE_SOFT
        retentionTxt = retentionScore >= 0.68 ? "HIGH" : retentionScore >= 0.45 ? "MODERATE" : "LOW"
        retentionCol = retentionScore >= 0.68 ? TEAL_SOFT : retentionScore >= 0.45 ? PURPLE_SOFT : RED_SOFT
        migrationCol = migrationState == "MIGRATING HIGHER" ? TEAL_SOFT : migrationState == "MIGRATING LOWER" ? RED_SOFT : PURPLE_SOFT

        table.cell(card, 0, 0, "ACCEPTANCE PROFILE", text_color=WHITE, bgcolor=NAVY_2, text_size=size.small)
        table.cell(card, 1, 0, "v1.2", text_color=PURPLE_SOFT, bgcolor=NAVY_2, text_size=size.small)
        table.cell(card, 0, 1, "STATE", text_color=MUTED, bgcolor=NAVY_3, text_size=size.small)
        table.cell(card, 1, 1, acceptanceState, text_color=stateCol, bgcolor=NAVY_2, text_size=size.small)
        table.cell(card, 0, 2, "RETENTION", text_color=MUTED, bgcolor=NAVY_3, text_size=size.small)
        table.cell(card, 1, 2, retentionTxt, text_color=retentionCol, bgcolor=NAVY_2, text_size=size.small)
        table.cell(card, 0, 3, "REVISITS", text_color=MUTED, bgcolor=NAVY_3, text_size=size.small)
        table.cell(card, 1, 3, str.tostring(revisitScore, "#.00"), text_color=WHITE, bgcolor=NAVY_2, text_size=size.small)
        table.cell(card, 0, 4, "MIGRATION", text_color=MUTED, bgcolor=NAVY_3, text_size=size.small)
        table.cell(card, 1, 4, migrationState, text_color=migrationCol, bgcolor=NAVY_2, text_size=size.small)
        table.cell(card, 0, 5, "CORE", text_color=MUTED, bgcolor=NAVY_3, text_size=size.small)
        table.cell(card, 1, 5, na(acceptanceCore) ? "—" : str.tostring(acceptanceCore, format.mintick), text_color=AMBER, bgcolor=NAVY_2, text_size=size.small)
    else
        table.clear(card, 0, 0, 1, 5)

//------------------------------------------------------------------------------
// Alerts — contextual state only
//------------------------------------------------------------------------------
coreCrossUp = barstate.isconfirmed and not na(acceptanceCore) and ta.crossover(close, acceptanceCore)
coreCrossDn = barstate.isconfirmed and not na(acceptanceCore) and ta.crossunder(close, acceptanceCore)
alertcondition(coreCrossUp, "Acceptance Core Cross Up", "Price crossed above the current Acceptance Core.")
alertcondition(coreCrossDn, "Acceptance Core Cross Down", "Price crossed below the current Acceptance Core.")
````
