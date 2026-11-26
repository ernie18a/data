# Day Trade Setup - CISD Finder

- url: https://www.tradingview.com/script/wkcm6DP0-Day-Trade-Setup-CISD-Finder/
- type: indicator
- pine_id: PUB;4066ae63689e4ff381b15ac770440c84
- version: 1.0

## Description

[b]Day Trade Setup - CISD Finder[/b] helps traders identify and monitor potential Changes in State of Delivery (CISD). It marks reference levels derived from candle opening prices, waits for a confirmed candle close beyond those levels, and displays the accumulated volume associated with each setup.
The indicator combines configurable swing detection, directional candle sequences, dashed reference lines, volume labels, optional confirmation markers, and alert conditions.
Its purpose is to make the reference level and confirmation process visible and consistent. A displayed level represents a condition being monitored; it does not automatically mean that CISD has already been confirmed.
[image]https://www.tradingview.com/x/htNgeV8a/[/image]
[b]How CISD levels are calculated[/b]
The indicator groups consecutive candles by their direction:
[list]
[*] A bullish candle closes above its opening price.
[*] A bearish candle closes below its opening price.
[*] A Doji closes at its opening price. It ends the current sequence and does not start a new 
[/list]directional sequence.
The opening price of the first candle in a qualifying sequence becomes the CISD reference level.
For [b]CISD +[/b], the indicator uses the opening price of a bearish candle sequence. Confirmation occurs when a subsequent candle closes strictly above that reference level.
For [b]CISD -[/b], the indicator uses the opening price of a bullish candle sequence. Confirmation occurs when a subsequent candle closes strictly below that reference level.
For example, if a qualifying bearish sequence starts at 2,650.00, its CISD + level is 2,650.00. A candle closing at 2,651.00 confirms the bullish CISD. A wick above 2,650.00 with a close below it does not qualify. A close exactly at 2,650.00 also does not qualify.

[b]Two detection modes are available[/b]
[list]
[*] Swing reversals — default: Filters the reference levels using confirmed Swing Highs and Swing Lows. At a confirmed Swing High, the indicator searches from the pivot candle forward for a bearish candle sequence to establish CISD +. At a confirmed Swing Low, it searches for a bullish candle sequence to establish CISD -. If the pivot candle already belongs to the required sequence, the opening price of that sequence’s first candle is used, even when the sequence started before the pivot. If the required candle direction has not appeared yet, the indicator waits for it.
[*] Every candle sequence: Creates a new reference level whenever a new bullish or bearish candle sequence begins, without requiring a confirmed swing. A new bearish sequence supplies CISD +, while a new bullish sequence supplies CISD -. This mode can replace levels more frequently because it does not apply the swing filter.
[/list]

[b]Swing sensitivity and confirmation timing[/b]
The default swing settings are:
[list]
[*] Swing: left bars = 6
[*] Swing: confirmation bars = 6
[/list]
Left bars controls the number of preceding candles used to identify a potential swing. Confirmation bars controls the number of following candles required before the swing becomes available to the indicator.

With the default settings, a swing is recognized only after six subsequent candles have closed. Increasing these settings generally selects broader swings, while increasing confirmation bars also increases the detection delay.

Once a swing is confirmed, the indicator draws its reference line back to the source candle. This identifies where the level originated; it does not mean the level was available in real time at that earlier candle.

If the selected reference level was already crossed by a closing price before swing confirmation, that candidate is discarded. The indicator does not generate a retrospective alert for that earlier crossing.

[b]Reading the lines and labels[/b]
The chart displays the latest selected level for each direction:
[list]
[*] CISD +: The reference level being monitored for a close above.
[*] CISD -: The reference level being monitored for a close below.
[/list]

Pending levels extend to the right as new bars arrive. Once a level is confirmed, its endpoint is fixed relative to the confirmation candle.

Each source candle can arm a level only once. A confirmed level cannot repeatedly trigger simply because price crosses it again. A newer qualifying level can replace the previous level on the same side.

Levels also have a configurable lifetime. The default is 500 bars from the source candle, after which the level is removed.

Optional display settings can add a ✓ to confirmed labels and place a directional marker on the actual confirmation candle. These options help distinguish pending levels from confirmed events.

[b]Volume displayed with each CISD level[/b]
The Vol text shows the total chart volume accumulated from the source candle through the latest closed candle, including both endpoints.

While a level is pending, its volume updates as additional candles close. When CISD is confirmed, the confirmation candle’s volume is included, and the total is frozen. Subsequent candles do not increase that confirmed total.

The calculation also includes candles between the source and the time a delayed swing is recognized, so volume accumulation does not begin only when the line first appears.
Volume display options include:
[list]
[*] Showing or hiding the volume text.
[*] Using abbreviated values such as K, M, or B.
[*] Displaying the value without abbreviation.
[*] Viewing a more detailed value in the label tooltip.
[*] Viewing each side’s volume in the Data Window.
[/list]
If any candle within the measured interval has missing volume data, the result displays N/A rather than presenting an incomplete sum as a complete total.
The value represents the chart’s supplied volume in its native units. It is not a separate measurement of buyer-initiated volume, seller-initiated volume, or volume delta.

[b]Appearance controls[/b]
Users can customize the color of each CISD direction, line width, right-side extension, and label size. Additional options show the reference price, confirmation check mark, and confirmation-candle markers.
The default appearance uses white dashed lines and simple labels, with volume text enabled.
Alert conditions
The indicator provides three selectable alert conditions:
[list]
[*] CISD + confirmed: Triggers when a monitored bullish reference level is confirmed.
[*] CISD - confirmed: Triggers when a monitored bearish reference level is confirmed.
[*] Any CISD confirmed: Triggers when either direction confirms.
[/list]

Directional alert messages include the symbol, timeframe, confirmed reference price, and closing price. Users must create their desired alerts through TradingView’s alert interface.
Detection and confirmation are evaluated on closed candles. An intrabar price movement or wick crossing alone does not trigger confirmation.

[b]Historical interpretation[/b]
The distinction between a level’s source candle, the time the level becomes available, and its eventual confirmation is essential when reviewing historical charts.
Swing-based levels require the configured confirmation delay, even though their lines are drawn back to their origins. Optional signal markers remain on the actual confirmation candles; they are not shifted back to the source candles.
CISD confirmation describes a specific closing-price event relative to the selected level. It does not guarantee that price will continue in the confirmed direction.

[i]Developed by DayTradeSetup.
© 2026 DayTradeSetup. All rights reserved.[/i]

## Source Code

````pine
//@version=6
// Copyright (c) 2026 DayTradeSetup. All rights reserved.
indicator("Day Trade Setup - CISD Finder", "Day Trade Setup - CISD Finder", overlay = true, max_lines_count = 10, max_labels_count = 10, max_bars_back = 5000)

// CISD +: close above the first bearish candle's open near a swing high.
// CISD -: close below the first bullish candle's open near a swing low.
// Levels are prospective; a line alone is NOT a confirmed CISD signal.
// Swing mode waits for rightBars CLOSED candles, then draws back to the
// source candle. Alerts/markers are never backdated to that source candle.
// A level already crossed before swing confirmation is discarded.

string detectionGroup = "1. Detection"
string detectionMode = input.string("Swing reversals", "Level source", options = ["Swing reversals", "Every candle sequence"], group = detectionGroup)
int leftBars = input.int(6, "Swing: left bars", minval = 1, maxval = 50, group = detectionGroup)
int rightBars = input.int(6, "Swing: confirmation bars", minval = 1, maxval = 50, group = detectionGroup, tooltip = "Swing mode: levels become available only after this many closed bars. Increasing this filters small swings but delays detection.")
int maxAge = input.int(500, "Expire level after (bars from source)", minval = 10, maxval = 5000, group = detectionGroup)

string appearanceGroup = "2. Appearance"
color plusColor = input.color(color.white, "CISD +", inline = "colors", group = appearanceGroup)
color minusColor = input.color(color.white, "CISD -", inline = "colors", group = appearanceGroup)
int lineWidth = input.int(2, "Line width", minval = 1, maxval = 4, group = appearanceGroup)
int projection = input.int(6, "Extend right (bars)", minval = 1, maxval = 100, group = appearanceGroup)
string labelSize = input.string(size.normal, "Text size", options = [size.tiny, size.small, size.normal, size.large], group = appearanceGroup)
bool showPrice = input.bool(false, "Show price in label", group = appearanceGroup)
bool showStatus = input.bool(false, "Add check mark after confirmation", group = appearanceGroup)
bool showMarkers = input.bool(false, "Mark confirmation candle", group = appearanceGroup)
bool showVolume = input.bool(true, "Show CISD volume", group = appearanceGroup, tooltip = "Total chart volume from the source candle through the latest closed candle, including both ends. Freezes on CISD confirmation. Uses the symbol feed's volume units; N/A means at least one candle has missing volume.")
bool compactVolume = input.bool(true, "Abbreviate volume (K / M / B)", group = appearanceGroup)

// Prefix totals allow delayed swing detection to include the whole interval.
// Track missing bars separately so unavailable volume is never shown as zero.
float cumulativeVolume = ta.cum(nz(volume, 0.0))
float cumulativeMissingVolume = ta.cum(na(volume) ? 1.0 : 0.0)

type CisdLevel
    float price = na
    int sourceBar = na
    int confirmedBar = na
    bool armed = false
    float volumeBefore = na
    float missingVolumeBefore = na
    float totalVolume = na
    line levelLine = na
    label levelLabel = na

method clearLevel(CisdLevel this) =>
    line.delete(this.levelLine)
    label.delete(this.levelLabel)
    this.levelLine := na
    this.levelLabel := na
    this.price := na
    this.sourceBar := na
    this.confirmedBar := na
    this.armed := false
    this.volumeBefore := na
    this.missingVolumeBefore := na
    this.totalVolume := na

method setLevel(CisdLevel this, float price, int sourceBar, color levelColor, float volumeBefore, float missingVolumeBefore) =>
    this.clearLevel()
    this.price := price
    this.sourceBar := sourceBar
    this.armed := true
    this.volumeBefore := volumeBefore
    this.missingVolumeBefore := missingVolumeBefore
    this.levelLine := line.new(sourceBar, price, bar_index + projection, price, xloc = xloc.bar_index, color = levelColor, style = line.style_dashed, width = lineWidth)
    this.levelLabel := label.new(bar_index + projection, price, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(levelColor, 100), textcolor = levelColor, size = labelSize)

method checkClose(CisdLevel this, bool bullish) =>
    // This method runs only on closed bars. Update before disarming so the
    // confirmation candle is included; later bars cannot change the total.
    if this.armed
        this.totalVolume := cumulativeMissingVolume > this.missingVolumeBefore ? na : math.max(0.0, cumulativeVolume - this.volumeBefore)
    bool crossed = this.armed and bar_index > this.sourceBar and (bullish ? close > this.price : close < this.price)
    if crossed
        this.armed := false
        this.confirmedBar := bar_index
    crossed

method drawLevel(CisdLevel this, string caption) =>
    if not na(this.levelLine)
        int endBar = (this.armed ? bar_index : this.confirmedBar) + projection
        line.set_x2(this.levelLine, endBar)
        label.set_x(this.levelLabel, endBar)
        string priceText = showPrice ? "  " + str.tostring(this.price, format.mintick) : ""
        string statusText = showStatus and not this.armed ? " ✓" : ""
        string volumeValue = na(this.totalVolume) ? "N/A" : str.tostring(this.totalVolume, compactVolume ? format.volume : "#,###.##")
        string volumeText = showVolume ? "\nVol: " + volumeValue : ""
        string volumeTooltip = "\nTotal volume (source through " + (this.armed ? "latest closed candle" : "confirmation candle") + "): " + (na(this.totalVolume) ? "N/A (missing volume data)" : str.tostring(this.totalVolume, "#,###.########"))
        label.set_text(this.levelLabel, caption + statusText + priceText + volumeText)
        label.set_tooltip(this.levelLabel, caption + " @ " + str.tostring(this.price, format.mintick) + (this.armed ? "\nWaiting for a candle to CLOSE beyond this level." : "\nConfirmed at bar " + str.tostring(this.confirmedBar)) + volumeTooltip)

// Doji candles terminate a sequence; they do not start a new one.
int candleDirection = close > open ? 1 : close < open ? -1 : 0
var float sequenceOpen = na
var int sequenceBar = na
var float sequenceVolumeBefore = na
var float sequenceMissingBefore = na
if barstate.isconfirmed
    if candleDirection == 0
        sequenceOpen := na
        sequenceBar := na
        sequenceVolumeBefore := na
        sequenceMissingBefore := na
    else if candleDirection != nz(candleDirection[1], 0)
        sequenceOpen := open
        sequenceBar := bar_index
        sequenceVolumeBefore := nz(cumulativeVolume[1], 0.0)
        sequenceMissingBefore := nz(cumulativeMissingVolume[1], 0.0)

float swingHigh = ta.pivothigh(high, leftBars, rightBars)
float swingLow = ta.pivotlow(low, leftBars, rightBars)

// Scan chronologically from the pivot to the detection bar. If the pivot
// candle already has the desired color, include its full candle sequence.
// A prior breach is remembered even if price subsequently returns inside.
findSwingSequence(int wantedDirection) =>
    float candidatePrice = na
    int candidateBar = na
    bool alreadyCrossed = false
    float candidateVolumeBefore = na
    float candidateMissingBefore = na
    for offset = rightBars to 0
        if na(candidateBar) and candleDirection[offset] == wantedDirection
            candidatePrice := sequenceOpen[offset]
            candidateBar := sequenceBar[offset]
            candidateVolumeBefore := sequenceVolumeBefore[offset]
            candidateMissingBefore := sequenceMissingBefore[offset]
        if not na(candidateBar) and offset > 0
            bool beyond = wantedDirection == -1 ? close[offset] > candidatePrice : close[offset] < candidatePrice
            alreadyCrossed := alreadyCrossed or beyond
    [candidatePrice, candidateBar, alreadyCrossed, candidateVolumeBefore, candidateMissingBefore]

var CisdLevel plus = CisdLevel.new()
var CisdLevel minus = CisdLevel.new()
var int lastPlusSource = na
var int lastMinusSource = na
var int waitingHighBar = na
var int waitingLowBar = na
bool plusSignal = false
bool minusSignal = false
float plusSignalPrice = na
float minusSignalPrice = na

if barstate.isconfirmed
    if not na(plus.sourceBar) and bar_index - plus.sourceBar > maxAge
        plus.clearLevel()
    if not na(minus.sourceBar) and bar_index - minus.sourceBar > maxAge
        minus.clearLevel()

    // Evaluate existing levels before a newly confirmed swing replaces them.
    plusSignal := plus.checkClose(true)
    minusSignal := minus.checkClose(false)
    plusSignalPrice := plusSignal ? plus.price : na
    minusSignalPrice := minusSignal ? minus.price : na

    float newPlusPrice = na
    int newPlusBar = na
    float newMinusPrice = na
    int newMinusBar = na
    float newPlusVolumeBefore = na
    float newPlusMissingBefore = na
    float newMinusVolumeBefore = na
    float newMinusMissingBefore = na

    if detectionMode == "Every candle sequence"
        if candleDirection == -1 and candleDirection != nz(candleDirection[1], 0)
            newPlusPrice := sequenceOpen
            newPlusBar := sequenceBar
            newPlusVolumeBefore := sequenceVolumeBefore
            newPlusMissingBefore := sequenceMissingBefore
        if candleDirection == 1 and candleDirection != nz(candleDirection[1], 0)
            newMinusPrice := sequenceOpen
            newMinusBar := sequenceBar
            newMinusVolumeBefore := sequenceVolumeBefore
            newMinusMissingBefore := sequenceMissingBefore
    else
        if not na(swingHigh)
            [price, sourceBar, alreadyCrossed, volumeBefore, missingBefore] = findSwingSequence(-1)
            waitingHighBar := na(sourceBar) ? bar_index - rightBars : na
            if not alreadyCrossed
                newPlusPrice := price
                newPlusBar := sourceBar
                newPlusVolumeBefore := volumeBefore
                newPlusMissingBefore := missingBefore
        if not na(swingLow)
            [price, sourceBar, alreadyCrossed, volumeBefore, missingBefore] = findSwingSequence(1)
            waitingLowBar := na(sourceBar) ? bar_index - rightBars : na
            if not alreadyCrossed
                newMinusPrice := price
                newMinusBar := sourceBar
                newMinusVolumeBefore := volumeBefore
                newMinusMissingBefore := missingBefore

        // A pivot can be confirmed without an opposite-colored candle yet.
        if not na(waitingHighBar)
            if bar_index - waitingHighBar > maxAge
                waitingHighBar := na
            else if candleDirection == -1
                newPlusPrice := sequenceOpen
                newPlusBar := sequenceBar
                newPlusVolumeBefore := sequenceVolumeBefore
                newPlusMissingBefore := sequenceMissingBefore
                waitingHighBar := na
        if not na(waitingLowBar)
            if bar_index - waitingLowBar > maxAge
                waitingLowBar := na
            else if candleDirection == 1
                newMinusPrice := sequenceOpen
                newMinusBar := sequenceBar
                newMinusVolumeBefore := sequenceVolumeBefore
                newMinusMissingBefore := sequenceMissingBefore
                waitingLowBar := na

    // Each source candle can arm only once, even when multiple pivots share it.
    if not na(newPlusBar) and (na(lastPlusSource) or newPlusBar > lastPlusSource) and bar_index - newPlusBar <= maxAge
        plus.setLevel(newPlusPrice, newPlusBar, plusColor, newPlusVolumeBefore, newPlusMissingBefore)
        lastPlusSource := newPlusBar
        if plus.checkClose(true)
            plusSignal := true
            plusSignalPrice := plus.price
    if not na(newMinusBar) and (na(lastMinusSource) or newMinusBar > lastMinusSource) and bar_index - newMinusBar <= maxAge
        minus.setLevel(newMinusPrice, newMinusBar, minusColor, newMinusVolumeBefore, newMinusMissingBefore)
        lastMinusSource := newMinusBar
        if minus.checkClose(false)
            minusSignal := true
            minusSignalPrice := minus.price

// Only the right edge follows the live chart. Price/detection state uses closes.
plus.drawLevel("CISD +")
minus.drawLevel("CISD -")

plotshape(showMarkers and plusSignal, title = "CISD + confirmed", style = shape.triangleup, location = location.belowbar, color = plusColor, size = size.tiny)
plotshape(showMarkers and minusSignal, title = "CISD - confirmed", style = shape.triangledown, location = location.abovebar, color = minusColor, size = size.tiny)
plot(plus.price, "CISD + level", display = display.data_window)
plot(minus.price, "CISD - level", display = display.data_window)
plot(plus.totalVolume, "CISD + volume", display = display.data_window, format = format.volume)
plot(minus.totalVolume, "CISD - volume", display = display.data_window, format = format.volume)
plot(plusSignalPrice, "CISD + signal price", display = display.none)
plot(minusSignalPrice, "CISD - signal price", display = display.none)
alertcondition(plusSignal, "CISD + confirmed", 'CISD + | {{ticker}} | {{interval}} | Level {{plot("CISD + signal price")}} | Close {{close}}')
alertcondition(minusSignal, "CISD - confirmed", 'CISD - | {{ticker}} | {{interval}} | Level {{plot("CISD - signal price")}} | Close {{close}}')
alertcondition(plusSignal or minusSignal, "Any CISD confirmed", "CISD confirmed | {{ticker}} | {{interval}} | Close {{close}}")
````
