<!-- tradingview-pine-id: PUB;4e89d1b4211f4025af46c2715c5e6cc7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PipSchool

Source: https://www.tradingview.com/script/LoXMFbNO-PipSchool/

## Description

What it does

PipSchool marks the London and New York trading sessions on the chart and overlays three moving averages with a trend-bias reading, so a beginner can see when the market is active and which way it is leaning from a single script instead of loading four separate ones.

Sessions

London and New York toggle on and off independently.
Two display modes: background shading across the full session, or a filled box bounded by the session's high and low. Switch with the Activate High/Low View checkbox.
Session highs and lows build live — the first bar of a session resets the level, and every bar after that extends the running high or low. No repainting of closed bars.
Session times are editable. Defaults are 03:00–12:00 for London and 08:00–17:00 for New York, anchored to the America/New_York timezone, so they hold through daylight-saving shifts without manual adjustment.

Moving averages

EMA 9 and EMA 21 — short-term momentum and the faster of the two crossover signals.
SMA 200 — the longer-term trend filter.
Each has its own Length, Source and Offset inputs plus an on/off switch, and its own colour, width and line style in the Style tab.

Trend bias label
A small on-chart panel reads the moving averages and summarises the picture in plain language: price above or below the SMA 200, the current EMA 9 / EMA 21 relationship, and a combined structure read — Bullish structure, Bearish structure, or Mixed structure — coloured green, red or grey.

How to use it
Use the sessions to decide when you look for trades. The London and New York windows carry most of the day's volume, and a session high or low is a natural reference for a stop or a break level. Use the moving averages to decide which direction you look. The bias label is a summary of what the MAs already show — it is a structure read, not an entry signal, and there are deliberately no buy/sell arrows.

Notes
The SMA 200 needs 200 bars of history before it plots, so it will be blank at the left edge of short intraday charts. That is expected.
Open-source. Read the code, change the defaults, build on it.

---

## Source Code

````pine
//@version=6

indicator("PipSchool", shorttitle="PipSchool", overlay=true)

bgColor = input.bool(false, "Activate High/Low View")

LondonColor = color.new(color.green, 90)
NYColor = color.new(color.red, 90)

///Sessions

res = input.timeframe("D", "Resolution", ["D","W","M"])
london = input.session("0300-1200:1234567", "London Session")
ny = input.session("0800-1700:1234567", "New York Session")

//Bars

is_newbar(sess) =>
    t = time(res, sess, "America/New_York")
    na(t[1]) and not na(t) or t[1] < t

is_session(sess) =>
    not na(time(timeframe.period, sess, "America/New_York"))
    

//London

London = input.bool(true, "London Session")

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

NY = input.bool(true, "New York Session")

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
````
