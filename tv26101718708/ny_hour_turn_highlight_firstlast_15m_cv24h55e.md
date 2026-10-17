# NY Hour Turn Highlight (First/Last 15m)

- url: https://www.tradingview.com/script/CV24h55e-NY-Hour-Turn-Highlight-First-Last-15m/
- type: indicator
- pine_id: PUB;cc4c06372ec34b0487b5448964b2a9d1
- version: 1.0

## Description

Last 15 min/First 15 min of the hour Ny Session
Last 15 min/First 15 min of the hour Ny Session

## Source Code

````pine
//@version=5
indicator("NY Hour Turn Highlight (First/Last 15m)", overlay=true)

// --- Inputs ---
nySession   = input.session("0800-1700", "NY Session (Exchange TZ)") // RTH default
useNYTZ     = input.bool(true, "Use New York timezone (America/New_York)?")

// If you prefer exchange time, turn off useNYTZ.
tz = useNYTZ ? "America/New_York" : syminfo.timezone

// --- Session filter ---
inNY = not na(time(timeframe.period, nySession, tz))

// --- Minute-in-hour logic ---
m = minute(time, tz)
isFirst15 = m >= 0 and m < 15
isLast15  = m >= 45 and m < 60

// --- Highlight background ---
show = inNY and (isFirst15 or isLast15)
bgcolor(show ? color.new(color.yellow, 85) : na)

// Optional: label which zone you're in
showLabels = input.bool(false, "Show labels?")
if showLabels and barstate.islast
    label.new(bar_index, high, "NY: " + (isFirst15 ? "First 15" : isLast15 ? "Last 15" : ""),
      style=label.style_label_down, textcolor=color.black, color=color.new(color.yellow, 0))
````
