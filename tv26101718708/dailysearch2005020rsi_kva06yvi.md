# daily_search_200_50_20_RSI

- url: https://www.tradingview.com/script/kva06yVi-daily-search-200-50-20-RSI/
- type: indicator
- pine_id: PUB;2b229567a95c4016ab01ee53d0e68f7b
- version: 1.0

## Description

I found the key detail. A script published with the "Private" setting is not available in the Community scripts feed, and the script widget is visible only to the author, from their profile's Scripts tab. Other users cannot see the script widget. TradingView

## Source Code

````pine
//@version=6
indicator('daily_search_200_50_20_RSI', overlay = false)

// ── Global Variables ─────────────────────────────────────────────────────────
candles_back = input.int(10, 'Candles to Scan Backwards', minval = 1, maxval = 50)
drop_threshold = input.int(3, 'Drop Threshold (min drops)', minval = 1, maxval = 20)
rsi_length = input.int(8, 'RSI Length', minval = 1)
rsi_level = input.float(50.0, 'RSI Level', minval = 1, maxval = 100)
rsi_source = input.source(close, 'RSI Source')

// ── Indicators ───────────────────────────────────────────────────────────────
ma200 = ta.sma(close, 200)
ma50 = ta.sma(close, 50)
ma20 = ta.sma(close, 20)
rsi = ta.rsi(rsi_source, rsi_length)

// ── Candle Midpoint ───────────────────────────────────────────────────────────
mid(i) =>
    (open[i] + close[i]) / 2

// ── Dropping Candle Check ─────────────────────────────────────────────────────
// Count how many candles in the lookback window have a lower midpoint than the previous
drop_count = 0
for i = 0 to candles_back - 1 by 1
    if mid(i) < mid(i + 1)
        drop_count := drop_count + 1
        drop_count

// True if drop count meets or exceeds the threshold
dropping = drop_count >= drop_threshold

// ── Conditions ───────────────────────────────────────────────────────────────
condition = dropping and close <= ma20 and rsi < rsi_level

// ── Output ───────────────────────────────────────────────────────────────────
signal = condition ? 1 : 0

plot(signal, title = 'Signal (1=True / 0=False)', color = condition ? color.green : color.red, style = plot.style_histogram, linewidth = 2)

bgcolor(condition ? color.new(color.green, 85) : na, title = 'Condition True')

alertcondition(condition, title = 'daily_search_200_50_20_RSI Alert', message = 'daily_search_200_50_20_RSI: All conditions met — drop threshold reached, price ≤ MA20, MA20 < MA50, RSI < level')
````
