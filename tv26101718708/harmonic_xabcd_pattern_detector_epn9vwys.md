# Harmonic XABCD Pattern Detector

- url: https://www.tradingview.com/script/EPN9VWys/
- type: indicator
- pine_id: PUB;12fad079d3d74ddcba7d614df57d7d37
- version: 3.0

## Description

[b]Overview[/b]

This overlay indicator scans the chart for classic [b]XABCD harmonic formations[/b] using pivot-based structure detection. When a valid five-point pattern completes at pivot D, it draws the zigzag legs, labels key ratios, and optionally highlights the Potential Reversal Zone (PRZ) near D.

The script is designed for [b]visual pattern recognition and education[/b]. It does not place orders, generate trade signals for automation, or guarantee future price behavior.

[b]Supported patterns[/b]

[list]
[*]Gartley
[*]Bat
[*]Butterfly
[*]Crab
[*]Deep Crab
[*]Cypher
[*]Shark
[*]AB=CD
[*]Three Drives (7-point structure)
[/list]

[b]Key features[/b]

[list=1]
[*][b]Strict and Soft modes[/b] — Strict uses fixed Fibonacci ratio rules. Soft applies a user-defined percentage tolerance around standard harmonic levels.
[*][b]PRZ box[/b] — Optional orange zone at D showing the projected reversal area.
[*][b]Structural stop line[/b] — Optional stop reference beyond D based on CD leg size and ATR buffer (visual reference only).
[*][b]Pattern score and confluence[/b] — Each completed pattern receives a quality score and a confluence count based on nearby pivot density.
[*][b]See the Future[/b] — When X-A-B-C is complete but D is not yet confirmed, the script can project possible D zones for active setups.
[*][b]On-chart table[/b] — Summary panel with pivot count, detection mode, pending projection status, average pattern score, and recent pattern history.
[*][b]Alerts[/b] — Optional alerts for pattern completion, future zone touch, and possible formation in the projected D zone.
[/list]

[b]How detection works[/b]

The script identifies swing pivots using configurable left/right bar settings, then evaluates consecutive pivot sequences against harmonic ratio rules. A pattern is drawn only after the pivot structure and ratio checks pass the selected mode (Strict or Soft).

[i]Important:[/i] Pivot D is confirmed only after the configured [b]Pivot Right Bars[/b] have closed. Until then, price action near the projected zone is handled by the [b]See the Future[/b] module, not as a completed pattern.

[b]Main settings[/b]

[list]
[*][b]Pivot Settings[/b] — Pivot left/right bars and maximum stored pivots.
[*][b]Filter Settings[/b] — Minimum leg size (ATR multiplier) and ATR period.
[*][b]Detection Mode[/b] — Strict vs Soft ratio control; Soft tolerance (%).
[*][b]Pattern Filters[/b] — Enable or disable individual harmonic types.
[*][b]Visual Settings[/b] — Labels, leg ratios, butterfly wings, PRZ, stop line, colors, and history table rows.
[*][b]See the Future[/b] — Projected D zones, zone merge, touch markers, and extension length.
[*][b]Storage[/b] — Maximum stored patterns for redraw and history.
[*][b]Alerts[/b] — Toggle alert conditions for completion and future-zone events.
[*][b]Analytics[/b] — Confluence ATR multiplier for pivot clustering near PRZ.
[/list]

[b]Alerts[/b]

Three optional alert conditions are available:

[list=1]
[*]Pattern Completed — a valid XABCD (or Three Drives) formation is detected and drawn.
[*]Future Zone Touched — price enters a projected D zone while XABC is still active.
[*]Possible Formation — price reaches an extremum inside a projected D zone before D is confirmed.
[/list]

[b]Limitations[/b]

[list]
[*]Harmonic patterns are [b]subjective geometric models[/b]. Different pivot settings, timeframes, and tolerance modes will produce different results.
[*]Overlapping patterns are filtered, but dense or choppy markets may still produce frequent redraws on setting changes.
[*]The optional stop line is a [b]structural visual reference[/b], not a validated risk-management rule.
[*]See the Future projections are [b]hypothetical[/b] until pivot D is confirmed by the pivot engine.
[*]This indicator runs on [pine]overlay=true[/pine] and is intended for manual chart analysis on TradingView.
[/list]

[quote]
[b]Disclaimer[/b]

This script is provided for informational and educational purposes only. It does not constitute investment advice, financial advice, trading advice, or a recommendation to buy or sell any instrument.

Trading involves substantial risk of loss. Past pattern occurrences do not guarantee future results. Always do your own research and consult a qualified financial professional before making trading decisions.

The author makes no warranties about the accuracy, completeness, or suitability of the detected patterns for any particular market or timeframe.
[/quote]

## Source Code

````pine
// Harmonic XABCD pattern detection indicator for TradingView.
// © 2026 - Pine Script v6
//@version=6
indicator("Harmonic Patterns [XABCD]", shorttitle="Harmonic", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 200, max_polylines_count = 100, max_bars_back = 5000)

// ══════════════════════════════════════════════════════════════════════════════
// INPUT PARAMETERS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_PIVOT   = "Pivot Settings"
int    pivotLeft   = input.int(5, "Pivot Left Bars", minval = 1, maxval = 50, group = GRP_PIVOT)
int    pivotRight  = input.int(5, "Pivot Right Bars", minval = 1, maxval = 50, group = GRP_PIVOT)
int    maxPivots   = input.int(150, "Max Pivot Count", minval = 30, maxval = 300, group = GRP_PIVOT)

string GRP_RATIO   = "Filter Settings"
float  minLegAtr   = input.float(0.3, "Min Leg Size (ATR mult.)", minval = 0.1, maxval = 5.0, step = 0.1, group = GRP_RATIO)
int    atrLen      = input.int(14, "ATR Period", minval = 1, group = GRP_RATIO)

string GRP_MODE    = "Detection Mode"
string detectMode  = input.string("Strict", "Ratio Control Mode", options = ["Strict", "Soft"], group = GRP_MODE, tooltip = "Strict: fixed epsilon. Soft: percentage-tolerance Fibonacci ranges.")
float  softTolPct  = input.float(8.0, "Soft Mode Tolerance (%)", minval = 1.0, maxval = 25.0, step = 0.5, group = GRP_MODE, active = detectMode == "Soft", tooltip = "Applies only in Soft mode.")

// Strict mode: minimal epsilon for float precision only (no flexible tolerance)
float STRICT_EPS = 0.003
bool  isSoftMode = detectMode == "Soft"

string GRP_PATTERN = "Pattern Filters"
bool   showGartley    = input.bool(true, "Gartley", group = GRP_PATTERN)
bool   showBat        = input.bool(true, "Bat", group = GRP_PATTERN)
bool   showButterfly  = input.bool(true, "Butterfly", group = GRP_PATTERN)
bool   showCrab       = input.bool(true, "Crab", group = GRP_PATTERN)
bool   showDeepCrab   = input.bool(false, "Deep Crab", group = GRP_PATTERN)
bool   showCypher     = input.bool(false, "Cypher", group = GRP_PATTERN)
bool   showShark      = input.bool(true, "Shark", group = GRP_PATTERN)
bool   showABCD       = input.bool(false, "AB=CD", group = GRP_PATTERN)
bool   showThreeDrive = input.bool(false, "Three Drives", group = GRP_PATTERN)

string GRP_VISUAL  = "Visual Settings"
bool   showLabels    = input.bool(true, "Show Labels", group = GRP_VISUAL)
bool   showRatios    = input.bool(true, "Show Ratios on Label", group = GRP_VISUAL)
bool   showLegRatios = input.bool(true, "Show Ratios on Legs", group = GRP_VISUAL, tooltip = "Compact ratio values at leg end pivots (B, C, D).")
bool   showButterflyWings = input.bool(true, "Butterfly Wings (X-B, B-D)", group = GRP_VISUAL, tooltip = "Dashed X-B and B-D diagonals with filled wing triangles.")
int    wingFillTransp = input.int(88, "Wing Fill Transparency", minval = 70, maxval = 95, group = GRP_VISUAL, active = showButterflyWings)
bool   showPRZ       = input.bool(true, "Show PRZ Zone", group = GRP_VISUAL, tooltip = "Orange box at D: Potential Reversal Zone (entry area). No text on box.")
bool   showStop      = input.bool(true, "Show Stop Level", group = GRP_VISUAL, tooltip = "Structural stop beyond D (CD leg buffer).")
float  stopAtrMult   = input.float(0.15, "Stop Buffer (ATR)", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_VISUAL, active = showStop)
color  stopColor     = input.color(color.new(#FF5252, 0), "Stop Color", group = GRP_VISUAL, active = showStop)
int    lineWidth     = input.int(2, "Line Width", minval = 1, maxval = 4, group = GRP_VISUAL)
color  bullColor     = input.color(color.new(#26A69A, 0), "Bullish Color", group = GRP_VISUAL)
color  bearColor     = input.color(color.new(#EF5350, 0), "Bearish Color", group = GRP_VISUAL)
color  przColor      = input.color(color.new(#FF9800, 65), "PRZ Color", group = GRP_VISUAL)
int    tableHistRows  = input.int(20, "Max History Rows", minval = 1, maxval = 50, group = GRP_VISUAL, tooltip = "Table shows detected patterns up to this count. Table height adjusts automatically.")
bool   tableShowTime  = input.bool(true, "Show Time in Table", group = GRP_VISUAL)

string GRP_FUTURE  = "See the Future"
bool   showFuture    = input.bool(true, "See the Future", group = GRP_FUTURE, tooltip = "When XABC is complete, draws a projected D zone (PRZ). The box shows the price range where the pattern may complete once pivot D forms.")
int    futureBars    = input.int(30, "Projection Extension (bars)", minval = 10, maxval = 100, group = GRP_FUTURE, active = showFuture)
color  futureBullCol = input.color(color.new(#26A69A, 40), "Bullish Projection", group = GRP_FUTURE, active = showFuture)
color  futureBearCol = input.color(color.new(#EF5350, 40), "Bearish Projection", group = GRP_FUTURE, active = showFuture)
color  futureLabelTextCol = input.color(color.white, "Future Label Text Color", group = GRP_FUTURE, active = showFuture)
bool   showFutureZone    = input.bool(true, "Show Future Zone Box", group = GRP_FUTURE, active = showFuture)
bool   showFutureMarkers = input.bool(true, "Show Zone Touch Markers", group = GRP_FUTURE, active = showFuture)
bool   mergeFutureZones  = input.bool(true, "Merge Overlapping Zones", group = GRP_FUTURE, active = showFuture)

string GRP_STORAGE = "Storage"
int    maxStoredPatterns = input.int(100, "Max Stored Patterns", minval = 20, maxval = 200, group = GRP_STORAGE, tooltip = "Limits history, signatures and redraw count.")

string GRP_ALERTS = "Alerts"
bool   alertPatternComplete  = input.bool(true, "Alert: Pattern Completed", group = GRP_ALERTS)
bool   alertZoneTouch        = input.bool(true, "Alert: Future Zone Touched", group = GRP_ALERTS)
bool   alertPossibleFormation = input.bool(true, "Alert: Possible Formation", group = GRP_ALERTS)

string GRP_ANALYTICS = "Analytics"
float  confluenceAtrMult = input.float(0.5, "Confluence ATR Mult", minval = 0.1, maxval = 2.0, step = 0.1, group = GRP_ANALYTICS)
color  formationLabelTextCol = input.color(color.white, "Formation Label Text Color", group = GRP_VISUAL)

// Table layout: title(1) + summary(8) + analytics header(1) + analytics(1) + history header(1) + history rows
int TABLE_SUMMARY_ROWS = 8
int TABLE_ANALYTICS_ROWS = 1

// ══════════════════════════════════════════════════════════════════════════════
// USER-DEFINED TYPES (UDT)
// ══════════════════════════════════════════════════════════════════════════════

// Represents a single pivot point
type PivotPoint
    int   barIdx
    float price
    bool  isHigh

// Represents a detected harmonic formation (5 pivots: X,A,B,C,D)
type HarmonicMatch
    string name
    bool   isBullish
    int    xBar
    int    aBar
    int    bBar
    int    cBar
    int    dBar
    float  xPrice
    float  aPrice
    float  bPrice
    float  cPrice
    float  dPrice
    float  rAB
    float  rBC
    float  rCD
    float  rAD
    float  rXC
    float  rDCxc
    float  przTop
    float  przBot
    int    scanIdx

// Record for table history
type FormationRecord
    int    dBar
    int    dTime
    string name
    bool   isBullish
    string signature
    float  score
    int    confluence

// XABC complete, D pending — possible formation projection
type FutureProjection
    string name
    bool   isBullish
    int    xBar
    int    cBar
    float  cPrice
    float  dPrice
    float  rAB
    float  rBC
    float  zTop
    float  zBot

// Merged See the Future zone
type MergedFutureZone
    bool   isBullish
    int    cBar
    float  cPrice
    float  zTop
    float  zBot
    string names

// Global state arrays (must be defined before functions)
var array<PivotPoint> pivotArray = array.new<PivotPoint>()
var array<string> drawnSignatures = array.new<string>()
var array<FormationRecord> formationHistory = array.new<FormationRecord>()
var array<line> patternLines = array.new<line>()
var array<label> patternLabels = array.new<label>()
var array<box> patternBoxes = array.new<box>()
var array<polyline> patternPolylines = array.new<polyline>()
var array<line> futureLines = array.new<line>()
var array<label> futureLabels = array.new<label>()
var array<box> futureBoxes = array.new<box>()
var string lastConfigHash = ""
var string pendingSummary = "None"

// ══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

// Calculates absolute difference
diff(float a, float b) =>
    math.abs(a - b)

// Leg length left-to-right (chronological order required)
legLen(PivotPoint pStart, PivotPoint pEnd) =>
    pEnd.barIdx > pStart.barIdx ? math.abs(pEnd.price - pStart.price) : na

// Checks whether XABCD points are in chronological order
isChronological(PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, PivotPoint pD) =>
    pX.barIdx < pA.barIdx and pA.barIdx < pB.barIdx and pB.barIdx < pC.barIdx and pC.barIdx < pD.barIdx

// XABC (4 points) chronological order
isChronologicalABC(PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC) =>
    pX.barIdx < pA.barIdx and pA.barIdx < pB.barIdx and pB.barIdx < pC.barIdx

// Returns Fibonacci ratio between two prices (numerator / denominator)
calcRatio(float leg, float base) =>
    base != 0.0 ? leg / base : na

// Calculates all harmonic ratios left-to-right
calcHarmonicRatios(PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, PivotPoint pD) =>
    float xa = legLen(pX, pA)
    float ab = legLen(pA, pB)
    float bc = legLen(pB, pC)
    float cd = legLen(pC, pD)
    float ad = legLen(pA, pD)
    float xc = legLen(pX, pC)
    [calcRatio(ab, xa), calcRatio(bc, ab), calcRatio(cd, bc), calcRatio(ad, xa), calcRatio(xc, xa), xa, ab, bc, cd]

// Strict Fibonacci: exact target (minimal epsilon for float precision)
isExactFib(float value, float target) =>
    not na(value) and math.abs(value - target) <= STRICT_EPS

// Strict Fibonacci: closed range (no tolerance)
inStrictRange(float value, float minR, float maxR) =>
    not na(value) and value >= minR and value <= maxR

// BC/AB strict range (valid for all classic formations)
bcValid(float rBC) =>
    inStrictRange(rBC, 0.382, 0.886)

// Appends pivot to array; removes oldest if capacity exceeded
method pushPivot(array<PivotPoint> this, PivotPoint p, int limit) =>
    this.push(p)
    if this.size() > limit
        this.shift()

// Builds formation signature (prevents duplicate drawing)
makeSignature(string name, int xBar, int aBar, int bBar, int cBar, int dBar) =>
    name + "|" + str.tostring(xBar) + "|" + str.tostring(aBar) + "|" + str.tostring(bBar) + "|" + str.tostring(cBar) + "|" + str.tostring(dBar)

// Keeps only the latest (rightmost) D point for the same XABC
makeXABCKeys(string name, int xBar, int aBar, int bBar, int cBar) =>
    name + "|" + str.tostring(xBar) + "|" + str.tostring(aBar) + "|" + str.tostring(bBar) + "|" + str.tostring(cBar)

filterOverlappingMatches(array<HarmonicMatch> matches) =>
    array<HarmonicMatch> filtered = array.new<HarmonicMatch>()
    array<string> keys = array.new<string>()
    int n = matches.size()
    if n > 0
        for i = 0 to n - 1
            HarmonicMatch m = matches.get(i)
            string key = makeXABCKeys(m.name, m.xBar, m.aBar, m.bBar, m.cBar)
            int existIdx = -1
            int kCount = keys.size()
            if kCount > 0
                for k = 0 to kCount - 1
                    if keys.get(k) == key
                        existIdx := k
                        break
            if existIdx == -1
                keys.push(key)
                filtered.push(m)
            else
                HarmonicMatch prev = filtered.get(existIdx)
                if m.dBar > prev.dBar
                    filtered.set(existIdx, m)
    filtered

// Converts bar time to readable date format
formatBarDate(int barTime, bool showTime) =>
    showTime ? str.format("{0,date,dd.MM.yyyy HH:mm}", barTime) : str.format("{0,date,dd.MM.yyyy}", barTime)

// Safely returns bar time for point D
getBarTime(int targetBar) =>
    int barsBack = bar_index - targetBar
    barsBack >= 0 and barsBack <= 5000 ? time[barsBack] : time

// ══════════════════════════════════════════════════════════════════════════════
// PIVOT DETECTION
// ══════════════════════════════════════════════════════════════════════════════

float ph = ta.pivothigh(high, pivotLeft, pivotRight)
float pl = ta.pivotlow(low, pivotLeft, pivotRight)

if not na(ph)
    pivotArray.pushPivot(PivotPoint.new(bar_index - pivotRight, ph, true), maxPivots)

if not na(pl)
    pivotArray.pushPivot(PivotPoint.new(bar_index - pivotRight, pl, false), maxPivots)

float atrVal = ta.atr(atrLen)

// ══════════════════════════════════════════════════════════════════════════════
// STRUCTURE VALIDATION — ABSOLUTE STRICT RULES (NON-NEGOTIABLE)
// ══════════════════════════════════════════════════════════════════════════════

// Leg direction: true = up, false = down
legIsUp(float pStart, float pEnd) =>
    pEnd > pStart

// Four consecutive legs must alternate direction (derived from prices)
// Bullish: XA↑ AB↓ BC↑ CD↓  |  Bearish: XA↓ AB↑ BC↓ CD↑
legsAlternate(float xP, float aP, float bP, float cP, float dP) =>
    legIsUp(xP, aP) != legIsUp(aP, bP) and legIsUp(aP, bP) != legIsUp(bP, cP) and legIsUp(bP, cP) != legIsUp(cP, dP)

// Price direction rules per leg (if XA up then AB down and B<A, etc.)
legPriceRules(float xP, float aP, float bP, float cP, float dP) =>
    bool xaUp = legIsUp(xP, aP)
    bool abUp = legIsUp(aP, bP)
    bool bcUp = legIsUp(bP, cP)
    bool cdUp = legIsUp(cP, dP)
    (xaUp ? aP > xP and bP < aP : aP < xP and bP > aP) and (bcUp ? cP > bP : cP < bP) and (cdUp ? dP > cP : dP < cP)

// No pivot between two consecutive pivots (no pivot skipping)
noPivotBetween(array<PivotPoint> pivots, PivotPoint pStart, PivotPoint pEnd) =>
    bool ok = true
    int n = pivots.size()
    if n > 0
        for j = 0 to n - 1
            PivotPoint p = pivots.get(j)
            if p.barIdx > pStart.barIdx and p.barIdx < pEnd.barIdx
                ok := false
    ok

// Verifies no swing high/low is skipped inside a leg using bar data
validateSwingLegBars(PivotPoint pStart, PivotPoint pEnd) =>
    bool legUp = legIsUp(pStart.price, pEnd.price)
    int span = pEnd.barIdx - pStart.barIdx
    bool ok = span > 0
    if ok and span > 1
        for step = 1 to span - 1
            int targetBar = pStart.barIdx + step
            int barsBack = bar_index - targetBar
            if barsBack >= 0 and barsBack <= 5000
                if legUp
                    if low[barsBack] < pStart.price
                        ok := false
                else
                    if high[barsBack] > pStart.price
                        ok := false
    ok

// Direction alternation on all legs + no pivot skip + bar integrity
validateAllLegs(array<PivotPoint> pivots, PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, PivotPoint pD) =>
    bool ok = legsAlternate(pX.price, pA.price, pB.price, pC.price, pD.price)
    ok := ok and legPriceRules(pX.price, pA.price, pB.price, pC.price, pD.price)
    ok := ok and noPivotBetween(pivots, pX, pA) and noPivotBetween(pivots, pA, pB)
    ok := ok and noPivotBetween(pivots, pB, pC) and noPivotBetween(pivots, pC, pD)
    ok := ok and validateSwingLegBars(pX, pA) and validateSwingLegBars(pA, pB)
    ok := ok and validateSwingLegBars(pB, pC) and validateSwingLegBars(pC, pD)
    ok

// Point C must never violate point A
cRespectsA(bool isBullish, float aP, float cP) =>
    isBullish ? cP >= aP : cP <= aP

// Internal formation: D stays between X and A (bullish: X=low, A=high)
isInternalD(bool isBullish, float xP, float aP, float dP) =>
    isBullish ? dP >= xP and dP <= aP : dP <= xP and dP >= aP

// External formation: D extends beyond X (XA extension)
isExternalD(bool isBullish, float xP, float aP, float dP) =>
    isBullish ? dP < xP : dP > xP

// Basic zigzag + minimum leg size (4 legs: XA, AB, BC, CD)
validateZigzag(bool isBullish, float xP, float aP, float bP, float cP, float dP, float minLeg) =>
    bool valid = legsAlternate(xP, aP, bP, cP, dP) and legPriceRules(xP, aP, bP, cP, dP)
    if valid
        valid := diff(xP, aP) >= minLeg and diff(aP, bP) >= minLeg
        valid := valid and diff(bP, cP) >= minLeg and diff(cP, dP) >= minLeg
        if isBullish
            valid := valid and aP > xP and bP < aP and bP >= xP and cP > bP and cP >= aP and dP < cP
        else
            valid := valid and aP < xP and bP > aP and bP <= xP and cP < bP and cP <= aP and dP > cP
    valid

// Combines all absolute structure rules
validateStructure(array<PivotPoint> pivots, bool isBullish, PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, PivotPoint pD, float minLeg) =>
    bool ok = validateZigzag(isBullish, pX.price, pA.price, pB.price, pC.price, pD.price, minLeg)
    ok := ok and cRespectsA(isBullish, pA.price, pC.price)
    ok := ok and validateAllLegs(pivots, pX, pA, pB, pC, pD)
    ok

// Five consecutive pivot template from pivot array (no pivot skipped)
// Bullish: L-H-L-H-L  |  Bearish: H-L-H-L-H
validatePivotTemplate(array<PivotPoint> pivots, int startIdx, bool isBullish) =>
    bool ok = false
    if startIdx + 4 < pivots.size()
        PivotPoint pX = pivots.get(startIdx)
        PivotPoint pA = pivots.get(startIdx + 1)
        PivotPoint pB = pivots.get(startIdx + 2)
        PivotPoint pC = pivots.get(startIdx + 3)
        PivotPoint pD = pivots.get(startIdx + 4)
        if isBullish
            ok := not pX.isHigh and pA.isHigh and not pB.isHigh and pC.isHigh and not pD.isHigh
        else
            ok := pX.isHigh and not pA.isHigh and pB.isHigh and not pC.isHigh and pD.isHigh
        ok := ok and isChronological(pX, pA, pB, pC, pD)
    ok

// ══════════════════════════════════════════════════════════════════════════════
// FORMATION RATIO CHECKS — STRICT RULES
// ══════════════════════════════════════════════════════════════════════════════

// Gartley: B=0.618 (exact), D=0.786 XA, internal
checkGartley(float rAB, float rBC, float rAD) =>
    isExactFib(rAB, 0.618) and bcValid(rBC) and isExactFib(rAD, 0.786)

// Bat: B=0.382-0.500, D=0.886 XA, internal
checkBat(float rAB, float rBC, float rAD) =>
    inStrictRange(rAB, 0.382, 0.500) and bcValid(rBC) and isExactFib(rAD, 0.886)

// Butterfly: B=0.786 (exact), D=1.272 XA, external
checkButterfly(float rAB, float rBC, float rAD) =>
    isExactFib(rAB, 0.786) and bcValid(rBC) and isExactFib(rAD, 1.272)

// Crab: B=0.382-0.618, D=1.618 XA, external
checkCrab(float rAB, float rBC, float rAD) =>
    inStrictRange(rAB, 0.382, 0.618) and bcValid(rBC) and isExactFib(rAD, 1.618)

// Shark: AB/XA=0.382-0.618, D=1.13-1.618 XC
checkShark(float rAB, float rBC, float rDCxc) =>
    inStrictRange(rAB, 0.382, 0.618) and bcValid(rBC) and inStrictRange(rDCxc, 1.130, 1.618)

// Deep Crab: B=0.886, D=1.618 XA, external
checkDeepCrab(float rAB, float rBC, float rAD) =>
    isExactFib(rAB, 0.886) and bcValid(rBC) and isExactFib(rAD, 1.618)

// Cypher: B=0.382-0.618, XC=1.13-1.414 XA, D=0.786 XC
checkCypher(float rAB, float rXC, float rADxc) =>
    inStrictRange(rAB, 0.382, 0.618) and inStrictRange(rXC, 1.130, 1.414) and isExactFib(rADxc, 0.786)

// AB=CD: BC=0.618-0.786, CD=AB
checkABCD(float rBC, float rCDtoAB) =>
    inStrictRange(rBC, 0.618, 0.786) and isExactFib(rCDtoAB, 1.000)

// ══════════════════════════════════════════════════════════════════════════════
// FORMATION RATIO CHECKS — SOFT MODE (strict mode untouched)
// ══════════════════════════════════════════════════════════════════════════════

// Soft Fibonacci: widens range by tolerance percentage
inFibRangeSoft(float value, float minR, float maxR, float tolPct) =>
    if na(value)
        false
    else
        float tolMin = minR * (1.0 - tolPct / 100.0)
        float tolMax = maxR * (1.0 + tolPct / 100.0)
        value >= tolMin and value <= tolMax

// Soft Fibonacci: tolerance-based proximity to single target
atFibSoft(float value, float target, float tolPct) =>
    inFibRangeSoft(value, target, target, tolPct)

// BC/AB soft range
bcValidSoft(float rBC, float tolPct) =>
    inFibRangeSoft(rBC, 0.382, 0.886, tolPct)

checkGartleySoft(float rAB, float rBC, float rAD, float tolPct) =>
    atFibSoft(rAB, 0.618, tolPct) and bcValidSoft(rBC, tolPct) and atFibSoft(rAD, 0.786, tolPct)

checkBatSoft(float rAB, float rBC, float rAD, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.500, tolPct) and bcValidSoft(rBC, tolPct) and atFibSoft(rAD, 0.886, tolPct)

checkButterflySoft(float rAB, float rBC, float rAD, float tolPct) =>
    atFibSoft(rAB, 0.786, tolPct) and bcValidSoft(rBC, tolPct) and atFibSoft(rAD, 1.272, tolPct)

checkCrabSoft(float rAB, float rBC, float rAD, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.618, tolPct) and bcValidSoft(rBC, tolPct) and atFibSoft(rAD, 1.618, tolPct)

checkSharkSoft(float rAB, float rBC, float rDCxc, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.618, tolPct) and bcValidSoft(rBC, tolPct) and inFibRangeSoft(rDCxc, 1.130, 1.618, tolPct)

checkDeepCrabSoft(float rAB, float rBC, float rAD, float tolPct) =>
    atFibSoft(rAB, 0.886, tolPct) and bcValidSoft(rBC, tolPct) and atFibSoft(rAD, 1.618, tolPct)

checkCypherSoft(float rAB, float rXC, float rADxc, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.618, tolPct) and inFibRangeSoft(rXC, 1.130, 1.414, tolPct) and atFibSoft(rADxc, 0.786, tolPct)

checkABCDSoft(float rBC, float rCDtoAB, float tolPct) =>
    inFibRangeSoft(rBC, 0.618, 0.786, tolPct) and atFibSoft(rCDtoAB, 1.000, tolPct)

// Soft mode classification (same priority as classifyPattern, tolerant ratios)
classifyPatternSoft(float rAB, float rBC, float rAD, float rXC, float rDCxc, float rCDtoAB, float rADxc, bool isBullish, float xP, float aP, float dP, float tolPct) =>
    string name = ""
    bool internalD = isInternalD(isBullish, xP, aP, dP)
    bool externalD = isExternalD(isBullish, xP, aP, dP)
    if internalD
        if showGartley and atFibSoft(rAB, 0.618, tolPct) and checkGartleySoft(rAB, rBC, rAD, tolPct)
            name := "Gartley"
        else if showBat and inFibRangeSoft(rAB, 0.382, 0.500, tolPct) and checkBatSoft(rAB, rBC, rAD, tolPct)
            name := "Bat"
    if name == "" and externalD
        if showButterfly and atFibSoft(rAB, 0.786, tolPct) and checkButterflySoft(rAB, rBC, rAD, tolPct)
            name := "Butterfly"
        else if showCrab and inFibRangeSoft(rAB, 0.382, 0.618, tolPct) and checkCrabSoft(rAB, rBC, rAD, tolPct)
            name := "Crab"
        else if showDeepCrab and atFibSoft(rAB, 0.886, tolPct) and checkDeepCrabSoft(rAB, rBC, rAD, tolPct)
            name := "Deep Crab"
    if name == "" and showShark and checkSharkSoft(rAB, rBC, rDCxc, tolPct)
        name := "Shark"
    if name == "" and showCypher and checkCypherSoft(rAB, rXC, rADxc, tolPct)
        name := "Cypher"
    if name == "" and showABCD and checkABCDSoft(rBC, rCDtoAB, tolPct)
        name := "AB=CD"
    name

checkThreeDrivesSoft(array<PivotPoint> pivots, int startIdx, bool isBullish, float tolPct) =>
    bool found = false
    if startIdx + 6 < pivots.size()
        PivotPoint p0 = pivots.get(startIdx)
        PivotPoint p1 = pivots.get(startIdx + 1)
        PivotPoint p2 = pivots.get(startIdx + 2)
        PivotPoint p3 = pivots.get(startIdx + 3)
        PivotPoint p4 = pivots.get(startIdx + 4)
        PivotPoint p5 = pivots.get(startIdx + 5)
        PivotPoint p6 = pivots.get(startIdx + 6)
        bool structOk = false
        if isBullish
            structOk := not p0.isHigh and p1.isHigh and not p2.isHigh and p3.isHigh and not p4.isHigh and p5.isHigh and not p6.isHigh
            structOk := structOk and p2.price < p0.price and p4.price < p2.price and p6.price < p4.price
        else
            structOk := p0.isHigh and not p1.isHigh and p2.isHigh and not p3.isHigh and p4.isHigh and not p5.isHigh and p6.isHigh
            structOk := structOk and p2.price > p0.price and p4.price > p2.price and p6.price > p4.price
        if structOk
            float drive1 = legLen(p0, p1)
            float retr1  = legLen(p1, p2)
            float drive2 = legLen(p2, p3)
            float retr2  = legLen(p3, p4)
            float drive3 = legLen(p4, p5)
            float final  = legLen(p5, p6)
            float rRet1  = calcRatio(retr1, drive1)
            float rRet2  = calcRatio(retr2, drive2)
            float rDrv2  = calcRatio(drive2, drive1)
            float rDrv3  = calcRatio(drive3, drive2)
            float rFin   = calcRatio(final, drive3)
            found := inFibRangeSoft(rRet1, 0.618, 0.786, tolPct) and inFibRangeSoft(rRet2, 0.618, 0.786, tolPct)
            found := found and inFibRangeSoft(rDrv2, 1.272, 1.618, tolPct) and inFibRangeSoft(rDrv3, 1.272, 1.618, tolPct)
            found := found and inFibRangeSoft(rFin, 0.618, 0.786, tolPct)
    found

checkThreeDrives(array<PivotPoint> pivots, int startIdx, bool isBullish) =>
    bool found = false
    if startIdx + 6 < pivots.size()
        PivotPoint p0 = pivots.get(startIdx)
        PivotPoint p1 = pivots.get(startIdx + 1)
        PivotPoint p2 = pivots.get(startIdx + 2)
        PivotPoint p3 = pivots.get(startIdx + 3)
        PivotPoint p4 = pivots.get(startIdx + 4)
        PivotPoint p5 = pivots.get(startIdx + 5)
        PivotPoint p6 = pivots.get(startIdx + 6)
        bool structOk = false
        if isBullish
            structOk := not p0.isHigh and p1.isHigh and not p2.isHigh and p3.isHigh and not p4.isHigh and p5.isHigh and not p6.isHigh
            structOk := structOk and p2.price < p0.price and p4.price < p2.price and p6.price < p4.price
        else
            structOk := p0.isHigh and not p1.isHigh and p2.isHigh and not p3.isHigh and p4.isHigh and not p5.isHigh and p6.isHigh
            structOk := structOk and p2.price > p0.price and p4.price > p2.price and p6.price > p4.price
        if structOk
            float drive1 = legLen(p0, p1)
            float retr1  = legLen(p1, p2)
            float drive2 = legLen(p2, p3)
            float retr2  = legLen(p3, p4)
            float drive3 = legLen(p4, p5)
            float final  = legLen(p5, p6)
            float rRet1  = calcRatio(retr1, drive1)
            float rRet2  = calcRatio(retr2, drive2)
            float rDrv2  = calcRatio(drive2, drive1)
            float rDrv3  = calcRatio(drive3, drive2)
            float rFin   = calcRatio(final, drive3)
            found := inStrictRange(rRet1, 0.618, 0.786) and inStrictRange(rRet2, 0.618, 0.786)
            found := found and inStrictRange(rDrv2, 1.272, 1.618) and inStrictRange(rDrv3, 1.272, 1.618)
            found := found and inStrictRange(rFin, 0.618, 0.786)
    found

// ATR at D confirmation bar (stop consistency)
getAtrAtBar(int targetBar) =>
    int barsBack = bar_index - targetBar
    float atrResult = atrVal
    if barsBack >= 0 and barsBack <= 5000
        atrResult := atrVal[barsBack]
    na(atrResult) ? atrVal : atrResult

// Structural stop beyond D: 5% of CD leg or ATR buffer (whichever is larger)
calcStopPrice(bool isBullish, float dP, float cP, float atr, float atrMult) =>
    float cdLen = diff(cP, dP)
    float buf = math.max(cdLen * 0.05, atr * atrMult)
    isBullish ? dP - buf : dP + buf

// Projects D price from AD/XA ratio
projectD_ADXA(bool isBullish, float xP, float aP, float adRatio) =>
    float xaLen = diff(xP, aP)
    isBullish ? aP - adRatio * xaLen : aP + adRatio * xaLen

// Projects D price from CD/XC ratio (Shark)
projectD_Shark(bool isBullish, float xP, float cP, float dcxcRatio) =>
    float xcLen = diff(xP, cP)
    isBullish ? cP - dcxcRatio * xcLen : cP + dcxcRatio * xcLen

// Cypher: AD/XC = 0.786
projectD_Cypher(bool isBullish, float xP, float aP, float cP) =>
    float xcLen = diff(xP, cP)
    isBullish ? aP - 0.786 * xcLen : aP + 0.786 * xcLen

// AB=CD: CD equals AB length
projectD_ABCD(bool isBullish, float aP, float bP, float cP) =>
    float abLen = diff(aP, bP)
    isBullish ? cP - abLen : cP + abLen

// PRZ / D zone — unified calculation (completed + See the Future)
calcDZone(string patternName, bool isBullish, float xP, float aP, float bP, float cP, float dTarget, bool useSoftBand) =>
    float xaLen = diff(xP, aP)
    float xcLen = diff(xP, cP)
    float abLen = not na(bP) ? diff(aP, bP) : xaLen
    float center = dTarget
    if patternName == "Gartley"
        center := projectD_ADXA(isBullish, xP, aP, 0.786)
    else if patternName == "Bat"
        center := projectD_ADXA(isBullish, xP, aP, 0.886)
    else if patternName == "Butterfly"
        center := projectD_ADXA(isBullish, xP, aP, 1.272)
    else if patternName == "Crab" or patternName == "Deep Crab"
        center := projectD_ADXA(isBullish, xP, aP, 1.618)
    else if patternName == "Shark"
        center := projectD_Shark(isBullish, xP, cP, 1.374)
    else if patternName == "Cypher"
        center := projectD_Cypher(isBullish, xP, aP, cP)
    else if patternName == "AB=CD"
        center := na(dTarget) ? projectD_ABCD(isBullish, aP, bP, cP) : dTarget
    else if na(center)
        center := projectD_ADXA(isBullish, xP, aP, 0.786)
    float zTop = center
    float zBot = center
    if patternName == "Shark"
        float pHi = projectD_Shark(isBullish, xP, cP, 1.130)
        float pLo = projectD_Shark(isBullish, xP, cP, 1.618)
        zTop := math.max(pHi, pLo)
        zBot := math.min(pHi, pLo)
        float pad = useSoftBand and isSoftMode ? xcLen * softTolPct / 100.0 : xcLen * 0.02
        zTop := zTop + pad
        zBot := zBot - pad
    else
        float baseLen = patternName == "AB=CD" ? abLen : xaLen
        float halfBand = useSoftBand and isSoftMode ? baseLen * softTolPct / 100.0 : baseLen * 0.02
        zTop := center + halfBand
        zBot := center - halfBand
    [zTop, zBot]

calcPRZ(bool isBullish, float xP, float aP, float bP, float cP, string patternName, float dPrice) =>
    calcDZone(patternName, isBullish, xP, aP, bP, cP, dPrice, false)

// ══════════════════════════════════════════════════════════════════════════════
// FORMATION MATCHING ENGINE
// ══════════════════════════════════════════════════════════════════════════════

// Classifies formation by point B (sliding formation logic)
// Priority: B level -> D/XA relation -> internal/external rule
classifyPattern(float rAB, float rBC, float rAD, float rXC, float rDCxc, float rCDtoAB, float rADxc, bool isBullish, float xP, float aP, float dP) =>
    string name = ""
    bool internalD = isInternalD(isBullish, xP, aP, dP)
    bool externalD = isExternalD(isBullish, xP, aP, dP)
    if internalD
        if showGartley and checkGartley(rAB, rBC, rAD)
            name := "Gartley"
        else if showBat and inStrictRange(rAB, 0.382, 0.500) and checkBat(rAB, rBC, rAD)
            name := "Bat"
    if name == "" and externalD
        if showButterfly and checkButterfly(rAB, rBC, rAD)
            name := "Butterfly"
        else if showCrab and inStrictRange(rAB, 0.382, 0.618) and checkCrab(rAB, rBC, rAD)
            name := "Crab"
        else if showDeepCrab and checkDeepCrab(rAB, rBC, rAD)
            name := "Deep Crab"
    if name == "" and showShark and checkShark(rAB, rBC, rDCxc)
        name := "Shark"
    if name == "" and showCypher and checkCypher(rAB, rXC, rADxc)
        name := "Cypher"
    if name == "" and showABCD and checkABCD(rBC, rCDtoAB)
        name := "AB=CD"
    name

detectXABCD(array<PivotPoint> pivots, PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, PivotPoint pD, bool isBullish, float minLeg) =>
    HarmonicMatch result = na
    if isChronological(pX, pA, pB, pC, pD)
        if validateStructure(pivots, isBullish, pX, pA, pB, pC, pD, minLeg)
            [rAB, rBC, rCD, rAD, rXC, xa, ab, bc, cd] = calcHarmonicRatios(pX, pA, pB, pC, pD)
            float rDCxc = calcRatio(legLen(pC, pD), legLen(pX, pC))
            float rADxc = calcRatio(legLen(pA, pD), legLen(pX, pC))
            float rCDtoAB = calcRatio(cd, ab)
            string matchedName = isSoftMode ? classifyPatternSoft(rAB, rBC, rAD, rXC, rDCxc, rCDtoAB, rADxc, isBullish, pX.price, pA.price, pD.price, softTolPct) : classifyPattern(rAB, rBC, rAD, rXC, rDCxc, rCDtoAB, rADxc, isBullish, pX.price, pA.price, pD.price)
            if matchedName != "" and not na(rAB) and not na(rBC) and not na(rAD)
                [przTop, przBot] = calcPRZ(isBullish, pX.price, pA.price, pB.price, pC.price, matchedName, pD.price)
                result := HarmonicMatch.new(matchedName, isBullish, pX.barIdx, pA.barIdx, pB.barIdx, pC.barIdx, pD.barIdx, pX.price, pA.price, pB.price, pC.price, pD.price, rAB, rBC, rCD, rAD, rXC, rDCxc, przTop, przBot, -1)
    result

// Scans all historical XABCD combinations in the pivot array
scanAllPatterns(array<PivotPoint> pivots, float minLeg) =>
    array<HarmonicMatch> matches = array.new<HarmonicMatch>()
    int sz = pivots.size()
    if sz >= 5
        for i = 0 to sz - 5
            if validatePivotTemplate(pivots, i, true)
                PivotPoint pX = pivots.get(i)
                PivotPoint pA = pivots.get(i + 1)
                PivotPoint pB = pivots.get(i + 2)
                PivotPoint pC = pivots.get(i + 3)
                PivotPoint pD = pivots.get(i + 4)
                HarmonicMatch m = detectXABCD(pivots, pX, pA, pB, pC, pD, true, minLeg)
                if not na(m)
                    matches.push(m)
            if validatePivotTemplate(pivots, i, false)
                PivotPoint pX = pivots.get(i)
                PivotPoint pA = pivots.get(i + 1)
                PivotPoint pB = pivots.get(i + 2)
                PivotPoint pC = pivots.get(i + 3)
                PivotPoint pD = pivots.get(i + 4)
                HarmonicMatch m = detectXABCD(pivots, pX, pA, pB, pC, pD, false, minLeg)
                if not na(m)
                    matches.push(m)
    if showThreeDrive and sz >= 7
        for i = 0 to sz - 7
            bool tdBull = isSoftMode ? checkThreeDrivesSoft(pivots, i, true, softTolPct) : checkThreeDrives(pivots, i, true)
            if tdBull
                PivotPoint p0 = pivots.get(i)
                PivotPoint p6 = pivots.get(i + 6)
                matches.push(HarmonicMatch.new("Three Drives", true, p0.barIdx, pivots.get(i + 1).barIdx, pivots.get(i + 2).barIdx, pivots.get(i + 3).barIdx, p6.barIdx, p0.price, pivots.get(i + 1).price, pivots.get(i + 2).price, pivots.get(i + 3).price, p6.price, na, na, na, na, na, na, na, na, i))
            bool tdBear = isSoftMode ? checkThreeDrivesSoft(pivots, i, false, softTolPct) : checkThreeDrives(pivots, i, false)
            if tdBear
                PivotPoint p0 = pivots.get(i)
                PivotPoint p6 = pivots.get(i + 6)
                matches.push(HarmonicMatch.new("Three Drives", false, p0.barIdx, pivots.get(i + 1).barIdx, pivots.get(i + 2).barIdx, pivots.get(i + 3).barIdx, p6.barIdx, p0.price, pivots.get(i + 1).price, pivots.get(i + 2).price, pivots.get(i + 3).price, p6.price, na, na, na, na, na, na, na, na, i))
    filterOverlappingMatches(matches)

// ══════════════════════════════════════════════════════════════════════════════
// SEE THE FUTURE — XABC COMPLETE, D PENDING
// ══════════════════════════════════════════════════════════════════════════════

// Four consecutive pivot XABC template (last pivot = C)
validateXABCTemplate(array<PivotPoint> pivots, int startIdx, bool isBullish) =>
    bool ok = false
    if startIdx + 3 < pivots.size()
        PivotPoint pX = pivots.get(startIdx)
        PivotPoint pA = pivots.get(startIdx + 1)
        PivotPoint pB = pivots.get(startIdx + 2)
        PivotPoint pC = pivots.get(startIdx + 3)
        if isBullish
            ok := not pX.isHigh and pA.isHigh and not pB.isHigh and pC.isHigh
        else
            ok := pX.isHigh and not pA.isHigh and pB.isHigh and not pC.isHigh
        ok := ok and isChronologicalABC(pX, pA, pB, pC)
    ok

// XABC structure validation (D not yet present)
validateXABCStructure(array<PivotPoint> pivots, bool isBullish, PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, float minLeg) =>
    float xP = pX.price
    float aP = pA.price
    float bP = pB.price
    float cP = pC.price
    bool xaUp = legIsUp(xP, aP)
    bool abUp = legIsUp(aP, bP)
    bool bcUp = legIsUp(bP, cP)
    bool ok = xaUp != abUp and abUp != bcUp
    ok := ok and (xaUp ? aP > xP and bP < aP : aP < xP and bP > aP)
    ok := ok and (bcUp ? cP > bP : cP < bP)
    ok := ok and cRespectsA(isBullish, aP, cP)
    ok := ok and noPivotBetween(pivots, pX, pA) and noPivotBetween(pivots, pA, pB) and noPivotBetween(pivots, pB, pC)
    ok := ok and validateSwingLegBars(pX, pA) and validateSwingLegBars(pA, pB) and validateSwingLegBars(pB, pC)
    if ok
        ok := diff(xP, aP) >= minLeg and diff(aP, bP) >= minLeg and diff(bP, cP) >= minLeg
        if isBullish
            ok := ok and aP > xP and bP < aP and bP >= xP and cP > bP and cP >= aP
        else
            ok := ok and aP < xP and bP > aP and bP <= xP and cP < bP and cP <= aP
    ok

// Config hash for redraw on setting change
buildConfigHash() =>
    detectMode + "|" + str.tostring(softTolPct) + "|" + str.tostring(showGartley) + str.tostring(showBat) + str.tostring(showButterfly) + str.tostring(showCrab) + str.tostring(showDeepCrab) + str.tostring(showCypher) + str.tostring(showShark) + str.tostring(showABCD) + str.tostring(showThreeDrive) + "|" + str.tostring(pivotLeft) + "|" + str.tostring(pivotRight) + "|" + str.tostring(minLegAtr)

// Is last pivot C — active XABC awaiting D
getActiveXABC(array<PivotPoint> pivots) =>
    int sz = pivots.size()
    bool active = false
    bool isBull = false
    int idx = -1
    if sz >= 4
        int i = sz - 4
        PivotPoint pC = pivots.get(sz - 1)
        bool bullOk = validateXABCTemplate(pivots, i, true) and pC.isHigh
        bool bearOk = validateXABCTemplate(pivots, i, false) and not pC.isHigh
        bool noBullD = sz < 5 or not validatePivotTemplate(pivots, sz - 5, true)
        bool noBearD = sz < 5 or not validatePivotTemplate(pivots, sz - 5, false)
        if bullOk and noBullD
            active := true
            isBull := true
            idx := i
        else if bearOk and noBearD
            active := true
            isBull := false
            idx := i
    [active, isBull, idx]

// First zone touch after C
findZoneFirstTouch(float zTop, float zBot, int fromBar) =>
    int touchBar = na
    float touchPrice = na
    bool touched = false
    int barsBack = bar_index - fromBar
    if barsBack >= 0
        for b = barsBack to 0
            if high[b] >= zBot and low[b] <= zTop
                touched := true
                touchBar := bar_index - b
                touchPrice := (high[b] + low[b]) / 2.0
                break
    [touchBar, touchPrice, touched]

// Extremum clipped inside zone
findZoneExtremumInZone(bool isBullish, float zTop, float zBot, int fromBar) =>
    int hitBar = na
    float hitPrice = na
    bool touched = false
    int barsBack = bar_index - fromBar
    if barsBack >= 0
        for b = 0 to barsBack
            if high[b] >= zBot and low[b] <= zTop
                touched := true
                float candidate = isBullish ? math.max(math.min(low[b], zTop), zBot) : math.min(math.max(high[b], zBot), zTop)
                if na(hitPrice) or (isBullish ? candidate < hitPrice : candidate > hitPrice)
                    hitPrice := candidate
                    hitBar := bar_index - b
    [hitBar, hitPrice, touched]

// 0-100 score for a single ratio
ratioScore(float value, float target, float tolPct) =>
    float sc = 0.0
    if not na(value)
        float dev = math.abs(value - target)
        float maxDev = isSoftMode ? target * tolPct / 100.0 : STRICT_EPS * 3.0
        sc := math.max(0.0, 100.0 * (1.0 - dev / math.max(maxDev, 0.0001)))
    sc

// Formation quality score
calcPatternScore(string name, float rAB, float rBC, float rAD, float rXC, float rDCxc) =>
    float sc = 50.0
    if name == "Gartley"
        sc := (ratioScore(rAB, 0.618, softTolPct) + ratioScore(rAD, 0.786, softTolPct)) / 2.0
    else if name == "Bat"
        sc := ratioScore(rAD, 0.886, softTolPct)
    else if name == "Butterfly"
        sc := (ratioScore(rAB, 0.786, softTolPct) + ratioScore(rAD, 1.272, softTolPct)) / 2.0
    else if name == "Crab" or name == "Deep Crab"
        sc := ratioScore(rAD, 1.618, softTolPct)
    else if name == "Shark"
        sc := ratioScore(rDCxc, 1.374, softTolPct)
    else if name == "Cypher"
        sc := ratioScore(rXC, 1.272, softTolPct)
    else if name == "AB=CD"
        sc := ratioScore(rBC, 0.682, softTolPct)
    math.round(sc)

// Pivot count near PRZ center (confluence)
countConfluence(array<PivotPoint> pivots, float zoneMid, float atr, float mult) =>
    int cnt = 0
    float band = atr * mult
    int n = pivots.size()
    if n > 0
        for i = 0 to n - 1
            PivotPoint p = pivots.get(i)
            if math.abs(p.price - zoneMid) <= band
                cnt += 1
    cnt

// Average formation score
calcAvgPatternScore(array<FormationRecord> history) =>
    float sumScore = 0.0
    int hN = history.size()
    if hN > 0
        for j = 0 to hN - 1
            sumScore += history.get(j).score
    hN > 0 ? sumScore / hN : 0.0

// Formation priority order (lower = higher priority)
patternPriority(string name) =>
    int p = 99
    if name == "Gartley"
        p := 1
    else if name == "Bat"
        p := 2
    else if name == "Butterfly"
        p := 3
    else if name == "Crab"
        p := 4
    else if name == "Deep Crab"
        p := 5
    else if name == "Shark"
        p := 6
    else if name == "Cypher"
        p := 7
    else if name == "AB=CD"
        p := 8
    p

// Best projection for pending row (touch > score > priority)
pickBestFutureProjection(array<FutureProjection> projs) =>
    FutureProjection best = na
    int n = projs.size()
    if n > 0
        best := projs.get(0)
        if n > 1
            for i = 1 to n - 1
                FutureProjection fp = projs.get(i)
                [tBarB, tPrB, tOkB] = findZoneFirstTouch(best.zTop, best.zBot, best.cBar)
                [tBarF, tPrF, tOkF] = findZoneFirstTouch(fp.zTop, fp.zBot, fp.cBar)
                bool useFp = false
                if tOkF and not tOkB
                    useFp := true
                else if tOkF == tOkB
                    float scB = calcPatternScore(best.name, best.rAB, best.rBC, na, na, na)
                    float scF = calcPatternScore(fp.name, fp.rAB, fp.rBC, na, na, na)
                    if scF > scB
                        useFp := true
                    else if scF == scB and patternPriority(fp.name) < patternPriority(best.name)
                        useFp := true
                if useFp
                    best := fp
    best

// Creates FutureProjection (zone included)
makeFutureProj(string name, bool isBullish, PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, float dP, float rAB, float rBC) =>
    [zTop, zBot] = calcDZone(name, isBullish, pX.price, pA.price, pB.price, pC.price, dP, true)
    FutureProjection.new(name, isBullish, pX.barIdx, pC.barIdx, pC.price, dP, rAB, rBC, zTop, zBot)

// Is projected point D structurally valid
projectedDValid(bool isBullish, float xP, float aP, float bP, float cP, float dP, float minLeg, bool needInternal) =>
    bool cdDown = isBullish
    bool cdOk = cdDown ? dP < cP : dP > cP
    bool ok = cdOk and legsAlternate(xP, aP, bP, cP, dP) and legPriceRules(xP, aP, bP, cP, dP)
    ok := ok and diff(cP, dP) >= minLeg
    ok := ok and (needInternal ? isInternalD(isBullish, xP, aP, dP) : isExternalD(isBullish, xP, aP, dP))
    ok

// Basic D validation for AB=CD without internal/external split
projectedDValidBasic(bool isBullish, float xP, float aP, float bP, float cP, float dP, float minLeg) =>
    bool cdOk = isBullish ? dP < cP : dP > cP
    bool ok = cdOk and legsAlternate(xP, aP, bP, cP, dP) and legPriceRules(xP, aP, bP, cP, dP)
    ok := ok and diff(cP, dP) >= minLeg
    ok

// Do XABC ratios meet formation preconditions (strict)
xabcCompatGartley(float rAB, float rBC) =>
    isExactFib(rAB, 0.618) and bcValid(rBC)

xabcCompatBat(float rAB, float rBC) =>
    inStrictRange(rAB, 0.382, 0.500) and bcValid(rBC)

xabcCompatButterfly(float rAB, float rBC) =>
    isExactFib(rAB, 0.786) and bcValid(rBC)

xabcCompatCrab(float rAB, float rBC) =>
    inStrictRange(rAB, 0.382, 0.618) and bcValid(rBC)

xabcCompatDeepCrab(float rAB, float rBC) =>
    isExactFib(rAB, 0.886) and bcValid(rBC)

xabcCompatShark(float rAB, float rBC) =>
    inStrictRange(rAB, 0.382, 0.618) and bcValid(rBC)

xabcCompatCypher(float rAB, float rXC) =>
    inStrictRange(rAB, 0.382, 0.618) and inStrictRange(rXC, 1.130, 1.414)

xabcCompatABCD(float rAB, float rBC) =>
    inStrictRange(rBC, 0.618, 0.786)

// XABC ratios — soft mode preconditions
xabcCompatGartleySoft(float rAB, float rBC, float tolPct) =>
    atFibSoft(rAB, 0.618, tolPct) and bcValidSoft(rBC, tolPct)

xabcCompatBatSoft(float rAB, float rBC, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.500, tolPct) and bcValidSoft(rBC, tolPct)

xabcCompatButterflySoft(float rAB, float rBC, float tolPct) =>
    atFibSoft(rAB, 0.786, tolPct) and bcValidSoft(rBC, tolPct)

xabcCompatCrabSoft(float rAB, float rBC, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.618, tolPct) and bcValidSoft(rBC, tolPct)

xabcCompatDeepCrabSoft(float rAB, float rBC, float tolPct) =>
    atFibSoft(rAB, 0.886, tolPct) and bcValidSoft(rBC, tolPct)

xabcCompatSharkSoft(float rAB, float rBC, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.618, tolPct) and bcValidSoft(rBC, tolPct)

xabcCompatCypherSoft(float rAB, float rXC, float tolPct) =>
    inFibRangeSoft(rAB, 0.382, 0.618, tolPct) and inFibRangeSoft(rXC, 1.130, 1.414, tolPct)

xabcCompatABCDSoft(float rAB, float rBC, float tolPct) =>
    inFibRangeSoft(rBC, 0.618, 0.786, tolPct)

// Computes possible D projections for a single XABC
scanFutureForXABC(PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, bool isBullish, float minLeg) =>
    array<FutureProjection> projs = array.new<FutureProjection>()
    float xP = pX.price
    float aP = pA.price
    float bP = pB.price
    float cP = pC.price
    float xa = diff(xP, aP)
    float ab = diff(aP, bP)
    float rAB = calcRatio(ab, xa)
    float rBC = calcRatio(diff(bP, cP), ab)
    float rXC = calcRatio(diff(xP, cP), xa)
    if showGartley and (isSoftMode ? xabcCompatGartleySoft(rAB, rBC, softTolPct) : xabcCompatGartley(rAB, rBC))
        float dP = projectD_ADXA(isBullish, xP, aP, 0.786)
        if projectedDValid(isBullish, xP, aP, bP, cP, dP, minLeg, true)
            projs.push(makeFutureProj("Gartley", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    if showBat and (isSoftMode ? xabcCompatBatSoft(rAB, rBC, softTolPct) : xabcCompatBat(rAB, rBC))
        float dP = projectD_ADXA(isBullish, xP, aP, 0.886)
        if projectedDValid(isBullish, xP, aP, bP, cP, dP, minLeg, true)
            projs.push(makeFutureProj("Bat", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    if showButterfly and (isSoftMode ? xabcCompatButterflySoft(rAB, rBC, softTolPct) : xabcCompatButterfly(rAB, rBC))
        float dP = projectD_ADXA(isBullish, xP, aP, 1.272)
        if projectedDValid(isBullish, xP, aP, bP, cP, dP, minLeg, false)
            projs.push(makeFutureProj("Butterfly", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    if showCrab and (isSoftMode ? xabcCompatCrabSoft(rAB, rBC, softTolPct) : xabcCompatCrab(rAB, rBC))
        float dP = projectD_ADXA(isBullish, xP, aP, 1.618)
        if projectedDValid(isBullish, xP, aP, bP, cP, dP, minLeg, false)
            projs.push(makeFutureProj("Crab", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    if showDeepCrab and (isSoftMode ? xabcCompatDeepCrabSoft(rAB, rBC, softTolPct) : xabcCompatDeepCrab(rAB, rBC))
        float dP = projectD_ADXA(isBullish, xP, aP, 1.618)
        if projectedDValid(isBullish, xP, aP, bP, cP, dP, minLeg, false)
            projs.push(makeFutureProj("Deep Crab", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    if showShark and (isSoftMode ? xabcCompatSharkSoft(rAB, rBC, softTolPct) : xabcCompatShark(rAB, rBC))
        float dP = projectD_Shark(isBullish, xP, cP, 1.374)
        if projectedDValid(isBullish, xP, aP, bP, cP, dP, minLeg, false)
            projs.push(makeFutureProj("Shark", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    if showCypher and (isSoftMode ? xabcCompatCypherSoft(rAB, rXC, softTolPct) : xabcCompatCypher(rAB, rXC))
        float dP = projectD_Cypher(isBullish, xP, aP, cP)
        if projectedDValid(isBullish, xP, aP, bP, cP, dP, minLeg, true)
            projs.push(makeFutureProj("Cypher", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    if showABCD and (isSoftMode ? xabcCompatABCDSoft(rAB, rBC, softTolPct) : xabcCompatABCD(rAB, rBC))
        float dP = projectD_ABCD(isBullish, aP, bP, cP)
        if projectedDValidBasic(isBullish, xP, aP, bP, cP, dP, minLeg)
            projs.push(makeFutureProj("AB=CD", isBullish, pX, pA, pB, pC, dP, rAB, rBC))
    projs

// Scans active XABC projections when last pivot is C
scanFutureProjections(array<PivotPoint> pivots, float minLeg) =>
    array<FutureProjection> allProjs = array.new<FutureProjection>()
    [active, isBull, idx] = getActiveXABC(pivots)
    if active and idx >= 0
        PivotPoint pX = pivots.get(idx)
        PivotPoint pA = pivots.get(idx + 1)
        PivotPoint pB = pivots.get(idx + 2)
        PivotPoint pC = pivots.get(idx + 3)
        if validateXABCStructure(pivots, isBull, pX, pA, pB, pC, minLeg)
            array<FutureProjection> projs = scanFutureForXABC(pX, pA, pB, pC, isBull, minLeg)
            int pn = projs.size()
            if pn > 0
                for p = 0 to pn - 1
                    allProjs.push(projs.get(p))
    allProjs

// Clears drawing objects
method clearLines(array<line> this) =>
    int n = this.size()
    if n > 0
        for i = 0 to n - 1
            line.delete(this.get(i))
        this.clear()

method clearLabels(array<label> this) =>
    int n = this.size()
    if n > 0
        for i = 0 to n - 1
            label.delete(this.get(i))
        this.clear()

method clearBoxes(array<box> this) =>
    int n = this.size()
    if n > 0
        for i = 0 to n - 1
            box.delete(this.get(i))
        this.clear()

method clearPolylines(array<polyline> this) =>
    int n = this.size()
    if n > 0
        for i = 0 to n - 1
            polyline.delete(this.get(i))
        this.clear()

// Merges overlapping future zones in the same direction
mergeProjectionsToZones(array<FutureProjection> projs) =>
    array<MergedFutureZone> merged = array.new<MergedFutureZone>()
    int n = projs.size()
    if n > 0
        for i = 0 to n - 1
            FutureProjection fp = projs.get(i)
            bool found = false
            int mCnt = merged.size()
            if mCnt > 0
                for m = 0 to mCnt - 1
                    MergedFutureZone mz = merged.get(m)
                    if mz.isBullish == fp.isBullish
                        bool overlap = fp.zTop >= mz.zBot and fp.zBot <= mz.zTop
                        if overlap
                            float nTop = math.min(fp.zTop, mz.zTop)
                            float nBot = math.max(fp.zBot, mz.zBot)
                            string nNames = mz.names + " / " + fp.name
                            merged.set(m, MergedFutureZone.new(fp.isBullish, fp.cBar, fp.cPrice, nTop, nBot, nNames))
                            found := true
                            break
            if not found
                merged.push(MergedFutureZone.new(fp.isBullish, fp.cBar, fp.cPrice, fp.zTop, fp.zBot, fp.name))
    merged

// Draws possible D projections
drawFutureProjections(array<FutureProjection> projs, PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, array<line> lnArr, array<label> lbArr, array<box> boxArr) =>
    int n = projs.size()
    if n > 0
        color xabcCol = color.new(color.gray, 50)
        lnArr.push(line.new(pX.barIdx, pX.price, pA.barIdx, pA.price, xloc = xloc.bar_index, color = xabcCol, width = 1, style = line.style_dotted))
        lnArr.push(line.new(pA.barIdx, pA.price, pB.barIdx, pB.price, xloc = xloc.bar_index, color = xabcCol, width = 1, style = line.style_dotted))
        lnArr.push(line.new(pB.barIdx, pB.price, pC.barIdx, pC.price, xloc = xloc.bar_index, color = xabcCol, width = 1, style = line.style_dotted))
        lbArr.push(label.new(pX.barIdx, pX.price, "X?", xloc = xloc.bar_index, style = pX.isHigh ? label.style_label_down : label.style_label_up, color = color.new(xabcCol, 60), textcolor = color.white, size = size.tiny))
        lbArr.push(label.new(pA.barIdx, pA.price, "A", xloc = xloc.bar_index, style = pA.isHigh ? label.style_label_down : label.style_label_up, color = color.new(xabcCol, 60), textcolor = color.white, size = size.tiny))
        lbArr.push(label.new(pB.barIdx, pB.price, "B", xloc = xloc.bar_index, style = pB.isHigh ? label.style_label_down : label.style_label_up, color = color.new(xabcCol, 60), textcolor = color.white, size = size.tiny))
        lbArr.push(label.new(pC.barIdx, pC.price, "C", xloc = xloc.bar_index, style = pC.isHigh ? label.style_label_down : label.style_label_up, color = color.new(xabcCol, 60), textcolor = color.white, size = size.tiny))
        int endBar = bar_index + futureBars
        array<MergedFutureZone> zones = array.new<MergedFutureZone>()
        if mergeFutureZones and n > 1
            zones := mergeProjectionsToZones(projs)
        else
            for i = 0 to n - 1
                FutureProjection fp = projs.get(i)
                zones.push(MergedFutureZone.new(fp.isBullish, fp.cBar, fp.cPrice, fp.zTop, fp.zBot, fp.name))
        int zc = zones.size()
        if zc > 0
            for z = 0 to zc - 1
                MergedFutureZone mz = zones.get(z)
                color col = mz.isBullish ? futureBullCol : futureBearCol
                float zMid = (mz.zTop + mz.zBot) / 2.0
                [touchBar, touchPrice, firstTouch] = findZoneFirstTouch(mz.zTop, mz.zBot, mz.cBar)
                [hitBar, hitPrice, zoneTouched] = findZoneExtremumInZone(mz.isBullish, mz.zTop, mz.zBot, mz.cBar)
                lnArr.push(line.new(mz.cBar, mz.cPrice, endBar, zMid, xloc = xloc.bar_index, color = col, width = zoneTouched ? 2 : 1, style = line.style_dashed))
                if showFutureZone
                    boxArr.push(box.new(mz.cBar, mz.zTop, endBar, mz.zBot, xloc = xloc.bar_index, bgcolor = color.new(col, zoneTouched ? 55 : 78), border_color = col, border_width = zoneTouched ? 3 : 1, border_style = line.style_dashed))
                string dir = mz.isBullish ? "▲" : "▼"
                string rangeTxt = str.tostring(mz.zBot, format.mintick) + " - " + str.tostring(mz.zTop, format.mintick)
                string statusTxt = zoneTouched ? "⚠ POSSIBLE FORMATION" : "Awaiting D pivot"
                string txt = dir + " D? " + mz.names + "\n" + rangeTxt + "\n" + statusTxt
                lbArr.push(label.new(endBar, zMid, txt, xloc = xloc.bar_index, style = mz.isBullish ? label.style_label_up : label.style_label_down, color = color.new(col, zoneTouched ? 10 : 30), textcolor = futureLabelTextCol, size = zoneTouched ? size.normal : size.small))
                if showFutureMarkers and firstTouch and not na(touchBar)
                    lbArr.push(label.new(touchBar, touchPrice, "1st touch", xloc = xloc.bar_index, style = mz.isBullish ? label.style_label_up : label.style_label_down, color = color.new(col, 40), textcolor = futureLabelTextCol, size = size.tiny))
                if showFutureMarkers and zoneTouched and not na(hitBar) and not na(hitPrice)
                    lbArr.push(label.new(hitBar, hitPrice, "⚠ D?\n" + mz.names + "\nPossible Formation", xloc = xloc.bar_index, style = mz.isBullish ? label.style_label_up : label.style_label_down, color = color.new(col, 0), textcolor = futureLabelTextCol, size = size.normal))

// ══════════════════════════════════════════════════════════════════════════════
// DRAWING FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

// Point name + ratio at leg-end pivot (single label — avoids overlap)
drawPivotLegLabel(PivotPoint pEnd, string pointName, string legName, float ratioVal, color col, array<label> lbArr) =>
    lbArr.push(label.new(pEnd.barIdx, pEnd.price, pointName + "\n" + legName + " " + str.tostring(ratioVal, "#.###"), xloc = xloc.bar_index, style = pEnd.isHigh ? label.style_label_down : label.style_label_up, color = color.new(col, 88), textcolor = color.new(col, 15), size = size.tiny))

// Single pivot point label
drawPivotPointLabel(PivotPoint p, string pointName, color col, array<label> lbArr) =>
    lbArr.push(label.new(p.barIdx, p.price, pointName, xloc = xloc.bar_index, style = p.isHigh ? label.style_label_down : label.style_label_up, color = color.new(col, 70), textcolor = color.white, size = size.tiny))

// Butterfly wings: X-A-B and B-C-D fill + X-B / B-D dashed diagonals
drawButterflyWings(PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, PivotPoint pD, color col, int fillTransp, array<line> lnArr, array<polyline> plArr) =>
    if plArr.size() < 95
        color fillCol = color.new(col, fillTransp)
        color dashCol = color.new(col, 45)
        array<chart.point> wingLeft = array.new<chart.point>()
        wingLeft.push(chart.point.from_index(pX.barIdx, pX.price))
        wingLeft.push(chart.point.from_index(pA.barIdx, pA.price))
        wingLeft.push(chart.point.from_index(pB.barIdx, pB.price))
        plArr.push(polyline.new(wingLeft, closed = true, line_color = color.new(col, 100), fill_color = fillCol))
        array<chart.point> wingRight = array.new<chart.point>()
        wingRight.push(chart.point.from_index(pB.barIdx, pB.price))
        wingRight.push(chart.point.from_index(pC.barIdx, pC.price))
        wingRight.push(chart.point.from_index(pD.barIdx, pD.price))
        plArr.push(polyline.new(wingRight, closed = true, line_color = color.new(col, 100), fill_color = fillCol))
        lnArr.push(line.new(pX.barIdx, pX.price, pB.barIdx, pB.price, xloc = xloc.bar_index, color = dashCol, width = 1, style = line.style_dashed))
        lnArr.push(line.new(pB.barIdx, pB.price, pD.barIdx, pD.price, xloc = xloc.bar_index, color = dashCol, width = 1, style = line.style_dashed))

// XABCD zigzag draw — 5 consecutive pivots, 4 legs (X->A->B->C->D)
drawXABCD(bool enabled, HarmonicMatch m, PivotPoint pX, PivotPoint pA, PivotPoint pB, PivotPoint pC, PivotPoint pD, color bullCol, color bearCol, int width, bool labelsOn, bool ratiosOn, bool legRatiosOn, bool butterflyOn, int fillTransp, bool przOn, color przCol, bool stopOn, color stopCol, float atr, float atrForStop, float stopMult, array<line> lnArr, array<label> lbArr, array<box> boxArr, array<polyline> plArr) =>
    float stopP = calcStopPrice(m.isBullish, pD.price, pC.price, atrForStop, stopMult)
    if enabled
        color col = m.isBullish ? bullCol : bearCol
        if butterflyOn
            drawButterflyWings(pX, pA, pB, pC, pD, col, fillTransp, lnArr, plArr)
        lnArr.push(line.new(pX.barIdx, pX.price, pA.barIdx, pA.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(pA.barIdx, pA.price, pB.barIdx, pB.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(pB.barIdx, pB.price, pC.barIdx, pC.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(pC.barIdx, pC.price, pD.barIdx, pD.price, xloc = xloc.bar_index, color = col, width = width))
        float pScore = calcPatternScore(m.name, m.rAB, m.rBC, m.rAD, m.rXC, m.rDCxc)
        float zoneMid = (m.przTop + m.przBot) / 2.0
        int confCnt = countConfluence(pivotArray, zoneMid, atr, confluenceAtrMult)
        if legRatiosOn
            drawPivotLegLabel(pB, "B", "AB/XA", m.rAB, col, lbArr)
            drawPivotLegLabel(pC, "C", "BC/AB", m.rBC, col, lbArr)
            if not labelsOn and not przOn
                drawPivotLegLabel(pD, "D", "CD/BC", m.rCD, col, lbArr)
        if przOn and not na(m.przTop) and not na(m.przBot)
            boxArr.push(box.new(pD.barIdx - 2, m.przTop, pD.barIdx + 5, m.przBot, xloc = xloc.bar_index, bgcolor = przCol, border_color = color.new(#FF9800, 0), border_width = 2))
        if stopOn and not na(stopP)
            lnArr.push(line.new(pD.barIdx, stopP, pD.barIdx + 8, stopP, xloc = xloc.bar_index, color = stopCol, width = 2, style = line.style_dashed))
            lbArr.push(label.new(pD.barIdx + 8, stopP, "STOP\n" + str.tostring(stopP, format.mintick), xloc = xloc.bar_index, style = m.isBullish ? label.style_label_up : label.style_label_down, color = color.new(stopCol, 20), textcolor = color.white, size = size.small))
        if labelsOn
            string dir = m.isBullish ? "▲" : "▼"
            string txt = dir + " " + m.name
            if ratiosOn and m.name != "Three Drives"
                txt += "\nB (XA): " + str.tostring(m.rAB, "#.###")
                txt += "\nBC/AB: " + str.tostring(m.rBC, "#.###")
                if m.name == "Shark"
                    txt += "\nD (XC): " + str.tostring(m.rDCxc, "#.###")
                else
                    txt += "\nD (XA): " + str.tostring(m.rAD, "#.###")
                txt += "\nScore: " + str.tostring(pScore)
                txt += "\nConf: " + str.tostring(confCnt)
                if stopOn and not na(stopP)
                    txt += "\nStop: " + str.tostring(stopP, format.mintick)
            lbArr.push(label.new(pD.barIdx, pD.price, txt, xloc = xloc.bar_index, style = pD.isHigh ? label.style_label_down : label.style_label_up, color = col, textcolor = formationLabelTextCol, size = size.normal))
        drawPivotPointLabel(pX, "X", col, lbArr)
        drawPivotPointLabel(pA, "A", col, lbArr)
        if not legRatiosOn
            drawPivotPointLabel(pB, "B", col, lbArr)
            drawPivotPointLabel(pC, "C", col, lbArr)
        if not labelsOn and not legRatiosOn
            drawPivotPointLabel(pD, "D", col, lbArr)

// Draws Three Drives formation (7-point structure)
drawThreeDrives(bool enabled, array<PivotPoint> pivots, int startIdx, bool isBullish, color bullCol, color bearCol, int width, bool labelsOn, array<line> lnArr, array<label> lbArr) =>
    if enabled
        PivotPoint p0 = pivots.get(startIdx)
        PivotPoint p1 = pivots.get(startIdx + 1)
        PivotPoint p2 = pivots.get(startIdx + 2)
        PivotPoint p3 = pivots.get(startIdx + 3)
        PivotPoint p4 = pivots.get(startIdx + 4)
        PivotPoint p5 = pivots.get(startIdx + 5)
        PivotPoint p6 = pivots.get(startIdx + 6)
        color col = isBullish ? bullCol : bearCol
        lnArr.push(line.new(p0.barIdx, p0.price, p1.barIdx, p1.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(p1.barIdx, p1.price, p2.barIdx, p2.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(p2.barIdx, p2.price, p3.barIdx, p3.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(p3.barIdx, p3.price, p4.barIdx, p4.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(p4.barIdx, p4.price, p5.barIdx, p5.price, xloc = xloc.bar_index, color = col, width = width))
        lnArr.push(line.new(p5.barIdx, p5.price, p6.barIdx, p6.price, xloc = xloc.bar_index, color = col, width = width))
        if labelsOn
            string dir = isBullish ? "▲" : "▼"
            lbArr.push(label.new(p6.barIdx, p6.price, dir + " Three Drives", xloc = xloc.bar_index, style = isBullish ? label.style_label_up : label.style_label_down, color = col, textcolor = formationLabelTextCol, size = size.small))

// Empty match for Pine series consistency (no side effects)
getIdleMatch() =>
    HarmonicMatch.new("Idle", false, bar_index, bar_index, bar_index, bar_index, bar_index, close, close, close, close, close, 0., 0., 0., 0., 0., 0., 0., 0., 0)

// Formation record and draw (no series access — safe to call in loops)
commitMatch(HarmonicMatch m, bool forceDraw, bool idleOnly, float atrForStop, int dTimeVal) =>
    string sig = makeSignature(m.name, m.xBar, m.aBar, m.bBar, m.cBar, m.dBar)
    bool alreadyDrawn = false
    int sigCount = drawnSignatures.size()
    if sigCount > 0 and not forceDraw and not idleOnly
        for k = 0 to sigCount - 1
            if drawnSignatures.get(k) == sig
                alreadyDrawn := true
                break
    bool doProcess = not idleOnly and (not alreadyDrawn or forceDraw)
    bool isThreeDrives = m.name == "Three Drives"
    PivotPoint pX = PivotPoint.new(m.xBar, m.xPrice, not m.isBullish)
    PivotPoint pA = PivotPoint.new(m.aBar, m.aPrice, m.isBullish)
    PivotPoint pB = PivotPoint.new(m.bBar, m.bPrice, not m.isBullish)
    PivotPoint pC = PivotPoint.new(m.cBar, m.cPrice, m.isBullish)
    PivotPoint pD = PivotPoint.new(m.dBar, m.dPrice, not m.isBullish)
    if doProcess
        if not alreadyDrawn
            drawnSignatures.push(sig)
            if drawnSignatures.size() > maxStoredPatterns
                drawnSignatures.shift()
        float pScore = calcPatternScore(m.name, m.rAB, m.rBC, m.rAD, m.rXC, m.rDCxc)
        float zMid = (m.przTop + m.przBot) / 2.0
        int confCnt = countConfluence(pivotArray, zMid, atrVal, confluenceAtrMult)
        formationHistory.push(FormationRecord.new(m.dBar, dTimeVal, m.name, m.isBullish, sig, pScore, confCnt))
        if formationHistory.size() > maxStoredPatterns
            formationHistory.shift()
    drawThreeDrives(doProcess and isThreeDrives, pivotArray, m.scanIdx, m.isBullish, bullColor, bearColor, lineWidth, showLabels, patternLines, patternLabels)
    drawXABCD(doProcess and not isThreeDrives, m, pX, pA, pB, pC, pD, bullColor, bearColor, lineWidth, showLabels, showRatios, showLegRatios, showButterflyWings, wingFillTransp, showPRZ, przColor, showStop, stopColor, atrVal, atrForStop, stopAtrMult, patternLines, patternLabels, patternBoxes, patternPolylines)
    doProcess

// Series consistency wrapper — called once per bar in main loop only
applyMatch(HarmonicMatch m, bool forceDraw, bool idleOnly) =>
    float atrForStop = getAtrAtBar(m.dBar)
    int dTimeVal = getBarTime(m.dBar)
    commitMatch(m, forceDraw, idleOnly, na(atrForStop) ? atrVal : atrForStop, dTimeVal)

// Redraws historical formations — called every bar
redrawAllHistoricalPatterns(float minLeg, bool enabled) =>
    if enabled
        patternLines.clearLines()
        patternLabels.clearLabels()
        patternBoxes.clearBoxes()
        patternPolylines.clearPolylines()
        drawnSignatures.clear()
        formationHistory.clear()
    array<HarmonicMatch> found = enabled ? scanAllPatterns(pivotArray, minLeg) : array.new<HarmonicMatch>()
    int matchCount = found.size()
    int drawCount = enabled and matchCount > 0 ? matchCount - math.max(0, matchCount - maxStoredPatterns) : 0
    int loopEnd = math.max(1, drawCount) - 1
    for j = 0 to loopEnd
        bool isIdle = drawCount == 0 or j >= drawCount
        int fIdx = drawCount > 0 ? math.max(0, matchCount - maxStoredPatterns) + j : 0
        HarmonicMatch m = isIdle ? getIdleMatch() : found.get(fIdx)
        int bb = bar_index - m.dBar
        float atrFS = atrVal
        int dTime = time
        if bb >= 0 and bb <= 5000
            float atrAtD = atrVal[bb]
            atrFS := na(atrAtD) ? atrVal : atrAtD
            dTime := time[bb]
        commitMatch(m, not isIdle, isIdle, atrFS, dTime)

// New pivot scan — called every bar
processPivotMatches(float minLeg, bool enabled) =>
    array<HarmonicMatch> found = enabled ? scanAllPatterns(pivotArray, minLeg) : array.new<HarmonicMatch>()
    int matchCount = found.size()
    bool triggered = false
    int loopEnd = math.max(1, matchCount) - 1
    for j = 0 to loopEnd
        bool isIdle = not enabled or matchCount == 0 or j >= matchCount
        HarmonicMatch m = isIdle ? getIdleMatch() : found.get(j)
        int bb = bar_index - m.dBar
        float atrFS = atrVal
        int dTime = time
        if bb >= 0 and bb <= 5000
            float atrAtD = atrVal[bb]
            atrFS := na(atrAtD) ? atrVal : atrAtD
            dTime := time[bb]
        if commitMatch(m, false, isIdle, atrFS, dTime) and not isIdle
            triggered := true
    triggered

// ══════════════════════════════════════════════════════════════════════════════
// MAIN EXECUTION LOOP
// ══════════════════════════════════════════════════════════════════════════════

float minLegSize = atrVal * minLegAtr

string configHash = buildConfigHash()
bool configChanged = configHash != lastConfigHash
if configChanged
    lastConfigHash := configHash

bool newPivot = not na(ph) or not na(pl)
bool alertPatTrigger = false
bool alertZoneTrigger = false
bool alertPossibleTrigger = false

bool needRedraw = barstate.isfirst or configChanged
redrawAllHistoricalPatterns(minLegSize, needRedraw)

// Pine series consistency: getAtrAtBar/getBarTime called exactly once per bar
applyMatch(getIdleMatch(), false, true)

bool shouldScanMatches = barstate.isconfirmed and newPivot
alertPatTrigger := processPivotMatches(minLegSize, shouldScanMatches)

// See the Future: live XABC -> possible D projections (updated on last bar)
if barstate.islast
    futureLines.clearLines()
    futureLabels.clearLabels()
    futureBoxes.clearBoxes()
    pendingSummary := "None"
    if showFuture
        array<FutureProjection> futureProjs = scanFutureProjections(pivotArray, minLegSize)
        int fpCount = futureProjs.size()
        if fpCount > 0
            [active, isBull, idx] = getActiveXABC(pivotArray)
            if active and idx >= 0
                PivotPoint pX = pivotArray.get(idx)
                PivotPoint pA = pivotArray.get(idx + 1)
                PivotPoint pB = pivotArray.get(idx + 2)
                PivotPoint pC = pivotArray.get(idx + 3)
                drawFutureProjections(futureProjs, pX, pA, pB, pC, futureLines, futureLabels, futureBoxes)
                FutureProjection fp0 = pickBestFutureProjection(futureProjs)
                string pDir = fp0.isBullish ? "▲" : "▼"
                pendingSummary := pDir + " " + fp0.name + " | " + str.tostring(fp0.zBot, format.mintick) + "-" + str.tostring(fp0.zTop, format.mintick) + " | Awaiting D"
                [tBar, tPr, tOk] = findZoneFirstTouch(fp0.zTop, fp0.zBot, fp0.cBar)
                [hBar, hPr, hOk] = findZoneExtremumInZone(fp0.isBullish, fp0.zTop, fp0.zBot, fp0.cBar)
                if tOk
                    alertZoneTrigger := true
                if hOk
                    alertPossibleTrigger := true

// Alerts
if alertPatternComplete and alertPatTrigger
    alert("Harmonic pattern completed", alert.freq_once_per_bar)
if alertZoneTouch and alertZoneTrigger
    alert("Price entered future D zone", alert.freq_once_per_bar)
if alertPossibleFormation and alertPossibleTrigger
    alert("Possible harmonic formation in D zone", alert.freq_once_per_bar)

alertcondition(alertPatTrigger, "Pattern Completed", "Harmonic pattern completed")
alertcondition(alertZoneTrigger, "Future Zone Touched", "Price entered future D zone")
alertcondition(alertPossibleTrigger, "Possible Formation", "Possible harmonic formation in D zone")

// ══════════════════════════════════════════════════════════════════════════════
// INFO TABLE (SUMMARY + HISTORY) — dynamic row count, no empty space
// ══════════════════════════════════════════════════════════════════════════════

var table infoTable = na

if barstate.islast
    int histSize = formationHistory.size()
    int showCount = math.min(histSize, tableHistRows)
    int histDataRows = showCount > 0 ? showCount : 1
    int totalRows = 1 + TABLE_SUMMARY_ROWS + 1 + TABLE_ANALYTICS_ROWS + 1 + histDataRows
    float avgScore = calcAvgPatternScore(formationHistory)
    if not na(infoTable)
        table.delete(infoTable)
    infoTable := table.new(position.top_right, 2, totalRows, bgcolor = color.new(#1A1A2E, 10), border_width = 2, border_color = color.new(color.white, 70), frame_width = 2, frame_color = color.new(color.white, 50))
    // Header row
    table.merge_cells(infoTable, 0, 0, 1, 0)
    table.cell(infoTable, 0, 0, "HARMONIC PATTERNS", text_color = color.white, text_size = size.normal, bgcolor = color.new(#16213E, 0))
    // Summary
    table.cell(infoTable, 0, 1, "Pivot Count", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, 1, str.tostring(pivotArray.size()), text_color = color.yellow, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 0, 2, "Total Patterns", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, 2, str.tostring(formationHistory.size()), text_color = color.lime, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 0, 3, "Mode", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    string modeLabel = isSoftMode ? "SOFT (" + str.tostring(softTolPct, "#.#") + "%)" : "STRICT"
    color modeColor = isSoftMode ? color.orange : color.red
    table.cell(infoTable, 1, 3, modeLabel, text_color = modeColor, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 0, 4, "Pivot L/R", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, 4, str.tostring(pivotLeft) + " / " + str.tostring(pivotRight), text_color = color.aqua, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 0, 5, "Pending", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, 5, pendingSummary, text_color = color.orange, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 0, 6, "See the Future", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, 6, showFuture ? "ON" : "OFF", text_color = showFuture ? color.lime : color.gray, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 0, 7, "Max Stored", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, 7, str.tostring(maxStoredPatterns), text_color = color.white, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 0, 8, "Confluence ATR", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, 8, str.tostring(confluenceAtrMult, "#.#"), text_color = color.white, text_size = size.normal, bgcolor = color.new(color.black, 60))
    // Analytics header
    int analyticsHeaderRow = TABLE_SUMMARY_ROWS + 1
    table.merge_cells(infoTable, 0, analyticsHeaderRow, 1, analyticsHeaderRow)
    table.cell(infoTable, 0, analyticsHeaderRow, "— ANALYTICS —", text_color = color.white, text_size = size.normal, bgcolor = color.new(#0F3460, 0))
    table.cell(infoTable, 0, analyticsHeaderRow + 1, "Avg Pattern Score", text_color = color.silver, text_size = size.normal, bgcolor = color.new(color.black, 60))
    table.cell(infoTable, 1, analyticsHeaderRow + 1, str.tostring(avgScore, "#.#"), text_color = color.lime, text_size = size.normal, bgcolor = color.new(color.black, 60))
    // History header
    int histHeaderRow = TABLE_SUMMARY_ROWS + 1 + TABLE_ANALYTICS_ROWS + 1
    table.merge_cells(infoTable, 0, histHeaderRow, 1, histHeaderRow)
    table.cell(infoTable, 0, histHeaderRow, "— PATTERN HISTORY (" + str.tostring(showCount) + ") —", text_color = color.white, text_size = size.normal, bgcolor = color.new(#0F3460, 0))
    // History list (newest first)
    int firstHistRow = histHeaderRow + 1
    if showCount > 0
        array<int> sortedIdx = array.sort_indices(formationHistory, order = order.descending)
        for r = 0 to showCount - 1
            int rowIdx = firstHistRow + r
            FormationRecord rec = formationHistory.get(sortedIdx.get(r))
            string dateStr = formatBarDate(rec.dTime, tableShowTime)
            string dirStr = rec.isBullish ? "▲" : "▼"
            color rowCol = rec.isBullish ? bullColor : bearColor
            table.cell(infoTable, 0, rowIdx, dateStr, text_color = color.white, text_size = size.normal, bgcolor = color.new(color.black, 40))
            table.cell(infoTable, 1, rowIdx, dirStr + " " + rec.name + " | S:" + str.tostring(rec.score), text_color = rowCol, text_size = size.normal, bgcolor = color.new(color.black, 40))
    else
        table.merge_cells(infoTable, 0, firstHistRow, 1, firstHistRow)
        table.cell(infoTable, 0, firstHistRow, "No patterns yet", text_color = color.gray, text_size = size.normal, bgcolor = color.new(color.black, 40))
````
