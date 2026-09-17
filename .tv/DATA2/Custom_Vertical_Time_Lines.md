<!-- tradingview-pine-id: PUB;230402878fe545b79fa732e2552c29cf -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# Custom Vertical Time Lines

Source: https://www.tradingview.com/script/CmOxKxWR-Time-Cycle-Vertical-Line/

## Description

Custom Vertical Time Lines — Description

A flexible TradingView indicator designed to mark important time-based levels and cycles with clean vertical lines.

Features:
Quarter Lines — marks quarterly boundaries one calendar day behind:
January 1
March 31
June 30
September 30

Monthly Lines — marks the first day of every month, with an option to shift one candle back on the Daily timeframe.
Sunday 6 PM Lines — marks every Sunday at 6 PM New York time; on 4H charts, the line is placed 2 candles behind.
Daily 6 PM Lines — marks every day at 6 PM New York time; on 4H charts, the line is placed 1 candle behind.
Independent ON/OFF controls for each line type.
Custom line color and width for every category.

Timezone selection, with New York (America/New_York) as the default.
Designed to work cleanly on XAUUSD and other TradingView instruments.
Uses vertical-only lines to avoid unwanted horizontal line artifacts.

Purpose:
The indicator helps traders visually divide the chart into important quarterly, monthly, weekly and daily time cycles, making it easier to study price behavior around recurring time-based events.

---

## Source Code

````pine
//@version=6
indicator("Custom Vertical Time Lines", overlay=true, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GENERAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string tz = input.string(
     "America/New_York",
     "Timezone",
     group="General"
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. QUARTER LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showQuarter = input.bool(
     true,
     "Show Quarter Lines",
     group="1. Quarter Lines"
     )

quarterColor = input.color(
     color.blue,
     "Color",
     group="1. Quarter Lines"
     )

quarterWidth = input.int(
     1,
     "Width",
     minval=1,
     maxval=5,
     group="1. Quarter Lines"
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. MONTHLY LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showMonthly = input.bool(
     false,
     "Show Monthly Lines",
     group="2. Monthly Lines"
     )

monthlyColor = input.color(
     color.gray,
     "Color",
     group="2. Monthly Lines"
     )

monthlyWidth = input.int(
     1,
     "Width",
     minval=1,
     maxval=5,
     group="2. Monthly Lines"
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. SUNDAY 6 PM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showSunday = input.bool(
     false,
     "Show Sunday 6 PM Lines",
     group="3. Sunday 6 PM"
     )

sundayColor = input.color(
     color.red,
     "Color",
     group="3. Sunday 6 PM"
     )

sundayWidth = input.int(
     1,
     "Width",
     minval=1,
     maxval=5,
     group="3. Sunday 6 PM"
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. DAILY 6 PM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showDaily6PM = input.bool(
     false,
     "Show Daily 6 PM Lines",
     group="4. Daily 6 PM"
     )

dailyColor = input.color(
     color.orange,
     "Color",
     group="4. Daily 6 PM"
     )

dailyWidth = input.int(
     1,
     "Width",
     minval=1,
     maxval=5,
     group="4. Daily 6 PM"
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT NEW YORK DATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int y = year(time, tz)
int m = month(time, tz)
int d = dayofmonth(time, tz)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME CHECKS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool isDaily = timeframe.isdaily
bool is4Hour = timeframe.isminutes and timeframe.multiplier == 240

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. QUARTER LINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Quarter reference dates
// Q1 = January 2
// Q2 = April 1
// Q3 = July 1
// Q4 = October 1

int q1 = timestamp(tz, y, 1, 2, 0, 0)
int q2 = timestamp(tz, y, 4, 1, 0, 0)
int q3 = timestamp(tz, y, 7, 1, 0, 0)
int q4 = timestamp(tz, y, 10, 1, 0, 0)

// Detect quarter
bool q1Trigger = time >= q1 and time[1] < q1
bool q2Trigger = time >= q2 and time[1] < q2
bool q3Trigger = time >= q3 and time[1] < q3
bool q4Trigger = time >= q4 and time[1] < q4

// One calendar day behind
int q1Line = timestamp(tz, y, 1, 1, 0, 0)
int q2Line = timestamp(tz, y, 3, 31, 0, 0)
int q3Line = timestamp(tz, y, 6, 30, 0, 0)
int q4Line = timestamp(tz, y, 9, 30, 0, 0)

if showQuarter

    if q1Trigger
        line.new(
             q1Line, -1000000,
             q1Line, 1000000,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=quarterColor,
             width=quarterWidth
             )

    if q2Trigger
        line.new(
             q2Line, -1000000,
             q2Line, 1000000,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=quarterColor,
             width=quarterWidth
             )

    if q3Trigger
        line.new(
             q3Line, -1000000,
             q3Line, 1000000,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=quarterColor,
             width=quarterWidth
             )

    if q4Trigger
        line.new(
             q4Line, -1000000,
             q4Line, 1000000,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=quarterColor,
             width=quarterWidth
             )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. FIRST DAY OF EVERY MONTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int monthStart = timestamp(tz, y, m, 1, 0, 0)

bool monthTrigger =
     time >= monthStart and time[1] < monthStart

if showMonthly and monthTrigger

    if isDaily
        // Daily chart: one day behind
        line.new(
             x1 = bar_index - 1,
             y1 = -1000000,
             x2 = bar_index - 1,
             y2 = 1000000,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = monthlyColor,
             width = monthlyWidth
             )
    else
        // All other timeframes: exact 1st
        line.new(
             monthStart, -1000000,
             monthStart, 1000000,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=monthlyColor,
             width=monthlyWidth
             )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. EVERY SUNDAY 6 PM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int dow = dayofweek(time, tz)

int sunday6PM =
     timestamp(tz, y, m, d, 18, 0)

bool sundayTrigger =
     dow == dayofweek.sunday and
     time <= sunday6PM and
     time_close >= sunday6PM

if showSunday and sundayTrigger

    if is4Hour
        // 4H: existing alignment
        line.new(
             x1 = bar_index - 0,
             y1 = -1000000,
             x2 = bar_index - 0,
             y2 = 1000000,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = sundayColor,
             width = sundayWidth
             )
    else
        // Other timeframes: exact 6 PM
        line.new(
             sunday6PM, -1000000,
             sunday6PM, 1000000,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=sundayColor,
             width=sundayWidth
             )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. EVERY DAY 6 PM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int daily6PM =
     timestamp(tz, y, m, d, 18, 0)

bool dailyTrigger =
     time <= daily6PM and
     time_close >= daily6PM

if showDaily6PM and dailyTrigger

    if is4Hour

        // 4H: existing alignment
        line.new(
             x1 = bar_index - 6,
             y1 = -1000000,
             x2 = bar_index - 6,
             y2 = 1000000,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = dailyColor,
             width = dailyWidth
             )

        // Monday 6 PM correction
        if dow == dayofweek.monday
            line.new(
                 x1 = bar_index,
                 y1 = -1000000,
                 x2 = bar_index,
                 y2 = 1000000,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = dailyColor,
                 width = dailyWidth
                 )

    else
        // Other timeframes: exact 6 PM
        line.new(
             daily6PM, -1000000,
             daily6PM, 1000000,
             xloc=xloc.bar_time,
             extend=extend.none,
             color=dailyColor,
             width=dailyWidth
             )
````
