# Vortex Volume Spectrum [JOAT]

- url: https://www.tradingview.com/script/2eONeXhp-Vortex-Volume-Spectrum-JOAT/
- type: indicator
- pine_id: PUB;507fb31b7fc349a6a3038494ccb7bd39
- version: 1.0

## Description

[b]Vortex Volume Spectrum [JOAT][/b]

[b]Overview[/b]

Vortex Volume Spectrum is a dynamic, proportional volume profile indicator built from scratch in Pine Script v6. It analyses how traded volume distributes across price levels within any configurable lookback window, identifies the Point of Control (POC) — the price level with the highest volume concentration — and draws the Value Area (the 70% of total volume nearest the POC) as a live-updating profile rendered directly on the chart using the box drawing API. Unlike fixed-range volume profiles offered by some platforms, this engine recalculates on every bar and is fully parametric.

[image]https://www.tradingview.com/x/6e4tAEVf/[/image]

[b]Why Build a Volume Profile in Pine?[/b]

Volume profile is one of the most powerful market microstructure tools available, revealing where the majority of market participants transacted. Most TradingView users rely on the built-in session profile which cannot be customised, scripted, or combined with other logic. Vortex Volume Spectrum gives Pine authors and traders a fully transparent, open-source volume distribution engine they can understand, modify, and build upon — with the visual quality of a professional charting suite.

[b]Distribution Engine[/b]

The profile is built with a configurable number of price bins (default 30) spanning the high-to-low range of the lookback window. For each bin, the engine calculates the proportional contribution of each historical bar's volume using an overlap method:

Each bar contributes volume proportionally to the fraction of its high-to-low range that overlaps with each bin. A bar spanning multiple bins splits its volume across all overlapping bins by the fraction of overlap — preventing the unrealistic "winner takes all" binning used by simpler implementations.

This overlap-proportional distribution produces a smooth, accurate volume histogram that closely mirrors the actual traded price distribution.

[b]POC Detection[/b]

After computing the full distribution array, the engine scans for the bin with the highest accumulated volume. This bin's midpoint is the Point of Control — the price level where the most volume traded during the lookback window. The POC is highlighted as the brightest horizontal line in the profile.

[b]Value Area (70%) Calculation[/b]

Starting from the POC bin, the Value Area algorithm expands outward — one bin up and one bin down in alternating steps — absorbing bins into the Value Area until their cumulative volume equals or exceeds 70% of total profile volume. The result is a price range (Value Area High and Value Area Low) that contains the bulk of institutional activity. This range is where the majority of price acceptance occurred and serves as a reference for mean-reversion and breakout trading contexts.

[b]Live Rendering at barstate.islast[/b]

The entire profile is rebuilt from scratch on each bar's final tick using the delete-before-create pattern: all existing profile boxes are deleted before redrawing. This ensures that the profile is always current without leaving ghost boxes on the chart. Each bin is drawn as a horizontal box scaled to its volume proportion relative to the maximum bin, using a gradient colour from muted (low volume) to bright teal (near-POC), with the POC bin rendered in gold.

[b]Profile Elements[/b]

- [b]Volume bins:[/b] Horizontal boxes scaled by proportional volume, coloured by intensity
- [b]POC line:[/b] Gold horizontal line at the maximum-volume price level
- [b]Value Area High / Low lines:[/b] Teal dashed lines marking the 70% value area boundary
- [b]Volume Delta overlay:[/b] For each bar, buy volume (close > open) and sell volume (close < open) are tracked separately and displayed as a delta bar, showing the directional pressure within the profile window

[b]Inputs Reference[/b]

- Profile Length (100) — number of bars included in the lookback window
- Number of Bins (30) — vertical resolution of the price distribution
- Profile Width (40 bars) — horizontal width of the rendered boxes
- Show POC Line — toggles the gold POC highlight
- Show Value Area — toggles the 70% Value Area High/Low lines
- Show Volume Delta — toggles the delta bar visualisation
- Profile Offset (0) — shifts the profile left or right from the current bar
- Theme: Dark / Light / Auto

[b]How to Use[/b]

1. Add to any chart. The profile automatically spans the last N bars (configurable lookback).
2. The POC (gold line) is the most significant reference level — price tends to be attracted back to the POC when trading away from it.
3. The Value Area High and Low act as potential support/resistance zones. Breakouts above VAH with volume expansion are bullish continuation signals; breakouts below VAL signal bearish continuation.
4. If price is trading within the Value Area, expect range behaviour with mean reversion toward the POC.
5. Volume Delta bars help identify whether the current session's participation is predominantly buying or selling within the profiled window.

[b]Non-Repainting Design[/b]

The profile always renders at barstate.islast using only confirmed historical bar data. No forward-looking data is accessed. The POC and Value Area lines represent historical distribution within the defined lookback and do not shift on historical bars.

[b]Limitations[/b]

- Volume profiles are most meaningful on instruments with genuine, transparent volume (equities, futures, crypto on-chain exchanges). Forex tick volume is a proxy and may produce less reliable distribution shapes.
- Increasing the number of bins significantly increases the number of box objects drawn, approaching TradingView's per-indicator box limit on very long lookbacks.
- The profile always represents the most recent N bars — it does not anchor to specific sessions or swing levels. Session-anchored profiles require different logic.
- Very low-volume bins at the extremes are accurate but may appear invisible at small chart scales.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. Volume profile is a descriptive market microstructure tool and does not predict future price movement. Always use proper risk management in conjunction with your own analysis.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Vortex Volume Spectrum [JOAT]", shorttitle="VVS [JOAT]", overlay=true,
          max_boxes_count=500, max_lines_count=100, max_labels_count=50)

// ─── INPUTS ──────────────────────────────────────────────────────────
var GRP_P = "Profile Settings"
var GRP_V = "Visual"

i_swingLen  = input.int  (10,  "Swing Detection Length",  group=GRP_P, minval=3, maxval=50)
i_bins      = input.int  (20,  "Price Bins",              group=GRP_P, minval=8, maxval=40)
i_maxProf   = input.int  (3,   "Max Historical Profiles", group=GRP_P, minval=1, maxval=6)
i_barWidth  = input.int  (25,  "Max Profile Width (bars)",group=GRP_P, minval=8, maxval=60)
i_showVA    = input.bool (true,"Show Value Area (70%)",   group=GRP_P)
i_showPOC   = input.bool (true,"Show POC Line",           group=GRP_P)
i_showVWAP  = input.bool (true,"Show Swing VWAP",         group=GRP_P)
i_showDelta = input.bool (true,"Show Delta Labels",        group=GRP_P)
i_showDash  = input.bool (true,"Show Dashboard",           group=GRP_P)
i_theme     = input.string("Auto","Theme",["Dark","Light","Auto"], group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
_isDark = i_theme == "Auto" ? color.r(chart.bg_color) < 128 : i_theme == "Dark"
C_BULL  = color.rgb(0, 245, 212)
C_BEAR  = color.rgb(255, 68, 102)
C_GOLD  = color.rgb(255, 215, 0)
C_POC   = color.rgb(255, 200, 0)
C_VA    = color.rgb(41, 98, 255)
C_VWAP  = color.rgb(200, 130, 255)
C_SLATE = color.rgb(96, 112, 128)
C_PANEL = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)
C_TXT   = _isDark ? color.white : color.black

// ─── HELPERS ─────────────────────────────────────────────────────────
safeDiv(float n, float d) =>
    d != 0.0 and not na(d) ? n / d : 0.0

// Distribute one candle's volume across bins
f_distrib(float cH, float cL, float cVol, float bot, float step,
          int bins, array<float> volArr, array<float> buyArr, bool isBuy) =>
    cRange = math.max(cH - cL, syminfo.mintick)
    for k = 0 to bins - 1
        binL    = bot + k * step
        binH    = binL + step
        overlap = math.max(0.0, math.min(cH, binH) - math.max(cL, binL))
        if overlap > 0.0
            portion = overlap / cRange
            vol     = cVol * portion
            volArr.set(k, volArr.get(k) + vol)
            if isBuy
                buyArr.set(k, buyArr.get(k) + vol)

// Find POC bin index
f_poc(array<float> v) =>
    mx  = array.max(v)
    idx = 0
    for k = 0 to array.size(v) - 1
        if v.get(k) >= mx
            idx := k
            break
    idx

// Value Area: expand from POC until 70% captured
f_valueArea(array<float> v, int pocBin, float bot, float step) =>
    bins   = array.size(v)
    total  = array.sum(v)
    target = total * 0.70
    acc    = v.get(pocBin)
    up     = pocBin
    dn     = pocBin
    while acc < target and (up < bins - 1 or dn > 0)
        upV = up + 1 < bins ? v.get(up + 1) : 0.0
        dnV = dn - 1 >= 0  ? v.get(dn - 1) : 0.0
        if upV >= dnV and up + 1 < bins
            up  += 1
            acc += upV
        else if dn - 1 >= 0
            dn  -= 1
            acc += dnV
        else
            break
    [bot + (up + 1) * step, bot + dn * step]  // [vaHigh, vaLow]

// Build profile from historical bars (lookback from current bar)
f_buildAndDraw(int swingLen, int rightEdge, bool isBullSwing) =>
    sLen  = math.min(swingLen, 300)
    sHigh = float(na)
    sLow  = float(na)
    sumPV = 0.0
    sumV  = 0.0
    buyV  = 0.0
    sellV = 0.0
    for k = 0 to sLen - 1
        h = high[k]
        l = low[k]
        v = volume[k]
        p = (h + l + close[k]) / 3.0
        sHigh := na(sHigh) ? h : math.max(sHigh, h)
        sLow  := na(sLow)  ? l : math.min(sLow,  l)
        sumPV += p * v
        sumV  += v
        if close[k] >= open[k]
            buyV  += v
        else
            sellV += v
    if na(sHigh) or na(sLow) or sHigh <= sLow
        [float(na), float(na), float(na), float(na), float(na)]
    else
        bins   = i_bins
        step   = (sHigh - sLow) / bins
        volArr = array.new_float(bins, 0.0)
        buyArr = array.new_float(bins, 0.0)
        for k = 0 to sLen - 1
            f_distrib(high[k], low[k], volume[k], sLow, step, bins, volArr, buyArr, close[k] >= open[k])
        pocBin = f_poc(volArr)
        pocPx  = sLow + (pocBin + 0.5) * step
        [vaHi, vaLo] = f_valueArea(volArr, pocBin, sLow, step)
        vwapVal = safeDiv(sumPV, sumV)
        deltaV  = safeDiv(buyV - sellV, math.max(buyV + sellV, 1.0)) * 100.0
        maxVol  = math.max(array.max(volArr), 1.0)
        // Draw profile bars
        for k = 0 to bins - 1
            binL    = sLow + k * step
            binH    = binL + step
            binVol  = volArr.get(k)
            barW    = math.round(safeDiv(binVol, maxVol) * i_barWidth)
            barW   := math.max(barW, 1)
            isPOC   = k == pocBin
            isVA    = binH >= vaLo and binL <= vaHi and i_showVA
            c       = isPOC ? C_POC : isVA ? C_VA : (isBullSwing ? C_BULL : C_BEAR)
            transp  = isPOC ? 30 : isVA ? 65 : 80
            box.new(rightEdge, binH, rightEdge + barW, binL,
                bgcolor=color.new(c, transp), border_color=na)
        // POC line
        if i_showPOC
            pocLine = line.new(rightEdge, pocPx, rightEdge + i_barWidth + 5, pocPx,
                      color=color.new(C_POC, 20), width=1, style=line.style_dashed)
        // Delta label
        if i_showDelta
            deltaStr = (deltaV >= 0 ? "+" : "") + str.tostring(math.round(deltaV, 1)) + "%"
            label.new(rightEdge + i_barWidth + 2, pocPx,
                "POC\n" + deltaStr,
                color=color.new(deltaV >= 0 ? C_BULL : C_BEAR, 50),
                textcolor=color.white, style=label.style_label_left, size=size.tiny)
        [pocPx, vaHi, vaLo, vwapVal, deltaV]

// ─── SWING TRACKING ──────────────────────────────────────────────────
ph = ta.pivothigh(high, i_swingLen, i_swingLen)
pl = ta.pivotlow (low,  i_swingLen, i_swingLen)

WARMUP  = i_swingLen * 3
isReady = bar_index >= WARMUP

var int   swingDir       = 0
var int   swingStart     = na
var int   profCount      = 0
var float lastPOC        = na
var float lastVAHi       = na
var float lastVALo       = na
var float lastVWAP       = na
var float lastDelta      = na

// On confirmed pivot, flip direction and build profile
if not na(ph) and isReady and barstate.isconfirmed
    if swingDir != -1
        if not na(swingStart)
            lookback = bar_index - i_swingLen - swingStart
            if lookback > 3 and profCount < i_maxProf
                [poc, vaH, vaL, vwp, dlt] = f_buildAndDraw(lookback, bar_index - i_swingLen, true)
                if not na(poc)
                    lastPOC   := poc
                    lastVAHi  := vaH
                    lastVALo  := vaL
                    lastVWAP  := vwp
                    lastDelta := dlt
                    profCount += 1
        swingDir   := -1
        swingStart := bar_index - i_swingLen

if not na(pl) and isReady and barstate.isconfirmed
    if swingDir != 1
        if not na(swingStart)
            lookback = bar_index - i_swingLen - swingStart
            if lookback > 3 and profCount < i_maxProf
                [poc, vaH, vaL, vwp, dlt] = f_buildAndDraw(lookback, bar_index - i_swingLen, false)
                if not na(poc)
                    lastPOC   := poc
                    lastVAHi  := vaH
                    lastVALo  := vaL
                    lastVWAP  := vwp
                    lastDelta := dlt
                    profCount += 1
        swingDir   := 1
        swingStart := bar_index - i_swingLen

// ─── REAL-TIME PROFILE (rebuilt every bar at barstate.islast) ─────────
var array<box>  rtBoxes = array.new<box>()
var line        rtPOCLine = na
var line        rtVWAPLine = na

if barstate.islast and not na(swingStart) and isReady
    // Delete previous RT objects
    for b in rtBoxes
        box.delete(b)
    rtBoxes.clear()
    if not na(rtPOCLine)
        line.delete(rtPOCLine)
    if not na(rtVWAPLine)
        line.delete(rtVWAPLine)

    sLen  = math.min(bar_index - swingStart + 1, 300)
    sHigh = float(na)
    sLow  = float(na)
    sumPV = 0.0
    sumV  = 0.0
    buyVr = 0.0
    sellVr= 0.0
    for k = 0 to sLen - 1
        h = high[k]
        l = low[k]
        v = volume[k]
        p = (h + l + close[k]) / 3.0
        sHigh := na(sHigh) ? h : math.max(sHigh, h)
        sLow  := na(sLow)  ? l : math.min(sLow,  l)
        sumPV += p * v
        sumV  += v
        if close[k] >= open[k]
            buyVr  += v
        else
            sellVr += v

    if not na(sHigh) and not na(sLow) and sHigh > sLow
        bins   = i_bins
        step   = (sHigh - sLow) / bins
        volArr = array.new_float(bins, 0.0)
        buyArr = array.new_float(bins, 0.0)
        for k = 0 to sLen - 1
            f_distrib(high[k], low[k], volume[k], sLow, step, bins, volArr, buyArr, close[k] >= open[k])

        pocBin  = f_poc(volArr)
        pocPx   = sLow + (pocBin + 0.5) * step
        [vaHi, vaLo] = f_valueArea(volArr, pocBin, sLow, step)
        vwapRT  = safeDiv(sumPV, sumV)
        deltaRT = safeDiv(buyVr - sellVr, math.max(buyVr + sellVr, 1.0)) * 100.0
        maxVol  = math.max(array.max(volArr), 1.0)
        rightEdge = bar_index + 2

        for k = 0 to bins - 1
            binL   = sLow + k * step
            binH   = binL + step
            binVol = volArr.get(k)
            barW   = math.round(safeDiv(binVol, maxVol) * i_barWidth)
            barW  := math.max(barW, 1)
            isPOC  = k == pocBin
            isVA   = binH >= vaLo and binL <= vaHi and i_showVA
            c      = isPOC ? C_POC : isVA ? C_VA : (swingDir == 1 ? C_BULL : C_BEAR)
            transp = isPOC ? 25 : isVA ? 60 : 78
            b = box.new(rightEdge, binH, rightEdge + barW, binL,
                bgcolor=color.new(c, transp), border_color=na)
            rtBoxes.push(b)

        if i_showPOC
            rtPOCLine := line.new(rightEdge, pocPx, rightEdge + i_barWidth + 8, pocPx,
                         color=color.new(C_POC, 15), width=2, style=line.style_dashed)
        if i_showVWAP and not na(vwapRT)
            rtVWAPLine := line.new(swingStart, vwapRT, bar_index, vwapRT,
                          color=color.new(C_VWAP, 25), width=1, style=line.style_dotted)
        // Update live stats
        lastPOC   := pocPx
        lastVAHi  := vaHi
        lastVALo  := vaLo
        lastVWAP  := vwapRT
        lastDelta := deltaRT

// ─── SWING VWAP PLOT (historical) ────────────────────────────────────
plot(i_showVWAP ? lastVWAP : na, "Swing VWAP", color=color.new(C_VWAP, 30),
     linewidth=1, style=plot.style_stepline)

// ─── ALERTS ──────────────────────────────────────────────────────────
bool touchedVA = not na(lastVAHi) and close <= lastVAHi and close >= lastVALo
alertcondition(touchedVA, "VVS Value Area Touch [JOAT]",
     "Vortex Volume: Price entered Value Area")

// ─── DASHBOARD ───────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 7,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 60))

if i_showDash and barstate.islast
    deltaClr  = lastDelta >= 0 ? C_BULL : C_BEAR
    dirStr    = swingDir == 1 ? "UP SWING" : swingDir == -1 ? "DOWN SWING" : "NEUTRAL"
    dirClr    = swingDir == 1 ? C_BULL : swingDir == -1 ? C_BEAR : C_SLATE

    table.cell(dash, 0, 0, "VVS [JOAT]",
         bgcolor=color.new(C_VA, 30), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "JackOfAllTrades",
         bgcolor=color.new(C_VA, 30), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 1, "Swing Dir",  text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 1, dirStr,       text_color=dirClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 2, "POC",        text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 2, na(lastPOC) ? "N/A" : str.tostring(math.round(lastPOC, 4)),
         text_color=C_POC, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 3, "VA High",    text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 3, na(lastVAHi) ? "N/A" : str.tostring(math.round(lastVAHi, 4)),
         text_color=C_VA, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 4, "VA Low",     text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 4, na(lastVALo) ? "N/A" : str.tostring(math.round(lastVALo, 4)),
         text_color=C_VA, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 5, "VWAP",       text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 5, na(lastVWAP) ? "N/A" : str.tostring(math.round(lastVWAP, 4)),
         text_color=C_VWAP, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 6, "Delta",      text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 6, na(lastDelta) ? "N/A" : (lastDelta >= 0 ? "+" : "") + str.tostring(math.round(lastDelta, 1)) + "%",
         text_color=deltaClr, text_size=size.small, bgcolor=C_PANEL)
````
