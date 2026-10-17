# Bollinger Bands SMA 20_2 Strategy

- url: https://www.tradingview.com/script/b6zu2RjR-Bollinger-Bands-SMA-20-2-Strategy/
- type: strategy
- pine_id: PUB;5f4852783fa64bfc85bd0a5d2e92baa5
- version: 1.0

## Description

Mean reversion strategy using Bollinger Bands (20-period SMA with 2.0 standard deviation bands).

[b]Trade Triggers:
[/b]
🟢 BUY SIGNAL:
[list]
[*]When: Price crosses above the lower Bollinger Band
[*]Logic: Price has hit oversold territory and is bouncing back
[*]Action: Places a long position with stop at the lower band
[/list]

🔴 SELL SIGNAL:
[list]
[*]When: Price crosses below the upper Bollinger Band
[*]Logic: Price has hit overbought territory and is pulling back
[*]Action: Places a short position with stop at the upper band
[/list]

## Source Code

````pine
//@version=6
strategy("Bollinger Bands Strategy", overlay=true)
source = close
length = input.int(20, minval=1)
mult = input.float(2.0, minval=0.001, maxval=50)
basis = ta.sma(source, length)
dev = mult * ta.stdev(source, length)
upper = basis + dev
lower = basis - dev
buyEntry = ta.crossover(source, lower)
sellEntry = ta.crossunder(source, upper)
if (ta.crossover(source, lower))
	strategy.entry("Buy", strategy.long, stop=lower, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="Buy Signal Triggered", alert_message="SYMBOL=ETH/USDC;SIGNAL=BUY;VOLUME=0.001;BOT_ID=5d846773-340b-41ad-9dbb-b014322e863f")
else
	strategy.cancel(id="Buy")
if (ta.crossunder(source, upper))
	strategy.entry("Sell", strategy.short,  stop=upper, oca_name="BollingerBands", oca_type=strategy.oca.cancel, comment="Sell Signal Triggered", alert_message="SYMBOL=ETH/USDC;SIGNAL=SELL;VOLUME=0.001;BOT_ID=5d846773-340b-41ad-9dbb-b014322e863f")

else
	strategy.cancel(id="Sell")
````
