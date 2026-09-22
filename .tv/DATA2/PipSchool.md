<!-- tradingview-pine-id: PUB;7b0cc64096624efb960a999e68a3855b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PipSchool

Source: https://www.tradingview.com/script/7yA77815-PipSchool/

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

---

## Source Code

````pine
//@version=6

indicator("PipSchool", shorttitle="PipSchool", overlay=true)

//=====================================================================
// SESSIONS
//=====================================================================

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


plotLL = plot(londonLow, title="London Low", color=color.new(#000000, 100))
plotLH = plot(londonHigh, title="London High", color=color.new(#000000, 100))
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


plotNYL = plot(nyLow, title="NY Low", color=color.new(#000000, 100))
plotNYH = plot(nyHigh, title="NY High", color=color.new(#000000, 100))
fill(plotNYL, plotNYH, color = nySession and NY and bgColor ? NYColor : na)

bgcolor(nySession and NY and not bgColor ? NYColor : na)


//=====================================================================
// MOVING AVERAGES
//=====================================================================

// --- EMA 9 ---

grpEma9   = "EMA 9"
showEma9  = input.bool(true, "Show EMA 9", group = grpEma9)
ema9Len   = input.int(9, "Length", minval = 1, group = grpEma9)
ema9Src   = input.source(close, "Source", group = grpEma9)
ema9Off   = input.int(0, "Offset", minval = -500, maxval = 500, group = grpEma9)

ema9Value = ta.ema(ema9Src, ema9Len)

plot(showEma9 ? ema9Value : na, title = "EMA 9", color = #2962FF, linewidth = 2, offset = ema9Off)


// --- EMA 21 ---

grpEma21  = "EMA 21"
showEma21 = input.bool(true, "Show EMA 21", group = grpEma21)
ema21Len  = input.int(21, "Length", minval = 1, group = grpEma21)
ema21Src  = input.source(close, "Source", group = grpEma21)
ema21Off  = input.int(0, "Offset", minval = -500, maxval = 500, group = grpEma21)

ema21Value = ta.ema(ema21Src, ema21Len)

plot(showEma21 ? ema21Value : na, title = "EMA 21", color = #FF6D00, linewidth = 2, offset = ema21Off)


// --- SMA 200 ---

grpSma200  = "SMA 200"
showSma200 = input.bool(true, "Show SMA 200", group = grpSma200)
sma200Len  = input.int(200, "Length", minval = 1, group = grpSma200)
sma200Src  = input.source(close, "Source", group = grpSma200)
sma200Off  = input.int(0, "Offset", minval = -500, maxval = 500, group = grpSma200)

sma200Value = ta.sma(sma200Src, sma200Len)

plot(showSma200 ? sma200Value : na, title = "SMA 200", color = #F23645, linewidth = 2, offset = sma200Off)


//=====================================================================
// TREND BIAS LABEL
//=====================================================================

grpBias   = "Trend Bias"
showBias  = input.bool(true, "Show Trend Bias Label", group = grpBias)
biasPos   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpBias)
biasSize  = input.string("Normal", "Text Size", options = ["Small", "Normal", "Large"], group = grpBias)

// --- Bias logic ---
// Bullish  : price above the SMA 200 AND the fast EMA above the slow EMA
// Bearish  : price below the SMA 200 AND the fast EMA below the slow EMA
// Neutral  : the two conditions disagree

bool enoughData = not na(sma200Value)

bool isBull = enoughData and close > sma200Value and ema9Value > ema21Value
bool isBear = enoughData and close < sma200Value and ema9Value < ema21Value

string biasText = not enoughData ? "BIAS: NOT ENOUGH DATA" : isBull ? "BIAS: BULLISH" : isBear ? "BIAS: BEARISH" : "BIAS: NEUTRAL"

string trendLine = not enoughData ? "Need more bars on this chart" :
   (close > sma200Value ? "Price above SMA 200" : "Price below SMA 200")

string emaLine = not enoughData ? "" :
   (ema9Value > ema21Value ? "EMA 9 above EMA 21" : "EMA 9 below EMA 21")

string noteLine = not enoughData ? "" : isBull ? "Bullish structure" : isBear ? "Bearish structure" : "Mixed structure"

color biasColor = not enoughData ? color.new(color.gray, 20) : isBull ? color.new(#089981, 10) : isBear ? color.new(#F23645, 10) : color.new(color.gray, 20)

// --- Draw ---

biasPosition = biasPos == "Top Right" ? position.top_right : biasPos == "Top Left" ? position.top_left : biasPos == "Bottom Right" ? position.bottom_right : position.bottom_left

biasTextSize = biasSize == "Small" ? size.small : biasSize == "Large" ? size.large : size.normal

var table biasTable = table.new(biasPosition, 1, 4, border_width = 1)

if showBias and barstate.islast
    table.cell(biasTable, 0, 0, biasText, text_color = color.white, bgcolor = biasColor, text_size = biasTextSize)
    table.cell(biasTable, 0, 1, trendLine, text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(biasTable, 0, 2, emaLine, text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(biasTable, 0, 3, noteLine, text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
````
