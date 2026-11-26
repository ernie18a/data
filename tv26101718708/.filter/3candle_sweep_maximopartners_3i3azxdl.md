# 3-Candle Sweep [MaximoPartners]

- url: https://www.tradingview.com/script/3i3AzXdL-3-Candle-Sweep-MaximoPartners/
- type: indicator
- pine_id: PUB;c5284ffcddaa4680a8d8bdfa9e4438e0
- version: 1.0

## Description

3-Candle Sweep displays candles from up to three selected timeframes alongside your chart and identifies a defined three-candle sweep pattern. It combines timeframe context, entry thresholds, and risk/reward drawings in one overlay.

[b]How the setup works[/b]

The pattern uses three consecutive candles from each selected timeframe:

[list=1]
[*]Reference candle: establishes the high and low.
[*]Sweep candle: moves beyond one side of the reference range, then closes strictly inside that range.
[*]Entry candle: the current candle, monitored for a break of the sweep candle's opposite extreme.
[/list]

A candle that sweeps both the reference high and low is ignored. Exact touches do not qualify as sweeps or entry breaks.

[list]
[*]Bullish setup: the sweep candle trades below the reference low and closes back inside the reference range. Entry is at the sweep candle's high.
[*]Bearish setup: the sweep candle trades above the reference high and closes back inside the reference range. Entry is at the sweep candle's low.
[/list]

[b]Ready setups and B/S labels[/b]

Once the sweep candle closes, the indicator highlights the entry threshold with a green or red line. This setup is visible before the current candle crosses entry.

[list]
[*]A green B appears while the current price is above a valid bullish entry threshold.
[*]A red S appears while the current price is below a valid bearish entry threshold.
[/list]

These labels update with the developing candle. They can disappear if price returns across the threshold; they are not permanent trade confirmations.

[b]Entry, stop-loss and take-profit levels[/b]

On chart timeframes smaller than an enabled projection timeframe, the indicator can draw a setup zone at actual chart prices:

[list]
[*]Entry: sweep candle high for buys, or low for sells.
[*]TP: reference candle high for buys, or low for sells.
[*]SL: calculated from entry and TP using the selected 1:1, 1:3 or 1:5 risk-to-reward ratio.
[/list]

Entry and TP remain fixed when the ratio changes. A higher ratio reduces the initial stop distance. Stops are rounded to the instrument's tick size, so the actual ratio may differ slightly from the selected ratio.

If TP is not beyond entry in the intended direction, the indicator displays the entry threshold without a risk/reward zone. Setup zones span the entry candle.

[b]Display and customization[/b]

[list]
[*]Three independently selectable timeframes, each with a visibility toggle.
[*]Two to ten displayed candles per timeframe; default is three.
[*]Candle-close countdowns, updated as new chart data arrives.
[*]Optional B/S labels, ready setups and historical setups.
[*]Custom bullish and bearish candle colors.
[*]Adjustable position, overall size, candle height and spacing.
[/list]

[b]How to use[/b]

[list=1]
[*]Select and enable your analysis timeframes under "Timeframe Candles."
[*]To view their entry/SL/TP zones, use a smaller chart timeframe. For example, use a 1-minute chart with 5-minute and 15-minute analysis candles.
[*]Choose a risk-to-reward ratio under "Setup Levels."
[*]Enable historical setups if you want to review previously crossed entry thresholds.
[*]Customize colors and layout under "Appearance."
[/list]

[b]Live behavior and limitations[/b]

Developing candles and signals change as prices update. Historical and replay detail depends on the chart timeframe and available data, particularly when viewing a projection timeframe smaller than the chart timeframe.

This is a visual analysis indicator. It does not place orders, backtest trades, or guarantee outcomes.

## Source Code

````pine
//@version=6
indicator("3-Candle Sweep [MaximoPartners]", overlay = true,
     max_lines_count = 300, max_boxes_count = 160, max_labels_count = 200)

bool showProjection1 = input.bool(true, "Show 1", inline = "p1", group = "Timeframe Candles")
string projectionTf1 = input.timeframe("5", "Timeframe", inline = "p1", group = "Timeframe Candles")
bool showProjection2 = input.bool(true, "Show 2", inline = "p2", group = "Timeframe Candles")
string projectionTf2 = input.timeframe("60", "Timeframe", inline = "p2", group = "Timeframe Candles")
bool showProjection3 = input.bool(false, "Show 3", inline = "p3", group = "Timeframe Candles")
string projectionTf3 = input.timeframe("240", "Timeframe", inline = "p3", group = "Timeframe Candles")

int candleCount = input.int(3, "Number of candles", minval = 2, maxval = 10, tooltip = "Candles per timeframe, including the current live candle. 3 = two completed plus current. The live candle never hides earlier high/low lines.", group = "Timeframe Candles")

bool showSignals = input.bool(true, "Show B/S signals", group = "Timeframe Candles", tooltip = "Show green B and red S labels when the sweep and current-price conditions are met.")

bool showSetups = input.bool(true, "Show ready setups", group = "Timeframe Candles", tooltip = "Show entry thresholds on the timeframe candles and entry/SL/TP zones on smaller chart timeframes. SL uses the risk-to-reward ratio selected under Setup Levels. Zones last for the current setup candle.")
bool showSetupHistory = input.bool(false, "Show historical setups", group = "Timeframe Candles", tooltip = "Keep the latest 19 entered setups per enabled projection, plus its current ready setup, on smaller chart timeframes. Entry requires a strict break of the sweep high/low during the setup candle; these are price-triggered setup drawings, not executed trades. History does not imply a winning trade.")

string rewardChoice = input.string("1:3", "Risk : reward", options = ["1:1", "1:3", "1:5"], group = "Setup Levels", tooltip = "Reward relative to initial risk. Entry and final TP stay fixed; a higher ratio tightens the initial SL. Stops are rounded to tick size, so the actual ratio can differ slightly.")
float rewardMultiple = str.tonumber(str.replace_all(rewardChoice, "1:", ""))


color bullishCandleColor = input.color(color.rgb(84, 166, 135), "Bullish candle", inline = "candleColors", group = "Appearance")
color bearishCandleColor = input.color(color.rgb(215, 100, 100), "Bearish candle", inline = "candleColors", group = "Appearance")

int horizontalPosition = input.int(9, "Horizontal position (bars)", minval = -200, maxval = 400, tooltip = "Offset from the latest chart candle. Increase to move right; decrease to move left. Default: 9 bars.", group = "Appearance")
float verticalPosition = input.float(0.0, "Vertical position", step = 0.25, tooltip = "Positive moves all candle groups up; negative moves them down. Units are the unscaled group height.", group = "Appearance")
float projectionSize = input.float(1.0, "Overall size", minval = 0.5, maxval = 3.0, step = 0.1, tooltip = "1 is the default. Larger values increase candle height, width and spacing.", group = "Appearance")

float projectionHeight = input.float(1.0, "Candle height", minval = 0.25, maxval = 4.0, step = 0.1, tooltip = "Adjust height independently of candle width and label size. 1 = normal, 0.5 = half height, 2 = double height. Applies on top of Overall size.", group = "Appearance")

int candleGap = input.int(1, "Gap between candles (bars)", minval = 0, maxval = 10, tooltip = "Space between candle bodies. 0 = touching, 1 = compact spacing. Does not change candle width or height.", group = "Appearance")

// Chart timeframe is used only to choose a safe data source, never to hide rows.
simple int chartSeconds = int(timeframe.in_seconds())

// Scalar fields keep both request paths below Pine's tuple-element limit.
type ProjectionSnapshot
    float o9
    float h9
    float l9
    float c9
    float o8
    float h8
    float l8
    float c8
    float o7
    float h7
    float l7
    float c7
    float o6
    float h6
    float l6
    float c6
    float o5
    float h5
    float l5
    float c5
    float o4
    float h4
    float l4
    float c4
    float o3
    float h3
    float l3
    float c3
    float o2
    float h2
    float l2
    float c2
    float o1
    float h1
    float l1
    float c1
    float o0
    float h0
    float l0
    float c0
    int closesAt

// The caller passes a literal offset. No chart-timeframe condition is
// re-evaluated inside the requested timeframe's context.
projectionSnapshot(simple int offset) =>
    ProjectionSnapshot.new(
         open[9 + offset], high[9 + offset], low[9 + offset], close[9 + offset], open[8 + offset], high[8 + offset], low[8 + offset], close[8 + offset], open[7 + offset], high[7 + offset], low[7 + offset], close[7 + offset], open[6 + offset], high[6 + offset], low[6 + offset], close[6 + offset], open[5 + offset], high[5 + offset], low[5 + offset], close[5 + offset], open[4 + offset], high[4 + offset], low[4 + offset], close[4 + offset], open[3 + offset], high[3 + offset], low[3 + offset], close[3 + offset], open[2 + offset], high[2 + offset], low[2 + offset], close[2 + offset], open[1 + offset], high[1 + offset], low[1 + offset], close[1 + offset], open[0 + offset], high[0 + offset], low[0 + offset], close[0 + offset], time_close)

projectionData(simple string tf) =>
    simple int targetSeconds = int(timeframe.in_seconds(tf))
    simple bool canAggregate = not na(chartSeconds) and chartSeconds < targetSeconds and targetSeconds % chartSeconds == 0
    ProjectionSnapshot snapshot = na
    if canAggregate
        // Completed history only: the newest requested candle is always [1].
        snapshot := request.security(syminfo.tickerid, tf, projectionSnapshot(1), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
    else
        // Native snapshot already includes the latest candle; do not append it.
        snapshot := request.security(syminfo.tickerid, tf, projectionSnapshot(0), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    // Requested data can be unavailable on initial bars or outside intrabar coverage.
    // An empty snapshot keeps all price fields na without dereferencing an na object.
    if na(snapshot)
        snapshot := ProjectionSnapshot.new()
    array<float> data = array.from(snapshot.o9, snapshot.h9, snapshot.l9, snapshot.c9, snapshot.o8, snapshot.h8, snapshot.l8, snapshot.c8, snapshot.o7, snapshot.h7, snapshot.l7, snapshot.c7, snapshot.o6, snapshot.h6, snapshot.l6, snapshot.c6, snapshot.o5, snapshot.h5, snapshot.l5, snapshot.c5, snapshot.o4, snapshot.h4, snapshot.l4, snapshot.c4, snapshot.o3, snapshot.h3, snapshot.l3, snapshot.c3, snapshot.o2, snapshot.h2, snapshot.l2, snapshot.c2, snapshot.o1, snapshot.h1, snapshot.l1, snapshot.c1, snapshot.o0, snapshot.h0, snapshot.l0, snapshot.c0)
    var float currentOpen = na
    var float currentHigh = na
    var float currentLow = na
    bool newCandle = timeframe.change(tf)
    if newCandle or na(currentOpen)
        currentOpen := open
        currentHigh := high
        currentLow := low
    else
        currentHigh := math.max(currentHigh, high)
        currentLow := math.min(currentLow, low)
    if canAggregate
        // Drop the oldest completed candle and append the developing candle.
        for n = 0 to 3
            array.shift(data)
        array.push(data, currentOpen)
        array.push(data, currentHigh)
        array.push(data, currentLow)
        array.push(data, close)
    array.push(data, float(canAggregate ? time_close(tf) : snapshot.closesAt))
    data

// Separate calls preserve independent aggregation state for each slot.
array<float> data1 = projectionData(projectionTf1)
array<float> data2 = projectionData(projectionTf2)
array<float> data3 = projectionData(projectionTf3)

projectionEnabled(int row) =>
    row == 0 ? showProjection1 : row == 1 ? showProjection2 : showProjection3

projectionName(string tf) =>
    float minutes = str.tonumber(tf)
    na(minutes) ? tf : minutes >= 60 and minutes % 60 == 0 ? str.tostring(int(minutes / 60)) + "h" : str.tostring(int(minutes)) + "m"

// Signals always use actual OHLC prices, independently of display scaling/count.
// The last completed candle must sweep the preceding candle and close strictly
// inside its range. The current price must remain beyond the opposite
// sweep-candle extreme. A past wick break alone does not keep a signal active.
// Equality alone is not a sweep or a break.
projectionSignals(array<float> data) =>
    float previousHigh = array.get(data, 29)
    float previousLow = array.get(data, 30)
    float sweepHigh = array.get(data, 33)
    float sweepLow = array.get(data, 34)
    float sweepClose = array.get(data, 35)
    float livePrice = array.get(data, 39)
    bool closesInside = sweepClose > previousLow and sweepClose < previousHigh
    bool buy = closesInside and sweepLow < previousLow and sweepHigh <= previousHigh and livePrice > sweepHigh
    bool sell = closesInside and sweepHigh > previousHigh and sweepLow >= previousLow and livePrice < sweepLow
    [buy, sell]

projectionCountdown(int closesAt) =>
    // Historical/replay bars use chart time instead of today's wall clock.
    int referenceTime = barstate.isrealtime ? timenow : time_close
    int secondsLeft = na(closesAt) or na(referenceTime) ? 0 : int(math.max(0, math.ceil((closesAt - referenceTime) / 1000.0)))
    int hoursLeft = int(secondsLeft / 3600)
    int minutesLeft = int((secondsLeft % 3600) / 60)
    int remainingSeconds = secondsLeft % 60
    string clockText = str.tostring(minutesLeft, "00") + ":" + str.tostring(remainingSeconds, "00")
    hoursLeft > 0 ? str.tostring(hoursLeft, "00") + ":" + clockText : clockText

// A setup is ready once the sweep candle closes, independently of live price.
setupReady(float refHigh, float refLow, float sweepHigh, float sweepLow, float sweepClose) =>
    bool inside = sweepClose > refLow and sweepClose < refHigh
    bool sweptLow = sweepLow < refLow
    bool sweptHigh = sweepHigh > refHigh
    [inside and sweptLow and not sweptHigh, inside and sweptHigh and not sweptLow]

type SetupDrawing
    bool isBuy = false
    box reward
    box risk
    line entryLine
    line stopLine
    line targetLine
    label entryLabel
    label stopLabel
    label targetLabel

removeSetup(SetupDrawing drawing) =>
    box.delete(drawing.reward)
    box.delete(drawing.risk)
    line.delete(drawing.entryLine)
    line.delete(drawing.stopLine)
    line.delete(drawing.targetLine)
    label.delete(drawing.entryLabel)
    label.delete(drawing.stopLabel)
    label.delete(drawing.targetLabel)

newSetup(int startsAt, int endsAt, float entry, float target, bool isBuy, string name) =>
    SetupDrawing drawing = SetupDrawing.new()
    drawing.isBuy := isBuy
    color directionColor = isBuy ? color.green : color.red
    bool validTarget = isBuy ? target > entry : target < entry
    drawing.entryLine := line.new(startsAt, entry, endsAt, entry, xloc = xloc.bar_time, color = directionColor, width = 2)
    string prefix = name + (isBuy ? " BUY" : " SELL")
    drawing.entryLabel := label.new(endsAt, entry, prefix + " Entry " + str.tostring(entry, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = directionColor, textcolor = color.white, size = size.tiny)
    if validTarget
        // Fixed reference target and entry determine the selected risk-to-reward stop.
        // Round stops to tradable ticks; the realized ratio can differ slightly.
        float stop = math.round_to_mintick(entry - (target - entry) / rewardMultiple)
        drawing.reward := box.new(startsAt, math.max(entry, target), endsAt, math.min(entry, target), xloc = xloc.bar_time, border_color = color.new(color.green, 70), bgcolor = color.new(color.green, 85))
        drawing.risk := box.new(startsAt, math.max(entry, stop), endsAt, math.min(entry, stop), xloc = xloc.bar_time, border_color = color.new(color.red, 70), bgcolor = color.new(color.red, 85))
        drawing.stopLine := line.new(startsAt, stop, endsAt, stop, xloc = xloc.bar_time, color = color.red, style = line.style_dashed)
        drawing.targetLine := line.new(startsAt, target, endsAt, target, xloc = xloc.bar_time, color = color.green, style = line.style_dashed)
        drawing.stopLabel := label.new(endsAt, stop, name + " SL " + str.tostring(stop, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.red, textcolor = color.white, size = size.tiny)
        drawing.targetLabel := label.new(endsAt, target, name + " TP " + str.tostring(target, format.mintick) + " (" + rewardChoice + ")", xloc = xloc.bar_time, style = label.style_label_left, color = color.green, textcolor = color.white, size = size.tiny)
    else
        label.set_tooltip(drawing.entryLabel, "Sweep setup ready, but the reference candle target is not beyond entry in the trade direction. No valid risk/reward zone is drawn.")
    drawing

// Current setups are previews. Only an entry during their own candle earns
// a place in history. Confirmed source OHLC prevents chart-bar boundary leakage.
chartSetups(simple string tf, simple bool enabled) =>
    var array<SetupDrawing> history = array.new<SetupDrawing>()
    var SetupDrawing active = na
    var int lastPeriod = na
    if enabled and showSetups and not na(chartSeconds) and chartSeconds < timeframe.in_seconds(tf)
        [periodStart, periodEnd, previousStart, refHigh, refLow, sweepHigh, sweepLow, sweepClose] = request.security(syminfo.tickerid, tf, [time, time_close, time[1], high[2], low[2], high[1], low[1], close[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
        if not na(periodStart) and (na(lastPeriod) or periodStart != lastPeriod)
            if not na(active)
                float previousEntry = line.get_y1(active.entryLine)
                // Here [1] is the just-finished setup candle, not its sweep candle.
                bool touched = active.isBuy ? sweepHigh > previousEntry : sweepLow < previousEntry
                bool entered = previousStart == lastPeriod and touched
                if showSetupHistory and entered
                    array.push(history, active)
                else
                    removeSetup(active)
                active := na
            while array.size(history) > 19
                removeSetup(array.shift(history))
            [buyReady, sellReady] = setupReady(refHigh, refLow, sweepHigh, sweepLow, sweepClose)
            if not na(periodEnd)
                if buyReady
                    active := newSetup(periodStart, periodEnd, sweepHigh, refHigh, true, projectionName(tf))
                else if sellReady
                    active := newSetup(periodStart, periodEnd, sweepLow, refLow, false, projectionName(tf))
            lastPeriod := periodStart
    0

chartSetups(projectionTf1, showProjection1)
chartSetups(projectionTf2, showProjection2)
chartSetups(projectionTf3, showProjection3)

// Pre-create projection objects once and update their coordinates on the last
// chart bar, following the pasted script's persistent-box/persistent-wick method.
miniCandleData(int offset, int row) =>
    array<float> data = row == 0 ? data1 : row == 1 ? data2 : data3
    int i = (10 - candleCount + offset) * 4
    [array.get(data, i), array.get(data, i + 1), array.get(data, i + 2), array.get(data, i + 3)]

// Stateful sizing calculations must run on EVERY bar, before last-bar rendering.
float projectionAtr = ta.atr(14)
float projectionHigh = ta.highest(high, 60)
float projectionLow = ta.lowest(low, 60)

var array<box> miniBodies = array.new<box>()
var array<line> miniWicks = array.new<line>()
var array<line> miniRanges = array.new<line>()
var array<line> miniEntries = array.new<line>()
var array<label> miniHeaders = array.new<label>()
var array<label> miniSignals = array.new<label>()
if barstate.isfirst
    for n = 0 to candleCount * 3 - 1
        array.push(miniBodies, box.new(na, na, na, na, xloc = xloc.bar_index))
        array.push(miniWicks, line.new(na, na, na, na, xloc = xloc.bar_index))
    for n = 0 to (candleCount - 1) * 6 - 1
        array.push(miniRanges, line.new(na, na, na, na, xloc = xloc.bar_index, color = color.gray, style = line.style_dashed))
    for row = 0 to 2
        array.push(miniHeaders, label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 70), textcolor = color.white, size = size.small))

    for n = 0 to 5
        array.push(miniEntries, line.new(na, na, na, na, xloc = xloc.bar_index, width = 2))
        array.push(miniSignals, label.new(na, na, "", xloc = xloc.bar_index, style = label.style_label_up, textcolor = color.white, size = size.small))

if barstate.islast
    // Clear every slot before rendering so disabled projections leave no objects.
    for body in miniBodies
        box.set_left(body, na)
        box.set_right(body, na)
    for wick in miniWicks
        line.set_xy1(wick, na, na)
        line.set_xy2(wick, na, na)
    for level in miniRanges
        line.set_xy1(level, na, na)
        line.set_xy2(level, na, na)
    for entry in miniEntries
        line.set_xy1(entry, na, na)
        line.set_xy2(entry, na, na)
    for header in miniHeaders
        label.set_xy(header, na, na)
    for signal in miniSignals
        label.set_xy(signal, na, na)
    int visibleCount = (showProjection1 ? 1 : 0) + (showProjection2 ? 1 : 0) + (showProjection3 ? 1 : 0)
    int visibleRow = 0
    // Stack enabled slots around the midpoint without gaps for hidden slots.
    float baseHeight = math.max(math.max(nz(projectionAtr, high - low) * 1.5, (projectionHigh - projectionLow) * 0.11), syminfo.mintick * 30)
    float bandHeight = baseHeight * projectionSize * projectionHeight
    // Even bar widths give every body an exact integer midpoint.
    int candleWidth = 2 * math.max(1, int(math.round(projectionSize)))
    int candleSpacing = candleWidth + candleGap
    float projectionCenter = (projectionHigh + projectionLow) * 0.5 + verticalPosition * baseHeight
    for row = 0 to 2
        if not projectionEnabled(row)
            continue
        array<float> rowData = row == 0 ? data1 : row == 1 ? data2 : data3
        int groupWidth = (candleCount - 1) * candleSpacing + candleWidth
        int safeOffset = math.min(horizontalPosition, 498 - groupWidth)
        int firstX = math.max(0, bar_index + safeOffset)
        int lastX = firstX + groupWidth
        float groupHigh = na
        float groupLow = na
        for n = 0 to candleCount - 1
            [o, h, l, c] = miniCandleData(n, row)
            if not na(h) and not na(l)
                groupHigh := na(groupHigh) ? h : math.max(groupHigh, h)
                groupLow := na(groupLow) ? l : math.min(groupLow, l)
        float sourceRange = math.max(groupHigh - groupLow, syminfo.mintick)
        float center = projectionCenter + ((visibleCount - 1) * 0.5 - visibleRow) * bandHeight * 1.45
        visibleRow += 1
        string tfName = projectionName(row == 0 ? projectionTf1 : row == 1 ? projectionTf2 : projectionTf3)
        label header = array.get(miniHeaders, row)
        label.set_xy(header, lastX + 2, center)
        int projectionEnd = int(array.get(rowData, 40))
        label.set_text(header, tfName + "\n" + projectionCountdown(projectionEnd))
        label.set_color(header, color.rgb(65, 105, 150))
        label.set_textcolor(header, color.white)
        label.set_size(header, projectionSize < 0.8 ? size.tiny : projectionSize <= 1.2 ? size.small : projectionSize <= 2.0 ? size.normal : size.large)
        label.set_tooltip(header, "Last candle: current. Levels hide only when a later completed candle body touches them; wicks do not count. The live candle never hides any levels. Each row uses its own visual scale.")

        // Highlight the sweep candle's entry extreme before any live-price break.
        [buyReady, sellReady] = setupReady(array.get(rowData, 29), array.get(rowData, 30), array.get(rowData, 33), array.get(rowData, 34), array.get(rowData, 35))
        for direction = 0 to 1
            bool isBuy = direction == 0
            bool ready = isBuy ? buyReady : sellReady
            if showSetups and ready
                float entryPrice = array.get(rowData, isBuy ? 33 : 34)
                float entryY = center - bandHeight * 0.5 + (entryPrice - groupLow) / sourceRange * bandHeight
                int sweepX = firstX + (candleCount - 2) * candleSpacing + int(candleWidth / 2)
                line entry = array.get(miniEntries, row * 2 + direction)
                line.set_xy1(entry, sweepX, entryY)
                line.set_xy2(entry, lastX, entryY)
                line.set_color(entry, isBuy ? color.green : color.red)

        // Update signal visibility on every tick using the current price.
        [buySignal, sellSignal] = projectionSignals(rowData)
        for direction = 0 to 1
            bool isBuy = direction == 0
            bool triggered = showSignals and (isBuy ? buySignal : sellSignal)
            label signal = array.get(miniSignals, row * 2 + direction)
            label.set_xy(signal, na, na)
            if triggered
                [liveOpen, liveHigh, liveLow, liveClose] = miniCandleData(candleCount - 1, row)
                float bandLow = center - bandHeight * 0.5
                float signalY = bandLow + ((isBuy ? liveLow : liveHigh) - groupLow) / sourceRange * bandHeight
                int signalX = firstX + (candleCount - 1) * candleSpacing + int(candleWidth / 2)
                label.set_xy(signal, signalX, signalY)
                label.set_text(signal, isBuy ? "B" : "S")
                label.set_style(signal, isBuy ? label.style_label_up : label.style_label_down)
                label.set_color(signal, isBuy ? color.green : color.red)
                label.set_textcolor(signal, color.white)
                label.set_tooltip(signal, isBuy ? "Previous candle swept the preceding low and closed inside its range. Current price is above the sweep candle high." : "Previous candle swept the preceding high and closed inside its range. Current price is below the sweep candle low.")

        for candle = 0 to candleCount - 1
            int objectIndex = row * candleCount + candle
            box body = array.get(miniBodies, objectIndex)
            line wick = array.get(miniWicks, objectIndex)
            [sourceOpen, sourceHigh, sourceLow, sourceClose] = miniCandleData(candle, row)
            if not na(sourceOpen) and not na(sourceHigh) and not na(sourceLow) and not na(sourceClose)
                float bandLow = center - bandHeight * 0.5
                float yHigh = bandLow + (sourceHigh - groupLow) / sourceRange * bandHeight
                float yLow = bandLow + (sourceLow - groupLow) / sourceRange * bandHeight
                float yOpen = bandLow + (sourceOpen - groupLow) / sourceRange * bandHeight
                float yClose = bandLow + (sourceClose - groupLow) / sourceRange * bandHeight
                float bodyTop = math.max(yOpen, yClose)
                float bodyBottom = math.min(yOpen, yClose)
                color candleColor = sourceClose >= sourceOpen ? bullishCandleColor : bearishCandleColor
                int leftX = firstX + candle * candleSpacing
                int wickX = leftX + int(candleWidth / 2)
                box.set_left(body, leftX)
                box.set_right(body, leftX + candleWidth)
                box.set_top(body, bodyTop)
                box.set_bottom(body, bodyBottom)
                box.set_bgcolor(body, candleColor)
                box.set_border_color(body, candleColor)
                line.set_xy1(wick, wickX, yHigh)
                line.set_xy2(wick, wickX, yLow)
                line.set_color(wick, candleColor)
                if candle < candleCount - 1
                    line highRange = array.get(miniRanges, row * (candleCount - 1) * 2 + candle * 2)
                    line lowRange = array.get(miniRanges, row * (candleCount - 1) * 2 + candle * 2 + 1)
                    // Ignore the source candle: its own wick defines the level.
                    // Inclusive comparisons count an exact body-edge touch; wicks do not count.
                    bool highTouched = false
                    bool lowTouched = false
                    // Only later completed candles can hide a level; exclude the live candle for every source.
                    if candle < candleCount - 2
                        for later = candle + 1 to candleCount - 2
                            [laterOpen, laterHigh, laterLow, laterClose] = miniCandleData(later, row)
                            if not na(laterOpen) and not na(laterClose)
                                float laterBodyLow = math.min(laterOpen, laterClose)
                                float laterBodyHigh = math.max(laterOpen, laterClose)
                                highTouched := highTouched or (sourceHigh >= laterBodyLow and sourceHigh <= laterBodyHigh)
                                lowTouched := lowTouched or (sourceLow >= laterBodyLow and sourceLow <= laterBodyHigh)
                    line.set_xy1(highRange, highTouched ? na : wickX, highTouched ? na : yHigh)
                    line.set_xy2(highRange, highTouched ? na : lastX, highTouched ? na : yHigh)
                    line.set_xy1(lowRange, lowTouched ? na : wickX, lowTouched ? na : yLow)
                    line.set_xy2(lowRange, lowTouched ? na : lastX, lowTouched ? na : yLow)
                    line.set_color(highRange, color.new(candleColor, 25))
                    line.set_color(lowRange, color.new(candleColor, 25))
            else
                box.set_left(body, na)
                box.set_right(body, na)
                line.set_xy1(wick, na, na)
                line.set_xy2(wick, na, na)
                if candle < candleCount - 1
                    line.set_xy1(array.get(miniRanges, row * (candleCount - 1) * 2 + candle * 2), na, na)
                    line.set_xy2(array.get(miniRanges, row * (candleCount - 1) * 2 + candle * 2), na, na)
                    line.set_xy1(array.get(miniRanges, row * (candleCount - 1) * 2 + candle * 2 + 1), na, na)
                    line.set_xy2(array.get(miniRanges, row * (candleCount - 1) * 2 + candle * 2 + 1), na, na)
````
