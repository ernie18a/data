# Multi-Timeframe RSI Box Adjustable

- url: https://www.tradingview.com/script/bVbQ6Nl9-Multi-Timeframe-RSI-Box-Adjustable/
- type: indicator
- pine_id: PUB;ed7c3774ece640d792ab05535a9f9f93
- version: 1.0

## Description

Multi RSI boxes. Gives 5 minute, 15 minute 30 minute 1hr  daily weekly and monthly RSI in neat little boxes on your screen.

## Source Code

````pine
//@version=5
indicator("Multi-Timeframe RSI Box Adjustable", overlay=true)

rsiLength = input.int(14, "RSI Length")

layout = input.string("Vertical", "Layout", options=["Vertical", "Horizontal"])
tablePos = input.string("Top Right", "Box Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"])
compactMode = input.bool(true, "Compact Box")

textSize =
     textSizeInput == "Tiny"   ? size.tiny :
     textSizeInput == "Small"  ? size.small :
     textSizeInput == "Normal" ? size.normal :
     size.large

pos =
     tablePos == "Top Right"    ? position.top_right :
     tablePos == "Top Left"     ? position.top_left :
     tablePos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

rsi5m  = request.security(syminfo.tickerid, "5",  ta.rsi(close, rsiLength))
rsi15m = request.security(syminfo.tickerid, "15", ta.rsi(close, rsiLength))
rsi30m = request.security(syminfo.tickerid, "30", ta.rsi(close, rsiLength))
rsi1h  = request.security(syminfo.tickerid, "60", ta.rsi(close, rsiLength))
rsiD   = request.security(syminfo.tickerid, "D",  ta.rsi(close, rsiLength))
rsiW   = request.security(syminfo.tickerid, "W",  ta.rsi(close, rsiLength))
rsiM   = request.security(syminfo.tickerid, "M",  ta.rsi(close, rsiLength))

getColor(rsi) =>
    rsi >= 70 ? color.red :
     rsi <= 30 ? color.green :
     rsi >= 50 ? color.new(color.green, 40) :
     color.new(color.red, 40)

bgLabel = color.new(color.black, compactMode ? 15 : 0)
txt = color.white

var table rsiTable = table.new(position.top_right, 7, 8, border_width=1)

if barstate.islast
    table.clear(rsiTable, 0, 0, 6, 7)

    if layout == "Vertical"
        table.cell(rsiTable, 0, 0, "TF", bgcolor=color.black, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 0, "RSI", bgcolor=color.black, text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 1, "5m", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 1, str.tostring(rsi5m, "#.#"), bgcolor=getColor(rsi5m), text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 2, "15m", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 2, str.tostring(rsi15m, "#.#"), bgcolor=getColor(rsi15m), text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 3, "30m", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 3, str.tostring(rsi30m, "#.#"), bgcolor=getColor(rsi30m), text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 4, "1h", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 4, str.tostring(rsi1h, "#.#"), bgcolor=getColor(rsi1h), text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 5, "D", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 5, str.tostring(rsiD, "#.#"), bgcolor=getColor(rsiD), text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 6, "W", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 6, str.tostring(rsiW, "#.#"), bgcolor=getColor(rsiW), text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 7, "M", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 7, str.tostring(rsiM, "#.#"), bgcolor=getColor(rsiM), text_color=txt, text_size=textSize)

    else
        table.cell(rsiTable, 0, 0, "5m", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 0, "15m", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 2, 0, "30m", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 3, 0, "1h", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 4, 0, "D", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 5, 0, "W", bgcolor=bgLabel, text_color=txt, text_size=textSize)
        table.cell(rsiTable, 6, 0, "M", bgcolor=bgLabel, text_color=txt, text_size=textSize)

        table.cell(rsiTable, 0, 1, str.tostring(rsi5m, "#.#"), bgcolor=getColor(rsi5m), text_color=txt, text_size=textSize)
        table.cell(rsiTable, 1, 1, str.tostring(rsi15m, "#.#"), bgcolor=getColor(rsi15m), text_color=txt, text_size=textSize)
        table.cell(rsiTable, 2, 1, str.tostring(rsi30m, "#.#"), bgcolor=getColor(rsi30m), text_color=txt, text_size=textSize)
        table.cell(rsiTable, 3, 1, str.tostring(rsi1h, "#.#"), bgcolor=getColor(rsi1h), text_color=txt, text_size=textSize)
        table.cell(rsiTable, 4, 1, str.tostring(rsiD, "#.#"), bgcolor=getColor(rsiD), text_color=txt, text_size=textSize)
        table.cell(rsiTable, 5, 1, str.tostring(rsiW, "#.#"), bgcolor=getColor(rsiW), text_color=txt, text_size=textSize)
        table.cell(rsiTable, 6, 1, str.tostring(rsiM, "#.#"), bgcolor=getColor(rsiM), text_color=txt, text_size=textSize)
````
