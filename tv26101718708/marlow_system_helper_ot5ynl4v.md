# Marlow System Helper

- url: https://www.tradingview.com/script/oT5ynL4V-marlow-system-helper/
- type: indicator
- pine_id: PUB;4d8a1e63e37e488bba1c82eac010aae8
- version: 1.0

## Description

Marlow System Helper — это трендовый сигнальный индикатор, разработанный для поиска более качественных точек входа с помощью многоуровневой системы фильтрации.

В основе алгоритма лежит комбинация EMA crossover, momentum-анализа и фильтрации рыночной волатильности. Индикатор не пытается выдавать большое количество сигналов — его задача заключается в том, чтобы отсеивать слабые и хаотичные входы, оставляя только наиболее вероятные продолжения движения.

В индикатор встроено несколько независимых фильтров:

• Trend Filter (EMA 200)
Сигналы BUY появляются только выше глобального тренда, а сигналы SELL — только ниже него. Это позволяет избегать большинства контртрендовых входов и снижает количество ложных сигналов во флэте.

• EMA Direction Filter
Дополнительно анализируется направление самой трендовой EMA. Система ищет только те входы, которые совпадают с текущим направлением рынка.

• Momentum Confirmation
Перед появлением сигнала алгоритм проверяет наличие импульса в движении цены. Это помогает исключать слабые пробои и случайные пересечения скользящих средних.

• ATR Volatility Filter
Встроенный фильтр волатильности анализирует текущую активность рынка через ATR. Сигналы во время низкой волатильности и бокового движения автоматически игнорируются.

• Smart Signal Filter
Индикатор использует систему защиты от повторных сигналов. Вместо большого количества одинаковых BUY или SELL подряд отображается только первый подтвержденный вход в направлении движения.

• Cooldown System
После появления сигнала алгоритм делает небольшую паузу перед поиском следующего входа. Это дополнительно уменьшает шум и снижает количество лишних уведомлений.

Индикатор специально выполнен в минималистичном стиле — на графике отображаются только точки входа без лишних линий и перегруженных элементов интерфейса.

Подходит для:
— Поиска трендов
— Скальпинга
— Forex / Crypto / Indices

Лучше всего работает на волатильных трендовых рынках.

## Source Code

````pine
//@version=6
indicator("Marlow System Helper", overlay=true)

// =====================================================
// SETTINGS
// =====================================================

fastLength = input.int(10, title="Fast EMA")
slowLength = input.int(20, title="Slow EMA")

trendLength = input.int(200, title="Trend EMA")

momentumLength = input.int(10, title="Momentum Length")
momentumLookback = input.int(5, title="Momentum Confirmation Candles")

atrLength = input.int(14, title="ATR Length")
atrMultiplier = input.float(0.7, title="ATR Filter")

cooldownBars = input.int(5, title="Cooldown")

// =====================================================
// EMA
// =====================================================

fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)
trendEMA = ta.ema(close, trendLength)

// =====================================================
// EMA CROSS
// =====================================================

emaBull = ta.crossover(fastEMA, slowEMA)
emaBear = ta.crossunder(fastEMA, slowEMA)

// =====================================================
// TREND FILTER (HIDDEN EMA 200)
// =====================================================

buyTrend = close > trendEMA
sellTrend = close < trendEMA

// EMA 200 direction
emaTrendUp = trendEMA > trendEMA[1]
emaTrendDown = trendEMA < trendEMA[1]

// =====================================================
// MOMENTUM
// =====================================================

momentum = ta.mom(close, momentumLength)

bullMomentumRecent =
     ta.highest(momentum, momentumLookback) > 0

bearMomentumRecent =
     ta.lowest(momentum, momentumLookback) < 0

// =====================================================
// ATR FILTER
// =====================================================

atr = ta.atr(atrLength)
atrAvg = ta.sma(atr, atrLength)

volatilityFilter =
     atr > atrAvg * atrMultiplier

// =====================================================
// RAW SIGNALS
// =====================================================

rawBuy =
     emaBull and
     bullMomentumRecent and
     buyTrend and
     emaTrendUp and
     volatilityFilter

rawSell =
     emaBear and
     bearMomentumRecent and
     sellTrend and
     emaTrendDown and
     volatilityFilter

// =====================================================
// SMART SIGNAL FILTER
// =====================================================

// 1 = BUY
// -1 = SELL
// 0 = NONE

var int lastDirection = 0
var int lastSignalBar = na

cooldownPassed =
     na(lastSignalBar) or
     (bar_index - lastSignalBar > cooldownBars)

// BUY only if previous signal wasn't BUY
buySignal =
     rawBuy and
     cooldownPassed and
     lastDirection != 1

// SELL only if previous signal wasn't SELL
sellSignal =
     rawSell and
     cooldownPassed and
     lastDirection != -1

// Save last direction
if buySignal
    lastDirection := 1
    lastSignalBar := bar_index

if sellSignal
    lastDirection := -1
    lastSignalBar := bar_index

// =====================================================
// HIDDEN FILTER EMA
// =====================================================

plot(
     trendEMA,
     display=display.none
)

// =====================================================
// VISUALS
// =====================================================

// BUY GLOW
plotshape(
     buySignal,
     style=shape.circle,
     location=location.belowbar,
     color=color.new(color.lime, 75),
     size=size.huge
)

// BUY LABEL
plotshape(
     buySignal,
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.white,
     size=size.large
)

// SELL GLOW
plotshape(
     sellSignal,
     style=shape.circle,
     location=location.abovebar,
     color=color.new(color.red, 75),
     size=size.huge
)

// SELL LABEL
plotshape(
     sellSignal,
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.large
)

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     buySignal,
     title="BUY SIGNAL",
     message="BUY SIGNAL"
)

alertcondition(
     sellSignal,
     title="SELL SIGNAL",
     message="SELL SIGNAL"
)
````
