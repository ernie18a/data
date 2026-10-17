# RSI2 Scapling

- url: https://www.tradingview.com/script/27mK1oIF-RSI2-Scapling/
- type: strategy
- pine_id: PUB;3VYh0Nbd1GRLb2PiSps5zmVacbRFWRYE
- version: 2.0

## Description

Rule
1. Price is above its 200-period moving average
2. The 2-period RSI of price closes below 5
3. Buy price on the close
4. Exit when price closes above its 5-period moving average

## Source Code

````pine
//@version=3
strategy("RSI-2 Strategy", overlay=true)

if (rsi(close,2) < 5 and close > sma(close,200))
    strategy.entry("BUY", strategy.long)
if (close > sma(close,5))
    strategy.close("BUY")
````
