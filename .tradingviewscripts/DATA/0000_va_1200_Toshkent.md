<!-- tradingview-pine-id: PUB;44f26b78e787403c96d5ffc9ecb250db -->
<!-- tradingviewscripts-format: 1 -->
# 00:00 va 12:00 (Toshkent)

Source: https://www.tradingview.com/script/gOjqnIJV-00-00-va-12-00-Toshkent/

## Description

//@version=6
indicator("00:00 va 12:00 (Toshkent)", overlay=true)

t = time("", "Asia/Tashkent")

h = hour(t)
m = minute(t)

if h == 19 and m == 0
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.green, width=2)

if h == 22 and m == 0
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.red, width=2)

---

## Source Code

````pine
//@version=6
indicator("00:00 va 12:00 (Toshkent)", overlay=true)

t = time("", "Asia/Tashkent")

h = hour(t)
m = minute(t)

if h == 19 and m == 0
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.green, width=2)

if h == 22 and m == 0
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.red, width=2)
````
