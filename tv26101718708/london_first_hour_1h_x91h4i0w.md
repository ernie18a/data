# London First Hour 1H 

- url: https://www.tradingview.com/script/x91H4I0W-london-first-hour-1h/
- type: indicator
- pine_id: PUB;4fea42a7de6f4acf8c372fa3038ae5d0
- version: 1.0

## Description

London First Hour 1H  окрашивает первую свечу открытия Лондона

## Source Code

````pine
//@version=5
indicator("London First Hour 1H Only (Full Color)", overlay=true)

// Настройки
timezone     = input.string("Europe/London", title="Часовой пояс")
candle_color = input.color(color.blue, title="Цвет часовой свечи")

// 1. Проверяем, что текущий таймфрейм равен ровно 1 часу
is_1h_timeframe = (timeframe.isminutes and timeframe.multiplier == 60)

// 2. Проверяем, что час открытия свечи равен 08:00 по Лондону
is_london_open = (hour(time, timezone) == 8)

// Условие для окрашивания
paint_candle = is_1h_timeframe and is_london_open

// Полное перекрашивание: тело, границы и фитили
plotcandle(open, high, low, close, 
           title="London Open Candle", 
           color=paint_candle ? candle_color : na, 
           wickcolor=paint_candle ? candle_color : na, 
           bordercolor=paint_candle ? candle_color : na)
````
