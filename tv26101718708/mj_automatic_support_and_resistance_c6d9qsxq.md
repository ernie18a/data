# MJ Automatic Support and Resistance

- url: https://www.tradingview.com/script/C6D9QsXq-MJ-Automatic-Support-and-Resistance/
- type: indicator
- pine_id: PUB;d1775a7ce698498786919ab0928ca091
- version: 2.0

## Description

MJ Automatic Support & Resistance

MJ Automatic Support & Resistance is a chart-based indicator designed to automatically identify and display key support and resistance levels using confirmed pivot highs and pivot lows.

The indicator recalculates based on the active chart timeframe, so the levels automatically update when switching between intraday, daily, or higher timeframes.

Key Features

. Automatically detects support and resistance levels
. Works across all chart timeframes
. Uses confirmed pivot highs and lows
. Separate color controls for support and resistance
. Separate line-thickness controls for support and resistance
. Adjustable pivot sensitivity
. Optional merging of nearby levels
. Adjustable maximum number of displayed levels
. Minimum-touch filter for stronger levels
. Solid, dashed, and dotted line options
. Adjustable line transparency
. Optional price labels
. Optional removal of broken levels
. Adjustable ATR-based breakout confirmation buffer
. Ability to show or hide support and resistance independently

How It Works

Resistance levels are created from confirmed pivot highs, while support levels are created from confirmed pivot lows.

When multiple pivots form near the same price, the indicator can merge them into one level using an ATR-based distance filter. The level price is then averaged as additional touches are detected.

Users can also require a minimum number of touches before a level becomes visible, helping reduce weaker or less-tested levels.

Important Note

Pivot-based levels require future candles to confirm. Because of this, a new support or resistance level will appear only after the selected pivot-strength period has passed.

A higher Pivot Strength generally produces fewer but stronger levels. A lower Pivot Strength produces more levels and reacts faster to short-term price structure.

Suggested Settings

For a balanced chart:

Pivot Strength: 5
Maximum Levels: 30–50
Merge Nearby Levels: Enabled
Merge Distance: 0.20 ATR
Minimum Touches: 1–2
Support Thickness: 2
Resistance Thickness: 2

Lower pivot-strength settings may be more suitable for short-term trading, while higher settings may be better suited for swing trading and higher-timeframe analysis.

Disclaimer

This indicator is intended for technical analysis and educational purposes only. Support and resistance levels are not guaranteed to hold. Traders should combine the indicator with proper risk management, price action, volume, market structure, and other forms of confirmation before making trading decisions

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MJPascal

//@version=6
indicator(
     title = "MJInvesting Support and Resistance",
     shorttitle = "MJ S/R",
     overlay = true,
     precision = 4,
     max_lines_count = 100,
     max_labels_count = 100
)

//-----------------------
// Parameters
//-----------------------

float source = close

string group = "Style"

string typ1 = "Solid"
string typ2 = "Dashed"
string typ3 = "Dotted"

string ext1 = "Left"
string ext2 = "None"

string alert1 = "Once per Bar"
string alert2 = "Once per Bar Close"

int maxline = input.int(
     defval = 15,
     title = "No. of S&R Lines",
     minval = 1,
     maxval = 20,
     tooltip = "No. of each S & R\n20 means 20 Resistance and 20 Support"
)

float atr_size = input.float(
     defval = 1.5,
     title = "Range Size",
     minval = 0.1,
     maxval = 10.0,
     step = 0.1,
     tooltip = "Smaller Number indicates tighter range\nMin Val=0.1\nMax Val = 10.0"
)

bool disp_rguide = input.bool(
     defval = true,
     title = "Range Guide",
     tooltip = "Display Range Size guide to find next bigger/smaller range at bottom left of the chart"
)

string in_ext = input.string(
     defval = ext1,
     title = "Line Extension",
     group = group,
     options = [ext1, ext2]
)

string c_style = input.string(
     defval = typ1,
     title = "Cardinal Cross Style",
     group = group,
     options = [typ1, typ2, typ3]
)

string o_style = input.string(
     defval = typ3,
     title = "Ordinal Cross Style",
     group = group,
     options = [typ1, typ2, typ3]
)

color g_col = input.color(
     defval = color.new(#606060, 35),
     title = "Line Color",
     group = group
)

string alert_typ = input.string(
     defval = alert2,
     title = "Alert Frequency",
     group = "Alert",
     options = [alert1, alert2]
)

//-----------------------
// Line styles
//-----------------------

cardinal = c_style == typ1
     ? line.style_solid
     : c_style == typ2
     ? line.style_dashed
     : line.style_dotted

ordinal = o_style == typ1
     ? line.style_solid
     : o_style == typ2
     ? line.style_dashed
     : line.style_dotted

ext_type = in_ext == ext1
     ? extend.left
     : extend.none

//-----------------------
// Generate Gann Square of 9 sequence
//-----------------------

int table_size = 1200

var array<float> gann_table = array.new_float()

var int val = 1
var int increment = 1
var int diag_check = 3

if barstate.isfirst
    array.push(gann_table, 1.0)

    for cnt = 0 to table_size - 1
        val += increment

        array.push(
             gann_table,
             float(val)
        )

        if val == int(math.pow(diag_check, 2))
            increment += 1
            diag_check += 2

//-----------------------
// Functions
//-----------------------

get_mult(float value, float adjustment) =>
    float initial = 0.00001
    float result = initial
    float check = na
    int count = 0

    for i = 0 to 12
        check := adjustment * (
             initial * math.pow(10.0, i)
        )

        count += 1

        if value < check
            result := 100.0 / (
                 initial * math.pow(10.0, i)
            )

            break

    [result, count]

get_idx(float srcValue) =>
    int exactIndex = array.indexof(
         gann_table,
         srcValue
    )

    int resistanceIndex = na

    if exactIndex != -1
        resistanceIndex := exactIndex + 1
    else
        int arraySize = array.size(gann_table)

        if arraySize > 0
            for cnt = 0 to arraySize - 1
                float temporaryValue = array.get(
                     gann_table,
                     cnt
                )

                if temporaryValue > srcValue
                    resistanceIndex := cnt
                    break

    if na(resistanceIndex)
        resistanceIndex := array.size(gann_table) - 1

    resistanceIndex

f_line(float yLocation, int levelIndex) =>
    line.new(
         x1 = bar_index - 50,
         y1 = yLocation,
         x2 = bar_index + 10,
         y2 = yLocation,
         xloc = xloc.bar_index,
         style = levelIndex % 2 == 1
              ? cardinal
              : ordinal,
         extend = ext_type,
         color = g_col
    )

f_label(string labelText, float yLocation) =>
    label.new(
         x = bar_index + 10,
         y = yLocation,
         xloc = xloc.bar_index,
         text = labelText,
         color = color.new(color.black, 100),
         textcolor = g_col,
         size = size.normal,
         style = label.style_label_left,
         textalign = text.align_left
    )

//-----------------------
// Main-calculation storage
//-----------------------

varip int r_loc = na
varip int s_loc = na

varip float r1 = na
varip float s1 = na

varip array<float> r_list = array.new_float()
varip array<float> s_list = array.new_float()

var array<line> g_line = array.new_line()
var array<label> g_lbl = array.new_label()

varip float curr_size = na
varip float prev_size = na

varip int run_num = 0
varip int count_run = 0

//-----------------------
// Range calculations
//-----------------------

float atr = ta.sma(
     ta.tr(true),
     30
)

int lookback = math.max(
     math.min(bar_index, 20),
     1
)

float rangeValue = na

float range2 = (
     ta.highest(high, lookback) -
     ta.lowest(low, lookback)
)

float mult = na
float src = na

float min_range = atr[1] * atr_size

//-----------------------
// Reset on each new bar
//-----------------------

if barstate.isnew
    run_num := 0
    count_run := 0

    r_loc := na
    r1 := na

    s_loc := na
    s1 := na

    curr_size := na
    prev_size := na

    array.clear(r_list)
    array.clear(s_list)

//-----------------------
// Calculate levels
//-----------------------

if barstate.islast and run_num == 0
    run_num += 1

    // Original loop:
    // for i = 0.0 to 4.5 by 0.5
    //
    // Pine v6 uses an integer loop and calculates
    // the decimal value inside the loop.

    for stepIndex = 0 to 9
        float i = float(stepIndex) * 0.5

        for j = 1 to 10
            rangeValue := atr * (
                 float(j) * 3.0
            )

            [calculatedMultiplier, executionCount] = get_mult(
                 nz(rangeValue, range2),
                 5.0 - i
            )

            mult := calculatedMultiplier

            src := math.floor(
                 source * mult
            )

            r_loc := get_idx(src)
            s_loc := r_loc - 1

            bool validResistanceIndex =
                 r_loc >= 0 and
                 r_loc < array.size(gann_table)

            bool validSupportIndex =
                 s_loc >= 0 and
                 s_loc < array.size(gann_table)

            if validResistanceIndex and validSupportIndex
                r1 := math.round_to_mintick(
                     array.get(
                          gann_table,
                          r_loc
                     ) / mult
                )

                s1 := math.round_to_mintick(
                     array.get(
                          gann_table,
                          s_loc
                     ) / mult
                )

                count_run += 1
                curr_size := r1 - s1

            if not na(curr_size) and
                 not na(min_range) and
                 curr_size >= min_range

                break

            prev_size := curr_size

        if not na(curr_size) and
             not na(min_range) and
             curr_size >= min_range

            break

    if not na(r_loc) and
         not na(s_loc) and
         not na(mult) and
         mult != 0

        for i = 0 to maxline - 1
            int resistanceIndex = r_loc + i
            int supportIndex = s_loc - i

            float r_val = na
            float s_val = na

            bool validResistance =
                 resistanceIndex >= 0 and
                 resistanceIndex < table_size

            bool validSupport =
                 supportIndex >= 0 and
                 supportIndex < table_size

            if validResistance
                r_val := math.round_to_mintick(
                     array.get(
                          gann_table,
                          resistanceIndex
                     ) / mult
                )

            if validSupport
                s_val := math.round_to_mintick(
                     array.get(
                          gann_table,
                          supportIndex
                     ) / mult
                )

            if not na(r_val)
                array.push(
                     r_list,
                     r_val
                )

            if not na(s_val)
                array.push(
                     s_list,
                     s_val
                )

//-----------------------
// Support and resistance drawing
//-----------------------

int r_size = array.size(r_list)
int s_size = array.size(s_list)

if barstate.islast
    while array.size(g_line) > 0
        line oldLine = array.shift(g_line)

        if not na(oldLine)
            line.delete(oldLine)

    while array.size(g_lbl) > 0
        label oldLabel = array.shift(g_lbl)

        if not na(oldLabel)
            label.delete(oldLabel)

    if r_size > 0 and not na(r_loc)
        for i = 0 to r_size - 1
            float resistanceLevel = array.get(
                 r_list,
                 i
            )

            array.push(
                 g_line,
                 f_line(
                      resistanceLevel,
                      r_loc + i
                 )
            )

            array.push(
                 g_lbl,
                 f_label(
                      "(" +
                      str.tostring(
                           resistanceLevel,
                           format.mintick
                      ) +
                      ")",
                      resistanceLevel
                 )
            )

    if s_size > 0 and not na(s_loc)
        for i = 0 to s_size - 1
            float supportLevel = array.get(
                 s_list,
                 i
            )

            array.push(
                 g_line,
                 f_line(
                      supportLevel,
                      s_loc - i
                 )
            )

            array.push(
                 g_lbl,
                 f_label(
                      "(" +
                      str.tostring(
                           supportLevel,
                           format.mintick
                      ) +
                      ")",
                      supportLevel
                 )
            )

//-----------------------
// Alerts
//-----------------------

bool alertup =
     not na(r1) and
     (
          ta.crossover(close, r1) or
          (
               close[1] < close and
               close == r1
          )
     )

bool alertdn =
     not na(s1) and
     (
          ta.crossunder(close, s1) or
          (
               close[1] > close and
               close == s1
          )
     )

string alerttxt = ""

if alertup
    alerttxt :=
         "Cross Above " +
         str.tostring(
              r1,
              format.mintick
         )

if alertdn
    alerttxt :=
         "Cross Below " +
         str.tostring(
              s1,
              format.mintick
         )

string alert_freq =
     alert_typ == alert1
     ? alert.freq_once_per_bar
     : alert.freq_once_per_bar_close

if alertup or alertdn
    alert(
         alerttxt,
         alert_freq
    )

//-----------------------
// Range-guideline table
//-----------------------

var table PTable = table.new(
     position = position.bottom_left,
     columns = 2,
     rows = 2
)

float previousRangeRatio =
     not na(prev_size) and
     not na(atr[1]) and
     atr[1] != 0
     ? prev_size / atr[1]
     : na

float nextRangeRatio =
     not na(curr_size) and
     not na(atr[1]) and
     atr[1] != 0
     ? curr_size / atr[1]
     : na

string prv_range =
     not na(previousRangeRatio) and
     previousRangeRatio > 0.1
     ? str.tostring(
          previousRangeRatio,
          "0.00"
     )
     : "Not Available"

string nxt_range =
     not na(nextRangeRatio) and
     nextRangeRatio < 10 and
     count_run < 80
     ? str.tostring(
          nextRangeRatio,
          "0.00"
     )
     : "Not Available"

if barstate.islast
    if disp_rguide
        table.cell(
             PTable,
             0,
             0,
             text = "Previous Range: ",
             text_color = g_col,
             text_halign = text.align_left,
             text_size = size.small
        )

        table.cell(
             PTable,
             1,
             0,
             text = "< " + prv_range,
             text_color = g_col,
             text_halign = text.align_left,
             text_size = size.small
        )

        table.cell(
             PTable,
             0,
             1,
             text = "Next Range: ",
             text_color = g_col,
             text_halign = text.align_left,
             text_size = size.small
        )

        table.cell(
             PTable,
             1,
             1,
             text = "> " + nxt_range,
             text_color = g_col,
             text_halign = text.align_left,
             text_size = size.small
        )
    else
        table.clear(
             PTable,
             0,
             0,
             1,
             1
        )
````
