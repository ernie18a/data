# GB Time Algo  Path Reference Tables by G

- url: https://www.tradingview.com/script/ct0sZ11L-GB-Time-Algo-Path-Reference-Tables-by-G/
- type: indicator
- pine_id: PUB;c79aaf73d172487a9d41b99a22749061
- version: 1.0

## Description

Algo  Path Reference Tables

A pure reference/lookup tool — it performs no swing, sweep, or price detection. It simply displays two static on-chart tables summarizing a time-based sequence model, so you have the key numbers in view while trading instead of checking notes off-chart.

What it shows

Algo Table — a 2-row table listing the "Algo 1" and "Algo 2" minute sequences (e.g., 00, 11(14), 41(44), 03(07), 17(23), 29(35)), for quick reference to the step order of each algorithm.
2-Path Tracker Table — an 8-row table listing the minute-window values for 8 tracked paths, each row showing up to 5 steps in that path's sequence.

Both tables stay pinned to the corner of the chart you choose, so they don't interfere with price action.

Customization

Show/hide each table independently
Position each table anywhere on the chart (9 anchor points, set separately for each table)
Text size (Tiny–Huge)
Header background/text color, cell background color (with zebra-striping between rows), cell text color
Border color and width

Use case
Designed for GB Time traders following a fixed time/number-sequence model (algo steps and multi-path tracking) who want the reference tables always visible on-chart rather than switching to external notes mid-session.[image]https://www.tradingview.com/x/HKWiga9Z/[/image]

## Source Code

````pine
//@version=6
indicator("Algo & Path Reference Tables", overlay=true)

// =====================================================================
// Pure reference display -- no swing/sweep detection. Just draws the
// Algo 1 / Algo 2 sequence table and the 8-row 2-Path tracker table on
// the chart for quick lookup while trading.
// =====================================================================

grp1 = "Algo Table"
showAlgoTable = input.bool(true, "Show Algo Table?", group=grp1)
algoPosStr    = input.string("Top Left", "Algo Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grp1)

grp2 = "2-Path Tracker Table"
showPathTable = input.bool(true, "Show 2-Path Table?", group=grp2)
pathPosStr    = input.string("Top Right", "2-Path Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grp2)

grp3 = "Appearance"
textSizeStr    = input.string("Small", "Table Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grp3)
headerBgColor  = input.color(color.new(#2a2a2a, 0), "Header/Label Background", group=grp3)
headerTxtColor = input.color(color.new(color.yellow, 0), "Header/Label Text Color", group=grp3)
cellBgColor    = input.color(color.new(#1a1a1a, 0), "Cell Background (Row A)", group=grp3)
altCellBgColor = input.color(color.new(#232323, 0), "Cell Background (Row B, zebra stripe)", group=grp3)
cellTxtColor   = input.color(color.new(color.white, 0), "Cell Text Color", group=grp3)
borderColor    = input.color(color.new(color.gray, 0), "Border Color", group=grp3)
borderWidth    = input.int(1, "Border Width", minval=0, maxval=5, group=grp3)

getSize(val) =>
    switch val
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small
sz = getSize(textSizeStr)

getPos(val) =>
    switch val
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right
algoPos = getPos(algoPosStr)
pathPos = getPos(pathPosStr)

// ===================== DATA =====================
var string[] algo1Steps = array.from("00", "11(14)", "41(44)", "03(07)", "17(23)", "29(35)")
var string[] algo2Steps = array.from("03(07)", "59", "17(23)", "11(14)", "47(50)53(56)", "29(35)")

var string[] pathRow0 = array.from("00", "11(14)", "29(35)", "", "")
var string[] pathRow1 = array.from("11(14)", "17(23)", "41(44)", "47(50)53(56)", "00")
var string[] pathRow2 = array.from("41(44)", "03(07)", "11(14)", "", "")
var string[] pathRow3 = array.from("03(07)", "17(23)", "41(44)", "", "")
var string[] pathRow4 = array.from("17(23)", "29(35)", "59", "11(14)", "03(07)")
var string[] pathRow5 = array.from("29(35)", "47(50)53(56)", "00", "03(07)", "17(23)")
var string[] pathRow6 = array.from("47(50)53(56)", "11(14)", "29(35)", "", "")
var string[] pathRow7 = array.from("59(65)", "03(07)", "17(23)", "", "")

// ===================== HELPERS =====================
fillAlgoRow(table t, int r, string label, string[] steps, color rowBg) =>
    table.cell(t, 0, r, label, bgcolor=headerBgColor, text_color=headerTxtColor, text_size=sz)
    for c = 0 to array.size(steps) - 1
        table.cell(t, c + 1, r, array.get(steps, c), bgcolor=rowBg, text_color=cellTxtColor, text_size=sz)

fillPathRow(table t, int r, string[] vals, color rowBg) =>
    for c = 0 to array.size(vals) - 1
        table.cell(t, c, r, array.get(vals, c), bgcolor=rowBg, text_color=cellTxtColor, text_size=sz)

// ===================== DRAW =====================
var table algoTable = table.new(position.top_left, 1, 1)
var table pathTable = table.new(position.top_left, 1, 1)

if barstate.islast
    table.delete(algoTable)
    table.delete(pathTable)

    if showAlgoTable
        algoTable := table.new(algoPos, 7, 2, border_width=borderWidth, border_color=borderColor)
        fillAlgoRow(algoTable, 0, "Algo 1", algo1Steps, cellBgColor)
        fillAlgoRow(algoTable, 1, "Algo 2", algo2Steps, altCellBgColor)

    if showPathTable
        pathTable := table.new(pathPos, 5, 8, border_width=borderWidth, border_color=borderColor)
        fillPathRow(pathTable, 0, pathRow0, cellBgColor)
        fillPathRow(pathTable, 1, pathRow1, altCellBgColor)
        fillPathRow(pathTable, 2, pathRow2, cellBgColor)
        fillPathRow(pathTable, 3, pathRow3, altCellBgColor)
        fillPathRow(pathTable, 4, pathRow4, cellBgColor)
        fillPathRow(pathTable, 5, pathRow5, altCellBgColor)
        fillPathRow(pathTable, 6, pathRow6, cellBgColor)
        fillPathRow(pathTable, 7, pathRow7, altCellBgColor)
````
