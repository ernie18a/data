<!-- tradingview-pine-id: PUB;ec18f9439b25436aada937e94156dc38 -->
<!-- tradingview-pine-version: 10.0 -->
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

//@description XZ Table Primitives v10. Sole suite-wide generic table construction and cell-rendering authority. Contains no indicator terminology, methodology, lifecycle authority or analytical qualification. v10 retains prior APIs and adds generic left-aligned batch rows plus a neutral two-pane topic/body grid for information-dense table layouts. Multi-table position deconfliction remains unchanged.
library("XZ_Table_Primitives", false)

//==============================================================================
// RESOLUTION
//==============================================================================

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

export resolveTextSize(simple string key) =>
    switch str.lower(key)
        "tiny" => size.tiny
        "small" => size.small
        "large" => size.large
        "huge" => size.huge
        => size.normal

//==============================================================================
// GENERIC MULTI-TABLE POSITION DECONFLICTION
//==============================================================================

_positionKeys() =>
    array.from("top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right")

_claimPosition(bool enabled, string requestedKey, array<string> claimed) =>
    string result = requestedKey
    if enabled
        if array.includes(claimed, requestedKey)
            array<string> keys = _positionKeys()
            int count = array.size(keys)
            int start = math.max(array.indexof(keys, requestedKey), 0)
            if count > 0
                for step = 1 to count
                    string candidate = array.get(keys, (start + step) % count)
                    if not array.includes(claimed, candidate)
                        result := candidate
                        break
        array.push(claimed, result)
    result

//@function Resolves up to four independently enabled table positions without allowing two enabled tables to occupy the same Pine anchor. Earlier arguments have priority for their requested anchor; later conflicts fall forward to the next unused canonical anchor. Disabled tables do not claim positions.
export deconflictFour(bool enabled0, string requested0, bool enabled1, string requested1, bool enabled2, string requested2, bool enabled3, string requested3) =>
    array<string> claimed = array.new_string()
    string resolved0 = _claimPosition(enabled0, requested0, claimed)
    string resolved1 = _claimPosition(enabled1, requested1, claimed)
    string resolved2 = _claimPosition(enabled2, requested2, claimed)
    string resolved3 = _claimPosition(enabled3, requested3, claimed)
    [resolved0, resolved1, resolved2, resolved3]

//==============================================================================
// TABLE LIFECYCLE
//==============================================================================

export create(string positionKey, int columns, int rows, color backgroundColor, color frameColor, int frameWidth) =>
    table.new(resolvePosition(positionKey), columns, rows, bgcolor=backgroundColor, frame_color=frameColor, frame_width=frameWidth)

export createStyled(string positionKey, int columns, int rows, color backgroundColor, color lineColor, bool showLines) =>
    table.new(resolvePosition(positionKey), columns, rows, bgcolor=backgroundColor, frame_color=showLines ? lineColor : na, frame_width=showLines ? 1 : 0, border_color=showLines ? lineColor : na, border_width=showLines ? 1 : 0)

export deleteTable(table id) =>
    if not na(id)
        table.delete(id)
    true

export clearRegion(table id, int firstColumn, int firstRow, int lastColumn, int lastRow) =>
    if not na(id)
        table.clear(id, firstColumn, firstRow, lastColumn, lastRow)
    true

//==============================================================================
// CELLS
//==============================================================================

export cell(table id, int column, int row, string cellText, color textColor, color backgroundColor, string textSize, string horizontalAlign, string tooltipText) =>
    if not na(id)
        table.cell(id, column, row, cellText, text_color=textColor, bgcolor=backgroundColor, text_size=textSize, text_halign=horizontalAlign, tooltip=tooltipText)
    true

export twoColumnRow(table id, int row, string labelText, string valueText, color labelColor, color valueColor, color backgroundColor, string textSize, string labelTooltip, string valueTooltip) =>
    cell(id, 0, row, labelText, labelColor, backgroundColor, textSize, text.align_left, labelTooltip)
    cell(id, 1, row, valueText, valueColor, backgroundColor, textSize, text.align_left, valueTooltip)
    true

export twoColumnHeader(table id, int row, string leftText, string rightText, color leftColor, color rightColor, color backgroundColor, string textSize, string leftTooltip, string rightTooltip) =>
    cell(id, 0, row, leftText, leftColor, backgroundColor, textSize, text.align_left, leftTooltip)
    cell(id, 1, row, rightText, rightColor, backgroundColor, textSize, text.align_left, rightTooltip)
    true

export mergedSection(table id, int row, int firstColumn, int lastColumn, string sectionText, color textColor, color backgroundColor, string textSize, string tooltipText) =>
    if not na(id)
        table.merge_cells(id, firstColumn, row, lastColumn, row)
        table.cell(id, firstColumn, row, sectionText, text_color=textColor, bgcolor=backgroundColor, text_size=textSize, text_halign=text.align_left, tooltip=tooltipText)
    true

// v4 alignment variants. Caller owns all meaning/copy.
export twoColumnRowRight(table id, int row, string labelText, string valueText, color labelColor, color valueColor, color backgroundColor, string textSize, string labelTooltip, string valueTooltip) =>
    cell(id, 0, row, labelText, labelColor, backgroundColor, textSize, text.align_left, labelTooltip)
    cell(id, 1, row, valueText, valueColor, backgroundColor, textSize, text.align_right, valueTooltip)
    true

//@function Renders the same generic two-column row at an arbitrary starting column. Useful for side-by-side panes without embedding consumer semantics in the library.
export twoColumnRowRightAt(table id, int startColumn, int row, string labelText, string valueText, color labelColor, color valueColor, color backgroundColor, string textSize, string labelTooltip, string valueTooltip) =>
    cell(id, startColumn, row, labelText, labelColor, backgroundColor, textSize, text.align_left, labelTooltip)
    cell(id, startColumn + 1, row, valueText, valueColor, backgroundColor, textSize, text.align_right, valueTooltip)
    true

export twoColumnHeaderRight(table id, int row, string leftText, string rightText, color leftColor, color rightColor, color backgroundColor, string textSize, string leftTooltip, string rightTooltip) =>
    cell(id, 0, row, leftText, leftColor, backgroundColor, textSize, text.align_left, leftTooltip)
    cell(id, 1, row, rightText, rightColor, backgroundColor, textSize, text.align_right, rightTooltip)
    true

export twoColumnRowsRight(table id, int startRow, array<string> labels, array<string> values, array<string> labelTooltips, array<string> valueTooltips, array<bool> accents, color textColor, color accentColor, color backgroundColor, string textSize) =>
    int n = math.min(array.size(labels), math.min(array.size(values), math.min(array.size(labelTooltips), math.min(array.size(valueTooltips), array.size(accents)))))
    if n > 0
        for i = 0 to n - 1
            bool accent = array.get(accents, i)
            twoColumnRowRight(id, startRow + i, array.get(labels, i), array.get(values, i), textColor, accent ? accentColor : textColor, backgroundColor, textSize, array.get(labelTooltips, i), array.get(valueTooltips, i))
    startRow + n

//@function Renders caller-supplied two-column rows with both label and value cells left-aligned. Meaning, ordering and accent decisions remain caller-owned.
export twoColumnRows(table id, int startRow, array<string> labels, array<string> values, array<string> labelTooltips, array<string> valueTooltips, array<bool> accents, color textColor, color accentColor, color backgroundColor, string textSize) =>
    int n = math.min(array.size(labels), math.min(array.size(values), math.min(array.size(labelTooltips), math.min(array.size(valueTooltips), array.size(accents)))))
    if n > 0
        for i = 0 to n - 1
            bool accent = array.get(accents, i)
            twoColumnRow(id, startRow + i, array.get(labels, i), array.get(values, i), textColor, accent ? accentColor : textColor, backgroundColor, textSize, array.get(labelTooltips, i), array.get(valueTooltips, i))
    startRow + n

//@function Renders a caller-supplied horizontal strip with every cell left-aligned.
export horizontalCellsLeft(table id, int row, array<string> texts, array<color> textColors, array<string> tooltips, color backgroundColor, string textSize) =>
    int n = math.min(array.size(texts), math.min(array.size(textColors), array.size(tooltips)))
    if n > 0
        for column = 0 to n - 1
            cell(id, column, row, array.get(texts, column), array.get(textColors, column), backgroundColor, textSize, text.align_left, array.get(tooltips, column))
    true

//@function Renders two independent caller-supplied topic/body panes side by side. The library assigns no meaning to topics or body text.
export twoPaneTopicRows(table id, int startRow, array<string> leftTopics, array<string> leftBodies, array<string> rightTopics, array<string> rightBodies, color topicColor, color bodyColor, color backgroundColor, string textSize) =>
    int leftCount = math.min(array.size(leftTopics), array.size(leftBodies))
    int rightCount = math.min(array.size(rightTopics), array.size(rightBodies))
    int n = math.max(leftCount, rightCount)
    if n > 0
        for i = 0 to n - 1
            int row = startRow + i
            string leftTopic = i < leftCount ? array.get(leftTopics, i) : ""
            string leftBody = i < leftCount ? array.get(leftBodies, i) : ""
            string rightTopic = i < rightCount ? array.get(rightTopics, i) : ""
            string rightBody = i < rightCount ? array.get(rightBodies, i) : ""
            cell(id, 0, row, leftTopic, topicColor, backgroundColor, textSize, text.align_left, "")
            cell(id, 1, row, leftBody, bodyColor, backgroundColor, textSize, text.align_left, "")
            cell(id, 2, row, rightTopic, topicColor, backgroundColor, textSize, text.align_left, "")
            cell(id, 3, row, rightBody, bodyColor, backgroundColor, textSize, text.align_left, "")
    startRow + n

//==============================================================================
// DECODER ROWS
//==============================================================================

decoderRowsImpl(table id, int startColumn, int startRow, array<string> codes, array<string> terms, array<string> tooltips, color accentColor, color textColor, color backgroundColor, string textSize) =>
    int count = math.min(array.size(codes), math.min(array.size(terms), array.size(tooltips)))
    if count > 0
        for i = 0 to count - 1
            int row = startRow + i
            cell(id, startColumn, row, array.get(codes, i), accentColor, backgroundColor, textSize, text.align_left, array.get(tooltips, i))
            cell(id, startColumn + 1, row, array.get(terms, i), textColor, backgroundColor, textSize, text.align_left, "")
    true

export decoderRows(table id, int startRow, array<string> codes, array<string> terms, array<string> tooltips, color accentColor, color textColor, color backgroundColor, string textSize) =>
    decoderRowsImpl(id, 0, startRow, codes, terms, tooltips, accentColor, textColor, backgroundColor, textSize)

export decoderRowsAt(table id, int startColumn, int startRow, array<string> codes, array<string> terms, array<string> tooltips, color accentColor, color textColor, color backgroundColor, string textSize) =>
    decoderRowsImpl(id, startColumn, startRow, codes, terms, tooltips, accentColor, textColor, backgroundColor, textSize)

//==============================================================================
// v5 GENERIC BATCH / MERGE HELPERS
//==============================================================================

//@function Merges one horizontal row across the supplied columns without assigning semantic content.
export mergeRow(table id, int row, int firstColumn, int lastColumn) =>
    if not na(id)
        table.merge_cells(id, firstColumn, row, lastColumn, row)
    true

//@function Renders a one-row horizontal strip from caller-supplied text/color/tooltip arrays. The first cell can be left-aligned while the remaining cells are right-aligned.
export horizontalCells(table id, int row, array<string> texts, array<color> textColors, array<string> tooltips, color backgroundColor, string textSize, bool firstCellLeft) =>
    int n = math.min(array.size(texts), math.min(array.size(textColors), array.size(tooltips)))
    if n > 0
        for column = 0 to n - 1
            string align = firstCellLeft and column == 0 ? text.align_left : text.align_right
            cell(id, column, row, array.get(texts, column), array.get(textColors, column), backgroundColor, textSize, align, array.get(tooltips, column))
    true

//==============================================================================
// v7 GENERIC PACKED GRID LAYOUT
//==============================================================================

//@type Generic mapping from logical section starts to physical table row/column starts.
export type PackedGridLayout
    array<int> logical_starts
    array<int> physical_rows
    array<int> physical_columns

//@function Creates a generic packed-grid mapping. Arrays are caller supplied and carry no semantic meaning.
export newPackedGridLayout(array<int> logicalStarts, array<int> physicalRows, array<int> physicalColumns) =>
    PackedGridLayout.new(logicalStarts, physicalRows, physicalColumns)

_packedGridIndex(PackedGridLayout layout, int logicalRow) =>
    int result = 0
    int n = math.min(array.size(layout.logical_starts), math.min(array.size(layout.physical_rows), array.size(layout.physical_columns)))
    if n > 0
        for i = 0 to n - 1
            if logicalRow >= array.get(layout.logical_starts, i)
                result := i
            else
                break
    result

export packedGridRow(PackedGridLayout layout, int logicalRow) =>
    int idx = _packedGridIndex(layout, logicalRow)
    array.get(layout.physical_rows, idx) + logicalRow - array.get(layout.logical_starts, idx)

export packedGridColumn(PackedGridLayout layout, int logicalRow) =>
    array.get(layout.physical_columns, _packedGridIndex(layout, logicalRow))

//@function Renders a generic two-column row with both cells left-aligned at an arbitrary starting column.
export twoColumnRowAt(table id, int startColumn, int row, string labelText, string valueText, color labelColor, color valueColor, color backgroundColor, string textSize, string labelTooltip, string valueTooltip) =>
    cell(id, startColumn, row, labelText, labelColor, backgroundColor, textSize, text.align_left, labelTooltip)
    cell(id, startColumn + 1, row, valueText, valueColor, backgroundColor, textSize, text.align_left, valueTooltip)
    true

//@function Renders a generic logical two-column row either normally or through a caller-defined packed-grid mapping, with both cells left-aligned.
export twoColumnRowPacked(table id, bool packed, PackedGridLayout layout, int logicalRow, string labelText, string valueText, color labelColor, color valueColor, color backgroundColor, string textSize, string labelTooltip, string valueTooltip) =>
    int startColumn = packed ? packedGridColumn(layout, logicalRow) : 0
    int row = packed ? packedGridRow(layout, logicalRow) : logicalRow
    twoColumnRowAt(id, startColumn, row, labelText, valueText, labelColor, valueColor, backgroundColor, textSize, labelTooltip, valueTooltip)

//@function Renders a generic logical two-column row either normally or through a caller-defined packed-grid mapping.
export twoColumnRowRightPacked(table id, bool packed, PackedGridLayout layout, int logicalRow, string labelText, string valueText, color labelColor, color valueColor, color backgroundColor, string textSize, string labelTooltip, string valueTooltip) =>
    int startColumn = packed ? packedGridColumn(layout, logicalRow) : 0
    int row = packed ? packedGridRow(layout, logicalRow) : logicalRow
    twoColumnRowRightAt(id, startColumn, row, labelText, valueText, labelColor, valueColor, backgroundColor, textSize, labelTooltip, valueTooltip)

//@function Renders a caller-supplied section title in one logical pane row.
export packedSection(table id, bool packed, PackedGridLayout layout, int logicalRow, string sectionText, color textColor, color backgroundColor, string textSize, string tooltipText) =>
    int startColumn = packed ? packedGridColumn(layout, logicalRow) : 0
    int row = packed ? packedGridRow(layout, logicalRow) : logicalRow
    cell(id, startColumn, row, sectionText, textColor, backgroundColor, textSize, text.align_left, tooltipText)
    true

//@function Merges generic packed-grid section header rows plus an optional number of full-width top rows.
export mergePackedGrid(table id, PackedGridLayout layout, int topFullWidthRows, int totalColumns) =>
    if not na(id)
        if topFullWidthRows > 0 and totalColumns > 0
            for row = 0 to topFullWidthRows - 1
                table.merge_cells(id, 0, row, totalColumns - 1, row)
        int n = math.min(array.size(layout.physical_rows), array.size(layout.physical_columns))
        if n > 0
            for i = 0 to n - 1
                int row = array.get(layout.physical_rows, i)
                int firstColumn = array.get(layout.physical_columns, i)
                table.merge_cells(id, firstColumn, row, firstColumn + 1, row)
    true
````
