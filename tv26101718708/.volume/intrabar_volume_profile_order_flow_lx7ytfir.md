# Intrabar Volume Profile [Order Flow]

- url: https://www.tradingview.com/script/lx7yTFiR-Intrabar-Volume-Profile-Order-Flow/
- type: indicator
- pine_id: PUB;4482d31413f64fd8b567e61655319689
- version: 1.0

## Description

A volume profile answers one question: at which prices did the volume actually trade? The answer depends entirely on how you distribute each bar's volume across price. Intrabar Volume Profile does it by reading the lower-timeframe intrabars inside every chart bar and placing each intrabar's volume across its own high-low range — so a peak forms at the prices where the volume actually traded, and the Point of Control lands where trading concentrated. It also estimates the buy/sell split from intrabar direction, tells you on the chart that it is an estimate, and hides it when the resolution is too low to mean anything. It is an observation tool, not a signal service.

[b]HOW IT WORKS[/b]

A chart bar only gives you one volume number for a whole price range. To place that volume at prices, you have to know where inside the bar it traded — and that is what the lower timeframe provides. The tool requests the intrabars of each chart bar and works from them.

[list]
[*][b]Intrabar distribution[/b] — each intrabar's volume is spread across its own high-low range, proportionally to how much of each profile row that range covers. A 5-minute bar that only moved between 108 and 110 puts its volume at 108-110, not across the whole bar range. Rows are tick-aligned: the row height is a number of the symbol's minimum price ticks, and the row count follows the price range.
[*][b]Buy/sell estimate[/b] — the intrabars this tool reads carry price and volume, but no bid/ask, so a true buy/sell split cannot be built from them. What can be done is an estimate: an intrabar that closes above its open counts to the buy side, below its open to the sell side. An intrabar that closes exactly at its open is neutral and is never forced onto a side.
[*][b]Resolution gate[/b] — the estimate only carries information if there are enough intrabars per bar. Below roughly four intrabars per bar the split collapses toward simply restating the candle's direction, so the tool stops colouring by side, falls back to total volume, and says so on the chart.
[*][b]Point of Control and Value Area[/b] — the POC is the row with the most total volume. The Value Area expands outward from the POC until it covers your chosen share of the range's volume (default 70%), giving VAH and VAL. Both are computed on total volume, so they stay valid whether or not the split is shown.
[*][b]Display modes[/b] — Buy/Sell colours each row by its dominant side (length stays total volume). Total draws plain volume by price with no buy/sell claim at all. Delta draws the net buy-minus-sell imbalance. Optional shading makes strongly one-sided rows more saturated.
[/list]

The profile is drawn in the right margin, to the right of the last bar and growing left, so it does not sit on top of the candles.

When the tool hits a limit, it says so instead of quietly degrading. A single factual line appears when — and only when — something applies: the split is unavailable at this resolution, the volume is tick volume, the range was capped by the lower-timeframe budget (with how many bars are actually covered), the row size was raised to fit a wide range, or there is no usable volume data. When nothing applies, there is no note on your chart.

[list=1]
[*]The intrabars of each chart bar in the range are requested from a lower timeframe
[*]Every intrabar's volume is distributed across the rows its own high-low range covers; direction (close vs open) assigns it to the buy or sell side, with doji intrabars left neutral
[*]Rows, POC and Value Area are drawn from the accumulated totals; anything the tool cannot do at this resolution or data quality is stated on the chart rather than approximated silently
[/list]

[b]HOW TO READ[/b]

[list]
[*]Long rows are prices that absorbed a lot of volume; short rows are prices the market passed through. The Point of Control is the single price row that traded the most.
[*]The Value Area marks where the bulk of the volume changed hands — a common reference for the range the market accepted versus the edges it rejected.
[*]Colour in Buy/Sell mode shows which side the estimate leans at that price, and the shading shows how one-sided it is. It describes what the intrabars did — it is not a forecast and not a buy or sell instruction.
[*]Delta mode shows only the net imbalance per row, so balanced prices shrink toward nothing and one-sided prices stand out.
[*]If you want no estimate at all in the picture, use Total mode: it is plain volume by price and makes no claim about who was buying.
[*]The profile describes the data in the range you are looking at. In Visible Range mode it recomputes as you scroll or zoom; use Fixed Lookback if you want it pinned to the last N bars regardless of the view.
[/list]

[b]INPUTS[/b]

[list]
[*]Range mode / Lookback bars — Visible Range follows what you are viewing; Fixed Lookback holds the last N bars.
[*]Lower timeframe (Auto / Manual) — Auto picks a lower timeframe from the chart timeframe; Manual lets you set it. More intrabars per bar means a finer distribution and a more meaningful split.
[*]Ticks per row — the row height, in the symbol's minimum price ticks. The row count follows the range; if the range is too wide for the chosen row size, the size is raised to fit and the chart says so.
[*]Bar mode — Buy/Sell, Total, or Delta.
[*]Value Area % / Show POC / Show VAH-VAL — the Value Area share and which levels to draw.
[*]Profile width (% of chart) / Gap from price — the size of the profile and its distance from the last candle; reduce the width if it runs off the right edge.
[*]Colours / Shade by imbalance strength — buy, sell, neutral, POC and Value Area colours; shading scales saturation with how one-sided a row is.
[/list]

[b]NOTES & LIMITS[/b]

This is an observation tool, not a forecast. The buy/sell split is an estimate derived from intrabar direction, not exchange bid/ask: the lower-timeframe intrabars this tool reads carry price and volume, not bid/ask, so a true split cannot be built from them; the tool says this on the chart when the split is shown, drops it when the resolution is too low to be meaningful, and leaves doji intrabars neutral rather than guessing a side. Everything rests on the volume feed underneath it: on instruments with genuine traded volume (futures, crypto) it is at its most reliable, while on forex and CFDs the volume is tick volume (the number of price updates, not contracts traded), so the readings there are looser — the chart tells you when that is the case. On a symbol with no usable volume, nothing is drawn and the reason is stated. The range depends on how far the lower-timeframe data reaches: if the requested range cannot be covered, it is not quietly shortened — the chart reports how many bars are actually included. POC, Value Area and row colour are a factual summary of what traded, not buy or sell instructions, and none of them says whether price will turn or continue. The profile describes the range you are viewing: in Visible Range mode it recomputes when you scroll or zoom, which is how a visible-range tool works; Fixed Lookback keeps it on the last N bars. Contributions from closed bars do not change once the range is set, the profile is drawn at the latest bar, and the lower-timeframe request reads completed intrabars and does not leak the future. No profit, win-rate, or guarantee claim. Open-source under CC BY-NC-SA 4.0 — non-commercial use, attribution to ElisTools required for reuse or derivatives. TradingView (Pine v6) only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// Intrabar Volume Profile [Order Flow] — Attribution required: credit "ElisTools" in any reuse or derivative.

//@version=6
// Intrabar Volume Profile [Order Flow]
//
// Distributes traded volume across price levels using lower-timeframe (LTF)
// intrabars: each intrabar's volume is spread across its OWN high-low range,
// so peaks form where price actually traded (real POC), not smeared across the
// whole bar range the way bar-level equal-spreading does.
//
// Buy/sell is estimated from intrabar direction (close vs open) -- a proxy, not
// exchange bid/ask -- and is only rendered when intrabar resolution is enough
// to be meaningful (otherwise it falls back to total). Doji intrabars
// (close == open) are neutral, never forced onto a side. Factual on-chart notes
// surface low resolution, tick volume, a range capped by the LTF budget, an
// enlarged or tick-floored row size, or a volumeless symbol -- no silent
// degradation.
//
// Row layout:
//   Number of rows : the range is divided into N equal rows. Portable across
//                    instruments and zoom levels; row height never goes below
//                    one tick (no sub-tick false precision).
//   Ticks per row  : row height = ticksPerRow * mintick, so rows align to real
//                    price increments and stay comparable across zoom. Needs
//                    per-instrument tuning, since a tick is worth wildly
//                    different amounts on an index vs an FX pair.
//
// Bar display modes:
//   Buy / Sell : length = total volume, colour = dominant side (shaded by imbalance)
//   Total      : length = total volume, neutral colour, no buy/sell claim
//   Delta      : length = |buy - sell|, colour = sign of the net imbalance
//
// Drawn in the right margin (bar_index based) to the right of the last bar,
// growing left, so it does not overlap the candles and holds proportion on
// zoom. Pine cannot read the empty margin's screen edge, so the profile is
// pinned to the last bar, not the far screen edge.
//
// Reads completed intrabars only. No lookahead parameter is used or available.
indicator("Intrabar Volume Profile [Order Flow]", shorttitle="Intrabar VP", overlay=true, max_boxes_count=500, max_lines_count=10, max_labels_count=5, max_bars_back=1500)

// ============================ Inputs =======================================
grpRange = "Range"
rangeMode    = input.string("Visible Range", "Range mode", options=["Visible Range", "Fixed Lookback"], group=grpRange, tooltip="Visible Range recomputes as you scroll (like a visible-range profile). Fixed Lookback keeps the data on the last N bars regardless of scroll.")
lookbackBars = input.int(300, "Lookback bars (Fixed mode)", minval=10, maxval=1000, group=grpRange)

grpRes = "Resolution"
ltfMode     = input.string("Auto", "Lower timeframe", options=["Auto", "Manual"], group=grpRes)
ltfManual   = input.timeframe("1", "Manual lower timeframe", group=grpRes, tooltip="Must be lower than the chart timeframe.")
rowLayout   = input.string("Number of rows", "Row layout", options=["Number of rows", "Ticks per row"], group=grpRes, tooltip="Number of rows: the range is split into N equal rows -- works the same on any instrument and any zoom. Ticks per row: fixed row height in ticks -- rows align to real price increments and stay comparable across zoom, but the right value differs per instrument (a tick on an index is not a tick on an FX pair).")
numRowsInput= input.int(50, "Number of rows", minval=10, maxval=300, group=grpRes, tooltip="Used when Row layout = Number of rows. 50 keeps row height close to a typical intrabar's range on most instruments; much finer than that is interpolation, not data.")
ticksPerRow = input.int(250, "Ticks per row", minval=1, group=grpRes, tooltip="Used when Row layout = Ticks per row. Row height = this many of the symbol's minimum price ticks (mintick). Tune per instrument. If the range is too wide for this row size, the row size is raised to fit (and noted on the chart).")

grpDisp = "Display"
dispMode = input.string("Buy / Sell", "Bar mode", options=["Buy / Sell", "Total", "Delta"], group=grpDisp, tooltip="Buy / Sell: each level coloured by the dominant side (length = total volume). Total: plain volume by price, no buy/sell estimate. Delta: length = net (buy - sell) imbalance, coloured by sign. Buy/Sell and Delta use the intrabar estimate and fall back to Total when resolution is too low.")

grpVA = "Value Area"
vaPercent = input.float(70, "Value Area %", minval=10, maxval=95, group=grpVA)
showPOC   = input.bool(true, "Show POC", group=grpVA)
showVA    = input.bool(true, "Show VAH / VAL", group=grpVA)

grpApp = "Appearance"
widthPct = input.float(25, "Profile width (% of chart)", minval=5, maxval=90, group=grpApp, tooltip="Length of the longest row as a percentage of the visible chart width. Sits in the right margin -- keep some empty space on the right. Reduce this if the profile runs off the right edge.")
gapBars  = input.int(20, "Gap from price (bars)", minval=0, maxval=100, group=grpApp, tooltip="Empty space between the last candle and the nearest edge of the profile. Increase to push it further right; reduce Profile width if it runs off the right edge.")
colBuy    = input.color(color.new(#26a69a, 0),  "Buy-dominant level", group=grpApp)
colSell   = input.color(color.new(#ef5350, 0),  "Sell-dominant level", group=grpApp)
colNeutral= input.color(color.new(#b2b5be, 35), "Balanced / total-only", group=grpApp)
shadeByImbalance = input.bool(true, "Shade by imbalance strength", group=grpApp, tooltip="Stronger one-sided imbalance at a level = more saturated colour; near-balanced = paler. Applies to Buy/Sell and Delta modes.")
colPOC    = input.color(color.new(#ffb74d, 0),  "POC", group=grpApp, inline="c3")
colVA     = input.color(color.new(#42a5f5, 0),  "Value Area", group=grpApp, inline="c3")

// ---- hidden constants (deliberately NOT user-tunable) ----
float SPLIT_MIN_INTRABARS = 4.0    // avg intrabars/bar below this => split == candle color, so colour neutral
int   SCAN_CAP            = 1000   // hard ceiling on bars scanned (memory + repaint safety)
int   MAX_ROWS            = 300    // hard ceiling on derived rows (object + performance safety)
int   MAX_WIDTH_BARS      = 250    // hard ceiling on profile width in bars (future-draw safety)

// ============================ LTF selection (Auto) =========================
int    _cs = timeframe.in_seconds()
float  _t  = _cs / 15.0
string ltfAuto = _cs <= 1 ? "1S" :
   _t >= 86400 ? "D"   :
   _t >= 14400 ? "240" :
   _t >= 7200  ? "120" :
   _t >= 3600  ? "60"  :
   _t >= 1800  ? "30"  :
   _t >= 900   ? "15"  :
   _t >= 600   ? "10"  :
   _t >= 300   ? "5"   :
   _t >= 180   ? "3"   :
   _t >= 60    ? "1"   :
   _t >= 30    ? "30S" :
   _t >= 15    ? "15S" :
   _t >= 10    ? "10S" :
   _t >= 3     ? "5S"  : "1S"
string ltf = ltfMode == "Auto" ? ltfAuto : ltfManual

// ============================ LTF request (global scope) ===================
[o_ltf, h_ltf, l_ltf, c_ltf, v_ltf] = request.security_lower_tf(syminfo.tickerid, ltf, [open, high, low, close, volume], ignore_invalid_timeframe = true)

// ============================ Persistent draw stores =======================
var array<box>  g_boxes = array.new<box>()
var array<line> g_lines = array.new<line>()
var label       g_label = na

// ============================ Helpers ======================================
// One horizontal bar in the right margin: right edge pinned at baseIdx, growing
// left by lenBars bars (bar_index space, so it can extend past the last bar).
f_row(array<box> store, int baseIdx, float lenBars, float yLo, float yHi, color col) =>
    if lenBars > 0
        int leftI = int(math.round(baseIdx - lenBars))
        if baseIdx > leftI
            box bx = box.new(leftI, yHi, baseIdx, yLo, border_color = na, border_width = 0, bgcolor = col, xloc = xloc.bar_index)
            array.push(store, bx)

f_note(float atPriceHigh, int atIdx, string txt) =>
    label.new(atIdx, atPriceHigh, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_lower_left, size = size.small, textcolor = chart.fg_color, color = color.new(color.gray, 82))

// ============================ Main (last bar only) =========================
if barstate.islast
    // ---- clear previous drawings ----
    for b in g_boxes
        box.delete(b)
    array.clear(g_boxes)
    for ln in g_lines
        line.delete(ln)
    array.clear(g_lines)
    if not na(g_label)
        label.delete(g_label)
        g_label := na

    // ---- layout: width & baseline in the right margin (bar_index) ----
    float barDurMs = math.max(1, timeframe.in_seconds()) * 1000.0
    float spanMs   = (na(chart.right_visible_bar_time) or na(chart.left_visible_bar_time)) ? na : (chart.right_visible_bar_time - chart.left_visible_bar_time)
    int   visBars   = (na(spanMs) or spanMs <= 0) ? 150 : int(math.max(10, math.round(spanMs / barDurMs)))
    int   widthBars = int(math.max(8, math.min(MAX_WIDTH_BARS, math.round(visBars * widthPct / 100.0))))
    int   baseIdx   = bar_index + gapBars + widthBars

    // ---- Pass A: covered bars, price bounds, cap state ----
    bool isVisible = rangeMode == "Visible Range"
    int  lt = chart.left_visible_bar_time
    int  rt = chart.right_visible_bar_time

    float rHigh = na
    float rLow  = na
    int   barsCovered    = 0
    int   totalIntrabars = 0
    float sumVol   = 0.0
    bool  capped   = false

    int  maxScan = math.min(SCAN_CAP, bar_index)
    int  i = 0
    bool stop = false
    while not stop and i <= maxScan
        bool inRange = true
        if isVisible
            int bt = time[i]
            if bt > rt
                inRange := false
            else if bt < lt
                inRange := false
                stop := true
            else
                inRange := true
        else
            if i >= lookbackBars
                inRange := false
                stop := true
            else
                inRange := true

        if inRange
            bool avail = not na(v_ltf[i]) and array.size(v_ltf[i]) > 0
            if not avail
                capped := true          // LTF budget ran out inside the requested range
                stop := true
            else
                barsCovered    := i + 1
                totalIntrabars += array.size(v_ltf[i])
                sumVol += na(volume[i]) ? 0.0 : volume[i]
                rHigh  := na(rHigh) ? high[i] : math.max(rHigh, high[i])
                rLow   := na(rLow)  ? low[i]  : math.min(rLow,  low[i])
        i += 1
    if not stop and i > maxScan
        capped := true                  // stopped by the scan ceiling, not by the range end

    // ---- validity ----
    float avgIntrabars = totalIntrabars / math.max(1, barsCovered)
    bool  volValid = sumVol > 0
    bool  tickVol  = syminfo.type == "forex" or syminfo.type == "cfd"
    bool  rangeOk  = barsCovered > 0 and not na(rHigh) and not na(rLow) and rHigh > rLow

    if not rangeOk or not volValid
        // nothing usable -> say why, so it does not read as "broken"
        string msg = (barsCovered > 0 and not volValid) ? "No volume data for this symbol" : "No intrabar data available for this range"
        g_label := f_note(na(rHigh) ? high : rHigh, bar_index + gapBars, msg)
    else
        // ---- row grid ----
        float tick    = syminfo.mintick
        float binSize = 0.0
        float gridLow = 0.0
        int   numBins = 0
        bool  rowsBumped  = false   // row size enlarged to fit the range
        bool  rowsFloored = false   // row size floored at 1 tick (range too narrow for the request)

        if rowLayout == "Ticks per row"
            binSize := ticksPerRow * tick
            gridLow := math.floor(rLow / binSize) * binSize
            numBins := int(math.ceil((rHigh - gridLow) / binSize))
            if numBins > MAX_ROWS
                binSize := math.ceil(((rHigh - rLow) / MAX_ROWS) / tick) * tick
                gridLow := math.floor(rLow / binSize) * binSize
                numBins := int(math.ceil((rHigh - gridLow) / binSize))
                rowsBumped := true
        else
            int   want = math.min(MAX_ROWS, numRowsInput)
            float raw  = (rHigh - rLow) / want
            rowsFloored := raw < tick
            binSize := math.max(tick, raw)      // never below one tick: no sub-tick false precision
            gridLow := rLow
            numBins := int(math.ceil((rHigh - gridLow) / binSize))
        numBins := math.max(1, math.min(MAX_ROWS, numBins))

        // ---- binning: each intrabar's volume onto its OWN [low, high] range ----
        array<float> binT = array.new<float>(numBins, 0.0)
        array<float> binB = array.new<float>(numBins, 0.0)
        array<float> binS = array.new<float>(numBins, 0.0)

        for bi = 0 to barsCovered - 1
            int sz = array.size(v_ltf[bi])
            if sz > 0
                for k = 0 to sz - 1
                    float iv = array.get(v_ltf[bi], k)
                    float ih = array.get(h_ltf[bi], k)
                    float il = array.get(l_ltf[bi], k)
                    if not na(iv) and iv > 0 and not na(ih) and not na(il)
                        float ic = array.get(c_ltf[bi], k)
                        float io = array.get(o_ltf[bi], k)
                        int side = (na(ic) or na(io)) ? 0 : (ic > io ? 1 : (ic < io ? -1 : 0))
                        if ih == il
                            int idx = math.max(0, math.min(numBins - 1, int(math.floor((il - gridLow) / binSize))))
                            array.set(binT, idx, array.get(binT, idx) + iv)
                            if side == 1
                                array.set(binB, idx, array.get(binB, idx) + iv)
                            else if side == -1
                                array.set(binS, idx, array.get(binS, idx) + iv)
                        else
                            float span  = ih - il
                            int   loIdx = math.max(0, math.min(numBins - 1, int(math.floor((il - gridLow) / binSize))))
                            int   hiIdx = math.max(0, math.min(numBins - 1, int(math.floor((ih - gridLow) / binSize))))
                            for bidx = loIdx to hiIdx
                                float binLo = gridLow + bidx * binSize
                                float binHi = binLo + binSize
                                float ov = math.min(ih, binHi) - math.max(il, binLo)
                                if ov > 0
                                    float add = iv * (ov / span)
                                    array.set(binT, bidx, array.get(binT, bidx) + add)
                                    if side == 1
                                        array.set(binB, bidx, array.get(binB, bidx) + add)
                                    else if side == -1
                                        array.set(binS, bidx, array.get(binS, bidx) + add)

        // ---- POC, totals, max abs delta ----
        float maxT = 0.0
        int   pocIdx = 0
        float totalAll = 0.0
        float maxAbsDelta = 0.0
        for bidx = 0 to numBins - 1
            float tv = array.get(binT, bidx)
            totalAll += tv
            if tv > maxT
                maxT := tv
                pocIdx := bidx
            float dd = math.abs(array.get(binB, bidx) - array.get(binS, bidx))
            if dd > maxAbsDelta
                maxAbsDelta := dd

        if maxT <= 0
            g_label := f_note(rHigh, bar_index + gapBars, "No usable volume in this range")
        else
            // ---- Value Area on TOTAL volume ----
            float target = totalAll * (vaPercent / 100.0)
            float acc = array.get(binT, pocIdx)
            int up = pocIdx + 1
            int dn = pocIdx - 1
            int vahIdx = pocIdx
            int valIdx = pocIdx
            while acc < target and (up < numBins or dn >= 0)
                float upv = up < numBins ? array.get(binT, up) : -1.0
                float dnv = dn >= 0      ? array.get(binT, dn) : -1.0
                if upv < 0 and dnv < 0
                    break
                if upv >= dnv
                    acc += upv
                    vahIdx := up
                    up += 1
                else
                    acc += dnv
                    valIdx := dn
                    dn -= 1

            float pocPrice = gridLow + (pocIdx + 0.5) * binSize
            float vahPrice = gridLow + (vahIdx + 1) * binSize
            float valPrice = gridLow + valIdx * binSize

            // ---- resolution gate + mode resolution ----
            bool wantsSplit  = (dispMode == "Buy / Sell") or (dispMode == "Delta")
            bool doSplit     = wantsSplit and (avgIntrabars >= SPLIT_MIN_INTRABARS) and volValid
            bool renderDelta = (dispMode == "Delta") and doSplit and maxAbsDelta > 0
            bool colorBySide = (dispMode == "Buy / Sell") and doSplit

            // ---- draw rows: right edge pinned at baseIdx, grow left ----
            float scaleTot = widthBars / maxT
            float scaleDel = maxAbsDelta > 0 ? widthBars / maxAbsDelta : 0.0
            for bidx = 0 to numBins - 1
                float tv = array.get(binT, bidx)
                float bv = array.get(binB, bidx)
                float sv = array.get(binS, bidx)
                float d  = bv - sv
                float binLo = gridLow + bidx * binSize
                float binHi = binLo + binSize
                if renderDelta
                    if d != 0
                        float ratio = (bv + sv) > 0 ? math.abs(d) / (bv + sv) : 0.0
                        int transp = shadeByImbalance ? int(math.round(65 - 45 * ratio)) : 20
                        transp := math.max(20, math.min(75, transp))
                        color col = d > 0 ? color.new(colBuy, transp) : color.new(colSell, transp)
                        f_row(g_boxes, baseIdx, math.abs(d) * scaleDel, binLo, binHi, col)
                else
                    if tv > 0
                        color col = colNeutral
                        if colorBySide
                            float dir = bv + sv
                            if dir > 0 and d != 0
                                float ratio = math.abs(d) / dir
                                int transp = shadeByImbalance ? int(math.round(65 - 45 * ratio)) : 20
                                transp := math.max(20, math.min(75, transp))
                                col := d > 0 ? color.new(colBuy, transp) : color.new(colSell, transp)
                        f_row(g_boxes, baseIdx, tv * scaleTot, binLo, binHi, col)

            // ---- POC / VA lines across the analyzed candles up to the profile ----
            int oldestIdx = math.max(0, bar_index - barsCovered + 1)
            if showPOC
                line lp = line.new(oldestIdx, pocPrice, baseIdx, pocPrice, xloc = xloc.bar_index, color = colPOC, width = 2)
                array.push(g_lines, lp)
            if showVA
                line lh = line.new(oldestIdx, vahPrice, baseIdx, vahPrice, xloc = xloc.bar_index, color = colVA, width = 1, style = line.style_dashed)
                line ll = line.new(oldestIdx, valPrice, baseIdx, valPrice, xloc = xloc.bar_index, color = colVA, width = 1, style = line.style_dashed)
                array.push(g_lines, lh)
                array.push(g_lines, ll)

            // ---- factual note: only lines that apply; invisible when nominal ----
            string note = ""
            if dispMode == "Buy / Sell"
                note := colorBySide ? "Buy/sell = intrabar estimate, not exchange bid/ask" : "Buy/sell unavailable at this resolution (showing total)"
            else if dispMode == "Delta"
                note := doSplit ? "Delta = intrabar buy - sell estimate, not exchange bid/ask" : "Delta unavailable at this resolution (showing total)"
            if tickVol
                note := note + (note == "" ? "" : "\n") + "Volume = tick volume (forex/CFD)"
            if rowsBumped
                note := note + (note == "" ? "" : "\n") + "Row size raised to " + str.tostring(int(math.round(binSize / tick))) + " ticks to fit range"
            if rowsFloored
                note := note + (note == "" ? "" : "\n") + "Rows limited to " + str.tostring(numBins) + " (1 tick each)"
            if capped
                note := note + (note == "" ? "" : "\n") + (isVisible ? "Range capped: last " + str.tostring(barsCovered) + " bars (LTF limit)" : "Range capped: last " + str.tostring(barsCovered) + " of " + str.tostring(lookbackBars) + " bars (LTF limit)")
            if note != ""
                g_label := f_note(rHigh, baseIdx - int(math.round(widthBars / 2.0)), note)
````
