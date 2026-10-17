# ORNY

- url: https://www.tradingview.com/script/PnQujLHH-orny/
- type: indicator
- pine_id: PUB;9af5392bdda44b3f8a3173071d8030b8
- version: 1.0

## Description

Highlights the first 5-minute candle range after NYSE/NASDAQ open (9:30–9:35 ET) on the 1-minute chart. Works on 1m timeframe only. UTC offset is adjustable in settings.

## Source Code

````pine
//@version=6
indicator("ORNY", overlay=true)

// ─── Settings ────────────────────────────────────────────────────────────────
utcOffset  = input.int(0, "UTC Offset (hours)", minval=-12, maxval=14)
rangeColor = input.color(color.new(#97a8d5, 70), "Range Color")

// ─── Helpers ─────────────────────────────────────────────────────────────────
// NYSE/NASDAQ открытие: 9:30 ET = 13:30 UTC
// Первая 5-минутная свеча: 9:30–9:35 ET = 13:30–13:35 UTC

offsetSec   = utcOffset * 3600
openUTC     = 13 * 3600 + 30 * 60   // 13:30 UTC
closeUTC    = 13 * 3600 + 35 * 60   // 13:35 UTC

timeInDay(t) =>
    // секунды с начала дня в UTC
    unix = math.floor(t / 1000)
    unix - math.floor(unix / 86400) * 86400

t = timeInDay(time)

isOpenBar  = timeframe.in_seconds() == 60 and t >= openUTC  and t <  openUTC + 60
isCloseBar = timeframe.in_seconds() == 60 and t >= closeUTC - 60 and t < closeUTC

// ─── State ───────────────────────────────────────────────────────────────────
var float rangeHigh  = na
var float rangeLow   = na
var int   openBarIdx = na
var box   rangeBox   = na

// Сбрасываем каждый день
isNewDay = dayofweek(time, "UTC") != dayofweek(time[1], "UTC")
if isNewDay
    rangeHigh  := na
    rangeLow   := na
    openBarIdx := na

// Накапливаем high/low за 5 минут (9:30–9:35)
if t >= openUTC and t < closeUTC
    rangeHigh  := na(rangeHigh)  ? high : math.max(rangeHigh, high)
    rangeLow   := na(rangeLow)   ? low  : math.min(rangeLow,  low)
    if na(openBarIdx)
        openBarIdx := bar_index

// После закрытия 5й минуты — рисуем box
if isCloseBar
    if not na(rangeHigh) and not na(rangeLow)
        rangeBox := box.new(
          left         = openBarIdx,
          top          = rangeHigh,
          right        = bar_index,
          bottom       = rangeLow,
          border_color = color.new(#97a8d5, 0),
          border_width = 1,
          bgcolor      = rangeColor
        )
````
