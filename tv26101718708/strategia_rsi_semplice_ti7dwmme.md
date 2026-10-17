# Strategia RSI semplice

- url: https://www.tradingview.com/script/Ti7DWmMe/
- type: strategy
- pine_id: PUB;41dHlmSozEwwG1HtYdXRUdVXQ0Bt6jke
- version: 1.0

## Description

Questo semplice script sfrutta il RSI a 14 periodi per comprare (solo long) quando RSI crocia al rialzo i 30 (oversold line) e chiude l'operazione quando RSI crocia al ribasso i 70 (overbought line).

La strategia è stata progettata sul TimeFrame delle 4H (su BTC) e dimostra come una semplicissima strategia con un solo segnale poteva portare un 20% dal 2020 ad oggi su BTC/USD

## Source Code

````pine
//@version=4
strategy("Strategia RSI", overlay=true)
length = input( 14 )
vrsi = rsi(close, length)
apri = crossover(vrsi, 30)
chiudi = crossunder(vrsi, 70)
start = timestamp(2020, 01,01,01)
if (apri and time > start)
	strategy.entry("Long", strategy.long)
strategy.close("Long", when = chiudi)
````
