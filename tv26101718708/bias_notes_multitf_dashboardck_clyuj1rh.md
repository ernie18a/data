# BIAS Notes - Multi-TF Dashboard(CK)

- url: https://www.tradingview.com/script/ClYUJ1rh-BIAS-Notes-Multi-TF-Dashboard-CK/
- type: indicator
- pine_id: PUB;9554586c3804427793900704e3c21625
- version: 1.0

## Description

Made by CK for Daily bias.We can do analysis for daily, weekly, 4hr, monthly and all time frames. Basically used for top down analysis,

## Source Code

````pine
//@version=6
indicator("BIAS Notes - Multi-TF Dashboard", overlay=true, max_labels_count=500)

// ============================================================
//  INPUTS — Timeframe Labels & Bias
// ============================================================
grp1 = "Timeframe Settings"

tf1_label = input.string("Monthly", "TF 1 Label", group=grp1)
tf1_bias  = input.string("Bullish", "TF 1 Bias",  options=["Bullish","Bearish","Wait","None"], group=grp1)

tf2_label = input.string("Weekly",  "TF 2 Label", group=grp1)
tf2_bias  = input.string("Bullish", "TF 2 Bias",  options=["Bullish","Bearish","Wait","None"], group=grp1)

tf3_label = input.string("Daily",   "TF 3 Label", group=grp1)
tf3_bias  = input.string("Bullish", "TF 3 Bias",  options=["Bullish","Bearish","Wait","None"], group=grp1)

tf4_label = input.string("4HR",     "TF 4 Label", group=grp1)
tf4_bias  = input.string("Bullish", "TF 4 Bias",  options=["Bullish","Bearish","Wait","None"], group=grp1)

tf5_label = input.string("1HR",     "TF 5 Label", group=grp1)
tf5_bias  = input.string("Bullish", "TF 5 Bias",  options=["Bullish","Bearish","Wait","None"], group=grp1)

tf6_label = input.string("15min",   "TF 6 Label", group=grp1)
tf6_bias  = input.string("Bullish", "TF 6 Bias",  options=["Bullish","Bearish","Wait","None"], group=grp1)

tf7_label = input.string("5min",    "TF 7 Label", group=grp1)
tf7_bias  = input.string("Bullish", "TF 7 Bias",  options=["Bullish","Bearish","Wait","None"], group=grp1)

// ============================================================
//  DISPLAY SETTINGS
// ============================================================
grp2 = "Display Settings"
show_table  = input.bool(true, "Show Table (uncheck = horizontal dots strip)", group=grp2)
show_icons  = input.bool(true, "Show Traffic Light Icons (table mode only)",   group=grp2)
tbl_pos     = input.string("Top Right", "Position",
     options=["Top Right","Top Left","Top Center",
              "Bottom Right","Bottom Left","Bottom Center",
              "Middle Right","Middle Left","Middle Center"], group=grp2)
txt_size_in = input.string("Normal", "Text Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=grp2)

// ============================================================
//  HELPERS
// ============================================================
f_pos(p) =>
    switch p
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.middle_center

f_size(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

f_color(bias) =>
    switch bias
        "Bullish" => color.new(#00C853, 0)
        "Bearish" => color.new(#D50000, 0)
        "Wait"    => color.new(#FF6D00, 0)
        => color.new(#455A64, 60)

f_icon(bias) =>
    switch bias
        "Bullish" => "🟢"
        "Bearish" => "🔴"
        "Wait"    => "🟠"
        => "⚫"

f_short(bias) =>
    switch bias
        "Bullish" => "▲ BULL"
        "Bearish" => "▼ BEAR"
        "Wait"    => "◆ WAIT"
        => "—"

// ============================================================
//  DATA ARRAYS
// ============================================================
tfs    = array.from(tf1_label, tf2_label, tf3_label, tf4_label, tf5_label, tf6_label, tf7_label)
biases = array.from(tf1_bias,  tf2_bias,  tf3_bias,  tf4_bias,  tf5_bias,  tf6_bias,  tf7_bias)

// ============================================================
//  MODE A — VERTICAL TABLE  (show_table = true)
// ============================================================
var table tbl_v = na

if show_table and barstate.islast
    int cols = show_icons ? 3 : 2
    tbl_v := table.new(
         f_pos(tbl_pos), columns=cols, rows=8,
         bgcolor      = color.new(#0D1117, 10),
         border_color = color.new(#30363D, 0),
         border_width = 1,
         frame_color  = color.new(#58A6FF, 80),
         frame_width  = 2)

    sz = f_size(txt_size_in)

    // Header row
    table.cell(tbl_v, 0, 0, "  TIMEFRAME  ",
         text_color=color.new(#8B949E,0), text_size=sz,
         bgcolor=color.new(#161B22,0), text_halign=text.align_center)
    table.cell(tbl_v, 1, 0, "  BIAS  ",
         text_color=color.new(#8B949E,0), text_size=sz,
         bgcolor=color.new(#161B22,0), text_halign=text.align_center)
    if show_icons
        table.cell(tbl_v, 2, 0, "  SIGNAL  ",
             text_color=color.new(#8B949E,0), text_size=sz,
             bgcolor=color.new(#161B22,0), text_halign=text.align_center)

    // Data rows
    for i = 0 to 6
        lbl  = array.get(tfs,    i)
        bias = array.get(biases, i)
        clr  = f_color(bias)
        row  = i + 1

        table.cell(tbl_v, 0, row, "  " + lbl + "  ",
             text_color=color.new(#E6EDF3,0), text_size=sz,
             bgcolor=color.new(#0D1117,0), text_halign=text.align_left)

        table.cell(tbl_v, 1, row, "  " + f_short(bias) + "  ",
             text_color=color.new(#FFFFFF,0), text_size=sz,
             bgcolor=color.new(clr, 55), text_halign=text.align_center)

        if show_icons
            table.cell(tbl_v, 2, row, "  " + f_icon(bias) + "  ",
                 text_color=color.new(#FFFFFF,0), text_size=sz,
                 bgcolor=color.new(#0D1117,0), text_halign=text.align_center)

// ============================================================
//  MODE B — HORIZONTAL DOTS STRIP  (show_table = false)
//
//  2 rows × 7 columns:
//    Row 0 → TF label  (dark header cell)
//    Row 1 → Coloured dot  ⬤  on tinted background
// ============================================================
var table tbl_h = na

if not show_table and barstate.islast
    tbl_h := table.new(
         f_pos(tbl_pos), columns=7, rows=2,
         bgcolor      = color.new(#0D1117, 10),
         border_color = color.new(#30363D, 0),
         border_width = 1,
         frame_color  = color.new(#58A6FF, 80),
         frame_width  = 2)

    sz = f_size(txt_size_in)

    for i = 0 to 6
        lbl  = array.get(tfs,    i)
        bias = array.get(biases, i)
        clr  = f_color(bias)

        // Row 0 — TF label
        table.cell(tbl_h, i, 0, " " + lbl + " ",
             text_color  = color.new(#E6EDF3, 0),
             text_size   = sz,
             bgcolor     = color.new(#1C3A4A, 0),
             text_halign = text.align_center)

        // Row 1 — Coloured dot
        table.cell(tbl_h, i, 1, " ⬤ ",
             text_color  = clr,
             text_size   = size.large,
             bgcolor     = color.new(clr, 80),
             text_halign = text.align_center)

// ============================================================
//  STATUS-LINE SUMMARY
// ============================================================
if barstate.islast
    _s = tf1_label + ":" + f_icon(tf1_bias) + "  " +
         tf2_label + ":" + f_icon(tf2_bias) + "  " +
         tf3_label + ":" + f_icon(tf3_bias) + "  " +
         tf4_label + ":" + f_icon(tf4_bias) + "  " +
         tf5_label + ":" + f_icon(tf5_bias) + "  " +
         tf6_label + ":" + f_icon(tf6_bias) + "  " +
         tf7_label + ":" + f_icon(tf7_bias)

plot(0, display=display.status_line, title="BIAS Summary", color=color.new(color.white,100))
````
