# Rupee Volume & SL Distance

- url: https://www.tradingview.com/script/6Sz5bNJr-Rupee-Volume-SL-Distance/
- type: indicator
- pine_id: PUB;964ab326fa7e4a30bea9337eccc02ee2
- version: 1.0

## Description

This indicator shows three things in a single row at the bottom of your chart:

**₹ Vol** — Today's cumulative rupee volume (price × volume), auto-formatted in Crores or Lakhs. Resets each new trading day.

**TDY Low %** — How far the current price is above today's low, as a percentage. Helps you gauge SL risk if you're using today's low as your stop.

**PRV Low %** — Same calculation but against yesterday's low. Useful when today's low is too tight and you want a wider SL at the previous day's low.

Both SL distances update in real-time so you can skip the manual math and decide your stop level at a glance.

## Source Code

````pine
//@version=6
indicator('₹ Volume + SL Distance', overlay = true)

// ─── Format rupee ─────────────────────────────────────────
formatRupee(x) =>
    x >= 1e7 ? str.tostring(x / 1e7, '#.##') + ' Cr' : x >= 1e5 ? str.tostring(x / 1e5, '#.##') + ' L' : str.tostring(x, '#')

// ─── Rupee Volume ─────────────────────────────────────────
currentDay = year * 10000 + month * 100 + dayofmonth
rupeeBar = volume * close

var float totalRupee = na
var int lastDay = na
if na(lastDay) or currentDay != lastDay
    totalRupee := rupeeBar
    lastDay := currentDay
    lastDay
else
    totalRupee := totalRupee + rupeeBar
    totalRupee

// ─── SL Distance % ───────────────────────────────────────
todayLow = request.security(syminfo.tickerid, 'D', low)
prevDayLow = request.security(syminfo.tickerid, 'D', low[1])

pctToday = (close - todayLow) / close * 100
pctPrev = (close - prevDayLow) / close * 100

// ─── Single Table ─────────────────────────────────────────
var table t = table.new(position.bottom_center, 3, 1, border_width = 1)

if barstate.islast
    table.cell(t, 0, 0, '₹ Vol: ' + formatRupee(totalRupee), text_color = color.white, bgcolor = color.new(color.blue, 80), text_size = size.normal)
    table.cell(t, 1, 0, 'TDY Low: ' + str.tostring(pctToday, '#.##') + ' %', text_color = color.teal, bgcolor = #1e1e2f, text_size = size.normal)
    table.cell(t, 2, 0, 'PRV Low: ' + str.tostring(pctPrev, '#.##') + ' %', text_color = color.orange, bgcolor = #1e1e2f, text_size = size.normal)
````
