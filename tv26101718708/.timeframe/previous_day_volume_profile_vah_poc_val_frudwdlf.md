# Previous Day Volume Profile (VAH / POC / VAL)

- url: https://www.tradingview.com/script/FRuDWdlf-Previous-Day-Volume-Profile-VAH-POC-VAL/
- type: indicator
- pine_id: PUB;d2f91ddcb58e43af8345c92aa6938e87
- version: 2.0

## Description

Previous Day Volume Profile — VAH / POC / VAL

Automatically calculates the previous trading day's Volume Profile and projects its three key levels — Value Area High, Point of Control, and Value Area Low — as dotted horizontal lines across the current trading day. Levels roll forward automatically at each new session, so yesterday's value area is always on your chart without manual drawing.

How it works

The trading day is defined by a configurable session and timezone (not midnight), so it works correctly on nearly-24h futures — e.g. 23:00–21:55 UK for CME index futures.
The profile is built from intrabar data (request.security_lower_tf, default 1-minute; seconds timeframes supported on Premium+ plans), giving near-tick resolution regardless of your chart timeframe. Where intrabar history isn't available it falls back to chart bars.
Each intrabar's volume is pro-rated across the price bins its high-low range overlaps (with an even-split option).
Bins are anchored to the absolute price grid, exactly N ticks wide (configurable, default 2 ticks), or alternatively a fixed row count.
POC = the highest-volume bin. The Value Area (default 70% of the day's volume) expands outward from the POC using the classic Market Profile "double" method — comparing the sum of the two bins above the band vs. the two below and adding the fuller pair (a simpler single-bin mode is also available). VAH and VAL are the band's top and bottom edges.
Inputs

Session and timezone defining the trading-day boundary
Row sizing: ticks per row, or fixed number of rows
Value Area percentage and expansion method (double / single)
Volume distribution: pro-rated or even split
Intrabar timeframe (1S–5min) with on/off toggle
Colour and line width per level, label toggle and offset
Notes

Lines are drawn only on the current day, from its first bar to the right edge — the previous day's candles stay clean. Old drawings are removed at each session roll.
Computed values are also exposed in the Data Window for verification.
Pine cannot access true tick data; on plans without seconds timeframes, 1-minute intrabars are the finest available resolution (the same resolution TradingView's built-in profiles use on those plans), so levels may differ from tick-based profiles by a row or so.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © callumstrading1998

//@version=6
indicator("Previous Day Volume Profile (VAH / POC / VAL)", overlay = true,
     max_lines_count = 10, max_labels_count = 10)

// ============================================================================
// Inputs
// ============================================================================
grpProfile = "Volume profile"
rowsInput        = input.int(24, "Number of rows (bins)", minval = 2, maxval = 500,
                              group = grpProfile,
                              tooltip = "Used when \"Ticks per row\" is 0.")
ticksPerRowInput = input.int(2, "Ticks per row (0 = use Number of rows)", minval = 0, maxval = 10000,
                              group = grpProfile,
                              tooltip = "If > 0, bin size = ticks-per-row × instrument tick size, overriding Number of rows. " +
                                        "2 on ES = 0.5-pt bins, close to TradingView's built-in VP.")
vaPctInput       = input.float(70.0, "Value Area %", minval = 1.0, maxval = 99.0, step = 1.0,
                                group = grpProfile,
                                tooltip = "Percentage of the day's total volume defining the Value Area.")
vaMethodInput    = input.string("Double (2-bin)", "Value Area expansion",
                                 options = ["Double (2-bin)", "Single (1-bin)"],
                                 group = grpProfile,
                                 tooltip = "Double = classic Market Profile — compare the sum of 2 bins above vs 2 bins below the band, " +
                                           "add both bins of the fuller pair. Single = simpler 1-bin comparison.")
useProrated      = input.bool(true, "Pro-rate volume by bin overlap",
                               group = grpProfile,
                               tooltip = "true: each (intra)bar's volume is split by the fraction of its H-L in each bin. " +
                                         "false: split evenly across overlapping bins.")

grpIntrabar = "Intrabar data"
useIntrabar  = input.bool(true, "Use intrabar (lower-timeframe) data", group = grpIntrabar,
                           tooltip = "Build the profile from lower-timeframe bars inside each chart bar instead of the chart bars " +
                                     "themselves — much closer to a true tick profile. Falls back to chart bars where intrabar " +
                                     "history isn't available.")
lowerTfInput = input.string("10S", "Intrabar timeframe", options = ["1S", "5S", "10S", "15S", "30S", "1", "2", "5"],
                             group = grpIntrabar,
                             tooltip = "Must be LOWER than the chart timeframe. Seconds (\"S\") timeframes need a TradingView plan " +
                                       "with seconds data (Premium+). Pine caps intrabar access at ~100k intrabars counted back " +
                                       "from the newest bar: 1S ≈ 1.2 days of a 23h futures session, 5S ≈ 4-5 days, 10S ≈ 12 days. " +
                                       "10S or 5S is the sweet spot; use \"1\" (1 minute) on non-seconds plans.")

grpSession = "Session"
sessionInput = input.session("2300-2100:1234567", "Trading session (day boundary)",
                              group = grpSession,
                              tooltip = "Session hours interpreted in the timezone below. Format HHMM-HHMM:days (1=Sun … 7=Sat). Overnight OK.")
tzInput      = input.string("Europe/London", "Session timezone",
                             options = ["exchange", "GMT+0", "America/New_York", "America/Chicago",
                                        "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Singapore"],
                             group = grpSession)

grpStyle = "Style"
vahColor  = input.color(color.green, "VAH colour", group = grpStyle)
pocColor  = input.color(color.blue,  "POC colour", group = grpStyle)
valColor  = input.color(color.red,   "VAL colour", group = grpStyle)
vahWidth  = input.int(1, "VAH width", minval = 1, maxval = 5, group = grpStyle)
pocWidth  = input.int(1, "POC width", minval = 1, maxval = 5, group = grpStyle)
valWidth  = input.int(1, "VAL width", minval = 1, maxval = 5, group = grpStyle)
showLabels     = input.bool(true, "Show right-side labels", group = grpStyle)
labelOffsetInp = input.int(5, "Label offset (bars right of last bar)", minval = 0, maxval = 100, group = grpStyle)

// ============================================================================
// Intrabar data — arrays of lower-timeframe H / L / V inside the current
// chart bar. Must be requested at global scope on every bar.
// ============================================================================
[ltfHighs, ltfLows, ltfVols] = request.security_lower_tf(syminfo.tickerid, lowerTfInput, [high, low, volume])

// ============================================================================
// New-day detection
// ============================================================================
tzToUse = tzInput == "exchange" ? syminfo.timezone : tzInput
dayTime = time("D", sessionInput, tzToUse)

var int trackedDay   = na
var int dayStartTime = na
newDaySignal = not na(dayTime) and (na(trackedDay) or dayTime != trackedDay)

// Milliseconds per chart bar — used to project drawings past the last bar.
barMs = timeframe.in_seconds() * 1000

// ============================================================================
// State
// ============================================================================
var array<float> curHighs   = array.new<float>()
var array<float> curLows    = array.new<float>()
var array<float> curVolumes = array.new<float>()

var float prevVAH = na
var float prevPOC = na
var float prevVAL = na

var line  lnVAH  = na
var line  lnPOC  = na
var line  lnVAL  = na
var label lblVAH = na
var label lblPOC = na
var label lblVAL = na

// ============================================================================
// Volume-profile computation
// ============================================================================
computeProfile(highs, lows, vols, rowsFixed, ticksPerRow, tickSize, vaPct, useDouble, proRate) =>
    float pocPrice = na
    float vahPrice = na
    float valPrice = na
    int   n        = array.size(highs)

    if n > 0
        float dayHi = array.get(highs, 0)
        float dayLo = array.get(lows,  0)
        if n > 1
            for i = 1 to n - 1
                dayHi := math.max(dayHi, array.get(highs, i))
                dayLo := math.min(dayLo, array.get(lows,  i))

        if dayHi > dayLo
            // Bin layout. With ticks-per-row: bins are EXACTLY ticksPerRow × tickSize
            // wide and anchored to absolute price-grid multiples of that size (like the
            // built-in VP), so levels land on clean grid prices. Otherwise: fixed row
            // count stretched across the day's range, anchored at the day low.
            int   rows    = 0
            float binSize = na
            float profLo  = na
            if ticksPerRow > 0
                binSize := ticksPerRow * tickSize
                profLo  := math.floor(dayLo / binSize) * binSize
                rows    := int(math.min(5000.0, math.max(2.0, math.ceil((dayHi - profLo) / binSize))))
            else
                rows    := rowsFixed
                binSize := (dayHi - dayLo) / rows
                profLo  := dayLo
            bins           = array.new<float>(rows, 0.0)
            float totalVol = 0.0

            for i = 0 to n - 1
                float h = array.get(highs, i)
                float l = array.get(lows,  i)
                float v = array.get(vols,  i)
                totalVol += v
                if h == l
                    int idx = math.max(0, math.min(rows - 1, int(math.floor((l - profLo) / binSize))))
                    array.set(bins, idx, array.get(bins, idx) + v)
                else
                    int loIdx = math.max(0, math.min(rows - 1, int(math.floor((l - profLo) / binSize))))
                    int hiIdx = math.max(0, math.min(rows - 1, int(math.floor((h - profLo) / binSize))))
                    if proRate
                        float barRange = h - l
                        for bIdx = loIdx to hiIdx
                            float binLo  = profLo +  bIdx      * binSize
                            float binHi  = profLo + (bIdx + 1) * binSize
                            float overlap = math.max(0.0, math.min(h, binHi) - math.max(l, binLo))
                            if overlap > 0
                                array.set(bins, bIdx, array.get(bins, bIdx) + v * overlap / barRange)
                    else
                        int span = hiIdx - loIdx + 1
                        float vPerBin = v / span
                        for bIdx = loIdx to hiIdx
                            array.set(bins, bIdx, array.get(bins, bIdx) + vPerBin)

            int   pocIdx = 0
            float pocVol = array.get(bins, 0)
            if rows > 1
                for i = 1 to rows - 1
                    float bv = array.get(bins, i)
                    if bv > pocVol
                        pocVol := bv
                        pocIdx := i

            float vaTarget = totalVol * vaPct / 100.0
            float accVol   = pocVol
            int   upIdx    = pocIdx
            int   dnIdx    = pocIdx

            if useDouble
                // Classic Market-Profile "double" expansion: compare the sum of the
                // next 2 bins above the band with the next 2 below; add the fuller pair.
                while accVol < vaTarget and (upIdx < rows - 1 or dnIdx > 0)
                    float up1 = upIdx < rows - 1 ? array.get(bins, upIdx + 1) : 0.0
                    float up2 = upIdx < rows - 2 ? array.get(bins, upIdx + 2) : 0.0
                    float dn1 = dnIdx > 0        ? array.get(bins, dnIdx - 1) : 0.0
                    float dn2 = dnIdx > 1        ? array.get(bins, dnIdx - 2) : 0.0
                    float upPair = up1 + up2
                    float dnPair = dn1 + dn2
                    if upPair == 0.0 and dnPair == 0.0
                        break
                    if upPair >= dnPair
                        if upIdx < rows - 1
                            upIdx  += 1
                            accVol += array.get(bins, upIdx)
                        if accVol < vaTarget and upIdx < rows - 1
                            upIdx  += 1
                            accVol += array.get(bins, upIdx)
                    else
                        if dnIdx > 0
                            dnIdx  -= 1
                            accVol += array.get(bins, dnIdx)
                        if accVol < vaTarget and dnIdx > 0
                            dnIdx  -= 1
                            accVol += array.get(bins, dnIdx)
            else
                while accVol < vaTarget and (upIdx < rows - 1 or dnIdx > 0)
                    bool  canUp = upIdx < rows - 1
                    bool  canDn = dnIdx > 0
                    float upVol = canUp ? array.get(bins, upIdx + 1) : -1.0
                    float dnVol = canDn ? array.get(bins, dnIdx - 1) : -1.0
                    bool  goUp  = canUp and (not canDn or upVol >= dnVol)
                    if goUp
                        upIdx  += 1
                        accVol += upVol
                    else
                        dnIdx  -= 1
                        accVol += dnVol

            pocPrice := profLo + (pocIdx + 0.5) * binSize
            vahPrice := profLo + (upIdx  + 1)   * binSize
            valPrice := profLo +  dnIdx         * binSize

    [pocPrice, vahPrice, valPrice]

// ============================================================================
// Per-bar processing
// ============================================================================
if newDaySignal and barstate.isconfirmed
    if array.size(curHighs) > 0
        [pocP, vahP, valP] = computeProfile(curHighs, curLows, curVolumes,
             rowsInput, ticksPerRowInput, syminfo.mintick,
             vaPctInput, vaMethodInput == "Double (2-bin)", useProrated)
        prevPOC := pocP
        prevVAH := vahP
        prevVAL := valP

    array.clear(curHighs)
    array.clear(curLows)
    array.clear(curVolumes)

    trackedDay   := dayTime
    dayStartTime := time

    if not na(lnVAH)
        line.delete(lnVAH)
        lnVAH := na
    if not na(lnPOC)
        line.delete(lnPOC)
        lnPOC := na
    if not na(lnVAL)
        line.delete(lnVAL)
        lnVAL := na
    if not na(lblVAH)
        label.delete(lblVAH)
        lblVAH := na
    if not na(lblPOC)
        label.delete(lblPOC)
        lblPOC := na
    if not na(lblVAL)
        label.delete(lblVAL)
        lblVAL := na

// Accumulate this chart bar's data into the current day. Prefer intrabar
// rows (fine-grained, near-tick resolution); fall back to the chart bar's
// own H/L/V when no intrabar data exists for this bar (older history).
if barstate.isconfirmed and not na(dayTime)
    int nIntra = array.size(ltfHighs)
    if useIntrabar and nIntra > 0
        for i = 0 to nIntra - 1
            array.push(curHighs,   array.get(ltfHighs, i))
            array.push(curLows,    array.get(ltfLows,  i))
            array.push(curVolumes, nz(array.get(ltfVols, i)))
    else
        array.push(curHighs,   high)
        array.push(curLows,    low)
        array.push(curVolumes, nz(volume))

// ============================================================================
// Draw / refresh the three lines every bar (time-based coordinates)
// ============================================================================
if not na(dayStartTime)
    int lineT2 = time + labelOffsetInp * barMs

    if not na(prevPOC)
        if na(lnPOC)
            lnPOC := line.new(dayStartTime, prevPOC, lineT2, prevPOC,
                              xloc = xloc.bar_time,
                              style = line.style_dotted, color = pocColor, width = pocWidth)
        else
            line.set_xy1(lnPOC, dayStartTime, prevPOC)
            line.set_xy2(lnPOC, lineT2,       prevPOC)

    if not na(prevVAH)
        if na(lnVAH)
            lnVAH := line.new(dayStartTime, prevVAH, lineT2, prevVAH,
                              xloc = xloc.bar_time,
                              style = line.style_dotted, color = vahColor, width = vahWidth)
        else
            line.set_xy1(lnVAH, dayStartTime, prevVAH)
            line.set_xy2(lnVAH, lineT2,       prevVAH)

    if not na(prevVAL)
        if na(lnVAL)
            lnVAL := line.new(dayStartTime, prevVAL, lineT2, prevVAL,
                              xloc = xloc.bar_time,
                              style = line.style_dotted, color = valColor, width = valWidth)
        else
            line.set_xy1(lnVAL, dayStartTime, prevVAL)
            line.set_xy2(lnVAL, lineT2,       prevVAL)

// ============================================================================
// Right-edge labels (time-based coordinates)
// ============================================================================
if showLabels and barstate.islast
    int labelT = time + labelOffsetInp * barMs

    if not na(prevVAH)
        if na(lblVAH)
            lblVAH := label.new(labelT, prevVAH, "Previous days VAH",
                                xloc = xloc.bar_time, style = label.style_none,
                                textcolor = vahColor, size = size.small)
        else
            label.set_xy(lblVAH, labelT, prevVAH)
            label.set_textcolor(lblVAH, vahColor)
    if not na(prevPOC)
        if na(lblPOC)
            lblPOC := label.new(labelT, prevPOC, "Previous days POC",
                                xloc = xloc.bar_time, style = label.style_none,
                                textcolor = pocColor, size = size.small)
        else
            label.set_xy(lblPOC, labelT, prevPOC)
            label.set_textcolor(lblPOC, pocColor)
    if not na(prevVAL)
        if na(lblVAL)
            lblVAL := label.new(labelT, prevVAL, "Previous days VAL",
                                xloc = xloc.bar_time, style = label.style_none,
                                textcolor = valColor, size = size.small)
        else
            label.set_xy(lblVAL, labelT, prevVAL)
            label.set_textcolor(lblVAL, valColor)

// ============================================================================
// Debug — computed values in the Data Window
// ============================================================================
plot(prevVAH, "prev VAH", color = vahColor, display = display.data_window)
plot(prevPOC, "prev POC", color = pocColor, display = display.data_window)
plot(prevVAL, "prev VAL", color = valColor, display = display.data_window)
````
