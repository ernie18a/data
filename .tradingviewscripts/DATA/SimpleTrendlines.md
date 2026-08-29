<!-- tradingview-pine-id: PUB;efe2d5bcfec34de3a6bc888e255b937d -->
<!-- tradingviewscripts-format: 1 -->
# SimpleTrendlines

Source: https://www.tradingview.com/script/85fU3JnE-Simple-Trendlines/

## Description

📈 Trendlines, made easy.
Simple Trendlines is a carefully made library that provides an easy and accessible way to draw trendlines on the chart.

Containing only 10 properties and 2 methods, the implementation is designed to be understandable through an object-oriented structure and provides developers the opportunity to expand without having to deal with slope calculation while also ensuring that there's no leakage between the trendlines before they're drawn.

Developers only need to provide 5 expressions to get everything up in running. This includes the following but is not limited to

[*] The x-axis
[*] Point A (Y1 Value)
[*] Point B (Y2 Value)
[*] A condition to draw the line
[*] A condition to keep the trendline under continuation

Automatic x-axis calculation is not a built-in feature due to the inconsistency it could bring.

📕 Quick Example
[pine]
import HoanGhetti/SimpleTrendlines/1 as tl

input_len = input.int(defval = 10)
pivotLow = fixnan(ta.pivotlow(input_len, input_len))

xAxis = ta.valuewhen(ta.change(pivotLow), bar_index, 0) - ta.valuewhen(ta.change(pivotLow), bar_index, 1)
prevPivot = ta.valuewhen(ta.change(pivotLow), pivotLow, 1)
pivotCondition = ta.change(pivotLow) and pivotLow > prevPivot 

plData = tl.new(x_axis = xAxis, offset = input_len)
plData.drawLine(pivotCondition, prevPivot, pivotLow)
plData.drawTrendline(close > 0)

plData.lines.trendline.set_style(line.style_dashed)
plData.lines.trendline.set_width(2)
plData.lines.startline.set_width(2)
[/pine]

Excluding the styling at the bottom, that was only 8 lines of code which yields the following result.
[image]https://www.tradingview.com/x/I7Ds0cDs/[/image]

⏳ Before continuing

[*] The library does not support block-scoped execution. Conditions must be declared before and integrated as a parameter. This doesn't limit any capabilities and only involves thinking logically about precedence. It was made this way for code readability and to keep things organized.
[*] The offset value inside the TrendlineSettings object can potentially affect performance (although very minimal) if you're using strict mode. When using strict mode, it loops through historical values to then do backend calculations.

🔽 Getting Started 🔽
Creating trendlines without a library isn't a hard task. However, the library features a built-in system called strict mode. We'll dive further into this below.

Creating an Instance
You can create an instance of the library by calling the new() function. Passing an identifier is conventionally mandatory in this case so you can reference properties and methods.
[pine]
import HoanGhetti/SimpleTrendlines/2 as tl 
lineData = tl.new(int x_axis, int offset, bool strictMode, int strictType)
___
int x_axis (Required) The distance between point A and point B provided by the user.
int offset (Optional) The offset from x2 and the current bar_index. Used in situations where conditions execute ahead of where the x2 location is such as pivót events.
bool strictMode (Optional) Strict mode works in the backend of things to ensure that the price hasn't closed below the trendline before the trendline is drawn.
int strictType (Optional) Only accepts 0 and 1, 0 ensures that the price during slope calculation is above the line, and 1 ensures that the price during slope calculation is below the line.
[/pine]

The Initial Line
After instantiating the library, we can go ahead use the identifer we made above and create an instance of our initial line by calling the drawLine() method.
[pine]
lineData.drawLine(bool condition, float y1, float y2, float src)
___
bool condition (Required) The condition in order to draw a new line.
float y1 (Required) The y-value of point A.
float y2 (Required) The y-value of point B.
float src (Optional) Determines which value strict mode will actively check for leakage before a trendline is drawn.
Typically used if you're not referencing OHLC values for your y-values, or you want to check for another value to exceed the line besides using the close value.
[/pine]

The Trendline
The trendline that gets drawn solely uses the values of the initial line and can be called using the drawTrendline() method. The library enforces a condition as a parameter in order to maintain simplicity.
[pine]
lineData.drawTrendline(bool condition)
___
bool condition (Required) The condition in order to maintain and continue drawing the trendline.
[/pine]

⚙️Features

🔹Automatic Slope Calculation
In the background, the library calculates the next Y2 and X2 values on every tick for the trendline. Preventing the developer from having to do such a process themself.

🔹Object-Oriented
Each object contains manipulative properties that allow the developer to debug and have the freedom they want.

🔹Enforced Error Checking
Runtime errors have been put in place to ensure you're doing things correctly.

🔹Strict Mode & Offset
Strict mode can only be used when the offset value is over 0. It's a feature that's only meant to function under scenarios where a condition executes further than where the X2 is relative to the current bar_index value.

Let's think about pivot systems. As you're aware, pivot events are detected based on historical factors. If a swing low occurred nth bars ago, then the pivot condition will execute at the current bar_index instead of executing nth bars back.

Now because of this, what if you wanted to draw a trendline when the pivot event is executed? The offset value takes care of this just as you would when developing your other scripts, basically how we always do bar_index - n. However, what does this mean for strict mode?

The photo below represents the logic behind the execution.
[image]https://www.tradingview.com/x/qzHVwIiU/[/image]
When looking at this image, imagine this just happened, the event just executed and the trendline is now drawn. Pay attention to all the values inside the surrounding box. As you can see there are some candles that closed below the trendline before the trendline was drawn.

From what I can see 5-6 candles closed below the trendline during slope calculation. The goal of strict mode is to be a provisional system that prevents such occurrences from happening.
Here's a photo with strict mode on.
[image]https://www.tradingview.com/x/i93lFhzU/[/image]

🔹Strict Type
A parameter used in the new() function that acts as a representation of what strict mode should calculate for. It accepts only two values, 0 and 1.
[pine]
0 - Ensures that all candles have closed above the trendline before the trendline is drawn.
1 - Ensures that all candles have closed below the trendline before the trendline is drawn.
[/pine]
In the most recent photo above, I used 0 for strict type, since I was wanting to have a clean trendline and ensure that not a single candlestick closed below.
If you want to reference something else besides the close value during strict mode calculation, you can change it in the drawLine() method. 
If it's still difficult to understand, think 0 for pivot lows, and 1 for pivot highs.

📕 Methods and Property Inheritance
[image]https://www.tradingview.com/x/vGETUjPS/[/image]
The library isn't crazy, but hopefully, it helps.
That is all.👍

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HoanGhetti

//@version=5

// @description An accessible and semi-effortless way to draw trendlines with automatic slope and angle calculation.
library("SimpleTrendlines", overlay = true)

// @type The object containing the essential values for proper library execution.
// @field x_axis The x-axis provided by the user to determine the distance between point A and point B
// @field offset The offset from x2 and the current bar_index. Used in situations where conditions execute ahead of where the x2 location is, such as pivot events.
// @field strictMode Strict mode works in the backend to ensure that price hasn't closed below or above the trendline before the trendline is drawn.
// @field strictType 0 if price is above line, 1 if price is below line.
export type TrendlineSettings
    int x_axis
    int offset
    bool strictMode
    int strictType


// @type The object containing values that the user can use for further calculation.
// @field slope The slope of the initial line.
// @field x1 The bar_index value of point A.
// @field x2 The bar_index value of point B.
// @field changeInX How many bars since the bar_index value of point B.
export type TrendlineData
    float slope
    int x1
    int x2
    float y1
    float y2
    int changeInX


// @type The object containing both the start line and trend line for manipulation.
// @field startline The initial line that gets drawn when instantiating the drawLine() method. 
// @field trendline The trendline that gets drawn when instantiating the drawTrendline() method. 
export type TrendlineLines
    line startline
    line trendline

// @type The object that serves as the class of the library. Inherits all properties and methods.
// @field info Contains properties inside the TrendlineSettings object.
// @field values Contains properties inside the TrendlineData object.
// @field lines Contains properties inside the TrendlineLines object.
export type Trendline
    TrendlineSettings info
    TrendlineData values
    TrendlineLines lines

// @function Creates an instance of the trendline library, accepting parameters that allow the library to function accordingly.
// @param x_axis The x-axis distance between point A and point B.
// @param offset The offset from x2 and the current bar_index. Used in situations where conditions execute ahead of where the x2 location is, such as pivot events.
// @param strictMode Strict mode works in the backend of things to ensure that price hasn't closed below the trendline before the trendline is drawn.
// @param strictType 0 ensures that price during slope calculation is above line, 1 ensures that price during slope calculation is below line.
export new(int x_axis, int offset = 0, bool strictMode = na, int strictType = na) =>
    var line l1 = line.new(na, na, na, na)
    var line l2 = line.new(na, na, na, na)
    Trendline this = Trendline.new(
         TrendlineSettings.new(x_axis, offset, strictMode, strictType),
         TrendlineData.new(na, bar_index - (x_axis + offset), bar_index - offset, na, na, na), 
         TrendlineLines.new(l1, l2)
         )
    switch 
        strictType > 1 or strictType < 0 => 
            runtime.error('strictType must be a value of 0 or 1.')
        strictType > 0 and (na(strictMode) or not strictMode) => 
            runtime.error('strictType can\'t have an assigned value without strictMode being true.')
        strictMode and offset < 1 => 
            runtime.error('Offset must be over 0 in order to use strictMode.')
    this


// @function Draws a new line from the given y-value parameters based on a condition.
// @param condition The condition in order to draw a new line.
// @param y1 The y-value of point A.
// @param y2 the y-value of point B.
// @param src Determines which value strict mode will actively check for leakage before a trendline is drawn.
export method drawLine(Trendline this, bool condition, float y1, float y2, float src = na) =>
    var float savedSlope = na
    var float savedY1 = na
    var float savedY2 = na
    if condition and (na(this.info.strictMode) or not this.info.strictMode)
        this.lines.startline.set_xy1(this.values.x1, y1)
        this.lines.startline.set_xy2(this.values.x2, y2)
        savedSlope := (this.lines.startline.get_y2() - this.lines.startline.get_y1()) / this.info.x_axis
        savedY1 := this.lines.startline.get_y1()
        savedY2 := this.lines.startline.get_y2()
    if condition and this.info.strictMode
        this.values.slope := (y2 - y1) / this.info.x_axis
        bool validElements = na
        for i = 0 to this.info.offset
            j = this.info.offset - i
            if this.info.strictType == 0 ? (na(src) ? close[j] : src[j]) >= y2 + (this.values.slope * (i)) : (na(src) ? close[j] : src[j]) <= y2 + (this.values.slope * (i))
                validElements := true
            else
                validElements := na
                break
        if not na(validElements)
            this.lines.startline.set_xy1(this.values.x1, y1)
            this.lines.startline.set_xy2(this.values.x2, y2)
            savedSlope := (this.lines.startline.get_y2() - this.lines.startline.get_y1()) / this.info.x_axis
            savedY1 := this.lines.startline.get_y1()
            savedY2 := this.lines.startline.get_y2()
    this.values.slope := savedSlope 
    this.values.y1 := savedY1
    this.values.y2 := savedY2
    this.values.changeInX := ta.barssince(ta.change(this.lines.startline.get_y1())) + this.info.offset  


// @function Draws a trendline from the line generated from the drawLine() method.
// @param condition The conditon to maintain the trendline.
export method drawTrendline(Trendline this, bool condition) =>
    if condition
        this.lines.trendline.set_xy1(this.lines.startline.get_x2(), this.lines.startline.get_y2())
        this.lines.trendline.set_xy2(bar_index, this.lines.startline.get_y2() + (this.values.slope * this.values.changeInX))
````
