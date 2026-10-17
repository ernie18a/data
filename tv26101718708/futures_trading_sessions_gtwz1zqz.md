# Futures Trading Sessions 

- url: https://www.tradingview.com/script/gTwz1zQz-Futures-Trading-Sessions/
- type: indicator
- pine_id: PUB;c704868b306b47a8bd8dac5369147b0f
- version: 1.0

## Description

Futures trading session windows with numerous colors and labels to easily differentiate trading session.

## Source Code

````pine
//@version=5
indicator("Trading Sessions — Futures", overlay=true, max_labels_count=500)

// ─── Session Toggles ──────────────────────────────────────────────────────────
show_globex    = input.bool(true,  "CME Globex Evening  (5:00 PM – 8:00 PM ET)",  group="Sessions")
show_asia      = input.bool(true,  "Asian Session       (8:00 PM – 3:00 AM ET)",  group="Sessions")
show_london    = input.bool(true,  "London Session      (3:00 AM – 9:30 AM ET)",  group="Sessions")
show_premarket = input.bool(true,  "NY Pre-Market       (8:30 AM – 9:30 AM ET)",  group="Sessions")
show_rth       = input.bool(true,  "NY RTH              (9:30 AM – 4:00 PM ET)",  group="Sessions")
show_overlap   = input.bool(true,  "London/NY Overlap   (9:30 AM – 11:30 AM ET)", group="Sessions")
show_labels    = input.bool(true,  "Show Session Open/Close Labels",              group="Display")
show_close_lbl = input.bool(true,  "Show RTH Close Label",                        group="Display")

// ─── Colors ───────────────────────────────────────────────────────────────────
globex_col    = input.color(color.new(color.gray,   90), "Globex Evening",    group="Colors")
asia_col      = input.color(color.new(color.yellow, 88), "Asian",             group="Colors")
london_col    = input.color(color.new(color.blue,   88), "London",            group="Colors")
premarket_col = input.color(color.new(color.orange, 85), "NY Pre-Market",     group="Colors")
rth_col       = input.color(color.new(color.green,  88), "NY RTH",            group="Colors")
overlap_col   = input.color(color.new(color.purple, 82), "London/NY Overlap", group="Colors")

// ─── Session Time Logic (ET) ──────────────────────────────────────────────────
tz = "America/New_York"
hm = hour(time, tz) * 60 + minute(time, tz)

in_globex    = hm >= 17 * 60      and hm < 20 * 60
in_asia      = hm >= 20 * 60      or  hm < 3  * 60
in_london    = hm >= 3  * 60      and hm < 9  * 60 + 30
in_premarket = hm >= 8  * 60 + 30 and hm < 9  * 60 + 30
in_rth       = hm >= 9  * 60 + 30 and hm < 16 * 60
in_overlap   = hm >= 9  * 60 + 30 and hm < 11 * 60 + 30

// ─── Background Shading ───────────────────────────────────────────────────────
bgcolor(show_globex    and in_globex    ? globex_col    : na, title="Globex Evening")
bgcolor(show_asia      and in_asia      ? asia_col      : na, title="Asian")
bgcolor(show_london    and in_london    ? london_col    : na, title="London")
bgcolor(show_premarket and in_premarket ? premarket_col : na, title="NY Pre-Market")
bgcolor(show_rth       and in_rth       ? rth_col       : na, title="NY RTH")
bgcolor(show_overlap   and in_overlap   ? overlap_col   : na, title="London/NY Overlap")

// ─── Session Open / Close Labels ─────────────────────────────────────────────
if show_labels
    if show_globex and in_globex and not in_globex[1]
        label.new(bar_index, high, "GLOBEX OPEN  5:00 PM",
                  style=label.style_label_down, color=color.new(color.gray, 20),
                  textcolor=color.white, size=size.small)

    if show_asia and in_asia and not in_asia[1]
        label.new(bar_index, high, "ASIA OPEN  8:00 PM",
                  style=label.style_label_down, color=color.new(color.yellow, 10),
                  textcolor=color.black, size=size.small)

    if show_london and in_london and not in_london[1]
        label.new(bar_index, high, "LONDON OPEN  3:00 AM",
                  style=label.style_label_down, color=color.new(color.blue, 10),
                  textcolor=color.white, size=size.small)

    if show_premarket and in_premarket and not in_premarket[1]
        label.new(bar_index, high, "NY PRE-MARKET  8:30 AM",
                  style=label.style_label_down, color=color.new(color.orange, 10),
                  textcolor=color.white, size=size.small)

    if show_rth and in_rth and not in_rth[1]
        label.new(bar_index, high, "NY RTH OPEN  9:30 AM",
                  style=label.style_label_down, color=color.new(color.green, 10),
                  textcolor=color.white, size=size.normal)

    if show_overlap and in_overlap and not in_overlap[1]
        label.new(bar_index, high, "LONDON / NY OVERLAP",
                  style=label.style_label_down, color=color.new(color.purple, 10),
                  textcolor=color.white, size=size.small)

if show_close_lbl and not in_rth and in_rth[1]
    label.new(bar_index, low, "NY RTH CLOSE  4:00 PM",
              style=label.style_label_up, color=color.new(color.red, 10),
              textcolor=color.white, size=size.small)
````
