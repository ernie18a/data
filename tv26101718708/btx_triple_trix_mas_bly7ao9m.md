# [BTX] Triple TRIX + MAs

- url: https://www.tradingview.com/script/BlY7Ao9M-BTX-Triple-TRIX-MAs/
- type: indicator
- pine_id: PUB;loGKGasO1DRMGLANe6PwOTbha7UUc8et
- version: 1.0

## Description

This indicator suggest a strategy, which is quite similar to multiple MA or multiple RSI strategies.
This indicator can be used for all timeframes, all markets.
This indicator can help detect the market trend and momentum.

Default values are TRIX - 6, 12, and 24 periods and MA(8) for each TRIX line. You can choose what type of MA to be used (EMA or SMA).

How to exploit this indicator?
- When all of the lower TRIXs are ABOVE the higher one: TRIX(6) is above TRIX(12), and TRIX(12) is above TRIX(24), there is a BULLISH market.
- When all of the lower TRIXs are BELOW the higher one: TRIX(6) is below TRIX(12), and TRIX(12) is below TRIX(24), there is a BEARISH market.
- A crossover of the lower TRIX to the higher one indicates a BUY signal.
- A crossunder of the lower TRIX to the higher one indicates a SELL signal.
- TRIX crossover the Zero line can be considered as a STRONG bullish signal.
- TRIX crossunder the Zero line can be considered as a STRONG bearish signal.
- The MA of TRIX acts as a confirmation, it can be used as SELL signals.
- High slopes of TRIX lines can point out the high momentum of the current trend.
- Divergence patterns can be used with this indicator.
- And many more tricks.

## Source Code

````pine
//@version=4
study(title="[BTX] Triple TRIX + MA", overlay=false)
//Default values are set to TRIX(6, 12, and 24) and MA(8)/TRIX for each TRIX
//Credit to @Batrachotoxin [BTX]
trlen1 = input(6, title='1st TRIX length', minval=1)
trlen2 = input(12, title='2nd TRIX length', minval=1)
trlen3 = input(24, title='3rd TRIX length', minval=1)
malen1 = input(8, title='1st TRIX MA length', minval=1)
ma1_type = input(title="Use EMA for 1st TRIX?", type=input.bool, defval=false)
malen2 = input(8, title='2nd TRIX MA length', minval=1)
ma2_type = input(title="Use EMA for 2nd TRIX?", type=input.bool, defval=false)
malen3 = input(8, title='3rd TRIX MA length', minval=1)
ma3_type = input(title="Use EMA for 3rd TRIX?", type=input.bool, defval=false)
trix1 = 10000 * change(ema(ema(ema(log(close), trlen1), trlen1), trlen1))
trix2 = 10000 * change(ema(ema(ema(log(close), trlen2), trlen2), trlen2))
trix3 = 10000 * change(ema(ema(ema(log(close), trlen3), trlen3), trlen3))
ema1 = ema(trix1, malen1)
sma1 = sma(trix1, malen1)
ema2 = ema(trix2, malen2)
sma2 = sma(trix2, malen2)
ema3 = ema(trix3, malen3)
sma3 = sma(trix3, malen3)
ma1 = ma1_type ? ema1 : sma1
ma2 = ma2_type ? ema2 : sma2
ma3 = ma3_type ? ema3 : sma3
plot(trix1, color=color.yellow, title="1st TRIX", linewidth=2, transp=0)
plot(trix2, color=color.aqua, title="2nd TRIX", linewidth=2, transp=0)
plot(trix3, color=color.fuchsia, title="3rd TRIX", linewidth=2, transp=0)
plot(ma1, color=color.yellow, title="1st TRIX MA", style=plot.style_cross, linewidth=1, transp=35)
plot(ma2, color=color.teal, title="2nd TRIX MA", style=plot.style_cross, linewidth=1, transp=35)
plot(ma3, color=color.fuchsia, title="3rd TRIX MA", style=plot.style_cross, linewidth=1, transp=35)
hline(0, title="Zero line", color=color.white)
````
