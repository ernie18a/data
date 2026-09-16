<!-- tradingview-pine-id: PUB;8acc2e771b5f4692874db93ff1358eb6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume & Movement

Source: https://www.tradingview.com/script/ezIc9E3m-Volume-Movement/

## Description

# Volume & Movement

A separate TradingView Pine v6 indicator for comparing activity, sustained volume and candle behaviour. Uses the chart's own candles and feed volume.

## Install

1. Open a standard candlestick chart in TradingView.
2. Open **Pine Editor**, create a new indicator and replace its contents with `Volume_and_Movement.pine`.
3. Choose **Add to chart**. Save under **Volume & Movement** if you want to keep it in your account.

No extra data subscription, library or account connection is used by the script. The chart's own market-data availability still applies. Alerts require you to create an alert in TradingView; this script does not create alerts or orders automatically.

## Read the pane

The default bars compare each completed candle's volume with the immediately preceding candle:

| Reading | Meaning |
|---|---|
| 0.50× | Half as much volume |
| 1.00× | The same volume |
| 2.00× | Twice as much volume |
| 3.00× | Three times as much volume |

**Blue:** more than 10% above the previous candle. **Amber:** more than 10% below it. **Grey:** within that neutral zone, or no valid previous comparison. Colours describe the change in volume, not buying or selling. The neutral zone and all colours are adjustable.

The **slate line** compares the combined volume of the latest five candles with the five immediately before them. Example: the earlier group totals 500 and the latest group totals 800; the line reads 1.60×. These groups do not overlap within an individual comparison. Each new candle advances both windows one candle.

The dashed **1× line** is the equal-volume reference. The default scale is uncapped. If you set a visual cap, orange dots mark clipped readings; their exact values remain in the dashboard and Data Window.

You can change bar height to **Recent typical** or **Matching clock time**. The bar colours continue to show change against the previous candle. The group line always retains its own group-to-group comparison. These are distinct baselines, although all use a 1× reference.

## Purple markers

These are adjustable descriptive conditions, not predictions or trade recommendations:

| Marker | What happened | Default rule |
|---|---|---|
| **S — Busy / stalled** | High activity, small range and little net price progress | High volume; range at/below prior 30th percentile and ≤0.75× typical; close-to-close distance ≤0.5× typical range |
| **A — Busy / advancing** | High activity and a large candle closing near an edge | High volume; range at/above prior 80th percentile and ≥1.25× typical; body ≥60% of range; close in top/bottom 20% |
| **R — Busy / rejection** | High activity with a dominant wick and a recovered close | High volume; range ≥typical; wick ≥60% of range; close in upper 35% for a lower wick, or lower 35% for an upper wick |
| **L — Large move / light volume** | Large candle range despite unusually light activity | Low volume; range at/above prior 80th percentile and ≥1.25× typical |

High volume must exceed the prior 90th-percentile value **and** be at least 1.5× the baseline median. Low volume must be below the prior 20th-percentile value **and** at most 0.65× the median. Requiring both a percentile and a multiple avoids labelling tiny fluctuations as extremes. Equal values at a percentile boundary do not qualify as unusual volume.

Default baselines use the **previous 100 candles**, excluding the candle being assessed. Typical means the median. An optional setting uses the matching-time volume baseline once it has enough samples; otherwise the dashboard explicitly identifies the recent-history fallback. Candle-size baselines continue to use recent candles in either mode.

Classification priority is S, then R, then A, then L. A price gap between the previous close and the candle open exceeding half the typical candle range suppresses these shape labels and is identified in the dashboard. The volume readings still remain available where comparable.

## Time-of-day context

“Same clock time” compares volume with the median of prior candles opening at the same clock minute. Default: exchange timezone, previous 28 calendar days, weekdays together and Saturday/Sunday separately, at least three matching days.

For example, an exchange-time 10:00–10:15 candle is compared with previous matching 10:00–10:15 candles, rather than the quieter overnight candles. This is a custom median-based comparison; it is not an exact clone of TradingView's built-in Relative Volume at Time.

- Supported for native intraday charts from 1 minute through 4 hours. Other standard timeframes retain the previous-candle, group and recent-history readings.
- Only completed, full-duration candles enter time history. The current day never enters its own baseline. Missing sessions are skipped, not treated as zero.
- Matching uses the exact opening minute and the same full chart-candle duration. For example, a 09:30 candle is never substituted for a 09:00 candle.
- Day matching can use all days, weekday/weekend groups, or the same weekday. Same-weekday matching needs more calendar history to warm up.
- The available chart history limits the sample. “Warming” means not enough matching history or no positive median; it does not mean low volume.
- Exchange time follows the exchange's daylight-saving rules. Brisbane remains fixed. During a repeated daylight-saving clock hour, the last completed candle for that day's bucket is retained, so each day contributes at most one observation.

## Timing, gaps and data

By default, the unfinished live candle is hidden and the dashboard shows the latest closed candle. Optional live preview is faded and explicitly labelled LIVE; its volume is incomplete and is not extrapolated to a full candle. Markers and alerts always wait for a confirmed close.

By default, immediate and group comparisons do not cross intraday session gaps or unequal-duration candle boundaries. They become available again after comparable candles accumulate. You can override this in settings. An unavailable or zero denominator produces “—”, never an infinite ratio. Valid zero current volume can produce 0×.

Detailed mode adds body/wick percentages and the group's net price distance divided by all close-to-close distance travelled. 100% means each close moved in one direction; a small percentage means more back-and-forth movement. Neither this nor candle direction identifies actual buyer-initiated versus seller-initiated volume.

The volume belongs to the selected symbol and feed. It may represent units, contracts, quote currency or tick activity depending on the feed. Comparisons do not combine exchanges or reconstruct order flow. Standard time-based charts are required; synthetic chart types are rejected.

## Alerts and sensible starting settings

Start with **Previous candle**, groups of **5**, history **100**, default anomaly thresholds and closed candles. Enable detailed mode only when examining a candle. The Data Window gives exact historical values when you move the crosshair; the dashboard shows the latest eligible candle.

Alert choices: any unusual event, or S/A/R/L individually. The default alerts only when an anomaly appears or its type/direction changes. Disable that option for every qualifying closed candle. Configure notifications yourself in TradingView.

Thresholds are starting definitions to evaluate, not settings demonstrated to improve trading results. This version does not include EMA-band integration, automatic impulse/pullback segmentation, an order-flow feed, a scanner or trade execution.

## Verification

See `VERIFICATION.md` for the actual checks performed and any remaining TradingView compile/runtime limitation.

References: [TradingView bar states](https://www.tradingview.com/pine-script-docs/concepts/bar-states/), [chart information and volume](https://www.tradingview.com/pine-script-docs/concepts/chart-information/), [Relative Volume at Time](https://www.tradingview.com/support/solutions/43000705489-relative-volume-at-time/).

---

## Source Code

````pine
//@version=6
indicator("Volume & Movement", shorttitle="V&M", overlay=false, precision=2, max_bars_back=1000)

// Native chart candles; every historical baseline excludes the candle being assessed.
string G1 = "1 · Volume comparisons"
int blockSize = input.int(5, "Candles per group", minval=2, maxval=20, group=G1)
bool showGroup = input.bool(true, "Show group comparison line", group=G1)
float neutralPct = input.float(10, "Neutral zone around previous volume (%)", minval=0, maxval=50, group=G1)
bool acrossGaps = input.bool(false, "Compare across session gaps / unequal candle durations", group=G1)
string heightBasis = input.string("Previous candle", "Bar height compares with", options=["Previous candle", "Recent typical", "Matching clock time"], group=G1)

string G2 = "2 · Time-of-day context"
bool useClock = input.bool(true, "Calculate matching time-of-day volume", group=G2)
string clockChoice = input.string("Exchange", "Comparison clock", options=["Exchange", "UTC", "Australia/Brisbane"], group=G2)
string dayMode = input.string("Weekday / Saturday / Sunday", "Match days by", options=["All days", "Weekday / Saturday / Sunday", "Same weekday"], group=G2)
int clockDays = input.int(28, "Prior calendar days", minval=3, maxval=60, group=G2)
int minMatches = input.int(3, "Minimum matching days", minval=3, maxval=20, group=G2)

string G3 = "3 · Unusual volume and candle behaviour"
int history = input.int(100, "Previous candles for recent baseline", minval=20, maxval=500, group=G3)
string anomalyBasis = input.string("Recent candles", "Volume anomaly baseline", options=["Recent candles", "Matching time when ready"], group=G3)
int highPct = input.int(90, "High volume percentile", minval=70, maxval=99, group=G3)
int lowPct = input.int(20, "Low volume percentile", minval=1, maxval=40, group=G3)
float highMultiple = input.float(1.5, "High volume: minimum × typical", minval=1.1, step=0.1, group=G3)
float lowMultiple = input.float(0.65, "Low volume: maximum × typical", minval=0.05, maxval=0.95, step=0.05, group=G3)
int smallPct = input.int(30, "Small range percentile", minval=5, maxval=45, group=G3)
int largePct = input.int(80, "Large range percentile", minval=55, maxval=99, group=G3)
float wickMin = input.float(60, "Rejection: minimum wick % of range", minval=50, maxval=90, group=G3) / 100
float bodyMin = input.float(60, "Advance: minimum body % of range", minval=50, maxval=90, group=G3) / 100
float edgeMax = input.float(20, "Advance: close within % of candle edge", minval=5, maxval=35, group=G3) / 100
bool showEvents = input.bool(true, "Show S / A / R / L markers", group=G3)
bool newOnly = input.bool(true, "Alerts: only a new or changed anomaly episode", group=G3)

string G4 = "4 · Display"
bool livePreview = input.bool(false, "Show faded live candle preview (alerts still wait for close)", group=G4)
float heightCap = input.float(0, "Visual height cap: 0 = uncapped", minval=0, maxval=100, group=G4)
bool showTable = input.bool(true, "Show dashboard", group=G4)
bool detailed = input.bool(false, "Detailed dashboard", group=G4)
color risingColor = input.color(color.rgb(25, 146, 219), "More volume than previous", group=G4)
color fallingColor = input.color(color.rgb(232, 164, 42), "Less volume than previous", group=G4)
color neutralColor = input.color(color.rgb(135, 148, 159), "Similar volume", group=G4)
color lineColor = input.color(color.rgb(87, 107, 135), "Group line", group=G4)
color eventColor = input.color(color.rgb(165, 87, 210), "Unusual behaviour marker", group=G4)

safeRatio(float n, float d) =>
    not na(n) and n >= 0 and not na(d) and d > 0 ? n / d : na

candleShape(float o, float h, float l, float c, float pc) =>
    float span = h - l
    [span, safeRatio(math.abs(c - o), span), safeRatio(h - math.max(o, c), span), safeRatio(math.min(o, c) - l, span), safeRatio(c - l, span), math.abs(c - pc)]

classify(bool hv, bool lv, bool small, bool large, bool gap, float rr, float body, float upper, float lower, float location, float progress, float wick, float bodyFloor, float edge) =>
    int result = 0
    if not gap
        if hv and small and rr <= 0.75 and progress <= 0.5
            result := 1
        else if hv and rr >= 1 and ((lower >= wick and location >= 0.65) or (upper >= wick and location <= 0.35))
            result := 3
        else if hv and large and rr >= 1.25 and body >= bodyFloor and (location >= 1 - edge or location <= edge)
            result := 2
        else if lv and large and rr >= 1.25
            result := 4
    result

// These checks run inside Pine, including when installed on another chart.
if barstate.isfirst
    if not chart.is_standard
        runtime.error("Use standard time-based candles for Volume & Movement.")
    bool ratiosOK = safeRatio(300, 100) == 3 and safeRatio(0, 100) == 0 and na(safeRatio(100, 0)) and na(safeRatio(100, na))
    [testRange, testBody, testUpper, testLower, testLocation, testProgress] = candleShape(10, 12, 9, 11, 10.5)
    bool shapeOK = testRange == 3 and math.abs(testBody - 1.0 / 3) < 0.000001 and testProgress == 0.5
    bool eventsOK = classify(true, false, true, false, false, 0.4, 0.2, 0.4, 0.4, 0.5, 0.1, 0.6, 0.6, 0.2) == 1 and classify(true, false, false, true, false, 2, 0.8, 0.1, 0.1, 0.9, 1.6, 0.6, 0.6, 0.2) == 2 and classify(true, false, false, true, false, 2, 0.2, 0.05, 0.75, 0.95, 0.4, 0.6, 0.6, 0.2) == 3 and classify(false, true, false, true, false, 2, 0.8, 0.1, 0.1, 0.9, 1.6, 0.6, 0.6, 0.2) == 4 and classify(true, false, true, false, true, 0.4, 0.2, 0.4, 0.4, 0.5, 0.1, 0.6, 0.6, 0.2) == 0
    if not ratiosOK or not shapeOK or not eventsOK
        runtime.error("Volume & Movement calculation self-check failed.")

string comparisonTZ = clockChoice == "Exchange" ? syminfo.timezone : clockChoice
float chartSeconds = timeframe.in_seconds()
bool clockSupported = timeframe.isintraday and chartSeconds >= 60 and chartSeconds <= 14400 and chartSeconds % 60 == 0
bool fullDuration = time_close - time == chartSeconds * 1000
int clockSlots = clockSupported ? 1440 : 1
int dayRing = clockDays + 2

dayClass(int t) =>
    int weekday = dayofweek(t, comparisonTZ)
    dayMode == "All days" ? 0 : dayMode == "Same weekday" ? weekday : weekday == dayofweek.saturday ? 1 : weekday == dayofweek.sunday ? 2 : 0

matchingClock() =>
    // Bounded ring: at most 89,280 volume cells at 1 minute / 60 days.
    var array<float> cells = array.new_float(dayRing * clockSlots, na)
    var array<int> dates = array.new_int(dayRing, na)
    var array<int> classes = array.new_int(dayRing, na)
    float med = na
    float qHigh = na
    float qLow = na
    int count = 0
    if useClock and clockSupported and fullDuration
        // Civil-date ordinal avoids using a fixed UTC offset across DST changes.
        int civilDay = int(timestamp("UTC", year(time, comparisonTZ), month(time, comparisonTZ), dayofmonth(time, comparisonTZ), 0, 0) / 86400000)
        int slot = hour(time, comparisonTZ) * 60 + minute(time, comparisonTZ)
        int cls = dayClass(time)
        array<float> prior = array.new_float()
        for row = 0 to dayRing - 1
            int savedDay = array.get(dates, row)
            if not na(savedDay) and savedDay < civilDay and savedDay >= civilDay - clockDays and array.get(classes, row) == cls
                float v = array.get(cells, row * clockSlots + slot)
                if not na(v)
                    array.push(prior, v)
        count := array.size(prior)
        if count >= minMatches
            array.sort(prior, order.ascending)
            med := array.median(prior)
            qHigh := array.percentile_nearest_rank(prior, highPct)
            qLow := array.percentile_nearest_rank(prior, lowPct)
        // Write AFTER lookup; current day can never contribute to its own baseline.
        if barstate.isconfirmed and not na(volume) and volume >= 0
            int row = civilDay % dayRing
            if na(array.get(dates, row)) or array.get(dates, row) != civilDay
                for s = 0 to clockSlots - 1
                    array.set(cells, row * clockSlots + s, na)
                array.set(dates, row, civilDay)
                array.set(classes, row, cls)
            array.set(cells, row * clockSlots + slot, volume)
    [med, qHigh, qLow, count]

[clockMedian, clockHigh, clockLow, clockCount] = matchingClock()
bool timeReady = clockCount >= minMatches and not na(clockMedian) and clockMedian > 0
float timeRatio = safeRatio(volume, clockMedian)
bool validVolume = not na(volume) and volume >= 0
bool boundary = timeframe.isintraday and not acrossGaps and bar_index > 0 and (time != time_close[1] or time_close - time != time_close[1] - time[1])
float previousRatio = boundary ? na : safeRatio(volume, volume[1])
float groupSum = math.sum(nz(volume), blockSize)
float missingGroup = math.sum(not validVolume ? 1 : 0, 2 * blockSize)
float groupBoundaries = math.sum(boundary ? 1 : 0, 2 * blockSize - 1)
bool groupReady = bar_index >= 2 * blockSize - 1 and missingGroup == 0 and groupBoundaries == 0
float groupRatio = groupReady ? safeRatio(groupSum, groupSum[blockSize]) : na
float volumeMedian = ta.median(volume[1], history)
float volumeHigh = ta.percentile_nearest_rank(volume[1], history, highPct)
float volumeLow = ta.percentile_nearest_rank(volume[1], history, lowPct)
float missingReference = math.sum(not validVolume ? 1 : 0, history)[1]
bool referenceReady = bar_index >= history and missingReference == 0
[span, bodyPart, upperPart, lowerPart, closePosition, progress] = candleShape(open, high, low, close, close[1])
float rangeMedian = ta.median(span[1], history)
float smallRange = ta.percentile_nearest_rank(span[1], history, smallPct)
float largeRange = ta.percentile_nearest_rank(span[1], history, largePct)
float rangeRatio = safeRatio(span, rangeMedian)
float progressRatio = safeRatio(progress, rangeMedian)
float openingGap = safeRatio(math.abs(open - close[1]), rangeMedian)
bool gapBar = openingGap > 0.5
bool timeForAnomaly = anomalyBasis == "Matching time when ready" and timeReady
float referenceVolume = timeForAnomaly ? clockMedian : volumeMedian
float referenceHigh = timeForAnomaly ? clockHigh : volumeHigh
float referenceLow = timeForAnomaly ? clockLow : volumeLow
float activityRatio = safeRatio(volume, referenceVolume)
bool usableReference = referenceReady and referenceVolume > 0 and rangeMedian > 0
float recentRatio = safeRatio(volume, volumeMedian)
bool highActivity = referenceReady and validVolume and volume > referenceHigh and activityRatio >= highMultiple
bool lowActivity = referenceReady and validVolume and volume < referenceLow and activityRatio <= lowMultiple
int anomalyCode = referenceReady and validVolume ? classify(highActivity, lowActivity, span <= smallRange, span >= largeRange, gapBar, rangeRatio, bodyPart, upperPart, lowerPart, closePosition, progressRatio, wickMin, bodyMin, edgeMax) : 0
int eventDirection = anomalyCode == 3 ? (lowerPart >= wickMin ? 1 : -1) : close > open ? 1 : close < open ? -1 : 0
int eventSignature = anomalyCode * 10 + (anomalyCode == 1 or anomalyCode == 0 ? 0 : eventDirection)
float pathDistance = math.sum(math.abs(close - close[1]), blockSize)
float groupEfficiency = groupReady ? safeRatio(math.abs(close - close[blockSize]), pathDistance) : na

clampHeight(float v) =>
    heightCap > 0 ? math.min(v, heightCap) : v

bool visibleBar = barstate.isconfirmed or livePreview
float heightValue = heightBasis == "Previous candle" ? previousRatio : heightBasis == "Recent typical" ? (referenceReady ? recentRatio : na) : timeRatio
color barColor = na(previousRatio) ? neutralColor : previousRatio > 1 + neutralPct / 100 ? risingColor : previousRatio < 1 - neutralPct / 100 ? fallingColor : neutralColor
plot(visibleBar ? clampHeight(heightValue) : na, "Selected volume comparison", color=color.new(barColor, barstate.isconfirmed ? 0 : 65), style=plot.style_columns)
plot(visibleBar and showGroup ? clampHeight(groupRatio) : na, "Group versus preceding group", color=color.new(lineColor, barstate.isconfirmed ? 0 : 65), linewidth=2, style=plot.style_linebr)
hline(1, "1× comparison baseline", color=color.gray, linestyle=hline.style_dashed)
bool clipped = heightCap > 0 and (heightValue > heightCap or (showGroup and groupRatio > heightCap))
plot(visibleBar and clipped ? heightCap : na, "Clipped: exact ratios in Data Window", color=color.orange, style=plot.style_circles, linewidth=2)
float markerY = math.max(nz(clampHeight(heightValue), 1), showGroup ? nz(clampHeight(groupRatio), 1) : 1) + 0.12
bool mark = barstate.isconfirmed and showEvents
plotshape(mark and anomalyCode == 1 ? markerY : na, title="Busy / stalled", style=shape.diamond, location=location.absolute, color=eventColor, text="S", textcolor=eventColor, size=size.tiny)
plotshape(mark and anomalyCode == 2 ? markerY : na, title="Busy / advancing", style=shape.diamond, location=location.absolute, color=eventColor, text="A", textcolor=eventColor, size=size.tiny)
plotshape(mark and anomalyCode == 3 ? markerY : na, title="Busy / rejection", style=shape.diamond, location=location.absolute, color=eventColor, text="R", textcolor=eventColor, size=size.tiny)
plotshape(mark and anomalyCode == 4 ? markerY : na, title="Large move / light volume", style=shape.diamond, location=location.absolute, color=eventColor, text="L", textcolor=eventColor, size=size.tiny)

plot(visibleBar ? previousRatio : na, "Exact · previous candle ×", display=display.data_window)
plot(visibleBar ? groupRatio : na, "Exact · group comparison ×", display=display.data_window)
plot(visibleBar ? timeRatio : na, "Exact · matching time ×", display=display.data_window)
plot(visibleBar and referenceReady ? recentRatio : na, "Exact · recent typical ×", display=display.data_window)
plot(visibleBar and referenceReady ? rangeRatio : na, "Exact · range versus typical ×", display=display.data_window)
plot(visibleBar and referenceReady ? progressRatio : na, "Exact · net progress / typical range", display=display.data_window)
plot(visibleBar ? bodyPart * 100 : na, "Exact · body % of range", display=display.data_window)
plot(visibleBar ? upperPart * 100 : na, "Exact · upper wick %", display=display.data_window)
plot(visibleBar ? lowerPart * 100 : na, "Exact · lower wick %", display=display.data_window)
plot(visibleBar ? volume : na, "Exact · feed volume", display=display.data_window)
plot(visibleBar ? clockCount : na, "Exact · matching prior days", display=display.data_window)
plot(barstate.isconfirmed ? anomalyCode : na, "Exact · event code (1=S, 2=A, 3=R, 4=L)", display=display.data_window)

bool alertEvent = barstate.isconfirmed and anomalyCode > 0 and (not newOnly or eventSignature != eventSignature[1])
alertcondition(alertEvent, "Any unusual volume / movement", "Volume & Movement: unusual completed candle on {{ticker}}, {{interval}}. Inspect the S/A/R/L marker.")
alertcondition(alertEvent and anomalyCode == 1, "S · Busy / stalled", "Volume & Movement: high volume with little price progress on {{ticker}}, {{interval}}.")
alertcondition(alertEvent and anomalyCode == 2, "A · Busy / advancing", "Volume & Movement: high volume with a large directional candle on {{ticker}}, {{interval}}.")
alertcondition(alertEvent and anomalyCode == 3, "R · Busy / rejection", "Volume & Movement: high volume with a dominant rejection wick on {{ticker}}, {{interval}}.")
alertcondition(alertEvent and anomalyCode == 4, "L · Large move / light volume", "Volume & Movement: large candle range on unusually light volume on {{ticker}}, {{interval}}.")

multiple(float v) =>
    na(v) ? "—" : str.tostring(v, "0.00") + "×"
percent(float v) =>
    na(v) ? "—" : str.tostring(v * 100, "0") + "%"
eventText(int code, int direction) =>
    string arrow = direction > 0 ? " ↑" : direction < 0 ? " ↓" : ""
    code == 1 ? "S · BUSY / STALLED" : code == 2 ? "A · BUSY / ADVANCING" + arrow : code == 3 ? "R · BUSY / REJECTION" + arrow : code == 4 ? "L · LARGE MOVE / LIGHT VOLUME" + arrow : "No unusual combination"

var table panel = table.new(position.top_right, 3, 13, bgcolor=color.rgb(21, 30, 40), border_width=0, frame_color=color.rgb(63, 78, 92), frame_width=1)
cell(int col, int row, string value, color ink) =>
    table.cell(panel, col, row, value, text_color=ink, text_size=size.small, text_halign=col == 0 ? text.align_left : text.align_right)

if barstate.isfirst
    table.merge_cells(panel, 0, 0, 2, 0)
    table.merge_cells(panel, 0, 7, 2, 7)
    table.merge_cells(panel, 0, 8, 2, 8)
    table.merge_cells(panel, 0, 12, 2, 12)
if barstate.islast
    table.clear(panel, 0, 0, 2, 12)
    if showTable
        int d = barstate.isconfirmed or livePreview ? 0 : 1
        color ink = color.rgb(232, 239, 245)
        color muted = color.rgb(161, 177, 191)
        string stamp = str.format_time(time[d], "EEE HH:mm", comparisonTZ)
        cell(0, 0, "VOLUME & MOVEMENT · " + timeframe.period + " · " + stamp + (d == 0 and not barstate.isconfirmed ? " · LIVE" : " · CLOSED"), ink)
        cell(0, 1, "COMPARISON", muted)
        cell(1, 1, "READING", muted)
        cell(2, 1, "CONTEXT", muted)
        cell(0, 2, "Previous candle", ink)
        cell(1, 2, multiple(previousRatio[d]), barColor[d])
        cell(2, 2, boundary[d] ? "Session boundary" : na(previousRatio[d]) ? "No valid comparison" : previousRatio[d] > 1 ? "More activity" : previousRatio[d] < 1 ? "Less activity" : "Unchanged", muted)
        cell(0, 3, str.tostring(blockSize) + " vs prior " + str.tostring(blockSize), ink)
        cell(1, 3, multiple(groupRatio[d]), ink)
        cell(2, 3, na(groupRatio[d]) ? "Need comparable groups" : groupRatio[d] > 1 ? "Building" : groupRatio[d] < 1 ? "Fading" : "Steady", muted)
        cell(0, 4, "Same clock time", ink)
        cell(1, 4, multiple(timeRatio[d]), ink)
        cell(2, 4, not useClock ? "Off" : not clockSupported ? "Use 1m–4h chart" : not fullDuration[d] ? "Partial candle" : str.tostring(clockCount[d]) + " days" + (not timeReady[d] ? " · warming" : ""), muted)
        cell(0, 5, "Candle range", ink)
        cell(1, 5, referenceReady[d] ? multiple(rangeRatio[d]) : "—", ink)
        cell(2, 5, "vs typical range", muted)
        cell(0, 6, "Net price progress", ink)
        cell(1, 6, referenceReady[d] ? multiple(progressRatio[d]) : "—", ink)
        cell(2, 6, "Close to prior close", muted)
        string status = not validVolume[d] ? "Volume unavailable from this feed" : not referenceReady[d] ? "Warming · need " + str.tostring(history) + " prior candles" : not usableReference[d] ? "Baseline unavailable · zero typical volume / range" : gapBar[d] ? "Opening price gap · shape classification skipped" : eventText(anomalyCode[d], eventDirection[d])
        cell(0, 7, status, anomalyCode[d] > 0 ? eventColor : muted)
        string referenceName = timeForAnomaly[d] ? "Matching time" : anomalyBasis == "Matching time when ready" ? "Recent baseline · time warming / unavailable" : "Recent baseline"
        cell(0, 8, referenceName + " · " + (referenceReady[d] ? multiple(activityRatio[d]) : "—") + " volume", ink)
        if detailed
            cell(0, 9, "Body / upper / lower wick", muted)
            cell(1, 9, percent(bodyPart[d]), ink)
            cell(2, 9, percent(upperPart[d]) + " / " + percent(lowerPart[d]), ink)
            cell(0, 10, "Group net / travelled distance", muted)
            cell(1, 10, percent(groupEfficiency[d]), ink)
            cell(2, 10, "100% = one direction", muted)
            cell(0, 11, "Feed volume", muted)
            cell(1, 11, str.tostring(volume[d], format.volume), ink)
            cell(2, 11, syminfo.volumetype, muted)
        cell(0, 12, "Colours = volume change, not buying / selling · " + comparisonTZ, muted)
````
