# Renko Stock Daily

- url: https://www.tradingview.com/script/g1E93ugk/
- type: strategy
- pine_id: PUB;tKMusVp5vSDcAr02gSF41ykcb8z1bpTM
- version: 2.0

## Description

Hello,
This strategy must be use only for stocks. It doesnt work with FOREX or others..
You must use it only for renko candles
Best regards

## Source Code

````pine
// @version=2
strategy("Strategy Renko Stock Daily")


Rango1 = input(false, title="Rango 1")
Rango2 = input(false, title="Rango 2")

Situacion = ((highest(close, 22)-low)/(highest(close, 22)))*100

DesviaccionTipica = 2 * stdev(Situacion, 20)
Media = sma(Situacion, 20)

Rango11 = Media + DesviaccionTipica

Rango22 = (highest(Situacion, 50)) * 0.85


advertir = Situacion >= Rango11 or Situacion >= Rango22 ? green : red    



if (Situacion[1] >= Rango11[1] or Situacion[1] >= Rango22[1]) and (Situacion[0] < Rango11[0] and Situacion[0] < Rango22[0])and (close>open)
    strategy.entry("Entrar", strategy.long,comment= "Entrar",when=strategy.position_size <= 0)


strategy.close_all(when=close<open)



plot(Rango1 and Rango22 ? Rango22 : na, title="Rango22", style=line, linewidth=4, color=orange)
plot(Situacion, title="Rengo Stock Daily", style=histogram, linewidth = 4, color=advertir)
plot(Rango2 and Rango11 ? Rango11 : na, title="Upper Band", style=line, linewidth = 3, color=aqua)
````
