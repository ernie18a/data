# SuperTrend BB Strategy [STB]

- url: https://www.tradingview.com/script/anNnwsQo/
- type: strategy
- pine_id: PUB;9ba0d8c1aca04d838e36de4bce5c1402
- version: 1.0

## Description

█ OVERVIEW

SuperTrend BB Filter Strategy [STB] combines a standard SuperTrend with a Bollinger Bands SMA filter to reduce false signals in choppy markets.

The core idea is simple — use the BB midline (SMA) to confirm trend direction first, then take SuperTrend signals only in that direction.


█ HOW IT WORKS

SuperTrend generates BUY/SELL signals based on ATR-derived trend lines. On its own, it tends to get whipsawed in ranging conditions.

Bollinger Bands midline (SMA) acts as a trend filter:
• Price above BB midline → long signals only
• Price below BB midline → short signals only

This filters out a large portion of counter-trend noise.


█ ENTRY / EXIT CONDITIONS

Long Entry
• SuperTrend flips bullish (direction change)
• Close is above the BB midline (SMA)

Short Entry
• SuperTrend flips bearish (direction change)
• Close is below the BB midline (SMA)

Stop Loss  : ATR(14) × multiplier from entry price
Take Profit: SL distance × Risk/Reward ratio

All signals trigger on confirmed bars only.


█ DEFAULT SETTINGS

SuperTrend
• ATR Length    : 10
• Multiplier    : 3.0

Bollinger Bands
• BB Length (SMA Filter) : 50
• BB Multiplier          : 2.0

Risk Management
• Stop Loss ATR Multiplier : 1.5
• Risk/Reward Ratio        : 1.5


█ ALERTS

Three alert conditions are available:
• STB BUY/SELL — triggers on either signal (saves one alert slot)
• STB BUY      — long signal only
• STB SELL     — short signal only

Alert messages include ticker and timeframe automatically.


█ NOTES

— This strategy is a fully original implementation.
  No external scripts or third-party code were used.
— Backtested with commission 0.05%. Adjust in the Properties tab to match your broker.
— Performed well on XAUUSD (Gold) Daily and Weekly timeframes in backtests.
— Results vary by symbol and timeframe. Always verify on your target pair before live trading.
— For better accuracy, confirm trend direction on a higher timeframe before entering on your target timeframe.

## Source Code

````pine
//@version=6
strategy("SuperTrend BB Strategy [STB]",
     overlay           = true,
     commission_type   = strategy.commission.percent,
     commission_value  = 0.05,
     default_qty_type  = strategy.fixed,
     default_qty_value = 1,
     initial_capital   = 100000)

// ─── SuperTrend設定 ──────────────────────────────────────────
st_atr  = input.int  (10,  "ATR期間",  minval=1,   group="SuperTrend")
st_mult = input.float(3.0, "乗数",     minval=0.1, step=0.1, group="SuperTrend")

// ─── ボリンジャーバンド設定 ──────────────────────────────────
bb_period = input.int  (50,  "BB期間（SMAフィルター）", minval=1,   group="ボリンジャーバンド")
bb_mult   = input.float(2.0, "BB乗数",                 minval=0.1, step=0.1, group="ボリンジャーバンド")

// ─── リスク管理 ──────────────────────────────────────────────
sl_atr_mult = input.float(1.5, "SLのATR倍率", minval=0.1, step=0.1, group="リスク管理")
rr_ratio    = input.float(1.5, "RR比率",      minval=0.1, step=0.1, group="リスク管理")

// ─── 計算 ────────────────────────────────────────────────────
[st_line, dir] = ta.supertrend(st_mult, st_atr)

bb_mid   = ta.sma(close, bb_period)
bb_dev   = ta.stdev(close, bb_period)
bb_upper = bb_mid + bb_mult * bb_dev
bb_lower = bb_mid - bb_mult * bb_dev

atr14    = ta.atr(14)

// ─── シグナル（確定足のみ） ──────────────────────────────────
st_up   = dir == -1 and dir[1] == 1
st_down = dir ==  1 and dir[1] == -1

buy_signal  = barstate.isconfirmed and st_up   and close > bb_mid
sell_signal = barstate.isconfirmed and st_down and close < bb_mid

// ─── エントリー・エグジット ──────────────────────────────────
if buy_signal and strategy.position_size == 0
    sl = close - atr14 * sl_atr_mult
    tp = close + (close - sl) * rr_ratio
    strategy.entry("Long",  strategy.long)
    strategy.exit ("Long Exit",  "Long",  stop=sl, limit=tp)

if sell_signal and strategy.position_size == 0
    sl = close + atr14 * sl_atr_mult
    tp = close - (sl - close) * rr_ratio
    strategy.entry("Short", strategy.short)
    strategy.exit ("Short Exit", "Short", stop=sl, limit=tp)

// ─── 表示 ────────────────────────────────────────────────────
plot(st_line, "SuperTrend", dir < 0 ? color.teal : color.red, linewidth=2)

p_upper = plot(bb_upper, "BB Upper", color.new(color.blue, 70), linewidth=1)
p_mid   = plot(bb_mid,   "BB Mid（SMAフィルター）", color.orange, linewidth=1)
p_lower = plot(bb_lower, "BB Lower", color.new(color.blue, 70), linewidth=1)
fill(p_upper, p_lower, color.new(color.blue, 90))

plotshape(buy_signal,  "BUY",  shape.labelup,   location.belowbar,
     color=color.new(color.teal, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sell_signal, "SELL", shape.labeldown, location.abovebar,
     color=color.new(color.red,  0), text="SELL", textcolor=color.white, size=size.small)

// ─── アラート ────────────────────────────────────────────────
alertcondition(buy_signal or sell_signal,
     title   = "STB BUY/SELL",
     message = "{{ticker}} {{interval}} | BUY/SELLシグナル発生")
alertcondition(buy_signal,
     title   = "STB BUY",
     message = "{{ticker}} {{interval}} | BUYシグナル")
alertcondition(sell_signal,
     title   = "STB SELL",
     message = "{{ticker}} {{interval}} | SELLシグナル")
````
