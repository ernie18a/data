<!-- tradingview-pine-id: PUB;135d8955d3e64e86b99fef3cac9b699e -->
<!-- tradingviewscripts-format: 1 -->
# Gann Box (Zeiierman)

Source: https://www.tradingview.com/script/aaPsyqft-Gann-Box-Zeiierman/

## Description

█ Overview
The Gann Box (Zeiierman) is an indicator that provides visual insights using the principles of W.D. Gann's trading methods. Gann's techniques are based on geometry, astronomy, and astrology, and are used to predict important price levels and market trends. This indicator helps traders identify potential support and resistance levels, and forecast future price movements.

Gann used angles and various geometric constructions to divide time and price into proportionate parts. Gann indicators are often used to predict areas of support and resistance, key tops and bottoms, and future price moves.

[image]https://www.tradingview.com/x/vvCYTSYE/[/image]

█  How It Works
The indicator operates by identifying high and low points within a visible range on the chart and drawing a Gann Box between these points. The box is divided into segments based on selected percentages, which represent key levels for observing market reactions. It includes options to display labels, a Gann fan, and Gann angles for analysis. Advanced features allow extending the box into the future for predictive analysis and reversing its orientation for alternative viewpoints.

[*]High and Low Points Identification: It starts by locating the highest and lowest price points visible on the chart.
[*]Gann Box Construction: Draws a box from these points and divides it according to specified percentages, highlighting potential support and resistance levels.

█  How to Use
Support and Resistance Levels
Using a Gann angle to forecast support and resistance is probably the most popular way they are used. This technique frames the market, allowing the analyst to read the movement of the market inside this framework.

The lines within the Gann Box, drawn at the key percentages, create a grid of potential support and resistance levels. As prices fluctuate, these lines can act as barriers to price movement, with the price often pausing or reversing at these intervals. 

[image]https://www.tradingview.com/x/FpxUg7Oj/[/image]

Forecasting with the 'Extend' Feature: The indicator's ability to extend lines and boxes into the future provides traders with a forward-looking tool to anticipate potential market movements and prepare for them.

[image]https://www.tradingview.com/x/zRjetHwR/[/image]

Gann Fan: This feature draws lines at a significant price angle, helping traders identify potential support and resistance levels based on the theory that prices move in predictable patterns.

[image]https://www.tradingview.com/x/qZNwwuad/[/image]

Gann Curves: Gann Curves display dynamic support and resistance levels, aiding in the analysis of momentum and trend strength.

[image]https://www.tradingview.com/x/eRe2EtPK/[/image]

█  Settings
The indicator includes several settings that allow customization of its appearance and functionality:

⚪ General Settings

[*]Reverse: This setting changes the orientation of labels and calculations within the Gann Box, providing alternative analytical perspectives. It essentially flips the Gann Box's direction, which can be useful in different market conditions or analysis scenarios.
[*]Extend: Extends the drawing of Gann lines or boxes into the future beyond the current last bar. This feature is essential for forecasting future price movements and identifying potential support or resistance levels that lie outside the current price action.

⚪ Gann Box

[*]Show Box: Toggles the visibility of the Gann Box on the chart. The Gann Box is a fundamental tool in Gann analysis, highlighting key levels based on selected high and low points to identify potential support and resistance areas.
[*]Show Fibonacci Labels: Controls the display of Fibonacci labels within the Gann Box. These labels mark specific Fibonacci retracement levels, aiding traders in recognizing significant levels for potential reversals.
[*]Box Visibility: Allows users to enable or disable individual boxes within the Gann Box, providing flexibility in focusing on specific levels of interest.
[*]Percentage Levels: Defines the Fibonacci levels within the Gann Box. Traders can adjust these levels to customize the Gann Box according to their specific analysis needs.
[*]Coloring: Customizes the color of each level within the Gann Box, enhancing visual clarity and differentiation between levels.

⚪ Gann Fan

[*]Show Fan: Enables the Gann Fan, which draws lines at significant Gann angles from a particular point on the chart, helping identify potential support and resistance levels.
[*]Fan Percentages and Coloring: Similar to the Gann Box, these settings allow traders to customize which Gann angles are displayed and how they are colored.

⚪ Gann Curves
Show Curves: When enabled, this setting draws Gann Curves on the chart. These curves are based on Gann percentages and provide a dynamic view of support and resistance levels as they adapt to changing market conditions.
Curve Percentages and Coloring: Define which curves are displayed and their colors, allowing for a tailored analysis experience.

⚪ Gann Angles

[*]Show Angles: Toggles the display of Gann Angles, which are crucial for understanding the market's price and time dynamics, offering insights into future support and resistance levels.
[*]Coloring: Customizes the color of the Gann Angles, making it easier to differentiate between various angles on the chart.

█  Alerts
The indicator includes several alert conditions for price breakouts from the Gann Box and specific levels, enabling traders to be notified of significant market movements.

-----------------
Disclaimer

The information contained in my Scripts/Indicators/Ideas/Algos/Systems does not constitute financial advice or a solicitation to buy or sell any securities of any type. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

My Scripts/Indicators/Ideas/Algos/Systems are only for educational purposes!

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/

// ~~ © Zeiierman {
//@version=5
indicator("Gann Box (Zeiierman)",overlay=true,max_boxes_count=50,max_labels_count=50,max_lines_count=144,max_bars_back=1000)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Settings {
// ~~ Tooltips
var t1 = "Reverses the orientation of labels and calculations in the Gann Box, offering alternative analytical perspectives."
var t2 = "Extend the drawing of Gann lines or boxes into the future beyond the current last bar to anticipate potential support or resistance levels. This setting is crucial for traders looking to forecast future price movements and prepare for potential market reactions at these extended levels."
var t3 = "Enables or disables the display of the Gann Box. When enabled, the Gann Box will be visible on the chart, illustrating key levels based on selected high and low points. The Gann Box is a fundamental tool in Gann analysis, providing insights into potential support and resistance levels, and enabling traders to identify strategic entry and exit points."
var t4 = "Enables or disables the display of Fibonacci labels within the Gann Box and Gann Fan. Useful for identifying specific Fibonacci retracement levels for support or resistance, these labels help traders to quickly recognize significant percentage levels that are often considered in trading strategies for their potential to indicate reversal points."
var t5 = "Enables or disables the display of Gann Curves. When enabled, it draws curves based on Gann percentages to predict potential market movements. These curves offer a dynamic view of potential support and resistance levels as they adjust to changing market conditions, aiding in the analysis of momentum and trend strength."
var t6 = "Enables or disables the display of Gann Angles. These are diagonal lines that extend from significant price points to provide insights into future support and resistance levels. Gann Angles are a cornerstone of Gann theory, offering a unique perspective on price and time dynamics that can signal significant market movements."
//~~}

//General{
reverse   = input.bool(false,title="Reverse",group="General Settings",tooltip=t1)
Future    = input.bool(true, title="Extend",group="General Settings",tooltip=t2)
//~~}

//Box{
showBox   = input.bool(true,title="Show Box",group="Gann Box",tooltip=t3)
showLabel = input.bool(true, title="Show Fibonacci Labels", group="Gann Box",tooltip=t4)

//Visuals
boxbool = array.from(input.bool(true,"",inline="1", group="Gann Box"),
 input.bool(true,"",inline="2", group="Gann Box"),
 input.bool(true,"",inline="3", group="Gann Box"),
 input.bool(true,"",inline="4", group="Gann Box"),
 input.bool(true,"",inline="5", group="Gann Box"),
 input.bool(true,"",inline="6", group="Gann Box"))

//Levels
perc = array.from(input.float(25.0,title="",step=.1,inline="1", group="Gann Box")/100,
 input.float(38.2,title="",step=.1,inline="2", group="Gann Box")/100,
 input.float(50.0,title="",step=.1,inline="3", group="Gann Box")/100,
 input.float(61.8,title="",step=.1,inline="4", group="Gann Box")/100,
 input.float(75.0,title="",step=.1,inline="5", group="Gann Box")/100)

//Coloring
c = array.from(input.color(#F44336,title="",inline="1", group="Gann Box"),
 input.color(#81C784,title="",inline="2", group="Gann Box"),
 input.color(#0097a7,title="",inline="3", group="Gann Box"),
 input.color(#9598a1,title="",inline="4", group="Gann Box"),
 input.color(#a5d6a7,title="",inline="5", group="Gann Box"),
 input.color(#F44336,title="",inline="6", group="Gann Box"))
//~~}

//Fan{
showFan= input.bool(false,title="Show Fan",group="Gann Fan",tooltip=t4)

//Visual
fperc = array.from(input.bool(true,"25%",inline="f1",group="Gann Fan"),
 input.bool(true,"38.2%",inline="f2",group="Gann Fan"),
 input.bool(true,"50%",inline="f3",group="Gann Fan"),
 input.bool(true,"61.8%",inline="f4",group="Gann Fan"),
 input.bool(true,"75%",inline="f5",group="Gann Fan"),
 input.bool(true,"100%",inline="f6",group="Gann Fan"))

//Coloring
fcol = array.from(input.color(#ff9800,"",inline="f1",group="Gann Fan"),
 input.color(#089981,"",inline="f2",group="Gann Fan"),
 input.color(#4caf50,"",inline="f3",group="Gann Fan"),
 input.color(#089981,"",inline="f4",group="Gann Fan"),
 input.color(#00bcd4,"",inline="f5",group="Gann Fan"),
 input.color(#2962ff,"",inline="f6",group="Gann Fan"))
//~~}

//Curve{
showCurve = input.bool(false, title="Show Curves",group="Gann Curves",tooltip=t5)

cperc = array.from(input.bool(true,"25%",inline="c1",group="Gann Curves"),
 input.bool(true,"38.2%",inline="c2",group="Gann Curves"),
 input.bool(true,"50%",inline="c3",group="Gann Curves"),
 input.bool(true,"61.8%",inline="c4",group="Gann Curves"),
 input.bool(true,"75%",inline="c5",group="Gann Curves"),
 input.bool(true,"100%",inline="c6",group="Gann Curves"))

//Coloring
ccol = array.from(input.color(#ff9800,"",inline="c1",group="Gann Curves"),
 input.color(#81c784,"",inline="c2",group="Gann Curves"),
 input.color(#4caf50,"",inline="c3",group="Gann Curves"),
 input.color(#089981,"",inline="c4",group="Gann Curves"),
 input.color(#00bcd4,"",inline="c5",group="Gann Curves"),
 input.color(#2962ff,"",inline="c6",group="Gann Curves"))
//~~}

//Angles{
showAngles= input.bool(false,title="Show Angles",group="Gann Angles",inline="a1",tooltip=t6)

//Coloring
acol = input.color(color.gray,"",group="Gann Angles",inline="a1")
//~~}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Variables {
b = bar_index
var float Hi = na
var float Lo = na
var int hLoc = na
var int lLoc = na 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Storage {
var box   [] Box    = array.new<box>(0)
var label [] Lab    = array.new<label>(0)
var line  [] Lin    = array.new<line>(12,line(na))
var polyline [] arr = array.new<polyline>(7)
var Ang = matrix.new<line>(4,13,line(na))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Visible Chart Function {
barIsVisible() => time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Main {
//Visible High & Low{
if barIsVisible() and high >= nz(Hi, high)
    Hi := high
    hLoc := bar_index
if barIsVisible() and low <= nz(Lo, low)
    Lo := low
    lLoc := bar_index

x0 = lLoc<hLoc?lLoc:hLoc
x6 = lLoc<hLoc?(Future?math.min(bar_index+500,hLoc+(hLoc-lLoc)):hLoc):(Future?math.min(bar_index+500,lLoc+(lLoc-hLoc)):lLoc)
y0 = lLoc<hLoc?Lo:Hi
y6 = lLoc<hLoc?Hi:Lo
//~~}

//Fibonacci Levels{
x = array.new<int>(1,x0)
y = array.new<float>(1,y0)

for i=0 to 4
    x.push(math.round(x0+(x6-x0)*array.get(perc,i)))
    y.push(y0+(y6-y0)*array.get(perc,i))
    if i==4
        x.push(x6)
        y.push(y6)
//~~}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Gann Box {
//Boxes{
if showBox and barIsVisible()
    for boxes in Box
        boxes.delete()
    Box.clear()
    for i=0 to 5
        left = x.get(i)
        right= x.get(i+1)
        for z=0 to 5
            if boxbool.get(z)
                bot = y.get(z)
                top = y.get(z+1)
                bx = box.new(left,top,right,bot,border_color=color.new(c.get(z),50),bgcolor=color.new(c.get(z),80))
                Box.unshift(bx)
//~~}        

//Labels{
if showLabel and barIsVisible()
    s = array.new<string>(1,"0")
    for i=0 to perc.size()-1
        s.push(str.tostring(perc.get(i)))
    s.push("1")
    if reverse
        s.reverse()
    for i=0 to 6
        xx = x.get(i)
        for z=0 to 6
            yy = y.get(z)
            if i==0 or i==6
                yLab = label.new(xx,yy,text=s.get(z),
                 textcolor=chart.fg_color,color=color.new(color.white,100),
                 style=i==0?label.style_label_right:label.style_label_left)
                Lab.unshift(yLab)
            if z==0 or z==6
                xLab = label.new(xx,yy,text=s.get(i),
                 textcolor=chart.fg_color,color=color.new(color.white,100),
                 style=lLoc<hLoc?(z==0?label.style_label_up:label.style_label_down):
                 (z==0?label.style_label_down:label.style_label_up))
                Lab.unshift(xLab)
            if Lab.size()>28
                prev1 = Lab.pop()
                prev2 = Lab.pop()
                prev1.delete()
                prev2.delete()
//~~}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Gann Square {
if showFan and barIsVisible()
    for i=0 to 5
        if fperc.get(i)
            l1 = line.new(x0,y0,x.get(i+1),y6,color=fcol.get(i))
            l2 = line.new(x0,y0,x6,y.get(i+1),color=fcol.get(i))
            Lin.pop().delete()
            Lin.pop().delete()
            Lin.unshift(l1)
            Lin.unshift(l2)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Gann Curve {
if showCurve and barIsVisible()
    for i=1 to arr.size()-1
        if cperc.get(i-1)
            points = array.new<chart.point>()
            for j = 0 to 90 by 1
                xx = x0 - (x0-x.get(i))*math.sin(math.toradians(j))
                yy = y0 + math.cos(math.toradians(j))*(y.get(i)-y0)
                points.push(chart.point.from_index(math.round(xx),yy))
            poly = polyline.new(points,false,false,line_color=ccol.get(i-1))
            arr.unshift(poly)
            arr.pop().delete()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Gann Angles {
if showAngles and barIsVisible()
    for i=0 to 6
        xx = x.get(i)
        yy = y.get(i)
        if i>0
            Ang.get(0,i).delete()
            Ang.get(1,i).delete()
            Ang.get(0,12-i).delete()
            Ang.get(1,12-i).delete()
            a1 = line.new(x0,y0,xx,y6,color=acol)
            a2 = line.new(x0,y0,x6,yy,color=acol)
            a3 = line.new(x0,y6,xx,y0,color=acol)
            a4 = line.new(x0,y6,x6,yy,color=acol)
            Ang.set(0,i,a1)
            Ang.set(0,12-i,a2)
            Ang.set(1,i,a3)
            Ang.set(1,12-i,a4)
        if i<6
            Ang.get(2,i).delete()
            Ang.get(3,i).delete()
            Ang.get(2,12-i).delete()
            Ang.get(3,12-i).delete()
            a1 = line.new(x6,y6,xx,y0,color=acol)
            a2 = line.new(x6,y6,x0,yy,color=acol)
            a3 = line.new(x6,y0,xx,y6,color=acol)
            a4 = line.new(x6,y0,x0,yy,color=acol)
            Ang.set(2,i,a1)
            Ang.set(2,12-i,a2)
            Ang.set(3,i,a3)
            Ang.set(3,12-i,a4)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alert1 = ta.crossunder(low,x0) or ta.crossover(high,x0)
alert2 = ta.crossunder(low,x.get(1)) or ta.crossover(high,x.get(1))
alert3 = ta.crossunder(low,x.get(2)) or ta.crossover(high,x.get(2))
alert4 = ta.crossunder(low,x.get(3)) or ta.crossover(high,x.get(3))
alert5 = ta.crossunder(low,x.get(4)) or ta.crossover(high,x.get(4))
alert6 = ta.crossunder(low,x.get(5)) or ta.crossover(high,x.get(5))

alertcondition(alert1,"Gann Box Breakout","Price breaks out from Gann Box")
alertcondition(alert2,"Gann Box Breakout Level 1","Price breaks Level 1")
alertcondition(alert3,"Gann Box Breakout Level 2","Price breaks Level 2")
alertcondition(alert4,"Gann Box Breakout Level 3","Price breaks Level 3")
alertcondition(alert5,"Gann Box Breakout Level 4","Price breaks Level 4")
alertcondition(alert6,"Gann Box Breakout Level 5","Price breaks Level 5")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
