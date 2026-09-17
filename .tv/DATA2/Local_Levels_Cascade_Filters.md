<!-- tradingview-pine-id: PUB;369d5d2cb171479faa9a78eb8fa93f91 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Local Levels (Cascade + Filters)

Source: https://www.tradingview.com/script/rbAGPghT-local-levels-cascade-filters/

## Description

Script Name: Local Levels (Cascade + Filters)

Short Description (for publication):

Local Levels is a powerful tool for visually identifying horizontal support and resistance levels (shelves) based on local swing highs and lows. The script automatically detects "cascades" of levels (as seen in the screenshot) and allows you to filter them by age and volume.

It is ideal for scalping and intraday trading, helping you quickly identify key zones where price might bounce or break out. The script includes built-in filters to weed out weak and "noisy" levels, as well as flexible signal settings for alerts.

List of Settings and Their Functions:

1. Structure Settings (Level Detection):

Pivot Strength (Bars Left) — Determines how many bars to the left are required to confirm a local extreme (the higher the value, the stronger the level).

Low Confirmation (Bars Right) — How many bars must pass after the pivot forms for the level to be considered confirmed.

Cascade History Depth (Max 60) — The maximum number of levels displayed on the chart at once.

2. Age Filter (Alert Filter):

Line Age Filter (From X and above) — Allows you to ignore "fresh" levels. You can set a threshold (e.g., 50+, 100+) to only receive signals on levels that have been around long enough and tested by time.

3. Volume Filter (Volume Filter):

Enable Volume Filter — Activates level filtering based on trading volume.

Volume Threshold (x Average) — Keeps only those levels where the volume at the formation bar was higher than the average by the specified multiplier. This filters out "empty" levels.

4. Signal Selection (Alert Management):

Signal on Break of GREEN levels — Enables/disables signals and labels (✕) when the price breaks below support levels.

Signal on Break of RED levels — Enables/disables signals and labels (✕) when the price breaks above resistance levels.

Strict Close Beyond Level (By Close) — If ON: the signal triggers only when the candle closes beyond the level. If OFF: the signal triggers on a simple touch of the level by the price (more sensitive).

5. Offset & Visibility (Visuals):

Shift All Lines Up (in %) — Moves all lines vertically up by a specified percentage. Useful when levels overlap the price.

Show GREEN levels / Show RED levels — Toggles the display of the corresponding lines on the chart. If turned off, the script will stop drawing and looking for those levels.

---

## Source Code

````pine
//@version=6
indicator('Local Levels (Cascade + Filters)', shorttitle = 'Local Levels', overlay = true, max_lines_count = 500)

// --- НАСТРОЙКИ СТРУКТУРЫ ---
leftBars = input.int(25, title = 'Pivot Strength (Bars Left)')
rightBars = input.int(3, title = 'Low Confirmation (Bars Right)')
maxHistory = input.int(60, title = 'Cascade History Depth (Max 60)')

// --- НАСТРОЙКИ ФИЛЬТРА ВОЗРАСТА ---
filterMode = input.string('50+', title = 'Line Age Filter (From X and above)', options = ['Off', '30+', '50+', '80+', '100+', '150+', '200+', 'Custom'], group = 'Alert Filter')
customFilter = input.int(60, title = 'Custom Value (From X and above)', minval = 1, step = 5, group = 'Alert Filter')

int filterValue = 0
switch filterMode
    'Off' => 
	    filterValue := 0
	    filterValue
    '30+' => 
	    filterValue := 30
	    filterValue
    '50+' => 
	    filterValue := 50
	    filterValue
    '80+' => 
	    filterValue := 80
	    filterValue
    '100+' => 
	    filterValue := 100
	    filterValue
    '150+' => 
	    filterValue := 150
	    filterValue
    '200+' => 
	    filterValue := 200
	    filterValue
    'Custom' => 
	    filterValue := customFilter
	    filterValue

// --- НАСТРОЙКИ ФИЛЬТРА ПО ОБЪЕМУ ---
useVolumeFilter = input.bool(false, title = 'Enable Volume Filter', group = 'Volume Filter', tooltip = 'Enable to show only lines with volume above the specified threshold')
volumeThreshold = input.float(1.0, title = 'Volume Threshold (x Average)', minval = 0.1, maxval = 5.0, step = 0.1, group = 'Volume Filter', tooltip = 'Show lines where volume at the formation bar is higher than the average by N times')

// --- КНОПКИ ВЫБОРА СИГНАЛОВ И РЕЖИМА ---
signalGreen = input.bool(true, title = 'Signal on Break of GREEN levels', group = 'Signal Selection')
signalRed = input.bool(true, title = 'Signal on Break of RED levels', group = 'Signal Selection')
useCloseBreak = input.bool(false, title = 'Strict Close Beyond Level (By Close)', group = 'Signal Selection', tooltip = 'ON - signal only when candle closes beyond level. OFF - signal on touch (low/high)')

// --- КНОПКИ СМЕЩЕНИЯ И ВИДИМОСТИ ---
shiftUpPercent = input.float(0.0, title = 'Shift All Lines Up (in %)', minval = 0.0, maxval = 50.0, step = 0.1)
showGreen = input.bool(true, title = 'Show GREEN levels')
showRed = input.bool(true, title = 'Show RED levels')

// --- ФУНКЦИЯ ДЛЯ РАСЧЕТА СРЕДНЕГО ОБЪЕМА ---
getAverageVolume(int length) =>
    float sum = 0.0
    for i = 0 to length - 1 by 1
        sum := sum + volume[i]
        sum
    sum / length

// --- МАССИВЫ (ЗЕЛЁНЫЕ) ---
var array<line> greenLines = array.new_line()
var array<int> startBars = array.new_int()
var array<int> confirmBars = array.new_int()
var array<float> greenPrices = array.new_float()
var array<bool> isG_Broken = array.new_bool()
var array<int> breakBars = array.new_int()
var array<float> greenVolumes = array.new_float()

// --- МАССИВЫ (КРАСНЫЕ) ---
var array<line> redLines = array.new_line()
var array<int> startBarsRed = array.new_int()
var array<int> confirmBarsRed = array.new_int()
var array<float> redPrices = array.new_float()
var array<bool> isR_Broken = array.new_bool()
var array<int> breakBarsRed = array.new_int()
var array<float> redVolumes = array.new_float()

// --- ПЕРЕМЕННЫЕ ДЛЯ ОТСЛЕЖИВАНИЯ СОСТОЯНИЯ КНОПОК ---
var bool prevShowGreen = true
var bool prevShowRed = true
var bool prevUseVolumeFilter = false
var float prevVolumeThreshold = 1.0
var bool needRedraw = false

// --- ПОИСК ЗЕЛЁНЫХ ПОЛОК (ЛОУ) ---
pivotL = ta.pivotlow(low, leftBars, rightBars)
if not na(pivotL)
    int pIdx = bar_index - rightBars
    int pConfirmIdx = bar_index
    float shiftedPivot = pivotL * (1 + shiftUpPercent / 100)
    float volumeAtPivot = volume[rightBars]

    if showGreen
        bool volumeCondition = true
        if useVolumeFilter
            float avgVol = getAverageVolume(20)
            volumeCondition := volumeAtPivot > avgVol * volumeThreshold
            volumeCondition

        if volumeCondition
            line gL = line.new(pIdx, shiftedPivot, bar_index, shiftedPivot, color = color.green, width = 2)
            array.push(greenLines, gL)
            array.push(startBars, pIdx)
            array.push(confirmBars, pConfirmIdx)
            array.push(greenPrices, shiftedPivot)
            array.push(isG_Broken, false)
            array.push(breakBars, 0)
            array.push(greenVolumes, volumeAtPivot)

            if array.size(greenLines) > maxHistory
                line.delete(array.shift(greenLines))
                array.shift(startBars)
                array.shift(confirmBars)
                array.shift(greenPrices)
                array.shift(isG_Broken)
                array.shift(breakBars)
                array.shift(greenVolumes)

// --- ПОИСК КРАСНЫХ ПОЛОК (ХАИ) ---
pivotH = ta.pivothigh(high, leftBars, rightBars)
if not na(pivotH)
    int pIdx = bar_index - rightBars
    int pConfirmIdx = bar_index
    float shiftedPivot = pivotH * (1 + shiftUpPercent / 100)
    float volumeAtPivot = volume[rightBars]

    if showRed
        bool volumeCondition = true
        if useVolumeFilter
            float avgVol = getAverageVolume(20)
            volumeCondition := volumeAtPivot > avgVol * volumeThreshold
            volumeCondition

        if volumeCondition
            line rL = line.new(pIdx, shiftedPivot, bar_index, shiftedPivot, color = color.red, width = 2)
            array.push(redLines, rL)
            array.push(startBarsRed, pIdx)
            array.push(confirmBarsRed, pConfirmIdx)
            array.push(redPrices, shiftedPivot)
            array.push(isR_Broken, false)
            array.push(breakBarsRed, 0)
            array.push(redVolumes, volumeAtPivot)

            if array.size(redLines) > maxHistory
                line.delete(array.shift(redLines))
                array.shift(startBarsRed)
                array.shift(confirmBarsRed)
                array.shift(redPrices)
                array.shift(isR_Broken)
                array.shift(breakBarsRed)
                array.shift(redVolumes)

// --- ОБРАБОТКА ИЗМЕНЕНИЙ СОСТОЯНИЯ КНОПОК ВИДИМОСТИ ---
if prevShowGreen and not showGreen
    for i = array.size(greenLines) - 1 to 0 by 1
        line gL = array.get(greenLines, i)
        if not na(gL)
            line.delete(gL)
    array.clear(greenLines)
    array.clear(startBars)
    array.clear(confirmBars)
    array.clear(greenPrices)
    array.clear(isG_Broken)
    array.clear(breakBars)
    array.clear(greenVolumes)
prevShowGreen := showGreen

if prevShowRed and not showRed
    for i = array.size(redLines) - 1 to 0 by 1
        line rL = array.get(redLines, i)
        if not na(rL)
            line.delete(rL)
    array.clear(redLines)
    array.clear(startBarsRed)
    array.clear(confirmBarsRed)
    array.clear(redPrices)
    array.clear(isR_Broken)
    array.clear(breakBarsRed)
    array.clear(redVolumes)
prevShowRed := showRed

// --- ОБРАБОТКА ИЗМЕНЕНИЙ ФИЛЬТРА ОБЪЕМА (ПЕРЕРИСОВКА) ---
if prevUseVolumeFilter != useVolumeFilter or prevVolumeThreshold != volumeThreshold
    needRedraw := true
    // Удаляем все линии
    if array.size(greenLines) > 0
        for i = array.size(greenLines) - 1 to 0 by 1
            line gL = array.get(greenLines, i)
            if not na(gL)
                line.delete(gL)
        array.clear(greenLines)
        array.clear(startBars)
        array.clear(confirmBars)
        array.clear(greenPrices)
        array.clear(isG_Broken)
        array.clear(breakBars)
        array.clear(greenVolumes)

    if array.size(redLines) > 0
        for i = array.size(redLines) - 1 to 0 by 1
            line rL = array.get(redLines, i)
            if not na(rL)
                line.delete(rL)
        array.clear(redLines)
        array.clear(startBarsRed)
        array.clear(confirmBarsRed)
        array.clear(redPrices)
        array.clear(isR_Broken)
        array.clear(breakBarsRed)
        array.clear(redVolumes)

prevUseVolumeFilter := useVolumeFilter
prevVolumeThreshold := volumeThreshold

// --- ПЕРЕРИСОВКА ИСТОРИИ ПРИ ИЗМЕНЕНИИ ФИЛЬТРОВ (ОПТИМИЗИРОВАНО) ---
if needRedraw and barstate.isconfirmed
    // Проходим по всей истории и ищем пивоты заново
    for i = 0 to bar_index by 1
        // Зеленые
        if i >= leftBars + rightBars
            float pivotLow = ta.pivotlow(low, leftBars, rightBars)[i - rightBars]
            if not na(pivotLow)
                int pIdx = i - rightBars
                float shiftedPivot = pivotLow * (1 + shiftUpPercent / 100)
                float volumeAtPivot = volume[rightBars]

                bool volumeCondition = true
                if useVolumeFilter
                    float avgVol = getAverageVolume(20)
                    volumeCondition := volumeAtPivot > avgVol * volumeThreshold
                    volumeCondition

                if volumeCondition and showGreen
                    line gL = line.new(pIdx, shiftedPivot, i, shiftedPivot, color = color.green, width = 2)
                    array.push(greenLines, gL)
                    array.push(startBars, pIdx)
                    array.push(confirmBars, i)
                    array.push(greenPrices, shiftedPivot)
                    array.push(isG_Broken, false)
                    array.push(breakBars, 0)
                    array.push(greenVolumes, volumeAtPivot)

                    if array.size(greenLines) > maxHistory
                        line.delete(array.shift(greenLines))
                        array.shift(startBars)
                        array.shift(confirmBars)
                        array.shift(greenPrices)
                        array.shift(isG_Broken)
                        array.shift(breakBars)
                        array.shift(greenVolumes)

        // Красные
        if i >= leftBars + rightBars
            float pivotHigh = ta.pivothigh(high, leftBars, rightBars)[i - rightBars]
            if not na(pivotHigh)
                int pIdx = i - rightBars
                float shiftedPivot = pivotHigh * (1 + shiftUpPercent / 100)
                float volumeAtPivot = volume[rightBars]

                bool volumeCondition = true
                if useVolumeFilter
                    float avgVol = getAverageVolume(20)
                    volumeCondition := volumeAtPivot > avgVol * volumeThreshold
                    volumeCondition

                if volumeCondition and showRed
                    line rL = line.new(pIdx, shiftedPivot, i, shiftedPivot, color = color.red, width = 2)
                    array.push(redLines, rL)
                    array.push(startBarsRed, pIdx)
                    array.push(confirmBarsRed, i)
                    array.push(redPrices, shiftedPivot)
                    array.push(isR_Broken, false)
                    array.push(breakBarsRed, 0)
                    array.push(redVolumes, volumeAtPivot)

                    if array.size(redLines) > maxHistory
                        line.delete(array.shift(redLines))
                        array.shift(startBarsRed)
                        array.shift(confirmBarsRed)
                        array.shift(redPrices)
                        array.shift(isR_Broken)
                        array.shift(breakBarsRed)
                        array.shift(redVolumes)
    needRedraw := false
    needRedraw

// --- ПЕРЕМЕННЫЕ ДЛЯ АЛЕРТА ---
var bool alertTriggered = false
var float alertPrice = 0.0
var string alertLineType = ''

// --- ОБРАБОТКА ЗЕЛЁНЫХ ЛИНИЙ ---
if signalGreen and array.size(greenLines) > 0
    for i = array.size(greenLines) - 1 to 0 by 1
        line gL = array.get(greenLines, i)
        float gPrice = array.get(greenPrices, i)
        bool gBroken = array.get(isG_Broken, i)
        int pConfirmIdx = array.get(confirmBars, i)

        if not gBroken
            bool breakCondition = useCloseBreak ? close < gPrice : low < gPrice
            if breakCondition
                if not na(gL)
                    line.set_x2(gL, bar_index)
                array.set(isG_Broken, i, true)
                array.set(breakBars, i, bar_index)

                if barstate.isconfirmed
                    int barsAge = bar_index - pConfirmIdx
                    if filterValue == 0 or barsAge >= filterValue
                        label.new(bar_index, low, text = '✕', style = label.style_label_up, color = color.new(color.green, 70), textcolor = color.green, size = size.tiny)
                        alertTriggered := true
                        alertPrice := low
                        alertLineType := 'GREEN (BREAK)'
                        alertLineType
            else
                if not na(gL)
                    line.set_x2(gL, bar_index)
        else
            int breakBarIdx = array.get(breakBars, i)
            if not na(gL)
                line.set_x2(gL, breakBarIdx)

// --- ОБРАБОТКА КРАСНЫХ ЛИНИЙ ---
if signalRed and array.size(redLines) > 0
    for i = array.size(redLines) - 1 to 0 by 1
        line rL = array.get(redLines, i)
        float rPrice = array.get(redPrices, i)
        bool rBroken = array.get(isR_Broken, i)
        int pConfirmIdx = array.get(confirmBarsRed, i)

        if not rBroken
            bool breakCondition = useCloseBreak ? close > rPrice : high > rPrice
            if breakCondition
                if not na(rL)
                    line.set_x2(rL, bar_index)
                array.set(isR_Broken, i, true)
                array.set(breakBarsRed, i, bar_index)

                if barstate.isconfirmed
                    int barsAge = bar_index - pConfirmIdx
                    if filterValue == 0 or barsAge >= filterValue
                        label.new(bar_index, high, text = '✕', style = label.style_label_down, color = color.new(color.red, 70), textcolor = color.red, size = size.tiny)
                        alertTriggered := true
                        alertPrice := high
                        alertLineType := 'RED (BREAK)'
                        alertLineType
            else
                if not na(rL)
                    line.set_x2(rL, bar_index)
        else
            int breakBarIdx = array.get(breakBarsRed, i)
            if not na(rL)
                line.set_x2(rL, breakBarIdx)

// --- ОТПРАВКА АЛЕРТА ---
if alertTriggered and barstate.isconfirmed
    alert('CASCADE: ' + alertLineType + ' at price ' + str.tostring(alertPrice, format.mintick) + ' (filter ' + str.tostring(filterValue) + '+)', alert.freq_once_per_bar_close)

// --- СБРОС ТРИГГЕРА ---
if barstate.isnew
    alertTriggered := false
    alertTriggered
````
