# Macro TWAP

- url: https://www.tradingview.com/script/l47C4lHO-Macro-TWAP/
- type: indicator
- pine_id: PUB;9bfc5e0a0fc948cdac7d48ed3b6bea46
- version: 1.0

## Description

Macro TWAP shows multiple time-weighted average price levels across long-term and short-term periods, including 30Y, 20Y, 10Y, 5Y, yearly, quarterly, monthly, weekly, and daily TWAP. Useful for identifying macro mean levels, higher-timeframe structure, and dynamic support/resistance.

## Source Code

````pine
//@version=5
indicator("Macro TWAP", shorttitle="MTWAP", overlay=true)

//=========================
// Inputs
//=========================
src         = input.source(hlc3, "TWAP Source")
show30Y     = input.bool(true,  "Show 30-Year TWAP")
show20Y     = input.bool(true,  "Show 20-Year TWAP")
show10Y     = input.bool(true,  "Show 10-Year TWAP")
show5Y      = input.bool(true,  "Show 5-Year TWAP")
showYear    = input.bool(true,  "Show Yearly TWAP")
showQuarter = input.bool(true,  "Show 3-Month TWAP")
showMonth   = input.bool(true,  "Show Monthly TWAP")
showWeek    = input.bool(true,  "Show Weekly TWAP")
showDay     = input.bool(true,  "Show Daily TWAP")

//=========================
// Period detection
//=========================
curYear      = year(time)

thirtyBucket = math.floor((curYear - 1970) / 30)
twentyBucket = math.floor((curYear - 1970) / 20)
tenBucket    = math.floor((curYear - 1970) / 10)
fiveBucket   = math.floor((curYear - 1970) / 5)

new30Y       = ta.change(thirtyBucket) != 0
new20Y       = ta.change(twentyBucket) != 0
new10Y       = ta.change(tenBucket) != 0
new5Y        = ta.change(fiveBucket) != 0
newYear      = ta.change(time("12M")) != 0
newQuarter   = ta.change(time("3M"))  != 0
newMonth     = ta.change(time("1M"))  != 0
newWeek      = ta.change(time("1W"))  != 0
newDay       = ta.change(time("1D"))  != 0

//=========================
// 30-Year TWAP
//=========================
var float thirtySum   = na
var float thirtyCount = na
thirtyReset  = barstate.isfirst or new30Y
thirtySum   := thirtyReset ? src : nz(thirtySum[1]) + src
thirtyCount := thirtyReset ? 1.0 : nz(thirtyCount[1]) + 1.0
thirtyTwap   = thirtySum / thirtyCount

//=========================
// 20-Year TWAP
//=========================
var float twentySum   = na
var float twentyCount = na
twentyReset  = barstate.isfirst or new20Y
twentySum   := twentyReset ? src : nz(twentySum[1]) + src
twentyCount := twentyReset ? 1.0 : nz(twentyCount[1]) + 1.0
twentyTwap   = twentySum / twentyCount

//=========================
// 10-Year TWAP
//=========================
var float tenSum   = na
var float tenCount = na
tenReset  = barstate.isfirst or new10Y
tenSum   := tenReset ? src : nz(tenSum[1]) + src
tenCount := tenReset ? 1.0 : nz(tenCount[1]) + 1.0
tenTwap   = tenSum / tenCount

//=========================
// 5-Year TWAP
//=========================
var float fiveSum   = na
var float fiveCount = na
fiveReset  = barstate.isfirst or new5Y
fiveSum   := fiveReset ? src : nz(fiveSum[1]) + src
fiveCount := fiveReset ? 1.0 : nz(fiveCount[1]) + 1.0
fiveTwap   = fiveSum / fiveCount

//=========================
// Yearly TWAP
//=========================
var float yearSum   = na
var float yearCount = na
yearReset  = barstate.isfirst or newYear
yearSum   := yearReset ? src : nz(yearSum[1]) + src
yearCount := yearReset ? 1.0 : nz(yearCount[1]) + 1.0
yearTwap   = yearSum / yearCount

//=========================
// 3-Month TWAP
//=========================
var float quarterSum   = na
var float quarterCount = na
quarterReset  = barstate.isfirst or newQuarter
quarterSum   := quarterReset ? src : nz(quarterSum[1]) + src
quarterCount := quarterReset ? 1.0 : nz(quarterCount[1]) + 1.0
quarterTwap   = quarterSum / quarterCount

//=========================
// Monthly TWAP
//=========================
var float monthSum   = na
var float monthCount = na
monthReset  = barstate.isfirst or newMonth
monthSum   := monthReset ? src : nz(monthSum[1]) + src
monthCount := monthReset ? 1.0 : nz(monthCount[1]) + 1.0
monthTwap   = monthSum / monthCount

//=========================
// Weekly TWAP
//=========================
var float weekSum   = na
var float weekCount = na
weekReset  = barstate.isfirst or newWeek
weekSum   := weekReset ? src : nz(weekSum[1]) + src
weekCount := weekReset ? 1.0 : nz(weekCount[1]) + 1.0
weekTwap   = weekSum / weekCount

//=========================
// Daily TWAP
//=========================
var float daySum   = na
var float dayCount = na
dayReset  = barstate.isfirst or newDay
daySum   := dayReset ? src : nz(daySum[1]) + src
dayCount := dayReset ? 1.0 : nz(dayCount[1]) + 1.0
dayTwap   = daySum / dayCount

//=========================
// Plots
//=========================
plot(show30Y     ? thirtyTwap  : na, title="30-Year TWAP", color=color.new(color.red, 0),      linewidth=5)
plot(show20Y     ? twentyTwap  : na, title="20-Year TWAP", color=color.new(color.orange, 0),   linewidth=4)
plot(show10Y     ? tenTwap     : na, title="10-Year TWAP", color=color.new(color.yellow, 0),   linewidth=4)
plot(show5Y      ? fiveTwap    : na, title="5-Year TWAP",  color=color.new(color.fuchsia, 0),  linewidth=3)
plot(showYear    ? yearTwap    : na, title="Yearly TWAP",  color=color.new(color.aqua, 0),     linewidth=3)
plot(showQuarter ? quarterTwap : na, title="3-Month TWAP", color=color.new(color.blue, 0),     linewidth=2)
plot(showMonth   ? monthTwap   : na, title="Monthly TWAP", color=color.new(color.purple, 0),   linewidth=2)
plot(showWeek    ? weekTwap    : na, title="Weekly TWAP",  color=color.new(color.green, 0),    linewidth=2)
plot(showDay     ? dayTwap     : na, title="Daily TWAP",   color=color.new(color.white, 0),    linewidth=1)
````
