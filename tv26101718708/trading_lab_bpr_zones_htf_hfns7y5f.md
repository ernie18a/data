# Trading Lab - BPR Zones HTF

- url: https://www.tradingview.com/script/HfNS7y5F-Trading-Lab-BPR-Zones-HTF/
- type: indicator
- pine_id: PUB;2ed295d558f940dcb3c3740ada9f4b1a
- version: 1.0

## Description

Trading Lab - BPR Zones HTF is an indicator designed to highlight Balanced Price Range zones from higher timeframes on the current chart.

The script helps traders identify potential reaction areas, imbalance zones, and higher timeframe context. It plots the selected HTF zones directly on the chart so traders can analyze price behavior around these levels more clearly.

Users can adjust the higher timeframe and display settings according to their own trading workflow.

This script is intended for educational and analytical purposes only. It does not provide financial advice, buy or sell recommendations, or guaranteed trading signals. Traders should use it together with their own analysis and proper risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trading Lab — BPR (Balanced Price Range) zones — HTF (no session)

//@version=6
indicator("Trading Lab — BPR Zones (HTF)", overlay = true,
          max_boxes_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ===========================================================================
// INPUTS
// ===========================================================================
grpDetect       = "זיהוי BPR"
minFvgSizeUser  = input.float(0.0, "גודל מינימלי ל-FVG (0 = אוטומטי לפי TF)",
                              minval = 0.0, step = 0.5, group = grpDetect)
bprMaxBarGap    = input.int(50, "מרווח מקסימלי בין FVG ל-FVG (נרות)",
                            minval = 1, maxval = 500, group = grpDetect)

grpFilter       = "סינון תצוגה"
allowSharedFvg  = input.bool(true, "אפשר BPR משורשר (FVG משותף)", group = grpFilter)
dupTol          = input.float(0.0, "טולרנס דדופ לאזורים כמעט-זהים (0 = אוטומטי)",
                              minval = 0.0, step = 0.25, group = grpFilter)
tightBprOnly    = input.bool(false, "רק BPR צמודים", group = grpFilter)
tightBprMaxGap  = input.int(10, "מרווח מקסימלי ל-BPR צמוד (נרות)",
                            minval = 1, maxval = 500, group = grpFilter)
showAllCandidates = input.bool(false, "הצג גם חפיפות משניות (רק כשהשרשור כבוי)",
                               group = grpFilter)
nearOnly        = input.bool(false, "הצג רק BPR קרובים למחיר", group = grpFilter)
maxDistPct      = input.float(2.0, "מרחק מקסימלי מהמחיר (% מהמחיר)",
                              minval = 0.1, step = 0.5, group = grpFilter)

grpVis          = "תצוגה — צבעים"
bullFill        = input.color(color.new(#86efac, 82), "מילוי BPR עולה", group = grpVis)
bullBorder      = input.color(color.new(#4ade80, 45), "גבול BPR עולה", group = grpVis)
bearFill        = input.color(color.new(#fca5a5, 82), "מילוי BPR יורד", group = grpVis)
bearBorder      = input.color(color.new(#f87171, 45), "גבול BPR יורד", group = grpVis)
candidateFill   = input.color(color.new(#c4b5fd, 90), "מילוי BPR משני", group = grpVis)
candidateBorder = input.color(color.new(#a78bfa, 60), "גבול BPR משני", group = grpVis)
varyStackShade  = input.bool(true, "גוון שונה ל-BPR חופפים (stack)", group = grpVis)
stackShadeStep  = input.int(7, "תוספת שקיפות לכל שכבת חפיפה",
                            minval = 0, maxval = 30, group = grpVis)
showLabel       = input.bool(true, "תווית מספר נרות על הקופסה", group = grpVis)
hideMitigated   = input.bool(false, "הסתר BPR שטופלו (מוטרפלים)", group = grpVis)

grpAlert        = "התראות"
alertImminent   = input.bool(true, "התראה: BPR מתקרב (intrabar, לפני סגירה)", group = grpAlert)
alertConfirmed  = input.bool(true, "התראה: BPR נוצר", group = grpAlert)
alertEntered    = input.bool(true, "התראה: מחיר נכנס ל-BPR", group = grpAlert)
alertRespectFilters = input.bool(true,
                      "התראות לפי הסינון התצוגתי (צמוד/ראשי/קרוב)", group = grpAlert)
imminentLeadMin = input.float(30.0,
                      "התראת 'BPR מתקרב' — דקות לפני סגירת הנר",
                      minval = 0.1, step = 1.0, group = grpAlert)

// ===========================================================================
// AUTO MIN-FVG SIZE BY TIMEFRAME (MNQ-oriented defaults — override per instrument)
// ===========================================================================
defaultMinFvg = switch timeframe.period
    "1"   => 1.0
    "5"   => 2.0
    "15"  => 3.0
    "30"  => 4.0
    "60"  => 6.0
    "120" => 8.0
    "240" => 12.0
    "D"   => 25.0
    "W"   => 50.0
    "M"   => 100.0
    =>       5.0

minFvgSize = minFvgSizeUser > 0.0 ? minFvgSizeUser : defaultMinFvg
effDupTol  = dupTol > 0.0 ? dupTol : minFvgSize * 0.5

// ===========================================================================
// TYPES
// ===========================================================================
type FVG
    int   endIdx        // bar_index of C3 (the bar that completes the FVG)
    float top           // upper edge of the gap
    float bot           // lower edge of the gap
    bool  isBull
    bool  usedInBpr     // true after this FVG has been claimed by a primary BPR (used-once mode only)

type Bpr
    box   b             // visual box (mutable right edge)
    label lbl           // optional gap-count label
    int   formationIdx  // bar_index where BPR formed (= second FVG's endIdx)
    int   barGap        // second.endIdx - first.endIdx
    float top
    float bot
    bool  isPrimary
    bool  mitigated
    bool  entered       // true once price re-entered the BPR zone (entered alert fired)
    bool  isBull        // direction = polarity of the FVG that completed the BPR
    int   stackLvl      // how many active BPRs already overlapped this zone at creation

// ===========================================================================
// STATE (persistent across bars)
// ===========================================================================
var array<FVG> bullFVGs = array.new<FVG>()
var array<FVG> bearFVGs = array.new<FVG>()
var array<Bpr> bprs     = array.new<Bpr>()

// ===========================================================================
// FVG DETECTION — 3-bar pattern, current bar is C3
// ===========================================================================
bullGap = low - high[2]
bearGap = low[2] - high

bullFvgFormed = bullGap > 0 and bullGap >= minFvgSize
bearFvgFormed = bearGap > 0 and bearGap >= minFvgSize

if bullFvgFormed and barstate.isconfirmed
    bullFVGs.push(FVG.new(bar_index, low, high[2], true, false))

if bearFvgFormed and barstate.isconfirmed
    bearFVGs.push(FVG.new(bar_index, low[2], high, false, false))

// ===========================================================================
// GC: drop FVGs older than the max bar gap (cannot pair anymore)
// ===========================================================================
gcStale(array<FVG> arr) =>
    while arr.size() > 0 and (bar_index - arr.get(0).endIdx) > bprMaxBarGap
        arr.shift()

gcStale(bullFVGs)
gcStale(bearFVGs)

// ===========================================================================
// BPR VISIBILITY — applies current input filters; safe to call per-bar.
//   Includes the proximity filter (distance from current close) and the
//   per-stack shade variation (deeper overlap = more transparent).
// ===========================================================================
applyVisibility(Bpr bpr) =>
    priceDist = close < bpr.bot ? bpr.bot - close : (close > bpr.top ? close - bpr.top : 0.0)
    nearOk = not nearOnly or priceDist <= close * maxDistPct / 100.0
    show = (not tightBprOnly or bpr.barGap <= tightBprMaxGap) and (allowSharedFvg or showAllCandidates or bpr.isPrimary) and (not hideMitigated or not bpr.mitigated) and nearOk
    baseFill   = bpr.isPrimary ? (bpr.isBull ? bullFill : bearFill) : candidateFill
    baseBorder = bpr.isPrimary ? (bpr.isBull ? bullBorder : bearBorder) : candidateBorder
    extraT     = varyStackShade ? bpr.stackLvl * stackShadeStep : 0
    fillC      = color.new(baseFill, math.min(95, color.t(baseFill) + extraT))
    borderC    = color.new(baseBorder, math.min(95, color.t(baseBorder) + extraT))
    if show
        box.set_bgcolor(bpr.b, fillC)
        box.set_border_color(bpr.b, borderC)
        if not na(bpr.lbl)
            label.set_textcolor(bpr.lbl, borderC)
    else
        invisible = color.new(color.gray, 100)
        box.set_bgcolor(bpr.b, invisible)
        box.set_border_color(bpr.b, invisible)
        if not na(bpr.lbl)
            label.set_textcolor(bpr.lbl, invisible)

// ===========================================================================
// DEDUP — skip a near-identical, still-active BPR zone (shared-FVG mode only)
// ===========================================================================
isDupBpr(float t, float b) =>
    bool dup = false
    for ex in bprs
        if not ex.mitigated and math.abs(ex.top - t) <= effDupTol and math.abs(ex.bot - b) <= effDupTol
            dup := true
    dup

// ===========================================================================
// STACK COUNT — how many active BPRs already overlap this price range
// ===========================================================================
stackCount(float t, float b) =>
    int c = 0
    for ex in bprs
        if not ex.mitigated and ex.bot <= t and ex.top >= b
            c += 1
    c

// ===========================================================================
// BPR CREATION — called once per newly-formed FVG, scans opposite array
//   No session gating (HTF version). Direction = polarity of the completing FVG.
//   allowSharedFvg=true → every distinct overlap is a primary BPR (chained BPRs
//   shown), with light dedup. allowSharedFvg=false → legacy used-once behaviour.
// ===========================================================================
createBprsForNewFvg(FVG newFvg, array<FVG> opposites) =>
    bool createdVisible = false
    for other in opposites
        barGap = newFvg.endIdx - other.endIdx
        if barGap > 0 and barGap <= bprMaxBarGap
            overlapTop = math.min(newFvg.top, other.top)
            overlapBot = math.max(newFvg.bot, other.bot)
            overlapSz  = overlapTop - overlapBot
            isDup = allowSharedFvg and isDupBpr(overlapTop, overlapBot)
            if overlapSz >= minFvgSize and not isDup
                isPrimary = allowSharedFvg ? true : (not newFvg.usedInBpr and not other.usedInBpr)
                if isPrimary and not allowSharedFvg
                    newFvg.usedInBpr := true
                    other.usedInBpr  := true
                bprIsBull = newFvg.isBull
                stk = stackCount(overlapTop, overlapBot)
                initFill   = isPrimary ? (bprIsBull ? bullFill : bearFill) : candidateFill
                initBorder = isPrimary ? (bprIsBull ? bullBorder : bearBorder) : candidateBorder
                leftIdx = math.min(newFvg.endIdx, other.endIdx) - 2
                newBox = box.new(leftIdx, overlapTop, bar_index, overlapBot, border_color = initBorder, border_width = 1, bgcolor = initFill, xloc = xloc.bar_index, extend = extend.none)
                label newLbl = na
                if showLabel
                    newLbl := label.new(x = newFvg.endIdx, y = overlapTop, text = str.tostring(barGap) + "n", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(color.gray, 100), textcolor = initBorder, style = label.style_label_down, size = size.small)
                newBpr = Bpr.new(newBox, newLbl, newFvg.endIdx, barGap, overlapTop, overlapBot, isPrimary, false, false, bprIsBull, stk)
                bprs.push(newBpr)
                applyVisibility(newBpr)
                visibleNow = (not tightBprOnly or barGap <= tightBprMaxGap) and (allowSharedFvg or showAllCandidates or isPrimary)
                if (not alertRespectFilters) or visibleNow
                    createdVisible := true
    createdVisible

// Bar-level alert flags (reset every bar)
bool sigImminent  = false
bool sigConfirmed = false
bool sigEntered   = false

if bullFvgFormed and barstate.isconfirmed
    if createBprsForNewFvg(bullFVGs.get(bullFVGs.size() - 1), bearFVGs)
        sigConfirmed := true

if bearFvgFormed and barstate.isconfirmed
    if createBprsForNewFvg(bearFVGs.get(bearFVGs.size() - 1), bullFVGs)
        sigConfirmed := true

// ===========================================================================
// MITIGATION & EXTEND — on every bar after formation
//   case A: close out of zone AND bar fully engulfs zone
//   case B: bar entirely outside zone (gap)
// ===========================================================================
if barstate.isconfirmed
    for bpr in bprs
        if not bpr.mitigated and bar_index > bpr.formationIdx
            engulfClose = (close > bpr.top or close < bpr.bot) and (high >= bpr.top and low <= bpr.bot)
            gapOver     = low > bpr.top or high < bpr.bot
            if engulfClose or gapOver
                bpr.mitigated := true
                box.set_right(bpr.b, bar_index)
                applyVisibility(bpr)
            else
                box.set_right(bpr.b, bar_index)

// ===========================================================================
// IMMINENT BPR — intra-bar early warning, ~N minutes before the bar closes.
//   The currently-forming bar is treated as the C3 of a prospective FVG.
//   If, right now, that prospective gap overlaps an opposite active FVG within
//   range, a BPR would complete when this bar closes → fire early.
//   Uses alert() with alert.freq_once_per_bar so it fires on the FIRST tick the
//   condition holds (~N min before close) regardless of any UI frequency setting.
//   Intra-bar = prediction; the bar may still change before it closes.
// ===========================================================================
checkImminent(float gapTop, float gapBot, array<FVG> opposites) =>
    bool found = false
    for other in opposites
        barGap = bar_index - other.endIdx
        passGap = barGap > 0 and barGap <= bprMaxBarGap and (not (alertRespectFilters and tightBprOnly) or barGap <= tightBprMaxGap)
        if passGap
            ot = math.min(gapTop, other.top)
            ob = math.max(gapBot, other.bot)
            if (ot - ob) >= minFvgSize
                found := true
    found

msToClose = time_close - timenow
nearClose = msToClose > 0 and msToClose <= imminentLeadMin * 60 * 1000

if nearClose
    if (low - high[2]) >= minFvgSize and checkImminent(low, high[2], bearFVGs)
        sigImminent := true
    if (low[2] - high) >= minFvgSize and checkImminent(low[2], high, bullFVGs)
        sigImminent := true

// "Price entered an existing BPR" — on confirmed bars only
if barstate.isconfirmed
    for bpr in bprs
        if not bpr.entered and not bpr.mitigated and bar_index > bpr.formationIdx and high >= bpr.bot and low <= bpr.top
            visible = (not alertRespectFilters) or ((not tightBprOnly or bpr.barGap <= tightBprMaxGap) and (allowSharedFvg or showAllCandidates or bpr.isPrimary))
            if visible
                bpr.entered := true
                sigEntered  := true

// ===========================================================================
// ALERTS — unified alert() calls. Create ONE alert on the indicator with the
//   condition "Any alert() function call". freq_once_per_bar lets imminent fire
//   intrabar (before close); confirmed/entered fire on the bar they occur.
// ===========================================================================
if sigImminent and alertImminent
    alert("BPR עומד להיווצר על " + syminfo.ticker + " " + timeframe.period + " בסגירת הנר הקרוב סביב " + str.tostring(close), alert.freq_once_per_bar)

if sigConfirmed and alertConfirmed
    alert("BPR נוצר על " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close), alert.freq_once_per_bar)

if sigEntered and alertEntered
    alert("מחיר נכנס ל-BPR על " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close), alert.freq_once_per_bar)

// ===========================================================================
// RE-APPLY VISIBILITY ON LAST BAR (so toggling filters / price moving refreshes)
// ===========================================================================
if barstate.islast
    for bpr in bprs
        applyVisibility(bpr)
````
