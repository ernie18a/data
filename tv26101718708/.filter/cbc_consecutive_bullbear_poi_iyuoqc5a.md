# CBC - Consecutive Bull/Bear POI

- url: https://www.tradingview.com/script/IYuoqc5A-CBC-Consecutive-Bull-Bear-POI/
- type: indicator
- pine_id: PUB;4ec722e1dd844155a6352ada5bf721b6
- version: 1.0

## Description

This indicator identifies POI based on a CBC (Candle-by-candle) strategy in bullish and bearish market.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tammybatubo101

//@version=6
indicator(
     "CBC - Consecutive Bull/Bear POI",
     shorttitle    = "CBC",
     overlay       = true,
     max_lines_count   = 500,
     max_boxes_count   = 500,
     max_labels_count  = 500
 )

// ============================================================
// INPUTS
// ============================================================
g_tf      = "Timeframes"
useChart  = input.bool(true, "Detect on chart timeframe",          group=g_tf)
useHTF1   = input.bool(true, "Enable Higher Timeframe 1",          group=g_tf)
htf1      = input.timeframe("60",  "    HTF 1",                    group=g_tf)
useHTF2   = input.bool(true, "Enable Higher Timeframe 2",          group=g_tf)
htf2      = input.timeframe("240", "    HTF 2",                    group=g_tf)

g_dir     = "Direction"
showBull  = input.bool(true, "Show Bullish POI", group=g_dir)
showBear  = input.bool(true, "Show Bearish POI", group=g_dir)

g_chart   = "Chart TF Colors"
bullLineC = input.color(color.new(#26a69a,  0), "Bullish line", group=g_chart)
bullBoxC  = input.color(color.new(#26a69a, 80), "Bullish box",  group=g_chart)
bearLineC = input.color(color.new(#ef5350,  0), "Bearish line", group=g_chart)
bearBoxC  = input.color(color.new(#ef5350, 80), "Bearish box",  group=g_chart)

g_h1      = "HTF 1 Colors"
bullLineH1 = input.color(color.new(#00c853,  0), "Bullish line", group=g_h1)
bullBoxH1  = input.color(color.new(#00c853, 75), "Bullish box",  group=g_h1)
bearLineH1 = input.color(color.new(#d50000,  0), "Bearish line", group=g_h1)
bearBoxH1  = input.color(color.new(#d50000, 75), "Bearish box",  group=g_h1)

g_h2      = "HTF 2 Colors"
bullLineH2 = input.color(color.new(#00b0ff,  0), "Bullish line", group=g_h2)
bullBoxH2  = input.color(color.new(#00b0ff, 70), "Bullish box",  group=g_h2)
bearLineH2 = input.color(color.new(#aa00ff,  0), "Bearish line", group=g_h2)
bearBoxH2  = input.color(color.new(#aa00ff, 70), "Bearish box",  group=g_h2)

g_style       = "Style"
drawMode      = input.string("Line only", "Draw style",
     options=["Line only", "Box only", "Box + Line"], group=g_style)
extendForever = input.bool(true,  "Extend POIs to the right (until mitigated)", group=g_style)
extBars       = input.int(20, "Bars to extend (if not forever)", 1, 5000, group=g_style)
mitigateMode  = input.string("Wick", "Mitigation type",
     options=["Wick", "Body close", "None"], group=g_style)
onMitigate    = input.string("Stop extending", "On mitigation",
     options=["Stop extending", "Delete drawing"], group=g_style)
showLabels    = input.bool(true,  "Show \"CBC\" label on line", group=g_style)
labelText     = input.string("CBC", "Label text", group=g_style)
lineWidth     = input.int(1, "Line width", 1, 5, group=g_style)
maxPois       = input.int(80, "Max active POIs (oldest pruned)", 1, 500, group=g_style)

g_alerts   = "Alerts"
showAlerts = input.bool(true, "Fire alerts on new POI", group=g_alerts)

// ============================================================
// PATTERN HELPERS
// ============================================================
// candle 1 = older, candle 2 = newer (immediately after candle 1)
// Candle sizes do NOT matter — only direction and close progression.
//
// Bullish CBC:
//   - both candles bullish (close > open)
//   - candle 2 closes ABOVE candle 1's close       (close2 > close1)
//   - candle 2's low does NOT break candle 1's low (low2 >= low1)
//   - candle 2's HIGHEST part is above candle 1's highest part (high2 > high1)
//   - POI level = low2
//   Validity is then resolved per bar going forward:
//     - touch  : low <= low2          -> POI confirmed (mitigation behavior)
//     - break  : high > high2         -> POI invalidated (deleted)
isBullPOI(float o1, float c1, float h1, float l1,
          float o2, float c2, float h2, float l2) =>
    (c1 > o1) and (c2 > o2) and (c2 > c1) and (l2 >= l1) and (h2 > h1)

// Bearish CBC: mirror image
//   - both candles bearish (close < open)
//   - candle 2 closes BELOW candle 1's close         (close2 < close1)
//   - candle 2's high does NOT break candle 1's high (high2 <= high1)
//   - candle 2's LOWEST part is below candle 1's lowest part (low2 < low1)
//   - POI level = high2
//   Validity:
//     - touch  : high >= high2        -> POI confirmed
//     - break  : low < low2           -> POI invalidated
isBearPOI(float o1, float c1, float h1, float l1,
          float o2, float c2, float h2, float l2) =>
    (c1 < o1) and (c2 < o2) and (c2 < c1) and (h2 <= h1) and (l2 < l1)

// ============================================================
// POI STATE (shared list across all timeframes)
// ============================================================
type POI
    bool   isBull
    float  level         // POI line price (low2 for bull, high2 for bear)
    float  extreme       // candle 2's high (bull) or low (bear) — break invalidates
    int    startBar
    bool   active
    line   ln
    box    bx
    label  lb

var array<POI> pois = array.new<POI>()

// Create a new POI drawing and register it.
//   isBull   - direction
//   level    - POI price (low2 for bull, high2 for bear)
//   top, bot - box vertical bounds (close1↔level)
//   extreme  - candle 2's opposite extreme (high2 for bull, low2 for bear)
//   startBar - chart bar_index to anchor the left edge
drawPOI(bool isBull, float level, float top, float bot, float extreme, int startBar,
       color cLine, color cBox) =>
    // Prune oldest if we hit cap
    if array.size(pois) >= maxPois
        old = array.shift(pois)
        if not na(old.ln)
            line.delete(old.ln)
        if not na(old.bx)
            box.delete(old.bx)
        if not na(old.lb)
            label.delete(old.lb)

    rightX = extendForever ? bar_index : startBar + extBars
    xtnd   = extendForever ? extend.right : extend.none

    line  ln = na
    box   bx = na
    label lb = na

    if drawMode != "Box only"
        ln := line.new(startBar, level, rightX, level,
             color=cLine, width=lineWidth, extend=xtnd)

    if drawMode != "Line only"
        bx := box.new(startBar, top, rightX, bot,
             border_color=color.new(cLine, 60), bgcolor=cBox, extend=xtnd)

    if showLabels
        // Float the "CBC" text on the line itself (no bubble / no arrow)
        labelX = startBar + 2
        lb := label.new(labelX, level, labelText,
             style    = label.style_none,
             textcolor= cLine,
             size     = size.small)

    p = POI.new(isBull=isBull, level=level, extreme=extreme,
                 startBar=startBar, active=true,
                 ln=ln, bx=bx, lb=lb)
    array.push(pois, p)

// ============================================================
// CHART TF DETECTION
// ============================================================
// On a confirmed bar, evaluate using the previous TWO closed candles:
//   candle 1 -> bar [2]   (older)
//   candle 2 -> bar [1]   (most recently closed)
// Drawing anchors at bar_index - 1 (the candle-2 bar).
if useChart and barstate.isconfirmed
    // candle 1 = [1] (older), candle 2 = current bar [0] (just closed)
    o1 = open[1]
    c1 = close[1]
    h1 = high[1]
    l1 = low[1]
    o2 = open
    c2 = close
    h2 = high
    l2 = low

    if showBull and isBullPOI(o1, c1, h1, l1, o2, c2, h2, l2)
        // extreme = h2 (breaking above invalidates)
        drawPOI(true,  l2, c1, l2, h2, bar_index, bullLineC, bullBoxC)
        if showAlerts
            alert("CBC Bullish POI on chart TF @ " + str.tostring(l2, format.mintick),
                 alert.freq_once_per_bar_close)

    if showBear and isBearPOI(o1, c1, h1, l1, o2, c2, h2, l2)
        // extreme = l2 (breaking below invalidates)
        drawPOI(false, h2, h2, c1, l2, bar_index, bearLineC, bearBoxC)
        if showAlerts
            alert("CBC Bearish POI on chart TF @ " + str.tostring(h2, format.mintick),
                 alert.freq_once_per_bar_close)

// ============================================================
// HTF 1 DETECTION
// ============================================================
// candle 1 = HTF [1] (older), candle 2 = HTF [0] (last closed)
[h1_o1, h1_c1, h1_l1, h1_h1,
 h1_o2, h1_c2, h1_l2, h1_h2, h1_t] =
     request.security(syminfo.tickerid, htf1,
         [open[1], close[1], low[1], high[1],
          open,    close,    low,    high,    time],
         lookahead=barmerge.lookahead_off)

isNewH1 = useHTF1 and barstate.isconfirmed and ta.change(h1_t) != 0

// Anchor HTF line back at candle 2's start (≈ 1 HTF bar in the past)
chartSecs   = timeframe.in_seconds(timeframe.period)
barsBackH1  = chartSecs > 0 ? math.max(1, int(math.round(timeframe.in_seconds(htf1) / chartSecs))) : 1
anchorH1    = math.max(0, bar_index - barsBackH1)

if isNewH1 and showBull and isBullPOI(h1_o1, h1_c1, h1_h1, h1_l1, h1_o2, h1_c2, h1_h2, h1_l2)
    drawPOI(true,  h1_l2, h1_c1, h1_l2, h1_h2, anchorH1, bullLineH1, bullBoxH1)
    if showAlerts
        alert("CBC Bullish POI on " + htf1 + " @ " + str.tostring(h1_l2, format.mintick),
             alert.freq_once_per_bar_close)

if isNewH1 and showBear and isBearPOI(h1_o1, h1_c1, h1_h1, h1_l1, h1_o2, h1_c2, h1_h2, h1_l2)
    drawPOI(false, h1_h2, h1_h2, h1_c1, h1_l2, anchorH1, bearLineH1, bearBoxH1)
    if showAlerts
        alert("CBC Bearish POI on " + htf1 + " @ " + str.tostring(h1_h2, format.mintick),
             alert.freq_once_per_bar_close)

// ============================================================
// HTF 2 DETECTION
// ============================================================
[h2_o1, h2_c1, h2_l1, h2_h1,
 h2_o2, h2_c2, h2_l2, h2_h2, h2_t] =
     request.security(syminfo.tickerid, htf2,
         [open[1], close[1], low[1], high[1],
          open,    close,    low,    high,    time],
         lookahead=barmerge.lookahead_off)

isNewH2 = useHTF2 and barstate.isconfirmed and ta.change(h2_t) != 0

barsBackH2 = chartSecs > 0 ? math.max(1, int(math.round(timeframe.in_seconds(htf2) / chartSecs))) : 1
anchorH2   = math.max(0, bar_index - barsBackH2)

if isNewH2 and showBull and isBullPOI(h2_o1, h2_c1, h2_h1, h2_l1, h2_o2, h2_c2, h2_h2, h2_l2)
    drawPOI(true,  h2_l2, h2_c1, h2_l2, h2_h2, anchorH2, bullLineH2, bullBoxH2)
    if showAlerts
        alert("CBC Bullish POI on " + htf2 + " @ " + str.tostring(h2_l2, format.mintick),
             alert.freq_once_per_bar_close)

if isNewH2 and showBear and isBearPOI(h2_o1, h2_c1, h2_h1, h2_l1, h2_o2, h2_c2, h2_h2, h2_l2)
    drawPOI(false, h2_h2, h2_h2, h2_c1, h2_l2, anchorH2, bearLineH2, bearBoxH2)
    if showAlerts
        alert("CBC Bearish POI on " + htf2 + " @ " + str.tostring(h2_h2, format.mintick),
             alert.freq_once_per_bar_close)

// ============================================================
// VALIDATION / MITIGATION
//   Each bar after candle 2 closed, we run a race for every active POI:
//     - touched : price reaches the POI level   -> CBC confirmed
//                 react per `onMitigate` (stop extending / delete)
//     - broken  : price breaks candle 2 extreme -> CBC INVALID
//                 always delete the drawing
//   Inside-bar (neither touch nor break) -> keep watching.
// ============================================================
if array.size(pois) > 0
    n = array.size(pois)
    for i = 0 to n - 1
        p = array.get(pois, i)
        // skip POIs that are no longer being tracked, and skip the bar of
        // creation (otherwise candle 2 itself would trivially register a touch).
        if p.active and bar_index > p.startBar
            bool touched = false
            bool broken  = false

            if p.isBull
                touched := mitigateMode == "Wick"       ? (low  <= p.level) :
                           mitigateMode == "Body close" ? (close < p.level) : false
                broken  := high > p.extreme
            else
                touched := mitigateMode == "Wick"       ? (high >= p.level) :
                           mitigateMode == "Body close" ? (close > p.level) : false
                broken  := low  < p.extreme

            if touched
                // ── valid CBC: price returned to the POI level ──
                p.active := false
                if onMitigate == "Delete drawing"
                    if not na(p.ln)
                        line.delete(p.ln)
                        p.ln := na
                    if not na(p.bx)
                        box.delete(p.bx)
                        p.bx := na
                    if not na(p.lb)
                        label.delete(p.lb)
                        p.lb := na
                else
                    // freeze right edge at the touch bar
                    if not na(p.ln)
                        line.set_x2(p.ln, bar_index)
                        line.set_extend(p.ln, extend.none)
                    if not na(p.bx)
                        box.set_right(p.bx, bar_index)
                        box.set_extend(p.bx, extend.none)
                array.set(pois, i, p)
            else if broken
                // ── invalidated: candle 2 extreme broken before any touch ──
                p.active := false
                if not na(p.ln)
                    line.delete(p.ln)
                    p.ln := na
                if not na(p.bx)
                    box.delete(p.bx)
                    p.bx := na
                if not na(p.lb)
                    label.delete(p.lb)
                    p.lb := na
                array.set(pois, i, p)
            else if extendForever
                // ── inside bar: keep extending the line/box right edge ──
                if not na(p.ln)
                    line.set_x2(p.ln, bar_index)
                if not na(p.bx)
                    box.set_right(p.bx, bar_index)

// ============================================================
// ALERT CONDITIONS (so users can wire alerts via UI)
// ============================================================
chartBull = useChart and barstate.isconfirmed and showBull and
     isBullPOI(open[1], close[1], high[1], low[1],  open, close, high, low)
chartBear = useChart and barstate.isconfirmed and showBear and
     isBearPOI(open[1], close[1], high[1], low[1],  open, close, high, low)

alertcondition(chartBull, title="CBC Chart Bullish POI",  message="CBC Bullish POI (chart TF)")
alertcondition(chartBear, title="CBC Chart Bearish POI",  message="CBC Bearish POI (chart TF)")
alertcondition(isNewH1 and showBull and isBullPOI(h1_o1, h1_c1, h1_h1, h1_l1, h1_o2, h1_c2, h1_h2, h1_l2),
     title="CBC HTF1 Bullish POI", message="CBC Bullish POI (HTF1)")
alertcondition(isNewH1 and showBear and isBearPOI(h1_o1, h1_c1, h1_h1, h1_l1, h1_o2, h1_c2, h1_h2, h1_l2),
     title="CBC HTF1 Bearish POI", message="CBC Bearish POI (HTF1)")
alertcondition(isNewH2 and showBull and isBullPOI(h2_o1, h2_c1, h2_h1, h2_l1, h2_o2, h2_c2, h2_h2, h2_l2),
     title="CBC HTF2 Bullish POI", message="CBC Bullish POI (HTF2)")
alertcondition(isNewH2 and showBear and isBearPOI(h2_o1, h2_c1, h2_h1, h2_l1, h2_o2, h2_c2, h2_h2, h2_l2),
     title="CBC HTF2 Bearish POI", message="CBC Bearish POI (HTF2)")
````
