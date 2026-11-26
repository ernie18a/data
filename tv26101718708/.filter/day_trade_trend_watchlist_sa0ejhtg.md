# Day Trade Trend Watchlist

- url: https://www.tradingview.com/script/sa0ejhtG-Day-Trade-Trend-Watchlist/
- type: indicator
- pine_id: PUB;fde33da6322e4655b640d7b1a713848a
- version: 1.0

## Description

# 10-Stock Premarket Breakout + EMA/VWAP Day Trade Trend Watchlist

Before you start: 
[*]Extended Hours must be turned on.
[*]Mark your Pre Market Levels or find a Indicator does that for you.

## Overview
This indicator turns any chart into a live screening dashboard for up to 10 stocks at once. It tracks each ticker's premarket high and low, flags the moment price breaks out of that range, and reads trend from EMA alignment — all from one customizable table, without needing to open 10 separate charts. A VWAP and 8/21/200 EMA are also plotted directly on your chart for the symbol you're currently viewing.

## What it does
- **Premarket High/Low (PMH/PML) tracking** — automatically calculates each ticker's premarket range (default 4:00–9:30 AM ET, adjustable session and timezone) and resets it fresh every trading day. Pulls real extended-hours data regardless of your own chart's display settings.
- **Breakout detection** — once premarket ends, the script flags the moment price crosses above the premarket high or below the premarket low, both in the table and with an on-chart arrow label naming the ticker.
- **Trend column (8/21/200 EMA stack)** — each ticker's trend is read from EMA alignment: price stacked above all three EMAs shows UP, the reverse shows DOWN, anything in between shows MIXED.
- **Daily inside/outside bar column** — classifies whether each ticker's current daily candle is still contained inside yesterday's range, or has broken outside it (up, down, or both).
- **On-chart EMA + VWAP** — the 8, 21, and 200 EMA plus a session VWAP are plotted directly on whatever symbol/timeframe your chart is showing, for standard visual trend and fair-value context.
- **Customizable dashboard** — choose exactly which columns appear (Last Price, PM High/Low, Breakout Status, Trend, Daily Bar), set text size, table position, and recolor every part of the table to match your own chart theme. Default view is a clean, minimal Ticker + Last price layout.
- **Built-in alerts** — get notified the moment any of your 10 tickers breaks its premarket high or low, with an option to only fire once per level per day.

## How to use it
1. Add the indicator to any chart — the chart's own symbol doesn't need to match your watchlist.
2. Open Settings → "Watchlist" group → enter up to 10 tickers. Leave any slot blank to skip it.
3. Adjust the premarket session window and timezone if you trade a market other than US equities.
4. Use the "Columns to Show" group to pick exactly what information you want visible.
5. Right-click the chart → Add Alert → select this indicator to receive breakout notifications.

## Notes
- Premarket tracking, EMAs, and trend classification all run on the 10-minute timeframe internally for consistency across all 10 tickers, regardless of your chart's own timeframe.
- This is a discretionary screening tool, not a standalone signal generator — use it alongside your own market structure, volume, and risk management approach.
- If a ticker shows "n/a," double check the symbol is entered correctly or that premarket data is available for that instrument.

## Source Code

````pine
//@version=6
indicator('10-Stock PM Breakout + 10min Trend Watchlist', overlay = true, max_labels_count = 100)

// ════════════════════════════════════════════════════════════
// TICKER INPUTS
// ════════════════════════════════════════════════════════════
g1 = 'Watchlist (10 slots — leave blank to skip)'
t1 = input.symbol('AAPL', 'Ticker 1', group = g1)
t2 = input.symbol('TSLA', 'Ticker 2', group = g1)
t3 = input.symbol('NVDA', 'Ticker 3', group = g1)
t4 = input.symbol('AMD', 'Ticker 4', group = g1)
t5 = input.symbol('MSFT', 'Ticker 5', group = g1)
t6 = input.symbol('', 'Ticker 6', group = g1)
t7 = input.symbol('', 'Ticker 7', group = g1)
t8 = input.symbol('', 'Ticker 8', group = g1)
t9 = input.symbol('', 'Ticker 9', group = g1)
t10 = input.symbol('', 'Ticker 10', group = g1)

g2 = 'Premarket Session'
sessionInput = input.session('0400-0930', 'Premarket Session (Exchange Time)', group = g2)
sessionTZ = input.string('America/New_York', 'Session Timezone', group = g2)

g3 = 'Trend (10min EMA)'
ema8Len = input.int(8, 'Fast EMA', group = g3)
ema21Len = input.int(21, 'Mid EMA', group = g3)
ema200Len = input.int(200, 'Slow EMA', group = g3)

g4 = 'Display'
tablePos = input.string('top_right', 'Table Position', options = ['top_right', 'top_left', 'bottom_right', 'bottom_left'], group = g4)
showOnlyBroken = input.bool(false, 'Show Only Breakouts (Hide Others)', group = g4)
tableTextSize = input.string('large', 'Text Size', options = ['small', 'normal', 'large'], group = g4)

g4b = 'Columns to Show'
showLastCol = input.bool(true, 'Last Price', group = g4b)
showPmCol = input.bool(false, 'PM High/Low', group = g4b)
showStatusCol = input.bool(false, 'Breakout Status', group = g4b)
showTrendCol = input.bool(false, 'Trend (EMA)', group = g4b)
showDayCol = input.bool(false, 'Daily Inside/Outside Bar', group = g4b)

g4c = 'Dashboard Colors'
headerBgColor = input.color(color.navy, 'Header Background', group = g4c)
headerTxtColor = input.color(color.white, 'Header Text', group = g4c)
rowBgColor = input.color(color.new(color.gray, 90), 'Default Row Background', group = g4c)
rowTxtColor = input.color(color.white, 'Default Row Text', group = g4c)
bullBgColor = input.color(color.new(color.lime, 80), 'Bullish Breakout Row Background', group = g4c)
bearBgColor = input.color(color.new(color.red, 80), 'Bearish Breakout Row Background', group = g4c)
bullTxtColor = input.color(color.lime, 'Bullish Text/Status Color', group = g4c)
bearTxtColor = input.color(color.red, 'Bearish Text/Status Color', group = g4c)
mixedTxtColor = input.color(color.yellow, 'Mixed/Inside Text Color', group = g4c)
borderColor = input.color(color.gray, 'Table Border Color', group = g4c)

g5 = 'Alerts'
alertOnce = input.bool(true, 'Only Alert Once Per Breakout Per Day', group = g5)

// ════════════════════════════════════════════════════════════
// STEP 1 — request.security() calls: unconditional, global scope,
// raw data only (v5-compliant). Pulled on the 10min timeframe.
// IMPORTANT: plain symbol strings only return REGULAR SESSION
// data from request.security() — premarket bars are excluded
// by default. We build each ticker with ticker.new(..., session.extended)
// so premarket/extended-hours bars are actually included.
//
// BUGFIX: input.symbol() often returns a string that ALREADY
// includes an exchange prefix (e.g. "NASDAQ:SPY"). Passing that
// whole string as the *ticker* argument to ticker.new() while also
// passing syminfo.prefix as the *prefix* argument double-prefixes
// it, producing an invalid combined symbol. We detect an existing
// prefix (a colon in the string) and build the ticker accordingly.
// ════════════════════════════════════════════════════════════
sessTimeExpr() =>
    time('10', sessionInput, sessionTZ)

f_buildTicker(sym) =>
    string result = na
    if sym == ''
        result := ticker.new(syminfo.prefix, syminfo.ticker, session.extended)
        result
    else if str.contains(sym, ':')
        colonPos = str.pos(sym, ':')
        prefixPart = str.substring(sym, 0, colonPos)
        tickerPart = str.substring(sym, colonPos + 1)
        result := ticker.new(prefixPart, tickerPart, session.extended)
        result
    else
        result := ticker.new(syminfo.prefix, sym, session.extended)
        result
    result

et1 = f_buildTicker(t1)
et2 = f_buildTicker(t2)
et3 = f_buildTicker(t3)
et4 = f_buildTicker(t4)
et5 = f_buildTicker(t5)
et6 = f_buildTicker(t6)
et7 = f_buildTicker(t7)
et8 = f_buildTicker(t8)
et9 = f_buildTicker(t9)
et10 = f_buildTicker(t10)

[h1, l1, c1, d1, st1, e1_8, e1_21, e1_200] = request.security(et1, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h2, l2, c2, d2, st2, e2_8, e2_21, e2_200] = request.security(et2, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h3, l3, c3, d3, st3, e3_8, e3_21, e3_200] = request.security(et3, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h4, l4, c4, d4, st4, e4_8, e4_21, e4_200] = request.security(et4, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h5, l5, c5, d5, st5, e5_8, e5_21, e5_200] = request.security(et5, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h6, l6, c6, d6, st6, e6_8, e6_21, e6_200] = request.security(et6, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h7, l7, c7, d7, st7, e7_8, e7_21, e7_200] = request.security(et7, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h8, l8, c8, d8, st8, e8_8, e8_21, e8_200] = request.security(et8, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h9, l9, c9, d9, st9, e9_8, e9_21, e9_200] = request.security(et9, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])
[h10, l10, c10, d10, st10, e10_8, e10_21, e10_200] = request.security(et10, '10', [high, low, close, time('D'), sessTimeExpr(), ta.ema(close, ema8Len), ta.ema(close, ema21Len), ta.ema(close, ema200Len)])

// ════════════════════════════════════════════════════════════
// STEP 1b — Daily inside/outside bar data, pulled separately on
// the DAILY timeframe regardless of what timeframe the rest of
// this script runs on. We need today's still-forming high/low/close
// plus yesterday's completed high/low to classify and detect breaks.
// ════════════════════════════════════════════════════════════
[dh1, dl1, dc1, pdh1, pdl1] = request.security(et1, 'D', [high, low, close, high[1], low[1]])
[dh2, dl2, dc2, pdh2, pdl2] = request.security(et2, 'D', [high, low, close, high[1], low[1]])
[dh3, dl3, dc3, pdh3, pdl3] = request.security(et3, 'D', [high, low, close, high[1], low[1]])
[dh4, dl4, dc4, pdh4, pdl4] = request.security(et4, 'D', [high, low, close, high[1], low[1]])
[dh5, dl5, dc5, pdh5, pdl5] = request.security(et5, 'D', [high, low, close, high[1], low[1]])
[dh6, dl6, dc6, pdh6, pdl6] = request.security(et6, 'D', [high, low, close, high[1], low[1]])
[dh7, dl7, dc7, pdh7, pdl7] = request.security(et7, 'D', [high, low, close, high[1], low[1]])
[dh8, dl8, dc8, pdh8, pdl8] = request.security(et8, 'D', [high, low, close, high[1], low[1]])
[dh9, dl9, dc9, pdh9, pdl9] = request.security(et9, 'D', [high, low, close, high[1], low[1]])
[dh10, dl10, dc10, pdh10, pdl10] = request.security(et10, 'D', [high, low, close, high[1], low[1]])

// ════════════════════════════════════════════════════════════
// STEP 2 — stateful logic OUTSIDE request.security(): premarket
// high/low tracking + breakout detection. Trend is simply
// close vs EMA, both already pulled from the 5min context.
// ════════════════════════════════════════════════════════════
f_track(h, l, c, dayId, inSess) =>
    var float pmH = na
    var float pmL = na
    var bool done = false
    var int lastDay = -1
    isNewDay = lastDay == -1 or dayId != lastDay
    if isNewDay
        pmH := na
        pmL := na
        done := false
        lastDay := dayId
        lastDay
    if not na(inSess)
        pmH := na(pmH) ? h : math.max(pmH, h)
        pmL := na(pmL) ? l : math.min(pmL, l)
        done := true
        done
    bH = na(inSess) and done and not na(pmH) and c > pmH
    bL = na(inSess) and done and not na(pmL) and c < pmL
    [pmH, pmL, bH, bL]

[pmh1, pml1, bh1, bl1] = f_track(h1, l1, c1, d1, st1)
[pmh2, pml2, bh2, bl2] = f_track(h2, l2, c2, d2, st2)
[pmh3, pml3, bh3, bl3] = f_track(h3, l3, c3, d3, st3)
[pmh4, pml4, bh4, bl4] = f_track(h4, l4, c4, d4, st4)
[pmh5, pml5, bh5, bl5] = f_track(h5, l5, c5, d5, st5)
[pmh6, pml6, bh6, bl6] = f_track(h6, l6, c6, d6, st6)
[pmh7, pml7, bh7, bl7] = f_track(h7, l7, c7, d7, st7)
[pmh8, pml8, bh8, bl8] = f_track(h8, l8, c8, d8, st8)
[pmh9, pml9, bh9, bl9] = f_track(h9, l9, c9, d9, st9)
[pmh10, pml10, bh10, bl10] = f_track(h10, l10, c10, d10, st10)

// trend: EMA stack alignment — 8 > 21 > 200 (price above all, stacked bullish) = UP
//        8 < 21 < 200 (stacked bearish) = DOWN, otherwise mixed/flat
f_trend(c, e8, e21, e200) =>
    result = '—'
    if not na(c) and not na(e8) and not na(e21) and not na(e200)
        if c > e8 and e8 > e21 and e21 > e200
            result := 'UP'
            result
        else if c < e8 and e8 < e21 and e21 < e200
            result := 'DOWN'
            result
        else
            result := 'MIXED'
            result
    result

trend1 = f_trend(c1, e1_8, e1_21, e1_200)
trend2 = f_trend(c2, e2_8, e2_21, e2_200)
trend3 = f_trend(c3, e3_8, e3_21, e3_200)
trend4 = f_trend(c4, e4_8, e4_21, e4_200)
trend5 = f_trend(c5, e5_8, e5_21, e5_200)
trend6 = f_trend(c6, e6_8, e6_21, e6_200)
trend7 = f_trend(c7, e7_8, e7_21, e7_200)
trend8 = f_trend(c8, e8_8, e8_21, e8_200)
trend9 = f_trend(c9, e9_8, e9_21, e9_200)
trend10 = f_trend(c10, e10_8, e10_21, e10_200)

// ════════════════════════════════════════════════════════════
// DAILY INSIDE / OUTSIDE BAR CLASSIFICATION + BREAKOUT
// Inside bar: today's high/low so far is fully contained within
// yesterday's high/low (high <= PDH and low >= PDL).
// Outside bar: today has already exceeded yesterday's high AND low.
// Breakout: today started as an inside bar, then price broke
// above PDH (bullish) or below PDL (bearish) — flagged once it
// happens, regardless of whether the rest of the day still
// qualifies as "outside" overall.
// ════════════════════════════════════════════════════════════
f_dayType(dh, dl, dc, pdh, pdl) =>
    string dayType = '—'
    bool brokeUp = false
    bool brokeDown = false
    if not na(dh) and not na(dl) and not na(pdh) and not na(pdl)
        insideSoFar = dh <= pdh and dl >= pdl
        brokeUp := dh > pdh
        brokeDown := dl < pdl
        if insideSoFar
            dayType := 'INSIDE'
            dayType
        else if brokeUp and brokeDown
            dayType := 'OUTSIDE'
            dayType
        else if brokeUp
            dayType := 'OUTSIDE (UP)'
            dayType
        else if brokeDown
            dayType := 'OUTSIDE (DN)'
            dayType
    [dayType, brokeUp, brokeDown]

[dayType1, du1, dd1] = f_dayType(dh1, dl1, dc1, pdh1, pdl1)
[dayType2, du2, dd2] = f_dayType(dh2, dl2, dc2, pdh2, pdl2)
[dayType3, du3, dd3] = f_dayType(dh3, dl3, dc3, pdh3, pdl3)
[dayType4, du4, dd4] = f_dayType(dh4, dl4, dc4, pdh4, pdl4)
[dayType5, du5, dd5] = f_dayType(dh5, dl5, dc5, pdh5, pdl5)
[dayType6, du6, dd6] = f_dayType(dh6, dl6, dc6, pdh6, pdl6)
[dayType7, du7, dd7] = f_dayType(dh7, dl7, dc7, pdh7, pdl7)
[dayType8, du8, dd8] = f_dayType(dh8, dl8, dc8, pdh8, pdl8)
[dayType9, du9, dd9] = f_dayType(dh9, dl9, dc9, pdh9, pdl9)
[dayType10, du10, dd10] = f_dayType(dh10, dl10, dc10, pdh10, pdl10)

// ════════════════════════════════════════════════════════════
// SHARED DAY-CHANGE FLAG (used by both alert blocks below)
// ════════════════════════════════════════════════════════════
newDayMain = ta.change(time('D')) != 0

// fire breakout alert once per day per direction, only meaningful the
// moment the bar transitions out of "inside" status
var array<bool> dailyAlertedUp = array.new_bool(10, false)
var array<bool> dailyAlertedDown = array.new_bool(10, false)
if newDayMain
    array.fill(dailyAlertedUp, false)
    array.fill(dailyAlertedDown, false)

f_dailyAlert(idx, sym, brokeUp, brokeDown) =>
    if sym != ''
        if brokeUp and not array.get(dailyAlertedUp, idx)
            array.set(dailyAlertedUp, idx, true)
            alert(sym + ' broke ABOVE yesterday\'s high (daily outside bar)', alert.freq_once_per_bar)
        if brokeDown and not array.get(dailyAlertedDown, idx)
            array.set(dailyAlertedDown, idx, true)
            alert(sym + ' broke BELOW yesterday\'s low (daily outside bar)', alert.freq_once_per_bar)

f_dailyAlert(0, t1, du1, dd1)
f_dailyAlert(1, t2, du2, dd2)
f_dailyAlert(2, t3, du3, dd3)
f_dailyAlert(3, t4, du4, dd4)
f_dailyAlert(4, t5, du5, dd5)
f_dailyAlert(5, t6, du6, dd6)
f_dailyAlert(6, t7, du7, dd7)
f_dailyAlert(7, t8, du8, dd8)
f_dailyAlert(8, t9, du9, dd9)
f_dailyAlert(9, t10, du10, dd10)

// ════════════════════════════════════════════════════════════
// ALERTS (fire once per symbol per day)
// ════════════════════════════════════════════════════════════
var array<bool> alertedHigh = array.new_bool(10, false)
var array<bool> alertedLow = array.new_bool(10, false)
if newDayMain
    array.fill(alertedHigh, false)
    array.fill(alertedLow, false)

f_checkAlert(idx, sym, bH, bL) =>
    if sym != ''
        if bH and (not alertOnce or not array.get(alertedHigh, idx))
            array.set(alertedHigh, idx, true)
            alert(sym + ' broke ABOVE premarket high (10min)', alert.freq_once_per_bar)
        if bL and (not alertOnce or not array.get(alertedLow, idx))
            array.set(alertedLow, idx, true)
            alert(sym + ' broke BELOW premarket low (10min)', alert.freq_once_per_bar)

f_checkAlert(0, t1, bh1, bl1)
f_checkAlert(1, t2, bh2, bl2)
f_checkAlert(2, t3, bh3, bl3)
f_checkAlert(3, t4, bh4, bl4)
f_checkAlert(4, t5, bh5, bl5)
f_checkAlert(5, t6, bh6, bl6)
f_checkAlert(6, t7, bh7, bl7)
f_checkAlert(7, t8, bh8, bl8)
f_checkAlert(8, t9, bh9, bl9)
f_checkAlert(9, t10, bh10, bl10)

// ════════════════════════════════════════════════════════════
// EMA PLOTS ON THE CURRENT CHART
// These plot directly on whatever symbol/timeframe the chart is
// showing (not the watchlist tickers) — standard visual EMA lines.
// ════════════════════════════════════════════════════════════
chartEma8 = ta.ema(close, ema8Len)
chartEma21 = ta.ema(close, ema21Len)
chartEma200 = ta.ema(close, ema200Len)

plot(chartEma8, 'EMA 8', color = color.new(color.aqua, 0), linewidth = 1)
plot(chartEma21, 'EMA 21', color = color.new(color.yellow, 0), linewidth = 1)
plot(chartEma200, 'EMA 200', color = color.new(color.orange, 0), linewidth = 2)

// ════════════════════════════════════════════════════════════
// VWAP — plotted on whatever symbol/timeframe the chart is showing.
// Resets automatically at the start of each session (standard VWAP
// behavior), using Pine's built-in ta.vwap().
// ════════════════════════════════════════════════════════════
chartVwap = ta.vwap(hlc3)
plot(chartVwap, 'VWAP', color = color.new(color.fuchsia, 0), linewidth = 2)

// ════════════════════════════════════════════════════════════
// TABLE
// Columns shown are controlled entirely by the toggles above.
// Ticker is always shown. Each other column only appears if its
// toggle is on, keeping the dashboard as minimal or as detailed
// as you want — default is just Ticker + Last for a clean,
// uncluttered mobile view.
// ════════════════════════════════════════════════════════════
posMap = tablePos == 'top_right' ? position.top_right : tablePos == 'top_left' ? position.top_left : tablePos == 'bottom_right' ? position.bottom_right : position.bottom_left
txtSize = tableTextSize == 'small' ? size.small : tableTextSize == 'large' ? size.large : size.normal

colCount = 1 + (showLastCol ? 1 : 0) + (showPmCol ? 1 : 0) + (showStatusCol ? 1 : 0) + (showTrendCol ? 1 : 0) + (showDayCol ? 1 : 0)
var table tbl = table.new(posMap, colCount, 11, border_width = 1, frame_width = 1, frame_color = borderColor)

if barstate.islast
    col = 0
    table.cell(tbl, col, 0, 'Ticker', bgcolor = headerBgColor, text_color = headerTxtColor, text_size = txtSize)
    col := col + 1
    if showLastCol
        table.cell(tbl, col, 0, 'Last', bgcolor = headerBgColor, text_color = headerTxtColor, text_size = txtSize)
        col := col + 1
        col
    if showPmCol
        table.cell(tbl, col, 0, 'PM High/Low', bgcolor = headerBgColor, text_color = headerTxtColor, text_size = txtSize)
        col := col + 1
        col
    if showStatusCol
        table.cell(tbl, col, 0, 'Status', bgcolor = headerBgColor, text_color = headerTxtColor, text_size = txtSize)
        col := col + 1
        col
    if showTrendCol
        table.cell(tbl, col, 0, 'Trend', bgcolor = headerBgColor, text_color = headerTxtColor, text_size = txtSize)
        col := col + 1
        col
    if showDayCol
        table.cell(tbl, col, 0, 'Daily Bar', bgcolor = headerBgColor, text_color = headerTxtColor, text_size = txtSize)

f_row(rowIdx, sym, c, h, l, bH, bL, trendTxt, dayType, brokeUp, brokeDown) =>
    if sym != ''
        include = not showOnlyBroken or bH or bL
        if include
            status = bH ? '🔼 HIGH BREAK' : bL ? '🔽 LOW BREAK' : '—'
            statusColor = bH ? bullTxtColor : bL ? bearTxtColor : rowTxtColor
            rowBg = bH ? bullBgColor : bL ? bearBgColor : rowBgColor
            trendColor = trendTxt == 'UP' ? bullTxtColor : trendTxt == 'DOWN' ? bearTxtColor : trendTxt == 'MIXED' ? mixedTxtColor : rowTxtColor
            trendArrow = trendTxt == 'UP' ? '▲ UP' : trendTxt == 'DOWN' ? '▼ DOWN' : trendTxt == 'MIXED' ? '◆ MIXED' : '—'
            dayTxt = brokeUp ? '▲ ' + dayType : brokeDown ? '▼ ' + dayType : dayType
            dayColor = brokeUp ? bullTxtColor : brokeDown ? bearTxtColor : dayType == 'INSIDE' ? mixedTxtColor : rowTxtColor
            pmTxt = na(h) or na(l) ? 'n/a' : str.tostring(h, '#.##') + ' / ' + str.tostring(l, '#.##')

            col = 0
            table.cell(tbl, col, rowIdx, sym, bgcolor = rowBg, text_color = rowTxtColor, text_size = txtSize)
            col := col + 1
            if showLastCol
                table.cell(tbl, col, rowIdx, na(c) ? 'n/a' : str.tostring(c, '#.##'), bgcolor = rowBg, text_color = rowTxtColor, text_size = txtSize)
                col := col + 1
                col
            if showPmCol
                table.cell(tbl, col, rowIdx, pmTxt, bgcolor = rowBg, text_color = rowTxtColor, text_size = txtSize)
                col := col + 1
                col
            if showStatusCol
                table.cell(tbl, col, rowIdx, status, bgcolor = rowBg, text_color = statusColor, text_size = txtSize)
                col := col + 1
                col
            if showTrendCol
                table.cell(tbl, col, rowIdx, trendArrow, bgcolor = rowBg, text_color = trendColor, text_size = txtSize)
                col := col + 1
                col
            if showDayCol
                table.cell(tbl, col, rowIdx, dayTxt, bgcolor = rowBg, text_color = dayColor, text_size = txtSize)

if barstate.islast
    f_row(1, t1, c1, pmh1, pml1, bh1, bl1, trend1, dayType1, du1, dd1)
    f_row(2, t2, c2, pmh2, pml2, bh2, bl2, trend2, dayType2, du2, dd2)
    f_row(3, t3, c3, pmh3, pml3, bh3, bl3, trend3, dayType3, du3, dd3)
    f_row(4, t4, c4, pmh4, pml4, bh4, bl4, trend4, dayType4, du4, dd4)
    f_row(5, t5, c5, pmh5, pml5, bh5, bl5, trend5, dayType5, du5, dd5)
    f_row(6, t6, c6, pmh6, pml6, bh6, bl6, trend6, dayType6, du6, dd6)
    f_row(7, t7, c7, pmh7, pml7, bh7, bl7, trend7, dayType7, du7, dd7)
    f_row(8, t8, c8, pmh8, pml8, bh8, bl8, trend8, dayType8, du8, dd8)
    f_row(9, t9, c9, pmh9, pml9, bh9, bl9, trend9, dayType9, du9, dd9)
    f_row(10, t10, c10, pmh10, pml10, bh10, bl10, trend10, dayType10, du10, dd10)

// ════════════════════════════════════════════════════════════
// ON-CHART BREAKOUT ARROWS
// Plots a green up-arrow the bar a ticker first breaks above its
// PM high, and a red down-arrow the bar it breaks below its PM
// low. Since this indicator can run on any chart, arrows for ALL
// 10 tickers are plotted on the visible chart's bars at the time
// each breakout happens (labels include the ticker symbol so you
// can tell them apart even though they share the same chart).
// ════════════════════════════════════════════════════════════
f_arrow(sym, bH, bL) =>
    if sym != ''
        if bH
            label.new(bar_index, low, '▲ ' + sym, style = label.style_label_up, color = color.new(color.lime, 0), textcolor = color.black, size = size.small, yloc = yloc.belowbar)
        if bL
            label.new(bar_index, high, '▼ ' + sym, style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.small, yloc = yloc.abovebar)

f_arrow(t1, bh1, bl1)
f_arrow(t2, bh2, bl2)
f_arrow(t3, bh3, bl3)
f_arrow(t4, bh4, bl4)
f_arrow(t5, bh5, bl5)
f_arrow(t6, bh6, bl6)
f_arrow(t7, bh7, bl7)
f_arrow(t8, bh8, bl8)
f_arrow(t9, bh9, bl9)
f_arrow(t10, bh10, bl10)
````
