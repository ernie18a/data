# ZT Swing Scan

- url: https://www.tradingview.com/script/HONxHEen-ZT-Swing-Scan/
- type: indicator
- pine_id: PUB;7dc574aa26f24fe9a7298af1649a3eb6
- version: 1.0

## Description

This shows possible swing trade setups based on the Daily 20, 50, 100, 200

## Source Code

````pine
//@version=6
indicator("ZT Swing Scan", overlay=false, max_bars_back=500)

// ── INPUTS
prox = input.float(1.5, "SMA Proximity %", minval=0.1, maxval=5.0)

// ── SMAs
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)

// ── PROXIMITY FUNCTION
near(level) =>
    math.abs(close - level) / level * 100 <= prox

// ── SMA CONDITIONS
aboveD20  = close > sma20
bounce20  = aboveD20 and near(sma20)
bounce50  = not aboveD20 and near(sma50)
bounce100 = not aboveD20 and near(sma100)
bounce200 = not aboveD20 and near(sma200)
smaTrigger = bounce20 or bounce50 or bounce100 or bounce200

// ── MACD ZERO CROSS
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
macdCrossBelow0 = ta.crossunder(macdLine, 0)

// ── FINAL SIGNAL (OR)
signal = smaTrigger or macdCrossBelow0

// ── SCREENER OUTPUT
plot(signal          ? 1 : 0, "Signal",     color = color.new(color.yellow, 0))
plot(smaTrigger      ? 1 : 0, "SMA Bounce", color = color.new(color.green,  0))
plot(macdCrossBelow0 ? 1 : 0, "MACD Zero",  color = color.new(color.red,    0))

// ── SMA LABEL
smaLabel = bounce20  ? "Near D20"  :
           bounce50  ? "Near D50"  :
           bounce100 ? "Near D100" :
           bounce200 ? "Near D200" : "—"

// ── VISUAL TABLE
var table t = table.new(position.top_right, 2, 5,
     bgcolor      = color.new(color.black, 70),
     border_width = 1,
     border_color = color.new(color.gray, 50))

if barstate.islast
    table.cell(t, 0, 0, "Condition",
         text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 0, "Status",
         text_color = color.gray,  text_size = size.small)
    table.cell(t, 0, 1, "SMA Level",
         text_color = color.white, text_size = size.small)
    table.cell(t, 1, 1, smaLabel,
         text_color = smaTrigger ? color.green : color.gray, text_size = size.small)
    table.cell(t, 0, 2, "MACD Below 0",
         text_color = color.white, text_size = size.small)
    table.cell(t, 1, 2, macdCrossBelow0 ? "NOW" : "—",
         text_color = macdCrossBelow0 ? color.red : color.gray, text_size = size.small)
    table.cell(t, 0, 3, "Proximity %",
         text_color = color.white, text_size = size.small)
    table.cell(t, 1, 3, str.tostring(prox) + "%",
         text_color = color.yellow, text_size = size.small)
    table.cell(t, 0, 4, "SIGNAL",
         text_color = color.white, text_size = size.small)
    table.cell(t, 1, 4, signal ? "ACTIVE" : "none",
         text_color = signal ? color.yellow : color.gray, text_size = size.small)

// ── ALERTS
alertcondition(signal,
     title   = "Swing Signal",
     message = "{{ticker}} — Swing condition triggered on Daily")
alertcondition(macdCrossBelow0,
     title   = "MACD Crossed Below Zero",
     message = "{{ticker}} — MACD crossed below 0 on Daily")
alertcondition(smaTrigger,
     title   = "SMA Bounce Zone",
     message = "{{ticker}} — Price near key SMA on Daily")
````
