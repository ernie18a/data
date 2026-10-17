# market sessions jjr

- url: https://www.tradingview.com/script/UtVDv6Q0-market-sessions-jjr/
- type: indicator
- pine_id: PUB;a7ab4fc70a714b1fa67793ad43a4cb03
- version: 1.0

## Description

market sessions for my refrence showing asia london and new york

## Source Code

````pine
//@version=6
indicator("market sessions jjr", overlay=true, max_labels_count=50)

// ── Inputs ───────────────────────────────────────────────────────────────────
show_asian  = input.bool(true, "Show Asian Session")
show_london = input.bool(true, "Show London Session")
show_ny     = input.bool(true, "Show New York Session")
show_labels = input.bool(true, "Show Session Labels")

asian_col   = input.color(color.new(#00BCD4, 88), "Asian Color")
london_col  = input.color(color.new(#E91E63, 88), "London Color")
ny_col      = input.color(color.new(#4CAF50, 88), "New York Color")

tz = "America/New_York"

// ── Session windows (ET times) ───────────────────────────────────────────────
// Asian:   8:00 PM – 4:00 AM ET (2000-0400)
// London:  3:00 AM – 9:30 AM ET (0300-0930)
// NY:      9:30 AM – 4:00 PM ET (0930-1600)

in_asian  = not na(time(timeframe.period, "2000-0400", tz))
in_london = not na(time(timeframe.period, "0300-0930", tz))
in_ny     = not na(time(timeframe.period, "0930-1600", tz))

// ── Background shading ───────────────────────────────────────────────────────
bgcolor(show_asian  and in_asian  ? asian_col  : na, title="Asian Session")
bgcolor(show_london and in_london ? london_col : na, title="London Session")
bgcolor(show_ny     and in_ny     ? ny_col     : na, title="New York Session")

// ── Session labels at the open of each session ───────────────────────────────
asian_start  = in_asian  and not in_asian[1]
london_start = in_london and not in_london[1]
ny_start     = in_ny     and not in_ny[1]

if show_labels and asian_start
    label.new(bar_index, high, "Asia", 
      style=label.style_label_down, 
      color=color.new(#00BCD4, 60), 
      textcolor=color.white, 
      size=size.small)

if show_labels and london_start
    label.new(bar_index, high, "London", 
      style=label.style_label_down, 
      color=color.new(#E91E63, 60), 
      textcolor=color.white, 
      size=size.small)

if show_labels and ny_start
    label.new(bar_index, high, "New York", 
      style=label.style_label_down, 
      color=color.new(#4CAF50, 60), 
      textcolor=color.white, 
      size=size.small)
````
