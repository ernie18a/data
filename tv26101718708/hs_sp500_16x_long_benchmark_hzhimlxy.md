# HS SP500 1.6x Long Benchmark

- url: https://www.tradingview.com/script/HZhiMLXY-HS-SP500-1-6x-Long-Benchmark/
- type: strategy
- pine_id: PUB;019c6293946440459e46b0533008bf98
- version: 1.0

## Description

Long-only SP500 benchmark strategy using 160% notional exposure.

This is not a predictive trading signal. It is a transparent leveraged benchmark designed to compare 1.6x long SP500 exposure against TradingView’s Buy & Hold benchmark over the same historical window.

Backtest target used:
VANTAGE:SP500, 4h, Mar 16, 2018 to May 26, 2026.

The strategy models:
160% of equity position sizing, 0.075% commission, 2 ticks slippage, and 50% long margin.

Expected behavior: if applied to the same SP500 chart and date window, it should outperform 1x Buy & Hold by roughly the leverage factor, while also carrying larger drawdowns and margin risk.

## Source Code

````pine
// Educational benchmark only. Not investment advice.
//@version=6
strategy("HS SP500 1.6x Long Benchmark", shorttitle="HS SPX 1.6x Long", overlay=true, initial_capital=10000, pyramiding=0, default_qty_type=strategy.percent_of_equity, default_qty_value=160, commission_type=strategy.commission.percent, commission_value=0.075, slippage=2, margin_long=50, margin_short=100, process_orders_on_close=true)

startTime = input.time(1521158400000, "Backtest start")
endTime = input.time(1779753600000, "Backtest end")

inWindow = time >= startTime and time <= endTime

if inWindow and strategy.position_size <= 0
    strategy.entry("1.6x SP500 Long", strategy.long)

if not inWindow and strategy.position_size > 0
    strategy.close("1.6x SP500 Long")
````
