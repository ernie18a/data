# Crypto Swing buy and sell indicator

- url: https://www.tradingview.com/script/5owHodc8-Crypto-Swing-buy-and-sell-indicator/
- type: indicator
- pine_id: PUB;0e87b8c2a90542e88f036117db99a578
- version: 1.0

## Description

Crypto Swing Buy and Sell Indicator is a trend-following swing indicator designed for crypto markets. It combines a 200-period EMA trend filter with MACD histogram momentum shifts, RSI recovery/cooling zones, and MFI volume-flow confirmation to highlight potential buy and sell opportunities.

The indicator plots a dynamic EMA 200 line that changes colour depending on whether price is trading above or below the trend filter. A BUY signal appears when price is above the EMA 200, MACD momentum turns bullish, RSI is recovering from lower levels, and MFI confirms that the move is not yet overextended. A SELL signal appears when price is below the EMA 200, MACD momentum turns bearish, RSI is cooling from higher levels, and MFI confirms weakening buying pressure.

This indicator is intended for swing trading and trend confirmation, especially on higher timeframes such as 4H or daily charts. It can be used to identify possible long and short setups, but should be combined with risk management, support/resistance analysis, and broader market context.

Signals:

BUY: Price above EMA 200 + MACD bullish flip + RSI recovering + MFI below 50.
SELL: Price below EMA 200 + MACD bearish flip + RSI cooling + MFI above 50.

Recommended use: crypto swing trading, trend confirmation, momentum-based entries, and alert-based trade monitoring.

## Source Code

````pine
//@version=6
indicator("SOL Swing Combo", overlay=true, max_labels_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
lenRSI  = input.int(14,   "RSI Length")
lenMFI  = input.int(14,   "MFI Length")
fastLen = input.int(12,   "MACD Fast")
slowLen = input.int(26,   "MACD Slow")
sigLen  = input.int(9,    "MACD Signal")
emaLen  = input.int(200,  "EMA Length")
src     = close

// ─── CALCULATIONS ────────────────────────────────────────────────────────────
ema200        = ta.ema(src, emaLen)
rsiVal        = ta.rsi(src, lenRSI)
mfiVal        = ta.mfi(hlc3, lenMFI)
[macdLine, signalLine, histLine] = ta.macd(src, fastLen, slowLen, sigLen)

emaBull       = src > ema200
emaBear       = src < ema200
macdBullCross = ta.crossover(histLine, 0)
macdBearCross = ta.crossunder(histLine, 0)

// ─── SIGNALS ─────────────────────────────────────────────────────────────────
// BUY: price above EMA + MACD hist flips bull + RSI recovering + MFI confirming
buySignal = emaBull and macdBullCross and (rsiVal > 20 and rsiVal < 50) and (mfiVal < 50)

// SELL: price below EMA + MACD hist flips bear + RSI cooling + MFI confirming
sellSignal = emaBear and macdBearCross and (rsiVal > 50 and rsiVal < 80) and (mfiVal > 50)

// ─── MAIN CHART ──────────────────────────────────────────────────────────────
plot(ema200, "EMA 200", color=emaBull ? color.new(#00E676, 20) : color.new(#FF5252, 20), linewidth=2)

plotshape(buySignal,  title="BUY",  text="BUY",  style=shape.labelup,
     location=location.belowbar, color=color.new(#00E676, 0),
     textcolor=color.white, size=size.normal)

plotshape(sellSignal, title="SELL", text="SELL", style=shape.labeldown,
     location=location.abovebar, color=color.new(#FF5252, 0),
     textcolor=color.white, size=size.normal)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(buySignal,  title="BUY",  message="CRYPTO LONG — EMA bull + MACD flip + RSI recovering")
alertcondition(sellSignal, title="SELL", message="CRYPTO SHORT — EMA bear + MACD flip + RSI cooling")
````
