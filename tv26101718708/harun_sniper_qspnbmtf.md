# harun sniper

- url: https://www.tradingview.com/script/QSPNBMTf-harun-sniper/
- type: indicator
- pine_id: PUB;1f39f78348b84f77acbcc02a44dca1bf
- version: 1.0

## Description

When he sees the market going up too much, he tells you that it will go up. When it goes down too much, he tells you that it will go up

## Source Code

````pine
//@version=5
indicator("harun sniper", overlay=true)

// رێکخستنی RSI (هەرچەندە لەسەر چارتە سەرەکییەکەیە، بەڵام حیساباتی RSI لە پشتەوە دەکرێت)
rsiLength = input.int(56, title="RSI Length")
rsiValue = ta.rsi(close, rsiLength)

// مەرجەکانی دروستبوونی ئاماژەکان
shortCondition = ta.crossover(rsiValue, 70)
buyCondition   = ta.crossunder(rsiValue, 23)

// پیشاندانی تێکست لەسەر چارتە سەرەکییەکە (لەسەر و خوارووی مۆمەکان)
if (shortCondition)
    label.new(bar_index, high, text="شۆڕدەکاتەوە", color=color.red, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar)

if (buyCondition)
    label.new(bar_index, low, text="دەروا کاکە", color=color.green, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar)
````
