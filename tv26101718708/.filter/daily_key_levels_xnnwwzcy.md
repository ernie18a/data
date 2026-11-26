# Daily Key Levels

- url: https://www.tradingview.com/script/XnNwWzCy-Daily-Key-Levels/
- type: indicator
- pine_id: PUB;5dc53a62ccce4c2b9bab20c24b079017
- version: 2.0

## Description

Daily Key Levels marks important New York-session opening prices directly on the chart, helping intraday traders keep the current session’s main reference levels visible without carrying old historical lines forward.

The indicator captures each level from 1-minute data and projects it across the active session only. The session resets at 18:00 New York time, matching the common futures session structure.

[b]Key Features[/b]

[list]
[*]  Marks the 18:00 market open, 8:30 news level, 9:30 New York open, and 10:00 macro level.
[*]  Optional 4-hour opening prices: 18:00, 22:00, 02:00, 06:00, 10:00, and 14:00.
[*]  Optional 6-hour opening prices: 18:00, 00:00, 06:00, and 12:00.
[*]  Automatically avoids duplicate stacked lines when the same timestamp belongs to multiple groups.
[*]  Only displays levels for the current active session.
[/list]

[b]Overlap Logic[/b]
When multiple level groups share the same timestamp, the indicator uses a clean priority rule:

[list]
[*]  Dedicated key levels > 4-hour opens > 6-hour opens
[/list]

For example, the standalone 18:00 market-open level takes priority over both 4H and 6H 18:00 levels. The standalone 10:00 macro level takes priority over the 4H 10:00 level.

[b]Notes[/b]
This indicator is designed as a visual reference tool for intraday context, planning, and level awareness. It does not generate trade signals, entries, exits, or alerts. Level accuracy depends on the chart symbol’s available 1-minute data and TradingView’s session/feed data.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NixYoung

//@version=6
indicator("Daily Key Levels", overlay=true, precision=2, max_labels_count=20, max_lines_count=20)

// ============================================
// INPUTS
// ============================================

showLevel1 = input.bool(true, "18:00 Market Open", group="Levels")
showLevel2 = input.bool(true, "8:30 News Level",   group="Levels")
showLevel3 = input.bool(true, "9:30 NY Open",      group="Levels")
showLevel4 = input.bool(true, "10:00 Macro Level",       group="Levels")
show4hOpens = input.bool(false, "4-Hour Opening Prices", group="Levels")
show6hOpens = input.bool(false, "6-Hour Opening Prices", group="Levels")
extendLineRight = input.bool(false, "Extend line to right", group="Line Extension")

// ============================================
// PALETTE
// ============================================

const color level18Color = #CC5C4C
const color intradayLevelColor = #2A8399
const color fourHourColor = #7E70A8
const color sixHourColor = #B1843F

label18Color = input.color(#CC5C4C, "18:00 Market Open Label", group="Label Colours")
labelIntradayColor = input.color(#2A8399, "Intraday Level Labels", group="Label Colours")
labelFourHourColor = input.color(#7E70A8, "4-Hour Opening Price Labels", group="Label Colours")
labelSixHourColor = input.color(#B1843F, "6-Hour Opening Price Labels", group="Label Colours")

// ============================================
// SESSION STATE (via 1m chart)
// ============================================
// We persist levels inside the 1m context so higher timeframes always see the
// latest value (not just the exact minute). The session day resets at 18:00 NY.

f_sessionKey(t) =>
    int shiftMs = 18 * 60 * 60 * 1000
    int keyYear = year(t - shiftMs, "America/New_York")
    int keyMonth = month(t - shiftMs, "America/New_York")
    int keyDom = dayofmonth(t - shiftMs, "America/New_York")
    keyYear * 10000 + keyMonth * 100 + keyDom

f_sessionState() =>
    var float s18    = na
    var float s22    = na
    var float s0     = na
    var float s2     = na
    var float s6     = na
    var float s830   = na
    var float s930   = na
    var float s1000  = na
    var float s12    = na
    var float s14    = na
    var int   t18    = na
    var int   t22    = na
    var int   t0     = na
    var int   t2     = na
    var int   t6     = na
    var int   t830   = na
    var int   t930   = na
    var int   t1000  = na
    var int   t12    = na
    var int   t14    = na
    var int   lastKey = na

    ny_h = hour(time, "America/New_York")
    ny_m = minute(time, "America/New_York")
    sessKey = f_sessionKey(time)

    if na(lastKey) or sessKey != lastKey
        s18     := na
        s22     := na
        s0      := na
        s2      := na
        s6      := na
        s830    := na
        s930    := na
        s1000   := na
        s12     := na
        s14     := na
        t18     := na
        t22     := na
        t0      := na
        t2      := na
        t6      := na
        t830    := na
        t930    := na
        t1000   := na
        t12     := na
        t14     := na
        lastKey := sessKey

    // Capture open + time at the exact session minute (latch once per day)
    if ny_h == 18 and ny_m == 0  and na(s18)
        s18 := open
        t18 := time
    if ny_h == 22 and ny_m == 0 and na(s22)
        s22 := open
        t22 := time
    if ny_h == 0 and ny_m == 0 and na(s0)
        s0 := open
        t0 := time
    if ny_h == 2 and ny_m == 0 and na(s2)
        s2 := open
        t2 := time
    if ny_h == 6 and ny_m == 0 and na(s6)
        s6 := open
        t6 := time
    if ny_h == 8  and ny_m == 30 and na(s830)
        s830 := open
        t830 := time
    if ny_h == 9  and ny_m == 30 and na(s930)
        s930 := open
        t930 := time
    if ny_h == 10 and ny_m == 0  and na(s1000)
        s1000 := open
        t1000 := time
    if ny_h == 12 and ny_m == 0 and na(s12)
        s12 := open
        t12 := time
    if ny_h == 14 and ny_m == 0 and na(s14)
        s14 := open
        t14 := time

    [s18, s22, s0, s2, s6, s830, s930, s1000, s12, s14,
     t18, t22, t0, t2, t6, t830, t930, t1000, t12, t14]

[level18, level22, level0, level2, level6, level830, level930, level1000, level12, level14,
 t18,     t22,     t0,     t2,     t6,     t830,     t930,     t1000,     t12,     t14] = request.security(
     syminfo.tickerid, "1", f_sessionState(), gaps=barmerge.gaps_off)

// ============================================
// HELPERS
// ============================================

f_plotLevel(show, lvl, start_t) =>
    activeSession = f_sessionKey(time) == f_sessionKey(last_bar_time)
    show and activeSession and not na(lvl) and not na(start_t) and time >= start_t ? lvl : na

f_updateRightExtension(ln, show, lvl, start_t, clr, width) =>
    line new_ln = ln
    activeLevel = extendLineRight and show and f_sessionKey(time) == f_sessionKey(last_bar_time) and not na(lvl) and not na(start_t) and time >= start_t
    if activeLevel
        if na(new_ln)
            new_ln := line.new(bar_index, lvl, bar_index + 1, lvl,
                 xloc=xloc.bar_index, extend=extend.right, color=clr, width=width)
        else
            line.set_xy1(new_ln, bar_index, lvl)
            line.set_xy2(new_ln, bar_index + 1, lvl)
            line.set_extend(new_ln, extend.right)
            line.set_color(new_ln, clr)
            line.set_width(new_ln, width)
    else
        if not na(new_ln)
            line.delete(new_ln)
        new_ln := na
    new_ln

// Overlap priority: dedicated key levels > 4-hour opens > 6-hour opens.
show4h18 = show4hOpens and not showLevel1
show4h10 = show4hOpens and not showLevel4
show6h18 = show6hOpens and not showLevel1 and not show4hOpens
show6h6 = show6hOpens and not show4hOpens

// ============================================
// PLOTS
// ============================================

plot(f_plotLevel(showLevel1, level18, t18),
     title="18:00 Market Open", color=level18Color, linewidth=2,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(showLevel2, level830, t830),
     title="8:30 News Level", color=intradayLevelColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(showLevel3, level930, t930),
     title="9:30 NY Open", color=intradayLevelColor, linewidth=2,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(showLevel4, level1000, t1000),
     title="10:00 Level", color=intradayLevelColor, linewidth=1,
     style=plot.style_linebr, editable=true)

plot(f_plotLevel(show4h18, level18, t18),
     title="4H 18:00 Open", color=fourHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show4hOpens, level22, t22),
     title="4H 22:00 Open", color=fourHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show4hOpens, level2, t2),
     title="4H 02:00 Open", color=fourHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show4hOpens, level6, t6),
     title="4H 06:00 Open", color=fourHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show4h10, level1000, t1000),
     title="4H 10:00 Open", color=fourHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show4hOpens, level14, t14),
     title="4H 14:00 Open", color=fourHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)

plot(f_plotLevel(show6h18, level18, t18),
     title="6H 18:00 Open", color=sixHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show6hOpens, level0, t0),
     title="6H 00:00 Open", color=sixHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show6h6, level6, t6),
     title="6H 06:00 Open", color=sixHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)
plot(f_plotLevel(show6hOpens, level12, t12),
     title="6H 12:00 Open", color=sixHourColor, linewidth=1,
     style=plot.style_linebr, editable=true)

// ============================================
// RIGHT EXTENSIONS
// ============================================

var line ext18 = na
var line ext830 = na
var line ext930 = na
var line ext1000 = na
var line ext4h18 = na
var line ext4h22 = na
var line ext4h2 = na
var line ext4h6 = na
var line ext4h10 = na
var line ext4h14 = na
var line ext6h18 = na
var line ext6h0 = na
var line ext6h6 = na
var line ext6h12 = na

ext18 := f_updateRightExtension(ext18, showLevel1, level18, t18, level18Color, 2)
ext830 := f_updateRightExtension(ext830, showLevel2, level830, t830, intradayLevelColor, 1)
ext930 := f_updateRightExtension(ext930, showLevel3, level930, t930, intradayLevelColor, 2)
ext1000 := f_updateRightExtension(ext1000, showLevel4, level1000, t1000, intradayLevelColor, 1)
ext4h18 := f_updateRightExtension(ext4h18, show4h18, level18, t18, fourHourColor, 1)
ext4h22 := f_updateRightExtension(ext4h22, show4hOpens, level22, t22, fourHourColor, 1)
ext4h2 := f_updateRightExtension(ext4h2, show4hOpens, level2, t2, fourHourColor, 1)
ext4h6 := f_updateRightExtension(ext4h6, show4hOpens, level6, t6, fourHourColor, 1)
ext4h10 := f_updateRightExtension(ext4h10, show4h10, level1000, t1000, fourHourColor, 1)
ext4h14 := f_updateRightExtension(ext4h14, show4hOpens, level14, t14, fourHourColor, 1)
ext6h18 := f_updateRightExtension(ext6h18, show6h18, level18, t18, sixHourColor, 1)
ext6h0 := f_updateRightExtension(ext6h0, show6hOpens, level0, t0, sixHourColor, 1)
ext6h6 := f_updateRightExtension(ext6h6, show6h6, level6, t6, sixHourColor, 1)
ext6h12 := f_updateRightExtension(ext6h12, show6hOpens, level12, t12, sixHourColor, 1)

// ============================================
// LABELS
// ============================================

var label lbl18   = na
var label lbl830  = na
var label lbl930  = na
var label lbl1000 = na
var label lbl4h18 = na
var label lbl4h22 = na
var label lbl4h2  = na
var label lbl4h6  = na
var label lbl4h10 = na
var label lbl4h14 = na
var label lbl6h18 = na
var label lbl6h0  = na
var label lbl6h6  = na
var label lbl6h12 = na

f_updateLabel(lbl, show, lvl, start_t, txt, txtColor) =>
    label new_lbl = na
    if show and not na(lvl) and not na(start_t)
        if na(lbl)
            new_lbl := label.new(time, lvl, txt,
                 color=na, textcolor=txtColor,
                 style=label.style_label_left, size=size.normal, yloc=yloc.price,
                 xloc=xloc.bar_time)
        else
            label.set_x(lbl, time)
            label.set_y(lbl, lvl)
            label.set_text(lbl, txt)
            label.set_color(lbl, na)
            label.set_textcolor(lbl, txtColor)
            new_lbl := lbl
    else
        label.delete(lbl)
    new_lbl

lbl18   := f_updateLabel(lbl18,   showLevel1, level18,   t18,   "18:00", label18Color)
lbl830  := f_updateLabel(lbl830,  showLevel2, level830,  t830,  "8:30", labelIntradayColor)
lbl930  := f_updateLabel(lbl930,  showLevel3, level930,  t930,  "9:30", labelIntradayColor)
lbl1000 := f_updateLabel(lbl1000, showLevel4, level1000, t1000, "10:00", labelIntradayColor)
lbl4h18 := f_updateLabel(lbl4h18, show4h18, level18, t18, "4H 18:00", labelFourHourColor)
lbl4h22 := f_updateLabel(lbl4h22, show4hOpens, level22, t22, "4H 22:00", labelFourHourColor)
lbl4h2  := f_updateLabel(lbl4h2, show4hOpens, level2, t2, "4H 02:00", labelFourHourColor)
lbl4h6  := f_updateLabel(lbl4h6, show4hOpens, level6, t6, "4H 06:00", labelFourHourColor)
lbl4h10 := f_updateLabel(lbl4h10, show4h10, level1000, t1000, "4H 10:00", labelFourHourColor)
lbl4h14 := f_updateLabel(lbl4h14, show4hOpens, level14, t14, "4H 14:00", labelFourHourColor)
lbl6h18 := f_updateLabel(lbl6h18, show6h18, level18, t18, "6H 18:00", labelSixHourColor)
lbl6h0  := f_updateLabel(lbl6h0, show6hOpens, level0, t0, "6H 00:00", labelSixHourColor)
lbl6h6  := f_updateLabel(lbl6h6, show6h6, level6, t6, "6H 06:00", labelSixHourColor)
lbl6h12 := f_updateLabel(lbl6h12, show6hOpens, level12, t12, "6H 12:00", labelSixHourColor)
````
