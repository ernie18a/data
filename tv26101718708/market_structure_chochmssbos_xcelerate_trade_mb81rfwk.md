# Market Structure + CHoCH/MSS/BOS | Xcelerate Trade

- url: https://www.tradingview.com/script/mB81RFwK-Market-Structure-CHoCH-MSS-BOS-Xcelerate-Trade/
- type: indicator
- pine_id: PUB;ad13223397da4f12a6a65f97042bfbe1
- version: 2.0

## Description

Market Structure + CHoCH / MSS / BOS | Xcelerate Trade
A precise market-structure mapper from the Xcelerate Trade team. It auto-detects swing highs / lows, classifies every break of structure as CHoCH (Change of Character), MSS (Market Structure Shift) or BOS (Break of Structure), and labels each pivot as HH / HL / LH / LL. Designed for SMC and price-action traders who want a clean, repaint-aware structural read of the chart.

What you get on the chart
Swing labels: HH (Higher High), HL (Higher Low), LH (Lower High), LL (Lower Low) — auto-placed on every detected pivot.
Break lines: every confirmed break is drawn as a horizontal segment from the swing bar to the breaking bar.
Break tags: each break line gets a label — CHoCH, MSS or BOS — so you can read structure at a glance.
Info table (top-right): current settings (Auto / Manual, TF, L/R, detection method, MSS definition, break validation) and an optional debug panel with trend state, flags, pre-CHoCH levels, last-break details.
Pattern alerts: ready-to-use alertcondition for HH-HL-HH and LL-LH-LL sequences.
Pivot detection — two modes
Williams Fractals (default): classic ta.pivothigh / ta.pivotlow with separate left and right lengths. Configurable in Manual Settings (defaults L = 6, R = 4) or selected automatically per timeframe via Auto Timeframe Settings:

Timeframe L / R
1m
4 / 4
5m
4 / 3
15m
5 / 4
30m+, daily, weekly, monthly
6 / 4
Simple Fractals: SMC-style, symmetric — current bar is a pivot if it's the highest / lowest within simpleFractalPeriod bars on each side. Faster but more frequent than Williams.

You can also force Wait for bar close (default ON) to confirm pivots only on closed bars.

Break validation — 4 modes
Choose how a level is considered "broken":

Close — close beyond the swing level (cleanest, default).
High/Low (wick) — wick beyond the level (most aggressive).
Close beyond buffer (ticks) — close beyond level ± N × mintick.
Close beyond buffer (%) — close beyond level ± X%.
Buffer fields appear conditionally so you can tune the strictness of structure breaks per instrument (forex, indices, crypto, etc.).

Structure classification — CHoCH / MSS / BOS
Trend state is tracked internally (Bullish, Bearish, Neutral). Every confirmed break is then classified:

CHoCH — first break that reverses the trend (bullish CHoCH on a close above the last swing high while bearish; bearish CHoCH on a close below the last swing low while bullish), or the very first break when the trend is still neutral. CHoCH flips the trend and starts a fresh leg.

MSS — first qualifying break in the direction of the new trend after CHoCH, per the MSS definition setting:

First break after CHoCH — any first break in trend direction = MSS, then BOS.
First break >= pre-CHoCH level — MSS only when the broken swing is at or beyond the swing level that existed before the CHoCH. Stricter — protects against premature MSS calls.
HL + >= pre-CHoCH (legacy) — same as above, plus a confirming HL (bull) / LH (bear) is required after CHoCH before MSS can fire.
BOS — every subsequent break in the trend direction after MSS — until the opposite CHoCH occurs and the cycle restarts.

This rule set keeps only one MSS per trend leg, with everything before it being CHoCH and everything after being BOS — exactly how SMC traders read it.

Pre-CHoCH levels (transparent reasoning)
When CHoCH fires, the script captures the swing-high / swing-low that existed before the trend flip (pre_choch_swing_high / pre_choch_swing_low). These are used by the stricter MSS modes and shown in the debug rows of the info table, so you can verify exactly why a break was classified as MSS or BOS.

Last broken swing tracking
For every confirmed break the indicator stores:

lastBreakSwingBarIndex — the bar where the broken swing originally formed (its ID).
lastBreakSwingPrice — the level that was broken.
lastBreakClassification — CHoCH / MSS / BOS.
lastBreakDirection — above swing high / below swing low.
lastBreakDetectBarIndex — the bar where the break passed your validation filter.
These are visible in the debug rows when Show debug rows (table) is on — useful for forensic / journal-style review.

Drawing budget (FIFO)
The indicator caps the number of CHoCH / MSS / BOS line + label pairs at Max CHoCH/MSS/BOS lines + labels (default 400, max ~80% of TradingView's 500 limit). Older drawings are removed first (FIFO), so you never hit the line cap on long histories.

Alerts
Two ready-to-use alert conditions:

HH-HL-HH Alert — fires when an HH-HL-HH pattern completes.
LL-LH-LL Alert — fires when an LL-LH-LL pattern completes.
Use TradingView's alert dialog → choose the alert condition by name. Messages include {{ticker}} and {{interval}} placeholders.

Suggested settings (from the Xcelerate Trade team)
Default for most traders: Auto settings ON, Williams Fractals, Wait for bar close ON, Break validation = Close, MSS definition = First break after CHoCH.
Strict structural read (low noise): Break validation = Close beyond buffer (%) with 0.05–0.10%, MSS definition = First break >= pre-CHoCH level.
Aggressive / fast feedback: Simple Fractals with period 2, Break validation = High/Low (wick), Wait for bar close = OFF.
Forensic review: turn ON Show debug rows (table) to see trend state, CHoCH / MSS flags, pre-CHoCH levels and the last-break summary.
Notes & disclaimers
Williams Fractals confirm with a delay equal to the right-length (R bars). This is intentional — pivots are not repainted after confirmation.
Simple Fractals confirm with a delay equal to simpleFractalPeriod bars.
This is an analytical tool — no automated buy / sell labels. Pair with your own execution rules.
Pine Script v6.
Built and maintained by the Xcelerate Trade team. A complete CHoCH / MSS / BOS market-structure read with HH / HL / LH / LL labels, four break-validation modes, three MSS definition modes, an info / debug table and ready alert conditions.

## Source Code

````pine
//@version=6
// -----------------------------------------------------------------------------
// MARKET STRUCTURE — logic specification (maintenance reference)
//
// Swing high/low: Williams (ta.pivothigh/low) or Simple Fractals (center at offset N).
// CHoCH: first break that reverses the trend (close above the last swing high in bear,
//        or below the last swing low in bull), or at trend==0 on the first such break.
// BOS:   in an already established trend, a break in the trend direction that does not
//        meet the MSS conditions below.
// MSS:   defined by the "MSS definition" setting: (1) first break after CHoCH in the
//        trend direction; (2) first break of a swing >= pre-CHoCH level; (3) legacy:
//        HL/LH + swing >= pre-CHoCH. Only one MSS per trend leg until the opposite
//        CHoCH, then BOS.
//
// Break validation: Close | High/Low (wick) | Close beyond level +/- ticks |
//                   or +/- percent of price (buffer %).
// Last break (point 4): bar_index and price of the broken swing + CHoCH/MSS/BOS label.
// -----------------------------------------------------------------------------

indicator('Market Structure + CHoCH/MSS/BOS | Xcelerate Trade', overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500)

// Indicator line budget — recommended cap for break drawings (~80%)
INDICATOR_LINE_BUDGET = 500
MAX_BREAK_DRAWINGS_CAP = int(INDICATOR_LINE_BUDGET * 0.8)

// Input groupings
autoGroup = "Auto Timeframe Settings"
manualGroup = "Manual Settings"
pivotGroup = "Pivot Detection Method"
otherGroup = "Other Settings"
displayGroup = "Display Settings"
breakGroup = "Break detection"
structGroup = "CHoCH / MSS / BOS"

// Toggle for auto settings
useAutoSettings = input.bool(true, title="Enable auto settings", group=autoGroup, tooltip="Auto L/R: 1m -> 4/4, 5m -> 4/3, 15m -> 5/4, 30m+ intraday -> 6/4. Daily / weekly / monthly and other non-standard TFs use the same bucket as 30m+ (6/4).")

// Break validation (point 3 — complete: ticks + percent)
breakValidation = input.string("Close", "Break validation", options=["Close", "High/Low (wick)", "Close beyond buffer (ticks)", "Close beyond buffer (%)"], group=breakGroup, tooltip="Close: closure only. Wick: closed-bar high/low vs swing. Buffer ticks: close beyond level +/- N x mintick. Buffer %: close beyond level +/-%.")
bufferTicks = input.int(0, "Buffer (ticks)", minval=0, group=breakGroup, tooltip="For 'Close beyond buffer (ticks)' mode.")
bufferPercent = input.float(0.05, "Buffer (%)", minval=0.0, maxval=5.0, step=0.01, group=breakGroup, tooltip="For 'Close beyond buffer (%)' mode — relative breach vs the swing level.")

mssDefinitionMode = input.string("First break after CHoCH", "MSS definition", options=["First break after CHoCH", "First break >= pre-CHoCH level", "HL + >= pre-CHoCH (legacy)"], group=structGroup, tooltip="First break after CHoCH: first valid break above a swing high (bull) / below a swing low (bear) after CHoCH = MSS, then BOS. >= pre-CHoCH: first break that takes a swing at or beyond the pre-CHoCH level (bull) or at / below pre-CHoCH (bear). Legacy: as before — also requires an HL/LH after CHoCH before MSS. After the first MSS on a leg, only BOS follows until the opposite CHoCH.")

// Display settings
showStructure = input.bool(true, title="Show HH/HL/LH/LL", group=displayGroup)
showBreaks = input.bool(true, title="Show CHoCH/MSS/BOS", group=displayGroup)
showLabels = input.bool(true, title="Show Break Labels", group=displayGroup)
showDebug = input.bool(false, "Show debug rows (table)", group=displayGroup, tooltip="Trend, CHoCH/MSS flags, pre-CHoCH levels — diagnostic only.")
maxBreakDrawings = input.int(400, "Max CHoCH/MSS/BOS lines + labels", minval=10, maxval=MAX_BREAK_DRAWINGS_CAP, step=10, group=displayGroup, tooltip="FIFO; default ~80% of max_lines_count (500) to avoid hitting the cap.")

// Colors
colBull = input.color(#089981, "Bullish Color", group=displayGroup)
colBear = input.color(#f23645, "Bearish Color", group=displayGroup)

// Promo banner (xcelerate.trade) — always on; timing tunable in settings (no disable toggle in menu).
groupPromo = "Promo Banner"
showSitePromo = true
promoIntervalMin = input.int(5, "Minutes hidden (between flashes)", minval=1, maxval=120, group=groupPromo, tooltip="After the message disappears, how long it stays hidden before the next appearance (including the first appearance after load).")
promoHighlightSec = input.int(30, "Seconds visible each flash", minval=5, maxval=120, group=groupPromo, tooltip="How many seconds the message stays visible in the center on each cycle.")

// Pivot Detection Method
pivotMethod = input.string("Williams Fractals", "Detection Method",
     options=["Williams Fractals", "Simple Fractals"],
     group=pivotGroup,
     tooltip="Williams Fractals: Classic method with delay\nSimple Fractals: SMC-style detection with MSS/BOS")

simpleFractalPeriod = input.int(2, "Simple Fractal Period", minval=1, maxval=10, group=pivotGroup,
     tooltip="Bars on each side for Simple Fractals detection")

// Function for auto settings
f_getTimeframeSetting(settingType) =>
    tf_minutes = timeframe.in_seconds() / 60
    if settingType == "left"
        tf_minutes <= 1 ? 4 : tf_minutes <= 5 ? 4 : tf_minutes <= 15 ? 5 : 6
    else if settingType == "right"
        tf_minutes <= 1 ? 4 : tf_minutes <= 5 ? 3 : tf_minutes <= 15 ? 4 : 4
    else
        0

autoPvtLenL = f_getTimeframeSetting("left")
autoPvtLenR = f_getTimeframeSetting("right")

manualPvtLenL = input.int(6, title="Pivot Length Left", group=manualGroup, minval=1)
manualPvtLenR = input.int(4, title="Pivot Length Right", group=manualGroup, minval=1)

pvtLenL = useAutoSettings ? autoPvtLenL : manualPvtLenL
pvtLenR = useAutoSettings ? autoPvtLenR : manualPvtLenR

waitforclose = input.bool(true, title="Wait for bar close", group=otherGroup)

tickBuf = bufferTicks * syminfo.mintick

f_bullBreakAbove(float level) =>
    if na(level)
        false
    else if breakValidation == "Close"
        close > level
    else if breakValidation == "High/Low (wick)"
        high > level
    else if breakValidation == "Close beyond buffer (ticks)"
        close > level + tickBuf
    else
        close > level * (1 + bufferPercent / 100.0)

f_bearBreakBelow(float level) =>
    if na(level)
        false
    else if breakValidation == "Close"
        close < level
    else if breakValidation == "High/Low (wick)"
        low < level
    else if breakValidation == "Close beyond buffer (ticks)"
        close < level - tickBuf
    else
        close < level * (1 - bufferPercent / 100.0)

// Last broken swing (point 4 — swing ID = bar_index of the swing candle; confirmation bar = bar_index when the break passes the filter)
var int lastBreakSwingBarIndex = na
var float lastBreakSwingPrice = na
var string lastBreakClassification = na
var string lastBreakDirection = na
var int lastBreakDetectBarIndex = na

// Info table — created here; cells are updated at the END (after swing / break logic) so the data is on the same bar
var table infoTable = table.new(position.top_right, 1, 17, bgcolor=color.new(color.blue, 90), border_width=1, border_color=color.new(color.blue, 50))

// Break lines / labels management — FIFO
var array<line> breakLines = array.new<line>()
var array<label> breakLabels = array.new<label>()

f_pushBreakDrawing(x1, y1, x2, y2, lineColor, txt) =>
    if showBreaks
        ln = line.new(x1=x1, y1=y1, x2=x2, y2=y2, xloc=xloc.bar_index, color=lineColor, style=line.style_solid, width=2)
        array.push(breakLines, ln)
        while array.size(breakLines) > maxBreakDrawings
            old = array.get(breakLines, 0)
            line.delete(old)
            array.remove(breakLines, 0)
        if showLabels
            mid = int(math.round((x1 + x2) / 2.0))
            lb = label.new(x=mid, y=y1, xloc=xloc.bar_index, text=txt, color=color.new(lineColor, 75), style=label.style_label_down, textcolor=color.white, size=size.small)
            array.push(breakLabels, lb)
            while array.size(breakLabels) > maxBreakDrawings
                oldL = array.get(breakLabels, 0)
                label.delete(oldL)
                array.remove(breakLabels, 0)

// Williams Fractals calculations
Shunt = waitforclose ? 1 : 0
pvthi_ = ta.pivothigh(high, pvtLenL, pvtLenR)
pvtlo_ = ta.pivotlow(low, pvtLenL, pvtLenR)
pvthi = pvthi_[Shunt]
pvtlo = pvtlo_[Shunt]

// Simple Fractals
isSimpleFractalHigh = true
if simpleFractalPeriod > 0
    for i = 1 to simpleFractalPeriod
        if high[simpleFractalPeriod] <= high[simpleFractalPeriod - i] or high[simpleFractalPeriod] <= high[simpleFractalPeriod + i]
            isSimpleFractalHigh := false
            break

isSimpleFractalLow = true
if simpleFractalPeriod > 0
    for i = 1 to simpleFractalPeriod
        if low[simpleFractalPeriod] >= low[simpleFractalPeriod - i] or low[simpleFractalPeriod] >= low[simpleFractalPeriod + i]
            isSimpleFractalLow := false
            break

// Last values for structure detection
var float lastHighValue = na
var float lastLowValue = na
var float simpleLastHighValue = na
var float simpleLastLowValue = na

// Structure labels
var float higherhigh = na
var float lowerhigh = na
var float higherlow = na
var float lowerlow = na

// Swing tracking — current and previous (pre-CHoCH)
var float swingHighPrice = na
var int swingHighIndex = na
var float swingLowPrice = na
var int swingLowIndex = na

var float prevSwingHighPrice = na
var int prevSwingHighIndex = na
var float prevSwingLowPrice = na
var int prevSwingLowIndex = na

// Trend State: 0=Start, 1=Bullish, -1=Bearish
var int trend = 0

// CHoCH/MSS flags
var bool bullish_choch_happened = false
var bool hl_after_bullish_choch = false
var bool bearish_choch_happened = false
var bool lh_after_bearish_choch = false

// PRE-CHoCH levels for MSS validation
var float pre_choch_swing_high = na
var int pre_choch_swing_high_index = na
var float pre_choch_swing_low = na
var int pre_choch_swing_low_index = na

var bool mss_bullish_occurred = false
var bool mss_bearish_occurred = false

// Reset structure on every bar
higherhigh := na
lowerhigh := na
higherlow := na
lowerlow := na

// PIVOT DETECTION
if pivotMethod == "Simple Fractals"
    if isSimpleFractalHigh
        prevSwingHighPrice := swingHighPrice
        prevSwingHighIndex := swingHighIndex
        swingHighPrice := high[simpleFractalPeriod]
        swingHighIndex := bar_index[simpleFractalPeriod]
        if not na(simpleLastHighValue)
            if high[simpleFractalPeriod] > simpleLastHighValue
                higherhigh := high[simpleFractalPeriod]
            else
                lowerhigh := high[simpleFractalPeriod]
        simpleLastHighValue := high[simpleFractalPeriod]
    else if isSimpleFractalLow
        prevSwingLowPrice := swingLowPrice
        prevSwingLowIndex := swingLowIndex
        swingLowPrice := low[simpleFractalPeriod]
        swingLowIndex := bar_index[simpleFractalPeriod]
        if not na(simpleLastLowValue)
            if low[simpleFractalPeriod] > simpleLastLowValue
                higherlow := low[simpleFractalPeriod]
            else
                lowerlow := low[simpleFractalPeriod]
        simpleLastLowValue := low[simpleFractalPeriod]

else
    if not na(pvthi)
        prevSwingHighPrice := swingHighPrice
        prevSwingHighIndex := swingHighIndex
        swingHighPrice := high[pvtLenR + Shunt]
        swingHighIndex := bar_index[pvtLenR + Shunt]
        currentHighValue = high[pvtLenR + Shunt]
        if not na(lastHighValue)
            if currentHighValue > lastHighValue
                higherhigh := pvthi
            else
                lowerhigh := pvthi
        lastHighValue := currentHighValue
    else if not na(pvtlo)
        prevSwingLowPrice := swingLowPrice
        prevSwingLowIndex := swingLowIndex
        swingLowPrice := low[pvtLenR + Shunt]
        swingLowIndex := bar_index[pvtLenR + Shunt]
        currentLowValue = low[pvtLenR + Shunt]
        if not na(lastLowValue)
            if currentLowValue > lastLowValue
                higherlow := pvtlo
            else
                lowerlow := pvtlo
        lastLowValue := currentLowValue

// Unified MSS tracking (both methods)
if not na(higherlow) and bullish_choch_happened
    hl_after_bullish_choch := true

if not na(lowerhigh) and bearish_choch_happened
    lh_after_bearish_choch := true

// BULLISH BREAK
if not na(swingHighPrice) and f_bullBreakAbove(swingHighPrice)
    breakType = ""

    if trend == -1
        breakType := "CHoCH"
        trend := 1
        bullish_choch_happened := true
        hl_after_bullish_choch := false
        mss_bullish_occurred := false
        pre_choch_swing_high := prevSwingHighPrice
        pre_choch_swing_high_index := prevSwingHighIndex
        bearish_choch_happened := false
        lh_after_bearish_choch := false
        pre_choch_swing_low := na
        pre_choch_swing_low_index := na
        mss_bearish_occurred := false

    else if trend == 1
        bullMss = mssDefinitionMode == "First break after CHoCH" ? not mss_bullish_occurred : (mssDefinitionMode == "First break >= pre-CHoCH level" ? not mss_bullish_occurred and not na(pre_choch_swing_high) and swingHighPrice >= pre_choch_swing_high : not mss_bullish_occurred and hl_after_bullish_choch and not na(pre_choch_swing_high) and swingHighPrice >= pre_choch_swing_high)
        if bullMss
            breakType := "MSS"
            mss_bullish_occurred := true
        else
            breakType := "BOS"

    else
        breakType := "CHoCH"
        trend := 1
        bullish_choch_happened := true
        hl_after_bullish_choch := false
        mss_bullish_occurred := false
        pre_choch_swing_high := prevSwingHighPrice
        pre_choch_swing_high_index := prevSwingHighIndex
        mss_bearish_occurred := false

    lastBreakSwingBarIndex := swingHighIndex
    lastBreakSwingPrice := swingHighPrice
    lastBreakClassification := breakType
    lastBreakDirection := "above swing high"
    lastBreakDetectBarIndex := bar_index
    f_pushBreakDrawing(swingHighIndex, swingHighPrice, bar_index, swingHighPrice, colBull, breakType)
    swingHighPrice := na

// BEARISH BREAK
if not na(swingLowPrice) and f_bearBreakBelow(swingLowPrice)
    breakType = ""

    if trend == 1
        breakType := "CHoCH"
        trend := -1
        bearish_choch_happened := true
        lh_after_bearish_choch := false
        mss_bearish_occurred := false
        pre_choch_swing_low := prevSwingLowPrice
        pre_choch_swing_low_index := prevSwingLowIndex
        bullish_choch_happened := false
        hl_after_bullish_choch := false
        pre_choch_swing_high := na
        pre_choch_swing_high_index := na
        mss_bullish_occurred := false

    else if trend == -1
        bearMss = mssDefinitionMode == "First break after CHoCH" ? not mss_bearish_occurred : (mssDefinitionMode == "First break >= pre-CHoCH level" ? not mss_bearish_occurred and not na(pre_choch_swing_low) and swingLowPrice <= pre_choch_swing_low : not mss_bearish_occurred and lh_after_bearish_choch and not na(pre_choch_swing_low) and swingLowPrice <= pre_choch_swing_low)
        if bearMss
            breakType := "MSS"
            mss_bearish_occurred := true
        else
            breakType := "BOS"

    else
        breakType := "CHoCH"
        trend := -1
        bearish_choch_happened := true
        lh_after_bearish_choch := false
        mss_bearish_occurred := false
        pre_choch_swing_low := prevSwingLowPrice
        pre_choch_swing_low_index := prevSwingLowIndex
        mss_bullish_occurred := false

    lastBreakSwingBarIndex := swingLowIndex
    lastBreakSwingPrice := swingLowPrice
    lastBreakClassification := breakType
    lastBreakDirection := "below swing low"
    lastBreakDetectBarIndex := bar_index
    f_pushBreakDrawing(swingLowIndex, swingLowPrice, bar_index, swingLowPrice, colBear, breakType)
    swingLowPrice := na

// Display offset based on method
displayOffset = pivotMethod == "Williams Fractals" ? -pvtLenR - Shunt : -simpleFractalPeriod

plotshape(showStructure ? higherhigh : na, title="HH", style=shape.triangleup, location=location.abovebar, color=color.new(color.green, 50), text="HH", offset=displayOffset, size=size.auto)
plotshape(showStructure and trend == 1 ? higherlow : na, title="HL", style=shape.triangledown, location=location.belowbar, color=color.new(color.green, 0), text="HL", offset=displayOffset, size=size.auto)
plotshape(showStructure and trend == -1 ? lowerhigh : na, title="LH", style=shape.triangleup, location=location.abovebar, color=color.new(color.red, 0), text="LH", offset=displayOffset, size=size.auto)
plotshape(showStructure ? lowerlow : na, title="LL", style=shape.triangledown, location=location.belowbar, color=color.new(color.red, 50), text="LL", offset=displayOffset, size=size.auto)

// Pattern tracking
var bool hhFound = false
var bool hlFound = false
var bool lhFound = false
var bool llFound = false

if not na(higherhigh)
    hhFound := true
    hlFound := false

if not na(higherlow) and hhFound and trend >= 0
    hlFound := true

if not na(lowerlow)
    llFound := true
    lhFound := false

if not na(lowerhigh) and llFound and trend <= 0
    lhFound := true

hh_hl_hh_pattern = not na(higherhigh) and hlFound
ll_lh_ll_pattern = not na(lowerlow) and lhFound

if hh_hl_hh_pattern
    hhFound := false
    hlFound := false

if ll_lh_ll_pattern
    llFound := false
    lhFound := false

// Info table + debug (last bar, after all calculations)
if barstate.islast
    settingsMode = useAutoSettings ? "Auto Settings" : "Manual Settings"
    settingsColor = useAutoSettings ? color.white : color.orange
    table.cell(infoTable, 0, 0, settingsMode, text_color=settingsColor, text_size=size.small)
    table.cell(infoTable, 0, 1, "TF: " + timeframe.period, text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 2, "L: " + str.tostring(pvtLenL) + " | R: " + str.tostring(pvtLenR), text_color=color.white, text_size=size.small)
    methodText = pivotMethod == "Simple Fractals" ? "Simple Fractals (" + str.tostring(simpleFractalPeriod) + ")" : "Williams Fractals"
    table.cell(infoTable, 0, 3, methodText, text_color=color.yellow, text_size=size.small)
    compactInfo = (useAutoSettings ? "AUTO" : "MANUAL") + " | " + (pivotMethod == "Simple Fractals" ? "SIMPLE" : "WILLIAMS")
    table.cell(infoTable, 0, 4, compactInfo, text_color=color.lime, text_size=size.tiny)
    breakInfo = breakValidation + (breakValidation == "Close beyond buffer (ticks)" ? " (" + str.tostring(bufferTicks) + " tk)" : breakValidation == "Close beyond buffer (%)" ? " (" + str.tostring(bufferPercent) + "%)" : "")
    table.cell(infoTable, 0, 5, breakInfo, text_color=color.aqua, text_size=size.tiny)
    mssDefShort = mssDefinitionMode == "First break after CHoCH" ? "1st break" : (mssDefinitionMode == "First break >= pre-CHoCH level" ? ">=pre" : "legacy")
    mssInfo = "MSS: " + mssDefShort
    table.cell(infoTable, 0, 6, mssInfo, text_color=color.aqua, text_size=size.tiny)
    if showDebug
        table.cell(infoTable, 0, 7, "trend=" + str.tostring(trend), text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 0, 8, "CHoCH bull/HLa=" + str.tostring(bullish_choch_happened) + "/" + str.tostring(hl_after_bullish_choch), text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 0, 9, "preH=" + str.tostring(pre_choch_swing_high, format.mintick), text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 0, 10, "CHoCH bear/LHa=" + str.tostring(bearish_choch_happened) + "/" + str.tostring(lh_after_bearish_choch), text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 0, 11, "preL=" + str.tostring(pre_choch_swing_low, format.mintick), text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 0, 12, "mssB/mssBr=" + str.tostring(mss_bullish_occurred) + "/" + str.tostring(mss_bearish_occurred), text_color=color.white, text_size=size.tiny)
        table.cell(infoTable, 0, 13, "active swH/swL=" + str.tostring(swingHighPrice, format.mintick) + " / " + str.tostring(swingLowPrice, format.mintick), text_color=color.orange, text_size=size.tiny)
        lastBreakSummary = na(lastBreakSwingPrice) ? "Last break: —" : "Last break: " + lastBreakClassification + " | " + lastBreakDirection
        table.cell(infoTable, 0, 14, lastBreakSummary, text_color=color.yellow, text_size=size.tiny)
        lastSwingDetail = na(lastBreakSwingPrice) ? "Swing: —" : "Swing ID (bar_index)=" + str.tostring(lastBreakSwingBarIndex) + " | level=" + str.tostring(lastBreakSwingPrice, format.mintick)
        table.cell(infoTable, 0, 15, lastSwingDetail, text_color=color.yellow, text_size=size.tiny)
        table.cell(infoTable, 0, 16, na(lastBreakSwingPrice) ? "Confirm bar: —" : "Break confirmed on bar_index=" + str.tostring(lastBreakDetectBarIndex), text_color=color.gray, text_size=size.tiny)
    else
        for r = 7 to 16
            table.cell(infoTable, 0, r, "", text_color=color.white, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
// xcelerate.trade promo — center: hidden N min -> visible N s -> hidden N min ...
// Promo state uses `varip` so it isn't wiped by Pine's intra-bar rollback on the
// last bar (with `var`, the 30 s expiration could never trigger).
// ═══════════════════════════════════════════════════════════════════
promoMsg = "For more indicators & strategies visit xcelerate.trade"
promoIntervalMs = promoIntervalMin * 60 * 1000
promoVisibleMs = promoHighlightSec * 1000
var table sitePromoTbl = na
// -1 = inactive phase; otherwise = ms (timenow) when the phase started
varip int promoHiddenAnchorMs = -1
varip int promoVisibleAnchorMs = -1

if showSitePromo and barstate.islast
    if na(sitePromoTbl)
        sitePromoTbl := table.new(position.middle_center, 1, 1, border_width = 0, frame_color = color.new(color.black, 100), bgcolor = color.new(color.black, 100))
    nowMs = na(timenow) ? time_close : timenow
    // Bootstrap: start in "hidden", first appearance after promoIntervalMs
    if promoHiddenAnchorMs < 0 and promoVisibleAnchorMs < 0
        promoHiddenAnchorMs := nowMs
    // First: if in flash, check expiration (otherwise hidden cannot restart correctly on the same tick)
    if promoVisibleAnchorMs >= 0
        if nowMs - promoVisibleAnchorMs >= promoVisibleMs
            promoHiddenAnchorMs := nowMs
            promoVisibleAnchorMs := -1
    else
        // Hidden phase: after interval, start flash
        if promoHiddenAnchorMs >= 0 and nowMs - promoHiddenAnchorMs >= promoIntervalMs
            promoVisibleAnchorMs := nowMs
    showPromoNow = promoVisibleAnchorMs >= 0 and nowMs - promoVisibleAnchorMs < promoVisibleMs
    if showPromoNow
        table.cell(sitePromoTbl, 0, 0, promoMsg, text_color = color.white, text_size = size.large, bgcolor = color.new(color.black, 25), text_halign = text.align_center)
    else
        table.cell(sitePromoTbl, 0, 0, "", bgcolor = color.new(color.black, 100), text_color = color.new(color.white, 100), text_size = size.large)
else if not showSitePromo and not na(sitePromoTbl) and barstate.islast
    promoHiddenAnchorMs := -1
    promoVisibleAnchorMs := -1
    table.cell(sitePromoTbl, 0, 0, "", bgcolor = color.new(color.black, 100), text_color = color.new(color.white, 100), text_size = size.large)

alertcondition(condition=hh_hl_hh_pattern, title="HH-HL-HH Alert", message="HH-HL-HH pattern detected on {{ticker}} at {{interval}}")
alertcondition(condition=ll_lh_ll_pattern, title="LL-LH-LL Alert", message="LL-LH-LL pattern detected on {{ticker}} at {{interval}}")
````
