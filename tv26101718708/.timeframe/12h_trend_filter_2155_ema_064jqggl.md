# 12H Trend Filter (21/55 EMA)

- url: https://www.tradingview.com/script/064JQGGl-12H-Trend-Filter-21-55-EMA/
- type: indicator
- pine_id: PUB;06b4d925569a402d86bb4f82fcd8e812
- version: 1.0

## Description

12H Trend Filter (21/55 EMA)

Displays the 12-hour timeframe trend direction directly on your 5-minute chart. Shows a green column when the 12H 21 EMA is above the 12H 55 EMA (uptrend) and a red column when it's below (downtrend). Outputs a clean 1/-1 value making it easy to use as a filter column in a dataset or backtesting spreadsheet. Includes background shading on the price chart and built-in alerts for when the 6H trend flips direction.

## Source Code

````pine
//@version=5
indicator(title="12H Trend Filter (21/55 EMA)", shorttitle="12H Trend", overlay=false)

// Inputs
ema_fast_len = input.int(21, "Fast EMA")
ema_slow_len = input.int(55, "Slow EMA")

// Pull 12H EMAs into 5min chart
ema21_12h = request.security(syminfo.tickerid, "720", ta.ema(close, ema_fast_len), lookahead=barmerge.lookahead_off)
ema55_12h = request.security(syminfo.tickerid, "720", ta.ema(close, ema_slow_len), lookahead=barmerge.lookahead_off)

// Trend state
uptrend = ema21_12h > ema55_12h
downtrend = ema21_12h < ema55_12h
trend_value = uptrend ? 1 : downtrend ? -1 : 0

// Plot columns
plot(trend_value, title="12H Trend (1=Up / -1=Down)", color=trend_value == 1 ? color.lime : color.red, style=plot.style_columns, linewidth=4)

// Reference lines
hline(0, "Neutral", color=color.gray, linestyle=hline.style_dashed)
hline(1, "Uptrend", color=color.lime, linestyle=hline.style_dotted)
hline(-1, "Downtrend", color=color.red, linestyle=hline.style_dotted)

// Background on price chart
bgcolor(uptrend ? color.new(color.lime, 92) : downtrend ? color.new(color.red, 92) : na, title="12H Trend Background")

// Label
var label info_label = na
label.delete(info_label)
status_txt = uptrend ? "UP" : downtrend ? "DOWN" : "NEUTRAL"
label_col = uptrend ? color.lime : downtrend ? color.red : color.gray
info_label := label.new(x=bar_index, y=trend_value, text=status_txt + "\nEMA21: " + str.tostring(math.round(ema21_12h, 2)) + "\nEMA55: " + str.tostring(math.round(ema55_12h, 2)), color=color.new(label_col, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)

// Alerts
alertcondition(ta.crossover(ema21_12h, ema55_12h), title="12H Turned BULLISH", message="12H EMA21 crossed above EMA55 - trend is now UP")
alertcondition(ta.crossunder(ema21_12h, ema55_12h), title="12H Turned BEARISH", message="12H EMA21 crossed below EMA55 - trend is now DOWN")
````
