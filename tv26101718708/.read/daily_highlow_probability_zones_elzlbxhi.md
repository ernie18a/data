# Daily High/Low probability zones

- url: https://www.tradingview.com/script/eLZlBxhi-Daily-High-Low-probability-zones/
- type: indicator
- pine_id: PUB;a7834225d7ed4a499d2fb25acbf5ab1f
- version: 1.0

## Description

Daily High/Low probability zones

Overview
Daily Segment Probabilities analyses the statistical distribution of where a market forms its daily High and daily Low relative to the previous session's range. By studying the prior day's High (PDH) and Low (PDL) across a user-defined lookback window, the indicator divides the price space around that range into 12 equal segments of 25% each — from −100% to +200% — and calculates how frequently the current session's High and Low have historically landed inside each segment. The result is a probability map drawn directly on the chart for today's session, letting you see at a glance which zones have historically attracted the day's extremes.

What is shown on the chart
The PDH and PDL of the prior session are drawn as solid horizontal lines across the current day, labelled in the margin. These form the 0% and 100% anchor points of the range.
Twelve segment boundaries are then projected from PDL upward and downward using the prior day's range as the measuring unit. Each boundary is coloured by zone: teal for the inside range (0–100%), indigo for upside extensions (above 100%), and red for downside extensions (below 0%). The 0% and 100% lines themselves are omitted from the segment boundaries since the PDH/PDL lines already mark them.

At the midpoint of each band, a label shows the segment name alongside the historical probability of the day's High and Low forming within that band — for example 0–25%  H:18%  L:34%. A tooltip on each label gives the full count of occurrences out of total sample days.
The two highest-probability bands are highlighted with a filled overlay: a gold fill marks the segment where the day's High has most frequently formed, and an orange fill marks the segment where the day's Low has most frequently formed. These fills are also reflected in the probability table — the High% and Low% cells for the top segments are coloured to match, creating a direct visual link between the chart and the table. Labels for the top bands carry a ★H or ★L marker for quick identification.

The probability table
The table summarises the full segment distribution in a compact grid with four columns:

Seg — segment number (1–12, top to bottom of chart)
Range — the percentage band that segment covers
High% — percentage of historical days where the session High formed in this segment
Low% — percentage of historical days where the session Low formed in this segment

Below the twelve data rows is an OOB (out-of-bounds) row counting days where the High or Low fell completely outside the −100% to +200% window. The footer row shows the actual sample size (n) and the configured lookback.

The High% and Low% cells for the two top-probability segments are highlighted with the same fill colours used on the chart, so the table and the chart read as a unified system.

How the lookback and calculation work
The lookback setting (default 250 days, range 10–500) defines how many prior daily sessions are included in the historical sample. 

For each day in that window the indicator:
Takes the prior session's High and Low to establish the reference range and its 0% / 100% anchors.
Measures where that session's own High and Low fell, expressed as a percentage of the prior range above the prior Low — so a High exactly at the PDH of its own prior session registers as 100%, and a Low exactly at the PDL registers as 0%.
Assigns each reading to whichever 25%-wide segment it falls into.
Counts occurrences per segment across all n valid days (days where the prior range is greater than zero are included; zero-range days are skipped).

Probabilities in the table and labels are the count for each segment divided by n, rounded to the nearest whole percent. The top-segment fills and ★ markers are determined purely by the highest raw count, not the rounded percentage, so ties resolve correctly.
A minimum of 5 valid days is required before anything is drawn.

Settings
Core Settings

Lookback (days) — number of prior sessions used to build the probability distribution. Higher values give a more statistically stable sample; lower values are more responsive to recent market character. 250 days (roughly one trading year) is a reasonable default for most instruments.

Visual Settings

PDH/PDL line colour — colour of the prior day High and Low anchor lines.
Inside range colour (0–100%) — colour applied to segment boundaries within the prior range.
Extension above colour (>100%) — colour for boundaries above the PDH.
Extension below colour (<0%) — colour for boundaries below the PDL.
Label text colour — colour of the midpoint probability labels.
Segment line style — Solid, Dotted, or Dashed for segment boundaries.
PDH/PDL line style — Solid, Dotted, or Dashed for the anchor lines.
Top High% band fill colour — fill colour for the highest-probability High segment (default gold).
Top Low% band fill colour — fill colour for the highest-probability Low segment (default orange).

Table Settings

Show probability table — toggle the table on or off.
Table position — Top Right, Bottom Right, Middle Right, Bottom Center, or Middle Left.
Table text size — Auto, Tiny, Small, Normal, Large, or Huge.


Interpreting the output
The indicator does not predict where price will go — it describes where it has historically gone. A segment showing H:35% means the day's High landed in that band on roughly one in three days over the lookback period. Used alongside other context (session opens, market structure, news), the distribution can inform expectations for the day's likely trading range and where extension targets have historically clustered.
Segments inside the prior range (0–100%) capturing a high proportion of Low readings suggest mean-reversion sessions are common for the instrument. Large probabilities in extension segments (above 100% or below 0%) reflect trending or breakout tendencies. The OOB row is worth watching on highly volatile instruments where extreme moves regularly exceed the prior range by a wide margin.

Notes

The indicator is drawn only on the last bar of the chart to avoid repainting and to keep line/label counts within TradingView's limits.
It is designed for use on intraday timeframes (1m–1h) where the daily session boundaries are visible. On a daily chart it will still compile but the lines will span only the current day's single candle.
The prior session data is fetched via request.security on the daily timeframe with lookahead_off to prevent look-ahead bias.
All percentages shown are based on historical frequency only and carry no implied forward guarantee.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © lucymatos

//@version=5
indicator("Daily Segment Probabilities", shorttitle="DSP", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpMain = "Core Settings"
grpVis  = "Visual Settings"
grpTbl  = "Table Settings"

lookback = input.int(250, "Lookback (days)", minval=10, maxval=500, group=grpMain)

int   N_SEGS = 12
var segEdges = array.new_float(13)
array.set(segEdges,  0, -100.0)
array.set(segEdges,  1,  -75.0)
array.set(segEdges,  2,  -50.0)
array.set(segEdges,  3,  -25.0)
array.set(segEdges,  4,    0.0)
array.set(segEdges,  5,   25.0)
array.set(segEdges,  6,   50.0)
array.set(segEdges,  7,   75.0)
array.set(segEdges,  8,  100.0)
array.set(segEdges,  9,  125.0)
array.set(segEdges, 10,  150.0)
array.set(segEdges, 11,  175.0)
array.set(segEdges, 12,  200.0)

var segLabels = array.new_string(12)
array.set(segLabels,  0, "-100–-75%")
array.set(segLabels,  1,  "-75–-50%")
array.set(segLabels,  2,  "-50–-25%")
array.set(segLabels,  3,   "-25–0%")
array.set(segLabels,  4,    "0–25%")
array.set(segLabels,  5,   "25–50%")
array.set(segLabels,  6,   "50–75%")
array.set(segLabels,  7,  "75–100%")
array.set(segLabels,  8, "100–125%")
array.set(segLabels,  9, "125–150%")
array.set(segLabels, 10, "150–175%")
array.set(segLabels, 11, "175–200%")

// ── Zone colours (user-configurable) ─────────────────────────────────────────
pdhlColor    = input.color(color.new(#2962FF, 0),   "PDH/PDL line colour",            group=grpVis)
colInside    = input.color(color.new(#26A69A, 0),   "Inside range colour (0–100%)",   group=grpVis)
colAbove     = input.color(color.new(#5C6BC0, 0),   "Extension above colour (>100%)", group=grpVis)
colBelow     = input.color(color.new(#EF5350, 0),   "Extension below colour (<0%)",   group=grpVis)
lblColor     = input.color(color.new(#787B86, 0),   "Label text colour",              group=grpVis)
segStyle     = input.string("Dashed (╌)", "Segment line style",
     options=["Solid (─)", "Dotted (┈)", "Dashed (╌)"], group=grpVis)
pdhlStyle    = input.string("Solid (─)", "PDH/PDL line style",
     options=["Solid (─)", "Dotted (┈)", "Dashed (╌)"], group=grpVis)
colHighFill  = input.color(color.new(#FFD700, 60),  "Top High% band fill colour",     group=grpVis)
colLowFill   = input.color(color.new(#FF6B35, 60),  "Top Low% band fill colour",      group=grpVis)

showTable     = input.bool(true, "Show probability table", group=grpTbl)
tablePos      = input.string("Top Right", "Table position",
     options=["Top Right","Bottom Right","Middle Right","Bottom Center","Middle Left"], group=grpTbl)
tableTextSize = input.string("Small", "Table text size",
     options=["Auto","Tiny","Small","Normal","Large","Huge"], group=grpTbl)

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
lnStyle(s) =>
    s == "Dotted (┈)" ? line.style_dotted : s == "Dashed (╌)" ? line.style_dashed : line.style_solid

tblPos(p) =>
    switch p
        "Top Right"     => position.top_right
        "Bottom Right"  => position.bottom_right
        "Middle Right"  => position.middle_right
        "Bottom Center" => position.bottom_center
        "Middle Left"   => position.middle_left

tblSz(s) =>
    switch s
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge

pctToPrice(pdLow, pdRange, pct) =>
    pdLow + pdRange * (pct / 100.0)

getSegIdx(pct) =>
    idx = -1
    for k = 0 to N_SEGS - 1
        lo = array.get(segEdges, k)
        hi = array.get(segEdges, k + 1)
        if k == N_SEGS - 1
            if pct >= lo and pct <= hi
                idx := k
        else
            if pct >= lo and pct < hi
                idx := k
    idx

segZoneColor(k) =>
    k >= 8 ? colAbove : k >= 4 ? colInside : colBelow

segRowBg(k) =>
    k >= 8 ? color.new(colAbove, 82) : k >= 4 ? color.new(colInside, 82) : color.new(colBelow, 82)

// ─────────────────────────────────────────────────────────────────────────────
// FETCH DAILY H/L
// ─────────────────────────────────────────────────────────────────────────────
get_daily(bars) =>
    h = array.new_float(0)
    l = array.new_float(0)
    t = array.new_int(0)
    for n = 0 to bars
        array.push(h, high[n])
        array.push(l, low[n])
        array.push(t, time[n])
    [h, l, t]

[dHighs, dLows, dTimes] = request.security(syminfo.tickerid, "1D",
     get_daily(lookback + 1), lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// ALL LOGIC ON LAST BAR ONLY
// ─────────────────────────────────────────────────────────────────────────────
if bar_index == last_bar_index

    segHighCounts = array.new_int(N_SEGS, 0)
    segLowCounts  = array.new_int(N_SEGS, 0)
    highOutAbove  = 0
    highOutBelow  = 0
    lowOutAbove   = 0
    lowOutBelow   = 0
    n = 0

    for i = 1 to math.min(lookback, array.size(dHighs) - 2)
        priorHigh  = array.get(dHighs, i + 1)
        priorLow   = array.get(dLows,  i + 1)
        priorRange = priorHigh - priorLow
        if priorRange > 0
            dayHigh = array.get(dHighs, i)
            dayLow  = array.get(dLows,  i)
            hPct    = (dayHigh - priorLow) / priorRange * 100.0
            lPct    = (dayLow  - priorLow) / priorRange * 100.0
            hIdx    = getSegIdx(hPct)
            lIdx    = getSegIdx(lPct)
            if hIdx >= 0
                array.set(segHighCounts, hIdx, array.get(segHighCounts, hIdx) + 1)
            else if hPct > 200.0
                highOutAbove += 1
            else
                highOutBelow += 1
            if lIdx >= 0
                array.set(segLowCounts, lIdx, array.get(segLowCounts, lIdx) + 1)
            else if lPct > 200.0
                lowOutAbove += 1
            else
                lowOutBelow += 1
            n += 1

    if n >= 5
        pdHigh     = array.get(dHighs, 1)
        pdLow      = array.get(dLows,  1)
        pdRange    = pdHigh - pdLow
        todayStart = array.get(dTimes, 0)
        todayEnd   = todayStart + 86400000

        // ── Find top High% and Low% segments ─────────────────────────────────
        topHighSeg = 0
        topHighVal = array.get(segHighCounts, 0)
        topLowSeg  = 0
        topLowVal  = array.get(segLowCounts, 0)

        for k = 1 to N_SEGS - 1
            hc = array.get(segHighCounts, k)
            lc = array.get(segLowCounts,  k)
            if hc > topHighVal
                topHighVal := hc
                topHighSeg := k
            if lc > topLowVal
                topLowVal := lc
                topLowSeg := k

        // ── Rest of logic gated on pdRange ────────────────────────────────────
        if pdRange > 0

            // ── Band fills ───────────────────────────────────────────────────
            highFillLo = pctToPrice(pdLow, pdRange, array.get(segEdges, topHighSeg))
            highFillHi = pctToPrice(pdLow, pdRange, array.get(segEdges, topHighSeg + 1))
            hFillBot   = line.new(todayStart, highFillLo, todayEnd, highFillLo,
                 xloc=xloc.bar_time, color=color.new(color.white, 100), width=1)
            hFillTop   = line.new(todayStart, highFillHi, todayEnd, highFillHi,
                 xloc=xloc.bar_time, color=color.new(color.white, 100), width=1)
            linefill.new(hFillBot, hFillTop, color=colHighFill)

            if topLowSeg != topHighSeg
                lowFillLo = pctToPrice(pdLow, pdRange, array.get(segEdges, topLowSeg))
                lowFillHi = pctToPrice(pdLow, pdRange, array.get(segEdges, topLowSeg + 1))
                lFillBot  = line.new(todayStart, lowFillLo, todayEnd, lowFillLo,
                     xloc=xloc.bar_time, color=color.new(color.white, 100), width=1)
                lFillTop  = line.new(todayStart, lowFillHi, todayEnd, lowFillHi,
                     xloc=xloc.bar_time, color=color.new(color.white, 100), width=1)
                linefill.new(lFillBot, lFillTop, color=colLowFill)

            // ── PDH and PDL lines ─────────────────────────────────────────────
            line.new(todayStart, pdHigh, todayEnd, pdHigh,
                 xloc=xloc.bar_time, color=pdhlColor,
                 style=lnStyle(pdhlStyle), width=2)
            label.new(todayEnd, pdHigh, text="PDH: " + str.tostring(pdHigh, "#.00"),
                 xloc=xloc.bar_time, color=color.new(color.black, 100),
                 textcolor=pdhlColor, size=size.small,
                 style=label.style_label_left,
                 text_font_family=font.family_monospace)

            line.new(todayStart, pdLow, todayEnd, pdLow,
                 xloc=xloc.bar_time, color=pdhlColor,
                 style=lnStyle(pdhlStyle), width=2)
            label.new(todayEnd, pdLow, text="PDL: " + str.tostring(pdLow, "#.00"),
                 xloc=xloc.bar_time, color=color.new(color.black, 100),
                 textcolor=pdhlColor, size=size.small,
                 style=label.style_label_left,
                 text_font_family=font.family_monospace)

            // ── Segment boundary lines ────────────────────────────────────────
            for k = 0 to N_SEGS
                edgePct   = array.get(segEdges, k)
                if edgePct != 0.0 and edgePct != 100.0
                    segIdx    = math.min(k, N_SEGS - 1)
                    edgeColor = segZoneColor(segIdx)
                    edgePrice = pctToPrice(pdLow, pdRange, edgePct)
                    line.new(todayStart, edgePrice, todayEnd, edgePrice,
                         xloc=xloc.bar_time, color=edgeColor,
                         style=lnStyle(segStyle), width=1)

            // ── Segment midpoint labels ───────────────────────────────────────
            for k = 0 to N_SEGS - 1
                loPct    = array.get(segEdges, k)
                hiPct    = array.get(segEdges, k + 1)
                midPrice = pctToPrice(pdLow, pdRange, (loPct + hiPct) / 2.0)
                hCount   = array.get(segHighCounts, k)
                lCount   = array.get(segLowCounts,  k)
                hPctLbl  = math.round(float(hCount) / n * 100)
                lPctLbl  = math.round(float(lCount) / n * 100)
                segLbl   = array.get(segLabels, k)
                hStar    = k == topHighSeg ? " ★H" : ""
                lStar    = k == topLowSeg  ? " ★L" : ""
                labelTxt = segLbl + "  H:" + str.tostring(hPctLbl) + "%" + hStar + "  L:" + str.tostring(lPctLbl) + "%" + lStar
                label.new(todayEnd, midPrice,
                     text=labelTxt,
                     xloc=xloc.bar_time,
                     color=color.new(color.black, 100),
                     textcolor=lblColor,
                     size=size.small,
                     style=label.style_label_left,
                     text_font_family=font.family_monospace,
                     tooltip=segLbl + "\n" +
                             "High formed here: " + str.tostring(hCount) + "/" + str.tostring(n) + " days (" + str.tostring(hPctLbl) + "%)\n" +
                             "Low  formed here: " + str.tostring(lCount) + "/" + str.tostring(n) + " days (" + str.tostring(lPctLbl) + "%)")

        // ── TABLE ─────────────────────────────────────────────────────────────
        if showTable
            tblRows = N_SEGS + 3
            tbl = table.new(tblPos(tablePos), 4, tblRows,
                 border_width=1,
                 border_color=color.new(color.gray, 60),
                 frame_color=color.new(color.gray, 60),
                 frame_width=1,
                 bgcolor=color.white)

            sz      = tblSz(tableTextSize)
            hdrBg   = color.new(color.gray, 70)
            hdrTxt  = color.black
            cellTxt = color.black

            table.cell(tbl, 0, 0, "Seg",    bgcolor=hdrBg, text_color=hdrTxt, text_size=sz, text_font_family=font.family_monospace)
            table.cell(tbl, 1, 0, "Range",  bgcolor=hdrBg, text_color=hdrTxt, text_size=sz, text_font_family=font.family_monospace)
            table.cell(tbl, 2, 0, "High %", bgcolor=hdrBg, text_color=hdrTxt, text_size=sz, text_font_family=font.family_monospace)
            table.cell(tbl, 3, 0, "Low %",  bgcolor=hdrBg, text_color=hdrTxt, text_size=sz, text_font_family=font.family_monospace)

            for k = 0 to N_SEGS - 1
                row    = k + 1
                hCount = array.get(segHighCounts, k)
                lCount = array.get(segLowCounts,  k)
                hPct   = math.round(float(hCount) / n * 100)
                lPct   = math.round(float(lCount) / n * 100)
                rowBg  = segRowBg(k)
                hBg    = k == topHighSeg ? colHighFill : rowBg
                lBg    = k == topLowSeg  ? colLowFill  : rowBg
                table.cell(tbl, 0, row, str.tostring(k + 1),     bgcolor=rowBg, text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)
                table.cell(tbl, 1, row, array.get(segLabels, k), bgcolor=rowBg, text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)
                table.cell(tbl, 2, row, str.tostring(hPct) + "%", bgcolor=hBg,  text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)
                table.cell(tbl, 3, row, str.tostring(lPct) + "%", bgcolor=lBg,  text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)

            outRow  = N_SEGS + 1
            hOOBpct = math.round(float(highOutAbove + highOutBelow) / n * 100)
            lOOBpct = math.round(float(lowOutAbove  + lowOutBelow)  / n * 100)
            table.cell(tbl, 0, outRow, "OOB",                        bgcolor=color.new(colBelow, 82), text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)
            table.cell(tbl, 1, outRow, "<-100%/>200%",               bgcolor=color.new(colBelow, 82), text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)
            table.cell(tbl, 2, outRow, str.tostring(hOOBpct) + "%",  bgcolor=color.new(colBelow, 82), text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)
            table.cell(tbl, 3, outRow, str.tostring(lOOBpct) + "%",  bgcolor=color.new(colBelow, 82), text_color=cellTxt, text_size=sz, text_font_family=font.family_monospace)

            nRow = N_SEGS + 2
            table.cell(tbl, 0, nRow, "n=" + str.tostring(n),         bgcolor=hdrBg, text_color=hdrTxt, text_size=sz, text_font_family=font.family_monospace)
            table.cell(tbl, 1, nRow, str.tostring(lookback) + "d lb", bgcolor=hdrBg, text_color=hdrTxt, text_size=sz)
            table.cell(tbl, 2, nRow, "",                               bgcolor=hdrBg, text_color=hdrTxt, text_size=sz)
            table.cell(tbl, 3, nRow, "",                               bgcolor=hdrBg, text_color=hdrTxt, text_size=sz)
````
