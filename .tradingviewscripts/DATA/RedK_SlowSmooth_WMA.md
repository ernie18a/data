<!-- tradingview-pine-id: PUB;wzM7wUz6LQu6zEGB6yJdpjO6oX3Z4m4M -->
<!-- tradingviewscripts-format: 1 -->
# RedK Slow_Smooth WMA

Source: https://www.tradingview.com/script/4nmGHAnL-RedK-Slow-Smooth-Average-RSS-WMA/

## Description

RedK Slow Smooth Average (RSS_WMA) is based on simple, multi-WMA passes to generate a moving average that sacrifices low-lag and fast responsiveness for the sake of smoothness. 

This smoothness enables an increased trader ability to visualize and track longer-term trends and removes the noise of smaller, relatively insignificant price fluctuations.

Notes:
=========
* RSS_WMA is deliberately built to be a "lazy line" - and it works in a different way to other common moving averages that attempt to achieve less lag and quicker responsiveness - the idea and the use scenario is to act as a "smooth base" when used against a faster moving average like the v_Wave of the Co_Ra Wave 

* Note that the settings of this line is "Smoothness' and not "length" - the initial length used for the first WMA pass calculation is 1/3 of that smoothness value selected in the settings

* Increments in the combined smoothness value will be allocated first to 1st WMA pass, then 2nd WMA pass, then 3rd pass consecutively then back to 1st pass. 

* because we utilize 3 WMA passes, a settings below 3 will have no effect on the line and it will just track the "source" price.

Suggested Use:
===============
- Use RSS_WMA when you're looking for a smooth moving average that can help  you analyze you chart at a broader / macro level, visualize the broader price action patterns and filter out the noise from short-term moves. you can also use this line to help set your position exits since only major and persistent moves will cause this line, as lay as it is, to swing from one direction to the other.

How does RSS_WMA compare?
============================
here's a quick view of how the RSS_WMA compared to other commonly used Moving Averages, including my recently published CoRa_Wave

https://www.tradingview.com/x/jHlEwjzR/

Code is commented - please feel free to use and customize further - please share a comment if you found this useful in your chart analysis or trading.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader
//@version=4
// ========================================================================================================================
// RedK Slow Smooth WMA (RSS_WMA) is a triple-pass WMA
// The idea here is to create a moving average that prioritizes smoothness over low-lag and fast-responsiveness
// to be used to filter out noise from insignificant or retively smaller price moves and enable visualization and tracking of the longer-term trend
// RSS_WMA can be used as a baseline with a faster MA, to set exit stops, and to help keep in positions for longer drations
// the initial length used for the first WMA pass is 1/3 of the "combined smoothness" value selected in the settings
// increments in the combined smoothness value will be allocated first to 1st pass, then 2nd pass, then 3rd pass consecutievly then back to 1st pass .. and so on.
// *** =====================================================================================================================

study("RedK Slow_Smooth WMA", shorttitle="RSS_WMA v3", overlay = true, resolution = "") 

//===============================================
f_LazyLine(_data, _length) =>
    w1 = 0, w2 = 0, w3 = 0
    L1 = 0.0, L2 = 0.0, L3 = 0.0
    w = _length / 3
    
    if _length > 2 
        w2 := round(w)
        w1 := round((_length-w2)/2)
        w3 :=   int((_length-w2)/2)
        
        L1 := wma(_data, w1)
        L2 := wma(L1, w2)
        L3 := wma(L2, w3)
    else
        L3 := _data
    L3
//====================================


price       = input(title = "Source",                 type = input.source,  defval = close)
alpha       = input(title = "Combined Smoothness",    type = input.integer, defval = 15, minval = 1)

LL = f_LazyLine(price, alpha)

c_up        = color.new(#33ff00, 0)
c_dn        = color.new(#ff1111, 0)
uptrend     = LL > LL[1]

plot(LL,                "SS_WMA Line",  color = uptrend ? c_up : c_dn,  linewidth=3)
plot(wma(price, alpha), "WMA",          color = color.purple,           display=0)

// ========================================================================================================================
// v2: add optional up/dn arrow signal on change of direction (swing) 
ShowSig     = input(title = "Up/Dn Swing Signal?",  type = input.bool,      defval = false)
SigMulti    = input(title = "Signal Locator %", defval = 1.0, step = 0.2, minval = 0, maxval = 20)

SignalOn    = ShowSig and barstate.isconfirmed      // ensure the signal plots *only* after "the bar closes" :) -- insert jokes :)
SwingDn     = uptrend[1] and not(uptrend)
SwingUp     = uptrend and not(uptrend[1])

d           = SigMulti / 100 * LL             //we'll use this to tweak a good location for the signal (that is not tied to price-specific parameters)

plotshape(SignalOn and SwingDn ? LL + d : na, title = "Swing Down", style = shape.triangledown,  location = location.absolute, size = size.small, color = c_dn)
plotshape(SignalOn and SwingUp ? LL - d : na, title = "Swing Up",   style = shape.triangleup,    location = location.absolute, size = size.small, color = c_up)

// ========================================================================================================================
// v3: enable alerts

// need to use alertcondition() to support variable resolution
alertcondition(SwingUp, "RSS_WMA Swing Up", "RSS_WMA Swing Up Detected!")                   // explicit swing up
alertcondition(SwingDn, "RSS_WMA Swing Down", "RSS_WMA Swing Down Detected!")               // explicit swing down
alertcondition(SwingUp or SwingDn, "RSS_WMA Swing", "RSS_WMA Up/Down Swing Detected!")      // either swings
````
