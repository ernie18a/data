# Time-Slot Price-Volume Context [IEF]

- url: https://www.tradingview.com/script/Cno7dRxk-Time-Slot-Price-Volume-Context-IEF/
- type: indicator
- pine_id: PUB;1ebbeb7df5144aafac2bd8fe7b96c115
- version: 1.0

## Description

Time-Slot Price-Volume Context describes unusual bar-volume and price-movement combinations, then records which boundaries of the event candle were broken during a fixed observation window. It is an open-source chart research tool, not an entry/exit system or a performance backtest.

Prior-day time-slot baseline

The exchange clock divides each calendar day into 15-, 30-, or 60-minute slots. For each completed observed day, the script calculates the mean positive-volume bar volume in each slot. Expected volume is the equally weighted mean of those daily slot samples across the selected number of prior observed days. It does not aggregate exchange trading sessions or compare total session volume. Changing the chart timezone does not change the exchange-clock buckets.

The current day is excluded from its reference baseline. The first loaded day is discarded because it may be partial. Missing or zero-volume observations are excluded; missing slots reduce the displayed sample count. Other partially populated days can contribute available observations. A slot must have the configured minimum number of valid prior-day samples before events are classified. The current bar must also have positive volume and a valid prior ATR.

Relative volume (RV) = current bar volume / expected bar volume for its time slot.

Movement (M) = absolute close-to-close movement / previous bar's ATR.

This is close-to-close movement, not candle range or real-body size. Volume units and reliability depend on the data feed.

Event definitions

Low and high relative-volume thresholds are independently adjustable. Defaults are low below 0.7x and high above 1.5x. Values between the thresholds, including equality, are neutral. Low must be less than high. These settings are heuristics, not statistically optimized parameters.

High movement exceeds the movement threshold (default 1.5x prior ATR). Low movement is below its reciprocal (default approximately 0.67x). Equality is neither high nor low.

- HM/LV: high movement / low volume.
- LM/HV: low movement / high volume.
- HM/HV: high movement / high volume.

These names report observable conditions. They do not establish absorption, exhaustion, institutional activity, reversals, or continuation. Event labels and event alert conditions require a closed candle.

Follow-through observation

When a displayed event appears, its candle high, low, time, relative volume, movement, and sample count are frozen. Only events selected by the event-display toggles and label cooldown enter follow-through tracking. With the default cooldown of three, the next three bars after a displayed event cannot create another displayed/tracked event. Base event alerts are not suppressed by the display toggles or cooldown.

The following N closed chart bars are examined, excluding the event candle itself. N defaults to five; on a five-minute chart this is normally 25 minutes, but gaps or session closures can extend elapsed clock time. Wicks count: high strictly above the frozen high is an upper break, and low strictly below the frozen low is a lower break. Equality is only a touch.

- FT UP: upper boundary broken, lower boundary never broken in the window.
- FT DOWN: lower boundary broken, upper boundary never broken.
- FT BOTH: both boundaries broken during the window.
- FT NEITHER: neither boundary broken.

The outcome label is placed on the final observation candle only when it closes, never retrospectively on the event candle. Its tooltip identifies the original event, frozen values, and first break-bar numbers. BOTH does not infer intrabar ordering when both boundaries break in the same candle. Pending windows at the end of available data remain pending, not NEITHER. Overlapping windows are tracked independently.

Separate outcome alert conditions become true when the full observation window finishes. Turning off outcome labels does not disable tracking or outcome alerts; turning off tracking disables both. Existing TradingView alerts retain their saved script/settings snapshot, so recreate them after changes. Select Once Per Bar Close when configuring alerts. Replay chart observations do not verify delivery of live alerts.

Distinct purpose and use

This implementation links an equal-day-weighted, prior-day time-slot volume baseline to a bounded event-range observation. Unlike a rolling volume/range classifier, its reference is the same exchange-clock slot on prior observed days. Its follow-through results describe subsequent boundary breaks without converting them into wins, losses, trading probabilities, or hypothetical profits.

Use standard time-based minute candles whose interval divides the slot width. For example, Binance ETHUSDT five-minute candles work with 30-minute slots. Nonstandard charts and incompatible intervals are rejected. Configure the baseline and minimum samples first, then the descriptive thresholds and observation window. Compact labels, measurement tooltips, label size, cooldown, transparency, and dashboard corner are configurable.

Limitations and disclaimer

The script has no entries, stops, targets, execution model, costs, or profitability calculation. A boundary break can be small, temporary, or unfavorable to any particular trading method. Changing settings or the amount of loaded history recalculates the baseline and observations. Data revisions, sparse slots, missing bars, exchange-clock daylight-saving transitions, and volume-feed differences can affect results. Days are equally weighted but weekdays and weekends are pooled. Pine retains at most 500 labels, so older labels can disappear as new ones are created.

Developing-bar dashboard measurements can change; event and outcome classifications wait for closed bars. Educational and informational use only. Not financial, investment, or trading advice. No predictive accuracy, returns, or future performance is claimed.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright IndicatorEliteFlow
//@version=6
indicator("Time-Slot Price-Volume Context [IEF]", shorttitle="TSPVC [IEF]", overlay=true, max_labels_count=500)

// Exchange-calendar-day buckets, not exchange trading sessions.
// Each completed observed day contributes one mean bar-volume sample per slot.
// Current-day observations never participate in the reference baseline.
string baselineGroup = "Prior-day volume baseline"
int bucketMinutes = input.int(30, "Time-slot width (minutes)", options=[15, 30, 60], group=baselineGroup)
int lookbackDays = input.int(20, "Prior observed exchange days", minval=2, maxval=60, group=baselineGroup)
int minimumDays = input.int(5, "Minimum valid days per slot", minval=2, maxval=60, group=baselineGroup)
string rulesGroup = "Descriptive conditions"
float priceThreshold = input.float(1.5, "High movement / prior ATR", minval=1.01, step=0.1, group=rulesGroup)
float lowVolumeThreshold = input.float(0.7, "Low relative volume below (x)", minval=0.01, step=0.05, tooltip="Current volume divided by prior-day expected bar volume. Below this threshold is low; values between low and high are neutral.", group=rulesGroup)
float highVolumeThreshold = input.float(1.5, "High relative volume above (x)", minval=0.01, step=0.05, tooltip="Independent of the low threshold. Must be greater than the low threshold. These are descriptive settings, not optimized trading parameters.", group=rulesGroup)
int atrLength = input.int(14, "ATR length", minval=2, group=rulesGroup)
string displayGroup = "Display"
bool showHighMoveLowVolume = input.bool(true, "High movement / low volume", group=displayGroup)
bool showLowMoveHighVolume = input.bool(true, "Low movement / high volume", group=displayGroup)
bool showHighMoveHighVolume = input.bool(true, "High movement / high volume", group=displayGroup)
int transparency = input.int(25, "Label transparency", minval=0, maxval=100, group=displayGroup)
float offsetAtr = input.float(0.8, "Label offset / ATR", minval=0.0, step=0.1, group=displayGroup)
string labelSize = input.string("Normal", "Label size", options=["Small", "Normal", "Large"], group=displayGroup)
bool lightTheme = input.bool(false, "Black label text", group=displayGroup)
bool showDashboard = input.bool(true, "Show dashboard", group=displayGroup)
bool compactLabels = input.bool(true, "Compact labels", tooltip="HM/LV = high movement / low volume; LM/HV = low movement / high volume; HM/HV = high movement / high volume. Hover for measurements.", group=displayGroup)
int labelCooldown = input.int(3, "Label cooldown (skip bars)", minval=0, maxval=100, tooltip="Skips this many bars after a displayed label. Display only: alerts still report every qualifying confirmed bar.", group=displayGroup)
string dashboardPosition = input.string("Bottom right", "Dashboard position", options=["Top left", "Top right", "Bottom left", "Bottom right"], group=displayGroup)
dashboardAnchor = dashboardPosition == "Top left" ? position.top_left : dashboardPosition == "Top right" ? position.top_right : dashboardPosition == "Bottom left" ? position.bottom_left : position.bottom_right
labelTextSize = labelSize == "Small" ? size.small : labelSize == "Large" ? size.large : size.normal
color labelTextColor = lightTheme ? color.black : color.white
string followGroup = "Follow-through research"
bool trackFollowThrough = input.bool(true, "Track displayed events", tooltip="Only events selected by display toggles and label cooldown are tracked. No trade performance is measured.", group=followGroup)
int followBars = input.int(5, "Following closed bars", minval=1, maxval=50, group=followGroup)
bool showOutcomes = input.bool(true, "Show outcome labels", group=followGroup)
// Wick-based strict range breaks. Equality is a touch, not a break.
type ContextEvent
    int origin
    int originTime
    float rangeHigh
    float rangeLow
    float frozenVolume
    float frozenMovement
    int frozenSamples
    string kind
    bool brokeUp = false
    bool brokeDown = false
    int firstUp = 0
    int firstDown = 0
var array<ContextEvent> pendingEvents = array.new<ContextEvent>()
var int completedEvents = 0
var string lastOutcome = "None completed"
bool outcomeUp = false
bool outcomeDown = false
bool outcomeBoth = false
bool outcomeNeither = false

int slots = int(1440 / bucketMinutes)
int chartSeconds = int(timeframe.in_seconds())
bool supported = timeframe.isminutes and chartSeconds <= bucketMinutes * 60 and (bucketMinutes * 60) % chartSeconds == 0 and chart.is_standard
if barstate.isfirst and not supported
    runtime.error("Use standard time-based minute candles whose interval divides the time-slot width (e.g. 3-minute candles with 30-minute slots).")
if barstate.isfirst and minimumDays > lookbackDays
    runtime.error("Minimum valid days must not exceed prior observed exchange days.")
if barstate.isfirst and lowVolumeThreshold >= highVolumeThreshold
    runtime.error("Low relative-volume threshold must be less than the high threshold.")

var matrix<float> history = matrix.new<float>(lookbackDays, slots, na)
var array<float> dayVolume = array.new_float(slots, 0.0)
var array<int> dayBars = array.new_int(slots, 0)
var int writeRow = 0
var int trackedDate = na
var bool initialPartialDay = true
int exchangeDate = year * 10000 + month * 100 + dayofmonth
int slot = int(math.floor((hour * 60 + minute) / bucketMinutes))

// Roll over only when another observed exchange-calendar day starts.
// The first loaded day is discarded because the dataset may start mid-day.
if na(trackedDate)
    trackedDate := exchangeDate
else if exchangeDate != trackedDate
    if not initialPartialDay
        for i = 0 to slots - 1
            int observations = array.get(dayBars, i)
            float dailyMean = observations > 0 ? array.get(dayVolume, i) / observations : na
            matrix.set(history, writeRow, i, dailyMean)
        writeRow := (writeRow + 1) % lookbackDays
    initialPartialDay := false
    array.fill(dayVolume, 0.0)
    array.fill(dayBars, 0)
    trackedDate := exchangeDate

float volumeSum = 0.0
int validDays = 0
for d = 0 to lookbackDays - 1
    float sample = matrix.get(history, d, slot)
    if not na(sample) and sample > 0
        volumeSum += sample
        validDays += 1
float expectedVolume = validDays > 0 ? volumeSum / validDays : na
bool validVolume = not na(volume) and volume > 0
bool baselineReady = validDays >= minimumDays and not na(expectedVolume) and expectedVolume > 0
float relativeVolume = baselineReady and validVolume ? volume / expectedVolume : na
float priorAtr = ta.atr(atrLength)[1]
bool priceReady = not na(priorAtr) and priorAtr > 0 and not na(close[1])
float movement = priceReady ? math.abs(close - close[1]) / priorAtr : na
bool ready = baselineReady and validVolume and priceReady
bool highMove = ready and movement > priceThreshold
bool lowMove = ready and movement < 1.0 / priceThreshold
bool highVolume = ready and relativeVolume > highVolumeThreshold
bool lowVolume = ready and relativeVolume < lowVolumeThreshold
bool highMoveLowVolume = barstate.isconfirmed and highMove and lowVolume
bool lowMoveHighVolume = barstate.isconfirmed and lowMove and highVolume
bool highMoveHighVolume = barstate.isconfirmed and highMove and highVolume

string detail = "\nRV " + str.tostring(relativeVolume, "#.##") + "x | M " + str.tostring(movement, "#.##") + "x"
float yOffset = priorAtr * offsetAtr
var int lastLabelBar = na
bool labelAllowed = na(lastLabelBar) or bar_index - lastLabelBar > labelCooldown
bool displayEvent = labelAllowed and ((showHighMoveLowVolume and highMoveLowVolume) or (showLowMoveHighVolume and lowMoveHighVolume) or (showHighMoveHighVolume and highMoveHighVolume))
// Process older events BEFORE registering this bar's event. The event bar
// itself is excluded. Final results are drawn on origin + followBars only.
if trackFollowThrough and barstate.isconfirmed and array.size(pendingEvents) > 0
    for i = array.size(pendingEvents) - 1 to 0
        ContextEvent event = array.get(pendingEvents, i)
        int elapsed = bar_index - event.origin
        if elapsed >= 1
            if high > event.rangeHigh and not event.brokeUp
                event.brokeUp := true
                event.firstUp := elapsed
            if low < event.rangeLow and not event.brokeDown
                event.brokeDown := true
                event.firstDown := elapsed
            if elapsed == followBars
                string result = event.brokeUp and event.brokeDown ? "BOTH" : event.brokeUp ? "UP" : event.brokeDown ? "DOWN" : "NEITHER"
                outcomeUp := outcomeUp or result == "UP"
                outcomeDown := outcomeDown or result == "DOWN"
                outcomeBoth := outcomeBoth or result == "BOTH"
                outcomeNeither := outcomeNeither or result == "NEITHER"
                completedEvents += 1
                lastOutcome := event.kind + " -> " + result
                string tip = "Event: " + event.kind + " at " + str.format_time(event.originTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + " (exchange clock)\nFrozen high: " + str.tostring(event.rangeHigh, format.mintick) + " | Low: " + str.tostring(event.rangeLow, format.mintick) + "\nFrozen RV: " + str.tostring(event.frozenVolume, "#.##") + "x | Move: " + str.tostring(event.frozenMovement, "#.##") + "x | Samples: " + str.tostring(event.frozenSamples) + "\nWindow: next " + str.tostring(followBars) + " closed bars\nFirst upper break: " + (event.firstUp > 0 ? "bar " + str.tostring(event.firstUp) : "none") + "\nFirst lower break: " + (event.firstDown > 0 ? "bar " + str.tostring(event.firstDown) : "none") + "\nWick breaks; equality is a touch. BOTH does not establish break order when both occur in the same candle. Not a win/loss or trade signal."
                if showOutcomes
                    label.new(bar_index, high + priorAtr * (offsetAtr + 1.2), "FT " + result, style=label.style_label_down, color=color.new(color.gray, transparency), textcolor=labelTextColor, size=labelTextSize, tooltip=tip)
                array.remove(pendingEvents, i)
if displayEvent
    bool belowBar = lowMoveHighVolume
    string fullName = highMoveLowVolume ? "High movement / low volume" : lowMoveHighVolume ? "Low movement / high volume" : "High movement / high volume"
    string shortName = highMoveLowVolume ? "HM/LV" : lowMoveHighVolume ? "LM/HV" : "HM/HV"
    color eventColor = highMoveLowVolume ? color.orange : lowMoveHighVolume ? color.blue : color.teal
    string measurements = fullName + detail + "\nPrior-day samples: " + str.tostring(validDays)
    label.new(bar_index, belowBar ? low - yOffset : high + yOffset, compactLabels ? shortName : fullName + detail, style=belowBar ? label.style_label_up : label.style_label_down, color=color.new(eventColor, transparency), textcolor=labelTextColor, size=labelTextSize, tooltip=measurements)
    lastLabelBar := bar_index
    if trackFollowThrough
        array.push(pendingEvents, ContextEvent.new(bar_index, time, high, low, relativeVolume, movement, validDays, shortName))

alertcondition(outcomeUp, "Follow-through: upper break only", "TSPVC: completed observation window; event range broken above only. Not a trade result.")
alertcondition(outcomeDown, "Follow-through: lower break only", "TSPVC: completed observation window; event range broken below only. Not a trade result.")
alertcondition(outcomeBoth, "Follow-through: both sides broken", "TSPVC: completed observation window; both sides of event range broken. Intrabar sequence is not inferred.")
alertcondition(outcomeNeither, "Follow-through: neither side broken", "TSPVC: completed observation window; neither side of event range broken.")

alertcondition(highMoveLowVolume, "High movement / low volume", "TSPVC: confirmed high movement / low volume on {{ticker}} {{interval}}. Descriptive condition, not a trade signal.")
alertcondition(lowMoveHighVolume, "Low movement / high volume", "TSPVC: confirmed low movement / high volume on {{ticker}} {{interval}}. Does not establish absorption or participant identity.")
alertcondition(highMoveHighVolume, "High movement / high volume", "TSPVC: confirmed high movement / high volume on {{ticker}} {{interval}}. Does not establish continuation.")
alertcondition(highMoveLowVolume or lowMoveHighVolume or highMoveHighVolume, "Any context event", "TSPVC: confirmed price-volume context event on {{ticker}} {{interval}}.")

// Update current-day aggregates only after classification, once per closed bar.
// Pine rollback prevents intermediate realtime updates from accumulating.
if barstate.isconfirmed and validVolume
    array.set(dayVolume, slot, array.get(dayVolume, slot) + volume)
    array.set(dayBars, slot, array.get(dayBars, slot) + 1)

var table dashboard = table.new(dashboardAnchor, 2, 8, border_width=1)
if barstate.islast
    if showDashboard
        string state = not ready ? "Insufficient valid data" : not barstate.isconfirmed ? "Developing (no event)" : highMoveLowVolume ? "High move / low vol" : lowMoveHighVolume ? "Low move / high vol" : highMoveHighVolume ? "High move / high vol" : "Unclassified"
        table.cell(dashboard, 0, 0, "TSPVC", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 0, state, bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 0, 1, "Slot samples (days)", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 1, str.tostring(validDays) + " / " + str.tostring(minimumDays) + " minimum", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 0, 2, "Relative volume", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 2, str.tostring(relativeVolume, "#.##") + "x", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 0, 3, "Move / prior ATR", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 3, str.tostring(movement, "#.##") + "x", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 0, 4, "Clock", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 4, "Exchange calendar day", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 0, 5, "Volume thresholds", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 5, "Low < " + str.tostring(lowVolumeThreshold, "#.##") + "x | High > " + str.tostring(highVolumeThreshold, "#.##") + "x", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 0, 6, "Follow-through", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 6, trackFollowThrough ? str.tostring(followBars) + " bars | " + str.tostring(array.size(pendingEvents)) + " pending" : "Disabled", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 0, 7, "Last completed", bgcolor=color.black, text_color=color.white)
        table.cell(dashboard, 1, 7, trackFollowThrough ? lastOutcome : "Disabled", bgcolor=color.black, text_color=color.white)
    else
        table.clear(dashboard, 0, 0, 1, 7)
````
