# Value and Flow - Anchored Volume Profile and Order Flow

- url: https://www.tradingview.com/script/nOcQxcUo-Value-and-Flow-Anchored-Volume-Profile-and-Order-Flow/
- type: indicator
- pine_id: PUB;8ad6232330fe4bc58f7fa41b369c161e
- version: 1.0

## Description

[b]Value and Flow - Anchored Volume Profile and Order Flow[/b]

Value and Flow connects value, volume pressure and price response. The chart combines anchored profile, delta line, local auctions and flow markers; the lower pane contains Footprint Insights. Eleven controls cover start and visibility.

The central workflow is [b]area -> evidence -> closed response[/b]. A cloud, delta dot or touch supplies context. Confirmation requires qualifying evidence at a pre-existing area and the required closing response.

[b]What connects the layers[/b]

The anchored profile frames the selected range. The flow engine separately tests frozen local-auction boundaries, completed-profile levels, eligible delta POCs and earlier POCs. It reads the preceding close's area registry: levels must already exist before a test.

Qualifying evidence freezes the band and response deadline. Overlapping compatible sources merge; display ranking does not determine source lifetime. The causal engine, shared native-row measurements and bounded presentation connect and extend the credited reference methods.

[b]Reading the chart[/b]

[image]https://www.tradingview.com/x/lUd3urVd/[/image]

[i]Overview: the essential indicator on a real chart, with anchored profile, flow context and Footprint Insights.[/i]

[b]Anchored volume profile.[/b] Select a starting candle and drag TradingView's time marker to move it; the endpoint follows the newest bar. Defaults are 100 rows and 68% value area, with POC/VAH/VAL, developing POC and low-volume features. DGT-style allocation distributes source OHLCV volume by range overlap, using candle polarity for its up/down split. This approximation is distinct from native footprint measurements.

[b]Local auctions.[/b] One developing and two completed profiles track local value. Completed display windows stop at the next episode. Developing guides are separate from frozen auction boundaries. Moving the VP start changes display CVD without restarting auctions or structural divergence.

[b]Compact event legend:[/b]

[list]
[*][b]W↑ / W↓:[/b] pending flow watches.
[*][b]RC↑:[/b] lower-edge reclaim; [b]RJ↓:[/b] upper-edge rejection.
[*][b]H↑ / H↓:[/b] confirmed hold at an eligible centre.
[*][b]P / A / F / M:[/b] auction probe, acceptance, failed excursion and value migration. Their signs describe the attempted auction direction.
[/list]

Hover for source, evidence, band delta and response/invalidation thresholds. Historical responses retain their candle and tooltip; nearby matching responses use triangles while the latest keeps its caption.

[b]Yellow trails and DPOCs.[/b] Up to 192 yellow dots record confirmed auction POC references at original times, sampled every four candles; distant history fades. They do not identify untouched levels. DPOC is the strongest absolute signed net-delta row in a confirmed cluster, distinct from highest-total-volume POC. Two active DPOCs appear; touched levels fade, crossed or expired levels retire.

[b]Reading volume pressure[/b]

[b]Footprint Insights and the absorption cloud[/b] compare normalized smoothed delta with price movement, with volume weighting. Green shows positive pressure exceeding price results; red shows the opposite gap. These are absorption hypotheses, not observed passive orders or reversal promises. Spike profiles and dots represent aggregated native row delta, not individual trades.

[b]The chart delta line[/b] approximates signed volume from lower-timeframe direction, with SMA14 on minute-and-higher charts. One affine transformation maps the recent 180-bar segment into price space. Its height and candle intersections have no price-level meaning; it displays per-bar delta, not anchored CVD.

[b]FLOW[/b] shows native CVD since the VP start, current signed delta/volume pressure and qualified flow state. Structural divergence uses separate continuous CVD within intact coverage. Unavailable values show dashes, genuine zero remains valid and an asterisk marks partial anchored totals.

[b]Timing and confirmation[/b]

Localized pressure measures footprint-row overlap inside the test band. Selling at a lower test can support an upward watch; buying at an upper test can support a downward watch when price progress is insufficient or a rejection completes. Whole-bar delta can disagree.

A completed response can confirm on the evidence candle's close. Otherwise, a watch has three subsequent bars to respond; adverse extremes, lost sources, missing totals or expiry can cancel it. Formal divergence uses 8/8 price pivots, so discovery occurs eight right-side bars later. Late pivot evidence can support a current eligible test, but cannot backdate a confirmation or rewrite an earlier response.

[b]Hypothetical trade illustrations[/b]

Examples are hypothetical entry/risk/objective drawings, with no executed trades or backtest claims. Close-ups hide several layers for clarity. Tooltip invalidation is a closing condition, not a broker stop.

[b]Long illustration — completed POC hold.[/b] On SOLUSDT.P 5m, the 17:55 UTC candle on 13 October 2026 closed at 18:00 with H↑ at completed POC 107.06. Its native tooltip records delta mismatch, band delta -2.158K and an invalidating close below 107.00. The drawing starts after confirmation: entry 107.59, risk stop 106.85, objective 108.20; these are discretionary planning levels.

[image]https://www.tradingview.com/x/nDwl4yBn/[/image]

[i]Hypothetical long planning annotation; no executed trade or return is claimed.[/i]

[b]Short illustration — completed VAH rejection.[/b] On SOLUSDT.P 5m, a response confirmed at 08:20 UTC on 13 October 2026: RJ↓ at completed VAH 108.76. The native tooltip records delta mismatch, band delta +6.174K and an invalidating close above 108.81. The illustrative drawing starts after confirmation, with entry 108.71, risk stop 109.05 and objective 108.02. These are discretionary planning levels, not script-generated orders; touching VAH alone is insufficient.

[image]https://www.tradingview.com/x/tMgECLhL/[/image]

[i]Hypothetical short: entry 108.71, risk stop 109.05, objective 108.02. The drawing is not an executed trade or a return claim.[/i]

[b]Failed alternative.[/b] An adverse extreme, qualifying acceptance through the area or failure to close beyond the response threshold within the deadline invalidates or expires the watch. A cloud or delta dot cannot override that failure.

[b]Setup, access and limits[/b]

Add the indicator, choose the VP start and enable the layers you need. Three optional alerts cover upward flow, downward flow and confirmed auction events. Use Once Per Bar Close. Hiding drawings does not disable their conditions.

Footprint access requires TradingView Premium or Ultimate; see the [url=https://www.tradingview.com/pine-script-docs/concepts/other-timeframes-and-data/#requestfootprint]official documentation[/url]. Intrabar volume is categorized by price action, rather than exchange-audited aggressor executions or an order book. Developing values change live; data revisions can change recalculated history. Retention is bounded, and dense histories may show Heavy script warnings. No win-rate or return claim is made.

[b]Credits and source transparency[/b]

[list]
[*][url=https://www.tradingview.com/script/Qwj6TO5I-Volume-Profile-and-Volume-Indicator-by-DGT/]dgtrd / DGT[/url]: profile allocation and appearance.
[*]colicoid: [url=https://www.tradingview.com/script/xAEyGSIS-CVD-Divergence-Insights/]CVD Divergence Insights[/url] calculation (MPL 2.0) and [url=https://www.tradingview.com/script/kNUmhguZ-Cumulative-Volume-Delta-Line/]Cumulative Volume Delta Line[/url] chart-delta method.
[*][url=https://www.tradingview.com/script/tV3rCaJ9-Market-sessions-and-Volume-profile-By-Leviathan/]Leviathan / LeviathanCapital[/url]: local-profile appearance; MPL 2.0. Its reference also acknowledges LonesomeTheBlue's VP influence.
[*][url=https://www.tradingview.com/script/Vgitqk52-Order-Flow-Volume-Delta-CVD-Absorption-Divergence-LunqFX/]LunqFX[/url]: absorption/divergence concepts. Native footprint evidence and causal response rules replace the reference's range-based delta approach.
[*]Supplied [b]Auction Regime Engine 3.1.3[/b]: auction/DPOC foundations. The supplied file does not identify an author; no authorship is inferred.
[/list]

Open source allows inspection; reused notices remain. This is a market-analysis indicator without automated execution or performance promises.

## Source Code

````pine
//@version=6
// All-in-One — value, footprint flow and confirmed auction context.
// Adapted VP calculation/appearance: © dgtrd, supplied Volume Profile by DGT.
// Delta-line method: © colicoid, Cumulative Volume Delta Line Chart with MA.
// Insights calculation: © colicoid, CVD Divergence Insights, MPL 2.0.
// Local profile appearance: © Leviathan, Market Sessions and Volume Profile, MPL 2.0.
// Lean auction/DPOC logic: supplied Auction Regime Engine.
// Absorption/divergence concept: supplied Order Flow by LunqFX.
// Reused Insights source is subject to https://mozilla.org/MPL/2.0/.
// Footprint volume is TradingView's intrabar direction classification, not a trade tape.
// Delta overlay height is a display transform; candle intersections are not signals.
indicator("All-in-One • VP, Delta & Insights", "Value & Flow", overlay = false,
     max_boxes_count = 500, max_lines_count = 300, max_labels_count = 300,
     max_polylines_count = 10)
// Only time needs the long drawing buffer. Let Pine size numerical/object
// series to their actual lookbacks instead of forcing 5,000 copies of each.
max_bars_back(time, 5000)

int anchorTime = input.time(0, "VP start — select or drag on chart", confirm = true,
     group = "Profile", tooltip = "VP + CVD start here.\nSelect Value & Flow, then drag the time marker.")
bool showVP = input.bool(true, "Anchored volume profile", group = "Profile")
bool showDeltaLine = input.bool(true, "Delta line on chart", group = "Layers",
     tooltip = "Smoothed buying minus selling.\nLine height is visual, not a price level.")
bool showInsights = input.bool(true, "Insights panel", group = "Layers")
bool showCloud = input.bool(true, "Absorption cloud", group = "Layers",
     tooltip = "Green: buying outruns price; red: selling outruns price.\nWait for price to respond.")
bool showSpikeProfiles = input.bool(true, "Merged spike profiles", group = "Layers")
bool showConcentrations = input.bool(true, "Large delta dots", group = "Layers",
     tooltip = "Green: buy delta · Red: sell delta.\nBigger dot = stronger pressure; hover for the value.")
bool showLocalProfiles = input.bool(true, "Local profiles", group = "Auction context")
bool showAuctionEvents = input.bool(true, "Auction events & DPOCs", group = "Auction context",
     tooltip = "P probe · A accepted · F failed · M value shift.\nYellow trails: POC references; DPOC: strongest delta row.")
bool showOrderFlow = input.bool(true, "Absorption & divergence", group = "Order flow",
     tooltip = "W watch · H hold · RC reclaim · RJ rejection\nArrow: response direction. Confirmed after candle close.")
bool showFlowSummary = input.bool(true, "Flow summary", group = "Order flow")

// Pure numerical helpers: actual source is executed by local fixture checks.
// Match DGT's candle-count budget, excluding the current candle. Session gaps
// must not make the source coarser for the same number of chart candles.
vp_sourceBudget(float chartSeconds, int anchorIndex, int latestIndex) =>
    float duration = chartSeconds * math.max(latestIndex - anchorIndex, 0)
    duration

vp_selectCandidate(float chartSeconds, float durationSeconds, float candidateSeconds, int target) =>
    bool eligible = candidateSeconds > 0 and candidateSeconds <= chartSeconds and durationSeconds / candidateSeconds < target
    eligible

// DGT keeps fractional proportional width until converting each coordinate.
// Rounding the bullish left coordinate, rather than its width, retains tiny nodes.
vp_displayScale(int rangeBars) =>
    float scale = math.min(math.max(rangeBars - 1, 0), 360) * 0.31
    scale

vp_upLeft(int profileRight, float upVolume, float maxVolume, float scale) =>
    int left = int(profileRight - upVolume / maxVolume * scale)
    left

// DGT overlap allocation with explicit zero-height and boundary protection.
vp_overlapFraction(float sourceLow, float sourceHigh, float rowLow, float rowHigh, float mintick) =>
    float fraction = 0.0
    if sourceHigh <= sourceLow
        if sourceLow >= rowLow and sourceLow < rowHigh
            fraction := 1.0
    else if sourceHigh > rowLow and sourceLow < rowHigh
        float overlap = math.min(sourceHigh, rowHigh) - math.max(sourceLow, rowLow)
        fraction := math.max(0.0, overlap) / math.max(sourceHigh - sourceLow, mintick)
    fraction

// Additive distributions preserve DGT's first (lowest) maximum-volume row.
vp_maxAfterAdd(float maximum, int poc, float updated, int row) =>
    float nextMaximum = maximum
    int nextPoc = poc
    if updated > maximum or (updated == maximum and row < poc)
        nextMaximum := updated
        nextPoc := row
    [nextMaximum, nextPoc]

vp_cacheReset(float cachedLow, float cachedStep, float gridLow, float step, int cachedStride, int stride, int cachedCount, int count) =>
    bool reset = na(cachedLow) or na(cachedStep)
    if not reset
        reset := cachedLow != gridLow or cachedStep != step or cachedStride != stride or cachedCount > count
    reset

// Expand from maximum-volume row; DGT upper-row tie preference, bounded at edges.
vp_valueArea(array<float> totals, float fraction) =>
    int poc = 0
    int lower = 0
    int upper = 0
    int count = totals.size()
    if count > 0 and totals.sum() > 0
        poc := totals.indexof(totals.max())
        lower := poc
        upper := poc
        float target = totals.sum() * math.max(0.0, math.min(1.0, fraction))
        float accumulated = totals.get(poc)
        int iterations = 0
        while accumulated < target and iterations < count
            if lower == 0 and upper == count - 1
                break
            float above = -1.0
            float below = -1.0
            if upper < count - 1
                above := totals.get(upper + 1)
            if lower > 0
                below := totals.get(lower - 1)
            if above >= below and upper < count - 1
                upper += 1
                accumulated += above
            else if lower > 0
                lower -= 1
                accumulated += below
            iterations += 1
    [poc, lower, upper]

// 0 keep, 1 start, 2 append, 3 close, 4 close then start.
// A last-bar render never closes state. Only confirmed bar membership calls this.
flow_clusterAction(bool active, int currentSide, int lastSpikeBar, int thisBar, bool spike, int newSide, int gap) =>
    int action = 0
    if not active
        if spike
            action := 1
    else if spike
        if newSide == currentSide and thisBar - lastSpikeBar <= gap + 1
            action := 2
        else
            action := 4
    else if thisBar - lastSpikeBar > gap
        action := 3
    action

// Completeness is sticky for an open cluster. An unknown footprint breaks
// continuity; a known non-spike gap does not need a spatial contribution.
flow_clusterDataUsable(bool usable, bool dataKnown, bool spike, bool rowsReady) =>
    bool complete = usable
    if not dataKnown or (spike and not rowsReady)
        complete := false
    complete

flow_spikeSide(bool spike, float oscillator) =>
    int side = 0
    if spike and oscillator > 0
        side := 1
    else if spike and oscillator < 0
        side := -1
    side

delta_affine(float value, float origin, float scale, float baseline) =>
    float mapped = baseline + (value - origin) * scale
    mapped

// Original intrabar classifier: body, then preceding close, then direction carry.
delta_classify(float o, float c, float previousClose, bool previousDirection) =>
    bool direction = previousDirection
    if c > o
        direction := true
    else if c < o
        direction := false
    else if c > previousClose
        direction := true
    else if c < previousClose
        direction := false
    direction

// Auction pure helpers: source ARE rules with fixed internal thresholds.
auction_validRow(float total, float buy, float sell, float delta, float lower, float upper) =>
    bool valid = false
    if not na(total) and not na(buy) and not na(sell) and not na(delta) and not na(lower) and not na(upper)
        float tolerance = math.max(0.000001, math.abs(total) * 0.000001)
        valid := total >= 0 and buy >= 0 and sell >= 0 and math.abs(total) < 1e100 and math.abs(buy) < 1e100 and math.abs(sell) < 1e100 and math.abs(delta) < 1e100 and math.abs(lower) < 1e100 and math.abs(upper) < 1e100 and upper > lower and math.abs(buy + sell - total) <= tolerance and math.abs(buy - sell - delta) <= tolerance
    valid

auction_intervalFraction(float lower, float upper, float cellLow, float cellHigh) =>
    float fraction = 0.0
    if upper > lower
        fraction := math.max(0.0, math.min(upper, cellHigh) - math.max(lower, cellLow)) / (upper - lower)
    fraction

auction_outsideFraction(float lower, float upper, float edge, int direction) =>
    float fraction = 0.0
    if upper > lower
        if direction == 1
            fraction := math.max(0.0, math.min(1.0, (upper - edge) / (upper - lower)))
        else if direction == -1
            fraction := math.max(0.0, math.min(1.0, (edge - lower) / (upper - lower)))
    fraction

auction_neighbor(array<float> levels, float price, int direction) =>
    float result = na
    if levels.size() > 0
        for index = 0 to levels.size() - 1
            float level = levels.get(index)
            if (level - price) * direction > 0
                if na(result)
                    result := level
                else if math.abs(level - price) < math.abs(result - price)
                    result := level
    result

auction_accept(int consecutive, float share, float participation, bool pocOutside) =>
    consecutive >= 3 and share >= 0.60 and participation >= 1.05 and pocOutside

auction_migrate(bool accepted, float shift, float overlap, int age, bool retest, int held) =>
    accepted and shift >= 0.5 and overlap <= 60 and age >= 8 and (retest or held >= 4)

auction_seedCount(int count, bool good, bool confirmed) =>
    int next = count
    if confirmed
        if good
            next += 1
        else
            next := 0
    next

auction_referenceReady(int count) =>
    count >= 24

// Event codes 0 none, 1 probe, 2 accepted, 3 failed, 4 migration.
auction_transition(int stage, int probeSide, int currentBar, int nextAttempt, int attemptStart, int acceptedAt, int held, bool backInside, bool accepted, bool migration, bool outsideClose, bool good, bool confirmed) =>
    int nextStage = stage
    int event = 0
    int nextEligible = nextAttempt
    int acceptedBar = acceptedAt
    int nextHeld = held
    if confirmed
        if not good
            nextStage := 0
            acceptedBar := -1
            nextHeld := 0
        else if stage == 0
            if probeSide != 0 and currentBar >= nextAttempt
                nextStage := 1
                event := 1
        else if backInside
            nextStage := 0
            event := 3
            nextEligible := currentBar + 3
        else if stage == 1 and accepted
            nextStage := 2
            event := 2
            acceptedBar := currentBar
            nextHeld := 0
        else if stage == 2
            if outsideClose
                nextHeld += 1
            else
                nextHeld := 0
            if migration
                nextStage := 0
                event := 4
                nextEligible := currentBar + 3
        if nextStage > 0 and stage > 0 and currentBar - attemptStart >= 30 and event != 2
            nextStage := 0
            nextEligible := currentBar + 3
    [nextStage, event, nextEligible, acceptedBar, nextHeld]

auction_targetPending(int currentBar, int born, float target, int direction, float edge, float barLow, float barHigh, float barClose, bool good) =>
    bool pending = good and currentBar - born < 40
    if currentBar > born
        if direction == 1 and barHigh >= target
            pending := false
        else if direction == -1 and barLow <= target
            pending := false
        if not na(edge) and (barClose - edge) * direction <= 0
            pending := false
    pending

auction_netPeak(array<int> keys, array<float> values) =>
    int chosen = na
    float strongest = 0.0
    if keys.size() > 0
        chosen := keys.get(0)
        strongest := values.get(0)
        for index = 0 to keys.size() - 1
            int key = keys.get(index)
            float value = values.get(index)
            if math.abs(value) > math.abs(strongest) or (math.abs(value) == math.abs(strongest) and key < chosen)
                chosen := key
                strongest := value
    [chosen, strongest]

auction_levelNext(int state, int side, int age, int lifetime, float barLow, float barHigh, float barClose, float lower, float upper) =>
    int nextState = state
    int nextSide = side
    bool firstTouch = false
    bool crossed = false
    if state < 2 and age > 0
        if age > lifetime
            nextState := 3
        else
            firstTouch := state == 0 and barLow <= upper and barHigh >= lower
            crossed := (side == 1 and barClose < lower) or (side == -1 and barClose > upper)
            if firstTouch
                nextState := 1
            if crossed
                nextState := 2
            if side == 0
                if barClose > upper
                    nextSide := 1
                else if barClose < lower
                    nextSide := -1
    [nextState, nextSide, firstTouch, crossed]

// 1 start, 2 append, 3 close, 4 close/start, 5 discard; no gap members.
auction_clusterAction(bool active, int count, int lastBar, int currentBar, bool significant, int pressure, int oldPressure, int reference, int oldReference, int attempt, int oldAttempt, bool usable, bool fits) =>
    int action = 0
    if not usable or not fits
        action := 5
    else if active
        if not significant
            action := 3
        else if currentBar == lastBar + 1 and pressure == oldPressure and reference == oldReference and attempt == oldAttempt and count < 4
            action := 2
        else
            action := 4
    else if significant
        action := 1
    action

auction_significant(float delta, float volume, float threshold, float priorMean, int priorCount) =>
    priorCount >= 200 and volume > 0 and priorMean > 0 and math.abs(delta) > threshold and math.abs(delta) / volume >= 0.20 and volume / priorMean >= 1.0

// Reject cheap failures before sorting the prior 200 deltas; admission is unchanged.
auction_deltaEligible(float delta, float volume, float priorMean, int priorCount) =>
    not na(priorMean) and priorCount >= 200 and volume > 0 and priorMean > 0 and math.abs(delta) / volume >= 0.20 and volume / priorMean >= 1.0

// Sample the original target trail, never its future extension. A new target
// gets its own first dot; a continuous trail leaves four candles between dots.
auction_referenceDotDue(float level, int born, int previousBorn, int currentBar, int previousBar, float previousLevel, float tick) =>
    not na(level) and currentBar > previousBar and (born != previousBorn or currentBar - previousBar >= 4 or math.abs(level - previousLevel) > tick * 0.5)

// Drawing freshness does not change the retained analytic record or its lifetime.
auction_oldPocEligible(float level, int born, int lastTouch, int reference, int currentReference, int currentBar, float price, float atr) =>
    not na(atr) and atr > 0 and not na(level) and reference != currentReference and currentBar > born and currentBar - born <= 160 and lastTouch <= born and math.abs(level - price) <= atr * 2.0

// One bounded pick at a time: proximity first, recency on ties, nearby levels merge.
auction_pickOldPoc(array<float> levels, array<int> born, array<bool> eligible, array<float> blockers, float price, float tolerance) =>
    int chosen = -1
    float bestDistance = 1e100
    int bestBorn = -1
    if levels.size() > 0
        for index = 0 to levels.size() - 1
            if eligible.get(index)
                float level = levels.get(index)
                bool separate = true
                if blockers.size() > 0
                    for blocker = 0 to blockers.size() - 1
                        if not na(blockers.get(blocker)) and math.abs(level - blockers.get(blocker)) <= tolerance + math.max(0.000000001, math.abs(level) * 1e-12)
                            separate := false
                            break
                if separate
                    float distance = math.abs(level - price)
                    if distance < bestDistance or (distance == bestDistance and born.get(index) > bestBorn)
                        chosen := index
                        bestDistance := distance
                        bestBorn := born.get(index)
    chosen

// Pure AU-grid display math; fixtures execute these exact helper bodies.
// Snapshot cells represent the full interval [key * step, (key + 1) * step].
// Display rows are a uniform resampling of that grid, including empty gaps.
local_gridValid(array<int> keys, array<float> totals, array<float> buys, float step) =>
    bool valid = false
    int count = keys.size()
    if not na(step) and step > 0 and count > 0 and totals.size() == count and buys.size() == count
        valid := true
        float volume = 0.0
        for cell = 0 to count - 1
            int key = keys.get(cell)
            float total = totals.get(cell)
            float buy = buys.get(cell)
            if na(key) or na(total) or na(buy)
                valid := false
            else if total < 0 or buy < 0 or buy > total
                valid := false
            else
                float cellLow = key * step
                float cellHigh = (key + 1) * step
                if na(cellLow) or na(cellHigh) or cellHigh <= cellLow
                    valid := false
                else
                    volume += total
        if volume <= 0
            valid := false
    valid

local_rowVolumes(array<int> keys, array<float> totals, array<float> buys, float step, float rowLow, float rowHigh) =>
    float totalOut = 0.0
    float buyOut = 0.0
    int count = keys.size()
    if not na(step) and not na(rowLow) and not na(rowHigh)
        if step > 0 and rowHigh > rowLow and count > 0 and totals.size() == count and buys.size() == count
            for cell = 0 to count - 1
                int key = keys.get(cell)
                float total = totals.get(cell)
                float buy = buys.get(cell)
                if not na(key) and not na(total) and not na(buy)
                    if total >= 0 and buy >= 0 and buy <= total
                        float cellLow = key * step
                        float cellHigh = (key + 1) * step
                        if not na(cellLow) and not na(cellHigh) and cellHigh > cellLow
                            float overlap = math.max(0.0, math.min(cellHigh, rowHigh) - math.max(cellLow, rowLow))
                            float fraction = math.max(0.0, math.min(1.0, overlap / (cellHigh - cellLow)))
                            totalOut += total * fraction
                            buyOut += buy * fraction
    // The final clamp removes floating-point overhang from fully bought cells.
    buyOut := math.max(0.0, math.min(totalOut, buyOut))
    float sellOut = math.max(0.0, totalOut - buyOut)
    [totalOut, buyOut, sellOut]

// Scatter each validated source cell only into the display rows it can touch.
// Neighbor candidates protect exact overlap at floating-point row boundaries;
// the same interval formula and final side clamps as local_rowVolumes apply.
// Output arrays are display-owned and never alias auction snapshot cells.
local_aggregateRows(array<int> keys, array<float> totals, array<float> buys, float step, float low, float high, array<float> rowTotals, array<float> rowBuys, array<float> rowSells) =>
    int rowCount = rowTotals.size()
    int count = keys.size()
    if rowCount > 0 and rowBuys.size() == rowCount and rowSells.size() == rowCount
        for row = 0 to rowCount - 1
            rowTotals.set(row, 0.0)
            rowBuys.set(row, 0.0)
            rowSells.set(row, 0.0)
        if not na(step) and not na(low) and not na(high)
            if step > 0 and high > low and count > 0 and totals.size() == count and buys.size() == count
                float rowStep = (high - low) / rowCount
                for cell = 0 to count - 1
                    int key = keys.get(cell)
                    float total = totals.get(cell)
                    float buy = buys.get(cell)
                    if not na(key) and not na(total) and not na(buy)
                        if total >= 0 and buy >= 0 and buy <= total
                            float cellLow = key * step
                            float cellHigh = (key + 1) * step
                            if not na(cellLow) and not na(cellHigh) and cellHigh > cellLow
                                int firstRow = int(math.max(0, math.floor((cellLow - low) / rowStep) - 1))
                                int lastRow = int(math.min(rowCount - 1, math.floor((cellHigh - low) / rowStep) + 1))
                                if firstRow <= lastRow
                                    for row = firstRow to lastRow
                                        float rowLow = math.max(low, low + row * rowStep)
                                        float rowHigh = high
                                        if row < rowCount - 1
                                            rowHigh := math.min(high, low + (row + 1) * rowStep)
                                        float overlap = math.max(0.0, math.min(cellHigh, rowHigh) - math.max(cellLow, rowLow))
                                        float fraction = math.max(0.0, math.min(1.0, overlap / (cellHigh - cellLow)))
                                        rowTotals.set(row, rowTotals.get(row) + total * fraction)
                                        rowBuys.set(row, rowBuys.get(row) + buy * fraction)
                for row = 0 to rowCount - 1
                    float total = rowTotals.get(row)
                    float buy = math.max(0.0, math.min(total, rowBuys.get(row)))
                    rowBuys.set(row, buy)
                    rowSells.set(row, math.max(0.0, total - buy))
    rowCount

// Display chronology is independent of shared candidate evidence in snapshots.
// A superseded interval with no positive span returns its opening timestamp.
local_displayEnd(int opened, int closed, int nextOpened) =>
    int displayClosed = closed
    if not na(opened) and not na(closed)
        displayClosed := math.max(opened, closed)
        if not na(nextOpened)
            displayClosed := math.max(opened, math.min(closed, nextOpened))
    displayClosed

// Market Sessions Mode 2 places the stacked profile within 1 / 3.5 of its span.
local_profileWidth(int opened, int closed) =>
    int width = int(math.max(closed - opened, 0) / 3.5)
    width

local_segmentTimes(int left, int width, float buy, float sell, float maxVolume) =>
    int buyEnd = left
    int sellEnd = left
    if width > 0 and maxVolume > 0
        float buyFraction = math.max(0.0, math.min(1.0, buy / maxVolume))
        float totalFraction = math.max(buyFraction, math.min(1.0, (buy + sell) / maxVolume))
        buyEnd := int(left + width * buyFraction)
        sellEnd := int(left + width * totalFraction)
    [buyEnd, sellEnd]

// A valid bottom-row POC (including a zero price) must not disappear.
local_levelInside(float price, float low, float high) =>
    bool inside = false
    if not na(price) and not na(low) and not na(high)
        inside := high > low and price >= low and price <= high
    inside

// Analytic area records are independent of every display layer.
const int area_CONTEXT_CAP = 32
// 3 frozen AU + 6 completed profile + 16 retained DPOC + 20 earlier POC.
const int area_SOURCE_CAP = 45

type area_Record
    string key
    string aliases
    string caption
    int kind
    int born
    int bornTime
    int reference
    int priority
    int lastTouch
    float lower
    float upper
    float level

area_tolerance(float atr, float nativeRow) =>
    float tolerance = na
    if not na(atr) and not na(nativeRow)
        if atr > 0 and nativeRow > 0 and math.abs(atr) < 1e100 and math.abs(nativeRow) < 1e100
            tolerance := math.max(0.15 * atr, nativeRow)
    tolerance

// Edges have one rejection role. Centres need a fresh approach from outside
// the band: residence at a busy POC is never an eligible test.
area_eligible(int kind, int born, int currentBar, int side, float previousClose, float barLow, float barHigh, float barClose, float lower, float upper) =>
    bool eligible = false
    if not na(born) and not na(previousClose) and not na(barLow) and not na(barHigh) and not na(barClose) and not na(lower) and not na(upper)
        bool finite = math.abs(previousClose) < 1e100 and math.abs(barLow) < 1e100 and math.abs(barHigh) < 1e100 and math.abs(barClose) < 1e100 and math.abs(lower) < 1e100 and math.abs(upper) < 1e100
        bool contact = barLow <= upper and barHigh >= lower
        bool role = (kind == 1 and side == 1) or (kind == 2 and side == -1)
        if kind == 3 or kind == 4
            role := (side == 1 and previousClose > upper) or (side == -1 and previousClose < lower)
        eligible := finite and born < currentBar and barHigh >= barLow and upper > lower and contact and role
    eligible

area_oldEligible(int born, int currentBar, int reference, int currentReference) =>
    bool eligible = false
    if not na(born)
        eligible := currentBar >= born and currentBar - born <= 160 and reference != currentReference
    eligible

// Anchors never grow during merging. The extra union-width guard prevents a
// succession of overlapping levels from chaining into an entire value area.
area_mergeable(int kindA, int kindB, float lowerA, float upperA, float lowerB, float upperB, float maxWidth) =>
    bool sameRole = kindA == kindB or ((kindA == 3 or kindA == 4) and (kindB == 3 or kindB == 4))
    bool overlap = lowerA <= upperB and lowerB <= upperA
    bool bounded = math.max(upperA, upperB) - math.min(lowerA, lowerB) <= maxWidth
    sameRole and overlap and bounded

area_rankBefore(int priorityA, int bornA, int touchA, float levelA, int priorityB, int bornB, int touchB, float levelB, float price) =>
    bool before = false
    int freshnessA = math.max(bornA, touchA)
    int freshnessB = math.max(bornB, touchB)
    float distanceA = math.abs(levelA - price)
    float distanceB = math.abs(levelB - price)
    if priorityA != priorityB
        before := priorityA > priorityB
    else if freshnessA != freshnessB
        before := freshnessA > freshnessB
    else if distanceA != distanceB
        before := distanceA < distanceB
    else if bornA != bornB
        before := bornA > bornB
    else
        before := levelA < levelB
    before

area_hasAlias(string aliases, string key) =>
    key != "" and str.contains(aliases, "|" + key + "|")

area_make(string key, string caption, int kind, int born, int bornTime, int reference, int priority, int lastTouch, float level, float tolerance) =>
    area_Record.new(key, "|" + key + "|", caption, kind, born, bornTime, reference, priority, lastTouch, level - tolerance, level + tolerance, level)

area_copy(area_Record record) =>
    area_Record copied = na
    if not na(record)
        copied := area_Record.new(record.key, record.aliases, record.caption, record.kind, record.born, record.bornTime, record.reference, record.priority, record.lastTouch, record.lower, record.upper, record.level)
    copied

area_cloneContext(array<area_Record> records) =>
    array<area_Record> copied = array.new<area_Record>()
    for record in records
        copied.push(area_copy(record))
    copied

// Valid source handles are captured before rank/cap selection. Last-touch
// metadata follows each source token through earlier compatible merges.
area_add(array<area_Record> sources, array<string> liveKeys, array<area_Record> previous, area_Record source, float barLow, float barHigh, int currentBar) =>
    bool added = false
    if not na(source) and not na(source.level) and not na(source.born) and not na(source.lower) and not na(source.upper)
        if sources.size() < area_SOURCE_CAP and math.abs(source.level) < 1e100 and source.upper > source.lower
            for prior in previous
                if prior.key == source.key or area_hasAlias(prior.aliases, source.key)
                    source.lastTouch := math.max(source.lastTouch, prior.lastTouch)
            if barLow <= source.upper and barHigh >= source.lower
                source.lastTouch := currentBar
            sources.push(source)
            liveKeys.push(source.key)
            added := true
    added

area_build(array<area_Record> sources, array<area_Record> previous, float price, float tolerance) =>
    array<area_Record> ranked = array.new<area_Record>()
    array<area_Record> merged = array.new<area_Record>()
    // At most 45 bounded sources; insertion order breaks complete numeric ties.
    for source in sources
        int insertAt = ranked.size()
        if ranked.size() > 0
            for index = 0 to ranked.size() - 1
                area_Record other = ranked.get(index)
                if area_rankBefore(source.priority, source.born, source.lastTouch, source.level, other.priority, other.born, other.lastTouch, other.level, price)
                    insertAt := index
                    break
        // Ranking is read-only. The merged record below owns its single copy.
        ranked.insert(insertAt, source)
    for source in ranked
        int mergeAt = -1
        if merged.size() > 0
            for index = 0 to merged.size() - 1
                area_Record anchor = merged.get(index)
                if area_mergeable(anchor.kind, source.kind, anchor.lower, anchor.upper, source.lower, source.upper, tolerance * 3.0)
                    mergeAt := index
                    break
        if mergeAt >= 0
            area_Record anchor = merged.get(mergeAt)
            if not area_hasAlias(anchor.aliases, source.key)
                anchor.aliases += source.aliases
            anchor.lastTouch := math.max(anchor.lastTouch, source.lastTouch)
        else if merged.size() < area_CONTEXT_CAP
            merged.push(area_copy(source))
    // Preserve a previous primary handle when its raw source is still in this
    // merged band. All dimensions and source metadata belong to the anchor.
    for record in merged
        for prior in previous
            if record.key == prior.key or area_hasAlias(record.aliases, prior.key)
                record.key := prior.key
                break
    merged

// Numeric helpers are exercised from this exact source by the limited fixture.
// Native record/state functions below are included verbatim in the Pine fixture.
const int of_PRIOR_VOLUMES = 20
const int of_PIVOT_SIDE = 8
const int of_PIVOT_WINDOW = 17
const int of_PIVOT_MAX_GAP = 120
const int of_KEEP_EPISODES = 24
const int of_KEEP_LEVELS = 5
const int of_KEEP_MARKERS = 12
const int of_LEVEL_AGE = 200

of_totalsUsable(bool of_valid, float of_total, float of_buy, float of_sell, float of_delta) =>
    bool of_result = false
    if of_valid and not na(of_total) and not na(of_buy) and not na(of_sell) and not na(of_delta)
        float of_tolerance = math.max(0.000001, math.abs(of_total) * 0.000001)
        of_result := of_total >= 0 and of_buy >= 0 and of_sell >= 0 and math.abs(of_total) < 1e100 and math.abs(of_buy) < 1e100 and math.abs(of_sell) < 1e100 and math.abs(of_delta) < 1e100 and math.abs(of_buy + of_sell - of_total) <= of_tolerance and math.abs(of_buy - of_sell - of_delta) <= of_tolerance
    of_result

of_rowUsable(float of_total, float of_buy, float of_sell, float of_delta, float of_lower, float of_upper) =>
    bool of_result = false
    if not na(of_total) and not na(of_buy) and not na(of_sell) and not na(of_delta) and not na(of_lower) and not na(of_upper)
        float of_tolerance = math.max(0.000001, math.abs(of_total) * 0.000001)
        of_result := of_total >= 0 and of_buy >= 0 and of_sell >= 0 and math.abs(of_total) < 1e100 and math.abs(of_buy) < 1e100 and math.abs(of_sell) < 1e100 and math.abs(of_delta) < 1e100 and math.abs(of_lower) < 1e100 and math.abs(of_upper) < 1e100 and of_upper > of_lower and math.abs(of_buy + of_sell - of_total) <= of_tolerance and math.abs(of_buy - of_sell - of_delta) <= of_tolerance
    of_result

of_spatialReconciled(bool of_rowsValid, int of_count, float of_total, float of_buy, float of_sell, float of_delta, float of_barTotal, float of_barBuy, float of_barSell, float of_barDelta) =>
    bool of_result = false
    if of_rowsValid and of_count > 0
        float of_tolerance = math.max(0.000001, math.abs(of_barTotal) * 0.00001)
        of_result := math.abs(of_total - of_barTotal) <= of_tolerance and math.abs(of_buy - of_barBuy) <= of_tolerance and math.abs(of_sell - of_barSell) <= of_tolerance and math.abs(of_delta - of_barDelta) <= of_tolerance
    of_result

of_intervalFraction(float of_lower, float of_upper, float of_bandLow, float of_bandHigh) =>
    float of_fraction = 0.0
    if of_upper > of_lower
        of_fraction := math.max(0.0, math.min(of_upper, of_bandHigh) - math.max(of_lower, of_bandLow)) / (of_upper - of_lower)
    of_fraction

// Positive side opposes selling pressure; negative side opposes buying.
// Closing progress is measured from the prior close in the pressure direction.
// Whole-bar net delta deliberately has no admission floor.
of_localPressure(bool of_valid, float of_volume, float of_priorMean, int of_priorCount, float of_zoneVolume, float of_zoneDelta, int of_side, float of_previousClose, float of_close, float of_atr, bool of_rejection) =>
    bool of_result = false
    if of_valid and of_priorCount >= 20
        if not na(of_volume) and not na(of_priorMean) and not na(of_zoneVolume) and not na(of_zoneDelta) and not na(of_previousClose) and not na(of_close) and not na(of_atr)
            if of_volume > 0 and of_priorMean > 0 and of_zoneVolume > 0 and of_atr > 0 and (of_side == 1 or of_side == -1)
                bool of_signedPressure = -of_zoneDelta * of_side >= 0.20 * of_zoneVolume
                float of_progress = (of_previousClose - of_close) * of_side
                of_result := of_volume > 1.8 * of_priorMean and of_zoneVolume >= 0.20 * of_volume and of_signedPressure and (of_progress <= 0.35 * of_atr or of_rejection)
    of_result

of_volumeMean(array<float> of_values, int of_required) =>
    float of_result = na
    int of_count = of_values.size()
    if of_required > 0 and of_count >= of_required
        of_result := of_values.sum() / of_count
    of_result

of_cvdValue(float of_previous, float of_delta, bool of_valid, bool of_reset) =>
    float of_result = na
    if of_valid and not na(of_delta)
        if of_reset or na(of_previous)
            of_result := of_delta
        else
            of_result := of_previous + of_delta
    of_result

// HUD accumulation begins with the chart candle containing the shared anchor,
// or the first available candle after it. Invalid totals mark incomplete data
// without discarding valid delta accumulated before or after that candle.
of_anchorStep(float of_previous, int of_previousStart, bool of_previousPartial, int of_time, int of_closeTime, int of_anchor, bool of_first, bool of_valid, float of_delta) =>
    float of_value = of_previous
    int of_start = of_previousStart
    bool of_partial = of_previousPartial
    bool of_contains = of_time <= of_anchor and not na(of_closeTime) and of_anchor < of_closeTime
    if na(of_start) and (of_contains or of_time >= of_anchor)
        of_start := of_time
        // No observed delta is unavailable, distinct from a real net zero.
        of_value := na
        of_partial := of_first and of_anchor < of_time
    if not na(of_start)
        if of_valid and not na(of_delta)
            of_value := nz(of_value) + of_delta
        else
            of_partial := true
    [of_value, of_start, of_partial]

// Only a totals coverage gap breaks structural continuity. Anchor changes and
// ordinary non-trading time gaps are intentionally absent from this API.
of_epochBreak(bool of_valid, bool of_previousValid) =>
    of_previousValid and not of_valid

of_windowIntact(array<int> of_epochs, int of_target, int of_required) =>
    int of_count = of_epochs.size()
    bool of_result = of_required > 0 and of_count >= of_required and of_target >= 0
    if of_result
        for of_index = of_count - of_required to of_count - 1
            if of_epochs.get(of_index) != of_target
                of_result := false
    of_result

of_materialDivergence(int of_side, float of_price, float of_previousPrice, float of_cvd, float of_previousCvd, int of_epoch, int of_previousEpoch, int of_separation, int of_maxGap, float of_nativeRow, float of_originAtr, float of_prominence, float of_deltaFloor) =>
    bool of_result = false
    if not na(of_price) and not na(of_previousPrice) and not na(of_cvd) and not na(of_previousCvd) and not na(of_nativeRow) and not na(of_originAtr) and not na(of_prominence) and not na(of_deltaFloor)
        if of_epoch == of_previousEpoch and of_epoch >= 0 and of_separation > 0 and of_separation <= of_maxGap and of_nativeRow > 0 and of_originAtr > 0 and of_deltaFloor >= 0
            float of_extension = (of_previousPrice - of_price) * of_side
            float of_cvdSeparation = (of_cvd - of_previousCvd) * of_side
            of_result := (of_side == 1 or of_side == -1) and of_extension >= math.max(of_nativeRow, 0.10 * of_originAtr) and of_prominence >= 0.75 * of_originAtr and of_cvdSeparation > 0 and of_cvdSeparation >= of_deltaFloor
    of_result

of_netPressure(float of_delta, float of_volume, bool of_valid) =>
    float of_result = na
    if of_valid and not na(of_delta) and not na(of_volume)
        if of_volume > 0
            of_result := 100.0 * of_delta / of_volume
    of_result

of_auctionMatch(int of_side, int of_reference, float of_lower, float of_upper, int of_eventDirection, int of_beforeReference, float of_eventEdge) =>
    bool of_result = false
    if not na(of_eventEdge)
        of_result := of_eventDirection == -of_side and of_reference >= 0 and of_beforeReference == of_reference and of_eventEdge >= of_lower and of_eventEdge <= of_upper
    of_result

of_leftBand(float of_close, float of_lower, float of_upper, float of_atr, float of_tick) =>
    float of_buffer = math.max(of_tick, 0.15 * of_atr)
    of_close > of_upper + of_buffer or of_close < of_lower - of_buffer

// Numeric lifecycle shared by the native state adapter and pure tests. Every
// watch cancellation is checked before the response close on the same candle.
of_nextState(int of_state, int of_side, float of_lower, float of_upper, float of_adverse, float of_atr, float of_tick, int of_born, int of_confirmedBar, int of_bar, float of_low, float of_high, float of_close, bool of_alive, bool of_totalsValid, bool of_contradictory) =>
    int of_next = of_state
    float of_buffer = math.max(of_tick, 0.05 * of_atr)
    if of_state == 0
        bool of_broken = (of_side == 1 and of_low < of_adverse) or (of_side == -1 and of_high > of_adverse)
        if not of_totalsValid or not of_alive or of_contradictory or of_broken
            of_next := 3
        else if of_bar - of_born > 3
            of_next := 4
        else if (of_side == 1 and of_close > of_upper + of_buffer) or (of_side == -1 and of_close < of_lower - of_buffer)
            of_next := 1
    else if of_state == 1 or of_state == 2
        if not of_alive or of_contradictory or (of_side == 1 and of_close < of_lower - of_buffer) or (of_side == -1 and of_close > of_upper + of_buffer)
            of_next := 3
        else if of_bar - of_confirmedBar > 200
            of_next := 4
        else if of_bar > of_confirmedBar and of_low <= of_upper and of_high >= of_lower
            of_next := 2
    of_next

// Lower-quality records are retired first when the analytic cap is reached.
// A pending watch never evicts a still-qualified confirmed/tested response.
of_retireBefore(int of_state, int of_priority, int of_freshness, float of_distance, int of_otherState, int of_otherPriority, int of_otherFreshness, float of_otherDistance) =>
    int of_tier = 0
    int of_otherTier = 0
    if of_state == 0
        of_tier := 1
    else if of_state == 2
        of_tier := 2
    else if of_state == 1
        of_tier := 3
    if of_otherState == 0
        of_otherTier := 1
    else if of_otherState == 2
        of_otherTier := 2
    else if of_otherState == 1
        of_otherTier := 3
    bool of_before = false
    if of_tier != of_otherTier
        of_before := of_tier < of_otherTier
    else if of_priority != of_otherPriority
        of_before := of_priority < of_otherPriority
    else if of_freshness != of_otherFreshness
        of_before := of_freshness < of_otherFreshness
    else
        of_before := of_distance > of_otherDistance
    of_before

type of_Episode
    string key
    string aliases
    string caption
    int kind
    int reference
    int side
    float lower
    float upper
    float level
    float atr
    float adverse
    int born
    int bornTime
    int state
    int confirmedBar
    int confirmedTime
    int divTime
    float zoneVolume
    float zoneDelta
    float barDelta
    bool absEvidence
    bool earlyEvidence
    bool divEvidence
    bool auctionEvidence
    int priority
    int touchedBar

type of_Marker
    int confirmedBar
    int confirmedTime
    float price
    int side
    string caption
    string tooltip

of_timeText(int of_stamp) =>
    na(of_stamp) ? "—" : str.format_time(of_stamp, "yyyy-MM-dd HH:mm", syminfo.timezone)

of_caption(int of_kind, int of_side) =>
    of_kind == 1 ? "RC↑" : of_kind == 2 ? "RJ↓" : "H" + (of_side == 1 ? "↑" : "↓")

of_tooltip(of_Episode of_episode) =>
    string of_stateName = of_episode.state == 0 ? "watch" : of_episode.state == 1 ? "confirmed" : of_episode.state == 2 ? "tested" : of_episode.state == 3 ? "invalid" : "expired"
    string of_role = of_episode.kind == 1 ? "Reclaim" : of_episode.kind == 2 ? "Rejection" : "Hold"
    string of_evidence = of_episode.absEvidence ? "Absorption" : ""
    if of_episode.divEvidence
        of_evidence += (of_evidence == "" ? "" : " + ") + "divergence"
    else if of_episode.earlyEvidence
        of_evidence += (of_evidence == "" ? "" : " + ") + "Δ mismatch"
    if of_evidence == "" and of_episode.auctionEvidence
        of_evidence := "Failed auction"
    float of_buffer = math.max(syminfo.mintick, 0.05 * of_episode.atr)
    float of_response = of_episode.side == 1 ? of_episode.upper + of_buffer : of_episode.lower - of_buffer
    float of_invalid = of_episode.side == 1 ? of_episode.lower - of_buffer : of_episode.upper + of_buffer
    string of_decision = of_episode.state == 0 ? "Close " + (of_episode.side == 1 ? "> " : "< ") + str.tostring(of_response, format.mintick) + "; cancel " + (of_episode.side == 1 ? "low < " : "high > ") + str.tostring(of_episode.adverse, format.mintick) : "Invalid close " + (of_episode.side == 1 ? "< " : "> ") + str.tostring(of_invalid, format.mintick)
    of_role + (of_episode.side == 1 ? " ↑" : " ↓") + " @ " + str.tostring(of_episode.level, format.mintick) + " · " + of_stateName + "\n" + of_episode.caption + " · " + of_evidence + " · Δ " + str.tostring(of_episode.zoneDelta, format.volume) + "\n" + of_decision

of_sameArea(string of_key, string of_aliases, area_Record of_zone) =>
    bool of_same = false
    if not na(of_zone)
        of_same := of_key == of_zone.key or str.contains(of_zone.aliases, "|" + of_key + "|") or str.contains(of_aliases, "|" + of_zone.key + "|")
        if not of_same
            array<string> of_keys = str.split(of_aliases, "|")
            for of_alias in of_keys
                if of_alias != "" and str.contains(of_zone.aliases, "|" + of_alias + "|")
                    of_same := true
                    break
    of_same

// Parallel epoch/rearm arrays keep the locked display record interface stable.
// Repeated evidence only merges flags; it cannot alter a frozen band or deadline.
of_admit(array<of_Episode> of_records, array<int> of_epochs, array<bool> of_left, area_Record of_zone, int of_side, int of_epoch, int of_bar, int of_stamp, float of_atr, float of_adverse, float of_zoneVolume, float of_zoneDelta, float of_barDelta, bool of_absEvidence, bool of_earlyEvidence, bool of_divEvidence, int of_divTime, float of_price = na) =>
    int of_match = -1
    if not na(of_zone) and of_records.size() > 0
        for of_index = 0 to of_records.size() - 1
            of_Episode of_existing = of_records.get(of_index)
            if of_existing.side == of_side and of_epochs.get(of_index) == of_epoch and of_sameArea(of_existing.key, of_existing.aliases, of_zone)
                of_match := of_index
    bool of_create = not na(of_zone) and (of_absEvidence or of_earlyEvidence or of_divEvidence)
    if of_match >= 0
        of_Episode of_existing = of_records.get(of_match)
        if of_existing.state == 0 and of_bar - of_existing.born <= 3
            of_existing.absEvidence := of_existing.absEvidence or of_absEvidence
            of_existing.earlyEvidence := of_existing.earlyEvidence or of_earlyEvidence
            of_existing.divEvidence := of_existing.divEvidence or of_divEvidence
            if of_divEvidence and na(of_existing.divTime)
                of_existing.divTime := of_divTime
            of_create := false
        else
            // A late formal result alone cannot revive a retired/overdue watch.
            // A new localized-pressure/early test can rearm after leaving.
            of_create := of_create and of_left.get(of_match) and (of_absEvidence or of_earlyEvidence)
    if of_create
        of_Episode of_new = of_Episode.new(of_zone.key, of_zone.aliases, of_zone.caption, of_zone.kind, of_zone.reference, of_side, of_zone.lower, of_zone.upper, of_zone.level, of_atr, of_adverse, of_bar, of_stamp, 0, -1, na, of_divTime, of_zoneVolume, of_zoneDelta, of_barDelta, of_absEvidence, of_earlyEvidence, of_divEvidence, false, of_zone.priority, -1)
        if of_match >= 0
            of_records.set(of_match, of_new)
            of_left.set(of_match, false)
        else
            bool of_room = true
            if of_records.size() >= of_KEEP_EPISODES
                float of_rankPrice = na(of_price) ? of_zone.level : of_price
                int of_victim = 0
                for of_index = 1 to of_records.size() - 1
                    of_Episode of_candidate = of_records.get(of_index)
                    of_Episode of_retained = of_records.get(of_victim)
                    int of_freshness = of_candidate.state == 0 ? of_candidate.born : of_candidate.confirmedBar
                    int of_retainedFreshness = of_retained.state == 0 ? of_retained.born : of_retained.confirmedBar
                    if of_retireBefore(of_candidate.state, of_candidate.priority, of_freshness, math.abs(of_candidate.level - of_rankPrice), of_retained.state, of_retained.priority, of_retainedFreshness, math.abs(of_retained.level - of_rankPrice))
                        of_victim := of_index
                of_Episode of_old = of_records.get(of_victim)
                int of_oldFreshness = of_old.state == 0 ? of_old.born : of_old.confirmedBar
                of_room := not of_retireBefore(of_new.state, of_new.priority, of_new.born, math.abs(of_new.level - of_rankPrice), of_old.state, of_old.priority, of_oldFreshness, math.abs(of_old.level - of_rankPrice))
                if of_room
                    of_records.remove(of_victim)
                    of_epochs.remove(of_victim)
                    of_left.remove(of_victim)
            if of_room
                of_records.push(of_new)
                of_epochs.push(of_epoch)
                of_left.push(false)
                of_match := of_records.size() - 1
    of_match

// Formal evidence only annotates a still-live pending test. The caller may
// separately admit a current fresh area test; old pivot evidence never rearms.
of_supportFormal(array<of_Episode> of_records, array<int> of_epochs, area_Record of_origin, int of_side, int of_epoch, int of_bar, int of_stamp) =>
    bool of_supported = false
    for of_episode in of_records
        int of_index = of_records.indexof(of_episode)
        if of_episode.state == 0 and of_episode.side == of_side and of_epochs.get(of_index) == of_epoch and of_bar - of_episode.born <= 3 and of_sameArea(of_episode.key, of_episode.aliases, of_origin)
            of_episode.divEvidence := true
            if na(of_episode.divTime)
                of_episode.divTime := of_stamp
            of_supported := true
    of_supported

// Apply current-close cancellation/expiry before admission chooses cap victims.
// A pending response proposal remains pending until all current evidence has
// merged; its single confirmation pass freezes the complete marker snapshot.
of_retireBeforeAdmission(of_Episode of_episode, int of_bar, float of_low, float of_high, float of_close, float of_tick, bool of_alive, bool of_totalsValid, bool of_contradictory) =>
    int of_previous = of_episode.state
    int of_next = of_nextState(of_previous, of_episode.side, of_episode.lower, of_episode.upper, of_episode.adverse, of_episode.atr, of_tick, of_episode.born, of_episode.confirmedBar, of_bar, of_low, of_high, of_close, of_alive, of_totalsValid, of_contradictory)
    if of_previous == 1 or of_previous == 2 or (of_previous == 0 and of_next >= 3)
        of_episode.state := of_next
        if of_previous != 2 and of_next == 2
            of_episode.touchedBar := of_bar
    of_episode.state

// The marker copies primitive values and a tooltip string. Later evidence,
// touches, retirement or rearm cannot modify this historical response snapshot.
of_advance(of_Episode of_episode, array<of_Marker> of_history, int of_bar, int of_stamp, float of_low, float of_high, float of_close, float of_tick, bool of_alive, bool of_totalsValid, bool of_contradictory, bool of_failure, bool of_canRespond) =>
    int of_previous = of_episode.state
    of_episode.state := of_nextState(of_episode.state, of_episode.side, of_episode.lower, of_episode.upper, of_episode.adverse, of_episode.atr, of_tick, of_episode.born, of_episode.confirmedBar, of_bar, of_low, of_high, of_close, of_alive, of_totalsValid, of_contradictory)
    if of_previous == 0 and of_episode.state == 1 and not of_canRespond
        of_episode.state := 0
    bool of_confirmed = of_previous == 0 and of_episode.state == 1
    if of_confirmed
        of_episode.confirmedBar := of_bar
        of_episode.confirmedTime := of_stamp
        of_episode.auctionEvidence := of_failure
        while of_history.size() >= of_KEEP_MARKERS
            of_history.shift()
        of_history.push(of_Marker.new(of_bar, of_stamp, of_episode.side == 1 ? of_low : of_high, of_episode.side, of_caption(of_episode.kind, of_episode.side), of_tooltip(of_episode)))
    if of_previous != 2 and of_episode.state == 2
        of_episode.touchedBar := of_bar
    of_confirmed

// These gates describe confirmed events. No trading orders or alerts are created.
prod_eventGate(bool confirmed, int eventBar, int currentBar) =>
    confirmed and not na(eventBar) and eventBar == currentBar

// Anchored volume profile, adapted from Volume Profile & Market Activity by © dgtrd.
// The DGT overlap allocation, 68% VA expansion, candle polarity and node colours
// are retained. Like the source, developing POC is recalculated on the current grid.

const int vp_rowCount = 100
const int vp_sampleCap = 12000
const int vp_sourceTarget = 5000
const int vp_pointCap = 500
const int vp_zoneCap = 20
const int vp_gapCap = 10
const float vp_valueFraction = 0.68
const float vp_thinFraction = 0.15
const int vp_gapNeighbors = 7

type vp_Sample
    float vp_high
    float vp_low
    float vp_volume
    bool vp_up
    int vp_barTime
    int vp_barEnd

// Selection is fixed for a run. Every candidate is checked against the chart TF;
// a long range on a small chart never accidentally requests a higher timeframe.
vp_chooseTimeframe(float vp_chartSeconds, float vp_durationSeconds) =>
    string vp_choice = timeframe.period
    array<string> vp_candidates = timeframe.isseconds ? array.from("1S", "5S", "15S", "30S") : array.from("1", "3", "5", "15", "30", "60", "120", "240", "1D")
    if not na(vp_chartSeconds) and vp_chartSeconds > 0
        for vp_candidate in vp_candidates
            float vp_candidateSeconds = timeframe.in_seconds(vp_candidate)
            if vp_selectCandidate(vp_chartSeconds, vp_durationSeconds, vp_candidateSeconds, vp_sourceTarget)
                vp_choice := vp_candidate
                break
    vp_choice

vp_clearBoxes(array<box> vp_owned) =>
    while array.size(vp_owned) > 0
        box.delete(array.pop(vp_owned))

vp_clearLines(array<line> vp_owned) =>
    while array.size(vp_owned) > 0
        line.delete(array.pop(vp_owned))

vp_clearLabels(array<label> vp_owned) =>
    while array.size(vp_owned) > 0
        label.delete(array.pop(vp_owned))

// Ordinary var storage deliberately participates in rollback. The open bar is
// re-ingested from its latest snapshot after each rollback, then committed once.
// Never use varip here: repeated ticks would otherwise duplicate live volume.
var array<vp_Sample> vp_samples = array.new<vp_Sample>()
var int vp_cachedBarTime = na
var int vp_startTime = na
var int vp_rangeBars = 0
var float vp_rangeLow = na
var float vp_rangeHigh = na
var bool vp_anchorBeforeHistory = false
var bool vp_overSampleCap = false
var int vp_fallbackBars = 0
var int vp_incompleteBars = 0
var int vp_missingVolumeBars = 0
var int vp_lastCoveredEnd = na
var array<box> vp_boxes = array.new<box>()
var array<line> vp_lines = array.new<line>()
var array<label> vp_labels = array.new<label>()
var polyline vp_developingPoc = na
// Closed prefixes use ordinary rollback-owned storage. A new range/grid or
// thinning stride rebuilds exactly; stable grids allocate only new samples.
var array<float> vp_cachedTotals = array.new<float>(vp_rowCount, 0.0)
var array<float> vp_cachedUpTotals = array.new<float>(vp_rowCount, 0.0)
var array<chart.point> vp_cachedPoints = array.new<chart.point>()
var float vp_cachedLow = na
var float vp_cachedStep = na
var float vp_cachedMax = 0.0
var int vp_cachedPoc = 0
var int vp_computedCount = 0
var int vp_cachedStride = 0
var int vp_nextPoint = 0
var int vp_lastPointSample = -1
var line vp_anchorLine = na
var label vp_anchorTag = na

float vp_pocLevel = na
float vp_vahLevel = na
float vp_valLevel = na
string vp_coverageMessage = ""

var string vp_sourceTf = timeframe.period
float vp_chartSeconds = timeframe.in_seconds(timeframe.period)
if barstate.isfirst
    // Preload the finest eligible context before the anchor. A realtime-only
    // anchor chooses this same context, so it never introduces an unseen request.
    vp_sourceTf := vp_chooseTimeframe(vp_chartSeconds, 0.0)

bool vp_containsAnchor = time <= anchorTime and not na(time_close) and anchorTime < time_close
var int vp_visibleStart = na
if na(vp_visibleStart) and (vp_containsAnchor or time >= anchorTime)
    vp_visibleStart := time
float vp_anchorHeight = high + math.max(nz(ta.atr(14)), syminfo.mintick) * 0.4
if showVP and na(vp_startTime) and (vp_containsAnchor or time >= anchorTime)
    vp_startTime := time
    vp_anchorBeforeHistory := barstate.isfirst and anchorTime < time
    float vp_rangeDuration = not na(vp_chartSeconds) ? vp_sourceBudget(vp_chartSeconds, bar_index, last_bar_index) : 0.0
    vp_sourceTf := vp_chooseTimeframe(vp_chartSeconds, vp_rangeDuration)

// Selection freezes at the selected starting candle for this run. Count chart
// candles rather than elapsed calendar time, preserving DGT source resolution.
// Unconditional historical requests preload both the initial and chosen context.
[vp_ltfTimes, vp_ltfEnds, vp_ltfOpens, vp_ltfHighs, vp_ltfLows, vp_ltfCloses, vp_ltfVolumes] = request.security_lower_tf(syminfo.tickerid, vp_sourceTf, [time, time_close, open, high, low, close, volume], ignore_invalid_timeframe = true, calc_bars_count = 100000)
bool vp_chartSource = not na(vp_chartSeconds) and timeframe.in_seconds(vp_sourceTf) == vp_chartSeconds

if showVP and not na(vp_startTime) and (na(vp_cachedBarTime) or vp_cachedBarTime != time)
    vp_cachedBarTime := time
    vp_rangeBars += 1
    if not na(low) and not na(high)
        vp_rangeLow := na(vp_rangeLow) ? low : math.min(vp_rangeLow, low)
        vp_rangeHigh := na(vp_rangeHigh) ? high : math.max(vp_rangeHigh, high)
    int vp_barEnd = barstate.isrealtime ? timenow : not na(time_close) ? time_close : time
    int vp_intrabarCount = array.size(vp_ltfVolumes)
    int vp_validIntrabars = 0
    float vp_intrabarVolume = 0.0
    bool vp_invalidIntrabar = false

    if not vp_chartSource and vp_intrabarCount > 0
        for vp_intrabar = 0 to vp_intrabarCount - 1
            float vp_sampleHigh = array.get(vp_ltfHighs, vp_intrabar)
            float vp_sampleLow = array.get(vp_ltfLows, vp_intrabar)
            float vp_sampleVolume = array.get(vp_ltfVolumes, vp_intrabar)
            float vp_sampleOpen = array.get(vp_ltfOpens, vp_intrabar)
            float vp_sampleClose = array.get(vp_ltfCloses, vp_intrabar)
            bool vp_validSample = not na(vp_sampleHigh) and not na(vp_sampleLow) and vp_sampleHigh >= vp_sampleLow and not na(vp_sampleVolume) and vp_sampleVolume >= 0 and not na(vp_sampleOpen) and not na(vp_sampleClose)
            if vp_validSample
                vp_validIntrabars += 1
                vp_intrabarVolume += vp_sampleVolume
                if array.size(vp_samples) < vp_sampleCap
                    int vp_sourceEnd = array.get(vp_ltfEnds, vp_intrabar)
                    int vp_retainedEnd = not na(vp_sourceEnd) ? math.min(vp_barEnd, vp_sourceEnd) : vp_barEnd
                    array.push(vp_samples, vp_Sample.new(vp_sampleHigh, vp_sampleLow, vp_sampleVolume, vp_sampleClose > vp_sampleOpen, time, vp_retainedEnd))
                    vp_lastCoveredEnd := vp_retainedEnd
                else
                    vp_overSampleCap := true
            else
                vp_invalidIntrabar := true

    // Equal-TF data uses its own chart candle. Empty or wholly invalid LTF data
    // uses chart OHLC as an explicit approximation; missing volume remains missing.
    if vp_chartSource or vp_validIntrabars == 0
        if not vp_chartSource
            vp_fallbackBars += 1
        if not na(volume) and volume >= 0 and not na(open) and not na(close) and not na(high) and not na(low)
            if array.size(vp_samples) < vp_sampleCap
                array.push(vp_samples, vp_Sample.new(high, low, volume, close > open, time, vp_barEnd))
                vp_lastCoveredEnd := vp_barEnd
            else
                vp_overSampleCap := true
        else
            vp_missingVolumeBars += 1
    else
        // A confirmed chart-volume shortfall reveals truncated/incomplete source
        // coverage. Do not pad it with chart volume and double-count valid samples.
        bool vp_volumeShortfall = barstate.isconfirmed and not na(volume) and volume > 0 and vp_intrabarVolume < volume * 0.999
        if vp_invalidIntrabar or vp_volumeShortfall
            vp_incompleteBars += 1

if showVP and (barstate.islastconfirmedhistory or barstate.islast) and vp_samples.size() > 0 and not na(vp_rangeLow) and not na(vp_rangeHigh)
    bool vp_flat = vp_rangeHigh <= vp_rangeLow
    float vp_grid = vp_flat ? vp_rangeLow - syminfo.mintick * 0.5 : vp_rangeLow
    float vp_gridStep = vp_flat ? syminfo.mintick / vp_rowCount : (vp_rangeHigh - vp_rangeLow) / vp_rowCount
    int vp_count = vp_samples.size()
    int vp_stride = math.max(1, int(math.ceil(float(vp_count) / (vp_pointCap - 2))))
    if vp_cacheReset(vp_cachedLow, vp_cachedStep, vp_grid, vp_gridStep, vp_cachedStride, vp_stride, vp_computedCount, vp_count)
        vp_cachedTotals.fill(0.0)
        vp_cachedUpTotals.fill(0.0)
        vp_cachedPoints.clear()
        vp_cachedMax := 0.0
        vp_cachedPoc := 0
        vp_computedCount := 0
        vp_nextPoint := 0
        vp_lastPointSample := -1
    vp_cachedLow := vp_grid
    vp_cachedStep := vp_gridStep
    vp_cachedStride := vp_stride
    if vp_computedCount < vp_count
        for vp_sampleIndex = vp_computedCount to vp_count - 1
            vp_Sample vp_sample = vp_samples.get(vp_sampleIndex)
            int vp_firstRow = math.max(0, math.min(vp_rowCount - 1, int(math.floor((vp_sample.vp_low - vp_grid) / vp_gridStep))))
            int vp_lastRow = math.max(0, math.min(vp_rowCount - 1, int(math.floor((vp_sample.vp_high - vp_grid) / vp_gridStep))))
            for vp_row = vp_firstRow to vp_lastRow
                float vp_rowLow = vp_grid + vp_row * vp_gridStep
                float vp_fraction = vp_sample.vp_high == vp_sample.vp_low ? 1.0 : vp_overlapFraction(vp_sample.vp_low, vp_sample.vp_high, vp_rowLow, vp_rowLow + vp_gridStep, syminfo.mintick)
                float vp_allocated = vp_sample.vp_volume * vp_fraction
                float vp_updated = vp_cachedTotals.get(vp_row) + vp_allocated
                vp_cachedTotals.set(vp_row, vp_updated)
                [vp_newMax, vp_newPoc] = vp_maxAfterAdd(vp_cachedMax, vp_cachedPoc, vp_updated, vp_row)
                vp_cachedMax := vp_newMax
                vp_cachedPoc := vp_newPoc
                if vp_sample.vp_up
                    vp_cachedUpTotals.set(vp_row, vp_cachedUpTotals.get(vp_row) + vp_allocated)
            bool vp_barBoundary = vp_sampleIndex == vp_count - 1
            if not vp_barBoundary
                vp_barBoundary := vp_samples.get(vp_sampleIndex + 1).vp_barTime != vp_sample.vp_barTime
            if vp_barBoundary and vp_sampleIndex >= vp_nextPoint and vp_cachedMax > 0
                float vp_price = vp_grid + (vp_cachedPoc + 0.5) * vp_gridStep
                if vp_cachedPoints.size() == 0
                    vp_cachedPoints.push(chart.point.from_time(vp_sample.vp_barTime, vp_price))
                if vp_cachedPoints.size() < vp_pointCap
                    vp_cachedPoints.push(chart.point.from_time(vp_sample.vp_barEnd, vp_price))
                    vp_lastPointSample := vp_sampleIndex
                vp_nextPoint := vp_sampleIndex + vp_stride
        vp_computedCount := vp_count

if barstate.islast
    if (showVP or showFlowSummary) and not na(vp_visibleStart)
        if na(vp_anchorLine)
            vp_anchorLine := line.new(vp_visibleStart, low, vp_visibleStart, high + syminfo.mintick, xloc=xloc.bar_time, extend=extend.both, color=color.new(#F4B740, 40), style=line.style_dashed, force_overlay=true)
            vp_anchorTag := label.new(vp_visibleStart, vp_anchorHeight, "VP START", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(#F4B740, 70), textcolor=#F4B740, size=size.tiny, tooltip="VP + CVD start\nSelect Value & Flow, then drag this time marker.", force_overlay=true)
        else
            label.set_y(vp_anchorTag, vp_anchorHeight)
    else if not na(vp_anchorLine)
        line.delete(vp_anchorLine)
        label.delete(vp_anchorTag)
        vp_anchorLine := na
        vp_anchorTag := na
    vp_clearBoxes(vp_boxes)
    vp_clearLines(vp_lines)
    vp_clearLabels(vp_labels)
    if not na(vp_developingPoc)
        polyline.delete(vp_developingPoc)
        vp_developingPoc := na

    if showVP
        // Coverage bookkeeping remains internal; no cumulative coverage banner.
        int vp_sampleCount = array.size(vp_samples)
        if vp_sampleCount > 0 and not na(vp_rangeLow) and not na(vp_rangeHigh)
            // Flat ranges receive one tick of total height centred on their price.
            // The containing row is unambiguous; no division by zero is possible.
            bool vp_flatRange = vp_rangeHigh <= vp_rangeLow
            float vp_gridLow = vp_flatRange ? vp_rangeLow - syminfo.mintick * 0.5 : vp_rangeLow
            float vp_step = vp_flatRange ? syminfo.mintick / vp_rowCount : (vp_rangeHigh - vp_rangeLow) / vp_rowCount
            array<float> vp_totals = vp_cachedTotals
            array<float> vp_upTotals = vp_cachedUpTotals
            // The forced live endpoint is a display copy, never a cached stride
            // boundary that could change the next bar's thinning decision.
            array<chart.point> vp_points = array.copy(vp_cachedPoints)
            if vp_lastPointSample != vp_sampleCount - 1 and vp_points.size() < vp_pointCap and vp_cachedMax > 0
                vp_Sample vp_tail = vp_samples.get(vp_sampleCount - 1)
                vp_points.push(chart.point.from_time(vp_tail.vp_barEnd, vp_gridLow + (vp_cachedPoc + 0.5) * vp_step))
            float vp_maxVolume = vp_cachedMax
            if vp_maxVolume > 0
                [vp_pocRow, vp_lowerRow, vp_upperRow] = vp_valueArea(vp_totals, vp_valueFraction)
                vp_pocLevel := vp_gridLow + (vp_pocRow + 0.5) * vp_step
                vp_vahLevel := vp_gridLow + (vp_upperRow + 1.0) * vp_step
                vp_valLevel := vp_gridLow + vp_lowerRow * vp_step
                // Preserve the original 31% proportional scale and its rounding.
                // Capping at 24 bars erased smaller up/down and sentiment nodes.
                float vp_profileWidth = vp_displayScale(vp_rangeBars)
                int vp_profileRight = bar_index + int(13 + vp_profileWidth)
                int vp_maxSentimentWidth = 0
                int vp_rangeEnd = barstate.isrealtime ? timenow : not na(time_close) ? time_close : time
                int vp_zoneStart = na
                bool vp_zoneAbovePoc = false
                int vp_zoneDrawn = 0
                int vp_zoneFound = 0
                int vp_gapDrawn = 0
                int vp_gapFound = 0

                // Merge adjacent thin rows, retaining the source's red-above-POC
                // and blue-below-POC meaning. These bands end at the latest bar.
                for vp_row = 0 to vp_rowCount
                    bool vp_thinRow = false
                    bool vp_abovePoc = vp_row > vp_pocRow
                    if vp_row < vp_rowCount
                        vp_thinRow := array.get(vp_totals, vp_row) / vp_maxVolume < vp_thinFraction
                    bool vp_closeZone = not na(vp_zoneStart) and (not vp_thinRow or vp_abovePoc != vp_zoneAbovePoc)
                    if vp_closeZone
                        vp_zoneFound += 1
                        if vp_zoneDrawn < vp_zoneCap
                            color vp_zoneColor = vp_zoneAbovePoc ? color.new(#ec1313, 80) : color.new(#0094FF, 80)
                            array.push(vp_boxes, box.new(left = vp_startTime, top = vp_gridLow + vp_row * vp_step, right = vp_rangeEnd, bottom = vp_gridLow + vp_zoneStart * vp_step, xloc = xloc.bar_time, border_color = na, bgcolor = vp_zoneColor, force_overlay = true))
                            vp_zoneDrawn += 1
                        vp_zoneStart := na
                    if vp_thinRow and na(vp_zoneStart)
                        vp_zoneStart := vp_row
                        vp_zoneAbovePoc := vp_abovePoc

                // Strict minima over seven neighbouring nodes on each side,
                // matching the original 7% neighbourhood at 100 rows.
                for vp_row = 0 to vp_rowCount - 1
                    float vp_nodeVolume = array.get(vp_totals, vp_row)
                    bool vp_gapNode = true
                    for vp_distance = 1 to vp_gapNeighbors
                        float vp_lowerNeighbor = vp_row - vp_distance >= 0 ? array.get(vp_totals, vp_row - vp_distance) : vp_maxVolume
                        float vp_upperNeighbor = vp_row + vp_distance < vp_rowCount ? array.get(vp_totals, vp_row + vp_distance) : vp_maxVolume
                        if vp_nodeVolume >= vp_lowerNeighbor or vp_nodeVolume >= vp_upperNeighbor
                            vp_gapNode := false
                            break
                    if vp_gapNode
                        vp_gapFound += 1
                        if vp_gapDrawn < vp_gapCap
                            // Time coordinates preserve distant anchors; the index
                            // bridge meets the VP stem exactly, even across sessions.
                            array.push(vp_boxes, box.new(left = vp_startTime, top = vp_gridLow + (vp_row + 0.9) * vp_step, right = time, bottom = vp_gridLow + (vp_row + 0.1) * vp_step, xloc = xloc.bar_time, border_color = na, bgcolor = color.new(#ff9800, 80), force_overlay = true))
                            array.push(vp_boxes, box.new(left = bar_index, top = vp_gridLow + (vp_row + 0.9) * vp_step, right = vp_profileRight, bottom = vp_gridLow + (vp_row + 0.1) * vp_step, xloc = xloc.bar_index, border_color = na, bgcolor = color.new(#ff9800, 80), force_overlay = true))
                            vp_gapDrawn += 1

                // At most 300 row boxes, 20 thin bands and 20 gap/bridge boxes.
                // Together with 80 spike boxes, the shared maximum is 420 of 500.
                for vp_row = 0 to vp_rowCount - 1
                    float vp_rowVolume = array.get(vp_totals, vp_row)
                    float vp_upVolume = array.get(vp_upTotals, vp_row)
                    float vp_downVolume = math.max(vp_rowVolume - vp_upVolume, 0.0)
                    bool vp_insideValue = vp_row >= vp_lowerRow and vp_row <= vp_upperRow
                    float vp_rowTop = vp_gridLow + (vp_row + 0.9) * vp_step
                    float vp_rowBottom = vp_gridLow + (vp_row + 0.1) * vp_step
                    int vp_upLeftIndex = vp_upLeft(vp_profileRight, vp_upVolume, vp_maxVolume, vp_profileWidth)
                    int vp_downLeft = vp_upLeftIndex - int(vp_downVolume / vp_maxVolume * vp_profileWidth)
                    if vp_upVolume > 0
                        array.push(vp_boxes, box.new(left = vp_upLeftIndex, top = vp_rowTop, right = vp_profileRight, bottom = vp_rowBottom, border_color = na, bgcolor = vp_insideValue ? color.new(#2962ff, 30) : color.new(#5d606b, 50), force_overlay = true))
                    if vp_downVolume > 0
                        array.push(vp_boxes, box.new(left = vp_downLeft, top = vp_rowTop, right = vp_upLeftIndex, bottom = vp_rowBottom, border_color = na, bgcolor = vp_insideValue ? color.new(#fbc02d, 30) : color.new(#d1d4dc, 50), force_overlay = true))
                    float vp_sentiment = 2.0 * vp_upVolume - vp_rowVolume
                    int vp_sentimentWidth = int(math.abs(vp_sentiment) / vp_maxVolume * vp_profileWidth)
                    vp_maxSentimentWidth := math.max(vp_maxSentimentWidth, vp_sentimentWidth)
                    if vp_sentimentWidth > 0
                        array.push(vp_boxes, box.new(left = vp_profileRight + 1, top = vp_rowTop, right = vp_profileRight + 1 + vp_sentimentWidth, bottom = vp_rowBottom, border_color = na, bgcolor = vp_sentiment > 0 ? color.new(#26a69a, 30) : color.new(#ef5350, 30), force_overlay = true))

                // Match the source: outward price-only tags at the sentiment edge.
                // VAH/VAL use index bridges to reach the VP stem without guessing
                // future timestamps on instruments with nontrading session gaps.
                int vp_labelIndex = vp_profileRight + vp_maxSentimentWidth
                array.push(vp_lines, line.new(x1 = vp_startTime, y1 = vp_vahLevel, x2 = time, y2 = vp_vahLevel, xloc = xloc.bar_time, color = #2962ff, width = 1, force_overlay = true))
                array.push(vp_lines, line.new(x1 = bar_index, y1 = vp_vahLevel, x2 = vp_profileRight, y2 = vp_vahLevel, xloc = xloc.bar_index, color = #2962ff, width = 1, force_overlay = true))
                array.push(vp_lines, line.new(x1 = vp_startTime, y1 = vp_valLevel, x2 = time, y2 = vp_valLevel, xloc = xloc.bar_time, color = #2962ff, width = 1, force_overlay = true))
                array.push(vp_lines, line.new(x1 = bar_index, y1 = vp_valLevel, x2 = vp_profileRight, y2 = vp_valLevel, xloc = xloc.bar_index, color = #2962ff, width = 1, force_overlay = true))
                array.push(vp_labels, label.new(x = vp_labelIndex, y = vp_pocLevel, text = str.tostring(vp_pocLevel, format.mintick), style = label.style_label_left, color = color.new(#f44336, 89), textcolor = #f44336, size = size.small, textalign = text.align_left, tooltip = "POC · volume centre\nWatch price hold here or move through.", force_overlay = true))
                array.push(vp_labels, label.new(x = vp_labelIndex, y = vp_vahLevel, text = str.tostring(vp_vahLevel, format.mintick), style = label.style_label_left, color = color.new(#2962ff, 89), textcolor = #2962ff, size = size.small, textalign = text.align_left, tooltip = "VAH · upper value edge\nWatch a hold above or return inside.", force_overlay = true))
                array.push(vp_labels, label.new(x = vp_labelIndex, y = vp_valLevel, text = str.tostring(vp_valLevel, format.mintick), style = label.style_label_left, color = color.new(#2962ff, 89), textcolor = #2962ff, size = size.small, textalign = text.align_left, tooltip = "VAL · lower value edge\nWatch a hold below or return inside.", force_overlay = true))
                if array.size(vp_points) >= 2
                    vp_developingPoc := polyline.new(vp_points, curved = false, closed = false, xloc = xloc.bar_time, line_color = #f44336, line_width = 2, force_overlay = true)
                if vp_zoneFound > vp_zoneCap or vp_gapFound > vp_gapCap
                    vp_coverageMessage += (str.length(vp_coverageMessage) > 0 ? "\n" : "") + "Zone/gap display capped at 30 highlights"
            else
                vp_coverageMessage += (str.length(vp_coverageMessage) > 0 ? "\n" : "") + "VP has no traded volume in available data"
        else
            vp_coverageMessage += (str.length(vp_coverageMessage) > 0 ? "\n" : "") + (na(vp_startTime) ? "VP anchor is beyond available bars" : "VP has no usable price/volume data")

        if str.length(vp_coverageMessage) > 0
            array.push(vp_labels, label.new(x = bar_index + 13, y = not na(vp_rangeHigh) ? vp_rangeHigh : high, text = vp_coverageMessage, style = label.style_label_lower_left, color = color.new(color.orange, 80), textcolor = chart.fg_color, size = size.small, force_overlay = true))

// Original LTF delta calculation. Empty source anchor resets per chart bar.
// One affine transformation is applied to the WHOLE displayed segment at refresh.
// No rolling per-point baseline is introduced, and raw values remain unchanged.
delta_signedVolume() =>
    var bool delta_buyDirection = true
    delta_buyDirection := delta_classify(open, close, close[1], delta_buyDirection)
    delta_buyDirection ? volume : -volume

string delta_lowerTF = timeframe.isseconds ? "1S" : timeframe.isintraday ? (timeframe.in_seconds() <= 300 ? "1S" : "1") : timeframe.isdaily ? "5" : "60"
array<float> delta_intrabarVolumes = request.security_lower_tf(syminfo.tickerid, delta_lowerTF, delta_signedVolume(), ignore_invalid_timeframe = true)
bool delta_hasIntrabars = delta_intrabarVolumes.size() > 0
float delta_raw = na
if delta_hasIntrabars
    delta_raw := delta_intrabarVolumes.sum()
float delta_smoothed = ta.sma(delta_raw, 14)
// The original "All" preset begins smoothing at one minute; retain seconds behaviour.
float delta_value = timeframe.in_seconds() >= 60 ? delta_smoothed : delta_raw
float delta_absMean = ta.sma(math.abs(delta_raw), 20)
bool delta_aboveThreshold = not na(delta_raw) and not na(delta_absMean) and math.abs(delta_raw) > delta_absMean * 1.5
color delta_colour = delta_aboveThreshold ? (delta_raw >= 0 ? #00C853 : #FF1744) : #2962FF
float delta_displayValue = delta_hasIntrabars ? delta_value : na
plot(delta_displayValue, "Delta line • raw volume units", color = delta_colour, display = display.data_window, format = format.volume)

const int DELTA_SEGMENT_BARS = 180
var array<int> delta_times = array.new<int>()
var array<float> delta_values = array.new<float>()
var array<color> delta_colours = array.new<color>()
var array<line> delta_segments = array.new<line>()
var int delta_cachedBar = na
if na(delta_cachedBar) or delta_cachedBar != bar_index
    delta_times.push(time)
    delta_values.push(delta_displayValue)
    delta_colours.push(delta_colour)
    delta_cachedBar := bar_index
    if delta_times.size() > DELTA_SEGMENT_BARS
        delta_times.shift()
        delta_values.shift()
        delta_colours.shift()

float delta_priceCentre = ta.ema(close, 50)
float delta_priceATR = ta.atr(20)
string delta_statusMessage = ""
if showDeltaLine and not delta_hasIntrabars
    delta_statusMessage := "Delta line: intrabar history unavailable"

if barstate.islast
    while delta_segments.size() > 0
        line.delete(delta_segments.pop())
    if showDeltaLine and delta_values.size() >= 2 and not na(delta_priceATR)
        float delta_lowest = na
        float delta_highest = na
        for delta_i = 0 to delta_values.size() - 1
            float delta_sample = delta_values.get(delta_i)
            if not na(delta_sample)
                delta_lowest := na(delta_lowest) ? delta_sample : math.min(delta_lowest, delta_sample)
                delta_highest := na(delta_highest) ? delta_sample : math.max(delta_highest, delta_sample)
        if not na(delta_lowest)
            float delta_origin = (delta_lowest + delta_highest) * 0.5
            float delta_spread = delta_highest - delta_lowest
            float delta_scale = delta_spread > 0 ? math.max(delta_priceATR, syminfo.mintick) * 3.0 / delta_spread : 0.0
            for delta_i = 1 to delta_values.size() - 1
                float delta_previous = delta_values.get(delta_i - 1)
                float delta_current = delta_values.get(delta_i)
                if not na(delta_previous) and not na(delta_current)
                    float delta_y1 = delta_affine(delta_previous, delta_origin, delta_scale, delta_priceCentre)
                    float delta_y2 = delta_affine(delta_current, delta_origin, delta_scale, delta_priceCentre)
                    delta_segments.push(line.new(delta_times.get(delta_i - 1), delta_y1, delta_times.get(delta_i), delta_y2,
                         xloc = xloc.bar_time, color = delta_colours.get(delta_i), width = 2, force_overlay = true))

// Footprint Insights, adapted from CVD Divergence Insights.
// This portion is subject to the Mozilla Public License 2.0:
// https://mozilla.org/MPL/2.0/ — © colicoid.
// The chart-timeframe default uses per-bar footprint delta, not anchored CVD.

const int flow_MAX_NATIVE_ROWS = 2000
const int flow_MAX_CLUSTER_KEYS = 8000
const int flow_PROFILE_ROWS = 16
const int flow_KEEP_CLUSTERS = 4
const int flow_KEEP_LABELS = 16
const int flow_CONCENTRATION_WINDOW = 500
const int flow_MIN_BASELINE = 20

// Rendering policy only: qualification and native-row measurements are intact.
// Consecutive nearby same-side concentrations show the strongest measured row.
// Return 0 to suppress, 1 to append, or 2 to replace the preceding dot.
flow_concentrationAction(int previousBar, float previousPrice, float previousDelta, int currentBar, float currentPrice, float currentDelta, float nearDistance) =>
    int action = 1
    if not na(previousBar) and not na(previousPrice) and not na(previousDelta)
        if currentBar > previousBar and currentBar - previousBar <= 3 and previousDelta * currentDelta > 0
            if math.abs(currentPrice - previousPrice) <= nearDistance
                if math.abs(currentDelta) > math.abs(previousDelta)
                    action := 2
                else
                    action := 0
    action

flow_concentrationStrength(float absoluteDelta, float priorDecile) =>
    int strength = 0
    if priorDecile > 0
        if absoluteDelta >= 2.0 * priorDecile
            strength := 2
        else if absoluteDelta >= 1.5 * priorDecile
            strength := 1
    strength

// Resolution is fixed for the entire execution. Fine chart rows stay fine on
// instruments such as SOL; it cannot change with a series price or ATR.
simple int flow_chartSeconds = timeframe.in_seconds()
simple int flow_baseTicks = flow_chartSeconds <= 300 ? 1 : flow_chartSeconds <= 1800 ? 5 : flow_chartSeconds <= 14400 ? 10 : flow_chartSeconds <= 86400 ? 25 : 50
simple int flow_tickScale = syminfo.mintick < 0.000001 ? 5 : 1
simple int flow_nativeTicks = flow_baseTicks * flow_tickScale
footprint flow_fp = request.footprint(flow_nativeTicks, 70)
bool flow_hasFootprint = not na(flow_fp)
float flow_delta = flow_hasFootprint ? flow_fp.delta() : na
float flow_barVolume = flow_hasFootprint ? flow_fp.total_volume() : na
bool flow_validData = flow_hasFootprint and not na(flow_delta) and not na(flow_barVolume)

// Preserve the source EMA14 / EMA14 mean / 14-bar deviation normalization.
// A measured flat series has z-score zero; unavailable data remains a gap.
float flow_priceMa = ta.ema(close, 14)
float flow_pressureMa = ta.ema(flow_delta, 14)
float flow_priceMean = ta.ema(flow_priceMa, 14)
float flow_pressureMean = ta.ema(flow_pressureMa, 14)
float flow_priceStd = ta.stdev(flow_priceMa, 14)
float flow_pressureStd = ta.stdev(flow_pressureMa, 14)
float flow_priceNorm = not na(flow_priceStd) ? (flow_priceStd > 0 ? (flow_priceMa - flow_priceMean) / flow_priceStd : 0.0) : na
float flow_pressureNorm = not na(flow_pressureStd) ? (flow_pressureStd > 0 ? (flow_pressureMa - flow_pressureMean) / flow_pressureStd : 0.0) : na
float flow_rawOscillator = flow_validData ? flow_pressureNorm - flow_priceNorm : na
float flow_volumeMa = ta.ema(flow_barVolume, 50)
float flow_volumeFactor = flow_validData and flow_volumeMa > 0 ? flow_barVolume / flow_volumeMa : na
float flow_oscillator = flow_rawOscillator * flow_volumeFactor
float flow_signal = ta.ema(flow_oscillator, 5)
float flow_spikeMean = ta.sma(flow_oscillator, 50)
float flow_spikeStd = ta.stdev(flow_oscillator, 50)
bool flow_isSpike = flow_validData and not na(flow_spikeStd) and math.abs(flow_oscillator - flow_spikeMean) > 2.0 * flow_spikeStd
int flow_newSide = flow_spikeSide(flow_isSpike, flow_oscillator)
bool flow_positiveSpike = flow_newSide > 0
bool flow_negativeSpike = flow_newSide < 0

// Green means positive pressure exceeds the price result: aggressive buying
// may be absorbed by passive sellers. Red means the opposite pressure gap:
// aggressive selling may be absorbed by passive buyers. These are pressure
// colors, not promises of a bullish/ bearish price outcome.
plot(showInsights ? flow_oscillator : na, title="Footprint Insights", color=flow_oscillator >= 0 ? color.new(color.green, 60) : color.new(color.red, 60), style=plot.style_areabr)
hline(0, title="Insights zero", color=color.gray, linestyle=hline.style_dashed, display=showInsights ? display.all : display.none)
plot(showInsights and flow_validData ? flow_signal : na, title="Insights signal EMA5", color=color.blue, display=display.none)
plotshape(showInsights and flow_positiveSpike, title="Positive pressure spike", style=shape.circle, location=location.top, color=color.green, size=size.tiny)
plotshape(showInsights and flow_negativeSpike, title="Negative pressure spike", style=shape.circle, location=location.bottom, color=color.red, size=size.tiny)

float flow_cloudAtr = ta.atr(20)
float flow_cloudPrice = flow_validData ? flow_priceMa + flow_priceNorm * flow_cloudAtr : na
float flow_cloudPressure = flow_validData ? flow_priceMa + flow_pressureNorm * flow_cloudAtr : na
flow_cloudPricePlot = plot(showCloud ? flow_cloudPrice : na, title="Cloud price edge", color=color.new(color.gray, 50), style=plot.style_linebr, force_overlay=true, display=display.pane)
flow_cloudPressurePlot = plot(showCloud ? flow_cloudPressure : na, title="Cloud pressure edge", color=color.new(color.gray, 50), style=plot.style_linebr, force_overlay=true, display=display.pane)
fill(flow_cloudPricePlot, flow_cloudPressurePlot, color=showCloud ? color.new(flow_cloudPressure >= flow_cloudPrice ? color.green : color.red, 90) : na, title="Absorption cloud", fillgaps=false)

// Scan actual native rows once. An oversized or malformed row array is never
// truncated and never substituted with estimated lower-timeframe delta.
array<volume_row> flow_rows = flow_hasFootprint ? flow_fp.rows() : array.new<volume_row>()
int flow_rowCount = array.size(flow_rows)
bool flow_rowsTooLarge = flow_rowCount > flow_MAX_NATIVE_ROWS
bool flow_rowsReady = flow_validData and flow_rowCount > 0 and not flow_rowsTooLarge
// Basic Insights readiness stays independent of strict auction/flow evidence.
// Their row predicates are identical; one pass shares validation and sums,
// retaining native order and NA propagation without caching extra row objects.
bool flow_rowsStrict = flow_rowsReady
float flow_rowsTotal = 0.0
float flow_rowsBuy = 0.0
float flow_rowsSell = 0.0
float flow_rowsDelta = 0.0
float flow_largestRowDelta = na
float flow_largestRowPrice = na
if flow_rowsReady
    for flow_row in flow_rows
        float flow_rowDelta = flow_row.delta()
        float flow_rowLow = flow_row.down_price()
        float flow_rowHigh = flow_row.up_price()
        float flow_rowTotal = flow_row.total_volume()
        float flow_rowBuy = flow_row.buy_volume()
        float flow_rowSell = flow_row.sell_volume()
        if na(flow_rowDelta) or na(flow_rowLow) or na(flow_rowHigh) or flow_rowHigh <= flow_rowLow
            flow_rowsReady := false
        else if na(flow_largestRowDelta) or math.abs(flow_rowDelta) > math.abs(flow_largestRowDelta)
            flow_largestRowDelta := flow_rowDelta
            flow_largestRowPrice := (flow_rowLow + flow_rowHigh) * 0.5
        flow_rowsStrict := flow_rowsStrict and of_rowUsable(flow_rowTotal, flow_rowBuy, flow_rowSell, flow_rowDelta, flow_rowLow, flow_rowHigh)
        flow_rowsTotal += flow_rowTotal
        flow_rowsBuy += flow_rowBuy
        flow_rowsSell += flow_rowSell
        flow_rowsDelta += flow_rowDelta
flow_rowsStrict := flow_rowsStrict and flow_rowsReady
if not flow_rowsReady
    flow_largestRowDelta := na
    flow_largestRowPrice := na

// Completed drawings own complete groups; deleting an old group deletes every
// box in it. The separate open-group owner is replaceable on the last bar.
type flow_ProfileDrawing
    array<box> flow_boxes

flow_deleteBoxes(array<box> flow_ownedBoxes) =>
    while array.size(flow_ownedBoxes) > 0
        box.delete(array.pop(flow_ownedBoxes))
    array.size(flow_ownedBoxes)

// Keys are absolute integer tick prices frozen at the requested resolution.
// The whole spike is preflighted before mutation, preserving signed totals.
flow_mergeRows(map<int, float> flow_destination, array<volume_row> flow_source) =>
    int flow_newKeys = 0
    for flow_row in flow_source
        int flow_key = int(math.round(flow_row.down_price() / syminfo.mintick))
        if not map.contains(flow_destination, flow_key)
            flow_newKeys += 1
    bool flow_fits = map.size(flow_destination) + flow_newKeys <= flow_MAX_CLUSTER_KEYS
    if flow_fits
        for flow_row in flow_source
            int flow_key = int(math.round(flow_row.down_price() / syminfo.mintick))
            float flow_previous = map.contains(flow_destination, flow_key) ? map.get(flow_destination, flow_key) : 0.0
            map.put(flow_destination, flow_key, flow_previous + flow_row.delta())
    flow_fits

// Display aggregation never alters the frozen native accumulation. Preserve
// the source's horizontal footprint bands: equal width, signed color, and
// opacity based on each displayed row's absolute delta (85 down to 15).
flow_drawProfile(map<int, float> flow_values, int flow_leftTime, int flow_rightTime, array<box> flow_ownedBoxes) =>
    array<int> flow_keys = map.keys(flow_values)
    int flow_keyCount = array.size(flow_keys)
    if flow_keyCount > 0
        int flow_minKey = array.min(flow_keys)
        int flow_maxKey = array.max(flow_keys) + flow_nativeTicks
        int flow_binTicks = math.max(flow_nativeTicks, int(math.ceil(float(flow_maxKey - flow_minKey) / flow_PROFILE_ROWS / flow_nativeTicks)) * flow_nativeTicks)
        array<float> flow_bins = array.new<float>(flow_PROFILE_ROWS, 0.0)
        for flow_key in flow_keys
            int flow_bin = math.min(flow_PROFILE_ROWS - 1, int(math.floor(float(flow_key - flow_minKey) / flow_binTicks)))
            array.set(flow_bins, flow_bin, array.get(flow_bins, flow_bin) + map.get(flow_values, flow_key))
        float flow_maxAbs = 0.0
        for flow_value in flow_bins
            flow_maxAbs := math.max(flow_maxAbs, math.abs(flow_value))
        if flow_maxAbs > 0
            for flow_bin = 0 to flow_PROFILE_ROWS - 1
                float flow_binDelta = array.get(flow_bins, flow_bin)
                if flow_binDelta != 0
                    float flow_bottom = (flow_minKey + flow_bin * flow_binTicks) * syminfo.mintick
                    float flow_top = math.min(flow_maxKey, flow_minKey + (flow_bin + 1) * flow_binTicks) * syminfo.mintick
                    float flow_padding = (flow_top - flow_bottom) * 0.08
                    int flow_transparency = int(math.round(85 - math.abs(flow_binDelta) / flow_maxAbs * 70))
                    color flow_color = color.new(flow_binDelta > 0 ? color.green : color.red, flow_transparency)
                    box flow_box = box.new(left=flow_leftTime, top=flow_top - flow_padding, right=flow_rightTime, bottom=flow_bottom + flow_padding, xloc=xloc.bar_time, border_color=na, bgcolor=flow_color, force_overlay=true)
                    array.push(flow_ownedBoxes, flow_box)
    array.size(flow_ownedBoxes)

var map<int, float> flow_clusterRows = map.new<int, float>()
var bool flow_clusterActive = false
var bool flow_clusterUsable = true
var int flow_clusterSide = 0
var int flow_clusterStartTime = na
var int flow_clusterEndTime = na
var int flow_clusterLastSpikeBar = na
var array<flow_ProfileDrawing> flow_completedProfiles = array.new<flow_ProfileDrawing>()
var array<box> flow_openBoxes = array.new<box>()
var int flow_oversizedBars = 0
var int flow_omittedClusters = 0

if barstate.isconfirmed
    if flow_rowsTooLarge
        flow_oversizedBars += 1
    if showSpikeProfiles
        // Membership is directional oscillator evidence, independent of row
        // availability. Unknown footprint cannot be treated as a known gap.
        if flow_clusterActive
            bool flow_previouslyUsable = flow_clusterUsable
            flow_clusterUsable := flow_clusterDataUsable(flow_clusterUsable, flow_validData, false, flow_rowsReady)
            if flow_previouslyUsable and not flow_clusterUsable
                flow_omittedClusters += 1
                map.clear(flow_clusterRows)
                flow_deleteBoxes(flow_openBoxes)
        bool flow_profileSpike = flow_newSide != 0
        int flow_action = flow_clusterAction(flow_clusterActive, flow_clusterSide, flow_clusterLastSpikeBar, bar_index, flow_profileSpike, flow_newSide, 1)
        if flow_action == 3 or flow_action == 4
            // Remove the provisional owner before retaining the closed group,
            // so four completed groups plus one open group never exceed 80.
            flow_deleteBoxes(flow_openBoxes)
            if flow_clusterUsable and map.size(flow_clusterRows) > 0
                if array.size(flow_completedProfiles) >= flow_KEEP_CLUSTERS
                    flow_ProfileDrawing flow_oldest = array.shift(flow_completedProfiles)
                    flow_deleteBoxes(flow_oldest.flow_boxes)
                array<box> flow_closedBoxes = array.new<box>()
                flow_drawProfile(flow_clusterRows, flow_clusterStartTime, flow_clusterEndTime, flow_closedBoxes)
                if array.size(flow_closedBoxes) > 0
                    array.push(flow_completedProfiles, flow_ProfileDrawing.new(flow_closedBoxes))
            map.clear(flow_clusterRows)
            flow_clusterActive := false
            flow_clusterUsable := true
            flow_clusterSide := 0
            flow_clusterStartTime := na
            flow_clusterEndTime := na
            flow_clusterLastSpikeBar := na
        if flow_action == 1 or flow_action == 4
            flow_clusterActive := true
            flow_clusterUsable := true
            flow_clusterSide := flow_newSide
            flow_clusterStartTime := time
        if flow_action == 1 or flow_action == 2 or flow_action == 4
            bool flow_previouslyUsable = flow_clusterUsable
            flow_clusterUsable := flow_clusterDataUsable(flow_clusterUsable, flow_validData, true, flow_rowsReady)
            if flow_previouslyUsable and not flow_clusterUsable
                // One unreadable actual member invalidates this entire group;
                // later valid members cannot recover its incomplete profile.
                flow_omittedClusters += 1
                map.clear(flow_clusterRows)
                flow_deleteBoxes(flow_openBoxes)
            if flow_clusterUsable and flow_rowsReady
                if not flow_mergeRows(flow_clusterRows, flow_rows)
                    // A cumulative native-row cap also omits the whole group.
                    flow_clusterUsable := false
                    flow_omittedClusters += 1
                    map.clear(flow_clusterRows)
                    flow_deleteBoxes(flow_openBoxes)
            flow_clusterLastSpikeBar := bar_index
            flow_clusterEndTime := na(time_close) ? time + 1 : time_close

// Preview only the confirmed native contributions of the open cluster.
// Last-bar rendering neither closes the cluster nor commits live-bar rows.
if barstate.islast
    flow_deleteBoxes(flow_openBoxes)
    if showSpikeProfiles and flow_clusterActive and flow_clusterUsable
        flow_drawProfile(flow_clusterRows, flow_clusterStartTime, flow_clusterEndTime, flow_openBoxes)

// Deliberate correction to the source: compare with prior valid observations,
// excluding the current bar and unavailable bars. Eviction is by chart-bar age
// (500 bars), not 500 non-missing samples. Twenty valid observations suffice
// for an adaptive baseline; no concentration is emitted during warmup.
var array<int> flow_baselineBars = array.new<int>()
var array<float> flow_baselineDeltas = array.new<float>()
var array<float> flow_baselineVolumes = array.new<float>()
type flow_ConcentrationMark
    label drawing
    int formed
    float price
    float delta

var array<flow_ConcentrationMark> flow_concentrationMarks = array.new<flow_ConcentrationMark>()
int flow_baselineCount = 0
if barstate.isconfirmed
    while array.size(flow_baselineBars) > 0
        if array.get(flow_baselineBars, 0) < bar_index - flow_CONCENTRATION_WINDOW
            array.shift(flow_baselineBars)
            array.shift(flow_baselineDeltas)
            array.shift(flow_baselineVolumes)
        else
            break
    flow_baselineCount := array.size(flow_baselineDeltas)
    // The same chart-age window governs relevance, independent of missing data.
    while array.size(flow_concentrationMarks) > 0
        flow_ConcentrationMark flow_oldestMark = array.get(flow_concentrationMarks, 0)
        if flow_oldestMark.formed < bar_index - flow_CONCENTRATION_WINDOW
            label.delete(flow_oldestMark.drawing)
            array.shift(flow_concentrationMarks)
        else
            break
    if showConcentrations and flow_rowsReady and flow_baselineCount >= flow_MIN_BASELINE
        float flow_averageVolume = array.avg(flow_baselineVolumes)
        bool flow_volumeFilter = flow_barVolume >= 0.8 * flow_averageVolume
        // Copy/sort only candidates that can pass the original cheap filters.
        if flow_volumeFilter and math.abs(flow_largestRowDelta) > 0
            array<float> flow_rankedDeltas = array.copy(flow_baselineDeltas)
            array.sort(flow_rankedDeltas, order.ascending)
            float flow_threshold = array.percentile_linear_interpolation(flow_rankedDeltas, 90)
            if math.abs(flow_largestRowDelta) >= flow_threshold
                int flow_dotAction = 1
                if array.size(flow_concentrationMarks) > 0
                    flow_ConcentrationMark flow_previousMark = array.last(flow_concentrationMarks)
                    float flow_nearDistance = math.max(flow_nativeTicks * syminfo.mintick, nz(flow_cloudAtr, 0.0) * 0.25)
                    flow_dotAction := flow_concentrationAction(flow_previousMark.formed, flow_previousMark.price, flow_previousMark.delta, bar_index, flow_largestRowPrice, flow_largestRowDelta, flow_nearDistance)
                if flow_dotAction == 2
                    flow_ConcentrationMark flow_previousMark = array.pop(flow_concentrationMarks)
                    label.delete(flow_previousMark.drawing)
                if flow_dotAction > 0
                    if array.size(flow_concentrationMarks) >= flow_KEEP_LABELS
                        flow_ConcentrationMark flow_oldestMark = array.shift(flow_concentrationMarks)
                        label.delete(flow_oldestMark.drawing)
                    int flow_strength = flow_concentrationStrength(math.abs(flow_largestRowDelta), flow_threshold)
                    color flow_dotColor = flow_largestRowDelta > 0 ? color.green : color.red
                    string flow_deltaText = (flow_largestRowDelta > 0 ? "+" : "-") + str.tostring(math.abs(flow_largestRowDelta), format.volume)
                    string flow_dotTooltip = (flow_largestRowDelta > 0 ? "Buy Δ " : "Sell Δ ") + flow_deltaText + " @ " + str.tostring(flow_largestRowPrice, format.mintick) + "\nLarge row pressure; watch price follow or stall."
                    label flow_dot = label.new(x=bar_index, y=flow_largestRowPrice, text="●", style=label.style_none, color=color.new(flow_dotColor, 100), textcolor=color.new(flow_dotColor, flow_strength == 2 ? 5 : flow_strength == 1 ? 15 : 30), size=flow_strength == 2 ? size.normal : flow_strength == 1 ? size.small : size.tiny, tooltip=flow_dotTooltip, force_overlay=true)
                    array.push(flow_concentrationMarks, flow_ConcentrationMark.new(flow_dot, bar_index, flow_largestRowPrice, flow_largestRowDelta))
    if flow_rowsReady
        array.push(flow_baselineBars, bar_index)
        array.push(flow_baselineDeltas, math.abs(flow_largestRowDelta))
        array.push(flow_baselineVolumes, flow_barVolume)
        // After the event decision, discard the observation that cannot be in
        // the next bar's prior 500-bar baseline. Keep storage at most 500.
        if array.size(flow_baselineBars) > flow_CONCENTRATION_WINDOW
            array.shift(flow_baselineBars)
            array.shift(flow_baselineDeltas)
            array.shift(flow_baselineVolumes)
else
    flow_baselineCount := array.size(flow_baselineDeltas)

// The root owns the single shared notice. Native request plan errors remain
// TradingView errors; a successful request with no data is a normal gap.
string flow_statusMessage = ""
if not flow_validData
    flow_statusMessage := "Footprint missing: Insights has a gap."
else if flow_rowsTooLarge
    flow_statusMessage := "Over 2,000 rows: spatial detail omitted."
else if not flow_rowsReady and (showSpikeProfiles or showConcentrations)
    flow_statusMessage := "Rows missing: spatial detail omitted."
else if showConcentrations and flow_baselineCount < flow_MIN_BASELINE
    flow_statusMessage := "Delta dots warming: " + str.tostring(flow_baselineCount) + "/20 valid bars."
// Cumulative row-coverage bookkeeping stays internal, without a chart banner.

// Lean Auction Regime Engine, adapted from ARE 3.1.3.
// Every admission is validated before histogram mutation; all commits use closes.
const int auction_MAP_CAP = 1200
const int auction_DPOC_CAP = 8000

type auction_ProfileSnapshot
    int opened
    int closed
    float step
    map<int, float> totals
    map<int, float> buys
    float poc
    float val
    float vah
    bool complete
    int reference = -1
    int available = na
    int availableTime = na

type auction_DpocRecord
    int formed
    int formedTime
    float level
    float lower
    float upper
    float net
    int side
    int state
    int reference = -1
    int availableTime = na

// Bounded analytic metadata leaves the legacy float navigation untouched.
type auction_OldPocMeta
    float level
    int born
    int bornTime
    int reference
    int lastTouch

auction_snapshot(int opened, int closed, float step, map<int, float> totals, map<int, float> buys, float poc, float val, float vah, int reference = -1, int available = na, int availableTime = na) =>
    auction_ProfileSnapshot.new(opened, closed, step, totals.copy(), buys.copy(), poc, val, vah, true, reference, available, availableTime)

// Read-only single-interval admission retained for the native map fixtures.
auction_preflightInterval(map<int, float> hist, float lower, float upper, float step, int capacity) =>
    bool fits = upper > lower and step > 0 and hist.size() <= capacity
    if fits
        fits := math.abs(lower / step) < 9e15 and math.abs(upper / step) < 9e15
    if fits
        int first = int(math.floor(lower / step))
        int last = int(math.ceil(upper / step)) - 1
        if last - first + 1 > capacity
            fits := false
        else
            int missing = 0
            for key = first to last
                if not hist.contains(key)
                    missing += 1
                if hist.size() + missing > capacity
                    fits := false
                    break
    fits

// Native interval preflight counts unique destination keys, never partial inserts.
auction_canAdd(map<int, float> hist, array<volume_row> rows, float step, int capacity) =>
    bool fits = not na(step) and step > 0 and hist.size() <= capacity
    int firstTouched = na
    int lastTouched = na
    if fits
        for row in rows
            if row.total_volume() > 0
                float lower = row.down_price()
                float upper = row.up_price()
                if na(lower) or na(upper) or upper <= lower or math.abs(lower / step) >= 9e15 or math.abs(upper / step) >= 9e15
                    fits := false
                    break
                int first = int(math.floor(lower / step))
                int last = int(math.ceil(upper / step)) - 1
                if last - first + 1 > capacity
                    fits := false
                    break
                firstTouched := na(firstTouched) ? first : math.min(firstTouched, first)
                lastTouched := na(lastTouched) ? last : math.max(lastTouched, last)
    // A full-span upper bound makes ordinary bars allocation free. Near the cap,
    // count only new keys, de-duplicating overlapping and unsorted native rows.
    if fits and not na(firstTouched) and hist.size() + lastTouched - firstTouched + 1 > capacity
        map<int, bool> missing = map.new<int, bool>()
        for row in rows
            if row.total_volume() > 0
                int first = int(math.floor(row.down_price() / step))
                int last = int(math.ceil(row.up_price() / step)) - 1
                for key = first to last
                    if not hist.contains(key) and not missing.contains(key)
                        missing.put(key, true)
                        if hist.size() + missing.size() > capacity
                            fits := false
                            break
                if not fits
                    break
    fits

auction_addInterval(map<int, float> hist, map<int, float> buys, float lower, float upper, float total, float buy, float step) =>
    int first = int(math.floor(lower / step))
    int last = int(math.ceil(upper / step)) - 1
    for key = first to last
        float fraction = auction_intervalFraction(lower, upper, key * step, (key + 1) * step)
        hist.put(key, nz(hist.get(key)) + total * fraction)
        buys.put(key, nz(buys.get(key)) + math.max(0.0, math.min(total, buy)) * fraction)
    hist.size()

auction_addRows(map<int, float> hist, map<int, float> buys, array<volume_row> rows, float step) =>
    for row in rows
        if row.total_volume() > 0
            auction_addInterval(hist, buys, row.down_price(), row.up_price(), row.total_volume(), row.buy_volume(), step)
    hist.size()

auction_valueSorted(map<int, float> hist, float step, array<int> keys) =>
    float poc = na
    float val = na
    float vah = na
    if hist.size() > 0
        int count = keys.size()
        float total = 0.0
        float largest = -1.0
        int peak = 0
        for index = 0 to count - 1
            float value = hist.get(keys.get(index))
            total += value
            if value > largest
                largest := value
                peak := index
        int lo = peak
        int hi = peak
        float included = largest
        while included < total * 0.70 and (lo > 0 or hi < count - 1)
            float left = lo > 0 ? hist.get(keys.get(lo - 1)) : -1.0
            float right = hi < count - 1 ? hist.get(keys.get(hi + 1)) : -1.0
            if left >= right
                lo -= 1
                included += left
            else
                hi += 1
                included += right
        poc := (keys.get(peak) + 0.5) * step
        val := keys.get(lo) * step
        vah := (keys.get(hi) + 1) * step
    [poc, val, vah]

auction_value(map<int, float> hist, float step) =>
    array<int> keys = hist.keys()
    keys.sort()
    auction_valueSorted(hist, step, keys)

// Histograms only append between explicit clears/swaps; unchanged membership
// reuses ascending keys while every bar still recomputes the exact value area.
auction_valueCached(map<int, float> hist, float step, array<int> keys) =>
    if keys.size() != hist.size()
        keys.clear()
        for key in hist.keys()
            keys.push(key)
        keys.sort()
    auction_valueSorted(hist, step, keys)

auction_dpocInterval(map<int, float> deltas, float lower, float upper, float delta, float step) =>
    int first = int(math.floor(lower / step))
    int last = int(math.ceil(upper / step)) - 1
    for key = first to last
        float fraction = auction_intervalFraction(lower, upper, key * step, (key + 1) * step)
        deltas.put(key, nz(deltas.get(key)) + delta * fraction)
    deltas.size()

auction_dpocAdd(map<int, float> deltas, array<volume_row> rows, float step) =>
    for row in rows
        if row.total_volume() > 0
            auction_dpocInterval(deltas, row.down_price(), row.up_price(), row.delta(), step)
    deltas.size()

auction_freezeDpoc(array<auction_DpocRecord> records, map<int, float> deltas, float step, int reference = -1) =>
    bool formed = deltas.size() > 0
    if formed
        array<int> keys = deltas.keys()
        keys.sort()
        array<float> values = array.new<float>()
        for key in keys
            values.push(deltas.get(key))
        [chosen, net] = auction_netPeak(keys, values)
        float lower = chosen * step
        float upper = (chosen + 1) * step
        int side = close > upper ? 1 : close < lower ? -1 : 0
        records.push(auction_DpocRecord.new(bar_index, time, (lower + upper) * 0.5, lower, upper, net, side, 0, reference, time_close))
        if records.size() > 16
            records.shift()
    formed

auction_push(array<float> values, float value, int capacity) =>
    values.push(value)
    if values.size() > capacity
        values.shift()
    values.size()

auction_percentile(array<float> values) =>
    array<float> sorted = values.copy()
    sorted.sort()
    sorted.get(int(math.ceil(sorted.size() * 0.95)) - 1)

var map<int, float> auction_episode = map.new<int, float>()
var map<int, float> auction_episodeBuy = map.new<int, float>()
var map<int, float> auction_candidate = map.new<int, float>()
var map<int, float> auction_candidateBuy = map.new<int, float>()
var array<int> auction_episodeKeys = array.new<int>()
var array<int> auction_candidateKeys = array.new<int>()
var array<float> auction_volumeHistory = array.new<float>()
var array<float> auction_oldPocs = array.new<float>()
var array<auction_OldPocMeta> auction_oldPocMeta = array.new<auction_OldPocMeta>()
var auction_ProfileSnapshot auction_liveProfile = na
var array<auction_ProfileSnapshot> auction_completedProfiles = array.new<auction_ProfileSnapshot>()
var int auction_episodeOpened = na
var int auction_episodeBars = 0
var float auction_grid = na
var float auction_refHigh = na
var float auction_refLow = na
var float auction_refPoc = na
var int auction_referenceId = -1
var int auction_referenceBar = na
var int auction_referenceTime = na
var int auction_referenceAvailableTime = na
var int auction_stage = 0
var int auction_direction = 0
var int auction_attemptStart = -1
var int auction_attemptTime = na
var int auction_acceptedAt = -1
var int auction_nextAttempt = 0
var int auction_consecutive = 0
var int auction_held = 0
var int auction_candidateBars = 0
var float auction_candidateVolume = 0.0
var float auction_outsideVolume = 0.0
var float auction_frozenAtr = na
var float auction_expectedVolume = na
var float auction_target = na
var int auction_targetBorn = na
var int auction_targetDirection = 0
var float auction_targetEdge = na
var string auction_latestEvent = ""
string auction_event = ""
int auction_eventDirection = 0
bool auction_dpocFormed = false
float auction_nearestDpoc = na
float auction_atr = ta.atr(14)
float auction_nativeStep = flow_nativeTicks * syminfo.mintick
float auction_proposedGrid = na(auction_grid) ? math.max(auction_nativeStep, math.ceil(auction_atr * 0.15 / syminfo.mintick) * syminfo.mintick) : auction_grid
float auction_volumeBase = auction_volumeHistory.size() >= 20 ? auction_volumeHistory.avg() : na
// Keys captured before decisions keep clusters causal across P and M bars.
int auction_beforeReference = auction_referenceId
int auction_beforeAttempt = auction_attemptStart
float auction_eventHigh = auction_refHigh
float auction_eventLow = auction_refLow
// Insights already checks the identical strict row predicate in native order.
// Keep auction's independent bar bounds and its original reconciliation floor.
bool auction_rowsValid = flow_rowsStrict and flow_barVolume > 0 and math.abs(flow_barVolume) < 1e100 and math.abs(flow_delta) <= flow_barVolume * 1.000001
float auction_rowTotal = flow_rowsTotal
float auction_rowDelta = flow_rowsDelta
if auction_rowsValid
    float auction_tolerance = math.max(0.000001, flow_barVolume * 0.00001)
    auction_rowsValid := auction_rowsValid and math.abs(auction_rowTotal - flow_barVolume) <= auction_tolerance and math.abs(auction_rowDelta - flow_delta) <= auction_tolerance
int auction_probeSide = 0
if auction_stage == 0 and bar_index >= auction_nextAttempt and not na(auction_refPoc) and not na(auction_volumeBase) and auction_volumeBase > 0
    auction_probeSide := close > auction_refHigh + auction_atr * 0.10 ? 1 : close < auction_refLow - auction_atr * 0.10 ? -1 : 0
bool auction_good = auction_rowsValid and not na(auction_atr) and auction_atr > 0
if barstate.isconfirmed and auction_good
    // Both mutable auction maps must fit before either receives this bar.
    auction_good := auction_canAdd(auction_episode, flow_rows, auction_proposedGrid, auction_MAP_CAP)
    if auction_good and (auction_stage > 0 or auction_probeSide != 0)
        auction_good := auction_canAdd(auction_candidate, flow_rows, auction_proposedGrid, auction_MAP_CAP)

var array<label> auction_markers = array.new<label>()
var int auction_lastMarkerBar = -100
var int auction_lastMarkerPriority = 0
var label auction_failureMarker = na
var int auction_failureReference = -1
var int auction_failureDirection = 0
var int auction_failureBar = -100
var float auction_failureEdge = na
var int auction_failureCount = 0

if barstate.isconfirmed
    if not auction_good
        auction_episode.clear()
        auction_episodeKeys.clear()
        auction_episodeBuy.clear()
        auction_candidate.clear()
        auction_candidateKeys.clear()
        auction_candidateBuy.clear()
        auction_volumeHistory.clear()
        auction_episodeOpened := na
        auction_episodeBars := 0
        auction_liveProfile := na
        auction_grid := na
        auction_refHigh := na
        auction_refLow := na
        auction_refPoc := na
        auction_referenceBar := na
        auction_referenceTime := na
        auction_referenceAvailableTime := na
        auction_referenceId += 1
        auction_stage := 0
        auction_target := na
        auction_latestEvent := ""
    else
        if na(auction_grid)
            auction_grid := auction_proposedGrid
        if auction_episodeBars == 0
            auction_episodeOpened := time
        auction_addRows(auction_episode, auction_episodeBuy, flow_rows, auction_grid)
        auction_episodeBars := auction_seedCount(auction_episodeBars, true, true)
        [auction_devPoc, auction_devLow, auction_devHigh] = auction_valueCached(auction_episode, auction_grid, auction_episodeKeys)
        auction_liveProfile := auction_ProfileSnapshot.new(auction_episodeOpened, time_close, auction_grid, auction_episode, auction_episodeBuy, auction_devPoc, auction_devLow, auction_devHigh, true)
        if not na(auction_target) and not auction_targetPending(bar_index, auction_targetBorn, auction_target, auction_targetDirection, auction_targetEdge, low, high, close, true)
            auction_target := na
        if na(auction_refPoc)
            if auction_referenceReady(auction_episodeBars)
                auction_refPoc := auction_devPoc
                auction_refLow := auction_devLow
                auction_refHigh := auction_devHigh
                auction_referenceBar := bar_index
                auction_referenceTime := time
                auction_referenceAvailableTime := time_close
                auction_referenceId += 1
                auction_oldPocs.push(auction_refPoc)
                auction_oldPocMeta.push(auction_OldPocMeta.new(auction_refPoc, bar_index, time_close, auction_referenceId, bar_index))
        else
            if auction_stage == 0 and auction_probeSide != 0
                auction_direction := auction_probeSide
                auction_stage := 1
                auction_attemptStart := bar_index
                auction_attemptTime := time
                auction_frozenAtr := auction_atr
                auction_expectedVolume := auction_volumeBase
                auction_target := auction_neighbor(auction_oldPocs, close, auction_direction)
                auction_targetBorn := bar_index
                auction_targetDirection := auction_direction
                auction_targetEdge := auction_direction == 1 ? auction_refHigh : auction_refLow
                auction_event := "P"
                auction_eventDirection := auction_direction
                auction_latestEvent := auction_direction == 1 ? "Probe higher" : "Probe lower"
            if auction_stage > 0
                auction_addRows(auction_candidate, auction_candidateBuy, flow_rows, auction_grid)
                auction_candidateBars += 1
                auction_candidateVolume += flow_barVolume
                float auction_edge = auction_direction == 1 ? auction_refHigh : auction_refLow
                for auction_row in flow_rows
                    auction_outsideVolume += auction_row.total_volume() * auction_outsideFraction(auction_row.down_price(), auction_row.up_price(), auction_edge, auction_direction)
                [auction_cp, auction_cl, auction_ch] = auction_valueCached(auction_candidate, auction_grid, auction_candidateKeys)
                bool auction_outsideClose = (close - auction_edge) * auction_direction > auction_frozenAtr * 0.10
                auction_consecutive := auction_outsideClose ? auction_consecutive + 1 : 0
                bool auction_backInside = (close - auction_edge) * auction_direction <= 0
                bool auction_accepts = auction_accept(auction_consecutive, auction_outsideVolume / auction_candidateVolume, auction_candidateVolume / (auction_candidateBars * auction_expectedVolume), (auction_cp - auction_edge) * auction_direction > 0)
                float auction_overlapPct = 100 * math.max(0.0, math.min(auction_refHigh, auction_ch) - math.max(auction_refLow, auction_cl)) / math.max(math.min(auction_refHigh - auction_refLow, auction_ch - auction_cl), syminfo.mintick)
                float auction_shift = (auction_cp - auction_refPoc) * auction_direction / math.max(auction_frozenAtr, syminfo.mintick)
                bool auction_retest = auction_stage == 2 and bar_index > auction_acceptedAt and auction_outsideClose and (auction_direction == 1 ? low <= auction_edge + auction_frozenAtr * 0.15 : high >= auction_edge - auction_frozenAtr * 0.15)
                int auction_nextHeld = auction_outsideClose ? auction_held + 1 : 0
                bool auction_migrates = auction_migrate(auction_accepts, auction_shift, auction_overlapPct, auction_candidateBars, auction_retest, auction_nextHeld)
                [auction_nextStage, auction_code, auction_nextEligible, auction_acceptBar, auction_holdCount] = auction_transition(auction_stage, 0, bar_index, auction_nextAttempt, auction_attemptStart, auction_acceptedAt, auction_held, auction_backInside, auction_accepts, auction_migrates, auction_outsideClose, true, true)
                auction_stage := auction_nextStage
                auction_nextAttempt := auction_nextEligible
                auction_acceptedAt := auction_acceptBar
                auction_held := auction_holdCount
                if auction_code > 0
                    auction_eventDirection := auction_direction
                    auction_event := auction_code == 2 ? "A" : auction_code == 3 ? "F" : "M"
                    auction_latestEvent := auction_code == 2 ? "Accepted outside value" : auction_code == 3 ? "Auction rejected" : "Value migrated"
                if auction_code == 3
                    auction_targetDirection := -auction_direction
                    auction_targetEdge := auction_edge
                    auction_targetBorn := bar_index
                    bool auction_alreadyTouched = auction_targetDirection == 1 ? high >= auction_refPoc : low <= auction_refPoc
                    auction_target := auction_alreadyTouched ? na : auction_refPoc
                if auction_code == 4
                    // Old and new distributions intentionally share candidate bars.
                    auction_completedProfiles.push(auction_snapshot(auction_episodeOpened, time_close, auction_grid, auction_episode, auction_episodeBuy, auction_devPoc, auction_devLow, auction_devHigh, auction_referenceId, bar_index, time_close))
                    auction_episode := auction_candidate.copy()
                    auction_episodeKeys := auction_candidateKeys.copy()
                    auction_episodeBuy := auction_candidateBuy.copy()
                    auction_episodeOpened := auction_attemptTime
                    auction_episodeBars := auction_candidateBars
                    auction_refPoc := auction_cp
                    auction_refLow := auction_cl
                    auction_refHigh := auction_ch
                    auction_referenceBar := bar_index
                    auction_referenceTime := time
                    auction_referenceAvailableTime := time_close
                    auction_referenceId += 1
                    auction_oldPocs.push(auction_cp)
                    auction_oldPocMeta.push(auction_OldPocMeta.new(auction_cp, bar_index, time_close, auction_referenceId, bar_index))
                    auction_liveProfile := auction_ProfileSnapshot.new(auction_episodeOpened, time_close, auction_grid, auction_episode, auction_episodeBuy, auction_cp, auction_cl, auction_ch, true)
                    auction_target := na
            if auction_stage == 0 and auction_event != "M" and auction_event != "F" and not na(auction_referenceBar) and bar_index - auction_referenceBar >= 160
                auction_completedProfiles.push(auction_snapshot(auction_episodeOpened, time_close, auction_grid, auction_episode, auction_episodeBuy, auction_devPoc, auction_devLow, auction_devHigh, auction_referenceId, bar_index, time_close))
                auction_episode.clear()
                auction_episodeKeys.clear()
                auction_episodeBuy.clear()
                auction_episodeOpened := na
                auction_episodeBars := 0
                auction_liveProfile := na
                auction_grid := na
                auction_refHigh := na
                auction_refLow := na
                auction_refPoc := na
                auction_referenceBar := na
                auction_referenceTime := na
                auction_referenceAvailableTime := na
                auction_referenceId += 1
                auction_target := na
        auction_push(auction_volumeHistory, flow_barVolume, 20)
        while auction_completedProfiles.size() > 2
            auction_completedProfiles.shift()
        while auction_oldPocs.size() > 20
            auction_oldPocs.shift()
        while auction_oldPocMeta.size() > 20
            auction_oldPocMeta.shift()
    // Touch history is analytic only; it does not extend the 160-bar lifetime.
    for auction_oldMeta in auction_oldPocMeta
        if not na(auction_atr) and low <= auction_oldMeta.level + math.max(auction_nativeStep, auction_atr * 0.15) and high >= auction_oldMeta.level - math.max(auction_nativeStep, auction_atr * 0.15)
            auction_oldMeta.lastTouch := bar_index
    if auction_stage == 0
        auction_direction := 0
        auction_attemptStart := -1
        auction_attemptTime := na
        auction_acceptedAt := -1
        auction_candidate.clear()
        auction_candidateKeys.clear()
        auction_candidateBuy.clear()
        auction_candidateBars := 0
        auction_candidateVolume := 0.0
        auction_outsideVolume := 0.0
        auction_consecutive := 0
        auction_held := 0
        auction_frozenAtr := na
        auction_expectedVolume := na
        // A failed attempt's fresh rotation target survives; timeout clears it.
        if auction_event == "" and auction_beforeAttempt != -1
            auction_target := na
    if showAuctionEvents and auction_event != ""
        int auction_priority = auction_event == "P" ? 1 : auction_event == "A" ? 2 : 3
        bool auction_crowded = bar_index - auction_lastMarkerBar < 4
        float auction_failureLevel = auction_eventDirection == 1 ? auction_eventHigh : auction_eventLow
        bool auction_mergeFailure = auction_event == "F" and not na(auction_failureMarker) and auction_markers.indexof(auction_failureMarker) >= 0 and auction_failureReference == auction_beforeReference and auction_failureDirection == auction_eventDirection and bar_index - auction_failureBar <= 20 and math.abs(auction_failureLevel - auction_failureEdge) <= syminfo.mintick * 0.5
        int auction_count = auction_mergeFailure ? auction_failureCount + 1 : 1
        if not auction_crowded or auction_priority >= auction_lastMarkerPriority
            if auction_mergeFailure
                int auction_index = auction_markers.indexof(auction_failureMarker)
                auction_markers.remove(auction_index)
                label.delete(auction_failureMarker)
            if auction_crowded and auction_markers.size() > 0 and label.get_x(auction_markers.last()) == auction_lastMarkerBar
                label.delete(auction_markers.pop())
            color auction_ink = auction_event == "F" ? color.orange : auction_eventDirection == 1 ? color.green : color.red
            string auction_text = auction_event + (auction_eventDirection == 1 ? "+" : "−") + (auction_count > 1 ? " ×" + str.tostring(auction_count) : "")
            string auction_eventTip = auction_latestEvent + "\n" + (auction_event == "P" ? "Outside value; wait for acceptance or return." : auction_event == "A" ? "Holding outside value; watch the retest." : auction_event == "F" ? "Back inside value; watch the failed edge." : "Volume centre shifted; watch the new value area.")
            label auction_marker = label.new(bar_index, auction_eventDirection == 1 ? high : low, auction_text, yloc=auction_eventDirection == 1 ? yloc.abovebar : yloc.belowbar, style=auction_eventDirection == 1 ? label.style_label_down : label.style_label_up, color=color.new(auction_ink, 25), textcolor=color.white, size=size.tiny, tooltip=auction_eventTip, force_overlay=true)
            auction_markers.push(auction_marker)
            auction_lastMarkerBar := bar_index
            auction_lastMarkerPriority := auction_priority
            if auction_event == "F"
                auction_failureMarker := auction_marker
                auction_failureReference := auction_beforeReference
                auction_failureDirection := auction_eventDirection
                auction_failureBar := bar_index
                auction_failureEdge := auction_failureLevel
                auction_failureCount := auction_count
            else if auction_event == "A" or auction_event == "M"
                auction_failureMarker := na
            if auction_markers.size() > 24
                label.delete(auction_markers.shift())

// Delta POCs use independent raw-delta admission and signed native row netting.
var array<float> auction_deltaHistory = array.new<float>()
var array<float> auction_deltaVolumes = array.new<float>()
var map<int, float> auction_deltaRows = map.new<int, float>()
var array<auction_DpocRecord> auction_dpocs = array.new<auction_DpocRecord>()
var int auction_clusterCount = 0
var int auction_clusterLast = -1
var int auction_clusterPressure = 0
var int auction_clusterReference = -1
var int auction_clusterAttempt = -1
if barstate.isconfirmed
    if not auction_good
        auction_deltaRows.clear()
        auction_clusterCount := 0
        auction_deltaHistory.clear()
        auction_deltaVolumes.clear()
        for auction_record in auction_dpocs
            if auction_record.state < 2
                auction_record.state := 4
    else
        float auction_priorMean = auction_deltaVolumes.size() > 0 ? auction_deltaVolumes.avg() : na
        bool auction_significantDelta = false
        if auction_deltaEligible(flow_delta, flow_barVolume, auction_priorMean, auction_deltaHistory.size())
            float auction_threshold = auction_percentile(auction_deltaHistory)
            auction_significantDelta := math.abs(flow_delta) > auction_threshold
        int auction_pressure = flow_delta >= 0 ? 1 : -1
        bool auction_sameCluster = auction_clusterCount > 0 and auction_significantDelta and auction_clusterLast + 1 == bar_index and auction_clusterPressure == auction_pressure and auction_clusterReference == auction_beforeReference and auction_clusterAttempt == auction_beforeAttempt
        // Capacity failure on a member discards every member; never freeze partial.
        bool auction_deltaFits = true
        if auction_significantDelta
            map<int, float> auction_preflightRows = auction_sameCluster ? auction_deltaRows : map.new<int, float>()
            auction_deltaFits := auction_canAdd(auction_preflightRows, flow_rows, auction_nativeStep, auction_DPOC_CAP)
        int auction_action = auction_clusterAction(auction_clusterCount > 0, auction_clusterCount, auction_clusterLast, bar_index, auction_significantDelta, auction_pressure, auction_clusterPressure, auction_beforeReference, auction_clusterReference, auction_beforeAttempt, auction_clusterAttempt, auction_rowsValid, auction_deltaFits)
        if auction_action == 3 or auction_action == 4
            auction_dpocFormed := auction_freezeDpoc(auction_dpocs, auction_deltaRows, auction_nativeStep, auction_clusterReference)
            auction_deltaRows.clear()
            auction_clusterCount := 0
        else if auction_action == 5
            auction_deltaRows.clear()
            auction_clusterCount := 0
        if auction_action == 1 or auction_action == 2 or auction_action == 4
            if auction_clusterCount == 0
                auction_clusterPressure := auction_pressure
                auction_clusterReference := auction_beforeReference
                auction_clusterAttempt := auction_beforeAttempt
            auction_dpocAdd(auction_deltaRows, flow_rows, auction_nativeStep)
            auction_clusterCount += 1
            auction_clusterLast := bar_index
            if auction_clusterCount == 4
                auction_dpocFormed := auction_freezeDpoc(auction_dpocs, auction_deltaRows, auction_nativeStep, auction_clusterReference) or auction_dpocFormed
                auction_deltaRows.clear()
                auction_clusterCount := 0
        for auction_record in auction_dpocs
            [auction_state, auction_side, auction_touched, auction_crossed] = auction_levelNext(auction_record.state, auction_record.side, bar_index - auction_record.formed, 100, low, high, close, auction_record.lower, auction_record.upper)
            auction_record.state := auction_state
            auction_record.side := auction_side
        auction_push(auction_deltaHistory, math.abs(flow_delta), 200)
        auction_push(auction_deltaVolumes, flow_barVolume, 20)

// Logical queries use the same newest two eligible levels as the drawn layer.
// Visibility is a drawing preference and never gates auction metadata.
auction_visibleDpocNear(float price, float tolerance) =>
    bool near = false
    int visible = 0
    if auction_dpocs.size() > 0
        for index = auction_dpocs.size() - 1 to 0
            auction_DpocRecord record = auction_dpocs.get(index)
            if record.state < 2 and visible < 2
                near := near or math.abs(record.level - price) <= tolerance
                visible += 1
    near

// Logical visible selection is available on historical closes to OF admission.
// Drawing creation stays on the last bar and uses this identical selection.
if auction_dpocs.size() > 0
    int auction_logicalVisible = 0
    for auction_index = auction_dpocs.size() - 1 to 0
        auction_DpocRecord auction_record = auction_dpocs.get(auction_index)
        if auction_record.state < 2 and auction_logicalVisible < 2
            float auction_midpoint = (high + low) * 0.5
            if na(auction_nearestDpoc) or math.abs(auction_record.level - auction_midpoint) < math.abs(auction_nearestDpoc - auction_midpoint)
                auction_nearestDpoc := auction_record.level
            auction_logicalVisible += 1

// The old yellow plot tracked confirmed auction targets. Preserve that history,
// with spacing and individual hover text instead of a current-price-only filter.
type auction_ReferenceDot
    float level
    int born
    int sampledBar
    int sampledTime
    label drawing

var array<auction_ReferenceDot> auction_referenceDots = array.new<auction_ReferenceDot>()
if barstate.isconfirmed and not na(auction_target)
    auction_ReferenceDot auction_previousDot = auction_referenceDots.size() > 0 ? auction_referenceDots.last() : na
    if auction_referenceDotDue(auction_target, auction_targetBorn, na(auction_previousDot) ? -1 : auction_previousDot.born, bar_index, na(auction_previousDot) ? -1 : auction_previousDot.sampledBar, na(auction_previousDot) ? 0.0 : auction_previousDot.level, syminfo.mintick)
        auction_referenceDots.push(auction_ReferenceDot.new(auction_target, auction_targetBorn, bar_index, time, na))
        if auction_referenceDots.size() > 192
            auction_ReferenceDot auction_evictedDot = auction_referenceDots.shift()
            if not na(auction_evictedDot.drawing)
                label.delete(auction_evictedDot.drawing)

// Bootstrap on the last closed historical bar so realtime rollback retains
// existing owners. Only a new confirmed sample needs a new glyph thereafter.
if barstate.islastconfirmedhistory or barstate.islast
    for auction_dot in auction_referenceDots
        if showAuctionEvents
            bool auction_nearPrice = not na(auction_atr) and math.abs(auction_dot.level - close) <= auction_atr * 2.0
            color auction_dotInk = color.new(#E8C547, auction_nearPrice ? 10 : 60)
            if na(auction_dot.drawing)
                auction_dot.drawing := label.new(auction_dot.sampledTime, auction_dot.level, "●", xloc=xloc.bar_time, style=label.style_none, textcolor=auction_dotInk, size=size.tiny, tooltip="POC reference · " + str.tostring(auction_dot.level, format.mintick) + "\nVolume centre; watch a hold or break.", force_overlay=true)
            else
                label.set_textcolor(auction_dot.drawing, auction_dotInk)
        else if not na(auction_dot.drawing)
            label.delete(auction_dot.drawing)
            auction_dot.drawing := na

// Draw only two retained active records, with rays beginning at confirmation.
var array<line> auction_dpocLines = array.new<line>()
var array<label> auction_dpocTags = array.new<label>()
var array<line> auction_referenceLines = array.new<line>()
if barstate.islast
    while auction_dpocLines.size() > 0
        line.delete(auction_dpocLines.pop())
    while auction_dpocTags.size() > 0
        label.delete(auction_dpocTags.pop())
    while auction_referenceLines.size() > 0
        line.delete(auction_referenceLines.pop())
    if showAuctionEvents
        int auction_visible = 0
        if auction_dpocs.size() > 0
            for auction_index = auction_dpocs.size() - 1 to 0
                auction_DpocRecord auction_record = auction_dpocs.get(auction_index)
                if auction_record.state < 2 and auction_visible < 2
                    color auction_ink = color.new(auction_record.net >= 0 ? color.green : color.red, auction_record.state == 1 ? 75 : 20)
                    auction_dpocLines.push(line.new(auction_record.formedTime, auction_record.level, time_close, auction_record.level, xloc=xloc.bar_time, color=auction_ink, style=auction_record.state == 1 ? line.style_dashed : line.style_solid, width=1, force_overlay=true))
                    auction_dpocTags.push(label.new(time_close, auction_record.level, "DPOC", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=auction_ink, size=size.tiny, tooltip="DPOC " + str.tostring(auction_record.level, format.mintick) + " · " + (auction_record.state == 1 ? "tested" : "fresh") + "\nStrongest delta row · Δ " + str.tostring(auction_record.net, format.volume), force_overlay=true))
                    auction_visible += 1
        if not na(auction_refPoc)
            auction_referenceLines.push(line.new(auction_referenceTime, auction_refHigh, time_close, auction_refHigh, xloc=xloc.bar_time, color=color.new(color.aqua, 85), style=line.style_dotted, force_overlay=true))
            auction_referenceLines.push(line.new(auction_referenceTime, auction_refLow, time_close, auction_refLow, xloc=xloc.bar_time, color=color.new(color.aqua, 85), style=line.style_dotted, force_overlay=true))

// Local AUCTION episodes use closed native footprint evidence from auction_core.
// This is a display adapter, with no independent calendar/session data engine.
// Market Sessions Mode 2 appearance: left-stacked green/red rows, 10% padding,
// transparent dashed outline and subdued gold/slate native level guides.
const int local_rowCount = 30
var array<polyline> local_contours = array.new<polyline>()
var array<box> local_outlines = array.new<box>()
var array<line> local_guides = array.new<line>()
var array<label> local_titles = array.new<label>()

local_clear() =>
    while local_contours.size() > 0
        polyline.delete(local_contours.pop())
    while local_outlines.size() > 0
        box.delete(local_outlines.pop())
    while local_guides.size() > 0
        line.delete(local_guides.pop())
    while local_titles.size() > 0
        label.delete(local_titles.pop())
    0

// Each rectangle returns to the same origin. The outbound connector is retraced
// exactly and encloses zero area, so one filled contour contains disjoint rows
// without filling the gaps or a background behind the stacked buy/sell sides.
local_appendRectangle(array<chart.point> local_points, int local_left, int local_right, float local_low, float local_high, int local_originTime, float local_originPrice) =>
    if local_right > local_left and local_high > local_low
        local_points.push(chart.point.from_time(local_left, local_low))
        local_points.push(chart.point.from_time(local_left, local_high))
        local_points.push(chart.point.from_time(local_right, local_high))
        local_points.push(chart.point.from_time(local_right, local_low))
        local_points.push(chart.point.from_time(local_left, local_low))
        local_points.push(chart.point.from_time(local_originTime, local_originPrice))
    local_points.size()

local_draw(auction_ProfileSnapshot local_snapshot, int local_age, bool local_current, int local_displayClosed) =>
    bool local_drawn = false
    if not na(local_snapshot)
        if local_snapshot.complete and not na(local_snapshot.opened) and not na(local_snapshot.closed)
            if not na(local_displayClosed) and local_displayClosed > local_snapshot.opened and local_snapshot.totals.size() > 0 and local_snapshot.buys.size() == local_snapshot.totals.size()
                array<int> local_keys = local_snapshot.totals.keys()
                array<float> local_totals = local_snapshot.totals.values()
                array<float> local_buys = array.new_float()
                for local_key in local_keys
                    local_buys.push(local_snapshot.buys.contains(local_key) ? local_snapshot.buys.get(local_key) : na)
                // Validate every spatial cell before creating any drawing.
                if local_gridValid(local_keys, local_totals, local_buys, local_snapshot.step)
                    float local_low = local_keys.min() * local_snapshot.step
                    float local_high = (local_keys.max() + 1) * local_snapshot.step
                    float local_rowStep = (local_high - local_low) / local_rowCount
                    int local_width = local_profileWidth(local_snapshot.opened, local_displayClosed)
                    if local_rowStep > 0 and local_width > 0
                        array<float> local_rowTotals = array.new_float(local_rowCount, 0.0)
                        array<float> local_rowBuys = array.new_float(local_rowCount, 0.0)
                        array<float> local_rowSells = array.new_float(local_rowCount, 0.0)
                        local_aggregateRows(local_keys, local_totals, local_buys, local_snapshot.step, local_low, local_high, local_rowTotals, local_rowBuys, local_rowSells)
                        // Preserve the Market Sessions scale: max buy + max sell.
                        float local_maxVolume = local_rowBuys.max() + local_rowSells.max()
                        if local_maxVolume > 0
                            array<chart.point> local_buyPoints = array.new<chart.point>()
                            array<chart.point> local_sellPoints = array.new<chart.point>()
                            local_buyPoints.push(chart.point.from_time(local_snapshot.opened, local_low))
                            local_sellPoints.push(chart.point.from_time(local_snapshot.opened, local_low))
                            for local_row = 0 to local_rowCount - 1
                                float local_rowLow = math.max(local_low, local_low + local_row * local_rowStep)
                                float local_rowHigh = local_row == local_rowCount - 1 ? local_high : math.min(local_high, local_low + (local_row + 1) * local_rowStep)
                                float local_padding = (local_rowHigh - local_rowLow) * 0.10
                                [local_buyEnd, local_sellEnd] = local_segmentTimes(local_snapshot.opened, local_width, local_rowBuys.get(local_row), local_rowSells.get(local_row), local_maxVolume)
                                local_appendRectangle(local_buyPoints, local_snapshot.opened, local_buyEnd, local_rowLow + local_padding, local_rowHigh - local_padding, local_snapshot.opened, local_low)
                                local_appendRectangle(local_sellPoints, local_buyEnd, local_sellEnd, local_rowLow + local_padding, local_rowHigh - local_padding, local_snapshot.opened, local_low)
                            int local_fillFade = local_current ? 60 : math.min(94, 78 + local_age * 5)
                            int local_guideFade = local_current ? 42 : math.min(92, 65 + local_age * 8)
                            int local_outlineFade = local_current ? 78 : math.min(96, 88 + local_age * 3)
                            color local_green = color.rgb(76, 175, 79)
                            color local_red = color.rgb(255, 82, 82)
                            color local_pocColor = local_current ? color.rgb(193, 161, 90) : color.rgb(144, 157, 173)
                            color local_valueColor = color.rgb(144, 157, 173)
                            if local_buyPoints.size() > 1
                                local_contours.push(polyline.new(local_buyPoints, curved=false, closed=true, xloc=xloc.bar_time, line_color=color.new(local_green, 100), fill_color=color.new(local_green, local_fillFade), line_width=1, force_overlay=true))
                            if local_sellPoints.size() > 1
                                local_contours.push(polyline.new(local_sellPoints, curved=false, closed=true, xloc=xloc.bar_time, line_color=color.new(local_red, 100), fill_color=color.new(local_red, local_fillFade), line_width=1, force_overlay=true))
                            local_outlines.push(box.new(local_snapshot.opened, local_high, local_displayClosed, local_low, xloc=xloc.bar_time, border_color=color.new(chart.fg_color, local_outlineFade), border_width=1, border_style=line.style_dashed, bgcolor=color.new(color.orange, 100), force_overlay=true))
                            // Guides are developing native AU-grid levels, not
                            // the separate causal reference edges used by ARE.
                            if local_levelInside(local_snapshot.poc, local_low, local_high)
                                local_guides.push(line.new(local_snapshot.opened, local_snapshot.poc, local_displayClosed, local_snapshot.poc, xloc=xloc.bar_time, color=color.new(local_pocColor, local_guideFade), width=1, force_overlay=true))
                            if local_levelInside(local_snapshot.vah, local_low, local_high)
                                local_guides.push(line.new(local_snapshot.opened, local_snapshot.vah, local_displayClosed, local_snapshot.vah, xloc=xloc.bar_time, color=color.new(local_valueColor, local_guideFade), width=1, force_overlay=true))
                            if local_levelInside(local_snapshot.val, local_low, local_high)
                                local_guides.push(line.new(local_snapshot.opened, local_snapshot.val, local_displayClosed, local_snapshot.val, xloc=xloc.bar_time, color=color.new(local_valueColor, local_guideFade), width=1, force_overlay=true))
                            int local_midTime = local_snapshot.opened + int((local_displayClosed - local_snapshot.opened) / 2)
                            string local_title = "Auction"
                            string local_tooltip = (local_current ? "Current auction" : "Closed auction") + "\nVolume centre and value range; watch their retest."
                            local_titles.push(label.new(local_midTime, local_high, local_title, xloc=xloc.bar_time, style=label.style_none, color=color.new(color.black, 100), textcolor=color.new(chart.fg_color, local_current ? 35 : 65 + local_age * 8), size=size.tiny, tooltip=local_tooltip, force_overlay=true))
                            local_drawn := true
    local_drawn

// Closed evidence changes only at chart-bar closes. Seed the committed drawing
// owner on the last historical bar so realtime rollback restores those objects;
// rebuilding on a confirmed last bar commits the replacement owner atomically.
// At most 3 outlines, 6 contours, 9 guides and 3 small titles exist at once.
var bool local_displayInitialized = false
bool local_rebuild = barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed) or (barstate.islast and not local_displayInitialized)
if local_rebuild
    local_clear()
    if showLocalProfiles
        int local_kept = math.min(auction_completedProfiles.size(), 2)
        if local_kept > 0
            for local_index = 0 to local_kept - 1
                int local_sourceIndex = auction_completedProfiles.size() - local_kept + local_index
                auction_ProfileSnapshot local_snapshot = auction_completedProfiles.get(local_sourceIndex)
                int local_nextOpened = na
                if local_sourceIndex + 1 < auction_completedProfiles.size()
                    local_nextOpened := auction_completedProfiles.get(local_sourceIndex + 1).opened
                else if not na(auction_liveProfile)
                    local_nextOpened := auction_liveProfile.opened
                int local_displayClosed = local_displayEnd(local_snapshot.opened, local_snapshot.closed, local_nextOpened)
                local_draw(local_snapshot, local_kept - local_index, false, local_displayClosed)
        if not na(auction_liveProfile)
            local_draw(auction_liveProfile, 0, true, auction_liveProfile.closed)
    local_displayInitialized := true

// Current close candidates are staged while OF reads the prior close context.
var array<area_Record> area_context = array.new<area_Record>()
array<area_Record> area_sources = array.new<area_Record>()
array<string> area_liveKeys = array.new<string>()
float area_bandTolerance = area_tolerance(auction_atr, auction_nativeStep)
if not na(area_bandTolerance)
    if not na(auction_refPoc) and not na(auction_referenceBar)
        string area_auctionKey = "AU:" + str.tostring(auction_referenceId) + ":"
        area_add(area_sources, area_liveKeys, area_context, area_make(area_auctionKey + "VAL", "AU VAL", 1, auction_referenceBar, auction_referenceAvailableTime, auction_referenceId, 100, auction_referenceBar, auction_refLow, area_bandTolerance), low, high, bar_index)
        area_add(area_sources, area_liveKeys, area_context, area_make(area_auctionKey + "VAH", "AU VAH", 2, auction_referenceBar, auction_referenceAvailableTime, auction_referenceId, 100, auction_referenceBar, auction_refHigh, area_bandTolerance), low, high, bar_index)
        area_add(area_sources, area_liveKeys, area_context, area_make(area_auctionKey + "POC", "AU POC", 3, auction_referenceBar, auction_referenceAvailableTime, auction_referenceId, 90, auction_referenceBar, auction_refPoc, area_bandTolerance), low, high, bar_index)
    for area_snapshot in auction_completedProfiles
        if area_snapshot.complete and not na(area_snapshot.available)
            string area_profileKey = "PROFILE:" + str.tostring(area_snapshot.reference) + ":" + str.tostring(area_snapshot.closed) + ":"
            area_add(area_sources, area_liveKeys, area_context, area_make(area_profileKey + "VAL", "Completed VAL", 1, area_snapshot.available, area_snapshot.availableTime, area_snapshot.reference, 80, area_snapshot.available, area_snapshot.val, area_bandTolerance), low, high, bar_index)
            area_add(area_sources, area_liveKeys, area_context, area_make(area_profileKey + "VAH", "Completed VAH", 2, area_snapshot.available, area_snapshot.availableTime, area_snapshot.reference, 80, area_snapshot.available, area_snapshot.vah, area_bandTolerance), low, high, bar_index)
            area_add(area_sources, area_liveKeys, area_context, area_make(area_profileKey + "POC", "Completed POC", 3, area_snapshot.available, area_snapshot.availableTime, area_snapshot.reference, 70, area_snapshot.available, area_snapshot.poc, area_bandTolerance), low, high, bar_index)
    // Consume every retained eligible analytic record, including hidden DPOCs.
    for auction_record in auction_dpocs
        if auction_record.state < 2
            string area_dpocKey = "DPOC:" + str.tostring(auction_record.reference) + ":" + str.tostring(auction_record.formed)
            area_add(area_sources, area_liveKeys, area_context, area_make(area_dpocKey, "DPOC", 4, auction_record.formed, auction_record.availableTime, auction_record.reference, 75, auction_record.formed, auction_record.level, area_bandTolerance), low, high, bar_index)
    for area_old in auction_oldPocMeta
        if area_oldEligible(area_old.born, bar_index, area_old.reference, auction_referenceId)
            string area_oldKey = "OLD:" + str.tostring(area_old.reference) + ":POC"
            area_add(area_sources, area_liveKeys, area_context, area_make(area_oldKey, "Earlier POC", 3, area_old.born, area_old.bornTime, area_old.reference, 60, area_old.lastTouch, area_old.level, area_bandTolerance), low, high, bar_index)
array<area_Record> area_nextContext = area_build(area_sources, area_context, close, area_bandTolerance)

// The returned copy freezes the prior-close dimensions for origin/test storage.
area_select(int side, float previousClose, float barLow, float barHigh, float barClose) =>
    area_Record area_selected = na
    for area_candidate in area_context
        if area_eligible(area_candidate.kind, area_candidate.born, bar_index, side, previousClose, barLow, barHigh, barClose, area_candidate.lower, area_candidate.upper)
            if na(area_selected)
                area_selected := area_candidate
            else if area_rankBefore(area_candidate.priority, area_candidate.born, area_candidate.lastTouch, area_candidate.level, area_selected.priority, area_selected.born, area_selected.lastTouch, area_selected.level, barClose)
                area_selected := area_candidate
    area_copy(area_selected)

// Rank/cap eviction is not source death. Every raw eligible source is tracked.
area_alive(string key) =>
    key != "" and area_liveKeys.indexof(key) >= 0

// Causal area / evidence / response engine. All admission uses prior-close area
// context; drawings and the compact overlay summary have a separate owner.
float of_nativeBuy = flow_hasFootprint ? flow_fp.buy_volume() : na
float of_nativeSell = flow_hasFootprint ? flow_fp.sell_volume() : na
bool of_totalsValid = of_totalsUsable(flow_validData, flow_barVolume, of_nativeBuy, of_nativeSell, flow_delta)
float of_atr14 = ta.atr(14)
float of_nativeRow = flow_nativeTicks * syminfo.mintick
float of_pressure = of_netPressure(flow_delta, flow_barVolume, of_totalsValid)
// Legacy export name now carries HUD CVD since the shared draggable anchor.
var float of_sessionCvd = na
var int of_anchorStartTime = na
var bool of_anchorPartial = false
var float of_structuralCvd = 0.0
// Ordinary var rollback recomputes live values once from the preceding close.
// Anchor accumulation is independent of profile visibility and spatial rows.
[of_anchorValue, of_anchorStartedAt, of_anchorIncomplete] = of_anchorStep(of_sessionCvd, of_anchorStartTime, of_anchorPartial, time, time_close, anchorTime, barstate.isfirst, of_totalsValid, flow_delta)
of_sessionCvd := of_anchorValue
of_anchorStartTime := of_anchorStartedAt
of_anchorPartial := of_anchorIncomplete
of_structuralCvd := of_cvdValue(of_structuralCvd, flow_delta, of_totalsValid, false)

var array<of_Episode> of_episodes = array.new<of_Episode>()
var array<of_Marker> of_markers = array.new<of_Marker>()
var array<int> of_episodeEpochs = array.new<int>()
var array<bool> of_episodeLeft = array.new<bool>()
var array<float> of_priorVolumes = array.new<float>()
var array<float> of_priorAbsDeltas = array.new<float>()
var array<int> of_windowEpochs = array.new<int>()
var array<area_Record> of_originUpAreas = array.new<area_Record>()
var array<area_Record> of_originDownAreas = array.new<area_Record>()
var int of_epoch = 0
var bool of_previousTotalsValid = false
var float of_previousHigh = na
var float of_previousHighCvd = na
var int of_previousHighEpoch = -1
var int of_previousHighBar = na
var float of_previousLow = na
var float of_previousLowCvd = na
var int of_previousLowEpoch = -1
var int of_previousLowBar = na
// Baselines are calculated before the current observation is appended. Their
// history therefore gives the exact baseline available at each pivot origin.
float of_priorMean = of_volumeMean(of_priorVolumes, of_PRIOR_VOLUMES)
float of_deltaFloor = of_volumeMean(of_priorAbsDeltas, of_PRIOR_VOLUMES)
float of_priceHighPivot = ta.pivothigh(high, of_PIVOT_SIDE, of_PIVOT_SIDE)
float of_priceLowPivot = ta.pivotlow(low, of_PIVOT_SIDE, of_PIVOT_SIDE)
float of_windowHigh = ta.highest(high, of_PIVOT_WINDOW)
float of_windowLow = ta.lowest(low, of_PIVOT_WINDOW)

// Both frozen test bands share one native traversal. Each band retains its own
// exact overlap formula and native summation order, including zero-volume rows.
of_zoneStats(array<volume_row> of_rows, area_Record of_upZone, area_Record of_downZone) =>
    float of_upVolume = 0.0
    float of_upDelta = 0.0
    float of_downVolume = 0.0
    float of_downDelta = 0.0
    bool of_hasUp = not na(of_upZone)
    bool of_hasDown = not na(of_downZone)
    if of_hasUp or of_hasDown
        for of_row in of_rows
            float of_lower = of_row.down_price()
            float of_upper = of_row.up_price()
            float of_volume = of_row.total_volume()
            float of_delta = of_row.delta()
            if of_hasUp
                float of_fraction = of_intervalFraction(of_lower, of_upper, of_upZone.lower, of_upZone.upper)
                of_upVolume += of_volume * of_fraction
                of_upDelta += of_delta * of_fraction
            if of_hasDown
                float of_fraction = of_intervalFraction(of_lower, of_upper, of_downZone.lower, of_downZone.upper)
                of_downVolume += of_volume * of_fraction
                of_downDelta += of_delta * of_fraction
    [of_upVolume, of_upDelta, of_downVolume, of_downDelta]

// Frozen merged aliases remain useful if the primary source retires while an
// overlapping source is still alive. The registry resolves pre-cap live keys.
of_sourceAlive(string of_key, string of_aliases) =>
    bool of_alive = area_alive(of_key)
    if not of_alive
        array<string> of_keys = str.split(of_aliases, "|")
        for of_alias in of_keys
            if of_alias != "" and of_alias != of_key and area_alive(of_alias)
                of_alive := true
                break
    of_alive

of_originAlive(area_Record of_zone) =>
    not na(of_zone) and of_sourceAlive(of_zone.key, of_zone.aliases)

int of_auctionSuppressedBar = na
if barstate.isconfirmed
    bool of_epochReset = of_epochBreak(of_totalsValid, of_previousTotalsValid)
    if of_epochReset
        of_epoch += 1
        array.clear(of_windowEpochs)
        array.clear(of_originUpAreas)
        array.clear(of_originDownAreas)
        of_previousHigh := na
        of_previousHighCvd := na
        of_previousHighEpoch := -1
        of_previousHighBar := na
        of_previousLow := na
        of_previousLowCvd := na
        of_previousLowEpoch := -1
        of_previousLowBar := na
    if not of_totalsValid
        array.clear(of_priorVolumes)
        array.clear(of_priorAbsDeltas)
    array.push(of_windowEpochs, of_totalsValid ? of_epoch : -1)
    if of_windowEpochs.size() > of_PIVOT_WINDOW
        of_windowEpochs.shift()
    bool of_windowReady = of_windowIntact(of_windowEpochs, of_epoch, of_PIVOT_WINDOW)
    int of_stamp = na(time_close) ? time : time_close
    // Copies capture the test band that was available before this candle.
    area_Record of_upTest = area_select(1, close[1], low, high, close)
    area_Record of_downTest = area_select(-1, close[1], low, high, close)
    array.push(of_originUpAreas, of_upTest)
    array.push(of_originDownAreas, of_downTest)
    if of_originUpAreas.size() > of_PIVOT_WINDOW
        of_originUpAreas.shift()
        of_originDownAreas.shift()

    // Valid totals continue CVD even when spatial rows are omitted/incomplete.
    bool of_spatialValid = of_spatialReconciled(flow_rowsStrict and of_totalsValid, flow_rowCount, flow_rowsTotal, flow_rowsBuy, flow_rowsSell, flow_rowsDelta, flow_barVolume, of_nativeBuy, of_nativeSell, flow_delta)
    float of_upVolume = 0.0
    float of_upDelta = 0.0
    float of_downVolume = 0.0
    float of_downDelta = 0.0
    if of_spatialValid
        [of_upV, of_upD, of_downV, of_downD] = of_zoneStats(flow_rows, of_upTest, of_downTest)
        of_upVolume := of_upV
        of_upDelta := of_upD
        of_downVolume := of_downV
        of_downDelta := of_downD
    // Current-close cancellation/expiry frees capacity before unique evidence
    // is admitted. A pending response proposal remains pending for the final
    // evidence merge and confirmation below. A watch cancelled on this close
    // must leave and make a later fresh test before rearming the same record.
    if of_episodes.size() > 0
        for of_index = 0 to of_episodes.size() - 1
            of_Episode of_episode = of_episodes.get(of_index)
            int of_previousState = of_episode.state
            float of_eventEdge = auction_eventDirection == 1 ? auction_eventHigh : auction_eventLow
            bool of_matched = of_auctionMatch(of_episode.side, of_episode.reference, of_episode.lower, of_episode.upper, auction_eventDirection, auction_beforeReference, of_eventEdge)
            bool of_contradictory = of_matched and (auction_event == "A" or auction_event == "M")
            bool of_episodeAlive = of_episode.state >= 3 or of_sourceAlive(of_episode.key, of_episode.aliases)
            of_retireBeforeAdmission(of_episode, bar_index, low, high, close, syminfo.mintick, of_episodeAlive, of_totalsValid, of_contradictory)
            if of_previousState == 0 and of_episode.state >= 3
                of_episodeLeft.set(of_index, false)
    bool of_canAdmit = of_totalsValid and flow_barVolume > 0 and not na(of_atr14) and of_atr14 > 0
    // Formal comparisons use adjacent prior pivots, then immediately advance
    // memory to the newest pivot known at this close. Early current-bar tests
    // below must compare against that newly confirmed pivot when available.
    bool of_bullDiv = false
    bool of_bearDiv = false
    area_Record of_lowOrigin = na
    area_Record of_highOrigin = na
    if of_windowReady
        int of_originBar = bar_index - of_PIVOT_SIDE
        int of_originEpoch = of_epoch[of_PIVOT_SIDE]
        float of_originCvd = of_structuralCvd[of_PIVOT_SIDE]
        float of_originAtr = of_atr14[of_PIVOT_SIDE]
        float of_originFloor = of_deltaFloor[of_PIVOT_SIDE]
        float of_originRow = of_nativeRow[of_PIVOT_SIDE]
        int of_areaIndex = of_originUpAreas.size() - 1 - of_PIVOT_SIDE
        if not na(of_priceLowPivot)
            int of_lowGap = na(of_previousLowBar) ? 0 : of_originBar - of_previousLowBar
            of_bullDiv := of_materialDivergence(1, of_priceLowPivot, of_previousLow, of_originCvd, of_previousLowCvd, of_originEpoch, of_previousLowEpoch, of_lowGap, of_PIVOT_MAX_GAP, of_originRow, of_originAtr, of_windowHigh - of_priceLowPivot, of_originFloor)
            of_lowOrigin := of_originUpAreas.get(of_areaIndex)
            of_previousLow := of_priceLowPivot
            of_previousLowCvd := of_originCvd
            of_previousLowEpoch := of_originEpoch
            of_previousLowBar := of_originBar
        if not na(of_priceHighPivot)
            int of_highGap = na(of_previousHighBar) ? 0 : of_originBar - of_previousHighBar
            of_bearDiv := of_materialDivergence(-1, of_priceHighPivot, of_previousHigh, of_originCvd, of_previousHighCvd, of_originEpoch, of_previousHighEpoch, of_highGap, of_PIVOT_MAX_GAP, of_originRow, of_originAtr, of_priceHighPivot - of_windowLow, of_originFloor)
            of_highOrigin := of_originDownAreas.get(of_areaIndex)
            of_previousHigh := of_priceHighPivot
            of_previousHighCvd := of_originCvd
            of_previousHighEpoch := of_originEpoch
            of_previousHighBar := of_originBar
    if of_canAdmit
        float of_responseBuffer = math.max(syminfo.mintick, 0.05 * of_atr14)
        bool of_upRejection = not na(of_upTest) and close > of_upTest.upper + of_responseBuffer
        bool of_downRejection = not na(of_downTest) and close < of_downTest.lower - of_responseBuffer
        bool of_upPressure = of_localPressure(of_spatialValid, flow_barVolume, of_priorMean, of_priorVolumes.size(), of_upVolume, of_upDelta, 1, close[1], close, of_atr14, of_upRejection)
        bool of_downPressure = of_localPressure(of_spatialValid, flow_barVolume, of_priorMean, of_priorVolumes.size(), of_downVolume, of_downDelta, -1, close[1], close, of_atr14, of_downRejection)
        int of_earlyLowGap = na(of_previousLowBar) ? 0 : bar_index - of_previousLowBar
        int of_earlyHighGap = na(of_previousHighBar) ? 0 : bar_index - of_previousHighBar
        bool of_upEarly = of_windowReady and not na(of_upTest) and of_materialDivergence(1, low, of_previousLow, of_structuralCvd, of_previousLowCvd, of_epoch, of_previousLowEpoch, of_earlyLowGap, of_PIVOT_MAX_GAP, of_nativeRow, of_atr14, of_windowHigh - low, of_deltaFloor)
        bool of_downEarly = of_windowReady and not na(of_downTest) and of_materialDivergence(-1, high, of_previousHigh, of_structuralCvd, of_previousHighCvd, of_epoch, of_previousHighEpoch, of_earlyHighGap, of_PIVOT_MAX_GAP, of_nativeRow, of_atr14, high - of_windowLow, of_deltaFloor)
        if of_originAlive(of_upTest) and (of_upPressure or of_upEarly)
            of_admit(of_episodes, of_episodeEpochs, of_episodeLeft, of_upTest, 1, of_epoch, bar_index, of_stamp, of_atr14, low, of_upVolume, of_upDelta, flow_delta, of_upPressure, of_upEarly, false, na, close)
        if of_originAlive(of_downTest) and (of_downPressure or of_downEarly)
            of_admit(of_episodes, of_episodeEpochs, of_episodeLeft, of_downTest, -1, of_epoch, bar_index, of_stamp, of_atr14, high, of_downVolume, of_downDelta, flow_delta, of_downPressure, of_downEarly, false, na, close)

    // Formal 8/8 evidence is known now, eight closed bars after its origin.
    // Support pending/current tests only; historical confirmation stays frozen.
    if of_bullDiv and of_canAdmit and of_originAlive(of_lowOrigin)
        bool of_supported = of_supportFormal(of_episodes, of_episodeEpochs, of_lowOrigin, 1, of_epoch, bar_index, of_stamp)
        if not of_supported and of_originAlive(of_upTest) and of_sameArea(of_lowOrigin.key, of_lowOrigin.aliases, of_upTest)
            of_admit(of_episodes, of_episodeEpochs, of_episodeLeft, of_upTest, 1, of_epoch, bar_index, of_stamp, of_atr14, low, of_upVolume, of_upDelta, flow_delta, false, false, true, of_stamp, close)
    if of_bearDiv and of_canAdmit and of_originAlive(of_highOrigin)
        bool of_supported = of_supportFormal(of_episodes, of_episodeEpochs, of_highOrigin, -1, of_epoch, bar_index, of_stamp)
        if not of_supported and of_originAlive(of_downTest) and of_sameArea(of_highOrigin.key, of_highOrigin.aliases, of_downTest)
            of_admit(of_episodes, of_episodeEpochs, of_episodeLeft, of_downTest, -1, of_epoch, bar_index, of_stamp, of_atr14, high, of_downVolume, of_downDelta, flow_delta, false, false, true, of_stamp, close)

    if of_episodes.size() > 0
        for of_index = 0 to of_episodes.size() - 1
            of_Episode of_episode = of_episodes.get(of_index)
            float of_eventEdge = auction_eventDirection == 1 ? auction_eventHigh : auction_eventLow
            bool of_matched = of_auctionMatch(of_episode.side, of_episode.reference, of_episode.lower, of_episode.upper, auction_eventDirection, auction_beforeReference, of_eventEdge)
            bool of_contradictory = of_matched and (auction_event == "A" or auction_event == "M")
            bool of_failure = of_matched and auction_event == "F"
            bool of_episodeAlive = of_episode.state >= 3 or of_sourceAlive(of_episode.key, of_episode.aliases)
            bool of_confirmed = of_advance(of_episode, of_markers, bar_index, of_stamp, low, high, close, syminfo.mintick, of_episodeAlive, of_totalsValid, of_contradictory, of_failure, flow_barVolume > 0)
            if of_confirmed and of_failure
                of_auctionSuppressedBar := bar_index
            // This leave is committed after admission/response, so a later
            // candle must make the fresh test required to rearm an old record.
            if of_leftBand(close, of_episode.lower, of_episode.upper, of_episode.atr, syminfo.mintick)
                of_episodeLeft.set(of_index, true)
    if of_totalsValid
        of_priorVolumes.push(flow_barVolume)
        of_priorAbsDeltas.push(math.abs(flow_delta))
        if of_priorVolumes.size() > of_PRIOR_VOLUMES
            of_priorVolumes.shift()
            of_priorAbsDeltas.shift()
    of_previousTotalsValid := of_totalsValid

// Active confirmed context outranks a minor new watch. Deterministic priority,
// confirmation freshness and distance select among equally qualified states.
string of_contextCaption = "—"
string of_contextTooltip = of_totalsValid ? "No active area test." : "Flow data missing; confirmation unavailable."
int of_contextSide = 0
int of_contextBar = na
if barstate.islast and showFlowSummary
    int of_contextIndex = -1
    int of_contextTier = -1
    int of_contextPriority = -1
    int of_contextFreshness = -1
    float of_contextDistance = na
    if of_episodes.size() > 0
        for of_index = 0 to of_episodes.size() - 1
            of_Episode of_episode = of_episodes.get(of_index)
            if of_episode.state <= 2
                int of_tier = of_episode.state == 0 ? 0 : 1
                int of_freshness = of_tier == 0 ? of_episode.born : of_episode.confirmedBar
                float of_distance = math.abs(close - of_episode.level)
                bool of_better = of_contextIndex < 0 or of_tier > of_contextTier or (of_tier == of_contextTier and (of_episode.priority > of_contextPriority or (of_episode.priority == of_contextPriority and (of_freshness > of_contextFreshness or (of_freshness == of_contextFreshness and of_distance < of_contextDistance)))))
                if of_better
                    of_contextIndex := of_index
                    of_contextTier := of_tier
                    of_contextPriority := of_episode.priority
                    of_contextFreshness := of_freshness
                    of_contextDistance := of_distance
    if of_contextIndex >= 0
        of_Episode of_context = of_episodes.get(of_contextIndex)
        of_contextCaption := of_context.state == 0 ? "W" + (of_context.side == 1 ? "↑" : "↓") : of_caption(of_context.kind, of_context.side)
        of_contextTooltip := of_tooltip(of_context)
        of_contextSide := of_context.side
        of_contextBar := of_context.state == 0 ? of_context.born : of_context.confirmedBar

// Causal flow presentation. The engine owns records; this fragment owns every
// flow drawing and only changes the appearance of compatible auction labels.
const color of_DISPLAY_GOLD = #F4B740
const color of_DISPLAY_UP = #2EC5F6
const color of_DISPLAY_DOWN = #FF6B81
const color of_DISPLAY_PANEL = #0A1520
const color of_DISPLAY_MUTED = #8A97A6
const color of_DISPLAY_TEXT = #EAF2F8

// Eligible is a maximum, not a request to fill five slots with stale bands.
of_displayEligible(int state, bool sourceAlive, int born, int confirmedBar, int currentBar, float lower, float upper, int maxAge) =>
    bool eligible = sourceAlive and state >= 0 and state <= 2 and not na(born) and not na(lower) and not na(upper)
    if eligible
        eligible := born <= currentBar and lower <= upper and math.abs(lower) < 1e100 and math.abs(upper) < 1e100
    if eligible
        if state == 0
            eligible := currentBar - born <= 3
        else
            eligible := not na(confirmedBar)
            if eligible
                eligible := confirmedBar <= currentBar and currentBar - confirmedBar <= maxAge
    eligible

// Lexicographic ranking keeps a nearby minor watch from replacing a valid
// confirmed response. Exact ties preserve record order deterministically.
of_displayRanksBefore(int state, int priority, int freshness, float distance, int oldState, int oldPriority, int oldFreshness, float oldDistance) =>
    int rank = 0
    int oldRank = 0
    if state == 1
        rank := 3
    else if state == 2
        rank := 2
    else if state == 0
        rank := 1
    if oldState == 1
        oldRank := 3
    else if oldState == 2
        oldRank := 2
    else if oldState == 0
        oldRank := 1
    bool before = rank > oldRank
    if rank == oldRank
        before := priority > oldPriority
        if priority == oldPriority
            before := freshness > oldFreshness
            if freshness == oldFreshness
                before := distance < oldDistance
    before

of_displayWatchVisible(int state, int born, int confirmedBar) =>
    bool visible = state == 0
    if state == 1 or state == 2
        visible := not na(confirmedBar) and born < confirmedBar
    visible

// bar_index aligns marks with their actual candles. Evidence/response close
// timestamps stay in frozen records; placing time_close on the axis shifts a mark
// to the following candle's open. Guard Pine's 9999-bar index history limit.
of_displayMarkerVisible(int eventBar, int currentBar) =>
    bool visible = not na(eventBar)
    if visible
        visible := eventBar >= 0 and eventBar <= currentBar and currentBar - eventBar <= 9999
    visible

of_displayAge(int originBar, int currentBar) =>
    int age = na
    if not na(originBar)
        if originBar >= 0 and originBar <= currentBar
            age := currentBar - originBar
    age

// De-overlap presentation only: all response records keep their candle, price
// and frozen tooltip. Missing ATR preserves the full caption. Compare against
// full-caption primaries rather than chaining an entire run into one cluster.
of_displayCompact(int barA, int barB, float priceA, float priceB, int sideA, int sideB, float atr) =>
    bool compact = not na(barA) and not na(barB) and not na(priceA) and not na(priceB) and not na(atr)
    if compact
        compact := barA >= 0 and barB >= 0 and atr > 0 and atr < 1e100 and math.abs(priceA) < 1e100 and math.abs(priceB) < 1e100
    if compact
        compact := sideA == sideB and math.abs(sideA) == 1 and math.abs(barA - barB) <= 8 and math.abs(priceA - priceB) < atr
    compact

// Grouped failures may have an earlier drawing x. Current failure metadata
// identifies the owned label; label coordinates are never used to infer F.
of_displayAuctionMatch(bool candidatePresent, int suppressedBar, int currentBar, int failureBar, int failureReference, int eventReference, int failureDirection, int eventDirection, float failureEdge, float eventEdge, float tick) =>
    bool matched = candidatePresent and not na(suppressedBar) and not na(failureEdge) and not na(eventEdge)
    if matched
        matched := suppressedBar == currentBar and failureBar == currentBar and failureReference == eventReference and failureDirection == eventDirection and math.abs(failureEdge - eventEdge) <= tick * 0.5
    matched

of_displayTime(int stamp) =>
    na(stamp) ? "—" : str.format_time(stamp, "dd MMM HH:mm", syminfo.timezone)

of_displayState(int state) =>
    state == 0 ? "Watch · awaiting closed response" : state == 1 ? "Confirmed response" : state == 2 ? "Tested response" : state == 3 ? "Invalid" : "Expired"

of_displayBandName(int kind) =>
    kind == 1 ? "VAL" : kind == 2 ? "VAH" : kind == 4 ? "DPOC" : "POC"

of_displayTooltip(of_Episode of_episode) =>
    of_tooltip(of_episode)

var array<box> of_bandBoxes = array.new<box>()
var array<line> of_bandLines = array.new<line>()
var array<label> of_bandTags = array.new<label>()
var array<label> of_watchLabels = array.new<label>()
var array<label> of_historyLabels = array.new<label>()
// Retain scratch ownership explicitly and clear before every live redraw.
var array<of_Marker> of_primaryMarkers = array.new<of_Marker>()
var table of_summary = na

of_displayClear() =>
    while of_bandBoxes.size() > 0
        box.delete(of_bandBoxes.pop())
    while of_bandLines.size() > 0
        line.delete(of_bandLines.pop())
    while of_bandTags.size() > 0
        label.delete(of_bandTags.pop())
    while of_watchLabels.size() > 0
        label.delete(of_watchLabels.pop())
    while of_historyLabels.size() > 0
        label.delete(of_historyLabels.pop())
    of_bandBoxes.size()

// Compatible auction label suppression runs on each historical close, not
// only the last bar. The auction owner retains its ID and failure accounting.
if showOrderFlow and barstate.isconfirmed and auction_event == "F"
    bool of_hasFailureLabel = not na(auction_failureMarker) and auction_markers.indexof(auction_failureMarker) >= 0
    float of_failureEventEdge = auction_eventDirection == 1 ? auction_eventHigh : auction_eventLow
    if of_displayAuctionMatch(of_hasFailureLabel, of_auctionSuppressedBar, bar_index, auction_failureBar, auction_failureReference, auction_beforeReference, auction_failureDirection, auction_eventDirection, auction_failureEdge, of_failureEventEdge, syminfo.mintick)
        label.set_text(auction_failureMarker, "")
        label.set_color(auction_failureMarker, color.new(of_DISPLAY_GOLD, 100))
        label.set_textcolor(auction_failureMarker, color.new(of_DISPLAY_GOLD, 100))

if barstate.islast
    of_displayClear()
    of_primaryMarkers.clear()
    if showOrderFlow
        array<int> of_selected = array.new<int>()
        if of_episodes.size() > 0
            for of_index = 0 to of_episodes.size() - 1
                of_Episode of_candidate = of_episodes.get(of_index)
                if of_displayEligible(of_candidate.state, of_sourceAlive(of_candidate.key, of_candidate.aliases), of_candidate.born, of_candidate.confirmedBar, bar_index, of_candidate.lower, of_candidate.upper, of_LEVEL_AGE)
                    int of_position = of_selected.size()
                    int of_freshness = of_candidate.state == 0 ? of_candidate.born : of_candidate.confirmedBar
                    float of_distance = math.abs(of_candidate.level - close)
                    if of_selected.size() > 0
                        for of_rankIndex = 0 to of_selected.size() - 1
                            of_Episode of_retained = of_episodes.get(of_selected.get(of_rankIndex))
                            int of_retainedFreshness = of_retained.state == 0 ? of_retained.born : of_retained.confirmedBar
                            if of_displayRanksBefore(of_candidate.state, of_candidate.priority, of_freshness, of_distance, of_retained.state, of_retained.priority, of_retainedFreshness, math.abs(of_retained.level - close))
                                of_position := of_rankIndex
                                break
                    of_selected.insert(of_position, of_index)
                    if of_selected.size() > of_KEEP_LEVELS
                        of_selected.pop()
        for of_selectedIndex in of_selected
            of_Episode of_episode = of_episodes.get(of_selectedIndex)
            color of_ink = of_episode.state == 0 ? of_DISPLAY_GOLD : of_episode.side == 1 ? of_DISPLAY_UP : of_DISPLAY_DOWN
            color of_bandInk = color.new(of_ink, of_episode.state == 2 ? 70 : 42)
            string of_tip = of_displayTooltip(of_episode)
            string of_tag = of_displayBandName(of_episode.kind) + (of_episode.state == 0 ? " · W" : of_episode.state == 2 ? " · T" : " · " + of_caption(of_episode.kind, of_episode.side))
            of_bandBoxes.push(box.new(of_episode.bornTime, of_episode.upper, time_close, of_episode.lower, xloc=xloc.bar_time, border_color=na, bgcolor=color.new(of_ink, of_episode.state == 2 ? 97 : 94), force_overlay=true))
            of_bandLines.push(line.new(of_episode.bornTime, of_episode.lower, time_close, of_episode.lower, xloc=xloc.bar_time, color=of_bandInk, style=of_episode.state == 1 ? line.style_solid : line.style_dashed, width=1, force_overlay=true))
            of_bandLines.push(line.new(of_episode.bornTime, of_episode.upper, time_close, of_episode.upper, xloc=xloc.bar_time, color=of_bandInk, style=of_episode.state == 1 ? line.style_solid : line.style_dashed, width=1, force_overlay=true))
            of_bandTags.push(label.new(bar_index + 3, of_episode.level, of_tag, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(of_DISPLAY_PANEL, 25), textcolor=of_ink, size=size.tiny, tooltip=of_tip, force_overlay=true))
            if of_displayWatchVisible(of_episode.state, of_episode.born, of_episode.confirmedBar) and of_displayMarkerVisible(of_episode.born, bar_index) and of_watchLabels.size() < of_KEEP_LEVELS
                of_watchLabels.push(label.new(of_episode.born, of_episode.adverse, "W" + (of_episode.side == 1 ? "↑" : "↓"), xloc=xloc.bar_index, yloc=yloc.price, style=of_episode.side == 1 ? label.style_label_up : label.style_label_down, color=color.new(of_DISPLAY_GOLD, 90), textcolor=of_DISPLAY_GOLD, size=size.tiny, tooltip=of_tip, force_overlay=true))
        int of_markerCount = 0
        if of_markers.size() > 0
            for of_markerIndex = of_markers.size() - 1 to 0
                of_Marker of_marker = of_markers.get(of_markerIndex)
                if of_markerCount < of_KEEP_MARKERS and of_displayMarkerVisible(of_marker.confirmedBar, bar_index)
                    color of_markerInk = of_marker.side == 1 ? of_DISPLAY_UP : of_DISPLAY_DOWN
                    bool of_compact = false
                    for of_primary in of_primaryMarkers
                        if of_marker.caption == of_primary.caption and of_displayCompact(of_marker.confirmedBar, of_primary.confirmedBar, of_marker.price, of_primary.price, of_marker.side, of_primary.side, of_atr14)
                            of_compact := true
                            break
                    if not of_compact
                        of_primaryMarkers.push(of_marker)
                    of_historyLabels.push(label.new(of_marker.confirmedBar, of_marker.price, of_compact ? "" : of_marker.caption, xloc=xloc.bar_index, yloc=yloc.price, style=of_compact ? (of_marker.side == 1 ? label.style_triangleup : label.style_triangledown) : (of_marker.side == 1 ? label.style_label_up : label.style_label_down), color=color.new(of_markerInk, 18), textcolor=of_DISPLAY_PANEL, size=size.tiny, tooltip="Closed response · " + of_displayTime(of_marker.confirmedTime) + "\n" + of_marker.tooltip, force_overlay=true))
                    of_markerCount += 1
    if showFlowSummary
        if na(of_summary)
            of_summary := table.new(position.top_right, 2, 4, bgcolor=color.new(of_DISPLAY_PANEL, 9), frame_color=color.new(of_DISPLAY_MUTED, 65), frame_width=1, border_width=0, force_overlay=true)
        string of_cvdDisplay = not na(of_sessionCvd) ? str.tostring(of_sessionCvd, format.volume) + (of_anchorPartial ? "*" : "") : "—"
        string of_cvdTooltip = na(of_anchorStartTime) ? "Waiting for the selected start candle." : na(of_sessionCvd) ? "No valid footprint delta since this start." : of_anchorPartial ? "Partial total; some footprint delta is missing." : "Net buying minus selling since VP start."
        string of_pressureDisplay = of_totalsValid and not na(of_pressure) ? str.tostring(of_pressure, "#.0") + "%" : "—"
        color of_contextInk = str.startswith(of_contextCaption, "W") ? of_DISPLAY_GOLD : of_contextSide == 1 ? of_DISPLAY_UP : of_contextSide == -1 ? of_DISPLAY_DOWN : of_DISPLAY_MUTED
        int of_contextAge = of_displayAge(of_contextBar, bar_index)
        string of_contextDisplay = (of_contextCaption == "—" ? "No active test" : of_contextCaption) + (not na(of_contextAge) ? " · " + str.tostring(of_contextAge) + "b" : "")
        // The engine's frozen qualified context is authoritative; AU probes
        // cannot displace the active response shown by this row.
        table.cell(of_summary, 0, 0, "FLOW", text_color=of_DISPLAY_TEXT, text_size=size.small, text_halign=text.align_left)
        table.cell(of_summary, 1, 0, na(of_anchorStartTime) ? "Set VP start" : str.format_time(of_anchorStartTime, "dd MMM HH:mm", syminfo.timezone), text_color=of_DISPLAY_GOLD, text_size=size.tiny, text_halign=text.align_right, tooltip="Start time · " + syminfo.timezone + "\nSelect Value & Flow, then drag the time marker.")
        table.cell(of_summary, 0, 1, "VP CVD", text_color=of_DISPLAY_MUTED, text_size=size.tiny, text_halign=text.align_left, tooltip="Delta since VP start.\n* partial · — no valid delta.")
        table.cell(of_summary, 1, 1, of_cvdDisplay, text_color=na(of_sessionCvd) ? of_DISPLAY_MUTED : of_sessionCvd >= 0 ? of_DISPLAY_UP : of_DISPLAY_DOWN, text_size=size.small, text_halign=text.align_right, tooltip=of_cvdTooltip)
        table.cell(of_summary, 0, 2, "Net pressure", text_color=of_DISPLAY_MUTED, text_size=size.tiny, text_halign=text.align_left, tooltip="This candle: net buying/selling as % of volume.")
        table.cell(of_summary, 1, 2, of_pressureDisplay, text_color=not of_totalsValid or na(of_pressure) ? of_DISPLAY_MUTED : of_pressure >= 0 ? of_DISPLAY_UP : of_DISPLAY_DOWN, text_size=size.small, text_halign=text.align_right)
        table.cell(of_summary, 0, 3, "Flow", text_color=of_DISPLAY_MUTED, text_size=size.tiny, text_halign=text.align_left)
        table.cell(of_summary, 1, 3, of_contextDisplay, text_color=of_contextInk, text_size=size.tiny, text_halign=text.align_right, tooltip=of_contextTooltip)
    else if not na(of_summary)
        table.delete(of_summary)
        of_summary := na

// Owner maxima: 5 boxes, 10 edge lines, 5 right tags, 5 setup marks and 12
// immutable response marks. No extra plot, request, pane or user control.

// Commit only after OF evidence/response and its display have read prior areas.
// Every build owns a new array and new merged records. Closed context is read
// only thereafter; area_select still copies the record frozen at a test origin.
if barstate.isconfirmed
    area_context := area_nextContext

// Optional closed-bar conditions in TradingView's alert menu. Visibility only
// controls drawings; no webhook, order, risk model or live alert is installed.
bool prod_flowUp = false
bool prod_flowDown = false
if barstate.isconfirmed
    if of_markers.size() > 0
        for prod_index = of_markers.size() - 1 to 0
            of_Marker prod_marker = of_markers.get(prod_index)
            if prod_marker.confirmedBar < bar_index
                break
            if prod_eventGate(barstate.isconfirmed, prod_marker.confirmedBar, bar_index)
                if prod_marker.side == 1
                    prod_flowUp := true
                else if prod_marker.side == -1
                    prod_flowDown := true
alertcondition(prod_flowUp, "Flow: reclaim or hold up", "Confirmed upward flow response on {{ticker}} {{interval}}. Review the area and invalidation price.")
alertcondition(prod_flowDown, "Flow: rejection or hold down", "Confirmed downward flow response on {{ticker}} {{interval}}. Review the area and invalidation price.")
alertcondition(barstate.isconfirmed and auction_event != "", "Auction: confirmed event", "Confirmed auction event on {{ticker}} {{interval}}. Review the P/A/F/M marker.")

// Current-feature errors only; cumulative VP/row coverage banners are hidden.
string status_message = ""
if showInsights or showCloud or showSpikeProfiles or showConcentrations
    status_message := flow_statusMessage
if str.length(delta_statusMessage) > 0
    status_message += (str.length(status_message) > 0 ? "\n" : "") + delta_statusMessage
var label status_notice = na
string status_detail = status_message
float status_height = high + math.max(nz(ta.atr(20)), syminfo.mintick) * 1.5
if barstate.islast
    if str.length(status_message) > 0
        if na(status_notice)
            status_notice := label.new(bar_index + 3, status_height, status_message, style = label.style_label_lower_left,
                 color = color.new(color.orange, 85), textcolor = chart.fg_color, size = size.small, tooltip = status_detail, force_overlay = true)
        else
            label.set_xy(status_notice, bar_index + 3, status_height)
            label.set_text(status_notice, status_message)
            label.set_tooltip(status_notice, status_detail)
    else if not na(status_notice)
        label.delete(status_notice)
        status_notice := na
````
