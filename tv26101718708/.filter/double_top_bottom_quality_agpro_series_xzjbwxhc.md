# Double Top / Bottom Quality [AGPro Series]

- url: https://www.tradingview.com/script/xzJbwxHc-Double-Top-Bottom-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;8199c5c3e33b4b4e99bdcf67597f6c4c
- version: 3.0

## Description

Double Top / Bottom Quality [AGPro Series]

Double Top / Bottom Quality [AGPro Series] is a disciplined, rules-based detector for the two most iconic reversal chart patterns: the Double Top (M-shape) and the Double Bottom (W-shape). Unlike basic pattern finders that fire on any two similar swings, this indicator scores every candidate pattern on a transparent 0–100 Quality Score across four independent factors — and only confirms patterns that pass a user-defined minimum. The result is a cleaner chart with fewer, higher-conviction setups.

Every confirmed pattern delivers a full trading lifecycle: a neckline flip S/R zone (resistance → support on a Double Bottom; support → resistance on a Double Top) and a measured-move target projection band. Pending, confirmed, target-hit and invalidated states are all tracked with disciplined cleanup, so the chart never becomes cluttered.


🔹 WHAT THE INDICATOR DOES

It detects classic Double Top and Double Bottom reversal structures using pivot-based swing analysis with ATR-normalised equality, depth and time-window filters. Each valid candidate is then scored on four independent quality factors. Only candidates that exceed the user-defined minimum score and break the neckline on close are confirmed. Once confirmed, the pattern draws its neckline flip zone and target projection band, labels the setup with its letter grade and score, and tracks the outcome until target hit or invalidation.


🔹 UNIQUE EDGE — WHY IT IS DIFFERENT

Most Double Top / Double Bottom scripts simply connect two similar swings and draw a line. This indicator adds a transparent 4-component Quality Score so every setup is rated before confirmation, not just flagged. Three factors that most scripts ignore are treated as first-class inputs here:

• Pattern Symmetry — the left leg and the right leg of the M / W must be comparable in time, or the pattern is penalised
• Break Volume Confirmation — the neckline break bar is compared to its rolling volume average, and thin breaks score lower
• Depth Quality — shallow, flat patterns are filtered out in favour of deep, decisive reversals

The full lifecycle visualisation (pending → confirmed → target hit) and same-region deduplication are also uncommon in this pattern category, and together they produce a chart that reads cleanly even on long history.


🔹 METHODOLOGY

• Pivot detection via ta.pivothigh / ta.pivotlow with user-configurable length
• Equality check: the two peaks (or troughs) must be within a configurable ATR tolerance
• Time-window filter: minimum and maximum bars allowed between the two pivots
• Depth filter: the vertical distance from peaks to neckline must exceed a minimum ATR threshold
• Neckline: lowest low between the two peaks for a Double Top, or highest high between the two troughs for a Double Bottom
• Confirmation trigger: daily close beyond the neckline
• Invalidation: price exceeds the pattern extreme before the neckline break
• Cooldown: after confirmation, new patterns in the same price region are suppressed for N bars to prevent clustering


🔹 QUALITY SCORE (0–100)

Each confirmed pattern receives a transparent score based on four equally-weighted factors (25 points each):

1. Peak / Trough Equality — how close the two extremes are to each other, measured in ATR units
2. Break Volume Confirmation — break-bar volume relative to the 20-bar average
3. Pattern Symmetry — ratio of the shorter leg to the longer leg (time-based)
4. Depth Quality — pattern height relative to ATR (deeper = higher score)

Score → Grade mapping:
• 85–100 = A
• 70–84  = B
• 55–69  = C
• <55    = D


🔹 SIGNALS, ZONES & ALERTS

Once a pattern confirms, the indicator renders:

• A solid neckline that extends to the right edge
• A neckline flip zone (rectangular S/R band at the neckline level)
• A target projection zone at the measured-move price (pattern height projected from neckline)
• A grade label (A / B / C) and numeric score on the pattern

Two alert types are available: "Confirmed Pattern" fires on confirmation, and "Target Hit" fires when the measured-move target is reached.


🔹 KEY INPUTS

• Pivot Length, ATR Length
• Peak / Trough Equality tolerance (ATR)
• Min / Max bars between peaks
• Minimum Pattern Depth (ATR)
• Break Volume Multiplier
• Cooldown bars
• Minimum Quality Score filter
• Show Pending Patterns toggle
• Show Neckline Flip Zone / Target Zone toggles
• Zone Width (ATR)
• Stale Cleanup Distance, Max Active Zones
• Label size, Panel position / theme / size
• Alert toggles


🔹 HOW TO USE

• Choose a liquid market and a timeframe that matches your trading style (4H and 1D are particularly well-suited to classic reversal patterns)
• Watch for Pending patterns (dashed lines) — these mark candidates awaiting a neckline break
• A Confirmed pattern with grade B or higher is the typical entry signal; aggressive traders may use C-grade while conservative traders may filter to A-grade only
• Use the neckline flip zone as a logical stop-loss reference (above it for Double Tops, below for Double Bottoms)
• Use the target projection zone as a take-profit reference based on the classical measured-move rule
• Combine with higher-timeframe trend, volume profile or an independent confluence tool for best results


🔹 LIMITATIONS & TRANSPARENCY

• Pivot-based detection means patterns confirm with a natural lag equal to the pivot length
• No strategy is 100% reliable — Quality Score filters improve average conviction but do not guarantee outcomes
• Very low-liquidity markets may produce unstable pivots; a longer pivot length helps
• Measured-move targets are a classical reference, not a prediction
• Historical statistics shown in the panel are pattern-completion counts on the loaded chart; they are not a guaranteed forward performance estimate


🔹 RISK DISCLOSURE

This script is provided for educational and analytical purposes only. It is not financial advice and does not constitute a recommendation to buy, sell or hold any asset. Trading involves substantial risk of loss; past pattern performance is not indicative of future results. Always perform your own research and use appropriate risk management.

Open-source under the Mozilla Public License 2.0 — contributions and feedback are welcome.

## Source Code

````pine
// -------------------------------------------------
// Double Top / Bottom Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.0
//
// Automatic detection of classic Double Top and Double Bottom reversal
// chart patterns with a 4-component Quality Score covering equality,
// neckline break volume, pattern symmetry, and depth. The script maps
// neckline flip zones, measured-move target bands, pending structures,
// confirmed patterns, target hits, invalidations, hand-drawn curved M/W
// skeletons, and an AGPro panel.
// -------------------------------------------------

//@version=6
indicator("Double Top / Bottom Quality [AGPro Series]",
     shorttitle = "AG Pro DTBQ",
     overlay = true,
     max_labels_count = 350,
     max_lines_count = 350,
     max_boxes_count = 350,
     max_polylines_count = 100)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpDet = "Detection"
pivLen = input.int(5, "Pivot Length", minval = 2, maxval = 20, group = grpDet, tooltip = "Number of bars on each side of a pivot used to confirm it. Larger values produce fewer but more significant swings.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 50, group = grpDet, tooltip = "ATR period used for equality tolerance, zone sizing, and label offsets.")
eqTolATR = input.float(0.5, "Peak / Trough Equality ATR", minval = 0.1, maxval = 2.0, step = 0.1, group = grpDet, tooltip = "Maximum vertical distance between the two peaks or troughs, expressed in ATR units.")
minBarsBw = input.int(8, "Min Bars Between Peaks", minval = 3, maxval = 100, group = grpDet, tooltip = "Minimum distance between the two peaks or troughs. Prevents adjacent swing noise from forming weak patterns.")
maxBarsBw = input.int(80, "Max Bars Between Peaks", minval = 20, maxval = 400, group = grpDet, tooltip = "Maximum distance between the two peaks or troughs. Prevents unrelated swings from being paired.")
minDepth = input.float(1.0, "Min Pattern Depth ATR", minval = 0.3, maxval = 5.0, step = 0.1, group = grpDet, tooltip = "Minimum distance from peaks or troughs to the neckline, measured in ATR.")
volMult = input.float(1.2, "Break Volume Multiplier", minval = 1.0, maxval = 3.0, step = 0.1, group = grpDet, tooltip = "Break bar volume is compared with average volume. Higher values require stronger confirmation.")
cooldown = input.int(30, "Cooldown Bars", minval = 0, maxval = 200, group = grpDet, tooltip = "After a confirmed pattern, suppress new patterns in the same price region for this many bars.")

grpQual = "Quality Filter"
minScore = input.int(60, "Minimum Quality Score", minval = 0, maxval = 100, group = grpQual, tooltip = "Patterns below this composite 0-100 score are ignored.")
showPend = input.bool(true, "Show Pending Patterns", group = grpQual, tooltip = "Shows patterns that have formed both peaks or troughs but have not yet broken the neckline.")

grpVis = "Visuals"
showFlip = input.bool(true, "Show Neckline Flip Zone", group = grpVis, tooltip = "Draws a horizontal support/resistance flip zone from the neckline after confirmation.")
showTgt = input.bool(true, "Show Target Projection Zone", group = grpVis, tooltip = "Draws the measured-move target band projected from the neckline.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = grpVis, tooltip = "Adds separate centered badges inside active flip and target zones.")
showPatternSkeleton = input.bool(true, "Show Pattern Skeleton", group = grpVis, tooltip = "Draws the hand-drawn curved M/W structure from the first peak or trough through the neckline and into the second peak or trough.")
showPatternPointLabels = input.bool(true, "Show Pattern Point Labels", group = grpVis, tooltip = "Labels the pattern points so users can see the first top or bottom, neckline, second top or bottom, and confirmed break leg.")
keepEducationalHistory = input.bool(true, "Keep Educational History", group = grpVis, tooltip = "Keeps M/W skeleton helpers and point labels after a pattern is finished so historical tops and bottoms remain educational on the chart.")
patternLineWidth = input.int(4, "Pattern Skeleton Width", minval = 1, maxval = 5, group = grpVis, tooltip = "Controls the thickness of the hand-drawn curved M/W skeleton.")
zoneWidth = input.float(0.3, "Zone Width ATR", minval = 0.1, maxval = 1.5, step = 0.1, group = grpVis, tooltip = "Vertical thickness of flip and target zones, measured in ATR.")
staleATR = input.float(8.0, "Stale Cleanup Distance ATR", minval = 2.0, maxval = 30.0, step = 0.5, group = grpVis, tooltip = "When price moves this many ATR away from active zones, they are closed to keep the chart clean.")
maxActive = input.int(15, "Max Active Zones", minval = 2, maxval = 30, group = grpVis, tooltip = "Maximum confirmed patterns kept active on the chart.")
bullColInp = input.color(color.rgb(34, 197, 166), "Bullish Color", group = grpVis)
bearColInp = input.color(color.rgb(244, 114, 182), "Bearish Color", group = grpVis)

grpLbl = "Labels"
showLbl = input.bool(true, "Show Pattern Labels", group = grpLbl, tooltip = "Shows labels on confirmed patterns with type, grade, and quality score.")
lblSizeIn = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpLbl)
showScore = input.bool(true, "Show Score in Label", group = grpLbl, tooltip = "Adds the numeric quality score to pattern labels.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Info Panel", group = grpPanel)
panelPos = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = grpPanel)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPanel)
panelSizeIn = input.string("Normal", "Panel Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel)

grpAlert = "Alerts"
alertConf = input.bool(true, "Alert on Confirmed Pattern", group = grpAlert)
alertHit = input.bool(false, "Alert on Target Hit", group = grpAlert)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
darkInk = color.rgb(17, 24, 39)
basePanelBg = color.rgb(15, 23, 42)
basePanelBorder = color.rgb(51, 65, 85)
basePanelLabel = color.rgb(148, 163, 184)
basePanelValue = color.rgb(226, 232, 240)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
bullCol = bullColInp
bearCol = bearColInp

// -------------------------------------------------
// Helpers
// -------------------------------------------------
// Luminance-145 contrast ink: bright badge fills get dark ink, dark fills get header text.
f_text_on(_bg) =>
    lum = math.round(0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg))
    lum >= 145 ? darkInk : headerText

f_to_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_panel_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Left" ? position.middle_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Center" ? position.bottom_center :
     p == "Bottom Left" ? position.bottom_left : position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : basePanelBg

f_panel_label_bg() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(22, 32, 56)

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : basePanelLabel

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : basePanelValue

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : basePanelBorder

f_grade(int s) =>
    s >= 85 ? "A" : s >= 70 ? "B" : s >= 55 ? "C" : "D"

// Densify a segment with collinear sub-points so the curved skeleton rounds the
// corners smoothly without overshooting past the tops, bottoms, and neckline.
f_addSeg(array<chart.point> pts, int b1, float p1, int b2, float p2, int steps) =>
    for s = 0 to steps - 1
        t = s / float(steps)
        bi = int(math.round(b1 + (b2 - b1) * t))
        pr = p1 + (p2 - p1) * t
        array.push(pts, chart.point.from_index(bi, pr))

lblSize = f_to_size(lblSizeIn)
panelSize = f_to_size(panelSizeIn)

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
atr = ta.atr(atrLen)
atrSafe = math.max(nz(atr, syminfo.mintick), syminfo.mintick)
volAvg = ta.sma(volume, 20)

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

var float ph1 = na
var int ph1bar = na
var float ph2 = na
var int ph2bar = na
var float pl1 = na
var int pl1bar = na
var float pl2 = na
var int pl2bar = na

if not na(ph)
    ph2 := ph1
    ph2bar := ph1bar
    ph1 := ph
    ph1bar := bar_index - pivLen
if not na(pl)
    pl2 := pl1
    pl2bar := pl1bar
    pl1 := pl
    pl1bar := bar_index - pivLen

// -------------------------------------------------
// Pattern state
// -------------------------------------------------
type DblPat
    int ptype = 0
    int status = 0
    int p1bar = 0
    float p1price = na
    int p2bar = 0
    float p2price = na
    int necklineBar = 0
    float necklinePrice = na
    int confirmBar = 0
    float targetPrice = na
    int score = 0
    string grade = ""
    line lnNeck = na
    line lnP1 = na
    polyline plSkel = na
    polyline plSkelGlow = na
    box bxFlip = na
    box bxTgt = na
    label lbl = na
    label flipBadge = na
    label tgtBadge = na
    label p1Tag = na
    label neckTag = na
    label p2Tag = na
    label breakTag = na

var array<DblPat> pats = array.new<DblPat>()
var int lastConfirmBarTop = na
var float lastConfirmPxTop = na
var int lastConfirmBarBot = na
var float lastConfirmPxBot = na

// -------------------------------------------------
// Detection
// -------------------------------------------------
f_region_occupied(int ptype, float refPrice) =>
    bool occupied = false
    if array.size(pats) > 0
        for i = 0 to array.size(pats) - 1
            existing = array.get(pats, i)
            if existing.ptype == ptype and (existing.status == 0 or existing.status == 1)
                if math.abs(existing.p2price - refPrice) < 2.0 * atrSafe
                    occupied := true
                    break
    occupied

detect_top() =>
    bool found = false
    DblPat p = DblPat.new()
    if not na(ph1) and not na(ph2) and not na(ph1bar) and not na(ph2bar)
        dist = ph1bar - ph2bar
        eqDiff = math.abs(ph1 - ph2)
        if dist >= minBarsBw and dist <= maxBarsBw and eqDiff <= eqTolATR * atrSafe
            necklineP = ta.lowest(low, dist)
            depth = math.min(ph1, ph2) - necklineP
            if depth >= minDepth * atrSafe
                cdOk = na(lastConfirmBarTop) or (bar_index - lastConfirmBarTop) > cooldown or math.abs(ph1 - lastConfirmPxTop) > 2 * atrSafe
                regionOk = not f_region_occupied(1, ph1)
                if cdOk and regionOk
                    p.ptype := 1
                    p.status := 0
                    p.p1bar := ph2bar
                    p.p1price := ph2
                    p.p2bar := ph1bar
                    p.p2price := ph1
                    p.necklinePrice := necklineP
                    p.necklineBar := bar_index - pivLen
                    found := true
    [found, p]

detect_bot() =>
    bool found = false
    DblPat p = DblPat.new()
    if not na(pl1) and not na(pl2) and not na(pl1bar) and not na(pl2bar)
        dist = pl1bar - pl2bar
        eqDiff = math.abs(pl1 - pl2)
        if dist >= minBarsBw and dist <= maxBarsBw and eqDiff <= eqTolATR * atrSafe
            necklineP = ta.highest(high, dist)
            depth = necklineP - math.max(pl1, pl2)
            if depth >= minDepth * atrSafe
                cdOk = na(lastConfirmBarBot) or (bar_index - lastConfirmBarBot) > cooldown or math.abs(pl1 - lastConfirmPxBot) > 2 * atrSafe
                regionOk = not f_region_occupied(2, pl1)
                if cdOk and regionOk
                    p.ptype := 2
                    p.status := 0
                    p.p1bar := pl2bar
                    p.p1price := pl2
                    p.p2bar := pl1bar
                    p.p2price := pl1
                    p.necklinePrice := necklineP
                    p.necklineBar := bar_index - pivLen
                    found := true
    [found, p]

// -------------------------------------------------
// Quality score
// -------------------------------------------------
f_calc_score(DblPat p, float breakVol) =>
    eqDiff = math.abs(p.p1price - p.p2price)
    eqPct = math.max(0.0, 1.0 - eqDiff / math.max(eqTolATR * atrSafe, syminfo.mintick))
    s1 = math.round(eqPct * 25)
    volRatio = breakVol / math.max(nz(volAvg, 1.0), 1.0)
    volPct = math.max(0.0, math.min(1.0, (volRatio - 1.0) / (volMult - 1.0 + 0.0001)))
    s2 = math.round(volPct * 25)
    leftLeg = p.necklineBar - p.p1bar
    rightLeg = p.p2bar - p.necklineBar
    symRatio = math.min(leftLeg, rightLeg) / math.max(math.max(leftLeg, rightLeg), 1)
    s3 = math.round(symRatio * 25)
    depth = p.ptype == 1 ? math.min(p.p1price, p.p2price) - p.necklinePrice : p.necklinePrice - math.max(p.p1price, p.p2price)
    depthATR = depth / atrSafe
    s4 = math.round(math.min(1.0, depthATR / 3.0) * 25)
    int(s1 + s2 + s3 + s4)

// -------------------------------------------------
// Draw helpers
// -------------------------------------------------
// Build a smooth curved skeleton through the supplied anchor list.
// anchors must be in order; each consecutive pair is densified, then the final
// point is appended, and a glow + main curved polyline are returned via p.
f_draw_skeleton(DblPat p, color col, int entryBar, bool withBreak) =>
    pts = array.new<chart.point>()
    steps = 5
    f_addSeg(pts, entryBar, p.necklinePrice, p.p1bar, p.p1price, steps)
    f_addSeg(pts, p.p1bar, p.p1price, p.necklineBar, p.necklinePrice, steps)
    f_addSeg(pts, p.necklineBar, p.necklinePrice, p.p2bar, p.p2price, steps)
    if withBreak
        f_addSeg(pts, p.p2bar, p.p2price, p.confirmBar, p.necklinePrice, steps)
        array.push(pts, chart.point.from_index(p.confirmBar, p.necklinePrice))
    else
        array.push(pts, chart.point.from_index(p.p2bar, p.p2price))
    if not na(p.plSkelGlow)
        polyline.delete(p.plSkelGlow)
    if not na(p.plSkel)
        polyline.delete(p.plSkel)
    p.plSkelGlow := polyline.new(pts, curved = true, closed = false, xloc = xloc.bar_index, line_color = color.new(col, 72), line_width = patternLineWidth + 3, line_style = line.style_solid)
    p.plSkel := polyline.new(pts, curved = true, closed = false, xloc = xloc.bar_index, line_color = color.new(col, 0), line_width = patternLineWidth, line_style = line.style_solid)

f_delete_pattern_visuals(DblPat p) =>
    if not na(p.lnNeck)
        line.delete(p.lnNeck)
    if not na(p.lnP1)
        line.delete(p.lnP1)
    if not na(p.plSkel)
        polyline.delete(p.plSkel)
    if not na(p.plSkelGlow)
        polyline.delete(p.plSkelGlow)
    if not na(p.bxFlip)
        box.delete(p.bxFlip)
    if not na(p.bxTgt)
        box.delete(p.bxTgt)
    if not na(p.lbl)
        label.delete(p.lbl)
    if not na(p.flipBadge)
        label.delete(p.flipBadge)
    if not na(p.tgtBadge)
        label.delete(p.tgtBadge)
    if not na(p.p1Tag)
        label.delete(p.p1Tag)
    if not na(p.neckTag)
        label.delete(p.neckTag)
    if not na(p.p2Tag)
        label.delete(p.p2Tag)
    if not na(p.breakTag)
        label.delete(p.breakTag)

f_clear_educational_visuals(DblPat p) =>
    if not na(p.plSkel)
        polyline.delete(p.plSkel)
        p.plSkel := na
    if not na(p.plSkelGlow)
        polyline.delete(p.plSkelGlow)
        p.plSkelGlow := na
    if not na(p.p1Tag)
        label.delete(p.p1Tag)
        p.p1Tag := na
    if not na(p.neckTag)
        label.delete(p.neckTag)
        p.neckTag := na
    if not na(p.p2Tag)
        label.delete(p.p2Tag)
        p.p2Tag := na
    if not na(p.breakTag)
        label.delete(p.breakTag)
        p.breakTag := na

f_draw_pending(DblPat p) =>
    col = p.ptype == 1 ? bearCol : bullCol
    p.lnNeck := line.new(p.p1bar, p.necklinePrice, p.p2bar, p.necklinePrice, color = col, style = line.style_dashed, width = 2)
    if showPatternSkeleton
        leftSpan = math.max(p.necklineBar - p.p1bar, 1)
        entryBar = math.max(p.p1bar - leftSpan, 0)
        f_draw_skeleton(p, col, entryBar, false)
    if showPatternPointLabels
        isTop = p.ptype == 1
        ptOffset = atrSafe * 0.72
        p1Text = isTop ? "T1" : "B1"
        p2Text = isTop ? "T2" : "B2"
        p1Y = isTop ? p.p1price + ptOffset : p.p1price - ptOffset
        p2Y = isTop ? p.p2price + ptOffset : p.p2price - ptOffset
        neckY = isTop ? p.necklinePrice - ptOffset : p.necklinePrice + ptOffset
        peakStyle = isTop ? label.style_label_down : label.style_label_up
        neckStyle = isTop ? label.style_label_up : label.style_label_down
        p.p1Tag := label.new(p.p1bar, p1Y, p1Text, xloc = xloc.bar_index, yloc = yloc.price, style = peakStyle, color = color.new(col, 0), textcolor = f_text_on(col), size = lblSize)
        p.neckTag := label.new(p.necklineBar, neckY, "NECK", xloc = xloc.bar_index, yloc = yloc.price, style = neckStyle, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = lblSize)
        p.p2Tag := label.new(p.p2bar, p2Y, p2Text, xloc = xloc.bar_index, yloc = yloc.price, style = peakStyle, color = color.new(col, 0), textcolor = f_text_on(col), size = lblSize)

f_upgrade_confirmed(DblPat p) =>
    col = p.ptype == 1 ? bearCol : bullCol
    if not na(p.lnNeck)
        line.delete(p.lnNeck)
    p.lnNeck := line.new(p.p1bar, p.necklinePrice, bar_index + 20, p.necklinePrice, color = col, style = line.style_solid, width = 2, extend = extend.right)
    if showPatternSkeleton
        leftSpan = math.max(p.necklineBar - p.p1bar, 1)
        entryBar = math.max(p.p1bar - leftSpan, 0)
        f_draw_skeleton(p, col, entryBar, true)
    if showPatternPointLabels
        breakText = p.ptype == 1 ? "BREAK DN" : "BREAK UP"
        breakY = p.ptype == 1 ? p.necklinePrice - atrSafe * 1.45 : p.necklinePrice + atrSafe * 1.45
        breakStyle = p.ptype == 1 ? label.style_label_up : label.style_label_down
        p.breakTag := label.new(p.confirmBar + 3, breakY, breakText, xloc = xloc.bar_index, yloc = yloc.price, style = breakStyle, color = color.new(col, 0), textcolor = f_text_on(col), size = lblSize)

    height = p.ptype == 1 ? math.min(p.p1price, p.p2price) - p.necklinePrice : p.necklinePrice - math.max(p.p1price, p.p2price)
    p.targetPrice := p.ptype == 1 ? p.necklinePrice - height : p.necklinePrice + height
    zw = zoneWidth * atrSafe

    if showFlip
        p.bxFlip := box.new(p.confirmBar, p.necklinePrice + zw * 0.5, bar_index + 40, p.necklinePrice - zw * 0.5, border_color = color.new(col, 55), bgcolor = color.new(col, 86), extend = extend.right)
        if showZoneBadges
            p.flipBadge := label.new(bar_index + 20, p.necklinePrice, "NECKLINE\nFLIP", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(col, 0), textcolor = f_text_on(col), size = lblSize)

    if showTgt
        p.bxTgt := box.new(p.confirmBar, p.targetPrice + zw * 0.5, bar_index + 40, p.targetPrice - zw * 0.5, border_color = color.new(col, 45), bgcolor = color.new(col, 82), extend = extend.right)
        if showZoneBadges
            p.tgtBadge := label.new(bar_index + 20, p.targetPrice, "TARGET\nZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(col, 0), textcolor = f_text_on(col), size = lblSize)

    if showLbl
        lblY = p.ptype == 1 ? math.max(p.p1price, p.p2price) + 2.15 * atrSafe : math.min(p.p1price, p.p2price) - 2.15 * atrSafe
        lblX = int(math.round((p.p1bar + p.p2bar) * 0.5))
        scoreStr = showScore ? " - " + str.tostring(p.score) : ""
        txt = (p.ptype == 1 ? "DOUBLE TOP" : "DOUBLE BOTTOM") + " [" + p.grade + "]" + scoreStr
        lblStyle = p.ptype == 1 ? label.style_label_down : label.style_label_up
        p.lbl := label.new(lblX, lblY, txt, style = lblStyle, color = col, textcolor = f_text_on(col), size = lblSize)

f_freeze_pattern(DblPat p) =>
    if not na(p.bxTgt)
        box.set_right(p.bxTgt, bar_index)
        box.set_extend(p.bxTgt, extend.none)
        box.set_bgcolor(p.bxTgt, color.new(neutralColor, 75))
    if not na(p.bxFlip)
        box.set_right(p.bxFlip, bar_index)
        box.set_extend(p.bxFlip, extend.none)
    if not na(p.lnNeck)
        line.set_x2(p.lnNeck, bar_index)
        line.set_extend(p.lnNeck, extend.none)
    if not na(p.flipBadge)
        label.delete(p.flipBadge)
        p.flipBadge := na
    if not na(p.tgtBadge)
        label.delete(p.tgtBadge)
        p.tgtBadge := na
    if not keepEducationalHistory
        f_clear_educational_visuals(p)

// -------------------------------------------------
// Main loop
// -------------------------------------------------
if not na(ph) and showPend
    [okTop, newTop] = detect_top()
    if okTop
        f_draw_pending(newTop)
        array.push(pats, newTop)

if not na(pl) and showPend
    [okBot, newBot] = detect_bot()
    if okBot
        f_draw_pending(newBot)
        array.push(pats, newBot)

bool confirmedTopEvent = false
bool confirmedBotEvent = false
bool targetHitTopEvent = false
bool targetHitBotEvent = false

if array.size(pats) > 0
    for i = array.size(pats) - 1 to 0
        p = array.get(pats, i)
        if p.status == 0
            topInvalid = p.ptype == 1 and high > math.max(p.p1price, p.p2price) + 0.1 * atrSafe
            botInvalid = p.ptype == 2 and low < math.min(p.p1price, p.p2price) - 0.1 * atrSafe
            if topInvalid or botInvalid
                f_delete_pattern_visuals(p)
                array.remove(pats, i)
                continue

            brokeTop = p.ptype == 1 and close < p.necklinePrice
            brokeBot = p.ptype == 2 and close > p.necklinePrice
            if brokeTop or brokeBot
                p.confirmBar := bar_index
                p.score := f_calc_score(p, volume)
                p.grade := f_grade(p.score)
                if p.score >= minScore
                    p.status := 1
                    if p.ptype == 1
                        lastConfirmBarTop := bar_index
                        lastConfirmPxTop := p.necklinePrice
                        confirmedTopEvent := true
                    else
                        lastConfirmBarBot := bar_index
                        lastConfirmPxBot := p.necklinePrice
                        confirmedBotEvent := true
                    if not na(p.lnP1)
                        line.delete(p.lnP1)
                        p.lnP1 := na
                    f_upgrade_confirmed(p)
                else
                    f_delete_pattern_visuals(p)
                    array.remove(pats, i)
                    continue

            if bar_index - p.p2bar > maxBarsBw * 2
                f_delete_pattern_visuals(p)
                array.remove(pats, i)
                continue

        else if p.status == 1
            hitTop = p.ptype == 1 and low <= p.targetPrice
            hitBot = p.ptype == 2 and high >= p.targetPrice
            if hitTop or hitBot
                p.status := 2
                targetHitTopEvent := hitTop
                targetHitBotEvent := hitBot
                f_freeze_pattern(p)
            else
                distNeck = math.abs(close - p.necklinePrice)
                distTgt = math.abs(close - p.targetPrice)
                if math.min(distNeck, distTgt) > staleATR * atrSafe
                    p.status := 2
                    f_freeze_pattern(p)
        array.set(pats, i, p)

if array.size(pats) > 0
    activeCount = 0
    for i = 0 to array.size(pats) - 1
        pi = array.get(pats, i)
        if pi.status == 1
            activeCount += 1
    if activeCount > maxActive
        toClose = activeCount - maxActive
        closed = 0
        for i = 0 to array.size(pats) - 1
            if closed >= toClose
                break
            po = array.get(pats, i)
            if po.status == 1
                po.status := 2
                f_freeze_pattern(po)
                array.set(pats, i, po)
                closed += 1

// -------------------------------------------------
// Panel stats
// -------------------------------------------------
activePending = 0
activeConfirmed = 0
tgtHit = 0
totalConfirmed = 0
bestScore = 0
lastPatStr = "-"

if array.size(pats) > 0
    for i = 0 to array.size(pats) - 1
        pp = array.get(pats, i)
        if pp.status == 0
            activePending += 1
        else if pp.status == 1
            activeConfirmed += 1
            totalConfirmed += 1
            if pp.score > bestScore
                bestScore := pp.score
                lastPatStr := (pp.ptype == 1 ? "Top" : "Bot") + " - " + pp.grade + " - " + str.tostring(pp.score)
        else if pp.status == 2
            tgtHit += 1
            totalConfirmed += 1

proofReady = totalConfirmed >= 6
hitRatePct = totalConfirmed > 0 ? tgtHit / totalConfirmed * 100.0 : na
hitRateStr = not proofReady ? "Building (" + str.tostring(totalConfirmed) + ")" : str.tostring(math.round(hitRatePct)) + "% (n=" + str.tostring(totalConfirmed) + ")"
hitRateCol = not proofReady ? f_panel_label() : hitRatePct >= 55.0 ? bullCol : hitRatePct >= 45.0 ? neutralColor : bearCol
hitRateBg = proofReady ? color.new(hitRateCol, 12) : f_panel_bg()
hitRateInk = proofReady ? f_text_on(hitRateCol) : f_panel_label()

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = na

if barstate.islast
    if showPanel
        if na(panel)
            panel := table.new(f_panel_pos(panelPos), 2, 10, bgcolor = f_panel_bg(), border_color = f_panel_border(), border_width = 1, frame_color = f_panel_border(), frame_width = 1)
        table.set_position(panel, f_panel_pos(panelPos))
        table.set_border_color(panel, f_panel_border())
        table.set_frame_color(panel, f_panel_border())
        table.clear(panel, 0, 0, 1, 9)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Double Top / Bottom", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 0, 1, "Pending", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 1, str.tostring(activePending), text_color = neutralColor, bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 2, "Active Confirmed", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 2, str.tostring(activeConfirmed), text_color = bullCol, bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 3, "Targets Hit", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 3, str.tostring(tgtHit), text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 4, "Best Active", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 4, lastPatStr, text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 5, "Equality Tol", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 5, str.tostring(eqTolATR) + " ATR", text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 6, "Min Score", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 6, str.tostring(minScore), text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(panel, 0, 7, "ATR", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 7, str.tostring(atrSafe, format.mintick), text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.merge_cells(panel, 0, 8, 1, 8)
        table.cell(panel, 0, 8, "— TARGET PROOF —", text_color = accentColor, bgcolor = f_panel_bg(), text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 0, 9, "Target Hit Rate", text_color = f_panel_label(), bgcolor = f_panel_label_bg(), text_size = panelSize)
        table.cell(panel, 1, 9, hitRateStr, text_color = hitRateInk, bgcolor = hitRateBg, text_size = panelSize)
    else
        if not na(panel)
            table.delete(panel)
            panel := na

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertConf and confirmedTopEvent, "Confirmed Double Top", "Double Top / Bottom Quality: Double Top confirmed.")
alertcondition(alertConf and confirmedBotEvent, "Confirmed Double Bottom", "Double Top / Bottom Quality: Double Bottom confirmed.")
alertcondition(alertHit and targetHitTopEvent, "Double Top Target Hit", "Double Top / Bottom Quality: Double Top target hit.")
alertcondition(alertHit and targetHitBotEvent, "Double Bottom Target Hit", "Double Top / Bottom Quality: Double Bottom target hit.")
````
