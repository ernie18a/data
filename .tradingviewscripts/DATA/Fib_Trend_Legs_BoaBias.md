<!-- tradingview-pine-id: PUB;aa2c877b772144faa668fb5f72d6cd99 -->
<!-- tradingviewscripts-format: 1 -->
# Fib Trend & Legs (BoaBias)

Source: https://www.tradingview.com/script/daSAHtZp-Fib-Trend-Legs-BoaBias/

## Description

█ OVERVIEW

Fib Trend & Legs (BoaBias) draws Fibonacci structure on two nested scales at once: a parent fib across the full market-structure trend cycle (trend-up ↔ trend-down), and child fibs on the BOS / CHoCH swing legs inside that trend. Optional golden / deep zones plus a CT-fade Edge panel (ALMA overheat · MTF EMA overheat · fib-anchored VWAP · golden proximity) with matching overlays. Structural context for discretionary work and alert workflows — not a black-box signal service.

█ WHY UNIQUE

Most Fib tools lock to a single hand-picked or last-swing range. This map keeps parent trend and child legs alive together: the parent tracks the whole structure trend cycle while child legs lock on each confirmed BOS/CHoCH segment (plus an optional forming leg). The Edge panel is a CT-fade confluence over that map: ALMA run overheat and MTF EMA above/below overheat (same lengths as BoaBias public EMA/ALMA), proximity to the parent golden zone, and a VWAP anchored at the parent fib start — so stretch + pullback context sit on one overlay instead of juggling three scripts.

█ HOW TO USE

[*]First use: If the indicator appears in the wrong scale (squashed or fullscreen), right-click the indicator → Pin to scale → Pin to right scale.
[*]Leave Show Parent Fib and Show Child Fibs on; tune Pivot Length so swings match your timeframe (higher length = fewer, larger structure events).
[*]Watch Golden Zone / Deep Zone on the parent for pullback context; enable the same zones on child legs when you trade inside-leg retracements.
[*]Use Pattern Edge (top-right) for parent-fib CT-fade confluence and Child Edge (bottom-left) for the active leg — high when pullback-side ALMA/EMA is stretched into golden near fib VWAP. Not a standalone entry trigger.
[*]Alerts: Chart → Create alert → this indicator → choose a condition (Golden/Deep entry, Strong Edge, Cross Fib VWAP, Break 0%, Full Retrace, Trend Up/Down, BOS, Upsweep/Dnsweep). Prefer Once per bar close for cleaner automation.

█ HOW IT WORKS

[*]Market structure: Pivot highs/lows feed a trend state. Trend flips (and BOS / CHoCH / optional liquidity sweeps) define when ranges update. Algorithm mode: Extreme Points or Adjusted Points.
[*]Parent fib (Trend): Anchored to the full active trend cycle — from the cycle origin to the opposing extreme — with retracements, optional extensions, and zone fills between configurable ratios (defaults emphasize 61.8–78.6 golden and 78.6–88.6 deep).
[*]Child fibs (Legs): Each leg = protective origin (CHoCH / last protect wick) → running extreme (ms.main wick). Locked on BOS with those bars frozen. L1 = newest locked, L2 = previous, Lf = forming. Optional H/L anchor marks show the two wicks. Parent trend flip clears child history.
[*]Edge layer (CT fade): Two panels — Pattern (parent fib) and Child (active leg). Each scores golden proximity (≤25) + ALMA pullback CT (≤25) + EMA pullback CT (≤25) + fib-start VWAP (≤25). ALMA/EMA CT use the chart timeframe only (panel shows e.g. ALMA 1D). For a bull fib, CT scores short / below-EMA stretch; bear fib scores the opposite. Optional plots: chart-TF ALMA SuperTrend, enabled EMAs, Pattern + Child fib VWAPs.
[*]Sweep markers: Optional “x” markers when structure detects upsweep / dnsweep liquidity grabs (style group for color, size, max count).

█ CTA

[*]More BoaBias public Scripts: TradingView → [Goldfinch_song](https://www.tradingview.com/u/Goldfinch_song/) → Scripts.
[*]Ideas that use this stack: profile → Ideas tab.

█ LIMITATIONS

[*]Pivot-based structure lags until pivots confirm; forming parent/child ranges can update until the next structure event.
[*]Fib levels and zones are structural maps, not guaranteed support/resistance or trade signals.
[*]Edge score is a confluence helper on the loaded history — descriptive, not predictive.
[*]Heavy child history + many levels can hit drawing limits — lower Max Completed Child Legs or disable unused levels.
[*]Educational / research overlay. Not financial advice.

Pine Script v6. License: [MPL-2.0](https://www.mozilla.org/MPL/2.0/).

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Goldfinch_song
// Fib Trend & Legs (BoaBias) — parent trend-cycle fibs + child BOS/CHoCH leg fibs + CT-fade Edge (ALMA OH · MTF EMA OH · fib-anchored VWAP · golden prox).

//@version=6
indicator("Fib Trend & Legs (BoaBias)", "FibLegs", true,
     scale = scale.right,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500,
     max_bars_back = 5000)

// ══════════════════════════════════════════════════════════════════
//                              INPUTS
// ══════════════════════════════════════════════════════════════════

groupMS = "Market Structure"
i_mslen      = input.int(5, "Pivot Length", minval = 2, maxval = 50, group = groupMS, tooltip = "Bars each side for pivothigh / pivotlow")
i_msmode     = input.string("Adjusted Points", "Algorithmic Logic", options = ["Extreme Points", "Adjusted Points"], group = groupMS)
i_buildsweep = input.bool(true, "Build Sweep (x)", group = groupMS, tooltip = "Liquidity sweep detection on structure levels")
i_showMsLbl  = input.bool(true, "Show MS Event Markers", group = groupMS)
i_swingCap   = input.int(200, "Swing Lookback Cap", minval = 20, maxval = 2000, group = groupMS, tooltip = "Caps swing search depth for speed on long histories")

groupSweep = "Sweep (x) Style"
i_showSweep  = input.bool(true, "Show Sweep Markers", group = groupSweep)
i_sweepTxt   = input.string("x", "Sweep Text", group = groupSweep)
i_sweepUpC   = input.color(#26a69a, "Upsweep Color", group = groupSweep)
i_sweepDnC   = input.color(#f23645, "Dnsweep Color", group = groupSweep)
i_sweepBg    = input.color(color.new(#ffffff, 100), "Marker Background", group = groupSweep)
i_sweepSize  = input.string("Small", "Marker Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupSweep)
i_sweepMax   = input.int(40, "Max Sweep Markers", minval = 5, maxval = 200, group = groupSweep)

groupParent = "Parent Fib (Trend Cycle)"
i_showParent = input.bool(true, "Show Parent Fib", group = groupParent)
i_extend     = input.int(30, "Right Projection", minval = 5, maxval = 200, group = groupParent)

groupChild = "Child Fib (Legs)"
i_showChild    = input.bool(true, "Show Child Fibs", group = groupChild)
i_maxChild     = input.int(5, "Max Completed Child Legs", minval = 1, maxval = 5, group = groupChild, tooltip = "L1 = newest BOS-locked leg, L2 = previous. Lf = forming leg (not locked yet).")
i_childFull    = input.bool(true, "Show Full Child Levels", group = groupChild, tooltip = "Off = compact 0/50/61.8/78.6/100 only")
i_childExtend  = input.int(18, "Child Right Projection", minval = 3, maxval = 100, group = groupChild)
i_childGolden  = input.bool(true, "Golden Zone on Child Legs", group = groupChild)
i_childDeep    = input.bool(false, "Deep Zone on Child Legs", group = groupChild)
i_showChildAnchors = input.bool(true, "Show Child Anchor Marks", group = groupChild, tooltip = "Marks H/L wicks that define each child fib (origin protect ↔ running extreme)")
i_cChildGoldFill = input.color(color.new(#c9a227, 88), "Child Golden Fill", inline = "CGc", group = groupChild)
i_cChildGoldBord = input.color(#c9a227, "Border", inline = "CGc", group = groupChild)
i_cChildDeepFill = input.color(color.new(#8d6e63, 90), "Child Deep Fill", inline = "CDc", group = groupChild)
i_cChildDeepBord = input.color(#bf360c, "Border", inline = "CDc", group = groupChild)

groupLevels = "Levels"
i_showLabels = input.bool(true, "Price Labels", group = groupLevels)
i_useTrendEnds = input.bool(true, "0%/100% Use Trend Color", group = groupLevels, tooltip = "When on, 0% and 100% lines follow bullish/bearish trend color instead of their level color pickers.")

// Retracement levels: enable + ratio + color
i_show0   = input.bool(true, "0%", inline = "L0", group = groupLevels)
i_r0      = input.float(0.0, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L0", group = groupLevels)
i_c0      = input.color(#00e676, "", inline = "L0", group = groupLevels)
i_show236 = input.bool(false, "23.6%", inline = "L236", group = groupLevels)
i_r236    = input.float(0.236, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L236", group = groupLevels)
i_c236    = input.color(#546e7a, "", inline = "L236", group = groupLevels)
i_show382 = input.bool(false, "38.2%", inline = "L382", group = groupLevels)
i_r382    = input.float(0.382, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L382", group = groupLevels)
i_c382    = input.color(#546e7a, "", inline = "L382", group = groupLevels)
i_show50  = input.bool(true, "50%", inline = "L50", group = groupLevels)
i_r50     = input.float(0.5, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L50", group = groupLevels)
i_c50     = input.color(#78909c, "", inline = "L50", group = groupLevels)
i_show618 = input.bool(true, "61.8%", inline = "L618", group = groupLevels)
i_r618    = input.float(0.618, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L618", group = groupLevels)
i_c618    = input.color(#ffd740, "", inline = "L618", group = groupLevels)
i_show786 = input.bool(false, "78.6%", inline = "L786", group = groupLevels)
i_r786    = input.float(0.786, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L786", group = groupLevels)
i_c786    = input.color(#ffd740, "", inline = "L786", group = groupLevels)
i_show886 = input.bool(false, "88.6%", inline = "L886", group = groupLevels)
i_r886    = input.float(0.886, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L886", group = groupLevels)
i_c886    = input.color(#ff6d00, "", inline = "L886", group = groupLevels)
i_show100 = input.bool(true, "100%", inline = "L100", group = groupLevels)
i_r100    = input.float(1.0, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "L100", group = groupLevels)
i_c100    = input.color(#ff1744, "", inline = "L100", group = groupLevels)

// Extensions: user enters 1.272 / 1.618 style (beyond 0%)
i_showExt1 = input.bool(true, "Ext 1", inline = "E1", group = groupLevels, tooltip = "Extension ratio > 1.0 (e.g. 1.272). Mapped as calc ratio = 1 − value.")
i_rExt1    = input.float(1.272, "", minval = 0.0, maxval = 5.0, step = 0.001, inline = "E1", group = groupLevels)
i_cExt1    = input.color(#26a69a, "", inline = "E1", group = groupLevels)
i_showExt2 = input.bool(true, "Ext 2", inline = "E2", group = groupLevels)
i_rExt2    = input.float(1.618, "", minval = 0.0, maxval = 5.0, step = 0.001, inline = "E2", group = groupLevels)
i_cExt2    = input.color(#26a69a, "", inline = "E2", group = groupLevels)

// Zones: ratios + fill/border colors
i_showGolden = input.bool(true, "Golden Zone", inline = "GZ", group = groupLevels)
i_rGoldA     = input.float(0.618, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "GZ", group = groupLevels)
i_rGoldB     = input.float(0.786, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "GZ", group = groupLevels)
i_cGoldFill  = input.color(color.new(#8d6e63, 88), "Fill", inline = "GZc", group = groupLevels)
i_cGoldBord  = input.color(#ffccbc, "Border", inline = "GZc", group = groupLevels)
i_showDeep   = input.bool(false, "Deep Zone", inline = "DZ", group = groupLevels)
i_rDeepA     = input.float(0.786, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "DZ", group = groupLevels)
i_rDeepB     = input.float(0.886, "", minval = -2.0, maxval = 3.0, step = 0.001, inline = "DZ", group = groupLevels)
i_cDeepFill  = input.color(color.new(#bf360c, 90), "Fill", inline = "DZc", group = groupLevels)
i_cDeepBord  = input.color(#ff6d00, "Border", inline = "DZc", group = groupLevels)

groupEdge = "Edge Analysis (CT Fade)"
i_showEdge  = input.bool(true, "Pattern Edge Panel", group = groupEdge)
i_showChildEdge = input.bool(true, "Child Edge Panel", group = groupEdge)
i_showVolB  = input.bool(true, "ATR Volatility Band", group = groupEdge)
i_heatmap   = input.bool(false, "Proximity Heatmap", group = groupEdge, tooltip = "When on, lines farther from price become more transparent (see Style → Heatmap transp range)")
i_atrLen    = input.int(14, "ATR Length", minval = 5, maxval = 50, group = groupEdge)
i_ohMult    = input.float(1.0, "Overheat Threshold (Cur/Avg)", minval = 0.5, maxval = 3.0, step = 0.1, group = groupEdge, tooltip = "Cur > threshold × Avg counts as overheat for ALMA/EMA CT-fade score")
i_panelSize = input.string("Large", "Dashboard Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupEdge)
i_patternPos = input.string("Top Right", "Pattern Edge Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupEdge)
i_childPos = input.string("Middle Right", "Child Edge Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupEdge)
i_showAlmaPlot = input.bool(true, "Draw ALMA SuperTrend (chart TF)", group = groupEdge)
i_showEmaPlot  = input.bool(true, "Draw Enabled EMAs", group = groupEdge)
i_showVwapPlot = input.bool(true, "Draw Fib-Anchored VWAP", group = groupEdge)

groupEdgeAlma = "Edge — ALMA (OH)"
i_alma15 = input.bool(true, "Use 15m", group = groupEdgeAlma, tooltip = "ALMA/EMA Edge CT score uses the chart timeframe only (see panel label). Other TF packs still compute for mapping/plots.")
i_alma1h = input.bool(true, "Use 1H", group = groupEdgeAlma)
i_alma4h = input.bool(true, "Use 4H", group = groupEdgeAlma)
i_alma1d = input.bool(true, "Use 1D", group = groupEdgeAlma)
i_alma3d = input.bool(true, "Use 3D", group = groupEdgeAlma)
i_alma1w = input.bool(true, "Use 1W", group = groupEdgeAlma)
i_almaWin = input.int(50, "ALMA Avg Window", minval = 5, maxval = 500, group = groupEdgeAlma)
// Defaults match BoaBias MTF ALMA SD SuperTrend public
i_almaFactor = input.float(1.0, "Factor", step = 0.05, group = groupEdgeAlma)
i_almaSdLen  = input.int(2, "SD Length", minval = 1, group = groupEdgeAlma)
i_almaLen    = input.int(3, "ALMA Length", minval = 1, group = groupEdgeAlma)
i_almaSig    = input.float(2.0, "ALMA Sigma", group = groupEdgeAlma)
i_almaOff    = input.float(1.0, "ALMA Offset", step = 0.1, group = groupEdgeAlma)
i_almaUpC    = input.color(color.rgb(31, 211, 37), "ALMA Long Color", group = groupEdgeAlma)
i_almaDnC    = input.color(color.rgb(188, 8, 219), "ALMA Short Color", group = groupEdgeAlma)

groupEdgeEma = "Edge — EMA (OH)"
i_ema15 = input.bool(true, "Use 15m", group = groupEdgeEma)
i_ema1h = input.bool(true, "Use 1H", group = groupEdgeEma)
i_ema4h = input.bool(true, "Use 4H", group = groupEdgeEma)
i_ema1d = input.bool(true, "Use 1D", group = groupEdgeEma)
i_ema3d = input.bool(true, "Use 3D", group = groupEdgeEma)
i_ema1w = input.bool(true, "Use 1W", group = groupEdgeEma)
i_emaLen15 = input.int(16, "15m Length", minval = 1, group = groupEdgeEma)
i_emaLen1h = input.int(24, "1H Length", minval = 1, group = groupEdgeEma)
i_emaLen4h = input.int(42, "4H Length", minval = 1, group = groupEdgeEma)
i_emaLen1d = input.int(29, "1D Length", minval = 1, group = groupEdgeEma)
i_emaLen3d = input.int(30, "3D Length", minval = 1, group = groupEdgeEma)
i_emaLen1w = input.int(52, "1W Length", minval = 1, group = groupEdgeEma)
i_emaWin   = input.int(200, "EMA Avg Window", minval = 5, maxval = 1000, group = groupEdgeEma)
i_emaC15 = input.color(#ffeb3b, "15m EMA Color", group = groupEdgeEma)
i_emaC1h = input.color(#f44336, "1H EMA Color", group = groupEdgeEma)
i_emaC4h = input.color(#4caf50, "4H EMA Color", group = groupEdgeEma)
i_emaC1d = input.color(#2196f3, "1D EMA Color", group = groupEdgeEma)
i_emaC3d = input.color(#9c27b0, "3D EMA Color", group = groupEdgeEma)
i_emaC1w = input.color(#ff9800, "1W EMA Color", group = groupEdgeEma)

groupStyle = "Style"
i_bullC     = input.color(#00e676, "Bullish / Trend Up", group = groupStyle)
i_bearC     = input.color(#ff1744, "Bearish / Trend Down", group = groupStyle)
i_volBC     = input.color(color.new(#000000, 100), "Volatility Band Fill", group = groupStyle)
i_volBordC  = input.color(color.new(#000000, 100), "Volatility Band Border", group = groupStyle)
i_lblTxtC   = input.color(#000000, "Label Text Color", group = groupStyle)
i_lineW     = input.int(1, "Line Width", minval = 1, maxval = 3, group = groupStyle)
i_lineTransp = input.int(0, "Level Line Transparency", minval = 0, maxval = 90, group = groupStyle, tooltip = "Base transparency when Proximity Heatmap is off (0 = solid)")
i_heatNearTransp = input.int(5, "Heatmap Near Transp", minval = 0, maxval = 90, group = groupStyle, tooltip = "Transparency for levels closest to price when heatmap is on")
i_heatFarTransp = input.int(40, "Heatmap Far Transp", minval = 0, maxval = 95, group = groupStyle, tooltip = "Transparency for levels farthest from price when heatmap is on")
i_lblTransp = input.int(55, "Level Label Fill Transp", minval = 0, maxval = 95, group = groupStyle)
i_lblSize = input.string("Small", "Level Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupStyle)

f_lbl_size() =>
    switch i_lblSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

// ══════════════════════════════════════════════════════════════════
//                               TYPES
// ══════════════════════════════════════════════════════════════════

type structure
    int    zn
    float  zz
    float  bos
    float  choch
    int    loc
    int    temp
    int    trend
    int    start
    float  main
    int    xloc
    bool   upsweep
    bool   dnsweep
    string txt = na

type FibLeg
    float h
    float l
    int   x1
    int   xH
    int   xL
    bool  bull
    bool  active

type SweepMark
    int   x
    float y
    bool  isUp

// ══════════════════════════════════════════════════════════════════
//                     MARKET STRUCTURE ENGINE
// ══════════════════════════════════════════════════════════════════

method findSwing(structure ms, bool use_max) =>
    float minV = 99999999.0
    float maxV = 0.0
    int idx = 0
    int span = math.max(bar_index - ms.loc, 0)
    int last = math.min(math.max(span - 1, 0), i_swingCap - 1)
    for i = 0 to last
        if use_max
            maxV := math.max(high[i], maxV)
            minV := maxV == high[i] ? low[i] : minV
            idx := maxV == high[i] ? i : idx
        else
            minV := math.min(low[i], minV)
            maxV := minV == low[i] ? high[i] : maxV
            idx := minV == low[i] ? i : idx
    idx

msStructure() =>
    var structure ms = structure.new(start = 0)
    bool crossup = false
    bool crossdn = false
    var float up = na
    var float dn = na
    float ph = ta.pivothigh(high, i_mslen, i_mslen)
    float pl = ta.pivotlow(low, i_mslen, i_mslen)
    var int[] phn = array.new_int(1, na)
    var float[] php = array.new_float(1, na)
    var int[] pln = array.new_int(1, na)
    var float[] plp = array.new_float(1, na)

    if not na(ph)
        phn.unshift(bar_index[i_mslen])
        php.unshift(high[i_mslen])
    if not na(pl)
        pln.unshift(bar_index[i_mslen])
        plp.unshift(low[i_mslen])
    if php.size() > 0 and high > php.get(0)
        php.clear()
        phn.clear()
    if plp.size() > 0 and low < plp.get(0)
        plp.clear()
        pln.clear()

    if na(up)
        up := high
    if na(dn)
        dn := low
    if high > up
        up := high
        dn := low
        crossup := true
    if low < dn
        up := high
        dn := low
        crossdn := true

    if ms.start == 0
        ms := structure.new(bar_index, na, high, low, bar_index, bar_index, 0, 1, na, bar_index)

    ms.upsweep := false
    ms.dnsweep := false
    ms.txt := na

    if ms.start == 1
        if i_buildsweep and low <= ms.choch and close >= ms.choch
            ms.dnsweep := true
            ms.choch := low
            ms.xloc := bar_index
        else if i_buildsweep and high >= ms.bos and close <= ms.bos
            ms.upsweep := true
            ms.bos := high
            ms.xloc := bar_index
        else if close <= ms.choch
            ms.txt := "choch"
            ms.trend := -1
            ms.choch := ms.bos
            ms.bos := na
            ms.start := 2
            ms.loc := bar_index
            ms.main := low
            ms.temp := ms.loc
            ms.xloc := bar_index
        else if close >= ms.bos
            ms.txt := "choch"
            ms.trend := 1
            ms.bos := na
            ms.start := 2
            ms.loc := bar_index
            ms.main := high
            ms.temp := ms.loc
            ms.xloc := bar_index

    if ms.start == 2
        if ms.trend == -1
            if low <= ms.main
                ms.main := low
                ms.temp := bar_index
            if bar_index % i_mslen * 2 == 0
                if not na(ms.bos) and i_msmode == "Adjusted Points" and php.size() > 0
                    if php.get(0) < ms.choch
                        ms.choch := php.get(0)
                        ms.loc := phn.get(0)
                        ms.xloc := phn.get(0)
                        ms.temp := phn.get(0)
            if na(ms.bos)
                if crossup and close > open and close[1] > open[1]
                    ms.bos := ms.main
                    ms.loc := ms.temp
                    ms.xloc := ms.loc
            // BOS block (independent of CHoCH)
            if i_buildsweep and not na(ms.bos) and low <= ms.bos and close >= ms.bos
                ms.dnsweep := true
                ms.bos := low
                ms.xloc := bar_index
            else if not na(ms.bos) and close <= ms.bos
                ms.txt := "bos"
                ms.zz := ms.bos
                id = ms.findSwing(true)
                ms.xloc := bar_index
                ms.bos := na
                ms.choch := high[id]
                ms.loc := bar_index[id]
            // CHoCH block
            if i_buildsweep and high >= ms.choch and close <= ms.choch
                ms.upsweep := true
                ms.choch := high
                ms.xloc := bar_index
            else if close >= ms.choch
                ms.txt := "choch"
                ms.zz := ms.choch
                id = ms.findSwing(false)
                if na(ms.bos)
                    ms.choch := low[id]
                else
                    ms.choch := ms.bos
                ms.bos := na
                ms.main := high
                ms.trend := 1
                ms.loc := bar_index
                ms.xloc := bar_index
                ms.temp := ms.loc

        else if ms.trend == 1
            if high >= ms.main
                ms.main := high
                ms.temp := bar_index
            if na(ms.bos)
                if crossdn and close < open and close[1] < open[1]
                    ms.bos := ms.main
                    ms.loc := ms.temp
                    ms.xloc := ms.loc
            if bar_index % i_mslen * 2 == 0
                if not na(ms.bos) and i_msmode == "Adjusted Points" and plp.size() > 0
                    if plp.get(0) > ms.choch
                        ms.choch := plp.get(0)
                        ms.loc := pln.get(0)
                        ms.xloc := pln.get(0)
                        ms.temp := pln.get(0)
            // BOS block
            if i_buildsweep and not na(ms.bos) and high >= ms.bos and close <= ms.bos
                ms.upsweep := true
                ms.bos := high
                ms.xloc := bar_index
            else if not na(ms.bos) and close >= ms.bos
                ms.txt := "bos"
                ms.zz := ms.bos
                id = ms.findSwing(false)
                ms.xloc := bar_index
                ms.bos := na
                ms.choch := low[id]
                ms.loc := bar_index[id]
            // CHoCH block
            if i_buildsweep and low <= ms.choch and close >= ms.choch
                ms.dnsweep := true
                ms.choch := low
                ms.xloc := bar_index
            else if close <= ms.choch
                ms.txt := "choch"
                ms.zz := ms.choch
                id = ms.findSwing(true)
                if na(ms.bos)
                    ms.choch := high[id]
                else
                    ms.choch := ms.bos
                ms.bos := na
                ms.main := low
                ms.trend := -1
                ms.loc := bar_index
                ms.temp := ms.loc
                ms.xloc := bar_index
    ms

// ══════════════════════════════════════════════════════════════════
//                         RUN MS + EVENTS
// ══════════════════════════════════════════════════════════════════

// Always call MS engine each bar for consistent internal var history
structure ms = msStructure()

var int prev_ms_trend = 0
bool ms_TrendUp = false
bool ms_TrendDown = false
bool ms_BOS = false
bool ms_CHoCH = false

var SweepMark[] sweepMarks = array.new<SweepMark>()

if not na(ms)
    // txt is cleared each bar inside msStructure; non-na means event this bar
    ms_CHoCH := ms.txt == "choch"
    ms_BOS := ms.txt == "bos"
    if ms.trend == 1 and prev_ms_trend != 1
        ms_TrendUp := true
    if ms.trend == -1 and prev_ms_trend != -1
        ms_TrendDown := true
    if i_buildsweep
        if ms.upsweep
            sweepMarks.unshift(SweepMark.new(bar_index, high, true))
            while sweepMarks.size() > i_sweepMax
                sweepMarks.pop()
        if ms.dnsweep
            sweepMarks.unshift(SweepMark.new(bar_index, low, false))
            while sweepMarks.size() > i_sweepMax
                sweepMarks.pop()
    prev_ms_trend := ms.trend

// ══════════════════════════════════════════════════════════════════
//                    PARENT FIB (TREND CYCLE)
// ══════════════════════════════════════════════════════════════════

var float fibWmHigh = na
var int   fibWmHighBar = na
var float fibSaveHigh = na
var int   fibSaveHighBar = na
var float fibBearLowTrack = na
var int   fibBearLowBar = na
var bool fibBearArm = false

var float fibWmLow = na
var int   fibWmLowBar = na
var float fibSaveLow = na
var int   fibSaveLowBar = na
var float fibBullHighTrack = na
var int   fibBullHighBar = na
var bool fibBullArm = false

var float fibLockedH = na
var float fibLockedL = na
var int   fibLockedHBar = na
var int   fibLockedLBar = na
var bool fibLockedBull = false
var bool fibLockValid = false
var int fibLockedX1 = na
var int fibArmX1 = na

if not na(ms)
    if ms.trend == 1
        if na(fibWmHigh) or high >= fibWmHigh
            fibWmHigh := high
            fibWmHighBar := bar_index
    if ms.trend == -1
        if na(fibWmLow) or low <= fibWmLow
            fibWmLow := low
            fibWmLowBar := bar_index

    if ms_TrendDown
        if fibBullArm
            if not na(fibSaveLow)
                fibLockedL := fibSaveLow
                fibLockedH := fibBullHighTrack
                fibLockedLBar := fibSaveLowBar
                fibLockedHBar := fibBullHighBar
                fibLockedBull := true
                fibLockValid := fibLockedH > fibLockedL
                fibLockedX1 := math.min(nz(fibLockedLBar, bar_index), nz(fibLockedHBar, bar_index))
            fibBullArm := false
            fibSaveLow := na
            fibSaveLowBar := na
        fibSaveHigh := fibWmHigh
        fibSaveHighBar := fibWmHighBar
        fibWmHigh := na
        fibWmHighBar := na
        fibBearArm := true
        fibBearLowTrack := low
        fibBearLowBar := bar_index
        fibArmX1 := bar_index

    if fibBearArm and ms.trend == -1
        if low <= nz(fibBearLowTrack, low)
            fibBearLowTrack := low
            fibBearLowBar := bar_index

    if ms_TrendUp
        if fibBearArm and not na(fibSaveHigh)
            fibLockedH := fibSaveHigh
            fibLockedL := fibBearLowTrack
            fibLockedHBar := fibSaveHighBar
            fibLockedLBar := fibBearLowBar
            fibLockedBull := false
            fibLockValid := fibLockedH > fibLockedL
            fibLockedX1 := math.min(nz(fibLockedLBar, bar_index), nz(fibLockedHBar, bar_index))
            fibBearArm := false
            fibSaveHigh := na
            fibSaveHighBar := na
        fibSaveLow := fibWmLow
        fibSaveLowBar := fibWmLowBar
        fibWmLow := na
        fibWmLowBar := na
        fibBullArm := true
        fibBullHighTrack := high
        fibBullHighBar := bar_index
        fibArmX1 := bar_index

    if fibBullArm and ms.trend == 1
        if high >= nz(fibBullHighTrack, high)
            fibBullHighTrack := high
            fibBullHighBar := bar_index

// Active parent: forming armed cycle preferred, else last locked
float parentH = na
float parentL = na
int parentHBar = na
int parentLBar = na
bool parentBull = true
int parentX1 = bar_index
bool parentValid = false

if fibBullArm
    parentL := not na(fibSaveLow) ? fibSaveLow : (not na(ms) ? ms.choch : na)
    parentH := fibBullHighTrack
    parentLBar := not na(fibSaveLowBar) ? fibSaveLowBar : (not na(ms) ? ms.loc : na)
    parentHBar := fibBullHighBar
    parentBull := true
    parentValid := not na(parentH) and not na(parentL) and parentH > parentL
    parentX1 := math.min(nz(parentLBar, nz(fibArmX1, bar_index)), nz(parentHBar, nz(fibArmX1, bar_index)))
else if fibBearArm
    parentH := not na(fibSaveHigh) ? fibSaveHigh : (not na(ms) ? ms.choch : na)
    parentL := fibBearLowTrack
    parentHBar := not na(fibSaveHighBar) ? fibSaveHighBar : (not na(ms) ? ms.loc : na)
    parentLBar := fibBearLowBar
    parentBull := false
    parentValid := not na(parentH) and not na(parentL) and parentH > parentL
    parentX1 := math.min(nz(parentLBar, nz(fibArmX1, bar_index)), nz(parentHBar, nz(fibArmX1, bar_index)))
else if fibLockValid
    parentH := fibLockedH
    parentL := fibLockedL
    parentHBar := fibLockedHBar
    parentLBar := fibLockedLBar
    parentBull := fibLockedBull
    parentValid := true
    parentX1 := nz(fibLockedX1, math.min(nz(parentLBar, bar_index), nz(parentHBar, bar_index)))

float parentRange = parentValid ? parentH - parentL : na
float parentSafe = parentValid and parentRange > 0 ? parentRange : 1.0

calcFib(float ratio, float h, float l, bool bull) =>
    bull ? h - ratio * (h - l) : l + ratio * (h - l)

// Extension input 1.272 → calc ratio -0.272 (beyond the 0% extreme)
extCalc(float extRatio) =>
    1.0 - extRatio

fmtPct(float ratio) =>
    str.tostring(ratio * 100.0, "#.###") + "%"

float f0 = parentValid ? calcFib(i_r0, parentH, parentL, parentBull) : na
float f236 = parentValid ? calcFib(i_r236, parentH, parentL, parentBull) : na
float f382 = parentValid ? calcFib(i_r382, parentH, parentL, parentBull) : na
float f500 = parentValid ? calcFib(i_r50, parentH, parentL, parentBull) : na
float f618 = parentValid ? calcFib(i_r618, parentH, parentL, parentBull) : na
float f786 = parentValid ? calcFib(i_r786, parentH, parentL, parentBull) : na
float f886 = parentValid ? calcFib(i_r886, parentH, parentL, parentBull) : na
float f100 = parentValid ? calcFib(i_r100, parentH, parentL, parentBull) : na
float fE1 = parentValid ? calcFib(extCalc(i_rExt1), parentH, parentL, parentBull) : na
float fE2 = parentValid ? calcFib(extCalc(i_rExt2), parentH, parentL, parentBull) : na
float fGoldA = parentValid ? calcFib(i_rGoldA, parentH, parentL, parentBull) : na
float fGoldB = parentValid ? calcFib(i_rGoldB, parentH, parentL, parentBull) : na
float fDeepA = parentValid ? calcFib(i_rDeepA, parentH, parentL, parentBull) : na
float fDeepB = parentValid ? calcFib(i_rDeepB, parentH, parentL, parentBull) : na

float atrVal = ta.atr(i_atrLen)
float goldenMid = parentValid ? (fGoldA + fGoldB) / 2.0 : na
float volUpper = parentValid ? goldenMid + atrVal * 0.5 : na
float volLower = parentValid ? goldenMid - atrVal * 0.5 : na
color trendC = parentBull ? i_bullC : i_bearC

// ══════════════════════════════════════════════════════════════════
//                 CHILD FIBS (BOS / CHoCH LEGS)
// ══════════════════════════════════════════════════════════════════
// Child leg = protect origin wick ↔ running extreme wick (ms.main / ms.temp).
// Stored as explicit hi/lo + bars so 0%/100% always start on those wicks.
// Note: after CHoCH, ms.loc is the break bar — NOT the choch wick. Resolve wick bars explicitly.

var float legHi = na
var int   legHiBar = na
var float legLo = na
var int   legLoBar = na
var bool  legIsBull = true
var FibLeg[] childLegs = array.new<FibLeg>()
var FibLeg formingChild = FibLeg.new(na, na, na, na, na, true, false)

// Find bar_index whose high/low matches px (prefer hint if it matches).
f_bar_of_high(float px, int hint) =>
    int out = na
    if not na(px)
        int maxLook = math.min(i_swingCap, bar_index)
        if not na(hint)
            int offH = bar_index - hint
            if offH >= 0 and offH <= maxLook and high[offH] == px
                out := hint
        if na(out)
            for i = 0 to maxLook
                if high[i] == px
                    out := bar_index - i
                    break
        if na(out)
            out := nz(hint, bar_index)
    out

f_bar_of_low(float px, int hint) =>
    int out = na
    if not na(px)
        int maxLook = math.min(i_swingCap, bar_index)
        if not na(hint)
            int offL = bar_index - hint
            if offL >= 0 and offL <= maxLook and low[offL] == px
                out := hint
        if na(out)
            for i = 0 to maxLook
                if low[i] == px
                    out := bar_index - i
                    break
        if na(out)
            out := nz(hint, bar_index)
    out

pushChild(float h, float l, int xH, int xL, bool bull) =>
    if not na(h) and not na(l) and h > l and not na(xH) and not na(xL)
        int x1 = math.min(xH, xL)
        childLegs.unshift(FibLeg.new(h, l, x1, xH, xL, bull, true))
        while childLegs.size() > i_maxChild
            childLegs.pop()

makeForming(bool bull, float hi, int hiBar, float lo, int loBar) =>
    FibLeg out = FibLeg.new(na, na, na, na, na, bull, false)
    if not na(hi) and not na(lo) and hi > lo and not na(hiBar) and not na(loBar)
        int x1 = math.min(hiBar, loBar)
        out := FibLeg.new(hi, lo, x1, hiBar, loBar, bull, true)
    out

if not na(ms)
    // New parent trend → wipe child history; seed hi/lo from structure
    if ms_TrendUp
        childLegs.clear()
        legIsBull := true
        legLo := ms.choch
        legLoBar := f_bar_of_low(ms.choch, ms.loc)
        legHi := ms.main
        legHiBar := f_bar_of_high(ms.main, ms.temp)
        formingChild := makeForming(true, legHi, legHiBar, legLo, legLoBar)
    if ms_TrendDown
        childLegs.clear()
        legIsBull := false
        legHi := ms.choch
        legHiBar := f_bar_of_high(ms.choch, ms.loc)
        legLo := ms.main
        legLoBar := f_bar_of_low(ms.main, ms.temp)
        formingChild := makeForming(false, legHi, legHiBar, legLo, legLoBar)

    // Track running extreme BEFORE BOS lock (include break-bar wick)
    if ms.start == 2 and not ms_TrendUp and not ms_TrendDown and not na(legHi) and not na(legLo)
        if legIsBull and ms.trend == 1 and not na(ms.main)
            if ms.main > legHi
                legHi := ms.main
                legHiBar := f_bar_of_high(ms.main, ms.temp)
        else if not legIsBull and ms.trend == -1 and not na(ms.main)
            if ms.main < legLo
                legLo := ms.main
                legLoBar := f_bar_of_low(ms.main, ms.temp)
        // Adjusted Points may move protect mid-leg — never on BOS bar (MS already rewrote choch)
        if not ms_BOS
            if legIsBull and not na(ms.choch) and ms.choch != legLo
                legLo := ms.choch
                legLoBar := f_bar_of_low(ms.choch, ms.loc)
            else if not legIsBull and not na(ms.choch) and ms.choch != legHi
                legHi := ms.choch
                legHiBar := f_bar_of_high(ms.choch, ms.loc)

    // BOS: lock hi/lo wicks, then open next forming leg from new protect
    if ms_BOS and not na(legHi) and not na(legLo) and legHi > legLo
        if ms.trend == 1 and legIsBull
            pushChild(legHi, legLo, nz(legHiBar, bar_index), nz(legLoBar, bar_index), true)
            legIsBull := true
            legLo := ms.choch
            legLoBar := f_bar_of_low(ms.choch, ms.loc)
            legHi := high
            legHiBar := bar_index
            formingChild := makeForming(true, legHi, legHiBar, legLo, legLoBar)
        else if ms.trend == -1 and not legIsBull
            pushChild(legHi, legLo, nz(legHiBar, bar_index), nz(legLoBar, bar_index), false)
            legIsBull := false
            legHi := ms.choch
            legHiBar := f_bar_of_high(ms.choch, ms.loc)
            legLo := low
            legLoBar := bar_index
            formingChild := makeForming(false, legHi, legHiBar, legLo, legLoBar)
    else if ms.start == 2 and not ms_TrendUp and not ms_TrendDown and not ms_BOS
        formingChild := makeForming(legIsBull, legHi, legHiBar, legLo, legLoBar)

// ══════════════════════════════════════════════════════════════════
//                    EDGE HELPERS (ALMA / EMA / VWAP)
// ══════════════════════════════════════════════════════════════════

f_st(_src, _alma, _factor, _sdlength) =>
    _sd = ta.stdev(_src, _sdlength)
    _upperband = _alma + _factor * _sd
    _lowerband = _alma - _factor * _sd
    _prevupperband = nz(_upperband[1])
    _prevlowerband = nz(_lowerband[1])
    _upperband := _upperband < _prevupperband or _src[1] > _prevupperband ? _upperband : _prevupperband
    _lowerband := _lowerband > _prevlowerband or _src[1] < _prevlowerband ? _lowerband : _prevlowerband
    int _direction = 1
    float _supertrend = na
    _prevsupertrend = _supertrend[1]
    if na(_sd[1])
        _direction := 1
    else if _prevsupertrend == _prevupperband
        _direction := _src > _upperband ? -1 : 1
    else
        _direction := _src < _lowerband ? 1 : -1
    _supertrend := _direction == -1 ? _lowerband : _upperband
    [_supertrend, _direction]

f_alma_signal(_src, _factor, _sdlen, _almalen, _almasig, _almaoffset) =>
    _alma = ta.alma(_src, _almalen, _almaoffset, _almasig)
    [_st_result, _dir_result] = f_st(_src, _alma, _factor, _sdlen)
    int _signal = 0
    if _dir_result < 0
        _signal := 1
    if _dir_result > 0
        _signal := -1
    [_signal, _st_result, _alma]

// Slim session stats: [avgShort, avgLong, curShort, curLong]
f_alma_sessions(_signal, _win) =>
    _sig = _signal == 1 or _signal == -1 ? _signal : nz(_signal[1], 0)
    _isLong = _sig == 1
    _isShort = _sig == -1
    var int _shortRun = 0
    var int _longRun = 0
    _longRun := _isLong ? _longRun + 1 : 0
    _shortRun := _isShort ? _shortRun + 1 : 0
    _prevSig = _signal[1] == 1 or _signal[1] == -1 ? _signal[1] : nz(_signal[2], 0)
    _crossToLong = (_sig == 1 or _sig == -1) and (_prevSig == 1 or _prevSig == -1) and _isLong and _prevSig == -1
    _crossToShort = (_sig == 1 or _sig == -1) and (_prevSig == 1 or _prevSig == -1) and _isShort and _prevSig == 1
    _shortLen = _crossToLong ? nz(_shortRun[1]) : 0
    _longLen = _crossToShort ? nz(_longRun[1]) : 0
    _cumSlen = ta.cum(_shortLen)
    _cumScnt = ta.cum(_shortLen > 0 ? 1 : 0)
    _cumLlen = ta.cum(_longLen)
    _cumLcnt = ta.cum(_longLen > 0 ? 1 : 0)
    _sumS = _cumSlen - nz(_cumSlen[_win])
    _cntS = _cumScnt - nz(_cumScnt[_win])
    _sumL = _cumLlen - nz(_cumLlen[_win])
    _cntL = _cumLcnt - nz(_cumLcnt[_win])
    _avgS = _cntS > 0 ? _sumS / _cntS : na
    _avgL = _cntL > 0 ? _sumL / _cntL : na
    _curS = _isShort ? _shortRun : 0
    _curL = _isLong ? _longRun : 0
    [_avgS, _avgL, _curS, _curL]

f_alma_pack(_factor, _sdlen, _almalen, _almasig, _almaoffset, _win) =>
    [_sig, _st, _alma] = f_alma_signal(close, _factor, _sdlen, _almalen, _almasig, _almaoffset)
    [_avgS, _avgL, _curS, _curL] = f_alma_sessions(_sig, _win)
    [_avgS, _avgL, _curS, _curL, _st, _alma, _sig]

f_ema_pack(_len, _win) =>
    _ema = ta.ema(close, _len)
    _above = close > _ema
    var int _sRun = 0
    var int _lRun = 0
    _sRun := _above ? 0 : _sRun + 1
    _lRun := _above ? _lRun + 1 : 0
    _prevAbove = _above[1]
    _crossUp = _above and not _prevAbove
    _crossDown = not _above and _prevAbove
    _sLen = _crossUp ? nz(_sRun[1]) : 0
    _lLen = _crossDown ? nz(_lRun[1]) : 0
    _cumSlen = ta.cum(_sLen)
    _cumScnt = ta.cum(_sLen > 0 ? 1 : 0)
    _cumLlen = ta.cum(_lLen)
    _cumLcnt = ta.cum(_lLen > 0 ? 1 : 0)
    _avgS = (_cumScnt - nz(_cumScnt[_win])) > 0 ? (_cumSlen - nz(_cumSlen[_win])) / (_cumScnt - nz(_cumScnt[_win])) : na
    _avgL = (_cumLcnt - nz(_cumLcnt[_win])) > 0 ? (_cumLlen - nz(_cumLlen[_win])) / (_cumLcnt - nz(_cumLcnt[_win])) : na
    _curS = _above ? 0 : _sRun
    _curL = _above ? _lRun : 0
    [_avgS, _avgL, _curS, _curL, _ema]

// CT-fade for Pattern/Child fib direction:
// Bull fib (long pattern) → score SHORT / below-EMA pullback stretch (fade into golden long).
// Bear fib → score LONG / above-EMA pullback stretch.
// Base credit while on pullback side even if Cur ≤ Avg; full credit when Cur > thr×Avg.
f_oh_ratio(float cur, float avg, float thr) =>
    float r = 0.0
    if not na(avg) and avg > 0 and cur > thr * avg
        float ratio = math.min(cur / avg, 2.5)
        r := math.min((ratio - 1.0) / 1.5, 1.0)
    r

f_ct_pullback(bool fibBull, float curL, float avgL, float curS, float avgS, float thr) =>
    float oh = fibBull ? f_oh_ratio(curS, avgS, thr) : f_oh_ratio(curL, avgL, thr)
    bool onPullback = fibBull ? curS > 0 : curL > 0
    float statePts = onPullback ? 0.35 : 0.0
    math.min(1.0, statePts + oh * 0.65)

// ══════════════════════════════════════════════════════════════════
//                     EDGE DATA (MTF ALMA / EMA)
// ══════════════════════════════════════════════════════════════════

[alAvgS15, alAvgL15, alCurS15, alCurL15, alSt15, alLine15, alSig15] = request.security(syminfo.tickerid, "15", f_alma_pack(i_almaFactor, i_almaSdLen, i_almaLen, i_almaSig, i_almaOff, i_almaWin), barmerge.gaps_off, barmerge.lookahead_off)
[alAvgS1h, alAvgL1h, alCurS1h, alCurL1h, alSt1h, alLine1h, alSig1h] = request.security(syminfo.tickerid, "60", f_alma_pack(i_almaFactor, i_almaSdLen, i_almaLen, i_almaSig, i_almaOff, i_almaWin), barmerge.gaps_off, barmerge.lookahead_off)
[alAvgS4h, alAvgL4h, alCurS4h, alCurL4h, alSt4h, alLine4h, alSig4h] = request.security(syminfo.tickerid, "240", f_alma_pack(i_almaFactor, i_almaSdLen, i_almaLen, i_almaSig, i_almaOff, i_almaWin), barmerge.gaps_off, barmerge.lookahead_off)
[alAvgS1d, alAvgL1d, alCurS1d, alCurL1d, alSt1d, alLine1d, alSig1d] = request.security(syminfo.tickerid, "D", f_alma_pack(i_almaFactor, i_almaSdLen, i_almaLen, i_almaSig, i_almaOff, i_almaWin), barmerge.gaps_off, barmerge.lookahead_off)
[alAvgS3d, alAvgL3d, alCurS3d, alCurL3d, alSt3d, alLine3d, alSig3d] = request.security(syminfo.tickerid, "3D", f_alma_pack(i_almaFactor, i_almaSdLen, i_almaLen, i_almaSig, i_almaOff, i_almaWin), barmerge.gaps_off, barmerge.lookahead_off)
[alAvgS1w, alAvgL1w, alCurS1w, alCurL1w, alSt1w, alLine1w, alSig1w] = request.security(syminfo.tickerid, "W", f_alma_pack(i_almaFactor, i_almaSdLen, i_almaLen, i_almaSig, i_almaOff, i_almaWin), barmerge.gaps_off, barmerge.lookahead_off)

[emAvgS15, emAvgL15, emCurS15, emCurL15, ema15] = request.security(syminfo.tickerid, "15", f_ema_pack(i_emaLen15, i_emaWin), barmerge.gaps_off, barmerge.lookahead_off)
[emAvgS1h, emAvgL1h, emCurS1h, emCurL1h, ema1h] = request.security(syminfo.tickerid, "60", f_ema_pack(i_emaLen1h, i_emaWin), barmerge.gaps_off, barmerge.lookahead_off)
[emAvgS4h, emAvgL4h, emCurS4h, emCurL4h, ema4h] = request.security(syminfo.tickerid, "240", f_ema_pack(i_emaLen4h, i_emaWin), barmerge.gaps_off, barmerge.lookahead_off)
[emAvgS1d, emAvgL1d, emCurS1d, emCurL1d, ema1d] = request.security(syminfo.tickerid, "D", f_ema_pack(i_emaLen1d, i_emaWin), barmerge.gaps_off, barmerge.lookahead_off)
[emAvgS3d, emAvgL3d, emCurS3d, emCurL3d, ema3d] = request.security(syminfo.tickerid, "3D", f_ema_pack(i_emaLen3d, i_emaWin), barmerge.gaps_off, barmerge.lookahead_off)
[emAvgS1w, emAvgL1w, emCurS1w, emCurL1w, ema1w] = request.security(syminfo.tickerid, "W", f_ema_pack(i_emaLen1w, i_emaWin), barmerge.gaps_off, barmerge.lookahead_off)

// Chart-TF ALMA plot: pick matching HTF series (defaults = SuperTrend public params, same for all TF packs)
float chartAlmaSt = switch
    timeframe.period == "15" or (timeframe.isminutes and timeframe.multiplier == 15) => alSt15
    timeframe.period == "60" or (timeframe.isminutes and timeframe.multiplier == 60) => alSt1h
    timeframe.period == "240" or (timeframe.isminutes and timeframe.multiplier == 240) => alSt4h
    timeframe.isdaily and timeframe.multiplier == 1 => alSt1d
    timeframe.isdaily and timeframe.multiplier == 3 => alSt3d
    timeframe.isweekly => alSt1w
    => alSt1h
int chartAlmaSig = switch
    timeframe.period == "15" or (timeframe.isminutes and timeframe.multiplier == 15) => alSig15
    timeframe.period == "60" or (timeframe.isminutes and timeframe.multiplier == 60) => alSig1h
    timeframe.period == "240" or (timeframe.isminutes and timeframe.multiplier == 240) => alSig4h
    timeframe.isdaily and timeframe.multiplier == 1 => alSig1d
    timeframe.isdaily and timeframe.multiplier == 3 => alSig3d
    timeframe.isweekly => alSig1w
    => alSig1h

// Edge CT uses chart TF only (no multi-TF average)
string edgeChartTf = switch
    timeframe.period == "15" or (timeframe.isminutes and timeframe.multiplier == 15) => "15"
    timeframe.period == "60" or (timeframe.isminutes and timeframe.multiplier == 60) => "60"
    timeframe.period == "240" or (timeframe.isminutes and timeframe.multiplier == 240) => "240"
    timeframe.isdaily and timeframe.multiplier == 1 => "D"
    timeframe.isdaily and timeframe.multiplier == 3 => "3D"
    timeframe.isweekly => "W"
    => "60"

string edgeChartTfLabel = switch edgeChartTf
    "15" => "15m"
    "60" => "1H"
    "240" => "4H"
    "D" => "1D"
    "3D" => "3D"
    "W" => "1W"
    => "1H"

f_ct_alma_chart(bool fibBull) =>
    switch edgeChartTf
        "15" => f_ct_pullback(fibBull, alCurL15, alAvgL15, alCurS15, alAvgS15, i_ohMult)
        "60" => f_ct_pullback(fibBull, alCurL1h, alAvgL1h, alCurS1h, alAvgS1h, i_ohMult)
        "240" => f_ct_pullback(fibBull, alCurL4h, alAvgL4h, alCurS4h, alAvgS4h, i_ohMult)
        "D" => f_ct_pullback(fibBull, alCurL1d, alAvgL1d, alCurS1d, alAvgS1d, i_ohMult)
        "3D" => f_ct_pullback(fibBull, alCurL3d, alAvgL3d, alCurS3d, alAvgS3d, i_ohMult)
        "W" => f_ct_pullback(fibBull, alCurL1w, alAvgL1w, alCurS1w, alAvgS1w, i_ohMult)
        => f_ct_pullback(fibBull, alCurL1h, alAvgL1h, alCurS1h, alAvgS1h, i_ohMult)

f_ct_ema_chart(bool fibBull) =>
    switch edgeChartTf
        "15" => f_ct_pullback(fibBull, emCurL15, emAvgL15, emCurS15, emAvgS15, i_ohMult)
        "60" => f_ct_pullback(fibBull, emCurL1h, emAvgL1h, emCurS1h, emAvgS1h, i_ohMult)
        "240" => f_ct_pullback(fibBull, emCurL4h, emAvgL4h, emCurS4h, emAvgS4h, i_ohMult)
        "D" => f_ct_pullback(fibBull, emCurL1d, emAvgL1d, emCurS1d, emAvgS1d, i_ohMult)
        "3D" => f_ct_pullback(fibBull, emCurL3d, emAvgL3d, emCurS3d, emAvgS3d, i_ohMult)
        "W" => f_ct_pullback(fibBull, emCurL1w, emAvgL1w, emCurS1w, emAvgS1w, i_ohMult)
        => f_ct_pullback(fibBull, emCurL1h, emAvgL1h, emCurS1h, emAvgS1h, i_ohMult)

// ══════════════════════════════════════════════════════════════════
//              FIB-ANCHORED VWAP (Pattern parentX1 + Child)
// ══════════════════════════════════════════════════════════════════

var float fibVwapCumTPV = 0.0
var float fibVwapCumVol = 0.0
var int fibVwapAnchor = na
float fibVwap = na

f_seed_vwap(int anchor) =>
    float cTPV = 0.0
    float cVol = 0.0
    int span = math.min(math.max(bar_index - anchor, 0), i_swingCap)
    for i = span to 0
        float tp = (high[i] + low[i] + close[i]) / 3.0
        float vol = math.max(volume[i], 1e-10)
        cTPV += tp * vol
        cVol += vol
    [cTPV, cVol]

if parentValid and not na(parentX1)
    if na(fibVwapAnchor) or fibVwapAnchor != parentX1
        fibVwapAnchor := parentX1
        [sTPV, sVol] = f_seed_vwap(parentX1)
        fibVwapCumTPV := sTPV
        fibVwapCumVol := sVol
    else
        float tpN = (high + low + close) / 3.0
        float volN = math.max(volume, 1e-10)
        fibVwapCumTPV += tpN * volN
        fibVwapCumVol += volN
    fibVwap := fibVwapCumVol > 0 ? fibVwapCumTPV / fibVwapCumVol : na
else
    fibVwapAnchor := na
    fibVwapCumTPV := 0.0
    fibVwapCumVol := 0.0
    fibVwap := na

// Active child for Child Edge (forming preferred, else newest completed L1)
bool childEdgeValid = false
bool childEdgeBull = true
float childEdgeH = na
float childEdgeL = na
int childEdgeX1 = na
if formingChild.active and not na(formingChild.h) and not na(formingChild.l) and formingChild.h > formingChild.l
    childEdgeValid := true
    childEdgeBull := formingChild.bull
    childEdgeH := formingChild.h
    childEdgeL := formingChild.l
    childEdgeX1 := formingChild.x1
else if childLegs.size() > 0
    FibLeg leg0 = childLegs.get(0)
    if leg0.active and leg0.h > leg0.l
        childEdgeValid := true
        childEdgeBull := leg0.bull
        childEdgeH := leg0.h
        childEdgeL := leg0.l
        childEdgeX1 := leg0.x1

float childRange = childEdgeValid ? childEdgeH - childEdgeL : na
float childSafe = childEdgeValid and childRange > 0 ? childRange : 1.0
float childGoldA = childEdgeValid ? calcFib(i_rGoldA, childEdgeH, childEdgeL, childEdgeBull) : na
float childGoldB = childEdgeValid ? calcFib(i_rGoldB, childEdgeH, childEdgeL, childEdgeBull) : na
float childGoldMid = childEdgeValid ? (childGoldA + childGoldB) / 2.0 : na

var float childVwapCumTPV = 0.0
var float childVwapCumVol = 0.0
var int childVwapAnchor = na
float childVwap = na

if childEdgeValid and not na(childEdgeX1)
    if na(childVwapAnchor) or childVwapAnchor != childEdgeX1
        childVwapAnchor := childEdgeX1
        [cTPV2, cVol2] = f_seed_vwap(childEdgeX1)
        childVwapCumTPV := cTPV2
        childVwapCumVol := cVol2
    else
        float tpC = (high + low + close) / 3.0
        float volC = math.max(volume, 1e-10)
        childVwapCumTPV += tpC * volC
        childVwapCumVol += volC
    childVwap := childVwapCumVol > 0 ? childVwapCumTPV / childVwapCumVol : na
else
    childVwapAnchor := na
    childVwapCumTPV := 0.0
    childVwapCumVol := 0.0
    childVwap := na

// ══════════════════════════════════════════════════════════════════
//              EDGE SCORE — PATTERN (parent) + CHILD
// ══════════════════════════════════════════════════════════════════

f_vwap_fade_pts(bool fibBull, float vwap, float rng) =>
    float pts = 0.0
    if not na(vwap) and rng > 0
        float vProx = 1.0 - math.min(math.abs(close - vwap) / rng, 1.0)
        // Pullback vs origin VWAP: bull fib → price at/below VWAP; bear → at/above
        bool fadeSide = fibBull ? close <= vwap : close >= vwap
        pts := vProx * (fadeSide ? 25.0 : 12.0)
    pts

// ——— Pattern (parent) ———
float proxScore = 0.0
float distGolden = parentValid ? math.abs(close - goldenMid) : 1.0
float proxRatio = parentValid ? 1.0 - math.min(distGolden / parentSafe, 1.0) : 0.0
proxScore := proxRatio * 25.0

float almaScore = parentValid ? f_ct_alma_chart(parentBull) * 25.0 : 0.0
float emaScore = parentValid ? f_ct_ema_chart(parentBull) * 25.0 : 0.0
float vwapScore = parentValid ? f_vwap_fade_pts(parentBull, fibVwap, parentSafe) : 0.0

int edgeScore = parentValid ? int(math.round(proxScore + almaScore + emaScore + vwapScore)) : 0
string edgeLabel = edgeScore >= 75 ? "STRONG" : edgeScore >= 50 ? "MODERATE" : edgeScore >= 25 ? "WEAK" : "LOW"
color edgeColorF = edgeScore >= 75 ? #00e676 : edgeScore >= 50 ? #ffd740 : edgeScore >= 25 ? #ff9800 : #ff1744

// ——— Child ———
float childProxScore = 0.0
if childEdgeValid and not na(childGoldMid)
    float dCG = math.abs(close - childGoldMid)
    childProxScore := (1.0 - math.min(dCG / childSafe, 1.0)) * 25.0

float childAlmaScore = childEdgeValid ? f_ct_alma_chart(childEdgeBull) * 25.0 : 0.0
float childEmaScore = childEdgeValid ? f_ct_ema_chart(childEdgeBull) * 25.0 : 0.0
float childVwapScore = childEdgeValid ? f_vwap_fade_pts(childEdgeBull, childVwap, childSafe) : 0.0

int childEdgeScore = childEdgeValid ? int(math.round(childProxScore + childAlmaScore + childEmaScore + childVwapScore)) : 0
string childEdgeLabel = childEdgeScore >= 75 ? "STRONG" : childEdgeScore >= 50 ? "MODERATE" : childEdgeScore >= 25 ? "WEAK" : "LOW"
color childEdgeColorF = childEdgeScore >= 75 ? #00e676 : childEdgeScore >= 50 ? #ffd740 : childEdgeScore >= 25 ? #ff9800 : #ff1744

bool inChildGolden = childEdgeValid and not na(childGoldA) and not na(childGoldB) and (close >= math.min(childGoldA, childGoldB)) and (close <= math.max(childGoldA, childGoldB))

calcAlpha(float _price, float _range) =>
    if i_heatmap and _range > 0
        _dist = math.abs(close - _price)
        _ratio = math.min(_dist / _range, 1.0)
        int(math.round(i_heatNearTransp + _ratio * math.max(i_heatFarTransp - i_heatNearTransp, 0)))
    else
        i_lineTransp

// Edge overlays
plot(i_showVwapPlot and parentValid ? fibVwap : na, "Pattern Fib VWAP", color = color.new(#42a5f5, 0), linewidth = 2, style = plot.style_line)
plot(i_showVwapPlot and childEdgeValid ? childVwap : na, "Child Fib VWAP", color = color.new(#26c6da, 20), linewidth = 1, style = plot.style_line)
plot(i_showAlmaPlot ? chartAlmaSt : na, "ALMA ST (chart TF)", color = chartAlmaSig == 1 ? i_almaUpC : i_almaDnC, linewidth = 2)
plot(i_showEmaPlot and i_ema15 ? ema15 : na, "EMA 15m", color = i_emaC15, linewidth = 1)
plot(i_showEmaPlot and i_ema1h ? ema1h : na, "EMA 1H", color = i_emaC1h, linewidth = 1)
plot(i_showEmaPlot and i_ema4h ? ema4h : na, "EMA 4H", color = i_emaC4h, linewidth = 1)
plot(i_showEmaPlot and i_ema1d ? ema1d : na, "EMA 1D", color = i_emaC1d, linewidth = 2)
plot(i_showEmaPlot and i_ema3d ? ema3d : na, "EMA 3D", color = i_emaC3d, linewidth = 1)
plot(i_showEmaPlot and i_ema1w ? ema1w : na, "EMA 1W", color = i_emaC1w, linewidth = 2)

// ══════════════════════════════════════════════════════════════════
//                         DRAW HELPERS
// ══════════════════════════════════════════════════════════════════

var line[] gLines = array.new_line()
var label[] gLabels = array.new_label()
var box[] gBoxes = array.new_box()

clearDraw() =>
    if gLines.size() > 0
        for ln in gLines
            line.delete(ln)
        gLines.clear()
    if gLabels.size() > 0
        for lb in gLabels
            label.delete(lb)
        gLabels.clear()
    if gBoxes.size() > 0
        for bx in gBoxes
            box.delete(bx)
        gBoxes.clear()

drawLvl(int x1, int x2, int xLbl, float price, string txt, color col, int w, string sty, float rng) =>
    lineStyle = switch sty
        "solid" => line.style_solid
        "dot" => line.style_dotted
        => line.style_dashed
    // Clamp start so line is never empty / off-chart lookback
    int xStart = math.max(math.min(x1, x2 - 1), bar_index - 5000)
    usedC = color.new(col, calcAlpha(price, rng))
    ln = line.new(xStart, price, x2, price, color = usedC, width = w, style = lineStyle)
    gLines.push(ln)
    if i_showLabels
        lb = label.new(xLbl, price, txt + "  " + str.tostring(price, format.mintick), style = label.style_label_left, color = color.new(col, i_lblTransp), textcolor = i_lblTxtC, size = f_lbl_size())
        gLabels.push(lb)

// 0% → extreme wick bar; 100% → origin wick bar; mids interpolate between xH and xL.
// For bull: 0%=high(xH), 100%=low(xL). For bear: 0%=low(xL), 100%=high(xH).
f_level_x1(float ratio, int xH, int xL, bool bull) =>
    int xExt = bull ? xH : xL
    int xOrg = bull ? xL : xH
    int x = xExt
    if na(xExt) and na(xOrg)
        x := bar_index
    else if na(xExt)
        x := xOrg
    else if na(xOrg)
        x := xExt
    else if ratio <= 0.0
        x := xExt
    else if ratio >= 1.0
        x := xOrg
    else
        x := int(math.round(xExt + ratio * (xOrg - xExt)))
    x

drawFibSet(float h, float l, bool bull, int xH, int xL, int x2, int xLbl, string prefix, color accent, int baseW, bool full, bool drawGolden, bool drawDeep, bool volBand, float rng, color goldFill, color goldBord, color deepFill, color deepBord, bool goldLabel) =>
    c0 = calcFib(i_r0, h, l, bull)
    c236 = calcFib(i_r236, h, l, bull)
    c382 = calcFib(i_r382, h, l, bull)
    c500 = calcFib(i_r50, h, l, bull)
    c618 = calcFib(i_r618, h, l, bull)
    c786 = calcFib(i_r786, h, l, bull)
    c886 = calcFib(i_r886, h, l, bull)
    c100 = calcFib(i_r100, h, l, bull)
    cGoldA = calcFib(i_rGoldA, h, l, bull)
    cGoldB = calcFib(i_rGoldB, h, l, bull)
    cDeepA = calcFib(i_rDeepA, h, l, bull)
    cDeepB = calcFib(i_rDeepB, h, l, bull)
    col0 = i_useTrendEnds ? accent : i_c0
    col100 = i_useTrendEnds ? accent : i_c100
    // Pin 0%/100% to extreme/origin wick bars (no ratio float ambiguity)
    int xStart0 = bull ? nz(xH, math.min(nz(xL, bar_index), bar_index)) : nz(xL, math.min(nz(xH, bar_index), bar_index))
    int xStart100 = bull ? nz(xL, math.min(nz(xH, bar_index), bar_index)) : nz(xH, math.min(nz(xL, bar_index), bar_index))
    xBox = math.min(xStart0, xStart100)
    if i_show0
        drawLvl(xStart0, x2, xLbl, c0, prefix + " " + fmtPct(i_r0), col0, baseW + 1, "solid", rng)
    if i_show100
        drawLvl(xStart100, x2, xLbl, c100, prefix + " " + fmtPct(i_r100), col100, baseW + 1, "solid", rng)
    if i_show618
        drawLvl(f_level_x1(i_r618, xH, xL, bull), x2, xLbl, c618, prefix + " " + fmtPct(i_r618), i_c618, baseW + (full ? 1 : 0), "solid", rng)
    if i_show786
        drawLvl(f_level_x1(i_r786, xH, xL, bull), x2, xLbl, c786, prefix + " " + fmtPct(i_r786), i_c786, baseW + (full ? 1 : 0), "solid", rng)
    if i_show50
        drawLvl(f_level_x1(i_r50, xH, xL, bull), x2, xLbl, c500, prefix + " " + fmtPct(i_r50), i_c50, baseW, "dot", rng)
    if full
        if i_show236
            drawLvl(f_level_x1(i_r236, xH, xL, bull), x2, xLbl, c236, prefix + " " + fmtPct(i_r236), i_c236, baseW, "dash", rng)
        if i_show382
            drawLvl(f_level_x1(i_r382, xH, xL, bull), x2, xLbl, c382, prefix + " " + fmtPct(i_r382), i_c382, baseW, "dash", rng)
        if i_show886
            drawLvl(f_level_x1(i_r886, xH, xL, bull), x2, xLbl, c886, prefix + " " + fmtPct(i_r886), i_c886, baseW, "dash", rng)
        if i_showExt1
            cE1 = calcFib(extCalc(i_rExt1), h, l, bull)
            drawLvl(f_level_x1(extCalc(i_rExt1), xH, xL, bull), x2, xLbl, cE1, prefix + " " + fmtPct(i_rExt1), i_cExt1, baseW, "dot", rng)
        if i_showExt2
            cE2 = calcFib(extCalc(i_rExt2), h, l, bull)
            drawLvl(f_level_x1(extCalc(i_rExt2), xH, xL, bull), x2, xLbl, cE2, prefix + " " + fmtPct(i_rExt2), i_cExt2, baseW, "dot", rng)
    if drawGolden and i_showGolden
        gTop = math.max(cGoldA, cGoldB)
        gBot = math.min(cGoldA, cGoldB)
        xG = math.min(f_level_x1(i_rGoldA, xH, xL, bull), f_level_x1(i_rGoldB, xH, xL, bull))
        bx = box.new(math.max(xG, bar_index - 5000), gTop, x2, gBot, border_color = goldBord, border_width = 2, border_style = line.style_solid, bgcolor = goldFill)
        gBoxes.push(bx)
        if goldLabel
            lbz = label.new(xLbl, math.avg(gTop, gBot), prefix + " GOLDEN", style = label.style_label_left, color = color.new(goldBord, 80), textcolor = i_lblTxtC, size = f_lbl_size())
            gLabels.push(lbz)
    if drawDeep and i_showDeep
        dTop = math.max(cDeepA, cDeepB)
        dBot = math.min(cDeepA, cDeepB)
        xD = math.min(f_level_x1(i_rDeepA, xH, xL, bull), f_level_x1(i_rDeepB, xH, xL, bull))
        bx2 = box.new(math.max(xD, bar_index - 5000), dTop, x2, dBot, border_color = deepBord, border_width = 1, border_style = line.style_dotted, bgcolor = deepFill)
        gBoxes.push(bx2)
    if volBand and i_showVolB and not na(volUpper)
        bx3 = box.new(math.max(xBox, bar_index - 5000), volUpper, x2, volLower, border_color = i_volBordC, border_width = 1, border_style = line.style_dotted, bgcolor = i_volBC)
        gBoxes.push(bx3)

// ══════════════════════════════════════════════════════════════════
//                             DRAWING
// ══════════════════════════════════════════════════════════════════

var table dashboard = table.new(position.top_right, 2, 10, bgcolor = color.new(#0d1117, 5), border_color = color.new(#30363d, 0), border_width = 1)
var table childDash = table.new(position.bottom_left, 2, 9, bgcolor = color.new(#0d1117, 5), border_color = color.new(#30363d, 0), border_width = 1)

if barstate.islast
    clearDraw()
    x2p = bar_index + i_extend
    xLblP = x2p + 2
    x2c = bar_index + i_childExtend
    xLblC = x2c + 2

    if i_showParent and parentValid
        drawFibSet(parentH, parentL, parentBull, nz(parentHBar, parentX1), nz(parentLBar, parentX1), x2p, xLblP, "T", trendC, i_lineW, true, true, true, true, parentSafe, i_cGoldFill, i_cGoldBord, i_cDeepFill, i_cDeepBord, true)

    if i_showChild
        childDrawGold = i_childGolden and i_showGolden
        childDrawDeep = i_childDeep and i_showDeep
        // L1 = newest BOS-locked leg, L2 = previous; Lf = forming (not yet locked)
        if childLegs.size() > 0
            for i = 0 to childLegs.size() - 1
                leg = childLegs.get(i)
                if leg.active
                    rngC = leg.h - leg.l
                    accentC = leg.bull ? color.new(i_bullC, 35) : color.new(i_bearC, 35)
                    tag = "L" + str.tostring(i + 1)
                    drawFibSet(leg.h, leg.l, leg.bull, nz(leg.xH, leg.x1), nz(leg.xL, leg.x1), x2c, xLblC, tag, accentC, i_lineW, i_childFull, childDrawGold, childDrawDeep, false, rngC, i_cChildGoldFill, i_cChildGoldBord, i_cChildDeepFill, i_cChildDeepBord, true)
                    if i_showChildAnchors
                        lbH = label.new(leg.xH, leg.h, tag + " H", style = label.style_label_down, color = color.new(accentC, 30), textcolor = color.white, size = size.tiny)
                        lbL = label.new(leg.xL, leg.l, tag + " L", style = label.style_label_up, color = color.new(accentC, 30), textcolor = color.white, size = size.tiny)
                        gLabels.push(lbH)
                        gLabels.push(lbL)
        if formingChild.active and not na(formingChild.h) and not na(formingChild.l)
            rngF = formingChild.h - formingChild.l
            if rngF > 0
                accentF = formingChild.bull ? color.new(i_bullC, 50) : color.new(i_bearC, 50)
                drawFibSet(formingChild.h, formingChild.l, formingChild.bull, nz(formingChild.xH, formingChild.x1), nz(formingChild.xL, formingChild.x1), x2c, xLblC, "Lf", accentF, 1, i_childFull, childDrawGold, childDrawDeep, false, rngF, i_cChildGoldFill, i_cChildGoldBord, i_cChildDeepFill, i_cChildDeepBord, true)
                if i_showChildAnchors
                    lbHf = label.new(formingChild.xH, formingChild.h, "Lf H", style = label.style_label_down, color = color.new(accentF, 20), textcolor = color.white, size = size.tiny)
                    lbLf = label.new(formingChild.xL, formingChild.l, "Lf L", style = label.style_label_up, color = color.new(accentF, 20), textcolor = color.white, size = size.tiny)
                    gLabels.push(lbHf)
                    gLabels.push(lbLf)

    sweepSz = switch i_sweepSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.small

    if i_showSweep and sweepMarks.size() > 0
        for i = 0 to sweepMarks.size() - 1
            sw = sweepMarks.get(i)
            swCol = sw.isUp ? i_sweepUpC : i_sweepDnC
            swStyle = sw.isUp ? label.style_label_down : label.style_label_up
            lbsw = label.new(sw.x, sw.y, i_sweepTxt, style = swStyle, color = i_sweepBg, textcolor = swCol, size = sweepSz)
            gLabels.push(lbsw)

    if i_showMsLbl and not na(ms)
        msTxt = ms.txt == "bos" ? "BOS" : ms.txt == "choch" ? "CHoCH" : ms.trend == 1 ? "UP" : ms.trend == -1 ? "DN" : ""
        if msTxt != ""
            lbms = label.new(bar_index, high, msTxt, style = label.style_label_down, color = color.new(trendC, 70), textcolor = color.white, size = size.tiny)
            gLabels.push(lbms)

// ══════════════════════════════════════════════════════════════════
//                          DASHBOARD
// ══════════════════════════════════════════════════════════════════

bool inGolden = parentValid and not na(fGoldA) and not na(fGoldB) and (close >= math.min(fGoldA, fGoldB)) and (close <= math.max(fGoldA, fGoldB))
bool inDeep = parentValid and not na(fDeepA) and not na(fDeepB) and (close >= math.min(fDeepA, fDeepB)) and (close <= math.max(fDeepA, fDeepB))

panelSz = switch i_panelSize
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    => size.small

panelHdr = switch i_panelSize
    "Tiny" => size.small
    "Small" => size.normal
    "Normal" => size.large
    "Large" => size.huge
    => size.normal

f_table_pos(string s) =>
    switch s
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

if barstate.islast
    table.set_position(dashboard, f_table_pos(i_patternPos))
    table.set_position(childDash, f_table_pos(i_childPos))
    if not i_showEdge
        table.clear(dashboard, 0, 0, 1, 9)
    if not i_showChildEdge
        table.clear(childDash, 0, 0, 1, 8)

if barstate.islast and i_showEdge
    table.cell(dashboard, 0, 0, "Pattern", text_color = #ffffff, text_size = panelHdr, text_font_family = font.family_monospace)
    table.cell(dashboard, 1, 0, "EDGE", text_color = trendC, text_size = panelHdr, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 1, "Trend", text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 1, parentValid ? (parentBull ? "▲ BULL" : "▼ BEAR") : "—", text_color = trendC, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 2, "Edge", text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 2, str.tostring(edgeScore) + "  " + edgeLabel, text_color = edgeColorF, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 3, "ALMA " + edgeChartTfLabel, text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 3, str.tostring(almaScore, "#.0"), text_color = almaScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 4, "EMA " + edgeChartTfLabel, text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 4, str.tostring(emaScore, "#.0"), text_color = emaScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 5, "VWAP", text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 5, str.tostring(vwapScore, "#.0"), text_color = vwapScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 6, "Prox", text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 6, str.tostring(proxScore, "#.0"), text_color = proxScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 7, "G-Zone", text_color = #8b949e, text_size = panelSz)
    gZoneText = inGolden ? "IN " + str.tostring(goldenMid, format.mintick) : "Waiting"
    table.cell(dashboard, 1, 7, gZoneText, text_color = inGolden ? #00e676 : #8b949e, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 8, "FibVWAP", text_color = #8b949e, text_size = panelSz)
    table.cell(dashboard, 1, 8, not na(fibVwap) ? str.tostring(fibVwap, format.mintick) : "—", text_color = #42a5f5, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(dashboard, 0, 9, "Legs", text_color = #8b949e, text_size = panelSz)
    legsN = childLegs.size() + (formingChild.active ? 1 : 0)
    table.cell(dashboard, 1, 9, str.tostring(legsN), text_color = #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)

if barstate.islast and i_showChildEdge
    color childTrendC = childEdgeBull ? i_bullC : i_bearC
    table.cell(childDash, 0, 0, "Child", text_color = #ffffff, text_size = panelHdr, text_font_family = font.family_monospace)
    table.cell(childDash, 1, 0, "EDGE", text_color = childTrendC, text_size = panelHdr, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 1, "Leg", text_color = #8b949e, text_size = panelSz)
    table.cell(childDash, 1, 1, childEdgeValid ? (childEdgeBull ? "▲ BULL" : "▼ BEAR") : "—", text_color = childTrendC, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 2, "Edge", text_color = #8b949e, text_size = panelSz)
    table.cell(childDash, 1, 2, childEdgeValid ? str.tostring(childEdgeScore) + "  " + childEdgeLabel : "—", text_color = childEdgeValid ? childEdgeColorF : #8b949e, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 3, "ALMA " + edgeChartTfLabel, text_color = #8b949e, text_size = panelSz)
    table.cell(childDash, 1, 3, str.tostring(childAlmaScore, "#.0"), text_color = childAlmaScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 4, "EMA " + edgeChartTfLabel, text_color = #8b949e, text_size = panelSz)
    table.cell(childDash, 1, 4, str.tostring(childEmaScore, "#.0"), text_color = childEmaScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 5, "VWAP", text_color = #8b949e, text_size = panelSz)
    table.cell(childDash, 1, 5, str.tostring(childVwapScore, "#.0"), text_color = childVwapScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 6, "Prox", text_color = #8b949e, text_size = panelSz)
    table.cell(childDash, 1, 6, str.tostring(childProxScore, "#.0"), text_color = childProxScore >= 15 ? #00e676 : #c9d1d9, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 7, "G-Zone", text_color = #8b949e, text_size = panelSz)
    childGz = inChildGolden ? "IN " + str.tostring(childGoldMid, format.mintick) : (childEdgeValid ? "Waiting" : "—")
    table.cell(childDash, 1, 7, childGz, text_color = inChildGolden ? #00e676 : #8b949e, text_size = panelSz, text_font_family = font.family_monospace)
    table.cell(childDash, 0, 8, "FibVWAP", text_color = #8b949e, text_size = panelSz)
    table.cell(childDash, 1, 8, not na(childVwap) ? str.tostring(childVwap, format.mintick) : "—", text_color = #26c6da, text_size = panelSz, text_font_family = font.family_monospace)

// ══════════════════════════════════════════════════════════════════
//                             ALERTS
// ══════════════════════════════════════════════════════════════════

alertcondition(inGolden, "Fib Trend Legs: Golden Zone Entry", "Price entered parent Fibonacci Golden Zone")
alertcondition(inDeep, "Fib Trend Legs: Deep Zone Entry", "Price entered parent Fibonacci Deep Zone")
alertcondition(edgeScore >= 75, "Fib Trend Legs: Strong Pattern Edge", "Pattern CT-fade Edge Score >= 75")
alertcondition(childEdgeScore >= 75, "Fib Trend Legs: Strong Child Edge", "Child CT-fade Edge Score >= 75")
bool crossParent0 = ta.cross(close, nz(f0, close))
bool crossParent100 = ta.cross(close, nz(f100, close))
alertcondition(parentValid and crossParent0, "Fib Trend Legs: Break 0%", "Price crossed parent Fibonacci 0% level")
alertcondition(parentValid and crossParent100, "Fib Trend Legs: Full Retrace", "Price crossed parent Fibonacci 100% level")
alertcondition(ms_TrendUp, "Fib Trend Legs: Trend Up", "Market structure trend changed to up")
alertcondition(ms_TrendDown, "Fib Trend Legs: Trend Down", "Market structure trend changed to down")
alertcondition(ms_BOS, "Fib Trend Legs: BOS", "BOS confirmed — child leg locked")
alertcondition(not na(ms) and ms.upsweep, "Fib Trend Legs: Upsweep (x)", "Upsweep liquidity grab")
alertcondition(not na(ms) and ms.dnsweep, "Fib Trend Legs: Dnsweep (x)", "Dnsweep liquidity grab")
bool crossFibVwap = ta.cross(close, nz(fibVwap, close))
alertcondition(parentValid and not na(fibVwap) and crossFibVwap, "Fib Trend Legs: Cross Fib VWAP", "Price crossed fib-anchored VWAP")
````
