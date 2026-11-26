# Daily Price Table

- url: https://www.tradingview.com/script/ZCgDlyjr-Daily-Price-Table/
- type: indicator
- pine_id: PUB;eb4fcd76e2ce4a518ee8667ad562f91a
- version: 1.0

## Description

Features

Shows the last 1–50 daily closes in a compact table, most recent first
▲ / ▼ / — directional arrows on every row at a glance
Color-coded rows — green tint for up days, red tint for down days
Change % and Change (points) columns with +/− prefix
Optional columns: Date, Open, High, Low, Volume (auto-formatted as K/M/B)

## Source Code

````pine
//@version=6
indicator("Daily Price Table", overlay=true, max_bars_back=500)

// ═══════════════════════════════════════════════════════
//  GROUPS
// ═══════════════════════════════════════════════════════
grp_table  = "Table Style"
grp_colors = "Color Settings"
grp_text   = "Text & Size"
grp_data   = "Data Settings"

// ═══════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════

// Position & text
i_pos      = input.string("Top Right", "Table Position",
             options=["Top Right","Top Left","Top Center",
                      "Bottom Right","Bottom Left","Bottom Center",
                      "Middle Right","Middle Left","Middle Center"],
             group=grp_table)
i_textSize = input.string("Normal", "Text Size",
             options=["Tiny","Small","Normal","Large","Huge"],
             group=grp_text)

// Border widths as integers (0-4) — Pine has no border_width namespace
i_borderW  = input.int(1, "Border Width (0=None)", minval=0, maxval=4, group=grp_table)
i_frameW   = input.int(1, "Frame Width  (0=None)", minval=0, maxval=4, group=grp_table)

// Data
i_rows     = input.int(10, "Number of Days to Show", minval=1, maxval=50, group=grp_data)
i_decimals = input.int(2,  "Price Decimal Places",   minval=0, maxval=8,  group=grp_data)

// Header colours
i_headerBg  = input.color(color.new(#1a1a2e, 0), "Header Background", group=grp_colors)
i_headerTxt = input.color(color.new(#e2e2ff, 0), "Header Text",       group=grp_colors)

// Row colours
i_rowBgEven = input.color(color.new(#16213e, 10), "Row BG (Even)", group=grp_colors)
i_rowBgOdd  = input.color(color.new(#0f3460, 20), "Row BG (Odd)",  group=grp_colors)
i_rowTxt    = input.color(color.new(#d4d4d4, 0),  "Row Text",      group=grp_colors)

// Direction colours
i_upColor   = input.color(color.new(#00c896, 0), "Up Colour   ▲",  group=grp_colors)
i_dnColor   = input.color(color.new(#ff4d6d, 0), "Down Colour ▼",  group=grp_colors)
i_flatColor = input.color(color.new(#aaaaaa, 0), "Flat Colour  —", group=grp_colors)

// Border colour
i_borderClr = input.color(color.new(#3a3a5c, 0), "Border / Frame Color", group=grp_colors)

// Row highlight
i_hlRow     = input.bool(true, "Tint Row with Direction", group=grp_colors)

// Column toggles
i_showDate  = input.bool(true,  "Show Date Column",        group=grp_data)
i_showOpen  = input.bool(false, "Show Open Column",        group=grp_data)
i_showHL    = input.bool(false, "Show High / Low Columns", group=grp_data)
i_showVol   = input.bool(false, "Show Volume Column",      group=grp_data)
i_showPts   = input.bool(false, "Show Change (Points)",    group=grp_data)
i_showPct   = input.bool(true,  "Show Change % Column",    group=grp_data)

// ═══════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════

f_pos() =>
    switch i_pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        =>                 position.middle_center

f_sz() =>
    switch i_textSize
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        =>         size.normal

f_round(v, d) =>
    f = math.pow(10, d)
    math.round(v * f) / f

f_fmt(v) =>
    str.tostring(f_round(v, i_decimals))

f_vol(v) =>
    v >= 1.0e9 ? str.tostring(math.round(v / 1.0e9, 2)) + "B" :
     v >= 1.0e6 ? str.tostring(math.round(v / 1.0e6, 2)) + "M" :
     v >= 1.0e3 ? str.tostring(math.round(v / 1.0e3, 1)) + "K" :
     str.tostring(math.round(v, 0))

// ═══════════════════════════════════════════════════════
//  DAILY DATA
// ═══════════════════════════════════════════════════════

d_close  = request.security(syminfo.tickerid, "D", close,   lookahead=barmerge.lookahead_off)
d_open   = request.security(syminfo.tickerid, "D", open,    lookahead=barmerge.lookahead_off)
d_high   = request.security(syminfo.tickerid, "D", high,    lookahead=barmerge.lookahead_off)
d_low    = request.security(syminfo.tickerid, "D", low,     lookahead=barmerge.lookahead_off)
d_vol    = request.security(syminfo.tickerid, "D", volume,  lookahead=barmerge.lookahead_off)
d_prev   = request.security(syminfo.tickerid, "D", close[1],lookahead=barmerge.lookahead_off)
d_time   = request.security(syminfo.tickerid, "D", time,    lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════
//  BUILD TABLE  (last bar only)
// ═══════════════════════════════════════════════════════

if barstate.islast

    // Count columns
    ncols = 1
    if i_showDate
        ncols := ncols + 1
    if i_showOpen
        ncols := ncols + 1
    if i_showHL
        ncols := ncols + 2
    if i_showVol
        ncols := ncols + 1
    if i_showPts
        ncols := ncols + 1
    if i_showPct
        ncols := ncols + 1

    tbl = table.new(
         position     = f_pos(),
         columns      = ncols,
         rows         = i_rows + 1,
         bgcolor      = i_headerBg,
         border_color = i_borderClr,
         border_width = i_borderW,
         frame_color  = i_borderClr,
         frame_width  = i_frameW)

    // ── Header ──────────────────────────────────────────
    c = 0
    if i_showDate
        table.cell(tbl, c, 0, "Date",
             text_color=i_headerTxt, text_size=f_sz(),
             bgcolor=i_headerBg, text_halign=text.align_center)
        c := c + 1

    table.cell(tbl, c, 0, "Close",
         text_color=i_headerTxt, text_size=f_sz(),
         bgcolor=i_headerBg, text_halign=text.align_right)
    c := c + 1

    if i_showOpen
        table.cell(tbl, c, 0, "Open",
             text_color=i_headerTxt, text_size=f_sz(),
             bgcolor=i_headerBg, text_halign=text.align_right)
        c := c + 1

    if i_showHL
        table.cell(tbl, c, 0, "High",
             text_color=i_headerTxt, text_size=f_sz(),
             bgcolor=i_headerBg, text_halign=text.align_right)
        c := c + 1
        table.cell(tbl, c, 0, "Low",
             text_color=i_headerTxt, text_size=f_sz(),
             bgcolor=i_headerBg, text_halign=text.align_right)
        c := c + 1

    if i_showVol
        table.cell(tbl, c, 0, "Volume",
             text_color=i_headerTxt, text_size=f_sz(),
             bgcolor=i_headerBg, text_halign=text.align_right)
        c := c + 1

    if i_showPts
        table.cell(tbl, c, 0, "Chg",
             text_color=i_headerTxt, text_size=f_sz(),
             bgcolor=i_headerBg, text_halign=text.align_right)
        c := c + 1

    if i_showPct
        table.cell(tbl, c, 0, "Chg %",
             text_color=i_headerTxt, text_size=f_sz(),
             bgcolor=i_headerBg, text_halign=text.align_right)

    // ── Data rows ────────────────────────────────────────
    for i = 0 to i_rows - 1
        cl  = d_close[i]
        op  = d_open [i]
        hi  = d_high [i]
        lo  = d_low  [i]
        vl  = d_vol  [i]
        pc  = d_prev [i]
        ts  = d_time [i]
        row = i + 1

        chgPts = cl - pc
        chgPct = pc != 0 ? (chgPts / pc) * 100.0 : 0.0

        arrow    = chgPct > 0.0 ? " ▲" : chgPct < 0.0 ? " ▼" : " —"
        dirColor = chgPct > 0.0 ? i_upColor : chgPct < 0.0 ? i_dnColor : i_flatColor
        rowBg    = i_hlRow ? color.new(dirColor, 85) : row % 2 == 0 ? i_rowBgEven : i_rowBgOdd
        txtColor = i_hlRow ? dirColor : i_rowTxt

        dateStr   = str.format("{0,date,dd MMM yy}", ts)
        closeStr  = f_fmt(cl) + arrow
        chgPtsStr = (chgPts >= 0.0 ? "+" : "") + f_fmt(chgPts)
        chgPctStr = (chgPct >= 0.0 ? "+" : "") + str.tostring(math.round(chgPct * 100.0) / 100.0) + "%"

        c := 0
        if i_showDate
            table.cell(tbl, c, row, dateStr,
                 text_color=i_rowTxt, text_size=f_sz(),
                 bgcolor=rowBg, text_halign=text.align_center)
            c := c + 1

        table.cell(tbl, c, row, closeStr,
             text_color=dirColor, text_size=f_sz(),
             bgcolor=rowBg, text_halign=text.align_right)
        c := c + 1

        if i_showOpen
            table.cell(tbl, c, row, f_fmt(op),
                 text_color=txtColor, text_size=f_sz(),
                 bgcolor=rowBg, text_halign=text.align_right)
            c := c + 1

        if i_showHL
            table.cell(tbl, c, row, f_fmt(hi),
                 text_color=i_upColor, text_size=f_sz(),
                 bgcolor=rowBg, text_halign=text.align_right)
            c := c + 1
            table.cell(tbl, c, row, f_fmt(lo),
                 text_color=i_dnColor, text_size=f_sz(),
                 bgcolor=rowBg, text_halign=text.align_right)
            c := c + 1

        if i_showVol
            table.cell(tbl, c, row, f_vol(vl),
                 text_color=txtColor, text_size=f_sz(),
                 bgcolor=rowBg, text_halign=text.align_right)
            c := c + 1

        if i_showPts
            table.cell(tbl, c, row, chgPtsStr,
                 text_color=dirColor, text_size=f_sz(),
                 bgcolor=rowBg, text_halign=text.align_right)
            c := c + 1

        if i_showPct
            table.cell(tbl, c, row, chgPctStr,
                 text_color=dirColor, text_size=f_sz(),
                 bgcolor=rowBg, text_halign=text.align_right)
````
