# Range Breakout Outcome Audit

- url: https://www.tradingview.com/script/0noFvAyE-Range-Breakout-Outcome-Audit/
- type: indicator
- pine_id: PUB;d6bd53af0f6342eab88fa6cb145b216c
- version: 1.0

## Description

Range Breakout Outcome Audit

PURPOSE
This educational indicator studies what happens after a confirmed close breaks a preceding price range. It counts four observed outcomes: target first, invalidation first, ambiguous order, and timeout. The table separates long and short events and keeps every outcome in the denominator.

The focus is a reproducible event sample. A fixed observation window stays reserved even when an outcome is known early, and every event enters the table at the same horizon age. This prevents early outcomes from creating extra sampling opportunities or entering the recent sample sooner than slower outcomes.

EVENT DEFINITION
A long candidate closes strictly above the highest high of the preceding N bars. A short candidate closes strictly below their lowest low. The event bar is excluded from that range, and equality is not a breakout.

Each qualifying close is a candidate; there is no separate crossover or fresh-onset requirement. The indicator selects a candidate only when no earlier observation window is reserved. Candidates inside a reserved window are ignored. The table shows that ignored count across the loaded chart history.

At the selected event's confirmed close, the script freezes its close price and Wilder ATR. ATR includes the event bar. For a long event, the target is the close plus the target ATR multiple, and invalidation is the close minus the invalidation ATR multiple. Short events reverse those directions. Invalidation is an opposite ATR barrier, not a return inside the old range.

OBSERVATION AND CLASSIFICATION
Only the next H confirmed chart bars are observed. Nothing on the event bar is scored, because its high and low may have occurred before the breakout close.

For each later bar, until the first outcome is recorded:
- If its open is at or beyond one barrier, that barrier is the first observed outcome. This covers gaps without assuming an execution price.
- Otherwise, if both barriers are reached or exceeded in that bar, the outcome is ambiguous. The script does not guess the intrabar high/low order.
- If only one barrier is reached, it records target first or invalidation first.
- If neither barrier has been reached through bar H, the outcome is timeout.

Exact barrier equality counts. The first classification is frozen; later price movement cannot change it. Bar H is checked before timeout is assigned.

The full H-bar window remains reserved even after an early classification. Its maturity bar cannot start another event. The earliest possible next event is the following bar. Results join the rolling table only at maturity. The latest unmatured window is excluded even when its first outcome is already known.

READING THE TABLE
K is the maximum number of matured events retained in one shared rolling sample across both directions. The newest matured event replaces the oldest when the sample exceeds K.

Each percentage equals that outcome's count divided by the Events (N) count in its own column. Target first, invalidation first, ambiguous, and timeout therefore account for the whole matured sample. An empty column displays n/a. The Long and Short columns are subsets of the shared last-K sample, not K events each.

The subtitle shows range length, ATR length, target distance (T), invalidation distance (I), horizon (H), and sample limit (K). T and I are ATR multiples. The Unmatured row shows completed observation bars and any outcome already recorded. Loaded-history totals are separate from the rolling sample.

CHART DISPLAY AND USE
Add the indicator to a standard market-price chart and select the range length, ATR length, barrier distances, horizon, and rolling sample size. Default values are illustrative, not optimized settings.

Small E markers identify selected event closes. Teal marks a long event; orange marks a short event. Optional levels show the frozen event close, target, and invalidation during the reserved window; they clear on the maturity bar. They stay fixed after an early outcome while the observation slot remains reserved. Non-standard charts are blocked.

The Data Window exposes matured outcome codes for manual inspection: positive for long and negative for short, with 1 = target first, 2 = invalidation first, 3 = ambiguous, and 4 = timeout. A code appears at the maturity bar. The table always describes the latest dataset state, not the bar under the cursor.

LIMITATIONS
This is an observational, sequentially selected sample, not every breakout. Non-overlapping windows do not imply statistically independent events. Nearby events can share market regimes and overlapping range-estimation data.

Results depend on symbol, timeframe, session settings, available history, and inputs. Changing the horizon changes which candidates are selected. Loading more history can change the initial sampling phase and later selections. Changing target or invalidation distance keeps the event cohort fixed for the same dataset, range, ATR length, and horizon, but changes classifications. Repeated parameter selection after seeing results can overfit the sample.

Large event bars can increase the frozen ATR and widen both barriers. Only included chart bars are observed; movement in excluded sessions is not reconstructed. Feed revisions or changes to the chart dataset can alter historical results. Small samples and rounded percentages need care.

The indicator does not model orders, fills, spread, commissions, slippage, position sizing, account rules, or profit and loss. A target-first percentage is not a trading win rate or a forecast. It provides no validated strategy, profitability claim, or recommendation to trade.

## Source Code

````pine
//@version=6
indicator("Range Breakout Outcome Audit", overlay = true, max_bars_back = 600)

// Original educational event-study implementation for ZILLIONAIRE010.
// This indicator records observed OHLC barrier outcomes, not orders or returns.
// All event/state changes happen at a confirmed chart close. No event-bar scoring.
// One fixed H-bar window is reserved per selected event, even after an early hit.
// Every outcome enters the rolling sample only at H-bar maturity.

string groupStudy = "Study definition"
int rangeLength = input.int(20, "Prior range bars", minval = 2, maxval = 500, group = groupStudy, tooltip = "A candidate closes strictly above the highest high, or below the lowest low, of these PRECEDING bars. The event bar is excluded from the range.")
int atrLength = input.int(14, "ATR length", minval = 1, maxval = 500, group = groupStudy, tooltip = "Wilder ATR is measured at the confirmed event close, including the event bar, and then frozen.")
float targetATR = input.float(1.0, "Target distance (ATR)", minval = 0.1, maxval = 20.0, step = 0.1, group = groupStudy)
float invalidationATR = input.float(1.0, "Invalidation distance (ATR)", minval = 0.1, maxval = 20.0, step = 0.1, group = groupStudy, tooltip = "The opposite ATR barrier from the event close. This is not a return-to-range invalidation rule or an executable stop order.")
int horizon = input.int(20, "Observation horizon (bars)", minval = 1, maxval = 500, group = groupStudy, tooltip = "Observe the NEXT H confirmed bars. Reserve the full H-bar window even if a barrier is reached early. The maturity bar cannot start a new event.")
int sampleLimit = input.int(200, "Last matured events to retain", minval = 1, maxval = 2000, group = groupStudy, tooltip = "A shared rolling sample across both directions. Every outcome enters only at H-bar maturity. The newest unmatured event is excluded, even if its first outcome is already known.")

string groupDisplay = "Display"
bool showEvents = input.bool(true, "Show selected event markers", group = groupDisplay)
bool showLevels = input.bool(false, "Show reserved-window levels", group = groupDisplay, tooltip = "Fixed event close, target and invalidation levels. They remain during the reserved window even after an early outcome, and clear on its maturity bar.")
bool showTable = input.bool(true, "Show audit table", group = groupDisplay)
string tableCorner = input.string("Top right", "Table corner", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = groupDisplay)

// Codes: 0 awaiting first outcome, 1 target first, 2 invalidation first,
// 3 ambiguous intrabar order, 4 timeout. Direction is 1 long or -1 short.
f_firstObserved(int direction, float target, float invalidation, float o, float h, float l) =>
    bool targetAtOpen = direction == 1 ? o >= target : o <= target
    bool invalidAtOpen = direction == 1 ? o <= invalidation : o >= invalidation
    bool targetInBar = direction == 1 ? h >= target : l <= target
    bool invalidInBar = direction == 1 ? l <= invalidation : h >= invalidation
    // An open at/beyond a barrier is the first observed price for this bar.
    // A gap is an observation, not an assumed fill at the barrier price.
    int result = targetAtOpen ? 1 : invalidAtOpen ? 2 : targetInBar and invalidInBar ? 3 : targetInBar ? 1 : invalidInBar ? 2 : 0
    result

f_bucket(int signedOutcome) =>
    (signedOutcome > 0 ? 0 : 4) + math.abs(signedOutcome) - 1

f_outcomeName(int outcome) =>
    switch outcome
        1 => "target first"
        2 => "invalidation first"
        3 => "ambiguous"
        4 => "timeout"
        => "awaiting outcome"

f_countRate(int count, int denominator) =>
    denominator > 0 ? str.tostring(count) + " (" + str.tostring(100.0 * count / denominator, "0.0") + "%)" : "0 (n/a)"

f_cell(table tableId, int column, int row, string txt, color txtColor, color bgColor) =>
    table.cell(tableId, column, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = size.small)

if barstate.isfirst and not chart.is_standard
    runtime.error("Use a standard OHLC chart. Synthetic or non-standard chart prices are not supported by this audit.")

// These history-dependent functions run on EVERY execution in global scope.
float priorHigh = ta.highest(high[1], rangeLength)
float priorLow = ta.lowest(low[1], rangeLength)
float atrNow = ta.atr(atrLength)
bool ready = bar_index >= rangeLength and not na(priorHigh) and not na(priorLow) and not na(atrNow) and atrNow > 0
int candidateDirection = ready ? (close > priorHigh ? 1 : close < priorLow ? -1 : 0) : 0

var bool reserved = false
var int eventBar = na
var int eventDirection = 0
var float eventClose = na
var float eventATR = na
var float targetLevel = na
var float invalidationLevel = na
var int firstOutcome = 0
var int confirmedAge = 0
var int ignoredCandidates = 0
var int totalMatured = 0
var array<int> outcomeQueue = array.new<int>(0)
// Long target/invalid/ambiguous/timeout, then the same four for short.
var array<int> outcomeCounts = array.new<int>(8, 0)

bool selectedLong = false
bool selectedShort = false
int maturedCode = na

if barstate.isconfirmed
    // The if/else deliberately blocks a new event on the maturity bar.
    if reserved
        confirmedAge := bar_index - eventBar
        if candidateDirection != 0
            ignoredCandidates += 1
        if firstOutcome == 0
            firstOutcome := f_firstObserved(eventDirection, targetLevel, invalidationLevel, open, high, low)
        if confirmedAge >= horizon
            int finalOutcome = firstOutcome == 0 ? 4 : firstOutcome
            int signedOutcome = eventDirection * finalOutcome
            int addedBucket = f_bucket(signedOutcome)
            array.push(outcomeQueue, signedOutcome)
            array.set(outcomeCounts, addedBucket, array.get(outcomeCounts, addedBucket) + 1)
            if array.size(outcomeQueue) > sampleLimit
                int removedOutcome = array.shift(outcomeQueue)
                int removedBucket = f_bucket(removedOutcome)
                array.set(outcomeCounts, removedBucket, array.get(outcomeCounts, removedBucket) - 1)
            totalMatured += 1
            maturedCode := signedOutcome
            reserved := false
    else if candidateDirection != 0
        reserved := true
        eventBar := bar_index
        eventDirection := candidateDirection
        eventClose := close
        eventATR := atrNow
        targetLevel := eventClose + eventDirection * targetATR * eventATR
        invalidationLevel := eventClose - eventDirection * invalidationATR * eventATR
        firstOutcome := 0
        confirmedAge := 0
        selectedLong := eventDirection == 1
        selectedShort := eventDirection == -1

// Mark only the selected bar, at its actual time. No back-offset or repainting
// of an earlier event marker to show its later outcome.
plotshape(showEvents and selectedLong, title = "Selected long event", style = shape.triangleup, location = location.belowbar, color = color.teal, size = size.tiny, text = "E")
plotshape(showEvents and selectedShort, title = "Selected short event", style = shape.triangledown, location = location.abovebar, color = color.orange, size = size.tiny, text = "E")
plot(showLevels and reserved ? eventClose : na, title = "Frozen event close", color = color.gray, style = plot.style_linebr)
plot(showLevels and reserved ? targetLevel : na, title = "Frozen target", color = color.teal, style = plot.style_linebr)
plot(showLevels and reserved ? invalidationLevel : na, title = "Frozen invalidation", color = color.orange, style = plot.style_linebr)

// Data Window diagnostics for manual replay and chart-data export.
// Codes are signed by direction: + long, - short; 1 target, 2 invalid,
// 3 ambiguous, 4 timeout. A matured code appears ONLY at horizon maturity.
plot(maturedCode, title = "Matured outcome code (+ long / - short)", display = display.data_window)
plot(reserved ? eventDirection : 0, title = "Reserved event direction", display = display.data_window)
plot(reserved ? confirmedAge : na, title = "Reserved confirmed age", display = display.data_window)
plot(reserved ? firstOutcome : na, title = "Reserved first outcome (0 = waiting)", display = display.data_window)
plot(array.size(outcomeQueue), title = "Matured rolling sample N", display = display.data_window)

string tablePosition = switch tableCorner
    "Bottom right" => position.bottom_right
    "Top left" => position.top_left
    "Bottom left" => position.bottom_left
    => position.top_right
var table audit = table.new(tablePosition, 4, 13, border_width = 1, border_color = color.new(color.gray, 70))
if barstate.isfirst
    table.merge_cells(audit, 0, 0, 3, 0)
    table.merge_cells(audit, 0, 1, 3, 1)
    table.merge_cells(audit, 0, 8, 3, 8)
    table.merge_cells(audit, 0, 9, 3, 9)
    table.merge_cells(audit, 0, 10, 3, 10)
    table.merge_cells(audit, 0, 11, 3, 11)
    table.merge_cells(audit, 0, 12, 3, 12)

if barstate.islast and showTable
    color fg = chart.fg_color
    color bg = color.new(chart.bg_color, 5)
    color headerBg = color.new(color.blue, 85)
    int longN = 0
    int shortN = 0
    for i = 0 to 3
        longN += array.get(outcomeCounts, i)
        shortN += array.get(outcomeCounts, i + 4)
    int allN = longN + shortN
    f_cell(audit, 0, 0, "Range Breakout Outcome Audit", fg, headerBg)
    f_cell(audit, 0, 1, "Range " + str.tostring(rangeLength) + " | ATR " + str.tostring(atrLength) + " | T " + str.tostring(targetATR, "0.0") + " / I " + str.tostring(invalidationATR, "0.0") + " | H " + str.tostring(horizon) + " | K " + str.tostring(sampleLimit), fg, bg)
    f_cell(audit, 0, 2, "Outcome", fg, headerBg)
    f_cell(audit, 1, 2, "All", fg, headerBg)
    f_cell(audit, 2, 2, "Long", fg, headerBg)
    f_cell(audit, 3, 2, "Short", fg, headerBg)
    f_cell(audit, 0, 3, "Events (N)", fg, bg)
    f_cell(audit, 1, 3, str.tostring(allN), fg, bg)
    f_cell(audit, 2, 3, str.tostring(longN), fg, bg)
    f_cell(audit, 3, 3, str.tostring(shortN), fg, bg)
    for i = 0 to 3
        int longCount = array.get(outcomeCounts, i)
        int shortCount = array.get(outcomeCounts, i + 4)
        string rowName = i == 0 ? "Target first" : i == 1 ? "Invalidation first" : i == 2 ? "Ambiguous" : "Timeout"
        f_cell(audit, 0, i + 4, rowName, fg, bg)
        f_cell(audit, 1, i + 4, f_countRate(longCount + shortCount, allN), fg, bg)
        f_cell(audit, 2, i + 4, f_countRate(longCount, longN), fg, bg)
        f_cell(audit, 3, i + 4, f_countRate(shortCount, shortN), fg, bg)
    f_cell(audit, 0, 8, "Each % = outcome count / column N", fg, bg)
    string pendingText = reserved ? "Unmatured: " + (eventDirection == 1 ? "long " : "short ") + str.tostring(confirmedAge) + "/" + str.tostring(horizon) + " | " + f_outcomeName(firstOutcome) : "Unmatured: none"
    f_cell(audit, 0, 9, pendingText + " | excluded from N", fg, bg)
    f_cell(audit, 0, 10, "Loaded history: " + str.tostring(totalMatured) + " matured; " + str.tostring(ignoredCandidates) + " lockout candidates ignored", fg, bg)
    f_cell(audit, 0, 11, "Non-overlap does not imply independence", fg, bg)
    f_cell(audit, 0, 12, "Educational only | No fills, costs or P&L", fg, bg)
````
