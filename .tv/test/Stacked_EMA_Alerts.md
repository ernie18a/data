<!-- tradingview-pine-id: PUB;a68bcc89b5c3428f84f2889818e63e7b -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stacked EMA Alerts

Source: https://www.tradingview.com/script/8azhgEYV-Stacked-EMA-Alerts/

## Description

Visual stacking highlight: When all four EMAs are perfectly stacked bullish (10 > 20 > 50 > 200) the background tints green; when stacked bearish it tints red — so you can see the "full stack" regime at a glance.

6 built-in alerts (available in the indicator's alert dropdown — click the bell on the indicator legend):

🔔 Golden Cross — EMA 50 crosses above EMA 200
🔔 Death Cross — EMA 50 crosses below EMA 200
🔔 Full Bullish Stack — all four EMAs aligned bullish
🔔 Full Bearish Stack — all four EMAs aligned bearish
🔔 Close Cross Above EMA 200 — price reclaims the 200
🔔 Close Cross Below EMA 200 — price loses the 200
Customizable: all four lengths, colors, and the background highlight toggle are configurable right in the indicator settings, organized into Lengths / Colors / Alerts groups.

---

## Source Code

````pine
//@version=6
indicator("Stacked EMA Alerts", overlay=true)

//#region Inputs
lengthsGroup = "Lengths"
colorsGroup = "Colors"
alertsGroup = "Alerts"

ema10Length = input.int(10, "EMA 10 Length", minval=1, group=lengthsGroup)
ema20Length = input.int(20, "EMA 20 Length", minval=1, group=lengthsGroup)
ema50Length = input.int(50, "EMA 50 Length", minval=1, group=lengthsGroup)
ema200Length = input.int(200, "EMA 200 Length", minval=1, group=lengthsGroup)

ema10Color = input.color(color.purple, "EMA 10 Color", group=colorsGroup)
ema20Color = input.color(color.blue, "EMA 20 Color", group=colorsGroup)
ema50Color = input.color(color.red, "EMA 50 Color", group=colorsGroup)
ema200Color = input.color(color.black, "EMA 200 Color", group=colorsGroup)

showStackBackground = input.bool(true, "Highlight EMA Stack", group=alertsGroup)
bullBgColor = input.color(color.new(color.green, 85), "Bullish Stack Background", group=alertsGroup)
bearBgColor = input.color(color.new(color.red, 85), "Bearish Stack Background", group=alertsGroup)
//#endregion

//#region Calculations
ema10 = ta.ema(close, ema10Length)
ema20 = ta.ema(close, ema20Length)
ema50 = ta.ema(close, ema50Length)
ema200 = ta.ema(close, ema200Length)

goldenCross = ta.crossover(ema10, ema50)
deathCross = ta.crossunder(ema10, ema50)
closeCrossAbove200 = ta.crossover(close, ema200)
closeCrossBelow200 = ta.crossunder(close, ema200)

bullStack = (ema10 > ema20 and ema20 > ema50 and ema50 > ema200)
bearStack = (ema10 < ema20 and ema20 < ema50 and ema50 < ema200)
//#endregion

//#region Plots
plot(ema10, title="EMA 10", color=ema10Color, linewidth=1)
plot(ema20, title="EMA 20", color=ema20Color, linewidth=1)
plot(ema50, title="EMA 50", color=ema50Color, linewidth=1)
plot(ema200, title="EMA 200", color=ema200Color, linewidth=1)

bgcolor(showStackBackground and bullStack ? bullBgColor : na, title="Bullish Stack Background")
bgcolor(showStackBackground and bearStack ? bearBgColor : na, title="Bearish Stack Background")
//#endregion

//#region Alerts
alertcondition(goldenCross, title="Golden Cross", message="EMA 50 crossed above EMA 200")
alertcondition(deathCross, title="Death Cross", message="EMA 50 crossed below EMA 200")
alertcondition(bullStack, title="Full Bullish Stack", message="EMA 10 > EMA 20 > EMA 50 > EMA 200")
alertcondition(bearStack, title="Full Bearish Stack", message="EMA 10 < EMA 20 < EMA 50 < EMA 200")
alertcondition(closeCrossAbove200, title="Close Cross Above EMA 200", message="Close crossed above EMA 200")
alertcondition(closeCrossBelow200, title="Close Cross Below EMA 200", message="Close crossed below EMA 200")
//#endregion
````
