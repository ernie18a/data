# Forex H/L Levels

- url: https://www.tradingview.com/script/UTJKTVi8-Forex-H-L-Levels/
- type: indicator
- pine_id: PUB;7cf6692ba32c4dac8d55a5c9dfc9e2bd
- version: 1.0

## Description

# Forex H/L Levels — Day / Week / Month / Sessions

A single indicator that plots the running high and low of the current Day, Week, Month and of the four major Forex trading sessions (Sydney, Tokyo, London, New York) as horizontal levels with optional labels.

It is designed for day-traders and scalpers who use session highs/lows and higher-timeframe extremes as key liquidity and reaction points.

## Features

- **Higher-timeframe H/L** – rolling Day, Week and Month high & low, updated live on every candle.
- **Session H/L** – separate high and low for each session:
  - Sydney 21:00–06:00 UTC
  - Tokyo 00:00–09:00 UTC
  - London 07:00–16:00 UTC
  - New York 12:00–21:00 UTC
  All time windows are computed in UTC, so the indicator behaves identically regardless of the chart’s timezone.
- **Fully customisable** – every level group has its own show/hide toggle, colour for the high and low, line style (solid / dashed / dotted) and line width.
- **Session background shading** – optional subtle tint for the currently active session so you can see at a glance who is driving price.
- **Smart, non-overlapping labels** – every enabled level is labelled with its name and exact price. When two or more levels are close in price, the labels are automatically laid out side-by-side in columns instead of stacking on top of each other. The "closeness" threshold is expressed as a multiple of ATR(14) and is user-configurable, so it adapts to any instrument or timeframe.
- **Non-repainting** – all lines and labels are drawn only on the last confirmed bar and are fully refreshed on every tick, so levels never duplicate and never repaint historical bars.

## Inputs

- **Daily / Weekly / Monthly** – show toggle, high colour, low colour, line style, line width.
- **Sydney / Tokyo / London / New York** – same controls as above; background shading is controlled by the same "show" toggle.
- **Labels**
  - *Show level labels* – master toggle.
  - *Label offset (bars right)* – how far to the right of the last bar the labels sit.
  - *Label column spacing (bars)* – horizontal distance between columns when labels overlap.
  - *Overlap threshold (× ATR14)* – labels whose prices are within this many ATR(14) of each other are placed side-by-side. Increase it if labels still visually overlap on your chart; decrease it if you want labels to stack only when truly on top of one another.

## How to use

1. Add the indicator to any chart (Forex, indices, crypto, stocks — all work).
2. Enable the level groups you care about from the settings panel.
3. Use the higher-timeframe levels (Daily / Weekly / Monthly H/L) as major S/R and breakout zones.
4. Use the session H/L as intraday liquidity pools — price very often sweeps the prior session’s high or low before reversing or continuing.
5. Tune the *Overlap threshold* so labels read cleanly on your timeframe; on intraday charts 0.3–0.5 × ATR works well, on higher timeframes 0.5–1.0 × ATR is usually enough.

## Notes

- London and New York overlap between 12:00 and 16:00 UTC — during that window both sets of levels will be visible, which is intentional and matches how traders actually watch those sessions.
- Because the indicator renders only on the last bar, scrolling back in time will not show historical session boxes; the goal is a clean, current snapshot of active levels, not a full historical replay.

## Disclaimer

This script is provided for educational and informational purposes only and does not constitute financial advice. Levels drawn by any indicator are objective price references — how you trade around them is your own responsibility. Past performance is not indicative of future results.

Open source — feel free to use, study and adapt.

## Source Code

````pine
//@version=5
indicator("Forex H/L Levels", 
     overlay=true, 
     max_lines_count=500,
     max_labels_count=500)

// ???????????????????????????????????????????????????????????????????
//  INPUTS
// ???????????????????????????????????????????????????????????????????

// ?? Daily ??
show_daily       = input.bool(true,  "Show Daily H/L",             group="? Daily")
col_daily_high   = input.color(color.new(#38BDF8, 0),  "High colour", group="? Daily")
col_daily_low    = input.color(color.new(#38BDF8, 0),  "Low colour",  group="? Daily")
style_daily      = input.string("Solid", "Line style",             group="? Daily", options=["Solid","Dashed","Dotted"])
width_daily      = input.int(2, "Line width", minval=1, maxval=4,  group="? Daily")

// ?? Weekly ??
show_weekly      = input.bool(true,  "Show Weekly H/L",            group="? Weekly")
col_weekly_high  = input.color(color.new(#818CF8, 0),  "High colour", group="? Weekly")
col_weekly_low   = input.color(color.new(#818CF8, 0),  "Low colour",  group="? Weekly")
style_weekly     = input.string("Dashed", "Line style",            group="? Weekly", options=["Solid","Dashed","Dotted"])
width_weekly     = input.int(2, "Line width", minval=1, maxval=4,  group="? Weekly")

// ?? Monthly ??
show_monthly     = input.bool(true,  "Show Monthly H/L",           group="?? Monthly")
col_monthly_high = input.color(color.new(#FBBF24, 0),  "High colour", group="?? Monthly")
col_monthly_low  = input.color(color.new(#FBBF24, 0),  "Low colour",  group="?? Monthly")
style_monthly    = input.string("Dashed", "Line style",            group="?? Monthly", options=["Solid","Dashed","Dotted"])
width_monthly    = input.int(2, "Line width", minval=1, maxval=4,  group="?? Monthly")

// ?? Sydney Session ??
show_sydney      = input.bool(true,  "Show Sydney Session H/L",    group="? Sydney Session  (21:00?06:00 UTC)")
col_sydney_high  = input.color(color.new(#34D399, 0),  "High colour", group="? Sydney Session  (21:00?06:00 UTC)")
col_sydney_low   = input.color(color.new(#34D399, 0),  "Low colour",  group="? Sydney Session  (21:00?06:00 UTC)")
style_sydney     = input.string("Dotted", "Line style",            group="? Sydney Session  (21:00?06:00 UTC)", options=["Solid","Dashed","Dotted"])
width_sydney     = input.int(1, "Line width", minval=1, maxval=4,  group="? Sydney Session  (21:00?06:00 UTC)")

// ?? Tokyo Session ??
show_tokyo       = input.bool(true,  "Show Tokyo Session H/L",     group="? Tokyo Session  (00:00?09:00 UTC)")
col_tokyo_high   = input.color(color.new(#F472B6, 0),  "High colour", group="? Tokyo Session  (00:00?09:00 UTC)")
col_tokyo_low    = input.color(color.new(#F472B6, 0),  "Low colour",  group="? Tokyo Session  (00:00?09:00 UTC)")
style_tokyo      = input.string("Dotted", "Line style",            group="? Tokyo Session  (00:00?09:00 UTC)", options=["Solid","Dashed","Dotted"])
width_tokyo      = input.int(1, "Line width", minval=1, maxval=4,  group="? Tokyo Session  (00:00?09:00 UTC)")

// ?? London Session ??
show_london      = input.bool(true,  "Show London Session H/L",    group="?? London Session  (07:00?16:00 UTC)")
col_london_high  = input.color(color.new(#FB923C, 0),  "High colour", group="?? London Session  (07:00?16:00 UTC)")
col_london_low   = input.color(color.new(#FB923C, 0),  "Low colour",  group="?? London Session  (07:00?16:00 UTC)")
style_london     = input.string("Dotted", "Line style",            group="?? London Session  (07:00?16:00 UTC)", options=["Solid","Dashed","Dotted"])
width_london     = input.int(1, "Line width", minval=1, maxval=4,  group="?? London Session  (07:00?16:00 UTC)")

// ?? New York Session ??
show_newyork     = input.bool(true,  "Show New York Session H/L",  group="? New York Session  (12:00?21:00 UTC)")
col_ny_high      = input.color(color.new(#F87171, 0),  "High colour", group="? New York Session  (12:00?21:00 UTC)")
col_ny_low       = input.color(color.new(#F87171, 0),  "Low colour",  group="? New York Session  (12:00?21:00 UTC)")
style_newyork    = input.string("Dotted", "Line style",            group="? New York Session  (12:00?21:00 UTC)", options=["Solid","Dashed","Dotted"])
width_newyork    = input.int(1, "Line width", minval=1, maxval=4,  group="? New York Session  (12:00?21:00 UTC)")

// ?? Labels ??
show_labels      = input.bool(true, "Show level labels",           group="?? Labels")
label_offset     = input.int(3,     "Label offset (bars right)",   group="?? Labels", minval=1, maxval=20)
label_spacing    = input.int(8,     "Label column spacing (bars)", group="?? Labels", minval=2, maxval=40, tooltip="Horizontal spacing (in bars) between labels when several overlap.")
overlap_factor   = input.float(0.5, "Overlap threshold (x ATR14)", group="?? Labels", minval=0.1, maxval=10.0, step=0.1, tooltip="Labels whose prices are within this many ATR(14) of each other are laid out side-by-side instead of stacking on top of each other.")

// ???????????????????????????????????????????????????????????????????
//  HELPERS
// ???????????????????????????????????????????????????????????????????
f_line_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// Draw or extend a persistent horizontal line
// Returns the line object so it can be stored
f_draw_line(price, col, lw, ls) =>
    ln = line.new(bar_index, price, bar_index + 1, price,
         color=col, width=lw, style=ls, extend=extend.right)
    ln

// Draw a label to the right of the current bar
f_draw_label(price, txt, col, is_high) =>
    lbl = label.new(bar_index + label_offset, price,
          text=txt, color=color.new(col, 85),
          textcolor=col, style=is_high ? label.style_label_down : label.style_label_up,
          size=size.small)
    lbl

// ???????????????????????????????????????????????????????????????????
//  UTC HOUR HELPER  (works for any chart timezone)
// ???????????????????????????????????????????????????????????????????
utc_hour  = hour(time, "UTC")
utc_dow   = dayofweek(time, "UTC")   // 1=Sun 2=Mon ... 7=Sat

// ???????????????????????????????????????????????????????????????????
//  SESSION TIME WINDOWS  (UTC)
//  Sydney  : 21:00 ? 06:00  (crosses midnight)
//  Tokyo   : 00:00 ? 09:00
//  London  : 07:00 ? 16:00
//  New York: 12:00 ? 21:00
// ???????????????????????????????????????????????????????????????????
in_sydney  = (utc_hour >= 21) or  (utc_hour < 6)
in_tokyo   = (utc_hour >= 0)  and (utc_hour < 9)
in_london  = (utc_hour >= 7)  and (utc_hour < 16)
in_newyork = (utc_hour >= 12) and (utc_hour < 21)

// Session opens  (first bar of each session)
sydney_open   = in_sydney  and not ((hour(time[1],"UTC") >= 21) or  (hour(time[1],"UTC") < 6))
tokyo_open    = in_tokyo   and not ((hour(time[1],"UTC") >= 0)  and (hour(time[1],"UTC") < 9))
london_open   = in_london  and not ((hour(time[1],"UTC") >= 7)  and (hour(time[1],"UTC") < 16))
newyork_open  = in_newyork and not ((hour(time[1],"UTC") >= 12) and (hour(time[1],"UTC") < 21))

// ???????????????????????????????????????????????????????????????????
//  PERIOD CHANGE DETECTION
// ???????????????????????????????????????????????????????????????????
new_day   = ta.change(time("D"))   != 0
new_week  = ta.change(time("W"))   != 0
new_month = ta.change(time("M"))   != 0

// ???????????????????????????????????????????????????????????????????
//  ROLLING H/L TRACKING
// ???????????????????????????????????????????????????????????????????

// ?? Daily ??
var float d_high = na
var float d_low  = na
if new_day or na(d_high)
    d_high := high
    d_low  := low
else
    d_high := math.max(d_high, high)
    d_low  := math.min(d_low,  low)

// ?? Weekly ??
var float w_high = na
var float w_low  = na
if new_week or na(w_high)
    w_high := high
    w_low  := low
else
    w_high := math.max(w_high, high)
    w_low  := math.min(w_low,  low)

// ?? Monthly ??
var float m_high = na
var float m_low  = na
if new_month or na(m_high)
    m_high := high
    m_low  := low
else
    m_high := math.max(m_high, high)
    m_low  := math.min(m_low,  low)

// ?? Sydney ??
var float sy_high = na
var float sy_low  = na
if sydney_open
    sy_high := high
    sy_low  := low
else if in_sydney
    sy_high := math.max(sy_high, high)
    sy_low  := math.min(sy_low,  low)

// ?? Tokyo ??
var float to_high = na
var float to_low  = na
if tokyo_open
    to_high := high
    to_low  := low
else if in_tokyo
    to_high := math.max(to_high, high)
    to_low  := math.min(to_low,  low)

// ?? London ??
var float lo_high = na
var float lo_low  = na
if london_open
    lo_high := high
    lo_low  := low
else if in_london
    lo_high := math.max(lo_high, high)
    lo_low  := math.min(lo_low,  low)

// ?? New York ??
var float ny_high = na
var float ny_low  = na
if newyork_open
    ny_high := high
    ny_low  := low
else if in_newyork
    ny_high := math.max(ny_high, high)
    ny_low  := math.min(ny_low,  low)

// ???????????????????????????????????????????????????????????????????
//  ATR (computed every bar so Pine keeps its history correctly)
// ???????????????????????????????????????????????????????????????????
atr14 = ta.atr(14)

// ???????????????????????????????????????????????????????????????????
//  Persistent collections of every line/label we draw on the last
//  bar. Each new real-time tick we wipe them before redrawing, so
//  the labels and lines never pile up across ticks or new bars.
// ???????????????????????????????????????????????????????????????????
var line[]  drawn_lines  = array.new_line()
var label[] drawn_labels = array.new_label()

// ???????????????????????????????????????????????????????????????????
//  DRAW LINES  (only on the last confirmed bar to avoid repainting)
// ???????????????????????????????????????????????????????????????????
if barstate.islast

    // Clear whatever we drew on the previous tick/bar so we don't
    // stack duplicates on every real-time update.
    while array.size(drawn_lines) > 0
        line.delete(array.pop(drawn_lines))
    while array.size(drawn_labels) > 0
        label.delete(array.pop(drawn_labels))

    // ?? Daily lines ??
    if show_daily and not na(d_high)
        array.push(drawn_lines, line.new(bar_index - 300, d_high, bar_index, d_high,
             color=col_daily_high, width=width_daily,
             style=f_line_style(style_daily), extend=extend.right))
        array.push(drawn_lines, line.new(bar_index - 300, d_low, bar_index, d_low,
             color=col_daily_low, width=width_daily,
             style=f_line_style(style_daily), extend=extend.right))

    // ?? Weekly lines ??
    if show_weekly and not na(w_high)
        array.push(drawn_lines, line.new(bar_index - 300, w_high, bar_index, w_high,
             color=col_weekly_high, width=width_weekly,
             style=f_line_style(style_weekly), extend=extend.right))
        array.push(drawn_lines, line.new(bar_index - 300, w_low, bar_index, w_low,
             color=col_weekly_low, width=width_weekly,
             style=f_line_style(style_weekly), extend=extend.right))

    // ?? Monthly lines ??
    if show_monthly and not na(m_high)
        array.push(drawn_lines, line.new(bar_index - 300, m_high, bar_index, m_high,
             color=col_monthly_high, width=width_monthly,
             style=f_line_style(style_monthly), extend=extend.right))
        array.push(drawn_lines, line.new(bar_index - 300, m_low, bar_index, m_low,
             color=col_monthly_low, width=width_monthly,
             style=f_line_style(style_monthly), extend=extend.right))

    // ?? Sydney lines ??
    if show_sydney and not na(sy_high)
        array.push(drawn_lines, line.new(bar_index - 300, sy_high, bar_index, sy_high,
             color=col_sydney_high, width=width_sydney,
             style=f_line_style(style_sydney), extend=extend.right))
        array.push(drawn_lines, line.new(bar_index - 300, sy_low, bar_index, sy_low,
             color=col_sydney_low, width=width_sydney,
             style=f_line_style(style_sydney), extend=extend.right))

    // ?? Tokyo lines ??
    if show_tokyo and not na(to_high)
        array.push(drawn_lines, line.new(bar_index - 300, to_high, bar_index, to_high,
             color=col_tokyo_high, width=width_tokyo,
             style=f_line_style(style_tokyo), extend=extend.right))
        array.push(drawn_lines, line.new(bar_index - 300, to_low, bar_index, to_low,
             color=col_tokyo_low, width=width_tokyo,
             style=f_line_style(style_tokyo), extend=extend.right))

    // ?? London lines ??
    if show_london and not na(lo_high)
        array.push(drawn_lines, line.new(bar_index - 300, lo_high, bar_index, lo_high,
             color=col_london_high, width=width_london,
             style=f_line_style(style_london), extend=extend.right))
        array.push(drawn_lines, line.new(bar_index - 300, lo_low, bar_index, lo_low,
             color=col_london_low, width=width_london,
             style=f_line_style(style_london), extend=extend.right))

    // ?? New York lines ??
    if show_newyork and not na(ny_high)
        array.push(drawn_lines, line.new(bar_index - 300, ny_high, bar_index, ny_high,
             color=col_ny_high, width=width_newyork,
             style=f_line_style(style_newyork), extend=extend.right))
        array.push(drawn_lines, line.new(bar_index - 300, ny_low, bar_index, ny_low,
             color=col_ny_low, width=width_newyork,
             style=f_line_style(style_newyork), extend=extend.right))

    // ???????????????????????????????????????????????????????????????
    //  LABELS ? collect every enabled level, sort by price, and
    //  shift overlapping labels horizontally so they sit side-by-side
    //  instead of stacking on top of each other.
    // ???????????????????????????????????????????????????????????????
    if show_labels
        lbl_prices = array.new_float()
        lbl_texts  = array.new_string()
        lbl_colors = array.new_color()
        lbl_ishigh = array.new_bool()

        if show_daily and not na(d_high)
            array.push(lbl_prices, d_high)
            array.push(lbl_texts,  "D High\n" + str.tostring(d_high, format.mintick))
            array.push(lbl_colors, col_daily_high)
            array.push(lbl_ishigh, true)
            array.push(lbl_prices, d_low)
            array.push(lbl_texts,  "D Low\n"  + str.tostring(d_low,  format.mintick))
            array.push(lbl_colors, col_daily_low)
            array.push(lbl_ishigh, false)

        if show_weekly and not na(w_high)
            array.push(lbl_prices, w_high)
            array.push(lbl_texts,  "W High\n" + str.tostring(w_high, format.mintick))
            array.push(lbl_colors, col_weekly_high)
            array.push(lbl_ishigh, true)
            array.push(lbl_prices, w_low)
            array.push(lbl_texts,  "W Low\n"  + str.tostring(w_low,  format.mintick))
            array.push(lbl_colors, col_weekly_low)
            array.push(lbl_ishigh, false)

        if show_monthly and not na(m_high)
            array.push(lbl_prices, m_high)
            array.push(lbl_texts,  "M High\n" + str.tostring(m_high, format.mintick))
            array.push(lbl_colors, col_monthly_high)
            array.push(lbl_ishigh, true)
            array.push(lbl_prices, m_low)
            array.push(lbl_texts,  "M Low\n"  + str.tostring(m_low,  format.mintick))
            array.push(lbl_colors, col_monthly_low)
            array.push(lbl_ishigh, false)

        if show_sydney and not na(sy_high)
            array.push(lbl_prices, sy_high)
            array.push(lbl_texts,  "SYD High\n" + str.tostring(sy_high, format.mintick))
            array.push(lbl_colors, col_sydney_high)
            array.push(lbl_ishigh, true)
            array.push(lbl_prices, sy_low)
            array.push(lbl_texts,  "SYD Low\n"  + str.tostring(sy_low,  format.mintick))
            array.push(lbl_colors, col_sydney_low)
            array.push(lbl_ishigh, false)

        if show_tokyo and not na(to_high)
            array.push(lbl_prices, to_high)
            array.push(lbl_texts,  "TYO High\n" + str.tostring(to_high, format.mintick))
            array.push(lbl_colors, col_tokyo_high)
            array.push(lbl_ishigh, true)
            array.push(lbl_prices, to_low)
            array.push(lbl_texts,  "TYO Low\n"  + str.tostring(to_low,  format.mintick))
            array.push(lbl_colors, col_tokyo_low)
            array.push(lbl_ishigh, false)

        if show_london and not na(lo_high)
            array.push(lbl_prices, lo_high)
            array.push(lbl_texts,  "LON High\n" + str.tostring(lo_high, format.mintick))
            array.push(lbl_colors, col_london_high)
            array.push(lbl_ishigh, true)
            array.push(lbl_prices, lo_low)
            array.push(lbl_texts,  "LON Low\n"  + str.tostring(lo_low,  format.mintick))
            array.push(lbl_colors, col_london_low)
            array.push(lbl_ishigh, false)

        if show_newyork and not na(ny_high)
            array.push(lbl_prices, ny_high)
            array.push(lbl_texts,  "NY High\n" + str.tostring(ny_high, format.mintick))
            array.push(lbl_colors, col_ny_high)
            array.push(lbl_ishigh, true)
            array.push(lbl_prices, ny_low)
            array.push(lbl_texts,  "NY Low\n"  + str.tostring(ny_low,  format.mintick))
            array.push(lbl_colors, col_ny_low)
            array.push(lbl_ishigh, false)

        n = array.size(lbl_prices)
        if n > 0
            // Build an index array and sort it by price (ascending).
            // Insertion sort keeps things simple and is fine for small n.
            indices = array.new_int()
            for i = 0 to n - 1
                array.push(indices, i)
            if n > 1
                // NOTE: Pine's `and` does not short-circuit, so we must
                // break out explicitly instead of checking j > 0 together
                // with array.get(indices, j - 1) in a single condition.
                for i = 1 to n - 1
                    j = i
                    while j > 0
                        a = array.get(lbl_prices, array.get(indices, j - 1))
                        b = array.get(lbl_prices, array.get(indices, j))
                        if a <= b
                            break
                        tmp = array.get(indices, j)
                        array.set(indices, j,     array.get(indices, j - 1))
                        array.set(indices, j - 1, tmp)
                        j := j - 1

            // Two labels are considered "overlapping" if their prices
            // are within `overlap_factor * ATR(14)` of each other.
            tol = na(atr14) ? 0.0 : atr14 * overlap_factor

            float prev_price = na
            int   col_idx    = 0
            for k = 0 to n - 1
                idx = array.get(indices, k)
                p   = array.get(lbl_prices, idx)
                if na(prev_price) or (p - prev_price) > tol
                    col_idx := 0
                else
                    col_idx := col_idx + 1
                x    = bar_index + label_offset + col_idx * label_spacing
                c    = array.get(lbl_colors, idx)
                ishi = array.get(lbl_ishigh, idx)
                array.push(drawn_labels, label.new(x, p, text=array.get(lbl_texts, idx),
                     color=color.new(c, 80), textcolor=c,
                     style=ishi ? label.style_label_down : label.style_label_up,
                     size=size.small))
                prev_price := p

// ???????????????????????????????????????????????????????????????????
//  BACKGROUND SESSION SHADING  (optional ? subtle tint per session)
// ???????????????????????????????????????????????????????????????????
bgcolor(show_sydney  and in_sydney  ? color.new(#34D399, 97) : na, title="Sydney bg")
bgcolor(show_tokyo   and in_tokyo   ? color.new(#F472B6, 97) : na, title="Tokyo bg")
bgcolor(show_london  and in_london  ? color.new(#FB923C, 97) : na, title="London bg")
bgcolor(show_newyork and in_newyork ? color.new(#F87171, 97) : na, title="New York bg")
````
