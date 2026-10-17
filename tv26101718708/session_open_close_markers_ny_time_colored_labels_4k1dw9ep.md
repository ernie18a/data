# Session Open Close Markers (NY Time - Colored Labels)

- url: https://www.tradingview.com/script/4K1dw9Ep-Session-Open-Close-Markers-NY-Time-Colored-Labels/
- type: indicator
- pine_id: PUB;d1879e8a4c8f44d3986aabe8f3ad50e1
- version: 1.0

## Description

Session open closes EST. London session closes at 8:30 because NY pre market opens

## Source Code

````pine
//@version=6
indicator("Session Open Close Markers (NY Time - Colored Labels)", overlay=true)

tz = "America/New_York"

// === Session Times (NY Time) ===

// Asia
asiaOpen  = hour(time, tz) == 18 and minute(time, tz) == 0
asiaClose = hour(time, tz) == 3 and minute(time, tz) == 0

// London
londonOpen  = hour(time, tz) == 3 and minute(time, tz) == 0
londonClose = hour(time, tz) == 8 and minute(time, tz) == 30

// New York
nyOpen  = hour(time, tz) == 9 and minute(time, tz) == 30
nyClose = hour(time, tz) == 17 and minute(time, tz) == 0

// === Asia ===
if asiaOpen
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.red, width=2)
    label.new(bar_index, high, "Asia Open", style=label.style_label_down, color=color.red, textcolor=color.white)

if asiaClose
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.red, width=2)
    label.new(bar_index, high, "Asia Close", style=label.style_label_down, color=color.red, textcolor=color.white)

// === London ===
if londonOpen
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.blue, width=2)
    label.new(bar_index, high, "London Open", style=label.style_label_down, color=color.blue, textcolor=color.white)

if londonClose
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.blue, width=2)
    label.new(bar_index, high, "London Close", style=label.style_label_down, color=color.blue, textcolor=color.white)

// === New York ===
if nyOpen
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.black, width=2)
    label.new(bar_index, high, "New York Open", style=label.style_label_down, color=color.black, textcolor=color.white)

if nyClose
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.black, width=2)
    label.new(bar_index, high, "New York Close", style=label.style_label_down, color=color.black, textcolor=color.white)
````
