# Multi-Timeframe Order Blocks

- url: https://www.tradingview.com/script/3Ral3HFz-Multi-Timeframe-Order-Blocks/
- type: indicator
- pine_id: PUB;d3faff04f9164235a1a2f17774864f6c
- version: 1.0

## Description

Settings (gear icon on the indicator)
You'll find 5 checkboxes — Show Daily, Show 4H, Show 1H, Show 30m, Show 15m — all enabled by default. Uncheck any to declutter. The boxes extend rightward until price mitigates them.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Order Blocks", overlay=true, max_boxes_count=500, max_labels_count=500)

showDaily = input.bool(true, "Show Daily OBs")
show4H = input.bool(true, "Show 4H OBs")
show1H = input.bool(true, "Show 1H OBs")
show30m = input.bool(true, "Show 30m OBs")
show15m = input.bool(true, "Show 15m OBs")

bosAtrLength = input.int(14, "Displacement ATR Length", minval=1)
bosAtrMult = input.float(1.5, "Displacement ATR Multiplier", minval=0.1, step=0.1)
maxStoredPerTf = input.int(20, "Max OBs per Timeframe", minval=1, maxval=100)

type OrderBlock
    box boxObj
    label labelObj
    float top
    float bottom
    bool bull
    string tf
    bool active

var array<OrderBlock> orderBlocks = array.new<OrderBlock>()

getObColor(string tf, bool bull) =>
    switch tf
        "D" => bull ? color.new(color.green, 82) : color.new(color.red, 82)
        "4H" => bull ? color.new(color.green, 85) : color.new(color.red, 85)
        "1H" => bull ? color.new(color.green, 88) : color.new(color.red, 88)
        "30m" => bull ? color.new(color.green, 90) : color.new(color.red, 90)
        => bull ? color.new(color.green, 92) : color.new(color.red, 92)

isTfEnabled(string tf) =>
    switch tf
        "D" => showDaily
        "4H" => show4H
        "1H" => show1H
        "30m" => show30m
        => show15m

getTfOb(string tf) =>
    request.security(syminfo.tickerid, tf, [ta.crossover(close, high[1]) and close > open and close[1] < open[1], ta.crossunder(close, low[1]) and close < open and close[1] > open[1], high[1], low[1], high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)

addOrderBlock(string tf, bool bull, float top, float bottom) =>
    if isTfEnabled(tf) and not na(top) and not na(bottom)
        obColor = getObColor(tf, bull)
        obBox = box.new(bar_index, top, bar_index, bottom, border_color=color.new(obColor, 0), bgcolor=obColor, extend=extend.right)
        obLabel = label.new(bar_index, bull ? top : bottom, "OB " + tf, style=bull ? label.style_label_down : label.style_label_up, textcolor=color.white, color=color.new(obColor, 0), size=size.tiny)
        orderBlocks.push(OrderBlock.new(obBox, obLabel, top, bottom, bull, tf, true))
        while orderBlocks.size() > maxStoredPerTf * 5
            old = orderBlocks.shift()
            old.boxObj.delete()
            old.labelObj.delete()

updateMitigation() =>
    for [index, ob] in orderBlocks
        if ob.active and close <= ob.top and close >= ob.bottom
            ob.boxObj.delete()
            ob.labelObj.delete()
            orderBlocks.set(index, OrderBlock.new(ob.boxObj, ob.labelObj, ob.top, ob.bottom, ob.bull, ob.tf, false))

[bullD, bearD, bullDTop, bullDBottom, bearDTop, bearDBottom] = getTfOb("D")
[bull4H, bear4H, bull4HTop, bull4HBottom, bear4HTop, bear4HBottom] = getTfOb("240")
[bull1H, bear1H, bull1HTop, bull1HBottom, bear1HTop, bear1HBottom] = getTfOb("60")
[bull30m, bear30m, bull30mTop, bull30mBottom, bear30mTop, bear30mBottom] = getTfOb("30")
[bull15m, bear15m, bull15mTop, bull15mBottom, bear15mTop, bear15mBottom] = getTfOb("15")

if bullD
    addOrderBlock("D", true, bullDTop, bullDBottom)
if bearD
    addOrderBlock("D", false, bearDTop, bearDBottom)
if bull4H
    addOrderBlock("4H", true, bull4HTop, bull4HBottom)
if bear4H
    addOrderBlock("4H", false, bear4HTop, bear4HBottom)
if bull1H
    addOrderBlock("1H", true, bull1HTop, bull1HBottom)
if bear1H
    addOrderBlock("1H", false, bear1HTop, bear1HBottom)
if bull30m
    addOrderBlock("30m", true, bull30mTop, bull30mBottom)
if bear30m
    addOrderBlock("30m", false, bear30mTop, bear30mBottom)
if bull15m
    addOrderBlock("15m", true, bull15mTop, bull15mBottom)
if bear15m
    addOrderBlock("15m", false, bear15mTop, bear15mBottom)

updateMitigation()
````
