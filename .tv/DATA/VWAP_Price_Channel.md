<!-- tradingview-pine-id: PUB;61fc0dbb24854b5788c601d0f3a6818d -->
<!-- tradingviewscripts-format: 1 -->
# VWAP Price Channel

Source: https://www.tradingview.com/script/Psnjpa2Y-VWAP-Price-Channel/

## Description

VWAP Price Channel cuts the crust off of a traditional price channel (Donchian Channel) by anchoring VWAPs at the highs and lows. By doing this, the flat levels, characteristic of traditional Donchian Channels, are no more!

Author's Note: This indicator is formed with no inherent use, and serves solely as a thought experiment.

> Concept

I would be hesitant to call this a "predictive" indicator, however the behavior of it would suggest it could be considered at least partially predictive

[image]https://www.tradingview.com/x/JGWm5SGV/[/image]

Essentially, the Anchored VWAPs creates something from otherwise nothing. 

While the DC upper or lower values are staying flat, the VWAPs improvise based on price and volume to project a level that may be a better representation of where future highs or lows may settle.

Visually, this looks like we have cut off the corners of the Donchian Channel.

Note: Notice how we are calculating values before the corners are realized.

> Implementation

While this is only a concept indicator, The specific application I've gone with for this, is a sort of supertrend-ish display (A Trend Flipping Trailing Stop Loss).

[image]https://www.tradingview.com/x/js6C6EKE/[/image]

The script uses basic logic to create a trend direction, and then displays the Anchored VWAPs as a form of trailing stop loss.

While "In Trend", the script fills in the area between the VWAP and Price in the direction of trend.

When new highs or lows are made while in trend, the opposite VWAP will start to generate at the new highs or lows. These happen on every new high or low, so they are not indicating the trend shift, but could be interpreted as breakout levels for the current trend direction in order for continuation.

Note: All values are drawn live, but when using higher timeframes, there is a natural calculation discrepancy when using live data vs. historical.

> Technicals

In this script, I'm simply detecting new highs or lows from the DC and using those as the anchor frequency on the built-in VWAP function.

So each time a new high or low is made based on DC, the VWAP function re-anchors to the high or low of the candle.

Past that, I have implemented some logic in order to account for a common occurrence I faced during development. 
Frequently, the price would outpace the anchored VWAP, so we would end up with the VWAP being further from price than the actual DC upper or lower.

Due to this, what I have ended up with was a third value which, rather than switching between raw VWAP values and DC values, it adjusts the value based on the change in the VWAP value. 
This can be simply thought of as a "Start + Change" type of setup.
By doing this, I can use the change values from the actual anchored VWAP, and under normal conditions, this will also be the true VWAP value. 
However, situationally, I am able to update the start value which we're applying the VWAP change to.

In other words, when these situations happen, the VWAP change is added to the new (closer to price) DC value.

The specific trend logic being used is nothing fancy at all, we are simply checking if a new high or low is created and setting the trend in that direction.
This is in line with some traditional DC Strategies.

To those who made it here, 
Just remember: 
The chart may be ugly, but it's the fastest analysis of the data you can get. 
Nicer displays often come at the hidden cost of latency. 
You have to shoot your shot to make it.

Choose 2: Fast, Clean, Useful

Enjoy!

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SamRecio

//@version=6
indicator("VWAP Price Channel", "VPC", overlay = true)

///_____________________________________________________________________________________________________________________
///Inputs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

tf = input.timeframe("", title = "Timeframe")
len = input.int(20, title = "Length", minval = 1)

///_____________________________________________________________________________________________________________________
///VWAP Price Channel Function
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

get_vpc(_len) =>  
    //Main Logic
    var float h_vwap = high
    var float l_vwap = low

    float upper = na
    float lower = na

    hst = ta.highest(_len)
    lst = ta.lowest(_len)

    new_high = high == hst
    new_low = low == lst

    h_vwap := ta.vwap(high,new_high)
    l_vwap := ta.vwap(low,new_low)

    h_change = ta.change(h_vwap)
    l_change = ta.change(l_vwap)

    upper := new_high ? hst : (hst == hst[1] ? upper[1] + h_change : math.min(hst,upper[1] + h_change))
    lower := new_low ? lst : (lst == lst[1] ? lower[1] + l_change : math.max(lst,lower[1] + l_change))

    _avg = math.avg(upper,lower)
    
    //Trend Detection & Coloring
    var int dir = 0
    var int dir2 = 0
    
    dir := new_high?1:new_low?-1:0
    dir2 := new_high?1:new_low?-1:dir2[1]
    
    [upper,lower,_avg,hst,lst,dir,dir2]

//Calling Function
[upper,lower,mid,hst,lst,dir,dir2] = request.security("",tf,get_vpc(len))

///_____________________________________________________________________________________________________________________
///Display
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

u = plot(upper, title = "Upper", color = dir == 1 ? color.rgb(0,0,0,100):color.rgb(255, 3, 62), style = plot.style_linebr)
plot(mid, title = "Mid", color = color.gray, display = display.none)
l = plot(lower, title = "Lower", color = dir == -1 ? color.rgb(0,0,0,100):color.rgb(61, 170, 69), style = plot.style_linebr)
c = plot(close, display = display.none, editable = false)

fill(u,c,dir2 == 1?color.rgb(0,0,0,100):color.rgb(255, 3, 62, 95), title = "Fill")
fill(l,c,dir2 == -1?color.rgb(0,0,0,100):color.rgb(61, 170, 69, 95), title = "Fill")

plot(hst, title = "DC Upper", color = #004d92, display = display.none)
plot(lst, title = "DC Lower", color = #004d92, display = display.none)
//<---nice
````
