# harun signal

- url: https://www.tradingview.com/script/sThU6Yhu-harun-signal/
- type: indicator
- pine_id: PUB;8dcc7b80ec834e02832749d3abc3fafd
- version: 1.0

## Description

when it goes up too much, he says sell it, teacher. when it goes down too much, he says buy it, teacher.

## Source Code

````pine
//@version=5
indicator("harun signal", overlay=true)

// رێکخستنی RSI لەسەر لێنزی 28
rsiLength = input.int(28, title="RSI Length")
rsiValue = ta.rsi(close, rsiLength)

// مەرجەکانی دروستبوونی ئاماژەکان (84 بۆ فرۆشتن و 14 بۆ کڕین)
shortCondition = ta.crossover(rsiValue, 84)
buyCondition   = ta.crossunder(rsiValue, 14)

// پیشاندانی تێکست لەسەر چارتە سەرەکییەکە لەسەر و خوارووی مۆمەکان
if (shortCondition)
    label.new(bar_index, high, text="بفرۆشە مامۆستا", color=color.red, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)

if (buyCondition)
    label.new(bar_index, low, text="بکڕە مامۆستا", color=color.green, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar)

// دروستکردنی مەرجی جەرەس (Alert Conditions) بۆ ئەوەی لە لیستی جەرەسەکەدا دیار بێت
alertcondition(shortCondition, title="بفرۆشە مامۆستا (RSI >= 84)", message="RSI گەیشتە 84 - بفرۆشە مامۆستا!")
alertcondition(buyCondition, title="بکڕە مامۆستا (RSI <= 14)", message="RSI گەیشتە 14 - بکڕە مامۆستا!")
````
