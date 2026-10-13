<!-- tradingview-pine-id: PUB;caf119fe7098431aabb183dc15e64a0d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Luxembourg Trading Hours

Source: https://www.tradingview.com/script/zCJVpgKl/

## Description

Mangoe LSD Trading Hours

Highlights the optimal trading window that captures the strongest volume from the London-New York session overlap. Based on Mangoe's Liquidity Supply and Demand trading methodology, who trades 8:00 AM - 3:00 PM UK time.

This indicator automatically adapts to your timezone, displaying Mangoe's trading hours regardless of your location. Trade your setups within defined hours for better discipline and consistency.

---

## Source Code

````pine
//@version=6
indicator("Luxembourg Trading Hours", overlay=true)

string timezone = "Europe/Luxembourg"

startHour   = input.int(9, "Start Hour", minval=0, maxval=23)
startMinute = input.int(0, "Start Minute", minval=0, maxval=59)

endHour     = input.int(16, "End Hour", minval=0, maxval=23)
endMinute   = input.int(0, "End Minute", minval=0, maxval=59)

showWeekends = input.bool(false, "Include Weekends")

zoneColor   = input.color(color.blue, "Zone Color")
zoneOpacity = input.int(15, "Zone Opacity (%)", minval=0, maxval=100)

// LUXEMBOURG TIME
luxHour   = hour(time, timezone)
luxMinute = minute(time, timezone)
luxDay    = dayofweek(time, timezone)

currentMinutes = luxHour * 60 + luxMinute
startMinutes   = startHour * 60 + startMinute
endMinutes     = endHour * 60 + endMinute

isWeekday = luxDay >= dayofweek.monday and luxDay <= dayofweek.friday

// TRADING HOURS CHECK
isTradingHours = currentMinutes >= startMinutes and currentMinutes < endMinutes and (showWeekends or isWeekday)

sessionBackground = isTradingHours ? color.new(zoneColor, 100 - zoneOpacity) : na

bgcolor(sessionBackground, title="Trading Hours")
````
