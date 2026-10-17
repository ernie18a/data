# Price history

- url: https://www.tradingview.com/script/JwMnfpwQ-price-history/
- type: indicator
- pine_id: PUB;5fb0716ad633469d9c5e15efe624f913
- version: 3.0

## Description

Простой индикатор для сезонных инструментов (природный газ, например). Накладывает историю цены прошлых лет на текущий год. Применять на старших таймфремах.

A simple indicator for seasonal instruments, such as natural gas. It overlays historical price data from previous years onto the current year. Use it on higher timeframes.

## Source Code

````pine
//@version=6
indicator("Price history", overlay=true, max_bars_back=5000, max_polylines_count=20, max_labels_count=50)

// Индикатор накладывает кривые прошлых лет на текущий календарный год.
// Версия с опцией продления кривых прошлых лет до конца текущего года.
// Важно:
// - прошлые годы рисуются через polyline;
// - если продление выключено, линии идут только до текущей даты;
// - если продление включено, линии идут до 31 декабря базового года;
// - 29 февраля пропускается;
// - пропуски выходных/праздников можно заполнять ближайшим прошлым значением.

groupMain = "Основные настройки"
src = input.source(close, "Источник данных", group=groupMain)
useAutoBaseYear = input.bool(true, "Базовый год = текущий календарный год", group=groupMain)
manualBaseYear = input.int(2026, "Базовый год вручную", minval=1900, maxval=2100, group=groupMain)

baseYear = useAutoBaseYear ? year(timenow) : manualBaseYear

groupYears = "Годы"
showY1 = input.bool(true,  "Показать -1 год", group=groupYears)
showY2 = input.bool(true,  "Показать -2 года", group=groupYears)
showY3 = input.bool(false, "Показать -3 года", group=groupYears)
showY4 = input.bool(false, "Показать -4 года", group=groupYears)
showY5 = input.bool(false, "Показать -5 лет", group=groupYears)

groupColors = "Цвета кривых"
colorY1 = input.color(color.rgb(0, 110, 255),   "Цвет -1 год", group=groupColors)
colorY2 = input.color(color.rgb(255, 140, 0),   "Цвет -2 года", group=groupColors)
colorY3 = input.color(color.rgb(140, 70, 255),  "Цвет -3 года", group=groupColors)
colorY4 = input.color(color.rgb(0, 170, 170),   "Цвет -4 года", group=groupColors)
colorY5 = input.color(color.rgb(210, 40, 40),   "Цвет -5 лет", group=groupColors)

groupView = "Отображение"
lineWidth = input.int(2, "Толщина линий", minval=1, maxval=5, group=groupView)
extendToEndOfYear = input.bool(true, "Продлевать кривые прошлых лет до конца года", group=groupView)
showCurrentYear = input.bool(false, "Показать текущий год", group=groupView)
currentYearColor = input.color(color.gray, "Цвет текущего года", group=groupView)
showLabels = input.bool(true, "Подписывать годы справа", group=groupView)
showInfoPanel = input.bool(true, "Показать инфопанель", group=groupView)

groupGaps = "Разрывы"
fillMissingDates = input.bool(true, "Заполнять пропуски ближайшим прошлым значением", group=groupGaps)
maxBackDays = input.int(7, "Максимум дней назад для заполнения", minval=1, maxval=14, group=groupGaps)

// День года в обычном 365-дневном календаре.
// Високосное 29 февраля пропускается.
// Все даты после 29 февраля получают такой же номер, как в обычном году.
f_day_index(int t) =>
    int m = month(t)
    int d = dayofmonth(t)
    int base = switch m
        1  => 0
        2  => 31
        3  => 59
        4  => 90
        5  => 120
        6  => 151
        7  => 181
        8  => 212
        9  => 243
        10 => 273
        11 => 304
        12 => 334
    base + d

f_month_from_day_index(int idx) =>
    int result = 12
    if idx <= 31
        result := 1
    else if idx <= 59
        result := 2
    else if idx <= 90
        result := 3
    else if idx <= 120
        result := 4
    else if idx <= 151
        result := 5
    else if idx <= 181
        result := 6
    else if idx <= 212
        result := 7
    else if idx <= 243
        result := 8
    else if idx <= 273
        result := 9
    else if idx <= 304
        result := 10
    else if idx <= 334
        result := 11
    result

f_day_from_day_index(int idx) =>
    int m = f_month_from_day_index(idx)
    int offset = switch m
        1  => 0
        2  => 31
        3  => 59
        4  => 90
        5  => 120
        6  => 151
        7  => 181
        8  => 212
        9  => 243
        10 => 273
        11 => 304
        12 => 334
    idx - offset

f_get_value(float[] arr, int idx, bool fillGaps, int maxBack) =>
    float result = na
    int limit = fillGaps ? maxBack : 0
    for offset = 0 to limit
        int checkIdx = idx - offset
        if checkIdx >= 1 and checkIdx <= 365 and na(result)
            float candidate = array.get(arr, checkIdx)
            if not na(candidate)
                result := candidate
    result

f_max_draw_day(int drawYear, bool extendFullYear) =>
    int result = 365
    if not extendFullYear
        int currentYear = year(timenow)
        if drawYear == currentYear
            result := math.min(365, f_day_index(timenow))
        else if drawYear < currentYear
            result := 365
        else
            result := 0
    result

f_make_points(float[] arr, int drawYear, bool fillGaps, int maxBack, bool extendFullYear) =>
    array<chart.point> points = array.new<chart.point>()
    int maxDay = f_max_draw_day(drawYear, extendFullYear)
    if maxDay >= 1
        for idx = 1 to maxDay
            float value = f_get_value(arr, idx, fillGaps, maxBack)
            if not na(value)
                int m = f_month_from_day_index(idx)
                int d = f_day_from_day_index(idx)
                int t = timestamp(syminfo.timezone, drawYear, m, d, 0, 0)
                array.push(points, chart.point.from_time(t, value))
    points

f_update_polyline(polyline oldLine, bool isShown, float[] arr, color lineColor) =>
    if not na(oldLine)
        polyline.delete(oldLine)
    polyline newLine = na
    if isShown
        array<chart.point> points = f_make_points(arr, baseYear, fillMissingDates, maxBackDays, extendToEndOfYear)
        if array.size(points) >= 2
            newLine := polyline.new(points, curved=false, closed=false, xloc=xloc.bar_time, line_color=lineColor, line_width=lineWidth)
    newLine

barYear = year(time)
isFeb29 = month(time) == 2 and dayofmonth(time) == 29
dayIndex = f_day_index(time)
inBaseYear = barYear == baseYear and not isFeb29

var float[] dataY1 = array.new_float(366, na)
var float[] dataY2 = array.new_float(366, na)
var float[] dataY3 = array.new_float(366, na)
var float[] dataY4 = array.new_float(366, na)
var float[] dataY5 = array.new_float(366, na)

// Запоминаем значения прошлых лет.
// 29 февраля не сохраняется.
if not isFeb29 and dayIndex >= 1 and dayIndex <= 365
    if barYear == baseYear - 1
        array.set(dataY1, dayIndex, src)
    if barYear == baseYear - 2
        array.set(dataY2, dayIndex, src)
    if barYear == baseYear - 3
        array.set(dataY3, dayIndex, src)
    if barYear == baseYear - 4
        array.set(dataY4, dayIndex, src)
    if barYear == baseYear - 5
        array.set(dataY5, dayIndex, src)

// Текущий год можно показать обычной линией только по уже существующим барам.
valueCurrentYear = inBaseYear and showCurrentYear ? src : na
plot(valueCurrentYear, "Текущий год", color=currentYearColor, linewidth=lineWidth, style=plot.style_line)

// Кривые прошлых лет строятся объектами polyline.
// Опция extendToEndOfYear управляет тем, рисовать ли их до 31 декабря.
var polyline polyY1 = na
var polyline polyY2 = na
var polyline polyY3 = na
var polyline polyY4 = na
var polyline polyY5 = na

if barstate.islast
    polyY1 := f_update_polyline(polyY1, showY1, dataY1, colorY1)
    polyY2 := f_update_polyline(polyY2, showY2, dataY2, colorY2)
    polyY3 := f_update_polyline(polyY3, showY3, dataY3, colorY3)
    polyY4 := f_update_polyline(polyY4, showY4, dataY4, colorY4)
    polyY5 := f_update_polyline(polyY5, showY5, dataY5, colorY5)

// Подписи годов ставятся на конец линии:
// - если продление включено, на 31 декабря;
// - если выключено, на текущую дату.
f_label_day_index() =>
    extendToEndOfYear ? 365 : f_max_draw_day(baseYear, false)

f_label_time() =>
    int idx = f_label_day_index()
    int m = f_month_from_day_index(idx)
    int d = f_day_from_day_index(idx)
    timestamp(syminfo.timezone, baseYear, m, d, 0, 0)

f_label_value(float[] arr) =>
    int idx = f_label_day_index()
    f_get_value(arr, idx, true, 30)

f_update_label(label oldLabel, bool isShown, float value, string labelText, color labelColor) =>
    label result = oldLabel
    if barstate.islast
        label.delete(result)
        result := na
        if showLabels and isShown and not na(value)
            result := label.new(x=f_label_time(), y=value, xloc=xloc.bar_time, text=labelText, style=label.style_label_left, textcolor=color.white, color=labelColor, size=size.small)
    result

var label labelY1 = na
var label labelY2 = na
var label labelY3 = na
var label labelY4 = na
var label labelY5 = na

labelY1 := f_update_label(labelY1, showY1, f_label_value(dataY1), str.tostring(baseYear - 1), colorY1)
labelY2 := f_update_label(labelY2, showY2, f_label_value(dataY2), str.tostring(baseYear - 2), colorY2)
labelY3 := f_update_label(labelY3, showY3, f_label_value(dataY3), str.tostring(baseYear - 3), colorY3)
labelY4 := f_update_label(labelY4, showY4, f_label_value(dataY4), str.tostring(baseYear - 4), colorY4)
labelY5 := f_update_label(labelY5, showY5, f_label_value(dataY5), str.tostring(baseYear - 5), colorY5)

var table infoPanel = table.new(position.top_right, 1, 1)

if barstate.islast and showInfoPanel
    extendText = extendToEndOfYear ? "до 31 декабря" : "до текущей даты"
    infoText = "Базовый год: " + str.tostring(baseYear) + "\n-1 год: " + str.tostring(baseYear - 1) + "\n-2 года: " + str.tostring(baseYear - 2) + "\n-3 года: " + str.tostring(baseYear - 3) + "\n-4 года: " + str.tostring(baseYear - 4) + "\n-5 лет: " + str.tostring(baseYear - 5) + "\nКривые прошлых лет: " + extendText + "\n29 февраля: пропуск" + "\nПропуски: заполнение до " + str.tostring(maxBackDays) + " дней"
    table.cell(table_id=infoPanel, column=0, row=0, text=infoText, text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
````
