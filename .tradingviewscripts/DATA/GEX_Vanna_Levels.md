<!-- tradingview-pine-id: PUB;e8159e7ef3c24a418a94eb6884ed025e -->
<!-- tradingviewscripts-format: 1 -->
# GEX / Vanna Levels

Source: https://www.tradingview.com/script/uZgyh2I5-IZIZIZ-IS-GEX-Vanna-Levels/

## Description

GEX / Vanna Levels visualizes manually supplied Vanna and GEX levels directly on the price chart.

+van and -van are displayed as shaded zones, while positive and negative GEX minimum/maximum levels are shown as labeled horizontal lines. All values are entered through a single multiline input field:

[pine]+van: 7469,7542
-van: 7406,7334
+gex-min: 7450
+gex-max: 7506
-gex-min: 7394
-gex-max: 7283[/pine]

The indicator includes individual visibility controls, customizable colors, line width, Vanna-zone transparency, label offset, and optional level values in labels.

This script does not calculate Vanna or GEX—it is intended only for plotting externally derived levels.

---

## Source Code

````pine
//@version=6
indicator(
     "GEX / Vanna Levels",
     shorttitle = "GEX/VAN",
     overlay = true,
     format = format.price,
     max_labels_count = 10
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Input groups
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string GROUP_DATA    = "Level Data"
string GROUP_DISPLAY = "Display"
string GROUP_STYLE   = "Style"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Multiline input
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string levelsInput = input.text_area(
     "- +van: val1,val2\n- -van: val1,val2\n- -gex-min: val\n- -gex-max: val\n- +gex-min: val\n- +gex-max: val",
     "Levels",
     tooltip = "Enter one level per line.\n\nExample:\n- +van: 7450,7480\n- -van: 7390,7415\n- -gex-min: 7388.55\n- -gex-max: 7450.80\n- +gex-min: 7450.38\n- +gex-max: 7563",
     group = GROUP_DATA
)

// Display settings
bool showPlusVan      = input.bool(true, "Show +van", group = GROUP_DISPLAY)
bool showMinusVan     = input.bool(true, "Show -van", group = GROUP_DISPLAY)
bool showNegGexMin    = input.bool(true, "Show -gex-min", group = GROUP_DISPLAY)
bool showNegGexMax    = input.bool(true, "Show -gex-max", group = GROUP_DISPLAY)
bool showPosGexMin    = input.bool(true, "Show +gex-min", group = GROUP_DISPLAY)
bool showPosGexMax    = input.bool(true, "Show +gex-max", group = GROUP_DISPLAY)
bool showValues       = input.bool(false, "Show values in labels", group = GROUP_DISPLAY)

// Style settings
int labelOffset      = input.int(8, "Label offset to the right, bars", minval = 0, maxval = 100, group = GROUP_STYLE)
int lineWidth        = input.int(1, "GEX line width", minval = 1, maxval = 4, group = GROUP_STYLE)
int zoneTransparency = input.int(95, "Vanna zone transparency", minval = 0, maxval = 100, group = GROUP_STYLE)

color plusVanColor    = input.color(color.purple, "+van color", group = GROUP_STYLE)
color minusVanColor   = input.color(color.teal, "-van color", group = GROUP_STYLE)
color negGexColor     = input.color(color.orange, "Negative GEX color", group = GROUP_STYLE)
color posGexColor     = input.color(color.aqua, "Positive GEX color", group = GROUP_STYLE)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Parser
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Finds a key and returns the requested comma-separated value.
//
// Examples:
// f_getLevel(source, "+van", 0) returns the first +van value.
// f_getLevel(source, "+van", 1) returns the second +van value.
// f_getLevel(source, "-gex-min", 0) returns the GEX level.

f_getLevel(string source, string targetKey, int valueIndex) =>
    float result = na
    array<string> rows = str.split(source, "\n")

    for rawRow in rows
        string row = str.replace_all(rawRow, "\r", "")
        row := str.trim(row)

        // Remove an optional Markdown list marker:
        // "- +van: 7450,7480" becomes "+van: 7450,7480".
        if str.startswith(row, "- ")
            row := str.trim(str.substring(row, 2))

        int colonPosition = str.pos(row, ":")

        if not na(colonPosition)
            string parsedKey = str.substring(row, 0, colonPosition)
            parsedKey := str.replace_all(str.trim(parsedKey), " ", "")

            if parsedKey == targetKey
                string valueText = str.substring(row, colonPosition + 1)
                valueText := str.trim(valueText)

                array<string> values = str.split(valueText, ",")

                if array.size(values) > valueIndex
                    string selectedValue = array.get(values, valueIndex)
                    result := str.tonumber(str.trim(selectedValue))

    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Parsed values
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float plusVan1  = f_getLevel(levelsInput, "+van", 0)
float plusVan2  = f_getLevel(levelsInput, "+van", 1)

float minusVan1 = f_getLevel(levelsInput, "-van", 0)
float minusVan2 = f_getLevel(levelsInput, "-van", 1)

float negGexMin = f_getLevel(levelsInput, "-gex-min", 0)
float negGexMax = f_getLevel(levelsInput, "-gex-max", 0)

float posGexMin = f_getLevel(levelsInput, "+gex-min", 0)
float posGexMax = f_getLevel(levelsInput, "+gex-max", 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Validation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool validPlusVan  = showPlusVan and not na(plusVan1) and not na(plusVan2)
bool validMinusVan = showMinusVan and not na(minusVan1) and not na(minusVan2)

bool validNegGexMin = showNegGexMin and not na(negGexMin)
bool validNegGexMax = showNegGexMax and not na(negGexMax)

bool validPosGexMin = showPosGexMin and not na(posGexMin)
bool validPosGexMax = showPosGexMax and not na(posGexMax)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Vanna zones
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plusVanPlot1 = plot(
     validPlusVan ? plusVan1 : na,
     title = "+van boundary 1",
     color = color.new(plusVanColor, 100),
     editable = false
)

plusVanPlot2 = plot(
     validPlusVan ? plusVan2 : na,
     title = "+van boundary 2",
     color = color.new(plusVanColor, 100),
     editable = false
)

fill(
     plusVanPlot1,
     plusVanPlot2,
     color = validPlusVan ? color.new(plusVanColor, zoneTransparency) : na,
     title = "+van zone"
)

minusVanPlot1 = plot(
     validMinusVan ? minusVan1 : na,
     title = "-van boundary 1",
     color = color.new(minusVanColor, 100),
     editable = false
)

minusVanPlot2 = plot(
     validMinusVan ? minusVan2 : na,
     title = "-van boundary 2",
     color = color.new(minusVanColor, 100),
     editable = false
)

fill(
     minusVanPlot1,
     minusVanPlot2,
     color = validMinusVan ? color.new(minusVanColor, zoneTransparency) : na,
     title = "-van zone"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GEX lines
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     validNegGexMin ? negGexMin : na,
     title = "-gex-min",
     color = negGexColor,
     linewidth = lineWidth
)

plot(
     validNegGexMax ? negGexMax : na,
     title = "-gex-max",
     color = negGexColor,
     linewidth = lineWidth
)

plot(
     validPosGexMin ? posGexMin : na,
     title = "+gex-min",
     color = posGexColor,
     linewidth = lineWidth
)

plot(
     validPosGexMax ? posGexMax : na,
     title = "+gex-max",
     color = posGexColor,
     linewidth = lineWidth
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Label text helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_levelText(string levelName, float levelValue) =>
    showValues ? levelName + " " + str.tostring(levelValue, format.mintick) : levelName

f_zoneText(string zoneName, float value1, float value2) =>
    showValues ? zoneName + " " + str.tostring(value1, format.mintick) + "–" + str.tostring(value2, format.mintick) : zoneName

float plusVanMiddle  = validPlusVan ? (plusVan1 + plusVan2) / 2.0 : na
float minusVanMiddle = validMinusVan ? (minusVan1 + minusVan2) / 2.0 : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Labels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label plusVanLabel   = label.new(na, na, "", style = label.style_none)
var label minusVanLabel  = label.new(na, na, "", style = label.style_none)
var label negGexMinLabel = label.new(na, na, "", style = label.style_none)
var label negGexMaxLabel = label.new(na, na, "", style = label.style_none)
var label posGexMinLabel = label.new(na, na, "", style = label.style_none)
var label posGexMaxLabel = label.new(na, na, "", style = label.style_none)

if barstate.islast
    int labelX = bar_index + labelOffset

    label.set_xy(plusVanLabel, labelX, validPlusVan ? plusVanMiddle : na)
    label.set_text(plusVanLabel, validPlusVan ? f_zoneText("+van", plusVan1, plusVan2) : "")
    label.set_textcolor(plusVanLabel, plusVanColor)
    label.set_size(plusVanLabel, size.small)
    label.set_textalign(plusVanLabel, text.align_left)

    label.set_xy(minusVanLabel, labelX, validMinusVan ? minusVanMiddle : na)
    label.set_text(minusVanLabel, validMinusVan ? f_zoneText("-van", minusVan1, minusVan2) : "")
    label.set_textcolor(minusVanLabel, minusVanColor)
    label.set_size(minusVanLabel, size.small)
    label.set_textalign(minusVanLabel, text.align_left)

    label.set_xy(negGexMinLabel, labelX, validNegGexMin ? negGexMin : na)
    label.set_text(negGexMinLabel, validNegGexMin ? f_levelText("-gex-min", negGexMin) : "")
    label.set_textcolor(negGexMinLabel, negGexColor)
    label.set_size(negGexMinLabel, size.small)
    label.set_textalign(negGexMinLabel, text.align_left)

    label.set_xy(negGexMaxLabel, labelX, validNegGexMax ? negGexMax : na)
    label.set_text(negGexMaxLabel, validNegGexMax ? f_levelText("-gex-max", negGexMax) : "")
    label.set_textcolor(negGexMaxLabel, negGexColor)
    label.set_size(negGexMaxLabel, size.small)
    label.set_textalign(negGexMaxLabel, text.align_left)

    label.set_xy(posGexMinLabel, labelX, validPosGexMin ? posGexMin : na)
    label.set_text(posGexMinLabel, validPosGexMin ? f_levelText("+gex-min", posGexMin) : "")
    label.set_textcolor(posGexMinLabel, posGexColor)
    label.set_size(posGexMinLabel, size.small)
    label.set_textalign(posGexMinLabel, text.align_left)

    label.set_xy(posGexMaxLabel, labelX, validPosGexMax ? posGexMax : na)
    label.set_text(posGexMaxLabel, validPosGexMax ? f_levelText("+gex-max", posGexMax) : "")
    label.set_textcolor(posGexMaxLabel, posGexColor)
    label.set_size(posGexMaxLabel, size.small)
    label.set_textalign(posGexMaxLabel, text.align_left)
````
