# Footprint Lookback [Order Flow]

- url: https://www.tradingview.com/script/mFzdS8hv-Footprint-Lookback-Order-Flow/
- type: indicator
- pine_id: PUB;bd781317e303444da7f7128f02aa2d8d
- version: 1.0

## Description

A footprint shows the real buy and sell volume at every price inside a bar. Read candle by candle it is a wall of numbers you have to zoom into one bar at a time. Footprint Lookback takes a different angle: you pick a period — say one hour — and it aggregates the real footprint of the last hour of bars into a single, readable profile pinned to the right of your chart, between the window's high and low. The window rolls forward with each new bar. It is a factual aggregation of bid and ask volume, not a signal service — it shows you where, in price, real buying and selling happened over the period you chose, and leaves the read to you. It uses TradingView's native footprint data, which is available on the Premium and Ultimate plans.

[b]HOW IT WORKS[/b]

A footprint records, for each bar, how much volume traded as buying (at the ask) and selling (at the bid) at each price level. Footprint Lookback reads that real data with a single request and aggregates it across a rolling window instead of showing it one candle at a time.


[list]
[*]Rolling lookback window — you choose a period (for example, 1 hour). The tool converts it into a number of chart bars — the last N bars — and aggregates the footprint of those bars. The window slides forward as new bars close, so the profile always describes the most recent period. For performance the window is capped at 300 bars, and the tool marks on the chart when that cap is reached rather than silently shortening it.
[*]The profile — a panel to the right of the last bar, bounded by the window's high and low. Each row is a price band: the real sell (bid) volume is drawn on the left, the buy (ask) volume on the right, shown by color intensity with the number on the outer edge. The row height is fixed and the number of rows follows the price range, so rows stay consistent and non-overlapping on any instrument and timeframe. Auto sizes the row height from ATR (volatility-adaptive); Manual lets you set ticks per row.
[*]Point of Control and Value Area — the Point of Control (POC) is the price band that traded the most total volume. The Value Area expands outward from the POC until it covers your chosen share of the window's volume (default 70%). POC, VAH and VAL are drawn as levels extending to the right.
[*]Diagonal imbalance — footprint imbalance compares the buy volume at one price against the sell volume at the level below it — the diagonal. When one side exceeds the other by your threshold, that cell is highlighted. Runs of consecutive same-side imbalances are boxed as stacked-imbalance zones (B-IMB for buy, S-IMB for sell).
[*]Stats — a fixed corner box reads out the window's total volume, its delta (buy minus sell), and the buy/sell split.
[/list]


If no footprint data is available — an unsupported symbol, a plan without footprint access, or a market with no real volume — the tool does not invent anything. It shows "No footprint data" and draws no profile.


[list=1]
[*]A single footprint request pulls the real bid/ask volume rows for each bar; the last N bars of your chosen window are aggregated into price bands between the window's high and low
[*]Each band shows real sell and buy volume by color and number; the Point of Control, Value Area, diagonal imbalances and stacked-imbalance zones are derived from the aggregated data
[*]Confirmed bars stay fixed; the window rolls forward and the panel redraws at the latest bar — and where there is no footprint data, the tool says so instead of drawing
[/list]


[b]HOW TO READ[/b]


[list]
[*]The profile answers one question: over the period you chose, at which prices did real buying and selling actually happen? Tall rows are prices that traded heavily; the Point of Control is the single price band that traded the most.
[*]The Value Area (POC, VAH, VAL) marks the price range where the bulk of the volume changed hands — a common reference for where the market accepted value versus where it rejected it.
[*]A row leaning strongly to the buy or sell side, or a highlighted diagonal imbalance, shows one side dominating at that price. It is a fact about what already happened inside the window, not a prediction.
[*]Stacked-imbalance zones (B-IMB, S-IMB) mark a run of one-sided pressure across several prices. They describe an order-flow condition — not a buy or sell instruction.
[*]The stats box gives the window totals: a positive delta means more volume traded into buys than sells over the period, negative the reverse. The tool maps the order flow; the read is yours.
[/list]


[b]INPUTS[/b]


[list]
[*]Lookback period — the window the footprint is aggregated over (e.g. 60 = the last hour of chart bars).
[*]Source granularity (ticks per row) — the resolution of the underlying footprint request; keep it fine for accurate aggregation.
[*]Value Area % — the share of window volume the Value Area covers (default 70).
[*]Imbalance threshold % — how far one side must exceed its diagonal opposite to count as an imbalance.
[*]Row size mode / Manual ticks per row / ATR length — Auto sizes each row from ATR (volatility-adaptive); Manual fixes ticks per row. Either way the row count follows the range.
[*]Max rows — a safety cap on the number of rows.
[*]Panel — Gap from last bar, Panel width, Show numbers, Show stats box, Stats box position, Text size, Mark current price line: the placement and contents of the right-side panel.
[*]Colors — buy, sell, lookback high/low, POC, current price line.
[*]Value Area / Imbalance — Show POC/VAH/VAL, VAH-VAL color, Mark imbalance, Mark stacked-imbalance zones, Stacked count (how many consecutive imbalanced rows form a zone).
[/list]


[b]NOTES & LIMITS[/b]

This is an observation tool, not a forecast. It uses TradingView's native footprint data, which requires a Premium or Ultimate plan; on a symbol or plan where that data is not available, or a market with no real volume, it shows "No footprint data" rather than drawing something invented. It is a rolling-window footprint profile — it aggregates the available footprint of the last N bars into one profile — not a per-candle footprint. The volume it reads is only as good as the feed underneath it: on instruments with genuine traded volume (futures, crypto) it is at its most reliable, while on forex and CFDs the volume is tick volume (the number of price updates, not contracts traded), so the readings there are looser and should be treated with more caution. The lookback is capped at 300 bars for performance, and the tool marks on the chart when that cap is reached. The Point of Control, Value Area, imbalances and stacked-imbalance zones are a factual aggregation of what traded — not buy or sell instructions, and marking one says nothing about whether price will turn or continue. The profile is built from confirmed (closed) bars, which stay fixed; the live window updates to show the current state and the panel redraws at the latest bar, but past levels are not moved, and the footprint request reads completed data and does not leak the future. No profit, win-rate, or guarantee claim. Open-source under CC BY-NC-SA 4.0 — non-commercial use, attribution to ElisTools required for reuse or derivatives. TradingView (Pine v6) only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// Footprint Lookback [Order Flow] — Attribution required: credit "ElisTools" in any reuse or derivative.
//@version=6
// =============================================================================
//  Footprint Lookback [Order Flow]
// -----------------------------------------------------------------------------
//  Shows the footprint of a ROLLING LOOKBACK window (not an HTF bar). Pick a
//  period (e.g. 1 hour) -> it aggregates the LAST 1 hour of chart bars. The
//  window slides forward each bar.
//
//   · Lookback high & low drawn as solid lines extending right.
//   · A panel to the right is bounded top = lookback high, bottom = lookback low.
//   · Row HEIGHT = ticks per row (Auto = volatility-adaptive, ATR-based); the
//     row COUNT follows the price range -> consistent rows, no overlap, any instrument.
//   · Each row = real buy/sell at that price band (Sell left, Buy right), POC gold.
//
//  DATA: single request.footprint() (chart bar) aggregated over the lookback.
//  HONESTY: real bid/ask · updates live · NO signals · no profit promise.
//  REQUIRES: request.footprint() compiles only on the Premium/Ultimate plan.
// =============================================================================
indicator("Footprint Lookback [Order Flow]", shorttitle = "Footprint LB", overlay = true, max_boxes_count = 500, max_labels_count = 150, max_lines_count = 20)

// -----------------------------------------------------------------------------
// INPUTS
// -----------------------------------------------------------------------------
GCORE = "Footprint data"
lbTf             = input.timeframe("60", "Lookback period", group = GCORE, tooltip = "Footprint = the LAST <this much> of chart bars. e.g. 1 hour -> last 60 minutes (rolling).")
ticksPerRow      = input.int(2,   "Source granularity — ticks_per_row", minval = 1, group = GCORE, tooltip = "Underlying chart-bar footprint resolution. Keep fine for accurate aggregation.")
vaPercent        = input.int(70,  "Value Area % — va_percent", minval = 1, maxval = 99, group = GCORE)
imbalancePercent = input.int(300, "Imbalance threshold % — imbalance_percent", minval = 1, group = GCORE)

GROW = "Row size  (fixed height; the row count follows the range)"
rowSizeMode = input.string("Auto (ATR)", "Row size mode", options = ["Auto (ATR)", "Manual (ticks per row)"], group = GROW, tooltip = "The row HEIGHT is fixed; the count follows the price range. Auto = 0.2 x ATR in ticks (volatility-adaptive). Manual = set ticks per row (e.g. index futures 1, tech futures 4-5, gold 5-10).")
manualTicks = input.int(10, "Manual ticks per row", minval = 1, group = GROW)
atrLen      = input.int(14, "ATR length (for Auto)", minval = 1, group = GROW)
maxRows     = input.int(80, "Max rows (safety cap)", minval = 5, maxval = 120, group = GROW)

GPANEL = "Panel (right side)"
panelGap   = input.int(4,  "Gap from last bar (bars)", minval = 0, maxval = 100, group = GPANEL)
panelWidth = input.int(24, "Panel width (bars)", minval = 4, maxval = 80, group = GPANEL)
showNums   = input.bool(true, "Show numbers", group = GPANEL)
showSummary = input.bool(true, "Show stats box (VOL / Δ / Buy / Sell)", group = GPANEL)
statPos    = input.string("Bottom right", "Stats box position", options = ["Bottom right", "Bottom left", "Bottom center", "Middle right", "Top right"], group = GPANEL)
txtSize    = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GPANEL)
showPrice  = input.bool(true, "Mark current price line", group = GPANEL)

GCOL = "Colors"
colBuy  = input.color(#26a69a, "Buy (right)", group = GCOL, inline = "c")
colSell = input.color(#ef5350, "Sell (left)", group = GCOL, inline = "c")
colHi   = input.color(#26a69a, "Lookback High line", group = GCOL, inline = "hl")
colLo   = input.color(#ef5350, "Lookback Low line", group = GCOL, inline = "hl")
colPoc  = input.color(#ffc107, "POC", group = GCOL)
colPrice = input.color(#787b86, "Current price line", group = GCOL)

GVA = "Value Area / Imbalance"
showVA  = input.bool(true,  "Show POC / VAH / VAL lines", group = GVA)
colVA   = input.color(#2962ff, "VAH / VAL color", group = GVA)
showImb = input.bool(true,  "Mark imbalance (solid colour)", group = GVA)
showZone = input.bool(true, "Mark stacked-imbalance zones", group = GVA, tooltip = "Draw a box around runs of consecutive same-side imbalanced rows (stacked imbalance). Buy zone ~ support, sell zone ~ resistance.")
stackN   = input.int(3, "Stacked count (consecutive rows)", minval = 2, maxval = 10, group = GVA)

f_txtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_statPos(string s) =>
    s == "Bottom left" ? position.bottom_left : s == "Bottom center" ? position.bottom_center : s == "Middle right" ? position.middle_right : s == "Top right" ? position.top_right : position.bottom_right

// -----------------------------------------------------------------------------
// FOOTPRINT + rolling lookback window
// -----------------------------------------------------------------------------
footprint fp = request.footprint(ticksPerRow, vaPercent, imbalancePercent)

int lbBarsRaw = math.max(2, int(math.round(timeframe.in_seconds(lbTf) / timeframe.in_seconds(timeframe.period))))
int lbBars = math.min(lbBarsRaw, 300)
bool lbCapped = lbBarsRaw > 300
float hiLB = ta.highest(high, lbBars)
float loLB = ta.lowest(low, lbBars)

// row HEIGHT (ticks per row) -> count is derived from the price range
float atrv = ta.atr(atrLen)
int   dispTicks = rowSizeMode == "Manual (ticks per row)" ? manualTicks : math.max(1, int(math.round(0.2 * atrv / syminfo.mintick)))
float rowH = dispTicks * syminfo.mintick
int   N = (not na(hiLB) and not na(loLB) and hiLB > loLB and rowH > 0) ? math.max(2, math.min(maxRows, int(math.round((hiLB - loLB) / rowH)))) : 2

// rolling buffer: footprint rows of the last lbBars confirmed bars
var array<int>   rBar  = array.new<int>()
var array<float> rPx   = array.new<float>()
var array<float> rBuy  = array.new<float>()
var array<float> rSell = array.new<float>()

if barstate.isconfirmed and (last_bar_index - bar_index) < lbBars and not na(fp)
    array<volume_row> rws = fp.rows()
    int nr = array.size(rws)
    if nr > 0
        for i = 0 to nr - 1
            volume_row r = array.get(rws, i)
            array.push(rBar, bar_index)
            array.push(rPx, r.up_price())
            array.push(rBuy, r.buy_volume())
            array.push(rSell, r.sell_volume())
    int minKeep = bar_index - lbBars + 1
    while array.size(rBar) > 0 and array.get(rBar, 0) < minKeep
        array.shift(rBar)
        array.shift(rPx)
        array.shift(rBuy)
        array.shift(rSell)

var array<box>   pBox  = array.new<box>()
var array<line>  pLine = array.new<line>()
var array<label> pLab  = array.new<label>()
var table statTbl = table.new(f_statPos(statPos), 2, 5, border_width = 1, border_color = color.new(#2a2e39, 40), frame_width = 1, frame_color = color.new(#2a2e39, 20))

// -----------------------------------------------------------------------------
// DRAW on the last bar
// -----------------------------------------------------------------------------
if barstate.islast
    for b in pBox
        box.delete(b)
    array.clear(pBox)
    for l in pLine
        line.delete(l)
    array.clear(pLine)
    for lb in pLab
        label.delete(lb)
    array.clear(pLab)
    table.clear(statTbl, 0, 0, 1, 4)

    if not na(hiLB) and not na(loLB) and hiLB > loLB
        string ts = f_txtSize(txtSize)
        float step = (hiLB - loLB) / N

        array<float> bBuy  = array.new<float>(N, 0.0)
        array<float> bSell = array.new<float>(N, 0.0)
        // accumulated (last lbBars confirmed bars)
        if array.size(rBar) > 0
            for i = 0 to array.size(rBar) - 1
                int bi = math.max(0, math.min(N - 1, int(math.floor((array.get(rPx, i) - loLB) / step))))
                array.set(bBuy,  bi, array.get(bBuy, bi)  + array.get(rBuy, i))
                array.set(bSell, bi, array.get(bSell, bi) + array.get(rSell, i))
        // still-forming chart bar (not yet in buffer)
        if barstate.isrealtime and not barstate.isconfirmed and not na(fp)
            array<volume_row> fr = fp.rows()
            if array.size(fr) > 0
                for i = 0 to array.size(fr) - 1
                    volume_row r = array.get(fr, i)
                    int bi = math.max(0, math.min(N - 1, int(math.floor((r.up_price() - loLB) / step))))
                    array.set(bBuy,  bi, array.get(bBuy, bi)  + r.buy_volume())
                    array.set(bSell, bi, array.get(bSell, bi) + r.sell_volume())

        // POC band + max side + totals
        int pocB = 0
        float tMax = -1.0
        float maxSide = 0.0
        float totalAll = 0.0
        float sumBuy = 0.0
        float sumSell = 0.0
        for j = 0 to N - 1
            float bvol = array.get(bBuy, j)
            float svol = array.get(bSell, j)
            float tot = bvol + svol
            totalAll += tot
            sumBuy += bvol
            sumSell += svol
            if tot > tMax
                tMax := tot
                pocB := j
            maxSide := math.max(maxSide, math.max(bvol, svol))

        // honest empty-state: no footprint data at all (unsupported symbol / no volume / wrong plan)
        bool hasData = totalAll > 0
        if not hasData
            label nd = label.new(last_bar_index + panelGap, (hiLB + loLB) / 2, "No footprint data\n(requires Premium/Ultimate + supported symbol)", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(#161a25, 0), textcolor = #eaecef, size = size.normal)
            array.push(pLab, nd)
        // note when the lookback window hit the 300-bar safety cap
        if hasData and lbCapped
            label cp = label.new(last_bar_index + panelGap, hiLB, "⚠ window capped to 300 bars", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(#161a25, 10), textcolor = #ffb74d, size = size.small)
            array.push(pLab, cp)

        // Value Area (expand from POC until vaPercent of total)
        int vlo = pocB
        int vhi = pocB
        float acc = array.get(bBuy, pocB) + array.get(bSell, pocB)
        float target = totalAll * vaPercent / 100.0
        int guard = 0
        while acc < target and (vlo > 0 or vhi < N - 1) and guard < N * 2
            guard += 1
            float upV = vhi < N - 1 ? array.get(bBuy, vhi + 1) + array.get(bSell, vhi + 1) : -1.0
            float dnV = vlo > 0 ? array.get(bBuy, vlo - 1) + array.get(bSell, vlo - 1) : -1.0
            if upV >= dnV and vhi < N - 1
                vhi += 1
                acc += array.get(bBuy, vhi) + array.get(bSell, vhi)
            else if vlo > 0
                vlo -= 1
                acc += array.get(bBuy, vlo) + array.get(bSell, vlo)
            else if vhi < N - 1
                vhi += 1
                acc += array.get(bBuy, vhi) + array.get(bSell, vhi)
            else
                guard := N * 2
        float imbRatio = imbalancePercent / 100.0

        // diagonal imbalance flag per band (single source for both the cells and the zones)
        array<bool> bImbArr = array.new<bool>(N, false)
        array<bool> sImbArr = array.new<bool>(N, false)
        if showImb
            for jj = 0 to N - 1
                if jj > 0 and array.get(bSell, jj - 1) > 0 and array.get(bBuy, jj) >= array.get(bSell, jj - 1) * imbRatio
                    array.set(bImbArr, jj, true)
                if jj < N - 1 and array.get(bBuy, jj + 1) > 0 and array.get(bSell, jj) >= array.get(bBuy, jj + 1) * imbRatio
                    array.set(sImbArr, jj, true)

        // lookback high / low solid lines (from window start, extend right)
        int xStart = math.max(0, last_bar_index - lbBars + 1)
        if hasData
            line lh = line.new(xStart, hiLB, last_bar_index, hiLB, xloc = xloc.bar_index, extend = extend.right, color = colHi, width = 2)
            line ll = line.new(xStart, loLB, last_bar_index, loLB, xloc = xloc.bar_index, extend = extend.right, color = colLo, width = 2)
            array.push(pLine, lh)
            array.push(pLine, ll)

        // POC / VAH / VAL levels (extend right)
        if hasData and showVA
            float pocPrice = loLB + (pocB + 0.5) * step
            float vahPrice = loLB + (vhi + 1) * step
            float valPrice = loLB + vlo * step
            line lp = line.new(xStart, pocPrice, last_bar_index, pocPrice, xloc = xloc.bar_index, extend = extend.right, color = colPoc, width = 1)
            line lvah = line.new(xStart, vahPrice, last_bar_index, vahPrice, xloc = xloc.bar_index, extend = extend.right, color = colVA, width = 1, style = line.style_dashed)
            line lval = line.new(xStart, valPrice, last_bar_index, valPrice, xloc = xloc.bar_index, extend = extend.right, color = colVA, width = 1, style = line.style_dashed)
            array.push(pLine, lp)
            array.push(pLine, lvah)
            array.push(pLine, lval)
            // level tags just to the RIGHT of the panel (box opens rightward into the margin).
            // The panel is always pinned to the latest bar, so these stay on the right side.
            int xTag = last_bar_index + panelGap + panelWidth + 1
            label lpT   = label.new(xTag, pocPrice, "POC", xloc = xloc.bar_index, style = label.style_label_left, color = colPoc, textcolor = color.white, size = size.small)
            label lvahT = label.new(xTag, vahPrice, "VAH", xloc = xloc.bar_index, style = label.style_label_left, color = colVA, textcolor = color.white, size = size.small)
            label lvalT = label.new(xTag, valPrice, "VAL", xloc = xloc.bar_index, style = label.style_label_left, color = colVA, textcolor = color.white, size = size.small)
            array.push(pLab, lpT)
            array.push(pLab, lvahT)
            array.push(pLab, lvalT)

        // panel (right side, bounded by hiLB / loLB)
        int xc0  = last_bar_index + panelGap
        int xc1  = xc0 + panelWidth
        int xMid = xc0 + int(panelWidth / 2)

        // Stats readout — fixed TABLE (screen space), always readable at any lookback / zoom
        if hasData and showSummary
            float dlt = sumBuy - sumSell
            float sellPct = totalAll > 0 ? sumSell / totalAll * 100 : 50.0
            int   sellPctI = int(math.round(sellPct))
            int   buyPctI = 100 - sellPctI
            int   dltPct = totalAll > 0 ? int(math.round(dlt / totalAll * 100)) : 0
            // Price-anchored boxes collapse when the lookback range is small (short panel ->
            // overlapping text). A table lives in screen space, so it stays legible at any zoom.
            // table bg is forced DARK, so text must be LIGHT (never chart.fg_color — that is
            // black on a light-theme chart -> black-on-black). Labels = light grey, values bright.
            color hbg  = color.new(#161a25, 0)
            color cLbl = color.new(#b2b5be, 0)
            color cVal = color.new(#eaecef, 0)
            color cD   = dlt >= 0 ? colBuy : colSell
            table.cell(statTbl, 0, 0, "VOL",     text_color = cLbl,          text_size = ts, text_halign = text.align_left,  bgcolor = hbg)
            table.cell(statTbl, 1, 0, str.tostring(totalAll, format.volume), text_color = cVal, text_size = ts, text_halign = text.align_right, bgcolor = hbg)
            table.cell(statTbl, 0, 1, "DELTA",   text_color = cLbl,          text_size = ts, text_halign = text.align_left,  bgcolor = hbg)
            table.cell(statTbl, 1, 1, (dlt >= 0 ? "+" : "") + str.tostring(dlt, format.volume), text_color = cD, text_size = ts, text_halign = text.align_right, bgcolor = hbg)
            table.cell(statTbl, 0, 2, "DELTA %", text_color = cLbl,          text_size = ts, text_halign = text.align_left,  bgcolor = hbg)
            table.cell(statTbl, 1, 2, (dltPct >= 0 ? "+" : "") + str.tostring(dltPct) + "%", text_color = cD, text_size = ts, text_halign = text.align_right, bgcolor = hbg)
            table.cell(statTbl, 0, 3, "BUY",     text_color = colBuy,        text_size = ts, text_halign = text.align_left,  bgcolor = hbg)
            table.cell(statTbl, 1, 3, str.tostring(sumBuy, format.volume) + "  " + str.tostring(buyPctI) + "%", text_color = colBuy, text_size = ts, text_halign = text.align_right, bgcolor = hbg)
            table.cell(statTbl, 0, 4, "SELL",    text_color = colSell,       text_size = ts, text_halign = text.align_left,  bgcolor = hbg)
            table.cell(statTbl, 1, 4, str.tostring(sumSell, format.volume) + "  " + str.tostring(sellPctI) + "%", text_color = colSell, text_size = ts, text_halign = text.align_right, bgcolor = hbg)

        for j = 0 to N - 1
            float yDn = loLB + j * step
            float yUp = yDn + step
            float sell = array.get(bSell, j)
            float buy  = array.get(bBuy, j)
            // full-width half cells: volume shown by COLOR INTENSITY, number pinned to the OUTER edge
            float sInt = maxSide > 0 ? sell / maxSide : 0.0
            float bInt = maxSide > 0 ? buy  / maxSide : 0.0
            // diagonal imbalance (precomputed) -> cell pops with a SOLID colour; else soft gradient
            bool bImb = array.get(bImbArr, j)
            bool sImb = array.get(sImbArr, j)
            color sBg = sImb ? color.new(colSell, 4) : (sell > 0 ? color.from_gradient(sInt, 0, 1, color.new(colSell, 92), color.new(colSell, 46)) : na)
            color bBg = bImb ? color.new(colBuy, 4)  : (buy  > 0 ? color.from_gradient(bInt, 0, 1, color.new(colBuy, 92), color.new(colBuy, 46)) : na)
            color tcS = sImb ? color.white : chart.fg_color
            color tcB = bImb ? color.white : chart.fg_color
            box sb = box.new(xc0, yUp, xMid, yDn, xloc = xloc.bar_index, bgcolor = sBg, border_color = na, border_width = 0, text = (showNums and sell > 0) ? str.tostring(sell, format.volume) : "", text_color = tcS, text_size = ts, text_halign = text.align_left, text_valign = text.align_center)
            box bb = box.new(xMid, yUp, xc1, yDn, xloc = xloc.bar_index, bgcolor = bBg, border_color = na, border_width = 0, text = (showNums and buy > 0) ? str.tostring(buy, format.volume) : "", text_color = tcB, text_size = ts, text_halign = text.align_right, text_valign = text.align_center)
            array.push(pBox, sb)
            array.push(pBox, bb)

        // current price marker — thin dotted line across the panel + a left-edge pointer
        if hasData and showPrice and not na(close)
            line lpx = line.new(xc0, close, xc1, close, xloc = xloc.bar_index, color = colPrice, width = 1, style = line.style_dotted)
            array.push(pLine, lpx)
            label mpx = label.new(xc0, close, "▶", xloc = xloc.bar_index, style = label.style_none, textcolor = colPrice, size = size.small)
            array.push(pLab, mpx)

        // stacked-imbalance ZONES — runs of >= stackN consecutive same-side imbalanced bands.
        // Buy zone ~ support, sell zone ~ resistance.
        if hasData and showZone
            int runB = 0
            for j = 0 to N - 1
                runB := array.get(bImbArr, j) ? runB + 1 : 0
                bool closeB = j == N - 1 ? array.get(bImbArr, j) : not array.get(bImbArr, j + 1)
                if closeB and runB >= stackN
                    float zTop = loLB + (j + 1) * step
                    float zBot = loLB + (j - runB + 1) * step
                    box zb = box.new(xc0, zTop, xc1, zBot, xloc = xloc.bar_index, bgcolor = na, border_color = colBuy, border_width = 2)
                    array.push(pBox, zb)
                    label zl = label.new(xc0, (zTop + zBot) / 2, "B-IMB", xloc = xloc.bar_index, style = label.style_label_right, color = colBuy, textcolor = color.white, size = size.small)
                    array.push(pLab, zl)
            int runS = 0
            for j = 0 to N - 1
                runS := array.get(sImbArr, j) ? runS + 1 : 0
                bool closeS = j == N - 1 ? array.get(sImbArr, j) : not array.get(sImbArr, j + 1)
                if closeS and runS >= stackN
                    float zTop = loLB + (j + 1) * step
                    float zBot = loLB + (j - runS + 1) * step
                    box zb = box.new(xc0, zTop, xc1, zBot, xloc = xloc.bar_index, bgcolor = na, border_color = colSell, border_width = 2)
                    array.push(pBox, zb)
                    label zl = label.new(xc0, (zTop + zBot) / 2, "S-IMB", xloc = xloc.bar_index, style = label.style_label_right, color = colSell, textcolor = color.white, size = size.small)
                    array.push(pLab, zl)

// =============================================================================
//  USAGE:
//   1) Premium/Ultimate -> add to chart (overlay). Pick the "Lookback period".
//   2) "1 hour" shows the LAST 60 minutes of chart bars (rolling, slides each bar).
//   3) Lookback high/low = solid lines extending right; the panel sits between them.
//      Row HEIGHT = ticks per row: Auto (0.2 x ATR, volatility-adaptive) or Manual.
//      The number of rows follows the range -> consistent, non-overlapping rows.
//   4) Each row = real buy/sell at that price band (Sell left, Buy right). POC gold.
//  NOTE: factual aggregation of bid/ask, NOT a buy/sell signal. No profit promise.
// =============================================================================
````
