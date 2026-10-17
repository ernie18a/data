# NYBREAKOUT by Fliux

- url: https://www.tradingview.com/script/QmV3DV0S-NYBREAKOUT-by-Fliux/
- type: strategy
- pine_id: PUB;419604bef25740b4aaa66e376738e94b
- version: 1.0

## Description

[b]Strategy Concept[/b]
This strategy captures high-probability breakout moves by defining a tight 30-minute range during low-volatility hours and trading the first clear break beyond that range with a 2:1 reward-to-risk ratio. 

[b]Key Benefits[/b]
Simplicity: Clear, time-based range and mechanical entries/exits.

Defined R:R: Automatic 2:1 target ensures consistent risk management.

Time-filtered: Trades only the initial breakout of a calm, pre-session range.

[b]How to Use[/b]
Add to Chart: Paste the Pine Script into TradingView’s Pine Editor, then click Add to Chart.

Backtest: Open Strategy Tester to review net profit, drawdown, win rate, and profit factor.

Optimize: Adjust stop-loss offset, R:R ratio, or session window parameters to suit different instruments or volatility regimes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Fliux

//@version=5
strategy("NYBREAKOUT by Fliux", overlay=true, calc_on_every_tick=true)

// 1) Сессия 13:00–13:30 UTC = 18:00–18:30 YEKT, фиксированная 30-минутка:
sess = time("30", "1300-1330:1234567")

// 2) Переменные диапазона
var float hi = na
var float lo = na

if sess
    // В слоте 18:00–18:30 ЕКТ накапливаем максимум/минимум
    hi := na(hi) ? high : math.max(hi, high)
    lo := na(lo) ? low  : math.min(lo,  low)
else if not sess and sess[1]
    // Первое появление бара после 18:30 — вход по пробою
    if close > hi
        strategy.entry("Long", strategy.long)
        strategy.exit("Exit Long", from_entry="Long",
                      stop = lo - syminfo.mintick,
                      limit= close + (close - lo) * 2)
    if close < lo
        strategy.entry("Short", strategy.short)
        strategy.exit("Exit Short", from_entry="Short",
                      stop = hi + syminfo.mintick,
                      limit= close - (hi - close) * 2)
    // Сбрасываем диапазон
    hi := na
    lo := na
````
