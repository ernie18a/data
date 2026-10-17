# ICT IPDA Levels

- url: https://www.tradingview.com/script/raVnN7KE-ICT-IPDA-Levels/
- type: indicator
- pine_id: PUB;d829226942d4417db5afc56acbf70cae
- version: 1.0

## Description

It marks IPDA levels as per ICT rules and tell you where you are right now.

## Source Code

````pine
//@version=5
indicator("ICT IPDA Levels", shorttitle="IPDA", overlay=true, max_lines_count=100, max_labels_count=50)

g1 = "20-Day Range"
show_20      = input.bool(true,  "Show 20-day range", group=g1)
col_20       = input.color(color.new(#534AB7, 85), "20D color", group=g1)

g2 = "40-Day Range"
show_40      = input.bool(true,  "Show 40-day range", group=g2)
col_40       = input.color(color.new(#0F6E56, 88), "40D color", group=g2)

g3 = "60-Day Range"
show_60      = input.bool(true,  "Show 60-day range", group=g3)
col_60       = input.color(color.new(#BA7517, 90), "60D color", group=g3)

g4 = "Zones"
show_zones   = input.bool(true, "Show premium and discount zones", group=g4)
col_premium  = input.color(color.new(#A32D2D, 80), "Premium top third color", group=g4)
col_discount = input.color(color.new(#1D6B2E, 80), "Discount bottom third color", group=g4)
show_mid     = input.bool(true, "Show 50pct midpoint lines", group=g4)
show_labels  = input.bool(true, "Show labels", group=g4)

g5 = "Contested Zones"
show_contested = input.bool(true, "Highlight contested zones", group=g5)
col_contested  = input.color(color.new(#EF9F27, 75), "Contested zone color", group=g5)

high_20 = ta.highest(high, 20)
low_20  = ta.lowest(low,   20)
high_40 = ta.highest(high, 40)
low_40  = ta.lowest(low,   40)
high_60 = ta.highest(high, 60)
low_60  = ta.lowest(low,   60)

third_20 = (high_20 - low_20) / 3
third_40 = (high_40 - low_40) / 3
third_60 = (high_60 - low_60) / 3

p20_bot = high_20 - third_20
d20_top = low_20  + third_20
mid_20  = (high_20 + low_20) / 2.0

p40_bot = high_40 - third_40
d40_top = low_40  + third_40
mid_40  = (high_40 + low_40) / 2.0

p60_bot = high_60 - third_60
d60_top = low_60  + third_60
mid_60  = (high_60 + low_60) / 2.0

pos_20 = close >= p20_bot ? "PREMIUM" : close <= d20_top ? "DISCOUNT" : "EQ"
pos_40 = close >= p40_bot ? "PREMIUM" : close <= d40_top ? "DISCOUNT" : "EQ"
pos_60 = close >= p60_bot ? "PREMIUM" : close <= d60_top ? "DISCOUNT" : "EQ"

clash_20_40 = (pos_20 == "PREMIUM" and pos_40 == "DISCOUNT") or (pos_20 == "DISCOUNT" and pos_40 == "PREMIUM")
clash_20_60 = (pos_20 == "PREMIUM" and pos_60 == "DISCOUNT") or (pos_20 == "DISCOUNT" and pos_60 == "PREMIUM")
any_clash   = clash_20_40 or clash_20_60

in_premium_20  = show_20 and show_zones and close >= p20_bot
in_discount_20 = show_20 and show_zones and close <= d20_top
in_premium_40  = show_40 and show_zones and close >= p40_bot
in_discount_40 = show_40 and show_zones and close <= d40_top
in_any_premium  = in_premium_20 or in_premium_40
in_any_discount = in_discount_20 or in_discount_40

bg_col = show_contested and any_clash ? color.new(col_contested, 93) : in_any_premium ? color.new(col_premium, 93) : in_any_discount ? color.new(col_discount, 93) : na
bgcolor(bg_col)

var line l_20h     = na
var line l_20l     = na
var line l_20m     = na
var line l_20_pbot = na
var line l_20_dtop = na
var line l_40h     = na
var line l_40l     = na
var line l_40m     = na
var line l_40_pbot = na
var line l_40_dtop = na
var line l_60h     = na
var line l_60l     = na
var line l_60m     = na
var line l_60_pbot = na
var line l_60_dtop = na

if barstate.islast
    line.delete(l_20h)
    line.delete(l_20l)
    line.delete(l_20m)
    line.delete(l_20_pbot)
    line.delete(l_20_dtop)
    line.delete(l_40h)
    line.delete(l_40l)
    line.delete(l_40m)
    line.delete(l_40_pbot)
    line.delete(l_40_dtop)
    line.delete(l_60h)
    line.delete(l_60l)
    line.delete(l_60m)
    line.delete(l_60_pbot)
    line.delete(l_60_dtop)

    if show_20
        l_20h     := line.new(bar_index - 20, high_20, bar_index, high_20, color=col_20, width=2, style=line.style_solid, extend=extend.right)
        l_20l     := line.new(bar_index - 20, low_20,  bar_index, low_20,  color=col_20, width=2, style=line.style_solid, extend=extend.right)
        l_20_pbot := line.new(bar_index - 20, p20_bot, bar_index, p20_bot, color=col_20, width=1, style=line.style_dotted, extend=extend.right)
        l_20_dtop := line.new(bar_index - 20, d20_top, bar_index, d20_top, color=col_20, width=1, style=line.style_dotted, extend=extend.right)
        if show_mid
            l_20m := line.new(bar_index - 20, mid_20, bar_index, mid_20, color=col_20, width=1, style=line.style_dashed, extend=extend.right)

    if show_40
        l_40h     := line.new(bar_index - 40, high_40, bar_index, high_40, color=col_40, width=2, style=line.style_solid, extend=extend.right)
        l_40l     := line.new(bar_index - 40, low_40,  bar_index, low_40,  color=col_40, width=2, style=line.style_solid, extend=extend.right)
        l_40_pbot := line.new(bar_index - 40, p40_bot, bar_index, p40_bot, color=col_40, width=1, style=line.style_dotted, extend=extend.right)
        l_40_dtop := line.new(bar_index - 40, d40_top, bar_index, d40_top, color=col_40, width=1, style=line.style_dotted, extend=extend.right)
        if show_mid
            l_40m := line.new(bar_index - 40, mid_40, bar_index, mid_40, color=col_40, width=1, style=line.style_dashed, extend=extend.right)

    if show_60
        l_60h     := line.new(bar_index - 60, high_60, bar_index, high_60, color=col_60, width=2, style=line.style_solid, extend=extend.right)
        l_60l     := line.new(bar_index - 60, low_60,  bar_index, low_60,  color=col_60, width=2, style=line.style_solid, extend=extend.right)
        l_60_pbot := line.new(bar_index - 60, p60_bot, bar_index, p60_bot, color=col_60, width=1, style=line.style_dotted, extend=extend.right)
        l_60_dtop := line.new(bar_index - 60, d60_top, bar_index, d60_top, color=col_60, width=1, style=line.style_dotted, extend=extend.right)
        if show_mid
            l_60m := line.new(bar_index - 60, mid_60, bar_index, mid_60, color=col_60, width=1, style=line.style_dashed, extend=extend.right)

var label lbl_20h  = na
var label lbl_20l  = na
var label lbl_20m  = na
var label lbl_40h  = na
var label lbl_40l  = na
var label lbl_40m  = na
var label lbl_60h  = na
var label lbl_60l  = na
var label lbl_60m  = na
var label lbl_info = na

if barstate.islast and show_labels
    label.delete(lbl_20h)
    label.delete(lbl_20l)
    label.delete(lbl_20m)
    label.delete(lbl_40h)
    label.delete(lbl_40l)
    label.delete(lbl_40m)
    label.delete(lbl_60h)
    label.delete(lbl_60l)
    label.delete(lbl_60m)
    label.delete(lbl_info)

    if show_20
        lbl_20h := label.new(bar_index + 2, high_20, "20D HIGH", style=label.style_label_left, color=color.new(col_20, 70), textcolor=color.white, size=size.small)
        lbl_20l := label.new(bar_index + 2, low_20,  "20D LOW",  style=label.style_label_left, color=color.new(col_20, 70), textcolor=color.white, size=size.small)
        if show_mid
            lbl_20m := label.new(bar_index + 2, mid_20, "20D MID", style=label.style_label_left, color=color.new(col_20, 80), textcolor=color.white, size=size.tiny)

    if show_40
        lbl_40h := label.new(bar_index + 2, high_40, "40D HIGH", style=label.style_label_left, color=color.new(col_40, 70), textcolor=color.white, size=size.small)
        lbl_40l := label.new(bar_index + 2, low_40,  "40D LOW",  style=label.style_label_left, color=color.new(col_40, 70), textcolor=color.white, size=size.small)
        if show_mid
            lbl_40m := label.new(bar_index + 2, mid_40, "40D MID", style=label.style_label_left, color=color.new(col_40, 80), textcolor=color.white, size=size.tiny)

    if show_60
        lbl_60h := label.new(bar_index + 2, high_60, "60D HIGH", style=label.style_label_left, color=color.new(col_60, 70), textcolor=color.white, size=size.small)
        lbl_60l := label.new(bar_index + 2, low_60,  "60D LOW",  style=label.style_label_left, color=color.new(col_60, 70), textcolor=color.white, size=size.small)
        if show_mid
            lbl_60m := label.new(bar_index + 2, mid_60, "60D MID", style=label.style_label_left, color=color.new(col_60, 80), textcolor=color.white, size=size.tiny)

    string clash_txt  = any_clash ? " | CONTESTED" : ""
    string info_txt   = "IPDA POSITION\n20D: " + pos_20 + "\n40D: " + pos_40 + "\n60D: " + pos_60 + clash_txt
    color  info_bg    = pos_20 == "DISCOUNT" and pos_40 == "DISCOUNT" ? color.new(#1D6B2E, 60) : pos_20 == "PREMIUM" and pos_40 == "PREMIUM" ? color.new(#A32D2D, 60) : any_clash ? color.new(#EF9F27, 60) : color.new(#1a1a1a, 60)
    lbl_info := label.new(bar_index + 2, mid_60, info_txt, style=label.style_label_left, color=info_bg, textcolor=color.white, size=size.normal)

var table tbl = table.new(position.bottom_right, 2, 8, bgcolor=color.new(#1a1a1a, 70), border_color=color.new(#888780, 50), border_width=1, frame_color=color.new(#888780, 50), frame_width=1)

if barstate.islast
    color c_bull = color.new(#1D6B2E, 40)
    color c_bear = color.new(#A32D2D, 40)
    color c_neut = color.new(#888780, 60)
    color c_warn = color.new(#EF9F27, 40)

    color col_p20 = pos_20 == "DISCOUNT" ? c_bull : pos_20 == "PREMIUM" ? c_bear : c_neut
    color col_p40 = pos_40 == "DISCOUNT" ? c_bull : pos_40 == "PREMIUM" ? c_bear : c_neut
    color col_p60 = pos_60 == "DISCOUNT" ? c_bull : pos_60 == "PREMIUM" ? c_bear : c_neut

    string bias_txt = pos_20 == "DISCOUNT" and pos_40 == "DISCOUNT" ? "STRONG BUY" : pos_20 == "PREMIUM" and pos_40 == "PREMIUM" ? "STRONG SELL" : any_clash ? "CONTESTED" : pos_60 == "DISCOUNT" ? "MILD BUY" : pos_60 == "PREMIUM" ? "MILD SELL" : "NEUTRAL"
    color  bias_bg  = bias_txt == "STRONG BUY" ? c_bull : bias_txt == "STRONG SELL" ? c_bear : bias_txt == "CONTESTED" ? c_warn : c_neut

    string clash_str = any_clash ? "YES - WAIT" : "NO"
    color  clash_bg  = any_clash ? c_warn : c_bull

    table.cell(tbl, 0, 0, "IPDA",     text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a1a, 40))
    table.cell(tbl, 1, 0, "POSITION", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a1a, 40))
    table.cell(tbl, 0, 1, "20D HIGH", text_color=color.white, text_size=size.tiny,  bgcolor=c_neut)
    table.cell(tbl, 1, 1, str.tostring(math.round(high_20, 2)), text_color=color.white, text_size=size.tiny, bgcolor=c_neut)
    table.cell(tbl, 0, 2, "20D LOW",  text_color=color.white, text_size=size.tiny,  bgcolor=c_neut)
    table.cell(tbl, 1, 2, str.tostring(math.round(low_20, 2)),  text_color=color.white, text_size=size.tiny, bgcolor=c_neut)
    table.cell(tbl, 0, 3, "20D POS",  text_color=color.white, text_size=size.small, bgcolor=col_p20)
    table.cell(tbl, 1, 3, pos_20,     text_color=color.white, text_size=size.small, bgcolor=col_p20)
    table.cell(tbl, 0, 4, "40D POS",  text_color=color.white, text_size=size.small, bgcolor=col_p40)
    table.cell(tbl, 1, 4, pos_40,     text_color=color.white, text_size=size.small, bgcolor=col_p40)
    table.cell(tbl, 0, 5, "60D POS",  text_color=color.white, text_size=size.small, bgcolor=col_p60)
    table.cell(tbl, 1, 5, pos_60,     text_color=color.white, text_size=size.small, bgcolor=col_p60)
    table.cell(tbl, 0, 6, "BIAS",     text_color=color.white, text_size=size.small, bgcolor=bias_bg)
    table.cell(tbl, 1, 6, bias_txt,   text_color=color.white, text_size=size.small, bgcolor=bias_bg)
    table.cell(tbl, 0, 7, "CLASH",    text_color=color.white, text_size=size.tiny,  bgcolor=clash_bg)
    table.cell(tbl, 1, 7, clash_str,  text_color=color.white, text_size=size.tiny,  bgcolor=clash_bg)
````
