# Adaptive Gap Continuation Matrix [Pineify]

- url: https://www.tradingview.com/script/M1KBwhbQ-Adaptive-Gap-Continuation-Matrix-Pineify/
- type: indicator
- pine_id: PUB;9407022088bd47359a7165d9b3362cee
- version: 1.0

## Description

[b]Adaptive Gap Continuation Matrix [Pineify][/b]

[b]Overview[/b]
This session gap indicator separates close position inside an opening gap from efficient recent travel. The ribbon and event matrix describe continuation, stall, repair and range fill in either gap direction.

[b]Problem Definition[/b]
An opening jump does not establish price acceptance. A fixed percentage ignores recent volatility, while a filled/unfilled label hides the route taken: two unfilled gaps can contain outward travel or noisy erosion. A wick reaching the old close also differs from a close staying there. The invariant is a frozen event reference with separate current close fill and maximum range fill.

[b]Design Rationale[/b]
Prior ATR prevents the opening jump from changing its own eligibility threshold. The last regular close excludes extended closes from the target. Recent event-only steps replace cumulative efficiency so early travel can leave the window and expose a later rebound. Frozen median volume discounts weak participation; capped ratios bound spike influence. Hysteresis reduces chatter but delays transitions. Range touch ends the event without guessing intrabar ordering.

[b]Key Features[/b]
[list]
[*]One bounded event per qualifying regular opening.
[*]Gap position and participation-adjusted path rails.
[*]Confirmed residence counts, close/range fill and optional live dots.
[*]Continuation, repair, range-fill, event-end and interruption alerts.
[/list]

[b]How It Works[/b]
On a standard 1m-1H chart, the first regular bar's close confirms its open versus the last observed regular close. Defaults require valid OHLC and positive volume over 30 prior chart bars, with a 0.35 ATR minimum gap. The event freezes ATR and median volume; path starts at the open.

X is twice the fraction of gap retained by the close minus one, clipped to [-1,1]: +100 means opening side, zero half gap, -100 old-close side. Y is gap-directed net close movement divided by absolute close-step travel over the latest eight event bars, multiplied by min(1, square root of mean RVOL). Individual RVOL ratios are capped at four.

Continuation enters at 60% retention, +0.30 flow and 0.80 mean RVOL; repair at 20% close fill, -0.30 flow and the same volume gate. Existing states use looser release boundaries; otherwise stalled is sought. Two candidate closes confirm changes. A range touch completes at close; 60 event bars, leaving regular trading or invalid data terminates further sampling.

[b]How Multiple Indicators Work Together[/b]
ATR admits the event, position locates the close, efficiency measures its recent route and RVOL discounts thin travel while gating state entry. Removing the rolling window would hide late rebounds; removing volume would give weak participation equal support. Range fill terminates; residence counts confirmed samples.

[b]Trading Ideas and Insights[/b]
Continuation describes efficient gap-side travel; inspect price structure before considering a trade. Repair describes inward travel with participation and does not promise completion. Left-side positive flow can show a rebound after repair even with a stalled class. A fill alert reports contact with the old close, not an executable fill price.

[b]Unique Aspects[/b]
A static gap box lacks the rolling event-only coordinate used here. Early path steps leave the efficiency window while the target remains frozen, separating recent reversal from fill depth. Participation shrinks flow without moving the gap reference. Dwell counts and terminal range contact distinguish confirmed history, present geometry and event completion.

[b]How to Use[/b]
Teal marks continuation, amber repair, purple range completion and gray stalled/ended states. The ribbon is the primary view. Matrix left means more close fill; up means gap-direction flow. Quadrant captions are geometric readings, not extra states. @ is the latest closed point; old dots fade and overlaps keep the newest. Use alerts once per bar close.

[b]Customization[/b]
Baseline length sets prior ATR and volume references; minimum gap sets eligibility. Event bars cap duration, and path length controls forgetting. Flow entry, release/entry ratio, RVOL and candidate-close count control admission and persistence. Matrix, residence, preview, markers, background and summary can be disabled without removing the ribbon.

[b]Assumptions and Limitations[/b]
Regular may mean electronic hours for futures; subsessions can lack the opening flag. Missing edge bars or changed sessions alter the gap. ATR/volume baselines include displayed extended bars and have no seasonal volume adjustment. RVOL is not order flow or a probability. Initial history needs a prior regular close and full baseline; zero/missing volume ends an active event without resumption.

States, trail and counts update only at close. Optional dots fluctuate intrabar while rails hold the last confirmation. Range contact reveals no intrabar high/low order or close acceptance. Coordinates clip extensions and matrix cells quantize to 25-point steps; only the latest bounded trail is shown. The lower residence lane shows the sampled class's share, with a gray terminal bar on timeout. Parameters, history and feed revisions can change results. Execution and profitability are not evaluated.

[b]Conclusion[/b]
The matrix keeps gap location, recent travel, participation and observed contact distinguishable. Use these confirmed descriptions within a known session context; trade selection and execution require separate judgment.

## Source Code

````pine
//@version=6
indicator("Adaptive Gap Continuation Matrix [Pineify]", overlay=false, max_bars_back=500, precision=1)

// Independent event model. Coordinates are separate views, not statistically independent.
string groupEvent = "Session event"
int baselineLength = input.int(30, "Prior chart-bar baseline", minval=10, maxval=200, group=groupEvent)
float minimumGap = input.float(0.35, "Minimum gap / prior ATR", minval=0.05, maxval=5.0, step=0.05, group=groupEvent)
int eventLimit = input.int(60, "Maximum regular event bars", minval=5, maxval=240, group=groupEvent)
int efficiencyLength = input.int(8, "Recent event path bars", minval=2, maxval=20, group=groupEvent)
string groupState = "Confirmed states"
float entryFlow = input.float(0.30, "Flow entry magnitude", minval=0.15, maxval=0.85, step=0.05, group=groupState)
float releaseFraction = input.float(0.40, "Flow release / entry", minval=0.10, maxval=0.80, step=0.05, group=groupState)
float minimumParticipation = input.float(0.80, "Minimum recent capped RVOL", minval=0.20, maxval=2.0, step=0.05, group=groupState)
int confirmationBars = input.int(2, "Consecutive candidate closes", minval=1, maxval=5, group=groupState)
string groupVisual = "Visual layers"
bool showMatrix = input.bool(true, "Latest event matrix", group=groupVisual)
bool showDwell = input.bool(true, "Current state residence columns", group=groupVisual)
bool showPreview = input.bool(true, "Live candidate dots", group=groupVisual)
bool showMarkers = input.bool(true, "Confirmed transition markers", group=groupVisual)
bool showWash = input.bool(false, "State background", group=groupVisual)
bool showSummary = input.bool(true, "Event summary", group=groupVisual)
int trailLength = input.int(24, "Matrix trail points", minval=4, maxval=32, group=groupVisual)

color continuationColor = #008F9A
color repairColor = #B56A13
color filledColor = #7655C4
color stalledColor = #697785
color fg = chart.fg_color
color bg = chart.bg_color
f_stateName(int state) =>
    switch state
        1 => "STALLED"
        2 => "CONTINUATION"
        3 => "REPAIR"
        4 => "FILLED (RANGE)"
        5 => "ENDED"
        6 => "DATA INVALID"
        => "NO EVENT"
f_stateColor(int state) =>
    switch state
        2 => continuationColor
        3 => repairColor
        4 => filledColor
        => stalledColor
f_clip(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

bool supported = timeframe.isintraday and timeframe.in_seconds() >= 60 and timeframe.in_seconds() <= 3600 and chart.is_standard
bool validPrice = not na(open) and not na(high) and not na(low) and not na(close) and high >= low and high >= math.max(open, close) and low <= math.min(open, close)
bool validData = validPrice and not na(volume) and volume > 0
float priorAtr = ta.atr(baselineLength)[1]
float priorVolume = ta.median(volume, baselineLength)[1]
float priorCoverage = ta.sma(validData ? 1.0 : 0.0, baselineLength)[1]
bool baselineReady = priorCoverage == 1.0 and not na(priorAtr) and priorAtr > syminfo.mintick and not na(priorVolume) and priorVolume > 0
bool firstRegular = session.isfirstbar_regular

var float lastRegularClose = na
var bool active = false
var float anchor = na
var float eventOpen = na
var float gapSize = na
var float frozenAtr = na
var float frozenVolume = na
var float gapAtr = na
var int direction = 0
var float previousEventClose = na
var int age = 0
var int state = 0
var int candidateState = 1
var int candidateCount = 0
var float confirmedX = na
var float confirmedY = na
var float confirmedFill = na
var float maximumFill = 0.0
var float confirmedRvol = na
var string endReason = "Await regular session"
var array<float> steps = array.new_float()
var array<float> rvols = array.new_float()
var array<float> trailX = array.new_float()
var array<float> trailY = array.new_float()
var array<int> dwell = array.new_int(5, 0)

// For a live candidate, add the new step mathematically without mutating memory.
f_path(array<float> changes, array<float> participation, float step, float rvol, int length) =>
    float net = step
    float distance = math.abs(step)
    float volumeSum = rvol
    int start = array.size(changes) >= length ? 1 : 0
    int count = 1
    if array.size(changes) > start
        for i = start to array.size(changes) - 1
            float change = array.get(changes, i)
            net += change
            distance += math.abs(change)
            volumeSum += array.get(participation, i)
            count += 1
    float meanRvol = volumeSum / count
    float efficiency = distance > 0 ? net / distance : 0.0
    float flow = efficiency * math.min(math.sqrt(meanRvol), 1.0)
    [flow, meanRvol]

bool eventSample = false
int sampleState = 0
bool continuationAlert = false
bool repairAlert = false
bool filledAlert = false
bool endedAlert = false
bool invalidAlert = false

if barstate.isconfirmed
    if firstRegular
        active := false
        anchor := na
        eventOpen := na
        gapSize := na
        frozenAtr := na
        frozenVolume := na
        gapAtr := na
        direction := 0
        previousEventClose := na
        age := 0
        state := 0
        candidateState := 1
        candidateCount := 0
        confirmedX := na
        confirmedY := na
        confirmedFill := na
        confirmedRvol := na
        maximumFill := 0.0
        array.clear(steps)
        array.clear(rvols)
        array.clear(trailX)
        array.clear(trailY)
        array.fill(dwell, 0)
        endReason := supported ? "No qualifying gap" : "Use standard 1m-1H chart"
        if supported and validData and baselineReady and not na(lastRegularClose)
            float openingGap = open - lastRegularClose
            if math.abs(openingGap) >= minimumGap * priorAtr and math.abs(openingGap) > syminfo.mintick
                anchor := lastRegularClose
                eventOpen := open
                gapSize := math.abs(openingGap)
                frozenAtr := priorAtr
                frozenVolume := priorVolume
                gapAtr := gapSize / frozenAtr
                direction := openingGap > 0 ? 1 : -1
                previousEventClose := eventOpen
                state := 1
                active := true
                endReason := "Active regular event"
        else if supported
            state := 6
            endReason := "Missing prior close or baseline"
    if active
        if not session.ismarket
            active := false
            state := 5
            endReason := "Regular session ended"
            endedAlert := true
        else if not validData or not supported
            active := false
            state := 6
            endReason := "Price or volume interrupted"
            invalidAlert := true
        else
            float step = direction * (close - previousEventClose)
            float rvol = f_clip(volume / frozenVolume, 0.0, 4.0)
            [flow, meanRvol] = f_path(steps, rvols, step, rvol, efficiencyLength)
            array.push(steps, step)
            array.push(rvols, rvol)
            if array.size(steps) > efficiencyLength
                array.shift(steps)
                array.shift(rvols)
            previousEventClose := close
            age += 1
            float retention = direction * (close - anchor) / gapSize
            confirmedX := f_clip(2.0 * retention - 1.0, -1.0, 1.0)
            confirmedY := flow
            confirmedRvol := meanRvol
            confirmedFill := f_clip(1.0 - retention, 0.0, 1.0)
            float rangeFill = f_clip(direction * (eventOpen - (direction == 1 ? low : high)) / gapSize, 0.0, 1.0)
            maximumFill := math.max(maximumFill, rangeFill)
            bool touched = direction == 1 ? low <= anchor : high >= anchor
            int oldState = state
            if touched
                state := 4
                active := false
                endReason := "Observed range touched prior close"
                filledAlert := true
                candidateCount := 0
            else
                bool credible = meanRvol >= minimumParticipation
                float releaseFlow = entryFlow * releaseFraction
                bool keepContinuation = state == 2 and confirmedX >= 0.0 and flow >= releaseFlow and meanRvol >= minimumParticipation * 0.75
                bool keepRepair = state == 3 and confirmedFill >= 0.10 and flow <= -releaseFlow and meanRvol >= minimumParticipation * 0.75
                int desired = keepContinuation ? 2 : keepRepair ? 3 : credible and confirmedX >= 0.20 and flow >= entryFlow ? 2 : credible and confirmedFill >= 0.20 and flow <= -entryFlow ? 3 : 1
                if desired == state
                    candidateCount := 0
                    candidateState := desired
                else
                    candidateCount := desired == candidateState ? candidateCount + 1 : 1
                    candidateState := desired
                    if candidateCount >= confirmationBars
                        state := desired
                        candidateCount := 0
                continuationAlert := state == 2 and oldState != 2
                repairAlert := state == 3 and oldState != 3
            // Count this observed sample before an administrative timeout.
            sampleState := state
            array.set(dwell, sampleState, array.get(dwell, sampleState) + 1)
            array.push(trailX, confirmedX)
            array.push(trailY, confirmedY)
            if array.size(trailX) > trailLength
                array.shift(trailX)
                array.shift(trailY)
            eventSample := true
            if active and age >= eventLimit
                active := false
                state := 5
                endReason := "Event bar limit reached"
                continuationAlert := false
                repairAlert := false
                endedAlert := true
    // Keep the last observed regular close; extended bars do not change this anchor.
    if session.ismarket
        lastRegularClose := validPrice ? close : na

float previewX = na
float previewY = na
if not barstate.isconfirmed and active and session.ismarket and not firstRegular and validData
    float step = direction * (close - previousEventClose)
    float rvol = f_clip(volume / frozenVolume, 0.0, 4.0)
    [liveFlow, liveRvol] = f_path(steps, rvols, step, rvol, efficiencyLength)
    previewX := f_clip(2.0 * direction * (close - anchor) / gapSize - 1.0, -1.0, 1.0)
    previewY := liveFlow

bool drawCore = eventSample or (not barstate.isconfirmed and active and session.ismarket and not firstRegular)
color stateColor = f_stateColor(state)
bool drawLines = drawCore and not firstRegular
pPosition = plot(drawLines ? confirmedX * 100.0 : na, "Gap position: -100 prior close, +100 open", color=stateColor, linewidth=3, style=plot.style_linebr)
pFlow = plot(drawLines ? confirmedY * 100.0 : na, "Participation-adjusted recent path", color=color.new(stateColor, 25), linewidth=1, style=plot.style_linebr)
fill(pPosition, pFlow, color=color.new(stateColor, 82), title="Position-path separation", fillgaps=false)
hline(0, "Half gap / neutral path", color=color.new(chart.fg_color, 70), linestyle=hline.style_dotted)
hline(100, "Opening side", color=color.new(chart.fg_color, 85))
hline(-100, "Prior-close side", color=color.new(chart.fg_color, 85))
plot(eventSample and firstRegular ? confirmedX * 100.0 : na, "First closed gap position", color=stateColor, style=plot.style_circles, linewidth=3)
plot(eventSample and firstRegular ? confirmedY * 100.0 : na, "First closed event path", color=stateColor, style=plot.style_circles, linewidth=1)
float residence = eventSample and age > 0 ? 100.0 * array.get(dwell, sampleState) / age : na
plot(showDwell and eventSample ? -125.0 - residence * 0.35 : na, "Current state residence, lower lane", color=eventSample ? color.new(stateColor, 40) : na, style=plot.style_columns, histbase=-125.0)
plot(showPreview ? previewX * 100.0 : na, "Live gap-position candidate", color=fg, style=plot.style_circles, linewidth=2)
plot(showPreview ? previewY * 100.0 : na, "Live path candidate", color=color.new(fg, 35), style=plot.style_circles, linewidth=1)
plotshape(showMarkers and continuationAlert ? 110.0 : na, "Continuation confirmed", shape.triangleup, location.absolute, continuationColor, size=size.tiny)
plotshape(showMarkers and repairAlert ? -110.0 : na, "Repair confirmed", shape.triangledown, location.absolute, repairColor, size=size.tiny)
plotshape(showMarkers and filledAlert ? -100.0 : na, "Range fill confirmed", shape.diamond, location.absolute, filledColor, size=size.tiny)
bgcolor(showWash and drawCore ? color.new(stateColor, 94) : na)
plot(confirmedFill * 100.0, "Last confirmed close fill %", display=display.data_window)
plot(maximumFill * 100.0, "Last event maximum range fill %", display=display.data_window)
plot(confirmedRvol, "Last confirmed recent capped RVOL", display=display.data_window)
plot(gapAtr, "Last event gap / frozen ATR", display=display.data_window)

var table matrix = table.new(position.top_right, 9, 12, bgcolor=chart.bg_color, frame_color=color.new(chart.fg_color, 65), frame_width=1)
var table summary = table.new(position.bottom_right, 2, 8, bgcolor=chart.bg_color, frame_color=color.new(chart.fg_color, 65), frame_width=1)
if barstate.isfirst
    table.merge_cells(matrix, 0, 0, 8, 0)
    table.merge_cells(matrix, 0, 1, 8, 1)
    table.merge_cells(matrix, 0, 11, 8, 11)
if barstate.islast
    table.clear(matrix, 0, 0, 8, 11)
    table.clear(summary, 0, 0, 1, 7)
    if showMatrix
        table.cell(matrix, 0, 0, "GAP POSITION x RECENT FLOW", text_color=fg, text_size=size.small)
        table.cell(matrix, 0, 1, "REBOUND | RETAIN / PUSH", text_color=fg, text_size=size.tiny)
        for row = 0 to 8
            for col = 0 to 8
                color quadrant = row < 4 ? continuationColor : repairColor
                string mark = row == 4 and col == 4 ? "+" : ""
                table.cell(matrix, col, row + 2, mark, text_color=color.new(fg, 45), bgcolor=col == 4 or row == 4 ? color.new(fg, 94) : color.new(quadrant, col < 4 ? 95 : 91), width=2, height=2, text_size=size.tiny)
        if array.size(trailX) > 0
            for i = 0 to array.size(trailX) - 1
                int col = int(math.round((array.get(trailX, i) + 1.0) * 4.0))
                int row = 2 + int(math.round((1.0 - array.get(trailY, i)) * 4.0))
                bool latest = i == array.size(trailX) - 1
                int fade = latest ? 0 : int(65.0 * (array.size(trailX) - 1 - i) / array.size(trailX))
                table.cell(matrix, col, row, latest ? "@" : ".", text_color=latest ? fg : color.new(fg, fade), bgcolor=latest ? color.new(stateColor, 45) : color.new(fg, 92), width=2, height=2, text_size=size.tiny)
        table.cell(matrix, 0, 11, "DEEP / REPAIR | RETAIN / ERODE", text_color=fg, text_size=size.tiny)
    if showSummary
        table.cell(summary, 0, 0, "CONFIRMED EVENT", text_color=fg, text_size=size.small)
        table.cell(summary, 1, 0, firstRegular and not barstate.isconfirmed ? "FIRST CLOSE PENDING" : f_stateName(state), text_color=stateColor, text_size=size.small)
        table.cell(summary, 0, 1, "Gap side / ATR", text_color=fg, text_size=size.tiny)
        table.cell(summary, 1, 1, age > 0 ? (direction == 1 ? "UP / " : "DOWN / ") + str.tostring(gapAtr, "#.00") : "n/a", text_color=fg, text_size=size.tiny)
        table.cell(summary, 0, 2, "Close / range fill", text_color=fg, text_size=size.tiny)
        table.cell(summary, 1, 2, age > 0 ? str.tostring(confirmedFill * 100.0, "#") + "% / " + str.tostring(maximumFill * 100.0, "#") + "%" : "n/a", text_color=fg, text_size=size.tiny)
        table.cell(summary, 0, 3, "Recent capped RVOL", text_color=fg, text_size=size.tiny)
        table.cell(summary, 1, 3, str.tostring(confirmedRvol, "#.00"), text_color=fg, text_size=size.tiny)
        table.cell(summary, 0, 4, "Stall / continue / repair", text_color=fg, text_size=size.tiny)
        table.cell(summary, 1, 4, str.tostring(array.get(dwell, 1)) + " / " + str.tostring(array.get(dwell, 2)) + " / " + str.tostring(array.get(dwell, 3)), text_color=fg, text_size=size.tiny)
        table.cell(summary, 0, 5, "Bars / range-fill bars", text_color=fg, text_size=size.tiny)
        table.cell(summary, 1, 5, str.tostring(age) + " / " + str.tostring(array.get(dwell, 4)), text_color=fg, text_size=size.tiny)
        table.cell(summary, 0, 6, "Termination / setup", text_color=fg, text_size=size.tiny)
        table.cell(summary, 1, 6, endReason, text_color=fg, text_size=size.tiny)
        table.cell(summary, 0, 7, "Matrix: closed trail", text_color=fg, text_size=size.tiny)
        table.cell(summary, 1, 7, "Left=fill; up=gap flow", text_color=fg, text_size=size.tiny)

alertcondition(continuationAlert, "Gap continuation confirmed", "Gap continuation state confirmed at bar close.")
alertcondition(repairAlert, "Gap repair confirmed", "Orderly gap repair state confirmed at bar close.")
alertcondition(filledAlert, "Gap range fill confirmed", "Observed regular bar range reached the prior regular close; this is not close acceptance.")
alertcondition(endedAlert, "Gap event ended", "Gap event ended at its bar limit or after leaving the regular session.")
alertcondition(invalidAlert, "Gap event data interrupted", "Active gap event terminated because price or positive volume was unavailable.")
````
