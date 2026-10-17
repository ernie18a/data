# Max/Min last hour ver. Shynkevich

- url: https://www.tradingview.com/script/4wIkW0gz-max-min-last-hour-ver-shynkevich/
- type: indicator
- pine_id: PUB;5bb8aa7f40654584a118e2824cb72e2d
- version: 1.0

## Description

Max/Min last hour ver. Shynkevich from border last hour

## Source Code

````pine
//@version=6
indicator("Max/Min предыдущего часа с границами", overlay=true)

// Запоминаем High, Low и индекс бара, где они были достигнуты
var float hourHigh = na
var float hourLow = na
var int hourHighIndex = na
var int hourLowIndex = na
var int currentHour = na

// Переменные для хранения ссылок на линии
var line prevHighLine = na
var line prevLowLine = na
var line prevVertLine = na

// Для определения высоты экрана используем максимальные цены за последние бары
screenHigh = ta.highest(high, 500)
screenLow = ta.lowest(low, 500)

// Текущий час закрытия бара
barHour = hour(time_close)

// Новый час
if na(currentHour) or barHour != currentHour
    // Удаляем старые линии
    if not na(prevHighLine)
        line.delete(prevHighLine)
    if not na(prevLowLine)
        line.delete(prevLowLine)
    if not na(prevVertLine)
        line.delete(prevVertLine)
    
    if not na(currentHour)
        // Рисуем горизонтальные линии от бара, где был максимум/минимум
        if not na(hourHighIndex)
            prevHighLine := line.new(hourHighIndex, hourHigh, bar_index, hourHigh, 
                                     color=color.new(color.green, 0), width=3, extend=extend.right)
        if not na(hourLowIndex)
            prevLowLine := line.new(hourLowIndex, hourLow, bar_index, hourLow, 
                                    color=color.new(color.red, 0), width=3, extend=extend.right)
        
        // Вертикальная граница на ВСЮ ВЫСОТУ ЭКРАНА
        // Используем screenHigh и screenLow для определения границ
        prevVertLine := line.new(bar_index[1], screenHigh, bar_index[1], screenLow, 
                                 color=color.new(color.gray, 50), width=2, style=line.style_dotted)
    
    // Сбрасываем для нового часа
    currentHour := barHour
    hourHigh := high
    hourLow := low
    hourHighIndex := bar_index
    hourLowIndex := bar_index
else
    // Обновляем максимум/минимум текущего часа и запоминаем индексы
    if high > hourHigh or na(hourHigh)
        hourHigh := high
        hourHighIndex := bar_index
    if low < hourLow or na(hourLow)
        hourLow := low
        hourLowIndex := bar_index
````
