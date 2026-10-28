# Volume Stats Dashboard

- url: https://www.tradingview.com/script/jj0GicRG-Volume-Stats-Dashboard/
- type: indicator
- pine_id: PUB;533f35770cc1423ead6a85eb39eb0f9f
- version: 1.0

## Description

# Volume Stats Dashboard

Volume Stats is a compact **dashboard over the price chart** that compares today's volume with historical session patterns and estimates end-of-day volume.

## Getting started

Add the indicator to a standard time-based **1-minute through 1-hour chart** of a symbol with daily and intraday volume. Some cash indexes may not supply volume; use a volume-bearing symbol when the dashboard reports missing data.

## Model and controls

- The prior 20 valid daily volumes set the baseline; today's daily bar is excluded.
- A regular-session 15-minute feed builds 26 buckets from **09:30 to 16:00 America/New_York**, independent of chart timeframe and extended-hours display.
- The last 10 observed prior sessions supply each bucket's median or mean. At least three valid samples per bucket are required. Partial sessions can reduce available depth; early-close days still use the fixed 16:00 model.
- Expected volume is daily average multiplied by elapsed profile fraction. A forming bucket contributes its **whole expected bucket**, not a minute-prorated fraction.
- Projected volume is today's daily volume divided by that fraction. Projection starts at **5%** of the profile and is considered settled at **20%**.
- Today's bucket volume is scaled by daily volume / elapsed intraday volume. The summary uses only completed buckets and caps RVOL at **300%**.
- Tier boundaries: below 50% red, 50-79% yellow, 80-89% orange, 90-105% green, above 105% lime.
- Seven themes, panel visibility, bucket summary, state banner, footer timestamp, UI scale, profile settings, and alert thresholds remain configurable. UI scale uses font-size presets rather than exact pixel sizing.
- **Volume Days** defaults to 20; **Stats Profile Days** defaults to 10; **Profile Collapse** defaults to Median.

The dashboard presents numeric summaries rather than separate volume curves, fan bands, projection drawings, or RVOL bar charts.

## Dashboard rows

| Row | Meaning |
| --- | --- |
| Ticker / VOLUME STATS | Centered header spanning both columns. |
| Large percentage | Projected end-of-day volume as a percentage of the daily average, with tier coloring after the projection settles. |
| Projected | Estimated end-of-day volume. |
| Daily avg | Average daily volume and the number of valid days used. |
| Normal vs Expected | Today's volume minus expected volume at the current profile point, followed by the signed percentage difference relative to expected volume. |
| Today / profile elapsed | Today's daily volume and the percentage of the volume profile elapsed, not the percentage of clock time elapsed. |
| Peak bucket RVOL | Start time and scaled RVOL of the strongest completed 15-minute bucket, capped at 300%. |
| Completed above avg | Completed buckets above 100% RVOL out of the completed buckets with valid data. |
| State banner | Full-width status: HEAVY DAY TRACKING, ON STATS, SLIGHTLY LIGHT, LIGHT TAPE, DEAD TAPE, or a data/warmup message. |
| Footer timestamp | Optional full-width timestamp in New York time. Disabled by default. |

The header, large percentage, state banner, and footer span both columns. Optional bucket, banner, and footer rows are allocated only when enabled, so disabling them leaves no blank rows.

## Alerts and data behavior

Configure an alert using **Volume Stats Negative** or **Projected Volume Above Average**. They use the rounded projected percentage with strict comparisons: below 90% and above 100% by default. They are state conditions, not one-time threshold crossings. Chart-bar-close evaluation is enabled by default and can be disabled.

The model does not use future daily volume in historical intraday signals. On live bars, developing daily volume and the current 15-minute bucket update as the feed updates. On historical intraday bars, the current daily value is normally available only at the daily close, so this dashboard is **not a reconstruction of historical intraday composite-volume projections**. Historical readings should not be assumed to reproduce live snapshots. Developing values can change before confirmation; bar-close alerts do not freeze a still-developing higher-timeframe feed.

Daily and intraday volume may differ across data providers. Identical numbers across feeds are not guaranteed. The fixed US cash-session model is not appropriate for 24-hour markets or other exchange sessions without adaptation.

## Verification

Before relying on the dashboard, confirm the default display, Median/Mean changes, missing-volume messages, panel visibility, full-width rows, no gaps when optional rows are disabled, the **Normal vs Expected** label, footer, and both alert conditions using a live volume feed.

## Source Code

````pine
// Created by @VietRoadie
// Last Updated: 2026-10-09 19:50 CST
//@version=6
indicator("Volume Stats Dashboard", shorttitle = "Volume Stats", overlay = true, dynamic_requests = true)

int volDays = input.int(20, "Volume Days", minval=1, maxval=200, group="Model")
int profileDays = input.int(10, "Stats Profile Days", minval=3, maxval=20, group="Model")
string profileMode = input.string("Median", "Profile Collapse", options=["Median", "Mean"], group="Model")
string theme = input.string("The Rock", "Theme", options=["The Rock", "Midnight", "Carbon", "Ocean", "Solar", "Light", "Paper"], group="Dashboard")
int uiScale = input.int(100, "UI Scale (%)", minval=50, maxval=200, step=5, group="Dashboard")
bool showPanel = input.bool(true, "Show Panel", group="Dashboard")
bool showBuckets = input.bool(true, "Bucket Summary", group="Dashboard")
bool showBanner = input.bool(true, "State Banner", group="Dashboard")
bool showFooter = input.bool(false, "Footer Timestamp", group="Dashboard")
float heavySigPct = input.float(100, "Heavy Signal (% of avg)", minval=1, maxval=500, step=5, group="Alerts")
float lightSigPct = input.float(90, "Light Signal (% of avg)", minval=1, maxval=200, step=5, group="Alerts")
bool closeOnly = input.bool(true, "Alerts On Chart Bar Close", group="Alerts")

const string TZ = "America/New_York"
const int OPEN = 570
const int CLOSE = 960
const int BUCKETS = 26
const float MIN_PROJ_FRAC = 0.05
const float SETTLED_FRAC = 0.20

dayKey(int stamp) =>
    year(stamp, TZ) * 10000 + month(stamp, TZ) * 100 + dayofmonth(stamp, TZ)

minuteOfDay(int stamp) =>
    hour(stamp, TZ) * 60 + minute(stamp, TZ)

dailyData() =>
    var array<float> prior = array.new<float>()
    if not na(volume[1])
        prior.push(volume[1])
        if prior.size() > volDays
            prior.shift()
    [time, volume, prior.size() > 0 ? prior.avg() : na, prior.size()]

// This state lives on a fixed regular-session 15-minute feed, not the chart feed.
statsData() =>
    var matrix<float> history = matrix.new<float>(0, BUCKETS)
    var array<float> today = array.new<float>(BUCKETS, na)
    var array<float> profile = array.new<float>(BUCKETS, na)
    var int activeDay = na
    var int depth = 0
    var float profileTotal = na
    int key = dayKey(time)
    if na(activeDay) or key != activeDay
        if not na(activeDay) and not na(today.sum())
            history.add_row(history.rows(), today)
            if history.rows() > profileDays
                history.remove_row(0)
        today := array.new<float>(BUCKETS, na)
        activeDay := key
        depth := history.rows()
        profileTotal := 0.0
        for bucket = 0 to BUCKETS - 1
            array<float> samples = array.new<float>()
            if history.rows() > 0
                for row = 0 to history.rows() - 1
                    float value = history.get(row, bucket)
                    if not na(value)
                        samples.push(value)
            depth := math.min(depth, samples.size())
            float typical = samples.size() > 0 ? (profileMode == "Median" ? samples.median() : samples.avg()) : na
            profile.set(bucket, typical)
            profileTotal += nz(typical)
    int startMinute = minuteOfDay(time)
    int bucketIndex = int(math.floor((startMinute - OPEN) / 15))
    if startMinute >= OPEN and startMinute < CLOSE and bucketIndex >= 0 and bucketIndex < BUCKETS
        today.set(bucketIndex, volume)
    int cutoff = math.min(minuteOfDay(time_close), CLOSE)
    if dayKey(timenow) == key and timenow >= time and timenow < time_close
        cutoff := math.min(minuteOfDay(timenow), CLOSE)
    float elapsed = 0.0
    float intraSum = 0.0
    for bucket = 0 to BUCKETS - 1
        if OPEN + bucket * 15 < cutoff
            elapsed += nz(profile.get(bucket))
            intraSum += nz(today.get(bucket))
    float fraction = depth >= 3 and profileTotal > 0 ? math.min(1.0, math.max(0.0, elapsed / profileTotal)) : na
    // Return collections only for the current snapshot to avoid copying history
    // arrays into every chart bar.
    [key, cutoff, fraction, intraSum, depth, profileTotal, barstate.islast ? today.copy() : na, barstate.islast ? profile.copy() : na]

string regularTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)
[dailyTime, dailyVolume, averageVolume, averageCount] = request.security(regularTicker, "D", dailyData(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[referenceDay, cutoff, shapeFraction, intraSum, profileDepth, profileTotal, todayBuckets, profileBuckets] = request.security(regularTicker, "15", statsData(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bool validTimeframe = timeframe.isintraday and timeframe.in_seconds() >= 60 and timeframe.in_seconds() <= 3600
bool sameSession = not na(dailyTime) and dayKey(dailyTime) == dayKey(time) and referenceDay == dayKey(time)
float todayVolume = sameSession ? dailyVolume : na
bool depthOK = profileDepth >= 3 and profileTotal > 0
float expectedByNow = validTimeframe and depthOK and averageVolume > 0 and not na(todayVolume) ? averageVolume * shapeFraction : na
float volumeStats = not na(expectedByNow) ? todayVolume - expectedByNow : na
float statsPct = expectedByNow > 0 ? volumeStats / expectedByNow * 100 : na
float projectedVolume = not na(expectedByNow) and shapeFraction >= MIN_PROJ_FRAC and todayVolume > 0 ? todayVolume / shapeFraction : na
float projectedPct = not na(projectedVolume) ? math.round(projectedVolume / averageVolume * 100) : na
bool settled = not na(projectedPct) and shapeFraction >= SETTLED_FRAC

color bg = switch theme
    "Midnight" => #0d1117
    "Carbon" => #0e0e10
    "Ocean" => #06202a
    "Solar" => #221810
    "Light" => #f7f8fa
    "Paper" => #f5efe2
    => #2a353b
color accent = switch theme
    "Midnight" => #1f6feb
    "Carbon" => #3a3a40
    "Ocean" => #1f7a8c
    "Solar" => #b8690f
    "Light" => #1a56b0
    "Paper" => #3d5a80
    => #6200ff
color muted = switch theme
    "Midnight" => #8b949e
    "Carbon" => #7a7a80
    "Ocean" => #6fa3b0
    "Solar" => #c9a878
    "Light" => #5a6473
    "Paper" => #8a7f6a
    => #b9c4cc
color textColor = switch theme
    "Midnight" => #e6edf3
    "Carbon" => #dcdce0
    "Ocean" => #e0f2f5
    "Solar" => #f5ead6
    "Light" => #1c2430
    "Paper" => #2b2418
    => #ffffff
color up = theme == "The Rock" ? #00a000 : #26a65b
color down = theme == "The Rock" ? #e01414 : #e74c3c
color yellow = theme == "Light" ? #c9a227 : theme == "Paper" ? #b8860b : #ffd54a
color orange = theme == "Paper" ? #e07b1f : #ff9d3c
color lime = theme == "Light" or theme == "Paper" ? #4caf50 : #7ed957

tierColor(float pct) =>
    na(pct) ? muted : pct > 105 ? lime : pct >= 90 ? up : pct >= 80 ? orange : pct >= 50 ? yellow : down

tierText(color tier) =>
    tier == yellow or tier == lime or tier == orange ? #14181c : color.white

fmtVolume(float value) =>
    na(value) ? "-" : math.abs(value) >= 1e9 ? str.tostring(value / 1e9, "0.00") + " B" : math.abs(value) >= 1e6 ? str.tostring(value / 1e6, "0.0") + " M" : math.abs(value) >= 1e3 ? str.tostring(value / 1e3, "0") + " K" : str.tostring(value, "0")

fmtSigned(float value) =>
    na(value) ? "-" : (value >= 0 ? "+" : "-") + fmtVolume(math.abs(value))

fmtPct(float value) =>
    na(value) ? "-" : (value >= 0 ? "+" : "-") + str.tostring(math.abs(value), "0") + "%"

string state = not validTimeframe ? "USE A 1m-1H CHART" : na(todayVolume) ? "NO DAILY VOLUME" : na(averageVolume) or averageVolume <= 0 ? "NO DAILY AVERAGE" : not depthOK ? "PROFILE TOO THIN" : na(projectedPct) ? "WAITING FOR OPEN" : not settled ? "PROJECTION SETTLING - " + str.tostring(projectedPct, "0") + "%" : (projectedPct > 105 ? "HEAVY DAY TRACKING" : projectedPct >= 90 ? "ON STATS" : projectedPct >= 80 ? "SLIGHTLY LIGHT" : projectedPct >= 50 ? "LIGHT TAPE" : "DEAD TAPE") + " - " + str.tostring(projectedPct, "0") + "% OF AVG"
color heroColor = settled ? tierColor(projectedPct) : muted
color statsColor = na(volumeStats) ? muted : volumeStats >= 0 ? up : down
string bodySize = uiScale <= 75 ? size.tiny : uiScale <= 110 ? size.small : uiScale <= 150 ? size.normal : size.large
string heroSize = uiScale <= 75 ? size.large : size.huge

int bannerRow = 6 + (showBuckets ? 2 : 0)
int footerRow = bannerRow + (showBanner ? 1 : 0)
int panelRows = footerRow + (showFooter ? 1 : 0)
var table panel = table.new(position.top_right, 2, panelRows, frame_color=accent, frame_width=2)
if barstate.islast
    table.clear(panel, 0, 0, 1, panelRows - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.merge_cells(panel, 0, 1, 1, 1)
    if showBanner
        table.merge_cells(panel, 0, bannerRow, 1, bannerRow)
    if showFooter
        table.merge_cells(panel, 0, footerRow, 1, footerRow)
    if showPanel
        table.cell(panel, 0, 0, syminfo.ticker + " | VOLUME STATS", bgcolor=accent, text_color=color.white, text_size=bodySize, text_halign=text.align_center)
        table.cell(panel, 0, 1, na(projectedPct) ? "-" : str.tostring(projectedPct, "0") + "%", bgcolor=heroColor, text_color=tierText(heroColor), text_size=heroSize)
        table.cell(panel, 0, 2, "Projected", bgcolor=bg, text_color=textColor, text_size=bodySize)
        table.cell(panel, 1, 2, fmtVolume(projectedVolume), bgcolor=bg, text_color=textColor, text_size=bodySize)
        table.cell(panel, 0, 3, str.tostring(averageCount) + "d daily avg", bgcolor=bg, text_color=muted, text_size=bodySize)
        table.cell(panel, 1, 3, fmtVolume(averageVolume), bgcolor=bg, text_color=textColor, text_size=bodySize)
        table.cell(panel, 0, 4, "Normal vs Expected", bgcolor=bg, text_color=textColor, text_size=bodySize)
        table.cell(panel, 1, 4, fmtSigned(volumeStats) + " / " + fmtPct(statsPct), bgcolor=bg, text_color=statsColor, text_size=bodySize)
        table.cell(panel, 0, 5, "Today / profile elapsed", bgcolor=bg, text_color=textColor, text_size=bodySize)
        table.cell(panel, 1, 5, fmtVolume(todayVolume) + " / " + (na(expectedByNow) ? "-" : str.tostring(shapeFraction * 100, "0") + "%"), bgcolor=bg, text_color=textColor, text_size=bodySize)
        if showBuckets
            int completed = 0
            int above = 0
            int peakBucket = na
            float peak = na
            float ratio = sameSession and intraSum > 0 ? todayVolume / intraSum : na
            if validTimeframe and depthOK and averageVolume > 0 and not na(ratio) and not na(todayBuckets) and not na(profileBuckets)
                for bucket = 0 to BUCKETS - 1
                    if OPEN + (bucket + 1) * 15 <= cutoff
                        float expectedBucket = averageVolume * profileBuckets.get(bucket) / profileTotal
                        float actualBucket = todayBuckets.get(bucket)
                        float pct = expectedBucket > 0 and not na(actualBucket) ? math.min(300.0, actualBucket * ratio / expectedBucket * 100) : na
                        if not na(pct)
                            completed += 1
                            above += pct > 100 ? 1 : 0
                            if na(peak) or pct > peak
                                peak := pct
                                peakBucket := bucket
            int peakMinute = na(peakBucket) ? na : OPEN + peakBucket * 15
            string peakTime = na(peakMinute) ? "-" : str.tostring(int(peakMinute / 60), "00") + ":" + str.tostring(peakMinute % 60, "00")
            table.cell(panel, 0, 6, "Peak bucket RVOL", bgcolor=bg, text_color=textColor, text_size=bodySize)
            table.cell(panel, 1, 6, na(peak) ? "-" : peakTime + " / " + str.tostring(peak, "0") + "%", bgcolor=bg, text_color=tierColor(peak), text_size=bodySize)
            table.cell(panel, 0, 7, "Completed above avg", bgcolor=bg, text_color=muted, text_size=bodySize)
            table.cell(panel, 1, 7, str.tostring(above) + " of " + str.tostring(completed), bgcolor=bg, text_color=textColor, text_size=bodySize)
        if showBanner
            table.cell(panel, 0, bannerRow, state, bgcolor=heroColor, text_color=tierText(heroColor), text_size=bodySize)
        if showFooter
            table.cell(panel, 0, footerRow, str.format_time(timenow, "MM/dd/yy HH:mm:ss", TZ) + " NY", bgcolor=bg, text_color=muted, text_size=bodySize)

bool alertGate = not closeOnly or barstate.isconfirmed
alertcondition(alertGate and not na(projectedPct) and projectedPct < lightSigPct, "Volume Stats Negative", "Projected daily volume is below the configured light threshold on {{ticker}}.")
alertcondition(alertGate and not na(projectedPct) and projectedPct > heavySigPct, "Projected Volume Above Average", "Projected daily volume is above the configured heavy threshold on {{ticker}}.")
````
