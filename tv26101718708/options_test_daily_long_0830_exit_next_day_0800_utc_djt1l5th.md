# Options test Daily Long 08:30 Exit next day 08:00 UTC

- url: https://www.tradingview.com/script/DJT1l5tH-Options-test-Daily-Long-08-30-Exit-next-day-08-00-UTC/
- type: strategy
- pine_id: PUB;1c23b1c517cd4ea19ca1cf4db9c15b07
- version: 1.0

## Description

This strategy allows to "backtest" 0DTE option straddles. It "buys" right after the expiration time and sells next day on expiration. Once you run the script, you can download the excel file with the results of each trade that will give you the followng information:
- potential move at expiry
- largest drawups and drawdowns

With this information you can manually backtest your options strategy on diffrent assets.

## Source Code

````pine
//@version=5
strategy("Options test Daily Long 08:30 → Exit 08:00", overlay=true, margin_long=100, margin_short=100)

// Get current time in UTC
currentHour   = hour(time, "UTC")
currentMinute = minute(time, "UTC")

// Entry condition: exactly 08:30 UTC
enterLong = (currentHour == 8 and currentMinute == 30)

// Exit condition: exactly 08:00 UTC
exitLong = (currentHour == 8 and currentMinute == 0)

// Submit orders
if (enterLong)
    strategy.entry("Long", strategy.long)

if (exitLong)
    strategy.close("Long")
````
