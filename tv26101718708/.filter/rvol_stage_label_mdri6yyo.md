# RVol + Stage Label

- url: https://www.tradingview.com/script/mDrI6YYO-RVol-Stage-Label/
- type: indicator
- pine_id: PUB;70bac0a790144e49af61a972d971d886
- version: 1.0

## Description

A compact chart label that shows the current trend stage, Stage 2 trend score, relative volume, current volume, and average volume.

The stage logic is based on moving average trend structure, 52-week high/low positioning, and price location versus the 50-day, 150-day, and 200-day moving averages.

Useful for quickly screening momentum stocks and identifying names with strong trend structure and above-average volume.

## Source Code

````pine
//@version=6
indicator("RVol + Stage Label", "RVol Stage", overlay=true, scale=scale.none)

// Inputs
string GP1 = "Input Data"
vol_len = input.int(title="Relative Volume Length", defval=20, group=GP1)

string GP2 = "Display"
txt_sizeopt = input.string(title="Text Size", defval="small", options=["auto", "tiny", "small", "normal", "large", "huge"], group=GP2)

txt_size = txt_sizeopt == "auto" ? size.auto :
     txt_sizeopt == "tiny" ? size.tiny :
     txt_sizeopt == "small" ? size.small :
     txt_sizeopt == "normal" ? size.normal :
     txt_sizeopt == "large" ? size.large :
     size.huge

i_tableYpos = input.string("top", "Panel position", options=["top", "middle", "bottom"], group=GP2)
i_tableXpos = input.string("right", "", options=["left", "center", "right"], group=GP2)

tablePos = switch i_tableYpos + "_" + i_tableXpos
    "top_left" => position.top_left
    "top_center" => position.top_center
    "top_right" => position.top_right
    "middle_left" => position.middle_left
    "middle_center" => position.middle_center
    "middle_right" => position.middle_right
    "bottom_left" => position.bottom_left
    "bottom_center" => position.bottom_center
    => position.bottom_right

// Table
var table rvolDisplay = table.new(tablePos, 1, 1, border_width=1, border_color=color.white)

// Volume calculations
timeFrame = timeframe.isweekly ? "W" : timeframe.ismonthly ? "M" : "D"

today_vol = request.security(syminfo.tickerid, timeFrame, volume)
yday_vol = request.security(syminfo.tickerid, timeFrame, volume[1])
avg_vol = request.security(syminfo.tickerid, timeFrame, ta.sma(volume[1], vol_len))

volpct = avg_vol > 0 ? math.round((today_vol / avg_vol) * 100) : na

avg_vol_display = avg_vol >= 1000000 ? str.tostring(math.round(avg_vol / 1000000, 2)) + " Mil" : str.tostring(math.round(avg_vol / 1000, 2)) + "k"
today_vol_display = today_vol >= 1000000 ? str.tostring(math.round(today_vol / 1000000, 2)) + " Mil" : str.tostring(math.round(today_vol / 1000, 2)) + "k"

// Stage 2 trend checks
sma50 = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

high52w = ta.highest(high, 252)
low52w = ta.lowest(low, 252)

c1 = not na(sma150) and close > sma150
c2 = not na(sma200) and close > sma200
c3 = not na(sma50) and not na(sma150) and sma50 > sma150
c4 = not na(sma50) and not na(sma200) and sma50 > sma200
c5 = not na(sma200) and not na(sma200[21]) and sma200 > sma200[21]

pctAboveLow = low52w > 0 and not na(low52w) ? ((close - low52w) / low52w) * 100 : 0
c6 = pctAboveLow >= 25

pctBelowHigh = high52w > 0 and not na(high52w) ? ((high52w - close) / high52w) * 100 : 100
c7 = pctBelowHigh <= 25

pctFromSma50 = not na(sma50) and sma50 > 0 ? ((close - sma50) / sma50) * 100 : -100
c8 = pctFromSma50 >= -10

passCount = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) + (c5 ? 1 : 0) + (c6 ? 1 : 0) + (c7 ? 1 : 0) + (c8 ? 1 : 0)

isStage2 = passCount == 8
isStage4 = not na(sma200) and not na(sma200[21]) and close < sma200 and sma200 < sma200[21]
isStage3 = not isStage2 and not isStage4 and not na(sma50) and not na(sma200) and close < sma50 and close > sma200
isStage1 = not isStage2 and not isStage3 and not isStage4

stageText = isStage2 ? "Stage 2" : isStage3 ? "Stage 3" : isStage4 ? "Stage 4" : "Stage 1"

// Label colour
labelColor = isStage2 and volpct >= 100 ? color.green :
     isStage2 ? color.teal :
     isStage3 ? color.orange :
     isStage4 ? color.red :
     color.gray

// Compact label
rvolText = na(volpct) ? "N/A" : str.tostring(volpct) + "%"

labelText = stageText + " (" + str.tostring(passCount) + "/8)" +
     " | RVol: " + rvolText +
     " | Vol: " + today_vol_display +
     " | Avg: " + avg_vol_display

if barstate.islast
    table.cell(rvolDisplay, 0, 0, labelText, bgcolor=labelColor, text_color=color.white, text_size=txt_size)

// Optional RVol line
showbarLine = input.bool(false, title="Show Selected Bar RVol Line")

bar_today_vol = volume
bar_avg_vol = ta.sma(volume[1], vol_len)
bar_volpct = bar_avg_vol > 0 ? math.round((bar_today_vol / bar_avg_vol) * 100) : na

plot(bar_volpct, color=showbarLine ? color.red : na, linewidth=1, title="Each Bar RVol")
````
