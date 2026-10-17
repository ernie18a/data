# Price Swing Detection - Smart Money Concept

- url: https://www.tradingview.com/script/GtWKHvJB-Price-Swing-Detection-Smart-Money-Concept/
- type: indicator
- pine_id: PUB;1c949c85374b4758a949221062aa3913
- version: 2.0

## Description

Since my own style is Smart Money Concept and these days I have seen a lot of my friends who are having trouble identifying structures for their indicators and strategies. I wrote this code so they could use it in their strategy . In fact, this type of structure, as one of the strongest technical structures, can increase the success of your strategy according to your personalization.
[image]https://www.tradingview.com/x/l4wnV6KJ/[/image]
The script detects swings (i.e. significant highs and lows) in a financial instrument's price action over a specified period. The user can set the lookback period (number of candles to consider) and the colors of the lines representing bullish and bearish trends.

The script has two functions: detectSwing and pivot high. The detectSwing function calculates the swing highs and lows for the specified number of candles. The function uses the ta.highest and ta.lowest functions to find the highest and lowest prices, respectively, over the lookback period. The function also determines the swing state (high or low) of the current candle and returns the calculated swing values.

The pivot high function calculates the pivot high, which is an important step in detecting bullish structures in the market. If a new top (i.e. swing high) is found, the script updates the pivot high values and creates a line from the recent top to the last bar. The script also updates the trailing maximum values, which are used to extend the top extension line.

[b]For Strategy[/b] :
The variable "trendDirection" in the code is used to keep track of the trend state, either bullish (up trend) or bearish (down trend), in the market. The variable is initialized to 0 which represents a downtrend. The value of this variable is updated later in the code based on the calculations of swing highs and lows, pivot crosses, and the trailing maximum. If a bullish structure is detected, the value of "trendDirection" is set to 1, indicating an uptrend.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MirNader_

//@version=5
indicator("Price Swing Detection - Smart Money Concept" , overlay =  true)

//Input & Swing Detection
// Define the input "swingLength" for the number of candles to look back for Swing detection
int swingLength         = input.int(20, 'Lookback Period' , minval = 5 , tooltip = "Determines the length of bullish and bearish swings in the market")

// Set the line color for bullish trend
color swingcolorBullish = input.color(color.green, 'Bullish Line' , inline = '01' , tooltip = "This line represents the trend direction. Green color indicates a bullish trend and red color indicates a bearish trend")

// Set the line color for bearish trend
color swingcolorBearish = input.color(color.red  , 'Bearish Line' , inline = '01' , tooltip = "This line represents the trend direction. Green color indicates a bullish trend and red color indicates a bearish trend")

//End of Input & Swing Detection
//------------------------------\\
//Swing Detection Function
// The "detectSwing" function will calculate the swing highs and lows for the given number of candles
detectSwing(swingPeriod) =>
// Initialize the "currentSwingState" variable, which will be used to determine the swing state (0 for swing high, 1 for swing low)
    var currentSwingState = 0

// Calculate the highest high and lowest low for the given number of candles
    highestSwing = ta.highest(swingPeriod)
    lowestSwing = ta.lowest(swingPeriod)

    // Determine the swing state based on the current candle high and low compared to the highest high and lowest low
    currentSwingState := high[swingPeriod] > highestSwing ? 0 : low[swingPeriod] < lowestSwing ? 1 : currentSwingState[1]

    // If the current candle is a swing high and the previous candle was not a swing high, set "currentSwingTop" to the current candle high
    currentSwingTop = currentSwingState == 0 and currentSwingState[1] != 0 ? high[swingPeriod] : 0
    // If the current candle is a swing low and the previous candle was not a swing low, set "currentSwingBottom" to the current candle low
    currentSwingBottom = currentSwingState == 1 and currentSwingState[1] != 1 ? low[swingPeriod] : 0

    // Return the calculated swing high and swing low values
    [currentSwingTop, currentSwingBottom]

//End of Swing Detection 
//------------------------------\\
//Parameters
// Initialize the "trendDirection" variable, which will keep track of the trend state (0 for downtrend, 1 for uptrend)
var trendDirection = 0

// Initialize variables for storing pivot high values
var swingTopValue = 0., var swingTopTimestamp = 0

// Initialize variables for storing pivot low values
var swingBottomValue = 0., var swingBottomTimestamp = 0

// Initialize variables for keeping track of the trailing maximum
var trailingSwingHigh          = high, var trailingSwingLow       = low
var trailingSwingHighTimestamp = 0, var trailingSwingLowTimestamp = 0

// Initialize variables for keeping track of pivot crosses
var topCrossCheck = true, var bottomCrossCheck = true

// Call the "detectSwing" function to calculate the swing highs and lows
[currentSwingTop, currentSwingBottom] = detectSwing(swingLength)

//Line Extend
var line extendingTopLine    = na // Initialize a line object for extending the recent top
var line extendingBottomLine = na // Initialize a line object for extending the recent bottom

//End of Parameters
//------------------------------\\
//Pivot High Function
//The calculation of pivot high is an important step in detecting bullish structures in the market
if currentSwingTop
// If a new top is found, set "topCrossCheck" to true
    topCrossCheck := true

    // Delete the previous extendingTopLine line
    line.delete(extendingTopLine[1])
    // Create a new extendingTopLine line from the recent top to the last bar
    extendingTopLine := line.new(bar_index-swingLength, currentSwingTop, bar_index, currentSwingTop, color = swingcolorBullish)

    // Store the pivot high values
    swingTopValue := currentSwingTop
    swingTopTimestamp := bar_index - swingLength

    // Update the trailing maximum values
    trailingSwingHigh := currentSwingTop
    trailingSwingHighTimestamp := bar_index - swingLength
//Update the trailing maximum values
trailingSwingHigh           := math.max(high, trailingSwingHigh)
trailingSwingHighTimestamp  := trailingSwingHigh == high ? bar_index : trailingSwingHighTimestamp

//Set the top extension line properties
if barstate.islast
    line.set_xy1(extendingTopLine, trailingSwingHighTimestamp, trailingSwingHigh)
    line.set_xy2(extendingTopLine, bar_index + 20, trailingSwingHigh)
//End of Pivot High Function
//------------------------------\\
//Pivot Low Function
//the Pivot low is used to detect the presence of a bearish structure in the price movement and update the trend accordingly.
if currentSwingBottom
    // If a new low is found, set "bottomCrossCheck" to true
    bottomCrossCheck := true
    //Extend recent bottom to last bar
    line.delete(extendingBottomLine[1])
    extendingBottomLine := line.new(bar_index - swingLength, currentSwingBottom, bar_index, currentSwingBottom, color = swingcolorBearish)

    //Store the pivot low values
    swingBottomValue     := currentSwingBottom
    swingBottomTimestamp := bar_index - swingLength

    //Update the trailing minimum values
    trailingSwingLow          := currentSwingBottom
    trailingSwingLowTimestamp := bar_index - swingLength
//Update the trailing minimum values
trailingSwingLow          := math.min(low, trailingSwingLow)
trailingSwingLowTimestamp := trailingSwingLow == low ? bar_index : trailingSwingLowTimestamp

    //Set the bottom extension line properties
if barstate.islast
    line.set_xy1(extendingBottomLine, trailingSwingLowTimestamp, trailingSwingLow)
    line.set_xy2(extendingBottomLine, bar_index + 20, trailingSwingLow)

// End of Pivot Low Function
//------------------------------\\
// You can use 'trendDirection' for your strategy to identify the uptrend or downtrend
// This section of code checks if the close price crosses over the trailing maximum value (top_y). 
// If it does, the top_cross boolean is set to false and the trend is set to 1, indicating a bullish trend.
//Detect bullish Structure
if ta.crossover(close, swingTopValue) and topCrossCheck
    topCrossCheck   := false
    trendDirection  := 1

// This section of code checks if the close price crosses under the trailing minimum value (btm_y). 
// If it does, the btm_cross boolean is set to false and the trend is set to -1, indicating a bearish trend.
// Detect bearish Structure
if ta.crossunder(close, swingBottomValue) and bottomCrossCheck
    bottomCrossCheck := false
    trendDirection   := -1

// End
````
