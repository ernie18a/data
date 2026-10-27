# 24H Vol & MTF Volatility

- url: https://www.tradingview.com/script/sZWGOFLO-24H-Vol-MTF-Volatility/
- type: indicator
- pine_id: PUB;2b84e4f858e04393b36ba9bc9da21ef6
- version: 2.0

## Description

24H Vol & MTF Volatility Dashboard

The 24H Vol & MTF Volatility indicator is a clean, compact dashboard that acts as a real-time health check for any asset. Instead of cluttering your screen with multiple indicators and moving averages, it displays vital volume, volatility, and trend performance statistics inside one simple table.
Key Features

    24-Hour Volume: Shows exactly how much money (in USD) has traded hands over the last 24 hours. It updates continuously, giving you an accurate picture of the asset's current liquidity.

    Multi-Timeframe Volatility: Instantly see how much the price is stretching on a Daily, Weekly, and Monthly basis. This helps you quickly gauge if the market is unusually quiet or experiencing high-risk, volatile spikes.

    Live Price Tracking: Tracks both Daily and Monthly price changes. The numbers automatically flash Green when the price is up and Red when the price is down.

How to Customize Your Dashboard

This indicator is built to be modular, meaning you can adjust it to fit your exact trading layout.
1. Choose Your Theme

Matches your TradingView charts perfectly with a quick dropdown menu:

    Dark Mode: Deep, dark backgrounds with bright text—perfect for night trading.

    Light Mode: Clean, crisp backgrounds with dark text—ideal for high-visibility day trading.

2. Clean, Auto-Resizing Layout

Don't care about monthly stats? Only want to see 24H volume? No problem. In the settings menu, you can turn individual rows on or off.

When you hide a row, the table automatically shrinks and cleans itself up, ensuring there are no ugly blank spaces left on your chart.
3. Place It Anywhere

You can scale the text size (Tiny, Small, Normal, Large) and snap the table to any of the 9 positions on your chart (such as the bottom-left, top-right, or dead center) so it never blocks your price action.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Starbots
//@version=6
indicator("24H Vol & MTF Volatility", overlay=true, format=format.volume)

import PineCoders/getSeries/1 as gs

var string G_TABLE = "Display Settings"
tableTextSize = input.string("normal", title="Text Size", options=["tiny", "small", "normal", "large"], group=G_TABLE)
tablePosition = input.string("bottom_left", title="Table Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=G_TABLE)
tableTheme    = input.string("Dark", title="Table Theme", options=["Light", "Dark"], group=G_TABLE)

var string G_DATA = "Data Filters"
showVolChg    = input.bool(true, title="Show 24H Volume Change %", group=G_DATA)
showDVol      = input.bool(true, title="Show Daily Volatility", group=G_DATA)
showWVol      = input.bool(true, title="Show Weekly Volatility", group=G_DATA)
showMVol      = input.bool(true, title="Show Monthly Volatility", group=G_DATA)
showDailyChg  = input.bool(true, title="Show Daily Price Change %", group=G_DATA)
showMonthlyChg = input.bool(true, title="Show Monthly Price Change %", group=G_DATA)

price = close
currency = "USD" 

sumVolTF = switch
    timeframe.isminutes or timeframe.isseconds => "1"
    timeframe.isdaily => "5"
    => "60"

sum24hVol(src) =>
    msIn24h = 24 * 60 * 60 * 1000
    sourceValues = gs.rollOnTimeWhen(src, msIn24h)
    sourceValues.sum()

expr = syminfo.volumetype == "quote" ? volume : price * volume
vol24h = request.security(syminfo.tickerid, sumVolTF, sum24hVol(expr * request.currency_rate(syminfo.currency, currency)))

fastSearchN(xs, x) =>
    max_bars_back(xs, 366)
    left  = 0
    right = math.min(bar_index, 366)
    mid   = 0
    if xs < x
        0
    else
        for i = 0 to 9
            mid := math.ceil((left + right) / 2)
            if left == right
                break
            else if xs[mid] < x
                right := mid
                continue
            else if xs[mid] > x
                left := mid
                continue
            else
                break
        mid

calcScreenerVol(bb) =>
    bb2 = bb
    if bar_index == 0
        bb2 := 365
    if bb2 == 0
        na
    else
        s = math.sum((high - low) / math.abs(low) * 100 / bb2, bb2)
        bb == 0 ? na : s

calcAllVolatilities() =>
    month_ago_this_bar = time - 1000 * 60 * 60 * 24 * 30
    countOfBars1MonthAgoThisBar = fastSearchN(time, month_ago_this_bar)
    
    week_ago_this_bar = time - 1000 * 60 * 60 * 24 * 7
    countOfBarsWeekAgoThisBar = fastSearchN(time, week_ago_this_bar)
    
    vD = ta.tr(true) * 100 / math.abs(low)
    vW = calcScreenerVol(countOfBarsWeekAgoThisBar)
    vM = calcScreenerVol(countOfBars1MonthAgoThisBar)
    
    closeMonthAgo = close[math.max(1, countOfBars1MonthAgoThisBar)]
    chgM = ((close - closeMonthAgo) / closeMonthAgo) * 100
    
    // Get yesterday's full daily volume converted to target currency
    yesterdayVol = expr[1] * request.currency_rate(syminfo.currency, currency)[1]
    [vD, vW, vM, chgM, yesterdayVol]

[dVol, wVol, mVol, mChg, volYesterday] = request.security(syminfo.tickerid, "D", calcAllVolatilities(), gaps=barmerge.gaps_off)

dChg = ta.change(close) / close[1] * 100
// Calculate change using the formula: (Current / Previous - 1) * 100
vChg = ((vol24h / volYesterday) - 1) * 100

getPosition(pos) =>
    switch pos
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.top_right

getSize(sz) =>
    switch sz
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small

formatDollarVolume(val) =>
    if na(val) or val == 0
        "N/A"
    else if val >= 1000000000
        str.tostring(val / 1000000000, "$#.##B")
    else if val >= 1000000
        str.tostring(val / 1000000, "$#.##M")
    else if val >= 1000
        str.tostring(val / 1000, "$#.##K")
    else
        str.tostring(val, "$#.##")

var table statsTable = table.new(position=getPosition(tablePosition), columns=2, rows=7, border_width=1, border_color=color.gray)

if barstate.islast
    bool isDark = (tableTheme == "Dark")
    
    color headerBg    = isDark ? color.new(#1c2030, 0) : color.new(#f1f3f7, 0)
    color volHeaderBg = isDark ? color.new(#1b365d, 0) : color.new(#dbeafe, 0)
    color valueBg     = isDark ? color.new(#131722, 0) : color.new(#ffffff, 0)
    
    color textColor    = isDark ? color.new(#d1d4dc, 0) : color.new(#131722, 0)
    color volTextColor = isDark ? color.new(#38bdf8, 0) : color.new(#1e40af, 0)
    color borderColor  = isDark ? color.new(#2a2e39, 0) : color.new(#e0e3eb, 0)
    
    color colorUp   = isDark ? color.new(#22c55e, 0) : color.new(#15803d, 0)
    color colorDown = isDark ? color.new(#ef4444, 0) : color.new(#b91c1c, 0)

    table.clear(statsTable, 0, 0, 1, 6)
    table.set_border_color(statsTable, borderColor)
    textSize = getSize(tableTextSize)

    table.cell(statsTable, 0, 0, "24H Vol (USD)", bgcolor=volHeaderBg, text_color=volTextColor, text_size=textSize)
    table.cell(statsTable, 1, 0, formatDollarVolume(vol24h), bgcolor=valueBg, text_color=volTextColor, text_size=textSize)

    int currentRow = 1

    if showVolChg
        color vChgColor = nz(vChg) >= 0 ? colorUp : colorDown
        string prefix = nz(vChg) >= 0 ? "+" : ""
        table.cell(statsTable, 0, currentRow, "24H Vol Change", bgcolor=headerBg, text_color=textColor, text_size=textSize)
        table.cell(statsTable, 1, currentRow, prefix + str.tostring(vChg, "#.##") + "%", bgcolor=valueBg, text_color=vChgColor, text_size=textSize)
        currentRow += 1

    if showDVol
        table.cell(statsTable, 0, currentRow, "Daily Volatility", bgcolor=headerBg, text_color=textColor, text_size=textSize)
        table.cell(statsTable, 1, currentRow, str.tostring(dVol, "#.##") + "%", bgcolor=valueBg, text_color=textColor, text_size=textSize)
        currentRow += 1
    
    if showWVol
        table.cell(statsTable, 0, currentRow, "Weekly Volatility", bgcolor=headerBg, text_color=textColor, text_size=textSize)
        table.cell(statsTable, 1, currentRow, str.tostring(wVol, "#.##") + "%", bgcolor=valueBg, text_color=textColor, text_size=textSize)
        currentRow += 1

    if showMVol
        table.cell(statsTable, 0, currentRow, "Monthly Volatility", bgcolor=headerBg, text_color=textColor, text_size=textSize)
        table.cell(statsTable, 1, currentRow, str.tostring(mVol, "#.##") + "%", bgcolor=valueBg, text_color=textColor, text_size=textSize)
        currentRow += 1

    if showDailyChg
        color dChgColor = nz(dChg) >= 0 ? colorUp : colorDown
        string prefix = nz(dChg) >= 0 ? "+" : ""
        table.cell(statsTable, 0, currentRow, "Daily Change", bgcolor=headerBg, text_color=textColor, text_size=textSize)
        table.cell(statsTable, 1, currentRow, prefix + str.tostring(dChg, "#.##") + "%", bgcolor=valueBg, text_color=dChgColor, text_size=textSize)
        currentRow += 1

    if showMonthlyChg
        color mChgColor = nz(mChg) >= 0 ? colorUp : colorDown
        string prefix = nz(mChg) >= 0 ? "+" : ""
        table.cell(statsTable, 0, currentRow, "Monthly Change", bgcolor=headerBg, text_color=textColor, text_size=textSize)
        table.cell(statsTable, 1, currentRow, prefix + str.tostring(mChg, "#.##") + "%", bgcolor=valueBg, text_color=mChgColor, text_size=textSize)
````
