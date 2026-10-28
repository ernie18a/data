# Previous Session High Low

- url: https://www.tradingview.com/script/PwhvBi51-Previous-Session-High-Low/
- type: indicator
- pine_id: PUB;4414983a5dde4372ab30efe5a55cf735
- version: 1.0

## Description

[b]Previous Session High Low[/b]

Price does not move in a vacuum. Every session — whether a day, a week, or a month — leaves behind two critical reference points: its high and its low. These levels act as natural support and resistance, and the way price interacts with them often tells you more about market direction than any indicator ever could.

This is a straightforward, no-fluff tool focused on one thing: marking the high and low of the previous day, previous week, and previous month on your chart. This indicator is not about the kill zones — just the clean session (day, week, month) highs and lows that matter to traders of instruments like Nifty, Nasdaq, S&P 500, and similar index and equity markets worldwide.

When price approaches a previous session high or low, one of two things happens — it respects it and reverses, or it breaks through. A clean break with strong momentum signals that the market has made a directional decision. A weak, hesitant break that quickly reverses is often a trap. Watching how price behaves at these levels — does it slice through decisively or does it stall and fade — is one of the most reliable ways to read market intent and filter trading decisions. Many price action and institutional trading strategies treat previous session highs and lows as primary reference points for bias, entries, and targets.

The indicator automatically respects each exchange's native timezone, so a Nifty trader and a Nasdaq trader both get correct session boundaries without touching any settings.

[b]Settings[/b] 

[b]Previous Day[/b] 
Toggle the high and low independently and assign a separate color to each. Controls how many previous day levels remain visible on the chart. Appears only on intraday timeframes where daily levels are meaningful.

[b]Previous Week[/b] 
Same controls as the day section. Visible on intraday and daily timeframes only.

[b]Previous Month[/b]
Same controls as the day and week sections. Visible on intraday, daily, and weekly timeframes only.

[b]Appearance[/b] 
Choose the line style (Solid, Dotted, or Dashed), line width, and whether labels are shown next to each level. Label size is also adjustable. Labels are color-matched to their respective levels for quick identification.

## Source Code

````pine
//@version=6
indicator("Previous Session High Low", "Prev Session HL", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── Helpers ───────────────────────────────────────────────────────────────────
line_style_opt(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed

label_size_opt(s) =>
    switch s
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge

// ── Inputs ────────────────────────────────────────────────────────────────────
var g_D  = "Previous Day  ·  intraday charts only"
show_dh  = input.bool(true,     "High",            inline = "DH", group = g_D)
dh_col   = input.color(#26a69a, "",                inline = "DH", group = g_D)
show_dl  = input.bool(true,     "Low",             inline = "DL", group = g_D)
dl_col   = input.color(#ef5350, "",                inline = "DL", group = g_D)
keep_d   = input.int(3,         "Keep N previous", inline = "DK", group = g_D, minval = 1, maxval = 10)

var g_W  = "Previous Week  ·  intraday & daily only"
show_wh  = input.bool(true,     "High",            inline = "WH", group = g_W)
wh_col   = input.color(#1e88e5, "",                inline = "WH", group = g_W)
show_wl  = input.bool(true,     "Low",             inline = "WL", group = g_W)
wl_col   = input.color(#fb8c00, "",                inline = "WL", group = g_W)
keep_w   = input.int(3,         "Keep N previous", inline = "WK", group = g_W, minval = 1, maxval = 10)

var g_M  = "Previous Month  ·  intraday, daily & weekly only"
show_mh  = input.bool(true,     "High",            inline = "MH", group = g_M)
mh_col   = input.color(#9c27b0, "",                inline = "MH", group = g_M)
show_ml  = input.bool(true,     "Low",             inline = "ML", group = g_M)
ml_col   = input.color(#ff5722, "",                inline = "ML", group = g_M)
keep_m   = input.int(3,         "Keep N previous", inline = "MK", group = g_M, minval = 1, maxval = 10)

var g_A  = "Appearance"
ln_style = line_style_opt(input.string("Solid", "Style",   options = ["Solid", "Dotted", "Dashed"], inline = "LS", group = g_A))
ln_width = input.int(1, "",  1, 4,                                                                   inline = "LS", group = g_A)
show_lbl = input.bool(true,  "Labels",                                                               inline = "LB", group = g_A)
lbl_sz   = label_size_opt(input.string("Small", "", options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], inline = "LB", group = g_A))

// ── Timeframe guards ──────────────────────────────────────────────────────────
// timeframe.change() uses syminfo.timezone internally, so exchange day
// boundaries are respected automatically (e.g. NASDAQ on an IST chart).
can_d = timeframe.isintraday
can_w = timeframe.isintraday or timeframe.isdaily
can_m = timeframe.isintraday or timeframe.isdaily or timeframe.isweekly

// ── Types ─────────────────────────────────────────────────────────────────────
type Level
    array<line>  lines
    array<label> labels

type Period
    string tf
    float  h  = na
    float  l  = na
    float  ph = na
    float  pl = na

// ── State ─────────────────────────────────────────────────────────────────────
var d = Period.new("D")
var w = Period.new("W")
var m = Period.new("M")

var dh_lvl = Level.new(array.new_line(), array.new_label())
var dl_lvl = Level.new(array.new_line(), array.new_label())
var wh_lvl = Level.new(array.new_line(), array.new_label())
var wl_lvl = Level.new(array.new_line(), array.new_label())
var mh_lvl = Level.new(array.new_line(), array.new_label())
var ml_lvl = Level.new(array.new_line(), array.new_label())

var T = color.new(color.white, 100)

// ── Functions ─────────────────────────────────────────────────────────────────

track(Period p) =>
    if timeframe.change(p.tf)
        p.ph := p.h
        p.pl := p.l
        p.h  := high
        p.l  := low
    else
        p.h := math.max(nz(p.h, high), high)
        p.l := math.min(nz(p.l, low),  low)

extend_last(Level lvl) =>
    if lvl.lines.size() > 0
        lvl.lines.get(0).set_x2(time)
    if show_lbl and lvl.labels.size() > 0
        lvl.labels.get(0).set_x(time)

stamp(Level lvl, float price, color col, string txt, int keep) =>
    if not na(price)
        lvl.lines.unshift(
             line.new(time, price, time, price,
             xloc  = xloc.bar_time,
             color = col,
             style = ln_style,
             width = ln_width))
        if show_lbl
            lvl.labels.unshift(
                 label.new(time, price, txt,
                 xloc      = xloc.bar_time,
                 style     = label.style_label_left,
                 color     = T,
                 textcolor = col,
                 size      = lbl_sz))
        if lvl.lines.size() > keep
            lvl.lines.pop().delete()
        if lvl.labels.size() > keep
            lvl.labels.pop().delete()

draw(Period p, bool can, int keep,
     bool use_h, Level hl, color hc, string h_txt,
     bool use_l, Level ll, color lc, string l_txt) =>
    if can
        extend_last(hl)
        extend_last(ll)
        if timeframe.change(p.tf)
            if use_h
                stamp(hl, p.ph, hc, h_txt, keep)
            if use_l
                stamp(ll, p.pl, lc, l_txt, keep)

// ── Per-bar execution ─────────────────────────────────────────────────────────
if can_d
    track(d)
if can_w
    track(w)
if can_m
    track(m)

draw(d, can_d, keep_d, show_dh, dh_lvl, dh_col, "PDH", show_dl, dl_lvl, dl_col, "PDL")
draw(w, can_w, keep_w, show_wh, wh_lvl, wh_col, "PWH", show_wl, wl_lvl, wl_col, "PWL")
draw(m, can_m, keep_m, show_mh, mh_lvl, mh_col, "PMH", show_ml, ml_lvl, ml_col, "PML")
````
