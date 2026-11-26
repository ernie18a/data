# Leo Bias VMC EMA

- url: https://www.tradingview.com/script/isBfmPwL-Leo-Bias-VMC-EMA/
- type: indicator
- pine_id: PUB;c722f58e4fe0438584d711106f910694
- version: 1.0

## Description

this indicator determines bias based off 1h moneyflow and 1h emas

## Source Code

````pine
//@version=6
indicator(title="VMC 1H Bias Box", shorttitle="VMC 1H Bias", overlay=true)

// EMA settings from VMC A
ema1Len = input(5, title="EMA 1 Length")
ema2Len = input(11, title="EMA 2 Length")
ema3Len = input(15, title="EMA 3 Length")
ema4Len = input(18, title="EMA 4 Length")
ema5Len = input(21, title="EMA 5 Length")
ema6Len = input(24, title="EMA 6 Length")
ema7Len = input(28, title="EMA 7 Length")
ema8Len = input(34, title="EMA 8 Length")

// Moneyflow settings from VMC B
rsiMFIperiod = input(60, title="MFI Period")
rsiMFIMultiplier = input(150, title="MFI Area Multiplier")

biasTf = input("60", title="Bias Timeframe")

f_rsimfi(_period, _multiplier) =>
    ta.sma(((close - open) / math.max(high - low, syminfo.mintick)) * _multiplier, _period)

ema2Htf = request.security(syminfo.tickerid, biasTf, ta.ema(close, ema2Len))
ema8Htf = request.security(syminfo.tickerid, biasTf, ta.ema(close, ema8Len))
moneyflowHtf = request.security(syminfo.tickerid, biasTf, f_rsimfi(rsiMFIperiod, rsiMFIMultiplier))

emaBullish = ema8Htf < ema2Htf
emaBearish = ema8Htf > ema2Htf
moneyflowBullish = moneyflowHtf > 0
moneyflowBearish = moneyflowHtf < 0

bullishBias = emaBullish and moneyflowBullish
bearishBias = emaBearish and moneyflowBearish

biasText = bullishBias ? "Bullish Bias" : bearishBias ? "Bearish Bias" : "Neutral Bias"
biasColor = bullishBias ? color.green : bearishBias ? color.red : color.gray

var table biasTable = table.new(position.top_right, 1, 1)

if barstate.islast
    table.cell(biasTable, 0, 0, biasText, text_color=color.white, bgcolor=biasColor)
````
