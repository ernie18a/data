# [FN] Strategy - Store Level on Condition

- url: https://www.tradingview.com/script/WrjN4xGt-FN-Strategy-Store-Level-on-Condition/
- type: indicator
- pine_id: PUB;17e2a7a3b579418698b4eefe93af7aa6
- version: 2.0

## Description

This is a function that you can use in strategies. Not a strategy in and of itself.
Example thumbnail is showing the function applied to a strategy.

Oftentimes, I am asked a question regarding how to hold a variable at a specific, constant level over a conditional period of time. This question is always asked in a very long convoluted way like "I want the strategy to know what the high of the last pivot was while I'm in a long."  or some other variation of wanting a script to remember something from prior bars. 

This function is designed to store a price or some numeric level on the bar that your conditional (bool) statements determine that it should be stored. In this construct, you would set conditional statement(s) to flip the 'hold condition' to be true on the next bar, then hold that value until either the "hold condition" is no longer true or the initial conditions trigger again, causing an update to the level that you want to capture.

You still have to come up with the logic for the start condition and hold condition on your own, but I've provided an example that should give you an idea of how to accomplish this and customize/deploy the function for your purposes.

The function will return 'na' when neither the start condition nor hold condition are true. There's multiple ways to implement this and variations on how the level is chosen. I've written extensive notes in the script to guide you through the logic behind the function. My hope is that it will be useful to those trying to build strategies or anyone attempting to get their script to remember a level under given conditions. 

In the thumbnail example, the take profit level is defined at the beginning of the trade and held until the take profit order executes. The order execution is a separate matter. However, storing the take-profit level at a static value is key to telling the strategy.exit() function what price to execute a limit exit order at.
Example: strategy.exit("Exit Long", from_entry = "long", qty_percent = 100, limit = stored_value)

Let me know how it works out for you and if I can be of any assistance.

[i]Note: Strategy results are mainly derived from the fact that the strategy is long-only, the NQ only goes up, and there is no stop loss in place. So don't ask for the specific strategy, because unless you're trading a single contract with a $500,000 account, you'll probably get liquidated using this strategy as it is presented. [/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kurtsmock

//@version=4
study("Store Level on Condition")

//////////////////////////
// Example Parameters ////
//////////////////////////{
c_entry                 = input("Market", "Entry Type", input.string, options = ["Market", "Limit"])

//-- This script is a study so strategy function isn't actually being used so it will compile without an error.
strategy_position_size  = 1 

//-- A new long trade has been initiated when the position size on the prior bar was <= 0 and is now > 0
newTrade_L     = strategy_position_size[1] <= 0 and strategy_position_size > 0

//-- This is a convoluted but valid way to initialize a variable that will update on execution
inTrade_long   = false, inTrade_long := nz(inTrade_long[1]), inTrade_long := strategy_position_size > 0 

//-- Determines what type of order should be executed. But, this will only serve to inform strategy.entry() and strategy.order()
//-- which is a separate matter. For our purposes, we're choosing which level to store based on the order type we would deploy. 
limit_entry    = c_entry == "Limit" ? true : false     // true = Entry Limit Order, False = Entry Market Order on candle close

//-- Condition Building
startCondition       = newTrade_L and not inTrade_long[1]
holdCondition        = inTrade_long and inTrade_long[1]
whichLvlCondition    = limit_entry
lvl                  = open
altLvl               = hlc3

// Example 1 //
// Holding a static level from starting point - Test for Hold Condition first so a new start condition won't update the level.

// 1. If your Hold Condition is not true, then you're waiting for a start condition. 
// 2. On the bar your start condition is true, the initialization variable is updated with the level defined ( _lvl )
// 3. Your hold condition should then become true on the next bar.
//    On each subsequent bar the hold condition should be true as long as the logic that holds it as true is valid.
//    (e.g. strategy.position_size > 0  This will remain true as long as you have a long trade open, which makes it a good hold condition for a
//    price level in a strategy.)
//    Because the hold condition is true and the function tests for that first, new instances of the start condition will not update the
//    value of the variable.
// 4. When the hold condition is no longer true (e.g. position is closed and the position size is <= 0) AND there is no start condition present
//    the level is set back to na and is waiting for a new start condition to re-initialize the level to be stored.
// 5. When the hold condition is no longer true AND the start condition is present, the level will update

_rememberLvl1(_startCondition, _holdCondition, _lvl) =>
    initialization = float(na)
    if _holdCondition
        initialization := initialization[1]
    else if _startCondition
        initialization := _lvl          // Level to store
    else
        initialization := float(na)
    [initialization]

//-- You can build the conditions as we did on lines 26-30 or you can just insert the conditions
levelExample1_a   = _rememberLvl1(startCondition,                       holdCondition,  lvl)
levelExample1_b   = _rememberLvl1((newTrade_L and not inTrade_long[1]), inTrade_long,   open)

// Example 1 Variation //
// Multiple possible levels. Making the decision on which level to store at the time at which _startCondition = true

// 1. All the above is the same except for how the script determines the level that is stored
// 2. When start condition is true, the script asks a nested if question. 
//    if _whichLvlCondition is true, then choose _lvl, but if not, then choose the _altLvl
//    This can be useful in situations where your standard stop level on a long trade is above the entry price for example
//    or when the long entry price is above the current price.
// 3. This feature can be expanded to a logic tree that fits the strategy. When start condition fires as true, you may want to
//    make certain determiniations to decide what level you want stored. 
// 4. More _whichLvlCondtion(s) can be added to the function by expanding the nested if function starting on line 82.
// 5. To do this, change 'else' on line 84 to 'else if _whichLvlCondtion2'. Then add _whichLvlCondition2 to line 77. 
//    also add _altLvl2 to line 77.  If all _whichLvlCondition(s) are false, then you will set level to na.
//    You can add as many potential levels as you like by expanding that logic by as many 'else if' statements as required.
//    I know that's not super clear, but hopefully it conveys the idea.

_rememberLvl1Alt(_startCondition, _holdCondition, _whichLvlCondition, _lvl, _altLvl) =>
    initialization = float(na)
    if _holdCondition
        initialization := initialization[1]
    else if _startCondition
        if _whichLvlCondition           // e.g. close > open
            initialization := _lvl      // Level to remember
        else
            initialization := _altLvl   // alternative level
    else
        initialization := float(na)
    [initialization]

//-- You can build the conditions as we did on lines 26-30 or you can just insert the conditions
levelsExample1alt_a  = _rememberLvl1Alt(startCondition,                       holdCondition, whichLvlCondition, lvl,  altLvl)
levelsExample1alt_b  = _rememberLvl1Alt((newTrade_L and not inTrade_long[1]), inTrade_long,  limit_entry,       hlc3, open)

// Example 2 //
// Recalculating the stored level on each occurrence of _startCondition or _holdCondition

// 1. In some cases you may want to track a certain value like ATR(20) calculating it only while the condition is running.
// 2. When _startCondition triggers or the _holdCondition keeps it valid, it recalculates the level on each bar.
// 3. However when both of these conditions are false (i.e. when you are flat), it will return na.

_rememberLvl2(_startCondition, _holdCondition, _lvl) =>
    initialization = float(na)
    if _startCondition or _holdCondition
        initialization := _lvl
    else
        initialization := float(na)
    [initialization]

//-- You can build the conditions as we did on lines 26-30 or you can just insert the conditions
levelExample2_a   = _rememberLvl2(startCondition,                       holdCondition, lvl)
levelExample2_b   = _rememberLvl2((newTrade_L and not inTrade_long[1]), inTrade_long,  open)

// Example 3 //
// Update level on each occurence of _startCondition only

// 1. Here the function tests for the presence of the start condition first. 
// 2. When _startCondition = true, then the level is updated. This is true even when the _holdCondition is true. 
// 3. When _startCondition = false and the _holdCondition = true, then it will simply carry the last value forward, keeping
//    the same level as defined by the prior bar.

_rememberLvl3(_startCondition, _holdCondition, _lvl) =>
    initialization = float(na)
    if _startCondition
        initialization := _lvl          // Level to store
    else if _holdCondition
        initialization := initialization[1]
    else
        initialization := float(na)
    [initialization]

//-- You can build the conditions as we did on lines 26-30 or you can just insert the conditions
levelExample3_a   = _rememberLvl3(startCondition,                       holdCondition, lvl)
levelExample3_b   = _rememberLvl3((newTrade_L and not inTrade_long[1]), inTrade_long,  open)


plot(close)
````
