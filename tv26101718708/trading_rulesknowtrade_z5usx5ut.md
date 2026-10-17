# Trading rules-knowtrade

- url: https://www.tradingview.com/script/Z5usx5ut-Trading-rules-knowtrade/
- type: indicator
- pine_id: PUB;5bdf9827b0af4d7cb8b822449a3069ab
- version: 1.0

## Description

Trading rules pro dementy, kteří neumí držet pravidla

## Source Code

````pine
//@version=5
indicator("Trading Rules Checklist", overlay=true)

// --- PREPINACE ---
r_vwap  = input.bool(false, "VWAP",  group="✅ Pravidla vstupu")
r_cvd   = input.bool(false, "CVD",   group="✅ Pravidla vstupu")
r_fibo  = input.bool(false, "FIBO",  group="✅ Pravidla vstupu")
r_tl    = input.bool(false, "Break", group="✅ Pravidla vstupu")
r_pdpoc = input.bool(false, "PDPOC", group="✅ Pravidla vstupu")
r_wpoc  = input.bool(false, "WPOC",  group="✅ Pravidla vstupu")
r_poc   = input.bool(false, "POC",   group="✅ Pravidla vstupu")

// --- PREJMENOVANI ---
n_vwap  = input.string("VWAP",  "Pravidlo 1", group="✏️ Prejmenovani")
n_cvd   = input.string("CVD",   "Pravidlo 2", group="✏️ Prejmenovani")
n_fibo  = input.string("FIBO",  "Pravidlo 3", group="✏️ Prejmenovani")
n_tl    = input.string("Break", "Pravidlo 4", group="✏️ Prejmenovani")
n_pdpoc = input.string("PDPOC", "Pravidlo 5", group="✏️ Prejmenovani")
n_wpoc  = input.string("WPOC",  "Pravidlo 6", group="✏️ Prejmenovani")
n_poc   = input.string("POC",   "Pravidlo 7", group="✏️ Prejmenovani")

min_rules = input.int(3, "Minimum pravidel pro vstup", minval=1, maxval=7, group="Nastaveni")
tbl_pos   = input.string("Vpravo nahore", "Pozice tabulky", options=["Vpravo nahore","Vpravo dole","Vlevo nahore","Vlevo dole"], group="Nastaveni")

score     = (r_vwap ? 1 : 0) + (r_cvd ? 1 : 0) + (r_fibo ? 1 : 0) + (r_tl ? 1 : 0) + (r_pdpoc ? 1 : 0) + (r_wpoc ? 1 : 0) + (r_poc ? 1 : 0)
signal_ok = score >= min_rules

clr_on  = color.new(color.green, 0)
clr_off = color.new(color.red,   0)
clr_bg  = color.new(color.black, 30)

// OBDELNIK PRES GRAF
bgcolor(signal_ok     ? color.new(color.green, 40) : na, title="Barva VSTUP")
bgcolor(not signal_ok ? color.new(color.red,   40) : na, title="Barva NEVSTUPUJ")

pos = switch tbl_pos
    "Vpravo nahore" => position.top_right
    "Vpravo dole"   => position.bottom_right
    "Vlevo nahore"  => position.top_left
    "Vlevo dole"    => position.bottom_left
    => position.top_right

var table tbl = table.new(pos, 2, 9, bgcolor=clr_bg, border_color=color.new(color.gray,60), border_width=1, frame_color=color.new(color.gray,40), frame_width=2)

f_mark(v) => v ? "✔" : "✘"
f_clr(v)  => v ? clr_on : clr_off

if barstate.islast
    table.cell(tbl, 0, 0, "PRAVIDLO", text_color=color.new(color.white,20), text_size=size.small, bgcolor=color.new(color.gray,70))
    table.cell(tbl, 1, 0, "",         text_color=color.white,               text_size=size.small, bgcolor=color.new(color.gray,70))

    table.cell(tbl, 0, 1, n_vwap,  text_color=color.white, text_size=size.small, bgcolor=clr_bg)
    table.cell(tbl, 1, 1, f_mark(r_vwap),  text_color=f_clr(r_vwap),  text_size=size.normal, bgcolor=clr_bg)

    table.cell(tbl, 0, 2, n_cvd,   text_color=color.white, text_size=size.small, bgcolor=clr_bg)
    table.cell(tbl, 1, 2, f_mark(r_cvd),   text_color=f_clr(r_cvd),   text_size=size.normal, bgcolor=clr_bg)

    table.cell(tbl, 0, 3, n_fibo,  text_color=color.white, text_size=size.small, bgcolor=clr_bg)
    table.cell(tbl, 1, 3, f_mark(r_fibo),  text_color=f_clr(r_fibo),  text_size=size.normal, bgcolor=clr_bg)

    table.cell(tbl, 0, 4, n_tl,    text_color=color.white, text_size=size.small, bgcolor=clr_bg)
    table.cell(tbl, 1, 4, f_mark(r_tl),    text_color=f_clr(r_tl),    text_size=size.normal, bgcolor=clr_bg)

    table.cell(tbl, 0, 5, n_pdpoc, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
    table.cell(tbl, 1, 5, f_mark(r_pdpoc), text_color=f_clr(r_pdpoc), text_size=size.normal, bgcolor=clr_bg)

    table.cell(tbl, 0, 6, n_wpoc,  text_color=color.white, text_size=size.small, bgcolor=clr_bg)
    table.cell(tbl, 1, 6, f_mark(r_wpoc),  text_color=f_clr(r_wpoc),  text_size=size.normal, bgcolor=clr_bg)

    table.cell(tbl, 0, 7, n_poc,   text_color=color.white, text_size=size.small, bgcolor=clr_bg)
    table.cell(tbl, 1, 7, f_mark(r_poc),   text_color=f_clr(r_poc),   text_size=size.normal, bgcolor=clr_bg)

    skore_bg  = signal_ok ? color.new(color.green, 40) : color.new(color.red, 40)
    skore_clr = signal_ok ? clr_on : clr_off
    table.cell(tbl, 0, 8, "SKORE  " + str.tostring(score) + "/" + str.tostring(7), text_color=color.white, text_size=size.small, bgcolor=skore_bg)
    table.cell(tbl, 1, 8, signal_ok ? "VSTUP" : "NEVSTUPUJ", text_color=skore_clr, text_size=size.small, bgcolor=skore_bg)
````
