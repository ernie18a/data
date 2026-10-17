# SuperTrend STRATEGY

- url: https://www.tradingview.com/script/VLRj2sG9-SuperTrend-STRATEGY/
- type: strategy
- pine_id: PUB;d6fba11d365a42f89f44000bc678d087
- version: 4.0

## Description

[b]SuperTrend Strategy (Long Only)[/b]
A streamlined, long-only implementation of the classic SuperTrend indicator designed for trend-following entries and exits.

[b]How It Works[/b]
This strategy identifies uptrend reversals using the SuperTrend algorithm and enters long positions accordingly. When the trend flips bearish, the position is closed — no short entries are taken. This makes it ideal for spot trading or accounts that do not permit shorting.

[b]Core Logic[/b]
[list]
[*]ATR is calculated using a Simple Moving Average (SMA) of True Range for more responsive volatility tracking.
[*]A long entry is triggered when the SuperTrend flips from bearish to bullish.
[*]The position is closed when the SuperTrend flips back to bearish.
[*]"Buy" and "Close" labels are plotted on the chart for clear visual reference.
[/list]

[b]Default Settings[/b]
[list]
[*]ATR Period: 10
[*]ATR Multiplier: 3.0
[*]Source: hl2
[*]Initial Capital: $10,000
[*]Position Size: 100% of equity
[*]Commission: 0.015%
[/list]

[b]Backtest Window[/b]
A customizable date range filter is included, allowing you to evaluate performance over specific periods.

[b]Notes[/b]
[list]
[*]This strategy is intended for educational and backtesting purposes only. Past performance does not guarantee future results.
[*]Works across all asset classes and timeframes. Adjust ATR Period and Multiplier to suit your preferred market and trading style.
[/list]

## Source Code

````pine
// SuperTrend STRATEGY made by Slow Cow

//@version=6
strategy("SuperTrend STRATEGY", overlay=true, initial_capital=10000000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.015, currency=currency.NONE, process_orders_on_close=true)

Periods    = input.int(10, title="ATR Period")
src        = input(hl2, title="Source")
Multiplier = input.float(8.5, title="ATR Multiplier", step=0.1)

atrVal = ta.sma(ta.tr, Periods)
up  = src - (Multiplier * atrVal)
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up
dn  = src + (Multiplier * atrVal)
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn

trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend

plot(trend == 1 ? up : na, title="Up Trend", style=plot.style_linebr, linewidth=2, color=color.green)
plot(trend == 1 ? na : dn, title="Down Trend", style=plot.style_linebr, linewidth=2, color=color.red)

buySignal  = trend == 1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] == 1

plotshape(buySignal ? up : na, title="Buy", text="Buy", location=location.absolute, style=shape.labelup, size=size.tiny, color=color.green, textcolor=color.white)
plotshape(sellSignal ? dn : na, title="Close", text="Close", location=location.absolute, style=shape.labeldown, size=size.tiny, color=color.black, textcolor=color.white)

FromMonth = input.int(1, title="From Month", minval=1, maxval=12)
FromDay   = input.int(1, title="From Day",   minval=1, maxval=31)
FromYear  = input.int(2020, title="From Year", minval=999)
ToMonth   = input.int(1, title="To Month", minval=1, maxval=12)
ToDay     = input.int(1, title="To Day",   minval=1, maxval=31)
ToYear    = input.int(9999, title="To Year", minval=999)

start  = timestamp(FromYear, FromMonth, FromDay, 00, 00)
finish = timestamp(ToYear, ToMonth, ToDay, 23, 59)
window() => time >= start and time <= finish

if buySignal and window()
    strategy.entry("BUY", strategy.long)

if sellSignal and window()
    strategy.close("BUY")
````
