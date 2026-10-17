# RSI + ADX Rising + DI+ Rising + ATR Expansion

- url: https://www.tradingview.com/script/09za6Xm8-RSI-ADX-Rising-DI-Rising-ATR-Expansion/
- type: indicator
- pine_id: PUB;772abdac8a78455a97e14c146e93c4c6
- version: 1.0

## Description

This indicator is designed to identify early-stage bullish momentum moves that are strengthening and gaining volatility, while avoiding stocks that may already be overextended.

What It Looks For

The script generates a bullish signal when all of the following conditions are met:

RSI is rising → momentum is improving.
ADX is rising → trend strength is increasing.
DI+ is rising → buying pressure is strengthening.
DI+ is greater than DI- → bulls are in control.
ATR is above its average → volatility is expanding, indicating increased participation and movement.
ADX is below 26 → trend is strengthening but not yet excessively mature.
Signal Logic

The indicator is essentially looking for:

"A stock where bullish momentum is building, trend strength is increasing, buyers are gaining control, and volatility is expanding—but the trend has not yet become crowded or overextended."

Visual Output
A triangle below the candle appears whenever all conditions align.
An alert can be triggered at the same time.
Best Use Case

This works well for identifying:

Early breakout candidates
Momentum continuation setups
Stocks transitioning from consolidation into trend
Names showing increasing institutional participation

## Source Code

````pine
//@version=5
indicator("RSI + ADX Rising + DI+ Rising + ATR Expansion", overlay=true)

rsiLen=input.int(14,"RSI Length",minval=1)
diLen=input.int(14,"DI Length",minval=1)
adxSmooth=input.int(14,"ADX Smoothing",minval=1)
lookback=input.int(1,"Rising Lookback",minval=1)
atrLen=input.int(14,"ATR Length",minval=1)
atrAvgLen=input.int(21,"ATR Average Length",minval=1)

rsi=ta.rsi(close,rsiLen)
[diPlus,diMinus,adx]=ta.dmi(diLen,adxSmooth)
atr=ta.atr(atrLen)

atrExpansion=atr>ta.sma(atr,atrAvgLen)
rsiRising=rsi>rsi[lookback]
adxRising=adx>adx[lookback]
diPlusRising=diPlus>diPlus[lookback]
diDominant=diPlus>diMinus

signal=rsiRising and adxRising and diPlusRising and diDominant and atrExpansion and adx<26

plotshape(signal,title="Signal",style=shape.triangleup,location=location.belowbar,size=size.small,text="RSI+DI+↑")
alertcondition(signal,title="Signal",message="RSI + DI+ rising + ADX rising + ATR expansion (ADX < 30).")
````
