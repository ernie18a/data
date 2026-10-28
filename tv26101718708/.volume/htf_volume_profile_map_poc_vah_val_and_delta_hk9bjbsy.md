# HTF Volume Profile Map - POC, VAH, VAL and Delta

- url: https://www.tradingview.com/script/hk9BJBSY-HTF-Volume-Profile-Map-POC-VAH-VAL-and-Delta/
- type: indicator
- pine_id: PUB;6fa4c16f480b4c1e959d6340fce06542
- version: 1.0

## Description

[b]HTF Volume Profile Map - POC, VAH, VAL and Delta[/b]

HTF Volume Profile Map estimates where trading volume was concentrated inside higher-timeframe candles and displays those value areas directly on an intraday chart.
The indicator builds a separate volume-at-price profile for each completed higher-timeframe candle. For example, traders can view four-hour volume distributions while working from a 5-minute, 15-minute, or 1-hour chart.
It highlights the prices that attracted the greatest estimated participation rather than relying only on the higher-timeframe candle’s open, high, low, and close.

[b]Main features[/b]
[list]
[*]Higher-timeframe volume-at-price profiles
[*]Point of Control, or POC
[*]Value Area High and Value Area Low
[*]Configurable value-area percentage
[*]Developing POC, VAH, and VAL
[*]Projection of the latest completed value area
[*]Estimated directional volume delta
[*]Buy/sell-colored profile rows
[*]Automatic ATR-based row sizing
[*]Manual tick-based row sizing
[*]Configurable profile width and history
[*]Dashboard showing location, flow, levels, and calculation quality
[*]Alerts for value-area entry and POC crosses
[/list]

[b]How it works[/b]
The script retrieves lower-timeframe OHLCV data using request.security_lower_tf() and groups those intrabars inside the selected higher-timeframe period.
Each intrabar’s volume is distributed across the price rows touched by its high-to-low range. Upward intrabars contribute to estimated buying volume, while downward intrabars contribute to estimated selling volume. Doji intrabars are classified using their movement relative to the preceding intrabar.
The row with the greatest accumulated volume becomes the POC.
The value area begins at the POC and expands toward adjacent rows with greater volume until it contains the selected percentage of total profile volume. The conventional default is 70%.

[b]Reading the profile[/b]
[b]POC[/b]
The price row containing the highest estimated volume. It can represent an important acceptance level or price magnet.
[b]VAH[/b]
The upper boundary of the value area. Trading above VAH can indicate an auction attempting to establish higher value.
[b]VAL[/b]
The lower boundary of the value area. Trading below VAL can indicate an auction attempting to establish lower value.

[b]Estimated Delta[/b]
The difference between estimated buying and selling volume:
Positive delta indicates greater upward intrabar volume.
Negative delta indicates greater downward intrabar volume.
A relatively small delta is classified as balanced value.
Dashboard states
[b]Above Value[/b]
[b]Price is above the latest completed HTF value area.
Below Value[/b]
Price is below the latest completed HTF value area.
[b]Value / Upper[/b]
[b]Price is inside value and above the POC.
Value / Lower[/b]
Price is inside value and below the POC.
[b]Buy Dominant / Sell Dominant[/b]
Estimated delta exceeds the directional threshold.
[b]Balanced Value[/b]
Neither side has established significant directional dominance.
[b]
Practical applications[/b]
Traders can use the indicator to study:
[list]
[*]Acceptance or rejection around prior HTF value
[*]POC retests
[*]Failed auctions above VAH or below VAL
[*]Rotation from one value boundary toward the other
[*]Confluence with market structure, liquidity, supply/demand, or session levels
[*]Differences between price direction and estimated volume delta
[/list]
The indicator identifies context and reference levels. It does not generate automatic buy or sell signals.

[b]Suggested configuration[/b]
For a 15-minute chart:
[list]
[*]Higher Timeframe: 240 minutes
[*]Intrabar Sampling: 1 minute
[*]Row Size: Auto
[*]Value Area: 70%
[/list]
For a 5-minute chart:
[list]
[*]Higher Timeframe: 60 or 240 minutes
[*]Intrabar Sampling: 1 minute
[*]Value Area: 70%
[/list]
Increase profile width if the histograms appear too narrow. Increase the row size or reduce the automatic target-row setting if the dashboard displays “Widen Rows.”

[b]Important limitation[/b]
This is an estimated volume profile, not an exchange-level bid/ask footprint.
TradingView’s native footprint API requires a qualifying higher-tier subscription. This script instead uses lower-timeframe OHLCV data, allowing it to operate without the native footprint request.
Because the precise transaction price of every trade is unavailable, each intrabar’s volume is distributed across the price rows covered by that intrabar. The resulting POC, value area, and delta should therefore be treated as analytical estimates.
Historical depth also depends on the selected sampling timeframe and TradingView’s available intrabar data.
The script processes confirmed chart bars and discards the first incomplete HTF profile loaded at the beginning of the dataset. Completed HTF profiles remain fixed, while developing levels can change until their HTF candle closes.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("HTF Volume Profile Map - POC, VAH, VAL and Delta", shorttitle="HTF Volume Map", overlay=true, behind_chart=false, max_boxes_count=500, max_lines_count=500)

// Essential-compatible approximation: builds HTF volume-at-price from request.security_lower_tf().
// It does NOT call TradingView's Premium/Ultimate-only request.footprint() API. Intrabar volume is
// spread evenly over the price rows touched by each lower-timeframe candle. Buy/sell categorization
// follows intrabar direction, but it is not exchange bid/ask tape data.

grpEngine       = "Approximate Profile Engine"
htfInput        = input.timeframe("240", "Higher Timeframe", group=grpEngine)
sampleTf        = input.timeframe("1", "Intrabar Sampling", group=grpEngine, tooltip="Must be lower than or equal to the chart timeframe. Finer sampling improves the approximation but shortens history.")
rowMode         = input.string("Auto", "Row Size", options=["Auto", "Manual"], group=grpEngine)
targetRows      = input.int(32, "Auto Rows per HTF ATR", minval=12, maxval=80, group=grpEngine)
manualTicks     = input.int(20, "Manual Ticks per Row", minval=1, group=grpEngine)
valueAreaPct    = input.float(70.0, "Value Area %", minval=1.0, maxval=100.0, step=1.0, group=grpEngine)
maxRowsGuard    = input.int(120, "Maximum Rows per Profile", minval=20, maxval=200, group=grpEngine)

grpVisual       = "Visuals"
profilesToKeep  = input.int(8, "HTF Profiles to Keep", minval=1, maxval=20, group=grpVisual)
profileWidthPct = input.int(42, "Profile Width (% of HTF Candle)", minval=10, maxval=100, group=grpVisual)
showDeveloping  = input.bool(true, "Show Developing POC / VA", group=grpVisual)
projectLatest   = input.bool(true, "Project Latest Completed VA / POC", group=grpVisual)
showDashboard   = input.bool(true, "Show Dashboard", group=grpVisual)

chartSec  = timeframe.in_seconds()
sampleSec = timeframe.in_seconds(sampleTf)
htfSec    = timeframe.in_seconds(htfInput)
if barstate.isfirst and (not timeframe.isintraday or na(chartSec) or na(sampleSec) or na(htfSec) or sampleSec > chartSec or chartSec >= htfSec)
    runtime.error("HTF VA Essential: use an intraday chart, choose an HTF above the chart timeframe, and choose sampling <= chart timeframe.")

colBuy   = #20d477
colSell  = #ff5353
colPoc   = #fbbf24
colVa    = #4f7cff
colText  = #d1d4dc
colMuted = #787b86
colPanel = #131722

priorAtr = request.security(syminfo.tickerid, htfInput, ta.atr(14)[1], lookahead=barmerge.lookahead_on)
float autoRaw = math.max(syminfo.mintick, nz(priorAtr, math.abs(close) * 0.01) / targetRows)
int autoTicks = math.max(1, int(math.ceil(autoRaw / syminfo.mintick)))
int nextTicks = rowMode == "Auto" ? autoTicks : manualTicks

[iOpen, iHigh, iLow, iClose, iVolume] = request.security_lower_tf(
    syminfo.tickerid,
    sampleTf,
    [open, high, low, close, volume],
    ignore_invalid_timeframe=true
)

var map<int, float> totalMap = map.new<int, float>()
var map<int, float> buyMap   = map.new<int, float>()
var map<int, float> sellMap  = map.new<int, float>()
var int minRow = na
var int maxRow = na
var int activeTicks = na
var float rowSize = na
var int profileStart = na
var bool profileIsFull = false
var bool rowLimitHit = false
var float priorIntrabarClose = na
var int priorDirection = 0

var float latestPoc = na
var float latestVah = na
var float latestVal = na
var float latestDeltaPct = na
var float developingPoc = na
var float developingVah = na
var float developingVal = na

var array<box> profileBoxes = array.new<box>()
var array<line> profileLines = array.new<line>()
var array<int> profileBoxCounts = array.new<int>()
var array<int> profileLineCounts = array.new<int>()
var array<line> liveLines = array.new<line>()
var box projectedVa = na
var line projectedPoc = na
var line projectedVah = na
var line projectedVal = na

f_total(int idx) => nz(map.get(totalMap, idx), 0.0)
f_buy(int idx) => nz(map.get(buyMap, idx), 0.0)
f_sell(int idx) => nz(map.get(sellMap, idx), 0.0)

f_stats() =>
    int poc = na
    int val = na
    int vah = na
    float total = 0.0
    float maxVolume = 0.0
    if not na(minRow) and not na(maxRow)
        for idx = minRow to maxRow
            float value = f_total(idx)
            total += value
            if value > maxVolume
                maxVolume := value
                poc := idx
        if not na(poc) and total > 0
            val := poc
            vah := poc
            float accepted = f_total(poc)
            float target = total * valueAreaPct / 100.0
            int guard = 0
            while accepted < target and guard < maxRowsGuard
                bool canDown = val > minRow
                bool canUp = vah < maxRow
                float downVolume = canDown ? f_total(val - 1) : -1.0
                float upVolume = canUp ? f_total(vah + 1) : -1.0
                if not canDown and not canUp
                    break
                else if upVolume >= downVolume
                    vah += 1
                    accepted += math.max(upVolume, 0.0)
                else
                    val -= 1
                    accepted += math.max(downVolume, 0.0)
                guard += 1
    [poc, val, vah, total, maxVolume]

f_prune_oldest() =>
    if array.size(profileBoxCounts) > 0
        int count = array.shift(profileBoxCounts)
        if count > 0
            for i = 0 to count - 1
                if array.size(profileBoxes) > 0
                    box.delete(array.shift(profileBoxes))
    if array.size(profileLineCounts) > 0
        int count = array.shift(profileLineCounts)
        if count > 0
            for i = 0 to count - 1
                if array.size(profileLines) > 0
                    line.delete(array.shift(profileLines))

f_render(int leftTime, int rightTime, int poc, int val, int vah, float maxVolume, float sizePerRow) =>
    int count = 0
    int span = math.max(1, rightTime - leftTime)
    int maxWidth = int(span * profileWidthPct / 100.0)
    if not na(poc) and maxVolume > 0
        for idx = minRow to maxRow
            float rowVolume = f_total(idx)
            if rowVolume > 0
                float ratio = rowVolume / maxVolume
                int width = math.max(1, int(maxWidth * ratio))
                float delta = f_buy(idx) - f_sell(idx)
                bool inValue = idx >= val and idx <= vah
                color rowColor = delta >= 0 ? colBuy : colSell
                int transparency = inValue ? int(58 - 20 * ratio) : int(84 - 14 * ratio)
                box rowBox = box.new(rightTime - width, (idx + 1) * sizePerRow, rightTime, idx * sizePerRow, xloc=xloc.bar_time, bgcolor=color.new(rowColor, transparency), border_color=color.new(rowColor, 100))
                array.push(profileBoxes, rowBox)
                count += 1
        array.push(profileLines, line.new(leftTime, (poc + 0.5) * sizePerRow, rightTime, (poc + 0.5) * sizePerRow, xloc=xloc.bar_time, color=colPoc, width=3))
        array.push(profileLines, line.new(leftTime, (vah + 1.0) * sizePerRow, rightTime, (vah + 1.0) * sizePerRow, xloc=xloc.bar_time, color=colVa, style=line.style_dashed))
        array.push(profileLines, line.new(leftTime, val * sizePerRow, rightTime, val * sizePerRow, xloc=xloc.bar_time, color=colVa, style=line.style_dashed))
    count

currentHtfStart = time(htfInput)
newHtf = ta.change(currentHtfStart) != 0

if na(profileStart)
    profileStart := currentHtfStart
    activeTicks := nextTicks
    rowSize := activeTicks * syminfo.mintick

if newHtf
    [oldPoc, oldVal, oldVah, oldTotal, oldMax] = f_stats()
    if profileIsFull and not na(oldPoc) and oldTotal > 0
        latestPoc := (oldPoc + 0.5) * rowSize
        latestVah := (oldVah + 1.0) * rowSize
        latestVal := oldVal * rowSize
        float totalBuy = 0.0
        float totalSell = 0.0
        for idx = minRow to maxRow
            totalBuy += f_buy(idx)
            totalSell += f_sell(idx)
        latestDeltaPct := oldTotal > 0 ? 100.0 * (totalBuy - totalSell) / oldTotal : na

        while array.size(profileBoxCounts) >= profilesToKeep
            f_prune_oldest()
        while array.size(profileBoxes) > 500 - maxRowsGuard and array.size(profileBoxCounts) > 0
            f_prune_oldest()
        int boxesMade = f_render(profileStart, currentHtfStart, oldPoc, oldVal, oldVah, oldMax, rowSize)
        array.push(profileBoxCounts, boxesMade)
        array.push(profileLineCounts, 3)

        if not na(projectedVa)
            box.delete(projectedVa)
        if not na(projectedPoc)
            line.delete(projectedPoc)
        if not na(projectedVah)
            line.delete(projectedVah)
        if not na(projectedVal)
            line.delete(projectedVal)
        int currentCloseTime = time_close(htfInput)
        projectedVa := projectLatest ? box.new(currentHtfStart, latestVah, currentCloseTime, latestVal, xloc=xloc.bar_time, extend=extend.right, bgcolor=color.new(colVa, 91), border_color=color.new(colVa, 100)) : na
        projectedPoc := projectLatest ? line.new(currentHtfStart, latestPoc, currentCloseTime, latestPoc, xloc=xloc.bar_time, extend=extend.right, color=color.new(colPoc, 10), width=2) : na
        projectedVah := projectLatest ? line.new(currentHtfStart, latestVah, currentCloseTime, latestVah, xloc=xloc.bar_time, extend=extend.right, color=color.new(colVa, 25), style=line.style_dotted) : na
        projectedVal := projectLatest ? line.new(currentHtfStart, latestVal, currentCloseTime, latestVal, xloc=xloc.bar_time, extend=extend.right, color=color.new(colVa, 25), style=line.style_dotted) : na

    map.clear(totalMap)
    map.clear(buyMap)
    map.clear(sellMap)
    minRow := na
    maxRow := na
    activeTicks := nextTicks
    rowSize := activeTicks * syminfo.mintick
    profileStart := currentHtfStart
    profileIsFull := true
    rowLimitHit := false
    priorIntrabarClose := na
    priorDirection := 0

if barstate.isconfirmed and array.size(iHigh) > 0
    for sample = 0 to array.size(iHigh) - 1
        float sampleOpen = array.get(iOpen, sample)
        float sampleHigh = array.get(iHigh, sample)
        float sampleLow = array.get(iLow, sample)
        float sampleClose = array.get(iClose, sample)
        float sampleVolume = nz(array.get(iVolume, sample), 0.0)
        if not na(sampleHigh) and not na(sampleLow) and sampleVolume > 0 and rowSize > 0
            int lowIdx = int(math.floor(sampleLow / rowSize))
            int highIdx = int(math.floor(sampleHigh / rowSize))
            int touched = highIdx - lowIdx + 1
            int prospectiveMin = na(minRow) ? lowIdx : math.min(minRow, lowIdx)
            int prospectiveMax = na(maxRow) ? highIdx : math.max(maxRow, highIdx)
            if touched <= maxRowsGuard and prospectiveMax - prospectiveMin + 1 <= maxRowsGuard
                int direction = sampleClose > sampleOpen ? 1 : sampleClose < sampleOpen ? -1 : not na(priorIntrabarClose) and sampleClose > priorIntrabarClose ? 1 : not na(priorIntrabarClose) and sampleClose < priorIntrabarClose ? -1 : priorDirection
                float share = sampleVolume / touched
                for idx = lowIdx to highIdx
                    map.put(totalMap, idx, f_total(idx) + share)
                    if direction >= 0
                        map.put(buyMap, idx, f_buy(idx) + share)
                    else
                        map.put(sellMap, idx, f_sell(idx) + share)
                minRow := na(minRow) ? lowIdx : math.min(minRow, lowIdx)
                maxRow := na(maxRow) ? highIdx : math.max(maxRow, highIdx)
                priorIntrabarClose := sampleClose
                priorDirection := direction
            else
                rowLimitHit := true

[devPoc, devVal, devVah, devTotal, devMax] = f_stats()
if not na(devPoc)
    developingPoc := (devPoc + 0.5) * rowSize
    developingVah := (devVah + 1.0) * rowSize
    developingVal := devVal * rowSize

if barstate.islast
    while array.size(liveLines) > 0
        line.delete(array.pop(liveLines))
    if showDeveloping and not na(developingPoc)
        int liveEnd = time_close(htfInput)
        array.push(liveLines, line.new(profileStart, developingPoc, liveEnd, developingPoc, xloc=xloc.bar_time, color=color.new(colPoc, 35), width=2))
        array.push(liveLines, line.new(profileStart, developingVah, liveEnd, developingVah, xloc=xloc.bar_time, color=color.new(colVa, 55), style=line.style_dotted))
        array.push(liveLines, line.new(profileStart, developingVal, liveEnd, developingVal, xloc=xloc.bar_time, color=color.new(colVa, 55), style=line.style_dotted))

string location = na(latestVah) ? "BUILDING" : close > latestVah ? "ABOVE VALUE" : close < latestVal ? "BELOW VALUE" : close >= latestPoc ? "VALUE / UPPER" : "VALUE / LOWER"
string flow = na(latestDeltaPct) ? "BUILDING" : latestDeltaPct >= 10 ? "BUY DOMINANT" : latestDeltaPct <= -10 ? "SELL DOMINANT" : "BALANCED VALUE"

var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(colPanel, 5), border_color=color.new(colMuted, 70), border_width=1)
if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "HTF VALUE (EST.)", text_color=colText, bgcolor=color.new(colVa, 60))
    table.cell(dash, 1, 0, htfInput, text_color=color.white, bgcolor=color.new(colVa, 60))
    table.cell(dash, 0, 1, "LOCATION", text_color=colMuted)
    table.cell(dash, 1, 1, location, text_color=location == "ABOVE VALUE" ? colBuy : location == "BELOW VALUE" ? colSell : colVa)
    table.cell(dash, 0, 2, "FLOW", text_color=colMuted)
    table.cell(dash, 1, 2, flow, text_color=latestDeltaPct >= 10 ? colBuy : latestDeltaPct <= -10 ? colSell : colPoc)
    table.cell(dash, 0, 3, "VAH", text_color=colMuted)
    table.cell(dash, 1, 3, str.tostring(latestVah, format.mintick), text_color=colVa)
    table.cell(dash, 0, 4, "POC", text_color=colMuted)
    table.cell(dash, 1, 4, str.tostring(latestPoc, format.mintick), text_color=colPoc)
    table.cell(dash, 0, 5, "VAL", text_color=colMuted)
    table.cell(dash, 1, 5, str.tostring(latestVal, format.mintick), text_color=colVa)
    table.cell(dash, 0, 6, "DELTA", text_color=colMuted)
    table.cell(dash, 1, 6, str.tostring(latestDeltaPct, "#.0") + "%", text_color=latestDeltaPct >= 0 ? colBuy : colSell)
    table.cell(dash, 0, 7, "QUALITY", text_color=colMuted)
    table.cell(dash, 1, 7, rowLimitHit ? "WIDEN ROWS" : "APPROXIMATE", text_color=rowLimitHit ? colSell : colText)
else if barstate.islast
    table.clear(dash, 0, 0, 1, 7)

bool wasOutside = not na(latestVah) and (close[1] > latestVah or close[1] < latestVal)
bool enteredValue = wasOutside and close <= latestVah and close >= latestVal
bool crossedPoc = not na(latestPoc) and ta.cross(close, latestPoc)
alertcondition(enteredValue, "Entered estimated HTF value area", "{{ticker}} entered the latest estimated HTF value area.")
alertcondition(crossedPoc, "Crossed estimated HTF POC", "{{ticker}} crossed the latest estimated HTF POC.")

plot(latestVah, "Latest estimated HTF VAH", color=color.new(colVa, 100), display=display.data_window)
plot(latestPoc, "Latest estimated HTF POC", color=color.new(colPoc, 100), display=display.data_window)
plot(latestVal, "Latest estimated HTF VAL", color=color.new(colVa, 100), display=display.data_window)
````
