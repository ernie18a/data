<!-- tradingview-pine-id: PUB;gpa65TEFCGVPq0SF3p3uE9LswgYCC1Kq -->
<!-- tradingviewscripts-format: 1 -->
# Penrose Diagram 3D

Source: https://www.tradingview.com/script/N8flt7gC-Penrose-Diagram/

## Description

Greetings Traders! This is my measly 2 dimensional non-curved take on a Penrose Diagram.
What is a Penrose Diagram?
[https://jila.colorado.edu/~ajsh/insidebh/penrose_schwpar.gif](https://jila.colorado.edu/~ajsh/insidebh/penrose_schwpar.gif)

"A Penrose diagram is a kind of spacetime diagram arranged to make clear the complete causal structure of any given geometry. They are an indispensable map for navigating inside a black hole. Roger Penrose, who invented this kind of diagram in the early 1950s, himself calls them conformal diagrams." - Source: [https://jila.colorado.edu/~ajsh/insidebh/penrose.html](https://jila.colorado.edu/~ajsh/insidebh/penrose.html)

Penrose Diagrams allow an understanding of an infinite surface by projecting 4D Spheres on 2 Dimension Squares. The 4D shape within the 2D Square has the ability to reference a definable edge on an infinite boundary. 

I thought this concept interesting, as I tend to hold a viewpoint of price being infinite in its own nature, and tried to combine the concepts as best I could.

In a true Penrose Diagram, you'd see curvature as you reached the edge of each Diagram Square to represent the curvature of space-time and the distorted boundary. However due to limitations of Pine and perhaps my own abilities, I decided to go the cheap route and opt for straight lines, as well as beginning each new Penrose Diagram on a new Session Start.

Also in this version, you will notice on some instruments that, as an example, two triangles overlap each other when you Extend the Penrose Diagram. The result of this is intentional and is due to the calculation of the first Triangle for the Penrose Diagram. The data points for each triangle are variable upon the average highest/lowest point from Open Price and the Max/Min highest/lowest point from Open Price over a variable amount of days. For typical instruments such as Futures products and Forex, it is common to see differences between the Highest High Breakout & Lowest Low Breakout, and therefore a difference between the true center of the Triangle and the corresponding angles. I prefer to use a 20-Day Average Period for Forex and Futures Products, for Crypto a 30 Day Average Period, all adjustable from the options menu.

Due to the differences between the data points(particularly the difference from the Session Open to the Highest High/ Lowest Low), the initial values for the extended Penrose Diagram will sometimes overlap with the initial triangle for Penrose Diagram creation. However keep in mind, all triangles are exactly the same, just rotated 180°and translated above and below the current Session Open Price. You can confirm this yourself using the handy Triangle Tool in your Drawing Tools directly from your TradingView Chart.
[image]https://www.tradingview.com/x/sAq1mZ2A/[/image]

Haven't managed to play around on all instruments yet, so give it a whirl, and any feedback is greatly appreciated. Hope you enjoy!
-@DayTradingOil

---

## Source Code

````pine
//@version=4
// @DayTradingOil
study("Penrose Diagram 3D", max_bars_back=2880, overlay=true, max_lines_count=500, max_labels_count=500)
// Linebreak String
l = "\n" 
// Time Declaration
t1 = time
// Inputs
chartColor = input(title="Chart Colors", defval="Dark Mode", options=["Dark Mode", "Light Mode"], group='Chart Display')
s = input(title="Resolution", defval="Week", options=["Day", "Week"])
res = s == "Day" ? "D" : "W"
show3D = input(title="Show 3D Penrose Diagram?", defval=true)
showHalf = input(title="Extend Penrose Diagram?", defval=true)
length = input(title="Range Average Day Period", defval=48)

// Color Mode Detection
color colorMode = color.white
colorMode := chartColor == "Dark Mode" ? colorMode : color.black

// Value Declarations
var dayOpen = 0.0
TrueAvgLowValue = 0.0
averageHighBreakoutValue = 0.0
averageTrueHighBreakoutValue = 0.0
//
var int barsSince1D = 0
var int barsSince1W = 0
var array_BarCount1D = array.new_int(0)
var array_BarCount1W = array.new_int(0)
//
var array_HighFromRange = array.new_float(length)
var array_HighFromRangeTrue = array.new_float(length)
var array_LowFromRange = array.new_float(length)
var array_LowFromRangeTrue = array.new_float(length)
var array_RemoveWeekend = array.new_int(7)
var float highDistanceFromRange = 0.0
var float noNewData = 0.0
var float lowDistanceFromRange = 0.0
var float averageLowDistance = 0.0
//
var pieArray =  array.new_line()
var timex = 0     
timeClose = time_close(res)

// --> Custom Function to Round Values to Tick from @PineCoders Backtesting/Trading Engine
// --> (https://www.tradingview.com/script/dYqL95JB-Backtesting-Trading-Engine-PineCoders/)
Round( _val, _decimals) => 
    // Rounds _val to _decimals places.
    _p = pow(10,_decimals)
    round(abs(_val)*_p)/_p*sign(_val)

// --> Function Used to Round Prices to Tick Size Everywhere We Calculate Prices 
RoundToTick( _price) => round(_price/syminfo.mintick)*syminfo.mintick

// Function to ease Trimming Arrays
trimArray(_array, _len) =>
    if array.size(_array) > _len
        array.reverse(_array)
        array.pop(_array)
        if array.size(_array) == _len
            array.reverse(_array)

// --> Custom Function to Check if New Bar == True
// --> (https://www.tradingview.com/wiki/Sessions_and_t1_Functions)
is_newbar(res) =>
    t = time(res)
    change(t) != 0 ? 1 : 0
 
//True When a New Period Begins
newDay = is_newbar("D")
newWeek = is_newbar("W")

// Calculate Number Of Bars to Given Session Based on Your Current t1frame
barsSince1D := not newDay ? barsSince1D + 1  : 1
barsSince1W := not newWeek ? barsSince1W + 1  : 1

// Count Number of Bars per Resolution
array.push(array_BarCount1D, barsSince1D)
array.push(array_BarCount1W, barsSince1W)
 
trimArray(array_BarCount1D, 1440)
trimArray(array_BarCount1W, 1440*7)

// Get Highest Bar Count From Array
numberOfBars1D = array.max(array_BarCount1D)
numberOfBars1W = array.max(array_BarCount1W)

// Set Future End Times for Lines 
timex := (time(s=="Day" ? "D" : "W")-time(s=="Day" ? "D" : "W")[1]) 
timex := round(highest(t1 - timeClose, numberOfBars1W)) + timex
if (s == "Day" and newDay) and syminfo.type != "crypto"
    array.push(array_RemoveWeekend, (t1 + timex) - t1)
    trimArray(array_RemoveWeekend, 7)
    timex := array.mode(array_RemoveWeekend)
t3 = t1 + timex
t2 = show3D ? t1 + (timex/2) : t3

// Highest/Lowest Per Day
hh = highest(high, s == "Day" ? numberOfBars1D : numberOfBars1W)
ll = lowest(low, s == "Day" ? numberOfBars1D : numberOfBars1W)

// Daily/Weekly Open Values
dailyOpen = security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_on)
weeklyOpen = security(syminfo.tickerid, "W", open, barmerge.gaps_off, barmerge.lookahead_on)

// Define a Ternary Condition to Check Whether to use Daily or Weekly Open Price
dayOpen := s == "Day" ? dailyOpen : weeklyOpen

//Calculate High/Low Distances & Sort by Averages & Max/Min Over a Period of Days
if (newDay and s == "Day") or (newWeek and s == "Week") 
    if (hh > dayOpen)
        highDistanceFromRange := hh - dayOpen
        array.push(array_HighFromRange, highDistanceFromRange)
        trimArray(array_HighFromRange, length)
        array.push(array_HighFromRangeTrue, highDistanceFromRange)
        trimArray(array_HighFromRangeTrue, length)
    if hh <= dayOpen
        noNewData := 0
        array.push(array_HighFromRangeTrue, noNewData)
        trimArray(array_HighFromRangeTrue, length)
    if ll < dayOpen
        lowDistanceFromRange := dayOpen - ll
        array.push(array_LowFromRange, lowDistanceFromRange)
        array.push(array_LowFromRangeTrue, lowDistanceFromRange)
        trimArray(array_LowFromRange, length)  
        trimArray(array_LowFromRangeTrue, length)
    if ll >= dayOpen
        noNewData := 0
        array.push(array_LowFromRangeTrue, noNewData)
        trimArray(array_LowFromRangeTrue, length)   


// Retrieve Array Values
averageHighBreakoutValue := RoundToTick(array.avg(array_HighFromRange))
averageTrueHighBreakoutValue := RoundToTick(array.avg(array_HighFromRangeTrue))
averageLowDistance := RoundToTick(array.avg(array_LowFromRange))
TrueAvgLowValue := RoundToTick(array.avg(array_LowFromRangeTrue))
maxBreakoutHigh = array.max(array_HighFromRange) 
maxBreakoutLow = array.max(array_LowFromRange)

// Function to Create Triangles for non-curved 2D Penrose Diagram
//
// ***(Note: Uses the Values Gathered from the High/Low Data. As a Result, Often Times Data Points are not Equal. Due to This Inequality in Data, You
// Will Often See an Extension Triangle Intersecting the Original Triangle. This is to be Expected As Not All Data Points Will Form Right-Angled Triangles.
// Triangle Similarity Can be Confrimed by Using the Triangle Drawing Tool Directly From Your TradingView Chaart.)***
//
pieceOfPie() =>
    if (s == "Day" and newDay) or (s == "Week" and newWeek)
        array.push(pieArray, line.new(t1, dayOpen, t3, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t1, maxBreakoutHigh + dayOpen, t1, dayOpen -maxBreakoutLow, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t1, dayOpen - maxBreakoutLow, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t1, dayOpen - averageLowDistance, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t1, dayOpen - TrueAvgLowValue, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t1, maxBreakoutHigh + dayOpen, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t1, dayOpen + averageHighBreakoutValue, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t1, dayOpen + averageTrueHighBreakoutValue, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
///////////////////////////////////////////////////
//////////////// 3D Original //////////////////////
///////////////////////////////////////////////////
        
        array.push(pieArray, line.new(t3, dayOpen - maxBreakoutLow, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t3, dayOpen - averageLowDistance, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t3, dayOpen - TrueAvgLowValue, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t3, dayOpen + averageHighBreakoutValue, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t3, dayOpen + averageTrueHighBreakoutValue, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t3, maxBreakoutHigh + dayOpen, t3, dayOpen -maxBreakoutLow, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        array.push(pieArray, line.new(t3, maxBreakoutHigh + dayOpen, t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = colorMode, width = 2))
        // Checks If Extend Penrose Diagram Is True
        if showHalf
            // Upper Quadrant
            array.push(pieArray, line.new(t1, (dayOpen + (maxBreakoutHigh)), t2, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen + (maxBreakoutHigh)) + averageHighBreakoutValue, t1, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t1, (dayOpen + (maxBreakoutHigh)), t2, (dayOpen + (maxBreakoutHigh)) + averageTrueHighBreakoutValue, xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen + (maxBreakoutHigh)) - averageLowDistance, t1, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen + (maxBreakoutHigh)) - TrueAvgLowValue, t1, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, maxBreakoutHigh + (dayOpen + (maxBreakoutHigh)), t1, (dayOpen + (maxBreakoutHigh)) , xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, dayOpen + syminfo.mintick, t1, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            // Lower Quadrant
            array.push(pieArray, line.new(t2, dayOpen - (maxBreakoutLow + maxBreakoutHigh), t2, dayOpen, xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t1, (dayOpen - (maxBreakoutLow)), t2, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen - (maxBreakoutLow)) - averageHighBreakoutValue, t1, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t1, (dayOpen - (maxBreakoutLow)), t2, (dayOpen - (maxBreakoutLow)) - averageTrueHighBreakoutValue, xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen - (maxBreakoutLow)) + averageLowDistance, t1, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen - (maxBreakoutLow)) + TrueAvgLowValue, t1, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t1, (dayOpen - (maxBreakoutLow)), t2, dayOpen , xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, dayOpen - (maxBreakoutLow + maxBreakoutHigh), t1, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
///////////////////////////////////////////////////
//////////////// 3D Upper /////////////////////////
///////////////////////////////////////////////////
            array.push(pieArray, line.new(t2, dayOpen + (maxBreakoutHigh + maxBreakoutHigh), t3, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen + (maxBreakoutHigh)), t3, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, dayOpen + syminfo.mintick, t3, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t3, (dayOpen + (maxBreakoutHigh)), t2, (dayOpen + (maxBreakoutHigh)) + averageTrueHighBreakoutValue, xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen + (maxBreakoutHigh)) - averageLowDistance, t3, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen + (maxBreakoutHigh)) - TrueAvgLowValue, t3, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, maxBreakoutHigh + (dayOpen + (maxBreakoutHigh)), t2, (dayOpen + (maxBreakoutHigh)) , xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
            array.push(pieArray, line.new(t2, dayOpen, t2, (dayOpen + (maxBreakoutHigh)), xloc = xloc.bar_time, style = line.style_solid, color = color.yellow, width = 2))
///////////////////////////////////////////////////
//////////////// 3D Lower /////////////////////////
///////////////////////////////////////////////////
            array.push(pieArray, line.new(t2, (dayOpen - (maxBreakoutLow)), t3, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen - (maxBreakoutLow)) - averageHighBreakoutValue, t3, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen - (maxBreakoutLow)) + averageLowDistance, t3, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, (dayOpen - (maxBreakoutLow)) + TrueAvgLowValue, t3, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, dayOpen, t3, (dayOpen - (maxBreakoutLow)) , xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))
            array.push(pieArray, line.new(t2, dayOpen - (maxBreakoutLow + maxBreakoutHigh), t3, (dayOpen - (maxBreakoutLow)), xloc = xloc.bar_time, style = line.style_solid, color = color.red, width = 2))



if array.size(pieArray) > 132
	ln = array.shift(pieArray)
	line.delete(ln)
pieceOfPie()
````
