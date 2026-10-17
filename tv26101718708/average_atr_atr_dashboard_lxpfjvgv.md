# Average ATR & ATR% Dashboard

- url: https://www.tradingview.com/script/LXpfJVGV/
- type: indicator
- pine_id: PUB;5421f2d73f6c46a2b9548b27056cdee2
- version: 1.0

## Description

Average ATR & ATR% Dashboard v26.5.24
Average ATR & ATR% Dashboard v26.5.24
Average ATR & ATR% Dashboard v26.5.24

## Source Code

````pine
//@version=6
indicator("Average ATR & ATR% Dashboard", overlay = true)

// === Inputs ===
len1 = input.int(8, "週期 1", minval = 1)
len2 = input.int(22, "週期 2", minval = 1)
len3 = input.int(60, "週期 3", minval = 1)
len4 = input.int(180, "週期 4", minval = 1)

maMethod = input.string(
     "RMA / Wilder",
     "平均方式",
     options = ["RMA / Wilder", "SMA"]
)

// === Colors ===
headerBg = color.rgb(30, 30, 30)
bodyBg   = color.rgb(45, 45, 45)
txtColor = color.white

// === True Range ===
tr = ta.tr(true)

// === Moving average function ===
// RMA / Wilder 接近 TradingView 標準 ATR 算法
f_ma(src, len) =>
    maMethod == "SMA" ? ta.sma(src, len) : ta.rma(src, len)

// === Average ATR ===
atr1 = f_ma(tr, len1)
atr2 = f_ma(tr, len2)
atr3 = f_ma(tr, len3)
atr4 = f_ma(tr, len4)

// === Average ATR% ===
// 每根 K 棒先用當根 TR / 當根 close 算百分比，再做平均。
// 不是用「平均 ATR / 最新 close」。
trPct = close != 0 ? tr / close * 100 : na

atrPct1 = f_ma(trPct, len1)
atrPct2 = f_ma(trPct, len2)
atrPct3 = f_ma(trPct, len3)
atrPct4 = f_ma(trPct, len4)

// === Formatting ===
f_price(x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_pct(x) =>
    na(x) ? "n/a" : str.tostring(x, "#.##") + "%"

// === Table ===
var table t = table.new(
     position.top_right,
     3,
     5,
     border_width = 1,
     frame_color = color.gray,
     border_color = color.gray
)

if barstate.islast
    // Header
    table.cell(t, 0, 0, "週期", text_color = txtColor, bgcolor = headerBg, text_size = size.normal)
    table.cell(t, 1, 0, "平均 ATR", text_color = txtColor, bgcolor = headerBg, text_size = size.normal)
    table.cell(t, 2, 0, "平均 ATR%", text_color = txtColor, bgcolor = headerBg, text_size = size.normal)

    // Row 1
    table.cell(t, 0, 1, str.tostring(len1) + " 根K", text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 1, 1, f_price(atr1), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 2, 1, f_pct(atrPct1), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)

    // Row 2
    table.cell(t, 0, 2, str.tostring(len2) + " 根K", text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 1, 2, f_price(atr2), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 2, 2, f_pct(atrPct2), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)

    // Row 3
    table.cell(t, 0, 3, str.tostring(len3) + " 根K", text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 1, 3, f_price(atr3), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 2, 3, f_pct(atrPct3), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)

    // Row 4
    table.cell(t, 0, 4, str.tostring(len4) + " 根K", text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 1, 4, f_price(atr4), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(t, 2, 4, f_pct(atrPct4), text_color = txtColor, bgcolor = bodyBg, text_size = size.normal)
````
