# Trendline Confluence Map [AGPro Series]

- url: https://www.tradingview.com/script/Z3Qnr1S8-Trendline-Confluence-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;07b993f16a6f45d28a2d371390205daa
- version: 2.0

## Description

Trendline Confluence Map [AGPro Series]

Overview

Trendline Confluence Map automatically draws ascending and descending trendlines from major and minor swing pivots, then maps the zones where two or more of these trendlines intersect with each other or with key horizontal support and resistance levels. Every confluence zone is scored from 0 to 100 based on touch count, line age, trendline angle and volume, so traders can instantly see which reaction levels are backed by the most structural weight. Drawn as long rectangular zones in the classic S/R style, the map stays anchored to current price and hides old, irrelevant levels automatically.

[image]https://www.tradingview.com/x/VtAZP1qI/[/image]

Unique Edge

Most trendline tools either draw a single line or flood the chart with dozens of low-quality lines that never interact with each other. This indicator is built around the opposite idea: confluence is the signal, single lines are just noise. Its three design choices make the difference. First, the script maintains a disciplined pool of only the trendlines whose current projection is on-chart, so a zero-visibility clutter problem cannot happen — the panel count always equals what you actually see. Second, horizontal S/R levels participate as first-class confluence sources alongside trendlines, with a guard requiring at least one real trendline per zone so the tool remains true to its name. Third, every zone label shows a source breakdown such as "2 TL" or "1 TL + 1 SR", giving you immediate insight into why a zone was considered high-probability.

[image]https://www.tradingview.com/x/joapvZSF/[/image]

Methodology

Swing pivots are detected at two depths (major and minor) using pivot-high and pivot-low structures, with configurable lookback lengths. Each valid consecutive pivot pair spawns a trendline, and every subsequent bar that wicks into the projected line within an ATR-based tolerance increments its touch count, raising its structural validity. Horizontal S/R levels are extracted from recent major pivots and merged when they fall within 0.4 ATR of each other. On each confirmed bar, the detector builds a combined pool of all on-chart trendline projections plus horizontal levels, then runs a greedy clustering pass using a zone-width-sized tolerance window. Candidate clusters that contain at least one trendline and meet the minimum source count are scored by combining touch strength, line age, slope quality, a rolling volume component and a horizontal S/R bonus. The highest-scoring cluster becomes a confluence zone, drawn as a rectangle whose right edge extends dynamically to the current bar so every active zone stays visually anchored to price. Zones are deduplicated by price and direction, and expire automatically after a configurable age.

Signals and Alerts

Every new confluence zone is announced with a descriptive alert that carries its mid-price, score and source breakdown. A second alert fires when price first crosses into an active zone from outside, helping traders react to the moment a level is tested. Zone colors encode directional bias: green zones indicate support-favored confluence while pink zones indicate resistance-favored confluence, with the bias derived from the dominant trendline direction in the cluster. Labels on the right edge of each zone show the current score, the source breakdown and the bias tag, so at a glance the trader knows which level is strongest and why.

Key Inputs

Major Pivot Length and Minor Pivot Length define the swing-detection depth of the two pivot streams. Max Active Trendlines caps the internal pool, while Min Touches to Validate filters out unconfirmed trendlines from the confluence pass. Touch Tolerance in ATR units controls how generously the script counts interactions. Min Sources for Zone sets the confluence requirement, Zone Width in ATR units determines rectangle thickness, and Zone Forward Extension controls how far each zone reaches to the right. Max Active Zones and Max Zone Age in bars keep the map focused on currently relevant structure. Panel Theme, Panel Location and Font Size cover the full visual customization layer.

How to Use

Start on the timeframe you trade and leave the defaults — they are tuned for 4H crypto and major FX on equivalent timeframes. Scan for zones with a score above 60 in a direction aligned with the higher-timeframe bias. Use the green support-biased zones as pullback entry areas in uptrends and the pink resistance-biased zones as fade or short entry areas in downtrends. Break-and-retest traders can wait for price to pierce a high-score zone and return to its edge; mean-reversion traders can watch for rejection at zones where the source breakdown includes both a trendline and a horizontal level, as those tend to hold more strongly. The panel at the top shows a quick summary of the current map state and the distance to the nearest zone in ATR units, which is useful for position sizing and stop placement.

Limitations and Transparency

This is not a strategy and not a complete trading system. It does not predict price and does not generate buy or sell instructions. Confluence zones are structural context, not entries, and their score is an internal quality estimate derived from visible price action, not a probability of success. The script needs a reasonable amount of historical bars to build a stable trendline pool. Very low timeframes and very illiquid symbols can produce erratic pivot structures and are not the intended use case. Like all pivot-based tools, the indicator reflects past structure, and levels can weaken or become stale as market regimes change. Zones older than the configured age are removed automatically to reduce this risk.

Risk Disclosure

Trading involves substantial risk of loss and is not suitable for every investor. Past performance is not indicative of future results. This indicator is provided for educational and analytical purposes only and should not be interpreted as financial advice, an investment recommendation or a solicitation to trade. Always combine multiple forms of analysis, manage position size responsibly, and never risk capital you cannot afford to lose.

## Source Code

````pine
// -------------------------------------------------
// Trendline Confluence Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Dynamic trendline confluence zone detector. Draws ascending and descending
// trendlines from major and minor swing pivots, then maps intersections where
// two or more trendlines (or trendline + horizontal S/R) converge into a single
// high-probability reaction zone. Each zone is scored by touch count, line age,
// trendline angle and volume confluence to surface the strongest setups.
// Zones extend dynamically to the right edge of the chart and expire after a
// configurable age so the map stays anchored to currently relevant levels.
// A reaction follow-rate layer reports how often zone entries on this chart
// actually produced a rejection away from the zone before it broke.
// Ideal for breakout traders, mean-reversion plays and key reversal confluence.
// -------------------------------------------------
//@version=6
indicator("Trendline Confluence Map [AGPro Series]",
     shorttitle       = "AG Pro TL Confluence",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 100,
     max_boxes_count  = 100)

// =================================================
// INPUTS
// =================================================

// -- Detection -------------------------------------
grpDet         = "Detection"
majorPivotLen  = input.int(15, "Major Pivot Length",        minval = 3, maxval = 50, group = grpDet, tooltip = "Lookback length used to detect major swing pivots. Larger values yield fewer but more significant pivots.")
minorPivotLen  = input.int(5,  "Minor Pivot Length",        minval = 2, maxval = 30, group = grpDet, tooltip = "Lookback length used to detect minor swing pivots. Smaller values add short-term structure.")
maxTrendlines  = input.int(10, "Max Active Trendlines",     minval = 4, maxval = 30, group = grpDet, tooltip = "Maximum number of active trendlines drawn on the chart. Weaker or younger lines are evicted when the limit is exceeded.")
minTouches     = input.int(2,  "Min Touches to Validate",   minval = 2, maxval = 5,  group = grpDet, tooltip = "Minimum number of pivot touches required for a trendline to be considered valid.")
touchTolATR    = input.float(0.35, "Touch Tolerance (ATR)", minval = 0.1, maxval = 1.5, step = 0.05, group = grpDet, tooltip = "Proximity tolerance in ATR units for counting a new touch against an existing trendline.")
useHorizSR     = input.bool(true, "Include Horizontal S/R in Confluence", group = grpDet, tooltip = "When enabled, horizontal support and resistance levels built from recent major pivots count toward confluence strength.")

// -- Confluence Zones ------------------------------
grpZone        = "Confluence Zones"
minConfluence  = input.int(2,   "Min Sources for Zone",      minval = 2, maxval = 4, group = grpZone, tooltip = "Minimum number of distinct trendlines that must converge to form a confluence zone.")
zoneWidthATR   = input.float(0.6,"Zone Width (ATR)",         minval = 0.2, maxval = 2.0, step = 0.1, group = grpZone, tooltip = "Vertical thickness of confluence zone rectangles, expressed in ATR units.")
zoneExtendBars = input.int(30,  "Zone Forward Extension (bars)", minval = 5, maxval = 200, group = grpZone, tooltip = "Number of bars the confluence zone rectangle extends to the right of its detection point.")
maxActiveZones = input.int(6,   "Max Active Zones",          minval = 2, maxval = 12, group = grpZone, tooltip = "Maximum number of active confluence zones retained on the chart.")
maxZoneAgeBars = input.int(120, "Max Zone Age (bars)",       minval = 30, maxval = 500, group = grpZone, tooltip = "Zones older than this age are automatically removed so the chart stays focused on currently relevant levels.")
minZoneScore   = input.float(35.0,"Min Zone Score to Show",  minval = 0.0, maxval = 100.0, step = 5.0, group = grpZone, tooltip = "Zones scoring below this threshold are hidden. Score combines touch count, line age, angle and volume confluence.")

// -- Visuals ---------------------------------------
grpVis         = "Visuals"
showTrendlines = input.bool(true, "Show Trendlines",           group = grpVis)
showZones      = input.bool(true, "Show Confluence Zones",     group = grpVis)
showLabels     = input.bool(true, "Show Zone Labels",          group = grpVis, tooltip = "Displays a compact label beside each active zone showing score and source count.")
showHorizSR    = input.bool(true,"Show Horizontal S/R Lines", group = grpVis, tooltip = "When enabled, plots the internal horizontal S/R levels used in the confluence calculation.")

fontSizeOpt    = input.string("Normal", "Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVis, tooltip = "Font size applied to panel and zone labels.")
theme          = input.string("Dark",   "Panel Theme", options = ["Dark", "Light"], group = grpVis)

// -- Panel -----------------------------------------
grpPanel       = "Panel"
showPanel      = input.bool(true, "Show Panel", group = grpPanel)
panelLoc       = input.string("Top Right", "Panel Location",
                 options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
                 group = grpPanel)

// -- Alerts ----------------------------------------
grpAlert       = "Alerts"
alertOnNewZone = input.bool(true, "Alert on New Confluence Zone", group = grpAlert)
alertOnTouch   = input.bool(true, "Alert on Price Entering Zone", group = grpAlert)

// =================================================
// COLOR PALETTE - AGPro
// =================================================
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgLight  = color.rgb(248, 250, 252)
panelBorderC  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueD   = color.rgb(226, 232, 240)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

isDark        = theme == "Dark"
panelBg       = isDark ? panelBgDark : panelBgLight
panelLabelCol = isDark ? panelLabelD : panelLabelL
panelValueCol = isDark ? panelValueD : panelValueL

// =================================================
// HELPERS
// =================================================
f_fontSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

fSize = f_fontSize(fontSizeOpt)

f_panelPos(string loc) =>
    switch loc
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

atr14 = ta.atr(14)

// =================================================
// PIVOT DETECTION
// =================================================
phMajor = ta.pivothigh(high, majorPivotLen, majorPivotLen)
plMajor = ta.pivotlow (low,  majorPivotLen, majorPivotLen)
phMinor = ta.pivothigh(high, minorPivotLen, minorPivotLen)
plMinor = ta.pivotlow (low,  minorPivotLen, minorPivotLen)

var int   lastMajHiBar = na
var float lastMajHiPx  = na
var int   prevMajHiBar = na
var float prevMajHiPx  = na
var int   lastMajLoBar = na
var float lastMajLoPx  = na
var int   prevMajLoBar = na
var float prevMajLoPx  = na

var int   lastMinHiBar = na
var float lastMinHiPx  = na
var int   prevMinHiBar = na
var float prevMinHiPx  = na
var int   lastMinLoBar = na
var float lastMinLoPx  = na
var int   prevMinLoBar = na
var float prevMinLoPx  = na

if not na(phMajor)
    prevMajHiBar := lastMajHiBar
    prevMajHiPx  := lastMajHiPx
    lastMajHiBar := bar_index - majorPivotLen
    lastMajHiPx  := phMajor
if not na(plMajor)
    prevMajLoBar := lastMajLoBar
    prevMajLoPx  := lastMajLoPx
    lastMajLoBar := bar_index - majorPivotLen
    lastMajLoPx  := plMajor
if not na(phMinor)
    prevMinHiBar := lastMinHiBar
    prevMinHiPx  := lastMinHiPx
    lastMinHiBar := bar_index - minorPivotLen
    lastMinHiPx  := phMinor
if not na(plMinor)
    prevMinLoBar := lastMinLoBar
    prevMinLoPx  := lastMinLoPx
    lastMinLoBar := bar_index - minorPivotLen
    lastMinLoPx  := plMinor

// =================================================
// TRENDLINE STORE
// =================================================
var array<int>   tlX1      = array.new<int>()
var array<float> tlY1      = array.new<float>()
var array<int>   tlX2      = array.new<int>()
var array<float> tlY2      = array.new<float>()
var array<float> tlSlope   = array.new<float>()
var array<int>   tlTouches = array.new<int>()
var array<int>   tlBornBar = array.new<int>()
var array<bool>  tlIsDown  = array.new<bool>()
var array<line>  tlLineId  = array.new<line>()

f_slope(int x1, float y1, int x2, float y2) =>
    dx = x2 - x1
    dx == 0 ? 0.0 : (y2 - y1) / dx

f_projectPrice(int idx, int x1, float y1, float slope) =>
    y1 + slope * (idx - x1)

f_evictWeakest() =>
    n = array.size(tlX1)
    if n > 0
        worstIdx   = 0
        worstScore = 1e12
        for i = 0 to n - 1
            t   = array.get(tlTouches, i)
            age = bar_index - array.get(tlBornBar, i)
            s   = t * 1000.0 + age
            if s < worstScore
                worstScore := s
                worstIdx   := i
        line.delete(array.get(tlLineId, worstIdx))
        array.remove(tlX1,      worstIdx)
        array.remove(tlY1,      worstIdx)
        array.remove(tlX2,      worstIdx)
        array.remove(tlY2,      worstIdx)
        array.remove(tlSlope,   worstIdx)
        array.remove(tlTouches, worstIdx)
        array.remove(tlBornBar, worstIdx)
        array.remove(tlIsDown,  worstIdx)
        array.remove(tlLineId,  worstIdx)

f_tlExists(int x1, float y1, int x2, float y2) =>
    n = array.size(tlX1)
    exists = false
    tolPx = atr14 * 0.25
    tolBr = 3
    if n > 0
        for i = 0 to n - 1
            if math.abs(array.get(tlX1, i) - x1) <= tolBr and math.abs(array.get(tlX2, i) - x2) <= tolBr and math.abs(array.get(tlY1, i) - y1) <= tolPx and math.abs(array.get(tlY2, i) - y2) <= tolPx
                exists := true
                break
    exists

f_addTL(int x1, float y1, int x2, float y2, bool isDown) =>
    // Reject lines whose current-bar projection is far off-chart (would never be visible)
    slopeCheck = f_slope(x1, y1, x2, y2)
    projNow    = f_projectPrice(bar_index, x1, y1, slopeCheck)
    if not na(projNow) and math.abs(projNow - close) <= atr14 * 6.0 and not f_tlExists(x1, y1, x2, y2)
        if array.size(tlX1) >= maxTrendlines
            f_evictWeakest()
        col   = isDown ? bearColor : bullColor
        ln    = line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = extend.right, color = col, width = 2, style = line.style_solid)
        array.push(tlX1,      x1)
        array.push(tlY1,      y1)
        array.push(tlX2,      x2)
        array.push(tlY2,      y2)
        array.push(tlSlope,   slopeCheck)
        array.push(tlTouches, 2)
        array.push(tlBornBar, bar_index)
        array.push(tlIsDown,  isDown)
        array.push(tlLineId,  ln)

if not na(phMajor) and not na(prevMajHiBar)
    f_addTL(prevMajHiBar, prevMajHiPx, lastMajHiBar, lastMajHiPx, true)
if not na(plMajor) and not na(prevMajLoBar)
    f_addTL(prevMajLoBar, prevMajLoPx, lastMajLoBar, lastMajLoPx, false)
if not na(phMinor) and not na(prevMinHiBar)
    f_addTL(prevMinHiBar, prevMinHiPx, lastMinHiBar, lastMinHiPx, true)
if not na(plMinor) and not na(prevMinLoBar)
    f_addTL(prevMinLoBar, prevMinLoPx, lastMinLoBar, lastMinLoPx, false)

// Touch accumulation
if barstate.isconfirmed and array.size(tlX1) > 0
    tol = atr14 * touchTolATR
    for i = 0 to array.size(tlX1) - 1
        yProj = f_projectPrice(bar_index, array.get(tlX1, i), array.get(tlY1, i), array.get(tlSlope, i))
        if high >= yProj - tol and low <= yProj + tol
            if bar_index - array.get(tlBornBar, i) > majorPivotLen
                array.set(tlTouches, i, array.get(tlTouches, i) + 1)

// Off-chart eviction: remove lines whose projection has drifted > 8 ATR from price.
// Iterate from top to avoid index shift.
if array.size(tlX1) > 0
    ei = array.size(tlX1) - 1
    while ei >= 0
        ypE = f_projectPrice(bar_index, array.get(tlX1, ei), array.get(tlY1, ei), array.get(tlSlope, ei))
        if na(ypE) or math.abs(ypE - close) > atr14 * 8.0
            line.delete(array.get(tlLineId, ei))
            array.remove(tlX1,      ei)
            array.remove(tlY1,      ei)
            array.remove(tlX2,      ei)
            array.remove(tlY2,      ei)
            array.remove(tlSlope,   ei)
            array.remove(tlTouches, ei)
            array.remove(tlBornBar, ei)
            array.remove(tlIsDown,  ei)
            array.remove(tlLineId,  ei)
        ei -= 1

// Visual refresh: hide lines below min touches OR those projecting far off-chart
if array.size(tlX1) > 0
    for i = 0 to array.size(tlX1) - 1
        ln     = array.get(tlLineId, i)
        tch    = array.get(tlTouches, i)
        isDown = array.get(tlIsDown, i)
        yProj  = f_projectPrice(bar_index, array.get(tlX1, i), array.get(tlY1, i), array.get(tlSlope, i))
        onChart = not na(yProj) and math.abs(yProj - close) <= atr14 * 6.0
        showIt = showTrendlines and tch >= minTouches and onChart
        col    = isDown ? bearColor : bullColor
        line.set_color(ln, showIt ? col : color.new(col, 100))
        line.set_width(ln, tch >= 4 ? 3 : tch >= 3 ? 2 : 2)
        line.set_extend(ln, showIt ? extend.right : extend.none)

// =================================================
// HORIZONTAL S/R LEVELS
// =================================================
var array<float> srLevels = array.new<float>()
var array<int>   srAges   = array.new<int>()
maxSR = 6

f_addSR(float px) =>
    if not na(px)
        n = array.size(srLevels)
        merged = false
        if n > 0
            for i = 0 to n - 1
                if math.abs(array.get(srLevels, i) - px) <= atr14 * 0.4
                    array.set(srLevels, i, (array.get(srLevels, i) + px) / 2.0)
                    array.set(srAges,   i, bar_index)
                    merged := true
                    break
        if not merged
            if array.size(srLevels) >= maxSR
                oldestIdx = 0
                oldestAge = array.get(srAges, 0)
                for i = 1 to array.size(srLevels) - 1
                    if array.get(srAges, i) < oldestAge
                        oldestAge := array.get(srAges, i)
                        oldestIdx := i
                array.remove(srLevels, oldestIdx)
                array.remove(srAges,   oldestIdx)
            array.push(srLevels, px)
            array.push(srAges,   bar_index)

if not na(phMajor)
    f_addSR(phMajor)
if not na(plMajor)
    f_addSR(plMajor)

// Optional S/R render
var array<line> srLines = array.new<line>()
if barstate.islast and showHorizSR and useHorizSR
    if array.size(srLines) > 0
        for i = 0 to array.size(srLines) - 1
            line.delete(array.get(srLines, i))
        array.clear(srLines)
    if array.size(srLevels) > 0
        for i = 0 to array.size(srLevels) - 1
            px = array.get(srLevels, i)
            ln = line.new(bar_index - 200, px, bar_index, px, xloc = xloc.bar_index, extend = extend.right, color = color.new(neutralColor, 50), style = line.style_dotted, width = 1)
            array.push(srLines, ln)

// =================================================
// CONFLUENCE ZONE STORE
// =================================================
var array<int>   zBornBar  = array.new<int>()
var array<float> zPriceMid = array.new<float>()
var array<float> zScore    = array.new<float>()
var array<int>   zSources  = array.new<int>()
var array<box>   zBoxId    = array.new<box>()
var array<label> zLabelId  = array.new<label>()
var array<bool>  zIsRes    = array.new<bool>()

f_removeZoneAt(int i) =>
    box.delete(array.get(zBoxId, i))
    lbl = array.get(zLabelId, i)
    if not na(lbl)
        label.delete(lbl)
    array.remove(zBornBar,  i)
    array.remove(zPriceMid, i)
    array.remove(zScore,    i)
    array.remove(zSources,  i)
    array.remove(zBoxId,    i)
    array.remove(zLabelId,  i)
    array.remove(zIsRes,    i)

// =================================================
// SCORE COMPONENTS
// =================================================
f_touchScore(int t) =>
    t >= 4 ? 40.0 : t == 3 ? 25.0 : t == 2 ? 10.0 : 0.0

f_ageScore(int born) =>
    age = bar_index - born
    math.min(20.0, age / 8.0)

f_angleScore(float slope, float atrV) =>
    s = atrV == 0.0 ? 0.0 : math.abs(slope) / atrV
    s < 0.05 ? 5.0 : s < 0.1 ? 10.0 : s <= 0.6 ? 15.0 : s <= 1.0 ? 10.0 : 5.0

volSMA = ta.sma(volume, 20)
f_volScore() =>
    result = 7.5
    if not na(volSMA) and volSMA > 0.0
        ratio = volume / volSMA
        result := ratio >= 1.8 ? 15.0 : ratio >= 1.4 ? 12.0 : ratio >= 1.1 ? 9.0 : ratio >= 0.8 ? 6.0 : 3.0
    result

f_srBonus(float pxMid) =>
    bonus = 0.0
    if useHorizSR and array.size(srLevels) > 0
        tol = atr14 * 0.5
        for i = 0 to array.size(srLevels) - 1
            if math.abs(array.get(srLevels, i) - pxMid) <= tol
                bonus := 10.0
                break
    bonus

// =================================================
// ZONE DETECTION - returns [score, mid, sources, isRes]
// Always returns a complete tuple of the same shape.
// =================================================
f_detectZones() =>
    bestScore   = -1.0
    bestMid     = 0.0
    bestSrcs    = 0
    bestTLCount = 0
    bestIsRes   = false

    // Build projection pool: trendline projections + horizontal S/R levels
    // S/R entries are tagged with slope=0 and synthetic touches=3 (acts as anchor).
    projPx       = array.new<float>()
    projIsDown   = array.new<bool>()
    projSlope    = array.new<float>()
    projBorn     = array.new<int>()
    projTouch    = array.new<int>()
    projIsTL     = array.new<bool>()   // true = trendline, false = horizontal SR

    nTL = array.size(tlX1)
    if nTL > 0
        for i = 0 to nTL - 1
            if array.get(tlTouches, i) >= minTouches
                yP = f_projectPrice(bar_index, array.get(tlX1, i), array.get(tlY1, i), array.get(tlSlope, i))
                if not na(yP) and math.abs(yP - close) <= atr14 * 15.0
                    array.push(projPx,     yP)
                    array.push(projIsDown, array.get(tlIsDown, i))
                    array.push(projSlope,  array.get(tlSlope, i))
                    array.push(projBorn,   array.get(tlBornBar, i))
                    array.push(projTouch,  array.get(tlTouches, i))
                    array.push(projIsTL,   true)

    if useHorizSR and array.size(srLevels) > 0
        for i = 0 to array.size(srLevels) - 1
            srPx = array.get(srLevels, i)
            if math.abs(srPx - close) <= atr14 * 15.0
                array.push(projPx,     srPx)
                array.push(projIsDown, srPx > close)
                array.push(projSlope,  0.0)
                array.push(projBorn,   array.get(srAges, i))
                array.push(projTouch,  3)
                array.push(projIsTL,   false)

    sz = array.size(projPx)
    if sz >= minConfluence
        // Wider cluster window: use the zone width itself as tolerance
        clusterTol = atr14 * zoneWidthATR

        processed = array.new<bool>()
        for k = 0 to sz - 1
            array.push(processed, false)

        for i = 0 to sz - 1
            if not array.get(processed, i)
                clusterPx    = array.new<float>()
                clusterSlope = array.new<float>()
                clusterBorn  = array.new<int>()
                clusterTouch = array.new<int>()
                clusterIsTL  = array.new<bool>()
                downCount = 0
                array.push(clusterPx,    array.get(projPx, i))
                array.push(clusterSlope, array.get(projSlope, i))
                array.push(clusterBorn,  array.get(projBorn,  i))
                array.push(clusterTouch, array.get(projTouch, i))
                array.push(clusterIsTL,  array.get(projIsTL, i))
                if array.get(projIsDown, i)
                    downCount += 1
                array.set(processed, i, true)

                if i < sz - 1
                    for j = i + 1 to sz - 1
                        if j < sz and not array.get(processed, j) and math.abs(array.get(projPx, j) - array.get(projPx, i)) <= clusterTol
                            array.push(clusterPx,    array.get(projPx, j))
                            array.push(clusterSlope, array.get(projSlope, j))
                            array.push(clusterBorn,  array.get(projBorn,  j))
                            array.push(clusterTouch, array.get(projTouch, j))
                            array.push(clusterIsTL,  array.get(projIsTL, j))
                            if array.get(projIsDown, j)
                                downCount += 1
                            array.set(processed, j, true)

                cSize = array.size(clusterPx)
                // Require cluster to contain at least one actual trendline (script promise)
                tlInCluster = 0
                if cSize > 0
                    for m = 0 to cSize - 1
                        if array.get(clusterIsTL, m)
                            tlInCluster += 1

                if cSize >= minConfluence and tlInCluster >= 1
                    mid = array.avg(clusterPx)
                    acc = 0.0
                    for m = 0 to cSize - 1
                        acc += f_touchScore(array.get(clusterTouch, m)) + f_ageScore(array.get(clusterBorn, m)) + f_angleScore(array.get(clusterSlope, m), atr14)
                    avgPart = acc / cSize
                    sc = math.min(100.0, avgPart + f_volScore() + f_srBonus(mid))
                    if sc > bestScore
                        bestScore   := sc
                        bestMid     := mid
                        bestSrcs    := cSize
                        bestTLCount := tlInCluster
                        upCount     = cSize - downCount
                        bestIsRes   := downCount > upCount ? true : downCount < upCount ? false : close < mid

    [bestScore, bestMid, bestSrcs, bestTLCount, bestIsRes]

f_zoneExistsNear(float mid, bool isRes) =>
    n = array.size(zPriceMid)
    ex = false
    if n > 0
        tol = atr14 * 1.2
        for i = 0 to n - 1
            if array.get(zIsRes, i) == isRes and math.abs(array.get(zPriceMid, i) - mid) <= tol
                ex := true
                break
    ex

f_drawZone(float mid, float sc, int srcs, int tlCount, bool isRes) =>
    half  = atr14 * zoneWidthATR / 2.0
    top   = mid + half
    bot   = mid - half
    col   = isRes ? bearColor : bullColor
    fillC = color.new(col, 82)
    bordC = color.new(col, 40)
    bx    = box.new(bar_index, top, bar_index + zoneExtendBars, bot, xloc = xloc.bar_index, bgcolor = fillC, border_color = bordC, border_width = 1)
    label lbl = na
    if showLabels
        srCount   = srcs - tlCount
        breakdown = tlCount > 0 and srCount > 0 ? str.tostring(tlCount) + " TL + " + str.tostring(srCount) + " SR" : tlCount > 0 ? str.tostring(tlCount) + " TL" : str.tostring(srCount) + " SR"
        tag       = (isRes ? "Res " : "Sup ") + str.tostring(math.round(sc)) + "  |  " + breakdown
        lbl := label.new(bar_index + zoneExtendBars, mid, tag, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 25), textcolor = color.white, size = fSize)
    array.push(zBornBar,  bar_index)
    array.push(zPriceMid, mid)
    array.push(zScore,    sc)
    array.push(zSources,  srcs)
    array.push(zBoxId,    bx)
    array.push(zLabelId,  lbl)
    array.push(zIsRes,    isRes)
    if array.size(zBornBar) > maxActiveZones
        f_removeZoneAt(0)

// Fire detection (rate-limited)
var int lastDetectBar = 0
detectCooldown = math.max(5, majorPivotLen / 2)
if barstate.isconfirmed and showZones and (bar_index - lastDetectBar) >= detectCooldown
    [sc, mid, srcs, tlCount, isRes] = f_detectZones()
    if sc >= minZoneScore and not f_zoneExistsNear(mid, isRes)
        f_drawZone(mid, sc, srcs, tlCount, isRes)
        lastDetectBar := bar_index
        if alertOnNewZone
            alert("New Confluence Zone formed at " + str.tostring(mid, format.mintick) + " | Score " + str.tostring(math.round(sc)) + " | " + str.tostring(tlCount) + " TL + " + str.tostring(srcs - tlCount) + " SR", alert.freq_once_per_bar)

// =================================================
// ZONE LIFECYCLE - extend right edge to current bar + age eviction
// Runs every bar so zones stay anchored near current price.
// =================================================
if array.size(zBornBar) > 0
    // Age-based eviction (iterate from top to avoid index shift)
    i = array.size(zBornBar) - 1
    while i >= 0
        if bar_index - array.get(zBornBar, i) > maxZoneAgeBars
            f_removeZoneAt(i)
        i -= 1
    // Refresh right edge + label anchor for remaining zones
    if array.size(zBornBar) > 0
        rightX = bar_index + zoneExtendBars
        for k = 0 to array.size(zBornBar) - 1
            bx = array.get(zBoxId, k)
            box.set_right(bx, rightX)
            lbl = array.get(zLabelId, k)
            if not na(lbl)
                label.set_x(lbl, rightX)
                label.set_y(lbl, array.get(zPriceMid, k))

// Touch-entry alerts
if barstate.isconfirmed and alertOnTouch and array.size(zBornBar) > 0
    for i = 0 to array.size(zBornBar) - 1
        mid  = array.get(zPriceMid, i)
        half = atr14 * zoneWidthATR / 2.0
        enteredNow  = high    >= mid - half and low    <= mid + half
        wasOutside  = high[1] <  mid - half or  low[1] >  mid + half
        if enteredNow and wasOutside
            alert("Price entered Confluence Zone @ " + str.tostring(mid, format.mintick), alert.freq_once_per_bar)

// Reaction follow-rate layer: each confirmed zone entry is tracked once.
// It counts as followed when price rejects away from the zone by one ATR
// beyond the entry-side edge, and as failed when price closes through the
// far edge first (zone broken) or the tracking window times out. Levels
// and ATR are frozen at registration so later zone updates cannot disturb
// an open measurement. Resolution runs before registration, so same-bar
// conflicts resolve conservatively.
var bool zTrkOn = false
var int zTrkDir = 0
var float zTrkEdgeNear = na
var float zTrkEdgeFar = na
var float zTrkAtr = na
var int zTrkStart = na
var int zoneFollowW = 0
var int zoneFollowN = 0
if zTrkOn
    zFollowed = zTrkDir == -1 ? low <= zTrkEdgeNear - zTrkAtr : high >= zTrkEdgeNear + zTrkAtr
    zFailed = zTrkDir == -1 ? close > zTrkEdgeFar : close < zTrkEdgeFar
    zTimeout = not na(zTrkStart) and bar_index - zTrkStart >= zoneExtendBars * 2
    if zFailed or zTimeout
        zoneFollowN += 1
        zTrkOn := false
    else if zFollowed
        zoneFollowN += 1
        zoneFollowW += 1
        zTrkOn := false
if barstate.isconfirmed and not zTrkOn and array.size(zBornBar) > 0
    for i = 0 to array.size(zBornBar) - 1
        zMidT = array.get(zPriceMid, i)
        zHalfT = atr14 * zoneWidthATR / 2.0
        zEnterT = high >= zMidT - zHalfT and low <= zMidT + zHalfT
        zWasOutT = high[1] < zMidT - zHalfT or low[1] > zMidT + zHalfT
        if zEnterT and zWasOutT
            zTrkOn := true
            zTrkDir := array.get(zIsRes, i) ? -1 : 1
            zTrkEdgeNear := array.get(zIsRes, i) ? zMidT - zHalfT : zMidT + zHalfT
            zTrkEdgeFar := array.get(zIsRes, i) ? zMidT + zHalfT : zMidT - zHalfT
            zTrkAtr := atr14
            zTrkStart := bar_index
            break
zoneFollowRate = zoneFollowN > 0 ? 100.0 * zoneFollowW / zoneFollowN : na
zoneFollowReady = zoneFollowN >= 8

// =================================================
// PANEL
// =================================================
var table panel = na

if barstate.islast and showPanel
    nActiveTL = 0
    if array.size(tlTouches) > 0
        for i = 0 to array.size(tlTouches) - 1
            if array.get(tlTouches, i) >= minTouches
                nActiveTL += 1

    nZones = array.size(zBornBar)
    topScore = 0.0
    topSrcs  = 0
    topBias  = "-"
    if nZones > 0
        for i = 0 to nZones - 1
            if array.get(zScore, i) > topScore
                topScore := array.get(zScore, i)
                topSrcs  := array.get(zSources, i)
                topBias  := array.get(zIsRes, i) ? "Resistance" : "Support"

    nearestDist  = 1e12
    nearestPx    = 0.0
    nearestIsRes = false
    hasNearest   = false
    if nZones > 0
        for i = 0 to nZones - 1
            d = math.abs(array.get(zPriceMid, i) - close)
            if d < nearestDist
                nearestDist  := d
                nearestPx    := array.get(zPriceMid, i)
                nearestIsRes := array.get(zIsRes, i)
                hasNearest   := true

    nearestStr = not hasNearest ? "-" : (nearestIsRes ? "Res " : "Sup ") + str.tostring(nearestPx, format.mintick) + "  (" + str.tostring(nearestDist / atr14, "#.##") + " ATR)"

    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(panelLoc), 2, 8, bgcolor = panelBg, border_color = panelBorderC, border_width = 1, frame_color = panelBorderC, frame_width = 1)

    // Row 0 - merged blue brand header, panel title only
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Trendline Confluence", text_color = headerText, bgcolor = headerBg, text_size = fSize, text_halign = text.align_center)

    table.cell(panel, 0, 1, "Active Trendlines", text_color = panelLabelCol, text_size = fSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, str.tostring(nActiveTL), text_color = panelValueCol, text_size = fSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "Active Zones", text_color = panelLabelCol, text_size = fSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, str.tostring(nZones), text_color = panelValueCol, text_size = fSize, text_halign = text.align_right)

    topCol = topScore >= 70.0 ? bullColor : topScore >= 50.0 ? neutralColor : panelValueCol
    table.cell(panel, 0, 3, "Top Zone Score", text_color = panelLabelCol, text_size = fSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, nZones > 0 ? str.tostring(math.round(topScore)) + " / 100" : "-", text_color = topCol, text_size = fSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "Top Zone Sources", text_color = panelLabelCol, text_size = fSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, nZones > 0 ? str.tostring(topSrcs) + " conf." : "-", text_color = panelValueCol, text_size = fSize, text_halign = text.align_right)

    biasCol = topBias == "Resistance" ? bearColor : topBias == "Support" ? bullColor : panelValueCol
    table.cell(panel, 0, 5, "Top Zone Bias", text_color = panelLabelCol, text_size = fSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, topBias, text_color = biasCol, text_size = fSize, text_halign = text.align_right)

    nearCol = not hasNearest ? panelValueCol : nearestIsRes ? bearColor : bullColor
    table.cell(panel, 0, 6, "Nearest Zone", text_color = panelLabelCol, text_size = fSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, nearestStr, text_color = nearCol, text_size = fSize, text_halign = text.align_right)

    zoneFollowText = zoneFollowN == 0 ? "-" : str.tostring(int(math.round(zoneFollowRate))) + "%  n=" + str.tostring(zoneFollowN)
    zoneFollowColor = zoneFollowReady ? (zoneFollowRate >= 55.0 ? bullColor : zoneFollowRate >= 40.0 ? neutralColor : bearColor) : panelLabelCol
    table.cell(panel, 0, 7, "Reaction Follow", text_color = panelLabelCol, text_size = fSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, zoneFollowText, text_color = zoneFollowColor, text_size = fSize, text_halign = text.align_right)
````
