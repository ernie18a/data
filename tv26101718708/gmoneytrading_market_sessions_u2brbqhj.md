# GMONEYTRADING | Market Sessions

- url: https://www.tradingview.com/script/U2BrbQhJ-GMONEYTRADING-Market-Sessions/
- type: indicator
- pine_id: PUB;201aca1731f14bc3930d3776d3e839de
- version: 4.0

## Description

GMONEYTRADING | Market Sessions

A customized session analysis tool built from the original FX Market Sessions framework by boitoki.

This edition expands the original concept with:
• Direction-based bullish/bearish session coloring
• Dynamic Fibonacci session mapping
• Average range projection levels
• Enhanced visual session structure tools

Designed around the GMONEY NYSE trading strategy, with a strong focus on session structure, momentum, Fibonacci execution, and intraday range analysis during the New York session.

The indicator can also be adapted and used across all major market sessions including Asia, London, New York, custom intraday windows, and personal trading workflows.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © G-MoneyFX
// Inspired by FX Market Sessions © boitoki


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GMONEY 一 Market Sessions
// Author: @gmoneytrading
// Version: Lite 1.3


//@version=6
indicator("GMONEY | Market Sessions", overlay=true, max_lines_count=100, max_labels_count=50, max_boxes_count=50)

//──────────────────────────────────────────────────────────
// FIXED SESSION TIMES (Central time — not editable)
//──────────────────────────────────────────────────────────
ASIA_SESS   = "1800-0000"
LONDON_SESS = "0200-0600"
NY_SESS     = "0700-1515"
DAY_SESS    = "1800-1515"  // Asia open → New York close

TRANSPARENT = color.new(color.black, 100)

//──────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────
grpTZ   = "🌐 TIMEZONE"
grpSess = "🕒 SESSIONS"
grpDisp = "🎨 DISPLAY"

// Timezone · history
i_tz        = input.string("America/Chicago", "Timezone", options=["America/Chicago", "America/New_York", "Europe/London", "UTC"], group=grpTZ, inline="tz")
i_history   = input.int(2, "", minval=1, maxval=10, group=grpTZ, inline="tz", tooltip="Timezone: keep America/Chicago.\nSession times are fixed in Central time and adjust for daylight saving automatically.\n\nNumber = History, how many of each session stay drawn.\n1 = current only\n2 = current + previous (default)")

// Day box + sessions
i_day       = input.bool(true, "Day Box", group=grpSess, inline="day")
i_day_col   = input.color(color.gray, "", group=grpSess, inline="day")
i_day_style = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=grpSess, inline="day", tooltip="One box per trading day: 6:00 PM – 3:15 PM (Central), wrapping Asia, London and New York together.\n\nTop = day high. Bottom = day low.\n\nColor · border style.")
i_asia      = input.bool(true, "Asia", group=grpSess, inline="asia")
i_asia_col  = input.color(#000000, "", group=grpSess, inline="asia", tooltip="Asia: 6:00 PM – 12:00 AM (Central).\n\nColor = box and label color when Direction Color is off.")
i_ldn       = input.bool(true, "London", group=grpSess, inline="ldn")
i_ldn_col   = input.color(#000000, "", group=grpSess, inline="ldn", tooltip="London: 2:00 AM – 6:00 AM (Central).\n\nColor = box and label color when Direction Color is off.")
i_ny        = input.bool(true, "New York", group=grpSess, inline="ny")
i_ny_col    = input.color(#000000, "", group=grpSess, inline="ny", tooltip="New York: 7:00 AM – 3:15 PM (Central).\n\nColor = box and label color when Direction Color is off.")

// Display
i_dircolor  = input.bool(true, "Direction Color", group=grpDisp, inline="dir")
i_bull_col  = input.color(color.blue, "", group=grpDisp, inline="dir")
i_bear_col  = input.color(color.red, "", group=grpDisp, inline="dir", tooltip="Bull · Bear.\n\nBull = session low formed first, then the high.\n\nBear = session high formed first, then the low.")
i_bg        = input.bool(true, "Box Background", group=grpDisp)
i_labels    = input.bool(true, "Labels", group=grpDisp, inline="lbl")
i_lbl_size  = input.string(size.normal, "", options=[size.tiny, size.small, size.normal, size.large], group=grpDisp, inline="lbl", tooltip="Session name and range in pips.\n\nGold: 1 pip = $0.10.")

day_border  = i_day_style == "Dashed" ? line.style_dashed : i_day_style == "Dotted" ? line.style_dotted : line.style_solid

//──────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────
// Pip size from the instrument's price level (gold 0.10, EURUSD 0.0001, USDJPY 0.01)
pipSize = math.pow(10, math.floor(math.log10(close)) - 4)

//──────────────────────────────────────────────────────────
// SESSION ENGINE — one call per session
//──────────────────────────────────────────────────────────
f_session(bool _show, string _sess, string _name, color _base) =>
    var line[]     tops   = array.new<line>()
    var line[]     bots   = array.new<line>()
    var linefill[] fills  = array.new<linefill>()
    var label[]    lbls   = array.new<label>()
    var float      hi     = na
    var float      lo     = na
    var int        hiBar  = na
    var int        loBar  = na

    t        = time(timeframe.period, _sess, i_tz)
    inSess   = not na(t)
    started  = inSess and na(t[1])
    active   = _show and timeframe.isintraday

    if active and started
        hi    := high
        lo    := low
        hiBar := bar_index
        loBar := bar_index

        line tl = line.new(bar_index, hi, bar_index, hi, color=_base, width=1)
        line bl = line.new(bar_index, lo, bar_index, lo, color=_base, width=1)
        array.push(tops, tl)
        array.push(bots, bl)
        array.push(fills, linefill.new(tl, bl, i_bg ? color.new(_base, 90) : TRANSPARENT))

        if i_labels
            array.push(lbls, label.new(bar_index, lo, _name, style=label.style_label_upper_left, color=TRANSPARENT, textcolor=_base, size=i_lbl_size, textalign=text.align_left))

        // Keep only the newest sessions (History)
        while array.size(tops) > i_history
            line.delete(array.shift(tops))
            line.delete(array.shift(bots))
            linefill.delete(array.shift(fills))
        while array.size(lbls) > i_history
            label.delete(array.shift(lbls))

    else if active and inSess and array.size(tops) > 0
        if high > hi
            hi    := high
            hiBar := bar_index
        if low < lo
            lo    := low
            loBar := bar_index

        bool  isBull = loBar < hiBar
        bool  isBear = hiBar < loBar
        color c      = i_dircolor ? (isBull ? i_bull_col : isBear ? i_bear_col : _base) : _base

        line tl = array.last(tops)
        line bl = array.last(bots)
        line.set_y1(tl, hi)
        line.set_y2(tl, hi)
        line.set_x2(tl, bar_index)
        line.set_color(tl, c)
        line.set_y1(bl, lo)
        line.set_y2(bl, lo)
        line.set_x2(bl, bar_index)
        line.set_color(bl, c)
        linefill.set_color(array.last(fills), i_bg ? color.new(c, 90) : TRANSPARENT)

        if i_labels and array.size(lbls) > 0
            label lb = array.last(lbls)
            // Bear → label above the high; Bull → label below the low
            label.set_y(lb, isBear ? hi : lo)
            label.set_style(lb, isBear ? label.style_label_lower_left : label.style_label_upper_left)
            label.set_text(lb, _name + "\n" + str.tostring((hi - lo) / pipSize, "#.#"))
            label.set_textcolor(lb, c)
    inSess

//──────────────────────────────────────────────────────────
// DAY BOX — one outline per trading day around all three sessions
//──────────────────────────────────────────────────────────
f_day(bool _show, color _col) =>
    var box[] boxes = array.new<box>()
    var float hi    = na
    var float lo    = na

    t       = time(timeframe.period, DAY_SESS, i_tz)
    inSess  = not na(t)
    started = inSess and na(t[1])
    active  = _show and timeframe.isintraday

    if active and started
        hi := high
        lo := low
        array.push(boxes, box.new(bar_index, hi, bar_index, lo, border_color=_col, border_width=1, border_style=day_border, bgcolor=TRANSPARENT))
        while array.size(boxes) > i_history
            box.delete(array.shift(boxes))

    else if active and inSess and array.size(boxes) > 0
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        box b = array.last(boxes)
        box.set_top(b, hi)
        box.set_bottom(b, lo)
        box.set_right(b, bar_index)
        box.set_border_color(b, _col)
    inSess

//──────────────────────────────────────────────────────────
// DRAW
//──────────────────────────────────────────────────────────
f_day(i_day, i_day_col)
f_session(i_asia, ASIA_SESS,   "Asia",     i_asia_col)
f_session(i_ldn,  LONDON_SESS, "London",   i_ldn_col)
f_session(i_ny,   NY_SESS,     "New York", i_ny_col)
````
