# Auto Trendline Break Quality [AGPro Series]

- url: https://www.tradingview.com/script/gFNh5Apx-Auto-Trendline-Break-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;98df1a81709f4e3cb3baada770526ecd
- version: 3.0

## Description

Auto Trendline Break Quality [AGPro Series]

🔹 OVERVIEW

Auto Trendline Break Quality is a structural break-quality engine. It automatically detects bullish and bearish trendlines from swing pivots, monitors every break event in real time, and assigns each break a 0–100 quality score derived from four independent quantitative factors. The tool separates Major (structural) and Minor (tactical) trendlines, so the same break can be evaluated against multiple layers of market structure at once.

The script is purpose-built to answer the single most practical question a price-action trader faces at a trendline break: "Is this break real, or is it a fake-out?"


🧭 UNIQUE EDGE

Most trendline scripts either draw trendlines or flag a break. They stop there. This indicator continues where they stop — and measures the break.

Key differentiators:

• Four-factor composite quality score (Volume · Slope · Impulse · Retest) calibrated to ATR, so the scoring is consistent across assets and timeframes.

• Major/Minor trendline hierarchy. A Major structural break automatically earns a score bonus and is visually flagged with a "MAJ" tag, so structural breaks are never confused with noise breaks.

• State-based visual language. Active trendlines render in a neutral tone. On break, the trendline transitions to the break-direction color (bullish break = bull color, bearish break = bear color), so the chart communicates state without ambiguity.

• Retest logic built directly into the score. A break that is retested and holds within the defined window receives an upgrade; a failed retest downgrades the score. The chart label reflects the final, updated quality.

• Optional zone-band rendering around Major trendlines, letting the user see each structural line as a reaction zone rather than a bare line.

• Label confluence grouping to prevent chart clutter when multiple breaks occur near the same price level.


⚙️ METHODOLOGY

1) Trendline detection
Pivots are identified using standard pivot-high and pivot-low logic with two configurable lookbacks — one for Major trendlines and one for Minor. A new trendline is validated between the two most recent same-side pivots when the slope (ATR-normalized) exceeds the minimum threshold. Nearly-flat trendlines are rejected by design.

2) Break detection
A trendline is considered broken when the current candle closes on the opposite side of the projected line while the previous candle closed on the valid side. This one-bar confirmation rule avoids intra-bar flicker.

3) Quality scoring (0–100)
• Volume expansion vs 20-bar average — up to 25 points
• ATR-normalized slope steepness — up to 20 points
• Break-bar impulse measured in ATR from the line — up to 25 points
• Retest base score — 18 points, upgraded by +15 on a held retest, or reduced by 10 on a failed retest
• Major trendline bonus — +10 points

4) Retest tracking
After a break, the script watches a configurable window (default 3–8 bars) for price to return to the broken trendline within an ATR tolerance. Held retests and failed retests are tracked independently and reflected in the panel's Retest Held Rate. Retest markers are offset from the trendline in ATR units to prevent overlap with candles.


📊 SIGNALS & STATES

• Break label: "BREAK Q:<score> · <direction>" and an optional "MAJ" tag for Major trendlines. Label color tier: High quality renders in full state color, Medium quality in neutral amber, Low quality in a muted tone.

• Retest marker: Small circular marker with "retest held" or "retest failed" text, offset from the trendline for clarity.

• Break bar border: Optional candle-border color that reflects break direction.

• Panel: Active trendlines per side, last break score and direction, overall break-direction breakdown, retest held rate, quality distribution (High/Medium/Low), total breaks tracked, and the current detection mode.

• Alerts: "High Quality Trendline Break" and "Major Trendline Break" — both standard alertcondition entries.


🎛️ KEY INPUTS

• Major / Minor Pivot Length — controls how many bars each side of a pivot must be a local extreme.
• Show Minor Trendlines — toggle tactical layer on top of structural layer.
• Max Active Trendlines per Side — caps the chart clutter.
• Volume Spike Threshold (x Avg) — ratio at which a volume expansion is considered full.
• Retest Min/Max Bars — bar range for a valid retest.
• Retest Tolerance (ATR) — how close price must come to the broken line to count as a retest.
• High / Medium Quality Thresholds — cutoffs for the three quality tiers (defaults: 70 / 50).
• Show Trendline Zone Band — renders a subtle ATR-based band around Major trendlines.
• Zone Band Width (ATR) — controls the thickness of the zone band.
• Label Confluence Grouping (ATR) — merges break labels that land within this ATR distance on nearby bars.
• Label Offset (ATR) — vertical padding so labels never embed in candles.
• Label / Panel / Help font sizes — all default to Normal.
• Panel Position and Theme — six positions, Dark/Light theme.


🧩 HOW TO USE

The indicator is a decision-support layer, not a standalone trading system.

• Treat a break with Q ≥ 70 and a "MAJ" tag as a structural event worth reviewing the higher-timeframe bias for.

• Use the retest window as a patience filter. A break with Q 55–69 that retests and holds often upgrades to a higher-quality setup after the retest.

• Failed retests are not "bad" — they are information. A failed retest on a low-quality break is a strong hint that the break was noise.

• The neutral-color active trendlines are intentional — they tell you where structure exists without biasing your read. Color appears only when structure breaks.

• Combine with your own confluence (volume profile, horizontal support/resistance, higher-timeframe trend). The script does not enter trades; it tells you how reliable a break looks at the moment it happens.


⚠️ LIMITATIONS & TRANSPARENCY

• Quality scores describe historical pattern behavior. They are not predictive probabilities.

• Trendlines are generated from pivots; the final pivot is always confirmed after the pivot-length bars have elapsed. This is standard pivot behavior and is not a repaint of historical marks — past labels remain fixed once a break bar closes.

• The script draws up to the platform's line/label limits. Older trendlines are removed when the active cap is reached.

• Parameter defaults target 4H–1D charts; lower timeframes benefit from smaller pivot lengths and tighter retest windows.


📜 RISK DISCLOSURE

This script is an analytical tool. It does not provide financial advice, investment recommendations, or a trading strategy. Past performance of any pattern, including trendline breaks, does not guarantee future results. Always perform your own analysis and apply proper risk management before making any trading decision.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Auto Trendline Break Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Auto-detects bullish and bearish trendlines from swing pivots, then turns
// each confirmed trendline break into a decision-planning workflow. The engine
// scores break quality, maps the retest pocket, frames invalidation and target
// rails, tracks an empirical stop-aware break follow-through proof rate, and
// summarizes the next action so trendline-break traders can judge whether the
// break is clean, late, or vulnerable to retest failure.
// ─────────────────────────────────────────────────

//@version=6
indicator("Auto Trendline Break Quality [AGPro Series]",
     shorttitle = "TLBQ",
     overlay    = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500)

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
tlNeutral     = color.rgb(100, 116, 139)

// ─────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────
grpGen   = "General"
grpTL    = "Trendline Detection"
grpQS    = "Quality Scoring"
grpVis   = "Visuals"
grpPlan  = "Planner Logic"
grpPnl   = "Panel"

// Trendline Detection
majorPiv   = input.int(10, "Major Pivot Length",      minval = 3, maxval = 50, group = grpTL, tooltip = "Lookback for Major (structural) trendlines. Higher value = fewer, stronger trendlines.")
minorPiv   = input.int(3,  "Minor Pivot Length",      minval = 2, maxval = 20, group = grpTL, tooltip = "Lookback for Minor (tactical) trendlines. Lower value = more short-term trendlines.")
showMinor  = input.bool(false, "Show Minor Trendlines", group = grpTL, tooltip = "Enable to display Minor trendlines alongside Major ones. Disabled by default for cleaner charts.")
maxActive  = input.int(3, "Max Active Trendlines per Side", minval = 1, maxval = 8, group = grpTL, tooltip = "Limits the number of simultaneous trendlines displayed per direction (bull/bear). Older ones are removed.")
extendBars = input.int(20, "Trendline Extension Bars", minval = 5, maxval = 120, group = grpTL, tooltip = "How many bars forward to refresh the newest active trendline. This keeps the live break check visible without overextending old broken structure.")
brokenGuideBars = input.int(0, "Broken Line Forward Guide", minval = 0, maxval = 60, group = grpTL, tooltip = "Keeps a short forward guide after a confirmed break. Default is 0 because the separate latest-line guide is cleaner for publication screenshots.")
showLatestGuide = input.bool(true, "Extend Latest Line Directly", group = grpTL, tooltip = "Extends the latest relevant trendline itself into the right-side chart space, making break monitoring easier without a separate guide segment.")
latestGuideBars = input.int(18, "Latest Direct Extension Bars", minval = 5, maxval = 80, group = grpTL, tooltip = "Forward length for the latest direct line extension. Higher values project farther into the right side of the chart.")
minSlopeATR = input.float(0.05, "Min Slope (ATR units)", minval = 0.0, maxval = 1.0, step = 0.01, group = grpTL, tooltip = "Minimum slope filter as fraction of ATR per bar. Rejects nearly-flat trendlines.")

// Quality Scoring
volMultThr  = input.float(2.0, "Volume Spike Threshold (x Avg)", minval = 1.0, maxval = 5.0, step = 0.1, group = grpQS, tooltip = "Break bar volume vs 20-bar average. 2.0x gives full volume score.")
retestMinBars = input.int(3, "Retest Min Bars After Break",  minval = 1, maxval = 10, group = grpQS)
retestMaxBars = input.int(8, "Retest Max Bars After Break",  minval = 3, maxval = 30, group = grpQS, tooltip = "Retest window. If price returns to the broken trendline within this window, retest scoring applies.")
retestTol   = input.float(0.5, "Retest Tolerance (ATR)", minval = 0.1, maxval = 2.0, step = 0.1, group = grpQS, tooltip = "How close price must come to the broken trendline to count as a retest (in ATR units).")
highQthr    = input.int(70, "High Quality Threshold",  minval = 60, maxval = 90, group = grpQS)
medQthr     = input.int(50, "Medium Quality Threshold", minval = 30, maxval = 70, group = grpQS)
readyQthr   = input.int(68, "Ready Break Threshold", minval = 50, maxval = 90, group = grpQS, tooltip = "Minimum score used by the planner state and Ready Break alert. This does not guarantee outcome; it only marks stronger rule-based break structure.")
confirmMode = input.string("Close Break", "Confirmation Mode", options = ["Close Break","Close + Volume","Close + Impulse"], group = grpQS, tooltip = "Controls how selective a trendline break must be before it is accepted. Close Break preserves the original behavior. Volume and Impulse modes add stricter filters.")

// Planner Logic
showRetestPocket = input.bool(false, "Show Retest Pocket", group = grpPlan, tooltip = "Draws a compact zone around the broken trendline during the retest window. The label is centered inside the pocket.")
showPlannerRails = input.bool(false, "Show Target / Invalidation Rails", group = grpPlan, tooltip = "Shows a lightweight target rail and invalidation rail for the latest confirmed trendline break.")
plannerTargetATR = input.float(1.6, "Planner Target Distance (ATR)", minval = 0.5, maxval = 5.0, step = 0.1, group = grpPlan, tooltip = "ATR-based target guide from the break candle. It is a planning reference, not a forecast or profit promise.")

// Visuals
fontSizeOpt = input.string("Normal", "Label Font Size", options = ["Small","Normal","Large"], group = grpVis)
panelFntOpt = input.string("Normal", "Panel Font Size", options = ["Small","Normal","Large"], group = grpVis)
labelOffATR = input.float(1.5, "Label Offset (ATR)", minval = 0.3, maxval = 3.0, step = 0.1, group = grpVis, tooltip = "Vertical label offset from candle in ATR units. Prevents label-candle overlap.")
showZoneBand = input.bool(false, "Show Trendline Zone Band", group = grpVis, tooltip = "Draw a subtle shaded band around each active trendline to visualize it as a reaction zone.")
zoneBandATR  = input.float(0.2, "Zone Band Width (ATR)", minval = 0.1, maxval = 1.0, step = 0.05, group = grpVis, tooltip = "Zone band thickness around the trendline in ATR units.")
confluenceATR = input.float(0.9, "Label Confluence Grouping (ATR)", minval = 0.0, maxval = 2.0, step = 0.1, group = grpVis, tooltip = "Merges break labels that fall within this ATR distance of an existing label on the same bar range. Set to 0 to disable.")
showRetest  = input.bool(false, "Show Retest Markers", group = grpVis)
showFailed  = input.bool(false, "Show Failed Retest Markers", group = grpVis)
colorizeBar = input.bool(true, "Colorize Break Bar Border", group = grpVis)
breakCooldownBars = input.int(6, "Break Label Cooldown Bars", minval = 0, maxval = 30, group = grpVis, tooltip = "Minimum spacing between printed break labels. Detection still runs; this only reduces label crowding.")
maxBreakLabels = input.int(4, "Max Break Labels", minval = 3, maxval = 20, group = grpVis, tooltip = "Caps visible break labels so the chart stays publication-ready while still showing enough recent context.")
maxRetestMarkers = input.int(12, "Max Retest Markers", minval = 3, maxval = 60, group = grpVis, tooltip = "Caps visible retest/failure markers to keep the chart responsive and publication-ready.")

// Panel
showPanel   = input.bool(true, "Show Info Panel", group = grpPnl)
panelPos    = input.string("Top Right", "Panel Position", options = ["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group = grpPnl)
panelTheme  = input.string("Dark", "Panel Theme", options = ["Dark","Light"], group = grpPnl)
proofTimeout = input.int(40, "Proof Window Bars", minval = 5, maxval = 200, group = grpPnl, tooltip = "Maximum bars a break follow-through window stays open before it is left uncounted in the proof rate.")

// ─────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────
f_toSize(s) =>
    s == "Small" ? size.small : s == "Large" ? size.large : size.normal

f_panelPos(p) =>
    p == "Top Right"     ? position.top_right :
       p == "Top Left"      ? position.top_left :
       p == "Middle Right"  ? position.middle_right :
       p == "Middle Left"   ? position.middle_left :
       p == "Bottom Right"  ? position.bottom_right :
       position.bottom_left

// Luminance-based contrast: dark ink on bright fills, light ink on dark fills.
f_text_on(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

// Vertical anti-collision: nudge a new label away from nearby existing labels.
f_avoid_overlap(array<label> labels, float desiredY, bool placeAbove, float safe) =>
    float y = desiredY
    float minGap = safe * 1.25
    int n = array.size(labels)
    if n > 0
        bool moved = true
        int guard = 0
        while moved and guard < 18
            moved := false
            for i = 0 to n - 1
                label lb = array.get(labels, i)
                if math.abs(label.get_x(lb) - bar_index) <= 26
                    if math.abs(label.get_y(lb) - y) < minGap
                        y := placeAbove ? y + minGap : y - minGap
                        moved := true
            guard += 1
    y

labSize  = f_toSize(fontSizeOpt)
panSize  = f_toSize(panelFntOpt)

// Theme-aware panel colors
themeBg     = panelTheme == "Light" ? color.rgb(248, 250, 252) : panelBg
themeBorder = panelTheme == "Light" ? color.rgb(203, 213, 225) : panelBorder
themeLabel  = panelTheme == "Light" ? color.rgb(71, 85, 105)   : panelLabelCol
themeValue  = panelTheme == "Light" ? color.rgb(15, 23, 42)    : panelValueCol

// ─────────────────────────────────────────────────
// CORE DATA
// ─────────────────────────────────────────────────
atr14    = math.max(nz(ta.atr(14), ta.tr(true)), syminfo.mintick)
volAvg20 = ta.sma(volume, 20)

// ─────────────────────────────────────────────────
// TRENDLINE TYPE
// ─────────────────────────────────────────────────
type TL
    int    id
    float  x1
    float  y1
    float  x2
    float  y2
    float  slope
    bool   isBull
    bool   isMajor
    bool   broken
    int    breakBar
    float  breakScore
    bool   retestSeen
    bool   retestHeld
    bool   retestFailed
    int    retestBar
    line   ln
    line   lnUp
    line   lnDn
    label  lbl

var array<TL> bullTLs = array.new<TL>()
var array<TL> bearTLs = array.new<TL>()
var int tlIdCounter = 0

// ─────────────────────────────────────────────────
// PIVOT DETECTION (Major + Minor)
// ─────────────────────────────────────────────────
majPH = ta.pivothigh(high, majorPiv, majorPiv)
majPL = ta.pivotlow(low,   majorPiv, majorPiv)
minPH = ta.pivothigh(high, minorPiv, minorPiv)
minPL = ta.pivotlow(low,   minorPiv, minorPiv)

var array<float> majPHprice = array.new<float>()
var array<int>   majPHbar   = array.new<int>()
var array<float> majPLprice = array.new<float>()
var array<int>   majPLbar   = array.new<int>()
var array<float> minPHprice = array.new<float>()
var array<int>   minPHbar   = array.new<int>()
var array<float> minPLprice = array.new<float>()
var array<int>   minPLbar   = array.new<int>()

pivBarMaj = bar_index - majorPiv
pivBarMin = bar_index - minorPiv

if not na(majPH)
    array.push(majPHprice, majPH)
    array.push(majPHbar, pivBarMaj)
    if array.size(majPHprice) > 20
        array.shift(majPHprice)
        array.shift(majPHbar)

if not na(majPL)
    array.push(majPLprice, majPL)
    array.push(majPLbar, pivBarMaj)
    if array.size(majPLprice) > 20
        array.shift(majPLprice)
        array.shift(majPLbar)

if not na(minPH)
    array.push(minPHprice, minPH)
    array.push(minPHbar, pivBarMin)
    if array.size(minPHprice) > 20
        array.shift(minPHprice)
        array.shift(minPHbar)

if not na(minPL)
    array.push(minPLprice, minPL)
    array.push(minPLbar, pivBarMin)
    if array.size(minPLprice) > 20
        array.shift(minPLprice)
        array.shift(minPLbar)

// ─────────────────────────────────────────────────
// TRENDLINE CREATION
// ─────────────────────────────────────────────────
f_createTL(float p1, int b1, float p2, int b2, bool isBull, bool isMajor, int nextId) =>
    slope = (p2 - p1) / math.max(b2 - b1, 1)
    absSlope = math.abs(slope)
    atrNorm = atr14 > 0 ? absSlope / atr14 : 0.0
    TL newTL = na
    if atrNorm >= minSlopeATR
        newTL := TL.new(
             id        = nextId,
             x1        = b1,
             y1        = p1,
             x2        = b2,
             y2        = p2,
             slope     = slope,
             isBull    = isBull,
             isMajor   = isMajor,
             broken    = false,
             breakBar  = 0,
             breakScore = 0.0,
             retestSeen  = false,
             retestHeld  = false,
             retestFailed = false,
             retestBar   = 0,
             ln        = na,
             lnUp      = na,
             lnDn      = na,
             lbl       = na)
    newTL

f_drawTL(TL t) =>
    width   = t.isMajor ? 3 : 2
    lstyle  = t.isMajor ? line.style_solid : line.style_dashed
    projX   = bar_index + extendBars
    projY   = t.y2 + t.slope * (projX - t.x2)
    t.ln := line.new(math.round(t.x1), t.y1, projX, projY, xloc = xloc.bar_index, color = tlNeutral, style = lstyle, width = width)
    if showZoneBand and t.isMajor and atr14 > 0
        bw = atr14 * zoneBandATR
        bandCol = color.new(tlNeutral, 82)
        t.lnUp := line.new(math.round(t.x1), t.y1 + bw, projX, projY + bw, xloc = xloc.bar_index, color = bandCol, style = line.style_solid, width = 1)
        t.lnDn := line.new(math.round(t.x1), t.y1 - bw, projX, projY - bw, xloc = xloc.bar_index, color = bandCol, style = line.style_solid, width = 1)
    t

// Try to form new Major bull trendline (last 2 pivot lows, ascending)
if array.size(majPLprice) >= 2 and not na(majPL)
    sz = array.size(majPLprice)
    p1 = array.get(majPLprice, sz - 2)
    b1 = array.get(majPLbar,   sz - 2)
    p2 = array.get(majPLprice, sz - 1)
    b2 = array.get(majPLbar,   sz - 1)
    if p2 > p1
        tlIdCounter += 1
        newTL = f_createTL(p1, b1, p2, b2, true, true, tlIdCounter)
        if not na(newTL)
            newTL := f_drawTL(newTL)
            array.push(bullTLs, newTL)

// Try to form new Major bear trendline (last 2 pivot highs, descending)
if array.size(majPHprice) >= 2 and not na(majPH)
    sz = array.size(majPHprice)
    p1 = array.get(majPHprice, sz - 2)
    b1 = array.get(majPHbar,   sz - 2)
    p2 = array.get(majPHprice, sz - 1)
    b2 = array.get(majPHbar,   sz - 1)
    if p2 < p1
        tlIdCounter += 1
        newTL = f_createTL(p1, b1, p2, b2, false, true, tlIdCounter)
        if not na(newTL)
            newTL := f_drawTL(newTL)
            array.push(bearTLs, newTL)

// Minor bull trendline
if showMinor and array.size(minPLprice) >= 2 and not na(minPL)
    sz = array.size(minPLprice)
    p1 = array.get(minPLprice, sz - 2)
    b1 = array.get(minPLbar,   sz - 2)
    p2 = array.get(minPLprice, sz - 1)
    b2 = array.get(minPLbar,   sz - 1)
    if p2 > p1
        tlIdCounter += 1
        newTL = f_createTL(p1, b1, p2, b2, true, false, tlIdCounter)
        if not na(newTL)
            newTL := f_drawTL(newTL)
            array.push(bullTLs, newTL)

// Minor bear trendline
if showMinor and array.size(minPHprice) >= 2 and not na(minPH)
    sz = array.size(minPHprice)
    p1 = array.get(minPHprice, sz - 2)
    b1 = array.get(minPHbar,   sz - 2)
    p2 = array.get(minPHprice, sz - 1)
    b2 = array.get(minPHbar,   sz - 1)
    if p2 < p1
        tlIdCounter += 1
        newTL = f_createTL(p1, b1, p2, b2, false, false, tlIdCounter)
        if not na(newTL)
            newTL := f_drawTL(newTL)
            array.push(bearTLs, newTL)

// Cap active TLs
f_capTLs(array<TL> arr) =>
    while array.size(arr) > maxActive
        oldTL = array.shift(arr)
        if not na(oldTL.ln)
            line.delete(oldTL.ln)
        if not na(oldTL.lnUp)
            line.delete(oldTL.lnUp)
        if not na(oldTL.lnDn)
            line.delete(oldTL.lnDn)
        if not na(oldTL.lbl)
            label.delete(oldTL.lbl)

f_capTLs(bullTLs)
f_capTLs(bearTLs)

// ─────────────────────────────────────────────────
// BREAK DETECTION & SCORING
// ─────────────────────────────────────────────────
f_tlPriceAt(TL t, int b) =>
    t.y2 + t.slope * (b - t.x2)

f_extendLatestActive(array<TL> arr) =>
    int latestIdx = na
    float latestAnchor = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            TL t = array.get(arr, i)
            if not t.broken and (na(latestAnchor) or t.x2 > latestAnchor)
                latestAnchor := t.x2
                latestIdx := i
    if not na(latestIdx)
        TL t = array.get(arr, latestIdx)
        liveX = bar_index + extendBars
        liveY = t.y2 + t.slope * (liveX - t.x2)
        if not na(t.ln)
            line.set_x2(t.ln, liveX)
            line.set_y2(t.ln, liveY)
        if showZoneBand and t.isMajor and atr14 > 0
            bw = atr14 * zoneBandATR
            if not na(t.lnUp)
                line.set_x2(t.lnUp, liveX)
                line.set_y2(t.lnUp, liveY + bw)
            if not na(t.lnDn)
                line.set_x2(t.lnDn, liveX)
                line.set_y2(t.lnDn, liveY - bw)
        array.set(arr, latestIdx, t)

f_extendLatestActive(bullTLs)
f_extendLatestActive(bearTLs)

// Directly extend the latest relevant line so the monitoring path stays continuous.
if showLatestGuide and barstate.islast
    TL guideTL = na
    float guideRecency = na
    if array.size(bullTLs) > 0
        for i = 0 to array.size(bullTLs) - 1
            TL t = array.get(bullTLs, i)
            bullRecency = t.broken ? t.breakBar : t.x2
            if not na(t.ln) and (na(guideRecency) or bullRecency > guideRecency)
                guideRecency := bullRecency
                guideTL := t
    if array.size(bearTLs) > 0
        for i = 0 to array.size(bearTLs) - 1
            TL t = array.get(bearTLs, i)
            bearRecency = t.broken ? t.breakBar : t.x2
            if not na(t.ln) and (na(guideRecency) or bearRecency > guideRecency)
                guideRecency := bearRecency
                guideTL := t
    if not na(guideTL)
        guideEndX = bar_index + latestGuideBars
        guideEndY = f_tlPriceAt(guideTL, guideEndX)
        if not na(guideTL.ln)
            line.set_x2(guideTL.ln, guideEndX)
            line.set_y2(guideTL.ln, guideEndY)
        if showZoneBand and guideTL.isMajor and atr14 > 0
            bw = atr14 * zoneBandATR
            if not na(guideTL.lnUp)
                line.set_x2(guideTL.lnUp, guideEndX)
                line.set_y2(guideTL.lnUp, guideEndY + bw)
            if not na(guideTL.lnDn)
                line.set_x2(guideTL.lnDn, guideEndX)
                line.set_y2(guideTL.lnDn, guideEndY - bw)

f_scoreBreak(TL t, int bar) =>
    volRatio = volAvg20 > 0 ? volume / volAvg20 : 0.0
    volPts   = math.min(25.0, (volRatio / volMultThr) * 25.0)
    slopeNorm = atr14 > 0 ? math.abs(t.slope) / atr14 : 0.0
    slopePts  = math.min(20.0, slopeNorm * 80.0)
    tlPx = f_tlPriceAt(t, bar)
    imp  = atr14 > 0 ? math.abs(close - tlPx) / atr14 : 0.0
    impPts = math.min(25.0, imp * 25.0)
    retestBase = 18.0
    majBonus = t.isMajor ? 10.0 : 0.0
    total = volPts + slopePts + impPts + retestBase + majBonus
    math.min(100.0, total)

// Confluence grouping state
var float lastLabY    = na
var int   lastLabBar  = na

f_confluenceSkip(float yPos, int curBar) =>
    bool skip = false
    if confluenceATR > 0 and not na(lastLabY) and not na(lastLabBar) and atr14 > 0
        if math.abs(curBar - lastLabBar) <= 3 and math.abs(yPos - lastLabY) <= atr14 * confluenceATR
            skip := true
    skip

f_stateColor(float score, bool isBreakBull) =>
    // Tier by quality: high = strong state color, med = neutral amber, low = opaque muted slate
    col = score >= highQthr ? (isBreakBull ? bullColor : bearColor) : score >= medQthr ? neutralColor : tlNeutral
    col

f_lineStrength(TL t) =>
    ageBars = math.max(t.x2 - t.x1, 1)
    ageRef = math.max(t.isMajor ? majorPiv : minorPiv, 1)
    agePts = math.min(35.0, (ageBars / ageRef) * 12.0)
    slopeNorm = atr14 > 0 ? math.abs(t.slope) / atr14 : 0.0
    slopePts = math.min(35.0, slopeNorm * 140.0)
    tierPts = t.isMajor ? 30.0 : 15.0
    math.min(100.0, agePts + slopePts + tierPts)

f_grade(float score) =>
    na(score) ? "Waiting" : score >= highQthr ? "Clean" : score >= medQthr ? "Review" : "Weak"

f_strengthText(float strength) =>
    na(strength) ? "—" : (strength >= 70 ? "Strong " : strength >= 50 ? "Usable " : "Thin ") + str.tostring(math.round(strength))

f_breakAction(float score, bool isMajor) =>
    action = "Avoid Chase"
    if score >= readyQthr and isMajor
        action := "Plan Retest"
    else if score >= readyQthr
        action := "Track Break"
    else if score >= medQthr
        action := "Wait Retest"
    action

f_labelAction(float score, bool isMajor) =>
    action = "AVOID"
    if score >= readyQthr and isMajor
        action := "PLAN"
    else if score >= readyQthr
        action := "TRACK"
    else if score >= medQthr
        action := "WAIT"
    action

f_retestRiskText(float score, bool retestSeen, bool retestHeld, bool retestFailed) =>
    risk = "—"
    if not na(score)
        if retestFailed
            risk := "High / Failed"
        else if retestHeld
            risk := "Low / Held"
        else if not retestSeen
            risk := score >= readyQthr ? "Medium / Pending" : score >= medQthr ? "High / Pending" : "Very High"
        else
            risk := "Window Closed"
    risk

f_actionText(float score, bool isMajor, bool retestSeen, bool retestHeld, bool retestFailed) =>
    action = "Watch Line"
    if not na(score)
        if retestFailed
            action := "Failure Risk"
        else if retestHeld and score >= readyQthr
            action := "Review Continuation"
        else if retestHeld
            action := "Accept With Caution"
        else if not retestSeen
            action := f_breakAction(score, isMajor)
        else
            action := "Avoid Chase"
    action

f_confirmOK(float tlPx) =>
    volOK = volAvg20 > 0 ? volume / volAvg20 >= 1.10 : true
    impulseOK = atr14 > 0 ? math.abs(close - tlPx) / atr14 >= 0.25 : true
    confirmMode == "Close Break" or (confirmMode == "Close + Volume" and volOK) or (confirmMode == "Close + Impulse" and impulseOK)

f_trackRetestLabel(array<label> marks, label l) =>
    if not na(l)
        array.push(marks, l)
        while array.size(marks) > maxRetestMarkers
            oldLbl = array.shift(marks)
            if not na(oldLbl)
                label.delete(oldLbl)

f_trackBreakLabel(array<label> marks, label l) =>
    if not na(l)
        array.push(marks, l)
        while array.size(marks) > maxBreakLabels
            oldLbl = array.shift(marks)
            if not na(oldLbl)
                label.delete(oldLbl)

var int lastPrintedBreakBar = na
var box planPocket = na
var label planPocketLbl = na
var line planTargetLine = na
var line planInvalidLine = na
var label planTargetLbl = na
var label planInvalidLbl = na
var array<label> breakLabels = array.new<label>()
var array<label> retestMarkers = array.new<label>()

if not showRetestPocket and not na(planPocket)
    box.delete(planPocket)
    planPocket := na
if not showRetestPocket and not na(planPocketLbl)
    label.delete(planPocketLbl)
    planPocketLbl := na
if not showPlannerRails and not na(planTargetLine)
    line.delete(planTargetLine)
    planTargetLine := na
if not showPlannerRails and not na(planInvalidLine)
    line.delete(planInvalidLine)
    planInvalidLine := na
if not showPlannerRails and not na(planTargetLbl)
    label.delete(planTargetLbl)
    planTargetLbl := na
if not showPlannerRails and not na(planInvalidLbl)
    label.delete(planInvalidLbl)
    planInvalidLbl := na

// Check bullish TLs for downward break (close below TL → break direction = Bear)
if array.size(bullTLs) > 0
    for i = array.size(bullTLs) - 1 to 0
        TL t = array.get(bullTLs, i)
        if not t.broken
            tlPx = f_tlPriceAt(t, bar_index)
            if close < tlPx and close[1] >= f_tlPriceAt(t, bar_index - 1) and f_confirmOK(tlPx)
                t.broken := true
                t.breakBar := bar_index
                t.breakScore := f_scoreBreak(t, bar_index)
                guideX = bar_index + brokenGuideBars
                guideY = f_tlPriceAt(t, guideX)
                if not na(t.ln)
                    line.set_x2(t.ln, guideX)
                    line.set_y2(t.ln, guideY)
                    line.set_color(t.ln, color.new(bearColor, 65))
                if not na(t.lnUp) and atr14 > 0
                    line.set_x2(t.lnUp, guideX)
                    line.set_y2(t.lnUp, guideY + atr14 * zoneBandATR)
                    line.set_color(t.lnUp, color.new(bearColor, 90))
                if not na(t.lnDn) and atr14 > 0
                    line.set_x2(t.lnDn, guideX)
                    line.set_y2(t.lnDn, guideY - atr14 * zoneBandATR)
                    line.set_color(t.lnDn, color.new(bearColor, 90))
                qStr = str.tostring(math.round(t.breakScore))
                majStr = t.isMajor ? " M" : ""
                labTxt = "BEAR Q" + qStr + majStr + "\n" + f_labelAction(t.breakScore, t.isMajor)
                labCol = f_stateColor(t.breakScore, false)
                yPos = low - atr14 * labelOffATR
                canPrint = na(lastPrintedBreakBar) or bar_index - lastPrintedBreakBar > breakCooldownBars
                if canPrint and not f_confluenceSkip(yPos, bar_index)
                    yPos := f_avoid_overlap(breakLabels, yPos, false, atr14)
                    t.lbl := label.new(bar_index, yPos, labTxt, style = label.style_label_up, color = labCol, textcolor = f_text_on(labCol), size = labSize)
                    f_trackBreakLabel(breakLabels, t.lbl)
                    lastLabY := yPos
                    lastLabBar := bar_index
                    lastPrintedBreakBar := bar_index
                pocketRight = bar_index + retestMaxBars
                if showRetestPocket and atr14 > 0
                    if not na(planPocket)
                        box.delete(planPocket)
                    if not na(planPocketLbl)
                        label.delete(planPocketLbl)
                    endPx = f_tlPriceAt(t, pocketRight)
                    pocketTop = math.max(tlPx, endPx) + atr14 * retestTol
                    pocketBottom = math.min(tlPx, endPx) - atr14 * retestTol
                    pocketMidX = bar_index + math.round(retestMaxBars * 0.5)
                    pocketMidY = (pocketTop + pocketBottom) * 0.5
                    planPocket := box.new(left = bar_index, top = pocketTop, right = pocketRight, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 90), border_color = color.new(bearColor, 65), border_width = 1)
                    planPocketLbl := label.new(pocketMidX, pocketMidY, "Retest Pocket", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(bearColor, 8), textcolor = f_text_on(bearColor), size = labSize)
                if showPlannerRails and atr14 > 0
                    if not na(planTargetLine)
                        line.delete(planTargetLine)
                    if not na(planInvalidLine)
                        line.delete(planInvalidLine)
                    if not na(planTargetLbl)
                        label.delete(planTargetLbl)
                    if not na(planInvalidLbl)
                        label.delete(planInvalidLbl)
                    railRight = bar_index + retestMaxBars * 2
                    targetPx = close - atr14 * plannerTargetATR
                    invalidPx = tlPx
                    planTargetLine := line.new(bar_index, targetPx, railRight, targetPx, xloc = xloc.bar_index, color = color.new(bearColor, 20), style = line.style_dashed, width = 1)
                    planInvalidLine := line.new(bar_index, invalidPx, railRight, invalidPx, xloc = xloc.bar_index, color = color.new(neutralColor, 15), style = line.style_dotted, width = 1)
                    planTargetLbl := label.new(railRight, targetPx, "T1", xloc = xloc.bar_index, style = label.style_label_left, color = bearColor, textcolor = f_text_on(bearColor), size = labSize)
                    planInvalidLbl := label.new(railRight, invalidPx, "Invalidation", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = f_text_on(neutralColor), size = labSize)
                array.set(bullTLs, i, t)

// Check bearish TLs for upward break (close above TL → break direction = Bull)
if array.size(bearTLs) > 0
    for i = array.size(bearTLs) - 1 to 0
        TL t = array.get(bearTLs, i)
        if not t.broken
            tlPx = f_tlPriceAt(t, bar_index)
            if close > tlPx and close[1] <= f_tlPriceAt(t, bar_index - 1) and f_confirmOK(tlPx)
                t.broken := true
                t.breakBar := bar_index
                t.breakScore := f_scoreBreak(t, bar_index)
                guideX = bar_index + brokenGuideBars
                guideY = f_tlPriceAt(t, guideX)
                if not na(t.ln)
                    line.set_x2(t.ln, guideX)
                    line.set_y2(t.ln, guideY)
                    line.set_color(t.ln, color.new(bullColor, 65))
                if not na(t.lnUp) and atr14 > 0
                    line.set_x2(t.lnUp, guideX)
                    line.set_y2(t.lnUp, guideY + atr14 * zoneBandATR)
                    line.set_color(t.lnUp, color.new(bullColor, 90))
                if not na(t.lnDn) and atr14 > 0
                    line.set_x2(t.lnDn, guideX)
                    line.set_y2(t.lnDn, guideY - atr14 * zoneBandATR)
                    line.set_color(t.lnDn, color.new(bullColor, 90))
                qStr = str.tostring(math.round(t.breakScore))
                majStr = t.isMajor ? " M" : ""
                labTxt = "BULL Q" + qStr + majStr + "\n" + f_labelAction(t.breakScore, t.isMajor)
                labCol = f_stateColor(t.breakScore, true)
                yPos = high + atr14 * labelOffATR
                canPrint = na(lastPrintedBreakBar) or bar_index - lastPrintedBreakBar > breakCooldownBars
                if canPrint and not f_confluenceSkip(yPos, bar_index)
                    yPos := f_avoid_overlap(breakLabels, yPos, true, atr14)
                    t.lbl := label.new(bar_index, yPos, labTxt, style = label.style_label_down, color = labCol, textcolor = f_text_on(labCol), size = labSize)
                    f_trackBreakLabel(breakLabels, t.lbl)
                    lastLabY := yPos
                    lastLabBar := bar_index
                    lastPrintedBreakBar := bar_index
                pocketRight = bar_index + retestMaxBars
                if showRetestPocket and atr14 > 0
                    if not na(planPocket)
                        box.delete(planPocket)
                    if not na(planPocketLbl)
                        label.delete(planPocketLbl)
                    endPx = f_tlPriceAt(t, pocketRight)
                    pocketTop = math.max(tlPx, endPx) + atr14 * retestTol
                    pocketBottom = math.min(tlPx, endPx) - atr14 * retestTol
                    pocketMidX = bar_index + math.round(retestMaxBars * 0.5)
                    pocketMidY = (pocketTop + pocketBottom) * 0.5
                    planPocket := box.new(left = bar_index, top = pocketTop, right = pocketRight, bottom = pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, 90), border_color = color.new(bullColor, 65), border_width = 1)
                    planPocketLbl := label.new(pocketMidX, pocketMidY, "Retest Pocket", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(bullColor, 8), textcolor = f_text_on(bullColor), size = labSize)
                if showPlannerRails and atr14 > 0
                    if not na(planTargetLine)
                        line.delete(planTargetLine)
                    if not na(planInvalidLine)
                        line.delete(planInvalidLine)
                    if not na(planTargetLbl)
                        label.delete(planTargetLbl)
                    if not na(planInvalidLbl)
                        label.delete(planInvalidLbl)
                    railRight = bar_index + retestMaxBars * 2
                    targetPx = close + atr14 * plannerTargetATR
                    invalidPx = tlPx
                    planTargetLine := line.new(bar_index, targetPx, railRight, targetPx, xloc = xloc.bar_index, color = color.new(bullColor, 20), style = line.style_dashed, width = 1)
                    planInvalidLine := line.new(bar_index, invalidPx, railRight, invalidPx, xloc = xloc.bar_index, color = color.new(neutralColor, 15), style = line.style_dotted, width = 1)
                    planTargetLbl := label.new(railRight, targetPx, "T1", xloc = xloc.bar_index, style = label.style_label_left, color = bullColor, textcolor = f_text_on(bullColor), size = labSize)
                    planInvalidLbl := label.new(railRight, invalidPx, "Invalidation", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = f_text_on(neutralColor), size = labSize)
                array.set(bearTLs, i, t)

// ─────────────────────────────────────────────────
// RETEST TRACKING
// ─────────────────────────────────────────────────
f_checkRetest(array<TL> arr, bool isBullArr) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            TL t = array.get(arr, i)
            if t.broken and not t.retestSeen
                barsSince = bar_index - t.breakBar
                if barsSince >= retestMinBars and barsSince <= retestMaxBars
                    tlPx = f_tlPriceAt(t, bar_index)
                    dist = math.abs(close - tlPx)
                    tol  = atr14 * retestTol
                    if dist <= tol
                        t.retestSeen := true
                        t.retestBar := bar_index
                        if isBullArr
                            t.retestHeld := close < tlPx
                            t.retestFailed := close >= tlPx
                        else
                            t.retestHeld := close > tlPx
                            t.retestFailed := close <= tlPx
                        if t.retestHeld
                            t.breakScore := math.min(100.0, t.breakScore + 15.0)
                        if t.retestFailed
                            t.breakScore := math.max(0.0, t.breakScore - 10.0)
                        retestYOff = atr14 * 0.4
                        breakDirTxt = t.isBull ? "Bear" : "Bull"
                        breakBullDir = not t.isBull
                        if not na(t.lbl)
                            updateTxt = (breakDirTxt == "Bull" ? "BULL" : "BEAR") + " Q" + str.tostring(math.round(t.breakScore)) + (t.isMajor ? " M" : "") + "\n" + (t.retestHeld ? "HELD" : "FAIL")
                            newLabCol = f_stateColor(t.breakScore, breakBullDir)
                            label.set_text(t.lbl, updateTxt)
                            label.set_color(t.lbl, newLabCol)
                            label.set_textcolor(t.lbl, f_text_on(newLabCol))
                            label.set_size(t.lbl, labSize)
                        if showRetest and t.retestHeld
                            heldY = t.isBull ? tlPx - retestYOff : tlPx + retestYOff
                            heldCol = color.new(t.isBull ? bearColor : bullColor, 25)
                            heldLbl = label.new(bar_index, heldY, "H", style = label.style_circle, color = heldCol, textcolor = f_text_on(t.isBull ? bearColor : bullColor), size = size.small)
                            f_trackRetestLabel(retestMarkers, heldLbl)
                        if showFailed and t.retestFailed
                            failY = t.isBull ? tlPx + retestYOff : tlPx - retestYOff
                            failLbl = label.new(bar_index, failY, "F", style = label.style_circle, color = color.new(neutralColor, 25), textcolor = f_text_on(neutralColor), size = size.small)
                            f_trackRetestLabel(retestMarkers, failLbl)
                        array.set(arr, i, t)
                else if barsSince > retestMaxBars
                    t.retestSeen := true
                    array.set(arr, i, t)

f_checkRetest(bullTLs, true)
f_checkRetest(bearTLs, false)

// ─────────────────────────────────────────────────
// STOP-AWARE BREAK FOLLOW-THROUGH PROOF (confirmed-bar gated)
// ─────────────────────────────────────────────────
// The break "holds" until price closes back through the broken trendline
// (reclaim), which is the script's own invalidation. A confirmed continuation
// of 1.5 ATR before reclaim is counted as a held, followed-through break.
var int proofTotal = 0
var int proofWins = 0
var bool proofPending = false
var int proofDir = 0
var float proofTarget = na
var float proofLineY2 = na
var float proofLineX2 = na
var float proofSlope = na
var int proofStartBar = na

if barstate.isconfirmed
    if proofPending
        float lineNow = proofLineY2 + proofSlope * (bar_index - proofLineX2)
        bool win = proofDir == 1 ? close >= proofTarget : close <= proofTarget
        bool reclaimed = proofDir == 1 ? close < lineNow : close > lineNow
        bool resolved = false
        if reclaimed
            proofTotal += 1
            resolved := true
        else if win
            proofWins += 1
            proofTotal += 1
            resolved := true
        if not resolved and not na(proofStartBar) and bar_index - proofStartBar >= proofTimeout
            resolved := true
        if resolved
            proofPending := false
    int newBreakDir = 0
    float newLineY2 = na
    float newLineX2 = na
    float newSlope = na
    if array.size(bullTLs) > 0
        for i = 0 to array.size(bullTLs) - 1
            TL t = array.get(bullTLs, i)
            if t.broken and t.breakBar == bar_index
                newBreakDir := -1
                newLineY2 := t.y2
                newLineX2 := t.x2
                newSlope := t.slope
    if array.size(bearTLs) > 0
        for i = 0 to array.size(bearTLs) - 1
            TL t = array.get(bearTLs, i)
            if t.broken and t.breakBar == bar_index
                newBreakDir := 1
                newLineY2 := t.y2
                newLineX2 := t.x2
                newSlope := t.slope
    if not proofPending and newBreakDir != 0
        proofPending := true
        proofDir := newBreakDir
        proofTarget := newBreakDir == 1 ? close + atr14 * 1.2 : close - atr14 * 1.2
        proofLineY2 := newLineY2
        proofLineX2 := newLineX2
        proofSlope := newSlope
        proofStartBar := bar_index

proofReady = proofTotal >= 6
proofRate = proofReady ? int(math.round(math.max(0.0, math.min(100.0, proofWins / proofTotal * 100.0)))) : na
proofText = proofReady ? str.tostring(proofRate) + "%  (" + str.tostring(proofTotal) + ")" : "Building (" + str.tostring(proofTotal) + ")"
proofColor = not proofReady ? neutralColor : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

// ─────────────────────────────────────────────────
// BAR COLORING
// ─────────────────────────────────────────────────
var bool   justBroke   = false
var bool   brokeBull   = false
if array.size(bullTLs) > 0
    for i = 0 to array.size(bullTLs) - 1
        TL t = array.get(bullTLs, i)
        if t.broken and t.breakBar == bar_index
            justBroke := true
            brokeBull := false
if array.size(bearTLs) > 0
    for i = 0 to array.size(bearTLs) - 1
        TL t = array.get(bearTLs, i)
        if t.broken and t.breakBar == bar_index
            justBroke := true
            brokeBull := true

barCol = not colorizeBar ? na : not justBroke ? na : (brokeBull ? bullColor : bearColor)
barcolor(barCol)

if barstate.isconfirmed
    justBroke := false

f_lastBreak(array<TL> arr) =>
    lastBar = 0
    float lastSc = na
    string lastDir = ""
    bool lastMaj = false
    bool lastRetestSeen = false
    bool lastHeld = false
    bool lastFailed = false
    float lastStrength = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            TL t = array.get(arr, i)
            if t.broken and t.breakBar > lastBar
                lastBar := t.breakBar
                lastSc := t.breakScore
                lastDir := t.isBull ? "Bear" : "Bull"
                lastMaj := t.isMajor
                lastRetestSeen := t.retestSeen
                lastHeld := t.retestHeld
                lastFailed := t.retestFailed
                lastStrength := f_lineStrength(t)
    [lastBar, lastSc, lastDir, lastMaj, lastRetestSeen, lastHeld, lastFailed, lastStrength]

f_bestLineStrength(array<TL> arr) =>
    float best = na
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            TL t = array.get(arr, i)
            if not t.broken
                st = f_lineStrength(t)
                best := na(best) ? st : math.max(best, st)
    best

// ─────────────────────────────────────────────────
// PANEL
// ─────────────────────────────────────────────────
var table panel = na

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(panelPos), 2, 7, bgcolor = themeBg, border_color = themeBorder, border_width = 1, frame_color = themeBorder, frame_width = 1)

    table.cell(panel, 0, 0, "AG Pro Auto Trendline Break Quality", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = panSize, text_halign = text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)

    [lbBullBar, lbBullSc, lbBullDir, lbBullMaj, lbBullSeen, lbBullHeld, lbBullFailed, lbBullStrength] = f_lastBreak(bullTLs)
    [lbBearBar, lbBearSc, lbBearDir, lbBearMaj, lbBearSeen, lbBearHeld, lbBearFailed, lbBearStrength] = f_lastBreak(bearTLs)
    lastScoreShow = lbBullBar >= lbBearBar ? lbBullSc : lbBearSc
    lastDirShow   = lbBullBar >= lbBearBar ? lbBullDir : lbBearDir
    lastMajShow   = lbBullBar >= lbBearBar ? lbBullMaj : lbBearMaj
    lastSeenShow  = lbBullBar >= lbBearBar ? lbBullSeen : lbBearSeen
    lastHeldShow  = lbBullBar >= lbBearBar ? lbBullHeld : lbBearHeld
    lastFailShow  = lbBullBar >= lbBearBar ? lbBullFailed : lbBearFailed
    lastStrengthShow = lbBullBar >= lbBearBar ? lbBullStrength : lbBearStrength

    bestBullStrength = f_bestLineStrength(bullTLs)
    bestBearStrength = f_bestLineStrength(bearTLs)
    activeStrength = not na(bestBullStrength) and not na(bestBearStrength) ? math.max(bestBullStrength, bestBearStrength) : not na(bestBullStrength) ? bestBullStrength : bestBearStrength
    strengthShow = na(lastScoreShow) ? activeStrength : lastStrengthShow
    breakSideTxt = na(lastScoreShow) ? "No confirmed break" : lastDirShow + (lastMajShow ? " · Major" : " · Minor")
    breakQualityTxt = na(lastScoreShow) ? "Waiting" : f_grade(lastScoreShow) + " · Q:" + str.tostring(math.round(lastScoreShow))
    breakQualityCol = na(lastScoreShow) ? tlNeutral : f_stateColor(lastScoreShow, lastDirShow == "Bull")
    retestRiskTxt = na(lastScoreShow) ? "—" : f_retestRiskText(lastScoreShow, lastSeenShow, lastHeldShow, lastFailShow)
    retestRiskCol = lastFailShow ? bearColor : lastHeldShow ? bullColor : na(lastScoreShow) ? themeValue : lastScoreShow >= readyQthr ? neutralColor : bearColor
    lineStrengthTxt = f_strengthText(strengthShow)
    lineStrengthCol = na(strengthShow) ? themeValue : strengthShow >= 70 ? bullColor : strengthShow >= 50 ? neutralColor : bearColor
    actionTxt = na(lastScoreShow) ? (na(activeStrength) ? "Build Context" : "Watch Line") : f_actionText(lastScoreShow, lastMajShow, lastSeenShow, lastHeldShow, lastFailShow)
    actionCol = actionTxt == "Failure Risk" ? bearColor : actionTxt == "Review Continuation" ? bullColor : actionTxt == "Plan Retest" ? accentColor : actionTxt == "Avoid Chase" ? neutralColor : tlNeutral

    // Row 1 - Break Side (colored text)
    table.cell(panel, 0, 1, "Break Side", text_color = themeLabel, bgcolor = themeBg, text_size = panSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, breakSideTxt, text_color = na(lastScoreShow) ? themeValue : lastDirShow == "Bull" ? bullColor : bearColor, bgcolor = themeBg, text_size = panSize, text_halign = text.align_right)

    // Row 2 - Break Quality (filled)
    table.cell(panel, 0, 2, "Break Quality", text_color = themeLabel, bgcolor = themeBg, text_size = panSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, breakQualityTxt, text_color = na(lastScoreShow) ? themeValue : f_text_on(breakQualityCol), bgcolor = na(lastScoreShow) ? themeBg : breakQualityCol, text_size = panSize, text_halign = text.align_right)

    // Row 3 - Retest Risk (colored text)
    table.cell(panel, 0, 3, "Retest Risk", text_color = themeLabel, bgcolor = themeBg, text_size = panSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, retestRiskTxt, text_color = retestRiskCol, bgcolor = themeBg, text_size = panSize, text_halign = text.align_right)

    // Row 4 - Proof (filled)
    table.cell(panel, 0, 4, "Follow-Through Proof", text_color = themeLabel, bgcolor = themeBg, text_size = panSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, proofText, text_color = f_text_on(proofColor), bgcolor = proofColor, text_size = panSize, text_halign = text.align_right)

    // Row 5 - Line Strength (colored text)
    table.cell(panel, 0, 5, "Line Strength", text_color = themeLabel, bgcolor = themeBg, text_size = panSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, lineStrengthTxt, text_color = lineStrengthCol, bgcolor = themeBg, text_size = panSize, text_halign = text.align_right)

    // Row 6 - Action (filled)
    table.cell(panel, 0, 6, "Action", text_color = themeLabel, bgcolor = themeBg, text_size = panSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, actionTxt, text_color = f_text_on(actionCol), bgcolor = actionCol, text_size = panSize, text_halign = text.align_right)

// ─────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────
bool newHighQBreak = false
bool newMajorBreak = false
bool newReadyBreak = false
bool newRetestHeld = false
bool newFailureRisk = false
if array.size(bullTLs) > 0
    for i = 0 to array.size(bullTLs) - 1
        TL t = array.get(bullTLs, i)
        if t.broken and t.breakBar == bar_index
            if t.breakScore >= highQthr
                newHighQBreak := true
            if t.breakScore >= readyQthr
                newReadyBreak := true
            if t.isMajor
                newMajorBreak := true
        if t.retestBar == bar_index
            if t.retestHeld
                newRetestHeld := true
            if t.retestFailed
                newFailureRisk := true
if array.size(bearTLs) > 0
    for i = 0 to array.size(bearTLs) - 1
        TL t = array.get(bearTLs, i)
        if t.broken and t.breakBar == bar_index
            if t.breakScore >= highQthr
                newHighQBreak := true
            if t.breakScore >= readyQthr
                newReadyBreak := true
            if t.isMajor
                newMajorBreak := true
        if t.retestBar == bar_index
            if t.retestHeld
                newRetestHeld := true
            if t.retestFailed
                newFailureRisk := true

alertcondition(newHighQBreak, title = "High Quality Trendline Break", message = "High Quality Trendline Break detected on {{ticker}} ({{interval}})")
alertcondition(newMajorBreak, title = "Major Trendline Break",        message = "Major Trendline Break detected on {{ticker}} ({{interval}})")
alertcondition(newReadyBreak, title = "Trendline Break Ready", message = "Trendline Break Ready state detected on {{ticker}} ({{interval}})")
alertcondition(newRetestHeld, title = "Trendline Retest Held", message = "Trendline Retest Held state detected on {{ticker}} ({{interval}})")
alertcondition(newFailureRisk, title = "Trendline Retest Failure Risk", message = "Trendline Retest Failure Risk state detected on {{ticker}} ({{interval}})")
````
