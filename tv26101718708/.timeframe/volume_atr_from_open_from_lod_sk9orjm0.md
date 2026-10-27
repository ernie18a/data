# Volume + ATR% From Open + % From LOD

- url: https://www.tradingview.com/script/Sk9ORjM0-Volume-ATR-From-Open-From-LOD/
- type: indicator
- pine_id: PUB;81e0aaa6853647869fa021f03349cabb
- version: 1.0

## Description

This indicator is designed to display the Average True Range (ATR) as a percentage of the current day’s movement, providing a clear and intuitive way to gauge volatility in real time. In this system, a full ATR move is represented as 100%, allowing traders to quickly assess how extended a stock is relative to its typical range. In addition, the indicator tracks and displays the distance from the current price to the low of the day, offering valuable context for risk management and potential downside. By combining ATR-based extension with intraday positioning, this tool helps traders better understand price expansion, identify overextended conditions, and make more informed trading decisions.

## Source Code

````pine
//@version=5
indicator("Volume + ATR% From Open + % From LOD", overlay=false, format=format.volume)

atrLen = input.int(14, "ATR Length in Days", minval=1, group="Calculation")

showAtrFromOpen = input.bool(true, "Show ATR% From Open", group="Display")
showPctFromLod = input.bool(true, "Show % From Low of Day", group="Display")

atrLabelText = input.string("ATR", "ATR Label Text", group="Display")
lodLabelText = input.string("LOD", "LOD Label Text", group="Display")

decimals = input.int(2, "Decimal Places", minval=0, maxval=4, group="Display")
showArrow = input.bool(false, "Show Direction Arrow", group="Display")
showPlusSign = input.bool(true, "Show Plus Sign", group="Display")
separatorText = input.string(" | ", "Separator Text", group="Display")

boxPosInput = input.string("Top Left", "Box Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Style")
textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Style")

upVolumeColor = input.color(color.new(color.green, 35), "Up Volume Color", group="Volume")
downVolumeColor = input.color(color.new(color.red, 35), "Down Volume Color", group="Volume")

showAvgVolumeLine = input.bool(true, "Show Average Volume Line", group="Average Volume")
avgVolumeLength = input.int(20, "Average Volume Length", minval=1, group="Average Volume")
avgVolumeColor = input.color(color.orange, "Average Volume Line Color", group="Average Volume")
avgVolumeWidth = input.int(2, "Average Volume Line Width", minval=1, maxval=5, group="Average Volume")

atrLabelColor = input.color(color.white, "ATR Label Color", group="Info Box Colors")
atrPositiveColor = input.color(color.lime, "ATR Positive Value Color", group="Info Box Colors")
atrNegativeColor = input.color(color.red, "ATR Negative Value Color", group="Info Box Colors")

lodLabelColor = input.color(color.white, "LOD Label Color", group="Info Box Colors")
lodPositiveColor = input.color(color.lime, "LOD Positive Value Color", group="Info Box Colors")
lodNegativeColor = input.color(color.red, "LOD Negative Value Color", group="Info Box Colors")

separatorColor = input.color(color.white, "Separator Color", group="Info Box Colors")
bgColor = input.color(color.new(color.black, 100), "Box Background Color", group="Info Box Colors")
borderColor = input.color(color.new(color.black, 100), "Border Color", group="Info Box Colors")
borderWidth = input.int(0, "Border Width", minval=0, maxval=5, group="Style")

boxPosition = switch boxPosInput
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right" => position.bottom_right

txtSize = switch textSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge

formatPattern = switch decimals
    0 => "#"
    1 => "#.#"
    2 => "#.##"
    3 => "#.###"
    4 => "#.####"

// Basic volume bars.
volumeColor = close >= open ? upVolumeColor : downVolumeColor
plot(volume, title="Volume", style=plot.style_columns, color=volumeColor)

// Average volume line.
avgVolume = ta.sma(volume, avgVolumeLength)
plot(showAvgVolumeLine ? avgVolume : na, title="Average Volume", color=avgVolumeColor, linewidth=avgVolumeWidth)

// ATR% from open.
adrPct = request.security(syminfo.tickerid, "D", ta.sma(((high[1] - low[1]) / close[2]) * 100, atrLen), barmerge.gaps_off, barmerge.lookahead_on)
todayOpen = request.security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_on)

moveFromOpenPct = ((close - todayOpen) / todayOpen) * 100
atrMoveFromOpen = adrPct != 0 and not na(adrPct) ? (moveFromOpenPct / adrPct) * 100 : na

atrIsBull = atrMoveFromOpen >= 0
atrArrow = showArrow ? (atrIsBull ? "▲ " : "▼ ") : ""
atrSign = showPlusSign and atrIsBull ? "+" : ""
atrValue = na(atrMoveFromOpen) ? "N/A" : atrArrow + atrSign + str.tostring(atrMoveFromOpen, formatPattern) + "%"
atrValueColor = atrIsBull ? atrPositiveColor : atrNegativeColor

// Low of day tracking.
// This tracks the low of the current chart day.
// If extended hours are off, it tracks regular-hours bars.
// If extended hours are on, it includes the extended-hours bars shown on your chart.
// On daily charts, it simply uses the daily candle low.
isNewDay = ta.change(time("D")) != 0

var float lowOfDay = na

if timeframe.isintraday
    if isNewDay or na(lowOfDay)
        lowOfDay := low
    else
        lowOfDay := math.min(lowOfDay, low)
else
    lowOfDay := low

// Distance from current price down to low of day.
// Example: current price is 105 and LOD is 100.
// This shows -4.76%, because price would need to fall 4.76% from 105 to reach 100.
pctFromLod = not na(lowOfDay) and close != 0 ? ((lowOfDay - close) / close) * 100 : na

lodArrow = showArrow ? (pctFromLod >= 0 ? "▲ " : "▼ ") : ""
lodSign = showPlusSign and pctFromLod > 0 ? "+" : ""
lodValue = na(pctFromLod) ? "N/A" : lodArrow + lodSign + str.tostring(pctFromLod, formatPattern) + "%"
lodValueColor = pctFromLod >= 0 ? lodPositiveColor : lodNegativeColor

// Compact one-line info box.
var table infoTable = table.new(boxPosition, 5, 1, bgcolor=bgColor, border_color=borderColor, border_width=borderWidth)

if barstate.islast
    table.clear(infoTable, 0, 0, 4, 0)

    col = 0

    if showAtrFromOpen
        table.cell(infoTable, col, 0, atrLabelText + ": ", text_color=atrLabelColor, text_size=txtSize, bgcolor=bgColor)
        col := col + 1

        table.cell(infoTable, col, 0, atrValue, text_color=atrValueColor, text_size=txtSize, bgcolor=bgColor)
        col := col + 1

    if showAtrFromOpen and showPctFromLod
        table.cell(infoTable, col, 0, separatorText, text_color=separatorColor, text_size=txtSize, bgcolor=bgColor)
        col := col + 1

    if showPctFromLod
        table.cell(infoTable, col, 0, lodLabelText + ": ", text_color=lodLabelColor, text_size=txtSize, bgcolor=bgColor)
        col := col + 1

        table.cell(infoTable, col, 0, lodValue, text_color=lodValueColor, text_size=txtSize, bgcolor=bgColor)
        col := col + 1
````
