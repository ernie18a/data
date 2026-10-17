# Snoop Confluence Stacking

- url: https://www.tradingview.com/script/jRHOEn1m-Snoop-Confluence-Stacking/
- type: indicator
- pine_id: PUB;5852b7ede99c4019a63b5ca00f6fe7d1
- version: 1.0

## Description

Mechanical trading checklist for a repeatable consistent trader

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Snoopynuts

// © Snoop — Follow the Flow
//@version=6
indicator("Snoop Confluence Stacking", shorttitle="SCS", overlay=true)

// ╔═══════════════════════════════════════════════════════════╗
// ║                    TABLE SETTINGS                         ║
// ╚═══════════════════════════════════════════════════════════╝
g_tbl = "📊 Table Settings"
i_position   = input.string("Top Right", "Position",
     options=["Top Left", "Top Center", "Top Right",
              "Middle Left", "Middle Center", "Middle Right",
              "Bottom Left", "Bottom Center", "Bottom Right"], group=g_tbl)
i_size       = input.string("Normal", "Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_tbl)
i_minScore   = input.int(5, "Min Confluences for Valid Setup", minval=1, maxval=7, group=g_tbl)
i_showScore  = input.bool(true, "Show Score Row",  group=g_tbl)
i_showFooter = input.bool(true, "Show Footer",     group=g_tbl)

// ╔═══════════════════════════════════════════════════════════╗
// ║                       COLORS                              ║
// ╚═══════════════════════════════════════════════════════════╝
g_col = "🎨 Colors"
i_bgColor     = input.color(color.new(#0d1117, 10), "Cell Background",       group=g_col)
i_borderColor = input.color(color.new(#30363d, 0),  "Border / Frame",        group=g_col)
i_titleBg     = input.color(color.new(#1f6feb, 0),  "Title Background",      group=g_col)
i_titleText   = input.color(color.white,            "Title Text",            group=g_col)
i_labelText   = input.color(#e6edf3,                "Label Text",            group=g_col)
i_tickColor   = input.color(#3fb950,                "Tick (✓) Color",        group=g_col)
i_crossColor  = input.color(#f85149,                "Cross (✗) Color",       group=g_col)
i_validBg     = input.color(color.new(#3fb950, 75), "Valid Setup BG Tint",   group=g_col)
i_invalidBg   = input.color(color.new(#f85149, 75), "Invalid Setup BG Tint", group=g_col)
i_footerText  = input.color(color.new(#7d8590, 0),  "Footer Text",           group=g_col)

// ╔═══════════════════════════════════════════════════════════╗
// ║                    CONFLUENCES (1-7)                      ║
// ╚═══════════════════════════════════════════════════════════╝
g_c1 = "1️⃣  Confluence 1"
i_c1_name  = input.string("Trend Aligned (HTF)", "Name",  group=g_c1)
i_c1_state = input.bool(false,                   "✓ Met", group=g_c1)

g_c2 = "2️⃣  Confluence 2"
i_c2_name  = input.string("Liquidity Swept",     "Name",  group=g_c2)
i_c2_state = input.bool(false,                   "✓ Met", group=g_c2)

g_c3 = "3️⃣  Confluence 3"
i_c3_name  = input.string("Market Structure Shift", "Name",  group=g_c3)
i_c3_state = input.bool(false,                      "✓ Met", group=g_c3)

g_c4 = "4️⃣  Confluence 4"
i_c4_name  = input.string("FVG / Order Block",   "Name",  group=g_c4)
i_c4_state = input.bool(false,                   "✓ Met", group=g_c4)

g_c5 = "5️⃣  Confluence 5"
i_c5_name  = input.string("Premium / Discount",  "Name",  group=g_c5)
i_c5_state = input.bool(false,                   "✓ Met", group=g_c5)

g_c6 = "6️⃣  Confluence 6"
i_c6_name  = input.string("Killzone Active",     "Name",  group=g_c6)
i_c6_state = input.bool(false,                   "✓ Met", group=g_c6)

g_c7 = "7️⃣  Confluence 7"
i_c7_name  = input.string("Risk:Reward >= 2:1",  "Name",  group=g_c7)
i_c7_state = input.bool(false,                   "✓ Met", group=g_c7)

// ╔═══════════════════════════════════════════════════════════╗
// ║                    HELPER FUNCTIONS                       ║
// ╚═══════════════════════════════════════════════════════════╝
f_pos(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.top_right

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ╔═══════════════════════════════════════════════════════════╗
// ║                       SCORE LOGIC                         ║
// ╚═══════════════════════════════════════════════════════════╝
score = (i_c1_state ? 1 : 0) + (i_c2_state ? 1 : 0) + (i_c3_state ? 1 : 0) +
         (i_c4_state ? 1 : 0) + (i_c5_state ? 1 : 0) + (i_c6_state ? 1 : 0) +
         (i_c7_state ? 1 : 0)
isValid = score >= i_minScore

// ╔═══════════════════════════════════════════════════════════╗
// ║                     BUILD TABLE                           ║
// ╚═══════════════════════════════════════════════════════════╝
var table t = table.new(f_pos(i_position), 2, 10,
     border_color=i_borderColor, border_width=1,
     frame_color=i_borderColor,  frame_width=1)

f_drawRow(int row, string name, bool state) =>
    table.cell(t, 0, row, name,
         text_color=i_labelText, bgcolor=i_bgColor,
         text_size=f_size(i_size), text_halign=text.align_left)
    table.cell(t, 1, row, state ? "✓" : "✗",
         text_color=state ? i_tickColor : i_crossColor, bgcolor=i_bgColor,
         text_size=f_size(i_size), text_halign=text.align_center)

if barstate.islast
    // ─── TITLE ───
    table.cell(t, 0, 0, "CONFLUENCE STACKING",
         text_color=i_titleText, bgcolor=i_titleBg,
         text_size=f_size(i_size), text_halign=text.align_center)
    table.cell(t, 1, 0, "", bgcolor=i_titleBg)
    table.merge_cells(t, 0, 0, 1, 0)

    // ─── 7 CONFLUENCE ROWS ───
    f_drawRow(1, i_c1_name, i_c1_state)
    f_drawRow(2, i_c2_name, i_c2_state)
    f_drawRow(3, i_c3_name, i_c3_state)
    f_drawRow(4, i_c4_name, i_c4_state)
    f_drawRow(5, i_c5_name, i_c5_state)
    f_drawRow(6, i_c6_name, i_c6_state)
    f_drawRow(7, i_c7_name, i_c7_state)

    // ─── SCORE ROW ───
    if i_showScore
        scoreBg     = isValid ? i_validBg : i_invalidBg
        scoreLabel  = "SCORE: " + str.tostring(score) + " / 7"
        statusLabel = isValid ? "VALID ✓" : "WAIT ✗"
        statusColor = isValid ? i_tickColor : i_crossColor
        table.cell(t, 0, 8, scoreLabel,
             text_color=i_labelText, bgcolor=scoreBg,
             text_size=f_size(i_size), text_halign=text.align_left)
        table.cell(t, 1, 8, statusLabel,
             text_color=statusColor, bgcolor=scoreBg,
             text_size=f_size(i_size), text_halign=text.align_center)

    // ─── FOOTER ───
    if i_showFooter
        table.cell(t, 0, 9, "Follow the Flow",
             text_color=i_footerText, bgcolor=i_bgColor,
             text_size=f_size(i_size), text_halign=text.align_center)
        table.cell(t, 1, 9, "", bgcolor=i_bgColor)
        table.merge_cells(t, 0, 9, 1, 9)
````
