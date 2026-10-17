# CNPS Bollinger Band

- url: https://www.tradingview.com/script/YbEXkbBd-CNPS-Bollinger-Band/
- type: strategy
- pine_id: PUB;616d1d55c5df4b1e9a4c24a25190ca4b
- version: 1.0

## Description

CNPS-Bollinger Band is a trend-following trading system applied to VN30F1M Index Futures Contracts.

1. Long order activation:
Open Long: Closing price > Upper Bollinger Band (20,2)
Close Long: Closing price < Lower Bollinger Band (20,2) or price hits SL/TP.

2. Short order activation:

Open Short: Closing price < Lower Bollinger Band (20,2)
Close Sell: Closing price > Upper Bollinger Band (20,2) or price hits SL/TP.

3. A compatible version can be found on Entrade's Avatar bot platform.

Log in to Entrade to copy and use it for free now: https://avatar.entrade.com.vn/dang-nhap

## Source Code

````pine
//Tác giả: https://phaisinh.online/
//Nhóm cộng đồng: https://zalo.me/g/jvaykb078
//@version=5
strategy("CNPS-Bollinger Band", overlay=true)

// ==== INPUT ====
length = input.int(20, "BB Length")
mult   = input.float(2.0, "BB Multiplier")

qty = input.int(1, "Contracts")
sl_points = input.float(10, "Stop Loss (points)")

tradeDirection = input.string("Mua & Bán", "Chiều giao dịch",
     options = ["Mua", "Bán", "Mua & Bán"])

// ==== BOLLINGER BANDS ====
basis = ta.sma(close, length)
dev   = mult * ta.stdev(close, length)

upper = basis + dev
lower = basis - dev

// ==== PLOT BB ====
plot(basis, "BB Basis", color=color.orange)
plot(upper, "BB Upper", color=color.blue)
plot(lower, "BB Lower", color=color.blue)

// ==== ENTRY CONDITIONS ====
longCondition  = close > upper
shortCondition = close < lower

if (tradeDirection == "Mua" or tradeDirection == "Mua & Bán") and longCondition
    strategy.entry("Long", strategy.long, qty=qty)

if (tradeDirection == "Bán" or tradeDirection == "Mua & Bán") and shortCondition
    strategy.entry("Short", strategy.short, qty=qty)

// ==== STOP LOSS ====
long_sl  = strategy.position_avg_price - sl_points
short_sl = strategy.position_avg_price + sl_points

strategy.exit("Long SL",  from_entry="Long",  stop=long_sl)
strategy.exit("Short SL", from_entry="Short", stop=short_sl)

// ==== EXIT CONDITIONS ====
long_exit_signal  = close < lower
short_exit_signal = close > upper

if strategy.position_size > 0 and long_exit_signal
    strategy.close("Long")

if strategy.position_size < 0 and short_exit_signal
    strategy.close("Short")

// ==== PLOT STOP LOSS ====
plot(strategy.position_size > 0 ? long_sl : na, "Long SL", color=color.red, style=plot.style_linebr)
plot(strategy.position_size < 0 ? short_sl : na, "Short SL", color=color.red, style=plot.style_linebr)
````
