# Watchman's 30-Min SMA Setup Vol 1

- url: https://www.tradingview.com/script/wBnBGt4M-Watchman-s-30-Min-SMA-Setup-Vol-1/
- type: indicator
- pine_id: PUB;e07d96cdf65448258a513b58f647f733
- version: 1.0

## Description

30 Minute Setup featuring the Brian Jones System 10/50/200 - SMAs on the 30 minute timeframe with pre-market OFF.

## Source Code

````pine
//@version=6
indicator(title="Watchman's 30-Min SMA Setup", overlay=true)

// ===== INPUTS =====
showDailyLevels      = input.bool(true, "Show Daily Levels")
showWeeklyLevels     = input.bool(true, "Show Weekly Levels")
showMonthlyLevels    = input.bool(true, "Show Monthly Levels")
showYearlyLevels     = input.bool(true, "Show 12-Month Levels")
showPremarketHL      = input.bool(true, "Show Pre-Market High/Low")
premarketStart       = input.int(400,   "Pre-Market Start (ET)", minval=0, maxval=2359)
premarketEnd         = input.int(930,   "Pre-Market End (ET)",   minval=0, maxval=2359)
showMonthlyEMA20     = input.bool(true, "Show Monthly EMA 20")
showWeeklyEMA50      = input.bool(true, "Show Weekly EMA 50")
showDailyEMA200      = input.bool(true, "Show Daily EMA 200")

// ===== 30-MINUTE SMAs =====
sma10_30min = request.security(syminfo.tickerid, "30", ta.sma(close, 10))
sma50_30min = request.security(syminfo.tickerid, "30", ta.sma(close, 50))
sma200_30min = request.security(syminfo.tickerid, "30", ta.sma(close, 200))

plot(sma10_30min, "SMA 10 (30-min)", color=color.new(color.blue, 0), linewidth=2)
plot(sma50_30min, "SMA 50 (30-min)", color=color.new(color.orange, 0), linewidth=2)
plot(sma200_30min, "SMA 200 (30-min)", color=color.new(color.red, 0), linewidth=2)

// ===== DAILY LEVELS (Previous Close) =====
dailyClose = request.security(syminfo.tickerid, "D", close[1])
plot(dailyClose, "Daily Pivot", color=showDailyLevels ? color.new(color.gray, 70) : na, linewidth=1, style=plot.style_circles)

// ===== WEEKLY LEVELS =====
weeklyHigh = request.security(syminfo.tickerid, "W", high[1])
weeklyLow  = request.security(syminfo.tickerid, "W", low[1])
plot(weeklyHigh, "Weekly High", color=showWeeklyLevels ? color.new(color.red, 60) : na, linewidth=1, style=plot.style_circles)
plot(weeklyLow,  "Weekly Low",  color=showWeeklyLevels ? color.new(color.green, 60) : na, linewidth=1, style=plot.style_circles)

// ===== MONTHLY LEVELS =====
monthlyHigh = request.security(syminfo.tickerid, "M", high[1])
monthlyLow  = request.security(syminfo.tickerid, "M", low[1])
plot(monthlyHigh, "Monthly High", color=showMonthlyLevels ? color.new(color.red, 50) : na, linewidth=1, style=plot.style_circles)
plot(monthlyLow,  "Monthly Low",  color=showMonthlyLevels ? color.new(color.green, 50) : na, linewidth=1, style=plot.style_circles)

// ===== YEARLY LEVELS (12-month) =====
yearlyHigh = request.security(syminfo.tickerid, "12M", high[1])
yearlyLow  = request.security(syminfo.tickerid, "12M", low[1])
plot(yearlyHigh, "12-Month High", color=showYearlyLevels ? color.new(color.red, 40) : na, linewidth=1, style=plot.style_circles)
plot(yearlyLow,  "12-Month Low",  color=showYearlyLevels ? color.new(color.green, 40) : na, linewidth=1, style=plot.style_circles)

// ===== PRE-MARKET HIGH/LOW (Using session time detection) =====
var float preMarketHigh = na
var float preMarketLow = na

// Get current hour and minute in exchange timezone
currentHour = hour(time)
currentMinute = minute(time)
currentTimeInt = currentHour * 100 + currentMinute

// Define pre-market session using the chart's exchange timezone
isPreMarket = currentTimeInt >= premarketStart and currentTimeInt < premarketEnd

// Track pre-market high/low
if isPreMarket and na(preMarketHigh)
    preMarketHigh := high
    preMarketLow := low
else if isPreMarket
    preMarketHigh := math.max(preMarketHigh, high)
    preMarketLow := math.min(preMarketLow, low)
else if not isPreMarket and not na(preMarketHigh)
    preMarketHigh := na
    preMarketLow := na

plot(showPremarketHL ? preMarketHigh : na, "Pre-Market High", color=color.new(color.blue, 0), linewidth=1, style=plot.style_stepline)
plot(showPremarketHL ? preMarketLow : na,  "Pre-Market Low",  color=color.new(color.blue, 0), linewidth=1, style=plot.style_stepline)

// ===== HIGHER TIMEFRAME EMAs =====
ema20_monthly = request.security(syminfo.tickerid, "M", ta.ema(close, 20))
ema50_weekly  = request.security(syminfo.tickerid, "W", ta.ema(close, 50))
ema200_daily  = request.security(syminfo.tickerid, "D", ta.ema(close, 200))

plot(showMonthlyEMA20 ? ema20_monthly : na, "EMA 20 (Monthly)", color=color.new(color.purple, 0), linewidth=2)
plot(showWeeklyEMA50  ? ema50_weekly  : na, "EMA 50 (Weekly)",  color=color.new(color.teal, 0),   linewidth=2)
plot(showDailyEMA200  ? ema200_daily  : na, "EMA 200 (Daily)",  color=color.new(color.yellow, 0), linewidth=2)
````
