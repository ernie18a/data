<!-- tradingview-pine-id: PUB;998395ec0ca842a495c72d6fadea745d -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_Research_Utilities

Source: https://www.tradingview.com/script/MZUTy7lj-XZ-Research-Utilities/

## Description

Library  "XZ_Research_Utilities"
Generic descriptive-statistics and two-column research-table utilities. Contains no XZ trading methodology or analytical authority.

resolvePosition(key)
  Resolves a normalized table-position key.
  Parameters:
    key (string): Position key.
  Returns: Pine table position constant.

resolveTextSize(key)
  Resolves a normalized text-size key.
  Parameters:
    key (string): Size key.
  Returns: Pine size constant.

countEqual(values, target)
  Counts values equal to a target.
  Parameters:
    values (array<int>): Integer observations.
    target (int): Target value.
  Returns: Matching observation count.

countPositive(values)
  Counts values greater than zero.
  Parameters:
    values (array<int>): Integer observations.
  Returns: Positive observation count.

countAtLeast(values, threshold)
  Counts values at or above a threshold.
  Parameters:
    values (array<int>): Integer observations.
    threshold (int): Inclusive threshold.
  Returns: Observation count at/above threshold.

sumInt(values)
  Sums integer observations.
  Parameters:
    values (array<int>): Integer observations.
  Returns: Sum.

selectedStat(values, mode)
  Returns Median or Mean from float observations.
  Parameters:
    values (array<float>): Float observations.
    mode (string): "Median" or "Mean".
  Returns: Selected descriptive statistic or na for an empty sample.

number(value, suffix)
  Formats a numeric result with an optional suffix.
  Parameters:
    value (float): Numeric result.
    suffix (string): Suffix such as d or %.
  Returns: Formatted number or em dash for na.

percent(numerator, denominator)
  Formats numerator/denominator as a percentage.
  Parameters:
    numerator (int): Numerator.
    denominator (int): Denominator.
  Returns: Percentage or em dash when denominator is zero.

createTable(positionKey, rows, backgroundColor, lineColor, showLines)
  Creates a two-column research table.
  Parameters:
    positionKey (string): Normalized table-position key.
    rows (int): Row count.
    backgroundColor (color): Background colour.
    lineColor (color): Frame/border colour.
    showLines (bool): Whether frame and borders are visible.
  Returns: Table handle.

header(id, leftText, rightText, accentColor, textColor, backgroundColor, textSize, leftTooltip, rightTooltip)
  Writes the two-column research header.
  Parameters:
    id (table): Table handle.
    leftText (string): Left header text.
    rightText (string): Right header text.
    accentColor (color): Accent colour.
    textColor (color): Neutral text colour.
    backgroundColor (color): Shared background.
    textSize (string): Normalized text-size key.
    leftTooltip (string): Left-cell tooltip.
    rightTooltip (string): Right-cell tooltip.
  Returns: True after rendering.

row(id, row, labelText, valueText, textColor, accentColor, backgroundColor, textSize, tooltipText, accentValue)
  Writes one label/value research row.
  Parameters:
    id (table): Table handle.
    row (int): Row index.
    labelText (string): Left label.
    valueText (string): Right value.
    textColor (color): Neutral text colour.
    accentColor (color): Optional emphasized value colour.
    backgroundColor (color): Shared background.
    textSize (string): Normalized text-size key.
    tooltipText (string): Shared metric-definition tooltip.
    accentValue (bool): Whether the right value uses accent colour.
  Returns: True after rendering.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign

//@version=6
//@description Generic descriptive-statistics and two-column research-table utilities. Contains no XZ trading methodology or analytical authority.
library("XZ_Research_Utilities", true)

//@function Resolves a normalized table-position key.
//@param key Position key.
//@returns Pine table position constant.
export resolvePosition(string key) =>
    switch key
        "top_left" => position.top_left
        "top_center" => position.top_center
        "top_right" => position.top_right
        "middle_left" => position.middle_left
        "middle_center" => position.middle_center
        "middle_right" => position.middle_right
        "bottom_left" => position.bottom_left
        "bottom_center" => position.bottom_center
        => position.bottom_right

//@function Resolves a normalized text-size key.
//@param key Size key.
//@returns Pine size constant.
export resolveTextSize(string key) =>
    switch str.lower(key)
        "tiny" => size.tiny
        "small" => size.small
        "large" => size.large
        "huge" => size.huge
        => size.normal

//@function Counts values equal to a target.
//@param values Integer observations.
//@param target Target value.
//@returns Matching observation count.
export countEqual(array<int> values, int target) =>
    int count = 0
    int n = array.size(values)
    if n > 0
        for i = 0 to n - 1
            if array.get(values, i) == target
                count += 1
    count

//@function Counts values greater than zero.
//@param values Integer observations.
//@returns Positive observation count.
export countPositive(array<int> values) =>
    int count = 0
    int n = array.size(values)
    if n > 0
        for i = 0 to n - 1
            if array.get(values, i) > 0
                count += 1
    count

//@function Counts values at or above a threshold.
//@param values Integer observations.
//@param threshold Inclusive threshold.
//@returns Observation count at/above threshold.
export countAtLeast(array<int> values, int threshold) =>
    int count = 0
    int n = array.size(values)
    if n > 0
        for i = 0 to n - 1
            if array.get(values, i) >= threshold
                count += 1
    count

//@function Sums integer observations.
//@param values Integer observations.
//@returns Sum.
export sumInt(array<int> values) =>
    int total = 0
    int n = array.size(values)
    if n > 0
        for i = 0 to n - 1
            total += array.get(values, i)
    total

//@function Returns Median or Mean from float observations.
//@param values Float observations.
//@param mode "Median" or "Mean".
//@returns Selected descriptive statistic or na for an empty sample.
export selectedStat(array<float> values, string mode) =>
    array.size(values) == 0 ? na : mode == "Median" ? array.median(values) : array.avg(values)

//@function Formats a numeric result with an optional suffix.
//@param value Numeric result.
//@param suffix Suffix such as d or %.
//@returns Formatted number or em dash for na.
export number(float value, string suffix) =>
    na(value) ? "—" : str.tostring(value, "#.##") + suffix

//@function Formats numerator/denominator as a percentage.
//@param numerator Numerator.
//@param denominator Denominator.
//@returns Percentage or em dash when denominator is zero.
export percent(int numerator, int denominator) =>
    denominator <= 0 ? "—" : str.tostring(float(numerator) / float(denominator) * 100.0, "#.##") + "%"

//@function Creates a two-column research table.
//@param positionKey Normalized table-position key.
//@param rows Row count.
//@param backgroundColor Background colour.
//@param lineColor Frame/border colour.
//@param showLines Whether frame and borders are visible.
//@returns Table handle.
export createTable(
     string positionKey,
     int rows,
     color backgroundColor,
     color lineColor,
     bool showLines
 ) =>
    table.new(
         resolvePosition(positionKey),
         2,
         rows,
         bgcolor=backgroundColor,
         border_color=lineColor,
         border_width=showLines ? 1 : 0,
         frame_color=lineColor,
         frame_width=showLines ? 1 : 0
     )

//@function Writes the two-column research header.
//@param id Table handle.
//@param leftText Left header text.
//@param rightText Right header text.
//@param accentColor Accent colour.
//@param textColor Neutral text colour.
//@param backgroundColor Shared background.
//@param textSize Normalized text-size key.
//@param leftTooltip Left-cell tooltip.
//@param rightTooltip Right-cell tooltip.
//@returns True after rendering.
export header(
     table id,
     string leftText,
     string rightText,
     color accentColor,
     color textColor,
     color backgroundColor,
     string textSize,
     string leftTooltip,
     string rightTooltip
 ) =>
    string resolvedSize = resolveTextSize(textSize)
    table.cell(id, 0, 0, leftText, text_color=accentColor, bgcolor=backgroundColor, text_size=resolvedSize, text_halign=text.align_left, tooltip=leftTooltip)
    table.cell(id, 1, 0, rightText, text_color=textColor, bgcolor=backgroundColor, text_size=resolvedSize, text_halign=text.align_right, tooltip=rightTooltip)
    true

//@function Writes one label/value research row with independent tooltip channels.
//@param id Table handle.
//@param row Row index.
//@param labelText Left label.
//@param valueText Right value.
//@param textColor Neutral text colour.
//@param accentColor Optional emphasized value colour.
//@param backgroundColor Shared background.
//@param textSize Normalized text-size key.
//@param labelTooltip Definition/decoder tooltip for the metric label.
//@param valueTooltip Optional value-specific tooltip. Pass an empty string when the displayed value is self-explanatory.
//@param accentValue Whether the right value uses accent colour.
//@returns True after rendering.
export row(
     table id,
     int row,
     string labelText,
     string valueText,
     color textColor,
     color accentColor,
     color backgroundColor,
     string textSize,
     string labelTooltip,
     string valueTooltip,
     bool accentValue
 ) =>
    table.cell(id, 0, row, labelText, text_color=textColor, bgcolor=backgroundColor, text_size=resolveTextSize(textSize), text_halign=text.align_left, tooltip=labelTooltip)
    table.cell(id, 1, row, valueText, text_color=accentValue ? accentColor : textColor, bgcolor=backgroundColor, text_size=resolveTextSize(textSize), text_halign=text.align_right, tooltip=valueTooltip)
    true

//@function Renders a sequence of two-column research rows.
export rows(
     table id, int startRow,
     array<string> labels, array<string> values, array<string> tooltips, array<bool> accents,
     color textColor, color accentColor, color backgroundColor, string textSize
 ) =>
    int n = math.min(array.size(labels), math.min(array.size(values), math.min(array.size(tooltips), array.size(accents))))
    if n > 0
        for i = 0 to n - 1
            row(
                 id, startRow + i,
                 array.get(labels, i), array.get(values, i),
                 textColor, accentColor, backgroundColor, textSize,
                 array.get(tooltips, i), "", array.get(accents, i)
             )
    startRow + n

//@function Converts an integer array to a float array preserving order.
export intArrayToFloat(array<int> values) =>
    array<float> result = array.new_float()
    if array.size(values) > 0
        for i = 0 to array.size(values) - 1
            array.push(result, float(array.get(values, i)))
    result
````
