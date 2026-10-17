# Auto Fibonacci Zones

- url: https://www.tradingview.com/script/FyKiHWkZ-Auto-Fibonacci-Zones/
- type: indicator
- pine_id: PUB;e408d9a3408d4717a19544ad005c2eaa
- version: 1.0

## Description

Auto Fibonacci Zones is a visual Fibonacci retracement tool built around confirmed swing pivots.

The script automatically detects the most recent significant swing leg using confirmed pivot highs and pivot lows, then draws Fibonacci retracement levels from that leg. It is designed to reduce the need for manually redrawing Fibonacci levels each time a new swing structure forms.

What the script shows

- Fibonacci retracement levels from the latest confirmed swing leg
- Optional Fibonacci extension levels
- A highlighted 0.5 - 0.618 retracement zone
- A dashed anchor leg showing the selected swing
- A compact state label describing the current retracement condition
- Optional alerts for key retracement events

How it works

The script uses confirmed pivot highs and confirmed pivot lows to define the current swing leg. A new Fibonacci sheet is accepted only when the detected high-low leg is large enough relative to ATR. This helps avoid redrawing levels on very small price movements.

The main retracement levels include:

- 0
- 0.382
- 0.5
- 0.618
- 0.786
- 1

The script can also show optional extension levels:

- 1.272
- 1.618

Extensions are disabled by default because they are reference geometry only and should not be interpreted as price forecasts.

Level sets

The user can choose between three level display modes:

- Core: shows 0, 0.5, 0.618, and 1
- Major: shows the main Fibonacci levels with a cleaner chart layout
- Standard: shows the common retracement levels

Golden zone

The script highlights the area between 0.5 and 0.618. This zone is commonly watched by traders as a retracement area, but it should not be treated as a guaranteed reversal zone or standalone trading signal.

State label

The state label gives a quick reading of the current retracement condition, such as:

- Shallow retracement
- Deep retracement
- Inside 0.5 - 0.618 zone
- Near full retrace
- Full retrace exceeded
- Beyond 0 level

The state label is only a descriptive reading of where price is relative to the current Fibonacci sheet.

Old or inactive sheets

The script includes options to fade older or fully retraced Fibonacci sheets. This helps keep the chart clean when the selected swing leg is no longer fresh or has already been fully retraced.

Main settings

Swing Detection:
- Pivot strength
- Minimum leg height x ATR

Levels:
- Level set
- Show extensions
- Shade 0.5 - 0.618 zone

Display:
- Show anchor leg
- Show level labels
- Show level prices
- Show state label
- State label offset
- Fade old / invalid sheet
- Expire sheet after bars

Lines and colors:
- Level line width
- Key level line width
- Anchor leg width
- Level colors
- Golden zone color
- Extension color
- Label colors
- Transparency controls

Alerts

The script includes alert conditions for:

- Price entering the 0.5 - 0.618 zone
- Price exiting the 0.5 - 0.618 zone
- Price crossing the 0.618 level
- Price touching or exceeding the 1.0 retracement level
- Price retesting the 0 level

These alerts are descriptive chart events. They are not buy or sell signals.

Repainting and confirmation note

This script uses confirmed pivot highs and confirmed pivot lows. A pivot can only be confirmed after the selected pivot-strength bars have passed.

Because of this, Fibonacci anchors appear only after confirmation. When a newer valid swing leg is confirmed, the current Fibonacci sheet can be replaced by the new one.

This is normal confirmation delay for pivot-based tools. The script does not use lookahead, and the levels are based on confirmed swing structure.

Limitations

Fibonacci levels are visual reference levels, not predictive levels.

A price reaction near any Fibonacci level does not guarantee continuation, reversal, support, or resistance.

The selected swing leg is determined automatically by the script. In some cases, a trader may manually choose a different swing leg based on broader market context.

This indicator is intended for chart analysis, education, and visual review of retracement structure. It is not a trading system, financial advice, or a standalone buy/sell tool.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Auto Fibonacci Zones
// ============================================================================
// Draws Fibonacci retracement levels from the most recent confirmed swing leg.
// The script uses confirmed pivot highs/lows, filters small legs with ATR,
// shades the 0.5 - 0.618 zone, and optionally shows extensions.
//
// IMPORTANT MECHANICS
// - Swing anchors are confirmed with ta.pivothigh/ta.pivotlow.
// - A pivot appears only after Pivot strength bars have passed.
// - The sheet is replaced when a newer valid swing leg is confirmed.
// - Levels are descriptive geometry, not buy/sell signals.
// - Extensions are reference geometry, not forecasts.
// ============================================================================

indicator(
     title          = "Auto Fibonacci Zones",
     shorttitle     = "AutoFib",
     overlay        = true,
     max_lines_count = 100,
     max_labels_count = 100,
     max_boxes_count = 50
)

// ============================================================================
// Inputs
// ============================================================================

int piv = input.int(
     defval  = 8,
     title   = "Pivot strength",
     minval  = 2,
     maxval  = 30,
     group   = "1) Swing Detection",
     tooltip = "A swing is confirmed this many bars after it happens. Higher values create larger, cleaner swing legs with more delay."
)

float minHeightAtr = input.float(
     defval  = 3.0,
     title   = "Minimum leg height x ATR",
     minval  = 0.5,
     maxval  = 15.0,
     step    = 0.5,
     group   = "1) Swing Detection",
     tooltip = "A new high-low leg must be at least this tall in ATR(14) units before the Fibonacci sheet re-anchors."
)

string levelMode = input.string(
     defval  = "Major",
     title   = "Level set",
     options = ["Core", "Major", "Standard"],
     group   = "2) Levels",
     tooltip = "Core shows 0, 0.5, 0.618, 1. Major adds 0.382 and 0.786. Standard shows all common retracement levels."
)

bool showExtensions = input.bool(
     defval  = false,
     title   = "Show extensions 1.272 / 1.618",
     group   = "2) Levels",
     tooltip = "Geometric multiples of the leg beyond the 0 line. Reference geometry only, not a forecast. OFF by default."
)

bool showGoldenZone = input.bool(
     defval = true,
     title  = "Shade 0.5 - 0.618 zone",
     group  = "2) Levels"
)

bool showAnchorLeg = input.bool(
     defval = true,
     title  = "Draw anchor leg",
     group  = "3) Display"
)

bool showLevelLabels = input.bool(
     defval = true,
     title  = "Show level labels",
     group  = "3) Display"
)

bool showLevelPrices = input.bool(
     defval = true,
     title  = "Show prices in level labels",
     group  = "3) Display",
     active = showLevelLabels
)

bool showStateLabel = input.bool(
     defval = true,
     title  = "Show state label",
     group  = "3) Display",
     tooltip = "Shows a compact label describing the current retracement state. This replaces the need for a table on the chart."
)

int stateLabelOffsetBars = input.int(
     defval  = 4,
     title   = "State label offset bars",
     minval  = 0,
     maxval  = 80,
     group   = "3) Display",
     active  = showStateLabel,
     tooltip = "Moves the state label to the right of the level labels to reduce overlap."
)

string stateLabelPosition = input.string(
     defval  = "Golden zone",
     title   = "State label position",
     options = ["Golden zone", "Current price"],
     group   = "3) Display",
     active  = showStateLabel,
     tooltip = "Golden zone keeps the state label near the 0.5 - 0.618 area. Current price places it near the latest close."
)

bool fadeInactiveSheet = input.bool(
     defval = false,
     title  = "Fade old / invalid sheet",
     group  = "3) Display",
     tooltip = "OFF by default for clearer lines. When enabled, the Fibonacci sheet fades when it becomes old or when the retracement exceeds the 1.0 level."
)

int expireAfterBars = input.int(
     defval  = 120,
     title   = "Expire sheet after bars",
     minval  = 20,
     maxval  = 1000,
     group   = "3) Display",
     active  = fadeInactiveSheet,
     tooltip = "When the latest confirmed leg is older than this number of bars, the Fibonacci sheet is faded."
)

bool fadeAfterFullRetrace = input.bool(
     defval = true,
     title  = "Fade after full retrace exceeded",
     group  = "3) Display",
     active  = fadeInactiveSheet,
     tooltip = "Fades the sheet when retracement exceeds 100%, because the selected leg has been fully retraced."
)

int inactiveSheetTransparency = input.int(
     defval = 45,
     title  = "Old / invalid sheet transparency",
     minval = 0,
     maxval = 100,
     group  = "3) Display",
     active = fadeInactiveSheet
)

bool showStatusCard = input.bool(
     defval = false,
     title  = "Show status card",
     group  = "3) Display",
     tooltip = "OFF by default to keep the chart clean."
)

int rightExtensionBars = input.int(
     defval  = 8,
     title   = "Extend levels right",
     minval  = 0,
     maxval  = 80,
     group   = "3) Display",
     tooltip = "Extends Fibonacci levels to the right for easier reading."
)

string labelSizeInput = input.string(
     defval  = "Small",
     title   = "Label size",
     options = ["Tiny", "Small", "Normal"],
     group   = "3) Display"
)

int levelLineWidth = input.int(
     defval = 2,
     title  = "Level line width",
     minval = 1,
     maxval = 5,
     group  = "4) Lines"
)

int keyLevelLineWidth = input.int(
     defval = 3,
     title  = "0.5 / 0.618 line width",
     minval = 1,
     maxval = 5,
     group  = "4) Lines"
)

int anchorLineWidth = input.int(
     defval = 2,
     title  = "Anchor leg width",
     minval = 1,
     maxval = 5,
     group  = "4) Lines"
)

string normalLineStyleInput = input.string(
     defval  = "Solid",
     title   = "Normal level style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "4) Lines"
)

string keyLineStyleInput = input.string(
     defval  = "Dashed",
     title   = "0.5 / 0.618 style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "4) Lines"
)

string anchorLineStyleInput = input.string(
     defval  = "Dashed",
     title   = "Anchor leg style",
     options = ["Solid", "Dashed", "Dotted"],
     group   = "4) Lines"
)

color levelColor = input.color(
     defval = color.rgb(115, 126, 142),
     title  = "Standard level color",
     group  = "5) Colors"
)

color goldenColor = input.color(
     defval = color.rgb(212, 180, 131),
     title  = "0.5 / 0.618 color",
     group  = "5) Colors"
)

color extensionColor = input.color(
     defval = color.rgb(66, 150, 145),
     title  = "Extension color",
     group  = "5) Colors"
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

color labelTextColor = input.color(
     defval = color.rgb(20, 24, 30),
     title  = "Level label text color",
     group  = "5) Colors"
)

color stateTextColor = input.color(
     defval = color.white,
     title  = "State label text color",
     group  = "5) Colors"
)

int goldenZoneTransparency = input.int(
     defval = 82,
     title  = "Golden zone transparency",
     minval = 0,
     maxval = 100,
     group  = "5) Colors"
)

int labelBackgroundTransparency = input.int(
     defval = 100,
     title  = "Level label background transparency",
     minval = 0,
     maxval = 100,
     group  = "5) Colors"
)

int hiddenTransparency = 100

// ============================================================================
// Helpers
// ============================================================================

float atr = ta.atr(14)

labelSize =
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Normal" ? size.normal :
     size.small

f_line_style(styleInput) =>
    styleInput == "Dotted" ? line.style_dotted :
     styleInput == "Dashed" ? line.style_dashed :
     line.style_solid

f_visible_level(float f) =>
    bool baseVisible =
         levelMode == "Standard" ?
             (f <= 1.0) :
         levelMode == "Major" ?
             (f == 0.0 or f == 0.382 or f == 0.5 or f == 0.618 or f == 0.786 or f == 1.0) :
             (f == 0.0 or f == 0.5 or f == 0.618 or f == 1.0)

    bool extensionVisible =
         f > 1.0 and showExtensions

    (f <= 1.0 and baseVisible) or extensionVisible

f_level_name(float f) =>
    f > 1.0 ?
         "ext " + str.tostring(f, "0.###") :
         str.tostring(f, "0.###")

f_level_text(float f, float price) =>
    showLevelPrices ?
         f_level_name(f) + "  " + str.tostring(price, format.mintick) :
         f_level_name(f)

f_is_key_level(float f) =>
    f == 0.5 or f == 0.618

f_level_color(float f) =>
    f > 1.0 ? extensionColor :
     f_is_key_level(f) ? goldenColor :
     levelColor

f_apply_inactive(color col, bool inactive) =>
    inactive ? color.new(col, inactiveSheetTransparency) : col

// ============================================================================
// Swing anchors
// ============================================================================

float ph = ta.pivothigh(high, piv, piv)
float pl = ta.pivotlow(low, piv, piv)

var float lastHighValue = na
var int   lastHighBar   = na
var float lastLowValue  = na
var int   lastLowBar    = na

if not na(ph)
    lastHighValue := ph
    lastHighBar   := bar_index - piv

if not na(pl)
    lastLowValue := pl
    lastLowBar   := bar_index - piv

// Accepted leg.
var float anchorHigh = na
var int   anchorHighBar = na
var float anchorLow = na
var int   anchorLowBar = na
var bool  anchorUp = true

bool validNewLeg =
     (not na(ph) or not na(pl)) and
     not na(lastHighValue) and
     not na(lastLowValue) and
     lastHighValue - lastLowValue >= minHeightAtr * atr

if validNewLeg
    anchorHigh    := lastHighValue
    anchorHighBar := lastHighBar
    anchorLow     := lastLowValue
    anchorLowBar  := lastLowBar
    anchorUp      := lastHighBar > lastLowBar

// ============================================================================
// Level calculation
// ============================================================================

f_level_price(float f) =>
    float legRange = anchorHigh - anchorLow
    float result = na

    if not na(anchorHigh) and not na(anchorLow) and legRange > 0.0
        result :=
             f <= 1.0 ?
                 (anchorUp ? anchorHigh - f * legRange : anchorLow + f * legRange) :
                 (anchorUp ? anchorHigh + (f - 1.0) * legRange : anchorLow - (f - 1.0) * legRange)

    result

float level50  = f_level_price(0.5)
float level618 = f_level_price(0.618)
float level786 = f_level_price(0.786)
float level0   = f_level_price(0.0)
float level1   = f_level_price(1.0)

bool haveLeg =
     not na(anchorHigh) and
     not na(anchorLow) and
     anchorHigh > anchorLow

float topGolden = math.max(level50, level618)
float botGolden = math.min(level50, level618)

bool inGoldenZone =
     haveLeg and
     close <= topGolden and
     close >= botGolden

bool enteredGoldenZone =
     inGoldenZone and not inGoldenZone[1]

bool exitedGoldenZone =
     not inGoldenZone and inGoldenZone[1]

bool crossed618 =
     haveLeg and
     not na(level618) and
     not na(level618[1]) and
     ((close > level618 and close[1] <= level618[1]) or
      (close < level618 and close[1] >= level618[1]))

bool fullRetraceTouched =
     haveLeg and
     not na(level1) and
     ((anchorUp and low <= level1) or
      (not anchorUp and high >= level1))

bool zeroRetestTouched =
     haveLeg and
     not na(level0) and
     ((anchorUp and high >= level0) or
      (not anchorUp and low <= level0))

// ============================================================================
// Drawing objects
// ============================================================================

var fibs = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.618)

var array<line>  levelLines = array.new<line>()
var array<label> levelLabels = array.new<label>()

var line  anchorLegLine = na
var box   goldenZoneBox = na
var label stateLabel = na
var table statusCard = na

// ============================================================================
// Drawing
// ============================================================================

if barstate.islast and haveLeg

    int countLevels = array.size(fibs)

    if array.size(levelLines) == 0
        for i = 0 to countLevels - 1
            array.push(levelLines, line.new(bar_index, close, bar_index, close, color=color.new(levelColor, 100)))
            array.push(levelLabels, label.new(bar_index, close, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=color.new(levelColor, 100), size=labelSize))

    int xStart = math.max(anchorHighBar, anchorLowBar)
    int xEnd = bar_index + rightExtensionBars

    float legRange = anchorHigh - anchorLow
    float retracementPercent =
         legRange > 0.0 ?
         (anchorUp ? (anchorHigh - close) / legRange : (close - anchorLow) / legRange) * 100.0 :
         na

    int legEndBar = math.max(anchorHighBar, anchorLowBar)
    int sheetAge = bar_index - legEndBar

    bool sheetOld = sheetAge > expireAfterBars
    bool fullRetraceExceeded = not na(retracementPercent) and retracementPercent > 100.0
    bool sheetInactive =
         fadeInactiveSheet and
         (sheetOld or (fadeAfterFullRetrace and fullRetraceExceeded))

    for i = 0 to countLevels - 1
        float f = array.get(fibs, i)
        float price = f_level_price(f)
        bool visible = f_visible_level(f)
        bool key = f_is_key_level(f)

        color rawColor = f_level_color(f)
        color baseColor = f_apply_inactive(rawColor, sheetInactive)
        color drawColor = visible ? baseColor : color.new(rawColor, hiddenTransparency)
        string styleValue = key ? keyLineStyleInput : normalLineStyleInput
        int widthValue = key ? keyLevelLineWidth : levelLineWidth

        line ln = array.get(levelLines, i)
        label lb = array.get(levelLabels, i)

        line.set_xy1(ln, xStart, price)
        line.set_xy2(ln, xEnd, price)
        line.set_style(ln, f_line_style(styleValue))
        line.set_width(ln, widthValue)
        line.set_color(ln, drawColor)

        label.set_xy(lb, xEnd + 1, price)
        label.set_text(lb, showLevelLabels and visible ? f_level_text(f, price) : "")
        label.set_textcolor(lb, showLevelLabels and visible ? baseColor : color.new(rawColor, hiddenTransparency))
        label.set_color(lb, color.new(color.white, labelBackgroundTransparency))
        label.set_size(lb, labelSize)

    // Golden zone.
    if na(goldenZoneBox)
        goldenZoneBox := box.new(
             left = xStart,
             top = topGolden,
             right = xEnd,
             bottom = botGolden,
             border_color = color.new(goldenColor, 100),
             bgcolor = color.new(goldenColor, goldenZoneTransparency)
        )

    box.set_lefttop(goldenZoneBox, xStart, topGolden)
    box.set_rightbottom(goldenZoneBox, xEnd, botGolden)
    int effectiveGoldenTransparency = sheetInactive ? math.max(goldenZoneTransparency, inactiveSheetTransparency) : goldenZoneTransparency
    box.set_bgcolor(goldenZoneBox, showGoldenZone ? color.new(goldenColor, effectiveGoldenTransparency) : color.new(goldenColor, 100))
    box.set_border_color(goldenZoneBox, color.new(goldenColor, 100))

    // Anchor leg.
    color legColor = anchorUp ? upLegColor : downLegColor

    if na(anchorLegLine)
        anchorLegLine := line.new(
             x1 = anchorLowBar,
             y1 = anchorLow,
             x2 = anchorHighBar,
             y2 = anchorHigh,
             color = legColor,
             style = f_line_style(anchorLineStyleInput),
             width = anchorLineWidth
        )

    line.set_xy1(anchorLegLine, anchorLowBar, anchorLow)
    line.set_xy2(anchorLegLine, anchorHighBar, anchorHigh)
    color effectiveLegColor = f_apply_inactive(legColor, sheetInactive)
    line.set_color(anchorLegLine, showAnchorLeg ? effectiveLegColor : color.new(legColor, hiddenTransparency))
    line.set_style(anchorLegLine, f_line_style(anchorLineStyleInput))
    line.set_width(anchorLegLine, anchorLineWidth)

    // State label.
    string stateText =
         sheetOld ? "Old Fibonacci sheet" :
         fullRetraceExceeded ? "Full retrace exceeded" :
         inGoldenZone ? "Inside 0.5 - 0.618 zone" :
         retracementPercent < 0 ? "Beyond 0 level" :
         retracementPercent < 50 ? "Shallow retracement" :
         retracementPercent <= 78.6 ? "Deep retracement" :
         retracementPercent <= 100 ? "Near full retrace" :
         "Full retrace exceeded"

    color stateColor =
         sheetInactive ? color.rgb(120, 120, 120) :
         inGoldenZone ? goldenColor :
         retracementPercent > 100 ? downLegColor :
         legColor

    float stateY =
         stateLabelPosition == "Current price" ? close :
         anchorUp ? topGolden : botGolden

    string stateLabelText =
         stateText + "\nRetrace: " + str.tostring(retracementPercent, "0") + "%" +
         (sheetOld ? "\nAge: " + str.tostring(sheetAge) + " bars" : "")

    if showStateLabel
        if na(stateLabel)
            stateLabel := label.new(
                 x = xEnd + 1 + stateLabelOffsetBars,
                 y = stateY,
                 text = stateLabelText,
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = color.new(stateColor, 12),
                 textcolor = stateTextColor,
                 size = labelSize
            )
        else
            label.set_x(stateLabel, xEnd + 1 + stateLabelOffsetBars)
            label.set_y(stateLabel, stateY)
            label.set_text(stateLabel, stateLabelText)
            label.set_color(stateLabel, color.new(stateColor, 12))
            label.set_textcolor(stateLabel, stateTextColor)
            label.set_size(stateLabel, labelSize)
    else
        if not na(stateLabel)
            label.delete(stateLabel)
            stateLabel := na

    // Optional card. Kept OFF by default.
    if showStatusCard
        if na(statusCard)
            statusCard := table.new(
                 position = position.bottom_right,
                 columns = 1,
                 rows = 4,
                 bgcolor = color.new(color.rgb(20, 25, 34), 12),
                 frame_width = 1,
                 frame_color = color.new(levelColor, 70)
            )

        float legPercent =
             anchorUp ? (anchorHigh / anchorLow - 1.0) * 100.0 :
             (anchorLow / anchorHigh - 1.0) * 100.0

        int legBars = math.abs(anchorHighBar - anchorLowBar)

        table.cell(statusCard, 0, 0, "AUTO FIB", text_color=goldenColor, text_size=size.small)
        table.cell(statusCard, 0, 1, "Leg: " + (anchorUp ? "UP " : "DOWN ") + (legPercent >= 0 ? "+" : "") + str.tostring(legPercent, "0.0") + "% / " + str.tostring(legBars) + " bars", text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
        table.cell(statusCard, 0, 2, "Retrace: " + str.tostring(retracementPercent, "0") + "%", text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
        table.cell(statusCard, 0, 3, stateText, text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    else
        if not na(statusCard)
            table.delete(statusCard)
            statusCard := na

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     enteredGoldenZone,
     title   = "Golden zone entered",
     message = "Auto Fibonacci Zones: price entered the 0.5 - 0.618 retracement zone of the current confirmed leg."
)

alertcondition(
     exitedGoldenZone,
     title   = "Golden zone exited",
     message = "Auto Fibonacci Zones: price exited the 0.5 - 0.618 retracement zone of the current confirmed leg."
)

alertcondition(
     crossed618,
     title   = "0.618 crossed",
     message = "Auto Fibonacci Zones: price crossed the 0.618 retracement level of the current confirmed leg."
)

alertcondition(
     fullRetraceTouched,
     title   = "Full retrace touched",
     message = "Auto Fibonacci Zones: price touched or exceeded the 1.0 retracement level of the current confirmed leg."
)

alertcondition(
     zeroRetestTouched,
     title   = "0 level retested",
     message = "Auto Fibonacci Zones: price retested the 0 level of the current confirmed leg."
)

// ============================================================================
// End of file
// ============================================================================
````
