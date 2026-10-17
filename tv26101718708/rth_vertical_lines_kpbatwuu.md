# RTH Vertical Lines

- url: https://www.tradingview.com/script/kPbaTWuu-RTH-Vertical-Lines/
- type: indicator
- pine_id: PUB;9cff20ef46f343789c9112353c028ff6
- version: 1.0

## Description

RTH Vertical Lines indicator automatically draws vertical lines at key New York session times:

• 9:30 AM – RTH Open
• 10:00 AM – Silver Bullet Time

Features:

* Auto vertical lines
* Custom line color/style
* Time labels
* Clean chart layout
* Designed for ICT & Smart Money traders

Perfect for tracking:

* RTH Open
* Silver Bullet setup
* Market manipulation timing
* Intraday liquidity moves

Built for Nasdaq, US30, and Forex traders.

## Source Code

````pine
//@version=5
indicator("RTH Vertical Lines", overlay=true)

// === Inputs ===
lineColor = input.color(color.blue, "Line Color")
lineStyle = input.string("Dotted", options=["Solid", "Dotted", "Dashed"])
lineWidth = input.int(1, "Line Width")

// === Style Convert ===
style =
     lineStyle == "Solid"  ? line.style_solid :
     lineStyle == "Dashed" ? line.style_dashed :
     line.style_dotted

// === Time Conditions ===
is930 = (hour == 9 and minute == 30)
is1000 = (hour == 10 and minute == 0)

// === Chart Range ===
topPrice = ta.highest(high, 500)
bottomPrice = ta.lowest(low, 500)

// === Draw 9:30 Line ===
if is930
    line.new(
         x1=bar_index,
         y1=topPrice,
         x2=bar_index,
         y2=bottomPrice,
         extend=extend.both,
         color=lineColor,
         style=style,
         width=lineWidth)

    label.new(
         x=bar_index,
         y=topPrice,
         text="9:30 AM",
         textcolor=color.blue,
         style=label.style_label_down,
         color=color.new(color.white, 100))

// === Draw 10:00 Line ===
if is1000
    line.new(
         x1=bar_index,
         y1=topPrice,
         x2=bar_index,
         y2=bottomPrice,
         extend=extend.both,
         color=lineColor,
         style=style,
         width=lineWidth)

    label.new(
         x=bar_index,
         y=topPrice,
         text="10 AM SB",
         textcolor=color.blue,
         style=label.style_label_down,
         color=color.new(color.white, 100))
````
