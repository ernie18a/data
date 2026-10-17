# Lucky News

- url: https://www.tradingview.com/script/ZbYlauCB-Lucky-News/
- type: indicator
- pine_id: PUB;23a1c925db664a6baa15668bbacd55b0
- version: 1.0

## Description

[b]Lucky News[/b]

Never get caught off guard by high-impact news again.

LUCKY NEWS is a minimal, no-clutter news tracker that lives right on your chart. Built for traders who check Forex Factory every morning — just enter your red folder events for the day, toggle them on, and a clean table shows exactly what's coming and when. No lines on your chart, no noise, just the information you need.

---

[b]What It Does[/b]

- **8 customizable event slots** — enter currency, event name, and time for each red news release
- **Clean table display** — shows CUR | EVENT | TIME in a sleek dark overlay anywhere on your chart
- **Zero chart clutter** — table only, nothing drawn on your candles or price action
- **Stays visible all day** — events don't disappear or fade after they pass
- **Works in your timezone** — times use your chart's timezone setting automatically

---

[b]How To Use[/b]

1. Check [Forex Factory](https://www.forexfactory.com) each morning for red folder (high impact) events
2. Open Settings → enable each event slot and fill in the hour, minute, currency, and event name
3. Toggle unused slots off
4. The table updates instantly on your chart — no refresh needed

---

[b]Example Setup[/b]

| CUR | EVENT | TIME |
|-----|-------|------|
| USD | FOMC | 11:00 |
| USD | CPI | 08:30 |

---

[b]Why I Built This[/b]

As a futures scalper I need to know exactly when red news hits so I can stay out or be ready. I wanted something dead simple — no automation, no APIs, just a fast manual input that keeps my news front and center while I trade.

*Stay informed. Trade prepared. Stay lucky.*

— LuckyJo

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════
//  LUCKY NEWS — Forex Factory High Impact Events
//  Table only. No chart clutter.
//
//  HOW TO USE:
//   Each event: toggle Active, type Hour + Minute (24h, your timezone),
//   Currency (e.g. USD), and Name (e.g. PMI).
//   Times auto-use today's date. Update each morning from FF.
// ══════════════════════════════════════════════════════════════════

//@version=6
indicator("Lucky News", overlay=true)

// ── Table position ────────────────────────────────────────────────
table_pos = input.string("Top Right", "Table position", options=["Top Right","Top Left","Bottom Right","Bottom Left"])

// ── Event 1 ───────────────────────────────────────────────────────
var G1 = "Event 1"
e1_on  = input.bool(false, "Active",    group=G1)
e1_h   = input.int(8,  "Hour (0-23)",  group=G1, minval=0, maxval=23)
e1_m   = input.int(30, "Minute",       group=G1, minval=0, maxval=59)
e1_cur = input.string("USD", "Currency", group=G1)
e1_name= input.string("PMI", "Event name", group=G1)

// ── Event 2 ───────────────────────────────────────────────────────
var G2 = "Event 2"
e2_on  = input.bool(false, "Active",    group=G2)
e2_h   = input.int(8,  "Hour (0-23)",  group=G2, minval=0, maxval=23)
e2_m   = input.int(30, "Minute",       group=G2, minval=0, maxval=59)
e2_cur = input.string("USD", "Currency", group=G2)
e2_name= input.string("CPI", "Event name", group=G2)

// ── Event 3 ───────────────────────────────────────────────────────
var G3 = "Event 3"
e3_on  = input.bool(false, "Active",    group=G3)
e3_h   = input.int(8,  "Hour (0-23)",  group=G3, minval=0, maxval=23)
e3_m   = input.int(30, "Minute",       group=G3, minval=0, maxval=59)
e3_cur = input.string("GBP", "Currency", group=G3)
e3_name= input.string("CPI", "Event name", group=G3)

// ── Event 4 ───────────────────────────────────────────────────────
var G4 = "Event 4"
e4_on  = input.bool(false, "Active",    group=G4)
e4_h   = input.int(8,  "Hour (0-23)",  group=G4, minval=0, maxval=23)
e4_m   = input.int(30, "Minute",       group=G4, minval=0, maxval=59)
e4_cur = input.string("EUR", "Currency", group=G4)
e4_name= input.string("ECB Rate", "Event name", group=G4)

// ── Event 5 ───────────────────────────────────────────────────────
var G5 = "Event 5"
e5_on  = input.bool(false, "Active",    group=G5)
e5_h   = input.int(14, "Hour (0-23)",  group=G5, minval=0, maxval=23)
e5_m   = input.int(0,  "Minute",       group=G5, minval=0, maxval=59)
e5_cur = input.string("USD", "Currency", group=G5)
e5_name= input.string("FOMC", "Event name", group=G5)

// ── Event 6 ───────────────────────────────────────────────────────
var G6 = "Event 6"
e6_on  = input.bool(false, "Active",    group=G6)
e6_h   = input.int(8,  "Hour (0-23)",  group=G6, minval=0, maxval=23)
e6_m   = input.int(30, "Minute",       group=G6, minval=0, maxval=59)
e6_cur = input.string("CAD", "Currency", group=G6)
e6_name= input.string("BOC Rate", "Event name", group=G6)

// ── Event 7 ───────────────────────────────────────────────────────
var G7 = "Event 7"
e7_on  = input.bool(false, "Active",    group=G7)
e7_h   = input.int(8,  "Hour (0-23)",  group=G7, minval=0, maxval=23)
e7_m   = input.int(30, "Minute",       group=G7, minval=0, maxval=59)
e7_cur = input.string("AUD", "Currency", group=G7)
e7_name= input.string("RBA Rate", "Event name", group=G7)

// ── Event 8 ───────────────────────────────────────────────────────
var G8 = "Event 8"
e8_on  = input.bool(false, "Active",    group=G8)
e8_h   = input.int(8,  "Hour (0-23)",  group=G8, minval=0, maxval=23)
e8_m   = input.int(30, "Minute",       group=G8, minval=0, maxval=59)
e8_cur = input.string("JPY", "Currency", group=G8)
e8_name= input.string("BOJ Rate", "Event name", group=G8)

// ── Format time as HH:MM ─────────────────────────────────────────
f_time_str(h, m) =>
    hh = h < 10 ? "0" + str.tostring(h) : str.tostring(h)
    mm = m < 10 ? "0" + str.tostring(m) : str.tostring(m)
    hh + ":" + mm

// ── Table ─────────────────────────────────────────────────────────
if barstate.islast
    tpos = switch table_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

    t = table.new(tpos, 3, 10, bgcolor=color.new(#0a0a14, 12), border_color=color.new(#2a2a3e, 60), border_width=1, frame_color=color.new(#e53e3e, 50), frame_width=1)

    table.cell(t, 0, 0, "CUR",   text_color=#7070a0, text_size=size.small, bgcolor=#10101e)
    table.cell(t, 1, 0, "EVENT", text_color=#7070a0, text_size=size.small, bgcolor=#10101e)
    table.cell(t, 2, 0, "TIME",  text_color=#7070a0, text_size=size.small, bgcolor=#10101e)

    row = 1
    col = color.new(#e0e0e8, 0)
    bg  = color.new(#0d0d1a, 5)

    if e1_on
        table.cell(t, 0, row, e1_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e1_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e1_h, e1_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
    if e2_on
        table.cell(t, 0, row, e2_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e2_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e2_h, e2_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
    if e3_on
        table.cell(t, 0, row, e3_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e3_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e3_h, e3_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
    if e4_on
        table.cell(t, 0, row, e4_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e4_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e4_h, e4_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
    if e5_on
        table.cell(t, 0, row, e5_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e5_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e5_h, e5_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
    if e6_on
        table.cell(t, 0, row, e6_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e6_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e6_h, e6_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
    if e7_on
        table.cell(t, 0, row, e7_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e7_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e7_h, e7_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
    if e8_on
        table.cell(t, 0, row, e8_cur,  text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 1, row, e8_name, text_color=col, text_size=size.small, bgcolor=bg)
        table.cell(t, 2, row, f_time_str(e8_h, e8_m), text_color=col, text_size=size.small, bgcolor=bg)
        row += 1
````
