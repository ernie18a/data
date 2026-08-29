<!-- tradingview-pine-id: PUB;yRCMifZ88lRmBj1mmYPBt9DvCfJp5Tsi -->
<!-- tradingviewscripts-format: 1 -->
# RedK_Directional Index

Source: https://www.tradingview.com/script/mbXXbS1f-RedK-Directional-Index-K-xDMI/

## Description

Here's a modern take on the famous DMI/ADX. i first wrote this on another platform few years ago, so i'm happy to be able to share it on TradingView

quick refresher: what does DMI/ADX tell us: 
------------------------------------------------------
in simple terms, at the core of this indicator, there are 3 main calculations / lines: the Plus Directional Index ( +DI ) which represents how much the bulls are able to push the high of a bar compared to previous one, the Minus Directional Index ( -DI ), showing how much the bears are able to push the low of a bar from previous one, then the Average Directional index ( ADX ) line, which creates an oscillator of the +DI and -DI to represent the strength of a trend -- usually the lines will be colored accordingly (bulls = green, bears = red, and any different color for the ADX )

Similar to my version of the RSI , we take a classic concept, then use the computing and visualization "super powers" available to us today, to extend and improve on what those masters created in the past. I guess they sort of expected us to do exactly that :)

this "extended" version of DMI/ADX provides couple of highly needed features (in my opinion) -- let's explore:
trying as much as possible to avoid jargon - pls forgive me if i failed in some places.
-------------------------------------------------------------------------------------------------
1 - the big change: the ability to visualize the ADX in a way that makes some more sense.
- the original calculation restricted the ADX to oscillate below zero - i'm sure they had a good reason to build it that way in the past - but to me, it becomes super hard to interpret what the ADX line means, especially when a negative trend (the bears) take over. by removing that restriction and allowing the ADX to oscillate up or down (and we're free to do that, so the indicator shows *us* what *we need* to see), we end up with an improved representation of the trend and the trend strength.
- also the original calculation applies a moving average (default 14 bars) of a moving average (another 14 of the Directional Indexes, which represent the strength of bulls vs bears) to calculate the ADX - that makes the ADX very "removed" from the base price values - i change that, and just smooth the initial +Di / -Di then calculate the ADX from there. again, this shows me the outcome of the (relatively) immediate moves.

2 - i use weighted average WMA () in all my averaging calculations .. i believe this type of average is the best to express the importance of recent days / bars vs the ones further in the past, compared to other averaging techniques

3 - ability to make the DMI volume-weighted .. but contrary to my RSI , this is not set by default.

4 - couple of options to view the unrestricted ADX (as an area or as histogram/columns .. which i call Vertical Bars) for improved visualization

other stuff:
5 - a "step" option for the ADX .. you can set the step option to an increment of, say 5 or 10. this is in case you prefer to see the trend more in "quality" terms - so the equivalent of weak, medium, strong, v. strong...etc -- since in reality, a number like 47.7683 doesn't really mean anything specific
6 - optional "strong trend" adjustable level

Settings & usage suggestion:
-----------------------------------
i prefer to use the defaults (length = 7, smoothing = 3, ..etc) -- i believe these are more suitable to the much faster trading that we have now. you can review the comparison chart and see if this works for you, and adjust as you need. 
from a "signal" standpoint, you can use the xDMI as you use the classic DMI/ADX, bulls (or bears) are in control when the corresponding DI line crosses the other going up, *AND* moving above the "strong trend" level that you can set as an extra filter (usually a value between 20 to 30), while ADX will show the quality/strength of the trend. 
i suggest you also utilize this indicator with other trend / momentum confirmation methods, and additional analysis and not in isolation - as well as inspecting the prevailing / longer time frame to ensure you're acting in the direction of the broader move / trend.

the above chart includes a side-by-side comparison between our new xDMI with the classic DMI/ADX using the same settings - then we add at the bottom panel also the xDMI, but with my default (faster) settings and showing other visualization options that can be utilized - the Moving Averages on the top / price panel is just to help put the price movement into perspective in terms of trend and trend strength.

The code is open and commented - please feel free to use, share, comment & provide feedback. if you're a DMI fan, and you find this useful in your trading, i would be more than happy to hear about it
Good luck!

---

## Source Code

````pine
//@version=4
study(title="RedK_Directional Index", shorttitle="K_xDMI", format=format.price, precision=2)

// Inputs 
len = input(7, minval=1, title="DI Length")
smooth = input(3, title="ADX Smoothing", minval=1, maxval=8)
step = input(title="Step", type=input.integer, defval=2, maxval=50, minval=0)
s = input(title="ADX Style", defval="Area", options=["Area", "V.Bars"])
KeyLevel = input(25, title="Key Level", type=input.integer, minval=1, maxval=100)
vol_weighted = input(title="Volume Weighted?", defval=false)
v = vol_weighted ? volume : 1

// calculations -- these are same as the classic ADX/DMI with couple differences; the use of wma() and the volume weighting
up = change(high)
down = -change(low)
plusDM = na(up) ? na : (up > down and up > 0 ? up * v : 0)
minusDM = na(down) ? na : (down > up and down > 0 ? down * v : 0)
trur = wma(tr * v, len)
plus = fixnan(100 * wma(plusDM, len) / trur)
minus = fixnan(100 * wma(minusDM, len) / trur)

// implement wma-based smoothing here -- we will not smoothen the ADX line any further
pluss = wma(plus, smooth)
minuss = wma(minus, smooth)
sum = pluss + minuss

// ADX line here is "unrestricted"  -- meaning it can fall below zero when it detects trend down
adx1 = 100 * (pluss - minuss) / (sum == 0 ? 1 : sum)
adx =  step > 0 ? round(adx1/step) * step : adx1 

// Plot colors & other preps
col_grow_above = #175707
col_fall_above = #66bb6a           
col_grow_below = #e01313
col_fall_below = #e57373
c = adx >= 0 ? (adx > adx[1] ? col_grow_above : col_fall_above) : (adx < adx[1] ? col_grow_below : col_fall_below) 
adxstyle = s == "Area" ? plot.style_area : plot.style_columns

// Plots -- start with the lines, then the background then main plot lines
hline(0, color = color.gray, linestyle = hline.style_solid, editable = false)
hline(KeyLevel, title = "Strong Trend Level", color = color.yellow, linestyle = hline.style_dotted)

plot(adx, title='ADXS', style=adxstyle, color = c, transp=50, linewidth = 3)

plot(pluss, color=color.green, title="+DI", linewidth = 2)
plot(minuss, color=color.red, title="-DI", linewidth = 2)
````
