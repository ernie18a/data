# Legende [Tradeuminati]

- url: https://www.tradingview.com/script/qOOuJvFp/
- type: indicator
- pine_id: PUB;b7a72f83094a4e389522978475d7279b
- version: 1.0

## Description

The "[b]Legende [Tradeuminati][/b]" indicator 
is a simple yet highly practical tool designed to bring clarity and structure to your TradingView watchlist workflow.

It displays a customizable legend in the bottom-right corner of your chart, allowing you to clearly define the meaning behind your watchlist flag colors. Each color (Green, Red, Orange, Blue, Purple, Turquoise, Pink) can be individually configured:

- Enable or disable each color row
- Assign a custom label (e.g. Long, Short, Watchlist, etc.)

The legend automatically adjusts itself:
Only active colors are displayed, ensuring a clean and compact layout without empty rows.
Additionally, the indicator uses TradingView’s native flag color palette, so your legend perfectly matches the colors used in your watchlist.

[b]Key Features:[/b]
- Clean legend displayed directly on the chart
- Fully customizable color labels
- Individual on/off toggle per color
- Compact layout with no empty gaps
- Matching TradingView watchlist flag colors
- Minimalistic and distraction-free design

This tool is ideal for traders who use color-coded watchlists and want a clear, consistent reference directly on their chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DonauTrading

//@version=6
indicator("Legende [Tradeuminati]", overlay=true, max_labels_count=50)

//====================================================
// Inputs (kompakt mit inline)
//====================================================
grpGreen  = "Grün"
showGreen = input.bool(true, "Anzeigen", group=grpGreen, inline="g")
txtGreen  = input.string("Long", " / Bezeichnung", group=grpGreen, inline="g")

grpRed  = "Rot"
showRed = input.bool(true, "Anzeigen", group=grpRed, inline="r")
txtRed  = input.string("Short", " / Bezeichnung", group=grpRed, inline="r")

grpOrange  = "Orange"
showOrange = input.bool(true, "Anzeigen", group=grpOrange, inline="o")
txtOrange  = input.string("Strong Watchlist", " / Bezeichnung", group=grpOrange, inline="o")

grpBlue  = "Blau"
showBlue = input.bool(true, "Anzeigen", group=grpBlue, inline="b")
txtBlue  = input.string("", " / Bezeichnung", group=grpBlue, inline="b")

grpPurple  = "Lila"
showPurple = input.bool(true, "Anzeigen", group=grpPurple, inline="p")
txtPurple  = input.string("", " / Bezeichnung", group=grpPurple, inline="p")

grpTurquoise  = "Türkis"
showTurquoise = input.bool(true, "Anzeigen", group=grpTurquoise, inline="t")
txtTurquoise  = input.string("", " / Bezeichnung", group=grpTurquoise, inline="t")

grpPink  = "Pink"
showPink = input.bool(true, "Anzeigen", group=grpPink, inline="pi")
txtPink  = input.string("", " / Bezeichnung", group=grpPink, inline="pi")

// Optional: Tabellen-Layout
grpLayout = "Layout"
textCol   = input.color(color.white, "Textfarbe", group=grpLayout)
bgCol     = input.color(color.new(color.black, 0), "Hintergrund", group=grpLayout)
frameCol  = input.color(color.new(color.white, 70), "Rahmenfarbe", group=grpLayout)
borderCol = input.color(color.new(color.white, 80), "Randfarbe", group=grpLayout)

//====================================================
// Table
//====================================================
var table t = table.new(position.bottom_right, 2, 8, frame_color=frameCol, border_color=borderCol)

// Helper
f_row(_row, _dotColor, _text) =>
    table.cell(t, 0, _row, "●", text_color=_dotColor, bgcolor=bgCol, text_halign=text.align_center)
    table.cell(t, 1, _row, _text, text_color=textCol, bgcolor=bgCol, text_halign=text.align_left)

//====================================================
// Rendering
//====================================================
if barstate.islast
    for r = 0 to 7
        table.cell(t, 0, r, "", text_color=textCol, bgcolor=bgCol)
        table.cell(t, 1, r, "", text_color=textCol, bgcolor=bgCol)

    // Header
    table.cell(t, 0, 0, "Farbe", text_color=textCol, bgcolor=bgCol, text_halign=text.align_center)
    table.cell(t, 1, 0, "Bedeutung", text_color=textCol, bgcolor=bgCol, text_halign=text.align_left)

    int row = 1

    if showGreen
        f_row(row, color.rgb(76, 175, 80), txtGreen)     // #4CAF50
        row += 1

    if showRed
        f_row(row, color.rgb(242, 54, 69), txtRed)       // #F23645
        row += 1

    if showOrange
        f_row(row, color.rgb(251, 192, 45), txtOrange)   // #FBC02D
        row += 1

    if showBlue
        f_row(row, color.rgb(41, 98, 255), txtBlue)      // #2962FF
        row += 1

    if showPurple
        f_row(row, color.rgb(171, 71, 188), txtPurple)   // #AB47BC
        row += 1

    if showTurquoise
        f_row(row, color.rgb(0, 188, 212), txtTurquoise) // #00BCD4
        row += 1

    if showPink
        f_row(row, color.rgb(236, 64, 122), txtPink)     // #EC407A
        row += 1
````
