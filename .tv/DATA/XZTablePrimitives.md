<!-- tradingview-pine-id: PUB;ec18f9439b25436aada937e94156dc38 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_Table_Primitives

Source: https://www.tradingview.com/script/592r4vCs-XZ-Table-Primitives/

## Description

Library  "XZ_Table_Primitives"
Generic Pine table construction and cell-rendering primitives for XZ scripts. Contains no trading methodology or analytical authority.

resolvePosition(key)
  Resolves a normalized position key to a Pine table position.
  Parameters:
    key (string): Position key: top_left, top_center, top_right, middle_left, middle_center, middle_right, bottom_left, bottom_center or bottom_right.
  Returns: Pine position constant.

resolveTextSize(key)
  Resolves a normalized text-size key to a Pine size constant.
  Parameters:
    key (string): Text-size key: tiny, small, normal, large or huge.
  Returns: Pine size constant.

create(positionKey, columns, rows, backgroundColor, frameColor, frameWidth)
  Creates a table using caller-supplied presentation values.
  Parameters:
    positionKey (string): Normalized table position key.
    columns (int): Number of columns.
    rows (int): Number of rows.
    backgroundColor (color): Table background color.
    frameColor (color): Table frame color.
    frameWidth (int): Table frame width.
  Returns: New table handle.

clearRegion(id, firstColumn, firstRow, lastColumn, lastRow)
  Clears a rectangular region of an existing table.
  Parameters:
    id (table): Table handle.
    firstColumn (int): First column index.
    firstRow (int): First row index.
    lastColumn (int): Last column index.
    lastRow (int): Last row index.
  Returns: True after clearing.

cell(id, column, row, cellText, textColor, backgroundColor, textSize, horizontalAlign, tooltipText)
  Writes one fully specified table cell.
  Parameters:
    id (table): Table handle.
    column (int): Column index.
    row (int): Row index.
    cellText (string): Cell text.
    textColor (color): Text color.
    backgroundColor (color): Cell background color.
    textSize (string): Pine text size constant.
    horizontalAlign (string): Pine text alignment constant.
    tooltipText (string): Cell tooltip text.
  Returns: True after writing.

twoColumnRow(id, row, labelText, valueText, labelColor, valueColor, backgroundColor, textSize, labelTooltip, valueTooltip)
  Writes one two-column label/value row.
  Parameters:
    id (table): Table handle.
    row (int): Row index.
    labelText (string): Left-cell text.
    valueText (string): Right-cell text.
    labelColor (color): Left text color.
    valueColor (color): Right text color.
    backgroundColor (color): Shared cell background color.
    textSize (string): Shared Pine text size constant.
    labelTooltip (string): Left-cell tooltip.
    valueTooltip (string): Right-cell tooltip.
  Returns: True after writing both cells.

twoColumnHeader(id, row, leftText, rightText, leftColor, rightColor, backgroundColor, textSize, leftTooltip, rightTooltip)
  Writes one two-column header/decoder row.
  Parameters:
    id (table): Table handle.
    row (int): Row index.
    leftText (string): Left-cell text.
    rightText (string): Right-cell text.
    leftColor (color): Left text color.
    rightColor (color): Right text color.
    backgroundColor (color): Shared background color.
    textSize (string): Shared Pine text size constant.
    leftTooltip (string): Left-cell tooltip.
    rightTooltip (string): Right-cell tooltip.
  Returns: True after writing both cells.

mergedSection(id, row, firstColumn, lastColumn, sectionText, textColor, backgroundColor, textSize, tooltipText)
  Writes one merged full-width section row.
  Parameters:
    id (table): Table handle.
    row (int): Row index.
    firstColumn (int): First column to merge.
    lastColumn (int): Last column to merge.
    sectionText (string): Section text.
    textColor (color): Text color.
    backgroundColor (color): Cell background color.
    textSize (string): Pine text size constant.
    tooltipText (string): Cell tooltip.
  Returns: True after writing and merging.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign

//@version=6
//@description Generic Pine table construction and cell-rendering primitives for XZ scripts. Contains no trading methodology or analytical authority.
library("XZ_Table_Primitives", true)

//@function Resolves a normalized position key to a Pine table position.
//@param key Position key: top_left, top_center, top_right, middle_left, middle_center, middle_right, bottom_left, bottom_center or bottom_right.
//@returns Pine position constant.
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

//@function Resolves a normalized text-size key to a Pine size constant.
//@param key Text-size key: tiny, small, normal, large or huge.
//@returns Pine size constant.
export resolveTextSize(string key) =>
    switch str.lower(key)
        "tiny" => size.tiny
        "small" => size.small
        "large" => size.large
        "huge" => size.huge
        => size.normal

//@function Creates a table using caller-supplied presentation values.
//@param positionKey Normalized table position key.
//@param columns Number of columns.
//@param rows Number of rows.
//@param backgroundColor Table background color.
//@param frameColor Table frame color.
//@param frameWidth Table frame width.
//@returns New table handle.
export create(
     string positionKey,
     int columns,
     int rows,
     color backgroundColor,
     color frameColor,
     int frameWidth
 ) =>
    table.new(
         resolvePosition(positionKey),
         columns,
         rows,
         bgcolor=backgroundColor,
         frame_color=frameColor,
         frame_width=frameWidth
     )

//@function Clears a rectangular region of an existing table.
//@param id Table handle.
//@param firstColumn First column index.
//@param firstRow First row index.
//@param lastColumn Last column index.
//@param lastRow Last row index.
//@returns True after clearing.
export clearRegion(table id, int firstColumn, int firstRow, int lastColumn, int lastRow) =>
    table.clear(id, firstColumn, firstRow, lastColumn, lastRow)
    true

//@function Writes one fully specified table cell.
//@param id Table handle.
//@param column Column index.
//@param row Row index.
//@param cellText Cell text.
//@param textColor Text color.
//@param backgroundColor Cell background color.
//@param textSize Pine text size constant.
//@param horizontalAlign Pine text alignment constant.
//@param tooltipText Cell tooltip text.
//@returns True after writing.
export cell(
     table id,
     int column,
     int row,
     string cellText,
     color textColor,
     color backgroundColor,
     string textSize,
     string horizontalAlign,
     string tooltipText
 ) =>
    table.cell(
         id,
         column,
         row,
         cellText,
         text_color=textColor,
         bgcolor=backgroundColor,
         text_size=textSize,
         text_halign=horizontalAlign,
         tooltip=tooltipText
     )
    true

//@function Writes one two-column label/value row.
//@param id Table handle.
//@param row Row index.
//@param labelText Left-cell text.
//@param valueText Right-cell text.
//@param labelColor Left text color.
//@param valueColor Right text color.
//@param backgroundColor Shared cell background color.
//@param textSize Shared Pine text size constant.
//@param labelTooltip Left-cell tooltip.
//@param valueTooltip Right-cell tooltip.
//@returns True after writing both cells.
export twoColumnRow(
     table id,
     int row,
     string labelText,
     string valueText,
     color labelColor,
     color valueColor,
     color backgroundColor,
     string textSize,
     string labelTooltip,
     string valueTooltip
 ) =>
    cell(id, 0, row, labelText, labelColor, backgroundColor, textSize, text.align_left, labelTooltip)
    cell(id, 1, row, valueText, valueColor, backgroundColor, textSize, text.align_right, valueTooltip)
    true

//@function Writes one two-column header/decoder row.
//@param id Table handle.
//@param row Row index.
//@param leftText Left-cell text.
//@param rightText Right-cell text.
//@param leftColor Left text color.
//@param rightColor Right text color.
//@param backgroundColor Shared background color.
//@param textSize Shared Pine text size constant.
//@param leftTooltip Left-cell tooltip.
//@param rightTooltip Right-cell tooltip.
//@returns True after writing both cells.
export twoColumnHeader(
     table id,
     int row,
     string leftText,
     string rightText,
     color leftColor,
     color rightColor,
     color backgroundColor,
     string textSize,
     string leftTooltip,
     string rightTooltip
 ) =>
    cell(id, 0, row, leftText, leftColor, backgroundColor, textSize, text.align_left, leftTooltip)
    cell(id, 1, row, rightText, rightColor, backgroundColor, textSize, text.align_right, rightTooltip)
    true

//@function Writes one merged full-width section row.
//@param id Table handle.
//@param row Row index.
//@param firstColumn First column to merge.
//@param lastColumn Last column to merge.
//@param sectionText Section text.
//@param textColor Text color.
//@param backgroundColor Cell background color.
//@param textSize Pine text size constant.
//@param tooltipText Cell tooltip.
//@returns True after writing and merging.
export mergedSection(
     table id,
     int row,
     int firstColumn,
     int lastColumn,
     string sectionText,
     color textColor,
     color backgroundColor,
     string textSize,
     string tooltipText
 ) =>
    table.cell(
         id,
         firstColumn,
         row,
         sectionText,
         text_color=textColor,
         bgcolor=backgroundColor,
         text_size=textSize,
         text_halign=text.align_left,
         tooltip=tooltipText
     )
    table.merge_cells(id, firstColumn, row, lastColumn, row)
    true

//@function Creates a table with matching frame and border styling.
export createStyled(
     string positionKey, int columns, int rows,
     color backgroundColor, color lineColor, bool showLines
 ) =>
    table.new(
         resolvePosition(positionKey), columns, rows,
         bgcolor=backgroundColor,
         frame_color=lineColor, frame_width=showLines ? 1 : 0,
         border_color=lineColor, border_width=showLines ? 1 : 0
     )

//@function Deletes a table when present.
export deleteTable(table id) =>
    if not na(id)
        table.delete(id)
    true

//@function Renders code/term decoder rows with tooltip only on the code cell.
export decoderRows(
     table id, int startRow,
     array<string> codes, array<string> terms, array<string> tooltips,
     color accentColor, color textColor, color backgroundColor, string textSize
 ) =>
    int n = math.min(array.size(codes), math.min(array.size(terms), array.size(tooltips)))
    if n > 0
        for i = 0 to n - 1
            cell(id, 0, startRow + i, array.get(codes, i), accentColor, backgroundColor, textSize, text.align_left, array.get(tooltips, i))
            cell(id, 1, startRow + i, array.get(terms, i), textColor, backgroundColor, textSize, text.align_left, "")
    startRow + n
````
