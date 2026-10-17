# Price Projection [FEELS]

- url: https://www.tradingview.com/script/NMVlhZV7-Price-Projection-FEELS/
- type: indicator
- pine_id: PUB;e6716c685e374c1d95b307f4e405023d
- version: 2.0

## Description

What happened the last time price looked like this? Price Projection finds every similar window in the chart's history and shows what came after. Descriptive, not predictive.

The script takes the most recent window of bars as a search pattern, scans the chart's own history for past windows that moved in a similar shape, and aggregates what happened after those past windows into a forward picture: ghost candles for the typical path, a band for the spread of outcomes, and a dashboard of descriptive statistics. Every number on the chart describes past behavior on the current symbol. Nothing is a prediction.

[b]How it works[/b]

The engine runs entirely on the chart's open, high, low and close. There are no external data feeds, no security() calls, no off-chart inputs.

Similarity is measured as a Pearson correlation between the current window and each historical window, computed on log prices so that a move is compared by shape rather than by absolute size. A coarse pass over sampled points ranks every candidate window; the best matches are then confirmed at full resolution. A spacing filter prevents a single historical episode from supplying most of the sample, and similarity-weighting gives closer matches more influence on the aggregate path.

Each accepted analog is anchored to the close at the end of its window. The forward bars of every analog are expressed as ratios to that anchor, then re-based onto the current price. The ghost candles are the weighted aggregate of those analog continuations. The band contains the middle portion of analog outcomes at each step (interquartile by default, adjustable). The dashboard reports the median outcome, the share of analogs that closed higher, and the best and worst analog result.

https://www.tradingview.com/x/GWuQvJaa/

[b]The walk-forward check[/b]

A projection tool is only as honest as its track record, so the script builds one into the dashboard. It re-runs the same analog engine at evenly spaced historical checkpoints. At each checkpoint it uses only the data that existed at that point in time, with no lookahead, and compares the analog statistics against what price actually did afterward.

Two results are reported. Direction hits is the share of checkpoints where the realized move matched the direction of the analog median. Close inside band is the share where the realized close landed inside the outcome band; a well-calibrated band sits near its coverage setting, which is shown as the target next to it.

These numbers are not always flattering, and that is the point. On some symbols and timeframes the analogs carry information and the figures are strong; on others they sit near a coin flip, and the script shows that plainly instead of hiding it. Read the walk-forward row before trusting the projection on any given chart.

https://www.tradingview.com/x/sjxvBaXx/

The screenshot above shows the check returning weak figures on a chart where the recent structure has not been informative. That is the tool working correctly, not failing: it is telling you the analogs are noise here.

https://www.tradingview.com/x/A8FqLOXS/

[b]How to read it[/b]


-[b]Ghost candles[/b] and the average path show the typical analog continuation, re-based onto current price.
-[b]The band shows[/b] the spread of outcomes, not a guarantee. Wider band means analogs disagreed more.
-[b]The dashboard[/b] separates the median outcome (the typical analog) from best and worst (the extremes). When the median and the average path point different ways, the sample is skewed and the band is doing the real work.
-[b]The walk-forward[/b] row tells you how much the analogs have been worth on this exact symbol and timeframe.

https://www.tradingview.com/x/ZP1kjg8w/

[b]Inputs[/b]

Pattern window sets how many recent bars form the search pattern. Scan depth sets how far back the search runs. Analogs used, Min similarity and Min analogs control how many matches are accepted and how strict the match must be; if too few pass, the sample auto-relaxes toward the next-best matches down to a floor, and the dashboard flags when it has done so. Projection horizon sets how far ahead the forward picture is drawn. Band coverage sets the width of the outcome band and the calibration target for the walk-forward band check. The walk-forward section controls the checkpoint count and per-checkpoint scan depth. Visual toggles cover aggregate candles, band, analog paths, average path, price targets, the live-bar divider, the current-pattern box, and the analog-window highlights and labels.

A larger pattern window means fewer but broader matches: on a weekly chart, widening it toward 100 bars finds a handful of full-cycle analogs instead of many short ones. Tune it to the structure your strategy trades.

https://www.tradingview.com/x/77pSmKSw/

[b]Repainting[/b]

This is a forward projection and it recalculates. On every new bar the engine re-scans and redraws, so the projected path, band and statistics update as the pattern changes. The projection is always anchored to the most recent confirmed bar, not to the still-forming bar. Treat the forward drawing as a description of historical analogs as of the current bar, which will move as new bars arrive. The walk-forward statistics are computed on confirmed historical bars and do not repaint.

[b]Notes[/b]

The script is a descriptive analysis tool. It does not issue buy or sell signals and the statistics are not financial advice. Historical analog behavior does not guarantee future results.

Mashup statement: this is an original implementation. The correlation-based analog search, the log-price similarity space, the anchored ratio aggregation, the outcome band, and the built-in walk-forward check are written from scratch and are not derived from another author's script.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FeelsStrategy

//@version=6
indicator("Price Projection [FEELS]", overlay = true, max_bars_back = 5000,
     max_lines_count = 500, max_boxes_count = 500, max_labels_count = 100, max_polylines_count = 100)

//--- constants
int SAMPLES = 8          // coarse-pass sample points per window
float HARD_FLOOR = 0.60  // absolute minimum similarity for auto-relaxed analogs

//--- inputs · pattern matching
grpM = "Pattern Matching"
winLen    = input.int(40,     "Pattern window (bars)",     minval = 10,  maxval = 100,               group = grpM, tooltip = "Recent price structure used as the search pattern. Larger windows match broader structures, smaller windows react to local shapes.")
scanDepth = input.int(5000,   "Scan depth (bars)",         minval = 500, maxval = 20000, step = 500, group = grpM, tooltip = "How far back the engine searches for similar windows. Automatically capped at the history actually available for the symbol.")
topK      = input.int(20,     "Analogs used (top K)",      minval = 3,   maxval = 50,                group = grpM, tooltip = "Number of best-matching historical windows used to build the projection.")
minK      = input.int(8,      "Min analogs (auto-relax)",  minval = 0,   maxval = 20,                group = grpM, tooltip = "If fewer analogs pass Min similarity, the engine keeps accepting the next-best windows down to a hard floor of 0.60, so the sample never collapses. Relaxed analogs receive minimal weight. Set 0 to disable.")
minSim    = input.float(0.75, "Min similarity",            minval = 0.50, maxval = 0.98, step = 0.01, group = grpM, tooltip = "Minimum Pearson correlation (computed on log prices) between the current window and a historical window.")
gapMult   = input.float(0.50, "Analog spacing (x window)", minval = 0.25, maxval = 2.00, step = 0.25, group = grpM, tooltip = "Minimum distance between two accepted analogs, so a single historical episode cannot dominate the sample.")

//--- inputs · projection
grpP = "Projection"
horizon = input.int(30, "Projection horizon (bars)", minval = 5, maxval = 100, group = grpP, tooltip = "How many bars ahead the analog continuations are aggregated and drawn.")
wMode   = input.string("Similarity-weighted", "Analog weighting", options = ["Similarity-weighted", "Equal"], group = grpP, tooltip = "Similarity-weighted gives closer matches more influence on the projected path. Equal treats every accepted analog the same.")
bandCov = input.int(50, "Band coverage (%)", minval = 10, maxval = 90, step = 10, group = grpP, tooltip = "The band contains the middle X% of analog outcomes at each projected bar. 50 = interquartile range. Also used as the calibration target for the walk-forward band check.")

//--- inputs · walk-forward check
grpW = "Walk-forward Check"
wfOn     = input.bool(true, "Run walk-forward check", group = grpW, tooltip = "Re-runs the analog engine at evenly spaced historical checkpoints, using only data available before each checkpoint, and measures how realized price related to the analog statistics. No lookahead. Checkpoints without enough forward history are skipped.")
wfChecks = input.int(30,   "Checkpoints",               minval = 10,  maxval = 60,               group = grpW, tooltip = "Number of historical checkpoints requested. Fewer may run on symbols with limited history.")
wfDepth  = input.int(1500, "Scan depth per checkpoint", minval = 500, maxval = 5000, step = 500, group = grpW, tooltip = "How far back each checkpoint scan searches. Smaller than the live scan to keep computation light.")

//--- inputs · visuals
grpV = "Visuals"
showGhost   = input.bool(true, "Ghost candles", group = grpV, inline = "g", tooltip = "Weighted-average analog OHLC drawn as semi-transparent candles ahead of price. The number sets body thickness in pixels.")
bodyW       = input.int(4, "", minval = 2, maxval = 8, group = grpV, inline = "g")
showBand    = input.bool(true, "Outcome band", group = grpV, tooltip = "Filled area containing the middle X% of analog outcomes at each projected bar (set by Band coverage).")
showPaths   = input.bool(false, "Analog paths", group = grpV, inline = "p", tooltip = "Each analog's continuation drawn as a thin line from the current price. By outcome colors paths by their final result; Neutral draws a uniform cloud of scenarios.")
pathColMode = input.string("By outcome", "", options = ["By outcome", "Neutral"], group = grpV, inline = "p")
showPath    = input.bool(true, "Average path", group = grpV, tooltip = "Dashed line through the weighted-average analog close at each projected bar.")
targetMode  = input.string("Median + band edges", "Price targets at horizon", options = ["Off", "Median only", "Median + band edges"], group = grpV, tooltip = "Price labels at the end of the projection: the average-path level and, optionally, the upper and lower band edges, each with its percentage distance from the anchor close.")
showDiv     = input.bool(true, "Divider at live bar", group = grpV, inline = "d", tooltip = "Vertical line separating actual price history from the projected area. Color, style and width are customizable.")
divCol      = input.color(color.new(#94A3B8, 60), "", group = grpV, inline = "d")
divStyleS   = input.string("Dashed", "", options = ["Dashed", "Dotted", "Solid"], group = grpV, inline = "d")
divWidth    = input.int(2, "", minval = 1, maxval = 3, group = grpV, inline = "d")
showInfo    = input.bool(true, "Projection info label", group = grpV, tooltip = "Floating label above the projection showing the analog count and average similarity.")
lblSzS      = input.string("Small", "Text size", options = ["Small", "Normal", "Large", "Huge"], group = grpV, tooltip = "Size of every on-chart caption: the info label, price targets, current-pattern and analog-window labels. Bump it up for screenshots and presentations. The dashboard has its own size setting.")

//--- inputs · pattern & analog windows
grpS = "Pattern & Analog Windows"
showCur     = input.bool(true,  "Current pattern box", group = grpS, inline = "cur", tooltip = "Outlines the recent window used as the search pattern, so it reads as the sample being matched. Color, style and width are customizable.")
curCol      = input.color(color.new(#F8FAFC, 0), "", group = grpS, inline = "cur")
curStyleS   = input.string("Dashed", "", options = ["Dashed", "Dotted", "Solid"], group = grpS, inline = "cur")
curWidth    = input.int(2, "", minval = 1, maxval = 4, group = grpS, inline = "cur")
showCurLbl  = input.bool(true, "Current pattern label", group = grpS, inline = "curl", tooltip = "Caption above the current-pattern box. Editable text.")
curLblTxt   = input.string("current pattern", "", group = grpS, inline = "curl")
showSrc     = input.bool(true, "Highlight analog windows", group = grpS, tooltip = "Shaded boxes over the historical windows used as analogs, so the source of the projection stays visible.")
showSrcLbl  = input.bool(true, "Analog window label", group = grpS, inline = "sl", tooltip = "Caption above each analog window. The editable prefix tells new viewers what the box is; the number is the analog's similarity.")
srcLblTxt   = input.string("similar pattern", "", group = grpS, inline = "sl")
srcLblSim   = input.bool(true, "show similarity value", group = grpS, inline = "sl2", tooltip = "Append the analog's similarity score to the label.")
srcLblDate  = input.bool(false, "show date", group = grpS, inline = "sl2", tooltip = "Append the analog window's start date to the label.")
colSrc      = input.color(color.new(#3B82F6, 90), "Analog window fill", group = grpS)

//--- inputs · visuals · colors
grpC = "Colors"
colUp   = input.color(color.new(#22C55E, 30), "Up",   group = grpC, inline = "c1")
colDn   = input.color(color.new(#EF4444, 30), "Down", group = grpC, inline = "c1")
colBand = input.color(color.new(#3B82F6, 85), "Band", group = grpC, inline = "c2")
colPath = input.color(color.new(#94A3B8, 25), "Path", group = grpC, inline = "c2")

//--- inputs · dashboard
grpD = "Dashboard"
showDash = input.bool(true, "Show dashboard", group = grpD)
dashPosS = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpD)
dashSzS  = input.string("Small", "Size", options = ["Tiny", "Small", "Normal"], group = grpD)

//--- inputs · alerts
grpA = "Alerts"
consThr = input.float(65, "Consensus threshold (%)", minval = 55, maxval = 90, step = 5, group = grpA, tooltip = "Share of analogs that must agree on the direction at the horizon for the consensus alerts to fire. 65 means: alert when at least 65% of analogs closed higher (bullish) or at least 65% closed lower (bearish).")

dashPos = dashPosS == "Top right" ? position.top_right : dashPosS == "Top left" ? position.top_left : dashPosS == "Bottom right" ? position.bottom_right : position.bottom_left
dashSz  = dashSzS == "Tiny" ? size.tiny : dashSzS == "Small" ? size.small : size.normal
lblSz   = lblSzS == "Huge" ? size.huge : lblSzS == "Large" ? size.large : lblSzS == "Normal" ? size.normal : size.small

//--- derived
float bandPLo = (100.0 - bandCov) / 2.0
float bandPHi = 100.0 - bandPLo
divStyle = divStyleS == "Dashed" ? line.style_dashed : divStyleS == "Dotted" ? line.style_dotted : line.style_solid
curStyle = curStyleS == "Dashed" ? line.style_dashed : curStyleS == "Dotted" ? line.style_dotted : line.style_solid

//--- dashboard palette
color D_BG     = color.new(#0F172A, 10)
color D_FRAME  = color.new(#334155, 0)
color D_LABEL  = color.new(#94A3B8, 0)
color D_VALUE  = color.new(#E2E8F0, 0)
color D_GREEN  = color.new(#22C55E, 0)
color D_RED    = color.new(#EF4444, 0)
color D_ORANGE = color.new(#F97316, 0)

//--- data storage · closed bars only
var aO  = array.new<float>()
var aH  = array.new<float>()
var aL  = array.new<float>()
var aC  = array.new<float>()
var aLC = array.new<float>()  // log closes for similarity space
var aBI = array.new<int>()    // bar_index map for analog highlights
var aTM = array.new<int>()    // bar time map for date labels

int maxStore = scanDepth + winLen + horizon + 10

if barstate.isconfirmed
    array.push(aO,  open)
    array.push(aH,  high)
    array.push(aL,  low)
    array.push(aC,  close)
    array.push(aLC, math.log(close))
    array.push(aBI, bar_index)
    array.push(aTM, time)
    if array.size(aC) > maxStore
        array.shift(aO)
        array.shift(aH)
        array.shift(aL)
        array.shift(aC)
        array.shift(aLC)
        array.shift(aBI)
        array.shift(aTM)

//--- drawing registries
var ghostLines = array.new<line>()
var srcBoxes   = array.new<box>()
var polys      = array.new<polyline>()
var infoLabels = array.new<label>()

wipeAll() =>
    for ln in ghostLines
        line.delete(ln)
    array.clear(ghostLines)
    for bx in srcBoxes
        box.delete(bx)
    array.clear(srcBoxes)
    for pl in polys
        polyline.delete(pl)
    array.clear(polys)
    for lb in infoLabels
        label.delete(lb)
    array.clear(infoLabels)

//--- pearson correlation between two windows of `src`, evaluated at offsets `offs`
pearsonAt(array<float> src, int s1, int s2, array<int> offs) =>
    int m = array.size(offs)
    float sx  = 0.0
    float sy  = 0.0
    float sxx = 0.0
    float syy = 0.0
    float sxy = 0.0
    for k = 0 to m - 1
        int off = array.get(offs, k)
        float x = array.get(src, s1 + off)
        float y = array.get(src, s2 + off)
        sx  += x
        sy  += y
        sxx += x * x
        syy += y * y
        sxy += x * y
    float num = m * sxy - sx * sy
    float den = math.sqrt(math.max(m * sxx - sx * sx, 0.0) * math.max(m * syy - sy * sy, 0.0))
    den > 0 ? num / den : 0.0

fmtPct(float v) =>
    (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

fmtDur(float secs) =>
    secs >= 86400 ? "~" + str.tostring(secs / 86400.0, "#.#") + "d" :
     secs >= 3600 ? "~" + str.tostring(secs / 3600.0, "#.#") + "h" :
     "~" + str.tostring(secs / 60.0, "#") + "m"

//--- dashboard handle
var table dash = na

//--- alert state · exposed from the last-bar scan
var float gPctUp   = na
var float gMedMove = na

//--- scan engine · runs once per bar on the live edge
var int scannedAt = -1

if barstate.islast and bar_index != scannedAt
    scannedAt := bar_index
    wipeAll()

    int n = array.size(aC)  // bars actually stored = real buffer limit
    int K = 0
    int scanned = 0
    bool relaxed = false
    float avgR      = na
    float pctUp     = na
    float medMove   = na
    float bestMove  = na
    float worstMove = na
    int wfDone    = 0
    int wfDirHit  = 0
    int wfBandHit = 0
    int wfReq     = 0

    if n >= 2 * winLen + horizon + 5
        int curStart = n - winLen
        // bounds use n (stored bars), not requested depth, to stay inside the buffer
        int sMin = math.max(0, n - scanDepth)
        int sMax = n - winLen - horizon - 1   // last window that still has `horizon` bars of realized data after it
        sMax := math.min(sMax, n - 2 * winLen)

        if sMax >= sMin
            //--- sample offsets
            offsC = array.new<int>()
            for k = 0 to SAMPLES - 1
                array.push(offsC, math.round(k * (winLen - 1) * 1.0 / (SAMPLES - 1)))
            offsF = array.new<int>()
            for k = 0 to winLen - 1
                array.push(offsF, k)

            //--- coarse pass over all candidate windows
            coarseR = array.new<float>()
            coarseS = array.new<int>()
            for s = sMin to sMax
                array.push(coarseR, pearsonAt(aLC, s, curStart, offsC))
                array.push(coarseS, s)
            scanned := array.size(coarseR)

            //--- best-first selection: spacing filter + full-resolution confirmation
            sortIdx = array.sort_indices(coarseR, order.descending)
            accS = array.new<int>()
            accR = array.new<float>()
            int minGap = math.max(1, math.round(winLen * gapMult))
            int ptr = 0
            int total = math.min(array.size(sortIdx), 2500)
            while ptr < total and array.size(accS) < topK
                int ci = array.get(sortIdx, ptr)
                if array.get(coarseR, ci) < minSim - 0.10
                    break
                int s = array.get(coarseS, ci)
                bool spaced = true
                int acc = array.size(accS)
                if acc > 0
                    for k = 0 to acc - 1
                        if math.abs(s - array.get(accS, k)) < minGap
                            spaced := false
                            break
                if spaced
                    float rf = pearsonAt(aLC, s, curStart, offsF)
                    if rf >= minSim
                        array.push(accS, s)
                        array.push(accR, rf)
                ptr += 1

            //--- auto-relax: guarantee a minimum sample down to the hard floor
            if array.size(accS) < minK
                int ptr2 = 0
                while ptr2 < total and array.size(accS) < minK
                    int ci = array.get(sortIdx, ptr2)
                    if array.get(coarseR, ci) < HARD_FLOOR - 0.10
                        break
                    int s = array.get(coarseS, ci)
                    bool spaced = true
                    int acc = array.size(accS)
                    if acc > 0
                        for k = 0 to acc - 1
                            if math.abs(s - array.get(accS, k)) < minGap
                                spaced := false
                                break
                    if spaced
                        float rf = pearsonAt(aLC, s, curStart, offsF)
                        if rf >= HARD_FLOOR
                            array.push(accS, s)
                            array.push(accR, rf)
                            relaxed := true
                    ptr2 += 1

            K := array.size(accS)

            if K > 0
                float lastC = array.get(aC, n - 1)

                //--- analog weights · relaxed analogs receive minimal weight
                wts = array.new<float>()
                float wSum = 0.0
                float rSum = 0.0
                for k = 0 to K - 1
                    float w = wMode == "Equal" ? 1.0 : math.max(array.get(accR, k) - minSim + 0.02, 0.02)
                    array.push(wts, w)
                    wSum += w
                    rSum += array.get(accR, k)
                avgR := rSum / K

                //--- per-step aggregation in ratio space, anchored to each analog's window-end close
                projO = array.new<float>()
                projH = array.new<float>()
                projL = array.new<float>()
                projC = array.new<float>()
                bandU = array.new<float>()
                bandL = array.new<float>()

                for j = 1 to horizon
                    float so = 0.0
                    float sh = 0.0
                    float sl = 0.0
                    float sc = 0.0
                    cr = array.new<float>()
                    for k = 0 to K - 1
                        int e = array.get(accS, k) + winLen - 1
                        float anchor = array.get(aC, e)
                        float w = array.get(wts, k)
                        so += w * array.get(aO, e + j) / anchor
                        sh += w * array.get(aH, e + j) / anchor
                        sl += w * array.get(aL, e + j) / anchor
                        float rc = array.get(aC, e + j) / anchor
                        sc += w * rc
                        array.push(cr, rc)
                    array.push(projO, lastC * so / wSum)
                    array.push(projH, lastC * sh / wSum)
                    array.push(projL, lastC * sl / wSum)
                    array.push(projC, lastC * sc / wSum)
                    array.push(bandU, lastC * array.percentile_linear_interpolation(cr, bandPHi))
                    array.push(bandL, lastC * array.percentile_linear_interpolation(cr, bandPLo))

                //--- outcome statistics at the horizon
                fin = array.new<float>()
                int ups = 0
                for k = 0 to K - 1
                    int e = array.get(accS, k) + winLen - 1
                    float rc = array.get(aC, e + horizon) / array.get(aC, e)
                    array.push(fin, rc)
                    if rc > 1.0
                        ups += 1
                pctUp     := 100.0 * ups / K
                medMove   := (array.percentile_linear_interpolation(fin, 50.0) - 1.0) * 100.0
                bestMove  := (array.max(fin) - 1.0) * 100.0
                worstMove := (array.min(fin) - 1.0) * 100.0

                //--- drawing · band first, candles and labels on top
                int b = bar_index
                // replay-safe floor: in bar replay TradingView shrinks the available bar_index
                // lookback as playback advances, so a box anchored too far back errors out.
                // only draw objects whose left edge is within drawBack bars of the live bar.
                int drawBack  = math.min(scanDepth, n - 1)
                int drawFloor = b - drawBack

                if showBand
                    pts = array.new<chart.point>()
                    for j = 1 to horizon
                        array.push(pts, chart.point.from_index(b + j, array.get(bandU, j - 1)))
                    for j = 1 to horizon
                        array.push(pts, chart.point.from_index(b + horizon - j + 1, array.get(bandL, horizon - j)))
                    array.push(polys, polyline.new(pts, curved = false, closed = true, xloc = xloc.bar_index, line_color = color.new(colBand, 70), fill_color = colBand))

                if showPaths
                    for k = 0 to K - 1
                        int e = array.get(accS, k) + winLen - 1
                        float anchor = array.get(aC, e)
                        ptsK = array.new<chart.point>()
                        array.push(ptsK, chart.point.from_index(b, lastC))
                        for j = 1 to horizon
                            array.push(ptsK, chart.point.from_index(b + j, lastC * array.get(aC, e + j) / anchor))
                        float finR = array.get(aC, e + horizon) / anchor
                        color pc = pathColMode == "Neutral" ? color.new(colPath, 72) : color.new(finR >= 1.0 ? colUp : colDn, 72)
                        array.push(polys, polyline.new(ptsK, curved = false, closed = false, xloc = xloc.bar_index, line_color = pc, line_width = 1))

                if showPath
                    pts2 = array.new<chart.point>()
                    array.push(pts2, chart.point.from_index(b, lastC))
                    for j = 1 to horizon
                        array.push(pts2, chart.point.from_index(b + j, array.get(projC, j - 1)))
                    array.push(polys, polyline.new(pts2, curved = false, closed = false, xloc = xloc.bar_index, line_color = colPath, line_style = line.style_dashed, line_width = 1))

                if showGhost
                    for j = 1 to horizon
                        float o_ = array.get(projO, j - 1)
                        float h_ = array.get(projH, j - 1)
                        float l_ = array.get(projL, j - 1)
                        float c_ = array.get(projC, j - 1)
                        color cc = c_ >= o_ ? colUp : colDn
                        array.push(ghostLines, line.new(b + j, l_, b + j, h_, xloc = xloc.bar_index, color = color.new(cc, 60), width = 1))
                        array.push(ghostLines, line.new(b + j, math.min(o_, c_), b + j, math.max(o_, c_), xloc = xloc.bar_index, color = cc, width = bodyW))

                if showDiv
                    array.push(ghostLines, line.new(b, lastC * 0.999, b, lastC * 1.001, xloc = xloc.bar_index, extend = extend.both, color = divCol, style = divStyle, width = divWidth))

                if showInfo
                    int xo = b + math.max(1, math.round(horizon * 0.5))
                    string txt = str.tostring(K) + " analogs · avg similarity " + str.tostring(avgR, "0.00")
                    array.push(infoLabels, label.new(xo, array.max(bandU), txt, xloc = xloc.bar_index, style = label.style_label_down, color = color.new(#0F172A, 20), textcolor = D_VALUE, size = lblSz))

                if targetMode != "Off"
                    int xt = b + horizon + 1
                    float cEnd = array.get(projC, horizon - 1)
                    if targetMode == "Median + band edges"
                        float uEnd = array.get(bandU, horizon - 1)
                        float lEnd = array.get(bandL, horizon - 1)
                        array.push(infoLabels, label.new(xt, uEnd, str.tostring(uEnd, format.mintick) + "  " + fmtPct((uEnd / lastC - 1) * 100), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#0F172A, 35), textcolor = D_GREEN, size = lblSz))
                        array.push(infoLabels, label.new(xt, lEnd, str.tostring(lEnd, format.mintick) + "  " + fmtPct((lEnd / lastC - 1) * 100), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#0F172A, 35), textcolor = D_RED, size = lblSz))
                    array.push(infoLabels, label.new(xt, cEnd, str.tostring(cEnd, format.mintick) + "  " + fmtPct((cEnd / lastC - 1) * 100), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#0F172A, 35), textcolor = D_VALUE, size = lblSz))

                //--- analog window boxes + labels
                if showSrc
                    for k = 0 to K - 1
                        int s = array.get(accS, k)
                        int e = s + winLen - 1
                        // replay-safe: skip analogs whose left edge is older than the drawable window
                        if array.get(aBI, s) >= drawFloor
                            float hi = array.get(aH, s)
                            float lo = array.get(aL, s)
                            for i = s + 1 to e
                                hi := math.max(hi, array.get(aH, i))
                                lo := math.min(lo, array.get(aL, i))
                            array.push(srcBoxes, box.new(array.get(aBI, s), hi, array.get(aBI, e), lo, border_color = color.new(colSrc, 55), border_width = 1, bgcolor = colSrc))
                            if showSrcLbl
                                string sl = srcLblTxt
                                if srcLblSim
                                    sl := sl + (str.length(sl) > 0 ? " " : "") + str.tostring(array.get(accR, k), "0.00")
                                if srcLblDate
                                    sl := sl + (str.length(sl) > 0 ? " · " : "") + str.format_time(array.get(aTM, s), "yyyy-MM-dd")
                                if str.length(sl) > 0
                                    array.push(infoLabels, label.new(math.round((array.get(aBI, s) + array.get(aBI, e)) / 2.0), hi, sl, xloc = xloc.bar_index, style = label.style_label_down, color = color.new(#0F172A, 25), textcolor = D_VALUE, size = lblSz))

                //--- current pattern box + label
                if showCur
                    int cs = curStart
                    int ce = n - 1
                    if array.get(aBI, cs) >= drawFloor
                        float chi = array.get(aH, cs)
                        float clo = array.get(aL, cs)
                        for i = cs + 1 to ce
                            chi := math.max(chi, array.get(aH, i))
                            clo := math.min(clo, array.get(aL, i))
                        array.push(srcBoxes, box.new(array.get(aBI, cs), chi, array.get(aBI, ce), clo, border_color = curCol, border_width = curWidth, border_style = curStyle, bgcolor = color.new(curCol, 100)))
                        if showCurLbl
                            array.push(infoLabels, label.new(math.round((array.get(aBI, cs) + array.get(aBI, ce)) / 2.0), chi, curLblTxt, xloc = xloc.bar_index, style = label.style_label_down, color = color.new(#0F172A, 20), textcolor = D_VALUE, size = lblSz))

            //--- walk-forward check · same engine at historical checkpoints, no lookahead, buffer-safe
            if wfOn
                int cLo = 2 * winLen + horizon + 50
                int cHi = n - horizon - 1   // last checkpoint that still has `horizon` realized bars within the buffer
                if cHi > cLo
                    for m = 0 to wfChecks - 1
                        int c = cLo + math.round(m * 1.0 * (cHi - cLo) / math.max(wfChecks - 1, 1))
                        // guard: the realized-outcome bar must exist inside the stored buffer
                        if c - 1 + horizon <= n - 1 and c - 1 >= 0
                            wfReq += 1
                            int cs = c - winLen
                            int wMin = math.max(0, c - wfDepth)
                            int wMax = math.min(c - 2 * winLen, c - winLen - horizon - 1)
                            if wMax > wMin and cs >= 0
                                rArr = array.new<float>()
                                sArr = array.new<int>()
                                for s = wMin to wMax by 2
                                    array.push(rArr, pearsonAt(aLC, s, cs, offsC))
                                    array.push(sArr, s)
                                wIdx = array.sort_indices(rArr, order.descending)
                                sel = array.new<float>()
                                selS = array.new<int>()
                                int p2 = 0
                                int t2 = array.size(wIdx)
                                while p2 < t2 and array.size(sel) < 10
                                    int ci2 = array.get(wIdx, p2)
                                    if array.get(rArr, ci2) < HARD_FLOOR
                                        break
                                    int s2 = array.get(sArr, ci2)
                                    bool ok2 = true
                                    int a2 = array.size(selS)
                                    if a2 > 0
                                        for q = 0 to a2 - 1
                                            if math.abs(s2 - array.get(selS, q)) < minGap
                                                ok2 := false
                                                break
                                    if ok2
                                        int e2 = s2 + winLen - 1
                                        if e2 + horizon <= n - 1
                                            array.push(sel, array.get(aC, e2 + horizon) / array.get(aC, e2))
                                            array.push(selS, s2)
                                    p2 += 1
                                if array.size(sel) >= 3
                                    float md = array.percentile_linear_interpolation(sel, 50.0)
                                    float bU = array.percentile_linear_interpolation(sel, bandPHi)
                                    float bL = array.percentile_linear_interpolation(sel, bandPLo)
                                    float realized = array.get(aC, c - 1 + horizon) / array.get(aC, c - 1)
                                    wfDone += 1
                                    if (md >= 1.0 and realized >= 1.0) or (md < 1.0 and realized < 1.0)
                                        wfDirHit += 1
                                    if realized >= bL and realized <= bU
                                        wfBandHit += 1

    //--- expose scan results for alerts
    gPctUp   := pctUp
    gMedMove := medMove

    //--- dashboard
    if showDash
        if na(dash)
            dash := table.new(dashPos, 2, 11, bgcolor = D_BG, frame_color = D_FRAME, frame_width = 1, border_color = color.new(#1E293B, 0), border_width = 1)
        float wfDirPct  = wfDone > 0 ? 100.0 * wfDirHit / wfDone : na
        float wfBandPct = wfDone > 0 ? 100.0 * wfBandHit / wfDone : na
        float bandDev   = na(wfBandPct) ? na : wfBandPct - bandCov
        color bandCol   = na(bandDev) ? D_VALUE : math.abs(bandDev) <= 10 ? D_GREEN : bandDev < 0 ? D_ORANGE : D_VALUE
        table.cell(dash, 0, 0, "PRICE PROJECTION", text_color = D_VALUE, text_size = dashSz, text_halign = text.align_left)
        table.cell(dash, 1, 0, "v1.1", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 1, "Analogs used", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Historical windows accepted into the sample. Orange when the sample is below the minimum size.")
        table.cell(dash, 1, 1, str.tostring(K), text_color = K >= math.max(minK, 1) ? D_VALUE : D_ORANGE, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 2, "Windows scanned", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Total candidate windows compared against the current pattern.")
        table.cell(dash, 1, 2, str.tostring(scanned, "#,###"), text_color = D_VALUE, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 3, "Avg similarity", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Average Pearson correlation (log prices) between the current window and the accepted analogs.")
        table.cell(dash, 1, 3, na(avgR) ? "—" : str.tostring(avgR, "0.00"), text_color = D_VALUE, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 4, "Horizon", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Projection length in bars and approximate calendar time on this timeframe.")
        table.cell(dash, 1, 4, str.tostring(horizon) + " bars · " + fmtDur(timeframe.in_seconds() * horizon * 1.0), text_color = D_VALUE, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 5, "Higher at horizon", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Share of analogs whose close was above their anchor close at the end of the horizon.")
        table.cell(dash, 1, 5, na(pctUp) ? "—" : str.tostring(pctUp, "#.#") + "%", text_color = na(pctUp) ? D_VALUE : pctUp >= 55 ? D_GREEN : pctUp <= 45 ? D_RED : D_VALUE, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 6, "Median outcome", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Median percentage move across analogs at the end of the horizon.")
        table.cell(dash, 1, 6, na(medMove) ? "—" : fmtPct(medMove), text_color = na(medMove) ? D_VALUE : medMove >= 0 ? D_GREEN : D_RED, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 7, "Best / worst", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Strongest and weakest analog outcome at the end of the horizon.")
        table.cell(dash, 1, 7, na(bestMove) ? "—" : fmtPct(bestMove) + " / " + fmtPct(worstMove), text_color = D_VALUE, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 8, "Direction hits · walk-fwd", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "The engine was re-run at evenly spaced historical checkpoints using only data available at each point (no lookahead). This is the share of checkpoints where the realized move matched the direction of the analog median. Checkpoints without enough forward history are skipped.")
        table.cell(dash, 1, 8, na(wfDirPct) ? "—" : str.tostring(wfDirPct, "#") + "% (" + str.tostring(wfDirHit) + "/" + str.tostring(wfDone) + ")", text_color = na(wfDirPct) ? D_VALUE : wfDirPct >= 55 ? D_GREEN : wfDirPct <= 45 ? D_RED : D_VALUE, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 9, "Close inside band · walk-fwd", text_color = D_LABEL, text_size = dashSz, text_halign = text.align_left, tooltip = "Share of walk-forward checkpoints where the realized close landed inside the outcome band. A well-calibrated band should sit near its coverage setting (the target). Well below target means the band underestimates the real spread on this symbol and timeframe.")
        table.cell(dash, 1, 9, na(wfBandPct) ? "—" : str.tostring(wfBandPct, "#") + "% · target " + str.tostring(bandCov) + "%", text_color = bandCol, text_size = dashSz, text_halign = text.align_right)
        table.cell(dash, 0, 10, "historical analogs · descriptive", text_color = D_LABEL, text_size = size.tiny, text_halign = text.align_left, tooltip = "All statistics describe how price behaved after similar historical windows on this symbol. This is a descriptive analysis tool.")
        table.cell(dash, 1, 10, relaxed ? "auto-relaxed sample" : "", text_color = relaxed and not na(avgR) and avgR < 0.70 ? D_ORANGE : D_LABEL, text_size = size.tiny, text_halign = text.align_right)

//--- alerts · consensus and median direction of the analog sample
bullCons = not na(gPctUp) and gPctUp >= consThr
bearCons = not na(gPctUp) and gPctUp <= 100.0 - consThr
medPos   = not na(gMedMove) and gMedMove > 0
medNeg   = not na(gMedMove) and gMedMove < 0

alertcondition(bullCons and not bullCons[1], "Bullish analog consensus", "Price Projection: the share of analogs that closed higher at the horizon reached the consensus threshold")
alertcondition(bearCons and not bearCons[1], "Bearish analog consensus", "Price Projection: the share of analogs that closed lower at the horizon reached the consensus threshold")
alertcondition(medPos and not medPos[1], "Median outcome turned positive", "Price Projection: the median analog outcome at the horizon turned positive")
alertcondition(medNeg and not medNeg[1], "Median outcome turned negative", "Price Projection: the median analog outcome at the horizon turned negative")
````
