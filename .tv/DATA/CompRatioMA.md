<!-- tradingview-pine-id: PUB;pOgLeMa347Zkml8worsHeXu8bvuxiHrh -->
<!-- tradingviewscripts-format: 1 -->
# Comp_Ratio_MA

Source: https://www.tradingview.com/script/NgLjvBWA-RedK-Compound-Ratio-Moving-Average-CoRa-Wave/

## Description

Compound Ratio Weighted Average (CoRa_Wave) is a moving average where the weights increase in a "logarithmically linear" way - from the furthest point in the data to the current point - the formula to calculate these weights work in a similar way to how "compound ratio" works - you start with an initial amount, then add a consistent "ratio of the cumulative prior sum" each period until you reach the end amount. The result is, the "step ratio" between the weights is consistent - This is not the case with linear-weights moving average (WMA), or EMA  

- for example, if you consider a Weighted Moving Average (WMA) of length 5, the weights will be (from the furthest point towards the most current) 1, 2, 3, 4, 5 -- we can see that the ratio between these weights are inconsistent. in fact, the ratio between the 2 furthest points is 2:1, but the ratio between the most recent points is 5:4 -- the ratio is inconsistent, and in fact, more recent points are not getting the best weights they should/can get to counter-act the lag effect. Using the Compound ratio approach addresses that point.

a key advantage here is that we can significantly reduce the "tail weight" - which is "relatively" large in other MAs and would be main cause for lag - giving more weights to the most recent data points - and in a way that is consistent, reliable and easy to "code"

- the outcome is, a moving average line that suffers very little lag regardless of the length, and that can be relied on to track the price movements and swings closely. 

other features:
===============
- An accelerator, or multiplier, has been added to further increase the "aggressiveness" of the moving average line, giving even more weights to the more recent points - the multiplier will have more effect between 1 and 5, then will have a diminishing effect after that - note that a multiplier of 0 (which effectively causes a comp. ratio of 0 to be applied) will produce a Simple Moving Average line :)

- We also added the ability to use an "automatic smoothing" mechanism, that user can over-ride by manually choosing how much smoothing is used. This gives more flexibility to how we can leverage this Moving Average in our charting.

- User can also select the Resolution and Source price for the CoRa_Wave. by default, they will be set to "same as chart" and hlc3

here are the formulas for our Compound Ratio moving average:
[pine]
Compound Weight ratio    r = (A/P)^1/t - 1
Weight at time t         A = P(1 + r)^t 
                           = Start_val * (1 + r) ^ index
index in the above formula is 0 for the furthest point out
[/pine]

Here's how CoRa_Wave compares to other common moving averages all set to the same length (20)
https://www.tradingview.com/x/Xd4iIB2L/

Proposed Usage
- CoRa_Wave can be used for any scenarios where we need a moving average that closely tracks the price, trend, swings with high responsiveness and little lag
- MA Cross-over scenarios - against another CoRa_Wave or any other MA 
- below is a quick example scenario for how to utilize 2 CoRa_Wave lines of same length (one for open and one for closing price) to track swings and trends
- get as creative as you need :)

https://www.tradingview.com/x/s2w3C6MI/

Code is commented - please feel free to leverage or customize further as you need.

👉 if you are interested in other moving averages i posted before, please check out the FiMA and the v_Wave ...

---

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader

study("Comp_Ratio_MA", shorttitle = "CoRa Wave", overlay = true, resolution ="")

// ======================================================================    
// Compound Ratio Weight MA function
// Compound Ratio Weight is where the weight increases in a "logarithmicly linear" way (i.e., linear when plotted on a log chart) - similar to compound ratio
// the "step ratio" between weights is consistent - that's not the case with linear-weight moving average (WMA), or EMA 
// another advantage is we can significantly reduce the "tail weight" - which is "relatively" large in other MAs and contributes to lag
//
// Compound Weight ratio     r = (A/P)^1/t - 1
// Weight at time t         A = P(1 + r)^t 
//                            = Start_val * (1 + r) ^ index
// Note: index is 0 at the furthest point back -- num periods = length -1
//
f_adj_crwma(source, length, Start_Wt, r_multi) =>
    numerator = 0.0, denom = 0.0, c_weight = 0.0
    //Start_Wt = 1.0    // Start Wight is an input in this version - can also be set to a basic value here.
    End_Wt = length     // use length as initial End Weight to calculate base "r"
    r = pow((End_Wt / Start_Wt),(1 / (length - 1))) - 1
    base = 1 + r * r_multi
    for i = 0 to length -1
        c_weight    := Start_Wt * pow(base,(length - i))
        numerator   := numerator + source[i] * c_weight 
        denom       := denom + c_weight
    numerator / denom    
// ====================================================================== ==   

data        = input(title = "Source",                 type = input.source,      defval = hlc3)
length      = input(title = "length",                 type = input.integer,     defval = 20,  minval = 1)
r_multi     = input(title = "Comp Ratio Multiplier",  type = input.float,       defval = 2.0, minval = 0, step = .1)
smooth      = input(title = "Auto Smoothing",         type = input.bool,        defval = true,                    group = "Smoothing")
man_smooth  = input(title = "Manual Smoothing",       type = input.integer,     defval = 1, minval = 1, step = 1, group = "Smoothing")

s           = smooth ? max(round(sqrt(length)),1) : man_smooth
cora_raw    = f_adj_crwma(data, length, 0.01, r_multi)    
cora_wave   = wma(cora_raw, s)

c_up        = color.new(color.aqua, 0)
c_dn        = color.new(#FF9800   , 0)
cora_up     = cora_wave > cora_wave[1]
plot(cora_wave, title="Adjustible CoRa_Wave", color = cora_up ? c_up : c_dn, linewidth = 3)
````
