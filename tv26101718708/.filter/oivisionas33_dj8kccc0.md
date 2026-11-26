# OI_vision_AS33

- url: https://www.tradingview.com/script/Dj8kCCC0-oi-vision-as33/
- type: indicator
- pine_id: PUB;08b1fd6f6acb4db59f89e3af6fa22ae2
- version: 1.0

## Description

OI divergence
Индикатор диверов по ОИ и цене
-
-
-
-
–
–
–
–

## Source Code

````pine
//@version=6
indicator("OI_vision_AS33", overlay=true)
// =====================================================================
// CLEAR VISION AS33 — OI DIVERGENCE MODULE FIX3
// =====================================================================
// FIX3 полностью автономный:
// - не использует oiNow1m
// - не использует oiTicker
// - сам собирает OI тикер через syminfo
//
// ВСТАВКА:
// BLOCK 1 — наверх к inputs.
// BLOCK 2 — можно вставить после блока DATA или перед SCORE / STATUS.
// =====================================================================


// =====================================================================
// BLOCK 1 — INPUTS
// =====================================================================

groupDivs = "Диверы Цена / OI"

showOIDivs = input.bool(false, "Показывать диверы Цена/OI", group=groupDivs)
divPivotLen = input.int(5, "Pivot длина", minval=2, maxval=30, group=groupDivs)

showHiddenOIDivs = input.bool(true, "Показывать скрытый набор OI", group=groupDivs)
showDivLabels = input.bool(true, "Подписи диверов", group=groupDivs)

divMaxLines = input.int(20, "Макс. линий", minval=1, maxval=100, group=groupDivs)

divUseAutoOI = input.bool(true, "Авто OI тикер для диверов", group=groupDivs)
divOiTickerInp = input.string("", "OI тикер для диверов вручную", group=groupDivs)

divUpNoOIColor = input.color(color.orange, "Цена ↑ / OI ↓", group=groupDivs)
divDownOIUpColor = input.color(color.red, "Цена ↓ / OI ↑", group=groupDivs)
divHiddenColor = input.color(color.yellow, "Скрытый набор / разгрузка", group=groupDivs)


// =====================================================================
// BLOCK 2 — LOGIC
// =====================================================================

divOiTickerAuto = syminfo.prefix + ":" + syminfo.basecurrency + "USDT.P_OI"
divOiTicker = divOiTickerInp != "" ? divOiTickerInp : (divUseAutoOI ? divOiTickerAuto : "")
divOiNow = divOiTicker != "" ? request.security(divOiTicker, "1", close, ignore_invalid_symbol=true) : na

var line[] oiDivLines = array.new_line()
var label[] oiDivLabels = array.new_label()

var float prevHighPrice = na
var float prevHighOI = na
var int prevHighBar = na

var float prevLowPrice = na
var float prevLowOI = na
var int prevLowBar = na

ph = ta.pivothigh(high, divPivotLen, divPivotLen)
pl = ta.pivotlow(low, divPivotLen, divPivotLen)

newUpNoOIDiv = false
newDownOIUpDiv = false
newHiddenHighDiv = false
newHiddenLowDiv = false

if showOIDivs and not na(divOiNow)

    if not na(ph)
        curHighBar = bar_index - divPivotLen
        curHighPrice = ph
        curHighOI = divOiNow[divPivotLen]

        if not na(prevHighPrice) and not na(prevHighOI) and not na(curHighOI)

            if curHighPrice > prevHighPrice and curHighOI < prevHighOI
                l = line.new(prevHighBar, prevHighPrice, curHighBar, curHighPrice, color=divUpNoOIColor, width=2)
                array.push(oiDivLines, l)

                if showDivLabels
                    lb = label.new(curHighBar, curHighPrice, "Цена ↑ / OI ↓\nрост без OI", style=label.style_label_down, textcolor=color.white, color=color.new(divUpNoOIColor, 15), size=size.small)
                    array.push(oiDivLabels, lb)

                newUpNoOIDiv := true

            if showHiddenOIDivs and curHighPrice < prevHighPrice and curHighOI > prevHighOI
                l = line.new(prevHighBar, prevHighPrice, curHighBar, curHighPrice, color=divHiddenColor, width=1, style=line.style_dashed)
                array.push(oiDivLines, l)

                if showDivLabels
                    lb = label.new(curHighBar, curHighPrice, "OI ↑ / цена не обновляет\nскрытый набор", style=label.style_label_down, textcolor=color.black, color=color.new(divHiddenColor, 10), size=size.small)
                    array.push(oiDivLabels, lb)

                newHiddenHighDiv := true

        prevHighPrice := curHighPrice
        prevHighOI := curHighOI
        prevHighBar := curHighBar


    if not na(pl)
        curLowBar = bar_index - divPivotLen
        curLowPrice = pl
        curLowOI = divOiNow[divPivotLen]

        if not na(prevLowPrice) and not na(prevLowOI) and not na(curLowOI)

            if curLowPrice < prevLowPrice and curLowOI > prevLowOI
                l = line.new(prevLowBar, prevLowPrice, curLowBar, curLowPrice, color=divDownOIUpColor, width=2)
                array.push(oiDivLines, l)

                if showDivLabels
                    lb = label.new(curLowBar, curLowPrice, "Цена ↓ / OI ↑\nнабор против лонга", style=label.style_label_up, textcolor=color.white, color=color.new(divDownOIUpColor, 15), size=size.small)
                    array.push(oiDivLabels, lb)

                newDownOIUpDiv := true

            if showHiddenOIDivs and curLowPrice > prevLowPrice and curLowOI < prevLowOI
                l = line.new(prevLowBar, prevLowPrice, curLowBar, curLowPrice, color=divHiddenColor, width=1, style=line.style_dashed)
                array.push(oiDivLines, l)

                if showDivLabels
                    lb = label.new(curLowBar, curLowPrice, "OI ↓ / цена держится\nразгрузка", style=label.style_label_up, textcolor=color.black, color=color.new(divHiddenColor, 10), size=size.small)
                    array.push(oiDivLabels, lb)

                newHiddenLowDiv := true

        prevLowPrice := curLowPrice
        prevLowOI := curLowOI
        prevLowBar := curLowBar


    while array.size(oiDivLines) > divMaxLines
        oldLine = array.shift(oiDivLines)
        line.delete(oldLine)

    while array.size(oiDivLabels) > divMaxLines
        oldLabel = array.shift(oiDivLabels)
        label.delete(oldLabel)

alertcondition(newUpNoOIDiv, "Цена ↑ / OI ↓", "Цена обновляет high, но OI не подтверждает рост")
alertcondition(newDownOIUpDiv, "Цена ↓ / OI ↑", "Цена обновляет low, а OI растёт против лонга")
alertcondition(newHiddenHighDiv, "Скрытый набор OI сверху", "OI растёт, цена не обновляет high")
alertcondition(newHiddenLowDiv, "Разгрузка снизу", "OI падает, цена удерживает higher low")
````
