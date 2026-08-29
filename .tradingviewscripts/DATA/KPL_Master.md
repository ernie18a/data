<!-- tradingview-pine-id: PUB;5c5e51fd107c4511b5c9dbbd094f4293 -->
<!-- tradingviewscripts-format: 1 -->
# KPL Master

Source: https://www.tradingview.com/script/hs66BDn4-10AM-10pm-KPL-auto-fib-with-supply-and-demand/

## Description

# KPL Master — Fib + Structure, Supply/Demand, Top Down Analysis

## Short description (for the summary field)

Three tools in one: an auto-fib retracement engine anchored to market structure, supply/demand zone mapping, and a multi-timeframe bias dashboard with a daily-direction filter.

---

## Full description

KPL Master combines three separate workflows into a single script so a chart doesn't need three indicators competing for the same space. Each module has its own on/off switch and its own settings group, so you can run one, two, or all three.

### 1. Fib + Structure

Finds significant swing points and draws Fibonacci retracement levels on the leg between them.

**Swing detection.** Pivots are found with configurable left/right bar counts, then filtered for significance — either by an ATR multiple or a fixed point distance. Legs that don't travel far enough are discarded, so a quiet range doesn't fill the chart with levels. Major and minor pivots are tracked separately.

**Leg selection.** Several legs can qualify at once. Each is scored on distance travelled, whether it's major or minor, whether price has already touched its zone, and how far price sits from that zone. The highest-scoring leg is drawn as active, with full retracement levels: .50, .62, .705, .786 and .85, plus 0% and 100% anchors. Remaining legs show as outlined zones.

**Provisional legs.** A swing isn't confirmed until the pivot completes, which lags by the right-bar setting. Provisional legs are drawn from the developing swing so a forming setup is visible immediately. They can be styled differently — dashed by default — so a live leg is never mistaken for a confirmed one.

**Invalidation.** A leg dies when price moves through its origin anchor, by wick or by close, your choice. Optional rules remove a leg after its first touch, after the .50 is crossed, or after a set age. Provisional legs are invalidated on the same rule and stay dead until a new pivot replaces them.

**Structure labels.** HH / HL / LH / LL tags, BOS and CHoCH breaks, optional sweep tags, and "LL forming" / "HH forming" flags that fire on the bar the break happens rather than waiting for pivot confirmation. A panel reports trend state, active sweep, and stored leg counts.

### 2. Supply / Demand

Marks zones where a base candle is followed by displacement.

A zone forms when the candle after a base breaks its range — by wick or by close — optionally requiring the displacement candle to be the opposite colour of the base and its body to exceed an ATR multiple. Zones extend forward until price invalidates them, either on a close beyond the zone or on a full body beyond it. Zone count per side is capped, and zone labels carry the chart timeframe so multiple copies of the script on different timeframes stay readable.

### 3. Top Down Analysis

A dashboard that reads four higher timeframes at once — Daily, 4H, 1H and 15M by default, all configurable.

**Direction and location are kept separate.** Structure sets direction on each timeframe via break of structure. Location then grades it: a bullish timeframe in discount grades A, at equilibrium B, at premium C. Sitting inside a supply or demand zone on that timeframe raises the grade one step. The point is that "bullish" and "good place to buy" are different statements, and averaging them into one number loses both.

**Unresolved state.** A bias latches until an opposite break, which means it can describe a move that ended weeks ago. If price has retraced past a configurable threshold against the latched bias without a new break, that row reads `-` and scores zero rather than voting on stale information.

**Alignment score.** Timeframes are weighted, with higher timeframes counting more. Neighbouring timeframes agreeing adds conviction, since 4H and 1H aligned is a more coherent statement than the same count of scattered agreement. A shape row shows which way each timeframe points, because a net score hides which ones disagree.

**Leg size in points** is shown per row, so you can see whether a timeframe's "discount" is 40 points away or 2,000 — a grade means little without knowing the scale it's measured on.

**Day gate.** A single line reading GREEN, RED or MIXED. Green requires price above both today's open and the previous day's close; if the two disagree it says MIXED rather than guessing. This answers "am I looking for trades against the day?", which structural daily bias does not. It is display only and blocks nothing. Note that it can flip intraday — it filters which setups you look for, it does not protect an open position.

**Levels.** Untouched swing highs and lows per timeframe, previous day and previous week high/low, and optional 10AM / 10PM / midnight session opens with individual colour and width settings. Levels that sit close together merge into a single line and shared label instead of stacking unreadably. Swings price has closed through are relabelled as broken.

### Notes

- Higher-timeframe readings update on the forming HTF bar, so a row can change until that bar closes.
- The modules are independent — they display alongside each other but do not currently feed signals into one another.
- No part of this script predicts price or generates trade signals. It organises structure, location, and higher-timeframe context so you can make your own decisions. Past behaviour of any level or zone does not indicate future results.

### Settings groups

`00` module switches · `01–06` Fib + Structure · `07` Supply/Demand · `08–12` Top Down ladder, structure, scoring and levels · `13` session opens · `14` day gate · `15` dashboard

---

## Source Code

````pine
//@version=6
// ═════════════════════════════════════════════════════════════
// KPL MASTER — Fib + Structure / Supply & Demand / Top Down
//
// Three previously separate scripts merged into one. Each module
// has a master switch in group 00 and keeps its own settings
// group. The modules do NOT share signals with each other yet —
// they coexist. Cross-module confluence is a separate build.
//
// RENAMES made during the merge (collisions between the three):
//   atrLen   -> fibAtrLen / sdAtrLen / tdaAtrLen
//   atrMult  -> fibAtrMult / tdaAtrMult
//   brokeUp  -> brokeUp (fib) / sdBrokeUp (S/D)
//   brokeDn  -> sdBrokeDn (S/D)
//   extendBar-> sdExtend
// Everything else kept its original name.
//
// Sources: KPL Fib + Structure v1.5, 5 Min Supply & Demand,
//          KPL Top Down Analysis v1.6
// ═════════════════════════════════════════════════════════════

indicator(
     "KPL Master",
     shorttitle = "KPL",
     overlay = true,
     max_bars_back = 1000,
     max_lines_count = 500,
     max_boxes_count = 500,
     max_labels_count = 500)

// ═════════════════════════════════════════════════════════════
// 00 — MODULE SWITCHES
// ═════════════════════════════════════════════════════════════

string gModules = "00 — Modules"

bool enableFib = input.bool(
     true,
     "Fib + Structure",
     group = gModules)

bool enableSD = input.bool(
     true,
     "Supply / Demand zones",
     group = gModules)

bool enableTDA = input.bool(
     true,
     "Top Down Analysis",
     group = gModules)

bool enableSess = input.bool(
     true,
     "Session open lines",
     group = gModules)

// ═════════════════════════════════════════════════════════════
// INPUTS — FIB + STRUCTURE
// ═════════════════════════════════════════════════════════════

string gSwing = "01 — Swing Engine"

string sigMode = input.string("ATR-gated", "Significance mode", options = ["ATR-gated", "Fixed"], group = gSwing)
float fibAtrMult = input.float(1.2, "ATR multiple", minval = 0.1, step = 0.1, group = gSwing)
int fibAtrLen = input.int(14, "ATR length", minval = 1, group = gSwing)
float fixedMinDistance = input.float(25.0, "Fixed minimum leg distance", minval = 0.0, step = 0.25, group = gSwing)
int leftMajor = input.int(5, "Major pivot — left bars", minval = 1, group = gSwing)
int rightMajor = input.int(2, "Major pivot — right bars", minval = 1, group = gSwing)
int leftMinor = input.int(3, "Minor pivot — left bars", minval = 1, group = gSwing)
int rightMinor = input.int(1, "Minor pivot — right bars", minval = 1, group = gSwing)
int maxPairs = input.int(2, "Opposing pivots tested", minval = 1, maxval = 5, group = gSwing)
int maxLegBars = input.int(40, "Maximum leg width", minval = 4, group = gSwing)
int maxMajorLegs = input.int(6, "Maximum stored major legs", minval = 1, maxval = 12, group = gSwing)
int maxMinorLegs = input.int(4, "Maximum stored minor legs", minval = 1, maxval = 12, group = gSwing)
bool showMinorLegs = input.bool(false, "Show minor-leg zones", group = gSwing)
bool showProvisionalLegs = input.bool(true, "Show provisional live legs", tooltip = "Provisional legs can repaint until the swing confirms.", group = gSwing)

string gLife = "02 — Leg Lifecycle"

string invalidationMode = input.string("Close beyond origin", "Leg invalidation", options = ["Close beyond origin", "Wick beyond origin"], group = gLife)
bool useLegExpiry = input.bool(false, "Expire old untouched legs", group = gLife)
int legLifeBars = input.int(250, "Untouched-leg lifetime", minval = 5, group = gLife)
bool removeAfterTouch = input.bool(false, "Remove after first touch", tooltip = "Removes the zone on the bar after its first touch.", group = gLife)
bool removeAfterMidpoint = input.bool(false, "Remove after .50 is crossed", group = gLife)
bool preserveUntouched = input.bool(true, "Prioritize untouched legs", group = gLife)

string gStructure = "03 — Structure and Bias"

int consolidationBars = input.int(20, "Bars without break = consolidating", minval = 2, group = gStructure)
string breakConfirmation = input.string("Close", "Break confirmation", options = ["Close", "Wick"], group = gStructure)
bool showStructureTags = input.bool(true, "Show HH / HL / LH / LL", group = gStructure)
bool showBreakLabels = input.bool(true, "Show BOS / CHoCH", group = gStructure)
bool showSweepLabels = input.bool(false, "Show sweep labels", group = gStructure)
bool showFormingTags = input.bool(true, "Show forming LL / HH tags", group = gStructure)
bool showBiasPanel = input.bool(true, "Show bias panel", group = gStructure)

string gRender = "04 — Rendering"

bool showZoneBoxes = input.bool(true, "Show zone boxes", group = gRender)
bool showInactiveBorders = input.bool(true, "Show inactive-zone borders", group = gRender)
bool showAnchorLines = input.bool(true, "Show 0% and 100% anchors", group = gRender)
int zoneExtension = input.int(3, "Zone extension bars", minval = 0, maxval = 100, group = gRender)
int lineExtension = input.int(3, "Line extension bars", minval = 0, maxval = 100, group = gRender)
int fibLineWidth = input.int(2, "Fib line width", minval = 1, maxval = 5, group = gRender)
int anchorLineWidth = input.int(1, "Anchor line width", minval = 1, maxval = 5, group = gRender)
string confirmedStyleInput = input.string("Solid", "Confirmed line style", options = ["Solid", "Dashed", "Dotted"], group = gRender)
string provisionalStyleInput = input.string("Dashed", "Provisional line style", options = ["Solid", "Dashed", "Dotted"], group = gRender)
int confirmedZoneTransparency = input.int(88, "Confirmed-zone transparency", minval = 0, maxval = 100, group = gRender)
int provisionalZoneTransparency = input.int(93, "Provisional-zone transparency", minval = 0, maxval = 100, group = gRender)
int touchedZoneFade = input.int(6, "Additional fade after touch", minval = 0, maxval = 50, group = gRender)
int sweptLineTransparency = input.int(70, "Swept-anchor line transparency", minval = 0, maxval = 100, group = gRender)
int inactiveBorderTransparency = input.int(65, "Inactive border transparency", minval = 0, maxval = 100, group = gRender)

string gColors = "05 — Colors"

color color50 = input.color(color.black, ".50 line", group = gColors)
color color62 = input.color(color.blue, ".62 line", group = gColors)
color color705 = input.color(color.lime, ".705 line", group = gColors)
color color786 = input.color(color.yellow, ".786 line", group = gColors)
color color85 = input.color(color.red, ".85 line", group = gColors)
color zeroAnchorColor = input.color(color.black, "0% anchor", group = gColors)
color hundredAnchorColor = input.color(color.gray, "100% anchor", group = gColors)
color majorBullZoneColor = input.color(color.teal, "Major bullish zone", group = gColors)
color majorBearZoneColor = input.color(color.maroon, "Major bearish zone", group = gColors)
color minorBullZoneColor = input.color(color.aqua, "Minor bullish zone", group = gColors)
color minorBearZoneColor = input.color(color.orange, "Minor bearish zone", group = gColors)
color provisionalBullColor = input.color(color.green, "Provisional bullish zone", group = gColors)
color provisionalBearColor = input.color(color.red, "Provisional bearish zone", group = gColors)

string gLabels = "06 — Labels"

bool showFibLabels = input.bool(true, "Show active fib labels", group = gLabels)
bool showFibPrices = input.bool(true, "Include prices in fib labels", group = gLabels)
bool showAnchorLabels = input.bool(false, "Show anchor labels", group = gLabels)
int fibLabelOffset = input.int(5, "Fib label offset", minval = 0, maxval = 100, group = gLabels)
string fibLabelSizeInput = input.string("Tiny", "Fib label size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels)
color fibLabelTextColor = input.color(color.white, "Fib label text", group = gLabels)
color fibLabelBackground = input.color(color.black, "Fib label background", group = gLabels)
int fibLabelTransparency = input.int(25, "Fib label transparency", minval = 0, maxval = 100, group = gLabels)
string structureLabelSizeInput = input.string("Tiny", "Structure label size", options = ["Tiny", "Small", "Normal"], group = gLabels)
color structureTextColor = input.color(color.gray, "Structure tag text", group = gLabels)
color structureBackground = input.color(color.gray, "Structure tag background", group = gLabels)
int structureTransparency = input.int(85, "Structure tag transparency", minval = 0, maxval = 100, group = gLabels)
color bullishBosColor = input.color(color.green, "Bullish BOS", group = gLabels)
color bearishBosColor = input.color(color.red, "Bearish BOS", group = gLabels)
color chochColor = input.color(color.orange, "CHoCH", group = gLabels)
color sweepColor = input.color(color.purple, "Sweep labels", group = gLabels)

// ═════════════════════════════════════════════════════════════
// INPUTS — SUPPLY / DEMAND
// ═════════════════════════════════════════════════════════════

string sdGD = "07 — S/D Detection"

string sdBreakMode = input.string("Wick", "Validation candle must break base by", options = ["Wick", "Close"], group = sdGD)
bool sdRequireOpp = input.bool(true, "Validation candle must be opposite color of base", group = sdGD)
bool sdUseSize = input.bool(true, "Require minimum displacement size", group = sdGD)
float sdSizeMult = input.float(1.0, "    Displacement body >= ATR x", minval = 0.1, step = 0.1, group = sdGD)
int sdAtrLen = input.int(14, "    ATR length", minval = 1, group = sdGD)

string sdGI = "07b — S/D Invalidation"

string sdInvMode = input.string("Full body", "Remove zone on", options = ["Close beyond", "Full body"], group = sdGI)
int sdMaxZones = input.int(100, "Max live zones per side", minval = 1, maxval = 250, group = sdGI)
int sdExtend = input.int(20, "Extend zones (bars past current)", minval = 0, maxval = 200, group = sdGI)

string sdGS = "07c — S/D Style"

color sdSupCol = input.color(color.new(color.blue, 70), "Supply fill", group = sdGS, inline = "sup")
color sdSupBrd = input.color(color.new(color.blue, 30), "border", group = sdGS, inline = "sup")
color sdDemCol = input.color(color.new(color.orange, 70), "Demand fill", group = sdGS, inline = "dem")
color sdDemBrd = input.color(color.new(color.orange, 30), "border", group = sdGS, inline = "dem")
bool sdShowTxt = input.bool(true, "Show zone labels", group = sdGS)
color sdTxtCol = input.color(color.new(color.gray, 20), "    Label color", group = sdGS)
string sdTxtSize = input.string("Small", "    Label size", options = ["Tiny", "Small", "Normal"], group = sdGS)
string sdTxtAlign = input.string("Center", "    Label position", options = ["Left", "Center", "Right"], group = sdGS)

// ═════════════════════════════════════════════════════════════
// TYPES
// ═════════════════════════════════════════════════════════════

type PivotPoint
    float price
    int pivotBar
    bool isHigh

type FibLeg
    float zeroPrice
    float originPrice
    int zeroBar
    int originBar
    bool bullish
    bool major
    bool anchorSwept
    bool touched
    int firstTouchBar
    float strength

// ═════════════════════════════════════════════════════════════
// ARRAYS AND OBJECT POOLS
// ═════════════════════════════════════════════════════════════

var array<PivotPoint> majorHighs = array.new<PivotPoint>()
var array<PivotPoint> majorLows = array.new<PivotPoint>()
var array<PivotPoint> minorHighs = array.new<PivotPoint>()
var array<PivotPoint> minorLows = array.new<PivotPoint>()

var array<FibLeg> majorLegs = array.new<FibLeg>()
var array<FibLeg> minorLegs = array.new<FibLeg>()

const int MAX_DRAW_LOOKBACK = 500

const int BOX_POOL_SIZE = 28
const int LINE_POOL_SIZE = 7
const int LABEL_POOL_SIZE = 7

var array<box> boxPool = array.new<box>()
var array<line> linePool = array.new<line>()
var array<label> labelPool = array.new<label>()

color hiddenColor = color.new(color.gray, 100)

// Pools are always built, even when the module is off, so the
// render helpers can never index an empty array.

if barstate.isfirst
    for i = 0 to BOX_POOL_SIZE - 1
        box newBox = box.new(bar_index, close, bar_index, close, border_color = hiddenColor, bgcolor = hiddenColor)
        array.push(boxPool, newBox)

    for i = 0 to LINE_POOL_SIZE - 1
        line newLine = line.new(bar_index, close, bar_index, close, color = hiddenColor)
        array.push(linePool, newLine)

    for i = 0 to LABEL_POOL_SIZE - 1
        label newLabel = label.new(bar_index, close, "", style = label.style_label_left, color = hiddenColor, textcolor = hiddenColor, size = size.tiny)
        array.push(labelPool, newLabel)

// ═════════════════════════════════════════════════════════════
// GLOBAL SERIES CALCULATIONS
// ═════════════════════════════════════════════════════════════

float atrValue = ta.atr(fibAtrLen)

float majorPivotHigh = ta.pivothigh(high, leftMajor, rightMajor)
float majorPivotLow = ta.pivotlow(low, leftMajor, rightMajor)
float minorPivotHigh = ta.pivothigh(high, leftMinor, rightMinor)
float minorPivotLow = ta.pivotlow(low, leftMinor, rightMinor)

int majorLowestOffsetRaw = ta.lowestbars(low, rightMajor + 1)
int majorHighestOffsetRaw = ta.highestbars(high, rightMajor + 1)

int majorLowestOffset = math.abs(majorLowestOffsetRaw)
int majorHighestOffset = math.abs(majorHighestOffsetRaw)

float majorAtrAtPivot = nz(atrValue[rightMajor], atrValue)
float minorAtrAtPivot = nz(atrValue[rightMinor], atrValue)

float majorMinimumDistance = fixedMinDistance

if sigMode == "ATR-gated"
    majorMinimumDistance := fibAtrMult * majorAtrAtPivot

float minorMinimumDistance = fixedMinDistance * 0.50

if sigMode == "ATR-gated"
    minorMinimumDistance := fibAtrMult * 0.50 * minorAtrAtPivot

minorMinimumDistance := math.max(minorMinimumDistance, syminfo.mintick)

// ═════════════════════════════════════════════════════════════
// DISPLAY HELPERS
// ═════════════════════════════════════════════════════════════

drawBar(int requestedBar) =>
    int earliestBar = bar_index - MAX_DRAW_LOOKBACK
    math.max(requestedBar, earliestBar)

getLineStyle(string selectedStyle) =>
    result = line.style_solid
    if selectedStyle == "Dashed"
        result := line.style_dashed
    else if selectedStyle == "Dotted"
        result := line.style_dotted
    result

getFibLabelSize(string selectedSize) =>
    result = size.tiny
    if selectedSize == "Small"
        result := size.small
    else if selectedSize == "Normal"
        result := size.normal
    else if selectedSize == "Large"
        result := size.large
    result

getStructureLabelSize(string selectedSize) =>
    result = size.tiny
    if selectedSize == "Small"
        result := size.small
    else if selectedSize == "Normal"
        result := size.normal
    result

confirmedLineStyle = getLineStyle(confirmedStyleInput)
provisionalLineStyle = getLineStyle(provisionalStyleInput)
fibLabelSize = getFibLabelSize(fibLabelSizeInput)
structureLabelSize = getStructureLabelSize(structureLabelSizeInput)

// ═════════════════════════════════════════════════════════════
// LEG CALCULATIONS
// ═════════════════════════════════════════════════════════════

fibPrice(FibLeg leg, float ratio) =>
    float result = na
    if leg.bullish
        result := leg.zeroPrice - ratio * (leg.zeroPrice - leg.originPrice)
    else
        result := leg.zeroPrice + ratio * (leg.originPrice - leg.zeroPrice)
    result

legDistance(FibLeg leg) =>
    math.abs(leg.zeroPrice - leg.originPrice)

zoneTop(FibLeg leg) =>
    float price62 = fibPrice(leg, 0.62)
    float price786 = fibPrice(leg, 0.786)
    math.max(price62, price786)

zoneBottom(FibLeg leg) =>
    float price62 = fibPrice(leg, 0.62)
    float price786 = fibPrice(leg, 0.786)
    math.min(price62, price786)

zoneTouchedNow(FibLeg leg) =>
    low <= zoneTop(leg) and high >= zoneBottom(leg)

crossedMidpoint(FibLeg leg) =>
    float midpoint = fibPrice(leg, 0.50)
    bool crossed = false
    if leg.bullish
        crossed := low <= midpoint
    else
        crossed := high >= midpoint
    crossed

legInvalidated(FibLeg leg) =>
    bool invalidated = false
    if invalidationMode == "Wick beyond origin"
        if leg.bullish
            invalidated := low < leg.originPrice
        else
            invalidated := high > leg.originPrice
    else
        if leg.bullish
            invalidated := close < leg.originPrice
        else
            invalidated := close > leg.originPrice
    invalidated

sameLeg(FibLeg firstLeg, FibLeg secondLeg) =>
    firstLeg.bullish == secondLeg.bullish and
     firstLeg.zeroBar == secondLeg.zeroBar and
     firstLeg.originBar == secondLeg.originBar

legAlreadyExists(array<FibLeg> legs, FibLeg candidate) =>
    bool exists = false
    if array.size(legs) > 0
        for i = 0 to array.size(legs) - 1
            FibLeg existing = array.get(legs, i)
            if sameLeg(existing, candidate)
                exists := true
                break
    exists

legPreservationScore(FibLeg leg) =>
    float atrDenominator = math.max(atrValue, syminfo.mintick)
    float normalizedDistance = legDistance(leg) / atrDenominator
    float score = 0.0
    if leg.major
        score += 100.0
    score += normalizedDistance * 10.0
    score += leg.strength * 5.0
    if not leg.touched
        score += 40.0
    if leg.anchorSwept
        score -= 10.0
    score

weakestLegIndex(array<FibLeg> legs) =>
    int weakestIndex = 0
    if array.size(legs) > 1
        float weakestScore = legPreservationScore(array.get(legs, 0))
        for i = 1 to array.size(legs) - 1
            FibLeg candidate = array.get(legs, i)
            float candidateScore = legPreservationScore(candidate)
            if candidateScore < weakestScore
                weakestScore := candidateScore
                weakestIndex := i
    weakestIndex

enforceLegLimit(array<FibLeg> legs, int maximumLegs) =>
    while array.size(legs) > maximumLegs
        int removalIndex = 0
        if preserveUntouched
            removalIndex := weakestLegIndex(legs)
        array.remove(legs, removalIndex)

pushPivot(array<PivotPoint> pivotArray, float pivotPrice, int pivotBarValue, bool pivotIsHigh) =>
    bool duplicate = false
    if array.size(pivotArray) > 0
        PivotPoint latest = array.get(pivotArray, array.size(pivotArray) - 1)
        duplicate := latest.pivotBar == pivotBarValue and math.abs(latest.price - pivotPrice) <= syminfo.mintick
    if not duplicate
        PivotPoint newPivot = PivotPoint.new(pivotPrice, pivotBarValue, pivotIsHigh)
        array.push(pivotArray, newPivot)
    while array.size(pivotArray) > 20
        array.shift(pivotArray)

spawnLegs(array<FibLeg> legArray, array<PivotPoint> opposingPivots, float zeroPrice, int zeroBar, bool bullish, bool major, float minimumDistance, int maximumLegs) =>
    int created = 0
    int available = array.size(opposingPivots)
    int tests = math.min(maxPairs, available)
    if tests > 0
        for i = 0 to tests - 1
            int oppositeIndex = available - 1 - i
            PivotPoint opposite = array.get(opposingPivots, oppositeIndex)
            bool correctTime = opposite.pivotBar < zeroBar
            bool withinSpan = zeroBar - opposite.pivotBar <= maxLegBars
            bool correctDirection = false
            if bullish
                correctDirection := opposite.price < zeroPrice
            else
                correctDirection := opposite.price > zeroPrice
            float candidateDistance = math.abs(zeroPrice - opposite.price)
            bool significant = candidateDistance >= minimumDistance
            if correctTime and withinSpan and correctDirection and significant
                float strengthDenominator = math.max(minimumDistance, syminfo.mintick)
                float strength = candidateDistance / strengthDenominator
                FibLeg candidate = FibLeg.new(zeroPrice, opposite.price, zeroBar, opposite.pivotBar, bullish, major, false, false, 0, strength)
                if not legAlreadyExists(legArray, candidate)
                    array.push(legArray, candidate)
                    created += 1
    enforceLegLimit(legArray, maximumLegs)
    created

// ═════════════════════════════════════════════════════════════
// SWING STATE
// ═════════════════════════════════════════════════════════════

var float previousMajorHigh = na
var float previousMajorLow = na

var float structureHigh = na
var float structureLow = na

var bool structureHighBroken = false
var bool structureLowBroken = false

var float provisionalLowPrice = na
var int provisionalLowBar = na
var float runningHigh = na
var int runningHighBar = na

var float provisionalHighPrice = na
var int provisionalHighBar = na
var float runningLow = na
var int runningLowBar = na

// ═════════════════════════════════════════════════════════════
// MAJOR PIVOT HIGH
// ═════════════════════════════════════════════════════════════

if not na(majorPivotHigh)
    int pivotBarValue = bar_index - rightMajor

    spawnLegs(majorLegs, majorLows, majorPivotHigh, pivotBarValue, true, true, majorMinimumDistance, maxMajorLegs)
    pushPivot(majorHighs, majorPivotHigh, pivotBarValue, true)

    structureHigh := majorPivotHigh
    structureHighBroken := false

    provisionalHighPrice := majorPivotHigh
    provisionalHighBar := pivotBarValue

    runningLow := low[majorLowestOffset]
    runningLowBar := bar_index - majorLowestOffset

    if showStructureTags and enableFib
        string highTag = "H"
        if not na(previousMajorHigh)
            if majorPivotHigh > previousMajorHigh
                highTag := "HH"
            else
                highTag := "LH"
        label.new(pivotBarValue, majorPivotHigh, highTag, style = label.style_label_down, color = color.new(structureBackground, structureTransparency), textcolor = structureTextColor, size = structureLabelSize)

    previousMajorHigh := majorPivotHigh

// ═════════════════════════════════════════════════════════════
// MAJOR PIVOT LOW
// ═════════════════════════════════════════════════════════════

if not na(majorPivotLow)
    int pivotBarValue = bar_index - rightMajor

    spawnLegs(majorLegs, majorHighs, majorPivotLow, pivotBarValue, false, true, majorMinimumDistance, maxMajorLegs)
    pushPivot(majorLows, majorPivotLow, pivotBarValue, false)

    structureLow := majorPivotLow
    structureLowBroken := false

    provisionalLowPrice := majorPivotLow
    provisionalLowBar := pivotBarValue

    runningHigh := high[majorHighestOffset]
    runningHighBar := bar_index - majorHighestOffset

    if showStructureTags and enableFib
        string lowTag = "L"
        if not na(previousMajorLow)
            if majorPivotLow < previousMajorLow
                lowTag := "LL"
            else
                lowTag := "HL"
        label.new(pivotBarValue, majorPivotLow, lowTag, style = label.style_label_up, color = color.new(structureBackground, structureTransparency), textcolor = structureTextColor, size = structureLabelSize)

    previousMajorLow := majorPivotLow

if not na(runningHigh)
    if high > runningHigh
        runningHigh := high
        runningHighBar := bar_index

if not na(runningLow)
    if low < runningLow
        runningLow := low
        runningLowBar := bar_index

// ═════════════════════════════════════════════════════════════
// FORMING EXTREMES
// ═════════════════════════════════════════════════════════════
// Breaking the last major pivot low means a lower low is being made
// NOW. The pivot engine's LL tag arrives rightMajor bars later, so
// this fires immediately. It also marks the provisional leg dead —
// the render block drops it on the same bar.
// Follows the same wick/close rule chosen for leg invalidation.

var float flaggedLow = na
var float flaggedHigh = na

bool lowViolated = not na(provisionalLowPrice) and (invalidationMode == "Wick beyond origin" ? low < provisionalLowPrice : close < provisionalLowPrice)
bool highViolated = not na(provisionalHighPrice) and (invalidationMode == "Wick beyond origin" ? high > provisionalHighPrice : close > provisionalHighPrice)

// Fire once per pivot, not once per bar.
bool newLowForming = lowViolated and (na(flaggedLow) or flaggedLow != provisionalLowPrice)
bool newHighForming = highViolated and (na(flaggedHigh) or flaggedHigh != provisionalHighPrice)

if newLowForming
    flaggedLow := provisionalLowPrice
    if showFormingTags and enableFib
        label.new(bar_index, low, "LL forming", style = label.style_label_up, color = color.new(bearishBosColor, 30), textcolor = color.white, size = structureLabelSize)

if newHighForming
    flaggedHigh := provisionalHighPrice
    if showFormingTags and enableFib
        label.new(bar_index, high, "HH forming", style = label.style_label_down, color = color.new(bullishBosColor, 30), textcolor = color.white, size = structureLabelSize)

// ═════════════════════════════════════════════════════════════
// MINOR PIVOTS
// ═════════════════════════════════════════════════════════════

if not na(minorPivotHigh)
    int pivotBarValue = bar_index - rightMinor
    bool duplicatesMajorHigh = false
    if not na(majorPivotHigh)
        duplicatesMajorHigh := pivotBarValue == bar_index - rightMajor and math.abs(minorPivotHigh - majorPivotHigh) <= syminfo.mintick
    if not duplicatesMajorHigh
        spawnLegs(minorLegs, minorLows, minorPivotHigh, pivotBarValue, true, false, minorMinimumDistance, maxMinorLegs)
        pushPivot(minorHighs, minorPivotHigh, pivotBarValue, true)

if not na(minorPivotLow)
    int pivotBarValue = bar_index - rightMinor
    bool duplicatesMajorLow = false
    if not na(majorPivotLow)
        duplicatesMajorLow := pivotBarValue == bar_index - rightMajor and math.abs(minorPivotLow - majorPivotLow) <= syminfo.mintick
    if not duplicatesMajorLow
        spawnLegs(minorLegs, minorHighs, minorPivotLow, pivotBarValue, false, false, minorMinimumDistance, maxMinorLegs)
        pushPivot(minorLows, minorPivotLow, pivotBarValue, false)

// ═════════════════════════════════════════════════════════════
// BIAS ENGINE
// ═════════════════════════════════════════════════════════════

var int directionBias = 0
var int lastBreakBar = na

bool sweepUp = false

if not na(structureHigh)
    sweepUp := not structureHighBroken and high > structureHigh and close <= structureHigh

bool sweepDown = false

if not na(structureLow)
    sweepDown := not structureLowBroken and low < structureLow and close >= structureLow

bool brokeUp = false

if not na(structureHigh) and not structureHighBroken
    if breakConfirmation == "Close"
        brokeUp := close > structureHigh
    else
        brokeUp := high > structureHigh

bool brokeDown = false

if not na(structureLow) and not structureLowBroken
    if breakConfirmation == "Close"
        brokeDown := close < structureLow
    else
        brokeDown := low < structureLow

int resolvedBreak = 0

if brokeUp and not brokeDown
    resolvedBreak := 1
else if brokeDown and not brokeUp
    resolvedBreak := -1
else if brokeUp and brokeDown
    float candleDistance = math.max(high - low, syminfo.mintick)
    float closeLocation = (close - low) / candleDistance
    if closeLocation >= 0.65
        resolvedBreak := 1
    else if closeLocation <= 0.35
        resolvedBreak := -1

if resolvedBreak == 1
    bool isChoch = directionBias == -1
    directionBias := 1
    structureHighBroken := true
    lastBreakBar := bar_index
    if showBreakLabels and enableFib
        color labelColor = bullishBosColor
        if isChoch
            labelColor := chochColor
        string breakText = "BOS"
        if isChoch
            breakText := "CHoCH"
        label.new(bar_index, structureHigh, breakText, style = label.style_label_down, color = color.new(labelColor, 20), textcolor = color.white, size = structureLabelSize)

if resolvedBreak == -1
    bool isChoch = directionBias == 1
    directionBias := -1
    structureLowBroken := true
    lastBreakBar := bar_index
    if showBreakLabels and enableFib
        color labelColor = bearishBosColor
        if isChoch
            labelColor := chochColor
        string breakText = "BOS"
        if isChoch
            breakText := "CHoCH"
        label.new(bar_index, structureLow, breakText, style = label.style_label_up, color = color.new(labelColor, 20), textcolor = color.white, size = structureLabelSize)

if showSweepLabels and enableFib and sweepUp
    label.new(bar_index, high, "High sweep", style = label.style_label_down, color = color.new(sweepColor, 25), textcolor = color.white, size = structureLabelSize)

if showSweepLabels and enableFib and sweepDown
    label.new(bar_index, low, "Low sweep", style = label.style_label_up, color = color.new(sweepColor, 25), textcolor = color.white, size = structureLabelSize)

bool isConsolidating = false

if not na(lastBreakBar)
    isConsolidating := bar_index - lastBreakBar > consolidationBars

string biasText = "FORMING"
color biasColor = color.silver

if isConsolidating
    biasText := "CONSOLIDATING"
    biasColor := color.gray
else
    if directionBias == 1
        biasText := "BULLISH"
        biasColor := color.green
    else if directionBias == -1
        biasText := "BEARISH"
        biasColor := color.red

// ═════════════════════════════════════════════════════════════
// LEG MAINTENANCE
// ═════════════════════════════════════════════════════════════

maintainLegs(array<FibLeg> legArray) =>
    int index = 0
    while index < array.size(legArray)
        FibLeg leg = array.get(legArray, index)
        bool invalidated = legInvalidated(leg)
        bool expired = false
        if useLegExpiry and not leg.touched
            expired := bar_index - leg.zeroBar > legLifeBars
        bool enteredNow = zoneTouchedNow(leg)
        if enteredNow and not leg.touched
            leg.touched := true
            leg.firstTouchBar := bar_index
        bool sweptNow = false
        if leg.bullish
            sweptNow := high > leg.zeroPrice
        else
            sweptNow := low < leg.zeroPrice
        if sweptNow
            leg.anchorSwept := true
        array.set(legArray, index, leg)
        bool deleteForTouch = false
        if removeAfterTouch and leg.touched
            deleteForTouch := leg.firstTouchBar < bar_index
        bool deleteForMidpoint = false
        if removeAfterMidpoint and leg.touched
            deleteForMidpoint := crossedMidpoint(leg)
        bool shouldDelete = invalidated or expired or deleteForTouch or deleteForMidpoint
        if shouldDelete
            array.remove(legArray, index)
        index := shouldDelete ? index : index + 1

maintainLegs(majorLegs)
maintainLegs(minorLegs)

enforceLegLimit(majorLegs, maxMajorLegs)
enforceLegLimit(minorLegs, maxMinorLegs)

// ═════════════════════════════════════════════════════════════
// ACTIVE LEG SCORING
// ═════════════════════════════════════════════════════════════

activeLegScore(FibLeg leg, bool provisional) =>
    float topPrice = zoneTop(leg)
    float bottomPrice = zoneBottom(leg)
    float distanceFromZone = 0.0
    if close > topPrice
        distanceFromZone := close - topPrice
    else if close < bottomPrice
        distanceFromZone := bottomPrice - close
    float denominator = math.max(atrValue, syminfo.mintick)
    float normalizedZoneDistance = distanceFromZone / denominator
    float normalizedLegDistance = legDistance(leg) / denominator
    float score = 0.0
    if zoneTouchedNow(leg)
        score += 500.0
    if leg.major
        score += 150.0
    if not leg.touched
        score += 75.0
    score += normalizedLegDistance * 15.0
    if provisional
        score -= 15.0
    if leg.anchorSwept
        score -= 10.0
    score -= normalizedZoneDistance * 20.0
    score

// ═════════════════════════════════════════════════════════════
// OBJECT HELPERS
// ═════════════════════════════════════════════════════════════

hideAllObjects() =>
    for i = 0 to BOX_POOL_SIZE - 1
        box currentBox = array.get(boxPool, i)
        box.set_bgcolor(currentBox, hiddenColor)
        box.set_border_color(currentBox, hiddenColor)
        box.set_border_width(currentBox, 0)
    for i = 0 to LINE_POOL_SIZE - 1
        line currentLine = array.get(linePool, i)
        line.set_color(currentLine, hiddenColor)
    for i = 0 to LABEL_POOL_SIZE - 1
        label currentLabel = array.get(labelPool, i)
        label.set_text(currentLabel, "")
        label.set_color(currentLabel, hiddenColor)
        label.set_textcolor(currentLabel, hiddenColor)

getZoneColor(FibLeg leg, bool provisional) =>
    color result = color.gray
    if provisional
        if leg.bullish
            result := provisionalBullColor
        else
            result := provisionalBearColor
    else if leg.major
        if leg.bullish
            result := majorBullZoneColor
        else
            result := majorBearZoneColor
    else
        if leg.bullish
            result := minorBullZoneColor
        else
            result := minorBearZoneColor
    result

placeZone(int slot, FibLeg leg, bool provisional, bool active) =>
    if slot < BOX_POOL_SIZE and showZoneBoxes
        box currentBox = array.get(boxPool, slot)
        color baseColor = getZoneColor(leg, provisional)
        int baseTransparency = confirmedZoneTransparency
        if provisional
            baseTransparency := provisionalZoneTransparency
        int finalTransparency = baseTransparency
        if leg.touched
            finalTransparency += touchedZoneFade
        finalTransparency := math.min(finalTransparency, 100)
        color currentBorderColor = hiddenColor
        int currentBorderWidth = 0
        if not active and showInactiveBorders
            currentBorderColor := color.new(baseColor, inactiveBorderTransparency)
            currentBorderWidth := 1
        box.set_lefttop(currentBox, drawBar(leg.zeroBar), zoneTop(leg))
        box.set_rightbottom(currentBox, bar_index + zoneExtension, zoneBottom(leg))
        box.set_bgcolor(currentBox, color.new(baseColor, finalTransparency))
        box.set_border_color(currentBox, currentBorderColor)
        box.set_border_width(currentBox, currentBorderWidth)

formatFibLabel(string ratioText, float priceValue) =>
    string result = ratioText
    if showFibPrices
        result := ratioText + "  " + str.tostring(priceValue, format.mintick)
    result

placeFibLabel(int labelIndex, float priceValue, string textValue) =>
    if labelIndex < LABEL_POOL_SIZE
        label currentLabel = array.get(labelPool, labelIndex)
        label.set_xy(currentLabel, bar_index + fibLabelOffset, priceValue)
        label.set_text(currentLabel, textValue)
        label.set_style(currentLabel, label.style_label_left)
        label.set_size(currentLabel, fibLabelSize)
        label.set_color(currentLabel, color.new(fibLabelBackground, fibLabelTransparency))
        label.set_textcolor(currentLabel, fibLabelTextColor)

placeActiveLevels(FibLeg leg, bool provisional) =>
    array<float> ratios = array.from(0.50, 0.62, 0.705, 0.786, 0.85)
    array<string> ratioNames = array.from(".50", ".62", ".705", ".786", ".85")
    array<color> levelColors = array.from(color50, color62, color705, color786, color85)

    activeStyle = confirmedLineStyle
    if provisional
        activeStyle := provisionalLineStyle

    int activeTransparency = 0
    if leg.anchorSwept
        activeTransparency := sweptLineTransparency

    for i = 0 to 4
        line currentLine = array.get(linePool, i)
        float ratioValue = array.get(ratios, i)
        float priceValue = fibPrice(leg, ratioValue)
        color levelColor = array.get(levelColors, i)
        line.set_xy1(currentLine, drawBar(leg.zeroBar), priceValue)
        line.set_xy2(currentLine, bar_index + lineExtension, priceValue)
        line.set_color(currentLine, color.new(levelColor, activeTransparency))
        line.set_style(currentLine, activeStyle)
        line.set_width(currentLine, fibLineWidth)
        if showFibLabels
            string ratioName = array.get(ratioNames, i)
            placeFibLabel(i, priceValue, formatFibLabel(ratioName, priceValue))

    line zeroLine = array.get(linePool, 5)
    line hundredLine = array.get(linePool, 6)

    if showAnchorLines
        line.set_xy1(zeroLine, drawBar(leg.zeroBar), leg.zeroPrice)
        line.set_xy2(zeroLine, bar_index + lineExtension, leg.zeroPrice)
        line.set_color(zeroLine, color.new(zeroAnchorColor, activeTransparency))
        line.set_style(zeroLine, activeStyle)
        line.set_width(zeroLine, anchorLineWidth)
        line.set_xy1(hundredLine, drawBar(leg.originBar), leg.originPrice)
        line.set_xy2(hundredLine, bar_index + lineExtension, leg.originPrice)
        line.set_color(hundredLine, color.new(hundredAnchorColor, activeTransparency))
        line.set_style(hundredLine, activeStyle)
        line.set_width(hundredLine, anchorLineWidth)
        if showFibLabels and showAnchorLabels
            placeFibLabel(5, leg.zeroPrice, formatFibLabel("0", leg.zeroPrice))
            placeFibLabel(6, leg.originPrice, formatFibLabel("1.00", leg.originPrice))

// ═════════════════════════════════════════════════════════════
// FIB RENDERING
// ═════════════════════════════════════════════════════════════

// Hiding runs unconditionally so switching the module off clears
// the pooled objects instead of freezing them on screen.

if barstate.islast
    hideAllObjects()

if barstate.islast and enableFib
    array<FibLeg> candidates = array.new<FibLeg>()
    array<bool> provisionalFlags = array.new<bool>()

    if array.size(majorLegs) > 0
        for i = 0 to array.size(majorLegs) - 1
            array.push(candidates, array.get(majorLegs, i))
            array.push(provisionalFlags, false)

    if showProvisionalLegs and not na(provisionalLowPrice) and not na(runningHigh)
        float provisionalDistance = runningHigh - provisionalLowPrice
        int provisionalWidth = runningHighBar - provisionalLowBar
        bool validBullishProvisional = runningHigh > provisionalLowPrice and provisionalDistance >= majorMinimumDistance and provisionalWidth >= 0 and provisionalWidth <= maxLegBars
        if validBullishProvisional
            float denominator = math.max(majorMinimumDistance, syminfo.mintick)
            FibLeg provisionalBullLeg = FibLeg.new(runningHigh, provisionalLowPrice, runningHighBar, provisionalLowBar, true, true, false, false, 0, provisionalDistance / denominator)
            // Option A: origin violated = dead on the spot. Provisional
            // legs never enter the leg array, so maintainLegs() cannot
            // reach them — the test has to happen here or not at all.
            if not legInvalidated(provisionalBullLeg)
                array.push(candidates, provisionalBullLeg)
                array.push(provisionalFlags, true)

    if showProvisionalLegs and not na(provisionalHighPrice) and not na(runningLow)
        float provisionalDistance = provisionalHighPrice - runningLow
        int provisionalWidth = runningLowBar - provisionalHighBar
        bool validBearishProvisional = runningLow < provisionalHighPrice and provisionalDistance >= majorMinimumDistance and provisionalWidth >= 0 and provisionalWidth <= maxLegBars
        if validBearishProvisional
            float denominator = math.max(majorMinimumDistance, syminfo.mintick)
            FibLeg provisionalBearLeg = FibLeg.new(runningLow, provisionalHighPrice, runningLowBar, provisionalHighBar, false, true, false, false, 0, provisionalDistance / denominator)
            if not legInvalidated(provisionalBearLeg)
                array.push(candidates, provisionalBearLeg)
                array.push(provisionalFlags, true)

    int activeIndex = -1
    float bestScore = -100000000000000000000.0

    if array.size(candidates) > 0
        for i = 0 to array.size(candidates) - 1
            FibLeg candidate = array.get(candidates, i)
            bool provisional = array.get(provisionalFlags, i)
            float candidateScore = activeLegScore(candidate, provisional)
            if candidateScore > bestScore
                bestScore := candidateScore
                activeIndex := i

    int boxSlot = 0

    if array.size(candidates) > 0
        for i = 0 to array.size(candidates) - 1
            FibLeg candidate = array.get(candidates, i)
            bool provisional = array.get(provisionalFlags, i)
            bool active = i == activeIndex
            placeZone(boxSlot, candidate, provisional, active)
            boxSlot += 1
            if active
                placeActiveLevels(candidate, provisional)

    if showMinorLegs and array.size(minorLegs) > 0
        for i = 0 to array.size(minorLegs) - 1
            FibLeg minorLeg = array.get(minorLegs, i)
            placeZone(boxSlot, minorLeg, false, false)
            boxSlot += 1

// ═════════════════════════════════════════════════════════════
// FIB BIAS PANEL
// ═════════════════════════════════════════════════════════════

var table biasPanel = table.new(position.top_right, 1, 3, border_width = 1)

if barstate.islast
    if showBiasPanel and enableFib
        table.cell(biasPanel, 0, 0, biasText, text_color = color.white, bgcolor = color.new(biasColor, 20), text_size = size.small)

        string sweepText = "NO ACTIVE SWEEP"
        color sweepTextColor = color.gray
        if sweepUp
            sweepText := "HIGH SWEEP"
            sweepTextColor := color.white
        else if sweepDown
            sweepText := "LOW SWEEP"
            sweepTextColor := color.white

        table.cell(biasPanel, 0, 1, sweepText, text_color = sweepTextColor, bgcolor = color.new(color.black, 85), text_size = size.tiny)

        string countText = str.tostring(array.size(majorLegs)) + " major / " + str.tostring(array.size(minorLegs)) + " minor"
        table.cell(biasPanel, 0, 2, countText, text_color = color.gray, bgcolor = color.new(color.black, 85), text_size = size.tiny)
    else
        table.clear(biasPanel, 0, 0, 0, 2)

// ═════════════════════════════════════════════════════════════
// SUPPLY / DEMAND MODULE
// ═════════════════════════════════════════════════════════════

sdSizeOpt = sdTxtSize == "Tiny" ? size.tiny : sdTxtSize == "Normal" ? size.normal : size.small
sdAlignOpt = sdTxtAlign == "Left" ? text.align_left : sdTxtAlign == "Right" ? text.align_right : text.align_center

// Auto timeframe label
sdTfTxt = timeframe.isminutes ? (timeframe.multiplier >= 60 and timeframe.multiplier % 60 == 0 ? str.tostring(timeframe.multiplier / 60) + " Hour" : str.tostring(timeframe.multiplier) + " Min") : timeframe.isdaily ? "Daily" : timeframe.period

// ─── Detection logic ───
sdAtr = ta.atr(sdAtrLen)
sdIsGreen = close > open
sdIsRed = close < open

sdBaseHigh = high[1]
sdBaseLow = low[1]

sdBrokeUp = sdBreakMode == "Close" ? close > sdBaseHigh : high > sdBaseHigh
sdBrokeDn = sdBreakMode == "Close" ? close < sdBaseLow : low < sdBaseLow

sdOppUpOk = not sdRequireOpp or sdIsGreen
sdOppDnOk = not sdRequireOpp or sdIsRed

sdBodySz = math.abs(close - open)
sdSizeOk = not sdUseSize or sdBodySz >= nz(sdAtr[1]) * sdSizeMult

newDemand = sdIsRed[1] and sdBrokeUp and sdOppUpOk and sdSizeOk
newSupply = sdIsGreen[1] and sdBrokeDn and sdOppDnOk and sdSizeOk

// ─── Zone storage ───
var array<box> demandZones = array.new<box>()
var array<box> supplyZones = array.new<box>()

if barstate.isconfirmed and enableSD
    if newDemand
        b = box.new(bar_index - 1, sdBaseHigh, bar_index + sdExtend, sdBaseLow, border_color = sdDemBrd, border_width = 1, bgcolor = sdDemCol, text = sdShowTxt ? sdTfTxt + " Demand" : "", text_color = sdTxtCol, text_size = sdSizeOpt, text_halign = sdAlignOpt, text_valign = text.align_center)
        array.push(demandZones, b)
        if array.size(demandZones) > sdMaxZones
            box.delete(array.shift(demandZones))
    if newSupply
        b = box.new(bar_index - 1, sdBaseHigh, bar_index + sdExtend, sdBaseLow, border_color = sdSupBrd, border_width = 1, bgcolor = sdSupCol, text = sdShowTxt ? sdTfTxt + " Supply" : "", text_color = sdTxtCol, text_size = sdSizeOpt, text_halign = sdAlignOpt, text_valign = text.align_center)
        array.push(supplyZones, b)
        if array.size(supplyZones) > sdMaxZones
            box.delete(array.shift(supplyZones))

// ─── Extend live zones, delete broken ones ───
if array.size(demandZones) > 0
    for i = array.size(demandZones) - 1 to 0
        b = array.get(demandZones, i)
        btm = box.get_bottom(b)
        dead = sdInvMode == "Full body" ? (close < btm and open < btm) : close < btm
        if dead
            box.delete(b)
            array.remove(demandZones, i)
        else
            box.set_right(b, bar_index + sdExtend)

if array.size(supplyZones) > 0
    for i = array.size(supplyZones) - 1 to 0
        b = array.get(supplyZones, i)
        top = box.get_top(b)
        dead = sdInvMode == "Full body" ? (close > top and open > top) : close > top
        if dead
            box.delete(b)
            array.remove(supplyZones, i)
        else
            box.set_right(b, bar_index + sdExtend)

// ─── S/D alerts ───
alertcondition(newDemand, "New demand zone", "New demand zone formed")
alertcondition(newSupply, "New supply zone", "New supply zone formed")

// ═════════════════════════════════════════════════════════════
// TOP DOWN ANALYSIS MODULE
// ═════════════════════════════════════════════════════════════


// ------------------------- INPUTS ----------------------------
grpTF   = "08 — TDA Ladder"
tf1     = input.timeframe("D",   "TF 1", group = grpTF)
tf2     = input.timeframe("240", "TF 2", group = grpTF)
tf3     = input.timeframe("60",  "TF 3", group = grpTF)
tf4     = input.timeframe("15",  "TF 4", group = grpTF)

w1      = input.int(4, "Weight TF1", minval = 0, maxval = 10, group = grpTF)
w2      = input.int(3, "Weight TF2", minval = 0, maxval = 10, group = grpTF)
w3      = input.int(2, "Weight TF3", minval = 0, maxval = 10, group = grpTF)
w4      = input.int(1, "Weight TF4", minval = 0, maxval = 10, group = grpTF)

grpStr  = "09 — TDA Structure"
// Per-TF pivot length. Higher TFs have far fewer bars, so the same
// length there reaches much further back in time and goes stale.
pv1     = input.int(3, "Pivot length TF1", minval = 2, group = grpStr,
     tooltip = "Daily: keep this SHORT (2-3). At 5 the last swing can be weeks old and the bias freezes.")
pv2     = input.int(4, "Pivot length TF2", minval = 2, group = grpStr)
pv3     = input.int(5, "Pivot length TF3", minval = 2, group = grpStr)
pv4     = input.int(5, "Pivot length TF4", minval = 2, group = grpStr)

unresThr = input.float(0.70, "Unresolved threshold", minval = 0.5, maxval = 0.95, step = 0.05,
     group = grpStr,
     tooltip = "If price retraces this far through the leg AGAINST the latched bias without a new break, the bias is treated as unresolved: it prints '-' and scores 0. Lower = stricter.")

eqBand  = input.float(0.05, "Equilibrium band (± of range)", minval = 0.0, maxval = 0.25,
     step = 0.01, group = grpStr,
     tooltip = "0.05 means 45%-55% of the leg counts as equilibrium.")

grpSD   = "10 — TDA Zone Booster"
useSD   = input.bool(true,  "Use S/D zone as grade booster", group = grpSD)
tdaAtrLen  = input.int(14,     "ATR length",     minval = 1,   group = grpSD)
tdaAtrMult = input.float(1.0,  "ATR multiple for displacement", minval = 0.1, step = 0.1, group = grpSD)

grpScr  = "11 — TDA Scoring"
adjW    = input.float(0.5, "Adjacent-TF agreement weight", minval = 0.0, maxval = 1.0, step = 0.1,
     group = grpScr,
     tooltip = "Neighbouring timeframes agreeing (4H+1H) is a real condition. Scattered agreement (D+1H with 4H against) is not. 0 = off.")

grpLvl  = "12 — TDA Levels"
shSwing = input.bool(true, "Show untouched HTF swing high/low", group = grpLvl)
shPD    = input.bool(true, "Show previous DAY high/low",        group = grpLvl)
shPW    = input.bool(true, "Show previous WEEK high/low",       group = grpLvl)
lvlLen  = input.int(60, "Line length (bars back)", minval = 5,  group = grpLvl)
lblOff  = input.int(12, "Label offset (bars right)", minval = 0, group = grpLvl)
gapMult = input.float(0.5, "Merge distance (x ATR)", minval = 0.0, step = 0.1, group = grpLvl,
     tooltip = "Levels closer together than this share a single line and label: '4H swing high / PDH'.")
lineSty = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpLvl)

c1      = input.color(color.new(color.black,   0), "TF1 color", group = grpLvl, inline = "c1")
c2      = input.color(color.new(color.orange,  0), "TF2 color", group = grpLvl, inline = "c1")
c3      = input.color(color.new(color.blue,    0), "TF3 color", group = grpLvl, inline = "c2")
c4      = input.color(color.new(color.gray,    0), "TF4 color", group = grpLvl, inline = "c2")
cPD     = input.color(color.new(color.olive,   0), "Prev day",  group = grpLvl, inline = "c3")
cPW     = input.color(color.new(color.purple,  0), "Prev week", group = grpLvl, inline = "c3")

grpSess  = "13 — Session Opens"
sessTZ   = input.string("America/New_York", "Timezone", group = grpSess)
sessHrs  = input.int(12, "Extend each line (hours)", minval = 1, maxval = 48, group = grpSess)
sessKeep = input.int(2,  "Past sessions to keep", minval = 1, maxval = 10, group = grpSess,
     tooltip = "How many previous occurrences of each line stay on the chart.")
sessStyI = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpSess)

on10a = input.bool(true, "10AM open", group = grpSess, inline = "s1")
c10a  = input.color(color.new(color.red, 0), "", group = grpSess, inline = "s1")
w10a  = input.int(2, "", minval = 1, maxval = 5, group = grpSess, inline = "s1")

on10p = input.bool(true, "10PM open", group = grpSess, inline = "s2")
c10p  = input.color(color.new(color.blue, 0), "", group = grpSess, inline = "s2")
w10p  = input.int(2, "", minval = 1, maxval = 5, group = grpSess, inline = "s2")

onMid = input.bool(true, "Midnight open", group = grpSess, inline = "s3")
cMid  = input.color(color.new(color.teal, 0), "", group = grpSess, inline = "s3")
wMid  = input.int(1, "", minval = 1, maxval = 5, group = grpSess, inline = "s3")

grpGate = "14 — Day Gate"
showGate = input.bool(true, "Show day gate row", group = grpGate)

grpTbl  = "15 — TDA Dashboard"
tblPos  = input.string("Bottom Right", "Table position",
     options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = grpTbl)
tblSize = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal"], group = grpTbl)
tblTxt  = input.color(color.new(color.black, 0), "Table text color",   group = grpTbl)
tblBg   = input.color(color.new(color.white, 0), "Table background",   group = grpTbl)
colorCd = input.bool(false, "Color-code Bias / Grade text", group = grpTbl,
     tooltip = "Off = everything prints in the table text color. On = green/red bias and A/B/C grade colors.")
showPct = input.bool(true, "Show leg % in Loc column", group = grpTbl)

// --------------------- FRIENDLY TF NAMES ---------------------
f_tfName(string _tf) =>
    string t = str.upper(_tf)
    string r = t
    if t == "D" or t == "1D"
        r := "D"
    else if t == "W" or t == "1W"
        r := "W"
    else if t == "M" or t == "1M"
        r := "M"
    else
        float mins = str.tonumber(t)
        if not na(mins)
            r := mins >= 60 and math.round(mins) % 60 == 0 ?
                 str.tostring(mins / 60, "#") + "H" : str.tostring(mins, "#") + "M"
    r

n1 = f_tfName(tf1)
n2 = f_tfName(tf2)
n3 = f_tfName(tf3)
n4 = f_tfName(tf4)

// --------------------- PER-TF STATE ENGINE -------------------
// Returns: bias (-1/0/1), position in leg (0-1), inDemand, inSupply,
//          last major swing high, last major swing low
f_state(int _pvt, float _atrMult, int _atrLen, bool _useSD, float _unres) =>
    float ph = ta.pivothigh(high, _pvt, _pvt)
    float pl = ta.pivotlow(low,  _pvt, _pvt)

    var float lastPH = na
    var float lastPL = na
    var int   bias   = 0

    lastPH := na(ph) ? lastPH : ph
    lastPL := na(pl) ? lastPL : pl

    // BOS / CHoCH: a CLOSE through a major swing flips bias
    if not na(lastPH) and close > lastPH
        bias := 1
    if not na(lastPL) and close < lastPL
        bias := -1

    // ---- Leg re-anchor ----
    // After a break, price sits beyond the swing that defined the leg.
    // Extend the leg to the running extreme so location stays 0-100%
    // and reflects the leg price is ACTUALLY trading in.
    float hiSince = ta.highest(high, _pvt + 1)
    float loSince = ta.lowest(low,  _pvt + 1)

    var float runHi = na
    var float runLo = na
    if not na(pl)
        runHi := hiSince          // new swing low: start tracking the high above it
    if not na(ph)
        runLo := loSince          // new swing high: start tracking the low below it
    runHi := na(runHi) ? high : math.max(runHi, high)
    runLo := na(runLo) ? low  : math.min(runLo, low)

    float legHi = na(lastPH) ? na : na(runHi) ? lastPH : math.max(lastPH, runHi)
    float legLo = na(lastPL) ? na : na(runLo) ? lastPL : math.min(lastPL, runLo)

    float rng = na(legHi) or na(legLo) ? na : legHi - legLo
    float pos = na(rng) or rng <= 0 ? 0.5 : (close - legLo) / rng
    pos := math.max(0.0, math.min(1.0, pos))

    // ---- Supply / Demand (single base candle + explosive move) ----
    float atrv = ta.atr(_atrLen)
    bool expUp = close > open and (close - open) > atrv * _atrMult
    bool expDn = open  > close and (open - close) > atrv * _atrMult

    var float dTop = na
    var float dBot = na
    var float sTop = na
    var float sBot = na

    // demand: last RED candle before an explosive UP move that breaks its high
    if expUp and close[1] < open[1] and close > high[1]
        dTop := high[1]
        dBot := low[1]
    // supply: last GREEN candle before an explosive DOWN move that breaks its low
    if expDn and close[1] > open[1] and close < low[1]
        sTop := high[1]
        sBot := low[1]

    // invalidation: full body close through the zone
    if not na(dBot) and close < dBot
        dTop := na
        dBot := na
    if not na(sTop) and close > sTop
        sTop := na
        sBot := na

    bool inD = _useSD and not na(dBot) and close <= dTop and close >= dBot
    bool inS = _useSD and not na(sTop) and close <= sTop and close >= sBot

    // ---- Unresolved bias ----
    // A bias latches until an opposite break. If price has travelled deep
    // back through the leg against it and NOT broken the other way, the
    // latch is stale - it describes an old move, not the current one.
    int effBias = bias
    if bias == 1 and pos < 1.0 - _unres
        effBias := 0
    if bias == -1 and pos > _unres
        effBias := 0

    [effBias, pos, inD ? 1 : 0, inS ? 1 : 0, lastPH, lastPL, na(rng) ? 0.0 : rng]

// NOTE ON REPAINTING: these read the *forming* HTF bar, so a row can
// change until that HTF bar closes. Matches the provisional/confirmed
// handling in the Fib + Structure script.
[b1, p1, d1, s1, h1, l1, r1] = request.security(syminfo.tickerid, tf1, f_state(pv1, tdaAtrMult, tdaAtrLen, useSD, unresThr))
[b2, p2, d2, s2, h2, l2, r2] = request.security(syminfo.tickerid, tf2, f_state(pv2, tdaAtrMult, tdaAtrLen, useSD, unresThr))
[b3, p3, d3, s3, h3, l3, r3] = request.security(syminfo.tickerid, tf3, f_state(pv3, tdaAtrMult, tdaAtrLen, useSD, unresThr))
[b4, p4, d4, s4, h4, l4, r4] = request.security(syminfo.tickerid, tf4, f_state(pv4, tdaAtrMult, tdaAtrLen, useSD, unresThr))

// --------------------- DIRECTION SCORE -----------------------
int   wTot  = w1 + w2 + w3 + w4
float rawSc = b1 * w1 + b2 * w2 + b3 * w3 + b4 * w4

// Adjacent agreement: neighbouring timeframes pointing the same way is
// a stronger statement than the same count of scattered agreement.
float pairSc = 0.0
if b1 != 0 and b1 == b2
    pairSc += b1 * (w1 + w2) * adjW
if b2 != 0 and b2 == b3
    pairSc += b2 * (w2 + w3) * adjW
if b3 != 0 and b3 == b4
    pairSc += b3 * (w3 + w4) * adjW

float maxPair = ((w1 + w2) + (w2 + w3) + (w3 + w4)) * adjW
float denom   = wTot + maxPair
float score   = denom == 0 ? 0.0 : (rawSc + pairSc) / denom * 100.0

string align = math.abs(score) >= 70 ? (score > 0 ? "ALIGNED LONG" : "ALIGNED SHORT") :
               math.abs(score) >= 35 ? (score > 0 ? "LEANING LONG" : "LEANING SHORT") : "CONFLICTED"
color alignCol = math.abs(score) >= 70 ? (score > 0 ? color.lime : color.red) :
                 math.abs(score) >= 35 ? color.orange : color.gray

// Shape string — the net score alone hides which TFs disagree
f_arrow(int _b) => _b == 1 ? "▲" : _b == -1 ? "▼" : "•"
string shape = n1 + f_arrow(b1) + "  " + n2 + f_arrow(b2) + "  " + n3 + f_arrow(b3) + "  " + n4 + f_arrow(b4)

// ---------------------- SESSION OPENS ------------------------
sessSty = sessStyI == "Dashed" ? line.style_dashed : sessStyI == "Dotted" ? line.style_dotted : line.style_solid

// First bar at or after the target minute-of-day, reset each NY day.
// Using >= rather than == so an odd chart timeframe can't step over
// the exact minute and skip the session entirely.
f_sessOpen(int _tmin) =>
    var float px   = na
    var int   tx   = na
    var bool  done = false
    int  mins   = hour(time, sessTZ) * 60 + minute(time, sessTZ)
    bool newDay = na(time[1]) ? true : dayofmonth(time, sessTZ) != dayofmonth(time[1], sessTZ)
    bool fired  = false
    if newDay
        done := false
    if not done and mins >= _tmin
        px    := open
        tx    := time
        done  := true
        fired := true
    [px, tx, fired]

f_drawSess(bool _fired, float _px, int _tx, bool _on, color _col, int _w, string _txt) =>
    var line[]  L = array.new_line()
    var label[] B = array.new_label()
    if _fired and _on and not na(_px)
        int t2 = _tx + sessHrs * 3600000
        line ln = line.new(_tx, _px, t2, _px, xloc = xloc.bar_time,
             color = _col, width = _w, style = sessSty)
        label lb = label.new(t2, _px, _txt, xloc = xloc.bar_time,
             style = label.style_label_left, color = color.new(color.black, 100),
             textcolor = _col, size = size.small)
        array.push(L, ln)
        array.push(B, lb)
        while array.size(L) > sessKeep
            line.delete(array.shift(L))
            label.delete(array.shift(B))

[a10p, a10t, a10f] = f_sessOpen(600)    // 10:00
[p10p, p10t, p10f] = f_sessOpen(1320)   // 22:00
[mdp,  mdt,  mdf ] = f_sessOpen(0)      // 00:00

f_drawSess(a10f, a10p, a10t, on10a and enableSess, c10a, w10a, "10AM open")
f_drawSess(p10f, p10p, p10t, on10p and enableSess, c10p, w10p, "10PM open")
f_drawSess(mdf,  mdp,  mdt,  onMid and enableSess, cMid, wMid, "Midnight open")

// ------------------------- DAY GATE --------------------------
// Green requires agreement between both references. Price above one
// and below the other is genuinely undecided, so it says so.
float dOpen = request.security(syminfo.tickerid, "D", open)
float pdC   = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

bool gGreen = close > dOpen and close > pdC
bool gRed   = close < dOpen and close < pdC

string gateTxt = gGreen ? "DAY GREEN - longs only" :
                 gRed   ? "DAY RED - shorts only"  : "DAY MIXED - no gate"
string gateDlt = "  (open " + str.tostring(close - dOpen, "+#;-#") +
                 "  /  pdc " + str.tostring(close - pdC, "+#;-#") + ")"

// ------------------------- GRADING ---------------------------
// Structure = direction.  Location = permission.
f_grade(int _bias, float _pos, int _inD, int _inS, float _band) =>
    float loEq = 0.5 - _band
    float hiEq = 0.5 + _band
    string g = "-"
    if _bias == 1
        g := _pos < loEq ? "A" : _pos > hiEq ? "C" : "B"
        if _inD == 1
            g := g == "C" ? "B" : "A"
    else if _bias == -1
        g := _pos > hiEq ? "A" : _pos < loEq ? "C" : "B"
        if _inS == 1
            g := g == "C" ? "B" : "A"
    g

f_locTxt(float _pos, float _band) =>
    string base = _pos < 0.5 - _band ? "Disc" : _pos > 0.5 + _band ? "Prem" : "Eq"
    showPct ? base + " " + str.tostring(_pos * 100, "#") + "%" : base

f_biasTxt(int _b) => _b == 1 ? "Bull" : _b == -1 ? "Bear" : "-"
f_biasCol(int _b) => not colorCd ? tblTxt : _b == 1 ? color.lime : _b == -1 ? color.red : color.gray
f_gradeCol(string _g) => not colorCd ? tblTxt : _g == "A" ? color.lime : _g == "B" ? color.orange : _g == "C" ? color.red : color.gray

// ------------------------- DASHBOARD -------------------------
var table tbl = table.new(
     tblPos == "Top Right"    ? position.top_right :
     tblPos == "Middle Right" ? position.middle_right :
     tblPos == "Bottom Right" ? position.bottom_right :
     tblPos == "Top Left"     ? position.top_left : position.bottom_left,
     5, 8, border_width = 1, frame_width = 1,
     bgcolor = tblBg, frame_color = tblTxt, border_color = color.new(color.gray, 60))

sz = tblSize == "Tiny" ? size.tiny : tblSize == "Normal" ? size.normal : size.small

f_row(int r, string tfName, int b, float p, int inD, int inS, float leg) =>
    string g = f_grade(b, p, inD, inS, eqBand)
    table.cell(tbl, 0, r, tfName, text_color = tblTxt, text_size = sz)
    table.cell(tbl, 1, r, f_biasTxt(b), text_color = f_biasCol(b), text_size = sz)
    table.cell(tbl, 2, r, b == 0 ? "-" : f_locTxt(p, eqBand), text_color = tblTxt, text_size = sz)
    table.cell(tbl, 3, r, g, text_color = f_gradeCol(g), text_size = sz)
    table.cell(tbl, 4, r, str.tostring(leg, "#") + "pt", text_color = tblTxt, text_size = sz)

if barstate.islast and enableTDA
    if showGate
        table.cell(tbl, 0, 0, gateTxt + gateDlt, text_color = tblTxt, text_size = sz)
        table.merge_cells(tbl, 0, 0, 4, 0)

    table.cell(tbl, 0, 1, "TF",    text_color = tblTxt, text_size = sz)
    table.cell(tbl, 1, 1, "Bias",  text_color = tblTxt, text_size = sz)
    table.cell(tbl, 2, 1, "Loc",   text_color = tblTxt, text_size = sz)
    table.cell(tbl, 3, 1, "Grade", text_color = tblTxt, text_size = sz)
    table.cell(tbl, 4, 1, "Leg",   text_color = tblTxt, text_size = sz)

    f_row(2, n1, b1, p1, d1, s1, r1)
    f_row(3, n2, b2, p2, d2, s2, r2)
    f_row(4, n3, b3, p3, d3, s3, r3)
    f_row(5, n4, b4, p4, d4, s4, r4)

    color rowCol = colorCd ? alignCol : tblTxt
    table.cell(tbl, 0, 6, str.tostring(score, "#") + "%", text_color = rowCol, text_size = sz)
    table.cell(tbl, 1, 6, align, text_color = rowCol, text_size = sz)
    table.merge_cells(tbl, 1, 6, 4, 6)

    table.cell(tbl, 0, 7, shape, text_color = tblTxt, text_size = sz)
    table.merge_cells(tbl, 0, 7, 4, 7)

// -------------------- LEVELS ON THE CHART --------------------
styleOf = lineSty == "Dashed" ? line.style_dashed : lineSty == "Dotted" ? line.style_dotted : line.style_solid

var line[]  LN = array.new_line()
var label[] LB = array.new_label()

float gapPts = ta.atr(14) * gapMult

// Collect a level. If one is already registered within `gap` points,
// fold this label into it rather than drawing a second line on top.
// Merging beats staggering: label width is pixels, bar width is zoom.
f_push(float[] _p, string[] _t, color[] _c, int[] _w,
       float price, string txt, color col, int width, float gap) =>
    if not na(price)
        int hit = -1
        if array.size(_p) > 0
            for i = 0 to array.size(_p) - 1
                if math.abs(array.get(_p, i) - price) < gap
                    hit := i
                    break
        if hit >= 0
            array.set(_t, hit, array.get(_t, hit) + " / " + txt)
        else
            array.push(_p, price)
            array.push(_t, txt)
            array.push(_c, col)
            array.push(_w, width)

// previous day / week
pdH = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
pdL = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
pwH = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
pwL = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_on)

if barstate.islast and enableTDA
    // clear previous draw
    while array.size(LN) > 0
        line.delete(array.pop(LN))
    while array.size(LB) > 0
        label.delete(array.pop(LB))

    float[] cP = array.new_float()
    string[] cT = array.new_string()
    color[]  cC = array.new_color()
    int[]    cW = array.new_int()

    // A swing the price has already closed through is a BROKEN level -
    // still worth watching, but it is no longer overhead resistance.
    string t1h = close > h1 ? n1 + " high (broken)" : n1 + " swing high"
    string t1l = close < l1 ? n1 + " low (broken)"  : n1 + " swing low"
    string t2h = close > h2 ? n2 + " high (broken)" : n2 + " swing high"
    string t2l = close < l2 ? n2 + " low (broken)"  : n2 + " swing low"
    string t3h = close > h3 ? n3 + " high (broken)" : n3 + " swing high"
    string t3l = close < l3 ? n3 + " low (broken)"  : n3 + " swing low"
    string t4h = close > h4 ? n4 + " high (broken)" : n4 + " swing high"
    string t4l = close < l4 ? n4 + " low (broken)"  : n4 + " swing low"

    // Highest timeframe registers first, so a merged cluster keeps the
    // HTF colour and the HTF name leads the label.
    if shSwing
        f_push(cP, cT, cC, cW, h1, t1h, c1, 3, gapPts)
        f_push(cP, cT, cC, cW, l1, t1l, c1, 3, gapPts)
        f_push(cP, cT, cC, cW, h2, t2h, c2, 2, gapPts)
        f_push(cP, cT, cC, cW, l2, t2l, c2, 2, gapPts)
        f_push(cP, cT, cC, cW, h3, t3h, c3, 2, gapPts)
        f_push(cP, cT, cC, cW, l3, t3l, c3, 2, gapPts)
        f_push(cP, cT, cC, cW, h4, t4h, c4, 1, gapPts)
        f_push(cP, cT, cC, cW, l4, t4l, c4, 1, gapPts)

    if shPW
        f_push(cP, cT, cC, cW, pwH, "PWH", cPW, 2, gapPts)
        f_push(cP, cT, cC, cW, pwL, "PWL", cPW, 2, gapPts)

    if shPD
        f_push(cP, cT, cC, cW, pdH, "PDH", cPD, 1, gapPts)
        f_push(cP, cT, cC, cW, pdL, "PDL", cPD, 1, gapPts)

    if array.size(cP) > 0
        for i = 0 to array.size(cP) - 1
            float pr = array.get(cP, i)
            color cl = array.get(cC, i)
            line ln = line.new(bar_index - lvlLen, pr, bar_index + lblOff, pr,
                 color = cl, width = array.get(cW, i), style = styleOf)
            label lb = label.new(bar_index + lblOff, pr, array.get(cT, i),
                 style = label.style_label_left, color = color.new(color.black, 100),
                 textcolor = cl, size = size.small)
            array.push(LN, ln)
            array.push(LB, lb)

// ------------------------- ALERTS ----------------------------
alertcondition(ta.cross(score, 70),  title = "Aligned Long",  message = "TDA: aligned long")
alertcondition(ta.cross(score, -70), title = "Aligned Short", message = "TDA: aligned short")
alertcondition(gGreen and not gGreen[1], title = "Day gate turned GREEN", message = "TDA: day gate GREEN")
alertcondition(gRed   and not gRed[1],   title = "Day gate turned RED",   message = "TDA: day gate RED")

// ─── Forming-extreme alerts ───
alertcondition(newLowForming,  "Lower low forming",   "KPL: lower low forming — provisional leg killed")
alertcondition(newHighForming, "Higher high forming", "KPL: higher high forming — provisional leg killed")
````
