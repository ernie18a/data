# Session Open Levels and Timer - 4H/6H

- url: https://www.tradingview.com/script/nJvvWV0p-Session-Open-Levels-and-Timer-4H-6H/
- type: indicator
- pine_id: PUB;4bd222220c604a3d81d3b771b840e6e4
- version: 1.0

## Description

Dynamic 4H and 6H session open lines for M1 to M90 charts. Tracks the opening price of each active HTF candle in real time so you always know which candle you are operating within and how much time is left on it.

## Source Code

````pine
//@version=6
// nevels
indicator("4H & 6H Session Opens", overlay=true, max_lines_count=10, max_labels_count=10)

// ─── SETTINGS ─────────────────────────────────────────────────────
var g4 = "4H Line"
var g6 = "6H Line"
var gg = "General"

show_4h      = input.bool(true,  "Show 4H Line",    group=g4)
col_4h       = input.color(color.new(#00BFFF, 0), "Color", group=g4)
style_4h     = input.string("Solid",  "Style",  options=["Solid","Dashed","Dotted"], group=g4)

show_6h      = input.bool(true,  "Show 6H Line",    group=g6)
col_6h       = input.color(color.new(#FF8C00, 0), "Color", group=g6)
style_6h     = input.string("Dashed", "Style",  options=["Solid","Dashed","Dotted"], group=g6)

col_aligned  = input.color(color.new(#FFFFFF, 0), "Aligned Color", group=gg)
lw           = input.int(2, "Line Width", minval=1, maxval=4, group=gg)
extend_right = input.int(50, "Extend Right (bars)", minval=0, maxval=2000, group=gg)
show_labels  = input.bool(true, "Show Labels", group=gg)
show_timer   = input.bool(true, "Show Candle Timer", group=gg)
timer_pos    = input.string("Bottom Right", "Timer Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gg)

// ─── HELPERS ──────────────────────────────────────────────────────
getStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

fmtHour(h) =>
    h == 0 ? "00:00" : h == 2 ? "02:00" : h == 6 ? "06:00" : h == 10 ? "10:00" : h == 12 ? "12:00" : h == 14 ? "14:00" : h == 18 ? "18:00" : h == 22 ? "22:00" : str.tostring(h) + ":00"

// ─── EXACT HOUR MAPPING (EST) ─────────────────────────────────────
bar_h = hour(time, "America/New_York")

get4h_label() =>
    h = bar_h
    (h >= 18 and h <= 21) ? 18 : (h >= 22 or h == 23) ? 22 : (h == 0 or h == 1) ? 22 : (h >= 2 and h <= 5) ? 2 : (h >= 6 and h <= 9) ? 6 : (h >= 10 and h <= 13) ? 10 : 14

get6h_label() =>
    h = bar_h
    (h >= 18 and h <= 23) ? 18 : (h >= 0 and h <= 5) ? 0 : (h >= 6 and h <= 11) ? 6 : 12

is_aligned() =>
    h = bar_h
    (h >= 18 and h <= 21) or (h >= 6 and h <= 9)

// ─── STATE ────────────────────────────────────────────────────────
var line  l4    = na
var line  l6    = na
var label lbl4  = na
var label lbl6  = na
var int   prev4 = -1
var int   prev6 = -1
var int   b6h_spawn = na

cur4    = get4h_label()
cur6    = get6h_label()
aligned = is_aligned()
new4    = cur4 != prev4
new6    = cur6 != prev6

// ─── NEW 4H ───────────────────────────────────────────────────────
if new4
    prev4 := cur4
    line.delete(l4)
    label.delete(lbl4)
    l4   := na
    lbl4 := na
    if show_4h
        c4   = aligned ? col_aligned : col_4h
        txt4 = aligned ? fmtHour(cur4) + "  (4H/6H)" : fmtHour(cur4) + "  (4H)"
        x2   = bar_index + extend_right
        l4  := line.new(x1=bar_index, y1=open, x2=x2, y2=open, color=c4, width=lw, style=getStyle(style_4h), extend=extend.none)
        if show_labels
            lbl4 := label.new(x=x2, y=open, text=txt4, color=color.new(c4, 100), textcolor=c4, style=label.style_label_left, size=size.small)

// ─── NEW 6H ───────────────────────────────────────────────────────
if new6
    prev6 := cur6
    if not aligned
        line.delete(l6)
        label.delete(lbl6)
        l6   := na
        lbl6 := na
        if show_6h
            txt6 = fmtHour(cur6) + "  (6H)"
            x2   = bar_index + extend_right
            l6  := line.new(x1=bar_index, y1=open, x2=x2, y2=open, color=col_6h, width=lw, style=getStyle(style_6h), extend=extend.none)
            if show_labels
                lbl6 := label.new(x=x2, y=open, text=txt6, color=color.new(col_6h, 100), textcolor=col_6h, style=label.style_label_left, size=size.small)

// ─── SPAWN 6H LINE WHEN 4H OPENS AFTER ALIGNED SESSION ───────────
if new4 and aligned
    b6h_spawn := bar_index
    line.delete(l6)
    label.delete(lbl6)
    l6   := na
    lbl6 := na

if new4 and not aligned
    if na(l6) and show_6h
        prev6_open = request.security(syminfo.tickerid, "360", open, lookahead=barmerge.lookahead_on)
        txt6_new   = fmtHour(cur6) + "  (6H)"
        x1_new     = na(b6h_spawn) ? bar_index : b6h_spawn
        x2_new     = bar_index + extend_right
        l6   := line.new(x1=x1_new, y1=prev6_open, x2=x2_new, y2=prev6_open, color=col_6h, width=lw, style=getStyle(style_6h), extend=extend.none)
        if show_labels
            lbl6 := label.new(x=x2_new, y=prev6_open, text=txt6_new, color=color.new(col_6h, 100), textcolor=col_6h, style=label.style_label_left, size=size.small)

// ─── EXTEND ON EVERY BAR ──────────────────────────────────────────
if not na(l4)
    x2 = bar_index + extend_right
    line.set_x2(l4, x2)
    if show_labels and not na(lbl4)
        label.set_x(lbl4, x2)

if not na(l6)
    x2 = bar_index + extend_right
    line.set_x2(l6, x2)
    if show_labels and not na(lbl6)
        label.set_x(lbl6, x2)

// ─── SESSION TIMER TABLE ──────────────────────────────────────────
// Uses time_close(HTF) - timenow for realtime per-second accuracy on any chart TF
fmtRem(secs) =>
    h = math.floor(secs / 3600)
    m = math.floor((secs % 3600) / 60)
    hs = str.tostring(h) + "h "
    ms = m < 10 ? "0" + str.tostring(m) + "m" : str.tostring(m) + "m"
    h > 0 ? hs + ms : ms

var table t = table.new(timer_pos == "Top Right" ? position.top_right : timer_pos == "Top Left" ? position.top_left : timer_pos == "Bottom Left" ? position.bottom_left : position.bottom_right, 2, 3, bgcolor=color.new(#222222, 0), border_color=color.new(#444444, 0), border_width=1, frame_color=color.new(#C00000, 0), frame_width=1)

if show_timer and (barstate.isrealtime or barstate.islast)
    // Pull closing time of current 4H and 6H candle — updates every tick in realtime
    rem4_secs = math.max(0, math.floor((time_close("240") - timenow) / 1000))
    rem6_secs = math.max(0, math.floor((time_close("360") - timenow) / 1000))

    // Header
    table.cell(t, 0, 0, "CANDLE",    text_color=color.new(#FF2222, 0), text_size=size.normal, bgcolor=color.new(#2A2A2A, 0), text_halign=text.align_center)
    table.cell(t, 1, 0, "REMAINING", text_color=color.new(#FF2222, 0), text_size=size.normal, bgcolor=color.new(#2A2A2A, 0), text_halign=text.align_center)

    // 4H row
    table.cell(t, 0, 1, fmtHour(cur4) + " (4H)", text_color=color.new(#AAAAAA, 0), text_size=size.small, bgcolor=color.new(#222222, 0), text_halign=text.align_center)
    table.cell(t, 1, 1, fmtRem(rem4_secs), text_color=color.new(#FFFFFF, 0), text_size=size.small, bgcolor=color.new(#222222, 0), text_halign=text.align_center)

    // 6H row
    table.cell(t, 0, 2, fmtHour(cur6) + " (6H)", text_color=color.new(#AAAAAA, 0), text_size=size.small, bgcolor=color.new(#222222, 0), text_halign=text.align_center)
    table.cell(t, 1, 2, fmtRem(rem6_secs), text_color=color.new(#FFFFFF, 0), text_size=size.small, bgcolor=color.new(#222222, 0), text_halign=text.align_center)
````
