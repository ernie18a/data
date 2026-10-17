# 4H Session Grid

- url: https://www.tradingview.com/script/lVHb3xhO-4h-session-grid/
- type: indicator
- pine_id: PUB;1db13a369faf4a06acf904c06ccd3908
- version: 1.0

## Description

Этот индикатор представляет собой автоматическую вертикальную разметку 4Ч свечей, видно только на 15М. Индикатор находит момент начала каждой новой 4-часовой свечи (согласно времени сервера биржи) и проводит в этом месте бесконечную вертикальную линию. На 15-минутном графике легко «потеряться» в шуме. Вертикальные линии показывают границы крупных временных блоков.

## Source Code

````pine
//@version=6
indicator("4H Session Grid", overlay = true)

// Проверяем, является ли текущий таймфрейм 15-минутным
// "15" — это строковое значение для 15 минут в Pine Script
isM15 = timeframe.period == "15"

// Получаем время открытия 4-часового бара
t4h = time("240")

// Проверяем, изменилось ли время (наступил ли новый 4Ч бар)
new4H = ta.change(t4h) != 0

// Рисуем вертикальную линию только если это 15М и наступил новый 4Ч бар
if isM15 and new4H
    line.new(bar_index, 0, bar_index, 100, xloc=xloc.bar_index, extend=extend.both, color=color.new(color.blue, 70), style=line.style_solid, width=1)
````
