# Week Days

- url: https://www.tradingview.com/script/7hZpKZt2-week-days/
- type: indicator
- pine_id: PUB;541d8670076b4b84af3473adca6c14fa
- version: 1.0

## Description

Draws dashed vertical lines at each weekday boundary and a bold solid line every Monday to visually separate trading weeks. UTC offset is adjustable in settings.

## Source Code

````pine
//@version=6
indicator("Week Days", overlay=true)

// ─── Settings ────────────────────────────────────────────────────────────────
utcOffset = input.int(0, "UTC Offset (hours)", minval=-12, maxval=14)

// ─── Helpers ─────────────────────────────────────────────────────────────────
adjustedTime = time + utcOffset * 3600 * 1000

dayOfWeekLocal(t) =>
    dayofweek(t, "UTC")

isNewDay() =>
    dayOfWeekLocal(adjustedTime) != dayOfWeekLocal(adjustedTime[1])

isWeekday() =>
    d = dayOfWeekLocal(adjustedTime)
    d >= 2 and d <= 6

isMonday() =>
    dayOfWeekLocal(adjustedTime) == 2

// ─── Draw vertical lines ─────────────────────────────────────────────────────
if isNewDay() and isWeekday()
    isM = isMonday()
    line.new(
      x1     = bar_index,
      y1     = high,
      x2     = bar_index,
      y2     = low,
      extend = extend.both,
      color  = isM ? color.new(#97a8d5, 0) : color.new(#97a8d5, 40),
      style  = isM ? line.style_solid : line.style_dashed,
      width  = isM ? 2 : 1
    )
````
