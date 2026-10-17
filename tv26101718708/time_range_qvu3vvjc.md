# Time Range

- url: https://www.tradingview.com/script/QvU3VvJc/
- type: indicator
- pine_id: PUB;6759a421d0ab4801b0e1c75e96dec9d6
- version: 5.0

## Description

Er markiert bestimmte Zeitzonen die Sie selber festlegen können

## Source Code

````pine
//@version=5
indicator(title="Time Range Highlighter", shorttitle="TimeRanges", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────
// GLOBALE EINSTELLUNGEN
// ─────────────────────────────────────────
var string g0 = "── Globale Einstellungen ──"

tz = input.string("Europe/Berlin", "Zeitzone", group=g0,
     options=["UTC","Europe/Berlin","Europe/London","Europe/Paris",
              "Europe/Zurich","Europe/Moscow","America/New_York",
              "America/Chicago","America/Denver","America/Los_Angeles",
              "America/Sao_Paulo","Asia/Tokyo","Asia/Shanghai",
              "Asia/Hong_Kong","Asia/Singapore","Asia/Dubai",
              "Asia/Kolkata","Australia/Sydney","Pacific/Auckland"])

days_back    = input.int(3,  "Tage zurück",  minval=0, maxval=365, group=g0)
days_forward = input.int(0,  "Tage voraus",  minval=0, maxval=30,  group=g0)

// Zeitfenster: von (heute - days_back) bis (heute + days_forward)
t_start = timestamp(year(timenow, tz), month(timenow, tz), dayofmonth(timenow, tz), 0, 0, 0) - days_back    * 86400000
t_end   = timestamp(year(timenow, tz), month(timenow, tz), dayofmonth(timenow, tz), 23,59,59) + days_forward * 86400000
in_window = time >= t_start and time <= t_end

// ─────────────────────────────────────────
// HILFSFUNKTIONEN
// ─────────────────────────────────────────

f_style(s) =>
    s == "Gestrichelt" ? line.style_dashed :
     s == "Gepunktet"   ? line.style_dotted :
     line.style_solid

f_draw(enabled, sess, col, sty, wid) =>
    in_sess = not na(time("1", sess, tz)) and in_window
    was_in  = not na(time("1", sess, tz)[1]) and in_window[1]
    if enabled
        if in_sess and not was_in
            line.new(bar_index, high, bar_index, low, extend=extend.both,
                     color=color.new(col, 0), style=f_style(sty), width=wid)
        if not in_sess and was_in
            line.new(bar_index, high, bar_index, low, extend=extend.both,
                     color=color.new(col, 0), style=f_style(sty), width=wid)

// ─────────────────────────────────────────
// ZONE 1
// ─────────────────────────────────────────
g1 = "── Zone 1 ──"
z1_on  = input.bool(true,           "Aktiv",          group=g1)
z1_von = input.session("0900-0930", "Zeit (Von–Bis)", group=g1)
z1_col = input.color(color.new(color.blue,   70), "Farbe",    group=g1, inline="z1")
z1_sty = input.string("Durchgezogen", "Linienart",   group=g1, inline="z1",
         options=["Durchgezogen","Gestrichelt","Gepunktet"])
z1_wid = input.int(1, "Breite", minval=1, maxval=4,  group=g1, inline="z1")

// ─────────────────────────────────────────
// ZONE 2
// ─────────────────────────────────────────
g2 = "── Zone 2 ──"
z2_on  = input.bool(true,           "Aktiv",          group=g2)
z2_von = input.session("1000-1030", "Zeit (Von–Bis)", group=g2)
z2_col = input.color(color.new(color.red,    70), "Farbe",    group=g2, inline="z2")
z2_sty = input.string("Gestrichelt", "Linienart",    group=g2, inline="z2",
         options=["Durchgezogen","Gestrichelt","Gepunktet"])
z2_wid = input.int(1, "Breite", minval=1, maxval=4,  group=g2, inline="z2")

// ─────────────────────────────────────────
// ZONE 3
// ─────────────────────────────────────────
g3 = "── Zone 3 ──"
z3_on  = input.bool(true,           "Aktiv",          group=g3)
z3_von = input.session("1200-1300", "Zeit (Von–Bis)", group=g3)
z3_col = input.color(color.new(color.green,  70), "Farbe",    group=g3, inline="z3")
z3_sty = input.string("Gepunktet",  "Linienart",     group=g3, inline="z3",
         options=["Durchgezogen","Gestrichelt","Gepunktet"])
z3_wid = input.int(1, "Breite", minval=1, maxval=4,  group=g3, inline="z3")

// ─────────────────────────────────────────
// ZONE 4
// ─────────────────────────────────────────
g4 = "── Zone 4 ──"
z4_on  = input.bool(false,          "Aktiv",          group=g4)
z4_von = input.session("1400-1500", "Zeit (Von–Bis)", group=g4)
z4_col = input.color(color.new(color.orange, 70), "Farbe",    group=g4, inline="z4")
z4_sty = input.string("Durchgezogen", "Linienart",   group=g4, inline="z4",
         options=["Durchgezogen","Gestrichelt","Gepunktet"])
z4_wid = input.int(1, "Breite", minval=1, maxval=4,  group=g4, inline="z4")

// ─────────────────────────────────────────
// ZONE 5
// ─────────────────────────────────────────
g5 = "── Zone 5 ──"
z5_on  = input.bool(false,          "Aktiv",          group=g5)
z5_von = input.session("1530-1600", "Zeit (Von–Bis)", group=g5)
z5_col = input.color(color.new(color.purple, 70), "Farbe",    group=g5, inline="z5")
z5_sty = input.string("Durchgezogen", "Linienart",   group=g5, inline="z5",
         options=["Durchgezogen","Gestrichelt","Gepunktet"])
z5_wid = input.int(1, "Breite", minval=1, maxval=4,  group=g5, inline="z5")

// ─────────────────────────────────────────
// ZONE 6
// ─────────────────────────────────────────
g6 = "── Zone 6 ──"
z6_on  = input.bool(false,          "Aktiv",          group=g6)
z6_von = input.session("1700-1730", "Zeit (Von–Bis)", group=g6)
z6_col = input.color(color.new(color.yellow, 70), "Farbe",    group=g6, inline="z6")
z6_sty = input.string("Durchgezogen", "Linienart",   group=g6, inline="z6",
         options=["Durchgezogen","Gestrichelt","Gepunktet"])
z6_wid = input.int(1, "Breite", minval=1, maxval=4,  group=g6, inline="z6")

// ─────────────────────────────────────────
// ZONE 7
// ─────────────────────────────────────────
g7 = "── Zone 7 ──"
z7_on  = input.bool(false,          "Aktiv",          group=g7)
z7_von = input.session("2000-2100", "Zeit (Von–Bis)", group=g7)
z7_col = input.color(color.new(color.teal,   70), "Farbe",    group=g7, inline="z7")
z7_sty = input.string("Durchgezogen", "Linienart",   group=g7, inline="z7",
         options=["Durchgezogen","Gestrichelt","Gepunktet"])
z7_wid = input.int(1, "Breite", minval=1, maxval=4,  group=g7, inline="z7")

// ─────────────────────────────────────────
// HINTERGRUND
// ─────────────────────────────────────────
bgcolor(z1_on and in_window and not na(time("1", z1_von, tz)) ? z1_col : na)
bgcolor(z2_on and in_window and not na(time("1", z2_von, tz)) ? z2_col : na)
bgcolor(z3_on and in_window and not na(time("1", z3_von, tz)) ? z3_col : na)
bgcolor(z4_on and in_window and not na(time("1", z4_von, tz)) ? z4_col : na)
bgcolor(z5_on and in_window and not na(time("1", z5_von, tz)) ? z5_col : na)
bgcolor(z6_on and in_window and not na(time("1", z6_von, tz)) ? z6_col : na)
bgcolor(z7_on and in_window and not na(time("1", z7_von, tz)) ? z7_col : na)

// ─────────────────────────────────────────
// VERTIKALE LINIEN
// ─────────────────────────────────────────
f_draw(z1_on, z1_von, z1_col, z1_sty, z1_wid)
f_draw(z2_on, z2_von, z2_col, z2_sty, z2_wid)
f_draw(z3_on, z3_von, z3_col, z3_sty, z3_wid)
f_draw(z4_on, z4_von, z4_col, z4_sty, z4_wid)
f_draw(z5_on, z5_von, z5_col, z5_sty, z5_wid)
f_draw(z6_on, z6_von, z6_col, z6_sty, z6_wid)
f_draw(z7_on, z7_von, z7_col, z7_sty, z7_wid)
````
