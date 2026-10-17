# Lucas Teste

- url: https://www.tradingview.com/script/IvqrCq3G/
- type: strategy
- pine_id: PUB;pB5lT2lww7xc9ttOMhXoiCxde96E7rhZ
- version: 1.0

## Description

IBOVEESPA - Mini indice.
Scalper

## Source Code

````pine
//@version=3

strategy("Lucas", overlay=true)

//Inicio das condições de entrada
shortCondition = crossunder(ema(close,7), ema(close, 14)) and crossunder(ema(close, 13), ema(close, 14)) //Crossunder é o cruzamento das médias para baixo (operações de venda).

if (shortCondition)
    strategy.entry("Entrada de Venda", strategy.short) //short define que só pode entrar em operações de VENDA.

longCondition = crossover(ema(close, 7), sma(close, 55)) and crossover(ema(close,7), ema(close, 14)) //Crossover é o cruzamento das médias para baixo (operações de compra).

if (longCondition)
    strategy.entry("Entrada de Compra", strategy.long) //long define que só pode entrar em operações de COMPRA.

//Configuração da saida para ambas as posições, tanto de compra como de venda.
strategy.exit("Saida", profit = 3, loss = 60)
````
