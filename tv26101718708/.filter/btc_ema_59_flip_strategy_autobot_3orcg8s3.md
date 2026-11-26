# BTC EMA 5-9 Flip Strategy Autobot

- url: https://www.tradingview.com/script/3oRCg8s3-BTC-EMA-5-9-Flip-Strategy-Autobot/
- type: strategy
- pine_id: PUB;94f8e0bbb39b4f268dab9d927efeacab
- version: 2.0

## Description

This strategy is designed for fast and accurate trend-following trades on Bitcoin.
It uses a crossover between EMA 5 and EMA 9 to detect instant trend reversals and automatically flips between Long and Short positions.

How the strategy works

EMA 5 crossing above EMA 9 → Long

EMA 5 crossing below EMA 9 → Short

Automatically closes the opposite trade during a flip

Executes trades only on candle close

Prevents double entries with internal position-state logic

Fully compatible with automated trading via webhooks (Delta Exchange)

Why this strategy works

EMA 5–9 is extremely responsive for BTC’s volatility

Captures trend reversals early

Works best on 15-minute timeframe

Clean, simple logic without over-filtering reduces missed opportunities

Performs well in both uptrends and downtrends

Automation Ready

This strategy includes alert conditions and webhook-ready JSON for automated execution.

This is a fast-reacting BTC bot designed for intraday and swing crypto trend trading.

## Source Code

````pine
//@version=5
strategy("SAFE PUBLIC – BTC EMA 5/9 Trend Strategy (Delta Ready)",
     overlay=true,
     calc_on_every_tick=false,
     process_orders_on_close=true,
     initial_capital=100000,
     default_qty_type=strategy.fixed,
     default_qty_value=20)  // always fixed lots, never increases automatically

// ===== INPUTS =====
orderQty = input.int(20, "Order Quantity (Lots)") // safe fixed quantity
useATR   = input.bool(true, "Use ATR Volatility Filter")
useST    = input.bool(true, "Use Supertrend Filter")
useHTF   = input.bool(true, "Use Higher Timeframe Trend Filter")

// ===== BASE EMAs =====
fastEMA = ta.ema(close, 5)
slowEMA = ta.ema(close, 9)
ema20   = ta.ema(close, 20)
ema50   = ta.ema(close, 50)

plot(fastEMA, color=color.new(color.green, 0), title="EMA 5")
plot(slowEMA, color=color.new(color.red,   0), title="EMA 9")
plot(ema20,  color=color.yellow, title="EMA 20")
plot(ema50,  color=color.blue,   title="EMA 50")

// ===== HIGHER TIMEFRAME TREND (1 HOUR) =====
htfEMA20 = request.security(syminfo.tickerid, "60", ta.ema(close, 20))
htfEMA50 = request.security(syminfo.tickerid, "60", ta.ema(close, 50))
htfUp    = htfEMA20 > htfEMA50
htfDown  = htfEMA20 < htfEMA50

// ===== SUPERTREND FILTER =====
[stLine, stDir] = ta.supertrend(3, 10)
stBuy  = stDir == 1
stSell = stDir == -1

// ===== ATR VOLATILITY FILTER =====
atr = ta.atr(14)
atrPerc = (atr / close) * 100
atrOK = atrPerc > 0.30   // safe threshold: avoid low volatility days

// ===== TREND CONDITIONS =====
upTrend   = ema20 > ema50
downTrend = ema20 < ema50

// ===== SIGNALS =====
bullCross = ta.crossover(fastEMA, slowEMA) and barstate.isconfirmed
bearCross = ta.crossunder(fastEMA, slowEMA) and barstate.isconfirmed

// ===== FINAL SAFE ENTRY CONDITIONS =====
buyAllowed  = upTrend and htfUp and stBuy and atrOK
sellAllowed = downTrend and htfDown and stSell and atrOK

// ===== SAFE ENTRY / EXIT LOGIC =====

// BUY LOGIC
if bullCross
    // Always close old trade first
    if strategy.position_size < 0
        strategy.close("Short")
    // Enter long only if all filters pass
    if buyAllowed
        strategy.close_all()
        strategy.entry("Long", strategy.long, qty=orderQty)

// SELL LOGIC
if bearCross
    // Always close old trade first
    if strategy.position_size > 0
        strategy.close("Long")
    // Enter short only if all filters pass
    if sellAllowed
        strategy.close_all()
        strategy.entry("Short", strategy.short, qty=orderQty)

// ===== ALERTS =====
alertcondition(bullCross and buyAllowed, "BUY", "BUY")
alertcondition(bearCross and sellAllowed, "SELL", "SELL")
````
