# Adaptive Market Structure & Fair Value

- url: https://www.tradingview.com/script/HfWsRc40-Adaptive-Market-Structure-Fair-Value/
- type: indicator
- pine_id: PUB;12b976b3d56b4256ba43f38ac784f06c
- version: 2.0

## Description

### Adaptive Market Structure & Fair Value

Adaptive Market Structure & Fair Value combines three complementary market measurements:

**Adaptive market structure**, using efficiency-adjusted pivot confirmation;

**Adaptive KAMA trend state**, using price efficiency and normalized KAMA progression;

**Session VWAP fair value**, using the direction and efficiency of VWAP migration.

The indicator is designed to distinguish structural price movement from short-term market noise rather than produce instantaneous turning-point signals.

### Adaptive Pivot Structure

Potential pivot highs and lows are identified when price exceeds the selected number of bars to the left of the candidate.

Unlike a fixed pivot algorithm, the number of right-side bars required for confirmation changes with price Efficiency Ratio (ER).

Efficient directional movement permits faster confirmation, while inefficient or noisy movement requires additional right-side evidence.

A pending candidate can therefore either:

* become a confirmed structural pivot after its required confirmation bars have elapsed, or
* disappear if price makes a more extreme high or low before confirmation.

**Pivot Caveat:** Confirmed pivots necessarily appear after the actual pivot bar. This is intentional confirmation delay, not repainting of a previously confirmed pivot. Pending candidates should not be treated as confirmed structure.

The Pivot Range Depth setting selects which surviving unbroken high/low pair defines the displayed structural zones. Increasing depth references progressively older and generally broader market structure.

### Adaptive KAMA

KAMA provides the indicator's short-term directional component.

Its responsiveness changes according to price Efficiency Ratio. Efficient movement causes KAMA to respond more quickly, while inefficient or sideways movement causes greater smoothing.

KAMA direction is not determined from price position alone. The script measures the linear-regression progression of KAMA and normalizes that movement against current market noise. Efficiency Ratio is then used to qualify how much confidence should be assigned to that progression.

The resulting states are:

* Bull High Efficiency
* Bull Directional
* Bull Transition
* Range
* Bear Transition
* Bear Directional
* Bear High Efficiency

The table displays the current state, its duration in bars, KAMA ER and normalized KAMA slope, together with the completed previous state.

### KAMA Confirmation Delay

KAMA is intentionally a confirmation tool rather than a prediction of the next price bar.

Several components contribute to its response time:

1. Efficiency Ratio is calculated across a historical lookback.
2. ER is smoothed before controlling KAMA responsiveness.
3. KAMA itself is an adaptive recursive average.
4. KAMA progression is measured using a short linear-regression slope.
5. When the optional KAMA Color Filter is enabled, major directional transitions also require price acceptance.

With the filter enabled, transitions from RANGE into a directional state and bullish-to-bearish or bearish-to-bullish reversals require price to exceed the accepted closing-price range established by the existing KAMA state.

This intentionally prevents a single minor change in slope from immediately reversing the displayed trend state.

Changes in efficiency within the same direction are not subjected to this additional acceptance delay, and deterioration back to RANGE is allowed immediately.

Consequently, the KAMA state should be interpreted as **confirmed trend condition**, not as an exact turning-point signal.

### Session VWAP Fair Value

VWAP resets at the selected session anchor and represents volume-weighted session fair value.

The indicator currently supports London and New York session anchoring.

In addition to plotting session VWAP, the script measures:

* VWAP Efficiency Ratio;
* normalized VWAP displacement;
* statistical strength of that displacement.

This allows VWAP to distinguish between simple movement in fair value and sustained directional migration.

### VWAP Warm-Up and Delay

The underlying VWAP calculation begins with the selected session and updates as new price and volume are received.

The **VWAP trend classification**, however, intentionally requires historical observations.

Early in the session, before enough bars are available for the full ER and statistical-strength calculations, the indicator uses the direction of VWAP displacement as an early directional estimate.

After sufficient observations accumulate, the classification becomes more selective and requires both:

* sufficient VWAP directional displacement; and
* VWAP Efficiency Ratio above its qualification threshold.

Therefore, the VWAP line itself should not be confused with the slower VWAP trend classification.

Higher VWAP ER lengths and smoothing values produce more stable classifications but require more bars before the full calculation becomes available.

### Important Interpretation

The Pivot, KAMA, and VWAP modules should not be expected to change simultaneously.

They measure different aspects of market behavior:

**Pivots** confirm structure after future bars establish that a swing survived.

**KAMA** confirms the quality and direction of recent price progression.

**VWAP** measures the migration of session fair value and requires session history before its stronger statistical classification is available.

A pivot may therefore form before KAMA confirms a directional change, or KAMA may become directional before VWAP has accumulated enough session data to confirm persistent fair-value migration.

This disagreement is not necessarily an error. It can represent a developing transition in market structure.

### Practical Use

The indicator is best used as a layered decision framework:

**Structure:** Where are the surviving pivot zones?

**Trend:** Is KAMA ranging, transitioning, directional, or highly efficient?

**Fair Value:** Is session VWAP migrating with the move or remaining relatively neutral?

Agreement between the three components provides stronger contextual confirmation than any individual component alone.

### Limitations

This indicator is descriptive and confirmatory. It does not predict future price movement.

Adaptive calculations necessarily introduce varying amounts of delay. Increasing ER lookbacks, smoothing lengths, pivot confirmation requirements, KAMA slow length, or structural depth will generally produce more stable information at the cost of slower response.

Pending pivots can disappear before confirmation. Confirmed pivots are historical structural references and should not be interpreted as signals that would have been known on the original pivot bar.

KAMA states may remain in the prior direction while a reversal is developing, particularly when the KAMA Color Filter is enabled.

VWAP trend classifications require sufficient bars after the selected session begins and should be considered immature during the early-session warm-up period.

The indicator should therefore be used as market context and confirmation rather than as a standalone entry or exit system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © immediatePerso44773

//@version=6
indicator("Adaptive Market Structure & Fair Value", shorttitle = "V1.0 Adaptive Structure",
 overlay = true, max_labels_count = 500, max_boxes_count = 100)

max_bars_back(time, 5000)

// INPUTS
g_str  =  'Show Intraday Tools And Structure Hand Offs'

executionModule = input.bool(true, "Show Intraday Execution Tools",
 tooltip =
 'Show the KAMA VWAP and the KAMA Table', group = g_str)
structureTF       = input.timeframe("15", "Structure / Execution Handoff",
 tooltip =
  "Below this timeframe, KAMA/VWAP execution tools are displayed. " +
  "At this timeframe and above, structural strength tools are displayed. " +
  "Adaptive pivots and structural zones remain visible on all timeframes.", group = g_str)

g_opr  =  'Visuals'

i_history  =  input.int(5, 'Sessions to Keep', minval = 1, group = g_opr)
i_tz = input.string("America/New_York", "Session Timezone", group = g_opr)
opr   =  input.int(5, 'Opening Ranges (Mins)', minval = 1, group = g_opr)
AS_on    =  input.bool(true, 'AS', inline = 'AS', group = g_opr)
AS_name  =  input.string('Asia', '', inline = 'AS', group = g_opr)
AS_time  =  input.session('1615-0200', '', inline = 'AS', group = g_opr)
AS_col   =  input.color(#AE81FF, '', inline = 'AS', group = g_opr)
LON_on    =  input.bool(true, 'LON', inline = 'LON', group = g_opr)
LON_name  =  input.string('London', '', inline = 'LON', group = g_opr)
LON_time  =  input.session('0300-0900', '', inline = 'LON', group = g_opr)
LON_col   =  input.color(#66d8ef62, '', inline = 'LON', group = g_opr)
NY_on    =  input.bool(true, 'NY', inline = 'NY', group = g_opr)
NY_name  =  input.string('NY Decision Window', '', inline = 'NY', group = g_opr)
NY_time  =  input.session('0930-1045', '', inline = 'NY', group = g_opr)
NY_col   =  input.color(#FD971F, '', inline = 'NY', group = g_opr)
i_box_width   =  input.int(1, 'Box Border Width', minval = 0, group = g_opr)
i_opr_style   =  input.string('Solid', 'OPR Line Style', 
 options = ['Solid', 'Dashed', 'Dotted'], group = g_opr)
i_opr_transp  =  input.int(90, 'OPR Fill Transparency', 
 minval = 0, maxval = 100, group = g_opr)

grp_StructureStrength = "Structural Pivot Strength"

showBOSReference = input.bool(true, "Show Last Broken Pivot",
      tooltip =
     "Displays the most recent broken adaptive pivot for each " +
     "structural depth up to the selected Pivot Range Depth. " +
     "The deepest selected depth is used by the Structural Strength Table.",
     group = grp_StructureStrength)
showStructureTable = input.bool(true, "Show Structural Strength Table",
 tooltip = "Displays measurements for the active structural sequence.", group = grp_StructureStrength)
bosBullColor = input.color(color.green, "Bull BOS", group = grp_StructureStrength)
bosBearColor = input.color(color.red,"Bear BOS", group = grp_StructureStrength)

grp_Pivots      = "Adaptive Pivot Detection"

showCandidates  = input.bool(true, "Show Pending Candidates", 
 tooltip = "Shows potential pivot highs and lows before confirmation. The displayed number is the adaptive number of right-side bars that must complete without price exceeding the candidate before the pivot becomes confirmed. Pending candidates may disappear if invalidated; confirmed pivots are therefore delayed by design", group = grp_Pivots)
leftBars        = input.int(2,  "Pivot Left", minval = 1,
 tooltip = "Number of bars used to establish the left side of a potential pivot. Lower values detect smaller swings; higher values focus on larger structural swings.", group = grp_Pivots)
pivotMin        = input.int(1,  "Minimum Right Bars", minval = 1, maxval = 6, 
 tooltip = "Minimum number of right-side bars required to confirm a pivot when price movement is highly efficient. Lower values allow faster confirmation.", group = grp_Pivots)
pivotMax        = input.int(2,  "Maximum Right Bars", minval = 1, 
 tooltip = "Maximum number of right-side bars required to confirm a pivot during less efficient price movement. Higher values produce slower but more selective pivot confirmation.", group = grp_Pivots)
erLen           = input.int(6,  "ER Length", minval = 6,
 tooltip = "Lookback used to measure price Efficiency Ratio (ER). ER determines how quickly potential pivots are confirmed. Shorter lengths react faster; longer lengths are smoother.", group = grp_Pivots)
erSmooth        = input.int(3,  "ER Smooth", minval = 3,
 tooltip = "Smooths the Efficiency Ratio used by the adaptive pivot engine. Higher values reduce short-term changes in pivot confirmation speed.", group = grp_Pivots)
zonePct         = input.float(25.0, "Pivot Zone (%)", minval = 5.0, maxval = 45.0, step = 5.0, 
 tooltip = "Sets the thickness of the structural zones as a percentage of the distance between the selected pivot high and pivot low.", group = grp_Pivots) / 100.0
maxActiveRanges = input.int(
     1,
     "Pivot Range Depth",
     minval = 1,
     maxval = 5,
     tooltip =
     "Selects structural depth. 1 uses the newest unbroken pivot pair; " +
     "higher values reference progressively older/larger structure. " +
     "BOS references are tracked from Depth 1 through the selected depth, " +
     "while the selected depth defines the displayed structural range " +
     "and Structural Strength Table.",
     group = grp_Pivots)
colorHighZone   = input.color(color.new(color.maroon , 55), "High Pivot Zone", group = grp_Pivots)
colorLowZone    = input.color(color.new(color.green, 55), "Low Pivot Zone", group = grp_Pivots)

grp_KAMA        = "Adaptive KAMA Short Term Trend"

useFilter       = input.bool(true, "KAMA Color Filter",
 tooltip = "Requires price acceptance before confirming RANGE-to-direction changes and bullish/bearish reversals. This intentionally delays major KAMA color changes to reduce rapid state switching during noisy price action. Same-direction efficiency changes and deterioration back to RANGE remain immediate.", group = grp_KAMA)
KAMAerLen       = input.int(15, "KAMA ER Length", options = [15, 24, 34],
  tooltip = "Lookback used to measure the efficiency of price movement for the adaptive KAMA. Shorter lengths react faster; longer lengths emphasize broader trend behavior.", group = grp_KAMA)
KAMAerSmooth    = input.int(3, "KAMA ER Smoothing Length", options = [3, 4, 5],
 tooltip = "Smooths the Efficiency Ratio controlling KAMA responsiveness. Higher values produce more stable but slower changes.", group = grp_KAMA)
maxLen          = input.int(21, "KAMA Slow Length", options = [21, 24, 55],
 tooltip = "Controls the slowest response of the adaptive KAMA during inefficient or sideways price movement. Higher values make KAMA more resistant to market noise.", group = grp_KAMA)
 
grp_vwap = "VWAP Session Fair Value"

marketSession  = input.string("New York", "VWAP Session", options = ["London", "New York"],
 tooltip = "Selects the session used to anchor VWAP. London begins at 08:00 London time; New York begins at 09:30 New York time.", group = grp_vwap)
src            = input.source(hlc3, "Source", 
 tooltip = "Price source used to calculate session VWAP. HLC3 is the default.", group=grp_vwap)
vwap_len       = input.int(15, "VWAP ER Length",
 tooltip = "Lookback used to measure how efficiently session VWAP is migrating. Higher ER indicates that fair value is moving consistently in one direction. VWAP ER is unavailable during the early-session warm-up until sufficient session bars have accumulated.", group = grp_vwap)
vwap_ER_Smooth = input.int(3, "VWAP ER Smoothing Length",
 tooltip = "Smooths VWAP Efficiency Ratio. Higher values reduce short-term changes in fair-value classification but add confirmation delay. This smoothing affects VWAP trend classification, not the underlying session VWAP price itself.", group = grp_vwap)

//  TYPES
type PivotCandidate

    float price
    int   bar
    int   pivotTime
    int   requiredRight
    label marker

type Pivot

    float price
    int   bar
    int   pivotTime
    bool  isHigh
    bool  isBroken
    label marker


type BOSReference

    Pivot pivot
    int direction
    int depth
    line bosLine
    label bosLabel


type StructuralLeg

    float startPrice
    float endPrice
    int   startBar
    int   endBar
    int   startTime
    int   endTime
    float distance
    int   bars
    float er
    float velocity
    float efficiency

type PivotRange

    Pivot highPivot
    Pivot lowPivot
    float Pivotrange
    float zoneHeight
    float highZoneTop
    float highZoneBottom
    float lowZoneTop
    float lowZoneBottom
    box   highBox
    box   lowBox
    bool  active

type SessionData

    string sess_time
    string name
    color  col
    int    opr_len
    box[]  opr_boxes

float chartTFSeconds             = timeframe.in_seconds()
float structureTFSeconds         = timeframe.in_seconds(structureTF)

bool showExecutionModule =
     executionModule and
     chartTFSeconds < structureTFSeconds

bool showStructuralModule =
     chartTFSeconds >= structureTFSeconds

var sesAS  =  SessionData.new(AS_time, AS_name, AS_col, opr, array.new_box())
var sesLON  =  SessionData.new(LON_time, LON_name, LON_col, opr, array.new_box())
var sesNY  =  SessionData.new(NY_time, NY_name, NY_col, opr, array.new_box())
var Pivot lastBrokenHigh         = na
var Pivot lastBrokenLow          = na
var int activeBOSDirection       = 0
var float activeBOSPrice         = na
var int   activeBOSBar           = na
var int   activeBOSTime          = na
var float highSinceBOS           = na
var float lowSinceBOS            = na
float structureDistance          = na
int   structureBars              = na
float structureER                = na
float pullbackDistance           = na
int   pullbackBars               = na
float retracement                = na
var int sessionBars    = 0
string sessionInput    = marketSession == "London" ? "0800-2100" : "0930-1600"
string sessionTimezone = marketSession == "London" ? "Europe/London" : "America/New_York"
timeVariable           = ta.change(time( "D", "", sessionTimezone))
inSession              = not na(time(timeframe.period, sessionInput,  sessionTimezone))
firstMarketBar         = inSession and (not inSession[1] or timeVariable != 0)
atr_norm               = ta.rma(ta.tr(true), 5)
dynamicNoiseGate       = math.max(atr_norm * 0.15, syminfo.mintick * 2)
tfSec                  = timeframe.in_seconds()
var cumVolume          = ta.cum(volume)
var float cumPV        = 0.0
var float cumV         = 0.0
color Above            = color.gray
bool hasVolume         = not na(volume) and cumVolume > 0
var PivotCandidate[] pendingHighs   = array.new<PivotCandidate>()
var PivotCandidate[] pendingLows    = array.new<PivotCandidate>()
var Pivot[]          confirmedHighs = array.new<Pivot>()
var Pivot[]          confirmedLows  = array.new<Pivot>()
var PivotRange[]     pivotRanges    = array.new<PivotRange>()
var BOSReference[] bosReferences    = array.new<BOSReference>()
Pivot[] preBreakHighs = array.new<Pivot>()
Pivot[] preBreakLows  = array.new<Pivot>()

// FUNCTIONS
get_style(s)  =>

    s  ==  'Solid' ? line.style_solid : s  ==  'Dashed' ? line.style_dashed : line.style_dotted

process_session(SessionData s) =>

    int t = time(timeframe.period, s.sess_time, i_tz)
    bool is_in_sess     = not na(t)
    bool is_new_sess    = is_in_sess and not is_in_sess[1]
    var float opr_hi    = na
    var float opr_lo    = na
    var int   startTime = na

    if is_new_sess

        startTime := time
        opr_hi    := high
        opr_lo    := low
        box newBox = box.new(left = bar_index,
         top = opr_hi, right = bar_index,
         bottom = opr_lo, border_color = s.col,
         border_style = get_style(i_opr_style),
         border_width = i_box_width,
         bgcolor = color.new(s.col, i_opr_transp))
        array.push(s.opr_boxes, newBox)

        if array.size(s.opr_boxes) > i_history

            box.delete(array.shift(s.opr_boxes))

    if is_in_sess and not na(startTime)

        float elapsedMins = (time - startTime) / 60000.0
        box curr_opr      = array.size(s.opr_boxes) > 0
         ? array.last(s.opr_boxes) : na

        if elapsedMins < s.opr_len

            opr_hi := math.max(opr_hi, high)
            opr_lo := math.min(opr_lo, low)

            if not na(curr_opr)

                box.set_top(curr_opr, opr_hi)
                box.set_bottom(curr_opr, opr_lo)
                box.set_right(curr_opr, bar_index)

        else

            if not na(curr_opr)

                box.set_right(curr_opr, bar_index)

f_structuralER(float startPrice, float endPrice, int startBar, int endBar) =>

    int legBars  = endBar - startBar
    float result = na

    if legBars > 0 and legBars <= 5000

        float netMove   = math.abs(endPrice - startPrice)
        float totalMove = 0.0

        for i = 0 to legBars - 1

            int offset = bar_index - endBar + i

            if offset >= 0

                totalMove += math.abs(close[offset] - close[offset + 1])

        result := totalMove > 0
         ? math.min(netMove / totalMove, 1.0) : 0.0

    result

f_createStructuralLeg(Pivot startPivot, Pivot endPivot) =>

    StructuralLeg result = na

    if not na(startPivot) and not na(endPivot)

        int bars           = math.abs(endPivot.bar - startPivot.bar)
        float distance     = math.abs(endPivot.price - startPivot.price)
        float structuralER = f_structuralER(startPivot.price,
         endPivot.price, startPivot.bar, endPivot.bar)
        float velocity     = bars > 0
         ? distance / bars : na
        float efficiency   = not na(structuralER) and not na(velocity)
         ? velocity * structuralER : na

        result := StructuralLeg.new(startPivot.price, endPivot.price,
         startPivot.bar, endPivot.bar, startPivot.pivotTime,
         endPivot.pivotTime, distance,
         bars, structuralER, velocity, efficiency)

    result

f_structuralEfficiencyColor(float value) =>

    na(value)
     ? color.gray
     : value >= 0.60
     ? color.new(color.green, 20)
     : value >= 0.40
     ? color.new(color.yellow, 20)
     : value >= 0.25
     ? color.new(color.orange, 20)
     : color.new(color.red, 20)
     
f_bosColor(int direction) =>

    direction == 1
     ? color.new(bosBullColor, 20) : direction == -1
     ? color.new(bosBearColor, 20) : color.gray

f_bosText(int direction) =>

    direction == 1
     ? "BULL BOS" : direction == -1
     ? "BEAR BOS" : "NONE"

f_er(float source, int len) =>

    float netMove   = math.abs(source - source[len])
    float totalMove = math.sum(math.abs(ta.change(source)), len)
    totalMove > 0 ? netMove / totalMove : 0.0

f_nthLastUnbrokenPivot(Pivot[] pivots, int depth) =>

    Pivot result = na
    int found    = 0
    int i        = array.size(pivots) - 1

    while i >= 0

        Pivot p = array.get(pivots, i)

        if not p.isBroken

            found += 1

            if found == depth

                result := p
                break

        i -= 1

    result

f_rangeExists(Pivot highPivot, Pivot lowPivot) =>

    bool exists = false

    if array.size(pivotRanges) > 0

        for i = 0 to array.size(pivotRanges) - 1

            PivotRange r = array.get(pivotRanges, i)

            if r.highPivot.bar == highPivot.bar and r.lowPivot.bar == lowPivot.bar

                exists := true
                break

    exists

f_createPivotRange(Pivot highPivot, Pivot lowPivot) =>

    if not na(highPivot) and not na(lowPivot)

        if not highPivot.isBroken and not lowPivot.isBroken

            if not f_rangeExists(highPivot, lowPivot)

                float structuralRange = math.abs(highPivot.price - lowPivot.price)

                if structuralRange > 0

                    float zoneHeight = structuralRange * zonePct
                    float highTop    = highPivot.price
                    float highBottom = highPivot.price - zoneHeight
                    float lowBottom  = lowPivot.price
                    float lowTop     = lowPivot.price + zoneHeight

                    PivotRange newRange = PivotRange.new(highPivot, lowPivot,
                     structuralRange, zoneHeight, highTop, highBottom,
                     lowTop, lowBottom, na, na, true)

                    array.push(pivotRanges, newRange)

f_tryCreateActiveRange() =>

    Pivot selectedHigh = f_nthLastUnbrokenPivot(confirmedHighs, maxActiveRanges)
    Pivot selectedLow  = f_nthLastUnbrokenPivot(confirmedLows, maxActiveRanges)

    if not na(selectedHigh) and not na(selectedLow)

        f_createPivotRange(selectedHigh, selectedLow)

f_updateBrokenPivots(Pivot[] pivots, bool isHigh) =>

    Pivot newlyBroken = na

    if array.size(pivots) > 0

        for i = 0 to array.size(pivots) - 1

            Pivot p = array.get(pivots, i)

            if not p.isBroken
                // Break of structure is close based
                bool brokenNow = barstate.isconfirmed and
                 (isHigh ? close > p.price : close < p.price)

                if brokenNow

                    p.isBroken := true

                    if not na(p.marker)

                        label.delete(p.marker)
                        p.marker := na

                    newlyBroken := p

    newlyBroken

f_updatePivotRanges() =>

    Pivot selectedHigh    = f_nthLastUnbrokenPivot( confirmedHighs,  maxActiveRanges)
    Pivot selectedLow     = f_nthLastUnbrokenPivot( confirmedLows, maxActiveRanges)
    bool haveSelectedPair = not na(selectedHigh) and not na(selectedLow)

    if array.size(pivotRanges) > 0

        int i = array.size(pivotRanges) - 1

        while i >= 0

            PivotRange r = array.get(pivotRanges, i)

            bool rangeBroken = r.highPivot.isBroken or r.lowPivot.isBroken

            bool selectedRange =
             haveSelectedPair and
             r.highPivot.bar == selectedHigh.bar and
             r.lowPivot.bar  == selectedLow.bar

            if rangeBroken or not selectedRange

                r.active := false

                if not na(r.highBox)

                    box.delete(r.highBox)
                    r.highBox := na

                if not na(r.lowBox)

                    box.delete(r.lowBox)
                    r.lowBox := na

            else

                r.active := true

                // HIGH PIVOT ZONE
                if na(r.highBox)

                    r.highBox :=  box.new(left = r.highPivot.pivotTime, top = r.highZoneTop, 
                     right = time, bottom = r.highZoneBottom, 
                     xloc = xloc.bar_time, 
                     bgcolor = colorHighZone, border_color = colorHighZone)

                else

                    box.set_right( r.highBox, time)

                if na(r.lowBox)

                    r.lowBox := box.new(left = r.lowPivot.pivotTime, top = r.lowZoneTop,
                     right = time, bottom = r.lowZoneBottom,
                     xloc = xloc.bar_time, bgcolor = colorLowZone,
                     border_color = colorLowZone)

                else

                    box.set_right( r.lowBox, time)

            i -= 1

f_createBOSReference(Pivot brokenPivot, int direction, int depth) =>

    color bosColor = direction == 1
     ? bosBullColor : bosBearColor
    string bosSide = direction == 1
     ? "H" : "L"
    line newLine = na
    label newLabel = na

    if showBOSReference

        newLine := line.new(x1 = brokenPivot.pivotTime, y1 = brokenPivot.price,
         x2 = time, y2 = brokenPivot.price,
         xloc = xloc.bar_time, extend = extend.none,
         color = bosColor, style = line.style_dashed, width = 2)

        newLabel := label.new(time, brokenPivot.price,
         "BOS " + bosSide + " D" + str.tostring(depth) +
         " " + str.tostring(brokenPivot.price, format.mintick),
         xloc = xloc.bar_time, yloc = yloc.price,
         color = color.new(color.black, 100), style = label.style_label_left,
         textalign = text.align_right, textcolor = color.new(bosColor, 30))

    BOSReference.new(brokenPivot, direction, depth, newLine, newLabel)

f_storeBOSReference(Pivot brokenPivot, int direction, int depth) =>

    if array.size(bosReferences) > 0

        int i = array.size(bosReferences) - 1

        while i >= 0

            BOSReference ref = array.get(bosReferences, i)

            if ref.depth == depth

                if not na(ref.bosLine)

                    line.delete(ref.bosLine)

                if not na(ref.bosLabel)

                    label.delete(ref.bosLabel)

                array.remove(bosReferences, i)

            i -= 1

    BOSReference newRef = f_createBOSReference(brokenPivot, direction, depth)
    array.push(bosReferences, newRef)

f_updateBOSReferences() =>

    if array.size(bosReferences) > 0

        int i = array.size(bosReferences) - 1

        while i >= 0

            BOSReference ref = array.get(bosReferences, i)

            if ref.depth > maxActiveRanges

                if not na(ref.bosLine)

                    line.delete(ref.bosLine)

                if not na(ref.bosLabel)

                    label.delete(ref.bosLabel)

                array.remove(bosReferences, i)

            else

                if showBOSReference

                    if not na(ref.bosLine)

                        line.set_x2(ref.bosLine, time)

                    if not na(ref.bosLabel)

                        label.set_x(ref.bosLabel, time)

            i -= 1

f_kamaERColor(float erValue) =>

    erValue >= 0.60
     ? color.lime : erValue >= 0.40
     ? color.green : erValue >= 0.25
     ? color.yellow : color.gray

f_kamaSlopeColor(float slopeValue) =>

    slopeValue > 0
     ? color.new(color.green, 30) : slopeValue < 0
     ? color.new(color.red, 30) : color.gray

f_kamaERTextColor(float erValue) =>

    na(erValue)
     ? color.white : erValue >= 0.60
     ? color.black : erValue >= 0.40
     ? color.white : erValue >= 0.25
     ? color.black : color.white

f_kamaStateTextColor(int state) =>

    state == 3 or
     state == 1 or
     state == -1
     ? color.black
     : color.white

f_kamaStateText(int state) =>

    switch state
        3  => "BULL HIGH EFF"
        2  => "BULL DIRECTIONAL"
        1  => "BULL TRANSITION"
        0  => "RANGE"
        -1 => "BEAR TRANSITION"
        -2 => "BEAR DIRECTIONAL"
        -3 => "BEAR HIGH EFF"
        => "UNKNOWN"

f_slopeStrengthText(float strength) =>
    
    na(strength) ? "CALC..." : strength >= 1.50 
     ? "V.STRONG" : strength >= 1.10 
     ? "STRONG" : strength >= 0.85 
     ? "MODERATE" : strength >= 0.50 
     ? "WEAK" : "EXHAUSTED"

f_slopeStrengthBgColor(float strength) =>

    na(strength) ? color.gray : strength >= 1.25 
     ? color.new(color.green, 20) : strength >= 0.85 
     ? color.new(color.blue, 30) : strength >= 0.50 
     ? color.new(color.orange, 30) : color.new(color.red, 30)

f_kamaStateColor(int state) =>

    switch state
        3  => color.lime
        2  => color.green
        1  => color.yellow
        0  => color.gray
        -1 => color.yellow
        -2 => color.maroon
        -3 => color.red 
        => color.gray

// MAIN CALCULATION PIPELINE

if AS_on

    process_session(sesAS)

if LON_on

    process_session(sesLON)

if NY_on

    process_session(sesNY)

Close_ER             = f_er(close, erLen)
float closeER        = bar_index >= erLen ? Close_ER : 0.0
float er             = ta.ema(closeER, erSmooth)
int adaptiveRight    = int(math.round(pivotMin + (pivotMax - pivotMin) * (1.0 - nz(er, 0.0))))
adaptiveRight        := math.max(pivotMin, math.min(adaptiveRight, pivotMax))
Highest_Bar          = ta.highest(high[1], leftBars)
bool isCandidateHigh = bar_index >= leftBars and high > Highest_Bar
Lowest_Bar           = ta.lowest(low[1], leftBars)
bool isCandidateLow  = bar_index >= leftBars and low < Lowest_Bar

if array.size(pendingHighs) > 0

    int i = array.size(pendingHighs) - 1

    while i >= 0

        PivotCandidate candidate = array.get(pendingHighs, i)
        int age          = bar_index - candidate.bar
        bool invalidated = bar_index > candidate.bar and high > candidate.price

        if invalidated

            if not na(candidate.marker)

                label.delete(candidate.marker)
                
            array.remove(pendingHighs, i)

        else if age >= candidate.requiredRight

            if not na(candidate.marker)

                label.delete(candidate.marker)

            label confirmedMarker = label.new(candidate.bar, candidate.price, str.tostring(candidate.requiredRight), 
             xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down,
             textcolor = color.red, color = color.new(color.maroon , 100), size = size.large)
            Pivot confirmed = Pivot.new(candidate.price, candidate.bar, candidate.pivotTime, true, false, confirmedMarker)
            array.push(confirmedHighs, confirmed)
            array.remove(pendingHighs, i)

        i -= 1

if array.size(pendingLows) > 0

    int i = array.size(pendingLows) - 1

    while i >= 0

        PivotCandidate candidate = array.get(pendingLows, i)
        int age                  = bar_index - candidate.bar
        bool invalidated         = bar_index > candidate.bar and low < candidate.price

        if invalidated

            if not na(candidate.marker)

                label.delete(candidate.marker)

            array.remove(pendingLows, i)

        else if age >= candidate.requiredRight

            if not na(candidate.marker)

                label.delete(candidate.marker)

            label confirmedMarker = label.new(candidate.bar, candidate.price, str.tostring(candidate.requiredRight),
                 xloc = xloc.bar_index, yloc = yloc.price, 
                 style = label.style_label_up, textcolor = color.green, 
                 color = color.new(color.green, 100), size = size.large)
            Pivot confirmed = Pivot.new(candidate.price, candidate.bar, candidate.pivotTime, false, false, confirmedMarker)
            array.push(confirmedLows, confirmed)
            array.remove(pendingLows, i)

        i -= 1

if isCandidateHigh

    label candidateMarker = (showCandidates ? 
     label.new(bar_index, high, str.tostring(adaptiveRight), 
     xloc = xloc.bar_index, yloc = yloc.price, 
     style = label.style_label_down, textcolor = color.white, 
     color = color.new(color.maroon , 80), size = size.small) : na)
    array.push(pendingHighs, PivotCandidate.new(high, bar_index, time, adaptiveRight, candidateMarker))

if isCandidateLow

    label candidateMarker = (showCandidates ? 
     label.new(bar_index, low, str.tostring(adaptiveRight), 
     xloc = xloc.bar_index, yloc = yloc.price, 
     style = label.style_label_up, textcolor = color.white, 
     color = color.new(color.green, 80), size = size.small) : na)
    array.push(pendingLows, PivotCandidate.new(low, bar_index, time, adaptiveRight, candidateMarker))

array.clear(preBreakHighs)
array.clear(preBreakLows)

for depth = 1 to maxActiveRanges

    Pivot depthHigh =
         f_nthLastUnbrokenPivot(confirmedHighs, depth)

    Pivot depthLow =
         f_nthLastUnbrokenPivot(confirmedLows, depth)

    array.push(preBreakHighs, depthHigh)

    array.push(preBreakLows, depthLow)

bool selectedBullBOS = false
bool selectedBearBOS = false
Pivot selectedBullPivot = na
Pivot selectedBearPivot = na

for depth = 1 to maxActiveRanges

    Pivot depthHigh = array.get(preBreakHighs, depth - 1)
    Pivot depthLow = array.get(preBreakLows, depth - 1)
    //Close is break of structure
    bool bullBreak = barstate.isconfirmed and not na(depthHigh) and close > depthHigh.price
    bool bearBreak = barstate.isconfirmed and not na(depthLow) and close < depthLow.price

    if bullBreak

        f_storeBOSReference(depthHigh, 1, depth)

        if depth == maxActiveRanges

            selectedBullBOS := true
            selectedBullPivot := depthHigh

    if bearBreak

        f_storeBOSReference(depthLow, -1, depth)

        if depth == maxActiveRanges

            selectedBearBOS := true
            selectedBearPivot := depthLow

Pivot newlyBrokenHigh = f_updateBrokenPivots(confirmedHighs, true)
Pivot newlyBrokenLow = f_updateBrokenPivots(confirmedLows, false)

f_tryCreateActiveRange()
f_updatePivotRanges()

if selectedBullBOS and not selectedBearBOS and not na(selectedBullPivot)

    lastBrokenHigh     := selectedBullPivot
    activeBOSDirection := 1
    activeBOSPrice     := selectedBullPivot.price
    activeBOSBar       := bar_index
    activeBOSTime      := time
    highSinceBOS       := high
    lowSinceBOS        := low

else if selectedBearBOS and not selectedBullBOS and not na(selectedBearPivot)

    lastBrokenLow      := selectedBearPivot
    activeBOSDirection := -1
    activeBOSPrice     := selectedBearPivot.price
    activeBOSBar       := bar_index
    activeBOSTime      := time
    highSinceBOS       := high
    lowSinceBOS := low

if activeBOSDirection != 0

    highSinceBOS := math.max(nz(highSinceBOS, high), high)
    lowSinceBOS  := math.min(nz(lowSinceBOS, low), low)

f_updateBOSReferences()

float bosExpansion = na
float bosAdverse   = na
float bosRetention = na
int   bosBars      = na

if activeBOSDirection == 1 and not na(activeBOSPrice)

    bosExpansion := math.max(highSinceBOS - activeBOSPrice, 0.0)
    bosAdverse   := math.max(activeBOSPrice - lowSinceBOS, 0.0)
    bosBars      := bar_index - activeBOSBar

else if activeBOSDirection == -1 and not na(activeBOSPrice)
    
    bosExpansion :=  math.max(activeBOSPrice - lowSinceBOS, 0.0)
    bosAdverse   := math.max(highSinceBOS - activeBOSPrice, 0.0)
    bosBars      := bar_index - activeBOSBar

if not na(bosExpansion) and not na(bosAdverse) and bosExpansion + bosAdverse > 0

    bosRetention := bosExpansion / (bosExpansion + bosAdverse)

float bosPullbackPct = na

if not na(bosExpansion) and bosExpansion > 0 and not na(bosAdverse)

    bosPullbackPct := bosAdverse / bosExpansion

Pivot structureHigh     = f_nthLastUnbrokenPivot(confirmedHighs, maxActiveRanges)
Pivot structureLow      = f_nthLastUnbrokenPivot(confirmedLows, maxActiveRanges)

if not na(structureHigh) and not na(structureLow)

    structureDistance := math.abs(structureHigh.price - structureLow.price)
    Pivot firstPivot = structureHigh.bar < structureLow.bar
     ? structureHigh : structureLow
    Pivot secondPivot = structureHigh.bar > structureLow.bar
     ? structureHigh : structureLow
    structureBars := secondPivot.bar - firstPivot.bar
    structureER :=
     f_structuralER(firstPivot.price, secondPivot.price,
      firstPivot.bar, secondPivot.bar)

    float completedLegDistance =
         math.abs(secondPivot.price - firstPivot.price)

    if secondPivot.isHigh

        pullbackDistance :=
             math.max(secondPivot.price - close, 0.0)

        pullbackBars :=
             bar_index - secondPivot.bar

    else

        pullbackDistance :=
             math.max(close - secondPivot.price, 0.0)

        pullbackBars :=
             bar_index - secondPivot.bar

    retracement :=
         completedLegDistance > 0
         ? pullbackDistance / completedLegDistance
         : na

while array.size(confirmedHighs) > 100

    Pivot oldPivot = array.shift(confirmedHighs)

    if not na(oldPivot.marker)

        label.delete(oldPivot.marker)

while array.size(confirmedLows) > 100

    Pivot oldPivot = array.shift(confirmedLows)

    if not na(oldPivot.marker)

        label.delete(oldPivot.marker)

while array.size(pivotRanges) > 100

    PivotRange oldRange = array.shift(pivotRanges)

    if not na(oldRange.highBox)

        box.delete(oldRange.highBox)

    if not na(oldRange.lowBox)

        box.delete(oldRange.lowBox)

if firstMarketBar

    sessionBars := 1
    cumPV := hasVolume ? src * volume : 0.0
    cumV  := hasVolume ? volume : 0.0

else if inSession

    sessionBars += 1

else

    sessionBars := 0
    cumPV := 0.0
    cumV  := 0.0

if hasVolume

    if firstMarketBar

        cumPV := src * volume
        cumV  := volume

    else if inSession

        cumPV += src * volume
        cumV  += volume

    else

        cumPV := 0.0
        cumV  := 0.0
        
else

    cumPV := 0.0
    cumV  := 0.0

float vwapValue         = (hasVolume and inSession and cumV > 0 
 ? cumPV / cumV : na)
float vwap_eff          = f_er(vwapValue, vwap_len)
float vwapEfficiencyRaw = sessionBars > vwap_len ? vwap_eff : na
float vwapEfficiency    = ta.ema(vwapEfficiencyRaw, vwap_ER_Smooth)
bool usingER            = hasVolume and sessionBars >= vwap_len + vwap_ER_Smooth
vwapER                  = (usingER ? vwapEfficiency : na)
int vwapLookback        = tfSec <= 60 ? 8 : tfSec <= 300 ? 5 : 3
float lookbackNoise     = dynamicNoiseGate * math.sqrt(vwapLookback)
float vwapDisplacementStrength = sessionBars > vwapLookback and lookbackNoise > 0
 ? (vwapValue - vwapValue[vwapLookback]) / lookbackNoise : na
bool earlyBull = hasVolume and inSession and vwapDisplacementStrength > 0
bool earlyBear = hasVolume and inSession and vwapDisplacementStrength < 0
int vwapStrengthLen = 20
float vwapStrengthDev = ta.stdev(vwapDisplacementStrength, vwapStrengthLen)
bool vwapStrengthReady = sessionBars > vwapLookback + vwapStrengthLen
bool trendBull = usingER and vwapStrengthReady and
 not na(vwapStrengthDev) and vwapDisplacementStrength >
 vwapStrengthDev * 0.5 and vwapER > 0.30
bool trendBear =
 usingER and vwapStrengthReady and
 not na(vwapStrengthDev) and vwapDisplacementStrength <
 -vwapStrengthDev * 0.5 and vwapER > 0.30
bool bullState = usingER and vwapStrengthReady
 ? trendBull : earlyBull
bool bearState = usingER and vwapStrengthReady
 ? trendBear : earlyBear

if inSession

    if bullState and close > vwapValue

        Above := color.new(color.green, 20)

    else if bearState and close < vwapValue

        Above := color.new(color.maroon , 20)

plot(showExecutionModule and inSession ? vwapValue : na, title = "Session VWAP", style = plot.style_linebr, color = Above, linestyle = plot.linestyle_dashed)

var float adaptiveKAMA = na

slowSC =
 2.0 / (maxLen + 1)

ER_KAMAerLen =
 ta.ema(f_er(close, KAMAerLen), KAMAerSmooth)

adaptiveSC =
 math.pow(ER_KAMAerLen * (0.667 - slowSC) + slowSC, 2)

adaptiveKAMA := na(adaptiveKAMA[1])
 ? close : adaptiveKAMA[1] + adaptiveSC * (close - adaptiveKAMA[1])

kamaDelta =
 ta.linreg(adaptiveKAMA, 5, 0) - ta.linreg(adaptiveKAMA, 5, 1)

float kamaSlopeStrength = dynamicNoiseGate > 0
 ? kamaDelta / dynamicNoiseGate : 0.0

float trustedKamaProgress = kamaSlopeStrength * ER_KAMAerLen

bool kamaRising = trustedKamaProgress > 0

bool kamaFalling = trustedKamaProgress < 0

bool kamaRange =
 ER_KAMAerLen < 0.25

bool kamaTransitionBull =
 ER_KAMAerLen >= 0.25 and
 ER_KAMAerLen < 0.40 and
 kamaRising

bool kamaTransitionBear =
 ER_KAMAerLen >= 0.25 and
 ER_KAMAerLen < 0.40 and
 kamaFalling

bool kamaDirectionalBull =
 ER_KAMAerLen >= 0.40 and
 ER_KAMAerLen < 0.60 and
 kamaRising

bool kamaDirectionalBear =
 ER_KAMAerLen >= 0.40 and
 ER_KAMAerLen < 0.60 and
 kamaFalling

bool kamaHighEfficiencyBull =
 ER_KAMAerLen >= 0.60 and
 kamaRising

bool kamaHighEfficiencyBear =
 ER_KAMAerLen >= 0.60 and
 kamaFalling

int rawKamaState =
 kamaRange
 ? 0  : kamaTransitionBull
 ? 1  : kamaDirectionalBull
 ? 2  : kamaHighEfficiencyBull
 ? 3  : kamaTransitionBear
 ? -1 : kamaDirectionalBear
 ? -2 : kamaHighEfficiencyBear
 ? -3 : 0

var int confirmedKamaState = 0
var float kamaStateHighClose = na
var float kamaStateLowClose  = na

if barstate.isfirst

    confirmedKamaState := rawKamaState
    kamaStateHighClose := close
    kamaStateLowClose  := close

if useFilter

    float priorHighClose   = kamaStateHighClose
    float priorLowClose    = kamaStateLowClose
    bool rawBull           = rawKamaState > 0
    bool rawBear           = rawKamaState < 0
    bool confirmedBull     = confirmedKamaState > 0
    bool confirmedBear     = confirmedKamaState < 0
    bool bullBreakAccepted = not na(priorHighClose) and close > priorHighClose
    bool bearBreakAccepted = not na(priorLowClose) and close < priorLowClose
    bool acceptNewState    = false

    if confirmedKamaState == 0

        if rawBull

            acceptNewState := bullBreakAccepted

        else if rawBear

            acceptNewState := bearBreakAccepted

    else if confirmedBull and rawBear

        acceptNewState := bearBreakAccepted

    else if confirmedBear and rawBull

        acceptNewState := bullBreakAccepted

    else if confirmedBull and rawBull

        acceptNewState := true

    else if confirmedBear and rawBear

        acceptNewState := true

    else if rawKamaState == 0

        acceptNewState := true

    if acceptNewState and rawKamaState != confirmedKamaState

        confirmedKamaState := rawKamaState
        kamaStateHighClose := close
        kamaStateLowClose  := close

    else

        kamaStateHighClose := math.max(nz(kamaStateHighClose, close), close)
        kamaStateLowClose  := math.min(nz(kamaStateLowClose, close), close)

else

    confirmedKamaState := rawKamaState
    kamaStateHighClose := close
    kamaStateLowClose  := close

int kamaState = useFilter
 ? confirmedKamaState : rawKamaState
var float previousKamaER = na
var float previousKamaSlope = na
bool kamaStateChanged =
 not na(kamaState[1]) and
 kamaState != kamaState[1]

if kamaStateChanged

    previousKamaER    := ER_KAMAerLen[1]

    previousKamaSlope := kamaSlopeStrength[1]

var int kamaStateBars = 1

if kamaState == kamaState[1]

    kamaStateBars += 1

else
    
    kamaStateBars := 1

var int previousKamaState     = 0
var int previousKamaStateBars = 0

if kamaStateChanged
    
    previousKamaState := nz(kamaState[1], 0)
    previousKamaStateBars := nz(kamaStateBars[1], 0)


var float previousSlopeStrength     = na
bool chart_1_min = timeframe.in_seconds() == timeframe.in_seconds("1")
int availableStateHistory = math.max(kamaStateBars - 1, 0)
bool strengthReady1m = availableStateHistory >= 3
int strengthLookback1m = math.min(availableStateHistory, 10)
float weightedSlopeSum = 0.0
float erWeightSum      = 0.0

if chart_1_min and strengthReady1m

    for i = 1 to strengthLookback1m

        float historicalER    = ER_KAMAerLen[i]
        float historicalSlope = math.abs(kamaSlopeStrength[i])

        if not na(historicalER) and not na(historicalSlope)

            weightedSlopeSum += historicalSlope * historicalER
            erWeightSum += historicalER

float kamaBaselineSlope = chart_1_min and strengthReady1m and erWeightSum > 0
 ? weightedSlopeSum / erWeightSum : na

float relativeStrength1m = not na(kamaBaselineSlope) and kamaBaselineSlope > 0
 ? math.abs(kamaSlopeStrength) / kamaBaselineSlope : na

float currentSlopeStrength =
     chart_1_min
     ? relativeStrength1m
     : math.abs(kamaSlopeStrength) * ER_KAMAerLen

if kamaStateChanged

    previousSlopeStrength := currentSlopeStrength[1]

color kamaLine_Color = color.gray

if kamaState == 3

    kamaLine_Color := color.lime

else if kamaState == 2

    kamaLine_Color := color.green

else if kamaState == 1

    kamaLine_Color := color.yellow

else if kamaState == 0

    kamaLine_Color := color.gray

else if kamaState == -1

    kamaLine_Color := color.yellow

else if kamaState == -2

    kamaLine_Color := color.maroon

else if kamaState == -3

    kamaLine_Color := color.red

else

    kamaLine_Color := color.gray

plot(showExecutionModule ? adaptiveKAMA : na, "KAMA", color = kamaLine_Color, linewidth = 2)

var table kamaTable =  table.new(position.bottom_right, 6, 3, border_width = 1)

if barstate.islast

    if showExecutionModule
        
        string currentStrengthText = chart_1_min
         ? f_slopeStrengthText(currentSlopeStrength)
         : "ER QUALIFIED"

        string previousStrengthText = chart_1_min
         ? f_slopeStrengthText(previousSlopeStrength)
         : "ER QUALIFIED"

        table.cell(kamaTable, 0, 0,
        "KAMA", text_color = color.white)
        table.cell(kamaTable, 1, 0,
        "STATE", text_color = color.white)
        table.cell(kamaTable, 2, 0,
        "BARS", text_color = color.white)
        table.cell(kamaTable, 3, 0,
        "ER", text_color = color.white)
        table.cell(kamaTable, 4, 0,
        "SLOPE", text_color = color.white)
        table.cell(kamaTable, 5, 0, 
        "STRENGTH", text_color = color.white)

        table.cell(kamaTable, 0, 1, "Current", 
        text_color = color.white)
        table.cell(kamaTable, 1, 1, f_kamaStateText(kamaState),
        bgcolor = f_kamaStateColor(kamaState), text_color = f_kamaStateTextColor(kamaState))
        table.cell(kamaTable, 2, 1, str.tostring(kamaStateBars),
        text_color = color.white)
        table.cell(kamaTable, 3, 1, str.tostring(ER_KAMAerLen, "#.00"),
        bgcolor = f_kamaERColor(ER_KAMAerLen), text_color = f_kamaERTextColor(ER_KAMAerLen))
        table.cell(kamaTable, 4, 1, str.tostring(kamaSlopeStrength, "+#.00;-#.00"),
        bgcolor = f_kamaSlopeColor(kamaSlopeStrength), text_color = color.white)
        table.cell(kamaTable, 5, 1, str.tostring(currentSlopeStrength, "0.00") + "\n(" + currentStrengthText + ")", 
        bgcolor = f_slopeStrengthBgColor(currentSlopeStrength), text_color = color.white)

        table.cell(kamaTable, 0, 2, "Previous",
        text_color = color.white)
        table.cell(kamaTable, 1, 2, f_kamaStateText(previousKamaState),
        bgcolor = f_kamaStateColor(previousKamaState), text_color = f_kamaStateTextColor(previousKamaState))
        table.cell(kamaTable, 2, 2, str.tostring(previousKamaStateBars),
        text_color = color.white)
        table.cell(kamaTable, 3, 2, str.tostring(previousKamaER, "#.00"), 
        bgcolor = f_kamaERColor(previousKamaER), text_color = f_kamaERTextColor(previousKamaER))
        table.cell(kamaTable, 4, 2,str.tostring(previousKamaSlope, "+#.00;-#.00"), 
        bgcolor = f_kamaSlopeColor(previousKamaSlope), text_color = color.white)
        table.cell(kamaTable, 5, 2, str.tostring(previousSlopeStrength, "0.00") + "\n(" + previousStrengthText + ")", 
        bgcolor = f_slopeStrengthBgColor(previousSlopeStrength), text_color = color.white)
    else
        table.clear(kamaTable, 0, 0, 5, 2)

var table structureTable = table.new(position.top_right, 4, 5, border_width = 1)

if barstate.islast

    if  showStructureTable and showStructuralModule

        table.cell(structureTable, 0, 0, timeframe.period + " STRUCTURE", text_color = color.white)
        table.cell( structureTable, 1, 0, "DIST", text_color = color.white)
        table.cell(structureTable, 2, 0, "BARS",  text_color = color.white)
        table.cell(structureTable, 3, 0, "QUALITY", text_color = color.white)

        table.cell(structureTable, 0, 1, "PIVOT RANGE", text_color = color.white)
        table.cell(structureTable, 1, 1, na(structureDistance)
         ? "-" : str.tostring( structureDistance,  "#.00"), text_color = color.white)
        table.cell(structureTable, 2, 1, na(structureBars)
         ? "-" : str.tostring(structureBars), text_color = color.white)
        table.cell(structureTable, 3, 1, "ROOM", text_color = color.white)

        table.cell(structureTable, 0, 2, "PIVOT SHAPE", text_color = color.white)
        table.cell(structureTable, 1, 2, "ER", text_color = color.white)
        table.cell(structureTable, 2, 2, na(structureBars)
         ? "-" : str.tostring(structureBars), text_color = color.white)
        table.cell(structureTable, 3, 2, na(structureER)
         ? "-" : str.tostring(structureER, "#.00"),
         bgcolor = f_structuralEfficiencyColor(structureER), text_color = color.white)

        table.cell(structureTable, 0, 3, f_bosText(activeBOSDirection),
         bgcolor = f_bosColor(activeBOSDirection), text_color = color.white)
        table.cell(structureTable, 1, 3, na(bosExpansion)
         ? "-" : str.tostring(bosExpansion, "#.00"), 
         bgcolor = f_bosColor(activeBOSDirection), text_color = color.white)
        table.cell(structureTable, 2, 3, na(bosBars)
         ? "-" : str.tostring(bosBars), 
         bgcolor = f_bosColor(activeBOSDirection), text_color = color.white)
        table.cell(structureTable, 3, 3, "EXPANSION", 
         bgcolor = f_bosColor(activeBOSDirection), text_color = color.white)

        table.cell(structureTable, 0, 4, "RETRACE", text_color = color.white)

        table.cell(structureTable, 1, 4, na(pullbackDistance)
         ? "-" : str.tostring(pullbackDistance, "#.00"),
         text_color = color.white)

        table.cell(structureTable, 2, 4, na(pullbackBars)
         ? "-" : str.tostring(pullbackBars),
         text_color = color.white)

        table.cell(structureTable, 3, 4, na(retracement)
         ? "-" : "RET " + str.tostring(retracement * 100, "#") + "%",
         text_color = color.white)

    else

        table.clear(structureTable, 0, 0, 3, 4)

bool sigCrossUP = ta.crossover(adaptiveKAMA, vwapValue)
bool sigCrossDn = ta.crossunder(adaptiveKAMA, vwapValue)

bool bullCross = showExecutionModule and
 inSession and sigCrossUP and barstate.isconfirmed
bool bearCross = showExecutionModule and
 inSession and sigCrossDn and barstate.isconfirmed

plotshape(bullCross, style = shape.triangleup, color = color.lime, location = location.belowbar, size = size.small)
plotshape(bearCross, style = shape.triangledown, color = color.maroon , location = location.abovebar, size = size.small)

alertcondition(bullCross, "Bull Cross", "KAMA crossed above VWAP")
alertcondition(bearCross, "Bear Cross", "KAMA crossed below VWAP")

var table volumeWarning = table.new(position.middle_center,
 1, 1, border_width = 1)

if barstate.islast

    if not hasVolume

        table.cell(volumeWarning, 0, 0, "VWAP UNAVAILABLE",
         text_color = color.white, bgcolor = color.maroon,  text_size = size.large)

    else
        table.delete(volumeWarning)
````
