# SMA/EMA/Pivots - TRP

- url: https://www.tradingview.com/script/MdWC5qc7-SMA-EMA-Pivots-TRP/
- type: indicator
- pine_id: PUB;4db1bf7470b541f0a3920163aff89280
- version: 1.0

## Description

This is consolidated version of EMA 9, 21 and SMA 50, 100 and 200

## Source Code

````pine
//@version=6
indicator("SMA/EMA/Pivots", overlay = true)

//EMA Code
ema_length1 = input(9)
ema_length2 = input(21)

ema1 = ta.ema(close, ema_length1)
ema2 = ta.ema(close, ema_length2)

plot(ema1, color = color.new(color.green, 0), linewidth = 2, title="ema_length1")
plot(ema2, color = color.new(color.red, 0), linewidth = 2, title="ema_length2")


//SMA Code
sma_length1 = input(50)
sma_length2 = input(100)
sma_length3 = input(200)

short50 = ta.sma(close, sma_length1)
plot(short50, color = close >= short50 ? color.blue : color.orange, linewidth = 2, title="sma_length1")

long100 = ta.sma(close, sma_length2)
plot(long100, color = close >= long100 ? color.blue : color.orange, linewidth = 3, title="sma_length2")

long200 = ta.sma(close, sma_length3)
plot(long200, color = close >= long200 ? color.blue : color.orange, linewidth = 4, title="sma_length3")

//Pivots Code
lengthGroupTitle = "LENGTH LEFT / RIGHT"
colorGroupTitle = "Text Color / Label Color"
leftLenH = input.int(title="Pivot High", defval=10, minval=1, inline="Pivot High", group=lengthGroupTitle)
rightLenH = input.int(title="/", defval=10, minval=1, inline="Pivot High", group=lengthGroupTitle)
textColorH = input(title="Pivot High", defval=color.black, inline="Pivot High", group=colorGroupTitle)
labelColorH = input(title="", defval=color.white, inline="Pivot High", group=colorGroupTitle)

leftLenL = input.int(title="Pivot Low", defval=10, minval=1, inline="Pivot Low", group=lengthGroupTitle)
rightLenL = input.int(title="/", defval=10, minval=1, inline="Pivot Low", group=lengthGroupTitle)
textColorL = input(title="Pivot Low", defval=color.black, inline="Pivot Low", group=colorGroupTitle)
labelColorL = input(title="", defval=color.white, inline="Pivot Low", group=colorGroupTitle)

ph = ta.pivothigh(leftLenH, rightLenH)
pl = ta.pivotlow(leftLenL, rightLenL)

drawLabel(_offset, _pivot, _style, _color, _textColor) =>
    if not na(_pivot)
        label.new(bar_index[_offset], _pivot, str.tostring(_pivot, format.mintick), style=_style, color=_color, textcolor=_textColor)

drawLabel(rightLenH, ph, label.style_label_down, labelColorH, textColorH)
drawLabel(rightLenL, pl, label.style_label_up, labelColorL, textColorL)
````
