# EMA + MACD + RSI Confluence Strategy

- url: https://www.tradingview.com/script/Ospkem6i/
- type: strategy
- pine_id: PUB;20aeb517962b4d318d6fe0e7393fb303
- version: 1.0

## Description

EMA + MACD + RSI Signalq  Confluence StrategyEMA + MACD + RSI Confluence 波段策略（BTC 4H 专用）

这是一个简单实用的多指标共振策略，适合 BTC 4小时波段交易。

核心逻辑：
- 使用 EMA 9/20 判断趋势
- MACD 确认动量
- RSI 过滤假信号（>50 做多，<50 做空）

适用场景：
- BTC 4小时图
- 趋势行情中表现较好
- 适合中线波段（持仓几天到两周）

参数说明：
- Fast EMA: 9
- Slow EMA: 20
- MACD: 12,26,9
- RSI: 14，阈值 50

使用建议：
建议配合日线趋势过滤使用，仅在日线多头时做多，日线空头时做空。

风险提示：仅供学习参考，实盘请严格做好风控。

## Source Code

````pine
//@version=5
strategy("EMA + MACD + RSI Confluence Strategy", overlay=true, 
     default_qty_type=strategy.percent_of_equity, default_qty_value=10, 
     commission_type=strategy.commission.percent, commission_value=0.04)

ema_fast = ta.ema(close, 9)
ema_slow = ta.ema(close, 20)
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)
rsi = ta.rsi(close, 14)

longCondition = close > ema_fast and close > ema_slow and rsi > 50 and hist > 0
shortCondition = close < ema_fast and close < ema_slow and rsi < 50 and hist < 0

if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)

strategy.exit("Exit Long", "Long", stop=close * 0.982, limit=close * 1.06)
strategy.exit("Exit Short", "Short", stop=close * 1.018, limit=close * 0.94)
````
