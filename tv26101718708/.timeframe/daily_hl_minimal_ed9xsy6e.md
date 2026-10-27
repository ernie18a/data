# Daily H/L [Minimal]

- url: https://www.tradingview.com/script/Ed9XSy6E-daily-h-l-minimal/
- type: indicator
- pine_id: PUB;145e5ca1b68247e9aba9127267e86eb1
- version: 1.0

## Description

Вчерашние High/Low — пунктирные линии на весь день с маленькой прозрачной подложкой и ценой.

Сегодняшние High/Low — тонкая сплошная линия (обновляется внутри дня), без лишнего шума.

Всё можно гибко настроить в меню.

## Source Code

````pine
//@version=5
indicator("Daily H/L [Minimal]", overlay=true, max_labels_count=500)

// ── Настройки ─────────────────────────────────
showPrev   = input.bool(true, "Вчерашние High/Low")
showToday  = input.bool(true, "Сегодняшние High/Low")
prevStyle  = input.string("Dashed", "Стиль вчерашних", options=["Solid","Dashed","Dotted"])
prevColorH = input.color(color.new(#ff5c5c, 30), "Цвет вчерашнего High")
prevColorL = input.color(color.new(#5cba5c, 30), "Цвет вчерашнего Low")
todayColorH = input.color(color.new(#ff5c5c, 60), "Цвет сегодня High")
todayColorL = input.color(color.new(#5cba5c, 60), "Цвет сегодня Low")
labelSize   = input.string(size.small, "Размер меток", options=[size.auto, size.tiny, size.small, size.normal])

// ── Логика ────────────────────────────────────
getLineStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

// Предыдущий день
prevHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
prevLow  = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_on)

// Сегодня (нарастающий)
todayHigh = request.security(syminfo.tickerid, "D", high, barmerge.gaps_off, barmerge.lookahead_on)
todayLow  = request.security(syminfo.tickerid, "D", low,  barmerge.gaps_off, barmerge.lookahead_on)

// ── Отрисовка ─────────────────────────────────
if showPrev and barstate.islast
    // Линии
    line.new(bar_index[1], prevHigh, bar_index, prevHigh, color=prevColorH, style=getLineStyle(prevStyle), width=1)
    line.new(bar_index[1], prevLow,  bar_index, prevLow,  color=prevColorL, style=getLineStyle(prevStyle), width=1)
    // Метки с ценой
    label.new(bar_index, prevHigh, text="PDH " + str.tostring(prevHigh, format.mintick), 
              color=color.new(color.gray, 90), textcolor=prevColorH, style=label.style_label_lower_right, size=labelSize)
    label.new(bar_index, prevLow,  text="PDL " + str.tostring(prevLow, format.mintick), 
              color=color.new(color.gray, 90), textcolor=prevColorL, style=label.style_label_upper_right, size=labelSize)

if showToday and barstate.islast
    line.new(bar_index, todayHigh, bar_index+1, todayHigh, color=todayColorH, style=line.style_solid, width=1)
    line.new(bar_index, todayLow,  bar_index+1, todayLow,  color=todayColorL, style=line.style_solid, width=1)
    label.new(bar_index, todayHigh, text="H " + str.tostring(todayHigh, format.mintick), 
              color=color.new(color.gray, 95), textcolor=todayColorH, style=label.style_label_lower_right, size=labelSize)
    label.new(bar_index, todayLow,  text="L " + str.tostring(todayLow, format.mintick), 
              color=color.new(color.gray, 95), textcolor=todayColorL, style=label.style_label_upper_right, size=labelSize)
````
