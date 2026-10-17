# Trading Checklist with Brand Watermark

- url: https://www.tradingview.com/script/74tJRJso-Trading-Checklist-with-Brand-Watermark/
- type: indicator
- pine_id: PUB;9b9406ce0bf14bca9257f31b04efefce
- version: 1.0

## Description

[b]Trading Checklist with Brand Watermark[/b]


A clean, fully customizable on-chart panel that combines a 7-row trading checklist with a branded watermark — built for traders and content creators who want to display trade conditions and personal branding directly on their TradingView charts.
Checklist Panel:

7 editable rows, each with a custom label and a ✅ / ❌ toggle
Optional header with a custom title and highlight color
Optional footer for social links, channel handles, or notes
Full control over colors, text size, alignment, and border styling
Adjustable row count (1–7 visible rows)

Brand Watermark:

Displays your name, brand, or handle anywhere on the chart
Independent position, text size, text color, and background color controls
Subtle by default — designed to stay visible without distracting from price action

Placement & Style:

Both panels support 9 chart positions (top / middle / bottom × left / center / right)
All inputs are grouped and hidden from the main display for a clean settings panel

Best for: Traders sharing chart screenshots or videos, educators building structured setups, and anyone who wants a branded, rule-based checklist visible at all times while trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
indicator("Trading Checklist with Brand Watermark", overlay = true)




// ─────────────────────────────────────────────
// ROW TEXT INPUTS  (text + checkbox, inline pairs)
// ─────────────────────────────────────────────
Inp1Text  = input.string("Example 1",  "", group = "Row Text", display = display.none, inline = "Inp1")
Inp1Bool  = input.bool(true, "", group = "Row Text", display = display.none, inline = "Inp1")

Inp2Text  = input.string("Example 2",  "", group = "Row Text", display = display.none, inline = "Inp2")
Inp2Bool  = input.bool(false, "", group = "Row Text", display = display.none, inline = "Inp2")

Inp3Text  = input.string("Example 3",  "", group = "Row Text", display = display.none, inline = "Inp3")
Inp3Bool  = input.bool(true, "", group = "Row Text", display = display.none, inline = "Inp3")

Inp4Text  = input.string("Example 4",  "", group = "Row Text", display = display.none, inline = "Inp4")
Inp4Bool  = input.bool(false, "", group = "Row Text", display = display.none, inline = "Inp4")

Inp5Text  = input.string("Example 5",  "", group = "Row Text", display = display.none, inline = "Inp5")
Inp5Bool  = input.bool(false, "", group = "Row Text", display = display.none, inline = "Inp5")

Inp6Text  = input.string("Example 6",  "", group = "Row Text", display = display.none, inline = "Inp6")
Inp6Bool  = input.bool(true, "", group = "Row Text", display = display.none, inline = "Inp6")

Inp7Text  = input.string("Example 7",  "", group = "Row Text", display = display.none, inline = "Inp7")
Inp7Bool  = input.bool(true, "", group = "Row Text", display = display.none, inline = "Inp7")



// ─────────────────────────────────────────────
// WATERMARK TABLE INPUTS
// ─────────────────────────────────────────────
display = display.none 

WatterMaketText = input.string("Chart Trader PX", "Watter Mark", group = "Watermark Table", display = display.none)

WM_PosInput = input.string("Top Center", "Position",
     options = ["Top Left","Top Center","Top Right",
                "Middle Left","Middle Center","Middle Right",
                "Bottom Left","Bottom Center","Bottom Right"],
     group = "Watermark Table", display = display.none)

WM_BgColor   = input.color(#45464900, "Background Color",  group = "Watermark Table", display = display.none)
WM_TextColor = input.color(#332e2e49,            "Text Color",         group = "Watermark Table", display = display.none)

WM_SizeInput = input.string("Huge", "Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"],
     group = "Watermark Table", display = display.none)

// ─────────────────────────────────────────────
// INFO TABLE INPUTS
// ─────────────────────────────────────────────
Rows = input.int(7, maxval = 7, minval = 1, group = "Info Table", display = display.none)

IT_PosInput = input.string("Middle Right", "Position",
     options = ["Top Left","Top Center","Top Right",
                "Middle Left","Middle Center","Middle Right",
                "Bottom Left","Bottom Center","Bottom Right"],
     group = "Info Table", display = display.none)

IT_BgColor      = input.color(color.rgb(30, 30, 30),  "Background Color",  group = "Info Table", display = display.none)
IT_TextColor    = input.color(color.white,             "Text Color",         group = "Info Table", display = display.none)
IT_BorderColor  = input.color(color.rgb(80, 80, 80),  "Border Color",       group = "Info Table", display = display.none)
IT_BorderWidth  = input.int(1, "Border Width", minval = 0, maxval = 5,       group = "Info Table", display = display.none)

IT_SizeInput = input.string("Normal", "Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"],
     group = "Info Table", display = display.none)

IT_AlignInput = input.string("Center", "Text Alignment",
     options = ["Left","Center","Right"],
     group = "Info Table", display = display.none)

IT_ShowHeader  = input.bool(true,  "Show Header Row",   group = "Info Table", display = display.none)
IT_HeaderText  = input.string("My Checklist", "Header Title", group = "Info Table", display = display.none)
IT_HeaderColor = input.color(color.rgb(50, 100, 180), "Header BG Color", group = "Info Table", display = display.none)

FT_SizeInput = input.string("Normal", "Text Size",
     options = ["Tiny","Small","Normal","Large","Huge"],
     group = "Info Table", display = display.none)
IT_ShowFooter  = input.bool(true, "Show Footer Row", group = "Info Table", display = display.none)
IT_FooterText  = input.text_area("▶ YouTube: @channel  \n\n📸 Instagram: @handle", "Footer Text", group = "Info Table", display = display.none)
IT_FooterTextColor  = input.color(color.rgb(180, 180, 180), "Footer Text", group = "Info Table", display = display.none)
IT_FooterBgColor = input.color(color.rgb(20, 20, 20), "Footer BG Color", group = "Info Table", display = display.none)


// ─────────────────────────────────────────────
// COMBINE TEXT + EMOJI BASED ON BOOL
// ─────────────────────────────────────────────

Inp1TextFull  = Inp1Text  + (Inp1Bool  ? " ✅" : " ❌")
Inp2TextFull  = Inp2Text  + (Inp2Bool  ? " ✅" : " ❌")
Inp3TextFull  = Inp3Text  + (Inp3Bool  ? " ✅" : " ❌")
Inp4TextFull  = Inp4Text  + (Inp4Bool  ? " ✅" : " ❌")
Inp5TextFull  = Inp5Text  + (Inp5Bool  ? " ✅" : " ❌")
Inp6TextFull  = Inp6Text  + (Inp6Bool  ? " ✅" : " ❌")
Inp7TextFull  = Inp7Text  + (Inp7Bool  ? " ✅" : " ❌")


// ─────────────────────────────────────────────
// HELPER: String → position.*
// ─────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top Left"       => position.top_left
        "Top Center"     => position.top_center
        "Top Right"      => position.top_right
        "Middle Left"    => position.middle_left
        "Middle Center"  => position.middle_center
        "Middle Right"   => position.middle_right
        "Bottom Left"    => position.bottom_left
        "Bottom Center"  => position.bottom_center
        => position.bottom_right

// ─────────────────────────────────────────────
// HELPER: String → size.*
// ─────────────────────────────────────────────
f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

// ─────────────────────────────────────────────
// HELPER: String → text.align_*
// ─────────────────────────────────────────────
f_align(string s) =>
    switch s
        "Left"  => text.align_left
        "Right" => text.align_right
        => text.align_center

// ─────────────────────────────────────────────
// DRAW TABLES
// ─────────────────────────────────────────────
if barstate.islast

    // ── Watermark Table ──────────────────────
    WatterMaket = table.new(f_pos(WM_PosInput), 1, 1, WM_BgColor)
    table.cell(WatterMaket, 0, 0, WatterMaketText,
         text_color      = WM_TextColor,
         width           = 50,
         height          = 10,
         text_size       = f_size(WM_SizeInput),
         text_formatting = text.format_bold)

    // ── Info Table ───────────────────────────
    int headerRows = IT_ShowHeader ? 1 : 0
    int footerRows = IT_ShowFooter ? 1 : 0
    int totalRows  = headerRows + Rows + footerRows
    InpTable = table.new(f_pos(IT_PosInput), 1, totalRows,
         border_color = IT_BorderColor,
         border_width = IT_BorderWidth)

    // Optional header row
    if IT_ShowHeader
        table.cell(InpTable, 0, 0, IT_HeaderText,
             bgcolor         = IT_HeaderColor,
             text_color      = color.white,
             text_size       = f_size(IT_SizeInput),
             text_halign     = text.align_center,
             text_formatting = text.format_bold)

    int startRow = IT_ShowHeader ? 1 : 0
    cx = 0
    while cx < Rows
        cx += 1
        string Text = ""
        if cx == 1
            Text := Inp1TextFull
        if cx == 2
            Text := Inp2TextFull
        if cx == 3
            Text := Inp3TextFull
        if cx == 4
            Text := Inp4TextFull
        if cx == 5
            Text := Inp5TextFull
        if cx == 6
            Text := Inp6TextFull
        if cx == 7
            Text := Inp7TextFull
        
        table.cell(InpTable, 0, startRow + cx - 1, Text,
             bgcolor     = IT_BgColor,
             text_color  = IT_TextColor,
             text_size   = f_size(IT_SizeInput),
             text_halign = f_align(IT_AlignInput))

    // Optional footer row
    if IT_ShowFooter

        table.cell(InpTable, 0, startRow + Rows, IT_FooterText,
             bgcolor     = IT_FooterBgColor,
             text_color  = IT_FooterTextColor,
             text_size   = f_size(FT_SizeInput),
             text_halign = text.align_center)
````
