# VWAP19 (5m)

- url: https://www.tradingview.com/script/1S7c3Qva-vwap19-5m/
- type: indicator
- pine_id: PUB;d67e2d326f0f49ab8783df195c6954bb
- version: 1.0

## Description

Подходит не для всех инструментов. вход по сигналу вивап, выход по сигналу МА19

## Source Code

````pine
//@version=5
indicator("Мой Сигнальный Скрипт (5m)", overlay=true)

// Параметры
maLength = 19
maSource = close

// Расчет индикаторов
sma19 = ta.sma(maSource, maLength)
vwapValue = ta.vwap(hlc3)

// Условия для сигналов
// 1. Пересечение цены со скользящей средней (SMA 19)
crossAboveMA = ta.crossover(close, sma19)
crossBelowMA = ta.crossunder(close, sma19)

// 2. Пересечение цены с VWAP и закрытие выше/ниже
// Для сигнала "закрытие выше VWAP": свеча пересекает VWAP снизу вверх И закрывается выше VWAP
crossAboveVWAP = ta.crossover(close, vwapValue) and close > vwapValue
// Для сигнала "закрытие ниже VWAP": свеча пересекает VWAP сверху вниз И закрывается ниже VWAP
crossBelowVWAP = ta.crossunder(close, vwapValue) and close < vwapValue

// Объединенный сигнал (любое из событий)
anySignal = crossAboveMA or crossBelowMA or crossAboveVWAP or crossBelowVWAP

// Визуализация сигналов
// 1. Сигналы по SMA 19
plotshape(crossAboveMA, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="MA↑")
plotshape(crossBelowMA, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="MA↓")

// 2. Сигналы по VWAP
plotshape(crossAboveVWAP, style=shape.triangleup, location=location.belowbar, color=color.blue, size=size.small, text="VWAP↑")
plotshape(crossBelowVWAP, style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small, text="VWAP↓")

// Отображение самих линий на графике
plot(sma19, "SMA 19", color=color.yellow, linewidth=2)
plot(vwapValue, "VWAP", color=color.purple, linewidth=2)

// Дополнительно: алерт на любой сигнал
alertcondition(anySignal, title="Любой сигнал", message="Сигнал: пересечение SMA 19 или VWAP на 5m")

// Отдельные алерты для каждого типа сигнала (опционально)
alertcondition(crossAboveMA, title="SMA 19 пересечение вверх", message="Цена пересекла SMA 19 вверх на 5m")
alertcondition(crossBelowMA, title="SMA 19 пересечение вниз", message="Цена пересекла SMA 19 вниз на 5m")
alertcondition(crossAboveVWAP, title="VWAP пересечение вверх + закрытие выше", message="Свеча пересекла VWAP вверх и закрылась выше на 5m")
alertcondition(crossBelowVWAP, title="VWAP пересечение вниз + закрытие ниже", message="Свеча пересекла VWAP вниз и закрылась ниже на 5m")
````
