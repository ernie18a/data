# Institutional SMC [Seiltanzer Edition]

- url: https://www.tradingview.com/script/YHL7Eb54-institutional-smc-seiltanzer-edition/
- type: indicator
- pine_id: PUB;f4dcff8f2e4c4f7b9cc5ab3f6aed2d56
- version: 1.0

## Description

FVG indicator for alerts
FVG indicator for alerts
FVG indicator for alerts
FVG indicator for alerts

## Source Code

````pine
//@version=6
indicator("Institutional SMC [CTO Edition]", overlay=true, max_boxes_count=500)

// =====================================================================
// ПРАВИЛО АРХИТЕКТОРА 1: ЗАЩИТА ОТ ПЕРЕРИСОВКИ (No Repainting)
// =====================================================================
is_closed = barstate.isconfirmed

// =====================================================================
// ЛОГИКА: Поиск FVG (Fair Value Gaps - Имбалансы)
// =====================================================================
bullish_fvg = is_closed and low > high[2] and close[1] > open[1]
bearish_fvg = is_closed and high < low[2] and close[1] < open[1]

// Массив для хранения АКТИВНЫХ зон имбаланса
var box[] fvg_boxes = array.new_box()

if bullish_fvg
    // Бычий имбаланс: дыра между high 1-й свечи и low 3-й
    b = box.new(left=bar_index[2], top=low, right=bar_index, bottom=high[2], border_color=color.new(color.green, 50), bgcolor=color.new(color.green, 80))
    array.push(fvg_boxes, b)

if bearish_fvg
    // Медвежий имбаланс: дыра между low 1-й свечи и high 3-й
    b = box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high, border_color=color.new(color.red, 50), bgcolor=color.new(color.red, 80))
    array.push(fvg_boxes, b)

// =====================================================================
// ПРАВИЛО АРХИТЕКТОРА 2: ПРОДЛЕНИЕ ЗОН И МИТИГАЦИЯ (Mitigation)
// =====================================================================
// Мы проходим по всем нашим зонам в массиве. 
// Если цена еще не заполнила зону, мы тянем её вправо.
// Если цена коснулась зоны (перекрыла её), мы прекращаем её тянуть.
if array.size(fvg_boxes) > 0
    for i = array.size(fvg_boxes) - 1 to 0
        b = array.get(fvg_boxes, i)
        
        top = box.get_top(b)
        bottom = box.get_bottom(b)
        
        // Проверка: коснулась ли текущая свеча границ нашей зоны?
        is_mitigated = (low <= top and high >= bottom)
        
        if not is_mitigated
            // Зона свежая -> тянем коробку вправо до текущей свечи
            box.set_right(b, bar_index)
        else
            // Зона отработала -> удаляем из отслеживаемого массива
            // Коробка останется на графике как история, но перестанет удлиняться!
            array.remove(fvg_boxes, i)
````
