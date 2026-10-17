# Trading Rules Checklist

- url: https://www.tradingview.com/script/pfhB6mwa-Trading-Rules-Checklist/
- type: indicator
- pine_id: PUB;363395a86ed440e9ae7312f9bf4b02c1
- version: 2.0

## Description

A simple and clean trade entry checklist for disciplined traders. The indicator displays a table with your trading rules — each rule can be toggled on or off directly from the settings. Once the required number of rules are met, the chart background turns green and the table shows "VSTUP" (Entry). If the conditions are not met, the background stays red showing "NEVSTUPUJ" (No Entry).

Features:

7 toggleable trading rules (default: VWAP, CVD, FIBO, Break, PDPOC, WPOC, POC)
Each rule can be renamed to match your own trading strategy
Configurable minimum number of rules required for entry (default: 3 out of 7)
Full-chart color background — green = entry confirmed, red = wait
Adjustable table position (4 corners of the chart)
Background colors fully customizable via the Style tab
How to use:
Before every trade, go through your checklist and toggle the rules that are currently met. The indicator will visually confirm whether you have enough confluences to enter the trade — helping you stay consistent and avoid impulsive decisions.

Works best with: VWAP, Volume Profile, CVD, Fibonacci retracements and trendline analysis.

## Source Code

````pine
//@version=5
indicator("Trading Rules Checklist", overlay=true)

// --- 10 SLOTU (prazdny nazev = skryto) ---
r1  = input.bool(false, "", inline="r1",  group="✅ Pravidla vstupu")
n1  = input.string("VWAP",  "  ", inline="r1",  group="✅ Pravidla vstupu")
r2  = input.bool(false, "", inline="r2",  group="✅ Pravidla vstupu")
n2  = input.string("CVD",   "  ", inline="r2",  group="✅ Pravidla vstupu")
r3  = input.bool(false, "", inline="r3",  group="✅ Pravidla vstupu")
n3  = input.string("FIBO",  "  ", inline="r3",  group="✅ Pravidla vstupu")
r4  = input.bool(false, "", inline="r4",  group="✅ Pravidla vstupu")
n4  = input.string("Break", "  ", inline="r4",  group="✅ Pravidla vstupu")
r5  = input.bool(false, "", inline="r5",  group="✅ Pravidla vstupu")
n5  = input.string("PDPOC", "  ", inline="r5",  group="✅ Pravidla vstupu")
r6  = input.bool(false, "", inline="r6",  group="✅ Pravidla vstupu")
n6  = input.string("WPOC",  "  ", inline="r6",  group="✅ Pravidla vstupu")
r7  = input.bool(false, "", inline="r7",  group="✅ Pravidla vstupu")
n7  = input.string("POC",   "  ", inline="r7",  group="✅ Pravidla vstupu")
r8  = input.bool(false, "", inline="r8",  group="✅ Pravidla vstupu")
n8  = input.string("",      "  ", inline="r8",  group="✅ Pravidla vstupu")
r9  = input.bool(false, "", inline="r9",  group="✅ Pravidla vstupu")
n9  = input.string("",      "  ", inline="r9",  group="✅ Pravidla vstupu")
r10 = input.bool(false, "", inline="r10", group="✅ Pravidla vstupu")
n10 = input.string("",      "  ", inline="r10", group="✅ Pravidla vstupu")

// --- NASTAVENI ---
min_rules = input.int(3, "Minimum pravidel pro vstup", minval=1, maxval=10, group="Nastaveni")
tbl_pos   = input.string("Vpravo nahore", "Pozice tabulky", options=["Vpravo nahore","Vpravo dole","Vlevo nahore","Vlevo dole"], group="Nastaveni")

// --- AKTIVNI SLOTY ---
a1  = n1  != ""
a2  = n2  != ""
a3  = n3  != ""
a4  = n4  != ""
a5  = n5  != ""
a6  = n6  != ""
a7  = n7  != ""
a8  = n8  != ""
a9  = n9  != ""
a10 = n10 != ""

total = (a1?1:0)+(a2?1:0)+(a3?1:0)+(a4?1:0)+(a5?1:0)+(a6?1:0)+(a7?1:0)+(a8?1:0)+(a9?1:0)+(a10?1:0)
score = (a1 and r1?1:0)+(a2 and r2?1:0)+(a3 and r3?1:0)+(a4 and r4?1:0)+(a5 and r5?1:0)+(a6 and r6?1:0)+(a7 and r7?1:0)+(a8 and r8?1:0)+(a9 and r9?1:0)+(a10 and r10?1:0)
signal_ok = score >= min_rules

clr_on  = color.new(color.green, 0)
clr_off = color.new(#e48e8e, 0)
clr_bg  = color.new(color.black, 30)

// --- OBDELNIK PRES GRAF ---
bgcolor(signal_ok     ? color.new(color.green, 80) : na, title="Barva VSTUP")
bgcolor(not signal_ok ? color.new(#ea67a6, 80) : na, title="Barva NEVSTUPUJ")

// --- POZICE ---
pos = switch tbl_pos
    "Vpravo nahore" => position.top_right
    "Vpravo dole"   => position.bottom_right
    "Vlevo nahore"  => position.top_left
    "Vlevo dole"    => position.bottom_left
    => position.top_right

f_mark(v) => v ? "✔" : "✘"
f_clr(v)  => v ? clr_on : clr_off

// --- TABULKA - dynamicky pocet radku ---
if barstate.islast
    tbl = table.new(pos, 2, total + 2, bgcolor=clr_bg, border_color=color.new(color.gray,60), border_width=1, frame_color=color.new(color.gray,40), frame_width=2)

    table.cell(tbl, 0, 0, "PRAVIDLO", text_color=color.new(color.white,20), text_size=size.small, bgcolor=color.new(color.gray,70))
    table.cell(tbl, 1, 0, "STATUS",   text_color=color.new(color.white,20), text_size=size.small, bgcolor=color.new(color.gray,70))

    row = 1
    if a1
        table.cell(tbl, 0, row, n1, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r1), text_color=f_clr(r1), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a2
        table.cell(tbl, 0, row, n2, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r2), text_color=f_clr(r2), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a3
        table.cell(tbl, 0, row, n3, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r3), text_color=f_clr(r3), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a4
        table.cell(tbl, 0, row, n4, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r4), text_color=f_clr(r4), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a5
        table.cell(tbl, 0, row, n5, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r5), text_color=f_clr(r5), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a6
        table.cell(tbl, 0, row, n6, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r6), text_color=f_clr(r6), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a7
        table.cell(tbl, 0, row, n7, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r7), text_color=f_clr(r7), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a8
        table.cell(tbl, 0, row, n8, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r8), text_color=f_clr(r8), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a9
        table.cell(tbl, 0, row, n9, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r9), text_color=f_clr(r9), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1
    if a10
        table.cell(tbl, 0, row, n10, text_color=color.white, text_size=size.small, bgcolor=clr_bg)
        table.cell(tbl, 1, row, f_mark(r10), text_color=f_clr(r10), text_size=size.normal, bgcolor=clr_bg)
        row := row + 1

    skore_bg = signal_ok ? color.new(color.green,40) : color.new(color.red,40)
    table.cell(tbl, 0, row, "SKORE " + str.tostring(score) + "/" + str.tostring(total) + "  (" + str.tostring(min_rules) + "+ = vstup)", text_color=color.white, text_size=size.small, bgcolor=skore_bg)
    table.cell(tbl, 1, row, signal_ok ? "VSTUP" : "NEVSTUPUJ", text_color=signal_ok ? clr_on : clr_off, text_size=size.small, bgcolor=skore_bg)
````
