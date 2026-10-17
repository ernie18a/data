# Raid On Liquidity indicator by Saif

- url: https://www.tradingview.com/script/jfQ6bDgD-Raid-On-Liquidity-indicator-by-Saif/
- type: indicator
- pine_id: PUB;599abc10aac7487caa902f9454ad2c25
- version: 1.0

## Description

Auto Range Marking 90 minutes before market open range ict hydramacro and equity range

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Aurocks_AIF

//@version=5

indicator("Raid On Liquidity ", overlay=true)

bgColor = input.bool(true, "Activate High/Low View")

LondonColor = color.new(#8ddbfa, 77)
NYColor = color.new(#ee3030, 87)
AsiaColor = color.new(#e7d536, 76)
SydneyColor = color.new(#0d47b3, 90)

///Raid On Liquidity 

res = input.timeframe("D", "Resolution", ["D","W","M"])
london = input.session("0200-0500:1234567", "London Liquidity 2AM-5AM")
ny = input.session("0800-0930:1234567", "NewYork AM liquidity range 8:00AM 9:30AM")
tokyo = input.session("2000-0200:1234567", "Tokyo Session")
sydney = input.session("1200-1330:1234567", "NEW LAUNCH RANGE")

//Bars

is_newbar(sess) =>
    t = time(res, sess, "America/New_York")
    na(t[1]) and not na(t) or t[1] < t

is_session(sess) =>
    not na(time(timeframe.period, sess, "America/New_York"))
    

//London

London = input.bool(true, "London Liquidity 2AM-5AM")

londonNewbar = is_newbar(london)
londonSession = is_session(london)

float londonLow = na
londonLow := if londonSession
    if londonNewbar
        low
    else
        math.min(londonLow[1],low)
else
    londonLow

float londonHigh = na
londonHigh := if londonSession
    if londonNewbar
        high
    else
        math.max(londonHigh[1],high)
else
    londonHigh


plotLL = plot(londonLow, color=color.new(#000000, 100))
plotLH = plot(londonHigh, color=color.new(#000000, 100))
fill(plotLL, plotLH, color = londonSession and London and bgColor ? LondonColor : na)

bgcolor(londonSession and London and not bgColor ? LondonColor : na)



//New York

NY = input.bool(true, "NewYork AM liquidity range 8:00AM 9:30AM")

nyNewbar = is_newbar(ny)
nySession = is_session(ny)

float nyLow = na
nyLow := if nySession
    if nyNewbar
        low
    else
        math.min(nyLow[1],low)
else
    nyLow

float nyHigh = na
nyHigh := if nySession
    if nyNewbar
        high
    else
        math.max(nyHigh[1],high)
else
    nyHigh


plotNYL = plot(nyLow, color=color.new(#000000, 100))
plotNYH = plot(nyHigh, color=color.new(#000000, 100))
fill(plotNYL, plotNYH, color = nySession and NY and bgColor ? NYColor : na)

bgcolor(nySession and NY and not bgColor ? NYColor : na)


//Tokyo

Tokyo = input.bool(true, "Tokyo Session")

tokyoNewbar = is_newbar(tokyo)
tokyoSession = is_session(tokyo)

float tokyoLow = na
tokyoLow := if tokyoSession
    if tokyoNewbar
        low
    else
        math.min(tokyoLow[1],low)
else
    tokyoLow

float tokyoHigh = na
tokyoHigh := if tokyoSession
    if tokyoNewbar
        high
    else
        math.max(tokyoHigh[1],high)
else
    tokyoHigh


plotTL = plot(tokyoLow, color=color.new(#000000, 100))
plotTH = plot(tokyoHigh, color=color.new(#000000, 100))
fill(plotTL, plotTH, color = tokyoSession and Tokyo and bgColor ? AsiaColor : na)

bgcolor(tokyoSession and Tokyo and not bgColor ? AsiaColor : na)



//Sydney

Sydney = input.bool(true, "NEW LAUNCH RANGE")

sydneyNewbar = is_newbar(sydney)
sydneySession = is_session(sydney)

float sydneyLow = na
sydneyLow := if sydneySession
    if sydneyNewbar
        low
    else
        math.min(sydneyLow[1],low)
else
    sydneyLow

float sydneyHigh = na
sydneyHigh := if sydneySession
    if sydneyNewbar
        high
    else
        math.max(sydneyHigh[1],high)
else
    sydneyHigh


plotSL = plot(sydneyLow, color=color.new(#000000, 100))
plotSH = plot(sydneyHigh, color=color.new(#000000, 100))
fill(plotSL, plotSH, color = sydneySession and Sydney and bgColor ? SydneyColor : na)

bgcolor(sydneySession and Sydney and not bgColor ? SydneyColor : na)
````
