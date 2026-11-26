# 50W MA

- url: https://www.tradingview.com/script/qZAHP7uy/
- type: indicator
- pine_id: PUB;1802af56e25a4700b760026b02935937
- version: 1.0

## Description

50주 이격도를 보기 편하게 나타냈습니다.

## Source Code

````pine
//@version=6
indicator("50W MA 이격도 상단 밴드 + 가격", overlay=true)

tf = input.timeframe("W", "기준 시간봉")
maLength = input.int(50, "기준 이동평균")

baseMA = request.security(syminfo.tickerid, tf, ta.sma(close, maLength))

band110 = baseMA * 1.10
band120 = baseMA * 1.20
band130 = baseMA * 1.30
band140 = baseMA * 1.40

plot(baseMA, "50W MA", color=color.aqua, linewidth=2)

plot(band110, "50W MA x 110%", color=color.green, linewidth=2)
plot(band120, "50W MA x 120%", color=color.orange, linewidth=2)
plot(band130, "50W MA x 130%", color=color.red, linewidth=2)
plot(band140, "50W MA x 140%", color=color.purple, linewidth=2)

var label lBase = na
var label l110 = na
var label l120 = na
var label l130 = na
var label l140 = na

if barstate.islast
    label.delete(lBase)
    label.delete(l110)
    label.delete(l120)
    label.delete(l130)
    label.delete(l140)

    lBase := label.new(bar_index + 5, baseMA, 
     "50W MA : " + str.tostring(baseMA, "#,###.##"), 
     style=label.style_label_left, textcolor=color.black, color=color.aqua)

    l110 := label.new(bar_index + 5, band110, 
     "110% : " + str.tostring(band110, "#,###.##"), 
     style=label.style_label_left, textcolor=color.white, color=color.green)

    l120 := label.new(bar_index + 5, band120, 
     "120% : " + str.tostring(band120, "#,###.##"), 
     style=label.style_label_left, textcolor=color.white, color=color.orange)

    l130 := label.new(bar_index + 5, band130, 
     "130% : " + str.tostring(band130, "#,###.##"), 
     style=label.style_label_left, textcolor=color.white, color=color.red)

    l140 := label.new(bar_index + 5, band140, 
     "140% : " + str.tostring(band140, "#,###.##"), 
     style=label.style_label_left, textcolor=color.white, color=color.purple)
````
