# Max/Min 1 hour not cross

- url: https://www.tradingview.com/script/nRJUiSy8-max-min-1-hour-not-cross/
- type: indicator
- pine_id: PUB;932b58e77e19435bb40d3b277ef838db
- version: 1.0

## Description

Max/Min 1 hour time frame not cross last 24 hour from Shynkevich Petr

## Source Code

````pine
//@version=6
indicator("Max/Min часов (с удалением при пересечении)", overlay=true)

// Запоминаем данные текущего часа
var float currentHourHigh = na
var float currentHourLow = na
var int currentHourHighBar = na
var int currentHourLowBar = na
var int currentHourNum = na

// Массивы для хранения линий и их уровней
var line[] highLines = array.new<line>()
var float[] highLevels = array.new<float>()
var line[] lowLines = array.new<line>()
var float[] lowLevels = array.new<float>()

// Текущий час
barHour = hour(time_close)

// Функция проверки и удаления пересечённых линий
checkAndDeleteBrokenLines() =>
    // Проверяем линии максимумов (только если массив не пустой)
    if array.size(highLines) > 0
        for i = array.size(highLines) - 1 to 0
            line currentLine = array.get(highLines, i)
            float level = array.get(highLevels, i)
            
            // Если цена пересекла уровень максимума
            if high >= level
                line.delete(currentLine)
                array.remove(highLines, i)
                array.remove(highLevels, i)
    
    // Проверяем линии минимумов (только если массив не пустой)
    if array.size(lowLines) > 0
        for i = array.size(lowLines) - 1 to 0
            line currentLine = array.get(lowLines, i)
            float level = array.get(lowLevels, i)
            
            // Если цена пересекла уровень минимума
            if low <= level
                line.delete(currentLine)
                array.remove(lowLines, i)
                array.remove(lowLevels, i)

// Начало нового часа
if na(currentHourNum) or barHour != currentHourNum
    
    // Фиксируем предыдущий час
    if not na(currentHourNum)
        // Добавляем линию максимума
        if not na(currentHourHighBar) and not na(currentHourHigh)
            array.push(highLines, line.new(currentHourHighBar, currentHourHigh, 
                                bar_index, currentHourHigh, 
                                color=color.new(color.green, 0), 
                                width=2, extend=extend.right))
            array.push(highLevels, currentHourHigh)
        
        // Добавляем линию минимума
        if not na(currentHourLowBar) and not na(currentHourLow)
            array.push(lowLines, line.new(currentHourLowBar, currentHourLow, 
                                bar_index, currentHourLow, 
                                color=color.new(color.red, 0), 
                                width=2, extend=extend.right))
            array.push(lowLevels, currentHourLow)
    
    // Сброс для нового часа
    currentHourNum := barHour
    currentHourHigh := high
    currentHourLow := low
    currentHourHighBar := bar_index
    currentHourLowBar := bar_index
else
    // Обновляем экстремумы текущего часа
    if high > currentHourHigh
        currentHourHigh := high
        currentHourHighBar := bar_index
    if low < currentHourLow
        currentHourLow := low
        currentHourLowBar := bar_index

// Проверяем и удаляем пересечённые линии на каждом баре
checkAndDeleteBrokenLines()

// Отладочная таблица
if barstate.islast
    var table debugTable = table.new(position.top_right, 2, 3, bgcolor=color.new(color.gray, 80))
    table.cell(debugTable, 0, 0, "Активных линий High:", text_color=color.white)
    table.cell(debugTable, 1, 0, str.tostring(array.size(highLines)), text_color=color.green)
    table.cell(debugTable, 0, 1, "Активных линий Low:", text_color=color.white)
    table.cell(debugTable, 1, 1, str.tostring(array.size(lowLines)), text_color=color.red)
    table.cell(debugTable, 0, 2, "Текущий час:", text_color=color.white)
    table.cell(debugTable, 1, 2, str.tostring(currentHourNum), text_color=color.yellow)
````
