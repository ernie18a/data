# Mark Minervini Trend Template Candles

- url: https://www.tradingview.com/script/BHXNz9Tp-Mark-Minervini-Trend-Template-Candles/
- type: indicator
- pine_id: PUB;f43f81b5ccae4f49ba1ad66368ee2241
- version: 1.0

## Description

Converted from Trendspider Code! Will add more later!

## Source Code

````pine
//@version=6
indicator('Mark Minervini Trend Template Candles', overlay = true)

// ===================== INPUTS & COLORS =====================
showTable = input.bool(true, title = 'Show Criteria Table')

// Neon color scale matching your score system (0-10)
getColor(score) =>
    switch score
        10 => #00F2FE // Neon Cyan (Extreme Best)
        9 => #3399FF // Bright Azure Blue
        8 => #66B2FF // Vivid Medium Blue
        7 => #99CCFF // Brighter Powder Blue
        6 => #FFD966 // Light Yellow-Orange
        5 => #FFB84D // Golden Orange
        4 => #FF9933 // Warm Amber-Orange
        3 => #FF751A // Strong Orange
        2 => #FF4D1A // Bright Red-Orange
        => #FF1A1A // Default / Neon Red (Extreme Worst)

// ===================== COMPUTE INDICATORS =====================
sma50 = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)
sma200_30_ago = sma200[30]

// Fetch 52-Week High and Low from the Weekly Timeframe
high52_w = request.security(syminfo.tickerid, 'W', ta.highest(high, 52), lookahead = barmerge.lookahead_off)
low52_w = request.security(syminfo.tickerid, 'W', ta.lowest(low, 52), lookahead = barmerge.lookahead_off)

// ===================== RELATIVE PERFORMANCE PROXY =====================
spx_close = request.security('INDEX:SPX', timeframe.period, close, lookahead = barmerge.lookahead_off)
rs_ratio = close / spx_close
rs_high = ta.highest(rs_ratio, 252)
rs_low = ta.lowest(rs_ratio, 252)
rp_score = (rs_ratio - rs_low) / math.max(0.00001, rs_high - rs_low) * 100

// ===================== MINERVINI CRITERIA SCORING =====================
rp_met = not na(rp_score) and rp_score > 70
price_above_50 = not na(close) and not na(sma50) and close > sma50
price_above_150 = not na(close) and not na(sma150) and close > sma150
price_above_200 = not na(close) and not na(sma200) and close > sma200
sma50_above_150 = not na(sma50) and not na(sma150) and sma50 > sma150
sma50_above_200 = not na(sma50) and not na(sma200) and sma50 > sma200
sma150_above_200 = not na(sma150) and not na(sma200) and sma150 > sma200
price_30_above_low = not na(close) and not na(low52_w) and close >= low52_w * 1.30
price_25_near_high = not na(close) and not na(high52_w) and close >= high52_w * 0.75
sma200_rising = not na(sma200) and not na(sma200_30_ago) and sma200 > sma200_30_ago

score = 0
score := score + (rp_met ? 1 : 0)
score := score + (price_above_50 ? 1 : 0)
score := score + (price_above_150 ? 1 : 0)
score := score + (price_above_200 ? 1 : 0)
score := score + (sma50_above_150 ? 1 : 0)
score := score + (sma50_above_200 ? 1 : 0)
score := score + (sma150_above_200 ? 1 : 0)
score := score + (price_30_above_low ? 1 : 0)
score := score + (price_25_near_high ? 1 : 0)
score := score + (sma200_rising ? 1 : 0)

// ===================== OUTPUT RENDERING =====================
barcolor(getColor(score))
plot(sma50, title = 'SMA 50', color = color.yellow, linewidth = 1)
plot(sma150, title = 'SMA 150', color = color.orange, linewidth = 1)
plot(sma200, title = 'SMA 200', color = color.red, linewidth = 2)

// ===================== SIGNALS / ALERTS =====================
alertcondition(score == 10, title = 'Meets All 10 Trend Template Criteria', message = 'Minervini 10/10 Score Achieved!')
alertcondition(score >= 9, title = '9+ Criteria Met', message = 'Minervini Score is 9 or higher.')
alertcondition(score >= 8, title = '8+ Criteria Met', message = 'Minervini Score is 8 or higher.')
alertcondition(score >= 7, title = '7+ Criteria Met', message = 'Minervini Score is 7 or higher.')
alertcondition(score >= 6, title = '6+ Criteria Met', message = 'Minervini Score is 6 or higher.')
alertcondition(score >= 5, title = '5+ Criteria Met', message = 'Minervini Score is 5 or higher.')

// ===================== UI OVERLAY TABLE =====================
var table infoTable = table.new(position.top_right, 2, 16, bgcolor = color.new(color.black, 30), border_width = 1, border_color = color.gray)

if showTable and barstate.islast
    table.merge_cells(infoTable, 0, 0, 1, 0)
    table.cell(infoTable, 0, 0, text = 'Minervini Template (' + timeframe.period + ')', text_color = color.white, bgcolor = color.gray, text_size = size.small)

    table.cell(infoTable, 0, 1, text = 'RP Score Proxy > 70', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 1, text = rp_met ? '✓' : '✗', text_color = rp_met ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 2, text = 'Price > SMA 50', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 2, text = price_above_50 ? '✓' : '✗', text_color = price_above_50 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 3, text = 'Price > SMA 150', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 3, text = price_above_150 ? '✓' : '✗', text_color = price_above_150 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 4, text = 'Price > SMA 200', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 4, text = price_above_200 ? '✓' : '✗', text_color = price_above_200 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 5, text = 'SMA 50 > SMA 150', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 5, text = sma50_above_150 ? '✓' : '✗', text_color = sma50_above_150 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 6, text = 'SMA 50 > SMA 200', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 6, text = sma50_above_200 ? '✓' : '✗', text_color = sma50_above_200 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 7, text = 'SMA 150 > SMA 200', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 7, text = sma150_above_200 ? '✓' : '✗', text_color = sma150_above_200 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 8, text = 'Price 30% > 52W Low', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 8, text = price_30_above_low ? '✓' : '✗', text_color = price_30_above_low ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 9, text = 'Price w/in 25% of 52W High', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 9, text = price_25_near_high ? '✓' : '✗', text_color = price_25_near_high ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 10, text = 'SMA 200 Rising', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 10, text = sma200_rising ? '✓' : '✗', text_color = sma200_rising ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.merge_cells(infoTable, 0, 11, 1, 11)
    table.cell(infoTable, 0, 11, text = 'Current Metrics:', text_color = color.white, bgcolor = color.gray, text_size = size.small)

    table.cell(infoTable, 0, 12, text = 'RP Score Proxy', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 12, text = str.tostring(rp_score, '#.#'), text_color = color.white, text_size = size.small, text_halign = text.align_right)

    pct_high = (close / high52_w - 1) * 100
    table.cell(infoTable, 0, 13, text = 'Price vs 52W High', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 13, text = str.tostring(pct_high, '#.#') + '%', text_color = pct_high >= -25 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    pct_low = (close / low52_w - 1) * 100
    table.cell(infoTable, 0, 14, text = 'Price vs 52W Low', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 14, text = '+' + str.tostring(pct_low, '#.#') + '%', text_color = pct_low >= 30 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)

    table.cell(infoTable, 0, 15, text = 'Total Criteria Met', text_color = color.white, bgcolor = #363a45, text_size = size.small, text_halign = text.align_left)
    table.cell(infoTable, 1, 15, text = str.tostring(score) + '/10', text_color = color.white, bgcolor = #363a45, text_size = size.small, text_halign = text.align_right)
````
