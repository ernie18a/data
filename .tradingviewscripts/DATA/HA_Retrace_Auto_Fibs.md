<!-- tradingview-pine-id: PUB;02ae80fcf780450d90ab2b68c5a428cf -->
<!-- tradingviewscripts-format: 1 -->
# HA Retrace & Auto Fibs

Source: https://www.tradingview.com/script/xx9pgFMF-Heiken-Ashi-Retrace-Auto-Fibs/

## Description

HA Retrace & Auto Fibs is an automated swing-structure, Fibonacci retracement, and Heikin Ashi support/resistance tool.

The script calculates Heikin Ashi price structure internally, so it can be used on a standard candlestick chart without requiring the chart itself to be switched to Heikin Ashi candles.

The indicator was designed around two related ideas:

Automatically identify meaningful swing pivots and maintain the appropriate Fibonacci retracement for the current price leg.
Identify Heikin Ashi body structures near those pivots that may act as useful retest zones for continuation.
Why Heikin Ashi Support & Resistance?

The HA support/resistance component came from observing that after a meaningful pivot forms, price will often return toward the Heikin Ashi body structure surrounding that pivot before continuing in the direction of the larger move.

These retests can sometimes function as a market check of the recently established structure:

After a pivot low, price may pull back toward the HA support area before attempting another move higher.
After a pivot high, price may rally back toward the HA resistance area before attempting another move lower.

Because of this behavior, these levels can be used as potential long or short entry areas, particularly when the retest aligns with the prevailing structure, Fibonacci retracement levels, momentum, or other forms of confirmation.

The levels are not intended to predict that every retest will hold. Rather, they provide clearly defined areas where traders can watch price behavior for continuation or failure.

Heikin Ashi Support & Resistance Logic

Swing pivots are identified using Heikin Ashi wick structure and a configurable fractal-style pivot method.

The support and resistance levels are then derived separately from the HA candle bodies surrounding the pivot.

By default, the script searches a configurable group of candles around each pivot for the local body structure or "nook" associated with the reversal.

For a pivot high, resistance is placed at the highest relevant HA body bottom near that pivot.

For a pivot low, support uses the mirrored calculation and is placed at the lowest relevant HA body top near that pivot.

This means the S/R level does not necessarily have to come from the exact candle containing the highest or lowest wick. A nearby candle can provide the more meaningful body-based level.

Users can also choose Wick instead of Body placement independently for support and resistance.

Automatic Fibonacci Retracements

The script automatically identifies opposing Heikin Ashi swing pivots and draws Fibonacci retracement levels across the active swing.

For a bullish swing:

0.000 = swing high
1.000 = swing low

For a bearish swing:

0.000 = swing low
1.000 = swing high

Displayed levels include:

0.000 · 0.236 · 0.382 · 0.500 · 0.618 · 0.786 · 1.000

Each Fib is labeled with both its ratio and corresponding price.

When an active swing extends beyond the established pivot, the Fibonacci structure can update with the expanding move until a new opposing pivot establishes the next completed swing structure.

Using the Two Systems Together

The Fib levels and HA support/resistance levels are intentionally calculated as separate structures.

The Fibonacci retracement measures the price range between the swing extremes, while the HA S/R levels identify body-based areas surrounding those pivots.

This can create useful confluence.

For example, during a bullish structure, a pullback into:

HA pivot support,
a meaningful Fib retracement,
and confirming momentum or price action

may provide an area to evaluate for a potential long continuation.

The same concept is mirrored for short setups when price retests HA resistance during a bearish structure.

Features
Works on standard candlestick or Heikin Ashi charts
Internally calculated Heikin Ashi OHLC data
Fractal-style automatic swing detection
Automatic bullish and bearish Fibonacci retracements
Dynamic tracking of an extending price leg
Fib ratio and price labels
Automatic HA-based support and resistance
Local HA body-structure/"nook" detection around pivots
Adjustable number of candles searched around a pivot
Independent Body / Wick selection for support and resistance
Optional pivot markers
Adjustable Fib appearance and transparency
Individual alerts for each Fib retracement
Combined Any Fib Level alert
Optional configurable alert suppression/cooldown
UI-controlled alert() calls for TradingView watchlist and multi-symbol scanning workflows
Alerts

Alerts are available for individual Fibonacci levels as well as an Any Fib Level condition.

Users can configure how a Fib interaction is recognized, including wick touches or closing-price crosses.

An optional suppression setting can prevent repeated alerts for a configurable number of bars after an initial signal.

The script also includes independently selectable alert() function calls, allowing it to be used with TradingView's Any alert() function call option for watchlist and multi-symbol scanning.

Important Note

Heikin Ashi candles use synthetic OHLC values derived from standard market prices. HA candle values therefore may not exactly match the prices displayed by standard candles.

This indicator is intended as a technical-analysis and chart-organization tool. A support, resistance, or Fibonacci interaction is not by itself confirmation that a reversal or continuation will occur. These areas are best evaluated alongside market structure, price action, momentum, volume, and appropriate risk management.

Open-source script. The code is available for users who would like to study the methodology, modify it, or build upon the underlying concepts.

---

## Source Code

````pine
//@version=6
indicator("HA Retrace & Auto Fibs", overlay=true,
     max_lines_count=50, max_labels_count=100, max_bars_back=5000)

// =============================================================================
// HA Retrace & Auto Fibs — v14
//
// Core behavior
// - Uses Heikin Ashi data even on a regular-candle chart.
// - Uses the Combo Lines rolling-window fractal method for structural pivots.
// - Fib and S/R are intentionally decoupled.
// - Fib spans the latest HA pivot WICK swing: low->high for bullish,
//   high->low for bearish. Once the opposite pivot confirms, the swing locks.
// - If that swing later extends beyond its pivot extreme, Fib 0.000 follows
//   each new confirmed HA extreme until another pivot completes.
// - HA support/resistance is drawn from the SAME two pivots defining the Fib.
//   Support defaults to the pivot-low body top; resistance defaults to the
//   pivot-high body bottom. Wick placement remains available in the UI.
// - When a swing extends beyond its last pivot, the broken-side S/R is hidden
//   until a new pivot confirms; the opposite anchor remains visible.
// - Fractal recognition is fixed to HA wicks; S/R placement has independent
//   Body/Wick dropdowns. Body is the default.
// - Body S/R uses a local "nook" search centered on the actual pivot candle:
//   resistance uses the highest body bottom; support uses the lowest body top.
// - By default the nook uses the VISIBLE chart-candle bodies around the HA pivot.
//   Internal Heikin Ashi bodies remain available as an optional S/R body source.
// - Default radius is one candle on each side of the pivot.
// - Right-side Fib labels, individual alerts, combined alerts, optional
//   suppression, and scan-friendly alert() calls.
// =============================================================================

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string pivotGroup = "HEIKEN ASHI FRACTAL PIVOTS"
int fractalPeriod = input.int(15, "Fractals Period", minval=3, maxval=999, step=2,
     group=pivotGroup,
     tooltip="Uses the Combo Lines rolling-window fractal structure. Keep this value odd.", display=display.none)
bool showPivotMarkers = input.bool(false, "Show confirmed pivot markers", group=pivotGroup,
     tooltip="Visual only. Pivot recognition remains active when these markers are hidden.", display=display.none)

string nookGroup = "S/R BODY NOOK SEARCH"
bool useBodyNookSearch = input.bool(true, "Use nearby body nook", group=nookGroup,
     tooltip="When Body is selected for S/R, searches around the pivot candle for the tightest structural body edge. Resistance uses the highest body bottom; support uses the lowest body top. Body source is selected separately under LATEST SUPPORT / RESISTANCE.", display=display.none)
int bodyNookBars = input.int(1, "Bars on each side of pivot", minval=0, maxval=10, group=nookGroup,
     tooltip="Defines the local pivot-body cluster. Default 1 checks exactly three candles: the pivot candle plus one candle before and one after. Resistance uses the highest body bottom; support uses the lowest body top. Increase only when you intentionally want a wider pivot cluster.", display=display.none)

string fibGroup = "SWING FIB RETRACEMENT"
bool showFib = input.bool(true, "Show swing retracement Fib", group=fibGroup, display=display.none)
bool extendFibRight = input.bool(true, "Extend Fib levels right", group=fibGroup, display=display.none)
bool showFibLabels = input.bool(true, "Show Fib labels", group=fibGroup, display=display.none)
int fibLabelOffset = input.int(25, "Right-side label offset bars",
     minval=1, maxval=500, group=fibGroup,
     tooltip="Moves the Fib numbers to the right side of the chart. Increase this if your chart has a wider right margin.", display=display.none)
color fibColor = input.color(color.aqua, "Fib color", group=fibGroup, inline="FIB", display=display.none)
int fibTransparency = input.int(50, "Transparency", minval=0, maxval=100,
     group=fibGroup, inline="FIB", display=display.none)
int fibWidth = input.int(1, "Width", minval=1, maxval=4, group=fibGroup, display=display.none)
string fibStyleInput = input.string("Dotted", "Style",
     options=["Solid", "Dashed", "Dotted"], group=fibGroup, display=display.none)

string srGroup = "LATEST SUPPORT / RESISTANCE"
bool showResistance = input.bool(true, "Show latest resistance", group=srGroup, display=display.none)
string resistanceAnchorInput = input.string("Body", "Resistance anchor",
     options=["Body", "Wick"], group=srGroup,
     tooltip="Body = highest body bottom in the local pivot nook. Wick = HA pivot high. The nook search width is controlled in S/R BODY NOOK SEARCH.", display=display.none)
bool showSupport = input.bool(true, "Show latest support", group=srGroup, display=display.none)
string supportAnchorInput = input.string("Body", "Support anchor",
     options=["Body", "Wick"], group=srGroup,
     tooltip="Body = lowest body top in the local pivot nook. Wick = HA pivot low. The nook search width is controlled in S/R BODY NOOK SEARCH.", display=display.none)
string srBodySourceInput = input.string("Chart candles", "S/R body source",
     options=["Chart candles", "Internal Heikin Ashi"], group=srGroup,
     tooltip="Chart candles uses the bodies visible on the chart around the HA-detected pivot. Internal Heikin Ashi uses the synthetic HA body values calculated by this script. Chart candles is the default.", display=display.none)
color resistanceColor = input.color(color.red, "Resistance", group=srGroup, inline="SRC", display=display.none)
color supportColor = input.color(color.lime, "Support", group=srGroup, inline="SRC", display=display.none)
int srTransparency = input.int(15, "Transparency", minval=0, maxval=100, group=srGroup, display=display.none)
int srWidth = input.int(2, "Width", minval=1, maxval=5, group=srGroup, display=display.none)
string srStyleInput = input.string("Dashed", "Style",
     options=["Solid", "Dashed", "Dotted"], group=srGroup, display=display.none)

string alertGroup = "FIB ALERT OPTIONS"
string fibAlertTrigger = input.string("Chart Wick Touch", "Trigger type",
     options=["Chart Wick Touch", "Chart Close Cross", "HA Wick Touch", "HA Close Cross"],
     group=alertGroup,
     tooltip="Choose how price interaction with an active Fib level is recognized.", display=display.none)
bool useFibAlertSuppression = input.bool(false, "Suppress repeated Fib alerts", group=alertGroup, display=display.none)
int fibAlertSuppressionBars = input.int(8, "Suppression bars", minval=1, maxval=500,
     group=alertGroup,
     tooltip="After one Fib alert, suppresses all additional Fib alerts for this many complete bars.", display=display.none)

string scanGroup = "WATCHLIST SCANNING — ANY ALERT() FUNCTION CALL"
string scanFrequencyInput = input.string("Once Per Bar Close", "alert() frequency",
     options=["All Calls", "Once Per Bar", "Once Per Bar Close"], group=scanGroup, display=display.none)
bool scanAnyFib = input.bool(true, "Any Fib level", group=scanGroup,
     tooltip="Turn this off when using individual level calls to avoid duplicate messages.", display=display.none)
bool scanFib0000 = input.bool(false, "Fib 0.000", group=scanGroup, inline="SCAN1", display=display.none)
bool scanFib0236 = input.bool(false, "Fib 0.236", group=scanGroup, inline="SCAN1", display=display.none)
bool scanFib0382 = input.bool(false, "Fib 0.382", group=scanGroup, inline="SCAN2", display=display.none)
bool scanFib0500 = input.bool(false, "Fib 0.500", group=scanGroup, inline="SCAN2", display=display.none)
bool scanFib0618 = input.bool(false, "Fib 0.618", group=scanGroup, inline="SCAN3", display=display.none)
bool scanFib0786 = input.bool(false, "Fib 0.786", group=scanGroup, inline="SCAN3", display=display.none)
bool scanFib1000 = input.bool(false, "Fib 1.000", group=scanGroup, inline="SCAN4", display=display.none)

string displayGroup = "DISPLAY"
bool showHaCandles = input.bool(false, "Overlay the Heiken Ashi candles used by the tool",
     group=displayGroup, display=display.none)
int haCandleTransparency = input.int(55, "HA candle transparency",
     minval=0, maxval=100, group=displayGroup, display=display.none)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_lineStyle(string styleInput) =>
    styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted : line.style_solid

f_ratioText(float ratio) =>
    ratio == 0.0 ? "0.000" :
     ratio == 1.0 ? "1.000" : str.tostring(ratio, "#.###")

f_levelTriggered(float level, string triggerType, float haH, float haL, float haC) =>
    bool chartWickTouch = not na(level) and high >= level and low <= level
    bool haWickTouch = not na(level) and haH >= level and haL <= level
    bool chartCloseCrossRaw = ta.cross(close, level)
    bool haCloseCrossRaw = ta.cross(haC, level)
    bool chartCloseCross = not na(level) and chartCloseCrossRaw
    bool haCloseCross = not na(level) and haCloseCrossRaw
    triggerType == "Chart Wick Touch" ? chartWickTouch :
     triggerType == "Chart Close Cross" ? chartCloseCross :
     triggerType == "HA Wick Touch" ? haWickTouch : haCloseCross

f_sendScanAlert(bool condition, bool enabled, string message) =>
    if condition and enabled
        if scanFrequencyInput == "All Calls"
            alert(message, alert.freq_all)
        else if scanFrequencyInput == "Once Per Bar"
            alert(message, alert.freq_once_per_bar)
        else
            alert(message, alert.freq_once_per_bar_close)

//------------------------------------------------------------------------------
// Heikin Ashi source — remains HA on a regular-candle chart
//------------------------------------------------------------------------------
// Always derive HA from the underlying STANDARD ticker.
// This prevents the script from inheriting non-standard chart modifiers
// (including an HA chart) and ensures the internal HA bodies match
// TradingView HA values for the underlying symbol exactly once.
string standardTicker = ticker.standard(syminfo.tickerid)
string haTicker = ticker.heikinashi(standardTicker)
[haOpen, haHigh, haLow, haClose] = request.security(
     haTicker,
     timeframe.period,
     [open, high, low, close],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

float haBodyTop = math.max(haOpen, haClose)
float haBodyBottom = math.min(haOpen, haClose)

// S/R body source is intentionally separate from pivot recognition.
// Pivots always use internal HA wicks. Body-based S/R defaults to the candle
// bodies visible on the current chart so the support/resistance "nook" aligns
// with the structure the user is looking at.
float chartBodyTop = math.max(open, close)
float chartBodyBottom = math.min(open, close)
float srBodyTop = srBodySourceInput == "Chart candles" ? chartBodyTop : haBodyTop
float srBodyBottom = srBodySourceInput == "Chart candles" ? chartBodyBottom : haBodyBottom

color haBodyColor = haClose >= haOpen ?
     color.new(color.lime, haCandleTransparency) :
     color.new(color.red, haCandleTransparency)
color haWickColor = color.new(color.gray, haCandleTransparency)

plotcandle(
     showHaCandles ? haOpen : na,
     showHaCandles ? haHigh : na,
     showHaCandles ? haLow : na,
     showHaCandles ? haClose : na,
     title="Tool Heiken Ashi Candles",
     color=haBodyColor,
     wickcolor=haWickColor,
     bordercolor=haBodyColor)

//------------------------------------------------------------------------------
// Combo Lines-style rolling-window fractal recognition
//------------------------------------------------------------------------------
// This preserves the reference Combo Lines center offset.
int fractalMid = int(fractalPeriod / 2) + 1

// Fractal detection and expanding-leg extremes are always based on HA wicks.
// The S/R anchor dropdowns above affect line placement only.
float highPivotSource = haHigh
float lowPivotSource = haLow
float runningHighSource = haHigh
float runningLowSource = haLow

bool fractalHighFound =
     ta.highest(highPivotSource, fractalPeriod) == highPivotSource[fractalMid]
bool fractalLowFound =
     ta.lowest(lowPivotSource, fractalPeriod) == lowPivotSource[fractalMid]

float pivotHigh = fractalHighFound ? highPivotSource[fractalMid] : na
float pivotLow = fractalLowFound ? lowPivotSource[fractalMid] : na

plotshape(
     showPivotMarkers ? pivotHigh : na,
     title="HA Fractal High",
     style=shape.triangledown,
     location=location.absolute,
     color=color.new(resistanceColor, 0),
     size=size.tiny,
     offset=-fractalMid)

plotshape(
     showPivotMarkers ? pivotLow : na,
     title="HA Fractal Low",
     style=shape.triangleup,
     location=location.absolute,
     color=color.new(supportColor, 0),
     size=size.tiny,
     offset=-fractalMid)

//------------------------------------------------------------------------------
// Persistent pivot / S-R / Fib state
//------------------------------------------------------------------------------
// Latest confirmed pivot data. Each pivot keeps its own S/R anchor so that
// when an opposite pivot completes the swing, both S/R lines can be copied
// directly from the exact two pivots used by the Fib.
var float latestHighPrice = na
var int latestHighIndex = na
var float latestHighResistanceLevel = na
var int latestHighResistanceIndex = na

var float latestLowPrice = na
var int latestLowIndex = na
var float latestLowSupportLevel = na
var int latestLowSupportIndex = na

// S/R for the CURRENT Fib swing only. These are deliberately NOT maintained
// as independent latest-high/latest-low levels.
var float swingResistanceLevel = na
var int swingResistanceIndex = na
var float swingSupportLevel = na
var int swingSupportIndex = na

var line resistanceLine = na
var line supportLine = na
var bool resistanceLevelActive = false
var bool supportLevelActive = false

// Fib direction describes the swing being retraced:
//   1  = bullish swing: 1.000 at pivot low, 0.000 at pivot high/live high
//  -1  = bearish swing: 1.000 at pivot high, 0.000 at pivot low/live low
var int activeDirection = 0
var int fibStartIndex = na
var float fibStartPrice = na
var int fibEndIndex = na
var float fibEndPrice = na

var array<float> fibRatios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
var array<float> fibLevels = array.new_float(7, na)
var array<line> fibLines = array.new_line()
var array<label> fibLabels = array.new_label()
var int lastFibAlertBar = na

bool newPivotHigh = not na(pivotHigh)
bool newPivotLow = not na(pivotLow)
bool confirmedBar = barstate.isconfirmed

//------------------------------------------------------------------------------
// Capture confirmed pivot-high.
// IMPORTANT: Fib and S/R use the SAME pivot index but different prices.
// - Fib endpoint = HA pivot wick high.
// - Wick S/R = HA pivot wick high.
// - Body S/R = HIGHEST selected-source body bottom in the local pivot nook.
//   By default this examines exactly the pivot candle plus one candle on
//   either side. This captures dojis and ordinary small-body candles that form
//   the immediate structural nook beneath a pivot top without drifting into
//   unrelated later/earlier price structure.
//------------------------------------------------------------------------------
if newPivotHigh
    int pivotIndexH = bar_index[fractalMid]

    float resistanceLevel = resistanceAnchorInput == "Body" ?
         srBodyBottom[fractalMid] : haHigh[fractalMid]
    int resistanceStartIndex = pivotIndexH

    if resistanceAnchorInput == "Body" and useBodyNookSearch and bodyNookBars > 0
        int maxSearchH = math.min(bodyNookBars, fractalMid - 1)
        if maxSearchH > 0
            for i = 1 to maxSearchH
                int beforeOffsetH = fractalMid + i
                int afterOffsetH = fractalMid - i

                float beforeBodyBottomH = srBodyBottom[beforeOffsetH]
                float afterBodyBottomH = srBodyBottom[afterOffsetH]

                if not na(beforeBodyBottomH) and beforeBodyBottomH > resistanceLevel
                    resistanceLevel := beforeBodyBottomH
                    resistanceStartIndex := bar_index[beforeOffsetH]

                if not na(afterBodyBottomH) and afterBodyBottomH > resistanceLevel
                    resistanceLevel := afterBodyBottomH
                    resistanceStartIndex := bar_index[afterOffsetH]

    // Save this pivot and its own resistance anchor together.
    latestHighPrice := pivotHigh
    latestHighIndex := pivotIndexH
    latestHighResistanceLevel := resistanceLevel
    latestHighResistanceIndex := resistanceStartIndex

    // If the preceding opposite pivot is a low, this high completes a bullish
    // swing. The Fib and BOTH S/R lines are now copied from this exact pair.
    if not na(latestLowIndex) and latestLowIndex < pivotIndexH
        activeDirection := 1
        fibStartIndex := latestLowIndex
        fibStartPrice := latestLowPrice
        fibEndIndex := pivotIndexH
        fibEndPrice := pivotHigh

        swingSupportLevel := latestLowSupportLevel
        swingSupportIndex := latestLowSupportIndex
        swingResistanceLevel := resistanceLevel
        swingResistanceIndex := resistanceStartIndex
        supportLevelActive := not na(swingSupportLevel)
        resistanceLevelActive := not na(swingResistanceLevel)

//------------------------------------------------------------------------------
// Capture confirmed pivot-low.
// - Fib endpoint = HA pivot wick low.
// - Wick S/R = HA pivot wick low.
// - Body S/R mirrors resistance: LOWEST selected-source body top in the local pivot nook.
//------------------------------------------------------------------------------
if newPivotLow
    int pivotIndexL = bar_index[fractalMid]

    float supportLevel = supportAnchorInput == "Body" ?
         srBodyTop[fractalMid] : haLow[fractalMid]
    int supportStartIndex = pivotIndexL

    if supportAnchorInput == "Body" and useBodyNookSearch and bodyNookBars > 0
        int maxSearchL = math.min(bodyNookBars, fractalMid - 1)
        if maxSearchL > 0
            for i = 1 to maxSearchL
                int beforeOffsetL = fractalMid + i
                int afterOffsetL = fractalMid - i

                float beforeBodyTopL = srBodyTop[beforeOffsetL]
                float afterBodyTopL = srBodyTop[afterOffsetL]

                if not na(beforeBodyTopL) and beforeBodyTopL < supportLevel
                    supportLevel := beforeBodyTopL
                    supportStartIndex := bar_index[beforeOffsetL]

                if not na(afterBodyTopL) and afterBodyTopL < supportLevel
                    supportLevel := afterBodyTopL
                    supportStartIndex := bar_index[afterOffsetL]

    // Save this pivot and its own support anchor together.
    latestLowPrice := pivotLow
    latestLowIndex := pivotIndexL
    latestLowSupportLevel := supportLevel
    latestLowSupportIndex := supportStartIndex

    // If the preceding opposite pivot is a high, this low completes a bearish
    // swing. Copy BOTH S/R anchors from the exact Fib pivot pair.
    if not na(latestHighIndex) and latestHighIndex < pivotIndexL
        activeDirection := -1
        fibStartIndex := latestHighIndex
        fibStartPrice := latestHighPrice
        fibEndIndex := pivotIndexL
        fibEndPrice := pivotLow

        swingResistanceLevel := latestHighResistanceLevel
        swingResistanceIndex := latestHighResistanceIndex
        swingSupportLevel := supportLevel
        swingSupportIndex := supportStartIndex
        resistanceLevelActive := not na(swingResistanceLevel)
        supportLevelActive := not na(swingSupportLevel)

//------------------------------------------------------------------------------
// Structural breaks + live swing extension
//------------------------------------------------------------------------------
// A confirmed break through a pivot invalidates that pivot's S/R line.
// It also flips the live Fib when the market breaks the opposite side of the
// most recent completed swing, even before a new opposite fractal confirms.
if confirmedBar
    bool brokeLatestHigh =
         not na(latestHighPrice) and not na(latestHighIndex) and
         bar_index > latestHighIndex and haHigh > latestHighPrice
    bool brokeLatestLow =
         not na(latestLowPrice) and not na(latestLowIndex) and
         bar_index > latestLowIndex and haLow < latestLowPrice

    if brokeLatestHigh
        resistanceLevelActive := false

        // If the last completed swing was bearish (high -> low), a break back
        // above that high establishes a new bullish expanding leg from the
        // latest pivot low to the current HA high. The active green support
        // becomes the S/R anchor belonging to that SAME pivot low.
        if not na(latestLowIndex) and latestHighIndex < latestLowIndex
            activeDirection := 1
            fibStartIndex := latestLowIndex
            fibStartPrice := latestLowPrice
            fibEndIndex := bar_index
            fibEndPrice := haHigh

            swingSupportLevel := latestLowSupportLevel
            swingSupportIndex := latestLowSupportIndex
            supportLevelActive := not na(swingSupportLevel)
            swingResistanceLevel := na
            swingResistanceIndex := na

    if brokeLatestLow
        supportLevelActive := false

        // Mirror: if the last completed swing was bullish (low -> high), a
        // break below that low establishes a bearish expanding leg from the
        // latest pivot high to the current HA low. The active red resistance
        // becomes the S/R anchor belonging to that SAME pivot high.
        if not na(latestHighIndex) and latestLowIndex < latestHighIndex
            activeDirection := -1
            fibStartIndex := latestHighIndex
            fibStartPrice := latestHighPrice
            fibEndIndex := bar_index
            fibEndPrice := haLow

            swingResistanceLevel := latestHighResistanceLevel
            swingResistanceIndex := latestHighResistanceIndex
            resistanceLevelActive := not na(swingResistanceLevel)
            swingSupportLevel := na
            swingSupportIndex := na

    // While a bullish leg is active, keep 1.000 fixed at its pivot-low WICK
    // and move 0.000 only when a new HA high is made.
    if activeDirection == 1 and not na(fibEndPrice) and haHigh > fibEndPrice
        fibEndPrice := haHigh
        fibEndIndex := bar_index

    // While a bearish leg is active, keep 1.000 fixed at its pivot-high WICK
    // and move 0.000 only when a new HA low is made.
    if activeDirection == -1 and not na(fibEndPrice) and haLow < fibEndPrice
        fibEndPrice := haLow
        fibEndIndex := bar_index

//------------------------------------------------------------------------------
// Draw HA support/resistance belonging to the CURRENT Fib pivot pair.
// Support: lowest selected-source body TOP in the pivot-low nook by default.
// Resistance: highest selected-source body BOTTOM in the pivot-high nook.
// Wick mode continues to use the HA pivot wick.
// The S/R anchors remain attached to the same pivots as the active Fib.
//------------------------------------------------------------------------------
if showResistance and resistanceLevelActive and not na(swingResistanceLevel) and not na(swingResistanceIndex)
    if na(resistanceLine)
        resistanceLine := line.new(
             swingResistanceIndex, swingResistanceLevel,
             bar_index, swingResistanceLevel,
             xloc=xloc.bar_index,
             extend=extend.right,
             color=color.new(resistanceColor, srTransparency),
             style=f_lineStyle(srStyleInput),
             width=srWidth)
    else
        line.set_xy1(resistanceLine, swingResistanceIndex, swingResistanceLevel)
        line.set_xy2(resistanceLine, bar_index, swingResistanceLevel)
        line.set_extend(resistanceLine, extend.right)
        line.set_color(resistanceLine, color.new(resistanceColor, srTransparency))
        line.set_style(resistanceLine, f_lineStyle(srStyleInput))
        line.set_width(resistanceLine, srWidth)
else if not na(resistanceLine)
    line.delete(resistanceLine)
    resistanceLine := na

if showSupport and supportLevelActive and not na(swingSupportLevel) and not na(swingSupportIndex)
    if na(supportLine)
        supportLine := line.new(
             swingSupportIndex, swingSupportLevel,
             bar_index, swingSupportLevel,
             xloc=xloc.bar_index,
             extend=extend.right,
             color=color.new(supportColor, srTransparency),
             style=f_lineStyle(srStyleInput),
             width=srWidth)
    else
        line.set_xy1(supportLine, swingSupportIndex, swingSupportLevel)
        line.set_xy2(supportLine, bar_index, swingSupportLevel)
        line.set_extend(supportLine, extend.right)
        line.set_color(supportLine, color.new(supportColor, srTransparency))
        line.set_style(supportLine, f_lineStyle(srStyleInput))
        line.set_width(supportLine, srWidth)
else if not na(supportLine)
    line.delete(supportLine)
    supportLine := na

//------------------------------------------------------------------------------
// Swing Fib calculation and drawing
//------------------------------------------------------------------------------
bool fibReady =
     activeDirection != 0 and
     not na(fibStartPrice) and not na(fibStartIndex) and
     not na(fibEndPrice) and not na(fibEndIndex) and
     fibStartPrice != fibEndPrice

if fibReady
    // 0.000 = swing extreme/end; 1.000 = swing origin.
    // Bull: 0 at high, 1 at low. Bear: 0 at low, 1 at high.
    float fibZeroPrice = fibEndPrice
    float fibOnePrice = fibStartPrice
    float fibRange = fibOnePrice - fibZeroPrice

    int labelX = bar_index + fibLabelOffset
    fibExtend = extendFibRight ? extend.right : extend.none
    color activeFibColor = color.new(fibColor, fibTransparency)
    activeFibStyle = f_lineStyle(fibStyleInput)

    for i = 0 to array.size(fibRatios) - 1
        float ratio = array.get(fibRatios, i)
        float level = fibZeroPrice + fibRange * ratio
        array.set(fibLevels, i, level)

        if showFib
            if array.size(fibLines) <= i
                line newFibLine = line.new(
                     fibStartIndex, level,
                     labelX, level,
                     xloc=xloc.bar_index,
                     extend=fibExtend,
                     color=activeFibColor,
                     style=activeFibStyle,
                     width=fibWidth)
                array.push(fibLines, newFibLine)
            else
                line fibLine = array.get(fibLines, i)
                line.set_xy1(fibLine, fibStartIndex, level)
                line.set_xy2(fibLine, labelX, level)
                line.set_extend(fibLine, fibExtend)
                line.set_color(fibLine, activeFibColor)
                line.set_style(fibLine, activeFibStyle)
                line.set_width(fibLine, fibWidth)

        if showFib and showFibLabels
            string labelText = f_ratioText(ratio) + " (" + str.tostring(level, format.mintick) + ")"
            if array.size(fibLabels) <= i
                label newFibLabel = label.new(
                     labelX, level, labelText,
                     xloc=xloc.bar_index,
                     style=label.style_none,
                     color=color.new(fibColor, 100),
                     textcolor=color.new(fibColor, 0),
                     size=size.small,
                     textalign=text.align_left)
                array.push(fibLabels, newFibLabel)
            else
                label fibLabel = array.get(fibLabels, i)
                label.set_x(fibLabel, labelX)
                label.set_y(fibLabel, level)
                label.set_text(fibLabel, labelText)
                label.set_style(fibLabel, label.style_none)
                label.set_color(fibLabel, color.new(fibColor, 100))
                label.set_textcolor(fibLabel, color.new(fibColor, 0))
                label.set_size(fibLabel, size.small)

// Remove stale Fib objects when disabled or unavailable.
if (not showFib or not fibReady) and array.size(fibLines) > 0
    for i = 0 to array.size(fibLines) - 1
        line.delete(array.get(fibLines, i))
    array.clear(fibLines)

if (not showFib or not showFibLabels or not fibReady) and array.size(fibLabels) > 0
    for i = 0 to array.size(fibLabels) - 1
        label.delete(array.get(fibLabels, i))
    array.clear(fibLabels)

//------------------------------------------------------------------------------
// Fib alert logic
//------------------------------------------------------------------------------
float fib0000 = array.get(fibLevels, 0)
float fib0236 = array.get(fibLevels, 1)
float fib0382 = array.get(fibLevels, 2)
float fib0500 = array.get(fibLevels, 3)
float fib0618 = array.get(fibLevels, 4)
float fib0786 = array.get(fibLevels, 5)
float fib1000 = array.get(fibLevels, 6)

bool rawFib0000 = fibReady and f_levelTriggered(fib0000, fibAlertTrigger, haHigh, haLow, haClose)
bool rawFib0236 = fibReady and f_levelTriggered(fib0236, fibAlertTrigger, haHigh, haLow, haClose)
bool rawFib0382 = fibReady and f_levelTriggered(fib0382, fibAlertTrigger, haHigh, haLow, haClose)
bool rawFib0500 = fibReady and f_levelTriggered(fib0500, fibAlertTrigger, haHigh, haLow, haClose)
bool rawFib0618 = fibReady and f_levelTriggered(fib0618, fibAlertTrigger, haHigh, haLow, haClose)
bool rawFib0786 = fibReady and f_levelTriggered(fib0786, fibAlertTrigger, haHigh, haLow, haClose)
bool rawFib1000 = fibReady and f_levelTriggered(fib1000, fibAlertTrigger, haHigh, haLow, haClose)

bool rawAnyFib = rawFib0000 or rawFib0236 or rawFib0382 or rawFib0500 or
     rawFib0618 or rawFib0786 or rawFib1000

bool fibAlertAllowed =
     not useFibAlertSuppression or na(lastFibAlertBar) or
     bar_index - lastFibAlertBar > fibAlertSuppressionBars

bool alertFib0000 = rawFib0000 and fibAlertAllowed
bool alertFib0236 = rawFib0236 and fibAlertAllowed
bool alertFib0382 = rawFib0382 and fibAlertAllowed
bool alertFib0500 = rawFib0500 and fibAlertAllowed
bool alertFib0618 = rawFib0618 and fibAlertAllowed
bool alertFib0786 = rawFib0786 and fibAlertAllowed
bool alertFib1000 = rawFib1000 and fibAlertAllowed
bool alertAnyFib = rawAnyFib and fibAlertAllowed

if alertAnyFib
    lastFibAlertBar := bar_index

alertcondition(alertFib0000, "Fib 0.000", "{{ticker}} {{interval}} interacted with active Fib 0.000. Close: {{close}}")
alertcondition(alertFib0236, "Fib 0.236", "{{ticker}} {{interval}} interacted with active Fib 0.236. Close: {{close}}")
alertcondition(alertFib0382, "Fib 0.382", "{{ticker}} {{interval}} interacted with active Fib 0.382. Close: {{close}}")
alertcondition(alertFib0500, "Fib 0.500", "{{ticker}} {{interval}} interacted with active Fib 0.500. Close: {{close}}")
alertcondition(alertFib0618, "Fib 0.618", "{{ticker}} {{interval}} interacted with active Fib 0.618. Close: {{close}}")
alertcondition(alertFib0786, "Fib 0.786", "{{ticker}} {{interval}} interacted with active Fib 0.786. Close: {{close}}")
alertcondition(alertFib1000, "Fib 1.000", "{{ticker}} {{interval}} interacted with active Fib 1.000. Close: {{close}}")
alertcondition(alertAnyFib, "Any Fib Level", "{{ticker}} {{interval}} interacted with an active Fib level. Close: {{close}}")

// Dynamic alert() calls for TradingView's "Any alert() function call" option.
string directionText = activeDirection == 1 ? "Bull" : activeDirection == -1 ? "Bear" : "None"
string scanPrefix = syminfo.ticker + " | " + timeframe.period + " | HA Retrace & Auto Fibs " + directionText + " | "

string anyHitText = ""
anyHitText := alertFib0000 ? "0.000" : anyHitText
anyHitText := alertFib0236 ? (str.length(anyHitText) > 0 ? anyHitText + ", 0.236" : "0.236") : anyHitText
anyHitText := alertFib0382 ? (str.length(anyHitText) > 0 ? anyHitText + ", 0.382" : "0.382") : anyHitText
anyHitText := alertFib0500 ? (str.length(anyHitText) > 0 ? anyHitText + ", 0.500" : "0.500") : anyHitText
anyHitText := alertFib0618 ? (str.length(anyHitText) > 0 ? anyHitText + ", 0.618" : "0.618") : anyHitText
anyHitText := alertFib0786 ? (str.length(anyHitText) > 0 ? anyHitText + ", 0.786" : "0.786") : anyHitText
anyHitText := alertFib1000 ? (str.length(anyHitText) > 0 ? anyHitText + ", 1.000" : "1.000") : anyHitText

f_sendScanAlert(alertAnyFib, scanAnyFib,
     scanPrefix + "Fib level(s) " + anyHitText + " | Close " + str.tostring(close, format.mintick))
f_sendScanAlert(alertFib0000, scanFib0000,
     scanPrefix + "Fib 0.000 | Level " + str.tostring(fib0000, format.mintick) + " | Close " + str.tostring(close, format.mintick))
f_sendScanAlert(alertFib0236, scanFib0236,
     scanPrefix + "Fib 0.236 | Level " + str.tostring(fib0236, format.mintick) + " | Close " + str.tostring(close, format.mintick))
f_sendScanAlert(alertFib0382, scanFib0382,
     scanPrefix + "Fib 0.382 | Level " + str.tostring(fib0382, format.mintick) + " | Close " + str.tostring(close, format.mintick))
f_sendScanAlert(alertFib0500, scanFib0500,
     scanPrefix + "Fib 0.500 | Level " + str.tostring(fib0500, format.mintick) + " | Close " + str.tostring(close, format.mintick))
f_sendScanAlert(alertFib0618, scanFib0618,
     scanPrefix + "Fib 0.618 | Level " + str.tostring(fib0618, format.mintick) + " | Close " + str.tostring(close, format.mintick))
f_sendScanAlert(alertFib0786, scanFib0786,
     scanPrefix + "Fib 0.786 | Level " + str.tostring(fib0786, format.mintick) + " | Close " + str.tostring(close, format.mintick))
f_sendScanAlert(alertFib1000, scanFib1000,
     scanPrefix + "Fib 1.000 | Level " + str.tostring(fib1000, format.mintick) + " | Close " + str.tostring(close, format.mintick))
````
