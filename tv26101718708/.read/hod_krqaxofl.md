# HOD%

- url: https://www.tradingview.com/script/KRqaxOFL-HOD/
- type: indicator
- pine_id: PUB;23c41b249b6a4592867c42810e0bdfe5
- version: 1.0

## Description

HOD% shows how far the current price is from the current intraday High of Day.

The value is calculated as:

HOD% = ((High of Day - Current Price) / Current Price) * 100

How to read it:
0.00 = price is exactly at High of Day
1.00 = price is about 1% below High of Day
3.00 = price is about 3% below High of Day

This indicator is useful for momentum traders who want to find stocks trading close to their High of Day. Lower values usually mean stronger intraday momentum.

Suggested usage:
HOD% <= 1 = very strong, near High of Day
HOD% <= 3 = still close to High of Day
HOD% > 5 = farther from High of Day

The script can be used in TradingView Pine Screener as a custom column for scanning watchlists.

## Source Code

````pine
//@version=5
indicator("HOD%", overlay=true)

// New trading day
isNewDay = ta.change(time("D"))

// Count bars from day start
var int barsSinceOpen = 1
barsSinceOpen := isNewDay ? 1 : barsSinceOpen + 1

// High of day
hod = ta.highest(high, barsSinceOpen)

// Distance from HOD %
hodPercent = ((hod - close) / close) * 100

// Show value in legend/status line only
plot(hodPercent, title="HOD%", display=display.status_line)
````
