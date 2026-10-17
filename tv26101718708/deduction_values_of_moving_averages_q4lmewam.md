# deduction values of moving averages

- url: https://www.tradingview.com/script/Q4lmEWaM/
- type: indicator
- pine_id: PUB;b70bb74df3ae4cb8976d38235fe4c5bb
- version: 1.0

## Description

均線扣抵值表格

本指標用於顯示不同週期均線的「扣抵值」，包含 MA5、MA10、MA20、MA60、MA120、MA240 等常用均線。

所謂均線扣抵值，是指該條均線在下一根 K 棒更新時，即將被移出平均計算的舊收盤價。例如 MA20 的扣抵值為 19 根 K 棒以前的收盤價。

當目前價格高於扣抵值，代表新價格高於即將被扣除的舊價格，均線較容易上彎，屬於「扣低助漲」；反之，當目前價格低於扣抵值，代表均線較容易下彎，屬於「扣高助跌」。

本指標可協助投資人快速判斷短、中、長期均線的支撐力道、轉折方向與趨勢延續性，適合用於盤中觀察、波段交易與趨勢判斷。

-----

This indicator displays the deduction values of commonly used moving averages, including MA5, MA10, MA20, MA60, MA120, and MA240.

The moving average deduction value refers to the old closing price that will be removed from the moving average calculation when the next candle is formed. For example, the MA20 deduction value is the closing price from 19 bars ago.

When the current price is above the deduction value, the new price is higher than the old price being removed, which makes the moving average more likely to turn upward. This is generally considered a bullish deduction structure.

When the current price is below the deduction value, the new price is lower than the old price being removed, making the moving average more likely to turn downward. This is generally considered a bearish deduction structure.

This indicator helps traders quickly evaluate the support strength, turning direction, and trend continuity of short-, medium-, and long-term moving averages. It can be useful for intraday monitoring, swing trading, and trend-following analysis.

## Source Code

````pine
//@version=5
indicator("均線扣抵值表格", overlay=true)

ma5 = ta.sma(close, 5)
ma10 = ta.sma(close, 10)
ma20 = ta.sma(close, 20)
ma60 = ta.sma(close, 60)

d5 = close[4]
d10 = close[9]
d20 = close[19]
d60 = close[59]

status(d) =>
    close > d ? "扣低助漲 ↑" : close < d ? "扣高助跌 ↓" : "持平"

var table t = table.new(position.top_right, 4, 5, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "週期", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, "均線", text_color=color.white, bgcolor=color.black)
    table.cell(t, 2, 0, "扣抵值", text_color=color.white, bgcolor=color.black)
    table.cell(t, 3, 0, "狀態", text_color=color.white, bgcolor=color.black)

    table.cell(t, 0, 1, "MA5")
    table.cell(t, 1, 1, str.tostring(ma5, format.mintick))
    table.cell(t, 2, 1, str.tostring(d5, format.mintick))
    table.cell(t, 3, 1, status(d5), text_color=close > d5 ? color.red : color.green)

    table.cell(t, 0, 2, "MA10")
    table.cell(t, 1, 2, str.tostring(ma10, format.mintick))
    table.cell(t, 2, 2, str.tostring(d10, format.mintick))
    table.cell(t, 3, 2, status(d10), text_color=close > d10 ? color.red : color.green)

    table.cell(t, 0, 3, "MA20")
    table.cell(t, 1, 3, str.tostring(ma20, format.mintick))
    table.cell(t, 2, 3, str.tostring(d20, format.mintick))
    table.cell(t, 3, 3, status(d20), text_color=close > d20 ? color.red : color.green)

    table.cell(t, 0, 4, "MA60")
    table.cell(t, 1, 4, str.tostring(ma60, format.mintick))
    table.cell(t, 2, 4, str.tostring(d60, format.mintick))
    table.cell(t, 3, 4, status(d60), text_color=close > d60 ? color.red : color.green)
````
