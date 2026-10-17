# SMC Universal + 50% Rule v2 [SCORED]

- url: https://www.tradingview.com/script/SvfY2AMh-SMC-Universal-50-Rule-v2-SCORED/
- type: indicator
- pine_id: PUB;10231c50c257438bb910e2b8a4e0e4e6
- version: 1.0

## Description

The price location indicator

Tell us where the price currently rests in the Premium or the Discount zone

With some layers in the settings panel to help choose the time frame of choice to get that reading

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// SMC UNIVERSAL + 50% RULE v2 [SCORED]
// ══════════════════════════════════════════════════════════
// Version: 2.0.1
//
// v2.0.1 fixes:
//   • tpPrice and lvlPx: multi-line nested ternaries → if/else
//     (Pine v6 parser was rejecting them with CE10156)
//   • Dashboard: opaque bg + explicit per-cell bgcolor
//     (was 80% transparent, effectively invisible on dark theme)
//
// Builds on the focused MTF equilibrium overlay (v1) with:
//   • Liquidity sweep detection at ITH / ITL / EQ50
//   • Engulfing patterns gated to points of interest (POI)
//   • Order-flow bias: signed volume + cumulative delta + absorption
//   • Confluence scoring → A+ / A / B / C grade
//   • Dashboard panel
//   • JSON-toggleable alerts for screener feeds / paper-exec routing
//
// Architecture intent kept from v1:
//   • Weekly is the single source of truth for ITH / ITL / EQ
//     (request.security with lookahead_on)
//   • CHoCH/BOS NOT added — would compete with weekly bias
//   • EQH/EQL (FibStruct concept) NOT added — naming conflict +
//     scale mismatch with weekly framework
//
// IMPORTANT: "delta" here is APPROXIMATED from bar direction, not
// from tick/bid-ask data (Pine doesn't expose those). It's a
// relative metric — useful for comparing pressure across bars in
// the same zone, NOT a true order-flow footprint.

indicator("SMC Universal + 50% Rule v2 [SCORED]",
     overlay = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 100,
     max_bars_back    = 2000)

// ══════════════════════════════════════
// INPUTS
// ══════════════════════════════════════

// ─── Timeframe Anchoring ─────────────────────────────────────
grp_mtf = "📐 Timeframe Anchoring"
tf_anchor = input.timeframe("W", "Anchor Timeframe", group = grp_mtf,
     tooltip = "Source TF for ITH/ITL pivots. Weekly is canonical for the 50% Rule.")

// ─── Structure ───────────────────────────────────────────────
grp_struct = "🏗️ 50% Rule Structure"
leftBars  = input.int(3, "Pivot Left Strength",  minval = 1, group = grp_struct)
rightBars = input.int(3, "Pivot Right Strength", minval = 1, group = grp_struct)

// ─── Points of Interest (POI) ────────────────────────────────
grp_poi = "🎯 Points of Interest"
poiPctInput = input.float(5.0, "POI Range (% of price)", minval = 0.5, maxval = 20.0, step = 0.5, group = grp_poi,
     tooltip = "Distance from key level (as % of price) within which order flow is tracked.\nTwo bands work in parallel:\n• POI band (this) — broad, gates delta tracking\n• Touch tolerance (below) — tight, gates engulf/sweep")
atrTolMultInput = input.float(0.5, "Level Touch Tolerance (× ATR)", minval = 0.1, maxval = 2.0, step = 0.1, group = grp_poi,
     tooltip = "How close to a level counts as 'at the level' for sweep / engulf detection.\nLower = stricter")

// ─── Order Flow ──────────────────────────────────────────────
grp_flow = "💧 Order Flow"
volMaLenInput = input.int(20, "Volume MA Length", minval = 5, group = grp_flow)
volSpikeMultInput = input.float(2.0, "Volume Spike Threshold (× MA)", minval = 1.1, step = 0.1, group = grp_flow,
     tooltip = "Volume must exceed this multiple of the MA to count as a 'spike' (worth +1 score)")
absorbVolMultInput = input.float(1.5, "Absorption Volume Threshold (× MA)", minval = 1.1, step = 0.1, group = grp_flow,
     tooltip = "Lower threshold for absorption — pattern matters more than spike size for absorption.")
absorbWickRatioInput = input.float(0.5, "Absorption Wick Ratio", minval = 0.3, maxval = 0.9, step = 0.05, group = grp_flow,
     tooltip = "Wick must be at least this fraction of total range for absorption.\nAbsorption High = upper wick (sellers stepping in).\nAbsorption Low = lower wick (buyers stepping in).")
deltaSignificanceInput = input.float(3.0, "Cumulative Delta Significance (× volMA)", minval = 1.0, step = 0.5, group = grp_flow,
     tooltip = "Cumulative delta in zone must exceed this multiple of vol-MA to register as 'building'.")

// ─── Engulfing ───────────────────────────────────────────────
grp_eng = "🕯️ Engulfing"
showEngulfInput = input.bool(true, "Detect Engulfing at POI", group = grp_eng,
     tooltip = "Only fires when current bar is at ITH / ITL / EQ within touch tolerance.")
strictEngulfInput = input.bool(true, "Strict Engulfing", group = grp_eng,
     tooltip = "Strict: current body strictly contains previous body on both sides.\nLoose: equality on one side allowed (more signals, lower quality).")

// ─── Scoring & Grades ────────────────────────────────────────
grp_score = "📊 Confluence Scoring"
ptsAtLevel    = input.int(0, "Points: At Level (gate, no score)",  minval = 0, group = grp_score)
ptsSweep      = input.int(3, "Points: Liquidity Sweep",            minval = 0, group = grp_score)
ptsEngulf     = input.int(2, "Points: Engulfing at POI",           minval = 0, group = grp_score)
ptsAbsorb     = input.int(2, "Points: Absorption",                  minval = 0, group = grp_score)
ptsVolSpike   = input.int(1, "Points: Volume Spike",                minval = 0, group = grp_score)
ptsDeltaAlign = input.int(2, "Points: Delta Aligned w/ Setup",     minval = 0, group = grp_score)
ptsZoneAlign  = input.int(1, "Points: Premium/Discount Aligned",   minval = 0, group = grp_score)
gradeAplusMin = input.int(8, "A+ Score Threshold", minval = 1, group = grp_score)
gradeAMin     = input.int(5, "A Score Threshold",  minval = 1, group = grp_score)
gradeBMin     = input.int(3, "B Score Threshold",  minval = 1, group = grp_score)

// ─── Dashboard ───────────────────────────────────────────────
grp_dash = "📋 Dashboard"
showDashInput = input.bool(true, "Show Dashboard", group = grp_dash)
dashPosStr = input.string("Top Right", "Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = grp_dash)
dashTextSizeInput = input.string("Small", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grp_dash,
     tooltip = "Dashboard font size. Header auto-scales one step larger than body cells.")

// ─── Alerts ──────────────────────────────────────────────────
grp_alert = "🔔 Alerts"
fireOnAplusInput = input.bool(true, "Fire Graded Alerts on A+ Only", group = grp_alert,
     tooltip = "ON = only A+ grade fires the graded signal alert.\nOFF = also fires for A grade.\nSweep alerts (separate) always fire when a sweep occurs.")
webhookInput = input.bool(true, "JSON Webhook Format", group = grp_alert,
     tooltip = "ON = JSON for screener / paper-exec ingestion.\nOFF = readable text.")

// ─── Visuals ─────────────────────────────────────────────────
grp_vis = "🎨 Visuals"
ithColor   = input.color(color.red,    "ITH",    inline = "v1", group = grp_vis)
itlColor   = input.color(color.teal,   "ITL",    inline = "v1", group = grp_vis)
eqColor    = input.color(color.yellow, "EQ50",   inline = "v1", group = grp_vis)
sweepColor = input.color(color.orange, "Sweep",  inline = "v2", group = grp_vis)
bullColor  = input.color(#00E676,      "Bull",   inline = "v2", group = grp_vis)
bearColor  = input.color(#FF5252,      "Bear",   inline = "v2", group = grp_vis)
showMomentumInput = input.bool(true, "Show v1 Momentum Triangles", group = grp_vis,
     tooltip = "EMA9 crossover + 2× volume — preserved from v1.")

// ══════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════
getDashPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

getDashBodySize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

getDashHeaderSize(string s) =>
    switch s
        "Tiny"   => size.small
        "Small"  => size.normal
        "Normal" => size.large
        "Large"  => size.huge
        => size.normal

dashBodySize   = getDashBodySize(dashTextSizeInput)
dashHeaderSize = getDashHeaderSize(dashTextSizeInput)

// ══════════════════════════════════════
// MTF PIVOT CALCULATION  (v1 logic — preserved)
// ══════════════════════════════════════
[mtfITH, mtfITL] = request.security(syminfo.tickerid, tf_anchor,
     [ta.pivothigh(high, leftBars, rightBars),
      ta.pivotlow(low,   leftBars, rightBars)],
     lookahead = barmerge.lookahead_on)

// ══════════════════════════════════════
// PERSISTENT LEVEL MEMORY  (v1 logic — preserved)
// ══════════════════════════════════════
var float lastITH = na
var float lastITL = na

if not na(mtfITH)
    lastITH := mtfITH
if not na(mtfITL)
    lastITL := mtfITL

float eqVal = (not na(lastITH) and not na(lastITL)) ? (lastITH + lastITL) / 2.0 : na

// ══════════════════════════════════════
// LEVEL DRAWINGS (lines + labels — v1 pattern, fixed object reuse)
// ══════════════════════════════════════
var line ithLine = line.new(na, na, na, na, color = ithColor, width = 2)
var line itlLine = line.new(na, na, na, na, color = itlColor, width = 2)
var line eqLine  = line.new(na, na, na, na, color = eqColor,  width = 2, style = line.style_dotted)

var label ithLabel = label.new(na, na, "", color = ithColor, textcolor = color.white, style = label.style_label_left, size = size.normal)
var label itlLabel = label.new(na, na, "", color = itlColor, textcolor = color.white, style = label.style_label_left, size = size.normal)
var label eqLabel  = label.new(na, na, "", color = eqColor,  textcolor = color.black, style = label.style_label_left, size = size.normal)

if barstate.islast
    if not na(lastITH)
        line.set_xy1(ithLine, bar_index[500], lastITH)
        line.set_xy2(ithLine, bar_index + 12, lastITH)
        label.set_xy(ithLabel, bar_index + 13, lastITH)
        label.set_text(ithLabel, "ITH: " + str.tostring(lastITH, format.mintick))
    if not na(lastITL)
        line.set_xy1(itlLine, bar_index[500], lastITL)
        line.set_xy2(itlLine, bar_index + 12, lastITL)
        label.set_xy(itlLabel, bar_index + 13, lastITL)
        label.set_text(itlLabel, "ITL: " + str.tostring(lastITL, format.mintick))
    if not na(eqVal)
        line.set_xy1(eqLine, bar_index[500], eqVal)
        line.set_xy2(eqLine, bar_index + 12, eqVal)
        label.set_xy(eqLabel, bar_index + 13, eqVal)
        label.set_text(eqLabel, "EQ: " + str.tostring(eqVal, format.mintick))

// ══════════════════════════════════════
// COMMON CALCULATIONS
// ══════════════════════════════════════
float atrValue = nz(ta.atr(14), 0.0)
float volMA    = nz(ta.sma(volume, volMaLenInput), volume)

// Two distance bands — see input tooltips for rationale
float touchTol = atrValue * atrTolMultInput
float poiTol   = close * poiPctInput / 100.0

// Distances to each level (na-safe — required because levels can be na on early bars)
float distITH = na(lastITH) ? na : math.abs(close - lastITH)
float distITL = na(lastITL) ? na : math.abs(close - lastITL)
float distEQ  = na(eqVal)   ? na : math.abs(close - eqVal)

// "At the level" — tight, ATR-based, gates engulf/sweep
bool atITH = not na(distITH) and distITH <= touchTol
bool atITL = not na(distITL) and distITL <= touchTol
bool atEQ  = not na(distEQ)  and distEQ  <= touchTol
bool atAnyLevel = atITH or atITL or atEQ

// "In POI zone" — broad, %-based, gates delta tracking
bool inPoiITH = not na(distITH) and distITH <= poiTol
bool inPoiITL = not na(distITL) and distITL <= poiTol
bool inPoiEQ  = not na(distEQ)  and distEQ  <= poiTol
bool inAnyPOI = inPoiITH or inPoiITL or inPoiEQ

// Nearest level (for dashboard) — manual scan, na-safe
string nearestName = "—"
float  nearestDist = na
if not na(distITH) and (na(nearestDist) or distITH < nearestDist)
    nearestDist := distITH
    nearestName := "ITH"
if not na(distEQ) and (na(nearestDist) or distEQ < nearestDist)
    nearestDist := distEQ
    nearestName := "EQ"
if not na(distITL) and (na(nearestDist) or distITL < nearestDist)
    nearestDist := distITL
    nearestName := "ITL"

// ══════════════════════════════════════
// PREMIUM / DISCOUNT ZONE
// ══════════════════════════════════════
bool inPremium  = not na(eqVal) and close > eqVal
bool inDiscount = not na(eqVal) and close < eqVal

// ══════════════════════════════════════
// LIQUIDITY SWEEPS at ITH / ITL / EQ
// ══════════════════════════════════════
var int lastSweptBar = na

bool sweepITH    = false
bool sweepITL    = false
bool sweepEQHigh = false
bool sweepEQLow  = false

if barstate.isconfirmed and bar_index != nz(lastSweptBar, -1)
    if not na(lastITH) and high > lastITH and close < lastITH and open < lastITH
        sweepITH := true
        lastSweptBar := bar_index
    else if not na(lastITL) and low < lastITL and close > lastITL and open > lastITL
        sweepITL := true
        lastSweptBar := bar_index
    else if not na(eqVal) and high > eqVal and close < eqVal and open < eqVal and inDiscount[1]
        sweepEQHigh := true
        lastSweptBar := bar_index
    else if not na(eqVal) and low < eqVal and close > eqVal and open > eqVal and inPremium[1]
        sweepEQLow := true
        lastSweptBar := bar_index

bool anySweep     = sweepITH or sweepITL or sweepEQHigh or sweepEQLow
bool sweepBullish = sweepITL or sweepEQLow
bool sweepBearish = sweepITH or sweepEQHigh

// ══════════════════════════════════════
// ENGULFING (gated to atAnyLevel)
// ══════════════════════════════════════
float bodyHi     = math.max(close, open)
float bodyLo     = math.min(close, open)
float body       = bodyHi - bodyLo
float prevBodyHi = math.max(close[1], open[1])
float prevBodyLo = math.min(close[1], open[1])
float prevBody   = prevBodyHi - prevBodyLo

bool bullishEngulfRaw = false
bool bearishEngulfRaw = false

if strictEngulfInput
    bullishEngulfRaw := close > open and close[1] < open[1] and body > prevBody and open < close[1] and close > open[1]
    bearishEngulfRaw := close < open and close[1] > open[1] and body > prevBody and open > close[1] and close < open[1]
else
    bullishEngulfRaw := close > open and close[1] < open[1] and body > prevBody and open <= close[1] and close >= open[1] and (open < close[1] or close > open[1])
    bearishEngulfRaw := close < open and close[1] > open[1] and body > prevBody and open >= close[1] and close <= open[1] and (open > close[1] or close < open[1])

bool bullEngulfAtPOI = showEngulfInput and bullishEngulfRaw and atAnyLevel and barstate.isconfirmed
bool bearEngulfAtPOI = showEngulfInput and bearishEngulfRaw and atAnyLevel and barstate.isconfirmed

// ══════════════════════════════════════
// ORDER FLOW: Signed Volume + Cumulative Delta + Absorption
// ══════════════════════════════════════
float signedVol = close > open ? volume : close < open ? -volume : 0.0

var float cumDelta   = 0.0
var int   barsInZone = 0

if inAnyPOI
    cumDelta   += signedVol
    barsInZone += 1
else if barsInZone > 0
    cumDelta   := 0.0
    barsInZone := 0

float upperWick  = high - bodyHi
float lowerWick  = bodyLo - low
float totalRange = math.max(high - low, syminfo.mintick)

bool volSpike       = volume > volMA * volSpikeMultInput
bool volAboveAbsorb = volume > volMA * absorbVolMultInput

bool absorptionHigh = volAboveAbsorb and (upperWick / totalRange) >= absorbWickRatioInput
bool absorptionLow  = volAboveAbsorb and (lowerWick / totalRange) >= absorbWickRatioInput

bool absorptionBullish = absorptionLow  and (atITL or (atEQ and inDiscount[1]))
bool absorptionBearish = absorptionHigh and (atITH or (atEQ and inPremium[1]))

float deltaSig = volMA * deltaSignificanceInput
string deltaState   = "—"
color  deltaStateClr = color.gray
if absorptionBullish
    deltaState    := "Bull absorbing"
    deltaStateClr := bullColor
else if absorptionBearish
    deltaState    := "Bear absorbing"
    deltaStateClr := bearColor
else if barsInZone > 0
    if cumDelta > deltaSig
        deltaState    := "Bull build (" + str.tostring(barsInZone) + ")"
        deltaStateClr := bullColor
    else if cumDelta < -deltaSig
        deltaState    := "Bear build (" + str.tostring(barsInZone) + ")"
        deltaStateClr := bearColor
    else
        deltaState    := "In zone (" + str.tostring(barsInZone) + ")"
        deltaStateClr := color.gray

// ══════════════════════════════════════
// CONFLUENCE SCORING → GRADE
// ══════════════════════════════════════
int bullScore = 0
int bearScore = 0

if atAnyLevel
    bullScore += ptsAtLevel
    if sweepBullish
        bullScore += ptsSweep
    if bullEngulfAtPOI
        bullScore += ptsEngulf
    if absorptionBullish
        bullScore += ptsAbsorb
    if volSpike and (sweepBullish or bullEngulfAtPOI or absorptionBullish)
        bullScore += ptsVolSpike
    if cumDelta > deltaSig and (atITL or atEQ)
        bullScore += ptsDeltaAlign
    if inDiscount
        bullScore += ptsZoneAlign

    bearScore += ptsAtLevel
    if sweepBearish
        bearScore += ptsSweep
    if bearEngulfAtPOI
        bearScore += ptsEngulf
    if absorptionBearish
        bearScore += ptsAbsorb
    if volSpike and (sweepBearish or bearEngulfAtPOI or absorptionBearish)
        bearScore += ptsVolSpike
    if cumDelta < -deltaSig and (atITH or atEQ)
        bearScore += ptsDeltaAlign
    if inPremium
        bearScore += ptsZoneAlign

bool hasBullTrigger = sweepBullish or bullEngulfAtPOI or absorptionBullish
bool hasBearTrigger = sweepBearish or bearEngulfAtPOI or absorptionBearish

int    finalScore = 0
string setupDir   = "—"
if hasBullTrigger and bullScore > bearScore
    finalScore := bullScore
    setupDir   := "LONG"
else if hasBearTrigger and bearScore > bullScore
    finalScore := bearScore
    setupDir   := "SHORT"

string grade    = "—"
color  gradeClr = color.gray
if finalScore >= gradeAplusMin
    grade    := "A+"
    gradeClr := color.fuchsia
else if finalScore >= gradeAMin
    grade    := "A"
    gradeClr := color.aqua
else if finalScore >= gradeBMin
    grade    := "B"
    gradeClr := color.yellow
else if finalScore > 0
    grade    := "C"
    gradeClr := color.gray

bool isBullSetup = setupDir == "LONG"  and finalScore >= gradeBMin
bool isBearSetup = setupDir == "SHORT" and finalScore >= gradeBMin

// ══════════════════════════════════════
// VISUAL MARKERS
// ══════════════════════════════════════
if sweepITH or sweepEQHigh
    label.new(bar_index, high, "✗",
         color = color.new(sweepColor, 100), textcolor = sweepColor,
         style = label.style_label_down, size = size.small,
         tooltip = "Sweep " + (sweepITH ? "ITH" : "EQ↑") + " @ " + str.tostring(sweepITH ? lastITH : eqVal, format.mintick))

if sweepITL or sweepEQLow
    label.new(bar_index, low, "✗",
         color = color.new(sweepColor, 100), textcolor = sweepColor,
         style = label.style_label_up, size = size.small,
         tooltip = "Sweep " + (sweepITL ? "ITL" : "EQ↓") + " @ " + str.tostring(sweepITL ? lastITL : eqVal, format.mintick))

if bullEngulfAtPOI
    label.new(bar_index, low, "▲",
         color = color.new(bullColor, 100), textcolor = bullColor,
         style = label.style_label_up, size = size.small,
         tooltip = "Bull engulf @ " + (atITL ? "ITL" : atEQ ? "EQ" : "ITH"))

if bearEngulfAtPOI
    label.new(bar_index, high, "▼",
         color = color.new(bearColor, 100), textcolor = bearColor,
         style = label.style_label_down, size = size.small,
         tooltip = "Bear engulf @ " + (atITH ? "ITH" : atEQ ? "EQ" : "ITL"))

if absorptionBullish
    label.new(bar_index, low - atrValue * 0.4, "●",
         color = color.new(bullColor, 100), textcolor = color.new(bullColor, 30),
         style = label.style_label_center, size = size.tiny,
         tooltip = "Bull absorption (long lower wick + heavy vol)")

if absorptionBearish
    label.new(bar_index, high + atrValue * 0.4, "●",
         color = color.new(bearColor, 100), textcolor = color.new(bearColor, 30),
         style = label.style_label_center, size = size.tiny,
         tooltip = "Bear absorption (long upper wick + heavy vol)")

if isBullSetup and finalScore >= gradeAMin
    label.new(bar_index, low, grade + " LONG",
         color = bullColor, textcolor = color.white,
         style = label.style_label_up, size = size.normal,
         tooltip = "Score: " + str.tostring(finalScore) + "\nNearest: " + nearestName + "\nDelta: " + deltaState)

if isBearSetup and finalScore >= gradeAMin
    label.new(bar_index, high, grade + " SHORT",
         color = bearColor, textcolor = color.white,
         style = label.style_label_down, size = size.normal,
         tooltip = "Score: " + str.tostring(finalScore) + "\nNearest: " + nearestName + "\nDelta: " + deltaState)

// ══════════════════════════════════════
// DASHBOARD  (v2.0.1 — opaque + per-cell bgcolor)
// ══════════════════════════════════════
DASH_BG       = color.new(#131722, 5)
DASH_BG_ALT   = color.new(#1C2030, 5)
DASH_BORDER   = color.new(#2A2E39, 0)
DASH_HEAD_BG  = color.new(#2962FF, 0)
DASH_TXT      = color.new(#E0E0E0, 0)
DASH_TXT_DIM  = color.new(#9E9E9E, 0)

var table dashTable = table.new(getDashPos(dashPosStr), 2, 12, DASH_BG, DASH_BORDER, 1, DASH_BORDER, 1)

if showDashInput and barstate.islast
    table.cell(dashTable, 0, 0, "SMC v2", text_color = color.white,
         bgcolor = DASH_HEAD_BG, text_size = dashHeaderSize, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, 0, 1, 0)

    string setupStr = setupDir == "—" ? "—" : (grade + " " + setupDir)
    color  setupClr = setupDir == "LONG" ? bullColor : setupDir == "SHORT" ? bearColor : DASH_TXT_DIM
    table.cell(dashTable, 0, 1, "Setup",  text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG)
    table.cell(dashTable, 1, 1, setupStr, text_color = setupClr,     text_size = dashBodySize, bgcolor = DASH_BG)

    table.cell(dashTable, 0, 2, "Score",                   text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG_ALT)
    table.cell(dashTable, 1, 2, str.tostring(finalScore), text_color = gradeClr,     text_size = dashBodySize, bgcolor = DASH_BG_ALT)

    string zoneStr = inPremium ? "Premium" : inDiscount ? "Discount" : "—"
    color  zoneClr = inPremium ? bearColor : inDiscount ? bullColor : DASH_TXT_DIM
    table.cell(dashTable, 0, 3, "Zone",  text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG)
    table.cell(dashTable, 1, 3, zoneStr, text_color = zoneClr,      text_size = dashBodySize, bgcolor = DASH_BG)

    string nearStr = "—"
    if not na(nearestDist) and atrValue > 0
        nearStr := nearestName + " (" + str.tostring(nearestDist / atrValue, "0.00") + " ATR)"
    table.cell(dashTable, 0, 4, "Near",  text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG_ALT)
    table.cell(dashTable, 1, 4, nearStr, text_color = DASH_TXT,     text_size = dashBodySize, bgcolor = DASH_BG_ALT)

    table.cell(dashTable, 0, 5, "Delta",    text_color = DASH_TXT_DIM,  text_size = dashBodySize, bgcolor = DASH_BG)
    table.cell(dashTable, 1, 5, deltaState, text_color = deltaStateClr, text_size = dashBodySize, bgcolor = DASH_BG)

    table.cell(dashTable, 0, 6, "ITH",                                                      text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG_ALT)
    table.cell(dashTable, 1, 6, na(lastITH) ? "—" : str.tostring(lastITH, format.mintick), text_color = ithColor,     text_size = dashBodySize, bgcolor = DASH_BG_ALT)

    table.cell(dashTable, 0, 7, "EQ",                                                  text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG)
    table.cell(dashTable, 1, 7, na(eqVal) ? "—" : str.tostring(eqVal, format.mintick), text_color = eqColor,      text_size = dashBodySize, bgcolor = DASH_BG)

    table.cell(dashTable, 0, 8, "ITL",                                                      text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG_ALT)
    table.cell(dashTable, 1, 8, na(lastITL) ? "—" : str.tostring(lastITL, format.mintick), text_color = itlColor,     text_size = dashBodySize, bgcolor = DASH_BG_ALT)

    table.cell(dashTable, 0, 9, "ATR(14)",                              text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG)
    table.cell(dashTable, 1, 9, str.tostring(atrValue, format.mintick), text_color = DASH_TXT,     text_size = dashBodySize, bgcolor = DASH_BG)

    table.cell(dashTable, 0, 10, "TF / Anchor",                        text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG_ALT)
    table.cell(dashTable, 1, 10, timeframe.period + " / " + tf_anchor, text_color = DASH_TXT,     text_size = dashBodySize, bgcolor = DASH_BG_ALT)

    table.cell(dashTable, 0, 11, "Ver",    text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG)
    table.cell(dashTable, 1, 11, "v2.0.1", text_color = DASH_TXT_DIM, text_size = dashBodySize, bgcolor = DASH_BG)

// ══════════════════════════════════════
// ALERTS
// ══════════════════════════════════════
string tickerStr = syminfo.tickerid
string tfStr     = timeframe.period
string priceStr  = str.tostring(close, format.mintick)

string activeLevel      = atITH ? "ITH" : atITL ? "ITL" : atEQ ? "EQ" : "—"
float  activeLevelPrice = atITH ? lastITH : atITL ? lastITL : atEQ ? eqVal : na

string setupTriggers = ""
if anySweep
    setupTriggers := setupTriggers + (setupTriggers == "" ? "sweep" : "+sweep")
if bullEngulfAtPOI or bearEngulfAtPOI
    setupTriggers := setupTriggers + (setupTriggers == "" ? "engulf" : "+engulf")
if absorptionBullish or absorptionBearish
    setupTriggers := setupTriggers + (setupTriggers == "" ? "absorb" : "+absorb")

bool fireSignal = (isBullSetup or isBearSetup) and
     (fireOnAplusInput ? finalScore >= gradeAplusMin : finalScore >= gradeAMin)

if fireSignal
    string actionStr = isBullSetup ? "buy" : "sell"
    float  slPrice   = isBullSetup ? close - atrValue * 1.5 : close + atrValue * 1.5
    // TP: prefer next opposing level if available, else 2.5× ATR.
    // if/else (not multi-line ternary) for Pine v6 compatibility.
    float tpPrice = na
    if isBullSetup
        if atITL and not na(eqVal)
            tpPrice := eqVal
        else if atEQ and not na(lastITH)
            tpPrice := lastITH
        else
            tpPrice := close + atrValue * 2.5
    else
        if atITH and not na(eqVal)
            tpPrice := eqVal
        else if atEQ and not na(lastITL)
            tpPrice := lastITL
        else
            tpPrice := close - atrValue * 2.5

    string slStr       = str.tostring(slPrice, format.mintick)
    string tpStr       = str.tostring(tpPrice, format.mintick)
    string lvlPriceStr = na(activeLevelPrice) ? "null" : str.tostring(activeLevelPrice, format.mintick)

    string jMsg = '{"action":"' + actionStr +
                  '","ticker":"' + tickerStr +
                  '","tf":"' + tfStr +
                  '","anchor_tf":"' + tf_anchor +
                  '","price":' + str.tostring(close) +
                  ',"grade":"' + grade +
                  '","score":' + str.tostring(finalScore) +
                  ',"setup":"' + setupTriggers +
                  '","level":"' + activeLevel +
                  '","level_price":' + lvlPriceStr +
                  ',"delta_state":"' + deltaState +
                  '","sl":' + slStr +
                  ',"tp":' + tpStr + '}'

    string tMsg = grade + " " + str.upper(actionStr) + " | " + tickerStr +
                  " | " + tfStr + " | " + priceStr +
                  " | Level: " + activeLevel +
                  " | Setup: " + setupTriggers +
                  " | Score: " + str.tostring(finalScore) +
                  " | SL: " + slStr + " | TP: " + tpStr

    alert(webhookInput ? jMsg : tMsg, alert.freq_once_per_bar_close)

if anySweep
    string dirStr = sweepBullish ? "bull" : "bear"
    string lvlStr = sweepITH ? "ITH" : sweepITL ? "ITL" : sweepEQHigh ? "EQ_high" : "EQ_low"
    // if/else (not multi-line ternary) for Pine v6 compatibility
    string lvlPx = ""
    if sweepITH
        lvlPx := str.tostring(lastITH, format.mintick)
    else if sweepITL
        lvlPx := str.tostring(lastITL, format.mintick)
    else
        lvlPx := str.tostring(eqVal, format.mintick)
    string jMsg = '{"action":"sweep","ticker":"' + tickerStr +
                  '","tf":"' + tfStr +
                  '","direction":"' + dirStr +
                  '","level":"' + lvlStr +
                  '","level_price":' + lvlPx +
                  ',"price":' + str.tostring(close) + '}'
    string tMsg = "🟠 SWEEP " + lvlStr + " | " + tickerStr + " | " + tfStr + " | " + priceStr
    alert(webhookInput ? jMsg : tMsg, alert.freq_once_per_bar_close)

// ══════════════════════════════════════
// MOMENTUM SIGNALS (v1 — preserved, toggleable)
// ══════════════════════════════════════
ema_f        = ta.ema(close, 9)
v_ma         = ta.sma(volume, 20)
long_signal  = ta.crossover(close, ema_f)  and volume > v_ma * 2.0
short_signal = ta.crossunder(close, ema_f) and volume > v_ma * 2.0

plotshape(showMomentumInput and long_signal,  location = location.belowbar, color = color.green, style = shape.triangleup,   size = size.tiny)
plotshape(showMomentumInput and short_signal, location = location.abovebar, color = color.red,   style = shape.triangledown, size = size.tiny)

// ══════════════════════════════════════
// CLEANUP
// ══════════════════════════════════════
if array.size(label.all) > 490
    label.delete(array.shift(label.all))
if array.size(line.all) > 490
    line.delete(array.shift(line.all))
````
