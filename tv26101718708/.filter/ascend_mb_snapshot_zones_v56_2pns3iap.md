# Ascend MB Snapshot Zones v5.6

- url: https://www.tradingview.com/script/2PNS3Iap-Ascend-MB-Snapshot-Zones-v5-6/
- type: indicator
- pine_id: PUB;1c33366ac2824bafb26fc547ae00c4fc
- version: 1.0

## Description

zones indicator updated

shows the zones for the draogn strat

## Source Code

````pine
//@version=6
indicator("Ascend MB Snapshot Zones — No Dashboard v5.6", overlay = true, max_boxes_count = 500, max_labels_count = 180, max_lines_count = 80)

// v5.6 — same levels / core level engine unchanged. Top-right dashboard hidden by default.
// Backtest context from Databento 1m: best full structure remains 6:30 + 7:00 snapshots only.
// Concept:
// - 6:30 snapshot = First Idea map / opening trap-reclaim battlefield.
// - 7:00 snapshot = Second Idea / 6:30-7 auction resolution.
// - Boxes remain the main visual. Top-right table/dashboard is OFF by default.
// - v5.6 keeps active-zone highlighting, distance fade, and auction rails.
// - No buy/sell signals. No Dragon tags.

max_bars_back(high, 5000)
max_bars_back(low, 5000)
max_bars_back(volume, 5000)

plot(close, "Compiler anchor", display = display.none)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

gCore = "Significant Snapshot MBs"
i_bins = input.int(36, "VP bins", minval = 12, maxval = 120, group = gCore)
i_lvnPct = input.float(28.0, "LVN percentile", minval = 5.0, maxval = 50.0, group = gCore)
i_maxZonesPerSnapshot = input.int(1, "Most significant boxes per snapshot", minval = 1, maxval = 10, group = gCore)
i_minGapTicks = input.int(8, "Min gap between boxes (ticks)", minval = 0, maxval = 200, group = gCore)
i_extendBars = input.int(260, "Extend boxes right", minval = 20, maxval = 1500, group = gCore)
i_keepMaxBoxes = input.int(80, "Keep max boxes", minval = 10, maxval = 500, group = gCore)

gSnap = "Snapshot Times"
i_tz = input.string("America/Los_Angeles", "Timezone", group = gSnap)
i_resetDaily = input.bool(true, "Clear old boxes each new day", group = gSnap)
i_show630 = input.bool(true, "6:30 first idea snapshot", group = gSnap)
i_show700 = input.bool(true, "7:00 second idea snapshot", group = gSnap)
i_show800 = input.bool(false, "Optional 8:00 late snapshot", group = gSnap)

gLookbacks = "Snapshot Sources"
i_historyBars = input.int(1500, "6:30 major historical lookback", minval = 100, maxval = 5000, group = gLookbacks)
i_trendBars = input.int(260, "Recent trend lookback", minval = 30, maxval = 1500, group = gLookbacks)
i_drawHistoryAt630 = input.bool(true, "Draw major historical at 6:30", group = gLookbacks)
i_drawTrendAt630 = input.bool(true, "Draw recent trend at 6:30", group = gLookbacks)
i_drawOpenAuctionAt700 = input.bool(true, "Draw 6:30-7 auction at 7:00", group = gLookbacks)
i_drawTrendAt700 = input.bool(true, "Draw recent trend at 7:00", group = gLookbacks)
i_drawSevenAuctionAt800 = input.bool(false, "Draw 7-8 auction at 8:00", group = gLookbacks)

gOverlap = "Historical Overlap / Confluence"
i_mergeOverlaps = input.bool(true, "Merge overlapping boxes", group = gOverlap)
i_overlapToleranceTicks = input.int(4, "Overlap tolerance (ticks)", minval = 0, maxval = 100, group = gOverlap)
i_confluenceMin = input.int(2, "Confluence starts at overlaps", minval = 2, maxval = 10, group = gOverlap)
i_strongConfluenceMin = input.int(3, "Strong confluence starts at overlaps", minval = 2, maxval = 10, group = gOverlap)
i_extendConfluenceUntilNextSnapshot = input.bool(true, "Extend confluence until next snapshot", group = gOverlap)
i_showConfluenceLabels = input.bool(false, "Show tiny overlap count", group = gOverlap)

gState = "Role State Table"
i_showTable = input.bool(false, "Show top-right dashboard", group = gState)
i_stateLookback = input.int(5, "Role state recent bars", minval = 1, maxval = 30, group = gState)
i_confirmTicks = input.int(4, "Reclaim/fail buffer ticks", minval = 0, maxval = 50, group = gState)

gVis = "Visuals — Boxes Only"
i_histColor = input.color(color.new(#ff9800, 82), "Historical MB box", group = gVis)
i_trendColor = input.color(color.new(#00e676, 80), "Trend MB box", group = gVis)
i_openColor = input.color(color.new(#e91e63, 76), "6:30-7 MB box", group = gVis)
i_secondColor = input.color(color.new(#2196f3, 78), "7-8 MB box", group = gVis)
i_confluenceColor = input.color(color.new(#ffeb3b, 68), "Confluence box", group = gVis)
i_strongConfluenceColor = input.color(color.new(#ff5252, 62), "Strong confluence box", group = gVis)
i_borderColor = input.color(color.new(color.white, 82), "Normal border", group = gVis)
i_confluenceBorder = input.color(color.new(color.yellow, 10), "Confluence border", group = gVis)
i_showLabels = input.bool(false, "Show tiny source labels", group = gVis)

gHtf = "Optional HTF Extreme Rails"
i_showHtfRails = input.bool(true, "Show prior RTH / Globex extreme rails", group = gHtf)
i_showPriorRthRails = input.bool(true, "Prior RTH high/low rails", group = gHtf)
i_showGlobexRails = input.bool(true, "Current Globex high/low rails", group = gHtf)
i_htfRailHalfTicks = input.int(24, "Rail half-width (ticks)", minval = 1, maxval = 200, group = gHtf)
i_htfRailExtendBars = input.int(390, "Rail extend right", minval = 50, maxval = 1500, group = gHtf)
i_priorRthRailColor = input.color(color.new(#9c27b0, 88), "Prior RTH extreme rail", group = gHtf)
i_globexRailColor = input.color(color.new(#03a9f4, 89), "Globex extreme rail", group = gHtf)
i_htfRailBorderColor = input.color(color.new(color.white, 88), "Rail border", group = gHtf)
i_showHtfRailLabels = input.bool(true, "Tiny rail labels", group = gHtf)

gUi = "v5.5 UI Layer"
i_displayMode = input.string("Clean Trading", "Display Mode", options = ["Clean Trading", "Full Study", "Review / Backtest"], group = gUi)
i_highlightActiveZone = input.bool(true, "Highlight active zone", group = gUi)
i_activeZoneTicks = input.int(32, "Active zone distance (ticks)", minval = 1, maxval = 400, group = gUi)
i_showNearestPanel = input.bool(true, "Show nearest level panel", group = gUi)
i_showAuctionRails = input.bool(true, "Show 6:30-7 auction rails", group = gUi)
i_auctionRailExtendBars = input.int(260, "Auction rail extend right", minval = 20, maxval = 1500, group = gUi)
i_auctionRailColor = input.color(color.new(color.white, 72), "Auction rail color", group = gUi)
i_showAuctionRailLabels = input.bool(true, "Tiny auction rail labels", group = gUi)
i_fadeDistantBoxes = input.bool(true, "Fade distant boxes", group = gUi)
i_fullOpacityDistancePts = input.float(80.0, "Full opacity within pts", minval = 0.0, step = 5.0, group = gUi)
i_fadeBeyondPts = input.float(220.0, "Fade beyond pts", minval = 10.0, step = 10.0, group = gUi)

// ══════════════════════════════════════════════════════════════════════════════
// STORAGE
// ══════════════════════════════════════════════════════════════════════════════

var box[] zoneBoxes = array.new_box()
var box[] htfRailBoxes = array.new_box()
var line[] auctionRailLines = array.new_line()
var label[] zoneLabels = array.new_label()
var label[] htfRailLabels = array.new_label()
var label[] auctionRailLabels = array.new_label()
var float[] zoneTops = array.new_float()
var float[] zoneBots = array.new_float()
var int[] zoneCounts = array.new_int()
var bool[] zoneExtendLive = array.new_bool()
var string[] zoneSnapTags = array.new_string()
var color[] zoneBaseColors = array.new_color()

var float firstTop = na
var float firstBot = na
var int firstCount = 0
var string firstSource = "—"
var int firstBar = na

var float secondTop = na
var float secondBot = na
var int secondCount = 0
var string secondSource = "—"
var int secondBar = na

var float lateTop = na
var float lateBot = na
var int lateCount = 0
var string lateSource = "—"
var int lateBar = na

var string activeSnapTag = ""

f_clear_drawings() =>
    if array.size(zoneBoxes) > 0
        for bx in zoneBoxes
            box.delete(bx)
        array.clear(zoneBoxes)
    if array.size(zoneLabels) > 0
        for lb in zoneLabels
            label.delete(lb)
        array.clear(zoneLabels)
    array.clear(zoneTops)
    array.clear(zoneBots)
    array.clear(zoneCounts)
    array.clear(zoneExtendLive)
    array.clear(zoneSnapTags)
    array.clear(zoneBaseColors)

f_clear_htf_rails() =>
    if array.size(htfRailBoxes) > 0
        for bx in htfRailBoxes
            box.delete(bx)
        array.clear(htfRailBoxes)
    if array.size(htfRailLabels) > 0
        for lb in htfRailLabels
            label.delete(lb)
        array.clear(htfRailLabels)

f_clear_auction_rails() =>
    if array.size(auctionRailLines) > 0
        for ln in auctionRailLines
            line.delete(ln)
        array.clear(auctionRailLines)
    if array.size(auctionRailLabels) > 0
        for lb in auctionRailLabels
            label.delete(lb)
        array.clear(auctionRailLabels)

f_draw_auction_rail(float px, string txt) =>
    if i_showAuctionRails and not na(px)
        line ln = line.new(bar_index, px, bar_index + i_auctionRailExtendBars, px, xloc = xloc.bar_index, extend = extend.none, color = i_auctionRailColor, style = line.style_dotted, width = 1)
        array.push(auctionRailLines, ln)
        if i_showAuctionRailLabels
            label lb = label.new(bar_index, px, txt, color = color.new(color.white, 100), textcolor = color.new(color.white, 20), style = label.style_label_right, size = size.tiny)
            array.push(auctionRailLabels, lb)

f_draw_htf_rail(float px, color railColor, string txt) =>
    if not na(px)
        float half = i_htfRailHalfTicks * syminfo.mintick
        int rightX = bar_index + i_htfRailExtendBars
        box bx = box.new(bar_index, px + half, rightX, px - half, bgcolor = railColor, border_color = i_htfRailBorderColor)
        array.push(htfRailBoxes, bx)
        if i_showHtfRailLabels
            label lb = label.new(bar_index, px, txt, color = color.new(color.white, 100), textcolor = color.new(color.white, 25), style = label.style_label_right, size = size.tiny)
            array.push(htfRailLabels, lb)

f_trim_drawings() =>
    while array.size(zoneBoxes) > i_keepMaxBoxes
        oldBox = array.shift(zoneBoxes)
        box.delete(oldBox)
        array.shift(zoneTops)
        array.shift(zoneBots)
        array.shift(zoneCounts)
        array.shift(zoneExtendLive)
        array.shift(zoneSnapTags)
        array.shift(zoneBaseColors)
    while array.size(zoneLabels) > i_keepMaxBoxes
        oldLabel = array.shift(zoneLabels)
        label.delete(oldLabel)

f_stop_live_extensions() =>
    if array.size(zoneExtendLive) > 0
        for j = 0 to array.size(zoneExtendLive) - 1
            array.set(zoneExtendLive, j, false)

f_extend_live_confluence() =>
    if i_extendConfluenceUntilNextSnapshot and array.size(zoneBoxes) > 0
        for j = 0 to array.size(zoneBoxes) - 1
            if array.get(zoneExtendLive, j)
                box bx = array.get(zoneBoxes, j)
                box.set_right(bx, bar_index)

f_far_enough(float mid, float[] chosen) =>
    bool ok = true
    float minGap = i_minGapTicks * syminfo.mintick
    if array.size(chosen) > 0
        for m in chosen
            if math.abs(mid - m) < minGap
                ok := false
    ok

f_already_chosen(int idx, int[] chosenIdxs) =>
    bool used = false
    if array.size(chosenIdxs) > 0
        for oldIdx in chosenIdxs
            if idx == oldIdx
                used := true
    used

f_pick_snapshot_zone(string snapTag) =>
    float bestTop = na
    float bestBot = na
    int bestCount = 0
    string bestSource = "—"
    if array.size(zoneBoxes) > 0
        for j = 0 to array.size(zoneBoxes) - 1
            bool sameSnap = str.contains(array.get(zoneSnapTags, j), snapTag)
            int cnt = array.get(zoneCounts, j)
            bool isBetter = sameSnap and cnt >= i_confluenceMin and cnt >= bestCount
            if isBetter
                bestTop := array.get(zoneTops, j)
                bestBot := array.get(zoneBots, j)
                bestCount := cnt
                bestSource := snapTag + " x" + str.tostring(cnt)
    [bestTop, bestBot, bestCount, bestSource]

f_zone_distance(float top, float bot) =>
    close > top ? close - top : close < bot ? bot - close : 0.0

f_zone_mid(float top, float bot) =>
    (top + bot) / 2.0

f_update_box_ui() =>
    if array.size(zoneBoxes) > 0
        float activeDist = i_activeZoneTicks * syminfo.mintick
        for j = 0 to array.size(zoneBoxes) - 1
            box bx = array.get(zoneBoxes, j)
            float top = array.get(zoneTops, j)
            float bot = array.get(zoneBots, j)
            int cnt = array.get(zoneCounts, j)
            color baseColor = array.get(zoneBaseColors, j)
            float dist = f_zone_distance(top, bot)
            bool activeZone = i_highlightActiveZone and dist <= activeDist
            int fadeTransp = i_fadeDistantBoxes and dist > i_fadeBeyondPts ? 94 : i_fadeDistantBoxes and dist > i_fullOpacityDistancePts ? 88 : na
            color boxColor = activeZone ? color.new(cnt >= i_strongConfluenceMin ? i_strongConfluenceColor : cnt >= i_confluenceMin ? i_confluenceColor : baseColor, 54) : na(fadeTransp) ? baseColor : color.new(baseColor, fadeTransp)
            color borderColor = activeZone ? color.new(color.white, 0) : cnt >= i_confluenceMin ? i_confluenceBorder : i_borderColor
            box.set_bgcolor(bx, boxColor)
            box.set_border_color(bx, borderColor)

f_nearest_level_text(int side) =>
    string txt = "—"
    float bestDist = na
    if array.size(zoneBoxes) > 0
        for j = 0 to array.size(zoneBoxes) - 1
            float top = array.get(zoneTops, j)
            float bot = array.get(zoneBots, j)
            float level = side == 1 ? (close <= bot ? bot : close <= top ? top : na) : (close >= top ? top : close >= bot ? bot : na)
            if not na(level)
                float dist = math.abs(level - close)
                if na(bestDist) or dist < bestDist
                    bestDist := dist
                    txt := (side == 1 ? "Above " : "Below ") + str.tostring(level, format.mintick) + " | " + array.get(zoneSnapTags, j) + " x" + str.tostring(array.get(zoneCounts, j)) + " | " + str.tostring(dist, "#.##") + " pts"
    txt

f_add_or_merge_box(int leftX, int rightX, float top, float bot, color zoneColor, string tag) =>
    float tol = i_overlapToleranceTicks * syminfo.mintick
    int mergeIdx = -1
    if i_mergeOverlaps and array.size(zoneBoxes) > 0
        for j = 0 to array.size(zoneBoxes) - 1
            float oldTop = array.get(zoneTops, j)
            float oldBot = array.get(zoneBots, j)
            bool overlaps = top >= oldBot - tol and bot <= oldTop + tol
            if overlaps and mergeIdx == -1
                mergeIdx := j

    if mergeIdx >= 0
        box oldBx = array.get(zoneBoxes, mergeIdx)
        float mergedTop = math.max(array.get(zoneTops, mergeIdx), top)
        float mergedBot = math.min(array.get(zoneBots, mergeIdx), bot)
        int newCount = array.get(zoneCounts, mergeIdx) + 1
        bool shouldExtendLive = i_extendConfluenceUntilNextSnapshot and newCount >= i_confluenceMin
        array.set(zoneTops, mergeIdx, mergedTop)
        array.set(zoneBots, mergeIdx, mergedBot)
        array.set(zoneCounts, mergeIdx, newCount)
        array.set(zoneExtendLive, mergeIdx, shouldExtendLive)
        array.set(zoneBaseColors, mergeIdx, zoneColor)
        string oldSnapTag = array.get(zoneSnapTags, mergeIdx)
        string mergedSnapTag = activeSnapTag == "" or str.contains(oldSnapTag, activeSnapTag) ? oldSnapTag : oldSnapTag + "+" + activeSnapTag
        array.set(zoneSnapTags, mergeIdx, mergedSnapTag)
        box.set_top(oldBx, mergedTop)
        box.set_bottom(oldBx, mergedBot)
        if shouldExtendLive
            box.set_right(oldBx, bar_index)
        else
            box.set_right(oldBx, math.max(box.get_right(oldBx), rightX))
        color mergedColor = newCount >= i_strongConfluenceMin ? i_strongConfluenceColor : newCount >= i_confluenceMin ? i_confluenceColor : zoneColor
        box.set_bgcolor(oldBx, mergedColor)
        box.set_border_color(oldBx, newCount >= i_confluenceMin ? i_confluenceBorder : i_borderColor)
        if i_showConfluenceLabels
            label lb = label.new(leftX, (mergedTop + mergedBot) / 2.0, "x" + str.tostring(newCount), color = color.new(color.white, 100), textcolor = i_confluenceBorder, style = label.style_label_right, size = size.tiny)
            array.push(zoneLabels, lb)
    else
        box bx = box.new(leftX, top, rightX, bot, bgcolor = zoneColor, border_color = i_borderColor)
        array.push(zoneBoxes, bx)
        array.push(zoneTops, top)
        array.push(zoneBots, bot)
        array.push(zoneCounts, 1)
        array.push(zoneExtendLive, false)
        array.push(zoneSnapTags, activeSnapTag)
        array.push(zoneBaseColors, zoneColor)
        if i_showLabels
            label lb = label.new(leftX, (top + bot) / 2.0, tag, color = color.new(color.white, 100), textcolor = color.new(zoneColor, 0), style = label.style_label_right, size = size.tiny)
            array.push(zoneLabels, lb)
    f_trim_drawings()

// ══════════════════════════════════════════════════════════════════════════════
// SNAPSHOT LVN PROFILE
// ══════════════════════════════════════════════════════════════════════════════

f_draw_lvn_snapshot(int lookback, color zoneColor, string tag) =>
    int lb = math.min(math.max(lookback, 2), bar_index + 1)

    float rangeHigh = high
    float rangeLow = low
    for i = 0 to lb - 1
        rangeHigh := math.max(rangeHigh, high[i])
        rangeLow := math.min(rangeLow, low[i])

    float binSize = (rangeHigh - rangeLow) / i_bins
    if binSize <= 0
        binSize := syminfo.mintick

    float[] binVols = array.new_float(i_bins, 0.0)

    for i = 0 to lb - 1
        float barH = high[i]
        float barL = low[i]
        float barV = volume[i]
        float barRange = math.max(barH - barL, syminfo.mintick)
        for b = 0 to i_bins - 1
            float binBottom = rangeLow + b * binSize
            float binTop = binBottom + binSize
            float intersectLow = math.max(barL, binBottom)
            float intersectHigh = math.min(barH, binTop)
            if intersectHigh > intersectLow
                float allocated = barV * (intersectHigh - intersectLow) / barRange
                array.set(binVols, b, array.get(binVols, b) + allocated)

    float[] sorted = array.copy(binVols)
    array.sort(sorted, order.ascending)
    int lvnIdx = int(math.floor(i_bins * i_lvnPct / 100.0))
    lvnIdx := math.max(0, math.min(i_bins - 1, lvnIdx))
    float lvnThresh = array.get(sorted, lvnIdx)

    float[] chosenMids = array.new_float()
    int[] chosenIdxs = array.new_int()
    int made = 0
    int leftX = bar_index - lb + 1
    int rightX = bar_index + i_extendBars

    for rank = 0 to i_bins - 1
        if made >= i_maxZonesPerSnapshot
            break
        float candidateVol = array.get(sorted, rank)
        if candidateVol > lvnThresh
            break
        for bIdx = 0 to i_bins - 1
            if made >= i_maxZonesPerSnapshot
                break
            float volAtBin = array.get(binVols, bIdx)
            if volAtBin == candidateVol and volAtBin > 0 and not f_already_chosen(bIdx, chosenIdxs)
                float binBottom = rangeLow + bIdx * binSize
                float binTop = binBottom + binSize
                float mid = (binTop + binBottom) / 2.0
                if f_far_enough(mid, chosenMids)
                    f_add_or_merge_box(leftX, rightX, binTop, binBottom, zoneColor, tag)
                    array.push(chosenMids, mid)
                    array.push(chosenIdxs, bIdx)
                    made += 1

// ══════════════════════════════════════════════════════════════════════════════
// TIME WINDOWS / SNAPSHOT COUNTERS
// ══════════════════════════════════════════════════════════════════════════════

in630Minute = not na(time(timeframe.period, "0630-0631", i_tz))
in700Minute = not na(time(timeframe.period, "0700-0701", i_tz))
in800Minute = not na(time(timeframe.period, "0800-0801", i_tz))
inOpenAuction = not na(time(timeframe.period, "0630-0700", i_tz))
inSecondAuction = not na(time(timeframe.period, "0700-0800", i_tz))
inRthSession = not na(time(timeframe.period, "0630-1300", i_tz))
inGlobexSession = not na(time(timeframe.period, "1300-0630", i_tz))

new630 = in630Minute and not in630Minute[1]
new700 = in700Minute and not in700Minute[1]
new800 = in800Minute and not in800Minute[1]
newDay = ta.change(dayofmonth(time, i_tz)) != 0
newRthSession = inRthSession and not inRthSession[1]
endRthSession = not inRthSession and inRthSession[1]
newGlobexSession = inGlobexSession and not inGlobexSession[1]

var int openAuctionBars = 0
var int secondAuctionBars = 0
var float rthHigh = na
var float rthLow = na
var float priorRthHigh = na
var float priorRthLow = na
var float globexHigh = na
var float globexLow = na
var float openAuctionHigh = na
var float openAuctionLow = na
var float openAuctionMid = na

if newDay
    openAuctionBars := 0
    secondAuctionBars := 0
    firstTop := na
    firstBot := na
    firstCount := 0
    firstSource := "—"
    firstBar := na
    secondTop := na
    secondBot := na
    secondCount := 0
    secondSource := "—"
    secondBar := na
    lateTop := na
    lateBot := na
    lateCount := 0
    lateSource := "—"
    lateBar := na
    openAuctionHigh := na
    openAuctionLow := na
    openAuctionMid := na
    f_clear_htf_rails()
    f_clear_auction_rails()
    if i_resetDaily
        f_clear_drawings()

if newGlobexSession
    globexHigh := high
    globexLow := low
else if inGlobexSession
    globexHigh := na(globexHigh) ? high : math.max(globexHigh, high)
    globexLow := na(globexLow) ? low : math.min(globexLow, low)

if newRthSession
    rthHigh := high
    rthLow := low
else if inRthSession
    rthHigh := na(rthHigh) ? high : math.max(rthHigh, high)
    rthLow := na(rthLow) ? low : math.min(rthLow, low)

if endRthSession
    priorRthHigh := rthHigh
    priorRthLow := rthLow

if new630 and i_showHtfRails
    f_clear_htf_rails()
    if i_showPriorRthRails
        f_draw_htf_rail(priorRthHigh, i_priorRthRailColor, "PDH")
        f_draw_htf_rail(priorRthLow, i_priorRthRailColor, "PDL")
    if i_showGlobexRails
        f_draw_htf_rail(globexHigh, i_globexRailColor, "ONH")
        f_draw_htf_rail(globexLow, i_globexRailColor, "ONL")

if new630
    openAuctionBars := 0
    openAuctionHigh := na
    openAuctionLow := na
    openAuctionMid := na
    f_clear_auction_rails()

if inOpenAuction
    openAuctionBars += 1
    openAuctionHigh := na(openAuctionHigh) ? high : math.max(openAuctionHigh, high)
    openAuctionLow := na(openAuctionLow) ? low : math.min(openAuctionLow, low)
    openAuctionMid := (openAuctionHigh + openAuctionLow) / 2.0

if new700
    secondAuctionBars := 0
    if i_showAuctionRails
        f_draw_auction_rail(openAuctionHigh, "Auction High")
        f_draw_auction_rail(openAuctionMid, "Auction Mid")
        f_draw_auction_rail(openAuctionLow, "Auction Low")

if inSecondAuction
    secondAuctionBars += 1

snapshotNow = (new630 and i_show630) or (new700 and i_show700) or (new800 and i_show800)
f_extend_live_confluence()
if snapshotNow
    f_stop_live_extensions()

// ══════════════════════════════════════════════════════════════════════════════
// SNAPSHOTS — only 6:30 and 7:00 by default
// ══════════════════════════════════════════════════════════════════════════════

if new630 and i_show630
    activeSnapTag := "FIRST"
    if i_drawHistoryAt630
        f_draw_lvn_snapshot(i_historyBars, i_histColor, "FIRST HIST")
    if i_drawTrendAt630
        f_draw_lvn_snapshot(i_trendBars, i_trendColor, "FIRST TREND")
    activeSnapTag := ""

if new700 and i_show700
    activeSnapTag := "SECOND"
    if i_drawOpenAuctionAt700 and openAuctionBars[1] >= 2
        f_draw_lvn_snapshot(openAuctionBars[1], i_openColor, "SECOND 6:30-7")
    if i_drawTrendAt700
        f_draw_lvn_snapshot(i_trendBars, i_trendColor, "SECOND TREND")
    activeSnapTag := ""

if new800 and i_show800
    activeSnapTag := "LATE"
    if i_drawSevenAuctionAt800 and secondAuctionBars[1] >= 2
        f_draw_lvn_snapshot(secondAuctionBars[1], i_secondColor, "LATE 7-8")
    activeSnapTag := ""

[_ft, _fb, _fc, _fs] = f_pick_snapshot_zone("FIRST")
firstTop := _ft
firstBot := _fb
firstCount := _fc
firstSource := _fs

[_st, _sb, _sc, _ss] = f_pick_snapshot_zone("SECOND")
secondTop := _st
secondBot := _sb
secondCount := _sc
secondSource := _ss

[_lt, _lb, _lc, _ls] = f_pick_snapshot_zone("LATE")
lateTop := _lt
lateBot := _lb
lateCount := _lc
lateSource := _ls

f_update_box_ui()

// ══════════════════════════════════════════════════════════════════════════════
// ROLE STATE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

f_role_state(float top, float bot) =>
    string state = "no box"
    color stateColor = color.gray
    float buf = i_confirmTicks * syminfo.mintick
    if not na(top) and not na(bot)
        bool above = close > top + buf
        bool below = close < bot - buf
        bool inside = not above and not below
        bool wasBelow = close[1] < bot - buf
        bool wasAbove = close[1] > top + buf
        bool recentTouch = ta.highest(high, i_stateLookback) >= bot and ta.lowest(low, i_stateLookback) <= top
        bool recentRejectFromBelow = below and ta.highest(high, i_stateLookback) >= bot
        bool recentRejectFromAbove = above and ta.lowest(low, i_stateLookback) <= top
        if inside
            state := "testing box"
            stateColor := color.yellow
        else if above and wasBelow
            state := "reclaiming above"
            stateColor := color.lime
        else if below and wasAbove
            state := "failing below"
            stateColor := color.red
        else if above and recentRejectFromAbove
            state := "holding above"
            stateColor := color.lime
        else if below and recentRejectFromBelow
            state := "rejecting below"
            stateColor := color.red
        else if above
            state := "above / accepted"
            stateColor := color.new(color.lime, 0)
        else if below
            state := "below / accepted"
            stateColor := color.new(color.red, 0)
        else if recentTouch
            state := "reacting"
            stateColor := color.orange
    [state, stateColor]

f_zone_text(float top, float bot, int count) =>
    na(top) or na(bot) ? "—" : str.tostring(bot, format.mintick) + "–" + str.tostring(top, format.mintick) + " x" + str.tostring(count)

[firstState, firstColor] = f_role_state(firstTop, firstBot)
[secondState, secondColor] = f_role_state(secondTop, secondBot)
[lateState, lateColor] = f_role_state(lateTop, lateBot)

nearestAboveText = f_nearest_level_text(1)
nearestBelowText = f_nearest_level_text(-1)

var table t = table.new(position.top_right, 3, 8, border_width = 1)
if i_showTable and barstate.islast
    table.cell(t, 0, 0, "Ascend MB v5.5", bgcolor = color.new(color.black, 0), text_color = color.white)
    table.cell(t, 1, 0, i_displayMode, bgcolor = color.new(color.black, 0), text_color = color.white)
    table.cell(t, 2, 0, "Role", bgcolor = color.new(color.black, 0), text_color = color.white)

    table.cell(t, 0, 1, "6:30 First Idea", text_color = color.white)
    table.cell(t, 1, 1, f_zone_text(firstTop, firstBot, firstCount), text_color = color.white)
    table.cell(t, 2, 1, firstState, text_color = color.white, bgcolor = color.new(firstColor, 70))

    table.cell(t, 0, 2, "7:00 Second Idea", text_color = color.white)
    table.cell(t, 1, 2, f_zone_text(secondTop, secondBot, secondCount), text_color = color.white)
    table.cell(t, 2, 2, secondState, text_color = color.white, bgcolor = color.new(secondColor, 70))

    table.cell(t, 0, 3, "8:00 Optional", text_color = color.new(color.white, 35))
    table.cell(t, 1, 3, f_zone_text(lateTop, lateBot, lateCount), text_color = color.new(color.white, 35))
    table.cell(t, 2, 3, i_show800 ? lateState : "off", text_color = color.new(color.white, 35), bgcolor = i_show800 ? color.new(lateColor, 75) : color.new(color.black, 80))

    table.cell(t, 0, 4, "Nearest Above", text_color = i_showNearestPanel ? color.white : color.new(color.white, 75))
    table.cell(t, 1, 4, i_showNearestPanel ? nearestAboveText : "off", text_color = i_showNearestPanel ? color.white : color.new(color.white, 75))
    table.cell(t, 2, 4, "target/magnet", text_color = color.new(color.white, 20), bgcolor = color.new(color.gray, 82))

    table.cell(t, 0, 5, "Nearest Below", text_color = i_showNearestPanel ? color.white : color.new(color.white, 75))
    table.cell(t, 1, 5, i_showNearestPanel ? nearestBelowText : "off", text_color = i_showNearestPanel ? color.white : color.new(color.white, 75))
    table.cell(t, 2, 5, "support/risk", text_color = color.new(color.white, 20), bgcolor = color.new(color.gray, 82))

    table.cell(t, 0, 6, "Auction Mid", text_color = color.white)
    table.cell(t, 1, 6, na(openAuctionMid) ? "—" : str.tostring(openAuctionMid, format.mintick), text_color = color.white)
    table.cell(t, 2, 6, i_showAuctionRails ? "rail on" : "rail off", text_color = color.white, bgcolor = color.new(color.gray, 75))

    table.cell(t, 0, 7, "Read", text_color = color.white)
    table.cell(t, 1, 7, "boxes = battlefield", text_color = color.white)
    table.cell(t, 2, 7, "not signals", text_color = color.white, bgcolor = color.new(color.gray, 75))
````
