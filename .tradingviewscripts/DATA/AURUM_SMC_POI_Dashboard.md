<!-- tradingview-pine-id: PUB;68664e775d484628aba61faa0784cc9c -->
<!-- tradingviewscripts-format: 1 -->
# AURUM SMC POI Dashboard

Source: https://www.tradingview.com/script/rNBszLzk-SMC-POI-Dashboard-by-LKBP/

## Description

SMC POI Dashboard — a non-repainting, multi-timeframe Smart Money Concepts indicator for TradingView (Pine v6), built for XAUUSD but symbol-agnostic.

It independently tracks market structure — confirmed swing highs/lows (HH/HL/LH/LL), body-close-only Break of Structure, active trading range, and protected levels — across five fixed timeframes (4H/1H/15M/5M/1M) using request.security(). On every confirmed BOS, it deterministically detects a Point of Interest (order block): the last 1–3 opposite-colored candles immediately preceding the break, combined into a single zone. Each timeframe keeps only its newest Bullish and Bearish POI, drawn as a color-coded box (distinct color per timeframe) anchored to its true origin candle. Zones turn gray and freeze when price wicks into them (Mitigated), and are deleted outright if price closes fully through (Invalidated).

Chart visuals (swing labels, BOS markers, range/protected lines, and POI boxes) can be filtered to show only the timeframe matching your current chart, keeping the chart clean. A floating dashboard summarizes trend, last BOS, range, and both POIs for all five timeframes plus current price and status (inside/outside a POI) at a glance.

---

## Source Code

````pine
//@version=6
indicator("AURUM SMC POI Dashboard", shorttitle="AURUM SMC", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, max_bars_back=500)

// ============================================================================
// AURUM SMC POI DASHBOARD
// Stage 1: COMPLETE MULTI-TIMEFRAME MARKET STRUCTURE MODULE (unchanged)
// Stage 2: DETERMINISTIC POI (ORDER BLOCK) DETECTION ENGINE
// ============================================================================
// Three engines:
//   1. MTF Structure + POI Engine (via request.security) - three fixed
//      timeframes (4H/1H/15M), each with fully isolated trend/BOS/
//      range/POI state. Feeds the dashboard AND the POI boxes drawn on the
//      chart (Engine 3). The Stage 1 trend/BOS/range calculations are
//      untouched; POI detection is purely additive.
//      (5M and 1M were dropped - fetching low-timeframe data via
//      request.security over long history was hitting TradingView's
//      memory limit, especially during Bar Replay. 15M is now the fastest
//      timeframe tracked, intended as the entry timeframe for a future
//      strategy version.)
//   2. Native Chart Engine - the same structure logic run natively at the
//      chart's own resolution. Unchanged from Stage 1: swing classification
//      (HH/HL/LH/LL), BOS lines/labels, the active trading range, and
//      protected levels.
//   3. POI Visualization - draws at most two boxes per timeframe (newest
//      active Bullish POI, newest active Bearish POI = 6 boxes max),
//      fetched from Engine 1. Each box is anchored to its true origin
//      candle(s) using bar_time (xloc.bar_time), so it displays correctly
//      regardless of the timeframe it was detected on.
//
// POI (Order Block) rule, applied per timeframe - fully deterministic:
//   1. Detect a confirmed body-close BOS (same rule as Stage 1: wicks are
//      ignored, only a body close beyond the last confirmed swing counts).
//   2. Walk backward from the BOS candle and collect the last 1-3
//      consecutive opposite-colored candles immediately preceding it.
//   3. Combine those candles into a single POI zone (highest high to
//      lowest low among them) and register it immediately - the BOS itself
//      is the only trigger, no confirmation lag.
//   4. If no opposite-colored candle immediately precedes the BOS, no POI
//      is registered for that BOS.
//   5. A new valid POI silently replaces the previous POI of the same
//      direction on that timeframe - only the newest is ever kept.
//   6. Mitigation: the first time price wicks back into a POI's zone, it is
//      marked Mitigated - the box stops extending (freezes in place) and
//      the label appends "(Mitigated)", but it keeps its timeframe color
//      and stays on the chart.
//   7. Invalidation: if price BODY CLOSES all the way through a POI's zone
//      (mitigated or not), the zone has fully failed and is deleted
//      outright.
//
// There is no displacement scoring, no ATR/body-size filtering, no
// consecutive strong-candle streak, and no internal FVG check - the BOS
// itself is the only trigger. Everything is derived from confirmed
// ta.pivothigh/ta.pivotlow values and candle body closes only, so nothing
// here can repaint.
// ============================================================================

// ---- Inputs ------------------------------------------------------------
grpStructure   = "Market Structure"
swingLength    = input.int(5, "Swing Length", minval=1, maxval=50, group=grpStructure)

grpTimeframes  = "Timeframes"
tf4H  = input.timeframe("240", "Timeframe 1 (4H)",  group=grpTimeframes)
tf1H  = input.timeframe("60",  "Timeframe 2 (1H)",  group=grpTimeframes)
tf15M = input.timeframe("15",  "Timeframe 3 (15M)", group=grpTimeframes)

grpVisuals        = "Visuals"
showSwingLabels    = input.bool(true, "Show Swing Labels (HH/HL/LH/LL)", group=grpVisuals)
maxSwingLabels     = input.int(20, "Max Swing Labels Visible", minval=5, maxval=100, group=grpVisuals)
showBOS            = input.bool(true, "Show BOS Lines + Labels", group=grpVisuals)
maxBosVisible      = input.int(5, "Max BOS Lines Visible (history)", minval=1, maxval=20, group=grpVisuals)
showRange          = input.bool(true, "Show Active Trading Range", group=grpVisuals)
showProtectedLevel = input.bool(true, "Show Protected Level", group=grpVisuals)

grpPOI               = "POI Detection"
showPOI              = input.bool(true, "Show POI Boxes", group=grpPOI)
poiFillTransparency  = input.int(85, "POI Fill Transparency", minval=80, maxval=90, group=grpPOI)
poiDisplayMode       = input.string("Current Chart Timeframe", "POI Display Mode", options=["Current Chart Timeframe", "All Timeframes"], group=grpPOI)

grpPOIColors   = "POI Colors (per timeframe)"
poiColor4H_Bull  = input.color(#006400, "4H Bullish - Dark Green",   group=grpPOIColors)
poiColor4H_Bear  = input.color(#8B0000, "4H Bearish - Dark Red",     group=grpPOIColors)
poiColor1H_Bull  = input.color(#50C878, "1H Bullish - Emerald",      group=grpPOIColors)
poiColor1H_Bear  = input.color(#DC143C, "1H Bearish - Crimson",      group=grpPOIColors)
poiColor15M_Bull = input.color(#008080, "15M Bullish - Teal",        group=grpPOIColors)
poiColor15M_Bear = input.color(#FF4500, "15M Bearish - Orange-Red",  group=grpPOIColors)

grpColors      = "Colors"
bullColor      = input.color(#089981, "Bullish Trend (Emerald Green)", group=grpColors)
bearColor      = input.color(#F23645, "Bearish Trend (Red)", group=grpColors)
rangeColor     = input.color(#2962FF, "Range (Blue)", group=grpColors)
protectedColor = input.color(#FF9800, "Protected Level (Orange)", group=grpColors)
neutralColor   = input.color(#787B86, "Neutral", group=grpColors)

grpDash        = "Dashboard"
showDashboard  = input.bool(true, "Show Dashboard", group=grpDash)
dashSectionColor = input.color(#FF9800, "Section Header Color (4H/1H/.../Market)", group=grpDash)

// ============================================================================
// ENGINE 1 - MTF Structure + Deterministic POI Detection
// ============================================================================
f_marketStructure(int swingLen) =>
    // ---- Stage 1 structure logic (unchanged) -------------------------------
    float pivotHigh = ta.pivothigh(high, swingLen, swingLen)
    float pivotLow  = ta.pivotlow(low, swingLen, swingLen)

    var float  lastSwingHigh = na
    var float  lastSwingLow  = na
    var int    trend         = 0       // 1 = Bullish, -1 = Bearish, 0 = Neutral
    var string lastBOS       = "None"
    var float  rangeHigh     = na
    var float  rangeLow      = na

    if not na(pivotHigh)
        lastSwingHigh := pivotHigh
    if not na(pivotLow)
        lastSwingLow := pivotLow

    bool bullBOS = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
    bool bearBOS = not na(lastSwingLow)  and close < lastSwingLow  and close[1] >= lastSwingLow

    if bullBOS
        trend := 1
        lastBOS := "Bullish"
        rangeLow  := lastSwingLow
        rangeHigh := high
        lastSwingHigh := na
    if bearBOS
        trend := -1
        lastBOS := "Bearish"
        rangeHigh := lastSwingHigh
        rangeLow  := low
        lastSwingLow := na

    if trend == 1 and not na(rangeHigh)
        rangeHigh := math.max(rangeHigh, high)
    if trend == -1 and not na(rangeLow)
        rangeLow := math.min(rangeLow, low)

    // ---- Stage 2: deterministic POI detection (additive) -------------------
    // On a confirmed BOS, walk backward and combine the last 1-3 consecutive
    // opposite-colored candles immediately preceding it into a POI zone.
    // No FVG gate, no confirmation lag - the BOS itself is the only trigger.
    var float bullPoiTop       = na
    var float bullPoiBottom    = na
    var int   bullPoiLeftTime  = na
    var bool  bullPoiMitigated = false
    var bool  bullPoiActive    = false

    var float bearPoiTop       = na
    var float bearPoiBottom    = na
    var int   bearPoiLeftTime  = na
    var bool  bearPoiMitigated = false
    var bool  bearPoiActive    = false

    // Mitigation / invalidation check against the currently active POIs.
    //   Mitigated  = price wicks back into the zone (a touch) - the zone
    //                stays on the chart, frozen in place, keeping its color.
    //   Invalidated = price BODY CLOSES all the way through the zone - the
    //                zone has fully failed and is removed outright, even if
    //                it was already mitigated.
    if bullPoiActive
        if close < bullPoiBottom
            bullPoiActive := false
        else if not bullPoiMitigated and low <= bullPoiTop and high >= bullPoiBottom
            bullPoiMitigated := true
    if bearPoiActive
        if close > bearPoiTop
            bearPoiActive := false
        else if not bearPoiMitigated and high >= bearPoiBottom and low <= bearPoiTop
            bearPoiMitigated := true

    // BOS trigger - walk backward for the origin and register the POI directly.
    if bullBOS
        bool bullOrigin1 = close[1] < open[1]
        bool bullOrigin2 = bullOrigin1 and close[2] < open[2]
        bool bullOrigin3 = bullOrigin2 and close[3] < open[3]
        int  bullOriginCount = bullOrigin3 ? 3 : bullOrigin2 ? 2 : bullOrigin1 ? 1 : 0
        if bullOriginCount > 0
            bullPoiTop      := bullOriginCount == 1 ? high[1] : bullOriginCount == 2 ? math.max(high[1], high[2]) : math.max(math.max(high[1], high[2]), high[3])
            bullPoiBottom   := bullOriginCount == 1 ? low[1]  : bullOriginCount == 2 ? math.min(low[1], low[2])   : math.min(math.min(low[1], low[2]), low[3])
            bullPoiLeftTime := time[bullOriginCount]
            bullPoiMitigated := false
            bullPoiActive    := true

    if bearBOS
        bool bearOrigin1 = close[1] > open[1]
        bool bearOrigin2 = bearOrigin1 and close[2] > open[2]
        bool bearOrigin3 = bearOrigin2 and close[3] > open[3]
        int  bearOriginCount = bearOrigin3 ? 3 : bearOrigin2 ? 2 : bearOrigin1 ? 1 : 0
        if bearOriginCount > 0
            bearPoiTop      := bearOriginCount == 1 ? high[1] : bearOriginCount == 2 ? math.max(high[1], high[2]) : math.max(math.max(high[1], high[2]), high[3])
            bearPoiBottom   := bearOriginCount == 1 ? low[1]  : bearOriginCount == 2 ? math.min(low[1], low[2])   : math.min(math.min(low[1], low[2]), low[3])
            bearPoiLeftTime := time[bearOriginCount]
            bearPoiMitigated := false
            bearPoiActive    := true

    [trend, lastBOS, rangeHigh, rangeLow, bullPoiTop, bullPoiBottom, bullPoiLeftTime, bullPoiMitigated, bullPoiActive, bearPoiTop, bearPoiBottom, bearPoiLeftTime, bearPoiMitigated, bearPoiActive]

[trend4H,  bos4H,  rangeHigh4H,  rangeLow4H,  bullTop4H,  bullBottom4H,  bullLeft4H,  bullMit4H,  bullAct4H,  bearTop4H,  bearBottom4H,  bearLeft4H,  bearMit4H,  bearAct4H]  = request.security(syminfo.tickerid, tf4H,  f_marketStructure(swingLength), lookahead=barmerge.lookahead_off)
[trend1H,  bos1H,  rangeHigh1H,  rangeLow1H,  bullTop1H,  bullBottom1H,  bullLeft1H,  bullMit1H,  bullAct1H,  bearTop1H,  bearBottom1H,  bearLeft1H,  bearMit1H,  bearAct1H]  = request.security(syminfo.tickerid, tf1H,  f_marketStructure(swingLength), lookahead=barmerge.lookahead_off)
[trend15M, bos15M, rangeHigh15M, rangeLow15M, bullTop15M, bullBottom15M, bullLeft15M, bullMit15M, bullAct15M, bearTop15M, bearBottom15M, bearLeft15M, bearMit15M, bearAct15M] = request.security(syminfo.tickerid, tf15M, f_marketStructure(swingLength), lookahead=barmerge.lookahead_off)

// ============================================================================
// ENGINE 2 - Native Chart Structure (drives all chart visuals) - UNCHANGED
// ============================================================================
float chartPivotHigh = ta.pivothigh(high, swingLength, swingLength)
float chartPivotLow  = ta.pivotlow(low, swingLength, swingLength)

var float lastSwingHigh    = na
var int   lastSwingHighBar = na
var float lastSwingLow     = na
var int   lastSwingLowBar  = na

// Persistent last classified value (never cleared by BOS) - used purely for
// HH/HL/LH/LL comparison, independent of BOS reference-level state.
var float prevSwingHighVal = na
var float prevSwingLowVal  = na

var int    trend        = 0
var string lastBOS       = "None"

var float protectedHigh = na
var float protectedLow  = na
var float rangeHigh     = na
var float rangeLow      = na

// ---- Drawing object state (reused every bar, never recreated per-bar) -----
var label[] swingLabels = array.new<label>()

var line  currentBosLine    = na
var label currentBosLabel   = na
var line[]  bosLineHistory  = array.new<line>()
var label[] bosLabelHistory = array.new<label>()

var line  devRangeLine  = na   // developing boundary of the active range (blue)
var label devRangeLabel = na
var line  protectedLine = na   // fixed/protected boundary of the active range (orange)
var label protectedLabel = na

// ---- Swing detection + classification --------------------------------------
if not na(chartPivotHigh)
    lastSwingHigh    := chartPivotHigh
    lastSwingHighBar := bar_index - swingLength
    string hhlh = na(prevSwingHighVal) ? "H" : (chartPivotHigh > prevSwingHighVal ? "HH" : "LH")
    prevSwingHighVal := chartPivotHigh
    if showSwingLabels
        label lbl = label.new(bar_index - swingLength, chartPivotHigh, hhlh, style=label.style_label_down, color=color.new(color.gray, 70), textcolor=color.gray, size=size.tiny)
        array.push(swingLabels, lbl)
        if array.size(swingLabels) > maxSwingLabels
            label.delete(array.shift(swingLabels))

if not na(chartPivotLow)
    lastSwingLow    := chartPivotLow
    lastSwingLowBar := bar_index - swingLength
    string hlll = na(prevSwingLowVal) ? "L" : (chartPivotLow > prevSwingLowVal ? "HL" : "LL")
    prevSwingLowVal := chartPivotLow
    if showSwingLabels
        label lbl2 = label.new(bar_index - swingLength, chartPivotLow, hlll, style=label.style_label_up, color=color.new(color.gray, 70), textcolor=color.gray, size=size.tiny)
        array.push(swingLabels, lbl2)
        if array.size(swingLabels) > maxSwingLabels
            label.delete(array.shift(swingLabels))

// ---- Break of Structure (body close only) -----------------------------------
bool bullBOS = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bool bearBOS = not na(lastSwingLow)  and close < lastSwingLow  and close[1] >= lastSwingLow

if bullBOS
    trend    := 1
    lastBOS  := "Bullish"
    protectedLow := lastSwingLow
    rangeLow  := protectedLow
    rangeHigh := high

    if showBOS
        if not na(currentBosLine)
            array.push(bosLineHistory, currentBosLine)
            array.push(bosLabelHistory, currentBosLabel)
            if array.size(bosLineHistory) > maxBosVisible
                line.delete(array.shift(bosLineHistory))
                label.delete(array.shift(bosLabelHistory))
        currentBosLine  := line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color=bullColor, style=line.style_dashed, width=1)
        currentBosLabel := label.new(bar_index, low, "BOS", style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.small)

    if showRange
        line.delete(protectedLine)
        line.delete(devRangeLine)
        label.delete(protectedLabel)
        label.delete(devRangeLabel)
        protectedLine  := line.new(lastSwingLowBar, rangeLow, bar_index, rangeLow, color=protectedColor, width=1)
        devRangeLine   := line.new(bar_index, rangeHigh, bar_index, rangeHigh, color=rangeColor, width=1, style=line.style_dotted)
        protectedLabel := label.new(bar_index, rangeLow, "Protected Low", style=label.style_label_left, color=protectedColor, textcolor=color.white, size=size.tiny)
        devRangeLabel  := label.new(bar_index, rangeHigh, "Range High", style=label.style_label_left, color=rangeColor, textcolor=color.white, size=size.tiny)

    lastSwingHigh := na   // require a fresh swing high before the next bullish BOS

if bearBOS
    trend    := -1
    lastBOS  := "Bearish"
    protectedHigh := lastSwingHigh
    rangeHigh := protectedHigh
    rangeLow  := low

    if showBOS
        if not na(currentBosLine)
            array.push(bosLineHistory, currentBosLine)
            array.push(bosLabelHistory, currentBosLabel)
            if array.size(bosLineHistory) > maxBosVisible
                line.delete(array.shift(bosLineHistory))
                label.delete(array.shift(bosLabelHistory))
        currentBosLine  := line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, color=bearColor, style=line.style_dashed, width=1)
        currentBosLabel := label.new(bar_index, high, "BOS", style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)

    if showRange
        line.delete(protectedLine)
        line.delete(devRangeLine)
        label.delete(protectedLabel)
        label.delete(devRangeLabel)
        protectedLine  := line.new(lastSwingHighBar, rangeHigh, bar_index, rangeHigh, color=protectedColor, width=1)
        devRangeLine   := line.new(bar_index, rangeLow, bar_index, rangeLow, color=rangeColor, width=1, style=line.style_dotted)
        protectedLabel := label.new(bar_index, rangeHigh, "Protected High", style=label.style_label_left, color=protectedColor, textcolor=color.white, size=size.tiny)
        devRangeLabel  := label.new(bar_index, rangeLow, "Range Low", style=label.style_label_left, color=rangeColor, textcolor=color.white, size=size.tiny)

    lastSwingLow := na    // require a fresh swing low before the next bearish BOS

// ---- Extend active drawing objects to the current bar ----------------------
if showBOS and not na(currentBosLine)
    line.set_x2(currentBosLine, bar_index)

if showRange and trend == 1 and not na(rangeHigh)
    rangeHigh := math.max(rangeHigh, high)
    if not na(devRangeLine)
        line.set_y1(devRangeLine, rangeHigh)
        line.set_y2(devRangeLine, rangeHigh)
        line.set_x2(devRangeLine, bar_index)
        line.set_x2(protectedLine, bar_index)
        label.set_xy(devRangeLabel, bar_index, rangeHigh)
        label.set_xy(protectedLabel, bar_index, rangeLow)
else if showRange and trend == -1 and not na(rangeLow)
    rangeLow := math.min(rangeLow, low)
    if not na(devRangeLine)
        line.set_y1(devRangeLine, rangeLow)
        line.set_y2(devRangeLine, rangeLow)
        line.set_x2(devRangeLine, bar_index)
        line.set_x2(protectedLine, bar_index)
        label.set_xy(devRangeLabel, bar_index, rangeLow)
        label.set_xy(protectedLabel, bar_index, rangeHigh)

if not showProtectedLevel
    line.delete(protectedLine)
    label.delete(protectedLabel)

// ============================================================================
// ENGINE 3 - POI Visualization (draws MTF POI boxes fetched via Engine 1)
// ============================================================================
// Reuses exactly one box + one label per (timeframe, direction) slot - 6
// slots max (3 timeframes x Bull/Bear). Boxes are anchored at their true
// origin candle(s) via xloc.bar_time (so MTF alignment is correct on the
// current chart) and extend right every bar until mitigated, at which point
// they freeze in place (keeping their timeframe color) instead of being
// deleted - only Invalidation removes a box outright.
f_updatePoiBox(box bId, label lblId, float top, float bottom, int leftTime, bool active, bool mitigated, color freshColor, int fillTransp, string dirText, string tfText) =>
    box   newB = bId
    label newL = lblId

    if not active
        if not na(bId)
            box.delete(bId)
            label.delete(lblId)
        newB := na
        newL := na
    else
        // Mitigated zones keep their timeframe color - only the label text
        // changes to "(Mitigated)" and the box freezes (stops extending).
        // Only Invalidation (handled above via `active`) removes a zone.
        color boxBorder = freshColor
        color boxBg     = color.new(freshColor, fillTransp)
        string txt = tfText + " " + dirText + " POI" + (mitigated ? " (Mitigated)" : "")
        bool isNew = na(bId) or top != box.get_top(bId) or bottom != box.get_bottom(bId)
        if isNew
            if not na(bId)
                box.delete(bId)
                label.delete(lblId)
            newB := box.new(leftTime, top, time, bottom, xloc=xloc.bar_time, border_color=boxBorder, bgcolor=boxBg)
            newL := label.new(leftTime, top, txt, xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.black, 0), textcolor=boxBorder, size=size.tiny)
        else
            if not mitigated
                box.set_right(newB, time)
            label.set_text(newL, txt)

    [newB, newL]

var box   bullBox4H = na
var label bullLbl4H = na
var box   bearBox4H = na
var label bearLbl4H = na
var box   bullBox1H = na
var label bullLbl1H = na
var box   bearBox1H = na
var label bearLbl1H = na
var box   bullBox15M = na
var label bullLbl15M = na
var box   bearBox15M = na
var label bearLbl15M = na

// When poiDisplayMode is "Current Chart Timeframe", only the timeframe slot
// matching the chart's own resolution is drawn - the other two are forced
// inactive (and therefore deleted if currently on screen), so switching the
// chart's timeframe automatically shows just that timeframe's POIs.
bool allTFs = poiDisplayMode == "All Timeframes"
bool matches4H  = allTFs or timeframe.period == tf4H
bool matches1H  = allTFs or timeframe.period == tf1H
bool matches15M = allTFs or timeframe.period == tf15M

if showPOI and barstate.islast
    [newBullBox4H, newBullLbl4H] = f_updatePoiBox(bullBox4H, bullLbl4H, bullTop4H, bullBottom4H, bullLeft4H, bullAct4H and matches4H, bullMit4H, poiColor4H_Bull, poiFillTransparency, "Bull", "4H")
    bullBox4H := newBullBox4H
    bullLbl4H := newBullLbl4H
    [newBearBox4H, newBearLbl4H] = f_updatePoiBox(bearBox4H, bearLbl4H, bearTop4H, bearBottom4H, bearLeft4H, bearAct4H and matches4H, bearMit4H, poiColor4H_Bear, poiFillTransparency, "Bear", "4H")
    bearBox4H := newBearBox4H
    bearLbl4H := newBearLbl4H

    [newBullBox1H, newBullLbl1H] = f_updatePoiBox(bullBox1H, bullLbl1H, bullTop1H, bullBottom1H, bullLeft1H, bullAct1H and matches1H, bullMit1H, poiColor1H_Bull, poiFillTransparency, "Bull", "1H")
    bullBox1H := newBullBox1H
    bullLbl1H := newBullLbl1H
    [newBearBox1H, newBearLbl1H] = f_updatePoiBox(bearBox1H, bearLbl1H, bearTop1H, bearBottom1H, bearLeft1H, bearAct1H and matches1H, bearMit1H, poiColor1H_Bear, poiFillTransparency, "Bear", "1H")
    bearBox1H := newBearBox1H
    bearLbl1H := newBearLbl1H

    [newBullBox15M, newBullLbl15M] = f_updatePoiBox(bullBox15M, bullLbl15M, bullTop15M, bullBottom15M, bullLeft15M, bullAct15M and matches15M, bullMit15M, poiColor15M_Bull, poiFillTransparency, "Bull", "15M")
    bullBox15M := newBullBox15M
    bullLbl15M := newBullLbl15M
    [newBearBox15M, newBearLbl15M] = f_updatePoiBox(bearBox15M, bearLbl15M, bearTop15M, bearBottom15M, bearLeft15M, bearAct15M and matches15M, bearMit15M, poiColor15M_Bear, poiFillTransparency, "Bear", "15M")
    bearBox15M := newBearBox15M
    bearLbl15M := newBearLbl15M

// ============================================================================
// DASHBOARD
// ============================================================================
f_trendText(int t) =>
    t == 1 ? "Bullish" : t == -1 ? "Bearish" : "Neutral"

f_trendColor(int t) =>
    t == 1 ? bullColor : t == -1 ? bearColor : neutralColor

f_bosColor(string b) =>
    b == "Bullish" ? bullColor : b == "Bearish" ? bearColor : neutralColor

f_priceStr(float p) =>
    na(p) ? "-" : str.tostring(p, format.mintick)

f_poiStr(float top, float bottom, bool active, bool mitigated) =>
    string result = "-"
    if active
        result := str.tostring(top, format.mintick) + " - " + str.tostring(bottom, format.mintick) + (mitigated ? " (Mitigated)" : " (Fresh)")
    result

var table dash = table.new(position.top_right, 2, 26, border_width=1, border_color=color.gray, bgcolor=color.new(#1E1E1E, 0))

f_dashTitle(table t, int row, string txt) =>
    table.cell(t, 0, row, txt, text_color=color.white, text_size=size.large, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, row, "", bgcolor=color.new(color.black, 0))

f_dashSection(table t, int row, string tfLabel, color sectionColor) =>
    table.cell(t, 0, row, tfLabel, text_color=sectionColor, text_size=size.normal, bgcolor=color.new(#2A2E39, 0))
    table.cell(t, 1, row, "", bgcolor=color.new(#2A2E39, 0))

f_dashRow(table t, int row, string label, string value, color valueColor) =>
    table.cell(t, 0, row, label, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, row, value, text_color=valueColor, text_size=size.small, bgcolor=color.new(color.black, 0))

f_dashTF(table t, int row, string tfLabel, color tfAccentColor, int tfTrend, string tfBos, float tfRangeHigh, float tfRangeLow, float bullTop, float bullBottom, bool bullActive, bool bullMitigated, float bearTop, float bearBottom, bool bearActive, bool bearMitigated) =>
    f_dashSection(t, row, tfLabel, tfAccentColor)
    f_dashRow(t, row + 1, "Trend", f_trendText(tfTrend), f_trendColor(tfTrend))
    f_dashRow(t, row + 2, "Last BOS", tfBos, f_bosColor(tfBos))
    f_dashRow(t, row + 3, "Range High", f_priceStr(tfRangeHigh), color.white)
    f_dashRow(t, row + 4, "Range Low", f_priceStr(tfRangeLow), color.white)
    f_dashRow(t, row + 5, "Bull POI", f_poiStr(bullTop, bullBottom, bullActive, bullMitigated), bullActive ? color.white : neutralColor)
    f_dashRow(t, row + 6, "Bear POI", f_poiStr(bearTop, bearBottom, bearActive, bearMitigated), bearActive ? color.white : neutralColor)
    row + 7

if showDashboard and barstate.islast
    int row = 0
    f_dashTitle(dash, row, "AURUM SMC")
    row += 1
    row := f_dashTF(dash, row, "4H",  poiColor4H_Bull,  trend4H,  bos4H,  rangeHigh4H,  rangeLow4H,  bullTop4H,  bullBottom4H,  bullAct4H,  bullMit4H,  bearTop4H,  bearBottom4H,  bearAct4H,  bearMit4H)
    row := f_dashTF(dash, row, "1H",  poiColor1H_Bull,  trend1H,  bos1H,  rangeHigh1H,  rangeLow1H,  bullTop1H,  bullBottom1H,  bullAct1H,  bullMit1H,  bearTop1H,  bearBottom1H,  bearAct1H,  bearMit1H)
    row := f_dashTF(dash, row, "15M", poiColor15M_Bull, trend15M, bos15M, rangeHigh15M, rangeLow15M, bullTop15M, bullBottom15M, bullAct15M, bullMit15M, bearTop15M, bearBottom15M, bearAct15M, bearMit15M)

    f_dashSection(dash, row, "Market", dashSectionColor)
    row += 1
    f_dashRow(dash, row, "Symbol", syminfo.ticker, color.white)
    row += 1
    f_dashRow(dash, row, "Price", f_priceStr(close), color.white)
    row += 1

    bool insideBull = (bullAct4H  and not bullMit4H  and close <= bullTop4H  and close >= bullBottom4H)  or
                       (bullAct1H  and not bullMit1H  and close <= bullTop1H  and close >= bullBottom1H)  or
                       (bullAct15M and not bullMit15M and close <= bullTop15M and close >= bullBottom15M)
    bool insideBear = (bearAct4H  and not bearMit4H  and close <= bearTop4H  and close >= bearBottom4H)  or
                       (bearAct1H  and not bearMit1H  and close <= bearTop1H  and close >= bearBottom1H)  or
                       (bearAct15M and not bearMit15M and close <= bearTop15M and close >= bearBottom15M)

    string currentStatus = insideBull ? "Inside Bullish POI" : insideBear ? "Inside Bearish POI" : "Outside POI"
    color  statusColor   = insideBull ? bullColor : insideBear ? bearColor : neutralColor

    f_dashRow(dash, row, "Current Status", currentStatus, statusColor)
````
