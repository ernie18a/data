<!-- tradingview-pine-id: PUB;3260c1817e9642df93eae2a51a8e6fc1 -->
<!-- tradingviewscripts-format: 1 -->
# NY Open Line

Source: https://www.tradingview.com/script/brvgldEj-NY-Open-Line-09-30-KO-by-MSJ/

## Description

simple vertical line marking NY open
shows every open
i use it for tapereading

---

## Source Code

````pine
//@version=6
indicator("NY Open Line", overlay = true)

// Innstillinger
sessTime = input.session("0930-0931", "NY Open Time")
lineColor = input.color(color.yellow, "Linjefarge")
lineWidth = input.int(1, "Linjebredde", minval = 1, maxval = 5)

// Detekterer starten på hver ny NY-økt
t = time(timeframe.period, sessTime, "America/New_York")
isNewSession = not na(t) and ta.change(t) != 0

if isNewSession
    line.new(bar_index, 0, bar_index, 0, extend = extend.both, color = lineColor, width = lineWidth)
````
