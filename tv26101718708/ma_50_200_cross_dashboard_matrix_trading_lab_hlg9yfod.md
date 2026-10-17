# MA 50 / 200 Cross Dashboard [Matrix Trading Lab]

- url: https://www.tradingview.com/script/hlG9YfOd/
- type: indicator
- pine_id: PUB;de3513f96a144b04a31d69eb21eb6bff
- version: 1.0

## Description

Simple and powerful Moving Average crossover dashboard built for traders who want clarity.

This indicator tracks the classic 50 MA and 200 MA relationship and displays:

✔ Golden Cross signals
✔ Death Cross signals
✔ Last crossover date & time
✔ Current trend alignment
✔ Bars since last signal
✔ Clean dashboard interface

Perfect for swing traders, trend followers and investors watching long-term market direction.

Use it on stocks, crypto, forex and indices.

Interested in this system or looking for more advanced professional indicators?  
For more details, please contact me directly.  
Email: goktugozi@hotmail.com

## Source Code

````pine
//@version=6
indicator("MA 50 / 200 Cross Dashboard", shorttitle="MA 50-200 Dashboard", overlay=true, max_labels_count=500)

//=========================
// INPUTS
//=========================
maType      = input.string("SMA", "Moving Average Type", options=["SMA", "EMA"])
fastLen     = input.int(50, "Fast MA Length", minval=1)
slowLen     = input.int(200, "Slow MA Length", minval=1)
showSignals = input.bool(true, "Show Cross Labels")
showBg      = input.bool(false, "Trend Background")
dashPos     = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

//=========================
// MA FUNCTION
//=========================
maFunc(src, len, type) =>
    type == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

//=========================
// CALCULATIONS
//=========================
maFast = maFunc(close, fastLen, maType)
maSlow = maFunc(close, slowLen, maType)

goldenCross = ta.crossover(maFast, maSlow)
deathCross  = ta.crossunder(maFast, maSlow)

trendBull = maFast > maSlow
trendBear = maFast < maSlow

//=========================
// STORE LAST CROSS INFO
//=========================
var string lastCrossType = "No Cross Yet"
var int    lastCrossBar  = na
var float  lastCrossPrice = na
var int    lastCrossTime = na

if goldenCross
    lastCrossType  := "Golden Cross"
    lastCrossBar   := bar_index
    lastCrossPrice := close
    lastCrossTime  := time

if deathCross
    lastCrossType  := "Death Cross"
    lastCrossBar   := bar_index
    lastCrossPrice := close
    lastCrossTime  := time

barsSinceCross = na(lastCrossBar) ? na : bar_index - lastCrossBar

lastCrossDate = na(lastCrossTime) ? "N/A" : str.format("{0,date,yyyy-MM-dd}", lastCrossTime)
lastCrossHour = na(lastCrossTime) ? "N/A" : str.format("{0,time,HH:mm}", lastCrossTime)

//=========================
// PLOTS
//=========================
plot(maFast, title="MA 50", color=color.new(color.orange, 0), linewidth=2)
plot(maSlow, title="MA 200", color=color.new(color.blue, 0), linewidth=2)

bgcolor(showBg ? (trendBull ? color.new(color.green, 92) : trendBear ? color.new(color.red, 92) : na) : na)

//=========================
// SIGNAL LABELS
//=========================
if showSignals and goldenCross
    label.new(
         bar_index, low,
         "Golden Cross\nMA 50 crossed above MA 200",
         style=label.style_label_up,
         textcolor=color.white,
         color=color.new(color.green, 0),
         size=size.small)

if showSignals and deathCross
    label.new(
         bar_index, high,
         "Death Cross\nMA 50 crossed below MA 200",
         style=label.style_label_down,
         textcolor=color.white,
         color=color.new(color.red, 0),
         size=size.small)

//=========================
// DASHBOARD POSITION
//=========================
tablePos = dashPos == "Top Right" ? position.top_right :
           dashPos == "Top Left" ? position.top_left :
           dashPos == "Bottom Right" ? position.bottom_right :
           position.bottom_left

//=========================
// DASHBOARD
//=========================
var table dash = table.new(tablePos, 2, 8, border_width=1)

headerBg = color.new(color.black, 0)
cellBg   = color.new(color.black, 15)

statusText = trendBull ? "Bullish Alignment" : trendBear ? "Bearish Alignment" : "Neutral"
statusBg   = trendBull ? color.new(color.green, 0) : trendBear ? color.new(color.red, 0) : color.new(color.gray, 0)

crossBg = lastCrossType == "Golden Cross" ? color.new(color.green, 0) :
          lastCrossType == "Death Cross" ? color.new(color.red, 0) :
          color.new(color.gray, 20)

if barstate.islast
    table.cell(dash, 0, 0, "MA 50 / 200 Dashboard", text_color=color.white, bgcolor=headerBg)
    table.cell(dash, 1, 0, maType, text_color=color.white, bgcolor=headerBg)

    table.cell(dash, 0, 1, "MA 50", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 1, str.tostring(maFast, format.mintick), text_color=color.white, bgcolor=cellBg)

    table.cell(dash, 0, 2, "MA 200", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 2, str.tostring(maSlow, format.mintick), text_color=color.white, bgcolor=cellBg)

    table.cell(dash, 0, 3, "Current Trend", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 3, statusText, text_color=color.white, bgcolor=statusBg)

    table.cell(dash, 0, 4, "Last Cross", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 4, lastCrossType, text_color=color.white, bgcolor=crossBg)

    table.cell(dash, 0, 5, "Cross Date", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 5, lastCrossDate, text_color=color.white, bgcolor=cellBg)

    table.cell(dash, 0, 6, "Cross Time", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 6, lastCrossHour, text_color=color.white, bgcolor=cellBg)

    table.cell(dash, 0, 7, "Bars Since Cross", text_color=color.white, bgcolor=cellBg)
    table.cell(dash, 1, 7, na(barsSinceCross) ? "N/A" : str.tostring(barsSinceCross), text_color=color.white, bgcolor=cellBg)

//=========================
// ALERTS
//=========================
alertcondition(goldenCross, title="Golden Cross", message="Golden Cross: MA 50 crossed above MA 200")
alertcondition(deathCross, title="Death Cross", message="Death Cross: MA 50 crossed below MA 200")
````
