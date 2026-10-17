# GC Strategy with Trend Filter and Sudden Move Profit Taking

- url: https://www.tradingview.com/script/1nw0Xtto/
- type: strategy
- pine_id: PUB;ea005da072fe4cae970f606fe632f78c
- version: 1.0

## Description

[symbol="BYBIT:BTCUSDT.P"]BYBIT:BTCUSDT.P[/symbol] 　15M


[b]Situation Assessment with Three Moving Averages[/b]

The strategy uses the crossover of the 5SMA and 25SMA as entry signals.

Additionally, the 75SMA is used as a filter. Long entries are only allowed when the price is above the 75SMA, and short entries are only allowed when the price is below the 75SMA.

[b]ADX Filter[/b]

The Average Directional Index (ADX) is used to check the strength of the trend. Entry signals are only activated when the ADX is above 20. This ensures that trades are only executed when the trend is strong.

[b]Sudden Move Detection[/b]

The strategy detects sudden price movements. If a sudden move occurs, the position is closed to lock in profits.

[b]Entry[/b]

Long Entry: When the 5SMA crosses above the 25SMA, the price is above the 75SMA, and the ADX is above 20.

Short Entry: When the 5SMA crosses below the 25SMA, the price is below the 75SMA, and the ADX is above 20.

[b]Exit[/b]

Positions are closed if a sudden move occurs. Positions are also closed if an opposing entry signal is generated.

This strategy aims to confirm the strength of the trend using moving average crossovers and ADX and to lock in profits based on sudden price movements.





[b]３本の移動平均線による状況判断[/b]

5SMAと25SMA のクロスオーバーをエントリーシグナルとして使用します。

さらに、75SMAをフィルターとして使用し、価格が75SMAの上にある場合のみロングエントリーを許可し、75SMAの下にある場合のみショートエントリーを許可します。



[b]ADXフィルター[/b]

ADX（平均方向性指数）を使ってトレンドの強さを確認します。
ADXが20より大きい場合のみ、エントリーシグナルを有効にします。これにより、トレンドが強い時にのみ取引を行うことができます。

[b]急激な変動検知[/b]

価格の急激な変動を検出します。
急激な変動があった場合には、ポジションをクローズして利益を確定します。


[b]エントリー[/b]

ロングエントリー

5SMAが25SMAを上にクロスし、価格が75SMAの上にあり、ADXが20を超えているとき。


ショートエントリー

5SMAが25SMAを下にクロスし、価格が75SMAの下にあり、ADXが20を超えているとき。

[b]エグジット[/b]

急激な変動があった場合、ポジションをクローズします。
反対のエントリーシグナルが発生した場合にも、ポジションをクローズします。
このストラテジーは、移動平均のクロスオーバーとADXを使ってトレンドの強さを確認し、急激な変動に基づいて利益を確定することを目的としています。

## Source Code

````pine
//@version=5
strategy("5SMA-25SMA Crossover Strategy with ADX Filter and Sudden Move Profit Taking", overlay=true)

// パラメータの設定
sma5 = ta.sma(close, 5)
sma25 = ta.sma(close, 25)
sma75 = ta.sma(close, 75)

// ADXの計算
length = 14
tr = ta.tr(true)
plus_dm = ta.rma(math.max(ta.change(high), 0), length)
minus_dm = ta.rma(math.max(-ta.change(low), 0), length)
tr_sum = ta.rma(tr, length)
plus_di = 100 * plus_dm / tr_sum
minus_di = 100 * minus_dm / tr_sum
dx = 100 * math.abs(plus_di - minus_di) / (plus_di + minus_di)
adx = ta.rma(dx, length)

// ロングとショートのエントリー条件
longCondition = ta.crossover(sma5, sma25) and close > sma75 and adx > 20
shortCondition = ta.crossunder(sma5, sma25) and close < sma75 and adx > 20

// 急激な変動を検知する条件（ここでは、前のローソク足に比べて0.6%以上の値動きがあった場合）
suddenMove = math.abs(ta.change(close)) > close[1] * 0.006

// ポジション管理
if (longCondition)
    strategy.entry("Long", strategy.long)
if (shortCondition)
    strategy.entry("Short", strategy.short)

// 急激な変動があった場合、ポジションを利益確定（クローズ）する
if (strategy.position_size > 0 and suddenMove)
    strategy.close("Long")
if (strategy.position_size < 0 and suddenMove)
    strategy.close("Short")

// エグジット条件
if (strategy.position_size > 0 and shortCondition)
    strategy.close("Long")
if (strategy.position_size < 0 and longCondition)
    strategy.close("Short")

// SMAとADXのプロット
plot(sma5, color=color.blue, title="5SMA")
plot(sma25, color=color.red, title="25SMA")
plot(sma75, color=color.green, title="75SMA")
plot(adx, color=color.orange, title="ADX")
hline(20, "ADX Threshold", color=color.gray, linestyle=hline.style_dotted)
````
