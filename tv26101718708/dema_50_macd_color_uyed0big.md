# DEMA 50 + MACD Color

- url: https://www.tradingview.com/script/UYeD0big/
- type: indicator
- pine_id: PUB;ee9852f7400e4e57ac7d939daaf89ca7
- version: 1.0

## Description

DEMA 50, which automatically changes color from green to red depending on momentum, measured with MACD.

## Source Code

````pine
//@version=5
indicator("DEMA 50 + MACD Color", overlay=true)

// ───── DEMA 50 ─────
len = 50
ema1 = ta.ema(close, len)
ema2 = ta.ema(ema1, len)
dema50 = 2 * ema1 - ema2

// ───── MACD ─────
fastLen = 12
slowLen = 26
signalLen = 9

[macdLine, signalLine, _] = ta.macd(close, fastLen, slowLen, signalLen)

// ───── Farblogik ─────
col = macdLine > signalLine ? color.green : color.red

// ───── Plot ─────
plot(dema50, title="DEMA 50", color=col, linewidth=2)
````
