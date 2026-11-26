# Booming Bull 15 Min Strategy

- url: https://www.tradingview.com/script/pbVTDAxm-Booming-Bull-15-Min-Strategy/
- type: indicator
- pine_id: PUB;sjIIyhIH3XcddbHW6FT89GpfMdm3pm7A
- version: 2.0

## Description

[b]Booming Bull 15 Min strategy
Conditions[/b]
[list]
[*] First 15 min candle high-low must be less than .75%
[*]  Next candle is crossing either high or low
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradingconnoisseur


//@version=4
study(title="Booming Bull 15 Min Strategy", shorttitle="15MinStrategy", overlay=true)
diff_range = input(defval=75,maxval=100,minval=50, title="15 Minute Opening Range (Input/100)")
diff_range:=diff_range/100
is_newbar(res) => change(time(res)) != 0 

adopt(r, s) => security(syminfo.tickerid, r, s) 

high_range = valuewhen(is_newbar('D'),high,0)
low_range = valuewhen(is_newbar('D'),low,0)

high_rangeL = valuewhen(is_newbar('D'),high,0) 
low_rangeL = valuewhen(is_newbar('D'),low,0) 
//range=((((high_rangeL-low_rangeL)/close) <= .75) or (((low_rangeL-high_rangeL)/close) <=.75 ))

up15min=adopt('15', high_rangeL)
down15min=adopt('15', low_rangeL)
range=(high_range>low_range ?(((up15min-down15min)/close)*100 <= diff_range) : (((down15min-up15min)/close)*100 >=diff_range ))
//label.new(bar_index, high, text=tostring((up15min-down15min)/close*100))


up15 = plot(range ? adopt('15', high_rangeL): na, color = color.red, style=plot.style_line, linewidth=1)
down15 = plot(range ? adopt('15', low_rangeL): na, color = color.green, style=plot.style_line, linewidth=1) 

fill(up15, down15, color = color.white, transp=90)//,vol15)
````
