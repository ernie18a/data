# Chart Banner

- url: https://www.tradingview.com/script/TvhYmocZ-Chart-Banner/
- type: indicator
- pine_id: PUB;ae6df959dd264fadb0feeeef67e5d184
- version: 5.0

## Description

Keep yourself in check with your rules right in your face

## Source Code

````pine
//@version=6
indicator("Chart Banner", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
string line1      = input.string("Be Boring. Be Consistent.",      title="Line 1 Text")
bool   show_line2 = input.bool(true,                               title="Show Line 2")
string line2      = input.string("Same Process · Same Discipline", title="Line 2 Text")
bool   show_line3 = input.bool(true,                               title="Show Line 3")
string line3      = input.string("Trust the System.",              title="Line 3 Text")

color  bg_color   = input.color(color.new(#111122, 15), title="Background Color")
color  txt1_color = input.color(color.white,             title="Line 1 Color")
color  txt2_color = input.color(color.new(#aaaaaa, 0),  title="Line 2 Color")
color  txt3_color = input.color(color.new(#aaaaaa, 0),  title="Line 3 Color")

string pos = input.string("Top Center", title="Position",
                options=["Top Left","Top Center","Top Right",
                         "Bottom Left","Bottom Center","Bottom Right"])

string sz = input.string("Normal", title="Text Size",
                options=["Tiny","Small","Normal","Large","Huge"])

// ─── Helpers ──────────────────────────────────────────────────────────────────
tsize(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        =>         size.normal

tpos(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.top_center

// ─── Table ────────────────────────────────────────────────────────────────────
var table t = na

if barstate.islast
    if not na(t)
        table.delete(t)

    rows = 1 + (show_line2 ? 1 : 0) + (show_line3 ? 1 : 0)
    t := table.new(tpos(pos), 1, rows,
         bgcolor      = bg_color,
         border_width = 0,
         frame_width  = 0)

    table.cell(t, 0, 0,
         text       = line1,
         text_color = txt1_color,
         text_size  = tsize(sz),
         bgcolor    = bg_color)

    row = 1
    if show_line2
        table.cell(t, 0, row,
             text       = line2,
             text_color = txt2_color,
             text_size  = size.small,
             bgcolor    = bg_color)
        row := row + 1

    if show_line3
        table.cell(t, 0, row,
             text       = line3,
             text_color = txt3_color,
             text_size  = size.small,
             bgcolor    = bg_color)
//t
````
