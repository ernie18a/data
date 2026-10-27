# Auto Swing Ruler

- url: https://www.tradingview.com/script/Cq00j5bo-Auto-Swing-Ruler/
- type: indicator
- pine_id: PUB;dfb3ce5245504166aaa8fe71cd48503f
- version: 1.0

## Description

Auto Swing Ruler is a visual measurement tool that automatically identifies confirmed price swings and measures each completed leg directly on the chart.

Its purpose is to replace repeated manual use of the measuring tool by displaying compact information for each swing, including movement size, duration, historical rank, and optional volume participation.

The indicator does not generate buy or sell signals. It is designed to help users compare the structure, speed, and relative importance of price swings.

HOW SWINGS ARE DETECTED

The script uses confirmed pivot highs and pivot lows to construct an alternating swing chain.

A pivot is confirmed only after the number of bars selected in the Pivot strength setting has passed on its right side.

When two consecutive pivots are of the same type, the script retains the more extreme value:

- For consecutive pivot highs, the higher pivot is retained.
- For consecutive pivot lows, the lower pivot is retained.

This prevents the swing chain from creating unnecessary same-direction segments.

Higher Pivot strength values identify broader and cleaner swings, while lower values produce more frequent and shorter swing legs.

LEG MEASUREMENTS

Each confirmed swing leg can display the following information:

- Percentage movement or ATR multiples.
- Duration in bars.
- Historical percentile rank.
- Relative volume during the leg.

Example:

+12.4% / 14b / P85 / V1.3x

This means:

- The leg advanced by 12.4%.
- The movement lasted 14 bars.
- Its absolute size ranked at approximately the 85th percentile of the stored completed-leg history.
- Average volume during the leg was approximately 1.3 times the current 50-bar average volume.

Users can choose between two measurement modes:

1. Percent

Displays the percentage change between the beginning and end of the swing leg.

2. ATR multiples

Displays the absolute price movement divided by ATR(14), allowing swing size to be viewed relative to recent volatility.

HISTORICAL PERCENTILE

The script stores the absolute percentage size of up to the most recent 100 finalized legs.

Before adding a newly completed leg to the history, the indicator compares its size with the existing stored legs and calculates its percentile rank.

A reading such as P85 means that the leg was larger than approximately 85% of the stored comparison legs.

The percentile is a descriptive ranking of historical swing size. It is not a probability, success rate, or prediction of future price movement.

VOLUME RATIO

When enabled, the indicator calculates the average volume recorded during the completed leg and compares it with the current 50-bar average volume.

For example:

- V1.5x means average volume during the leg was approximately 1.5 times the reference average.
- V0.8x means average volume during the leg was below the reference average.

The volume field is skipped when usable volume data is unavailable. Volume comparisons may also be less meaningful on markets that provide synthetic, tick-based, or incomplete volume.

PROVISIONAL AND FINALIZED LEGS

A newly detected leg remains provisional until the next opposite pivot is confirmed.

Provisional measurements are prefixed with the ~ symbol because the current same-direction extreme may still be replaced by a more extreme pivot.

For example:

~+6.8% / 9b

When the next opposite pivot is confirmed, the previous leg becomes finalized. Its endpoint, line, and measurement label are then fixed during normal chart operation.

LIVE LEG

The optional dashed live line connects the latest confirmed pivot to the current closing price.

It provides a real-time visual estimate of the movement currently developing after the latest confirmed pivot.

The live leg is not a confirmed swing. Its size, direction, endpoint, and duration can change while price develops.

An optional state label can display the live percentage movement, bar count, and percentile comparison. This label is disabled by default to keep the chart clean.

VISUAL-DENSITY CONTROLS

The indicator includes several options designed to reduce chart clutter:

- Show or hide all completed-leg labels.
- Show or hide movement size.
- Show or hide bar count.
- Show or hide percentile rank.
- Show or hide volume ratio.
- Show or hide the live leg.
- Show or hide the live state label.
- Select label size.
- Limit the number of completed legs displayed on the chart.
- Adjust swing-line width and style.
- Select separate colors for rising and falling legs.

The Visible completed legs setting limits only the number of drawings shown on the chart. Historical leg measurements used by the percentile calculation are stored separately.

The default display shows movement size and bar count, while percentile rank, volume ratio, and the state label are disabled to maintain a cleaner chart.

ALERTS

The indicator provides alert conditions for:

- A newly confirmed swing high.
- A newly confirmed swing low.
- A finalized leg reaching or exceeding the selected Big leg alert percentile.

The Big leg alert requires at least ten finalized legs in the stored history before it can trigger.

REPAINTING AND CONFIRMATION

Auto Swing Ruler uses confirmed pivots.

Because a pivot requires future bars on its right side, swing points appear with a natural delay equal to the selected Pivot strength.

The current provisional leg may extend or change when a more extreme same-direction pivot is confirmed.

The live leg changes continuously because it connects the latest confirmed pivot to the current market price.

After an opposite pivot confirms and a leg becomes finalized, its stored measurement and drawing are no longer modified during normal chart operation.

Changing the symbol, timeframe, Pivot strength, measurement settings, or available chart history causes the script to recalculate its swing structure.

LIMITATIONS

Pivot-based swing detection is inherently delayed and is not intended to identify turning points at the exact moment they occur.

Lower Pivot strength settings may create many small legs in volatile or sideways markets. Higher settings may omit smaller price movements.

ATR measurements use the ATR value available when the leg is finalized rather than an average ATR calculated across the full leg.

The volume ratio compares the leg's average volume with the 50-bar volume average available when the leg is finalized.

Percentile results depend on the completed legs available in the loaded chart history and should not be treated as universal market statistics.

Auto Swing Ruler is a visual measurement and historical-comparison tool. It does not forecast future price direction, place orders, or provide standalone trading recommendations.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Auto Swing Ruler
// ============================================================================
// Automates the measuring tape: every confirmed swing leg is drawn as a
// zigzag segment and labeled with what you would measure by hand - the
// percent move, the number of bars, how the leg ranks against recent legs,
// and its volume versus average.
//
// IMPORTANT MECHANICS
// - Swings are confirmed with ta.pivothigh/ta.pivotlow (Pivot strength bars
//   of delay). A leg label is PROVISIONAL (prefixed with ~) until the next
//   opposite swing confirms, because a same-direction extreme can still
//   extend the leg. Finalized labels never change afterwards.
// - The percentile ranks the leg size against up to the last 100 finalized
//   legs on this chart. It is a description of the past, not a signal.
// - Visual-density controls allow users to limit completed drawings and hide
//   optional label fields without changing the swing-detection logic.
// - This tool measures. It does not predict.
// ============================================================================

indicator(
     title          = "Auto Swing Ruler",
     shorttitle     = "SwingRuler",
     overlay        = true,
     max_lines_count = 500,
     max_labels_count = 500
)

max_bars_back(volume, 500)

// ============================================================================
// Inputs
// ============================================================================

int piv = input.int(
     defval  = 8,
     title   = "Pivot strength",
     minval  = 2,
     maxval  = 50,
     group   = "1) Swing Detection",
     tooltip = "A swing is confirmed this many bars after it happens. Higher values measure larger, cleaner legs."
)

string measureMode = input.string(
     defval  = "Percent",
     title   = "Measure legs in",
     options = ["Percent", "ATR multiples"],
     group   = "2) Ruler"
)

int bigLegPercentile = input.int(
     defval  = 80,
     title   = "Big leg alert percentile",
     minval  = 50,
     maxval  = 99,
     group   = "2) Ruler",
     tooltip = "The Big leg alert fires when a finalized leg is at or above this percentile of the stored leg history (needs at least 10 finalized legs)."
)

bool showLegLabels = input.bool(
     defval  = true,
     title   = "Show leg labels",
     group   = "3) Display",
     tooltip = "Displays compact measurements on swing legs. Turn OFF for a line-only view."
)

bool showPct = input.bool(
     defval = true,
     title  = "Show size (% or ATR)",
     group  = "3) Display",
     active = showLegLabels
)

bool showBars = input.bool(
     defval = true,
     title  = "Show bar count",
     group  = "3) Display",
     active = showLegLabels
)

bool showPercentile = input.bool(
     defval = false,
     title  = "Show percentile rank",
     group  = "3) Display",
     active = showLegLabels,
     tooltip = "OFF by default to reduce text density. Enable it when historical ranking is needed."
)

bool showVolume = input.bool(
     defval  = false,
     title   = "Show volume ratio",
     group   = "3) Display",
     active  = showLegLabels,
     tooltip = "OFF by default to reduce text density. Average volume during the leg versus the 50-bar average volume. Skipped on symbols without volume."
)

bool showLiveLeg = input.bool(
     defval = true,
     title  = "Show live (unconfirmed) leg",
     group  = "3) Display"
)

bool showStateLabel = input.bool(
     defval = false,
     title  = "Show state label",
     group  = "3) Display",
     tooltip = "Optional compact label describing the current live leg. OFF by default to keep the chart clean."
)

int stateLabelOffsetBars = input.int(
     defval  = 4,
     title   = "State label offset bars",
     minval  = 0,
     maxval  = 80,
     group   = "3) Display",
     active  = showStateLabel
)

string labelSizeInput = input.string(
     defval  = "Tiny",
     title   = "Label size",
     options = ["Tiny", "Small", "Normal"],
     group   = "3) Display",
     active  = showLegLabels or showStateLabel
)

int visibleCompletedLegs = input.int(
     defval  = 20,
     title   = "Visible completed legs",
     minval  = 3,
     maxval  = 150,
     group   = "3) Display",
     tooltip = "Limits only the drawings shown on the chart. Historical measurements used by percentile calculations are still retained separately."
)

int legWidth = input.int(
     defval = 2,
     title  = "Leg line width",
     minval = 1,
     maxval = 5,
     group  = "4) Lines"
)

string legStyleInput = input.string(
     defval  = "Solid",
     title   = "Leg line style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "4) Lines"
)

color upLegColor = input.color(
     defval = color.rgb(72, 166, 126),
     title  = "Up leg color",
     group  = "5) Colors"
)

color downLegColor = input.color(
     defval = color.rgb(201, 91, 101),
     title  = "Down leg color",
     group  = "5) Colors"
)

color stateTextColor = input.color(
     defval = color.white,
     title  = "State label text color",
     group  = "5) Colors"
)

// ============================================================================
// Helpers
// ============================================================================

float atr = ta.atr(14)
float volSma = ta.sma(nz(volume), 50)

labelSize =
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Normal" ? size.normal :
     size.small

f_line_style(styleInput) =>
    styleInput == "Dotted" ? line.style_dotted :
     styleInput == "Dashed" ? line.style_dashed :
     line.style_solid

f_leg_text(float legPct, float atrMult, int legBars, float pctile, float volRatio, bool provisional) =>
    string t = provisional ? "~" : ""
    if showPct
        t := t + (measureMode == "ATR multiples" and not na(atrMult) ?
             str.tostring(atrMult, "0.0") + "A" :
             (legPct >= 0 ? "+" : "") + str.tostring(legPct, "0.0") + "%")
    if showBars
        t := t + (t == "" or t == "~" ? "" : " / ") + str.tostring(legBars) + "b"
    if showPercentile and not na(pctile)
        t := t + (t == "" or t == "~" ? "" : " / ") + "P" + str.tostring(pctile, "0")
    if showVolume and not na(volRatio)
        t := t + (t == "" or t == "~" ? "" : " / ") + "V" + str.tostring(volRatio, "0.0") + "x"
    t

// ============================================================================
// Alternating pivot chain
// ============================================================================

float ph = ta.pivothigh(high, piv, piv)
float pl = ta.pivotlow(low, piv, piv)

var array<float> chainPrice  = array.new<float>()
var array<int>   chainBar    = array.new<int>()
var array<bool>  chainIsHigh = array.new<bool>()

bool pushedHigh   = false
bool pushedLow    = false
bool replacedLast = false

if not na(ph)
    int n = array.size(chainPrice)
    if n > 0 and array.get(chainIsHigh, n - 1)
        if ph > array.get(chainPrice, n - 1)
            array.set(chainPrice, n - 1, ph)
            array.set(chainBar, n - 1, bar_index - piv)
            replacedLast := true
    else
        array.push(chainPrice, ph)
        array.push(chainBar, bar_index - piv)
        array.push(chainIsHigh, true)
        pushedHigh := true

if not na(pl)
    int n = array.size(chainPrice)
    if n > 0 and not array.get(chainIsHigh, n - 1)
        if pl < array.get(chainPrice, n - 1)
            array.set(chainPrice, n - 1, pl)
            array.set(chainBar, n - 1, bar_index - piv)
            replacedLast := true
    else
        array.push(chainPrice, pl)
        array.push(chainBar, bar_index - piv)
        array.push(chainIsHigh, false)
        pushedLow := true

while array.size(chainPrice) > 40
    array.shift(chainPrice)
    array.shift(chainBar)
    array.shift(chainIsHigh)

// ============================================================================
// Leg finalization and provisional leg upkeep
// ============================================================================

var array<float> legSizeArr = array.new<float>()   // abs % sizes of finalized legs

var array<line>  finalizedLines  = array.new<line>()
var array<label> finalizedLabels = array.new<label>()

var line  provLine  = na
var label provLabel = na

bool  newLegFinalized = false
float finalizedPctile = na

int n = array.size(chainPrice)

// A new pushed pivot locks the PREVIOUS leg (between elements n-3 and n-2).
if (pushedHigh or pushedLow) and n >= 3
    float p1 = array.get(chainPrice, n - 3)
    int   b1 = array.get(chainBar, n - 3)
    float p2 = array.get(chainPrice, n - 2)
    int   b2 = array.get(chainBar, n - 2)

    float legPct = (p2 / p1 - 1.0) * 100.0
    int   legBars = b2 - b1
    float atrMult = not na(atr) and atr > 0 ? math.abs(p2 - p1) / atr : na
    float absPct = math.abs(legPct)

    // Percentile vs stored history (before adding this leg).
    int cnt = array.size(legSizeArr)
    int below = 0
    if cnt > 0
        for i = 0 to cnt - 1
            if array.get(legSizeArr, i) <= absPct
                below += 1
    float pctile = cnt > 0 ? below * 100.0 / cnt : na

    // Volume during the leg vs 50-bar average (inline history loop).
    float volRatio = na
    int startOff = bar_index - b1
    int endOff = bar_index - b2
    if not na(volume) and startOff < 480 and startOff > endOff
        float volSum = 0.0
        for t = endOff to startOff
            volSum += nz(volume[t])
        float legAvgVol = volSum / (startOff - endOff + 1)
        volRatio := not na(volSma) and volSma > 0 ? legAvgVol / volSma : na

    array.push(legSizeArr, absPct)
    if array.size(legSizeArr) > 100
        array.shift(legSizeArr)

    newLegFinalized := true
    finalizedPctile := pctile

    // Stamp the provisional objects with final values, then release them.
    color finalCol = legPct >= 0 ? upLegColor : downLegColor
    if not na(provLine)
        line.set_xy1(provLine, b1, p1)
        line.set_xy2(provLine, b2, p2)
        line.set_color(provLine, finalCol)
        array.push(finalizedLines, provLine)

    if not na(provLabel)
        label.set_xy(provLabel, math.round((b1 + b2) / 2.0), (p1 + p2) / 2.0)
        label.set_text(provLabel, f_leg_text(legPct, atrMult, legBars, pctile, volRatio, false))
        label.set_textcolor(provLabel, finalCol)
        array.push(finalizedLabels, provLabel)

    while array.size(finalizedLines) > visibleCompletedLegs
        line.delete(array.shift(finalizedLines))

    while array.size(finalizedLabels) > visibleCompletedLegs
        label.delete(array.shift(finalizedLabels))

    provLine := na
    provLabel := na

// A push also opens a NEW provisional leg (n-2 -> n-1).
if (pushedHigh or pushedLow) and n >= 2
    float p1 = array.get(chainPrice, n - 2)
    int   b1 = array.get(chainBar, n - 2)
    float p2 = array.get(chainPrice, n - 1)
    int   b2 = array.get(chainBar, n - 1)
    float legPct = (p2 / p1 - 1.0) * 100.0
    float atrMult = not na(atr) and atr > 0 ? math.abs(p2 - p1) / atr : na
    color legCol = legPct >= 0 ? upLegColor : downLegColor
    provLine := line.new(b1, p1, b2, p2, color = legCol, width = legWidth, style = f_line_style(legStyleInput))

    if showLegLabels
        provLabel := label.new(
             math.round((b1 + b2) / 2.0),
             (p1 + p2) / 2.0,
             f_leg_text(legPct, atrMult, b2 - b1, na, na, true),
             style = label.style_none,
             textcolor = legCol,
             size = labelSize
        )
    else
        provLabel := na

// A replacement extends the current provisional leg.
if replacedLast and n >= 2 and not na(provLine)
    float p1 = array.get(chainPrice, n - 2)
    int   b1 = array.get(chainBar, n - 2)
    float p2 = array.get(chainPrice, n - 1)
    int   b2 = array.get(chainBar, n - 1)
    float legPct = (p2 / p1 - 1.0) * 100.0
    float atrMult = not na(atr) and atr > 0 ? math.abs(p2 - p1) / atr : na
    color legCol = legPct >= 0 ? upLegColor : downLegColor
    line.set_xy2(provLine, b2, p2)
    line.set_color(provLine, legCol)
    if not na(provLabel)
        label.set_xy(provLabel, math.round((b1 + b2) / 2.0), (p1 + p2) / 2.0)
        label.set_text(provLabel, f_leg_text(legPct, atrMult, b2 - b1, na, na, true))
        label.set_textcolor(provLabel, legCol)

bool bigLeg =
     newLegFinalized and
     not na(finalizedPctile) and
     array.size(legSizeArr) > 10 and
     finalizedPctile >= bigLegPercentile

// ============================================================================
// Live leg and state label
// ============================================================================

var line  liveLine   = na
var label stateLabel = na

if barstate.islast and n >= 1
    float lastP = array.get(chainPrice, n - 1)
    int   lastB = array.get(chainBar, n - 1)
    float livePct = (close / lastP - 1.0) * 100.0
    int   liveBars = bar_index - lastB
    color liveCol = livePct >= 0 ? upLegColor : downLegColor

    if showLiveLeg
        if na(liveLine)
            liveLine := line.new(lastB, lastP, bar_index, close, color = liveCol, width = 1, style = line.style_dashed)
        line.set_xy1(liveLine, lastB, lastP)
        line.set_xy2(liveLine, bar_index, close)
        line.set_color(liveLine, liveCol)
    else
        if not na(liveLine)
            line.delete(liveLine)
            liveLine := na

    // Live percentile vs history.
    float liveAbs = math.abs(livePct)
    int cnt = array.size(legSizeArr)
    int below = 0
    if cnt > 0
        for i = 0 to cnt - 1
            if array.get(legSizeArr, i) <= liveAbs
                below += 1
    float livePctile = cnt > 0 ? below * 100.0 / cnt : na

    string stateText =
         "Live leg: " + (livePct >= 0 ? "+" : "") + str.tostring(livePct, "0.0") + "% / " + str.tostring(liveBars) + "b" +
         (not na(livePctile) ? "\nvs last " + str.tostring(cnt) + " legs: P" + str.tostring(livePctile, "0") : "\nNo leg history yet")

    if showStateLabel
        if na(stateLabel)
            stateLabel := label.new(
                 x = bar_index + 1 + stateLabelOffsetBars,
                 y = close,
                 text = stateText,
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = color.new(liveCol, 12),
                 textcolor = stateTextColor,
                 size = labelSize
            )
        else
            label.set_x(stateLabel, bar_index + 1 + stateLabelOffsetBars)
            label.set_y(stateLabel, close)
            label.set_text(stateLabel, stateText)
            label.set_color(stateLabel, color.new(liveCol, 12))
            label.set_textcolor(stateLabel, stateTextColor)
            label.set_size(stateLabel, labelSize)
    else
        if not na(stateLabel)
            label.delete(stateLabel)
            stateLabel := na

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     pushedHigh,
     title   = "New swing high confirmed",
     message = "Auto Swing Ruler: a new swing high has been confirmed."
)

alertcondition(
     pushedLow,
     title   = "New swing low confirmed",
     message = "Auto Swing Ruler: a new swing low has been confirmed."
)

alertcondition(
     bigLeg,
     title   = "Big leg finalized",
     message = "Auto Swing Ruler: a finalized leg ranked at or above the big-leg percentile of recent history."
)

// ============================================================================
// End of file
// ============================================================================
````
