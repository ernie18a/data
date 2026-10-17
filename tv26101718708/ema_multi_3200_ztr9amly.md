# EMA Multi 3-200

- url: https://www.tradingview.com/script/ZTR9AmlY-EMA-Multi-3-200/
- type: indicator
- pine_id: PUB;51a770f24a4545bfaffa64fda3581464
- version: 2.0

## Description

This indicator provide multi EMA from 3 to 200, include: EMA 3, 5, 30, 45, 60, 100, 200
Alerts:
1. Price crossover alerts
2. EMA crossover alerts

## Source Code

````pine
//@version=6
indicator("Multi EMAs [MIZU] - Grouped Visual System", overlay=true, precision=2)

// =====================
// Inputs
// =====================
showEma3   = input.bool(true, "Show EMA 3")
showEma5   = input.bool(true, "Show EMA 5")
showEma30  = input.bool(true, "Show EMA 30")
showEma45  = input.bool(true, "Show EMA 45")
showEma60  = input.bool(true, "Show EMA 60")
showEma100 = input.bool(true, "Show EMA 100")
showEma200 = input.bool(true, "Show EMA 200")

showLegend = input.bool(true, "Show EMA Legend")
showBands  = input.bool(true, "Show EMA Bands")

// =====================
// EMA Calculations
// =====================
ema3   = ta.ema(close, 3)
ema5   = ta.ema(close, 5)
ema30  = ta.ema(close, 30)
ema45  = ta.ema(close, 45)
ema60  = ta.ema(close, 60)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

// =====================
// Colors
// =====================
// Small EMA group: fast trigger
colorEma3 = color.yellow
colorEma5 = color.orange

// Mid EMA group: trend structure
colorEma30 = color.aqua
colorEma45 = color.blue
colorEma60 = color.purple

// Large EMA group: macro trend
colorEma100 = color.white
colorEma200 = color.red

// =====================
// Plots
// =====================
pEma3 = plot(showEma3 ? ema3 : na, color=colorEma3, linewidth=2, title="EMA 3 - Fast Trigger")
pEma5 = plot(showEma5 ? ema5 : na, color=colorEma5, linewidth=2, title="EMA 5 - Short Trigger")

pEma30 = plot(showEma30 ? ema30 : na, color=colorEma30, linewidth=1, title="EMA 30 - Structure Start")
pEma45 = plot(showEma45 ? ema45 : na, color=colorEma45, linewidth=1, title="EMA 45 - Structure Midline")
pEma60 = plot(showEma60 ? ema60 : na, color=colorEma60, linewidth=1, title="EMA 60 - Structure End")

pEma100 = plot(showEma100 ? ema100 : na, color=colorEma100, linewidth=2, title="EMA 100 - Major Trend")
pEma200 = plot(showEma200 ? ema200 : na, color=colorEma200, linewidth=3, title="EMA 200 - Macro Boundary")

// =====================
// EMA Bands
// =====================
fill(
    pEma30,
    pEma60,
    color = showBands and showEma30 and showEma60 ? color.new(color.aqua, 88) : na,
    title = "EMA 30-60 Structure Band"
)

fill(
    pEma100,
    pEma200,
    color = showBands and showEma100 and showEma200 ? color.new(color.red, 90) : na,
    title = "EMA 100-200 Macro Trend Band"
)

// =====================
// Legend Table
// =====================
var table emaLegend = table.new(position.top_right, 3, 8, border_width=1)

if barstate.islast
    if showLegend
        table.cell(emaLegend, 0, 0, "EMA", text_color=color.white, bgcolor=color.new(color.gray, 30))
        table.cell(emaLegend, 1, 0, "Role", text_color=color.white, bgcolor=color.new(color.gray, 30))
        table.cell(emaLegend, 2, 0, "Level", text_color=color.white, bgcolor=color.new(color.gray, 30))

        table.cell(emaLegend, 0, 1, "3", text_color=color.black, bgcolor=colorEma3)
        table.cell(emaLegend, 1, 1, "Fast Trigger", text_color=color.white)
        table.cell(emaLegend, 2, 1, "Small", text_color=color.white)

        table.cell(emaLegend, 0, 2, "5", text_color=color.black, bgcolor=colorEma5)
        table.cell(emaLegend, 1, 2, "Short Trigger", text_color=color.white)
        table.cell(emaLegend, 2, 2, "Small", text_color=color.white)

        table.cell(emaLegend, 0, 3, "30", text_color=color.black, bgcolor=colorEma30)
        table.cell(emaLegend, 1, 3, "Structure Start", text_color=color.white)
        table.cell(emaLegend, 2, 3, "Mid", text_color=color.white)

        table.cell(emaLegend, 0, 4, "45", text_color=color.white, bgcolor=colorEma45)
        table.cell(emaLegend, 1, 4, "Structure Mid", text_color=color.white)
        table.cell(emaLegend, 2, 4, "Mid", text_color=color.white)

        table.cell(emaLegend, 0, 5, "60", text_color=color.white, bgcolor=colorEma60)
        table.cell(emaLegend, 1, 5, "Structure End", text_color=color.white)
        table.cell(emaLegend, 2, 5, "Mid-Large", text_color=color.white)

        table.cell(emaLegend, 0, 6, "100", text_color=color.black, bgcolor=colorEma100)
        table.cell(emaLegend, 1, 6, "Major Trend", text_color=color.white)
        table.cell(emaLegend, 2, 6, "Large", text_color=color.white)

        table.cell(emaLegend, 0, 7, "200", text_color=color.white, bgcolor=colorEma200)
        table.cell(emaLegend, 1, 7, "Macro Boundary", text_color=color.white)
        table.cell(emaLegend, 2, 7, "Largest", text_color=color.white)
    else
        table.clear(emaLegend, 0, 0, 2, 7)

// =====================
// Price Crossover Alerts
// =====================
alertcondition(ta.crossover(close, ema30), title="Price Crosses Above EMA 30", message="{{ticker}} Price crossed above EMA 30. Current price: {{close}}")
alertcondition(ta.crossunder(close, ema30), title="Price Crosses Below EMA 30", message="{{ticker}} Price crossed below EMA 30. Current price: {{close}}")

alertcondition(ta.crossover(close, ema60), title="Price Crosses Above EMA 60", message="{{ticker}} Price crossed above EMA 60. Current price: {{close}}")
alertcondition(ta.crossunder(close, ema60), title="Price Crosses Below EMA 60", message="{{ticker}} Price crossed below EMA 60. Current price: {{close}}")

alertcondition(ta.crossover(close, ema100), title="Price Crosses Above EMA 100", message="{{ticker}} Price crossed above EMA 100. Current price: {{close}}")
alertcondition(ta.crossunder(close, ema100), title="Price Crosses Below EMA 100", message="{{ticker}} Price crossed below EMA 100. Current price: {{close}}")

alertcondition(ta.crossover(close, ema200), title="Price Crosses Above EMA 200", message="{{ticker}} Price crossed above EMA 200. Current price: {{close}}")
alertcondition(ta.crossunder(close, ema200), title="Price Crosses Below EMA 200", message="{{ticker}} Price crossed below EMA 200. Current price: {{close}}")

// =====================
// EMA Crossover Alerts
// =====================
alertcondition(ta.crossover(ema3, ema5), title="EMA 3 Crosses Above EMA 5", message="{{ticker}} EMA 3 crossed above EMA 5. Current price: {{close}}")
alertcondition(ta.crossunder(ema3, ema5), title="EMA 3 Crosses Below EMA 5", message="{{ticker}} EMA 3 crossed below EMA 5. Current price: {{close}}")

alertcondition(ta.crossover(ema5, ema30), title="EMA 5 Crosses Above EMA 30", message="{{ticker}} EMA 5 crossed above EMA 30. Current price: {{close}}")
alertcondition(ta.crossunder(ema5, ema30), title="EMA 5 Crosses Below EMA 30", message="{{ticker}} EMA 5 crossed below EMA 30. Current price: {{close}}")

alertcondition(ta.crossover(ema30, ema60), title="EMA 30 Crosses Above EMA 60", message="{{ticker}} EMA 30 crossed above EMA 60. Current price: {{close}}")
alertcondition(ta.crossunder(ema30, ema60), title="EMA 30 Crosses Below EMA 60", message="{{ticker}} EMA 30 crossed below EMA 60. Current price: {{close}}")

alertcondition(ta.crossover(ema60, ema100), title="EMA 60 Crosses Above EMA 100", message="{{ticker}} EMA 60 crossed above EMA 100. Current price: {{close}}")
alertcondition(ta.crossunder(ema60, ema100), title="EMA 60 Crosses Below EMA 100", message="{{ticker}} EMA 60 crossed below EMA 100. Current price: {{close}}")

alertcondition(ta.crossover(ema100, ema200), title="EMA 100 Crosses Above EMA 200", message="{{ticker}} EMA 100 crossed above EMA 200. Current price: {{close}}")
alertcondition(ta.crossunder(ema100, ema200), title="EMA 100 Crosses Below EMA 200", message="{{ticker}} EMA 100 crossed below EMA 200. Current price: {{close}}")
````
