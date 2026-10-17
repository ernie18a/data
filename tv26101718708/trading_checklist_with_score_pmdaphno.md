# Trading Checklist with Score

- url: https://www.tradingview.com/script/PmdaPHNo-Trading-Checklist-with-Score/
- type: indicator
- pine_id: PUB;10c8fcf415b245ceb214ca148b40fc53
- version: 1.0

## Description

This indicator displays a customizable trading checklist directly on the chart.

It is designed to help discretionary traders organize their trade validation process before entering a position. The script does not generate buy or sell signals, does not automate trading decisions, and does not make any performance claims.

Main features:
• Up to 20 checklist rows
• 10 rows displayed by default
• Adjustable number of visible rows from 1 to 20
• Optional trade score based only on the visible checklist rows
• Custom text for each checklist item
• Custom table position, colors, text size, and header
• Optional symbol pinning, so the checklist can be linked to one chart symbol

How to use:
1. Add the indicator to the chart.
2. Open the indicator settings.
3. Edit each checklist row with your own trading criteria.
4. Select the number of visible rows.
5. Check or uncheck each row depending on your trade plan.
6. Use the score as an organizational aid, not as a trading signal.

This script is intended for education, journaling, and discretionary trade preparation. It does not predict market direction and should not be used as a standalone trading system.

Credits:
This version was customized and published by Faouzi Community. If this script is based on or inspired by another open-source checklist script, credit to the original author must be preserved according to TradingView’s open-source reuse rules.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Faouzi Community
//@version=6
indicator(title = "Trading Checklist with Score", shorttitle = "Checklist Score", overlay = true)

// Group 0: Symbol Pinning
var string GP0 = "Symbol Settings"

// Use a variable to track if this is the first load
var bool firstLoad = true

// Input with a constant default, will be overridden on first load
pinnedSymbolInput = input.string(defval = "", title = "Pinned Symbol", group = GP0, tooltip = "Checklist will only work for this symbol.")

// Set pinnedSymbol to current chart symbol on first load, otherwise use user input
var string pinnedSymbol = firstLoad and pinnedSymbolInput == "" ? syminfo.ticker : pinnedSymbolInput
if firstLoad
    firstLoad := false

// Group 1: Table Header Settings
var string GP1 = "Table Header Settings"

TablePosition = input.string(
     defval = "Top Right",
     title = "Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     inline = "in1",
     group = GP1)

Table_Position = switch TablePosition
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right

label_size = input.string(
     defval = "Normal",
     title = "Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     inline = "in1",
     group = GP1)

Tsize = switch label_size
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

btextcolor = input.color(defval = color.white, title = "Header Text Color", inline = "in111", group = GP1)
bbackgroundcolor = input.color(defval = #1E90FF, title = "Header Background", inline = "in111", group = GP1)
borderColor = input.color(defval = #4682B4, title = "Border Color", inline = "in112", group = GP1)

ubs = input.bool(true, "", inline = "in00", group = GP1, tooltip = "(Max 50 characters for all text boxes)")
banner = input.string("Checklist by Faouzi Community", title = "Header", inline = "in00", group = GP1)

// Group 2: Table Content Settings
var string GP2 = "Table Content Settings"

textcolor = input.color(defval = #D3D3D3, title = "Text Color", inline = "in2", group = GP2)
backgroundcolor = input.color(defval = #2F2F2F, title = "Background Color", inline = "in2", group = GP2)

// Checkbox Inputs with Tooltips
checktb1  = input.bool(true, "Row 1",  inline = "in02", group = GP2, tooltip = "Criteria 1")
checktb2  = input.bool(true, "Row 2",  inline = "in03", group = GP2, tooltip = "Criteria 2")
checktb3  = input.bool(true, "Row 3",  inline = "in04", group = GP2, tooltip = "Criteria 3")
checktb4  = input.bool(true, "Row 4",  inline = "in05", group = GP2, tooltip = "Criteria 4")
checktb5  = input.bool(true, "Row 5",  inline = "in06", group = GP2, tooltip = "Criteria 5")
checktb6  = input.bool(true, "Row 6",  inline = "in07", group = GP2, tooltip = "Criteria 6")
checktb7  = input.bool(true, "Row 7",  inline = "in08", group = GP2, tooltip = "Criteria 7")
checktb8  = input.bool(true, "Row 8",  inline = "in09", group = GP2, tooltip = "Criteria 8")
checktb9  = input.bool(true, "Row 9",  inline = "in10", group = GP2, tooltip = "Criteria 9")
checktb10 = input.bool(true, "Row 10", inline = "in11", group = GP2, tooltip = "Criteria 10")
checktb11 = input.bool(true, "Row 11", inline = "in12", group = GP2, tooltip = "Criteria 11")
checktb12 = input.bool(true, "Row 12", inline = "in13", group = GP2, tooltip = "Criteria 12")
checktb13 = input.bool(true, "Row 13", inline = "in14", group = GP2, tooltip = "Criteria 13")
checktb14 = input.bool(true, "Row 14", inline = "in15", group = GP2, tooltip = "Criteria 14")
checktb15 = input.bool(true, "Row 15", inline = "in16", group = GP2, tooltip = "Criteria 15")
checktb16 = input.bool(true, "Row 16", inline = "in17", group = GP2, tooltip = "Criteria 16")
checktb17 = input.bool(true, "Row 17", inline = "in18", group = GP2, tooltip = "Criteria 17")
checktb18 = input.bool(true, "Row 18", inline = "in19", group = GP2, tooltip = "Criteria 18")
checktb19 = input.bool(true, "Row 19", inline = "in20", group = GP2, tooltip = "Criteria 19")
checktb20 = input.bool(true, "Row 20", inline = "in21", group = GP2, tooltip = "Criteria 20")

// Row Text Inputs
tb1  = input.string("1",  title = "T1",  inline = "in02", group = GP2)
tb2  = input.string("2",  title = "T2",  inline = "in03", group = GP2)
tb3  = input.string("3",  title = "T3",  inline = "in04", group = GP2)
tb4  = input.string("4",  title = "T4",  inline = "in05", group = GP2)
tb5  = input.string("5",  title = "T5",  inline = "in06", group = GP2)
tb6  = input.string("6",  title = "T6",  inline = "in07", group = GP2)
tb7  = input.string("7",  title = "T7",  inline = "in08", group = GP2)
tb8  = input.string("8",  title = "T8",  inline = "in09", group = GP2)
tb9  = input.string("9",  title = "T9",  inline = "in10", group = GP2)
tb10 = input.string("10", title = "T10", inline = "in11", group = GP2)
tb11 = input.string("11", title = "T11", inline = "in12", group = GP2)
tb12 = input.string("12", title = "T12", inline = "in13", group = GP2)
tb13 = input.string("13", title = "T13", inline = "in14", group = GP2)
tb14 = input.string("14", title = "T14", inline = "in15", group = GP2)
tb15 = input.string("15", title = "T15", inline = "in16", group = GP2)
tb16 = input.string("16", title = "T16", inline = "in17", group = GP2)
tb17 = input.string("17", title = "T17", inline = "in18", group = GP2)
tb18 = input.string("18", title = "T18", inline = "in19", group = GP2)
tb19 = input.string("19", title = "T19", inline = "in20", group = GP2)
tb20 = input.string("20", title = "T20", inline = "in21", group = GP2)

// Input to control number of visible rows
visibleRows = input.int(10, title = "Number of Visible Rows", minval = 1, maxval = 20, group = GP2)

// Input to show or hide Trade Score
showTradeScore = input.bool(true, title = "Show Trade Score", group = GP2)

// Helper functions
getChecked(rowNumber) =>
    switch rowNumber
        1  => checktb1
        2  => checktb2
        3  => checktb3
        4  => checktb4
        5  => checktb5
        6  => checktb6
        7  => checktb7
        8  => checktb8
        9  => checktb9
        10 => checktb10
        11 => checktb11
        12 => checktb12
        13 => checktb13
        14 => checktb14
        15 => checktb15
        16 => checktb16
        17 => checktb17
        18 => checktb18
        19 => checktb19
        20 => checktb20
        => false

getRowText(rowNumber) =>
    switch rowNumber
        1  => tb1
        2  => tb2
        3  => tb3
        4  => tb4
        5  => tb5
        6  => tb6
        7  => tb7
        8  => tb8
        9  => tb9
        10 => tb10
        11 => tb11
        12 => tb12
        13 => tb13
        14 => tb14
        15 => tb15
        16 => tb16
        17 => tb17
        18 => tb18
        19 => tb19
        20 => tb20
        => ""

// Check if current symbol matches pinned symbol
isPinnedSymbol = syminfo.ticker == pinnedSymbol

// Calculate Trade Score only for visible rows and pinned symbol
checkedRows = 0
if isPinnedSymbol
    for i = 1 to visibleRows
        checkedRows += getChecked(i) ? 1 : 0

tradeScore = isPinnedSymbol ? math.round((checkedRows / visibleRows) * 100) : 0

// Dynamic Trade Score Color
tradeScoreColor = tradeScore >= 75 ? color.green : tradeScore >= 50 ? color.yellow : color.red

// Initialize table with enough rows for header + 20 checklist rows + score row
var int totalRows = 22
var table myTable = table.new(position = Table_Position, columns = 2, rows = totalRows, border_width = 2, border_color = borderColor, frame_width = 2, frame_color = borderColor)

if barstate.islast
    // Clear table with proper range
    table.clear(myTable, start_column = 0, start_row = 0, end_column = 1, end_row = totalRows - 1)

    // Only populate table if on pinned symbol
    if isPinnedSymbol
        // Set the header with consistent formatting
        if ubs
            txt0 = " " + str.tostring(banner) + " "
            table.cell(myTable, column = 0, row = 0, text_size = Tsize, text = txt0, text_color = btextcolor, bgcolor = bbackgroundcolor)
            table.merge_cells(table_id = myTable, start_column = 0, start_row = 0, end_column = 1, end_row = 0)

        // Populate checklist rows dynamically
        for i = 1 to visibleRows
            checked = getChecked(i)
            rowText = getRowText(i)

            table.cell(myTable, column = 0, row = i, text_size = Tsize, text = checked ? "✔" : "✘", text_color = checked ? #32CD32 : #FF4500, bgcolor = backgroundcolor)
            table.cell(myTable, column = 1, row = i, text_size = Tsize, text = rowText, text_color = textcolor, bgcolor = backgroundcolor)

        // Display Trade Score if enabled
        if showTradeScore
            table.cell(myTable, column = 0, row = visibleRows + 1, text_size = Tsize, text = "Score", text_color = #FFD700, bgcolor = #3C3C3C)
            table.cell(myTable, column = 1, row = visibleRows + 1, text_size = Tsize, text = str.tostring(tradeScore) + "%", text_color = tradeScoreColor, bgcolor = #3C3C3C)
````
