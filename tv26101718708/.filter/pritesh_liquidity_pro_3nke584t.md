# Pritesh Liquidity PRO

- url: https://www.tradingview.com/script/3Nke584T-Pritesh-Liquidity-PRO/
- type: indicator
- pine_id: PUB;439b1024e3fa41b3a28c80e41a6fda4a
- version: 1.0

## Description

Intraday vols for episodic pivot which tells liquidity

## Source Code

````pine
//@version=6
indicator("Pritesh Liquidity PRO", overlay=false)

// === INPUT ===
len = input.int(20, "Avg Volume Length")

// === CALCULATIONS ===
avg_vol = ta.sma(volume, len)
rel_vol = avg_vol != 0 ? volume / avg_vol : 0
rel_vol_pct = rel_vol * 100

traded_value = volume * open

// === FORMAT FUNCTIONS (NO TERNARY = NO ERROR) ===
format_vol(v) =>
    string result = ""
    if v >= 1000000
        result := str.tostring(v / 1000000, "#.#") + "M"
    else if v >= 1000
        result := str.tostring(v / 1000, "#.#") + "K"
    else
        result := str.tostring(v)
    result

format_rs(v) =>
    string result = ""
    if v >= 10000000
        result := str.tostring(v / 10000000, "#.#") + "Cr"
    else if v >= 100000
        result := str.tostring(v / 100000, "#.#") + "L"
    else if v >= 1000
        result := str.tostring(v / 1000, "#.#") + "K"
    else
        result := str.tostring(v, "#.##")
    result

// === COLORS ===
volColor = close > open ? color.lime : close < open ? color.red : color.gray

// === PLOTS ===
plot(volume, title="Volume", style=plot.style_columns, color=volColor)
plot(rel_vol_pct, title="Rel Vol %", color=color.yellow)

// === TABLE ===
var table t = table.new(position.top_right, 2, 4)

if barstate.islast
    table.cell(t, 0, 0, "Pritesh", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 1, 0, "Liquidity", bgcolor=color.blue, text_color=color.white)

    table.cell(t, 0, 1, "1m Vol")
    table.cell(t, 1, 1, format_vol(volume))

    table.cell(t, 0, 2, "₹ Liq")
    table.cell(t, 1, 2, format_rs(traded_value))

    table.cell(t, 0, 3, "Rel %")
    table.cell(t, 1, 3, str.tostring(rel_vol_pct, "#.##"),
         text_color = rel_vol_pct > 200 ? color.lime : color.red)
````
