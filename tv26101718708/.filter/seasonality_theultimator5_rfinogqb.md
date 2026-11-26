# Seasonality [theUltimator5]

- url: https://www.tradingview.com/script/RfINOGQb-Seasonality-theUltimator5/
- type: indicator
- pine_id: PUB;83793c57418d4f8fba714e342ed54aef
- version: 1.0

## Description

Seasonality is a unique multi-timeframe price-pattern indicator that projects the typical historical path of an asset through the current year, month, week, or trading day.

Rather than averaging raw prices, this indicator normalizes each historical period to its opening value. This allows periods with very different price levels to be compared on an equal basis. The normalized historical paths are then combined using either the median or arithmetic mean to create a 'seasonal' curve.  The term 'seasonal' is used loosely since that generally applies to the yearly trends, but this indicator can break down the chart into shorter timeframes to show periodic trends rather than just yearly ones.

The current-period curve is projected forward across the chart, providing a visual estimate of where price has historically tended to strengthen, weaken, consolidate, or reverse during comparable portions of previous periods.


The indicator supports four profiling modes:

1) [b]Yearly[/b]: Uses daily bars to compare the current year with previous years.
2) [b]Monthly[/b]: Uses hourly bars to compare the current month with previous months.
3) [b]Weekly[/b]: Uses 30-minute bars to compare the current week with previous weeks.
4) [b]Daily[/b]: Uses 5-minute bars to compare the current trading day with previous trading days.

Each mode should be used on a chart timeframe at or below its native calculation timeframe:

Yearly: 4-hour through daily charts
Monthly: 15-minute through hourly charts
Weekly: 5-minute through 30-minute charts
Daily: 1-minute through 5-minute charts

A warning is displayed when the selected chart timeframe is outside the recommended range.


The seasonal pattern is calculated from a rolling historical window.
For example, a lookback of 20 in Yearly mode uses up to the previous 20 years. A lookback of 20 in Daily mode uses the previous 20 observed trading days.

The calculation only includes periods that actually traded during each seasonal slot. Holidays, missing sessions, shortened sessions, and unavailable bars are excluded rather than treated as zero values.


[b]Two averaging methods are available:[/b]

1) [b]Median[/b] is the default method. The median reduces the influence of unusually strong or weak historical periods and often produces a more representative seasonal path.

2) [b]Mean[/b] calculates the standard arithmetic average of all available historical observations. This method is more responsive to extreme historical moves and is not recommended on symbols that have experienced volatility on a lookback time period orders of magnitude higher than the other periods.  It will completely blow out the chart and skew it towards that single outlier period.


The indicator includes three methods for positioning the normalized seasonal curve on the current price chart.

1) [b]Scale Only (Default)[/b]
The seasonal curve is vertically rescaled so its projected high-to-low range matches the actual high-to-low range of either the current or previous period.
The curve remains anchored to the current period’s first close.
This retains the historical seasonal shape while adapting its magnitude to the asset’s recent volatility.

2) [b]Chained — No Fit[/b]
The original normalized seasonal path is anchored to the first close of the current period.
Historical curves are chained together so the end of one period connects continuously with the beginning of the next. No additional adjustment is made to match the asset’s current trading range.

3) [b]Rotate & Scale[/b]
This mode applies the same range adjustment as Scale Only, then gradually rotates the current-period curve so it passes through the live price at the current bar.
The adjustment begins at zero near the start of the period and increases progressively toward the current bar. This allows the future seasonal path to remain connected to current price without abruptly shifting the entire curve.
Because this mode incorporates the live price, the projected curve can change as the current period develops.


When using Scale Only or Rotate & Scale, the user can choose which actual price range controls the vertical scaling.

1) [b]Current Period[/b] uses the developing high and low of the current year, month, week, or day.
The curve may rescale as new highs or lows occur.

2) [b]Previous Period[/b] uses the completed high and low of the prior period.
This creates a more stable projection that does not continually rescale during the current period.


The Draw Curve Back setting controls how many completed periods are displayed behind the current seasonal projection.

Historical seasonal curves are shown in gray and are chained together into a continuous path. The current period is displayed separately using the selected seasonality color.

Displaying previous curves can help identify how the rolling seasonal model evolved over time and whether the current projection is consistent with earlier versions of the model.

Higher draw-back settings may require more processing, particularly on intraday charts.

[b]Smoothing[/b]

A trailing simple moving average can be applied along the seasonal curve.
A smoothing value of 1 disables smoothing. Higher values reduce short-term noise but may also soften or delay smaller seasonal turning points.

[b]Min/Max Envelope[/b]

The minimum and maximum lines show the strongest and weakest normalized historical paths observed at each seasonal point within the selected lookback.
These lines use the same normalization, chaining, smoothing, scaling, and rotation calculations as the primary seasonal curve.

Because different slots may contain different sample sizes, the minimum and maximum lines should be interpreted as a historical range rather than a guaranteed boundary.

[b]Current-Period Projection[/b]

For completed portions of the current period, the curve is aligned with actual timestamps.

For seasonal slots that have not yet occurred, the indicator projects timestamps forward so the curve extends into the future.


Seasonality describes recurring historical tendencies. It does not predict that price must follow the displayed curve.

## Source Code

````pine
//@version=6
indicator("Seasonality [theUltimator5]", overlay=true, max_polylines_count=10)


// INPUTS

seasonTF = input.string("Yearly (1D bars)", "Seasonality timeframe",
     options=["Yearly (1D bars)", "Monthly (1h bars)", "Weekly (30m bars)", "Daily (5m bars)"],
     tooltip="The period being profiled and the bar size used to build it. " +
     "Apply the indicator on a chart at or below the matching timeframe (1D / 1h / 30m / 5m).")

lookbackPeriods = input.int(20, "Lookback (periods)", minval=1, maxval=50,
     tooltip="Rolling window in PERIODS of the selected seasonality timeframe: years for Yearly, " +
     "months for Monthly, weeks for Weekly, trading days for Daily. The curve drawn on period P is " +
     "built from the prior N observed periods. Each slot uses however many of those periods actually " +
     "traded at that time — holidays/half-days are excluded from the sample.")

drawBackPeriods = input.int(10, "Draw curve back (periods)", minval=0, maxval=50,
     tooltip="How many previous periods to draw the seasonal curve across, in addition to the current one. " +
     "Large values on intraday timeframes can be slow.")

avgMethod = input.string("Median", "Average method", options=["Median", "Mean"],
     tooltip="Median is robust to outlier periods. Mean is the plain arithmetic average.")

smoothLen = input.int(5, "Smoothing (bars)", minval=1, maxval=30,
     tooltip="Simple moving average applied along the seasonal curve. 1 = no smoothing.")

scaleMode = input.string("Scale Only", "Fit mode",
     options=["Chained (no fit)", "Scale Only", "Rotate & Scale"],
     tooltip="Chained: original behavior, curve anchored to the current period's first close only. " +
     "Scale Only: the current period's curve is rescaled so its high-low span matches the actual " +
     "high-low of the range source, anchored at the period's first close. " +
     "Rotate & Scale: same, plus the curve is rotated so it also passes through the CURRENT price " +
     "at the current bar.")

rangeSource = input.string("Current period", "Fit range source",
     options=["Current period", "Previous period"],
     tooltip="Which period's actual high/low defines the fit scale. Current period grows/re-fits as the " +
     "period develops; Previous period gives a stable scale from the completed prior year/month/week/day.")

seasColor  = input.color(color.aqua, "Current period seasonality")
pastColor  = input.color(color.new(color.gray, 30), "Past periods seasonality")

glowOn = input.bool(true, "Glow on current period line",
     tooltip="Draws soft, transparent halo layers behind the current period's curve.")

showMinMax = input.bool(false, "Show min/max lines", group="Min/Max Envelope",
     tooltip="Draws the minimum and maximum seasonal paths across the same lookback sample " +
     "the average curve is built from. Shows the historical best/worst case at each point " +
     "in the period. Uses the same normalization, chaining, smoothing, and fit transform " +
     "as the main curve.")
maxColor = input.color(color.new(color.green, 40), "Max line color", group="Min/Max Envelope")
minColor = input.color(color.new(color.red, 40), "Min line color", group="Min/Max Envelope")

showSettings = input.bool(true, "Show settings table", group="Settings Table")
settingsPos  = input.string("top_right", "Table position", group="Settings Table",
     options=["top_left", "top_center", "top_right", "middle_left", "middle_right",
     "bottom_left", "bottom_center", "bottom_right"])
tblTextColor = input.color(color.white, "Table text color", group="Settings Table")
tblBgColor   = input.color(color.new(color.rgb(30, 34, 45), 15), "Table background", group="Settings Table")


// MODE / TIMEFRAME SETUP
// Translate the selected seasonality mode into the data timeframe to request, its bar size in seconds, and the minimum chart timeframe that's acceptable for that mode.

modeYearly  = seasonTF == "Yearly (1D bars)"
modeMonthly = seasonTF == "Monthly (1h bars)"
modeWeekly  = seasonTF == "Weekly (30m bars)"

reqTF  = modeYearly ? "D" : modeMonthly ? "60" : modeWeekly ? "30" : "5"
reqSec = modeYearly ? 86400 : modeMonthly ? 3600 : modeWeekly ? 1800 : 300
minSec = modeYearly ? 14400 : modeMonthly ? 900 : modeWeekly ? 300 : 60   // lowest acceptable chart TF

// Pull close/high/low from the mode's native timeframe, regardless of chart TF
sym = syminfo.tickerid
[pxC, pxH, pxL] = request.security(sym, reqTF, [close, high, low])


// PERIOD & SLOT KEYS
// Each bar is assigned to a period (which year / month / week / day it belongs to) and a slot (its position WITHIN that period,
// e.g. "March 15" or "Tuesday 10:30"). Slots let us line up the same moment across many historical periods.

dNum = int(math.floor(timestamp("UTC", year, month, dayofmonth, 0, 0) / 86400000.0))
wd   = (dNum + 4) % 7                          // day of week (0 = Sunday)
wkIdx = int(math.floor((dNum + 4) / 7.0))      // running week index

perId = modeYearly  ? year :
     modeMonthly ? year * 12 + (month - 1) :
     modeWeekly  ? wkIdx : dNum

slotId = modeYearly  ? month * 100 + dayofmonth :
     modeMonthly ? dayofmonth * 10000 + hour * 100 + minute :
     modeWeekly  ? wd * 10000 + hour * 100 + minute :
     hour * 100 + minute

// Data collection
// Persistent maps/arrays that accumulate history bar by bar:
//   closeMap/timeMap        : close & timestamp per (period, slot) key
//   firstCloseMap/firstTime : first close & time of each period (anchor)
//   hiMap/loMap             : running high/low of each period (for fit scaling)
//   slotsArr                : sorted list of every slot ever seen
//   periodsSeen             : ordered list of every period ever seen
var closeMap      = map.new<int, float>()
var timeMap       = map.new<int, int>()
var firstCloseMap = map.new<int, float>()
var firstTimeMap  = map.new<int, int>()
var hiMap         = map.new<int, float>()
var loMap         = map.new<int, float>()
var slotSeen      = map.new<int, bool>()
var slotsArr      = array.new<int>()
var periodsSeen   = array.new<int>()
var int lastP     = na

// Binary-search insert that keeps slotsArr sorted with no duplicates
insertSortedUnique(array<int> arr, int v) =>
    lo = 0
    hi = arr.size()
    while lo < hi
        mid = int(math.floor((lo + hi) / 2.0))
        if arr.get(mid) < v
            lo := mid + 1
        else
            hi := mid
    if lo >= arr.size() or arr.get(lo) != v
        arr.insert(lo, v)

// On every bar with data: record close/time under a combined period+slot key,
// track first close, running high/low, and register new periods/slots.
if not na(pxC)
    keyPS = perId * 1000000 + slotId
    closeMap.put(keyPS, pxC)
    timeMap.put(keyPS, time)
    if not slotSeen.contains(slotId)
        slotSeen.put(slotId, true)
        insertSortedUnique(slotsArr, slotId)
    if not firstCloseMap.contains(perId)
        firstCloseMap.put(perId, pxC)
        firstTimeMap.put(perId, time)
    hiMap.put(perId, hiMap.contains(perId) ? math.max(hiMap.get(perId), pxH) : pxH)
    loMap.put(perId, loMap.contains(perId) ? math.min(loMap.get(perId), pxL) : pxL)
    if na(lastP) or perId != lastP
        periodsSeen.push(perId)
        lastP := perId


// SEASONAL SHAPE BUILDER
// For a given period index, walk every slot and average (median/mean) the values from the prior N lookback periods.
// Also records the min and max sample at each slot for the envelope.
// Values are relative (close / period's first close) when normalized.

type PShape
    array<int>   slots
    array<float> rs
    array<float> rsMin
    array<float> rsMax

buildShape(int pi, int lb, bool useMedian) =>
    sh = PShape.new(array.new<int>(), array.new<float>(), array.new<float>(), array.new<float>())
    if pi > 0 and slotsArr.size() > 0
        loP = math.max(0, pi - lb)
        for si = 0 to slotsArr.size() - 1
            slot = slotsArr.get(si)
            samples = array.new<float>()
            for k = loP to pi - 1
                pp = periodsSeen.get(k)
                v = closeMap.get(pp * 1000000 + slot)
                if not na(v)
                    a = firstCloseMap.get(pp)
                    if not na(a) and a != 0
                        samples.push(v / a)
            if samples.size() > 0
                sh.slots.push(slot)
                sh.rs.push(useMedian ? samples.median() : samples.avg())
                sh.rsMin.push(samples.min())
                sh.rsMax.push(samples.max())
    sh

// Simple trailing moving average along an array (used to smooth the curve)
smoothArr(array<float> src, int len) =>
    out = array.new<float>()
    n = src.size()
    if n > 0
        for i = 0 to n - 1
            if len <= 1
                out.push(src.get(i))
            else
                start = math.max(0, i - len + 1)
                s = 0.0
                for j = start to i
                    s += src.get(j)
                out.push(s / (i - start + 1))
    out

// Polyline handles kept between redraws so old lines can be deleted
var polyline pastLine  = na
var polyline curLine   = na
var polyline glowLine1 = na
var polyline glowLine2 = na
var polyline glowLine3 = na
var polyline minLine   = na
var polyline maxLine   = na

// MAIN DRAWING
// Runs only on the last bar. Deletes previous polylines,
// builds a seasonal shape for each drawn period, chains/scales them into one
// continuous series, applies smoothing and the selected fit transform, then
// draws the past curve, current curve (+glow), and optional min/max envelope.

if barstate.islast
    // Clear the previous frame's drawings
    if not na(pastLine)
        polyline.delete(pastLine)
    if not na(curLine)
        polyline.delete(curLine)
    if not na(glowLine1)
        polyline.delete(glowLine1)
    if not na(glowLine2)
        polyline.delete(glowLine2)
    if not na(glowLine3)
        polyline.delete(glowLine3)
    if not na(minLine)
        polyline.delete(minLine)
    if not na(maxLine)
        polyline.delete(maxLine)

    useMedian = avgMethod == "Median"
    nP = periodsSeen.size()
    if nP > 0
        curIdxP  = nP - 1
        startIdx = math.max(0, curIdxP - drawBackPeriods)
        curPer   = periodsSeen.get(curIdxP)

        // Build one seasonal shape per period in the draw-back window
        shapes = array.new<PShape>()
        pIdxA  = array.new<int>()
        for pi = startIdx to curIdxP
            sh = buildShape(pi, lookbackPeriods, useMedian)
            if sh.rs.size() > 0
                shapes.push(sh)
                pIdxA.push(pi)

        nY = shapes.size()
        if nY > 0
            // Chaining: compute a price scale per period so consecutive
            // period curves connect end-to-start into one continuous line.
            // The current period anchors at its actual first close; earlier
            // periods are scaled backwards from there.
            scales = array.new<float>(nY, 1.0)
            lastI = nY - 1
            aCur = firstCloseMap.get(periodsSeen.get(pIdxA.get(lastI)))
            scLast = na(aCur) ? 1.0 : aCur
            scales.set(lastI, scLast)
            nextStartVal = scLast * shapes.get(lastI).rs.get(0)
            if nY > 1
                for i = nY - 2 to 0
                    sh = shapes.get(i)
                    rEnd = sh.rs.get(sh.rs.size() - 1)
                    sc = rEnd != 0 ? nextStartVal / rEnd : 1.0
                    scales.set(i, sc)
                    nextStartVal := sc * sh.rs.get(0)

            // Flatten every period's shape into single x/y arrays.
            // Past periods use their real bar timestamps. For the current
            // period, slots that haven't traded yet get projected timestamps
            // (from calendar math for Yearly, or from the previous period's
            // times shifted forward for intraday modes) so the curve extends
            // into the future. Weekends are skipped in Yearly mode.
            allXs    = array.new<int>()
            allVs    = array.new<float>()
            allVsMin = array.new<float>()
            allVsMax = array.new<float>()
            int curStartIdx = na
            int nowPosAll   = na
            for i = 0 to nY - 1
                sh = shapes.get(i)
                sc = scales.get(i)
                p  = periodsSeen.get(pIdxA.get(i))
                if pIdxA.get(i) == curIdxP
                    curStartIdx := allXs.size()
                    int lastRealSlot = na
                    int lastRealTime = na
                    for j = 0 to sh.slots.size() - 1
                        k = p * 1000000 + sh.slots.get(j)
                        if timeMap.contains(k)
                            lastRealSlot := sh.slots.get(j)
                            lastRealTime := timeMap.get(k)
                    if na(lastRealSlot)
                        lastRealSlot := -1
                        lastRealTime := time

                    // Offset between this period's start and the previous one,
                    // used to project future timestamps in intraday modes
                    int prevPerRef = curIdxP > 0 ? periodsSeen.get(curIdxP - 1) : na
                    int perOffset  = na
                    if not na(prevPerRef) and firstTimeMap.contains(p) and firstTimeMap.contains(prevPerRef)
                        perOffset := firstTimeMap.get(p) - firstTimeMap.get(prevPerRef)
                    int lastX = lastRealTime
                    for j = 0 to sh.slots.size() - 1
                        slot = sh.slots.get(j)
                        k = p * 1000000 + slot
                        if timeMap.contains(k)
                            allXs.push(timeMap.get(k))
                            allVs.push(sh.rs.get(j) * sc)
                            allVsMin.push(sh.rsMin.get(j) * sc)
                            allVsMax.push(sh.rsMax.get(j) * sc)
                            nowPosAll := allXs.size() - 1
                            lastX := timeMap.get(k)
                        else if slot > lastRealSlot
                            int ft = na
                            bool skipSlot = false
                            if modeYearly
                                m_ = int(slot / 100)
                                d_ = slot % 100
                                t_ = timestamp("UTC", p, m_, d_, 0, 0)   // perId == year
                                wd_ = (int(t_ / 86400000) + 4) % 7
                                if wd_ == 0 or wd_ == 6                  // skip weekends
                                    skipSlot := true
                                else
                                    ft := t_
                            else if not na(perOffset)
                                kPrev = prevPerRef * 1000000 + slot
                                if timeMap.contains(kPrev)
                                    ft := timeMap.get(kPrev) + perOffset
                            if not skipSlot
                                if na(ft) or ft <= lastX
                                    ft := lastX + reqSec * 1000
                                allXs.push(ft)
                                allVs.push(sh.rs.get(j) * sc)
                                allVsMin.push(sh.rsMin.get(j) * sc)
                                allVsMax.push(sh.rsMax.get(j) * sc)
                                lastX := ft
                else
                    // Past period.  Only plot slots that actually traded
                    for j = 0 to sh.slots.size() - 1
                        k = p * 1000000 + sh.slots.get(j)
                        if timeMap.contains(k)
                            allXs.push(timeMap.get(k))
                            allVs.push(sh.rs.get(j) * sc)
                            allVsMin.push(sh.rsMin.get(j) * sc)
                            allVsMax.push(sh.rsMax.get(j) * sc)

            // Smooth all three series with the trailing SMA
            smVs    = smoothArr(allVs, smoothLen)
            smVsMin = showMinMax ? smoothArr(allVsMin, smoothLen) : array.new<float>()
            smVsMax = showMinMax ? smoothArr(allVsMax, smoothLen) : array.new<float>()
            n = smVs.size()

            // Fit transform: rescale the whole curve so the current
            // period's span matches the real high-low of the range source,
            // anchored at the period's first close. "Rotate & Scale" then
            // tilts the current-period segment so it passes through the
            // live price at the current bar.
            if scaleMode != "Chained (no fit)" and not na(curStartIdx) and n > curStartIdx
                cFirst = smVs.get(curStartIdx)
                cMin = cFirst
                cMax = cFirst
                for k = curStartIdx to n - 1
                    cMin := math.min(cMin, smVs.get(k))
                    cMax := math.max(cMax, smVs.get(k))

                int prevPer = curIdxP > 0 ? periodsSeen.get(curIdxP - 1) : na
                float refH = na
                float refL = na
                if rangeSource == "Previous period" and not na(prevPer) and hiMap.contains(prevPer)
                    refH := hiMap.get(prevPer)
                    refL := loMap.get(prevPer)
                else
                    refH := hiMap.get(curPer)
                    refL := loMap.get(curPer)

                anchor = firstCloseMap.get(curPer)
                if not na(refH) and not na(refL) and not na(anchor) and cMax != cMin
                    scAdj = (refH - refL) / (cMax - cMin)
                    for k = 0 to n - 1
                        smVs.set(k, anchor + (smVs.get(k) - cFirst) * scAdj)
                        if showMinMax
                            smVsMin.set(k, anchor + (smVsMin.get(k) - cFirst) * scAdj)
                            smVsMax.set(k, anchor + (smVsMax.get(k) - cFirst) * scAdj)
                    // Rotate: add a linearly-growing delta so the curve hits
                    // the current price exactly at the current bar
                    if scaleMode == "Rotate & Scale" and not na(nowPosAll) and nowPosAll > curStartIdx and not na(pxC)
                        delta = pxC - smVs.get(nowPosAll)
                        denom = nowPosAll - curStartIdx
                        for k = curStartIdx to n - 1
                            ratio = (k - curStartIdx) / float(denom)
                            smVs.set(k, smVs.get(k) + ratio * delta)
                            if showMinMax
                                smVsMin.set(k, smVsMin.get(k) + ratio * delta)
                                smVsMax.set(k, smVsMax.get(k) + ratio * delta)

            // Convert to chart points, split into past vs current period,
            // and build the optional min/max envelope point lists
            ptsPast = array.new<chart.point>()
            ptsCur  = array.new<chart.point>()
            ptsMin  = array.new<chart.point>()
            ptsMax  = array.new<chart.point>()
            for k = 0 to n - 1
                pnt = chart.point.from_time(allXs.get(k), smVs.get(k))
                if na(curStartIdx) or k < curStartIdx
                    ptsPast.push(pnt)
                else
                    ptsCur.push(pnt)
                if showMinMax
                    ptsMin.push(chart.point.from_time(allXs.get(k), smVsMin.get(k)))
                    ptsMax.push(chart.point.from_time(allXs.get(k), smVsMax.get(k)))
            // Bridge the gap so the past line connects to the current line
            if not na(curStartIdx) and ptsCur.size() > 0 and ptsPast.size() > 0
                ptsPast.push(ptsCur.get(0))

            // Draw everything: envelope (dashed), past curve (gray),
            // glow halo layers, and the main current-period curve on top
            if showMinMax and ptsMin.size() > 1
                minLine := polyline.new(ptsMin, curved=false, closed=false,
                     xloc=xloc.bar_time, line_color=minColor, line_width=1,
                     line_style=line.style_dashed)
                maxLine := polyline.new(ptsMax, curved=false, closed=false,
                     xloc=xloc.bar_time, line_color=maxColor, line_width=1,
                     line_style=line.style_dashed)

            if ptsPast.size() > 1
                pastLine := polyline.new(ptsPast, curved=false, closed=false,
                     xloc=xloc.bar_time, line_color=pastColor, line_width=1)
            if ptsCur.size() > 1
                if glowOn
                    glowLine3 := polyline.new(ptsCur, curved=false, closed=false,
                         xloc=xloc.bar_time, line_color=color.new(seasColor, 92), line_width=10)
                    glowLine2 := polyline.new(ptsCur, curved=false, closed=false,
                         xloc=xloc.bar_time, line_color=color.new(seasColor, 85), line_width=6)
                    glowLine1 := polyline.new(ptsCur, curved=false, closed=false,
                         xloc=xloc.bar_time, line_color=color.new(seasColor, 72), line_width=4)
                curLine := polyline.new(ptsCur, curved=false, closed=false,
                     xloc=xloc.bar_time, line_color=seasColor, line_width=2)


// SETTINGS TABLE 
if barstate.islast
    var table setTbl = na
    if not na(setTbl)
        table.delete(setTbl)

    if showSettings
        tPos = settingsPos == "top_left"      ? position.top_left :
             settingsPos == "top_center"    ? position.top_center :
             settingsPos == "top_right"     ? position.top_right :
             settingsPos == "middle_left"   ? position.middle_left :
             settingsPos == "middle_right"  ? position.middle_right :
             settingsPos == "bottom_left"   ? position.bottom_left :
             settingsPos == "bottom_center" ? position.bottom_center :
             position.bottom_right

        setTbl := table.new(tPos, 2, 7, border_width=1,
             border_color=color.new(tblTextColor, 80))

        hdrBg = color.new(tblBgColor, 0)

        table.cell(setTbl, 0, 0, "Seasonality", text_color=tblTextColor, bgcolor=hdrBg,
             text_size=size.small, text_halign=text.align_left)
        table.cell(setTbl, 1, 0, seasonTF, text_color=tblTextColor, bgcolor=hdrBg,
             text_size=size.small, text_halign=text.align_left)

        table.cell(setTbl, 0, 1, "Lookback", text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)
        table.cell(setTbl, 1, 1, str.tostring(lookbackPeriods) + " periods", text_color=tblTextColor,
             bgcolor=tblBgColor, text_size=size.small, text_halign=text.align_left)

        table.cell(setTbl, 0, 2, "Average", text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)
        table.cell(setTbl, 1, 2, avgMethod, text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)

        table.cell(setTbl, 0, 3, "Smoothing", text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)
        table.cell(setTbl, 1, 3, smoothLen == 1 ? "Off" : str.tostring(smoothLen) + " bars",
             text_color=tblTextColor, bgcolor=tblBgColor, text_size=size.small,
             text_halign=text.align_left)

        table.cell(setTbl, 0, 4, "Fit mode", text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)
        table.cell(setTbl, 1, 4, scaleMode, text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)

        table.cell(setTbl, 0, 5, "Fit range", text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)
        table.cell(setTbl, 1, 5, scaleMode == "Chained (no fit)" ? "—" : rangeSource,
             text_color=tblTextColor, bgcolor=tblBgColor, text_size=size.small,
             text_halign=text.align_left)

        table.cell(setTbl, 0, 6, "Min/Max", text_color=tblTextColor, bgcolor=tblBgColor,
             text_size=size.small, text_halign=text.align_left)
        table.cell(setTbl, 1, 6, showMinMax ? "On" : "Off", text_color=tblTextColor,
             bgcolor=tblBgColor, text_size=size.small, text_halign=text.align_left)

// TIMEFRAME WARNING — checks the chart's timeframe against the acceptable
// window for the selected mode and shows a red warning badge if outside it.
//   Yearly:  4h – 1D      Monthly: 15m – 1h
//   Weekly:  5m – 30m     Daily:   1m – 5m

chartSec = timeframe.in_seconds(timeframe.period)
tfOK = chartSec >= minSec and chartSec <= reqSec

if barstate.islast and not tfOK
    natLabel = modeYearly ? "1D" : modeMonthly ? "1h" : modeWeekly ? "30m" : "5m"
    minLabel = modeYearly ? "4h" : modeMonthly ? "15m" : modeWeekly ? "5m" : "1m"
    var table warn = table.new(position.top_right, 1, 1)
    table.cell(warn, 0, 0,
         "⚠ Use a " + minLabel + " – " + natLabel + " chart for " + seasonTF,
         text_color=color.white, bgcolor=color.new(color.red, 20))
````
