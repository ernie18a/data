# Manas - MTF EMA 21/50/200 + VWAP

- url: https://www.tradingview.com/script/9Dzhawv6-Manas-MTF-EMA-21-50-200-VWAP/
- type: indicator
- pine_id: PUB;3f8f4c3fa8404d8fb03a196e14fddeaa
- version: 1.0

## Description

100 % trend following pine script with improved version

## Source Code

````pine
//@version=5
indicator("MTF EMA 21/50/200 + VWAP", overlay=true)

// ===== EMA + VWAP =====
ema9_line   = ta.ema(close, 9)
ema21_line  = ta.ema(close, 21)
ema50_line  = ta.ema(close, 50)
ema200_line = ta.ema(close, 200)
vwap_line   = ta.vwap(hlc3)

// ===== PLOTS =====
plot(ema9_line, color=color.blue, title="EMA 9", linewidth=1)
plot(ema21_line, color=color.orange, title="EMA 21", linewidth=1)
plot(ema50_line, color=color.green, title="EMA 50", linewidth=1)
plot(ema200_line, color=color.red, title="EMA 200", linewidth=1)
plot(vwap_line, color=color.purple, title="VWAP", linewidth=2)

// ===== FUNCTION =====
getData(tf) =>
    price = request.security(syminfo.tickerid, tf, close)
    ema50 = request.security(syminfo.tickerid, tf, ta.ema(close, 50))
    ema200 = request.security(syminfo.tickerid, tf, ta.ema(close, 200))
    vwap = request.security(syminfo.tickerid, tf, ta.vwap(hlc3))
    [price, ema50, ema200, vwap]

// ===== DATA =====
[p4h, ema50_4h, ema200_4h, vwap_4h] = getData("240")
[p1h, ema50_1h, ema200_1h, vwap_1h] = getData("60")
[p15m, ema50_15m, ema200_15m, vwap_15m] = getData("15")
[p5m, ema50_5m, ema200_5m, vwap_5m] = getData("5")

// ===== CONDITIONS =====
cond(p, e) =>
    p > e ? "Above" : "Below"

getColor(p, e) =>
    p > e ? color.green : color.red

trend(p, e50, e200, v) =>
    result = "Mixed"
    if (p > e50 and p > e200 and p > v)
        result := "Strong Bull"
    else if (p < e50 and p < e200 and p < v)
        result := "Strong Bear"
    result

trendColor(p, e50, e200, v) =>
    col = color.orange
    if (p > e50 and p > e200 and p > v)
        col := color.green
    else if (p < e50 and p < e200 and p < v)
        col := color.red
    col

// ===== TABLE =====
var table t = table.new(position.top_right, 5, 5, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "TF", text_color=color.yellow, bgcolor=color.black, text_size=size.tiny)
    table.cell(t, 1, 0, "EMA50", text_color=color.yellow, bgcolor=color.black, text_size=size.tiny)
    table.cell(t, 2, 0, "EMA200", text_color=color.yellow, bgcolor=color.black, text_size=size.tiny)
    table.cell(t, 3, 0, "VWAP", text_color=color.yellow, bgcolor=color.black, text_size=size.tiny)
    table.cell(t, 4, 0, "Trend", text_color=color.yellow, bgcolor=color.black, text_size=size.tiny)

    // 4H
    table.cell(t, 0, 1, "4H", text_size=size.tiny)
    table.cell(t, 1, 1, cond(p4h, ema50_4h), text_color=getColor(p4h, ema50_4h), text_size=size.tiny)
    table.cell(t, 2, 1, cond(p4h, ema200_4h), text_color=getColor(p4h, ema200_4h), text_size=size.tiny)
    table.cell(t, 3, 1, cond(p4h, vwap_4h), text_color=getColor(p4h, vwap_4h), text_size=size.tiny)
    table.cell(t, 4, 1, trend(p4h, ema50_4h, ema200_4h, vwap_4h), text_color=trendColor(p4h, ema50_4h, ema200_4h, vwap_4h), text_size=size.tiny)

    // 1H
    table.cell(t, 0, 2, "1H", text_size=size.tiny)
    table.cell(t, 1, 2, cond(p1h, ema50_1h), text_color=getColor(p1h, ema50_1h), text_size=size.tiny)
    table.cell(t, 2, 2, cond(p1h, ema200_1h), text_color=getColor(p1h, ema200_1h), text_size=size.tiny)
    table.cell(t, 3, 2, cond(p1h, vwap_1h), text_color=getColor(p1h, vwap_1h), text_size=size.tiny)
    table.cell(t, 4, 2, trend(p1h, ema50_1h, ema200_1h, vwap_1h), text_color=trendColor(p1h, ema50_1h, ema200_1h, vwap_1h), text_size=size.tiny)

    // 15M
    table.cell(t, 0, 3, "15M", text_size=size.tiny)
    table.cell(t, 1, 3, cond(p15m, ema50_15m), text_color=getColor(p15m, ema50_15m), text_size=size.tiny)
    table.cell(t, 2, 3, cond(p15m, ema200_15m), text_color=getColor(p15m, ema200_15m), text_size=size.tiny)
    table.cell(t, 3, 3, cond(p15m, vwap_15m), text_color=getColor(p15m, vwap_15m), text_size=size.tiny)
    table.cell(t, 4, 3, trend(p15m, ema50_15m, ema200_15m, vwap_15m), text_color=trendColor(p15m, ema50_15m, ema200_15m, vwap_15m), text_size=size.tiny)

    // 5M
    table.cell(t, 0, 4, "5M", text_size=size.tiny)
    table.cell(t, 1, 4, cond(p5m, ema50_5m), text_color=getColor(p5m, ema50_5m), text_size=size.tiny)
    table.cell(t, 2, 4, cond(p5m, ema200_5m), text_color=getColor(p5m, ema200_5m), text_size=size.tiny)
    table.cell(t, 3, 4, cond(p5m, vwap_5m), text_color=getColor(p5m, vwap_5m), text_size=size.tiny)
    table.cell(t, 4, 4, trend(p5m, ema50_5m, ema200_5m, vwap_5m), text_color=trendColor(p5m, ema50_5m, ema200_5m, vwap_5m), text_size=size.tiny)
````
