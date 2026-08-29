<!-- tradingview-pine-id: PUB;b01c3c1741aa449581a1573f6cb7c0b2 -->
<!-- tradingviewscripts-format: 1 -->
# Fibonacci Sequence Circles [BigBeluga]

Source: https://www.tradingview.com/script/x4xoO9ax-Fibonacci-Sequence-Circles-BigBeluga/

## Description

🔵 Overview  
The Fibonacci Sequence Circles [BigBeluga] is a unique and visually intuitive indicator designed for the TradingView platform. It combines the principles of the Fibonacci sequence with geometric circles to help traders identify potential support and resistance levels, as well as price expansion zones. The indicator dynamically anchors to key price points, such as pivot highs, pivot lows, or timeframe changes (daily, weekly, monthly), and generates Fibonacci-based circles around these anchor points.

⚠️For proper indicators visualization use simple not logarithmic chart

🔵 Key Features  

[*] Customizable Anchor Points: The indicator can be anchored to Pivot Highs, Pivot Lows, or timeframe changes (Daily, Weekly, Monthly), making it adaptable to various trading strategies.
[image]https://www.tradingview.com/x/PNpwegTx/[/image]

[*] Fibonacci Sequence Logic: The circles are generated using the Fibonacci sequence, where the diameter of each circle is the sum of the diameters of the two preceding circles.
[pine]
    first   = start_val
    secon   = start_val + int(start_val/2)
    three   = first + secon
    four    = secon + three
    five    = three + four
    six     = four + five
    seven   = five + six
    eight   = six + seven
    nine    = seven + eight
    ten     = eight + nine
[/pine]

[*] Adjustable Start Value: Traders can modify the starting value of the sequence to scale the circles larger or smaller, ensuring they fit the current price action.
[image]https://www.tradingview.com/x/1uhtSHDi/[/image]

[*] Color Customization: Each circle can be individually enabled or disabled, and its color can be customized for better visual clarity.
[image]https://www.tradingview.com/x/AeF9tyDD/[/image]

[*] Visual Labels: The diameter of each circle (in bars) is displayed next to the circle, providing additional context for analysis.
[image]https://www.tradingview.com/x/u43XL5Eb/[/image]

🔵 Usage  

[*] Step 1: Set the Anchor Point - Choose the anchor type (Pivot High, Pivot Low, Daily, Weekly, Monthly) to define the center of the Fibonacci circles.
[*] Step 2: Adjust the Start Value - Modify the starting value of the Fibonacci sequence to scale the circles according to the price action.
[*] Step 3: Customize Circle Colors - Enable or disable specific circles and adjust their colors for better visualization.
[*] Step 4: Analyze Price Action - Use the circles to identify potential support/resistance levels, price expansion zones, or trend continuation areas.
[*] Step 5: Combine with Other Tools - Enhance your analysis by combining the indicator with other technical tools like trendlines, moving averages, or volume indicators.

The Fibonacci Sequence Circles [BigBeluga] is a powerful and flexible tool for traders who rely on Fibonacci principles and geometric patterns. Its ability to anchor to key price points and dynamically scale based on market conditions makes it suitable for various trading styles and timeframes. Whether you're a day trader or a long-term investor, this indicator can help you visualize and anticipate price movements with greater precision.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Fibonacci Sequence Circles [BigBeluga]", overlay = true)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
start_val = input.int(2, "Start", minval = 1, maxval = 50)
anchor = input.string("Pivot High", "Anchor", ["Pivot High", "Pivot Low", "D", "W", "M"], inline = "a")
rightBars = input.int(40, "Pivot", inline = "a")

circle1 = input.bool(true, "1", inline = "1"), col1 = input.color(color.white, "", inline = "1")
circle2 = input.bool(true, "2", inline = "2"), col2 = input.color(color.blue, "", inline = "2")
circle3 = input.bool(true, "3", inline = "3"), col3 = input.color(color.aqua, "", inline = "3")
circle4 = input.bool(true, "4", inline = "4"), col4 = input.color(color.lime, "", inline = "4")
circle5 = input.bool(true, "5", inline = "5"), col5 = input.color(color.yellow, "", inline = "5")
circle6 = input.bool(true, "6", inline = "1"), col6 = input.color(color.orange, "", inline = "1")
circle7 = input.bool(true, "7", inline = "2"), col7 = input.color(color.red, "", inline = "2")
circle8 = input.bool(true, "8", inline = "3"), col8 = input.color(color.maroon, "", inline = "3")
circle9 = input.bool(false, "9", inline = "4"), col9 = input.color(color.purple, "", inline = "4")
circle10 = input.bool(false, "10", inline = "5"), col10 = input.color(color.fuchsia, "", inline = "5")


var index_h = 0
var index_l = 0
var line_   = line(na)
var H = float(na)
var L = float(na)
// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
bool ph_ = not na(ta.pivothigh(rightBars, rightBars))
bool pl_ = not na(ta.pivotlow(rightBars, rightBars))

// Define scaling factors
float xScale = 2.0
float yScale = 0.5 * ta.atr(500)
// Initialize arrays for storing points and levels
var points = array.new<chart.point>()


if ph_
    index_h := bar_index[rightBars]
    H := high[rightBars]

if pl_
    index_l := bar_index[rightBars]
    L := low[rightBars]


method draw_circle(bool cond, float source, index, int mult_x, int mult_y, color) =>
    if cond
        points.clear()
        float     angle  = 0
        for i = 1 to 21
            int xValue   = int(math.round(xScale * mult_x * math.cos(angle))) + index
            float yValue = yScale * mult_y * math.sin(angle) + source
            angle       += math.pi / 10

            points.push(chart.point.from_index(xValue, yValue))

        p = polyline.new(    
                         points, 
                         curved     = false,
                         line_color = color, 
                         line_width = 1, 
                         fill_color = color.new(color, 95)
                         )

        polyline.delete(p[1])

        label.delete(label.new(points.last(), str.tostring(mult_x), color = color(na), style = label.style_label_left, textcolor = color)[1])


display = switch anchor
    "Pivot High" => ph_ 
    "Pivot Low"  => pl_ 
    "D"          => timeframe.change("D")
    "W"          => timeframe.change("W")
    "M"          => timeframe.change("M")


index = switch anchor
    "Pivot High" => index_h
    "Pivot Low"  => index_l
    => bar_index


source = switch anchor
    "Pivot High" => H
    "Pivot Low"  => L
    => hlc3

// }



// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
if display
    label.new(index, source, "", style = label.style_cross, size = size.tiny, color = color.orange)
    
    first   = start_val
    secon   = start_val + int(start_val/2)
    three   = first + secon
    four    = secon + three
    five    = three + four
    six     = four + five
    seven   = five + six
    eight   = six + seven
    nine    = seven + eight
    ten     = eight + nine

    circle1.draw_circle(source, index, first, first, col1)
    circle2.draw_circle(source, index, secon, secon, col2)
    circle3.draw_circle(source, index, three, three, col3)
    circle4.draw_circle(source, index, four, four, col4)
    circle5.draw_circle(source, index, five, five, col5)
    circle6.draw_circle(source, index, six, six, col6)
    circle7.draw_circle(source, index, seven, seven, col7)
    circle8.draw_circle(source, index, eight, eight, col8)
    circle9.draw_circle(source, index, nine, nine, col9)
    circle10.draw_circle(source, index, ten, ten, col10)

    line.delete(line_)
    line_ := line.new(index, source, bar_index, hlc3, color = chart.fg_color, style = line.style_dashed)

line_.set_xy2(bar_index, hlc3)

// }
````
