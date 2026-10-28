# Elliott Wave Oscillator Divergence | XoRonX

- url: https://www.tradingview.com/script/VNcXOjcT/
- type: indicator
- pine_id: PUB;45e26833b11943d1a7e51d83e9c3b205
- version: 1.0

## Description

Elliott Wave Oscillator Divergence Divergence identifies regular and hidden divergences using dominant Elliott Wave Oscillator swings and price wick extremes.

The indicator focuses on the main peak or trough of each EWO wave. Smaller fluctuations within the same wave are grouped together to create a cleaner view of momentum divergence.

[b]Key Features[/b]

- Regular bullish and bearish divergence.
- Hidden bullish and bearish divergence.
- Dominant EWO anchors that remain valid until a more extreme oscillator swing occurs.
- Price comparisons based on wick highs and lows.
- Optional filtering to retain one largest divergence per anchor and divergence type.
- Divergence lines, arrows, and labels displayed in the oscillator panel.
- Multi-timeframe scanning with a customizable list, such as `M5,M15,H1,H4,D1`.
- Support for up to 10 unique scanning timeframes.
- A scanner table showing the latest detected divergence and pivot time for each timeframe.
- Dynamic alerts containing the symbol, timeframe, divergence type, and pivot time.

[b]Oscillator Settings[/b]

The default EWO calculation is:

`SMA(hl2, 5) − SMA(hl2, 35)`

MA periods, price source, calculation method, and oscillator smoothing can be customized.

[b]Signal Confirmation[/b]

A divergence is confirmed after its EWO wave reaches or crosses the zero line and the minimum number of candles after the oscillator extreme has closed. The default minimum is five candles.

Once confirmed, the divergence is drawn at its earlier pivot locations. Historical markers therefore show the pivot positions, rather than the moment the signal became available. With the largest-divergence filter enabled, a stronger confirmed pair may replace an earlier displayed line.

[b]Alert Setup[/b]

Create a TradingView alert, select this indicator, and choose “Any alert() function call.” Enable “Notify on app” for mobile notifications.

Historical signals do not trigger notifications when the alert starts. Recreate your alert after changing indicator settings or the scanning timeframe list.

## Source Code

````pine
//@version=6
// Elliott Wave Oscillator Divergence .
// Modify By : XoRonX
// Lines are backplotted to confirmed pivots. A stronger pair may replace an older display line.
indicator("Elliott Wave Oscillator Divergence | XoRonX", "EWO Div | XoRonX", overlay=false, max_bars_back=5000, max_lines_count=500, max_labels_count=500, dynamic_requests=true)

string G_EWO = "EWO"
int fastPeriod = input.int(5, "Fast MA", minval=1, maxval=500, group=G_EWO)
int slowPeriod = input.int(35, "Slow MA", minval=1, maxval=500, group=G_EWO)
float priceSource = input.source(hl2, "Price source", group=G_EWO)
string maMethod = input.string("SMA", "MA method", options=["SMA", "EMA", "WMA", "SMMA"], group=G_EWO)
bool showMA = input.bool(true, "Show EWO smoothing MA", group=G_EWO)
int signalPeriod = input.int(5, "EWO smoothing period", minval=1, maxval=500, group=G_EWO)
string signalMethod = input.string("SMA", "EWO smoothing method", options=["SMA", "EMA", "WMA", "SMMA"], group=G_EWO)

string G_DIV = "Dominant EWO Swings"
bool regularOn = input.bool(true, "Regular divergence", group=G_DIV)
bool hiddenOn = input.bool(true, "Hidden divergence", group=G_DIV)
int confirmRight = input.int(5, "Min closed candles after EWO extreme", minval=1, maxval=100, group=G_DIV)
int minDistance = input.int(5, "Min bars between EWO pivots", minval=1, maxval=2000, group=G_DIV)
int maxDistance = input.int(500, "Max bars between EWO pivots", minval=5, maxval=2000, group=G_DIV)
bool majorOnly = input.bool(true, "Use strong lobes as anchors", group=G_DIV)
int strengthLookback = input.int(150, "Anchor strength lookback", minval=10, maxval=2000, group=G_DIV)
float minHeight = input.float(0.50, "Min anchor height / recent same-side amplitude", minval=0.0, maxval=1.0, step=0.05, group=G_DIV)
float minSwing = input.float(0.20, "Minimum anchor strength", minval=0.0, maxval=1.0, step=0.05, group=G_DIV)
bool keepLargest = input.bool(true, "Keep one largest divergence per anchor/type", group=G_DIV)

string G_VIEW = "Display"
bool drawLines = input.bool(true, "Draw divergence lines in EWO panel", group=G_VIEW)
bool showLabels = input.bool(true, "Show divergence labels", group=G_VIEW)
bool showArrows = input.bool(true, "Show pivot arrows", group=G_VIEW)
int historyBars = input.int(1500, "Display history bars", minval=50, maxval=5000, group=G_VIEW)
int maxDraw = input.int(100, "Max displayed divergences", minval=1, maxval=200, group=G_VIEW)
int strokeWidth = input.int(2, "Regular divergence line width", minval=1, maxval=5, group=G_VIEW)
color regularBullColor = input.color(color.lime, "Regular bullish", group=G_VIEW)
color regularBearColor = input.color(color.rgb(255, 99, 71), "Regular bearish", group=G_VIEW)
color hiddenBullColor = input.color(color.aqua, "Hidden bullish", group=G_VIEW)
color hiddenBearColor = input.color(color.orange, "Hidden bearish", group=G_VIEW)

string G_SCAN = "Multi-Timeframe Scanner"
bool scannerOn = input.bool(true, "Enable scanner", group=G_SCAN)
string timeframeList = input.string("M5,M15,H1,H4,D1", "Timeframes (max 10, comma-separated)", group=G_SCAN)
bool showScanner = input.bool(true, "Show scanner table", group=G_SCAN)
bool alertRegular = input.bool(true, "Notify regular divergence", group=G_SCAN)
bool alertHidden = input.bool(true, "Notify hidden divergence", group=G_SCAN)

fMA(float src, int length, string averageKind) =>
    switch averageKind
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        "SMMA" => ta.rma(src, length)
        => ta.sma(src, length)

fName(int kind) =>
    switch kind
        1 => "RBull"
        2 => "RBear"
        3 => "HBull"
        4 => "HBear"
        => "-"

fColor(int kind) =>
    switch kind
        1 => regularBullColor
        2 => regularBearColor
        3 => hiddenBullColor
        => hiddenBearColor

fKind(int side, float oldPrice, float newPrice, float oldOsc, float newOsc) =>
    int kind = 0
    if side < 0
        if regularOn and newPrice < oldPrice and newOsc >= oldOsc
            kind := 1
        else if hiddenOn and newPrice > oldPrice and newOsc < oldOsc
            kind := 3
    else
        if regularOn and newPrice > oldPrice and newOsc <= oldOsc
            kind := 2
        else if hiddenOn and newPrice < oldPrice and newOsc > oldOsc
            kind := 4
    kind

type Lobe
    int side
    int pivotIndex
    int pivotTime
    float oscillator
    float price
    int priceTime
    int readyIndex
    bool major
    int consumedIndex = na

// Primitive-only snapshot: request.* does not return mutable internal engine arrays.
type Packet
    int processedClose
    int eventNumber
    int kind
    int anchorTime
    int pivotTime
    int pivotIndex
    float anchorOsc
    float pivotOsc
    float anchorPrice
    float pivotPrice
    int confirmedTime
    string freshEvents

// Rolling maxima over available closed history, including the initial partial lookback.
fRollingMax(array<float> values, array<int> indices, float value, int index, int length) =>
    while array.size(values) > 0 and array.last(values) <= value
        array.pop(values)
        array.pop(indices)
    array.push(values, value)
    array.push(indices, index)
    while array.size(indices) > 0 and array.first(indices) < index - length + 1
        array.shift(values)
        array.shift(indices)
    array.first(values)

// For chart/HTF contexts every input, including time and bar index, is shifted by one.
// For LTF contexts security_lower_tf supplies intrabars; the caller accepts only closed packets.
fSnapshot(bool previousClosed) =>
    float oscillator = fMA(priceSource, fastPeriod, maMethod) - fMA(priceSource, slowPeriod, maMethod)
    int offset = previousClosed ? 1 : 0
    float value = oscillator[offset]
    float hi = high[offset]
    float lo = low[offset]
    int index = bar_index - offset
    int stamp = time[offset]
    int closedStamp = time_close[offset]
    var array<float> positiveValues = array.new_float()
    var array<int> positiveIndices = array.new_int()
    var array<float> negativeValues = array.new_float()
    var array<int> negativeIndices = array.new_int()
    var array<Lobe> lobes = array.new<Lobe>()
    var array<Lobe> pending = array.new<Lobe>()
    var array<int> bestAnchors = array.new_int()
    var array<int> bestKinds = array.new_int()
    var array<float> bestGaps = array.new_float()
    var array<int> bestPivots = array.new_int()
    var int side = 0
    var bool seenValid = false
    var bool fullLobe = false
    var int pivotIndex = na
    var int pivotTime = na
    var float pivotOsc = na
    var float wickPrice = na
    var int wickTime = na
    var bool strong = false
    var int eventNumber = 0
    var int lastKind = 0
    var int lastAnchorTime = na
    var int lastPivotTime = na
    var int lastPivotIndex = na
    var float lastAnchorOsc = na
    var float lastPivotOsc = na
    var float lastAnchorPrice = na
    var float lastPivotPrice = na
    var int lastConfirmedTime = na
    string freshEvents = ""
    if not na(value) and not na(stamp) and not na(closedStamp)
        float positiveAmplitude = fRollingMax(positiveValues, positiveIndices, math.max(value, 0.0), index, strengthLookback)
        float negativeAmplitude = fRollingMax(negativeValues, negativeIndices, math.max(-value, 0.0), index, strengthLookback)
        float sideAmplitude = value < 0 ? negativeAmplitude : positiveAmplitude
        // Record the FIRST bar that consumes an anchor. Later bars cannot rewrite an old interval.
        if array.size(lobes) > 0
            for j = 0 to array.size(lobes) - 1
                Lobe old = array.get(lobes, j)
                float tolerance = math.max(1.0, math.abs(old.oscillator)) * 1e-10
                if na(old.consumedIndex) and (old.side < 0 ? value < old.oscillator - tolerance : value > old.oscillator + tolerance)
                    old.consumedIndex := index
        if array.size(pending) > 0
            for j = 0 to array.size(pending) - 1
                Lobe old = array.get(pending, j)
                float tolerance = math.max(1.0, math.abs(old.oscillator)) * 1e-10
                if na(old.consumedIndex) and (old.side < 0 ? value < old.oscillator - tolerance : value > old.oscillator + tolerance)
                    old.consumedIndex := index
        int nextSide = value > 0 ? 1 : value < 0 ? -1 : 0
        if nextSide != side
            if side != 0 and fullLobe and not na(pivotIndex)
                array.push(pending, Lobe.new(side, pivotIndex, pivotTime, pivotOsc, wickPrice, wickTime, math.max(index, pivotIndex + confirmRight), strong))
            fullLobe := seenValid
            side := nextSide
            pivotIndex := side == 0 ? na : index
            pivotTime := side == 0 ? na : stamp
            pivotOsc := side == 0 ? na : value
            wickPrice := side == 0 ? na : side < 0 ? lo : hi
            wickTime := side == 0 ? na : stamp
            strong := not majorOnly or math.abs(value) >= sideAmplitude * math.max(minHeight, minSwing)
        else if side != 0
            if side < 0 ? value <= pivotOsc : value >= pivotOsc
                pivotIndex := index
                pivotTime := stamp
                pivotOsc := value
                strong := not majorOnly or math.abs(value) >= sideAmplitude * math.max(minHeight, minSwing)
            if side < 0 ? lo <= wickPrice : hi >= wickPrice
                wickPrice := side < 0 ? lo : hi
                wickTime := stamp
        seenValid := true
        int p = 0
        while p < array.size(pending)
            Lobe current = array.get(pending, p)
            if current.readyIndex > index
                p += 1
                continue
            Lobe anchor = na
            if array.size(lobes) > 0
                for j = 0 to array.size(lobes) - 1
                    Lobe old = array.get(lobes, j)
                    int distance = current.pivotIndex - old.pivotIndex
                    bool intact = na(old.consumedIndex) or old.consumedIndex >= current.pivotIndex
                    if old.side == current.side and old.major and old.readyIndex <= current.readyIndex and distance >= minDistance and distance <= maxDistance and intact
                        if na(anchor)
                            anchor := old
                        else if current.side < 0 ? old.oscillator < anchor.oscillator : old.oscillator > anchor.oscillator
                            anchor := old
                        else if old.oscillator == anchor.oscillator and old.pivotIndex < anchor.pivotIndex
                            anchor := old
            if not na(anchor)
                int kind = fKind(current.side, anchor.price, current.price, anchor.oscillator, current.oscillator)
                if kind != 0
                    float gap = math.abs(current.price - anchor.price)
                    float tolerance = math.max(1.0, math.abs(anchor.price)) * 1e-10
                    int slot = -1
                    if array.size(bestAnchors) > 0
                        for j = 0 to array.size(bestAnchors) - 1
                            if array.get(bestAnchors, j) == anchor.pivotIndex and array.get(bestKinds, j) == kind
                                slot := j
                                break
                    bool selected = true
                    if keepLargest and slot >= 0
                        float oldGap = array.get(bestGaps, slot)
                        selected := gap > oldGap + tolerance or (math.abs(gap - oldGap) <= tolerance and current.pivotIndex >= array.get(bestPivots, slot))
                    if selected
                        if slot < 0
                            array.push(bestAnchors, anchor.pivotIndex)
                            array.push(bestKinds, kind)
                            array.push(bestGaps, gap)
                            array.push(bestPivots, current.pivotIndex)
                        else
                            array.set(bestGaps, slot, gap)
                            array.set(bestPivots, slot, current.pivotIndex)
                        eventNumber += 1
                        lastKind := kind
                        lastAnchorTime := anchor.pivotTime
                        lastPivotTime := current.pivotTime
                        lastPivotIndex := current.pivotIndex
                        lastAnchorOsc := anchor.oscillator
                        lastPivotOsc := current.oscillator
                        lastAnchorPrice := anchor.price
                        lastPivotPrice := current.price
                        lastConfirmedTime := closedStamp
                        bool notify = kind <= 2 ? alertRegular : alertHidden
                        if notify
                            freshEvents += (freshEvents == "" ? "" : "; ") + fName(kind) + " confirmed | pivot " + str.format_time(current.pivotTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
            array.push(lobes, current)
            array.remove(pending, p)
        int j = array.size(lobes) - 1
        while j >= 0
            if array.get(lobes, j).pivotIndex < index - maxDistance - confirmRight
                array.remove(lobes, j)
            j -= 1
        j := array.size(bestAnchors) - 1
        while j >= 0
            if array.get(bestAnchors, j) < index - maxDistance - confirmRight
                array.remove(bestAnchors, j)
                array.remove(bestKinds, j)
                array.remove(bestGaps, j)
                array.remove(bestPivots, j)
            j -= 1
    else
        side := 0
        fullLobe := false
        seenValid := false
    Packet.new(closedStamp, eventNumber, lastKind, lastAnchorTime, lastPivotTime, lastPivotIndex, lastAnchorOsc, lastPivotOsc, lastAnchorPrice, lastPivotPrice, lastConfirmedTime, freshEvents)

fTimeframe(string token) =>
    switch token
        "CURRENT" => timeframe.period
        "M1" => "1"
        "M2" => "2"
        "M3" => "3"
        "M4" => "4"
        "M5" => "5"
        "M6" => "6"
        "M10" => "10"
        "M12" => "12"
        "M15" => "15"
        "M20" => "20"
        "M30" => "30"
        "H1" => "60"
        "H2" => "120"
        "H3" => "180"
        "H4" => "240"
        "H6" => "360"
        "H8" => "480"
        "H12" => "720"
        "D1" => "1D"
        "W1" => "1W"
        "MN1" => "1M"
        => ""

var array<string> scanFrames = array.new_string()
var array<string> scanNames = array.new_string()
varip array<int> seenClose = array.new_int()
if barstate.isfirst
    if minDistance > maxDistance
        runtime.error("Min bars must not exceed max bars.")
    if scannerOn
        string normalized = str.replace_all(str.upper(timeframeList), "PERIOD_", "")
        normalized := str.replace_all(normalized, ";", ",")
        normalized := str.replace_all(normalized, " ", ",")
        normalized := str.replace_all(normalized, "\t", ",")
        normalized := str.replace_all(normalized, "\r", ",")
        normalized := str.replace_all(normalized, "\n", ",")
        array<string> tokens = str.split(normalized, ",")
        for token in tokens
            if token != ""
                string frame = fTimeframe(token)
                if frame == ""
                    runtime.error("Unknown timeframe: " + token + ". Example: M5,M15,H1,H4,D1")
                if not array.includes(scanFrames, frame)
                    array.push(scanFrames, frame)
                    array.push(scanNames, token)
                    array.push(seenClose, na)
        if array.size(scanFrames) < 1 or array.size(scanFrames) > 10
            runtime.error("Enter between 1 and 10 unique timeframes.")

float ewo = fMA(priceSource, fastPeriod, maMethod) - fMA(priceSource, slowPeriod, maMethod)
float smoothed = fMA(ewo, signalPeriod, signalMethod)
color histogramColor = ewo >= 0 ? (ewo > ewo[1] ? color.lime : color.green) : (ewo < ewo[1] ? color.red : color.maroon)
plot(ewo, "EWO", color=histogramColor, linewidth=2, style=plot.style_histogram)
plot(showMA ? smoothed : na, "EWO MA", color=color.blue, linewidth=1)
hline(0, "Zero", color=color.new(color.gray, 65))

type Drawing
    string key
    int pivotIndex
    line segment
    label caption

var array<Drawing> drawings = array.new<Drawing>()
var int drawnEvent = 0
Packet local = fSnapshot(true)
if local.eventNumber > drawnEvent and local.kind != 0
    string key = str.tostring(local.anchorTime) + ":" + str.tostring(local.kind)
    if keepLargest and array.size(drawings) > 0
        int j = array.size(drawings) - 1
        while j >= 0
            Drawing old = array.get(drawings, j)
            if old.key == key
                line.delete(old.segment)
                label.delete(old.caption)
                array.remove(drawings, j)
            j -= 1
    color clr = fColor(local.kind)
    line segment = na
    label caption = na
    if drawLines
        segment := line.new(local.anchorTime, local.anchorOsc, local.pivotTime, local.pivotOsc, xloc=xloc.bar_time, extend=extend.none, color=clr, style=local.kind <= 2 ? line.style_solid : line.style_dashed, width=local.kind <= 2 ? strokeWidth : 1)
    if showLabels or showArrows
        bool bullish = local.kind == 1 or local.kind == 3
        string captionText = (showArrows ? (bullish ? "↑ " : "↓ ") : "") + (showLabels ? fName(local.kind) : "")
        caption := label.new(local.pivotTime, local.pivotOsc, captionText, xloc=xloc.bar_time, yloc=yloc.price, style=bullish ? label.style_label_up : label.style_label_down, color=color.new(clr, 100), textcolor=clr, size=size.small)
    array.push(drawings, Drawing.new(key, local.pivotIndex, segment, caption))
    drawnEvent := local.eventNumber
while array.size(drawings) > maxDraw
    Drawing old = array.shift(drawings)
    line.delete(old.segment)
    label.delete(old.caption)
if array.size(drawings) > 0
    int j = array.size(drawings) - 1
    while j >= 0
        Drawing old = array.get(drawings, j)
        if old.pivotIndex < bar_index - historyBars
            line.delete(old.segment)
            label.delete(old.caption)
            array.remove(drawings, j)
        j -= 1

var table scanner = table.new(position.top_right, 3, 12, border_width=1)
varip bool realtimeStarted = false
varip int localSeenClose = na
bool firstRealtime = barstate.isrealtime and not realtimeStarted
string notifications = ""
if barstate.islast and showScanner and scannerOn
    table.cell(scanner, 0, 0, "Mr Poleks", text_color=color.white, bgcolor=color.new(color.blue, 65))
    table.cell(scanner, 1, 0, "Divergence", text_color=color.white, bgcolor=color.new(color.blue, 65))
    table.cell(scanner, 2, 0, "Pivot (exchange time)", text_color=color.white, bgcolor=color.new(color.blue, 65))

if scannerOn and array.size(scanFrames) > 0
    for i = 0 to array.size(scanFrames) - 1
        string frame = array.get(scanFrames, i)
        string name = array.get(scanNames, i)
        int checkpoint = array.get(seenClose, i)
        Packet latest = na
        if timeframe.in_seconds(frame) < timeframe.in_seconds()
            array<Packet> intrabars = request.security_lower_tf(syminfo.tickerid, frame, fSnapshot(false), ignore_invalid_timeframe=true, calc_bars_count=6000)
            if array.size(intrabars) > 0
                for packet in intrabars
                    if not na(packet) and not na(packet.processedClose) and (not barstate.isrealtime or packet.processedClose <= timenow)
                        latest := packet
                        if barstate.isrealtime and not firstRealtime and not na(checkpoint) and packet.processedClose > checkpoint and packet.freshEvents != ""
                            notifications += (notifications == "" ? "" : "\n") + syminfo.ticker + " (" + name + ") " + packet.freshEvents
                        if barstate.isrealtime
                            checkpoint := na(checkpoint) ? packet.processedClose : math.max(checkpoint, packet.processedClose)
        else
            latest := request.security(syminfo.tickerid, frame, fSnapshot(true), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=6000)
            if not na(latest) and barstate.isrealtime and not na(latest.processedClose)
                if not firstRealtime and not na(checkpoint) and latest.processedClose > checkpoint and latest.freshEvents != ""
                    notifications += (notifications == "" ? "" : "\n") + syminfo.ticker + " (" + name + ") " + latest.freshEvents
                checkpoint := na(checkpoint) ? latest.processedClose : math.max(checkpoint, latest.processedClose)
        if barstate.isrealtime
            array.set(seenClose, i, checkpoint)
        if barstate.islast and showScanner
            string status = na(latest) ? "Waiting for data" : fName(latest.kind)
            string pivot = na(latest) ? "-" : na(latest.pivotTime) ? "-" : str.format_time(latest.pivotTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
            color clr = na(latest) ? color.gray : latest.kind == 0 ? color.gray : fColor(latest.kind)
            table.cell(scanner, 0, i + 1, name, text_color=color.white, bgcolor=color.new(color.black, 30))
            table.cell(scanner, 1, i + 1, status, text_color=clr, bgcolor=color.new(color.black, 30))
            table.cell(scanner, 2, i + 1, pivot, text_color=color.silver, bgcolor=color.new(color.black, 30))
else if barstate.isrealtime
    if not firstRealtime and not na(localSeenClose) and local.processedClose > localSeenClose and local.freshEvents != ""
        notifications := syminfo.ticker + " (" + timeframe.period + ") " + local.freshEvents
    localSeenClose := local.processedClose

if barstate.isrealtime
    realtimeStarted := true
if notifications != ""
    alert(notifications, alert.freq_all)

// Create Alert -> this indicator -> Any alert() function call -> enable Notify on app.
// Historical signals do not trigger alerts at startup. Changes to inputs require recreating alerts.
````
