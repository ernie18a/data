# Aurora Compass [JOAT]

- url: https://www.tradingview.com/script/dv3KXM0G-Aurora-Compass-JOAT/
- type: indicator
- pine_id: PUB;c12a960afe284364a402b627c33d04f8
- version: 1.0

## Description

[b]Aurora Compass [JOAT][/b]

Aurora Compass is a higher-timeframe volume-profile overlay with smart-money-weighted bin coloring, Point of Control (POC) tracking, Value Area High / Value Area Low boundaries, top-three High Volume Node (HVN) full-chart-width zones, low-volume node markers, liquidity-sweep detection with persistent price labels, an inter-interval POC drift trail, profile imbalance and HVN-rotation alerts, and a right-side 21-segment bias compass.

[b]What makes it different[/b]
[list]
[*] Traditional volume profile shows raw volume distribution. Aurora Compass weights each candle's contribution by a normalized Negative Volume Index delta, emphasising bars where institutions tend to transact (NVI-up days). The result highlights levels of smart-money concentration, not just raw turnover.
[*] Full-chart-width HVN zone boxes (not just thin borders) make the top three nodes obvious across the entire visible price history.
[*] Value Area High and Value Area Low are computed and drawn. The price boundaries that bracket 70% of profile volume. These are first-class horizontal levels with right-edge labels.
[*] An inter-interval POC drift trail draws a line from each interval's POC midpoint to the next, colored by direction. You can read multi-day POC migration at a glance.
[*] Liquidity sweeps are detected when price wicks beyond an HVN and the candle body closes back through. The script prints a persistent price label, not just a marker.
[/list]


[image]https://www.tradingview.com/x/JFDZq9Ev/[/image]

[b]How it works[/b]
[list=1]
[*] Higher-timeframe rollover is detected via ta.change(htfTf). No request.security is used. The profile is constructed from local bars within the interval.
[*] The price range within the active interval is binned into [i]res[/i] slices. For each bin, the script accumulates total volume and smart-money-weighted signed volume.
[*] POC is the bin midpoint with the maximum total volume. Value Area is computed by expanding outward from POC until cumulative volume reaches 70%.
[*] Top three bins by volume become HVNs. Bottom three become LVNs, where breakouts tend to accelerate through low-resistance areas.
[*] Sweep markers fire when a wick pierces an HVN boundary and the body closes the other side.
[*] POC drift in ATR units is tracked across interval boundaries. Imbalance is the absolute net signed volume divided by total volume.
[/list]

[b]Reading the chart[/b]
[list]
[*] Heatmap boxes for each bin, transparency-modulated by relative volume share. Smart-money weighting tints them mint or red according to net flow direction.
[*] POC dashed horizontal line extends across the visible chart with a right-edge price label that includes the inter-interval drift in ATR units.
[*] VAH and VAL dashed lines with right-edge labels.
[*] Three HVN full-width zones with right-edge price and volume labels.
[*] Three LVN border-only highlights (visually distinct from filled HVN).
[*] HTF interval boundary dotted vertical lines (capped to last 20 intervals).
[*] Per-interval sentiment timeline labels above each historical interval's high.
[*] Liquidity sweep labels at sweep wicks (for example SWEEP 4520.50).
[*] Inter-interval POC drift trail (capped to last 10 segments).
[*] Right-side 30-segment vertical bias gauge with horizontal sight-line and pointer label.
[/list]

[b]Signals[/b]
[list]
[*] Bullish / bearish liquidity sweep
[*] Bullish / bearish POC drift
[*] HVN touch
[*] HVN rotation (top-3 ordering changed between intervals)
[*] Profile imbalance bull / bear (net signed volume crosses the threshold)
[*] VAH / VAL touch and Value Area reclaim (up / down breakouts)
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references.

[b]Inputs[/b]
[list]
[*] [b]HTF Profile[/b]: higher timeframe selector, profile resolution, intensity scale, show heatmap, show POC, show HVN.
[*] [b]Cross-Interval[/b]: HTF interval markers, sentiment timeline, POC trail, LVN bands, sweep labels, gauge, sentiment label, Value Area, HVN zones, imbalance threshold.
[*] [b]Sweep[/b]: detection toggle.
[*] [b]Visual[/b]: bullish / bearish colors, intensity scale.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]HVN reactions[/b]: the top-three HVN zones are the levels most likely to attract price retests. Look for rejections or breakouts at these levels.
[*] [b]LVN acceleration[/b]: when price enters a low-volume bin, expected travel speed is faster. These are thin-air zones useful for measured-move targets.
[*] [b]Sweep then reclaim[/b]: a bull sweep where price wicks below an HVN and closes above is a classic stop-hunt-then-reverse pattern.
[*] [b]POC drift[/b]: a series of mint trail segments showing upward POC migration across multiple HTF intervals is a structural up-trend signal independent of price action on the LTF.
[*] [b]Value Area[/b]: trading within Value Area is range / rotation behavior. Trading outside is trend / discovery behavior.
[/list]

[b]Limitations[/b]
[list]
[*] The profile is built from local LTF bars within an HTF interval. Resolution and quality scale with how many LTF bars fit in the HTF window. Daily HTF with 1-minute LTF gives the richest profile.
[*] Smart-money weighting via NVI is a proxy. It is not a substitute for true tick-level order-flow data.
[*] HVN / LVN selection is recomputed each bar and may shift as new volume arrives within an interval. Once the interval closes the profile is locked.
[*] For very illiquid instruments the profile is sparse and the levels are less informative.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator. Any symbol with volume data. HTF must be strictly higher than the chart timeframe. No external request.security calls. Non-repainting: signals fire on confirmed bars.

[b]Defaults[/b]
Daily HTF, 30 bins, mint / red palette, top-right medium dashboard. For higher resolution increase the bin count. For noisier instruments raise the imbalance threshold.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aurora Compass [JOAT]", "AUC [JOAT]", overlay=true, behind_chart=true, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_htf     = "HTF Profile"
g_chart   = "Chart Overlay"
g_sweep   = "Sweep"
g_compass = "Compass"
g_visual  = "Visual"
g_dash    = "Dashboard"

htfTf       = input.timeframe("1D", "Higher Timeframe",                   group=g_htf,     tooltip="Higher timeframe used to demarcate each profile window. Set to a timeframe strictly higher than the chart's resolution (e.g. 1D when charting 15m).")
res         = input.int(30, "Profile Resolution", minval=4, maxval=100,   group=g_htf,     tooltip="Number of vertical price bins per HTF interval. Higher values add price-resolution but increase object updates.")
showHeat    = input.bool(true,  "Show Heatmap",                           group=g_htf,     tooltip="Toggle the per-interval volume heatmap behind chart candles.")
intensityScale = input.float(1.0, "Heatmap Intensity", minval=0.5, maxval=2.0, step=0.1, group=g_htf, tooltip="Multiply the heatmap opacity intensity. 1.0 default; raise to make bins more punchy, lower to fade.")
showPOC     = input.bool(true,  "Show POC Line",                          group=g_htf,     tooltip="Toggle the dashed point-of-control line.")
showVA      = input.bool(true,  "Show Value Area (VAH/VAL)",              group=g_htf,     tooltip="Toggle the dashed Value Area High and Value Area Low lines containing 70% of volume.")
showHVN     = input.bool(true,  "Show Top-3 HVN (in-window)",             group=g_htf,     tooltip="Toggle thin coloured rectangles around the three highest-volume bins inside the active interval.")
showHVNZones = input.bool(true, "Show HVN Zone Bands (full width)",       group=g_chart,   tooltip="Toggle persistent low-opacity horizontal bands marking the top-3 HVN price levels across the entire chart.")
showLVN     = input.bool(true,  "Show LVN Nodes (low-vol thin bands)",    group=g_chart,   tooltip="Toggle thin striped horizontal bands at the three LOWEST-volume bins inside the active interval — price holes where breakouts accelerate.")
showIntervals = input.bool(true, "Show HTF Interval Boundaries",          group=g_chart,   tooltip="Toggle dotted vertical lines at each HTF interval boundary.")
showSentimentTimeline = input.bool(true, "Show Sentiment Timeline",       group=g_chart,   tooltip="Toggle per-interval sentiment labels above prior intervals' highs.")
showPOCTrail = input.bool(true, "Show POC Drift Trail",                   group=g_chart,   tooltip="Toggle line segments connecting prior interval POCs to current POC.")

detectSweep = input.bool(true,  "Detect Liquidity Sweeps",                group=g_sweep,   tooltip="Detect wick-and-reclaim liquidity sweeps at any top-3 HVN. Bullish: wick prints below an HVN bottom while close prints back above the HVN top. Bearish is the inverse.")
imbalThr    = input.float(0.6, "Profile Imbalance Threshold", minval=0.1, maxval=0.95, step=0.05, group=g_sweep, tooltip="Threshold for the AUC Profile Imbalance alert. Fires when |signed-volume / total-volume| exceeds this fraction.")

showGauge   = input.bool(true,  "Show Right-Edge Compass Gauge",          group=g_compass, tooltip="Toggle the 30-segment vertical bias gauge drawn at the chart's right edge.")
showLabel   = input.bool(true,  "Show Sentiment Label",                   group=g_compass, tooltip="Toggle the textual sentiment label at the bottom of the current HTF range.")

bullColor   = input.color(#00ffbb, "Bullish", inline="cBull",             group=g_visual,  tooltip="Primary bullish color — JOAT brand mint. Applied to bullish bins, HVN outlines and the gauge top.")
bearColor   = input.color(#ff1100, "Bearish", inline="cBull",             group=g_visual,  tooltip="Primary bearish color — JOAT brand red. Applied to bearish bins, HVN outlines and the gauge bottom.")

showDash    = input.bool(true,  "Show Dashboard",                         group=g_dash,    tooltip="Toggle the institutional dashboard panel.")
dashPos     = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize    = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════

posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

formatVolume(float v) =>
    str.lower(str.tostring(math.abs(v), format.volume))

nvi_series   = ta.nvi
nviChange    = nvi_series - nz(nvi_series[1])
nviPrevAbs   = math.max(math.abs(nz(nvi_series[1])), 1.0)
smartWeight  = 1.0 + 0.3 * (nviChange / nviPrevAbs)

profileCalc(int startIdx, int endIdx, int resn) =>
    top_bounds = array.new_float(resn)
    bot_bounds = array.new_float(resn)
    binVol     = array.new_float(resn)
    binSigned  = array.new_float(resn)
    highs      = array.new_float()
    lows       = array.new_float()
    volumes    = array.new_float()
    dirs       = array.new_int()
    smartW     = array.new_float()

    loopLen = math.min(bar_index - startIdx, 1000)
    if loopLen >= 0
        for offset = loopLen to 0
            if not na(high[offset]) and not na(low[offset]) and not na(volume[offset])
                highs.push(high[offset])
                lows.push(low[offset])
                volumes.push(volume[offset])
                dirs.push(close[offset] > open[offset] ? 1 : -1)
                smartW.push(nz(smartWeight[offset], 1.0))

    float poc = 0.0
    float vah = 0.0
    float val = 0.0
    int   pocIdx = 0
    if highs.size() > 0
        maxx = highs.max()
        minn = lows.min()
        if maxx > minn
            step = (maxx - minn) / resn
            for k = 0 to resn - 1
                bottomY = minn + k * step
                topY    = minn + (k + 1) * step
                bot_bounds.set(k, bottomY)
                top_bounds.set(k, topY)
                binV  = 0.0
                binS  = 0.0
                for j = 0 to highs.size() - 1
                    if not (lows.get(j) > topY or highs.get(j) < bottomY)
                        v = volumes.get(j)
                        w = smartW.get(j)
                        binV += v
                        binS += v * dirs.get(j) * w
                binVol.set(k, binV)
                binSigned.set(k, binS)
            pIdx = binVol.indexof(binVol.max())
            pocIdx := pIdx >= 0 ? pIdx : 0
            poc := math.avg(top_bounds.get(pocIdx), bot_bounds.get(pocIdx))

            totalV = 0.0
            for kk = 0 to resn - 1
                totalV += binVol.get(kk)
            cumV = binVol.get(pocIdx)
            target = totalV * 0.70
            int hiIdx = pocIdx
            int loIdx = pocIdx
            while cumV < target and (hiIdx < resn - 1 or loIdx > 0)
                float upV = hiIdx < resn - 1 ? binVol.get(hiIdx + 1) : -1.0
                float dnV = loIdx > 0       ? binVol.get(loIdx - 1) : -1.0
                if upV >= dnV and hiIdx < resn - 1
                    hiIdx += 1
                    cumV += upV
                else if loIdx > 0
                    loIdx -= 1
                    cumV += dnV
                else
                    break
            vah := top_bounds.get(hiIdx)
            val := bot_bounds.get(loIdx)
    [top_bounds, bot_bounds, binVol, binSigned, poc, vah, val]

// ════════════════════════════════════════════════════════════════════
// CORE — interval state & per-interval profile
// ════════════════════════════════════════════════════════════════════

new_ = timeframe.change(htfTf)

// Persistent interval state
var int   intervalStartBar     = na
var int   prevIntervalStartBar = na
var float prevIntervalHigh     = na
var float prevIntervalUp       = 0.0
var float prevIntervalDn       = 0.0
var float prevIntervalBias     = 0.0
var int   prevRes              = na

// Persistent draw collections
var box[]  heatmapBoxes  = array.new_box()
var box[]  hvnBoxes      = array.new_box()
var box[]  hvnZoneBoxes  = array.new_box()
var box[]  lvnBoxes      = array.new_box()
var label[] hvnZoneLabels= array.new_label()
var line   pocLine       = na
var label  pocLabel      = na
var line   vahLine       = na
var line   valLine       = na
var label  vahLabel      = na
var label  valLabel      = na
var line[] gaugeLines    = array.new_line()
var line   gaugeNeedle   = na
var line   gaugePointer  = na
var label  compassLabel  = na
var label  sentLabel     = na

// Long-lived overlay arrays (capped)
var array<line>  intervalLines   = array.new<line>()
var array<label> sentimentLabels = array.new<label>()
var array<label> sweepLabels     = array.new<label>()
var array<line>  pocTrail        = array.new<line>()

var int    lastSweepDir = 0
var int    lastSweepBar = na

var float    prevIntervalPOC = na
var int[]    prevHvnIdx      = array.new_int(3, -1)
var float    pocDriftATR     = 0.0
var bool     hvnRotated      = false

needPoolRebuild = na(intervalStartBar) or new_ or prevRes != res
if needPoolRebuild
    prevIntervalStartBar := intervalStartBar
    intervalStartBar := bar_index
    prevRes := res

    if array.size(heatmapBoxes) > 0
        for b in heatmapBoxes
            box.delete(b)
        array.clear(heatmapBoxes)
    for k = 0 to res - 1
        array.push(heatmapBoxes, box.new(intervalStartBar, 0.0, bar_index, 0.0, border_color=na, bgcolor=na))

    if array.size(hvnBoxes) > 0
        for b in hvnBoxes
            box.delete(b)
        array.clear(hvnBoxes)
    for k = 0 to 2
        array.push(hvnBoxes, box.new(intervalStartBar, 0.0, bar_index, 0.0, border_color=na, bgcolor=na))

    if array.size(lvnBoxes) > 0
        for b in lvnBoxes
            box.delete(b)
        array.clear(lvnBoxes)
    for k = 0 to 2
        array.push(lvnBoxes, box.new(intervalStartBar, 0.0, bar_index, 0.0, border_color=na, bgcolor=na))

    if array.size(hvnZoneBoxes) > 0
        for b in hvnZoneBoxes
            box.delete(b)
        array.clear(hvnZoneBoxes)
    for k = 0 to 2
        array.push(hvnZoneBoxes, box.new(intervalStartBar, 0.0, bar_index + 30, 0.0, border_color=na, bgcolor=na))
    if array.size(hvnZoneLabels) > 0
        for lab in hvnZoneLabels
            label.delete(lab)
        array.clear(hvnZoneLabels)
    for k = 0 to 2
        array.push(hvnZoneLabels, label.new(bar_index + 30, 0.0, "", style=label.style_label_left, color=na, textcolor=na, size=size.small, xloc=xloc.bar_index))

    if not na(pocLine)
        line.delete(pocLine)
    pocLine := line.new(intervalStartBar, close, bar_index + 30, close, color=na, style=line.style_dashed, width=2, xloc=xloc.bar_index)
    if not na(pocLabel)
        label.delete(pocLabel)
    pocLabel := label.new(bar_index + 30, close, "", style=label.style_label_left, color=na, textcolor=na, size=size.small, xloc=xloc.bar_index)

    if not na(vahLine)
        line.delete(vahLine)
    vahLine := line.new(intervalStartBar, close, bar_index + 30, close, color=na, style=line.style_dashed, width=1, xloc=xloc.bar_index)
    if not na(valLine)
        line.delete(valLine)
    valLine := line.new(intervalStartBar, close, bar_index + 30, close, color=na, style=line.style_dashed, width=1, xloc=xloc.bar_index)
    if not na(vahLabel)
        label.delete(vahLabel)
    vahLabel := label.new(bar_index + 30, close, "", style=label.style_label_left, color=na, textcolor=na, size=size.small, xloc=xloc.bar_index)
    if not na(valLabel)
        label.delete(valLabel)
    valLabel := label.new(bar_index + 30, close, "", style=label.style_label_left, color=na, textcolor=na, size=size.small, xloc=xloc.bar_index)

    if not na(sentLabel)
        label.delete(sentLabel)
    sentLabel := label.new(intervalStartBar, low, "", style=label.style_label_up, color=chart.bg_color, textcolor=chart.fg_color, size=size.small, textalign=text.align_left)

[topB, botB, binV, binS, pocPx, vahPx, valPx] = profileCalc(intervalStartBar, bar_index, res)

barsInInterval = math.max(bar_index - intervalStartBar + 1, 1)
htfHigh = ta.highest(high, barsInInterval)
htfLow  = ta.lowest(low,  barsInInterval)
atr14   = ta.atr(14)

// ────────────────────────────────────────────────────────────────────
// HVN detection — top-3 bins by raw participation
// ────────────────────────────────────────────────────────────────────
var int[] hvnIdx = array.new_int(3, -1)
var int[] lvnIdx = array.new_int(3, -1)

if new_ and not na(intervalStartBar[1])
    prevIntervalPOC := pocPx[1]
    if array.size(hvnIdx) > 0
        array.clear(prevHvnIdx)
        for sIdx = 0 to array.size(hvnIdx) - 1
            array.push(prevHvnIdx, hvnIdx.get(sIdx))

if array.size(binV) > 0
    array.clear(hvnIdx)
    array.clear(lvnIdx)
    work = array.new_float(0)
    for k = 0 to array.size(binV) - 1
        work.push(binV.get(k))
    for slot = 0 to 2
        if work.size() > 0
            mx = work.max()
            idxRaw = work.indexof(mx)
            if idxRaw >= 0 and mx > 0
                array.push(hvnIdx, idxRaw)
                work.set(idxRaw, -1.0)
            else
                array.push(hvnIdx, -1)
        else
            array.push(hvnIdx, -1)
    workLo = array.new_float(0)
    for k = 0 to array.size(binV) - 1
        v = binV.get(k)
        workLo.push(v > 0 ? v : 1e18)
    for slot = 0 to 2
        if workLo.size() > 0
            mn = workLo.min()
            idxRaw2 = workLo.indexof(mn)
            if idxRaw2 >= 0 and mn < 1e18
                array.push(lvnIdx, idxRaw2)
                workLo.set(idxRaw2, 1e18)
            else
                array.push(lvnIdx, -1)
        else
            array.push(lvnIdx, -1)

// ────────────────────────────────────────────────────────────────────
// HVN rotation — fires on the first bar of a new HTF interval when the
// top-3 ordering changed between the just-closed and prior intervals.
// ────────────────────────────────────────────────────────────────────
hvnRotated := false
if new_ and array.size(prevHvnIdx) >= 3 and array.size(hvnIdx) >= 3
    for sIdx = 0 to 2
        if prevHvnIdx.get(sIdx) != hvnIdx.get(sIdx)
            hvnRotated := true

// ────────────────────────────────────────────────────────────────────
// Sweep detection — top-3 HVN wick-and-reclaim on the current bar
// ────────────────────────────────────────────────────────────────────
confirmedBar = barstate.isconfirmed or barstate.ishistory

bullSweepRaw = false
bearSweepRaw = false
hvnTouchRaw  = false
if array.size(hvnIdx) > 0 and array.size(topB) > 0 and array.size(botB) > 0
    for slot = 0 to array.size(hvnIdx) - 1
        i_h = hvnIdx.get(slot)
        if i_h >= 0 and i_h < array.size(topB)
            hTop = topB.get(i_h)
            hBot = botB.get(i_h)
            if not na(hTop) and not na(hBot)
                if low < hBot and close > hTop
                    bullSweepRaw := true
                if high > hTop and close < hBot
                    bearSweepRaw := true
                if high >= hBot and low <= hTop
                    hvnTouchRaw := true

bullSweep  = detectSweep and bullSweepRaw and confirmedBar
bearSweep  = detectSweep and bearSweepRaw and confirmedBar
hvnTouch   = hvnTouchRaw and confirmedBar

if bullSweep
    lastSweepDir := 1
    lastSweepBar := bar_index
if bearSweep
    lastSweepDir := -1
    lastSweepBar := bar_index

barsSinceSweep = na(lastSweepBar) ? -1 : bar_index - lastSweepBar

// ────────────────────────────────────────────────────────────────────
// Bias score — POC-anchored, ATR-scaled, clamped to ±3
// ────────────────────────────────────────────────────────────────────
biasRaw  = (close - pocPx) / math.max(atr14, syminfo.mintick)
biasScore = math.max(-3.0, math.min(3.0, biasRaw))

pocDriftBull = pocPx > nz(pocPx[1]) and confirmedBar
pocDriftBear = pocPx < nz(pocPx[1]) and confirmedBar
pocDriftATR := na(prevIntervalPOC) ? 0.0 : (pocPx - prevIntervalPOC) / math.max(atr14, syminfo.mintick)

// ════════════════════════════════════════════════════════════════════
// VISUALS — heatmap boxes (intensity-scaled)
// ════════════════════════════════════════════════════════════════════
maxBinV = array.size(binV) > 0 ? binV.max() : 0.0
totalUp  = 0.0
totalDn  = 0.0

drawN = math.min(array.size(heatmapBoxes), math.min(array.size(topB), math.min(array.size(botB), math.min(array.size(binV), array.size(binS)))))
if drawN > 0
    for k = 0 to drawN - 1
        bx       = array.get(heatmapBoxes, k)
        topY     = topB.get(k)
        botY     = botB.get(k)
        v        = binV.get(k)
        signedV  = binS.get(k)
        totalAbs = math.abs(v)
        if signedV >= 0
            totalUp += totalAbs
        else
            totalDn += totalAbs
        normRaw  = maxBinV > 0 ? v / maxBinV : 0.0
        norm     = math.min(normRaw * intensityScale, 1.0)
        transp   = 50 + math.round((1.0 - norm) * 35.0)
        baseC    = signedV > 0 ? bullColor : signedV < 0 ? bearColor : chart.fg_color
        box.set_left(bx, intervalStartBar)
        box.set_right(bx, bar_index)
        box.set_top(bx, topY)
        box.set_bottom(bx, botY)
        box.set_bgcolor(bx, showHeat ? color.new(baseC, transp) : na)
        box.set_border_color(bx, showHeat ? color.new(baseC, math.min(transp + 5, 95)) : na)

profileTotal     = totalUp + totalDn
profileImbalance = profileTotal > 0 ? math.abs(totalUp - totalDn) / profileTotal : 0.0
imbalanceBull    = totalUp > totalDn and profileImbalance >= imbalThr and confirmedBar and nz(profileImbalance[1]) < imbalThr
imbalanceBear    = totalDn > totalUp and profileImbalance >= imbalThr and confirmedBar and nz(profileImbalance[1]) < imbalThr

// ════════════════════════════════════════════════════════════════════
// VISUALS — POC line + right-edge label
// ════════════════════════════════════════════════════════════════════
if not na(pocLine)
    line.set_x1(pocLine, intervalStartBar)
    line.set_x2(pocLine, bar_index + 30)
    line.set_y1(pocLine, pocPx)
    line.set_y2(pocLine, pocPx)
    line.set_color(pocLine, showPOC ? color.new(chart.fg_color, 15) : na)
if not na(pocLabel)
    driftStr = pocDriftATR >= 0 ? "+" : "-"
    pocText = "POC " + str.tostring(pocPx, format.mintick) + "  drift " + driftStr + str.tostring(math.abs(pocDriftATR), "0.00") + "atr"
    label.set_x(pocLabel, bar_index + 30)
    label.set_y(pocLabel, pocPx)
    label.set_text(pocLabel, showPOC ? pocText : "")
    label.set_textcolor(pocLabel, showPOC ? chart.fg_color : na)
    label.set_color(pocLabel, showPOC ? color.new(chart.bg_color, 30) : na)

// ════════════════════════════════════════════════════════════════════
// VISUALS — VAH / VAL dashed lines + right-edge labels
// ════════════════════════════════════════════════════════════════════
if not na(vahLine)
    line.set_x1(vahLine, intervalStartBar)
    line.set_x2(vahLine, bar_index + 30)
    line.set_y1(vahLine, vahPx)
    line.set_y2(vahLine, vahPx)
    line.set_color(vahLine, showVA ? color.new(bullColor, 30) : na)
if not na(valLine)
    line.set_x1(valLine, intervalStartBar)
    line.set_x2(valLine, bar_index + 30)
    line.set_y1(valLine, valPx)
    line.set_y2(valLine, valPx)
    line.set_color(valLine, showVA ? color.new(bearColor, 30) : na)
if not na(vahLabel)
    label.set_x(vahLabel, bar_index + 30)
    label.set_y(vahLabel, vahPx)
    label.set_text(vahLabel, showVA ? "VAH " + str.tostring(vahPx, format.mintick) : "")
    label.set_textcolor(vahLabel, showVA ? bullColor : na)
    label.set_color(vahLabel, showVA ? color.new(chart.bg_color, 30) : na)
if not na(valLabel)
    label.set_x(valLabel, bar_index + 30)
    label.set_y(valLabel, valPx)
    label.set_text(valLabel, showVA ? "VAL " + str.tostring(valPx, format.mintick) : "")
    label.set_textcolor(valLabel, showVA ? bearColor : na)
    label.set_color(valLabel, showVA ? color.new(chart.bg_color, 30) : na)

vahTouch    = (high >= vahPx and low <= vahPx) and confirmedBar
valTouch    = (high >= valPx and low <= valPx) and confirmedBar
vaReclaimUp = (close > vahPx and nz(close[1]) <= nz(vahPx[1])) and confirmedBar
vaReclaimDn = (close < valPx and nz(close[1]) >= nz(valPx[1])) and confirmedBar

// ════════════════════════════════════════════════════════════════════
// VISUALS — HVN in-window thin highlights (existing pool)
// ════════════════════════════════════════════════════════════════════
if array.size(hvnBoxes) > 0 and array.size(hvnIdx) > 0
    for slot = 0 to array.size(hvnBoxes) - 1
        hb = array.get(hvnBoxes, slot)
        if slot < array.size(hvnIdx)
            iH = hvnIdx.get(slot)
            if iH >= 0 and iH < array.size(topB) and showHVN
                hT = topB.get(iH)
                hB = botB.get(iH)
                signedH = binS.get(iH)
                borderC = signedH > 0 ? bullColor : signedH < 0 ? bearColor : chart.fg_color
                box.set_left(hb, intervalStartBar)
                box.set_right(hb, bar_index)
                box.set_top(hb, hT)
                box.set_bottom(hb, hB)
                box.set_bgcolor(hb, na)
                box.set_border_color(hb, color.new(borderC, 20))
                box.set_border_width(hb, 1)
            else
                box.set_bgcolor(hb, na)
                box.set_border_color(hb, na)
        else
            box.set_bgcolor(hb, na)
            box.set_border_color(hb, na)

// ════════════════════════════════════════════════════════════════════
// VISUALS — HVN full-chart-width zones (persistent low-opacity bands)
// One band per top-3 HVN; spans from intervalStartBar to bar_index+30.
// Each band carries a right-edge plain-text label with price + volume.
// ════════════════════════════════════════════════════════════════════
tickPad = syminfo.mintick * 4.0
if array.size(hvnZoneBoxes) > 0 and array.size(hvnIdx) > 0
    for slot = 0 to array.size(hvnZoneBoxes) - 1
        zb = array.get(hvnZoneBoxes, slot)
        zlab = array.get(hvnZoneLabels, slot)
        if slot < array.size(hvnIdx)
            iH = hvnIdx.get(slot)
            if iH >= 0 and iH < array.size(topB) and showHVNZones
                hT = topB.get(iH)
                hB = botB.get(iH)
                signedH = binS.get(iH)
                volH = binV.get(iH)
                midH = math.avg(hT, hB)
                dirC = signedH > 0 ? bullColor : signedH < 0 ? bearColor : chart.fg_color
                box.set_left(zb, intervalStartBar)
                box.set_right(zb, bar_index + 30)
                box.set_top(zb, hT + tickPad)
                box.set_bottom(zb, hB - tickPad)
                box.set_bgcolor(zb, color.new(dirC, 88))
                box.set_border_color(zb, color.new(dirC, 60))
                box.set_border_width(zb, 1)
                label.set_x(zlab, bar_index + 30)
                label.set_y(zlab, midH)
                label.set_text(zlab, "HVN" + str.tostring(slot + 1) + " " + str.tostring(midH, format.mintick) + "  " + formatVolume(volH))
                label.set_textcolor(zlab, dirC)
                label.set_color(zlab, color.new(chart.bg_color, 30))
            else
                box.set_bgcolor(zb, na)
                box.set_border_color(zb, na)
                label.set_text(zlab, "")
                label.set_color(zlab, na)
                label.set_textcolor(zlab, na)
        else
            box.set_bgcolor(zb, na)
            box.set_border_color(zb, na)
            label.set_text(zlab, "")
            label.set_color(zlab, na)
            label.set_textcolor(zlab, na)

// ════════════════════════════════════════════════════════════════════
// VISUALS — LVN nodes (bottom-3 by volume), thin striped border-only
// "Price holes" — likely breakout acceleration zones.
// ════════════════════════════════════════════════════════════════════
if array.size(lvnBoxes) > 0 and array.size(lvnIdx) > 0
    for slot = 0 to array.size(lvnBoxes) - 1
        lb = array.get(lvnBoxes, slot)
        if slot < array.size(lvnIdx)
            iL = lvnIdx.get(slot)
            if iL >= 0 and iL < array.size(topB) and showLVN
                lT = topB.get(iL)
                lB = botB.get(iL)
                signedL = binS.get(iL)
                // Visual contrast vs HVN: NO fill, thin dashed-style border.
                lvnC = signedL >= 0 ? color.new(bullColor, 40) : color.new(bearColor, 40)
                box.set_left(lb, intervalStartBar)
                box.set_right(lb, bar_index + 30)
                box.set_top(lb, lT)
                box.set_bottom(lb, lB)
                box.set_bgcolor(lb, na)
                box.set_border_color(lb, lvnC)
                box.set_border_width(lb, 1)
            else
                box.set_bgcolor(lb, na)
                box.set_border_color(lb, na)
        else
            box.set_bgcolor(lb, na)
            box.set_border_color(lb, na)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Liquidity sweep markers
// Subtle dot (kept) PLUS a persistent price label at the wick extreme.
// ════════════════════════════════════════════════════════════════════
plotchar(bullSweep ? low  : na, "Bull Sweep Marker", char="·", location=location.absolute, color=bullColor, size=size.tiny)
plotchar(bearSweep ? high : na, "Bear Sweep Marker", char="·", location=location.absolute, color=bearColor, size=size.tiny)

if bullSweep
    lab = label.new(bar_index, low, "SWEEP " + str.tostring(low, format.mintick), color=color.new(bullColor, 70), textcolor=chart.fg_color, style=label.style_label_up, size=size.small, xloc=xloc.bar_index)
    array.push(sweepLabels, lab)
if bearSweep
    lab = label.new(bar_index, high, "SWEEP " + str.tostring(high, format.mintick), color=color.new(bearColor, 70), textcolor=chart.fg_color, style=label.style_label_down, size=size.small, xloc=xloc.bar_index)
    array.push(sweepLabels, lab)

while array.size(sweepLabels) > 30
    old = array.shift(sweepLabels)
    label.delete(old)

// ════════════════════════════════════════════════════════════════════
// VISUALS — HTF interval boundaries (dotted vertical lines)
// ════════════════════════════════════════════════════════════════════
if new_ and showIntervals
    bln = line.new(bar_index, low * 0.99, bar_index, high * 1.01, color=color.new(chart.fg_color, 80), style=line.style_dotted, extend=extend.both, xloc=xloc.bar_index)
    array.push(intervalLines, bln)
while array.size(intervalLines) > 20
    old = array.shift(intervalLines)
    line.delete(old)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Per-interval sentiment timeline labels
// On every HTF rollover we freeze the prior interval's stats and pin a
// plain-text label above its high at the interval midpoint.
// ════════════════════════════════════════════════════════════════════
if new_ and not na(prevIntervalStartBar) and showSentimentTimeline
    midBar = math.round((prevIntervalStartBar + bar_index - 1) / 2.0)
    pHi    = nz(prevIntervalHigh, high)
    delta  = prevIntervalUp - prevIntervalDn
    deltaStr = (delta >= 0 ? "+" : "-") + formatVolume(delta)
    sentTxt2 = (prevIntervalBias > 0.3 ? "BULL " : prevIntervalBias < -0.3 ? "BEAR " : "FLAT ") + deltaStr + "  bias " + str.tostring(prevIntervalBias, "0.00")
    sentCol  = prevIntervalBias > 0.3 ? bullColor : prevIntervalBias < -0.3 ? bearColor : chart.fg_color
    yLabel   = pHi + nz(atr14, syminfo.mintick) * 0.5
    sl = label.new(midBar, yLabel, sentTxt2, color=na, textcolor=sentCol, style=label.style_none, size=size.small, xloc=xloc.bar_index)
    array.push(sentimentLabels, sl)
while array.size(sentimentLabels) > 20
    old = array.shift(sentimentLabels)
    label.delete(old)

if not new_
    prevIntervalHigh := math.max(nz(prevIntervalHigh, high), high)
    prevIntervalUp   := totalUp
    prevIntervalDn   := totalDn
    prevIntervalBias := biasScore
else
    prevIntervalHigh := high
    prevIntervalUp   := 0.0
    prevIntervalDn   := 0.0
    prevIntervalBias := 0.0

// ════════════════════════════════════════════════════════════════════
// VISUALS — POC drift trail
// One short line segment per HTF rollover, prevPOC -> currentPOC,
// colored by direction. Cap at 10 segments.
// ════════════════════════════════════════════════════════════════════
if new_ and not na(prevIntervalPOC) and not na(prevIntervalStartBar) and showPOCTrail
    prevMid = math.round((prevIntervalStartBar + bar_index - 1) / 2.0)
    curMid  = bar_index
    dirCol  = pocPx > prevIntervalPOC ? bullColor : pocPx < prevIntervalPOC ? bearColor : chart.fg_color
    tln = line.new(prevMid, prevIntervalPOC, curMid, pocPx, color=color.new(dirCol, 20), width=2, style=line.style_solid, xloc=xloc.bar_index)
    array.push(pocTrail, tln)
while array.size(pocTrail) > 10
    old = array.shift(pocTrail)
    line.delete(old)

// ════════════════════════════════════════════════════════════════════
// VISUALS — Right-edge Aurora Compass gauge (30-segment band + needle)
// ════════════════════════════════════════════════════════════════════
if barstate.islast
    if array.size(gaugeLines) > 0
        for ln in gaugeLines
            line.delete(ln)
        array.clear(gaugeLines)
    if not na(compassLabel)
        label.delete(compassLabel)
        compassLabel := na
    if not na(gaugeNeedle)
        line.delete(gaugeNeedle)
        gaugeNeedle := na
    if not na(gaugePointer)
        line.delete(gaugePointer)
        gaugePointer := na

    if showGauge and htfHigh > htfLow
        segments = 30
        segLen   = (htfHigh - htfLow) / segments
        for k = 0 to segments - 1
            y1 = htfHigh - k * segLen
            y2 = htfHigh - (k + 1) * segLen
            yMid = math.avg(y1, y2)
            segCol = color.from_gradient(yMid, htfLow, htfHigh, bearColor, bullColor)
            ln = line.new(bar_index + 4, y1, bar_index + 4, y2, color=segCol, width=6, xloc=xloc.bar_index)
            array.push(gaugeLines, ln)
        pointerY  = htfLow + ((biasScore + 3.0) / 6.0) * (htfHigh - htfLow)
        biasText  = biasScore > 0.3 ? "BULL  " + str.tostring(math.abs(biasScore), "0.00") : biasScore < -0.3 ? "BEAR  " + str.tostring(math.abs(biasScore), "0.00") : "NEUTRAL"
        pointerC  = biasScore > 0.3 ? bullColor : biasScore < -0.3 ? bearColor : chart.fg_color
        needleC = color.from_gradient(biasScore, -3.0, 3.0, bearColor, bullColor)
        gaugeNeedle := line.new(bar_index - 20, pointerY, bar_index + 4, pointerY, color=color.new(needleC, 30), width=1, style=line.style_dashed, xloc=xloc.bar_index)
        gaugePointer := line.new(bar_index + 5, pointerY, bar_index + 8, pointerY, color=pointerC, width=3, style=line.style_solid, xloc=xloc.bar_index)
        compassLabel := label.new(bar_index + 9, pointerY, biasText, color=na, textcolor=pointerC, size=size.small, style=label.style_label_left, xloc=xloc.bar_index)

// ════════════════════════════════════════════════════════════════════
// VISUALS — sentiment label (text-only, anchored beneath HTF low)
// ════════════════════════════════════════════════════════════════════
deltaVol  = totalUp - totalDn
signedDelta = (deltaVol >= 0 ? "+" : "-") + formatVolume(deltaVol)
biasLabel = biasScore > 0.3 ? "BULL" : biasScore < -0.3 ? "BEAR" : "NEUTRAL"
sentTxt = "AURORA  bias " + biasLabel + " | up " + formatVolume(totalUp) + "  dn " + formatVolume(totalDn) + "  delta " + signedDelta
if not na(sentLabel)
    rangeNow = math.max(htfHigh - htfLow, syminfo.mintick)
    labelY   = htfLow - rangeNow * 0.06
    labelX   = math.round((intervalStartBar + bar_index) / 2.0)
    label.set_x(sentLabel, labelX)
    label.set_y(sentLabel, labelY)
    label.set_text(sentLabel, showLabel ? sentTxt : "")
    label.set_textcolor(sentLabel, showLabel ? (biasScore > 0.3 ? bullColor : biasScore < -0.3 ? bearColor : chart.fg_color) : na)
    label.set_color(sentLabel, showLabel ? chart.bg_color : na)

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 13,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

f_biasText(float b) =>
    b > 0.3 ? "BULL" : b < -0.3 ? "BEAR" : "NEUTRAL"

f_biasBg(float b) =>
    b > 0.3 ? color.new(bullColor, 60) : b < -0.3 ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_sweepText(int d) =>
    d == 1 ? "BULL" : d == -1 ? "BEAR" : "NONE"

f_sweepBg(int d) =>
    d == 1 ? color.new(bullColor, 60) : d == -1 ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_driftBg(float a) =>
    a > 0.25 ? color.new(bullColor, 60) : a < -0.25 ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_imbalBg(float u, float d) =>
    u > d ? color.new(bullColor, 60) : d > u ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_hvnRow(int slot, int[] idxArr, float[] tArr, float[] bArr, float[] vArr) =>
    string outTxt = "-"
    if slot < array.size(idxArr) and array.size(tArr) > 0 and array.size(vArr) > 0
        iH = idxArr.get(slot)
        if iH >= 0 and iH < array.size(tArr)
            midP = math.avg(tArr.get(iH), bArr.get(iH))
            volH = vArr.get(iH)
            outTxt := str.tostring(midP, format.mintick) + "  " + formatVolume(volH)
    outTxt

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 13,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    table.clear(dash, 0, 0, 1, 12)
    txtSize = sizeFromString(dashSize)

    table.cell(dash, 0, 0, "Aurora Compass [JOAT]", text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.cell(dash, 1, 0, "",                       text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "HTF",                                                text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 1, htfTf,                                                text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 2, "POC",                                                text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 2, str.tostring(pocPx, format.mintick),                  text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 3, "Bias",                                               text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 3, f_biasText(biasScore),                                text_color=color.white,    bgcolor=f_biasBg(biasScore), text_size=txtSize)

    table.cell(dash, 0, 4, "Bias Score",                                         text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 4, str.tostring(biasScore, "0.00"),                      text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 5, "Last Sweep",                                         text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 5, f_sweepText(lastSweepDir),                            text_color=color.white,    bgcolor=f_sweepBg(lastSweepDir), text_size=txtSize)

    table.cell(dash, 0, 6, "Bars Since",                                         text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 6, barsSinceSweep < 0 ? "-" : str.tostring(barsSinceSweep), text_color=color.white, bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 7, "POC Drift (ATR)",                                    text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 7, na(prevIntervalPOC) ? "-" : str.tostring(pocDriftATR, "+0.00;-0.00"), text_color=color.white, bgcolor=f_driftBg(pocDriftATR), text_size=txtSize)

    table.cell(dash, 0, 8, "Imbalance",                                          text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 8, str.tostring(profileImbalance, "0.00"),               text_color=color.white,    bgcolor=f_imbalBg(totalUp, totalDn), text_size=txtSize)

    table.cell(dash, 0, 9, "HVN #1",                                             text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 9, f_hvnRow(0, hvnIdx, topB, botB, binV),                text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 10, "HVN #2",                                            text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 10, f_hvnRow(1, hvnIdx, topB, botB, binV),               text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 11, "HVN #3",                                            text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 11, f_hvnRow(2, hvnIdx, topB, botB, binV),               text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 12, "@JackOfAllTrades",                                  text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.cell(dash, 1, 12, "",                                                  text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.merge_cells(dash, 0, 12, 1, 12)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(bullSweep,     title="AUC Bullish Sweep",       message="Aurora Compass [JOAT] — Bullish liquidity sweep + reclaim")
alertcondition(bearSweep,     title="AUC Bearish Sweep",       message="Aurora Compass [JOAT] — Bearish liquidity sweep + reclaim")
alertcondition(pocDriftBull,  title="AUC POC Drift Up",        message="Aurora Compass [JOAT] — POC drifted higher")
alertcondition(pocDriftBear,  title="AUC POC Drift Down",      message="Aurora Compass [JOAT] — POC drifted lower")
alertcondition(hvnTouch,      title="AUC HVN Touch",           message="Aurora Compass [JOAT] — Price touched a top-3 HVN")
alertcondition(hvnRotated,    title="AUC HVN Rotation",        message="Aurora Compass [JOAT] — Top-3 HVN ordering changed between HTF intervals")
alertcondition(imbalanceBull, title="AUC Profile Imbalance Bull", message="Aurora Compass [JOAT] — Live profile imbalance crossed threshold (bullish)")
alertcondition(imbalanceBear, title="AUC Profile Imbalance Bear", message="Aurora Compass [JOAT] — Live profile imbalance crossed threshold (bearish)")
alertcondition(vahTouch,      title="AUC VAH Touch",           message="Aurora Compass [JOAT] — Price touched Value Area High")
alertcondition(valTouch,      title="AUC VAL Touch",           message="Aurora Compass [JOAT] — Price touched Value Area Low")
alertcondition(vaReclaimUp,   title="AUC VA Breakout Up",      message="Aurora Compass [JOAT] — Close broke above Value Area High")
alertcondition(vaReclaimDn,   title="AUC VA Breakdown Down",   message="Aurora Compass [JOAT] — Close broke below Value Area Low")
````
