# Days of the Week - NY Time (8PM EST Day Start)

- url: https://www.tradingview.com/script/WzFXtrVB-Days-of-the-Week-NY-Time-8PM-EST-Day-Start/
- type: indicator
- pine_id: PUB;425d67e8b0914eb8bafcb7ff5a1a58cb
- version: 1.0

## Description

This indicator color-codes every trading day directly on your chart, with each "day" beginning at 8:00 PM New York time - the true start of the crypto daily session when Asia opens and fresh weekly/daily liquidity comes in. Instead of using the standard midnight rollover, this aligns your chart with how crypto actually trades.

Features:

- Each day of the week gets its own background color (all 7 colors fully customizable)
- Day name labels print at the start of each session
- Dashed vertical separator lines mark each 8PM rollover
- Uses the America/New York timezone, so EST/EDT daylight savings is handled automatically
- Toggle labels and separators on/off independently
- Adjustable background transparency

Why 8PM ET?

In crypto, the daily candle that matters opens at 8PM New York time - Sunday 8PM kicks off the Monday session. Anchoring your day boundaries here makes it much easier to spot day-of-week tendencies: weekend compression, early-week momentum, and mid-week reversals all become visually obvious at a glance.

Works on any intraday timeframe. Best viewed on 15m-4H charts.

## Source Code

````pine
//@version=6
indicator("Days of the Week — NY Time (8PM EST Day Start)", overlay=true, max_labels_count=500, max_lines_count=500)

// ── Inputs ────────────────────────────────────────────────
transp     = input.int(85, "Background Transparency", minval=0, maxval=100)
showLabels = input.bool(true, "Show Day Name Labels")
showSep    = input.bool(true, "Show Day Separator Lines")

colMon = input.color(color.new(color.blue,    0), "Monday")
colTue = input.color(color.new(color.green,   0), "Tuesday")
colWed = input.color(color.new(color.yellow,  0), "Wednesday")
colThu = input.color(color.new(color.orange,  0), "Thursday")
colFri = input.color(color.new(color.red,     0), "Friday")
colSat = input.color(color.new(color.purple,  0), "Saturday")
colSun = input.color(color.new(color.aqua,    0), "Sunday")

// ── Day logic: shift time +4h so 8PM ET = start of the next day ──
shiftMs = 4 * 60 * 60 * 1000
dowNow  = dayofweek(time + shiftMs, "America/New_York")
dowPrev = dayofweek(nz(time[1], time) + shiftMs, "America/New_York")
newDay  = barstate.isfirst or dowNow != dowPrev

// ── Day name + color ──────────────────────────────────────
dayName = switch dowNow
    dayofweek.monday    => "Monday"
    dayofweek.tuesday   => "Tuesday"
    dayofweek.wednesday => "Wednesday"
    dayofweek.thursday  => "Thursday"
    dayofweek.friday    => "Friday"
    dayofweek.saturday  => "Saturday"
    => "Sunday"

dayColor = switch dowNow
    dayofweek.monday    => colMon
    dayofweek.tuesday   => colTue
    dayofweek.wednesday => colWed
    dayofweek.thursday  => colThu
    dayofweek.friday    => colFri
    dayofweek.saturday  => colSat
    => colSun

// ── Drawing ───────────────────────────────────────────────
bgcolor(color.new(dayColor, transp))

if newDay and showSep
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(dayColor, 40), style=line.style_dashed, width=1)

if newDay and showLabels
    label.new(bar_index, high, dayName, xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.new(dayColor, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
````
