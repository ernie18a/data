# Crypto Global Session Highlights (US/Asia)

- url: https://www.tradingview.com/script/rkiapIzl-Crypto-Global-Session-Highlights-US-Asia/
- type: indicator
- pine_id: PUB;2e35420c5115495d9838c915112a3a90
- version: 1.0

## Description

US (blue) & Asia (yellow) Sessions highlights + weekends (white)

## Source Code

````pine
//@version=6
indicator('Session Highlights', overlay = true)

// Monday–Friday 08:00–09:30 EST – Teal (Pre-market)
in_morning = not na(time(timeframe.period, '0800-0930:23456', 'America/New_York'))

// Monday–Friday 09:30–16:00 EST – Blue (Regular session)
in_regular = not na(time(timeframe.period, '0930-1600:23456', 'America/New_York'))

// Sunday–Wednesday 20:00–21:30 EST – Yellow (Evening prep)
in_evening_yellow = not na(time(timeframe.period, '2000-2130:1245', 'America/New_York'))

// Orange: Sunday 20:00–Monday 04:00 ... through Thursday 20:00–Friday 04:00
in_night_orange_sun = not na(time(timeframe.period, '2000-0400:2', 'America/New_York'))
in_night_orange_mon = not na(time(timeframe.period, '2000-0400:3', 'America/New_York'))
in_night_orange_tue = not na(time(timeframe.period, '2000-0400:4', 'America/New_York'))
in_night_orange_wed = not na(time(timeframe.period, '2000-0400:5', 'America/New_York'))
in_night_orange_thu = not na(time(timeframe.period, '2000-0400:6', 'America/New_York'))

in_night_orange = in_night_orange_sun or in_night_orange_mon or in_night_orange_tue or in_night_orange_wed or in_night_orange_thu

// Weekend: Friday 16:00–Sunday 18:00 EST – White
in_weekend_fri = not na(time(timeframe.period, '1600-2359:6', 'America/New_York'))
in_weekend_sat = not na(time(timeframe.period, '0000-2359:7', 'America/New_York'))
in_weekend_sun = not na(time(timeframe.period, '0000-1800:1', 'America/New_York'))
in_weekend = in_weekend_fri or in_weekend_sat or in_weekend_sun

// Background colors at 10% opacity
bgcolor(in_morning ? color.new(color.aqua, 90) : na)
bgcolor(in_regular ? color.new(color.blue, 90) : na)
bgcolor(in_evening_yellow ? color.new(color.orange, 90) : na)
bgcolor(in_night_orange ? color.new(color.yellow, 90) : na)
bgcolor(in_weekend ? color.new(color.white, 90) : na)
````
