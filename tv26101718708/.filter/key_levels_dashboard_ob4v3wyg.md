# Key Levels Dashboard

- url: https://www.tradingview.com/script/Ob4v3WYg-Key-Levels-Dashboard/
- type: indicator
- pine_id: PUB;bd674762bc7b46abbf79ec4b9d83aa1f
- version: 1.0

## Description

A clean and lightweight dashboard that displays the most important daily and weekly market reference levels in a compact table directly on your chart.

Designed for traders who want instant access to key price levels without cluttering the chart with additional lines and labels.

[b]Displayed Levels[/b]

[list]
[*] [b]OPEN[/b] - Current Day Open
[*] [b]PDH[/b] - Previous Day High
[*] [b]PDL[/b] - Previous Day Low
[*] [b]PDC[/b] - Previous Day Close
[*] [b]PWH[/b] - Previous Week High
[*] [b]PWL[/b] - Previous Week Low
[/list]

[b]Features[/b]

[list]
[*] Compact dashboard displaying all key levels in a single table.
[*] Optional OPEN vs PDC comparison with directional arrows.
[*] Shows whether today's opening price is above, below, or equal to the previous day's close.
[*] Displays the exact price difference between OPEN and PDC.
[*] Fully customizable table position.
[*] Adjustable text size, colors, background and borders.
[*] Individual visibility controls for every level.
[/list]

[b]OPEN vs PDC Direction[/b]

When enabled, the dashboard compares the current day's opening price with the previous day's close:

[list]
[*] [b]↑[/b] Opening price is above the previous close.
[*] [b]↓[/b] Opening price is below the previous close.
[*] [b]→[/b] Opening price is equal to the previous close.
[/list]

This provides a quick view of overnight gaps and market sentiment before the trading session develops.

## Source Code

````pine
//@version=6
indicator("Key Levels Dashboard", overlay = true)

//====================================================
// INPUTS
//====================================================
groupVisibility = "Visibility"

showOpen = input.bool(true,  "Current Day Open",  group = groupVisibility)
showArrow = input.bool(true, "OPEN vs PDC Direction",     group = groupVisibility)

showPDH = input.bool(true, "Previous Day High (PDH)",  group = groupVisibility)
showPDL = input.bool(true, "Previous Day Low (PDL)",   group = groupVisibility)
showPDC = input.bool(true, "Previous Day Close (PDC)", group = groupVisibility)

showPWH = input.bool(true, "Previous Week High (PWH)", group = groupVisibility)
showPWL = input.bool(true, "Previous Week Low (PWL)",  group = groupVisibility)

groupStyle = "Style"

tablePosition = input.string(
     "bottom_right",
     "Table Position",
     options = [
          "top_right",
          "bottom_right",
          "top_left",
          "bottom_left",
          "top_center",
          "bottom_center"
     ],
     group = groupStyle)

textSize = input.string(
     "normal",
     "Text Size",
     options = ["tiny", "small", "normal", "large"],
     group = groupStyle)

bgColor = input.color(color.new(color.black, 15), "Background", group = groupStyle)
textColor = input.color(color.white, "Text Color", group = groupStyle)
borderColor = input.color(color.new(color.gray, 40), "Border Color", group = groupStyle)

//====================================================
// DATA
//====================================================
[pdh, pdl, pdc] = request.security(
     syminfo.tickerid,
     "D",
     [high[1], low[1], close[1]],
     lookahead = barmerge.lookahead_on)

[pwh, pwl] = request.security(
     syminfo.tickerid,
     "W",
     [high[1], low[1]],
     lookahead = barmerge.lookahead_on)

dayOpen = request.security(
     syminfo.tickerid,
     "D",
     open,
     lookahead = barmerge.lookahead_on)

//====================================================
// OPEN VS PDC
//====================================================
string openLabel = "OPEN"

if showArrow

    float diff = dayOpen - pdc

    bool isFlat = math.abs(diff) < syminfo.mintick

    string arrow =
         isFlat ? " →" :
         diff > 0 ? " ↑" :
         " ↓"

    string diffText =
         isFlat ? "" :
         " (" + (diff > 0 ? "+" : "") + str.tostring(diff, format.mintick) + ")"

    openLabel += arrow + diffText

//====================================================
// TABLE POSITION
//====================================================
tablePos = switch tablePosition
    "top_right"     => position.top_right
    "bottom_right"  => position.bottom_right
    "top_left"      => position.top_left
    "bottom_left"   => position.bottom_left
    "top_center"    => position.top_center
    => position.bottom_center

//====================================================
// ROW FUNCTION
//====================================================
addRow(
     table tbl,
     int row,
     string label,
     float value) =>

    table.cell(
         tbl,
         0,
         row,
         label,
         text_color = textColor,
         bgcolor = bgColor,
         text_size = textSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         row,
         str.tostring(value, format.mintick),
         text_color = textColor,
         bgcolor = bgColor,
         text_size = textSize,
         text_halign = text.align_right)

//====================================================
// TABLE
//====================================================
if barstate.islast

    int rows = 0

    if showOpen
        rows += 1

    if showPDH
        rows += 1

    if showPDL
        rows += 1

    if showPDC
        rows += 1

    if showPWH
        rows += 1

    if showPWL
        rows += 1

    if rows > 0

        var table dashboard = table.new(
             tablePos,
             2,
             rows,
             border_width = 1,
             border_color = borderColor,
             frame_width = 1,
             frame_color = borderColor)

        int row = 0

        if showOpen
            addRow(dashboard, row, openLabel, dayOpen)
            row += 1

        if showPDH
            addRow(dashboard, row, "PDH", pdh)
            row += 1

        if showPDL
            addRow(dashboard, row, "PDL", pdl)
            row += 1

        if showPDC
            addRow(dashboard, row, "PDC", pdc)
            row += 1

        if showPWH
            addRow(dashboard, row, "PWH", pwh)
            row += 1

        if showPWL
            addRow(dashboard, row, "PWL", pwl)
            row += 1
````
