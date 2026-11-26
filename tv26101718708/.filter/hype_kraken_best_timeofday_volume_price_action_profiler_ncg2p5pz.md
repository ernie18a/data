# HYPE / Kraken: Best Time-of-Day (Volume + Price Action Profiler)

- url: https://www.tradingview.com/script/ncg2P5pZ-HYPE-Kraken-Best-Time-of-Day-Volume-Price-Action-Profiler/
- type: indicator
- pine_id: PUB;f74af54d4562418ab51ae6699eda89cc
- version: 1.0

## Description

This script analyzes KRAKEN:HYPEUSD historical intraday behavior by time of day. It groups past candles into hourly buckets and ranks each hour using volume, price range, or a combined Volume × Range score.

The goal is to help traders identify when HYPE has historically shown the strongest combination of liquidity and price movement, as well as which hours tend to be slower or lower quality.

Recommended use: apply it on the 15-minute timeframe for KRAKEN:HYPEUSD. The table shows each hour in the selected timezone, with rankings and quality labels such as Prime, Good, Normal, or Slow.

This is not a buy/sell signal. It is a time-of-day profiling tool designed to help traders plan when to focus, when to monitor, and when to avoid low-quality market conditions.

Cheers!

## Source Code

````pine
//@version=6

indicator("HYPE Kraken Time-of-Day Volume + Price Action Profiler", overlay=false, max_labels_count=500)

// ─────────────────────────────────────────────

// Inputs

// ─────────────────────────────────────────────

tzInput = input.string("America/Los_Angeles", "Display Timezone", options=["Etc/UTC", "America/Los_Angeles", "America/New_York", "Europe/London", "Asia/Tokyo"])

metricChoice = input.string("Volume x Range", "Ranking Metric", options=["Volume", "Range %", "Volume x Range"])

minBarsPerHour = input.int(10, "Minimum Bars Per Hour", minval=1)

showTable = input.bool(true, "Show Time-of-Day Table")

// ─────────────────────────────────────────────

// 24 hourly buckets

// ─────────────────────────────────────────────

var float[] volSum = array.new_float(24, 0.0)

var float[] rangeSum = array.new_float(24, 0.0)

var float[] scoreSum = array.new_float(24, 0.0)

var int[] barCount = array.new_int(24, 0)

// ─────────────────────────────────────────────

// Per-bar calculations

// ─────────────────────────────────────────────

barHour = hour(time, tzInput)

rangePct = close != 0.0 ? ((high - low) / close) * 100.0 : 0.0

score = volume * rangePct

if barstate.isconfirmed

    array.set(volSum, barHour, array.get(volSum, barHour) + volume)

    array.set(rangeSum, barHour, array.get(rangeSum, barHour) + rangePct)

    array.set(scoreSum, barHour, array.get(scoreSum, barHour) + score)

    array.set(barCount, barHour, array.get(barCount, barHour) + 1)

// ─────────────────────────────────────────────

// Helper functions

// ─────────────────────────────────────────────

f_avgVol(int h) =>

    c = array.get(barCount, h)

    c > 0 ? array.get(volSum, h) / c : na

f_avgRange(int h) =>

    c = array.get(barCount, h)

    c > 0 ? array.get(rangeSum, h) / c : na

f_avgScore(int h) =>

    c = array.get(barCount, h)

    c > 0 ? array.get(scoreSum, h) / c : na

f_metric(int h) =>

    metricChoice == "Volume" ? f_avgVol(h) : metricChoice == "Range %" ? f_avgRange(h) : f_avgScore(h)

f_hourLabel(int h) =>

    nextH = h == 23 ? 0 : h + 1

    str.format("{0,number,00}:00-{1,number,00}:00", h, nextH)

f_rank(int h) =>

    myVal = f_metric(h)

    rank = 1

    if not na(myVal)

        for j = 0 to 23

            otherVal = f_metric(j)

            if not na(otherVal) and otherVal > myVal

                rank += 1

    rank

f_quality(int rank, int bars) =>

    bars < minBarsPerHour ? "Low data" : rank <= 3 ? "Prime" : rank <= 6 ? "Good" : rank <= 12 ? "Normal" : "Slow"

// ─────────────────────────────────────────────

// Table

// ─────────────────────────────────────────────

var table todTable = table.new(position.top_right, 6, 26, border_width=1)

if barstate.islast and showTable

    table.clear(todTable, 0, 0)

    table.cell(todTable, 0, 0, "Rank", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 1, 0, "Hour", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 2, 0, "Avg Vol", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 3, 0, "Avg Range %", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 4, 0, "Vol x Range", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 5, 0, "Quality", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    for h = 0 to 23

        r = f_rank(h)

        c = array.get(barCount, h)

        av = f_avgVol(h)

        ar = f_avgRange(h)

        sc = f_avgScore(h)

        q = f_quality(r, c)

        rowColor = r <= 3 ? color.new(color.green, 72) : r <= 6 ? color.new(color.green, 86) : r <= 12 ? color.new(color.gray, 88) : color.new(color.red, 88)

        table.cell(todTable, 0, h + 1, str.tostring(r), bgcolor=rowColor)

        table.cell(todTable, 1, h + 1, f_hourLabel(h), bgcolor=rowColor)

        table.cell(todTable, 2, h + 1, na(av) ? "n/a" : str.tostring(av, format.volume), bgcolor=rowColor)

        table.cell(todTable, 3, h + 1, na(ar) ? "n/a" : str.tostring(ar, "#.###") + "%", bgcolor=rowColor)

        table.cell(todTable, 4, h + 1, na(sc) ? "n/a" : str.tostring(sc, format.volume), bgcolor=rowColor)

        table.cell(todTable, 5, h + 1, q, bgcolor=rowColor)

    table.cell(todTable, 0, 25, "Symbol", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 1, 25, syminfo.ticker, text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 2, 25, "TF", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 3, 25, timeframe.period, text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 4, 25, "TZ", text_color=color.white, bgcolor=color.rgb(30, 30, 30))

    table.cell(todTable, 5, 25, tzInput, text_color=color.white, bgcolor=color.rgb(30, 30, 30))

// ─────────────────────────────────────────────

// Plot current hour historical score

// ─────────────────────────────────────────────

currentHourAvgScore = f_avgScore(barHour)

plot(currentHourAvgScore, "Current Hour Historical Vol x Range Score", linewidth=2)
````
