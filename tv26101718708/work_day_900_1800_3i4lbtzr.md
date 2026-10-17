# Work Day (9:00 - 18:00)

- url: https://www.tradingview.com/script/3I4lBTzr-work-day-9-00-18-00/
- type: indicator
- pine_id: PUB;197c348723be48b9b9744c5313db322e
- version: 1.0

## Description

Индикатор для тех кто живет в Европе и торгует только с 9:00 до 18:00

## Source Code

````pine
//@version=5
indicator("Рабочий день (9:00 - 18:00)", overlay=true)

// Настройки времени (можно менять в меню индикатора)
sessionInput = input.session("0900-1800", "Рабочее время", group="Настройки времени")
timeZone = input.string("UTC+3", "Часовой пояс", group="Настройки времени") // Укажите свой часовой пояс

// Проверка: находится ли текущий бар в рабочем интервале
inSession = not na(time(timeframe.period, sessionInput + ":1234567", timeZone))

// Закрашиваем фон (цвет можно настроить)
bgcolor(inSession ? color.new(color.blue, 90) : na)

// Дополнительно: линии начала и конца дня (вертикальные метки)
isStart = inSession and not inSession[1]
isEnd = not inSession and inSession[1]

plotshape(isStart, "Начало дня", shape.arrowup, location.bottom, color.green, size=size.tiny)
plotshape(isEnd, "Конец дня", shape.arrowdown, location.top, color.red, size=size.tiny)
````
