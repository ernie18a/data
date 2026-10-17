# Kure 909 Clarity

- url: https://www.tradingview.com/script/oJp0vm8c-Kure-909-Clarity/
- type: indicator
- pine_id: PUB;a48ae6ce4141440db4ae6d89d57b1971
- version: 1.0

## Description

Session Outlines
PDH PDL Level Markers
Session PiP Counters
Medium Inducement Level Markers

## Source Code

````pine
//@version=6
indicator("Kure 909 Clarity", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════
pip_val() => syminfo.mintick * 10.0

fmt_pips(x) =>
    r = math.round(x * 10) / 10
    str.tostring(r) + " pips"

// ═══════════════════════════════════════════════════
// INPUTS — TIMEZONE
// ═══════════════════════════════════════════════════
i_tz = input.string("Europe/Belgrade", "⏱ Timezone",
     options=["UTC","America/New_York","America/Chicago","America/Denver",
              "America/Los_Angeles","Europe/London","Europe/Berlin",
              "Europe/Belgrade","Europe/Athens","Asia/Tokyo","Asia/Shanghai",
              "Asia/Singapore","Asia/Dubai","Australia/Sydney"],
     group="Timezone")

// ═══════════════════════════════════════════════════
// INPUTS — SESSIONS
// ═══════════════════════════════════════════════════
i_days       = input.int(15, "Broj dana unazad", minval=1, maxval=60, group="Sesije")
i_box_trans  = input.int(85, "Transparentnost boxa", minval=0, maxval=100, group="Sesije")
i_box_border = input.int(0,  "Debljina bordera (0=nema)", minval=0, maxval=4, group="Sesije")
i_pip_offset = input.int(3,  "Pip label offset", minval=0, group="Sesije")

i_s1_on      = input.bool(true, "London uključena", group="London (Session 1)")
i_s1_sess    = input.session("0800-1100", "London vreme", group="London (Session 1)")
i_s1_col     = input.color(color.new(color.blue, 85),   "London boja", group="London (Session 1)")
i_s1_pips    = input.bool(true, "London prikaži pips", group="London (Session 1)")
i_s1_pip_col = input.color(color.white, "London pip text boja", group="London (Session 1)")

i_s2_on      = input.bool(true, "New York uključena", group="New York (Session 2)")
i_s2_sess    = input.session("1300-1700", "New York vreme", group="New York (Session 2)")
i_s2_col     = input.color(color.new(color.orange, 85), "New York boja", group="New York (Session 2)")
i_s2_pips    = input.bool(true, "New York prikaži pips", group="New York (Session 2)")
i_s2_pip_col = input.color(color.white, "New York pip text boja", group="New York (Session 2)")

i_s3_on      = input.bool(true, "Azija uključena", group="Azija (Session 3)")
i_s3_sess    = input.session("2200-0600", "Azija vreme", group="Azija (Session 3)")
i_s3_col     = input.color(color.new(color.green, 85),  "Azija boja", group="Azija (Session 3)")
i_s3_pips    = input.bool(true, "Azija prikaži pips", group="Azija (Session 3)")
i_s3_pip_col = input.color(color.white, "Azija pip text boja", group="Azija (Session 3)")

// ═══════════════════════════════════════════════════
// INPUTS — PDH/PDL
// ═══════════════════════════════════════════════════
i_pdh_on   = input.bool(true, "Prikaži PDH", group="PDH / PDL")
i_pdl_on   = input.bool(true, "Prikaži PDL", group="PDH / PDL")
i_pdh_col  = input.color(color.red,  "PDH boja", group="PDH / PDL")
i_pdl_col  = input.color(color.lime, "PDL boja", group="PDH / PDL")
i_pd_style = input.string("Dashed", "Stil linije", options=["Solid","Dashed","Dotted"], group="PDH / PDL")
i_pd_width = input.int(2, "Debljina linije", minval=1, maxval=4, group="PDH / PDL")
i_pd_left  = input.int(50, "Extend levo (barova)", minval=1, maxval=500, group="PDH / PDL",
              tooltip="Koliko barova unazad da se proteže PDH/PDL linija. Desni kraj je uvek trenutni bar.")

pd_ls = i_pd_style == "Solid" ? line.style_solid : i_pd_style == "Dashed" ? line.style_dashed : line.style_dotted

// ═══════════════════════════════════════════════════
// INPUTS — MIP
// ═══════════════════════════════════════════════════
i_mip_on       = input.bool(true,  "Prikaži MIP", group="MIP")
i_internal_max = input.float(15.0, "Internal max (pipi)", minval=1.0, step=1.0, group="MIP",
                  tooltip="Swing amplituda ispod ovoga = internal, ignoriše se.")
i_external_min = input.float(50.0, "External min (pipi)", minval=1.0, step=1.0, group="MIP",
                  tooltip="Swing amplituda iznad ovoga = external, ignoriše se. Između = MIP.")
i_mip_llen     = input.int(20, "Dužina linije (±barova)", minval=5, maxval=100, group="MIP")
i_mip_h_col    = input.color(color.orange, "MIP High boja", group="MIP")
i_mip_l_col    = input.color(color.aqua,   "MIP Low boja",  group="MIP")
i_mip_width    = input.int(2, "MIP debljina", minval=1, maxval=4, group="MIP")
i_mip_style    = input.string("Dashed", "MIP stil", options=["Solid","Dashed","Dotted"], group="MIP")

mip_ls = i_mip_style == "Solid" ? line.style_solid : i_mip_style == "Dashed" ? line.style_dashed : line.style_dotted

// ═══════════════════════════════════════════════════
// PDH / PDL
// ═══════════════════════════════════════════════════
pdh_val = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl_val = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

is_new_day = ta.change(time("D", i_tz)) != 0

var line  pdh_ln   = na
var line  pdl_ln   = na
var label pdh_lbl  = na
var label pdl_lbl  = na
var bool  is_today = false

if is_new_day or barstate.isfirst
    is_today := true

if i_pdh_on and not na(pdh_val) and is_today
    if not na(pdh_ln)
        line.delete(pdh_ln)
    if not na(pdh_lbl)
        label.delete(pdh_lbl)
    pdh_ln := line.new(
         x1=bar_index - i_pd_left, y1=pdh_val,
         x2=bar_index,             y2=pdh_val,
         xloc=xloc.bar_index, extend=extend.none,
         color=i_pdh_col, style=pd_ls, width=i_pd_width)
    pdh_lbl := label.new(
         x=bar_index - i_pd_left, y=pdh_val, text="PDH",
         xloc=xloc.bar_index, yloc=yloc.price,
         color=color.new(i_pdh_col, 100), textcolor=i_pdh_col,
         style=label.style_label_right, size=size.small)

if i_pdl_on and not na(pdl_val) and is_today
    if not na(pdl_ln)
        line.delete(pdl_ln)
    if not na(pdl_lbl)
        label.delete(pdl_lbl)
    pdl_ln := line.new(
         x1=bar_index - i_pd_left, y1=pdl_val,
         x2=bar_index,             y2=pdl_val,
         xloc=xloc.bar_index, extend=extend.none,
         color=i_pdl_col, style=pd_ls, width=i_pd_width)
    pdl_lbl := label.new(
         x=bar_index - i_pd_left, y=pdl_val, text="PDL",
         xloc=xloc.bar_index, yloc=yloc.price,
         color=color.new(i_pdl_col, 100), textcolor=i_pdl_col,
         style=label.style_label_right, size=size.small)

if not i_pdh_on
    if not na(pdh_ln)
        line.delete(pdh_ln)
        pdh_ln := na
    if not na(pdh_lbl)
        label.delete(pdh_lbl)
        pdh_lbl := na

if not i_pdl_on
    if not na(pdl_ln)
        line.delete(pdl_ln)
        pdl_ln := na
    if not na(pdl_lbl)
        label.delete(pdl_lbl)
        pdl_lbl := na

// ═══════════════════════════════════════════════════
// SESSIONS
// ═══════════════════════════════════════════════════
cutoff = timenow - i_days * 86400000

// ─── LONDON ──────────────────────────────────────
var int   s1t       = na
var float s1h       = na
var float s1l       = na
var box   s1b_live  = na
var label s1lb_live = na

in_s1    = not na(time(timeframe.period, i_s1_sess, i_tz))
s1_start = in_s1 and not in_s1[1]
s1_end   = not in_s1 and in_s1[1]

if is_new_day and not in_s1
    s1t := na
    s1h := na
    s1l := na

if s1_start
    s1t := time
    s1h := high
    s1l := low

if in_s1
    s1h := na(s1h) ? high : math.max(s1h, high)
    s1l := na(s1l) ? low  : math.min(s1l, low)

if in_s1 and i_s1_on and not na(s1t) and s1t >= cutoff
    if not na(s1b_live)
        box.delete(s1b_live)
    if not na(s1lb_live)
        label.delete(s1lb_live)
    s1b_live := box.new(s1t, s1h, time, s1l,
         xloc=xloc.bar_time, bgcolor=color.new(i_s1_col, i_box_trans),
         border_color=i_box_border > 0 ? color.new(i_s1_col, 50) : na,
         border_width=i_box_border)
    if i_s1_pips
        pip  = pip_val()
        pips = (s1h - s1l) / pip
        s1lb_live := label.new(time, s1l - pip * i_pip_offset,
             pips > 0 ? fmt_pips(pips) : "< 1 pip",
             xloc=xloc.bar_time, yloc=yloc.price,
             color=color.new(i_s1_pip_col, 100), textcolor=i_s1_pip_col,
             style=label.style_label_up, size=size.small)

if s1_end and i_s1_on and not na(s1t) and s1t >= cutoff
    if not na(s1b_live)
        box.delete(s1b_live)
        s1b_live := na
    if not na(s1lb_live)
        label.delete(s1lb_live)
        s1lb_live := na
    box.new(s1t, s1h, time[1], s1l,
         xloc=xloc.bar_time, bgcolor=color.new(i_s1_col, i_box_trans),
         border_color=i_box_border > 0 ? color.new(i_s1_col, 50) : na,
         border_width=i_box_border)
    if i_s1_pips
        pip  = pip_val()
        pips = (s1h - s1l) / pip
        label.new(time[1], s1l - pip * i_pip_offset,
             pips > 0 ? fmt_pips(pips) : "< 1 pip",
             xloc=xloc.bar_time, yloc=yloc.price,
             color=color.new(i_s1_pip_col, 100), textcolor=i_s1_pip_col,
             style=label.style_label_up, size=size.small)

// ─── NEW YORK ─────────────────────────────────────
var int   s2t       = na
var float s2h       = na
var float s2l       = na
var box   s2b_live  = na
var label s2lb_live = na

in_s2    = not na(time(timeframe.period, i_s2_sess, i_tz))
s2_start = in_s2 and not in_s2[1]
s2_end   = not in_s2 and in_s2[1]

if is_new_day and not in_s2
    s2t := na
    s2h := na
    s2l := na

if s2_start
    s2t := time
    s2h := high
    s2l := low

if in_s2
    s2h := na(s2h) ? high : math.max(s2h, high)
    s2l := na(s2l) ? low  : math.min(s2l, low)

if in_s2 and i_s2_on and not na(s2t) and s2t >= cutoff
    if not na(s2b_live)
        box.delete(s2b_live)
    if not na(s2lb_live)
        label.delete(s2lb_live)
    s2b_live := box.new(s2t, s2h, time, s2l,
         xloc=xloc.bar_time, bgcolor=color.new(i_s2_col, i_box_trans),
         border_color=i_box_border > 0 ? color.new(i_s2_col, 50) : na,
         border_width=i_box_border)
    if i_s2_pips
        pip  = pip_val()
        pips = (s2h - s2l) / pip
        s2lb_live := label.new(time, s2l - pip * i_pip_offset,
             pips > 0 ? fmt_pips(pips) : "< 1 pip",
             xloc=xloc.bar_time, yloc=yloc.price,
             color=color.new(i_s2_pip_col, 100), textcolor=i_s2_pip_col,
             style=label.style_label_up, size=size.small)

if s2_end and i_s2_on and not na(s2t) and s2t >= cutoff
    if not na(s2b_live)
        box.delete(s2b_live)
        s2b_live := na
    if not na(s2lb_live)
        label.delete(s2lb_live)
        s2lb_live := na
    box.new(s2t, s2h, time[1], s2l,
         xloc=xloc.bar_time, bgcolor=color.new(i_s2_col, i_box_trans),
         border_color=i_box_border > 0 ? color.new(i_s2_col, 50) : na,
         border_width=i_box_border)
    if i_s2_pips
        pip  = pip_val()
        pips = (s2h - s2l) / pip
        label.new(time[1], s2l - pip * i_pip_offset,
             pips > 0 ? fmt_pips(pips) : "< 1 pip",
             xloc=xloc.bar_time, yloc=yloc.price,
             color=color.new(i_s2_pip_col, 100), textcolor=i_s2_pip_col,
             style=label.style_label_up, size=size.small)

// ─── AZIJA ────────────────────────────────────────
var int   s3t       = na
var float s3h       = na
var float s3l       = na
var box   s3b_live  = na
var label s3lb_live = na

in_s3    = not na(time(timeframe.period, i_s3_sess, i_tz))
s3_start = in_s3 and not in_s3[1]
s3_end   = not in_s3 and in_s3[1]

if is_new_day and not in_s3
    s3t := na
    s3h := na
    s3l := na

if s3_start
    s3t := time
    s3h := high
    s3l := low

if in_s3
    s3h := na(s3h) ? high : math.max(s3h, high)
    s3l := na(s3l) ? low  : math.min(s3l, low)

if in_s3 and i_s3_on and not na(s3t) and s3t >= cutoff
    if not na(s3b_live)
        box.delete(s3b_live)
    if not na(s3lb_live)
        label.delete(s3lb_live)
    s3b_live := box.new(s3t, s3h, time, s3l,
         xloc=xloc.bar_time, bgcolor=color.new(i_s3_col, i_box_trans),
         border_color=i_box_border > 0 ? color.new(i_s3_col, 50) : na,
         border_width=i_box_border)
    if i_s3_pips
        pip  = pip_val()
        pips = (s3h - s3l) / pip
        s3lb_live := label.new(time, s3l - pip * i_pip_offset,
             pips > 0 ? fmt_pips(pips) : "< 1 pip",
             xloc=xloc.bar_time, yloc=yloc.price,
             color=color.new(i_s3_pip_col, 100), textcolor=i_s3_pip_col,
             style=label.style_label_up, size=size.small)

if s3_end and i_s3_on and not na(s3t) and s3t >= cutoff
    if not na(s3b_live)
        box.delete(s3b_live)
        s3b_live := na
    if not na(s3lb_live)
        label.delete(s3lb_live)
        s3lb_live := na
    box.new(s3t, s3h, time[1], s3l,
         xloc=xloc.bar_time, bgcolor=color.new(i_s3_col, i_box_trans),
         border_color=i_box_border > 0 ? color.new(i_s3_col, 50) : na,
         border_width=i_box_border)
    if i_s3_pips
        pip  = pip_val()
        pips = (s3h - s3l) / pip
        label.new(time[1], s3l - pip * i_pip_offset,
             pips > 0 ? fmt_pips(pips) : "< 1 pip",
             xloc=xloc.bar_time, yloc=yloc.price,
             color=color.new(i_s3_pip_col, 100), textcolor=i_s3_pip_col,
             style=label.style_label_up, size=size.small)

// ═══════════════════════════════════════════════════
// MIP — Medium Inducement Point
// ═══════════════════════════════════════════════════
m5_high = request.security(syminfo.tickerid, "5", high, lookahead=barmerge.lookahead_on)
m5_low  = request.security(syminfo.tickerid, "5", low,  lookahead=barmerge.lookahead_on)

m5_ph = ta.pivothigh(m5_high, 3, 3)
m5_pl = ta.pivotlow (m5_low,  3, 3)

var float prev_sh = na
var float prev_sl = na

internal_max_price = i_internal_max * pip_val()
external_min_price = i_external_min * pip_val()

var float mip_h_val = na
var float mip_l_val = na

if not na(m5_ph)
    if not na(prev_sl)
        amp_h = m5_ph - prev_sl
        if amp_h >= internal_max_price and amp_h <= external_min_price
            mip_h_val := m5_ph
    prev_sh := m5_ph

if not na(m5_pl)
    if not na(prev_sh)
        amp_l = prev_sh - m5_pl
        if amp_l >= internal_max_price and amp_l <= external_min_price
            mip_l_val := m5_pl
    prev_sl := m5_pl

if not na(mip_h_val) and close > mip_h_val
    mip_h_val := na

if not na(mip_l_val) and close < mip_l_val
    mip_l_val := na

var line  mip_h_ln  = na
var label mip_h_lbl = na
var line  mip_l_ln  = na
var label mip_l_lbl = na

if i_mip_on and barstate.islast
    if not na(mip_h_val)
        if not na(mip_h_ln)
            line.delete(mip_h_ln)
        if not na(mip_h_lbl)
            label.delete(mip_h_lbl)
        mip_h_ln := line.new(
             bar_index - i_mip_llen, mip_h_val,
             bar_index + i_mip_llen, mip_h_val,
             color=i_mip_h_col, width=i_mip_width, style=mip_ls)
        mip_h_lbl := label.new(
             bar_index + i_mip_llen, mip_h_val, "MIP H",
             yloc=yloc.price,
             color=color.new(i_mip_h_col, 100), textcolor=i_mip_h_col,
             style=label.style_label_left, size=size.small)
    else
        if not na(mip_h_ln)
            line.delete(mip_h_ln)
            mip_h_ln := na
        if not na(mip_h_lbl)
            label.delete(mip_h_lbl)
            mip_h_lbl := na

    if not na(mip_l_val)
        if not na(mip_l_ln)
            line.delete(mip_l_ln)
        if not na(mip_l_lbl)
            label.delete(mip_l_lbl)
        mip_l_ln := line.new(
             bar_index - i_mip_llen, mip_l_val,
             bar_index + i_mip_llen, mip_l_val,
             color=i_mip_l_col, width=i_mip_width, style=mip_ls)
        mip_l_lbl := label.new(
             bar_index + i_mip_llen, mip_l_val, "MIP L",
             yloc=yloc.price,
             color=color.new(i_mip_l_col, 100), textcolor=i_mip_l_col,
             style=label.style_label_left, size=size.small)
    else
        if not na(mip_l_ln)
            line.delete(mip_l_ln)
            mip_l_ln := na
        if not na(mip_l_lbl)
            label.delete(mip_l_lbl)
            mip_l_lbl := na
````
